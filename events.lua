local _, ns = ...

local buffs = ns.buffs
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character
local constants = ns.constants
local traits = ns.resources.traits
local turnState = ns.state.turn
local weaknesses = ns.resources.weaknesses

local BUFF_TYPES = constants.BUFF_TYPES
local EVENTS = bus.EVENTS
local TRAITS = traits.TRAITS
local TURN_TYPES = constants.TURN_TYPES
local WEAKNESSES = weaknesses.WEAKNESSES

-- [[ Combat ]]

bus.addListener(EVENTS.DAMAGE_TAKEN, function()
    if character.hasWeakness(WEAKNESSES.TEMPO) then
        local turnTypeId = turnState.state.type.get()
        if turnTypeId == TURN_TYPES.ENEMY.id then
            buffs.addWeaknessDebuff(WEAKNESSES.TEMPO)
        end
    end
end)

-- [[ Environment ]]

bus.addListener(EVENTS.DISTANCE_FROM_ENEMY_CHANGED, function(distanceFromEnemy)
    local playerWeaknesses = character.getPlayerWeaknesses()
    for weaknessID in pairs(playerWeaknesses) do
        local weakness = WEAKNESSES[weaknessID]

        if weakness.distanceFromEnemy then
            local debuff = characterState.state.buffLookup.getWeaknessDebuff(weakness)
            if distanceFromEnemy == weakness.distanceFromEnemy then
                if not debuff then
                    buffs.addWeaknessDebuff(weakness)
                end
            elseif debuff then
                characterState.state.activeBuffs.remove(debuff)
            end
        end
    end
end)

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

-- [[ Turns ]]

local function restoreSecondWindCharge()
    local getSetCharges = characterState.state.featsAndTraits.numTraitCharges

    local oldNumCharges = getSetCharges.get(TRAITS.SECOND_WIND.id)
    getSetCharges.set(TRAITS.SECOND_WIND.id, TRAITS.SECOND_WIND.numCharges)
    if getSetCharges.get(TRAITS.SECOND_WIND.id) ~= oldNumCharges then
        TEARollHelper:Print(TEARollHelper.COLOURS.TRAITS.GENERIC .. TRAITS.SECOND_WIND.name .. " charge restored.")
    end
end

bus.addListener(EVENTS.COMBAT_OVER, function()
    restoreSecondWindCharge()
    local debuff = characterState.state.buffLookup.getWeaknessDebuff(WEAKNESSES.CORRUPTED)
    if debuff then
        characterState.state.activeBuffs.remove(debuff)
        TEARollHelper:Print("Corruption stacks removed, max health returned to normal.")
    end
end)

local function setRemainingTurns(buff, remainingTurns, turnTypeId)
    if type(buff.remainingTurns) == "table" then
        buff.remainingTurns[turnTypeId] = remainingTurns
    else
        buff.remainingTurns = remainingTurns
    end
end

local function expireBuff(index, buff)
    characterState.state.activeBuffs.removeAtIndex(index)
    bus.fire(EVENTS.BUFF_EXPIRED, buff.label)
end

local function applyHealTick(buff)
    if buff.types[BUFF_TYPES.HEALING_OVER_TIME] then
        characterState.state.health.heal(buff.healingPerTick)
    end
end

bus.addListener(EVENTS.TURN_STARTED, function(index, turnTypeID)
    local activeBuffs = characterState.state.activeBuffs.get()

    for i = #activeBuffs, 1, -1 do
        local buff = activeBuffs[i]

        local remainingTurns
        if type(buff.remainingTurns) == "table" then
            remainingTurns = buff.remainingTurns[turnTypeID]
        else
            remainingTurns = buff.remainingTurns
        end

        if remainingTurns then
             -- this check shouldn't be needed because buffs with 0 turns left are removed at the end of a turn
             -- but just to be sure
            if remainingTurns > 0 then
                setRemainingTurns(buff, remainingTurns - 1, turnTypeID)
                TEARollHelper:Debug("Decremented buff remaining turns at index " .. i)

                applyHealTick(buff)
            end
        end
    end
end)

bus.addListener(EVENTS.TURN_FINISHED, function(index, turnTypeID)
    local activeBuffs = characterState.state.activeBuffs.get()

    for i = #activeBuffs, 1, -1 do
        local buff = activeBuffs[i]

        local remainingTurns
        if type(buff.remainingTurns) == "table" then
            remainingTurns = buff.remainingTurns[turnTypeID]
        else
            remainingTurns = buff.remainingTurns
        end

        if remainingTurns and remainingTurns <= 0 then
            expireBuff(i, buff)
        end
    end
end)

bus.addListener(EVENTS.COMBAT_OVER, function()
    local activeBuffs = characterState.state.activeBuffs.get()

    for i = #activeBuffs, 1, -1 do
        local buff = activeBuffs[i]

        if buff.expireOnCombatEnd then
            expireBuff(i, buff)
        end
    end
end)