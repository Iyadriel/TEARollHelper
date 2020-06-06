local _, ns = ...

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

ns.actions = {}
ns.buffs = {}
ns.bus = {}
ns.character = {}
ns.consequences = {}
ns.constants = {}
ns.db = {}
ns.events = {}
ns.integrations = {}
ns.launchers = {}
ns.resources = {
    enemies = {},
    feats = {},
    racialTraits = {},
    traits = {},
    weaknesses = {}
}
ns.rules = {}
ns.state = {
    character = {},
    rolls = {},
    turn = {}
}
ns.turns = {}
ns.ui = {}

TEARollHelper = LibStub("AceAddon-3.0"):NewAddon("TEARollHelper", "AceConsole-3.0", "AceEvent-3.0")

function TEARollHelper:Debug(...)
    if TEARollHelper.db.global.settings.debug then
        TEARollHelper:Print("[DEBUG]", ...)
    end
end

function TEARollHelper:OnInitialize()
    local config = ns.ui.modules.config
    local turn = ns.ui.modules.turn

    local configOptions = config.getOptions()
    AceConfig:RegisterOptionsTable(config.name, configOptions, {"tea"})
    ns.db.initDb(configOptions)

    self:InitState()

    AceConfig:RegisterOptionsTable(turn.name, turn.getOptions())
    AceConfigDialog:SetDefaultSize(turn.name, 450, 720)

    ns.launchers.initLaunchers()
end