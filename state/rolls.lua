local _, ns = ...

local actions = ns.actions
local character = ns.character
local rolls = ns.state.rolls
local turns = ns.turns

-- TODO: we don't actually need to hold any state, need to rename this module.
-- It's just a way to calculate our actions without having to repeat code across different parts of the UI.

local function getDefence()
    local defence = character.getPlayerDefence()
    local buff = turns.getCurrentBuffs().defence
    local values = turns.getCurrentTurnValues()
    local racialTrait = turns.getRacialTrait()
    local defence = actions.getDefence(values.roll, values.defendThreshold, values.damageRisk, defence, buff, racialTrait)

    return defence
end

rolls.getDefence = getDefence