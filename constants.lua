local _, ns = ...

local constants = ns.constants

local ACTIONS = {
    attack = "attack",
    cc = "cc",
    healing = "healing",
    buff = "buff",
    defend = "defend",
    meleeSave = "meleeSave",
    rangedSave = "rangedSave",
    utility = "utility"
}

local ACTION_LABELS = {
    attack = "Attack",
    cc = "CC",
    healing = "Heal",
    buff = "Buff",
    defend = "Defend",
    meleeSave = "Melee save",
    rangedSave = "Ranged save",
    utility = "Utility",
}

local BUFF_SOURCES = {
    PLAYER = "Player",
    OTHER_PLAYER = "Other player",
    TRAIT = "Trait",
    WEAKNESS = "Weakness",
    RACIAL_TRAIT = "Racial Trait",
    CRITICAL_WOUND = "Critical Wound",
}

local BUFF_TYPES = {
    STAT = 0,
    DISADVANTAGE = 1,
    ADVANTAGE = 2,
    HEALING_OVER_TIME = 3,
    MAX_HEALTH = 4,
    BASE_DMG = 5,
    HEALING_DONE = 6,
    DAMAGE_TAKEN = 7,
    DAMAGE_DONE = 8,
    DAMAGE_OVER_TIME = 9,
    UTILITY_BONUS = 10,
}

local DAMAGE_TYPES = {
    PHYSICAL = 0,
    MAGICAL = 1,
    MIXED = 2,
}

local DAMAGE_TYPE_LABELS = {
    PHYSICAL = "Physical",
    MAGICAL = "Magical",
    MIXED = "Mixed",
}

local DEFENCE_TYPES = {
    THRESHOLD = 0,
    DAMAGE_REDUCTION = 1,
}

local DEFENCE_TYPE_LABELS = {
    THRESHOLD = "Threshold",
    DAMAGE_REDUCTION = "Damage reduction",
}

local INCOMING_HEAL_SOURCES = {
    SELF = 0,
    OTHER_PLAYER = 1,
}

local ROLL_MODES = {
    DISADVANTAGE = -1,
    NORMAL = 0,
    ADVANTAGE = 1
}

local STATS = {
    offence = "offence",
    defence = "defence",
    spirit = "spirit",
    stamina = "stamina"
}

local STAT_LABELS = {
    offence = "Offence",
    defence = "Defence",
    spirit = "Spirit",
    stamina = "Stamina"
}

local STATS_SORTED = { STATS.offence, STATS.defence, STATS.spirit, STATS.stamina }

local TURN_TYPES = {
    PLAYER = { id = "PLAYER", name = "Player" },
    ENEMY = { id = "ENEMY", name = "Enemy" },
    OUT_OF_COMBAT = { id = "OUT_OF_COMBAT", name = "Out of combat" },
}

constants.ACTIONS = ACTIONS
constants.ACTION_LABELS = ACTION_LABELS
constants.BUFF_SOURCES = BUFF_SOURCES
constants.BUFF_TYPES = BUFF_TYPES
constants.DAMAGE_TYPES = DAMAGE_TYPES
constants.DAMAGE_TYPE_LABELS = DAMAGE_TYPE_LABELS
constants.DEFENCE_TYPES = DEFENCE_TYPES
constants.DEFENCE_TYPE_LABELS = DEFENCE_TYPE_LABELS
constants.INCOMING_HEAL_SOURCES = INCOMING_HEAL_SOURCES
constants.ROLL_MODES = ROLL_MODES
constants.STATS = STATS
constants.STAT_LABELS = STAT_LABELS
constants.STATS_SORTED = STATS_SORTED
constants.TURN_TYPES = TURN_TYPES