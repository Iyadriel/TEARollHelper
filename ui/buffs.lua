local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local characterState = ns.state.character
local ui = ns.ui

local state = characterState.state

ui.modules.buffs = {}
ui.modules.buffs.getOptions = function()
    return {
        name = "Buffs",
        type = "group",
        desc = "Apply a temporary buff",

        guiInline = true,
        order = 3,
        validate = function(info, input)
            if not input then return true end
            local amount = TEARollHelper:GetArgs(input)
            if tonumber(amount) == nil then
                return "Buff value must be a number! |cFFBBBBBBExample: /tea buff offence 6"
            end
            return true
        end,
        get = function(info)
            return tostring(state.buffs[info[#info]].get())
        end,
        set = function(info, input)
            local buffType = info[#info]
            local amount = TEARollHelper:GetArgs(input)
            state.buffs[buffType].set(tonumber(amount))
            -- if slash command, print feedback
            if info[0] and info[0] ~= "" then
                TEARollHelper:Print("Applied temporary " .. buffType .. " buff of " .. COLOURS.BUFF .. amount .. "|r.")
            end
        end,
        args = {
            offence = {
                type = "input",
                name = "Offence",
                desc = "Buff your character's Offence stat",
                width = "half",
                order = 0
            },
            defence = {
                type = "input",
                name = "Defence",
                desc = "Buff your character's Defence stat",
                width = "half",
                order = 1
            },
            spirit = {
                type = "input",
                name = "Spirit",
                desc = "Buff your character's Spirit stat",
                width = "half",
                order = 1
            },
            clear = {
                type = "execute",
                name = "Clear",
                desc = "Clear your current buffs",
                width = "half",
                order = 2,
                func = function(info)
                    for buff in pairs(state.buffs) do
                        state.buffs[buff] = 0
                    end
                    -- if slash command, print feedback
                    if info[0] and info[0] ~= "" then
                        TEARollHelper:Print("Temporary buffs have been cleared.")
                    end
                end
            }
        }
    }
end