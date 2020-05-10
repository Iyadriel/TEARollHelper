local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

ui.modules.rolls = {
    name = "TEA Roll View",
    type = "group",
    desc = "See possible outcomes for a given roll",
    cmdHidden = true,
    order = 3,
    childGroups = "select",
    args = {
--[[         config = {
            name = "Show config UI",
            type = "execute",
            order = 0,
            func = function()
                AceConfigDialog:Open("TEARollHelper")
            end
        }, ]]
        roll = {
            name = "Roll",
            type = "range",
            desc = "The number you rolled",
            order = 0,
            min = 1,
            max = rules.MAX_ROLL,
            step = 1,
            get = function()
                return turns.getCurrentTurnValues().roll
            end,
            set = function(info, value)
                turns.setCurrentRoll(value)
            end
        },
        buffs = ui.modules.buffs.getOptions(),
        playerTurn = {
            name = "Player turn",
            type = "group",
            order = 1,
            args = {
                attack = {
                    name = "Attack",
                    type = "group",
                    inline = true,
                    order = 0,
                    args = {
                        attackThreshold = {
                            name = "Attack threshold",
                            type = "input",
                            desc = "The minimum required roll to hit the target",
                            order = 1,
                            pattern = "%d",
                            usage = "Must be a number",
                            get = function()
                                return tostring(turns.getCurrentTurnValues().attackThreshold)
                            end,
                            set = function(info, value)
                                turns.setAttackValues(tonumber(value))
                            end
                        },
                        dmg = {
                            name = "Damage dealt",
                            type = "description",
                            desc = "How much damage you can deal to a target",
                            order = 2,
                            name = function()
                                local offence = character.getPlayerOffence()
                                local buff = turns.getCurrentBuffs().offence
                                local values = turns.getCurrentTurnValues()

                                local attack = actions.getAttack(values.roll, values.attackThreshold, offence, buff)

                                if attack.dmg > 0 then
                                    if attack.isCrit then
                                        return COLOURS.CRITICAL .. "CRITICAL HIT!|r You can deal " .. tostring(attack.dmg) .. " damage!"
                                    else
                                        return "You can deal " .. tostring(attack.dmg) .. " damage."
                                    end
                                else
                                    return "You can't deal any damage with this roll."
                                end
                            end
                        },
                    }
                },
                heal = {
                    name = "Heal",
                    type = "group",
                    inline = true,
                    order = 1,
                    args = {
                        healing = {
                            name = "Healing",
                            type = "description",
                            desc = "How much you can heal for",
                            order = 4,
                            name = function()
                                local spirit = character.getPlayerSpirit()
                                local healing = actions.getHealing(turns.getCurrentTurnValues().roll, spirit)

                                if healing.amountHealed > 0 then
                                    if healing.isCrit then
                                        return COLOURS.CRITICAL .. "CRITICAL HEAL!|r " .. COLOURS.HEALING .. "You can heal everyone in line of sight for " .. tostring(healing.amountHealed) .. " HP."
                                    else
                                        return COLOURS.HEALING .. "You can heal for " .. tostring(healing.amountHealed) .. " HP."
                                    end
                                else
                                    return "You can't heal anyone with this roll."
                                end
                            end
                        },
                    }
                }
            }
        },
        enemyTurn = {
            name = "Enemy turn",
            type = "group",
            --inline = true,
            order = 2,
            args = {
                defendThreshold = {
                    name = "Defend threshold",
                    type = "input",
                    desc = "The minimum required roll to not take any damage",
                    order = 0,
                    pattern = "%d",
                    usage = "Must be a number",
                    get = function()
                        return tostring(turns.getCurrentTurnValues().defendThreshold)
                    end,
                    set = function(info, value)
                        turns.setDefendValues(tonumber(value), nil)
                    end
                },
                damageRisk = {
                    name = "Damage risk",
                    type = "input",
                    desc = "How much damage you will take if you fail the roll",
                    order = 1,
                    pattern = "%d",
                    usage = "Must be a number",
                    get = function()
                        return tostring(turns.getCurrentTurnValues().damageRisk)
                    end,
                    set = function(info, value)
                        turns.setDefendValues(nil, tonumber(value))
                    end
                },
                damageTaken = {
                    name = "Damage taken",
                    type = "description",
                    desc = "How much damage you take this turn",
                    order = 2,
                    name = function()
                        local defence = character.getPlayerDefence()
                        local buff = turns.getCurrentBuffs().defence
                        local values = turns.getCurrentTurnValues()
                        local defend = actions.getDefence(values.roll, values.defendThreshold, values.damageRisk, defence, buff)

                        if defend.damageTaken > 0 then
                            return COLOURS.DAMAGE .. "You take " .. tostring(defend.damageTaken) .. " damage."
                        else
                            local msg = "Safe! You don't take damage this turn."
                            if defend.canRetaliate then
                                msg = msg .. COLOURS.CRITICAL .. "\nRETALIATE!|r You can deal "..defend.retaliateDmg.." damage to your attacker!"
                            end
                            return msg
                        end
                    end
                },
            }
        },
    }
}