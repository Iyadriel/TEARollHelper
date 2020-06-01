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
        },

        healing = {
            numGreaterHealSlots = 0,
            mercyFromPainBonusHealing = 0,
            rollMode = turns.ROLL_MODES.NORMAL,
        },

        buff = {
            rollMode = turns.ROLL_MODES.NORMAL,
        },

        defend = {
            threshold = 10,
            damageRisk = 4,
            useBulwark = false,
            rollMode = turns.ROLL_MODES.NORMAL,
        },

        meleeSave = {
            rollMode = turns.ROLL_MODES.NORMAL,
        },

        rangedSave = {
            rollMode = turns.ROLL_MODES.NORMAL,
        },

        utility = {
            useUtilityTrait = false,
            rollMode = turns.ROLL_MODES.NORMAL,
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
    },

    healing = {
        numGreaterHealSlots = basicGetSet("healing", "numGreaterHealSlots"),
        mercyFromPainBonusHealing = basicGetSet("healing", "mercyFromPainBonusHealing"),
        rollMode = basicGetSet("healing", "rollMode"),
    },

    buff = {
        rollMode = basicGetSet("buff", "rollMode"),
    },

    defend = {
        threshold = basicGetSet("defend", "threshold"),
        damageRisk = basicGetSet("defend", "damageRisk"),
        useBulwark = basicGetSet("defend", "useBulwark"),
        rollMode = basicGetSet("defend", "rollMode"),
    },

    meleeSave = {
        rollMode = basicGetSet("meleeSave", "rollMode"),
    },

    rangedSave = {
        rollMode = basicGetSet("rangedSave", "rollMode"),
    },

    utility = {
        useUtilityTrait = basicGetSet("utility", "useUtilityTrait"),
        rollMode = basicGetSet("utility", "rollMode"),
    },
}

local function resetSlots()
    rolls.state.attack.numBloodHarvestSlots.set(0)
    rolls.state.healing.numGreaterHealSlots.set(0)
    rolls.state.healing.mercyFromPainBonusHealing.set(0)
    rolls.state.defend.useBulwark.set(false)
end

bus.addListener(EVENTS.CHARACTER_STAT_CHANGED, resetSlots)
bus.addListener(EVENTS.FEAT_CHANGED, resetSlots)
bus.addListener(EVENTS.TRAITS_CHANGED, resetSlots)
bus.addListener(EVENTS.TURN_CHANGED, resetSlots)

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

local function getAttack()
    local offence = character.getPlayerOffence()
    local buff = characterState.buffs.offence.get()
    local values = turns.getRollValues()
    local threshold = state.attack.threshold
    local numBloodHarvestSlots = state.attack.numBloodHarvestSlots
    local numVindicationCharges = characterState.featsAndTraits.numVindicationCharges.get()

    return actions.getAttack(values.roll, values.preppedRoll, threshold, offence, buff, numBloodHarvestSlots, numVindicationCharges)
end

local function getHealing(outOfCombat)
    local spirit = character.getPlayerSpirit()
    local buff = characterState.buffs.spirit.get()
    local values = turns.getRollValues()

    return actions.getHealing(values.roll, spirit, buff, state.healing.numGreaterHealSlots, state.healing.mercyFromPainBonusHealing, outOfCombat)
end

local function getBuff()
    local spirit = character.getPlayerSpirit()
    local offence = character.getPlayerOffence()
    local offenceBuff = characterState.buffs.offence.get()
    local spiritBuff = characterState.buffs.spirit.get()
    local values = turns.getRollValues()

    return actions.getBuff(values.roll, spirit, spiritBuff, offence, offenceBuff)
end

local function getDefence()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()
    local values = turns.getRollValues()
    local useBulwark = state.defend.useBulwark

    return actions.getDefence(values.roll, state.defend.threshold, state.defend.damageRisk, defence, buff, useBulwark)
end

local function getMeleeSave()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()
    local values = turns.getRollValues()

    return actions.getMeleeSave(values.roll, state.defend.threshold, state.defend.damageRisk, defence, buff)
end

local function getRangedSave()
    local spirit = character.getPlayerSpirit()
    local values = turns.getRollValues()
    local buff = characterState.buffs.spirit.get()

    return actions.getRangedSave(values.roll, state.defend.threshold, state.defend.damageRisk, spirit, buff)
end

rolls.getAttack = getAttack
rolls.getHealing = getHealing
rolls.getBuff = getBuff
rolls.getDefence = getDefence
rolls.getMeleeSave = getMeleeSave
rolls.getRangedSave = getRangedSave