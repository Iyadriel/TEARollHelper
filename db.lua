local _, ns = ...

local bus = ns.bus
local db = ns.db

local feats = ns.resources.feats
local traits = ns.resources.traits
local utilityTypes = ns.resources.utilityTypes

local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local UTILITY_TYPES = utilityTypes.UTILITY_TYPES

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
        weaknesses = {},
        utilityTraits = {
            [1] = { utilityTypeID = UTILITY_TYPES.OTHER.id },
            [2] = { utilityTypeID = UTILITY_TYPES.OTHER.id },
            [3] = { utilityTypeID = UTILITY_TYPES.OTHER.id },
            [4] = { utilityTypeID = UTILITY_TYPES.OTHER.id },
            [5] = { utilityTypeID = UTILITY_TYPES.OTHER.id },
        },
        racialTraitID = select(3, UnitRace("player")),
    },
    global = {
        settings = {
            autoUpdateTRP = false,
            debug = false,
            minimapIcon = {},
            showCustomFeatsTraits = false,
            suggestFatePoints = true,
        },
        warningsSeen = {
            updateTRP = false
        }
    }
}

local function onProfileChanged()
    bus.fire(EVENTS.PROFILE_CHANGED)
end

db.initDb = function(options)
    TEARollHelper.db = AceDB:New("TeaRollHelperDB", defaults)
    options.args.profile = AceDBOptions:GetOptionsTable(TEARollHelper.db)

    TEARollHelper.db.RegisterCallback(TEARollHelper, "OnProfileChanged", onProfileChanged)
    TEARollHelper.db.RegisterCallback(TEARollHelper, "OnProfileCopied", onProfileChanged)
    TEARollHelper.db.RegisterCallback(TEARollHelper, "OnProfileReset", onProfileChanged)
end
