local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local feats = ns.resources.feats
local rolls = ns.state.rolls
local rules = ns.rules
local ui = ns.ui

local FEATS = feats.FEATS
local state = rolls.state

--[[ local options = {
    order: Number
} ]]
ui.modules.rolls.modules.attack.getOptions = function(options)
    return {
        name = "Attack",
        type = "group",
        inline = true,
        order = options.order,
        args = {
            attackThreshold = {
                name = "Attack threshold",
                type = "range",
                desc = "The minimum required roll to hit the target",
                min = 1,
                softMax = 20,
                max = 100,
                step = 1,
                order = 0,
                get = function()
                    return state.attack.threshold
                end,
                set = function(info, value)
                    state.attack.threshold = value
                end
            },
            bloodHarvest = {
                name = COLOURS.FEATS.BLOOD_HARVEST .. FEATS.BLOOD_HARVEST.name,
                type = "select",
                desc = "The amount of Blood Harvest slots to use.",
                order = 1,
                values = function()
                    local values = {}
                    for i = 0, rules.offence.getMaxBloodHarvestSlots() do
                        values[i] = tostring(i)
                    end
                    return values
                end,
                hidden = function()
                    return not rules.offence.canUseBloodHarvest()
                end,
                disabled = function()
                    return rules.offence.getMaxBloodHarvestSlots() == 0
                end,
                get = function()
                    return state.attack.numBloodHarvestSlots
                end,
                set = function(info, value)
                    state.attack.numBloodHarvestSlots = value
                end
            },
            dmg = {
                type = "description",
                desc = "How much damage you can deal to a target",
                fontSize = "medium",
                order = 3,
                name = function()
                    local attack = rolls.getAttack()
                    local msg = " |n"
                    local excited = false

                    if attack.dmg > 0 then
                        if attack.isCrit and attack.critType == rules.offence.CRIT_TYPES.DAMAGE then
                            excited = true
                            msg = msg .. COLOURS.CRITICAL .. "CRITICAL HIT!|r "
                        end

                        if attack.hasAdrenalineProc then
                            msg = msg .. COLOURS.FEATS.ADRENALINE .. "ADRENALINE!|r "
                        end

                        if attack.isCrit and attack.critType == rules.offence.CRIT_TYPES.REAPER then
                            msg = msg .. COLOURS.FEATS.REAPER .. "TIME TO REAP!|r You can deal " .. tostring(attack.dmg) .. " damage to all enemies in melee range of you or your target!"
                        else
                            msg = msg .. "You can deal " .. tostring(attack.dmg) .. " damage" .. (excited and "!" or ".")
                        end

                        if attack.hasEntropicEmbraceProc then
                            msg = msg .. COLOURS.DAMAGE_TYPES.SHADOW .. "|nEntropic Embrace: You deal " .. attack.entropicEmbraceDmg .. " extra Shadow damage!"
                        end

                        if attack.hasMercyFromPainProc then
                            local healingSingleTargetHit = rules.offence.calculateMercyFromPainBonusHealing(false)
                            local healingMultipleEnemiesHit = rules.offence.calculateMercyFromPainBonusHealing(true)
                            msg = msg .. COLOURS.FEATS.MERCY_FROM_PAIN .."|nMercy from Pain: +" .. healingSingleTargetHit .. " HP on your next heal roll (+" .. healingMultipleEnemiesHit .. "HP if AoE)"
                        end
                    else
                        msg = msg .. COLOURS.NOTE .. "You can't deal any damage with this roll."
                    end

                    return msg
                end
            },
        }
    }
end