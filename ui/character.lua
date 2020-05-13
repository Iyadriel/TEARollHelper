local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
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
                return tostring(TEARollHelper.db.profile.stats[info[#info]])
            end,
            set = function(info, value)
                local stat = info[#info]
                TEARollHelper.db.profile.stats[stat] = tonumber(value)
                -- if slash command, print feedback
                if info[0] and info[0] ~= "" then
                    TEARollHelper:Print("Your character's " .. stat .. " has been set to "..value..".")
                end
                notifyChange()
            end,
            validate = function(info, input)
                if tonumber(input) == nil then
                    local stat = info[#info]
                    local statName = info.option.name
                    return statName .. " stat must be a number! |cFFBBBBBBExample: /tea " .. stat .. " 4"
                end
                return true
            end,
            args = {
                offence = {
                    type = "input",
                    name = function()
                        local label = "Offence"
                        if character.hasOffenceMastery() then
                            label = label .. COLOURS.MASTERY .. " Mastery unlocked!"
                        end
                        return label
                    end,
                    desc = "Mastery bonus: +2 base damage",
                    order = 0
                },
                defence = {
                    type = "input",
                    name = "Defence",
                    desc = "Your character's defence stat",
                    order = 1
                },
                spirit = {
                    type = "input",
                    name = "Spirit",
                    desc = "Your character's spirit stat",
                    order = 2
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
        racialTrait = {
            name = "Racial trait",
            type = "select",
            order = 3,
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
            order = 4
        }
    }
}