local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local function healingToString(healing)
    local msg = ""

    if healing.amountHealed > 0 then
        local amount = tostring(healing.amountHealed)
        local healColour = (healing.outOfCombat and character.hasFeat(FEATS.MEDIC)) and COLOURS.FEATS.GENERIC or COLOURS.HEALING

        if healing.isCrit then
            msg = msg .. COLOURS.CRITICAL .. "MANY HEALS!|r " .. healColour .. "You heal everyone in line of sight for " .. amount .. " HP."
        else
            if healing.usesParagon then
                local targets = healing.playersHealableWithParagon > 1 and " allies" or " ally"
                msg = msg .. healColour .. "You heal " .. healing.playersHealableWithParagon .. targets .. " for " .. amount .. " HP."
            else
                msg = msg .. healColour .. "You heal for " .. amount .. " HP."
            end
        end
    else
        msg = msg .. COLOURS.NOTE .. "You can't heal anyone with this roll."
    end

    return msg
end

local toString = {
    [ACTIONS.healing] = healingToString,
}

actions.toString = function(actionType, action)
    return toString[actionType](action)
end