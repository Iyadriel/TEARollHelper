local _, ns = ...

local consequences = ns.consequences
local ui = ns.ui

--[[ local options = {
    order: Number,
    name: Function,
    hidden: Function?,
    func: Function?,
} ]]
local function confirmActionButton(actionType, getAction, options)
    return {
        order = options.order,
        type = "execute",
        name = options.name or "Confirm",
        desc = "Confirm that you perform the stated action, consuming any charges and buffs used.",
        hidden = options.hidden,
        func = options.func or function()
            consequences.confirmAction(actionType, getAction())
        end
    }
end

ui.helpers.confirmActionButton = confirmActionButton