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
local turnState = ns.state.turn

local utilityTypes = ns.resources.utilityTypes

local ACTIONS = constants.ACTIONS
local DEFENCE_TYPES = constants.DEFENCE_TYPES
local EVENTS = bus.EVENTS
local ROLL_MODES = constants.ROLL_MODES
local STATS = constants.STATS
local UTILITY_TYPES = utilityTypes.UTILITY_TYPES

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
            activeTraits = {},
        },

        [ACTIONS.penance] = {
            numGreaterHealSlots = 1,
            targetIsKO = false,
            activeTraits = {},
        },

        [ACTIONS.cc] = {
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.healing] = {
            heals = {},
            numGreaterHealSlots = 0,
            targetIsKO = false,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
            activeTraits = {},
        },

        [ACTIONS.buff] = {
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
            activeTraits = {},
        },

        [ACTIONS.defend] = {
            defences = {},
            defenceType = DEFENCE_TYPES.THRESHOLD,
            threshold = nil,
            damageType = nil,
            damageRisk = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
            activeTraits = {},
        },

        [ACTIONS.meleeSave] = {
            defenceType = DEFENCE_TYPES.THRESHOLD,
            threshold = nil,
            damageType = nil,
            damageRisk = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
            activeTraits = {},
        },

        [ACTIONS.rangedSave] = {
            defenceType = DEFENCE_TYPES.THRESHOLD,
            threshold = nil,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
        },

        [ACTIONS.utility] = {
            utilityTypeID = UTILITY_TYPES.OTHER.id,
            utilityTraitSlot = 0,
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
        activeTraits = {
            get = function(trait)
                return state.attack.activeTraits[trait.id]
            end,
            toggle = function(trait)
                if state.attack.activeTraits[trait.id] then
                    state.attack.activeTraits[trait.id] = false
                else
                    state.attack.activeTraits[trait.id] = true
                end
            end,
            reset = function()
                state.attack.activeTraits = {}
            end,
        },

        resetSlots = function()
            TEARollHelper:Debug("Resetting slots for attack")
            rolls.state.attack.numBloodHarvestSlots.set(0)
            rolls.state.attack.isAOE.set(false)
            rolls.state.attack.activeTraits.reset()
        end,
    },

    [ACTIONS.penance] = {
        numGreaterHealSlots = basicGetSet(ACTIONS.penance, "numGreaterHealSlots"),
        targetIsKO = basicGetSet(ACTIONS.penance, "targetIsKO"),
        activeTraits = {
            get = function(trait)
                return state.penance.activeTraits[trait.id]
            end,
            toggle = function(trait)
                if state.penance.activeTraits[trait.id] then
                    state.penance.activeTraits[trait.id] = false
                else
                    state.penance.activeTraits[trait.id] = true
                end
            end,
            reset = function()
                state.penance.activeTraits = {}
            end,
        },

        resetSlots = function()
            TEARollHelper:Debug("Resetting slots for penance")
            rolls.state.penance.numGreaterHealSlots.set(1)
            rolls.state.penance.targetIsKO.set(false)
            rolls.state.penance.activeTraits.reset()
        end,
    },

    [ACTIONS.cc] = {
        rollMode = basicGetSet(ACTIONS.cc, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.cc, "currentRoll"),
    },

    [ACTIONS.healing] = {
        heals = {
            get = function()
                return state.healing.heals
            end,
            count = function()
                return #state.healing.heals
            end,
            add = function(healing)
                table.insert(state.healing.heals, healing)
            end,
            clear = function()
                state.healing.heals = {}
            end,
        },
        numGreaterHealSlots = basicGetSet(ACTIONS.healing, "numGreaterHealSlots"),
        targetIsKO = basicGetSet(ACTIONS.healing, "targetIsKO"),
        rollMode = basicGetSet(ACTIONS.healing, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.healing, "currentRoll"),
        activeTraits = {
            get = function(trait)
                return state.healing.activeTraits[trait.id]
            end,
            toggle = function(trait)
                if state.healing.activeTraits[trait.id] then
                    state.healing.activeTraits[trait.id] = false
                else
                    state.healing.activeTraits[trait.id] = true
                end
            end,
            reset = function()
                state.healing.activeTraits = {}
            end,
        },

        resetSlots = function()
            TEARollHelper:Debug("Resetting slots for healing")
            rolls.state.healing.numGreaterHealSlots.set(0)
            rolls.state.healing.targetIsKO.set(false)
            rolls.state.healing.activeTraits.reset()
        end,
    },

    [ACTIONS.buff] = {
        rollMode = basicGetSet(ACTIONS.buff, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.buff, "currentRoll"),
        activeTraits = {
            get = function(trait)
                return state.buff.activeTraits[trait.id]
            end,
            toggle = function(trait)
                if state.buff.activeTraits[trait.id] then
                    state.buff.activeTraits[trait.id] = false
                else
                    state.buff.activeTraits[trait.id] = true
                end
            end,
            reset = function()
                state.buff.activeTraits = {}
            end,
        },

        resetSlots = function()
            TEARollHelper:Debug("Resetting slots for buffing")
            rolls.state.buff.activeTraits.reset()
        end,
    },

    [ACTIONS.defend] = {
        defences = {
            get = function()
                return state.defend.defences
            end,
            count = function()
                return #state.defend.defences
            end,
            add = function(defence)
                table.insert(state.defend.defences, defence)
            end,
            clear = function()
                state.defend.defences = {}
            end,
        },
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
        activeTraits = {
            get = function(trait)
                return state.defend.activeTraits[trait.id]
            end,
            toggle = function(trait)
                if state.defend.activeTraits[trait.id] then
                    state.defend.activeTraits[trait.id] = false
                else
                    state.defend.activeTraits[trait.id] = true
                end
            end,
            reset = function()
                state.defend.activeTraits = {}
            end,
        },

        resetSlots = function()
            TEARollHelper:Debug("Resetting slots for defend")
            rolls.state.defend.activeTraits.reset()
        end,
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
        activeTraits = {
            get = function(trait)
                return state.meleeSave.activeTraits[trait.id]
            end,
            toggle = function(trait)
                if state.meleeSave.activeTraits[trait.id] then
                    state.meleeSave.activeTraits[trait.id] = false
                else
                    state.meleeSave.activeTraits[trait.id] = true
                end
            end,
            reset = function()
                state.meleeSave.activeTraits = {}
            end,
        },

        resetSlots = function()
            TEARollHelper:Debug("Resetting slots for meleeSave")
            rolls.state.meleeSave.activeTraits.reset()
        end,
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
        utilityTypeID = basicGetSet(ACTIONS.utility, "utilityTypeID"),
        utilityTraitSlot = basicGetSet(ACTIONS.utility, "utilityTraitSlot"),
        rollMode = basicGetSet(ACTIONS.utility, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.utility, "currentRoll"),

        resetSlots = function()
            TEARollHelper:Debug("Resetting slots for utility")
            rolls.state.utility.utilityTraitSlot.set(0)
        end,
    },
}

