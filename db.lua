local _, ns = ...

local db = ns.db

local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local defaults = {
    profile = {
        stats = {
            offence = 0,
            defence = 0,
            spirit = 0
        },
        feats = {
            keenSense = false,
            phalanx = false
        },
        racialTraitID = select(3, UnitRace("player"))
    }
}

db.initDb = function(options)
    TEARollHelper.db = AceDB:New("TeaRollHelperDB", defaults)
    options.args.profile = AceDBOptions:GetOptionsTable(TEARollHelper.db)
end