local _, ns = ...

local ui = ns.ui

ui.modules.turn.modules = {
    character = {},
    turn = {}
}

ui.modules.turn.getOptions = function()
    return {
        name = "TEA Turn View",
        type = "group",
        desc = "See an overview of the current turn",
        --cmdHidden = true,
        --childGroups = "tab",
        args = {
            turn = ui.modules.turn.modules.turn.getOptions({ order = 0 }),
            character = ui.modules.turn.modules.character.getOptions({ order = 1 })
        }
    }
end