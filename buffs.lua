local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local constants = ns.constants
local models = ns.models
local rules = ns.rules
local traits = ns.resources.traits
local utils = ns.utils

local EVENTS = bus.EVENTS
local BUFF_SOURCES = constants.BUFF_SOURCES
local BUFF_TYPES = constants.BUFF_TYPES
local STATS = constants.STATS
local STAT_LABELS = constants.STAT_LABELS
local TRAIT_BUFF_SPECS = traits.TRAIT_BUFF_SPECS
local TURN_TYPES = constants.TURN_TYPES

local TraitBuff = models.TraitBuff
local Buff, BuffEffectRoll, BuffEffectStat = models.Buff, models.BuffEffectRoll, models.BuffEffectStat
local BuffEffectBaseDamage = models.BuffEffectBaseDamage
local BuffEffectDamageDone = models.BuffEffectDamageDone
local BuffEffectDamageTaken = models.BuffEffectDamageTaken
local BuffEffectMaxHealth = models.BuffEffectMaxHealth
local BuffEffectHealingDone = models.BuffEffectHealingDone
local BuffEffectUtilityBonus = models.BuffEffectUtilityBonus

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

local function addBuff(buff)
    buffsState.state.activeBuffs.add(buff)
end

local function removeBuff(buff)
    buffsState.state.activeBuffs.remove(buff)
end

local function getRemainingTurns(expireAfterNextTurn)
    if not expireAfterNextTurn then return nil end
    return 1
end

local function addTestBuff()
    local buff1 = Buff:New({
        id = "test",
        label = "Test buff",
        icon = "Interface\\Icons\\trade_engineering",
        effects = {
            --BuffEffectBaseDamage:New(100),
            --BuffEffectRoll:New(TURN_TYPES.PLAYER.id, 5),
            --BuffEffectStat:New(STATS.spirit, 4),
            --BuffEffectDamageDone:New(100),
            --BuffEffectDamageTaken:New(50),
            BuffEffectUtilityBonus:New(-5),
        }
    })

--[[     local buff2 = Buff:New({
        id = "maxHealthTest",
        label = "Max Health",
        icon = "Interface\\Icons\\trade_engineering",
        effects = {
            BuffEffectMaxHealth:New(-5),
        }
    }) ]]

    addBuff(buff1)

    --buff1:AddStack()
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
        {
            remainingTurns = {
                [turnTypeID] = 0
            },
            expireAfterFirstAction = true,
        },
        true,
        { BuffEffectRoll:New(turnTypeID, amount) }
    )

    buff:Apply()

    -- TODO use effect in model instead
    bus.fire(EVENTS.ROLL_BUFF_ADDED, turnTypeID, amount)
end

local function addStatBuff(stat, amount, label, expireAfterNextTurn, expireAfterFirstAction)
    local existingBuff = buffsState.state.buffLookup.getPlayerStatBuff(stat)

    if existingBuff then
        existingBuff:Remove()
    end

    if label:trim() == "" then
        label = STAT_LABELS[stat]
    end

    local duration = {
        remainingTurns = getRemainingTurns(expireAfterNextTurn),
        expireAfterFirstAction = expireAfterFirstAction,
    }

    local buff = Buff:New(
        "player_" .. stat,
        label,
        STAT_TYPE_ICONS[stat],
        duration,
        true,
        { BuffEffectStat:New(stat, amount) }
    )

    buff:Apply()

    bus.fire(EVENTS.STAT_BUFF_ADDED, stat, amount)
end

local function addBaseDmgBuff(amount, label, expireAfterNextTurn, expireAfterFirstAction)
    local existingBuff = buffsState.state.buffLookup.getPlayerBaseDmgBuff()

    if existingBuff then
        existingBuff:Remove()
    end

    if label:trim() == "" then
        label = "Base damage"
    end

    local duration = {
        remainingTurns = getRemainingTurns(expireAfterNextTurn),
        expireAfterFirstAction = expireAfterFirstAction,
    }

    local buff = Buff:New(
        "player_baseDmg",
        label,
        "Interface\\Icons\\ability_warrior_victoryrush",
        duration,
        true,
        { BuffEffectBaseDamage:New(amount) }
    )

    buff:Apply()

    -- TODO use effect in model instead
    bus.fire(EVENTS.BASE_DMG_BUFF_ADDED, amount)
