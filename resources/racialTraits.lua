local _, ns = ...

local constants = ns.constants
local models = ns.models

local racialTraits = ns.resources.racialTraits

local BuffEffectStat = models.BuffEffectStat

local STATS = constants.STATS

local RACE_IDS = {
    1, -- Human
    3, -- Dwarf
    4, -- Night Elf
    7, -- Gnome
    11, -- Draenei
    22, -- Worgen
    25, -- Pandaren
    29, -- Void Elf
    30, -- Lightforged Draenei
    32, -- Kul Tiran
    34, -- Dark Iron Dwarf
    37 -- Mechagnome
}

local function getRaceName(raceID)
    return C_CreatureInfo.GetRaceInfo(raceID).raceName
end

local RACE_NAMES = {
    [-1] = "None"
}
for i = 1, #RACE_IDS do
    local raceID = RACE_IDS[i]
    RACE_NAMES[raceID] = getRaceName(raceID)
end
RACE_NAMES[100] = "High elf" -- yeah...

local RACIAL_TRAITS_LOOKUP = {
    [-1] = "OUTCAST",
    [1] = "DIPLOMACY",
    [3] = "MIGHT_OF_THE_MOUNTAIN",
    [4] = "QUICKNESS",
    [7] = "EXPANSIVE_MIND",
    [11] = "HEROIC_PRESENCE",
    [22] = "VICIOUSNESS",
    [25] = "INNER_PEACE",
    [29] = "ENTROPIC_EMBRACE",
    [30] = "DEMONBANE",
    [32] = "BRUSH_IT_OFF",
    [34] = "DUNGEON_DELVER",
    [37] = "MASTERCRAFT",
    [100] = "ARCANE_AFFINITY"
}

local DESCRIPTIONS = {
    DIPLOMACY = "Gain an additional +5 to all Utility rolls that rely on friendly interactions with NPCs.",
    MIGHT_OF_THE_MOUNTAIN = "Getting a natural 20 on an Offense or Defense roll provides an additional 4 total damage done. Getting a natural 20 on a healing roll provides an additional 2 total healing done.",
    QUICKNESS = "Gain +2 to Defence while in forested areas.",
    EXPANSIVE_MIND = "Gain an additional +5 to all Utility rolls that rely on your intelligence.",
    HEROIC_PRESENCE = "Gain +1 to Offense, Defense, and Spirit while in areas tainted by evil forces.",
    VICIOUSNESS = "The raw amount needed to achieve a natural 20 on Offense rolls is reduced from 20 to 19 (Becomes 18 with Keen Sense).",
    INNER_PEACE = "Gain an additional +5 to all Utility rolls that rely on the use of your senses, or sheer mental focus.",
    ENTROPIC_EMBRACE = "Gain advantage on all Utility rolls that utilize raw Void Magic, or interact with any Void spellwork not created by yourself.",
    DEMONBANE = "Gain +1 to Offence and Defence when fighting enemies of the following type: Fel, Undead, Void, Eldritch.",
    BRUSH_IT_OFF = "The threshold for resisting a KO is reduced to 12.",
    DUNGEON_DELVER = "Gain +1 to Offense, Defense, and Spirit while indoors or underground.",
    MASTERCRAFT = "Gain advantage on all Utility rolls that rely on the use of Tools or interacts with Mechanical parts.",
    ARCANE_AFFINITY = "Gain advantage on all Utility rolls that utilize raw Arcane Magic, or interacts with any Arcane spellwork not created by yourself.",
}

