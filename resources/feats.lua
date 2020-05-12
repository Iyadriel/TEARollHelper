local _, ns = ...

local feats = ns.resources.feats

feats.FEAT_KEYS = {"KEEN_SENSE", "PHALANX"}

feats.FEATS = {
    KEEN_SENSE = {
        id = "KEEN_SENSE",
        name = "Keen sense",
        desc = "The threshold for getting a critical roll is reduced to 19 from 20."
    },
    PHALANX = {
        id = "PHALANX",
        name = "Phalanx",
        desc = "The threshold for taking double damage on a failed Melee Save is increased to 8 below target threshold, up from 5 below target threshold."
    },
}