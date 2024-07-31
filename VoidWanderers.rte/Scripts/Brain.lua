function Create(self)
	-- Set up constants
	self.DistPerPower = 75
	self.CoolDownInterval = 3000
	self.PrintSkills = true

	self.WeaponTeleportEnabled = false
	self.DamageEnabled = false
	self.PushEnabled = false
	self.StealEnabled = false
	self.DistortEnabled = false
	self.ShieldEnabled = false

	self.WeaponTeleportCost = 15
	self.DamageCost = 65
	self.PushCost = 15
	self.StealCost = 30
	self.DistortCost = 25

	self.HealRange = 75

	self.LinkedActors = nil

	self.HoldTimer = Timer()

	-- Find our owner actor
	local found = self:GetParent()

	if found then
		-- Store actor for future use
		if found.ClassName == "AHuman" then
			print("WEre here");
			self.ThisActor = ToAHuman(found)
			--print ("Created: " ..self.ThisActor.PresetName)
		elseif found.ClassName == "ACrab" then
			self.ThisActor = ToACrab(found)
		else
			self.ThisActor = nil
		end
	end

	self.Energy = 100
	self.Timer = Timer()
	self.Timer:Reset()
	self.CoolDownTimer = Timer()
	self.CoolDownTimer:Reset()
	self.RegenTimer = Timer()
	self.RegenTimer:Reset()
	self.BlinkTimer = Timer()
	self.BlinkTimer:Reset()
	self.HealSkillTimer = Timer()
	self.HealSkillTimer:Reset()

	if self.ThisActor then
		self.TelekinesisLvl = 0
		self.ShieldLvl = 0
		self.MaxHealth = 100
		self.RegenInterval = 0
		self.RepairCount = 0
		self.HealCount = 0
		self.SelfHealCount = 0
		self.ScanRange = 0
		self.ScanLevel = 0
		self.QuantumStorage = 0
		self.QuantumCapacity = 0
		self.SplitterLevel = 0

		self.BrainNumber = -1

		-- Fake menu to use by AI brain
		self.ActiveMenu = {}
		self.ActiveMenu[1] = {}
		self.SelectedMenuItem = 1

		-- Calculate actor base power
		local s = self.ThisActor.PresetName
		local pos = string.find(s, "RPG Brain Robot")
		if pos ~= nil and pos == 1 then
			if CF_GS ~= nil and self.ThisActor.Team == 0 then
				--print ("GS")
				local bplr = tonumber(string.sub(s, string.len(s), string.len(s)))
				self.BrainNumber = bplr

				self.TelekinesisLvl = tonumber(CF_GS["Brain" .. bplr .. "Telekinesis"])
				self.ShieldLvl = tonumber(CF_GS["Brain" .. bplr .. "Field"])

				self.MaxHealth = 100 + tonumber(CF_GS["Brain" .. bplr .. "Level"])
				self.RegenInterval = 1500 - tonumber(CF_GS["Brain" .. bplr .. "Level"]) * 10

				self.RepairCount = tonumber(CF_GS["Brain" .. bplr .. "Fix"]) * 3
				self.HealCount = tonumber(CF_GS["Brain" .. bplr .. "Heal"])
				self.SelfHealCount = tonumber(CF_GS["Brain" .. bplr .. "SelfHeal"])
				self.ScanLevel = tonumber(CF_GS["Brain" .. bplr .. "Scanner"])
				self.SplitterLevel = tonumber(CF_GS["Brain" .. bplr .. "Splitter"])
				self.QuantumCapacity = tonumber(CF_GS["Brain" .. bplr .. "QuantumCapacity"])
				self.QuantumCapacity = CF_QuantumCapacityPerLevel + self.QuantumCapacity * CF_QuantumCapacityPerLevel

				-- If skills counters were previosly saved then load their values from config
				if self.BrainNumber > -1 then
					local val = tonumber(c["Brain" .. self.BrainNumber .. "Fix_Count"])
					if val ~= nil then
						self.RepairCount = val
					end

					local val = tonumber(c["Brain" .. self.BrainNumber .. "Heal_Count"])
					if val ~= nil then
						self.HealCount = val
					end

					local val = tonumber(c["Brain" .. self.BrainNumber .. "SelfHeal_Count"])
					if val ~= nil then
						self.SelfHealCount = val
					end

					local val = tonumber(c["Brain" .. self.BrainNumber .. "QuantumStorage"])
					if val ~= nil then
						self.QuantumStorage = val
					end
				end
			else
				--print ("Preset")
				local pos = string.find(s, "SHLD")
				if pos ~= nil then
					self.ShieldLvl = tonumber(string.sub(s, pos + 4, pos + 4))
				end

				local pos = string.find(s, "TLKN")
				if pos ~= nil then
					self.TelekinesisLvl = tonumber(string.sub(s, pos + 4, pos + 4))
				end

				local pos = string.find(s, "HLTH")
				if pos ~= nil then
					local val = (tonumber(string.sub(s, pos + 4, pos + 4)) + 1) * 10

					self.MaxHealth = 100 + val
					self.RegenInterval = 1500 - val * 10
				end

				local pos = string.find(s, "FIXW")
				if pos ~= nil then
					self.RepairCount = tonumber(string.sub(s, pos + 4, pos + 4)) * 3
				end

				local pos = string.find(s, "HEAL")
				if pos ~= nil then
					self.HealCount = tonumber(string.sub(s, pos + 4, pos + 4)) * 2
				end

				local pos = string.find(s, "RGEN")
				if pos ~= nil then
					self.SelfHealCount = tonumber(string.sub(s, pos + 4, pos + 4))
				end

				local pos = string.find(s, "SCAN")
				if pos ~= nil then
					self.ScanLevel = tonumber(string.sub(s, pos + 4, pos + 4))
				end

				local pos = string.find(s, "SPLT")
				if pos ~= nil then
					self.SplitterLevel = tonumber(string.sub(s, pos + 4, pos + 4))
				end

				local pos = string.find(s, "STOR")
				if pos ~= nil then
					self.QuantumStorage = CF_QuantumCapacityPerLevel
						+ tonumber(string.sub(s, pos + 4, pos + 4)) * CF_QuantumCapacityPerLevel
				end

				local pos = string.find(s, "QCAP")
				if pos ~= nil then
					self.QuantumCapacity = CF_QuantumCapacityPerLevel
						+ tonumber(string.sub(s, pos + 4, pos + 4)) * CF_QuantumCapacityPerLevel
				end

				local pos = string.find(s, "::")
				if pos ~= nil then
					self.OriginalPreset = string.sub(s, 1, pos - 1)
				end
			end
		end

		self.ScanEnabled = true
		self.ScanRange = 200 + self.ScanLevel * 160

		self.ThisActor.Health = self.MaxHealth
		local levelRatio = 1 - self.HealCount / 5
		self.healTimer = Timer()
		self.baseHealDelay = 40 + 200 * levelRatio
		self.healIncrementPerTarget = 30 + 150 * levelRatio
		self.healIncrementPerWound = 10 + 50 * levelRatio
		self.healTimer:SetSimTimeLimitMS(self.baseHealDelay)
		self.crossTimer = Timer()
		self.crossTimer:SetSimTimeLimitMS(800)

		self.visual = {}
		self.visual.Colors = { 135, 133, 149, 148, 145, 148, 149, 133 }
		self.visual.CurrentColor = 0
		self.visual.Rotation = 0
		self.visual.RPM = 60
		self.visual.ArcCount = 3

		self.maxHealRange = 50 + self.HealCount * 10
		self.healTargets = {}

		--print (self.ThisActor.PresetName)
		--print ("Shield: "..self.ShieldLvl)
		--print ("Kinesis: "..self.TelekinesisLvl)
		--print ("MaxHealth: "..self.MaxHealth)

		-- Create skills menu
		self.Skills = {}
		local count = 0

		if self.ScanLevel > 0 then
			count = count + 1
			self.Skills[count] = {}

			self.Skills[count]["Text"] = "Toggle scanner"
			self.Skills[count]["Count"] = -1
			self.Skills[count]["Function"] = rpgbrain_skill_scanner

			self.ScannerSkillIndex = count

			if CF_GS["Brain" .. self.BrainNumber .. "ScannerEnabled"] == "true" then
				self.Skills[self.ScannerSkillIndex]["State"] = "On"
				self.ScanEnabled = true
			else
				self.Skills[self.ScannerSkillIndex]["State"] = "Off"
				self.ScanEnabled = false
			end
		end

		if self.RepairCount > 0 then
			count = count + 1
			self.Skills[count] = {}

			self.Skills[count]["Text"] = "Repair weapon"
			self.Skills[count]["Count"] = self.RepairCount
			self.Skills[count]["Function"] = rpgbrain_skill_repair
		end
		--[[
		if self.HealCount > 0 then
			count = count + 1
			self.Skills[count] = {}
			
			self.Skills[count]["Text"] = "Heal unit"
			self.Skills[count]["Count"] = self.HealCount
			self.Skills[count]["Function"] = rpgbrain_skill_healstart
			self.Skills[count]["ActorDetectRange"] = self.HealRange
		end]]
		--

		if self.SelfHealCount > 0 then
			count = count + 1
			self.Skills[count] = {}

			self.Skills[count]["Text"] = "Heal brain"
			self.Skills[count]["Count"] = self.SelfHealCount
			self.Skills[count]["Function"] = rpgbrain_skill_selfhealstart
			self.Skills[count]["ActorDetectRange"] = 0.1
			self.Skills[count]["AffectsBrains"] = true
		end

		if self.SplitterLevel > 0 then
			count = count + 1
			self.Skills[count] = {}

			self.Skills[count]["Text"] = "Nanolyze item"
			self.Skills[count]["Count"] = -1
			self.Skills[count]["Function"] = rpgbrain_skill_split

			self.NanolyzeItem = count

			-- Make quantum sub-menu
			local items = {}

			for i = 1, #CF_QuantumItems do
				local id = CF_QuantumItems[i]

				if c["QuantumItemUnlocked_" .. id] == "True" then
					local n = #arr + 1
					arr[n] = {}
					arr[n]["ID"] = id
					arr[n]["Preset"] = CF_QuantumItmPresets[id]
					arr[n]["Class"] = CF_QuantumItmClasses[id]
					arr[n]["Module"] = CF_QuantumItmModules[id]
					arr[n]["Price"] = math.ceil(CF_QuantumItmPrices[id] / 2)
				end
			end

			self.Quantum = {}
			for i = 1, #items do
				self.Quantum[i] = {}
				self.Quantum[i]["Text"] = items[i]["Preset"]
				self.Quantum[i]["Count"] = items[i]["Price"]

				self.Quantum[i]["ID"] = items[i]["ID"]
				self.Quantum[i]["Preset"] = items[i]["Preset"]
				self.Quantum[i]["Class"] = items[i]["Class"]
				self.Quantum[i]["Module"] = items[i]["Module"]
				self.Quantum[i]["Price"] = items[i]["Price"]

				self.Quantum[i]["Function"] = rpgbrain_skill_synthesize
			end

			local n = #self.Quantum + 1

			self.Quantum[n] = {}
			self.Quantum[n]["Text"] = "BACK"
			self.Quantum[n]["Count"] = -1
			self.Quantum[n]["SubMenu"] = self.Skills

			-- Add synthesizer menu item
			count = count + 1
			self.Skills[count] = {}

			self.Skills[count]["Text"] = "Synthesize item"
			self.Skills[count]["Count"] = self.QuantumStorage
			self.Skills[count]["SubMenu"] = self.Quantum

			self.QuantumStorageItem = count
		end

		if self.ShieldLvl > 0 then
			self.ShieldEnabled = true
		end

		if self.TelekinesisLvl > 0 then
			self.DistortEnabled = true
		end

		if self.TelekinesisLvl > 1 then
			self.PushEnabled = true
		end

		if self.TelekinesisLvl > 2 then
			self.WeaponTeleportEnabled = true
		end

		if self.TelekinesisLvl > 3 then
			self.StealEnabled = true
		end

		if self.TelekinesisLvl > 4 then
			self.DamageEnabled = true
		end

		if self.ShieldEnabled then
			-- Shield variables
			if G_VW_Shields == nil then
				G_VW_Shields = {}
			end
			if G_VW_Active == nil then
				G_VW_Active = {}
			end
			if G_VW_Pressure == nil then
				G_VW_Pressure = {}
			end
			if G_VW_Power == nil then
				G_VW_Power = {}
			end
			if G_VW_Timer == nil then
				G_VW_Timer = Timer()
				G_VW_ThisFrameTime = 0
			end
			if G_VW_DepressureTimer == nil then
				G_VW_DepressureTimer = Timer()
			end

			G_VW_ShieldRadius = 80
			G_VW_ShieldRadiusPerPower = 20
			G_VW_MinVelocity = 10

			local shld = #G_VW_Shields + 1

			G_VW_Shields[shld] = self.ThisActor
			G_VW_Active[shld] = true
			G_VW_Pressure[shld] = 0
			G_VW_Power[shld] = self.ShieldLvl
			G_VW_Switch = 0

			-- Remove inactive shields from the global list
			local shields = {}
			local active = {}
			local pressure = {}
			local power = {}

			local j = 0

			for i = 1, #G_VW_Shields do
				-- Remove shield duplicates
				for ii = 1, i - 1 do
					if MovableMan:IsActor(G_VW_Shields[ii]) and MovableMan:IsActor(G_VW_Shields[i]) then
						if G_VW_Shields[ii].ID == G_VW_Shields[i].ID then
							G_VW_Active[i] = false
						end
					end
				end

				if not MovableMan:IsActor(G_VW_Shields[i]) then
					G_VW_Active[i] = false
				else
					if
						not G_VW_Shields[i]:IsInGroup("Brains")
						or string.find(G_VW_Shields[i].PresetName, "RPG Brain Robot") == nil
					then
						G_VW_Active[i] = false
					end
				end

				-- Remove disabled shields
				if G_VW_Active[i] then
					j = j + 1
					shields[j] = G_VW_Shields[i]
					active[j] = G_VW_Active[i]
					pressure[j] = G_VW_Pressure[i]
					power[j] = G_VW_Power[i]
					--print (shields[j])
				end
			end

			G_VW_Shields = shields
			G_VW_Active = active
			G_VW_Pressure = pressure
			G_VW_Power = power --]]--

			--print ("Shield count: "..#G_VW_Shields)
		end
	else
		--print (self.ThisActor)
	end
end

function Update(self)-- Don't do anything when in edit mode
	if ActivityMan:GetActivity().ActivityState ~= Activity.RUNNING then
		return
	end

	--[[if true then
		return
	end--]]
	--

	if G_VW_Shields ~= nil then
		-- Timers are updated on every sim update
		-- so to find out if it's first run during this sim update we just
		-- get current timer value
		if G_VW_ThisFrameTime ~= G_VW_Timer.ElapsedSimTimeMS then
			G_VW_ThisFrameTime = G_VW_Timer.ElapsedSimTimeMS
			do_rpgbrain_shield()
			--print ("Do "..G_VW_Timer.ElapsedSimTimeMS)
		else
			--print ("Skip "..G_VW_Timer.ElapsedSimTimeMS)
		end
	end
	
	if IsActor(self.ThisActor) then
		self.FullPower = self.TelekinesisLvl

		-- Calculate effective skills distance
		self.EffectiveDistance = self.FullPower * self.DistPerPower

		self.Threat = nil
		local nearestenemydist = 1000000
		local catalysts = 0
		local inhibitors = 0
		local dreadnoughtnearby = false

		-- Search for nearby actors
		for actor in MovableMan.Actors do
			-- Search for friends to amplify power
			if actor.Team ~= self.ThisActor.Team and not actor:IsInGroup("Brains") and actor.Health > 0 then
				-- Search for enemies to find threat
				local dist = SceneMan:ShortestDistance(actor.Pos, self.ThisActor.Pos, true)

				-- Find only nearest enemies
				if dist:MagnitudeIsLessThan(self.EffectiveDistance) and dist:MagnitudeIsLessThan(nearestenemydist) then
					local d = dist.Magnitude
					-- Search for targets only if we have enough power and not recharging
					if self.Energy >= 15 and self.CoolDownTimer:IsPastSimMS(self.CoolDownInterval) then
						local angle = VoidWanderersRPG_GetAngle(self.Pos, actor.Pos)
						local pos = self.Pos + Vector(math.cos(-angle) * 20, math.sin(-angle) * 20)

						-- To improve enemy visibility cast rays across the whole enemy figure
						local offsets = { Vector(0, -15), Vector(0, -7), Vector(0, 0), Vector(0, 7), Vector(0, 15) }

						for i = 1, #offsets do
							local actorpos = pos
							local vectortoactor = actor.Pos + offsets[i] - actorpos
							local moid = SceneMan:CastMORay(
								actorpos,
								vectortoactor,
								self.ThisActor.ID,
								self.ThisActor.Team,
								-1,
								false,
								4
							)
							local mo = MovableMan:GetMOFromID(moid)

							if mo ~= nil then
								if mo.ClassName == "AHuman" then
									self.Threat = ToAHuman(mo)
									nearestenemydist = d
								else
									local mo = MovableMan:GetMOFromID(mo.RootID)
									if mo ~= nil then
										if mo.ClassName == "AHuman" then
											self.Threat = ToAHuman(mo)
											nearestenemydist = d
										end
									end
								end
							end -- if
						end -- for
					end
				end --if d <
			end -- if not brain
		end

		-- Debug, draw selected target
		if self.PrintSkills and MovableMan:IsActor(self.Threat) then
			self.Threat:FlashWhite(25)
		end

		-- Check for applicable skill from closest to farthest
		-- Teleport closest weapon
		if
			self.Energy >= self.WeaponTeleportCost
			and self.WeaponTeleportEnabled
			and self.CoolDownTimer:IsPastSimMS(self.CoolDownInterval)
			and self.ThisActor.EquippedItem == nil
		then
			local nearestitmdist = 1000000
			local nearestitem = nil

			-- Find nearest weapon
			for itm in MovableMan.Items do
				if itm.ClassName == "HDFirearm" and itm.HitsMOs ~= false and not ToHeldDevice(itm).UnPickupable then
					local d = SceneMan:ShortestDistance(itm.Pos, self.ThisActor.Pos, true).Magnitude

					if d < self.EffectiveDistance and d < nearestitmdist then
						nearestitem = itm
						nearestenemydist = d
					end --if d <
				end
			end

			-- Teleport weapon
			if nearestitem ~= nil then
				if self.PrintSkills then
					print("Teleport - " .. tostring(math.ceil(self.FullPower)))
				end

				self.Energy = self.Energy - self.WeaponTeleportCost
				VoidWanderersRPG_AddPsyEffect(self.Pos)
				VoidWanderersRPG_AddPsyEffect(nearestitem.Pos)

				local newitem = nearestitem:Clone()
				if newitem ~= nil then
					self.ThisActor:AddInventoryItem(newitem)
					nearestitem.ToDelete = true
					-- This item will be teleported only on the next sim update, we need to move it far away to avoid grabbing by other psyclones
					nearestitem.Pos = Vector(0, 25000)
				end --]]--
				--self.ThisActor:AddInventoryItem(nearestitem)
				self.CoolDownTimer:Reset()
			end
		end

		-- If we have target then use some skills on it
		if MovableMan:IsActor(self.Threat) then
			-- Damage and gib
			if
				self.Energy >= self.DamageCost
				and nearestenemydist < self.EffectiveDistance * 0.3
				and self.FullPower > 10
				and self.DamageEnabled
				and self.CoolDownTimer:IsPastSimMS(self.CoolDownInterval)
			then
				self.Energy = self.Energy - self.DamageCost

				if self.PrintSkills then
					print("Damage - " .. tostring(math.ceil(self.FullPower)) .. " - " .. self.Threat.PresetName)
				end

				for i = 1, self.FullPower / 4 do
					local pix = CreateMOPixel("Hit particle")
					pix.Pos = self.Threat.Pos + Vector(-2 + math.random(4), -2 + math.random(4))
					pix.Vel = Vector(-2 + math.random(4), -2 + math.random(4))
					MovableMan:AddParticle(pix)
				end

				VoidWanderersRPG_AddPsyEffect(self.Threat.Pos)
				self.DamageThreat = self.Threat
				self.Threat:AddAbsImpulseForce(Vector(0, -6), Vector(0, 0))

				VoidWanderersRPG_AddPsyEffect(self.Pos)
				self.CoolDownTimer:Reset()
			end --]]--

			-- Steal weapon
			if
				self.Energy >= self.StealCost
				and nearestenemydist < self.EffectiveDistance * 0.6
				and self.StealEnabled
				and self.CoolDownTimer:IsPastSimMS(self.CoolDownInterval)
			then
				local weap = self.Threat.EquippedItem

				if weap ~= nil then
					local newweap = VoidWanderersRPG_VW_MakeItem(weap.PresetName, weap.ClassName)
					if newweap ~= nil then
						if self.PrintSkills then
							print("Steal - " .. tostring(math.ceil(self.FullPower)) .. " - " .. self.Threat.PresetName)
						end

						self.Energy = self.Energy - self.StealCost

						-- If enemy holds grenade then explode it
						if newweap.ClassName == "TDExplosive" then
							newweap:GibThis()
						else
							-- Pull wepon otherwise
							newweap.Pos = weap.Pos
							MovableMan:AddItem(newweap)

							local angle, d = VoidWanderersRPG_GetAngle(self.Pos, weap.Pos)
							local vel = Vector(
								-math.cos(-angle) * (2 * self.FullPower),
								-math.sin(-angle) * (2 * self.FullPower)
							)

							newweap.Vel = vel

							VoidWanderersRPG_AddPsyEffect(weap.Pos)
							weap.ToDelete = true
						end

						VoidWanderersRPG_AddPsyEffect(self.Pos)
						self.CoolDownTimer:Reset()
					end
				end
			end --]]--

			-- Push target
			if
				self.Energy >= self.PushCost
				and nearestenemydist < self.EffectiveDistance * 0.8
				and self.PushEnabled
				and self.CoolDownTimer:IsPastSimMS(self.CoolDownInterval)
			then
				local pow = 7.5 * self.FullPower

				if self.PrintSkills then
					print(
						"Push - "
							.. tostring(math.ceil(self.FullPower))
							.. " - "
							.. tostring(math.ceil(pow))
							.. " - "
							.. self.Threat.PresetName
					)
				end

				self.Energy = self.Energy - self.PushCost

				local target = self.Threat.Pos
				local angle, d = VoidWanderersRPG_GetAngle(self.Pos, target)

				-- Apply forces
				self.Threat:AddAbsImpulseForce(Vector(math.cos(-angle) * pow, math.sin(-angle) * pow), Vector(0, 0))

				VoidWanderersRPG_AddPsyEffect(self.Threat.Pos)
				VoidWanderersRPG_AddPsyEffect(self.Pos)
				self.CoolDownTimer:Reset()
			end --]]--

			-- Distort aiming
			if
				self.Energy >= self.DistortCost
				and self.DistortEnabled
				and self.CoolDownTimer:IsPastSimMS(self.CoolDownInterval)
			then
				if self.PrintSkills then
					print("Distort - " .. tostring(math.ceil(self.FullPower)) .. " - " .. self.Threat.PresetName)
				end

				self.Energy = self.Energy - self.DistortCost
				self.AimDistortThreat = self.Threat
				VoidWanderersRPG_AddPsyEffect(self.Pos)
				self.CoolDownTimer:Reset()
			end --]]--
		end

		-- Do distortion
		if MovableMan:IsActor(self.AimDistortThreat) and not self.CoolDownTimer:IsPastSimMS(self.CoolDownInterval) then
			self.AimDistortThreat:GetController():SetState(Controller.AIM_UP, true)

			if self.AimDistortThreat:GetAimAngle(false) < 0.75 then
				self.AimDistortThreat:GetController():SetState(Controller.WEAPON_FIRE, true)
			end
		else
			self.AimDistortThreat = nil
		end

		-- Do distortion after damage
		if MovableMan:IsActor(self.DamageThreat) and not self.CoolDownTimer:IsPastSimMS(self.CoolDownInterval) then
			if self.DamageDistortEnabled then
				self.DamageThreat:GetController():SetState(Controller.BODY_CROUCH, true)
				self.DamageThreat:GetController():SetState(Controller.AIM_DOWN, true)
			end
		else
			self.DamageThreat = nil
		end

		--CF_DrawString(tostring(self.ThisActor:GetAimAngle(true)), self.Pos + Vector(0,-110), 200, 200)
		--CF_DrawString(tostring(math.cos(self.ThisActor:GetAimAngle(false))), self.Pos + Vector(0,-100), 200, 200)
		--CF_DrawString(tostring(math.floor(self.ThisActor:GetAimAngle(true) * (180 / 3.14))), self.Pos + Vector(0,-90), 200, 200)

		-- Update state
		if self.Timer:IsPastSimMS(250) then
			-- Add power
			if self.Energy < 100 then
				self.Energy = self.Energy + self.FullPower * 0.1

				if self.Energy > 100 then
					self.Energy = 100
				end
			end

			self.Timer:Reset()
		end

		if self.RegenInterval > 0 and self.MaxHealth > 100 and self.RegenTimer:IsPastSimMS(self.RegenInterval) then
			if self.ThisActor.Health < self.MaxHealth then
				self.ThisActor.Health = self.ThisActor.Health + 1
			end
			self.RegenTimer:Reset()
		end

		-- Draw power marker
		if self.TelekinesisLvl > 0 then
			local glownum = math.ceil(self.FullPower * 2 * (self.Energy / 100))

			if glownum > 10 then
				glownum = 10
			end

			if glownum > 0 then
				VoidWanderersRPG_AddEffect(self.Pos, "Purple Glow " .. glownum)
			end
		end

		if CF_DrawString ~= nil and self.PrintSkills then
			CF_DrawString("E " .. math.floor(self.Energy), self.Pos + Vector(0, -50), 200, 200)
			CF_DrawString("P " .. self.FullPower, self.Pos + Vector(0, -40), 200, 200)
		end

		-- Process scanner
		if self.ScanLevel > 0 and self.ScanEnabled then
			for actor in MovableMan.Actors do
				if actor.ClassName ~= "ADoor" and actor.ClassName ~= "Actor" and actor.ID ~= self.ThisActor.ID then
					local d = CF_Dist(actor.Pos, self.Pos)

					if d < self.ScanRange then
						local a = VoidWanderersRPG_GetAngle(self.Pos, actor.Pos)
						local relpos = Vector(math.cos(-a) * (20 + (d * 0.1)), math.sin(-a) * (20 + (d * 0.1)))

						local effect = "Blue Glow"

						if actor.Team ~= self.ThisActor.Team then
							local pos = self.Pos + Vector(math.cos(-a) * 20, math.sin(-a) * 20)
							local actorpos = pos

							effect = "Yellow Glow"

							local offsets = { Vector(0, -15), Vector(0, -7), Vector(0, 0), Vector(0, 7), Vector(0, 15) }
							for i = 1, #offsets do
								local vectortoactor = actor.Pos + offsets[i] - actorpos
								local outv = Vector(0, 0)

								if not SceneMan:CastStrengthRay(actorpos, vectortoactor, 1, outv, 6, -1, true) then
									effect = "Red Glow"
									break
								end
							end
						end

						VoidWanderersRPG_AddEffect(self.Pos + relpos, effect) --]]--
					end
				end
			end

			-- Show eye pos
			local a = VoidWanderersRPG_GetAngle(self.Pos, self.ThisActor.ViewPoint)
			local d = CF_Dist(self.ThisActor.ViewPoint, self.Pos)
			local relpos = Vector(math.cos(-a) * (20 + (d * 0.1)), math.sin(-a) * (20 + (d * 0.1)))
			local effect = "Green Glow"

			VoidWanderersRPG_AddEffect(self.Pos + relpos, effect)
		end

		-- Process PDA input
		if self.ThisActor:IsPlayerControlled() then
			print("help")
			if CF_PDAInitiator ~= nil and CF_PDAInitiator.ID == self.ThisActor.ID then
				-- Enable PDA only if we're not flying or something
				if self.PDAEnabled then
					self.PDAEnabled = false
				else
					if self.ThisActor.Vel:MagnitudeIsLessThan(3) then
						self.PDAEnabled = true
					end
				end
				CF_PDAInitiator = nil
				self.SelectedMenuItem = 1
				self.PinPoint = Vector(self.ThisActor.Pos.X, self.ThisActor.Pos.Y)
				self.ActiveMenu = self.Skills
			end
		else
			self.PDAEnabled = false
			if self.LinkedActors ~= nil then
				for i = 1, #self.LinkedActors do
					if MovableMan:IsActor(self.LinkedActors[i]) then
						self.LinkedActors[i]:SetControllerMode(Controller.CIM_AI, -1)
					end
				end
			end
			self.LinkedActors = nil
		end

		if self.PDAEnabled then
			do_rpgbrain_pda(self)
		end

		-- Process healing skill activation
		if self.HealCount > 0 then
			--Visualize heal range
			local healRange = self.maxHealRange
			if #self.healTargets > 0 then
				local screen = ActivityMan:GetActivity():ScreenOfPlayer(self.ThisActor:GetController().Player)
				if screen ~= -1 then
					self.visual.Rotation = self.visual.Rotation - self.visual.RPM / (TimerMan.DeltaTimeMS * 0.5)
					local color = self.visual.Colors[self.visual.CurrentColor]
					local angleSize = 180 / self.visual.ArcCount
					for i = 0, self.visual.ArcCount - 1 do
						local arcThin = i * 360 / self.visual.ArcCount + self.visual.Rotation
						local arcThick = arcThin + angleSize * 0.1
						PrimitiveMan:DrawArcPrimitive(
							self.Pos,
							arcThick,
							arcThick + angleSize * 0.8,
							healRange,
							color,
							2
						)
						PrimitiveMan:DrawArcPrimitive(self.Pos, arcThin, arcThin + angleSize, healRange, color, 1)
					end
				end
			end
			if self.healTimer:IsPastSimTimeLimit() then
				self.visual.CurrentColor = self.visual.CurrentColor % #self.visual.Colors + 1
				self.healTimer:Reset()
				for _, healTarget in pairs(self.healTargets) do
					if
						healTarget
						and IsActor(healTarget)
						and (healTarget.Health < healTarget.MaxHealth or healTarget.WoundCount > 0)
						and healTarget.Vel.Largest < 10
					then
						local trace = SceneMan:ShortestDistance(self.Pos, healTarget.Pos, false)
						if
							(trace.Magnitude - healTarget.Radius) < healRange
							and SceneMan:CastObstacleRay(
									self.Pos,
									trace,
									Vector(),
									Vector(),
									self.ThisActor.ID,
									self.ThisActor.IgnoresWhichTeam,
									rte.grassID,
									5
								)
								< 0
						then
							healTarget.Health = math.min(healTarget.Health + 1, healTarget.MaxHealth)
							if self.crossTimer:IsPastSimTimeLimit() then
								local cross = CreateMOSParticle("Particle Heal Effect", "Base.rte")
								if cross then
									cross.Pos = healTarget.AboveHUDPos + Vector(0, 4)
									MovableMan:AddParticle(cross)
								end
								healTarget:RemoveWounds(1)
							end
						end
					end
				end
				if self.crossTimer:IsPastSimTimeLimit() then
					self.crossTimer:Reset()
				end
				self.healTargets = {}
				for actor in MovableMan.Actors do
					if
						actor.Team == self.ThisActor.Team
						and actor.ID ~= self.ThisActor.ID
						and (actor.Health < actor.MaxHealth or actor.WoundCount > 0)
						and actor.Vel.Largest < 5
					then
						local trace = SceneMan:ShortestDistance(self.Pos, actor.Pos, false)
						if (trace.Magnitude - actor.Radius) < (healRange * 0.9) then
							if
								SceneMan:CastObstacleRay(
									self.Pos,
									trace,
									Vector(),
									Vector(),
									self.ThisActor.ID,
									self.ThisActor.IgnoresWhichTeam,
									rte.airID,
									3
								) < 0
							then
								table.insert(self.healTargets, actor)
							end
						end
					end
				end
				self.healTimer:SetSimTimeLimitMS(
					self.baseHealDelay
						+ (self.healIncrementPerWound * self.WoundCount)
						+ (#self.healTargets * self.healIncrementPerTarget)
				)
			end
		end
		--
		if self.HealTarget ~= nil then
			if self.HealSkillTimer:IsPastSimMS(6000) then
				rpgbrain_skill_healend(self)
			else
				swarm_update(self)
			end
		else
			swarm_destroy(self)
		end
		--
		-- Process AI skill usage
		if self.ThisActor.Team ~= 0 then
			-- Heal itself
			if self.ThisActor.Health < 40 and self.HealTarget == nil then
				self.SkillTargetActor = self.ThisActor
				rpgbrain_skill_selfhealstart(self)
			end

			--[[ Heal nearby actors
			if self.HealTarget == nil then
				local a = nil
				local dist = self.HealRange
				local hlth = 40

				for actor in MovableMan.Actors do
					if actor.Team == self.ThisActor.Team and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
						local d = CF_Dist(self.ThisActor.Pos, actor.Pos)
						if d <= dist then
							if actor.Health < hlth then
								a = actor;
								dist = d
								hlth = actor.Health
							end
						end
					end
				end
				
				if a ~= nil then
					self.SkillTargetActor = a
					rpgbrain_skill_healstart(self)
				end
			end]]
			--
		end
	end
end

function Destroy(self)
	swarm_destroy(self)
end

function OnMessage(message, context)
	if "RPGBrain_State_Request_Fulfill" == message then
		
	end
end

function RequestInfoTable()
	
end

function ExportInfoTable()
	
end

function VoidWanderersRPG_AddEffect(pos, preset)
	local pix = CreateMOPixel(preset, "VoidWanderers.rte")
	pix.Pos = pos
	MovableMan:AddParticle(pix)
end

function VoidWanderersRPG_AddPsyEffect(pos)
	local pix = CreateMOPixel("Huge Glow")
	pix.Pos = pos
	MovableMan:AddParticle(pix)
end

function VoidWanderersRPG_VW_MakeItem(item, class)
	if class == "HeldDevice" then
		return CreateHeldDevice(item)
	elseif class == "HDFirearm" then
		return CreateHDFirearm(item)
	elseif class == "TDExplosive" then
		return CreateTDExplosive(item)
	elseif class == "ThrownDevice" then
		return CreateThrownDevice(item)
	end

	return nil
end

function VoidWanderersRPG_GetAngle(from, to)
	local b = to.X - from.X
	local a = to.Y - from.Y
	local c = SceneMan:ShortestDistance(from, to, true).Magnitude

	local cosa = (b * b + c * c - a * a) / (2 * b * c)
	local angle = math.acos(cosa)

	if from.X > to.X and from.Y > to.Y then
		angle = angle
	elseif from.X < to.X and from.Y > to.Y then
		angle = angle --
	elseif from.X < to.X and from.Y < to.Y then
		angle = -angle
	elseif from.X > to.X and from.Y < to.Y then
		angle = 2 * math.pi - angle --
	end

	return angle, c, cosa
end

function do_rpgbrain_shield()
	local radius = 0
	local dist = Vector()
	local glownum = 0
	local s
	local pr

	local rads = {}
	local shields = {}
	local active = {}
	local pressure = {}
	local n = 0

	local depressure = false
	-- Looks like global timers will show negative values, generated during previous activty run or something
	if G_VW_DepressureTimer.ElapsedSimTimeMS < 0 then
		G_VW_DepressureTimer:Reset()
	end

	if G_VW_DepressureTimer:IsPastSimMS(25) then
		depressure = true
		G_VW_DepressureTimer:Reset()
	end

	for i = 1, #G_VW_Active do
		if G_VW_Active[i] and MovableMan:IsActor(G_VW_Shields[i]) and G_VW_Shields[i].Health > 0 then
			n = #shields + 1

			shields[n] = G_VW_Shields[i]
			active[n] = true

			rads[n] = (G_VW_ShieldRadius + (G_VW_Power[i] - 1) * G_VW_ShieldRadiusPerPower) - (G_VW_Pressure[i] * 0.1)

			if rads[n] < 0 then
				rads[n] = 0
			end

			if G_VW_Pressure[i] > 7 then
				if rads[n] > 5 then
					for i = 1, 4 do
						local a = math.random(360) / (180 / math.pi)
						--a = 0 / (180 / math.pi)
						local pos = shields[n].Pos + Vector(math.cos(a) * rads[n], math.sin(a) * rads[n])
						if SceneMan:GetTerrMatter(pos.X, pos.Y) == 0 then
							VoidWanderersRPG_AddEffect(pos, "Purple Glow 1")
						end
					end
				else
					local a = math.random(360) / (180 / math.pi)
					local r = math.random(50)
					local pos = shields[n].Pos + Vector(math.cos(a) * r, math.sin(a) * r)
					if SceneMan:GetTerrMatter(pos.X, pos.Y) == 0 then
						VoidWanderersRPG_AddEffect(pos, "Purple Glow 1")
					end
				end
			end

			pressure[n] = G_VW_Pressure[i]
			if depressure then
				pressure[n] = G_VW_Pressure[i] - 3 * G_VW_Power[i]
				if pressure[n] < 0 then
					pressure[n] = 0
				end
			end
			--pressure[n] = 15000

			--CF_DrawString(tostring(math.ceil(G_VW_Pressure[i])), shields[n].Pos + Vector(0,-50), 200, 200)
		else
			G_VW_Active[i] = false
		end
	end

	G_VW_Shields = shields
	G_VW_Active = active
	G_VW_Pressure = pressure

	local massindex

	G_VW_Switch = G_VW_Switch == 0 and 1 or 0

	-- Weaker shields take more pressure from incoming projectiles
	local massindex = {}
	for i = 1, #G_VW_Shields do
		massindex[i] = 1 + ((6 - G_VW_Power[i]) * 0.20)
	end

	local effectcount = 0
	for i = 1, #G_VW_Shields do
		if G_VW_Active[i] then
			radius = rads[i]
			if radius > 5 then
				s = G_VW_Shields[i]
				for p in MovableMan:GetMOsInRadius(s.Pos, radius, G_VW_Shields[i].Team, false) do
					if p.HitsMOs and p.Vel:MagnitudeIsGreaterThan(G_VW_MinVelocity) then
						pr = G_VW_Pressure[i]
						dist = SceneMan:ShortestDistance(s.Pos, p.Pos, SceneMan.SceneWrapsX)
						if dist:MagnitudeIsGreaterThan(radius * 0.1) then
							pr = pr + ((p.Mass * massindex[i]) * p.Vel.Magnitude)

							if effectcount < 10 then
								glownum = math.min(math.floor(p.Vel.Magnitude * 0.1), 20)

								if glownum >= 1 then
									VoidWanderersRPG_AddEffect(p.Pos, "Purple Glow " .. tostring(glownum))
									effectcount = effectcount + 1
								end
							end

							p.Vel = Vector(p.Vel.X * 0.1, p.Vel.Y * 0.1)
								+ Vector(dist.X, dist.Y):SetMagnitude(1 + p.Vel.Magnitude * 0.5)
						end
						G_VW_Pressure[i] = pr
					end
				end
			end
		end
	end
end

function do_rpgbrain_pda(self)
	self.ThisActor.Vel = Vector(0, 0)
	self.ThisActor.Pos = self.PinPoint

	--local pos = self.ThisActor.Pos + Vector(0,-34)
	local pos = self.ThisActor.Pos + Vector(0, -130)

	self.SkillTargetActor = nil
	self.SkillTargetActors = nil

	-- Detect nearby target actor
	if #self.ActiveMenu > 0 and self.ActiveMenu[self.SelectedMenuItem]["ActorDetectRange"] ~= nil then
		if
			self.ActiveMenu[self.SelectedMenuItem]["DetectAllActors"] == nil
			or self.ActiveMenu[self.SelectedMenuItem]["DetectAllActors"] == false
		then
			local dist = self.ActiveMenu[self.SelectedMenuItem]["ActorDetectRange"]
			local a = nil

			for actor in MovableMan.Actors do
				local brainonly = false

				if
					self.ActiveMenu[self.SelectedMenuItem]["AffectsBrains"] ~= nil
					and self.ActiveMenu[self.SelectedMenuItem]["AffectsBrains"] == true
				then
					brainonly = true
				end

				local acceptable = true

				if brainonly then
					if actor:IsInGroup("Brains") then
						acceptable = true
					else
						acceptable = false
					end
				else
					if actor:IsInGroup("Brains") then
						acceptable = false
					else
						acceptable = true
					end
				end

				if
					actor.Team == self.ThisActor.Team
					and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
					and acceptable
				then
					local d = CF_Dist(self.ThisActor.Pos, actor.Pos)
					if d <= dist then
						a = actor
						dist = d
					end
				end
			end

			if a ~= nil then
				self.SkillTargetActor = a

				if self.BlinkTimer:IsPastSimMS(500) then
					self.SkillTargetActor:FlashWhite(25)
					self.BlinkTimer:Reset()
				end
			end
		else
			self.SkillTargetActors = {}

			local dist = self.ActiveMenu[self.SelectedMenuItem]["ActorDetectRange"]
			local a = nil

			for actor in MovableMan.Actors do
				local brainonly = false

				if
					self.ActiveMenu[self.SelectedMenuItem]["AffectsBrains"] ~= nil
					and self.ActiveMenu[self.SelectedMenuItem]["AffectsBrains"] == true
				then
					brainonly = true
				end

				local acceptable = true

				if brainonly then
					if actor:IsInGroup("Brains") then
						acceptable = true
					else
						acceptable = false
					end
				else
					if actor:IsInGroup("Brains") then
						acceptable = false
					else
						acceptable = true
					end
				end

				if
					actor.Team == self.ThisActor.Team
					and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
					and acceptable
				then
					local d = CF_Dist(self.ThisActor.Pos, actor.Pos)
					if d <= dist then
						self.SkillTargetActors[#self.SkillTargetActors + 1] = actor
					end
				end
			end

			if self.BlinkTimer:IsPastSimMS(500) then
				self.BlinkTimer:Reset()
				for i = 1, #self.SkillTargetActors do
					self.SkillTargetActors[i]:FlashWhite(25)
				end
			end
		end
	end

	local cont = self.ThisActor:GetController()
	local plr = cont.GetPlayer()
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
		cont:SetState(Controller.PRESS_UP, false)
		cont:SetState(Controller.MOVE_UP, false)
		cont:SetState(Controller.BODY_JUMPSTART, false)
		cont:SetState(Controller.BODY_JUMP, false)

		self.SelectedMenuItem = self.SelectedMenuItem - 1
		if self.SelectedMenuItem < 1 then
			self.SelectedMenuItem = #self.ActiveMenu
		end
	end

	if down then
		cont:SetState(Controller.PRESS_DOWN, false)
		cont:SetState(Controller.MOVE_DOWN, false)
		cont:SetState(Controller.BODY_CROUCH, false)

		self.SelectedMenuItem = self.SelectedMenuItem + 1
		if self.SelectedMenuItem > #self.ActiveMenu then
			self.SelectedMenuItem = 1
		end
	end

	self.MenuItemsListStart = self.SelectedMenuItem - (self.SelectedMenuItem - 1) % 6

	-- Show price if item will be nanolyzed
	if self.NanolyzeItem ~= nil then
		self.Skills[self.NanolyzeItem]["Count"] = "EMPTY"

		if self.ThisActor.EquippedItem ~= nil then
			local mass = self.ThisActor.EquippedItem.Mass
			local convert = self.SplitterLevel * CF_QuantumSplitterEffectiveness
			local matter = math.floor(mass * convert)

			if self.QuantumStorage + matter > self.QuantumCapacity then
				matter = self.QuantumCapacity - self.QuantumStorage
			end
			self.Skills[self.NanolyzeItem]["Count"] = "+" .. matter

			if self.QuantumStorage == self.QuantumCapacity then
				self.Skills[self.NanolyzeItem]["Count"] = "MAX"
			end
		end
	end

	-- Draw background
	VoidWanderersRPG_AddEffect(pos + Vector(0, 27), "ControlPanel_Skills")

	-- Draw skills menu
	if self.ActiveMenu == nil or #self.ActiveMenu == 0 then
		local s = "NO SKILLS"
		local l = CF_GetStringPixelWidth(s)

		CF_DrawString(s, pos + Vector(-l / 2, 2), 100, 8)
	else
		for i = self.MenuItemsListStart, self.MenuItemsListStart + 6 - 1 do
			if i <= #self.ActiveMenu then
				local s = self.ActiveMenu[i]["Text"]

				if self.ActiveMenu[i]["Count"] ~= nil and self.ActiveMenu[i]["Count"] ~= -1 then
					s = s .. " " .. self.ActiveMenu[i]["Count"]
				end

				if self.ActiveMenu[i]["State"] ~= nil then
					s = s .. " [ " .. self.ActiveMenu[i]["State"] .. " ]"
				end

				if i == self.SelectedMenuItem then
					CF_DrawString("> " .. s, pos + Vector(-50, (i - self.MenuItemsListStart) * 10), 150, 8)
				else
					CF_DrawString(s, pos + Vector(-50, (i - self.MenuItemsListStart) * 10), 150, 8)
				end
			end
		end --]]--
	end

	if cont:IsState(Controller.WEAPON_FIRE) then
		cont:SetState(Controller.WEAPON_FIRE, false)

		if not self.FirePressed[plr] then
			self.FirePressed[plr] = true

			-- Execute skill function
			if self.ActiveMenu[self.SelectedMenuItem]["Function"] ~= nil then
				self.ActiveMenu[self.SelectedMenuItem]["Function"](self)
			end

			if self.ActiveMenu[self.SelectedMenuItem]["SubMenu"] ~= nil then
				self.ActiveMenu = self.ActiveMenu[self.SelectedMenuItem]["SubMenu"]
				self.SelectedMenuItem = 1
			end
		end
	else
		self.FirePressed[plr] = false
	end
