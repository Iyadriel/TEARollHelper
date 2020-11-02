local _, ns = ...

local bus = ns.bus
local comms = ns.comms
local models = ns.models

local EVENTS = bus.EVENTS

local CharacterStatus = models.CharacterStatus

local PREFIX = "TEARollHelper"
local CHANNEL_PARTY = "PARTY"
local CHANNEL_RAID = "RAID"
local MSG_TYPES = {
    CHARACTER_STATUS_UPDATE = "CHARACTER_STATUS_UPDATE", -- an update from someone else's character.
    GROUP_STATUS_REQUEST = "GROUP_STATUS_REQUEST", -- someone requesting that group members send them their status.
}

local function validateStatus(payload)
    return payload.currentHealth ~= nil and payload.maxHealth ~= nil
end

local function onStatusReceived(sender, payload)
    if not validateStatus(payload) then
        TEARollHelper:Print("Received invalid character status from:", sender)
        return
    end

    local characterStatus = CharacterStatus:New(sender, payload.currentHealth, payload.maxHealth)
    bus.fire(EVENTS.COMMS_STATUS_RECEIVED, sender, characterStatus)
end

local function onGroupStatusRequestReceived(sender)
    bus.fire(EVENTS.COMMS_STATUS_REQUEST_RECEIVED, sender)
end

function TEARollHelper:OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= PREFIX then return end

    local success, msgType, payload = TEARollHelper:Deserialize(message)

    if not success then
        TEARollHelper:Print("Failed to parse message from:", sender)
        return
    end

    TEARollHelper:Debug("[comms] received", msgType, "from", sender)

    if msgType == MSG_TYPES.CHARACTER_STATUS_UPDATE then
        onStatusReceived(sender, payload)
    elseif msgType == MSG_TYPES.GROUP_STATUS_REQUEST then
        onGroupStatusRequestReceived(sender)
    else
        TEARollHelper:Print("Received message with unknown type (" .. msgType .. ") from:", sender)
    end
end

local function registerComms()
    TEARollHelper:Debug("[comms] Registering comms")
    TEARollHelper:RegisterComm(PREFIX)
    bus.fire(EVENTS.COMMS_READY)
end

local function getBroadcastChannel(inRaid)
    return inRaid and CHANNEL_RAID or CHANNEL_PARTY
end

-- Broadcast your own status so that people can update you in their party state.
local function broadcastCharacterStatus(characterStatus, inRaid)
    local channel = getBroadcastChannel(inRaid)
    TEARollHelper:Debug("[comms] Broadcasting status to", channel, "(2/2)")
    local msg = TEARollHelper:Serialize(MSG_TYPES.CHARACTER_STATUS_UPDATE, characterStatus)

    TEARollHelper:SendCommMessage(PREFIX, msg, channel)
end

-- Request that people send you their status.
local function broadcastGroupStatusRequest(inRaid)
    local channel = getBroadcastChannel(inRaid)
    TEARollHelper:Debug("[comms] Requesting status from group members in channel", channel, "(2/2)")
    local msg = TEARollHelper:Serialize(MSG_TYPES.GROUP_STATUS_REQUEST)

    TEARollHelper:SendCommMessage(PREFIX, msg, channel)
end

-- Send your own status to a specific player (because they broadcast a request for this)
local function sendCharacterStatusToPlayer(characterStatus, targetPlayerName)
    TEARollHelper:Debug("[comms] Sending status to:", targetPlayerName)
    local msg = TEARollHelper:Serialize(MSG_TYPES.CHARACTER_STATUS_UPDATE, characterStatus)

    TEARollHelper:SendCommMessage(PREFIX, msg, "WHISPER", targetPlayerName)
end

comms.registerComms = registerComms
comms.broadcastCharacterStatus = broadcastCharacterStatus
comms.broadcastGroupStatusRequest = broadcastGroupStatusRequest
comms.sendCharacterStatusToPlayer = sendCharacterStatusToPlayer