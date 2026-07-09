FarmReputationFrame = {}

local FarmReputationFrame_mt =
    Class(
        FarmReputationFrame,
        TabbedMenuFrameElement
    )

function FarmReputationFrame.new()

    local self =
        TabbedMenuFrameElement.new(
        nil,
        FarmReputationFrame_mt
        )

        self.currentPage = 1
        self.selectedContractorIndex = 1
        self.contractorNames = {}
    return self

end

function FarmReputationFrame:initialize()

	
end

function FarmReputationFrame:onFrameOpen()

	-------------------------------------------------
    -- FELDANALYSE AKTUALISIEREN
    -------------------------------------------------

	AKFReputationCalculator.calculateFarmScore()

    local reputation =
        ReputationManager.get()

    local currentRank =
        ReputationManager.getRankData()

    local nextRank = nil

    for _, rank in ipairs(
        ReputationManager.ranks
    ) do

        if rank.min > reputation then

            nextRank = rank
            break

        end

    end

    local reputationText =
        tostring(reputation)

    local remainingRep = 0

    if nextRank ~= nil then

        reputationText =
            tostring(reputation)
            .. " / "
            .. tostring(nextRank.min)

        remainingRep =
            nextRank.min - reputation

    else

        reputationText =
            tostring(reputation)
            .. " / MAX"

    end

    if self.rankText ~= nil then
        self.rankText:setText(
            currentRank.title
        )
    end

    if self.reputationText ~= nil then
        self.reputationText:setText(
            reputationText
        )
    end

    if self.remainingRepText ~= nil then

        if nextRank ~= nil then

            self.remainingRepText:setText(
                tostring(remainingRep)
            )

        else

            self.remainingRepText:setText(
                "-"
            )

        end

    end

    if self.nextRankText ~= nil then

        if nextRank ~= nil then

            self.nextRankText:setText(
                nextRank.title
            )

        else

            self.nextRankText:setText(
                g_i18n:getText("fr_rank_max")
            )

        end

    end

    if self.maxContractsText ~= nil then

        self.maxContractsText:setText(
            tostring(
                currentRank.missionLimit
            )
        )

    end

	if self.maxContractValueText ~= nil then

		if currentRank.maxContractValue ==
			math.huge then

			self.maxContractValueText:setText(
				g_i18n:getText("fr_unlimited")
			)

		else

			self.maxContractValueText:setText(
				tostring(currentRank.maxContractValue)
				.. " "
				.. g_i18n:getText("fr_currency")
			)

		end

	end

    if self.bonusPercentText ~= nil then

		self.bonusPercentText:setText(
			tostring(
				math.floor(
					currentRank.rewardBonus
					* 100
				)
			)
			.. " %"
		)

	end

    if nextRank ~= nil then

        if self.nextMissionLimitText ~= nil then

            self.nextMissionLimitText:setText(
                tostring(
                    nextRank.missionLimit
                )
            )

        end

        if self.nextMaxValueText ~= nil then

            if nextRank.maxContractValue ==
                math.huge then

                self.nextMaxValueText:setText(
                    g_i18n:getText("fr_unlimited")
                )

            else

                self.nextMaxValueText:setText(
					tostring(nextRank.maxContractValue)
					.. " "
					.. g_i18n:getText("fr_currency")
				)

            end

        end

        if self.nextBonusText ~= nil then

            self.nextBonusText:setText(
                tostring(
                    math.floor(
                        nextRank.rewardBonus
                        * 100
                    )
                )
                .. " %"
            )

        end

    end
	
	-------------------------------------------------
	-- FREISCHALTUNGEN
	-------------------------------------------------

	if self.unlockCurrentRankText ~= nil then
		self.unlockCurrentRankText:setText(
			currentRank.title
		)
	end

	if nextRank ~= nil then

		if self.unlockNextRankText ~= nil then
			self.unlockNextRankText:setText(
				nextRank.title
			)
		end

		if self.unlockNextMissionText ~= nil then
			self.unlockNextMissionText:setText(
				tostring(nextRank.missionLimit)
				.. " "
				.. g_i18n:getText("fr_activeContracts")
			)
		end

				if self.unlockNextBonusText ~= nil then
					self.unlockNextBonusText:setText(
						tostring(
							math.floor(
								nextRank.rewardBonus * 100
							)
						)
						.. " "
						.. g_i18n:getText("fr_percent")
						.. " "
						.. g_i18n:getText("fr_rewardBonus")
					)
				end

				if self.unlockNextValueText ~= nil then

					if nextRank.maxContractValue == math.huge then

						self.unlockNextValueText:setText(
							g_i18n:getText("fr_unlimitedContractValue")
						)

					else

						self.unlockNextValueText:setText(
							tostring(
								nextRank.maxContractValue
							)
							.. " "
							.. g_i18n:getText("fr_currency")
							.. " "
							.. g_i18n:getText("fr_contractValue")
						)

					end

				end

			end

	if self.unlockCurrentMissionText ~= nil then
		self.unlockCurrentMissionText:setText(
			tostring(currentRank.missionLimit)
			.. " "
			.. g_i18n:getText("fr_activeContracts")
		)
	end

	if self.unlockCurrentBonusText ~= nil then
		self.unlockCurrentBonusText:setText(
			tostring(
				math.floor(
					currentRank.rewardBonus * 100
				)
			)
			.. " "
			.. g_i18n:getText("fr_percent")
			.. " "
			.. g_i18n:getText("fr_rewardBonus")
		)
	end

	if self.unlockCurrentValueText ~= nil then

		if currentRank.maxContractValue == math.huge then

			self.unlockCurrentValueText:setText(
				g_i18n:getText("fr_unlimitedContractValue")
			)

		else

			self.unlockCurrentValueText:setText(
				tostring(
					currentRank.maxContractValue
				)
				.. " "
				.. g_i18n:getText("fr_currency")
				.. " "
				.. g_i18n:getText("fr_contractValue")
			)

		end

	end
	
	-------------------------------------------------
	-- CONTRACTOR LIST
	-------------------------------------------------

	local contractors =
		ReputationManager.getAllContractorData()
	
	self.contractorNames = {}

	if contractors ~= nil then

		for contractorName, _ in pairs(contractors) do
			table.insert(
				self.contractorNames,
				contractorName
			)
		end

		table.sort(
			self.contractorNames
		)

	end
	
	if self.contractorListText ~= nil then

		local contractorList = ""

		if contractors ~= nil then

			for index, contractorName in ipairs(
				self.contractorNames
		) do

		if index == self.selectedContractorIndex then

			contractorList =
				contractorList
				.. "> "
				.. contractorName
				.. "\n\n"

		else

			contractorList =
				contractorList
				.. "  "
				.. contractorName
			.. "\n\n"

		end

	end

		end

		if contractorList == "" then
			contractorList =
				g_i18n:getText("fr_noContractors")
		end

		self.contractorListText:setText(
			contractorList
		)

	end
	
	-------------------------------------------------
	-- BETRIEBSBEWERTUNG
	-------------------------------------------------
	
	if AKFReputationCalculator.isEnabled() then
	
	if self.evaluationLastText ~= nil then
		self.evaluationLastText:setText(
			AKFFarmEvaluationManager.getLastEvaluationText()
		)
	end

	if self.evaluationScoreText ~= nil then
		self.evaluationScoreText:setText(
			tostring(
				AKFFarmEvaluationManager.lastFarmScore
			) .. " / 100"
		)
	end

	if self.evaluationStatusText ~= nil then
		self.evaluationStatusText:setText(
			AKFFarmEvaluationManager.getLastStatus()
		)
	end

	if self.evaluationRepText ~= nil then
		self.evaluationRepText:setText(
			string.format(
				"%+d %s",
				AKFFarmEvaluationManager.lastReputation,
				g_i18n:getText("fr_rep")
			)
		)
	end
	
	else

    -- Platzhalter

		if self.evaluationLastText ~= nil then
			self.evaluationLastText:setText(
				g_i18n:getText("fr_akfDisabled")
			)
		end

		if self.evaluationScoreText ~= nil then
			self.evaluationScoreText:setText("-")
		end

		if self.evaluationStatusText ~= nil then
			self.evaluationStatusText:setText("-")
		end

		if self.evaluationRepText ~= nil then
			self.evaluationRepText:setText("-")
		end

	end
	-------------------------------------------------
	-- FELDANALYSE
	-------------------------------------------------

	if self.weedAnalysisText ~= nil then
		self.weedAnalysisText:setText(
		AKFFarmEvaluationManager.getWeedText()
	)
	end

	if self.stoneAnalysisText ~= nil then
		self.stoneAnalysisText:setText(
		AKFFarmEvaluationManager.getStoneText()
	)
	end

	if self.limeAnalysisText ~= nil then
		self.limeAnalysisText:setText(
		AKFFarmEvaluationManager.getLimeText()
	)
	end

	if self.fertilizerAnalysisText ~= nil then
		self.fertilizerAnalysisText:setText(
		AKFFarmEvaluationManager.getFertilizerText()
	)
	end

	if self.plowAnalysisText ~= nil then
		self.plowAnalysisText:setText(
		AKFFarmEvaluationManager.getPlowText()
	)
	end
		
	-------------------------------------------------
	-- SELECTED CONTRACTOR
	-------------------------------------------------

	local selectedContractor = nil

		if #self.contractorNames > 0 then
			selectedContractor =
			self.contractorNames[
				self.selectedContractorIndex
			]
	end

	if selectedContractor ~= nil then

		if self.contractorRankText ~= nil then
			self.contractorRankText:setText(
				ReputationManager.getContractorRank(
					selectedContractor
				)
			)
		end

		if self.contractorRepText ~= nil then
			self.contractorRepText:setText(
				tostring(
					ReputationManager.getContractorReputation(
						selectedContractor
					)
				)
			)
		end

		if self.contractorAcceptedText ~= nil then
			self.contractorAcceptedText:setText(
				tostring(
					ReputationManager.getContractorAccepted(
						selectedContractor
					)
				)
			)
		end

		if self.contractorCompletedText ~= nil then
			self.contractorCompletedText:setText(
				tostring(
					ReputationManager.getContractorCompleted(
						selectedContractor
					)
				)
			)
		end

		if self.contractorCancelledText ~= nil then
		self.contractorCancelledText:setText(
			tostring(
				ReputationManager.getContractorCancelled(
					selectedContractor
				)
			)
		)
	end

	-------------------------------------------------
	-- CONTRACTOR BONUS
	-------------------------------------------------

	local baseLimit =
		ReputationManager.getMaxContractValue()

	local bonusLimit =
		ReputationManager.getContractorMaxContractBonus(
			selectedContractor
		)

	local totalLimit =
		ReputationManager.getContractorMaxContractValue(
			selectedContractor
		)

	if self.contractorBaseLimitText ~= nil then

		if baseLimit == math.huge then
			self.contractorBaseLimitText:setText(
				g_i18n:getText("fr_unlimited")
			)
		else
			self.contractorBaseLimitText:setText(
				string.format(
					"%d %s",
					baseLimit,
					g_i18n:getText("fr_currency")
				)
			)
		end

	end

	if self.contractorBonusLimitText ~= nil then
		self.contractorBonusLimitText:setText(
			string.format(
				"+%d %s",
				bonusLimit,
				g_i18n:getText("fr_currency")
			)
		)
	end

	if self.contractorMaxLimitText ~= nil then

		if totalLimit == math.huge then
			self.contractorMaxLimitText:setText(
				g_i18n:getText("fr_unlimited")
			)
		else
			self.contractorMaxLimitText:setText(
				string.format(
					"%d %s",
					totalLimit,
					g_i18n:getText("fr_currency")
				)
			)
		end

	end

	end

	self:updatePage()
	self:updateMenuButtons()
	end

	-------------------------------------------------
	-- NEXT PAGE
	-------------------------------------------------

	function FarmReputationFrame:nextPage()

		self.currentPage =
			self.currentPage + 1

		if self.currentPage > 5 then
			self.currentPage = 1
		end

		self:updatePage()
		self:setMenuButtonInfoDirty()
	end

	-------------------------------------------------
	-- PREVIOUS PAGE
	-------------------------------------------------

	function FarmReputationFrame:previousPage()

		self.currentPage =
			self.currentPage - 1

		if self.currentPage < 1 then
			self.currentPage = 5
		end

		self:updatePage()
		self:setMenuButtonInfoDirty()
	end

	-------------------------------------------------
	-- UPDATE PAGE
	-------------------------------------------------

	function FarmReputationFrame:updatePage()

		local pageNames = {
			g_i18n:getText("fr_page_career"),
			g_i18n:getText("fr_page_unlocks"),
			g_i18n:getText("fr_page_contractors"),
			g_i18n:getText("fr_page_farmEvaluation"),
			g_i18n:getText("fr_page_fieldAnalysis")
		}

		if self.pageTitleText ~= nil then
			self.pageTitleText:setText(
				pageNames[self.currentPage]
			)
	end
	-------------------------------------------------
	-- PAGE VISIBILITY
	-------------------------------------------------

	if self.careerPage ~= nil then
		self.careerPage:setVisible(
			self.currentPage == 1
		)
	end

	if self.unlockPage ~= nil then
		self.unlockPage:setVisible(
			self.currentPage == 2
		)
	end

	if self.contractorPage ~= nil then
		self.contractorPage:setVisible(
			self.currentPage == 3
		)
	end

	if self.evaluationPage ~= nil then
		self.evaluationPage:setVisible(
			self.currentPage == 4
			and AKFReputationCalculator.isEnabled()
		)
	end

	if self.evaluationDisabledPage ~= nil then
		self.evaluationDisabledPage:setVisible(
			self.currentPage == 4
			and not AKFReputationCalculator.isEnabled()
		)
	end

	if self.fieldAnalysisPage ~= nil then
		self.fieldAnalysisPage:setVisible(
			self.currentPage == 5
			and AKFReputationCalculator.isEnabled()
		)
	end

	if self.fieldAnalysisDisabledPage ~= nil then
		self.fieldAnalysisDisabledPage:setVisible(
			self.currentPage == 5
			and not AKFReputationCalculator.isEnabled()
		)
	end
	
	------------------------------------------------
	-- BETRIEBSBEWERTUNG DEAKTIVIERT
	------------------------------------------------

	if self.evaluationDisabledPage ~= nil 
		and not AKFReputationCalculator.isEnabled() then

		local plowStatus =
			AKFReputationCalculator.isPlowingEnabled()
			and g_i18n:getText("fr_status_active")
			or g_i18n:getText("fr_status_missing")

		local stoneStatus =
			AKFReputationCalculator.isStonesEnabled()
			and g_i18n:getText("fr_status_active")
			or g_i18n:getText("fr_status_missing")

		local weedStatus =
			AKFReputationCalculator.isWeedsEnabled()
			and g_i18n:getText("fr_status_active")
			or g_i18n:getText("fr_status_missing")

		if self.plowRequiredText ~= nil then
			self.plowRequiredText:setText(
				plowStatus
				.. "  "
				.. g_i18n:getText("fr_requirement_plowing")
			)
		end

		if self.stoneRequiredText ~= nil then
			self.stoneRequiredText:setText(
				stoneStatus
				.. "  "
				.. g_i18n:getText("fr_requirement_stones")
			)
		end

		if self.weedRequiredText ~= nil then
			self.weedRequiredText:setText(
				weedStatus
				.. "  "
				.. g_i18n:getText("fr_requirement_weeds")
			)
		end

	end
	
	self:updateMenuButtons()