end
--[[
function rpgbrain_skill_healstart(self)
	if self.HealCount > 0 and self.HealTarget == nil then
		if self.SkillTargetActor ~= nil and MovableMan:IsActor(self.SkillTargetActor) and self.SkillTargetActor.Health > 0 then
			self.HealTarget = self.SkillTargetActor
			self.HealSkillTimer:Reset()
			swarm_create(self, self.HealTarget)
			
			self.HealCount = self.HealCount - 1
			self.ActiveMenu[self.SelectedMenuItem]["Count"] = self.HealCount
			CF_SaveThisBrainSupplies(CF_GS, self)
		end
	end
end
]]
--
function rpgbrain_skill_selfhealstart(self)
	if self.SelfHealCount > 0 and self.HealTarget == nil then
		if
			self.SkillTargetActor ~= nil
			and MovableMan:IsActor(self.SkillTargetActor)
			and self.SkillTargetActor.Health > 0
		then
			self.HealTarget = self.SkillTargetActor
			self.HealSkillTimer:Reset()
			swarm_create(self, self.HealTarget)

			self.SelfHealCount = self.SelfHealCount - 1
			self.ActiveMenu[self.SelectedMenuItem]["Count"] = self.SelfHealCount
			CF_SaveThisBrainSupplies(CF_GS, self)
		end
	end
