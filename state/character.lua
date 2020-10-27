local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits
local characterState = ns.state.character
local turnState = ns.state.turn
local weaknesses = ns.resources.weaknesses

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

        defence = {
            damagePrevented = 0,
        },

        healing = {
            numGreaterHealSlots = rules.healing.getMaxGreaterHealSlots(),
            remainingOutOfCombatHeals = rules.healing.getMaxOutOfCombatHeals(),
            excess = 0,
        },

        featsAndTraits = {
            numBloodHarvestSlots = rules.offence.getMaxBloodHarvestSlots(),
            numTraitCharges = numTraitCharges,
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
            health = max(0, health)

            if health ~= state.health then
                state.health = health
                bus.fire(EVENTS.CHARACTER_HEALTH, state.health)
            end
        end,
        damage = function(dmgTaken, ignoreDamageTakenBuffs)
            local damageTakenBuff = 0

            -- defence and melee save pre-apply these so they can display correct action results
            -- also used for damage that cannot be prevented
            if not ignoreDamageTakenBuffs then
                damageTakenBuff = buffsState.state.buffs.damageTaken.get()
            end

            local damage = rules.effects.calculateDamageTaken(dmgTaken, state.health, damageTakenBuff)
            characterState.state.health.set(state.health - damage.damageTaken)
            bus.fire(EVENTS.DAMAGE_TAKEN, damage.incomingDamage, damage.damageTaken, damage.overkill)
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
        excess = basicGetSet("healing", "excess"),
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
end)

characterState.summariseHP = summariseHP
characterState.summariseState = summariseState