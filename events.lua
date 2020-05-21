local _, ns = ...

local integrations = ns.integrations
local turns = ns.turns

local PLAYER_NAME = UnitName("player")

function TEARollHelper:CHAT_MSG_SYSTEM(event, msg)
    local author, rollResult, rollMin, rollMax = string.match(msg, "(.+) rolls (%d+) %((%d+)-(%d+)%)")
    if author == PLAYER_NAME then
        self:UnregisterEvent("CHAT_MSG_SYSTEM")
        --print(author, rollResult, rollMin, rollMax)
        local rollResultNumber = tonumber(rollResult)
        if rollResultNumber ~= nil then
            turns.handleRollResult(rollResultNumber)
        else
            self:Print("Could not convert roll result to number! Roll result was:", rollResult)
        end
    end
end

function TEARollHelper:ADDON_LOADED(event, addon)
    if addon == "totalRP3" then
        integrations.InitTRPSync()
        self:UnregisterEvent("ADDON_LOADED")
    end
end
TEARollHelper:RegisterEvent("ADDON_LOADED")

local function listenForRolls()
    TEARollHelper:RegisterEvent("CHAT_MSG_SYSTEM")
end

ns.events.listenForRolls = listenForRolls