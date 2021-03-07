local _, ns = ...

local buffsState = ns.state.buffs.state
local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local ui = ns.ui

local COLOURS = TEARollHelper.COLOURS
local STAT_LABELS = constants.STAT_LABELS
local STAT_MAX_VALUE = rules.stats.STAT_MAX_VALUE
local state = characterState.state

local function traitColour(trait)
    return COLOURS.TRAITS[trait.id] or COLOURS.TRAITS.GENERIC
end

local function traitDescription(trait)
    if trait and trait.desc then
        local text = trait.desc

        if trait.requiredStats then
            text = text .. COLOURS.NOTE .. " (Requires "
            for _, pair in ipairs(trait.requiredStats) do
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

--[[ local options = {
    order: Number,
    width: Any,
    name: Function?,
    hidden: Function?,
    checkBuff: Boolean,
    func: Function?,
} ]]
local function traitButton(trait, options)
    return {
        order = options.order,
        type = "execute",
        width = options.width,
        name = options.name or traitColour(trait) .. "Use " .. trait.name,
        desc = traitDescription(trait),
        hidden = options.hidden or function()
            return not character.hasTrait(trait) or (options.checkBuff and buffsState.buffLookup.getTraitBuffs(trait))
        end,
        disabled = function()
            return state.featsAndTraits.numTraitCharges.get(trait.id) == 0
        end,
        func = options.func or consequences.useTrait(trait)
    }
end

local function traitActiveText(trait, order)
    return {
        order = order,
        type = "description",
        name = traitColour(trait) .. trait.name .. " is active.",
        hidden = function()
            return not (character.hasTrait(trait) and buffsState.buffLookup.getTraitBuffs(trait))
        end,
    }
end

--[[ local options = {
    order: Number,
    name: Function?,
    actionArgs: Array?,
} ]]
local function traitToggle(actionType, trait, options)
    local getAction = rolls.getActionMethod(actionType)

    local actionArgs = nil
    if options.actionArgs then
        actionArgs =  unpack(options.actionArgs)
    end

    return {
        order = options.order,
        type = "toggle",
        width = "full",
        name = options.name or function()
            return traitColour(trait) .. "Use " .. trait.name
        end,
        desc = traitDescription(trait),
        hidden = function()
            if character.hasTrait(trait) then
                local numCharges = state.featsAndTraits.numTraitCharges.get(trait.id)
                return numCharges <= 0 or not getAction(actionArgs).traits[trait.id].canUse
            end
            return true
        end,
        get = function()
            return rolls.state[actionType].activeTraits.get(trait)
        end,
        set = function()
            rolls.state[actionType].activeTraits.toggle(trait)
        end,
    }
end

ui.helpers.traitDescription = traitDescription
ui.helpers.traitButton = traitButton
ui.helpers.traitActiveText = traitActiveText
ui.helpers.traitToggle = traitToggle