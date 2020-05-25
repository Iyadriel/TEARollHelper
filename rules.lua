local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local MAX_ROLL = 20

local function isCrit(roll)
    local critReq = MAX_ROLL
    if character.hasFeat(FEATS.KEEN_SENSE) then
        critReq = critReq - 1
    end
    if character.hasRacialTrait(RACIAL_TRAITS.VICIOUSNESS) then
        critReq = critReq - 1
    end
    return roll >= critReq
end

local function getMaxFatePoints()
    return character.hasWeakness(WEAKNESSES.FATELESS) and 0 or 1
end

local function calculateOffenceStat(offence, buff)
    return offence + buff
end

local function calculateDefenceStat(defence, buff, racialTrait)
    local stat = defence + buff
    if racialTraits.equals(racialTrait, RACIAL_TRAITS.QUICKNESS) then
        stat = stat + 2
    end
    return stat
end

local function calculateSpiritStat(spirit, buff)
    return spirit + buff
end

ns.rules.rolls = {
    MAX_ROLL = MAX_ROLL,
    isCrit = isCrit,
    getMaxFatePoints = getMaxFatePoints,
}

-- For use by other rule modules
ns.rules.common = {
    calculateOffenceStat = calculateOffenceStat,
    calculateDefenceStat = calculateDefenceStat,
    calculateSpiritStat = calculateSpiritStat,
}