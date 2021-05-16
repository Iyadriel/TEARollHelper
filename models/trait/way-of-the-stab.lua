local _, ns = ...

local buffs = ns.buffs
local constants = ns.constants
local models = ns.models

local BuffDuration = models.BuffDuration
local BuffEffectAdvantage = models.BuffEffectAdvantage
local Trait = models.Trait
local TraitBuff = models.TraitBuff
local WayOfTheStab = Trait:NewFromObj({})

local ACTIONS = constants.ACTIONS
local STATS = constants.STATS
local TURN_TYPES = constants.TURN_TYPES

function WayOfTheStab:New()
    -- Base Trait object
    local trait = Trait:New(
        "WAY_OF_THE_STAB",
        "The Way of the Stab",
        "Activate on an enemy turn to give yourself advantage on defence rolls against enemies you have damaged during the previous player turn, and also let you roll defence against those enemies with your offence stat. Lasts for the current enemy turn. Activate before rolling.",
        "Interface\\Icons\\ability_warrior_riposte",
        3
    )

    trait.requiredStats = {
        {
            [STATS.offence] = 4,
        },
    }

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function WayOfTheStab:Activate()
    buffs.addTraitBuff(self)
    self:UseCharge()
end

function WayOfTheStab:CreateBuff(index)
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

models.WayOfTheStab = WayOfTheStab
