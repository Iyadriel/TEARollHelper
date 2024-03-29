local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local CRIT_TYPES = constants.CRIT_TYPES
local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local function ascendToString()
    return COLOURS.BUFF .. " You apply your buff to a second target.|r"
end

local function faultlineToString()
    return " You apply your attack to up to 2 additional targets."
end

local function lifePulseToString()
    return COLOURS.HEALING .. " You heal everyone in your line of sight!|r"
end

local function presenceOfVirtueToString()
    return COLOURS.HEALING .. " You heal the target for 5 HP. They are also buffed for +5 on their next player turn.|r"
end

local function reapToString()
    return COLOURS.TRAITS.REAP .. " You damage all enemies in melee range of you or your target!|r"
end

local function vindicationToString(vindication)
    return COLOURS.HEALING .. " You heal for " .. vindication.healingDone .. " HP.|r"
end

local traitActionToString = {
    [TRAITS.ASCEND.id] = ascendToString,
    [TRAITS.FAULTLINE.id] = faultlineToString,
    [TRAITS.LIFE_PULSE.id] = lifePulseToString,
    [TRAITS.PRESENCE_OF_VIRTUE.id] = presenceOfVirtueToString,
    [TRAITS.REAP.id] = reapToString,
    [TRAITS.VINDICATION.id] = vindicationToString,
}

local function getTraitMessages(action)
    local msg = ""

    if action.traits then
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
    end

    return msg
end

local function attackToString(attack)
    local damage = attack.actions.damage
    local msg = ""

    if damage.dmg > 0 then
        if damage.isCrit then
            if damage.critType == CRIT_TYPES.VALUE_MOD then
                msg = msg .. COLOURS.CRITICAL .. "CRITICAL HIT!|r You deal " .. tostring(damage.dmg) .. " damage!"
            else
                msg = msg .. COLOURS.CRITICAL .. "BIG DAMAGE!|r You deal " .. tostring(damage.dmg) .. " damage to all enemies in melee range of you or your target!"
            end
        else
            msg = msg .. "You deal " .. tostring(damage.dmg) .. " damage."
        end

        if attack.hasAdrenalineProc then
            msg = msg .. COLOURS.FEATS.ADRENALINE .. "|nADRENALINE! You damage the same target a second time!|r "
        end

        if damage.hasVengeanceProc then
            msg = msg .. COLOURS.FEATS.VENGEANCE .. " VENGEANCE!"
        end
    else
        msg = msg .. COLOURS.NOTE .. "You can't deal any damage with this roll."
    end

    if damage.amountHealed > 0 then
        msg = msg .. COLOURS.HEALING .. " You heal for " .. damage.amountHealed .. " HP.|r"
    end

    msg = msg .. getTraitMessages(damage)

    return msg
end

local function CCToString(cc)
    local msg

    if cc.isCrit then
        msg = COLOURS.CRITICAL .. "CRITICAL CC!|r You are guaranteed CC of at least 1 turn."
    else
        msg = "The result of your CC roll is " .. cc.ccValue .. "."
    end

    msg = msg .. getTraitMessages(cc)

    return msg
end

local function buffToString(buff)
    local msg

    if buff.amountBuffed > 0 then
        if buff.isCrit then
            if buff.critType == CRIT_TYPES.VALUE_MOD then
                msg = COLOURS.CRITICAL .. "BIG BUFF!|r " .. COLOURS.BUFF .. "You buff 1 person's roll by " .. buff.amountBuffed .. " (" .. buff.amountBuffedForDamage .. " if buffing damage)!"
            else
                msg = COLOURS.CRITICAL .. "MANY BUFFS!|r " .. COLOURS.BUFF .. "You buff 3 people's 's rolls by " .. buff.amountBuffed .. " (" .. buff.amountBuffedForDamage .. " if buffing damage)!"
            end
        else
            msg = COLOURS.BUFF .. "You buff someone's roll by " .. buff.amountBuffed .. " (" .. buff.amountBuffedForDamage .. " if buffing damage)."
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
            if healing.critType == CRIT_TYPES.VALUE_MOD then
                msg = COLOURS.CRITICAL .. "BIG HEAL!|r " .. healColour .. "You heal 1 person for " .. amount .. " HP!"
            else
                msg = COLOURS.CRITICAL .. "MANY HEALS!|r " .. healColour .. "You heal 3 people for " .. amount .. " HP!"
            end
        else
            if healing.usesParagon then
                local targets = healing.playersHealableWithParagon > 1 and " allies" or " ally"
                msg = msg .. healColour .. "You heal " .. healing.playersHealableWithParagon .. targets .. " for " .. amount .. " HP.|r"
            else
                msg = msg .. healColour .. "You heal for " .. amount .. " HP.|r"
            end
        end

        if healing.hasLifeSentinelProc then
            msg = msg .. COLOURS.FEATS.GENERIC .. " You also heal your blessed player for " .. amount .. " HP.|r"
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
        msg = COLOURS.DAMAGE .. "You take " .. tostring(defence.damageTaken) .. " damage.|r"
    else
        if defence.damagePrevented > 0 then
            msg = COLOURS.ROLES.TANK .. "You prevent " .. defence.damagePrevented .. " damage.|r"
        else
            msg = "Safe! You don't take damage this turn.|r"
        end
    end

    if defence.isCrit then
        if defence.critType == CRIT_TYPES.RETALIATE then
            msg = msg .. COLOURS.CRITICAL .. "\nRETALIATE!|r You deal "..defence.retaliateDmg.." damage to your attacker!"
        else
            msg = msg .. COLOURS.CRITICAL .. "\nPROTECTOR!|r You activate Protector at no cost!"
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

    if meleeSave.damagePrevented > 0 then
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
