local _, ns = ...

local bus = ns.bus
local comms = ns.comms
local characterState = ns.state.character
local models = ns.models
local party = ns.state.party

local EVENTS = bus.EVENTS

local CharacterStatus = models.CharacterStatus

local BUCKET_MSG = "TEA_BUCKET_STATUS_BROADCAST"

local function getStatus()
    local name = UnitName("player")
    local currentHP = characterState.state.health.get()
    local maxHP = characterState.state.maxHealth.get()

    return CharacterStatus:New(name, currentHP, maxHP)
end

local function updatePartyMember(name, characterStatus)
    party.state.partyMembers.addOrUpdate(name, characterStatus)
end

local function inGroupOrRaid()
    local inGroup = IsInGroup(LE_PARTY_CATEGORY_HOME)
    local inRaid = IsInRaid(LE_PARTY_CATEGORY_HOME)
    return inGroup, inRaid
end

local function broadcastStatus()
    local inGroup, inRaid = inGroupOrRaid()
    if inGroup then
        local characterStatus = getStatus()
        comms.broadcastCharacterStatus(characterStatus, inRaid)
    end
end

local function requestGroupStatus()
    local inGroup, inRaid = inGroupOrRaid()
    if inGroup then
        comms.broadcastGroupStatusRequest(inRaid)
    end
end


local function sendCharacterStatusToPlayer(targetPlayerName)
    local characterStatus = getStatus()
    comms.sendCharacterStatusToPlayer(characterStatus, targetPlayerName)
end

-- character health events can be spammy, so use a bucket to make sure we don't send too many.
local function bucketBroadcast()
    TEARollHelper:SendMessage(BUCKET_MSG)
end

local function handleGameEvent(event)
    TEARollHelper:Debug("[comms]", event)

    -- Request that people send you their status when you join a group or log in/reload UI.
    requestGroupStatus()

    if event == "GROUP_JOINED" then
        -- Let them know your status, too.
        broadcastStatus()
    end
end

bus.addListener(EVENTS.COMMS_READY, function()
    TEARollHelper:RegisterEvent("PLAYER_LOGIN", handleGameEvent)
    TEARollHelper:RegisterEvent("GROUP_JOINED", handleGameEvent)

    TEARollHelper:RegisterBucketMessage(BUCKET_MSG, 2, broadcastStatus)
    bus.addListener(EVENTS.CHARACTER_HEALTH, bucketBroadcast)
    bus.addListener(EVENTS.CHARACTER_MAX_HEALTH, bucketBroadcast)
    bus.addListener(EVENTS.CRITICAL_WOUND_TOGGLED, bucketBroadcast)

    bus.addListener(EVENTS.COMMS_FORCE_REFRESH, requestGroupStatus)
end)

-- a player has requested your status.
bus.addListener(EVENTS.COMMS_STATUS_REQUEST_RECEIVED, sendCharacterStatusToPlayer)

-- received status from a player, update the party state.
bus.addListener(EVENTS.COMMS_STATUS_RECEIVED, updatePartyMember)