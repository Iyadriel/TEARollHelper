local _, ns = ...

local constants = ns.constants
local rules = ns.rules

local feats = ns.resources.feats
local traits = ns.resources.traits

local CRIT_TYPES = constants.CRIT_TYPES
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local Chastice = TRAITS.CHASTICE
local CriticalMass = TRAITS.CRITICAL_MASS
local IHoldYouHurt = TRAITS.I_HOLD_YOU_HURT

local function getAmountHealedWithPenance(numGreaterHealSlots, healingDoneBuff, targetIsKO)
    local amountHealed = 0

    amountHealed = rules.healing.applySpiritBonus(amountHealed)
    amountHealed = rules.healing.applyHealingDoneBuff(amountHealed, healingDoneBuff)
    amountHealed = amountHealed + rules.healing.calculateGreaterHealBonus(numGreaterHealSlots)

    if rules.healing.canUseTargetKOBonus() and targetIsKO then
        amountHealed = amountHealed + rules.healing.getTargetKOBonus()
    end

    return amountHealed
end

-- [[ Actions ]]

local function getAttack(attackIndex, roll, rollBuff, critType, threshold, stat, statBuff, baseDmgBuff, damageDoneBuff, enemyId, damageAction)
    local attackValue, isSuccessful
    local isCrit = rules.offence.isCrit(roll)
    local hasAdrenalineProc = nil

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    attackValue = rules.offence.calculateAttackValue(roll, stat, statBuff)
    isSuccessful = rules.offence.isSuccessful(attackValue, threshold)

    if rules.feats.canProc(FEATS.ADRENALINE) then
        hasAdrenalineProc = rules.offence.hasAdrenalineProc(attackIndex, threshold, attackValue)
    end

    if not isSuccessful and rules.feats.canProc(FEATS.ONSLAUGHT) then
        damageAction.dmg = rules.damage.calculateOnslaughtDamage(baseDmgBuff, damageDoneBuff)
    end

    return {
        attackValue = attackValue,
        isSuccessful = isSuccessful,
        isCrit = isCrit,
        critType = critType,
        enemyId = enemyId,
        hasAdrenalineProc = hasAdrenalineProc,

        actions = {
            damage = damageAction,
        },
    }
end

local function getDamage(attackRoll, damageRoll, rollBuff, critType, baseDmgBuff, damageDoneBuff, healingDoneBuff, enemyId, isAOE, numGreaterHealSlots, targetIsKO, numBloodHarvestSlots, activeTraits)
    local damageValue
    local dmg = 0
    local amountHealed = 0
    local isCrit = rules.offence.isCrit(attackRoll)
    local hasMercyFromPainProc = nil
    local mercyFromPainBonusHealing = 0
    local canUseCriticalMass = nil
    local criticalMassActive = nil
    local criticalMassBonusDamage = 0
    local hasVengeanceProc = nil
    local hasVindicationProc = nil
    local vindicationHealing = 0

    if damageRoll then
        damageRoll = rules.rolls.calculateRoll(damageRoll, rollBuff)
        damageValue = rules.damage.calculateDamageValue(damageRoll)
        dmg = rules.damage.calculateAttackDmg(damageValue, baseDmgBuff, damageDoneBuff, enemyId)
        dmg = rules.damage.calculateEffectiveOutgoingDamage(dmg)
    end

    if rules.feats.canProc(FEATS.BLOOD_HARVEST) then
        dmg = dmg + rules.damage.calculateBloodHarvestBonus(numBloodHarvestSlots)
    end

    if damageRoll then
        if numGreaterHealSlots > 0 then
            amountHealed = getAmountHealedWithPenance(numGreaterHealSlots, healingDoneBuff, targetIsKO)
        end

        canUseCriticalMass = CriticalMass:IsUsable(dmg)
        criticalMassActive = canUseCriticalMass and activeTraits[CriticalMass.id]
        if criticalMassActive then
            criticalMassBonusDamage = CriticalMass:GetBonusDamage()
            dmg = dmg + criticalMassBonusDamage
        end

        if isCrit and critType == CRIT_TYPES.VALUE_MOD then
            dmg = rules.damage.applyCritModifier(dmg)
        end

        if rules.feats.canProc(FEATS.MERCY_FROM_PAIN) then
            hasMercyFromPainProc = rules.damage.hasMercyFromPainProc(dmg)
        end

        if hasMercyFromPainProc then
            mercyFromPainBonusHealing = rules.damage.calculateMercyFromPainBonusHealing(isAOE)
        end

        if rules.feats.canProc(FEATS.VENGEANCE) then
            hasVengeanceProc = rules.offence.hasVengeanceProc(attackRoll)
        end

        if rules.damage.canProcVindication() then
            hasVindicationProc = rules.damage.hasVindicationProc(dmg)
            if hasVindicationProc then
                vindicationHealing = rules.damage.calculateVindicationHealing(dmg)
            end
        end
    end

    return {
        dmg = dmg,
        amountHealed = amountHealed,
        isCrit = isCrit,
        critType = critType,
        numGreaterHealSlots = numGreaterHealSlots,
        numBloodHarvestSlots = numBloodHarvestSlots,
        hasMercyFromPainProc = hasMercyFromPainProc,
        mercyFromPainBonusHealing = mercyFromPainBonusHealing,
        hasVengeanceProc = hasVengeanceProc,
        traits = {
            [CriticalMass.id] = {
                canUse = canUseCriticalMass,
                active = criticalMassActive,
                dmg = criticalMassBonusDamage,
            },
            [TRAITS.FAULTLINE.id] = {
                canUse = dmg > 0,
                active = dmg > 0 and activeTraits[TRAITS.FAULTLINE.id],
            },
            [TRAITS.REAP.id] = {
                canUse = dmg > 0,
                active = dmg > 0 and activeTraits[TRAITS.REAP.id],
            },
            [TRAITS.VINDICATION.id] = {
                canUse = hasVindicationProc,
                healingDone = vindicationHealing,
                active = hasVindicationProc and activeTraits[TRAITS.VINDICATION.id],
            }
        },
    }
