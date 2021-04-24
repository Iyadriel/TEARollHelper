local _, ns = ...

local characterState = ns.state.character
local models = ns.models
local rollsState = ns.state.rolls

local Trait = models.Trait
local RetaliateAndDecimate = Trait:NewFromObj({})

function RetaliateAndDecimate:New()
    -- Base Trait object
    local trait = Trait:New(
        "RETALIATE_AND_DECIMATE",
        "Retaliate and Decimate",
        "When tasked with defending against an enemy attack towards yourself, you can choose to instead activate this trait to take the full damage of the attack and then immediately deal the same damage back to the attacker. Activate instead of rolling.",
        "Interface\\Icons\\warrior_talent_icon_innerrage",
        3
    )

    setmetatable(trait, self)
    self.__index = self

    return trait
end

function RetaliateAndDecimate:Activate()
    local dmgRisk = rollsState.state.defend.damageRisk.get()
    if dmgRisk == nil then return end -- Shouldn't happen but just in case

    self:UseCharge()
    characterState.state.health.damage(dmgRisk)
    return TEARollHelper.COLOURS.TRAITS.GENERIC .. "You deal " .. dmgRisk .. " damage back to your attacker!|r"
end

models.RetaliateAndDecimate = RetaliateAndDecimate
