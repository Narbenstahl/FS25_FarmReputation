ReputationManager = {}

ReputationManager.reputationByFarm = {}

	-------------------------------------------------
	-- CONTRACTOR STATS
	-------------------------------------------------

	ReputationManager.contractorStatsByFarm = {}
	
	-------------------------------------------------
	-- CONTRACTOR DATA
	-------------------------------------------------

	ReputationManager.contractorDataByFarm = {}
	
	-------------------------------------------------
	-- GET CURRENT FARM ID
	-------------------------------------------------

	function ReputationManager.getCurrentFarmId()

		if g_currentMission == nil then
			return 1
		end

		return g_currentMission:getFarmId() or 1

	end

	-------------------------------------------------
	-- ENSURE FARM DATA
	-------------------------------------------------

	function ReputationManager.ensureFarmData(farmId)

		if ReputationManager.reputationByFarm[farmId] == nil then
			ReputationManager.reputationByFarm[farmId] = 0
		end

		if ReputationManager.contractorStatsByFarm[farmId] == nil then
			ReputationManager.contractorStatsByFarm[farmId] = {}
		end
		
		if ReputationManager.contractorDataByFarm[farmId] == nil then
			ReputationManager.contractorDataByFarm[farmId] = {}
		end
		
	end

	-------------------------------------------------
	-- RANKS
	-------------------------------------------------

	ReputationManager.ranks = {

		{
			title = g_i18n:getText("fr_rank_farmHelper"),
			min = 0,
			missionLimit = 1,
			maxContractValue = 10000,
			rewardBonus = 0.00
		},

		{
			title = g_i18n:getText("fr_rank_farmer"),
			min = 250,
			missionLimit = 2,
			maxContractValue = 25000,
			rewardBonus = 0.02
		},

		{
			title = g_i18n:getText("fr_rank_contractFarmer"),
			min = 750,
			missionLimit = 4,
			maxContractValue = 50000,
			rewardBonus = 0.05
		},

		{
			title = g_i18n:getText("fr_rank_largeContractFarmer"),
			min = 1500,
			missionLimit = 6,
			maxContractValue = 100000,
			rewardBonus = 0.07
		},

		{
			title = g_i18n:getText("fr_rank_agriculturalContractor"),
			min = 3000,
			missionLimit = 8,
			maxContractValue = 200000,
			rewardBonus = 0.10
		},

		{
			title = g_i18n:getText("fr_rank_largeFarm"),
			min = 6000,
			missionLimit = 10,
			maxContractValue = math.huge,
			rewardBonus = 0.15
		}

	}

	-------------------------------------------------
	-- GET RANK DATA
	-------------------------------------------------

	function ReputationManager.getRankData()

    local currentRank =
        ReputationManager.ranks[1]

    local reputation =
        ReputationManager.get()

    for _, rank in ipairs(
        ReputationManager.ranks
    ) do

        if reputation >= rank.min then

            currentRank = rank

        end

    end

    return currentRank

end

	-------------------------------------------------
	-- GET RANK
	-------------------------------------------------

	function ReputationManager.getRank()

		return ReputationManager
			.getRankData()
			.title

	end

	-------------------------------------------------
	-- GET MISSION LIMIT
	-------------------------------------------------

	function ReputationManager.getMissionLimit()

		return ReputationManager
			.getRankData()
			.missionLimit

	end

	-------------------------------------------------
	-- GET MAX CONTRACT VALUE
	-------------------------------------------------

	function ReputationManager.getMaxContractValue()

		return ReputationManager
			.getRankData()
			.maxContractValue

	end
	
	-------------------------------------------------
	-- GET REWARD BONUS
	-------------------------------------------------

	function ReputationManager.getRewardBonus()

    return ReputationManager
        .getRankData()
        .rewardBonus

	end
	
	-------------------------------------------------
	-- ADD REPUTATION
	-------------------------------------------------

	function ReputationManager.add(amount)

    local farmId =
        ReputationManager.getCurrentFarmId()

    ReputationManager.ensureFarmData(
        farmId
    )

    local oldRank =
        ReputationManager.getRankData()

    ReputationManager.reputationByFarm[
        farmId
    ] =
        ReputationManager.reputationByFarm[
            farmId
        ] + amount
	
	if FarmReputation.autoSaveManager ~= nil then
		FarmReputation.autoSaveManager:markDirty()
	end
	
    local newRank =
        ReputationManager.getRankData()

    if oldRank.title ~= newRank.title then

        if RankNotificationManager ~= nil then

            RankNotificationManager.showRankUp(
                oldRank,
                newRank
            )

        end

    end

