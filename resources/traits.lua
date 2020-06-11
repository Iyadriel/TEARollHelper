local _, ns = ...

local constants = ns.constants
local traits = ns.resources.traits

local BUFF_TYPES = constants.BUFF_TYPES
local TURN_TYPES = constants.TURN_TYPES

traits.TRAIT_KEYS = {"OTHER", "BULWARK", "CALAMITY_GAMBIT", "FOCUS", "LIFE_PULSE", "NOURISH", "SECOND_WIND", "VINDICATION"}

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
        buffs = {
            {
                types = { [BUFF_TYPES.STAT] = true, [BUFF_TYPES.ADVANTAGE] = true },
                turnTypeId = TURN_TYPES.ENEMY.id,
                stats = {
                    defence = 3,
                },
                remainingTurns = {
                    [TURN_TYPES.ENEMY.id] = 0,
                },
            },
        },
    },
    CALAMITY_GAMBIT = {
        id = "CALAMITY_GAMBIT",
        name = "Calamity Gambit",
        desc = "Activate to double your Offence stat for the current and the next player turn. However, your defence stat is reduced by an amount equal to your regular offense stat for the next two enemy turns. Can be used once per event. Activate and then roll.",
        icon = "Interface\\Icons\\spell_shadow_unstableaffliction_3",
        supported = true,
        numCharges = 1,
        buffs = {
            {
                type = BUFF_TYPES.STAT,
                stats = {
                    offence = "custom"
                },
                remainingTurns = {
                    [TURN_TYPES.PLAYER.id] = 1,
                },
            },
            {
                type = BUFF_TYPES.STAT,
                stats = {
                    defence = "custom"
                },
                remainingTurns = {
                    [TURN_TYPES.ENEMY.id] = 2,
                },
            }
        },
    },
    FOCUS = {
        id = "FOCUS",
        name = "Focus",
        desc = "Activate to gain advantage to all of your rolls during the current player turn. Can be activated twice per event. Activate and then roll.",
        icon = "Interface\\Icons\\spell_nature_focusedmind",
        supported = true,
        numCharges = 2,
        buffs = {
            {
                type = BUFF_TYPES.ADVANTAGE,
                turnTypeId = TURN_TYPES.PLAYER.id,
                remainingTurns = {
                    [TURN_TYPES.PLAYER.id] = 0,
                },
            },
        },
    },
    LIFE_PULSE = {
        id = "LIFE_PULSE",
        name = "Life Pulse",
        desc = "Activate to apply the result of a Heal to the target and all friendly characters in melee range of that target. Can be used once per event. Activate after rolling.",
        supported = true,
        numCharges = 1,
    },
    SECOND_WIND = {
        id = "SECOND_WIND",
        name = "Second Wind",
        desc = "Activate outside of combat to regain 15HP. Can be used once, recharges after every combat. Activate without rolling.",
        supported = true,
        numCharges = 1,
    },
    NOURISH = {
        id = "NOURISH",
        name = "Nourish",
        desc = "Activate to have your Healing roll heal half of its total result rounded up every player turn for the duration of four player turns. Can be used thrice per event. Activate after rolling.",
        icon = "Interface\\Icons\\ability_druid_nourish",
        supported = true,
        numCharges = 3,
        buffs = {
            {
                type = BUFF_TYPES.HEALING_OVER_TIME,
                remainingTurns = {
                    [TURN_TYPES.PLAYER.id] = 4,
                },
            },
        },
    },
    VINDICATION = {
        id = "VINDICATION",
        name = "Vindication",
        desc = "Activate after a successful Offence attack roll in order to replicate half the damage done rounded up as healing. You can spread this healing as you wish among friendly targets. Can be used twice per event.",
        supported = true,
        numCharges = 2,
    },
}