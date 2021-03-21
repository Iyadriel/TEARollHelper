local _, ns = ...

local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local rules = ns.rules
local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS

-- Crits

local function isCrit(roll)
    local critReq = rules.rolls.getCritReq(ACTIONS.cc)

    if character.hasRacialTrait(RACIAL_TRAITS.VICIOUSNESS) then
        critReq = critReq - 1
    end

    return roll >= critReq
end

-- Core

local function calculateCCValue(roll, offence, offenceBuff, defence, defenceBuff)
    local stat

    local offenceAfterBuffs = rules.common.calculateOffenceStat(offence, offenceBuff)

    if character.hasFeat(FEATS.SHEPHERD_OF_THE_WICKED) then
        local defenceAfterBuffs = rules.common.calculateDefenceStat(nil, defence, defenceBuff)
        stat = max(offenceAfterBuffs, defenceAfterBuffs)
    else
        stat = offenceAfterBuffs
    end

    return roll + stat
end

-- Rolling

local function shouldShowPreRollUI()
    return character.hasTrait(TRAITS.VESEERAS_IRE) or rules.playerTurn.shouldShowPreRollUI() or rules.other.shouldShowPreRollUI()
end

rules.cc = {
    isCrit = isCrit,
    calculateCCValue = calculateCCValue,
    shouldShowPreRollUI = shouldShowPreRollUI,
}