local _, ns = ...

local ui = ns.ui

ui.modules.turn.modules = {
    character = {}
}

ui.modules.turn.getOptions = function()
    return {
        name = "TEA Turn View",
        type = "group",
        desc = "See an overview of the current turn",
        --cmdHidden = true,
        --childGroups = "tab",
        args = {
            character = ui.modules.turn.modules.character.getOptions({ order = 0 })
        }
    }
end