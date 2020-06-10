local _, ns = ...

local constants = ns.constants
local weaknesses = ns.resources.weaknesses

local BUFF_TYPES = constants.BUFF_TYPES
local TURN_TYPES = constants.TURN_TYPES

weaknesses.WEAKNESS_KEYS = {"CORRUPTED", "FATELESS", "FRAGILE", "OUTCAST", "REBOUND", "TEMPO", "TIMID"}

weaknesses.WEAKNESSES = {
--[[     BRUTE = {
        id = "BRUTE",
        name = "Brute",
        desc = "You can no longer heal, buff, or pick any Utility traits.",
        supported = true,
    }, ]]
--[[     CORRUPTED = {
        id = "CORRUPTED",
        name = "Corrupted",
        desc = "All healing received from other players and NPCs are cut in half, rounded down. Furthermore you must choose one of the following types of healing: Holy, Unholy, Life. Whenever you are healed by the chosen type, your max HP is reduced by 3. Your HP returns to normal after combat ends, but you are not healed for the missing HP. If healed by your chosen type outside of combat your HP returns to normal after the next combat section ends.",
        supported = true,
    }, ]]
    CORRUPTED = {
        id = "CORRUPTED",
        name = "Corrupted",
        desc = "All healing received from other players and NPCs is cut in half, rounded down. Furthermore you must choose one of the following types of healing: Holy, Unholy, Life. Whenever you are healed by the chosen type, your max HP is reduced by 3. Your HP returns to normal after combat ends, but you are not healed for the missing HP. If healed by your chosen type outside of combat your HP returns to normal after the next combat section ends.",
        note = "Maximum health reduction is not yet implemented.",
        supported = true,
    },
    FATELESS = {
        id = "FATELESS",
        name = "Fateless",
        desc = "You no longer have access to your Fate Point.",
        supported = true,
    },
    FRAGILE = {
        id = "FRAGILE",
        name = "Fragile",
        desc = "Reduce your max HP by 8.",
        supported = true,
    },
    OUTCAST = {
        id = "OUTCAST",
        name = "Outcast",
        desc = "You no longer benefit from your Racial Trait.",
        supported = true,
    },
    REBOUND = {
        id = "REBOUND",
        name = "Rebound",
        desc = "When rolling a nat 1 on any player turn roll, you take damage equal to your Offense or Spirit stat, whichever is highest, and you have disadvantage during the next enemy turn. Requires at least 4 out of 6 points in either Offense or Spirit to pick.",
        icon = "Interface\\Icons\\ability_hunter_hatchettoss", -- TODO better icon
        supported = true,
        debuff = {
            type = BUFF_TYPES.DISADVANTAGE,
            turnTypeId = TURN_TYPES.ENEMY.id,
            remainingTurns = {
                [TURN_TYPES.ENEMY.id] = 1,
            },
        }
    },
    TEMPO = {
        id = "TEMPO",
        name = "Tempo",
        desc = "If you take damage during an enemy turn, you have disadvantage on your next player turn.",
        icon = "Interface\\Icons\\ability_mage_timewarp",
        supported = true,
        debuff = {
            type = BUFF_TYPES.DISADVANTAGE,
            turnTypeId = TURN_TYPES.PLAYER.id,
            remainingTurns = {
                [TURN_TYPES.PLAYER.id] = 1,
            },
        }
    },
    TIMID = {
        id = "TIMID",
        name = "Timid",
        desc = "While in melee range of an enemy, your Offence, Defense, and Spirit stats are reduced by -3.",
        icon = "Interface\\Icons\\spell_misc_emotionafraid",
        supported = true,
        distanceFromEnemy = "melee",
        debuff = {
            type = BUFF_TYPES.STAT,
            stats = {
                offence = -3,
                defence = -3,
                spirit = -3
            },
            canCancel = false,
        }
    },
}