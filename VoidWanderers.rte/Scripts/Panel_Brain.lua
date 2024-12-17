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
		local act = self:GetControlledActor(player);

		if act and MovableMan:IsActor(act) then
			if act.PresetName == "Brain Case" then
				local cont = act:GetController()
				local pos = act.Pos

				if cont:IsState(Controller.PRESS_DOWN) then
					-- Create faction appropriate brain because we can do that
					local f = self.GS.PlayerFaction;
					local rb = CF.MakeBrainWithPreset(self.GS, CF.PlayerTeam, act.Pos + Vector(0, 20), CF.Brains[f], CF.BrainClasses[f], CF.BrainModules[f])

					if rb then
						rb.PieMenu:AddPieSlice(CreatePieSlice("RPG Brain PDA", "VoidWanderers.rte"), nil)
						rb.Vel = Vector(0, 4)
						rb.AIMode = Actor.AIMODE_SENTRY
						rb.Health = act.Health / act.MaxHealth * rb.MaxHealth

						-- Make this brain's player known
						rb:SetNumberValue("VW_BrainOfPlayer", player + 1)

						-- Give items
						for j = 1, CF.MaxSavedItemsPerActor do
							if self.GS["Brain" .. player .. "Item" .. j .. "Preset"] ~= nil then
								local itm = CF.MakeItem(
									self.GS["Brain" .. player .. "Item" .. j .. "Preset"],
									self.GS["Brain" .. player .. "Item" .. j .. "Class"],
									self.GS["Brain" .. player .. "Item" .. j .. "Module"]
								)

								if itm then
									rb:AddInventoryItem(itm)
								end
							end
						end

						-- Only add to scene after everything is sorted
						MovableMan:AddActor(rb)

						-- Then switch
						rb:AddScript("VoidWanderers.rte/Scripts/Brain.lua")
						rb:EnableScript("VoidWanderers.rte/Scripts/Brain.lua")
						self:SwitchToActor(rb, player, CF.PlayerTeam)
						self:SetPlayerBrain(rb, player)

						-- Then record
						self.GS["Brain" .. player .. "Detached"] = "True"
						self.createdBrainCases[player] = nil
						act.ToDelete = true

						-- Maintain identity only if it was ever determined
						if self.GS["Brain" .. player .. "Identity"] ~= nil then
							rb:SetNumberValue("Identity", tonumber(self.GS["Brain" .. player .. "Identity"]))
						end
					end
				end
				-- Process brain attachment
			elseif act:GetNumberValue("VW_BrainOfPlayer") - 1 ~= Activity.PLAYER_NONE then
				local readytoattach = act.Pos.X > self.BrainPos[player + 1].X - 10
					and act.Pos.X < self.BrainPos[player + 1].X + 10
					and act.Pos.Y > self.BrainPos[player + 1].Y
					and CF.DistUnder(act.Pos, self.BrainPos[player + 1], 100);
					
				local cont = self:GetPlayerController(player);

				if cont:IsState(Controller.PRESS_UP) and readytoattach then
					local rb = CreateActor("Brain Case", "Base.rte")

					if rb then
						rb.Team = CF.PlayerTeam
						rb.Pos = self.BrainPos[player + 1] + Vector(0, 8)
						rb.Health = act.Health/act.MaxHealth * rb.MaxHealth
						rb:SetNumberValue("VW_BrainOfPlayer", player + 1)
						-- Clear inventory
						for j = 1, CF.MaxSavedItemsPerActor do
							self.GS["Brain" .. player .. "Item" .. j .. "Preset"] = nil
							self.GS["Brain" .. player .. "Item" .. j .. "Class"] = nil
							self.GS["Brain" .. player .. "Item" .. j .. "Module"] = nil
						end
						-- Save inventory
						local pre, cls, mdl = CF.GetInventory(act)
						for j = 1, #pre do
							self.GS["Brain" .. player .. "Item" .. j .. "Preset"] = pre[j]
							self.GS["Brain" .. player .. "Item" .. j .. "Class"] = cls[j]
							self.GS["Brain" .. player .. "Item" .. j .. "Module"] = mdl[j]
						end
						self.GS["Brain" .. player .. "Detached"] = "False"
						self.createdBrainCases[player] = rb
						if act.GoldCarried > 0 then
							self:SetTeamFunds(CF.ChangeGold(self.GS, act.GoldCarried), CF.PlayerTeam)
						end

						if self.GS["Brain" .. player .. "Identity"] == nil then
							self.GS["Brain" .. player .. "Identity"] = act:GetNumberValue("Identity")
						end

						act.ToDelete = true

						MovableMan:AddActor(rb)

						--[[local reference = CF.MakeBrain(self.GS, 0, CF.PlayerTeam, act.Pos + Vector(0, 20), false)
						if not reference:IsOrganic() and IsAHuman(reference) then
							local decoHead = CreateAttachable(reference.Head.PresetName)
							decoHead.RotAngle = math.pi
							decoHead.HFlipped = true
							decoHead.IgnoreTerrain = true
							decoHead:EnableDeepCheck(false)
							rb.IgnoreTerrain = true
							rb.Scale = 0
							rb:AddAttachable(decoHead, Vector(0, decoHead:GetSpriteHeight()/2))
						end]]

						self:SwitchToActor(rb, player, CF.PlayerTeam)
						self:SetPlayerBrain(rb, player)
					end
				end
			end
		end
	end
end
