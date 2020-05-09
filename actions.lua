local _, ns = ...

local character = ns.character
local rules = ns.rules
local turns = ns.turns

local performAttack, performDefence

function performAttack(roll)
    local currentTurnValues = turns.getCurrentTurnValues()

    local threshold = currentTurnValues.attackThreshold
    local offence = character.getPlayerOffence()
    local buff = turns.getCurrentBuffs().offence

    local attackValue = rules.offence.calculateAttackValue(roll, offence, buff)
    local dmg = rules.offence.calculateAttackDmg(threshold, attackValue)

    local details
    if buff > 0 then
        details = "|cFFBBBBBB("..threshold.." to beat, your attack was "..roll.." + "..offence.." |cFF00FF00+ "..buff.."|r = "..attackValue..")"
    else
        details = "|cFFBBBBBB("..threshold.." to beat, your attack was "..roll.." + "..offence.." = "..attackValue..")"
    end

    if dmg > 0 then
        if rules.isCrit(roll) then
            dmg = rules.offence.applyCritModifier(dmg)
            TeaRollHelper:Print("CRITICAL HIT! You deal "..dmg.." damage. "..details)
        else
            TeaRollHelper:Print("Attack successful! You deal "..dmg.." damage. "..details)
        end
    else
        TeaRollHelper:Print("Attack failed. "..details)
    end

    turns.clearCurrentBuff(turns.BUFF_TYPES.OFFENCE)
end

function performDefence(roll)
    local currentTurnValues = turns.getCurrentTurnValues()

    local threshold = currentTurnValues.defendTreshold
    local dmgRisk = currentTurnValues.damageRisk
    local defence = character.getPlayerDefence()
    local buff = turns.getCurrentBuffs().defence

    local defendValue = rules.defence.calculateDefendValue(roll, defence, buff)
    local damageTaken = rules.defence.calculateDamageTaken(threshold, defendValue, dmgRisk)

    local details
    if buff > 0 then
        details = "|cFFBBBBBB("..threshold.." to beat, your defence was "..roll.." + "..defence.." |cFF00FF00+ "..buff.."|r = "..defendValue..")"
    else
        details = "|cFFBBBBBB("..threshold.." to beat, your defence was "..roll.." + "..defence.." = "..defendValue..")"
    end

    if damageTaken == 0 then
        TeaRollHelper:Print("Safe! You take no damage. "..details)
        if rules.isCrit(roll) then
            local retaliateDmg = rules.defence.calculateRetaliationDamage(defence)
            TeaRollHelper:Print("RETALIATE! You can deal "..retaliateDmg.." damage to your attacker!")
        end
    else
        TeaRollHelper:Print("Defence failed. You take |cFFFF0000"..damageTaken.."|r damage. "..details)
    end

    turns.clearCurrentBuff(turns.BUFF_TYPES.DEFENCE)
end

ns.actions.performAttack = performAttack
ns.actions.performDefence = performDefence