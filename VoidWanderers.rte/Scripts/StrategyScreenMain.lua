-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Start Activity
-----------------------------------------------------------------------------------------
function VoidWanderers:StartActivity()
	print("VoidWanderers:StrategyScreen:StartActivity");
	
	self.MenuNavigationSchemes = { KEYBOARD = 0, MOUSE = 1, GAMEPAD = 2 };
	CF_MenuNavigationScheme = self.MenuNavigationSchemes.KEYBOARD;
	CF_FirstActivePlayer = 0;
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self:PlayerActive(player) and self:PlayerHuman(player) then
			CF_FirstActivePlayer = player;
			if self:GetPlayerController(player):IsMouseControlled() then
				CF_MenuNavigationScheme = self.MenuNavigationSchemes.MOUSE;
			elseif self:GetPlayerController(player):IsGamepadControlled() then
				CF_MenuNavigationScheme = self.MenuNavigationSchemes.GAMEPAD;
			end
			break;
		else
			print("WARNING: You are playing with a setup this mod is not yet able to accomodate.");
		end
	end

	if self.IsInitialized == nil then
		self.IsInitialized = false;
	end

	if self.IsInitialized then
		return;
	end

	self:SetTeamFunds(0, 0);

	self.GS = {};

	CF_InitFactions(self);

	self:LoadCurrentGameState();

	---- -- -- self.ModuleName = "VoidWanderers.rte";

	self.MidX = SceneMan.Scene.Width / 4;
	self.MidY = SceneMan.Scene.Height / 2;
	self.Mid = Vector(self.MidX, self.MidY);

	self.ResX = FrameMan.PlayerScreenWidth;
	self.ResY = FrameMan.PlayerScreenHeight;

	self.ResX2 = FrameMan.PlayerScreenWidth / 2;
	self.ResY2 = FrameMan.PlayerScreenHeight / 2;

	self.Mouse = self.Mid * 1;
	self.Scroll = self.Mid * 1;
	self.ScrollMinimumDistance = FrameMan.PlayerScreenHeight / 2 - 50;

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		self:SetPlayerBrain(nil, player);
	end

	self.brain = nil;

	self.ObserverPos = nil;

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		FrameMan:ClearScreenText(player);
	end
	
	self.FirePressed = {};
	--Make an invisible brain.
	self.MidOffset = Vector(0,0);
	if self.PlayerCount == 1 then
		self.brain = CreateActor("Fake Brain Case");
		self.brain.Scale = 0;
		self.brain.Team = Activity.TEAM_1;
		self.brain.Pos = self.Mid;
		self.brain.HitsMOs = false;
		self.brain.GetsHitByMOs = false;
		MovableMan:AddActor(self.brain);
		self:SetPlayerBrain(self.brain, Activity.TEAM_1);
		self:SwitchToActor(self.brain, Activity.PLAYER_1, Activity.TEAM_1);
		self.CurCursorMO = self.brain;
		self.LastCursorMO = self.brain;
	else
		local brainpos = {};

		brainpos[0] = self.Mid + Vector(0, 0);
		brainpos[1] = self.Mid + Vector(self.ResX, -self.ResY2);
		brainpos[2] = self.Mid + Vector(self.ResX, 0);
		brainpos[3] = self.Mid + Vector(self.ResX, self.ResY2);
		self.ObserverPos = brainpos[3];
		
		local activeHumans = 0;
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local brn;
			if self:PlayerActive(player) and self:PlayerHuman(player) then
				activeHumans = activeHumans + 1;
				brn = CreateActor("Fake Brain Case");
				brn.Scale = 0;
				brn.Team = Activity.TEAM_1;
				brn.Pos = brainpos[activeHumans - 1];
				brn.HitsMOs = false;
				brn.GetsHitByMOs = false;
				MovableMan:AddActor(brn);
				self:SetPlayerBrain(brn, player);
				self:SwitchToActor(brn, player, Activity.TEAM_1);
				CameraMan:SetScroll(self.Mid, self:ScreenOfPlayer(player));
				
				if self.brain == nil then
					self.brain = brn;
				end
			end
		end
	end

	self.MouseFirePressed = true;

	self.GenericTimer = Timer();
	self.GenericTimer:Reset();

	self.MessageTimer = Timer();
	self.MessageTimer:Reset();
	self.MessageInterval = CF_MessageInterval;
	self.MessagePos = self.Mid + Vector(-75, self.ResY2 - 48);

	self.Messages = {};

	-- How many times to redraw cursor glows to make it less transparent
	self.CURSOR_REDRAW_COUNT = 1;

	-- How many times to redraw button glows to make it less transparent
	self.BUTTON_REDRAW_COUNT = 1;

	self.ElementTypes = { BUTTON = 0, LABEL = 1, PLANET = 2 };
	self.ButtonStates = { IDLE = 0, MOUSE_OVER = 1, PRESSED = 2 };

	self.UI = {};

	-- Load default form
	-- If we returned from tactical mission go straight to default form
	dofile(FORM_TO_LOAD);
	-- Init form
	self:FormLoad();

	self.MouseOverElement = nil;
	self.MousePressedElement = nil;
	self.MousePressStartElement = nil;
	self.MousePressEndElement = nil;

	self.IsInitialized = true;
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ClearMessages()
	self.Messages = {};
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ShowMessage(msg, iscritical)
	if #self.Messages == 0 then
		self.MessageTimer:Reset();
	end

	local newmsg = {};
	newmsg["Text"] = msg;
	newmsg["Critical"] = iscritical;

	table.insert(self.Messages, newmsg);
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DisplayCurrentMessage()
	if #self.Messages > 0 then
		if self.MessageTimer:IsPastSimMS(self.MessageInterval) then
			table.remove(self.Messages, 1);
			self.MessageTimer:Reset();
		else
			local msg = self.Messages[1];

			if msg["Critical"] == true then
				local pix = CreateMOPixel("MessagePanelRed");
				pix.Pos = self.MessagePos;
				MovableMan:AddParticle(pix);
			else
				local pix = CreateMOPixel("MessagePanel");
				pix.Pos = self.MessagePos;
				MovableMan:AddParticle(pix);
			end

			CF_DrawString(msg["Text"], self.MessagePos + Vector(-130, -40), 260, 80);
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:AddAIAttackEvent(terr, base, facil)
	-- Find empty attack event effect slot
	local found = 1;

	for i = 1, CF_MaxAttackEventSlots do
		if
			self.GS["AttackEvent" .. i .. "Expires"] == nil
			or tonumber(self.GS["AttackEvent" .. i .. "Expires"]) < tonumber(self.GS["Time"])
		then
			found = i;
			break;
		end
	end

	self.GS["AttackEvent" .. found .. "Expires"] = tonumber(self.GS["Time"]) + CF_AttackEventExpire;
	self.GS["AttackEvent" .. found .. "Territory"] = terr;
	self.GS["AttackEvent" .. found .. "Facility"] = facil;
	self.GS["AttackEvent" .. found .. "Base"] = base;
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawMouseCursor()
	local pix = CreateMOPixel("Cursor");
	pix.Pos = self.Mouse + Vector(6, 6);
	MovableMan:AddParticle(pix);
