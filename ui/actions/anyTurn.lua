local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffsState = ns.state.buffs.state
local character = ns.character
local constants = ns.constants
local characterState = ns.state.character.state
local consequences = ns.consequences
local rolls = ns.state.rolls
local traits = ns.resources.traits
local ui = ns.ui

local ACTIONS = constants.ACTIONS
local TRAITS = traits.TRAITS

local state = rolls.state

--[[ local options = {
    order: Number,
    action: String,
    actionArgs: Array?
} ]]
ui.modules.actions.modules.anyTurn.getSharedPreRollOptions = function(options)
    return {
        versatile = {
            order = options.order,
            type = "group",
            name = COLOURS.TRAITS.GENERIC .. TRAITS.VERSATILE.name,
            inline = true,
            hidden = function()
                return options.action == ACTIONS.utility or not character.hasTrait(TRAITS.VERSATILE) or buffsState.buffLookup.getTraitBuffs(TRAITS.VERSATILE)
            end,
            args = {
                stat1 = {
                    order = 0,
                    type = "select",
                    name = "Source stat",
                    width = 0.55,
                    values = constants.STAT_LABELS,
                    sorting = constants.STATS_SORTED,
                    get = state.shared.versatile.stat1.get,
                    set = function(info, value)
                        state.shared.versatile.stat1.set(value)
                    end,
                },
                stat2 = {
                    order = 1,
                    type = "select",
                    name = "Transfer to",
                    width = 0.55,
                    values = constants.STAT_LABELS,
                    sorting = constants.STATS_SORTED,
                    get = state.shared.versatile.stat2.get,
                    set = function(info, value)
                        state.shared.versatile.stat2.set(value)
                    end,
                },
                transfer = {
                    order = 2,
                    type = "execute",
                    name = "Transfer",
                    width = 0.65,
                    disabled = function()
                        local statsDiffer = state.shared.versatile.stat1.get() ~= state.shared.versatile.stat2.get()
                        return not statsDiffer or characterState.featsAndTraits.numTraitCharges.get(TRAITS.VERSATILE.id) == 0
                    end,
                    func = consequences.useTrait(TRAITS.VERSATILE)
                }
            },
        },
        versatileActive = ui.helpers.traitActiveText(TRAITS.VERSATILE, options.order),
        useSilamelsAce = ui.helpers.traitButton(TRAITS.SILAMELS_ACE, {
            order = options.order + 1,
            checkBuff = true,
            func = function()
                consequences.useTrait(TRAITS.SILAMELS_ACE)(options.action)
            end,
        }),
        silamelsAceActive = ui.helpers.traitActiveText(TRAITS.SILAMELS_ACE, options.order + 1)
    }
end
