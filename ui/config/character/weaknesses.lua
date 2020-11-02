local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local settings = ns.settings
local ui = ns.ui
local utils = ns.utils

local players = ns.resources.players
local weaknesses = ns.resources.weaknesses

local PLAYERS = players.PLAYERS

-- Update turn UI, in case it is also open
local function updateTurnUI()
    ui.update(ui.modules.turn.name)
end

local function getWeaknessName(weakness)
    local name = weakness.name
    if weakness.isCustom then
        local player = PLAYERS[weakness.player]
        name = name.. " (" .. utils.playerColor(player.name) .. ")"
    end
    return name
end

--[[ local options = {
    order: Number,
} ]]
ui.modules.config.modules.character.modules.weaknesses.getOptions = function(options)
    return {
        weaknesses = {
            order = options.order,
            type = "group",
            name = "Weaknesses",
            inline = true,
            get = function(info)
                local weaknessID = info[#info]
                return character.hasWeaknessByID(weaknessID)
            end,
            set = function(info, value)
                local weaknessID = info[#info]
                character.togglePlayerWeaknessByID(weaknessID, value)
                updateTurnUI()
            end,
            args = (function()
                local weaknessOptions = {}

                for i = 1, #weaknesses.WEAKNESS_KEYS do
                    local key = weaknesses.WEAKNESS_KEYS[i]
                    local weakness = weaknesses.WEAKNESSES[key]

                    weaknessOptions[key] = {
                        order = i,
                        type = "toggle",
                        name = function()
                            return getWeaknessName(weakness)
                        end,
                        hidden = function()
                            return weakness.isCustom and not settings.showCustomFeatsTraits.get()
                        end,
                        desc = (function()
                            local msg = weakness.desc
                            if weakness.note then
                                msg = msg .. "|n|n" .. COLOURS.NOTE .. weakness.note
                            end
                            return msg
                        end)(),
                    }
                end

                return weaknessOptions
            end)(),
        },
        numWeaknesses = {
            order = options.order + 1,
            type = "range",
            name = "Weaknesses",
            min = 0,
            max = 2,
            step = 1,
            get = character.getNumWeaknesses,
            set = function(info, value)
                character.setNumWeaknesses(value)
            end,
        },
        weaknessNote = {
            order = options.order + 2,
            type = "description",
            name = COLOURS.NOTE .. "Not all weaknesses are currently supported, but the amount of weaknesses you have affects how many traits you can have.|n ",
        },
    }
end