local _, ns = ...

local models = ns.models

local Buff = models.Buff
local TraitBuff = Buff:NewFromObj({})

function TraitBuff:New(trait, duration, effects, specIndex, castOnOthers)
    -- Base Buff object
    local buff = Buff:New(
        "trait_" .. trait.id .. "_" .. specIndex,
        trait.name,
        trait.icon,
        duration,
        true,
        effects
    )

    -- Custom TraitBuff properties
    buff.traitID = trait.id
    buff.castOnOthers = castOnOthers or false

    setmetatable(buff, self)
    self.__index = self

    return buff
end

models.TraitBuff = TraitBuff
