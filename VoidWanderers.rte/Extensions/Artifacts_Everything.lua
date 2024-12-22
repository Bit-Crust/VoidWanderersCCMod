do
	-- Outside modules not marked factions are entered as artifact producing factions
	local id, n, mosr, isObtainable, isHeldDevice, isTraditionalUnit;
	for module in PresetMan.Modules do
		if module.FileName ~= CF.ModuleName and not module.IsFaction then
			for entity in module.Presets do
				if IsMOSRotating(entity) then
					mosr = ToMOSRotating(entity);
					isObtainable = (mosr.Buyable and mosr.RandomWeight ~= 0) or mosr:HasObjectInGroup("Artifact");

					if isObtainable then
						isHeldDevice = mosr.ClassName == "HDFirearm" or mosr.ClassName == "TDExplosive" or mosr.ClassName == "HeldDevice";
						isTraditionalUnit = mosr.ClassName == "AHuman" or mosr.ClassName == "ACrab";

						if isHeldDevice then
							if mosr:HasObjectInGroup("Payloads") then
								n = #CF.BombNames + 1;
								CF.BombNames[n] = mosr:GetModuleAndPresetName();

								CF.BombPresets[n] = mosr.PresetName;
								CF.BombModules[n] = module.FileName;
								CF.BombClasses[n] = mosr.ClassName;
								CF.BombPrices[n] = mosr:GetGoldValue(0, 1, 1);
								CF.BombDescriptions[n] = mosr.Description;
								CF.BombOwnerFactions[n] = {};
								CF.BombUnlockData[n] = 0;
							else
								id = #CF.ArtItmPresets + 1;
								CF.ArtItmPresets[id] = mosr.PresetName;
								CF.ArtItmModules[id] = module.FileName;
								CF.ArtItmClasses[id] = mosr.ClassName;
								CF.ArtItmPrices[id] = mosr:GetGoldValue(0, 1, 1);
								CF.ArtItmDescriptions[id] = mosr.Description;
							end
						elseif isTraditionalUnit then
							id = #CF.ArtActPresets + 1;
							CF.ArtActPresets[id] = mosr.PresetName;
							CF.ArtActModules[id] = module.FileName;
							CF.ArtActClasses[id] = mosr.ClassName;
							CF.ArtActPrices[id] = mosr:GetGoldValue(0, 1, 1);
							CF.ArtActDescriptions[id] = mosr.Description;
						end
					end
				end
			end
		end
	end
end