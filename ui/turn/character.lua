local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local integrations = ns.integrations
local rules = ns.rules
local traits = ns.resources.traits
local characterState = ns.state.character
local settings = ns.settings
local ui = ns.ui
local utils = ns.utils

local TRAIT_KEYS = traits.TRAIT_KEYS
local TRAITS = traits.TRAITS
local state = characterState.state

local function traitChargesSlider(order, trait)
    local colour = COLOURS.TRAITS[trait.id] or COLOURS.TRAITS.GENERIC

    return {
        order = order,
        type = "range",
        name = colour .. trait.name .. " charges",
        desc = trait.desc,
        min = 0,
        max = trait.numCharges,
        step = 1,
        get = function()
            return state.featsAndTraits.numTraitCharges.get(trait.id)
        end,
        set = function(info, value)
            state.featsAndTraits.numTraitCharges.set(trait.id, value)
        end,
        hidden = function()
            return not character.hasTrait(trait)
        end,
    }
end

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.character.getOptions = function(options)
    return {
        type = "group",
        name = ui.iconString("Interface\\Icons\\petbattle_health") .. "Health and resources",
        desc = "The current state of your character",
        order = options.order,
        args = {
            debugView = {
                order = 0,
                type = "group",
                name = "Debug",
                inline = true,
                hidden = function()
                    return not settings.debug.get()
                end,
                args = {
                    statBuffs = {
                        order = 1,
                        type = "description",
                        name = function()
                            local out = {
                                "Offence buff: ",
                                state.buffs.offence.get(),
                                "|nDefence buff: ",
                                state.buffs.defence.get(),
                                "|nSpirit buff: ",
                                state.buffs.spirit.get(),
                                "|nStamina buff: ",
                                state.buffs.stamina.get(),
                            }

                            return table.concat(out)
                        end,
                    }
                }
            },
            health = {
                order = 1,
                type = "group",
                name = "Health",
                inline = true,
                args = {
                    turn_character_hp = {
                        order = 0,
                        type = "range",
                        name = "Health",
                        desc = "How much health your character has",
                        softMin = 0,
                        min = -100,
                        max = state.maxHealth.get(),
                        step = 1,
                        get = state.health.get,
                        set = function(info, value)
                            state.health.set(value)
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("turn_character_hp", {
                            max = state.maxHealth.get
                        })
                    },
                }
            },
            defence = {
                order = 2,
                type = "group",
                name = "Defence",
                inline = true,
                hidden = function()
                    return not character.hasDefenceMastery()
                end,
                args = {
                    damagePrevented = {
                        order = 0,
                        type = "range",
                        name = COLOURS.ROLES.TANK .. "Damage prevented",
                        desc = "When you block incoming damage to yourself, or to someone else via Melee save, it counts towards your ”Damage prevented”. When that counter reaches 50 it resets back to zero and you can regain 1 charge to a trait of your choice.",
                        min = 0,
                        max = rules.defence.MAX_DAMAGE_PREVENTED - 1,
                        step = 1,
                        get = state.defence.damagePrevented.get,
                        set = function(info, value)
                            state.defence.damagePrevented.set(value)
                        end,
                    },
                }
            },
            healing = {
                order = 3,
                type = "group",
                name = "Healing",
                inline = true,
                args = {
                    turn_character_numGreaterHealSlots = {
                        order = 0,
                        type = "range",
                        name = "Greater Heal slots",
                        desc = "How many Greater Heals you have left.|n"
                                .. "Using a Greater Heal increases the amount of your next heal. Multiple Greater Heals can be used at the same time.",
                        min = 0,
                        max = rules.healing.getMaxGreaterHealSlots(),
                        step = 1,
                        get = state.healing.numGreaterHealSlots.get,
                        set = function(info, value)
                            state.healing.numGreaterHealSlots.set(value)
                        end,
                        disabled = function()
                            return rules.healing.getMaxGreaterHealSlots() == 0
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("turn_character_numGreaterHealSlots", {
                            max = rules.healing.getMaxGreaterHealSlots
                        })
                    },
                    excess = {
                        order = 1,
                        type = "range",
                        name = "Excess",
                        desc = "How much Excess you have gained.|n"
                                .. "You can spend Excess to increase your own spirit or offense stat for a player turn (1 point per 1 Excess spent).|n"
                                .. "Spending Excess does not grant you more Greater Heal Slots, but if you wish you can spend all 6 points of Excess without buffing yourself in order to restore 1 Greater Heal Slot.",
                        min = 0,
                        max = rules.healing.getMaxExcess(),
                        step = 1,
                        hidden = function()
                            return not rules.healing.canUseExcess()
                        end,
                        get = state.healing.excess.get,
                        set = function(info, value)
                            state.healing.excess.set(value)
                        end
                    },
                }
            },
            featsAndTraits = {
                order = 4,
                type = "group",
                name = "Feats and traits",
                inline = true,
                args = utils.merge({
                    turn_character_numBloodHarvestSlots = {
                        order = 0,
                        type = "range",
                        name = COLOURS.FEATS.BLOOD_HARVEST .. "Blood Harvest slots",
                        desc = "How many Blood Harvest slots you have left",
                        min = 0,
                        max = rules.offence.getMaxBloodHarvestSlots(),
                        step = 1,
                        get = state.featsAndTraits.numBloodHarvestSlots.get,
                        set = function(info, value)
                            state.featsAndTraits.numBloodHarvestSlots.set(value)
                        end,
                        hidden = function()
                            return not rules.offence.canUseBloodHarvest()
                        end,
                        disabled = function()
                            return rules.offence.getMaxBloodHarvestSlots() == 0
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("turn_character_numBloodHarvestSlots", {
                            max = rules.offence.getMaxBloodHarvestSlots
                        })
                    },
                }, (function()
                    local sliders = {}

                    for i, traitID in ipairs(TRAIT_KEYS) do
                        local trait = TRAITS[traitID]
                        if trait.numCharges then
                            sliders[traitID] = traitChargesSlider(i, trait)
                        end
                    end

                    return sliders
                end)())
            },
            turn_character_fatePoints = {
                order = 5,
                type = "range",
                name = "Fate Points",
                desc = "How many Fate Points you have left",
                min = 0,
                max = rules.rolls.getMaxFatePoints(),
                step = 1,
                hidden = function()
                    return rules.rolls.getMaxFatePoints() == 0
                end,
                get = state.numFatePoints.get,
                set = function(info, value)
                    state.numFatePoints.set(value)
                end,
                dialogControl = TEARollHelper:CreateCustomSlider("turn_character_fatePoints", {
                    max = rules.rolls.getMaxFatePoints
                })
            },
            updateTRP = {
                order = 6,
                type = "execute",
                name = "Update Total RP",
                desc = "Update your Total RP 'Currently' with your current/max HP",
                width = "full",
                hidden = function()
                    return not integrations.TRP or settings.autoUpdateTRP.get()
                end,
                confirm = function()
                    if not TEARollHelper.db.global.warningsSeen.updateTRP then
                        return "This will allow this addon to overwrite any content you have set in your 'Currently' field."
                    end
                    return false
                end,
                func = function()
                    integrations.TRP.updateCurrently()
                    TEARollHelper:Print("Updated your Total RP profile.")
                    TEARollHelper.db.global.warningsSeen.updateTRP = true
                end,
            },
            autoUpdateTRPNote = {
                order = 7,
                type = "description",
                name = COLOURS.NOTE .. " |nYour Total RP is set to update automatically when needed.|n ",
                hidden = function()
                    return not (integrations.TRP and settings.autoUpdateTRP.get())
                end,
            },
            openConfig = {
                order = 8,
                type = "execute",
                width = "full",
                name = "Show character sheet",
                func = function()
                    ui.openWindow(ui.modules.config.name)
                end,
            },
        }
    }
end