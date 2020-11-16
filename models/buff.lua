local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local models = ns.models
local utils = ns.utils

local Buff = {}

local EVENTS = bus.EVENTS

function Buff:NewFromObj(obj)
    local buff = obj

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function Buff:New(id, label, icon, duration, canCancel, effects)
    if label:trim() == "" then
        label = "Buff"
    end

    if canCancel == nil then
        canCancel = true
    end

    local buff = {
        id = id,
        --source = obj.source,
        label = label,
        icon = icon,
        duration = utils.deepCopy(duration),
        originalDuration = utils.deepCopy(duration),
        numStacks = 1,
        canCancel = canCancel,
        effects = effects or {},
    }

    return Buff:NewFromObj(buff)
end

function Buff:IsActive()
    buffsState.state.buffLookup.get(self.id)
end

function Buff:GetDuration()
    return self.duration
end

function Buff:GetEffectOfType(BuffEffect)
    for _, effect in ipairs(self.effects) do
        if effect:Is(BuffEffect) then
            return effect
        end
    end
    return nil
end

function Buff:Apply()
    for _, effect in ipairs(self.effects) do
        effect:Apply()
    end
    buffsState.state.activeBuffs.add(self)
end

function Buff:Remove()
    for _, effect in ipairs(self.effects) do
        effect:Remove(self.numStacks)
    end
    buffsState.state.activeBuffs.remove(self)
end

function Buff:Cancel()
    self:Remove()
    bus.fire(EVENTS.BUFF_CANCELLED, self.id)
end

function Buff:AddStack()
    for _, effect in ipairs(self.effects) do
        effect:AddStack()
    end
    self.numStacks = self.numStacks + 1
    bus.fire(EVENTS.BUFF_STACK_ADDED, self)
end

function Buff:RefreshDuration()
    self.duration = utils.deepCopy(self.originalDuration)
end

function Buff:ShouldExpire(turnTypeID)
    return self.duration and self.duration:ShouldExpire(turnTypeID)
end

function Buff:Expire()
    self:Remove()
    bus.fire(EVENTS.BUFF_EXPIRED, self.id, self.label)
end

function Buff:GetTooltip()
    local msg = {}

    for i, effect in ipairs(self.effects) do
        table.insert(msg, "|n")
        table.insert(msg, effect:GetTooltipText())
    end

    if self.duration then
        table.insert(msg, "|n")
        table.insert(msg, TEARollHelper.COLOURS.NOTE)
        table.insert(msg, self.duration:GetTooltipText())
    end

    return table.concat(msg)
end

models.Buff = Buff