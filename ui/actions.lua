local _, ns = ...

local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local traits = ns.resources.traits
local turn = ns.state.turn
local ui = ns.ui

local COLOURS = TEARollHelper.COLOURS
local TRAITS = traits.TRAITS
local TURN_TYPES = constants.TURN_TYPES
local turnState = turn.state
local state = characterState.state

ui.modules.actions.modules = {
    playerTurn = {},

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
            childGroups = "tab",
            hidden = function()
                return not (turnState.inCombat.get() and turnState.type.get() == TURN_TYPES.PLAYER.id)
            end,
            args = {
                attack = ui.modules.actions.modules.attack.getOptions({ order = 0 }),
                heal = ui.modules.actions.modules.healing.getOptions({
                    order = 1,
                    outOfCombat = false,
                    turnTypeID = TURN_TYPES.PLAYER.id,
                }),
                buff = ui.modules.actions.modules.buff.getOptions({ order = 2 }),
                utility = ui.modules.actions.modules.utility.getOptions({ order = 3, turnTypeID = TURN_TYPES.PLAYER.id }),
            }
        },
        enemyTurn = {
            name = options.groupName or "Enemy turn",
            type = "group",
            order = options.order,
            childGroups = "tab",
            hidden = function()
                return not (turnState.inCombat.get() and turnState.type.get() == TURN_TYPES.ENEMY.id)
            end,
            args = {
                defend = ui.modules.actions.modules.defend.getOptions({ order = 2 }),
                meleeSave = ui.modules.actions.modules.meleeSave.getOptions({ order = 3 }),
                rangedSave = ui.modules.actions.modules.rangedSave.getOptions({ order = 4 }),
                utility = ui.modules.actions.modules.utility.getOptions({ order = 5, turnTypeID = TURN_TYPES.ENEMY.id }),
            }
        },
        outOfCombat = {
            name = options.groupName or "Out of combat",
            type = "group",
            order = options.order,
            childGroups = "tab",
            hidden = function()
                return turnState.inCombat.get()
            end,
            args = {
                secondWind = {
                    order = 0,
                    type = "execute",
                    name = COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.SECOND_WIND.name,
                    desc = TRAITS.SECOND_WIND.desc,
                    hidden = function()
                        return not character.hasTrait(TRAITS.SECOND_WIND)
                    end,
                    disabled = function()
                        return state.featsAndTraits.numSecondWindCharges.get() == 0
                    end,
                    func = consequences.useSecondWind
                },
                heal = ui.modules.actions.modules.healing.getOptions({
                    order = 1,
                    outOfCombat = true,
                    turnTypeID = TURN_TYPES.OUT_OF_COMBAT.id,
                }),
                utility = ui.modules.actions.modules.utility.getOptions({ order = 2, turnTypeID = TURN_TYPES.OUT_OF_COMBAT.id }),
            }
        }
    }
end