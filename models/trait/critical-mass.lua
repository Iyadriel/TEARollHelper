local _, ns = ...

local buffs = ns.buffs
local character = ns.character
local models = ns.models

local Trait = models.Trait
local CriticalMass = Trait:NewFromObj({})

function CriticalMass:New()
    -- Base Trait object
    local trait = Trait:New(
        "CRITICAL_MASS",
        "Critical Mass",
        "Activate after a successful Offence Attack roll to deal bonus damage equal to your base Offence stat. Activate after rolling.",
        "",
        2
    )

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function CriticalMass:GetActionText()
    return " (damage from Critical Mass included)"
end

-- Custom methods

function CriticalMass:IsUsable(dmgDealt)
    return dmgDealt > 0
end

function CriticalMass:GetBonusDamage()
    return character.getPlayerOffence()
end

models.CriticalMass = CriticalMass