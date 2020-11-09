local _, ns = ...

local bus = ns.bus

local traits = ns.resources.traits

local EVENTS = bus.EVENTS
local TRAITS = traits.TRAITS

bus.addListener(EVENTS.STATE_READY, function()
    local traits = TEARollHelper.db.profile.traits
    for slot, id in pairs(traits) do
        -- 1.2.3 to 1.3.0
        if id == "CALAMITY_GAMBIT" then
            traits[slot] = TRAITS.VESEERAS_IRE.id
            TEARollHelper:Print("Migrated trait: Calamity Gambit -> Veseera's Ire")
        end
    end
end)