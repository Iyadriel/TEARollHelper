local _, ns = ...

local rules = ns.rules

local function getAttack(roll, threshold, offence, buff)
    local attackValue = rules.offence.calculateAttackValue(roll, offence, buff)
    local dmg = rules.offence.calculateAttackDmg(threshold, attackValue)
    local isCrit = rules.isCrit(roll)
    local critType = rules.getCritType()
    local hasAdrenalineProc = nil
    local hasEntropicEmbraceProc = nil
    local entropicEmbraceDmg = 0

    if rules.offence.canProcAdrenaline() then
        hasAdrenalineProc = rules.offence.hasAdrenalineProc(threshold, attackValue)
        if hasAdrenalineProc then
            dmg = rules.offence.applyAdrenalineProcModifier(dmg, offence)
        end
    end

    if rules.offence.canProcEntropicEmbrace() then
        hasEntropicEmbraceProc = rules.offence.hasEntropicEmbraceProc(roll, threshold)
        if hasEntropicEmbraceProc then
            entropicEmbraceDmg = rules.offence.getEntropicEmbraceDmg()
        end
    end

    if isCrit then
        if critType == rules.CRIT_TYPES.DAMAGE then
            dmg = rules.offence.applyCritModifier(dmg)
            entropicEmbraceDmg = rules.offence.applyCritModifier(entropicEmbraceDmg)
        end
    end

    return {
        attackValue = attackValue,
        dmg = dmg,
        isCrit = isCrit,
        critType = critType,
        hasAdrenalineProc = hasAdrenalineProc,
        hasEntropicEmbraceProc = hasEntropicEmbraceProc,
        entropicEmbraceDmg = entropicEmbraceDmg
    }
end

local function getDefence(roll, threshold, dmgRisk, defence, buff)
    local defendValue = rules.defence.calculateDefendValue(roll, defence, buff)
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

local function getMeleeSave(roll, threshold, dmgRisk, defence, buff)
    local defendValue = rules.defence.calculateDefendValue(roll, defence, buff)
    local damageTaken = rules.defence.calculateDamageTaken(threshold, defendValue, dmgRisk)
    local isBigFail = rules.meleeSave.isSaveBigFail(defendValue, threshold)

    if isBigFail then
        damageTaken = rules.meleeSave.applyBigFailModifier(damageTaken)
    end

    return {
        defendValue = defendValue,
        damageTaken = damageTaken,
        isBigFail = isBigFail
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

local function getHealing(roll, spirit, numGreaterHealSlots)
    local healValue = rules.healing.calculateHealValue(roll, spirit)
    local amountHealed = rules.healing.calculateAmountHealed(healValue)

    amountHealed = amountHealed + rules.healing.calculateGreaterHealBonus(numGreaterHealSlots)

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
        isCrit = rules.isCrit(roll)
    }
end

ns.actions.getAttack = getAttack
ns.actions.getDefence = getDefence
ns.actions.getMeleeSave = getMeleeSave
ns.actions.getRangedSave = getRangedSave
ns.actions.getHealing = getHealing
ns.actions.getBuff = getBuff