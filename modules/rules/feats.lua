local _, ns = ...

local character = ns.character
local constants = ns.constants
local rules = ns.rules

local STATS = constants.STATS

local ETERNAL_SACRIFICE_HEAL_AMOUNT = 4

local function canProc(feat)
    return character.hasFeat(feat);
end

local function getStatForAvengingGuardian()
    if character.getPlayerDefence() >= character.getPlayerSpirit() then
        return STATS.defence
    end
    return STATS.spirit
end

local function calculateAvengingGuardianBonusDmg()
    return ceil(max(character.getPlayerDefence(), character.getPlayerSpirit()) / 2)
end

local function halfOfOffenceRoundedDown()
    return max(0, floor(character.getPlayerOffence() / 2))
end

local function applyVanguardDamageDoneBonus(outgoingDamage)
    return outgoingDamage +  max(0, floor(character.getPlayerDefence() / 2))
end

local function applyVanguardDamageReduction(dmg)
    return dmg - halfOfOffenceRoundedDown()
end

local function applyVanguardHealingReceivedBonus(incomingHealAmount)
    return incomingHealAmount + halfOfOffenceRoundedDown()
end


rules.feats = {
    ETERNAL_SACRIFICE_HEAL_AMOUNT = ETERNAL_SACRIFICE_HEAL_AMOUNT,

    canProc = canProc,

    getStatForAvengingGuardian = getStatForAvengingGuardian,
    calculateAvengingGuardianBonusDmg = calculateAvengingGuardianBonusDmg,

    applyVanguardDamageDoneBonus = applyVanguardDamageDoneBonus,
    applyVanguardDamageReduction = applyVanguardDamageReduction,
    applyVanguardHealingReceivedBonus = applyVanguardHealingReceivedBonus,
}
