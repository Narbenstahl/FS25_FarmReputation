MissionDetailsExtension = {}

-------------------------------------------------
-- ADD REPUTATION DETAILS TO MISSION DETAILS
-------------------------------------------------

local function getDetails(self, superFunc)

    local details = superFunc(self)

    local reward = ContractEvaluator.getRepReward(self)

    table.insert(details, {
        title = g_i18n:getText("fr_reputationReward"),
        value = "+" .. tostring(reward)
    })

    table.insert(details, {
        title = g_i18n:getText("fr_reputationPenalty"),
        value = "-5"
    })

    return details

end

-------------------------------------------------
-- REGISTER
-------------------------------------------------

AbstractMission.getDetails =
    Utils.overwrittenFunction(
        AbstractMission.getDetails,
        getDetails
    )