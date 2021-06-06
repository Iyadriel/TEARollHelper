local _, ns = ...

local launchers = ns.launchers
local settings = ns.settings
local ui = ns.ui

ui.modules.config.modules.settings.getOptions = function()
    return {
        name = "Settings",
        type = "group",
        order = 2,
        cmdHidden = true,
        args = {
            gameplay = {
                order = 0,
                type = "group",
                name = "Gameplay",
                inline = true,
                args = {
                    suggestFatePoints = {
                        order = 0,
                        type = "toggle",
                        name = "Suggest Fate Points",
                        desc = "Offer to use a Fate Point on a bad roll",
                        get = settings.suggestFatePoints.get,
                        set = function(info, value)
                            settings.suggestFatePoints.set(value)
                        end,
                    }
                }
            },
            addon = {
                order = 1,
                type = "group",
                name = "Addon",
                inline = true,
                args = {
                    autoUpdateTRP = {
                        order = 0,
                        type = "toggle",
                        name = "Auto update Total RP profile",
                        desc = "When your character's state changes (e.g. when you lose HP), update your Total RP automatically.",
                        width = "full",
                        get = settings.autoUpdateTRP.get,
                        set = function(info, value)
                            settings.autoUpdateTRP.set(value)
                            if value then
                                TEARollHelper.db.global.warningsSeen.updateTRP = true
                            end
                        end,
                        confirm = function()
                            local global = TEARollHelper.db.global
                            if not settings.autoUpdateTRP.get() and not global.warningsSeen.updateTRP then
                                return "This will allow this addon to overwrite any content you have set in your 'Currently' field."
                            end
                            return false
                        end
                    },
                    showCustomFeatsTraits = {
                        order = 1,
                        type = "toggle",
                        name = "Show custom Feats and Traits",
                        desc = "Allows you to select supported custom Feats and Traits.",
                        width = "full",
                        get = settings.showCustomFeatsTraits.get,
                        set = function(info, value)
                            settings.showCustomFeatsTraits.set(value)
                        end,
                    },
                    minimapIcon = {
                        order = 2,
                        type = "toggle",
                        name = "Minimap icon",
                        desc = "If disabled, you can still use the /tea slash command to access the addon.",
                        width = "full",
                        get = function()
                            return not TEARollHelper.db.global.settings.minimapIcon.hide
                        end,
                        set = function(info, shown)
                            TEARollHelper.db.global.settings.minimapIcon.hide = not shown
                            launchers.setMinimapIconShown(shown)
                        end
                    },
                }
            },
            advanced = {
                order = 2,
                type = "group",
                name = "Advanced",
                inline = true,
                args = {
                    debugMode = {
                        order = 0,
                        type = "toggle",
                        name = "Debug mode",
                        desc = "Don't touch this! I said don't.",
                        width = "full",
                        get = settings.debug.get,
                        set = function(info, value)
                            settings.debug.set(value)
                        end,
                    },
                }
            }
        }
    }
end
