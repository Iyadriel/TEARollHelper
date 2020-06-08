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

local function useTraitCharge(traitGetSet)
    traitGetSet.set(traitGetSet.get() - 1)
end

-- [[ Out of combat ]]

local function useSecondWind()
    state.health.heal(rules.traits.SECOND_WIND_HEAL_AMOUNT)
    useTraitCharge(state.featsAndTraits.numSecondWindCharges)
    bus.fire(EVENTS.TRAIT_ACTIVATED, TRAITS.SECOND_WIND.id)
end

-- [[ Rolls ]]

local function useBulwark()
    buffs.addTraitBuff(TRAITS.BULWARK)
    useTraitCharge(state.featsAndTraits.numBulwarkCharges)
    bus.fire(EVENTS.TRAIT_ACTIVATED, TRAITS.BULWARK.id)
end

local function confirmReboundRoll()
    buffs.addWeaknessDebuff(WEAKNESSES.REBOUND)
    characterState.state.health.damage(rules.rolls.calculateReboundDamage())
end

local function useFatePoint()
    state.numFatePoints.set(state.numFatePoints.get() - 1)
end

-- [[ Player turn ]]

local function useFocus()
    buffs.addTraitBuff(TRAITS.FOCUS)
    useTraitCharge(state.featsAndTraits.numFocusCharges)
    bus.fire(EVENTS.TRAIT_ACTIVATED, TRAITS.FOCUS.id)
end


-- [[ Enemy turn ]]

local function confirmDefenceAction(defence)
    state.health.damage(defence.damageTaken)
end

local function confirmMeleeSaveAction(meleeSave)
    state.health.damage(meleeSave.damageTaken)
end

-- [[ Exports ]]

consequences.useSecondWind = useSecondWind

consequences.useBulwark = useBulwark
consequences.confirmReboundRoll = confirmReboundRoll
consequences.useFatePoint = useFatePoint

consequences.useFocus = useFocus

consequences.confirmDefenceAction = confirmDefenceAction
consequences.confirmMeleeSaveAction = confirmMeleeSaveAction