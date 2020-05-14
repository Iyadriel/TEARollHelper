local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local actions = ns.actions
local events = ns.events
local rules = ns.rules
local turns = ns.turns

local ROLL_MODES = {
    DISADVANTAGE = -1,
    NORMAL = 0,
    ADVANTAGE = 1
}

local ROLL_MODE_LABELS = {
    [ROLL_MODES.DISADVANTAGE] = "Disadvantage",
    [ROLL_MODES.NORMAL] = "Normal",
    [ROLL_MODES.ADVANTAGE] = "Advantage"
}

local BUFF_TYPES = {
    OFFENCE = "offence",
    DEFENCE = "defence"
}

local isRolling, setCurrentRoll, getCurrentTurnValues, handleRollResult
local getRollMode, setRollMode
local getRacialTrait, setRacialTrait
local setAttackValues, getNumGreaterHealSlots, setNumGreaterHealSlots, setDefendValues
local roll
local getCurrentBuffs, setCurrentBuff, clearCurrentBuffs

local currentTurnValues = {
    isRolling = false,
    roll = 1,
    rollMode = ROLL_MODES.NORMAL,
    totalRequiredRolls = 1,
    remainingRolls = 1,

    racialTrait = nil,

    attackThreshold = 12,
    numGreaterHealSlots = 0,
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

function isRolling()
    return currentTurnValues.isRolling
end

function setCurrentRoll(roll)
    currentTurnValues.roll = roll
end

function getCurrentTurnValues()
    return currentTurnValues
end

function getRollMode()
    return currentTurnValues.rollMode
end

function setRollMode(mode)
    currentTurnValues.rollMode = mode
end

function getRacialTrait()
    return currentTurnValues.racialTrait
end

function setRacialTrait(trait)
    currentTurnValues.racialTrait = trait
end

function setAttackValues(attackThreshold)
    currentTurnValues.attackThreshold = attackThreshold
end

function getNumGreaterHealSlots()
    return currentTurnValues.numGreaterHealSlots
end

function setNumGreaterHealSlots(numGreaterHealSlots)
    currentTurnValues.numGreaterHealSlots = numGreaterHealSlots
end

function setDefendValues(defendThreshold, damageRisk)
    if defendThreshold ~= nil then
        currentTurnValues.defendThreshold = defendThreshold
    end
    if damageRisk ~= nil then
        currentTurnValues.damageRisk = damageRisk
    end
end

local function sendRoll()
    events.listenForRolls()
    RandomRoll(1, rules.MAX_ROLL)
end

function roll()
    currentTurnValues.isRolling = true
    notifyChange() -- so we can update the button state

    local numRolls

    if getRollMode() == ROLL_MODES.NORMAL then
        numRolls = 1
    else
        numRolls = 2
    end

    currentTurnValues.totalRequiredRolls = numRolls
    currentTurnValues.remainingRolls = numRolls

    sendRoll()
end

function handleRollResult(result)
    local rollMode = getRollMode()

    if
        (currentTurnValues.remainingRolls == currentTurnValues.totalRequiredRolls) or
        (rollMode == ROLL_MODES.ADVANTAGE and result > currentTurnValues.roll) or
        (rollMode == ROLL_MODES.DISADVANTAGE and result < currentTurnValues.roll) then
        setCurrentRoll(result)
    end

    currentTurnValues.remainingRolls = currentTurnValues.remainingRolls - 1

    if currentTurnValues.remainingRolls > 0 then
        sendRoll()
    else
        currentTurnValues.isRolling = false
        notifyChange()
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
    notifyChange()
end

function clearCurrentBuffs()
    setCurrentBuff(BUFF_TYPES.OFFENCE, 0)
    setCurrentBuff(BUFF_TYPES.DEFENCE, 0)
    notifyChange()
end

turns.ROLL_MODE_LABELS = ROLL_MODE_LABELS
turns.BUFF_TYPES = BUFF_TYPES

turns.getCurrentTurnValues = getCurrentTurnValues

turns.isRolling = isRolling
turns.setCurrentRoll = setCurrentRoll
turns.getRollMode = getRollMode
turns.setRollMode = setRollMode

turns.getRacialTrait = getRacialTrait
turns.setRacialTrait = setRacialTrait

turns.setAttackValues = setAttackValues
turns.getNumGreaterHealSlots = getNumGreaterHealSlots
turns.setNumGreaterHealSlots = setNumGreaterHealSlots
turns.setDefendValues = setDefendValues

turns.roll = roll
turns.handleRollResult = handleRollResult

turns.getCurrentBuffs = getCurrentBuffs
turns.setCurrentBuff = setCurrentBuff
turns.clearCurrentBuffs = clearCurrentBuffs