local _, ns = ...

local feats = ns.resources.feats

feats.FEAT_KEYS = {"NONE", "ADRENALINE", "KEEN_SENSE", "PHALANX", "REAPER"}

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
}