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

local RACIAL_TRAIT_DESCRIPTIONS = {
    [1] = "Gain an additional +5 to all Utility rolls that rely on friendly interactions with NPCs.",
    [3] = "Getting a natural 20 on an Offense or Defense roll provides an additional 4 total damage done. Getting a natural 20 on a healing roll provides an additional 2 total healing done.",
    [4] = "Gain +2 to Defence while in forested areas.",
    [7] = "Gain an additional +5 to all Utility rolls that rely on your intelligence.",
    [11] = "Gain +1 to Offense, Defense, and Spirit while in areas tainted by evil forces.",
    [22] = "The raw amount needed to achieve a natural 20 on Offense rolls is reduced from 20 to 19 (Becomes 18 with Keen Sense).",
    [25] = "Gain an additional +5 to all Utility rolls that rely on the use of your senses, or sheer mental focus.",
    [29] = "When the raw number on your Offense roll perfectly matches the enemy threshold you deal an additional 3 Damage as Shadow Damage.",
    [30] = "Gain +2 to Offense and Defense when fighting Demons and Warlocks.",
    [32] = "The threshold for resisting a KO is reduced to 12.",
    [34] = "Gain +1 to Offense, Defense, and Spirit while indoors or under ground.",
    [37] = "Gain advantage on all Utility rolls that rely on the use of Tools or interacts with Mechanical parts.",
    [100] = "Gain advantage on all Utility rolls that utilize raw Arcane Magic, or interacts with any Arcane spellwork not created by yourself.",
}

local RACIAL_TRAITS = {
    [-1] = { raceID = -1, name = "Outcast", supported = true, manualActivation = false },
    [1] = { raceID = 1, desc = RACIAL_TRAIT_DESCRIPTIONS[1], name = "Diplomacy", supported = false, manualActivation = true },
    [3] = { raceID = 3, desc = RACIAL_TRAIT_DESCRIPTIONS[3], name = "Might of the Mountain", supported = true, manualActivation = false },
    [4] = { raceID = 7, desc = RACIAL_TRAIT_DESCRIPTIONS[4], name = "Quickness", supported = true, manualActivation = true },
    [7] = { raceID = 7, desc = RACIAL_TRAIT_DESCRIPTIONS[7], name = "Expansive Mind", supported = false, manualActivation = true },
    [11] = { raceID = 11, desc = RACIAL_TRAIT_DESCRIPTIONS[11], name = "Heroic Presence", supported = true, manualActivation = true },
    [22] = { raceID = 22, desc = RACIAL_TRAIT_DESCRIPTIONS[22], name = "Viciousness", supported = true, manualActivation = false },
    [25] = { raceID = 25, desc = RACIAL_TRAIT_DESCRIPTIONS[25], name = "Inner Peace", supported = false, manualActivation = true },
    [29] = { raceID = 29, desc = RACIAL_TRAIT_DESCRIPTIONS[29], name = "Entropic Embrace", supported = true, manualActivation = false },
    [30] = { raceID = 30, desc = RACIAL_TRAIT_DESCRIPTIONS[30], name = "Demonbane", supported = true, manualActivation = true },
    [32] = { raceID = 32, desc = RACIAL_TRAIT_DESCRIPTIONS[32], name = "Brush It Off", supported = false, manualActivation = false },
    [34] = { raceID = 34, desc = RACIAL_TRAIT_DESCRIPTIONS[34], name = "Dungeon Delver", supported = true, manualActivation = false },
    [37] = { raceID = 37, desc = RACIAL_TRAIT_DESCRIPTIONS[37], name = "Mastercraft", supported = false, manualActivation = true },
    [100] = { raceID = 100, desc = RACIAL_TRAIT_DESCRIPTIONS[100], name = "Arcane Affinity", supported = false, manualActivation = true },
}

racialTraits.RACE_IDS = RACE_IDS
racialTraits.RACE_NAMES = RACE_NAMES
racialTraits.RACIAL_TRAITS = RACIAL_TRAITS