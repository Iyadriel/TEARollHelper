local _, ns = ...

local bus = ns.bus
local constants = ns.constants
local characterState = ns.state.character

local EVENTS = bus.EVENTS
local BUFF_TYPES = constants.BUFF_TYPES
local STAT_LABELS = constants.STAT_LABELS

local BUFF_SOURCES = {
    PLAYER = "Player",
    WEAKNESS = "Weakness",
    RACIAL_TRAIT = "Racial Trait",
}

local STAT_TYPE_ICONS = {
    offence = "Interface\\Icons\\spell_holy_greaterblessingofkings",
    defence = "Interface\\Icons\\spell_magic_greaterblessingofkings",
    spirit = "Interface\\Icons\\spell_holy_greaterblessingofwisdom",
    stamina = "Interface\\Icons\\spell_holy_wordfortitude",
}

local function addBuff(buff)
    characterState.state.activeBuffs.add(buff)
end

local function removeBuff(buff)
    characterState.state.activeBuffs.remove(buff)
end

local function getRemainingTurns(expireAfterNextTurn)
    if not expireAfterNextTurn then return nil end
    return 1
end

local function addStatBuff(stat, amount, label, expireAfterNextTurn)
    local existingBuff = characterState.state.buffLookup.getPlayerStatBuff(stat)

    if existingBuff then
        removeBuff(existingBuff)
    end

    if label:trim() == "" then
        label = STAT_LABELS[stat]
    end

    addBuff({
        id = "player_" .. stat,
        type = BUFF_TYPES.STAT,
        label = label,
        icon = STAT_TYPE_ICONS[stat],

        stats = {
            [stat] = amount
        },

        source = BUFF_SOURCES.PLAYER,

        remainingTurns = getRemainingTurns(expireAfterNextTurn),
    })

    bus.fire(EVENTS.STAT_BUFF_ADDED, stat, amount)
end

local function addAdvantageBuff(action, label, expireAfterNextTurn)
    local existingBuff = characterState.state.buffLookup.getPlayerAdvantageBuff(action)

    if existingBuff then
        removeBuff(existingBuff)
    end

    if label:trim() == "" then
        label = "Advantage"
    end

    addBuff({
        id = "player_advantage_" .. action,
        type = BUFF_TYPES.ADVANTAGE,
        label = label,
        icon = "Interface\\Icons\\spell_holy_borrowedtime",

        actions = { [action] = true },

        source = BUFF_SOURCES.PLAYER,

        remainingTurns = getRemainingTurns(expireAfterNextTurn),
    })
end

local function addDisadvantageDebuff(action, label, expireAfterNextTurn)
    local existingBuff = characterState.state.buffLookup.getPlayerDisadvantageDebuff(action)

    if existingBuff then
        removeBuff(existingBuff)
    end

    if label:trim() == "" then
        label = "Disadvantage"
    end

    addBuff({
        id = "player_disadvantage_" .. action,
        type = BUFF_TYPES.DISADVANTAGE,
        label = label,
        icon = "Interface\\Icons\\achievement_bg_overcome500disadvantage",

        actions = { [action] = true },

        source = BUFF_SOURCES.PLAYER,

        remainingTurns = getRemainingTurns(expireAfterNextTurn),
    })
end

local function addWeaknessDebuff(weakness)
    local debuff = weakness.debuff
    if debuff then
        local existingBuff = characterState.state.buffLookup.getWeaknessDebuff(weakness)

        if existingBuff then
            removeBuff(existingBuff)
        end

        local buff = {
            id = "weakness_" .. weakness.id,
            type = debuff.type,
            label = weakness.name,
            icon = weakness.icon,

            source = BUFF_SOURCES.WEAKNESS,
            weaknessID = weakness.id,

            canCancel = false
        }

        if debuff.type == BUFF_TYPES.STAT then
            buff.stats = debuff.stats
        elseif debuff.type == BUFF_TYPES.DISADVANTAGE then
            buff.actions = debuff.actions or {}
            if debuff.turnTypeId then
                buff.turnTypeId = debuff.turnTypeId
            end
        end

        if debuff.remainingTurns then
            buff.remainingTurns = debuff.remainingTurns
        end

        addBuff(buff)
    end
end

local function addRacialBuff(racialTrait)
    local buffs = racialTrait.buffs
    if buffs and buffs.stats then
        local existingBuff = characterState.state.buffLookup.getRacialBuff()
        if existingBuff then
            removeBuff(existingBuff)
        end

        addBuff({
            id = "racial",
            type = BUFF_TYPES.STAT,
            label = racialTrait.name,
            icon = racialTrait.icon,

            stats = buffs.stats,

            source = BUFF_SOURCES.RACIAL_TRAIT,
            racialTraitID = racialTrait.id,

            canCancel = false
        })
    end
end

ns.buffs.BUFF_SOURCES = BUFF_SOURCES
ns.buffs.addStatBuff = addStatBuff
ns.buffs.addAdvantageBuff = addAdvantageBuff
ns.buffs.addDisadvantageDebuff = addDisadvantageDebuff
ns.buffs.addWeaknessDebuff = addWeaknessDebuff
ns.buffs.addRacialBuff = addRacialBuff