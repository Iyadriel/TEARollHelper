local _, ns = ...

local constants = ns.constants
local feats = ns.resources.feats
local models = ns.models

local BuffDuration = models.BuffDuration
local BuffEffectAdvantage = models.BuffEffectAdvantage
local BuffEffectDamageTaken = models.BuffEffectDamageTaken
local BuffEffectDisadvantage = models.BuffEffectDisadvantage
local BuffEffectStat = models.BuffEffectStat

local ACTIONS = constants.ACTIONS
local DAMAGE_TYPES = constants.DAMAGE_TYPES
local STATS = constants.STATS
local TURN_TYPES = constants.TURN_TYPES

feats.FEAT_KEYS = {"FEATLESS", "ADRENALINE", "BLOOD_HARVEST", "CHAPLAIN_OF_VIOLENCE", "COUNTER_FORCE", "DIVINE_PURPOSE", "ETERNAL_SACRIFICE", "EXPANSIVE_ARSENAL", "FOCUS", "INSPIRING_PRESENCE", "KEEN_SENSE", "LEADER", "LIVING_BARRICADE", "MEDIC", "MENDER", "MERCY_FROM_PAIN", "MONSTER_HUNTER", "ONSLAUGHT", "PARAGON", "PENANCE", "PHALANX", "PROFESSIONAL", "REAPER", "SHEPHERD_OF_THE_WICKED", "TRAUMA_RESPONSE", "VENGEANCE", "WARDER"}

local FEATS = {
    FEATLESS = {
        id = "FEATLESS",
        name = "Featless / other"
    },
    ADRENALINE = {
        id = "ADRENALINE",
        name = "Adrenaline",
        desc = "Beating the threshold by 8 or more with an Offence attack roll lets you perform a second attack against the same target. Cannot trigger more than once per player turn.",
    },
    BLOOD_HARVEST = {
        id = "BLOOD_HARVEST",
        name = "Blood Harvest",
        desc = "For every 2 points you put into the Offence stat you gain a Harvest Slot. You can activate these Harvest Slots to spend them just like a Greater Heal Slot. Spending a Harvest slot increases the damage of your next Offence attack by +3. This damage is dealt even if you miss.",
    },
    CHAPLAIN_OF_VIOLENCE = {
        id = "CHAPLAIN_OF_VIOLENCE",
        name = "Chaplain of Violence",
        desc = "Healing a single friendly target for 3HP or more increases the damage of your next successful Offence Attack roll by +2. Using a Greater Heal slot increases the damage to +4. This bonus does not stack and is consumed on your next successful Offence Attack roll. Requires 4/6 Spirit in order to pick.",
        icon = "Interface\\Icons\\spell_holy_holyguidance",
    },
    COUNTER_FORCE = {
        id = "COUNTER_FORCE",
        name = "Counter-Force",
        desc = "Your melee save rolls only benefit from half of your Defence stat (rounded up), but if you manage the roll you deal damage back to the attacker by an amount equal to your Defence stat.",
    },
    DIVINE_PURPOSE = {
        id = "DIVINE_PURPOSE",
        name = "Divine Purpose",
        desc = "Vindication has 2 extra charges, but you can no longer perform Heal rolls while in combat.",
        isCustom = true,
        player = "IYADRIEL",
    },
    ETERNAL_SACRIFICE = {
        id = "ETERNAL_SACRIFICE",
        name = "Eternal Sacrifice",
        desc = "Your Offence rolls have advantage.|nYour Defence is increased by +4 against magical attacks.|nYou unlock the following traits: Empowered Blades, Shatter Soul.|nYou gain the following weaknesses: Corrupted, Fateless, Old Scars, Outcast.",
        passives = {
            resistance = {
                [DAMAGE_TYPES.MAGICAL] = 4,
                [DAMAGE_TYPES.MIXED] = 2,
            }
        },
        isCustom = true,
        player = "KELANRA",
    },
    EXPANSIVE_ARSENAL = {
        id = "EXPANSIVE_ARSENAL",
        name = "Expansive Arsenal",
        desc = "You may pick an additional Trait.",
    },
    FOCUS = {
        id = "FOCUS",
        name = "Focus",
        desc = "On player turn you can choose to roll with advantage, but when doing so you have disadvantage on the following enemy turn. Choose before rolling whether or not to apply the advantage.",
        icon = "Interface\\Icons\\spell_nature_focusedmind",
    },
--[[     FOREIGN_DISCIPLE = {
        id = "FOREIGN_DISCIPLE",
        name = "Foreign Disciple",
        desc = "You can now pick a second racial trait in addition to your first. Cannot be picked with Outcast.",
        supported = false
    }, ]]
    INSPIRING_PRESENCE = {
        id = "INSPIRING_PRESENCE",
        name = "Inspiring Presence",
        desc = "You now buff someone for both their current player turn and the next enemy turn, but you only apply half of your spirit stat to the roll, rounded up.",
    },
    KEEN_SENSE = {
        id = "KEEN_SENSE",
        name = "Keen sense",
        desc = "The threshold for getting a critical roll is reduced to 19 from 20.",
    },
    LEADER = {
        id = "LEADER",
        name = "Leader",
        desc = "You can now buff with the Offence stat instead of the Spirit stat.",
        note = "The addon will automatically use the highest stat.",
    },
    LIVING_BARRICADE = {
        id = "LIVING_BARRICADE",
        name = "Living Barricade",
        desc = "When tasked with doing multiple defense rolls in the same enemy turn (saves not included) you take 3 less damage from all sources for the duration of the enemy turn.",
        note = "Activate manually from the Defend action tab.",
        icon = "Interface\\Icons\\ability_warrior_shieldwall",
    },
    MEDIC = {
        id = "MEDIC",
        name = "Medic",
        desc = "Your out of combat basic healing is doubled, and the amount of heals you can do out of combat is increased by 2.",
    },
    MENDER = {
        id = "MENDER",
        name = "Mender",
        desc = "Gain 2 additional Greater Heal Slots.",
    },
    MERCY_FROM_PAIN = {
        id = "MERCY_FROM_PAIN",
        name = "Mercy from Pain",
        desc = "Every time you deal 5 damage or more to a single enemy, your next healing roll is boosted by +2 HP, if you deal 5 damage or more to multiple enemies at once, your next healing roll is instead boosted by +4HP (does not stack). The bonus to healing lasts until the end of combat, but does not stack with itself and is consumed on your next heal roll.",
        icon = "Interface\\Icons\\ability_priest_atonement",
    },
    MONSTER_HUNTER = {
        id = "MONSTER_HUNTER",
        name = "Monster Hunter",
        desc = "You have advantage on offense attack rolls against creatures of the following types - Undead, Demon, Void, Eldritch.",
        passives = {
            advantageAgainstEnemies = {
                DEMON = true,
                ELDRITCH = true,
                UNDEAD = true,
                VOID = true,
            },
        },
    },
    ONSLAUGHT = {
        id = "ONSLAUGHT",
        name = "Onslaught",
        desc = "When rolling an Offence Attack roll against a target and failing to meet the threshold to hit, you still deal your base damage to the target.",
    },
    PARAGON = {
        id = "PARAGON",
        name = "Paragon",
        desc = "You no longer gain Greater Heal Slots. Every 3 Spirit lets you apply your basic heal in full to an additional target. Not increased by buffs, but is increased by spending Excess. You can no longer divide your healing done.",
    },
    PENANCE = {
        id = "PENANCE",
        name = "Penance",
        desc = "You can now perform Attack rolls with your Spirit stat. When using a Greater Heal Slot you can also heal someone for the Heal Slot amount while using your Spirit to deal damage to an enemy. You can still choose to heal, buff, and ranged save with your Spirit Stat.",
    },
    PHALANX = {
        id = "PHALANX",
        name = "Phalanx",
        desc = "You now have advantage on Melee save rolls.",
    },
    PROFESSIONAL = {
        id = "PROFESSIONAL",
        name = "Professional",
        desc = "You may pick 2 additional Utility Traits. Furthermore your Utility Traits now grant you a bonus of +8 rather than +5.",
    },
    REAPER = {
        id = "REAPER",
        name = "Reaper",
        desc = "When scoring a nat 20 on an Offence attack roll, you no longer deal double damage, but instead activate the Reap trait without cost. You do not have to have Reap as a chosen trait.",
    },
    SHEPHERD_OF_THE_WICKED = {
        id = "SHEPHERD_OF_THE_WICKED",
        name = "Shepherd of the Wicked",
        desc = "You can now roll CC rolls with your Defence stat instead of your Offence stat.",
        note = "The addon will automatically use the highest stat.",
    },
    TRAUMA_RESPONSE = {
        id = "TRAUMA_RESPONSE",
        name = "Trauma Response",
        desc = "Your cost for removing a Critical Wound from yourself or another character is now 1 Greater Heal Slot.",
    },
    VENGEANCE = {
        id = "VENGEANCE",
        name = "Vengeance",
        desc = "When the raw result of your Offence attack roll is 16 or higher, you gain an additional +4 to Offence for your next player round.",
        icon = "Interface\\Icons\\ability_racial_spatialrift",
        isCustom = true,
        player = "CALLEAN",
    },
    WARDER = {
        id = "WARDER",
        name = "Warder",
        desc = "You now have advantage on Ranged save rolls.",
    },
}

