local _, ns = ...

local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local environment = ns.state.environment
local rollState = ns.state.rolls
local rules = ns.rules
local settings = ns.settings
local turns = ns.turns
local turnState = ns.state.turn
local ui = ns.ui
local weaknesses = ns.resources.weaknesses

local ACTIONS = constants.ACTIONS
local COLOURS = TEARollHelper.COLOURS
local ROLL_MODES = constants.ROLL_MODES
local WEAKNESSES = weaknesses.WEAKNESSES

local state = rollState.state

local ROLL_MODE_VALUES_NORMAL = {
    [ROLL_MODES.DISADVANTAGE] = "Disadvantage",
    [ROLL_MODES.NORMAL] = "Normal",
    [ROLL_MODES.ADVANTAGE] = "Advantage"
}

local ROLL_MODE_VALUES_ADVANTAGE = {
    [ROLL_MODES.DISADVANTAGE] = "Disadvantage+",
    [ROLL_MODES.NORMAL] = "Normal+",
    [ROLL_MODES.ADVANTAGE] = "Advantage"
}

local ROLL_MODE_VALUES_DISADVANTAGE = {
    [ROLL_MODES.DISADVANTAGE] = "Disadvantage",
    [ROLL_MODES.NORMAL] = "Normal-",
    [ROLL_MODES.ADVANTAGE] = "Advantage-"
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
        local turnTypeId = turnState.state.type.get()

        local buffLookup = characterState.state.buffLookup
        local advantageBuff = buffLookup.getAdvantageBuff(action, turnTypeId)
        local disadvantageDebuff = buffLookup.getDisadvantageDebuff(action, turnTypeId)
        local enemyId = environment.state.enemyId.get()

        local modifier = rules.rolls.getRollModeModifier(action, advantageBuff, disadvantageDebuff, enemyId)
        modifier = max(ROLL_MODES.DISADVANTAGE, min(ROLL_MODES.ADVANTAGE, modifier))
        return modifier
    end

    local function performRoll(isReroll)
        local rollMode
        local rollModeMod

        if isReroll then
            rollMode = ROLL_MODES.NORMAL
            rollModeMod = 0
        else
            rollMode = state[options.action].rollMode.get()
            rollModeMod = getRollModeModifier()
        end

        turns.setAction(options.action)
        turns.roll(rollMode, rollModeMod, isReroll)
    end

    return {
        type = "group",
        name = "Roll",
        inline = true,
        order = options.order,
        hidden = options.hidden or false,
        args = {
            rollMode = {
                order = 0,
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
                type = "select",
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
                order = 1,
                type = "execute",
                name = function()
                    return turns.isRolling() and "Rolling..." or "Roll"
                end,
                desc = "Do a /roll " .. rules.rolls.MAX_ROLL .. ".",
                width = 1.3,
                disabled = function()
                    return turns.isRolling()
                end,
                func = function()
                    performRoll()
                end,
            },
            roll = {
                order = 2,
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
                    turns.setAction(options.action)
                    turns.setCurrentRoll(value)
                end
            },
            useFatePoint = {
                order = 3,
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
                order = 4,
                type = "execute",
                name = COLOURS.DAMAGE .. "Confirm " .. WEAKNESSES.REBOUND.name,
                desc = WEAKNESSES.REBOUND.desc,
                width = "full",
                hidden = function()
                    if rules.rolls.canProcRebound() then
                        local roll = state[options.action].currentRoll.get()
                        local turnTypeId = turnState.state.type.get()

                        return not (rules.rolls.hasReboundProc(roll, turnTypeId) and not characterState.state.buffLookup.getWeaknessDebuff(WEAKNESSES.REBOUND))
                    end
                    return true
                end,
                func = consequences.confirmReboundRoll,
            },
        }
    }
end