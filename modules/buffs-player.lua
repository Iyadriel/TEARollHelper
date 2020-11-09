local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local constants = ns.constants
local models = ns.models

local EVENTS = bus.EVENTS
local STAT_LABELS = constants.STAT_LABELS
local TURN_TYPES = constants.TURN_TYPES

local Buff = models.Buff
local BuffDuration = models.BuffDuration
local BuffEffectAdvantage = models.BuffEffectAdvantage
local BuffEffectBaseDamage = models.BuffEffectBaseDamage
local BuffEffectDisadvantage = models.BuffEffectDisadvantage
local BuffEffectRoll = models.BuffEffectRoll
local BuffEffectStat = models.BuffEffectStat

local STAT_TYPE_ICONS = {
    offence = "Interface\\Icons\\spell_holy_greaterblessingofkings",
    defence = "Interface\\Icons\\spell_magic_greaterblessingofkings",
    spirit = "Interface\\Icons\\spell_holy_greaterblessingofwisdom",
    stamina = "Interface\\Icons\\spell_holy_wordfortitude",
}

local TURN_TYPE_ICONS = {
    [TURN_TYPES.PLAYER.id] = "Interface\\Icons\\spell_nature_lightning",
    [TURN_TYPES.ENEMY.id] = "Interface\\Icons\\spell_holy_powerwordbarrier",
}

local function getRemainingTurns(expireAfterNextTurn)
    if not expireAfterNextTurn then return nil end
    return 1
end

local function getPlayerBuffDuration(expireAfterNextTurn, expireAfterAnyAction)
    return BuffDuration:New({
        remainingTurns = getRemainingTurns(expireAfterNextTurn),
        expireAfterAnyAction = expireAfterAnyAction,
    })
end

local function addRollBuff(turnTypeID, amount, label)
    local existingBuff = buffsState.state.buffLookup.getPlayerRollBuff(turnTypeID)
    if existingBuff then
        existingBuff:Remove()
    end

    local buff = Buff:New(
        "player_roll_" .. turnTypeID,
        label,
        TURN_TYPE_ICONS[turnTypeID],
        BuffDuration:NewWithTurnType({
            turnTypeID = turnTypeID,
            remainingTurns = 0,
            expireAfterAnyAction = true,
        }),
        true,
        { BuffEffectRoll:New(turnTypeID, amount) }
    )

    buff:Apply()

    -- TODO use effect in model instead
    bus.fire(EVENTS.ROLL_BUFF_ADDED, turnTypeID, amount)
end

local function addStatBuff(stat, amount, label, expireAfterNextTurn, expireAfterAnyAction)
    local existingBuff = buffsState.state.buffLookup.getPlayerStatBuff(stat)
    if existingBuff then
        existingBuff:Remove()
    end

    if label:trim() == "" then
        label = STAT_LABELS[stat]
    end

    local buff = Buff:New(
        "player_" .. stat,
        label,
        STAT_TYPE_ICONS[stat],
        getPlayerBuffDuration(expireAfterNextTurn, expireAfterAnyAction),
        true,
        { BuffEffectStat:New(stat, amount) }
    )

    buff:Apply()

    bus.fire(EVENTS.STAT_BUFF_ADDED, stat, amount)
end

local function addBaseDmgBuff(amount, label, expireAfterNextTurn, expireAfterAnyAction)
    local existingBuff = buffsState.state.buffLookup.getPlayerBaseDmgBuff()
    if existingBuff then
        existingBuff:Remove()
    end

    if label:trim() == "" then
        label = "Base damage"
    end

    local buff = Buff:New(
        "player_baseDmg",
        label,
        "Interface\\Icons\\ability_warrior_victoryrush",
        getPlayerBuffDuration(expireAfterNextTurn, expireAfterAnyAction),
        true,
        { BuffEffectBaseDamage:New(amount) }
    )

    buff:Apply()

    -- TODO use effect in model instead
    bus.fire(EVENTS.BASE_DMG_BUFF_ADDED, amount)
end

local function addAdvantageBuff(action, label, expireAfterNextTurn, expireAfterAnyAction)
    local existingBuff = buffsState.state.buffLookup.getPlayerAdvantageBuff(action)
    if existingBuff then
        existingBuff:Remove()
    end

    if label:trim() == "" then
        label = "Advantage"
    end

    local buff = Buff:New(
        "player_advantage_" .. action,
        label,
        "Interface\\Icons\\spell_holy_borrowedtime",
        getPlayerBuffDuration(expireAfterNextTurn, expireAfterAnyAction),
        true,
        { BuffEffectAdvantage:New({ [action] = true }) }
    )

    buff:Apply()
end

local function addDisadvantageDebuff(action, label, expireAfterNextTurn, expireAfterAnyAction)
    local existingBuff = buffsState.state.buffLookup.getPlayerDisadvantageDebuff(action)
    if existingBuff then
        existingBuff:Remove()
    end

    if label:trim() == "" then
        label = "Disadvantage"
    end

    local buff = Buff:New(
        "player_disadvantage_" .. action,
        label,
        "Interface\\Icons\\achievement_bg_overcome500disadvantage",
        getPlayerBuffDuration(expireAfterNextTurn, expireAfterAnyAction),
        true,
        { BuffEffectDisadvantage:New({ [action] = true }) }
    )

    buff:Apply()
end

ns.buffs.addRollBuff = addRollBuff
ns.buffs.addStatBuff = addStatBuff
ns.buffs.addBaseDmgBuff = addBaseDmgBuff
ns.buffs.addAdvantageBuff = addAdvantageBuff
ns.buffs.addDisadvantageDebuff = addDisadvantageDebuff