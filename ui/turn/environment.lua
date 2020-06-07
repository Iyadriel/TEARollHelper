local _, ns = ...

local enemies = ns.resources.enemies
local environment = ns.state.environment
local rules = ns.rules
local ui = ns.ui
local zones = ns.resources.zones

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
            zone = {
                order = 1,
                name = "Environment",
                type = "select",
                desc = "The environment you are fighting in",
                hidden = function()
                    return not rules.environment.shouldShowZoneSelect()
                end,
                values = (function()
                    local zoneOptions = {}
                    for i = 1, #zones.ZONE_KEYS do
                        local key = zones.ZONE_KEYS[i]
                        local zone = zones.ZONES[key]
                        zoneOptions[key] = zone.name
                    end
                    return zoneOptions
                end)(),
                get = state.zoneId.get,
                set = function(info, value)
                    state.zoneId.set(value)
                end
            },
            distanceFromEnemy = {
                order = 2,
                type = "select",
                name = "Distance from enemy",
                hidden = function()
                    return not rules.environment.shouldShowDistanceFromEnemy()
                end,
                values = {
                    melee = "Melee range",
                    ranged = "Ranged",
                },
                get = function()
                    return state.distanceFromEnemy.get()
                end,
                set = function(info, value)
                    state.distanceFromEnemy.set(value)
                end
            },
        }
    }
end