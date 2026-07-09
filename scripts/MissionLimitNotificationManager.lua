MissionLimitNotificationManager = {}

-------------------------------------------------
-- DATA
-------------------------------------------------

MissionLimitNotificationManager.visible = false
MissionLimitNotificationManager.endTime = 0
MissionLimitNotificationManager.box = nil

-------------------------------------------------
-- CREATE BOX
-------------------------------------------------

function MissionLimitNotificationManager.createBox()

    if g_currentMission == nil then
        return
    end

    local infoDisplay =
        g_currentMission.hud.infoDisplay

    MissionLimitNotificationManager.box =
        infoDisplay:createBox(
            InfoDisplayKeyValueBox
        )

    MissionLimitNotificationManager.box.canDraw =
        function()

            return MissionLimitNotificationManager.visible

        end

end

-------------------------------------------------
-- GET NEXT RANK
-------------------------------------------------

local function getNextRank()

    local currentRep =
        ReputationManager.get()

    for _, rank in ipairs(
        ReputationManager.ranks
    ) do

        if rank.min > currentRep then

            return rank

        end

    end

    return nil

end

-------------------------------------------------
-- SHOW
-------------------------------------------------

function MissionLimitNotificationManager.show(
    activeMissions,
    missionLimit
)

	FRDebug.log("INSIDE SHOW")
	
    local currentRank =
        ReputationManager.getRankData()

    local nextRank =
        getNextRank()

    local currentRep =
        ReputationManager.get()

    local text =
		g_i18n:getText("fr_maxActiveContractsReached")
		.. "\n\n"

		.. g_i18n:getText("fr_activeContracts")
		.. ":\n"
		.. tostring(activeMissions)
		.. " / "
		.. tostring(missionLimit)

		.. "\n\n"

		.. g_i18n:getText("fr_currentRank")
		.. ":\n"
		.. currentRank.title

    if nextRank ~= nil then

        local missingRep =
            nextRank.min - currentRep

        text =
			text
			.. "\n\n"
			.. g_i18n:getText("fr_nextRank")
			.. ":\n"
			.. nextRank.title

			.. "\n\n"
			.. g_i18n:getText("fr_missing")
			.. ":\n"
			.. tostring(missingRep)
			.. " "
			.. g_i18n:getText("fr_rep")

    end
	
	FRDebug.log("BEFORE INFODIALOG")
	
    InfoDialog.show(
		g_i18n:getText("fr_contractLocked")
		.. "\n\n"
		.. text
	)

end

-------------------------------------------------
-- UPDATE
-------------------------------------------------

function MissionLimitNotificationManager.update()

    if not MissionLimitNotificationManager.visible then
        return
    end

    if g_time >=
        MissionLimitNotificationManager.endTime then

        MissionLimitNotificationManager.visible = false

    end

end

-------------------------------------------------
-- REGISTER
-------------------------------------------------

FSBaseMission.update =
    Utils.appendedFunction(
        FSBaseMission.update,
        MissionLimitNotificationManager.update
    )

FSBaseMission.onStartMission =
    Utils.appendedFunction(
        FSBaseMission.onStartMission,
        function()

            MissionLimitNotificationManager.createBox()

        end
    )
