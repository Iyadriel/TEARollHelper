local _, ns = ...

local weaknesses = ns.resources.weaknesses
weaknesses.WEAKNESS_KEYS = {"CORRUPTED", "FATELESS", "FRAGILE", "OUTCAST"}

weaknesses.WEAKNESSES = {
--[[     BRUTE = {
        id = "BRUTE",
        name = "Brute",
        desc = "You can no longer heal, buff, or pick any Utility traits.",
        supported = true,
    }, ]]
--[[     CORRUPTED = {
        id = "CORRUPTED",
        name = "Corrupted",
        desc = "All healing received from other players and NPCs are cut in half, rounded down. Furthermore you must choose one of the following types of healing: Holy, Unholy, Life. Whenever you are healed by the chosen type, your max HP is reduced by 3. Your HP returns to normal after combat ends, but you are not healed for the missing HP. If healed by your chosen type outside of combat your HP returns to normal after the next combat section ends.",
        supported = true,
    }, ]]
    FATELESS = {
        id = "FATELESS",
        name = "Fateless",
        desc = "You no longer have access to your Fate Point.",
        supported = true,
    },
    FRAGILE = {
        id = "FRAGILE",
        name = "Fragile",
        desc = "Reduce your max HP by 8.",
        supported = true,
    },
    OUTCAST = {
        id = "OUTCAST",
        name = "Outcast",
        desc = "You no longer benefit from your Racial Trait.",
        supported = true,
    },
}