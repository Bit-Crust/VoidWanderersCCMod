local id, n
-- Non-base outsider modules not marked factions are entered as artifact producing factions
-- From data, this includes Uzira.rte, Zombies and garbage, cool
for module in PresetMan.Modules do
	if module.FileName ~= CF.ModuleName and not module.IsFaction then
		for entity in module.Presets do
			if IsMovableObject(entity) then
				local mo = ToMovableObject(entity);
				local buyable = mo.Buyable and mo.RandomWeight ~= 0 or mo:HasObjectInGroup("Artifact");

				if buyable then
					local item = mo.ClassName == "HDFirearm" or mo.ClassName == "TDExplosive" or mo.ClassName == "HeldDevice";
					local actor = mo.ClassName == "AHuman" or mo.ClassName == "ACrab";

					if item then
						if mo:HasObjectInGroup("Payloads") then
							n = #CF.BombNames + 1;
							CF.BombPresets[n] = mo.PresetName;
							CF.BombModules[n] = module.FileName;
							CF.BombClasses[n] = mo.ClassName;
							CF.BombPrices[n] = mo:GetGoldValue(0, 1, 1);
							CF.BombDescriptions[n] = mo.Description;

							--Bomb owner factions determines which faction will sell you those bombs. If your relations are not good enough, then you won't get the bombs.
							--If it's empty then bombs can be sold to any faction
							CF.BombOwnerFactions[n] = {};
							CF.BombUnlockData[n] = 0;
							CF.BombNames[n] = mo:GetModuleAndPresetName();
						else
							id = #CF.ArtItmPresets + 1;
							CF.ArtItmPresets[id] = mo.PresetName;
							CF.ArtItmModules[id] = module.FileName;
							CF.ArtItmClasses[id] = mo.ClassName;
							CF.ArtItmPrices[id] = mo:GetGoldValue(0, 1, 1);
							CF.ArtItmDescriptions[id] = mo.Description;
						end
					elseif actor then
						id = #CF.ArtActPresets + 1;
						CF.ArtActPresets[id] = mo.PresetName;
						CF.ArtActModules[id] = module.FileName;
						CF.ArtActClasses[id] = mo.ClassName;
						CF.ArtActPrices[id] = mo:GetGoldValue(0, 1, 1);
						CF.ArtActDescriptions[id] = mo.Description;
					end
				end
			end
		end
	end
end
