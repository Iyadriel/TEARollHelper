local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local events = ns.events
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

local ROLL_MODES = {
    DISADVANTAGE = -1,
    NORMAL = 0,
    ADVANTAGE = 1
}

local isRolling, setCurrentRoll, getCurrentTurnValues, handleRollResult
local getRollMode, setRollMode
local roll

local currentTurnValues = {
    isRolling = false,
    roll = 1,
    rollMode = ROLL_MODES.NORMAL,
}
local totalRequiredRolls = 1
local remainingRolls = 1

local function notifyChange()
    AceConfigRegistry:NotifyChange(ui.modules.turn.name)
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

local function sendRoll()
    events.listenForRolls()
    RandomRoll(1, rules.rolls.MAX_ROLL)
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

    totalRequiredRolls = numRolls
    remainingRolls = numRolls

    sendRoll()
end

function handleRollResult(result)
    local rollMode = getRollMode()

    if
        (remainingRolls == totalRequiredRolls) or
        (rollMode == ROLL_MODES.ADVANTAGE and result > currentTurnValues.roll) or
        (rollMode == ROLL_MODES.DISADVANTAGE and result < currentTurnValues.roll) then
        setCurrentRoll(result)
    end

    remainingRolls = remainingRolls - 1

    if remainingRolls > 0 then
        sendRoll()
    else
        currentTurnValues.isRolling = false
        notifyChange()
    end
end

turns.ROLL_MODES = ROLL_MODES
turns.getCurrentTurnValues = getCurrentTurnValues
turns.isRolling = isRolling
turns.setCurrentRoll = setCurrentRoll
turns.getRollMode = getRollMode
turns.setRollMode = setRollMode
turns.roll = roll
turns.handleRollResult = handleRollResult