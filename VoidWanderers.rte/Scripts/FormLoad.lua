-----------------------------------------------------------------------
--	Load event. Put all UI element initialiations here.
-----------------------------------------------------------------------
function VoidWanderers:FormLoad()
	local el

	-- Clear old elements
	self.UI = {}

	-- Create save slots-buttons
	self.Slots = {}
	local saveSlotWidth = 180
	local saveSlotHeight = 70

	for i = 1, CF.MaxSaveGames do
		el = {};
		el.Type = CF.ElementTypes.BUTTON;
		el.Pos = Vector(0, 0);
		el.Width = saveSlotWidth - 4;
		el.Height = saveSlotHeight - 4;

		el.OnHover = self.SaveSlots_OnHover;
		el.OnClick = self.SaveSlots_OnClick;

		self.UI[#self.UI + 1] = el;

		if CF.IsFileExists(self.ModuleName, "savegame" .. i .. ".dat") then
			local config = CF.ReadDataFile("Mods/" .. self.ModuleName .. "/CampaignData/" .. "savegame" .. i .. ".dat");

			local isbroken = false;
			local reason = "";

			if not config["PlayerGold"] then
				isbroken = true;
			end

			-- Check that all used factions are installed
			for j = 1, CF.MaxCPUPlayers do
				if config["Player" .. j .. "Active"] == "True" then
					local f = config["Player" .. j .. "Faction"];

					if f == nil then
						isbroken = true;
						break;
					else
						if CF.FactionNames[f] == nil or CF.FactionPlayable[f] == false then
							isbroken = true;
							reason = "NO " .. f;
						end
					end
				end
			end
			
			local slot = {};

			if not isbroken then
				slot.Faction = CF.FactionNames[config["PlayerFaction"]];
				slot.Reason = reason;

				slot.Gold = config["PlayerGold"];
				slot.Planet = CF.PlanetName[config["Planet"]];
				slot.Time = CF.ConvertTimeToString(tonumber(config.Time) or 0);
				slot.Broken = false;
			else
				slot.Faction = "Broken slot #" .. i .. "";
				slot.Reason = reason;

				slot.Gold = config["PlayerGold"] or "N/A";
				slot.Planet = CF.PlanetName[config["Planet"] or ""] or "N/A";
				slot.Time = CF.ConvertTimeToString(tonumber(config.Time) or 0);
				slot.Broken = true;
			end

			if slot then
				el.Text = slot.Faction
				.. "\n" .. slot.Reason;
				if not slot.Broken then
					el.Text = el.Text
					.. "\n" .. slot.Planet
					.. "\n" .. slot.Time
					.. "\n\198 " .. slot.Gold .. " oz";
				end
			else
				el.Text = "EMPTY";
			end

			self.Slots[i] = slot;
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

		self.UI[i].Pos = Vector(
			self.Mid.X - ((tilesThisRow * (saveSlotWidth - 2)) / 2) + (xtile * (saveSlotWidth - 2)) - ((saveSlotWidth - 2) / 2),
			self.Mid.Y - ((self.Rows * (saveSlotHeight - 2)) / 2) + (ytile * (saveSlotHeight - 2)) + ((saveSlotHeight - 2)/ 2)
		)

		xtile = xtile + 1
		if xtile > self.SaveSlotsPerRow then
			xtile = 1
			ytile = ytile + 1
		end
	end

	el = {}
	el.Type = CF.ElementTypes.LABEL
	el.Pos = self.Mid + Vector(0, -self.Res.Y / 2 + 33)
	el.Text = "LOAD GAME"
	el.Width = 800
	el.Height = 100

	self.UI[#self.UI + 1] = el

	el = {}
	el.Type = CF.ElementTypes.BUTTON
	el.Pos = self.Mid + Vector(self.Res.X / 2 - 70 - 20, -self.Res.Y / 2 + 12 + 20)
	el.Text = "Back"
	el.Width = 140
	el.Height = 40

	el.OnClick = self.BtnBack_OnClick

	self.UI[#self.UI + 1] = el

	el = {}
	el.Type = CF.ElementTypes.LABEL
	el.Preset = nil
	el.Pos = self.Mid + Vector(0, -self.Res.Y / 2 + 28)
	el.Text = ""
	el.Width = 800
	el.Height = 100

	self.UI[#self.UI + 1] = el
	self.LblSlotDescription = el
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:SaveSlots_OnHover()
	if self.Slots[self.MouseOverElement].Empty ~= true then
		self.LblSlotDescription.Text = ""
	else
		self.LblSlotDescription.Text = ""
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:SaveSlots_OnClick()
	if not self.Slots[self.MouseOverElement].Empty then
		self.GS = CF.ReadDataFile("Mods/" .. self.ModuleName .. "/CampaignData/" .. "savegame" .. self.MouseOverElement .. ".dat")

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

		self:OnSave()
		self:LoadSaveData()
		self:FormClose()
		self.sceneToLaunch = self.GS["Scene"];
		self.scriptToLaunch = "Tactics.lua";
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:BtnBack_OnClick()
	self:FormClose()
	dofile(BASE_PATH .. "FormStart.lua")
	self:FormLoad()
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:FormClick()
	local el = self.MousePressedElement

	if el then
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:FormUpdate() end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:FormDraw() end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------

function VoidWanderers:FormClose() end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
