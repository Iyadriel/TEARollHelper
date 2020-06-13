local _, ns = ...

local actions = ns.actions
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character.state
local constants = ns.constants
local enemies = ns.resources.enemies
local feats = ns.resources.feats
local rolls = ns.state.rolls
local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local ROLL_MODES = constants.ROLL_MODES
local TRAITS = traits.TRAITS

local state

rolls.initState = function()
    state = {
        attack = {
            threshold = nil,
            numBloodHarvestSlots = 0,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
            prepMode = false,
            currentPreppedRoll = nil,
        },

        healing = {
            numGreaterHealSlots = 0,
            lifePulse = false,
            mercyFromPainBonusHealing = 0,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
            prepMode = false,
            currentPreppedRoll = nil,
        },

        buff = {
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
            prepMode = false,
            currentPreppedRoll = nil,
        },

        defend = {
            threshold = nil,
            damageRisk = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        meleeSave = {
            threshold = nil,
            damageRisk = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        rangedSave = {
            threshold = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        utility = {
            useUtilityTrait = false,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },
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

local function clearPreppedRoll(action)
    return function(prepMode)
        if not prepMode then
            rolls.state[action].currentPreppedRoll.set(nil)
        end
    end
end

rolls.state = {
    attack = {
        threshold = basicGetSet("attack", "threshold"),
        numBloodHarvestSlots = basicGetSet("attack", "numBloodHarvestSlots"),
        rollMode = basicGetSet("attack", "rollMode"),
        currentRoll = basicGetSet("attack", "currentRoll"),
        prepMode = basicGetSet("attack", "prepMode", clearPreppedRoll("attack")),
        currentPreppedRoll = basicGetSet("attack", "currentPreppedRoll"),
    },

    healing = {
        numGreaterHealSlots = basicGetSet("healing", "numGreaterHealSlots"),
        lifePulse = basicGetSet("healing", "lifePulse"),
        mercyFromPainBonusHealing = basicGetSet("healing", "mercyFromPainBonusHealing"),
        rollMode = basicGetSet("healing", "rollMode"),
        currentRoll = basicGetSet("healing", "currentRoll"),
        prepMode = basicGetSet("healing", "prepMode", clearPreppedRoll("healing")),
        currentPreppedRoll = basicGetSet("healing", "currentPreppedRoll"),
    },

    buff = {
        rollMode = basicGetSet("buff", "rollMode"),
        currentRoll = basicGetSet("buff", "currentRoll"),
        prepMode = basicGetSet("buff", "prepMode", clearPreppedRoll("buff")),
        currentPreppedRoll = basicGetSet("buff", "currentPreppedRoll"),
    },

    defend = {
        threshold = basicGetSet("defend", "threshold"),
        damageRisk = basicGetSet("defend", "damageRisk"),
        rollMode = basicGetSet("defend", "rollMode"),
        currentRoll = basicGetSet("defend", "currentRoll"),
    },

    meleeSave = {
        threshold = basicGetSet("meleeSave", "threshold"),
        damageRisk = basicGetSet("meleeSave", "damageRisk"),
        rollMode = basicGetSet("meleeSave", "rollMode"),
        currentRoll = basicGetSet("meleeSave", "currentRoll"),
    },

    rangedSave = {
        threshold = basicGetSet("rangedSave", "threshold"),
        rollMode = basicGetSet("rangedSave", "rollMode"),
        currentRoll = basicGetSet("rangedSave", "currentRoll"),
    },

    utility = {
        useUtilityTrait = basicGetSet("utility", "useUtilityTrait"),
        rollMode = basicGetSet("utility", "rollMode"),
        currentRoll = basicGetSet("utility", "currentRoll"),
    },
}

local function resetSlots()
    rolls.state.attack.numBloodHarvestSlots.set(0)
    rolls.state.healing.numGreaterHealSlots.set(0)
    rolls.state.healing.lifePulse.set(false)
    rolls.state.healing.mercyFromPainBonusHealing.set(0)
end

local function resetRolls()
    for _, action in pairs(ACTIONS) do
        local actionState = rolls.state[action]

        actionState.currentRoll.set(nil)
        if actionState.prepMode then
            actionState.prepMode.set(false)
            actionState.currentPreppedRoll.set(nil)
        end
    end
end

local function resetThresholds()
    rolls.state.attack.threshold.set(nil)
    rolls.state.defend.threshold.set(nil)
    rolls.state.defend.damageRisk.set(nil)
    rolls.state.meleeSave.threshold.set(nil)
    rolls.state.meleeSave.damageRisk.set(nil)
    rolls.state.rangedSave.threshold.set(nil)
end

bus.addListener(EVENTS.CHARACTER_STAT_CHANGED, resetSlots)
bus.addListener(EVENTS.FEAT_CHANGED, function()
    resetSlots()
    resetRolls() -- in case of crit threshold change
end)
bus.addListener(EVENTS.TRAITS_CHANGED, resetSlots)
bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, resetRolls) -- in case of crit threshold change
bus.addListener(EVENTS.TURN_STARTED, function()
    resetSlots()
    resetRolls()
    resetThresholds()
end)

bus.addListener(EVENTS.FEAT_CHARGES_CHANGED, function(featID, numCharges)
    if featID == FEATS.BLOOD_HARVEST.id and numCharges < state.attack.numBloodHarvestSlots then
        rolls.state.attack.numBloodHarvestSlot.set(numCharges)
    end
end)
bus.addListener(EVENTS.GREATER_HEAL_CHARGES_CHANGED, function(numCharges)
    if numCharges < state.healing.numGreaterHealSlots then
        rolls.state.healing.numGreaterHealSlots.set(numCharges)
    end
end)

bus.addListener(EVENTS.ROLL_CHANGED, function(action, roll)
    rolls.state[action].currentRoll.set(roll)
end)

bus.addListener(EVENTS.PREPPED_ROLL_CHANGED, function(action, roll)
    rolls.state[action].currentPreppedRoll.set(roll)
end)

bus.addListener(EVENTS.REROLLED, function(action, roll)
    local currentRoll = rolls.state[action].currentRoll.get()
    local currentPreppedRoll
    if rolls.state[action].currentPreppedRoll then
        currentPreppedRoll = rolls.state[action].currentPreppedRoll.get()
    end

    if currentPreppedRoll then
        -- when rerolling, we can replace either the current or the prepped roll, so check which is the lowest.
        if roll > min(currentRoll, currentPreppedRoll) then
            if currentRoll <= currentPreppedRoll then
                rolls.state[action].currentRoll.set(roll)
            else
                rolls.state[action].currentPreppedRoll.set(roll)
            end
        end
    else
        if roll > currentRoll then
            rolls.state[action].currentRoll.set(roll)
        end
    end
end)

local function getAttack()
    local offence = character.getPlayerOffence()
    local buff = characterState.buffs.offence.get()
    local threshold = state.attack.threshold
    local numBloodHarvestSlots = state.attack.numBloodHarvestSlots
    local numVindicationCharges = characterState.featsAndTraits.numTraitCharges.get(TRAITS.VINDICATION.id)

    return actions.getAttack(state.attack.currentRoll, state.attack.currentPreppedRoll, threshold, offence, buff, numBloodHarvestSlots, numVindicationCharges)
end

local function getHealing(outOfCombat)
    local spirit = character.getPlayerSpirit()
    local buff = characterState.buffs.spirit.get()

    return actions.getHealing(state.healing.currentRoll, state.healing.currentPreppedRoll, spirit, buff, state.healing.numGreaterHealSlots, state.healing.lifePulse, state.healing.mercyFromPainBonusHealing, outOfCombat)
end

local function getBuff()
    local spirit = character.getPlayerSpirit()
    local offence = character.getPlayerOffence()
    local offenceBuff = characterState.buffs.offence.get()
    local spiritBuff = characterState.buffs.spirit.get()

    return actions.getBuff(state.buff.currentRoll, state.buff.currentPreppedRoll, spirit, spiritBuff, offence, offenceBuff)
end

local function getDefence()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()

    return actions.getDefence(state.defend.currentRoll, state.defend.threshold, state.defend.damageRisk, defence, buff)
end

local function getMeleeSave()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()

    return actions.getMeleeSave(state.meleeSave.currentRoll, state.meleeSave.threshold, state.meleeSave.damageRisk, defence, buff)
end

local function getRangedSave()
    local spirit = character.getPlayerSpirit()
    local buff = characterState.buffs.spirit.get()

    return actions.getRangedSave(state.rangedSave.currentRoll, state.rangedSave.threshold, spirit, buff)
end

rolls.getAttack = getAttack
rolls.getHealing = getHealing
rolls.getBuff = getBuff
rolls.getDefence = getDefence
rolls.getMeleeSave = getMeleeSave
rolls.getRangedSave = getRangedSave