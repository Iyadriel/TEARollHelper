local _, ns = ...

local actions = ns.actions
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character.state
local constants = ns.constants
local environment = ns.state.environment
local feats = ns.resources.feats
local rolls = ns.state.rolls
local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local BUFF_TYPES = constants.BUFF_TYPES
local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local ROLL_MODES = constants.ROLL_MODES
local STATS = constants.STATS
local TRAITS = traits.TRAITS

local state

rolls.initState = function()
    state = {
        shared = {
            versatile = {
                stat1 = STATS.offence,
                stat2 = STATS.spirit,
            }
        },

        [ACTIONS.attack] = {
            threshold = nil,
            numBloodHarvestSlots = 0,
            isAOE = false,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.cc] = {
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.healing] = {
            numGreaterHealSlots = 0,
            targetIsKO = false,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.buff] = {
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.defend] = {
            threshold = nil,
            damageType = nil,
            damageRisk = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.meleeSave] = {
            threshold = nil,
            damageType = nil,
            damageRisk = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.rangedSave] = {
            threshold = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.utility] = {
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

rolls.state = {
    shared = {
        versatile = {
            stat1 = {
                get = function()
                    return state.shared.versatile.stat1
                end,
                set = function(value)
                    state.shared.versatile.stat1 = value
                end
            },
            stat2 = {
                get = function()
                    return state.shared.versatile.stat2
                end,
                set = function(value)
                    state.shared.versatile.stat2 = value
                end
            },
        },
    },

    [ACTIONS.attack] = {
        threshold = basicGetSet(ACTIONS.attack, "threshold"),
        numBloodHarvestSlots = basicGetSet(ACTIONS.attack, "numBloodHarvestSlots"),
        isAOE = basicGetSet(ACTIONS.attack, "isAOE"),
        rollMode = basicGetSet(ACTIONS.attack, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.attack, "currentRoll"),
    },

    [ACTIONS.cc] = {
        rollMode = basicGetSet(ACTIONS.cc, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.cc, "currentRoll"),
    },

    [ACTIONS.healing] = {
        numGreaterHealSlots = basicGetSet(ACTIONS.healing, "numGreaterHealSlots"),
        targetIsKO = basicGetSet(ACTIONS.healing, "targetIsKO"),
        rollMode = basicGetSet(ACTIONS.healing, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.healing, "currentRoll"),
    },

    [ACTIONS.buff] = {
        rollMode = basicGetSet(ACTIONS.buff, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.buff, "currentRoll"),
    },

    [ACTIONS.defend] = {
        threshold = basicGetSet(ACTIONS.defend, "threshold"),
        damageType = basicGetSet(ACTIONS.defend, "damageType"),
        damageRisk = basicGetSet(ACTIONS.defend, "damageRisk"),
        rollMode = basicGetSet(ACTIONS.defend, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.defend, "currentRoll"),
    },

    [ACTIONS.meleeSave] = {
        threshold = basicGetSet(ACTIONS.meleeSave, "threshold"),
        damageType = basicGetSet(ACTIONS.meleeSave, "damageType"),
        damageRisk = basicGetSet(ACTIONS.meleeSave, "damageRisk"),
        rollMode = basicGetSet(ACTIONS.meleeSave, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.meleeSave, "currentRoll"),
    },

    [ACTIONS.rangedSave] = {
        threshold = basicGetSet(ACTIONS.rangedSave, "threshold"),
        rollMode = basicGetSet(ACTIONS.rangedSave, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.rangedSave, "currentRoll"),
    },

    [ACTIONS.utility] = {
        useUtilityTrait = basicGetSet(ACTIONS.utility, "useUtilityTrait"),
        rollMode = basicGetSet(ACTIONS.utility, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.utility, "currentRoll"),
    },
}

local function resetSlots()
    rolls.state.attack.numBloodHarvestSlots.set(0)
    rolls.state.attack.isAOE.set(false)
    rolls.state.healing.numGreaterHealSlots.set(0)
    rolls.state.healing.targetIsKO.set(false)
    rolls.state.utility.useUtilityTrait.set(false)
end

local function resetRolls()
    for _, action in pairs(ACTIONS) do
        local actionState = rolls.state[action]
        actionState.currentRoll.set(nil)
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
bus.addListener(EVENTS.WEAKNESSES_CHANGED, resetSlots)
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

bus.addListener(EVENTS.REROLLED, function(action, roll)
    local currentRoll = rolls.state[action].currentRoll.get()

    if roll > currentRoll then
        rolls.state[action].currentRoll.set(roll)
    end
end)

local function getAttack()
    local offence = character.getPlayerOffence()
    local offenceBuff = characterState.buffs.offence.get()
    local baseDmgBuff = characterState.buffLookup.getPlayerBaseDmgBuff()
    local baseDmgBuffAmount = baseDmgBuff and baseDmgBuff.amount or 0
    local enemyId = environment.state.enemyId.get()
    local isAOE = state.attack.isAOE
    local threshold = state.attack.threshold
    local numBloodHarvestSlots = state.attack.numBloodHarvestSlots
    local numVindicationCharges = characterState.featsAndTraits.numTraitCharges.get(TRAITS.VINDICATION.id)

    return actions.getAttack(state.attack.currentRoll, threshold, offence, offenceBuff, baseDmgBuffAmount, enemyId, isAOE, numBloodHarvestSlots, numVindicationCharges)
end

local function getCC()
    local offence = character.getPlayerOffence()
    local offenceBuff = characterState.buffs.offence.get()
    local defence = character.getPlayerDefence()
    local defenceBuff = characterState.buffs.defence.get()

    return actions.getCC(state.cc.currentRoll, offence, offenceBuff, defence, defenceBuff)
end

local function getHealing(outOfCombat)
    local spirit = character.getPlayerSpirit()
    local spiritBuff = characterState.buffs.spirit.get()

    local healingDoneBuffs = characterState.buffLookup.getBuffsOfType(BUFF_TYPES.HEALING_DONE)
    local healingDoneBuff = 0
    for _, buff in ipairs(healingDoneBuffs) do
        healingDoneBuff = healingDoneBuff + buff.amount
    end


    return actions.getHealing(state.healing.currentRoll, spirit, spiritBuff, healingDoneBuff, state.healing.numGreaterHealSlots, state.healing.targetIsKO, outOfCombat)
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

    return actions.getDefence(state.defend.currentRoll, state.defend.threshold, state.defend.damageType, state.defend.damageRisk, defence, buff)
end

local function getMeleeSave()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()

    return actions.getMeleeSave(state.meleeSave.currentRoll, state.meleeSave.threshold, state.meleeSave.damageType, state.meleeSave.damageRisk, defence, buff)
end

local function getRangedSave()
    local spirit = character.getPlayerSpirit()
    local buff = characterState.buffs.spirit.get()

    return actions.getRangedSave(state.rangedSave.currentRoll, state.rangedSave.threshold, spirit, buff)
end

rolls.getAttack = getAttack
rolls.getCC = getCC
rolls.getHealing = getHealing
rolls.getBuff = getBuff
rolls.getDefence = getDefence
rolls.getMeleeSave = getMeleeSave
rolls.getRangedSave = getRangedSave