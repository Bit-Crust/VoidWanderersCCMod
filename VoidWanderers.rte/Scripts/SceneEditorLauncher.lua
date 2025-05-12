-----------------------------------------------------------------------
-- Checks whether the mission can be started from a given scene.
-----------------------------------------------------------------------
function VoidWanderers:IsCompatibleScene(scene)
	return (scene.ClassName == "Scene" and scene.PresetName == "Void Wanderers" and scene.ModuleName == "VoidWanderers.rte");
end
-----------------------------------------------------------------------
function VoidWanderers:StartActivity()
	print("VoidWanderersSceneEditor:StartActivity");

	self.IsInitialized = false;

	stateConfigFileName = "current.dat";
	libPath = self.ModuleName .. "/Scripts/";
	basePath = self.ModuleName .. "/Scripts/";

	dofile(libPath .. "Lib_Generic.lua");
	dofile(libPath .. "Lib_Config.lua");
	dofile(libPath .. "Lib_Spawn.lua");
	dofile(libPath .. "Lib_Storage.lua");

	FORM_TO_LOAD = basePath .. "FormSceneSelect.lua";

	dofile(basePath .. "StrategyScreenMain.lua");
	self:StartSceneProcess(true);
end
-----------------------------------------------------------------------
-- Pause Activity
-----------------------------------------------------------------------
function VoidWanderers:PauseActivity(pause)
	print("PAUSE! -- VoidWanderersSceneEditor:PauseActivity()!");
end
-----------------------------------------------------------------------
-- End Activity
-----------------------------------------------------------------------
function VoidWanderers:EndActivity()
	print("END! -- VoidWanderersSceneEditor:EndActivity()!");
end
-----------------------------------------------------------------------
-- Update Activity
-----------------------------------------------------------------------
function VoidWanderers:UpdateActivity()
	--self:UpdateSceneProcess();
end
-----------------------------------------------------------------------
-- Launches new mission script without leaving current activity. Scene is case sensitive!
-----------------------------------------------------------------------
function VoidWanderers:launchScript(scene, script)
	print("VoidWanderers-launchScript: " .. scene .. " / " .. script);

	self.IsInitialized = false;

	MovableMan:PurgeAllMOs();
	
	dofile(basePath .. script);
	SceneMan:LoadScene(scene, true);
end
