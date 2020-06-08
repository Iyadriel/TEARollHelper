local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffs = ns.buffs
local constants = ns.constants
local characterState = ns.state.character
local ui = ns.ui

local ACTION_LABELS = constants.ACTION_LABELS
local BUFF_TYPES = constants.BUFF_TYPES
local MAX_BUFFS = 8
local ROLL_MODES = constants.ROLL_MODES
local STAT_LABELS = constants.STAT_LABELS
local TURN_TYPES = constants.TURN_TYPES

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
                        local buff = state.activeBuffs.get()[i]
                        if buff.canCancel then
                            state.activeBuffs.cancel(i)
                        end
                    end,
                    desc = function()
                        local buff = state.activeBuffs.get()[i]
                        if not buff then return "" end

                        local msg = " |n"
                        if buff.type == BUFF_TYPES.STAT then
                            for stat, amount in pairs(buff.stats) do
                                if amount > 0 then
                                    msg = msg .. STAT_LABELS[stat] .. " increased by " .. amount .. ". "
                                else
                                    msg = msg .. STAT_LABELS[stat] .. " decreased by " .. abs(amount) .. ". "
                                end
                            end
                        elseif buff.type == BUFF_TYPES.ADVANTAGE then
                            msg = msg .. "Your rolls have advantage.|nApplies to: "
                            if buff.turnTypeId then
                                msg = msg .. TURN_TYPES[buff.turnTypeId].name .. " turn, "
                            end
                            for action in pairs(buff.actions) do
                                msg = msg ..  ACTION_LABELS[action] .. ", "
                            end
                            msg = string.sub(msg, 0, -3)
                        elseif buff.type == BUFF_TYPES.DISADVANTAGE then
                            msg = msg .. "Your rolls have disadvantage.|nApplies to: "
                            if buff.turnTypeId then
                                msg = msg .. TURN_TYPES[buff.turnTypeId].name .. " turn, "
                            end
                            for action in pairs(buff.actions) do
                                msg = msg ..  ACTION_LABELS[action] .. ", "
                            end
                            msg = string.sub(msg, 0, -3)
                        end

                        if buff.remainingTurns then
                            msg = msg .. COLOURS.NOTE .. "|n|nRemaining turns: " .. buff.remainingTurns
                        end

                        --msg = msg .. COLOURS.NOTE .. "|n|nSource: " .. buff.source

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
                    type = {
                        order = 0,
                        type = "select",
                        name = "Type",
                        width = 0.55,
                        values = {
                            stat = "Stat",
                            [ROLL_MODES.DISADVANTAGE] = "Disadvantage",
                            [ROLL_MODES.ADVANTAGE] = "Advantage"
                        },
                        sorting = {"stat", ROLL_MODES.ADVANTAGE, ROLL_MODES.DISADVANTAGE},
                        get = state.newPlayerBuff.type.get,
                        set = function(info, value)
                            state.newPlayerBuff.type.set(value)
                        end,
                    },
                    stat = {
                        order = 1,
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
                        hidden = function()
                            return state.newPlayerBuff.type.get() ~= "stat"
                        end,
                        get = state.newPlayerBuff.stat.get,
                        set = function(info, value)
                            state.newPlayerBuff.stat.set(value)
                        end,
                    },
                    amount = {
                        order = 2,
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
                        hidden = function()
                            return state.newPlayerBuff.type.get() ~= "stat"
                        end,
                        get = function()
                            return tostring(state.newPlayerBuff.amount.get())
                        end,
                        set = function(info, value)
                            state.newPlayerBuff.amount.set(tonumber(value))
                        end
                    },
                    action = {
                        order = 3,
                        type = "select",
                        name = "Action",
                        width = 0.9,
                        values = ACTION_LABELS,
                        hidden = function()
                            return state.newPlayerBuff.type.get() == "stat"
                        end,
                        get = state.newPlayerBuff.action.get,
                        set = function(info, value)
                            state.newPlayerBuff.action.set(value)
                        end,
                    },
                    label = {
                        order = 4,
                        type = "input",
                        name = "Label (optional)",
                        desc = "This can be used as a reminder of where the buff came from. This is only visible to you.",
                        width = 0.5,
                        get = state.newPlayerBuff.label.get,
                        set = function(info, value)
                            state.newPlayerBuff.label.set(value)
                        end
                    },
                    expireAfterNextTurn = {
                        order = 5,
                        type = "toggle",
                        name = "Expire after next turn",
                        desc = "This will remove the buff after the next turn. You can always clear buffs manually by right-clicking.",
                        get = characterState.state.newPlayerBuff.expireAfterNextTurn.get,
                        set = function(info, value)
                            characterState.state.newPlayerBuff.expireAfterNextTurn.set(value)
                        end,
                    },
                    add = {
                        order = 6,
                        type = "execute",
                        name = "Add",
                        func = function()
                            local newBuff = state.newPlayerBuff
                            local buffType = newBuff.type.get()
                            local label = newBuff.label.get()
                            local expireAfterNextTurn = newBuff.expireAfterNextTurn.get()
                            if buffType == "stat" then
                                local stat = newBuff.stat.get()
                                local amount = newBuff.amount.get()
                                buffs.addStatBuff(stat, amount, label, expireAfterNextTurn)
                            elseif buffType == ROLL_MODES.ADVANTAGE then
                                local action = newBuff.action.get()
                                buffs.addAdvantageBuff(action, label, expireAfterNextTurn)
                            elseif buffType == ROLL_MODES.DISADVANTAGE then
                                local action = newBuff.action.get()
                                buffs.addDisadvantageDebuff(action, label, expireAfterNextTurn)
                            end
                        end
                    },
                }
            }

            return rows
        end)()
    }
end