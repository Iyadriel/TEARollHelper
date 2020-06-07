local _, ns = ...

local buffs = ns.buffs
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
local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES
local state

characterState.initState = function()
    state = {
        health = character.getPlayerMaxHPWithoutBuffs(),

        healing = {
            numGreaterHealSlots = rules.healing.getMaxGreaterHealSlots(),
            excess = 0,
        },

        featsAndTraits = {
            numBloodHarvestSlots = rules.offence.getMaxBloodHarvestSlots(),
            numBulwarkCharges = TRAITS.BULWARK.numCharges,
            numSecondWindCharges = TRAITS.SECOND_WIND.numCharges,
            numVindicationCharges = TRAITS.VINDICATION.numCharges,
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

local function summariseState()
    local out = {
        characterState.state.health.get(),
        "/",
        character.getPlayerMaxHP(),
        " HP",
--[[         "|n|n|nFeat: ",
        character.getPlayerFeat().name,
        "|n|n|nGreater Heal slots: ",
        state.healing.numGreaterHealSlots.get(),
        "/",
        rules.healing.getMaxGreaterHealSlots() ]]
    }

    return table.concat(out)
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
            state.health = state.health - dmgTaken
            bus.fire(EVENTS.CHARACTER_HEALTH, state.health)
            bus.fire(EVENTS.DAMAGE_TAKEN, dmgTaken)
        end,
        heal = function(amountHealed)
            local maxHP = character.getPlayerMaxHP()
            local overhealing = max(0, state.health + amountHealed - maxHP)
            local netAmountHealed = amountHealed - overhealing

            characterState.state.health.set(state.health + netAmountHealed)

            bus.fire(EVENTS.HEALED, amountHealed, netAmountHealed, overhealing)
        end
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
        numBulwarkCharges = basicGetSet("featsAndTraits", "numBulwarkCharges", function(numCharges)
            bus.fire(EVENTS.TRAIT_CHARGES_CHANGED, TRAITS.BULWARK.id, numCharges)
        end),
        numSecondWindCharges = basicGetSet("featsAndTraits", "numSecondWindCharges"),
        numVindicationCharges = basicGetSet("featsAndTraits", "numVindicationCharges"),
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
            bus.fire(EVENTS.CHARACTER_MAX_HEALTH, character.getPlayerMaxHP())
        end),
    },
    activeBuffs = {
        get = function ()
            return state.activeBuffs
        end,
        add = function(buff)
            table.insert(state.activeBuffs, buff)
            characterState.state.buffLookup.add(buff)

            if buff.type == buffs.BUFF_TYPES.STAT then
                for stat, amount in pairs(buff.stats) do
                    local statBuff = characterState.state.buffs[stat]
                    statBuff.set(statBuff.get() + amount)
            end
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

            if buff.type == buffs.BUFF_TYPES.STAT then
                for stat, amount in pairs(buff.stats) do
                    local statBuff = characterState.state.buffs[stat]
                    statBuff.set(statBuff.get() - amount)
                end
            end

            table.remove(state.activeBuffs, index)
            characterState.state.buffLookup.remove(buff)
        end,
        cancel = function(index)
            -- cancel is for buffs manually removed by the player.
            characterState.state.activeBuffs.removeAtIndex(index)
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
        getAdvantageBuff = function(action)
            local activeBuffs = characterState.state.activeBuffs.get()
            for _, buff in ipairs(activeBuffs) do
                if buff.type == buffs.BUFF_TYPES.ADVANTAGE and buff.actions[action] then
                    return buff
                end
            end
            return nil
        end,
        getDisadvantageDebuff = function(action)
            local activeBuffs = characterState.state.activeBuffs.get()
            for _, buff in ipairs(activeBuffs) do
                if buff.type == buffs.BUFF_TYPES.DISADVANTAGE and buff.actions[action] then
                    return buff
                end
            end
            return nil
        end,
        getWeaknessDebuff = function(weakness)
            return characterState.state.buffLookup.get("weakness_" .. weakness.id)
        end,
        getRacialBuff = function()
            return characterState.state.buffLookup.get("racial")
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

bus.addListener(EVENTS.ENEMY_CHANGED, function(enemyId)
    local racialTrait = character.getPlayerRacialTrait()
    if racialTrait.buffAgainstEnemies then
        local buff = characterState.state.buffLookup.getRacialBuff()

        if racialTrait.buffAgainstEnemies[enemyId] then
            if not buff then
                buffs.addRacialBuff(racialTrait)
            end
        elseif buff then
            characterState.state.activeBuffs.remove(buff)
        end
    end
end)

bus.addListener(EVENTS.ZONE_CHANGED, function(zoneId)
    local racialTrait = character.getPlayerRacialTrait()
    if racialTrait.zones then
        local buff = characterState.state.buffLookup.getRacialBuff()

        if racialTrait.zones[zoneId] then
            if not buff then
                buffs.addRacialBuff(racialTrait)
            end
        elseif buff then
            characterState.state.activeBuffs.remove(buff)
        end
    end
end)

bus.addListener(EVENTS.COMBAT_OVER, function()
    local getCharges = characterState.state.featsAndTraits.numSecondWindCharges.get

    local oldNumCharges = getCharges()
    characterState.state.featsAndTraits.numSecondWindCharges.set(TRAITS.SECOND_WIND.numCharges)
    if getCharges() ~= oldNumCharges then
        TEARollHelper:Print(TEARollHelper.COLOURS.TRAITS.GENERIC .. TRAITS.SECOND_WIND.name .. " charge restored.")
    end
end)

bus.addListener(EVENTS.TURN_INCREMENTED, function()
    local activeBuffs = characterState.state.activeBuffs.get()

    for i = #activeBuffs, 1, -1 do
        local buff = activeBuffs[i]
        if buff.remainingTurns then
            if buff.remainingTurns <= 0 then
                characterState.state.activeBuffs.removeAtIndex(i)
                bus.fire(EVENTS.BUFF_EXPIRED, buff.label)
            else
                buff.remainingTurns = buff.remainingTurns - 1
                TEARollHelper:Debug("Decremented buff remaining turns at index " .. i)
            end
        end
    end
end)

bus.addListener(EVENTS.CHARACTER_MAX_HEALTH, function(maxHP)
    local hp = characterState.state.health.get()

    if hp > maxHP then
        characterState.state.health.set(maxHP)
        TEARollHelper:Debug("Reduced remaining HP because max HP changed.")
    elseif hp < maxHP and not turnState.state.inCombat.get() then
        characterState.state.health.set(maxHP)
        TEARollHelper:Debug("Increased remaining HP because max HP changed.")
    end
end)

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
        bus.fire(EVENTS.CHARACTER_MAX_HEALTH, character.getPlayerMaxHP())
    end
end)

