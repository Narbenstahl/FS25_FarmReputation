AKFFieldScanner = {}

--print("[AKF] AKFFieldScanner geladen")

	local function computePct(area, totalArea)
		if totalArea == nil or totalArea <= 0 then
			return 0
		end
		return (area / totalArea) * 100
	end
	
	local function executeAreaForValue(modifier, filter, value)
		filter:setValueCompareParams(
			DensityValueCompareType.EQUAL,
			value
		)

		local _, area, totalArea =
			modifier:executeGet(filter)

		return area or 0, totalArea or 0
	end
	
	local function applyFieldPolygonToModifier(field, modifier)
		if field == nil then
			return nil
		end

		local poly = field:getDensityMapPolygon()

		if poly == nil then
			return nil
		end

		poly:applyToModifier(modifier)

		return poly
	end
	
	local function buildSoilLayerCache()
		local mission = g_currentMission

		if mission == nil
			or mission.fieldGroundSystem == nil
			or FieldDensityMap == nil then
			return nil
		end

		local cache = {}

		local function addFgsLayer(key, layerId)
			local mapId, firstChannel, numChannels =
				mission.fieldGroundSystem:getDensityMapData(layerId)

			if mapId ~= nil
				and firstChannel ~= nil
				and numChannels ~= nil then

				cache[key] = {
					mapId = mapId,
					firstChannel = firstChannel,
					numChannels = numChannels,
					layerId = layerId
				}
			end
		end

		addFgsLayer(
			"mulch",
			FieldDensityMap.STUBBLE_SHRED_LEVEL
		)

		addFgsLayer(
			"plow",
			FieldDensityMap.PLOW_LEVEL
		)

		addFgsLayer(
			"roll",
			FieldDensityMap.ROLLER_LEVEL
		)

		addFgsLayer(
			"spray",
			FieldDensityMap.SPRAY_LEVEL
		)

		addFgsLayer(
			"lime",
			FieldDensityMap.LIME_LEVEL
		)

		if mission.fieldGroundSystem.getMaxValue ~= nil then

			if cache.spray ~= nil then
				cache.spray.maxValue =
					mission.fieldGroundSystem:getMaxValue(
						FieldDensityMap.SPRAY_LEVEL
					)
			end

			if cache.lime ~= nil then
				cache.lime.maxValue =
					mission.fieldGroundSystem:getMaxValue(
						FieldDensityMap.LIME_LEVEL
					)
			end
		end

		if mission.weedSystem ~= nil
			and mission.weedSystem.getMapHasWeed ~= nil
			and mission.weedSystem.getDensityMapData ~= nil
			and mission.weedSystem:getMapHasWeed() then

			local mapId, firstChannel, numChannels =
				mission.weedSystem:getDensityMapData()

			if mapId ~= nil
				and firstChannel ~= nil
				and numChannels ~= nil then

				cache.weed = {
					mapId = mapId,
					firstChannel = firstChannel,
					numChannels = numChannels,
					maxValue = 9
				}
			end
		end

		return cache
	end
	
	local function buildSoilSamplers(layerCache)
		if layerCache == nil then
			return nil
		end

		local samplers = {}

		local function addSampler(key, layer)
			if layer == nil then
				return
			end

			local modifier =
				DensityMapModifier.new(
					layer.mapId,
					layer.firstChannel,
					layer.numChannels,
					g_terrainNode
				)

			local filter =
				DensityMapFilter.new(modifier)

			samplers[key] = {
				modifier = modifier,
				filter = filter,
				maxValue = layer.maxValue
			}
		end

		addSampler("mulch", layerCache.mulch)
		addSampler("plow",  layerCache.plow)
		addSampler("roll",  layerCache.roll)
		addSampler("spray", layerCache.spray)
		addSampler("lime",  layerCache.lime)
		addSampler("weed",  layerCache.weed)

		return samplers
	end
	
	local function computeDensitySoilStatusForFarmland(thisFarmland, hasCrop, samplers)

		if thisFarmland == nil
			or thisFarmland.field == nil
			or samplers == nil then
			return nil
		end

		local field = thisFarmland.field
		local result = {}

		-- Mulch (0/1)
		if samplers.mulch ~= nil then
			local modifier = samplers.mulch.modifier
			local filter = samplers.mulch.filter

			if applyFieldPolygonToModifier(field, modifier) ~= nil then
				local area1, totalArea =
					executeAreaForValue(
						modifier,
						filter,
						1
					)

				result.mulchPct =
					computePct(
						area1,
						totalArea
					)
			end
		end

		-- Plow (0/1)
		if samplers.plow ~= nil then
			local modifier = samplers.plow.modifier
			local filter = samplers.plow.filter

			if applyFieldPolygonToModifier(field, modifier) ~= nil then
				local area1, totalArea =
					executeAreaForValue(
						modifier,
						filter,
						1
					)

				result.plowPct =
					computePct(
						area1,
						totalArea
					)
			end
		end
		
		-- Roll (0/1)
		if hasCrop and samplers.roll ~= nil then
			local modifier = samplers.roll.modifier
			local filter = samplers.roll.filter

			if applyFieldPolygonToModifier(field, modifier) ~= nil then
				local area1, totalArea =
					executeAreaForValue(
						modifier,
						filter,
						1
					)

				result.rolledPct =
					computePct(
						area1,
						totalArea
					)
			end
		end
		
		-- Fertilizer (0/1/2)
		if samplers.spray ~= nil then
			local modifier = samplers.spray.modifier
			local filter = samplers.spray.filter
			local maxValue = samplers.spray.maxValue or 2

			if applyFieldPolygonToModifier(field, modifier) ~= nil then

				local area2, totalArea =
					executeAreaForValue(
						modifier,
						filter,
						math.min(2, maxValue)
					)

				local area1, _ =
					executeAreaForValue(
						modifier,
						filter,
						math.min(1, maxValue)
					)

				local pct2 =
					computePct(
						area2,
						totalArea
					)

				local pct1 =
					computePct(
						area1,
						totalArea
					)

				result.fertPct = 0

				if maxValue >= 2 and pct2 >= 90 then

					result.fertPct = 100

				elseif maxValue >= 2 and pct2 > 0 then

					local area0 =
						math.max(
							0,
							totalArea - area1 - area2
						)

					if area1 >= area0 then
						result.fertPct = 50
					else
						result.fertPct = 0
					end

				else

					if pct1 >= 90 then
						result.fertPct = 50
					else
						result.fertPct = 0
					end

				end
			end
		end
		
		-- Lime (0/1/2/3)
		if samplers.lime ~= nil then

			local modifier = samplers.lime.modifier
			local filter = samplers.lime.filter
			local maxValue = samplers.lime.maxValue or 3

			if applyFieldPolygonToModifier(field, modifier) ~= nil then

				local area3, totalArea =
					executeAreaForValue(
						modifier,
						filter,
						math.min(3, maxValue)
					)

				local area2, _ =
					executeAreaForValue(
						modifier,
						filter,
						math.min(2, maxValue)
					)

				local area1, _ =
					executeAreaForValue(
						modifier,
						filter,
						math.min(1, maxValue)
					)

				local pct3 =
					computePct(
						area3,
						totalArea
					)

				result.limePct = 0

				if maxValue >= 3 and pct3 >= 90 then

					result.limePct = 100

				else

					local area0 =
						math.max(
							0,
							totalArea - area1 - area2 - area3
						)

					if maxValue >= 3 and pct3 > 0 then

						if area2 >= area1
							and area2 >= area0 then

							result.limePct = 66.7

						elseif area1 >= area0 then

							result.limePct = 33.3

						else

							result.limePct = 0

						end

					else

						if area2 >= area1
							and area2 >= area0 then

							result.limePct = 66.7

						elseif area1 >= area0 then

							result.limePct = 33.3

						else

							result.limePct = 0

						end

					end
				end
			end
		end
		
		-- Weeds
		if samplers.weed ~= nil then

			local modifier = samplers.weed.modifier

			if applyFieldPolygonToModifier(field, modifier) ~= nil then

				local filter =
					DensityMapFilter.new(modifier)

				local area3, totalArea =
					executeAreaForValue(
						modifier,
						filter,
						3
					)

				local area4, _ =
					executeAreaForValue(
						modifier,
						filter,
						4
					)

				local area5, _ =
					executeAreaForValue(
						modifier,
						filter,
						5
					)

				local penalizingArea =
					area3 + area4 + area5

				local penalizingPct =
					computePct(
						penalizingArea,
						totalArea
					)

				result.weedsPenalizingPct =
					penalizingPct

				result.weedYieldFactor = 0

				if penalizingPct >= 10 then

					if area5 >= area4
						and area5 >= area3 then

						result.weedYieldFactor = 1.0

					elseif area4 >= area3 then

						result.weedYieldFactor = 0.75

					else

						result.weedYieldFactor = 0.5

					end
				end
			end
		end
		
		return result
	end
	
