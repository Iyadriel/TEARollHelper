local _, ns = ...

local constants = ns.constants

local ACTIONS = {
    attack = "attack",
    healing = "healing",
    buff = "buff",
    defend = "defend",
    meleeSave = "meleeSave",
    rangedSave = "rangedSave",
    utility = "utility"
}

local ACTION_LABELS = {
    attack = "Attack",
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
}

local BUFF_TYPES = {
    STAT = 0,
    DISADVANTAGE = 1,
    ADVANTAGE = 2,
    HEALING_OVER_TIME = 3,
}

local ROLL_MODES = {
    DISADVANTAGE = -1,
    NORMAL = 0,
    ADVANTAGE = 1
}

local STAT_LABELS = {
    offence = "Offence",
    defence = "Defence",
    spirit = "Spirit",
    stamina = "Stamina"
}

local TURN_TYPES = {
    PLAYER = { id = "PLAYER", name = "Player" },
    ENEMY = { id = "ENEMY", name = "Enemy" },
    OUT_OF_COMBAT = { id = "OUT_OF_COMBAT", name = "Out of combat" },
}

constants.ACTIONS = ACTIONS
constants.ACTION_LABELS = ACTION_LABELS
constants.BUFF_SOURCES = BUFF_SOURCES
constants.BUFF_TYPES = BUFF_TYPES
constants.ROLL_MODES = ROLL_MODES
constants.STAT_LABELS = STAT_LABELS
constants.TURN_TYPES = TURN_TYPES