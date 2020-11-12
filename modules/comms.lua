local _, ns = ...

local bus = ns.bus
local comms = ns.comms
local gameAPI = ns.gameAPI

local EVENTS = bus.EVENTS

local PREFIX = "TEARollHelper"
local PROTOCOL_VERSION = GetAddOnMetadata("TEARollHelper", "X-ProtocolVersion")

local MSG_TYPES = {
    CHARACTER_STATUS_UPDATE = 0, -- an update from someone else's character.
    GROUP_STATUS_REQUEST = 1, -- someone requesting that group members send them their status.
    UNIT_ADDED = 2, -- unit added
    UNIT_UPDATED = 3, -- unit updated
    UNIT_REMOVED = 4, -- unit removed
}

local incomingMsgHandlers = {}

function TEARollHelper:OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= PREFIX then return end

    local success, protocolVersion, msgType, payload = TEARollHelper:Deserialize(message)

    if not success then
        TEARollHelper:Debug("[comms] Failed to parse message from:", sender)
        return
    end

    if protocolVersion ~= PROTOCOL_VERSION then
        TEARollHelper:Debug("[comms] Incompatible protocol version", protocolVersion, "from", sender)
        return
    end

    TEARollHelper:Debug("[comms] received", msgType, "from", sender)

    if incomingMsgHandlers[msgType] then
        incomingMsgHandlers[msgType](sender, payload)
    else
        TEARollHelper:Debug("[comms] Received message with unknown type (" .. msgType .. ") from:", sender)
    end
end

local function getBroadcastChannel(inRaid)
    return inRaid and "RAID" or "PARTY"
end

local function registerComms()
    TEARollHelper:Debug("[comms] Registering comms")
    TEARollHelper:RegisterComm(PREFIX)
    bus.fire(EVENTS.COMMS_READY)
end

local function registerMsgHandler(msgType, handler)
    incomingMsgHandlers[msgType] = handler
end

local function serializeMsg(msgType, payload)
    if payload then
        return TEARollHelper:Serialize(PROTOCOL_VERSION, msgType, payload)
    end
    return TEARollHelper:Serialize(PROTOCOL_VERSION, msgType)
end

local function sendMsg(msg, channel, target)
    TEARollHelper:SendCommMessage(PREFIX, msg, channel, target)
end

local function broadcast(commsCallback)
--[[     return function(...)
        local inGroup, inRaid = gameAPI.inGroupOrRaid()
        if not inGroup then
            local channel = "GUILD"
            local msg = commsCallback(...)
            sendMsg(msg, channel)
        end
    end ]]

    return function(...)
        local inGroup, inRaid = gameAPI.inGroupOrRaid()
        if inGroup then
            local channel = getBroadcastChannel(inRaid)
            local msg = commsCallback(...)
            sendMsg(msg, channel)
        end
    end
end

comms.MSG_TYPES = MSG_TYPES
comms.registerComms = registerComms
comms.registerMsgHandler = registerMsgHandler
comms.serializeMsg = serializeMsg
comms.sendMsg = sendMsg
comms.broadcast = broadcast