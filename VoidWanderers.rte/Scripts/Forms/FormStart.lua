local StartForm = {};
-----------------------------------------------------------------------
--	
-----------------------------------------------------------------------
local function continueButtonOnClick(element, form, activity)
	activity.GS = activity:loadCurrentGameState();
	activity.sceneToLaunch = activity.GS["Scene"];
	activity.scriptToLaunch = "Tactics.lua";
end
-----------------------------------------------------------------------
--	
-----------------------------------------------------------------------
local function newGameButtonOnClick(element, form, activity)
	activity.formToLoad = "FormNewGame.lua";
end
-----------------------------------------------------------------------
--	
-----------------------------------------------------------------------
local function loadGameButtonOnClick(element, form, activity)
	activity.formToLoad = "FormLoad.lua";
end
-----------------------------------------------------------------------
--	Load event. Put all UI element initializations here.
-----------------------------------------------------------------------
function StartForm:Load(document, activity)
	local ui = {};

	local resolution = Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight);
	local center = Vector(SceneMan.Scene.Width / 4, SceneMan.Scene.Height / 2);
	
	table.insert(ui, {
		Type = CF.ElementTypes.BUTTON,
		Pos = center + Vector(0, -40),
		Text = "Continue game",
		Width = 140,
		Height = 40,
		OnClick = continueButtonOnClick,
	});

	table.insert(ui, {
		Type = CF.ElementTypes.BUTTON,
		Pos = center + Vector(0, -0),
		Text = "New game",
		Width = 140,
		Height = 40,
		OnClick = newGameButtonOnClick,
	});

	table.insert(ui, {
		Type = CF.ElementTypes.BUTTON,
		Pos = center + Vector(0, 40),
		Text = "Load game",
		Width = 140,
		Height = 40,
		OnClick = loadGameButtonOnClick,
	});
	
	document.scrollingScreen = { X = false, Y = false };
	document.bound.Corner = center * 1;
	document.bound.Height = 0;
	document.bound.Width = 0;
	MusicMan:PlayDynamicSong("Main Menu Music DynamicSong", "Default", false, true, true);

	return ui;
end
-----------------------------------------------------------------------
-- When a click occurs anywhere without catching in an element
-----------------------------------------------------------------------
function StartForm:Click()
	--print("Default form click handling.");
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
	--print("Default form close handling.");
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
return StartForm;