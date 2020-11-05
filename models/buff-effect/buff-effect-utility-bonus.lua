local _, ns = ...

local buffsState = ns.state.buffs
local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectUtilityBonus = BuffEffect:NewFromObj({})

function BuffEffectUtilityBonus:New(value)
    local buff = BuffEffect:NewFromObj({
        value = value
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectUtilityBonus:Apply()
    buffsState.state.buffs.utilityBonus.set(buffsState.state.buffs.utilityBonus.get() + self.value)
end

function BuffEffectUtilityBonus:Remove()
    buffsState.state.buffs.utilityBonus.set(buffsState.state.buffs.utilityBonus.get() - self.value)
end

function BuffEffectUtilityBonus:GetTooltipText()
    return self:GetValueTooltipText("Utility trait bonus", self.value)
end

models.BuffEffectUtilityBonus = BuffEffectUtilityBonus