local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local turns = ns.turns
local ui = ns.ui

--[[ local options = {
    order: Number
} ]]
ui.modules.rolls.modules.buff.getOptions = function(options)
    return {
        name = "Buff",
        type = "group",
        inline = true,
        order = options.order,
        args = {
            buff = {
                type = "description",
                desc = "How much you can buff for",
                fontSize = "medium",
                order = 4,
                name = function()
                    local spirit = character.getPlayerSpirit()
                    local offence = character.getPlayerOffence()
                    local offenceBuff = turns.getCurrentBuffs().offence
                    local spiritBuff = turns.getCurrentBuffs().spirit
                    local buff = actions.getBuff(turns.getCurrentTurnValues().roll, spirit, spiritBuff, offence, offenceBuff)

                    local msg

                    if buff.amountBuffed > 0 then
                        local amount = tostring(buff.amountBuffed)
                        if buff.isCrit then
                            msg = COLOURS.CRITICAL .. "BIG BUFF!|r " .. COLOURS.BUFF .. "You can buff everyone in line of sight for " .. amount .. "."
                        else
                            msg = COLOURS.BUFF .. "You can buff someone for " .. amount .. "."
                        end

                        if buff.usesInspiringPresence then
                            msg = msg .. COLOURS.NOTE .. "|nYour buff is active in both the current player turn and the next enemy turn."
                        end
                    else
                        msg = COLOURS.NOTE .. "You can't buff anyone with this roll."
                    end

                    return msg
                end
            }
        }
    }
end