end

local function getCC(roll, rollBuff, stat, statBuff, activeTraits)
    local isCrit = rules.cc.isCrit(roll)
    roll = rules.rolls.calculateRoll(roll, rollBuff)
    local ccValue = rules.cc.calculateCCValue(roll, stat, statBuff)

    return {
        ccValue = ccValue,
        isCrit = isCrit,
        traits = {
            [IHoldYouHurt.id] = {
                canUse = ccValue > 0,
                active = ccValue > 0 and activeTraits[IHoldYouHurt.id],
                damageBonus = IHoldYouHurt:calculateDamageDoneBonus(ccValue),
            },
        },
    }
end

local function calculateDamageTaken(calculator)
    local dmg = calculator.incomingDmg
    dmg = calculator.doAction(dmg)
    if dmg  > 0 then
        dmg = calculator.applyGeneralModifiers(dmg)
        if calculator.applyActionModifiers then
            dmg = calculator.applyActionModifiers(dmg)
        end
    end
    return dmg
end

local function getDefence(roll, rollBuff, defenceType, threshold, damageType, dmgRisk, numBraceCharges, critType, stat, statBuff, damageTakenBuff, activeTraits)
    local isCrit = rules.defence.isCrit(roll)
    local defendValue, damageTaken, damagePrevented
    local retaliateDmg = 0
    local hasBulwarkOfHopeProc = nil
    local hasDefensiveTacticianProc = nil

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    stat = stat + rules.defence.calculateBraceDefenceBonus(numBraceCharges) -- brace increases defence stat, not the roll.
    defendValue = rules.defence.calculateDefendValue(roll, damageType, stat, statBuff)

    damageTaken = calculateDamageTaken({
        incomingDmg = dmgRisk,
        doAction = function (dmg)
            return rules.defence.calculateDamageAfterDefence(defenceType, threshold, defendValue, dmg)
        end,
        applyGeneralModifiers = function (dmg)
            return rules.defence.calculateEffectiveIncomingDamage(defenceType, dmg, damageTakenBuff)
        end,
    })

    damagePrevented = rules.defence.calculateDamagePrevented(dmgRisk, damageTaken)

    if isCrit then
        retaliateDmg = rules.defence.calculateRetaliationDamage(stat, statBuff)
        retaliateDmg = rules.damage.calculateEffectiveOutgoingDamage(retaliateDmg)
    end

    if rules.feats.canProc(FEATS.BULWARK_OF_HOPE) then
        hasBulwarkOfHopeProc = rules.defence.hasBulwarkOfHopeProc(damageTaken)
    elseif rules.feats.canProc(FEATS.DEFENSIVE_TACTICIAN) then
        hasDefensiveTacticianProc = rules.defence.hasDefensiveTacticianProc(damageTaken)
    end

    return {
        defendValue = defendValue,
        dmgRisk = dmgRisk,
        damageTaken = damageTaken,
        damagePrevented = damagePrevented,
        numBraceCharges = numBraceCharges,
        isCrit = isCrit,
        critType = critType,
        retaliateDmg = retaliateDmg,

        hasBulwarkOfHopeProc = hasBulwarkOfHopeProc,
        hasDefensiveTacticianProc = hasDefensiveTacticianProc,
    }
