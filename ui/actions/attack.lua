local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local characterState = ns.state.character.state
local feats = ns.resources.feats
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui

local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local state = rolls.state

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.attack.getOptions = function(options)
    return {
        name = "Attack",
        type = "group",
        order = options.order,
        args = {
            attackThreshold = {
                order = 0,
                name = "Attack threshold",
                type = "range",
                desc = "The minimum required roll to hit the target",
                min = 1,
                softMax = 20,
                max = 100,
                step = 1,
                get = state.attack.threshold.get,
                set = function(info, value)
                    state.attack.threshold.set(value)
                end
            },
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 1,
                action = "attack",
                includePrep = true,
            }),
            attack = {
                order = 2,
                type = "group",
                name = "Attack",
                inline = true,
                hidden = function()
                    return not state.attack.currentRoll.get()
                end,
                args = {
                    actions_attack_bloodHarvest = {
                        order = 2,
                        type = "range",
                        name = COLOURS.FEATS.BLOOD_HARVEST .. FEATS.BLOOD_HARVEST.name,
                        desc = "The amount of Blood Harvest slots to use.",
                        min = 0,
                        max = characterState.featsAndTraits.numBloodHarvestSlots.get(),
                        step = 1,
                        hidden = function()
                            return not rules.offence.canUseBloodHarvest()
                        end,
                        disabled = function()
                            return rules.offence.getMaxBloodHarvestSlots() == 0 or characterState.featsAndTraits.numBloodHarvestSlots.get() == 0
                        end,
                        get = state.attack.numBloodHarvestSlots.get,
                        set = function(info, value)
                            state.attack.numBloodHarvestSlots.set(value)
                        end,
                        dialogControl = TEARollHelper:CreateCustomSlider("actions_attack_bloodHarvest", {
                            max = characterState.featsAndTraits.numBloodHarvestSlots.get
                        })
                    },
                    dmg = {
                        order = 3,
                        type = "description",
                        desc = "How much damage you can deal to a target",
                        fontSize = "medium",
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

                                if attack.hasVindicationProc then
                                    msg = msg .. COLOURS.HEALING .. "|n" .. TRAITS.VINDICATION.name .. ": You can heal for " .. attack.vindicationHealing .. " HP!|r"
                                end
                            else
                                msg = msg .. COLOURS.NOTE .. "You can't deal any damage with this roll."
                            end

                            return msg
                        end
                    },
                }
            },
        }
    }
end