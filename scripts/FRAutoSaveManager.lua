FRAutoSaveManager = {}

local FRAutoSaveManager_mt = Class(FRAutoSaveManager)

function FRAutoSaveManager.new()

    local self = setmetatable({}, FRAutoSaveManager_mt)

    self.isDirty = false

    self.saveDelay = 0
    self.saveInterval = 0

    -- Save 10 seconds after the last change
    self.delayTime = 10000

    -- Force a save every 5 minutes if there are unsaved changes
    self.intervalTime = 300000

    return self

end

-------------------------------------------------
-- CAN SAVE?
-------------------------------------------------

function FRAutoSaveManager:canSave()

    return g_currentMission ~= nil
        and g_currentMission.missionInfo ~= nil
        and g_currentMission.missionInfo.savegameDirectory ~= nil

end

-------------------------------------------------
-- MARK DATA AS CHANGED
-------------------------------------------------

function FRAutoSaveManager:markDirty()

    self.isDirty = true
    self.saveDelay = self.delayTime

end

-------------------------------------------------
-- SAVE
-------------------------------------------------

function FRAutoSaveManager:save()

    if not self:canSave() then
        return
    end

    SavegameManager.save()

    self.isDirty = false
    self.saveInterval = 0
    self.saveDelay = 0

end

-------------------------------------------------
-- UPDATE
-------------------------------------------------

function FRAutoSaveManager:update(dt)

    if not self.isDirty then
        return
    end

    self.saveInterval = self.saveInterval + dt

    -------------------------------------------------
    -- DELAY SAVE
    -------------------------------------------------

    if self.saveDelay > 0 then

        self.saveDelay = self.saveDelay - dt

        if self.saveDelay <= 0 then

            self:save()
            return

        end

    end

    -------------------------------------------------
    -- SAFETY SAVE
    -------------------------------------------------

    if self.saveInterval >= self.intervalTime then

        self:save()

    end

end

-------------------------------------------------
-- FORCE SAVE
-------------------------------------------------

function FRAutoSaveManager:forceSave()

    if not self.isDirty then
        return
    end

    self:save()

end

-------------------------------------------------
-- RESET
-------------------------------------------------

function FRAutoSaveManager:reset()

    self.isDirty = false
    self.saveInterval = 0
    self.saveDelay = 0

end