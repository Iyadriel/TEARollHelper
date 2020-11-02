local _, ns = ...

local party = ns.state.party
local ui = ns.ui

local state = party.state

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.party.getOptions = function(options)
    return {
        order = options.order,
        type = "group",
        name = ui.iconString("Interface\\Icons\\achievement_guildperk_everybodysfriend") .. "Party",
--[[         args = (function ()
            local partyMembers = {}

            for i = 1, 20 do
                partyMembers["partyMember" .. i] = {
                    order = i,
                    type = "description",
                    name = function()

                    end,
                    hidden = function()
                        return state.partyMembers.count() < i
                    end,
                }
            end

            return partyMembers
        end)(), ]]
        args = {
            members = {
                order = 0,
                type = "multiselect",
                name = "Members",
                values = function()
                    local values = {}

                    for name, member in pairs(state.partyMembers.list()) do
                        values[name] = member:ToString()
                    end

                    return values
                end
            }
        },
    }
end