local _, ns = ...

local MAX_ROLL = 20

local isCrit
local calculateAttackValue, calculateAttackDmg, applyCritModifier
local calculateDefendValue, calculateDamageTaken, calculateRetaliationDamage

function isCrit(roll)
    local critReq = MAX_ROLL
    if TeaRollHelper.db.profile.feats.keenSense then
        critReq = critReq - 1
    end
    return roll >= critReq
end

-- [[ Offence ]]

function calculateAttackValue(roll, offence, buff)
    return roll + offence + buff
end

function calculateAttackDmg(threshold, attackValue)
    local overkill = attackValue - threshold
    if overkill >= 0 then
        return 1 + floor(overkill / 2)
    end
    return 0
end

function applyCritModifier(dmg)
    return dmg * 2
end

-- [[ Defence ]]

function calculateDefendValue(roll, defence, buff)
    return roll + defence + buff
end

function calculateDamageTaken(threshold, defendValue, dmgRisk)
    local safetyMargin = defendValue - threshold
    if safetyMargin >= 0 then
        return 0
    end
    return dmgRisk
end

function calculateRetaliationDamage(defence)
    return 1 + defence
end

-- [[ Export ]]

ns.rules.MAX_ROLL = MAX_ROLL
ns.rules.isCrit = isCrit
ns.rules.offence = {
    calculateAttackValue = calculateAttackValue,
    calculateAttackDmg = calculateAttackDmg,
    applyCritModifier = applyCritModifier
}
ns.rules.defence = {
    calculateDefendValue = calculateDefendValue,
    calculateDamageTaken = calculateDamageTaken,
    calculateRetaliationDamage = calculateRetaliationDamage
}