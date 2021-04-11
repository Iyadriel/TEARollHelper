local _, ns = ...

local models = ns.models

local Buff = models.Buff
local FeatBuff = Buff:NewFromObj({})

function FeatBuff:New(feat, duration, effects, specIndex, castOnOthers)
    -- Base Buff object
    local buff = Buff:New(
        "feat_" .. feat.id .. "_" .. specIndex,
        feat.name,
        feat.icon,
        duration,
        true,
        effects
    )

    -- Custom FeatBuff properties
    buff.featID = feat.id
    buff.castOnOthers = castOnOthers or false

    setmetatable(buff, self)
    self.__index = self

    return buff
end

models.FeatBuff = FeatBuff