end

local function getMeleeSave(roll, rollBuff, defenceType, threshold, damageType, dmgRiskToAlly, defence, defenceBuff, damageTakenBuff, activeTraits)
    threshold = threshold + rules.common.SAVE_THRESHOLD_INCREASE

    local dmgRiskToPlayer = dmgRiskToAlly
    local meleeSaveValue, damageTaken, damagePrevented
    local isBigFail
    local hasCounterForceProc = nil
    local counterForceDmg = 0
    local hasAvengingGuardianProc = nil
    local hasBulwarkOfHopeProc = nil
    local hasDefensiveTacticianProc = nil

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    meleeSaveValue = rules.meleeSave.calculateMeleeSaveValue(roll, damageType, defence, defenceBuff)

    damagePrevented = rules.meleeSave.calculateDamagePrevented(dmgRiskToAlly)

    isBigFail = rules.meleeSave.isSaveBigFail(meleeSaveValue, threshold)
    -- in case of big fail, double incoming damage before other modifiers
    if isBigFail then
        dmgRiskToPlayer = rules.meleeSave.applyBigFailModifier(dmgRiskToPlayer)
    end

    damageTaken = calculateDamageTaken({
        incomingDmg = dmgRiskToPlayer,
        doAction = function (dmg)
            return rules.defence.calculateDamageAfterDefence(defenceType, threshold, meleeSaveValue, dmg)
        end,
        applyGeneralModifiers = function (dmg)
            return rules.effects.calculateEffectiveIncomingDamage(dmg, damageTakenBuff, true)
        end,
        applyActionModifiers = function (dmg)
            return rules.meleeSave.applyExtraMeleeSaveDamageTakenReductions(dmg)
        end,
    })

    if rules.feats.canProc(FEATS.AVENGING_GUARDIAN) then
        hasAvengingGuardianProc = rules.defence.hasAvengingGuardianProc(damageTaken)
    elseif rules.feats.canProc(FEATS.BULWARK_OF_HOPE) then
        hasBulwarkOfHopeProc = rules.defence.hasBulwarkOfHopeProc(damageTaken)
    elseif rules.feats.canProc(FEATS.COUNTER_FORCE) then
        hasCounterForceProc = rules.meleeSave.hasCounterForceProc(meleeSaveValue, threshold)
        if hasCounterForceProc then
            counterForceDmg = rules.meleeSave.calculateCounterForceProcDmg(defence)
            counterForceDmg = rules.damage.calculateEffectiveOutgoingDamage(counterForceDmg)
        end
    elseif rules.feats.canProc(FEATS.DEFENSIVE_TACTICIAN) then
        hasDefensiveTacticianProc = rules.defence.hasDefensiveTacticianProc(damageTaken)
    end

    return {
        meleeSaveValue = meleeSaveValue,
        dmgRiskToPlayer = dmgRiskToPlayer,
        damageTaken = damageTaken,
        damagePrevented = damagePrevented,
        isBigFail = isBigFail,

        hasCounterForceProc = hasCounterForceProc,
        counterForceDmg = counterForceDmg,
        hasAvengingGuardianProc = hasAvengingGuardianProc,
        hasBulwarkOfHopeProc = hasBulwarkOfHopeProc,
        hasDefensiveTacticianProc = hasDefensiveTacticianProc,

        traits = {
            [TRAITS.PRESENCE_OF_VIRTUE.id] = {
                canUse = damageTaken <= 0,
                active = damageTaken <= 0 and activeTraits[TRAITS.PRESENCE_OF_VIRTUE.id],
            },
        },
    }
end

