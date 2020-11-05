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
    local msg = {}

    if buff.GetTooltip then
        table.insert(msg, buff:GetTooltip())
    else -- TODO remove legacy
        table.insert(msg, " |n")

        if buff.types[BUFF_TYPES.ROLL] then
            table.insert(msg, valueIncDecText("Roll", buff.amount))
        end

        if buff.types[BUFF_TYPES.STAT] then
            for stat, amount in pairs(buff.stats) do
                table.insert(msg, valueIncDecText(STAT_LABELS[stat], amount))
            end
        end

        if buff.types[BUFF_TYPES.BASE_DMG] then
            table.insert(msg, valueIncDecText("Base damage", buff.amount))
        end

        if buff.types[BUFF_TYPES.ADVANTAGE] then
            table.insert(msg, "Your rolls have advantage.|nApplies to: ")
            if buff.turnTypeId then
                table.insert(msg, TURN_TYPES[buff.turnTypeId].name .. " turn, ")
            end
            for action in pairs(buff.actions) do
                table.insert(msg,  ACTION_LABELS[action] .. ", ")
            end
            msg = string.sub(msg, 0, -3)
        elseif buff.types[BUFF_TYPES.DISADVANTAGE] then
            table.insert(msg, "Your rolls have disadvantage.|nApplies to: ")
            if buff.turnTypeId then
                table.insert(msg, TURN_TYPES[buff.turnTypeId].name .. " turn, ")
            end
            for action in pairs(buff.actions) do
                table.insert(msg,  ACTION_LABELS[action] .. ", ")
            end
            msg = string.sub(msg, 0, -3)
        end

        if buff.types[BUFF_TYPES.HEALING_OVER_TIME] then
            table.insert(msg, "Healing for " .. buff.healingPerTick .. " at the start of every turn.")
        elseif buff.types[BUFF_TYPES.DAMAGE_OVER_TIME] then
            table.insert(msg, "Taking " .. buff.damagePerTick .. " damage at the start of every turn.")
        end

        if buff.types[BUFF_TYPES.MAX_HEALTH] then
            table.insert(msg, valueIncDecText("Maximum health", buff.amount))
        end

        if buff.types[BUFF_TYPES.HEALING_DONE] then
            table.insert(msg, valueIncDecText("Healing done", buff.amount))
        end

        if buff.types[BUFF_TYPES.DAMAGE_TAKEN] then
            table.insert(msg, valueIncDecText("Damage taken", buff.amount))
        end

        if buff.types[BUFF_TYPES.DAMAGE_DONE] then
            table.insert(msg, valueIncDecText("Damage done", buff.amount))
        end

        if buff.types[BUFF_TYPES.UTILITY_BONUS] then
            table.insert(msg, valueIncDecText("Utility trait", buff.amount))
        end
    end

    local duration = buff.duration

    if duration.remainingTurns then
        if type(duration.remainingTurns) == "table" then
            local remainingPlayerTurns = duration.remainingTurns[TURN_TYPES.PLAYER.id]
            local remainingEnemyTurns = duration.remainingTurns[TURN_TYPES.ENEMY.id]
            if remainingPlayerTurns then
                table.insert(msg, COLOURS.NOTE .. "|nRemaining " .. TURN_TYPES.PLAYER.name .. " turns: " .. remainingPlayerTurns)
            elseif remainingEnemyTurns then
                table.insert(msg, COLOURS.NOTE .. "|nRemaining " .. TURN_TYPES.ENEMY.name .. " turns: " .. remainingEnemyTurns)
            end
        else
            table.insert(msg, COLOURS.NOTE .. "|nRemaining turns: " .. duration.remainingTurns)
        end
    end

    if duration.expireAfterFirstAction then
        table.insert(msg, COLOURS.NOTE .. "|nLasts for 1 action")
    end
    if duration.expireOnCombatEnd then
        table.insert(msg, COLOURS.NOTE .. "|nLasts until end of combat")
    end

    --table.insert(msg, COLOURS.NOTE .. "|n|nSource: " .. buff.source)

    return table.concat(msg)
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

            -- TODO: all new buffs have numStacks
            if buff.numStacks and buff.numStacks > 1 then
                msg = msg .. " (" .. buff.numStacks .. ")"
            end

            return msg
        end,
        func = function()
            local buff = getBuff(index)
            if buff.canCancel then
                buff:Cancel()
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