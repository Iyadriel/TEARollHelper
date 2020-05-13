local _, ns = ...

local rules = ns.rules
local turns = ns.turns

local getAttack, getDefence, getMeleeSave, getHealing, getBuff

function getAttack(roll, threshold, offence, buff)
    local attackValue = rules.offence.calculateAttackValue(roll, offence, buff)
    local dmg = rules.offence.calculateAttackDmg(threshold, attackValue)
    local isCrit = rules.isCrit(roll)
    local hasEntropicEmbraceProc = nil

    if isCrit then
        dmg = rules.offence.applyCritModifier(dmg)
    end

    if rules.offence.canProcEntropicEmbrace() then
        hasEntropicEmbraceProc = rules.offence.hasEntropicEmbraceProc(roll, threshold)
    end

    return {
        attackValue = attackValue,
        dmg = dmg,
        isCrit = isCrit,
        hasEntropicEmbraceProc = hasEntropicEmbraceProc
    }
end

function getDefence(roll, threshold, dmgRisk, defence, buff)
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

function getMeleeSave(roll, threshold, dmgRisk, defence, buff)
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

function getHealing(roll, spirit)
    local healValue = rules.healing.calculateHealValue(roll, spirit)
    local amountHealed = rules.healing.calculateAmountHealed(healValue)

    return {
        amountHealed = amountHealed,
        isCrit = rules.isCrit(roll)
    }
end

function getBuff(roll, spirit)
    local buffValue = rules.buffing.calculateBuffValue(roll, spirit)
    local amountBuffed = rules.buffing.calculateBuffAmount(buffValue)

    return {
        amountBuffed = amountBuffed,
        isCrit = rules.isCrit(roll)
    }
end

ns.actions.getAttack = getAttack
ns.actions.getDefence = getDefence
ns.actions.getMeleeSave = getMeleeSave
ns.actions.getHealing = getHealing
ns.actions.getBuff = getBuff