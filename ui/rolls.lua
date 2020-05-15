local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

-- Update config UI, in case it is also open
local function notifyChange()
    AceConfigRegistry:NotifyChange("TEARollHelper")
end

ui.modules.rolls.modules = {
    attack = {},
    healing = {}
}

ui.modules.rolls.getOptions = function()
    return {
        name = "TEA Roll View",
        type = "group",
        desc = "See possible outcomes for a given roll",
        cmdHidden = true,
        order = 3,
        childGroups = "tab",
        args = {
            rollMode = {
                name = "Roll mode",
                type = "select",
                order = 0,
                values = turns.ROLL_MODE_LABELS,
                get = turns.getRollMode,
                set = function(info, value)
                    turns.setRollMode(value)
                end
            },
            performRoll = {
                name = function()
                    return turns.isRolling() and "Rolling..." or "Roll"
                end,
                type = "execute",
                desc = "Do a /roll " .. rules.MAX_ROLL .. ".",
                disabled = function()
                    return turns.isRolling()
                end,
                order = 1,
                func = turns.roll
            },
            roll = {
                name = "Roll result",
                type = "range",
                desc = "The number you rolled",
                min = 1,
                softMax = rules.MAX_ROLL,
                max = rules.MAX_ROLL * 2, -- "support" prepping by letting people add rolls together
                step = 1,
                order = 2,
                get = function()
                    return turns.getCurrentTurnValues().roll
                end,
                set = function(info, value)
                    turns.setCurrentRoll(value)
                end
            },
            buffs = ui.modules.buffs.getOptions(),
            racialTrait = {
                type = "toggle",
                name = function()
                    return "Activate racial trait (" .. character.getPlayerRacialTrait().name .. ")"
                end,
                desc = function()
                    return character.getPlayerRacialTrait().desc
                end,
                width = "full",
                order = 4,
                hidden = function()
                    local trait = character.getPlayerRacialTrait()
                    return not (trait.supported and trait.manualActivation)
                end,
                get = function()
                    return turns.getRacialTrait() ~= nil
                end,
                set = function(info, value)
                    turns.setRacialTrait(value and character.getPlayerRacialTrait() or nil)
                    notifyChange() -- so we can disable/enable the trait selection
                end
            },
            playerTurn = {
                name = "Player turn",
                type = "group",
                order = 5,
                args = {
                    attack = ui.modules.rolls.modules.attack.getOptions({ order = 0 }),
                    heal = ui.modules.rolls.modules.healing.getOptions({
                        order = 1,
                        outOfCombat = false
                    }),
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
                                    local offence = character.getPlayerOffence()
                                    local offenceBuff = turns.getCurrentBuffs().offence
                                    local buff = actions.getBuff(turns.getCurrentTurnValues().roll, spirit, offence, offenceBuff)

                                    local msg

                                    if buff.amountBuffed > 0 then
                                        local amount = tostring(buff.amountBuffed)
                                        if buff.isCrit then
                                            msg = COLOURS.CRITICAL .. "BIG BUFF!|r " .. COLOURS.BUFF .. "You can buff everyone in line of sight for " .. amount .. "."
                                        else
                                            msg = COLOURS.BUFF .. "You can buff someone for " .. amount .. "."
                                        end

                                        if buff.usesInspiringPresence then
                                            msg = msg .. COLOURS.NOTE .. "|nYour buff is active in both the current player turn and the next enemy turn."
                                        end
                                    else
                                        msg = COLOURS.NOTE .. "You can't buff anyone with this roll."
                                    end

                                    return msg
                                end
                            }
                        }
                    }
                }
            },
            enemyTurn = {
                name = "Enemy turn",
                type = "group",
                order = 6,
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
                                    local racialTrait = turns.getRacialTrait()
                                    local defend = actions.getDefence(values.roll, values.defendThreshold, values.damageRisk, defence, buff, racialTrait)

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
                    meleeSave = {
                        name = "Melee save",
                        type = "group",
                        inline = true,
                        order = 3,
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
                                        msg = msg .. COLOURS.CRITICAL .. "\nCOUNTER-FORCE!|r You can deal "..save.counterForceDmg.." damage to your attacker!"
                                    end

                                    return msg
                                end
                            },
                        },
                    },
                    rangedSave = {
                        name = "Ranged save",
                        type = "group",
                        inline = true,
                        order = 4,
                        args = {
                            saveResult = {
                                type = "description",
                                fontSize = "medium",
                                name = function()
                                    local spirit = character.getPlayerSpirit()
                                    local values = turns.getCurrentTurnValues()
                                    local save = actions.getRangedSave(values.roll, values.defendThreshold, values.damageRisk, spirit)

                                    if save.thresholdMet then
                                        return COLOURS.SAVE .. "You can fully protect your ally."
                                    elseif save.damageReduction > 0 then
                                        return "You can reduce the damage your ally takes by " .. save.damageReduction .. ".|n" .. COLOURS.NOTE .. "However, you cannot act during the next player turn."
                                    else
                                        return COLOURS.NOTE .. "You can't reduce the damage your ally takes with this roll."
                                    end
                                end
                            },
                        },
                    },
                }
            },
            ooc = {
                name = "Out of combat",
                type = "group",
                order = 7,
                args = {
                    heal = ui.modules.rolls.modules.healing.getOptions({
                        order = 0,
                        outOfCombat = true
                    }),
                    utility = {
                        type = "group",
                        name = "Utility",
                        inline = true,
                        order = 1,
                        args = {
                            useUtilityTrait = {
                                type = "toggle",
                                name = "Use utility trait",
                                desc = "Enable if you have a utility trait that fits what you are rolling for.",
                                order = 0,
                                get = turns.utility.getUseUtilityTrait,
                                set = function(info, value)
                                    turns.utility.setUseUtilityTrait(value)
                                end
                            },
                            utility = {
                                type = "description",
                                name = "Utility",
                                desc = "The result of your utility roll",
                                fontSize = "medium",
                                order = 1,
                                name = function()
                                    local roll = turns.getCurrentTurnValues().roll
                                    local useUtilityTrait = turns.utility.getUseUtilityTrait()

                                    return " |nYour total utility roll: " .. actions.getUtility(roll, useUtilityTrait)
                                end
                            }
                        }
                    }
                }
            }
        }
    }
end