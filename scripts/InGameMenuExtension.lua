InGameMenuExtension = {
    MOD_DIRECTORY = g_currentModDirectory
}

source(
    InGameMenuExtension.MOD_DIRECTORY ..
    "scripts/gui/FarmReputationFrame.lua"
)

--print("[FarmReputation] InGameMenuExtension LOADED")

local function fixInGameMenu(
    frame,
    pageName,
    uvs,
    position,
    predicateFunc
)

    local inGameMenu =
        g_gui.screenControllers[InGameMenu]

    for _, v in pairs({pageName}) do
        inGameMenu.controlIDs[v] = nil
    end

    inGameMenu[pageName] = frame

    inGameMenu.pagingElement:addElement(
        inGameMenu[pageName]
    )

    inGameMenu:exposeControlsAsFields(
        pageName
    )

    for i = 1,
        #inGameMenu.pagingElement.elements do

        local child =
            inGameMenu.pagingElement.elements[i]

        if child == inGameMenu[pageName] then

            table.remove(
                inGameMenu.pagingElement.elements,
                i
            )

            table.insert(
                inGameMenu.pagingElement.elements,
                position,
                child
            )

            break

        end

    end

    for i = 1,
        #inGameMenu.pagingElement.pages do

        local child =
            inGameMenu.pagingElement.pages[i]

        if child.element ==
            inGameMenu[pageName] then

            table.remove(
                inGameMenu.pagingElement.pages,
                i
            )

            table.insert(
                inGameMenu.pagingElement.pages,
                position,
                child
            )

            break

        end

    end

    inGameMenu.pagingElement:updateAbsolutePosition()
    inGameMenu.pagingElement:updatePageMapping()

    inGameMenu:registerPage(
        inGameMenu[pageName],
        position,
        predicateFunc
    )

    local iconFileName =
        Utils.getFilename(
            "images/menuIconFarmReputation.dds",
            InGameMenuExtension.MOD_DIRECTORY
        )

    inGameMenu:addPageTab(
        inGameMenu[pageName],
        iconFileName,
        GuiUtils.getUVs(uvs)
    )

    for i = 1, #inGameMenu.pageFrames do

        local child =
            inGameMenu.pageFrames[i]

        if child ==
            inGameMenu[pageName] then

            table.remove(
                inGameMenu.pageFrames,
                i
            )

            table.insert(
                inGameMenu.pageFrames,
                position,
                child
            )

            break

        end

    end

    inGameMenu:rebuildTabList()

end

local function loadedMission()

    --print(
    --    "[FarmReputation] Mission vollständig geladen"
    --)

    local frame =
        FarmReputationFrame.new()

    g_gui:loadGui(
        InGameMenuExtension.MOD_DIRECTORY ..
        "gui/FarmReputationFrame.xml",
        "FarmReputationFrame",
        frame,
        true
    )

    frame:initialize()

    fixInGameMenu(
        frame,
        "FarmReputationFrame",
        {0, 0, 1024, 1024},
        10,
        nil
    )

    --print(
    --    "[FarmReputation] Farm Reputation Seite registriert"
    --)

end

Mission00.loadMission00Finished =
    Utils.appendedFunction(
        Mission00.loadMission00Finished,
        loadedMission
    )

--print(
--    "[FarmReputation] Frame Script geladen"
--)