end
-----------------------------------------------------------------------------------------
-- Draw label element
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawLabel(el, state)
	-- Labels can ommit presets or texts
	if el["Preset"] then
		local pix = CreateMOPixel(el["Preset"]);
		pix.Pos = el.Pos;
		MovableMan:AddParticle(pix);
	end

	if el["Text"] then
		local centered = true;

		if el["Centered"] ~= nil and el["Centered"] == false then
			centered = false;
		end

		if centered then
			local w = CF_GetStringPixelWidth(el["Text"]);
			CF_DrawString(el["Text"], Vector(el.Pos.X - (w / 2) + 4, el.Pos.Y), el["Width"], el["Height"]);
		else
			CF_DrawString(el["Text"], el.Pos, el["Width"], el["Height"]);
		end
	end
end
-----------------------------------------------------------------------------------------
-- Draw button element
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawButton(el, state, drawthistime)
	local isvisible = true;
	local presetprefix;

	if CF_LowPerformance then
		presetprefix = "Ln";
	else
		presetprefix = "";
	end

	if el["Visible"] ~= nil then
		if el["Visible"] == false then
			isvisible = false;
		end
	end

	if isvisible then
		if drawthistime then
			local pix = CreateMOPixel(presetprefix .. el["Presets"][state]);
			pix.Pos = el.Pos;
			MovableMan:AddParticle(pix);
		end

		if el["Text"] then
			local w = CF_GetStringPixelWidth(el["Text"]);
			CF_DrawString(el["Text"], Vector(el.Pos.X - (w / 2) + 4, el.Pos.Y), el["Width"], el["Height"]);
		end
	end
