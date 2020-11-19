local _, ns = ...

local buffs = ns.buffs
local constants = ns.constants
local models = ns.models
local rules = ns.rules

local BuffDuration = models.BuffDuration
local BuffEffectAdvantage = models.BuffEffectAdvantage
local Trait = models.Trait
local TraitBuff = models.TraitBuff
local ApexProtector = Trait:NewFromObj({})

local ACTIONS = constants.ACTIONS
local TURN_TYPES = constants.TURN_TYPES

function ApexProtector:New()
    -- Base Trait object
    local trait = Trait:New(
        "APEX_PROTECTOR",
        "Apex Protector",
        "Activate on an enemy turn. Roll Defence with advantage, give up to five other people your defence roll result if it is higher. Does not count as a save or as damage prevented. Activate before rolling.",
        "Interface\\Icons\\trade_engraving",
        1
    )

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function ApexProtector:Activate()
    buffs.addTraitBuff(self)
    self:UseCharge()

    return "Up to five other people will gain your defence roll result if it is higher than theirs."
end

function ApexProtector:CreateBuff(index)
    return TraitBuff:New(
        self,
        BuffDuration:NewWithTurnType({
            turnTypeID = TURN_TYPES.ENEMY.id,
            remainingTurns = 0,
        }),
        { BuffEffectAdvantage:New({ [ACTIONS.defend] = true, }) },
        index
    )
end

models.ApexProtector = ApexProtector