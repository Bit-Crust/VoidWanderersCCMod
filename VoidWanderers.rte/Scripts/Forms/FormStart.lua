local StartForm = {};
-----------------------------------------------------------------------
--	Load event. Put all UI element initializations here.
-----------------------------------------------------------------------
function StartForm:Load(document, activity)
	local ui = {};
	
	table.insert(ui, {
		Type = CF.ElementTypes.BUTTON,
		Pos = document.mid + Vector(0, -40),
		Text = "Continue game",
		Width = 140,
		Height = 40,
		OnClick = function(element, activity)
			activity:loadCurrentGameState();
			activity.sceneToLaunch = activity.GS["Scene"];
			activity.scriptToLaunch = "Tactics.lua";
		end,
	});

	table.insert(ui, {
		Type = CF.ElementTypes.BUTTON,
		Pos = document.mid + Vector(0, -0),
		Text = "New game",
		Width = 140,
		Height = 40,
		OnClick = function(element, activity)
			activity.formToLoad = "FormNewGame.lua";
		end,
	});

	table.insert(ui, {
		Type = CF.ElementTypes.BUTTON,
		Pos = document.mid + Vector(0, 40),
		Text = "Load game",
		Width = 140,
		Height = 40,
		OnClick = function(element, activity)
			activity.formToLoad = "FormLoad.lua";
		end,
	});
	
	MusicMan:PlayDynamicSong("Main Menu Music DynamicSong", "Default", false, true, true);

	return ui;
end
-----------------------------------------------------------------------
-- When a click occurs anywhere without catching in an element
-----------------------------------------------------------------------
function StartForm:Click()
	print("Default form click handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function StartForm:Update()
	--print("Default form update handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function StartForm:Draw()
	--print("Default form draw handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function StartForm:Close()
	print("Default form close handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
return StartForm;