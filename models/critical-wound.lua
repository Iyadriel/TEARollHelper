local _, ns = ...

local buffsState = ns.state.buffs
local constants = ns.constants
local models = ns.models

local BUFF_SOURCES = constants.BUFF_SOURCES

local CriticalWound = {
    index = nil,
    name = "",
    desc = "",
    icon = "",
    buff = nil,
    isActive = false,
}

function CriticalWound:New(resource, index)
    local wound = resource

    setmetatable(wound, self)
    self.__index = self

    wound.index = index

    return wound
end

function CriticalWound:Apply()
    local newBuff = {
        id = "criticalWound_" .. self.index,
        label = self.name,
        icon = self.icon,

        source = BUFF_SOURCES.CRITICAL_WOUND,
        types = self.buff.types,
        canCancel = false,

        -- Extra properties
        actions = self.buff.actions,
        amount = self.buff.amount,
        damagePerTick = self.buff.damagePerTick,
        ignoreDmgReduction = self.buff.ignoreDmgReduction,
        turnTypeID = self.buff.turnTypeID,
    }

    buffsState.state.activeBuffs.add(newBuff)

    self.isActive = true
end

function CriticalWound:Remove()
    local existingBuff = buffsState.state.buffLookup.getCriticalWoundDeBuff(self.index)

    if existingBuff then
        buffsState.state.activeBuffs.remove(existingBuff)
    end

    self.isActive = false
end

function CriticalWound:Toggle()
    if self.isActive then
        self:Remove()
    else
        self:Apply()
    end
end

models.CriticalWound = CriticalWound