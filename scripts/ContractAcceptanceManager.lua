ContractAcceptanceManager = {}

-------------------------------------------------
-- DEBUG
-------------------------------------------------

local function frPrint(text)

    FRDebug.log(text)

end

-------------------------------------------------
-- START CONTRACT
-------------------------------------------------

local function startContract(
    self,
    superFunc,
    wantsLease
)
	
	FRDebug.log(
        "FR START CONTRACT CALLED"
    )
	
    local contract =
        self:getSelectedContract()

    if contract ~= nil
    and contract.mission ~= nil then

        local mission =
            contract.mission
		
		local farmId =
    g_currentMission:getFarmId()

	local activeMissions = 0

	for _, missionData in ipairs(
    g_missionManager.missions
	) do

    if missionData.farmId == farmId then

        activeMissions =
            activeMissions + 1

		end

	end

	local missionLimit =
    ReputationManager.getMissionLimit()

	if activeMissions >= missionLimit then

    MissionLimitNotificationManager.show(
        activeMissions,
        missionLimit
    )

    return

	end
		
		local reward =
		math.floor(
        mission:getReward() or 0
    )

        --frPrint(
        --    "START CONTRACT HOOK"
        --)

        --frPrint(
    --"MISSION REWARD: "
    --.. tostring(reward)
	--	)
	
	local npc =
    mission:getNPC()

	if npc ~= nil then

		--frPrint(
        --"NPC: "
        --.. tostring(npc.title)
    --)

		--frPrint(
        --"NPC INDEX: "
        --.. tostring(npc.index)
    --)

		--frPrint(
        --"BC JOBS: "
        --.. tostring(
        --    ReputationManager.getNpcJobs(
        --     npc.index
        --    )
        --)
    --)

	--	frPrint(
    --    "CONTRACTOR LEVEL: "
    --    .. tostring(
    --        ReputationManager.getContractorLevel(
    --            npc.index
    --        )
    --    )
    --)

	--	frPrint(
    --    "CONTRACTOR BONUS: "
    --    .. tostring(
    --        ReputationManager.getContractorBonus(
    --            npc.index
    --        )
    --    )
    --)

	end

	--	frPrint(
    --"RANK LIMIT: "
    --.. tostring(
    --    ReputationManager.getMaxContractValue()
	--	)	
	--)
	
	local contractorBonus = 0

	if npc ~= nil then

    contractorBonus =
        ReputationManager.getContractorBonus(
            npc.index
        )

	end
	
	local effectiveLimit =
    ReputationManager.getMaxContractValue()
    + contractorBonus

	--frPrint(
    --"EFFECTIVE LIMIT: "
    --.. tostring(
    --    effectiveLimit
	--	)
	--)
	
	if reward > effectiveLimit then
	
	local jobs =
		ReputationManager.getNpcJobs(
			npc.index
		)

	local level =
		ReputationManager.getContractorLevel(
			npc.index
		)

	local nextLevelText =
		g_i18n:getText("fr_contractorRank_businessPartner")

	local jobsNeeded =
		g_i18n:getText("fr_jobs_50plus")

	local nextBonus =
		"+25.000 "
		.. g_i18n:getText("fr_currency")

	if jobs < 10 then

		nextLevelText =
			g_i18n:getText("fr_contractorRank_satisfiedCustomer")

		jobsNeeded =
			jobs .. " / 10"

		nextBonus =
			"+5.000 "
			.. g_i18n:getText("fr_currency")

	elseif jobs < 25 then

		nextLevelText =
			g_i18n:getText("fr_contractorRank_regularCustomer")

		jobsNeeded =
			jobs .. " / 25"

		nextBonus =
			"+15.000 "
			.. g_i18n:getText("fr_currency")

	elseif jobs < 50 then

		nextLevelText =
			g_i18n:getText("fr_contractorRank_businessPartner")

		jobsNeeded =
			jobs .. " / 50"

		nextBonus =
			"+25.000 "
			.. g_i18n:getText("fr_currency")

	else

		jobsNeeded =
			tostring(jobs)

		nextBonus =
			g_i18n:getText("fr_maximum")

	end

    InfoDialog.show(

		g_i18n:getText("fr_contractLocked")
		.. "\n\n"

		.. g_i18n:getText("fr_contractValue")
		.. ": "
		.. tostring(reward)
		.. " "
		.. g_i18n:getText("fr_currency")
		.. "\n"

		.. g_i18n:getText("fr_currentLimit")
		.. ": "
		.. tostring(effectiveLimit)
		.. " "
		.. g_i18n:getText("fr_currency")
		.. "\n\n"

		.. g_i18n:getText("fr_contractor")
		.. ":\n"
		.. npc.title
		.. "\n\n"

		.. g_i18n:getText("fr_status")
		.. ":\n"
		.. level
		.. "\n\n"

		.. g_i18n:getText("fr_progress")
		.. ":\n"
		.. jobsNeeded
		.. "\n\n"

		.. g_i18n:getText("fr_nextLevel")
		.. ":\n"
		.. nextLevelText
		.. "\n\n"

		.. g_i18n:getText("fr_bonus")
		.. ":\n"
		.. nextBonus
	)

    return

	end
	
    end

    return superFunc(
        self,
        wantsLease
    )

	end

-------------------------------------------------
-- REGISTER
-------------------------------------------------

	FRDebug.log(
    "START CONTRACT BEFORE HOOK: "
    .. tostring(
        InGameMenuContractsFrame.startContract
    )
)

InGameMenuContractsFrame.startContract =
    Utils.overwrittenFunction(
        InGameMenuContractsFrame.startContract,
        startContract
    )
	
	FRDebug.log(
    "START CONTRACT AFTER HOOK: "
    .. tostring(
        InGameMenuContractsFrame.startContract
    )
)
	
frPrint(
    "ContractAcceptanceManager LOADED"
)