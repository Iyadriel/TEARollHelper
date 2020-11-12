local _, ns = ...

local bus = ns.bus
local comms = ns.comms
local environment = ns.state.environment

local EVENTS = bus.EVENTS
local MSG_TYPES = comms.MSG_TYPES

local broadcast = comms.broadcast

local function addUnit(unitIndex, name)
    TEARollHelper:Debug("addUnit", unitIndex, name)
    environment.state.units.add(unitIndex, name, false)
end

local function updateUnit(unitIndex, name)
    TEARollHelper:Debug("updateUnit", unitIndex, name)
    environment.state.units.update(unitIndex, name, false)
end

local function removeUnit(unitIndex)
    TEARollHelper:Debug("removeUnit", unitIndex)
    environment.state.units.remove(unitIndex, false)
end

local function replaceUnits(units)
    TEARollHelper:Debug("replaceUnits", units)
    environment.state.units.replaceList(units, false)
end

-- [[ Send ]]

local function broadcastUnitAdded(unit)
    TEARollHelper:Debug("[comms] broadcastUnitAdded")
    return comms.serializeMsg(MSG_TYPES.UNIT_ADDED, unit)
end

local function broadcastUnitUpdated(unit)
    TEARollHelper:Debug("[comms] broadcastUnitUpdated")
    return comms.serializeMsg(MSG_TYPES.UNIT_UPDATED, unit)
end

local function broadcastUnitRemoved(unitIndex)
    TEARollHelper:Debug("[comms] broadcastUnit")
    return comms.serializeMsg(MSG_TYPES.UNIT_REMOVED, unitIndex)
end

local function broadcastUnitList(units)
    TEARollHelper:Debug("[comms] broadcastUnitList")
    return comms.serializeMsg(MSG_TYPES.UNIT_LIST, units)
end

-- [[ Receive ]]

local function onUnitAddedReceived(sender, payload)
    addUnit(payload.unitIndex, payload.name)
end

local function onUnitUpdatedReceived(sender, payload)
    updateUnit(payload.unitIndex, payload.name)
end

local function onUnitRemovedReceived(sender, unitIndex)
    removeUnit(unitIndex)
end

local function onUnitListReceived(sender, units)
    replaceUnits(units)
end

-- [[ Setup ]]

comms.registerMsgHandler(MSG_TYPES.UNIT_ADDED, onUnitAddedReceived)
comms.registerMsgHandler(MSG_TYPES.UNIT_UPDATED, onUnitUpdatedReceived)
comms.registerMsgHandler(MSG_TYPES.UNIT_REMOVED, onUnitRemovedReceived)
comms.registerMsgHandler(MSG_TYPES.UNIT_LIST, onUnitListReceived)

bus.addListener(EVENTS.COMMS_READY, function()
    local function onUnitEvent(broadcastCB)
        return function(isLocal, ...)
            if isLocal then
                broadcastCB(...)
            end
        end
    end

    bus.addListener(EVENTS.UNIT_ADDED, onUnitEvent(broadcast(broadcastUnitAdded)))
    bus.addListener(EVENTS.UNIT_UPDATED, onUnitEvent(broadcast(broadcastUnitUpdated)))
    bus.addListener(EVENTS.UNIT_REMOVED, onUnitEvent(broadcast(broadcastUnitRemoved)))
    bus.addListener(EVENTS.COMMS_BROADCAST_UNIT_LIST, broadcast(broadcastUnitList))
end)