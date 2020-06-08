local _, ns = ...

local settings = ns.settings

local function basicGetSet(key)
    return {
        get = function ()
            return TEARollHelper.db.global.settings[key]
        end,
        set = function (value)
            TEARollHelper.db.global.settings[key] = value
        end
    }
end

for _, setting in ipairs({
    "debug",
    --"minimapIcon", -- managed by ldb
    "autoUpdateTRP"
}) do
    settings[setting] = basicGetSet(setting)
end