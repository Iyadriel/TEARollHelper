local _, ns = ...

local actions = ns.actions
local buffs = ns.buffs
local buffsState = ns.state.buffs
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local models = ns.models
local rollState = ns.state.rolls
local rules = ns.rules

local enemies = ns.resources.enemies
local feats = ns.resources.feats
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local BuffEffectBaseDamage = models.BuffEffectBaseDamage
local BuffEffectDamageDone = models.BuffEffectDamageDone
local BuffEffectHealingDone = models.BuffEffectHealingDone
local BuffEffectHealingOverTime = models.BuffEffectHealingOverTime
local BuffEffectSpecial = models.BuffEffectSpecial
local BuffEffectStat = models.BuffEffectStat

local ACTIONS = constants.ACTIONS
local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local INCOMING_HEAL_SOURCES = constants.INCOMING_HEAL_SOURCES
local STATS = constants.STATS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local state = characterState.state

local function useTraitCharge(trait)
    local traitGetSet = state.featsAndTraits.numTraitCharges
    traitGetSet.set(trait.id, traitGetSet.get(trait.id) - 1)
end

local function useTraitChargeWithMsg(trait, msg)
    useTraitCharge(trait)
    bus.fire(EVENTS.TRAIT_ACTIVATED, trait.id, msg)
end

-- [[ Effects ]]

local function applyFaelunesRegrowth(initialHealAmount)
    characterState.state.health.heal(initialHealAmount, INCOMING_HEAL_SOURCES.OTHER_PLAYER)
    local healingPerTick = rules.traits.calculateRegrowthHealingPerTick(initialHealAmount)
    buffs.addTraitBuff(TRAITS.FAELUNES_REGROWTH, { BuffEffectHealingOverTime:New(healingPerTick) })
end

-- [[ Resources ]]

local function useFatePoint()
    state.numFatePoints.set(state.numFatePoints.get() - 1)
    bus.fire(EVENTS.FATE_POINT_USED)
end

local function restoreGreaterHealSlotWithExcess()
    state.healing.excess.spend(rules.healing.NUM_EXCESS_TO_RESTORE_GREATER_HEAL_SLOT)
    state.healing.numGreaterHealSlots.restore(1)
end

-- Feats

local function applyAvengingGuardian()
    local defenceBuff = buffsState.state.buffs.defence.get()
    local spiritBuff = buffsState.state.buffs.spirit.get()
    buffs.addFeatBuff(FEATS.AVENGING_GUARDIAN, {
        BuffEffectDamageDone:New(rules.feats.calculateAvengingGuardianBonusDmg(defenceBuff, spiritBuff)),
        BuffEffectSpecial:New("You roll attack or CC with your Defence/Spirit stat (whichever is higher)."),
    })
end

local function applyDefensiveTactician(dmgRisk)
    buffs.addFeatBuff(FEATS.DEFENSIVE_TACTICIAN, { BuffEffectDamageDone:New(floor(dmgRisk / 2)) })
end

local function enableFocus()
    buffs.addFeatBuff(FEATS.FOCUS)
end

local function enableLivingBarricade()
    buffs.addFeatBuff(FEATS.LIVING_BARRICADE)
end

-- Traits

local function useAnqulansRedoubt()
    buffs.addTraitBuff(TRAITS.ANQULANS_REDOUBT)
end

local function useGreaterRestoration()
    return "You can remove a critical wound from yourself or someone else."
end

local function useHolyBulwark(isSave)
    local holyBulwark = rollState.traits.getHolyBulwark(isSave)

    if holyBulwark.damagePrevented > 0 then
        state.defence.damagePrevented.increment(holyBulwark.damagePrevented)
    end

    return actions.traitToString(TRAITS.HOLY_BULWARK, holyBulwark)
end

local function useLifeWithin()
    buffs.addTraitBuff(TRAITS.LIFE_WITHIN)
    state.health.heal(rules.traits.LIFE_WITHIN_HEAL_AMOUNT, INCOMING_HEAL_SOURCES.SELF)
end

local function useSecondWind()
    state.health.heal(rules.traits.SECOND_WIND_HEAL_AMOUNT, INCOMING_HEAL_SOURCES.SELF)
end

local function useShieldSlam()
    return actions.traitToString(TRAITS.SHIELD_SLAM, rollState.traits.getShieldSlam())
end

