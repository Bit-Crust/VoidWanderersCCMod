-----------------------------------------------------------------------
-- Initialize menu screen systems.
-----------------------------------------------------------------------
function VoidWanderers:StartActivity(isNewGame)
	print("VoidWanderers:StrategyScreen:StartActivity");

	self.AllowsUserSaving = false;

	if self.IsInitialized == nil then
		self.IsInitialized = false;
	elseif self.IsInitialized == true then
		return;
	end
	
	self.MenuNavigationSchemes = { KEYBOARD = 0, MOUSE = 1, GAMEPAD = 2 };
	self.MenuNavigationScheme = self.MenuNavigationSchemes.KEYBOARD;
	self.MenuNavigatingPlayer = Activity.PLAYER_NONE;
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if self:PlayerActive(player) and self:PlayerHuman(player) then
			self.MenuNavigatingPlayer = player;
			local cont = self:GetPlayerController(player);
			if cont:IsMouseControlled() then
				self.MenuNavigationScheme = self.MenuNavigationSchemes.MOUSE;
			elseif cont:IsGamepadControlled() then
				self.MenuNavigationScheme = self.MenuNavigationSchemes.GAMEPAD;
			end
			break;
		end
	end

	self.Mid = Vector(SceneMan.Scene.Width / 4, SceneMan.Scene.Height / 2);

	self.Res = Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight);

	-- Mouse is screen coords
	self.Mouse = Vector();
	-- Scroll is screen offset
	self.Scroll = self.Mid * 1;
	-- Cursor is selection in space
	self.Cursor = self.Mouse + self.Scroll; 

	self.ScrollTriggerThickness = Vector(50, 50);
	self.ScrollingScreen = { X = true, Y = true };

	self.Screen = Box(-self.Res.X / 2, -self.Res.Y / 2, self.Res.X / 2, self.Res.Y / 2);
	self.Bound = Box(self.Mid.X, -200 + self.Mid.Y, self.Mid.X, 300 + self.Mid.Y);

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		self:SetPlayerBrain(nil, player);
		self:SetPlayerHadBrain(player, false);
		FrameMan:ClearScreenText(player);
	end

	self.CamOffset = {};
	self.CamOffset[0] = self.Mid;
	self.CamOffset[1] = self.Mid + Vector(self.Mid.X * 2, -self.Mid.Y / 2);
	self.CamOffset[2] = self.Mid + Vector(self.Mid.X * 2, 0);
	self.CamOffset[3] = self.Mid + Vector(self.Mid.X * 2, self.Mid.Y / 2);

	self.FirePressed = {};
	self.MouseFirePressed = false;

	self.UI = {};

	dofile(FORM_TO_LOAD);
	self:FormLoad();

	self.MouseOverElement = nil;
	self.MousePressedElement = nil;
	self.MousePressStartElement = nil;
	self.MousePressEndElement = nil;

	self.IsInitialized = true;
