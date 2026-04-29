hs.window.animationDuration = 0

if hs.ipc then
  hs.ipc.cliInstall()
end

local aerospace = "/opt/homebrew/bin/aerospace"
local sketchybar = "/opt/homebrew/bin/sketchybar"
local sketchybarUpdater = os.getenv("HOME") .. "/.config/sketchybar/plugins/aerospace_spaces.sh"
local sketchybarNotifications = os.getenv("HOME") .. "/.config/sketchybar/plugins/ai_app_notifications.sh"
local logPath = "/tmp/hammerspoon-workspace-inherit.log"
local maxLogBytes = 256 * 1024
local inheritWindowSeconds = 10
local lastFocusedByBundle = {}
local focusHistoryByBundle = {}
local pendingTargetsByWindow = {}
local queryingWindows = {}
local movingWindows = {}
local movedWindows = {}
local focusRefreshTimer = nil
local focusQueryRunning = false
local focusQueryQueued = false
local workspaceSettleTimer = nil
local aiNotificationRefreshRunning = false
local aiNotificationRefreshStartedAt = 0
local aiNotificationClearTimers = {}
local aiNotificationLastClearAt = {}
local aiAttentionAppByBundle = {
  ["dev.warp.Warp-Stable"] = "warp",
  ["com.openai.codex"] = "codex",
  ["com.jetbrains.intellij"] = "idea",
  ["com.jetbrains.goland"] = "goland",
}

local function log(message)
  local attrs = hs.fs.attributes(logPath)
  if attrs and attrs.size and attrs.size > maxLogBytes then
    os.remove(logPath .. ".1")
    os.rename(logPath, logPath .. ".1")
  end

  local file = io.open(logPath, "a")
  if file then
    file:write(os.date("%Y-%m-%d %H:%M:%S "), message, "\n")
    file:close()
  end
end

local function parseFirstWindowLine(line)
  if not line or line == "" then
    return nil
  end

  local workspace, bundleID, appName, title = line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)\t(.*)$")
  if not workspace or workspace == "" or not bundleID or bundleID == "" then
    return nil
  end

  return {
    workspace = workspace,
    bundleID = bundleID,
    appName = appName or "",
    title = title or "",
  }
end

local function runAerospace(args, callback)
  hs.task.new(aerospace, function(exitCode, stdout, stderr)
    if exitCode ~= 0 then
      log("aerospace failed exit=" .. tostring(exitCode) .. " args=" .. table.concat(args, " ") .. " stderr=" .. (stderr or ""))
      callback(nil, exitCode, stderr)
      return
    end

    callback(stdout or "", exitCode, stderr)
  end, args):start()
end

local function focusedAeroWindowAsync(callback)
  runAerospace({
    "list-windows",
    "--focused",
    "--format",
    "%{workspace}%{tab}%{app-bundle-id}%{tab}%{app-name}%{tab}%{window-title}",
  }, function(output)
    callback(parseFirstWindowLine((output or ""):match("([^\r\n]+)")))
  end)
end

local function rememberFocusedWindowState(focused)
  if not focused then
    return
  end

  local history = focusHistoryByBundle[focused.bundleID] or {}
  local latest = history[1]
  if not latest or latest.workspace ~= focused.workspace then
    table.insert(history, 1, {
      workspace = focused.workspace,
      appName = focused.appName,
      title = focused.title,
      at = os.time(),
    })
    while #history > 5 do
      table.remove(history)
    end
    focusHistoryByBundle[focused.bundleID] = history
  end

  lastFocusedByBundle[focused.bundleID] = {
    workspace = focused.workspace,
    appName = focused.appName,
    title = focused.title,
    at = os.time(),
  }
end

local scheduleRememberFocusedWindow

local function rememberFocusedWindow()
  if focusQueryRunning then
    focusQueryQueued = true
    return
  end

  focusQueryRunning = true
  focusedAeroWindowAsync(function(focused)
    focusQueryRunning = false
    rememberFocusedWindowState(focused)

    if focusQueryQueued then
      focusQueryQueued = false
      scheduleRememberFocusedWindow(0.05)
    end
  end)
end

scheduleRememberFocusedWindow = function(delay)
  if focusRefreshTimer then
    focusRefreshTimer:stop()
  end

  focusRefreshTimer = hs.timer.doAfter(delay or 0.05, function()
    focusRefreshTimer = nil
    rememberFocusedWindow()
  end)
end

