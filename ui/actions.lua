local _, ns = ...

local rolls = ns.state.rolls
local turn = ns.state.turn
local ui = ns.ui

local TURN_TYPES = turn.TURN_TYPES
local rollState = rolls.state
local turnState = turn.state

ui.modules.actions.modules = {
    attack = {},
    healing = {},
    buff = {},
    defend = {},
    meleeSave = {},
    rangedSave = {},
    utility = {}
}

--[[ local options = {
    order: Number,
    groupName: String
} ]]
ui.modules.actions.getOptions = function(options)
    return {
        playerTurn = {
            name = options.groupName or "Player turn",
            type = "group",
            order = options.order,
            hidden = function()
                return not (turnState.inCombat.get() and turnState.type.get() == TURN_TYPES.PLAYER.id)
            end,
            args = {
                attack = ui.modules.actions.modules.attack.getOptions({ order = 0 }),
                heal = ui.modules.actions.modules.healing.getOptions({
                    order = 1,
                    outOfCombat = false
                }),
                buff = ui.modules.actions.modules.buff.getOptions({ order = 2 })
            }
        },
        enemyTurn = {
            name = options.groupName or "Enemy turn",
            type = "group",
            order = options.order,
            hidden = function()
                return not (turnState.inCombat.get() and turnState.type.get() == TURN_TYPES.ENEMY.id)
            end,
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
                        return rollState.defend.threshold
                    end,
                    set = function(info, value)
                        rollState.defend.threshold = value
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
                        return rollState.defend.damageRisk
                    end,
                    set = function(info, value)
                        rollState.defend.damageRisk = value
                    end
                },
                defend = ui.modules.actions.modules.defend.getOptions({ order = 2 }),
                meleeSave = ui.modules.actions.modules.meleeSave.getOptions({ order = 3 }),
                rangedSave = ui.modules.actions.modules.rangedSave.getOptions({ order = 4 }),
            }
        },
        outOfCombat = {
            name = options.groupName or "Out of combat",
            type = "group",
            order = options.order,
            hidden = function()
                return turnState.inCombat.get()
            end,
            args = {
                heal = ui.modules.actions.modules.healing.getOptions({
                    order = 0,
                    outOfCombat = true
                }),
                utility = ui.modules.actions.modules.utility.getOptions({ order = 1 }),
            }
        }
    }
end