bus.addListener(EVENTS.FEAT_CHANGED, function()
    updateGreaterHealSlots("feat changed")
end)

bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, function()
    local racialBuff = characterState.state.buffLookup.getRacialBuff()
    if racialBuff then
        characterState.state.activeBuffs.remove(racialBuff)
        TEARollHelper:Debug("Removed racial trait buff because racial trait in character sheet changed.")
    end
end)

bus.addListener(EVENTS.WEAKNESS_ADDED, function(weaknessID)
    if weaknessID == WEAKNESSES.FRAGILE.id then
        bus.fire(EVENTS.CHARACTER_MAX_HEALTH, character.getPlayerMaxHP())
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
        bus.fire(EVENTS.CHARACTER_MAX_HEALTH, character.getPlayerMaxHP())
    elseif weaknessID == WEAKNESSES.FATELESS.id then
        local numFatePoints = characterState.state.numFatePoints.get()
        local maxFatePoints = rules.rolls.getMaxFatePoints()
        if numFatePoints < maxFatePoints and not turnState.state.inCombat.get() then
            characterState.state.numFatePoints.set(maxFatePoints)
            TEARollHelper:Debug("Increased remaining fate points because player no longer has Fateless weakness.")
        end
    elseif weaknessID == WEAKNESSES.TIMID.id then
        local weaknessDebuff = characterState.state.buffLookup.getWeaknessDebuff(WEAKNESSES.TIMID)
        if weaknessDebuff then
            characterState.state.activeBuffs.remove(weaknessDebuff)
            TEARollHelper:Debug("Removed weakness debuff because player no longer has Timid weakness.")
        end
    end
end)

characterState.summariseState = summariseState