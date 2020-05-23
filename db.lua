local _, ns = ...

local db = ns.db
local feats = ns.resources.feats
local traits = ns.resources.traits

local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

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
        traits = {
            [1] = TRAITS.OTHER.id,
            [2] = TRAITS.OTHER.id,
            [3] = TRAITS.OTHER.id
        },
        numWeaknesses = 0,
        racialTraitID = select(3, UnitRace("player"))
    },
    global = {
        settings = {
            minimapIcon = {},
            autoUpdateTRP = false,
        }
    }
}

db.initDb = function(options)
    TEARollHelper.db = AceDB:New("TeaRollHelperDB", defaults)
    options.args.profile = AceDBOptions:GetOptionsTable(TEARollHelper.db)
end