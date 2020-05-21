local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local integrations = ns.integrations
local rules = ns.rules
local characterState = ns.state.character
local ui = ns.ui

local state = characterState.state

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.character.getOptions = function(options)
    return {
        type = "group",
        name = "Character",
        desc = "The current state of your character",
        inline = true,
        order = options.order,
        args = {
            turn_character_hp = {
                order = 0,
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
                    max = character.getPlayerMaxHP,
                    set = state.health.set
                })
            },
            healing = {
                order = 1 ,
                type = "group",
                name = "Healing",
                inline = true,
                args = {
                    turn_character_numGreaterHealSlots = {
                        order = 0,
                        type = "range",
                        name = "Greater Heal slots",
                        desc = "How many Greater Heals you have left",
                        min = 0,
                        max = rules.healing.getMaxGreaterHealSlots(),
                        step = 1,
                        get = state.healing.numGreaterHealSlots.get,
                        set = function(info, value)
                            state.healing.numGreaterHealSlots.set(value)
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("turn_character_numGreaterHealSlots", {
                            max = rules.healing.getMaxGreaterHealSlots,
                            set = state.healing.numGreaterHealSlots.set
                        })
                    },
                    excess = {
                        order = 1,
                        type = "range",
                        name = "Excess",
                        desc = "How much Excess you have gained",
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
                order = 2,
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
                            max = rules.offence.getMaxBloodHarvestSlots,
                            set = state.featsAndTraits.numBloodHarvestSlots.set
                        })
                    },
                }
            },
            updateTRP = {
                type = "execute",
                name = "Update TRP",
                desc = "Update your TRP 'Currently' with your current/max HP",
                hidden = function()
                    return not integrations.TRP
                end,
                func = function()
                    local out = {
                        state.health.get(),
                        "/",
                        character.getPlayerMaxHP(),
                        " HP",
--[[                         "|n|n|nFeat: ",
                        character.getPlayerFeat().name,
                        "|n|n|nGreater Heal slots: ",
                        state.healing.numGreaterHealSlots.get(),
                        "/",
                        rules.healing.getMaxGreaterHealSlots() ]]
                    }

                    local text = table.concat(out)

                    integrations.TRP.setCurrently(text)

                    --return table.concat(out)
                end,
                order = 3,
            }
        }
    }
end