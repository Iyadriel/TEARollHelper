local _, ns = ...

local turns = ns.turns
local ui = ns.ui

ui.modules.buffs = {
    name = "Buffs",
    type = "group",
    desc = "Apply a temporary buff",
    order = 1,
    validate = function(info, input)
        local amount = TeaRollHelper:GetArgs(input)
        if tonumber(amount) == nil then
            return "Buff value must be a number! |cFFBBBBBBExample: /tea buff offence 6"
        end
        return true
    end,
    get = function(info)
        return tostring(turns.getCurrentBuffs()[info[#info]])
    end,
    set = function(info, input)
        local buffType = info[#info]
        local amount = TeaRollHelper:GetArgs(input)
        turns.setCurrentBuff(buffType, tonumber(amount))
    end,
    args = {
        offence = {
            type = "input",
            name = "Offence",
            desc = "Buff your character's offence stat",
            order = 0
        },
        defence = {
            type = "input",
            name = "Defence",
            desc = "Buff your character's defence stat",
            order = 1
        },
        description = {
            type = "description",
            name = "Buffs expire after one turn.",
            order = 2
        }
    }
}