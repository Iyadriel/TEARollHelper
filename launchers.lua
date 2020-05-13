local _, ns = ...

local launchers = ns.launchers

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

local LDB_NAME = "TEA Roll Helper"

local dataObject = ldb:NewDataObject(LDB_NAME, {
    type = "launcher",
    icon = "Interface\\Icons\\inv_misc_dice_02",
    OnClick = function(_, button)
        if button == "LeftButton" then
            if AceConfigDialog.OpenFrames.TEARollHelperRolls then
                AceConfigDialog:Close("TEARollHelperRolls")
            else
                AceConfigDialog:Open("TEARollHelperRolls")
            end
        elseif button == "RightButton" then
            if AceConfigDialog.OpenFrames.TEARollHelper then
                AceConfigDialog:Close("TEARollHelper")
            else
                AceConfigDialog:Open("TEARollHelper")
            end
        end
    end
})

function dataObject:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(LDB_NAME, 1, 1, 1)
	GameTooltip:AddLine("")
	GameTooltip:AddLine("Left click: Show roll window")
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