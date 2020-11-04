local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffsState = ns.state.buffs.state
local constants = ns.constants
local ui = ns.ui

local ACTION_LABELS = constants.ACTION_LABELS
local BUFF_TYPES = constants.BUFF_TYPES
local STAT_LABELS = constants.STAT_LABELS
local TURN_TYPES = constants.TURN_TYPES

local imageCoords = {.08, .92, .08, .92}

local function getBuff(index)
    return buffsState.activeBuffs.get()[index]
end

local function valueIncDecText(msgStart, value)
    if value > 0 then
        return msgStart .. " increased by " .. value .. ". "
    else
        return msgStart .. " reduced by " .. abs(value) .. ". "
    end
end

local function buffDesc(buff)
    local msg = " |n"

    if buff.types[BUFF_TYPES.STAT] then
        for stat, amount in pairs(buff.stats) do
            msg = msg .. valueIncDecText(STAT_LABELS[stat], amount)
        end
    end

    if buff.types[BUFF_TYPES.BASE_DMG] then
        msg = msg .. valueIncDecText("Base damage", buff.amount)
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
    elseif buff.types[BUFF_TYPES.DAMAGE_OVER_TIME] then
        msg = msg .. "Taking " .. buff.damagePerTick .. " damage at the start of every turn."
    end

    if buff.types[BUFF_TYPES.MAX_HEALTH] then
        msg = msg .. valueIncDecText("Maximum health", buff.amount)
    end

    if buff.types[BUFF_TYPES.HEALING_DONE] then
        msg = msg .. valueIncDecText("Healing done", buff.amount)
    end

    if buff.types[BUFF_TYPES.DAMAGE_TAKEN] then
        msg = msg .. valueIncDecText("Damage taken", buff.amount)
    end

    if buff.types[BUFF_TYPES.DAMAGE_DONE] then
        msg = msg .. valueIncDecText("Damage done", buff.amount)
    end

    if buff.types[BUFF_TYPES.UTILITY_BONUS] then
        msg = msg .. valueIncDecText("Utility trait", buff.amount)
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
end

ui.modules.buffs.modules.buffButton.getOption = function(index)
    return {
        order = index,
        type = "execute",
        width = 0.5,
        hidden = function()
            return not getBuff(index)
        end,
        image = function()
            local buff = getBuff(index)
            return buff and buff.icon or ""
        end,
        imageCoords = imageCoords,
        name = function()
            local buff = getBuff(index)
            if not buff then return "" end

            local msg = (buff.colour or "|cffffffff") .. buff.label

            if buff.stacks and buff.stacks > 1 then
                msg = msg .. " (" .. buff.stacks .. ")"
            end

            return msg
        end,
        func = function()
            local buff = getBuff(index)
            if buff.canCancel then
                buffsState.activeBuffs.cancel(index)
            end
        end,
        desc = function()
            local buff = getBuff(index)
            if not buff then return "" end

            return buffDesc(buff)
        end,
        dialogControl = "TEABuffButton"
    }
end