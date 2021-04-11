local _, ns = ...

local models = ns.models

local BuffDuration = models.BuffDuration
local BuffEffectDamageDone = models.BuffEffectDamageDone
local BuffEffectDamageTaken = models.BuffEffectDamageTaken
local BuffEffectHealingTaken = models.BuffEffectHealingTaken
local Trait = models.Trait
local TraitBuff = models.TraitBuff
local MarkOfBenevolence = Trait:NewFromObj({})

function MarkOfBenevolence:New()
    -- Base Trait object
    local trait = Trait:New(
        "MARK_OF_BENEVOLENCE",
        "Mark of Benevolence",
        "Activate on a player turn to bless a friendly player, the blessed player deal 3 more damage, take 3 less damage, and receives 3 more healing from all sources for the current player turn and the following enemy turn. Cannot be cast on yourself. Activate outside of rolling.",
        "Interface\\Icons\\spell_holy_aspiration",
        2
    )

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function MarkOfBenevolence:Activate()
    self:UseCharge()

    return "You bless a player with Mark of Benevolence!"
end

function MarkOfBenevolence:CreateBuff(index)
    return TraitBuff:New(
        self,
        BuffDuration:New({
            remainingTurns = 1,
        }),
        {
            BuffEffectDamageDone:New(3),
            BuffEffectDamageTaken:New(-3),
            BuffEffectHealingTaken:New(3),
        },
        index,
        true
    )
end

models.MarkOfBenevolence = MarkOfBenevolence
