local NewGameForm = {};
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
local function okButtonOnClick(element, form, activity)
	local cpu = {};
	
	for index = 1, form.playableFactionCount do
		factionInSlot = form.selectedParticipants[index];

		if factionInSlot ~= 0 then
			table.insert(cpu, form.playableFactions[factionInSlot]);
		end
	end
	
	for index = 1, #form.factionsStatic do
		table.insert(cpu, form.factionsStatic[index]);
	end

	activity.GS = activity:makeFreshGameState(cpu[1], cpu);
	activity.sceneToLaunch = activity.GS["Scene"];
	activity.scriptToLaunch = "Tactics.lua";
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
local function backButtonOnClick(element, form, activity)
	activity.formToLoad = "FormStart.lua";
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
local function factionButtonOnClick(element, form, activity)
	local meta = element.Metadata;
	local faction = meta.factionId;
	local factionIndex = meta.index;

	local removing = false;
	local relevantIndex = 0;
	
	for index = 1, form.playableFactionCount do
		local factionInSlot = form.selectedParticipants[index];
		
		if factionInSlot == 0 then
			if relevantIndex == 0 then
				relevantIndex = index;
			end
		else
			if factionInSlot == factionIndex then
				removing = true;
				relevantIndex = index;
				break;
			end
		end
	end

	if not removing then
		local slot = form.participantSlots[relevantIndex];
		local actor = CF.SpawnRandomInfantry(-1, slot.Pos, faction, Actor.AIMODE_SENTRY);

		if actor then
			actor.HFlipped = false;
			actor:SetControllerMode(Controller.CIM_DISABLED, -1);
			actor.HitsMOs = false;
			actor.GetsHitByMOs = false;
			actor.IgnoresTerrain = true;

			slot.Metadata.actor = actor;
		end

		form.selectedParticipants[relevantIndex] = factionIndex;
		form.factionButtons[factionIndex].Palettes = CF.MenuDeniedPalette;

		form.addSoundContainer:Play();
	else
		local slotMeta = form.participantSlots[relevantIndex].Metadata;
		local actor = slotMeta.actor;

		if actor ~= nil then
			actor.ToDelete = true;

			slotMeta.actor = nil;
		end
		
		form.selectedParticipants[relevantIndex] = 0;
		form.factionButtons[factionIndex].Palettes = CF.MenuNormalPalette;

		form.removeSoundContainer:Play();
	end
	
	local validParticipants = 0;
	local firstHole = 0;

	for index = 1, form.playableFactionCount do
		if form.selectedParticipants[index] == 0 then
			if firstHole == 0 then
				firstHole = index;
			end
		else
			validParticipants = validParticipants + 1;
		end
	end

	local playerSelected = firstHole ~= 1;

	if firstHole == 0 then
		form.phaseLabel.Text = "ALL FACTIONS SELECTED, REARRANGE OR CONTINUE";
	elseif playerSelected then
		form.phaseLabel.Text = "SELECT CPU " .. (firstHole - 1) .. " FACTION";
	else
		form.phaseLabel.Text = "SELECT PLAYER FACTION";
	end

	form.okButton.Visible = validParticipants >= 5 and playerSelected;
