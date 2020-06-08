local _, ns = ...

local constants = ns.constants
local traits = ns.resources.traits

local BUFF_TYPES = constants.BUFF_TYPES
local TURN_TYPES = constants.TURN_TYPES

traits.TRAIT_KEYS = {"OTHER", "BULWARK", "FOCUS", "SECOND_WIND", "VINDICATION"}

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
        icon = "Interface\\Icons\\spell_holy_greaterblessingofsanctuary",
        supported = true,
        numCharges = 2,
        buff = {
            types = { [BUFF_TYPES.STAT] = true, [BUFF_TYPES.ADVANTAGE] = true },
            turnTypeId = TURN_TYPES.ENEMY.id,
            stats = {
                defence = 3,
            },
            remainingTurns = 0,
        },
    },
    FOCUS = {
        id = "FOCUS",
        name = "Focus",
        desc = "Activate to gain advantage to all of your rolls during the current player turn. Can be activated twice per event. Activate and then roll.",
        icon = "Interface\\Icons\\spell_nature_focusedmind",
        supported = true,
        numCharges = 2,
        buff = {
            type = BUFF_TYPES.ADVANTAGE,
            turnTypeId = TURN_TYPES.PLAYER.id,
            remainingTurns = 0,
        },
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