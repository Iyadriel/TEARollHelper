local _, ns = ...

local enemies = ns.resources.enemies

enemies.ENEMY_KEYS = {"OTHER", "DEMON", "ELDRITCH", "UNDEAD", "VOID", "WARLOCK"}

enemies.ENEMIES = {
    OTHER = {
        id = "OTHER",
        name = "Other"
    },
    DEMON = {
        id = "DEMON",
        name = "Demon",
    },
    ELDRITCH = {
        id = "ELDRITCH",
        name = "Eldritch",
    },
    UNDEAD = {
        id = "UNDEAD",
        name = "Undead",
    },
    VOID = {
        id = "VOID",
        name = "Void",
    },
    WARLOCK = {
        id = "WARLOCK",
        name = "Warlock",
    },
}