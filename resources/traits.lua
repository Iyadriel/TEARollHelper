local _, ns = ...

local constants = ns.constants
local models = ns.models
local traits = ns.resources.traits

local BuffDuration = models.BuffDuration
local BuffEffectAdvantage = models.BuffEffectAdvantage
local BuffEffectMaxHealth = models.BuffEffectMaxHealth
local BuffEffectStat = models.BuffEffectStat

local ApexProtector = models.ApexProtector:New()
local Artisan = models.Artisan:New()
local Chastice = models.Chastice:New()
local CriticalMass = models.CriticalMass:New()

local ACTIONS = constants.ACTIONS
local STATS = constants.STATS
local TURN_TYPES = constants.TURN_TYPES

traits.TRAIT_KEYS = {"OTHER", ApexProtector.id, Artisan.id, "ASCEND", "ANQULANS_REDOUBT", Chastice.id, CriticalMass.id, "FAELUNES_REGROWTH", "FAULTLINE", "GREATER_RESTORATION", "HOLY_BULWARK", "LIFE_PULSE", "LIFE_WITHIN", "MOMENT_OF_EXCELLENCE", "PRESENCE_OF_VIRTUE", "REAP", "SECOND_WIND", "SHATTER_SOUL", "SHIELD_SLAM", "SILAMELS_ACE", "VERSATILE", "VESEERAS_IRE", "VINDICATION"}

local TRAITS = {
    OTHER = {
        id = "OTHER",
        name = "Other",
    },
    [ApexProtector.id] = ApexProtector,
    [Artisan.id] = Artisan,
    ASCEND = {
        id = "ASCEND",
        name = "Ascend",
        desc = "Activate to replicate your buff roll and apply it to a secondary target. Activate after rolling.",
        numCharges = 2,
    },
    ANQULANS_REDOUBT = {
        id = "ANQULANS_REDOUBT",
        name = "Anqulan's Redoubt",
        desc = "Activate to gain +3 to defense as well as advantage on all defense rolls for the current or next enemy turn. Activate and then roll.",
        icon = "Interface\\Icons\\spell_holy_greaterblessingofsanctuary",
        numCharges = 2,
    },
    [Chastice.id] = Chastice,
    [CriticalMass.id] = CriticalMass,
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
        desc = "Activate to deal your full damage to up to 2 additional targets. Activate after rolling.",
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
    MOMENT_OF_EXCELLENCE = {
        id = "MOMENT_OF_EXCELLENCE",
        name = "Moment of Excellence",
        desc = "Instead of rolling, you can activate this trait to gain the nat20 critical result of an Offense, Defense, Stamina, Spirit, or Utility roll. Activate outside of rolling.",
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
        numCharges = 2,
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
    SILAMELS_ACE = {
        id = "SILAMELS_ACE",
        name = "Silamel's Ace",
        desc = "Activate to have one of your Utility Trait bonuses apply to your next Offence, Defence or Spirit roll. Your emote must adhere to the theme of the chosen utility Trait, and the trait itself must be at least somewhat applicable. Activate and then roll.",
        icon = "Interface\\Icons\\inv_glowingazeritespire",
        numCharges = 2,
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
        desc = "Activate to set the threshold to hit on all enemies to 10+ (Only applies to you, does not affect enemies with a threshold already lower than 10+), and double the damage bonus of your Offence Mastery, for the current and next player turn. However, your defence stat is reduced by half of your base Offence rounded up for the duration. Activate and then roll.",
        icon = "Interface\\Icons\\spell_shadow_unstableaffliction_3",
        numCharges = 1,
        requiredStats = {
            {
                [STATS.offence] = 4,
            },
        },
    },
    VINDICATION = {
        id = "VINDICATION",
        name = "Vindication",
        desc = "Activate after a successful Offence attack roll in order to replicate half the damage done rounded up as healing. You can spread this healing as you wish among friendly targets.",
        numCharges = 2,
    },
}

local TRAIT_BUFF_SPECS = {
    [TRAITS.ANQULANS_REDOUBT.id] = {
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
    [TRAITS.FAELUNES_REGROWTH.id] = {
        {
            duration = BuffDuration:New({
                remainingTurns = 2,
                expireOnCombatEnd = true,
            }),
            -- effects provided in consequences.lua
        },
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
    [TRAITS.SILAMELS_ACE.id] = {
        {
            duration = BuffDuration:New({
                expireAfterAnyAction = true,
            }),
            -- effects provided in consequences.lua
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