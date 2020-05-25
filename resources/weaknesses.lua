local _, ns = ...

local weaknesses = ns.resources.weaknesses
weaknesses.WEAKNESS_KEYS = {"BRUTE", "FATELESS"}

weaknesses.WEAKNESSES = {
    BRUTE = {
        id = "BRUTE",
        name = "Brute",
        desc = "You can no longer heal, buff, or pick any Utility traits.",
        supported = true,
    },
    FATELESS = {
        id = "FATELESS",
        name = "Fateless",
        desc = "You no longer have access to your Fate Point.",
        supported = true,
    },
}