local FEAT_BUFF_SPECS = {
    [FEATS.CHAPLAIN_OF_VIOLENCE.id] = {
        duration = BuffDuration:New({
            expireAfterActions = {
                [ACTIONS.attack] = true,
            },
            expireOnCombatEnd = true,
        }),
        -- effects provided in consequences.lua
    },
    [FEATS.FOCUS.id] = {
        duration = BuffDuration:New({
            remainingTurns = 1,
        }),
        effects = {
            BuffEffectAdvantage:New(nil, TURN_TYPES.PLAYER.id),
            BuffEffectDisadvantage:New(nil, TURN_TYPES.ENEMY.id),
        },
    },
    [FEATS.LIVING_BARRICADE.id] = {
        duration = BuffDuration:NewWithTurnType({
            turnTypeID = TURN_TYPES.ENEMY.id,
            remainingTurns = 0,
        }),
        effects = {
            BuffEffectDamageTaken:New(-3),
        },
    },
    [FEATS.MERCY_FROM_PAIN.id] = {
        duration = BuffDuration:New({
            expireAfterActions = {
                [ACTIONS.healing] = true,
            },
            expireOnCombatEnd = true,
        }),
        -- effects provided in consequences.lua
    },
    [FEATS.VENGEANCE.id] = {
        duration = BuffDuration:NewWithTurnType({
            turnTypeID = TURN_TYPES.PLAYER.id,
            remainingTurns = 1,
        }),
        effects = {
            BuffEffectStat:New(STATS.offence, 4),
        },
    },
}

feats.FEATS = FEATS
feats.FEAT_BUFF_SPECS = FEAT_BUFF_SPECS