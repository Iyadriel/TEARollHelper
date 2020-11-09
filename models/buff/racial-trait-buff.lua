local _, ns = ...

local models = ns.models

local Buff = models.Buff
local RacialTraitBuff = Buff:NewFromObj({})

function RacialTraitBuff:New(racialTrait, effects)
    -- Base Buff object
    local buff = Buff:New(
        "racial",
        racialTrait.name,
        racialTrait.icon,
        nil, -- no duration
        false,
        effects
    )

    -- Custom RacialTraitBuff properties
    buff.racialTraitID = racialTrait.id

    setmetatable(buff, self)
    self.__index = self

    return buff
end

models.RacialTraitBuff = RacialTraitBuff