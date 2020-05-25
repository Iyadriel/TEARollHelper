local _, ns = ...

local actions = ns.actions
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character.state
local feats = ns.resources.feats
local rolls = ns.state.rolls
local traits = ns.resources.traits
local turns = ns.turns

local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local state = {
    attack = {
        threshold = 12,
        numBloodHarvestSlots = 0,
    },

    healing = {
        numGreaterHealSlots = 0,
        mercyFromPainBonusHealing = 0,
    },

    defend = {
        threshold = 10,
        damageRisk = 4,
        useBulwark = false,
    },

    utility = {
        useUtilityTrait = false
    }
}

local function resetSlots()
    state.attack.numBloodHarvestSlots = 0
    state.healing.numGreaterHealSlots = 0
    state.healing.mercyFromPainBonusHealing = 0
    state.defend.useBulwark = false
end

bus.addListener(EVENTS.CHARACTER_STAT_CHANGED, resetSlots)
bus.addListener(EVENTS.FEAT_CHANGED, resetSlots)
bus.addListener(EVENTS.TRAITS_CHANGED, resetSlots)
bus.addListener(EVENTS.TURN_CHANGED, resetSlots)

bus.addListener(EVENTS.FEAT_CHARGES_CHANGED, function(featID, numCharges)
    if featID == FEATS.BLOOD_HARVEST.id and numCharges < state.attack.numBloodHarvestSlots then
        state.attack.numBloodHarvestSlots = numCharges
    end
end)
bus.addListener(EVENTS.GREATER_HEAL_CHARGES_CHANGED, function(numCharges)
    if numCharges < state.healing.numGreaterHealSlots then
        state.healing.numGreaterHealSlots = numCharges
    end
end)

bus.addListener(EVENTS.TRAIT_CHARGES_CHANGED, function(traitID, numCharges)
    if traitID == TRAITS.BULWARK.id and numCharges == 0 then
        state.defend.useBulwark = false
    end
end)

local function getAttack()
    local offence = character.getPlayerOffence()
    local buff = characterState.buffs.offence.get()
    local values = turns.getRollValues()
    local threshold = state.attack.threshold
    local numBloodHarvestSlots = state.attack.numBloodHarvestSlots
    local numVindicationCharges = characterState.featsAndTraits.numVindicationCharges.get()

    return actions.getAttack(values.roll, values.rollIsCrit, threshold, offence, buff, numBloodHarvestSlots, numVindicationCharges)
end

local function getHealing(outOfCombat)
    local spirit = character.getPlayerSpirit()
    local buff = characterState.buffs.spirit.get()
    local values = turns.getRollValues()

    return actions.getHealing(values.roll, values.rollIsCrit, spirit, buff, state.healing.numGreaterHealSlots, state.healing.mercyFromPainBonusHealing, outOfCombat)
end

local function getBuff()
    local spirit = character.getPlayerSpirit()
    local offence = character.getPlayerOffence()
    local offenceBuff = characterState.buffs.offence.get()
    local spiritBuff = characterState.buffs.spirit.get()
    local values = turns.getRollValues()

    return actions.getBuff(values.roll, values.rollIsCrit, spirit, spiritBuff, offence, offenceBuff)
end

local function getDefence()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()
    local values = turns.getRollValues()
    local useBulwark = state.defend.useBulwark
    local racialTrait = characterState.featsAndTraits.racialTrait.get()

    return actions.getDefence(values.roll, values.rollIsCrit, state.defend.threshold, state.defend.damageRisk, defence, buff, useBulwark, racialTrait)
end

local function getMeleeSave()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()
    local values = turns.getRollValues()
    local racialTrait = characterState.featsAndTraits.racialTrait.get()

    return actions.getMeleeSave(values.roll, state.defend.threshold, state.defend.damageRisk, defence, buff, racialTrait)
end

local function getRangedSave()
    local spirit = character.getPlayerSpirit()
    local values = turns.getRollValues()
    local buff = characterState.buffs.spirit.get()

    return actions.getRangedSave(values.roll, state.defend.threshold, state.defend.damageRisk, spirit, buff)
end

rolls.state = state
rolls.getAttack = getAttack
rolls.getHealing = getHealing
rolls.getBuff = getBuff
rolls.getDefence = getDefence
rolls.getMeleeSave = getMeleeSave
rolls.getRangedSave = getRangedSave