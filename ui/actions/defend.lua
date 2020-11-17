local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local buffsState = ns.state.buffs.state
local character = ns.character
local consequences = ns.consequences
local constants = ns.constants
local environment = ns.state.environment
local feats = ns.resources.feats
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui
local utils = ns.utils

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local DEFENCE_TYPES = constants.DEFENCE_TYPES
local DEFENCE_TYPE_LABELS = constants.DEFENCE_TYPE_LABELS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

-- shared with melee save
-- action: String (defend, meleeSave, rangedSave)
--[[ options = {
    thresholdLabel: String
} ]]
ui.modules.actions.modules.defend.getSharedOptions = function(action, options)
    return {
        defenceType = {
            order = 0,
            type = "select",
            name = "Defence type",
            desc = "Select 'Threshold' for regular defence rolls, or 'Damage reduction' when the damage you take is x minus the result of your defence roll.",
            values = (function()
                local defenceTypeOptions = {}
                for key, value in pairs(DEFENCE_TYPES) do
                    defenceTypeOptions[value] = DEFENCE_TYPE_LABELS[key]
                end
                return defenceTypeOptions
            end)(),
            get = rolls.state[action].defenceType.get,
            set = function(info, value)
                rolls.state[action].defenceType.set(value)
            end
        },
        defendThreshold = {
            order = 1,
            name = "Defend threshold",
            type = "range",
            desc = options.thresholdLabel,
            min = 1,
            softMax = 20,
            max = 100,
            step = 1,
            disabled = function()
                return rolls.state[action].defenceType.get() ~= DEFENCE_TYPES.THRESHOLD
            end,
            get = rolls.state[action].threshold.get,
            set = function(info, value)
                rolls.state[action].threshold.set(value)
            end
        },
        damageRisk = action ~= "rangedSave" and {
            order = 2,
            name = "Damage risk",
            type = "range",
            min = 1,
            softMax = 30,
            max = 100,
            step = 1,
            get = rolls.state[action].damageRisk.get,
            set = function(info, value)
                rolls.state[action].damageRisk.set(value)
            end
        },
        damageType = action ~= "rangedSave" and {
            order = 3,
            name = "Damage type",
            type = "select",
            values = (function()
                local damageTypeOptions = {}
                for key, value in pairs(constants.DAMAGE_TYPES) do
                    damageTypeOptions[value] = constants.DAMAGE_TYPE_LABELS[key]
                end
                return damageTypeOptions
            end)(),
            hidden = function()
                return not rules.defence.shouldShowDamageType()
            end,
            get = rolls.state[action].damageType.get,
            set = function(info, value)
                rolls.state[action].damageType.set(value)
            end
        },
    }
