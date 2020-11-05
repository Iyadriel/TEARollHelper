local _, ns = ...

local buffsState = ns.state.buffs
local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectRoll = BuffEffect:NewFromObj({})

function BuffEffectRoll:New(turnTypeID, value)
    local buff = BuffEffect:NewFromObj({
        turnTypeID = turnTypeID,
        value = value
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectRoll:Apply()
    local newValue = buffsState.state.buffs.roll.get(self.turnTypeID) + self.value
    buffsState.state.buffs.roll.set(self.turnTypeID, newValue)
end

function BuffEffectRoll:Remove()
    local newValue = buffsState.state.buffs.roll.get(self.turnTypeID) - self.value
    buffsState.state.buffs.roll.set(self.turnTypeID, newValue)
end

function BuffEffectRoll:GetTooltipText()
    return self:GetValueTooltipText("Roll", self.value)
end

models.BuffEffectRoll = BuffEffectRoll