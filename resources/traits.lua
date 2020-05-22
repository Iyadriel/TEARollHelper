local _, ns = ...

local traits = ns.resources.traits
traits.TRAIT_KEYS = {"OTHER", "SECOND_WIND", "VINDICATION"}

traits.TRAITS = {
    OTHER = {
        id = "OTHER",
        name = "Other",
        supported = true
    },
    SECOND_WIND = {
        id = "SECOND_WIND",
        name = "Second Wind",
        desc = "Activate outside of combat to regain 15HP. Can be used once, recharges after every combat. Activate without rolling.",
        supported = true
    },
    VINDICATION = {
        id = "VINDICATION",
        name = "Vindication",
        desc = "Activate after a successful Offence attack roll in order to replicate half the damage done rounded up as healing. You can spread this healing as you wish among friendly targets. Can be used twice per event.",
        supported = true
    },
}