local _, ns = ...

local constants = ns.constants
local models = ns.models

local ACTION_LABELS = constants.ACTION_LABELS

local BuffEffect = models.BuffEffect
local BuffEffectAdvantage = BuffEffect:NewFromObj({})

function BuffEffectAdvantage:New(actions, turnTypeID)
    local buff = BuffEffect:NewFromObj({
        actions = actions,
        turnTypeID = turnTypeID
    })

    setmetatable(buff, self)
    self.__index = self

    return buff
end

function BuffEffectAdvantage:GetTooltipText()
    local msg = "Your rolls have advantage.|nApplies to: "

    for action in pairs(self.actions) do
        msg = msg ..  ACTION_LABELS[action] .. ", "
    end

    msg = string.sub(msg, 0, -3)

    return msg
end

models.BuffEffectAdvantage = BuffEffectAdvantage