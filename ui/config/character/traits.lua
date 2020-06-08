local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui

-- Update turn UI, in case it is also open
local function updateTurnUI()
    ui.update(ui.modules.turn.name)
end

--[[ local options = {
    order: Number,
    slotIndex: Number,
} ]]
ui.modules.config.modules.character.modules.traits.getOptions = function(options)
    local slotIndex = options.slotIndex

    local function shouldHide()
        local maxTraits = rules.traits.calculateMaxTraits()
        return slotIndex > maxTraits
    end

    return {
        trait = {
            name = function()
                return "Trait " .. slotIndex
            end,
            type = "select",
            desc = "More Traits may be supported in the future.",
            order = options.order,
            values = (function()
                local traitOptions = {}
                for i = 1, #traits.TRAIT_KEYS do
                    local key = traits.TRAIT_KEYS[i]
                    local trait = traits.TRAITS[key]
                    traitOptions[key] = trait.name
                end
                return traitOptions
            end)(),
            hidden = shouldHide,
            get = function()
                return character.getPlayerTraitIDAtSlot(slotIndex)
            end,
            set = function(info, traitID)
                character.setPlayerTraitByID(slotIndex, traitID)
                updateTurnUI()
            end,
        },
        traitDesc = {
            type = "description",
            name = function()
                local trait = character.getPlayerTraitAtSlot(slotIndex)
                return trait and trait.desc
            end,
            fontSize = "medium",
            hidden = shouldHide,
            order = options.order + 1
        },
        traitNote = {
            type = "description",
            name = COLOURS.NOTE .. "",
            hidden = shouldHide,
            order = options.order + 2
        },
    }
end