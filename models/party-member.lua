local _, ns = ...

local models = ns.models

local PartyMember = {}

function PartyMember:New(name, currentHealth, maxHealth)
    local status = {
        name = name,
        characterState = {
            health = currentHealth,
            maxHealth = maxHealth,
        },
    }

    setmetatable(status, self)
    self.__index = self

    return status
end

function PartyMember:UpdateHealth(currentHealth, maxHealth)
    TEARollHelper:Debug("Updating member", self.name)
    self.characterState.health = currentHealth
    self.characterState.maxHealth = maxHealth
end

function PartyMember:ToString()
    return self.name .. ": " ..     self.characterState.health .. "/" .. self.characterState.maxHealth
end

models.PartyMember = PartyMember