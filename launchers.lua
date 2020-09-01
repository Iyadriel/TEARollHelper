local _, ns = ...

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

local bus = ns.bus
local characterState = ns.state.character
local launchers = ns.launchers
local ui = ns.ui

local EVENTS = bus.EVENTS
local LDB_NAME = ui.constants.FRIENDLY_ADDON_NAME

local function toggleDialog(name)
    if AceConfigDialog.OpenFrames[name] then
        AceConfigDialog:Close(name)
    else
        AceConfigDialog:Open(name)
    end
end

local dataObject = ldb:NewDataObject(LDB_NAME, {
    type = "data source",
    icon = "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
    OnClick = function(_, button)
        if button == "LeftButton" then
            toggleDialog(ui.modules.turn.name)
        elseif button == "RightButton" then
            toggleDialog(ui.modules.config.name)
        elseif button == "MiddleButton" then
            toggleDialog(ui.modules.turn.name)
        end
    end
})

function dataObject:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(LDB_NAME, 1, 1, 1)
	GameTooltip:AddLine("")
	GameTooltip:AddLine("Left click: Show turn window")
	GameTooltip:AddLine("Right click: Show config UI")
	GameTooltip:Show()
end

function dataObject:OnLeave()
	GameTooltip:Hide()
end

launchers.initLaunchers = function()
    icon:Register(LDB_NAME, dataObject, TEARollHelper.db.global.settings.minimapIcon)
end

launchers.setMinimapIconShown = function(shown)
    if shown then
        icon:Show(LDB_NAME)
    else
        icon:Hide(LDB_NAME)
    end
end

local function updateDisplay()
    dataObject.text = characterState.summariseHP()
end

bus.addListener(EVENTS.CHARACTER_HEALTH, updateDisplay)
bus.addListener(EVENTS.CHARACTER_MAX_HEALTH, updateDisplay)
bus.addListener(EVENTS.STATE_READY, updateDisplay)