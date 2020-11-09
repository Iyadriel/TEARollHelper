local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffsState = ns.state.buffs.state
local constants = ns.constants
local ui = ns.ui

local TURN_TYPES = constants.TURN_TYPES

local imageCoords = {.08, .92, .08, .92}

local function getBuff(index)
    return buffsState.activeBuffs.get()[index]
end

local function buffDesc(buff)
    local msg = {
        buff:GetTooltip()
    }

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

            if buff.numStacks > 1 then
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