MultiplayerManager = {}

-------------------------------------------------
-- DEBUG
-------------------------------------------------

local function frPrint(text)

    FRDebug.log(text)

end

-------------------------------------------------
-- COUNT ACTIVE MISSIONS
-------------------------------------------------

local function getActiveMissionCount(farmId)

    local count = 0

    for _, mission in ipairs(g_missionManager.missions) do

        if mission.farmId == farmId then

            local missionType = "unknown"

            if mission.type ~= nil then
                missionType = tostring(mission.type.name)
            end

            frPrint(
                "ACTIVE MISSION"
                .. " | TYPE: "
                .. missionType
            )

            count = count + 1

        end

    end

    frPrint(
        "TOTAL ACTIVE MISSIONS"
        .. " | COUNT: "
        .. tostring(count)
    )

    return count

end

-------------------------------------------------
-- MISSION LIMIT
-------------------------------------------------

	local function hasFarmReachedMissionLimit(
    self,
    superFunc,
    farmId
)

    local limit =
        ReputationManager.getMissionLimit()

    local activeMissions =
        getActiveMissionCount(farmId)

    frPrint(
        "MISSION LIMIT CHECK"
        .. " | ACTIVE: "
        .. tostring(activeMissions)
        .. " | LIMIT: "
        .. tostring(limit)
    )

   if activeMissions >= limit then

    frPrint("FR LIMIT REACHED")
	frPrint("RETURNING FALSE")
    return false

	end					
    
	frPrint("RETURNING FALSE")
	
	return false

end
-------------------------------------------------
-- REGISTER
-------------------------------------------------

MissionManager.hasFarmReachedMissionLimit =
    Utils.overwrittenFunction(
        MissionManager.hasFarmReachedMissionLimit,
        hasFarmReachedMissionLimit
    )

frPrint("MultiplayerManager LOADED")