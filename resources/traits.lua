local _, ns = ...

local traits = ns.resources.traits
traits.TRAIT_KEYS = {"OTHER", "BULWARK", "SECOND_WIND", "VINDICATION"}

traits.TRAITS = {
    OTHER = {
        id = "OTHER",
        name = "Other",
        supported = true
    },
    BULWARK = {
        id = "BULWARK",
        name = "Bulwark",
        desc = "Activate to gain +3 to defense as well as advantage on all defense rolls for the current or next enemy turn. Can be used twice per event. Activate and then roll.",
        supported = true,
        numCharges = 2,
    },
    SECOND_WIND = {
        id = "SECOND_WIND",
        name = "Second Wind",
        desc = "Activate outside of combat to regain 15HP. Can be used once, recharges after every combat. Activate without rolling.",
        supported = true,
        numCharges = 1,
    },
    VINDICATION = {
        id = "VINDICATION",
        name = "Vindication",
        desc = "Activate after a successful Offence attack roll in order to replicate half the damage done rounded up as healing. You can spread this healing as you wish among friendly targets. Can be used twice per event.",
        supported = true,
        numCharges = 2,
    },
}