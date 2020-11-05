local _, ns = ...

local buffsState = ns.state.buffs
local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectDamageDone = BuffEffect:NewFromObj({})

function BuffEffectDamageDone:New(value)
    local buff = BuffEffect:NewFromObj({
        value = value
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectDamageDone:Apply()
    buffsState.state.buffs.damageDone.set(buffsState.state.buffs.damageDone.get() + self.value)
end

function BuffEffectDamageDone:Remove()
    buffsState.state.buffs.damageDone.set(buffsState.state.buffs.damageDone.get() - self.value)
end

function BuffEffectDamageDone:GetTooltipText()
    return self:GetValueTooltipText("Damage done", self.value)
end

models.BuffEffectDamageDone = BuffEffectDamageDone