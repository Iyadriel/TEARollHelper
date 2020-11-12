local _, ns = ...

local models = ns.models

local Unit = {}

function Unit:New(unitIndex, name)
    local unit = {
        unitIndex = unitIndex,
        name = name,
    }

    setmetatable(unit, self)
    self.__index = self

    return unit
end

function Unit:GetName()
    return self.name
end

function Unit:SetName(name)
    self.name = name
end

models.Unit = Unit