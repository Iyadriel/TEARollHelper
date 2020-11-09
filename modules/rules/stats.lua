local _, ns = ...

local character = ns.character
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local WEAKNESSES = weaknesses.WEAKNESSES

local BASE_MAX_HEALTH = 25

local BASE_STAT_POINTS = 12
local MAX_STAT_POINTS = 16
local NEGATIVE_POINTS_BUDGET = MAX_STAT_POINTS - BASE_STAT_POINTS
local STAT_MIN_VALUE = -4
local STAT_MAX_VALUE = 6
local STAT_POINT_COSTS = {
    [1] = 1,
    [2] = 2,
    [3] = 4,
    [4] = 6,
    [5] = 9,
    [6] = 12
}

local function getNegativePointsAssigned()
    local negativePointsAllocated = 0

    local offence = character.getPlayerOffence()
    local defence = character.getPlayerDefence()
    local spirit = character.getPlayerSpirit()
    local stamina = character.getPlayerStamina()

    if offence < 0 then
        negativePointsAllocated = negativePointsAllocated - offence
    end

    if defence < 0 then
        negativePointsAllocated = negativePointsAllocated - defence
    end

    if spirit < 0 then
        negativePointsAllocated = negativePointsAllocated - spirit
    end

    if stamina < 0 then
        negativePointsAllocated = negativePointsAllocated - stamina
    end

    return negativePointsAllocated
end

local function getNegativePointsUsed()
    return min(NEGATIVE_POINTS_BUDGET, getNegativePointsAssigned())
end

local function getAvailableNegativePoints()
    return NEGATIVE_POINTS_BUDGET - getNegativePointsUsed()
end

local function getAvailableStatPoints()
    local points = BASE_STAT_POINTS

    local offence = character.getPlayerOffence()
    local defence = character.getPlayerDefence()
    local spirit = character.getPlayerSpirit()
    local stamina = character.getPlayerStamina()

    if offence > 0 then
        points = points - STAT_POINT_COSTS[offence]
    end

    if defence > 0 then
        points = points - STAT_POINT_COSTS[defence]
    end

    if spirit > 0 then
        points = points - STAT_POINT_COSTS[spirit]
    end

    if stamina > 0 then
        points = points - STAT_POINT_COSTS[stamina]
    end

    points = points + getNegativePointsUsed()

    return points
end

local function calculateMaxHealth(stamina, staminaBuff, maxHealthBuff)
    staminaBuff = staminaBuff or 0
    maxHealthBuff = maxHealthBuff or 0
    stamina = stamina + staminaBuff

    local maxHealth = BASE_MAX_HEALTH + (stamina * 2) + maxHealthBuff

    if character.hasWeakness(WEAKNESSES.FRAGILE) then
        maxHealth = maxHealth - 8
    end

    maxHealth = max(1, maxHealth) -- sanity check

    return maxHealth
end

local function validateStatsForRebound()
    return max(character.getPlayerOffence(), character.getPlayerSpirit()) >= 4
end

local function validateStatsForTemperedBenevolence()
    return character.getPlayerSpirit() >= 4
end

local function validateStatsForOverflow()
    return character.getPlayerSpirit() >= 4
end

rules.stats = {
    STAT_MIN_VALUE = STAT_MIN_VALUE,
    STAT_MAX_VALUE = STAT_MAX_VALUE,
    getNegativePointsAssigned = getNegativePointsAssigned,
    getNegativePointsUsed = getNegativePointsUsed,
    getAvailableNegativePoints = getAvailableNegativePoints,
    getAvailableStatPoints = getAvailableStatPoints,
    calculateMaxHealth = calculateMaxHealth,

    validateStatsForRebound = validateStatsForRebound,
    validateStatsForTemperedBenevolence = validateStatsForTemperedBenevolence,
    validateStatsForOverflow = validateStatsForOverflow,
}