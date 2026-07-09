RankNotificationManager = {}

-------------------------------------------------
-- DATA
-------------------------------------------------

RankNotificationManager.visible = false
RankNotificationManager.lines = {}
RankNotificationManager.endTime = 0
RankNotificationManager.box = nil

RankNotificationManager.pendingRank = nil
RankNotificationManager.pendingBonus = nil
-------------------------------------------------
-- FORMAT MONEY
-------------------------------------------------

local function formatMoney(value)

    if value == math.huge then
        return g_i18n:getText("fr_unlimited")
    end

    local formatted =
        tostring(value):reverse():gsub("(%d%d%d)", "%1."):reverse()

    if formatted:sub(1, 1) == "." then
        formatted = formatted:sub(2)
    end

    return formatted .. " " .. g_i18n:getText("fr_currency")

end

-------------------------------------------------
-- CREATE BOX
-------------------------------------------------

function RankNotificationManager.createBox()

    if g_currentMission == nil then
        return
    end

    local infoDisplay =
        g_currentMission.hud.infoDisplay

    RankNotificationManager.box =
        infoDisplay:createBox(
            InfoDisplayKeyValueBox
        )

    RankNotificationManager.box.canDraw =
        function(self)

            return RankNotificationManager.visible

        end

end

-------------------------------------------------
-- SHOW RANK UP
-------------------------------------------------

function RankNotificationManager.showRankUp(
    oldRank,
    newRank
)

    RankNotificationManager.visible = true
    RankNotificationManager.endTime =
        g_time + 15000

    if RankNotificationManager.box ~= nil then

        RankNotificationManager.box:clear()

        RankNotificationManager.box:setTitle(
            g_i18n:getText("fr_notification_rankUpTitle")
        )

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_rank"),
            newRank.title
        )

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_notification_addedContracts"),
            tostring(
                newRank.missionLimit -
                oldRank.missionLimit
            )
        )

        if oldRank.maxContractValue ~= math.huge then

            RankNotificationManager.box:addLine(
                g_i18n:getText("fr_notification_addedContractValue"),
                formatMoney(
                    newRank.maxContractValue -
                    oldRank.maxContractValue
                )
            )

        end

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_current"),
            ""
        )

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_contracts"),
            tostring(
                newRank.missionLimit
            )
        )

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_contractValue"),
            formatMoney(
                newRank.maxContractValue
            )
        )

    end

end

-------------------------------------------------
-- SHOW RANK DOWN
-------------------------------------------------

function RankNotificationManager.showRankDown(
    oldRank,
    newRank
)

    RankNotificationManager.visible = true
    RankNotificationManager.endTime =
        g_time + 12000

    if RankNotificationManager.box ~= nil then

        RankNotificationManager.box:clear()

        RankNotificationManager.box:setTitle(
            g_i18n:getText("fr_notification_rankDownTitle")
        )

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_rank"),
            newRank.title
        )

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_notification_removedContracts"),
            tostring(
                oldRank.missionLimit -
                newRank.missionLimit
            )
        )

        if oldRank.maxContractValue ~= math.huge then

            RankNotificationManager.box:addLine(
                g_i18n:getText("fr_notification_removedContractValue"),
                formatMoney(
                    oldRank.maxContractValue -
                    newRank.maxContractValue
                )
            )

        end

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_current"),
            ""
        )

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_contracts"),
            tostring(
                newRank.missionLimit
            )
        )

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_contractValue"),
            formatMoney(
                newRank.maxContractValue
            )
        )

    end

end

-------------------------------------------------
-- SHOW BONUS
-------------------------------------------------

function RankNotificationManager.showBonus(
    rankName,
    bonus
)

    RankNotificationManager.visible = true
    RankNotificationManager.endTime =
        g_time + 30000

    if RankNotificationManager.box ~= nil then
        RankNotificationManager.box:clear()

        RankNotificationManager.box:setTitle(
            g_i18n:getText("fr_notification_bonusTitle")
        )

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_rank"),
            tostring(rankName)
        )

        RankNotificationManager.box:addLine(
            g_i18n:getText("fr_bonus"),
            tostring(bonus)
			.. " "
			.. g_i18n:getText("fr_currency")
        )

    end

end

-------------------------------------------------
-- UPDATE
-------------------------------------------------

function RankNotificationManager.update()

-------------------------------------------------
-- PENDING BONUS
-------------------------------------------------

    if RankNotificationManager.pendingBonus ~= nil then

        RankNotificationManager.showBonus(
            RankNotificationManager.pendingRank,
            RankNotificationManager.pendingBonus
        )

        RankNotificationManager.pendingRank = nil
        RankNotificationManager.pendingBonus = nil

    end

    if not RankNotificationManager.visible then
        return
    end

    if g_time >= RankNotificationManager.endTime then

        RankNotificationManager.visible = false

    end

end

-------------------------------------------------
-- REGISTER
-------------------------------------------------

FSBaseMission.update =
    Utils.appendedFunction(
        FSBaseMission.update,
        RankNotificationManager.update
    )

FSBaseMission.onStartMission =
    Utils.appendedFunction(
        FSBaseMission.onStartMission,
        function()

            RankNotificationManager.createBox()

        end
    )