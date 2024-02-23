function CF_InitExtensionsData(activity)
	-- Init planet data structures
	CF_Planet = {}
	CF_PlanetName = {}
	CF_PlanetGlow = {}
	CF_PlanetGlowModule = {}
	CF_PlanetPos = {}
	CF_PlanetScale = {} -- Used just to show realistic km distances when traveling near moons or stations

	-- Init locations data structures
	CF_Location = {}
	CF_LocationName = {}
	CF_LocationPos = {}
	CF_LocationDescription = {}
	CF_LocationSecurity = {}
	CF_LocationGoldPresent = {}
	CF_LocationRemoveDoors = {}
	CF_LocationScenes = {}
	CF_LocationPlanet = {}
	CF_LocationScript = {}
	CF_LocationAmbientScript = {}
	CF_LocationMissions = {}
	CF_LocationPlayable = {} -- Used by scene editor to discard service locations
	CF_LocationAttributes = {}

	CF_LocationAttributeTypes = {
		BLACKMARKET = 0,
		TRADESTAR = 1,
		SHIPYARD = 2,
		VESSEL = 3,
		NOTMISSIONASSIGNABLE = 4,
		ALWAYSUNSEEN = 5,
		TEMPLOCATION = 6,
		ABANDONEDVESSEL = 7,
		SCOUT = 8,
		CORVETTE = 9,
		FRIGATE = 10,
		DESTROYER = 11,
		CRUISER = 12,
		BATTLESHIP = 13,
		NOBOMBS = 14,
	}

	CF_AssaultDifficultyVesselClass = {}
	CF_AssaultDifficultyVesselClass[1] = CF_LocationAttributeTypes.SCOUT
	CF_AssaultDifficultyVesselClass[2] = CF_LocationAttributeTypes.CORVETTE
	CF_AssaultDifficultyVesselClass[3] = CF_LocationAttributeTypes.FRIGATE
	CF_AssaultDifficultyVesselClass[4] = CF_LocationAttributeTypes.DESTROYER
	CF_AssaultDifficultyVesselClass[5] = CF_LocationAttributeTypes.CRUISER
	CF_AssaultDifficultyVesselClass[6] = CF_LocationAttributeTypes.BATTLESHIP

	-- Init ship data structures
	CF_Vessel = {}
	CF_VesselName = {}
	CF_VesselScene = {}
	CF_VesselModule = {}

	-- Price of the vesel
	CF_VesselPrice = {}

	-- Amount of bodies which can be stored on the ship
	CF_VesselMaxClonesCapacity = {}
	CF_VesselStartClonesCapacity = {}

	-- Amount of items which can be stored on the ship
	CF_VesselMaxStorageCapacity = {}
	CF_VesselStartStorageCapacity = {}

	-- How many units can be active on the ship simultaneously
	CF_VesselMaxLifeSupport = {}
	CF_VesselStartLifeSupport = {}

	-- How many units can be active on the planet surface simultaneously
	CF_VesselMaxCommunication = {}
	CF_VesselStartCommunication = {}

	CF_VesselMaxSpeed = {}
	CF_VesselStartSpeed = {}

	CF_VesselMaxTurrets = {}
	CF_VesselStartTurrets = {}

	CF_VesselMaxTurretStorage = {}
	CF_VesselStartTurretStorage = {}

	CF_VesselMaxBombBays = {}
	CF_VesselStartBombBays = {}

	CF_VesselMaxBombStorage = {}
	CF_VesselStartBombStorage = {}

	CF_Mission = {}

	CF_MissionName = {}
	CF_MissionRequiredData = {}
	CF_MissionScript = {}
	CF_MissionMinReputation = {}
	CF_MissionBriefingText = {}
	CF_MissionGoldRewardPerDifficulty = {}
	CF_MissionReputationRewardPerDifficulty = {}
	CF_MissionMaxSets = {}

	-- Artifact items
	CF_ArtItmPresets = {}
	CF_ArtItmModules = {}
	CF_ArtItmClasses = {}
	CF_ArtItmPrices = {}
	CF_ArtItmDescriptions = {}

	-- Artifact actors
	CF_ArtActPresets = {}
	CF_ArtActModules = {}
	CF_ArtActClasses = {}
	CF_ArtActPrices = {}
	CF_ArtActDescriptions = {}

	-- Black Market items
	CF_BlackMarketItmPresets = {}
	CF_BlackMarketItmModules = {}
	CF_BlackMarketItmClasses = {}
	CF_BlackMarketItmPrices = {}
	CF_BlackMarketItmDescriptions = {}

	-- Quantum items
	CF_QuantumItems = {}
	CF_QuantumItmPresets = {}
	CF_QuantumItmModules = {}
	CF_QuantumItmClasses = {}
	CF_QuantumItmPrices = {}

	-- Random encounters
	CF_RandomEncounters = {}
	CF_RandomEncounterIDs = {}

	CF_RandomEncountersInitialTexts = {}
	CF_RandomEncountersInitialVariants = {}
	CF_RandomEncountersVariantsInterval = {}
	CF_RandomEncountersFunctions = {}
	CF_RandomEncountersOneTime = {}

	CF_ItemReplacements = {}
end
