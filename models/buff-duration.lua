local _, ns = ...

local constants = ns.constants
local models = ns.models

local TURN_TYPES = constants.TURN_TYPES

local BuffDuration = {}

function BuffDuration:NewInternal(turnTypeID, remainingTurns, expireAfterActions, expireAfterAnyAction, expireOnCombatEnd)
    local buffDuration = {
        turnTypeID = turnTypeID, -- can be nil
        remainingTurns = remainingTurns, -- can be nil, represents remaining turns of turnTypeID or remaining any turns
        expireAfterActions = expireAfterActions or {},
        expireAfterAnyAction = false,
        expireOnCombatEnd = false,
    }

    if expireAfterAnyAction ~= nil then
        buffDuration.expireAfterAnyAction = expireAfterAnyAction
    end

    if expireOnCombatEnd ~= nil then
        buffDuration.expireOnCombatEnd = expireOnCombatEnd
    end

    setmetatable(buffDuration, self)
    self.__index = self

    return buffDuration
end

function BuffDuration:New(obj)
    assert(obj.turnTypeID == nil)

    return BuffDuration:NewInternal(
        nil,
        obj.remainingTurns,
        obj.expireAfterActions,
        obj.expireAfterAnyAction,
        obj.expireOnCombatEnd
    )
end

function BuffDuration:NewWithTurnType(obj)
    assert(obj.turnTypeID ~= nil)

    return BuffDuration:NewInternal(
        obj.turnTypeID,
        obj.remainingTurns,
        obj.expireAfterActions,
        obj.expireAfterAnyAction,
        obj.expireOnCombatEnd
    )
end

function BuffDuration:GetRemainingTurns()
    return self.remainingTurns
end

function BuffDuration:ExpiresAfterAnyAction()
    return self.expireAfterAnyAction
end

function BuffDuration:ExpiresAfterAction(action)
    return self.expireAfterActions[action]
end

function BuffDuration:ExpiresOnCombatEnd()
    return self.expireOnCombatEnd
end

function BuffDuration:ShouldExpire(turnTypeID)
    if self.remainingTurns ~= nil and (self.turnTypeID == nil or self.turnTypeID == turnTypeID) then
        return self.remainingTurns <= 0
    end
    return false
end

function BuffDuration:DecrementRemainingTurns(turnTypeID)
    if self.remainingTurns ~= nil and (self.turnTypeID == nil or self.turnTypeID == turnTypeID) then
        self.remainingTurns = self.remainingTurns - 1
    end
end

function BuffDuration:GetTooltipText()
    local msg = {}

    if self.remainingTurns ~= nil then
        if self.turnTypeID ~= nil then
            if self.turnTypeID == TURN_TYPES.PLAYER.id then
                table.insert(msg, "|nRemaining " .. TURN_TYPES.PLAYER.name .. " turns: " .. self.remainingTurns)
            elseif self.turnTypeID == TURN_TYPES.ENEMY.id then
                table.insert(msg, "|nRemaining " .. TURN_TYPES.ENEMY.name .. " turns: " .. self.remainingTurns)
            end
        else
            table.insert(msg, "|nRemaining turns: " .. self.remainingTurns)
        end
    end

    if self:ExpiresAfterAnyAction() then
        table.insert(msg, "|nLasts for 1 action")
    end

    if self:ExpiresOnCombatEnd() then
        table.insert(msg, "|nLasts until end of combat")
    end

    return table.concat(msg)
end

models.BuffDuration = BuffDuration