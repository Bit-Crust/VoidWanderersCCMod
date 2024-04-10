-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Start Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:StartActivity()
	print("VoidWanderers:StrategyScreen:StartActivity")

	self.player1Controller = self:GetPlayerController(Activity.PLAYER_1)

	if self.PlayerCount > 1 or self.player1Controller:IsKeyboardOnlyControlled() then
		CF_EnableKeyboardControls = true
	else
		CF_EnableKeyboardControls = false
	end

	if self.IsInitialized == nil then
		self.IsInitialized = false
	end

	if self.IsInitialized then
		return
	end

	self.ButtonPressed = false

	self:SetTeamFunds(0, 0)

	self.GS = {}

	self:LoadCurrentGameState()

	CF_InitFactions(self)

	---- -- -- self.ModuleName = "VoidWanderers.rte";

	self.MidX = SceneMan.Scene.Width / 2
	self.MidY = SceneMan.Scene.Height / 2
	self.Mid = Vector(self.MidX, self.MidY)

	self.ResX = FrameMan.PlayerScreenWidth
	self.ResY = FrameMan.PlayerScreenHeight

	self.ResX2 = FrameMan.PlayerScreenWidth / 2
	self.ResY2 = FrameMan.PlayerScreenHeight / 2

	self.Mouse = self.Mid

	for plr = 0, self.PlayerCount - 1 do
		self:SetPlayerBrain(nil, Activity.TEAM_1)
	end

	self.brain = nil

	self.ObserverPos = nil

	for plr = 0, self.PlayerCount - 1 do
		FrameMan:ClearScreenText(plr)
	end

	self:CreateActors()

	self.MouseFirePressed = true

	self.GenericTimer = Timer()
	self.GenericTimer:Reset()

	self.MessageTimer = Timer()
	self.MessageTimer:Reset()
	self.MessageInterval = CF_MessageInterval
	self.MessagePos = self.Mid + Vector(-75, self.ResY2 - 48)

	self.Messages = {}

	-- How many times to redraw cursor glows to make it less transparent
	self.CURSOR_REDRAW_COUNT = 1

	-- How many times to redraw button glows to make it less transparent
	self.BUTTON_REDRAW_COUNT = 1

	self.ElementTypes = { BUTTON = 0, LABEL = 1, PLANET = 2 }
	self.ButtonStates = { IDLE = 0, MOUSE_OVER = 1, PRESSED = 2 }

	self.UI = {}

	-- Load default form
	-- If we returned from tactical mission go straight to default form
	dofile(FORM_TO_LOAD)
	-- Init form
	self:FormLoad()

	self.MouseOverElement = nil
	self.MousePressedElement = nil
	self.MousePressStartElement = nil
	self.MousePressEndElement = nil

	self.IsInitialized = true
