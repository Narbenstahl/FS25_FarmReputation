FarmReputationDisplay = {

    STRETCH_SIZE = 240,

    posX = 0.875,
    posY = 0.85,
	

    dragging = false,

    dragOffsetX = 0,
    dragOffsetY = 0

}
	
	FarmReputationDisplay.userId = nil
	
	local modDirectory =
    g_currentModDirectory

-------------------------------------------------
-- DEBUG
-------------------------------------------------

local function frPrint(text)

    FRDebug.log(text)

end

-------------------------------------------------
-- GET NEXT TARGET
-------------------------------------------------

local function getNextTarget(rep)

    if rep < 250 then

        return 250

    elseif rep < 750 then

        return 750

    elseif rep < 1500 then

        return 1500

    elseif rep < 3000 then

        return 3000

    elseif rep < 6000 then

        return 6000

    end

    return rep

end

-------------------------------------------------
-- HUD EXTEND
-------------------------------------------------

	function FarmReputationDisplay:hudCreateDisplayComponents(
    superFunc,
    uiScale
	)

    superFunc(self, uiScale)

    local display =
        self.gameInfoDisplay

   

    frPrint(
        "FARM REPUTATION HUD EXTENDED"
    )

	end

	-------------------------------------------------
	-- DRAW
	-------------------------------------------------

function FarmReputationDisplay:draw(
    superFunc
)

    superFunc(self)
	

    -------------------------------------------------
    -- BACKGROUND STRETCH
    -------------------------------------------------

    self.infoBgScale.width =
        self:scalePixelToScreenWidth(
            FarmReputationDisplay.STRETCH_SIZE
        )

    self.infoBgScale.offsetX =
        -self:scalePixelToScreenWidth(
            FarmReputationDisplay.STRETCH_SIZE
        )

   -- self.infoBgScale:render()

    -------------------------------------------------
    -- DATA
    -------------------------------------------------

    local currentRep =
        ReputationManager.get()

    local rank =
        ReputationManager.getRank()

    local nextTarget =
        getNextTarget(currentRep)

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

	local missionText =
    string.format(
        "%d / %d %s",
        activeMissions,
        ReputationManager.getMissionLimit(),
        g_i18n:getText("fr_hud_contracts")
    )

    -------------------------------------------------
    -- REFERENCE POSITION
    -------------------------------------------------
	
	local baseX =
    FarmReputationDisplay.posX

	local baseY =
    FarmReputationDisplay.posY

    -------------------------------------------------
    -- SEPARATORS
    -------------------------------------------------
	
	local leftSeparatorX = baseX

	local rightSeparatorX =
    leftSeparatorX
    + self:scalePixelToScreenWidth(220)


	local separatorTop =
    baseY
    + self:scalePixelToScreenHeight(55)

	local separatorBottom =
    baseY

	
	-------------------------------------------------
	-- HUD BACKGROUND
	-------------------------------------------------

	drawFilledRect(
    leftSeparatorX,
    baseY,
    self:scalePixelToScreenWidth(210),
    self:scalePixelToScreenHeight(65),
    0,
    0,
    0,
    0.45
	)
	
	-------------------------------------------------
	-- HUD BORDER
	-------------------------------------------------

	local hudWidth =
		self:scalePixelToScreenWidth(210)

	local hudHeight =
		self:scalePixelToScreenHeight(65)

	FarmReputationDisplay.hudWidth =
    hudWidth

	FarmReputationDisplay.hudHeight =
    hudHeight

	FarmReputationDisplay.hudX =
    baseX

	FarmReputationDisplay.hudY =
    baseY
	
	local mouseX =
    g_inputBinding.mousePosXLast

	local mouseY =
    g_inputBinding.mousePosYLast

	if mouseX ~= nil
	and mouseY ~= nil then

    local ctrlPressed =
        Input.isKeyPressed(
            Input.KEY_lctrl
        )
        or
        Input.isKeyPressed(
            Input.KEY_rctrl
        )

    local altPressed =
        Input.isKeyPressed(
            Input.KEY_lalt
        )
        or
        Input.isKeyPressed(
            Input.KEY_ralt
        )

    local mouseOverHud =
        mouseX >= baseX
        and mouseX <= baseX + hudWidth
        and mouseY >= baseY
        and mouseY <= baseY + hudHeight

    if FarmReputation.hudEditMode
	and mouseOverHud
	and Input.isMouseButtonPressed(
    Input.MOUSE_BUTTON_LEFT
	)
	and not FarmReputationDisplay.dragging then

        FarmReputationDisplay.dragging = true

        FarmReputationDisplay.dragOffsetX =
            mouseX - baseX

        FarmReputationDisplay.dragOffsetY =
            mouseY - baseY

    end

    if FarmReputationDisplay.dragging then

    if Input.isMouseButtonPressed(
        Input.MOUSE_BUTTON_LEFT
    ) then

        FarmReputationDisplay.posX =
            mouseX
            - FarmReputationDisplay.dragOffsetX

        FarmReputationDisplay.posY =
            mouseY
            - FarmReputationDisplay.dragOffsetY

    else

        FarmReputationDisplay.dragging = false

        --print(
        --    "[FarmReputation] NEW POS: "
        --    .. tostring(FarmReputationDisplay.posX)
        --    .. " / "
        --    .. tostring(FarmReputationDisplay.posY)
        --)

			end

		end

	end
	
	local borderColor = 0.35
	local borderAlpha = 0.85

    -------------------------------------------------
    -- TEXT POSITION
    -------------------------------------------------

    local posX =
        leftSeparatorX
        + self:scalePixelToScreenWidth(15)

    local posY =
    baseY
    + self:scalePixelToScreenHeight(28)

    -------------------------------------------------
    -- TEXT
    -------------------------------------------------

    setTextAlignment(
        RenderText.ALIGN_LEFT
    )

    setTextBold(true)

    renderText(
        posX,
        posY + self:scalePixelToScreenHeight(13),
        self:scalePixelToScreenHeight(14),
        rank
    )
	
	setTextBold(false)

    renderText(
		posX,
		posY - self:scalePixelToScreenHeight(9),
		self:scalePixelToScreenHeight(12),
		string.format(
			"%d / %d %s",
			currentRep,
			nextTarget,
			g_i18n:getText("fr_rep")
		)
	)

    renderText(
        posX,
        posY
        - self:scalePixelToScreenHeight(25),
        self:scalePixelToScreenHeight(12),
        missionText
    )

end

-------------------------------------------------
-- REGISTER
-------------------------------------------------

HUD.createDisplayComponents =
    Utils.overwrittenFunction(
        HUD.createDisplayComponents,
        FarmReputationDisplay.hudCreateDisplayComponents
    )

GameInfoDisplay.draw =
    Utils.overwrittenFunction(
        GameInfoDisplay.draw,
        FarmReputationDisplay.draw
    )

--frPrint(
--    "FarmReputationDisplay LOADED"
--)