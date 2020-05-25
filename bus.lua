local _, ns = ...

local bus = ns.bus

local EVENTS = {
    CHARACTER_HEALTH = "CHARACTER_HEALTH", -- newHealth
    CHARACTER_MAX_HEALTH = "CHARACTER_MAX_HEALTH", -- newHealth
    CHARACTER_STAT_CHANGED = "CHARACTER_STAT_CHANGED", -- stat, value
    FEAT_CHANGED = "FEAT_CHANGED", -- featID
    TRAITS_CHANGED = "TRAITS_CHANGED",
    WEAKNESS_ADDED = "WEAKNESS_ADDED", -- weaknessID
    WEAKNESS_REMOVED = "WEAKNESS_REMOVED", -- weaknessID
    RACIAL_TRAIT_CHANGED = "RACIAL_TRAIT_CHANGED", -- racialTraitID

    -- Resources
    FEAT_CHARGES_CHANGED = "FEAT_CHARGES_CHANGED", -- featID, numCharges
    GREATER_HEAL_CHARGES_CHANGED = "GREATER_HEAL_CHARGES_CHANGED", -- numCharges
    TRAIT_CHARGES_CHANGED = "TRAIT_CHARGES_CHANGED", -- traitID, numCharges

    -- Character effects
    DAMAGE_TAKEN = "DAMAGE_TAKEN", --dmgTaken
    HEALED = "HEALED", -- amountHealed, netAmountHealed, overHealing

    -- Turn
    COMBAT_STARTED = "COMBAT_STARTED",
    COMBAT_OVER = "COMBAT_OVER",
    TURN_CHANGED = "TURN_CHANGED", -- index
}

local listeners = {}

local function addListener(event, callback)
    if not EVENTS[event] then
        TEARollHelper:Print("Attempted to add listener to invalid event:", event)
        return
    end
    if not listeners[event] then
        listeners[event] = {}
    end
    table.insert(listeners[event], callback)
end

local function fire(event, ...)
    TEARollHelper:Debug("Fired", event, ...)
    if not listeners[event] then return end
    for _, callback in ipairs(listeners[event]) do
        callback(...)
    end
end

bus.EVENTS = EVENTS
bus.addListener = addListener
bus.fire = fire