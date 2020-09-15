local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffs = ns.buffs
local character = ns.character
local characterState = ns.state.character
local constants = ns.constants
local traits = ns.resources.traits
local ui = ns.ui
local weaknesses = ns.resources.weaknesses

local INCOMING_HEAL_SOURCES = constants.INCOMING_HEAL_SOURCES
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local damageAmount = 1

local healAmount = 1
local regrowthHealing = 1
local addCorruptedDebuff = false -- TODO reset when weakness is removed (move to state)

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.effects.getOptions = function(options)
    local FAELUNES_REGROWTH = TRAITS.FAELUNES_REGROWTH

    return {
        order = options.order,
        type = "group",
        name = ui.iconString("Interface\\Icons\\spell_magic_lesserinvisibilty") .. "Effects",
        args = {
            damage = {
                order = 0,
                type = "group",
                name = "Take damage",
                inline = true,
                args = {
                    damageAmount = {
                        order = 0,
                        type = "range",
                        name = "Incoming damage",
                        min = 1,
                        softMax = 30,
                        max = 50,
                        step = 1,
                        get = function()
                            return damageAmount
                        end,
                        set = function(info, value)
                            damageAmount = value
                        end,
                    },
                    damage = {
                        order = 1,
                        type = "execute",
                        name = COLOURS.DAMAGE .. "Take damage",
                        desc = "Take the specified amount of damage.",
                        func = function()
                            characterState.state.health.damage(damageAmount)
                        end,
                    },
                }
            },
            healing = {
                order = 1,
                type = "group",
                name = "Get healed",
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
                                type = "range",
                                name = "Incoming heal",
                                min = 1,
                                softMax = 30,
                                max = 50,
                                step = 1,
                                get = function()
                                    return healAmount
                                end,
                                set = function(info, value)
                                    healAmount = value
                                end,
                            },
                            heal = {
                                order = 1,
                                type = "execute",
                                name = COLOURS.HEALING .. "Apply heal",
                                desc = "Get healed for the specified incoming heal amount.",
                                func = function()
                                    characterState.state.health.heal(healAmount, INCOMING_HEAL_SOURCES.OTHER_PLAYER)
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
                    faelunesRegrowth = {
                        order = 1,
                        type = "group",
                        name = COLOURS.TRAITS.FAELUNES_REGROWTH .. FAELUNES_REGROWTH.name,
                        inline = true,
                        args = {
                            regrowthHealing = {
                                order = 0,
                                type = "range",
                                name = "Initial heal amount",
                                desc = "The amount you are healed for immediately. You will also be healed for half of this amount for the next two turns.",
                                min = 1,
                                softMax = 30,
                                max = 50,
                                step = 1,
                                get = function()
                                    return regrowthHealing
                                end,
                                set = function(info, value)
                                    regrowthHealing = value
                                end,
                            },
                            faelunesRegrowth = {
                                order = 1,
                                type = "execute",
                                name = COLOURS.TRAITS.FAELUNES_REGROWTH .. "Apply " .. FAELUNES_REGROWTH.name,
                                desc = "Applies the " .. FAELUNES_REGROWTH.name .. " effect to you.",
                                func = function()
                                    characterState.state.health.heal(regrowthHealing, INCOMING_HEAL_SOURCES.OTHER_PLAYER)
                                    local healingPerTick = ceil(regrowthHealing / 2)
                                    buffs.addHoTBuff(FAELUNES_REGROWTH.name, FAELUNES_REGROWTH.icon, healingPerTick, FAELUNES_REGROWTH.buffs[1].remainingTurns)
                                end,
                            }
                        },
                    },
                }
            }
        }
    }
end