local _, ns = ...

local models = ns.models

local Buff = models.Buff
local FeatBuff = Buff:NewFromObj({})

function FeatBuff:New(feat, duration, effects)
    -- Base Buff object
    local buff = Buff:New(
        "feat_" .. feat.id,
        feat.name,
        feat.icon,
        duration,
        true,
        effects
    )

    -- Custom FeatBuff properties
    buff.featID = feat.id

    setmetatable(buff, self)
    self.__index = self

    return buff
end

models.FeatBuff = FeatBuff