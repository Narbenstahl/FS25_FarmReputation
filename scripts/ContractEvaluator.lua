ContractEvaluator = {}

-------------------------------------------------
-- REP MULTIPLIERS
-------------------------------------------------

ContractEvaluator.repMultipliers = {

    -------------------------------------------------
    -- TOP TIER
    -------------------------------------------------

    harvestMission = 10,
    sowMission = 8,

    -------------------------------------------------
    -- HIGH
    -------------------------------------------------

    cultivateMission = 7,
    plowMission = 7,
    fertilizeMission = 6,

    -------------------------------------------------
    -- MEDIUM
    -------------------------------------------------

    weedMission = 5,
    herbicideMission = 5,
    sprayingMission = 5,
    mowMission = 5,
    deadwoodMission = 5,
    hoeMission = 5,

    -------------------------------------------------
    -- LOW
    -------------------------------------------------

    tedderMission = 4,
    limeMission = 4,
    stonePickMission = 4,
    destructibleRockMission = 4,
    transportMission = 4,
    supplyTransportMission = 4,

    -------------------------------------------------
    -- EASY
    -------------------------------------------------

    baleMission = 3,
    baleWrapMission = 3,
    treeTransportMission = 2,

    -------------------------------------------------
    -- SPECIAL
    -------------------------------------------------

    kommunalMission = 8

}

-------------------------------------------------
-- GET REP VALUE
-------------------------------------------------

local function getRepReward(mission)

    if mission == nil then
        return 5
    end

    local missionType =
        tostring(mission.type.name)

    local rep =
        ContractEvaluator.repMultipliers[missionType]

    if rep == nil then
        return 5
    end

    return rep

end

-------------------------------------------------
-- MISSION FINISH
-------------------------------------------------

local function onMissionFinish(self, success)

    if success == MissionFinishState.SUCCESS then

        local rep =
            getRepReward(self)

        if self.info ~= nil then

			ReputationManager.addContractorJob(
			self.info.contractorName
		)

			ReputationManager.addContractorCompleted(
			self.info.contractorName,
			rep
		)

	end

        ReputationManager.add(rep)

-------------------------------------------------
-- REPUTATION BONUS
-------------------------------------------------

        local rewardBonus =
            ReputationManager.getRewardBonus()

        local bonus =
            math.floor(
                self:getReward()
                * rewardBonus
            )

        if bonus > 0 then

            g_currentMission:addMoney(
                bonus,
                g_currentMission:getFarmId(),
                MoneyType.AI,
                true
            )
			
            RankNotificationManager.pendingRank =
			ReputationManager.getRank()

			RankNotificationManager.pendingBonus =
			bonus

        end


    else

    ReputationManager.remove(5)

    if self.info ~= nil then

        ReputationManager.addContractorCancelled(
            self.info.contractorName
        )

		end
	end
end
-------------------------------------------------
-- REGISTER
-------------------------------------------------

AbstractMission.finish =
    Utils.appendedFunction(
        AbstractMission.finish,
        onMissionFinish
    )