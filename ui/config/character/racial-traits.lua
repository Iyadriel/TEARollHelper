local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local racialTraits = ns.resources.racialTraits
local ui = ns.ui
local weaknesses = ns.resources.weaknesses

local WEAKNESSES = weaknesses.WEAKNESSES

local RACIAL_TRAIT_LIST = {}
for _, trait in pairs(racialTraits.RACIAL_TRAITS) do
    RACIAL_TRAIT_LIST[trait.id] = racialTraits.RACE_NAMES[trait.id] .. " (" .. trait.name .. ")"
end

-- Update turn UI, in case it is also open
local function updateTurnUI()
    ui.update(ui.modules.turn.name)
end

--[[ local options = {
    order: Number,
} ]]
ui.modules.config.modules.character.modules.racialTraits.getOptions = function(options)
    return {
        racialTrait = {
            order = options.order,
            name = "Racial trait",
            type = "select",
            disabled = function()
                return character.hasWeakness(WEAKNESSES.OUTCAST)
            end,
            get = function()
                return character.getPlayerRacialTrait().id
            end,
            set = function(info, value)
                character.setPlayerRacialTraitByID(value)
                updateTurnUI()
            end,
            values = RACIAL_TRAIT_LIST
        },
        racialTraitDesc = {
            order = options.order + 1,
            type = "description",
            image = function()
                local trait = character.getPlayerRacialTrait()
                return trait and trait.icon
            end,
            imageCoords = {.08, .92, .08, .92},
            name = function()
                local msg = ""
                local trait = character.getPlayerRacialTrait()
                if trait and trait.desc then
                    if not trait.supported then
                        msg = COLOURS.NOTE .. "(Not implemented)|r "
                    end
                    msg = msg .. trait.desc
                end
                return msg
            end,
            fontSize = "medium",
        },
        racialTraitNote = {
            order = options.order + 2,
            type = "description",
            name = function()
                local trait = character.getPlayerRacialTrait()
                return COLOURS.NOTE .. (trait and (trait.note and trait.note .. "|n ") or "")
            end,
        },
    }
end