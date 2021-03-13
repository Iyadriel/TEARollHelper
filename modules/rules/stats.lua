local _, ns = ...

local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local WEAKNESSES = weaknesses.WEAKNESSES

local STATS = constants.STATS

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

    for stat in pairs(STATS) do
        local value = character.getPlayerStat(stat)
        if value < 0 then
            negativePointsAllocated = negativePointsAllocated - value
        end
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

    for stat in pairs(STATS) do
        local value = character.getPlayerStat(stat)
        if value > 0 then
            points = points - STAT_POINT_COSTS[value]
        end
    end

    points = points + getNegativePointsUsed()

    return points
end

local function calculateMaxHealth(stamina, staminaBuff, maxHealthBuff)
    staminaBuff = staminaBuff or 0
    maxHealthBuff = maxHealthBuff or 0
    stamina = stamina + staminaBuff

    local HP_PER_STAMINA = character.hasFeat(FEATS.MASTER) and 3 or 2
    local maxHealth = BASE_MAX_HEALTH + (stamina * HP_PER_STAMINA) + maxHealthBuff

    if character.hasWeakness(WEAKNESSES.FRAGILE) then
        maxHealth = maxHealth - 8
    end

    maxHealth = max(1, maxHealth) -- sanity check

    return maxHealth
end

local function validateStatsFor(featOrTrait)
    if featOrTrait.requiredStats then
        for _, pair in ipairs(featOrTrait.requiredStats) do
            local pairOk = true

            for stat, minValue in pairs(pair) do
                if character.getPlayerStat(stat) < minValue then
                    pairOk = false
                    break
                end
            end

            if pairOk then
                return true
            end
        end

        return false
    end

    return true
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

    validateStatsFor = validateStatsFor,
    validateStatsForRebound = validateStatsForRebound,
    validateStatsForTemperedBenevolence = validateStatsForTemperedBenevolence,
    validateStatsForOverflow = validateStatsForOverflow,
}