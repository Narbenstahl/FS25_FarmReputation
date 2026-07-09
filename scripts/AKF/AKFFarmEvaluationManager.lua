AKFFarmEvaluationManager = {}

-------------------------------------------------
-- DATA
-------------------------------------------------

AKFFarmEvaluationManager.lastKnownPeriod = -1

AKFFarmEvaluationManager.lastEvaluationPeriod = 0
AKFFarmEvaluationManager.lastEvaluationYear = 0
AKFFarmEvaluationManager.lastFarmScore = 0
AKFFarmEvaluationManager.lastReputation = 0

-------------------------------------------------
-- FELDANALYSE
-------------------------------------------------

AKFFarmEvaluationManager.totalFields = 0

AKFFarmEvaluationManager.weedFields = 0
AKFFarmEvaluationManager.stoneFields = 0
AKFFarmEvaluationManager.limeFields = 0
AKFFarmEvaluationManager.fertilizedFields = 0
AKFFarmEvaluationManager.plowedFields = 0

AKFFarmEvaluationManager.ranks = {

    {
        minScore = 95,
        name = g_i18n:getText("fr_farmRank_exemplaryFarm"),
        reputation = 15
    },

    {
        minScore = 85,
        name = g_i18n:getText("fr_farmRank_respectedFarm"),
        reputation = 10
    },

    {
        minScore = 70,
        name = g_i18n:getText("fr_farmRank_solidFarm"),
        reputation = 0
    },

    {
        minScore = 50,
        name = g_i18n:getText("fr_farmRank_needsImprovement"),
        reputation = -15
    },

    {
        minScore = 0,
        name = g_i18n:getText("fr_farmRank_problemFarm"),
        reputation = -30
    }

}

-------------------------------------------------
-- GET RANK DATA
-------------------------------------------------

function AKFFarmEvaluationManager.getRankData(
    farmScore
)

    farmScore =
        tonumber(farmScore) or 0

    for _, rank in ipairs(
        AKFFarmEvaluationManager.ranks
    ) do

        if farmScore >= rank.minScore then
            return rank
        end

    end

    return nil

end

-------------------------------------------------
-- GET STATUS
-------------------------------------------------

function AKFFarmEvaluationManager.getStatus(
    farmScore
)

    local rank =
        AKFFarmEvaluationManager.getRankData(
            farmScore
        )

    if rank ~= nil then
        return rank.name
    end

    return g_i18n:getText("fr_unknown")

end

-------------------------------------------------
-- GET LAST STATUS
-------------------------------------------------

function AKFFarmEvaluationManager.getLastStatus()

    return AKFFarmEvaluationManager.getStatus(
        AKFFarmEvaluationManager.lastFarmScore
    )

end

-------------------------------------------------
-- GET LAST EVALUATION TEXT
-------------------------------------------------

function AKFFarmEvaluationManager.getLastEvaluationText()

    local monthNames = {
		[1] = g_i18n:getText("fr_month_march"),
		[4] = g_i18n:getText("fr_month_june"),
		[7] = g_i18n:getText("fr_month_september"),
		[10] = g_i18n:getText("fr_month_december")
	}

    local month =
        monthNames[
            AKFFarmEvaluationManager.lastEvaluationPeriod
        ]

    if month == nil then
        return g_i18n:getText("fr_noEvaluation")
    end

    return string.format(
				"%s %s %d",
				month,
				g_i18n:getText("fr_year"),
				AKFFarmEvaluationManager.lastEvaluationYear
			)

end

-------------------------------------------------
-- GET FIELD ANALYSIS
-------------------------------------------------

function AKFFarmEvaluationManager.getWeedText()

    return string.format(
			g_i18n:getText("fr_fieldAnalysis_clean"),
			AKFFarmEvaluationManager.weedFields,
			AKFFarmEvaluationManager.totalFields
		   )

end

function AKFFarmEvaluationManager.getStoneText()

    return string.format(
		g_i18n:getText("fr_fieldAnalysis_stoneFree"),
		AKFFarmEvaluationManager.stoneFields,
		AKFFarmEvaluationManager.totalFields
	)

end

function AKFFarmEvaluationManager.getLimeText()

    return string.format(
		g_i18n:getText("fr_fieldAnalysis_limed"),
		AKFFarmEvaluationManager.limeFields,
		AKFFarmEvaluationManager.totalFields
	)

end

function AKFFarmEvaluationManager.getFertilizerText()

    return string.format(
		g_i18n:getText("fr_fieldAnalysis_fertilized"),
		AKFFarmEvaluationManager.fertilizedFields,
		AKFFarmEvaluationManager.totalFields
	)

end

function AKFFarmEvaluationManager.getPlowText()

    return string.format(
		g_i18n:getText("fr_fieldAnalysis_plowed"),
		AKFFarmEvaluationManager.plowedFields,
		AKFFarmEvaluationManager.totalFields
	)

end

-------------------------------------------------
-- APPLY REPUTATION
-------------------------------------------------

function AKFFarmEvaluationManager.applyReputation(
    farmScore
)

    local rank =
        AKFFarmEvaluationManager.getRankData(
            farmScore
        )

    if rank == nil then
        return
    end

    if rank.reputation > 0 then

        ReputationManager.add(
            rank.reputation
        )

    elseif rank.reputation < 0 then

        ReputationManager.remove(
            math.abs(
                rank.reputation
            )
        )

    end
	
	AKFFarmEvaluationManager.lastEvaluationPeriod =
		g_currentMission.environment.currentPeriod

	AKFFarmEvaluationManager.lastEvaluationYear =
		g_currentMission.environment.currentYear

	AKFFarmEvaluationManager.lastFarmScore =
		farmScore

	AKFFarmEvaluationManager.lastReputation =
		rank.reputation

    Logging.info(
        "[AKF] Quartalsbewertung"
    )

    Logging.info(
        "[AKF] Farmscore: %d",
        farmScore
    )

    Logging.info(
        "[AKF] Status: %s",
        rank.name
    )

    Logging.info(
        "[AKF] Reputation: %+d",
        rank.reputation
    )

end

-------------------------------------------------
-- EVALUATE
-------------------------------------------------

function AKFFarmEvaluationManager.evaluate()

    Logging.info("===== AKF QUARTALSBEWERTUNG =====")

    local farmScore =
        AKFReputationCalculator.calculateFarmScore()

    if farmScore == nil then
        return
    end

    Logging.info(
        "[AKF] FarmScore = %d",
        farmScore
    )

    AKFFarmEvaluationManager.applyReputation(
        farmScore
    )

    Logging.info("===== AKF ENDE =====")

end

-------------------------------------------------
-- CHECK MONTH
-------------------------------------------------

function AKFFarmEvaluationManager.checkMonth(month)

    -- Monat hat sich nicht geändert
    if month == AKFFarmEvaluationManager.lastKnownPeriod then
        return
    end

    AKFFarmEvaluationManager.lastKnownPeriod = month

    -- Nur Quartalsmonate
    if month ~= 1
    and month ~= 4
    and month ~= 7
    and month ~= 10 then
        return
    end

    -- Bereits bewertet?
    if month == AKFFarmEvaluationManager.lastEvaluationPeriod then
        return
    end

    AKFFarmEvaluationManager.evaluate()

    AKFFarmEvaluationManager.lastEvaluationPeriod = month

end