local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local constants = ns.constants
local rules = ns.rules
local ui = ns.ui

local weaknesses = ns.resources.weaknesses

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
                label = label .. COLOURS.MASTERY .. " (Master)"
            else
                label = label .. COLOURS.PROFICIENCY .. " (Proficient)"
            end
        end
        return label
    end
end

local statSliderOrder = -1
local function statSlider(stat, proficiencyDesc, masteryDesc)
    statSliderOrder = statSliderOrder + 1

    return {
        type = "range",
        name = getStatLabel(stat),
        desc = "|nProficiency bonus: " .. proficiencyDesc .. ". |n|nMastery bonus: " .. masteryDesc .. ".",
        min = STAT_MIN_VALUE,
        max = STAT_MAX_VALUE,
        step = 1,
        order = statSliderOrder
    }
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
            offence = statSlider(
                STATS.offence,
                "+2 base damage",
                "You have the Feat 'Focus' without it occupying your Feat slot (works even with Featless)"
            ),
            defence = statSlider(
                STATS.defence,
                "Damage taken from failing a Melee Save is reduced to half rounded up",
                "You have 3 charges of 'Brace'. Each charge of Brace that you spend increases your Defence stat for your next Defense roll by +2. Every 15 damage that you prevent through Defence rolls and Melee Saves restore 1 charge of Brace"
            ),
            spirit = statSlider(
                STATS.spirit,
                "+1 Greater Heal slot, healing done increased by +2",
                "Increases healing done by +2 against KO'd targets"
            ),
            stamina = statSlider(
                STATS.stamina,
                "When at risk of receiving a critical wound, roll 1-4, if your result is 1 or 4 you resist the critical wound",
                "Receive +2 HP per heal from all sources. The roll made to resist going KO is no longer raw but instead applies your Stamina"
            ),
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
            featWarning = {
                order = 5,
                type = "description",
                name = function()
                    return COLOURS.ERROR .. "These stats are not compatible with your " .. character.getPlayerFeat().name .. " feat."
                end,
                hidden = function()
                    return rules.stats.validateStatsFor(character.getPlayerFeat())
                end,
            },
            traitWarning1 = {
                order = 6,
                type = "description",
                name = function()
                    local trait = character.getPlayerTraitAtSlot(1)
                    return COLOURS.ERROR .. "These stats are not compatible with your " .. trait.name .. " trait."
                end,
                hidden = function()
                    local trait = character.getPlayerTraitAtSlot(1)
                    return not trait or rules.stats.validateStatsFor(trait)
                end,
            },
            traitWarning2 = {
                order = 7,
                type = "description",
                name = function()
                    local trait = character.getPlayerTraitAtSlot(2)
                    return COLOURS.ERROR .. "These stats are not compatible with your " .. trait.name .. " trait."
                end,
                hidden = function()
                    local trait = character.getPlayerTraitAtSlot(2)
                    return not trait or rules.stats.validateStatsFor(trait)
                end,
            },
            traitWarning3 = {
                order = 8,
                type = "description",
                name = function()
                    local trait = character.getPlayerTraitAtSlot(3)
                    return COLOURS.ERROR .. "These stats are not compatible with your " .. trait.name .. " trait."
                end,
                hidden = function()
                    local trait = character.getPlayerTraitAtSlot(3)
                    return not trait or rules.stats.validateStatsFor(trait)
                end,
            },
            reboundWarning = {
                order = 9,
                type = "description",
                name = COLOURS.ERROR .. "These stats are not compatible with your " .. WEAKNESSES.REBOUND.name .. " weakness.",
                hidden = function()
                    return not rules.rolls.canProcRebound() or rules.stats.validateStatsForRebound()
                end,
            },
            temperedBenevolenceWarning = {
                order = 10,
                type = "description",
                name = COLOURS.ERROR .. "These stats are not compatible with your " .. WEAKNESSES.TEMPERED_BENEVOLENCE.name .. " weakness.",
                hidden = function()
                    return not character.hasWeakness(WEAKNESSES.TEMPERED_BENEVOLENCE) or rules.stats.validateStatsForTemperedBenevolence()
                end,
            },
            overflowWarning = {
                order = 11,
                type = "description",
                name = COLOURS.ERROR .. "These stats are not compatible with your " .. WEAKNESSES.OVERFLOW.name .. " weakness.",
                hidden = function()
                    return not character.hasWeakness(WEAKNESSES.OVERFLOW) or rules.stats.validateStatsForOverflow()
                end,
            }
        }
    }
end