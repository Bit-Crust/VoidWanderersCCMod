-----------------------------------------------------------------------
--	Load event. Put all UI element initialiations here.
-----------------------------------------------------------------------
function VoidWanderers:FormLoad()
	-- Clear old elements
	self.UI = {};
	self.ScrollingScreen = { X = false, Y = true };

	local el;

	self.TileW = 60;
	self.TileH = 70;

	-- Load factions
	self.PlayableFactionCount = 0;

	self.FactionButtons = {};
	local largestFactionDescriptionHeight = 0;

	for i = 1, #CF.Factions do
		if CF.FactionPlayable[CF.Factions[i]] then
			self.PlayableFactionCount = self.PlayableFactionCount + 1;
			local el = {};
			
			el.Type = CF.ElementTypes.BUTTON;
			el.Width = self.TileW;
			el.Height = self.TileH;
			el.Backdrop = false;
			el.Text = "";
			el.Palettes = CF.MenuNormalPalette;

			el.Description = CF.FactionDescriptions[CF.Factions[i]];
			el.FactionName = CF.FactionNames[CF.Factions[i]];
			el.FactionId = CF.Factions[i];
			el.Selected = false;
			el.IsPlayer = false;
			
			largestFactionDescriptionHeight = math.max(CF.GetStringPixelWidth(el.Description) / 400, largestFactionDescriptionHeight);

			self.FactionButtons[self.PlayableFactionCount] = el;
			self.UI[#self.UI + 1] = el;
		end
	end
	
	largestFactionDescriptionHeight = math.ceil(largestFactionDescriptionHeight) * 11 + 22;

	self.MaxCPUPlayersSelectable = #CF.Factions - 1;

	self.FactionButtonsPerRow = math.floor(FrameMan.PlayerScreenWidth / (self.TileW + 1)); -- Plates per row

	if self.PlayableFactionCount < self.FactionButtonsPerRow then
		self.FactionButtonsPerRow = self.PlayableFactionCount;
	end

	self.Rows = math.ceil(self.PlayableFactionCount / self.FactionButtonsPerRow);

	el = {};
	el.Type = CF.ElementTypes.LABEL;
	el.Preset = nil;
	el.Pos = self.Mid + Vector(0, -self.Rows * self.TileH - largestFactionDescriptionHeight);
	el.Text = "START NEW GAME";
	el.Width = 800;
	el.Height = 11;
	el.Centered = true;

	self.UI[#self.UI + 1] = el;
	self.LblHeader = el;

	el = {};
	el.Type = CF.ElementTypes.LABEL;
	el.Preset = nil;
	el.Pos = self.Mid + Vector(0, -self.Rows * self.TileH - largestFactionDescriptionHeight + 10);
	el.Text = "SELECT STARTING FACTION";
	el.Width = 800;
	el.Height = 11;
	el.Centered = true;

	self.UI[#self.UI + 1] = el;
	self.LblPhase = el;

	el = {};
	el.Type = CF.ElementTypes.LABEL;
	el.Preset = nil;
	el.Pos = self.Mid + Vector(0, -self.Rows * self.TileH - largestFactionDescriptionHeight + 30);
	el.Text = "";
	el.Width = 400;
	el.Height = 100;
	el.Centered = true;

	self.UI[#self.UI + 1] = el
	self.LblFactionName = el

	el = {};
	el.Type = CF.ElementTypes.LABEL;
	el.Preset = nil;
	el.Pos = self.Mid + Vector(-190, -self.Rows * self.TileH - largestFactionDescriptionHeight + 40);
	el.Text = " - ";
	el.Width = 400;
	el.Height = 100;
	el.Centered = false;

	self.UI[#self.UI + 1] = el;
	self.LblFactionDescription = el;

	el = {};
	el.Type = CF.ElementTypes.BUTTON;
	el.Pos = self.Mid + Vector(0, 60);
	el.Text = "OK";
	el.Width = 140;
	el.Height = 40;
	el.Visible = false;

	el.OnClick = self.BtnOk_OnClick;

	self.UI[#self.UI + 1] = el;
	self.BtnOk = el;

	el = {};
	el.Type = CF.ElementTypes.BUTTON;
	el.Pos = self.Mid + Vector(self.Res.X / 2 - 70 - 20, - self.Res.Y / 2 + 20 + 20);
	el.Text = "Back";
	el.Width = 140;
	el.Height = 40;
	el.Visible = true;

	el.OnClick = self.BtnBack_OnClick;

	self.UI[#self.UI + 1] = el;
	self.BtnBack = el;

	local xtile = 1;
	local ytile = 0;
	local tilesperrow = 0;
	local tileH2 = 80;

	-- Init factions UI
	for i = 1, self.PlayableFactionCount do
		if i <= self.PlayableFactionCount - self.PlayableFactionCount % self.FactionButtonsPerRow then
			tilesperrow = self.FactionButtonsPerRow;
		else
			tilesperrow = self.PlayableFactionCount % self.FactionButtonsPerRow;
		end

		self.FactionButtons[i].Pos = Vector(
			self.Mid.X - ((tilesperrow * self.TileW) / 2) + (xtile * self.TileW) - (self.TileW / 2),
			self.Mid.Y - (ytile * 70)
		);

		xtile = xtile + 1;
		if (xtile > self.FactionButtonsPerRow) then
			xtile = 1;
			ytile = ytile + 1;
		end
	end

	for i = 1, self.PlayableFactionCount do
		local actor = CF.SpawnRandomInfantry(
			-1,
			self.FactionButtons[i].Pos,
			self.FactionButtons[i].FactionId,
			Actor.AIMODE_SENTRY
		);
		if actor ~= nil then
			actor:EnableOrDisableAllScripts(false);
			actor:SetControllerMode(Controller.CIM_DISABLED, -1);
			actor.ToSettle = true;
			actor.IgnoreTerrain = true;
			actor.IgnoresActorHits = true;
			actor.HFlipped = false;
			actor.SimUpdatesBetweenScriptedUpdates = 0;
			actor.HitsMOs = false;
			actor.GetsHitByMOs = false;
			actor:ClearForces();

			if (actor.Height > self.TileH) then
				actor.Scale = self.TileH / actor.Height;
			end

			self.FactionButtons[i].Actor = actor;
		end
	end

	self.NoMOIDPlaceholders = {};

	-- Interface logic
	self.Phases = {};
	for i = 1, (self.MaxCPUPlayersSelectable + 1) do
		self.Phases[i] = "player";
	end
	self.Phase = 0;

	-- Selections
	self.SelectedPlayerFaction = 0;
	self.SelectedPlayerAlly = 0;
	self.SelectedCPUFactions = {};
	self.NoMOIDPlaceholders[0] = false;
	for i = 1, self.MaxCPUPlayersSelectable do
		self.SelectedCPUFactions[i] = 0;
		self.NoMOIDPlaceholders[i] = false;
	end

	-- Draw selection plates
	self.SelectionButtons = {};
	local xtile = 1;
	local ytile = 0;
	local tilesperrow = self.FactionButtonsPerRow;


	for i = 1, self.MaxCPUPlayersSelectable do
		el = {};
		el.Type = CF.ElementTypes.LABEL;
		el.Pos = Vector(
			self.Mid.X - ((tilesperrow * self.TileW) / 2) + (xtile * self.TileW) - (self.TileW / 2),
			self.Mid.Y + 90 + (ytile * tileH2) + 60
		);
		el.Width = 60;
		el.Backdrop = true;
		el.Palettes = i == 1 and CF.MenuSelectPalette or CF.MenuNormalPalette;
		el.State = i == 1 and CF.ElementStates.IDLE or CF.ElementStates.MOUSE_OVER;
		el.Height = 70;

		self.SelectionButtons[i] = el;
		self.UI[#self.UI + 1] = el;

		-- Add labels
		local el = {};
		el.Type = CF.ElementTypes.LABEL;
		el.Pos = self.SelectionButtons[i].Pos + Vector(0, -39);
		el.Text = i == 1 and "PLAYER" or ("FACTION " .. i);
		el.Width = self.TileW;
		el.Height = 11;
		el.Centered = true;
		self.UI[#self.UI + 1] = el;

		xtile = xtile + 1;
		if (xtile > tilesperrow) then
			xtile = 1;
			ytile = ytile + 1;
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:BtnOk_OnClick()
	-- Create new game file
	local player = self.FactionButtons[self.SelectedPlayerFaction].FactionId
	for i = 1, self.MaxCPUPlayersSelectable do
		if (self.SelectedCPUFactions[i] == 0) then
			table.remove(self.SelectedCPUFactions, i)
			self.SelectedCPUFactions[self.MaxCPUPlayersSelectable] = 0
			i = i - 1
		end
	end
	
	local cpu = {player}
	for i = 1, self.MaxCPUPlayersSelectable do
		if self.SelectedCPUFactions[i] ~= 0 then
			cpu[i + 1] = self.FactionButtons[self.SelectedCPUFactions[i]].FactionId
		end
	end

	-- Create new game state
	self.GS = CF.MakeFreshGameState(player, cpu, self)
	self:OnSave()
	self:LoadSaveData()
	self:FormClose()
	self:LaunchScript(self.GS["Scene"], "Tactics.lua")
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:GetFactionButtonUnderMouse(pos)
	for i = 1, #self.FactionButtons do
		local elpos = self.FactionButtons[i].Pos
		local wx = self.FactionButtons[i].Width
		local wy = self.FactionButtons[i].Height

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
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:BtnBack_OnClick()
	self:FormClose();
	for _, set in pairs{MovableMan.Actors, MovableMan.AddedActors} do
		for actor in set do
			MovableMan:RemoveActor(actor);
		end
	end
	dofile(BASE_PATH .. "FormStart.lua");
	self:FormLoad();
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
local addSoundContainer = CreateSoundContainer("Confirm")
local removeSoundContainer = CreateSoundContainer("Error")
local selectedActors = {}
local freeSpots = {}
function VoidWanderers:FormClick()
	local f = self:GetFactionButtonUnderMouse(self.Cursor)

	if f ~= nil then
		-- If a faction is already in the list, note where so we can remove it on click
		local removeIndex = 0
		local isPlayerFaction = f == self.SelectedPlayerFaction

		if not isPlayerFaction then
			for i = 1, #self.Phases do
				if self.SelectedCPUFactions[i] == f then
					removeIndex = i
					break
				end
			end
		end

		if not (isPlayerFaction or removeIndex > 0) then
			-- If we're clear, add a unit and a faction to the list
			local actor = CF.SpawnRandomInfantry(
				-1,
				self.SelectionButtons[self.Phase + 1].Pos,
				self.FactionButtons[f].FactionId,
				Actor.AIMODE_SENTRY
			)

			if not actor then
				self.NoMOIDPlaceholders[self.Phase] = true
			else
				actor.HFlipped = false
				actor:SetControllerMode(Controller.CIM_DISABLED, -1)
				actor.HitsMOs = false
				actor.GetsHitByMOs = false
				actor.IgnoresTerrain = true
				selectedActors[self.Phase] = actor
			end

			if self.Phase == 0 then
				self.SelectedPlayerFaction = f
				self.FactionButtons[f].IsPlayer = true
			elseif self.Phase > 0 then
				self.SelectedCPUFactions[self.Phase] = f
			end

			self.FactionButtons[f].Selected = true
			self.FactionButtons[f].Palettes = CF.MenuDeniedPalette

			addSoundContainer:Play()
		else
			-- If we're removing a faction, remove it and their guy
			if isPlayerFaction then
				self.SelectedPlayerFaction = 0
			else
				self.SelectedCPUFactions[removeIndex] = 0
			end

			local actor = selectedActors[removeIndex]
			if actor ~= nil then
				actor.ToDelete = true
			end
			selectedActors[removeIndex] = nil
			self.FactionButtons[f].IsPlayer = false
			self.FactionButtons[f].Selected = false
			self.FactionButtons[f].Palettes = CF.MenuNormalPalette

			removeSoundContainer:Play()
		end

		-- Find the first open slot for a faction
		self.Phase = 0
		
		if self.SelectedPlayerFaction ~= 0 then
			for i = 1, #self.Phases do
				self.Phase = self.Phase + 1
				if self.SelectedCPUFactions[i] == 0 then
					break
				end
			end
		end
		
		self.LblPhase["Text"] = (self.Phase == #self.Phases) and "ALL FACTIONS SELECTED, REARRANGE OR CONTINUE" or ("SELECT " .. (self.Phase > 0 and ("CPU " .. self.Phase) or "STARTING") .. " FACTION")

		-- Allow continuing only with at least 5 factions selected, and only if player faction is selected
		local validFactions = 0

		if self.SelectedPlayerFaction ~= 0 then
			validFactions = 1
			for i = 1, #self.Phases do
				if self.SelectedCPUFactions[i] ~= 0 then
					validFactions = validFactions + 1
				end
			end
		end
		
		self.BtnOk["Visible"] = validFactions > 5
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:FormUpdate()
	-- Redraw plates on hover or press
	local f = self:GetFactionButtonUnderMouse(self.Cursor);

	if self.LastMouseOver and self.LastMouseOver ~= f then
		-- Clear faction description
		self.LblFactionDescription["Text"] = "";
		self.LblFactionName["Text"] = "";
	end

	if f ~= nil then
		if not self.MouseButtonHeld then
			-- Update faction description
			self.LblFactionDescription["Text"] = self.FactionButtons[f].Description;
			self.LblFactionName["Text"] = string.upper(self.FactionButtons[f].FactionName);
		end
		self.LastMouseOver = f;
	end

	-- Print out of MOID warning
	for i = 0, self.MaxCPUPlayersSelectable do
		if self.NoMOIDPlaceholders[i] then
			local s = "No MOIDs";
			local l = CF.GetStringPixelWidth(s);

			CF.DrawString(s, self.SelectionButtons[i + 1].Pos + Vector(-l / 2, 0), 100, 100); 
		end
	end
end
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