local function getRangedSave(roll, rollBuff, defenceType, threshold, spirit, buff)
    threshold = threshold + rules.common.SAVE_THRESHOLD_INCREASE

    local hasAvengingGuardianProc = nil
    local hasBulwarkOfHopeProc = nil

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    local saveValue = rules.rangedSave.calculateRangedSaveValue(roll, spirit, buff)
    local canFullyProtect = rules.rangedSave.canFullyProtect(defenceType, threshold, saveValue)
    local damageReduction = nil

    if not canFullyProtect then
        damageReduction = rules.rangedSave.calculateDamageReduction(spirit)
    end

    if rules.feats.canProc(FEATS.AVENGING_GUARDIAN) then
        hasAvengingGuardianProc = canFullyProtect
    elseif rules.feats.canProc(FEATS.BULWARK_OF_HOPE) then
        hasBulwarkOfHopeProc = canFullyProtect
    end

    return {
        saveValue = saveValue,
        canFullyProtect = canFullyProtect,
        damageReduction = damageReduction,

        hasAvengingGuardianProc = hasAvengingGuardianProc,
        hasBulwarkOfHopeProc = hasBulwarkOfHopeProc,
    }
end

local function getHealing(roll, rollBuff, critType, spirit, spiritBuff, healingDoneBuff, numGreaterHealSlots, targetIsKO, outOfCombat, remainingOutOfCombatHeals, activeTraits)
    local canStillHeal = rules.healing.canStillHeal(outOfCombat, remainingOutOfCombatHeals, numGreaterHealSlots)
    local healValue
    local amountHealed = 0
    local isCrit = rules.healing.isCrit(roll)
    local hasBulwarkOfHopeProc = nil
    local hasChaplainOfViolenceProc = nil
    local chaplainOfViolenceBonusDamage = 0
    local usesParagon = rules.healing.usesParagon()
    local playersHealableWithParagon = nil
    local canUseChastice = nil
    local chasticeActive = nil
    local chasticeDmg = 0

    roll = rules.rolls.calculateRoll(roll, rollBuff)

    if canStillHeal then
        healValue = rules.healing.calculateHealValue(roll, spirit, spiritBuff)

        amountHealed = rules.healing.calculateBaseAmountHealed(healValue)

        if outOfCombat then
            amountHealed = rules.healing.applyOutOfCombatBaseAmountBonus(amountHealed)
        end

        amountHealed = rules.healing.applySpiritBonus(amountHealed)
        amountHealed = rules.healing.applyHealingDoneBuff(amountHealed, healingDoneBuff)
        amountHealed = amountHealed + rules.healing.calculateGreaterHealBonus(numGreaterHealSlots)

        if rules.healing.canUseTargetKOBonus() and targetIsKO then
            amountHealed = amountHealed + rules.healing.getTargetKOBonus()
        end

        if outOfCombat then
            amountHealed = amountHealed + rules.healing.getOutOfCombatBonus()
        end

        if usesParagon then
            playersHealableWithParagon = rules.healing.calculateNumPlayersHealableWithParagon()
        end

        if isCrit then
            amountHealed = rules.healing.applyCritModifier(amountHealed, critType)
        end

        if rules.feats.canProc(FEATS.BULWARK_OF_HOPE) then
            hasBulwarkOfHopeProc = rules.healing.hasBulwarkOfHopeProc(amountHealed)
        elseif rules.feats.canProc(FEATS.CHAPLAIN_OF_VIOLENCE) then
            hasChaplainOfViolenceProc = rules.healing.hasChaplainOfViolenceProc(amountHealed)
        end

        if hasChaplainOfViolenceProc then
            chaplainOfViolenceBonusDamage = rules.healing.calculateChaplainOfViolenceBonusDamage(numGreaterHealSlots)
        end
    end

    canUseChastice = Chastice:IsUsable(amountHealed)
    chasticeActive = canUseChastice and activeTraits[Chastice.id]
    if chasticeActive then
        chasticeDmg = Chastice:GetDamageDone(amountHealed)
        chasticeDmg = rules.damage.calculateEffectiveOutgoingDamage(chasticeDmg)
    end

    return {
        canStillHeal = canStillHeal,
        amountHealed = amountHealed,
        isCrit = isCrit,
        critType = critType,
        outOfCombat = outOfCombat,
        numGreaterHealSlots = numGreaterHealSlots,
        hasBulwarkOfHopeProc = hasBulwarkOfHopeProc,
        hasChaplainOfViolenceProc = hasChaplainOfViolenceProc,
        chaplainOfViolenceBonusDamage = chaplainOfViolenceBonusDamage,
        hasLifeSentinelProc = rules.feats.canProc(FEATS.LIFE_SENTINEL),
        usesParagon = usesParagon,
        playersHealableWithParagon = playersHealableWithParagon,
        traits = {
            [Chastice.id] = {
                canUse = canUseChastice,
                active = chasticeActive,
                damageDone = chasticeDmg,
            },
            [TRAITS.LIFE_PULSE.id] = {
                canUse = amountHealed > 0,
                active = amountHealed > 0 and activeTraits[TRAITS.LIFE_PULSE.id],
            },
        },
    }
