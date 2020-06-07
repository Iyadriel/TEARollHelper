local _, ns = ...

local character = ns.character
local rules = ns.rules

local function shouldShowEnemySelect()
    return character.getPlayerFeat().advantageAgainstEnemies or character.getPlayerRacialTrait().buffAgainstEnemies
end

local function shouldShowEnvironment()
    return shouldShowEnemySelect()
end

rules.environment = {
    shouldShowEnemySelect = shouldShowEnemySelect,
    shouldShowEnvironment = shouldShowEnvironment,
}