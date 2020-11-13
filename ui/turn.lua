local _, ns = ...

local ui = ns.ui

ui.modules.turn.modules = {
    character = {},
    effects = {},
    party = {},
    roll = {},
    turn = {},
}

ui.modules.turn.getOptions = function()
    local turnOptions = ui.modules.turn.modules.turn.getOptions({ order = 0 })
    local actionOptions = ui.modules.actions.getOptions({
        order = 5,
        groupName = ui.iconString("Interface\\Buttons\\UI-GroupLoot-Dice-Up") .. "Actions",
    })

    return {
        name = ui.modules.turn.friendlyName,
        type = "group",
        args = {
            environment = ui.modules.environment.getOptions({ order = 0 }),

            startCombat = turnOptions.args.startCombat,
            turnType = turnOptions.args.turnType,
            nextTurn = turnOptions.args.nextTurn,
            endCombat = turnOptions.args.endCombat,

            spacing = {
                order = 4,
                type = "description",
                name = " "
            },

            playerTurn = actionOptions.playerTurn,
            enemyTurn = actionOptions.enemyTurn,
            outOfCombat = actionOptions.outOfCombat,
            effects = ui.modules.turn.modules.effects.getOptions({ order = 6 }),
            buffs = ui.modules.buffs.getOptions({ order = 7 }),
            character = ui.modules.turn.modules.character.getOptions({ order = 8 }),
            party = ui.modules.turn.modules.party.getOptions({ order = 9 }),
            units = ui.modules.units.getOptions({ order = 10 }),
        }
    }
end