end
-----------------------------------------------------------------------------------------
-- Pause Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:PauseActivity(pause) end
-----------------------------------------------------------------------------------------
-- End Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:CreateActors()
	--Make an invisible brain.
	if MovableMan:IsActor(self.brain) then
		self.brain.ToDelete = true
		self.brain = nil
	end

	self.brain = CreateActor("Fake Brain Case")
	self.brain.Scale = 0
	self.brain.Team = Activity.TEAM_1
	self.brain.Pos = self.Mid
	self.brain.HitsMOs = false
	self.brain.GetsHitByMOs = false
	MovableMan:AddActor(self.brain)
	self:SetPlayerBrain(self.brain, Activity.TEAM_1)
	self:SwitchToActor(self.brain, Activity.PLAYER_1, Activity.TEAM_1)

	--[[if MovableMan:IsActor(G_CursorActor) then
		G_CursorActor.ToDelete = true
		G_CursorActor = nil
	end--]]
	--

	G_CursorActor = CreateActor("VW_Cursor")
	if G_CursorActor then
		G_CursorActor.Team = CF_PlayerTeam
		local curactor = self:GetControlledActor(Activity.PLAYER_1)

		if act and MovableMan:IsActor(curactor) then
			G_CursorActor.Pos = curactor.Pos
		else
			local curactor = self:GetPlayerBrain(0)
			if MovableMan:IsActor(curactor) then
				G_CursorActor.Pos = curactor.Pos
			else
				G_CursorActor.Pos = Vector()
			end
		end

		MovableMan:AddActor(G_CursorActor)
		ActivityMan:GetActivity():SwitchToActor(G_CursorActor, Activity.PLAYER_1, Activity.TEAM_1)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ClearMessages()
	self.Messages = {}
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:LoadCurrentGameState()
	if CF_IsFileExists(self.ModuleName, STATE_CONFIG_FILE) then
		self.GS = CF_ReadConfigFile(self.ModuleName, STATE_CONFIG_FILE)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SaveCurrentGameState()
	CF_WriteConfigFile(self.GS, self.ModuleName, STATE_CONFIG_FILE)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawMouseCursor()
	--for i = 1, self.CURSOR_REDRAW_COUNT do
	local pix = CreateMOPixel("Cursor")
	pix.Pos = self.Mouse + Vector(6, 6)
	MovableMan:AddParticle(pix)
	--end
end
-----------------------------------------------------------------------------------------
-- Draw label element
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawLabel(el, state)
	-- Labels can ommit presets or texts
	if el["Preset"] then
		local pix = CreateMOPixel(el["Preset"])
		pix.Pos = el.Pos
		MovableMan:AddParticle(pix)
	end

	if el["Text"] then
		local centered = true

		if el["Centered"] ~= nil and el["Centered"] == false then
			centered = false
		end

		if centered then
			CF_DrawString(
				el["Text"],
				Vector(el.Pos.X - (CF_GetStringPixelWidth(el["Text"]) / 2) + 2, el.Pos.Y),
				el["Width"] - 8,
				el["Height"]
			)
		else
			CF_DrawString(el["Text"], el.Pos, el["Width"], el["Height"])
		end
	end
end
-----------------------------------------------------------------------------------------
-- Draw button element
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawButton(el, state, drawthistime)
	local isvisible = true
	local presetprefix

	if CF_LowPerformance then
		presetprefix = "Ln"
	else
		presetprefix = ""
	end

	if el["Visible"] ~= nil then
		if el["Visible"] == false then
			isvisible = false
		end
	end

	if isvisible then
		if drawthistime then
			local pix = CreateMOPixel(presetprefix .. el["Presets"][state])
			pix.Pos = el.Pos
			MovableMan:AddParticle(pix)
		end

		if el["Text"] then
			CF_DrawString(
				el["Text"],
				Vector(el.Pos.X - (CF_GetStringPixelWidth(el["Text"]) / 2) + 2, el.Pos.Y),
				el["Width"] - 8,
				el["Height"]
			)
		end
	end
end
-----------------------------------------------------------------------------------------
-- Check if pos is within button area
-----------------------------------------------------------------------------------------
function VoidWanderers:IsWithinButton(el, pos)
	local isvisible = true

	if el["Visible"] ~= nil then
		if el["Visible"] == false then
			isvisible = false
		end
	end

	if isvisible then
		local elpos = el["Pos"]
		local wx = el["Width"]
		local wy = el["Height"]

		if
			pos.X > elpos.X - (wx / 2)
			and pos.X < elpos.X + (wx / 2)
			and pos.Y > elpos.Y - (wy / 2)
			and pos.Y < elpos.Y + (wy / 2)
		then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------
