local _, ns = ...

local enemies = ns.resources.enemies

enemies.ENEMY_KEYS = {"OTHER", "DEMON", "ELDRITCH", "MECHANICAL", "UNDEAD", "VOID", "WARLOCK"}

enemies.ENEMIES = {
    OTHER = {
        id = "OTHER",
        name = "Other",
        icon = "Interface\\Icons\\spell_shadow_twistedfaith",
    },
    DEMON = {
        id = "DEMON",
        name = "Demon",
        icon = "Interface\\Icons\\spell_shadow_demonicpact",
    },
    ELDRITCH = {
        id = "ELDRITCH",
        name = "Eldritch",
        icon = "Interface\\Icons\\ability_rogue_envelopingshadows",
    },
    MECHANICAL = {
        id = "MECHANICAL",
        name = "Mechanical",
        icon = "Interface\\Icons\\pet_type_mechanical",
    },
    UNDEAD = {
        id = "UNDEAD",
        name = "Undead",
        icon = "Interface\\Icons\\pet_type_undead",
    },
    VOID = {
        id = "VOID",
        name = "Void",
        icon = "Interface\\Icons\\spell_shadow_summonvoidwalker",
    },
    WARLOCK = {
        id = "WARLOCK",
        name = "Warlock",
        icon = "Interface\\Icons\\classicon_warlock",
    },
}