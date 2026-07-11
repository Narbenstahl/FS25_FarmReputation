FarmReputation = {

    hudEditMode = false

}

function FarmReputation:loadMap()

    --FRDebug.log(
    --    "FarmReputation LOADMAP"
    --)

end

function FarmReputation:update(dt)

    if g_currentMission == nil
    or g_currentMission.environment == nil then
        return
    end

    local month =
        g_currentMission.environment.currentPeriod

    AKFFarmEvaluationManager.checkMonth(
        month
    )

    AKFFarmEvaluationManager.update()

end


function FarmReputation:keyEvent(
    unicode,
    sym,
    modifier,
    isDown
)

    if isDown and sym == Input.KEY_f9 then

        self.hudEditMode =
            not self.hudEditMode

        g_inputBinding:setShowMouseCursor(
            self.hudEditMode
        )
	
        local vehicle = nil

        if g_localPlayer ~= nil
        and g_localPlayer.getCurrentVehicle ~= nil then

            vehicle =
                g_localPlayer:getCurrentVehicle()

        end

        if vehicle ~= nil
        and vehicle.spec_enterable ~= nil
        and vehicle.spec_enterable.cameras ~= nil then

            for _, camera in pairs(
                vehicle.spec_enterable.cameras
            ) do

                if self.hudEditMode then

                    camera.frOldAllowTranslation =
                        camera.allowTranslation

                    camera.frOldIsRotatable =
                        camera.isRotatable

                    camera.allowTranslation =
                        false

                    camera.isRotatable =
                        false

                else

                    camera.allowTranslation =
                        camera.frOldAllowTranslation ~= false

                    camera.isRotatable =
                        camera.frOldIsRotatable ~= false

                end

            end

        end

       -- print(
       --     "[FarmReputation] HUD EDIT MODE: "
       --     .. tostring(self.hudEditMode)
       -- )

    end

end

addModEventListener(
    FarmReputation
)

--print(
--    "[FarmReputation] LOADED"
--)