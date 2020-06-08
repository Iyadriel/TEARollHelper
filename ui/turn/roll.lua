local _, ns = ...

local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local environment = ns.state.environment
local rollState = ns.state.rolls
local rules = ns.rules
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
    action: String, -- attack, healing, buff, defend, meleeSave, rangedSave, utility
    includePrep: Boolean,
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
        local rollMode = state[options.action].rollMode.get()
        local rollModeMod = getRollModeModifier()
        local prepMode = options.includePrep and state[options.action].prepMode.get() or false

        turns.setAction(options.action)
        turns.roll(rollMode, rollModeMod, prepMode, isReroll)
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
                width = 0.65,
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
            prep = {
                order = 1,
                type = "toggle",
                name = "Include prep",
                desc = "Activate if you prepared during the last player turn.",
                width = 0.55,
                hidden = not options.includePrep,
                get = function()
                    return state[options.action].prepMode.get()
                end,
                set = function(info, value)
                    turns.setAction(options.action)
                    state[options.action].prepMode.set(value)
                end,
            },
            performRoll = {
                order = 2,
                type = "execute",
                name = function()
                    return turns.isRolling() and "Rolling..." or "Roll"
                end,
                desc = "Do a /roll " .. rules.rolls.MAX_ROLL .. ".",
                width = options.includePrep and 0.85 or 1.4,
                disabled = function()
                    return turns.isRolling()
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
                    turns.setAction(options.action)
                    turns.setCurrentRoll(value)
                end
            },
            prepRoll = {
                order = 4,
                name = "Prep roll result",
                type = "range",
                desc = "The number you rolled",
                min = 1,
                max = rules.rolls.MAX_ROLL,
                step = 1,
                hidden = not options.includePrep or function()
                    return not state[options.action].prepMode.get()
                end,
                get = function()
                    return state[options.action].currentPreppedRoll.get()
                end,
                set = function(info, value)
                    turns.setAction(options.action)
                    turns.setPreppedRoll(value)
                end
            },
            useFatePoint = {
                order = 5,
                type = "execute",
                name = "Use Fate Point",
                desc = "Uses a Fate Point and rolls again, picking the highest result.",
                width = "full",
                hidden = function()
                    if characterState.state.numFatePoints.get() > 0 then
                        local roll = state[options.action].currentRoll.get()

                        if not roll then return true end

                        local action = options.action
                        local attack, healing, buff, defence, meleeSave, rangedSave

                        if action == ACTIONS.attack then
                            attack = rollState.getAttack()
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
                        return not rules.rolls.shouldSuggestFatePoint(roll, attack, healing, buff, defence, meleeSave, rangedSave)
                    end
                    return true
                end,
                func = function()
                    performRoll(true)
                    consequences.useFatePoint()
                end,
            },
            rebound = {
                order = 6,
                type = "execute",
                name = COLOURS.DAMAGE .. "Confirm " .. WEAKNESSES.REBOUND.name,
                desc = WEAKNESSES.REBOUND.desc,
                width = "full",
                hidden = function()
                    if rules.rolls.canProcRebound() then
                        local roll = state[options.action].currentRoll.get()
                        local turnTypeId = turnState.state.type.get()

                        return not rules.rolls.hasReboundProc(roll, turnTypeId)
                    end
                    return true
                end,
                func = consequences.confirmReboundRoll,
            },
        }
    }
end