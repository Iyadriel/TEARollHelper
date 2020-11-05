local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local models = ns.models

local BuffEffect = models.BuffEffect
local BuffEffectMaxHealth = BuffEffect:NewFromObj({})

local EVENTS = bus.EVENTS

function BuffEffectMaxHealth:New(value)
    local buff = BuffEffect:NewFromObj({
        value = value
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectMaxHealth:Apply()
    buffsState.state.buffs.maxHealth.set(buffsState.state.buffs.maxHealth.get() + self.value)
    bus.fire(EVENTS.MAX_HEALTH_EFFECT, self.value)
end

function BuffEffectMaxHealth:Remove(numStacks)
    buffsState.state.buffs.maxHealth.set(buffsState.state.buffs.maxHealth.get() - (self.value * numStacks))
    bus.fire(EVENTS.MAX_HEALTH_EFFECT, self.value)
end

function BuffEffectMaxHealth:AddStack()
    buffsState.state.buffs.maxHealth.set(buffsState.state.buffs.maxHealth.get() + self.value)
    bus.fire(EVENTS.MAX_HEALTH_EFFECT, self.value)
end

function BuffEffectMaxHealth:GetTooltipText()
    return self:GetValueTooltipText("Maximum health", self.value)
end

models.BuffEffectMaxHealth = BuffEffectMaxHealth