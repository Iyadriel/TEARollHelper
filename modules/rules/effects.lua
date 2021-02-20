local _, ns = ...

local character = ns.character
local constants = ns.constants
local environment = ns.state.environment
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local INCOMING_HEAL_SOURCES = constants.INCOMING_HEAL_SOURCES
local WEAKNESSES = weaknesses.WEAKNESSES

local function calculateEffectiveIncomingDamage(incomingDamage, damageTakenBuff, canBeMitigated)
    if damageTakenBuff > 0 or canBeMitigated then
        incomingDamage = incomingDamage + damageTakenBuff
    end

    if character.hasWeakness(WEAKNESSES.GLASS_CANNON) then
        incomingDamage = incomingDamage + 4
    end

    if character.hasWeakness(WEAKNESSES.WOE_UPON_THE_AFFLICTED) then
        local enemyId = environment.state.enemyId.get()
        if WEAKNESSES.WOE_UPON_THE_AFFLICTED.weakAgainstEnemies[enemyId] then
            incomingDamage = incomingDamage + 4
        end
    end

    incomingDamage = max(0, incomingDamage)

    return incomingDamage
end

local function calculateDamageTaken(effectiveIncomingDamage, currentHealth)
    local overkill = max(0, effectiveIncomingDamage - currentHealth)
    local damageTaken = effectiveIncomingDamage - overkill

    return {
        effectiveIncomingDamage = effectiveIncomingDamage,
        damageTaken = damageTaken,
        overkill = overkill
    }
end

local function applyCorruptionModifier(healAmount)
    return floor(healAmount / 2)
end

local function calculateHealingReceived(incomingHealAmount, source, currentHealth, maxHealth)
    local amountHealed = incomingHealAmount

    if character.hasWeakness(WEAKNESSES.CORRUPTED) and source ~= INCOMING_HEAL_SOURCES.SELF then
        amountHealed = applyCorruptionModifier(amountHealed)
    end

    if character.hasStaminaMastery() then
        amountHealed = amountHealed + 2
    end

    local overhealing = max(0, currentHealth + amountHealed - maxHealth)
    local netAmountHealed = amountHealed - overhealing

    return {
        amountHealed = amountHealed,
        netAmountHealed = netAmountHealed,
        overhealing = overhealing,
    }
end

rules.effects = {
    calculateEffectiveIncomingDamage = calculateEffectiveIncomingDamage,
    calculateDamageTaken = calculateDamageTaken,
    calculateHealingReceived = calculateHealingReceived,
}