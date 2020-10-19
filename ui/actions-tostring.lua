local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local function attackToString(attack)
    local msg = ""

    if attack.dmg > 0 then
        local excited = false

        if attack.isCrit and attack.critType == rules.offence.CRIT_TYPES.DAMAGE then
            excited = true
            msg = msg .. COLOURS.CRITICAL .. "CRITICAL HIT!|r "
        end

        if attack.isCrit and attack.critType == rules.offence.CRIT_TYPES.REAPER then
            msg = msg .. COLOURS.FEATS.REAPER .. "TIME TO REAP!|r You deal " .. tostring(attack.dmg) .. " damage to all enemies in melee range of you or your target!"
        else
            msg = msg .. "You deal " .. tostring(attack.dmg) .. " damage" .. (excited and "!" or ".")
        end

        if attack.hasAdrenalineProc then
            msg = msg .. COLOURS.FEATS.ADRENALINE .. "|nADRENALINE! You attack the same target a second time.|r "
        end

        if attack.hasEntropicEmbraceProc then
            msg = msg .. COLOURS.DAMAGE_TYPES.SHADOW .. "|nEntropic Embrace: You deal " .. attack.entropicEmbraceDmg .. " extra Shadow damage!"
        end
    else
        msg = msg .. COLOURS.NOTE .. "You can't deal any damage with this roll."
    end

    return msg
end

local function healingToString(healing)
    local msg = ""

    if healing.amountHealed > 0 then
        local amount = tostring(healing.amountHealed)
        local healColour = (healing.outOfCombat and character.hasFeat(FEATS.MEDIC)) and COLOURS.FEATS.GENERIC or COLOURS.HEALING

        if healing.isCrit then
            msg = msg .. COLOURS.CRITICAL .. "MANY HEALS!|r " .. healColour .. "You heal everyone in line of sight for " .. amount .. " HP."
        else
            if healing.usesParagon then
                local targets = healing.playersHealableWithParagon > 1 and " allies" or " ally"
                msg = msg .. healColour .. "You heal " .. healing.playersHealableWithParagon .. targets .. " for " .. amount .. " HP."
            else
                msg = msg .. healColour .. "You heal for " .. amount .. " HP."
            end
        end
    elseif not healing.canStillHeal then
        msg = COLOURS.ERROR .. "You must use Greater Heals if you want to perform more healing out of combat."
    else
        msg = COLOURS.NOTE .. "You can't heal anyone with this roll."
    end

    return msg
end

local function defenceToString(defence)
    if defence.damageTaken > 0 then
        return COLOURS.DAMAGE .. "You take " .. tostring(defence.damageTaken) .. " damage."
    else
        local msg
        if defence.damagePrevented > 0 then
            msg = COLOURS.ROLES.TANK .. "You prevent " .. defence.damagePrevented .. " damage."
        else
            msg = "Safe! You don't take damage this turn."
        end
        if defence.canRetaliate then
            msg = msg .. COLOURS.CRITICAL .. "\nRETALIATE!|r You can deal "..defence.retaliateDmg.." damage to your attacker!"
        end
        return msg
    end
end

local function meleeSaveToString(meleeSave)
    local msg = ""

    if meleeSave.isBigFail then
        msg = COLOURS.DAMAGE .. "Bad save! |r"
    end

    msg = msg .. "You save your ally"

    if character.hasDefenceMastery() then
        msg = msg .. "," .. COLOURS.ROLES.TANK .. " preventing " .. meleeSave.dmgRisk .. " damage,"
    end

    if meleeSave.damageTaken > 0 then
        msg = msg .. COLOURS.DAMAGE .. " but you take " .. meleeSave.damageTaken .. " damage.|r"
    else
        msg = msg .. " without taking any damage yourself."
    end

    if meleeSave.hasCounterForceProc then
        msg = msg .. COLOURS.FEATS.GENERIC .. "|nCOUNTER-FORCE!|r You can deal "..meleeSave.counterForceDmg.." damage to your attacker!"
    end

    return msg
end

-- Trait actions

local function ascendToString()
    return COLOURS.BUFF .. "You can apply your buff to a second target."
end

local function lifePulseToString()
    return COLOURS.HEALING .. "You can heal everyone in melee range of your target."
end

local function presenceOfVirtueToString()
    return COLOURS.HEALING .. "You may heal the target for 5 HP."
end

local function shieldSlamToString(shieldSlam)
    return "You deal " .. shieldSlam.dmg .. " damage with your Shield Slam."
end

local function vindicationToString()
    return COLOURS.HEALING .. "You may heal for the stated amount."
end

local toString = {
    [ACTIONS.attack] = attackToString,
    [ACTIONS.healing] = healingToString,
    [ACTIONS.defend] = defenceToString,
    [ACTIONS.meleeSave] = meleeSaveToString,
}

local traitsToString = {
    [TRAITS.ASCEND] = ascendToString,
    [TRAITS.LIFE_PULSE] = lifePulseToString,
    [TRAITS.PRESENCE_OF_VIRTUE] = presenceOfVirtueToString,
    [TRAITS.SHIELD_SLAM] = shieldSlamToString,
    [TRAITS.VINDICATION] = vindicationToString,
}

actions.toString = function(actionType, action)
    return toString[actionType](action)
end

actions.traitToString = function(trait, traitAction)
    return traitsToString[trait](traitAction)
end