end
-----------------------------------------------------------------------
--	Load event. Put all UI element initialiations here.
-----------------------------------------------------------------------
function NewGameForm:Load(document, activity)
	local ui = {};

	local resolution = Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight);
	local center = Vector(SceneMan.Scene.Width / 4, SceneMan.Scene.Height / 2);

	self.addSoundContainer = CreateSoundContainer("Confirm");
	self.removeSoundContainer = CreateSoundContainer("Error");

	self.playableFactions = {};
	self.factionsStatic = {};

	for i = 1, #CF.Factions do
		local faction = CF.Factions[i];	

		if CF.FactionStaticInvolvement[faction] then
			table.insert(self.factionsStatic, faction);
		elseif CF.FactionPlayable[faction] then
			table.insert(self.playableFactions, faction);
		end
	end

	self.playableFactionCount = #self.playableFactions;
	self.selectedParticipants = {};

	for i = 1, self.playableFactionCount do
		self.selectedParticipants[i] = 0;
	end
	
	self.factionButtons = {};
	self.participantSlots = {};
	self.participantLabels = {};
	
	local factionTileWidth = 60;
	local factionTileHeight = 70;
	local participantsTileHeight = 83;
	local columns = math.floor(FrameMan.PlayerScreenWidth / (factionTileWidth + 1));
	local rows = math.ceil(self.playableFactionCount / columns);
	local columnsInLastRow = self.playableFactionCount % columns;
	local xTile = 0;
	local yTile = 0;
	local maxDescriptionLines = 0;

	for i = 1, self.playableFactionCount do
		local faction = self.playableFactions[i];
		local columnsThisRow = columns;

		if i > self.playableFactionCount - columnsInLastRow then
			columnsThisRow = columnsInLastRow;
		end

		local factionSlotOffset = center + Vector(
			xTile * (factionTileWidth) + (factionTileWidth / 2) - columnsThisRow * (factionTileWidth / 2), 
			-40 - (factionTileHeight / 2) - yTile * (factionTileHeight)
		);

		local participantSlotOffset = center + Vector(
			xTile * (factionTileWidth) + (factionTileWidth / 2) - columnsThisRow * (factionTileWidth / 2), 
			40 + (participantsTileHeight / 2) + yTile * (participantsTileHeight)
		);

		local textContent = CF.FactionDescriptions[faction];
		maxDescriptionLines = math.max(maxDescriptionLines, CF.GetStringPixelWidth(textContent) / 400);

		local actor = CF.SpawnRandomInfantry(-1, factionSlotOffset, faction, Actor.AIMODE_SENTRY);

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

			if (actor.Height > factionTileHeight) then
				actor.Scale = factionTileHeight / actor.Height;
			end
		end

		local factionButton = {
			Type = CF.ElementTypes.BUTTON,
			Pos = factionSlotOffset,
			Text = "",
			Width = factionTileWidth,
			Height = factionTileHeight,
			Backdrop = false,
			Palettes = CF.MenuNormalPalette,
			OnClick = factionButtonOnClick,
			Metadata = {
				index = i,
				factionId = faction,
				factionName = CF.FactionNames[faction],
				description = CF.SplitStringToFitWidth(textContent, 400, false),
				actor = actor,
			},
		};

		table.insert(self.factionButtons, factionButton);
		table.insert(ui, factionButton);

		local participantSlot = {
			Type = CF.ElementTypes.LABEL,
			Pos = participantSlotOffset + Vector(0, 7),
			Text = "",
			Width = factionTileWidth,
			Height = factionTileHeight,
			Backdrop = false,
			Metadata = {
				actor = nil,
			},
		};

		table.insert(self.participantSlots, participantSlot);
		table.insert(ui, participantSlot);

		local participantLabel = {
			Type = CF.ElementTypes.LABEL,
			Pos = participantSlotOffset + Vector(0, -34),
			Text = i == 1 and "PLAYER" or ("FACTION " .. i),
			Centered = true,
			Width = factionTileWidth,
			Height = 14,
			Backdrop = true,
			Palettes = i == 1 and CF.MenuSelectPalette or CF.MenuNormalPalette,
			State = i == 1 and CF.ElementStates.IDLE or CF.ElementStates.MOUSE_OVER,
		};
		
		table.insert(self.participantLabels, participantLabel);
		table.insert(ui, participantLabel);

		xTile = xTile + 1;

		if (xTile >= columns) then
			xTile = 0;
			yTile = yTile + 1;
		end
	end

	local maxDescriptionHeight = math.ceil(maxDescriptionLines) * 11;
	vertOffset = Vector(0, 0);

	local okButton = {
		Type = CF.ElementTypes.BUTTON,
		Pos = center + vertOffset,
		Text = "OK",
		Width = 140,
		Height = 40,
		Visible = false,
		OnClick = okButtonOnClick,
	};

	table.insert(ui, okButton);
	self.okButton = okButton;

	vertOffset.Y = -(40 + rows * factionTileHeight + 22);

	local phaseLabel = {
		Type = CF.ElementTypes.LABEL,
		Preset = nil,
		Pos = center + vertOffset,
		Text = "SELECT STARTING FACTION",
		Centered = true,
		Width = 800,
		Height = 11,
	};
	
	table.insert(ui, phaseLabel);
	self.phaseLabel = phaseLabel;

	vertOffset.Y = vertOffset.Y - (maxDescriptionHeight / 2 + 22);

	local factionDescriptionLabel = {
		Type = CF.ElementTypes.LABEL,
		Preset = nil,
		Pos = center + vertOffset,
		Text = "",
		Centered = true,
		Width = 400,
		Height = 100,
	};

	table.insert(ui, factionDescriptionLabel);
	self.factionDescriptionLabel = factionDescriptionLabel;

	vertOffset.Y = vertOffset.Y - (maxDescriptionHeight / 2 + 22);

	local factionNameLabel = {
		Type = CF.ElementTypes.LABEL,
		Preset = nil,
		Pos = center + vertOffset,
		Text = "",
		Centered = true,
		Width = 400,
		Height = 100,
	};

	table.insert(ui, factionNameLabel);
	self.factionNameLabel = factionNameLabel;

	vertOffset.Y = vertOffset.Y - 22;

	local headerLabel = {
		Type = CF.ElementTypes.LABEL,
		Preset = nil,
		Pos = center + vertOffset,
		Text = "START NEW GAME",
		Centered = true,
		Width = 800,
		Height = 11,
	};

	table.insert(ui, headerLabel);
	self.headerLabel = headerLabel;

	vertOffset.X = resolution.X / 2 - 70 - 20;

	local backButton = {
		Type = CF.ElementTypes.BUTTON,
		Pos = center + vertOffset,
		Text = "Back",
		Width = 140,
		Height = 40,
		Visible = true,
		OnClick = backButtonOnClick,
	};

	table.insert(ui, backButton);
	self.backButton = backButton;

	vertOffset.Y = vertOffset.Y - 40 + resolution.Y / 2;

	document.scrollingScreen = { X = false, Y = true };
	document.bound.Corner = center + Vector(0, vertOffset.Y);
	document.bound.Height = 40 + rows * participantsTileHeight + 20 - resolution.Y / 2 - vertOffset.Y;
	document.bound.Width = 0;

	return ui;
