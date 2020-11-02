local _, ns = ...

local bus = ns.bus
local models = ns.models
local party = ns.state.party
local ui = ns.ui

local PartyMember = models.PartyMember

local EVENTS = bus.EVENTS

local state

party.initState = function()
    state = {
        partyMembers = {
--[[             ["Best character"] = PartyMember:New("Best character", 25, 25),
            ["Test character"] = PartyMember:New("Test character", 5, 25),
            ["Zest character"] = PartyMember:New("Zest character", 12, 15), ]]
        },
        numMembers = 0,
    }
end

party.state = {
    partyMembers = {
        list = function()
            return state.partyMembers
        end,
        get = function(name)
            return state.partyMembers[name]
        end,
        getGroupHealthPerc = function()
            if party.state.numMembers.get() == 0 then
                return 100
            end

            local currentHealth = 0
            local maxHealth = 0

            for _, partyMember in pairs(state.partyMembers) do
                currentHealth = currentHealth + partyMember.characterState.health
                maxHealth = maxHealth + partyMember.characterState.maxHealth
            end

            return floor((currentHealth / maxHealth) * 100)
        end,
        add = function(name, initialCharacterStatus)
            TEARollHelper:Debug("party.add", name)

            local currentHealth, maxHealth = initialCharacterStatus.currentHealth, initialCharacterStatus.maxHealth

            state.partyMembers[name] = PartyMember:New(name, currentHealth, maxHealth)
            state.numMembers = state.numMembers + 1

            bus.fire(EVENTS.PARTY_MEMBER_ADDED, name)
        end,
        addOrUpdate = function(name, characterStatus)
            TEARollHelper:Debug("party.addOrUpdate", name, characterStatus:ToString())

            local partyMember = party.state.partyMembers.get(name)
            if not partyMember then
                party.state.partyMembers.add(name, characterStatus)
            else
                partyMember:UpdateHealth(characterStatus.currentHealth, characterStatus.maxHealth)
                bus.fire(EVENTS.PARTY_MEMBER_UPDATED, name)
            end
        end,
        remove = function(name)
            if state.partyMembers[name] then
                state.partyMembers[name] = nil
                state.numMembers = state.numMembers - 1
            end
        end,
        removeMultiple = function(names)
            for name, _ in pairs(names) do
                party.state.partyMembers.remove(name)
            end
        end,
    },
    numMembers = {
        get = function()
            return state.numMembers
        end,
    }
}