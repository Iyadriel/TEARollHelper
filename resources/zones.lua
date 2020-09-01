local _, ns = ...

local zones = ns.resources.zones

zones.ZONE_KEYS = {"OTHER", "FOREST", "INDOORS", "TAINTED"}

zones.ZONES = {
    OTHER = {
        id = "OTHER",
        name = "Other",
        icon = "Interface\\Icons\\achievement_zone_arathihighlands_01",
    },
    FOREST = {
        id = "FOREST",
        name = "Forest",
        icon = "Interface\\Icons\\achievement_zone_feralas",
    },
    INDOORS = {
        id = "INDOORS",
        name = "Indoors / Underground",
        icon = "Interface\\Icons\\ability_racial_dungeondelver",
    },
    TAINTED = {
        id = "TAINTED",
        name = "Tainted by evil",
        icon = "Interface\\Icons\\spell_holy_senseundead",
    },
}