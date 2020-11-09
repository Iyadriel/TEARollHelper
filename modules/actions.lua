local _, ns = ...

local rules = ns.rules

local traits = ns.resources.traits

local TRAITS = traits.TRAITS

local function getAttack(attackIndex, roll, rollBuff, threshold, offence, offenceBuff, baseDmgBuff, damageDoneBuff, enemyId, isAOE, numBloodHarvestSlots, activeTraits)
    local attackValue
    local dmg
    local originalRoll = roll
    local critType = rules.offence.getCritType()
    local isCrit = rules.offence.isCrit(roll)
    local hasAdrenalineProc = nil
    local hasMercyFromPainProc = nil
    local mercyFromPainBonusHealing = 0
    local shatterSoulEnabled = false
    local hasVengeanceProc = nil
    local hasVindicationProc = nil
    local vindicationHealing = 0

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    attackValue = rules.offence.calculateAttackValue(roll, offence, offenceBuff)
    dmg = rules.offence.calculateAttackDmg(threshold, attackValue, baseDmgBuff, damageDoneBuff)

    if rules.offence.canProcAdrenaline(attackIndex) then
        hasAdrenalineProc = rules.offence.hasAdrenalineProc(threshold, attackValue)
    end

    if rules.offence.canUseBloodHarvest() then
        dmg = dmg + rules.offence.calculateBloodHarvestBonus(numBloodHarvestSlots)
    end

    if isCrit and critType == rules.offence.CRIT_TYPES.DAMAGE then
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
        isCrit = isCrit,
        critType = critType,
        enemyId = enemyId,
        hasAdrenalineProc = hasAdrenalineProc,
        numBloodHarvestSlots = numBloodHarvestSlots,
        hasMercyFromPainProc = hasMercyFromPainProc,
        mercyFromPainBonusHealing = mercyFromPainBonusHealing,
        hasVengeanceProc = hasVengeanceProc,
        traits = {
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

local function getPenance(roll, rollBuff, threshold, spirit, spiritBuff, baseDmgBuff, damageDoneBuff, numGreaterHealSlots, targetIsKO, activeTraits)
    local attackValue
    local dmg
    local amountHealed = 0
    local isCrit = rules.offence.isCrit(roll)
    local hasVindicationProc = nil
    local vindicationHealing = 0

    roll = rules.rolls.calculateRoll(roll, rollBuff)

    -- Damage

    attackValue = rules.penance.calculateAttackValue(roll, spirit, spiritBuff)

    dmg = rules.offence.calculateAttackDmg(threshold, attackValue, baseDmgBuff, damageDoneBuff)

     if isCrit then
        dmg = rules.offence.applyCritModifier(dmg)
    end

    if rules.offence.canProcVindication() then
        hasVindicationProc = rules.offence.hasVindicationProc(dmg)
        if hasVindicationProc then
            vindicationHealing = rules.offence.calculateVindicationHealing(dmg)
        end
    end

    -- Healing

    amountHealed = rules.healing.calculateGreaterHealBonus(numGreaterHealSlots)

    if targetIsKO then
        amountHealed = amountHealed + rules.healing.getTargetKOBonus()
    end

    return {
        attackValue = attackValue,
        dmg = dmg,
        isCrit = isCrit,
        amountHealed = amountHealed,
        numGreaterHealSlots = numGreaterHealSlots,
        traits = {
            [TRAITS.FAULTLINE.id] = {
                canUse = dmg > 0,
                active = dmg > 0 and activeTraits[TRAITS.FAULTLINE.id],
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

local function getDefence(roll, rollBuff, defenceType, threshold, damageType, dmgRisk, defence, defenceBuff, damageTakenBuff, activeTraits)
    local isCrit = rules.defence.isCrit(roll)
    local defendValue, damageTaken, damagePrevented
    local retaliateDmg = 0
    local empoweredBladesEnabled = false

    local effectiveIncomingDamage = rules.effects.calculateEffectiveIncomingDamage(dmgRisk, damageTakenBuff, true)

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    defendValue = rules.defence.calculateDefendValue(roll, damageType, defence, defenceBuff)
    damageTaken = rules.defence.calculateDamageTaken(defenceType, threshold, defendValue, effectiveIncomingDamage)
    damagePrevented = rules.defence.calculateDamagePrevented(effectiveIncomingDamage, damageTaken)

    if isCrit then
        retaliateDmg = rules.defence.calculateRetaliationDamage(defence)
    end

    if rules.defence.canUseEmpoweredBlades() then
        empoweredBladesEnabled = rules.defence.empoweredBladesEnabled(damageTaken, damageType)
    end

    return {
        defendValue = defendValue,
        dmgRisk = dmgRisk,
        damageTaken = damageTaken,
        damagePrevented = damagePrevented,
        canRetaliate = isCrit,
        retaliateDmg = retaliateDmg,
        empoweredBladesEnabled = empoweredBladesEnabled,
        traits = {
            [TRAITS.EMPOWERED_BLADES.id] = {
                canUse = empoweredBladesEnabled,
                active = empoweredBladesEnabled and activeTraits[TRAITS.EMPOWERED_BLADES.id],
            },
        },
    }
end

local function getMeleeSave(roll, rollBuff, defenceType, threshold, damageType, dmgRisk, defence, defenceBuff, damageTakenBuff, activeTraits)
    threshold = threshold + rules.common.SAVE_THRESHOLD_INCREASE

    local meleeSaveValue, damageTaken, damagePrevented
    local isBigFail
    local hasCounterForceProc = nil
    local counterForceDmg = 0

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    meleeSaveValue = rules.meleeSave.calculateMeleeSaveValue(roll, damageType, defence, defenceBuff)

    -- the damage that the ally would have taken
    damagePrevented = rules.meleeSave.calculateDamagePrevented(dmgRisk)

    isBigFail = rules.meleeSave.isSaveBigFail(meleeSaveValue, threshold)
    -- in case of big fail, double incoming damage before other modifiers
    if isBigFail then
        dmgRisk = rules.meleeSave.applyBigFailModifier(dmgRisk)
    end

    -- then apply modifiers
    local effectiveIncomingDamage = rules.effects.calculateEffectiveIncomingDamage(dmgRisk, damageTakenBuff, true)

    damageTaken = rules.defence.calculateDamageTaken(defenceType, threshold, meleeSaveValue, effectiveIncomingDamage)

    if rules.meleeSave.canProcCounterForce() then
        hasCounterForceProc = rules.meleeSave.hasCounterForceProc(meleeSaveValue, threshold)
        if hasCounterForceProc then
            counterForceDmg = rules.meleeSave.calculateCounterForceProcDmg(defence)
        end
    end

    return {
        meleeSaveValue = meleeSaveValue,
        damageTaken = damageTaken,
        damagePrevented = damagePrevented,
        isBigFail = isBigFail,
        hasCounterForceProc = hasCounterForceProc,
        counterForceDmg = counterForceDmg,
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

local function getHealing(roll, rollBuff, spirit, spiritBuff, healingDoneBuff, numGreaterHealSlots, targetIsKO, outOfCombat, remainingOutOfCombatHeals, activeTraits)
    local canStillHeal = rules.healing.canStillHeal(outOfCombat, remainingOutOfCombatHeals, numGreaterHealSlots)
    local healValue
    local amountHealed = 0
    local isCrit = rules.healing.isCrit(roll)
    local usesParagon = rules.healing.usesParagon()
    local playersHealableWithParagon = nil

    roll = rules.rolls.calculateRoll(roll, rollBuff)

    if canStillHeal then
        healValue = rules.healing.calculateHealValue(roll, spirit, spiritBuff)

        amountHealed = rules.healing.calculateBaseAmountHealed(healValue)

        if outOfCombat then
            amountHealed = rules.healing.applyOutOfCombatBaseAmountBonus(amountHealed)
        end

        amountHealed = rules.healing.applyHealingDoneBuff(amountHealed, healingDoneBuff)
        amountHealed = amountHealed + rules.healing.calculateGreaterHealBonus(numGreaterHealSlots)

        if targetIsKO then
            amountHealed = amountHealed + rules.healing.getTargetKOBonus()
        end

        if outOfCombat then
            amountHealed = amountHealed + rules.healing.getOutOfCombatBonus()
        end

        if usesParagon then
            playersHealableWithParagon = rules.healing.calculateNumPlayersHealableWithParagon()
        end

        if isCrit then
            amountHealed = rules.healing.applyCritModifier(amountHealed)
        end
    end

    return {
        canStillHeal = canStillHeal,
        amountHealed = amountHealed,
        isCrit = isCrit,
        outOfCombat = outOfCombat,
        numGreaterHealSlots = numGreaterHealSlots,
        usesParagon = usesParagon,
        playersHealableWithParagon = playersHealableWithParagon,
        traits = {
            [TRAITS.LIFE_PULSE.id] = {
                canUse = amountHealed > 0,
                active = amountHealed > 0 and activeTraits[TRAITS.LIFE_PULSE.id],
            },
        },
    }
end

local function getBuff(roll, rollBuff, spirit, spiritBuff, offence, offenceBuff, activeTraits)
    local buffValue
    local amountBuffed
    local isCrit = rules.buffing.isCrit(roll)

    roll = rules.rolls.calculateRoll(roll, rollBuff)
    buffValue = rules.buffing.calculateBuffValue(roll, spirit, spiritBuff, offence, offenceBuff)

    amountBuffed = rules.buffing.calculateBuffAmount(buffValue)

    return {
        amountBuffed = amountBuffed,
        isCrit = isCrit,
        usesInspiringPresence = rules.buffing.usesInspiringPresence(),
        traits = {
            [TRAITS.ASCEND.id] = {
                canUse = amountBuffed > 0,
                active = amountBuffed > 0 and activeTraits[TRAITS.ASCEND.id],
            },
        },
    }
end

local function getUtility(roll, rollBuff, useUtilityTrait, utilityBonusBuff)
    roll = rules.rolls.calculateRoll(roll, rollBuff)
    local utilityValue = rules.utility.calculateUtilityValue(roll, useUtilityTrait, utilityBonusBuff)

    return {
        utilityValue = utilityValue
    }
end

-- Trait actions

local function getShieldSlam(baseDmgBuff, defence, defenceBuff)
    local dmg = rules.traits.calculateShieldSlamDmg(baseDmgBuff, defence, defenceBuff)

    return {
        dmg = dmg
    }
end

ns.actions.getAttack = getAttack
ns.actions.getPenance = getPenance
ns.actions.getCC = getCC
ns.actions.getDefence = getDefence
ns.actions.getMeleeSave = getMeleeSave
ns.actions.getRangedSave = getRangedSave
ns.actions.getHealing = getHealing
ns.actions.getBuff = getBuff
ns.actions.getUtility = getUtility
ns.actions.traits = {
    getShieldSlam = getShieldSlam
}