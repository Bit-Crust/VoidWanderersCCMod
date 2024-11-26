-----------------------------------------------------------------------------------------
-- Initialize menu screen systems.
-----------------------------------------------------------------------------------------

local menuPanelBase = { 228 };
local menuPanelTrim = { 227, 50, 190 };
local menuPanelSheen = { 173 };
local menuPanelInset = { 224 };
local menuPanelGround = { 189, 190, 209, 213, 11, 12 };

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
			if self:GetPlayerController(player):IsMouseControlled() then
				self.MenuNavigationScheme = self.MenuNavigationSchemes.MOUSE;
			elseif self:GetPlayerController(player):IsGamepadControlled() then
				self.MenuNavigationScheme = self.MenuNavigationSchemes.GAMEPAD;
			end
			break;
		end
	end

	self.Mid = Vector(SceneMan.Scene.Width / 4, SceneMan.Scene.Height / 2);

	self.Res = Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight);

	self.Mouse = Vector();
	self.Scroll = self.Mid * 1;
	self.Cursor = self.Mouse + self.Scroll; 

	self.ScrollTriggerThickness = Vector(50, 50);
	self.ScrollingScreen = { X = true, Y = true };

	self.Screen = Box(-self.Res.X / 2, -self.Res.Y / 2, self.Res.X / 2, self.Res.Y / 2);
	self.Bound = Box(-500 + self.Mid.X, -200 + self.Mid.Y, 100 + self.Mid.X, 300 + self.Mid.Y);

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		self:SetPlayerBrain(nil, player);
		FrameMan:ClearScreenText(player);
	end

	self.CamOffset = {};
	self.CamOffset[0] = self.Mid;
	self.CamOffset[1] = self.Mid + Vector(self.Mid.X * 2, -self.Mid.Y / 2);
	self.CamOffset[2] = self.Mid + Vector(self.Mid.X * 2, 0);
	self.CamOffset[3] = self.Mid + Vector(self.Mid.X * 2, self.Mid.Y / 2);

	self.FirePressed = {}
	self.MouseFirePressed = true

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
			local w = CF.GetStringPixelWidth(el["Text"])
			CF.DrawString(el["Text"], Vector(el.Pos.X - (w / 2) + 4, el.Pos.Y), el["Width"], el["Height"])
		else
			CF.DrawString(el["Text"], el.Pos, el["Width"], el["Height"])
		end
	end
end
-----------------------------------------------------------------------------------------
-- Draw button element
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawButton(el, state)
	if el.Visible ~= false then
		if el.Text then
			local w = CF.GetStringPixelWidth(el.Text)
			CF.DrawString(el.Text, Vector(el.Pos.X - (w / 2) + 4, el.Pos.Y), el.Width, el.Height)
		end

		PrimitiveMan:DrawBoxFillPrimitive(el.Pos - Vector(el.Width, el.Height) / 2, el.Pos + Vector(el.Width, el.Height) / 2 - Vector(1, 1), menuPanelBase[1])
		PrimitiveMan:DrawBoxFillPrimitive(el.Pos - Vector(el.Width, el.Height) / 2 + Vector(1, 1), el.Pos + Vector(el.Width, el.Height) / 2 - Vector(3, 3), menuPanelTrim[state + 1])
		if state == 0 then
			PrimitiveMan:DrawBoxFillPrimitive(el.Pos - Vector(el.Width, el.Height) / 2 + Vector(1, 1), el.Pos - Vector(el.Width, el.Height) / 2 + Vector(1, 1), menuPanelSheen[1])
		end
		if state == 2 then
			PrimitiveMan:DrawBoxFillPrimitive(el.Pos - Vector(el.Width, el.Height) / 2 + Vector(2, 2), el.Pos + Vector(el.Width, el.Height) / 2 - Vector(4, 4), menuPanelInset[1])
			PrimitiveMan:DrawBoxFillPrimitive(el.Pos - Vector(el.Width, el.Height) / 2 + Vector(3, 3), el.Pos + Vector(el.Width, el.Height) / 2 - Vector(4, 4), menuPanelGround[state == 0 and 1 or 2])
		else
			PrimitiveMan:DrawBoxFillPrimitive(el.Pos - Vector(el.Width, el.Height) / 2 + Vector(2, 2), el.Pos + Vector(el.Width, el.Height) / 2 - Vector(4, 4), menuPanelGround[state == 0 and 1 or 2])
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
	for i = 1, #self.UI do
		-- Redraw button
		if self.UI[i]["Type"] == self.ElementTypes.BUTTON then
			local state = self.ButtonStates.IDLE

			if i == self.MouseOverElement then
				state = self.ButtonStates.MOUSE_OVER
			end

			if i == self.MousePressedElement then
				state = self.ButtonStates.PRESSED
			end

			self:DrawButton(self.UI[i], state, true)
		end

		if self.UI[i]["Type"] == self.ElementTypes.LABEL then
			self:DrawLabel(self.UI[i])
		end
	end
