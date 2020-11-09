local _, ns = ...

local constants = ns.constants
local models = ns.models
local weaknesses = ns.resources.weaknesses

local BuffDuration = models.BuffDuration
local BuffEffectDisadvantage = models.BuffEffectDisadvantage
local BuffEffectMaxHealth = models.BuffEffectMaxHealth
local BuffEffectStat = models.BuffEffectStat

local STATS = constants.STATS
local TURN_TYPES = constants.TURN_TYPES

weaknesses.WEAKNESS_KEYS = {"BRUTE", "CORRUPTED", "FATELESS", "FEATLESS", "FRAGILE", "GLASS_CANNON", "OUTCAST", "OVERFLOW", "REBOUND", "TEMPERED_BENEVOLENCE", "TEMPO", "TIMID", "WOE_UPON_THE_AFFLICTED"}

local WEAKNESSES = {
    BRUTE = {
        id = "BRUTE",
        name = "Brute",
        desc = "You can no longer heal, buff, or pick any Utility traits.",
        supported = true,
    },
    CORRUPTED = {
        id = "CORRUPTED",
        name = "Corrupted",
        desc = "All healing received from other players and NPCs is cut in half, rounded down. Furthermore you must choose one of the following types of healing: Holy, Unholy, Life. Whenever you are healed by the chosen type, your max HP is reduced by 3. Your HP returns to normal after combat ends, but you are not healed for the missing HP. If healed by your chosen type outside of combat your HP returns to normal after the next combat section ends.",
        icon = "Interface\\Icons\\spell_deathknight_bloodplague",
        supported = true,
    },
    FATELESS = {
        id = "FATELESS",
        name = "Fateless",
        desc = "You no longer have access to your Fate Point.",
        supported = true,
    },
    FEATLESS = {
        id = "FEATLESS",
        name = "Featless",
        desc = "You may no longer pick a Feat.",
        supported = true,
    },
    FRAGILE = {
        id = "FRAGILE",
        name = "Fragile",
        desc = "Reduce your max HP by 8.",
        supported = true,
    },
    GLASS_CANNON = {
        id = "GLASS_CANNON",
        name = "Glass Cannon",
        desc = "You take 4 additional damage from all sources, but you also gain +2 dmg.",
        supported = true,
        isCustom = true,
        player = "CALLEAN",
    },
    OUTCAST = {
        id = "OUTCAST",
        name = "Outcast",
        desc = "You no longer benefit from your Racial Trait.",
        supported = true,
    },
    OVERFLOW = {
        id = "OVERFLOW",
        name = "Overflow",
        desc = "You no longer benefit from the Excess mechanic. Requires at least 4 out  of 6 points in the Spirit stat in order to pick.",
        supported = true,
    },
    REBOUND = {
        id = "REBOUND",
        name = "Rebound",
        desc = "When rolling a nat 1 on any player turn roll, you take damage equal to your Offense or Spirit stat, whichever is highest, and you have disadvantage during the next enemy turn. Requires at least 4 out of 6 points in either Offense or Spirit to pick.",
        icon = "Interface\\Icons\\ability_hunter_hatchettoss",
        supported = true,
    },
    TEMPO = {
        id = "TEMPO",
        name = "Tempo",
        desc = "If you take damage during an enemy turn, you have disadvantage on your next player turn.",
        icon = "Interface\\Icons\\ability_mage_timewarp",
        supported = true,
    },
    TEMPERED_BENEVOLENCE = {
        id = "TEMPERED_BENEVOLENCE",
        name = "Tempered Benevolence",
        desc = "You gain a Greater Heal slot for every 3 Spirit, rather than every 2 Spirit, and do not gain Greater Heal slots from the +6 Spirit bonus. Requires at least 4/6 in Spirit in order to pick. Can not be picked together with Paragon.",
        supported = true,
    },
    TIMID = {
        id = "TIMID",
        name = "Timid",
        desc = "While in melee range of an enemy, your Offence, Defense, and Spirit stats are reduced by -2.",
        icon = "Interface\\Icons\\spell_misc_emotionafraid",
        supported = true,
        distanceFromEnemy = "melee",
    },
    WOE_UPON_THE_AFFLICTED = {
        id = "WOE_UPON_THE_AFFLICTED",
        name = "Woe Upon The Afflicted",
        desc = "You take 4 additional damage from creatures and magical sources of the following types - undead, demon, void, eldritch.",
        weakAgainstEnemies = {
            DEMON = true,
            ELDRITCH = true,
            UNDEAD = true,
            VOID = true,
        },
        supported = true,
    },
}

local WEAKNESS_BUFF_SPECS = {
    [WEAKNESSES.CORRUPTED.id] = {
        effects = {
            BuffEffectMaxHealth:New(-3)
        },
        canCancel = true,
    },
    [WEAKNESSES.REBOUND.id] = {
        duration = BuffDuration:NewWithTurnType({
            turnTypeID = TURN_TYPES.ENEMY.id,
            remainingTurns = 1,
        }),
        effects = {
            BuffEffectDisadvantage:New(nil, TURN_TYPES.ENEMY.id)
        },
        canCancel = true,
    },
    [WEAKNESSES.TEMPO.id] = {
        duration = BuffDuration:NewWithTurnType({
            turnTypeID = TURN_TYPES.PLAYER.id,
            remainingTurns = 1,
        }),
        effects = {
            BuffEffectDisadvantage:New(nil, TURN_TYPES.PLAYER.id)
        },
        canCancel = true,
    },
    [WEAKNESSES.TIMID.id] = {
        effects = {
            BuffEffectStat:New(STATS.offence, -2),
            BuffEffectStat:New(STATS.defence, -2),
            BuffEffectStat:New(STATS.spirit, -2),
        },
        canCancel = false,
    },
}

weaknesses.WEAKNESSES = WEAKNESSES
weaknesses.WEAKNESS_BUFF_SPECS = WEAKNESS_BUFF_SPECS