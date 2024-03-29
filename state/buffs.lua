local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character
local constants = ns.constants
local models = ns.models

local weaknesses = ns.resources.weaknesses

local BuffEffectAdvantage = models.BuffEffectAdvantage
local BuffEffectDisadvantage = models.BuffEffectDisadvantage

local ACTIONS = constants.ACTIONS
local EVENTS = bus.EVENTS
local PLAYER_BUFF_TYPES = constants.PLAYER_BUFF_TYPES
local STATS = constants.STATS
local TURN_TYPES = constants.TURN_TYPES
local WEAKNESSES = weaknesses.WEAKNESSES
local state

buffsState.initState = function()
    state = {
        buffs = {
            offence = 0,
            defence = 0,
            spirit = 0,
            stamina = 0,

            roll = {
                [TURN_TYPES.PLAYER.id] = 0,
                [TURN_TYPES.ENEMY.id] = 0,
                [TURN_TYPES.OUT_OF_COMBAT.id] = 0, -- unused, but simplifies some logic
                damage = 0,
            },
            maxHealth = 0,
            baseDamage = 0,
            damageDone = 0,
            damageTaken = 0,
            healingDone = 0,
            healingTaken = 0,
            utilityBonus = 0,
        },

        activeBuffs = {},
        buffLookup = {},

        newPlayerBuff = {
            type = PLAYER_BUFF_TYPES.ROLL,
            turnTypeID = TURN_TYPES.PLAYER.id,
            stat = STATS.offence,
            amount = 1,
            action = ACTIONS.attack,
            expireAfterNextTurn = true,
            expireAfterAnyAction = true,
        },
    }
end

local function basicGetSet(section, key, callback)
    return {
        get = function ()
            return state[section][key]
        end,
        set = function (value)
            state[section][key] = value
            if callback then callback(value) end
        end
    }
end

buffsState.state = {
    buffs = {
        [STATS.offence] = basicGetSet("buffs", STATS.offence),
        [STATS.defence] = basicGetSet("buffs", STATS.defence),
        [STATS.spirit] = basicGetSet("buffs", STATS.spirit),
        [STATS.stamina] = basicGetSet("buffs", STATS.stamina, function()
            characterState.state.maxHealth.update({
                healIfNewMaxHealthHigher = false
            })
        end),

        roll = {
            get = function(kind)
                return state.buffs.roll[kind]
            end,
            set = function(kind, value)
                state.buffs.roll[kind] = value
            end,
        },
        maxHealth = basicGetSet("buffs", "maxHealth"),
        baseDamage = basicGetSet("buffs", "baseDamage"),
        damageDone = basicGetSet("buffs", "damageDone"),
        damageTaken = basicGetSet("buffs", "damageTaken"),
        healingDone = basicGetSet("buffs", "healingDone"),
        healingTaken = basicGetSet("buffs", "healingTaken"),
        utilityBonus = basicGetSet("buffs", "utilityBonus"),
    },
    activeBuffs = {
        get = function ()
            return state.activeBuffs
        end,
        add = function(buff)
            table.insert(state.activeBuffs, buff)
            buffsState.state.buffLookup.add(buff)

            -- reset input
            buffsState.state.newPlayerBuff.type.set(PLAYER_BUFF_TYPES.ROLL)
            buffsState.state.newPlayerBuff.turnTypeID.set(TURN_TYPES.PLAYER.id)
            buffsState.state.newPlayerBuff.stat.set(STATS.offence)
            buffsState.state.newPlayerBuff.amount.set(1)
            buffsState.state.newPlayerBuff.expireAfterNextTurn.set(true)
            buffsState.state.newPlayerBuff.expireAfterAnyAction.set(true)
        end,
        remove = function (buff)
            local buffID = buff.id
            local index
            for i, b in ipairs(state.activeBuffs) do
                if b.id == buffID then
                    index = i
                    break
                end
            end
            if index then
                buffsState.state.activeBuffs.removeAtIndex(index)
            else
                TEARollHelper:Debug("Failed to remove buff with ID " .. buffID)
            end
        end,
        removeAtIndex = function(index)
            local buff = state.activeBuffs[index]

            table.remove(state.activeBuffs, index)
            buffsState.state.buffLookup.remove(buff)
        end,
        cancel = function(index)
            -- cancel is for buffs manually removed by the player.
            buffsState.state.activeBuffs.removeAtIndex(index)
        end,
    },
    buffLookup = {
        get = function(id)
            return state.buffLookup[id]
        end,
        getPlayerRollBuff = function(kind)
            return buffsState.state.buffLookup.get("player_roll_" .. kind)
        end,
        getPlayerStatBuff = function(stat)
            return buffsState.state.buffLookup.get("player_" .. stat)
        end,
        getPlayerBaseDmgBuff = function()
            return buffsState.state.buffLookup.get("player_baseDmg")
        end,
        getPlayerAdvantageBuff = function(action)
            return buffsState.state.buffLookup.get("player_advantage_" .. action)
        end,
        getPlayerDisadvantageDebuff = function(action)
            return buffsState.state.buffLookup.get("player_disadvantage_" .. action)
        end,
        getAdvantageBuff = function(action, turnTypeID)
            local activeBuffs = buffsState.state.activeBuffs.get()
            for _, buff in ipairs(activeBuffs) do
                local effect = buff:GetEffectOfType(BuffEffectAdvantage)
                if effect then
                    if (action and effect.actions[action]) or (turnTypeID and effect.turnTypeID == turnTypeID) then
                        return buff
                    end
                end
            end
            return nil
        end,
        getDisadvantageDebuff = function(action, turnTypeID)
            local activeBuffs = buffsState.state.activeBuffs.get()
            for _, buff in ipairs(activeBuffs) do
                local effect = buff:GetEffectOfType(BuffEffectDisadvantage)
                if effect then
                    if (action and effect.actions[action]) or (turnTypeID and effect.turnTypeID == turnTypeID) then
                        return buff
                    end
                end
            end
            return nil
        end,
        getFeatBuffs = function(feat)
            local activeBuffs = buffsState.state.activeBuffs.get()
            local featBuffs = {}
            for _, buff in ipairs(activeBuffs) do
                if buff.featID == feat.id then
                    table.insert(featBuffs, buff)
                end
            end
            if #featBuffs == 0 then
                return nil
            end
            return featBuffs
        end,
        getTraitBuffs = function(trait)
            local activeBuffs = buffsState.state.activeBuffs.get()
            local traitBuffs = {}
            for _, buff in ipairs(activeBuffs) do
                if buff.traitID == trait.id then
                    table.insert(traitBuffs, buff)
                end
            end
            if #traitBuffs == 0 then
                return nil
            end
            return traitBuffs
        end,
        getWeaknessDebuff = function(weakness)
            return buffsState.state.buffLookup.get("weakness_" .. weakness.id)
        end,
        getRacialBuff = function()
            return buffsState.state.buffLookup.get("racial")
        end,
        add = function(buff)
            state.buffLookup[buff.id] = buff
            TEARollHelper:Debug("Added buff:", buff.id)
        end,
        remove = function(buff)
            state.buffLookup[buff.id] = nil
            TEARollHelper:Debug("Removed buff:", buff.id)
        end,
    },
    newPlayerBuff = {
        type = basicGetSet("newPlayerBuff", "type"),
        turnTypeID = basicGetSet("newPlayerBuff", "turnTypeID"),
        stat = basicGetSet("newPlayerBuff", "stat"),
        amount = basicGetSet("newPlayerBuff", "amount"),
        action = basicGetSet("newPlayerBuff", "action"),
        expireAfterNextTurn = basicGetSet("newPlayerBuff", "expireAfterNextTurn"),
        expireAfterAnyAction = basicGetSet("newPlayerBuff", "expireAfterAnyAction"),
    }
}

