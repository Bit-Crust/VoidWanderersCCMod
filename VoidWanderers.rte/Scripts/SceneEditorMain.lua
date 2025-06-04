-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Start Scene Process
-----------------------------------------------------------------------
function VoidWanderers:StartSceneProcess()
	print("VoidWanderers:StrategyScreen:StartSceneProcess");

	self.menuNavigationSchemes = { KEYBOARD = 0, MOUSE = 1, GAMEPAD = 2 }
	self.menuNavigationScheme = self.menuNavigationSchemes.KEYBOARD
	self.menuNavigatingPlayer = Activity.PLAYER_NONE
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self:PlayerActive(player) and self:PlayerHuman(player) then
			self.menuNavigatingPlayer = player
			if self:GetPlayerController(player):IsMouseControlled() then
				self.menuNavigationScheme = self.menuNavigationSchemes.MOUSE
			elseif self:GetPlayerController(player):IsGamepadControlled() then
				self.menuNavigationScheme = self.menuNavigationSchemes.GAMEPAD
			end
			break
		else
			print("WARNING: You are playing with a setup this mod is not yet able to accomodate.")
		end
	end

	if self.IsInitialized == nil then
		self.IsInitialized = false
	elseif self.IsInitialized == true then
		return
	end

	self.ButtonPressed = false

	self:SetTeamFunds(0, 0)

	self.GS = {}

	CF.InitFactions(self)

	self:loadCurrentGameState()

	---- -- -- -- -- self.ModuleName = "VoidWanderers.rte"

	self.mid.X = SceneMan.Scene.Width / 2
	self.mid.Y = SceneMan.Scene.Height / 2
	self.mid = Vector(self.mid.X, self.mid.Y)

	self.res.X = FrameMan.PlayerScreenWidth
	self.res.Y = FrameMan.PlayerScreenHeight

	self.res.X / 2 = FrameMan.PlayerScreenWidth / 2
	self.res.Y / 2 = FrameMan.PlayerScreenHeight / 2

	self.mouse = self.mid

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		self:SetPlayerBrain(nil, player)
		FrameMan:ClearScreenText(self:ScreenOfPlayer(player))
	end

	self.brain = nil

	self.ObserverPos = nil

	self:CreateActors()

	self.mouseFirePressed = true

	self.SceneTimer = Timer()
	self.SceneTimer:Reset()

	self.MessageTimer = Timer()
	self.MessageTimer:Reset()
	self.MessageInterval = CF.MessageInterval
	self.MessagePos = self.mid + Vector(-75, self.res.Y / 2 - 48)

	self.Messages = {}

	-- How many times to redraw cursor glows to make it less transparent
	self.CURSOR_REDRAW_COUNT = 1

	-- How many times to redraw button glows to make it less transparent
	self.BUTTON_REDRAW_COUNT = 1

	CF.ElementTypes = { BUTTON = 0, LABEL = 1, PLANET = 2 }
	CF.ElementStates = { IDLE = 0, MOUSE_OVER = 1, PRESSED = 2 }

	self.ui = {}

	-- Load default form
	-- If we returned from tactical mission go straight to default form
	dofile(FORM_TO_LOAD)
	-- Init form
	self:FormLoad()

	self.hoverOverIndex = nil
	self.pressHoldIndex = nil
	self.pressStartIndex = nil
	self.pressEndIndex = nil

	self.IsInitialized = true
