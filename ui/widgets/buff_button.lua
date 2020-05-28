local AceGUI = LibStub("AceGUI-3.0")
local type, version = "TEABuffButton", 1

local function Constructor()
    local button = AceGUI:Create("Icon")
    button.type = type

    button.frame:RegisterForClicks("RightButtonUp")

    return AceGUI:RegisterAsWidget(button)
end

AceGUI:RegisterWidgetType(type, Constructor, version)