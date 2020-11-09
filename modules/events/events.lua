local _, ns = ...

local buffs = ns.buffs
local buffsState = ns.state.buffs
local bus = ns.bus
local character = ns.character
local characterState = ns.state.character
local constants = ns.constants
local models = ns.models
local settings = ns.settings
local turnState = ns.state.turn
local ui = ns.ui

local criticalWounds = ns.resources.criticalWounds
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local BuffEffectDamageOverTime = models.BuffEffectDamageOverTime
local BuffEffectDamageTaken = models.BuffEffectDamageTaken
local BuffEffectHealingOverTime = models.BuffEffectHealingOverTime

local EVENTS = bus.EVENTS
local INCOMING_HEAL_SOURCES = constants.INCOMING_HEAL_SOURCES
local TRAITS = traits.TRAITS
local TURN_TYPES = constants.TURN_TYPES
local WEAKNESSES = weaknesses.WEAKNESSES

-- [[ Buff effects ]]

bus.addListener(EVENTS.MAX_HEALTH_EFFECT, function()
    local shouldRestoreMissingHealth = false
    characterState.state.maxHealth.update(shouldRestoreMissingHealth)
end)

-- [[ Combat ]]

bus.addListener(EVENTS.DAMAGE_TAKEN, function()
    if character.hasWeakness(WEAKNESSES.TEMPO) then
        local turnTypeID = turnState.state.type.get()
        if turnTypeID == TURN_TYPES.ENEMY.id then
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
                debuff:Remove()
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
            buff:Remove()
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
            buff:Remove()
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
        debuff:Remove()
        TEARollHelper:Print("Corruption stacks removed, max health returned to normal.")
    end
end)

local function applyDamageTick(buff)
    local dotEffect = buff:GetEffectOfType(BuffEffectDamageOverTime)
    local damagePerTick = dotEffect.damagePerTick

    -- Hack for "You take 5 more damage from all sources except for Internal Bleeding"
    local isIB = buff.GetCriticalWoundID and buff:GetCriticalWoundID() == criticalWounds.WOUNDS.INTERNAL_BLEEDING.id
    local deepBruising = criticalWounds.WOUNDS.DEEP_BRUISING
    local hasDB = deepBruising:IsActive()

    if isIB and hasDB then
        local damageToSubtract = deepBruising:GetDebuff():GetEffectOfType(BuffEffectDamageTaken).value
        damagePerTick = damagePerTick - damageToSubtract
    end

    characterState.state.health.damage(damagePerTick, { canBeMitigated = dotEffect.canBeMitigated })
end

local function applyHealTick(effect)
    characterState.state.health.heal(effect.healingPerTick, INCOMING_HEAL_SOURCES.OTHER_PLAYER)
end

bus.addListener(EVENTS.TURN_STARTED, function(index, turnTypeID)
    local activeBuffs = buffsState.state.activeBuffs.get()

    -- we stick these buffs in separate table to iterate them in appropriate order
    -- (dmg taken should come first)
    local dmgOverTimeBuffs = {}
    local healingOverTimeEffects = {}

    for i = #activeBuffs, 1, -1 do
        local buff = activeBuffs[i]

        if buff.duration then
            buff.duration:DecrementRemainingTurns(turnTypeID)
        end

        if buff.turnTypeID == nil or buff.turnTypeID == turnTypeID then
            local dotEffect = buff:GetEffectOfType(BuffEffectDamageOverTime)
            if dotEffect and (not dotEffect.turnTypeID or dotEffect.turnTypeID == turnTypeID) then
                table.insert(dmgOverTimeBuffs, buff)
            end

            local hotEffect = buff:GetEffectOfType(BuffEffectHealingOverTime)
            if hotEffect then
                table.insert(healingOverTimeEffects, hotEffect)
            end
        end
    end

    for _, buff in ipairs(dmgOverTimeBuffs) do
        applyDamageTick(buff)
    end

    for _, effect in ipairs(healingOverTimeEffects) do
        applyHealTick(effect)
    end
end)

bus.addListener(EVENTS.TURN_FINISHED, function(index, turnTypeID)
    local activeBuffs = buffsState.state.activeBuffs.get()

    for i = #activeBuffs, 1, -1 do
        local buff = activeBuffs[i]

        if buff:ShouldExpire(turnTypeID) then
            buff:Expire()
        end
    end
end)

local function applyRemainingHealAmount(regrowth)
    local remainingHealAmount = regrowth.duration.remainingTurns * regrowth.effects[1].healingPerTick
    if remainingHealAmount > 0 then
        characterState.state.health.heal(remainingHealAmount, INCOMING_HEAL_SOURCES.OTHER_PLAYER)
    end
end

bus.addListener(EVENTS.COMBAT_OVER, function()
    local activeBuffs = buffsState.state.activeBuffs.get()

    for i = #activeBuffs, 1, -1 do
        local buff = activeBuffs[i]

        if buff.traitID == TRAITS.FAELUNES_REGROWTH.id then
            applyRemainingHealAmount(buff)
        end

        local duration = buff:GetDuration()
        if duration and duration:ExpiresOnCombatEnd() then
            buff:Expire()
        end
    end
end)

bus.addListener(EVENTS.ACTION_PERFORMED, function(actionType)
    local activeBuffs = buffsState.state.activeBuffs.get()

    for i = #activeBuffs, 1, -1 do
        local buff = activeBuffs[i]
        local duration = buff:GetDuration()

        if duration and (duration:ExpiresAfterAnyAction() or duration:ExpiresAfterAction(actionType)) then
            buff:Expire()
        end
    end
end)

-- [[ Party ]]

-- TODO find a way to update only the party tab
local function updateTurnUI()
    if settings.refreshOnPartyUpdate.get() then
        ui.update(ui.modules.turn.name)
    end
end
bus.addListener(EVENTS.PARTY_MEMBER_ADDED, updateTurnUI)
bus.addListener(EVENTS.PARTY_MEMBER_UPDATED, updateTurnUI)