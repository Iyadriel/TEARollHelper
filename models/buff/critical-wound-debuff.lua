local _, ns = ...

local models = ns.models

local Buff = models.Buff
local CriticalWoundDebuff = Buff:NewFromObj({})

function CriticalWoundDebuff:New(criticalWound, effects)
    -- Base Buff object
    local buff = Buff:New(
        "criticalWound_" .. criticalWound.id,
        criticalWound.name,
        criticalWound.icon,
        nil, -- no duration
        false,
        effects
    )

    -- Custom CriticalWoundDebuff properties
    buff.criticalWoundID = criticalWound.id

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function CriticalWoundDebuff:GetCriticalWoundID()
    return self.criticalWoundID
end

models.CriticalWoundDebuff = CriticalWoundDebuff