end
-----------------------------------------------------------------------
-- Update Scene Process
-----------------------------------------------------------------------
function VoidWanderers:UpdateSceneProcess()
	-- Just check for intialization flags in update loop to avoid unnecessary function calls during all the mission
	if self.IsInitialized == nil then
		self.IsInitialized = false
	end

	-- Set the screen of disabled 4-th player when we're playing in 3-player mode
	-- this should never happen, and we specifically defined this as nil anyways
	--[[if self.ObserverPos ~= nil and self:PlayerHuman(Activity.PLAYER_4) then
		CameraMan:SetScrollTarget(self.ObserverPos, 0.04, self:ScreenOfPlayer(Activity.PLAYER_4))
	end]]

	local cont = self.brain:GetController()

	if self.menuNavigationScheme == self.menuNavigationSchemes.KEYBOARD then
		if cont:IsState(Controller.MOVE_LEFT) then
			self.mouse = self.mouse + Vector(-5, 0)
		end

		if cont:IsState(Controller.MOVE_RIGHT) then
			self.mouse = self.mouse + Vector(5, 0)
		end

		if cont:IsState(Controller.MOVE_UP) then
			self.mouse = self.mouse + Vector(0, -5)
		end

		if cont:IsState(Controller.MOVE_DOWN) then
			self.mouse = self.mouse + Vector(0, 5)
		end
	elseif self.menuNavigationScheme == self.menuNavigationSchemes.MOUSE then
		-- Read mouse input
		self.mouse = self.mouse + UInputMan:GetMouseMovement(self.menuNavigatingPlayer)
	else
		self.mouse = self.mouse + self:GetPlayerController(self.menuNavigatingPlayer).AnalogMove * 5
	end

	-- Don't let the cursor leave the screen
	if self.ButtonPressed then
		if self.mouse.X < G_CursorActor.Pos.X - self.res.X / 2 + 5 then
			self.mouse.X = G_CursorActor.Pos.X - self.res.X / 2 + 5
		end

		if self.mouse.Y < G_CursorActor.Pos.Y - self.res.Y / 2 + 5 then
			self.mouse.Y = G_CursorActor.Pos.Y - self.res.Y / 2 + 5
		end

		if self.mouse.X > G_CursorActor.Pos.X + self.res.X / 2 - 5 then
			self.mouse.X = G_CursorActor.Pos.X + self.res.X / 2 - 5
		end

		if self.mouse.Y > G_CursorActor.Pos.Y + self.res.Y / 2 - 5 then
			self.mouse.Y = G_CursorActor.Pos.Y + self.res.Y / 2 - 5
		end
	else
		if self.mouse.X < 0 then
			self.mouse.X = SceneMan.Scene.Width - 1
		end

		if self.mouse.Y < 10 then
			self.mouse.Y = 10
		end

		if self.mouse.X > SceneMan.Scene.Width then
			self.mouse.X = 0
		end

		if self.mouse.Y > SceneMan.Scene.Height - 10 then
			self.mouse.Y = SceneMan.Scene.Height - 10
		end
	end

	self:DrawMouseCursor()

	if MovableMan:IsActor(G_CursorActor) then
		if not self.ButtonPressed then
			G_CursorActor.Pos = self.mouse
		end
	end

	-- Process mouse hovers and presses -- TODO: UInputMan doesn't seem to register the mouse press functions?
	if true or self.menuNavigationScheme == self.menuNavigationSchemes.KEYBOARD then
		self.hoverOverIndex = self:getHoveredButton()

		if self.hoverOverIndex then
			if self.ui[self.hoverOverIndex]["OnHover"] ~= nil then
				self.ui[self.hoverOverIndex]["OnHover"](self)
			end
		end

		-- Process standard input
		if cont:IsState(Controller.WEAPON_FIRE) then
			if not self.mouseFirePressed then
				self.pressHoldIndex = self:getHoveredButton()

				local dontpass = false

				if self.pressHoldIndex ~= nil then
					if self.ui[self.pressHoldIndex]["OnClick"] ~= nil then
						dontpass = true
						self.ui[self.pressHoldIndex]["OnClick"](self)
					end
				end

				if not dontpass then
					self:FormClick()
				end

				self.hoverOverIndex = nil
				self.pressHoldIndex = nil
				self.pressStartIndex = nil
				self.pressEndIndex = nil
			end
			self.mouseFirePressed = true
		else
			self.mouseFirePressed = false
		end
	else
		-- Process mouse input
		self.hoverOverIndex = self:getHoveredButton()

		if self.hoverOverIndex then
			if self.ui[self.hoverOverIndex]["OnHover"] ~= nil then
				self.ui[self.hoverOverIndex]["OnHover"](self)
			end
		end

		if UInputMan:MouseButtonPressed(0) then
			self.pressStartIndex = self:getHoveredButton()
			self.pressEndIndex = nil
			self.pressHoldIndex = self:getHoveredButton()
		end

		if UInputMan:MouseButtonHeld(0) then
			self.hoverOverIndex = nil
			self.MouseButtonHeld = true
		else
			self.MouseButtonHeld = false
		end

		if UInputMan:MouseButtonReleased(0) then
			-- Get element above which mouse was released
			self.pressEndIndex = self:getHoveredButton()

			local dontpass = false

			if self.pressStartIndex ~= nil and self.pressStartIndex == self.pressEndIndex then
				if self.pressHoldIndex ~= nil then
					if self.ui[self.pressHoldIndex]["OnClick"] ~= nil then
						dontpass = true
						self.ui[self.pressHoldIndex]["OnClick"](self)
					end
				end
			end

			-- Don't pass events which were already handled by known controls
			if not dontpass then
				self:FormClick()
			end

			self.hoverOverIndex = nil
			self.pressHoldIndex = nil
			self.pressStartIndex = nil
			self.pressEndIndex = nil
		end
	end

	--print(self.hoverOverIndex)
	--print(self.pressHoldIndex)

	self:redrawKnownFormElements()
	self:FormUpdate()
	self:FormDraw()
