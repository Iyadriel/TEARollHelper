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

local isRolling, setCurrentRoll, setPreppedRoll, getRollValues, handleRollResult
local getRollMode, setRollMode
local doRoll

local rollValues = {
    isRolling = false,
    roll = 1,
    rollMode = nil,

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
    return rollValues.isRolling
end

function setCurrentRoll(roll)
    rollValues.roll = roll
end

function setPreppedRoll(roll)
    rollValues.preppedRoll = roll
end

function getRollValues()
    return rollValues
end

function getRollMode()
    return rollValues.rollMode
end

function setRollMode(mode)
    rollValues.rollMode = mode
end

local function resetRollMode()
    setRollMode(nil)
end

local function resetRollValues()
    setCurrentRoll(1)
    resetRollMode()
    rollValues.preppedRoll = nil
    rollValues.prepMode = false
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

function doRoll(rollMode)
    rollValues.rollMode = rollMode
    rollValues.isRolling = true
    if rollValues.prepMode then
        rollValues.isPrepRolling = true
    else
        rollValues.preppedRoll = nil
    end

    notifyChange() -- so we can update the button state

    local numRolls = getRequiredRollsForTurn()
    totalRequiredRolls = numRolls
    remainingRolls = numRolls

    sendRoll()
end

function handleRollResult(result)
    local rollMode = getRollMode()
    local roll = rollValues.isPrepRolling and rollValues.preppedRoll or rollValues.roll

    if
        (remainingRolls == totalRequiredRolls) or
        (rollMode == ROLL_MODES.ADVANTAGE and result > roll) or
        (rollMode == ROLL_MODES.DISADVANTAGE and result < roll) then
        if rollValues.isPrepRolling then
            setPreppedRoll(result)
        else
            setCurrentRoll(result)
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
        if rollValues.prepMode then
            rollValues.prepMode = false
        else
        end

        rollValues.isRolling = false

        notifyChange()
    end
end

bus.addListener(EVENTS.COMBAT_OVER, resetRollMode)
bus.addListener(EVENTS.FEAT_CHANGED, resetRollValues) -- in case of crit threshold change
bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, resetRollValues) -- in case of crit threshold change
bus.addListener(EVENTS.TURN_CHANGED, resetRollMode)

turns.ROLL_MODES = ROLL_MODES
turns.getRollValues = getRollValues
turns.isRolling = isRolling
turns.setCurrentRoll = setCurrentRoll
turns.setPreppedRoll = setPreppedRoll
turns.roll = doRoll
turns.handleRollResult = handleRollResult