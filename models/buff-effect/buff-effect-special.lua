local _, ns = ...

local buffsState = ns.state.buffs
local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectSpecial = BuffEffect:NewFromObj({})

function BuffEffectSpecial:New(tooltipText)
    local buff = BuffEffect:NewFromObj({
        tooltipText = tooltipText,
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectSpecial:GetTooltipText()
    return self.tooltipText
end

models.BuffEffectSpecial = BuffEffectSpecial