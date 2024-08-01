-----------------------------------------------------------------------------------------
--	Returns sorted array of stored items from game state. If makefilters is true, then
--	it will also return additional array with filtered items
-----------------------------------------------------------------------------------------
CF["GetStorageArray"] = function(gs, makefilters)
	local arr = {}

	-- Copy items
	for i = 1, CF["MaxStorageItems"] do
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
		arr2[CF["WeaponTypes"].PISTOL] = {}
		arr2[CF["WeaponTypes"].RIFLE] = {}
		arr2[CF["WeaponTypes"].SHOTGUN] = {}
		arr2[CF["WeaponTypes"].SNIPER] = {}
		arr2[CF["WeaponTypes"].HEAVY] = {}
		arr2[CF["WeaponTypes"].SHIELD] = {}
		arr2[CF["WeaponTypes"].DIGGER] = {}
		arr2[CF["WeaponTypes"].GRENADE] = {}
		arr2[CF["WeaponTypes"].TOOL] = {}
		arr2[CF["WeaponTypes"].BOMB] = {}

		for itm = 1, #arr do
			local f, i = CF["FindItemInFactions"](arr[itm]["Preset"], arr[itm]["Class"], arr[itm]["Module"])

			-- Add item to 'all' list
			local indx = #arr2[-1] + 1
			arr2[-1][indx] = itm

			-- Add item to 'sell' list
			local indx = #arr2[-3] + 1
			arr2[-3][indx] = itm

			if f and i then
				-- Add item to specific list
				local indx = #arr2[CF["ItmTypes"][f][i]] + 1
				arr2[CF["ItmTypes"][f][i]][indx] = itm
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
CF["GetItemShopArray"] = function(gs, makefilters)
	local arr = {}

	for i = 1, tonumber(gs["ActiveCPUs"]) do
		local f = CF["GetPlayerFaction"](gs, i)

		-- Add generic items
		for itm = 1, #CF["ItmNames"][f] do
			local applicable = false

			if
				tonumber(gs["Player" .. i .. "Reputation"]) > 0
				and tonumber(gs["Player" .. i .. "Reputation"]) >= CF["ItmUnlockData"][f][itm]
			then
				applicable = true
			end

			if not applicable then
				if gs["UnlockedItmBlueprint_" .. CF["ItmPresets"][f][itm]] then
					applicable = true
				end
			end

			for j = 1, #arr do
				if
					CF["ItmDescriptions"][f][itm] == arr[j]["Description"]
					and CF["ItmPresets"][f][itm] == arr[j]["Preset"]
				then
					applicable = false
					break
				end
			end

			if applicable then
				local ii = #arr + 1
				arr[ii] = {}
				arr[ii]["Preset"] = CF["ItmPresets"][f][itm]
				arr[ii]["Module"] = CF["ItmModules"][f][itm]
				if CF["ItmClasses"][f][itm] ~= nil then
					arr[ii]["Class"] = CF["ItmClasses"][f][itm]
				else
					arr[ii]["Class"] = "HDFirearm"
				end
				arr[ii]["Faction"] = f
				arr[ii]["Index"] = itm
				arr[ii]["Description"] = CF["ItmDescriptions"][f][itm]
				local price = math.floor(
					CF["ItmPrices"][f][itm]
							* (tonumber(gs["Player" .. i .. "Reputation"]) >= CF["ItmUnlockData"][f][itm] and 1 or CF["TechPriceMultiplier"])
						+ 0.5
				)
				--[[
				local repRatio = math.max((CF["ItmUnlockData"][f][itm] * CF["TechPriceMultiplier"])/tonumber(gs["Player"..i.."Reputation"]), 1)
				if repRatio == 1 then
					price = CF["ItmPrices"][f][itm]
				else
					price = CF["ItmPrices"][f][itm] * repRatio + 4
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
				arr[ii]["Type"] = CF["ItmTypes"][f][itm]

				--print(arr[ii]["Preset"])
				--print(arr[ii]["Class"])
			end
		end

		-- Add bombs
		for itm = 1, #CF["BombNames"] do
			local allowed = true
			local owner = ""

			if #CF["BombOwnerFactions"][itm] > 0 then
				allowed = false
				for of = 1, #CF["BombOwnerFactions"][itm] do
					--print(CF["BombOwnerFactions"][itm][of])
					if CF["BombOwnerFactions"][itm][of] == f then
						--print ("OK")
						--print (tonumber(gs["Player"..i.."Reputation"]))
						--print (CF["BombUnlockData"][itm])
						if tonumber(gs["Player" .. i .. "Reputation"]) >= CF["BombUnlockData"][itm] then
							allowed = true
							owner = f
						end
					end
				end
			end

			local isduplicate = false

			for j = 1, #arr do
				if CF["BombDescriptions"][itm] == arr[j]["Description"] and CF["BombPresets"][itm] == arr[j]["Preset"] then
					isduplicate = true
				end
			end

			if allowed and not isduplicate then
				local ii = #arr + 1
				arr[ii] = {}
				arr[ii]["Preset"] = CF["BombPresets"][itm]
				arr[ii]["Module"] = CF["BombModules"][itm]
				if CF["BombClasses"][itm] ~= nil then
					arr[ii]["Class"] = CF["BombClasses"][itm]
				else
					arr[ii]["Class"] = "TDExplosive"
				end
				arr[ii]["Faction"] = owner
				arr[ii]["Index"] = itm
				arr[ii]["Description"] = CF["BombDescriptions"][itm]
				local price = CF["BombPrices"][itm]
				if price >= 1000 then
					if price >= 10000 then
						price = math.floor(price * 0.001) * 1000
					else
						price = math.floor(price * 0.01) * 100
					end
				end
				arr[ii]["Price"] = price
				arr[ii]["Type"] = CF["WeaponTypes"].BOMB
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
		arr2[CF["WeaponTypes"].PISTOL] = {}
		arr2[CF["WeaponTypes"].RIFLE] = {}
		arr2[CF["WeaponTypes"].SHOTGUN] = {}
		arr2[CF["WeaponTypes"].SNIPER] = {}
		arr2[CF["WeaponTypes"].HEAVY] = {}
		arr2[CF["WeaponTypes"].SHIELD] = {}
		arr2[CF["WeaponTypes"].DIGGER] = {}
		arr2[CF["WeaponTypes"].GRENADE] = {}
		arr2[CF["WeaponTypes"].TOOL] = {}
		arr2[CF["WeaponTypes"].BOMB] = {} -- Bombs

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
CF["GetItemBlackMarketArray"] = function(gs, makefilters)
	-- Find out if we need to create a list of available items for this black market
	local loc = gs["Location"]
	local tocreate = gs["BlackMarket" .. loc .. "ItemsLastRefresh"] == nil
		or tonumber(gs["BlackMarket" .. loc .. "ItemsLastRefresh"]) + CF["BlackMarketRefreshInterval"]
			< tonumber(gs["Time"])

	local arr = {}

	-- Create list of items available in blackmarket
	if tocreate then
		local count = 0

		-- Add Black Market exclusives
		if #CF["BlackMarketItmPresets"] > 0 then
			for i = 1, math.random(math.floor(math.sqrt(#CF["BlackMarketItmPresets"]))) do
				local itm = math.random(#CF["BlackMarketItmPresets"])
				local isduplicate = false
				for j = 1, #arr do
					if CF["BlackMarketItmPresets"][itm] == arr[j]["Preset"] then
						isduplicate = true
						break
					end
				end
				if CF["BlackMarketItmPresets"][itm] and math.random() < (1 / i) and not isduplicate then
					count = count + 1
					gs["BlackMarket" .. loc .. "Item" .. count .. "Faction"] = "Black Market" --nil
					gs["BlackMarket" .. loc .. "Item" .. count .. "Index"] = itm

					-- Store descriptions to get rid of duplicates
					arr[count] = {}
					arr[count]["Description"] = CF["BlackMarketItmDescriptions"][itm]
					arr[count]["Preset"] = CF["BlackMarketItmPresets"][itm]
					arr[count]["Module"] = CF["BlackMarketItmModules"][itm]
				end
			end
		end
		-- Add random artifact items into the listing
		if #CF["ArtItmPresets"] > 0 then
			for itm = 1, #CF["ArtItmPresets"] do
				if gs["UnlockedItmBlackprint_" .. CF["ArtItmPresets"][itm]] then
					count = count + 1
					gs["BlackMarket" .. loc .. "Item" .. count .. "Faction"] = nil
					gs["BlackMarket" .. loc .. "Item" .. count .. "Index"] = itm

					arr[count] = {}
					arr[count]["Description"] = CF["ArtItmDescriptions"][itm]
					arr[count]["Preset"] = CF["ArtItmPresets"][itm]
					arr[count]["Module"] = CF["ArtItmModules"][itm]
				end
			end
			for i = 1, math.random(math.floor(math.sqrt(#CF["ArtItmPresets"]))) do
				local itm = math.random(#CF["ArtItmPresets"])
				local isduplicate = false
				for j = 1, #arr do
					if CF["ArtItmPresets"][itm] == arr[j]["Preset"] then
						isduplicate = true
						break
					end
				end
				if CF["ArtItmPresets"][itm] and math.random() < (1 / i) and not isduplicate then
					count = count + 1
					gs["BlackMarket" .. loc .. "Item" .. count .. "Faction"] = nil --PresetMan:GetDataModule(PresetMan:GetModuleID(CF["ArtItmModules"][itm])).FriendlyName
					gs["BlackMarket" .. loc .. "Item" .. count .. "Index"] = itm

					-- Store descriptions to get rid of duplicates
					arr[count] = {}
					arr[count]["Description"] = CF["ArtItmDescriptions"][itm]
					arr[count]["Preset"] = CF["ArtItmPresets"][itm]
					arr[count]["Module"] = CF["ArtItmModules"][itm]
				end
			end
		end
		for i = 1, tonumber(gs["ActiveCPUs"]) do
			local f = CF["GetPlayerFaction"](gs, i)

			for itm = 1, #CF["ItmNames"][f] do
				local isduplicate = false

				for j = 1, #arr do
					if
						CF["ItmDescriptions"][f][itm] == arr[j]["Description"]
						and CF["ItmPresets"][f][itm] == arr[j]["Preset"]
					then
						isduplicate = true
						break
					end
				end --]]--

				if
					CF["ItmPresets"][f][itm]
					and (CF["ItmPowers"][f][itm] == 0 or CF["ItmPowers"][f][itm] > math.random(4, 6))
					and math.random() < (0.3 / (count + 1))
					and not isduplicate
				then
					count = count + 1
					gs["BlackMarket" .. loc .. "Item" .. count .. "Faction"] = f
					gs["BlackMarket" .. loc .. "Item" .. count .. "Index"] = itm
					-- Store descriptions to get rid of duplicates
					arr[count] = {}
					arr[count]["Description"] = CF["ItmDescriptions"][f][itm]
					arr[count]["Preset"] = CF["ItmPresets"][f][itm]
					arr[count]["Module"] = CF["ItmModules"][f][itm]
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
		local funds = math.sqrt(CF["GetPlayerGold"](gs, 0))

		if f then
			if f == "Black Market" then
				arr[ii]["Faction"] = CF["BlackMarketItmModules"][itm] == CF["ModuleName"] and "Black Market" or nil
				arr[ii]["Index"] = itm

				arr[ii]["Preset"] = CF["BlackMarketItmPresets"][itm]
				arr[ii]["Module"] = CF["BlackMarketItmModules"][itm]
				arr[ii]["Class"] = CF["BlackMarketItmClasses"][itm] or "HDFirearm"
				arr[ii]["Description"] = CF["BlackMarketItmDescriptions"][itm] or "DESCRIPTION UNAVAILABLE"
				local price = (funds * CF["BlackMarketPriceMultiplier"] * RangeRand(0.5, 0.75))
					+ (CF["BlackMarketItmPrices"][itm] * CF["BlackMarketPriceMultiplier"])
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
				arr[ii]["Price"] = math.max(math.floor(price), CF["UnknownItemPrice"])
				--arr[ii]["Type"] = CF["BlackMarketItmTypes"][itm]
			elseif CF["ItmPresets"][f][itm] then
				arr[ii]["Faction"] = f
				arr[ii]["Index"] = itm

				-- In case somebody will change number of items in faction file, check every item
				arr[ii]["Preset"] = CF["ItmPresets"][f][itm]
				arr[ii]["Module"] = CF["ItmModules"][f][itm]
				if CF["ItmClasses"][f][itm] ~= nil then
					arr[ii]["Class"] = CF["ItmClasses"][f][itm]
				else
					arr[ii]["Class"] = "HDFirearm"
				end
				arr[ii]["Description"] = CF["ItmDescriptions"][f][itm]
				local price = (funds * CF["BlackMarketPriceMultiplier"] * RangeRand(0.5, 0.75))
					+ (CF["ItmPrices"][f][itm] * CF["BlackMarketPriceMultiplier"])
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
				arr[ii]["Price"] = math.max(math.floor(price), CF["UnknownItemPrice"])
				arr[ii]["Type"] = CF["ItmTypes"][f][itm]
			end
		else -- No faction = it's an Artifact
			arr[ii]["Index"] = itm

			arr[ii]["Preset"] = CF["ArtItmPresets"][itm]
			arr[ii]["Module"] = CF["ArtItmModules"][itm]

			arr[ii]["Class"] = CF["ArtItmClasses"][itm] and CF["ArtItmClasses"][itm] or "HDFirearm"

			arr[ii]["Description"] = CF["ArtItmDescriptions"][itm] or "DESCRIPTION UNAVAILABLE"
			local multiplier = CF["BlackMarketPriceMultiplier"]
			if gs["UnlockedItmBlackprint_" .. CF["ArtItmPresets"][itm]] then
				multiplier = multiplier * 0.5
			end
			local price = (funds * multiplier * RangeRand(0.5, 0.75))
				+ (CF["ArtItmPrices"][itm] and CF["ArtItmPrices"][itm] * multiplier or 1000)
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
			arr[ii]["Price"] = math.max(math.floor(price), CF["UnknownItemPrice"])
			--arr[ii]["Type"] = CF["ItmTypes"][f][itm]
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
		arr2[CF["WeaponTypes"].PISTOL] = {}
		arr2[CF["WeaponTypes"].RIFLE] = {}
		arr2[CF["WeaponTypes"].SHOTGUN] = {}
		arr2[CF["WeaponTypes"].SNIPER] = {}
		arr2[CF["WeaponTypes"].HEAVY] = {}
		arr2[CF["WeaponTypes"].SHIELD] = {}
		arr2[CF["WeaponTypes"].DIGGER] = {}
		arr2[CF["WeaponTypes"].GRENADE] = {}
		arr2[CF["WeaponTypes"].TOOL] = {}

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
CF["GetCloneShopArray"] = function(gs, makefilters)
	local arr = {}

	for i = 1, tonumber(gs["ActiveCPUs"]) do
		local f = CF["GetPlayerFaction"](gs, i)

		for itm = 1, #CF["ActNames"][f] do
			local applicable = false

			if not applicable then
				if
					tonumber(gs["Player" .. i .. "Reputation"]) > 0
					and tonumber(gs["Player" .. i .. "Reputation"]) >= CF["ActUnlockData"][f][itm]
				then
					applicable = true
				end
			end

			if not applicable then
				if gs["UnlockedActBlueprint_" .. CF["ActPresets"][f][itm]] then
					applicable = true
				end
			end

			for j = 1, #arr do
				if
					CF["ActDescriptions"][f][itm] == arr[j]["Description"]
					and CF["ActPresets"][f][itm] == arr[j]["Preset"]
				then
					applicable = false
					break
				end
			end

			if applicable then
				local ii = #arr + 1
				arr[ii] = {}
				arr[ii]["Preset"] = CF["ActPresets"][f][itm]
				arr[ii]["Class"] = CF["ActClasses"][f][itm] or "AHuman"

				arr[ii]["Faction"] = f
				arr[ii]["Index"] = itm
				arr[ii]["Description"] = CF["ActDescriptions"][f][itm]
				local price = math.floor(
					CF["ActPrices"][f][itm]
							* (tonumber(gs["Player" .. i .. "Reputation"]) >= CF["ActUnlockData"][f][itm] and 1 or CF["TechPriceMultiplier"])
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
				arr[ii]["Type"] = CF["ActTypes"][f][itm]
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
		arr2[CF["ActorTypes"].LIGHT] = {}
		arr2[CF["ActorTypes"].HEAVY] = {}
		arr2[CF["ActorTypes"].ARMOR] = {}
		arr2[CF["ActorTypes"].TURRET] = {}

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
CF["GetCloneBlackMarketArray"] = function(gs, makefilters)
	-- Find out if we need to create a list of available items for this black market
	local loc = gs["Location"]
	local tocreate = false

	if gs["BlackMarket" .. loc .. "ActorsLastRefresh"] == nil then
		tocreate = true
	else
		local last = tonumber(gs["BlackMarket" .. loc .. "ActorsLastRefresh"])

		if last + CF["BlackMarketRefreshInterval"] < tonumber(gs["Time"]) then
			tocreate = true
		end
	end

	--tocreate = true -- DEBUG

	arr = {}

	-- Create list of items available in blackmarket
	if tocreate then
		local count = 0

		for i = 1, tonumber(gs["ActiveCPUs"]) do
			local f = CF["GetPlayerFaction"](gs, i)

			for itm = 1, #CF["ActNames"][f] do
				local isduplicate = false

				for j = 1, #arr do
					if
						CF["ActDescriptions"][f][itm] == arr[j]["Description"]
						and CF["ActPresets"][f][itm] == arr[j]["Preset"]
					then
						isduplicate = true
						break
					end
				end --]]--

				if
					CF["ActPowers"][f][itm] > math.random(4, 6)
					and CF["ActTypes"][f][itm] ~= CF["ActorTypes"].TURRET
					and math.random() < (0.4 / (count + 1))
					and not isduplicate
				then
					count = count + 1
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Faction"] = f
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Index"] = itm

					-- Store descriptions to get rid of duplicates
					arr[count] = {}
					arr[count]["Description"] = CF["ActDescriptions"][f][itm]
					arr[count]["Preset"] = CF["ActPresets"][f][itm]
				end
			end
		end
		if #CF["ArtActPresets"] > 0 then
			for itm = 1, #CF["ArtActPresets"] do
				if gs["UnlockedActBlackprint_" .. CF["ArtActPresets"][itm]] then
					count = count + 1
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Faction"] = nil
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Index"] = itm

					arr[count] = {}
					arr[count]["Preset"] = CF["ArtActPresets"][itm]
				end
			end
			-- Add random artifact actors into the listing
			for i = 1, math.random(math.floor(math.sqrt(#CF["ArtActPresets"]))) do
				local itm = math.random(#CF["ArtActPresets"])
				local isduplicate = false
				for j = 1, #arr do
					if CF["ArtActPresets"][itm] == arr[j]["Preset"] then
						isduplicate = true
						break
					end
				end
				if math.random() < (0.5 / (count + 1)) and not isduplicate then
					count = count + 1
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Faction"] = nil --PresetMan:GetDataModule(PresetMan:GetModuleID(CF["ArtActModules"][itm])).FriendlyName
					gs["BlackMarket" .. loc .. "Actor" .. count .. "Index"] = itm

					-- Store descriptions to get rid of duplicates
					arr[count] = {}
					arr[count]["Preset"] = CF["ArtActPresets"][itm]
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

		if f and CF["ActPresets"][f][itm] ~= nil then
			arr[ii]["Faction"] = f
			arr[ii]["Index"] = itm

			-- In case somebody will change number of items in faction file check
			-- every actor
			arr[ii]["Preset"] = CF["ActPresets"][f][itm]
			arr[ii]["Module"] = CF["ActModules"][f][itm]
			arr[ii]["Class"] = CF["ActClasses"][f][itm] or "AHuman"

			arr[ii]["Description"] = CF["ActDescriptions"][f][itm]
			local price = (math.sqrt(CF["GetPlayerGold"](gs, 0)) * CF["BlackMarketPriceMultiplier"] * RangeRand(0.75, 1.0))
				+ (CF["ActPrices"][f][itm] * CF["BlackMarketPriceMultiplier"])
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
			arr[ii]["Price"] = math.max(math.floor(price), CF["UnknownActorPrice"])
			arr[ii]["Type"] = CF["ActTypes"][f][itm]
		else -- Artifact
			arr[ii]["Index"] = itm

			arr[ii]["Preset"] = CF["ArtActPresets"][itm]
			arr[ii]["Module"] = CF["ArtActModules"][itm]

			arr[ii]["Class"] = CF["ArtActClasses"][itm] and CF["ArtActClasses"][itm] or "AHuman"

			arr[ii]["Description"] = "DESCRIPTION UNAVAILABLE"
			local multiplier = CF["BlackMarketPriceMultiplier"]
			if gs["UnlockedActBlackprint_" .. CF["ArtActPresets"][itm]] then
				multiplier = multiplier * 0.5
			end
			local price = (math.sqrt(CF["GetPlayerGold"](gs, 0)) * multiplier * RangeRand(0.75, 1.0))
				+ (CF["ArtActPrices"][itm] and CF["ArtActPrices"][itm] * multiplier or 2000)
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
			arr[ii]["Price"] = math.max(math.floor(price), CF["UnknownActorPrice"])
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
		arr2[CF["ActorTypes"].LIGHT] = {}
		arr2[CF["ActorTypes"].HEAVY] = {}
		arr2[CF["ActorTypes"].ARMOR] = {}
		arr2[CF["ActorTypes"].TURRET] = {}

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
CF["SetStorageArray"] = function(gs, arr)
	-- Clear stored array data
	for i = 1, CF["MaxStorageItems"] do
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
CF["CountUsedStorageInArray"] = function(arr)
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
CF["FindItemInFactions"] = function(preset, class, module)
	for fact = 1, #CF["Factions"] do
		local f = CF["Factions"][fact]

		for i = 1, #CF["ItmNames"][f] do
			if preset == CF["ItmPresets"][f][i] then
				if class == CF["ItmClasses"][f][i] or (class == "HDFirearm" and CF["ItmClasses"][f][i] == nil) then
					if module ~= nil then
						if module:lower() == CF["ItmModules"][f][i]:lower() then
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
CF["PutItemToStorageArray"] = function(arr, preset, class, module)
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
CF["FindActorInFactions"] = function(preset, class, module)
	for fact = 1, #CF["Factions"] do
		local f = CF["Factions"][fact]

		for i = 1, #CF["ActNames"][f] do
			if preset == CF["ActPresets"][f][i] then
				if class == CF["ActClasses"][f][i] or (class == "AHuman" and CF["ActClasses"][f][i] == nil) then
					if module ~= nil then
						if module == CF["ActModules"][f][i] then
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
CF["GetClonesArray"] = function(gs)
	local arr = {}

	-- Copy clones
	for i = 1, CF["MaxClones"] do
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
			for j = 1, #CF["LimbID"] do
				arr[i][CF["LimbID"][j]] = gs["ClonesStorage" .. i .. CF["LimbID"][j]]
			end

			arr[i]["Items"] = {}
			for itm = 1, CF["MaxItems"] do
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
CF["CountUsedClonesInArray"] = function(arr)
	return #arr
end
-----------------------------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------------------------
CF["SetClonesArray"] = function(gs, arr)
	-- Clean clones
	for i = 1, CF["MaxClones"] do
		gs["ClonesStorage" .. i .. "Preset"] = nil
		gs["ClonesStorage" .. i .. "Class"] = nil
		gs["ClonesStorage" .. i .. "Module"] = nil
		gs["ClonesStorage" .. i .. "XP"] = nil
		gs["ClonesStorage" .. i .. "Identity"] = nil
		gs["ClonesStorage" .. i .. "Prestige"] = nil
		gs["ClonesStorage" .. i .. "Name"] = nil
		for j = 1, #CF["LimbID"] do
			gs["ClonesStorage" .. i .. CF["LimbID"][j]] = nil
		end

		for itm = 1, CF["MaxItems"] do
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
		for j = 1, #CF["LimbID"] do
			gs["ClonesStorage" .. i .. CF["LimbID"][j]] = arr[i][CF["LimbID"][j]]
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
CF["PutTurretToStorageArray"] = function(arr, preset, class, module)
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
CF["GetTurretsArray"] = function(gs)
	local arr = {}

	-- Copy
	for i = 1, CF["MaxTurrets"] do
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
CF["CountUsedTurretsInArray"] = function(arr)
	local count = 0

	for i = 1, #arr do
		count = count + arr[i]["Count"]
	end

	return count
end
-----------------------------------------------------------------------------------------
--	Saves array of stored items to game state
-----------------------------------------------------------------------------------------
CF["SetTurretsArray"] = function(gs, arr)
	-- Clean clones
	for i = 1, CF["MaxTurrets"] do
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
CF["PutBombToStorageArray"] = function(arr, preset, class, module)
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
CF["GetBombsArray"] = function(gs)
	local arr = {}

	-- Copy
	for i = 1, CF["MaxBombs"] do
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
CF["CountUsedBombsInArray"] = function(arr)
	local count = 0

	for i = 1, #arr do
		count = count + arr[i]["Count"]
	end

	return count
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
CF["SetBombsArray"] = function(gs, arr)
	-- Clean clones
	for i = 1, CF["MaxBombs"] do
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
