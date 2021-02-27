local _, ns = ...

local constants = ns.constants
local rules = ns.rules

local traits = ns.resources.traits

local CRIT_TYPES = constants.CRIT_TYPES
local TRAITS = traits.TRAITS

local Chastice = TRAITS.CHASTICE
local CriticalMass = TRAITS.CRITICAL_MASS

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

local function getAttack(attackIndex, roll, rollBuff, critType, threshold, stat, statBuff, baseDmgBuff, damageDoneBuff, healingDoneBuff, enemyId, isAOE, numGreaterHealSlots, targetIsKO, numBloodHarvestSlots, activeTraits)
    local attackValue
    local dmg
    local amountHealed = 0
    local originalRoll = roll
    local isCrit = rules.offence.isCrit(roll)
    local hasAdrenalineProc = nil
    local hasMercyFromPainProc = nil
    local mercyFromPainBonusHealing = 0
    local canUseCriticalMass = nil
    local criticalMassActive = nil
    local criticalMassBonusDamage = 0
    local shatterSoulEnabled = false
    local hasVengeanceProc = nil
    local hasVindicationProc = nil
    local vindicationHealing = 0

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    attackValue = rules.offence.calculateAttackValue(roll, stat, statBuff)
    dmg = rules.offence.calculateAttackDmg(threshold, attackValue, baseDmgBuff, damageDoneBuff)

    if rules.offence.canProcAdrenaline(attackIndex) then
        hasAdrenalineProc = rules.offence.hasAdrenalineProc(threshold, attackValue)
    end

    if rules.offence.canUseBloodHarvest() then
        dmg = dmg + rules.offence.calculateBloodHarvestBonus(numBloodHarvestSlots)
    end

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
        dmg = rules.offence.applyCritModifier(dmg)
    end

    if rules.offence.canUseShatterSoul() then
        shatterSoulEnabled = rules.offence.shatterSoulEnabled(dmg, enemyId)
    end

    if rules.offence.canProcMercyFromPain() then
        hasMercyFromPainProc = rules.offence.hasMercyFromPainProc(dmg)
    end

    if hasMercyFromPainProc then
        mercyFromPainBonusHealing = rules.offence.calculateMercyFromPainBonusHealing(isAOE)
    end

    if rules.offence.canProcVengeance() then
        hasVengeanceProc = rules.offence.hasVengeanceProc(originalRoll)
    end

    if rules.offence.canProcVindication() then
        hasVindicationProc = rules.offence.hasVindicationProc(dmg)
        if hasVindicationProc then
            vindicationHealing = rules.offence.calculateVindicationHealing(dmg)
        end
    end

    return {
        attackValue = attackValue,
        dmg = dmg,
        amountHealed = amountHealed,
        isCrit = isCrit,
        critType = critType,
        enemyId = enemyId,
        hasAdrenalineProc = hasAdrenalineProc,
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
            [TRAITS.SHATTER_SOUL.id] = {
                canUse = shatterSoulEnabled,
                active = shatterSoulEnabled and activeTraits[TRAITS.SHATTER_SOUL.id],
            },
            [TRAITS.VINDICATION.id] = {
                canUse = hasVindicationProc,
                healingDone = vindicationHealing,
                active = hasVindicationProc and activeTraits[TRAITS.VINDICATION.id],
            }
        },
    }
end

local function getCC(roll, rollBuff, offence, offenceBuff, defence, defenceBuff)
    local isCrit = rules.cc.isCrit(roll)
    roll = rules.rolls.calculateRoll(roll, rollBuff)
    local ccValue = rules.cc.calculateCCValue(roll, offence, offenceBuff, defence, defenceBuff)

    return {
        ccValue = ccValue,
        isCrit = isCrit,
    }
end

local function getDefence(roll, rollBuff, defenceType, threshold, damageType, dmgRisk, numBraceCharges, critType, defence, defenceBuff, damageTakenBuff, activeTraits)
    local isCrit = rules.defence.isCrit(roll)
    local defendValue, damageTaken, damagePrevented
    local retaliateDmg = 0
    local hasDefensiveTacticianProc = nil

    local effectiveIncomingDamage = rules.effects.calculateEffectiveIncomingDamage(dmgRisk, damageTakenBuff, true)

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    defence = defence + rules.defence.calculateBraceDefenceBonus(numBraceCharges) -- brace increases defence stat, not the roll.
    defendValue = rules.defence.calculateDefendValue(roll, damageType, defence, defenceBuff)
    damageTaken = rules.defence.calculateDamageTaken(defenceType, threshold, defendValue, effectiveIncomingDamage)
    damagePrevented = rules.defence.calculateDamagePrevented(effectiveIncomingDamage, damageTaken)

    if isCrit then
        retaliateDmg = rules.defence.calculateRetaliationDamage(defence)
    end

    if rules.defence.canProcDefensiveTactician() then
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

        hasDefensiveTacticianProc = hasDefensiveTacticianProc,
    }
