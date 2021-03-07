local _, ns = ...

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

ns.actions = {}
ns.buffs = {}
ns.bus = {}
ns.character = {}
ns.comms = {}
ns.consequences = {}
ns.constants = {}
ns.db = {}
ns.events = {}
ns.gameAPI = {}
ns.gameEvents = {}
ns.integrations = {}
ns.launchers = {}
ns.models = {}
ns.resources = {
    criticalWounds = {},
    enemies = {},
    feats = {},
    players = {},
    racialTraits = {},
    traits = {},
    utilityTypes = {},
    weaknesses = {},
    zones = {},
}
ns.rollHandler = {}
ns.rolls = {}
ns.rules = {}
ns.settings = {}
ns.state = {
    buffs = {},
    character = {},
    environment = {},
    party = {},
    rolls = {},
    turn = {}
}
ns.ui = {}
ns.utils = {}

TEARollHelper = LibStub("AceAddon-3.0"):NewAddon("TEARollHelper", "AceBucket-3.0", "AceComm-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")

local debugFrame = DEFAULT_CHAT_FRAME

for i = 1, NUM_CHAT_WINDOWS do
    local chatFrame = _G["ChatFrame"..i]
    if chatFrame.name == "Debug" then
        debugFrame = chatFrame
    end
end

function TEARollHelper:Debug(...)
    if ns.settings.debug.get() then
        TEARollHelper:Print(debugFrame, ...)
    end
end

function TEARollHelper:OnInitialize()
    local config = ns.ui.modules.config
    local turn = ns.ui.modules.turn

    local configOptions = config.getOptions()
    AceConfig:RegisterOptionsTable(config.name, configOptions, {"tea"})
    AceConfigDialog:SetDefaultSize(config.name, 700, 550)
    ns.db.initDb(configOptions)

    self:InitState()

    AceConfig:RegisterOptionsTable(turn.name, turn.getOptions())
    AceConfigDialog:SetDefaultSize(turn.name, 630, 680)

    ns.launchers.initLaunchers()

    ns.comms.registerComms()
end