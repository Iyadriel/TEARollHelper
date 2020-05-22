local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local characterState = ns.state.character
local rollsState = ns.state.rolls
local ui = ns.ui

local state = characterState.state

ui.modules.buffs = {}

-- Update config UI, in case it is also open
local function notifyChange()
    AceConfigRegistry:NotifyChange(ui.modules.config.name)
end

--[[ local options = {
    order: Number
} ]]
ui.modules.buffs.getOptions = function(options)
    return {
        name = "Buffs",
        type = "group",
        desc = "Apply a temporary buff",
        guiInline = true,
        order = options.order,
        validate = function(info, input)
            if not input then return true end
            local amount = TEARollHelper:GetArgs(input)
            if tonumber(amount) == nil then
                return "Buff value must be a number! |cFFBBBBBBExample: /tea buff offence 6"
            end
            return true
        end,
        get = function(info)
            return tostring(state.buffs[info[#info]].get())
        end,
        set = function(info, input)
            local buffType = info[#info]
            local amount = TEARollHelper:GetArgs(input)
            state.buffs[buffType].set(tonumber(amount))
            -- if slash command, print feedback
            if info[0] and info[0] ~= "" then
                TEARollHelper:Print("Applied temporary " .. buffType .. " buff of " .. COLOURS.BUFF .. amount .. "|r.")
            end
        end,
        args = {
            offence = {
                type = "input",
                name = "Offence",
                desc = "Buff your character's Offence stat",
                width = "half",
                order = 0
            },
            defence = {
                type = "input",
                name = "Defence",
                desc = "Buff your character's Defence stat",
                width = "half",
                order = 1
            },
            spirit = {
                type = "input",
                name = "Spirit",
                desc = "Buff your character's Spirit stat",
                width = "half",
                order = 2
            },
            clear = {
                type = "execute",
                name = "Clear",
                desc = "Clear your current buffs",
                width = "half",
                order = 3,
                func = function(info)
                    for buff in pairs(state.buffs) do
                        state.buffs[buff].set(0)
                    end
                    -- if slash command, print feedback
                    if info[0] and info[0] ~= "" then
                        TEARollHelper:Print("Temporary buffs have been cleared.")
                    end
                end
            },
            racialTrait = {
                type = "toggle",
                name = function()
                    return "Activate racial trait (" .. character.getPlayerRacialTrait().name .. ")"
                end,
                desc = function()
                    return character.getPlayerRacialTrait().desc
                end,
                cmdHidden = true,
                width = "full",
                order = 4,
                hidden = function()
                    local trait = character.getPlayerRacialTrait()
                    return not (trait.supported and trait.manualActivation)
                end,
                validate = function() return true end,
                get = function()
                    return rollsState.state.racialTrait ~= nil
                end,
                set = function(info, value)
                    rollsState.state.racialTrait = (value and character.getPlayerRacialTrait() or nil)
                    notifyChange() -- so we can disable/enable trait selection in character sheet
                end
            },
        }
    }
end