local RACIAL_TRAITS = {
    OUTCAST = {
        id = -1,
        name = "Outcast",
    },
    DIPLOMACY = {
        id = 1,
        desc = DESCRIPTIONS.DIPLOMACY,
        name = "Diplomacy",
        icon = "Interface\\Icons\\inv_misc_note_02",
        utilityBonus = {
            FRIENDLY_INTERACTIONS = 5,
        }
    },
    MIGHT_OF_THE_MOUNTAIN = {
        id = 3,
        desc = DESCRIPTIONS.MIGHT_OF_THE_MOUNTAIN,
        name = "Might of the Mountain",
        icon = "Interface\\Icons\\inv_hammer_05",
        note = "This is compatible with effects that reduce the critical hit threshold.",
    },
    QUICKNESS = {
        id = 4,
        desc = DESCRIPTIONS.QUICKNESS,
        name = "Quickness",
        icon = "Interface\\Icons\\ability_racial_shadowmeld",
        zones = {
            FOREST = true,
        },
    },
    EXPANSIVE_MIND = {
        id = 7,
        desc = DESCRIPTIONS.EXPANSIVE_MIND,
        name = "Expansive Mind",
        icon = "Interface\\Icons\\inv_enchant_essenceeternallarge",
        utilityBonus = {
            INTELLIGENCE = 5,
        }
    },
    HEROIC_PRESENCE = {
        id = 11,
        desc = DESCRIPTIONS.HEROIC_PRESENCE,
        name = "Heroic Presence",
        icon = "Interface\\Icons\\inv_helmet_21",
        zones = {
            TAINTED = true,
        },
    },
    VICIOUSNESS = {
        id = 22,
        desc = DESCRIPTIONS.VICIOUSNESS,
        name = "Viciousness",
        icon = "Interface\\Icons\\ability_hunter_pet_wolf",
    },
    INNER_PEACE = {
        id = 25,
        desc = DESCRIPTIONS.INNER_PEACE,
        name = "Inner Peace",
        icon = "Interface\\Icons\\pandarenracial_innerpeace",
        utilityBonus = {
            MENTAL_FOCUS = 5,
            SENSES = 5,
        }
    },
    ENTROPIC_EMBRACE = {
        id = 29,
        desc = DESCRIPTIONS.ENTROPIC_EMBRACE,
        name = "Entropic Embrace",
        icon = "Interface\\Icons\\ability_racial_entropicembrace",
        utilityAdvantage = {
            VOID = true,
        }
    },
    DEMONBANE = {
        id = 30,
        desc = DESCRIPTIONS.DEMONBANE,
        name = "Demonbane",
        icon = "Interface\\Icons\\ability_racial_demonbane",
        buffAgainstEnemies = {
            DEMON = true,
            FEL = true,
            ELDRITCH = true,
            UNDEAD = true,
            VOID = true,
        },
    },
    BRUSH_IT_OFF = {
        id = 32,
        desc = DESCRIPTIONS.BRUSH_IT_OFF,
        name = "Brush It Off",
        icon = "Interface\\Icons\\ability_racial_brushitoff",
    },
    DUNGEON_DELVER = {
        id = 34,
        desc = DESCRIPTIONS.DUNGEON_DELVER,
        name = "Dungeon Delver",
        icon = "Interface\\Icons\\ability_racial_dungeondelver",
        zones = {
            INDOORS = true,
            UNDERGROUND = true,
        },
    },
    MASTERCRAFT = {
        id = 37,
        desc = DESCRIPTIONS.MASTERCRAFT,
        name = "Mastercraft",
        icon = "Interface\\Icons\\ability_racial_mastercraft",
        utilityAdvantage = {
            MECHANICAL = true,
        }
    },
    ARCANE_AFFINITY = {
        id = 100,
        desc = DESCRIPTIONS.ARCANE_AFFINITY,
        name = "Arcane Affinity",
        icon = "Interface\\Icons\\inv_enchant_shardglimmeringlarge",
        utilityAdvantage = {
            ARCANE = true,
        }
    },
}

local RACIAL_TRAIT_BUFF_SPECS = {
    [RACIAL_TRAITS.QUICKNESS.id] = {
        effects = {
            BuffEffectStat:New(STATS.defence, 2),
        },
    },
    [RACIAL_TRAITS.HEROIC_PRESENCE.id] = {
        effects = {
            BuffEffectStat:New(STATS.offence, 1),
            BuffEffectStat:New(STATS.defence, 1),
            BuffEffectStat:New(STATS.spirit, 1),
        },
    },
    [RACIAL_TRAITS.DEMONBANE.id] = {
        effects = {
            BuffEffectStat:New(STATS.offence, 1),
            BuffEffectStat:New(STATS.defence, 1),
        },
    },
    [RACIAL_TRAITS.DUNGEON_DELVER.id] = {
        effects = {
            BuffEffectStat:New(STATS.offence, 1),
            BuffEffectStat:New(STATS.defence, 1),
            BuffEffectStat:New(STATS.spirit, 1),
        },
    },
}

local function getRacialTrait(traitID)
    local key = RACIAL_TRAITS_LOOKUP[traitID]
    return RACIAL_TRAITS[key]
end

local function equals(trait1, trait2)
    return trait1 and trait2 and trait1.id == trait2.id
end

racialTraits.RACE_NAMES = RACE_NAMES
racialTraits.RACIAL_TRAITS = RACIAL_TRAITS
racialTraits.RACIAL_TRAIT_BUFF_SPECS = RACIAL_TRAIT_BUFF_SPECS

racialTraits.getRacialTrait = getRacialTrait
racialTraits.equals = equals