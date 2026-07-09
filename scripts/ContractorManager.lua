ContractorManager = {}


-------------------------------------------------
-- CONTRACTORS
-------------------------------------------------

ContractorManager.contractors = {

    -------------------------------------------------
    -- HARVEST
    -------------------------------------------------

    harvestMission = {
        "NordAgrar GmbH",
        "AgroFarm Services",
        "Meyer Landwirtschaft",
        "Hofgemeinschaft Becker"
    },

    -------------------------------------------------
    -- SOWING
    -------------------------------------------------

    sowMission = {
        "Saatzucht Nord",
        "AgriPlant Services",
        "Feldtechnik Müller"
    },

    -------------------------------------------------
    -- PLOWING
    -------------------------------------------------

    plowMission = {
        "Ackerbau Nord",
        "Bodenservice West"
    },

    -------------------------------------------------
    -- CULTIVATING
    -------------------------------------------------

    cultivateMission = {
        "Ackerbau Nord",
        "Bodenservice West",
        "TerraCult GmbH"
    },

    -------------------------------------------------
    -- HOE / WEED CONTROL
    -------------------------------------------------

    hoeMission = {
        "Feldpflege Nord",
        "CropCare Services"
    },

    weedMission = {
        "Feldpflege Nord",
        "CropCare Services",
        "Agrarpflege West"
    },

    -------------------------------------------------
    -- TEDDER
    -------------------------------------------------

    tedderMission = {
        "HeuService Nord",
        "Grassland Solutions",
        "Futtertechnik West"
    },

    -------------------------------------------------
    -- FERTILIZING
    -------------------------------------------------

    fertilizeMission = {
        "AgroChem Nord",
        "Crop Solutions GmbH"
    },

    -------------------------------------------------
    -- SPRAYING
    -------------------------------------------------

    sprayingMission = {
        "Pflanzenschutz Nord",
        "AgriSpray Services"
    },

    herbicideMission = {
        "Pflanzenschutz Nord",
        "AgriSpray Services",
        "CropProtect GmbH"
    },

    -------------------------------------------------
    -- LIMING
    -------------------------------------------------

    limeMission = {
        "Kalkwerk Nord",
        "AgriLime Services",
        "Bodenverbesserung GmbH"
    },

    -------------------------------------------------
    -- MOWING
    -------------------------------------------------

    mowMission = {
        "Kommunalpflege Nord",
        "Landschaftspflege Becker"
    },

    -------------------------------------------------
    -- BALE
    -------------------------------------------------

    baleMission = {
        "BallenService Nord",
        "AgriBale Logistics"
    },

    -------------------------------------------------
    -- BALE WRAP
    -------------------------------------------------

    baleWrapMission = {
        "Silage Service Nord",
        "BallenExpress GmbH"
    },

    -------------------------------------------------
    -- TREE TRANSPORT
    -------------------------------------------------

    treeTransportMission = {
        "NordForst Logistik",
        "Holztrans West",
        "Wald & Transport GmbH"
    },

    -------------------------------------------------
    -- DEADWOOD
    -------------------------------------------------

    deadwoodMission = {
        "Forstservice Nord",
        "Waldpflege Becker",
        "Nordwald Forstbetrieb"
    },

    -------------------------------------------------
    -- STONE PICKING
    -------------------------------------------------

    stonePickMission = {
        "Bau & Boden GmbH",
        "TerraClean Services"
    },

    -------------------------------------------------
    -- DESTRUCTIBLE ROCK
    -------------------------------------------------

    destructibleRockMission = {
        "Steinbruch Becker",
        "TerraRock Services",
        "Sprengtechnik Nord",
        "Bau & Boden GmbH",
        "Fels & Tiefbau GmbH"
    },

    -------------------------------------------------
    -- TRANSPORT
    -------------------------------------------------

    transportMission = {
        "NordCargo",
        "Mühlen Logistik",
        "AgriTrans GmbH"
    },

    -------------------------------------------------
    -- SUPPLY TRANSPORT
    -------------------------------------------------

    supplyTransportMission = {
        "AgriLogistik Nord",
        "Landhandel Becker",
        "Raiffeisen Transport",
        "NordCargo Agrar",
        "Agrarversorgung West"
    },

    -------------------------------------------------
    -- SPECIAL MOD MISSIONS
    -------------------------------------------------

    kommunalMission = {
        "Kommunal Services",
        "Stadtpflege Nord",
        "Kommunaltechnik West"
    }

}

-------------------------------------------------
-- RANDOM ENTRY
-------------------------------------------------

local function getRandomEntry(list)

    if list == nil then
        return g_i18n:getText("fr_unknownContractor")
    end

    local index =
        math.random(1, #list)

    return list[index]

end

-------------------------------------------------
-- ASSIGN CONTRACTOR
-------------------------------------------------

function ContractorManager.assignContractor(mission)

    if mission == nil then
        return
    end

    if mission.info == nil then
        mission.info = {}
    end

    local missionType =
        tostring(mission.type.name)

    local contractorName = nil

    -------------------------------------------------
    -- NPC CONTRACTOR
    -------------------------------------------------

    if mission.getNPC ~= nil then

        local npc = mission:getNPC()

        if npc ~= nil and npc.title ~= nil then

            contractorName = npc.title

        end

    end

    -------------------------------------------------
    -- FALLBACK CONTRACTOR
    -------------------------------------------------

    if contractorName == nil then

        local contractorList =
            ContractorManager.contractors[missionType]

        contractorName =
            getRandomEntry(contractorList)

    end

    mission.info.contractorName =
        contractorName

end
