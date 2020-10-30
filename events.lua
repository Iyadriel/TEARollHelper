local _, ns = ...

local buffs = ns.buffs
local buffsState = ns.state.buffs
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character
local constants = ns.constants
local turnState = ns.state.turn

local criticalWounds = ns.resources.criticalWounds
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local BUFF_TYPES = constants.BUFF_TYPES
local EVENTS = bus.EVENTS
local INCOMING_HEAL_SOURCES = constants.INCOMING_HEAL_SOURCES
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
            local debuff = buffsState.state.buffLookup.getWeaknessDebuff(weakness)
            if distanceFromEnemy == weakness.distanceFromEnemy then
                if not debuff then
                    buffs.addWeaknessDebuff(weakness)
                end
            elseif debuff then
                buffsState.state.activeBuffs.remove(debuff)
            end
        end
    end
end)

bus.addListener(EVENTS.ENEMY_CHANGED, function(enemyId)
    local racialTrait = character.getPlayerRacialTrait()
    if racialTrait.buffAgainstEnemies then
        local buff = buffsState.state.buffLookup.getRacialBuff()

        if racialTrait.buffAgainstEnemies[enemyId] then
            if not buff then
                buffs.addRacialBuff(racialTrait)
            end
        elseif buff then
            buffsState.state.activeBuffs.remove(buff)
        end
    end
end)

bus.addListener(EVENTS.ZONE_CHANGED, function(zoneId)
    local racialTrait = character.getPlayerRacialTrait()
    if racialTrait.zones then
        local buff = buffsState.state.buffLookup.getRacialBuff()

        if racialTrait.zones[zoneId] then
            if not buff then
                buffs.addRacialBuff(racialTrait)
            end
        elseif buff then
            buffsState.state.activeBuffs.remove(buff)
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
    characterState.state.healing.remainingOutOfCombatHeals.restore()
    restoreSecondWindCharge()

    local debuff = buffsState.state.buffLookup.getWeaknessDebuff(WEAKNESSES.CORRUPTED)
    if debuff then
        buffsState.state.activeBuffs.remove(debuff)
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
    buffsState.state.activeBuffs.removeAtIndex(index)
    bus.fire(EVENTS.BUFF_EXPIRED, buff.label)
end

local function applyDamageTick(buff)
    local damagePerTick = buff.damagePerTick

    -- Hack for "You take 5 more damage from all sources except for Internal Bleeding"
    local criticalWoundBuffId = criticalWounds.WOUNDS.INTERNAL_BLEEDING:GetBuffID()
    local deepBruising = criticalWounds.WOUNDS.DEEP_BRUISING
    if buff.id == criticalWoundBuffId and buffsState.state.buffLookup.getCriticalWoundDebuff(deepBruising) then
        damagePerTick = damagePerTick - deepBruising.buff.amount
    end

    characterState.state.health.damage(damagePerTick, { canBeMitigated = buff.canBeMitigated })
end

local function applyHealTick(buff)
    characterState.state.health.heal(buff.healingPerTick, INCOMING_HEAL_SOURCES.OTHER_PLAYER)
end

bus.addListener(EVENTS.TURN_STARTED, function(index, turnTypeID)
    local activeBuffs = buffsState.state.activeBuffs.get()

    -- we stick these buffs in separate table to iterate them in appropriate order
    -- (dmg taken should come first)
    local dmgOverTimeBuffs = {}
    local healingOverTimeBuffs = {}

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
            end
        end

        if buff.turnTypeID == nil or buff.turnTypeID == turnTypeID then
            if buff.types[BUFF_TYPES.DAMAGE_OVER_TIME] then
                table.insert(dmgOverTimeBuffs, buff)
            end
            if buff.types[BUFF_TYPES.HEALING_OVER_TIME] then
                table.insert(healingOverTimeBuffs, buff)
            end
        end
    end

    for _, buff in ipairs(dmgOverTimeBuffs) do
        applyDamageTick(buff)
    end

    for _, buff in ipairs(healingOverTimeBuffs) do
        applyHealTick(buff)
    end
end)

bus.addListener(EVENTS.TURN_FINISHED, function(index, turnTypeID)
    local activeBuffs = buffsState.state.activeBuffs.get()

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

local function applyRemainingHealAmount(regrowth)
    local remainingHealAmount = regrowth.remainingTurns * regrowth.healingPerTick
    if remainingHealAmount > 0 then
        characterState.state.health.heal(remainingHealAmount, INCOMING_HEAL_SOURCES.OTHER_PLAYER)
    end
end

bus.addListener(EVENTS.COMBAT_OVER, function()
    local activeBuffs = buffsState.state.activeBuffs.get()

    for i = #activeBuffs, 1, -1 do
        local buff = activeBuffs[i]

        if buff.id == "HoT_" .. TRAITS.FAELUNES_REGROWTH.name then
            applyRemainingHealAmount(buff)
        end

        if buff.expireOnCombatEnd then
            expireBuff(i, buff)
        end
    end
end)

bus.addListener(EVENTS.ACTION_PERFORMED, function(actionType)
    local activeBuffs = buffsState.state.activeBuffs.get()

    for i = #activeBuffs, 1, -1 do
        local buff = activeBuffs[i]
        if buff.expireAfterFirstAction then
            if type(buff.expireAfterFirstAction) == "table" then
                if buff.expireAfterFirstAction[actionType] then
                    expireBuff(i, buff)
                end
            else
                expireBuff(i, buff)
            end
        end
    end
end)