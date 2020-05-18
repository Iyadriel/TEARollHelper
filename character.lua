local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local rules = ns.rules

local FEATS = feats.FEATS

local getPlayerOffence, getPlayerDefence, getPlayerSpirit, getPlayerStamina, getPlayerMaxHP
local hasOffenceMastery, hasSpiritMastery
local getPlayerFeat, hasFeat, hasFeatByID, setPlayerFeatByID, getPlayerRacialTrait, hasRacialTrait

function getPlayerOffence()
    return tonumber(TEARollHelper.db.profile.stats.offence)
end

function getPlayerDefence()
    return tonumber(TEARollHelper.db.profile.stats.defence)
end

function getPlayerSpirit()
    return tonumber(TEARollHelper.db.profile.stats.spirit)
end

function getPlayerStamina()
    return tonumber(TEARollHelper.db.profile.stats.stamina)
end

function getPlayerMaxHP()
    return rules.stats.calculateMaxHP(getPlayerStamina())
end

function hasOffenceMastery()
    return getPlayerOffence() >= 6
end

function hasSpiritMastery()
    return getPlayerSpirit() >= 6
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

function getPlayerRacialTrait()
    return racialTraits.getRacialTrait(TEARollHelper.db.profile.racialTraitID)
end

function hasRacialTrait(racialTrait)
    return TEARollHelper.db.profile.racialTraitID == racialTrait.id
end

character.getPlayerOffence = getPlayerOffence
character.getPlayerDefence = getPlayerDefence
character.getPlayerSpirit = getPlayerSpirit
character.getPlayerStamina = getPlayerStamina
character.getPlayerMaxHP = getPlayerMaxHP
character.hasOffenceMastery = hasOffenceMastery
character.hasSpiritMastery = hasSpiritMastery
character.getPlayerFeat = getPlayerFeat
character.hasFeat = hasFeat
character.hasFeatByID = hasFeatByID
character.setPlayerFeatByID = setPlayerFeatByID
character.getPlayerRacialTrait = getPlayerRacialTrait
character.hasRacialTrait = hasRacialTrait