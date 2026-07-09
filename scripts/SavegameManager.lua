SavegameManager = {}

-------------------------------------------------
-- GET LOCAL USER ID
-------------------------------------------------

function SavegameManager.getLocalUserId()

    local userManager =
        g_currentMission.userManager

    if userManager ~= nil
    and userManager.users ~= nil then

        for _, user in pairs(
            userManager.users
        ) do

            return user.uniqueUserId

        end

    end

    return nil

end

-------------------------------------------------
-- SAVE
-------------------------------------------------

function SavegameManager.save()

    if g_currentMission == nil then
        return
    end

    local savegame =
        g_currentMission.missionInfo.savegameDirectory

    if savegame == nil then
        return
    end

    local xmlFile =
        createXMLFile(
            "farmReputationXML",
            savegame .. "/farmReputation.xml",
            "farmReputation"
        )

    if xmlFile == nil then
        return
    end

    -------------------------------------------------
	-- FARMS
	-------------------------------------------------

	local farmReputations =
    ReputationManager.getAllFarmReputations()

	local farmContractors =
    ReputationManager.getAllFarmContractorStats()
	
	local farmContractorData =
		ReputationManager.contractorDataByFarm
	
	local farmXmlIndex = 0
	
	for farmId, reputation in pairs(
    farmReputations
	) do

    local farmKey =
		"farmReputation.farms.farm("
		.. tostring(farmXmlIndex)
		.. ")"

    setXMLInt(
        xmlFile,
        farmKey .. "#id",
        farmId
    )

    setXMLInt(
        xmlFile,
        farmKey .. "#reputation",
        reputation
    )

    local contractors =
        farmContractors[farmId]

    if contractors ~= nil then

        local contractorIndex = 0

        for contractorName, jobs in pairs(
            contractors
        ) do

            local contractorKey =
                farmKey
                .. ".contractors.contractor("
                .. tostring(contractorIndex)
                .. ")"

            setXMLString(
                xmlFile,
                contractorKey .. "#name",
                contractorName
            )

            setXMLInt(
                xmlFile,
                contractorKey .. "#jobs",
                jobs
            )
			
		local contractorData = nil

		if farmContractorData ~= nil
		and farmContractorData[farmId] ~= nil then

			contractorData =
				farmContractorData[farmId][contractorName]

		end

		if contractorData ~= nil then

			setXMLInt(
				xmlFile,
				contractorKey .. "#reputation",
				contractorData.reputation or 0
			)

			setXMLInt(
				xmlFile,
				contractorKey .. "#completed",
				contractorData.completed or 0
			)

			setXMLInt(
				xmlFile,
				contractorKey .. "#cancelled",
				contractorData.cancelled or 0
			)

		end

            contractorIndex =
                contractorIndex + 1

        end

    end
	
	farmXmlIndex =
    farmXmlIndex + 1
	
end

   -------------------------------------------------
	-- HUD POSITION
	-------------------------------------------------

	local userId =
    SavegameManager.getLocalUserId()

	if userId ~= nil then

    local playerIndex = 0

    while true do

        local key =
            "farmReputation.hudPositions.player("
            .. tostring(playerIndex)
            .. ")"

        local savedUserId =
            getXMLString(
                xmlFile,
                key .. "#userId"
            )

        if savedUserId == nil
        or savedUserId == userId then

            setXMLString(
                xmlFile,
                key .. "#userId",
                userId
            )

            setXMLFloat(
                xmlFile,
                key .. "#posX",
                FarmReputationDisplay.posX
            )

            setXMLFloat(
                xmlFile,
                key .. "#posY",
                FarmReputationDisplay.posY
            )

            break

        end

        playerIndex =
            playerIndex + 1

    end

end

	-------------------------------------------------
	-- AKF EVALUATION
	-------------------------------------------------

	if AKFFarmEvaluationManager ~= nil then
	
	setXMLInt(
		xmlFile,
		"farmReputation.akfEvaluation#lastPeriod",
		AKFFarmEvaluationManager.lastEvaluationPeriod
	)

	setXMLInt(
		xmlFile,
		"farmReputation.akfEvaluation#lastYear",
		AKFFarmEvaluationManager.lastEvaluationYear
	)

	setXMLInt(
		xmlFile,
		"farmReputation.akfEvaluation#lastFarmScore",
		AKFFarmEvaluationManager.lastFarmScore
	)

	setXMLInt(
		xmlFile,
		"farmReputation.akfEvaluation#lastReputation",
		AKFFarmEvaluationManager.lastReputation
	)

	end

	saveXMLFile(xmlFile)
	delete(xmlFile)

end

-------------------------------------------------
-- LOAD
-------------------------------------------------

