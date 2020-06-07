local _, ns = ...

local enemies = ns.resources.enemies
local environment = ns.state.environment
local rules = ns.rules
local ui = ns.ui

local state = environment.state

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.environment.getOptions = function(options)
    return {
        order = options.order,
        type = "group",
        name = "Environment",
        inline = true,
        hidden = function()
            return not rules.environment.shouldShowEnvironment()
        end,
        args = {
            enemy = {
                order = 0,
                name = "Enemy",
                type = "select",
                desc = "The enemy you are fighting",
                hidden = function()
                    return not rules.environment.shouldShowEnemySelect()
                end,
                values = (function()
                    local enemyOptions = {}
                    for i = 1, #enemies.ENEMY_KEYS do
                        local key = enemies.ENEMY_KEYS[i]
                        local enemy = enemies.ENEMIES[key]
                        enemyOptions[key] = enemy.name
                    end
                    return enemyOptions
                end)(),
                get = state.enemyId.get,
                set = function(info, value)
                    state.enemyId.set(value)
                end
            },
        }
    }
end