local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

local FEATS = feats.FEATS

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
                        local healColour = (options.outOfCombat and character.hasFeat(FEATS.MEDIC)) and COLOURS.FEATS.GENERIC or COLOURS.HEALING

                        if healing.isCrit then
                            msg = msg .. COLOURS.CRITICAL .. "MANY HEALS!|r " .. healColour .. "You can heal everyone in line of sight for " .. amount .. " HP."
                        else
                            msg = msg .. healColour .. "You can heal someone for " .. amount .. " HP."
                        end
                    else
                        msg = msg .. COLOURS.NOTE .. "You can't heal anyone with this roll."
                    end

                    return msg
                end
            },
            outOfCombatNote = {
                type = "description",
                name = function()
                    local msg = COLOURS.NOTE .. " |nOut of combat, you can perform "
                    if character.hasFeat(FEATS.MEDIC) then
                        msg = msg .. COLOURS.FEATS.GENERIC .. rules.healing.calculateNumHealsAllowedOutOfCombat() .. " regular heals" .. COLOURS.NOTE
                    else
                        msg = msg .. rules.healing.calculateNumHealsAllowedOutOfCombat() .. " regular heals"
                    end
                    msg = msg .. " (refreshes after combat ends), or spend as many Greater Heal slots as you want (you can roll every time you spend slots)."
                    return msg
                end,
                hidden = not options.outOfCombat,
                order = 2
            }
        }
    }
end