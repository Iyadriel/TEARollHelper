local _, ns = ...

local character = ns.character
local rules = ns.rules
local ui = ns.ui

local utilityTypes = ns.resources.utilityTypes

local UTILITY_TYPE_OPTIONS = (function()
    local options = {}

    for i = 1, #utilityTypes.UTILITY_TYPE_KEYS do
        local key = utilityTypes.UTILITY_TYPE_KEYS[i]
        local utilityType = utilityTypes.UTILITY_TYPES[key]

        options[key] = utilityType.name
    end

    return options
end)()

-- Update turn UI, in case it is also open
local function updateTurnUI()
    ui.update(ui.modules.turn.name)
end

--[[ local options = {
    order: Number,
    slotIndex: Number,
} ]]
ui.modules.config.modules.character.modules.utilityTraits.getOptions = function(options)
    local slotIndex = options.slotIndex

    local function shouldHide()
        local maxTraits = rules.utility.getNumAllowedUtilityTraits()
        return slotIndex > maxTraits
    end

    return {
        trait = {
            order = options.order,
            type = "input",
            name = function()
                return "Utility trait " .. slotIndex
            end,
            width = 1.1,
            desc = "Enter the name of your utility trait.",
            hidden = shouldHide,
            get = function()
                return character.getUtilityTraitAtSlot(slotIndex).name
            end,
            set = function(info, name)
                character.setUtilityTraitNameAtSlot(slotIndex, name)
                updateTurnUI()
            end,
        },
        utilityType = {
            order = options.order + 1,
            type = "select",
            name = "Type",
            width = 1.2,
            hidden = shouldHide,
            values = UTILITY_TYPE_OPTIONS,
            get = function()
                return character.getUtilityTraitAtSlot(slotIndex).utilityType
            end,
            set = function(info, name)
                character.setUtilityTraitTypeAtSlot(slotIndex, name)
                updateTurnUI()
            end,
        }
    }
end