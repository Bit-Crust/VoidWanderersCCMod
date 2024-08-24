-----------------------------------------------------------------------------------------
--	Load event. Put all UI element initialiations here.
-----------------------------------------------------------------------------------------
function VoidWanderers:FormLoad()
	local el

	-- Clear old elements
	self.UI = {}

	-- Create save slots-buttons
	self.Slots = {}
	for i = 1, CF["MaxSaveGames"] do
		el = {}
		el["Type"] = self.ElementTypes.BUTTON
		el["Presets"] = {}
		el["Presets"][self.ButtonStates.IDLE] = "SlotWideIdle"
		el["Presets"][self.ButtonStates.MOUSE_OVER] = "SlotWideMouseOver"
		el["Presets"][self.ButtonStates.PRESSED] = "SlotWidePressed"
		el["Pos"] = Vector(0, 0) -- Will be calculated later
		el["Text"] = nil
		el["Width"] = 180
		el["Height"] = 70

		el["OnHover"] = self.SaveSlots_OnHover
		el["OnClick"] = self.SaveSlots_OnClick

		self.UI[#self.UI + 1] = el

		self.Slots[i] = {}
		self.Slots[i]["Empty"] = true

		if CF["IsFileExists"](self.ModuleName, "savegame" .. i .. ".dat") then
			local config = {}

			config = CF["ReadConfigFile"](self.ModuleName, "savegame" .. i .. ".dat")

			if config["Player0Faction"] ~= nil then
				self.Slots[i]["Faction"] = CF["FactionNames"][config["Player0Faction"]]
				self.Slots[i]["Gold"] = config["Player0Gold"]

				local tm = tonumber(config["Time"])
				local hrs
				local mins

				hrs = math.floor(tm / 3600)
				mins = math.floor((tm - hrs * 3600) / 60)

				if mins < 10 then
					mins = "0" .. mins
				end

				tm = tostring(hrs) .. ":" .. mins

				self.Slots[i]["Time"] = tm
				self.Slots[i]["Planet"] = CF["PlanetName"][config["Planet"]]
				self.Slots[i]["Empty"] = false
			else
				self.Slots[i]["Faction"] = "Empty/Broken slot #" .. i .. "\n"
			end
		else
			self.Slots[i]["Faction"] = "EMPTY"
		end
	end

	-- Place elements
	self.SaveSlotsPerRow = 4 -- Plates per row

	if CF["MaxSaveGames"] < self.SaveSlotsPerRow then
		self.SaveSlotsPerRow = CF["MaxSaveGames"]
	end

	self.Rows = math.floor(CF["MaxSaveGames"] / self.SaveSlotsPerRow + 1)

	local xtile = 1
	local ytile = 1
	local tilesperrow = 0

	-- Init factions UI
	for i = 1, CF["MaxSaveGames"] do
		if i <= CF["MaxSaveGames"] - CF["MaxSaveGames"] % self.SaveSlotsPerRow then
			tilesperrow = self.SaveSlotsPerRow
		else
			tilesperrow = CF["MaxSaveGames"] % self.SaveSlotsPerRow
		end

		self.UI[i]["Pos"] = Vector(
			self.MidX - ((tilesperrow * (180 - 2)) / 2) + (xtile * (180 - 2)) - ((180 - 2) / 2),
			self.MidY - ((self.Rows * 68) / 2) + (ytile * 68) + (68 / 2)
		)

		xtile = xtile + 1
		if xtile > self.SaveSlotsPerRow then
			xtile = 1
			ytile = ytile + 1
		end
	end

	-- Create description labels
	for i = 1, CF["MaxSaveGames"] do
		el = {}
		el["Type"] = self.ElementTypes.LABEL
		el["Preset"] = nil
		el["Pos"] = self.UI[i]["Pos"] + Vector(0, -25)
		el["Text"] = self.Slots[i]["Faction"]
		el["Width"] = 180
		el["Height"] = 70

		self.UI[#self.UI + 1] = el

		el = {}
		el["Type"] = self.ElementTypes.LABEL
		el["Preset"] = nil
		el["Pos"] = self.UI[i]["Pos"] + Vector(0, -5)
		el["Text"] = self.Slots[i]["Planet"]
		el["Width"] = 180
		el["Height"] = 70

		self.UI[#self.UI + 1] = el

		--print(self.Slots[i]["Empty"])

		if not self.Slots[i]["Empty"] then
			el = {}
			el["Type"] = self.ElementTypes.LABEL
			el["Preset"] = nil
			el["Pos"] = self.UI[i]["Pos"] + Vector(0, -15)
			el["Text"] = ""
			el["Width"] = 180
			el["Height"] = 70

			self.UI[#self.UI + 1] = el

			el = {}
			el["Type"] = self.ElementTypes.LABEL
			el["Preset"] = nil
			el["Pos"] = self.UI[i]["Pos"] + Vector(0, 10)
			el["Text"] = self.Slots[i]["Time"]
			el["Width"] = 180
			el["Height"] = 70

			self.UI[#self.UI + 1] = el

			el = {}
			el["Type"] = self.ElementTypes.LABEL
			el["Preset"] = nil
			el["Pos"] = self.UI[i]["Pos"] + Vector(0, 24)
			el["Text"] = self.Slots[i]["Gold"] .. " oz"
			el["Width"] = 180
			el["Height"] = 70

			self.UI[#self.UI + 1] = el
		end
	end

	el = {}
	el["Type"] = self.ElementTypes.LABEL
	el["Preset"] = nil
	el["Pos"] = self.Mid + Vector(0, -self.ResY2 + 33)
	el["Text"] = "SAVE GAME"
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
	el["Pos"] = self.Mid + Vector(0, -self.ResY2 + 58)
	el["Text"] = ""
	el["Width"] = 800
	el["Height"] = 100

	self.UI[#self.UI + 1] = el
	self.LblSlotDescription = el
	
	AudioMan:ClearMusicQueue()
	AudioMan:PlayMusic("Base.rte/Music/Hubnester/ccmenu.ogg", -1, -1)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SaveSlots_OnHover()
	if self.Slots[self.MouseOverElement]["Empty"] ~= true then
		self.LblSlotDescription["Text"] = "!!! WARNING, YOUR SAVED GAME WILL BE OVERWRITTEN !!!"
	else
		self.LblSlotDescription["Text"] = ""
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SaveSlots_OnClick()
	CF.WriteConfigFile(self.GS, self.ModuleName, "savegame" .. self.MouseOverElement .. ".dat")

	self:FormClose()
	self:LoadCurrentGameState()
	self:LaunchScript(self.GS["Scene"], "Tactics.lua")
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:BtnBack_OnClick()
	self:FormClose()
	self:LoadCurrentGameState()
	self:LaunchScript(self.GS["Scene"], "Tactics.lua")
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
