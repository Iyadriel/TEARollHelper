local _, ns = ...

local character = ns.character
local rules = ns.rules
local turns = ns.turns

local getAttack, getDefence, getHealing
local performAttack, performDefence

function getAttack(roll, threshold, offence, buff)
    local attackValue = rules.offence.calculateAttackValue(roll, offence, buff)
    local dmg = rules.offence.calculateAttackDmg(threshold, attackValue)
    local isCrit = rules.isCrit(roll)

    if isCrit then
        dmg = rules.offence.applyCritModifier(dmg)
    end

    return {
        attackValue = attackValue,
        dmg = dmg,
        isCrit = isCrit
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

function getHealing(roll, spirit)
    local healValue = rules.healing.calculateHealValue(roll, spirit)
    local amountHealed = rules.healing.calculateAmountHealed(healValue)

    return {
        amountHealed = amountHealed,
        isCrit = rules.isCrit(roll)
    }
end

function performAttack(roll)
    local currentTurnValues = turns.getCurrentTurnValues()

    local threshold = currentTurnValues.attackThreshold
    local offence = character.getPlayerOffence()
    local buff = turns.getCurrentBuffs().offence

    local attack = getAttack(roll, threshold, offence, buff)

    local details
    if buff > 0 then
        details = "|cFFBBBBBB("..threshold.." to beat, your attack was "..roll.." + "..offence.." |cFF00FF00+ "..buff.."|r = "..attack.attackValue..")"
    else
        details = "|cFFBBBBBB("..threshold.." to beat, your attack was "..roll.." + "..offence.." = "..attack.attackValue..")"
    end

    if attack.dmg > 0 then
        if attack.isCrit then
            TEARollHelper:Print("CRITICAL HIT! You deal "..attack.dmg.." damage. "..details)
        else
            TEARollHelper:Print("Attack successful! You deal "..attack.dmg.." damage. "..details)
        end
    else
        TEARollHelper:Print("Attack failed. "..details)
    end

    turns.expireCurrentBuff(turns.BUFF_TYPES.OFFENCE)
end

function performDefence(roll)
    local currentTurnValues = turns.getCurrentTurnValues()

    local threshold = currentTurnValues.defendTreshold
    local dmgRisk = currentTurnValues.damageRisk
    local defence = character.getPlayerDefence()
    local buff = turns.getCurrentBuffs().defence

    local result = getDefence(roll, threshold, dmgRisk, defence, buff)

    local details
    if buff > 0 then
        details = "|cFFBBBBBB("..threshold.." to beat, your defence was "..roll.." + "..defence.." |cFF00FF00+ "..buff.."|r = "..result.defendValue..")"
    else
        details = "|cFFBBBBBB("..threshold.." to beat, your defence was "..roll.." + "..defence.." = "..result.defendValue..")"
    end

    if result.damageTaken == 0 then
        TEARollHelper:Print("Safe! You take no damage. "..details)
        if result.canRetaliate then
            TEARollHelper:Print("RETALIATE! You can deal "..result.retaliateDmg.." damage to your attacker!")
        end
    else
        TEARollHelper:Print("Defence failed. You take |cFFFF0000"..result.damageTaken.."|r damage. "..details)
    end

    turns.expireCurrentBuff(turns.BUFF_TYPES.DEFENCE)
end

ns.actions.getAttack = getAttack
ns.actions.getDefence = getDefence
ns.actions.getHealing = getHealing
ns.actions.performAttack = performAttack
ns.actions.performDefence = performDefence