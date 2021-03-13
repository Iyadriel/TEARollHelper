local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local character = ns.character
local constants = ns.constants
local rules = ns.rules
local characterState = ns.state.character
local utils = ns.utils

local criticalWounds = ns.resources.criticalWounds
local feats = ns.resources.feats
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local CONSCIOUSNESS_STATES = constants.CONSCIOUSNESS_STATES
local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local STATS = constants.STATS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES
local state
local cache = {}

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
            numBraceCharges = rules.defence.getMaxBraceCharges(),
        },

        healing = {
            numGreaterHealSlots = rules.healing.getMaxGreaterHealSlots(),
            remainingOutOfCombatHeals = rules.healing.getMaxOutOfCombatHeals(),
            excess = 0,
        },

        consciousness = CONSCIOUSNESS_STATES.FINE,
        criticalWounds = {},

        featsAndTraits = {
            numBloodHarvestSlots = rules.offence.getMaxBloodHarvestSlots(),
            numTraitCharges = numTraitCharges(),
        },

        numFatePoints = rules.rolls.getMaxFatePoints(),
    }

    cache.maxNumGreaterHealSlots = rules.healing.getMaxGreaterHealSlots()
    cache.maxNumBraceCharges = rules.defence.getMaxBraceCharges()
    cache.maxNumBloodHarvestSlots = rules.offence.getMaxBloodHarvestSlots()
    -- switching from a profile with Bright Burner to one without it should reset trait charges to max.
    -- this should not happen during events, but we rely on the player to not switch to a profile with different weaknesses during events.
    cache.hasBrightBurner = character.hasWeakness(WEAKNESSES.BRIGHT_BURNER)
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

