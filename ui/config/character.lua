local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local COLOURS = TEARollHelper.COLOURS

local bus = ns.bus
local character = ns.character
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local rolls = ns.state.rolls
local rules = ns.rules
local ui = ns.ui

local EVENTS = bus.EVENTS
local STAT_MIN_VALUE = rules.stats.STAT_MIN_VALUE
local STAT_MAX_VALUE = rules.stats.STAT_MAX_VALUE

local RACIAL_TRAIT_LIST = {}
for key, trait in pairs(racialTraits.RACIAL_TRAITS) do
    RACIAL_TRAIT_LIST[trait.id] = racialTraits.RACE_NAMES[trait.id] .. " (" .. trait.name .. ")"
end

-- Update turn UI, in case it is also open
local function notifyChange()
    AceConfigRegistry:NotifyChange(ns.ui.modules.turn.name)
end

ui.modules.config.modules.character.modules = {
    traits = {},
    weaknesses = {}
}

ui.modules.config.modules.character.getOptions = function()
    local traitOptions = {}
    local traitOrder = 4
    for i = 1, rules.traits.MAX_NUM_TRAITS do
        traitOptions[i] = ui.modules.config.modules.character.modules.traits.getOptions({ slotIndex = i, order = traitOrder })
        traitOrder = traitOrder + 3
    end

    return {
        name = "Character sheet",
        type = "group",
        desc = "Set up your character sheet",
        guiInline = true,
        order = 1,
        args = {
            stats = {
                name = "Stats",
                type = "group",
                inline = true,
                order = 0,
                get = function(info)
                    return TEARollHelper.db.profile.stats[info[#info]]
                end,
                set = function(info, value)
                    local stat = info[#info]
                    character.setStat(stat, value)
                    bus.fire(EVENTS.CHARACTER_STAT_CHANGED, stat, value)
                    -- if slash command, print feedback
                    if info[0] and info[0] ~= "" then
                        TEARollHelper:Print("Your character's " .. stat .. " has been set to "..value..".")
                    end
                    notifyChange()
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
                        desc = "Mastery bonus: +2 base damage",
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
                        desc = "Mastery bonus: +1 Greater Heal slot",
                        min = STAT_MIN_VALUE,
                        max = STAT_MAX_VALUE,
                        step = 1,
                        order = 2
                    },
                    stamina = {
                        type = "range",
                        name = function()
                            return "Stamina (max HP: " .. rules.stats.calculateMaxHP(character.getPlayerStamina()) .. ")"
                        end,
                        desc = "Affects your character's maximum HP.",
                        min = STAT_MIN_VALUE,
                        max = STAT_MAX_VALUE,
                        step = 1,
                        order = 3
                    },
                    availablePoints = {
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
                        order = 4
                    }
                }
            },
            feats = {
                name = "Feat",
                type = "select",
                desc = "More Feats may be supported in the future.",
                order = 1,
                values = (function()
                    local featOptions = {}
                    for i = 1, #feats.FEAT_KEYS do
                        local key = feats.FEAT_KEYS[i]
                        local feat = feats.FEATS[key]
                        featOptions[key] = feat.name
                    end
                    return featOptions
                end)(),
                get = function()
                    local feat = character.getPlayerFeat()
                    return feat and feat.id
                end,
                set = function(info, value)
                    character.setPlayerFeatByID(value)
                    notifyChange()
                end
            },
            featDesc = {
                type = "description",
                name = function()
                    local feat = character.getPlayerFeat()
                    return feat and feat.desc or ""
                end,
                fontSize = "medium",
                order = 2
            },
            featNote = {
                type = "description",
                name = function()
                    local feat = character.getPlayerFeat()
                    return COLOURS.NOTE .. (feat and (feat.note and feat.note .. "|n ") or "")
                end,
                order = 3
            },
            trait1 = traitOptions[1].trait,
            trait1Desc = traitOptions[1].traitDesc,
            trait1Note = traitOptions[1].traitNote,
            trait2 = traitOptions[2].trait,
            trait2Desc = traitOptions[2].traitDesc,
            trait2Note = traitOptions[2].traitNote,
            trait3 = traitOptions[3].trait,
            trait3Desc = traitOptions[3].traitDesc,
            trait3Note = traitOptions[3].traitNote,
            weaknesses = ui.modules.config.modules.character.modules.weaknesses.getOptions({ order = 13 }),
            numWeaknesses = {
                type = "range",
                name = "Weaknesses",
                min = 0,
                max = 2,
                step = 1,
                order = 14,
                get = character.getNumWeaknesses,
                set = function(info, value)
                    character.setNumWeaknesses(value)
                end,
            },
            weaknessNote = {
                type = "description",
                name = COLOURS.NOTE .. "Not all weaknesses are currently supported, but the amount of weaknesses you have affects how many traits you can have.|n ",
                order = 15,
            },
            racialTrait = {
                name = "Racial trait",
                type = "select",
                disabled = function()
                    return rolls.state.racialTrait ~= nil
                end,
                order = 16,
                get = function()
                    return TEARollHelper.db.profile.racialTraitID
                end,
                set = function(info, value)
                    TEARollHelper.db.profile.racialTraitID = tonumber(value)
                    notifyChange()
                end,
                values = RACIAL_TRAIT_LIST
            },
            racialTraitDesc = {
                type = "description",
                image = function()
                    local trait = racialTraits.getRacialTrait(TEARollHelper.db.profile.racialTraitID)
                    return trait and trait.icon
                end,
                imageCoords = {.08, .92, .08, .92},
                name = function()
                    local msg = ""
                    local trait = racialTraits.getRacialTrait(TEARollHelper.db.profile.racialTraitID)
                    if trait and trait.desc then
                        if not trait.supported then
                            msg = COLOURS.NOTE .. "(Not implemented)|r "
                        end
                        msg = msg .. trait.desc
                    end
                    return msg
                end,
                fontSize = "medium",
                order = 17
            },
            racialTraitDisabledNote = {
                type = "description",
                name = function()
                    if rolls.state.racialTraits ~= nil then
                        return COLOURS.NOTE .. "You must deactivate your racial trait before you can change it."
                    end
                    return ""
                end,
                order = 18
            }
        }
    }
end