-- Redraw non-custom elements
-----------------------------------------------------------------------------------------
function VoidWanderers:RedrawKnownFormElements()
	local drawthistime

	for i = 1, #self.UI do
		drawthistime = true

		if CF_LowPerformance then
			if CF_FrameCounter % 2 == i % 2 then
				drawthistime = true
			else
				drawthistime = false
			end
		end

		-- Redraw button
		if self.UI[i]["Type"] == self.ElementTypes.BUTTON then
			local state = self.ButtonStates.IDLE

			if i == self.MouseOverElement then
				state = self.ButtonStates.MOUSE_OVER
			end

			if i == self.MousePressedElement then
				state = self.ButtonStates.PRESSED
			end

			self:DrawButton(self.UI[i], state, drawthistime)
		end

		if self.UI[i]["Type"] == self.ElementTypes.LABEL then
			self:DrawLabel(self.UI[i], nil)
		end
	end
end
-----------------------------------------------------------------------------------------
-- Get element id above whicj mouse currently is
-----------------------------------------------------------------------------------------
function VoidWanderers:GetMouseOverKnownFormElements()
	for i = 1, #self.UI do
		if self.UI[i]["Type"] == self.ElementTypes.BUTTON then
			if self:IsWithinButton(self.UI[i], self.Mouse) then
				return i
			end
		end
	end

	return nil
