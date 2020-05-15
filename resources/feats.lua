local _, ns = ...

local feats = ns.resources.feats

feats.FEAT_KEYS = {"NONE", "ADRENALINE", "BLOOD_HARVEST", "COUNTER_FORCE", "KEEN_SENSE", "LEADER", "MENDER", "PHALANX", "PROFESSIONAL", "REAPER", "WARDER"}

feats.FEATS = {
    NONE = {
        id = "NONE",
        name = "Featless / other"
    },
    ADRENALINE = {
        id = "ADRENALINE",
        name = "Adrenaline",
        desc = "Beating the threshold by 4 or more with an offence attack roll yields bonus damage equal to half of your Offence stat rounded up.",
        supported = true
    },
    BLOOD_HARVEST = {
        id = "BLOOD_HARVEST",
        name = "Blood Harvest",
        desc = "For every 2 points you put into the Offence stat you gain a Harvest Slot. You can activate these Harvest Slots to spend them just like a Greater Heal Slot. Spending a Harvest slot increases the damage of your next Offence attack by +3. This damage is dealt even if you miss.",
        supported = true
    },
    COUNTER_FORCE = {
        id = "COUNTER_FORCE",
        name = "Counter-Force",
        desc = "Your melee save rolls no longer benefit from your Defence stat, but if you manage the roll you deal damage back to the attacker by an amount equal to your Defence stat.",
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
    PROFESSIONAL = {
        id = "PROFESSIONAL",
        name = "Professional",
        desc = "You may pick 2 additional Utility Traits. Furthermore your Utility Traits now grant you a bonus of +8 rather than +5.",
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