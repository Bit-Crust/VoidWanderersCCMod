-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:InitBeamControlPanelUI()
	local x, y;

	x = tonumber(self.SceneConfig["BeamControlPanelX"]);
	y = tonumber(self.SceneConfig["BeamControlPanelY"]);
	if x ~= nil and y ~= nil then
		self.BeamControlPanelPos = Vector(x, y);
	else
		self.BeamControlPanelPos = nil;
	end

	if self.BeamControlPanelPos ~= nil then
		self:LocateBeamControlPanelActor();
		if not MovableMan:IsActor(self.BeamControlPanelActor) then
			self.BeamControlPanelActor = CreateActor("Beam Control Panel");
			if self.BeamControlPanelActor ~= nil then
				self.BeamControlPanelActor.Pos = self.BeamControlPanelPos;
				self.BeamControlPanelActor.Team = CF.PlayerTeam;
				MovableMan:AddActor(self.BeamControlPanelActor);
			end
		end
	end

	-- Init variables
	local x1, y1, x2, y2;

	x1 = tonumber(self.SceneConfig["BeamBoxX1"]);
	y1 = tonumber(self.SceneConfig["BeamBoxY1"]);
	x2 = tonumber(self.SceneConfig["BeamBoxX2"]);
	y2 = tonumber(self.SceneConfig["BeamBoxY2"]);

	if x1 ~= nil and y1 ~= nil and x2 ~= nil and y2 ~= nil then
		self.BeamControlPanelBox = Box(x1, y1, x2, y2);
	else
		self.BeamControlPanelBox = nil;
	end
