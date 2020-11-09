local _, ns = ...

local buffs = ns.buffs
local buffsState = ns.state.buffs.state
local constants = ns.constants
local ui = ns.ui

local ACTION_LABELS_NO_PENANCE = constants.ACTION_LABELS_NO_PENANCE
local PLAYER_BUFF_TYPES = constants.PLAYER_BUFF_TYPES
local STAT_LABELS = constants.STAT_LABELS
local TURN_TYPES = constants.TURN_TYPES

--[[ local options = {
    order: Number
} ]]
ui.modules.buffs.modules.newBuff.getOptions = function(options)
    return {
        order = options.order,
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
                    [PLAYER_BUFF_TYPES.ROLL] = "Roll",
                    [PLAYER_BUFF_TYPES.STAT] = "Stat",
                    [PLAYER_BUFF_TYPES.BASE_DMG] = "Base dmg",
                    [PLAYER_BUFF_TYPES.ADVANTAGE] = "Advantage",
                    [PLAYER_BUFF_TYPES.DISADVANTAGE] = "Disadvantage",
                },
                sorting = {
                    PLAYER_BUFF_TYPES.ROLL,
                    PLAYER_BUFF_TYPES.STAT,
                    PLAYER_BUFF_TYPES.BASE_DMG,
                    PLAYER_BUFF_TYPES.ADVANTAGE,
                    PLAYER_BUFF_TYPES.DISADVANTAGE
                },
                get = buffsState.newPlayerBuff.type.get,
                set = function(info, value)
                    buffsState.newPlayerBuff.type.set(value)
                end,
            },
            turn = {
                order = 1,
                type = "select",
                name = "Turn",
                width = 0.5,
                values = {
                    [TURN_TYPES.PLAYER.id] = TURN_TYPES.PLAYER.name,
                    [TURN_TYPES.ENEMY.id] = TURN_TYPES.ENEMY.name,
                },
                sorting = {TURN_TYPES.PLAYER.id, TURN_TYPES.ENEMY.id},
                hidden = function()
                    return buffsState.newPlayerBuff.type.get() ~= PLAYER_BUFF_TYPES.ROLL
                end,
                get = buffsState.newPlayerBuff.turnTypeID.get,
                set = function(info, value)
                    buffsState.newPlayerBuff.turnTypeID.set(value)
                end,
            },
            stat = {
                order = 2,
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
                    return buffsState.newPlayerBuff.type.get() ~= PLAYER_BUFF_TYPES.STAT
                end,
                get = buffsState.newPlayerBuff.stat.get,
                set = function(info, value)
                    buffsState.newPlayerBuff.stat.set(value)
                end,
            },
            amount = {
                order = 3,
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
                    return type ~= PLAYER_BUFF_TYPES.ROLL and type ~= PLAYER_BUFF_TYPES.STAT and type ~= PLAYER_BUFF_TYPES.BASE_DMG
                end,
                get = function()
                    return tostring(buffsState.newPlayerBuff.amount.get())
                end,
                set = function(info, value)
                    buffsState.newPlayerBuff.amount.set(tonumber(value))
                end
            },
            action = {
                order = 4,
                type = "select",
                name = "Action",
                width = 0.9,
                values = ACTION_LABELS_NO_PENANCE,
                hidden = function()
                    local type = buffsState.newPlayerBuff.type.get()
                    return not (type == PLAYER_BUFF_TYPES.ADVANTAGE or type == PLAYER_BUFF_TYPES.DISADVANTAGE)
                end,
                get = buffsState.newPlayerBuff.action.get,
                set = function(info, value)
                    buffsState.newPlayerBuff.action.set(value)
                end,
            },
            label = {
                order = 5,
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
                order = 6,
                type = "toggle",
                name = "Expire after next turn",
                desc = "This will remove the buff after the next turn. You can always clear buffs manually by right-clicking.",
                hidden = function()
                    return buffsState.newPlayerBuff.type.get() == PLAYER_BUFF_TYPES.ROLL
                end,
                get = buffsState.newPlayerBuff.expireAfterNextTurn.get,
                set = function(info, value)
                    buffsState.newPlayerBuff.expireAfterNextTurn.set(value)
                end,
            },
            expireAfterFirstAction = {
                order = 7,
                type = "toggle",
                name = "Expire after first action",
                desc = "This will remove the buff when you confirm any action in your turn. This is how most buffs work, so leave this enabled if you're not sure.",
                hidden = function()
                    return buffsState.newPlayerBuff.type.get() == PLAYER_BUFF_TYPES.ROLL
                end,
                get = buffsState.newPlayerBuff.expireAfterFirstAction.get,
                set = function(info, value)
                    buffsState.newPlayerBuff.expireAfterFirstAction.set(value)
                end,
            },
            add = {
                order = 8,
                type = "execute",
                name = "Add",
                func = function()
                    local newBuff = buffsState.newPlayerBuff
                    local buffType = newBuff.type.get()
                    local label = newBuff.label.get()
                    local expireAfterNextTurn = newBuff.expireAfterNextTurn.get()
                    local expireAfterFirstAction = newBuff.expireAfterFirstAction.get()

                    if buffType == PLAYER_BUFF_TYPES.ROLL then
                        local turnTypeID = newBuff.turnTypeID.get()
                        local amount = newBuff.amount.get()
                        buffs.addRollBuff(turnTypeID, amount, label)
                    elseif buffType == PLAYER_BUFF_TYPES.STAT then
                        local stat = newBuff.stat.get()
                        local amount = newBuff.amount.get()
                        buffs.addStatBuff(stat, amount, label, expireAfterNextTurn, expireAfterFirstAction)
                    elseif buffType == PLAYER_BUFF_TYPES.BASE_DMG then
                        local amount = newBuff.amount.get()
                        buffs.addBaseDmgBuff(amount, label, expireAfterNextTurn, expireAfterFirstAction)
                    elseif buffType == PLAYER_BUFF_TYPES.ADVANTAGE then
                        local action = newBuff.action.get()
                        buffs.addAdvantageBuff(action, label, expireAfterNextTurn, expireAfterFirstAction)
                    elseif buffType == PLAYER_BUFF_TYPES.DISADVANTAGE then
                        local action = newBuff.action.get()
                        buffs.addDisadvantageDebuff(action, label, expireAfterNextTurn, expireAfterFirstAction)
                    end
                end
            },
        }
    }
end