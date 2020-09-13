local _, ns = ...

local constants = ns.constants
local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local BUFF_TYPES = constants.BUFF_TYPES
local TURN_TYPES = constants.TURN_TYPES

traits.TRAIT_KEYS = {"OTHER", "BULWARK", "CALAMITY_GAMBIT", "EMPOWERED_BLADES", "FOCUS", "LIFE_PULSE", "LIFE_WITHIN", "FAELUNES_REGROWTH", "SECOND_WIND", "SHATTER_SOUL", "VERSATILE", "VINDICATION"}

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
                actions = {
                    [ACTIONS.defend] = true,
                },
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
    EMPOWERED_BLADES = {
        id = "EMPOWERED_BLADES",
        name = "Empowered Blades",
        desc = "Activate after a successful Defence roll against a magical attack to make your next successful attack deal additional Chaos damage equal to half of the prevented damage rounded up. Can be used twice per event. Activate after rolling.",
        icon = "Interface\\Icons\\ability_demonhunter_chaosstrike",
        supported = true,
        numCharges = 2,
        buffs = {
            {
                type = BUFF_TYPES.DAMAGE_DONE,
                amount = "custom",
                remainingTurns = {
                    [TURN_TYPES.PLAYER.id] = 1,
                },
            },
        },
        isCustom = true,
        player = "KELANRA",
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
    LIFE_WITHIN = {
        id = "LIFE_WITHIN",
        name = "Life Within",
        desc = "Activate to increase your current and max HP by 10. Lasts until end of combat. Can be used once per event. Activate outside of rolling on either a player or enemy turn.",
        icon = "Interface\\Icons\\ability_druid_flourish",
        supported = true,
        numCharges = 1,
        buffs = {
            {
                type = BUFF_TYPES.MAX_HEALTH,
                amount = 10,
                expireOnCombatEnd = true,
            }
        }
    },
    SECOND_WIND = {
        id = "SECOND_WIND",
        name = "Second Wind",
        desc = "Activate outside of combat to regain 15HP. Can be used once, recharges after every combat. Activate without rolling.",
        supported = true,
        numCharges = 1,
    },
    SHATTER_SOUL = {
        id = "SHATTER_SOUL",
        name = "Shatter Soul",
        desc = "Activate after a successful attack to heal yourself for 6 HP. The target of your attack must not be mechanical. If the target is a demon, your Offence is also increased by +6 on the next player turn. Can be used thrice per event. Activate after rolling.",
        icon = "Interface\\Icons\\ability_demonhunter_shatteredsouls",
        supported = true,
        numCharges = 3,
        buffs = {
            {
                type = BUFF_TYPES.STAT,
                stats = {
                    offence = 6,
                },
                remainingTurns = {
                    [TURN_TYPES.PLAYER.id] = 1,
                },
            },
        },
        isCustom = true,
        player = "KELANRA",
    },
    FAELUNES_REGROWTH = {
        id = "FAELUNES_REGROWTH",
        name = "Faelune's Regrowth",
        desc = "Activate to have your Healing roll replicate half of its healing amount rounded up for the next enemy turn, and the following player turn in addition to the full healing on the current player turn. Can be used thrice per event. Activate after rolling.",
        icon = "Interface\\Icons\\ability_druid_nourish",
        supported = true,
        numCharges = 3,
        buffs = {
            {
                type = BUFF_TYPES.HEALING_OVER_TIME,
                remainingTurns = 2,
            },
        },
    },
    VERSATILE = {
        id = "VERSATILE",
        name = "Versatile",
        desc = "Activate to choose one stat, and transfer its value to another stat of your choice for the duration of your next roll. Can be used twice per event. Activate before rolling. Does not grant additional Greater Heal Slots. If you use Versatile to gain HP, and then have that amount or less HP left total by the end of your turn, you go down to 1 HP rather than 0 HP.",
        icon = "Interface\\Icons\\spell_arcane_arcanetactics",
        supported = true,
        note = "If you roll more than once during a turn, you must manually clear the Versatile buff after the first roll.",
        numCharges = 2,
        buffs = {
            {
                type = BUFF_TYPES.STAT,
                remainingTurns = 0,
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