end
-----------------------------------------------------------------------
-- Find and assign appropriate actors
-----------------------------------------------------------------------
function VoidWanderers:LocateBeamControlPanelActor()
	for actor in MovableMan.AddedActors do
		if actor.PresetName == "Beam Control Panel" then
			self.BeamControlPanelActor = actor;
			break;
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DestroyBeamControlPanelUI()
	if self.BeamControlPanelActor ~= nil then
		self.BeamControlPanelActor.ToDelete = true;
		self.BeamControlPanelActor = nil;
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ProcessBeamControlPanelUI()
	local showIdle = true;

	if self.BeamControlPanelActor then
		local pos = self.BeamControlPanelPos;

		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			local act = self:GetControlledActor(player);

			if act and act.PresetName == self.BeamControlPanelActor.PresetName then
				showIdle = false;
				local pos = self.BeamControlPanelPos;
				local cont = act:GetController();
				local canbeam = false;
				local beamText = "";

				local braincount = 0;

				local count = 0;
				for actor in MovableMan.Actors do
					if actor.GetsHitByMOs and self.BeamControlPanelBox:IsWithinBox(actor.Pos) then
						-- Create particle effect around actors
						local part = CreateMOSParticle("Tiny Blue Glow", self.ModuleName);
						part.Pos = actor.Pos
							+ Vector(0, actor.IndividualRadius * 0.5)
							+ Vector(actor.IndividualRadius * RangeRand(0, 1.25), 0):RadRotate(RangeRand(-math.pi, math.pi))
						MovableMan:AddParticle(part);

						count = count + 1;

						if CF.IsBrain(actor) then
							braincount = braincount + 1;
						end
					end
				end

				-- Create teleport effects
				--if self.TeleportEffectTimer:IsPastSimMS(50) then
				-- Create particle
				local p = CreateMOSParticle("Tiny Blue Glow", self.ModuleName);
				p.Pos = self.BeamControlPanelBox:GetRandomPoint();
				p.Vel = p.Vel * 0.5;
				MovableMan:AddParticle(p);
				--	self.TeleportEffectTimer:Reset()
				--end

				local locationID = self.GS["Location"];
				--print (CF.LocationName[ locationID ])

				-- Search for detached brains
				local anybraindetached = false;

				for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
					if self.GS["Brain" .. player .. "Detached"] == "True" then
						anybraindetached = true;
					end
				end

				local limit = tonumber(self.GS["PlayerVesselCommunication"]);

				if braincount > 0 and braincount < self.PlayerCount then
					beamText = "All brains must be on the landing deck";
					canbeam = false;
				else
					local locname = CF.LocationName[locationID];
					if locname ~= nil then
						if
							CF.LocationPlayable[locationID] == nil
							or CF.LocationPlayable[locationID] == true
						then
							if count <= limit or anybraindetached then
								if count > 0 then
									beamText = "Deploy away team on\n" .. CF.LocationName[locationID];
									canbeam = true;
								else
									beamText = "No units on the landing deck";
									canbeam = false
								end
							else
								beamText = "Too many units!";
								canbeam = false;
							end
						else
							beamText = "Can't deploy to\n" .. CF.LocationName[locationID];
							canbeam = false;
						end
					else
						beamText = "Can't deploy units into space";
						canbeam = false;
					end
				end

				-- Deploy units
				if cont:IsState(Controller.WEAPON_FIRE) and canbeam then
					if not self.FirePressed[player] then
						self.FirePressed[player] = true

						-- Save ground items
						storageCapacity = tonumber(self.GS["PlayerVesselStorageCapacity"])
						for item in MovableMan.Items do
							if IsHeldDevice(item) and not ToHeldDevice(item).UnPickupable then
								local count = CF.CountUsedStorageInArray(self.StorageItems)

								if count < storageCapacity then
									CF.PutItemToStorageArray(
										self.StorageItems,
										item.PresetName,
										item.ClassName,
										item.ModuleName
									)
								else
									break
								end
							end
						end

						CF.SetStorageArray(self.GS, self.StorageItems)

						-- Clean previously saved actors and inventories in config
						self:ClearDeployed()
						self.deployedActors = {}
						local deployedactor = 1
					
						self:ClearActors()
						self.onboardActors = {}
						local savedactor = 1

						-- Save actors to config and transfer them to scene
						for _, set in pairs{MovableMan.Actors, MovableMan.Particles} do
							for actor in set do
								if IsActor(actor) then
									actor = ToActor(actor)
								end
								if
									actor.GetsHitByMOs
									and actor.PresetName ~= "Brain Case"
									and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
								then
									local pre, cls, mdl = CF.GetInventory(actor)

									if self.BeamControlPanelBox:IsWithinBox(actor.Pos) then
										-- Save actors to deployment config
										self.GS["Deployed" .. deployedactor .. "Preset"] = actor.PresetName
										self.GS["Deployed" .. deployedactor .. "Class"] = actor.ClassName
										self.GS["Deployed" .. deployedactor .. "Module"] = actor.ModuleName
										self.GS["Deployed" .. deployedactor .. "XP"] = actor:GetNumberValue("VW_XP")
										self.GS["Deployed" .. deployedactor .. "Identity"] = actor:GetNumberValue("Identity")
										self.GS["Deployed" .. deployedactor .. "Player"] = actor:GetNumberValue("VW_BrainOfPlayer")
										self.GS["Deployed" .. deployedactor .. "Prestige"] = actor:GetNumberValue("VW_Prestige")
										self.GS["Deployed" .. deployedactor .. "Name"] = actor:GetStringValue("VW_Name")

										for i, limbID in pairs(CF.HumanLimbID) do
											self.GS["Deployed" .. deployedactor .. limbID] = CF.GetLimbData(actor, limbID)
										end

										for j = 1, #pre do
											self.GS["Deployed" .. deployedactor .. "Item" .. j .. "Preset"] = pre[j]
											self.GS["Deployed" .. deployedactor .. "Item" .. j .. "Class"] = cls[j]
											self.GS["Deployed" .. deployedactor .. "Item" .. j .. "Module"] = mdl[j]
										end

										self.deployedActors[deployedactor] = actor
										deployedactor = deployedactor + 1
									else
										-- Save actors to onboard config
										self.GS["Actor" .. savedactor .. "Preset"] = actor.PresetName
										self.GS["Actor" .. savedactor .. "Class"] = actor.ClassName
										self.GS["Actor" .. savedactor .. "Module"] = actor.ModuleName
										self.GS["Actor" .. savedactor .. "XP"] = actor:GetNumberValue("VW_XP")
										self.GS["Actor" .. savedactor .. "Identity"] = actor:GetNumberValue("Identity")
										self.GS["Actor" .. savedactor .. "Player"] = actor:GetNumberValue("VW_BrainOfPlayer")
										self.GS["Actor" .. savedactor .. "Prestige"] = actor:GetNumberValue("VW_Prestige")
										self.GS["Actor" .. savedactor .. "Name"] = actor:GetStringValue("VW_Name")
										self.GS["Actor" .. savedactor .. "X"] = math.floor(actor.Pos.X)
										self.GS["Actor" .. savedactor .. "Y"] = math.floor(actor.Pos.Y)
										
										for i, limbID in pairs(CF.HumanLimbID) do
											self.GS["Actor" .. deployedactor .. limbID] = CF.GetLimbData(actor, limbID)
										end

										for j = 1, #pre do
											self.GS["Actor" .. savedactor .. "Item" .. j .. "Preset"] = pre[j]
											self.GS["Actor" .. savedactor .. "Item" .. j .. "Class"] = cls[j]
											self.GS["Actor" .. savedactor .. "Item" .. j .. "Module"] = mdl[j]
										end
								
										self.onboardActors[savedactor] = actor
										savedactor = savedactor + 1
									end
								end
							end
						end

						for _, actor in pairs(self.deployedActors) do
							self.deployedActors[_] = MovableMan:RemoveActor(actor)
						end

						for _, actor in pairs(self.onboardActors) do
							self.onboardActors[_] = MovableMan:RemoveActor(actor)
						end

						if braincount == self.PlayerCount then
							self.GS["BrainsOnMission"] = "True"
						else
							self.GS["BrainsOnMission"] = "False"
						end
						self.BrainsAtStake = false

						-- Prepare for transfer
						-- Select scene
						local locationScenes = CF.LocationScenes[locationID]
						local scene = locationScenes[math.random(#locationScenes)]

						-- Set new operating mode
						self.GS["DeserializeDeployedTeam"] = "True"
						self.GS["DeserializeOnboard"] = "True"
						self.GS["Mode"] = "Mission"
						self.GS["Scene"] = scene
						self:SaveCurrentGameState()

						self:LaunchScript(scene, "Tactics.lua")
						self:DestroyConsoles()
						return true
					end
				else
					self.FirePressed[player] = false
				end

				-- Draw background
				local player = Activity.PLAYER_NONE;
				CF.DrawMenuBox(player, pos.X - 70, pos.Y - 24, pos.X + 70, pos.Y + 24, canbeam and CF.MenuNormalIdle or CF.MenuDeniedIdle);

				local text = "DEPLOY";
				if not anybraindetached then
					text = "DEPLOY [ " .. tostring(count) .. "/" .. self.GS["PlayerVesselCommunication"] .. " ]";
				end
				CF.DrawString(text, pos + Vector(0, -20), 130, 36, nil, nil, 1, nil, nil, player);

				CF.DrawString(beamText, pos + Vector(0, 6), 124, 36, nil, nil, 1, 1, nil, player)
			end
		end
	end
	
	if showIdle and MovableMan:ValidMO(self.BeamControlPanelActor) and self.BeamControlPanelActor.Team == Activity.TEAM_1 then
		local player = Activity.PLAYER_NONE;
		local pos = self.BeamControlPanelActor.Pos;
		local path = "Mods/VoidWanderers.rte/UI/ControlPanels/ControlPanel_Beam.png";
		local rotation = 0;
		local hflip = false;
		local vflip = false;
		PrimitiveMan:DrawBitmapPrimitive(player, pos, path, rotation, hflip, vflip);
	end

	if MovableMan:IsActor(self.BeamControlPanelActor) then
		self.BeamControlPanelActor.Health = 100
	end
end
