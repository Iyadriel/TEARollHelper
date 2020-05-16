local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local turns = ns.turns
local ui = ns.ui

--[[ local options = {
    order: Number
} ]]
ui.modules.rolls.modules.meleeSave.getOptions = function(options)
    return {
        name = "Melee save",
        type = "group",
        inline = true,
        order = options.order,
        args = {
            saveDamageTaken = {
                type = "description",
                desc = "How much damage you take this turn",
                fontSize = "medium",
                name = function()
                    local defence = character.getPlayerDefence()
                    local buff = turns.getCurrentBuffs().defence
                    local values = turns.getCurrentTurnValues()
                    local racialTrait = turns.getRacialTrait()
                    local save = actions.getMeleeSave(values.roll, values.defendThreshold, values.damageRisk, defence, buff, racialTrait)

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
        },
    }
end