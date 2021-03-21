local _, ns = ...

local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local ACTIONS = constants.ACTIONS
local CRIT_TYPES = constants.CRIT_TYPES
local FEATS = feats.FEATS
local WEAKNESSES = weaknesses.WEAKNESSES

local function canBuff()
    return not character.hasWeakness(WEAKNESSES.BRUTE)
end

local function usesInspiringPresence()
    return character.hasFeat(FEATS.INSPIRING_PRESENCE)
end

local function calculateSpiritToAddToRoll(spirit)
    if usesInspiringPresence() then
        return ceil(spirit / 2)
    end
    return spirit
end

local function calculateBuffValue(roll, spirit, spiritBuff, offence, offenceBuff)
    local stat
    spirit = rules.common.calculateSpiritStat(spirit, spiritBuff)
    spirit = calculateSpiritToAddToRoll(spirit)

    if character.hasFeat(FEATS.LEADER) then
        local offenceStat = rules.common.calculateOffenceStat(offence, offenceBuff)
        stat = max(spirit, offenceStat)
    else
        stat = spirit
    end

    return roll + stat
end

local function calculateBuffAmount(buffValue)
    return ceil(buffValue / 2)
end

local function isCrit(roll)
    local critReq = rules.rolls.getCritReq(ACTIONS.buff)

    return roll >= critReq
end

local function applyCritModifier(amountBuffed, critType)
    if critType == CRIT_TYPES.VALUE_MOD then
        amountBuffed = amountBuffed * 2
    end

    return amountBuffed
end

-- Feat:  Bulwark of Hope

local function hasBulwarkOfHopeProc(amountBuffed)
    return amountBuffed > 0
end

local function shouldShowPreRollUI()
    return rules.playerTurn.shouldShowPreRollUI() or rules.other.shouldShowPreRollUI()
end

rules.buffing = {
    canBuff = canBuff,
    usesInspiringPresence = usesInspiringPresence,
    calculateBuffValue = calculateBuffValue,
    calculateBuffAmount = calculateBuffAmount,
    isCrit = isCrit,
    applyCritModifier = applyCritModifier,

    hasBulwarkOfHopeProc = hasBulwarkOfHopeProc,

    shouldShowPreRollUI = shouldShowPreRollUI,
}