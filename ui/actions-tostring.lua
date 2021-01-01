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

local function ascendToString()
    return COLOURS.BUFF .. " You apply your buff to a second target.|r"
end

local function empoweredBladesToString()
    return COLOURS.TRAITS.EMPOWERED_BLADES .. " Your warglaives absorb the energy of the attack!|r"
end

local function faultlineToString()
    return " You apply your attack to up to 3 additional targets."
end

local function lifePulseToString()
    return COLOURS.HEALING .. " You heal everyone in melee range of your target.|r"
end

local function presenceOfVirtueToString()
    return COLOURS.HEALING .. " You heal the target for 5 HP. They are also buffed for +5 on their next player turn.|r"
end

local function reapToString()
    return COLOURS.TRAITS.REAP .. " You damage all enemies in melee range of you or your target!|r"
end

local function shatterSoulToString()
    return COLOURS.TRAITS.SHATTER_SOUL .. " You shatter the enemy's soul!|r"
end

local function vindicationToString(vindication)
    return COLOURS.HEALING .. " You heal for " .. vindication.healingDone .. " HP.|r"
end

local traitActionToString = {
    [TRAITS.ASCEND.id] = ascendToString,
    [TRAITS.EMPOWERED_BLADES.id] = empoweredBladesToString,
    [TRAITS.FAULTLINE.id] = faultlineToString,
    [TRAITS.LIFE_PULSE.id] = lifePulseToString,
    [TRAITS.PRESENCE_OF_VIRTUE.id] = presenceOfVirtueToString,
    [TRAITS.REAP.id] = reapToString,
    [TRAITS.SHATTER_SOUL.id] = shatterSoulToString,
    [TRAITS.VINDICATION.id] = vindicationToString,
}

local function getTraitMessages(action)
    local msg = ""

    for traitID, traitAction in pairs(action.traits) do
        if traitAction.active then
            local trait = TRAITS[traitID]
            if trait.GetActionText then
                msg = msg .. trait:GetActionText(traitAction)
            else
                msg = msg .. traitActionToString[traitID](traitAction)
            end
        end
    end

    return msg
end

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
            msg = msg .. COLOURS.FEATS.ADRENALINE .. "|nADRENALINE! You attack the same target a second time!|r "
        end

        if attack.hasVengeanceProc then
            msg = msg .. COLOURS.FEATS.VENGEANCE .. " VENGEANCE!"
        end
    else
        msg = msg .. COLOURS.NOTE .. "You can't deal any damage with this roll."
    end

    if attack.amountHealed > 0 then
        msg = msg .. COLOURS.HEALING .. " You heal for " .. attack.amountHealed .. " HP.|r"
    end

    msg = msg .. getTraitMessages(attack)

    return msg
end

local function CCToString(cc)
    local msg

    if cc.isCrit then
        msg = COLOURS.CRITICAL .. "CRITICAL CC!|r You are guaranteed CC of at least 1 turn."
    else
        msg = "The result of your CC roll is " .. cc.ccValue .. "."
    end

    return msg
end

local function buffToString(buff)
    local msg

    if buff.amountBuffed > 0 then
        local amount = tostring(buff.amountBuffed)
        if buff.isCrit then
            msg = COLOURS.CRITICAL .. "BIG BUFF!|r " .. COLOURS.BUFF .. "You can buff everyone in line of sight for " .. amount .. "."
        else
            msg = COLOURS.BUFF .. "You can buff someone for " .. amount .. "."
        end

        if buff.usesInspiringPresence then
            msg = msg .. COLOURS.NOTE .. "|nYour buff is active in both the current player turn and the next enemy turn."
        end
    else
        msg = COLOURS.NOTE .. "You can't buff anyone with this roll."
    end

    msg = msg .. getTraitMessages(buff)

    return msg
end

