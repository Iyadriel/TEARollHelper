local _, ns = ...

local integrations = ns.integrations

function integrations.InitTRPSync()
    local TRP3_API = _G.TRP3_API
    local Utils, Events, Globals = TRP3_API.utils, TRP3_API.events, TRP3_API.globals
    local getPlayerCurrentProfileID = TRP3_API.profile.getPlayerCurrentProfileID
    local get = TRP3_API.profile.getData

    -- taken from totalRP3 itself, haven't found an API that does this
    local function incrementCharacterVernum()
        local character = get("player/character");
        character.v = Utils.math.incrementNumber(character.v or 1, 2);
        Events.fireEvent(Events.REGISTER_DATA_UPDATED, Globals.player_id, getPlayerCurrentProfileID(), "character");
    end

--[[     function TEARollHelper:GetTRP3CU()
        return get("player/character/CU")
    end ]]

    local function setCurrently(text)
        local character = get("player/character");
        local old = character.CU;
        if old ~= text then
            character.CU = text
            incrementCharacterVernum()
        end
    end

--[[     TRP3_API.Events.registerCallback("REGISTER_DATA_UPDATED", function()
        local currently = get("player/character/CU")
        state.character.health.set(currently, true)
    end, "TEARollHelper") ]]

    --TEARollHelper.TRP_CONNECTED = true

    integrations.TRP = {
        setCurrently = setCurrently
    }
end