local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffs = ns.buffs
local buffsState = ns.state.buffs.state
local constants = ns.constants
local ui = ns.ui

local ACTION_LABELS = constants.ACTION_LABELS
local BUFF_TYPES = constants.BUFF_TYPES
local MAX_BUFFS = 8
local STAT_LABELS = constants.STAT_LABELS
local TURN_TYPES = constants.TURN_TYPES

ui.modules.buffs = {}

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
                        rows["buff" .. i] = {
                            order = i,
                            type = "execute",
                            width = 0.5,
                            hidden = function()
                                return not buffsState.activeBuffs.get()[i]
                            end,
                            image = function()
                                local buff = buffsState.activeBuffs.get()[i]
                                return buff and buff.icon or ""
                            end,
                            imageCoords = {.08, .92, .08, .92},
                            name = function()
                                local buff = buffsState.activeBuffs.get()[i]
                                if not buff then return "" end

                                local msg = (buff.colour or "|cffffffff") .. buff.label

                                if buff.stacks and buff.stacks > 1 then
                                    msg = msg .. " (" .. buff.stacks .. ")"
                                end

                                return msg
                            end,
                            func = function()
                                local buff = buffsState.activeBuffs.get()[i]
                                if buff.canCancel then
                                    buffsState.activeBuffs.cancel(i)
                                end
                            end,
                            desc = function()
                                local buff = buffsState.activeBuffs.get()[i]
                                if not buff then return "" end

                                local msg = " |n"

                                if buff.types[BUFF_TYPES.STAT] then
                                    for stat, amount in pairs(buff.stats) do
                                        if amount > 0 then
                                            msg = msg .. STAT_LABELS[stat] .. " increased by " .. amount .. ". "
                                        else
                                            msg = msg .. STAT_LABELS[stat] .. " reduced by " .. abs(amount) .. ". "
                                        end
                                    end
                                end

                                if buff.types[BUFF_TYPES.BASE_DMG] then
                                    if buff.amount > 0 then
                                        msg = msg .. "Base damage increased by " .. buff.amount .. ". "
                                    else
                                        msg = msg .. "Base damage reduced by " .. buff.amount .. ". "
                                    end
                                end

                                if buff.types[BUFF_TYPES.ADVANTAGE] then
                                    msg = msg .. "Your rolls have advantage.|nApplies to: "
                                    if buff.turnTypeId then
                                        msg = msg .. TURN_TYPES[buff.turnTypeId].name .. " turn, "
                                    end
                                    for action in pairs(buff.actions) do
                                        msg = msg ..  ACTION_LABELS[action] .. ", "
                                    end
                                    msg = string.sub(msg, 0, -3)
                                elseif buff.types[BUFF_TYPES.DISADVANTAGE] then
                                    msg = msg .. "Your rolls have disadvantage.|nApplies to: "
                                    if buff.turnTypeId then
                                        msg = msg .. TURN_TYPES[buff.turnTypeId].name .. " turn, "
                                    end
                                    for action in pairs(buff.actions) do
                                        msg = msg ..  ACTION_LABELS[action] .. ", "
                                    end
                                    msg = string.sub(msg, 0, -3)
                                end

                                if buff.types[BUFF_TYPES.HEALING_OVER_TIME] then
                                    msg = msg .. "Healing for " .. buff.healingPerTick .. " at the start of every turn."
                                end

                                if buff.types[BUFF_TYPES.MAX_HEALTH] then
                                    local amount = buff.amount
                                    if amount > 0 then
                                        msg = msg .. "Maximum health increased by " .. amount .. ". "
                                    else
                                        msg = msg .. "Maximum health reduced by " .. abs(amount) .. ". "
                                    end
                                end

                                if buff.types[BUFF_TYPES.HEALING_DONE] then
                                    local amount = buff.amount
                                    if amount > 0 then
                                        msg = msg .. "Healing done increased by " .. amount .. ". "
                                    else
                                        msg = msg .. "Healing done reduced by " .. abs(amount) .. ". "
                                    end
                                end

                                if buff.types[BUFF_TYPES.DAMAGE_TAKEN] then
                                    local amount = buff.amount
                                    if amount > 0 then
                                        msg = msg .. "Damage taken increased by " .. amount .. ". "
                                    else
                                        msg = msg .. "Damage taken reduced by " .. abs(amount) .. ". "
                                    end
                                end

                                if buff.types[BUFF_TYPES.DAMAGE_DONE] then
                                    local amount = buff.amount
                                    if amount > 0 then
                                        msg = msg .. "Damage done increased by " .. amount .. ". "
                                    else
                                        msg = msg .. "Damage done reduced by " .. abs(amount) .. ". "
                                    end
                                end

                                if buff.remainingTurns then
                                    if type(buff.remainingTurns) == "table" then
                                        local remainingPlayerTurns = buff.remainingTurns[TURN_TYPES.PLAYER.id]
                                        local remainingEnemyTurns = buff.remainingTurns[TURN_TYPES.ENEMY.id]
                                        if remainingPlayerTurns then
                                            msg = msg .. COLOURS.NOTE .. "|n|nRemaining " .. TURN_TYPES.PLAYER.name .. " turns: " .. remainingPlayerTurns
                                        elseif remainingEnemyTurns then
                                            msg = msg .. COLOURS.NOTE .. "|n|nRemaining " .. TURN_TYPES.ENEMY.name .. " turns: " .. remainingEnemyTurns
                                        end
                                    else
                                        msg = msg .. COLOURS.NOTE .. "|n|nRemaining turns: " .. buff.remainingTurns
                                    end
                                end

                                if buff.expireAfterFirstAction then
                                    msg = msg .. COLOURS.NOTE .. "|n|nLasts for 1 action"
                                end
                                if buff.expireOnCombatEnd then
                                    msg = msg .. COLOURS.NOTE .. "|n|nLasts until end of combat"
                                end

                                --msg = msg .. COLOURS.NOTE .. "|n|nSource: " .. buff.source

                                return msg
                            end,
                            dialogControl = "TEABuffButton"
                        }
                    end

                    return rows
                end)()
            },
            newBuff = {
                order = 1,
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
                            [BUFF_TYPES.STAT] = "Stat",
                            [BUFF_TYPES.BASE_DMG] = "Base dmg",
                            [BUFF_TYPES.DISADVANTAGE] = "Disadvantage",
                            [BUFF_TYPES.ADVANTAGE] = "Advantage"
                        },
                        sorting = {BUFF_TYPES.STAT, BUFF_TYPES.BASE_DMG, BUFF_TYPES.ADVANTAGE, BUFF_TYPES.DISADVANTAGE},
                        get = buffsState.newPlayerBuff.type.get,
                        set = function(info, value)
                            buffsState.newPlayerBuff.type.set(value)
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
                        sorting = constants.STATS_SORTED,
                        hidden = function()
                            return buffsState.newPlayerBuff.type.get() ~= BUFF_TYPES.STAT
                        end,
                        get = buffsState.newPlayerBuff.stat.get,
                        set = function(info, value)
                            buffsState.newPlayerBuff.stat.set(value)
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
                            local type = buffsState.newPlayerBuff.type.get()
                            return type ~= BUFF_TYPES.STAT and type ~= BUFF_TYPES.BASE_DMG
                        end,
                        get = function()
                            return tostring(buffsState.newPlayerBuff.amount.get())
                        end,
                        set = function(info, value)
                            buffsState.newPlayerBuff.amount.set(tonumber(value))
                        end
                    },
                    action = {
                        order = 3,
                        type = "select",
                        name = "Action",
                        width = 0.9,
                        values = ACTION_LABELS,
                        hidden = function()
                            local type = buffsState.newPlayerBuff.type.get()
                            return not (type == BUFF_TYPES.ADVANTAGE or type == BUFF_TYPES.DISADVANTAGE)
                        end,
                        get = buffsState.newPlayerBuff.action.get,
                        set = function(info, value)
                            buffsState.newPlayerBuff.action.set(value)
                        end,
                    },
                    label = {
                        order = 4,
                        type = "input",
                        name = "Label (optional)",
                        desc = "This can be used as a reminder of where the buff came from. This is only visible to you.",
                        width = 0.5,
                        get = buffsState.newPlayerBuff.label.get,
                        set = function(info, value)
                            buffsState.newPlayerBuff.label.set(value)
                        end
                    },
                    expireAfterNextTurn = {
                        order = 5,
                        type = "toggle",
                        name = "Expire after next turn",
                        desc = "This will remove the buff after the next turn. You can always clear buffs manually by right-clicking.",
                        get = buffsState.newPlayerBuff.expireAfterNextTurn.get,
                        set = function(info, value)
                            buffsState.newPlayerBuff.expireAfterNextTurn.set(value)
                        end,
                    },
                    expireAfterFirstAction = {
                        order = 6,
                        type = "toggle",
                        name = "Expire after first action",
                        desc = "This will remove the buff when you confirm any action in your turn. This is how most buffs work, so leave this enabled if you're not sure.",
                        get = buffsState.newPlayerBuff.expireAfterFirstAction.get,
                        set = function(info, value)
                            buffsState.newPlayerBuff.expireAfterFirstAction.set(value)
                        end,
                    },
                    add = {
                        order = 7,
                        type = "execute",
                        name = "Add",
                        func = function()
                            local newBuff = buffsState.newPlayerBuff
                            local buffType = newBuff.type.get()
                            local label = newBuff.label.get()
                            local expireAfterNextTurn = newBuff.expireAfterNextTurn.get()
                            local expireAfterFirstAction = newBuff.expireAfterFirstAction.get()

                            if buffType == BUFF_TYPES.STAT then
                                local stat = newBuff.stat.get()
                                local amount = newBuff.amount.get()
                                buffs.addStatBuff(stat, amount, label, expireAfterNextTurn, expireAfterFirstAction)
                            elseif buffType == BUFF_TYPES.BASE_DMG then
                                local amount = newBuff.amount.get()
                                buffs.addBaseDmgBuff(amount, label, expireAfterNextTurn, expireAfterFirstAction)
                            elseif buffType == BUFF_TYPES.ADVANTAGE then
                                local action = newBuff.action.get()
                                buffs.addAdvantageBuff(action, label, expireAfterNextTurn, expireAfterFirstAction)
                            elseif buffType == BUFF_TYPES.DISADVANTAGE then
                                local action = newBuff.action.get()
                                buffs.addDisadvantageDebuff(action, label, expireAfterNextTurn, expireAfterFirstAction)
                            end
                        end
                    },
                }
            }
        }
    }
end