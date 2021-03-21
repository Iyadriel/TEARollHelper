local _, ns = ...

local bus = ns.bus
local constants = ns.constants
local gameEvents = ns.gameEvents
local rollHandler = ns.rollHandler
local rules = ns.rules
local ui = ns.ui

local EVENTS = bus.EVENTS
local ROLL_MODES = constants.ROLL_MODES

local isRolling, setCurrentRoll, handleRollResult
local doRoll

local rollValues = {
    isRolling = false,
    tempRoll = nil,
    action = nil,
    tempMomentOfExcellence = false,
    tempRollMode = nil,
    tempMaxRoll = nil,
    tempIsFateRoll = nil,
}
local totalRequiredRolls = 1
local remainingRolls = 1

local function updateUI()
    ui.update(ui.modules.turn.name)
end

function isRolling()
    return rollValues.isRolling
end

function setCurrentRoll(roll)
    bus.fire(EVENTS.ROLL_CHANGED, rollValues.action, roll)
end

local function setAction(action)
    rollValues.action = action
    rollValues.tempMaxRoll = rules.rolls.getMaxRoll(action)
end

local function resetTempValues()
    rollValues.tempMomentOfExcellence = false
    rollValues.tempRollMode = nil
    rollValues.tempRoll = nil
    rollValues.tempMaxRoll = nil
    rollValues.tempIsFateRoll = nil
end

local function getMinRoll()
    return rollValues.tempMomentOfExcellence and 20 or rules.rolls.MIN_ROLL
end

local function sendRoll()
    gameEvents.listenForRolls()
    RandomRoll(getMinRoll(), rollValues.tempMaxRoll)
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

function doRoll(rollMode, rollModeModifier, isFateRoll)
    rollMode = rollMode + rollModeModifier
    rollMode = max(ROLL_MODES.DISADVANTAGE, min(ROLL_MODES.ADVANTAGE, rollMode))

    rollValues.tempMomentOfExcellence = false
    rollValues.tempRollMode = rollMode
    rollValues.isRolling = true
    rollValues.tempIsFateRoll = isFateRoll

    updateUI() -- so we can update the button state

    local numRolls = getRequiredRollsForTurn()
    totalRequiredRolls = numRolls
    remainingRolls = numRolls

    sendRoll()
end

local function doFateRoll(currentRoll, rollMode, rollModeModifier)
    rollValues.tempMaxRoll = rollValues.tempMaxRoll - currentRoll
    doRoll(rollMode, rollModeModifier, true)
end

local function doMomentOfExcellence()
    rollValues.tempMomentOfExcellence = true
    rollValues.tempRollMode = ROLL_MODES.NORMAL
    rollValues.isRolling = true
    rollValues.tempIsFateRoll = false

    updateUI() -- so we can update the button state

    totalRequiredRolls = 1
    remainingRolls = 1

    sendRoll()
end

function handleRollResult(result)
    local rollMode = rollValues.tempRollMode
    local roll = rollValues.tempRoll

    if
        (remainingRolls == totalRequiredRolls) or
        (rollMode == ROLL_MODES.ADVANTAGE and result > roll) or
        (rollMode == ROLL_MODES.DISADVANTAGE and result < roll) then
            rollValues.tempRoll = result
    end

    remainingRolls = remainingRolls - 1

    if remainingRolls > 0 then
        sendRoll()
    else
        rollValues.isRolling = false

        if rollValues.tempIsFateRoll then
            bus.fire(EVENTS.FATE_ROLLED, rollValues.action, rollValues.tempRoll)
        else
            setCurrentRoll(rollValues.tempRoll)
        end

        resetTempValues()

        updateUI()
    end
end

rollHandler.isRolling = isRolling
rollHandler.setCurrentRoll = setCurrentRoll
rollHandler.setAction = setAction
rollHandler.roll = doRoll
rollHandler.fateRoll = doFateRoll
rollHandler.doMomentOfExcellence = doMomentOfExcellence
rollHandler.handleRollResult = handleRollResult