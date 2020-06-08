local _, ns = ...

local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local ACTIONS = constants.ACTIONS
local FEATS = feats.FEATS
local WEAKNESSES = weaknesses.WEAKNESSES

local MIN_ROLL = 1
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

local function getRollModeModifier(action, advantageBuff, disadvantageDebuff, enemyId)
    local modifier = 0

    if advantageBuff then
        modifier = modifier + 1
    end
    if disadvantageDebuff then
        modifier = modifier - 1
    end

    if action == ACTIONS.attack then
        modifier = modifier + rules.offence.getRollModeModifier(enemyId)
    end

    return modifier
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

rules.rolls = {
    MIN_ROLL = MIN_ROLL,
    MAX_ROLL = MAX_ROLL,
    getCritReq = getCritReq,
    getMaxFatePoints = getMaxFatePoints,
    getRollModeModifier = getRollModeModifier,
}

-- For use by other rule modules
rules.common = {
    calculateOffenceStat = calculateOffenceStat,
    calculateDefenceStat = calculateDefenceStat,
    calculateSpiritStat = calculateSpiritStat,
}