local _, ns = ...

local constants = ns.constants

local ACTION_LABELS = {
    attack = "Attacking",
    healing = "Healing",
    buff = "Buffing",
    defend = "Defending",
    meleeSave = "Melee saves",
    rangedSave = "Ranged saves",
    utility = "Utility",
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

constants.ACTION_LABELS = ACTION_LABELS
constants.ROLL_MODES = ROLL_MODES
constants.STAT_LABELS = STAT_LABELS