end

function rpgbrain_skill_healend(self)
	if self.HealTarget ~= nil and MovableMan:IsActor(self.HealTarget) and self.HealTarget.Health > 0 then
		local presets, classes, modules
		if self.HealTarget.ClassName == "AHuman" then
			presets, classes, modules = CF_GetInventory(self.HealTarget)
		end
		local preset = self.HealTarget.PresetName
		local oldpreset = self.HealTarget.PresetName

		if self.HealTarget:IsInGroup("Brains") and self.OriginalPreset ~= nil then
			preset = self.OriginalPreset
		end

		--print (self.OriginalPreset)
		--print (oldpreset)

		local actor = CF_MakeActor(
			preset,
			self.HealTarget.ClassName,
			self.HealTarget.ModuleName,
			self.HealTarget:GetNumberValue("VW_XP"),
			self.HealTarget:GetNumberValue("Identity"),
			self.HealTarget:GetNumberValue("VW_Prestige"),
			self.HealTarget:GetStringValue("VW_Name"),
			{}
		)
		if actor then
			actor.PresetName = oldpreset
			actor.Team = self.ThisActor.Team
			actor.AIMode = self.HealTarget.AIMode

			if actor.ClassName == "AHuman" then
				for i = 1, #presets do
					local itm = CF_MakeItem(presets[i], classes[i], modules[i])
					if itm then
						actor:AddInventoryItem(itm)
					end
				end
			end

			actor.Pos = Vector(self.HealTarget.Pos.X, self.HealTarget.Pos.Y)
			MovableMan:AddActor(actor)
		end
		self.HealTarget.Pos = Vector(0, -1000)
		self.HealTarget.ToDelete = true
		self.HealTarget = nil
	end
	swarm_destroy(self)
