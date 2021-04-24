local _, ns = ...

local character = ns.character
local constants = ns.constants
local racialTraits = ns.resources.racialTraits
local rules = ns.rules
local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
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

local function calculateCCValue(roll, stat, statBuff)
    return roll + rules.common.calculateGenericStat(stat, statBuff)
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