end
-----------------------------------------------------------------------
-- When a click occurs anywhere without catching in an element
-----------------------------------------------------------------------
function NewGameForm:Click()
	--print("Default form click handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function NewGameForm:Update(document, activity)
	local hoverIndex = document.hoverOverIndex;
	
	self.factionDescriptionLabel.Text = "";
	self.factionNameLabel.Text = "";

	if hoverIndex ~= 0 then
		local button = document.ui[hoverIndex];
		
		if not button or button.Type ~= CF.ElementTypes.BUTTON then
			return;
		end

		local meta = button.Metadata;

		if not meta or not meta.description or not meta.factionName then
			return;
		end

		self.factionDescriptionLabel.Text = meta.description;
		self.factionNameLabel.Text = string.upper(meta.factionName);
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function NewGameForm:Draw()
	--print("Default form draw handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function NewGameForm:Close()
	for _, set in pairs{MovableMan.Actors, MovableMan.AddedActors} do
		for actor in set do
			actor.ToDelete = true;
		end
	end
	for _, set in pairs{MovableMan.Particles, MovableMan.AddedParticles} do
		for particle in set do
			particle.ToDelete = true;
		end
	end
	for _, set in pairs{MovableMan.Items, MovableMan.AddedItems} do
		for item in set do
			item.ToDelete = true;
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
return NewGameForm;