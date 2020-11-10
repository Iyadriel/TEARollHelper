local _, ns = ...

local models = ns.models

local CharacterStatus = {}

function CharacterStatus:New(name, currentHealth, maxHealth, criticalWounds)
    local status = {
        name = name,
        currentHealth = currentHealth,
        maxHealth = maxHealth,
        criticalWounds = criticalWounds,
    }

    setmetatable(status, self)
    self.__index = self

    return status
end

function CharacterStatus:ToString()
    return self.name .. ": " .. self.currentHealth .. "/" .. self.maxHealth
end

models.CharacterStatus = CharacterStatus