local _, ns = ...

local character = ns.character
local weaknesses = ns.resources.weaknesses
local ui = ns.ui

local COLOURS = TEARollHelper.COLOURS

-- Update turn UI, in case it is also open
local function updateTurnUI()
    ui.update(ui.modules.turn.name)
end

--[[ local options = {
    order: Number,
} ]]
ui.modules.config.modules.character.modules.weaknesses.getOptions = function(options)
    return {
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
                    name = weakness.name,
                    desc = function()
                        local msg = weakness.desc
                        if weakness.note then
                            msg = msg .. "|n|n" .. COLOURS.NOTE .. weakness.note
                        end
                        return msg
                    end,
                }
            end
            return weaknessOptions
        end)(),
    }
end