function AKFFieldScanner.scanField(field)

    local result = {
		stonePct = 0,
		weedsPenalizingPct = 0,

		fertPct = 0,
		limePct = 0,

		plowPct = 0,
		rolledPct = 0,
		mulchPct = 0,
		
		pfNitrogenLevel = nil,
		pfNitrogenTarget = nil,
		pfNitrogenPct = nil
	}

    local densityMapPolygon =
        field:getDensityMapPolygon()

    if densityMapPolygon == nil then
        --print("[AKF] Polygon NIL")
        return result
    end
	
	local fieldState =
		field:getFieldState()

	if fieldState ~= nil then

		result.fruitTypeIndex =
			fieldState.fruitTypeIndex

		result.growthState =
			fieldState.growthState

		result.cropPct =
			AKFFieldAnalyzer.getCropCoverage(
				field,
				fieldState.fruitTypeIndex
			)
	else

		result.fruitTypeIndex =
			FruitType.UNKNOWN

		result.growthState = 0
		result.cropPct = 0

	end
	
	------------------------------------------------
	-- Precision Farming Stickstoff
	-- Liest Stickstoff-Istwert und Zielwert
	-- über die Precision Farming N_MAP aus.
	------------------------------------------------

	local posX, posZ =
		field:getIndicatorPosition()

	result.pfNitrogenLevel = nil
	result.pfNitrogenTarget = nil
	result.pfNitrogenPct = nil

	for _, modObj in pairs(g_modEventListeners) do

		if modObj.getValueMaps ~= nil then

			local maps =
				modObj:getValueMaps()

			if maps ~= nil then

				for _, map in ipairs(maps) do

					if map.id == "N_MAP" then

						local level =
							map:getLevelAtWorldPos(
								posX,
								posZ
							)

						local target =
							map:getTargetLevelAtWorldPos(
								posX,
								posZ
							)

						result.pfNitrogenLevel =
							level

						result.pfNitrogenTarget =
							target

						if target ~= nil
							and target > 0 then

							result.pfNitrogenPct =
								math.min(
									level / target,
									1
								) * 100
						end

						break

					end

				end

			end

		end

	end
	
	local layerCache = buildSoilLayerCache()

	if layerCache == nil then
		return result
	end

	local samplers = buildSoilSamplers(layerCache)

	if samplers == nil then
		return result
	end
	
	local stoneSystem = g_currentMission.stoneSystem

	if stoneSystem ~= nil then

		local mapId, firstChannel, numChannels =
			stoneSystem:getDensityMapData()

		local modifier =
			DensityMapModifier.new(
				mapId,
				firstChannel,
				numChannels,
				g_terrainNode
			)

		densityMapPolygon:applyToModifier(modifier)

		local filterEq2 =
			DensityMapFilter.new(modifier)

		filterEq2:setValueCompareParams(
			DensityValueCompareType.EQUAL,
			2
		)

		local _, area2, totalArea =
			modifier:executeGet(filterEq2)

		local filterEq3 =
			DensityMapFilter.new(modifier)

		filterEq3:setValueCompareParams(
			DensityValueCompareType.EQUAL,
			3
		)

		local _, area3, _ =
			modifier:executeGet(filterEq3)

		local filterEq4 =
			DensityMapFilter.new(modifier)

		filterEq4:setValueCompareParams(
			DensityValueCompareType.EQUAL,
			4
		)

		local _, area4, _ =
			modifier:executeGet(filterEq4)

		if totalArea ~= nil and totalArea > 0 then

			result.stonePct =
				(
					((area2 or 0)
					+ (area3 or 0)
					+ (area4 or 0))
					/ totalArea
				) * 100

		end
	end
	
    local fakeFarmland = {
		id = 0,
		field = field
	}

	local hasCrop = true

	local soilStatus =
		computeDensitySoilStatusForFarmland(
			fakeFarmland,
			hasCrop,
			samplers
		)

	if soilStatus ~= nil then

		result.fertPct =
			soilStatus.fertPct or 0

		result.limePct =
			soilStatus.limePct or 0

		result.plowPct =
			soilStatus.plowPct or 0

		result.rolledPct =
			soilStatus.rolledPct or 0

		result.mulchPct =
			soilStatus.mulchPct or 0

		result.weedsPenalizingPct =
			soilStatus.weedsPenalizingPct or 0
		end
	return result

end