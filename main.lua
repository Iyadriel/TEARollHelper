local _, ns = ...

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

ns.actions = {}
ns.bus = {}
ns.character = {}
ns.db = {}
ns.events = {}
ns.integrations = {}
ns.launchers = {}
ns.resources = {
    feats = {},
    racialTraits = {},
    traits = {}
}
ns.rules = {}
ns.state = {}
ns.turns = {}
ns.ui = {}

TEARollHelper = LibStub("AceAddon-3.0"):NewAddon("TEARollHelper", "AceConsole-3.0", "AceEvent-3.0")

TEARollHelper.DEBUG = false

function TEARollHelper:Debug(...)
    if TEARollHelper.DEBUG then
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
    AceConfigDialog:SetDefaultSize(turn.name, 450, 640)

    ns.launchers.initLaunchers()
end