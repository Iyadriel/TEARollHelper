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

local SPECIAL_ACTIONS = {
    save = "save", -- used for Crippling Pain CW
    clingToConsciousness = "clingingOn",
}

local SPECIAL_ACTION_LABELS = {
    save = "Save",
    clingToConsciousness = "Cling to consciousness",
}

local CONSCIOUSNESS_STATES = {
    FINE = 0,
    FADING = 1,
    CLINGING_ON = 2,
    UNCONSCIOUS = 3
}

local CRIT_TYPES = {
    VALUE_MOD = 0,
    MULTI_TARGET = 1,
    RETALIATE = 2,
    PROTECTOR = 3,
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

local PLAYER_BUFF_TYPES = {
    ROLL = 0,
    STAT = 1,
    BASE_DMG = 2,
    ADVANTAGE = 3,
    DISADVANTAGE = 4,
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
constants.SPECIAL_ACTIONS = SPECIAL_ACTIONS
constants.ACTION_LABELS = ACTION_LABELS
constants.SPECIAL_ACTION_LABELS = SPECIAL_ACTION_LABELS
constants.CONSCIOUSNESS_STATES = CONSCIOUSNESS_STATES
constants.CRIT_TYPES = CRIT_TYPES
constants.DAMAGE_TYPES = DAMAGE_TYPES
constants.DAMAGE_TYPE_LABELS = DAMAGE_TYPE_LABELS
constants.DEFENCE_TYPES = DEFENCE_TYPES
constants.DEFENCE_TYPE_LABELS = DEFENCE_TYPE_LABELS
constants.INCOMING_HEAL_SOURCES = INCOMING_HEAL_SOURCES
constants.PLAYER_BUFF_TYPES = PLAYER_BUFF_TYPES
constants.ROLL_MODES = ROLL_MODES
constants.STATS = STATS
constants.STAT_LABELS = STAT_LABELS
constants.STATS_SORTED = STATS_SORTED
constants.TURN_TYPES = TURN_TYPES