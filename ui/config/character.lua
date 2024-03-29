local _, ns = ...

local rules = ns.rules
local ui = ns.ui

ui.modules.config.modules.character.modules = {
    feats = {},
    stats = {},
    traits = {},
    weaknesses = {},
    utilityTraits = {},
    racialTraits = {},
}

ui.modules.config.modules.character.getOptions = function()
    local featOptions = ui.modules.config.modules.character.modules.feats.getOptions({ order = 1 })
    local weaknessOptions = ui.modules.config.modules.character.modules.weaknesses.getOptions({ order = 17 })
    local racialTraitOptions = ui.modules.config.modules.character.modules.racialTraits.getOptions({ order = 25 })

    local traitOptions = {}
    local traitOrder = 5
    for i = 1, rules.traits.MAX_NUM_TRAITS do
        traitOptions[i] = ui.modules.config.modules.character.modules.traits.getOptions({ slotIndex = i, order = traitOrder })
        traitOrder = traitOrder + 4
    end

    local utilityTraitOptions = {}
    local utilityTraitOrder = 21
    for i = 1, rules.utility.MAX_NUM_UTILITY_TRAITS do
        utilityTraitOptions[i] = ui.modules.config.modules.character.modules.utilityTraits.getOptions({ slotIndex = i, order = utilityTraitOrder })
        utilityTraitOrder = utilityTraitOrder + 1
    end

    return {
        name = "Character sheet",
        type = "group",
        desc = "Set up your character sheet",
        guiInline = true,
        order = 1,
        args = {
            stats = ui.modules.config.modules.character.modules.stats.getOptions({ order = 0 }),

            feats = featOptions.feats,
            temperedBenevolenceWarning = featOptions.temperedBenevolenceWarning,
            featDesc = featOptions.featDesc,
            featNote = featOptions.featNote,

            trait1 = traitOptions[1].trait,
            trait1Desc = traitOptions[1].traitDesc,
            trait1Note = traitOptions[1].traitNote,
            trait1Charges = traitOptions[1].traitCharges,
            trait2 = traitOptions[2].trait,
            trait2Desc = traitOptions[2].traitDesc,
            trait2Note = traitOptions[2].traitNote,
            trait2Charges = traitOptions[2].traitCharges,
            trait3 = traitOptions[3].trait,
            trait3Desc = traitOptions[3].traitDesc,
            trait3Note = traitOptions[3].traitNote,
            trait3Charges = traitOptions[3].traitCharges,

            weaknesses = weaknessOptions.weaknesses,

            utilityTrait1 = utilityTraitOptions[1].trait,
            utilityTrait2 = utilityTraitOptions[2].trait,
            utilityTrait3 = utilityTraitOptions[3].trait,
            utilityTrait4 = utilityTraitOptions[4].trait,
            utilityTrait5 = utilityTraitOptions[5].trait,

            space = {
                order = 24,
                type = "description",
                name = " ",
            },

            racialTrait = racialTraitOptions.racialTrait,
            racialTraitDesc = racialTraitOptions.racialTraitDesc,
            racialTraitNote = racialTraitOptions.racialTraitNote,

--[[             characterSheet = {
                order = 24,
                type = "input",
                multiline = 13,
                name = "Preview",
                width = "full",
                get = character.characterSheetToString
            } ]]
        }
    }
end