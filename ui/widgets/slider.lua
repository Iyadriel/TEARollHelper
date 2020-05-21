--[[
    AceGUI's slider doesn't support callbacks for min and max values.
    This custom widget takes care of that.
]]

local AceGUI = LibStub("AceGUI-3.0")

local type, version = "TEACustomSlider", 1
local CALLBACKS = {}

local function onSliderShow(slider)
    local widget = slider.obj

    local table = widget:GetUserDataTable()
    local optionKey = table.path[#table.path]
    local option = widget:GetUserData("option")
    local callbacks = CALLBACKS[optionKey]

    if callbacks.max then
        option.max = callbacks.max()
    end

    widget:SetUserData("option", option)

    -- If the value exceeds the new max, adjust the value by calling the slider's set()
    callbacks.set(min(option.get(), option.max))
end

local function Constructor()
    local slider = AceGUI:Create("Slider")
    slider.type = type
    slider.slider:HookScript("OnShow", onSliderShow)

    return AceGUI:RegisterAsWidget(slider)
end

AceGUI:RegisterWidgetType(type, Constructor, version)

function TEARollHelper:CreateCustomSlider(key, callbacks)
    CALLBACKS[key] = callbacks
    return type
end