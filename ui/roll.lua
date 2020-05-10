local _, ns = ...

local turns = ns.turns
local ui = ns.ui

ui.modules.roll = {
    name = "Roll",
    type = "group",
    desc = "Perform a roll",
    guiHidden = true,
    cmdInline = true,
    order = 1,
    args = {
        attack = {
            name = "Attack",
            type = "input",
            desc = "Perform an attack roll",
            order = 0,
            validate = function(info, input)
                local threshold = tonumber(input)
                if threshold == nil then
                    return "Attack threshold must be a number! |cFFBBBBBBExample: /tea attack 15"
                end
                return true
            end,
            set = function(info, threshold)
                TEARollHelper:Print("Attacking with threshold "..threshold..".")
                turns.startAttackTurn(threshold)
            end
        },
        defend = {
            name = "Defend",
            type = "input",
            desc = "Perform a defence roll",
            order = 1,
            validate = function(info, input)
                local threshold, dmg = TEARollHelper:GetArgs(input, 2)
                threshold = tonumber(threshold)
                dmg = tonumber(dmg)
                if threshold == nil or dmg == nil then
                    return "Defence roll needs a threshold and damage risk. |cFFBBBBBBExample: /tea defend 12 4"
                end
                return true
            end,
            set = function(info, input)
                local threshold, dmg = TEARollHelper:GetArgs(input, 2)
                threshold = tonumber(threshold)
                dmg = tonumber(dmg)
                TEARollHelper:Print("Defending with threshold "..threshold.." and a risk of "..dmg.." damage.")
                turns.startDefendTurn(threshold, dmg)
            end
        },
    }
}