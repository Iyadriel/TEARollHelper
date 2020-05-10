local _, ns = ...

local actions = ns.actions
local events = ns.events
local rules = ns.rules
local turns = ns.turns

local TURN_MODE_ATTACK = 0
local TURN_MODE_DEFEND = 1
local BUFF_TYPES = {
    OFFENCE = "offence",
    DEFENCE = "defence"
}

local setTurnMode, setCurrentRoll, getCurrentTurnValues, handleRollResult
local setAttackValues, setDefendValues
local startAttackTurn, startDefendTurn
local getCurrentBuffs, setCurrentBuff, clearCurrentBuffs, expireCurrentBuff

local currentTurnValues = {
    turnMode = TURN_MODE_ATTACK,
    roll = 1,
    attackThreshold = 0,
    defendThreshold = 0,
    damageRisk = 0
}

local currentBuffs = {
    [BUFF_TYPES.OFFENCE] = 0,
    [BUFF_TYPES.DEFENCE] = 0
}

function setTurnMode(mode)
    currentTurnValues.turnMode = mode
end

function setCurrentRoll(roll)
    currentTurnValues.roll = roll
end

function getCurrentTurnValues()
    return currentTurnValues
end

function setAttackValues(attackThreshold)
    currentTurnValues.attackThreshold = attackThreshold
end

function setDefendValues(defendThreshold, damageRisk)
    if defendThreshold ~= nil then
        currentTurnValues.defendThreshold = defendThreshold
    end
    if damageRisk ~= nil then
        currentTurnValues.damageRisk = damageRisk
    end
end

function startAttackTurn(attackThreshold)
    events.listenForRolls()

    setTurnMode(TURN_MODE_ATTACK)
    setAttackValues(attackThreshold)

    RandomRoll(1, rules.MAX_ROLL)
end

function startDefendTurn(defendThreshold, damageRisk)
    events.listenForRolls()

    setTurnMode(TURN_MODE_DEFEND)
    setDefendValues(defendThreshold, damageRisk)

    RandomRoll(1, rules.MAX_ROLL)
end

function handleRollResult(roll)
    setCurrentRoll(roll)
    if currentTurnValues.turnMode == TURN_MODE_ATTACK then
        actions.performAttack(roll)
    elseif currentTurnValues.turnMode == TURN_MODE_DEFEND then
        actions.performDefence(roll)
    end
end

function getCurrentBuffs()
    return {
        [BUFF_TYPES.OFFENCE] = currentBuffs[BUFF_TYPES.OFFENCE],
        [BUFF_TYPES.DEFENCE] = currentBuffs[BUFF_TYPES.DEFENCE]
    }
end

function setCurrentBuff(buffType, amount)
    currentBuffs[buffType] = amount
end

function clearCurrentBuffs()
    setCurrentBuff(BUFF_TYPES.OFFENCE, 0)
    setCurrentBuff(BUFF_TYPES.DEFENCE, 0)
end

function expireCurrentBuff(buffType)
    if currentBuffs[buffType] > 0 then
        TEARollHelper:Print("|cFFBBBBBBYour temporary "..buffType.." buff has expired.")
    end
    currentBuffs[buffType] = 0
end

turns.BUFF_TYPES = BUFF_TYPES
turns.getCurrentTurnValues = getCurrentTurnValues
turns.setCurrentRoll = setCurrentRoll
turns.setAttackValues = setAttackValues
turns.setDefendValues = setDefendValues
turns.startAttackTurn = startAttackTurn
turns.startDefendTurn = startDefendTurn
turns.handleRollResult = handleRollResult
turns.getCurrentBuffs = getCurrentBuffs
turns.setCurrentBuff = setCurrentBuff
turns.clearCurrentBuffs = clearCurrentBuffs
turns.expireCurrentBuff = expireCurrentBuff