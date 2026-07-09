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
		
		local iconPath =
    Utils.getFilename(
        "textures/farmer_icon.dds",
        modDirectory
    )

	display.farmRepIcon =
		Overlay.new(
			iconPath,
			0,
			0,
			0.02,
			0.02
    )
	
	GameInfoDisplay.farmRepIcon =
    display.farmRepIcon

	frPrint(
		"ICON LOADED: "
		.. tostring(display.farmRepIcon ~= nil)
	)

   

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
		g_i18n:getText("fr_hud_contracts")
		.. ": "
		.. tostring(activeMissions)
		.. "/"
		.. tostring(
			ReputationManager.getMissionLimit()
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
    self:scalePixelToScreenWidth(300),
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
		self:scalePixelToScreenWidth(300)

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

	-- oben
	--drawLine2D(
	--	leftSeparatorX,
	--	baseY + hudHeight,
	--	leftSeparatorX + hudWidth,
	--	baseY + hudHeight,
	--	1,
	--	borderColor,
	--	borderColor,
	--	borderColor,
	--	borderAlpha
	--)
	
	-- unten
	--drawLine2D(
	--	leftSeparatorX,
	--	baseY,
	--	leftSeparatorX + hudWidth,
	--	baseY,
	--	1,
	--	borderColor,
	--	borderColor,
	--	borderColor,
	--	borderAlpha
	--)

	-- links
	--drawLine2D(
	--	leftSeparatorX,
	--	baseY,
	--	leftSeparatorX,
	--	baseY + hudHeight,
	--	1,
	--	borderColor,
	--	borderColor,
	--	borderColor,
	--	borderAlpha
	--)

	-- rechts
	--drawLine2D(
	--	leftSeparatorX + hudWidth,
	--	baseY,
	--	leftSeparatorX + hudWidth,
	--	baseY + hudHeight,
	--	1,
	--	borderColor,
	--	borderColor,
	--	borderColor,
	--	borderAlpha
	--)
	
	-------------------------------------------------
	-- ICON
	-------------------------------------------------

	local iconSize =
    self:scalePixelToScreenHeight(55)

	local iconX =
    leftSeparatorX
    + self:scalePixelToScreenWidth(8)

	local iconY =
    baseY
    + self:scalePixelToScreenHeight(2)

	if GameInfoDisplay.farmRepIcon ~= nil then

    GameInfoDisplay.farmRepIcon:setDimension(
        iconSize,
        iconSize
    )

    GameInfoDisplay.farmRepIcon:setPosition(
        iconX,
        iconY
    )

    GameInfoDisplay.farmRepIcon:render()

end

    -------------------------------------------------
    -- TEXT POSITION
    -------------------------------------------------

    local posX =
        leftSeparatorX
        + self:scalePixelToScreenWidth(110)

    local posY =
    baseY
    + self:scalePixelToScreenHeight(30)

    -------------------------------------------------
    -- TEXT
    -------------------------------------------------

    setTextAlignment(
        RenderText.ALIGN_LEFT
    )

    setTextBold(true)

    renderText(
        posX,
        posY + self:scalePixelToScreenHeight(11),
        self:scalePixelToScreenHeight(14),
        rank
    )
	
	setTextBold(false)

    renderText(
        posX,
        posY
        - self:scalePixelToScreenHeight(11),
        self:scalePixelToScreenHeight(12),
        tostring(currentRep)
		.. "/"
		.. tostring(nextTarget)
		.. " "
		.. g_i18n:getText("fr_rep")
		)

    renderText(
        posX,
        posY
        - self:scalePixelToScreenHeight(22),
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