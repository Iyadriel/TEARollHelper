local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local turns = ns.turns
local ui = ns.ui

ui.modules.buffs = {}
ui.modules.buffs.getOptions = function()
    return {
        name = "Buffs",
        type = "group",
        desc = "Apply a temporary buff",

        guiInline = true,
        order = 2,
        validate = function(info, input)
            if not input then return true end
            local amount = TEARollHelper:GetArgs(input)
            if tonumber(amount) == nil then
                return "Buff value must be a number! |cFFBBBBBBExample: /tea buff offence 6"
            end
            return true
        end,
        get = function(info)
            return tostring(turns.getCurrentBuffs()[info[#info]])
        end,
        set = function(info, input)
            local buffType = info[#info]
            local amount = TEARollHelper:GetArgs(input)
            turns.setCurrentBuff(buffType, tonumber(amount))
            -- if slash command, print feedback
            if info[0] and info[0] ~= "" then
                TEARollHelper:Print("Applied temporary " .. buffType .. " buff of " .. COLOURS.BUFF .. amount .. "|r.")
            end
        end,
        args = {
            offence = {
                type = "input",
                name = "Offence",
                desc = "Buff your character's offence stat",
                order = 0
            },
            defence = {
                type = "input",
                name = "Defence",
                desc = "Buff your character's defence stat",
                order = 1
            },
            clear = {
                type = "execute",
                name = "Clear",
                desc = "Clear your current buffs",
                order = 2,
                func = function(info)
                    turns.clearCurrentBuffs()
                    -- if slash command, print feedback
                    if info[0] and info[0] ~= "" then
                        TEARollHelper:Print("Temporary buffs have been cleared.")
                    end
                end
            },
            description = {
                type = "description",
                name = "Buffs expire automatically after one roll.\nIf using the roll window, they must be cleared manually.",
                order = 3
            }
        }
    }
end