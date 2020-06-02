local _, ns = ...

local actions = ns.actions
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character.state
local feats = ns.resources.feats
local rolls = ns.state.rolls
local traits = ns.resources.traits
local turns = ns.turns

local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local state

rolls.initState = function()
    state = {
        attack = {
            threshold = 12,
            numBloodHarvestSlots = 0,
            rollMode = turns.ROLL_MODES.NORMAL,
            currentRoll = nil,
            prepMode = false,
            currentPreppedRoll = nil,
        },

        healing = {
            numGreaterHealSlots = 0,
            mercyFromPainBonusHealing = 0,
            rollMode = turns.ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        buff = {
            rollMode = turns.ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        defend = {
            threshold = 10,
            damageRisk = 4,
            useBulwark = false,
            rollMode = turns.ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        meleeSave = {
            rollMode = turns.ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        rangedSave = {
            rollMode = turns.ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        utility = {
            useUtilityTrait = false,
            rollMode = turns.ROLL_MODES.NORMAL,
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

rolls.state = {
    attack = {
        threshold = basicGetSet("attack", "threshold"),
        numBloodHarvestSlots = basicGetSet("attack", "numBloodHarvestSlots"),
        rollMode = basicGetSet("attack", "rollMode"),
        currentRoll = basicGetSet("attack", "currentRoll"),
        prepMode = basicGetSet("attack", "prepMode", function(prepMode)
            if not prepMode then
                rolls.state.attack.currentPreppedRoll.set(nil)
            end
        end),
        currentPreppedRoll = basicGetSet("attack", "currentPreppedRoll"),
    },

    healing = {
        numGreaterHealSlots = basicGetSet("healing", "numGreaterHealSlots"),
        mercyFromPainBonusHealing = basicGetSet("healing", "mercyFromPainBonusHealing"),
        rollMode = basicGetSet("healing", "rollMode"),
        currentRoll = basicGetSet("healing", "currentRoll"),
    },

    buff = {
        rollMode = basicGetSet("buff", "rollMode"),
        currentRoll = basicGetSet("buff", "currentRoll"),
    },

    defend = {
        threshold = basicGetSet("defend", "threshold"),
        damageRisk = basicGetSet("defend", "damageRisk"),
        useBulwark = basicGetSet("defend", "useBulwark"),
        rollMode = basicGetSet("defend", "rollMode"),
        currentRoll = basicGetSet("defend", "currentRoll"),
    },

    meleeSave = {
        rollMode = basicGetSet("meleeSave", "rollMode"),
        currentRoll = basicGetSet("meleeSave", "currentRoll"),
    },

    rangedSave = {
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
    rolls.state.healing.mercyFromPainBonusHealing.set(0)
    rolls.state.defend.useBulwark.set(false)
end

local function resetRolls()
    rolls.state.attack.currentRoll.set(nil)
    rolls.state.attack.prepMode.set(false)
    rolls.state.attack.currentPreppedRoll.set(nil)
    rolls.state.healing.currentRoll.set(nil)
    rolls.state.buff.currentRoll.set(nil)
    rolls.state.defend.currentRoll.set(nil)
    rolls.state.meleeSave.currentRoll.set(nil)
    rolls.state.rangedSave.currentRoll.set(nil)
    rolls.state.utility.currentRoll.set(nil)
end

bus.addListener(EVENTS.CHARACTER_STAT_CHANGED, resetSlots)
bus.addListener(EVENTS.FEAT_CHANGED, function()
    resetSlots()
    resetRolls() -- in case of crit threshold change
end)
bus.addListener(EVENTS.TRAITS_CHANGED, resetSlots)
bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, resetRolls) -- in case of crit threshold change
bus.addListener(EVENTS.TURN_CHANGED, function()
    resetSlots()
    resetRolls()
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

bus.addListener(EVENTS.TRAIT_CHARGES_CHANGED, function(traitID, numCharges)
    if traitID == TRAITS.BULWARK.id and numCharges == 0 then
        rolls.state.defend.useBulwark.set(false)
    end
end)

bus.addListener(EVENTS.ROLL_CHANGED, function(action, roll)
    rolls.state[action].currentRoll.set(roll)
end)

bus.addListener(EVENTS.PREPPED_ROLL_CHANGED, function(action, roll)
    rolls.state[action].currentPreppedRoll.set(roll)
end)

local function getAttack()
    local offence = character.getPlayerOffence()
    local buff = characterState.buffs.offence.get()
    local threshold = state.attack.threshold
    local numBloodHarvestSlots = state.attack.numBloodHarvestSlots
    local numVindicationCharges = characterState.featsAndTraits.numVindicationCharges.get()

    return actions.getAttack(state.attack.currentRoll, state.attack.currentPreppedRoll, threshold, offence, buff, numBloodHarvestSlots, numVindicationCharges)
end

local function getHealing(outOfCombat)
    local spirit = character.getPlayerSpirit()
    local buff = characterState.buffs.spirit.get()

    return actions.getHealing(state.healing.currentRoll, spirit, buff, state.healing.numGreaterHealSlots, state.healing.mercyFromPainBonusHealing, outOfCombat)
end

local function getBuff()
    local spirit = character.getPlayerSpirit()
    local offence = character.getPlayerOffence()
    local offenceBuff = characterState.buffs.offence.get()
    local spiritBuff = characterState.buffs.spirit.get()

    return actions.getBuff(state.buff.currentRoll, spirit, spiritBuff, offence, offenceBuff)
end

local function getDefence()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()
    local useBulwark = state.defend.useBulwark

    return actions.getDefence(state.defend.currentRoll, state.defend.threshold, state.defend.damageRisk, defence, buff, useBulwark)
end

local function getMeleeSave()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()

    return actions.getMeleeSave(state.meleeSave.currentRoll, state.defend.threshold, state.defend.damageRisk, defence, buff)
end

local function getRangedSave()
    local spirit = character.getPlayerSpirit()
    local buff = characterState.buffs.spirit.get()

    return actions.getRangedSave(state.rangedSave.currentRoll, state.defend.threshold, state.defend.damageRisk, spirit, buff)
end

rolls.getAttack = getAttack
rolls.getHealing = getHealing
rolls.getBuff = getBuff
rolls.getDefence = getDefence
rolls.getMeleeSave = getMeleeSave
rolls.getRangedSave = getRangedSave