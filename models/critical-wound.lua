local _, ns = ...

local buffsState = ns.state.buffs
local characterState = ns.state.character
local constants = ns.constants
local models = ns.models

local BUFF_SOURCES = constants.BUFF_SOURCES

local CriticalWound = {}

function CriticalWound:New(id, index, name, desc, icon, buff)
    local wound = {
        id = id,
        index = index,
        name = name,
        desc = desc,
        icon = icon,
        buff = buff
    }

    setmetatable(wound, self)
    self.__index = self

    return wound
end

function CriticalWound:IsActive()
    return characterState.state.criticalWounds.has(self)
end

function CriticalWound:GetBuffID()
    return "criticalWound_" .. self.id
end

function CriticalWound:Apply()
    if self.buff then
        local newBuff = {
            id = self:GetBuffID(),
            label = self.name,
            icon = self.icon,

            source = BUFF_SOURCES.CRITICAL_WOUND,
            types = self.buff.types,
            canCancel = false,

            -- Extra properties
            actions = self.buff.actions,
            amount = self.buff.amount,
            damagePerTick = self.buff.damagePerTick,
            canBeMitigated = self.buff.canBeMitigated,
            stats = self.buff.stats,
            turnTypeID = self.buff.turnTypeID,
        }

        buffsState.state.activeBuffs.add(newBuff)
    end

    characterState.state.criticalWounds.apply(self)
end

function CriticalWound:Remove()
    if self.buff then
        local existingBuff = buffsState.state.buffLookup.getCriticalWoundDebuff(self)

        if existingBuff then
            buffsState.state.activeBuffs.remove(existingBuff)
        end
    end

    characterState.state.criticalWounds.remove(self)
end

function CriticalWound:Toggle()
    if self:IsActive() then
        self:Remove()
    else
        self:Apply()
    end
end

models.CriticalWound = CriticalWound