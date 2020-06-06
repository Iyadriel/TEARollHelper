local _, ns = ...

local bus = ns.bus
local characterState = ns.state.character
local racialTraits = ns.resources.racialTraits

local EVENTS = bus.EVENTS

local BUFF_TYPES = {
    STAT = 0,
    DISADVANTAGE = 1,
    ADVANTAGE = 2,
}

local BUFF_SOURCES = {
    PLAYER = "Player",
    WEAKNESS = "Weakness",
    RACIAL_TRAIT = "Racial Trait",
}

-- TODO this doesn't belong here
local STAT_LABELS = {
    offence = "Offence",
    defence = "Defence",
    spirit = "Spirit",
    stamina = "Stamina"
}

-- TODO neither does this
local ACTION_LABELS = {
    attack = "Attacking",
    healing = "Healing",
    buff = "Buffing",
    defend = "Defending",
    meleeSave = "Melee saves",
    rangedSave = "Ranged saves",
    utility = "Utility",
}

local STAT_TYPE_ICONS = {
    offence = "Interface\\Icons\\spell_holy_greaterblessingofkings",
    defence = "Interface\\Icons\\spell_magic_greaterblessingofkings",
    spirit = "Interface\\Icons\\spell_holy_greaterblessingofwisdom",
    stamina = "Interface\\Icons\\spell_holy_wordfortitude",
}

local function addBuff(buff)
    characterState.state.activeBuffs.add(buff)
end

local function removeBuff(buff)
    characterState.state.activeBuffs.remove(buff)
end

local function getRemainingTurns(expireAfterNextTurn)
    if not expireAfterNextTurn then return nil end
    return 1
end

local function addStatBuff(stat, amount, label, expireAfterNextTurn)
    local existingBuff = characterState.state.buffLookup.getPlayerStatBuff(stat)

    if existingBuff then
        removeBuff(existingBuff)
    end

    if label:trim() == "" then
        label = STAT_LABELS[stat]
    end

    addBuff({
        id = "player_" .. stat,
        type = BUFF_TYPES.STAT,
        label = label,
        icon = STAT_TYPE_ICONS[stat],

        stats = {
            [stat] = amount
        },

        source = BUFF_SOURCES.PLAYER,

        remainingTurns = getRemainingTurns(expireAfterNextTurn),
    })

    bus.fire(EVENTS.STAT_BUFF_ADDED, stat, amount)
end

local function addWeaknessDebuff(weakness)
    local debuffs = weakness.debuffs
    if debuffs and debuffs.stats then
        addBuff({
            id = "weakness_" .. weakness.id,
            type = BUFF_TYPES.STAT,
            label = weakness.name,
            icon = weakness.icon,

            stats = debuffs.stats,

            source = BUFF_SOURCES.WEAKNESS,
            weaknessID = weakness.id
        })
    end
end

local function addRacialBuff(racialTrait)
    local buffs = racialTrait.buffs
    if buffs and buffs.stats then
        addBuff({
            id = "racial",
            type = BUFF_TYPES.STAT,
            label = racialTrait.name,
            icon = racialTrait.icon,

            stats = buffs.stats,

            source = BUFF_SOURCES.RACIAL_TRAIT,
            racialTraitID = racialTrait.id
        })
    end
end

ns.buffs.BUFF_TYPES = BUFF_TYPES
ns.buffs.BUFF_SOURCES = BUFF_SOURCES
ns.buffs.STAT_LABELS = STAT_LABELS
ns.buffs.ACTION_LABELS = ACTION_LABELS
ns.buffs.addStatBuff = addStatBuff
ns.buffs.addWeaknessDebuff = addWeaknessDebuff
ns.buffs.addRacialBuff = addRacialBuff