end
-----------------------------------------------------------------------------------------
-- Check if pos is within button area
-----------------------------------------------------------------------------------------
function VoidWanderers:IsWithinButton(el, pos)
	local isvisible = true;

	if el["Visible"] ~= nil then
		if el["Visible"] == false then
			isvisible = false;
		end
	end

	if isvisible then
		local elpos = el["Pos"];
		local wx = el["Width"];
		local wy = el["Height"];

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
	local drawthistime;

	for i = 1, #self.UI do
		drawthistime = true;

		if CF_LowPerformance then
			if CF_FrameCounter % 2 == i % 2 then
				drawthistime = true;
			else
				drawthistime = false;
			end
		end

		-- Redraw button
		if self.UI[i]["Type"] == self.ElementTypes.BUTTON then
			local state = self.ButtonStates.IDLE;

			if i == self.MouseOverElement then
				state = self.ButtonStates.MOUSE_OVER;
			end

			if i == self.MousePressedElement then
				state = self.ButtonStates.PRESSED;
			end

			self:DrawButton(self.UI[i], state, drawthistime);
		end

		if self.UI[i]["Type"] == self.ElementTypes.LABEL then
			self:DrawLabel(self.UI[i], nil);
		end
	end
end
-----------------------------------------------------------------------------------------
-- Get element id above which mouse currently is
-----------------------------------------------------------------------------------------
function VoidWanderers:GetMouseOverKnownFormElements()
	for i = 1, #self.UI do
		if self.UI[i]["Type"] == self.ElementTypes.BUTTON then
			if self:IsWithinButton(self.UI[i], self.Mouse) then
				return i;
			end
		end
	end

	return nil;
end
-----------------------------------------------------------------------------------------
-- Update Activity
-----------------------------------------------------------------------------------------


