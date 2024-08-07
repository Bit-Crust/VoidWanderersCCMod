local id, n
for module in PresetMan.Modules do
	if module.FileName ~= "Base.rte" and module.FileName ~= CF["ModuleName"] and not module.IsFaction then
		for entity in module.Presets do
			if
				(
					entity.ClassName == "HDFirearm"
					or entity.ClassName == "TDExplosive"
					or entity.ClassName == "HeldDevice"
				)
				and ToHeldDevice(entity).Buyable
				and ToHeldDevice(entity).RandomWeight ~= 0
			then
				entity = ToHeldDevice(entity)
				if entity:HasObjectInGroup("Bombs - Payloads") then
					n = #CF["BombNames"] + 1
					CF["BombNames"][n] = entity:GetModuleAndPresetName()
					CF["BombPresets"][n] = entity.PresetName
					CF["BombModules"][n] = module.FileName
					CF["BombClasses"][n] = entity.ClassName
					CF["BombPrices"][n] = entity:GetGoldValue(0, 1, 1) * 1.5
					CF["BombDescriptions"][n] = entity.Description
					--Bomb owner factions determines which faction will sell you those bombs. If your relations are not good enough, then you won't get the bombs.
					--If it's empty then bombs can be sold to any faction
					CF["BombOwnerFactions"][n] = {}
					CF["BombUnlockData"][n] = 0
				else
					id = #CF["ArtItmPresets"] + 1
					CF["ArtItmPresets"][id] = entity.PresetName
					CF["ArtItmModules"][id] = module.FileName
					CF["ArtItmClasses"][id] = entity.ClassName
					CF["ArtItmPrices"][id] = entity:GetGoldValue(0, 1, 1)
					CF["ArtItmDescriptions"][id] = entity.Description
				end
			elseif
				(entity.ClassName == "AHuman" or entity.ClassName == "ACrab")
				and ToActor(entity).Buyable
				and ToActor(entity).RandomWeight ~= 0
			then
				id = #CF["ArtActPresets"] + 1
				CF["ArtActPresets"][id] = entity.PresetName
				CF["ArtActModules"][id] = module.FileName
				CF["ArtActClasses"][id] = entity.ClassName
				CF["ArtActPrices"][id] = ToActor(entity):GetGoldValue(0, 1, 1)
				CF["ArtActDescriptions"][id] = entity.Description
			end
		end
	end
end
