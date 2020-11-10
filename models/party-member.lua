local _, ns = ...

local models = ns.models
local utils = ns.utils

local criticalWounds = ns.resources.criticalWounds

local PartyMember = {}

function PartyMember:New(name, currentHealth, maxHealth, criticalWounds)
    local status = {
        name = name,
        characterState = {
            health = currentHealth,
            maxHealth = maxHealth,
            criticalWounds = criticalWounds or {},
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

function PartyMember:UpdateCriticalWounds(criticalWounds)
    if criticalWounds then
        self.characterState.criticalWounds = criticalWounds
    end
end

function PartyMember:ToString()
    local cur, max = self.characterState.health, self.characterState.maxHealth
    local msg = {
        utils.formatPlayerName(self.name),
        ": ",
        utils.healthColor(cur, max),
        utils.formatHealth(cur, max),
        "|r",
    }

    local hasCW = false
    for id in pairs(self.characterState.criticalWounds) do
        hasCW = true
        break
    end

    if hasCW then
        table.insert(msg, " (")

        for id in pairs(self.characterState.criticalWounds) do
            table.insert(msg, criticalWounds.getName(id))
            table.insert(msg, ", ")
        end

        table.remove(msg)

        table.insert(msg, ")")
    end

    return table.concat(msg)
end

models.PartyMember = PartyMember