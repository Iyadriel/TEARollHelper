local _, ns = ...

local character = ns.character
local constants = ns.constants
local environment = ns.state.environment
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local INCOMING_HEAL_SOURCES = constants.INCOMING_HEAL_SOURCES
local WEAKNESSES = weaknesses.WEAKNESSES

local function calculateDamageTaken(incomingDamage)
    if character.hasWeakness(WEAKNESSES.WOE_UPON_THE_AFFLICTED) then
        local enemyId = environment.state.enemyId.get()
        if WEAKNESSES.WOE_UPON_THE_AFFLICTED.weakAgainstEnemies[enemyId] then
            incomingDamage = incomingDamage + 4
        end
    end

    return incomingDamage
end

local function applyCorruptionModifier(healAmount)
    return floor(healAmount / 2)
end

local function calculateHealingReceived(incomingHealAmount, source, currentHealth, maxHealth)
    local amountHealed

    if character.hasWeakness(WEAKNESSES.CORRUPTED) and source ~= INCOMING_HEAL_SOURCES.SELF then
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

rules.effects = {
    calculateDamageTaken = calculateDamageTaken,
    calculateHealingReceived = calculateHealingReceived,
}