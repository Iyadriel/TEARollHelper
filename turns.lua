local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local actions = ns.actions
local events = ns.events
local rules = ns.rules
local turns = ns.turns

local BUFF_TYPES = {
    OFFENCE = "offence",
    DEFENCE = "defence"
}

local setCurrentRoll, getCurrentTurnValues, handleRollResult
local setAttackValues, setDefendValues
local roll
local getCurrentBuffs, setCurrentBuff, clearCurrentBuffs

local currentTurnValues = {
    roll = 1,
    attackThreshold = 12,
    defendThreshold = 10,
    damageRisk = 4
}

local currentBuffs = {
    [BUFF_TYPES.OFFENCE] = 0,
    [BUFF_TYPES.DEFENCE] = 0
}

local function notifyChange()
    AceConfigRegistry:NotifyChange("TEARollHelperRolls")
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

function roll()
    RandomRoll(1, rules.MAX_ROLL)
end

function freeRoll()
    events.listenForRolls()
    roll()
end

function handleRollResult(roll)
    setCurrentRoll(roll)
    notifyChange()
end

function getCurrentBuffs()
    return {
        [BUFF_TYPES.OFFENCE] = currentBuffs[BUFF_TYPES.OFFENCE],
        [BUFF_TYPES.DEFENCE] = currentBuffs[BUFF_TYPES.DEFENCE]
    }
end

function setCurrentBuff(buffType, amount)
    currentBuffs[buffType] = amount
    notifyChange()
end

function clearCurrentBuffs()
    setCurrentBuff(BUFF_TYPES.OFFENCE, 0)
    setCurrentBuff(BUFF_TYPES.DEFENCE, 0)
    notifyChange()
end

turns.BUFF_TYPES = BUFF_TYPES
turns.getCurrentTurnValues = getCurrentTurnValues
turns.setCurrentRoll = setCurrentRoll
turns.setAttackValues = setAttackValues
turns.setDefendValues = setDefendValues
turns.freeRoll = freeRoll
turns.handleRollResult = handleRollResult
turns.getCurrentBuffs = getCurrentBuffs
turns.setCurrentBuff = setCurrentBuff
turns.clearCurrentBuffs = clearCurrentBuffs