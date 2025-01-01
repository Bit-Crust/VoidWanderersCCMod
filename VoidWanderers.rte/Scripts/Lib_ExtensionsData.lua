function CF.InitExtensionsData(activity)
	-- Init planet data structures
	CF.Planet = {};
	CF.PlanetName = {};
	CF.PlanetGlow = {};
	CF.PlanetPos = {};
	CF.PlanetScale = {}; -- Used just to show realistic km distances when traveling near moons or stations

	-- Init locations data structures
	CF.Location = {};
	CF.LocationName = {};
	CF.LocationPos = {};
	CF.LocationDescription = {};
	CF.LocationSecurity = {};
	CF.LocationGoldPresent = {};
	CF.LocationScenes = {};
	CF.LocationPlanet = {};
	CF.LocationScript = {};
	CF.LocationAmbientScript = {};
	CF.LocationMissions = {};
	CF.LocationPlayable = {}; -- Used by scene editor to discard service locations
	CF.LocationAttributes = {};

	CF.LocationAttributeTypes = {
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
	};

	CF.AssaultDifficultyVesselClass = {};
	CF.AssaultDifficultyVesselClass[1] = CF.LocationAttributeTypes.SCOUT;
	CF.AssaultDifficultyVesselClass[2] = CF.LocationAttributeTypes.CORVETTE;
	CF.AssaultDifficultyVesselClass[3] = CF.LocationAttributeTypes.FRIGATE;
	CF.AssaultDifficultyVesselClass[4] = CF.LocationAttributeTypes.DESTROYER;
	CF.AssaultDifficultyVesselClass[5] = CF.LocationAttributeTypes.CRUISER;
	CF.AssaultDifficultyVesselClass[6] = CF.LocationAttributeTypes.BATTLESHIP;

	-- Init ship data structures
	CF.Vessel = {};
	CF.VesselName = {};
	CF.VesselScene = {};
	CF.VesselModule = {};

	-- Price of the vesel
	CF.VesselPrice = {}

	-- Amount of bodies which can be stored on the ship
	CF.VesselMaxClonesCapacity = {}
	CF.VesselStartClonesCapacity = {};

	-- Amount of items which can be stored on the ship
	CF.VesselMaxStorageCapacity = {};
	CF.VesselStartStorageCapacity = {};

	-- How many units can be active on the ship simultaneously
	CF.VesselMaxLifeSupport = {};
	CF.VesselStartLifeSupport = {};

	-- How many units can be active on the planet surface simultaneously
	CF.VesselMaxCommunication = {};
	CF.VesselStartCommunication = {};

	CF.VesselMaxSpeed = {};
	CF.VesselStartSpeed = {};

	CF.VesselMaxTurrets = {};
	CF.VesselStartTurrets = {};

	CF.VesselMaxTurretStorage = {};
	CF.VesselStartTurretStorage = {};

	CF.VesselMaxBombBays = {};
	CF.VesselStartBombBays = {};

	CF.VesselMaxBombStorage = {};
	CF.VesselStartBombStorage = {};

	CF.Mission = {};

	CF.MissionName = {};
	CF.MissionRequiredData = {};
	CF.MissionScript = {};
	CF.MissionMinReputation = {};
	CF.MissionBriefingText = {};
	CF.MissionGoldRewardPerDifficulty = {};
	CF.MissionReputationRewardPerDifficulty = {};
	CF.MissionMaxSets = {};

	-- Artifact items
	CF.ArtItmPresets = {};
	CF.ArtItmModules = {};
	CF.ArtItmClasses = {};
	CF.ArtItmPrices = {};
	CF.ArtItmDescriptions = {};

	-- Artifact actors
	CF.ArtActPresets = {};
	CF.ArtActModules = {};
	CF.ArtActClasses = {};
	CF.ArtActPrices = {};
	CF.ArtActDescriptions = {};

	-- Black Market items
	CF.BlackMarketItmPresets = {};
	CF.BlackMarketItmModules = {};
	CF.BlackMarketItmClasses = {};
	CF.BlackMarketItmPrices = {};
	CF.BlackMarketItmDescriptions = {};
	CF.BlackMarketItmTypes = {};

	-- Quantum items
	CF.QuantumItems = {};
	CF.QuantumItmPresets = {};
	CF.QuantumItmModules = {};
	CF.QuantumItmClasses = {};
	CF.QuantumItmPrices = {};

	-- Random encounters
	CF.RandomEncounters = {};
	CF.RandomEncounterScripts = {};
	CF.RandomEncounterEligibilityTests = {};
end