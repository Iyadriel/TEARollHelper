local _, ns = ...

local buffsState = ns.state.buffs
local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectBaseDamage = BuffEffect:NewFromObj({})

function BuffEffectBaseDamage:New(value)
    local buff = BuffEffect:NewFromObj({
        value = value
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectBaseDamage:Apply()
    buffsState.state.buffs.baseDamage.set(buffsState.state.buffs.baseDamage.get() + self.value)
end

function BuffEffectBaseDamage:Remove()
    buffsState.state.buffs.baseDamage.set(buffsState.state.buffs.baseDamage.get() - self.value)
end

function BuffEffectBaseDamage:GetTooltipText()
    return self:GetValueTooltipText("Base damage", self.value)
end

models.BuffEffectBaseDamage = BuffEffectBaseDamage