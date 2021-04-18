local _, ns = ...

local buffsState = ns.state.buffs
local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local rollHandler = ns.rollHandler
local rolls = ns.rolls
local rollState = ns.state.rolls
local rules = ns.rules
local settings = ns.settings
local turnState = ns.state.turn
local ui = ns.ui
local utils = ns.utils

local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local ACTIONS = constants.ACTIONS
local COLOURS = TEARollHelper.COLOURS
local ROLL_MODES = constants.ROLL_MODES
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local state = rollState.state

local VALUE_DISADVANTAGE = ui.iconString("Interface\\Icons\\petbattle_speed-down") .. "Disadvantage"
local VALUE_ADVANTAGE = ui.iconString("Interface\\Icons\\petbattle_speed") .. "Advantage"

local ROLL_MODE_VALUES_NORMAL = {
    [ROLL_MODES.DISADVANTAGE] = VALUE_DISADVANTAGE,
    [ROLL_MODES.NORMAL] = "Normal",
    [ROLL_MODES.ADVANTAGE] = VALUE_ADVANTAGE
}

local ROLL_MODE_VALUES_ADVANTAGE = {
    [ROLL_MODES.DISADVANTAGE] = VALUE_DISADVANTAGE .. "+",
    [ROLL_MODES.NORMAL] = "Normal+",
    [ROLL_MODES.ADVANTAGE] = VALUE_ADVANTAGE
}

local ROLL_MODE_VALUES_DISADVANTAGE = {
    [ROLL_MODES.DISADVANTAGE] = VALUE_DISADVANTAGE,
    [ROLL_MODES.NORMAL] = "Normal-",
    [ROLL_MODES.ADVANTAGE] = VALUE_ADVANTAGE .. "-"
}

--[[ local options = {
    order: Number,
    hidden: Function,
    args: Table,
} ]]
ui.modules.turn.modules.roll.getPreRollOptions = function(options)
    return {
        order = options.order,
        type = "group",
        name = "Before rolling",
        inline = true,
        hidden = options.hidden,
        args = options.args,
    }
end

