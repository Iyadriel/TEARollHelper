local _, ns = ...

local turnState = ns.turnState

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local function notifyChange()
    --AceConfigRegistry:NotifyChange(ns.ui.modules.rolls.name)
    AceConfigRegistry:NotifyChange(ns.ui.modules.turn.name)
end

local state = {
    health = 25
}

turnState.state = {
    character = {
        health = {
            get = function()
                return state.health
            end,
            format = function()
                return tostring(state.health) .. " HP"
            end,
            set = function(health, external)
                state.health = health
                if external then
                    notifyChange()
                else
                    -- push update
                    --TEARollHelper:SetTRP3CU(health)
                end
            end
        }
    }
}