MissionFilter = {}

-------------------------------------------------
-- OVERRIDE ADDMISSION
-------------------------------------------------

local function addMission(self, superFunc, mission)

    ContractorManager.assignContractor(mission)

    return superFunc(
        self,
        mission
    )

end

-------------------------------------------------
-- REGISTER
-------------------------------------------------

MissionManager.addMission =
    Utils.overwrittenFunction(
        MissionManager.addMission,
        addMission
    )