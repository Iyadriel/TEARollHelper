local _, ns = ...

local turns = ns.turns
local ui = ns.ui

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
                    name = "Offence",
                    desc = "Your character's offence stat",
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
            name = "Feats",
            type = "group",
            inline = true,
            order = 1,
            get = function(info)
                return TEARollHelper.db.profile.feats[info[#info]]
            end,
            set = function(info, value)
                local feat = info[#info]
                local featName = info.option.name
                TEARollHelper.db.profile.feats[feat] = value
                -- if slash command, print feedback
                if info[0] and info[0] ~= "" then
                    local status = value and "enabled" or "disabled"
                    TEARollHelper:Print("Feat '" .. featName .. "' has been " .. status .. ".")
                end
            end,
            args = {
                desc = {
                    type = "description",
                    name = "More Feats may be supported in the future."
                },
                keenSense = {
                    type = "toggle",
                    name = "Keen sense",
                    desc = "The threshold for getting a critical roll is reduced to 19 from 20."
                }
            }
        }
    }
}