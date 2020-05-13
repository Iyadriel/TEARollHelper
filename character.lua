local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local turns = ns.turns

local FEATS = feats.FEATS

local getPlayerOffence, getPlayerDefence, getPlayerSpirit
local hasOffenceMastery
local getPlayerFeat, hasFeat, hasFeatByID, setPlayerFeatByID, hasRacialTrait

function getPlayerOffence()
    return tonumber(TEARollHelper.db.profile.stats.offence)
end

function getPlayerDefence()
    return tonumber(TEARollHelper.db.profile.stats.defence)
end

function getPlayerSpirit()
    return tonumber(TEARollHelper.db.profile.stats.spirit)
end

function hasOffenceMastery()
    return getPlayerOffence() >= 6
end

function getPlayerFeat()
    return FEATS[TEARollHelper.db.profile.featID]
end

function hasFeat(feat)
    return hasFeatByID(feat.id)
end

function hasFeatByID(featID)
    return TEARollHelper.db.profile.featID == featID
end

function setPlayerFeatByID(featID)
    TEARollHelper.db.profile.featID = featID
end

function hasRacialTrait(racialTrait)
    return TEARollHelper.db.profile.racialTraitID == racialTrait.id
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
character.hasOffenceMastery = hasOffenceMastery
character.getPlayerFeat = getPlayerFeat
character.hasFeat = hasFeat
character.hasFeatByID = hasFeatByID
character.setPlayerFeatByID = setPlayerFeatByID
character.hasRacialTrait = hasRacialTrait