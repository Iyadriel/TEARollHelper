local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local turns = ns.turns
local ui = ns.ui

--[[ local options = {
    order: Number
} ]]
ui.modules.rolls.modules.defend.getOptions = function(options)
    return {
        name = "Defend",
        type = "group",
        inline = true,
        order = options.order,
        args = {
            damageTaken = {
                type = "description",
                desc = "How much damage you take this turn",
                fontSize = "medium",
                order = 0,
                name = function()
                    local defence = character.getPlayerDefence()
                    local buff = turns.getCurrentBuffs().defence
                    local values = turns.getCurrentTurnValues()
                    local racialTrait = turns.getRacialTrait()
                    local defend = actions.getDefence(values.roll, values.defendThreshold, values.damageRisk, defence, buff, racialTrait)

                    if defend.damageTaken > 0 then
                        return COLOURS.DAMAGE .. "You take " .. tostring(defend.damageTaken) .. " damage."
                    else
                        local msg = "Safe! You don't take damage this turn."
                        if defend.canRetaliate then
                            msg = msg .. COLOURS.CRITICAL .. "\nRETALIATE!|r You can deal "..defend.retaliateDmg.." damage to your attacker!"
                        end
                        return msg
                    end
                end
            },
        },
    }
end