local _, ns = ...

local actions = ns.actions
local bus = ns.bus
local constants = ns.constants
local characterState = ns.state.character
local feats = ns.resources.feats
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local COLOURS = TEARollHelper.COLOURS
local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

-- [[ Resources ]]

bus.addListener(EVENTS.FATE_POINT_USED, function()
    TEARollHelper:Print("Using Fate Point.")
end)

bus.addListener(EVENTS.BLOOD_HARVEST_CHARGES_USED, function(numCharges)
    TEARollHelper:Print(COLOURS.FEATS.BLOOD_HARVEST .. "You used " .. numCharges .. " Blood Harvest charge(s).")
end)

bus.addListener(EVENTS.GREATER_HEAL_CHARGES_USED, function(numCharges)
    TEARollHelper:Print("You used " .. numCharges .. " Greater Heal charge(s).")
end)

-- [[ Actions ]]

bus.addListener(EVENTS.ACTION_PERFORMED, function(actionType, action, hideMsg)
    if not hideMsg then
        TEARollHelper:Print(actions.toString(actionType, action))
    end
end)

-- [[ Character effects ]]

bus.addListener(EVENTS.DAMAGE_PREVENTED_COUNTER_RESET, function()
    TEARollHelper:Print(COLOURS.MASTERY .. "Your 'Damage prevented' counter was maxed out and has been reset.")
end)

bus.addListener(EVENTS.DAMAGE_TAKEN, function(incomingDamage, damageTaken, overkill)
    local initialColour = damageTaken > 0 and COLOURS.DAMAGE or COLOURS.NOTE

    local msg = initialColour .. "You take " .. damageTaken .. " damage. "

    msg = msg .. COLOURS.NOTE .. "[" .. characterState.summariseHP() .. "]"

    if overkill > 0 then
        msg = msg .. COLOURS.NOTE .. " (Incoming dmg = " .. incomingDamage .. ", overkill = " .. overkill .. ")"
    end

    TEARollHelper:Print(msg)
end)

bus.addListener(EVENTS.HEALED, function(amountHealed, netAmountHealed, overhealing)
    local initialColour = netAmountHealed > 0 and COLOURS.HEALING or COLOURS.NOTE

    local msg = initialColour .. "You are healed for " .. netAmountHealed .. " HP. "

    msg = msg .. COLOURS.NOTE .. "[" .. characterState.summariseHP() .. "]"

    if overhealing > 0 then
        msg = msg .. COLOURS.NOTE .. " (Heal of " .. amountHealed .. " overhealed by " .. overhealing .. ")"
    end

    TEARollHelper:Print(msg)
end)

bus.addListener(EVENTS.TRAIT_ACTIVATED, function(traitID, msg)
    TEARollHelper:Print("Activated trait:", TRAITS[traitID].name)

    if traitID == TRAITS.LIFE_PULSE.id then
        TEARollHelper:Print(COLOURS.HEALING .. "You can heal everyone in melee range of your target.")
    elseif traitID == TRAITS.VINDICATION.id then
        TEARollHelper:Print(COLOURS.HEALING .. "You may heal for the stated amount.")
    end

    if msg then
        TEARollHelper:Print(msg)
    end
end)

-- [[ Buffs ]]

bus.addListener(EVENTS.STAT_BUFF_ADDED, function(stat, amount)
    TEARollHelper:Print("Your " .. constants.STAT_LABELS[stat] .. " stat has been buffed by " .. amount .. ".")
end)

bus.addListener(EVENTS.BASE_DMG_BUFF_ADDED, function(amount)
    TEARollHelper:Print("Your base damage has been increased by " .. amount .. ".")
end)

bus.addListener(EVENTS.BUFF_STACK_ADDED, function(buff)
    TEARollHelper:Print("Added a stack to buff: " .. buff.label .. ". (" .. buff.stacks .. ")")
end)

bus.addListener(EVENTS.WEAKNESS_DEBUFF_ADDED, function(weaknessID)
    TEARollHelper:Print("Added debuff:", WEAKNESSES[weaknessID].name)
end)

bus.addListener(EVENTS.HEALING_OVER_TIME_BUFF_ADDED, function(label)
    TEARollHelper:Print("Added healing over time effect:", label)
end)

bus.addListener(EVENTS.FEAT_BUFF_ADDED, function(featID)
    TEARollHelper:Print(COLOURS.FEATS.GENERIC .. "Added Feat buff:", FEATS[featID].name)
end)

bus.addListener(EVENTS.BUFF_EXPIRED, function(label)
    TEARollHelper:Print("Buff expired:", label)
end)