local _, ns = ...

local constants = ns.constants
local criticalWounds = ns.resources.criticalWounds

local CriticalWound = ns.models.CriticalWound

local ACTIONS = constants.ACTIONS
local BUFF_TYPES = constants.BUFF_TYPES
local TURN_TYPES = constants.TURN_TYPES

local wounds = {
    [1] = {
        name = "Injured Arm",
        desc = "You have disadvantage on Attack rolls.",
        icon = "Interface\\Icons\\ability_warrior_bloodfrenzy",
        buff = {
            types = { [BUFF_TYPES.DISADVANTAGE] = true },
            actions = {
                [ACTIONS.attack] = true,
            },
        },
    },
    [2] = {
        name = "Injured Leg",
        desc = "You have disadvantage on Defence rolls.",
        icon = "Interface\\Icons\\ability_monk_legsweep",
        buff = {
            types = { [BUFF_TYPES.DISADVANTAGE] = true },
            actions = {
                [ACTIONS.defend] = true,
            },
        },
    },
    [3] = {
        name = "Bad Wounds",
        desc = "Your max HP is reduced by 8.",
        icon = "Interface\\Icons\\ability_backstab",
        buff = {
            types = { [BUFF_TYPES.MAX_HEALTH] = true },
            amount = -8,
        },
    },
    [4] = {
        name = "Internal Bleeding",
        desc = "You take 3 damage at the start of every player turn. Cannot be prevented or reduced in any way.",
        icon = "Interface\\Icons\\spell_shadow_lifedrain",
        buff = {
            types = { [BUFF_TYPES.DAMAGE_OVER_TIME] = true },
            turnTypeID = TURN_TYPES.PLAYER.id,
            ignoreDmgReduction = true,
            damagePerTick = 3,
        },
    },
}

criticalWounds.WOUNDS = {}

for index, wound in ipairs(wounds) do
    criticalWounds.WOUNDS[index] = CriticalWound:New(wound, index)
end