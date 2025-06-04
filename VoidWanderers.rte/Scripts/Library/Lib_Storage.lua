-----------------------------------------------------------------------
--	Returns sorted array of stored items from game state. If makefilters is true, then
--	it will also return additional array with filtered items
-----------------------------------------------------------------------
function CF.GetStorageArray(gameState, makefilters)
	local arr = {}

	-- Copy items
	for i = 1, CF.MaxStorageItems do
		if gameState["ItemStorage" .. i .. "Preset"] ~= nil then
			arr[i] = {}
			arr[i].Preset = gameState["ItemStorage" .. i .. "Preset"]
			arr[i].Class = gameState["ItemStorage" .. i .. "Class"]
			arr[i].Module = gameState["ItemStorage" .. i .. "Module"]
			arr[i].Count = tonumber(gameState["ItemStorage" .. i .. "Count"])
		else
			break
		end
	end

	-- Sort items
	for i = 1, #arr do
		for j = 1, #arr - 1 do
			if arr[j].Preset > arr[j + 1].Preset then
				local c = arr[j + 1]
				arr[j + 1] = arr[j]
				arr[j] = c
			end
		end
	end

	local arr2
	if makefilters then
		arr2 = {}

		-- Array for all items
		arr2[-1] = {}
		-- Array for unknown items
		arr2[-2] = {}
		-- Array for sell items
		arr2[-3] = {}
		-- Arrays for items by types
		arr2[CF.WeaponTypes.PISTOL] = {}
		arr2[CF.WeaponTypes.RIFLE] = {}
		arr2[CF.WeaponTypes.SHOTGUN] = {}
		arr2[CF.WeaponTypes.SNIPER] = {}
		arr2[CF.WeaponTypes.HEAVY] = {}
		arr2[CF.WeaponTypes.SHIELD] = {}
		arr2[CF.WeaponTypes.DIGGER] = {}
		arr2[CF.WeaponTypes.GRENADE] = {}
		arr2[CF.WeaponTypes.TOOL] = {}
		arr2[CF.WeaponTypes.BOMB] = {}

		for itm = 1, #arr do
			local f, i = CF.FindItemInFactions(arr[itm].Preset, arr[itm].Class, arr[itm].Module)

			-- Add item to 'all' list
			local indx = #arr2[-1] + 1
			arr2[-1][indx] = itm

			-- Add item to 'sell' list
			local indx = #arr2[-3] + 1
			arr2[-3][indx] = itm

			if f and i then
				-- Add item to specific list
				local indx = #arr2[CF.ItmTypes[f][i]] + 1
				arr2[CF.ItmTypes[f][i]][indx] = itm
			else
				-- Add item to unknown list
				local indx = #arr2[-2] + 1
				arr2[-2][indx] = itm
			end
		end
	end

	--for i = 1, #arr do
	--	print (arr[i].Preset)
	--end

	return arr, arr2