end

local function addAdvantageBuff(action, label, expireAfterNextTurn, expireAfterFirstAction)
    local existingBuff = buffsState.state.buffLookup.getPlayerAdvantageBuff(action)

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
        expireAfterFirstAction = expireAfterFirstAction,
    })
end

local function addDisadvantageDebuff(action, label, expireAfterNextTurn, expireAfterFirstAction)
    local existingBuff = buffsState.state.buffLookup.getPlayerDisadvantageDebuff(action)

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
        expireAfterFirstAction = expireAfterFirstAction,
    })
end

local function addHoTBuff(label, icon, healingPerTick, remainingTurns)
    if label:trim() == "" then
        label = "Healing"
    end

    if type(remainingTurns) == "table" then
        remainingTurns = utils.shallowCopy(remainingTurns)
    end

    addBuff({
        id = "HoT_" .. label,
        types = { [BUFF_TYPES.HEALING_OVER_TIME] = true },
        label = label,
        icon = icon,

        healingPerTick = healingPerTick,

        source = BUFF_SOURCES.OTHER_PLAYER,

        remainingTurns = remainingTurns,
        expireOnCombatEnd = true,
    })

    bus.fire(EVENTS.HEALING_OVER_TIME_BUFF_ADDED, label)
end

local function addFeatBuff(feat, providedValue)
    local existingBuff = buffsState.state.buffLookup.getFeatBuff(feat)
    if existingBuff then
        removeBuff(existingBuff)
    end

    local buff = feat.buff

    local types = buff.types or {
        [buff.type] = true
    }

    local newBuff = {
        id = "feat_" .. feat.id,
        types = types,
        label = feat.name,
        icon = feat.icon,

        source = BUFF_SOURCES.TRAIT,
        featID = feat.id,

        canCancel = true
    }

    if types[BUFF_TYPES.HEALING_DONE] then
        if providedValue then
            newBuff.amount = providedValue
        end
    end
    if types[BUFF_TYPES.DAMAGE_TAKEN] then
        newBuff.amount = buff.amount
    end

    if buff.remainingTurns then
        if type(buff.remainingTurns) == "table" then
            newBuff.remainingTurns = utils.shallowCopy(buff.remainingTurns)
        else
            newBuff.remainingTurns = buff.remainingTurns
        end
    end
    if buff.expireOnCombatEnd then
        newBuff.expireOnCombatEnd = buff.expireOnCombatEnd
    end
    if buff.expireAfterFirstAction then
        newBuff.expireAfterFirstAction = buff.expireAfterFirstAction
    end

    addBuff(newBuff)

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
    local debuff = weakness.debuff
    if debuff then
        local existingBuff = buffsState.state.buffLookup.getWeaknessDebuff(weakness)

        if existingBuff then
            if addStacks then
                existingBuff:AddStack()
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
            if debuff.turnTypeID then
                buff.turnTypeID = debuff.turnTypeID
            end
        end
        if types[BUFF_TYPES.MAX_HEALTH] then
            buff.amount = debuff.amount
            buff.originalAmount = debuff.amount
        end

        if debuff.remainingTurns then
            buff.remainingTurns = utils.shallowCopy(debuff.remainingTurns)
        end

        addBuff(buff)

        bus.fire(EVENTS.WEAKNESS_DEBUFF_ADDED, weakness.id)
    end
end

local function addRacialBuff(racialTrait)
    local buffs = racialTrait.buffs
    if buffs and buffs.stats then
        local existingBuff = buffsState.state.buffLookup.getRacialBuff()
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

ns.buffs.addRollBuff = addRollBuff
ns.buffs.addStatBuff = addStatBuff
ns.buffs.addBaseDmgBuff = addBaseDmgBuff
ns.buffs.addAdvantageBuff = addAdvantageBuff
ns.buffs.addDisadvantageDebuff = addDisadvantageDebuff
ns.buffs.addHoTBuff = addHoTBuff
ns.buffs.addFeatBuff = addFeatBuff
ns.buffs.addTraitBuff = addTraitBuff
ns.buffs.addWeaknessDebuff = addWeaknessDebuff
ns.buffs.addRacialBuff = addRacialBuff