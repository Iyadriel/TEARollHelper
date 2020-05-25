local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local characterState = ns.state.character.state
local feats = ns.resources.feats
local rolls = ns.state.rolls
local rules = ns.rules
local ui = ns.ui

local FEATS = feats.FEATS
local state = rolls.state

--[[ local options = {
    order: Number
    outOfCombat: Boolean
} ]]
ui.modules.actions.modules.healing.getOptions = function(options)
    return {
        name = "Heal",
        type = "group",
        inline = true,
        order = options.order,
        args = {
            actions_healing_greaterHeals = {
                order = 0,
                type = "range",
                name = "Greater Heals",
                desc = "The amount of Greater Heals to use.",
                min = 0,
                max = characterState.healing.numGreaterHealSlots.get(),
                step = 1,
                hidden = function()
                    return rules.healing.getMaxGreaterHealSlots() == 0
                end,
                disabled = function()
                    return characterState.healing.numGreaterHealSlots.get() == 0
                end,
                get = function()
                    return state.healing.numGreaterHealSlots
                end,
                set = function(info, value)
                    state.healing.numGreaterHealSlots = value
                end,
                dialogControl = TEARollHelper:CreateCustomSlider("actions_healing_greaterHeals", {
                    max = characterState.healing.numGreaterHealSlots.get
                })
            },
            mercyFromPain = {
                name = COLOURS.FEATS.MERCY_FROM_PAIN .. FEATS.MERCY_FROM_PAIN.name,
                type = "select",
                desc = FEATS.MERCY_FROM_PAIN.desc,
                order = 1,
                values = {
                    [0] = "Inactive",
                    [rules.offence.calculateMercyFromPainBonusHealing(false)] = "Single enemy damaged",
                    [rules.offence.calculateMercyFromPainBonusHealing(true)] = "Multple enemies damaged",
                },
                hidden = function()
                    return options.outOfCombat or not rules.offence.canProcMercyFromPain()
                end,
                get = function()
                    return state.healing.mercyFromPainBonusHealing
                end,
                set = function(info, value)
                    state.healing.mercyFromPainBonusHealing = value
                end
            },
            healing = {
                type = "description",
                desc = "How much you can heal for",
                fontSize = "medium",
                order = 2,
                name = function()
                    local healing = rolls.getHealing(options.outOfCombat)
                    local msg = rules.healing.getMaxGreaterHealSlots() > 0 and " |n" or "" -- Only show spacing if greater heals are shown. Dirty hack

                    if healing.amountHealed > 0 then
                        local amount = tostring(healing.amountHealed)
                        local healColour = (options.outOfCombat and character.hasFeat(FEATS.MEDIC)) and COLOURS.FEATS.GENERIC or COLOURS.HEALING

                        if healing.isCrit then
                            msg = msg .. COLOURS.CRITICAL .. "MANY HEALS!|r " .. healColour .. "You can heal everyone in line of sight for " .. amount .. " HP."
                        else
                            if healing.usesParagon then
                                local targets = healing.playersHealableWithParagon > 1 and " allies" or " ally"
                                msg = msg .. healColour .. "You can heal " .. healing.playersHealableWithParagon .. targets .. " for " .. amount .. " HP."
                            else
                                msg = msg .. healColour .. "You can heal for " .. amount .. " HP."
                            end
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
                order = 3
            }
        }
    }
end