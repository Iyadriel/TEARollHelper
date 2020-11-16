local _, ns = ...

local character = ns.character
local rules = ns.rules

local racialTraits = ns.resources.racialTraits
local weaknesses = ns.resources.weaknesses

local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local function getClingToConsciousnessThreshold()
    return character.hasRacialTrait(RACIAL_TRAITS.BRUSH_IT_OFF) and 12 or 15
end

local function getClingToConsciousnessDuration()
    local stamina = character.getPlayerStamina()
    return 1 + floor(stamina / 2)
end

local function canRecoverFromClingingOn(health, maxHealth)
    return health >= maxHealth
end

local function canRecoverFromKO(health, maxHealth)
    return health >= ceil(maxHealth / 2)
end

local function getKOMaxHealthReduction()
    return character.hasWeakness(WEAKNESSES.WORN) and 6 or 3
end

rules.KO = {
    getClingToConsciousnessThreshold = getClingToConsciousnessThreshold,
    getClingToConsciousnessDuration = getClingToConsciousnessDuration,

    canRecoverFromClingingOn = canRecoverFromClingingOn,
    canRecoverFromKO = canRecoverFromKO,

    getKOMaxHealthReduction = getKOMaxHealthReduction,
}