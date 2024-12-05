-----------------------------------------------------------------------------------------
--	Returns sorted array of stored items from game state. If makefilters is true, then
--	it will also return additional array with filtered items
-----------------------------------------------------------------------------------------
function CF.GetStorageArray(gs, makefilters)
	local arr = {}

	-- Copy items
	for i = 1, CF.MaxStorageItems do
		if gs["ItemStorage" .. i .. "Preset"] ~= nil then
			arr[i] = {}
			arr[i]["Preset"] = gs["ItemStorage" .. i .. "Preset"]
			arr[i]["Class"] = gs["ItemStorage" .. i .. "Class"]
			arr[i]["Module"] = gs["ItemStorage" .. i .. "Module"]
			arr[i]["Count"] = tonumber(gs["ItemStorage" .. i .. "Count"])
		else
			break
		end
	end

	-- Sort items
	for i = 1, #arr do
		for j = 1, #arr - 1 do
			if arr[j]["Preset"] > arr[j + 1]["Preset"] then
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
			local f, i = CF.FindItemInFactions(arr[itm]["Preset"], arr[itm]["Class"], arr[itm]["Module"])

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
	--	print (arr[i]["Preset"])
	--end

	return arr, arr2
end
-----------------------------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------------------------
function CF.SetStorageArray(gs, arr)
	-- Clear stored array data
	for i = 1, CF.MaxStorageItems do
		gs["ItemStorage" .. i .. "Preset"] = nil
		gs["ItemStorage" .. i .. "Module"] = nil
		gs["ItemStorage" .. i .. "Class"] = nil
		gs["ItemStorage" .. i .. "Count"] = nil
	end

	-- Copy items
	local itm = 1

	for i = 1, #arr do
		if arr[i]["Count"] > 0 then
			gs["ItemStorage" .. itm .. "Preset"] = arr[i]["Preset"]
			gs["ItemStorage" .. itm .. "Module"] = arr[i]["Module"]
			gs["ItemStorage" .. itm .. "Class"] = arr[i]["Class"]
			gs["ItemStorage" .. itm .. "Count"] = arr[i]["Count"]
			itm = itm + 1
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF.GetItemShopArray(gs, makefilters)
	local arr = {}

	for i = 1, tonumber(gs["ActiveCPUs"]) do
		local f = CF.GetPlayerFaction(gs, i)

		-- Add generic items
		for itm = 1, #CF.ItmNames[f] do
			local applicable = false

			if
				tonumber(gs["Player" .. i .. "Reputation"]) > 0
				and tonumber(gs["Player" .. i .. "Reputation"]) >= CF.ItmUnlockData[f][itm]
			then
				applicable = true
			end

			if not applicable then
				if CF.IsEntityUnlocked(gs, "Blueprint", CF.ItmClasses[f][itm] or "HDFirearm", CF.ItmPresets[f][itm], CF.ItmModules[f][itm]) then
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
							* (tonumber(gs["Player" .. i .. "Reputation"]) >= CF.ItmUnlockData[f][itm] and 1 or CF.TechPriceMultiplier)
						+ 0.5
				)
				--[[
				local repRatio = math.max((CF.ItmUnlockData[f][itm] * CF.TechPriceMultiplier)/tonumber(gs["Player"..i.."Reputation"]), 1)
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
						--print (tonumber(gs["Player"..i.."Reputation"]))
						--print (CF.BombUnlockData[itm])
						if tonumber(gs["Player" .. i .. "Reputation"]) >= CF.BombUnlockData[itm] then
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
			local indx = #arr2[-1] + 1
			arr2[-1][indx] = itm

			-- Add item to specific list
			local tp = arr[itm]["Type"]
			local indx = #arr2[tp] + 1
			arr2[tp][indx] = itm
		end
	end

	return arr, arr2
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF.GetCloneShopArray(gs, makefilters)
	local arr = {}

	for i = 1, tonumber(gs["ActiveCPUs"]) do
		local f = CF.GetPlayerFaction(gs, i)

		for itm = 1, #CF.ActNames[f] do
			local applicable = false

			if not applicable then
				if
					tonumber(gs["Player" .. i .. "Reputation"]) > 0
					and tonumber(gs["Player" .. i .. "Reputation"]) >= CF.ActUnlockData[f][itm]
				then
					applicable = true
				end
			end

			if not applicable then
				if CF.IsEntityUnlocked(gs, "Blueprint", CF.ActClasses[f][itm] or "AHuman", CF.ActPresets[f][itm], CF.ActModules[f][itm]) then
					applicable = true
				end
			end

			for j = 1, #arr do
				if
					CF.ActDescriptions[f][itm] == arr[j]["Description"]
					and CF.ActPresets[f][itm] == arr[j]["Preset"]
				then
					applicable = false
					break
				end
			end

			if applicable then
				local ii = #arr + 1
				arr[ii] = {}
				arr[ii]["Preset"] = CF.ActPresets[f][itm]
				arr[ii]["Class"] = CF.ActClasses[f][itm] or "AHuman"

				arr[ii]["Faction"] = f
				arr[ii]["Index"] = itm
				arr[ii]["Description"] = CF.ActDescriptions[f][itm]
				local price = math.floor(
					CF.ActPrices[f][itm]
							* (tonumber(gs["Player" .. i .. "Reputation"]) >= CF.ActUnlockData[f][itm] and 1 or CF.TechPriceMultiplier)
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
				arr[ii]["Price"] = math.floor(price)
				arr[ii]["Type"] = CF.ActTypes[f][itm]
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

	local arr2
	if makefilters then
		arr2 = {}

		-- Array for all items
		arr2[-1] = {}
		-- Arrays for items by types
		arr2[CF.ActorTypes.LIGHT] = {}
		arr2[CF.ActorTypes.HEAVY] = {}
		arr2[CF.ActorTypes.ARMOR] = {}
		arr2[CF.ActorTypes.TURRET] = {}

		for itm = 1, #arr do
			-- Add item to 'all' list
			local indx = #arr2[-1] + 1
			arr2[-1][indx] = itm

			-- Add item to specific list
			local tp = arr[itm]["Type"]
			local indx = #arr2[tp] + 1
			arr2[tp][indx] = itm
		end
	end

	return arr, arr2
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF.RefreshBlackMarketItems(gs, location)
	local registered = {};
	local count = 1;
	
	for i = 1, 100 do
		gs["BlackMarket" .. location .. "Item" .. i .. "Class"] = nil;
		gs["BlackMarket" .. location .. "Item" .. i .. "Preset"] = nil;
		gs["BlackMarket" .. location .. "Item" .. i .. "Module"] = nil;
		gs["BlackMarket" .. location .. "Item" .. i .. "Faction"] = nil;
		gs["BlackMarket" .. location .. "Item" .. i .. "Index"] = nil;
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
			for j = 1, #registered do
				if characteristic == registered[j] then
					isduplicate = true;
					break;
				end
			end

			if CF.BlackMarketItmPresets[index] and math.random() < (1 / i) and not isduplicate then
				gs["BlackMarket" .. location .. "Item" .. count .. "Index"] = index;
				registered[count] = characteristic;
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
			local characteristic = class .. "_" .. preset .. "_" .. module;

			if CF.IsEntityUnlocked(gs, "Blackprint", class, preset, module) then
				gs["BlackMarket" .. location .. "Item" .. count .. "Class"] = class;
				gs["BlackMarket" .. location .. "Item" .. count .. "Preset"] = preset;
				gs["BlackMarket" .. location .. "Item" .. count .. "Module"] = module;
				registered[count] = characteristic;
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
			for j = 1, #registered do
				if characteristic == registered[j] then
					isduplicate = true;
					break;
				end
			end

			if preset and math.random() < (1 / i) and not isduplicate then
				gs["BlackMarket" .. location .. "Item" .. count .. "Class"] = class;
				gs["BlackMarket" .. location .. "Item" .. count .. "Preset"] = preset;
				gs["BlackMarket" .. location .. "Item" .. count .. "Module"] = module;
				registered[count] = characteristic;
				count = count + 1;
			end
		end
	end

	-- Add completely random items
	-- Store faction and index of generic participant faction items
	for i = 1, tonumber(gs["ActiveCPUs"]) do
		local faction = CF.GetPlayerFaction(gs, i);

		for index = 1, #CF.ItmNames[faction] do
			local class = CF.ItmClasses[faction][index] or (print(faction .. "'s item " .. CF.ItmPresets[faction][index] .. " class unspecified.") or "HDFirearm");
			local preset = CF.ItmPresets[faction][index];
			local module = CF.ItmModules[faction][index] or (ActivityMan:PauseActivity(true, false) or error(faction .. "'s item " .. CF.ItmPresets[faction][index] .. " module unspecified..."));
			local characteristic = class .. "_" .. preset .. "_" .. module;

			local isduplicate = false;
			for j = 1, #registered do
				if characteristic == registered[j] then
					isduplicate = true;
					break;
				end
			end

			if not isduplicate and preset and math.random() < (1 / count) then
				gs["BlackMarket" .. location .. "Item" .. count .. "Faction"] = faction;
				gs["BlackMarket" .. location .. "Item" .. count .. "Index"] = index;
				registered[count] = characteristic;
				count = count + 1;
			end
		end
	end

	gs["BlackMarket" .. location .. "ItemCount"] = count;
	gs["BlackMarket" .. location .. "ItemsLastRefresh"] = gs["Time"];
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF.RefreshBlackMarketActors(gs, location)
	local registered = {};
	local count = 1;
	
	for i = 1, 100 do
		gs["BlackMarket" .. location .. "Actor" .. i .. "Class"] = nil;
		gs["BlackMarket" .. location .. "Actor" .. i .. "Preset"] = nil;
		gs["BlackMarket" .. location .. "Actor" .. i .. "Module"] = nil;
		gs["BlackMarket" .. location .. "Actor" .. i .. "Faction"] = nil;
		gs["BlackMarket" .. location .. "Actor" .. i .. "Index"] = nil;
	end

	-- Add known artifact actors
	-- Store artifacts precisely, they are not stable between loads
	if #CF.ArtActPresets > 0 then
		for index = 1, #CF.ArtActPresets do
			local class = CF.ArtActClasses[index];
			local preset = CF.ArtActPresets[index];
			local module = CF.ArtActModules[index];
			local characteristic = class .. "_" .. preset .. "_" .. module;

			if CF.IsEntityUnlocked(gs, "Blackprint", class, preset, module) then
				gs["BlackMarket" .. location .. "Actor" .. count .. "Class"] = class;
				gs["BlackMarket" .. location .. "Actor" .. count .. "Preset"] = preset;
				gs["BlackMarket" .. location .. "Actor" .. count .. "Module"] = module;
				registered[count] = characteristic;
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
			for j = 1, #registered do
				if characteristic == registered[j] then
					isduplicate = true;
					break;
				end
			end

			if preset and math.random() < (1 / i) and not isduplicate then
				gs["BlackMarket" .. location .. "Actor" .. count .. "Class"] = class;
				gs["BlackMarket" .. location .. "Actor" .. count .. "Preset"] = preset;
				gs["BlackMarket" .. location .. "Actor" .. count .. "Module"] = module;
				registered[count] = characteristic;
				count = count + 1;
			end
		end
	end

	-- Add completely random actors
	-- Store faction and index of generic participant faction actors
	for i = 1, tonumber(gs["ActiveCPUs"]) do
		local faction = CF.GetPlayerFaction(gs, i);

		for index = 1, #CF.ActNames[faction] do
			local class = CF.ActClasses[faction][index] or (print(faction .. "'s actor " .. CF.ActPresets[faction][index] .. " class unspecified.") or "AHuman");
			local preset = CF.ActPresets[faction][index];
			local module = CF.ActModules[faction][index] or (ActivityMan:PauseActivity(true, false) or error(faction .. "'s actor " .. CF.ActPresets[faction][index] .. " module unspecified..."));
			local characteristic = class .. "_" .. preset .. "_" .. module;

			local isduplicate = false;
			for j = 1, #registered do
				if characteristic == registered[j] then
					isduplicate = true;
					break;
				end
			end

			if not isduplicate and CF.ActTypes[faction][index] ~= CF.ActorTypes.TURRET and preset and math.random() < (1 / count) then
				gs["BlackMarket" .. location .. "Actor" .. count .. "Faction"] = faction;
				gs["BlackMarket" .. location .. "Actor" .. count .. "Index"] = index;
				registered[count] = characteristic;
				count = count + 1;
			end
		end
	end

	gs["BlackMarket" .. location .. "ActorsCount"] = count;
	gs["BlackMarket" .. location .. "ActorsLastRefresh"] = gs["Time"];
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF.GetItemBlackMarketArray(gs, makefilters)
	-- Find out if we need to create a list of available items for this black market
	local location = gs["Location"];
	local time = tonumber(gs["Time"]);
	local lastRefresh = tonumber(gs["BlackMarket" .. location .. "ItemsLastRefresh"]);
	local refreshNeeded = lastRefresh == nil or lastRefresh + CF.BlackMarketRefreshInterval < time;

	-- Refresh black market listings
	if refreshNeeded then
		CF.RefreshBlackMarketItems(gs, location);
	end

	-- Fill array
	local count = tonumber(gs["BlackMarket" .. location .. "ItemCount"]) or 0;
	local items = {};

	for i = 1, count do
		local item = {};
		local faction = gs["BlackMarket" .. location .. "Item" .. i .. "Faction"];
		local index = tonumber(gs["BlackMarket" .. location .. "Item" .. i .. "Index"]);
		local fundFactor = math.sqrt(CF.GetPlayerGold(gs, 0)) * RangeRand(0.5, 0.75) * CF.BlackMarketPriceMultiplier;

		-- Faction typical items have a faction, duh
		if faction then
			item["Faction"] = CF.FactionNames[faction];

			item["Class"] = CF.ItmClasses[faction][index] or (print(faction .. "'s item " .. (CF.ItmPresets[faction][index] or "ERR") .. " class unspecified.") or "HDFirearm");
			item["Preset"] = CF.ItmPresets[faction][index];
			item["Module"] = CF.ItmModules[faction][index];
			item["Description"] = CF.ItmDescriptions[faction][index] or "DESCRIPTION UNAVAILABLE";
			local price = CF.ItmPrices[faction][index] + fundFactor;
			local digitFactor = math.pow(10, math.max(0, math.floor(math.log10(price)) - 2));
			price = math.floor(price / digitFactor) * digitFactor;
			item["Price"] = math.max(math.floor(price), CF.UnknownItemPrice);
			item["Type"] = CF.ItmTypes[faction][index];

			table.insert(items, item);
		elseif index then
			item["Faction"] = "[[Black Market]]";

			item["Class"] = CF.BlackMarketItmClasses[index];
			item["Preset"] = CF.BlackMarketItmPresets[index];
			item["Module"] = CF.BlackMarketItmModules[index];
			item["Description"] = CF.BlackMarketItmDescriptions[index] or "DESCRIPTION UNAVAILABLE";
			local price = CF.BlackMarketItmPrices[index] + fundFactor;
			local digitFactor = math.pow(10, math.max(0, math.floor(math.log10(price)) - 2));
			price = math.floor(price / digitFactor) * digitFactor;
			item["Price"] = math.max(math.floor(price), CF.UnknownItemPrice);
			item["Type"] = CF.BlackMarketItmTypes[index];

			table.insert(items, item);
		else
			local class = gs["BlackMarket" .. location .. "Item" .. i .. "Class"] or "";
			local preset = gs["BlackMarket" .. location .. "Item" .. i .. "Preset"] or "";
			local module = gs["BlackMarket" .. location .. "Item" .. i .. "Module"] or "";
			local tempEntity = PresetMan:GetPreset(class, preset, module);

			if tempEntity ~= nil and IsSceneObject(tempEntity) then
				tempEntity = ToSceneObject(tempEntity);
				item["Faction"] = "[[Ancient]]";

				item["Class"] = class;
				item["Preset"] = preset;
				item["Module"] = module;
				item["Description"] = tempEntity.Description or "DESCRIPTION UNAVAILABLE";
				local multiplier = 1;
				if CF.IsEntityUnlocked(gs, "Blackprint", class, preset, module) then
					multiplier = 0.5;
				end
				local price = tempEntity:GetGoldValue(0, 1, 1) + fundFactor;
				local digitFactor = math.pow(10, math.max(0, math.floor(math.log10(price)) - 2));
				price = math.floor(price / digitFactor) * digitFactor;
				item["Price"] = math.max(math.floor(price), CF.UnknownItemPrice) * multiplier;
				--item["Type"] = CF.WeaponTypes.TOOL;

				table.insert(items, item);
			end
		end
	end

	-- Sort items
	for i = 1, #items do
		for j = 1, #items - 1 do
			if items[j]["Preset"] > items[j + 1]["Preset"] then
				local a = items[j];
				items[j] = items[j + 1];
				items[j + 1] = a;
			end
		end
	end

	local filterSets = nil;
	if makefilters then
		filterSets = {};

		-- Array for all items
		filterSets[CF.WeaponTypes.ANY] = {};
		filterSets[CF.WeaponTypes.PISTOL] = {};
		filterSets[CF.WeaponTypes.RIFLE] = {};
		filterSets[CF.WeaponTypes.SHOTGUN] = {};
		filterSets[CF.WeaponTypes.SNIPER] = {};
		filterSets[CF.WeaponTypes.HEAVY] = {};
		filterSets[CF.WeaponTypes.SHIELD] = {};
		filterSets[CF.WeaponTypes.DIGGER] = {};
		filterSets[CF.WeaponTypes.GRENADE] = {};
		filterSets[CF.WeaponTypes.TOOL] = {};

		for index = 1, #items do
			table.insert(filterSets[CF.WeaponTypes.ANY], index);

			-- Add item to specific list
			local type = items[index]["Type"];
			if type ~= nil and type ~= CF.WeaponTypes.ANY then
				table.insert(filterSets[type], index);
			end
		end
	end

	return items, filterSets;
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF.GetCloneBlackMarketArray(gs, makefilters)
	-- Find out if we need to create a list of available actors for this black market
	local location = gs["Location"];
	local time = tonumber(gs["Time"]);
	local lastRefresh = tonumber(gs["BlackMarket" .. location .. "ActorsLastRefresh"]);
	local refreshNeeded = lastRefresh == nil or lastRefresh + CF.BlackMarketRefreshInterval < time;

	-- Refresh black market listings
	if refreshNeeded then
		CF.RefreshBlackMarketActors(gs, location);
	end

	local count = tonumber(gs["BlackMarket" .. location .. "ActorsCount"]) or 0;
	actors = {};

	for i = 1, count do
		local actor = {};
		local faction = gs["BlackMarket" .. location .. "Actor" .. i .. "Faction"];
		local index = tonumber(gs["BlackMarket" .. location .. "Actor" .. i .. "Index"]);
		local fundFactor = math.sqrt(CF.GetPlayerGold(gs, 0)) * RangeRand(0.75, 1.0) * CF.BlackMarketPriceMultiplier;

		if faction then
			actor["Faction"] = CF.FactionNames[faction];

			actor["Class"] = CF.ActClasses[faction][index] or "AHuman";
			actor["Preset"] = CF.ActPresets[faction][index];
			actor["Module"] = CF.ActModules[faction][index];
			actor["Description"] = CF.ActDescriptions[faction][index] or "DESCRIPTION UNAVAILABLE";
			local price = CF.ActPrices[faction][index] + fundFactor;
			local digitFactor = math.pow(10, math.max(0, math.floor(math.log10(price)) - 2));
			price = math.floor(price / digitFactor) * digitFactor;
			actor["Price"] = math.max(math.floor(price), CF.UnknownActorPrice);
			actor["Type"] = CF.ActTypes[faction][index];

			table.insert(actors, actor);
		elseif index then
		else
			local class = gs["BlackMarket" .. location .. "Actor" .. i .. "Class"] or "";
			local preset = gs["BlackMarket" .. location .. "Actor" .. i .. "Preset"] or "";
			local module = gs["BlackMarket" .. location .. "Actor" .. i .. "Module"] or "";
			local tempEntity = PresetMan:GetPreset(class, preset, module);

			if tempEntity ~= nil and IsSceneObject(tempEntity) then
				tempEntity = ToSceneObject(tempEntity);
				actor["Faction"] = "[[Ancient]]";

				actor["Class"] = class;
				actor["Preset"] = preset;
				actor["Module"] = module;
				actor["Description"] = tempEntity.Description or "DESCRIPTION UNAVAILABLE";
				local multiplier = 1;
				if CF.IsEntityUnlocked(gs, "Blackprint", class, preset, module) then
					multiplier = 0.5;
				end
				local price = tempEntity:GetGoldValue(0, 1, 1) + fundFactor;
				local digitFactor = math.pow(10, math.max(0, math.floor(math.log10(price)) - 2));
				price = math.floor(price / digitFactor) * digitFactor;
				actor["Price"] = math.max(math.floor(price), CF.UnknownItemPrice) * multiplier;
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
-----------------------------------------------------------------------------------------
--	Counts used storage units in storage array
-----------------------------------------------------------------------------------------
function CF.CountUsedStorageInArray(arr)
	local count = 0

	for i = 1, #arr do
		if arr[i]["Class"] ~= "TDExplosive" then
			count = count + arr[i]["Count"]
		else
			count = count + math.floor(arr[i]["Count"] / 10)
		end
	end

	return count
end
-----------------------------------------------------------------------------------------
--	Searches for given item in all faction files and returns it's factions and index if found
-----------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------
--	Put item to storage array. You still need to update filters array if this is a new item.
--	Returns true if added item is new item and you need to sort and update filters
-----------------------------------------------------------------------------------------
function CF.PutItemToStorageArray(arr, preset, class, module)
	-- Find item in storage array
	local found = 0
	local isnew = false

	--print (preset)
	--print (class)

	for j = 1, #arr do
		if arr[j]["Preset"] == preset and arr[j]["Module"] == module then
			found = j
		end
	end

	if found == 0 then
		found = #arr + 1
		arr[found] = {}
		arr[found]["Count"] = 1
		arr[found]["Preset"] = preset
		arr[found]["Module"] = module
		arr[found]["Class"] = class or "HDFirearm"

		isnew = true
	else
		arr[found]["Count"] = arr[found]["Count"] + 1
	end

	return isnew
end
-----------------------------------------------------------------------------------------
--	Searches for given actor in all faction files and returns it's factions and index if found
-----------------------------------------------------------------------------------------
function CF.FindActorInFactions(preset, class, module)
	for fact = 1, #CF.Factions do
		local f = CF.Factions[fact]

		for i = 1, #CF.ActNames[f] do
			if preset == CF.ActPresets[f][i] then
				if class == CF.ActClasses[f][i] or (class == "AHuman" and CF.ActClasses[f][i] == nil) then
					if module ~= nil then
						if module == CF.ActModules[f][i] then
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
-----------------------------------------------------------------------------------------
--	Returns sorted array of stored items from game state. If makefilters is true, then
--	it will also return additional array with filtered items
-----------------------------------------------------------------------------------------
function CF.GetClonesArray(gs)
	local arr = {}

	-- Copy clones
	for i = 1, CF.MaxClones do
		if gs["ClonesStorage" .. i .. "Preset"] ~= nil then
			arr[i] = {}
			arr[i]["Preset"] = gs["ClonesStorage" .. i .. "Preset"]
			arr[i]["Class"] = gs["ClonesStorage" .. i .. "Class"]
			arr[i]["Module"] = gs["ClonesStorage" .. i .. "Module"]
			arr[i]["Module"] = gs["ClonesStorage" .. i .. "Module"]
			arr[i]["XP"] = gs["ClonesStorage" .. i .. "XP"]
			arr[i]["Identity"] = gs["ClonesStorage" .. i .. "Identity"]
			arr[i]["Player"] = gs["ClonesStorage" .. i .. "Player"]
			arr[i]["Prestige"] = gs["ClonesStorage" .. i .. "Prestige"]
			arr[i]["Name"] = gs["ClonesStorage" .. i .. "Name"]
			for j = 1, #CF.LimbID do
				arr[i][CF.LimbID[j]] = gs["ClonesStorage" .. i .. CF.LimbID[j]]
			end

			arr[i]["Items"] = {}
			for itm = 1, CF.MaxItems do
				if gs["ClonesStorage" .. i .. "Item" .. itm .. "Preset"] ~= nil then
					arr[i]["Items"][itm] = {}
					arr[i]["Items"][itm]["Preset"] = gs["ClonesStorage" .. i .. "Item" .. itm .. "Preset"]
					arr[i]["Items"][itm]["Class"] = gs["ClonesStorage" .. i .. "Item" .. itm .. "Class"]
					arr[i]["Items"][itm]["Module"] = gs["ClonesStorage" .. i .. "Item" .. itm .. "Module"]
				else
					break
				end
			end
		else
			break
		end
	end

	-- Sort clones
	for i = 1, #arr do
		for j = 1, #arr - 1 do
			if arr[j]["Preset"] > arr[j + 1]["Preset"] then
				local c = arr[j]
				arr[j] = arr[j + 1]
				arr[j + 1] = c
			end
		end
	end

	return arr
end

-----------------------------------------------------------------------------------------
--	Counts used clones in clone array
-----------------------------------------------------------------------------------------
function CF.CountUsedClonesInArray(arr)
	return #arr
end
-----------------------------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------------------------
function CF.SetClonesArray(gs, arr)
	-- Clean clones
	for i = 1, CF.MaxClones do
		gs["ClonesStorage" .. i .. "Preset"] = nil
		gs["ClonesStorage" .. i .. "Class"] = nil
		gs["ClonesStorage" .. i .. "Module"] = nil
		gs["ClonesStorage" .. i .. "XP"] = nil
		gs["ClonesStorage" .. i .. "Identity"] = nil
		gs["ClonesStorage" .. i .. "Player"] = nil
		gs["ClonesStorage" .. i .. "Prestige"] = nil
		gs["ClonesStorage" .. i .. "Name"] = nil
		for j = 1, #CF.LimbID do
			gs["ClonesStorage" .. i .. CF.LimbID[j]] = nil
		end

		for itm = 1, CF.MaxItems do
			gs["ClonesStorage" .. i .. "Item" .. itm .. "Preset"] = nil
			gs["ClonesStorage" .. i .. "Item" .. itm .. "Class"] = nil
			gs["ClonesStorage" .. i .. "Item" .. itm .. "Module"] = nil
		end
	end

	-- Save clones
	for i = 1, #arr do
		gs["ClonesStorage" .. i .. "Preset"] = arr[i]["Preset"]
		gs["ClonesStorage" .. i .. "Class"] = arr[i]["Class"]
		gs["ClonesStorage" .. i .. "Module"] = arr[i]["Module"]
		gs["ClonesStorage" .. i .. "XP"] = arr[i]["XP"]
		gs["ClonesStorage" .. i .. "Identity"] = arr[i]["Identity"]
		gs["ClonesStorage" .. i .. "Player"] = arr[i]["Player"]
		gs["ClonesStorage" .. i .. "Prestige"] = arr[i]["Prestige"]
		gs["ClonesStorage" .. i .. "Name"] = arr[i]["Name"]
		for j = 1, #CF.LimbID do
			gs["ClonesStorage" .. i .. CF.LimbID[j]] = arr[i][CF.LimbID[j]]
		end

		--print (tostring(i).." "..arr[i]["Preset"])
		--print (tostring(i).." "..arr[i]["Class"])

		for itm = 1, #arr[i]["Items"] do
			gs["ClonesStorage" .. i .. "Item" .. itm .. "Preset"] = arr[i]["Items"][itm]["Preset"]
			gs["ClonesStorage" .. i .. "Item" .. itm .. "Class"] = arr[i]["Items"][itm]["Class"]
			gs["ClonesStorage" .. i .. "Item" .. itm .. "Module"] = arr[i]["Items"][itm]["Module"]

			--print (tostring(i).." "..itm.." "..arr[i]["Items"][itm]["Preset"])
			--print (tostring(i).." "..itm.." "..arr[i]["Items"][itm]["Class"])
		end
	end
end
-----------------------------------------------------------------------------------------
--
--
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--
--
-----------------------------------------------------------------------------------------
function CF.PutTurretToStorageArray(arr, preset, class, module)
	-- Find item in storage array
	local found = 0
	local isnew = false

	--print (preset)
	--print (class)

	for j = 1, #arr do
		if arr[j]["Preset"] == preset then
			found = j
		end
	end

	if found == 0 then
		found = #arr + 1
		arr[found] = {}
		arr[found]["Count"] = 1
		arr[found]["Preset"] = preset
		arr[found]["Class"] = class or "AHuman"
		arr[found]["Module"] = module
		isnew = true
	else
		arr[found]["Count"] = arr[found]["Count"] + 1
	end

	return isnew
end
-----------------------------------------------------------------------------------------
--
--
-----------------------------------------------------------------------------------------
function CF.GetTurretsArray(gs)
	local arr = {}

	-- Copy
	for i = 1, CF.MaxTurrets do
		if gs["TurretsStorage" .. i .. "Preset"] ~= nil then
			arr[i] = {}
			arr[i]["Preset"] = gs["TurretsStorage" .. i .. "Preset"]
			arr[i]["Class"] = gs["TurretsStorage" .. i .. "Class"]
			arr[i]["Module"] = gs["TurretsStorage" .. i .. "Module"]
			arr[i]["Count"] = tonumber(gs["TurretsStorage" .. i .. "Count"])
		else
			break
		end
	end

	-- Sort
	for i = 1, #arr do
		for j = 1, #arr - 1 do
			if arr[j]["Preset"] > arr[j + 1]["Preset"] then
				local c = arr[j]
				arr[j] = arr[j + 1]
				arr[j + 1] = c
			end
		end
	end

	return arr
end

-----------------------------------------------------------------------------------------
--	Counts used clones in clone array
-----------------------------------------------------------------------------------------
function CF.CountUsedTurretsInArray(arr)
	local count = 0

	for i = 1, #arr do
		count = count + arr[i]["Count"]
	end

	return count
end
-----------------------------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------------------------
function CF.SetTurretsArray(gs, arr)
	-- Clean clones
	for i = 1, CF.MaxTurrets do
		gs["TurretsStorage" .. i .. "Preset"] = nil
		gs["TurretsStorage" .. i .. "Class"] = nil
		gs["TurretsStorage" .. i .. "Module"] = nil
		gs["TurretsStorage" .. i .. "Count"] = nil
	end

	-- Save
	for i = 1, #arr do
		if gs["TurretsStorage" .. i .. "Preset"] == "Remove turret" then
			break
		else
			gs["TurretsStorage" .. i .. "Preset"] = arr[i]["Preset"]
			gs["TurretsStorage" .. i .. "Class"] = arr[i]["Class"]
			gs["TurretsStorage" .. i .. "Module"] = arr[i]["Module"]
			gs["TurretsStorage" .. i .. "Count"] = arr[i]["Count"]
		end

		--print (tostring(i).." "..arr[i]["Preset"])
		--print (tostring(i).." "..arr[i]["Class"])
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--
--
-----------------------------------------------------------------------------------------
function CF.PutBombToStorageArray(arr, preset, class, module)
	-- Find item in storage array
	local found = 0
	local isnew = false

	--print (preset)
	--print (class)

	for j = 1, #arr do
		if arr[j]["Preset"] == preset then
			found = j
		end
	end

	if found == 0 then
		found = #arr + 1
		arr[found] = {}
		arr[found]["Count"] = 1
		arr[found]["Preset"] = preset
		arr[found]["Class"] = class or "AHuman"

		arr[found]["Module"] = module
		isnew = true
	else
		arr[found]["Count"] = arr[found]["Count"] + 1
	end

	return isnew
end
-----------------------------------------------------------------------------------------
--
--
-----------------------------------------------------------------------------------------
function CF.GetBombsArray(gs)
	local arr = {}

	-- Copy
	for i = 1, CF.MaxBombs do
		if gs["BombsStorage" .. i .. "Preset"] ~= nil then
			arr[i] = {}
			arr[i]["Preset"] = gs["BombsStorage" .. i .. "Preset"]
			arr[i]["Class"] = gs["BombsStorage" .. i .. "Class"]
			arr[i]["Module"] = gs["BombsStorage" .. i .. "Module"]
			arr[i]["Count"] = tonumber(gs["BombsStorage" .. i .. "Count"])
		else
			break
		end
	end

	-- Sort
	for i = 1, #arr do
		for j = 1, #arr - 1 do
			if arr[j]["Preset"] > arr[j + 1]["Preset"] then
				local c = arr[j]
				arr[j] = arr[j + 1]
				arr[j + 1] = c
			end
		end
	end

	return arr
end

-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF.CountUsedBombsInArray(arr)
	local count = 0

	for i = 1, #arr do
		count = count + arr[i]["Count"]
	end

	return count
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF.SetBombsArray(gs, arr)
	-- Clean clones
	for i = 1, CF.MaxBombs do
		gs["BombsStorage" .. i .. "Preset"] = nil
		gs["BombsStorage" .. i .. "Class"] = nil
		gs["BombsStorage" .. i .. "Module"] = nil
		gs["BombsStorage" .. i .. "Count"] = nil
	end

	-- Save
	for i = 1, #arr do
		if gs["BombsStorage" .. i .. "Preset"] == "Remove Bomb" then
			break
		else
			gs["BombsStorage" .. i .. "Preset"] = arr[i]["Preset"]
			gs["BombsStorage" .. i .. "Class"] = arr[i]["Class"]
			gs["BombsStorage" .. i .. "Module"] = arr[i]["Module"]
			gs["BombsStorage" .. i .. "Count"] = arr[i]["Count"]
		end

		--print (tostring(i).." "..arr[i]["Preset"])
		--print (tostring(i).." "..arr[i]["Class"])
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
