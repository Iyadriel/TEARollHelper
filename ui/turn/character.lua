local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local integrations = ns.integrations
local rules = ns.rules
local traits = ns.resources.traits
local characterState = ns.state.character
local ui = ns.ui

local TRAITS = traits.TRAITS
local state = characterState.state

local function traitChargesSlider(order, trait, stateKey)
    return {
        order = order,
        type = "range",
        name = COLOURS.TRAITS.GENERIC .. trait.name .. " charges",
        desc = trait.desc,
        min = 0,
        max = trait.numCharges,
        step = 1,
        get = state.featsAndTraits[stateKey].get,
        set = function(info, value)
            state.featsAndTraits[stateKey].set(value)
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
        name = "Character",
        desc = "The current state of your character",
        order = options.order,
        args = {
            buffs = ui.modules.buffs.getOptions({ order = 0 }),
            turn_character_hp = {
                order = 1,
                type = "range",
                name = "Health",
                desc = "How much health your character has",
                softMin = 0,
                min = -100,
                max = character.getPlayerMaxHP(),
                step = 1,
                get = state.health.get,
                set = function(info, value)
                    state.health.set(value)
                end,
                dialogControl = TEARollHelper:CreateCustomSlider("turn_character_hp", {
                    max = character.getPlayerMaxHP
                })
            },
            healing = {
                order = 2,
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
                        get = state.healing.excess.get,
                        set = function(info, value)
                            state.healing.excess.set(value)
                        end
                    },
                }
            },
            featsAndTraits = {
                order = 3,
                type = "group",
                name = "Feats and traits",
                inline = true,
                args = {
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
                    bulwark = traitChargesSlider(1, TRAITS.BULWARK, "numBulwarkCharges"),
                    secondWind = traitChargesSlider(2, TRAITS.SECOND_WIND, "numSecondWindCharges"),
                    vindication = traitChargesSlider(3, TRAITS.VINDICATION, "numVindicationCharges"),
                }
            },
            turn_character_fatePoints = {
                order = 4,
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
                order = 5,
                type = "execute",
                name = "Update Total RP",
                desc = "Update your Total RP 'Currently' with your current/max HP",
                hidden = function()
                    return not integrations.TRP or TEARollHelper.db.global.settings.autoUpdateTRP
                end,
                disabled = function()
                    return TEARollHelper.db.global.settings.autoUpdateTRP
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
                order = 6,
                type = "description",
                name = COLOURS.NOTE .. " |nYour Total RP is set to update automatically when needed.",
                hidden = function()
                    return not (integrations.TRP and TEARollHelper.db.global.settings.autoUpdateTRP)
                end,
            }
        }
    }
end