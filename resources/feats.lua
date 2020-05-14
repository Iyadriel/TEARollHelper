local _, ns = ...

local feats = ns.resources.feats

feats.FEAT_KEYS = {"NONE", "ADRENALINE", "KEEN_SENSE", "LEADER", "MENDER", "PHALANX", "REAPER", "WARDER"}

feats.FEATS = {
    NONE = {
        id = "NONE",
        name = "None / other"
    },
    ADRENALINE = {
        id = "ADRENALINE",
        name = "Adrenaline",
        desc = "Beating the threshold by 4 or more with an offence attack roll yields bonus damage equal to half of your Offence stat rounded up.",
        supported = true
    },
    KEEN_SENSE = {
        id = "KEEN_SENSE",
        name = "Keen sense",
        desc = "The threshold for getting a critical roll is reduced to 19 from 20.",
        supported = true
    },
    LEADER = {
        id = "LEADER",
        name = "Leader",
        desc = "You can now buff with the Offence stat instead of the Spirit stat.",
        note = "The addon will automatically use the highest stat.",
        supported = true
    },
    MENDER = {
        id = "MENDER",
        name = "Mender",
        desc = "Gain 1 additional Greater Heal Slot.",
        supported = true
    },
    PHALANX = {
        id = "PHALANX",
        name = "Phalanx",
        desc = "The threshold for taking double damage on a failed Melee Save is increased to 8 below target threshold, up from 5 below target threshold.",
        supported = true
    },
    REAPER = {
        id = "REAPER",
        name = "Reaper",
        desc = "When scoring a nat 20 on an Offence attack roll, you no longer deal double damage, but instead activate the Reap trait without cost. You do not have to have Reap as a chosen trait.",
        supported = true
    },
    WARDER = {
        id = "WARDER",
        name = "Warder",
        desc = "The base amount of damage reduced on a failed Ranged Save is increased to 4 up from 2.",
        supported = true
    },
}