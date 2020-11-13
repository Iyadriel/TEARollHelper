local _, ns = ...

local zones = ns.resources.zones

zones.ZONE_KEYS = {"OTHER", "FOREST", "INDOORS", "TAINTED", "UNDERGROUND"}

zones.ZONES = {
    OTHER = {
        id = "OTHER",
        name = "Other",
        icon = "Interface\\Icons\\achievement_zone_arathihighlands_01",
        colour = "|cffbbbbbb",
    },
    FOREST = {
        id = "FOREST",
        name = "Forest",
        icon = "Interface\\Icons\\achievement_zone_feralas",
        colour = "|cff4f7649",
    },
    INDOORS = {
        id = "INDOORS",
        name = "Indoors",
        icon = "Interface\\Icons\\ability_racial_dungeondelver",
        colour = "|cffa05220",
    },
    TAINTED = {
        id = "TAINTED",
        name = "Tainted by evil",
        icon = "Interface\\Icons\\spell_holy_senseundead",
        colour = "|cff244f8a",
    },
    UNDERGROUND = {
        id = "UNDERGROUND",
        name = "Underground",
        icon = "Interface\\Icons\\ability_racial_dungeondelver",
        colour = "|cffa05220",
    },
}