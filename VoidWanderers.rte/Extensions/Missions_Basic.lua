-- Uses: Enemy
local id = "Assault"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Assault"
CF.MissionScript[id] = "VoidWanderers.rte/Scripts/Missions/Assault.lua"
CF.MissionMinReputation[id] = -math.huge -- This mission is always available
CF.MissionBriefingText[id] = "Attack the enemy installation and wipe out any enemy forces."
CF.MissionGoldRewardPerDifficulty[id] = 0
CF.MissionReputationRewardPerDifficulty[id] = 100
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

-- Uses: Enemy, Assassinate
local id = "Assassinate"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Assassinate"
CF.MissionScript[id] = "VoidWanderers.rte/Scripts/Missions/Assassinate.lua"
CF.MissionMinReputation[id] = 0
CF.MissionBriefingText[id] = "Locate and assassinate enemy commander."
CF.MissionGoldRewardPerDifficulty[id] = 600
CF.MissionReputationRewardPerDifficulty[id] = 70
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

local i = 1
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Commander"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 4

-- Uses: Enemy, Mine
local id = "Mine"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Establish Mining"
CF.MissionScript[id] = "VoidWanderers.rte/Scripts/Missions/Mine.lua"
CF.MissionMinReputation[id] = 700
CF.MissionBriefingText[id] = "Establish mining camp and protect enough miners from enemy. Brain presence recommended."
CF.MissionGoldRewardPerDifficulty[id] = 0
CF.MissionReputationRewardPerDifficulty[id] = 175
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

local i = 1
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Miners"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 6

local i = 2
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "MinerSentries"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 6

local i = 3
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "MinerLZ"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 6

-- Uses: Enemy, Mine
local id = "Dropships"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Disrupt Mining"
CF.MissionScript[id] = "VoidWanderers.rte/Scripts/Missions/Dropships.lua"
CF.MissionMinReputation[id] = 600
CF.MissionBriefingText[id] =
	"Disrupt enemy mining operations and destroy all incoming drop ships. Brain presence recommended."
CF.MissionGoldRewardPerDifficulty[id] = 750
CF.MissionReputationRewardPerDifficulty[id] = 150
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

-- Uses: Zombies
local id = "Zombies"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Zombie onslaught"
CF.MissionScript[id] = "VoidWanderers.rte/Scripts/Missions/Zombies.lua"
CF.MissionMinReputation[id] = 800
CF.MissionBriefingText[id] = "Destroy hacked cloning vats producing aggressive unbaked bodies."
CF.MissionGoldRewardPerDifficulty[id] = 800
CF.MissionReputationRewardPerDifficulty[id] = 175
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

local i = 1
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Vat"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 8

-- Uses: Enemy
local id = "Defend"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Hold position"
CF.MissionScript[id] = "VoidWanderers.rte/Scripts/Missions/Defend.lua"
CF.MissionMinReputation[id] = 1000
CF.MissionBriefingText[id] =
	"Assist allied troops and protect the base from incoming enemies. Brain presence recommended."
CF.MissionGoldRewardPerDifficulty[id] = 1000
CF.MissionReputationRewardPerDifficulty[id] = 200
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

-- Uses: Ambient, Zombies
local id = "Destroy"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Destroy"
CF.MissionScript[id] = "VoidWanderers.rte/Scripts/Missions/Destroy.lua"
CF.MissionMinReputation[id] = 1300
CF.MissionBriefingText[id] = "Locate and destroy enemy data relays."
CF.MissionGoldRewardPerDifficulty[id] = 1250
CF.MissionReputationRewardPerDifficulty[id] = 200
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

-- Uses: Squad
local id = "Squad"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Wipe squad"
CF.MissionScript[id] = "VoidWanderers.rte/Scripts/Missions/Squad.lua"
CF.MissionMinReputation[id] = 1500
CF.MissionBriefingText[id] = "Locate and destroy enemy spec ops squad and their commander."
CF.MissionGoldRewardPerDifficulty[id] = 1300
CF.MissionReputationRewardPerDifficulty[id] = 220
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

local i = 1
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Commander"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 1

local i = 2
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Trooper"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 4

-- Uses: Enemy, Assassinate
local id = "Evacuate"
CF.Mission[#CF.Mission + 1] = id

CF.MissionName[id] = "Evacuate"
CF.MissionScript[id] = "VoidWanderers.rte/Scripts/Missions/Evacuate.lua"
CF.MissionMinReputation[id] = 1700
CF.MissionBriefingText[id] = "Rescue and evacuate allied commander amid the enemy assault."
CF.MissionGoldRewardPerDifficulty[id] = 1500
CF.MissionReputationRewardPerDifficulty[id] = 300
CF.MissionMaxSets[id] = 6
CF.MissionRequiredData[id] = {}

local i = 1
CF.MissionRequiredData[id][i] = {}
CF.MissionRequiredData[id][i]["Name"] = "Commander"
CF.MissionRequiredData[id][i]["Type"] = "Vector"
CF.MissionRequiredData[id][i]["Max"] = 4
