local _, ns = ...

local character = ns.character
local characterState = ns.state.character
local consequences = ns.consequences
local constants = ns.constants
local rolls = ns.state.rolls
local traits = ns.resources.traits
local turn = ns.state.turn
local ui = ns.ui

local COLOURS = TEARollHelper.COLOURS
local TRAITS = traits.TRAITS
local TURN_TYPES = constants.TURN_TYPES
local turnState = turn.state
local state = characterState.state

ui.modules.actions.modules = {
    anyTurn = {},
    playerTurn = {},

    attack = {},
    cc = {},
    healing = {},
    buff = {},
    defend = {},
    meleeSave = {},
    rangedSave = {},
    utility = {},
    KO = {},
}

--[[ local options = {
    order: Number,
    groupName: String
} ]]
ui.modules.actions.getOptions = function(options)
    local lifeWithin = ui.helpers.traitButton(TRAITS.LIFE_WITHIN, { order = 2})

    return {
        KO = ui.modules.actions.modules.KO.getOptions({ order = options.order }),
        playerTurn = {
            order = options.order + 1,
            type = "group",
            name = options.groupName or "Player turn",
            childGroups = "tab",
            hidden = function()
                return turnState.type.get() ~= TURN_TYPES.PLAYER.id
            end,
            args = {
                blessedStrike = ui.helpers.traitButton(TRAITS.BLESSED_STRIKE, {
                    order = 1,
                    width = "full",
                }),
                lifeWithin = lifeWithin,
                markOfBenevolence = ui.helpers.traitButton(TRAITS.MARK_OF_BENEVOLENCE, {
                    order = 3,
                    width = "full",
                }),
                shieldSlam = ui.helpers.traitButton(TRAITS.SHIELD_SLAM, {
                    order = 4,
                    name = function()
                        return COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.SHIELD_SLAM.name .. ": Deal " .. rolls.traits.getShieldSlam().dmg .. " damage"
                    end,
                    width = "full",
                }),
                attack = ui.modules.actions.modules.attack.getOptions({ order = 5 }),
                cc = ui.modules.actions.modules.cc.getOptions({ order = 6 }),
                heal = ui.modules.actions.modules.healing.getOptions({
                    order = 7,
                    outOfCombat = false,
                    turnTypeID = TURN_TYPES.PLAYER.id,
                }),
                buff = ui.modules.actions.modules.buff.getOptions({ order = 8 }),
                utility = ui.modules.actions.modules.utility.getOptions({ order = 9, turnTypeID = TURN_TYPES.PLAYER.id }),
            }
        },
        enemyTurn = {
            order = options.order + 1,
            type = "group",
            name = options.groupName or "Enemy turn",
            childGroups = "tab",
            hidden = function()
                return turnState.type.get() ~= TURN_TYPES.ENEMY.id
            end,
            args = {
                lifeWithin = lifeWithin,
                defend = ui.modules.actions.modules.defend.getOptions({ order = 2 }),
                meleeSave = ui.modules.actions.modules.meleeSave.getOptions({ order = 3 }),
                rangedSave = ui.modules.actions.modules.rangedSave.getOptions({ order = 4 }),
                utility = ui.modules.actions.modules.utility.getOptions({ order = 5, turnTypeID = TURN_TYPES.ENEMY.id }),
            }
        },
        outOfCombat = {
            order = options.order + 1,
            type = "group",
            name = options.groupName or "Out of combat",
            childGroups = "tab",
            hidden = function()
                return turnState.inCombat.get()
            end,
            args = {
                secondWind = {
                    order = 0,
                    type = "execute",
                    name = COLOURS.TRAITS.GENERIC .. "Use " .. TRAITS.SECOND_WIND.name,
                    desc = TRAITS.SECOND_WIND.desc,
                    hidden = function()
                        return not character.hasTrait(TRAITS.SECOND_WIND)
                    end,
                    disabled = function()
                        return state.featsAndTraits.numTraitCharges.get(TRAITS.SECOND_WIND.id) == 0
                    end,
                    func = consequences.useTrait(TRAITS.SECOND_WIND)
                },
                heal = ui.modules.actions.modules.healing.getOptions({
                    order = 1,
                    outOfCombat = true,
                    turnTypeID = TURN_TYPES.OUT_OF_COMBAT.id,
                }),
                utility = ui.modules.actions.modules.utility.getOptions({ order = 2, turnTypeID = TURN_TYPES.OUT_OF_COMBAT.id }),
            }
        }
    }
end
