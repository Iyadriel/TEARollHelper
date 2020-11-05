local _, ns = ...

local buffsState = ns.state.buffs
local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectDamageTaken = BuffEffect:NewFromObj({})

function BuffEffectDamageTaken:New(value)
    local buff = BuffEffect:NewFromObj({
        value = value
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectDamageTaken:Apply()
    buffsState.state.buffs.damageTaken.set(buffsState.state.buffs.damageTaken.get() + self.value)
end

function BuffEffectDamageTaken:Remove()
    buffsState.state.buffs.damageTaken.set(buffsState.state.buffs.damageTaken.get() - self.value)
end

function BuffEffectDamageTaken:GetTooltipText()
    return self:GetValueTooltipText("Damage taken", self.value)
end

models.BuffEffectDamageTaken = BuffEffectDamageTaken