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
ns.gameEvents = {}
ns.integrations = {}
ns.launchers = {}
ns.resources = {
    enemies = {},
    feats = {},
    players = {},
    racialTraits = {},
    traits = {},
    weaknesses = {},
    zones = {},
}
ns.rules = {}
ns.settings = {}
ns.state = {
    buffs = {},
    character = {},
    environment = {},
    rolls = {},
    turn = {}
}
ns.turns = {}
ns.ui = {}
ns.utils = {}

TEARollHelper = LibStub("AceAddon-3.0"):NewAddon("TEARollHelper", "AceConsole-3.0", "AceEvent-3.0")

function TEARollHelper:Debug(...)
    if ns.settings.debug.get() then
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
    AceConfigDialog:SetDefaultSize(turn.name, 630, 720)

    ns.launchers.initLaunchers()
end