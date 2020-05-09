local _, ns = ...

local db = ns.db

local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local defaults = {
    profile = {
        stats = {
            offence = 0,
            defence = 0
        },
        feats = {
            keenSense = false
        }
    }
}

db.initDb = function(options)
    TeaRollHelper.db = AceDB:New("TeaRollHelperDB", defaults)
    options.args.profile = AceDBOptions:GetOptionsTable(TeaRollHelper.db)
end