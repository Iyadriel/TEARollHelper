local _, ns = ...

local character = ns.character
local rules = ns.rules
local traits = ns.resources.traits
local characterState = ns.state.character

local TRAITS = traits.TRAITS
local state

characterState.initState = function()
    state = {
        health = character.getPlayerMaxHP(),

        healing = {
            numGreaterHealSlots = rules.healing.getMaxGreaterHealSlots(),
            excess = 0,
        },

        featsAndTraits = {
            numBloodHarvestSlots = rules.offence.getMaxBloodHarvestSlots(),
            numSecondWindCharges = TRAITS.SECOND_WIND.numCharges,
            numVindicationCharges = TRAITS.VINDICATION.numCharges,
        },

        buffs = {
            offence = 0,
            defence = 0,
            spirit = 0
        }
    }
end

local function basicGetSet(section, key)
    return {
        get = function ()
            return state[section][key]
        end,
        set = function (value)
            state[section][key] = value
        end
    }
end

characterState.state = {
    health = {
        get = function()
            return state.health
        end,
        set = function(health)
            state.health = health
        end,
        subtract = function(health)
            state.health = state.health - health
        end
    },
    healing = {
        numGreaterHealSlots = basicGetSet("healing", "numGreaterHealSlots"),
        excess = basicGetSet("healing", "excess"),
    },
    featsAndTraits = {
        numBloodHarvestSlots = basicGetSet("featsAndTraits", "numBloodHarvestSlots"),
        numSecondWindCharges = basicGetSet("featsAndTraits", "numSecondWindCharges"),
        numVindicationCharges = basicGetSet("featsAndTraits", "numVindicationCharges"),
    },
    buffs = {
        offence = basicGetSet("buffs", "offence"),
        defence = basicGetSet("buffs", "defence"),
        spirit = basicGetSet("buffs", "spirit"),
    }
}

-- TODO: handle this better, this is more of a rule thing
local function onCombatStatusChange(inCombat)
    if not inCombat then
        local getCharges = characterState.state.featsAndTraits.numSecondWindCharges.get

        local oldNumCharges = getCharges()
        characterState.state.featsAndTraits.numSecondWindCharges.set(TRAITS.SECOND_WIND.numCharges)
        if getCharges() ~= oldNumCharges then
            TEARollHelper:Print(TEARollHelper.COLOURS.TRAITS.GENERIC .. TRAITS.SECOND_WIND.name .. " charge restored.")
        end
    end
end

characterState.onCombatStatusChange = onCombatStatusChange