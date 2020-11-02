local _, ns = ...

local bus = ns.bus
local comms = ns.comms
local characterState = ns.state.character
local models = ns.models
local party = ns.state.party

local EVENTS = bus.EVENTS

local CharacterStatus = models.CharacterStatus

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

-- TODO use bucket
local function broadcastStatus()
    TEARollHelper:Debug("[comms] Broadcasting status if in group... (1/2)")

    local inGroup, inRaid = inGroupOrRaid()
    if inGroup then
        local characterStatus = getStatus()
        comms.broadcastCharacterStatus(characterStatus, inRaid)
    end
end

local function requestGroupStatus()
    TEARollHelper:Debug("[comms] Requesting group status if in group... (1/2)")

    local inGroup, inRaid = inGroupOrRaid()
    if inGroup then
        comms.broadcastGroupStatusRequest(inRaid)
    end
end


local function sendCharacterStatusToPlayer(targetPlayerName)
    local characterStatus = getStatus()
    comms.sendCharacterStatusToPlayer(characterStatus, targetPlayerName)
end

bus.addListener(EVENTS.CHARACTER_HEALTH, broadcastStatus)
bus.addListener(EVENTS.CHARACTER_MAX_HEALTH, broadcastStatus)
bus.addListener(EVENTS.CRITICAL_WOUND_TOGGLED, broadcastStatus)

-- see comms.lua for registered events
function TEARollHelper:COMMS_HANDLE_GAME_EVENT(event)
    TEARollHelper:Debug("[comms]", event)
    if event == "PLAYER_LOGIN" or event == "GROUP_JOINED" then
        -- Request that people send you their status when you join a group.
        requestGroupStatus()

        -- Let them know your status, too.
        broadcastStatus()
    end
end

-- a player has requested your status.
bus.addListener(EVENTS.COMMS_STATUS_REQUEST_RECEIVED, sendCharacterStatusToPlayer)

-- received status from a player, update the party state.
bus.addListener(EVENTS.COMMS_STATUS_RECEIVED, updatePartyMember)