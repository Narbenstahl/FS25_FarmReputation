AKFFieldAnalyzer = {}

function AKFFieldAnalyzer.getCropCoverage(
    field,
    fruitTypeIndex
)

    if field == nil then
        return 0
    end

    if fruitTypeIndex == nil
    or fruitTypeIndex == FruitType.UNKNOWN then
        return 0
    end

    local fruitDesc =
        g_fruitTypeManager:getFruitTypeByIndex(
            fruitTypeIndex
        )

    if fruitDesc == nil then
        return 0
    end

    if fruitDesc.terrainDataPlaneId == nil then
        return 0
    end

    local modifier =
        DensityMapModifier.new(
            fruitDesc.terrainDataPlaneId,
            fruitDesc.startStateChannel,
            fruitDesc.numStateChannels,
            g_terrainNode
        )

    modifier:setPolygonRoundingMode(
        DensityRoundingMode.INCLUSIVE
    )

    field:getDensityMapPolygon():applyToModifier(
        modifier
    )

    local filter =
        DensityMapFilter.new(
            modifier
        )

    filter:setValueCompareParams(
        DensityValueCompareType.GREATER,
        0
    )

    local _,
          area,
          totalArea =
        modifier:executeGet(
            filter
        )

    if totalArea == nil
    or totalArea <= 0 then
        return 0
    end

    return area / totalArea * 100
end