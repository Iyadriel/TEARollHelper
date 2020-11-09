local _, ns = ...

local models = ns.models

local Buff = models.Buff
local WeaknessDebuff = Buff:NewFromObj({})

function WeaknessDebuff:New(weakness, duration, effects, canCancel)
    -- Base Buff object
    local buff = Buff:New(
        "weakness_" .. weakness.id,
        weakness.name,
        weakness.icon,
        duration,
        canCancel,
        effects
    )

    -- Custom WeaknessDebuff properties
    buff.weaknessID = weakness.id

    setmetatable(buff, self)
    self.__index = self

    return buff
end

models.WeaknessDebuff = WeaknessDebuff