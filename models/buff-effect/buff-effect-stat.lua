local _, ns = ...

local buffsState = ns.state.buffs
local constants = ns.constants
local models = ns.models

local STAT_LABELS = constants.STAT_LABELS

local BuffEffect = models.BuffEffect
local BuffEffectStat = BuffEffect:NewFromObj({})

function BuffEffectStat:New(stat, value)
    local buff = BuffEffect:NewFromObj({
        stat = stat,
        value = value
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectStat:Apply()
    local statBuff = buffsState.state.buffs[self.stat]
    statBuff.set(statBuff.get() + self.value)
end

function BuffEffectStat:Remove()
    local statBuff = buffsState.state.buffs[self.stat]
    statBuff.set(statBuff.get() - self.value)
end

function BuffEffectStat:GetTooltipText()
    return self:GetValueTooltipText(STAT_LABELS[self.stat], self.value)
end

models.BuffEffectStat = BuffEffectStat