end
-----------------------------------------------------------------------------------------
-- Get element id above which mouse currently is
-----------------------------------------------------------------------------------------
function VoidWanderers:GetMouseOverKnownFormElements()
	for i = 1, #self.UI do
		if self.UI[i]["Type"] == self.ElementTypes.BUTTON then
			if self:IsWithinButton(self.UI[i], self.Cursor) then
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
	if not self.IsInitialized then
		--Init mission if we're still not
		print("*");
		self:StartActivity(true);
	end

	self:ClearObjectivePoints();

	-- Set the screen of disabled 4-th player when we're playing in 3-player mode
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local screen = self:ScreenOfPlayer(player);
		if screen ~= -1 then
			if screen ~= 0 then
				CameraMan:SetOffset(self.CamOffset[screen] - self.Res / 2, screen);
			else
				CameraMan:SetOffset(self.Scroll - self.Res / 2, screen);
			end
		end
	end

	-- Record previous mouse position to avoid scrolling artifacts.
	local prevMouse = self.Mouse * 1;
	
	local cont = self:GetPlayerController(self.MenuNavigatingPlayer);

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
		-- Read mouse input
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

	-- Don't let the cursor leave the screen

	local dim = { X = "Width", Y = "Height" };

	for _, axis in ipairs{"X", "Y"} do
	end

	local diff = self.Mouse - self.Screen:GetWithinBox(self.Mouse);

	self.Mouse = self.Mouse - diff;
	self.Scroll = self.Bound:GetWithinBox(self.Scroll + diff);

	self.Cursor = self.Mouse + self.Scroll;

	-- Process mouse hovers and presses -- TODO: UInputMan doesn't seem to register the mouse press functions?
	if self.MenuNavigationScheme == self.MenuNavigationSchemes.KEYBOARD then
		self.MouseOverElement = self:GetMouseOverKnownFormElements()

		if self.MouseOverElement then
			if self.UI[self.MouseOverElement].OnHover ~= nil then
				self.UI[self.MouseOverElement].OnHover(self)
			end
		end

		-- Process standard input
		if cont:IsState(Controller.WEAPON_FIRE) then
			if not self.MouseFirePressed then
				self.MousePressedElement = self:GetMouseOverKnownFormElements()

				local dontpass = false

				if self.MousePressedElement ~= nil then
					if self.UI[self.MousePressedElement].OnClick ~= nil then
						dontpass = true
						self.UI[self.MousePressedElement].OnClick(self)
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
			if self.UI[self.MouseOverElement].OnHover ~= nil then
				self.UI[self.MouseOverElement].OnHover(self)
			end
		end

		if UInputMan:MouseButtonPressed(MouseButtons.MOUSE_LEFT, self.MenuNavigatingPlayer) then
			self.MousePressStartElement = self:GetMouseOverKnownFormElements()
			self.MousePressEndElement = nil
			self.MousePressedElement = self:GetMouseOverKnownFormElements()
		end

		if UInputMan:MouseButtonHeld(MouseButtons.MOUSE_LEFT, self.MenuNavigatingPlayer) then
			self.MouseOverElement = nil
			self.MouseButtonHeld = true
		else
			self.MouseButtonHeld = false
		end

		if UInputMan:MouseButtonReleased(MouseButtons.MOUSE_LEFT, self.MenuNavigatingPlayer) then
			-- Get element above which mouse was released
			self.MousePressEndElement = self:GetMouseOverKnownFormElements()

			local dontpass = false

			if self.MousePressStartElement ~= nil and self.MousePressStartElement == self.MousePressEndElement then
				if self.MousePressedElement ~= nil then
					if self.UI[self.MousePressedElement].OnClick ~= nil then
						dontpass = true
						self.UI[self.MousePressedElement].OnClick(self)
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

	self:RedrawKnownFormElements()
	self:FormUpdate()
	self:FormDraw()
	PrimitiveMan:DrawBitmapPrimitive(self:ScreenOfPlayer(self.MenuNavigatingPlayer), self.Cursor + Vector(5, 5), "Mods/VoidWanderers.rte/UI/Generic/Cursor.png", 0)
end
-----------------------------------------------------------------------------------------
-- Thats all folks!!!
-----------------------------------------------------------------------------------------
