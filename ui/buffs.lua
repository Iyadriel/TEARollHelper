local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffs = ns.buffs
local character = ns.character
local characterState = ns.state.character
local ui = ns.ui

local BUFF_TYPES = buffs.BUFF_TYPES
local MAX_BUFFS = 10
local STAT_LABELS = buffs.STAT_LABELS
local state = characterState.state

ui.modules.buffs = {}

--[[ local options = {
    order: Number
} ]]
ui.modules.buffs.getOptions = function(options)
    return {
        order = options.order,
        type = "group",
        name = "Buffs",
        inline = true,
        args = (function()
            local rows = {}

            for i = 1, MAX_BUFFS do
                rows["buff" .. i] = {
                    order = i,
                    type = "execute",
                    width = 0.5,
                    hidden = function()
                        return not state.activeBuffs.get()[i]
                    end,
                    image = function()
                        local buff = state.activeBuffs.get()[i]
                        return buff and buff.icon or ""
                    end,
                    imageCoords = {.08, .92, .08, .92},
                    name = function()
                        local buff = state.activeBuffs.get()[i]
                        if not buff then return "" end
                        local msg = (buff.colour or "|cffffffff") .. buff.label
                        if buff.stacks then
                            msg = msg .. " (" .. buff.stacks .. ")"
                        end
                        return msg
                    end,
                    func = function()
                        state.activeBuffs.cancel(i)
                    end,
                    desc = function()
                        local buff = state.activeBuffs.get()[i]
                        if not buff then return "" end

                        local msg = ""
                        if buff.type == BUFF_TYPES.STAT then
                            if buff.amount > 0 then
                                msg = STAT_LABELS[buff.stat] .. " increased by " .. buff.amount .. "."
                            else
                                msg = STAT_LABELS[buff.stat] .. " decreased by " .. abs(buff.amount) .. "."
                            end
                        --elseif buff.type == "advantage" then
                        --    msg = "Your rolls have advantage."
                        end

                        msg = msg .. COLOURS.NOTE .. "|n|nSource: " .. buff.source

                        return msg
                    end,
                    dialogControl = "TEABuffButton"
                }
            end

            rows.newBuff = {
                order = 11,
                type = "group",
                name = "Add buff",
                inline = true,
                args = {
                    stat = {
                        order = 0,
                        type = "select",
                        name = "Stat",
                        width = 0.5,
                        values = {
                            offence = STAT_LABELS.offence,
                            defence = STAT_LABELS.defence,
                            spirit = STAT_LABELS.spirit,
                            stamina = STAT_LABELS.stamina,
                        },
                        sorting = { "offence", "defence", "spirit", "stamina" },
                        get = state.newPlayerBuff.stat.get,
                        set = function(info, value)
                            state.newPlayerBuff.stat.set(value)
                        end,
                    },
                    amount = {
                        order = 1,
                        type = "input",
                        name = "Amount",
                        desc = "How much to increase or decrease the stat by.",
                        width = 0.4,
                        validate = function(info, value)
                            if tonumber(value) == nil then
                                return "Buff amount must be a number"
                            end
                            return true
                        end,
                        get = function()
                            return tostring(state.newPlayerBuff.amount.get())
                        end,
                        set = function(info, value)
                            state.newPlayerBuff.amount.set(tonumber(value))
                        end
                    },
                    label = {
                        order = 1,
                        type = "input",
                        name = "Label (optional)",
                        desc = "This can be used as a reminder of where the buff came from. This is only visible to you.",
                        width = 0.5,
                        get = state.newPlayerBuff.label.get,
                        set = function(info, value)
                            state.newPlayerBuff.label.set(value)
                        end
                    },
                    add = {
                        order = 2,
                        type = "execute",
                        name = "Add",
                        width = 0.5,
                        func = function()
                            local newBuff = state.newPlayerBuff
                            local stat = newBuff.stat.get()
                            local amount = newBuff.amount.get()
                            local label = newBuff.label.get()
                            buffs.addStatBuff(stat, amount, label)
                        end
                    }
                }
            }

            rows.racialTrait = {
                order = 12,
                type = "toggle",
                name = function()
                    return "Activate racial trait (" .. character.getPlayerRacialTrait().name .. ")"
                end,
                desc = function()
                    return character.getPlayerRacialTrait().desc
                end,
                cmdHidden = true,
                width = "full",
                hidden = function()
                    local trait = character.getPlayerRacialTrait()
                    return not (trait.supported and trait.manualActivation)
                end,
                validate = function() return true end,
                get = function()
                    return state.featsAndTraits.racialTrait.get() ~= nil
                end,
                set = function(info, value)
                    state.featsAndTraits.racialTrait.set(value and character.getPlayerRacialTrait() or nil)
                end
            }

            return rows
        end)()
    }
end