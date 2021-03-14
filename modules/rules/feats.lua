local _, ns = ...

local character = ns.character
local rules = ns.rules

local function canProc(feat)
    return character.hasFeat(feat);
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

local function applyVanguardDamageHealingReceivedBonus(incomingHealAmount)
    return incomingHealAmount + halfOfOffenceRoundedDown()
end


rules.feats = {
    canProc = canProc,
    applyVanguardDamageDoneBonus = applyVanguardDamageDoneBonus,
    applyVanguardDamageReduction = applyVanguardDamageReduction,
    applyVanguardDamageHealingReceivedBonus = applyVanguardDamageHealingReceivedBonus,
}