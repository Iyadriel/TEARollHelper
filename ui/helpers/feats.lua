local _, ns = ...

local constants = ns.constants
local rules = ns.rules
local ui = ns.ui

local COLOURS = TEARollHelper.COLOURS
local STAT_LABELS = constants.STAT_LABELS
local STAT_MAX_VALUE = rules.stats.STAT_MAX_VALUE

local function featDescription(feat)
    if feat.desc then
        local text = feat.desc
        if feat.requiredStats then
            text = text .. COLOURS.NOTE .. " (Requires "
            for stat, minValue in pairs(feat.requiredStats) do
                text = text .. minValue .. "/" .. STAT_MAX_VALUE .. " " .. STAT_LABELS[stat] .. ", "
            end

            text = string.sub(text, 0, -3) .. ")|r"
        end
        return text
    end
    return ""
end

ui.helpers.featDescription = featDescription