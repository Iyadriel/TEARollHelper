local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local character = ns.character
local rolls = ns.state.rolls
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

local state = rolls.state

local ROLL_MODES = turns.ROLL_MODES

-- Update config UI, in case it is also open
local function notifyChange()
    AceConfigRegistry:NotifyChange(ui.modules.config.name)
end

ui.modules.rolls.modules = {
    attack = {},
    healing = {},
    buff = {},
    defend = {},
    meleeSave = {},
    rangedSave = {},
    utility = {}
}

ui.modules.rolls.getOptions = function()
    return {
        name = "TEA Roll View",
        type = "group",
        desc = "See possible outcomes for a given roll",
        cmdHidden = true,
        order = 3,
        childGroups = "tab",
        args = {
            rollMode = {
                name = "Roll mode",
                type = "select",
                order = 0,
                values = {
                    [ROLL_MODES.DISADVANTAGE] = "Disadvantage",
                    [ROLL_MODES.NORMAL] = "Normal",
                    [ROLL_MODES.ADVANTAGE] = "Advantage"
                },
                get = turns.getRollMode,
                set = function(info, value)
                    turns.setRollMode(value)
                end
            },
            performRoll = {
                name = function()
                    return turns.isRolling() and "Rolling..." or "Roll"
                end,
                type = "execute",
                desc = "Do a /roll " .. rules.rolls.MAX_ROLL .. ".",
                disabled = function()
                    return turns.isRolling()
                end,
                order = 1,
                func = turns.roll
            },
            roll = {
                name = "Roll result",
                type = "range",
                desc = "The number you rolled",
                min = 1,
                softMax = rules.rolls.MAX_ROLL,
                max = rules.rolls.MAX_ROLL * 2, -- "support" prepping by letting people add rolls together
                step = 1,
                order = 2,
                get = function()
                    return turns.getCurrentTurnValues().roll
                end,
                set = function(info, value)
                    turns.setCurrentRoll(value)
                end
            },
            buffs = ui.modules.buffs.getOptions(),
            racialTrait = {
                type = "toggle",
                name = function()
                    return "Activate racial trait (" .. character.getPlayerRacialTrait().name .. ")"
                end,
                desc = function()
                    return character.getPlayerRacialTrait().desc
                end,
                width = "full",
                order = 4,
                hidden = function()
                    local trait = character.getPlayerRacialTrait()
                    return not (trait.supported and trait.manualActivation)
                end,
                get = function()
                    return state.racialTrait ~= nil
                end,
                set = function(info, value)
                    state.racialTrait = (value and character.getPlayerRacialTrait() or nil)
                    notifyChange() -- so we can disable/enable trait selection in character sheet
                end
            },
            playerTurn = {
                name = "Player turn",
                type = "group",
                order = 5,
                args = {
                    attack = ui.modules.rolls.modules.attack.getOptions({ order = 0 }),
                    heal = ui.modules.rolls.modules.healing.getOptions({
                        order = 1,
                        outOfCombat = false
                    }),
                    buff = ui.modules.rolls.modules.buff.getOptions({ order = 2 })
                }
            },
            enemyTurn = {
                name = "Enemy turn",
                type = "group",
                order = 6,
                args = {
                    defendThreshold = {
                        name = "Defend threshold",
                        type = "range",
                        desc = "The minimum required roll to not take any damage",
                        min = 1,
                        softMax = 20,
                        max = 100,
                        step = 1,
                        order = 0,
                        get = function()
                            return state.defend.threshold
                        end,
                        set = function(info, value)
                            state.defend.threshold = value
                        end
                    },
                    damageRisk = {
                        name = "Damage risk",
                        type = "range",
                        desc = "How much damage you will take if you fail the roll",
                        min = 1,
                        softMax = 20,
                        max = 100,
                        step = 1,
                        order = 1,
                        get = function()
                            return state.defend.damageRisk
                        end,
                        set = function(info, value)
                            state.defend.damageRisk = value
                        end
                    },
                    defend = ui.modules.rolls.modules.defend.getOptions({ order = 2 }),
                    meleeSave = ui.modules.rolls.modules.meleeSave.getOptions({ order = 3 }),
                    rangedSave = ui.modules.rolls.modules.rangedSave.getOptions({ order = 4 }),
                }
            },
            ooc = {
                name = "Out of combat",
                type = "group",
                order = 7,
                args = {
                    heal = ui.modules.rolls.modules.healing.getOptions({
                        order = 0,
                        outOfCombat = true
                    }),
                    utility = ui.modules.rolls.modules.utility.getOptions({ order = 1 }),
                }
            }
        }
    }
end