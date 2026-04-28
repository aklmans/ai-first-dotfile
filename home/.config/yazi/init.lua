-- https://github.com/Rolv-Apneseth/.dotfiles/blob/1d230af142770f8056375c73724908de84499f93/yazi/.config/yazi/init.lua
-- PLUGIN SETUP/CONFIG
--- Require plugin, giving a warning notification if a plugin is not found
--- @param plugin_name string
---@return nil|any
local function require_plugin(plugin_name)
    local status_ok, plugin = pcall(require, plugin_name)

    if not status_ok then
        ya.notify({
            title = "Plugins",
            content = "Could not find plugin: " .. plugin_name,
            timeout = 5,
        })
        return nil
    end

    return plugin
end

local bookmarks = require_plugin("bookmarks")
if bookmarks then
    bookmarks:setup({
        notify = {
            enable = true,
            timeout = 1,
            message = {
                new = " Created bookmark '<key>'",
                delete = "󰧌 Deleted bookmark '<key>'",
                delete_all = "󰧌 Deleted all bookmarks",
            },
        },
    })
end

require("full-border"):setup()