end

function rpgbrain_skill_repair(self)
	if self.RepairCount > 0 then
		if self.ThisActor.EquippedItem ~= nil then
			local preset = self.ThisActor.EquippedItem.PresetName
			local class = self.ThisActor.EquippedItem.ClassName
			local module = self.ThisActor.EquippedItem.ModuleName

			self.ThisActor.EquippedItem.ToDelete = true

			local newgun = CF_MakeItem(preset, class, module)
			if newgun then
				self.ThisActor:AddInventoryItem(newgun)
				self.ThisActor:GetController():SetState(Controller.WEAPON_CHANGE_PREV, true)
			end

			self.RepairCount = self.RepairCount - 1
			self.ActiveMenu[self.SelectedMenuItem]["Count"] = self.RepairCount
			CF_SaveThisBrainSupplies(CF_GS, self)
		end
	end
end

function rpgbrain_skill_split(self)
	if self.ThisActor.EquippedItem ~= nil then
		if self.QuantumStorage < self.QuantumCapacity then
			local mass = self.ThisActor.EquippedItem.Mass
			local convert = self.SplitterLevel * CF_QuantumSplitterEffectiveness
			local matter = math.floor(mass * convert)

			self.QuantumStorage = self.QuantumStorage + matter
			if self.QuantumStorage > self.QuantumCapacity then
				self.QuantumStorage = self.QuantumCapacity
			end

			self.Skills[self.QuantumStorageItem]["Count"] = self.QuantumStorage
			CF_SaveThisBrainSupplies(CF_GS, self)

			self.ThisActor.EquippedItem.ToDelete = true
			self.ThisActor:GetController():SetState(Controller.WEAPON_CHANGE_PREV, true)
		end
	end
