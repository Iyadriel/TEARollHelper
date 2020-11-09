local _, ns = ...

local models = ns.models

local BuffEffect = {}

function BuffEffect:NewFromObj(obj)
    local buffEffect = obj

    setmetatable(buffEffect, self)
    self.__index = self

    return buffEffect
end

-- Add the effect to state state. Called when buff is added.
function BuffEffect:Apply()

end

-- Remove the effect from state. Called when buff is removed.
-- numStacks: How many stacks the buff has at time of removal
-- Buff effects are responsible for removing all stacks of their applied effect when removed.
function BuffEffect:Remove(numStacks)

end

-- Called by Buff when a stack is added to the buff.
-- Not every effect needs to implement this.
function BuffEffect:AddStack()

end

-- Check if a a BuffEffect is of a certain type (eg BuffEffectAdvantage)
function BuffEffect:Is(buffEffectType)
    return self.__index == buffEffectType
end

function BuffEffect:GetTooltipText()
    return "Unknown effect"
end

function BuffEffect:GetValueTooltipText(msgStart, value)
    if value > 0 then
        return msgStart .. " increased by " .. value .. "."
    else
        return msgStart .. " reduced by " .. abs(value) .. "."
    end
end

models.BuffEffect = BuffEffect