local _, ns = ...

local character = ns.character
local enemies = ns.resources.enemies
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local ENEMIES = enemies.ENEMIES
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local MAX_NUM_TRAITS = 3
local HOLY_BULWARK_ENEMIES = {
    [ENEMIES.DEMON.id] = true,
    [ENEMIES.ELDRITCH.id] = true,
    [ENEMIES.UNDEAD.id] = true,
    [ENEMIES.VOID.id] = true,
}
local LIFE_WITHIN_HEAL_AMOUNT = 10
local SECOND_WIND_HEAL_AMOUNT = 15
local SHATTER_SOUL_HEAL_AMOUNT = 6

local function calculateMaxTraits()
    local maxTraits = 1

    if character.getNumWeaknesses() > 0 then
        maxTraits = maxTraits + 1
    end

    if character.hasFeat(FEATS.EXPANSIVE_ARSENAL) then
        maxTraits = maxTraits + 1
    end

    return maxTraits
end

local function getMaxTraitCharges(trait)
    local numCharges = trait.numCharges

    if trait.id == TRAITS.VINDICATION.id and character.hasFeat(FEATS.DIVINE_PURPOSE) then
        numCharges = 4
    end

    if character.hasWeakness(WEAKNESSES.BRIGHT_BURNER) then
        numCharges = numCharges - 1
    end

    return numCharges
end

local function calculateRegrowthHealingPerTick(initialHealAmount)
    return ceil(initialHealAmount / 2)
end

local function canUseHolyBulwark(enemyId)
    return character.hasTrait(TRAITS.HOLY_BULWARK) and HOLY_BULWARK_ENEMIES[enemyId]
end

local function calculateShieldSlamDmg(baseDmgBuff, defence, defenceBuff)
    local baseDmg = rules.offence.getBaseDamageAfterBuffs(baseDmgBuff)
    local defenceStat = rules.common.calculateDefenceStat(nil, defence, defenceBuff)

    return baseDmg + max(0, defenceStat)
end

rules.traits = {
    MAX_NUM_TRAITS = MAX_NUM_TRAITS,
    LIFE_WITHIN_HEAL_AMOUNT = LIFE_WITHIN_HEAL_AMOUNT,
    SECOND_WIND_HEAL_AMOUNT = SECOND_WIND_HEAL_AMOUNT,
    SHATTER_SOUL_HEAL_AMOUNT = SHATTER_SOUL_HEAL_AMOUNT,

    calculateMaxTraits = calculateMaxTraits,
    getMaxTraitCharges = getMaxTraitCharges,

    calculateRegrowthHealingPerTick = calculateRegrowthHealingPerTick,
    canUseHolyBulwark = canUseHolyBulwark,
    calculateShieldSlamDmg = calculateShieldSlamDmg,
}