local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local rolls = ns.state.rolls
local ui = ns.ui

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.meleeSave.getOptions = function(options)
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions("meleeSave")

    return {
        name = "Melee save",
        type = "group",
        order = options.order,
        args = {
            defendThreshold = sharedOptions.defendThreshold,
            damageRisk = sharedOptions.damageRisk,
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 2,
                action = "meleeSave",
                hidden = function()
                    return not (rolls.state.meleeSave.threshold.get() and rolls.state.meleeSave.damageRisk.get())
                end,
            }),
            meleeSave = {
                order = 3,
                type = "group",
                name = "Melee save",
                inline = true,
                hidden = function()
                    return not rolls.state.meleeSave.currentRoll.get()
                end,
                args = {
                    saveDamageTaken = {
                        order = 3,
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
                }
            },
        },
    }
end