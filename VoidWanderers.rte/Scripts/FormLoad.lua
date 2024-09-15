-----------------------------------------------------------------------------------------
--	Load event. Put all UI element initialiations here.
-----------------------------------------------------------------------------------------
function VoidWanderers:FormLoad()
	local el

	-- Clear old elements
	self.UI = {}

	-- Create save slots-buttons
	self.Slots = {}
	local saveSlotWidth = 180
	local saveSlotHeight = 70
	for i = 1, CF.MaxSaveGames do
		el = {}
		el["Type"] = self.ElementTypes.BUTTON
		el["Presets"] = {}
		el["Presets"][self.ButtonStates.IDLE] = "SlotWideIdle"
		el["Presets"][self.ButtonStates.MOUSE_OVER] = "SlotWideMouseOver"
		el["Presets"][self.ButtonStates.PRESSED] = "SlotWidePressed"
		el["Pos"] = Vector(0, 0) -- Will be calculated later
		el["Text"] = nil
		el["Width"] = saveSlotWidth
		el["Height"] = saveSlotHeight

		el["OnHover"] = self.SaveSlots_OnHover
		el["OnClick"] = self.SaveSlots_OnClick

		self.UI[#self.UI + 1] = el

		self.Slots[i] = {}
		self.Slots[i]["Empty"] = true

		if CF.IsFileExists(self.ModuleName, "savegame" .. i .. ".dat") then
			local config = {}

			config = CF.ReadConfigFile(self.ModuleName, "savegame" .. i .. ".dat")

			local isbroken = false
			local reason = ""

			if not config["PlayerGold"] then
				isbroken = true
			end

			-- Check that all used factions are installed
			for j = 1, CF.MaxCPUPlayers do
				if config["Player" .. j .. "Active"] == "True" then
					local f = config["Player" .. j .. "Faction"]

					if f == nil then
						isbroken = true
						break
					else
						if CF.FactionNames[f] == nil or CF.FactionPlayable[f] == false then
							isbroken = true
							reason = "NO " .. f
						end
					end
				end
			end

			if not isbroken then
				self.Slots[i]["Faction"] = CF.FactionNames[config["PlayerFaction"]]
				self.Slots[i]["Gold"] = config["PlayerGold"]

				local tm = tonumber(config["Time"]) or 0
				local hrs
				local mins

				hrs = math.floor(tm / 3600)
				mins = math.floor((tm - hrs * 3600) / 60)

				if mins < 10 then
					mins = "0" .. mins
				end

				tm = tostring(hrs) .. ":" .. mins

				self.Slots[i]["Time"] = tm
				self.Slots[i]["Reason"] = reason
				self.Slots[i]["Planet"] = CF.PlanetName[config["Planet"]]
				self.Slots[i]["Empty"] = false
			else
				self.Slots[i]["Faction"] = "Broken slot #" .. i .. ""
				self.Slots[i]["Reason"] = reason
			end
		else
			self.Slots[i]["Faction"] = "EMPTY"
		end
	end

	-- Place elements
	self.SaveSlotsPerRow = 4 -- Plates per row

	if CF.MaxSaveGames < self.SaveSlotsPerRow then
		self.SaveSlotsPerRow = CF.MaxSaveGames
	end

	self.Rows = math.floor(CF.MaxSaveGames / self.SaveSlotsPerRow + 1)

	local xtile = 1
	local ytile = 1
	local tilesThisRow = 0

	-- Init factions UI
	for i = 1, CF.MaxSaveGames do
		if i <= CF.MaxSaveGames - CF.MaxSaveGames % self.SaveSlotsPerRow then
			tilesThisRow = self.SaveSlotsPerRow
		else
			tilesThisRow = CF.MaxSaveGames % self.SaveSlotsPerRow
		end

		self.UI[i]["Pos"] = Vector(
			self.MidX - ((tilesThisRow * (saveSlotWidth - 2)) / 2) + (xtile * (saveSlotWidth - 2)) - ((saveSlotWidth - 2) / 2),
			self.MidY - ((self.Rows * (saveSlotHeight - 2)) / 2) + (ytile * (saveSlotHeight - 2)) + ((saveSlotHeight - 2)/ 2)
		)

		xtile = xtile + 1
		if xtile > self.SaveSlotsPerRow then
			xtile = 1
			ytile = ytile + 1
		end
	end

	-- Create description labels
	for i = 1, CF.MaxSaveGames do
		el = {}
		el["Type"] = self.ElementTypes.LABEL
		el["Preset"] = nil
		el["Pos"] = self.UI[i]["Pos"] + Vector(0, -25)
		el["Text"] = self.Slots[i]["Faction"]
		el["Width"] = saveSlotWidth
		el["Height"] = saveSlotHeight

		self.UI[#self.UI + 1] = el

		el = {}
		el["Type"] = self.ElementTypes.LABEL
		el["Preset"] = nil
		el["Pos"] = self.UI[i]["Pos"] + Vector(0, -15)
		el["Text"] = self.Slots[i]["Reason"]
		el["Width"] = saveSlotWidth
		el["Height"] = saveSlotHeight

		self.UI[#self.UI + 1] = el

		el = {}
		el["Type"] = self.ElementTypes.LABEL
		el["Preset"] = nil
		el["Pos"] = self.UI[i]["Pos"] + Vector(0, -5)
		el["Text"] = self.Slots[i]["Planet"]
		el["Width"] = saveSlotWidth
		el["Height"] = saveSlotHeight

		self.UI[#self.UI + 1] = el

		if not self.Slots[i]["Empty"] then
			el = {}
			el["Type"] = self.ElementTypes.LABEL
			el["Preset"] = nil
			el["Pos"] = self.UI[i]["Pos"] + Vector(0, 10)
			el["Text"] = self.Slots[i]["Time"]
			el["Width"] = saveSlotWidth
			el["Height"] = saveSlotHeight

			self.UI[#self.UI + 1] = el

			el = {}
			el["Type"] = self.ElementTypes.LABEL
			el["Preset"] = nil
			el["Pos"] = self.UI[i]["Pos"] + Vector(0, 24)
			el["Text"] = self.Slots[i]["Gold"] .. " oz"
			el["Width"] = saveSlotWidth
			el["Height"] = saveSlotHeight

			self.UI[#self.UI + 1] = el
		end
	end

	el = {}
	el["Type"] = self.ElementTypes.LABEL
	el["Preset"] = nil
	el["Pos"] = self.Mid + Vector(0, -self.ResY2 + 33)
	el["Text"] = "LOAD GAME"
	el["Width"] = 800
	el["Height"] = 100

	self.UI[#self.UI + 1] = el

	el = {}
	el["Type"] = self.ElementTypes.BUTTON
	el["Presets"] = {}
	el["Presets"][self.ButtonStates.IDLE] = "SideMenuButtonSmallIdle"
	el["Presets"][self.ButtonStates.MOUSE_OVER] = "SideMenuButtonSmallMouseOver"
	el["Presets"][self.ButtonStates.PRESSED] = "SideMenuButtonSmallPressed"
	el["Pos"] = self.Mid + Vector(self.ResX2 - 70 - 20, -self.ResY2 + 12 + 20)
	el["Text"] = "Back"
	el["Width"] = 140
	el["Height"] = 40

	el["OnClick"] = self.BtnBack_OnClick

	self.UI[#self.UI + 1] = el

	el = {}
	el["Type"] = self.ElementTypes.LABEL
	el["Preset"] = nil
	el["Pos"] = self.Mid + Vector(0, -self.ResY2 + 28)
	el["Text"] = ""
	el["Width"] = 800
	el["Height"] = 100

	self.UI[#self.UI + 1] = el
	self.LblSlotDescription = el
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SaveSlots_OnHover()
	if self.Slots[self.MouseOverElement]["Empty"] ~= true then
		self.LblSlotDescription["Text"] = ""
	else
		self.LblSlotDescription["Text"] = ""
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SaveSlots_OnClick()
	if not self.Slots[self.MouseOverElement]["Empty"] then
		self.GS = CF.ReadConfigFile(self.ModuleName, "savegame" .. self.MouseOverElement .. ".dat")

		-- Reset mission listing if they are not correct
		for j = 1, CF.MaxMissions do
			local resetMissions = true
			if
				self.GS["Mission" .. j .. "Location"]
				and self.GS["Mission" .. j .. "Type"]
				and CF.LocationMissions[self.GS["Mission" .. j .. "Location"]]
			then
				for lm = 1, #CF.LocationMissions[self.GS["Mission" .. j .. "Location"]] do
					if
						self.GS["Mission" .. j .. "Type"] == CF.LocationMissions[self.GS["Mission" .. j .. "Location"]][lm]
					then
						resetMissions = false
						break
					end
				end
				if resetMissions then
					print("Mission location mismatch detected!! Mission listing has been reset!")
					CF.GenerateRandomMissions(self.GS)
					break
				end
			end
		end

		-- Completion streak will be reset, so make sure that the mission report gets fixed
		CF.MissionCombo = nil
		for i = 1, CF.MaxMissionReportLines do
			if self.GS["MissionReport" .. i] then
				if string.find(self.GS["MissionReport" .. i], "Completion streak") then
					self.GS["MissionReport" .. i] = "Completion streak: 0"
					break
				end
			else
				break
			end
		end

		self:WriteSaveData()
		self:LoadSaveData()
		self:FormClose()
		self:LaunchScript(self.GS["Scene"], "Tactics.lua")
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:BtnBack_OnClick()
	self:FormClose()
	dofile(BASE_PATH .. "FormStart.lua")
	self:FormLoad()
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormClick()
	local el = self.MousePressedElement

	if el then
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormUpdate() end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormDraw() end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------

function VoidWanderers:FormClose() end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