end

function rpgbrain_skill_synthesize(self)
	if self.QuantumStorage >= self.ActiveMenu[self.SelectedMenuItem]["Price"] then
		local preset = self.ActiveMenu[self.SelectedMenuItem]["Preset"]
		local class = self.ActiveMenu[self.SelectedMenuItem]["Class"]
		local module = self.ActiveMenu[self.SelectedMenuItem]["Module"]

		local newgun = CF_MakeItem(preset, class, module)
		if newgun then
			self.ThisActor:AddInventoryItem(newgun)
			self.ThisActor:GetController():SetState(Controller.WEAPON_CHANGE_PREV, true)
		end

		self.QuantumStorage = self.QuantumStorage - self.ActiveMenu[self.SelectedMenuItem]["Price"]
		self.Skills[self.QuantumStorageItem]["Count"] = self.QuantumStorage
		CF_SaveThisBrainSupplies(CF_GS, self)
	end
end

function rpgbrain_skill_scanner(self)
	self.ScanEnabled = not self.ScanEnabled

	if CF_GS["Brain" .. self.BrainNumber .. "ScannerEnabled"] == "true" then
		CF_GS["Brain" .. self.BrainNumber .. "ScannerEnabled"] = "false"
	else
		CF_GS["Brain" .. self.BrainNumber .. "ScannerEnabled"] = "true"
	end

	if CF_GS["Brain" .. self.BrainNumber .. "ScannerEnabled"] == "true" then
		self.Skills[self.ScannerSkillIndex]["State"] = "On"
	else
		self.Skills[self.ScannerSkillIndex]["State"] = "Off"
	end
