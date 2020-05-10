local _, ns = ...

local character = ns.character
local turns = ns.turns

local getPlayerOffence, getPlayerDefence,characterSheetToString

function getPlayerOffence()
    return tonumber(TeaRollHelper.db.profile.stats.offence)
end

function getPlayerDefence()
    return tonumber(TeaRollHelper.db.profile.stats.defence)
end

function getPlayerSpirit()
    return tonumber(TeaRollHelper.db.profile.stats.spirit)
end

--[[ function characterSheetToString()
    local offence = getPlayerOffence()
    local defence = getPlayerDefence()

    local msg = "Your character: < Offence: |cFF15A8D8"..offence.."|r "

    local currentBuffs = turns.getCurrentBuffs()

    if currentBuffs.offence > 0 then
        msg = msg .. "|cFF00FF00+ "..currentBuffs.offence.."|r "
    end

    msg = msg .. "- Defence: |cFF15A8D8"..defence.."|r "

    if currentBuffs.defence > 0 then
        msg = msg .. "|cFF00FF00+ "..currentBuffs.defence.."|r "
    end

    msg = msg .. ">|n"

    return msg
end ]]

character.getPlayerOffence = getPlayerOffence
character.getPlayerDefence = getPlayerDefence
character.getPlayerSpirit = getPlayerSpirit