end

local function getMeleeSave(roll, rollBuff, defenceType, threshold, damageType, dmgRiskToAlly, defence, defenceBuff, damageTakenBuff, activeTraits)
    threshold = threshold + rules.common.SAVE_THRESHOLD_INCREASE

    local dmgRiskToPlayer = rules.meleeSave.calculateDamageRiskToPlayer(dmgRiskToAlly)
    local meleeSaveValue, damageTaken, damagePrevented
    local isBigFail
    local hasCounterForceProc = nil
    local counterForceDmg = 0
    local hasDefensiveTacticianProc = nil

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    meleeSaveValue = rules.meleeSave.calculateMeleeSaveValue(roll, damageType, defence, defenceBuff)

    damagePrevented = rules.meleeSave.calculateDamagePrevented(dmgRiskToAlly)

    isBigFail = rules.meleeSave.isSaveBigFail(meleeSaveValue, threshold)
    -- in case of big fail, double incoming damage before other modifiers
    if isBigFail then
        dmgRiskToPlayer = rules.meleeSave.applyBigFailModifier(dmgRiskToPlayer)
    end

    -- then apply modifiers
    local effectiveIncomingDamage = rules.effects.calculateEffectiveIncomingDamage(dmgRiskToPlayer, damageTakenBuff, true)

    damageTaken = rules.defence.calculateDamageTaken(defenceType, threshold, meleeSaveValue, effectiveIncomingDamage)

    if rules.meleeSave.canProcCounterForce() then
        hasCounterForceProc = rules.meleeSave.hasCounterForceProc(meleeSaveValue, threshold)
        if hasCounterForceProc then
            counterForceDmg = rules.meleeSave.calculateCounterForceProcDmg(defence)
        end
    end

    if rules.defence.canProcDefensiveTactician() then
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

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    local saveValue = rules.rangedSave.calculateRangedSaveValue(roll, spirit, buff)
    local canFullyProtect = rules.rangedSave.canFullyProtect(defenceType, threshold, saveValue)
    local damageReduction = nil

    if not canFullyProtect then
        damageReduction = rules.rangedSave.calculateDamageReduction(spirit)
    end

    return {
        saveValue = saveValue,
        canFullyProtect = canFullyProtect,
        damageReduction = damageReduction,
    }
end

local function getHealing(roll, rollBuff, critType, spirit, spiritBuff, healingDoneBuff, numGreaterHealSlots, targetIsKO, outOfCombat, remainingOutOfCombatHeals, activeTraits)
    local canStillHeal = rules.healing.canStillHeal(outOfCombat, remainingOutOfCombatHeals, numGreaterHealSlots)
    local healValue
    local amountHealed = 0
    local isCrit = rules.healing.isCrit(roll)
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

        if rules.healing.canProcChaplainOfViolence() then
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
    end

    return {
        canStillHeal = canStillHeal,
        amountHealed = amountHealed,
        isCrit = isCrit,
        critType = critType,
        outOfCombat = outOfCombat,
        numGreaterHealSlots = numGreaterHealSlots,
        hasChaplainOfViolenceProc = hasChaplainOfViolenceProc,
        chaplainOfViolenceBonusDamage = chaplainOfViolenceBonusDamage,
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
    local amountBuffed
    local isCrit = rules.buffing.isCrit(roll)

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    buffValue = rules.buffing.calculateBuffValue(roll, spirit, spiritBuff, offence, offenceBuff)

    amountBuffed = rules.buffing.calculateBuffAmount(buffValue)

    if isCrit then
        amountBuffed = rules.buffing.applyCritModifier(amountBuffed, critType)
    end

    return {
        amountBuffed = amountBuffed,
        isCrit = isCrit,
        critType = critType,
        usesInspiringPresence = rules.buffing.usesInspiringPresence(),
        traits = {
            [TRAITS.ASCEND.id] = {
                canUse = amountBuffed > 0,
                active = amountBuffed > 0 and activeTraits[TRAITS.ASCEND.id],
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
        retaliateDmg = dmgRisk
    }
end

local function getShieldSlam(baseDmgBuff, defence, defenceBuff)
    local dmg = rules.traits.calculateShieldSlamDmg(baseDmgBuff, defence, defenceBuff)

    return {
        dmg = dmg
    }
end

ns.actions.getAttack = getAttack
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