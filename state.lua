local _, ns = ...

function TEARollHelper:InitState()
    ns.state.character.initState()
    ns.state.environment.initState()
    ns.state.rolls.initState()
    ns.state.turn.initState()
end