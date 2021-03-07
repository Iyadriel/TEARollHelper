local _, ns = ...

local rollHandler = ns.rollHandler
local rolls = ns.rolls
local rollState = ns.state.rolls
local turnState = ns.state.turn

local state = rollState.state

local function getRollModeModifier(action)
    local turnTypeID = turnState.state.type.get()

    return rollState.getRollModeModifier(action, turnTypeID)
end

local function prepareRoll(action)
    rollHandler.setAction(action)
end

local function performRoll(action)
    local rollMode = state[action].rollMode.get()
    local rollModeMod = getRollModeModifier(action)

    prepareRoll(action)

    rollHandler.roll(rollMode, rollModeMod, false)
end

local function performFateRoll(action)
    local rollMode = state[action].rollMode.get()
    local rollModeMod = getRollModeModifier(action)

    prepareRoll(action)

    local currentRoll = state[action].currentRoll.get()
    rollHandler.fateRoll(rollMode, rollModeMod, currentRoll)
end

rolls.getRollModeModifier = getRollModeModifier
rolls.performRoll = performRoll
rolls.performFateRoll = performFateRoll