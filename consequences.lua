local _, ns = ...

local actions = ns.actions
local buffs = ns.buffs
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local enemies = ns.resources.enemies
local feats = ns.resources.feats
local rollState = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local ACTIONS = constants.ACTIONS
local ENEMIES = enemies.ENEMIES
local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local INCOMING_HEAL_SOURCES = constants.INCOMING_HEAL_SOURCES
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local state = characterState.state

local function useTraitCharge(trait, msg)
    local traitGetSet = state.featsAndTraits.numTraitCharges
    traitGetSet.set(trait.id, traitGetSet.get(trait.id) - 1)
end

local function useTraitChargeWithMsg(trait, msg)
    useTraitCharge(trait)
    bus.fire(EVENTS.TRAIT_ACTIVATED, trait.id, msg)
end

-- [[ Effects ]]

local function applyFaelunesRegrowth(initialHealAmount)
    local FAELUNES_REGROWTH = TRAITS.FAELUNES_REGROWTH

    characterState.state.health.heal(initialHealAmount, INCOMING_HEAL_SOURCES.OTHER_PLAYER)
    local healingPerTick = rules.traits.calculateRegrowthHealingPerTick(initialHealAmount)
    buffs.addHoTBuff(FAELUNES_REGROWTH.name, FAELUNES_REGROWTH.icon, healingPerTick, FAELUNES_REGROWTH.buffs[1].remainingTurns)
end

-- [[ Feats/Traits/Fate ]]

local function useFatePoint()
    state.numFatePoints.set(state.numFatePoints.get() - 1)
    bus.fire(EVENTS.FATE_POINT_USED)
end

-- Feats

local function enableLivingBarricade()
    buffs.addFeatBuff(FEATS.LIVING_BARRICADE)
end

-- Traits

local function useArtisan()
    buffs.addTraitBuff(TRAITS.ARTISAN)
end

local function useBulwark()
    buffs.addTraitBuff(TRAITS.BULWARK)
end

local function useCalamityGambit()
    buffs.addTraitBuff(TRAITS.CALAMITY_GAMBIT)
end

local function useEmpoweredBlades(defence)
    buffs.addTraitBuff(TRAITS.EMPOWERED_BLADES, ceil(defence.dmgRisk / 2))
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

local function useShatterSoul(attack)
    state.health.heal(rules.traits.SHATTER_SOUL_HEAL_AMOUNT, INCOMING_HEAL_SOURCES.SELF)

    if attack.enemyId == ENEMIES.DEMON.id then
        buffs.addTraitBuff(TRAITS.SHATTER_SOUL)
    end
end

local function useShieldSlam()
    return actions.traitToString(TRAITS.SHIELD_SLAM, rollState.traits.getShieldSlam())
end

local function useVersatile()
    local stat1 = rollState.state.shared.versatile.stat1.get()
    local stat2 = rollState.state.shared.versatile.stat2.get()
    buffs.addTraitBuff(TRAITS.VERSATILE, {
        [stat1] = -character.getPlayerStat(stat1),
        [stat2] = character.getPlayerStat(stat1),
    })
end

local TRAIT_FNS = {
    [TRAITS.ARTISAN.id] = useArtisan,
    [TRAITS.BULWARK.id] = useBulwark,
    [TRAITS.CALAMITY_GAMBIT.id] = useCalamityGambit,
    [TRAITS.EMPOWERED_BLADES.id] = useEmpoweredBlades,
    [TRAITS.FOCUS.id] = useFocus,
    [TRAITS.LIFE_WITHIN.id] = useLifeWithin,
    [TRAITS.SECOND_WIND.id] = useSecondWind,
    [TRAITS.SHIELD_SLAM.id] = useShieldSlam,
    [TRAITS.VERSATILE.id] = useVersatile,
}

local function useTrait(trait)
    return function(...)
        local msg = TRAIT_FNS[trait.id](...)
        useTraitChargeWithMsg(trait, msg)
    end
end

-- [[ Rolls ]]

local function confirmReboundRoll()
    buffs.addWeaknessDebuff(WEAKNESSES.REBOUND)
    characterState.state.health.damage(rules.rolls.calculateReboundDamage())
end

-- [[ Actions ]]

local function confirmAttackAction(attack)
    characterState.state.featsAndTraits.numBloodHarvestSlots.use(attack.numBloodHarvestSlots)

    if attack.hasMercyFromPainProc then
        buffs.addFeatBuff(FEATS.MERCY_FROM_PAIN, attack.mercyFromPainBonusHealing)
    end

    local shatterSoul = attack.traits[TRAITS.SHATTER_SOUL.id]
    if shatterSoul.active then
        useShatterSoul(attack)
    end

    rollState.state.attack.attacks.add(attack)
end

local function confirmPenanceAction(penance)
    characterState.state.healing.numGreaterHealSlots.use(penance.numGreaterHealSlots)
end

local function confirmHealAction(heal)
    characterState.state.healing.numGreaterHealSlots.use(heal.numGreaterHealSlots)
    if heal.outOfCombat and heal.numGreaterHealSlots <= 0 then
        characterState.state.healing.remainingOutOfCombatHeals.spendOne()
    end

    rollState.state.healing.heals.add(heal)
end

local function confirmDefenceAction(defence)
    if defence.damageTaken > 0 then
        state.health.applyDamage(defence.damageTaken)
    end
    if defence.damagePrevented > 0 then
        state.defence.damagePrevented.increment(defence.damagePrevented)
    end
end

local function confirmMeleeSaveAction(meleeSave)
    if meleeSave.damageTaken > 0 then
        state.health.applyDamage(meleeSave.damageTaken)
    end
    if meleeSave.damagePrevented > 0 then
        state.defence.damagePrevented.increment(meleeSave.damagePrevented)
    end
end

local actionFns = {
    [ACTIONS.attack] = confirmAttackAction,
    [ACTIONS.penance] = confirmPenanceAction,
    [ACTIONS.healing] = confirmHealAction,
    [ACTIONS.defend] = confirmDefenceAction,
    [ACTIONS.meleeSave] = confirmMeleeSaveAction,
}

local function confirmAction(actionType, action, hideMsg)
    bus.fire(EVENTS.ACTION_PERFORMED, actionType, action, hideMsg)

    -- not every action has specific effects yet
    if actionFns[actionType] then
        actionFns[actionType](action)
    end

    if action.traits then
        for traitID, traitAction in pairs(action.traits) do
            if traitAction.active then
                useTraitCharge(TRAITS[traitID])
            end
        end
    end

    local actionState = rollState.state[actionType]

    if actionType == ACTIONS.penance then
        rollState.state[ACTIONS.attack].currentRoll.set(nil)
    else
        actionState.currentRoll.set(nil)
    end

    if actionState.resetSlots then
        actionState.resetSlots()
    end
end

-- [[ Exports ]]

consequences.applyFaelunesRegrowth = applyFaelunesRegrowth
consequences.useFatePoint = useFatePoint
consequences.enableLivingBarricade = enableLivingBarricade
consequences.useTrait = useTrait
consequences.confirmReboundRoll = confirmReboundRoll
consequences.confirmAction = confirmAction