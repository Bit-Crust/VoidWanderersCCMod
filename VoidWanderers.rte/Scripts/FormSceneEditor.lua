-----------------------------------------------------------------------------------------
--	Load event. Put all UI element initialiations here.
-----------------------------------------------------------------------------------------
function VoidWanderers:FormLoad()
	--CF["StopUIProcessing"] = true

	print("Form load")

	G_CursorActor = CreateActor("VW_Cursor")
	if G_CursorActor then
		G_CursorActor.Team = CF.PlayerTeam
		local curactor = self:GetControlledActor(CF.PlayerTeam)

		if curactor and MovableMan:IsActor(curactor) then
			G_CursorActor.Pos = curactor.Pos
		else
			local curactor = self:GetPlayerBrain(0)
			if MovableMan:IsActor(curactor) then
				G_CursorActor.Pos = curactor.Pos
			else
				G_CursorActor.Pos = Vector(0, 0)
			end
		end

		MovableMan:AddActor(G_CursorActor)
		ActivityMan:GetActivity():SwitchToActor(G_CursorActor, 0, 0)
	end

	self:CreateActors()

	self.Pts = {}

	local el
	self.UI = {}

	local sx = 160
	local sy = 20
	local x = 0
	local y = 1

	local pos = Vector(SceneMan.Scene.Width / 2, 0)

	self.FixedPos = Vector(0, 0)

	self.Mouse = pos

	-- Data array will be indexed Data[mission][]
	self.Data = {}

	-- Create list of data objcets
	-- Add generic mission types which must be present on any map
	--self.Data[1] = {}
	--self.Data[1]["Name"] = "Deploy"

	--self.Data[2] = {}
	--self.Data[2]["Name"] = "Enemy"

	for i = 1, CF["GenericMissionCount"] do
		self.Data[i] = {}
		self.Data[i]["Name"] = CF["Mission"][i]
	end

	print(self.SelectedLocationID)

	for i = 1, #CF["LocationMissions"][self.SelectedLocationID] do
		self.Data[CF["GenericMissionCount"] + i] = {}
		self.Data[CF["GenericMissionCount"] + i]["Name"] = CF["LocationMissions"][self.SelectedLocationID][i]
	end

	el = {}
	el["Type"] = self.ElementTypes.BUTTON
	el["Presets"] = {}
	el["Presets"][self.ButtonStates.IDLE] = "ButtonSceneEditorWideIdle"
	el["Presets"][self.ButtonStates.MOUSE_OVER] = "ButtonSceneEditorWideMouseOver"
	el["Presets"][self.ButtonStates.PRESSED] = "ButtonSceneEditorWidePressed"
	el["RelPos"] = Vector(-self.ResX2 + 20 + sx / 2, -self.ResY2 + 20)
	el["Text"] = "SAVE"
	el["Width"] = sx
	el["Height"] = sy
	el["Visible"] = false

	el["OnClick"] = self.Save_OnClick

	self.UI[#self.UI + 1] = el

	el = {}
	el["Type"] = self.ElementTypes.BUTTON
	el["Presets"] = {}
	el["Presets"][self.ButtonStates.IDLE] = "ButtonSceneEditorWideIdle"
	el["Presets"][self.ButtonStates.MOUSE_OVER] = "ButtonSceneEditorWideMouseOver"
	el["Presets"][self.ButtonStates.PRESSED] = "ButtonSceneEditorWidePressed"
	el["RelPos"] = Vector(-self.ResX2 + 20 + sx / 2 + 161, -self.ResY2 + 20)
	el["Text"] = "Show Generic"
	el["Width"] = sx
	el["Height"] = sy
	el["Visible"] = false

	el["OnClick"] = self.AlwaysShowGenericMarks_OnClick

	self.UI[#self.UI + 1] = el

	el = {}
	el["Type"] = self.ElementTypes.BUTTON
	el["Presets"] = {}
	el["Presets"][self.ButtonStates.IDLE] = "ButtonSceneEditorWideIdle"
	el["Presets"][self.ButtonStates.MOUSE_OVER] = "ButtonSceneEditorWideMouseOver"
	el["Presets"][self.ButtonStates.PRESSED] = "ButtonSceneEditorWidePressed"
	el["RelPos"] = Vector(-self.ResX2 + 20 + sx / 2 + 321, -self.ResY2 + 20)
	el["Text"] = "Snap to grid 12px"
	el["Width"] = sx
	el["Height"] = sy
	el["Visible"] = false

	el["OnClick"] = self.SnapToGrid_OnClick

	self.UI[#self.UI + 1] = el

	self.ShowGeneric = true
	self.SnapToGrid = true
	self.GridSize = 12

	-- Create scene buttons
	for i = 1, #self.Data do
		el = {}
		el["Type"] = self.ElementTypes.BUTTON
		el["Presets"] = {}
		el["Presets"][self.ButtonStates.IDLE] = "ButtonSceneEditorWideIdle"
		el["Presets"][self.ButtonStates.MOUSE_OVER] = "ButtonSceneEditorWideMouseOver"
		el["Presets"][self.ButtonStates.PRESSED] = "ButtonSceneEditorWidePressed"
		el["RelPos"] = Vector(-self.ResX2 + 20 + sx / 2 + x * sx, -self.ResY2 + 20 + y * sy)
		el["Text"] = self.Data[i]["Name"]
		el["Data"] = self.Data[i]["Name"]
		el["Width"] = sx
		el["Height"] = sy
		el["Visible"] = false

		y = y + 1

		el["OnClick"] = self.MissionType_OnClick

		self.UI[#self.UI + 1] = el
	end

	self.LastTypeElement = #self.UI

	-- Load level data
	self.SceneConfig = CF["ReadSceneConfigFile"](self.ModuleName, SceneMan.Scene.PresetName .. ".dat")

	for k1 = 1, #self.Data do
		local msntype = self.Data[k1]["Name"]

		for k2 = 1, CF["MissionMaxSets"][msntype] do
			for k3 = 1, #CF["MissionRequiredData"][msntype] do
				local pttype = CF["MissionRequiredData"][msntype][k3]["Name"]

				for k4 = 1, CF["MissionRequiredData"][msntype][k3]["Max"] do
					local id = msntype .. tostring(k2) .. pttype .. tostring(k4)

					local x = self.SceneConfig[id .. "X"]
					local y = self.SceneConfig[id .. "Y"]

					if x ~= nil and y ~= nil then
						if self.Pts[msntype] == nil then
							self.Pts[msntype] = {}
						end
						if self.Pts[msntype][k2] == nil then
							self.Pts[msntype][k2] = {}
						end
						if self.Pts[msntype][k2][k3] == nil then
							self.Pts[msntype][k2][k3] = {}
						end
						if self.Pts[msntype][k2][k3][k4] == nil then
							self.Pts[msntype][k2][k3][k4] = {}
						end

						self.Pts[msntype][k2][k3][k4] = Vector(tonumber(x), tonumber(y))
					end
				end
			end
		end
	end --]]--

	--[[for k,v in pairs(self.Pts) do
		print (k)
		
		for k2,v2 in pairs(v) do
			print (k2)
			
			for k3,v3 in pairs(v2) do
				print (k3)
				
				for k4,v4 in pairs(v3) do
					print (k4)
					print (v4)
				end
			end
		end
	end	]]
	--
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ShowElements()
	local pos = self.FixedPos

	for i = 1, #self.UI do
		self.UI[i]["Visible"] = true
		self.UI[i]["Pos"] = pos + self.UI[i]["RelPos"]
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:HideElements()
	for i = 1, #self.UI do
		self.UI[i]["Visible"] = false
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:AlwaysShowGenericMarks_OnClick()
	self.ShowGeneric = not self.ShowGeneric
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:SnapToGrid_OnClick()
	self.SnapToGrid = not self.SnapToGrid
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:Save_OnClick()
	for k, v in pairs(self.Pts) do -- Mission type
		--print (k)
		local msntype = k

		for k2, v2 in pairs(v) do -- Set number
			--print (k2)

			local setnum = tostring(k2)

			for k3, v3 in pairs(v2) do -- Point type
				--print (k3)

				local pnttype = CF["MissionRequiredData"][k][k3]["Name"]
				-- Clear data
				for i = 1, CF["MissionRequiredData"][k][k3]["Max"] do
					self.SceneConfig[msntype .. setnum .. pnttype .. tostring(i) .. "X"] = nil
					self.SceneConfig[msntype .. setnum .. pnttype .. tostring(i) .. "Y"] = nil
				end

				-- Save data
				for k4, v4 in pairs(v3) do -- Point vector
					--print (k4)
					--print (v4)
					self.SceneConfig[msntype .. setnum .. pnttype .. tostring(k4) .. "X"] = v4.X
					self.SceneConfig[msntype .. setnum .. pnttype .. tostring(k4) .. "Y"] = v4.Y
				end
			end
		end
	end

	CF["WriteSceneConfigFile"](self.SceneConfig, CF["ModuleName"], SceneMan.Scene.PresetName .. ".dat")
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:MissionType_OnClick()
	local newui = {}

	-- Delete all unneded elements
	for i = 1, self.LastTypeElement do
		newui[i] = self.UI[i]
	end

	self.UI = newui

	self.SelectedType = self.UI[self.MousePressedElement]["Data"]

	-- Create sub-elements
	local sx = 90
	local sy = 20
	local x = 0
	local y = 1

	local pos = Vector(SceneMan.Scene.Width / 2, 0)

	-- Fill sets
	for i = 1, CF["MissionMaxSets"][self.SelectedType] do
		el = {}
		el["Type"] = self.ElementTypes.BUTTON
		el["Presets"] = {}
		el["Presets"][self.ButtonStates.IDLE] = "ButtonSceneEditorIdle"
		el["Presets"][self.ButtonStates.MOUSE_OVER] = "ButtonSceneEditorMouseOver"
		el["Presets"][self.ButtonStates.PRESSED] = "ButtonSceneEditorPressed"
		el["RelPos"] = Vector(-self.ResX2 + 20 + sx / 2 + x * sx + 161, -self.ResY2 + 20 + y * sy)
		el["Text"] = "SET " .. i
		el["Data"] = i
		el["Width"] = sx
		el["Height"] = sy
		el["Visible"] = true

		y = y + 1

		el["OnClick"] = self.Set_OnClick

		self.UI[#self.UI + 1] = el
	end

	local sx = 160
	local sy = 20
	local x = 0
	local y = 1

	-- Fill point types
	for i = 1, #CF["MissionRequiredData"][self.SelectedType] do
		el = {}
		el["Type"] = self.ElementTypes.BUTTON
		el["Presets"] = {}
		el["Presets"][self.ButtonStates.IDLE] = "ButtonSceneEditorWideIdle"
		el["Presets"][self.ButtonStates.MOUSE_OVER] = "ButtonSceneEditorWideMouseOver"
		el["Presets"][self.ButtonStates.PRESSED] = "ButtonSceneEditorWidePressed"
		el["RelPos"] = Vector(-self.ResX2 + 20 + sx / 2 + x * sx + 252, -self.ResY2 + 20 + y * sy)
		el["Text"] = CF["MissionRequiredData"][self.SelectedType][i]["Name"]
		el["Data"] = i
		el["Width"] = sx
		el["Height"] = sy
		el["Visible"] = true

		y = y + 1

		el["OnClick"] = self.PointType_OnClick

		self.UI[#self.UI + 1] = el
	end

	self.LastPointTypeElement = #self.UI

	self.SelectedSet = 1

	self:ShowElements()

	--CF["DisableUIProcessing"] = true
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:Set_OnClick()
	self.SelectedSet = self.UI[self.MousePressedElement]["Data"]
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:PointType_OnClick()
	local newui = {}

	-- Delete all unneded elements
	for i = 1, self.LastPointTypeElement do
		newui[i] = self.UI[i]
	end

	self.UI = newui

	self.SelectedPointType = self.UI[self.MousePressedElement]["Data"]

	-- Create sub-elements
	local sx = 90
	local sy = 20
	local x = 0
	local y = 1

	local pos = Vector(SceneMan.Scene.Width / 2, 0)

	-- Fill sets
	for i = 1, CF["MissionRequiredData"][self.SelectedType][self.SelectedPointType]["Max"] do
		el = {}
		el["Type"] = self.ElementTypes.BUTTON
		el["Presets"] = {}
		el["Presets"][self.ButtonStates.IDLE] = "ButtonSceneEditorIdle"
		el["Presets"][self.ButtonStates.MOUSE_OVER] = "ButtonSceneEditorMouseOver"
		el["Presets"][self.ButtonStates.PRESSED] = "ButtonSceneEditorPressed"
		el["RelPos"] = Vector(-self.ResX2 + 20 + sx / 2 + x * sx + 252 + 161, -self.ResY2 + 20 + y * sy)
		el["Text"] = tostring(i)
		el["Data"] = i
		el["Width"] = sx
		el["Height"] = sy
		el["Visible"] = true

		y = y + 1

		el["OnClick"] = self.Point_OnClick

		self.UI[#self.UI + 1] = el
	end

	self:ShowElements()
	self.SelectedPoint = 1
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:Point_OnClick()
	self.SelectedPoint = self.UI[self.MousePressedElement]["Data"]
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormUpdate()
	--print (UInputMan:MouseWheelMoved())

	if
		self.SelectedType ~= nil
		and self.SelectedSet ~= nil
		and self.SelectedPointType ~= nil
		and self.SelectedPoint ~= nil
	then
		local mx = CF["MissionRequiredData"][self.SelectedType][self.SelectedPointType]["Max"]
		local mv = UInputMan:MouseWheelMoved()

		if mv > 0 then
			self.SelectedPoint = self.SelectedPoint - 1
			if self.SelectedPoint < 1 then
				self.SelectedPoint = mx
			end
		end

		if mv < 0 then
			self.SelectedPoint = self.SelectedPoint + 1
			if self.SelectedPoint > mx then
				self.SelectedPoint = 1
			end
		end
	end

	if UInputMan:KeyPressed(Key.SPACE) then
		self.ButtonPressed = not self.ButtonPressed

		if self.ButtonPressed then
			self.FixedPos = self.Mouse

			if self.Mouse.Y < self.ResY2 then
				self.FixedPos.Y = self.ResY2
			end

			if self.Mouse.Y > SceneMan.Scene.Height - self.ResY2 then
				self.FixedPos.Y = SceneMan.Scene.Height - self.ResY2
			end

			self.Mouse = self.FixedPos
			if MovableMan:IsActor(G_CursorActor) then
				G_CursorActor.Pos = self.Mouse
			end

			self:ShowElements()
		else
			self:HideElements()
		end
	end

	-- Process numeric keys
	for i = 1, 9 do
		if UInputMan:KeyPressed(47 + i) then
			if
				self.SelectedType ~= nil
				and self.SelectedSet ~= nil
				and self.SelectedPointType ~= nil
				and self.SelectedPoint ~= nil
			then
				local mx = CF["MissionRequiredData"][self.SelectedType][self.SelectedPointType]["Max"]

				if i <= mx then
					self.SelectedPoint = i
				end
			end
		end
	end

	if UInputMan:MouseButtonPressed(2) then
		if self.SelectedType ~= nil then
			if self.Pts[self.SelectedType] ~= nil and self.Pts[self.SelectedType][self.SelectedSet] ~= nil then
				-- Enum
				for k3, v3 in pairs(self.Pts[self.SelectedType][self.SelectedSet]) do
					for k4, v4 in pairs(v3) do
						--self:PutGlow("ControlPanel_Ship_LocationDot", v4)
						if CF["DistUnder"](v4, self.Mouse, 5) then
							self.Pts[self.SelectedType][self.SelectedSet][k3][k4] = nil
						end
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormClick()
	if not self.ButtonPressed then
		local el = self.MousePressedElement

		if el then
		end

		if self.SelectedType ~= nil and self.SelectedPointType ~= nil then
			if self.Pts[self.SelectedType] == nil then
				self.Pts[self.SelectedType] = {}
			end
			if self.Pts[self.SelectedType][self.SelectedSet] == nil then
				self.Pts[self.SelectedType][self.SelectedSet] = {}
			end
			if self.Pts[self.SelectedType][self.SelectedSet][self.SelectedPointType] == nil then
				self.Pts[self.SelectedType][self.SelectedSet][self.SelectedPointType] = {}
			end

			local ms

			if self.SnapToGrid and self.SnappedMouse ~= nil then
				ms = self.SnappedMouse
			else
				ms = self.Mouse
			end

			self.Pts[self.SelectedType][self.SelectedSet][self.SelectedPointType][self.SelectedPoint] = Vector(
				math.floor(ms.X),
				math.floor(ms.Y)
			)
		end
	end

	-- Draw points
	--[[for k,v in pairs(self.Pts) do
		print (k)
		
		for k2,v2 in pairs(v) do
			print (k2)
			
			for k3,v3 in pairs(v2) do
				print (k3)
				
				for k4,v4 in pairs(v3) do
					print (k4)
					print (v4)
				end
			end
		end
	end--]]
	--
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormDraw()
	self:ClearObjectivePoints()

	if not self.ButtonPressed then
		local ms

		if self.SnapToGrid and self.SnappedMouse ~= nil then
			ms = self.SnappedMouse
		else
			ms = self.Mouse
		end

		CF.DrawString("" .. math.floor(ms.X) .. "-" .. math.floor(ms.Y), self.Mouse + Vector(-14, 40), 100, 100)
	end

	if self.SelectedType ~= nil then
		if self.Pts[self.SelectedType] ~= nil and self.Pts[self.SelectedType][self.SelectedSet] ~= nil then
			-- Enum
			for k3, v3 in pairs(self.Pts[self.SelectedType][self.SelectedSet]) do
				local tp = CF.MissionRequiredData[self.SelectedType][k3]["Type"]

				if tp == "Box" then
					for k4, v4 in pairs(v3) do
						local havepair = false
						local pair

						if k4 % 2 == 0 then
							pair = k4 - 1
						else
							pair = k4 + 1
						end

						if v3[pair] == nil then
							self:PutGlow("SceneEditor_Dot_Red", v4)
						else
							self:PutGlow("SceneEditor_Dot_Green", v4)
							havepair = true
						end

						if havepair and k4 % 2 == 1 then
							local c1 = v4
							local c2 = v3[pair]

							--Draw box
							local x1 = c1.X
							local y1 = c1.Y
							local x2 = c2.X
							local y2 = c2.Y

							-- if we crossed th seam - change drawing coords
							if x2 < x1 then
								x2 = SceneMan.Scene.Width + x2
							end

							self:DrawDottedLine(x1, y1, x2, y2, "SceneEditor_Dot_Yellow", 50)
							self:DrawDottedLine(x2, y1, x1, y2, "SceneEditor_Dot_Yellow", 50)

							self:DrawDottedLine(x1, y1, x1, y2, "SceneEditor_Dot_Yellow", 50)
							self:DrawDottedLine(x1, y1, x2, y1, "SceneEditor_Dot_Yellow", 50)
							self:DrawDottedLine(x2, y1, x2, y2, "SceneEditor_Dot_Yellow", 50)
							self:DrawDottedLine(x1, y2, x2, y2, "SceneEditor_Dot_Yellow", 50)
						end

						local nm = CF.MissionRequiredData[self.SelectedType][k3]["Name"]
						local s = nm .. "-" .. tostring(k4)
						local l = CF.GetStringPixelWidth(s)

						CF.DrawString(s, v4 + Vector(-l / 2, -10), 150, 20)
					end
				else
					for k4, v4 in pairs(v3) do
						local nm = CF.MissionRequiredData[self.SelectedType][k3]["Name"]
						local s = nm .. "-" .. tostring(k4)
						local l = CF.GetStringPixelWidth(s)

						CF.DrawString(s, v4 + Vector(-l / 2, -10), 150, 20)
						self:PutGlow("SceneEditor_Dot_Green", v4)

						if self.SelectedPointType == k3 and self.SelectedPoint == k4 then
							self:AddObjectivePoint(s, v4 + Vector(0, -15), CF.PlayerTeam, GameActivity.ARROWDOWN)
						end

						if self.SelectedPointType == k3 and self.SelectedPoint ~= k4 then
							self:AddObjectivePoint(s, v4 + Vector(0, 15), CF.PlayerTeam, GameActivity.ARROWUP)
						end
					end
				end
			end
		end
	end

	if self.SnapToGrid and not self.ButtonPressed then
		local sx
		local sy

		if self.Mouse.X % self.GridSize < self.GridSize / 2 then
			sx = math.floor(self.Mouse.X / self.GridSize) * self.GridSize
		else
			sx = math.ceil(self.Mouse.X / self.GridSize) * self.GridSize
		end

		if self.Mouse.Y % self.GridSize < self.GridSize / 2 then
			sy = math.floor(self.Mouse.Y / self.GridSize) * self.GridSize
		else
			sy = math.ceil(self.Mouse.Y / self.GridSize) * self.GridSize
		end

		self.SnappedMouse = Vector(sx, sy)
		self:PutGlow("SceneEditor_Dot_Yellow", self.SnappedMouse)
	end

	local s = SceneMan.Scene.PresetName .. "\n"

	if self.SelectedType ~= nil then
		s = s .. self.SelectedType
	end

	if self.SelectedSet ~= nil then
		s = s .. " - S " .. self.SelectedSet
	end

	if self.SelectedPointType ~= nil then
		s = s .. " - " .. CF.MissionRequiredData[self.SelectedType][self.SelectedPointType]["Name"]
	end

	if self.SelectedPoint ~= nil then
		s = s .. " - " .. self.SelectedPoint
	end

	-- Draw generic points
	if self.ShowGeneric then
		for i = 1, CF.GenericMissionCount do
			if
				self.SelectedType ~= self.Data[i]["Name"]
				and self.SelectedSet ~= nil
				and self.Pts[self.Data[i]["Name"]] ~= nil
				and self.Pts[self.Data[i]["Name"]][self.SelectedSet] ~= nil
			then
				for k3, v3 in pairs(self.Pts[self.Data[i]["Name"]][self.SelectedSet]) do
					for k4, v4 in pairs(v3) do
						local nm = CF.MissionRequiredData[self.Data[i]["Name"]][k3]["Name"]
						local s = nm .. "-" .. tostring(k4)
						local l = CF.GetStringPixelWidth(s)

						CF.DrawString(s, v4 + Vector(-l / 2, -10), 150, 20)
						self:PutGlow("SceneEditor_Dot_Blue", v4)
					end
				end
			end
		end
	end --]]--

	FrameMan:ClearScreenText(0)
	FrameMan:SetScreenText(s, 0, 0, 1000, false)
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:PutGlow(preset, pos)
	local glow = CreateMOPixel(preset, self.ModuleName)
	if glow then
		glow.Pos = pos
		MovableMan:AddParticle(glow)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:FormClose() end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:PutGlowWithModule(preset, pos, module)
	local glow = CreateMOPixel(preset, module)
	if glow then
		glow.Pos = pos
		MovableMan:AddParticle(glow)
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DrawDottedLine(x1, y1, x2, y2, dot, interval)
	local d = CF.Dist(Vector(x1, y1), Vector(x2, y2))

	--local avgx = x2 - x1
	--local avgy = y2 - y2
	--local d = math.sqrt(avgx ^ 2 + avgy ^ 2)

	--print (d)

	local ax = (x2 - x1) / d * interval
	local ay = (y2 - y1) / d * interval

	local x = x1
	local y = y1

	d = math.floor(d)

	for i = 1, d, interval do
		self:PutGlowWithModule(dot, Vector(x, y), self.ModuleName)

		x = x + ax
		y = y + ay
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
