local _, ns = ...

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

ns.actions = {}
ns.character = {}
ns.db = {}
ns.events = {}
ns.launchers = {}
ns.resources = {
    feats = {},
    racialTraits = {}
}
ns.rules = {}
ns.turns = {}
ns.turnState = {}
ns.ui = {}

TEARollHelper = LibStub("AceAddon-3.0"):NewAddon("TEARollHelper", "AceConsole-3.0", "AceEvent-3.0")

function TEARollHelper:OnInitialize()
    local config = ns.ui.modules.config
    local rolls = ns.ui.modules.rolls
    local turn = ns.ui.modules.turn

    local configOptions = config.getOptions()
    AceConfig:RegisterOptionsTable(config.name, configOptions, {"tea"})
    ns.db.initDb(configOptions)

    AceConfig:RegisterOptionsTable(rolls.name, rolls.getOptions())
    AceConfigDialog:SetDefaultSize(rolls.name, 450, 640)

    AceConfig:RegisterOptionsTable(turn.name, turn.getOptions())

    ns.launchers.initLaunchers()
end