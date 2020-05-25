local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits

local FEATS = feats.FEATS

local MAX_NUM_TRAITS = 3
local SECOND_WIND_HEAL_AMOUNT = 15

local function calculateMaxTraits()
    local maxTraits = 1
    local numWeaknesses = character.getNumWeaknesses()

    if numWeaknesses > 0 then
        maxTraits = maxTraits + 1

        if numWeaknesses > 1 and character.hasFeat(FEATS.EXPANSIVE_ARSENAL) then
            maxTraits = maxTraits + 1
        end
    end

    return maxTraits
end

rules.traits = {
    MAX_NUM_TRAITS = MAX_NUM_TRAITS,
    SECOND_WIND_HEAL_AMOUNT = SECOND_WIND_HEAL_AMOUNT,
    calculateMaxTraits = calculateMaxTraits,
}