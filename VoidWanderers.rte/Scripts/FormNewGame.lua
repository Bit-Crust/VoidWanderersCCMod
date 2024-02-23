-----------------------------------------------------------------------------------------
--	Load event. Put all UI element initialiations here.
-----------------------------------------------------------------------------------------
function VoidWanderers:FormLoad()
	local el

	-- Clear old elements
	self.UI = {}

	el = {}
	el["Type"] = self.ElementTypes.LABEL
	el["Preset"] = nil
	el["Pos"] = self.Mid + Vector(0, -195)
	el["Text"] = "START NEW GAME"
	el["Width"] = 800
	el["Height"] = 100

	self.UI[#self.UI + 1] = el
	self.LblHeader = el

	el = {}
	el["Type"] = self.ElementTypes.LABEL
	el["Preset"] = nil
	el["Pos"] = self.Mid + Vector(0, -184)
	el["Text"] = "SELECT STARTING FACTION"
	el["Width"] = 800
	el["Height"] = 100

	self.UI[#self.UI + 1] = el
	self.LblPhase = el

	el = {}
	el["Type"] = self.ElementTypes.LABEL
	el["Preset"] = nil
	el["Pos"] = self.Mid + Vector(-190, math.max(-FrameMan.PlayerScreenHeight * 0.5 + 50, -165))
	el["Text"] = " - "
	el["Width"] = 400
	el["Height"] = 100
	el["Centered"] = false

	self.UI[#self.UI + 1] = el
	self.LblFactionDescription = el

	el = {}
	el["Type"] = self.ElementTypes.LABEL
	el["Preset"] = nil
	el["Pos"] = self.Mid + Vector(0, -174)
	el["Text"] = ""
	el["Width"] = 400
	el["Height"] = 100

	self.UI[#self.UI + 1] = el
	self.LblFactionName = el

	el = {}
	el["Type"] = self.ElementTypes.BUTTON
	el["Presets"] = {}
	el["Presets"][self.ButtonStates.IDLE] = "SideMenuButtonIdle"
	el["Presets"][self.ButtonStates.MOUSE_OVER] = "SideMenuButtonMouseOver"
	el["Presets"][self.ButtonStates.PRESSED] = "SideMenuButtonPressed"
	el["Pos"] = self.Mid + Vector(0, math.min(170, FrameMan.PlayerScreenHeight * 0.5 - 50))
	el["Text"] = "OK"
	el["Width"] = 140
	el["Height"] = 40
	el["Visible"] = false

	el["OnClick"] = self.BtnOk_OnClick

	self.UI[#self.UI + 1] = el
	self.BtnOk = el

	if CF_IsFileExists(self.ModuleName, STATE_CONFIG_FILE) then
		el = {}
		el["Type"] = self.ElementTypes.LABEL
		el["Preset"] = nil
		el["Pos"] = self.Mid + Vector(0, 134)
		el["Text"] = "!!! WARNING, YOUR EXISTING GAME WILL BE DELETED !!!"
		el["Width"] = 800
		el["Height"] = 100

		self.UI[#self.UI + 1] = el
		self.LblHeader = el
	end

	-- Load factions
	self.PlayableFactionCount = 1

	self.FactionButtons = {}

	for i = 1, #CF_Factions do
		if CF_FactionPlayable[CF_Factions[i]] then
			self.FactionButtons[self.PlayableFactionCount] = {}

			self.FactionButtons[self.PlayableFactionCount]["Description"] = CF_FactionDescriptions[CF_Factions[i]]
			self.FactionButtons[self.PlayableFactionCount]["FactionName"] = CF_FactionNames[CF_Factions[i]]
			self.FactionButtons[self.PlayableFactionCount]["FactionId"] = CF_Factions[i]
			self.FactionButtons[self.PlayableFactionCount]["Width"] = 60
			self.FactionButtons[self.PlayableFactionCount]["Height"] = 70
			self.PlayableFactionCount = self.PlayableFactionCount + 1
		end
	end

	self.PlayableFactionCount = self.PlayableFactionCount - 1

	self.FactionButtonsPerRow = 10 -- Plates per row

	if self.PlayableFactionCount < self.FactionButtonsPerRow then
		self.FactionButtonsPerRow = self.PlayableFactionCount
	end

	self.Rows = math.floor(self.PlayableFactionCount / self.FactionButtonsPerRow + 1)

	local xtile = 1
	local ytile = 1
	local tilesperrow = 0

	-- Init factions UI
	for i = 1, self.PlayableFactionCount do
		if i <= self.PlayableFactionCount - self.PlayableFactionCount % self.FactionButtonsPerRow then
			tilesperrow = self.FactionButtonsPerRow
		else
			tilesperrow = self.PlayableFactionCount % self.FactionButtonsPerRow
		end

		self.FactionButtons[i]["Pos"] = Vector(
			self.MidX - ((tilesperrow * 58) / 2) + (xtile * 58) - (58 / 2),
			self.MidY - ((self.Rows * 68) / 2) + (ytile * 68) - (68 / 2)
		)

		xtile = xtile + 1
		if xtile > self.FactionButtonsPerRow then
			xtile = 1
			ytile = ytile + 1
		end
	end

	self:RedrawFactionButtons()

	for i = 1, self.PlayableFactionCount do
		local actor = CF_SpawnRandomInfantry(
			-1,
			self.FactionButtons[i]["Pos"],
			self.FactionButtons[i]["FactionId"],
			Actor.AIMODE_SENTRY
		)
		if actor ~= nil then
			actor:SetControllerMode(Controller.CIM_DISABLED, -1)
			actor.HFlipped = false
		end
	end

	self.NoMOIDPlaceholders = {}

	-- Interface logic
	self.Phases = {}
	for i = 1, (CF_MaxCPUPlayers + 1) do
		self.Phases[i] = "player"
	end
	self.Phase = 0

	-- Selections
	self.SelectedPlayerFaction = 0
	self.SelectedPlayerAlly = 0
	self.SelectedCPUFactions = {}
	self.NoMOIDPlaceholders[0] = false
	for i = 1, CF_MaxCPUPlayers do
		self.SelectedCPUFactions[i] = 0
		self.NoMOIDPlaceholders[i] = false
	end

	-- Draw selection plates
	self.SelectionButtons = {}
	local xtile = 1

	for i = 1, 1 + CF_MaxCPUPlayers do
		self.SelectionButtons[i] = {}
		self.SelectionButtons[i]["Pos"] = Vector(
			self.MidX - (((1 + CF_MaxCPUPlayers) * 58) / 2) + (xtile * 58) - (58 / 2),
			self.MidY + 90
		)
		self:RedrawFactionButton(self.SelectionButtons[i], self.ButtonStates.IDLE)
		xtile = xtile + 1

		-- Add labels
		el = {}
		el["Type"] = self.ElementTypes.LABEL
		el["Preset"] = nil
		el["Pos"] = self.SelectionButtons[i]["Pos"] + Vector(0, -40)
		if i == 1 then
			el["Text"] = "PLAYER"
		else
			el["Text"] = "FACTION " .. i - 1
		end
		el["Width"] = 800
		el["Height"] = 100

		self.UI[#self.UI + 1] = el
	end
end
-----------------------------------------------------------------------------------------
-- Redraw new campaign dialog mission plate
-----------------------------------------------------------------------------------------
function VoidWanderers:RedrawFactionButton(el, state)
	-- print ("RedrawNewGamePlate")
	if el and el["State"] ~= state then
		el["State"] = state

		if MovableMan:IsParticle(el["Particle"]) then
			el["Particle"].ToDelete = true
			el["Particle"] = nil
		end

		local preset = "FactionBannerIdle"

		if state == self.ButtonStates.MOUSE_OVER then
			preset = "FactionBannerMouseOver"
		elseif state == self.ButtonStates.PRESSED then
			preset = "FactionBannerPressed"
		end

		el["Particle"] = CreateMOSRotating(preset, self.ModuleName)

		el["Particle"].Pos = el["Pos"]
		MovableMan:AddParticle(el["Particle"])
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:RedrawFactionButtons()
	for i = 1, #self.FactionButtons do
		self:RedrawFactionButton(self.FactionButtons[i], self.ButtonStates.IDLE)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:BtnOk_OnClick()
	--CF_StopUIProcessing = true

	-- Create new game file
	local config = {}

	local player
	local ally
	local cpu = {}

	player = self.FactionButtons[self.SelectedPlayerFaction]["FactionId"]
	for i = 1, CF_MaxCPUPlayers do
		if self.SelectedCPUFactions[i] ~= 0 then
			cpu[i] = self.FactionButtons[self.SelectedCPUFactions[i]]["FactionId"]
		else
			cpu[i] = nil
		end
	end

	-- Create new game data
	dofile(LIB_PATH .. "Lib_NewGameData.lua")
	config = CF_MakeNewConfig(CHOSEN_DIFFICULTY, CHOSEN_AISKILLPLAYER, CHOSEN_AISKILLCPU, player, cpu, self)
	CF_MakeNewConfig = nil

	CF_WriteConfigFile(config, self.ModuleName, STATE_CONFIG_FILE)

	self:FormClose()

	--for player = 0, self.PlayerCount - 1 do
	--	self:SetPlayerBrain(nil, player);
	--end

	--CF_LaunchMission(config["Scene"], "Tactics.lua")
	self:LaunchScript(config["Scene"], "Tactics.lua")
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:GetFactionButtonUnderMouse(pos)
	for i = 1, #self.FactionButtons do
		local elpos = self.FactionButtons[i]["Pos"]
		local wx = self.FactionButtons[i]["Width"]
		local wy = self.FactionButtons[i]["Height"]

		if
			pos.X > elpos.X - (wx / 2)
			and pos.X < elpos.X + (wx / 2)
			and pos.Y > elpos.Y - (wy / 2)
			and pos.Y < elpos.Y + (wy / 2)
		then
			return i
		end
	end

	return nil
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormClick()
	local f = self:GetFactionButtonUnderMouse(self.Mouse)

	if f ~= nil then
		if self.Phase == 0 then
			self.SelectedPlayerFaction = f

			CF_SpawnRandomInfantry(
				-1,
				self.SelectionButtons[1]["Pos"],
				self.FactionButtons[f]["FactionId"],
				Actor.AIMODE_SENTRY
			)
			self.Phase = self.Phase + 1

			self.SelectedCPUFactions[self.Phase] = f
			self.LblPhase["Text"] = "SELECT CPU " .. self.Phase .. " FACTION"

			local actor = CF_SpawnRandomInfantry(
				-1,
				self.SelectionButtons[self.Phase + 1]["Pos"],
				self.FactionButtons[f]["FactionId"],
				Actor.AIMODE_SENTRY
			)
			if actor == nil then
				self.NoMOIDPlaceholders[self.Phase] = true
			else
				actor.HFlipped = false
				actor:SetControllerMode(Controller.CIM_DISABLED, -1)
			end
			self.Phase = self.Phase + 1
		elseif self.Phase > 1 and self.Phase < (#self.Phases - 1) then
			local ok = true

			for i = 1, self.Phase do
				if self.SelectedCPUFactions[i] == f then
					ok = false
				end
			end

			if ok then
				self.SelectedCPUFactions[self.Phase] = f
				self.LblPhase["Text"] = "SELECT CPU " .. self.Phase .. " FACTION"

				if self.Phase > 3 then
					self.BtnOk["Visible"] = true
				end

				local actor = CF_SpawnRandomInfantry(
					-1,
					self.SelectionButtons[self.Phase + 1]["Pos"],
					self.FactionButtons[f]["FactionId"],
					Actor.AIMODE_SENTRY
				)
				if actor == nil then
					self.NoMOIDPlaceholders[self.Phase] = true
				else
					actor.HFlipped = false
					actor:SetControllerMode(Controller.CIM_DISABLED, -1)
				end
				self.Phase = self.Phase + 1
			else
				FrameMan:SetScreenText("ALL CPU FACTIONS MUST BE DIFFERENT", 0, 0, 2000, true)
			end
		elseif self.Phase == (#self.Phases - 1) then
			local ok = true

			for i = 1, self.Phase do
				if self.SelectedCPUFactions[i] == f then
					ok = false
				end
			end

			if ok then
				self.SelectedCPUFactions[self.Phase] = f
				self.LblPhase["Text"] = "PRESS OK TO START NEW GAME"

				local actor = CF_SpawnRandomInfantry(
					-1,
					self.SelectionButtons[self.Phase + 1]["Pos"],
					self.FactionButtons[f]["FactionId"],
					Actor.AIMODE_SENTRY
				)
				if actor == nil then
					self.NoMOIDPlaceholders[self.Phase] = true
				else
					actor.HFlipped = false
					actor:SetControllerMode(Controller.CIM_DISABLED, -1)
				end
				self.Phase = self.Phase + 1
			else
				FrameMan:SetScreenText("ALL CPU FACTIONS MUST BE DIFFERENT", 0, 0, 2000, true)
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormUpdate()
	-- Redraw plates on hover or press
	local f = self:GetFactionButtonUnderMouse(self.Mouse)

	if self.LastMouseOver and self.LastMouseOver ~= f then
		self:RedrawFactionButton(self.FactionButtons[self.LastMouseOver], self.ButtonStates.IDLE)

		-- Update faction description
		self.LblFactionDescription["Text"] = ""
		self.LblFactionName["Text"] = ""
	end

	if f ~= nil then
		if self.MouseButtonHeld then
			self:RedrawFactionButton(self.FactionButtons[f], self.ButtonStates.PRESS)
		else
			self:RedrawFactionButton(self.FactionButtons[f], self.ButtonStates.MOUSE_OVER)

			-- Update faction description
			self.LblFactionDescription["Text"] = self.FactionButtons[f]["Description"]
			self.LblFactionName["Text"] = string.upper(self.FactionButtons[f]["FactionName"])
		end
		self.LastMouseOver = f
	end

	-- Print out of MOID warning
	for i = 0, CF_MaxCPUPlayers do
		if self.NoMOIDPlaceholders[i] then
			local s = "No MOIDs"
			local l = CF_GetStringPixelWidth(s)

			CF_DrawString(s, self.SelectionButtons[i + 1]["Pos"] + Vector(-l / 2, 0), 100, 100)
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormDraw() end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormClose()
	print("FormNewGame:Close")

	-- Destroy actors
	for actor in MovableMan.Actors do
		if actor.PresetName ~= "Brain Case" then
			actor.ToDelete = true
		end
	end

	-- Destroy plates
	for i = 1, #self.FactionButtons do
		if MovableMan:IsParticle(self.FactionButtons[i]["Particle"]) then
			self.FactionButtons[i]["Particle"].ToDelete = true
			self.FactionButtons[i]["Particle"] = nil
		end
	end

	for i = 1, #self.SelectionButtons do
		if MovableMan:IsParticle(self.SelectionButtons[i]["Particle"]) then
			self.SelectionButtons[i]["Particle"].ToDelete = true
			self.SelectionButtons[i]["Particle"] = nil
		end
	end

	self.FactionButtons = {}
	self.SelectionButtons = {}
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
