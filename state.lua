local _, ns = ...

ns.state.character = {}
ns.state.rolls = {}
ns.state.turn = {}

function TEARollHelper:InitState()
    ns.state.character.initState()
    ns.state.turn.initState()
end