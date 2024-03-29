local _, ns = ...

local buffs = ns.buffs
local buffsState = ns.state.buffs.state
local constants = ns.constants
local ui = ns.ui

local ACTION_LABELS = constants.ACTION_LABELS
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
                width = 0.8,
                values = {
                    [PLAYER_BUFF_TYPES.ROLL] = "Roll",
                    [PLAYER_BUFF_TYPES.DAMAGE_ROLL] = "Roll (damage)",
                    [PLAYER_BUFF_TYPES.STAT] = "Stat",
                    [PLAYER_BUFF_TYPES.BASE_DMG] = "Base damage",
                    [PLAYER_BUFF_TYPES.ADVANTAGE] = "Advantage",
                    [PLAYER_BUFF_TYPES.DISADVANTAGE] = "Disadvantage",
                },
                sorting = {
                    PLAYER_BUFF_TYPES.ROLL,
                    PLAYER_BUFF_TYPES.DAMAGE_ROLL,
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
                width = 0.7,
                values = {
                    [TURN_TYPES.PLAYER.id] = TURN_TYPES.PLAYER.name,
                    [TURN_TYPES.ENEMY.id] = TURN_TYPES.ENEMY.name,
                },
                sorting = {TURN_TYPES.PLAYER.id, TURN_TYPES.ENEMY.id},
                hidden = function()
                    local type = buffsState.newPlayerBuff.type.get()
                    return type ~= PLAYER_BUFF_TYPES.ROLL
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
                width = 0.7,
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
                width = 0.5,
                validate = function(info, value)
                    if tonumber(value) == nil then
                        return "Buff amount must be a number"
                    end
                    return true
                end,
                hidden = function()
                    local type = buffsState.newPlayerBuff.type.get()
                    return not(type == PLAYER_BUFF_TYPES.ROLL or type == PLAYER_BUFF_TYPES.DAMAGE_ROLL) and type ~= PLAYER_BUFF_TYPES.STAT and type ~= PLAYER_BUFF_TYPES.BASE_DMG
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
                width = 0.8,
                values = ACTION_LABELS,
                hidden = function()
                    local type = buffsState.newPlayerBuff.type.get()
                    return not (type == PLAYER_BUFF_TYPES.ADVANTAGE or type == PLAYER_BUFF_TYPES.DISADVANTAGE)
                end,
                get = buffsState.newPlayerBuff.action.get,
                set = function(info, value)
                    buffsState.newPlayerBuff.action.set(value)
                end,
            },
            expireAfterNextTurn = {
                order = 5,
                type = "toggle",
                name = "Expire after next turn",
                desc = "This will remove the buff after the next turn. You can always clear buffs manually by right-clicking.",
                hidden = function()
                    local type = buffsState.newPlayerBuff.type.get()
                    return type == PLAYER_BUFF_TYPES.ROLL or type == PLAYER_BUFF_TYPES.DAMAGE_ROLL
                end,
                get = buffsState.newPlayerBuff.expireAfterNextTurn.get,
                set = function(info, value)
                    buffsState.newPlayerBuff.expireAfterNextTurn.set(value)
                end,
            },
            expireAfterAnyAction = {
                order = 6,
                type = "toggle",
                name = "Expire after first action",
                desc = "This will remove the buff when you confirm any action in your turn. This is how most buffs work, so leave this enabled if you're not sure.",
                hidden = function()
                    local type = buffsState.newPlayerBuff.type.get()
                    return type == PLAYER_BUFF_TYPES.ROLL or type == PLAYER_BUFF_TYPES.DAMAGE_ROLL
                end,
                get = buffsState.newPlayerBuff.expireAfterAnyAction.get,
                set = function(info, value)
                    buffsState.newPlayerBuff.expireAfterAnyAction.set(value)
                end,
            },
            add = {
                order = 7,
                type = "execute",
                name = "Add",
                func = function()
                    local newBuff = buffsState.newPlayerBuff
                    local buffType = newBuff.type.get()
                    local expireAfterNextTurn = newBuff.expireAfterNextTurn.get()
                    local expireAfterAnyAction = newBuff.expireAfterAnyAction.get()

                    if buffType == PLAYER_BUFF_TYPES.ROLL then
                        local turnTypeID = newBuff.turnTypeID.get()
                        local amount = newBuff.amount.get()
                        buffs.addRollBuff(turnTypeID, amount)
                    elseif buffType == PLAYER_BUFF_TYPES.DAMAGE_ROLL then
                        local amount = newBuff.amount.get()
                        buffs.addDamageRollBuff(amount)
                    elseif buffType == PLAYER_BUFF_TYPES.STAT then
                        local stat = newBuff.stat.get()
                        local amount = newBuff.amount.get()
                        buffs.addStatBuff(stat, amount, expireAfterNextTurn, expireAfterAnyAction)
                    elseif buffType == PLAYER_BUFF_TYPES.BASE_DMG then
                        local amount = newBuff.amount.get()
                        buffs.addBaseDmgBuff(amount, expireAfterNextTurn, expireAfterAnyAction)
                    elseif buffType == PLAYER_BUFF_TYPES.ADVANTAGE then
                        local action = newBuff.action.get()
                        buffs.addAdvantageBuff(action, expireAfterNextTurn, expireAfterAnyAction)
                    elseif buffType == PLAYER_BUFF_TYPES.DISADVANTAGE then
                        local action = newBuff.action.get()
                        buffs.addDisadvantageDebuff(action, expireAfterNextTurn, expireAfterAnyAction)
                    end
                end
            },
        }
    }
end