local function useSilamelsAce(action)
    local utilityBonusBuff = buffsState.state.buffs.utilityBonus.get()
    local amount = rules.utility.calculateUtilityTraitBonus(utilityBonusBuff)

    buffs.addTraitBuff(TRAITS.SILAMELS_ACE, {
        BuffEffectStat:New(STATS.offence, amount),
        BuffEffectStat:New(STATS.defence, amount),
        BuffEffectStat:New(STATS.spirit, amount),
    }, 1)

    if action == ACTIONS.attack then
        amount = ceil(amount / 2)

        buffs.addTraitBuff(TRAITS.SILAMELS_ACE, {
            BuffEffectDamageDone:New(amount),
        }, 2)
    end
end

local function useVersatile()
    local stat1 = rollState.state.shared.versatile.stat1.get()
    local stat2 = rollState.state.shared.versatile.stat2.get()
    buffs.addTraitBuff(TRAITS.VERSATILE, {
        BuffEffectStat:New(stat1, -character.getPlayerStat(stat1)),
        BuffEffectStat:New(stat2, character.getPlayerStat(stat1)),
    })
end

local function useVeseerasIre()
    rollState.state.attack.threshold.set(10)

    buffs.addTraitBuff(TRAITS.VESEERAS_IRE, {
        BuffEffectBaseDamage:New(rules.damage.getBaseDamageBonus()),
        BuffEffectSpecial:New("You roll 5-10 for damage instead of 1-10."),
    }, 1)
    buffs.addTraitBuff(TRAITS.VESEERAS_IRE, {
        BuffEffectStat:New(STATS.defence, -ceil(character.getPlayerOffence() / 2)),
    }, 2)
end

local TRAIT_FNS = {
    [TRAITS.ANQULANS_REDOUBT.id] = useAnqulansRedoubt,
    [TRAITS.GREATER_RESTORATION.id] = useGreaterRestoration,
    [TRAITS.HOLY_BULWARK.id] = useHolyBulwark,
    [TRAITS.LIFE_WITHIN.id] = useLifeWithin,
    [TRAITS.SECOND_WIND.id] = useSecondWind,
    [TRAITS.SHIELD_SLAM.id] = useShieldSlam,
    [TRAITS.SILAMELS_ACE.id] = useSilamelsAce,
    [TRAITS.VERSATILE.id] = useVersatile,
    [TRAITS.VESEERAS_IRE.id] = useVeseerasIre,
}

local function useTrait(trait)
    return function(...)
        if trait.Activate then
            local msg = trait:Activate(...)
            bus.fire(EVENTS.TRAIT_ACTIVATED, trait.id, msg)
        else
            local msg = TRAIT_FNS[trait.id](...)
            useTraitChargeWithMsg(trait, msg)
        end
    end
end

-- [[ Rolls ]]

local function confirmReboundRoll()
    buffs.addWeaknessDebuff(WEAKNESSES.REBOUND)
    characterState.state.health.damage(rules.rolls.calculateReboundDamage())
end

-- [[ Actions ]]

local function confirmDamageAction(damage)
    if character.hasFeat(FEATS.ETERNAL_SACRIFICE) and damage.dmg > 0 then
        -- TODO: only melee attacks
        characterState.state.health.heal(rules.feats.ETERNAL_SACRIFICE_HEAL_AMOUNT, INCOMING_HEAL_SOURCES.SELF)
    end

    characterState.state.featsAndTraits.numBloodHarvestSlots.use(damage.numBloodHarvestSlots)
    characterState.state.healing.numGreaterHealSlots.use(damage.numGreaterHealSlots)

    if damage.hasMercyFromPainProc then
        buffs.addFeatBuff(FEATS.MERCY_FROM_PAIN, { BuffEffectHealingDone:New(damage.mercyFromPainBonusHealing) })
    end

    if damage.hasVengeanceProc then
        buffs.addFeatBuff(FEATS.VENGEANCE)
    end
end

local function confirmAttackAction(attack)
    confirmDamageAction(attack.actions.damage)
    rollState.state.attack.attacks.add(attack)
end

local function confirmHealAction(heal)
    characterState.state.healing.numGreaterHealSlots.use(heal.numGreaterHealSlots)

    if heal.outOfCombat and heal.numGreaterHealSlots <= 0 then
        characterState.state.healing.remainingOutOfCombatHeals.spendOne()
    end

    if heal.hasBulwarkOfHopeProc then
        buffs.addFeatBuff(FEATS.BULWARK_OF_HOPE, nil, 1, true)
    end

    if heal.hasChaplainOfViolenceProc then
        buffs.addFeatBuff(FEATS.CHAPLAIN_OF_VIOLENCE, { BuffEffectDamageDone:New(heal.chaplainOfViolenceBonusDamage) })
    end

    rollState.state.healing.heals.add(heal)
