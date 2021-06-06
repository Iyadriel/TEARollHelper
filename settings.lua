local _, ns = ...

local settings = ns.settings
local ui = ns.ui

local function basicGetSet(key, callback)
    return {
        get = function ()
            return TEARollHelper.db.global.settings[key]
        end,
        set = function (value)
            TEARollHelper.db.global.settings[key] = value
            if callback then callback(value) end
        end
    }
end

local function updateTurnUI()
    ui.update(ui.modules.turn.name)
end

for _, setting in ipairs({
    "autoUpdateTRP",
    "debug",
    --"minimapIcon", -- managed by ldb
    "showCustomFeatsTraits",
    "suggestFatePoints",
}) do
    settings[setting] = basicGetSet(setting, updateTurnUI)
end
