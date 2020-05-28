local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local WEAKNESSES = weaknesses.WEAKNESSES

local MAX_ROLL = 20

local function getCritReq()
    local critReq = MAX_ROLL
    if character.hasFeat(FEATS.KEEN_SENSE) then
        critReq = critReq - 1
    end
    return critReq
end

local function getMaxFatePoints()
    return character.hasWeakness(WEAKNESSES.FATELESS) and 0 or 1
end

local function calculateOffenceStat(offence, buff)
    return offence + buff
end

local function calculateDefenceStat(defence, buff)
    return defence + buff
end

local function calculateSpiritStat(spirit, buff)
    return spirit + buff
end

ns.rules.rolls = {
    MAX_ROLL = MAX_ROLL,
    getCritReq = getCritReq,
    getMaxFatePoints = getMaxFatePoints,
}

-- For use by other rule modules
ns.rules.common = {
    calculateOffenceStat = calculateOffenceStat,
    calculateDefenceStat = calculateDefenceStat,
    calculateSpiritStat = calculateSpiritStat,
}