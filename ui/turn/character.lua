local _, ns = ...

local turnState = ns.turnState
local ui = ns.ui

local state = turnState.state

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.character.getOptions = function(options)
    return {
        type = "group",
        name = "Character",
        desc = "The current state of your character",
        inline = true,
        order = options.order,
        args = {
            hp = {
                type = "input",
                name = "Health",
                desc = "How much health your character has",
                get = state.character.health.get,
                set = function(info, value)
                    state.character.health.set(value)
                end
            }
        }
    }
end