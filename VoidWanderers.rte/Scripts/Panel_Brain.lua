-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:InitBrainControlPanelUI() end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:DestroyBrainControlPanelUI() end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:ProcessBrainControlPanelUI()
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		local actor = self:GetControlledActor(player);

		if actor and MovableMan:IsActor(actor) then
			if actor.PresetName == "Brain Case" then
				local cont = actor:GetController();
				local pos = actor.Pos;

				if cont:IsState(Controller.PRESS_DOWN) then
					local faction = self.GS["PlayerFaction"];
					local brain = CF. MakeBrain(faction, false);

					if brain then
						brain.Pos = actor.Pos + Vector(0, 20);
						brain.Team = Activity.TEAM_1;
						brain.Vel = Vector(0, 4);
						brain.AIMode = Actor.AIMODE_SENTRY;
						brain.Health = actor.Health / actor.MaxHealth * brain.MaxHealth;
						brain.PieMenu:AddPieSlice(CreatePieSlice("RPG Brain PDA", "VoidWanderers.rte"), nil);
						brain:SetNumberValue("VW_BrainOfPlayer", player + 1);

						for j = 1, CF.MaxSavedItemsPerActor do
							if self.GS["Brain" .. player .. "Item" .. j .. "Preset"] ~= nil then
								local item = CF.MakeItem(
									self.GS["Brain" .. player .. "Item" .. j .. "Class"],
									self.GS["Brain" .. player .. "Item" .. j .. "Preset"],
									self.GS["Brain" .. player .. "Item" .. j .. "Module"]
								);

								if item then
									brain:AddInventoryItem(item);
								end
							else
								break;
							end
						end

						-- Only add to scene after everything is sorted
						MovableMan:AddActor(brain);

						-- Then switch
						brain:AddScript("VoidWanderers.rte/Actors/Shared/Brain.lua");
						brain:EnableScript("VoidWanderers.rte/Actors/Shared/Brain.lua");
						self:SwitchToActor(brain, player, CF.PlayerTeam);
						self:SetPlayerBrain(brain, player);

						-- Then record
						self.GS["Brain" .. player .. "Detached"] = "True";
						self.createdBrainCases[player] = nil;
						actor.ToDelete = true;

						-- Maintain identity only if it was ever determined
						if self.GS["Brain" .. player .. "Identity"] ~= nil then
							brain:SetNumberValue("Identity", tonumber(self.GS["Brain" .. player .. "Identity"]));
						end
					end
				end
				-- Process brain attachment
			elseif actor.Team == self.vesselData["team"] and actor:GetNumberValue("VW_BrainOfPlayer") - 1 ~= Activity.PLAYER_NONE then
				local readytoattach = actor.Pos.X > self.BrainPos[player + 1].X - 10
					and actor.Pos.X < self.BrainPos[player + 1].X + 10
					and actor.Pos.Y > self.BrainPos[player + 1].Y
					and CF.Dist(actor.Pos, self.BrainPos[player + 1]) < 100;
					
				local cont = self:GetPlayerController(player);

				if cont:IsState(Controller.PRESS_UP) and readytoattach then
					local brain = CreateActor("Brain Case", "Base.rte")

					if brain then
						brain.Team = CF.PlayerTeam
						brain.Pos = self.BrainPos[player + 1] + Vector(0, 8)
						brain.Health = actor.Health/actor.MaxHealth * brain.MaxHealth
						brain:SetNumberValue("VW_BrainOfPlayer", player + 1)
						-- Clear inventory
						for j = 1, CF.MaxSavedItemsPerActor do
							self.GS["Brain" .. player .. "Item" .. j .. "Preset"] = nil
							self.GS["Brain" .. player .. "Item" .. j .. "Class"] = nil
							self.GS["Brain" .. player .. "Item" .. j .. "Module"] = nil
						end
						-- Save inventory
						local pre, cls, mdl = CF.GetInventory(actor)
						for j = 1, #pre do
							self.GS["Brain" .. player .. "Item" .. j .. "Preset"] = pre[j]
							self.GS["Brain" .. player .. "Item" .. j .. "Class"] = cls[j]
							self.GS["Brain" .. player .. "Item" .. j .. "Module"] = mdl[j]
						end
						self.GS["Brain" .. player .. "Detached"] = "False"
						self.createdBrainCases[player] = brain

						if actor.GoldCarried > 0 then
							CF.ChangePlayerGold(self.GS, actor.GoldCarried);
						end

						if self.GS["Brain" .. player .. "Identity"] == nil then
							self.GS["Brain" .. player .. "Identity"] = actor:GetNumberValue("Identity");
						end

						actor = MovableMan:RemoveActor(actor);
						if actor then
							DeleteEntity(actor);
						end

						MovableMan:AddActor(brain);
						self:SwitchToActor(brain, player, CF.PlayerTeam);
						self:SetPlayerBrain(brain, player);
					end
				end
			end
		end
	end
end
