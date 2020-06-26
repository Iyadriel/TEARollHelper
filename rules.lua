local _, ns = ...

local character = ns.character
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local TRAITS = traits.TRAITS
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

local function canUseFeats()
    return not character.hasWeakness(WEAKNESSES.FEATLESS)
end

local function calculateHealingReceived(incomingHealAmount, currentHealth, maxHealth)
    local amountHealed
    if character.hasWeakness(WEAKNESSES.CORRUPTED) then
        amountHealed = applyCorruptionModifier(incomingHealAmount)
    else
        amountHealed = incomingHealAmount
    end

    local overhealing = max(0, currentHealth + amountHealed - maxHealth)
    local netAmountHealed = amountHealed - overhealing

    return {
        amountHealed = amountHealed,
        netAmountHealed = netAmountHealed,
        overhealing = overhealing,
    }
end

local function shouldShowPreRollUI()
    return character.hasTrait(TRAITS.VERSATILE)
end

-- For use by other rule modules
rules.common = {
    calculateOffenceStat = calculateOffenceStat,
    calculateDefenceStat = calculateDefenceStat,
    calculateSpiritStat = calculateSpiritStat,
}

rules.other = {
    canUseFeats = canUseFeats,
    calculateHealingReceived = calculateHealingReceived,
    shouldShowPreRollUI = shouldShowPreRollUI,
}