local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffs = ns.buffs
local ui = ns.ui

local traits = ns.resources.traits

local TRAITS = traits.TRAITS

--[[ local options = {
    order: Number
} ]]
ui.modules.buffs.modules.specialBuffs.getOptions = function(options)
    return {
        order = options.order,
        type = "group",
        name = "Add special buff",
        inline = true,
        args = {
            markOfBenevolence = {
                order = 0,
                type = "execute",
                name = COLOURS.TRAITS.MARK_OF_BENEVOLENCE .. TRAITS.MARK_OF_BENEVOLENCE.name,
                func = function()
                    buffs.addTraitBuff(TRAITS.MARK_OF_BENEVOLENCE)
                end,
            },
            trueshotAura = {
                order = 1,
                type = "execute",
                name = COLOURS.TRAITS.TRUESHOT_AURA .. TRAITS.TRUESHOT_AURA.name,
                func = function()
                    buffs.addTraitBuff(TRAITS.TRUESHOT_AURA)
                end,
            },
        },
    }
end
