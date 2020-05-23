local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local bus = ns.bus
local events = ns.events
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

local EVENTS = bus.EVENTS
local ROLL_MODES = {
    DISADVANTAGE = -1,
    NORMAL = 0,
    ADVANTAGE = 1
}

local isRolling, setCurrentRoll, setPreppedRoll, getCurrentTurnValues, handleRollResult
local getRollMode, setRollMode
local roll

local currentTurnValues = {
    isRolling = false,
    roll = 1,
    rollMode = ROLL_MODES.NORMAL,

    isPrepRolling = false,
    preppedRoll = nil,
    prepMode = false,
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

function setPreppedRoll(roll)
    currentTurnValues.preppedRoll = roll
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

local function resetRollMode()
    setRollMode(ROLL_MODES.NORMAL)
end

local function sendRoll()
    events.listenForRolls()
    RandomRoll(1, rules.rolls.MAX_ROLL)
end

local function getRequiredRollsForTurn()
    local numRolls

    if getRollMode() == ROLL_MODES.NORMAL then
        numRolls = 1
    else
        numRolls = 2
    end

    return numRolls
end

function roll()
    currentTurnValues.isRolling = true
    if currentTurnValues.prepMode then
        currentTurnValues.isPrepRolling = true
    end

    notifyChange() -- so we can update the button state

    local numRolls = getRequiredRollsForTurn()
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
        if currentTurnValues.isPrepRolling then
            setPreppedRoll(result)
        else
            setCurrentRoll(result)
        end
    end

    remainingRolls = remainingRolls - 1

    if remainingRolls > 0 then
        sendRoll()
    elseif currentTurnValues.isPrepRolling then
        local numRolls = getRequiredRollsForTurn()

        totalRequiredRolls = numRolls
        remainingRolls = numRolls

        currentTurnValues.isPrepRolling = false

        sendRoll()
    else
        if currentTurnValues.prepMode then
            setCurrentRoll(currentTurnValues.roll + currentTurnValues.preppedRoll)
            currentTurnValues.prepMode = false
        end

        currentTurnValues.isRolling = false
        notifyChange()
    end
end

bus.addListener(EVENTS.COMBAT_OVER, resetRollMode)
bus.addListener(EVENTS.TURN_CHANGED, resetRollMode)

turns.ROLL_MODES = ROLL_MODES
turns.getCurrentTurnValues = getCurrentTurnValues
turns.isRolling = isRolling
turns.setCurrentRoll = setCurrentRoll
turns.getRollMode = getRollMode
turns.setRollMode = setRollMode
turns.roll = roll
turns.handleRollResult = handleRollResult