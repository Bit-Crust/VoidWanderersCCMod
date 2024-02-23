-- DEPLOY MISSION IS ESSENTIAL!!! NEVER TURN IT OFF!!!
-- It is used by scene editor to put deployment, ambient enemies and crates marks
local id = "Deploy"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Deploy"
CF_MissionScript[id] = ""
CF_MissionMinReputation[id] = 0
CF_MissionBriefingText[id] = ""
CF_MissionMaxSets[id] = 1
CF_MissionRequiredData[id] = {}

local i = 1
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "PlayerLZ"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 8

local i = 2
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "EnemyLZ"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 8

local i = 3
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "PlayerUnit"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 16

local i = 4
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "AmbientEnemy"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 16

local i = 5
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Crates"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 16

local id = "Enemy"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Enemy"
CF_MissionScript[id] = ""
CF_MissionMinReputation[id] = 0
CF_MissionBriefingText[id] = ""
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

local i = 1
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Any"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 6

local i = 2
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Rifle"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 6

local i = 3
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Heavy"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 4

local i = 4
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Shotgun"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 4

local i = 5
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Defender"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 4

local i = 6
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Armor"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 4

local i = 7
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Sniper"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 4

local i = 8
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Base"
CF_MissionRequiredData[id][i]["Type"] = "Box"
CF_MissionRequiredData[id][i]["Max"] = 16

local i = 9
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "LZ"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 12

local id = "Firefight"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Vessel_Firefight"
CF_MissionScript[id] = ""
CF_MissionMinReputation[id] = 0
CF_MissionBriefingText[id] = ""
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

local i = 1
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Team 1"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 8

local i = 2
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Team 2"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 8

local i = 3
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Waypoint 1"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 6

local i = 4
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Waypoint 2"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 6

local id = "Exploration"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Vessel_exploration"
CF_MissionScript[id] = ""
CF_MissionMinReputation[id] = 0
CF_MissionBriefingText[id] = ""
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

local i = 1
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Explore"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 16

CF_GenericMissionCount = #CF_Mission

-------------------------------------------------------------------------------
-- Ship counterattack fake encounter
CF_RandomEncountersFunctions["COUNTERATTACK"] = 
function(self, variant)
	if not self.RandomEncounterIsInitialized then
		local locations = {}

		-- Find usable scene
		for i = 1, #CF_Location do
			local id = CF_Location[i]
			if CF_IsLocationHasAttribute(id, CF_AssaultDifficultyVesselClass[self.AssaultDifficulty]) then
				locations[#locations + 1] = id
			end
		end

		self.CounterattackVesselLocation = locations[math.random(#locations)]

		self.RandomEncounterIsInitialized = true

		self.EncounterCounterAttackExpiration = self.Time + CF_ShipCounterattackDelay

		self.DeploymentStarted = false
	end

	if variant == 0 then
		if self.DeploymentStarted then
			self.RandomEncounterText = "Deploy your away team to the enemy ship! Enemy will charge its FTL drive in T-"
				.. self.EncounterCounterAttackExpiration - self.Time
				.. "."
			FrameMan:ClearScreenText(0)
			FrameMan:SetScreenText(
				"Enemy will charge its FTL drive in T-" .. self.EncounterCounterAttackExpiration - self.Time .. ".",
				0,
				0,
				1000,
				true
			)
		else
			self.RandomEncounterText = "Enemy will charge its FTL drive in T-"
				.. self.EncounterCounterAttackExpiration - self.Time
				.. ", we can counterattack!"
		end
		if self.Time >= self.EncounterCounterAttackExpiration then
			variant = 2
		end
	end

	if variant == 1 then
		self.GS["Location"] = self.CounterattackVesselLocation

		self.RandomEncounterText = "Deploy your away team to the enemy ship."
		self.RandomEncounterVariants = {}
		self.RandomEncounterChosenVariant = 0

		self.MissionDifficulty = self.AssaultDifficulty

		self.DeploymentStarted = true
	end

	if variant == 2 then
		-- Finish encounter
		self.RandomEncounterID = nil
		self.GS["Location"] = nil
	end
end
-------------------------------------------------------------------------------
