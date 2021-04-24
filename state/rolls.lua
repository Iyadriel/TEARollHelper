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

local feats = ns.resources.feats
local utilityTypes = ns.resources.utilityTypes

local ACTIONS = constants.ACTIONS
local CRIT_TYPES = constants.CRIT_TYPES
local DEFENCE_TYPES = constants.DEFENCE_TYPES
local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local ROLL_MODES = constants.ROLL_MODES
local SPECIAL_ACTIONS = constants.SPECIAL_ACTIONS
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
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
            critType = CRIT_TYPES.VALUE_MOD,
            activeTraits = {},
        },

        [ACTIONS.damage] = {
            numBloodHarvestSlots = 0,
            numGreaterHealSlots = 0, -- for penance
            targetIsKO = false, -- for penance
            isAOE = false,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
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
            critType = CRIT_TYPES.VALUE_MOD,
            activeTraits = {},
        },

        [ACTIONS.buff] = {
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
            critType = CRIT_TYPES.VALUE_MOD,
            activeTraits = {},
        },

        [ACTIONS.defend] = {
            defences = {},
            defenceType = DEFENCE_TYPES.THRESHOLD,
            threshold = nil,
            damageType = nil,
            damageRisk = nil,
            numBraceCharges = 0,
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
            critType = CRIT_TYPES.RETALIATE,
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

        [SPECIAL_ACTIONS.clingToConsciousness] = {
            rollMode = ROLL_MODES.NORMAL,
            currentRoll = nil,
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

local function activeTraits(action)
    return {
        get = function(trait)
            return state[action].activeTraits[trait.id]
        end,
        toggle = function(trait)
            if state[action].activeTraits[trait.id] then
                state[action].activeTraits[trait.id] = false
            else
                state[action].activeTraits[trait.id] = true
            end
        end,
        reset = function()
            state[action].activeTraits = {}
        end,
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
        rollMode = basicGetSet(ACTIONS.attack, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.attack, "currentRoll"),
        critType = basicGetSet(ACTIONS.attack, "critType"),
        activeTraits = activeTraits(ACTIONS.attack),

        resetSlots = function()
            rolls.state.attack.activeTraits.reset()
            rolls.state.damage.resetSlots()
        end,
    },

    [ACTIONS.damage] = {
        numBloodHarvestSlots = basicGetSet(ACTIONS.damage, "numBloodHarvestSlots"),
        numGreaterHealSlots = basicGetSet(ACTIONS.damage, "numGreaterHealSlots"),
        targetIsKO = basicGetSet(ACTIONS.damage, "targetIsKO"),
        isAOE = basicGetSet(ACTIONS.damage, "isAOE"),
        rollMode = basicGetSet(ACTIONS.damage, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.damage, "currentRoll"),
        activeTraits = activeTraits(ACTIONS.damage),

        resetSlots = function()
            rolls.state.damage.numBloodHarvestSlots.set(0)
            rolls.state.damage.numGreaterHealSlots.set(0)
            rolls.state.damage.targetIsKO.set(false)
            rolls.state.damage.isAOE.set(false)
            rolls.state.damage.activeTraits.reset()
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
        critType = basicGetSet(ACTIONS.healing, "critType"),
        activeTraits = activeTraits(ACTIONS.healing),

        resetSlots = function()
            rolls.state.healing.numGreaterHealSlots.set(0)
            rolls.state.healing.targetIsKO.set(false)
            rolls.state.healing.activeTraits.reset()
        end,
    },

    [ACTIONS.buff] = {
        rollMode = basicGetSet(ACTIONS.buff, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.buff, "currentRoll"),
        critType = basicGetSet(ACTIONS.buff, "critType"),
        activeTraits = activeTraits(ACTIONS.buff),

        resetSlots = function()
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
        numBraceCharges = basicGetSet(ACTIONS.defend, "numBraceCharges"),
        rollMode = basicGetSet(ACTIONS.defend, "rollMode"),
        currentRoll = basicGetSet(ACTIONS.defend, "currentRoll"),
        critType = basicGetSet(ACTIONS.defend, "critType"),
        activeTraits = activeTraits(ACTIONS.defend),

        resetSlots = function()
            rolls.state.defend.numBraceCharges.set(0)
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
        activeTraits = activeTraits(ACTIONS.meleeSave),

        resetSlots = function()
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
            rolls.state.utility.utilityTraitSlot.set(0)
        end,
    },

    [SPECIAL_ACTIONS.clingToConsciousness] = {
        rollMode = basicGetSet(SPECIAL_ACTIONS.clingToConsciousness, "rollMode"),
        currentRoll = basicGetSet(SPECIAL_ACTIONS.clingToConsciousness, "currentRoll"),
    },
}

local function resetSlots()
    TEARollHelper:Debug("Resetting slots")
    rolls.state.attack.resetSlots()
    rolls.state.healing.resetSlots()
    rolls.state.buff.resetSlots()
    rolls.state.defend.resetSlots()
    rolls.state.meleeSave.resetSlots()
    rolls.state.utility.resetSlots()
end

local function resetRolls()
    for _, action in pairs(ACTIONS) do
        local actionState = rolls.state[action]
        actionState.currentRoll.set(nil)
    end
    rolls.state.attack.attacks.clear()
    rolls.state.defend.defences.clear()
    rolls.state.healing.heals.clear()
    rolls.state[SPECIAL_ACTIONS.clingToConsciousness].currentRoll.set(nil)
end

local function resetRollModes()
    for _, action in pairs(ACTIONS) do
        local actionState = rolls.state[action]
        actionState.rollMode.set(ROLL_MODES.NORMAL)
    end

    rolls.state[SPECIAL_ACTIONS.clingToConsciousness].rollMode.set(ROLL_MODES.NORMAL)
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

local function resetAll()
    resetSlots()
    resetRolls()
    resetRollModes()
    resetThresholds()
end

bus.addListener(EVENTS.CHARACTER_STAT_CHANGED, resetSlots)
bus.addListener(EVENTS.FEAT_CHANGED, function()
    resetSlots()
    resetRolls() -- in case of crit threshold change
end)
bus.addListener(EVENTS.TRAITS_CHANGED, resetSlots)
bus.addListener(EVENTS.WEAKNESSES_CHANGED, function()
    resetRollModes() -- because of underachiever
    resetSlots()
end)
bus.addListener(EVENTS.UTILITY_TRAITS_CHANGED, resetSlots)
bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, resetAll)
bus.addListener(EVENTS.PROFILE_CHANGED, resetAll)
bus.addListener(EVENTS.TURN_STARTED, resetAll)

