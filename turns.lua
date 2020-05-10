local _, ns = ...

local actions = ns.actions
local events = ns.events
local rules = ns.rules

local TURN_MODE_ATTACK = 0
local TURN_MODE_DEFEND = 1
local BUFF_TYPES = {
    OFFENCE = "offence",
    DEFENCE = "defence"
}

local setTurnMode, getCurrentTurnValues, clearCurrentTurnValues, handleRollResult
local startAttackTurn, startDefendTurn
local getCurrentBuffs, setCurrentBuff, clearCurrentBuffs, expireCurrentBuff

local currentTurnValues = {
    turnMode = TURN_MODE_ATTACK,
    attackThreshold = nil,
    defendTreshold = nil,
    damageRisk = nil
}

local currentBuffs = {
    [BUFF_TYPES.OFFENCE] = 0,
    [BUFF_TYPES.DEFENCE] = 0
}

function setTurnMode(mode)
    currentTurnValues.turnMode = mode
end

function getCurrentTurnValues()
    return {
        attackThreshold = currentTurnValues.attackThreshold,
        defendTreshold = currentTurnValues.defendTreshold,
        damageRisk = currentTurnValues.damageRisk
    }
end

function clearCurrentTurnValues()
    currentTurnValues.attackThreshold = nil
    defendTreshold = nil
    damageRisk = nil
end

function startAttackTurn(attackThreshold)
    events.listenForRolls()

    setTurnMode(TURN_MODE_ATTACK)
    currentTurnValues.attackThreshold = attackThreshold

    RandomRoll(1, rules.MAX_ROLL)
end

function startDefendTurn(defendTreshold, damageRisk)
    events.listenForRolls()

    setTurnMode(TURN_MODE_DEFEND)
    currentTurnValues.defendTreshold = defendTreshold
    currentTurnValues.damageRisk = damageRisk

    RandomRoll(1, rules.MAX_ROLL)
end

function handleRollResult(roll)
    if currentTurnValues.turnMode == TURN_MODE_ATTACK then
        actions.performAttack(roll)
    elseif currentTurnValues.turnMode == TURN_MODE_DEFEND then
        actions.performDefence(roll)
    end
    clearCurrentTurnValues()
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
end

function expireCurrentBuff(buffType)
    if currentBuffs[buffType] > 0 then
        TEARollHelper:Print("|cFFBBBBBBYour temporary "..buffType.." buff has expired.")
    end
    currentBuffs[buffType] = 0
end

ns.turns.BUFF_TYPES = BUFF_TYPES
ns.turns.getCurrentTurnValues = getCurrentTurnValues
ns.turns.startAttackTurn = startAttackTurn
ns.turns.startDefendTurn = startDefendTurn
ns.turns.handleRollResult = handleRollResult
ns.turns.getCurrentBuffs = getCurrentBuffs
ns.turns.setCurrentBuff = setCurrentBuff
ns.turns.clearCurrentBuff = clearCurrentBuff