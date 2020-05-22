local _, ns = ...

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

ns.actions = {}
ns.character = {}
ns.db = {}
ns.events = {}
ns.integrations = {}
ns.launchers = {}
ns.resources = {
    feats = {},
    racialTraits = {}
}
ns.rules = {}
ns.state = {}
ns.turns = {}
ns.ui = {}

TEARollHelper = LibStub("AceAddon-3.0"):NewAddon("TEARollHelper", "AceConsole-3.0", "AceEvent-3.0")

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