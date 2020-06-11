local _, ns = ...

local bus = ns.bus
local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits
local characterState = ns.state.character
local turnState = ns.state.turn
local weaknesses = ns.resources.weaknesses

local ACTIONS = constants.ACTIONS
local BUFF_TYPES = constants.BUFF_TYPES
local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES
local state

local numTraitCharges = (function()
    local numCharges = {}

    for traitID, trait in pairs(TRAITS) do
        if trait.numCharges then
            numCharges[traitID] = trait.numCharges
        end
    end

    return numCharges
end)()

characterState.initState = function()
    state = {
        health = character.calculatePlayerMaxHealthWithoutBuffs(),
        maxHealth = character.calculatePlayerMaxHealthWithoutBuffs(),

        healing = {
            numGreaterHealSlots = rules.healing.getMaxGreaterHealSlots(),
            excess = 0,
        },

        featsAndTraits = {
            numBloodHarvestSlots = rules.offence.getMaxBloodHarvestSlots(),
            numTraitCharges = numTraitCharges,
        },

        numFatePoints = rules.rolls.getMaxFatePoints(),

        buffs = {
            offence = 0,
            defence = 0,
            spirit = 0,
            stamina = 0,
        },

        activeBuffs = {},
        buffLookup = {},
        newPlayerBuff = {
            type = "stat",
            stat = "offence",
            amount = 1,
            action = ACTIONS.attack,
            label = "",
            expireAfterNextTurn = true,
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

local function summariseHP()
    local out = {
        characterState.state.health.get(),
        "/",
        characterState.state.maxHealth.get(),
        " HP",
    }

    return table.concat(out)
end

local function summariseState()
    --[[         "|n|n|nFeat: ",
            character.getPlayerFeat().name,
            "|n|n|nGreater Heal slots: ",
            state.healing.numGreaterHealSlots.get(),
            "/",
            rules.healing.getMaxGreaterHealSlots() ]]
    return summariseHP()
end

local function updateMaxHealth(shouldRestoreMissingHealth)
    characterState.state.maxHealth.update(shouldRestoreMissingHealth)
end

characterState.state = {
    health = {
        get = function()
            return state.health
        end,
        set = function(health)
            if health ~= state.health then
                state.health = health
                bus.fire(EVENTS.CHARACTER_HEALTH, state.health)
            end
        end,
        damage = function(dmgTaken)
            if dmgTaken <= 0 then return end

            state.health = state.health - dmgTaken
            bus.fire(EVENTS.CHARACTER_HEALTH, state.health)
            bus.fire(EVENTS.DAMAGE_TAKEN, dmgTaken)
        end,
        heal = function(incomingHealAmount)
            local heal = ns.rules.other.calculateHealingReceived(incomingHealAmount, state.health, state.maxHealth)

            characterState.state.health.set(state.health + heal.netAmountHealed)

            bus.fire(EVENTS.HEALED, heal.amountHealed, heal.netAmountHealed, heal.overhealing)
        end
    },
    maxHealth = {
        get = function()
            return state.maxHealth
        end,
        update = function(shouldRestoreMissingHealth)
            local health = characterState.state.health.get()
            local maxHealth = character.calculatePlayerMaxHealth()

            state.maxHealth = maxHealth

            if health > maxHealth then
                characterState.state.health.set(maxHealth)
                TEARollHelper:Debug("Reduced remaining HP because max HP changed.")
            elseif shouldRestoreMissingHealth and health < maxHealth and not turnState.state.inCombat.get() then
                characterState.state.health.set(maxHealth)
                TEARollHelper:Debug("Increased remaining HP because max HP changed.")
            end

            bus.fire(EVENTS.CHARACTER_MAX_HEALTH, state.maxHealth)
        end,
    },
    healing = {
        numGreaterHealSlots = basicGetSet("healing", "numGreaterHealSlots", function(numCharges)
            bus.fire(EVENTS.GREATER_HEAL_CHARGES_CHANGED, numCharges)
        end),
        excess = basicGetSet("healing", "excess"),
    },
    featsAndTraits = {
        numBloodHarvestSlots = basicGetSet("featsAndTraits", "numBloodHarvestSlots", function(numCharges)
            bus.fire(EVENTS.FEAT_CHARGES_CHANGED, FEATS.BLOOD_HARVEST.id, numCharges)
        end),
        numTraitCharges = {
            get = function(traitID)
                return state.featsAndTraits.numTraitCharges[traitID]
            end,
            set = function(traitID, numCharges)
                state.featsAndTraits.numTraitCharges[traitID] = numCharges
            end,
        },
    },
    numFatePoints = {
        get = function ()
            return state.numFatePoints
        end,
        set = function (value)
            state.numFatePoints = value
        end
    },
    buffs = {
        offence = basicGetSet("buffs", "offence"),
        defence = basicGetSet("buffs", "defence"),
        spirit = basicGetSet("buffs", "spirit"),
        stamina = basicGetSet("buffs", "stamina", function()
            updateMaxHealth(true)
        end),
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
            characterState.state.buffLookup.add(buff)

            if buff.types[BUFF_TYPES.STAT] then
                for stat, amount in pairs(buff.stats) do
                    local statBuff = characterState.state.buffs[stat]
                    statBuff.set(statBuff.get() + amount)
                end
            end
            if buff.types[BUFF_TYPES.MAX_HEALTH] then
                updateMaxHealth(false)
            end

            -- reset input
            characterState.state.newPlayerBuff.amount.set(1)
            characterState.state.newPlayerBuff.label.set("")
            characterState.state.newPlayerBuff.expireAfterNextTurn.set(true)
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
                characterState.state.activeBuffs.removeAtIndex(index)
            else
                TEARollHelper:Debug("Failed to remove buff with ID " .. buffID)
            end
        end,
        removeAtIndex = function(index)
            local buff = state.activeBuffs[index]

            if buff.types[BUFF_TYPES.STAT] then
                for stat, amount in pairs(buff.stats) do
                    local statBuff = characterState.state.buffs[stat]
                    statBuff.set(statBuff.get() - amount)
                end
            end

            table.remove(state.activeBuffs, index)
            characterState.state.buffLookup.remove(buff)

            if buff.types[BUFF_TYPES.MAX_HEALTH] then
                updateMaxHealth(false)
            end
        end,
        cancel = function(index)
            -- cancel is for buffs manually removed by the player.
            characterState.state.activeBuffs.removeAtIndex(index)
        end,
        addStack = function(buff)
            buff.stacks = buff.stacks + 1

            if buff.types[BUFF_TYPES.MAX_HEALTH] then
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
            return characterState.state.buffLookup.get("player_" .. stat)
        end,
        getPlayerAdvantageBuff = function(action)
            return characterState.state.buffLookup.get("player_advantage_" .. action)
        end,
        getPlayerDisadvantageDebuff = function(action)
            return characterState.state.buffLookup.get("player_disadvantage_" .. action)
        end,
        getAdvantageBuff = function(action, turnTypeId)
            local activeBuffs = characterState.state.activeBuffs.get()
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
            local activeBuffs = characterState.state.activeBuffs.get()
            for _, buff in ipairs(activeBuffs) do
                if buff.types[BUFF_TYPES.DISADVANTAGE] then
                    if (action and buff.actions[action]) or (turnTypeId and buff.turnTypeId == turnTypeId) then
                        return buff
                    end
                end
            end
            return nil
        end,
        getTraitBuffs = function(trait)
            local activeBuffs = characterState.state.activeBuffs.get()
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
            return characterState.state.buffLookup.get("weakness_" .. weakness.id)
        end,
        getRacialBuff = function()
            return characterState.state.buffLookup.get("racial")
        end,
        getMaxHealthBuffs = function()
            local activeBuffs = characterState.state.activeBuffs.get()
            local maxHealthBuffs = {}
            for _, buff in ipairs(activeBuffs) do
                if buff.types[BUFF_TYPES.MAX_HEALTH] then
                    table.insert(maxHealthBuffs, buff)
                end
            end
            return maxHealthBuffs
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
    }
}

local function updateGreaterHealSlots(reason)
    local remainingSlots = characterState.state.healing.numGreaterHealSlots.get()
    local maxSlots = rules.healing.getMaxGreaterHealSlots()
    if remainingSlots > maxSlots then
        characterState.state.healing.numGreaterHealSlots.set(maxSlots)
        TEARollHelper:Debug("Reduced remaining Greater Heal charges because " .. reason)
    elseif remainingSlots < maxSlots and not turnState.state.inCombat.get() then
        characterState.state.healing.numGreaterHealSlots.set(maxSlots)
        TEARollHelper:Debug("Increased remaining Greater Heal charges because " .. reason)
    end
end

local function removeWeaknessDebuff(weakness)
    local weaknessDebuff = characterState.state.buffLookup.getWeaknessDebuff(weakness)
    if weaknessDebuff then
        characterState.state.activeBuffs.remove(weaknessDebuff)
        TEARollHelper:Debug("Removed weakness debuff because player no longer has Weakness:", weakness.name)
    end
end

bus.addListener(EVENTS.CHARACTER_STAT_CHANGED, function(stat, value)
    if stat == "offence" then
        local remainingSlots = characterState.state.featsAndTraits.numBloodHarvestSlots.get()
        local maxSlots = rules.offence.getMaxBloodHarvestSlots()
        if remainingSlots > maxSlots then
            characterState.state.featsAndTraits.numBloodHarvestSlots.set(maxSlots)
            TEARollHelper:Debug("Reduced remaining " .. FEATS.BLOOD_HARVEST.name .. " charges because offence stat changed.")
        elseif remainingSlots < maxSlots and not turnState.state.inCombat.get() then
            characterState.state.featsAndTraits.numBloodHarvestSlots.set(maxSlots)
            TEARollHelper:Debug("Increased remaining " .. FEATS.BLOOD_HARVEST.name .. " charges because offence stat changed.")
        end
    elseif stat == "spirit" then
        updateGreaterHealSlots("spirit stat changed")
    elseif stat == "stamina" then
        updateMaxHealth(true)
    end
end)

bus.addListener(EVENTS.FEAT_CHANGED, function(featID)
    updateGreaterHealSlots("feat changed")

    if featID == FEATS.BLOOD_HARVEST.id and not turnState.state.inCombat.get() then
        local numBloodHarvestSlots = characterState.state.featsAndTraits.numBloodHarvestSlots
        local maxSlots = rules.offence.getMaxBloodHarvestSlots()
        if numBloodHarvestSlots.get() < maxSlots then
            numBloodHarvestSlots.set(maxSlots)
            TEARollHelper:Debug("Increased remaining " .. FEATS.BLOOD_HARVEST.name .. " charges because feat changed out of combat.")
        end
    end
end)

bus.addListener(EVENTS.TRAIT_REMOVED, function(traitID)
    local traitBuffs = characterState.state.buffLookup.getTraitBuffs(TRAITS[traitID])
    if traitBuffs then
        for _, traitBuff in pairs(traitBuffs) do
            characterState.state.activeBuffs.remove(traitBuff)
        end
    end

    if not turnState.state.inCombat.get() then
        local trait = TRAITS[traitID]
        if trait.numCharges then
            characterState.state.featsAndTraits.numTraitCharges.set(traitID, trait.numCharges)
        end
    end
end)

bus.addListener(EVENTS.WEAKNESS_ADDED, function(weaknessID)
    if weaknessID == WEAKNESSES.FRAGILE.id then
        updateMaxHealth(true)
    elseif weaknessID == WEAKNESSES.FATELESS.id then
        local numFatePoints = characterState.state.numFatePoints.get()
        local maxFatePoints = rules.rolls.getMaxFatePoints()
        if numFatePoints > maxFatePoints then
            characterState.state.numFatePoints.set(maxFatePoints)
            TEARollHelper:Debug("Reduced remaining fate points because player now has Fateless weakness.")
        end
    end
end)

bus.addListener(EVENTS.WEAKNESS_REMOVED, function(weaknessID)
    if weaknessID == WEAKNESSES.FRAGILE.id then
        updateMaxHealth(true)
    elseif weaknessID == WEAKNESSES.FATELESS.id then
        local numFatePoints = characterState.state.numFatePoints.get()
        local maxFatePoints = rules.rolls.getMaxFatePoints()
        if numFatePoints < maxFatePoints and not turnState.state.inCombat.get() then
            characterState.state.numFatePoints.set(maxFatePoints)
            TEARollHelper:Debug("Increased remaining fate points because player no longer has Fateless weakness.")
        end
    elseif weaknessID == WEAKNESSES.TEMPO.id then
        removeWeaknessDebuff(WEAKNESSES.TEMPO)
    elseif weaknessID == WEAKNESSES.TIMID.id then
        removeWeaknessDebuff(WEAKNESSES.TIMID)
    end
end)

bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, function()
    local racialBuff = characterState.state.buffLookup.getRacialBuff()
    if racialBuff then
        characterState.state.activeBuffs.remove(racialBuff)
        TEARollHelper:Debug("Removed racial trait buff because racial trait in character sheet changed.")
    end
end)

characterState.summariseHP = summariseHP
characterState.summariseState = summariseState