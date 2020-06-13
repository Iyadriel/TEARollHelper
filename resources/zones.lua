local _, ns = ...

local zones = ns.resources.zones

zones.ZONE_KEYS = {"OTHER", "FOREST", "INDOORS", "TAINTED"}

zones.ZONES = {
    OTHER = {
        id = "OTHER",
        name = "Other"
    },
    FOREST = {
        id = "FOREST",
        name = "Forest",
    },
    INDOORS = {
        id = "INDOORS",
        name = "Indoors / Underground",
    },
    TAINTED = {
        id = "TAINTED",
        name = "Tainted by evil",
    },
}