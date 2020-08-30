local _, ns = ...

local buffs = ns.buffs
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local enemies = ns.resources.enemies
local environmentState = ns.state.environment.state
local feats = ns.resources.feats
local rollState = ns.state.rolls.state
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local ENEMIES = enemies.ENEMIES
local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local INCOMING_HEAL_SOURCES = constants.INCOMING_HEAL_SOURCES
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
end

local function useCalamityGambit()
    buffs.addTraitBuff(TRAITS.CALAMITY_GAMBIT)
end

local function useFocus()
    buffs.addTraitBuff(TRAITS.FOCUS)
end

local function useLifeWithin()
    buffs.addTraitBuff(TRAITS.LIFE_WITHIN)
    state.health.heal(rules.traits.LIFE_WITHIN_HEAL_AMOUNT, INCOMING_HEAL_SOURCES.SELF)
end

local function useSecondWind()
    state.health.heal(rules.traits.SECOND_WIND_HEAL_AMOUNT, INCOMING_HEAL_SOURCES.SELF)
end

local function useShatterSoul()
    state.health.heal(rules.traits.SHATTER_SOUL_HEAL_AMOUNT, INCOMING_HEAL_SOURCES.SELF)

    if environmentState.enemyId.get() == ENEMIES.DEMON.id then
        buffs.addTraitBuff(TRAITS.SHATTER_SOUL)
    end
end

local function useVersatile()
    local stat1 = rollState.shared.versatile.stat1.get()
    local stat2 = rollState.shared.versatile.stat2.get()
    buffs.addTraitBuff(TRAITS.VERSATILE, {
        [stat1] = -character.getPlayerStat(stat1),
        [stat2] = character.getPlayerStat(stat1),
    })
end

local function useVindication()
end

local TRAIT_FNS = {
    [TRAITS.BULWARK.id] = useBulwark,
    [TRAITS.CALAMITY_GAMBIT.id] = useCalamityGambit,
    [TRAITS.FOCUS.id] = useFocus,
    [TRAITS.LIFE_WITHIN.id] = useLifeWithin,
    [TRAITS.SECOND_WIND.id] = useSecondWind,
    [TRAITS.SHATTER_SOUL.id] = useShatterSoul,
    [TRAITS.VERSATILE.id] = useVersatile,
    [TRAITS.VINDICATION.id] = useVindication,
}

local function useTrait(trait, ...)
    local args = {...}
    return function()
        TRAIT_FNS[trait.id](unpack(args))
        useTraitCharge(trait)
    end
end

-- [[ Rolls ]]

local function confirmReboundRoll()
    buffs.addWeaknessDebuff(WEAKNESSES.REBOUND)
    characterState.state.health.damage(rules.rolls.calculateReboundDamage())
end

-- [[ Actions ]]

local function confirmAttackAction(attack)
    if attack.hasMercyFromPainProc then
        buffs.addFeatBuff(FEATS.MERCY_FROM_PAIN, attack.mercyFromPainBonusHealing)
    end
end

local function confirmDefenceAction(defence)
    if defence.damageTaken > 0 then
        state.health.damage(defence.damageTaken)
    else
        state.defence.damagePrevented.increment(defence.dmgRisk)
    end
end

local function confirmMeleeSaveAction(meleeSave)
    if meleeSave.damageTaken > 0 then
        state.health.damage(meleeSave.damageTaken)
    else
        state.defence.damagePrevented.increment(meleeSave.dmgRisk)
    end
end

-- [[ Exports ]]

consequences.useFatePoint = useFatePoint
consequences.useTrait = useTrait

consequences.confirmReboundRoll = confirmReboundRoll

consequences.confirmAttackAction = confirmAttackAction
consequences.confirmDefenceAction = confirmDefenceAction
consequences.confirmMeleeSaveAction = confirmMeleeSaveAction