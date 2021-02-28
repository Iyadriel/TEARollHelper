local _, ns = ...

local buffsState = ns.state.buffs
local bus = ns.bus
local characterState = ns.state.character
local constants = ns.constants
local models = ns.models
local rules = ns.rules

local Buff = models.Buff
local BuffDuration = models.BuffDuration
local BuffEffectMaxHealth = models.BuffEffectMaxHealth
local BuffEffectSpecial = models.BuffEffectSpecial

local EVENTS = bus.EVENTS
local SPECIAL_ACTIONS = constants.SPECIAL_ACTIONS
local STATES = constants.CONSCIOUSNESS_STATES
local TURN_TYPES = constants.TURN_TYPES

local fadingConsciousness = Buff:New(
    "fading",
    "Fading consciousness",
    "Interface\\Icons\\spell_frost_stun",
    BuffDuration:NewWithTurnType({
        turnTypeID = TURN_TYPES.PLAYER.id,
        remainingTurns = 1,
    }),
    true,
    {
        BuffEffectSpecial:New("Roll to cling to consciousness!")
    }
)

local clingingOnBuff = Buff:New("clinging", "Clinging on", "Interface\\Icons\\spell_holy_painsupression", nil, true, { BuffEffectSpecial:New("Get healed to full health to stay conscious!") })
local unconsciousBuff = Buff:New("ko", "Unconscious", "Interface\\Icons\\spell_nature_sleep", nil, true, { BuffEffectSpecial:New("Get healed to at least half your health to return to consciousness!") })

local STATE_BUFFS = {
    [STATES.FADING] = fadingConsciousness,
    [STATES.CLINGING_ON] = clingingOnBuff,
    [STATES.UNCONSCIOUS] = unconsciousBuff,
}

local function getState()
    return characterState.state.consciousness.get()
end

local function setState(newState)
    local currentState = getState()
    if currentState == newState then return end

    if STATE_BUFFS[currentState] then
        STATE_BUFFS[currentState]:Remove()
    end

    if STATE_BUFFS[newState] then
        STATE_BUFFS[newState]:Apply()
    end

    characterState.state.consciousness.set(newState)
    bus.fire(EVENTS.CONSCIOUSNESS_CHANGED, newState)
end

local function goKO()
    local maxHealthBuff = buffsState.state.buffLookup.get("ko_maxhealth")
    if maxHealthBuff then
        maxHealthBuff:AddStack()
    else
        local maxHealthEffect = BuffEffectMaxHealth:New(-rules.KO.getKOMaxHealthReduction())
        maxHealthBuff = Buff:New("ko_maxhealth", "Max health", "Interface\\Icons\\spell_nature_sleep", nil, true, { maxHealthEffect })
        maxHealthBuff:Apply()
    end

    -- TODO if character has Final Act feat, do dmg

    setState(STATES.UNCONSCIOUS)
end

bus.addListener(EVENTS.CHARACTER_HEALTH, function(health)
    local maxHealth = characterState.state.maxHealth.get()

    if getState() == STATES.FINE and health == 0 then
        fadingConsciousness:RefreshDuration()
        setState(STATES.FADING)
    elseif getState() == STATES.CLINGING_ON and rules.KO.canRecoverFromClingingOn(health, maxHealth) then
        setState(STATES.FINE)
    end
end)

bus.addListener(EVENTS.HEALED, function()
    local health = characterState.state.health.get()
    local maxHealth = characterState.state.maxHealth.get()

    if getState() == STATES.UNCONSCIOUS and rules.KO.canRecoverFromKO(health, maxHealth) then
        setState(STATES.FINE)
    end
end)

-- TODO final stand trait

bus.addListener(EVENTS.ROLL_CHANGED, function(action, roll)
    if getState() == STATES.FADING and action == SPECIAL_ACTIONS.clingToConsciousness then
        if rules.KO.isClingToConsciousnessSuccessful(roll) then
            local duration = BuffDuration:NewWithTurnType({
                turnTypeID = TURN_TYPES.PLAYER.id,
                remainingTurns = rules.KO.getClingToConsciousnessDuration()
            })
            clingingOnBuff:SetDuration(duration)
            setState(STATES.CLINGING_ON)
        else
            goKO()
        end
    end
end)

-- TODO listen to FATE_ROLLED, can go from unconscious to clinging on
-- TODO need some UI to confirm roll, can't reroll if everything's automatic

bus.addListener(EVENTS.BUFF_EXPIRED, function(id)
    if id == fadingConsciousness.id then
        -- TODO player didn't roll on this turn, what do?
        setState(STATES.FINE)
    elseif id == clingingOnBuff.id then
        goKO()
    end
end)

-- make sure we don't get stuck in some state if player manually cancels buff
bus.addListener(EVENTS.BUFF_CANCELLED, function(id)
    if id == fadingConsciousness.id or id == clingingOnBuff.id or id == unconsciousBuff.id then
        setState(STATES.FINE)
    end
end)