local _, ns = ...

local utilityTypes = ns.resources.utilityTypes

utilityTypes.UTILITY_TYPE_KEYS = {"OTHER", "ARCANE", "FRIENDLY_INTERACTIONS", "INTELLIGENCE", "MECHANICAL", "MENTAL_FOCUS", "SENSES", "VOID"}

utilityTypes.UTILITY_TYPES = {
    OTHER = {
        id = "OTHER",
        name = "Other",
    },
    ARCANE = {
        id = "ARCANE",
        name = "Arcane magic",
    },
    FRIENDLY_INTERACTIONS = {
        id = "FRIENDLY_INTERACTIONS",
        name = "Friendly interactions with NPCs",
    },
    INTELLIGENCE = {
        id = "INTELLIGENCE",
        name = "Intelligence",
    },
    MECHANICAL = {
        id = "MECHANICAL",
        name = "Tools and mechanical parts",
    },
    MENTAL_FOCUS = {
        id = "MENTAL_FOCUS",
        name = "Mental focus",
    },
    SENSES = {
        id = "SENSES",
        name = "Senses",
    },
    VOID = {
        id = "VOID",
        name = "Void magic",
    },
}