end
-----------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------
function CF.SetStorageArray(gameState, arr)
	-- Clear stored array data
	for i = 1, CF.MaxStorageItems do
		gameState["ItemStorage" .. i .. "Preset"] = nil
		gameState["ItemStorage" .. i .. "Module"] = nil
		gameState["ItemStorage" .. i .. "Class"] = nil
		gameState["ItemStorage" .. i .. "Count"] = nil
	end

	-- Copy items
	local itm = 1

	for i = 1, #arr do
		if arr[i].Count > 0 then
			gameState["ItemStorage" .. itm .. "Preset"] = arr[i].Preset
			gameState["ItemStorage" .. itm .. "Module"] = arr[i].Module
			gameState["ItemStorage" .. itm .. "Class"] = arr[i].Class
			gameState["ItemStorage" .. itm .. "Count"] = arr[i].Count
			itm = itm + 1
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.GetItemShopArray(gameState, makefilters)
	local arr = {}

	for i = 1, tonumber(gameState["ActiveCPUs"]) do
		local f = CF.GetPlayerFaction(gameState, i)

		-- Add generic items
		for itm = 1, #CF.ItmNames[f] do
			local applicable = false

			if
				tonumber(gameState["Participant" .. i .. "Reputation"]) > 0
				and tonumber(gameState["Participant" .. i .. "Reputation"]) >= CF.ItmUnlockData[f][itm]
			then
				applicable = true
			end

			if not applicable then
				if CF.IsEntityUnlocked(gameState, "Blueprint", CF.ItmClasses[f][itm] or "HDFirearm", CF.ItmPresets[f][itm], CF.ItmModules[f][itm]) then
					applicable = true
				end
			end

			for j = 1, #arr do
				if
					CF.ItmDescriptions[f][itm] == arr[j]["Description"]
					and CF.ItmPresets[f][itm] == arr[j]["Preset"]
				then
					applicable = false
					break
				end
			end

			if applicable then
				local ii = #arr + 1
				arr[ii] = {}
				arr[ii]["Preset"] = CF.ItmPresets[f][itm]
				arr[ii]["Module"] = CF.ItmModules[f][itm]
				if CF.ItmClasses[f][itm] ~= nil then
					arr[ii]["Class"] = CF.ItmClasses[f][itm]
				else
					arr[ii]["Class"] = "HDFirearm"
				end
				arr[ii]["Faction"] = f
				arr[ii]["Index"] = itm
				arr[ii]["Description"] = CF.ItmDescriptions[f][itm]
				local price = math.floor(
					CF.ItmPrices[f][itm]
							* (tonumber(gameState["Participant" .. i .. "Reputation"]) >= CF.ItmUnlockData[f][itm] and 1 or CF.TechPriceMultiplier)
						+ 0.5
				)
				--[[
				local repRatio = math.max((CF.ItmUnlockData[f][itm] * CF.TechPriceMultiplier)/tonumber(gameState["Player"..i.."Reputation"]), 1)
				if repRatio == 1 then
					price = CF.ItmPrices[f][itm]
				else
					price = CF.ItmPrices[f][itm] * repRatio + 4
					price = price - (price % 5)
				end
				]]
				--
				if price >= 1000 then
					if price >= 10000 then
						price = math.floor(price * 0.001) * 1000
					else
						price = math.floor(price * 0.01) * 100
					end
				end

				arr[ii]["Price"] = math.floor(price)
				arr[ii]["Type"] = CF.ItmTypes[f][itm]

				--print(arr[ii]["Preset"])
				--print(arr[ii]["Class"])
			end
		end

		-- Add bombs
		for itm = 1, #CF.BombNames do
			local allowed = true
			local owner = ""

			if #CF.BombOwnerFactions[itm] > 0 then
				allowed = false
				for of = 1, #CF.BombOwnerFactions[itm] do
					--print(CF.BombOwnerFactions[itm][of])
					if CF.BombOwnerFactions[itm][of] == f then
						--print ("OK")
						--print (tonumber(gameState["Player"..i.."Reputation"]))
						--print (CF.BombUnlockData[itm])
						if tonumber(gameState["Participant" .. i .. "Reputation"]) >= CF.BombUnlockData[itm] then
							allowed = true
							owner = f
						end
					end
				end
			end

			local isduplicate = false

			for j = 1, #arr do
				if CF.BombDescriptions[itm] == arr[j]["Description"] and CF.BombPresets[itm] == arr[j]["Preset"] then
					isduplicate = true
				end
			end

			if allowed and not isduplicate then
				local ii = #arr + 1
				arr[ii] = {}
				arr[ii]["Preset"] = CF.BombPresets[itm]
				arr[ii]["Module"] = CF.BombModules[itm]
				if CF.BombClasses[itm] ~= nil then
					arr[ii]["Class"] = CF.BombClasses[itm]
				else
					arr[ii]["Class"] = "TDExplosive"
				end
				arr[ii]["Faction"] = owner
				arr[ii]["Index"] = itm
				arr[ii]["Description"] = CF.BombDescriptions[itm]
				local price = CF.BombPrices[itm]
				if price >= 1000 then
					if price >= 10000 then
						price = math.floor(price * 0.001) * 1000
					else
						price = math.floor(price * 0.01) * 100
					end
				end
				arr[ii]["Price"] = price
				arr[ii]["Type"] = CF.WeaponTypes.BOMB
			end
		end
	end

	-- Sort items
	for i = 1, #arr do
		for j = 1, #arr - 1 do
			if arr[j]["Preset"] > arr[j + 1]["Preset"] then
				local a = arr[j]
				arr[j] = arr[j + 1]
				arr[j + 1] = a
			end
		end
	end

	--for i = 1, #arr do
	--	print(arr[i]["Preset"])
	--	print(arr[i]["Class"])
	--end

	local arr2
	if makefilters then
		arr2 = {}

		-- Array for all items
		arr2[-1] = {}
		-- Arrays for items by types
		arr2[CF.WeaponTypes.PISTOL] = {}
		arr2[CF.WeaponTypes.RIFLE] = {}
		arr2[CF.WeaponTypes.SHOTGUN] = {}
		arr2[CF.WeaponTypes.SNIPER] = {}
		arr2[CF.WeaponTypes.HEAVY] = {}
		arr2[CF.WeaponTypes.SHIELD] = {}
		arr2[CF.WeaponTypes.DIGGER] = {}
		arr2[CF.WeaponTypes.GRENADE] = {}
		arr2[CF.WeaponTypes.TOOL] = {}
		arr2[CF.WeaponTypes.BOMB] = {} -- Bombs

		for itm = 1, #arr do
			-- Add item to 'all' list
			if arr[itm].Type ~= CF.WeaponTypes.BOMB then
				local indx = #arr2[-1] + 1;
				arr2[-1][indx] = itm;
			end

			-- Add item to specific list
			local tp = arr[itm].Type
			local indx = #arr2[tp] + 1
			arr2[tp][indx] = itm
		end
	end

	return arr, arr2
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.GetCloneShopArray(gameState, makefilters)
	local clones = {};

	for i = 1, tonumber(gameState["ActiveCPUs"]) do
		local faction = CF.GetPlayerFaction(gameState, i);

		for index = 1, #CF.ActNames[faction] do
			local applicable = false

			if not applicable then
				if
					tonumber(gameState["Participant" .. i .. "Reputation"]) > 0
					and tonumber(gameState["Participant" .. i .. "Reputation"]) >= CF.ActUnlockData[faction][index]
				then
					applicable = true
				end
			end

			if not applicable then
				if CF.IsEntityUnlocked(gameState, "Blueprint", CF.ActClasses[faction][index] or "AHuman", CF.ActPresets[faction][index], CF.ActModules[faction][index]) then
					applicable = true
				end
			end

			for j = 1, #clones do
				if
					CF.ActDescriptions[faction][index] == clones[j].Description
					and CF.ActPresets[faction][index] == clones[j].Preset
				then
					applicable = false
					break
				end
			end

			if applicable then
				local ii = #clones + 1
				clones[ii] = {}
				clones[ii].Preset = CF.ActPresets[faction][index]
				clones[ii].Class = CF.ActClasses[faction][index] or "AHuman"

				clones[ii].Faction = faction
				clones[ii].Index = index
				clones[ii].Description = CF.ActDescriptions[faction][index]
				local price = math.floor(
					CF.ActPrices[faction][index]
							* (tonumber(gameState["Participant" .. i .. "Reputation"]) >= CF.ActUnlockData[faction][index] and 1 or CF.TechPriceMultiplier)
						+ 0.5
				)
				if price >= 100 then
					if price >= 1000 then
						if price >= 10000 then
							price = math.floor(price * 0.001) * 1000
						else
							price = math.floor(price * 0.01) * 100
						end
					else
						price = math.floor(price * 0.1) * 10
					end
				end
				clones[ii].Price = math.floor(price)
				clones[ii].Type = CF.ActTypes[faction][index]
			end
		end
	end

	-- Sort items
	for i = 1, #clones do
		for j = 1, #clones - 1 do
			if clones[j].Preset > clones[j + 1].Preset then
				table.insert(clones, j + 1, table.remove(clones, j));
			end
		end
	end

	local filterSets = nil;

	if makefilters then
		filterSets = {
			[CF.ActorTypes.ANY] = {},
			[CF.ActorTypes.LIGHT] = {},
			[CF.ActorTypes.HEAVY] = {},
			[CF.ActorTypes.ARMOR] = {},
			[CF.ActorTypes.TURRET] = {}
		};

		for index = 1, #clones do
			local type = clones[index].Type;

			if type ~= CF.ActorTypes.TURRET then
				table.insert(filterSets[CF.ActorTypes.ANY], index);
			end

			table.insert(filterSets[type], index);
		end
	end

	return clones, filterSets;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.RefreshBlackMarketItems(gameState, location)
	local registeredCharacteristics = {};
	local count = 1;
	
	for i = 1, 100 do
		gameState["BlackMarket" .. location .. "Item" .. i .. "Class"] = nil;
		gameState["BlackMarket" .. location .. "Item" .. i .. "Preset"] = nil;
		gameState["BlackMarket" .. location .. "Item" .. i .. "Module"] = nil;
		gameState["BlackMarket" .. location .. "Item" .. i .. "Faction"] = nil;
		gameState["BlackMarket" .. location .. "Item" .. i .. "Index"] = nil;
	end

	-- Add Black Market exclusives
	-- Only store index of black market native items
	if #CF.BlackMarketItmPresets > 0 then
		for i = 1, math.random(math.floor(math.sqrt(#CF.BlackMarketItmPresets))) do
			local index = math.random(#CF.BlackMarketItmPresets);
			local class = CF.BlackMarketItmClasses[index];
			local preset = CF.BlackMarketItmPresets[index];
			local module = CF.BlackMarketItmModules[index];
			local characteristic = class .. "_" .. preset .. "_" .. module;

			local isduplicate = false;
			for j = 1, #registeredCharacteristics do
				if characteristic == registeredCharacteristics[j] then
					isduplicate = true;
					break;
				end
			end

			if CF.BlackMarketItmPresets[index] and math.random() < (1 / i) and not isduplicate then
				gameState["BlackMarket" .. location .. "Item" .. count .. "Index"] = index;
				registeredCharacteristics[count] = characteristic;
				count = count + 1;
			end
		end
	end

	-- Add known artifact items
	-- Store artifacts precisely, they are not stable between loads
	if #CF.ArtItmPresets > 0 then
		for index = 1, #CF.ArtItmPresets do
			local class = CF.ArtItmClasses[index];
			local preset = CF.ArtItmPresets[index];
			local module = CF.ArtItmModules[index];

			if CF.IsEntityUnlocked(gameState, "Blackprint", class, preset, module) then
				gameState["BlackMarket" .. location .. "Item" .. count .. "Class"] = class;
				gameState["BlackMarket" .. location .. "Item" .. count .. "Preset"] = preset;
				gameState["BlackMarket" .. location .. "Item" .. count .. "Module"] = module;
				registeredCharacteristics[count] = class .. "_" .. preset .. "_" .. module;
				count = count + 1;
			end
		end

		-- Add random artifact items
		for i = 1, math.random(math.floor(math.sqrt(#CF.ArtItmPresets))) do
			local index = math.random(#CF.ArtItmPresets);
			local class = CF.ArtItmClasses[index];
			local preset = CF.ArtItmPresets[index];
			local module = CF.ArtItmModules[index];
			local characteristic = class .. "_" .. preset .. "_" .. module;

			local isduplicate = false;
			for j = 1, #registeredCharacteristics do
				if characteristic == registeredCharacteristics[j] then
					isduplicate = true;
					break;
				end
			end

			if preset and math.random() < (1 / i) and not isduplicate then
				gameState["BlackMarket" .. location .. "Item" .. count .. "Class"] = class;
				gameState["BlackMarket" .. location .. "Item" .. count .. "Preset"] = preset;
				gameState["BlackMarket" .. location .. "Item" .. count .. "Module"] = module;
				registeredCharacteristics[count] = characteristic;
				count = count + 1;
			end
		end
	end

	-- Add completely random items
	-- Store faction and index of generic participant faction items
	for i = 1, tonumber(gameState["ActiveCPUs"]) do
		local faction = CF.GetPlayerFaction(gameState, i);

		for index = 1, #CF.ItmNames[faction] do
			local class = CF.ItmClasses[faction][index] or (print(faction .. "'s item " .. CF.ItmPresets[faction][index] .. " class unspecified.") or "HDFirearm");
			local preset = CF.ItmPresets[faction][index];
			local module = CF.ItmModules[faction][index] or (ActivityMan:PauseActivity(true, false) or error(faction .. "'s item " .. CF.ItmPresets[faction][index] .. " module unspecified..."));
			local characteristic = class .. "_" .. preset .. "_" .. module;

			local isduplicate = false;
			for j = 1, #registeredCharacteristics do
				if characteristic == registeredCharacteristics[j] then
					isduplicate = true;
					break;
				end
			end

			if not isduplicate and preset and math.random() < (1 / count) then
				gameState["BlackMarket" .. location .. "Item" .. count .. "Faction"] = faction;
				gameState["BlackMarket" .. location .. "Item" .. count .. "Index"] = index;
				registeredCharacteristics[count] = characteristic;
				count = count + 1;
			end
		end
	end

	gameState["BlackMarket" .. location .. "ItemCount"] = count;
	gameState["BlackMarket" .. location .. "ItemsLastRefresh"] = gameState["Time"];
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.RefreshBlackMarketActors(gameState, location)
	local registeredCharacteristics = {};
	local count = 1;
	
	for i = 1, 100 do
		gameState["BlackMarket" .. location .. "Actor" .. i .. "Class"] = nil;
		gameState["BlackMarket" .. location .. "Actor" .. i .. "Preset"] = nil;
		gameState["BlackMarket" .. location .. "Actor" .. i .. "Module"] = nil;
		gameState["BlackMarket" .. location .. "Actor" .. i .. "Faction"] = nil;
		gameState["BlackMarket" .. location .. "Actor" .. i .. "Index"] = nil;
	end

	-- Add known artifact actors
	-- Store artifacts precisely, they are not stable between loads
	if #CF.ArtActPresets > 0 then
		for index = 1, #CF.ArtActPresets do
			local class = CF.ArtActClasses[index];
			local preset = CF.ArtActPresets[index];
			local module = CF.ArtActModules[index];

			if CF.IsEntityUnlocked(gameState, "Blackprint", class, preset, module) then
				gameState["BlackMarket" .. location .. "Actor" .. count .. "Class"] = class;
				gameState["BlackMarket" .. location .. "Actor" .. count .. "Preset"] = preset;
				gameState["BlackMarket" .. location .. "Actor" .. count .. "Module"] = module;
				registeredCharacteristics[count] = class .. "_" .. preset .. "_" .. module;
				count = count + 1;
			end
		end

		-- Add random artifact actors
		for i = 1, math.random(math.floor(math.sqrt(#CF.ArtActPresets))) do
			local index = math.random(#CF.ArtActPresets);
			local class = CF.ArtActClasses[index];
			local preset = CF.ArtActPresets[index];
			local module = CF.ArtActModules[index];
			local characteristic = class .. "_" .. preset .. "_" .. module;

			local isduplicate = false;
			for j = 1, #registeredCharacteristics do
				if characteristic == registeredCharacteristics[j] then
					isduplicate = true;
					break;
				end
			end

			if preset and math.random() < (1 / i) and not isduplicate then
				gameState["BlackMarket" .. location .. "Actor" .. count .. "Class"] = class;
				gameState["BlackMarket" .. location .. "Actor" .. count .. "Preset"] = preset;
				gameState["BlackMarket" .. location .. "Actor" .. count .. "Module"] = module;
				registeredCharacteristics[count] = characteristic;
				count = count + 1;
			end
		end
	end

	-- Add completely random actors
	-- Store faction and index of generic participant faction actors
	for i = 1, tonumber(gameState["ActiveCPUs"]) do
		local faction = CF.GetPlayerFaction(gameState, i);

		for index = 1, #CF.ActNames[faction] do
			local class = CF.ActClasses[faction][index] or (print(faction .. "'s actor " .. CF.ActPresets[faction][index] .. " class unspecified.") or "AHuman");
			local preset = CF.ActPresets[faction][index];
			local module = CF.ActModules[faction][index] or (ActivityMan:PauseActivity(true, false) or error(faction .. "'s actor " .. CF.ActPresets[faction][index] .. " module unspecified..."));
			local characteristic = class .. "_" .. preset .. "_" .. module;

			local isduplicate = false;
			for j = 1, #registeredCharacteristics do
				if characteristic == registeredCharacteristics[j] then
					isduplicate = true;
					break;
				end
			end

			if not isduplicate and CF.ActTypes[faction][index] ~= CF.ActorTypes.TURRET and preset and math.random() < (1 / count) then
				gameState["BlackMarket" .. location .. "Actor" .. count .. "Faction"] = faction;
				gameState["BlackMarket" .. location .. "Actor" .. count .. "Index"] = index;
				registeredCharacteristics[count] = characteristic;
				count = count + 1;
			end
		end
	end

	gameState["BlackMarket" .. location .. "ActorsCount"] = count;
	gameState["BlackMarket" .. location .. "ActorsLastRefresh"] = gameState["Time"];
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.GetItemBlackMarketArray(gameState, makefilters)
	-- Find out if we need to create a list of available items for this black market
	local location = gameState["Location"];
	local time = tonumber(gameState["Time"]);
	local lastRefresh = tonumber(gameState["BlackMarket" .. location .. "ItemsLastRefresh"]);
	local refreshNeeded = lastRefresh == nil or lastRefresh + CF.BlackMarketRefreshInterval < time;

	-- Refresh black market listings
	if refreshNeeded then
		CF.RefreshBlackMarketItems(gameState, location);
	end

	-- Fill array
	local count = tonumber(gameState["BlackMarket" .. location .. "ItemCount"]) or 0;
	local items = {};

	for i = 1, count do
		local item = {};
		local faction = gameState["BlackMarket" .. location .. "Item" .. i .. "Faction"];
		local index = tonumber(gameState["BlackMarket" .. location .. "Item" .. i .. "Index"]);
		local fundFactor = math.sqrt(CF.GetPlayerGold(gameState, 0)) * RangeRand(0.5, 0.75) * CF.BlackMarketPriceMultiplier;

		-- A typical item has a faction associated, a black market item is referenced by index alone, an artifact is referenced only be preset info
		if faction then
			item.Faction = CF.FactionNames[faction];

			item.Class = CF.ItmClasses[faction][index] or (print(faction .. "'s item " .. (CF.ItmPresets[faction][index] or "ERR") .. " class unspecified.") or "HDFirearm");
			item.Preset = CF.ItmPresets[faction][index];
			item.Module = CF.ItmModules[faction][index];
			item.Description = CF.ItmDescriptions[faction][index] or "DESCRIPTION UNAVAILABLE";
			item.Price = math.max(CF.TruncateNumber(CF.ItmPrices[faction][index] + fundFactor, 1), CF.UnknownItemPrice);
			item.Type = CF.ItmTypes[faction][index];

			table.insert(items, item);
		elseif index then
			item.Faction = "[[Black Market]]";

			item.Class = CF.BlackMarketItmClasses[index];
			item.Preset = CF.BlackMarketItmPresets[index];
			item.Module = CF.BlackMarketItmModules[index];
			item.Description = CF.BlackMarketItmDescriptions[index] or "DESCRIPTION UNAVAILABLE";
			item.Price = math.max(CF.TruncateNumber(CF.BlackMarketItmPrices[index] + fundFactor, 1), CF.UnknownItemPrice);
			item.Type = CF.BlackMarketItmTypes[index];

			table.insert(items, item);
		else
			local class = gameState["BlackMarket" .. location .. "Item" .. i .. "Class"] or "";
			local preset = gameState["BlackMarket" .. location .. "Item" .. i .. "Preset"] or "";
			local module = gameState["BlackMarket" .. location .. "Item" .. i .. "Module"] or "";
			local tempEntity = PresetMan:GetPreset(class, preset, module);

			if tempEntity ~= nil and IsSceneObject(tempEntity) then
				tempEntity = ToSceneObject(tempEntity);
				item.Faction = "[[Ancient]]";

				item.Class = class;
				item.Preset = preset;
				item.Module = module;
				item.Description = tempEntity.Description or "DESCRIPTION UNAVAILABLE";
				local multiplier = CF.IsEntityUnlocked(gameState, "Blackprint", class, preset, module) and 0.5 or 1;
				local truncatedPrice = CF.TruncateNumber(tempEntity:GetGoldValue(0, 1, 1) + fundFactor, 1);
				item.Price = math.floor(math.max(truncatedPrice, CF.UnknownItemPrice) * multiplier);
				item.Type = CF.WeaponTypes.TOOL;

				table.insert(items, item);
			end
		end
	end

	-- Sort items
	for i = 1, #items do
		for j = 1, #items - 1 do
			if items[j].Preset > items[j + 1].Preset then
				local a = items[j];
				items[j] = items[j + 1];
				items[j + 1] = a;
			end
		end
	end

	local filterSets = nil;
	if makefilters then
		filterSets = {
			[CF.WeaponTypes.ANY] = {},
			[CF.WeaponTypes.PISTOL] = {},
			[CF.WeaponTypes.RIFLE] = {},
			[CF.WeaponTypes.SHOTGUN] = {},
			[CF.WeaponTypes.SNIPER] = {},
			[CF.WeaponTypes.HEAVY] = {},
			[CF.WeaponTypes.SHIELD] = {},
			[CF.WeaponTypes.DIGGER] = {},
			[CF.WeaponTypes.GRENADE] = {},
			[CF.WeaponTypes.TOOL] = {},
			[CF.WeaponTypes.BOMB] = {}
		};

		for index = 1, #items do
			table.insert(filterSets[CF.WeaponTypes.ANY], index);
			local type = items[index].Type;

			if type ~= nil and type ~= CF.WeaponTypes.ANY then
				table.insert(filterSets[type], index);
			end
		end
	end

	return items, filterSets;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.GetCloneBlackMarketArray(gameState, makefilters)
	-- Find out if we need to create a list of available actors for this black market
	local location = gameState["Location"];
	local time = tonumber(gameState["Time"]);
	local lastRefresh = tonumber(gameState["BlackMarket" .. location .. "ActorsLastRefresh"]);
	local refreshNeeded = lastRefresh == nil or lastRefresh + CF.BlackMarketRefreshInterval < time;

	-- Refresh black market listings
	if refreshNeeded then
		CF.RefreshBlackMarketActors(gameState, location);
	end

	local count = tonumber(gameState["BlackMarket" .. location .. "ActorsCount"]) or 0;
	actors = {};

	for i = 1, count do
		local actor = {};
		local faction = gameState["BlackMarket" .. location .. "Actor" .. i .. "Faction"];
		local index = tonumber(gameState["BlackMarket" .. location .. "Actor" .. i .. "Index"]);
		local fundFactor = math.sqrt(CF.GetPlayerGold(gameState, 0)) * RangeRand(0.75, 1.0) * CF.BlackMarketPriceMultiplier;

		if faction then
			actor["Faction"] = CF.FactionNames[faction];

			actor["Class"] = CF.ActClasses[faction][index] or "AHuman";
			actor["Preset"] = CF.ActPresets[faction][index];
			actor["Module"] = CF.ActModules[faction][index];
			actor["Description"] = CF.ActDescriptions[faction][index] or "DESCRIPTION UNAVAILABLE";
			actor["Price"] = math.max(CF.TruncateNumber(CF.ActPrices[faction][index] + fundFactor, 1), CF.UnknownActorPrice);
			actor["Type"] = CF.ActTypes[faction][index];

			table.insert(actors, actor);
		elseif index then
		else
			local class = gameState["BlackMarket" .. location .. "Actor" .. i .. "Class"] or "";
			local preset = gameState["BlackMarket" .. location .. "Actor" .. i .. "Preset"] or "";
			local module = gameState["BlackMarket" .. location .. "Actor" .. i .. "Module"] or "";
			local tempEntity = PresetMan:GetPreset(class, preset, module);

			if tempEntity ~= nil and IsSceneObject(tempEntity) then
				tempEntity = ToSceneObject(tempEntity);
				actor["Faction"] = "[[Ancient]]";

				actor["Class"] = class;
				actor["Preset"] = preset;
				actor["Module"] = module;
				actor["Description"] = tempEntity.Description or "DESCRIPTION UNAVAILABLE";
				local multiplier = CF.IsEntityUnlocked(gameState, "Blackprint", class, preset, module) and 0.5 or 1;
				local truncatedPrice = CF.TruncateNumber(tempEntity:GetGoldValue(0, 1, 1) + fundFactor, 1);
				actor["Price"] = math.floor(math.max(truncatedPrice, CF.UnknownActorPrice) * multiplier);
				--actor["Type"] = CF.ActorTypes.ANY;

				table.insert(actors, actor);
			end
		end
	end

	-- Sort actors
	for i = 1, #actors do
		for j = 1, #actors - 1 do
			if actors[j]["Preset"] > actors[j + 1]["Preset"] then
				local a = actors[j];
				actors[j] = actors[j + 1];
				actors[j + 1] = a;
			end
		end
	end
	
	local filterSets = nil;
	if makefilters then
		filterSets = {};

		-- Array for all items
		filterSets[CF.ActorTypes.ANY] = {};
		filterSets[CF.ActorTypes.LIGHT] = {};
		filterSets[CF.ActorTypes.HEAVY] = {};
		filterSets[CF.ActorTypes.ARMOR] = {};
		filterSets[CF.ActorTypes.TURRET] = {};

		for index = 1, #actors do
			table.insert(filterSets[CF.ActorTypes.ANY], index);

			-- Add item to specific list
			local type = actors[index]["Type"];
			if type ~= nil and type ~= CF.ActorTypes.ANY then
				table.insert(filterSets[type], index);
			end
		end
	end

	return actors, filterSets;
end
-----------------------------------------------------------------------
--	Counts used storage units in storage array
-----------------------------------------------------------------------
function CF.CountUsedStorageInArray(arr)
	local count = 0;

	for i = 1, #arr do
		if arr[i].Class == "TDExplosive" then
			count = count + math.floor(arr[i].Count / 10);
		else
			count = count + arr[i].Count;
		end
	end

	return count;
end
-----------------------------------------------------------------------
--	Searches for given item in all faction files and returns it's factions and index if found
-----------------------------------------------------------------------
function CF.FindItemInFactions(preset, class, module)
	for fact = 1, #CF.Factions do
		local f = CF.Factions[fact]

		for i = 1, #CF.ItmNames[f] do
			if preset == CF.ItmPresets[f][i] then
				if class == CF.ItmClasses[f][i] or (class == "HDFirearm" and CF.ItmClasses[f][i] == nil) then
					if module ~= nil then
						if module:lower() == CF.ItmModules[f][i]:lower() then
							return f, i
						end
					else
						return f, i
					end
				end
			end
		end
	end

	return nil, nil
end
-----------------------------------------------------------------------
--	Searches for given actor in all faction files and returns it's factions and index if found
-----------------------------------------------------------------------
function CF.FindActorInFactions(preset, class, module)
	for fact = 1, #CF.Factions do
		local f = CF.Factions[fact];

		for i = 1, #CF.ActNames[f] do
			if preset == CF.ActPresets[f][i] then
				if class == (CF.ActClasses[f][i] or "AHuman") then
					if module ~= nil then
						if module == CF.ActModules[f][i] then
							return f, i;
						end
					else
						return f, i;
					end
				end
			end
		end
	end

	return nil, nil;
end
-----------------------------------------------------------------------
--	Put item to storage array. You still need to update filters array if this is a new item.
--	Returns true if added item is new item and you need to sort and update filters
-----------------------------------------------------------------------
function CF.PutItemToStorageArray(arr, preset, class, module)
	-- Find item in storage array
	local found = 0
	local isnew = false

	--print (preset)
	--print (class)

	for j = 1, #arr do
		if arr[j].Preset == preset and arr[j].Module == module then
			found = j
		end
	end

	if found == 0 then
		found = #arr + 1
		arr[found] = {}
		arr[found].Count = 1
		arr[found].Preset = preset
		arr[found].Module = module
		arr[found].Class = class or "HDFirearm"

		isnew = true
	else
		arr[found].Count = arr[found].Count + 1
	end

	return isnew
end
-----------------------------------------------------------------------
--	Returns sorted array of stored items from game state. If makefilters is true, then
--	it will also return additional array with filtered items
-----------------------------------------------------------------------
function CF.GetClonesArray(gameState)
	local clones = {};

	-- Copy clones
	for i = 1, CF.MaxClones do
		if gameState["ClonesStorage" .. i .. "Preset"] ~= nil then
			local clone = {};
			clone.Preset = gameState["ClonesStorage" .. i .. "Preset"];
			clone.Class = gameState["ClonesStorage" .. i .. "Class"];
			clone.Module = gameState["ClonesStorage" .. i .. "Module"];
			clone.XP = gameState["ClonesStorage" .. i .. "XP"];
			clone.Identity = gameState["ClonesStorage" .. i .. "Identity"];
			clone.Player = gameState["ClonesStorage" .. i .. "Player"];
			clone.Prestige = gameState["ClonesStorage" .. i .. "Prestige"];
			clone.Name = gameState["ClonesStorage" .. i .. "Name"];
			
			for _, limbName in ipairs(CF.LimbIDs[clone.Class]) do
				clone[limbName] = gameState["ClonesStorage" .. i .. limbName];
			end

			clone.Items = {};

			for itm = 1, CF.MaxStoredActorInventory do
				if gameState["ClonesStorage" .. i .. "Item" .. itm .. "Preset"] ~= nil then
					local item = {};
					item.Preset = gameState["ClonesStorage" .. i .. "Item" .. itm .. "Preset"];
					item.Class = gameState["ClonesStorage" .. i .. "Item" .. itm .. "Class"];
					item.Module = gameState["ClonesStorage" .. i .. "Item" .. itm .. "Module"];
					table.insert(clone.Items, item);
				else
					break;
				end
			end

			table.insert(clones, clone);
		else
			break;
		end
	end

	-- Sort clones
	for i = 1, #clones do
		for j = 1, #clones - 1 do
			if clones[j].Preset > clones[j + 1].Preset then
				local c = clones[j];
				clones[j] = clones[j + 1];
				clones[j + 1] = c;
			end
		end
	end

	return clones;
end
-----------------------------------------------------------------------
--	Counts used clones in clone array
-----------------------------------------------------------------------
function CF.CountUsedClonesInArray(arr)
	return #arr
end
-----------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------
function CF.SetClonesArray(gameState, clones)
	-- Clean clones
	for i = 1, CF.MaxClones do
		gameState["ClonesStorage" .. i .. "Preset"] = nil;
		gameState["ClonesStorage" .. i .. "Class"] = nil;
		gameState["ClonesStorage" .. i .. "Module"] = nil;
		gameState["ClonesStorage" .. i .. "XP"] = nil;
		gameState["ClonesStorage" .. i .. "Identity"] = nil;
		gameState["ClonesStorage" .. i .. "Player"] = nil;
		gameState["ClonesStorage" .. i .. "Prestige"] = nil;
		gameState["ClonesStorage" .. i .. "Name"] = nil;

		for _, classLimbs in pairs(CF.LimbIDs) do
			for _, limbName in ipairs(classLimbs) do
				gameState["ClonesStorage" .. i .. limbName] = nil;
			end
		end

		for itm = 1, CF.MaxStoredActorInventory do
			gameState["ClonesStorage" .. i .. "Item" .. itm .. "Preset"] = nil;
			gameState["ClonesStorage" .. i .. "Item" .. itm .. "Class"] = nil;
			gameState["ClonesStorage" .. i .. "Item" .. itm .. "Module"] = nil;
		end
	end

	-- Save clones
	for i = 1, #clones do
		local clone = clones[i];
		gameState["ClonesStorage" .. i .. "Preset"] = clone.Preset;
		gameState["ClonesStorage" .. i .. "Class"] = clone.Class;
		gameState["ClonesStorage" .. i .. "Module"] = clone.Module;
		gameState["ClonesStorage" .. i .. "XP"] = clone.XP;
		gameState["ClonesStorage" .. i .. "Identity"] = clone.Identity;
		gameState["ClonesStorage" .. i .. "Player"] = clone.Player;
		gameState["ClonesStorage" .. i .. "Prestige"] = clone.Prestige;
		gameState["ClonesStorage" .. i .. "Name"] = clone.Name;
		
		for _, limbName in ipairs(CF.LimbIDs[clone.Class]) do
			gameState["ClonesStorage" .. i .. limbName] = clone[limbName];
		end

		for itm = 1, #clone.Items do
			local item = clone.Items[itm];
			gameState["ClonesStorage" .. i .. "Item" .. itm .. "Preset"] = item.Preset;
			gameState["ClonesStorage" .. i .. "Item" .. itm .. "Class"] = item.Class;
			gameState["ClonesStorage" .. i .. "Item" .. itm .. "Module"] = item.Module;
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.ClearOnboard(gameState)
	for i = 1, tonumber(gameState["Onboard#"]) or CF.MaxSavedActors do
		gameState["Onboard" .. i .. "Preset"] = nil;
		gameState["Onboard" .. i .. "Class"] = nil;
		gameState["Onboard" .. i .. "Module"] = nil;
		gameState["Onboard" .. i .. "X"] = nil;
		gameState["Onboard" .. i .. "Y"] = nil;
		gameState["Onboard" .. i .. "XP"] = nil;
		gameState["Onboard" .. i .. "Identity"] = nil;
		gameState["Onboard" .. i .. "Player"] = nil;
		gameState["Onboard" .. i .. "Prestige"] = nil;
		gameState["Onboard" .. i .. "Name"] = nil;
		
		for _, classLimbs in pairs(CF.LimbIDs) do
			for _, limbName in ipairs(classLimbs) do
				gameState["Onboard" .. i .. limbName] = nil;
			end
		end

		for j = 1, tonumber(gameState["Onboard" .. i .. "Item#"]) or CF.MaxSavedItemsPerActor do
			gameState["Onboard" .. i .. "Item" .. j .. "Preset"] = nil;
			gameState["Onboard" .. i .. "Item" .. j .. "Class"] = nil;
			gameState["Onboard" .. i .. "Item" .. j .. "Module"] = nil;
		end

		gameState["Onboard" .. i .. "Item#"] = nil;
	end

	gameState["Onboard#"] = nil;
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.ClearDeployed(gameState)
	for i = 1, tonumber(gameState["Deployed#"]) or CF.MaxSavedActors do
		gameState["Deployed" .. i .. "Preset"] = nil;
		gameState["Deployed" .. i .. "Class"] = nil;
		gameState["Deployed" .. i .. "Module"] = nil;
		gameState["Deployed" .. i .. "X"] = nil;
		gameState["Deployed" .. i .. "Y"] = nil;
		gameState["Deployed" .. i .. "XP"] = nil;
		gameState["Deployed" .. i .. "Identity"] = nil;
		gameState["Deployed" .. i .. "Player"] = nil;
		gameState["Deployed" .. i .. "Prestige"] = nil;
		gameState["Deployed" .. i .. "Name"] = nil;
		
		for _, classLimbs in pairs(CF.LimbIDs) do
			for _, limbName in ipairs(classLimbs) do
				gameState["Deployed" .. i .. limbName] = nil;
			end
		end

		for j = 1, tonumber(gameState["Deployed" .. i .. "Item#"]) or CF.MaxSavedItemsPerActor do
			gameState["Deployed" .. i .. "Item" .. j .. "Preset"] = nil;
			gameState["Deployed" .. i .. "Item" .. j .. "Class"] = nil;
			gameState["Deployed" .. i .. "Item" .. j .. "Module"] = nil;
		end

		gameState["Deployed" .. i .. "Item#"] = nil;
	end

	gameState["Deployed#"] = nil;
end
-----------------------------------------------------------------------
--	
-----------------------------------------------------------------------
function CF.PutTurretToStorageArray(arr, preset, class, module)
	-- Find item in storage array
	local found = 0
	local isnew = false

	--print (preset)
	--print (class)

	for j = 1, #arr do
		if arr[j].Preset == preset then
			found = j
		end
	end

	if found == 0 then
		found = #arr + 1
		arr[found] = {}
		arr[found].Count = 1
		arr[found].Preset = preset
		arr[found].Class = class or "AHuman"
		arr[found].Module = module
		isnew = true
	else
		arr[found].Count = arr[found].Count + 1
	end

	return isnew
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.GetTurretsArray(gameState)
	local arr = {}

	-- Copy
	for i = 1, CF.MaxTurrets do
		if gameState["TurretsStorage" .. i .. "Preset"] ~= nil then
			arr[i] = {}
			arr[i].Preset = gameState["TurretsStorage" .. i .. "Preset"]
			arr[i].Class = gameState["TurretsStorage" .. i .. "Class"]
			arr[i].Module = gameState["TurretsStorage" .. i .. "Module"]
			arr[i].Count = tonumber(gameState["TurretsStorage" .. i .. "Count"])
		else
			break
		end
	end

	-- Sort
	for i = 1, #arr do
		for j = 1, #arr - 1 do
			if arr[j].Preset > arr[j + 1].Preset then
				local c = arr[j]
				arr[j] = arr[j + 1]
				arr[j + 1] = c
			end
		end
	end

	return arr
end
-----------------------------------------------------------------------
--	Counts used clones in clone array
-----------------------------------------------------------------------
function CF.CountUsedTurretsInArray(arr)
	local count = 0

	for i = 1, #arr do
		count = count + arr[i].Count
	end

	return count
end
-----------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------
function CF.SetTurretsArray(gameState, arr)
	-- Clean clones
	for i = 1, CF.MaxTurrets do
		gameState["TurretsStorage" .. i .. "Preset"] = nil
		gameState["TurretsStorage" .. i .. "Class"] = nil
		gameState["TurretsStorage" .. i .. "Module"] = nil
		gameState["TurretsStorage" .. i .. "Count"] = nil
	end

	-- Save
	for i = 1, #arr do
		if gameState["TurretsStorage" .. i .. "Preset"] == "Remove turret" then
			break
		else
			gameState["TurretsStorage" .. i .. "Preset"] = arr[i].Preset
			gameState["TurretsStorage" .. i .. "Class"] = arr[i].Class
			gameState["TurretsStorage" .. i .. "Module"] = arr[i].Module
			gameState["TurretsStorage" .. i .. "Count"] = arr[i].Count
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.PutBombToStorageArray(arr, preset, class, module)
	-- Find item in storage array
	local found = 0
	local isnew = false

	--print (preset)
	--print (class)

	for j = 1, #arr do
		if arr[j].Preset == preset then
			found = j
		end
	end

	if found == 0 then
		found = #arr + 1
		arr[found] = {}
		arr[found].Count = 1
		arr[found].Preset = preset
		arr[found].Class = class or "AHuman"

		arr[found].Module = module
		isnew = true
	else
		arr[found].Count = arr[found].Count + 1
	end

	return isnew
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.GetBombsArray(gameState)
	local arr = {}

	-- Copy
	for i = 1, CF.MaxBombs do
		if gameState["BombsStorage" .. i .. "Preset"] ~= nil then
			arr[i] = {}
			arr[i].Preset = gameState["BombsStorage" .. i .. "Preset"]
			arr[i].Class = gameState["BombsStorage" .. i .. "Class"]
			arr[i].Module = gameState["BombsStorage" .. i .. "Module"]
			arr[i].Count = tonumber(gameState["BombsStorage" .. i .. "Count"])
		else
			break
		end
	end

	-- Sort
	for i = 1, #arr do
		for j = 1, #arr - 1 do
			if arr[j].Preset > arr[j + 1].Preset then
				local c = arr[j]
				arr[j] = arr[j + 1]
				arr[j + 1] = c
			end
		end
	end

	return arr
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.CountUsedBombsInArray(arr)
	local count = 0

	for i = 1, #arr do
		count = count + arr[i].Count
	end

	return count
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function CF.SetBombsArray(gameState, arr)
	-- Clean clones
	for i = 1, CF.MaxBombs do
		gameState["BombsStorage" .. i .. "Preset"] = nil
		gameState["BombsStorage" .. i .. "Class"] = nil
		gameState["BombsStorage" .. i .. "Module"] = nil
		gameState["BombsStorage" .. i .. "Count"] = nil
	end

	-- Save
	for i = 1, #arr do
		if gameState["BombsStorage" .. i .. "Preset"] == "Remove Bomb" then
			break
		else
			gameState["BombsStorage" .. i .. "Preset"] = arr[i].Preset
			gameState["BombsStorage" .. i .. "Class"] = arr[i].Class
			gameState["BombsStorage" .. i .. "Module"] = arr[i].Module
			gameState["BombsStorage" .. i .. "Count"] = arr[i].Count
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