end

	-------------------------------------------------
	-- REMOVE REPUTATION
	-------------------------------------------------

	function ReputationManager.remove(amount)

    local farmId =
        ReputationManager.getCurrentFarmId()

    ReputationManager.ensureFarmData(
        farmId
    )

    local oldRank =
        ReputationManager.getRankData()

    ReputationManager.reputationByFarm[
        farmId
    ] =
        ReputationManager.reputationByFarm[
            farmId
        ] - amount

    if ReputationManager.reputationByFarm[
        farmId
    ] < 0 then

        ReputationManager.reputationByFarm[
            farmId
        ] = 0

    end
	
	if FarmReputation.autoSaveManager ~= nil then
		FarmReputation.autoSaveManager:markDirty()
	end
	
    local newRank =
        ReputationManager.getRankData()

    if oldRank.title ~= newRank.title then

        if RankNotificationManager ~= nil then

            RankNotificationManager.showRankDown(
                oldRank,
                newRank
            )

        end

    end

end

	-------------------------------------------------
	-- GET REPUTATION
	-------------------------------------------------

	function ReputationManager.get()

    local farmId =
        ReputationManager.getCurrentFarmId()

    ReputationManager.ensureFarmData(
        farmId
    )

    return ReputationManager.reputationByFarm[
        farmId
    ]

	end
	
	-------------------------------------------------
	-- ENSURE CONTRACTOR DATA
	-------------------------------------------------

	function ReputationManager.ensureContractorData(
		contractorName
	)

		if contractorName == nil then
			return nil
		end

		local farmId =
			ReputationManager.getCurrentFarmId()

		ReputationManager.ensureFarmData(
			farmId
		)

		local contractorData =
			ReputationManager.contractorDataByFarm[
				farmId
			][
				contractorName
			]

		if contractorData == nil then

			contractorData = {
				reputation = 0,
				completed = 0,
				cancelled = 0
			}

			ReputationManager.contractorDataByFarm[
				farmId
			][
				contractorName
			] = contractorData

			end

			return contractorData

	end

	-------------------------------------------------
	-- GET CONTRACTOR DATA
	-------------------------------------------------

	function ReputationManager.getContractorData(
		contractorName
	)

		return ReputationManager.ensureContractorData(
			contractorName
		)

	end

	-------------------------------------------------
	-- GET ALL CONTRACTOR DATA
	-------------------------------------------------

	function ReputationManager.getAllContractorData()

		local farmId =
			ReputationManager.getCurrentFarmId()

		ReputationManager.ensureFarmData(
			farmId
		)

		return ReputationManager.contractorDataByFarm[
			farmId
		]

	end
	
	-------------------------------------------------
	-- ADD CONTRACTOR COMPLETED
	-------------------------------------------------

	function ReputationManager.addContractorCompleted(
		contractorName,
		reputation
	)

		local contractorData =
			ReputationManager.ensureContractorData(
				contractorName
			)

		if contractorData == nil then
			return
		end

		contractorData.completed =
			contractorData.completed + 1

		contractorData.reputation =
			contractorData.reputation +
			(reputation or 0)
	
		if FarmReputation.autoSaveManager ~= nil then
			FarmReputation.autoSaveManager:markDirty()
		end
		
	end

	-------------------------------------------------
	-- ADD CONTRACTOR CANCELLED
	-------------------------------------------------

	function ReputationManager.addContractorCancelled(
		contractorName
	)

		local contractorData =
			ReputationManager.ensureContractorData(
				contractorName
			)

		if contractorData == nil then
			return
		end

		contractorData.cancelled =
			contractorData.cancelled + 1

		contractorData.reputation =
			math.max(
				0,
				contractorData.reputation - 5
			)
		
		if FarmReputation.autoSaveManager ~= nil then
			FarmReputation.autoSaveManager:markDirty()
		end
		
	end

	-------------------------------------------------
	-- GET CONTRACTOR ACCEPTED
	-------------------------------------------------

	function ReputationManager.getContractorAccepted(
		contractorName
	)

		local contractorData =
			ReputationManager.ensureContractorData(
				contractorName
			)

		if contractorData == nil then
			return 0
		end

		return
			contractorData.completed +
			contractorData.cancelled

	end
	
	-------------------------------------------------
	-- GET CONTRACTOR REPUTATION
	-------------------------------------------------

	function ReputationManager.getContractorReputation(
		contractorName
	)

		local contractorData =
			ReputationManager.ensureContractorData(
				contractorName
			)

		if contractorData == nil then
			return 0
		end

		return contractorData.reputation or 0

	end

	-------------------------------------------------
	-- GET CONTRACTOR COMPLETED
	-------------------------------------------------

	function ReputationManager.getContractorCompleted(
		contractorName
	)

		local contractorData =
			ReputationManager.ensureContractorData(
				contractorName
			)

		if contractorData == nil then
			return 0
		end

		return contractorData.completed or 0

	end

	-------------------------------------------------
	-- GET CONTRACTOR CANCELLED
	-------------------------------------------------

	function ReputationManager.getContractorCancelled(
		contractorName
	)

		local contractorData =
			ReputationManager.ensureContractorData(
				contractorName
			)

		if contractorData == nil then
			return 0
		end

		return contractorData.cancelled or 0

	end

	-------------------------------------------------
	-- GET CONTRACTOR RANK
	-------------------------------------------------

	function ReputationManager.getContractorRank(
		contractorName
	)

		local reputation =
			ReputationManager.getContractorReputation(
				contractorName
			)

		if reputation >= 300 then
			return g_i18n:getText("fr_contractorRank_businessPartner")
		end

		if reputation >= 150 then
			return g_i18n:getText("fr_contractorRank_regularCustomer")
		end

		if reputation >= 50 then
			return g_i18n:getText("fr_contractorRank_satisfiedCustomer")
		end

		return g_i18n:getText("fr_contractorRank_newCustomer")

	end
	
	-------------------------------------------------
	-- GET CONTRACTOR MAX CONTRACT BONUS
	-------------------------------------------------

	function ReputationManager.getContractorMaxContractBonus(contractorName)

		local reputation =
			ReputationManager.getContractorReputation(contractorName)

		if reputation >= 300 then
			return 50000
		end

		if reputation >= 150 then
			return 25000
		end

		if reputation >= 50 then
			return 5000
		end

		return 0

	end
	
	-------------------------------------------------
	-- GET CONTRACTOR MAX CONTRACT VALUE
	-------------------------------------------------

	function ReputationManager.getContractorMaxContractValue(contractorName)

		local baseLimit =
			ReputationManager.getMaxContractValue()

		local bonus =
			ReputationManager.getContractorMaxContractBonus(
				contractorName
			)

		if baseLimit == math.huge then
			return math.huge
		end

		return baseLimit + bonus

	end
	
	-------------------------------------------------
	-- GET TOP CONTRACTOR
	-------------------------------------------------

	function ReputationManager.getTopContractor()

		local contractors =
			ReputationManager.getAllContractorData()

		local bestName = nil
		local bestRep = -1

		if contractors == nil then
			return nil
		end

		for contractorName, data in pairs(
			contractors
		) do

			local rep =
				data.reputation or 0

			if rep > bestRep then

				bestRep = rep
				bestName = contractorName

			end

		end

		return bestName

	end
	
	-------------------------------------------------
	-- CONTRACTOR JOBS
	-------------------------------------------------

	function ReputationManager.addContractorJob(
		contractorName
	)

		if contractorName == nil then
    return
	end

	local farmId =
    ReputationManager.getCurrentFarmId()

	ReputationManager.ensureFarmData(
    farmId
	)

	local currentJobs =
    ReputationManager.contractorStatsByFarm[
        farmId
    ][
        contractorName
    ] or 0

	currentJobs =
    currentJobs + 1

	ReputationManager.contractorStatsByFarm[
    farmId
	][
    contractorName
	] = currentJobs
	
		if FarmReputation.autoSaveManager ~= nil then
			FarmReputation.autoSaveManager:markDirty()
		end
	
	end

	-------------------------------------------------
	-- GET CONTRACTOR JOBS
	-------------------------------------------------

	function ReputationManager.getContractorJobs(
		contractorName
	)

		if contractorName == nil then
    return 0
	end

	local farmId =
    ReputationManager.getCurrentFarmId()

	ReputationManager.ensureFarmData(
    farmId
	)

	return ReputationManager.contractorStatsByFarm[
    farmId
	][
    contractorName
	] or 0
	
	end

	-------------------------------------------------
	-- GET ALL CONTRACTOR STATS
	-------------------------------------------------

	function ReputationManager.getAllContractorStats()

		local farmId =
    ReputationManager.getCurrentFarmId()

	ReputationManager.ensureFarmData(
    farmId
	)

	return ReputationManager.contractorStatsByFarm[
    farmId
	]

	end

	-------------------------------------------------
	-- GET ALL FARM REPUTATIONS
	-------------------------------------------------

	function ReputationManager.getAllFarmReputations()

    return ReputationManager.reputationByFarm

	end

	-------------------------------------------------
	-- GET ALL FARM CONTRACTOR STATS
	-------------------------------------------------

	function ReputationManager.getAllFarmContractorStats()

    return ReputationManager.contractorStatsByFarm

	end

	-------------------------------------------------
	-- GET NPC JOBS (BETTER CONTRACTS)
	-------------------------------------------------

	function ReputationManager.getNpcJobs(
		npcIndex,
		farmId
	)

		if npcIndex == nil then
			return 0
		end

		farmId =
			farmId
			or g_currentMission:getFarmId()

		local farm =
			g_farmManager:getFarmById(
				farmId
			)

		if farm == nil
		or farm.stats == nil
		or farm.stats.npcJobs == nil then
			return 0
		end

		return farm.stats.npcJobs[
			npcIndex
		] or 0

	end
	
	-------------------------------------------------
	-- GET CONTRACTOR LEVEL
	-------------------------------------------------

	function ReputationManager.getContractorLevel(
    npcIndex,
    farmId
)

    local jobs =
        ReputationManager.getNpcJobs(
            npcIndex,
            farmId
        )

    if jobs >= 50 then
        return g_i18n:getText("fr_contractorRank_businessPartner")
    end

    if jobs >= 25 then
        return g_i18n:getText("fr_contractorRank_regularCustomer")
    end

    if jobs >= 10 then
        return g_i18n:getText("fr_contractorRank_satisfiedCustomer")
    end

    return g_i18n:getText("fr_contractorRank_newCustomer")

	end
	
	-------------------------------------------------
	-- GET CONTRACTOR BONUS
	-------------------------------------------------

	function ReputationManager.getContractorBonus(
    npcIndex,
    farmId
)

    local level =
        ReputationManager.getContractorLevel(
            npcIndex,
            farmId
        )

    if level == g_i18n:getText("fr_contractorRank_businessPartner") then
		return 25000
	end

	if level == g_i18n:getText("fr_contractorRank_regularCustomer") then
		return 15000
	end

	if level == g_i18n:getText("fr_contractorRank_satisfiedCustomer") then
		return 5000
	end

	return 0

	end
	
	-------------------------------------------------
	-- IS ADMIN?
	-------------------------------------------------

	function ReputationManager.isConsoleAdmin()

		if g_currentMission == nil then
			return false
		end

		-- Singleplayer
		if not g_currentMission.missionDynamicInfo.isMultiplayer then
			return true
		end

		-- Multiplayer: nur Server/Admin
		return g_server ~= nil

	end
	
	-------------------------------------------------
	-- CONSOLE COMMANDS
	-------------------------------------------------

	addConsoleCommand(
		"frAddRep",
		"Add reputation",
		"consoleAddRep",
		ReputationManager
	)

	addConsoleCommand(
		"frRemoveRep",
		"Remove reputation",
		"consoleRemoveRep",
		ReputationManager
	)

	function ReputationManager:consoleAddRep(amount)

		if not ReputationManager.isConsoleAdmin() then
			Logging.warning(
				"[Farm Reputation] Only the server administrator may use this command."
			)
			return
		end

		amount = tonumber(amount) or 0

		ReputationManager.add(amount)

	end

	function ReputationManager:consoleRemoveRep(amount)

		if not ReputationManager.isConsoleAdmin() then
			Logging.warning(
				"[Farm Reputation] Only the server administrator may use this command."
			)
			return
		end

		amount = tonumber(amount) or 0

		ReputationManager.remove(amount)

	end