local _, ns = ...

local characterState = ns.state.character
local constants = ns.constants
local rollState = ns.state.rolls
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

local COLOURS = TEARollHelper.COLOURS
local ROLL_MODES = constants.ROLL_MODES
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

        local buffLookup = characterState.state.buffLookup
        local advantageBuff = buffLookup.getAdvantageBuff(action)
        local disadvantageDebuff = buffLookup.getDisadvantageDebuff(action)
        local enemyId = state.attack.enemyId.get()

        local modifier = rules.rolls.getRollModeModifier(action, advantageBuff, disadvantageDebuff, enemyId)
        modifier = max(ROLL_MODES.DISADVANTAGE, min(ROLL_MODES.ADVANTAGE, modifier))
        return modifier
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
                    local rollMode = state[options.action].rollMode.get()
                    local rollModeMod = getRollModeModifier()
                    local prepMode = options.includePrep and state[options.action].prepMode.get() or false

                    turns.setAction(options.action)
                    turns.roll(rollMode, rollModeMod, prepMode)
                end
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
        }
    }
end