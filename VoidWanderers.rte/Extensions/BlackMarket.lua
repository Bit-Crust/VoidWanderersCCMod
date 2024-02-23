-- Black Market exclusives :O
CF_FactionNames["Black Market"] = "Black Market"
local id = #CF_BlackMarketItmPresets

for module in PresetMan.Modules do
	if module.FileName ~= CF_ModuleName then
		for entity in module.Presets do
			if
				(entity.ClassName == "HDFirearm" or entity.ClassName == "HeldDevice")
				and (not ToHeldDevice(entity).Buyable or ToHeldDevice(entity).RandomWeight == 0)
				and ToHeldDevice(entity):GetGoldValue(0, 1, 1) ~= 0
			then -- If it has a price, it's for sale!
				entity = ToHeldDevice(entity)
				id = id + 1
				CF_BlackMarketItmPresets[id] = entity.PresetName
				CF_BlackMarketItmModules[id] = module.FileName
				CF_BlackMarketItmClasses[id] = entity.ClassName
				CF_BlackMarketItmPrices[id] = math.max(math.abs(entity:GetGoldValue(0, 1, 1)), CF_UnknownItemPrice)
				CF_BlackMarketItmDescriptions[id] = entity.Description
				--[[
			elseif (entity.ClassName == "AHuman" or entity.ClassName == "ACrab") and ToActor(entity):HasObjectInGroup("Brains") and ToActor(entity).Buyable then
				entity = ToActor(entity);
				id = id + 1;
				CF_BlackMarketActPresets[id] = entity.PresetName;
				CF_BlackMarketActModules[id] = module.FileName;
				CF_BlackMarketActClasses[id] = entity.ClassName;
				CF_BlackMarketActPrices[id] = math.max(math.abs(entity:GetGoldValue(0, 1, 1)), CF_UnknownItemPrice);
				CF_BlackMarketActDescriptions[id] = entity.Description;
			]]
				--
			end
		end
	end
end

id = id + 1
CF_BlackMarketItmPresets[id] = "Prosthetic Arm"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HeldDevice"
CF_BlackMarketItmPrices[id] = 25
CF_BlackMarketItmDescriptions[id] = "Need a hand?"

id = id + 1
CF_BlackMarketItmPresets[id] = "Prosthetic Leg"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HeldDevice"
CF_BlackMarketItmPrices[id] = 25
CF_BlackMarketItmDescriptions[id] = "Break a leg!"

id = id + 1
CF_BlackMarketItmPresets[id] = "Green Dummy Head"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HeldDevice"
CF_BlackMarketItmPrices[id] = 25
CF_BlackMarketItmDescriptions[id] = "Quit while you're a head!"

id = id + 1
CF_BlackMarketItmPresets[id] = "Replacement Head"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HeldDevice"
CF_BlackMarketItmPrices[id] = 50
CF_BlackMarketItmDescriptions[id] = "Quit while you're a head!"

id = id + 1
CF_BlackMarketItmPresets[id] = "Lazor Rifle"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 200
CF_BlackMarketItmDescriptions[id] = "Your firing you're lazor!!"

id = id + 1
CF_BlackMarketItmPresets[id] = "YAK-4700"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 200
CF_BlackMarketItmDescriptions[id] = "Someone's tampered with this gun, I can tell..."
-- Counterfeit
id = id + 1
CF_BlackMarketItmPresets[id] = "Ubor Cannon"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 100
CF_BlackMarketItmDescriptions[id] =
	"Ubor Cannon. A shoulder mounted, tactical artillery weapon that fires air bursting cluster bomb. Features a trajectory guide to help with long ranged shots."

id = id + 1
CF_BlackMarketItmPresets[id] = "Missilo Launcher"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 100
CF_BlackMarketItmDescriptions[id] =
	"Can fire powerfull automatically guided missiles, excellent at destroying enemy crafts.  Lock on to enemy units using the laser pointer!"

id = id + 1
CF_BlackMarketItmPresets[id] = "Devastator CNN-72"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 100
CF_BlackMarketItmDescriptions[id] =
	"A devestating anti air weapon that can take out a drop ship from a distance easily with little effort. The proximity fuze on the flak shells ensures that they explodes at the right distance for maximum effectiveness."

id = id + 1
CF_BlackMarketItmPresets[id] = "Bulldog GG-69"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 100
CF_BlackMarketItmDescriptions[id] =
	"Slow firing, but incredibly powerfull, this gatling gun is sure to destroy you're opponents."

id = id + 1
CF_BlackMarketItmPresets[id] = "Giga Pulser"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 100
CF_BlackMarketItmDescriptions[id] =
	"With an alternative cooling system, the Giga Pulser dwarfs it's smaller siblings not only in physicle size, but also in fire power and round count. After a short charge up, this weapon deals a brief but concentrated splattering of short range lasers."

id = id + 1
CF_BlackMarketItmPresets[id] = "Nucleu Swarm"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 100
CF_BlackMarketItmDescriptions[id] =
	"Charge this weapon before firing a swarm of 8 plasma 'missles' that home in on enemies."

if PresetMan:GetModuleID("MyMod.rte") ~= -1 then
	id = id + 1
	CF_BlackMarketItmPresets[id] = "My Gun"
	CF_BlackMarketItmModules[id] = "MyMod.rte"
	CF_BlackMarketItmClasses[id] = "HDFirearm"
	CF_BlackMarketItmPrices[id] = 100
	CF_BlackMarketItmDescriptions[id] = "It's my gun!"
end

--[[
id = id + 1
CF_BlackMarketItmPresets[id] = "Uber Grenade Launcher"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 700

id = id + 1
CF_BlackMarketItmPresets[id] = "Frag Nailer Machinegun"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 500

id = id + 1
CF_BlackMarketItmPresets[id] = "Big Iron"
CF_BlackMarketItmModules[id] = CF_ModuleName
CF_BlackMarketItmClasses[id] = "HDFirearm"
CF_BlackMarketItmPrices[id] = 250
]]
--
