local _, ns = ...

local rules = ns.rules

local function getAttack(roll, threshold, offence, buff, numBloodHarvestSlots)
    local attackValue = rules.offence.calculateAttackValue(roll, offence, buff)
    local dmg = rules.offence.calculateAttackDmg(threshold, attackValue)
    local isCrit = rules.isCrit(roll)
    local critType = rules.getCritType()
    local hasAdrenalineProc = nil
    local hasMercyFromPainProc = nil
    local hasEntropicEmbraceProc = nil
    local entropicEmbraceDmg = 0

    if rules.offence.canProcAdrenaline() then
        hasAdrenalineProc = rules.offence.hasAdrenalineProc(threshold, attackValue)
        if hasAdrenalineProc then
            dmg = rules.offence.applyAdrenalineProcModifier(dmg, offence)
        end
    end

    if rules.offence.canUseBloodHarvest() then
        dmg = dmg + rules.offence.calculateBloodHarvestBonus(numBloodHarvestSlots)
    end

    if rules.offence.canProcEntropicEmbrace() then
        hasEntropicEmbraceProc = rules.offence.hasEntropicEmbraceProc(roll, threshold)
        if hasEntropicEmbraceProc then
            entropicEmbraceDmg = rules.offence.getEntropicEmbraceDmg()
        end
    end

    if isCrit and critType == rules.CRIT_TYPES.DAMAGE then
        dmg = rules.offence.applyCritModifier(dmg)
        entropicEmbraceDmg = rules.offence.applyCritModifier(entropicEmbraceDmg)
    end

    if rules.offence.canProcMercyFromPain() then
        hasMercyFromPainProc = rules.offence.hasMercyFromPainProc(dmg + entropicEmbraceDmg)
    end

    return {
        attackValue = attackValue,
        dmg = dmg,
        isCrit = isCrit,
        critType = critType,
        hasAdrenalineProc = hasAdrenalineProc,
        hasMercyFromPainProc = hasMercyFromPainProc,
        hasEntropicEmbraceProc = hasEntropicEmbraceProc,
        entropicEmbraceDmg = entropicEmbraceDmg
    }
end

local function getDefence(roll, threshold, dmgRisk, defence, buff, racialTrait)
    local defendValue = rules.defence.calculateDefendValue(roll, defence, buff, racialTrait)
    local damageTaken = rules.defence.calculateDamageTaken(threshold, defendValue, dmgRisk)
    local isCrit = rules.isCrit(roll)
    local retaliateDmg = 0

    if isCrit then
        retaliateDmg = rules.defence.calculateRetaliationDamage(defence)
    end

    return {
        defendValue = defendValue,
        damageTaken = damageTaken,
        canRetaliate = isCrit,
        retaliateDmg = retaliateDmg
    }
end

local function getMeleeSave(roll, threshold, dmgRisk, defence, buff, racialTrait)
    local meleeSaveValue = rules.meleeSave.calculateMeleeSaveValue(roll, defence, buff, racialTrait)
    local damageTaken = rules.defence.calculateDamageTaken(threshold, meleeSaveValue, dmgRisk)
    local isBigFail = rules.meleeSave.isSaveBigFail(meleeSaveValue, threshold)
    local hasCounterForceProc = nil
    local counterForceDmg = 0

    if isBigFail then
        damageTaken = rules.meleeSave.applyBigFailModifier(damageTaken)
    end

    if rules.meleeSave.canProcCounterForce() then
        hasCounterForceProc = rules.meleeSave.hasCounterForceProc(meleeSaveValue, threshold)
        if hasCounterForceProc then
            counterForceDmg = rules.meleeSave.calculateCounterForceProcDmg(defence)
        end
    end

    return {
        meleeSaveValue = meleeSaveValue,
        damageTaken = damageTaken,
        isBigFail = isBigFail,
        hasCounterForceProc = hasCounterForceProc,
        counterForceDmg = counterForceDmg
    }
end

local function getRangedSave(roll, threshold, dmgRisk, spirit)
    local saveValue = rules.rangedSave.calculateRangedSaveValue(roll, spirit)
    local damageReduction = rules.rangedSave.calculateDamageReduction(threshold, dmgRisk, saveValue, spirit)
    local thresholdMet = saveValue >= threshold

    return {
        saveValue = saveValue,
        damageReduction = damageReduction,
        thresholdMet = thresholdMet
    }
end

local function getHealing(roll, spirit, numGreaterHealSlots, mercyFromPainBonusHealing, outOfCombat)
    local healValue = rules.healing.calculateHealValue(roll, spirit)
    local amountHealed = rules.healing.calculateAmountHealed(healValue)

    amountHealed = amountHealed + rules.healing.calculateGreaterHealBonus(numGreaterHealSlots)

    if outOfCombat then
        amountHealed = rules.healing.applyOutOfCombatBonus(amountHealed)
    else
        amountHealed = amountHealed + mercyFromPainBonusHealing
    end

    return {
        amountHealed = amountHealed,
        isCrit = rules.isCrit(roll)
    }
end

local function getBuff(roll, spirit, offence, offenceBuff)
    local buffValue = rules.buffing.calculateBuffValue(roll, spirit, offence, offenceBuff)
    local amountBuffed = rules.buffing.calculateBuffAmount(buffValue)

    return {
        amountBuffed = amountBuffed,
        isCrit = rules.isCrit(roll),
        usesInspiringPresence = rules.buffing.usesInspiringPresence()
    }
end

local function getUtility(roll, useUtilityTrait)
    return rules.utility.calculateUtilityValue(roll, useUtilityTrait)
end

ns.actions.getAttack = getAttack
ns.actions.getDefence = getDefence
ns.actions.getMeleeSave = getMeleeSave
ns.actions.getRangedSave = getRangedSave
ns.actions.getHealing = getHealing
ns.actions.getBuff = getBuff
ns.actions.getUtility = getUtility