local function healingToString(healing)
    local msg = ""

    if healing.amountHealed > 0 then
        local amount = tostring(healing.amountHealed)
        local healColour = (healing.outOfCombat and character.hasFeat(FEATS.MEDIC)) and COLOURS.FEATS.GENERIC or COLOURS.HEALING

        if healing.isCrit then
            msg = msg .. COLOURS.CRITICAL .. "MANY HEALS!|r " .. healColour .. "You heal everyone in line of sight for " .. amount .. " HP.|r"
        else
            if healing.usesParagon then
                local targets = healing.playersHealableWithParagon > 1 and " allies" or " ally"
                msg = msg .. healColour .. "You heal " .. healing.playersHealableWithParagon .. targets .. " for " .. amount .. " HP.|r"
            else
                msg = msg .. healColour .. "You heal for " .. amount .. " HP.|r"
            end
        end
    elseif not healing.canStillHeal then
        msg = COLOURS.ERROR .. "You must use Greater Heals if you want to perform more healing out of combat."
    else
        msg = COLOURS.NOTE .. "You can't heal anyone with this roll."
    end

    msg = msg .. getTraitMessages(healing)

    return msg
end

local function defenceToString(defence)
    local msg

    if defence.damageTaken > 0 then
        msg = COLOURS.DAMAGE .. "You take " .. tostring(defence.damageTaken) .. " damage."
    else
        if defence.damagePrevented > 0 then
            msg = COLOURS.ROLES.TANK .. "You prevent " .. defence.damagePrevented .. " damage."
        else
            msg = "Safe! You don't take damage this turn."
        end

        if defence.canRetaliate then
            msg = msg .. COLOURS.CRITICAL .. "\nRETALIATE!|r You can deal "..defence.retaliateDmg.." damage to your attacker!"
        end
    end

    msg = msg .. getTraitMessages(defence)

    return msg
end

local function meleeSaveToString(meleeSave)
    local msg = ""

    if meleeSave.isBigFail then
        msg = COLOURS.DAMAGE .. "Bad save! |r"
    end

    msg = msg .. "You save your ally"

    if character.hasDefenceProficiency() then
        msg = msg .. "," .. COLOURS.ROLES.TANK .. " preventing " .. meleeSave.damagePrevented .. " damage,"
    end

    if meleeSave.damageTaken > 0 then
        msg = msg .. COLOURS.DAMAGE .. " but you take " .. meleeSave.damageTaken .. " damage.|r"
    else
        msg = msg .. " without taking any damage yourself."
    end

    if meleeSave.hasCounterForceProc then
        msg = msg .. COLOURS.FEATS.GENERIC .. "|nCOUNTER-FORCE!|r You can deal "..meleeSave.counterForceDmg.." damage to your attacker!"
    end

    msg = msg .. getTraitMessages(meleeSave)

    return msg
end

local function rangedSaveToString(rangedSave)
    local msg

    if rangedSave.canFullyProtect then
        msg = COLOURS.ROLES.TANK .. "You can fully protect your ally."
    elseif rangedSave.damageReduction > 0 then
        msg = "You can reduce the damage your ally takes by " .. rangedSave.damageReduction .. ".|n" .. COLOURS.NOTE .. "However, you cannot act during the next player turn."
    else
        msg = COLOURS.NOTE .. "You can't reduce the damage your ally takes with this roll."
    end

    return msg
end

local function utilityToString(utility)
    return "Your total utility roll: " .. utility.utilityValue
end

-- Trait actions

local function holyBulwarkToString(holyBulwark)
    local msg

    if holyBulwark.damagePrevented > 0 then
        msg = COLOURS.ROLES.TANK .. "You prevent " .. holyBulwark.damagePrevented .. " damage. |r"
    else
        msg = "You block the attack. "
    end

    msg = msg .. "You retaliate for " .. holyBulwark.retaliateDmg .. " damage!"

    return msg
end

local function shieldSlamToString(shieldSlam)
    return "You deal " .. shieldSlam.dmg .. " damage with your Shield Slam."
end

local toString = {
    [ACTIONS.attack] = attackToString,
    [ACTIONS.cc] = CCToString,
    [ACTIONS.buff] = buffToString,
    [ACTIONS.healing] = healingToString,
    [ACTIONS.defend] = defenceToString,
    [ACTIONS.meleeSave] = meleeSaveToString,
    [ACTIONS.rangedSave] = rangedSaveToString,
    [ACTIONS.utility] = utilityToString,
}

local traitsToString = {
    [TRAITS.HOLY_BULWARK] = holyBulwarkToString,
    [TRAITS.SHIELD_SLAM] = shieldSlamToString,
}

actions.toString = function(actionType, action)
    return toString[actionType](action)
end

actions.traitToString = function(trait, traitAction)
    return traitsToString[trait](traitAction)
end