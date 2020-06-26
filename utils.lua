local _, ns = ...

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

utils.merge = merge