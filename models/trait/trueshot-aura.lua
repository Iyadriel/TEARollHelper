local _, ns = ...

local constants = ns.constants
local models = ns.models

local BuffDuration = models.BuffDuration
local BuffEffectBaseDamage = models.BuffEffectBaseDamage
local BuffEffectStat = models.BuffEffectStat
local Trait = models.Trait
local TraitBuff = models.TraitBuff
local TrueshotAura = Trait:NewFromObj({})

local STATS = constants.STATS
local TURN_TYPES = constants.TURN_TYPES

function TrueshotAura:New()
    -- Base Trait object
    local trait = Trait:New(
        "TRUESHOT_AURA",
        "Trueshot Aura",
        "Activate to increase offence and base damage by +3 for friendly characters in melee range of yourself upon activation. Activate outside of rolling.",
        "Interface\\Icons\\ability_trueshot",
        3
    )

    -- Extra properties
    trait.isCustom = true
    trait.player = "IYADRIEL"

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function TrueshotAura:Activate()
    self:UseCharge()
end

function TrueshotAura:CreateBuff(index)
    return TraitBuff:New(
        self,
        BuffDuration:NewWithTurnType({
            turnTypeID = TURN_TYPES.PLAYER.id,
            remainingTurns = 0,
        }),
        {
            BuffEffectStat:New(STATS.offence, 3),
            BuffEffectBaseDamage:New(3),
        },
        index,
        true
    )
end

models.TrueshotAura = TrueshotAura
