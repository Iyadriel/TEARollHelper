local _, ns = ...

ns.actions = {}
ns.character = {}
ns.db = {}
ns.events = {}
ns.rules = {}
ns.turns = {}
ns.ui = {}

TEARollHelper = LibStub("AceAddon-3.0"):NewAddon("TEARollHelper", "AceConsole-3.0", "AceEvent-3.0")

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function TEARollHelper:OnInitialize()
    local options = ns.ui.getOptions()
    AceConfig:RegisterOptionsTable("TEARollHelper", options, {"tea"})
    ns.db.initDb(options)

    AceConfig:RegisterOptionsTable("TEARollHelperRolls", ns.ui.getRollOptions())
    AceConfigDialog:SetDefaultSize("TEARollHelperRolls", 450, 535)
end