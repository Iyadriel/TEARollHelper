local _, ns = ...

local actions = ns.actions
local character = ns.character
local rolls = ns.state.rolls
local turns = ns.turns

local state = {
    racialTrait = nil,

    attack = {
        threshold = 12,
        numBloodHarvestSlots = 0,
    },
    heal = {
        numGreaterHealSlots = 0,
        mercyFromPainBonusHealing = 0,
    },
    defend = {
        defendThreshold = 10,
        damageRisk = 4,
    },
    utility = {
        useUtilityTrait = false
    }
}

local function getDefence()
    local defence = character.getPlayerDefence()
    local buff = turns.getCurrentBuffs().defence
    local values = turns.getCurrentTurnValues()
    local racialTrait = state.racialTrait
    local defence = actions.getDefence(values.roll, values.defendThreshold, values.damageRisk, defence, buff, racialTrait)

    return defence
end

local function getMeleeSave()
    local defence = character.getPlayerDefence()
    local buff = turns.getCurrentBuffs().defence
    local values = turns.getCurrentTurnValues()
    local racialTrait = state.racialTrait
    local save = actions.getMeleeSave(values.roll, values.defendThreshold, values.damageRisk, defence, buff, racialTrait)

    return save
end

rolls.state = state
rolls.getDefence = getDefence
rolls.getMeleeSave = getMeleeSave