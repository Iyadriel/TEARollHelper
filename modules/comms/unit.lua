local _, ns = ...

local bus = ns.bus
local comms = ns.comms

local EVENTS = bus.EVENTS
local MSG_TYPES = comms.MSG_TYPES

local broadcast = comms.broadcast

local function addUnit(unitIndex, name)
    TEARollHelper:Debug("addUnit", unitIndex, name)
end

local function updateUnit(unitIndex, name)
    TEARollHelper:Debug("updateUnit", unitIndex, name)
end

local function removeUnit(unitIndex)
    TEARollHelper:Debug("removeUnit", unitIndex)
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

-- [[ Setup ]]

comms.registerMsgHandler(MSG_TYPES.UNIT_ADDED, onUnitAddedReceived)
comms.registerMsgHandler(MSG_TYPES.UNIT_UPDATED, onUnitAddedReceived)
comms.registerMsgHandler(MSG_TYPES.UNIT_REMOVED, onUnitRemovedReceived)

bus.addListener(EVENTS.COMMS_READY, function()
    bus.addListener(EVENTS.UNIT_ADDED, broadcast(broadcastUnitAdded))
    bus.addListener(EVENTS.UNIT_UPDATED, broadcast(broadcastUnitUpdated))
    bus.addListener(EVENTS.UNIT_REMOVED, broadcast(broadcastUnitRemoved))
end)