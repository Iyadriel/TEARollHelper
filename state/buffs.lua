local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local characterState = ns.state.character
local constants = ns.constants
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local ACTIONS = constants.ACTIONS
local BUFF_TYPES = constants.BUFF_TYPES
local EVENTS = bus.EVENTS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES
local state

buffsState.initState = function()
    state = {
        buffs = {
            offence = 0,
            defence = 0,
            spirit = 0,
            stamina = 0,

            maxHealth = 0,
            baseDamage = 0,
            damageDone = 0,
            damageTaken = 0,
            healingDone = 0,
        },

        activeBuffs = {},
        buffLookup = {},

        newPlayerBuff = {
            type = BUFF_TYPES.STAT,
            stat = "offence",
            amount = 1,
            action = ACTIONS.attack,
            label = "",
            expireAfterNextTurn = true,
            expireAfterFirstAction = true,
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

local function updateMaxHealth(shouldRestoreMissingHealth)
    characterState.state.maxHealth.update(shouldRestoreMissingHealth)
end

buffsState.state = {
    buffs = {
        offence = basicGetSet("buffs", "offence"),
        defence = basicGetSet("buffs", "defence"),
        spirit = basicGetSet("buffs", "spirit"),
        stamina = basicGetSet("buffs", "stamina", function()
            updateMaxHealth(true)
        end),

        maxHealth = basicGetSet("buffs", "maxHealth"),
        baseDamage = basicGetSet("buffs", "baseDamage"),
        damageDone = basicGetSet("buffs", "damageDone"),
        damageTaken = basicGetSet("buffs", "damageTaken"),
        healingDone = basicGetSet("buffs", "healingDone"),
    },
    activeBuffs = {
        get = function ()
            return state.activeBuffs
        end,
        add = function(buff)
            if buff.canCancel == nil then
                buff.canCancel = true
            end

            table.insert(state.activeBuffs, buff)
            buffsState.state.buffLookup.add(buff)

            if buff.types[BUFF_TYPES.STAT] then
                for stat, amount in pairs(buff.stats) do
                    local statBuff = buffsState.state.buffs[stat]
                    statBuff.set(statBuff.get() + amount)
                end
            end

            if buff.types[BUFF_TYPES.MAX_HEALTH] then
                buffsState.state.buffs.maxHealth.set(buffsState.state.buffs.maxHealth.get() + buff.amount)
                updateMaxHealth(false)
            elseif buff.types[BUFF_TYPES.BASE_DMG] then
                buffsState.state.buffs.baseDamage.set(buffsState.state.buffs.baseDamage.get() + buff.amount)
            elseif buff.types[BUFF_TYPES.DAMAGE_DONE] then
                buffsState.state.buffs.damageDone.set(buffsState.state.buffs.damageDone.get() + buff.amount)
            elseif buff.types[BUFF_TYPES.DAMAGE_TAKEN] then
                buffsState.state.buffs.damageTaken.set(buffsState.state.buffs.damageTaken.get() + buff.amount)
            elseif buff.types[BUFF_TYPES.HEALING_DONE] then
                buffsState.state.buffs.healingDone.set(buffsState.state.buffs.healingDone.get() + buff.amount)
            end

            -- reset input
            buffsState.state.newPlayerBuff.amount.set(1)
            buffsState.state.newPlayerBuff.label.set("")
            buffsState.state.newPlayerBuff.expireAfterNextTurn.set(true)
            buffsState.state.newPlayerBuff.expireAfterFirstAction.set(true)
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

            if buff.types[BUFF_TYPES.STAT] then
                for stat, amount in pairs(buff.stats) do
                    local statBuff = buffsState.state.buffs[stat]
                    statBuff.set(statBuff.get() - amount)
                end
            end

            if buff.types[BUFF_TYPES.MAX_HEALTH] then
                buffsState.state.buffs.maxHealth.set(buffsState.state.buffs.maxHealth.get() - buff.amount)
                updateMaxHealth(false)
            elseif buff.types[BUFF_TYPES.BASE_DMG] then
                buffsState.state.buffs.baseDamage.set(buffsState.state.buffs.baseDamage.get() - buff.amount)
            elseif buff.types[BUFF_TYPES.DAMAGE_DONE] then
                buffsState.state.buffs.damageDone.set(buffsState.state.buffs.damageDone.get() - buff.amount)
            elseif buff.types[BUFF_TYPES.DAMAGE_TAKEN] then
                buffsState.state.buffs.damageTaken.set(buffsState.state.buffs.damageTaken.get() - buff.amount)
            elseif buff.types[BUFF_TYPES.HEALING_DONE] then
                buffsState.state.buffs.healingDone.set(buffsState.state.buffs.healingDone.get() - buff.amount)
            end

            table.remove(state.activeBuffs, index)
            buffsState.state.buffLookup.remove(buff)
        end,
        cancel = function(index)
            -- cancel is for buffs manually removed by the player.
            buffsState.state.activeBuffs.removeAtIndex(index)
        end,
        addStack = function(buff)
            buff.stacks = buff.stacks + 1

            if buff.types[BUFF_TYPES.MAX_HEALTH] then
                buffsState.state.buffs.maxHealth.set(buffsState.state.buffs.maxHealth.get() + buff.originalAmount)
                buff.amount = buff.originalAmount * buff.stacks
                updateMaxHealth(false)
            end

            bus.fire(EVENTS.BUFF_STACK_ADDED, buff)
        end,
    },
    buffLookup = {
        get = function(id)
            return state.buffLookup[id]
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
        getAdvantageBuff = function(action, turnTypeId)
            local activeBuffs = buffsState.state.activeBuffs.get()
            for _, buff in ipairs(activeBuffs) do
                if buff.types[BUFF_TYPES.ADVANTAGE] then
                    if (action and buff.actions[action]) or (turnTypeId and buff.turnTypeId == turnTypeId) then
                        return buff
                    end
                end
            end
            return nil
        end,
        getDisadvantageDebuff = function(action, turnTypeId)
            local activeBuffs = buffsState.state.activeBuffs.get()
            for _, buff in ipairs(activeBuffs) do
                if buff.types[BUFF_TYPES.DISADVANTAGE] then
                    if (action and buff.actions[action]) or (turnTypeId and buff.turnTypeId == turnTypeId) then
                        return buff
                    end
                end
            end
            return nil
        end,
        getFeatBuff = function(feat)
            return buffsState.state.buffLookup.get("feat_" .. feat.id)
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
        getCriticalWoundDebuff = function(criticalWound)
            return buffsState.state.buffLookup.get(criticalWound:GetBuffID())
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
        stat = basicGetSet("newPlayerBuff", "stat"),
        amount = basicGetSet("newPlayerBuff", "amount"),
        action = basicGetSet("newPlayerBuff", "action"),
        label = basicGetSet("newPlayerBuff", "label"),
        expireAfterNextTurn = basicGetSet("newPlayerBuff", "expireAfterNextTurn"),
        expireAfterFirstAction = basicGetSet("newPlayerBuff", "expireAfterFirstAction"),
    }
}

local function removeWeaknessDebuff(weakness)
    local weaknessDebuff = buffsState.state.buffLookup.getWeaknessDebuff(weakness)
    if weaknessDebuff then
        buffsState.state.activeBuffs.remove(weaknessDebuff)
        TEARollHelper:Debug("Removed weakness debuff because player no longer has Weakness:", weakness.name)
    end
end

bus.addListener(EVENTS.TRAIT_REMOVED, function(traitID)
    local traitBuffs = buffsState.state.buffLookup.getTraitBuffs(TRAITS[traitID])
    if traitBuffs then
        for _, traitBuff in pairs(traitBuffs) do
            buffsState.state.activeBuffs.remove(traitBuff)
        end
    end
end)

bus.addListener(EVENTS.WEAKNESS_REMOVED, function(weaknessID)
    if weaknessID == WEAKNESSES.TEMPO.id then
        removeWeaknessDebuff(WEAKNESSES.TEMPO)
    elseif weaknessID == WEAKNESSES.TIMID.id then
        removeWeaknessDebuff(WEAKNESSES.TIMID)
    end
end)

bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, function()
    local racialBuff = buffsState.state.buffLookup.getRacialBuff()
    if racialBuff then
        buffsState.state.activeBuffs.remove(racialBuff)
        TEARollHelper:Debug("Removed racial trait buff because racial trait in character sheet changed.")
    end
end)