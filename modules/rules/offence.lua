local _, ns = ...

local character = ns.character
local constants = ns.constants
local rules = ns.rules

local enemies = ns.resources.enemies
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local ACTIONS = constants.ACTIONS
local ENEMIES = enemies.ENEMIES
local FEATS = feats.FEATS
local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local NUM_OFFENCE_PER_BLOOD_HARVEST_SLOT = 2

-- Crits

local function isCrit(roll)
    local critReq = rules.rolls.getCritReq(ACTIONS.attack)

    if character.hasRacialTrait(RACIAL_TRAITS.VICIOUSNESS) then
        critReq = critReq - 1
    end

    return roll >= critReq
end

local function calculateAttackValue(roll, stat, statBuff)
    return roll + rules.common.calculateGenericStat(stat, statBuff)
end

local function isSuccessful(attackValue, threshold)
    return attackValue >= threshold
end

-- Enemies

local function hasAdvantageAgainstEnemy(enemyId)
    local hasAdvantage = false
    local featPassives = character.getPlayerFeat().passives
    if featPassives and featPassives.advantageAgainstEnemies then
        hasAdvantage = featPassives.advantageAgainstEnemies[enemyId]
    end
    return hasAdvantage
end

local function getRollModeModifier(enemyId)
    local modifier = 0

    if character.hasFeat(FEATS.ETERNAL_SACRIFICE) then
        modifier = modifier + 1
    end

    if hasAdvantageAgainstEnemy(enemyId) then
        modifier = modifier + 1
    end

    return modifier
end

-- Feat: Adrenaline

local function hasAdrenalineProc(attackIndex, threshold, attackValue)
    return attackIndex == 1 and attackValue >= threshold + 6
end

-- Feat: Vengeance

local function hasVengeanceProc(roll)
    return roll >= 16
end

-- Rolling

local function shouldShowPreRollUI()
    return character.hasTrait(TRAITS.VESEERAS_IRE) or rules.playerTurn.shouldShowPreRollUI() or rules.other.shouldShowPreRollUI()
end

rules.offence = {
    isCrit = isCrit,
    calculateAttackValue = calculateAttackValue,
    isSuccessful = isSuccessful,

    getRollModeModifier = getRollModeModifier,

    hasAdrenalineProc = hasAdrenalineProc,
    hasVengeanceProc = hasVengeanceProc,

    shouldShowPreRollUI = shouldShowPreRollUI,
}
