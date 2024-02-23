local id, n
for module in PresetMan.Modules do
	if module.FileName ~= "Base.rte" and module.FileName ~= CF_ModuleName and not module.IsFaction then
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
					n = #CF_BombNames + 1
					CF_BombNames[n] = entity:GetModuleAndPresetName()
					CF_BombPresets[n] = entity.PresetName
					CF_BombModules[n] = module.FileName
					CF_BombClasses[n] = entity.ClassName
					CF_BombPrices[n] = entity:GetGoldValue(0, 1, 1) * 1.5
					CF_BombDescriptions[n] = entity.Description
					--Bomb owner factions determines which faction will sell you those bombs. If your relations are not good enough, then you won't get the bombs.
					--If it's empty then bombs can be sold to any faction
					CF_BombOwnerFactions[n] = {}
					CF_BombUnlockData[n] = 0
				else
					id = #CF_ArtItmPresets + 1
					CF_ArtItmPresets[id] = entity.PresetName
					CF_ArtItmModules[id] = module.FileName
					CF_ArtItmClasses[id] = entity.ClassName
					CF_ArtItmPrices[id] = entity:GetGoldValue(0, 1, 1)
					CF_ArtItmDescriptions[id] = entity.Description
				end
			elseif
				(entity.ClassName == "AHuman" or entity.ClassName == "ACrab")
				and ToActor(entity).Buyable
				and ToActor(entity).RandomWeight ~= 0
			then
				id = #CF_ArtActPresets + 1
				CF_ArtActPresets[id] = entity.PresetName
				CF_ArtActModules[id] = module.FileName
				CF_ArtActClasses[id] = entity.ClassName
				CF_ArtActPrices[id] = ToActor(entity):GetGoldValue(0, 1, 1)
				CF_ArtActDescriptions[id] = entity.Description
			end
		end
	end
end
