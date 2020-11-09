local _, ns = ...

local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectDamageOverTime = BuffEffect:NewFromObj({})

function BuffEffectDamageOverTime:New(damagePerTick, canBeMitigated, turnTypeID)
    local buff = BuffEffect:NewFromObj({
        damagePerTick = damagePerTick,
        canBeMitigated = canBeMitigated,
        turnTypeID = turnTypeID,
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectDamageOverTime:GetTooltipText()
    return "Taking " .. self.damagePerTick .. " damage at the start of every turn."
end

models.BuffEffectDamageOverTime = BuffEffectDamageOverTime