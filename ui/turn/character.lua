local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local consequences = ns.consequences
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits
local characterState = ns.state.character
local ui = ns.ui
local utils = ns.utils

local FEATS = feats.FEATS
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
        max = rules.traits.getMaxTraitCharges(trait),
        step = 1,
        get = function()
            return state.featsAndTraits.numTraitCharges.get(trait.id)
        end,
        set = function(info, value)
            state.featsAndTraits.numTraitCharges.set(trait.id, value)
        end,
        disabled = function()
            return rules.traits.getMaxTraitCharges(trait) <= 0
        end,
        hidden = function()
            return not character.hasTrait(trait)
        end,
        dialogControl = TEARollHelper:CreateCustomSlider("turn_character_numCharges_" .. trait.id, {
            max = function()
                return rules.traits.getMaxTraitCharges(trait)
            end
        })
    }
end

local nameStart = ui.iconString("Interface\\Icons\\petbattle_health") .. "Character" .. COLOURS.NOTE .. " ("

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.character.getOptions = function(options)
    return {
        type = "group",
        name = function()
            local currentHealth = characterState.state.health.get()
            local maxHealth = characterState.state.maxHealth.get()
            return nameStart .. utils.healthColor(currentHealth, maxHealth) .. characterState.summariseHP() .. COLOURS.NOTE .. ")"
        end,
        order = options.order,
        args = {
            debugView = ui.helpers.debugView(),
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
                    return not rules.defence.canUseBraceSystem()
                end,
                args = {
                    damagePrevented = {
                        order = 0,
                        type = "range",
                        name = COLOURS.ROLES.TANK .. "Damage prevented",
                        desc = "When you block incoming damage to yourself, or to someone else via Melee save, it counts towards your ”Damage prevented”. When that counter reaches 15 it resets back to zero and you can regain 1 charge of Brace.",
                        min = 0,
                        max = rules.defence.MAX_DAMAGE_PREVENTED - 1,
                        step = 1,
                        get = state.defence.damagePrevented.get,
                        set = function(info, value)
                            state.defence.damagePrevented.set(value)
                        end,
                    },
                    turn_character_numBraceCharges = {
                        order = 1,
                        type = "range",
                        name = COLOURS.ROLES.TANK .. "Brace",
                        desc = "You have 3 charges of 'Brace'. Each charge of Brace that you spend increases your Defence stat for your next Defence roll by +2. Every 15 damage that you prevent through Defence rolls and Melee Saves restore 1 charge of Brace.",
                        min = 0,
                        max = rules.defence.getMaxBraceCharges(),
                        step = 1,
                        get = state.defence.numBraceCharges.get,
                        set = function(info, value)
                            state.defence.numBraceCharges.set(value)
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("turn_character_numBraceCharges", {
                            max = rules.defence.getMaxBraceCharges
                        })
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
                    turn_character_remainingOutOfCombatHeals = {
                        order = 1,
                        type = "range",
                        name = function()
                            if character.hasFeat(FEATS.MEDIC) then
                                return COLOURS.FEATS.GENERIC .. "Heals out of combat"
                            end
                            return "Heals out of combat"
                        end,
                        desc = function()
                            local msg = COLOURS.NOTE .. "Out of combat, you can perform "
                            if character.hasFeat(FEATS.MEDIC) then
                                msg = msg .. COLOURS.FEATS.GENERIC .. rules.healing.getMaxOutOfCombatHeals() .. " regular heals" .. COLOURS.NOTE
                            else
                                msg = msg .. rules.healing.getMaxOutOfCombatHeals() .. " regular heals"
                            end
                            msg = msg .. " (refreshes after combat ends), or spend as many Greater Heal slots as you want (you can roll every time you spend slots)."
                            return msg
                        end,
                        min = 0,
                        max = rules.healing.getMaxOutOfCombatHeals(),
                        step = 1,
                        get = state.healing.remainingOutOfCombatHeals.get,
                        set = function(info, value)
                            state.healing.remainingOutOfCombatHeals.set(value)
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("turn_character_remainingOutOfCombatHeals", {
                            max = rules.healing.getMaxOutOfCombatHeals
                        })
                    },
                    excess = {
                        order = 2,
                        type = "range",
                        name = "Excess",
                        desc = "How much Excess you have gained.|n"
                                .. "You can spend Excess to increase your own spirit or offense stat for a player turn (1 point per 1 Excess spent).|n"
                                .. "Spending Excess does not grant you more Greater Heal Slots, but if you wish you can spend all 3 points of Excess without buffing yourself in order to restore 1 Greater Heal Slot.",
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
                    restoreGreaterHealSlot = {
                        order = 3,
                        type = "execute",
                        name = "Restore Greater Heal slot",
                        desc = "Spend " .. rules.healing.NUM_EXCESS_TO_RESTORE_GREATER_HEAL_SLOT .. " excess to restore a Greater Heal slot.",
                        hidden = function()
                            return not rules.healing.canUseExcess() or rules.healing.getMaxGreaterHealSlots() == 0 or state.healing.numGreaterHealSlots.get() == rules.healing.getMaxGreaterHealSlots()
                        end,
                        disabled = function()
                            return state.healing.excess.get() < rules.healing.NUM_EXCESS_TO_RESTORE_GREATER_HEAL_SLOT
                        end,
                        func = function()
                            consequences.restoreGreaterHealSlotWithExcess()
                        end,
                    }
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
                            sliders["turn_character_numCharges_" .. traitID] = traitChargesSlider(i, trait)
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
            updateTRPButton = ui.helpers.updateTRPButton({ order = 6 }),
            autoUpdateTRPNote = ui.helpers.autoUpdateTRPNote({ order = 7 }),
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