local _, ns = ...

local characterState = ns.state.character
local models = ns.models

local Trait = {}

function Trait:NewFromObj(obj)
    local trait = obj

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function Trait:New(id, name, desc, icon, numCharges)
    local trait = {
        id = id,
        name = name,
        desc = desc,
        icon = icon,
        numCharges = numCharges,
    }

    return Trait:NewFromObj(trait)
end

function Trait:UseCharge()
    local traitGetSet = characterState.state.featsAndTraits.numTraitCharges
    traitGetSet.set(self.id, traitGetSet.get(self.id) - 1)
end

-- implemented by traits that are enabled as part of an action
-- returns msg to include in action msg
function Trait:GetActionText()
    return ""
end

-- implemented by traits that use a button to activate
-- optionally returns a msg on activation
function Trait:Activate()
    return nil
end

-- implemented by traits that create a buff object
function Trait:CreateBuff()
    return nil
end

models.Trait = Trait