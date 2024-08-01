-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:InitBeamControlPanelUI()
	-- Beam Control Panel
	local x, y;

	x = tonumber(self.LS["BeamControlPanelX"]);
	y = tonumber(self.LS["BeamControlPanelY"]);
	if x ~= nil and y ~= nil then
		self.BeamControlPanelPos = Vector(x, y);
	else
		self.BeamControlPanelPos = nil;
	end

	local x1, y1, x2, y2;

	x1 = tonumber(self.LS["BeamBoxX1"]);
	y1 = tonumber(self.LS["BeamBoxY1"]);
	x2 = tonumber(self.LS["BeamBoxX2"]);
	y2 = tonumber(self.LS["BeamBoxY2"]);

	if x1 ~= nil and y1 ~= nil and x2 ~= nil and y2 ~= nil then
		self.BeamControlPanelBox = Box(x1, y1, x2, y2);
	else
		self.BeamControlPanelBox = nil;
	end

	-- Create actor
	-- Ship
	if self.BeamControlPanelPos ~= nil then
		if not MovableMan:IsActor(self.BeamControlPanelActor) then
			self.BeamControlPanelActor = CreateActor("Beam Control Panel");
			if self.BeamControlPanelActor ~= nil then
				self.BeamControlPanelActor.Pos = self.BeamControlPanelPos;
				self.BeamControlPanelActor.Team = CF["PlayerTeam"];
				MovableMan:AddActor(self.BeamControlPanelActor);
			end
		else
			--print (self.BeamControlPanelActor)
		end
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:DestroyBeamControlPanelUI()
	if self.BeamControlPanelActor ~= nil then
		self.BeamControlPanelActor.ToDelete = true;
		self.BeamControlPanelActor = nil;
	end
