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
            startCombat = turnOptions.args.startCombat,

            turnType = turnOptions.args.turnType,
            enemy = ui.modules.environment.getEnemyOption(1),
            nextTurn = turnOptions.args.nextTurn,
            endCombat = turnOptions.args.endCombat,

            outOfCombatSpacing = turnOptions.args.outOfCombatSpacing,
            spacing = {
                order = 4,
                type = "description",
                name = " "
            },

            KO = actionOptions.KO,
            playerTurn = actionOptions.playerTurn,
            enemyTurn = actionOptions.enemyTurn,
            outOfCombat = actionOptions.outOfCombat,
            effects = ui.modules.turn.modules.effects.getOptions({ order = 7 }),
            buffs = ui.modules.buffs.getOptions({ order = 8 }),
            character = ui.modules.turn.modules.character.getOptions({ order = 9 }),
            environment = ui.modules.environment.getOptions({ order = 10 }),
            party = ui.modules.turn.modules.party.getOptions({ order = 11 }),
            units = ui.modules.units.getOptions({ order = 12 }),
        }
    }
end