local function recentWorkspaceCandidates(bundleID)
  local now = os.time()
  local result = {}
  local seen = {}

  for _, item in ipairs(focusHistoryByBundle[bundleID] or {}) do
    if now - item.at <= inheritWindowSeconds and not seen[item.workspace] then
      result[#result + 1] = item.workspace
      seen[item.workspace] = true
    end
  end

  local remembered = lastFocusedByBundle[bundleID]
  if remembered and now - remembered.at <= inheritWindowSeconds and not seen[remembered.workspace] then
    result[#result + 1] = remembered.workspace
  end

  return result
end

local function parseWindowList(output)
  local windows = {}

  for line in (output or ""):gmatch("[^\r\n]+") do
    local id, workspace, bundleID, title = line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)\t(.*)$")
    if id and workspace and bundleID then
      windows[#windows + 1] = {
        id = id,
        workspace = workspace,
        bundleID = bundleID,
        title = title or "",
      }
    end
  end

  return windows
end

local function listAeroWindowsAsync(callback)
  runAerospace({
    "list-windows",
    "--all",
    "--format",
    "%{window-id}%{tab}%{workspace}%{tab}%{app-bundle-id}%{tab}%{window-title}",
  }, function(output)
    if not output then
      callback(nil)
      return
    end

    callback(parseWindowList(output))
  end)
end

local function findAeroWindowAsync(win, bundleID, title, callback)
  local directID = tostring(win:id())
  listAeroWindowsAsync(function(windows)
    local fallback = nil
    if not windows then
      callback(nil)
      return
    end

    for _, item in ipairs(windows) do
      if item.id == directID then
        callback(item)
        return
      end

      if item.bundleID == bundleID and item.title == title then
        fallback = fallback or item
      end
    end

    callback(fallback)
  end)
end

local function windowKey(win, bundleID, title)
  return tostring(win:id()) .. "\t" .. bundleID .. "\t" .. title
end

local function chooseTargetWorkspace(item, workspaceCandidates)
  local targetWorkspace = workspaceCandidates[1]
  if not item then
    return targetWorkspace
  end

  if item.workspace == targetWorkspace and #workspaceCandidates > 1 then
    return workspaceCandidates[2]
  end

  for index = 2, #workspaceCandidates do
    if item.workspace == workspaceCandidates[index] then
      return item.workspace
    end
  end

  return targetWorkspace
end

local function refreshSketchyBar()
  if hs.fs.attributes(sketchybarUpdater, "mode") == "file" then
    hs.task.new(sketchybarUpdater, nil, {}):start()
  end
end

local function refreshAINotifications()
  if hs.fs.attributes(sketchybarNotifications, "mode") ~= "file" then
    return
  end

  if aiNotificationRefreshRunning then
    if hs.timer.secondsSinceEpoch() - aiNotificationRefreshStartedAt < 15 then
      return
    end

    if _G.wowAINotificationRefreshTask and _G.wowAINotificationRefreshTask:isRunning() then
      _G.wowAINotificationRefreshTask:terminate()
    end

    log("ai notification refresh timed out; restarting")
    aiNotificationRefreshRunning = false
    _G.wowAINotificationRefreshTask = nil
  end

  aiNotificationRefreshRunning = true
  aiNotificationRefreshStartedAt = hs.timer.secondsSinceEpoch()
  _G.wowAINotificationRefreshTask = hs.task.new(sketchybarNotifications, function(exitCode, stdout, stderr)
    aiNotificationRefreshRunning = false
    _G.wowAINotificationRefreshTask = nil
    if exitCode ~= 0 then
      log("ai notification refresh failed exit=" .. tostring(exitCode) .. " stderr=" .. (stderr or ""))
    end
  end, { "paint" })
  _G.wowAINotificationRefreshTask:start()
end

local function triggerAINotificationSync()
  if hs.fs.attributes(sketchybar, "mode") == "file" then
    hs.task.new(sketchybar, nil, { "--trigger", "ai_notification_sync" }):start()
  end
end

local function requestClearAINotification(app)
  local now = hs.timer.secondsSinceEpoch()
  if aiNotificationLastClearAt[app] and now - aiNotificationLastClearAt[app] < 2 then
    return
  end

  if hs.fs.attributes(sketchybarNotifications, "mode") ~= "file" then
    return
  end

  aiNotificationLastClearAt[app] = now
  hs.task.new(sketchybarNotifications, function(exitCode, stdout, stderr)
    if exitCode ~= 0 then
      log("ai notification clear request failed app=" .. tostring(app) .. " exit=" .. tostring(exitCode) .. " stderr=" .. (stderr or ""))
      return
    end

    triggerAINotificationSync()
    hs.timer.doAfter(0.7, refreshAINotifications)
  end, { "request-clear", app }):start()
end

local function scheduleClearAINotificationForBundle(bundleID)
  local app = bundleID and aiAttentionAppByBundle[bundleID]
  if not app then
    return
  end

  if aiNotificationClearTimers[app] then
    aiNotificationClearTimers[app]:stop()
  end

  aiNotificationClearTimers[app] = hs.timer.doAfter(0.5, function()
    aiNotificationClearTimers[app] = nil
    requestClearAINotification(app)
  end)
end

local function scheduleClearAINotificationForFrontmostApp()
  local app = hs.application.frontmostApplication()
  scheduleClearAINotificationForBundle(app and app:bundleID())
end

local function scheduleWorkspaceSettle(delay)
  if workspaceSettleTimer then
    workspaceSettleTimer:stop()
  end

  workspaceSettleTimer = hs.timer.doAfter(delay or 0.08, function()
    workspaceSettleTimer = nil
    runAerospace({ "balance-sizes" }, function()
      refreshSketchyBar()
    end)
  end)
end

local function moveCreatedWindow(win, bundleID, title, workspaceCandidates, key)
  if not win or not win:isStandard() or #workspaceCandidates == 0 then
    return
  end

  if movedWindows[key] or movingWindows[key] or queryingWindows[key] then
    return
  end

  queryingWindows[key] = true
  findAeroWindowAsync(win, bundleID, title, function(item)
    queryingWindows[key] = nil
    if movedWindows[key] or movingWindows[key] or not item then
      return
    end

    local targetWorkspace = pendingTargetsByWindow[key]
    if not targetWorkspace then
      targetWorkspace = chooseTargetWorkspace(item, workspaceCandidates)
      pendingTargetsByWindow[key] = targetWorkspace
      log("target " .. bundleID .. " window=" .. item.id .. " target=" .. targetWorkspace .. " candidates=" .. table.concat(workspaceCandidates, ",") .. " current=" .. item.workspace .. " title=" .. title)
    end

    if item.workspace == targetWorkspace then
      movedWindows[key] = true
      return
    end

    movingWindows[key] = true
    log("inherit " .. bundleID .. " window=" .. item.id .. " " .. item.workspace .. " -> " .. targetWorkspace .. " title=" .. title)
    hs.task.new(aerospace, function(exitCode)
      movingWindows[key] = nil
      if exitCode == 0 then
        movedWindows[key] = true
        hs.timer.doAfter(0.15, refreshSketchyBar)
      else
        log("inherit failed " .. bundleID .. " window=" .. item.id .. " exit=" .. tostring(exitCode) .. " title=" .. title)
      end
    end, {
      "move-node-to-workspace",
      "--focus-follows-window",
      "--window-id",
      item.id,
      targetWorkspace,
    }):start()
  end)
end

local function inheritWorkspaceForCreatedWindow(win)
  local app = win and win:application()
  local bundleID = app and app:bundleID()
  if not bundleID or bundleID == "" then
    return
  end

  local workspaceCandidates = recentWorkspaceCandidates(bundleID)
  if #workspaceCandidates == 0 then
    return
  end

  local title = win:title() or ""
  local key = windowKey(win, bundleID, title)

  log("created " .. bundleID .. " candidates=" .. table.concat(workspaceCandidates, ",") .. " title=" .. title)
  for _, delay in ipairs({ 0.15, 0.45, 0.9 }) do
    hs.timer.doAfter(delay, function()
      moveCreatedWindow(win, bundleID, title, workspaceCandidates, key)
    end)
  end

  hs.timer.doAfter(inheritWindowSeconds + 2, function()
    pendingTargetsByWindow[key] = nil
    queryingWindows[key] = nil
    movingWindows[key] = nil
    movedWindows[key] = nil
  end)
end

hs.window.filter.default:subscribe(hs.window.filter.windowFocused, function(win)
  scheduleRememberFocusedWindow(0.05)
  local app = win and win:application()
  scheduleClearAINotificationForBundle(app and app:bundleID())
end)

hs.window.filter.default:subscribe(hs.window.filter.windowCreated, inheritWorkspaceForCreatedWindow)

hs.window.filter.default:subscribe(hs.window.filter.windowDestroyed, function()
  scheduleWorkspaceSettle(0.08)
end)

local aiHotkeys = os.getenv("HOME") .. "/.hammerspoon/ai_hotkeys.lua"
if hs.fs.attributes(aiHotkeys, "mode") == "file" then
  dofile(aiHotkeys)
end

local appReveal = os.getenv("HOME") .. "/.hammerspoon/app_reveal.lua"
if hs.fs.attributes(appReveal, "mode") == "file" then
  dofile(appReveal)
end

local airForceQuit = os.getenv("HOME") .. "/.hammerspoon/air_force_quit.lua"
if hs.fs.attributes(airForceQuit, "mode") == "file" then
  dofile(airForceQuit)
end

scheduleRememberFocusedWindow(0.05)
if _G.wowAINotificationRefreshTimer then
  _G.wowAINotificationRefreshTimer:stop()
end
_G.wowAINotificationRefreshTimer = hs.timer.doEvery(5, function()
  scheduleClearAINotificationForFrontmostApp()
  refreshAINotifications()
end)
hs.timer.doAfter(1, function()
  scheduleClearAINotificationForFrontmostApp()
  refreshAINotifications()
end)
if _G.wowAIApplicationWatcher then
  _G.wowAIApplicationWatcher:stop()
end
_G.wowAIApplicationWatcher = hs.application.watcher.new(function(appName, eventType, app)
  if eventType == hs.application.watcher.activated then
    scheduleClearAINotificationForBundle(app and app:bundleID())
  end
end)
_G.wowAIApplicationWatcher:start()
log("workspace inherit watcher started")
hs.autoLaunch(true)
