local _, ns = ...

local bus = ns.bus
local enemies = ns.resources.enemies
local environment = ns.state.environment
local rules = ns.rules
local ui = ns.ui
local zones = ns.resources.zones

local EVENTS = bus.EVENTS
local state = environment.state

local MARKER_LIST = (function()
    local list = {}
    for i, markerString in ipairs(ICON_LIST) do
        list[i] = markerString .. "0|t"
    end
    return list
end)()

local newUnit = {
    unitIndex = 1,
    name = ""
}

--[[ local options = {
    order: Number
} ]]
ui.modules.environment.getOptions = function(options)
    return {
        order = options.order,
        type = "group",
        name = function()
            local zone = zones.ZONES[state.zoneId.get()]
            return ui.iconString(zone.icon) .. "Environment"
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
                        enemyOptions[key] = ui.iconString(enemy.icon) .. enemy.name
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
            units = {
                order = 3,
                type = "group",
                name = "Units",
                inline = true,
                args = (function()
                    local units = {
                        unitIndex = {
                            order = 0,
                            type = "select",
                            width = 0.5,
                            name = "Marker",
                            values = function()
                                local values = {}

                                for unitIndex, marker in ipairs(MARKER_LIST) do
                                    if not state.units.get(unitIndex) then
                                        values[unitIndex] = marker
                                    end
                                end

                                return values
                            end,
                            get = function()
                                return newUnit.unitIndex
                            end,
                            set = function(info, value)
                                newUnit.unitIndex = value
                            end,
                        },
                        name = {
                            order = 1,
                            type = "input",
                            name = "Name",
                            width = 0.9,
                            get = function()
                                return newUnit.name
                            end,
                            set = function(info, value)
                                newUnit.name = value
                            end,
                        },
                        add = {
                            order = 2,
                            type = "execute",
                            width = 0.7,
                            name = "Add",
                            disabled = function()
                                return newUnit.unitIndex == nil or newUnit.name:trim() == "" or state.units.get(newUnit.unitIndex)
                            end,
                            func = function()
                                state.units.add(newUnit.unitIndex, newUnit.name, true)

                                if newUnit.unitIndex < #ICON_LIST then
                                    newUnit.unitIndex = newUnit.unitIndex + 1
                                end

                                newUnit.name = ""
                            end,
                        },
                        divider = {
                            order = 3,
                            type = "header",
                            name = "",
                            hidden = function()
                                return state.units.count() == 0
                            end
                        }
                    }

                    local order = 4

                    for unitIndex = 1, #MARKER_LIST do
                        units["unit" .. unitIndex .. "name"] = {
                            order = order,
                            type = "input",
                            name = MARKER_LIST[unitIndex],
                            width = 1.5,
                            hidden = function()
                                return not state.units.get(unitIndex)
                            end,
                            get = function()
                                return state.units.get(unitIndex):GetName()
                            end,
                            set = function(info, value)
                                state.units.update(unitIndex, value, true)
                            end,
                        }

                        order = order + 1

                        units["unit" .. unitIndex .. "remove"] = {
                            order = order,
                            type = "execute",
                            name = "Clear",
                            width = 0.6,
                            hidden = function()
                                return not state.units.get(unitIndex)
                            end,
                            func = function()
                                state.units.remove(unitIndex, true)
                            end,
                        }

                        order = order + 1

                        units.broadcast = {
                            order = order,
                            type = "execute",
                            name = "Announce",
                            width = "full",
                            hidden = function()
                                return state.units.count() == 0
                            end,
                            func = function()
                                bus.fire(EVENTS.COMMS_BROADCAST_UNIT_LIST, state.units.list())
                            end,
                        }
                    end

                    return units
                end)(),
            },
        }
    }
end