bus.addListener(EVENTS.BLOOD_HARVEST_CHARGES_CHANGED, function(numCharges)
    if numCharges < state.damage.numBloodHarvestSlots then
        rolls.state.damage.numBloodHarvestSlots.set(numCharges)
    end
end)

bus.addListener(EVENTS.BRACE_CHARGES_CHANGED, function(numCharges)
    if numCharges < state.defend.numBraceCharges then
        rolls.state.defend.numBraceCharges.set(numCharges)
    end
end)

bus.addListener(EVENTS.GREATER_HEAL_CHARGES_CHANGED, function(numCharges)
    if numCharges < state.healing.numGreaterHealSlots then
        rolls.state.healing.numGreaterHealSlots.set(numCharges)
    end
    if numCharges < state.damage.numGreaterHealSlots then
        rolls.state.damage.numGreaterHealSlots.set(numCharges)
    end
end)

bus.addListener(EVENTS.ROLL_CHANGED, function(action, roll)
    rolls.state[action].currentRoll.set(roll)

    -- damage action is invalidated when attack roll changes.
    if action == ACTIONS.attack then
        rolls.state.damage.currentRoll.set(nil)
        rolls.state.damage.resetSlots()
    end
end)

bus.addListener(EVENTS.ROLL_BUFFS_CHANGED, function()
    -- it's possible that the attack is no longer successful, so we need to clear our damage action if we have anything set.
    rolls.state.damage.currentRoll.set(nil)
    rolls.state.damage.resetSlots()
end)

bus.addListener(EVENTS.FATE_ROLLED, function(action, roll)
    local currentRoll = rolls.state[action].currentRoll.get()

     rolls.state[action].currentRoll.set(currentRoll + roll)
end)

-- Turn actions

local function getRollBuff()
    return buffsState.buffs.roll.get(turnState.state.type.get())
end

local function getDamageRollBuff()
    return buffsState.buffs.roll.get("damage")
end

local function getDamage()
    local rollBuff = getDamageRollBuff()
    local healingDoneBuff = buffsState.buffs.healingDone.get()
    local baseDmgBuff = buffsState.buffs.baseDamage.get()
    local damageDoneBuff = buffsState.buffs.damageDone.get()

    return actions.getDamage(
        state.attack.currentRoll,
        state.damage.currentRoll,
        rollBuff,
        state.attack.critType,
        baseDmgBuff,
        damageDoneBuff,
        healingDoneBuff,
        state.damage.isAOE,
        state.damage.numGreaterHealSlots,
        state.damage.targetIsKO,
        state.damage.numBloodHarvestSlots,
        state.damage.activeTraits
    )
