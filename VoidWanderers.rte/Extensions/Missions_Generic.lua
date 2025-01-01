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
