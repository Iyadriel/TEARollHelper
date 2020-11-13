local _, ns = ...

local enemies = ns.resources.enemies
local environment = ns.state.environment
local rules = ns.rules
local turnState = ns.state.turn
local ui = ns.ui
local zones = ns.resources.zones

local state = environment.state

--[[ local options = {
    order: Number
} ]]
ui.modules.environment.getOptions = function(options)
    return {
        order = options.order,
        type = "group",
        name = function()
            local zone = zones.ZONES[state.zoneId.get()]
            return ui.iconString(zone.icon) .. "Zone (" .. zone.colour .. zone.name .. "|r)"
        end,
        hidden = function()
            return not rules.environment.shouldShowEnvironment()
        end,
        args = {
            zone = {
                order = 0,
                name = "Zone",
                type = "select",
                desc = "The environment you are fighting in",
                width = 0.8,
                hidden = function()
                    return not rules.environment.shouldShowZoneSelect()
                end,
                values = (function()
                    local zoneOptions = {}
                    for i = 1, #zones.ZONE_KEYS do
                        local key = zones.ZONE_KEYS[i]
                        local zone = zones.ZONES[key]
                        zoneOptions[key] = ui.iconString(zone.icon) .. zone.name
                    end
                    return zoneOptions
                end)(),
                sorting = zones.ZONE_KEYS,
                get = state.zoneId.get,
                set = function(info, value)
                    state.zoneId.set(value)
                end
            },
            enemy = {
                order = 1,
                name = "Enemy",
                type = "select",
                desc = "The enemy you are fighting",
                width = 0.75,
                hidden = function()
                    return not turnState.state.inCombat.get() or not rules.environment.shouldShowEnemySelect()
                end,
                values = (function()
                    local enemyOptions = {}
                    for i = 1, #enemies.ENEMY_KEYS do
                        local key = enemies.ENEMY_KEYS[i]
                        local enemy = enemies.ENEMIES[key]
                        enemyOptions[key] = ui.iconString(enemy.icon) .. enemy.name
                    end
                    return enemyOptions
                end)(),
                get = state.enemyId.get,
                set = function(info, value)
                    state.enemyId.set(value)
                end
            },
            distanceFromEnemy = {
                order = 2,
                type = "select",
                name = "Distance from enemy",
                width = 0.7,
                hidden = function()
                    return not turnState.state.inCombat.get() or not rules.environment.shouldShowDistanceFromEnemy()
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