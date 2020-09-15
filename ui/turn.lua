local _, ns = ...

local ui = ns.ui
local utils = ns.utils

ui.modules.turn.modules = {
    character = {},
    effects = {},
    environment = {},
    roll = {},
    turn = {},
}

ui.modules.turn.getOptions = function()
    local actionOptions = ui.modules.actions.getOptions({
        order = 1,
        groupName = ui.iconString("Interface\\Buttons\\UI-GroupLoot-Dice-Up") .. "Actions",
    })

    return {
        name = ui.modules.turn.friendlyName,
        type = "group",
        args = {
            turn = ui.modules.turn.modules.turn.getOptions({ order = 0 }),

            playerTurn = actionOptions.playerTurn,
            enemyTurn = actionOptions.enemyTurn,
            outOfCombat = actionOptions.outOfCombat,
            effects = ui.modules.turn.modules.effects.getOptions({ order = 2 }),
            buffs = ui.modules.buffs.getOptions({ order = 3 }),
            character = ui.modules.turn.modules.character.getOptions({ order = 4 }),
            environment = ui.modules.turn.modules.environment.getOptions({ order = 5 }),
        }
    }
end