local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

local RACIAL_TRAIT_LIST = {}
for key, trait in pairs(racialTraits.RACIAL_TRAITS) do
    RACIAL_TRAIT_LIST[trait.id] = racialTraits.RACE_NAMES[trait.id] .. " (" .. trait.name .. ")"
end

-- Update roll UI, in case it is also open
local function notifyChange()
    AceConfigRegistry:NotifyChange("TEARollHelperRolls")
end

ui.modules.character = {
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
                TEARollHelper.db.profile.stats[stat] = value
                -- if slash command, print feedback
                if info[0] and info[0] ~= "" then
                    TEARollHelper:Print("Your character's " .. stat .. " has been set to "..value..".")
                end
                notifyChange()
            end,
            validate = function(info, input)
                if input == nil then
                    local stat = info[#info]
                    local statName = info.option.name
                    return statName .. " stat must be a number! |cFFBBBBBBExample: /tea " .. stat .. " 4"
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
                    min = -100,
                    max = 100,
                    softMin = -4,
                    softMax = 6,
                    step = 1,
                    order = 0
                },
                defence = {
                    type = "range",
                    name = "Defence",
                    desc = "Your character's defence stat",
                    min = -100,
                    max = 100,
                    softMin = -4,
                    softMax = 6,
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
                    min = -100,
                    max = 100,
                    softMin = -4,
                    softMax = 6,
                    step = 1,
                    order = 2
                },
                stamina = {
                    type = "range",
                    name = function()
                        return "Stamina (max HP: " .. rules.stamina.calculateMaxHP(character.getPlayerStamina()) .. ")"
                    end,
                    desc = "Affects your character's maximum HP.",
                    min = -100,
                    max = 100,
                    softMin = -4,
                    softMax = 6,
                    step = 1,
                    order = 3
                },
                availablePoints = {
                    type = "description",
                    name = function()
                        local availablePoints = rules.getAvailableStatPoints()
                        local availableNegativePoints = rules.getAvailableNegativePoints()
                        local msg = " |n"

                        if availablePoints > 0 then
                            msg = msg .. "Available points: " .. availablePoints
                        elseif availablePoints == 0 then
                            local negativePointsTooMany = rules.getNegativePointsAssigned() - rules.getNegativePointsUsed()
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
        racialTrait = {
            name = "Racial trait",
            type = "select",
            disabled = function()
                return turns.getRacialTrait() ~= nil
            end,
            order = 4,
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
            order = 5
        },
        racialTraitDisabledNote = {
            type = "description",
            name = function()
                if turns.getRacialTrait() ~= nil then
                    return COLOURS.NOTE .. "You must deactivate your racial trait before you can change it."
                end
                return ""
            end,
            order = 6
        }
    }
}