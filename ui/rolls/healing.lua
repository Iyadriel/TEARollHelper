local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

--[[ local options = {
    order: Number
    outOfCombat: Boolean
} ]]
ui.modules.rolls.modules.healing.getOptions = function(options)
    return {
        name = "Heal",
        type = "group",
        inline = true,
        order = options.order,
        args = {
            greaterHeals = {
                name = "Greater Heals",
                type = "select",
                desc = "The amount of Greater Heals to use.",
                values = function()
                    local values = {}
                    for i = 0, rules.healing.getMaxGreaterHealSlots() do
                        values[i] = tostring(i)
                    end
                    return values
                end,
                disabled = function()
                    return rules.healing.getMaxGreaterHealSlots() == 0
                end,
                order = 0,
                get = function()
                    return turns.getNumGreaterHealSlots()
                end,
                set = function(info, value)
                    turns.setNumGreaterHealSlots(value)
                end
            },
            healing = {
                name = "Healing",
                type = "description",
                desc = "How much you can heal for",
                fontSize = "medium",
                order = 1,
                name = function()
                    local spirit = character.getPlayerSpirit()
                    local healing = actions.getHealing(turns.getCurrentTurnValues().roll, spirit, turns.getNumGreaterHealSlots(), options.outOfCombat)
                    local msg = " |n"

                    if healing.amountHealed > 0 then
                        local amount = tostring(healing.amountHealed)
                        if healing.isCrit then
                            msg = msg .. COLOURS.CRITICAL .. "MANY HEALS!|r " .. COLOURS.HEALING .. "You can heal everyone in line of sight for " .. amount .. " HP."
                        else
                            msg = msg .. COLOURS.HEALING .. "You can heal someone for " .. amount .. " HP."
                        end
                    else
                        msg = msg .. COLOURS.NOTE .. "You can't heal anyone with this roll."
                    end

                    return msg
                end
            },
            outOfCombatNote = {
                type = "description",
                name = COLOURS.NOTE .. " |nOut of combat, you can perform 3 regular heals (refreshes after combat ends), or spend as many Greater Heal slots as you want (you can roll every time you spend slots).",
                hidden = not options.outOfCombat,
                order = 2
            }
        }
    }
end