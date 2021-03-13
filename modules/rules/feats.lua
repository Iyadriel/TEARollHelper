local _, ns = ...

local character = ns.character
local rules = ns.rules

local feats = ns.resources.feats

local FEATS = feats.FEATS

local function canProcBulwarkOfHope()
    return character.hasFeat(FEATS.BULWARK_OF_HOPE)
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
    canProcBulwarkOfHope = canProcBulwarkOfHope,
    applyVanguardDamageDoneBonus = applyVanguardDamageDoneBonus,
    applyVanguardDamageReduction = applyVanguardDamageReduction,
    applyVanguardDamageHealingReceivedBonus = applyVanguardDamageHealingReceivedBonus,
}