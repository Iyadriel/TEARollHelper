local _, ns = ...

local buffsState = ns.state.buffs
local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectHealingDone = BuffEffect:NewFromObj({})

function BuffEffectHealingDone:New(value)
    local buff = BuffEffect:NewFromObj({
        value = value
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectHealingDone:Apply()
    buffsState.state.buffs.healingDone.set(buffsState.state.buffs.healingDone.get() + self.value)
end

function BuffEffectHealingDone:Remove()
    buffsState.state.buffs.healingDone.set(buffsState.state.buffs.healingDone.get() - self.value)
end

function BuffEffectHealingDone:GetTooltipText()
    return self:GetValueTooltipText("Healing done", self.value)
end

models.BuffEffectHealingDone = BuffEffectHealingDone