local _, ns = ...

local bus = ns.bus

local EVENTS = bus.EVENTS

function TEARollHelper:InitState()
    ns.state.character.initState()
    ns.state.environment.initState()
    ns.state.rolls.initState()
    ns.state.turn.initState()

    bus.fire(EVENTS.STATE_READY)
end