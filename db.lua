local _, ns = ...

local db = ns.db

local FEAT_KEYS = ns.resources.feats.FEAT_KEYS

local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local defaults = {
    profile = {
        stats = {
            offence = 0,
            defence = 0,
            spirit = 0
        },
        feats = (function()
            local featDefaults = {}
            for _, featKey in ipairs(FEAT_KEYS) do
                featDefaults[featKey] = false
            end
            return featDefaults
        end)(),
        racialTraitID = select(3, UnitRace("player"))
    }
}

db.initDb = function(options)
    TEARollHelper.db = AceDB:New("TeaRollHelperDB", defaults)
    options.args.profile = AceDBOptions:GetOptionsTable(TEARollHelper.db)
end