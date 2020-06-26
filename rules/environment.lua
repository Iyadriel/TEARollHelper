local _, ns = ...

local character = ns.character
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local WEAKNESSES = weaknesses.WEAKNESSES

local function shouldShowEnemySelect()
    return character.getPlayerFeat().advantageAgainstEnemies
        or character.getPlayerRacialTrait().buffAgainstEnemies
        or character.hasWeakness(WEAKNESSES.WOE_UPON_THE_AFFLICTED)
end

local function shouldShowZoneSelect()
    return character.getPlayerRacialTrait().zones
end

local function shouldShowDistanceFromEnemy()
    return character.hasWeakness(WEAKNESSES.TIMID)
end

local function shouldShowEnvironment()
    return shouldShowEnemySelect() or shouldShowZoneSelect() or shouldShowDistanceFromEnemy()
end

rules.environment = {
    shouldShowEnemySelect = shouldShowEnemySelect,
    shouldShowZoneSelect = shouldShowZoneSelect,
    shouldShowDistanceFromEnemy = shouldShowDistanceFromEnemy,
    shouldShowEnvironment = shouldShowEnvironment,
}