local _, ns = ...

local buffs = ns.buffs
local bus = ns.bus
local characterState = ns.state.character.state

local COLOURS = TEARollHelper.COLOURS
local EVENTS = bus.EVENTS

local function printCriticalHealth()
    local health = characterState.health.get()
    if health <= 0 then
        TEARollHelper:Print(COLOURS.DAMAGE .. "Critical health! You are at " .. health .. " HP.")
    end
end

bus.addListener(EVENTS.DAMAGE_TAKEN, function(dmgTaken)
    TEARollHelper:Print(COLOURS.DAMAGE .. "You took " .. dmgTaken .. " damage.")
    printCriticalHealth()
end)

bus.addListener(EVENTS.HEALED, function(amountHealed, netAmountHealed, overhealing)
    local msg = COLOURS.HEALING .. "You are healed for " .. netAmountHealed .. " HP."
    if overhealing > 0 then
        msg = msg .. COLOURS.NOTE .. " (Heal of " .. amountHealed .. " overhealed by " .. overhealing .. ")"
    end
    TEARollHelper:Print(msg)
    printCriticalHealth()
end)

bus.addListener(EVENTS.STAT_BUFF_ADDED, function(stat, amount)
    TEARollHelper:Print("Your " .. buffs.STAT_LABELS[stat] .. " stat has been buffed by " .. amount .. ".")
end)