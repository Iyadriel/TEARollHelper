local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffs = ns.buffs
local character = ns.character
local characterState = ns.state.character
local traits = ns.resources.traits
local ui = ns.ui
local weaknesses = ns.resources.weaknesses

local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local healAmount = 1
local healingPerTick = 1
local addCorruptedDebuff = false -- TODO reset when weakness is removed (move to state)

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.otherPlayers.getOptions = function(options)
    local NOURISH = TRAITS.NOURISH

    return {
        order = options.order,
        type = "group",
        name = "Other players",
        desc = "Effects from other players",
        args = {
            healing = {
                order = 0,
                type = "group",
                name = "Healing",
                inline = true,
                args = {
                    regularHealing = {
                        order = 0,
                        type = "group",
                        name = "Regular healing",
                        inline = true,
                        args = {
                            healAmount = {
                                order = 0,
                                type = "input",
                                name = "Incoming heal",
                                pattern = "%d+",
                                get = function()
                                    return tostring(healAmount)
                                end,
                                set = function(info, value)
                                    healAmount = tonumber(value)
                                end,
                            },
                            heal = {
                                order = 1,
                                type = "execute",
                                name = COLOURS.HEALING .. "Apply heal",
                                desc = "Get healed for the specified incoming heal amount.",
                                func = function()
                                    characterState.state.health.heal(healAmount)
                                    if addCorruptedDebuff then
                                        buffs.addWeaknessDebuff(WEAKNESSES.CORRUPTED, true)
                                    end
                                end,
                            },
                            addCorruptedDebuff = {
                                order = 2,
                                type = "toggle",
                                name = COLOURS.WEAKNESSES.CORRUPTED .. "Add " .. WEAKNESSES.CORRUPTED.name .. " stack",
                                desc = "Enable if the heal you receive is of the school you are vulnerable to (Holy, Unholy or Life).",
                                hidden = function()
                                    return not (character.hasWeakness(WEAKNESSES.CORRUPTED) or addCorruptedDebuff)
                                end,
                                get = function()
                                    return addCorruptedDebuff
                                end,
                                set = function(info, value)
                                    addCorruptedDebuff = value
                                end,
                            }
                        },
                    },
                    nourish = {
                        order = 1,
                        type = "group",
                        name = COLOURS.TRAITS.GENERIC .. NOURISH.name,
                        inline = true,
                        args = {
                            healingPerTick = {
                                order = 0,
                                type = "input",
                                name = "Healing per tick",
                                desc = "The amount you are healed for at the start of every applicable turn.",
                                pattern = "%d+",
                                get = function()
                                    return tostring(healingPerTick)
                                end,
                                set = function(info, value)
                                    healingPerTick = tonumber(value)
                                end,
                            },
                            nourish = {
                                order = 1,
                                type = "execute",
                                name = COLOURS.HEALING .. "Apply " .. NOURISH.name,
                                desc = "Applies the " .. NOURISH.name .. " effect to you.",
                                func = function()
                                    buffs.addHoTBuff(NOURISH.name, NOURISH.icon, healingPerTick, NOURISH.buffs[1].remainingTurns)
                                end,
                            }
                        },
                    },
                }
            }
        }
    }
end