end
-----------------------------------------------------------------------------------------
-- Update Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:UpdateActivity()
	-- Just check for intialization flags in update loop to avoid unnecessary function calls during all the mission
	if self.IsInitialized == nil then
		self.IsInitialized = false
	end

	if not self.IsInitialized then
		--Init mission if we're still not
		self:StartActivity()
	end

	if self.ActivityState == Activity.OVER then
		return
	end

	if CF_StopUIProcessing then
		return
	end

	if self.ProcessBeforeAnything ~= nil then
		self:ProcessBeforeAnything()
	end

	-- Set the screen of disabled 4-th player when we're playing in 3-player mode
	if self.ObserverPos ~= nil and self:PlayerHuman(Activity.PLAYER_4) then
		CameraMan:SetScrollTarget(self.ObserverPos, 0.04, self:ScreenOfPlayer(Activity.PLAYER_4))
	end

	--Read standard input, ugly but at least it will be operational if mouse fail for whatever reason

	if CF_EnableKeyboardControls then
		if self.player1Controller:IsState(Controller.MOVE_LEFT) then
			self.Mouse = self.Mouse + Vector(-5, 0)
		end

		if self.player1Controller:IsState(Controller.MOVE_RIGHT) then
			self.Mouse = self.Mouse + Vector(5, 0)
		end

		if self.player1Controller:IsState(Controller.MOVE_UP) then
			self.Mouse = self.Mouse + Vector(0, -5)
		end

		if self.player1Controller:IsState(Controller.MOVE_DOWN) then
			self.Mouse = self.Mouse + Vector(0, 5)
		end
	else
		-- Read mouse input
		self.Mouse = self.Mouse + UInputMan:GetMouseMovement(0)
	end

	-- Debug Toggle low performance flag on/off
	--if UInputMan:KeyPressed(28) then
	--	CF_LowPerformance = not CF_LowPerformance
	--	print (CF_LowPerformance)
	--end

	-- Find out info about UInputMan buttons
	--for i = 1, 128 do
	--	if UInputMan:KeyPressed(i) then
	--		print (i)
	--	end
	--end

	-- Don't let the cursor leave the screen
	if self.ButtonPressed then
		if self.Mouse.X < G_CursorActor.Pos.X - self.ResX2 + 5 then
			self.Mouse.X = G_CursorActor.Pos.X - self.ResX2 + 5
		end

		if self.Mouse.Y < G_CursorActor.Pos.Y - self.ResY2 + 5 then
			self.Mouse.Y = G_CursorActor.Pos.Y - self.ResY2 + 5
		end

		if self.Mouse.X > G_CursorActor.Pos.X + self.ResX2 - 5 then
			self.Mouse.X = G_CursorActor.Pos.X + self.ResX2 - 5
		end

		if self.Mouse.Y > G_CursorActor.Pos.Y + self.ResY2 - 5 then
			self.Mouse.Y = G_CursorActor.Pos.Y + self.ResY2 - 5
		end
	else
		if self.Mouse.X < 0 then
			self.Mouse.X = SceneMan.Scene.Width - 1
		end

		if self.Mouse.Y < 10 then
			self.Mouse.Y = 10
		end

		if self.Mouse.X > SceneMan.Scene.Width then
			self.Mouse.X = 0
		end

		if self.Mouse.Y > SceneMan.Scene.Height - 10 then
			self.Mouse.Y = SceneMan.Scene.Height - 10
		end
	end

	self:DrawMouseCursor()

	if MovableMan:IsActor(G_CursorActor) then
		if not self.ButtonPressed then
			G_CursorActor.Pos = self.Mouse
		end
	end

	-- Process mouse hovers and presses -- TODO: UInputMan doesn't seem to register the mouse press functions?
	if true or CF_EnableKeyboardControls then
		self.MouseOverElement = self:GetMouseOverKnownFormElements()

		if self.MouseOverElement then
			if self.UI[self.MouseOverElement]["OnHover"] ~= nil then
				self.UI[self.MouseOverElement]["OnHover"](self)
			end
		end

		-- Process standard input
		if self.player1Controller:IsState(Controller.WEAPON_FIRE) then
			if not self.MouseFirePressed then
				self.MousePressedElement = self:GetMouseOverKnownFormElements()

				local dontpass = false

				if self.MousePressedElement ~= nil then
					if self.UI[self.MousePressedElement]["OnClick"] ~= nil then
						dontpass = true
						self.UI[self.MousePressedElement]["OnClick"](self)
					end
				end

				if not dontpass then
					self:FormClick()
				end

				self.MouseOverElement = nil
				self.MousePressedElement = nil
				self.MousePressStartElement = nil
				self.MousePressEndElement = nil
			end
			self.MouseFirePressed = true
		else
			self.MouseFirePressed = false
		end
	else
		-- Process mouse input
		self.MouseOverElement = self:GetMouseOverKnownFormElements()

		if self.MouseOverElement then
			if self.UI[self.MouseOverElement]["OnHover"] ~= nil then
				self.UI[self.MouseOverElement]["OnHover"](self)
			end
		end

		if UInputMan:MouseButtonPressed(0) then
			self.MousePressStartElement = self:GetMouseOverKnownFormElements()
			self.MousePressEndElement = nil
			self.MousePressedElement = self:GetMouseOverKnownFormElements()
		end

		if UInputMan:MouseButtonHeld(0) then
			self.MouseOverElement = nil
			self.MouseButtonHeld = true
		else
			self.MouseButtonHeld = false
		end

		if UInputMan:MouseButtonReleased(0) then
			-- Get element above which mouse was released
			self.MousePressEndElement = self:GetMouseOverKnownFormElements()

			local dontpass = false

			if self.MousePressStartElement ~= nil and self.MousePressStartElement == self.MousePressEndElement then
				if self.MousePressedElement ~= nil then
					if self.UI[self.MousePressedElement]["OnClick"] ~= nil then
						dontpass = true
						self.UI[self.MousePressedElement]["OnClick"](self)
					end
				end
			end

			-- Don't pass events which were already handled by known controls
			if not dontpass then
				self:FormClick()
			end

			self.MouseOverElement = nil
			self.MousePressedElement = nil
			self.MousePressStartElement = nil
			self.MousePressEndElement = nil
		end
	end

	--print(self.MouseOverElement);
	--print(self.MousePressedElement);

	self:RedrawKnownFormElements()
	self:FormUpdate()
	self:FormDraw()

	-- Count frames for low performance version of CF_DrawString
	CF_FrameCounter = CF_FrameCounter + 1

	if CF_FrameCounter >= 10000 then
		CF_FrameCounter = 0
	end

	--print (self.Mouse - self.Mid)--]]--
end
-----------------------------------------------------------------------------------------
-- Thats all folks!!!
-----------------------------------------------------------------------------------------