end

function swarm_swarmto(object, target, speed)
	local baseVector = SceneMan:ShortestDistance(object.Pos, target, true)
	local dirVector = baseVector / baseVector.Largest
	local dist = baseVector.Magnitude
	local modifier = dist / 5
	if modifier < 1 then
		modifier = 1
	end

	object.Vel = object.Vel + dirVector * speed * modifier
end

function swarm_create(self, target)
	--The initial number of wasps.
	self.waspNum = 25

	--The chance of stinging.
	self.stingChance = 0.015

	--The change of dying while stinging.
	self.stingDieChance = 0.1

	--The chance of flickering.
	self.flickerChance = 0.2

	--Speed of the sting particle.
	self.stingSpeed = 25

	--How long it takes for one wasp to die off.
	self.dieTime = 500

	--How high to go while idling, maximum.
	self.maxIdleAlt = 100

	--How low to go while idling, minimum.
	self.minIdleAlt = 25

	--The radius of the swarm.
	self.swarmRad = 15

	--The maximum speed for one wasp.
	self.maxSpeed = 5

	--The modifier for maximum speed when attacking.
	self.attackMaxMod = 5

	--The basic acceleration for one wasp.
	self.baseAcc = 0.75

	--The modifier for acceleration when attacking.
	self.attackAccMod = 2

	--The acceleration speed of the base swarm.
	self.swarmSpeed = 1

	--The maximum speed of the base swarm.
	self.maxBaseSpeed = 15

	--The air reistance on the base swarm.
	self.airResistance = 1.1

	--The maximum distance a wasp can be from the swarm.
	self.maxDist = 75

	--The maximum distance to target at.
	self.targetDist = 500

	--The maximum distance to attack at.
	self.attackDist = 75

	--The maximum strength the swarm can push through.
	self.maxMoveStrength = 1

	--The list of wasps in this swarm.
	self.roster = {}

	--The list of offsets for each wasp.
	self.offsets = {}

	--The target to attack.
	self.target = target

	--Timer for wasp death.
	--self.dieTimer = Timer();

	--Garbage collection timer.
	self.garbTimer = Timer()

	--Fill the list.
	for i = 1, self.waspNum do
		local wasp = CreateMOPixel("Techion.rte/Nanowasp " .. math.random(1, 3))
		wasp.Vel = Vector(math.random(-10, 10), math.random(-10, 10))
		self.offsets[i] = Vector(math.random(-self.swarmRad, self.swarmRad), math.random(-self.swarmRad, self.swarmRad))
		wasp.Pos = self.Pos + self.offsets[i]
		MovableMan:AddParticle(wasp)
		self.roster[i] = wasp
	end
