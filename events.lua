local _, ns = ...

local buffs = ns.buffs
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character
local constants = ns.constants
local traits = ns.resources.traits
local turnState = ns.state.turn
local weaknesses = ns.resources.weaknesses

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
            TEARollHelper:Print("Added debuff:", WEAKNESSES.TEMPO.name)
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