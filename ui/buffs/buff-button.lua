local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffsState = ns.state.buffs.state
local ui = ns.ui

local imageCoords = {.08, .92, .08, .92}

local function getBuff(index)
    return buffsState.activeBuffs.get()[index]
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

            local msg = buff.label

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

            return buff:GetTooltip()
        end,
        dialogControl = "TEABuffButton"
    }
end