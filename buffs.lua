local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local models = ns.models

local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local EVENTS = bus.EVENTS
local FEAT_BUFF_SPECS = feats.FEAT_BUFF_SPECS
local RACIAL_TRAIT_BUFF_SPECS = racialTraits.RACIAL_TRAIT_BUFF_SPECS
local TRAIT_BUFF_SPECS = traits.TRAIT_BUFF_SPECS
local WEAKNESS_BUFF_SPECS = weaknesses.WEAKNESS_BUFF_SPECS

local FeatBuff = models.FeatBuff
local RacialTraitBuff = models.RacialTraitBuff
local TraitBuff = models.TraitBuff
local WeaknessDebuff = models.WeaknessDebuff

local function addFeatBuff(feat, providedEffects)
    local existingBuff = buffsState.state.buffLookup.getFeatBuff(feat)
    if existingBuff then
        existingBuff:Remove()
    end

    local buffSpec = FEAT_BUFF_SPECS[feat.id]

    local newBuff = FeatBuff:New(
        feat,
        buffSpec.duration,
        providedEffects or buffSpec.effects
    )

    newBuff:Apply()

    -- TODO use model for this
    bus.fire(EVENTS.FEAT_BUFF_ADDED, feat.id)
end

local function addTraitBuff(trait, providedEffects, index)
    if not index then index = 1 end -- most traits only have 1 buff to add

    -- when adding more than one buff, don't remove the previous ones
    if index == 1 then
        local existingBuffs = buffsState.state.buffLookup.getTraitBuffs(trait)
        if existingBuffs then
            for _, existingBuff in pairs(existingBuffs) do
                existingBuff:Remove()
            end
        end
    end

    local buffSpec = TRAIT_BUFF_SPECS[trait.id][index]
    local effects = providedEffects or buffSpec.effects

    local newBuff = TraitBuff:New(
        trait,
        buffSpec.duration,
        effects,
        index
    )

    newBuff:Apply()
end

local function addWeaknessDebuff(weakness, addStacks)
    local buffSpec = WEAKNESS_BUFF_SPECS[weakness.id]

    local existingBuff = buffsState.state.buffLookup.getWeaknessDebuff(weakness)

    if existingBuff then
        if addStacks then
            existingBuff:AddStack()
            return
        else
            existingBuff:Remove()
        end
    end

    local newBuff = WeaknessDebuff:New(
        weakness,
        buffSpec.duration,
        buffSpec.effects,
        buffSpec.canCancel
    )

    newBuff:Apply()

    -- TODO use model for this
    bus.fire(EVENTS.WEAKNESS_DEBUFF_ADDED, weakness.id)
end

local function addRacialBuff(racialTrait)
    local buffSpec = RACIAL_TRAIT_BUFF_SPECS[racialTrait.id]

    local existingBuff = buffsState.state.buffLookup.getRacialBuff()
    if existingBuff then
        existingBuff:Remove()
    end

    local newBuff = RacialTraitBuff:New(
        racialTrait,
        buffSpec.effects
    )

    newBuff:Apply()
end


ns.buffs.addFeatBuff = addFeatBuff
ns.buffs.addTraitBuff = addTraitBuff
ns.buffs.addWeaknessDebuff = addWeaknessDebuff
ns.buffs.addRacialBuff = addRacialBuff