end
-----------------------------------------------------------------------
-- Pause Activity
-----------------------------------------------------------------------
function VoidWanderers:PauseActivity(pause) end
-----------------------------------------------------------------------
-- Create actors used by scene editor
-----------------------------------------------------------------------
function VoidWanderers:CreateActors()
	--Make an invisible brain.
	if MovableMan:IsActor(self.brain) then
		self.brain.ToDelete = true
		self.brain = nil
	end

	self.brain = CreateActor("Brain Case")
	self.brain.Scale = 0
	self.brain.Team = Activity.TEAM_1
	self.brain.Pos = self.mid
	self.brain.HitsMOs = false
	self.brain.GetsHitByMOs = false
	MovableMan:AddActor(self.brain)
	self:SetPlayerBrain(self.brain, Activity.TEAM_1)
	self:SwitchToActor(self.brain, Activity.PLAYER_1, Activity.TEAM_1)
	CameraMan:SetScroll(self.mid, self:ScreenOfPlayer(Activity.PLAYER_1))

	--[[if MovableMan:IsActor(G_CursorActor) then
		G_CursorActor.ToDelete = true
		G_CursorActor = nil
	end--]]
	--

	G_CursorActor = CreateActor("VW_Cursor")
	if G_CursorActor then
		G_CursorActor.Team = CF.PlayerTeam
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
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ClearMessages()
	self.Messages = {}
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:loadCurrentGameState()
	if CF.IsFileExists("Mods/VoidWanderers.rte/CampaignData/" .. self.stateConfigFileName) then
		self.GS = CF.ReadDataFile("Mods/VoidWanderers.rte/CampaignData/" .. self.stateConfigFileName)
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:saveCurrentGameState()
	CF.WriteDataFile(self.GS, "Mods/VoidWanderers.rte/CampaignData/" .. self.stateConfigFileName)
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DrawMouseCursor()
	--for i = 1, self.CURSOR_REDRAW_COUNT do
	local pix = CreateMOPixel("Cursor")
	pix.Pos = self.mouse + Vector(6, 6)
	MovableMan:AddParticle(pix)
	--end
end
-----------------------------------------------------------------------
-- Draw label element
-----------------------------------------------------------------------
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
			CF.DrawString(
				el["Text"],
				Vector(el.Pos.X - (CF.GetStringPixelWidth(el["Text"]) / 2) + 2, el.Pos.Y),
				el["Width"] - 8,
				el["Height"]
			)
		else
			CF.DrawString(el["Text"], el.Pos, el["Width"], el["Height"])
		end
	end
end
-----------------------------------------------------------------------
-- Draw button element
-----------------------------------------------------------------------
function VoidWanderers:DrawButton(el, state)
	local isvisible = true

	if el["Visible"] ~= nil then
		if el["Visible"] == false then
			isvisible = false
		end
	end

	if isvisible then
		local pix = CreateMOPixel(el["Presets"][state])
		pix.Pos = el.Pos
		MovableMan:AddParticle(pix)

		if el["Text"] then
			CF.DrawString(
				el["Text"],
				Vector(el.Pos.X - (CF.GetStringPixelWidth(el["Text"]) / 2) + 2, el.Pos.Y),
				el["Width"] - 8,
				el["Height"]
			)
		end
	end
end
-----------------------------------------------------------------------
-- Check if pos is within button area
-----------------------------------------------------------------------
function VoidWanderers:isWithinButton(el, pos)
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
-----------------------------------------------------------------------
-- Redraw non-custom elements
-----------------------------------------------------------------------
function VoidWanderers:redrawKnownFormElements()
	for i = 1, #self.ui do
		-- Redraw button
		if self.ui[i]["Type"] == CF.ElementTypes.BUTTON then
			local state = CF.ElementStates.IDLE

			if i == self.hoverOverIndex then
				state = CF.ElementStates.MOUSE_OVER
			end

			if i == self.pressHoldIndex then
				state = CF.ElementStates.PRESSED
			end

			CF.DrawButton(self.ui[i], state, true)
		end

		if self.ui[i]["Type"] == CF.ElementTypes.LABEL then
			CF.DrawLabel(self.ui[i], nil)
		end
	end
end
-----------------------------------------------------------------------
-- Get element id above whicj mouse currently is
-----------------------------------------------------------------------
function VoidWanderers:getHoveredButton()
	for i = 1, #self.ui do
		if self.ui[i]["Type"] == CF.ElementTypes.BUTTON then
			if self:isWithinButton(self.ui[i], self.mouse) then
				return i
			end
		end
	end

	return nil
end
-----------------------------------------------------------------------
-- Thats all folks!!!
-----------------------------------------------------------------------
