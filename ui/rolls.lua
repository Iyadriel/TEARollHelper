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
    childGroups = "tab",
    args = {
        roll = {
            name = "Roll result",
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
        performRoll = {
            name = "Roll",
            type = "execute",
            desc = "Do a /roll " .. rules.MAX_ROLL .. ".",
            order = 1,
            func = turns.freeRoll
        },
--[[         tempEffects = {
            name = "Temporary effects",
            type = "group",
            order = 2,
            args = { ]]
                buffs = ui.modules.buffs.getOptions(),
--[[                 racialTrait = {
                    name = "Racial trait",
                    type = "toggle",
                    get = function()
                        return racialTraitActive
                    end,
                    set = function(info, value)
                        racialTraitActive = value
                    end
                }
            }
        }, ]]
        playerTurn = {
            name = "Player turn",
            type = "group",
            order = 3,
            args = {
                attack = {
                    name = "Attack",
                    type = "group",
                    inline = true,
                    order = 0,
                    args = {
                        attackThreshold = {
                            name = "Attack threshold",
                            type = "range",
                            desc = "The minimum required roll to hit the target",
                            min = 1,
                            softMax = 20,
                            max = 100,
                            step = 1,
                            order = 1,
                            get = function()
                                return turns.getCurrentTurnValues().attackThreshold
                            end,
                            set = function(info, value)
                                turns.setAttackValues(value)
                            end
                        },
                        dmg = {
                            name = "Damage dealt",
                            type = "description",
                            desc = "How much damage you can deal to a target",
                            fontSize = "medium",
                            order = 2,
                            name = function()
                                local offence = character.getPlayerOffence()
                                local buff = turns.getCurrentBuffs().offence
                                local values = turns.getCurrentTurnValues()

                                local attack = actions.getAttack(values.roll, values.attackThreshold, offence, buff)
                                local msg = ""
                                local excited = false

                                if attack.dmg > 0 then
                                    if attack.isCrit and attack.critType == rules.CRIT_TYPES.DAMAGE then
                                        excited = true
                                        msg = COLOURS.CRITICAL .. "CRITICAL HIT!|r "
                                    end

                                    if attack.hasAdrenalineProc then
                                        msg = msg .. COLOURS.FEATS.ADRENALINE .. "ADRENALINE!|r "
                                    end

                                    if attack.isCrit and attack.critType == rules.CRIT_TYPES.REAPER then
                                        msg = COLOURS.FEATS.REAPER .. "TIME TO REAP!|r You can deal " .. tostring(attack.dmg) .. " damage to all enemies in melee range of you or your target!"
                                    else
                                        msg = msg .. "You can deal " .. tostring(attack.dmg) .. " damage" .. (excited and "!" or ".")
                                    end

                                    if attack.hasEntropicEmbraceProc then
                                        msg = msg .. COLOURS.DAMAGE_TYPES.SHADOW .. "|nEntropic Embrace: You deal " .. attack.entropicEmbraceDmg .. " extra Shadow damage!"
                                    end
                                else
                                    msg = COLOURS.NOTE .. "You can't deal any damage with this roll."
                                end

                                return msg
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
                            fontSize = "medium",
                            order = 4,
                            name = function()
                                local spirit = character.getPlayerSpirit()
                                local healing = actions.getHealing(turns.getCurrentTurnValues().roll, spirit)

                                if healing.amountHealed > 0 then
                                    local amount = tostring(healing.amountHealed)
                                    if healing.isCrit then
                                        return COLOURS.CRITICAL .. "MANY HEALS!|r " .. COLOURS.HEALING .. "You can heal everyone in line of sight for " .. amount .. " HP."
                                    else
                                        return COLOURS.HEALING .. "You can heal someone for " .. amount .. " HP."
                                    end
                                else
                                    return COLOURS.NOTE .. "You can't heal anyone with this roll."
                                end
                            end
                        },
                    }
                },
                buff = {
                    name = "Buff",
                    type = "group",
                    inline = true,
                    order = 2,
                    args = {
                        buff = {
                            name = "Buffing",
                            type = "description",
                            desc = "How much you can buff for",
                            fontSize = "medium",
                            order = 4,
                            name = function()
                                local spirit = character.getPlayerSpirit()
                                local buff = actions.getBuff(turns.getCurrentTurnValues().roll, spirit)

                                if buff.amountBuffed > 0 then
                                    local amount = tostring(buff.amountBuffed)
                                    if buff.isCrit then
                                        return COLOURS.CRITICAL .. "BIG BUFF!|r " .. COLOURS.BUFF .. "You can buff everyone in line of sight for " .. amount .. "."
                                    else
                                        return COLOURS.BUFF .. "You can buff someone for " .. amount .. "."
                                    end
                                else
                                    return COLOURS.NOTE .. "You can't buff anyone with this roll."
                                end
                            end
                        }
                    }
                }
            }
        },
        enemyTurn = {
            name = "Enemy turn",
            type = "group",
            order = 4,
            args = {
                defendThreshold = {
                    name = "Defend threshold",
                    type = "range",
                    desc = "The minimum required roll to not take any damage",
                    min = 1,
                    softMax = 20,
                    max = 100,
                    step = 1,
                    order = 0,
                    get = function()
                        return turns.getCurrentTurnValues().defendThreshold
                    end,
                    set = function(info, value)
                        turns.setDefendValues(value, nil)
                    end
                },
                damageRisk = {
                    name = "Damage risk",
                    type = "range",
                    desc = "How much damage you will take if you fail the roll",
                    min = 1,
                    softMax = 20,
                    max = 100,
                    step = 1,
                    order = 1,
                    get = function()
                        return turns.getCurrentTurnValues().damageRisk
                    end,
                    set = function(info, value)
                        turns.setDefendValues(nil, value)
                    end
                },
                defend = {
                    name = "Defend",
                    type = "group",
                    inline = true,
                    order = 2,
                    args = {
                        damageTaken = {
                            name = "Damage taken",
                            type = "description",
                            desc = "How much damage you take this turn",
                            fontSize = "medium",
                            order = 0,
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
                    },
                },
                save = {
                    name = "Melee save",
                    type = "group",
                    inline = true,
                    order = 3,
                    args = {
                        saveDamageTaken = {
                            name = "Damage taken",
                            type = "description",
                            desc = "How much damage you take this turn",
                            fontSize = "medium",
                            order = 0,
                            name = function()
                                local defence = character.getPlayerDefence()
                                local buff = turns.getCurrentBuffs().defence
                                local values = turns.getCurrentTurnValues()
                                local save = actions.getMeleeSave(values.roll, values.defendThreshold, values.damageRisk, defence, buff)

                                if save.damageTaken > 0 then
                                    local msg = ""
                                    if save.isBigFail then
                                        msg = COLOURS.DAMAGE .. "Bad save! |r"
                                    end
                                    return msg .. "You can save your ally, |r" .. COLOURS.DAMAGE .. "but you will take " .. tostring(save.damageTaken) .. " damage."
                                else
                                    return COLOURS.SAVE .. "You can save your ally without taking any damage yourself."
                                end
                            end
                        },
                    },
                },
            }
        }
    }
}