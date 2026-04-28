local configDir = os.getenv("HOME") .. "/.config/ai-router"
local router = configDir .. "/ai-router.sh"
local catalogsDir = configDir .. "/catalogs"
local stateDir = configDir .. "/state"
local hyper = { "ctrl", "alt", "cmd", "shift" }
local paletteChooser = nil
local agentChooser = nil
local suppressAgentChooserUntil = 0
local modifierReleaseWatcher = nil
local modifierReleaseTimeout = nil
local pendingRouterArgs = nil

-- Keep the short suppression window because CapsLock+C shares a physical key
-- path with prompt shortcuts while Karabiner modifiers are still up.
local agentChooserSuppressSeconds = 0.8
local modifierReleaseFallbackSeconds = 0.9
local chooserWidth = 60
local chooserRows = 14

local kindLabels = {
  prompt = "Prompt",
  snippet = "Snippet",
  agent = "Agent",
  skill = "Skill",
  plugin = "Plugin",
  tool = "Tool",
}

local kindOrder = {
  prompt = 10,
  snippet = 20,
  agent = 30,
  skill = 40,
  plugin = 50,
  tool = 60,
}

local function notify(title, message)
  hs.notify.new({ title = title, informativeText = message }):send()
end

local function readJsonArray(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  if not content or content == "" then
    return nil
  end

  local ok, decoded = pcall(hs.json.decode, content)
  if not ok or type(decoded) ~= "table" then
    return nil
  end

  return decoded
end

local function compactText(text)
  return tostring(text or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function truncateText(text, maxChars)
  text = compactText(text)
  maxChars = maxChars or 220

  if not utf8 or not utf8.len or not utf8.offset then
    if #text > maxChars then
      return text:sub(1, maxChars) .. "..."
    end
    return text
  end

  local ok, length = pcall(utf8.len, text)
  if not ok or not length or length <= maxChars then
    return text
  end

  local byteIndex = utf8.offset(text, maxChars + 1)
  if not byteIndex then
    return text
  end

  return text:sub(1, byteIndex - 1) .. "..."
end

local function kindLabel(kind)
  return kindLabels[kind] or tostring(kind or "Item")
end

local function stripCatalogPrefix(text)
  text = compactText(text)
  return text:gsub("^Prompt:%s*", "")
    :gsub("^Snippet:%s*", "")
    :gsub("^Agent:%s*", "")
    :gsub("^Skill:%s*", "")
    :gsub("^Plugin:%s*", "")
    :gsub("^Tool:%s*", "")
end

local function relativeTime(ts)
  ts = tonumber(ts) or 0
  if ts <= 0 then
    return ""
  end

  local diff = math.max(0, hs.timer.secondsSinceEpoch() - ts)
  if diff < 60 then
    return "just now"
  end
  if diff < 3600 then
    return tostring(math.floor(diff / 60)) .. "m ago"
  end
  if diff < 86400 then
    return tostring(math.floor(diff / 3600)) .. "h ago"
  end
  return os.date("%m-%d %H:%M", ts)
end

local function choiceFromRecord(record)
  if type(record) ~= "table" then
    return nil
  end

  local kind = record.kind or record.type
  local value = record.value or record.name or record.path
  if not kind or not value then
    return nil
  end

  local text = record.text or record.title or record.name or value
  local subText = record.subText or record.description or record.searchText or ""

  return {
    text = text,
    subText = subText,
    kind = kind,
    value = value,
    title = record.title or record.text or record.name or value,
    category = record.category or "",
    hotkey = record.hotkey or "",
    searchText = record.searchText or "",
    _rawText = text,
    _rawSubText = subText,
  }
end

local function runRouter(args)
  if hs.fs.attributes(router, "mode") ~= "file" then
    notify("AI Router", "Missing router: " .. router)
    return
  end

  hs.task.new(router, function(exitCode, stdout, stderr)
    if exitCode ~= 0 then
      local message = stderr
      if not message or message == "" then
        message = stdout or "Unknown error"
      end
      notify("AI Router failed", message)
    end
  end, args):start()
end

local function hotkeyModifiersReleased()
  local modifiers = hs.eventtap.checkKeyboardModifiers()
  return not (modifiers.cmd or modifiers.ctrl or modifiers.alt or modifiers.shift)
end

local function stopModifierReleaseWatcher()
  if modifierReleaseWatcher then
    modifierReleaseWatcher:stop()
    modifierReleaseWatcher = nil
  end

  if modifierReleaseTimeout then
    modifierReleaseTimeout:stop()
    modifierReleaseTimeout = nil
  end
end

local function flushPendingRouterArgs()
  local args = pendingRouterArgs
  pendingRouterArgs = nil
  stopModifierReleaseWatcher()

  if args then
    runRouter(args)
  end
end

local function runRouterAfterModifiersReleased(args)
  pendingRouterArgs = args
  suppressAgentChooserUntil = hs.timer.secondsSinceEpoch() + agentChooserSuppressSeconds

  if hotkeyModifiersReleased() then
    flushPendingRouterArgs()
    return
  end

  stopModifierReleaseWatcher()
  modifierReleaseWatcher = hs.eventtap.new({
    hs.eventtap.event.types.flagsChanged,
    hs.eventtap.event.types.keyUp,
  }, function()
    if hotkeyModifiersReleased() then
      flushPendingRouterArgs()
    end
    return false
  end)
  modifierReleaseWatcher:start()

  modifierReleaseTimeout = hs.timer.doAfter(modifierReleaseFallbackSeconds, flushPendingRouterArgs)
end

local fallbackPromptBindings = {
  { key = "a", prompt = "ask", title = "Ask AI", desc = "复制通用问答 prompt" },
  { key = "s", prompt = "summarize", title = "Summarize", desc = "复制总结 prompt" },
  { key = "t", prompt = "translate", title = "Translate", desc = "复制翻译 prompt" },
  { key = "e", prompt = "explain", title = "Explain", desc = "复制解释 prompt" },
  { key = "w", prompt = "rewrite", title = "Rewrite", desc = "复制改写 prompt" },
  { key = "f", prompt = "fix", title = "Fix", desc = "复制修复 prompt" },
  { key = "x", prompt = "extract", title = "Extract", desc = "复制提取 prompt" },
  { key = "r", prompt = "research", title = "Research", desc = "复制研究 prompt" },
  { key = "g", prompt = "generate", title = "Generate", desc = "复制生成 prompt" },
  { key = "d", prompt = "draft", title = "Draft", desc = "复制起草 prompt" },
  { key = "y", prompt = "translate-to-en", title = "Translate to English", desc = "复制中译英 prompt" },
  { key = "=", prompt = "optimize-prompt", title = "Optimize Prompt", desc = "复制提示词增强 prompt" },
}

local fallbackAgentChoices = {
  { text = "Codex CLI", subText = "新开 Warp tab 并粘贴 codex --disable apps", kind = "agent", value = "codex" },
  { text = "Claude Code", subText = "新开 Warp tab 并粘贴 claude", kind = "agent", value = "claude" },
  { text = "Junie", subText = "新开 Warp tab 并粘贴 junie", kind = "agent", value = "junie" },
  { text = "Gemini CLI", subText = "新开 Warp tab 并粘贴 gemini", kind = "agent", value = "gemini" },
  { text = "Kimi CLI", subText = "新开 Warp tab 并粘贴 kimi", kind = "agent", value = "kimi" },
  { text = "Warp Agent", subText = "新开 Warp tab 并放置 Warp Agent 占位命令", kind = "agent", value = "warp-agent" },
  { text = "Codex App", subText = "打开 Codex App", kind = "agent", value = "codex-app" },
}

local toolChoices = {
  { text = "Open Last Output", subText = "打开 cache/last-output.md", kind = "tool", value = "last-output" },
  { text = "Open Last Error", subText = "打开最近一次错误日志", kind = "tool", value = "last-error" },
  { text = "Provider Status", subText = "查看 Kimi/Gemini/Codex/Claude/Junie 状态", kind = "tool", value = "provider-status" },
  { text = "Open AI Router Config", subText = "打开 ~/.config/ai-router", kind = "tool", value = "config" },
  { text = "Open Prompt Folder", subText = "打开 prompts 目录", kind = "tool", value = "prompts" },
  { text = "Open Logs", subText = "打开 logs 目录", kind = "tool", value = "logs" },
  { text = "Rebuild Catalog Index", subText = "重新生成 catalogs/*.json", kind = "tool", value = "index" },
}

local function stateKey(kind, value)
  return tostring(kind or "") .. ":" .. tostring(value or "")
end

local function loadUsageItems()
  local data = readJsonArray(stateDir .. "/usage.json")
  if not data or type(data.items) ~= "table" then
    return {}
  end
  return data.items
end

local function loadFavoriteSet()
  local data = readJsonArray(stateDir .. "/favorites.json")
  local set = {}
  if not data or type(data.items) ~= "table" then
    return set
  end

  for _, item in ipairs(data.items) do
    if item.kind and item.value then
      set[stateKey(item.kind, item.value)] = item
    end
  end

  return set
end

local function annotateChoice(choice, index, usageItems, favoriteSet)
  local key = stateKey(choice.kind, choice.value)
  local usage = usageItems[key] or {}
  local favorite = favoriteSet[key] ~= nil
  local count = tonumber(usage.count) or 0
  local lastUsed = tonumber(usage.last_used_ts) or 0
  local kind = choice.kind or "item"
  local label = kindLabel(kind)
  local title = stripCatalogPrefix(choice.title or choice._rawText or choice.text or choice.value)
  local rawSubText = choice._rawSubText or choice.subText or ""
  local status = {}

  choice._baseIndex = index
  choice._favorite = favorite
  choice._usageCount = count
  choice._lastUsed = lastUsed
  choice._kindOrder = kindOrder[kind] or 999

  if favorite then
    choice.text = "Pinned / " .. label .. " / " .. title
    status[#status + 1] = "pinned"
  elseif lastUsed > 0 then
    choice.text = "Recent / " .. label .. " / " .. title
  else
    choice.text = label .. " / " .. title
  end

  if lastUsed > 0 then
    status[#status + 1] = "used " .. tostring(count) .. "x"
    status[#status + 1] = relativeTime(lastUsed)
  end
  if choice.category and choice.category ~= "" then
    status[#status + 1] = choice.category
  end

  local preview = truncateText(rawSubText, 260)
  if #status > 0 and preview ~= "" then
    choice.subText = table.concat(status, " | ") .. " - " .. preview
  elseif #status > 0 then
    choice.subText = table.concat(status, " | ")
  else
    choice.subText = preview
  end

  return choice
end

local function rankChoices(choices)
  local usageItems = loadUsageItems()
  local favoriteSet = loadFavoriteSet()

  for index, choice in ipairs(choices) do
    annotateChoice(choice, index, usageItems, favoriteSet)
  end

  table.sort(choices, function(a, b)
    if a._favorite ~= b._favorite then
      return a._favorite
    end
    if a._lastUsed ~= b._lastUsed then
      return a._lastUsed > b._lastUsed
    end
    if a._usageCount ~= b._usageCount then
      return a._usageCount > b._usageCount
    end
    if a._kindOrder ~= b._kindOrder then
      return a._kindOrder < b._kindOrder
    end
    return (a._baseIndex or 0) < (b._baseIndex or 0)
  end)

  return choices
end

local function loadPromptBindings()
  local records = readJsonArray(catalogsDir .. "/hotkeys.json")
  if not records then
    return fallbackPromptBindings
  end

  local bindings = {}
  for _, record in ipairs(records) do
    if record.key and record.prompt then
      bindings[#bindings + 1] = {
        key = record.key,
        prompt = record.prompt,
        title = record.title or record.prompt,
        desc = record.desc or record.description or "",
      }
    end
  end

  if #bindings == 0 then
    return fallbackPromptBindings
  end

  return bindings
end

local function promptChoices()
  local choices = {}

  for _, binding in ipairs(loadPromptBindings()) do
    choices[#choices + 1] = {
      text = "Prompt: " .. binding.title,
      subText = binding.desc,
      kind = "prompt",
      value = binding.prompt,
    }
  end

  return choices
end

local function loadAgentChoicesFromCatalog()
  local records = readJsonArray(catalogsDir .. "/agents.json")
  if not records then
    return nil
  end

  local choices = {}
  for _, record in ipairs(records) do
    choices[#choices + 1] = {
      text = record.title or record.name,
      subText = record.description or "",
      kind = "agent",
      value = record.name,
    }
  end

  if #choices == 0 then
    return nil
  end

  return rankChoices(choices)
end

local function loadAgentChoices()
  local catalogChoices = loadAgentChoicesFromCatalog()
  if catalogChoices then
    return catalogChoices
  end

  local choices = {}
  for _, choice in ipairs(fallbackAgentChoices) do
    choices[#choices + 1] = {
      text = choice.text,
      subText = choice.subText,
      kind = choice.kind,
      value = choice.value,
    }
  end

  return rankChoices(choices)
end

local function loadPaletteChoices()
  local records = readJsonArray(catalogsDir .. "/palette.json")
  if not records then
    return nil
  end

  local choices = {}
  for _, record in ipairs(records) do
    local choice = choiceFromRecord(record)
    if choice then
      choices[#choices + 1] = choice
    end
  end

  if #choices == 0 then
    return nil
  end

  return rankChoices(choices)
end

local function allPaletteChoices()
  local cachedChoices = loadPaletteChoices()
  if cachedChoices then
    return cachedChoices
  end

  local choices = promptChoices()

  for _, choice in ipairs(loadAgentChoices()) do
    choices[#choices + 1] = choice
  end

  for _, choice in ipairs(toolChoices) do
    choices[#choices + 1] = choice
  end

  return rankChoices(choices)
end

local function toggleFavorite(choice)
  if not choice or not choice.kind or not choice.value then
    return
  end

  local title = choice.title or choice.text or choice.value
  title = title:gsub("^Pinned / [^/]+ / ", ""):gsub("^Recent / [^/]+ / ", "")
  runRouter({ "favorite", "toggle", choice.kind, choice.value, title })
end

local function executeChoice(choice)
  if not choice then
    return
  end

  if choice.kind == "prompt" then
    runRouterAfterModifiersReleased({ "render", choice.value })
  elseif choice.kind == "snippet" then
    runRouterAfterModifiersReleased({ "snippet", choice.value })
  elseif choice.kind == "skill" then
    runRouterAfterModifiersReleased({ "skill", choice.value })
  elseif choice.kind == "plugin" then
    runRouterAfterModifiersReleased({ "plugin", choice.value })
  elseif choice.kind == "agent" then
    runRouter({ "agent", choice.value })
  elseif choice.kind == "tool" then
    runRouter({ "tool", choice.value })
  end
end

local function showPalette()
  paletteChooser = hs.chooser.new(executeChoice)
  paletteChooser:placeholderText("AI Router")
  paletteChooser:searchSubText(true)
  pcall(function() paletteChooser:width(chooserWidth) end)
  pcall(function() paletteChooser:rows(chooserRows) end)
  paletteChooser:choices(allPaletteChoices())
  pcall(function() paletteChooser:rightClickCallback(toggleFavorite) end)
  paletteChooser:show()
end

local function showAgents()
  if hs.timer.secondsSinceEpoch() < suppressAgentChooserUntil then
    return
  end

  agentChooser = hs.chooser.new(executeChoice)
  agentChooser:placeholderText("AI Coding Agents")
  agentChooser:searchSubText(true)
  pcall(function() agentChooser:width(chooserWidth) end)
  pcall(function() agentChooser:rows(10) end)
  agentChooser:choices(loadAgentChoices())
  pcall(function() agentChooser:rightClickCallback(toggleFavorite) end)
  agentChooser:show()
end

for _, binding in ipairs(loadPromptBindings()) do
  local key = binding.key
  local prompt = binding.prompt

  hs.hotkey.bind(hyper, key, function()
    runRouterAfterModifiersReleased({ "render", prompt })
  end)
end

hs.hotkey.bind(hyper, "space", showPalette)
hs.hotkey.bind(hyper, "c", showAgents)
