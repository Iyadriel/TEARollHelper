local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local buffsState = ns.state.buffs.state
local character = ns.character
local characterState = ns.state.character.state
local consequences = ns.consequences
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui
local utils = ns.utils

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local TRAITS = traits.TRAITS

local state = rolls.state

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.cc.getOptions = function(options)
    local preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
        order = 0,
        hidden = function()
            return not rules.cc.shouldShowPreRollUI()
        end,
        args = utils.merge(
            ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 1 }),
            ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 2 }),
            {
                useCalamityGambit = {
                    order = 0,
                    type = "execute",
                    name = COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.CALAMITY_GAMBIT.name,
                    desc = TRAITS.CALAMITY_GAMBIT.desc,
                    hidden = function()
                        return not character.hasTrait(TRAITS.CALAMITY_GAMBIT) or buffsState.buffLookup.getTraitBuffs(TRAITS.CALAMITY_GAMBIT)
                    end,
                    disabled = function()
                        return characterState.featsAndTraits.numTraitCharges.get(TRAITS.CALAMITY_GAMBIT.id) == 0
                    end,
                    func = consequences.useTrait(TRAITS.CALAMITY_GAMBIT),
                },
                calamityGambitActive = {
                    order = 0,
                    type = "description",
                    name = COLOURS.TRAITS.GENERIC .. TRAITS.CALAMITY_GAMBIT.name .. " is active.",
                    hidden = function()
                        return not (character.hasTrait(TRAITS.CALAMITY_GAMBIT) and buffsState.buffLookup.getTraitBuffs(TRAITS.CALAMITY_GAMBIT))
                    end,
                },
            }
        ),
    })

    return {
        name = ACTION_LABELS.cc,
        type = "group",
        desc = "Crowd control",
        order = options.order,
        args = {
            preRoll = preRoll,
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 1,
                action = ACTIONS.cc,
            }),
            cc = {
                order = 2,
                type = "group",
                name = ACTION_LABELS.cc,
                inline = true,
                hidden = function()
                    return not state.cc.currentRoll.get()
                end,
                args = {
                    result = {
                        order = 0,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            local cc = rolls.getCC()
                            local msg

                            if cc.isCrit then
                                msg = COLOURS.CRITICAL .. "CRITICAL CC!|r You are guaranteed CC of at least 1 turn."
                            else
                                msg = "The result of your CC roll is " .. cc.ccValue .. "."
                            end

                            return msg
                        end
                    }
                }
            }
        }
    }
end