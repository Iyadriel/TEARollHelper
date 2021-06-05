local _, ns = ...

local models = ns.models

local Trait = models.Trait
local IHoldYouHurt = Trait:NewFromObj({})

function IHoldYouHurt:New()
    -- Base Trait object
    local trait = Trait:New(
        "I_HOLD_YOU_HURT",
        "I Hold, You Hurt",
        "Activate after a CC roll to increase another player’s damage done against the target by half of the CC roll rounded up for their next attack against the target. They deal this damage even if they fail their offence attack roll. Activate after rolling.",
        nil,
        2
    )

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function IHoldYouHurt:GetActionText(iHoldYouHurt)
    return " You increase another player's damage done against this target by " .. iHoldYouHurt.damageBonus .. " for their next attack."
end

function IHoldYouHurt:calculateDamageDoneBonus(ccValue)
    return ceil(ccValue / 2)
end

models.IHoldYouHurt = IHoldYouHurt
