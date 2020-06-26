local _, ns = ...

local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local ACTIONS = constants.ACTIONS
local FEATS = feats.FEATS
local TURN_TYPES = constants.TURN_TYPES
local WEAKNESSES = weaknesses.WEAKNESSES

local MIN_ROLL = 1
local MAX_ROLL = 20

local function getCritReq()
    local critReq = MAX_ROLL
    if character.hasFeat(FEATS.KEEN_SENSE) then
        critReq = critReq - 1
    end
    return critReq
end

local function getMaxFatePoints()
    return character.hasWeakness(WEAKNESSES.FATELESS) and 0 or 1
end

local function shouldSuggestFatePoint(roll, attack, healing, buff, defence, meleeSave, rangedSave)
    if attack then
        return attack.dmg <= 0
    elseif healing then
        return healing.amountHealed <= 1
    elseif buff then
        return buff.amountBuffed <= 2
    elseif defence then
        return defence.damageTaken > 0
    elseif meleeSave then
        return meleeSave.damageTaken > 0
    elseif rangedSave then
        return not rangedSave.canFullyProtect
    else
        return roll <= 5
    end
end

local function getRollModeModifier(action, advantageBuff, disadvantageDebuff, enemyId)
    local modifier = 0

    if advantageBuff then
        modifier = modifier + 1
    end
    if disadvantageDebuff then
        modifier = modifier - 1
    end

    if action == ACTIONS.attack then
        modifier = modifier + rules.offence.getRollModeModifier(enemyId)
    elseif action == ACTIONS.meleeSave then
        modifier = modifier + rules.meleeSave.getRollModeModifier()
    elseif action == ACTIONS.rangedSave then
        modifier = modifier + rules.rangedSave.getRollModeModifier()
    end

    return modifier
end

local function canProcRebound()
    return character.hasWeakness(WEAKNESSES.REBOUND)
end

local function hasReboundProc(roll, turnTypeId)
    return turnTypeId == TURN_TYPES.PLAYER.id and roll == MIN_ROLL
end

local function calculateReboundDamage()
    return max(character.getPlayerOffence(), character.getPlayerSpirit())
end

rules.rolls = {
    MIN_ROLL = MIN_ROLL,
    MAX_ROLL = MAX_ROLL,

    getCritReq = getCritReq,

    getMaxFatePoints = getMaxFatePoints,
    shouldSuggestFatePoint = shouldSuggestFatePoint,

    getRollModeModifier = getRollModeModifier,

    canProcRebound = canProcRebound,
    hasReboundProc = hasReboundProc,
    calculateReboundDamage = calculateReboundDamage,
}