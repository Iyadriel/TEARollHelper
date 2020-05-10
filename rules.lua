local _, ns = ...

local MAX_ROLL = 20

local function isCrit(roll)
    local critReq = MAX_ROLL
    if TEARollHelper.db.profile.feats.keenSense then
        critReq = critReq - 1
    end
    return roll >= critReq
end

-- [[ Offence ]]

local function calculateAttackValue(roll, offence, buff)
    return roll + offence + buff
end

local function calculateAttackDmg(threshold, attackValue)
    local overkill = attackValue - threshold
    if overkill >= 0 then
        return 1 + floor(overkill / 2)
    end
    return 0
end

local function applyCritModifier(dmg)
    return dmg * 2
end

-- [[ Defence ]]

local function calculateDefendValue(roll, defence, buff)
    return roll + defence + buff
end

local function calculateDamageTaken(threshold, defendValue, dmgRisk)
    local safetyMargin = defendValue - threshold
    if safetyMargin >= 0 then
        return 0
    end
    return dmgRisk
end

local function calculateRetaliationDamage(defence)
    return 1 + defence
end

-- [[ Healing ]]

local function calculateHealValue(roll, spirit)
    return roll + spirit
end

local function calculateAmountHealed(healValue)
    if healValue > 19 then
        return 5
    elseif healValue > 14 then
        return 4
    elseif healValue > 9 then
        return 3
    elseif healValue > 4 then
        return 2
    elseif healValue > 1 then
        return 1
    end

    return 0
end

-- [[ Buffing ]]

local function calculateBuffValue(roll, spirit)
    return roll + spirit
end

local function calculateBuffAmount(buffValue)
    return ceil(buffValue / 2)
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
ns.rules.healing = {
    calculateHealValue = calculateHealValue,
    calculateAmountHealed = calculateAmountHealed
}
ns.rules.buffing = {
    calculateBuffValue = calculateBuffValue,
    calculateBuffAmount = calculateBuffAmount
}