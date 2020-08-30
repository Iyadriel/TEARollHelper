local _, ns = ...

local constants = ns.constants
local feats = ns.resources.feats

local BUFF_TYPES = constants.BUFF_TYPES
local DAMAGE_TYPES = constants.DAMAGE_TYPES
local TURN_TYPES = constants.TURN_TYPES

feats.FEAT_KEYS = {"FEATLESS", "ADRENALINE", "BLOOD_HARVEST", "COUNTER_FORCE", "ETERNAL_SACRIFICE", "EXPANSIVE_ARSENAL", "FOREIGN_DISCIPLE", "INSPIRING_PRESENCE", "KEEN_SENSE", "LEADER", "MEDIC", "MENDER", "MERCY_FROM_PAIN", "MONSTER_HUNTER", "ONSLAUGHT", "PARAGON", "PHALANX", "PROFESSIONAL", "REAPER", "SHEPHERD_OF_THE_WICKED", "WARDER"}

feats.FEATS = {
    FEATLESS = {
        id = "FEATLESS",
        name = "Featless / other"
    },
    ADRENALINE = {
        id = "ADRENALINE",
        name = "Adrenaline",
        desc = "Beating the threshold by 6 or more with an Offence attack roll lets you perform a second attack against the same target. Cannot trigger more than once per player turn.",
        supported = true
    },
    BLOOD_HARVEST = {
        id = "BLOOD_HARVEST",
        name = "Blood Harvest",
        desc = "For every 2 points you put into the Offence stat you gain a Harvest Slot. You can activate these Harvest Slots to spend them just like a Greater Heal Slot. Spending a Harvest slot increases the damage of your next Offence attack by +3. This damage is dealt even if you miss.",
        supported = true
    },
    COUNTER_FORCE = {
        id = "COUNTER_FORCE",
        name = "Counter-Force",
        desc = "Your melee save rolls no longer benefit from your Defence stat, but if you manage the roll you deal damage back to the attacker by an amount equal to your Defence stat.",
        supported = true
    },
    ETERNAL_SACRIFICE = {
        id = "ETERNAL_SACRIFICE",
        name = "Eternal Sacrifice",
        desc = "Your Offence rolls have advantage.|nYour Defence is increased by +4 against magical attacks.|nYou unlock the following traits: Empowered Blades, Shatter Soul.|nYou gain the following weaknesses: Corrupted, Fateless, Old Scars, Outcast.",
        passives = {
            resistance = {
                [DAMAGE_TYPES.MAGICAL] = 4,
            }
        },
        supported = true,
        isCustom = true,
        player = "KELANRA",
    },
    EXPANSIVE_ARSENAL = {
        id = "EXPANSIVE_ARSENAL",
        name = "Expansive Arsenal",
        desc = "If you pick a second Weakness, you may pick a third Trait.",
        supported = true
    },
    FOREIGN_DISCIPLE = {
        id = "FOREIGN_DISCIPLE",
        name = "Foreign Disciple",
        desc = "You can change your Racial Trait to that of another race.",
        supported = true
    },
    INSPIRING_PRESENCE = {
        id = "INSPIRING_PRESENCE",
        name = "Inspiring Presence",
        desc = "You now buff someone for both their current player turn and the next enemy turn, but you only apply half of your spirit stat to the roll, rounded up.",
        supported = true
    },
    KEEN_SENSE = {
        id = "KEEN_SENSE",
        name = "Keen sense",
        desc = "The threshold for getting a critical roll is reduced to 19 from 20.",
        supported = true
    },
    LEADER = {
        id = "LEADER",
        name = "Leader",
        desc = "You can now buff with the Offence stat instead of the Spirit stat.",
        note = "The addon will automatically use the highest stat.",
        supported = true
    },
    MEDIC = {
        id = "MEDIC",
        name = "Medic",
        desc = "Your out of combat basic healing is doubled, and the amount of heals you can do out of combat is increased by 2.",
        supported = true
    },
    MENDER = {
        id = "MENDER",
        name = "Mender",
        desc = "Gain 2 additional Greater Heal Slots.",
        supported = true
    },
    MERCY_FROM_PAIN = {
        id = "MERCY_FROM_PAIN",
        name = "Mercy from Pain",
        desc = "Every time you deal 5 damage or more to a single enemy, your next healing roll is boosted by +2 HP, if you deal 5 damage or more to multiple enemies at once, your next healing roll is instead boosted by +4HP (does not stack). If you do not use this bonus on your next player turn, it fades.",
        icon = "Interface\\Icons\\spell_holy_holyguidance",
        supported = true,
        buff = {
            type = BUFF_TYPES.HEALING_DONE,
            remainingTurns = {
                [TURN_TYPES.PLAYER.id] = 1,
            },
        },
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
        supported = true
    },
    ONSLAUGHT = {
        id = "ONSLAUGHT",
        name = "Onslaught",
        desc = "When hitting with an Offence attack roll you always deal your base damage plus half of your Offence stat rounded up, regardless of how much you beat the threshold by.",
        supported = true
    },
    PARAGON = {
        id = "PARAGON",
        name = "Paragon",
        desc = "You no longer gain Greater Heal Slots. Every 3 Spirit lets you apply your basic heal in full to an additional target. Not increased by buffs, but is increased by spending Excess. You can no longer divide your healing done.",
        supported = true
    },
    PHALANX = {
        id = "PHALANX",
        name = "Phalanx",
        desc = "You now have advantage on Melee save rolls.",
        supported = true
    },
    PROFESSIONAL = {
        id = "PROFESSIONAL",
        name = "Professional",
        desc = "You may pick 2 additional Utility Traits. Furthermore your Utility Traits now grant you a bonus of +8 rather than +5.",
        supported = true
    },
    REAPER = {
        id = "REAPER",
        name = "Reaper",
        desc = "When scoring a nat 20 on an Offence attack roll, you no longer deal double damage, but instead activate the Reap trait without cost. You do not have to have Reap as a chosen trait.",
        supported = true
    },
    SHEPHERD_OF_THE_WICKED = {
        id = "SHEPHERD_OF_THE_WICKED",
        name = "Shepherd of the Wicked",
        desc = "You can now roll CC rolls with your Defence stat instead of your Offence stat.",
        note = "The addon will automatically use the highest stat.",
        supported = true
    },
    WARDER = {
        id = "WARDER",
        name = "Warder",
        desc = "You now have advantage on Ranged save rolls.",
        supported = true
    },
}