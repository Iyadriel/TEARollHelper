local _, ns = ...

local bus = ns.bus
local character = ns.character
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local EVENTS = bus.EVENTS
local FEATS = feats.FEATS
local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local getPlayerOffence, getPlayerDefence, getPlayerSpirit, getPlayerStamina, getPlayerMaxHP
local hasOffenceMastery, hasSpiritMastery
local getPlayerFeat, hasFeat, hasFeatByID, setPlayerFeatByID, getPlayerRacialTrait, hasRacialTrait
local clearExcessTraits

-- [[ Stats ]]

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

local function setStat(stat, value)
    TEARollHelper.db.profile.stats[stat] = value
end

function hasOffenceMastery()
    return getPlayerOffence() >= 6
end

function hasSpiritMastery()
    return getPlayerSpirit() >= 6
end

-- [[ Feats ]]

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
    clearExcessTraits()
    bus.fire(EVENTS.FEAT_CHANGED, featID)
end

-- [[ Traits ]]

local function hasTraitByID(traitID)
    for slot, id in pairs(TEARollHelper.db.profile.traits) do
        if id == traitID then
            return true
        end
    end
    return false
end

local function hasTrait(trait)
    return hasTraitByID(trait.id)
end

local function getPlayerTraitIDAtSlot(slotIndex)
    return TEARollHelper.db.profile.traits[slotIndex]
end

local function getPlayerTraitAtSlot(slotIndex)
    local traitID = getPlayerTraitIDAtSlot(slotIndex)
    return TRAITS[traitID]
end

local function setPlayerTraitByID(index, traitID)
    TEARollHelper.db.profile.traits[index] = traitID
end

local function clearPlayerTrait(index)
    TEARollHelper.db.profile.traits[index] = TRAITS.OTHER.id
end

function clearExcessTraits()
    local maxTraits = rules.traits.calculateMaxTraits()
    for i = maxTraits + 1, #TEARollHelper.db.profile.traits do
        clearPlayerTrait(i)
    end
end

-- [[ Racial traits ]]

function getPlayerRacialTrait()
    return racialTraits.getRacialTrait(TEARollHelper.db.profile.racialTraitID)
end

function hasRacialTrait(racialTrait)
    return TEARollHelper.db.profile.racialTraitID == racialTrait.id
end

local function setPlayerRacialTraitByID(racialTraitID)
    TEARollHelper.db.profile.racialTraitID = racialTraitID
end

local function setPlayerRacialTrait(racialTrait)
    setPlayerRacialTraitByID(racialTrait.id)
end

-- [[ Weaknesses ]]

local function getNumWeaknesses()
    return TEARollHelper.db.profile.numWeaknesses
end

local function setNumWeaknesses(numWeaknesses)
    TEARollHelper.db.profile.numWeaknesses = numWeaknesses
    clearExcessTraits()
end

local function hasWeaknessByID(weaknessID)
    return TEARollHelper.db.profile.weaknesses[weaknessID]
end

local function hasWeakness(weakness)
    return hasWeaknessByID(weakness.id)
end

local function togglePlayerWeaknessByID(weaknessID, value)
    if not value then value = nil end
    TEARollHelper.db.profile.weaknesses[weaknessID] = value
    local event = value and EVENTS.WEAKNESS_ADDED or EVENTS.WEAKNESS_REMOVED
    bus.fire(event, weaknessID)
end

bus.addListener(EVENTS.WEAKNESS_ADDED, function(weaknessID)
    if weaknessID == WEAKNESSES.OUTCAST.id then
        setPlayerRacialTrait(RACIAL_TRAITS.OUTCAST)
    end
end)

character.getPlayerOffence = getPlayerOffence
character.getPlayerDefence = getPlayerDefence
character.getPlayerSpirit = getPlayerSpirit
character.getPlayerStamina = getPlayerStamina
character.getPlayerMaxHP = getPlayerMaxHP
character.setStat = setStat

character.hasOffenceMastery = hasOffenceMastery
character.hasSpiritMastery = hasSpiritMastery

character.getPlayerFeat = getPlayerFeat
character.hasFeat = hasFeat
character.hasFeatByID = hasFeatByID
character.setPlayerFeatByID = setPlayerFeatByID

character.hasTrait = hasTrait
character.getPlayerTraitIDAtSlot = getPlayerTraitIDAtSlot
character.getPlayerTraitAtSlot = getPlayerTraitAtSlot
character.setPlayerTraitByID = setPlayerTraitByID

character.getPlayerRacialTrait = getPlayerRacialTrait
character.hasRacialTrait = hasRacialTrait
character.setPlayerRacialTraitByID = setPlayerRacialTraitByID

character.getNumWeaknesses = getNumWeaknesses
character.setNumWeaknesses = setNumWeaknesses

character.hasWeaknessByID = hasWeaknessByID
character.hasWeakness = hasWeakness
character.togglePlayerWeaknessByID = togglePlayerWeaknessByID