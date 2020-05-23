local _, ns = ...

local bus = ns.bus

local EVENTS = {
    COMBAT_STARTED = "COMBAT_STARTED",
    COMBAT_OVER = "COMBAT_OVER",
    FEAT_CHARGES_CHANGED = "FEAT_CHARGES_CHANGED", -- featID, numCharges
    --TRAIT_CHARGES_CHANGED = "TRAIT_CHARGES_CHANGED", -- traitID, numCharges
    CHARACTER_STAT_CHANGED = "CHARACTER_STAT_CHANGED" -- stat, value
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