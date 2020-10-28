local _, ns = ...

local actions = ns.actions
local buffsState = ns.state.buffs.state
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character.state
local constants = ns.constants
local environment = ns.state.environment
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local DEFENCE_TYPES = constants.DEFENCE_TYPES
local EVENTS = bus.EVENTS
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
            attacks = {},
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
            defenceType = DEFENCE_TYPES.THRESHOLD,
            threshold = nil,
            damageType = nil,
            damageRisk = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.meleeSave] = {
            defenceType = DEFENCE_TYPES.THRESHOLD,
            threshold = nil,
            damageType = nil,
            damageRisk = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.rangedSave] = {
            defenceType = DEFENCE_TYPES.THRESHOLD,
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
        attacks = {
            get = function()
                return state.attack.attacks
            end,
            count = function()
                return #state.attack.attacks
            end,
            add = function(attack)
                table.insert(state.attack.attacks, attack)
            end,
            clear = function()
                state.attack.attacks = {}
            end,
        },
        threshold = basicGetSet(ACTIONS.attack, "threshold"),
        numBloodHarvestSlots = basicGetSet(ACTIONS.attack, "numBloodHarvestSlots"),
        isAOE = basicGetSet(ACTIONS.attack, "isAOE"),
        rollMode = basicGetSet(ACTIONS.attack, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.attack, "currentRoll"),

        resetSlots = function()
            TEARollHelper:Debug("Resetting slots for attack")
            rolls.state.attack.numBloodHarvestSlots.set(0)
            rolls.state.attack.isAOE.set(false)
        end,
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

        resetSlots = function()
            TEARollHelper:Debug("Resetting slots for healing")
            rolls.state.healing.numGreaterHealSlots.set(0)
            rolls.state.healing.targetIsKO.set(false)
        end,
    },

    [ACTIONS.buff] = {
        rollMode = basicGetSet(ACTIONS.buff, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.buff, "currentRoll"),
    },

    [ACTIONS.defend] = {
        defenceType = basicGetSet(ACTIONS.defend, "defenceType", function(defenceType)
            if defenceType ~= DEFENCE_TYPES.THRESHOLD then
                rolls.state[ACTIONS.defend].threshold.set(0)
            end
        end),
        threshold = basicGetSet(ACTIONS.defend, "threshold"),
        damageType = basicGetSet(ACTIONS.defend, "damageType"),
        damageRisk = basicGetSet(ACTIONS.defend, "damageRisk"),
        rollMode = basicGetSet(ACTIONS.defend, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.defend, "currentRoll"),
    },

    [ACTIONS.meleeSave] = {
        defenceType = basicGetSet(ACTIONS.meleeSave, "defenceType", function(defenceType)
            if defenceType ~= DEFENCE_TYPES.THRESHOLD then
                rolls.state[ACTIONS.meleeSave].threshold.set(0)
            end
        end),
        threshold = basicGetSet(ACTIONS.meleeSave, "threshold"),
        damageType = basicGetSet(ACTIONS.meleeSave, "damageType"),
        damageRisk = basicGetSet(ACTIONS.meleeSave, "damageRisk"),
        rollMode = basicGetSet(ACTIONS.meleeSave, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.meleeSave, "currentRoll"),
    },

    [ACTIONS.rangedSave] = {
        defenceType = basicGetSet(ACTIONS.rangedSave, "defenceType", function(defenceType)
            if defenceType ~= DEFENCE_TYPES.THRESHOLD then
                rolls.state[ACTIONS.rangedSave].threshold.set(0)
            end
        end),
        threshold = basicGetSet(ACTIONS.rangedSave, "threshold"),
        rollMode = basicGetSet(ACTIONS.rangedSave, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.rangedSave, "currentRoll"),
    },

    [ACTIONS.utility] = {
        useUtilityTrait = basicGetSet(ACTIONS.utility, "useUtilityTrait"),
        rollMode = basicGetSet(ACTIONS.utility, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.utility, "currentRoll"),

        resetSlots = function()
            TEARollHelper:Debug("Resetting slots for utility")
            rolls.state.utility.useUtilityTrait.set(false)
        end,
    },
}

local function resetSlots()
    rolls.state.attack.resetSlots()
    rolls.state.healing.resetSlots()
    rolls.state.utility.resetSlots()
end

local function resetRolls()
    for _, action in pairs(ACTIONS) do
        local actionState = rolls.state[action]
        actionState.currentRoll.set(nil)
    end
    rolls.state.attack.attacks.clear()
end

local function resetThresholds()
    rolls.state.defend.defenceType.set(DEFENCE_TYPES.THRESHOLD)
    rolls.state.attack.threshold.set(nil)
    rolls.state.defend.threshold.set(nil)
    rolls.state.defend.damageRisk.set(nil)
    rolls.state.meleeSave.defenceType.set(DEFENCE_TYPES.THRESHOLD)
    rolls.state.meleeSave.threshold.set(nil)
    rolls.state.meleeSave.damageRisk.set(nil)
    rolls.state.rangedSave.defenceType.set(DEFENCE_TYPES.THRESHOLD)
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

