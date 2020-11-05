local _, ns = ...

local constants = ns.constants
local models = ns.models
local turnState = ns.state.turn

local TURN_TYPES = constants.TURN_TYPES

local BuffEffect = {}

function BuffEffect:NewFromObj(obj)
    local buffEffect = obj

--[[     buffEffect.appliesToTurns = {
        [TURN_TYPES.PLAYER.id] = true,
    } ]]

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

--[[ function BuffEffect:IsActive()
    local turnTypeID = turnState.state.type.get()
    return self.appliesToTurns[turnTypeID]
end ]]

function BuffEffect:GetTooltipText()
    return "Unknown effect"
end

function BuffEffect:GetValueTooltipText(msgStart, value)
    if value > 0 then
        return msgStart .. " increased by " .. value .. ". "
    else
        return msgStart .. " reduced by " .. abs(value) .. ". "
    end
end

models.BuffEffect = BuffEffect