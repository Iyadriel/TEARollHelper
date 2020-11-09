local _, ns = ...

local integrations = ns.integrations
local rollHandler = ns.rollHandler

local PLAYER_NAME = UnitName("player")
local TOTALRP3_NAME = "totalRP3"

function TEARollHelper:CHAT_MSG_SYSTEM(event, msg)
    local author, rollResult, rollMin, rollMax = string.match(msg, "(.+) rolls (%d+) %((%d+)-(%d+)%)")
    if author == PLAYER_NAME then
        self:UnregisterEvent("CHAT_MSG_SYSTEM")
        --print(author, rollResult, rollMin, rollMax)
        local rollResultNumber = tonumber(rollResult)
        if rollResultNumber ~= nil then
            rollHandler.handleRollResult(rollResultNumber)
        else
            self:Print("Could not convert roll result to number! Roll result was:", rollResult)
        end
    end
end

function TEARollHelper:ADDON_LOADED(event, addon)
    if addon == TOTALRP3_NAME then
        integrations.InitTRPSync()
        self:UnregisterEvent("ADDON_LOADED")
    end
end

if IsAddOnLoaded(TOTALRP3_NAME) then
    integrations.InitTRPSync()
else
    TEARollHelper:RegisterEvent("ADDON_LOADED")
end

local function listenForRolls()
    TEARollHelper:RegisterEvent("CHAT_MSG_SYSTEM")
end

ns.gameEvents.listenForRolls = listenForRolls