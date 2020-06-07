local _, ns = ...

local ui = ns.ui

ui.modules.turn.modules = {
    character = {},
    environment = {},
    roll = {},
    turn = {},
}

ui.modules.turn.getOptions = function()
    local actionOptions = ui.modules.actions.getOptions({ order = 2, groupName = "Actions" })

    return {
        name = "TEA Turn View",
        type = "group",
        desc = "See an overview of the current turn",
        childGroups = "tab",
        args = {
            turn = ui.modules.turn.modules.turn.getOptions({ order = 0 }),
            environment = ui.modules.turn.modules.environment.getOptions({ order = 1 }),
            playerTurn = actionOptions.playerTurn,
            enemyTurn = actionOptions.enemyTurn,
            outOfCombat = actionOptions.outOfCombat,
            character = ui.modules.turn.modules.character.getOptions({ order = 3 }),
        }
    }
end