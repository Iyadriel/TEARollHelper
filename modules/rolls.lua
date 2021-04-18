local _, ns = ...

local constants = ns.constants
local buffsState = ns.state.buffs
local rollHandler = ns.rollHandler
local rolls = ns.rolls
local rules = ns.rules
local rollState = ns.state.rolls
local turnState = ns.state.turn

local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local TRAITS = traits.TRAITS

local state = rollState.state

local function getRollModeModifier(action)
    local turnTypeID = turnState.state.type.get()

    return rollState.getRollModeModifier(action, turnTypeID)
end

local function getMinRoll(action)
    if action == ACTIONS.damage
    and ((rollState.getAttack() and rollState.getAttack().isCrit) or buffsState.state.buffLookup.getTraitBuffs(TRAITS.VESEERAS_IRE)) then
        return 5
    end

    return rules.rolls.MIN_ROLL
end

local function prepareRoll(action)
    rollHandler.setAction(action)
end

local function performRoll(action)
    local rollMode = state[action].rollMode.get()
    local rollModeMod = getRollModeModifier(action)
    local minRoll = getMinRoll(action)

    prepareRoll(action)

    rollHandler.roll(rollMode, rollModeMod, minRoll, false)
end

local function performFateRoll(action)
    local rollMode = state[action].rollMode.get()
    local rollModeMod = getRollModeModifier(action)
    local minRoll = getMinRoll(action)

    prepareRoll(action)

    local currentRoll = state[action].currentRoll.get()
    rollHandler.fateRoll(currentRoll, rollMode, rollModeMod, minRoll)
end

rolls.getRollModeModifier = getRollModeModifier
rolls.getMinRoll = getMinRoll
rolls.performRoll = performRoll
rolls.performFateRoll = performFateRoll
