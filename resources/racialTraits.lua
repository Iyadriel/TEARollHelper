local _, ns = ...

local racialTraits = ns.resources.racialTraits

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
    ENTROPIC_EMBRACE = "When the raw number on your Offense roll perfectly matches the enemy threshold you deal an additional 3 Damage as Shadow Damage.",
    DEMONBANE = "Gain +2 to Offense and Defense when fighting Demons and Warlocks.",
    BRUSH_IT_OFF = "The threshold for resisting a KO is reduced to 12.",
    DUNGEON_DELVER = "Gain +1 to Offense, Defense, and Spirit while indoors or underground.",
    MASTERCRAFT = "Gain advantage on all Utility rolls that rely on the use of Tools or interacts with Mechanical parts.",
    ARCANE_AFFINITY = "Gain advantage on all Utility rolls that utilize raw Arcane Magic, or interacts with any Arcane spellwork not created by yourself.",
}

local RACIAL_TRAITS = {
    OUTCAST = {
        id = -1,
        name = "Outcast",
        supported = true,
        manualActivation = false
    },
    DIPLOMACY = {
        id = 1,
        desc = DESCRIPTIONS.DIPLOMACY,
        name = "Diplomacy",
        icon = "Interface\\Icons\\inv_misc_note_02",
        supported = false,
        manualActivation = true
    },
    MIGHT_OF_THE_MOUNTAIN = {
        id = 3,
        desc = DESCRIPTIONS.MIGHT_OF_THE_MOUNTAIN,
        name = "Might of the Mountain",
        icon = "Interface\\Icons\\inv_hammer_05",
        note = "This is compatible with effects that reduce the critical hit threshold.",
        supported = true,
        manualActivation = false
    },
    QUICKNESS = {
        id = 4,
        desc = DESCRIPTIONS.QUICKNESS,
        name = "Quickness",
        icon = "Interface\\Icons\\ability_racial_shadowmeld",
        note = "Toggle manually in the Character tab.",
        supported = true,
        manualActivation = "Forested area",
        buffs = {
            stats = {
                defence = 2
            }
        }
    },
    EXPANSIVE_MIND = {
        id = 7,
        desc = DESCRIPTIONS.EXPANSIVE_MIND,
        name = "Expansive Mind",
        icon = "Interface\\Icons\\inv_enchant_essenceeternallarge",
        supported = false,
        manualActivation = true
    },
    HEROIC_PRESENCE = {
        id = 11,
        desc = DESCRIPTIONS.HEROIC_PRESENCE,
        name = "Heroic Presence",
        icon = "Interface\\Icons\\inv_helmet_21",
        supported = false,
        manualActivation = true
    },
    VICIOUSNESS = {
        id = 22,
        desc = DESCRIPTIONS.VICIOUSNESS,
        name = "Viciousness",
        icon = "Interface\\Icons\\ability_hunter_pet_wolf",
        supported = true,
        manualActivation = false
    },
    INNER_PEACE = {
        id = 25,
        desc = DESCRIPTIONS.INNER_PEACE,
        name = "Inner Peace",
        icon = "Interface\\Icons\\pandarenracial_innerpeace",
        supported = false,
        manualActivation = true
    },
    ENTROPIC_EMBRACE = {
        id = 29,
        desc = DESCRIPTIONS.ENTROPIC_EMBRACE,
        name = "Entropic Embrace",
        icon = "Interface\\Icons\\ability_racial_entropicembrace",
        supported = true,
        manualActivation = false
    },
    DEMONBANE = {
        id = 30,
        desc = DESCRIPTIONS.DEMONBANE,
        name = "Demonbane",
        icon = "Interface\\Icons\\ability_racial_demonbane",
        supported = true,
        manualActivation = false,
        buffAgainstEnemies = {
            DEMON = true,
            WARLOCK = true,
        },
        buffs = {
            stats = {
                offence = 2,
                defence = 2,
            }
        },
    },
    BRUSH_IT_OFF = {
        id = 32,
        desc = DESCRIPTIONS.BRUSH_IT_OFF,
        name = "Brush It Off",
        icon = "Interface\\Icons\\ability_racial_brushitoff",
        supported = false,
        manualActivation = false
    },
    DUNGEON_DELVER = {
        id = 34,
        desc = DESCRIPTIONS.DUNGEON_DELVER,
        name = "Dungeon Delver",
        icon = "Interface\\Icons\\ability_racial_dungeondelver",
        supported = false,
        manualActivation = false
    },
    MASTERCRAFT = {
        id = 37,
        desc = DESCRIPTIONS.MASTERCRAFT,
        name = "Mastercraft",
        icon = "Interface\\Icons\\ability_racial_mastercraft",
        supported = false,
        manualActivation = true
    },
    ARCANE_AFFINITY = {
        id = 100,
        desc = DESCRIPTIONS.ARCANE_AFFINITY,
        name = "Arcane Affinity",
        icon = "Interface\\Icons\\inv_enchant_shardglimmeringlarge",
        supported = false,
        manualActivation = true
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
racialTraits.getRacialTrait = getRacialTrait
racialTraits.equals = equals