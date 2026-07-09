AKFDebug = {}

-------------------------------------------------
-- DEBUG EIN/AUS
-------------------------------------------------

AKFDebug.DEBUG = false

-------------------------------------------------
-- DEBUG AUSGABE
-------------------------------------------------

function AKFDebug.log(text)

    if AKFDebug.DEBUG then
        print(text)
    end

end

AKFDebug.log("[AKF] Datei geladen")

-------------------------------------------------
-- TEST
-------------------------------------------------

function AKFDebug.test()

    local farmId =
        g_currentMission:getFarmId()

    local farmlandIds =
        g_farmlandManager:getOwnedFarmlandIdsByFarmId(
            farmId
        )

    AKFDebug.log("===== AKF TEST =====")

    local farmScore = 0
    local fieldCount = 0

    for _, farmlandId in pairs(farmlandIds) do

        local field =
            g_fieldManager.farmlandIdFieldMapping[
                farmlandId
            ]

        if field ~= nil then

            local state =
                FieldState.new()

            local posX, posZ =
                field:getIndicatorPosition()

            state:update(
                posX,
                posZ
            )

            AKFDebug.log(
                "[AKF] Feld "
                .. tostring(farmlandId)
            )

            local result =
                AKFFieldScanner.scanField(field)

            local reputation =
                AKFReputationCalculator.calculate(
                    result
                )

            farmScore = farmScore + reputation
            fieldCount = fieldCount + 1

            AKFDebug.log(
                "reputation = "
                .. tostring(reputation)
            )

            AKFDebug.log(
                "fertPct = "
                .. tostring(result.fertPct)
            )

            AKFDebug.log(
                "limePct = "
                .. tostring(result.limePct)
            )

            AKFDebug.log(
                "plowPct = "
                .. tostring(result.plowPct)
            )

            AKFDebug.log(
                "weedsPenalizingPct = "
                .. tostring(result.weedsPenalizingPct)
            )

            AKFDebug.log(
                "stonePct = "
                .. tostring(result.stonePct)
            )

            AKFDebug.log("-----")

        end
    end

    if fieldCount > 0 then

        AKFDebug.log(
            "farmScore = "
            .. tostring(farmScore / fieldCount)
        )

    end

    AKFDebug.log("===== AKF ENDE =====")

end

-------------------------------------------------
-- CONSOLE COMMAND
-------------------------------------------------

FSBaseMission.onStartMission =
    Utils.appendedFunction(
        FSBaseMission.onStartMission,
        function()

            if AKFDebug.DEBUG then

                addConsoleCommand(
                    "gsAKFTest",
                    "Run AKF field scanner test",
                    "test",
                    AKFDebug
                )

            end

        end
    )