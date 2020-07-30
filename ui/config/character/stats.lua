local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local rules = ns.rules
local ui = ns.ui
local weaknesses = ns.resources.weaknesses

local STAT_MIN_VALUE = rules.stats.STAT_MIN_VALUE
local STAT_MAX_VALUE = rules.stats.STAT_MAX_VALUE
local WEAKNESSES = weaknesses.WEAKNESSES

-- Update turn UI, in case it is also open
local function updateTurnUI()
    ui.update(ui.modules.turn.name)
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
                name = function()
                    local label = "Offence"
                    if character.hasOffenceMastery() then
                        label = label .. COLOURS.MASTERY .. " Mastery unlocked!"
                    end
                    return label
                end,
                desc = "Mastery bonus: +2 base damage, increases to +4 on first player turn after being saved by another player",
                min = STAT_MIN_VALUE,
                max = STAT_MAX_VALUE,
                step = 1,
                order = 0
            },
            defence = {
                type = "range",
                name = "Defence",
                desc = "Your character's defence stat",
                min = STAT_MIN_VALUE,
                max = STAT_MAX_VALUE,
                step = 1,
                order = 1
            },
            spirit = {
                type = "range",
                name = function()
                    local label = "Spirit"
                    if character.hasSpiritMastery() then
                        label = label .. COLOURS.MASTERY .. " Mastery unlocked!"
                    end
                    return label
                end,
                desc = "Mastery bonus: +1 Greater Heal slot. Increases healing done to KO'd targets by +3.",
                min = STAT_MIN_VALUE,
                max = STAT_MAX_VALUE,
                step = 1,
                order = 2
            },
            stamina = {
                type = "range",
                name = function()
                    return "Stamina (max HP: " .. character.calculatePlayerMaxHealthWithoutBuffs() .. ")"
                end,
                desc = "Affects your character's maximum HP.",
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
            reboundWarning = {
                order = 5,
                type = "description",
                name = COLOURS.ERROR .. "These stats are not compatible with your " .. WEAKNESSES.REBOUND.name .. " weakness.",
                hidden = function()
                    return not rules.rolls.canProcRebound() or rules.stats.validateStatsForRebound()
                end,
            },
            temperedBenevolenceWarning = {
                order = 6,
                type = "description",
                name = COLOURS.ERROR .. "These stats are not compatible with your " .. WEAKNESSES.TEMPERED_BENEVOLENCE.name .. " weakness.",
                hidden = function()
                    return not character.hasWeakness(WEAKNESSES.TEMPERED_BENEVOLENCE) or rules.stats.validateStatsForTemperedBenevolence()
                end,
            },
            overflowWarning = {
                order = 7,
                type = "description",
                name = COLOURS.ERROR .. "These stats are not compatible with your " .. WEAKNESSES.OVERFLOW.name .. " weakness.",
                hidden = function()
                    return not character.hasWeakness(WEAKNESSES.OVERFLOW) or rules.stats.validateStatsForOverflow()
                end,
            }
        }
    }
end