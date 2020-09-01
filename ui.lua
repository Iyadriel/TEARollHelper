local _, ns = ...

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

local function update(moduleName)
    AceConfigRegistry:NotifyChange(moduleName)
end

ui.constants = constants
ui.modules = modules

ui.update = update