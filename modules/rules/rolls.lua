local _, ns = ...

local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local ACTIONS = constants.ACTIONS
local FEATS = feats.FEATS
local ROLL_MODES = constants.ROLL_MODES
local TURN_TYPES = constants.TURN_TYPES
local WEAKNESSES = weaknesses.WEAKNESSES

local MIN_ROLL = 1
local DEFAULT_MAX_ROLL = 20

local function getMaxRoll(action)
    if action == ACTIONS.damage then
        return 10
    end

    return DEFAULT_MAX_ROLL
end

local function calculateRoll(roll, rollBuff)
    return roll + rollBuff
end

local function getCritReq(action)
    local critReq = getMaxRoll(action)
    if character.hasFeat(FEATS.KEEN_SENSE) then
        critReq = critReq - 1
    end
    return critReq
end

local function getMaxFatePoints()
    return 2
end

local fatePointChecks = {
    [ACTIONS.attack] = function(action)
        return not action.isSuccessful
    end,
    [ACTIONS.damage] = function(damage)
        return false -- currently not allowed
    end,
    [ACTIONS.cc] = function(cc)
        return cc.ccValue <= 10
    end,
    [ACTIONS.healing] = function(healing)
        return healing.amountHealed <= 1
    end,
    [ACTIONS.buff] = function(buff)
        return buff.amountBuffed <= 2
    end,
    [ACTIONS.defend] = function(defence)
        return defence.damageTaken > 0
    end,
    [ACTIONS.meleeSave] = function(meleeSave)
        return meleeSave.damageTaken > 0
    end,
    [ACTIONS.rangedSave] = function(rangedSave)
        return not rangedSave.canFullyProtect
    end,
}

local function shouldSuggestFatePoint(roll, actionType, action)
    if fatePointChecks[actionType] then
        return fatePointChecks[actionType](action)
    else
        return roll <= 5
    end
end

local function canHaveAdvantage()
    return not character.hasWeakness(WEAKNESSES.UNDERACHIEVER)
end

local function getRollModeModifier(action, turnTypeID, advantageBuff, disadvantageDebuff, enemyId, utilityTypeID)
    local modifier = 0

    if advantageBuff then
        modifier = modifier + 1
    end
    if disadvantageDebuff then
        modifier = modifier - 1
    end

    if turnTypeID == TURN_TYPES.PLAYER.id and character.hasFeat(FEATS.MASTER) and character.hasOffenceMastery() then
        modifier = modifier + 1
    end

    if action == ACTIONS.attack or action == ACTIONS.damage then
        modifier = modifier + rules.offence.getRollModeModifier(enemyId)
    elseif action == ACTIONS.meleeSave then
        modifier = modifier + rules.meleeSave.getRollModeModifier()
    elseif action == ACTIONS.rangedSave then
        modifier = modifier + rules.rangedSave.getRollModeModifier()
    elseif action == ACTIONS.utility then
        modifier = modifier + rules.utility.getRollModeModifier(utilityTypeID)
    end

    local maxModifier = canHaveAdvantage() and ROLL_MODES.ADVANTAGE or 0

    modifier = max(ROLL_MODES.DISADVANTAGE, min(maxModifier, modifier))

    return modifier
end

local function canProcRebound()
    return character.hasWeakness(WEAKNESSES.REBOUND)
end

local function hasReboundProc(roll, turnTypeID)
    return turnTypeID == TURN_TYPES.PLAYER.id and roll == MIN_ROLL
end

local function calculateReboundDamage()
    return max(character.getPlayerOffence(), character.getPlayerSpirit())
end

rules.rolls = {
    MIN_ROLL = MIN_ROLL,
    getMaxRoll = getMaxRoll,

    calculateRoll = calculateRoll,

    getCritReq = getCritReq,

    getMaxFatePoints = getMaxFatePoints,
    shouldSuggestFatePoint = shouldSuggestFatePoint,

    canHaveAdvantage = canHaveAdvantage,
    getRollModeModifier = getRollModeModifier,

    canProcRebound = canProcRebound,
    hasReboundProc = hasReboundProc,
    calculateReboundDamage = calculateReboundDamage,
}