local function onFeatChanged()
    local activeBuffs = buffsState.state.activeBuffs.get()
    local buffsToRemove = {}

    for _, buff in ipairs(activeBuffs) do
        if buff.featID and not buff.castOnOthers and not character.hasFeatByID(buff.featID) then
            table.insert(buffsToRemove, buff)
        end
    end

    for _, featBuff in ipairs(buffsToRemove) do
        featBuff:Remove()
    end
end

local function onTraitsChanged()
    local activeBuffs = buffsState.state.activeBuffs.get()
    local buffsToRemove = {}

    for _, buff in ipairs(activeBuffs) do
        if buff.traitID and not buff.castOnOthers and not character.hasTraitByID(buff.traitID) then
            table.insert(buffsToRemove, buff)
        end
    end

    for _, traitBuff in ipairs(buffsToRemove) do
        traitBuff:Remove()
    end
end

local function onWeaknessesChanged()
    local activeBuffs = buffsState.state.activeBuffs.get()
    local buffsToRemove = {}

    for _, buff in ipairs(activeBuffs) do
        if buff.weaknessID and not character.hasWeaknessByID(buff.weaknessID) then
            table.insert(buffsToRemove, buff)
        end
    end

    for _, weaknessDebuff in ipairs(buffsToRemove) do
        weaknessDebuff:Remove()
    end
end

local function onRacialTraitChanged()
    local racialBuff = buffsState.state.buffLookup.getRacialBuff()
    if racialBuff then
        racialBuff:Remove()
        TEARollHelper:Debug("Removed racial trait buff because racial trait in character sheet changed.")
    end
end

local function onProfileChanged()
    onFeatChanged()
    onTraitsChanged()
    onWeaknessesChanged()
    onRacialTraitChanged()
end

bus.addListener(EVENTS.FEAT_CHANGED, onFeatChanged)
bus.addListener(EVENTS.TRAITS_CHANGED, onTraitsChanged)
bus.addListener(EVENTS.WEAKNESSES_CHANGED, onWeaknessesChanged)
bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, onRacialTraitChanged)
bus.addListener(EVENTS.PROFILE_CHANGED, onProfileChanged)
