local _, ns = ...

local bus = ns.bus
local constants = ns.constants
local characterState = ns.state.character.state
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local COLOURS = TEARollHelper.COLOURS
local EVENTS = bus.EVENTS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

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
    local initialColour = netAmountHealed > 0 and COLOURS.HEALING or COLOURS.NOTE

    local msg = initialColour .. "You are healed for " .. netAmountHealed .. " HP."
    if overhealing > 0 then
        msg = msg .. COLOURS.NOTE .. " (Heal of " .. amountHealed .. " overhealed by " .. overhealing .. ")"
    end
    TEARollHelper:Print(msg)
    printCriticalHealth()
end)

bus.addListener(EVENTS.FATE_POINT_USED, function()
    TEARollHelper:Print("Using Fate Point.")
end)

bus.addListener(EVENTS.STAT_BUFF_ADDED, function(stat, amount)
    TEARollHelper:Print("Your " .. constants.STAT_LABELS[stat] .. " stat has been buffed by " .. amount .. ".")
end)

bus.addListener(EVENTS.BUFF_STACK_ADDED, function(buff)
    TEARollHelper:Print("Added a stack to buff: " .. buff.label .. ". (" .. buff.stacks .. ")")
end)

bus.addListener(EVENTS.TRAIT_ACTIVATED, function(traitID)
    TEARollHelper:Print("Activated trait:", TRAITS[traitID].name)
end)

bus.addListener(EVENTS.WEAKNESS_DEBUFF_ADDED, function(weaknessID)
    TEARollHelper:Print("Added debuff:", WEAKNESSES[weaknessID].name)
end)

bus.addListener(EVENTS.BUFF_EXPIRED, function(label)
    TEARollHelper:Print("Buff expired:", label)
end)