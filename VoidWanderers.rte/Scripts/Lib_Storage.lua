-----------------------------------------------------------------------------------------
--	Returns sorted array of stored items from game state. If makefilters is true, then
--	it will also return additional array with filtered items
-----------------------------------------------------------------------------------------
function CF_GetStorageArray(gs, makefilters)
	local arr = {}

	-- Copy items
	for i = 1, CF_MaxStorageItems do
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
		arr2[CF_WeaponTypes.PISTOL] = {}
		arr2[CF_WeaponTypes.RIFLE] = {}
		arr2[CF_WeaponTypes.SHOTGUN] = {}
		arr2[CF_WeaponTypes.SNIPER] = {}
		arr2[CF_WeaponTypes.HEAVY] = {}
		arr2[CF_WeaponTypes.SHIELD] = {}
		arr2[CF_WeaponTypes.DIGGER] = {}
		arr2[CF_WeaponTypes.GRENADE] = {}
		arr2[CF_WeaponTypes.TOOL] = {}
		arr2[CF_WeaponTypes.BOMB] = {}

		for itm = 1, #arr do
			local f, i = CF_FindItemInFactions(arr[itm]["Preset"], arr[itm]["Class"], arr[itm]["Module"])

			-- Add item to 'all' list
			local indx = #arr2[-1] + 1
			arr2[-1][indx] = itm

			-- Add item to 'sell' list
			local indx = #arr2[-3] + 1
			arr2[-3][indx] = itm

			if f and i then
				-- Add item to specific list
				local indx = #arr2[CF_ItmTypes[f][i]] + 1
				arr2[CF_ItmTypes[f][i]][indx] = itm
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
--
-----------------------------------------------------------------------------------------
function CF_GetItemShopArray(gs, makefilters)
	local arr = {}

	for i = 1, tonumber(gs["ActiveCPUs"]) do
		local f = CF_GetPlayerFaction(gs, i)

		-- Add generic items
		for itm = 1, #CF_ItmNames[f] do
			local applicable = false

			if
				tonumber(gs["Player" .. i .. "Reputation"]) > 0
				and tonumber(gs["Player" .. i .. "Reputation"]) >= CF_ItmUnlockData[f][itm]
			then
				applicable = true
			end

			if not applicable then
				if gs["UnlockedItmBlueprint_" .. CF_ItmPresets[f][itm]] then
					applicable = true
				end
			end

			for j = 1, #arr do
				if
					CF_ItmDescriptions[f][itm] == arr[j]["Description"]
					and CF_ItmPresets[f][itm] == arr[j]["Preset"]
				then
					applicable = false
					break
				end
			end

			if applicable then
				local ii = #arr + 1
				arr[ii] = {}
				arr[ii]["Preset"] = CF_ItmPresets[f][itm]
				arr[ii]["Module"] = CF_ItmModules[f][itm]
				if CF_ItmClasses[f][itm] ~= nil then
					arr[ii]["Class"] = CF_ItmClasses[f][itm]
				else
					arr[ii]["Class"] = "HDFirearm"
				end
				arr[ii]["Faction"] = f
				arr[ii]["Index"] = itm
				arr[ii]["Description"] = CF_ItmDescriptions[f][itm]
				local price = math.floor(
					CF_ItmPrices[f][itm]
							* (tonumber(gs["Player" .. i .. "Reputation"]) >= CF_ItmUnlockData[f][itm] and 1 or CF_TechPriceMultiplier)
						+ 0.5
				)
				--[[
				local repRatio = math.max((CF_ItmUnlockData[f][itm] * CF_TechPriceMultiplier)/tonumber(gs["Player"..i.."Reputation"]), 1)
				if repRatio == 1 then
					price = CF_ItmPrices[f][itm]
				else
					price = CF_ItmPrices[f][itm] * repRatio + 4
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
				arr[ii]["Type"] = CF_ItmTypes[f][itm]

				--print(arr[ii]["Preset"])
				--print(arr[ii]["Class"])
			end
		end

		-- Add bombs
		for itm = 1, #CF_BombNames do
			local allowed = true
			local owner = ""

			if #CF_BombOwnerFactions[itm] > 0 then
				allowed = false
				for of = 1, #CF_BombOwnerFactions[itm] do
					--print(CF_BombOwnerFactions[itm][of])
					if CF_BombOwnerFactions[itm][of] == f then
						--print ("OK")
						--print (tonumber(gs["Player"..i.."Reputation"]))
						--print (CF_BombUnlockData[itm])
						if tonumber(gs["Player" .. i .. "Reputation"]) >= CF_BombUnlockData[itm] then
							allowed = true
							owner = f
						end
					end
				end
			end

			local isduplicate = false

			for j = 1, #arr do
				if CF_BombDescriptions[itm] == arr[j]["Description"] and CF_BombPresets[itm] == arr[j]["Preset"] then
					isduplicate = true
				end
			end

			if allowed and not isduplicate then
				local ii = #arr + 1
				arr[ii] = {}
				arr[ii]["Preset"] = CF_BombPresets[itm]
				arr[ii]["Module"] = CF_BombModules[itm]
				if CF_BombClasses[itm] ~= nil then
					arr[ii]["Class"] = CF_BombClasses[itm]
				else
					arr[ii]["Class"] = "TDExplosive"
				end
				arr[ii]["Faction"] = owner
				arr[ii]["Index"] = itm
				arr[ii]["Description"] = CF_BombDescriptions[itm]
				local price = CF_BombPrices[itm]
				if price >= 1000 then
					if price >= 10000 then
						price = math.floor(price * 0.001) * 1000
					else
						price = math.floor(price * 0.01) * 100
					end
				end
				arr[ii]["Price"] = price
				arr[ii]["Type"] = CF_WeaponTypes.BOMB
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
		arr2[CF_WeaponTypes.PISTOL] = {}
		arr2[CF_WeaponTypes.RIFLE] = {}
		arr2[CF_WeaponTypes.SHOTGUN] = {}
		arr2[CF_WeaponTypes.SNIPER] = {}
		arr2[CF_WeaponTypes.HEAVY] = {}
		arr2[CF_WeaponTypes.SHIELD] = {}
		arr2[CF_WeaponTypes.DIGGER] = {}
		arr2[CF_WeaponTypes.GRENADE] = {}
		arr2[CF_WeaponTypes.TOOL] = {}
		arr2[CF_WeaponTypes.BOMB] = {} -- Bombs

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
function CF_GetItemBlackMarketArray(gs, makefilters)
	-- Find out if we need to create a list of available items for this black market
	local loc = gs["Location"]
	local tocreate = gs["BlackMarket" .. loc .. "ItemsLastRefresh"] == nil
		or tonumber(gs["BlackMarket" .. loc .. "ItemsLastRefresh"]) + CF_BlackMarketRefreshInterval
			< tonumber(gs["Time"])

	local arr = {}

	-- Create list of items available in blackmarket
	if tocreate then
		local count = 0

		-- Add Black Market exclusives
		if #CF_BlackMarketItmPresets > 0 then
			for i = 1, math.random(math.floor(math.sqrt(#CF_BlackMarketItmPresets))) do
				local itm = math.random(#CF_BlackMarketItmPresets)
				local isduplicate = false
				for j = 1, #arr do
					if CF_BlackMarketItmPresets[itm] == arr[j]["Preset"] then
						isduplicate = true
						break
					end
				end
				if CF_BlackMarketItmPresets[itm] and math.random() < (1 / i) and not isduplicate then
					count = count + 1
					gs["BlackMarket" .. loc .. "Item" .. count .. "Faction"] = "Black Market" --nil
					gs["BlackMarket" .. loc .. "Item" .. count .. "Index"] = itm

					-- Store descriptions to get rid of duplicates
					arr[count] = {}
					arr[count]["Description"] = CF_BlackMarketItmDescriptions[itm]
					arr[count]["Preset"] = CF_BlackMarketItmPresets[itm]
					arr[count]["Module"] = CF_BlackMarketItmModules[itm]
				end
			end
		end
		-- Add random artifact items into the listing
		if #CF_ArtItmPresets > 0 then
			for itm = 1, #CF_ArtItmPresets do
				if gs["UnlockedItmBlackprint_" .. CF_ArtItmPresets[itm]] then
					count = count + 1
					gs["BlackMarket" .. loc .. "Item" .. count .. "Faction"] = nil
					gs["BlackMarket" .. loc .. "Item" .. count .. "Index"] = itm

					arr[count] = {}
					arr[count]["Description"] = CF_ArtItmDescriptions[itm]
					arr[count]["Preset"] = CF_ArtItmPresets[itm]
					arr[count]["Module"] = CF_ArtItmModules[itm]
				end
			end
			for i = 1, math.random(math.floor(math.sqrt(#CF_ArtItmPresets))) do
				local itm = math.random(#CF_ArtItmPresets)
				local isduplicate = false
				for j = 1, #arr do
					if CF_ArtItmPresets[itm] == arr[j]["Preset"] then
						isduplicate = true
						break
					end
				end
				if CF_ArtItmPresets[itm] and math.random() < (1 / i) and not isduplicate then
					count = count + 1
					gs["BlackMarket" .. loc .. "Item" .. count .. "Faction"] = nil --PresetMan:GetDataModule(PresetMan:GetModuleID(CF_ArtItmModules[itm])).FriendlyName
					gs["BlackMarket" .. loc .. "Item" .. count .. "Index"] = itm

					-- Store descriptions to get rid of duplicates
					arr[count] = {}
					arr[count]["Description"] = CF_ArtItmDescriptions[itm]
					arr[count]["Preset"] = CF_ArtItmPresets[itm]
					arr[count]["Module"] = CF_ArtItmModules[itm]
				end
			end
		end
		for i = 1, tonumber(gs["ActiveCPUs"]) do
			local f = CF_GetPlayerFaction(gs, i)

			for itm = 1, #CF_ItmNames[f] do
				local isduplicate = false

				for j = 1, #arr do
					if
						CF_ItmDescriptions[f][itm] == arr[j]["Description"]
						and CF_ItmPresets[f][itm] == arr[j]["Preset"]
					then
						isduplicate = true
						break
					end
				end --]]--

				if
					CF_ItmPresets[f][itm]
					and (CF_ItmPowers[f][itm] == 0 or CF_ItmPowers[f][itm] > math.random(4, 6))
					and math.random() < (0.3 / (count + 1))
					and not isduplicate
				then
					count = count + 1
					gs["BlackMarket" .. loc .. "Item" .. count .. "Faction"] = f
					gs["BlackMarket" .. loc .. "Item" .. count .. "Index"] = itm
					-- Store descriptions to get rid of duplicates
					arr[count] = {}
					arr[count]["Description"] = CF_ItmDescriptions[f][itm]
					arr[count]["Preset"] = CF_ItmPresets[f][itm]
					arr[count]["Module"] = CF_ItmModules[f][itm]
				end
			end
		end
		gs["BlackMarket" .. loc .. "ItemCount"] = count
		gs["BlackMarket" .. loc .. "ItemsLastRefresh"] = gs["Time"]
	end

	-- Fill array
	local count = gs["BlackMarket" .. loc .. "ItemCount"] and tonumber(gs["BlackMarket" .. loc .. "ItemCount"]) or 0
	arr = {}

	for i = 1, count do
		local ii = #arr + 1
		arr[ii] = {}
		local f = gs["BlackMarket" .. loc .. "Item" .. i .. "Faction"]
		local itm = tonumber(gs["BlackMarket" .. loc .. "Item" .. i .. "Index"])
		local funds = math.sqrt(CF_GetPlayerGold(gs, 0))

		if f then
			if f == "Black Market" then
				arr[ii]["Faction"] = CF_BlackMarketItmModules[itm] == CF_ModuleName and "Black Market" or nil
				arr[ii]["Index"] = itm

				arr[ii]["Preset"] = CF_BlackMarketItmPresets[itm]
				arr[ii]["Module"] = CF_BlackMarketItmModules[itm]
				arr[ii]["Class"] = CF_BlackMarketItmClasses[itm] or "HDFirearm"
				arr[ii]["Description"] = CF_BlackMarketItmDescriptions[itm] or "DESCRIPTION UNAVAILABLE"
				local price = (funds * CF_BlackMarketPriceMultiplier * RangeRand(0.5, 0.75))
					+ (CF_BlackMarketItmPrices[itm] * CF_BlackMarketPriceMultiplier)
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
				arr[ii]["Price"] = math.max(math.floor(price), CF_UnknownItemPrice)
				--arr[ii]["Type"] = CF_BlackMarketItmTypes[itm]
			elseif CF_ItmPresets[f][itm] then
				arr[ii]["Faction"] = f
				arr[ii]["Index"] = itm

				-- In case somebody will change number of items in faction file, check every item
				arr[ii]["Preset"] = CF_ItmPresets[f][itm]
				arr[ii]["Module"] = CF_ItmModules[f][itm]
				if CF_ItmClasses[f][itm] ~= nil then
					arr[ii]["Class"] = CF_ItmClasses[f][itm]
				else
					arr[ii]["Class"] = "HDFirearm"
				end
				arr[ii]["Description"] = CF_ItmDescriptions[f][itm]
				local price = (funds * CF_BlackMarketPriceMultiplier * RangeRand(0.5, 0.75))
					+ (CF_ItmPrices[f][itm] * CF_BlackMarketPriceMultiplier)
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
				arr[ii]["Price"] = math.max(math.floor(price), CF_UnknownItemPrice)
				arr[ii]["Type"] = CF_ItmTypes[f][itm]
			end
		else -- No faction = it's an Artifact
			arr[ii]["Index"] = itm

			arr[ii]["Preset"] = CF_ArtItmPresets[itm]
			arr[ii]["Module"] = CF_ArtItmModules[itm]

			arr[ii]["Class"] = CF_ArtItmClasses[itm] and CF_ArtItmClasses[itm] or "HDFirearm"

			arr[ii]["Description"] = CF_ArtItmDescriptions[itm] or "DESCRIPTION UNAVAILABLE"
			local multiplier = CF_BlackMarketPriceMultiplier
			if gs["UnlockedItmBlackprint_" .. CF_ArtItmPresets[itm]] then
				multiplier = multiplier * 0.5
			end
			local price = (funds * multiplier * RangeRand(0.5, 0.75))
				+ (CF_ArtItmPrices[itm] and CF_ArtItmPrices[itm] * multiplier or 1000)
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
			arr[ii]["Price"] = math.max(math.floor(price), CF_UnknownItemPrice)
			--arr[ii]["Type"] = CF_ItmTypes[f][itm]
		end
	end

	-- Sort items
	for i = 1, #arr do
		for j = 1, #arr - 1 do
			if arr[j]["Preset"] and arr[j + 1]["Preset"] and arr[j]["Preset"] > arr[j + 1]["Preset"] then
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
		arr2[CF_WeaponTypes.PISTOL] = {}
		arr2[CF_WeaponTypes.RIFLE] = {}
		arr2[CF_WeaponTypes.SHOTGUN] = {}
		arr2[CF_WeaponTypes.SNIPER] = {}
		arr2[CF_WeaponTypes.HEAVY] = {}
		arr2[CF_WeaponTypes.SHIELD] = {}
		arr2[CF_WeaponTypes.DIGGER] = {}
		arr2[CF_WeaponTypes.GRENADE] = {}
		arr2[CF_WeaponTypes.TOOL] = {}

		for itm = 1, #arr do
			-- Add item to 'all' list
			local indx = #arr2[-1] + 1
			arr2[-1][indx] = itm

			-- Add item to specific list
			if arr[itm]["Type"] then
				local tp = arr[itm]["Type"]
				local indx = #arr2[tp] + 1
				arr2[tp][indx] = itm
			end
		end
	end

	return arr, arr2
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_GetCloneShopArray(gs, makefilters)
	local arr = {}

	for i = 1, tonumber(gs["ActiveCPUs"]) do
		local f = CF_GetPlayerFaction(gs, i)

		for itm = 1, #CF_ActNames[f] do
			local applicable = false

			if not applicable then
				if
					tonumber(gs["Player" .. i .. "Reputation"]) > 0
					and tonumber(gs["Player" .. i .. "Reputation"]) >= CF_ActUnlockData[f][itm]
				then
					applicable = true
				end
			end

			if not applicable then
				if gs["UnlockedActBlueprint_" .. CF_ActPresets[f][itm]] then
					applicable = true
				end
			end

			for j = 1, #arr do
				if
					CF_ActDescriptions[f][itm] == arr[j]["Description"]
					and CF_ActPresets[f][itm] == arr[j]["Preset"]
				then
					applicable = false
					break
				end
			end

			if applicable then
				local ii = #arr + 1
				arr[ii] = {}
				arr[ii]["Preset"] = CF_ActPresets[f][itm]
				arr[ii]["Class"] = CF_ActClasses[f][itm] or "AHuman"

				arr[ii]["Faction"] = f
				arr[ii]["Index"] = itm
				arr[ii]["Description"] = CF_ActDescriptions[f][itm]
				local price = math.floor(
					CF_ActPrices[f][itm]
							* (tonumber(gs["Player" .. i .. "Reputation"]) >= CF_ActUnlockData[f][itm] and 1 or CF_TechPriceMultiplier)
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
				arr[ii]["Type"] = CF_ActTypes[f][itm]
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
		arr2[CF_ActorTypes.LIGHT] = {}
		arr2[CF_ActorTypes.HEAVY] = {}
		arr2[CF_ActorTypes.ARMOR] = {}
		arr2[CF_ActorTypes.TURRET] = {}

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
function CF_GetCloneBlackMarketArray(gs, makefilters)
	-- Find out if we need to create a list of available items for this black market
	local loc = gs["Location"]
	local tocreate = false

	if gs["BlackMarket" .. loc .. "ActorsLastRefresh"] == nil then
		tocreate = true
	else
		local last = tonumber(gs["BlackMarket" .. loc .. "ActorsLastRefresh"])

		if last + CF_BlackMarketRefreshInterval < tonumber(gs["Time"]) then
			tocreate = true
		end
	end

	--tocreate = true -- DEBUG

	arr = {}

	-- Create list of items available in blackmarket
	if tocreate then
		local count = 0

		for i = 1, tonumber(gs["ActiveCPUs"]) do
			local f = CF_GetPlayerFaction(gs, i)

			for itm = 1, #CF_ActNames[f] do
				local isduplicate = false

				for j = 1, #arr do
					if
						CF_ActDescriptions[f][itm] == arr[j]["Description"]
						and CF_ActPresets[f][itm] == arr[j]["Preset"]
					then
						isduplicate = true
						break
					end
				end --]]--

				if
					CF_ActPowers[f][itm] > math.random(4, 6)
					and CF_ActTypes[f][itm] ~= CF_ActorTypes.TURRET
					and math.random() < (0.4 / (count + 1))
					and not isduplicate
				then
					count = count + 1
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Faction"] = f
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Index"] = itm

					-- Store descriptions to get rid of duplicates
					arr[count] = {}
					arr[count]["Description"] = CF_ActDescriptions[f][itm]
					arr[count]["Preset"] = CF_ActPresets[f][itm]
				end
			end
		end
		if #CF_ArtActPresets > 0 then
			for itm = 1, #CF_ArtActPresets do
				if gs["UnlockedActBlackprint_" .. CF_ArtActPresets[itm]] then
					count = count + 1
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Faction"] = nil
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Index"] = itm

					arr[count] = {}
					arr[count]["Preset"] = CF_ArtActPresets[itm]
				end
			end
			-- Add random artifact actors into the listing
			for i = 1, math.random(math.floor(math.sqrt(#CF_ArtActPresets))) do
				local itm = math.random(#CF_ArtActPresets)
				local isduplicate = false
				for j = 1, #arr do
					if CF_ArtActPresets[itm] == arr[j]["Preset"] then
						isduplicate = true
						break
					end
				end
				if math.random() < (0.5 / (count + 1)) and not isduplicate then
					count = count + 1
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Faction"] = nil --PresetMan:GetDataModule(PresetMan:GetModuleID(CF_ArtActModules[itm])).FriendlyName
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Index"] = itm

					-- Store descriptions to get rid of duplicates
					arr[count] = {}
					arr[count]["Preset"] = CF_ArtActPresets[itm]
				end
			end
		end
		gs["BlackMarket" .. loc .. "ActorsCount"] = count
		gs["BlackMarket" .. loc .. "ActorsLastRefresh"] = gs["Time"]
	end

	-- Fill array
	local count = tonumber(gs["BlackMarket" .. loc .. "ActorsCount"]) and tonumber(
		gs["BlackMarket" .. loc .. "ActorsCount"]
	) or 0
	arr = nil
	arr = {}

	for i = 1, count do
		local ii = #arr + 1
		arr[ii] = {}
		local f = gs["BlackMarket" .. loc .. "Actor" .. i .. "Faction"]
		local itm = tonumber(gs["BlackMarket" .. loc .. "Actor" .. i .. "Index"])

		if f and CF_ActPresets[f][itm] ~= nil then
			arr[ii]["Faction"] = f
			arr[ii]["Index"] = itm

			-- In case somebody will change number of items in faction file check
			-- every actor
			arr[ii]["Preset"] = CF_ActPresets[f][itm]
			arr[ii]["Module"] = CF_ActModules[f][itm]
			arr[ii]["Class"] = CF_ActClasses[f][itm] or "AHuman"

			arr[ii]["Description"] = CF_ActDescriptions[f][itm]
			local price = (math.sqrt(CF_GetPlayerGold(gs, 0)) * CF_BlackMarketPriceMultiplier * RangeRand(0.75, 1.0))
				+ (CF_ActPrices[f][itm] * CF_BlackMarketPriceMultiplier)
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
			arr[ii]["Price"] = math.max(math.floor(price), CF_UnknownActorPrice)
			arr[ii]["Type"] = CF_ActTypes[f][itm]
		else -- Artifact
			arr[ii]["Index"] = itm

			arr[ii]["Preset"] = CF_ArtActPresets[itm]
			arr[ii]["Module"] = CF_ArtActModules[itm]

			arr[ii]["Class"] = CF_ArtActClasses[itm] and CF_ArtActClasses[itm] or "AHuman"

			arr[ii]["Description"] = "DESCRIPTION UNAVAILABLE"
			local multiplier = CF_BlackMarketPriceMultiplier
			if gs["UnlockedActBlackprint_" .. CF_ArtActPresets[itm]] then
				multiplier = multiplier * 0.5
			end
			local price = (math.sqrt(CF_GetPlayerGold(gs, 0)) * multiplier * RangeRand(0.75, 1.0))
				+ (CF_ArtActPrices[itm] and CF_ArtActPrices[itm] * multiplier or 2000)
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
			arr[ii]["Price"] = math.max(math.floor(price), CF_UnknownActorPrice)
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
		arr2[CF_ActorTypes.LIGHT] = {}
		arr2[CF_ActorTypes.HEAVY] = {}
		arr2[CF_ActorTypes.ARMOR] = {}
		arr2[CF_ActorTypes.TURRET] = {}

		for itm = 1, #arr do
			-- Add item to 'all' list
			local indx = #arr2[-1] + 1
			arr2[-1][indx] = itm

			-- Add item to specific list
			if arr[itm]["Type"] then
				local tp = arr[itm]["Type"]
				local indx = #arr2[tp] + 1
				arr2[tp][indx] = itm
			end
		end
	end

	return arr, arr2
end
-----------------------------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------------------------
function CF_SetStorageArray(gs, arr)
	-- Clear stored array data
	for i = 1, CF_MaxStorageItems do
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
--	Counts used storage units in storage array
-----------------------------------------------------------------------------------------
function CF_CountUsedStorageInArray(arr)
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
function CF_FindItemInFactions(preset, class, module)
	for fact = 1, #CF_Factions do
		local f = CF_Factions[fact]

		for i = 1, #CF_ItmNames[f] do
			if preset == CF_ItmPresets[f][i] then
				if class == CF_ItmClasses[f][i] or (class == "HDFirearm" and CF_ItmClasses[f][i] == nil) then
					if module ~= nil then
						if module:lower() == CF_ItmModules[f][i]:lower() then
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
function CF_PutItemToStorageArray(arr, preset, class, module)
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
function CF_FindActorInFactions(preset, class, module)
	for fact = 1, #CF_Factions do
		local f = CF_Factions[fact]

		for i = 1, #CF_ActNames[f] do
			if preset == CF_ActPresets[f][i] then
				if class == CF_ActClasses[f][i] or (class == "AHuman" and CF_ActClasses[f][i] == nil) then
					if module ~= nil then
						if module == CF_ActModules[f][i] then
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
function CF_GetClonesArray(gs)
	local arr = {}

	-- Copy clones
	for i = 1, CF_MaxClones do
		if gs["ClonesStorage" .. i .. "Preset"] ~= nil then
			arr[i] = {}
			arr[i]["Preset"] = gs["ClonesStorage" .. i .. "Preset"]
			arr[i]["Class"] = gs["ClonesStorage" .. i .. "Class"]
			arr[i]["Module"] = gs["ClonesStorage" .. i .. "Module"]
			arr[i]["Module"] = gs["ClonesStorage" .. i .. "Module"]
			arr[i]["XP"] = gs["ClonesStorage" .. i .. "XP"]
			arr[i]["Identity"] = gs["ClonesStorage" .. i .. "Identity"]
			arr[i]["Prestige"] = gs["ClonesStorage" .. i .. "Prestige"]
			arr[i]["Name"] = gs["ClonesStorage" .. i .. "Name"]
			for j = 1, #CF_LimbID do
				arr[i][CF_LimbID[j]] = gs["ClonesStorage" .. i .. CF_LimbID[j]]
			end

			arr[i]["Items"] = {}
			for itm = 1, CF_MaxItems do
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
function CF_CountUsedClonesInArray(arr)
	return #arr
end
-----------------------------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------------------------
function CF_SetClonesArray(gs, arr)
	-- Clean clones
	for i = 1, CF_MaxClones do
		gs["ClonesStorage" .. i .. "Preset"] = nil
		gs["ClonesStorage" .. i .. "Class"] = nil
		gs["ClonesStorage" .. i .. "Module"] = nil
		gs["ClonesStorage" .. i .. "XP"] = nil
		gs["ClonesStorage" .. i .. "Identity"] = nil
		gs["ClonesStorage" .. i .. "Prestige"] = nil
		gs["ClonesStorage" .. i .. "Name"] = nil
		for j = 1, #CF_LimbID do
			gs["ClonesStorage" .. i .. CF_LimbID[j]] = nil
		end

		for itm = 1, CF_MaxItems do
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
		gs["ClonesStorage" .. i .. "Prestige"] = arr[i]["Prestige"]
		gs["ClonesStorage" .. i .. "Name"] = arr[i]["Name"]
		for j = 1, #CF_LimbID do
			gs["ClonesStorage" .. i .. CF_LimbID[j]] = arr[i][CF_LimbID[j]]
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
function CF_PutTurretToStorageArray(arr, preset, class, module)
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
function CF_GetTurretsArray(gs)
	local arr = {}

	-- Copy
	for i = 1, CF_MaxTurrets do
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
function CF_CountUsedTurretsInArray(arr)
	local count = 0

	for i = 1, #arr do
		count = count + arr[i]["Count"]
	end

	return count
end
-----------------------------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------------------------
function CF_SetTurretsArray(gs, arr)
	-- Clean clones
	for i = 1, CF_MaxTurrets do
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
function CF_PutBombToStorageArray(arr, preset, class, module)
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
function CF_GetBombsArray(gs)
	local arr = {}

	-- Copy
	for i = 1, CF_MaxBombs do
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
function CF_CountUsedBombsInArray(arr)
	local count = 0

	for i = 1, #arr do
		count = count + arr[i]["Count"]
	end

	return count
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function CF_SetBombsArray(gs, arr)
	-- Clean clones
	for i = 1, CF_MaxBombs do
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
