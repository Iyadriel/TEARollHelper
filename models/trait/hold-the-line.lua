local _, ns = ...

local models = ns.models

local Trait = models.Trait
local HoldTheLine = Trait:NewFromObj({})

function HoldTheLine:New()
    -- Base Trait object
    local trait = Trait:New(
        "HOLD_THE_LINE",
        "Hold the Line",
        "Activate on a player turn to taunt all enemies in melee range of yourself. On the next enemy turn the taunted enemies can only attack you. Activate instead of rolling.",
        nil,
        1
    )

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function HoldTheLine:Activate()
    self:UseCharge()
    return "You taunt all enemies in melee range of yourself!"
end

models.HoldTheLine = HoldTheLine
