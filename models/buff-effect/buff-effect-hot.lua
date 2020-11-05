local _, ns = ...

local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectHealingOverTime = BuffEffect:NewFromObj({})

function BuffEffectHealingOverTime:New(healingPerTick)
    local buff = BuffEffect:NewFromObj({
        healingPerTick = healingPerTick
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectHealingOverTime:Apply()

end

function BuffEffectHealingOverTime:Remove()

end

function BuffEffectHealingOverTime:GetTooltipText()
    return "Healing for " .. self.healingPerTick .. " at the start of every turn."
end

models.BuffEffectHealingOverTime = BuffEffectHealingOverTime