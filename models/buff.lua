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

    local remainingTurns
    if type(duration.remainingTurns) == "table" then
        remainingTurns = utils.shallowCopy(duration.remainingTurns)
    else
        remainingTurns = duration.remainingTurns
    end

    local buff = {
        id = id,
        --source = obj.source,
        label = label,
        icon = icon,
        types = {}, -- TODO remove legacy
        duration = {
            remainingTurns = remainingTurns,
            expireAfterFirstAction = duration.expireAfterFirstAction,
            expireOnCombatEnd = duration.expireOnCombatEnd,
        },
        numStacks = 1,
        canCancel = canCancel,
        effects = effects,
    }

    return Buff:NewFromObj(buff)
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
end

function Buff:AddStack()
    for _, effect in ipairs(self.effects) do
        effect:AddStack()
    end
    self.numStacks = self.numStacks + 1
    bus.fire(EVENTS.BUFF_STACK_ADDED, self)
end

function Buff:GetTooltip()
    local msg = {}

    for _, effect in ipairs(self.effects) do
        table.insert(msg, "|n")
        table.insert(msg, effect:GetTooltipText())
    end

    return table.concat(msg)
end

models.Buff = Buff