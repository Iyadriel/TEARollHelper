local _, ns = ...

local bus = ns.bus
local character = ns.character
local constants = ns.constants
local models = ns.models
local rules = ns.rules

local Buff = models.Buff
local BuffDuration = models.BuffDuration
local BuffEffectMaxHealth = models.BuffEffectMaxHealth
local BuffEffectSpecial = models.BuffEffectSpecial

local EVENTS = bus.EVENTS
local SPECIAL_ACTIONS = constants.SPECIAL_ACTIONS
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
local unconsciousBuff = Buff:New("ko", "Unconscious", "Interface\\Icons\\spell_nature_sleep", nil, true)

local STATES = {
    FINE = 0,
    FADING = 1,
    CLINGING_ON = 2,
    KO = 3
}

local STATE_BUFFS = {
    [STATES.FADING] = fadingConsciousness,
    [STATES.CLINGING_ON] = clingingOnBuff,
    [STATES.KO] = unconsciousBuff,
}

local currentState = STATES.FINE

local function setState(newState)
    if currentState == newState then return end

    if STATE_BUFFS[currentState] then
        STATE_BUFFS[currentState]:Remove()
    end

    if STATE_BUFFS[newState] then
        STATE_BUFFS[newState]:Apply()
    end

    currentState = newState
end

local function goKO()
    local maxHealthEffect = BuffEffectMaxHealth:New(rules.KO.getKOMaxHealthReduction())
    local maxHealthDebuff = nil -- TODO add or increase stacks

    bus.fire(EVENTS.KO)

    -- TODO add critical wound
    -- TODO if character has Final Act feat, do dmg

    setState(STATES.KO)
end

bus.addListener(EVENTS.CHARACTER_HEALTH, function(health)
    local maxHealth = character.calculatePlayerMaxHealth()

    if currentState == STATES.FINE and health == 0 then
        fadingConsciousness:RefreshDuration()
        setState(STATES.FADING)
    elseif currentState == STATES.CLINGING_ON and rules.KO.canRecoverFromClingingOn(health, maxHealth) then
        setState(STATES.FINE)
    elseif currentState == STATES.KO and rules.KO.canRecoverFromKO(health, maxHealth) then
        -- TODO remove max health stacks
        setState(STATES.FINE)
    end
end)

-- TODO final stand trait

bus.addListener(EVENTS.ROLL_CHANGED, function(action, roll)
    if currentState == STATES.FADING and action == SPECIAL_ACTIONS.clingToConsciousness then
        if roll >= rules.KO.getClingToConsciousnessThreshold() then
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

-- TODO listen to REROLLED, can go from unconscious to clinging on
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