local faction = ""
local id = 0
--Coalition
faction = "Coalition"
id = #CF_ItmNames[faction]
--Imperatus
faction = "Imperatus"
id = #CF_ItmNames[faction]

id = id + 1
CF_ItmPresets[faction][id] = "Imperatus Arm"
CF_ItmModules[faction][id] = CF_ModuleName
CF_ItmNames[faction][id] = CF_ItmModules[faction][id] .. "/" .. CF_ItmPresets[faction][id]
CF_ItmPrices[faction][id] = 30
CF_ItmDescriptions[faction][id] = "Robotic replacement arm. Compatible with both robotic and organic entities."
CF_ItmUnlockData[faction][id] = 300
CF_ItmTypes[faction][id] = CF_WeaponTypes.TOOL
CF_ItmClasses[faction][id] = "HeldDevice"
CF_ItmPowers[faction][id] = 0

id = id + 1
CF_ItmPresets[faction][id] = "Imperatus Leg"
CF_ItmModules[faction][id] = CF_ModuleName
CF_ItmNames[faction][id] = CF_ItmModules[faction][id] .. "/" .. CF_ItmPresets[faction][id]
CF_ItmPrices[faction][id] = 30
CF_ItmDescriptions[faction][id] = "Robotic replacement leg. Compatible with both robotic and organic entities."
CF_ItmUnlockData[faction][id] = 300
CF_ItmTypes[faction][id] = CF_WeaponTypes.TOOL
CF_ItmClasses[faction][id] = "HeldDevice"
CF_ItmPowers[faction][id] = 0
--Techion
faction = "Techion"
id = #CF_ItmNames[faction]
--Dummy
faction = "Dummy"
id = #CF_ItmNames[faction]
--Ronin
faction = "Ronin"
id = #CF_ItmNames[faction]
--Browncoats
faction = "Browncoats"
id = #CF_ItmNames[faction]
