local _, ns = ...

local bus = ns.bus
local integrations = ns.integrations
local settings = ns.settings

local EVENTS = bus.EVENTS

function integrations.InitTRPSync()
    local AddOn_TotalRP3 = _G.AddOn_TotalRP3
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
        TEARollHelper:Debug("Updating Total RP")
        local character = get("player/character");
        local old = character.CU;
        if old ~= text then
            character.CU = text
            incrementCharacterVernum()
        end
    end

    local function updateCurrently()
        local text = ns.state.character.summariseState()
        setCurrently(text)
    end

    local function autoUpdateCurrently()
        if settings.autoUpdateTRP.get() then
            updateCurrently()
        end
    end

--[[     TRP3_API.Events.registerCallback("REGISTER_DATA_UPDATED", function()
        local currently = get("player/character/CU")
        state.character.health.set(currently, true)
    end, "TEARollHelper") ]]

    --TEARollHelper.TRP_CONNECTED = true

    local function getPlayerColor(playerName)
        if AddOn_TotalRP3 then
            local realmName = GetNormalizedRealmName()
            local player = AddOn_TotalRP3.Player.static.CreateFromNameAndRealm(playerName, realmName)
            if player then
                return player:GetCustomColorForDisplay()
            end
        end
        return nil
    end

    bus.addListener(EVENTS.CHARACTER_HEALTH, autoUpdateCurrently)
    bus.addListener(EVENTS.CHARACTER_MAX_HEALTH, autoUpdateCurrently)
    bus.addListener(EVENTS.CRITICAL_WOUND_TOGGLED, autoUpdateCurrently)

    integrations.TRP = {
        updateCurrently = updateCurrently,
        getPlayerColor = getPlayerColor,
    }
end