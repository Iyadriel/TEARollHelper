local _, ns = ...

function TEARollHelper:InitState()
    ns.state.character.initState()
    ns.state.turn.initState()
end