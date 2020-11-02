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
        partyMembers = {},
    }
end

party.state = {
    partyMembers = {
        list = function()
            return state.partyMembers
        end,
        count = function()
            return #state.partyMembers
        end,
        get = function(name)
            return state.partyMembers[name]
        end,
        add = function(name, initialCharacterStatus)
            TEARollHelper:Debug("party.add", name)

            local currentHealth, maxHealth = initialCharacterStatus.currentHealth, initialCharacterStatus.maxHealth

            state.partyMembers[name] = PartyMember:New(name, currentHealth, maxHealth)

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
    },
}