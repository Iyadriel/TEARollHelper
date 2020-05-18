local _, ns = ...

local actions = ns.actions
local character = ns.character
local characterState = ns.state.character.state
local rolls = ns.state.rolls
local turns = ns.turns

local state = {
    racialTrait = nil,

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
    },

    utility = {
        useUtilityTrait = false
    }
}

local function getAttack()
    local offence = character.getPlayerOffence()
    local buff = characterState.buffs.offence.get()
    local values = turns.getCurrentTurnValues()
    local threshold = state.attack.threshold
    local numBloodHarvestSlots = state.attack.numBloodHarvestSlots

    return actions.getAttack(values.roll, threshold, offence, buff, numBloodHarvestSlots)
end

local function getHealing(outOfCombat)
    local spirit = character.getPlayerSpirit()
    local buff = characterState.buffs.spirit.get()

    return actions.getHealing(turns.getCurrentTurnValues().roll, spirit, buff, state.healing.numGreaterHealSlots, state.healing.mercyFromPainBonusHealing, outOfCombat)
end

local function getBuff()
    local spirit = character.getPlayerSpirit()
    local offence = character.getPlayerOffence()
    local offenceBuff = characterState.buffs.offence.get()
    local spiritBuff = characterState.buffs.spirit.get()

    return actions.getBuff(turns.getCurrentTurnValues().roll, spirit, spiritBuff, offence, offenceBuff)
end

local function getDefence()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()
    local values = turns.getCurrentTurnValues()
    local racialTrait = state.racialTrait

    return actions.getDefence(values.roll, state.defend.threshold, state.defend.damageRisk, defence, buff, racialTrait)
end

local function getMeleeSave()
    local defence = character.getPlayerDefence()
    local buff = characterState.buffs.defence.get()
    local values = turns.getCurrentTurnValues()
    local racialTrait = state.racialTrait

    return actions.getMeleeSave(values.roll, state.defend.threshold, state.defend.damageRisk, defence, buff, racialTrait)
end

local function getRangedSave()
    local spirit = character.getPlayerSpirit()
    local values = turns.getCurrentTurnValues()
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