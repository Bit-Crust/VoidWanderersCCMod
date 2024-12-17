-- DEPLOY MISSION IS ESSENTIAL!!! NEVER TURN IT OFF!!!
-- It is used by scene editor to put deployment, ambient enemies and crates marks
local id = "Deploy"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Deploy"
CF.MissionScript[id] = ""
CF.MissionMinReputation[id] = 0
CF.MissionBriefingText[id] = ""
CF.MissionMaxSets[id] = 1
CF.MissionRequiredData[id] = {}

local i = 1
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "PlayerLZ"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 8

local i = 2
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "EnemyLZ"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 8

local i = 3
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "PlayerUnit"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 16

local i = 4
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "AmbientEnemy"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 16

local i = 5
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Crates"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 16

local id = "Enemy"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Enemy"
CF.MissionScript[id] = ""
CF.MissionMinReputation[id] = 0
CF.MissionBriefingText[id] = ""
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

local i = 1
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Any"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 6

local i = 2
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Rifle"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 6

local i = 3
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Heavy"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 4

local i = 4
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Shotgun"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 4

local i = 5
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Defender"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 4

local i = 6
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Armor"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 4

local i = 7
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Sniper"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 4

local i = 8
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Base"
CF.MissionRequiredData[id][i]["Type"] = "Box"
CF.MissionRequiredData[id][i]["Max"] = 16

local i = 9
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "LZ"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 12

local id = "Firefight"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Vessel_Firefight"
CF.MissionScript[id] = ""
CF.MissionMinReputation[id] = 0
CF.MissionBriefingText[id] = ""
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

local i = 1
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Team 1"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 8

local i = 2
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Team 2"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 8

local i = 3
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Waypoint 1"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 6

local i = 4
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Waypoint 2"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 6

local id = "Exploration"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Vessel_exploration"
CF.MissionScript[id] = ""
CF.MissionMinReputation[id] = 0
CF.MissionBriefingText[id] = ""
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

local i = 1
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Explore"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 16

CF.GenericMissionCount = #CF.Mission

-----------------------------------------------------------------------
--[[ Ship counterattack fake encounter
CF.RandomEncountersFunctions["COUNTERATTACK"] = 
function(self, variant)
	if not self.RandomEncounterIsInitialized then
		local locations = {}

		-- Find usable scene
		for i = 1, #CF.Location do
			local id = CF.Location[i]
			if CF.IsLocationHasAttribute(id, CF.AssaultDifficultyVesselClass[self.AssaultDifficulty]) then
				locations[#locations + 1] = id
			end
		end

		self.CounterattackVesselLocation = locations[math.random(#locations)]

		self.RandomEncounterIsInitialized = true

		self.EncounterCounterAttackExpiration = self.Time + CF.ShipCounterattackDelay

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
		self.vesselData["dialogOptionChosen"] = 0

		self.missionData["difficulty"] = self.AssaultDifficulty

		self.DeploymentStarted = true
	end

	if variant == 2 then
		-- Finish encounter
		self.RandomEncounterID = nil
		self.GS["Location"] = nil
	end
end
--]]
-----------------------------------------------------------------------
