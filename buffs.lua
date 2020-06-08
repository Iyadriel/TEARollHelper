local _, ns = ...

local bus = ns.bus
local constants = ns.constants
local characterState = ns.state.character
local rules = ns.rules

local EVENTS = bus.EVENTS
local BUFF_SOURCES = constants.BUFF_SOURCES
local BUFF_TYPES = constants.BUFF_TYPES
local STAT_LABELS = constants.STAT_LABELS

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
        types = { [BUFF_TYPES.STAT] = true },
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
        types = { [BUFF_TYPES.ADVANTAGE] = true },
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
        types = { [BUFF_TYPES.DISADVANTAGE] = true },
        label = label,
        icon = "Interface\\Icons\\achievement_bg_overcome500disadvantage",

        actions = { [action] = true },

        source = BUFF_SOURCES.PLAYER,

        remainingTurns = getRemainingTurns(expireAfterNextTurn),
    })
end

--[[ local function addHoTBuff(label, healingPerTurn, nmTurns)
    if label:trim() == "" then
        label = "Healing"
    end

    addBuff({
        id = "advantage",
        types = { [BUFF_TYPES.HEALING_OVER_TIME] = true },
        label = label,
        icon = "Interface\\Icons\\ability_druid_nourish",

        healingPerTurn = healingPerTurn,

        source = BUFF_SOURCES.PLAYER,

        remainingTurns = remainingTurns,
    })
end ]]

local function addTraitBuff(trait)
    local buff = trait.buff
    if buff then
        local existingBuff = characterState.state.buffLookup.getTraitBuff(trait)
        if existingBuff then
            removeBuff(existingBuff)
        end

        local types = buff.types or {
            [buff.type] = true
        }

        local newBuff = {
            id = "trait_" .. trait.id,
            types = types,
            label = trait.name,
            icon = trait.icon,

            source = BUFF_SOURCES.TRAIT,
            traitID = trait.id,

            canCancel = true
        }

        if types[BUFF_TYPES.STAT] then
            if buff.stats == "custom" then
                newBuff.stats = rules.traits.calculateStatBuff(trait)
            else
                newBuff.stats = buff.stats
            end
        end
        if types[BUFF_TYPES.ADVANTAGE] then
            newBuff.actions = buff.actions or {}
            if buff.turnTypeId then
                newBuff.turnTypeId = buff.turnTypeId
            end
        end

        if buff.remainingTurns then
            newBuff.remainingTurns = buff.remainingTurns
        end

        addBuff(newBuff)
    end
end

local function addWeaknessDebuff(weakness)
    local debuff = weakness.debuff
    if debuff then
        local existingBuff = characterState.state.buffLookup.getWeaknessDebuff(weakness)

        if existingBuff then
            removeBuff(existingBuff)
        end

        local types = debuff.types or {
            [debuff.type] = true
        }

        local buff = {
            id = "weakness_" .. weakness.id,
            types = types,
            label = weakness.name,
            icon = weakness.icon,

            source = BUFF_SOURCES.WEAKNESS,
            weaknessID = weakness.id,

            canCancel = debuff.canCancel,
        }

        if types[BUFF_TYPES.STAT] then
            buff.stats = debuff.stats
        end
        if types[BUFF_TYPES.DISADVANTAGE] then
            buff.actions = debuff.actions or {}
            if debuff.turnTypeId then
                buff.turnTypeId = debuff.turnTypeId
            end
        end

        if debuff.remainingTurns then
            buff.remainingTurns = debuff.remainingTurns
        end

        addBuff(buff)

        bus.fire(EVENTS.WEAKNESS_DEBUFF_ADDED, weakness.id)
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
            types = { [BUFF_TYPES.STAT] = true },
            label = racialTrait.name,
            icon = racialTrait.icon,

            stats = buffs.stats,

            source = BUFF_SOURCES.RACIAL_TRAIT,
            racialTraitID = racialTrait.id,

            canCancel = false
        })
    end
end

ns.buffs.addStatBuff = addStatBuff
ns.buffs.addAdvantageBuff = addAdvantageBuff
ns.buffs.addDisadvantageDebuff = addDisadvantageDebuff
ns.buffs.addTraitBuff = addTraitBuff
ns.buffs.addWeaknessDebuff = addWeaknessDebuff
ns.buffs.addRacialBuff = addRacialBuff