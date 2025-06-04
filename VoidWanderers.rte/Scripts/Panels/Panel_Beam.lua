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

			self.BeamControlPanelActor.Pos = self.BeamControlPanelPos;
			self.BeamControlPanelActor.Team = CF.PlayerTeam;

			MovableMan:AddActor(self.BeamControlPanelActor);
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
	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.PresetName == "Beam Control Panel" then
			self.BeamControlPanelActor = actor;
			break;
		end
	end end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DestroyBeamControlPanelUI()
	for _, set in ipairs{ MovableMan.Actors, MovableMan.AddedActors } do for actor in set do
		if actor.PresetName == "Beam Control Panel" then
			actor.ToDelete = true;
		end
	end end
	
	self.BeamControlPanelActor = nil;
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

				local brainCount = 0;

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
							brainCount = brainCount + 1;
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

				if brainCount > 0 and brainCount < self.PlayerCount then
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
					if not self.firePressed[player] then
						self.firePressed[player] = true;

						-- Save ground items
						storageCapacity = tonumber(self.GS["PlayerVesselStorageCapacity"]);
						for item in MovableMan.Items do
							if IsHeldDevice(item) and not ToHeldDevice(item).UnPickupable then
								local count = CF.CountUsedStorageInArray(self.StorageItems);

								if count < storageCapacity then
									CF.PutItemToStorageArray(self.StorageItems, item.PresetName, item.ClassName, item.ModuleName);
								else
									break;
								end
							end
						end

						CF.SetStorageArray(self.GS, self.StorageItems);

						-- Clean previously saved actors and inventories in config
						CF.ClearDeployed(self.GS);
						CF.ClearOnboard(self.GS);

						local deployed = {};
						local onboard = {};

						-- Save actors to config and transfer them to scene
						for _, set in pairs{MovableMan.Actors, MovableMan.Particles} do
							for actor in set do
								if
									actor.GetsHitByMOs
									and actor.PresetName ~= "Brain Case"
									and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
									and actor.Team == Activity.TEAM_1
								then
									if self.BeamControlPanelBox:IsWithinBox(actor.Pos) then
										table.insert(deployed, actor);
									else
										table.insert(onboard, actor);
									end
								end
							end
						end

						self.deploymentToSerialize = deployed;
						self.onboardToSerialize = onboard;
						local locationScenes = CF.LocationScenes[locationID];
						local scene = locationScenes[math.random(#locationScenes)];

						-- Set new operating mode
						self.GS["BrainsOnMission"] = brainCount == self.PlayerCount and "True" or "False";
						self.GS["Mode"] = "Mission";
						self.GS["Scene"] = scene;
						self:saveCurrentGameState(self.GS);
						self:DestroyConsoles();
						
						self.sceneToLaunch = self.GS["Scene"];
						self.scriptToLaunch = "Tactics.lua";
					end
				else
					self.firePressed[player] = false
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
		PrimitiveMan.DrawPrimitives(PrimitiveMan, DrawBlendMode.NoBlend, 080, 080, 080, 080, { BitmapPrimitive(player, pos, path, rotation, hflip, vflip) });
	end

	if MovableMan:IsActor(self.BeamControlPanelActor) then
		self.BeamControlPanelActor.Health = 100
	end
end
