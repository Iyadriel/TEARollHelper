local _, ns = ...

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local ui = ns.ui

local constants = {
    FRIENDLY_ADDON_NAME = "TEA Roll Helper"
}

local modules = {
    actions = {},
    config = {
        name = "TEARollHelper",
        friendlyName = constants.FRIENDLY_ADDON_NAME,
    },
    turn = {
        name = "TEARollHelperTurn",
        friendlyName = "Turn View"
    }
}

local function openWindow(name)
    AceConfigDialog:Open(name)
end

local function toggleWindow(name)
    if AceConfigDialog.OpenFrames[name] then
        AceConfigDialog:Close(name)
    else
        openWindow(name)
    end
end

local function update(moduleName)
    AceConfigRegistry:NotifyChange(moduleName)
end

local function iconString(iconPath, size, crop)
    if crop == nil then crop = true end

    if size and size == "small" then
        if crop then
            return "|T" .. iconPath .. ":12:12:0:0:12:12:1:11:1:11|t "
        end

        return "|T" .. iconPath .. ":12|t "
    end

    if crop then
        return "|T" .. iconPath .. ":14:14:0:0:14:14:1:13:1:13|t "
    end

    return "|T" .. iconPath .. ":14|t "
end

ui.constants = constants
ui.modules = modules

ui.openWindow = openWindow
ui.toggleWindow = toggleWindow
ui.update = update
ui.iconString = iconString