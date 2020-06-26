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

local function shallowCopy(table)
    local copy = {}
    for k, v in pairs(table) do
        copy[k] = v
    end
    return copy
end

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

local function addHoTBuff(label, icon, healingPerTick, remainingTurns)
    if label:trim() == "" then
        label = "Healing"
    end

    if type(remainingTurns) == "table" then
        remainingTurns = shallowCopy(remainingTurns)
    end

    addBuff({
        id = "HoT_" .. label,
        types = { [BUFF_TYPES.HEALING_OVER_TIME] = true },
        label = label,
        icon = icon,

        healingPerTick = healingPerTick,

        source = BUFF_SOURCES.OTHER_PLAYER,

        remainingTurns = remainingTurns,
    })

    bus.fire(EVENTS.HEALING_OVER_TIME_BUFF_ADDED, label)
end

local function addTraitBuff(trait, providedStats)
    local existingBuffs = characterState.state.buffLookup.getTraitBuffs(trait)
    if existingBuffs then
        for _, existingBuff in pairs(existingBuffs) do
            removeBuff(existingBuff)
        end
    end

    for i, buff in ipairs(trait.buffs) do
        local types = buff.types or {
            [buff.type] = true
        }

        local newBuff = {
            id = "trait_" .. trait.id .. "_" .. i,
            types = types,
            label = trait.name,
            icon = trait.icon,

            source = BUFF_SOURCES.TRAIT,
            traitID = trait.id,

            canCancel = true
        }

        if types[BUFF_TYPES.STAT] then
            if providedStats then
                newBuff.stats = providedStats
            else
                newBuff.stats = {}
                for stat, value in pairs(buff.stats) do
                    if value == "custom" then
                        newBuff.stats[stat] = rules.traits.calculateStatBuff(trait, stat)
                    else
                        newBuff.stats[stat] = value
                    end
                end
            end
        end
        if types[BUFF_TYPES.ADVANTAGE] then
            newBuff.actions = buff.actions or {}
            if buff.turnTypeId then
                newBuff.turnTypeId = buff.turnTypeId
            end
        end
        if types[BUFF_TYPES.MAX_HEALTH] then
            newBuff.amount = buff.amount
            newBuff.originalAmount = buff.amount
        end

        if buff.remainingTurns then
            if type(buff.remainingTurns) == "table" then
                newBuff.remainingTurns = shallowCopy(buff.remainingTurns)
            else
                newBuff.remainingTurns = buff.remainingTurns
            end
        end
        if buff.expireOnCombatEnd then
            newBuff.expireOnCombatEnd = buff.expireOnCombatEnd
        end

        addBuff(newBuff)
    end
end

local function addWeaknessDebuff(weakness, addStacks)
    local debuff = weakness.debuff
    if debuff then
        local existingBuff = characterState.state.buffLookup.getWeaknessDebuff(weakness)

        if existingBuff then
            if addStacks then
                characterState.state.activeBuffs.addStack(existingBuff)
                return
            else
            removeBuff(existingBuff)
        end
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

            stacks = 1,

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
        if types[BUFF_TYPES.MAX_HEALTH] then
            buff.amount = debuff.amount
            buff.originalAmount = debuff.amount
        end

        if debuff.remainingTurns then
            buff.remainingTurns = shallowCopy(debuff.remainingTurns)
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
ns.buffs.addHoTBuff = addHoTBuff
ns.buffs.addTraitBuff = addTraitBuff
ns.buffs.addWeaknessDebuff = addWeaknessDebuff
ns.buffs.addRacialBuff = addRacialBuff