end

local function confirmBuffAction(buff)
    if buff.hasBulwarkOfHopeProc then
        buffs.addFeatBuff(FEATS.BULWARK_OF_HOPE, nil, 1, true)
    end
end

local function confirmDefenceAction(defence)
    state.defence.numBraceCharges.use(defence.numBraceCharges)

    if defence.damageTaken > 0 then
        state.health.applyDamage(defence.damageTaken)
    end
    if defence.damagePrevented > 0 then
        state.defence.damagePrevented.increment(defence.damagePrevented)
    end

    if defence.hasBulwarkOfHopeProc then
        buffs.addFeatBuff(FEATS.BULWARK_OF_HOPE, nil, 2, true)
    end

    if defence.hasDefensiveTacticianProc then
        applyDefensiveTactician(defence.dmgRisk)
    end

    rollState.state.defend.defences.add(defence)
end

local function confirmMeleeSaveAction(meleeSave)
    if meleeSave.damageTaken > 0 then
        state.health.applyDamage(meleeSave.damageTaken)
    end
    if meleeSave.damagePrevented > 0 then
        state.defence.damagePrevented.increment(meleeSave.damagePrevented)
    end

    if meleeSave.hasAvengingGuardianProc then
        applyAvengingGuardian()
    end

    if meleeSave.hasBulwarkOfHopeProc then
        buffs.addFeatBuff(FEATS.BULWARK_OF_HOPE, nil, 2, true)
    end

    if meleeSave.hasDefensiveTacticianProc then
        applyDefensiveTactician(meleeSave.dmgRiskToPlayer)
    end
end

local function confirmRangedSaveAction(rangedSave)
    if rangedSave.hasAvengingGuardianProc then
        applyAvengingGuardian()
    end

    if rangedSave.hasBulwarkOfHopeProc then
        buffs.addFeatBuff(FEATS.BULWARK_OF_HOPE, nil, 2, true)
    end
end

local actionFns = {
    [ACTIONS.attack] = confirmAttackAction,
    [ACTIONS.healing] = confirmHealAction,
    [ACTIONS.buff] = confirmBuffAction,
    [ACTIONS.defend] = confirmDefenceAction,
    [ACTIONS.meleeSave] = confirmMeleeSaveAction,
    [ACTIONS.rangedSave] = confirmRangedSaveAction,
}

local function useTraitCharges(action)
    if action.traits then
        for traitID, traitAction in pairs(action.traits) do
            if traitAction.active then
                useTraitCharge(TRAITS[traitID])
            end
        end
    end
end

local function confirmAction(actionType, action, hideMsg)
    bus.fire(EVENTS.ACTION_PERFORMED, actionType, action, hideMsg)

    -- not every action has specific effects yet
    if actionFns[actionType] then
        actionFns[actionType](action)
    end

    useTraitCharges(action)

    if action.actions then
        for subActionType, subAction in pairs(action.actions) do
            bus.fire(EVENTS.ACTION_PERFORMED, subActionType, subAction, true)
            useTraitCharges(subAction)
        end
    end

    local actionState = rollState.state[actionType]

    actionState.currentRoll.set(nil)

    if actionState.resetSlots then
        actionState.resetSlots()
    end
end

local function removeCriticalWoundWithGreaterHealSlots()
    local cost = rules.criticalWounds.getNumGreaterHealSlotsToRemoveCriticalWound()
    characterState.state.healing.numGreaterHealSlots.use(cost)
end

-- [[ Exports ]]

consequences.useTraitCharge = useTraitCharge
consequences.applyFaelunesRegrowth = applyFaelunesRegrowth
consequences.useFatePoint = useFatePoint
consequences.restoreGreaterHealSlotWithExcess = restoreGreaterHealSlotWithExcess
consequences.enableFocus = enableFocus
consequences.enableLivingBarricade = enableLivingBarricade
consequences.useTrait = useTrait
consequences.confirmReboundRoll = confirmReboundRoll
consequences.confirmAction = confirmAction
consequences.removeCriticalWoundWithGreaterHealSlots = removeCriticalWoundWithGreaterHealSlots
