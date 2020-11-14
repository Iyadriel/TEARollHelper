local _, ns = ...

local constants = ns.constants
local models = ns.models
local traits = ns.resources.traits

local BuffDuration = models.BuffDuration
local BuffEffectAdvantage = models.BuffEffectAdvantage
local BuffEffectMaxHealth = models.BuffEffectMaxHealth
local BuffEffectStat = models.BuffEffectStat

local ACTIONS = constants.ACTIONS
local STATS = constants.STATS
local TURN_TYPES = constants.TURN_TYPES

traits.TRAIT_KEYS = {"OTHER", "ARTISAN", "ASCEND", "BULWARK", "EMPOWERED_BLADES", "FAELUNES_REGROWTH", "FAULTLINE", "FOCUS", "GREATER_RESTORATION", "HOLY_BULWARK", "LIFE_PULSE", "LIFE_WITHIN", "PRESENCE_OF_VIRTUE", "REAP", "SECOND_WIND", "SHATTER_SOUL", "SHIELD_SLAM", "VERSATILE", "VESEERAS_IRE", "VINDICATION"}

local TRAITS = {
    OTHER = {
        id = "OTHER",
        name = "Other",
    },
    ARTISAN = {
        id = "ARTISAN",
        name = "Artisan",
        desc = "Activate to double the bonuses of your Utility traits for your next Utility roll. Activate before rolling.",
        icon = "Interface\\Icons\\trade_engraving",
        numCharges = 3,
    },
    ASCEND = {
        id = "ASCEND",
        name = "Ascend",
        desc = "Activate to replicate your buff roll and apply it to a secondary target. Activate after rolling.",
        numCharges = 2,
    },
    BULWARK = {
        id = "BULWARK",
        name = "Bulwark",
        desc = "Activate to gain +3 to defense as well as advantage on all defense rolls for the current or next enemy turn. Activate and then roll.",
        icon = "Interface\\Icons\\spell_holy_greaterblessingofsanctuary",
        numCharges = 2,
    },
    EMPOWERED_BLADES = {
        id = "EMPOWERED_BLADES",
        name = "Empowered Blades",
        desc = "Activate after a successful Defence roll against a magical attack to make your next successful attack deal additional Chaos damage equal to half of the prevented damage rounded up. Activate after rolling.",
        icon = "Interface\\Icons\\ability_demonhunter_chaosstrike",
        numCharges = 2,
        isCustom = true,
        player = "KELANRA",
    },
    FAELUNES_REGROWTH = {
        id = "FAELUNES_REGROWTH",
        name = "Faelune's Regrowth",
        desc = "Activate to have your Healing roll replicate half of its healing amount rounded up for the next enemy turn, and the following player turn in addition to the full healing on the current player turn. Activate after rolling.",
        icon = "Interface\\Icons\\ability_druid_nourish",
        numCharges = 3,
    },
    FAULTLINE = {
        id = "FAULTLINE",
        name = "Faultline",
        desc = "Activate to apply the result of an Offence attack roll onto a straight line outwards from yourself. All targets within line of sight along the line are struck. Activate after rolling.",
        numCharges = 2,
    },
    FOCUS = {
        id = "FOCUS",
        name = "Focus",
        desc = "Activate to gain advantage to all of your rolls during the current player turn. Activate and then roll.",
        icon = "Interface\\Icons\\spell_nature_focusedmind",
        numCharges = 2,
    },
    GREATER_RESTORATION = {
        id = "GREATER_RESTORATION",
        name = "Greater Restoration",
        desc = "Activate to remove a Critical Wound from yourself or another character without it costing any Greater Heal Slots. Activate outside of rolling.",
        numCharges = 2,
    },
    HOLY_BULWARK = {
        id = "HOLY_BULWARK",
        name = "Holy Bulwark",
        desc = "Activate on an enemy turn to block the damage incoming towards yourself or an ally from an enemy attack, then deal the blocked damage back to the attacker. Only works against enemies who are Undead, Demonic, Void, or Eldritch. Activate outside of rolling.",
        numCharges = 1,
    },
    LIFE_PULSE = {
        id = "LIFE_PULSE",
        name = "Life Pulse",
        desc = "Activate to apply the result of a Heal to the target and all friendly characters in melee range of that target. Activate after rolling.",
        numCharges = 2,
    },
    LIFE_WITHIN = {
        id = "LIFE_WITHIN",
        name = "Life Within",
        desc = "Activate to increase your current and max HP by 10. Lasts until end of combat. Activate outside of rolling on either a player or enemy turn.",
        icon = "Interface\\Icons\\ability_druid_flourish",
        numCharges = 1,
    },
    PRESENCE_OF_VIRTUE = {
        id = "PRESENCE_OF_VIRTUE",
        name = "Presence of Virtue",
        desc = "Activate after performing a successful Melee save on a friendly target, on activation you heal the target for 5 HP and buff them for +5 for their next player turn.",
        numCharges = 4,
    },
    REAP = {
        id = "REAP",
        name = "Reap",
        desc = "Activate to apply the result of an Offence roll to all enemies in melee range around you, or in melee range around your target. Activate after rolling.",
        numCharges = 1,
    },
    SECOND_WIND = {
        id = "SECOND_WIND",
        name = "Second Wind",
        desc = "Activate outside of combat to regain 15HP. Can be used once, recharges after every combat. Activate without rolling.",
        numCharges = 1,
    },
    SHATTER_SOUL = {
        id = "SHATTER_SOUL",
        name = "Shatter Soul",
        desc = "Activate after a successful attack to heal yourself for 6 HP. The target of your attack must not be mechanical. If the target is a demon, your Offence is also increased by +6 on the next player turn. Activate after rolling.",
        icon = "Interface\\Icons\\ability_demonhunter_shatteredsouls",
        numCharges = 3,
        isCustom = true,
        player = "KELANRA",
    },
    SHIELD_SLAM = {
        id = "SHIELD_SLAM",
        name = "Shield Slam",
        desc = "Activate on a player turn, instead of rolling for attack you deal your base damage plus your Defence as damage to an enemy of your choice. Activate outside of rolling.",
        numCharges = 3,
    },
    VERSATILE = {
        id = "VERSATILE",
        name = "Versatile",
        desc = "Activate to choose one stat, and transfer its value to another stat of your choice for the duration of your next roll. Activate before rolling. Does not grant additional Greater Heal Slots. If you use Versatile to gain HP, and then have that amount or less HP left total by the end of your turn, you go down to 1 HP rather than 0 HP.",
        icon = "Interface\\Icons\\spell_arcane_arcanetactics",
        numCharges = 3,
    },
    VESEERAS_IRE = {
        id = "VESEERAS_IRE",
        name = "Veseera's Ire",
        desc = "Activate to double your Offence stat for the current and the next player turn. However, your defence stat is reduced by an amount equal to your regular offense stat for the next two enemy turns. Activate and then roll.",
        icon = "Interface\\Icons\\spell_shadow_unstableaffliction_3",
        numCharges = 1,
    },
    VINDICATION = {
        id = "VINDICATION",
        name = "Vindication",
        desc = "Activate after a successful Offence attack roll in order to replicate half the damage done rounded up as healing. You can spread this healing as you wish among friendly targets.",
        numCharges = 2,
    },
}