function SavegameManager.load()

    if g_currentMission == nil then
        return
    end

    local savegame =
        g_currentMission.missionInfo.savegameDirectory

    if savegame == nil then
        return
    end

    local path =
        savegame .. "/farmReputation.xml"

    if not fileExists(path) then
        return
    end

    local xmlFile =
        loadXMLFile(
            "farmReputationXML",
            path
        )

    if xmlFile == nil then
        return
    end

	-------------------------------------------------
	-- LOAD FARMS
	-------------------------------------------------

	ReputationManager.reputationByFarm = {}
	ReputationManager.contractorStatsByFarm = {}
	ReputationManager.contractorDataByFarm = {}

	local farmIndex = 0

	while true do

    local farmKey =
        "farmReputation.farms.farm("
        .. tostring(farmIndex)
        .. ")"

    local farmId =
        getXMLInt(
            xmlFile,
            farmKey .. "#id"
        )

    if farmId == nil then
        break
    end

    local reputation =
        getXMLInt(
            xmlFile,
            farmKey .. "#reputation"
        ) or 0

    ReputationManager.reputationByFarm[
        farmId
    ] = reputation

    ReputationManager.contractorStatsByFarm[
		farmId
	] = {}
	
	ReputationManager.contractorDataByFarm[
		farmId
	] = {}
	
	local contractorIndex = 0

	while true do

    local contractorKey =
        farmKey
        .. ".contractors.contractor("
        .. tostring(contractorIndex)
        .. ")"

    local contractorName =
        getXMLString(
            xmlFile,
            contractorKey .. "#name"
        )

    if contractorName == nil then
        break
    end

    local jobs =
        getXMLInt(
            xmlFile,
            contractorKey .. "#jobs"
        ) or 0

    ReputationManager.contractorStatsByFarm[
        farmId
    ][
        contractorName
    ] = jobs
	
	local contractorReputation =
		getXMLInt(
			xmlFile,
			contractorKey .. "#reputation"
		) or 0

	local contractorCompleted =
		getXMLInt(
			xmlFile,
			contractorKey .. "#completed"
		) or jobs

	local contractorCancelled =
		getXMLInt(
			xmlFile,
			contractorKey .. "#cancelled"
		) or 0

	ReputationManager.contractorDataByFarm[
		farmId
		][
		contractorName
		] = {
		reputation = contractorReputation,
		completed = contractorCompleted,
		cancelled = contractorCancelled
		}
	
    contractorIndex =
        contractorIndex + 1

	end

	farmIndex = farmIndex + 1

end
	
	-------------------------------------------------
	-- LOAD HUD POSITION
	-------------------------------------------------

	local userId =
    SavegameManager.getLocalUserId()

	if userId ~= nil then

    local playerIndex = 0

    while true do

        local key =
            "farmReputation.hudPositions.player("
            .. tostring(playerIndex)
            .. ")"

        local savedUserId =
            getXMLString(
                xmlFile,
                key .. "#userId"
            )

        if savedUserId == nil then
            break
        end

        if savedUserId == userId then

            FarmReputationDisplay.posX =
                getXMLFloat(
                    xmlFile,
                    key .. "#posX"
                ) or 0.875

            FarmReputationDisplay.posY =
                getXMLFloat(
                    xmlFile,
                    key .. "#posY"
                ) or 0.85

            break

        end

        playerIndex =
            playerIndex + 1

		end

	end
	
	-------------------------------------------------
	-- LOAD AKF EVALUATION
	-------------------------------------------------

	if AKFFarmEvaluationManager ~= nil then
		
		AKFFarmEvaluationManager.lastEvaluationPeriod =
			getXMLInt(
				xmlFile,
				"farmReputation.akfEvaluation#lastPeriod"
			) or 0

		AKFFarmEvaluationManager.lastEvaluationYear =
			getXMLInt(
				xmlFile,
				"farmReputation.akfEvaluation#lastYear"
			) or 0

		AKFFarmEvaluationManager.lastFarmScore =
			getXMLInt(
				xmlFile,
				"farmReputation.akfEvaluation#lastFarmScore"
			) or 0

		AKFFarmEvaluationManager.lastReputation =
			getXMLInt(
				xmlFile,
				"farmReputation.akfEvaluation#lastReputation"
			) or 0
		
	end
	
    delete(xmlFile)

end

-------------------------------------------------
-- LOAD EVENT
-------------------------------------------------

function SavegameManager.loadOnStart()

    SavegameManager.load()

end

-------------------------------------------------
-- DELETE EVENT
-------------------------------------------------

local function onMissionDelete()

    SavegameManager.save()

end

-------------------------------------------------
-- REGISTER
-------------------------------------------------

FSBaseMission.loadMapFinished =
    Utils.prependedFunction(
        FSBaseMission.loadMapFinished,
        SavegameManager.loadOnStart
    )

FSBaseMission.delete =
    Utils.appendedFunction(
        FSBaseMission.delete,
        onMissionDelete
    )