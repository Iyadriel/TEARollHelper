local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local function shouldShowEnemySelect()
    local featPassives = character.getPlayerFeat().passives

    return featPassives and featPassives.advantageAgainstEnemies
        or character.getPlayerRacialTrait().buffAgainstEnemies
        or character.hasFeat(FEATS.ETERNAL_SACRIFICE)
        or character.hasTrait(TRAITS.HOLY_BULWARK)
        or character.hasWeakness(WEAKNESSES.WOE_UPON_THE_AFFLICTED)
end

local function shouldShowZoneSelect()
    return character.getPlayerRacialTrait().zones
end

local function shouldShowDistanceFromEnemy()
    return character.hasWeakness(WEAKNESSES.TIMID)
end

local function shouldShowEnvironment()
    return shouldShowZoneSelect() or shouldShowDistanceFromEnemy()
end

rules.environment = {
    shouldShowEnemySelect = shouldShowEnemySelect,
    shouldShowZoneSelect = shouldShowZoneSelect,
    shouldShowDistanceFromEnemy = shouldShowDistanceFromEnemy,
    shouldShowEnvironment = shouldShowEnvironment,
}