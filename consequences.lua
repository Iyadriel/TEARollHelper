local _, ns = ...

local buffs = ns.buffs
local bus = ns.bus
local characterState = ns.state.character
local consequences = ns.consequences
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local EVENTS = bus.EVENTS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local state = characterState.state

local function useTraitCharge(trait)
    local traitGetSet = state.featsAndTraits.numTraitCharges
    traitGetSet.set(trait.id, traitGetSet.get(trait.id) - 1)
    bus.fire(EVENTS.TRAIT_ACTIVATED, trait.id)
end

-- [[ Feats/Traits/Fate ]]

local function useFatePoint()
    state.numFatePoints.set(state.numFatePoints.get() - 1)
    bus.fire(EVENTS.FATE_POINT_USED)
end

-- Traits

local function useBulwark()
    buffs.addTraitBuff(TRAITS.BULWARK)
    useTraitCharge(TRAITS.BULWARK)
end

local function useCalamityGambit()
    buffs.addTraitBuff(TRAITS.CALAMITY_GAMBIT)
    useTraitCharge(TRAITS.CALAMITY_GAMBIT)
end

local function useFocus()
    buffs.addTraitBuff(TRAITS.FOCUS)
    useTraitCharge(TRAITS.FOCUS)
end

local function useLifeWithin()
    buffs.addTraitBuff(TRAITS.LIFE_WITHIN)
    state.health.heal(rules.traits.LIFE_WITHIN_HEAL_AMOUNT)
    useTraitCharge(TRAITS.LIFE_WITHIN)
end

local function useSecondWind()
    state.health.heal(rules.traits.SECOND_WIND_HEAL_AMOUNT)
    useTraitCharge(TRAITS.SECOND_WIND)
end

-- [[ Rolls ]]

local function confirmReboundRoll()
    buffs.addWeaknessDebuff(WEAKNESSES.REBOUND)
    characterState.state.health.damage(rules.rolls.calculateReboundDamage())
end

-- [[ Actions ]]

local function confirmDefenceAction(defence)
    state.health.damage(defence.damageTaken)
end

local function confirmMeleeSaveAction(meleeSave)
    state.health.damage(meleeSave.damageTaken)
end

-- [[ Exports ]]

consequences.useFatePoint = useFatePoint

consequences.useBulwark = useBulwark
consequences.useCalamityGambit = useCalamityGambit
consequences.useFocus = useFocus
consequences.useLifeWithin = useLifeWithin
consequences.useSecondWind = useSecondWind

consequences.confirmReboundRoll = confirmReboundRoll

consequences.confirmDefenceAction = confirmDefenceAction
consequences.confirmMeleeSaveAction = confirmMeleeSaveAction