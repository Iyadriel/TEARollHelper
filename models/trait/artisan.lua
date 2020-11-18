local _, ns = ...

local buffs = ns.buffs
local constants = ns.constants
local models = ns.models
local rules = ns.rules

local BuffDuration = models.BuffDuration
local BuffEffectUtilityBonus = models.BuffEffectUtilityBonus
local Trait = models.Trait
local TraitBuff = models.TraitBuff
local Artisan = Trait:NewFromObj({})

local ACTIONS = constants.ACTIONS

function Artisan:New()
    -- Base Trait object
    local trait = Trait:New(
        "ARTISAN",
        "Artisan",
        "Activate to double the bonuses of your Utility traits for your next Utility roll. Activate before rolling.",
        "Interface\\Icons\\trade_engraving",
        3
    )

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function Artisan:Activate()
    buffs.addTraitBuff(self)
    self:UseCharge()
end

function Artisan:CreateBuff(index)
    return TraitBuff:New(
        self,
        BuffDuration:New({
            expireAfterActions = {
                [ACTIONS.utility] = true,
            }
        }),
        { BuffEffectUtilityBonus:New(rules.utility.calculateBaseUtilityBonus()) },
        index
    )
end

models.Artisan = Artisan