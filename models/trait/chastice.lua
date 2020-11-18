local _, ns = ...

local models = ns.models

local Trait = models.Trait
local Chastice = Trait:NewFromObj({})

function Chastice:New()
    -- Base Trait object
    local trait = Trait:New(
        "CHASTICE",
        "Chastice",
        "Activate to also apply the Heal result of your current Heal roll as damage to an enemy target of your choice. Activate after rolling.",
        "",
        3
    )

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function Chastice:GetActionText(chastice)
    return " You deal " .. chastice.damageDone .. " damage."
end

-- Custom methods

function Chastice:IsUsable(amountHealed)
    return amountHealed > 0
end

function Chastice:GetDamageDone(amountHealed)
    return amountHealed
end

models.Chastice = Chastice