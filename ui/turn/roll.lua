local _, ns = ...

local buffsState = ns.state.buffs
local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local rollHandler = ns.rollHandler
local rollState = ns.state.rolls
local rules = ns.rules
local settings = ns.settings
local turnState = ns.state.turn
local ui = ns.ui

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
    action: String, -- attack, healing, buff, defend, meleeSave, rangedSave, utility
    hidden: Function,
} ]]
ui.modules.turn.modules.roll.getOptions = function(options)
    local function getRollModeModifier()
        local action = options.action
        local turnTypeID = turnState.state.type.get()

        return rollState.getRollModeModifier(action, turnTypeID)
    end

    local function performRoll(isReroll)
        local rollMode = state[options.action].rollMode.get()
        local rollModeMod = getRollModeModifier()

        rollHandler.setAction(options.action)
        rollHandler.roll(rollMode, rollModeMod, isReroll)
    end

    return {
        type = "group",
        name = "Roll",
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
                    return not character.hasTrait(trait) or characterState.state.featsAndTraits.numTraitCharges.get(trait.id) <= 0
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
                    local rollModeMod = getRollModeModifier()
                    if rollModeMod == ROLL_MODES.ADVANTAGE then
                        return "Roll mode" .. COLOURS.BUFF .. " (Advantage)"
                    elseif rollModeMod == ROLL_MODES.DISADVANTAGE then
                        return "Roll mode" .. COLOURS.DEBUFF .. " (Disadvantage)"
                    end
                    return "Roll mode"
                end,
                desc =  function()
                    local msg = "Select the roll mode requested by the DM."
                    local rollModeMod = getRollModeModifier()
                    if rollModeMod == ROLL_MODES.ADVANTAGE then
                        msg = msg .. "|n|nYou have advantage! This is already taken into account. You do not need to change your roll mode here."
                    elseif rollModeMod == ROLL_MODES.DISADVANTAGE then
                        msg = msg .. "|n|nYou have disadvantage. This is already taken into account. You do not need to change your roll mode here."
                    end
                    return msg
                end,
                width = 0.75,
                values = function()
                    local rollModeMod = getRollModeModifier()
                    if rollModeMod == ROLL_MODES.ADVANTAGE then
                        return ROLL_MODE_VALUES_ADVANTAGE
                    elseif rollModeMod == ROLL_MODES.DISADVANTAGE then
                        return ROLL_MODE_VALUES_DISADVANTAGE
                    end
                    return ROLL_MODE_VALUES_NORMAL
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
                desc = "Do a /roll " .. rules.rolls.MAX_ROLL .. ".",
                width = 1.3,
                disabled = function()
                    return rollHandler.isRolling()
                end,
                func = function()
                    performRoll()
                end,
            },
            roll = {
                order = 3,
                name = "Roll result",
                type = "range",
                desc = "The number you rolled",
                min = 1,
                max = rules.rolls.MAX_ROLL,
                step = 1,
                get = function()
                    return state[options.action].currentRoll.get()
                end,
                set = function(info, value)
                    rollHandler.setAction(options.action)
                    rollHandler.setCurrentRoll(value)
                end
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
                        local roll = state[options.action].currentRoll.get()

                        if not roll then return true end

                        local action = options.action
                        local attack, cc, healing, buff, defence, meleeSave, rangedSave

                        if action == ACTIONS.attack then
                            attack = rollState.getAttack()
                        elseif action == ACTIONS.cc then
                            cc = rollState.getCC()
                        elseif action == ACTIONS.healing then
                            healing = rollState.getHealing(not turnState.state.inCombat.get())
                        elseif action == ACTIONS.buff then
                            buff = rollState.getBuff()
                        elseif action == ACTIONS.defend then
                            defence = rollState.getDefence()
                        elseif action == ACTIONS.meleeSave then
                            meleeSave = rollState.getMeleeSave()
                        elseif action == ACTIONS.rangedSave then
                            rangedSave = rollState.getRangedSave()
                        end

                        hidden = not rules.rolls.shouldSuggestFatePoint(roll, attack, cc, healing, buff, defence, meleeSave, rangedSave)
                    end

                    return hidden
                end,
                func = function()
                    performRoll(true)
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