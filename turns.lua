local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local bus = ns.bus
local constants = ns.constants
local gameEvents = ns.gameEvents
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

local EVENTS = bus.EVENTS
local ROLL_MODES = constants.ROLL_MODES

local isRolling, setCurrentRoll, setPreppedRoll, handleRollResult
local doRoll

local rollValues = {
    isRolling = false,
    tempRoll = nil,
    action = nil,
    tempRollMode = nil,

    isPrepRolling = false,
    tempPreppedRoll = nil,
    tempPrepMode = false,
}
local totalRequiredRolls = 1
local remainingRolls = 1

local function notifyChange()
    AceConfigRegistry:NotifyChange(ui.modules.turn.name)
end

function isRolling()
    return rollValues.isRolling
end

function setCurrentRoll(roll)
    bus.fire(EVENTS.ROLL_CHANGED, rollValues.action, roll)
end

function setPreppedRoll(roll)
    bus.fire(EVENTS.PREPPED_ROLL_CHANGED, rollValues.action, roll)
end

local function setAction(action)
    rollValues.action = action
end

local function resetTempValues()
    rollValues.tempRollMode = nil
    rollValues.tempRoll = nil
    rollValues.tempPreppedMode = nil
    rollValues.tempPreppedRoll = nil
end

local function sendRoll()
    gameEvents.listenForRolls()
    RandomRoll(1, rules.rolls.MAX_ROLL)
end

local function getRequiredRollsForTurn()
    local numRolls

    if rollValues.tempRollMode == ROLL_MODES.NORMAL then
        numRolls = 1
    else
        numRolls = 2
    end

    return numRolls
end

function doRoll(rollMode, rollModeModifier, prepMode)
    rollMode = rollMode + rollModeModifier
    rollMode = max(ROLL_MODES.DISADVANTAGE, min(ROLL_MODES.ADVANTAGE, rollMode))

    rollValues.tempRollMode = rollMode
    rollValues.tempPrepMode = prepMode
    rollValues.isRolling = true
    rollValues.isPrepRolling = prepMode

    notifyChange() -- so we can update the button state

    local numRolls = getRequiredRollsForTurn()
    totalRequiredRolls = numRolls
    remainingRolls = numRolls

    sendRoll()
end

function handleRollResult(result)
    local rollMode = rollValues.tempRollMode
    local roll = rollValues.isPrepRolling and rollValues.tempPreppedRoll or rollValues.tempRoll

    if
        (remainingRolls == totalRequiredRolls) or
        (rollMode == ROLL_MODES.ADVANTAGE and result > roll) or
        (rollMode == ROLL_MODES.DISADVANTAGE and result < roll) then
        if rollValues.isPrepRolling then
            rollValues.tempPreppedRoll = result
        else
            rollValues.tempRoll = result
        end
    end

    remainingRolls = remainingRolls - 1

    if remainingRolls > 0 then
        sendRoll()
    elseif rollValues.isPrepRolling then
        local numRolls = getRequiredRollsForTurn()

        totalRequiredRolls = numRolls
        remainingRolls = numRolls

        rollValues.isPrepRolling = false

        sendRoll()
    else
        rollValues.isRolling = false

        setCurrentRoll(rollValues.tempRoll)

        if rollValues.tempPrepMode then
            setPreppedRoll(rollValues.tempPreppedRoll)
        end

        resetTempValues()

        notifyChange()
    end
end

turns.isRolling = isRolling
turns.setCurrentRoll = setCurrentRoll
turns.setPreppedRoll = setPreppedRoll
turns.setAction = setAction
turns.roll = doRoll
turns.handleRollResult = handleRollResult