local function resetSlots()
    rolls.state.attack.resetSlots()
    rolls.state.penance.resetSlots()
    rolls.state.healing.resetSlots()
    rolls.state.buff.resetSlots()
    rolls.state.defend.resetSlots()
    rolls.state.meleeSave.resetSlots()
    rolls.state.utility.resetSlots()
end

local function resetRolls()
    for _, action in pairs(ACTIONS) do
        local actionState = rolls.state[action]
        if actionState.currentRoll then -- penance uses attack state for roll
            actionState.currentRoll.set(nil)
        end
    end
    rolls.state.attack.attacks.clear()
    rolls.state.defend.defences.clear()
    rolls.state.healing.heals.clear()
end

local function resetThresholds()
    rolls.state.attack.threshold.set(nil)
    rolls.state.defend.defenceType.set(DEFENCE_TYPES.THRESHOLD)
    rolls.state.defend.threshold.set(nil)
    rolls.state.defend.damageRisk.set(nil)
    rolls.state.meleeSave.defenceType.set(DEFENCE_TYPES.THRESHOLD)
    rolls.state.meleeSave.threshold.set(nil)
    rolls.state.meleeSave.damageRisk.set(nil)
    rolls.state.rangedSave.defenceType.set(DEFENCE_TYPES.THRESHOLD)
    rolls.state.rangedSave.threshold.set(nil)
    rolls.state.utility.utilityTypeID.set(UTILITY_TYPES.OTHER.id)
end

bus.addListener(EVENTS.CHARACTER_STAT_CHANGED, resetSlots)
bus.addListener(EVENTS.FEAT_CHANGED, function()
    resetSlots()
    resetRolls() -- in case of crit threshold change
end)
bus.addListener(EVENTS.TRAITS_CHANGED, resetSlots)
bus.addListener(EVENTS.WEAKNESSES_CHANGED, resetSlots)
bus.addListener(EVENTS.UTILITY_TRAITS_CHANGED, resetSlots)
bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, function()
    resetSlots() -- in case of utility bonus change
    resetRolls() -- in case of crit threshold change
    resetThresholds() -- in case of utility bonus change
end)
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
    if numCharges < state.penance.numGreaterHealSlots then
        rolls.state.penance.numGreaterHealSlots.set(max(1, numCharges))
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

local function getRollBuff()
    return buffsState.buffs.roll.get(turnState.state.type.get())
end

local function getAttack()
    local attackIndex = rolls.state.attack.attacks.count() + 1
    local rollBuff = getRollBuff()
    local offence = character.getPlayerOffence()
    local offenceBuff = buffsState.buffs.offence.get()
    local baseDmgBuff = buffsState.buffs.baseDamage.get()
    local damageDoneBuff = buffsState.buffs.damageDone.get()
    local enemyId = environment.state.enemyId.get()
    local isAOE = state.attack.isAOE
    local threshold = state.attack.threshold
    local numBloodHarvestSlots = state.attack.numBloodHarvestSlots
    local activeTraits = state.attack.activeTraits

    return actions.getAttack(attackIndex, state.attack.currentRoll, rollBuff, threshold, offence, offenceBuff, baseDmgBuff, damageDoneBuff, enemyId, isAOE, numBloodHarvestSlots, activeTraits)
