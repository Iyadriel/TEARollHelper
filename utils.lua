local _, ns = ...

local integrations = ns.integrations
local utils = ns.utils

local function merge(t1, t2, t3)
    local t4 = {}
    for k, v in pairs(t1) do
        t4[k] = v
    end
    for k, v in pairs(t2) do
        t4[k] = v
    end
    if t3 then
        for k, v in pairs(t3) do
            t4[k] = v
        end
    end
    return t4
end

local function colorsAndPercent(a, b, ...)
	if(a <= 0 or b == 0) then
		return nil, ...
	elseif(a >= b) then
		return nil, select(-3, ...)
	end

	local num = select('#', ...) / 3
	local segment, relperc = math.modf((a / b) * (num - 1))
	return relperc, select((segment * 3) + 1, ...)
end

local function RGBColorGradient(...)
	local relperc, r1, g1, b1, r2, g2, b2 = colorsAndPercent(...)
	if(relperc) then
		return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
	else
		return r1, g1, b1
	end
end

local function RGBPercToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

local function healthColor(currentHP, maxHP)
    return "|cff" .. RGBPercToHex(RGBColorGradient(currentHP, maxHP, 1, 0, 0, 0, 1, 0))
end

local function formatHealth(currentHealth, maxHealth)
	local out = {
        currentHealth,
        "/",
        maxHealth,
        " HP",
    }

    return table.concat(out)
end

local function formatPlayerName(playerName)
    local fancyName
    if integrations.TRP then
        fancyName = integrations.TRP.getRPNameAndColor(playerName)
    end
    return fancyName or playerName
end

utils.merge = merge
utils.healthColor = healthColor
utils.formatHealth = formatHealth
utils.formatPlayerName = formatPlayerName