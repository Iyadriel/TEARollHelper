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
            for _, pair in ipairs(feat.requiredStats) do
                for stat, minValue in pairs(pair) do
                    text = text .. minValue .. "/" .. STAT_MAX_VALUE .. " " .. STAT_LABELS[stat] .. " and "
                end
                text = string.sub(text, 0, -6) .. " or "
            end

            text = string.sub(text, 0, -5) .. ")|r"
        end
        return text
    end
    return ""
end

ui.helpers.featDescription = featDescription