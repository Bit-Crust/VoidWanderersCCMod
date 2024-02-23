-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitTurretsControlPanelUI()
	local count = tonumber(self.GS["Player0VesselTurrets"])

	self.TurretsControlPanelPos = {}

	for i = 1, count do
		local x = tonumber(self.GS["Actors - Turret" .. i .. "X"])
		local y = tonumber(self.GS["Actors - Turret" .. i .. "Y"])

		if x ~= nil and y ~= nil then
			self.TurretsControlPanelPos[i] = Vector(x, y)
		else
			self.TurretsControlPanelPos[i] = self.AwayTeamPos[i]
		end
	end

	self.TurretsControlPanelActor = {}

	for i = 1, count do
		if not MovableMan:IsActor(self.TurretsControlPanelActor[i]) then
			self.TurretsControlPanelActor[i] = CreateActor("Turret Control Panel")
			if self.TurretsControlPanelActor[i] ~= nil then
				self.TurretsControlPanelActor[i].Pos = self.TurretsControlPanelPos[i]
				self.TurretsControlPanelActor[i].Team = CF_PlayerTeam
				MovableMan:AddActor(self.TurretsControlPanelActor[i])
			end
		else
			--print (self.TurretsControlPanelActor)
		end
	end

	self.TurretsControlPanelEditMode = {}
	self.TurretsControlPanelInitialized = {}
	for i = 1, count do
		self.TurretsControlPanelEditMode[i] = false
		self.TurretsControlPanelInitialized[i] = false
	end

	self.Turrets = CF_GetTurretsArray(self.GS)
	self.TurretsControlPanelLinesPerPage = 4
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DestroyTurretsControlPanelUI()
	local count = tonumber(self.GS["Player0VesselTurrets"])
	for i = 1, count do
		if self.TurretsControlPanelActor[i] ~= nil and MovableMan:IsActor(self.TurretsControlPanelActor[i]) then
			self.TurretsControlPanelActor[i].ToDelete = true
			self.TurretsControlPanelActor[i] = nil
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessTurretsControlPanelUI()
	local count = tonumber(self.GS["Player0VesselTurrets"])

	for turr = 1, count do
		if MovableMan:IsActor(self.TurretsControlPanelActor[turr]) then
			local showidle = true
			local empty = true

			if self.GS["DeployedTurret" .. turr .. "Preset"] ~= nil then
				empty = false
			end

			for plr = 0, self.PlayerCount - 1 do
				local act = self:GetControlledActor(plr)

				if
					act
					and MovableMan:IsActor(act)
					and act.Pos.X == self.TurretsControlPanelActor[turr].Pos.X
					and act.Pos.Y == self.TurretsControlPanelActor[turr].Pos.Y
					and act.Age == self.TurretsControlPanelActor[turr].Age
				then
					showidle = false

					local pos = self.TurretsControlPanelPos[turr]
					local cont = act:GetController()

					if self.TurretsControlPanelEditMode[turr] then
						if not self.TurretsControlPanelInitialized[turr] then
							if #self.Turrets > 0 then
								self.SelectedTurret = 1
							else
								self.SelectedTurret = 0
							end

							self.TurretsStorageSelectedItem = 1

							self.TurretsControlPanelInitialized[turr] = true
						end

						-- Add or delete 'remove turret' menu item
						if self.GS["DeployedTurret" .. turr .. "Preset"] ~= nil then
							if self.Turrets[#self.Turrets]["Preset"] ~= "Remove turret" then
								local n = #self.Turrets + 1

								self.Turrets[n] = {}
								self.Turrets[n]["Preset"] = "Remove turret"
								self.Turrets[n]["Class"] = ""
								self.Turrets[n]["Module"] = ""
								self.Turrets[n]["Count"] = 0
							end
						else
						end

						local up = false
						local down = false

						if cont:IsState(Controller.PRESS_UP) then
							self.HoldTimer:Reset()
							up = true
						end

						if cont:IsState(Controller.PRESS_DOWN) then
							self.HoldTimer:Reset()
							down = true
						end

						if self.HoldTimer:IsPastSimMS(CF_KeyRepeatDelay) then
							self.HoldTimer:Reset()

							if cont:IsState(Controller.HOLD_UP) then
								up = true
							end

							if cont:IsState(Controller.HOLD_DOWN) then
								down = true
							end
						end

						if up then
							if #self.Turrets > 0 then
								self.SelectedTurret = self.SelectedTurret - 1

								if self.SelectedTurret < 1 then
									self.SelectedTurret = #self.Turrets
								end
							end
						end

						if down then
							if #self.Turrets > 0 then
								self.SelectedTurret = self.SelectedTurret + 1

								if self.SelectedTurret > #self.Turrets then
									self.SelectedTurret = 1
								end
							end
						end

						if cont:IsState(Controller.WEAPON_FIRE) then
							if not self.FirePressed then
								self.FirePressed = true

								if self.SelectedTurret > 0 then
									-- Remove current turret  if 'remove turret' was selected
									if self.Turrets[self.SelectedTurret]["Preset"] == "Remove turret" then
										if
											self.GS["DeployedTurret" .. turr .. "Preset"] ~= nil
											and self.GS["DeployedTurret" .. turr .. "Class"] ~= nil
										then
											if
												CF_CountUsedTurretsInArray(self.Turrets)
												< tonumber(self.GS["Player0VesselTurretStorage"])
											then
												if self.Turrets[#self.Turrets]["Preset"] == "Remove turret" then
													self.Turrets[#self.Turrets] = nil
												end

												self.SelectedTurret = #self.Turrets

												CF_PutTurretToStorageArray(
													self.Turrets,
													self.GS["DeployedTurret" .. turr .. "Preset"],
													self.GS["DeployedTurret" .. turr .. "Class"],
													self.GS["DeployedTurret" .. turr .. "Module"]
												)

												self.GS["DeployedTurret" .. turr .. "Preset"] = nil
												self.GS["DeployedTurret" .. turr .. "Class"] = nil
												self.GS["DeployedTurret" .. turr .. "Module"] = nil
												CF_SetTurretsArray(self.GS, self.Turrets)
											end
										end
									else
										if self.Turrets[self.SelectedTurret]["Count"] > 0 then
											if
												self.GS["DeployedTurret" .. turr .. "Preset"] ~= nil
												and self.GS["DeployedTurret" .. turr .. "Class"] ~= nil
											then
												CF_PutTurretToStorageArray(
													self.Turrets,
													self.GS["DeployedTurret" .. turr .. "Preset"],
													self.GS["DeployedTurret" .. turr .. "Class"],
													self.GS["DeployedTurret" .. turr .. "Module"]
												)
											end

											self.GS["DeployedTurret" .. turr .. "Preset"] =
												self.Turrets[self.SelectedTurret]["Preset"]
											self.GS["DeployedTurret" .. turr .. "Class"] =
												self.Turrets[self.SelectedTurret]["Class"]
											self.GS["DeployedTurret" .. turr .. "Module"] =
												self.Turrets[self.SelectedTurret]["Module"]
											self.Turrets[self.SelectedTurret]["Count"] = self.Turrets[self.SelectedTurret]["Count"]
												- 1

											CF_SetTurretsArray(self.GS, self.Turrets)
										end
									end
								end
							end
						else
							self.FirePressed = false
						end

						self.TurretsControlCloneListStart = self.SelectedTurret
							- (self.SelectedTurret - 1) % self.TurretsControlPanelLinesPerPage

						local pre = self.GS["DeployedTurret" .. turr .. "Preset"]

						if self.Time % 2 == 0 then
							if pre ~= nil then
								CF_DrawString("Active: " .. pre, pos + Vector(-60, -24), 136, 10)
							else
								CF_DrawString("Active: NONE", pos + Vector(-60, -24), 136, 10)
							end
						else
							CF_DrawString(
								"Storage: "
									.. CF_CountUsedTurretsInArray(self.Turrets)
									.. " / "
									.. self.GS["Player0VesselTurretStorage"],
								pos + Vector(-60, -24),
								136,
								10
							)
						end

						-- Draw list
						for i = self.TurretsControlCloneListStart, self.TurretsControlCloneListStart + self.TurretsControlPanelLinesPerPage - 1 do
							if i <= #self.Turrets and i > 0 then
								local loc = i - self.TurretsControlCloneListStart

								if i == self.SelectedTurret then
									CF_DrawString(
										"> " .. self.Turrets[i]["Preset"],
										pos + Vector(-60, -8) + Vector(0, loc * 12),
										120,
										10
									)
								else
									CF_DrawString(
										self.Turrets[i]["Preset"],
										pos + Vector(-60, -8) + Vector(0, loc * 12),
										120,
										10
									)
								end
								if self.Turrets[i]["Preset"] ~= "Remove turret" then
									CF_DrawString(
										tostring(self.Turrets[i]["Count"]),
										pos + Vector(56, -8) + Vector(0, loc * 12),
										120,
										10
									)
								end
							end
						end

						self:PutGlow("ControlPanel_Turret_Select", self.TurretsControlPanelPos[turr])
					else
						local up = false
						local down = false
						local left = false
						local right = false

						if cont:IsState(Controller.PRESS_UP) then
							self.HoldTimer:Reset()
							up = true
						end

						if cont:IsState(Controller.PRESS_DOWN) then
							self.HoldTimer:Reset()
							down = true
						end

						if cont:IsState(Controller.PRESS_LEFT) then
							self.HoldTimer:Reset()
							left = true
						end

						if cont:IsState(Controller.PRESS_RIGHT) then
							self.HoldTimer:Reset()
							right = true
						end

						if self.HoldTimer:IsPastSimMS(50) then
							self.HoldTimer:Reset()

							if cont:IsState(Controller.HOLD_UP) then
								up = true
							end

							if cont:IsState(Controller.HOLD_DOWN) then
								down = true
							end

							if cont:IsState(Controller.HOLD_LEFT) then
								left = true
							end

							if cont:IsState(Controller.HOLD_RIGHT) then
								right = true
							end
						end

						local ax = 0
						local ay = 0

						if left then
							ax = -1
						end

						if right then
							ax = 1
						end

						if up then
							ay = -1
						end

						if down then
							ay = 1
						end

						if ax ~= 0 or ay ~= 0 then
							local newpos = Vector(
								self.TurretsControlPanelActor[turr].Pos.X + ax * 8,
								self.TurretsControlPanelActor[turr].Pos.Y + ay * 8
							)

							--if self.Ship:IsInside(newpos) and SceneMan:GetTerrMatter(newpos.X, newpos.Y) == 0 then
							if self.Ship:IsInside(newpos) then
								self.TurretsControlPanelActor[turr].Pos = newpos
								self.TurretsControlPanelPos[turr] = newpos
								self.GS["Actors - Turret" .. turr .. "X"] = math.floor(newpos.X)
								self.GS["Actors - Turret" .. turr .. "Y"] = math.floor(newpos.Y)
							end
						end

						if cont:IsState(Controller.WEAPON_FIRE) then
							if not self.FirePressed then
								self.FirePressed = true

								self.TurretsControlPanelEditMode[turr] = true
								self.TurretsControlPanelInitialized[turr] = false
							end
						else
							self.FirePressed = false
						end

						-- Draw background
						if empty then
							self:PutGlow("ControlPanel_Turret_EmptyMove", self.TurretsControlPanelPos[turr])
						else
							if
								self.GS["DeployedTurret" .. turr .. "Preset"] ~= nil
								and self.GS["DeployedTurret" .. turr .. "Class"] ~= nil
							then
								local l = CF_GetStringPixelWidth(self.GS["DeployedTurret" .. turr .. "Preset"])
								CF_DrawString(
									self.GS["DeployedTurret" .. turr .. "Preset"],
									self.TurretsControlPanelPos[turr] + Vector(-l / 2, -28),
									120,
									10
								)
							end

							self:PutGlow("ControlPanel_Turret_Move", self.TurretsControlPanelPos[turr])
						end
					end
				end
			end

			if showidle then
				self.TurretsControlPanelEditMode[turr] = false
				self.TurretsControlPanelInitialized[turr] = false
			end

			if showidle and self.TurretsControlPanelPos[turr] ~= nil then
				if empty then
					self:PutGlow("ControlPanel_Turret_Empty", self.TurretsControlPanelPos[turr])
				else
					self:PutGlow("ControlPanel_Turret", self.TurretsControlPanelPos[turr])
				end
			end

			if MovableMan:IsActor(self.TurretsControlPanelActor[turr]) then
				self.TurretsControlPanelActor[turr].Health = 100
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DeployTurrets()
	self.TurretsDeployedActors = {}
	local count = tonumber(self.GS["Player0VesselTurrets"])

	for turr = 1, count do
		local preset = self.GS["DeployedTurret" .. turr .. "Preset"]
		local class = self.GS["DeployedTurret" .. turr .. "Class"]
		local module = self.GS["DeployedTurret" .. turr .. "Module"]

		if preset ~= nil and class ~= nil then
			local actor = CF_MakeActor(preset, class, module)
			if actor then
				actor.Team = CF_PlayerTeam
				actor.Pos = self.TurretsControlPanelPos[turr]
				actor.AIMode = Actor.AIMODE_SENTRY
				self:SetAlly(actor, true)

				local leftSpace = SceneMan:CastObstacleRay(
					actor.Pos,
					Vector(-100, 0),
					Vector(),
					Vector(),
					actor.ID,
					actor.Team,
					rte.doorID,
					5
				)
				local rightSpace = SceneMan:CastObstacleRay(
					actor.Pos,
					Vector(100, 0),
					Vector(),
					Vector(),
					actor.ID,
					actor.Team,
					rte.doorID,
					5
				)
				if leftSpace < 0 and rightSpace < 0 then
					actor.HFlipped = math.random() < 0.5
				elseif leftSpace < 0 then
					actor.HFlipped = true
				elseif rightSpace < 0 then
					actor.HFlipped = false
				else
					actor.HFlipped = leftSpace > rightSpace
				end

				self.TurretsDeployedActors[turr] = actor
				MovableMan:AddActor(actor)
			else
				print("Can't create turret " .. preset .. " " .. class)
			end
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:RemoveDeployedTurrets()
	if self.TurretsDeployedActors ~= nil then
		local count = tonumber(self.GS["Player0VesselTurrets"])

		for turr = 1, count do
			if MovableMan:IsActor(self.TurretsDeployedActors[turr]) then
				self.TurretsDeployedActors[turr].ToDelete = true
			else
				self.GS["DeployedTurret" .. turr .. "Preset"] = nil
				self.GS["DeployedTurret" .. turr .. "Class"] = nil
				self.GS["DeployedTurret" .. turr .. "Module"] = nil
			end
		end

		self.TurretsDeployedActors = nil
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
