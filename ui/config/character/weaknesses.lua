local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local character = ns.character
local weaknesses = ns.resources.weaknesses
local ui = ns.ui

-- Update turn UI, in case it is also open
local function notifyChange()
    AceConfigRegistry:NotifyChange(ns.ui.modules.turn.name)
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
            notifyChange()
        end,
        args = (function()
            local options = {}
            for i = 1, #weaknesses.WEAKNESS_KEYS do
                local key = weaknesses.WEAKNESS_KEYS[i]
                local weakness = weaknesses.WEAKNESSES[key]

                options[key] = {
                    order = i,
                    type = "toggle",
                    name = weakness.name,
                    desc = weakness.desc,
                }
            end
            return options
        end)(),
    }
end