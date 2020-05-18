local _, ns = ...

local character = ns.character
local rules = ns.rules
local characterState = ns.state.character

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local state

local function notifyChange(isExternal)
    if isExternal then
        AceConfigRegistry:NotifyChange(ns.ui.modules.turn.name)
    end
end

characterState.initState = function()
    state = {
        health = character.getPlayerMaxHP(),

        healing = {
            numGreaterHealSlots = rules.healing.getMaxGreaterHealSlots(),
            excess = 0,
        },

        featsAndTraits = {
            numBloodHarvestSlots = rules.offence.getMaxBloodHarvestSlots(),
        },
    }
end

characterState.state = {
    health = {
        get = function()
            return state.health
        end,
        set = function(health, isExternal)
            state.health = health
            notifyChange(isExternal)
        end,
        subtract = function(health, isExternal)
            state.health = state.health - health
            notifyChange(isExternal)
        end
    },
    healing = {
        numGreaterHealSlots = {
            get = function ()
                return state.healing.numGreaterHealSlots
            end,
            set = function (numGreaterHealSlots)
                state.healing.numGreaterHealSlots = numGreaterHealSlots
            end
        },
        excess = {
            get = function ()
                return state.healing.excess
            end,
            set = function (excess)
                state.healing.excess = excess
            end
        },
    },
    featsAndTraits = {
        numBloodHarvestSlots = {
            get = function ()
                return state.featsAndTraits.numBloodHarvestSlots
            end,
            set = function (numBloodHarvestSlots)
                state.featsAndTraits.numBloodHarvestSlots = numBloodHarvestSlots
            end
        }
    }
}