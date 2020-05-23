local _, ns = ...

local bus = ns.bus
local characterState = ns.state.character.state

local COLOURS = TEARollHelper.COLOURS
local EVENTS = bus.EVENTS

bus.addListener(EVENTS.DAMAGE_TAKEN, function(dmgTaken)
    TEARollHelper:Print(COLOURS.DAMAGE .. "You took " .. dmgTaken .. " damage.")
    local health = characterState.health.get()
    if health <= 0 then
        TEARollHelper:Print(COLOURS.DAMAGE .. "Critical health! You are at " .. health .. " HP.")
    end
end)