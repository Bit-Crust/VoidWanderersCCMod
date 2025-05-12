local SaveForm = {};
-----------------------------------------------------------------------
--	Load event. Put all UI element initializations here.
-----------------------------------------------------------------------
function SaveForm:Load(document, activity)
	local ui = {};

	local saveSlotWidth = 180;
	local saveSlotHeight = 70;
	local columns = math.min(4, CF.MaxSaveGames);
	local rows = math.floor(CF.MaxSaveGames / columns);
	local columnsInLastRow = CF.MaxSaveGames % columns;
	local xtile = 1;
	local ytile = 1;
	local resolution = Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight);

	for i = 1, CF.MaxSaveGames do
		local text = "EMPTY";
		
		if CF.IsFileExists(activity.ModuleName, "savegame" .. i .. ".dat") then
			local gameState = CF.ReadDataFile("Mods/VoidWanderers.rte/CampaignData/savegame" .. i .. ".dat");
			local isbroken = false;
			local reason = "";

			if not gameState["PlayerGold"] then
				isbroken = true;
			end

			-- Check that all used factions are installed
			for j = 1, CF.MaxCPUPlayers do
				if gameState["Player" .. j .. "Active"] == "True" then
					local f = gameState["Player" .. j .. "Faction"];

					if f == nil then
						isbroken = true;
						break;
					else
						if CF.FactionNames[f] == nil then
							isbroken = true;
							reason = "NO " .. f;
						elseif CF.FactionPlayable[f] == false then
							isbroken = true;
							reason = f .. " NOT PLAYABLE";
						end
					end
				end
			end

			if not isbroken then
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

		local slotId = #ui + 1;

		table.insert(ui, {
			Type = CF.ElementTypes.BUTTON,
			Pos = document.mid + Vector(
				xtile * 178 - 89 - columnsThisRow * 89,
				ytile * 68 - 34 - rows * 34
			),
			Text = text,
			Width = saveSlotWidth - 4,
			Height = saveSlotHeight - 4,
			OnClick = function(element, activity)
				CF.WriteDataFile(activity.GS, "Mods/" .. activity.ModuleName .. "/CampaignData/" .. "savegame" .. slotId .. ".dat");

				activity:loadCurrentGameState();
				activity.sceneToLaunch = activity.GS["Scene"];
				activity.scriptToLaunch = "Tactics.lua";
			end,
		});

		xtile = xtile + 1;

		if xtile > columns then
			xtile = 1;
			ytile = ytile + 1;
		end
	end
	
	table.insert(ui, {
		Type = CF.ElementTypes.LABEL,
		Pos = document.mid + Vector(0, -resolution.Y / 2 + 33),
		Text = "SAVE GAME",
		Centered = 1,
		Width = 800,
		Height = 100,
	});
	
	table.insert(ui, {
		Type = CF.ElementTypes.BUTTON,
		Pos = document.mid + Vector(resolution.X / 2 - 70 - 20, -resolution.Y / 2 + 12 + 20),
		Text = "Back",
		Width = 140,
		Height = 40,
		OnClick = function(element, activity)
			activity:loadCurrentGameState();
			activity.sceneToLaunch = activity.GS["Scene"];
			activity.scriptToLaunch = "Tactics.lua";
		end,
	});
	
	MusicMan:PlayDynamicSong("Main Menu Music DynamicSong", "Default", false, true, true);
	
	return ui;
end
-----------------------------------------------------------------------
-- When a click occurs anywhere without catching in an element
-----------------------------------------------------------------------
function SaveForm:Click()
	print("Default form click handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function SaveForm:Update()
	--print("Default form update handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function SaveForm:Draw()
	--print("Default form draw handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function SaveForm:Close()
	print("Default form close handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
return SaveForm;