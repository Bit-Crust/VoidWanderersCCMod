-----------------------------------------------------------------------
--	Load event. Put all UI element initialiations here.
-----------------------------------------------------------------------
function VoidWanderers:FormLoad()
	-- Create UI elements
	-- Clear old elements
	local el
	self.UI = {}

	local sx = 140
	local sy = 40
	local wx = 5
	local x = 1
	local y = 1

	local pos = Vector(
		(SceneMan.Scene.Width - sx) / 2,
		((SceneMan.Scene.Height + sy) / 4) / math.max(#CF.Location / (wx * sy), 1)
	)

	-- Create scene buttons
	for i = 1, #CF.Location do
		local playable = true

		if CF.LocationPlayable[CF.Location[i]] ~= nil and CF.LocationPlayable[CF.Location[i]] == false then
			playable = false
		end

		if playable then
			for j = 1, #CF.LocationScenes[CF.Location[i]] do
				el = {}
				el["Type"] = CF.ElementTypes.BUTTON
				el["Presets"] = {}
				el["Presets"][CF.ElementStates.IDLE] = "ButtonIdle"
				el["Presets"][CF.ElementStates.MOUSE_OVER] = "ButtonMouseOver"
				el["Presets"][CF.ElementStates.PRESSED] = "ButtonPressed"
				el["Pos"] = pos + Vector(-(wx * sx / 2) + x * sx, y * sy)
				el["Text"] = CF.LocationScenes[CF.Location[i]][j]
				el["LocationID"] = CF.LocationScenes[CF.Location[i]][j]
				el["Width"] = sx
				el["Height"] = sy

				x = x + 1
				if x > wx then
					x = 1
					y = y + 1
				end

				--el["OnHover"] = self.SaveSlots_OnHover
				el["OnClick"] = self.SceneButton_OnClick

				self.UI[#self.UI + 1] = el
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:FormClick()
	local el = self.MousePressedElement

	if el then
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:SceneButton_OnClick()
	local el = self.MousePressedElement

	self:FormClose()
	SceneMan:LoadScene(self.UI[el]["Text"], true)

	--[[for actor in MovableMan.AddedActors do
		--print (actor.PresetName)
		if actor.ClassName == "AHuman" or actor.ClassName == "ACrab" or actor.PresetName == "Brain Case" then
			actor.ToDelete = true
		end
	end--]]
	--

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		self:SetPlayerBrain(nil, player)
	end

	self.SelectedLocationID = self.UI[el]["LocationID"]
	dofile(BASE_PATH .. "FormSceneEditor.lua")
	self:FormLoad()
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:FormUpdate() end
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
