local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local rules = ns.rules
local settings = ns.settings
local traits = ns.resources.traits
local ui = ns.ui

-- Update turn UI, in case it is also open
local function updateTurnUI()
    ui.update(ui.modules.turn.name)
end

local BASE_TRAITS = (function()
    local traitOptions = {}

    for i = 1, #traits.TRAIT_KEYS do
        local key = traits.TRAIT_KEYS[i]
        local trait = traits.TRAITS[key]

        if not trait.isCustom then
            traitOptions[key] = trait.name
        end
    end

    return traitOptions
end)()

local ALL_TRAITS = (function()
    local traitOptions = {}

    for i = 1, #traits.TRAIT_KEYS do
        local key = traits.TRAIT_KEYS[i]
        local trait = traits.TRAITS[key]

        local name = trait.name

        if trait.isCustom then
            name = name.. " (|c" .. RAID_CLASS_COLORS[trait.playerClass].colorStr .. trait.playerName .. "|r)"
        end

        traitOptions[key] = name
    end

    return traitOptions
end)()

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
            values = function()
                if settings.showCustomFeatsTraits.get() then
                    return ALL_TRAITS
                end
                return BASE_TRAITS
            end,
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
            name = function()
                local trait = character.getPlayerTraitAtSlot(slotIndex)
                return COLOURS.NOTE .. (trait and (trait.note and trait.note .. "|n ") or "")
            end,
            hidden = shouldHide,
            order = options.order + 2
        },
    }
end