local faction = ""
local id = 0
--Coalition
faction = "Coalition"
id = #CF.ItmNames[faction]
--Imperatus
faction = "Imperatus"
id = #CF.ItmNames[faction]

id = id + 1
CF.ItmPresets[faction][id] = "Imperatus Arm"
CF.ItmModules[faction][id] = CF.ModuleName
CF.ItmNames[faction][id] = CF.ItmModules[faction][id] .. "/" .. CF.ItmPresets[faction][id]
CF.ItmPrices[faction][id] = 30
CF.ItmDescriptions[faction][id] = "Robotic replacement arm. Compatible with both robotic and organic entities."
CF.ItmUnlockData[faction][id] = 300
CF.ItmTypes[faction][id] = CF.WeaponTypes.TOOL
CF.ItmClasses[faction][id] = "HeldDevice"
CF.ItmPowers[faction][id] = 0

id = id + 1
CF.ItmPresets[faction][id] = "Imperatus Leg"
CF.ItmModules[faction][id] = CF.ModuleName
CF.ItmNames[faction][id] = CF.ItmModules[faction][id] .. "/" .. CF.ItmPresets[faction][id]
CF.ItmPrices[faction][id] = 30
CF.ItmDescriptions[faction][id] = "Robotic replacement leg. Compatible with both robotic and organic entities."
CF.ItmUnlockData[faction][id] = 300
CF.ItmTypes[faction][id] = CF.WeaponTypes.TOOL
CF.ItmClasses[faction][id] = "HeldDevice"
CF.ItmPowers[faction][id] = 0
--Techion
faction = "Techion"
id = #CF.ItmNames[faction]
--Dummy
faction = "Dummy"
id = #CF.ItmNames[faction]
--Ronin
faction = "Ronin"
id = #CF.ItmNames[faction]
--Browncoats
faction = "Browncoats"
id = #CF.ItmNames[faction]
