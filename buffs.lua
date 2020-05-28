local _, ns = ...

local bus = ns.bus
local characterState = ns.state.character

local EVENTS = bus.EVENTS

local BUFF_TYPES = {
    STAT = 0
}

local BUFF_SOURCES = {
    PLAYER = "Player"
}

-- TODO this doesn't belong here
local STAT_LABELS = {
    offence = "Offence",
    defence = "Defence",
    spirit = "Spirit",
    stamina = "Stamina"
}

local STAT_TYPE_ICONS = {
    offence = "Interface\\Icons\\spell_holy_greaterblessingofkings",
    defence = "Interface\\Icons\\spell_magic_greaterblessingofkings",
    spirit = "Interface\\Icons\\spell_holy_greaterblessingofwisdom",
    stamina = "Interface\\Icons\\spell_holy_wordfortitude",
}

local buffID = 0

local function addBuff(buff)
    buff.id = buffID
    characterState.state.activeBuffs.add(buff)
    buffID = buffID + 1
end

local function removeBuff(buff)
    characterState.state.activeBuffs.remove(buff)
end

local function findPlayerStatBuff(stat)
    local buffs = characterState.state.activeBuffs.getPlayerStatBuffs()
    return buffs[stat]
end

local function addStatBuff(stat, amount, label)
    local existingBuff = findPlayerStatBuff(stat)

    if existingBuff then
        removeBuff(existingBuff)
    end

    if label:trim() == "" then
        label = STAT_LABELS[stat]
    end

    addBuff({
        type = BUFF_TYPES.STAT,
        label = label,
        icon = STAT_TYPE_ICONS[stat],

        stat = stat,
        amount = amount,

        source = BUFF_SOURCES.PLAYER,

        -- TODO
        --expires = true,
        --expiresAfterTurn = 2,
    })

    bus.fire(EVENTS.STAT_BUFF_ADDED, stat, amount)
end

ns.buffs.BUFF_TYPES = BUFF_TYPES
ns.buffs.BUFF_SOURCES = BUFF_SOURCES
ns.buffs.STAT_LABELS = STAT_LABELS
ns.buffs.addStatBuff = addStatBuff