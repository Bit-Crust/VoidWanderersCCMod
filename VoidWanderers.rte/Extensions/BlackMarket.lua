-- Black Market exclusives :O
CF["FactionNames"]["Black Market"] = "Black Market"
local id = #CF["BlackMarketItmPresets"]

for module in PresetMan.Modules do
	if module.FileName ~= CF["ModuleName"] then
		for entity in module.Presets do
			if
				(entity.ClassName == "HDFirearm" or entity.ClassName == "HeldDevice")
				and (not ToHeldDevice(entity).Buyable or ToHeldDevice(entity).RandomWeight == 0)
				and ToHeldDevice(entity):GetGoldValue(0, 1, 1) ~= 0
			then -- If it has a price, it's for sale!
				entity = ToHeldDevice(entity)
				id = id + 1
				CF["BlackMarketItmPresets"][id] = entity.PresetName
				CF["BlackMarketItmModules"][id] = module.FileName
				CF["BlackMarketItmClasses"][id] = entity.ClassName
				CF["BlackMarketItmPrices"][id] = math.max(math.abs(entity:GetGoldValue(0, 1, 1)), CF["UnknownItemPrice"])
				CF["BlackMarketItmDescriptions"][id] = entity.Description
				--[[
			elseif (entity.ClassName == "AHuman" or entity.ClassName == "ACrab") and ToActor(entity):HasObjectInGroup("Brains") and ToActor(entity).Buyable then
				entity = ToActor(entity)
				id = id + 1
				CF["BlackMarketActPresets"][id] = entity.PresetName
				CF["BlackMarketActModules"][id] = module.FileName
				CF["BlackMarketActClasses"][id] = entity.ClassName
				CF["BlackMarketActPrices"][id] = math.max(math.abs(entity:GetGoldValue(0, 1, 1)), CF["UnknownItemPrice"])
				CF["BlackMarketActDescriptions"][id] = entity.Description
			]]
				--
			end
		end
	end
end

id = id + 1
CF["BlackMarketItmPresets"][id] = "Prosthetic Arm"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HeldDevice"
CF["BlackMarketItmPrices"][id] = 25
CF["BlackMarketItmDescriptions"][id] = "Need a hand?"

id = id + 1
CF["BlackMarketItmPresets"][id] = "Prosthetic Leg"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HeldDevice"
CF["BlackMarketItmPrices"][id] = 25
CF["BlackMarketItmDescriptions"][id] = "Break a leg!"

id = id + 1
CF["BlackMarketItmPresets"][id] = "Green Dummy Head"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HeldDevice"
CF["BlackMarketItmPrices"][id] = 25
CF["BlackMarketItmDescriptions"][id] = "Quit while you're a head!"

id = id + 1
CF["BlackMarketItmPresets"][id] = "Replacement Head"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HeldDevice"
CF["BlackMarketItmPrices"][id] = 50
CF["BlackMarketItmDescriptions"][id] = "Quit while you're a head!"

id = id + 1
CF["BlackMarketItmPresets"][id] = "Lazor Rifle"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 200
CF["BlackMarketItmDescriptions"][id] = "Your firing you're lazor!!"

id = id + 1
CF["BlackMarketItmPresets"][id] = "YAK-4700"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 200
CF["BlackMarketItmDescriptions"][id] = "Someone's tampered with this gun, I can tell..."
-- Counterfeit
id = id + 1
CF["BlackMarketItmPresets"][id] = "Ubor Cannon"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 100
CF["BlackMarketItmDescriptions"][id] =
	"Ubor Cannon. A shoulder mounted, tactical artillery weapon that fires air bursting cluster bomb. Features a trajectory guide to help with long ranged shots."

id = id + 1
CF["BlackMarketItmPresets"][id] = "Missilo Launcher"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 100
CF["BlackMarketItmDescriptions"][id] =
	"Can fire powerfull automatically guided missiles, excellent at destroying enemy crafts.  Lock on to enemy units using the laser pointer!"

id = id + 1
CF["BlackMarketItmPresets"][id] = "Devastator CNN-72"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 100
CF["BlackMarketItmDescriptions"][id] =
	"A devestating anti air weapon that can take out a drop ship from a distance easily with little effort. The proximity fuze on the flak shells ensures that they explodes at the right distance for maximum effectiveness."

id = id + 1
CF["BlackMarketItmPresets"][id] = "Bulldog GG-69"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 100
CF["BlackMarketItmDescriptions"][id] =
	"Slow firing, but incredibly powerfull, this gatling gun is sure to destroy you're opponents."

id = id + 1
CF["BlackMarketItmPresets"][id] = "Giga Pulser"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 100
CF["BlackMarketItmDescriptions"][id] =
	"With an alternative cooling system, the Giga Pulser dwarfs it's smaller siblings not only in physicle size, but also in fire power and round count. After a short charge up, this weapon deals a brief but concentrated splattering of short range lasers."

id = id + 1
CF["BlackMarketItmPresets"][id] = "Nucleu Swarm"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 100
CF["BlackMarketItmDescriptions"][id] =
	"Charge this weapon before firing a swarm of 8 plasma 'missles' that home in on enemies."

if PresetMan:GetModuleID("MyMod.rte") ~= -1 then
	id = id + 1
	CF["BlackMarketItmPresets"][id] = "My Gun"
	CF["BlackMarketItmModules"][id] = "MyMod.rte"
	CF["BlackMarketItmClasses"][id] = "HDFirearm"
	CF["BlackMarketItmPrices"][id] = 100
	CF["BlackMarketItmDescriptions"][id] = "It's my gun!"
end

--[[
id = id + 1
CF["BlackMarketItmPresets"][id] = "Uber Grenade Launcher"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 700

id = id + 1
CF["BlackMarketItmPresets"][id] = "Frag Nailer Machinegun"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 500

id = id + 1
CF["BlackMarketItmPresets"][id] = "Big Iron"
CF["BlackMarketItmModules"][id] = CF["ModuleName"]
CF["BlackMarketItmClasses"][id] = "HDFirearm"
CF["BlackMarketItmPrices"][id] = 250
]]
--
