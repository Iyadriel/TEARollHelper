local _, ns = ...

local character = ns.character
local rules = ns.rules

local function shouldShowEnemySelect()
    return character.getPlayerFeat().advantageAgainstEnemies or character.getPlayerRacialTrait().buffAgainstEnemies
end

local function shouldShowZoneSelect()
    return character.getPlayerRacialTrait().zones
end

local function shouldShowEnvironment()
    return shouldShowEnemySelect() or shouldShowZoneSelect()
end

rules.environment = {
    shouldShowEnemySelect = shouldShowEnemySelect,
    shouldShowZoneSelect = shouldShowZoneSelect,
    shouldShowEnvironment = shouldShowEnvironment,
}