end

local function getPenance()
    local rollBuff = getRollBuff()
    local spirit = character.getPlayerSpirit()
    local spiritBuff = buffsState.buffs.spirit.get()
    local baseDmgBuff = buffsState.buffs.baseDamage.get()
    local damageDoneBuff = buffsState.buffs.damageDone.get()
    local threshold = state.attack.threshold
    local activeTraits = state.penance.activeTraits

    return actions.getPenance(state.attack.currentRoll, rollBuff, threshold, spirit, spiritBuff, baseDmgBuff, damageDoneBuff, state.penance.numGreaterHealSlots, state.penance.targetIsKO, activeTraits)
end

local function getCC()
    local rollBuff = getRollBuff()
    local offence = character.getPlayerOffence()
    local offenceBuff = buffsState.buffs.offence.get()
    local defence = character.getPlayerDefence()
    local defenceBuff = buffsState.buffs.defence.get()

    return actions.getCC(state.cc.currentRoll, rollBuff, offence, offenceBuff, defence, defenceBuff)
end

local function getHealing(outOfCombat)
    local rollBuff = getRollBuff()
    local spirit = character.getPlayerSpirit()
    local spiritBuff = buffsState.buffs.spirit.get()
    local healingDoneBuff = buffsState.buffs.healingDone.get()
    local remainingOutOfCombatHeals = characterState.healing.remainingOutOfCombatHeals.get()
    local activeTraits = state.healing.activeTraits

    return actions.getHealing(state.healing.currentRoll, rollBuff, spirit, spiritBuff, healingDoneBuff, state.healing.numGreaterHealSlots, state.healing.targetIsKO, outOfCombat, remainingOutOfCombatHeals, activeTraits)
end

local function getBuff()
    local rollBuff = getRollBuff()
    local spirit = character.getPlayerSpirit()
    local offence = character.getPlayerOffence()
    local offenceBuff = buffsState.buffs.offence.get()
    local spiritBuff = buffsState.buffs.spirit.get()
    local activeTraits = state.buff.activeTraits

    return actions.getBuff(state.buff.currentRoll, rollBuff, spirit, spiritBuff, offence, offenceBuff, activeTraits)
end

local function getDefence()
    local rollBuff = getRollBuff()
    local defence = character.getPlayerDefence()
    local defenceBuff = buffsState.buffs.defence.get()
    local damageTakenBuff = buffsState.buffs.damageTaken.get()
    local activeTraits = state.defend.activeTraits

    return actions.getDefence(state.defend.currentRoll, rollBuff, state.defend.defenceType, state.defend.threshold, state.defend.damageType, state.defend.damageRisk, defence, defenceBuff, damageTakenBuff, activeTraits)
end

local function getMeleeSave()
    local rollBuff = getRollBuff()
    local defence = character.getPlayerDefence()
    local defenceBuff = buffsState.buffs.defence.get()
    local damageTakenBuff = buffsState.buffs.damageTaken.get()
    local activeTraits = state.meleeSave.activeTraits

    return actions.getMeleeSave(state.meleeSave.currentRoll, rollBuff, state.meleeSave.defenceType, state.meleeSave.threshold, state.meleeSave.damageType, state.meleeSave.damageRisk, defence, defenceBuff, damageTakenBuff, activeTraits)
end

local function getRangedSave()
    local rollBuff = getRollBuff()
    local spirit = character.getPlayerSpirit()
    local buff = buffsState.buffs.spirit.get()

    return actions.getRangedSave(state.rangedSave.currentRoll, rollBuff, state.rangedSave.defenceType, state.rangedSave.threshold, spirit, buff)
end

local function getUtility()
    local rollBuff = getRollBuff()
    local utilityBonusBuff = buffsState.buffs.utilityBonus.get()
    local utilityTypeID = state.utility.utilityTypeID
    local utilityTrait = character.getUtilityTraitAtSlot(state.utility.utilityTraitSlot)
    return actions.getUtility(state.utility.currentRoll, rollBuff, utilityTypeID, utilityTrait, utilityBonusBuff)
end

-- Trait actions

local function getShieldSlam()
    local baseDmgBuff = buffsState.buffs.baseDamage.get()
    local defence = character.getPlayerDefence()
    local defenceBuff = buffsState.buffs.defence.get()

    return actions.traits.getShieldSlam(baseDmgBuff, defence, defenceBuff)
end

-- Rolls

local function getRollModeModifier(action, turnTypeID)
    local advantageBuff = buffsState.buffLookup.getAdvantageBuff(action, turnTypeID)
    local disadvantageDebuff = buffsState.buffLookup.getDisadvantageDebuff(action, turnTypeID)
    local enemyId = environment.state.enemyId.get()
    local utilityTypeID = state.utility.utilityTypeID

    local modifier = rules.rolls.getRollModeModifier(action, advantageBuff, disadvantageDebuff, enemyId, utilityTypeID)

    return modifier
end

rolls.getAttack = getAttack
rolls.getPenance = getPenance
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