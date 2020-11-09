local _, ns = ...

local bus = ns.bus
local characterState = ns.state.character
local models = ns.models

local CriticalWoundDebuff = models.CriticalWoundDebuff

local EVENTS = bus.EVENTS

local CriticalWound = {}

function CriticalWound:NewFromObj(obj)
    local wound = obj

    setmetatable(wound, self)
    self.__index = self

    return wound
end

function CriticalWound:New(id, index, name, desc, icon, buffSpec)
    local wound = {
        id = id,
        index = index,
        name = name,
        desc = desc,
        icon = icon,
    }

    if buffSpec then
        wound.debuff = CriticalWoundDebuff:New(wound, buffSpec.effects)
    end

    return CriticalWound:NewFromObj(wound)
end

function CriticalWound:GetDebuff()
    return self.debuff
end

function CriticalWound:IsActive()
    return characterState.state.criticalWounds.has(self)
end

function CriticalWound:Apply()
    if self.debuff then
        self.debuff:Apply()
    end

    characterState.state.criticalWounds.apply(self)
    bus.fire(EVENTS.CRITICAL_WOUND_TOGGLED, self.id)
end

function CriticalWound:Remove()
    if self.debuff then
        self.debuff:Remove()
    end

    characterState.state.criticalWounds.remove(self)
    bus.fire(EVENTS.CRITICAL_WOUND_TOGGLED, self.id)
end

function CriticalWound:Toggle()
    if self:IsActive() then
        self:Remove()
    else
        self:Apply()
    end
end

models.CriticalWound = CriticalWound