function CF_GetAvailableQuantumItems(c)
	local arr = {}

	for i = 1, #CF_QuantumItems do
		local id = CF_QuantumItems[i]

		if c["QuantumItemUnlocked_" .. id] == "True" then
			local n = #arr + 1
			arr[n] = {}
			arr[n]["ID"] = id
			arr[n]["Preset"] = CF_QuantumItmPresets[id]
			arr[n]["Class"] = CF_QuantumItmClasses[id]
			arr[n]["Module"] = CF_QuantumItmModules[id]
			arr[n]["Price"] = math.ceil(CF_QuantumItmPrices[id] / 2)
		end
	end

	return arr
end

function CF_UnlockRandomQuantumItem(c)
	local id = CF_QuantumItems[math.random(#CF_QuantumItems)]

	c["QuantumItemUnlocked_" .. id] = "True"

	return id
end

function CF_SaveThisBrainSupplies(c, self)
	if self.BrainNumber > -1 then
		c["Brain" .. self.BrainNumber .. "Fix_Count"] = self.RepairCount
		c["Brain" .. self.BrainNumber .. "Heal_Count"] = self.HealCount
		c["Brain" .. self.BrainNumber .. "SelfHeal_Count"] = self.SelfHealCount
		c["Brain" .. self.BrainNumber .. "QuantumStorage"] = self.QuantumStorage
	end
end

function CF_LoadThisBrainSupplies(c, self)
	if self.BrainNumber > -1 then
		local val = tonumber(c["Brain" .. self.BrainNumber .. "Fix_Count"])
		if val ~= nil then
			self.RepairCount = val
		end

		local val = tonumber(c["Brain" .. self.BrainNumber .. "Heal_Count"])
		if val ~= nil then
			self.HealCount = val
		end

		local val = tonumber(c["Brain" .. self.BrainNumber .. "SelfHeal_Count"])
		if val ~= nil then
			self.SelfHealCount = val
		end

		local val = tonumber(c["Brain" .. self.BrainNumber .. "QuantumStorage"])
		if val ~= nil then
			self.QuantumStorage = val
		end
	end
end

function CF_ClearAllBrainsSupplies(c, b)
	c["Brain" .. b .. "Fix_Count"] = nil
	c["Brain" .. b .. "Heal_Count"] = nil
	c["Brain" .. b .. "SelfHeal_Count"] = nil
end