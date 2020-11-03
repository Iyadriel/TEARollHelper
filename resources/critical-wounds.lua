local _, ns = ...

local constants = ns.constants
local criticalWounds = ns.resources.criticalWounds

local CriticalWound = ns.models.CriticalWound
local CriticalWoundCripplingPain = ns.models.CriticalWoundCripplingPain

local ACTIONS = constants.ACTIONS
local BUFF_TYPES = constants.BUFF_TYPES
local TURN_TYPES = constants.TURN_TYPES

local wounds = {
    INJURED_ARM = {
        id = "INJURED_ARM",
        index = 1,
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
    INJURED_LEG = {
        id = "INJURED_LEG",
        index = 2,
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
    BAD_WOUNDS = {
        id = "BAD_WOUNDS",
        index = 3,
        name = "Bad Wounds",
        desc = "Your max HP is reduced by 8.",
        icon = "Interface\\Icons\\ability_backstab",
        buff = {
            types = { [BUFF_TYPES.MAX_HEALTH] = true },
            amount = -8,
        },
    },
    INTERNAL_BLEEDING = {
        id = "INTERNAL_BLEEDING",
        index = 4,
        name = "Internal Bleeding",
        desc = "You take 3 damage at the start of every player turn. Cannot be prevented or reduced in any way.",
        icon = "Interface\\Icons\\spell_shadow_lifedrain",
        buff = {
            types = { [BUFF_TYPES.DAMAGE_OVER_TIME] = true },
            turnTypeID = TURN_TYPES.PLAYER.id,
            canBeMitigated = false,
            damagePerTick = 3,
        },
    },
    CONCUSSION = {
        id = "CONCUSSION",
        index = 5,
        name = "Concussion",
        desc = "You lose 2 of your Utility traits (your choice).",
        icon = "Interface\\Icons\\spell_frost_stun",
    },
    CRIPPLING_PAIN = {
        model = CriticalWoundCripplingPain,
        id = "CRIPPLING_PAIN",
        index = 6,
        name = "Crippling Pain",
        desc = "You have disadvantage on one of the following, and cannot perform the other one at all (your choice) - Saves, Buff Rolls.",
        icon = "Interface\\Icons\\spell_holy_painsupression",
        buff = {
            types = { [BUFF_TYPES.DISADVANTAGE] = true },
            actions = {
                [ACTIONS.buff] = true,
                [ACTIONS.meleeSave] = true,
                [ACTIONS.rangedSave] = true,
            },
        },
    },
    DEEP_BRUISING = {
        id = "DEEP_BRUISING",
        index = 7,
        name = "Deep Bruising",
        desc = "You take 5 more damage from all sources except for Internal Bleeding.",
        icon = "Interface\\Icons\\ability_warrior_trauma",
        buff = {
            types = { [BUFF_TYPES.DAMAGE_TAKEN] = true },
            amount = 5,
        },
    },
    RUPTURED_ORGANS = {
        id = "RUPTURED_ORGANS",
        index = 8,
        name = "Ruptured Organs",
        desc = "Your Offence, Defence, and Spirit stats are reduced by 3.",
        icon = "Interface\\Icons\\ability_rogue_rupture",
        buff = {
            types = { [BUFF_TYPES.STAT] = true },
            stats = {
                offence = -3,
                defence = -3,
                spirit = -3,
            },
        },
    },
}

criticalWounds.WOUNDS = {}

for id, wound in pairs(wounds) do
    if not wound.model then
        wound.model = CriticalWound
    end

    criticalWounds.WOUNDS[id] = wound.model:New(
        wound.id,
        wound.index,
        wound.name,
        wound.desc,
        wound.icon,
        wound.buff
    )
end