function VoidWanderers:UpdateActivity()
	-- Just check for intialization flags in update loop to avoid unnecessary function calls during all the mission
	if self.IsInitialized == nil then
		self.IsInitialized = false;
	end

	if not self.IsInitialized then
		--Init mission if we're still not
		self:StartActivity();
	end

	if self.ActivityState == Activity.OVER then
		return;
	end

	if CF_StopUIProcessing then
		return;
	end

	if self.ProcessBeforeAnything ~= nil then
		self:ProcessBeforeAnything();
	end

	-- Set the screen of disabled 4-th player when we're playing in 3-player mode
	if self.ObserverPos and self:PlayerHuman(Activity.PLAYER_4) then
		CameraMan:SetScrollTarget(self.ObserverPos, 0.04, self:ScreenOfPlayer(Activity.PLAYER_4));
	end

	self:ClearObjectivePoints();

	if self.WasPaused then
		self:RestoreAI();
	end

	local cont = self.PlayerCount == 1 and self.CurCursorMO:GetController() or self.brain:GetController();

	if CF_MenuNavigationScheme == self.MenuNavigationSchemes.KEYBOARD then
		if cont:IsState(Controller.MOVE_LEFT) then
			self.Mouse = self.Mouse + Vector(-5, 0);
		end

		if cont:IsState(Controller.MOVE_RIGHT) then
			self.Mouse = self.Mouse + Vector(5, 0);
		end

		if cont:IsState(Controller.MOVE_UP) then
			self.Mouse = self.Mouse + Vector(0, -5);
		end

		if cont:IsState(Controller.MOVE_DOWN) then
			self.Mouse = self.Mouse + Vector(0, 5);
		end
	elseif CF_MenuNavigationScheme == self.MenuNavigationSchemes.MOUSE then
		-- Read mouse input
		self.Mouse = self.Mouse + UInputMan:GetMouseMovement(CF_FirstActivePlayer);
	else
		self.Mouse = self.Mouse + self:GetPlayerController(CF_FirstActivePlayer).AnalogMove * 5;
	end
	
	
	if self.Mouse.Y > self.Scroll.Y + self.ScrollMinimumDistance then
		self.Scroll.Y = self.Scroll.Y - (self.Scroll.Y + self.ScrollMinimumDistance - self.Mouse.Y) * 0.25;
	end
	if self.Mouse.Y < self.Scroll.Y - self.ScrollMinimumDistance then
		self.Scroll.Y = self.Scroll.Y - (self.Scroll.Y - self.ScrollMinimumDistance - self.Mouse.Y) * 0.25;
	end
	
	self.brain.Pos = self.Scroll * 1;

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
	-- changePos if self.brain is not 

	-- Don't let the cursor leave the screen

	
	if self.PlayerCount == 1 and self.CurCursorMO.ID ~= self.LastCursorMO.ID then
		self.LastCursorMO = self.CurCursorMO;
		self:SetPlayerBrain(self.CurCursorMO, Activity.PLAYER_1);
		
		-- print("MID: " .. self.Mid.X .. ", " .. self.Mid.Y)
		self.MidOffset = (self.CurCursorMO.Pos - self.Mid) / 2;
		-- print("MID: " .. self.Mid.X .. ", " .. self.Mid.Y)
	end

	-- print("OFFSET: " .. self.MidOffset.X .. ", " .. self.MidOffset.Y )
	-- print("MID: " .. self.Mid.X .. ", " .. self.Mid.Y)
	-- print("MOUSE: " .. self.Mouse.X .. ", " .. self.Mouse.Y)

	self.CurCursorMO = self:GetControlledActor(Activity.PLAYER_1);

	-- local CUR_MPOS = self.Mouse ?idOff
	local LEFT_BOUND = self.Mid.X + -self.ResX2 + self.MidOffset.X;
	local RIGHT_BOUND = self.Mid.X + self.ResX2 + self.MidOffset.X - 10;
	local TOP_BOUND = self.MidOffset.Y;
	local BOTTOM_BOUND = self.Mid.Y * 2 + self.MidOffset.Y - 10;
	-- print("BOUNDS: \n\tl: " .. LEFT_BOUND .. "\n\tr: " .. RIGHT_BOUND .. "\n\tu: " .. TOP_BOUND .. "\n\td: " .. BOTTOM_BOUND)

	if self.Mouse.X < LEFT_BOUND then
		self.Mouse.X = LEFT_BOUND;
	end

	if self.Mouse.Y < TOP_BOUND then
		self.Mouse.Y = TOP_BOUND;
	end

	if self.Mouse.X > RIGHT_BOUND  then
		self.Mouse.X = RIGHT_BOUND;
	end

	if self.Mouse.Y > BOTTOM_BOUND  then
		self.Mouse.Y = BOTTOM_BOUND;
	end

	self:DrawMouseCursor();
	self:DisplayCurrentMessage();

	-- Process mouse hovers and presses -- TODO: UInputMan doesn't seem to register the mouse press functions?
	if true or CF_MenuNavigationScheme == self.MenuNavigationSchemes.KEYBOARD then
		self.MouseOverElement = self:GetMouseOverKnownFormElements();

		if self.MouseOverElement then
			if self.UI[self.MouseOverElement]["OnHover"] ~= nil then
				self.UI[self.MouseOverElement]["OnHover"](self);
			end
		end

		-- Process standard input
		if cont:IsState(Controller.WEAPON_FIRE) then
			if not self.MouseFirePressed then
				self.MousePressedElement = self:GetMouseOverKnownFormElements();

				local dontpass = false;

				if self.MousePressedElement ~= nil then
					if self.UI[self.MousePressedElement]["OnClick"] ~= nil then
						dontpass = true;
						self.UI[self.MousePressedElement]["OnClick"](self);
					end
				end

				if not dontpass then
					self:FormClick();
				end

				self.MouseOverElement = nil;
				self.MousePressedElement = nil;
				self.MousePressStartElement = nil;
				self.MousePressEndElement = nil;
			end
			self.MouseFirePressed = true;
		else
			self.MouseFirePressed = false;
		end
	else
		-- Process mouse input
		self.MouseOverElement = self:GetMouseOverKnownFormElements();

		if self.MouseOverElement then
			if self.UI[self.MouseOverElement]["OnHover"] ~= nil then
				self.UI[self.MouseOverElement]["OnHover"](self);
			end
		end

		if UInputMan:MouseButtonPressed(0) then
			self.MousePressStartElement = self:GetMouseOverKnownFormElements();
			self.MousePressEndElement = nil;
			self.MousePressedElement = self:GetMouseOverKnownFormElements();
		end

		if UInputMan:MouseButtonHeld(0) then
			self.MouseOverElement = nil;
			self.MouseButtonHeld = true;
		else
			self.MouseButtonHeld = false;
		end

		if UInputMan:MouseButtonReleased(0) then
			-- Get element above which mouse was released
			self.MousePressEndElement = self:GetMouseOverKnownFormElements();

			local dontpass = false;

			if self.MousePressStartElement ~= nil and self.MousePressStartElement == self.MousePressEndElement then
				if self.MousePressedElement ~= nil then
					if self.UI[self.MousePressedElement]["OnClick"] ~= nil then
						dontpass = true;
						self.UI[self.MousePressedElement]["OnClick"](self);
					end
				end
			end

			-- Don't pass events which were already handled by known controls
			if not dontpass then
				self:FormClick();
			end

			self.MouseOverElement = nil;
			self.MousePressedElement = nil;
			self.MousePressStartElement = nil;
			self.MousePressEndElement = nil;
		end
	end

	--print(self.MouseOverElement);
	--print(self.MousePressedElement);

	self:RedrawKnownFormElements();
	self:FormUpdate();
	self:FormDraw();

	-- Count frames for low performance version of CF_DrawString
	CF_FrameCounter = CF_FrameCounter + 1;

	if CF_FrameCounter >= 10000 then
		CF_FrameCounter = 0;
	end

	--print (self.Mouse - self.Mid)--]]--
end
-----------------------------------------------------------------------------------------
-- Thats all folks!!!
-----------------------------------------------------------------------------------------
