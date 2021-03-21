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

-- Core

local function getBaseDamageBonus()
    if character.hasOffenceProficiency() then
        if character.hasFeat(FEATS.CYCLES_OF_LIFE_AND_DEATH) then
            return 1
        elseif character.hasFeat(FEATS.MASTER) then
            return 4
        end

        return 2
    end

    return 0
end

local function getBaseDamage()
    return 1 + getBaseDamageBonus()
end

local function getBaseDamageAfterBuffs(baseDmgBuff)
    return getBaseDamage() + baseDmgBuff
end

local function calculateAttackValue(roll, offence, buff)
    return roll + rules.common.calculateOffenceStat(offence, buff)
end

local function calculateAttackDmg(threshold, attackValue, baseDmgBuff, damageDoneBuff)
    local overkill = attackValue - threshold
    local damage = 0

    if overkill >= 0 then
        local baseDamage = getBaseDamageAfterBuffs(baseDmgBuff)
        damage = baseDamage + floor(overkill / 2) + damageDoneBuff

        if character.hasWeakness(WEAKNESSES.GLASS_CANNON) then
            damage = damage + 2
        end
    elseif character.hasFeat(FEATS.ONSLAUGHT) then
        local baseDamage = getBaseDamageAfterBuffs(baseDmgBuff)
        damage = baseDamage + damageDoneBuff
    end

    return damage
end

local function applyCritModifier(dmg)
    dmg = dmg * 2

    if character.hasRacialTrait(RACIAL_TRAITS.MIGHT_OF_THE_MOUNTAIN) then
        dmg = dmg + 4
    end

    return dmg
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

-- Feat: Blood Harvest

local function canUseBloodHarvest()
    return character.hasFeat(FEATS.BLOOD_HARVEST)
end

local function getMaxBloodHarvestSlots()
    local offence = character.getPlayerOffence()
    local numSlots = max(0, floor(offence / NUM_OFFENCE_PER_BLOOD_HARVEST_SLOT))

    return numSlots
end

local function calculateBloodHarvestBonus(numBloodHarvestSlots)
    return numBloodHarvestSlots * 5
end

-- Feat: Mercy from Pain

local function hasMercyFromPainProc(dmgDealt)
    return dmgDealt >= 5
end

local function calculateMercyFromPainBonusHealing(attackIsAOE)
    return attackIsAOE and 4 or 2
end

-- Feat: Vengeance

local function hasVengeanceProc(roll)
    return roll >= 16
end

-- Trait: Shatter Soul

local function canUseShatterSoul()
    return character.hasTrait(TRAITS.SHATTER_SOUL)
end

local function shatterSoulEnabled(dmgDealt, enemyId)
    return dmgDealt > 0 and enemyId ~= ENEMIES.MECHANICAL.id
end

-- Trait: Vindication

local function canProcVindication()
    return character.hasTrait(TRAITS.VINDICATION)
end

local function hasVindicationProc(dmgDealt)
    return dmgDealt > 0
end

local function calculateVindicationHealing(dmgDealt)
    return ceil(dmgDealt / 2)
end

-- Rolling

local function shouldShowPreRollUI()
    return character.hasTrait(TRAITS.VESEERAS_IRE) or rules.playerTurn.shouldShowPreRollUI() or rules.other.shouldShowPreRollUI()
end

rules.offence = {
    isCrit = isCrit,

    getBaseDamageBonus = getBaseDamageBonus,
    getBaseDamageAfterBuffs = getBaseDamageAfterBuffs,
    calculateAttackValue = calculateAttackValue,
    calculateAttackDmg = calculateAttackDmg,
    applyCritModifier = applyCritModifier,

    getRollModeModifier = getRollModeModifier,

    hasAdrenalineProc = hasAdrenalineProc,

    canUseBloodHarvest = canUseBloodHarvest,
    getMaxBloodHarvestSlots = getMaxBloodHarvestSlots,
    calculateBloodHarvestBonus = calculateBloodHarvestBonus,

    hasMercyFromPainProc = hasMercyFromPainProc,
    calculateMercyFromPainBonusHealing = calculateMercyFromPainBonusHealing,

    hasVengeanceProc = hasVengeanceProc,

    canUseShatterSoul = canUseShatterSoul,
    shatterSoulEnabled = shatterSoulEnabled,

    canProcVindication = canProcVindication,
    hasVindicationProc = hasVindicationProc,
    calculateVindicationHealing = calculateVindicationHealing,

    shouldShowPreRollUI = shouldShowPreRollUI,
}