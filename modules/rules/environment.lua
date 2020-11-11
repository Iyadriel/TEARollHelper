local _, ns = ...

local character = ns.character
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local WEAKNESSES = weaknesses.WEAKNESSES
local TRAITS = traits.TRAITS

local function shouldShowEnemySelect()
    local featPassives = character.getPlayerFeat().passives

    return featPassives and featPassives.advantageAgainstEnemies
        or character.getPlayerRacialTrait().buffAgainstEnemies
        or character.hasTrait(TRAITS.SHATTER_SOUL)
        or character.hasWeakness(WEAKNESSES.WOE_UPON_THE_AFFLICTED)
end

local function shouldShowZoneSelect()
    return character.getPlayerRacialTrait().zones
end

local function shouldShowDistanceFromEnemy()
    return character.hasWeakness(WEAKNESSES.TIMID)
end

rules.environment = {
    shouldShowEnemySelect = shouldShowEnemySelect,
    shouldShowZoneSelect = shouldShowZoneSelect,
    shouldShowDistanceFromEnemy = shouldShowDistanceFromEnemy,
}