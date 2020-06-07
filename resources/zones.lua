local _, ns = ...

local zones = ns.resources.zones

zones.ZONE_KEYS = {"OTHER", "FOREST"}

zones.ZONES = {
    OTHER = {
        id = "OTHER",
        name = "Other"
    },
    FOREST = {
        id = "FOREST",
        name = "Forest",
    },
}