local TRAIT_BUFF_SPECS = {
    [TRAITS.ARTISAN.id] = {
        {
            duration = BuffDuration:New({
                expireAfterActions = {
                    [ACTIONS.utility] = true,
                }
            }),
            -- effects provided in consequences.lua
        },
    },
    [TRAITS.BULWARK.id] = {
        {
            duration = BuffDuration:NewWithTurnType({
                turnTypeID = TURN_TYPES.ENEMY.id,
                remainingTurns = 0,
            }),
            effects = {
                BuffEffectAdvantage:New({
                    [ACTIONS.defend] = true,
                }),
                BuffEffectStat:New(STATS.defence, 3),
            },
        },
    },
    [TRAITS.EMPOWERED_BLADES.id] = {
        {
            duration = BuffDuration:New({
                expireAfterActions = {
                    [ACTIONS.attack] = true,
                }
            }),
            -- effects provided in consequences.lua
        },
    },
    [TRAITS.FAELUNES_REGROWTH.id] = {
        {
            duration = BuffDuration:New({
                remainingTurns = 2,
                expireOnCombatEnd = true,
            }),
            -- effects provided in consequences.lua
        },
    },
    [TRAITS.FOCUS.id] = {
        {
            duration = BuffDuration:NewWithTurnType({
                turnTypeID = TURN_TYPES.PLAYER.id,
                remainingTurns = 0,
            }),
            effects = {
                BuffEffectAdvantage:New(nil, TURN_TYPES.PLAYER.id),
            },
        }
    },
    [TRAITS.LIFE_WITHIN.id] = {
        {
            duration = BuffDuration:New({
                expireOnCombatEnd = true,
            }),
            effects = {
                BuffEffectMaxHealth:New(10)
            },
        },
    },
    [TRAITS.SHATTER_SOUL.id] = {
        {
            duration = BuffDuration:NewWithTurnType({
                turnTypeID = TURN_TYPES.PLAYER.id,
                remainingTurns = 1,
            }),
            effects = {
                BuffEffectStat:New(STATS.offence, 6)
            },
        },
    },
    [TRAITS.VERSATILE.id] = {
        {
            duration = BuffDuration:New({
                remainingTurns = 0,
                expireAfterAnyAction = true,
            }),
            -- effects provided in consequences.lua
        }
    },
    [TRAITS.VESEERAS_IRE.id] = {
        {
            duration = BuffDuration:NewWithTurnType({
                turnTypeID = TURN_TYPES.PLAYER.id,
                remainingTurns = 1,
            }),
            -- effects provided in consequences.lua
        },
        {
            duration = BuffDuration:NewWithTurnType({
                turnTypeID = TURN_TYPES.ENEMY.id,
                remainingTurns = 2,
            }),
            -- effects provided in consequences.lua
        },
    },
}

traits.TRAITS = TRAITS
traits.TRAIT_BUFF_SPECS = TRAIT_BUFF_SPECS