local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local character = ns.character
local rules = ns.rules
local characterState = ns.state.character
local turnState = ns.state.turn
local utils = ns.utils

local criticalWounds = ns.resources.criticalWounds
local feats = ns.resources.feats
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES
local state

local numTraitCharges = function()
    local numCharges = {}

    for traitID, trait in pairs(TRAITS) do
        if trait.numCharges then
            numCharges[traitID] = rules.traits.getMaxTraitCharges(trait)
        end
    end

    return numCharges
end

characterState.initState = function()
    state = {
        health = character.calculatePlayerMaxHealthWithoutBuffs(),
        maxHealth = character.calculatePlayerMaxHealthWithoutBuffs(),

        defence = {
            damagePrevented = 0,
        },

        healing = {
            numGreaterHealSlots = rules.healing.getMaxGreaterHealSlots(),
            remainingOutOfCombatHeals = rules.healing.getMaxOutOfCombatHeals(),
            excess = 0,
        },

        criticalWounds = {},

        featsAndTraits = {
            numBloodHarvestSlots = rules.offence.getMaxBloodHarvestSlots(),
            numTraitCharges = numTraitCharges(),
        },

        numFatePoints = rules.rolls.getMaxFatePoints(),
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
    return utils.formatHealth(characterState.state.health.get(), characterState.state.maxHealth.get())
end

local function summariseCriticalWounds()
    local out = {}

    for id, active in pairs(state.criticalWounds) do
        if active then
            if #out > 0 then
                table.insert(out, ", ")
            end
            table.insert(out, criticalWounds.WOUNDS[id].name)
        end
    end

    if #out > 0 then
        table.insert(out, 1, "CW: ")
    end

    return out
end

local function summariseState()
    local msg = summariseHP()
    local cw = summariseCriticalWounds()

    if #cw > 0 then
        msg = msg .. "|n|n" .. table.concat(cw)
    end

    return msg
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
            health = max(0, health)

            if health ~= state.health then
                state.health = health
                bus.fire(EVENTS.CHARACTER_HEALTH, state.health)
            end
        end,
        -- for any kind of non defence related damage that still needs its effective damage calculated
        -- damage from defence will use applyDamage directly
        damage = function(incomingDamage, options)
            options = options or {}
            if options.canBeMitigated == nil then
                options.canBeMitigated = true
            end

            local damageTakenBuff = buffsState.state.buffs.damageTaken.get()
            incomingDamage = rules.effects.calculateEffectiveIncomingDamage(incomingDamage, damageTakenBuff, options.canBeMitigated)

            characterState.state.health.applyDamage(incomingDamage)
        end,
        applyDamage = function(effectiveIncomingDamage)
            local damage = rules.effects.calculateDamageTaken(effectiveIncomingDamage, state.health)

            characterState.state.health.set(state.health - damage.damageTaken)
            bus.fire(EVENTS.DAMAGE_TAKEN, damage.effectiveIncomingDamage, damage.damageTaken, damage.overkill)
        end,
        heal = function(incomingHealAmount, source)
            TEARollHelper:Debug("Incoming heal", incomingHealAmount, source)

            local heal = rules.effects.calculateHealingReceived(incomingHealAmount, source, state.health, state.maxHealth)
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
    defence = {
        damagePrevented = {
            get = function()
                return state.defence.damagePrevented
            end,
            set = function(damagePrevented)
                if damagePrevented ~= state.defence.damagePrevented then
                    state.defence.damagePrevented = damagePrevented

                    if state.defence.damagePrevented >= rules.defence.MAX_DAMAGE_PREVENTED then
                        characterState.state.defence.damagePrevented.reset()
                    end
                end
            end,
            increment = function(damagePrevented)
                bus.fire(EVENTS.DAMAGE_PREVENTED, damagePrevented)
                characterState.state.defence.damagePrevented.set(state.defence.damagePrevented + damagePrevented)
            end,
            reset = function()
                characterState.state.defence.damagePrevented.set(0)
                bus.fire(EVENTS.DAMAGE_PREVENTED_COUNTER_RESET)
            end,
        }
    },
    healing = {
        numGreaterHealSlots = {
            get = function()
                return state.healing.numGreaterHealSlots
            end,
            set = function(numCharges)
                if numCharges ~= state.healing.numGreaterHealSlots then
                    state.healing.numGreaterHealSlots = numCharges
                    bus.fire(EVENTS.GREATER_HEAL_CHARGES_CHANGED, numCharges)
                end
            end,
            use = function(numCharges)
                if numCharges > 0 then
                    characterState.state.healing.numGreaterHealSlots.set(state.healing.numGreaterHealSlots - numCharges)
                    bus.fire(EVENTS.GREATER_HEAL_CHARGES_USED, numCharges)
                end
            end,
            restore = function(numCharges)
                if numCharges > 0 then
                    characterState.state.healing.numGreaterHealSlots.set(state.healing.numGreaterHealSlots + numCharges)
                end
            end,
        },
        remainingOutOfCombatHeals = {
            get = function()
                return state.healing.remainingOutOfCombatHeals
            end,
            set = function(remainingOutOfCombatHeals)
                if remainingOutOfCombatHeals ~= state.healing.remainingOutOfCombatHeals then
                    state.healing.remainingOutOfCombatHeals = remainingOutOfCombatHeals
                end
            end,
            spendOne = function()
                characterState.state.healing.remainingOutOfCombatHeals.set(state.healing.remainingOutOfCombatHeals - 1)
            end,
            restore = function()
                if state.healing.remainingOutOfCombatHeals < rules.healing.getMaxOutOfCombatHeals() then
                    characterState.state.healing.remainingOutOfCombatHeals.reset()
                end
            end,
            reset = function()
                characterState.state.healing.remainingOutOfCombatHeals.set(rules.healing.getMaxOutOfCombatHeals())
            end,
        },
        excess = {
            get = function()
                return state.healing.excess
            end,
            set = function(excess)
                if excess ~= state.healing.excess then
                    state.healing.excess = excess
                end
            end,
            spend = function(excess)
                if excess > 0 then
                    characterState.state.healing.excess.set(state.healing.excess - excess)
                end
            end,
        },
    },
    criticalWounds = {
        list = function()
            return state.criticalWounds
        end,
        has = function(criticalWound)
            return state.criticalWounds[criticalWound.id]
        end,
        apply = function(criticalWound)
            state.criticalWounds[criticalWound.id] = true
        end,
        remove = function(criticalWound)
            state.criticalWounds[criticalWound.id] = nil
        end,
    },
    featsAndTraits = {
        numBloodHarvestSlots = {
            get = function()
                return state.featsAndTraits.numBloodHarvestSlots
            end,
            set = function(numBloodHarvestSlots)
                if numBloodHarvestSlots ~= state.featsAndTraits.numBloodHarvestSlots then
                    state.featsAndTraits.numBloodHarvestSlots = numBloodHarvestSlots
                    bus.fire(EVENTS.BLOOD_HARVEST_CHARGES_CHANGED, numBloodHarvestSlots)
                end
            end,
            use = function(numBloodHarvestSlots)
                if numBloodHarvestSlots > 0 then
                    characterState.state.featsAndTraits.numBloodHarvestSlots.set(state.featsAndTraits.numBloodHarvestSlots - numBloodHarvestSlots)
                    bus.fire(EVENTS.BLOOD_HARVEST_CHARGES_USED, numBloodHarvestSlots)
                end
            end,
        },
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

local function resetRemainingOutOfCombatHeals(reason)
    characterState.state.healing.remainingOutOfCombatHeals.reset()
    TEARollHelper:Debug("Reset remaining out of combat heals because " .. reason)
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
    elseif stat == "defence" then
        characterState.state.defence.damagePrevented.set(0)
    elseif stat == "spirit" then
        updateGreaterHealSlots("spirit stat changed")
    elseif stat == "stamina" then
        updateMaxHealth(true)
    end
end)

bus.addListener(EVENTS.FEAT_CHANGED, function(featID)
    updateGreaterHealSlots("feat changed")
    resetRemainingOutOfCombatHeals("feat changed")

    local featBuffs = buffsState.state.buffLookup.getFeatBuffs()
    if featBuffs then
        for _, featBuff in ipairs(featBuffs) do
            featBuff:Remove()
        end
    end

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
    if not turnState.state.inCombat.get() then
        local trait = TRAITS[traitID]
        if trait and trait.numCharges then -- check if trait exists in case it was removed from addon
            characterState.state.featsAndTraits.numTraitCharges.set(traitID, rules.traits.getMaxTraitCharges(trait))
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
    elseif weaknessID == WEAKNESSES.TEMPERED_BENEVOLENCE.id then
        updateGreaterHealSlots("player now has Tempered Benevolence weakness")
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
    elseif weaknessID == WEAKNESSES.TEMPERED_BENEVOLENCE.id then
        updateGreaterHealSlots("player no longer has Tempered Benevolence weakness")
    end

    character.clearExcessTraits()
end)

characterState.summariseHP = summariseHP
characterState.summariseState = summariseState