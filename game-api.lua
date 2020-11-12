local _, ns = ...

local gameAPI = ns.gameAPI

local function inGroupOrRaid()
    local inGroup = IsInGroup(LE_PARTY_CATEGORY_HOME)
    local inRaid = IsInRaid(LE_PARTY_CATEGORY_HOME)
    return inGroup, inRaid
end

gameAPI.inGroupOrRaid = inGroupOrRaid