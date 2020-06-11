local _, ns = ...

local rules = ns.rules

local function getAttack(roll, preppedRoll, threshold, offence, buff, numBloodHarvestSlots, numVindicationCharges)
    local attackValue
    local dmg
    local critType = rules.offence.getCritType()
    local isCrit = rules.offence.isCrit(roll)
    local hasAdrenalineProc = nil
    local hasMercyFromPainProc = nil
    local hasEntropicEmbraceProc = nil
    local entropicEmbraceDmg = 0
    local hasVindicationProc = nil
    local vindicationHealing = 0

    attackValue = rules.offence.calculateAttackValue(roll, offence, buff)

    if preppedRoll then
        attackValue = attackValue + rules.offence.calculateAttackValue(preppedRoll, offence, buff)
    end

    dmg = rules.offence.calculateAttackDmg(threshold, attackValue)

    if not isCrit and preppedRoll then
        isCrit = rules.offence.isCrit(preppedRoll)
    end

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
        if not hasEntropicEmbraceProc and preppedRoll then
            hasEntropicEmbraceProc = rules.offence.hasEntropicEmbraceProc(preppedRoll, threshold)
        end
        if hasEntropicEmbraceProc then
            entropicEmbraceDmg = rules.offence.getEntropicEmbraceDmg()
        end
    end

    if isCrit and critType == rules.offence.CRIT_TYPES.DAMAGE then
        dmg = rules.offence.applyCritModifier(dmg)
        entropicEmbraceDmg = rules.offence.applyCritModifier(entropicEmbraceDmg)
    end

    if rules.offence.canProcMercyFromPain() then
        hasMercyFromPainProc = rules.offence.hasMercyFromPainProc(dmg + entropicEmbraceDmg)
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
        hasMercyFromPainProc = hasMercyFromPainProc,
        hasEntropicEmbraceProc = hasEntropicEmbraceProc,
        entropicEmbraceDmg = entropicEmbraceDmg,
        hasVindicationProc = hasVindicationProc,
        vindicationHealing = vindicationHealing,
    }
end

local function getDefence(roll, threshold, dmgRisk, defence, buff)
    local isCrit = rules.defence.isCrit(roll)
    local defendValue, damageTaken
    local retaliateDmg = 0

    defendValue = rules.defence.calculateDefendValue(roll, defence, buff)
    damageTaken = rules.defence.calculateDamageTaken(threshold, defendValue, dmgRisk)

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

local function getMeleeSave(roll, threshold, dmgRisk, defence, buff)
    local meleeSaveValue = rules.meleeSave.calculateMeleeSaveValue(roll, defence, buff)
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

local function getRangedSave(roll, threshold, spirit, buff)
    local saveValue = rules.rangedSave.calculateRangedSaveValue(roll, spirit, buff)
    local canFullyProtect = rules.rangedSave.canFullyProtect(threshold, saveValue)
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

local function getHealing(roll, spirit, buff, numGreaterHealSlots, lifePulse, mercyFromPainBonusHealing, outOfCombat)
    local healValue = rules.healing.calculateHealValue(roll, spirit, buff)
    local amountHealed = rules.healing.calculateAmountHealed(healValue)
    local isCrit = rules.healing.isCrit(roll)
    local usesParagon = rules.healing.usesParagon()
    local playersHealableWithParagon = nil

    amountHealed = amountHealed + rules.healing.calculateGreaterHealBonus(numGreaterHealSlots)

    if outOfCombat then
        amountHealed = rules.healing.applyOutOfCombatBonus(amountHealed)
    else
        amountHealed = amountHealed + mercyFromPainBonusHealing
    end


    if usesParagon then
        playersHealableWithParagon = rules.healing.calculateNumPlayersHealableWithParagon()
    end

    if isCrit then
        amountHealed = rules.healing.applyCritModifier(amountHealed)
    end

    return {
        amountHealed = amountHealed,
        isCrit = isCrit,
        numGreaterHealSlots = numGreaterHealSlots,
        lifePulse = lifePulse,
        usesParagon = usesParagon,
        playersHealableWithParagon = playersHealableWithParagon,
    }
end

local function getBuff(roll, spirit, spiritBuff, offence, offenceBuff)
    local buffValue = rules.buffing.calculateBuffValue(roll, spirit, spiritBuff, offence, offenceBuff)
    local amountBuffed = rules.buffing.calculateBuffAmount(buffValue)
    local isCrit = rules.buffing.isCrit(roll)

    return {
        amountBuffed = amountBuffed,
        isCrit = isCrit,
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