end

function swarm_update(self)
	--Move the swarm.
	local moving = false
	local attacking = false

	if MovableMan:IsActor(self.target) then
		--Go after the target.
		if
			not SceneMan:CastStrengthRay(
				self.Pos,
				SceneMan:ShortestDistance(self.Pos, self.target.Pos, true),
				self.maxMoveStrength,
				Vector(),
				5,
				0,
				true
			)
		then
			local dirVec = SceneMan:ShortestDistance(self.Pos, self.target.Pos, true)
			local movement = (dirVec / dirVec.Largest) * self.maxBaseSpeed

			self.Vel = self.Vel + movement

			if movement.Largest ~= 0 then
				moving = true
			end
		else
			target = nil
		end
	else
		target = nil
	end

	if not moving then
		self.Vel = self.Vel / self.airResistance
	end

	if self.Vel.Largest > self.maxBaseSpeed then
		self.Vel = (self.Vel / self.Vel.Largest) * self.maxBaseSpeed
	end

	--Check if the swarm is about to run into a wall, and if it is, stop it.
	if SceneMan:CastStrengthRay(self.Pos, self.Vel, self.maxMoveStrength, Vector(), 0, 0, true) then
		self.Vel = Vector(0, 0)
	end

	--Attack.
	local attackMax = 1
	local attackAcc = 1

	if attacking then
		attackMax = self.attackMaxMod
		attackAcc = self.attackAccMod
	end

	--Make all the wasps in this swarm's roster follow it.
	if MovableMan:IsActor(self.target) then
		for i = 1, #self.roster do
			if MovableMan:IsParticle(self.roster[i]) then
				local wasp = self.roster[i]

				--Keep the wasp alive.
				wasp.ToDelete = false
				wasp.ToSettle = false
				wasp:NotResting()
				wasp.Age = 0

				--Make the wasp follow the swarm.
				local target = self.target.Pos + self.offsets[i]
				swarm_swarmto(wasp, target, math.random() * self.baseAcc * attackAcc)

				--Keep the wasp from going too fast.
				local speedMod = SceneMan:ShortestDistance(wasp.Pos, target, true).Magnitude / 5
				if speedMod < 1 then
					speedMod = 1
				end

				--Counteract gravity.
				wasp.Vel.Y = wasp.Vel.Y - SceneMan.Scene.GlobalAcc.Y * TimerMan.DeltaTimeSecs

				if wasp.Vel.Largest > self.maxSpeed * speedMod * attackMax then
					wasp.Vel = (wasp.Vel / wasp.Vel.Largest) * self.maxSpeed * speedMod * attackMax
				end

				--Keep the wasp within decent bounds of the swarm.
				local distVec = SceneMan:ShortestDistance(target, wasp.Pos, true)

				if math.abs(distVec.Largest) > self.maxDist then
					wasp.Pos = distVec:SetMagnitude(self.maxDist) + target
				end

				--Flicker.
				if math.random() <= self.flickerChance then
					local flicker = CreateMOPixel("Techion.rte/Nanowasp Flicker")
					flicker.Pos = wasp.Pos
					MovableMan:AddParticle(flicker)
				end
			else
				if #self.roster < self.waspNum then
					--Replace the wasp.
					local wasp = CreateMOPixel("Techion.rte/Nanowasp " .. math.random(1, 3))
					wasp.Pos = self.Pos + self.offsets[i]
					wasp.Vel = Vector(math.random(-10, 10), math.random(-10, 10))
					MovableMan:AddParticle(wasp)
					self.roster[i] = wasp
				else
					table.remove(self.roster, i)
				end
			end
		end
	else
		self.ToDelete = true
	end

	if self.garbTimer:IsPastSimMS(10000) then
		collectgarbage("collect")
		self.garbTimer:Reset()
	end

	if self.waspNum > 0 then
		self.ToDelete = false
		self.ToSettle = false
		self:NotResting()
		self.Age = 0
	else
		self.ToDelete = true
	end
end

function swarm_destroy(self)
	--Remove all wasps.
	if self.roster ~= nil then
		for i = 1, #self.roster do
			if MovableMan:IsParticle(self.roster[i]) then
				self.roster[i].ToDelete = true
			end
		end

		self.roster = nil
	end
end