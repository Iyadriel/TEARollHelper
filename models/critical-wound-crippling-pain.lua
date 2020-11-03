local _, ns = ...

local constants = ns.constants
local models = ns.models

local ACTIONS = constants.ACTIONS

local CriticalWound = models.CriticalWound
local CriticalWoundCripplingPain = CriticalWound:NewFromObj({})

function CriticalWoundCripplingPain:New(...)
    local wound = CriticalWound:New(...)

    wound.unavailableAction = ACTIONS.buff

    setmetatable(wound, self)
    self.__index = self

    return wound
end

function CriticalWoundCripplingPain:GetUnavailableAction()
    return self.unavailableAction
end

function CriticalWoundCripplingPain:SetUnavailableAction(action)
    self.unavailableAction = action
end

models.CriticalWoundCripplingPain = CriticalWoundCripplingPain