local _, ns = ...

local bus = ns.bus

local traits = ns.resources.traits

local EVENTS = bus.EVENTS
local TRAITS = traits.TRAITS

bus.addListener(EVENTS.STATE_READY, function()
    local traits = TEARollHelper.db.profile.traits
    for slot, id in pairs(traits) do
        -- from 1.6.0
        if id == "BULWARK" then
            traits[slot] = TRAITS.ANQULANS_REDOUBT.id
            TEARollHelper:Print("Migrated trait: Bulwark -> Anqulan's Redoubt")
        end
    end
end)