local _, ns = ...

ns.actions = {}
ns.character = {}
ns.db = {}
ns.events = {}
ns.rules = {}
ns.turns = {}
ns.ui = {}

TeaRollHelper = LibStub("AceAddon-3.0"):NewAddon("TeaRollHelper", "AceConsole-3.0", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")

function TeaRollHelper:OnInitialize()
    local options = ns.ui.getOptions()
    AceConfig:RegisterOptionsTable("TeaRollHelper", options, {"tea"})
    ns.db.initDb(options)
end