-----------------------------------------------------------------------------------------
--	Load event. Put all UI element initialiations here.
-----------------------------------------------------------------------------------------
function VoidWanderers:FormLoad()
	-- Create UI elements
	-- Clear old elements
	local el
	self.UI = {}

	if CF.IsFileExists(self.ModuleName, STATE_CONFIG_FILE) then
		el = {}
		el["Type"] = self.ElementTypes.BUTTON
		el["Presets"] = {}
		el["Presets"][self.ButtonStates.IDLE] = "SideMenuButtonIdle"
		el["Presets"][self.ButtonStates.MOUSE_OVER] = "SideMenuButtonMouseOver"
		el["Presets"][self.ButtonStates.PRESSED] = "SideMenuButtonPressed"
		el["Pos"] = self.Mid + Vector(0,-60)
		el["Text"] = "Continue game"
		el["Width"] = 140
		el["Height"] = 40
		
		el["OnClick"] = self.BtnContinueGame_OnClick
		
		self.UI[#self.UI + 1] = el
	end

	el = {}
	el["Type"] = self.ElementTypes.BUTTON
	el["Presets"] = {}
	el["Presets"][self.ButtonStates.IDLE] = "SideMenuButtonIdle"
	el["Presets"][self.ButtonStates.MOUSE_OVER] = "SideMenuButtonMouseOver"
	el["Presets"][self.ButtonStates.PRESSED] = "SideMenuButtonPressed"
	el["Pos"] = self.Mid + Vector(0, -20)
	el["Text"] = "New game"
	el["Width"] = 140
	el["Height"] = 40

	el["OnClick"] = self.BtnNewGame_OnClick

	self.UI[#self.UI + 1] = el

	el = {}
	el["Type"] = self.ElementTypes.BUTTON
	el["Presets"] = {}
	el["Presets"][self.ButtonStates.IDLE] = "SideMenuButtonIdle"
	el["Presets"][self.ButtonStates.MOUSE_OVER] = "SideMenuButtonMouseOver"
	el["Presets"][self.ButtonStates.PRESSED] = "SideMenuButtonPressed"
	el["Pos"] = self.Mid + Vector(0, 20)
	el["Text"] = "Load game"
	el["Width"] = 140
	el["Height"] = 40

	el["OnClick"] = self.BtnLoadGame_OnClick

	self.UI[#self.UI + 1] = el
	
	AudioMan:ClearMusicQueue()
	AudioMan:PlayMusic("Base.rte/Music/Hubnester/ccmenu.ogg", -1, -1)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:BtnContinueGame_OnClick()
	self:FormClose()
	self:LoadCurrentGameState()
	self:LaunchScript(self.GS["Scene"], "Tactics.lua")
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:BtnNewGame_OnClick()
	self:FormClose()
	dofile(BASE_PATH .. "FormNewGame.lua")
	self:FormLoad()
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:BtnLoadGame_OnClick()
	self:FormClose()
	dofile(BASE_PATH .. "FormLoad.lua")
	self:FormLoad()
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormClick()
	local el = self.MousePressedElement

	if el then
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormUpdate() end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormDraw() end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------

function VoidWanderers:FormClose() end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
