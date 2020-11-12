local _, ns = ...

local bus = ns.bus
local comms = ns.comms
local characterState = ns.state.character
local party = ns.state.party
local models = ns.models

local EVENTS = bus.EVENTS
local MSG_TYPES = comms.MSG_TYPES

local broadcast = comms.broadcast
local CharacterStatus = models.CharacterStatus

local function getStatus()
    local name = UnitName("player")
    local currentHP = characterState.state.health.get()
    local maxHP = characterState.state.maxHealth.get()
    local criticalWounds = characterState.state.criticalWounds.list()

    return CharacterStatus:New(name, currentHP, maxHP, criticalWounds)
end

-- [[ Send ]]

-- Broadcast your own status so that people can update you in their party state.
local function broadcastCharacterStatus()
    TEARollHelper:Debug("[comms] broadcastCharacterStatus")
    return comms.serializeMsg(MSG_TYPES.CHARACTER_STATUS_UPDATE, getStatus())
end

-- Request that people send you their status.
local function broadcastGroupStatusRequest()
    TEARollHelper:Debug("[comms] broadcastGroupStatusRequest")
    return comms.serializeMsg(MSG_TYPES.GROUP_STATUS_REQUEST)
end

-- Send your own status to a specific player (because they broadcast a request for this)
local function sendCharacterStatusToPlayer(targetPlayerName)
    TEARollHelper:Debug("[comms] sendCharacterStatusToPlayer:", targetPlayerName)

    local msg = comms.serializeMsg(MSG_TYPES.CHARACTER_STATUS_UPDATE, getStatus())
    comms.sendMsg(msg, "WHISPER", targetPlayerName)
end

-- [[ Receive ]]

local function onStatusReceived(sender, payload)
    local characterStatus = CharacterStatus:New(sender, payload.currentHealth, payload.maxHealth, payload.criticalWounds)
    party.state.partyMembers.addOrUpdate(sender, characterStatus)
end

local function onGroupStatusRequestReceived(sender)
    sendCharacterStatusToPlayer(sender)
end

-- [[ Setup ]]

comms.registerMsgHandler(MSG_TYPES.CHARACTER_STATUS_UPDATE, onStatusReceived)
comms.registerMsgHandler(MSG_TYPES.GROUP_STATUS_REQUEST, onGroupStatusRequestReceived)

bus.addListener(EVENTS.COMMS_READY, function()
    local BUCKET_MSG = "TEA_BUCKET_STATUS_BROADCAST"

    local broadcastGroupStatusRequestCB = broadcast(broadcastGroupStatusRequest)
    local broadcastCharacterStatusCB = broadcast(broadcastCharacterStatus)

    local function handleGameEvent(event)
        TEARollHelper:Debug("[comms]", event)
        -- Request that people send you their status when you join a group or log in/reload UI.
        broadcastGroupStatusRequestCB()
        -- Let them know your status, too.
        broadcastCharacterStatusCB()
    end

    local function bucketBroadcast()
        TEARollHelper:SendMessage(BUCKET_MSG)
    end

    TEARollHelper:RegisterEvent("PLAYER_LOGIN", handleGameEvent)
    TEARollHelper:RegisterEvent("GROUP_JOINED", handleGameEvent)

    -- character health events can be spammy, so use a bucket to make sure we don't send too many.
    TEARollHelper:RegisterBucketMessage(BUCKET_MSG, 2, broadcastCharacterStatusCB)
    bus.addListener(EVENTS.CHARACTER_HEALTH, bucketBroadcast)
    bus.addListener(EVENTS.CHARACTER_MAX_HEALTH, bucketBroadcast)
    bus.addListener(EVENTS.CRITICAL_WOUND_TOGGLED, bucketBroadcast)

    bus.addListener(EVENTS.COMMS_FORCE_REFRESH, broadcastGroupStatusRequestCB)
end)