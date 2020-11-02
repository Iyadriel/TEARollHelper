local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local party = ns.state.party
local ui = ns.ui
local utils = ns.utils

local state = party.state

local selected = {}
local nameStart = ui.iconString("Interface\\Icons\\achievement_guildperk_everybodysfriend") .. "Party" .. COLOURS.NOTE .. " ("

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.party.getOptions = function(options)
    return {
        order = options.order,
        type = "group",
        --name = ui.iconString("Interface\\Icons\\achievement_guildperk_everybodysfriend") .. "Party",
        name = function()
            local health = state.partyMembers.getGroupHealthPerc()
            return nameStart .. utils.healthColor(health, 100) .. health .. "%" .. COLOURS.NOTE .. ")"
        end,
--[[         args = (function ()
            local partyMembers = {}

            for i = 1, 20 do
                partyMembers["partyMember" .. i] = {
                    order = i,
                    type = "description",
                    name = function()

                    end,
                    hidden = function()
                        return state.numMembers.get() < i
                    end,
                }
            end

            return partyMembers
        end)(), ]]
        args = {
            members = {
                order = 0,
                type = "multiselect",
                width = "full",
                name = "Party members",
                hidden = function()
                    return party.state.numMembers.get() == 0
                end,
                values = function()
                    local values = {}

                    for name, member in pairs(state.partyMembers.list()) do
                        values[name] = member:ToString()
                    end

                    return values
                end,
                get = function(info, name)
                    return selected[name]
                end,
                set = function(info, name, value)
                    if value then
                        selected[name] = true
                    else
                        selected[name] = nil
                    end
                end
            },
            remove = {
                order = 1,
                type = "execute",
                name = "Remove",
                hidden = function()
                    return party.state.numMembers.get() == 0
                end,
                func = function()
                    state.partyMembers.removeMultiple(selected)
                    selected = {}
                end
            },
            emptyState = {
                order = 2,
                type = "description",
                name = "Your party is empty.",
                hidden = function()
                    return party.state.numMembers.get() > 0
                end,
            }
        },
    }
end