bus.addListener(EVENTS.BLOOD_HARVEST_CHARGES_CHANGED, function(numCharges)
    if numCharges < state.attack.numBloodHarvestSlots then
        rolls.state.attack.numBloodHarvestSlots.set(numCharges)
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

-- Turn actions

local function getAttack()
    local attackIndex = rolls.state.attack.attacks.count() + 1
    local offence = character.getPlayerOffence()
    local offenceBuff = buffsState.buffs.offence.get()
    local baseDmgBuff = buffsState.buffs.baseDamage.get()
    local damageDoneBuff = buffsState.buffs.damageDone.get()
    local enemyId = environment.state.enemyId.get()
    local isAOE = state.attack.isAOE
    local threshold = state.attack.threshold
    local numBloodHarvestSlots = state.attack.numBloodHarvestSlots
    local numVindicationCharges = characterState.featsAndTraits.numTraitCharges.get(TRAITS.VINDICATION.id)

    return actions.getAttack(attackIndex, state.attack.currentRoll, threshold, offence, offenceBuff, baseDmgBuff, damageDoneBuff, enemyId, isAOE, numBloodHarvestSlots, numVindicationCharges)
end

local function getCC()
    local offence = character.getPlayerOffence()
    local offenceBuff = buffsState.buffs.offence.get()
    local defence = character.getPlayerDefence()
    local defenceBuff = buffsState.buffs.defence.get()

    return actions.getCC(state.cc.currentRoll, offence, offenceBuff, defence, defenceBuff)
end

local function getHealing(outOfCombat)
    local spirit = character.getPlayerSpirit()
    local spiritBuff = buffsState.buffs.spirit.get()
    local healingDoneBuff = buffsState.buffs.healingDone.get()
    local remainingOutOfCombatHeals = characterState.healing.remainingOutOfCombatHeals.get()

    return actions.getHealing(state.healing.currentRoll, spirit, spiritBuff, healingDoneBuff, state.healing.numGreaterHealSlots, state.healing.targetIsKO, outOfCombat, remainingOutOfCombatHeals)
end

local function getBuff()
    local spirit = character.getPlayerSpirit()
    local offence = character.getPlayerOffence()
    local offenceBuff = buffsState.buffs.offence.get()
    local spiritBuff = buffsState.buffs.spirit.get()

    return actions.getBuff(state.buff.currentRoll, spirit, spiritBuff, offence, offenceBuff)
end

local function getDefence()
    local defence = character.getPlayerDefence()
    local defenceBuff = buffsState.buffs.defence.get()
    local damageTakenBuff = buffsState.buffs.damageTaken.get()

    return actions.getDefence(state.defend.currentRoll, state.defend.defenceType, state.defend.threshold, state.defend.damageType, state.defend.damageRisk, defence, defenceBuff, damageTakenBuff)
end

local function getMeleeSave()
    local defence = character.getPlayerDefence()
    local defenceBuff = buffsState.buffs.defence.get()
    local damageTakenBuff = buffsState.buffs.damageTaken.get()

    return actions.getMeleeSave(state.meleeSave.currentRoll, state.meleeSave.defenceType, state.meleeSave.threshold, state.meleeSave.damageType, state.meleeSave.damageRisk, defence, defenceBuff, damageTakenBuff)
end

local function getRangedSave()
    local spirit = character.getPlayerSpirit()
    local buff = buffsState.buffs.spirit.get()

    return actions.getRangedSave(state.rangedSave.currentRoll, state.rangedSave.defenceType, state.rangedSave.threshold, spirit, buff)
end

local function getUtility()
    local utilityBonusBuff = buffsState.buffs.utilityBonus.get()
    return actions.getUtility(state.utility.currentRoll, state.utility.useUtilityTrait, utilityBonusBuff)
end

-- Trait actions

local function getShieldSlam()
    local baseDmgBuff = buffsState.buffs.baseDamage.get()
    local defence = character.getPlayerDefence()
    local defenceBuff = buffsState.buffs.defence.get()

    return actions.traits.getShieldSlam(baseDmgBuff, defence, defenceBuff)
end

-- Rolls

local function getRollModeModifier(action, turnTypeId)
    local advantageBuff = buffsState.buffLookup.getAdvantageBuff(action, turnTypeId)
    local disadvantageDebuff = buffsState.buffLookup.getDisadvantageDebuff(action, turnTypeId)
    local enemyId = environment.state.enemyId.get()

    local modifier = rules.rolls.getRollModeModifier(action, advantageBuff, disadvantageDebuff, enemyId)

    return modifier
end

rolls.getAttack = getAttack
rolls.getCC = getCC
rolls.getHealing = getHealing
rolls.getBuff = getBuff
rolls.getDefence = getDefence
rolls.getMeleeSave = getMeleeSave
rolls.getRangedSave = getRangedSave
rolls.getUtility = getUtility

rolls.traits = {
    getShieldSlam = getShieldSlam,
}

rolls.getRollModeModifier = getRollModeModifier