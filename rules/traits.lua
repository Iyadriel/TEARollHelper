local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits

local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local MAX_NUM_TRAITS = 3
local LIFE_WITHIN_HEAL_AMOUNT = 10
local SECOND_WIND_HEAL_AMOUNT = 15
local SHATTER_SOUL_HEAL_AMOUNT = 6

local function calculateMaxTraits()
    local maxTraits = 1
    local numWeaknesses = character.getNumWeaknesses()

    if numWeaknesses > 0 then
        maxTraits = maxTraits + 1

        if numWeaknesses > 1 and character.hasFeat(FEATS.EXPANSIVE_ARSENAL) then
            maxTraits = maxTraits + 1
        end
    end

    return maxTraits
end

local function getMaxTraitCharges(trait)
    if trait.id == TRAITS.VINDICATION.id and character.hasFeat(FEATS.DIVINE_PURPOSE) then
        return 4
    end
    return trait.numCharges
end

local function calculateStatBuff(trait, stat)
    if trait.id == TRAITS.CALAMITY_GAMBIT.id then
        if stat == "offence" then
            return character.getPlayerOffence() -- double the stat
        else
            return -character.getPlayerOffence() -- reduce defence by regular offence stat
        end
    end
end

local function calculateUtilityBonusBuff(trait)
    if trait.id == TRAITS.ARTISAN.id then
        return rules.utility.calculateBaseUtilityBonus()
    end
end

local function calculateRegrowthHealingPerTick(initialHealAmount)
    return ceil(initialHealAmount / 2)
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
    calculateStatBuff = calculateStatBuff,
    calculateUtilityBonusBuff = calculateUtilityBonusBuff,

    calculateRegrowthHealingPerTick = calculateRegrowthHealingPerTick,
    calculateShieldSlamDmg = calculateShieldSlamDmg,
}