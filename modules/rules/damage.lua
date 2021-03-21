local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local NUM_OFFENCE_PER_BLOOD_HARVEST_SLOT = 2

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
    return max(0, getBaseDamage() + baseDmgBuff)
end

local function calculateDamageValue(roll)
    return roll
end

local function calculateAttackDmg(damageValue, baseDmgBuff, damageDoneBuff)
    local damage = getBaseDamageAfterBuffs(baseDmgBuff) + damageValue + damageDoneBuff

    if character.hasWeakness(WEAKNESSES.GLASS_CANNON) then
        damage = damage + 2
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

local function calculateEffectiveOutgoingDamage(outgoingDamage)
    if character.hasFeat(FEATS.VANGUARD) then
        outgoingDamage = rules.feats.applyVanguardDamageDoneBonus(outgoingDamage)
    end

    return outgoingDamage
end

-- Feat: Blood Harvest

local function getMaxBloodHarvestSlots()
    local offence = character.getPlayerOffence()
    local numSlots = max(0, floor(offence / NUM_OFFENCE_PER_BLOOD_HARVEST_SLOT))

    return numSlots
end

local function calculateBloodHarvestBonus(numBloodHarvestSlots)
    return numBloodHarvestSlots * 5
end

-- Feat: Onslaught

local function calculateOnslaughtDamage(baseDmgBuff, damageDoneBuff)
    local baseDamage = getBaseDamageAfterBuffs(baseDmgBuff)
    return baseDamage + damageDoneBuff
end

-- Feat: Mercy from Pain

local function hasMercyFromPainProc(dmgDealt)
    return dmgDealt >= 5
end

local function calculateMercyFromPainBonusHealing(attackIsAOE)
    return attackIsAOE and 4 or 2
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

rules.damage = {
    getBaseDamageBonus = getBaseDamageBonus,
    getBaseDamageAfterBuffs = getBaseDamageAfterBuffs,
    calculateDamageValue = calculateDamageValue,
    calculateAttackDmg = calculateAttackDmg,
    applyCritModifier = applyCritModifier,

    calculateEffectiveOutgoingDamage = calculateEffectiveOutgoingDamage,

    getMaxBloodHarvestSlots = getMaxBloodHarvestSlots,
    calculateBloodHarvestBonus = calculateBloodHarvestBonus,
    calculateOnslaughtDamage =  calculateOnslaughtDamage,
    hasMercyFromPainProc = hasMercyFromPainProc,
    calculateMercyFromPainBonusHealing = calculateMercyFromPainBonusHealing,

    canProcVindication = canProcVindication,
    hasVindicationProc = hasVindicationProc,
    calculateVindicationHealing = calculateVindicationHealing,
}