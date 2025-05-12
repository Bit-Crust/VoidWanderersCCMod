-----------------------------------------------------------------------
-- Start Scene Process.
-----------------------------------------------------------------------
function VoidWanderers:StartSceneProcess()
	print("VoidWanderers:StrategyScreen:StartSceneProcess");

	self.AllowsUserSaving = false;

	self.screens = { SCREEN_NONE = -1, SCREEN_ONE = 0, SCREEN_TWO = 1, SCREEN_THREE = 2, SCREEN_FOUR = 3, MAXSCREENCOUNT = 4 };
	self.menuNavigationSchemes = { KEYBOARD = 0, MOUSE = 1, GAMEPAD = 2 };

	self.menuNavigationScheme = self.menuNavigationSchemes.KEYBOARD;
	self.menuNavigatingPlayer = Activity.PLAYER_NONE;

	for player = Activity.PLAYER_NONE + 1, Activity.MAXPLAYERCOUNT - 1 do
		if self:PlayerActive(player) and self:PlayerHuman(player) then
			self.menuNavigatingPlayer = player;
			local cont = self:GetPlayerController(player);

			if cont:IsMouseControlled() then
				self.menuNavigationScheme = self.menuNavigationSchemes.MOUSE;
			elseif cont:IsGamepadControlled() then
				self.menuNavigationScheme = self.menuNavigationSchemes.GAMEPAD;
			end

			break;
		end
	end

	self.mid = Vector(SceneMan.Scene.Width / 4, SceneMan.Scene.Height / 2);
	self.res = Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight);
	self.mouse = Vector();
	self.scroll = self.mid * 1;
	self.cursor = self.mouse + self.scroll; 
	self.scrollingScreen = { X = false, Y = false };
	self.screen = Box(-self.res.X / 2, -self.res.Y / 2, self.res.X / 2, self.res.Y / 2);
	self.bound = Box(self.mid.X, self.res.Y / 2, self.mid.X, SceneMan.Scene.Height - self.res.Y / 2);

	for player = Activity.PLAYER_NONE + 1, Activity.MAXPLAYERCOUNT - 1 do
		self:SetPlayerBrain(nil, player);
		self:SetPlayerHadBrain(player, false);
		FrameMan:ClearScreenText(player);
	end

	self.camOffset = {
		[0] = self.mid,
		[1] = self.mid + Vector(self.mid.X * 2, -self.mid.Y / 2),
		[2] = self.mid + Vector(self.mid.X * 2, 0),
		[3] = self.mid + Vector(self.mid.X * 2, self.mid.Y / 2),
	};

	self.mouseFirePressed = false;
	self.hoverOverIndex = nil;
	self.pressHoldIndex = nil;
	self.pressStartIndex = nil;
