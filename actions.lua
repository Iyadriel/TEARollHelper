local _, ns = ...

local rules = ns.rules

local function getAttack(attackIndex, roll, threshold, offence, offenceBuff, baseDmgBuff, damageDoneBuff, enemyId, isAOE, numBloodHarvestSlots, numVindicationCharges)
    local attackValue
    local dmg
    local critType = rules.offence.getCritType()
    local isCrit = rules.offence.isCrit(roll)
    local hasAdrenalineProc = nil
    local hasMercyFromPainProc = nil
    local mercyFromPainBonusHealing = 0
    local shatterSoulEnabled = false
    local hasVindicationProc = nil
    local vindicationHealing = 0

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

    if rules.offence.canProcVindication() and numVindicationCharges > 0 then
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
        hasAdrenalineProc = hasAdrenalineProc,
        numBloodHarvestSlots = numBloodHarvestSlots,
        hasMercyFromPainProc = hasMercyFromPainProc,
        mercyFromPainBonusHealing = mercyFromPainBonusHealing,
        shatterSoulEnabled = shatterSoulEnabled,
        hasVindicationProc = hasVindicationProc,
        vindicationHealing = vindicationHealing,
    }
end

local function getCC(roll, offence, offenceBuff, defence, defenceBuff)
    local ccValue = rules.cc.calculateCCValue(roll, offence, offenceBuff, defence, defenceBuff)
    local isCrit = rules.cc.isCrit(roll)

    return {
        ccValue = ccValue,
        isCrit = isCrit,
    }
end

local function getDefence(roll, defenceType, threshold, damageType, dmgRisk, defence, defenceBuff, damageTakenBuff)
    local isCrit = rules.defence.isCrit(roll)
    local defendValue, damageTaken, damagePrevented
    local retaliateDmg = 0
    local empoweredBladesEnabled = false

    defendValue = rules.defence.calculateDefendValue(roll, damageType, defence, defenceBuff)
    damageTaken = rules.defence.calculateDamageTaken(defenceType, threshold, defendValue, dmgRisk, damageTakenBuff)
    damagePrevented = rules.defence.calculateDamagePrevented(dmgRisk, damageTaken)

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
    }
end

local function getMeleeSave(roll, defenceType, threshold, damageType, dmgRisk, defence, defenceBuff, damageTakenBuff)
    threshold = threshold + rules.common.SAVE_THRESHOLD_INCREASE

    local meleeSaveValue, damageTaken, damagePrevented
    local isBigFail
    local hasCounterForceProc = nil
    local counterForceDmg = 0

    meleeSaveValue = rules.meleeSave.calculateMeleeSaveValue(roll, damageType, defence, defenceBuff)
    isBigFail = rules.meleeSave.isSaveBigFail(meleeSaveValue, threshold)

    damageTaken = rules.defence.calculateDamageTaken(defenceType, threshold, meleeSaveValue, dmgRisk, damageTakenBuff)

    if isBigFail then
        damageTaken = rules.meleeSave.applyBigFailModifier(damageTaken)
    end

    damagePrevented = rules.meleeSave.calculateDamagePrevented(dmgRisk)

    if rules.meleeSave.canProcCounterForce() then
        hasCounterForceProc = rules.meleeSave.hasCounterForceProc(meleeSaveValue, threshold)
        if hasCounterForceProc then
            counterForceDmg = rules.meleeSave.calculateCounterForceProcDmg(defence)
        end
    end

    return {
        meleeSaveValue = meleeSaveValue,
        dmgRisk = dmgRisk,
        damageTaken = damageTaken,
        damagePrevented = damagePrevented,
        isBigFail = isBigFail,
        hasCounterForceProc = hasCounterForceProc,
        counterForceDmg = counterForceDmg
    }
end

local function getRangedSave(roll, defenceType, threshold, spirit, buff)
    threshold = threshold + rules.common.SAVE_THRESHOLD_INCREASE

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

local function getHealing(roll, spirit, spiritBuff, healingDoneBuff, numGreaterHealSlots, targetIsKO, outOfCombat, remainingOutOfCombatHeals)
    local canStillHeal = rules.healing.canStillHeal(outOfCombat, remainingOutOfCombatHeals, numGreaterHealSlots)
    local healValue
    local amountHealed = 0
    local isCrit = rules.healing.isCrit(roll)
    local usesParagon = rules.healing.usesParagon()
    local playersHealableWithParagon = nil

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
    }
end

local function getBuff(roll, spirit, spiritBuff, offence, offenceBuff)
    local buffValue
    local amountBuffed
    local isCrit = rules.buffing.isCrit(roll)

    buffValue = rules.buffing.calculateBuffValue(roll, spirit, spiritBuff, offence, offenceBuff)

    amountBuffed = rules.buffing.calculateBuffAmount(buffValue)

    return {
        amountBuffed = amountBuffed,
        isCrit = isCrit,
        usesInspiringPresence = rules.buffing.usesInspiringPresence()
    }
end

local function getUtility(roll, useUtilityTrait)
    local utilityValue = rules.utility.calculateUtilityValue(roll, useUtilityTrait)

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