local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules

local FEATS = feats.FEATS

local function calculateDamageDone(outgoingDamage)
    if character.hasFeat(FEATS.VANGUARD) then
        outgoingDamage = rules.feats.applyVanguardDamageDoneBonus(outgoingDamage)
    end

    return outgoingDamage
end

rules.damageDone = {
    calculateDamageDone = calculateDamageDone,
}