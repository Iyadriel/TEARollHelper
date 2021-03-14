local _, ns = ...

local buffsState = ns.state.buffs
local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectHealingTaken = BuffEffect:NewFromObj({})

function BuffEffectHealingTaken:New(value)
    local buff = BuffEffect:NewFromObj({
        value = value
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectHealingTaken:Apply()
    buffsState.state.buffs.healingTaken.set(buffsState.state.buffs.healingTaken.get() + self.value)
end

function BuffEffectHealingTaken:Remove()
    buffsState.state.buffs.healingTaken.set(buffsState.state.buffs.healingTaken.get() - self.value)
end

function BuffEffectHealingTaken:GetTooltipText()
    return self:GetValueTooltipText("Healing received", self.value)
end

models.BuffEffectHealingTaken = BuffEffectHealingTaken