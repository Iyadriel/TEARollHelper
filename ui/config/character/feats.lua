local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local feats = ns.resources.feats
local players = ns.resources.players
local rules = ns.rules
local settings = ns.settings
local ui = ns.ui
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local FEAT_KEYS = feats.FEAT_KEYS
local PLAYERS = players.PLAYERS
local WEAKNESSES = weaknesses.WEAKNESSES

-- Update turn UI, in case it is also open
local function updateTurnUI()
    ui.update(ui.modules.turn.name)
end

local BASE_FEATS = (function()
    local featOptions = {}

    for i = 1, #FEAT_KEYS do
        local key = FEAT_KEYS[i]
        local feat = FEATS[key]
        if not feat.isCustom then
            featOptions[key] = feat.name
        end
    end
    return featOptions
end)()

local ALL_FEATS = (function()
    local featOptions = {}

    for i = 1, #FEAT_KEYS do
        local key = FEAT_KEYS[i]
        local feat = FEATS[key]

        local name = feat.name

        if feat.isCustom then
            local player = PLAYERS[feat.player]
            name = name.. " (|c" .. player.colour .. player.name .. "|r)"
        end

        featOptions[key] = name
    end
    return featOptions
end)()

--[[ local options = {
    order: Number,
} ]]
ui.modules.config.modules.character.modules.feats.getOptions = function(options)
    return {
        feats = {
            order = options.order,
            name = "Feat",
            type = "select",
            desc = "More Feats may be supported in the future.",
            disabled = function()
                return not rules.other.canUseFeats()
            end,
            values = function()
                if settings.showCustomFeatsTraits.get() then
                    return ALL_FEATS
                end
                return BASE_FEATS
            end,
            get = function()
                local feat = character.getPlayerFeat()
                return feat and feat.id
            end,
            set = function(info, value)
                character.setPlayerFeatByID(value)
                updateTurnUI()
            end
        },
        temperedBenevolenceWarning = {
            order = options.order + 1,
            type = "description",
            name = COLOURS.ERROR .. "This Feat is not compatible with your " .. WEAKNESSES.TEMPERED_BENEVOLENCE.name .. " weakness.",
            hidden = function()
                return not (character.hasFeat(FEATS.PARAGON) and character.hasWeakness(WEAKNESSES.TEMPERED_BENEVOLENCE))
            end,
        },
        featDesc = {
            order = options.order + 2,
            type = "description",
            name = function()
                local feat = character.getPlayerFeat()
                return feat and feat.desc or ""
            end,
            fontSize = "medium",
        },
        featNote = {
            order = options.order + 3,
            type = "description",
            name = function()
                local feat = character.getPlayerFeat()
                return COLOURS.NOTE .. (feat and (feat.note and feat.note .. "|n ") or "")
            end,
        },
    }
end