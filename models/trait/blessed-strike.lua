local _, ns = ...

local models = ns.models

local Trait = models.Trait
local BlessedStrike = Trait:NewFromObj({})

function BlessedStrike:New()
    -- Base Trait object
    local trait = Trait:New(
        "BLESSED_STRIKE",
        "Blessed Strike",
        "Activate to turn another player’s damage roll into 10. Activate outside of rolling.",
        nil,
        3
    )

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function BlessedStrike:Activate()
    self:UseCharge()
    return "You turn another player's damage roll into 10."
end

models.BlessedStrike = BlessedStrike
