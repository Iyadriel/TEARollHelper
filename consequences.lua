local _, ns = ...

local characterState = ns.state.character
local consequences = ns.consequences
local rules = ns.rules

local state = characterState.state

local function useTraitCharge(traitGetSet)
    traitGetSet.set(traitGetSet.get() - 1)
end

-- [[ Out of combat ]]

local function useSecondWind()
    state.health.heal(rules.traits.SECOND_WIND_HEAL_AMOUNT)
    useTraitCharge(state.featsAndTraits.numSecondWindCharges)
end

-- [[ Enemy turn ]]

-- TODO: use bulwark charge in defence confirmation
local function confirmDefenceAction(defence)
    state.health.damage(defence.damageTaken)
end

local function confirmMeleeSaveAction(meleeSave)
    state.health.damage(meleeSave.damageTaken)
end

consequences.useSecondWind = useSecondWind
consequences.confirmDefenceAction = confirmDefenceAction
consequences.confirmMeleeSaveAction = confirmMeleeSaveAction