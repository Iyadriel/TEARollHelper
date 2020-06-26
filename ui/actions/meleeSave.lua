local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local consequences = ns.consequences
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local ui = ns.ui

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.meleeSave.getOptions = function(options)
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions("meleeSave")

    local function shouldHideRoll()
        return not (rolls.state.meleeSave.threshold.get() and rolls.state.meleeSave.damageRisk.get())
    end

    return {
        name = ACTION_LABELS.meleeSave,
        type = "group",
        order = options.order,
        args = {
            defendThreshold = sharedOptions.defendThreshold,
            damageRisk = sharedOptions.damageRisk,
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 2,
                hidden = function()
                    return shouldHideRoll() or not rules.meleeSave.shouldShowPreRollUI()
                end,
                args = ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 0 }),
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 3,
                action = ACTIONS.meleeSave,
                hidden = shouldHideRoll,
            }),
            meleeSave = {
                order = 4,
                type = "group",
                name = ACTION_LABELS.meleeSave,
                inline = true,
                hidden = function()
                    return not rolls.state.meleeSave.currentRoll.get()
                end,
                args = {
                    saveDamageTaken = {
                        order = 0,
                        type = "description",
                        desc = "How much damage you take this turn",
                        fontSize = "medium",
                        name = function()
                            local save = rolls.getMeleeSave()

                            local msg = ""

                            if save.damageTaken > 0 then
                                if save.isBigFail then
                                    msg = COLOURS.DAMAGE .. "Bad save! |r"
                                end
                                msg = msg .. "You can save your ally, |r" .. COLOURS.DAMAGE .. "but you will take " .. tostring(save.damageTaken) .. " damage."
                            else
                                msg = COLOURS.SAVE .. "You can save your ally without taking any damage yourself."
                            end

                            if save.hasCounterForceProc then
                                msg = msg .. COLOURS.FEATS.GENERIC .. "\nCOUNTER-FORCE!|r You can deal "..save.counterForceDmg.." damage to your attacker!"
                            end

                            return msg
                        end
                    },
                    confirm = {
                        order = 1,
                        type = "execute",
                        name = "Confirm",
                        desc = "Apply the stated damage to your character's HP",
                        hidden = function()
                            return rolls.getMeleeSave().damageTaken <= 0
                        end,
                        func = function()
                            consequences.confirmMeleeSaveAction(rolls.getMeleeSave())
                        end
                    }
                }
            },
        },
    }
end