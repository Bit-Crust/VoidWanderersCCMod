-- Uses: Enemy
local id = "Assault"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Assault"
CF_MissionScript[id] = "VoidWanderers.rte/Scripts/Mission_Assault.lua"
CF_MissionMinReputation[id] = -10000 -- This mission is always available
CF_MissionBriefingText[id] = "Attack the enemy installation and wipe out any enemy forces."
CF_MissionGoldRewardPerDifficulty[id] = 0
CF_MissionReputationRewardPerDifficulty[id] = 100
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

-- Uses: Enemy, Assassinate
local id = "Assassinate"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Assassinate"
CF_MissionScript[id] = "VoidWanderers.rte/Scripts/Mission_Assassinate.lua"
CF_MissionMinReputation[id] = 0
CF_MissionBriefingText[id] = "Locate and assassinate enemy commander."
CF_MissionGoldRewardPerDifficulty[id] = 600
CF_MissionReputationRewardPerDifficulty[id] = 70
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

local i = 1
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Commander"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 4

-- Uses: Enemy, Mine
local id = "Mine"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Establish Mining"
CF_MissionScript[id] = "VoidWanderers.rte/Scripts/Mission_Mine.lua"
CF_MissionMinReputation[id] = 700
CF_MissionBriefingText[id] = "Establish mining camp and protect enough miners from enemy. Brain presence recommended."
CF_MissionGoldRewardPerDifficulty[id] = 0
CF_MissionReputationRewardPerDifficulty[id] = 175
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

local i = 1
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Miners"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 6

local i = 2
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "MinerSentries"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 6

local i = 3
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "MinerLZ"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 6

-- Uses: Enemy, Mine
local id = "Dropships"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Disrupt Mining"
CF_MissionScript[id] = "VoidWanderers.rte/Scripts/Mission_Dropships.lua"
CF_MissionMinReputation[id] = 600
CF_MissionBriefingText[id] =
	"Disrupt enemy mining operations and destroy all incoming drop ships. Brain presence recommended."
CF_MissionGoldRewardPerDifficulty[id] = 750
CF_MissionReputationRewardPerDifficulty[id] = 150
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

-- Uses: Zombies
local id = "Zombies"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Zombie onslaught"
CF_MissionScript[id] = "VoidWanderers.rte/Scripts/Mission_Zombies.lua"
CF_MissionMinReputation[id] = 800
CF_MissionBriefingText[id] = "Destroy hacked cloning vats producing aggressive unbaked bodies."
CF_MissionGoldRewardPerDifficulty[id] = 800
CF_MissionReputationRewardPerDifficulty[id] = 175
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

local i = 1
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Vat"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 8

-- Uses: Enemy
local id = "Defend"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Hold position"
CF_MissionScript[id] = "VoidWanderers.rte/Scripts/Mission_Defend.lua"
CF_MissionMinReputation[id] = 1000
CF_MissionBriefingText[id] =
	"Assist allied troops and protect the base from incoming enemies. Brain presence recommended."
CF_MissionGoldRewardPerDifficulty[id] = 1000
CF_MissionReputationRewardPerDifficulty[id] = 200
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

-- Uses: Ambient, Zombies
local id = "Destroy"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Destroy"
CF_MissionScript[id] = "VoidWanderers.rte/Scripts/Mission_Destroy.lua"
CF_MissionMinReputation[id] = 1300
CF_MissionBriefingText[id] = "Locate and destroy enemy data relays."
CF_MissionGoldRewardPerDifficulty[id] = 1250
CF_MissionReputationRewardPerDifficulty[id] = 200
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

-- Uses: Squad
local id = "Squad"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Wipe squad"
CF_MissionScript[id] = "VoidWanderers.rte/Scripts/Mission_Squad.lua"
CF_MissionMinReputation[id] = 1500
CF_MissionBriefingText[id] = "Locate and destroy enemy spec ops squad and their commander."
CF_MissionGoldRewardPerDifficulty[id] = 1300
CF_MissionReputationRewardPerDifficulty[id] = 220
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

local i = 1
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Commander"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 1

local i = 2
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Trooper"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 4

-- Uses: Enemy, Assassinate
local id = "Evacuate"
CF_Mission[#CF_Mission + 1] = id

CF_MissionName[id] = "Evacuate"
CF_MissionScript[id] = "VoidWanderers.rte/Scripts/Mission_Evacuate.lua"
CF_MissionMinReputation[id] = 1700
CF_MissionBriefingText[id] = "Rescue and evacuate allied commander amid the enemy assault."
CF_MissionGoldRewardPerDifficulty[id] = 1500
CF_MissionReputationRewardPerDifficulty[id] = 300
CF_MissionMaxSets[id] = 6
CF_MissionRequiredData[id] = {}

local i = 1
CF_MissionRequiredData[id][i] = {}
CF_MissionRequiredData[id][i]["Name"] = "Commander"
CF_MissionRequiredData[id][i]["Type"] = "Vector"
CF_MissionRequiredData[id][i]["Max"] = 4
