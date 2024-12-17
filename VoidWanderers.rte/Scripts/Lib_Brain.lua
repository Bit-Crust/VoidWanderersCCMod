-----------------------------------------------------------------------
-- RPG brain related functions to add to library
-----------------------------------------------------------------------

-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------
function CF.GetAvailableQuantumItems(gs)
	local items = {};
	local qItems = CF.QuantumItems;
	local classes = CF.QuantumItmClasses;
	local presets = CF.QuantumItmPresets;
	local modules = CF.QuantumItmModules;

	for i = 1, #qItems do
		local id = qItems[i];

		if CF.IsEntityUnlocked(gs, "Quantum", classes[id], presets[id], modules[id]) then
			local item = {};
			item["ID"] = id;
			item["Class"] = classes[id];
			item["Preset"] = presets[id];
			item["Module"] = modules[id];
			item["Price"] = CF.QuantumItmPrices[id];
			table.insert(items, item);
		end
	end

	return items;
end
-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------
function CF.RandomLockedQuantumItem(gs)
	local lockedItems = {};
	local qItems = CF.QuantumItems;
	local classes = CF.QuantumItmClasses;
	local presets = CF.QuantumItmPresets;
	local modules = CF.QuantumItmModules;

	for i = 1, #qItems do
		local id = qItems[i];

		if not CF.IsEntityUnlocked(gs, "Quantum", classes[id], presets[id], modules[id]) then
			table.insert(lockedItems, id);
		end
	end

	return lockedItems[math.random(#lockedItems)];
end
-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------
function CF.UnlockRandomQuantumItem(gs)
	local qItem = CF.RandomLockedQuantumItem(gs);
	local classes = CF.QuantumItmClasses;
	local presets = CF.QuantumItmPresets;
	local modules = CF.QuantumItmModules;
	CF.SetEntityUnlocked(gs, "Quantum", classes[qItem], presets[qItem], modules[qItem], true);
end
-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------
function CF.SetPlayerQuantumSubstance(gs, player, substance)
	if player > Activity.PLAYER_NONE and player < Activity.MAXPLAYERCOUNT then
		gs["Brain" .. player .. "QuantumStorage"] = tostring(substance);
	end
end
-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------
function CF.GetPlayerQuantumSubstance(gs, player)
	if player > Activity.PLAYER_NONE and player < Activity.MAXPLAYERCOUNT then
		return tonumber(gs["Brain" .. player .. "QuantumStorage"]);
	end
	return nil;
end