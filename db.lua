local _, ns = ...

local db = ns.db
local feats = ns.resources.feats

local FEATS = feats.FEATS

local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

local defaults = {
    profile = {
        stats = {
            offence = 0,
            defence = 0,
            spirit = 0,
            stamina = 0
        },
        featID = FEATS.FEATLESS.id,
        racialTraitID = select(3, UnitRace("player"))
    },
    global = {
        settings = {
            minimapIcon = {}
        }
    }
}

db.initDb = function(options)
    TEARollHelper.db = AceDB:New("TeaRollHelperDB", defaults)
    options.args.profile = AceDBOptions:GetOptionsTable(TEARollHelper.db)
end