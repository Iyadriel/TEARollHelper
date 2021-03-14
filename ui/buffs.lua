local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffsState = ns.state.buffs.state
local ui = ns.ui

local MAX_BUFFS = 8

ui.modules.buffs.modules = {
    buffButton = {},
    newBuff = {},
    specialBuffs = {},
}

--[[ local options = {
    order: Number
} ]]
ui.modules.buffs.getOptions = function(options)
    local nameBase = ui.iconString("Interface\\Icons\\spell_holy_wordfortitude") .. "Buffs"

    return {
        order = options.order,
        type = "group",
        name = function()
            local numBuffs = #buffsState.activeBuffs.get()

            if numBuffs > 0 then
                return nameBase .. COLOURS.BUFF .. " (" .. numBuffs .. ")"
            end

            return nameBase
        end,
        args = {
            activeBuffs = {
                order = 0,
                type = "group",
                name = "Active buffs",
                inline = true,
                args = (function()
                    local rows = {}

                    rows.noActiveBuffs = {
                        order = 0,
                        type = "description",
                        fontSize = "medium",
                        name = COLOURS.NOTE .. "Active buffs will appear here.",
                        hidden = function()
                            return buffsState.activeBuffs.get()[1]
                        end,
                    }

                    for i = 1, MAX_BUFFS do
                        rows["buff" .. i] = ui.modules.buffs.modules.buffButton.getOption(i)
                    end

                    return rows
                end)()
            },
            newBuff = ui.modules.buffs.modules.newBuff.getOptions({ order = 1 }),
            specialBuffs = ui.modules.buffs.modules.specialBuffs.getOptions({ order = 2 }),
        }
    }
end