local function updateMaxHealth(options)
    characterState.state.maxHealth.update(options)
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
        update = function(options)
            options = options or {}

            local health = characterState.state.health.get()
            local oldMaxHealth = state.maxHealth
            local newMaxHealth = character.calculatePlayerMaxHealth()

            state.maxHealth = newMaxHealth

            if health > newMaxHealth then
                characterState.state.health.set(newMaxHealth)
                TEARollHelper:Debug("Reduced remaining HP because max HP changed.")
            elseif health < newMaxHealth then
                if options.healIfNewMaxHealthHigher then
                    local diff = newMaxHealth - oldMaxHealth
                    if diff > 0 then
                        TEARollHelper:Debug("Increased remaining HP by " .. diff .. " because max HP increased.")
                        characterState.state.health.set(state.health + diff)
                    end
                end
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
                characterState.state.defence.numBraceCharges.restoreOne()
            end,
        },
        numBraceCharges = {
            get = function()
                return state.defence.numBraceCharges
            end,
            set = function(numBraceCharges)
                if numBraceCharges ~= state.defence.numBraceCharges then
                    state.defence.numBraceCharges = numBraceCharges
                    bus.fire(EVENTS.BRACE_CHARGES_CHANGED, numBraceCharges)
                end
            end,
            update = function()
                local numSlots = state.defence.numBraceCharges
                local maxNumSlots = rules.defence.getMaxBraceCharges()

                if numSlots > maxNumSlots then
                    characterState.state.defence.numBraceCharges.set(maxNumSlots)
                    TEARollHelper:Debug("Reduced remaining Brace charges because max slots changed.")
                elseif numSlots < maxNumSlots then
                    local diff = maxNumSlots - cache.maxNumBraceCharges
                    if diff > 0 then
                        TEARollHelper:Debug("Increased remaining Brace charges by " .. diff .. " because max slots increased.")
                        characterState.state.defence.numBraceCharges.restore(diff)
                    end
                end

                cache.maxNumBraceCharges = maxNumSlots
            end,
            use = function(numBraceCharges)
                if numBraceCharges > 0 and state.defence.numBraceCharges > 0 then
                    characterState.state.defence.numBraceCharges.set(state.defence.numBraceCharges - numBraceCharges)
                    bus.fire(EVENTS.BRACE_CHARGES_USED, numBraceCharges)
                end
            end,
            restore = function(numCharges)
                if state.defence.numBraceCharges + numCharges <= rules.defence.getMaxBraceCharges() then
                    characterState.state.defence.numBraceCharges.set(state.defence.numBraceCharges + numCharges)
                end
            end,
            --  used when cycling dmg prevented
            restoreOne = function()
                if state.defence.numBraceCharges < rules.defence.getMaxBraceCharges() then
                    characterState.state.defence.numBraceCharges.set(state.defence.numBraceCharges + 1)

                    -- prints msg to chat
                    bus.fire(EVENTS.BRACE_CHARGE_RESTORED)
                end
            end,
        },
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
            update = function()
                local numSlots = state.healing.numGreaterHealSlots
                local maxNumSlots = rules.healing.getMaxGreaterHealSlots()

                if numSlots > maxNumSlots then
                    characterState.state.healing.numGreaterHealSlots.set(maxNumSlots)
                    TEARollHelper:Debug("Reduced remaining greater heal slots because max slots changed.")
                elseif numSlots < maxNumSlots then
                    local diff = maxNumSlots - cache.maxNumGreaterHealSlots
                    if diff > 0 then
                        TEARollHelper:Debug("Increased remaining greater heal slots by " .. diff .. " because max slots increased.")
                        characterState.state.healing.numGreaterHealSlots.restore(diff)
                    end
                end

                cache.maxNumGreaterHealSlots = maxNumSlots
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
    consciousness = {
        get = function()
            return state.consciousness
        end,
        set = function(consciousnessState)
            state.consciousness = consciousnessState
        end
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
            update = function()
                local numSlots = state.featsAndTraits.numBloodHarvestSlots
                local maxNumSlots = rules.offence.getMaxBloodHarvestSlots()

                if numSlots > maxNumSlots then
                    characterState.state.featsAndTraits.numBloodHarvestSlots.set(maxNumSlots)
                    TEARollHelper:Debug("Reduced remaining " .. FEATS.BLOOD_HARVEST.name .. " charges because max slots changed.")
                elseif numSlots < maxNumSlots then
                    local diff = maxNumSlots - cache.maxNumBloodHarvestSlots
                    if diff > 0 then
                        TEARollHelper:Debug("Increased remaining " .. FEATS.BLOOD_HARVEST.name .. " charges by " .. diff .. " because max slots increased.")
                        characterState.state.featsAndTraits.numBloodHarvestSlots.set(numSlots + diff)
                    end
                end

                cache.maxNumBloodHarvestSlots = maxNumSlots
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
                if numCharges ~= state.featsAndTraits.numTraitCharges[traitID] then
                    TEARollHelper:Debug("SET numTraitCharges for", traitID)
                    state.featsAndTraits.numTraitCharges[traitID] = numCharges
                end
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

local function resetRemainingOutOfCombatHeals(reason)
    characterState.state.healing.remainingOutOfCombatHeals.reset()
    TEARollHelper:Debug("Reset remaining out of combat heals because " .. reason)
end

local onStatUpdate = {
    [STATS.offence] = function()
        characterState.state.featsAndTraits.numBloodHarvestSlots.update()
    end,
    [STATS.defence] = function()
        -- if player swaps away from build with brace, then back again later, we want them to have full brace charges.
        -- but we don't want to reset them when swapping from one build with brace to another with brace.
        -- hence the check here.
        if not rules.defence.canUseBraceSystem() then
            characterState.state.defence.numBraceCharges.set(rules.defence.getMaxBraceCharges()) -- TODO
        end
    end,
    [STATS.spirit] = function()
        characterState.state.healing.numGreaterHealSlots.update()
    end,
    [STATS.stamina] = function()
        updateMaxHealth({
            healIfNewMaxHealthHigher = true
        })
    end,
}

bus.addListener(EVENTS.CHARACTER_STAT_CHANGED, function(stat, value)
    onStatUpdate[stat]()
end)

local function onFeatUpdate()
    characterState.state.defence.numBraceCharges.update()
    characterState.state.healing.numGreaterHealSlots.update()
    resetRemainingOutOfCombatHeals("feat changed")
    character.clearExcessTraits()
end

bus.addListener(EVENTS.FEAT_CHANGED, function(featID)
    onFeatUpdate()

    if featID == FEATS.BLOOD_HARVEST.id then
        characterState.state.featsAndTraits.numBloodHarvestSlots.update()
    end
end)

local function updateMaxTraitCharges(reason, options)
    TEARollHelper:Debug("Updating max trait charges because " .. reason)

    for traitID, trait in pairs(TRAITS) do
        if trait.numCharges then
            local curNumCharges = characterState.state.featsAndTraits.numTraitCharges.get(traitID)
            local maxNumCharges = rules.traits.getMaxTraitCharges(trait)
            local shouldAdjust = false

            -- we use this if the update is caused by something that can't be be done on the fly in events (eg weaknesses)
            -- when you change your character sheet outside of events you want all charges to be at max.
            shouldAdjust = options and options.restoreAllCharges

            if not shouldAdjust then
                -- in case player swaps back to one of them later. Only for things that can be done during events.
                shouldAdjust = options and options.restoreChargesOfRemovedTraits and not character.hasTrait(trait)
            end

            if not shouldAdjust then
                -- adjust for new maximum if necessary.
                shouldAdjust = curNumCharges > maxNumCharges
            end

            if shouldAdjust then
                characterState.state.featsAndTraits.numTraitCharges.set(traitID, maxNumCharges)
            end
        end
    end
end

local function onTraitsChanged()
    updateMaxTraitCharges("traits changed", {
        restoreChargesOfRemovedTraits = true
    })
end

bus.addListener(EVENTS.TRAITS_CHANGED, onTraitsChanged)

local function onBrightBurnerAdded()
    updateMaxTraitCharges("Bright Burner was added")
    cache.hasBrightBurner = true
end

local function onBrightBurnerRemoved()
    updateMaxTraitCharges("Bright Burner was removed", {
        restoreAllCharges = true
    })
    cache.hasBrightBurner = false
end

bus.addListener(EVENTS.WEAKNESS_ADDED, function(weaknessID)
    if weaknessID == WEAKNESSES.BRIGHT_BURNER.id then
        onBrightBurnerAdded()
    elseif weaknessID == WEAKNESSES.FRAGILE.id then
        updateMaxHealth()
    elseif weaknessID == WEAKNESSES.TEMPERED_BENEVOLENCE.id then
        characterState.state.healing.numGreaterHealSlots.update()
    end
end)

bus.addListener(EVENTS.WEAKNESS_REMOVED, function(weaknessID)
    if weaknessID == WEAKNESSES.BRIGHT_BURNER.id then
        onBrightBurnerRemoved()
    elseif weaknessID == WEAKNESSES.FRAGILE.id then
        updateMaxHealth({
            -- weaknesses are only changed outside of events, so set HP to full.
            healIfNewMaxHealthHigher = true
        })
    elseif weaknessID == WEAKNESSES.TEMPERED_BENEVOLENCE.id then
        characterState.state.healing.numGreaterHealSlots.update()
    end

    character.clearExcessTraits()
end)

bus.addListener(EVENTS.PROFILE_CHANGED, function()
    for stat in pairs(STATS) do
        onStatUpdate[stat]()
    end

    onFeatUpdate()
    onTraitsChanged()
    -- weakness changes are currently covered by our stat/trait updates.
    -- with exception of bright burner being removed (added is also handled by onTraitsChanged)
    if cache.hasBrightBurner and not character.hasWeakness(WEAKNESSES.BRIGHT_BURNER) then
        onBrightBurnerRemoved()
    end
    cache.hasBrightBurner  = character.hasWeakness(WEAKNESSES.BRIGHT_BURNER)
end)

characterState.summariseHP = summariseHP
characterState.summariseState = summariseState