end

	-------------------------------------------------
	-- UPDATE MENU BUTTONS
	-------------------------------------------------

	function FarmReputationFrame:updateMenuButtons()

		if self.currentPage == 3 then

			self:setMenuButtonInfo({

				{
					inputAction = InputAction.MENU_BACK
				},

				{
					inputAction = InputAction.FR_PREVIOUS_PAGE,
					text = "input_FR_PREVIOUS_PAGE",
					callback = function()
						self:previousPage()
					end
				},

				{
					inputAction = InputAction.FR_NEXT_PAGE,
					text = "input_FR_NEXT_PAGE",
					callback = function()
						self:nextPage()
					end
				},

				{
					inputAction = InputAction.FR_CONTRACTOR_UP,
					text = "input_FR_CONTRACTOR_UP",
					callback = function()

						self.selectedContractorIndex =
							math.max(
								1,
								self.selectedContractorIndex - 1
							)

						self:onFrameOpen()

					end
				},

				{
					inputAction = InputAction.FR_CONTRACTOR_DOWN,
					text = "input_FR_CONTRACTOR_DOWN",
					callback = function()

						self.selectedContractorIndex =
							math.min(
								#self.contractorNames,
								self.selectedContractorIndex + 1
							)

						self:onFrameOpen()

					end
				}

			})

		else

			self:setMenuButtonInfo({

				{
					inputAction = InputAction.MENU_BACK
				},

				{
					inputAction = InputAction.FR_PREVIOUS_PAGE,
					text = "input_FR_PREVIOUS_PAGE",
					callback = function()
						self:previousPage()
					end
				},

				{
					inputAction = InputAction.FR_NEXT_PAGE,
					text = "input_FR_NEXT_PAGE",
					callback = function()
						self:nextPage()
					end
				}

			})

		end

		self:setMenuButtonInfoDirty()

	end
	
	-------------------------------------------------
	-- DRAW REPUTATION BAR
	-------------------------------------------------

	function FarmReputationFrame:onDrawReputationBar(
		element
		)

		if element == nil then
			return
		end

		local reputation =
			ReputationManager.get()

		local currentRank =
			ReputationManager.getRankData()

		local nextRank = nil

		for _, rank in ipairs(
			ReputationManager.ranks
		) do

			if rank.min > reputation then

				nextRank = rank
				break

			end

		end

		if nextRank == nil then

			drawFilledRect(
				element.absPosition[1],
				element.absPosition[2],
				element.absSize[1],
				element.absSize[2],
				0.0,
				0.7,
				0.0,
				0.9
			)

			return

		end

		local previousMin =
			currentRank.min or 0

		local needed =
			nextRank.min - previousMin

		local progress =
			reputation - previousMin

		local pct =
			math.max(
				0,
				math.min(
					100,
					(progress / needed) * 100
				)
			)

		local x =
			element.absPosition[1]

		local y =
			element.absPosition[2]

		local w =
			element.absSize[1]

		local h =
			element.absSize[2]

		drawFilledRect(
			x,
			y,
			w,
			h,
			0.15,
			0.15,
			0.15,
			0.7
		)

		drawFilledRect(
			x,
			y,
			w * (pct / 100),
			h,
			0.0,
			0.7,
			0.0,
			0.9
		)

	end
	
	-------------------------------------------------
	-- KEY EVENT
	-------------------------------------------------

	function FarmReputationFrame:keyEvent(
		unicode,
		sym,
		modifier,
		isDown
	)

		if not isDown then
			return
		end

		if self.currentPage ~= 3 then
			return
		end

		if sym == Input.KEY_up then

			self.selectedContractorIndex =
				math.max(
					1,
					self.selectedContractorIndex - 1
				)

			self:onFrameOpen()

			return true

		elseif sym == Input.KEY_down then

			self.selectedContractorIndex =
				math.min(
					#self.contractorNames,
					self.selectedContractorIndex + 1
				)

			self:onFrameOpen()

			return true

		end

		return false

	end
	
function FarmReputationFrame:onFrameClose()

    FarmReputationFrame:superClass()
        .onFrameClose(self)

end