--[[ local options = {
    order: Number,
    action: String, -- attack, damage, healing, buff, defend, meleeSave, rangedSave, utility
    name: String = "Roll",
    hideMomentOfExcellence: Boolean = false,
    hidden: Function,
} ]]
ui.modules.turn.modules.roll.getOptions = function(options)
    local maxRoll = rules.rolls.getMaxRoll(options.action)

    return {
        type = "group",
        name = options.name or "Roll",
        inline = true,
        order = options.order,
        hidden = options.hidden or false,
        args = {
            momentOfExcellence = {
                order = 0,
                type = "execute",
                width = "full",
                name = COLOURS.TRAITS.MOMENT_OF_EXCELLENCE .. ui.iconString("Interface\\Buttons\\UI-GroupLoot-Dice-Up", "small", false) .. "Moment of Excellence",
                hidden = function()
                    local trait = TRAITS.MOMENT_OF_EXCELLENCE
                    return options.hideMomentOfExcellence or not character.hasTrait(trait) or characterState.state.featsAndTraits.numTraitCharges.get(trait.id) <= 0
                end,
                func = function()
                    rollHandler.setAction(options.action)
                    rollHandler.doMomentOfExcellence()
                    consequences.useTraitCharge(TRAITS.MOMENT_OF_EXCELLENCE)
                end,
            },
            rollMode = {
                order = 1,
                type = "select",
                name =  function()
                    local rollModeMod = rolls.getRollModeModifier(options.action)
                    if rollModeMod == ROLL_MODES.ADVANTAGE then
                        return "Roll mode" .. COLOURS.BUFF .. " (Advantage)"
                    elseif rollModeMod == ROLL_MODES.DISADVANTAGE then
                        return "Roll mode" .. COLOURS.DEBUFF .. " (Disadvantage)"
                    end
                    return "Roll mode"
                end,
                desc =  function()
                    local msg = "Select the roll mode requested by the DM."
                    local rollModeMod = rolls.getRollModeModifier(options.action)
                    if rollModeMod == ROLL_MODES.ADVANTAGE then
                        msg = msg .. "|n|nYou have advantage! This is already taken into account. You do not need to change your roll mode here."
                    elseif rollModeMod == ROLL_MODES.DISADVANTAGE then
                        msg = msg .. "|n|nYou have disadvantage. This is already taken into account. You do not need to change your roll mode here."
                    end
                    return msg
                end,
                width = 0.75,
                values = function()
                    local rollModeMod = rolls.getRollModeModifier(options.action)
                    local values

                    if rollModeMod == ROLL_MODES.ADVANTAGE then
                        values = ROLL_MODE_VALUES_ADVANTAGE
                    elseif rollModeMod == ROLL_MODES.DISADVANTAGE then
                        values = ROLL_MODE_VALUES_DISADVANTAGE
                    end
                    values = ROLL_MODE_VALUES_NORMAL

                    if not rules.rolls.canHaveAdvantage() then
                        values = utils.shallowCopy(values)
                        values[ROLL_MODES.ADVANTAGE] = nil
                    end

                    return values
                end,
                get = state[options.action].rollMode.get,
                set = function(info, value)
                    state[options.action].rollMode.set(value)
                end
            },
            performRoll = {
                order = 2,
                type = "execute",
                name = function()
                    return rollHandler.isRolling() and "Rolling..." or ui.iconString("Interface\\Buttons\\UI-GroupLoot-Dice-Up", "small", false) .. "Roll"
                end,
                desc = "Do a /roll " .. maxRoll .. ".",
                width = 1.2,
                disabled = function()
                    return rollHandler.isRolling()
                end,
                func = function()
                    rolls.performRoll(options.action)
                end,
            },
            ["roll_result_" .. options.action]  = {
                order = 3,
                name = "Roll result",
                type = "range",
                desc = "The number you rolled",
                min = rolls.getMinRoll(options.action),
                max = maxRoll,
                step = 1,
                get = function()
                    return state[options.action].currentRoll.get()
                end,
                set = function(info, value)
                    rollHandler.setAction(options.action)
                    rollHandler.setCurrentRoll(value)
                end,
                dialogControl = TEARollHelper:CreateCustomSlider("roll_result_" .. options.action, {
                    min = function()
                        return rolls.getMinRoll(options.action)
                    end,
                })
            },
            useFatePoint = {
                order = 4,
                type = "execute",
                name = "Use Fate Point",
                desc = "Uses a Fate Point and rolls again, picking the highest result.",
                width = "full",
                hidden = function()
                    local hidden = true

                    if settings.suggestFatePoints.get() and characterState.state.numFatePoints.get() > 0 then
                        local action = options.action
                        local roll = state[action].currentRoll.get()

                        if not roll then return true end

                        local actionMethod = rollState.getActionMethod(action)

                        if action == ACTIONS.healing then
                            actionMethod = function()
                                return rollState.getHealing(not turnState.state.inCombat.get())
                            end
                        end

                        hidden = not rules.rolls.shouldSuggestFatePoint(roll, action, actionMethod())
                    end

                    return hidden
                end,
                func = function()
                    rolls.performFateRoll(options.action)
                    consequences.useFatePoint()
                end,
            },
            rebound = {
                order = 5,
                type = "execute",
                name = COLOURS.DAMAGE .. "Confirm " .. WEAKNESSES.REBOUND.name,
                desc = WEAKNESSES.REBOUND.desc,
                width = "full",
                hidden = function()
                    if rules.rolls.canProcRebound() then
                        local roll = state[options.action].currentRoll.get()
                        local turnTypeID = turnState.state.type.get()

                        return not (rules.rolls.hasReboundProc(roll, turnTypeID) and not buffsState.state.buffLookup.getWeaknessDebuff(WEAKNESSES.REBOUND))
                    end
                    return true
                end,
                func = consequences.confirmReboundRoll,
            },
        }
    }
end
