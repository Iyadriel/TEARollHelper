local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local rolls = ns.state.rolls
local ui = ns.ui

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.buff.getOptions = function(options)
    return {
        name = "Buff",
        type = "group",
        order = options.order,
        args = {
            roll = ui.modules.turn.modules.roll.getOptions({ order = 0, action = "buff" }),
            buff = {
                order = 1,
                type = "group",
                name = "Buff",
                inline = true,
                hidden = function()
                    return not rolls.state.buff.currentRoll.get()
                end,
                args = {
                    buff = {
                        type = "description",
                        desc = "How much you can buff for",
                        fontSize = "medium",
                        order = 0,
                        name = function()
                            local buff = rolls.getBuff()

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
            },
        }
    }
end