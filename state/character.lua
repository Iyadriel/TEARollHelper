local _, ns = ...

local bus = ns.bus
local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits
local characterState = ns.state.character
local turnState = ns.state.turn

local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
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

local function basicGetSet(section, key, callback)
    return {
        get = function ()
            return state[section][key]
        end,
        set = function (value)
            state[section][key] = value
            if callback then callback(value) end
        end
    }
end

local function summariseState()
    local out = {
        characterState.state.health.get(),
        "/",
        character.getPlayerMaxHP(),
        " HP",
--[[         "|n|n|nFeat: ",
        character.getPlayerFeat().name,
        "|n|n|nGreater Heal slots: ",
        state.healing.numGreaterHealSlots.get(),
        "/",
        rules.healing.getMaxGreaterHealSlots() ]]
    }

    return table.concat(out)
end

characterState.state = {
    health = {
        get = function()
            return state.health
        end,
        set = function(health)
            state.health = health
            bus.fire(EVENTS.CHARACTER_HEALTH, state.health)
        end,
        subtract = function(health)
            state.health = state.health - health
            bus.fire(EVENTS.CHARACTER_HEALTH, state.health)
        end
    },
    healing = {
        numGreaterHealSlots = basicGetSet("healing", "numGreaterHealSlots"),
        excess = basicGetSet("healing", "excess"),
    },
    featsAndTraits = {
        numBloodHarvestSlots = basicGetSet("featsAndTraits", "numBloodHarvestSlots", function(numCharges)
            bus.fire(EVENTS.FEAT_CHARGES_CHANGED, FEATS.BLOOD_HARVEST.id, numCharges)
        end),
        numSecondWindCharges = basicGetSet("featsAndTraits", "numSecondWindCharges"),
        numVindicationCharges = basicGetSet("featsAndTraits", "numVindicationCharges"),
    },
    buffs = {
        offence = basicGetSet("buffs", "offence"),
        defence = basicGetSet("buffs", "defence"),
        spirit = basicGetSet("buffs", "spirit"),
    }
}

characterState.summariseState = summariseState

bus.addListener(EVENTS.COMBAT_OVER, function()
    local getCharges = characterState.state.featsAndTraits.numSecondWindCharges.get

    local oldNumCharges = getCharges()
    characterState.state.featsAndTraits.numSecondWindCharges.set(TRAITS.SECOND_WIND.numCharges)
    if getCharges() ~= oldNumCharges then
        TEARollHelper:Print(TEARollHelper.COLOURS.TRAITS.GENERIC .. TRAITS.SECOND_WIND.name .. " charge restored.")
    end
end)

bus.addListener(EVENTS.CHARACTER_STAT_CHANGED, function(stat, value)
    if stat == "offence" then
        local remainingSlots = characterState.state.featsAndTraits.numBloodHarvestSlots.get()
        local maxSlots = rules.offence.getMaxBloodHarvestSlots()
        if remainingSlots > maxSlots then
            characterState.state.featsAndTraits.numBloodHarvestSlots.set(maxSlots)
            TEARollHelper:Debug("Reduced remaining " .. FEATS.BLOOD_HARVEST.name .. " charges because offence stat changed.")
        elseif remainingSlots < maxSlots and not turnState.state.inCombat.get() then
            characterState.state.featsAndTraits.numBloodHarvestSlots.set(maxSlots)
            TEARollHelper:Debug("Increased remaining " .. FEATS.BLOOD_HARVEST.name .. " charges because offence stat changed.")
        end
    end
end)