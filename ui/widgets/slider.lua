--[[
    AceGUI's slider doesn't support callbacks for min and max values.
    This custom widget takes care of that.
]]

local AceGUI = LibStub("AceGUI-3.0")

local type, version = "TEACustomSlider", 1
local CALLBACKS = {}

local function setSliderValues(widget)
    if not widget.tea_optionKey then return end -- Ace will call SetSliderValues before SetParent, at which point we don't have the optionKey yet./

    local callbacks = CALLBACKS[widget.tea_optionKey]
    local option = callbacks.option

    if callbacks.min then
        option.min = callbacks.min()
    end

    if callbacks.max then
        option.max = callbacks.max()
    end

    callbacks.option = option
    widget:SetUserData("option", option)
end

local function onSetParent(frame)
    local widget = frame.obj

    local table = widget:GetUserDataTable()
    if table.path then
        local optionKey = table.path[#table.path]
        -- Store the option's key so we can use it in setSliderValues. Ace wipes the UserData when it's done with it, so we have to grab it while we can.
        -- Why hook SetParent? Because it's the only way to actually access this data that worked reliably.
        widget.tea_optionKey = optionKey

        local callbacks = CALLBACKS[widget.tea_optionKey]
        local option = widget:GetUserData("option")

        callbacks.option = option -- Same story as for tea_optionKey, make sure we can reference this in setSliderValues.

        -- Update the values. Ace calls SetParent after SetSliderValues, which means we'll have the wrong values on the slider's first show unless we do this.
        local min, max, step = option.softMin or option.min or 0, option.softMax or option.max or 100, option.bigStep or option.step or 0
        widget:SetSliderValues(min, max, step)

        local value = option.get()
        if value then
            widget:SetValue(value)
        end
    end
end

local function Constructor()
    local slider = AceGUI:Create("Slider")
    slider.type = type

    local oldSetSliderValues = slider.SetSliderValues
    slider.SetSliderValues = function(self, ...)
        setSliderValues(self)
        oldSetSliderValues(self, ...)
    end

    hooksecurefunc(slider.frame, "SetParent", onSetParent)

    return AceGUI:RegisterAsWidget(slider)
end

AceGUI:RegisterWidgetType(type, Constructor, version)

function TEARollHelper:CreateCustomSlider(key, callbacks)
    CALLBACKS[key] = callbacks
    return type
end
