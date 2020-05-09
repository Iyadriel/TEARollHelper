local ADDON_NAME, ns = ...

local turns = ns.turns

local PLAYER_NAME = UnitName("player")
local listenForRolls

function TeaRollHelper:CHAT_MSG_SYSTEM(event, msg)
    local author, rollResult, rollMin, rollMax = string.match(msg, "(.+) rolls (%d+) %((%d+)-(%d+)%)")
    if author == PLAYER_NAME then
        --print(author, rollResult, rollMin, rollMax)
        local rollResultNumber = tonumber(rollResult)
        if rollResultNumber ~= nil then
            turns.handleRollResult(rollResultNumber)
        else
            self:Print("Could not convert roll result to number! Roll result was:", rollResult)
        end
        self:UnregisterEvent("CHAT_MSG_SYSTEM")
    end
end

function listenForRolls()
    TeaRollHelper:RegisterEvent("CHAT_MSG_SYSTEM")
end

ns.events.listenForRolls = listenForRolls