end

local function getAttack()
    if not state.attack.currentRoll then return nil end

    local attackIndex = rolls.state.attack.attacks.count() + 1
    local rollBuff = getRollBuff()
    local whichStat = character.hasFeat(FEATS.PENANCE) and STATS.spirit or STATS.offence
    local stat = character.getPlayerStat(whichStat)
    local statBuff = buffsState.buffs[whichStat].get()
    local baseDmgBuff = buffsState.buffs.baseDamage.get()
    local damageDoneBuff = buffsState.buffs.damageDone.get()
    local enemyId = environment.state.enemyId.get()
    local threshold = state.attack.threshold

    return actions.getAttack(
        attackIndex,
        state.attack.currentRoll,
        rollBuff,
        state.attack.critType,
        threshold,
        stat,
        statBuff,
        baseDmgBuff,
        damageDoneBuff,
        enemyId,
        getDamage()
    )
end

local function getCC()
    local rollBuff = getRollBuff()
    local whichStat
    if character.hasFeat(FEATS.SHEPHERD_OF_THE_WICKED) then
        whichStat = STATS.defence
    else
        whichStat = STATS.offence
    end
    local stat = character.getPlayerStat(whichStat)
    local statBuff = buffsState.buffs[whichStat].get()

    return actions.getCC(state.cc.currentRoll, rollBuff, stat, statBuff)
end

local function getHealing(outOfCombat)
    local rollBuff = getRollBuff()
    local spirit = character.getPlayerSpirit()
    local spiritBuff = buffsState.buffs.spirit.get()
    local healingDoneBuff = buffsState.buffs.healingDone.get()
    local remainingOutOfCombatHeals = characterState.healing.remainingOutOfCombatHeals.get()
    local activeTraits = state.healing.activeTraits

    return actions.getHealing(state.healing.currentRoll, rollBuff, state.healing.critType, spirit, spiritBuff, healingDoneBuff, state.healing.numGreaterHealSlots, state.healing.targetIsKO, outOfCombat, remainingOutOfCombatHeals, activeTraits)
end

local function getBuff()
    local rollBuff = getRollBuff()
    local spirit = character.getPlayerSpirit()
    local offence = character.getPlayerOffence()
    local offenceBuff = buffsState.buffs.offence.get()
    local spiritBuff = buffsState.buffs.spirit.get()
    local activeTraits = state.buff.activeTraits

    return actions.getBuff(state.buff.currentRoll, rollBuff, state.buff.critType, spirit, spiritBuff, offence, offenceBuff, activeTraits)
end

local function getDefence()
    local rollBuff = getRollBuff()
    local defence = character.getPlayerDefence()
    local defenceBuff = buffsState.buffs.defence.get()
    local damageTakenBuff = buffsState.buffs.damageTaken.get()
    local activeTraits = state.defend.activeTraits

    return actions.getDefence(state.defend.currentRoll, rollBuff, state.defend.defenceType, state.defend.threshold, state.defend.damageType, state.defend.damageRisk, state.defend.numBraceCharges, state.defend.critType, defence, defenceBuff, damageTakenBuff, activeTraits)
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

local ACTION_METHODS = {
    [ACTIONS.attack] = getAttack,
    [ACTIONS.damage] = getDamage,
    [ACTIONS.cc] = getCC,
    [ACTIONS.healing] = getHealing,
    [ACTIONS.buff] = getBuff,
    [ACTIONS.defend] = getDefence,
    [ACTIONS.meleeSave] = getMeleeSave,
    [ACTIONS.rangedSave] = getRangedSave,
    [ACTIONS.utility] = getUtility,
}

local function getActionMethod(action)
    return ACTION_METHODS[action]
end

-- Trait actions

local function getHolyBulwark(isSave)
    local damageTakenBuff = buffsState.buffs.damageTaken.get()

    return actions.traits.getHolyBulwark(state.defend.damageRisk, damageTakenBuff, isSave)
end

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

    local modifier = rules.rolls.getRollModeModifier(action, turnTypeID, advantageBuff, disadvantageDebuff, enemyId, utilityTypeID)

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
rolls.getActionMethod = getActionMethod

rolls.traits = {
    getShieldSlam = getShieldSlam,
    getHolyBulwark = getHolyBulwark,
}

rolls.getRollModeModifier = getRollModeModifier