end
-----------------------------------------------------------------------
-- Update Activity
-----------------------------------------------------------------------
function VoidWanderers:UpdateActivity()
	if not self.IsInitialized then
		print("*");
		self:StartActivity(true);
	end
	
	local cont = self:GetPlayerController(self.MenuNavigatingPlayer);

	if cont:IsMouseControlled() then
		self.MenuNavigationScheme = self.MenuNavigationSchemes.MOUSE;
	elseif cont:IsGamepadControlled() then
		self.MenuNavigationScheme = self.MenuNavigationSchemes.GAMEPAD;
	else
		self.MenuNavigationScheme = self.MenuNavigationSchemes.KEYBOARD;
	end
	
	self:ClearObjectivePoints();

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local screen = self:ScreenOfPlayer(player);
		FrameMan:ClearScreenText(player);
		if screen ~= -1 then
			if screen ~= 0 then
				CameraMan:SetOffset(self.CamOffset[screen] - self.Res / 2, screen);
			else
				CameraMan:SetOffset(self.Scroll - self.Res / 2, screen);
			end
		end
	end

	local prevMouse = self.Mouse * 1;

	if self.MenuNavigationScheme == self.MenuNavigationSchemes.KEYBOARD then
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
	elseif self.MenuNavigationScheme == self.MenuNavigationSchemes.MOUSE then
		self.Mouse = self.Mouse + UInputMan:GetMouseMovement(self.MenuNavigatingPlayer);

		if self.ScrollingScreen.Y and not UInputMan.FlagLShiftState then
			local scrollOffset = Vector(0, -UInputMan:MouseWheelMoved() * 10);
			self.Scroll = self.Scroll + scrollOffset;
		elseif self.ScrollingScreen.X and UInputMan.FlagLShiftState then
			local scrollOffset = Vector(-UInputMan:MouseWheelMoved() * 10, 0);
			self.Scroll = self.Scroll + scrollOffset;
		end
	else
		self.Mouse = self.Mouse + cont.AnalogMove * 5;
	end

	-- Get distance pulled outside screen
	local excess = self.Mouse - self.Screen:GetWithinBox(self.Mouse);
	self.Mouse = self.Mouse - excess;

	-- Add to scroll and then bound
	self.Scroll = self.Bound:GetWithinBox(self.Scroll + excess);

	self.Cursor = self.Mouse + self.Scroll;

	self.MouseOverElement = self:GetMouseOverKnownFormElements();

	if self.MouseOverElement then
		if self.UI[self.MouseOverElement].OnHover ~= nil then
			self.UI[self.MouseOverElement].OnHover(self)
		end
	end

	if self.MenuNavigationScheme == self.MenuNavigationSchemes.MOUSE then
		if UInputMan:MouseButtonPressed(MouseButtons.MOUSE_LEFT, self.MenuNavigatingPlayer) then
			self.MousePressStartElement = self:GetMouseOverKnownFormElements();
			self.MousePressEndElement = nil;
			self.MousePressedElement = self:GetMouseOverKnownFormElements();
		end

		if UInputMan:MouseButtonHeld(MouseButtons.MOUSE_LEFT, self.MenuNavigatingPlayer) then
			self.MouseOverElement = nil;
			self.MouseButtonHeld = true;
		else
			self.MouseButtonHeld = false;
		end

		if UInputMan:MouseButtonReleased(MouseButtons.MOUSE_LEFT, self.MenuNavigatingPlayer) then
			self.MousePressEndElement = self:GetMouseOverKnownFormElements();
			
			local dontpass = false;

			if self.MousePressStartElement ~= nil and self.MousePressStartElement == self.MousePressEndElement then
				if self.MousePressedElement ~= nil then
					if self.UI[self.MousePressedElement].OnClick ~= nil then
						dontpass = true;
						self.UI[self.MousePressedElement].OnClick(self);
					end
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
	else
		if cont:IsState(Controller.WEAPON_FIRE) then
			if not self.MouseFirePressed then
				self.MousePressStartElement = self:GetMouseOverKnownFormElements();
				self.MousePressEndElement = nil;
				self.MousePressedElement = self:GetMouseOverKnownFormElements();
			end

			self.MouseOverElement = nil;
			self.MouseFirePressed = true;
		else
			if self.MouseFirePressed then
				self.MousePressEndElement = self:GetMouseOverKnownFormElements();

				local dontpass = false;

				if self.MousePressStartElement ~= nil and self.MousePressStartElement == self.MousePressEndElement then
					if self.MousePressedElement ~= nil then
						if self.UI[self.MousePressedElement].OnClick ~= nil then
							dontpass = true;
							self.UI[self.MousePressedElement].OnClick(self);
						end
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

			self.MouseFirePressed = false;
		end
	end

	self:RedrawKnownFormElements()
	self:FormUpdate()
	self:FormDraw()
	PrimitiveMan:DrawBitmapPrimitive(self:ScreenOfPlayer(self.MenuNavigatingPlayer), self.Cursor + Vector(5, 5), "Mods/VoidWanderers.rte/UI/Generic/Cursor.png", 0)
end
-----------------------------------------------------------------------
-- Check if pos is within button area
-----------------------------------------------------------------------
function VoidWanderers:IsWithinButton(el, pos)
	local isvisible = true

	if el.Visible ~= nil then
		if el.Visible == false then
			isvisible = false
		end
	end

	if isvisible then
		local elpos = el.Pos
		local wx = el.Width
		local wy = el.Height

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
function VoidWanderers:RedrawKnownFormElements()
	for i = 1, #self.UI do
		if self.UI[i].Type == CF.ElementTypes.BUTTON then
			local button = self.UI[i];
			local state = CF.ElementStates.IDLE;
			if i == self.MousePressedElement then
				state = CF.ElementStates.PRESSED;
			elseif i == self.MouseOverElement then
				state = CF.ElementStates.MOUSE_OVER;
			end
			button.State = state;

			CF.DrawButton(button);
		end

		if self.UI[i].Type == CF.ElementTypes.LABEL then
			CF.DrawLabel(self.UI[i])
		end
	end
end
-----------------------------------------------------------------------
-- Get element id above which mouse currently is
-----------------------------------------------------------------------
function VoidWanderers:GetMouseOverKnownFormElements()
	for i = 1, #self.UI do
		if self.UI[i].Type == CF.ElementTypes.BUTTON then
			if self:IsWithinButton(self.UI[i], self.Cursor) then
				return i
			end
		end
	end

	return nil
end
-----------------------------------------------------------------------
-- Thats all folks!!!
-----------------------------------------------------------------------