end
-----------------------------------------------------------------------
-- Update Scene Process
-----------------------------------------------------------------------
function VoidWanderers:UpdateSceneProcess()
	self:ClearObjectivePoints();
	local navigator = self.menuNavigatingPlayer;
	local cont = self:GetPlayerController(navigator);

	if cont:IsMouseControlled() then
		self.menuNavigationScheme = self.menuNavigationSchemes.MOUSE;
	elseif cont:IsGamepadControlled() then
		self.menuNavigationScheme = self.menuNavigationSchemes.GAMEPAD;
	else
		self.menuNavigationScheme = self.menuNavigationSchemes.KEYBOARD;
	end

	for player = Activity.PLAYER_NONE + 1, Activity.MAXPLAYERCOUNT - 1 do
		local screen = self:ScreenOfPlayer(player);
		FrameMan:ClearScreenText(screen);

		if screen ~= self.screens.SCREEN_NONE then
			if screen == self.screens.SCREEN_ONE then
				CameraMan:SetOffset(self.scroll - self.res / 2, screen);
			else
				CameraMan:SetOffset(self.camOffset[screen] - self.res / 2, screen);
			end
		end
	end

	local prevMouse = self.mouse * 1;

	if self.menuNavigationScheme == self.menuNavigationSchemes.MOUSE then
		self.mouse = self.mouse + UInputMan:GetMouseMovement(navigator);

		if self.scrollingScreen.Y and not UInputMan.FlagLShiftState then
			local scrollOffset = Vector(0, -UInputMan:MouseWheelMoved() * 10);
			self.scroll = self.scroll + scrollOffset;
		elseif self.scrollingScreen.X and UInputMan.FlagLShiftState then
			local scrollOffset = Vector(-UInputMan:MouseWheelMoved() * 10, 0);
			self.scroll = self.scroll + scrollOffset;
		end
	elseif self.menuNavigationScheme == self.menuNavigationSchemes.KEYBOARD then
		if cont:IsState(Controller.MOVE_LEFT) then
			self.mouse = self.mouse + Vector(-5, 0);
		end

		if cont:IsState(Controller.MOVE_RIGHT) then
			self.mouse = self.mouse + Vector(5, 0);
		end

		if cont:IsState(Controller.MOVE_UP) then
			self.mouse = self.mouse + Vector(0, -5);
		end

		if cont:IsState(Controller.MOVE_DOWN) then
			self.mouse = self.mouse + Vector(0, 5);
		end
	elseif self.menuNavigationScheme == self.menuNavigationSchemes.GAMEPAD then
		self.mouse = self.mouse + cont.AnalogMove * 5;
	end

	local screenPull = self.mouse - self.screen:GetWithinBox(self.mouse);
	self.mouse = self.mouse - screenPull;
	self.scroll = self.bound:GetWithinBox(self.scroll + screenPull);
	self.cursor = self.mouse + self.scroll;

	local hoverOverIndex = 0;
	
	for i = 1, #self.ui do
		local element = self.ui[i];

		if element.Type == CF.ElementTypes.BUTTON and element.Visible ~= false then
			local mouseOffset = self.cursor - element.Pos;
			local withinX = math.abs(mouseOffset.X) < element.Width / 2;
			local withinY = math.abs(mouseOffset.Y) < element.Height / 2;

			if withinX and withinY then
				hoverOverIndex = i;
				break;
			end
		end
	end

	local pressHoldIndex = self.pressHoldIndex;
	local pressStartIndex = self.pressStartIndex;
	local pressEndIndex = self.pressEndIndex;

	if self.menuNavigationScheme == self.menuNavigationSchemes.MOUSE then
		if UInputMan:MouseButtonPressed(MouseButtons.MOUSE_LEFT, navigator) then
			pressStartIndex = hoverOverIndex;
		end

		if UInputMan:MouseButtonReleased(MouseButtons.MOUSE_LEFT, navigator) then
			pressEndIndex = hoverOverIndex;
		end

		if UInputMan:MouseButtonHeld(MouseButtons.MOUSE_LEFT, navigator) then
			pressHoldIndex = hoverOverIndex;
			hoverOverIndex = nil;
		else
			pressHoldIndex = nil;
		end
	else
		if cont:IsState(Controller.WEAPON_FIRE) then
			if not self.mouseFirePressed then
				pressStartIndex = hoverOverIndex;
			end

			hoverOverIndex = nil;
			self.mouseFirePressed = true;
		else
			if self.mouseFirePressed then
				pressEndIndex = hoverOverIndex;
			end

			self.mouseFirePressed = false;
		end
	end
	
	for i = 1, #self.ui do
		local element = self.ui[i];

		if element.Type == CF.ElementTypes.BUTTON then
			element.State = CF.ElementStates.IDLE;
		end
	end

	if pressStartIndex then
		local element = self.ui[pressStartIndex];
		
		if element ~= nil then
			if element.Type == CF.ElementTypes.BUTTON then
				element.State = CF.ElementStates.PRESSED;
			end
		end
	end

	if hoverOverIndex then
		local element = self.ui[hoverOverIndex];

		if element ~= nil then
			if element.Type == CF.ElementTypes.BUTTON then
				element.State = CF.ElementStates.MOUSE_OVER;
			end

			local elementOnHover = element.OnHover;
		
			if elementOnHover ~= nil then
				elementOnHover(element, self);
			end
		end
	end

	if pressStartIndex ~= nil and pressEndIndex ~= nil then
		local dontpass = false;
		
		if pressStartIndex == pressEndIndex then
			local clickedElement = self.ui[pressEndIndex];

			if clickedElement ~= nil then
				local elementOnClick = clickedElement.OnClick;

				if elementOnClick ~= nil then
					dontpass = true;
					elementOnClick(clickedElement, self);
				end
			end
		end

		if not dontpass then
			self.form:Click();
		end

		pressStartIndex = nil;
		pressEndIndex = nil;
	end

	self.hoverOverIndex = hoverOverIndex;
	self.pressHoldIndex = pressHoldIndex;
	self.pressStartIndex = pressStartIndex;
	
	self.form:Update();

	for i = 1, #self.ui do
		local element = self.ui[i];
		
		if element.Type == CF.ElementTypes.BUTTON then
			CF.DrawButton(element);
		elseif element.Type == CF.ElementTypes.LABEL then
			CF.DrawLabel(element);
		end
	end

	self.form:Draw();

	PrimitiveMan:DrawBitmapPrimitive(Activity.PLAYER_NONE, self.cursor + Vector(5, 5), "Mods/VoidWanderers.rte/UI/Generic/Cursor.png", 0);
end
-----------------------------------------------------------------------
-- 
-----------------------------------------------------------------------
function VoidWanderers:CloseSceneProcess()
	self.form:Close();
end
-----------------------------------------------------------------------
-- Thats all folks!!!
-----------------------------------------------------------------------
