local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local constants = ns.constants
local rules = ns.rules
local ui = ns.ui

local feats = ns.resources.feats
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local STATS = constants.STATS
local STAT_LABELS = constants.STAT_LABELS
local STAT_MIN_VALUE = rules.stats.STAT_MIN_VALUE
local STAT_MAX_VALUE = rules.stats.STAT_MAX_VALUE
local WEAKNESSES = weaknesses.WEAKNESSES

-- Update turn UI, in case it is also open
local function updateTurnUI()
    ui.update(ui.modules.turn.name)
end

local function getStatLabel(stat)
    return function()
        local label = STAT_LABELS[stat]

        if stat == STATS.stamina then
            label = label .. " (HP: " .. character.calculatePlayerMaxHealthWithoutBuffs() .. ")"
        end

        if character.hasProficiency(stat) then
            if character.hasMastery(stat) then
                label = label .. COLOURS.MASTERY .. " (Mastery)"
            else
                label = label .. COLOURS.PROFICIENCY .. " (Proficiency)"
            end
        end
        return label
    end
end

--[[ local options = {
    order: Number,
} ]]
ui.modules.config.modules.character.modules.stats.getOptions = function(options)
    return {
        order = options.order,
        name = "Stats",
        type = "group",
        inline = true,
        get = function(info)
            return TEARollHelper.db.profile.stats[info[#info]]
        end,
        set = function(info, value)
            local stat = info[#info]
            character.setStat(stat, value)
            -- if slash command, print feedback
            if info[0] and info[0] ~= "" then
                TEARollHelper:Print("Your character's " .. stat .. " has been set to "..value..".")
            end
            updateTurnUI()
        end,
        validate = function(info, input)
            local stat = info[#info]
            if input == nil then
                return stat .. " stat must be a number! |cFFBBBBBBExample: /tea " .. stat .. " 4"
            end
            if input < STAT_MIN_VALUE or input > STAT_MAX_VALUE then
                return stat .. " must be between " .. STAT_MIN_VALUE .. " and " .. STAT_MAX_VALUE .. "."
            end
            return true
        end,
        args = {
            offence = {
                type = "range",
                name = getStatLabel(STATS.offence),
                desc = "Proficiency bonus: +1 base damage. |nMastery bonus: +1 base damage, increases to +3 on first player turn after being saved by another player",
                min = STAT_MIN_VALUE,
                max = STAT_MAX_VALUE,
                step = 1,
                order = 0
            },
            defence = {
                type = "range",
                name = getStatLabel(STATS.defence),
                desc = "Proficiency bonus: When you block incoming damage to yourself, or to someone else via Melee save, it counts towards your ”Damage prevented”. When that counter reaches 50 it resets back to zero and you can regain 1 fate point. |nMastery bonus: You can let someone else regain 1 fate point, not just yourself.",
                min = STAT_MIN_VALUE,
                max = STAT_MAX_VALUE,
                step = 1,
                order = 1
            },
            spirit = {
                type = "range",
                name = getStatLabel(STATS.spirit),
                desc = "Proficiency bonus: +1 Greater Heal slot. |nMastery bonus: +1 Greater Heal slot and increases healing done to KO'd targets by +3.",
                min = STAT_MIN_VALUE,
                max = STAT_MAX_VALUE,
                step = 1,
                order = 2
            },
            stamina = {
                type = "range",
                name = getStatLabel(STATS.stamina),
                desc = "Proficiency bonus: When at risk of receiving a critical wound, roll 1-4, if your result is 4 you resist the critical wound. |nMastery bonus: If your result is 1 or 4 you resist the critical wound.",
                min = STAT_MIN_VALUE,
                max = STAT_MAX_VALUE,
                step = 1,
                order = 3
            },
            availablePoints = {
                order = 4,
                type = "description",
                name = function()
                    local availablePoints = rules.stats.getAvailableStatPoints()
                    local availableNegativePoints = rules.stats.getAvailableNegativePoints()
                    local msg = " |n"

                    if availablePoints > 0 then
                        msg = msg .. "Available points: " .. availablePoints
                    elseif availablePoints == 0 then
                        local negativePointsTooMany = rules.stats.getNegativePointsAssigned() - rules.stats.getNegativePointsUsed()
                        if negativePointsTooMany > 0 then
                            msg = msg .. "You have " .. negativePointsTooMany .. " more negative point(s) than you can use. This is allowed, but it will not benefit you."
                        else
                            msg = msg .. COLOURS.SUCCESS .. "You have allocated all available points."
                            if availableNegativePoints > 0 then
                                msg = msg .. COLOURS.NOTE .. "|nYou can unlock " .. availableNegativePoints .. " more points by going negative in one or more stats."
                            end
                        end
                    else
                        msg = msg .. COLOURS.ERROR .. "You have spent " .. abs(availablePoints) .. " point(s) too many."
                    end

                    return msg
                end,
            },
            chaplainOfViolenceWarning = {
                order = 5,
                type = "description",
                name = COLOURS.ERROR .. "These stats are not compatible with your " .. FEATS.CHAPLAIN_OF_VIOLENCE.name .. " feat.",
                hidden = function()
                    return not character.hasFeat(FEATS.CHAPLAIN_OF_VIOLENCE) or rules.stats.validateStatsForChaplainOfViolence()
                end,
            },
            reboundWarning = {
                order = 6,
                type = "description",
                name = COLOURS.ERROR .. "These stats are not compatible with your " .. WEAKNESSES.REBOUND.name .. " weakness.",
                hidden = function()
                    return not rules.rolls.canProcRebound() or rules.stats.validateStatsForRebound()
                end,
            },
            temperedBenevolenceWarning = {
                order = 7,
                type = "description",
                name = COLOURS.ERROR .. "These stats are not compatible with your " .. WEAKNESSES.TEMPERED_BENEVOLENCE.name .. " weakness.",
                hidden = function()
                    return not character.hasWeakness(WEAKNESSES.TEMPERED_BENEVOLENCE) or rules.stats.validateStatsForTemperedBenevolence()
                end,
            },
            overflowWarning = {
                order = 8,
                type = "description",
                name = COLOURS.ERROR .. "These stats are not compatible with your " .. WEAKNESSES.OVERFLOW.name .. " weakness.",
                hidden = function()
                    return not character.hasWeakness(WEAKNESSES.OVERFLOW) or rules.stats.validateStatsForOverflow()
                end,
            }
        }
    }
end