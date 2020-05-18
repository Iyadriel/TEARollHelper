local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local events = ns.events
local rules = ns.rules
local turns = ns.turns

local ROLL_MODES = {
    DISADVANTAGE = -1,
    NORMAL = 0,
    ADVANTAGE = 1
}

local ROLL_MODE_LABELS = {
    [ROLL_MODES.DISADVANTAGE] = "Disadvantage",
    [ROLL_MODES.NORMAL] = "Normal",
    [ROLL_MODES.ADVANTAGE] = "Advantage"
}

local BUFF_TYPES = {
    OFFENCE = "offence",
    DEFENCE = "defence",
    SPIRIT = "spirit"
}

local isRolling, setCurrentRoll, getCurrentTurnValues, handleRollResult
local getRollMode, setRollMode
local setAttackValues, getNumGreaterHealSlots, setNumGreaterHealSlots, setDefendValues
local roll
local getCurrentBuffs, setCurrentBuff, clearCurrentBuffs

-- TODO: clean this up and move to state/rolls.lua module
local currentTurnValues = {
    isRolling = false,
    roll = 1,
    rollMode = ROLL_MODES.NORMAL,
    totalRequiredRolls = 1,
    remainingRolls = 1,

    attackThreshold = 12,
    numBloodHarvestSlots = 0,

    numGreaterHealSlots = 0,
    mercyFromPainBonusHealing = 0,

    defendThreshold = 10,
    damageRisk = 4,

    utility = {
        useUtilityTrait = false
    }
}

local currentBuffs = {
    [BUFF_TYPES.OFFENCE] = 0,
    [BUFF_TYPES.DEFENCE] = 0,
    [BUFF_TYPES.SPIRIT] = 0
}

local function notifyChange()
    AceConfigRegistry:NotifyChange("TEARollHelperRolls")
end

function isRolling()
    return currentTurnValues.isRolling
end

function setCurrentRoll(roll)
    currentTurnValues.roll = roll
end

function getCurrentTurnValues()
    return currentTurnValues
end

function getRollMode()
    return currentTurnValues.rollMode
end

function setRollMode(mode)
    currentTurnValues.rollMode = mode
end

function setAttackValues(attackThreshold)
    currentTurnValues.attackThreshold = attackThreshold
end

local function getNumBloodHarvestSlots()
    return currentTurnValues.numBloodHarvestSlots
end

local function setNumBloodHarvestSlots(numBloodHarvestSlots)
    currentTurnValues.numBloodHarvestSlots = numBloodHarvestSlots
end

function getNumGreaterHealSlots()
    return currentTurnValues.numGreaterHealSlots
end

function setNumGreaterHealSlots(numGreaterHealSlots)
    currentTurnValues.numGreaterHealSlots = numGreaterHealSlots
end

local function getMercyFromPainBonusHealing()
    return currentTurnValues.mercyFromPainBonusHealing
end

local function setMercyFromPainBonusHealing(mercyFromPainBonusHealing)
    currentTurnValues.mercyFromPainBonusHealing = mercyFromPainBonusHealing
end

function setDefendValues(defendThreshold, damageRisk)
    if defendThreshold ~= nil then
        currentTurnValues.defendThreshold = defendThreshold
    end
    if damageRisk ~= nil then
        currentTurnValues.damageRisk = damageRisk
    end
end

local function getUseUtilityTrait()
    return currentTurnValues.utility.useUtilityTrait
end

local function setUseUtilityTrait(useUtilityTrait)
    currentTurnValues.utility.useUtilityTrait = useUtilityTrait
end


local function sendRoll()
    events.listenForRolls()
    RandomRoll(1, rules.core.MAX_ROLL)
end

function roll()
    currentTurnValues.isRolling = true
    notifyChange() -- so we can update the button state

    local numRolls

    if getRollMode() == ROLL_MODES.NORMAL then
        numRolls = 1
    else
        numRolls = 2
    end

    currentTurnValues.totalRequiredRolls = numRolls
    currentTurnValues.remainingRolls = numRolls

    sendRoll()
end

function handleRollResult(result)
    local rollMode = getRollMode()

    if
        (currentTurnValues.remainingRolls == currentTurnValues.totalRequiredRolls) or
        (rollMode == ROLL_MODES.ADVANTAGE and result > currentTurnValues.roll) or
        (rollMode == ROLL_MODES.DISADVANTAGE and result < currentTurnValues.roll) then
        setCurrentRoll(result)
    end

    currentTurnValues.remainingRolls = currentTurnValues.remainingRolls - 1

    if currentTurnValues.remainingRolls > 0 then
        sendRoll()
    else
        currentTurnValues.isRolling = false
        notifyChange()
    end
end

function getCurrentBuffs()
    return {
        [BUFF_TYPES.OFFENCE] = currentBuffs[BUFF_TYPES.OFFENCE],
        [BUFF_TYPES.DEFENCE] = currentBuffs[BUFF_TYPES.DEFENCE],
        [BUFF_TYPES.SPIRIT] = currentBuffs[BUFF_TYPES.SPIRIT],
    }
end

function setCurrentBuff(buffType, amount)
    currentBuffs[buffType] = amount
    notifyChange()
end

function clearCurrentBuffs()
    setCurrentBuff(BUFF_TYPES.OFFENCE, 0)
    setCurrentBuff(BUFF_TYPES.DEFENCE, 0)
    setCurrentBuff(BUFF_TYPES.SPIRIT, 0)
    notifyChange()
end

turns.ROLL_MODE_LABELS = ROLL_MODE_LABELS
turns.BUFF_TYPES = BUFF_TYPES

turns.getCurrentTurnValues = getCurrentTurnValues

turns.isRolling = isRolling
turns.setCurrentRoll = setCurrentRoll
turns.getRollMode = getRollMode
turns.setRollMode = setRollMode

turns.setAttackValues = setAttackValues
turns.getNumGreaterHealSlots = getNumGreaterHealSlots
turns.setNumGreaterHealSlots = setNumGreaterHealSlots
turns.getMercyFromPainBonusHealing = getMercyFromPainBonusHealing
turns.setMercyFromPainBonusHealing = setMercyFromPainBonusHealing
turns.getNumBloodHarvestSlots = getNumBloodHarvestSlots
turns.setNumBloodHarvestSlots = setNumBloodHarvestSlots

turns.setDefendValues = setDefendValues

turns.utility = {
    getUseUtilityTrait = getUseUtilityTrait,
    setUseUtilityTrait = setUseUtilityTrait
}

turns.roll = roll
turns.handleRollResult = handleRollResult

turns.getCurrentBuffs = getCurrentBuffs
turns.setCurrentBuff = setCurrentBuff
turns.clearCurrentBuffs = clearCurrentBuffs