end
-----------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------
function VoidWanderers:ProcessBeamControlPanelUI()
	local showidle = true;

	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local act = self:GetControlledActor(player)

		if act and MovableMan:IsActor(act) and act.PresetName == "Beam Control Panel" then
			showidle = false;

			local pos = self.BeamControlPanelPos;
			local cont = act:GetController();
			local canbeam = false;

			local braincount = 0;

			local count = 0;
			for actor in MovableMan.Actors do
				if actor.GetsHitByMOs and self.BeamControlPanelBox:IsWithinBox(actor.Pos) then
					-- Create particle effect around actors
					local part = CreateMOSParticle("Tiny Blue Glow", self.ModuleName);
					part.Pos = actor.Pos
						+ Vector(0, actor.IndividualRadius * 0.5)
						+ Vector(actor.IndividualRadius * RangeRand(0, 1.25), 0):RadRotate(RangeRand(-math.pi, math.pi));
					MovableMan:AddParticle(part);

					count = count + 1;

					if actor:IsInGroup("Brains") then
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

			--print (CF["LocationName"][ self.GS["Location"] ])

			-- Search for detached brains
			local anybraindetached = false;

			for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
				if self.GS["Brain" .. player .. "Detached"] == "True" then
					anybraindetached = true;
				end
			end

			local limit = tonumber(self.GS["Player0VesselCommunication"]);
			if anybraindetached then
				limit = 1000;
			end

			if anybraindetached and braincount < self.PlayerCount then
				CF["DrawString"]("All brains must be on the landing deck", pos + Vector(-54, -6), 124, 36);
				canbeam = false;
			else
				local locname = CF["LocationName"][self.GS["Location"]];
				if locname ~= nil then
					if
						CF["LocationPlayable"][self.GS["Location"]] == nil
						or CF["LocationPlayable"][self.GS["Location"]] == true
					then
						if count <= limit then
							if count > 0 then
								CF["DrawString"](
									"Deploy away team on " .. CF["LocationName"][self.GS["Location"]],
									pos + Vector(-55, -6),
									120,
									36
								);
								canbeam = true;
							else
								CF["DrawString"]("No units on the landing deck", pos + Vector(-50, -6), 120, 36);
								canbeam = false;
							end
						else
							CF["DrawString"]("Too many units!", pos + Vector(-35, -6), 120, 36);
							canbeam = false;
						end
					else
						CF["DrawString"](
							"Can't deploy to " .. CF["LocationName"][self.GS["Location"]],
							pos + Vector(-50, -6),
							120,
							36
						);
						canbeam = false;
					end
				else
					CF["DrawString"]("Can't deploy units into space", pos + Vector(-50, 0), 120, 36);
					canbeam = false;
				end
			end

			if not anybraindetached then
				CF["DrawString"](
					"DEPLOY [ " .. tostring(count) .. "/" .. self.GS["Player0VesselCommunication"] .. " ]",
					pos + Vector(-30, -16),
					130,
					36
				);
			else
				CF["DrawString"]("DEPLOY", pos + Vector(-16, -16), 130, 36);
			end

			-- Deploy units
			if cont:IsState(Controller.WEAPON_FIRE) and canbeam then
				if not self.FirePressed[player] then
					self.FirePressed[player] = true

					local savedactor = 1;

					-- Save all items
					for item in MovableMan.Items do
						if IsHeldDevice(item) and not ToHeldDevice(item).UnPickupable then
							local count = CF["CountUsedStorageInArray"](self.StorageItems);

							if count < tonumber(self.GS["Player0VesselStorageCapacity"]) then
								CF["PutItemToStorageArray"](
									self.StorageItems,
									item.PresetName,
									item.ClassName,
									item.ModuleName
								);
							else
								break;
							end
						end
					end

					CF["SetStorageArray"](self.GS, self.StorageItems);

					-- Clean previously saved actors and inventories in config
					self:ClearActors();

					self.DeployedActors = {};

					-- Save actors to config and transfer them to scene
					for actor in MovableMan.Actors do
						if
							actor.GetsHitByMOs
							and actor.PresetName ~= "Brain Case"
							and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
						then
							local pre, cls, mdl = CF["GetInventory"](actor);

							-- These actors must be deployed
							if self.BeamControlPanelBox:IsWithinBox(actor.Pos) then
								local n = #self.DeployedActors + 1;
								self.DeployedActors[n] = {};
								self.DeployedActors[n]["Preset"] = actor.PresetName;
								self.DeployedActors[n]["Class"] = actor.ClassName;
								self.DeployedActors[n]["Module"] = actor.ModuleName;
								self.DeployedActors[n]["XP"] = actor:GetNumberValue("VW_XP");
								self.DeployedActors[n]["Identity"] = actor:GetNumberValue("Identity");
								self.DeployedActors[n]["Prestige"] = actor:GetNumberValue("VW_Prestige");
								self.DeployedActors[n]["Name"] = actor:GetStringValue("VW_Name");
								self.DeployedActors[n]["InventoryPresets"] = pre;
								self.DeployedActors[n]["InventoryClasses"] = cls;
								self.DeployedActors[n]["InventoryModules"] = mdl;
								for j = 1, #CF["LimbID"] do
									self.DeployedActors[n][CF["LimbID"][j]] = CF["GetLimbData"](actor, j);
								end
								--[[
								local attCount = 0;
								for att in actor.Attachables do
									attCount = attCount + 1;
									self.DeployedActors[n]["Attachable"..attCount] = att.PresetName;
								end
								]]
								--
							else
								-- Save actors to config
								self.GS["Actor" .. savedactor .. "Preset"] = actor.PresetName;
								self.GS["Actor" .. savedactor .. "Class"] = actor.ClassName;
								self.GS["Actor" .. savedactor .. "Module"] = actor.ModuleName;
								self.GS["Actor" .. savedactor .. "XP"] = actor:GetNumberValue("VW_XP");
								self.GS["Actor" .. savedactor .. "Identity"] = actor:GetNumberValue("Identity");
								self.GS["Actor" .. savedactor .. "Prestige"] = actor:GetNumberValue("VW_Prestige");
								self.GS["Actor" .. savedactor .. "Name"] = actor:GetStringValue("VW_Name");
								self.GS["Actor" .. savedactor .. "X"] = math.floor(actor.Pos.X);
								self.GS["Actor" .. savedactor .. "Y"] = math.floor(actor.Pos.Y);
								for j = 1, #CF["LimbID"] do
									self.GS["Actor" .. savedactor .. CF["LimbID"][j]] = CF["GetLimbData"](actor, j);
								end

								for j = 1, #pre do
									self.GS["Actor" .. savedactor .. "Item" .. j .. "Preset"] = pre[j];
									self.GS["Actor" .. savedactor .. "Item" .. j .. "Class"] = cls[j];
									self.GS["Actor" .. savedactor .. "Item" .. j .. "Module"] = mdl[j];
								end

								savedactor = savedactor + 1;
							end
						end
					end

					-- Prepare for transfer
					-- Select scene
					local r = math.random(#CF["LocationScenes"][self.GS["Location"]]);
					local scene = CF["LocationScenes"][self.GS["Location"]][r];

					if anybraindetached then
						self.GS["BrainsOnMission"] = "True";
					else
						self.GS["BrainsOnMission"] = "False";
					end

					--print (self.GS["Location"])
					--print (scene)

					-- Set new operating mode
					self.GS["Mode"] = "Mission";
					self.GS["SceneType"] = "Mission";
					self:SaveCurrentGameState();

					self:LaunchScript(scene, "Tactics.lua");
					self.EnableBrainSelection = false;
					self:DestroyConsoles(); --]]--
					return;
				end
			else
				self.FirePressed[player] = false
			end

			-- Draw background
			if canbeam then
				self:PutGlow("ControlPanel_Beam_Button", pos);
			else
				self:PutGlow("ControlPanel_Beam_ButtonRed", pos);
			end
		end
	end

	if showidle and self.BeamControlPanelPos ~= nil and self.BeamControlPanelActor ~= nil then
		self:PutGlow("ControlPanel_Beam", self.BeamControlPanelPos);
	end

	if MovableMan:IsActor(self.BeamControlPanelActor) then
		self.BeamControlPanelActor.Health = 100;
	end
end
