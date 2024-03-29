local _, ns = ...

local bus = ns.bus

local EVENTS = {
    -- System
    PROFILE_CHANGED = "PROFILE_CHANGED",
    STATE_READY = "STATE_READY",

    -- Character sheet
    CHARACTER_HEALTH = "CHARACTER_HEALTH", -- newHealth
    CHARACTER_MAX_HEALTH = "CHARACTER_MAX_HEALTH", -- newHealth
    CHARACTER_STAT_CHANGED = "CHARACTER_STAT_CHANGED", -- stat, value
    FEAT_CHANGED = "FEAT_CHANGED", -- featID
    TRAITS_CHANGED = "TRAITS_CHANGED",
    WEAKNESSES_CHANGED = "WEAKNESSES_CHANGED",
    WEAKNESS_ADDED = "WEAKNESS_ADDED", -- weaknessID
    WEAKNESS_REMOVED = "WEAKNESS_REMOVED", -- weaknessID
    UTILITY_TRAITS_CHANGED = "UTILITY_TRAITS_CHANGED",
    RACIAL_TRAIT_CHANGED = "RACIAL_TRAIT_CHANGED", -- racialTraitID

    -- Environment
    DISTANCE_FROM_ENEMY_CHANGED = "DISTANCE_FROM_ENEMY_CHANGED", -- distanceFromEnemy
    ENEMY_CHANGED = "ENEMY_CHANGED", -- enemyId
    ZONE_CHANGED = "ZONE_CHANGED", -- zoneId
    UNIT_ADDED = "UNIT_ADDED", -- isLocal, Unit
    UNIT_UPDATED = "UNIT_UPDATED", -- isLocal, Unit
    UNIT_REMOVED = "UNIT_REMOVED", -- isLocal, unitIndex
    UNITS_REPLACED = "UNITS_REPLACED", -- isLocal

    -- Resources
    BLOOD_HARVEST_CHARGES_CHANGED = "BLOOD_HARVEST_CHARGES_CHANGED", -- numCharges
    BLOOD_HARVEST_CHARGES_USED = "BLOOD_HARVEST_CHARGES_USED", -- numCharges
    BRACE_CHARGES_CHANGED = "BRACE_CHARGES_CHANGED", -- numCharges
    BRACE_CHARGES_USED = "BRACE_CHARGES_USED", -- numCharges
    FATE_POINT_USED = "FATE_POINT_USED",
    GREATER_HEAL_CHARGES_CHANGED = "GREATER_HEAL_CHARGES_CHANGED", -- numCharges
    GREATER_HEAL_CHARGES_USED = "GREATER_HEAL_CHARGES_USED", -- numCharges

    -- Actions
    ACTION_PERFORMED = "ACTION_PERFORMED", -- actionType, action, hideMsg

    -- Character effects
    CONSCIOUSNESS_CHANGED = "CONSCIOUSNESS_CHANGED", -- consciousnessState
    CRITICAL_WOUND_TOGGLED = "CRITICAL_WOUND_TOGGLED", -- criticalWoundID
    DAMAGE_PREVENTED = "DAMAGE_PREVENTED", -- damagePrevented
    BRACE_CHARGE_RESTORED = "BRACE_CHARGE_RESTORED",
    DAMAGE_TAKEN = "DAMAGE_TAKEN", -- incomingDamage, damageTaken, overkill
    HEALED = "HEALED", -- amountHealed, netAmountHealed, overHealing
    TRAIT_ACTIVATED = "TRAIT_ACTIVATED", -- traitID, msg?

    -- Buffs
    ROLL_BUFFS_CHANGED = "ROLL_BUFFS_CHANGED",
    ROLL_BUFF_ADDED = "ROLL_BUFF_ADDED", -- turnTypeID, amount
    DAMAGE_ROLL_BUFF_ADDED = "DAMAGE_ROLL_BUFF_ADDED", -- amount
    STAT_BUFF_ADDED = "STAT_BUFF_ADDED", -- stat, amount
    BASE_DMG_BUFF_ADDED = "BASE_DMG_BUFF_ADDED", -- amount
    BUFF_STACK_ADDED = "BUFF_STACK_ADDED", -- buff
    WEAKNESS_DEBUFF_ADDED = "WEAKNESS_DEBUFF_ADDED", -- weaknessID
    HEALING_OVER_TIME_BUFF_ADDED = "HEALING_OVER_TIME_BUFF_ADDED", -- label
    FEAT_BUFF_ADDED = "FEAT_BUFF_ADDED", -- featID
    BUFF_EXPIRED = "BUFF_EXPIRED", -- id, label
    BUFF_CANCELLED = "BUFF_CANCELLED", -- id

    -- Buff effects
    MAX_HEALTH_EFFECT = "MAX_HEALTH_EFFECT",

    -- Rolling
    ROLL_CHANGED = "ROLL_CHANGED", -- action, roll
    FATE_ROLLED = "FATE_ROLLED", -- action, roll

    -- Turn
    COMBAT_STARTED = "COMBAT_STARTED",
    COMBAT_OVER = "COMBAT_OVER",
    TURN_STARTED = "TURN_STARTED", -- index, turnTypeID
    TURN_FINISHED = "TURN_FINISHED", -- index, turnTypeID

    -- Comms
    COMMS_READY = "COMMS_READY",
    COMMS_FORCE_PARTY_REFRESH = "COMMS_FORCE_PARTY_REFRESH",
    COMMS_BROADCAST_UNIT_LIST = "COMMS_BROADCAST_UNIT_LIST",

    -- Party
    PARTY_MEMBER_ADDED = "PARTY_MEMBER_ADDED", -- player
    PARTY_MEMBER_UPDATED = "PARTY_MEMBER_UPDATED", -- player
}

local listeners = {}

local function addListener(event, callback)
    if not EVENTS[event] then
        TEARollHelper:Print("[bus] Attempted to add listener to invalid event:", event)
        return
    end
    if not listeners[event] then
        listeners[event] = {}
    end
    table.insert(listeners[event], callback)
end

local function fire(event, ...)
    TEARollHelper:Debug("[bus]", event, ...)
    if not listeners[event] then return end
    for _, callback in ipairs(listeners[event]) do
        callback(...)
    end
end

bus.EVENTS = EVENTS
bus.addListener = addListener
bus.fire = fire