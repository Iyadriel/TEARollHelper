local _, ns = ...

local rules = ns.rules

local function calculateOffenceStat(offence, buff)
    return offence + buff
end

local function calculateDefenceStat(defence, buff)
    return defence + buff
end

local function calculateSpiritStat(spirit, buff)
    return spirit + buff
end

-- For use by other rule modules
rules.common = {
    calculateOffenceStat = calculateOffenceStat,
    calculateDefenceStat = calculateDefenceStat,
    calculateSpiritStat = calculateSpiritStat,
}