end

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.defend.getOptions = function(options)
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions("defend", { thresholdLabel = "The minimum required roll to not take any damage" })

    local function shouldHideRoll()
        return not (rolls.state.defend.threshold.get() and rolls.state.defend.damageRisk.get())
    end

    return {
        name = ACTION_LABELS.defend,
        type = "group",
        order = options.order,
        args = {
            defenceType = sharedOptions.defenceType,
            defendThreshold = sharedOptions.defendThreshold,
            damageRisk = sharedOptions.damageRisk,
            damageType = sharedOptions.damageType,
            useHolyBulwark = ui.helpers.traitButton(TRAITS.HOLY_BULWARK, {
                order = 4,
                hidden = function()
                    local enemyId = environment.state.enemyId.get()
                    return not rules.traits.canUseHolyBulwark(enemyId) or not rolls.state.defend.damageRisk.get()
                end,
                func = function()
                    consequences.useTrait(TRAITS.HOLY_BULWARK)(false)
                end,
            }),
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 5,
                hidden = function()
                    return shouldHideRoll() or not rules.defence.shouldShowPreRollUI()
                end,
                args = utils.merge(
                    ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 1, action = ACTIONS.defend }),
                    {
                        useBulwark = ui.helpers.traitButton(TRAITS.BULWARK, {
                            order = 0,
                            checkBuff = true,
                        }),
                        bulwarkActive = ui.helpers.traitActiveText(TRAITS.BULWARK, 0),
                        enableLivingBarricade = {
                            order = 1,
                            type = "execute",
                            name = COLOURS.FEATS.GENERIC .. "Enable " .. FEATS.LIVING_BARRICADE.name,
                            desc = FEATS.LIVING_BARRICADE.desc,
                            hidden = function()
                                return not character.hasFeat(FEATS.LIVING_BARRICADE) or buffsState.buffLookup.getFeatBuff(FEATS.LIVING_BARRICADE)
                            end,
                            func = consequences.enableLivingBarricade,
                        },
                        livingBarricadeActive = {
                            order = 1,
                            type = "description",
                            name = COLOURS.FEATS.GENERIC .. FEATS.LIVING_BARRICADE.name .. " is active.",
                            hidden = function()
                                return not (character.hasFeat(FEATS.LIVING_BARRICADE) and buffsState.buffLookup.getFeatBuff(FEATS.LIVING_BARRICADE))
                            end,
                        },
                    }
                ),
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 6,
                action = ACTIONS.defend,
                hidden = shouldHideRoll,
            }),
            defend = {
                order = 7,
                type = "group",
                name = ACTION_LABELS.defend,
                inline = true,
                hidden = function()
                    return not rolls.state.defend.currentRoll.get()
                end,
                args = {
                    damageTaken = {
                        order = 0,
                        type = "description",
                        desc = "How much damage you take this turn",
                        fontSize = "medium",
                        name = function()
                            return actions.toString(ACTIONS.defend, rolls.getDefence())
                        end
                    },
                    useEmpoweredBlades = ui.helpers.traitToggle(ACTIONS.defend, TRAITS.EMPOWERED_BLADES, {
                        order = 1,
                    }),
                    confirm = ui.helpers.confirmActionButton(ACTIONS.defend, rolls.getDefence, {
                        order = 2,
                        hideMsg = true,
                        func = function()
                            local defence = rolls.getDefence()
                            local hideMsg = defence.damageTaken > 0
                            consequences.confirmAction(ACTIONS.defend, rolls.getDefence(), hideMsg)
                        end
                    }),
                }
            },
            summary = {
                order = 8,
                type = "group",
                name = "Summary",
                inline = true,
                hidden = function()
                    return rolls.state.defend.defences.count() < 1
                end,
                args = {
                    totalDamage = {
                        order = 0,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            local msg = ""
                            local totalDamageTaken = 0
                            local totalDamagePrevented = 0

                            for i, defence in ipairs(rolls.state.defend.defences.get()) do
                                msg = msg .. COLOURS.NOTE .. ">|r " .. actions.toString(ACTIONS.defend, defence) .. "|r|n"
                                totalDamageTaken = totalDamageTaken + defence.damageTaken
                                totalDamagePrevented = totalDamagePrevented + defence.damagePrevented
                            end

                            if totalDamageTaken > 0 or totalDamagePrevented > 0 then
                                msg = msg .. COLOURS.NOTE .. "|nTotal:|r " .. totalDamageTaken .. " damage taken"

                                if totalDamagePrevented > 0 then
                                    msg = msg .. ", " .. totalDamagePrevented .. " damage prevented"
                                end

                                msg = msg .. "|n "
                            end

                            return msg
                        end,
                    },
                    reset = {
                        order = 1,
                        type = "execute",
                        width = 0.75,
                        name = "Clear",
                        func = function()
                            rolls.state.defend.defences.clear()
                        end,
                    }
                }
            },
--[[             postRoll = {
                order = 8,
                type = "group",
                name = "After rolling",
                inline = true,
                hidden = function()
                    return not rolls.state.defend.currentRoll.get() or rolls.getDefence().damageTaken > 0 or not rules.defence.shouldShowPostRollUI()
                end,
                args = {}
            } ]]
        },
    }
end