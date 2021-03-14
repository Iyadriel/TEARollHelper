local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffsState = ns.state.buffs
local ui = ns.ui

local traits = ns.resources.traits

local TRAITS = traits.TRAITS

--[[ local options = {
    order: Number
} ]]
ui.modules.buffs.modules.specialBuffs.getOptions = function(options)
    local markOfBenevolenceBuff = TRAITS.MARK_OF_BENEVOLENCE:CreateBuff()

    return {
        order = options.order,
        type = "group",
        name = "Add special buff",
        inline = true,
        args = {
            markOfBenevolence = {
                order = 0,
                type = "execute",
                name = COLOURS.TRAITS.MARK_OF_BENEVOLENCE .. "Add " .. TRAITS.MARK_OF_BENEVOLENCE.name,
                func = function()
                    local existingBuff = buffsState.state.buffLookup.get(markOfBenevolenceBuff.id)
                    if existingBuff then
                        existingBuff:Remove()
                    end

                    markOfBenevolenceBuff:RefreshDuration()
                    markOfBenevolenceBuff:Apply()
                end,
            },
        },
    }
end