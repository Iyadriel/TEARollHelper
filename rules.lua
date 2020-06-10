local _, ns = ...

local character = ns.character
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local WEAKNESSES = weaknesses.WEAKNESSES

local function calculateOffenceStat(offence, buff)
    return offence + buff
end

local function calculateDefenceStat(defence, buff)
    return defence + buff
end

local function calculateSpiritStat(spirit, buff)
    return spirit + buff
end

local function applyCorruptionModifier(healAmount)
    return floor(healAmount / 2)
end

local function calculateHealingReceived(incomingHealAmount, currentHealth)
    local amountHealed
    if character.hasWeakness(WEAKNESSES.CORRUPTED) then
        amountHealed = applyCorruptionModifier(incomingHealAmount)
    else
        amountHealed = incomingHealAmount
    end

    local maxHP = character.getPlayerMaxHP()
    local overhealing = max(0, currentHealth + amountHealed - maxHP)
    local netAmountHealed = amountHealed - overhealing

    return {
        amountHealed = amountHealed,
        netAmountHealed = netAmountHealed,
        overhealing = overhealing,
    }
end

-- For use by other rule modules
rules.common = {
    calculateOffenceStat = calculateOffenceStat,
    calculateDefenceStat = calculateDefenceStat,
    calculateSpiritStat = calculateSpiritStat,
}

rules.other = {
    calculateHealingReceived = calculateHealingReceived,
}