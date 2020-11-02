local _, ns = ...

local bus = ns.bus

local EVENTS = bus.EVENTS

function TEARollHelper:InitState()
    for _, module in pairs(ns.state) do
        module.initState()
    end

    bus.fire(EVENTS.STATE_READY)
end