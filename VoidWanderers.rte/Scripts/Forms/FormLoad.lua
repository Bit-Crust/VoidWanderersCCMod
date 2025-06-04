local LoadForm = {};
-----------------------------------------------------------------------
--	
-----------------------------------------------------------------------
local function saveSlotOnClick(element, form, activity)
	local gameState = element.Metadata.gameState;

	if gameState and not element.Metadata.isBroken then
		CF.UpdateGameState(gameState);

		activity.GS = gameState;
		activity.sceneToLaunch = activity.GS["Scene"];
		activity.scriptToLaunch = "Tactics.lua";
	end
end
-----------------------------------------------------------------------
--	
-----------------------------------------------------------------------
local function backButtonOnClick(element, form, activity)
	activity.formToLoad = "FormStart.lua";
end
-----------------------------------------------------------------------
--	Load event. Put all UI element initialiations here.
-----------------------------------------------------------------------
function LoadForm:Load(document, activity)
	local ui = {};
	
	local resolution = Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight);
	local center = Vector(SceneMan.Scene.Width / 4, SceneMan.Scene.Height / 2);

	local saveSlotWidth = 180;
	local saveSlotHeight = 70;
	local columns = math.min(4, CF.MaxSaveGames);
	local rows = math.ceil(CF.MaxSaveGames / columns);
	local columnsInLastRow = CF.MaxSaveGames % columns;
	local xTile = 1;
	local yTile = 1;

	for i = 1, CF.MaxSaveGames do
		local text = "EMPTY";
		local gameState = CF.ReadDataFile("Mods/VoidWanderers.rte/CampaignData/savegame" .. i .. ".dat");
		local isBroken = false;
		local reason = "";

		if gameState then
			if not gameState["PlayerGold"] then
				isBroken = true;
			end

			-- Check that all used factions are installed
			for j = 1, CF.MaxCPUPlayers do
				if gameState["Participant" .. j .. "Active"] == "True" then
					local f = gameState["Participant" .. j .. "Faction"];

					if f == nil then
						isBroken = true;
						break;
					else
						if CF.FactionNames[f] == nil then
							isBroken = true;
							reason = "NO " .. f;
						elseif CF.FactionPlayable[f] == false then
							isBroken = true;
							reason = f .. " NOT PLAYABLE";
						end
					end
				end
			end

			if not isBroken then
				text = CF.FactionNames[gameState["PlayerFaction"]];
			else
				text = "Broken slot #" .. i .. "";
			end
			
			text = text .. "\n" .. reason;
			text = text .. "\n" .. CF.PlanetName[gameState["Planet"] or ""] or "N/A";
			text = text .. "\n" .. CF.ConvertTimeToString(tonumber(gameState.Time) or 0);
			text = text .. "\n" .. "\198 " .. (gameState["PlayerGold"] or "NaN") .. " oz";
		end

		local columnsThisRow = columns;

		if i > CF.MaxSaveGames - columnsInLastRow then
			columnsThisRow = columnsInLastRow;
		end

		local offset = Vector(
			xTile * (saveSlotWidth - 2) - (saveSlotWidth / 2 - 1) - columnsThisRow * (saveSlotWidth / 2 - 1), 
			yTile * (saveSlotHeight - 2) - (saveSlotHeight / 2 - 1) - rows * (saveSlotHeight / 2 - 1)
		);

		table.insert(ui, {
			Type = CF.ElementTypes.BUTTON,
			Pos = document.mid + offset,
			Text = text,
			Width = saveSlotWidth - 4,
			Height = saveSlotHeight - 4,
			Backdrop = true,
			OnClick = saveSlotOnClick,
			Metadata = {
				gameState = gameState,
				isBroken = isBroken,
			},
		});

		xTile = xTile + 1;

		if xTile > columns then
			xTile = 1;
			yTile = yTile + 1;
		end
	end
	
	table.insert(ui, {
		Type = CF.ElementTypes.LABEL,
		Pos = document.mid + Vector(0, -resolution.Y / 2 + 33),
		Centered = 1,
		Text = "LOAD GAME",
		Width = 800,
		Height = 100,
	});
	
	table.insert(ui, {
		Type = CF.ElementTypes.BUTTON,
		Pos = document.mid + Vector(resolution.X / 2 - 70 - 20, -resolution.Y / 2 + 12 + 20),
		Text = "Back",
		Width = 140,
		Height = 40,
		OnClick = backButtonOnClick,
	});
	
	document.scrollingScreen = { X = false, Y = false };
	document.bound.Corner = center * 1;
	document.bound.Height = 0;
	document.bound.Width = 0;

	return ui;
end
-----------------------------------------------------------------------
-- When a click occurs anywhere without catching in an element
-----------------------------------------------------------------------
function LoadForm:Click()
	--print("Default form click handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function LoadForm:Update()
	--print("Default form update handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function LoadForm:Draw()
	--print("Default form draw handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function LoadForm:Close()
	--print("Default form close handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
return LoadForm;