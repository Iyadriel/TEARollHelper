local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffs = ns.buffs
local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local ui = ns.ui
local utils = ns.utils

local criticalWounds = ns.resources.criticalWounds
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local ACTIONS, SPECIAL_ACTIONS = constants.ACTIONS, constants.SPECIAL_ACTIONS
local ACTION_LABELS, SPECIAL_ACTION_LABELS = constants.ACTION_LABELS, constants.SPECIAL_ACTION_LABELS
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
                                    consequences.applyFaelunesRegrowth(regrowthHealing)
                                end,
                            }
                        },
                    },
                }
            },
            criticalWounds = {
                order = 2,
                type = "group",
                name = "Critical wounds",
                inline = true,
                args = utils.merge(
                    (function()
                        local toggles = {}

                        for id, wound in pairs(criticalWounds.WOUNDS) do
                            toggles[id] = {
                                order = wound.index,
                                type = "toggle",
                                name = COLOURS.NOTE .. wound.index.. ": |r" .. wound.name,
                                desc = wound.desc,
                                get = function()
                                    return wound:IsActive()
                                end,
                                set = function()
                                    wound:Toggle()
                                end,
                            }
                        end

                        return toggles
                    end)(),
                    {
                        unavailableAction = {
                            order = 9,
                            type = "select",
                            width = 0.7,
                            name = "Unavailable action",
                            hidden = function()
                                return not criticalWounds.WOUNDS.CRIPPLING_PAIN:IsActive()
                            end,
                            values = {
                                [ACTIONS.buff] = ACTION_LABELS.buff,
                                [SPECIAL_ACTIONS.save] = SPECIAL_ACTION_LABELS.save,

                            },
                            get = function()
                                return criticalWounds.WOUNDS.CRIPPLING_PAIN:GetUnavailableAction()
                            end,
                            set = function(info, value)
                                criticalWounds.WOUNDS.CRIPPLING_PAIN:SetUnavailableAction(value)
                            end,
                        }
                    }
                )
            },
            updateTRPButton = ui.helpers.updateTRPButton({ order = 3 }),
            autoUpdateTRPNote = ui.helpers.autoUpdateTRPNote({ order = 4 }),
        }
    }
end