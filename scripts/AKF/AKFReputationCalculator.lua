AKFReputationCalculator = {}

--print("[AKF] AKFReputationCalculator geladen")
	
	-------------------------------------------------
	-- AKF AKTIV?
	-------------------------------------------------

	function AKFReputationCalculator.isEnabled()
	
		return g_currentMission ~= nil
			and g_currentMission.missionInfo ~= nil
			and g_currentMission.missionInfo.plowingRequiredEnabled
			and g_currentMission.missionInfo.stonesEnabled
			and g_currentMission.missionInfo.weedsEnabled

	end
	
	-------------------------------------------------
	-- PFLÜGEN AKTIV?
	-------------------------------------------------

	function AKFReputationCalculator.isPlowingEnabled()

		return g_currentMission ~= nil
			and g_currentMission.missionInfo ~= nil
			and g_currentMission.missionInfo.plowingRequiredEnabled

	end

	-------------------------------------------------
	-- STEINE AKTIV?
	-------------------------------------------------

	function AKFReputationCalculator.isStonesEnabled()

		return g_currentMission ~= nil
			and g_currentMission.missionInfo ~= nil
			and g_currentMission.missionInfo.stonesEnabled

	end

	-------------------------------------------------
	-- UNKRAUT AKTIV?
	-------------------------------------------------

	function AKFReputationCalculator.isWeedsEnabled()

		return g_currentMission ~= nil
			and g_currentMission.missionInfo ~= nil
			and g_currentMission.missionInfo.weedsEnabled

	end
	
	-------------------------------------------------
	-- SCORE BERECHNEN
	-------------------------------------------------
	
	function AKFReputationCalculator.calculate(fieldData)

    if fieldData == nil then
        return 0
    end
	
    ------------------------------------------------
    -- AKF nur aktiv wenn alle drei Systeme aktiv
    ------------------------------------------------

    if not AKFReputationCalculator.isEnabled() then
		return 0
	end

    local score = 0

    ------------------------------------------------
    -- Bestand (10 Punkte)
    ------------------------------------------------

    if (fieldData.cropPct or 0) >= 90 then

        score = score + 10

    end

    ------------------------------------------------
	-- Dünger / Precision Farming Stickstoff
	------------------------------------------------

	local fertilizerPct = fieldData.fertPct or 0

	if fieldData.pfNitrogenPct ~= nil then

		fertilizerPct =
			fieldData.pfNitrogenPct

		if fertilizerPct < 20 then
			fertilizerPct = 0
		end

	end

	score =
		score +
		(fertilizerPct * 0.40)

    ------------------------------------------------
    -- Kalk (10 Punkte)
    ------------------------------------------------

    local limePct = fieldData.limePct or 0

    if limePct >= 90 then

        score = score + 10

    elseif limePct >= 66 then

        score = score + 5

    end

    ------------------------------------------------
    -- Pflügen (10 Punkte)
    ------------------------------------------------

    if (fieldData.plowPct or 0) >= 90 then

        score = score + 10

    end

    ------------------------------------------------
    -- Unkraut (15 Punkte)
    ------------------------------------------------

    if (fieldData.weedsPenalizingPct or 0) < 0.01 then

        score = score + 15

    end

    ------------------------------------------------
    -- Steine (15 Punkte)
    ------------------------------------------------

    if (fieldData.stonePct or 0) <= 0 then

        score = score + 15

    end

    ------------------------------------------------
    -- Begrenzen
    ------------------------------------------------

    if score > 100 then
        score = 100
    end

    if score < 0 then
        score = 0
    end
	
	if (fieldData.cropPct or 0) < 90 then
		score = math.min(score, 50)
	end
    
	return math.floor(score + 0.5)
	
	end
	
	------------------------------------------------
	-- FARM SCORE
	------------------------------------------------

	function AKFReputationCalculator.calculateFarmScore()

		if g_fieldManager == nil then
			return 0
		end

		local totalScore = 0
		local fieldCount = 0
		
		local weedCount = 0
		local stoneCount = 0
		local limeCount = 0
		local fertilizerCount = 0
		local plowCount = 0
		
		for _, field in pairs(g_fieldManager:getFields()) do

			local farmland = field.farmland

			if farmland ~= nil
			and g_farmlandManager:getFarmlandOwner(farmland.id) == g_currentMission:getFarmId() then

				local fieldData =
					AKFFieldScanner.scanField(field)
		
		------------------------------------------------
		-- FELDSTATISTIK
		------------------------------------------------

		if (fieldData.weedsPenalizingPct or 0) < 0.01 then
			weedCount = weedCount + 1
		end

		if (fieldData.stonePct or 0) <= 0 then
			stoneCount = stoneCount + 1
		end

		if (fieldData.limePct or 0) >= 90 then
			limeCount = limeCount + 1
		end

		local fertilizerPct = fieldData.fertPct or 0

		if fieldData.pfNitrogenPct ~= nil then
			fertilizerPct = fieldData.pfNitrogenPct
		end

		if fertilizerPct >= 90 then
			fertilizerCount = fertilizerCount + 1
		end

		if (fieldData.plowPct or 0) >= 90 then
			plowCount = plowCount + 1
		end
		
				local score =
					AKFReputationCalculator.calculate(fieldData)

				totalScore = totalScore + score
				fieldCount = fieldCount + 1

			end

		end

		if fieldCount == 0 then
			return 0
		end
		
		------------------------------------------------
		-- FELDANALYSE SPEICHERN
		------------------------------------------------

		AKFFarmEvaluationManager.totalFields = fieldCount

		AKFFarmEvaluationManager.weedFields = weedCount
		AKFFarmEvaluationManager.stoneFields = stoneCount
		AKFFarmEvaluationManager.limeFields = limeCount
		AKFFarmEvaluationManager.fertilizedFields = fertilizerCount
		AKFFarmEvaluationManager.plowedFields = plowCount
		
		return math.floor(
			(totalScore / fieldCount) + 0.5
		)

	end
	