end

local function getBuff(roll, rollBuff, critType, spirit, spiritBuff, offence, offenceBuff, activeTraits)
    local buffValue
    local amountBuffed, amountBuffedForDamage
    local isCrit = rules.buffing.isCrit(roll)
    local hasBulwarkOfHopeProc = nil

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    buffValue = rules.buffing.calculateBuffValue(roll, spirit, spiritBuff, offence, offenceBuff)

    amountBuffed = rules.buffing.calculateBuffAmount(buffValue)
    amountBuffedForDamage = rules.buffing.calculateBuffAmountForDamage(buffValue)

    if isCrit then
        amountBuffed = rules.buffing.applyCritModifier(amountBuffed, critType)
        amountBuffedForDamage = rules.buffing.applyCritModifier(amountBuffedForDamage, critType)
    end

    if rules.feats.canProc(FEATS.BULWARK_OF_HOPE) then
        hasBulwarkOfHopeProc = rules.buffing.hasBulwarkOfHopeProc(buffValue)
    end

    return {
        amountBuffed = amountBuffed,
        amountBuffedForDamage = amountBuffedForDamage,
        isCrit = isCrit,
        critType = critType,
        hasBulwarkOfHopeProc = hasBulwarkOfHopeProc,
        usesInspiringPresence = rules.buffing.usesInspiringPresence(),
        traits = {
            [TRAITS.ASCEND.id] = {
                canUse = buffValue > 0,
                active = buffValue > 0 and activeTraits[TRAITS.ASCEND.id],
            },
        },
    }
end

local function getUtility(roll, rollBuff, utilityTypeID, utilityTrait, utilityBonusBuff)
    roll = rules.rolls.calculateRoll(roll, rollBuff)
    local utilityValue = rules.utility.calculateUtilityValue(roll, utilityTypeID, utilityTrait, utilityBonusBuff)

    return {
        utilityValue = utilityValue
    }
end

-- Trait actions

local function getHolyBulwark(dmgRisk, damageTakenBuff, isSave)
    local damageTaken = 0
    local effectiveIncomingDamage = rules.effects.calculateEffectiveIncomingDamage(dmgRisk, damageTakenBuff, true)
    local damagePrevented

    if isSave then
        -- when saving ally, the original damage directed towards them is prevented
        damagePrevented = rules.defence.calculateDamagePrevented(dmgRisk, damageTaken)
    else
        -- if it's not a save, use effective incoming damage for damage prevented
        damagePrevented = rules.defence.calculateDamagePrevented(effectiveIncomingDamage, damageTaken)
    end

    return {
        dmgRisk = dmgRisk,
        damagePrevented = damagePrevented,
        retaliateDmg = rules.damage.calculateEffectiveOutgoingDamage(dmgRisk)
    }
end

local function getShieldSlam(baseDmgBuff, defence, defenceBuff)
    local dmg = rules.traits.calculateShieldSlamDmg(baseDmgBuff, defence, defenceBuff)
    dmg = rules.damage.calculateEffectiveOutgoingDamage(dmg)

    return {
        dmg = dmg
    }
end

ns.actions.getAttack = getAttack
ns.actions.getDamage = getDamage
ns.actions.getCC = getCC
ns.actions.getDefence = getDefence
ns.actions.getMeleeSave = getMeleeSave
ns.actions.getRangedSave = getRangedSave
ns.actions.getHealing = getHealing
ns.actions.getBuff = getBuff
ns.actions.getUtility = getUtility
ns.actions.traits = {
    getHolyBulwark = getHolyBulwark,
    getShieldSlam = getShieldSlam,
}
