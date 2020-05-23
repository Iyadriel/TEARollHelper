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
                    secondWind = {
                        order = 1,
                        type = "range",
                        name = TRAITS.SECOND_WIND.name .. " charges",
                        desc = TRAITS.SECOND_WIND.desc,
                        min = 0,
                        max = TRAITS.SECOND_WIND.numCharges,
                        step = 1,
                        get = state.featsAndTraits.numSecondWindCharges.get,
                        set = function(info, value)
                            state.featsAndTraits.numSecondWindCharges.set(value)
                        end,
                        hidden = function()
                            return not rules.traits.canUseSecondWind()
                        end,
                    },
                    vindication = {
                        order = 2,
                        type = "range",
                        name = TRAITS.VINDICATION.name .. " charges",
                        desc = TRAITS.VINDICATION.desc,
                        min = 0,
                        max = TRAITS.VINDICATION.numCharges,
                        step = 1,
                        get = state.featsAndTraits.numVindicationCharges.get,
                        set = function(info, value)
                            state.featsAndTraits.numVindicationCharges.set(value)
                        end,
                        hidden = function()
                            return not rules.offence.canProcVindication()
                        end,
                    },
                }
            },
            updateTRP = {
                order = 4,
                type = "execute",
                name = "Update Total RP",
                desc = "Update your Total RP 'Currently' with your current/max HP",
                hidden = function()
                    return not integrations.TRP or TEARollHelper.db.global.settings.autoUpdateTRP
                end,
                disabled = function()
                    return TEARollHelper.db.global.settings.autoUpdateTRP
                end,
                func = function()
                    integrations.TRP.updateCurrently()
                    TEARollHelper:Print("Updated your Total RP profile.")
                end,
            },
            autoUpdateTRPNote = {
                order = 5,
                type = "description",
                name = COLOURS.NOTE .. " |nYour Total RP is set to update automatically when needed.",
                hidden = function()
                    return not (integrations.TRP and TEARollHelper.db.global.settings.autoUpdateTRP)
                end,
            }
        }
    }
end