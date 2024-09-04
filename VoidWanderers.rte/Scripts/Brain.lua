local tempvar = nil

function CF_Read(self, keys) 
	tempvar = nil
	ActivityMan:GetActivity():SendMessage("read_from_CF", {self, keys})
	return tempvar
end

function CF_Write(keys, value) 
	ActivityMan:GetActivity():SendMessage("write_to_CF", {keys, value})
end

function CF_Call(self, keys, arguments) 
	tempvar = nil
	ActivityMan:GetActivity():SendMessage("call_in_CF", {self, keys, arguments})
	return tempvar
end

function OnMessage(self, message, context)
	if message == "return_from_activity" then
		tempvar = context
	end
end

function PackBrainForConfig(self)
	return {BrainNumber = self.BrainNumber, RepairCount = self.RepairCount, HealCount = self.HealCount, SelfHealCount = self.SelfHealCount, QuantumStorage = self.QuantumStorage}
end

function UnpackBrainForConfig(self, info)
	self.BrainNumber = info.BrainNumber
	self.RepairCount = info.RepairCount
	self.HealCount = info.HealCount
	self.SelfHealCount = info.SelfHealCount
	self.QuantumStorage = info.QuantumStorage
end

function Create(self)
	-- Set up constants and temps
	local quantumCapacityPerLevel = CF_Read(self, {"QuantumCapacityPerLevel"})
	local reference = ToActor(PresetMan:GetPreset(self.ClassName, self.PresetName, self.ModuleName))
	
	self.DistPerPower = 75
	self.CoolDownInterval = 3000
	self.PrintSkills = false
	self.WeaponTeleportCost = 15
	self.DamageCost = 65
	self.PushCost = 15
	self.StealCost = 30
	self.DistortCost = 25
	self.HealRange = 75

	-- Set timers
	self.HoldTimer = Timer()
	self.HoldTimer:Reset()
	self.EnergyTickTimer = Timer()
	self.EnergyTickTimer:Reset()
	self.CoolDownTimer = Timer()
	self.CoolDownTimer:Reset()
	self.RegenTimer = Timer()
	self.RegenTimer:Reset()
	self.BlinkTimer = Timer()
	self.BlinkTimer:Reset()
	self.HealSkillTimer = Timer()
	self.HealSkillTimer:Reset()

	self.Energy = 100
	
	self.BrainNumber = self:GetNumberValue("VW_BrainOfPlayer") - 1

	-- Defaults are basically nothing but slight regen
	local val = 0
	local healthProportion = self.Health / self.MaxHealth
	self.MaxHealth = reference.MaxHealth * (100 + val) / 100
	self.Health = self.MaxHealth * healthProportion
	self.RegenInterval = 2000 - val * 10

	self.ToughnessLevel = 0
	self.ShieldLevel = 0
	self.TelekinesisLevel = 0
	self.ScannerLevel = 0
	self.HealLevel = 0
	self.SelfHealLevel = 0
	self.RepairLevel = 0
	self.SplitterLevel = 0
	self.QuantumStorageLevel = 0

	-- Obtain brain capabilities depending on type
	if self.BrainNumber ~= Activity.PLAYER_NONE then -- If player controlled
		local player = self.BrainNumber

		local val = tonumber(CF_Read(self, {"GS", "Brain" .. player .. "Level"}))
		local healthProportion = self.Health / self.MaxHealth
		self.MaxHealth = reference.MaxHealth * (100 + val) / 100
		self.Health = self.MaxHealth * healthProportion
		self.RegenInterval = 2000 - val * 10
			
		self.ToughnessLevel = tonumber(CF_Read(self, {"GS", "Brain" .. player .. "Toughness"}))
		self.ShieldLevel = tonumber(CF_Read(self, {"GS", "Brain" .. player .. "Field"}))
		self.TelekinesisLevel = tonumber(CF_Read(self, {"GS", "Brain" .. player .. "Telekinesis"}))
		self.ScannerLevel = tonumber(CF_Read(self, {"GS", "Brain" .. player .. "Scanner"}))
		self.HealLevel = tonumber(CF_Read(self, {"GS", "Brain" .. player .. "Heal"}))
		self.SelfHealLevel = tonumber(CF_Read(self, {"GS", "Brain" .. player .. "SelfHeal"}))
		self.RepairLevel = tonumber(CF_Read(self, {"GS", "Brain" .. player .. "Fix"}))
		self.SplitterLevel = tonumber(CF_Read(self, {"GS", "Brain" .. player .. "Splitter"}))
		self.QuantumStorageLevel = tonumber(CF_Read(self, {"GS", "Brain" .. player .. "QuantumCapacity"}))
	elseif self:GetNumberValue("VW_PreassignedSkills") ~= 0 then -- If preset with values
		local val = self:GetNumberValue("VW_HealthSkill")
		local healthProportion = self.Health / self.MaxHealth
		self.MaxHealth = reference.MaxHealth * (100 + val) / 100
		self.Health = self.MaxHealth * healthProportion
		self.RegenInterval = 2000 - val * 10

		self.ToughnessLevel = self:GetNumberValue("VW_ToughSkill")
		self.ShieldLevel = self:GetNumberValue("VW_ShieldSkill")
		self.TelekinesisLevel = self:GetNumberValue("VW_TelekenesisSkill")
		self.ScannerLevel = self:GetNumberValue("VW_ScannerSkill")
		self.HealLevel = self:GetNumberValue("VW_HealSkill")
		self.SelfHealLevel = self:GetNumberValue("VW_SelfHealSkill")
		self.RepairLevel = self:GetNumberValue("VW_RepairSkill")
		self.SplitterLevel = self:GetNumberValue("VW_SplitterSkill")
		self.QuantumStorageLevel = self:GetNumberValue("VW_QuantumSkill")
	end

	-- Default power uses
	self.HealCount = self.HealLevel
	self.SelfHealCount = self.SelfHealLevel
	self.RepairCount = self.RepairLevel * 3
	self.QuantumCapacity = (1 + self.QuantumStorageLevel) * quantumCapacityPerLevel
	self.QuantumStorage = 0

	-- If player, get existing power uses
	if self.BrainNumber ~= Activity.PLAYER_NONE then
		-- Record potentially unknown identity
		if CF_Read(self, {"GS", "Brain" .. self.BrainNumber .. "Identity"}) == nil then
			CF_Write({"GS", "Brain" .. self.BrainNumber .. "Identity"}, self:GetNumberValue("Identity"))
		end
		self.RepairCount = tonumber(CF_Read(self, {"GS", "Brain" .. self.BrainNumber .. "Fix_Count"})) or self.RepairCount
		self.HealCount = tonumber(CF_Read(self, {"GS", "Brain" .. self.BrainNumber .. "Heal_Count"})) or self.HealCount
		self.SelfHealCount = tonumber(CF_Read(self, {"GS", "Brain" .. self.BrainNumber .. "SelfHeal_Count"})) or self.SelfHealCount
		self.QuantumStorage = tonumber(CF_Read(self, {"GS", "Brain" .. self.BrainNumber .. "QuantumStorage"})) or self.QuantumStorage
	end

	-- Determine enabled abilities
	self.DistortEnabled = self.TelekinesisLevel > 0
	self.PushEnabled = self.TelekinesisLevel > 1
	self.WeaponTeleportEnabled = self.TelekinesisLevel > 2
	self.StealEnabled = self.TelekinesisLevel > 3
	self.DamageEnabled = self.TelekinesisLevel > 4

	-- Set up scanner
	self.ScannerEnabled = false
	self.ScannerRange = 200 + self.ScannerLevel * 160

	-- Set up shield
	self.ShieldEnabled = self.ShieldLevel > 0
	self.ShieldRadius = 75
	self.ShieldRadiusPerPower = 25
	self.ShieldIneffectiveRadius = 25
	self.ShieldMinVelocity = 25
	self.ShieldPressure = 0
	self.ShieldPressureAmp = 10
	self.ShieldDepressureDelay = 1000

	self.DepressureTimer = Timer()
	self.DepressureTimer:SetSimTimeLimitMS(self.ShieldDepressureDelay)
	
	-- Set up healing capabilities
	local healSkillFactor = 1 - self.HealCount / 5
	self.baseHealDelay = 40 + 200 * healSkillFactor
	self.healIncrementPerTarget = 30 + 150 * healSkillFactor
	self.healIncrementPerWound = 10 + 50 * healSkillFactor
	self.healTimer = Timer()
	self.healTimer:SetSimTimeLimitMS(self.baseHealDelay)

	self.crossTimer = Timer()
	self.crossTimer:SetSimTimeLimitMS(800)

	self.visual = {}
	self.visual.Colors = { 135, 133, 149, 148, 145, 148, 149, 133 }
	self.visual.CurrentColor = 0
	self.visual.Rotation = 0
	self.visual.RPM = 60
	self.visual.ArcCount = 3

	self.maxHealRange = 50 + self.HealCount * 5
	self.healTargets = {}

	-- Apply toughness buffs
	local toughnessFactor = (1 + 2 * self.ToughnessLevel / 5)
	self.AimDistance = self.AimDistance * toughnessFactor
	self.ImpulseDamageThreshold = self.ImpulseDamageThreshold * toughnessFactor
	self.GibWoundLimit = self.GibWoundLimit * toughnessFactor
	self.GibImpulseLimit = self.GibImpulseLimit * toughnessFactor
	if self.BGArm then
		self.BGArm.GibWoundLimit = self.BGArm.GibWoundLimit * toughnessFactor
		self.BGArm.GibImpulseLimit = self.BGArm.GibImpulseLimit * toughnessFactor
		self.BGArm.GripStrength = 400000
	end
	if self.FGArm then
		self.FGArm.GibWoundLimit = self.FGArm.GibWoundLimit * toughnessFactor
		self.FGArm.GibImpulseLimit = self.FGArm.GibImpulseLimit * toughnessFactor
		self.FGArm.GripStrength = 400000
	end
	if self.BGLeg then
		self.BGLeg.GibWoundLimit = self.BGLeg.GibWoundLimit * toughnessFactor
		self.BGLeg.GibImpulseLimit = self.BGLeg.GibImpulseLimit * toughnessFactor
	end
	if self.FGLeg then
		self.FGLeg.GibWoundLimit = self.FGLeg.GibWoundLimit * toughnessFactor
		self.FGLeg.GibImpulseLimit = self.FGLeg.GibImpulseLimit * toughnessFactor
	end
	if self.Head then
		self.Head.GibWoundLimit = self.Head.GibWoundLimit * toughnessFactor
		self.Head.GibImpulseLimit = self.Head.GibImpulseLimit * toughnessFactor
	end
	if self.Jetpack then
		local softnessFactor = math.sqrt(toughnessFactor)
		self.Jetpack.JetTimeTotal = self.Jetpack.JetTimeTotal * softnessFactor
		self.Jetpack.JetTimeLeft = self.Jetpack.JetTimeLeft * softnessFactor
		self.Jetpack.JetReplenishRate = self.Jetpack.JetReplenishRate * softnessFactor
		for em in self.Jetpack.Emissions do
			em.ParticlesPerMinute = em.ParticlesPerMinute * softnessFactor;
			em.BurstSize = em.BurstSize * softnessFactor;
		end
	end

	-- Create skills menu
	self.ActiveMenu = {}
	self.ActiveMenu[1] = {}
	self.SelectedMenuItem = 1

	self.Skills = {}
	local count = 0

	if self.ScannerLevel > 0 then
		count = count + 1
		self.Skills[count] = {}

		self.Skills[count]["Text"] = "Toggle scanner"
		self.Skills[count]["Count"] = -1
		self.Skills[count]["Function"] = rpgbrain_skill_scanner

		self.ScannerSkillIndex = count

		if CF_Read(self, {"GS", "Brain" .. self.BrainNumber .. "ScannerEnabled"}) == "true" then
			self.Skills[self.ScannerSkillIndex]["State"] = "On"
			self.ScannerEnabled = true
		else
			self.Skills[self.ScannerSkillIndex]["State"] = "Off"
			self.ScannerEnabled = false
		end
	end

	if self.RepairCount > 0 then
		count = count + 1
		self.Skills[count] = {}

		self.Skills[count]["Text"] = "Repair weapon"
		self.Skills[count]["Count"] = self.RepairCount
		self.Skills[count]["Function"] = rpgbrain_skill_repair
	end
		
	if self.HealCount > 0 then
		count = count + 1
		self.Skills[count] = {}
			
		self.Skills[count]["Text"] = "Heal unit"
		self.Skills[count]["Count"] = self.HealCount
		self.Skills[count]["Function"] = rpgbrain_skill_healstart
		self.Skills[count]["ActorDetectRange"] = self.HealRange
		self.Skills[count]["AffectsBrains"] = false
	end

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

		local quantumItems = CF_Read(self, {"QuantumItems"})
		local quantumItemPresets = CF_Read(self, {"QuantumItmPresets"})
		local quantumItemClasses = CF_Read(self, {"QuantumItmClasses"})
		local quantumItemModules = CF_Read(self, {"QuantumItmModules"})
		local quantumItemPrices = CF_Read(self, {"QuantumItmPrices"})
		for i = 1, #quantumItems do
			local id = quantumItems[i]

			if CF_Read(self, {"GS", "QuantumItemUnlocked_" .. id}) == "True" then
				local n = #items + 1
				items[n] = {}
				items[n]["ID"] = id
				items[n]["Preset"] = quantumItemPresets[id]
				items[n]["Class"] = quantumItemClasses[id]
				items[n]["Module"] = quantumItemModules[id]
				items[n]["Price"] = math.ceil(quantumItemPrices[id] / 2)
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
end

function Update(self)
	-- Don't do anything when in edit mode
	if ActivityMan:GetActivity().ActivityState ~= Activity.RUNNING then
		return
	end

	if self.Status >= Actor.DYING then
		if self.BrainNumber == Activity.PLAYER_NONE then
			self:DisableScript("VoidWanderers.rte/Scripts/Brain.lua")
		end
		return
	end

	do_rpgbrain_shield(self)
	
	self.FullPower = self.TelekinesisLevel

	-- Calculate effective skills distance
	self.EffectiveDistance = self.FullPower * self.DistPerPower

	self.Threat = nil
	local nearestenemydist = self.EffectiveDistance

	-- Search for nearby actors
	if self.Energy >= 15 and self.CoolDownTimer:IsPastSimMS(self.CoolDownInterval) then
		for actor in MovableMan.Actors do
			if actor.Team ~= self.Team and not actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua") and actor.Health > 0 then
				-- Search for enemies to find threat
				local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX)

				-- Find only nearest enemies
				if dist:MagnitudeIsLessThan(nearestenemydist) then
					local angle = dist.AbsRadAngle
					local pos = self.Pos + Vector(math.cos(-angle) * 20, math.sin(-angle) * 20)

					-- To improve enemy visibility cast rays across the whole enemy figure
					local offsets = { Vector(0, -15), Vector(0, -7), Vector(0, 0), Vector(0, 7), Vector(0, 15) }

					for i = 1, #offsets do
						local actorpos = pos
						local vectortoactor = actor.Pos + offsets[i] - actorpos
						local moid = SceneMan:CastMORay(
							actorpos,
							vectortoactor,
							self.ID,
							self.Team,
							-1,
							false,
							4
						)
						local mo = MovableMan:GetMOFromID(moid)

						if mo ~= nil then
							if mo.ClassName == "AHuman" then
								self.Threat = ToAHuman(mo)
								nearestenemydist = dist.Magnitude
							else
								local mo = MovableMan:GetMOFromID(mo.RootID)
								if mo ~= nil and mo.ClassName == "AHuman" then
									self.Threat = ToAHuman(mo)
									nearestenemydist = dist.Magnitude
								end
							end
						end
					end
				end
			end
		end
	end

	-- Check for applicable skill from closest to farthest
	-- Teleport closest weapon
	if
		self.Energy >= self.WeaponTeleportCost
		and self.WeaponTeleportEnabled
		and self.CoolDownTimer:IsPastSimMS(self.CoolDownInterval)
		and self.EquippedItem == nil
	then
		local nearestitmdist = 1000000
		local nearestitem = nil

		-- Find nearest weapon
		for itm in MovableMan.Items do
			if itm.ClassName == "HDFirearm" and itm.HitsMOs ~= false and not ToHeldDevice(itm).UnPickupable then
				local d = SceneMan:ShortestDistance(itm.Pos, self.Pos, true).Magnitude

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
			VoidWanderersRPG_AddPsyEffect(self.Head.Pos)
			VoidWanderersRPG_AddPsyEffect(nearestitem.Pos)

			local newitem = nearestitem:Clone()
			if newitem ~= nil then
				self:AddInventoryItem(newitem)
				nearestitem.ToDelete = true
				-- This item will be teleported only on the next sim update, we need to move it far away to avoid grabbing by other psyclones
				nearestitem.Pos = Vector(0, 25000)
			end --]]--
			--self:AddInventoryItem(nearestitem)
			self.CoolDownTimer:Reset()
		end
	end

	-- If we have target then use some skills on it
	if MovableMan:IsActor(self.Threat) then
		self.Threat:FlashWhite(25)

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
				local newweap = VoidWanderersRPG_VW_MakeItem(weap.PresetName, weap.ClassName, weap.ModuleName)
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

						local shortestDistance = SceneMan:ShortestDistance(self.Pos, weap.Pos, SceneMan.SceneWrapsX)
						local angle, d = shortestDistance.AbsRadAngle, shortestDistance.Magnitude
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

			local shortestDistance = SceneMan:ShortestDistance(self.Pos, self.Threat.Pos, SceneMan.SceneWrapsX)
			local angle, d = shortestDistance.AbsRadAngle, shortestDistance.Magnitude

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

	--CF.DrawString(tostring(self:GetAimAngle(true)), self.Pos + Vector(0,-110), 200, 200)
	--CF.DrawString(tostring(math.cos(self:GetAimAngle(false))), self.Pos + Vector(0,-100), 200, 200)
	--CF.DrawString(tostring(math.floor(self:GetAimAngle(true) * (180 / 3.14))), self.Pos + Vector(0,-90), 200, 200)

	-- Update state
	if self.EnergyTickTimer:IsPastSimMS(250) then
		-- Add power
		self.Energy = self.Energy + self.FullPower * 0.1

		if self.Energy > 100 then
			self.Energy = 100
		end

		self.EnergyTickTimer:Reset()
	end

	if self.RegenInterval > 0 and self.MaxHealth > 100 and self.RegenTimer:IsPastSimMS(self.RegenInterval) then
		if self.Health < self.MaxHealth then
			self.Health = self.Health + 1
		end
		self.RegenTimer:Reset()
	end

	-- Draw power marker
	if self.TelekinesisLevel > 0 and self.Head then
		local glownum = math.ceil(self.FullPower * 2 * (self.Energy / 100))

		if glownum > 10 then
			glownum = 10
		end

		if glownum > 0 then
			local pix = CreateMOPixel("Purple Glow " .. glownum, "VoidWanderers.rte")
			pix.Pos = self.Head.Pos
			MovableMan:AddParticle(pix)
		end
	end

	if self.PrintSkills then
		CF_Call(self, {"DrawString"}, {"E " .. math.floor(self.Energy), self.Pos + Vector(0, -50), 200, 200})
		CF_Call(self, {"DrawString"}, {"P " .. self.FullPower, self.Pos + Vector(0, -40), 200, 200})
	end

	-- Process scanner
	if self.ScannerLevel > 0 and self.ScannerEnabled then
		for actor in MovableMan.Actors do
			if actor.ClassName ~= "ADoor" and actor.ClassName ~= "Actor" and actor.ID ~= self.ID then
				local shortestDistance = SceneMan:ShortestDistance(self.Head.Pos, actor.Pos, SceneMan.SceneWrapsX)
				local a, d = shortestDistance.AbsRadAngle, shortestDistance.Magnitude
				if d < self.ScannerRange then
					local relpos = Vector(math.cos(-a) * (20 + (d * 0.1)), math.sin(-a) * (20 + (d * 0.1)))

					local effect = "Blue Glow"

					if actor.Team ~= self.Team then
						local pos = self.Head.Pos + Vector(math.cos(-a) * 20, math.sin(-a) * 20)
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
						
					local pix = CreateMOPixel(effect, "VoidWanderers.rte")
					pix.Pos = self.Head.Pos + relpos
					MovableMan:AddParticle(pix)
				end
			end
		end

		-- Show eye pos
		local shortestDistance = SceneMan:ShortestDistance(self.Head.Pos, self.ViewPoint, SceneMan.SceneWrapsX)
		local a, d = shortestDistance.AbsRadAngle, shortestDistance.Magnitude
		local relpos = Vector(math.cos(-a) * (20 + (d * 0.1)), math.sin(-a) * (20 + (d * 0.1)))
		local effect = "Green Glow"
			
		local pix = CreateMOPixel(effect, "VoidWanderers.rte")
		pix.Pos = self.Head.Pos + relpos
		MovableMan:AddParticle(pix)
	end

	-- Process PDA input
	if self:IsPlayerControlled() then
		if self:NumberValueExists("EnablePDA") then
			-- Enable PDA only if we're not flying or something
			if self.PDAEnabled then
				self.PDAEnabled = false
			else
				if self.Vel:MagnitudeIsLessThan(15) then
					self.PDAEnabled = true
				end
				self.SelectedMenuItem = 1
				self.ActiveMenu = self.Skills
			end
			self:RemoveNumberValue("EnablePDA")
		end
	else
		self.PDAEnabled = false
	end

	if self.PDAEnabled then
		do_rpgbrain_pda(self)
	end

	-- Process passive healing skill
	if self.HealLevel > 0 then
		--Visualize heal range
		local healRange = self.maxHealRange
		local color = self.visual.Colors[self.visual.CurrentColor]
		if #self.healTargets > 0 then
			self.visual.Rotation = self.visual.Rotation - self.visual.RPM / (TimerMan.DeltaTimeMS * 0.5)
			local angleSize = 180 / self.visual.ArcCount
			for i = 0, self.visual.ArcCount - 1 do
				local arcThin = i * 360 / self.visual.ArcCount + self.visual.Rotation
				local arcThick = arcThin + angleSize * 0.1
				PrimitiveMan:DrawArcPrimitive(self.Head.Pos, arcThick, arcThick + angleSize * 0.8, healRange, color, 2)
				PrimitiveMan:DrawArcPrimitive(self.Head.Pos, arcThin, arcThin + angleSize, healRange, color, 1)
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
					and (healTarget.Vel - self.Vel).Largest < 10
				then
					local trace = SceneMan:ShortestDistance(self.Pos, healTarget.Pos, SceneMan.SceneWrapsX)
					if
						(trace.Magnitude - healTarget.Radius) < healRange
						and SceneMan:CastObstacleRay(
								self.Pos,
								trace,
								Vector(),
								Vector(),
								self.ID,
								self.IgnoresWhichTeam,
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
					actor.Team == self.Team
					and actor.ID ~= self.ID
					and (actor.Health < actor.MaxHealth or actor.WoundCount > 0)
					and (actor.Vel - self.Vel).Largest < 10
				then
					local trace = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX)
					if (trace.Magnitude - actor.Radius) < (healRange * 0.9) then
						if
							SceneMan:CastObstacleRay(
								self.Pos,
								trace,
								Vector(),
								Vector(),
								self.ID,
								self.IgnoresWhichTeam,
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
					+ (self.healIncrementPerTarget * #self.healTargets)
			)
		end
	end
		
	if self.HealTarget ~= nil then
		if self.HealSkillTimer:IsPastSimMS(6000) then
			rpgbrain_skill_healend(self)
		else
			swarm_update(self)
		end
	else
		swarm_destroy(self)
	end
		
	-- Process AI skill usage
	if self.Team ~= Activity.TEAM_1 then
		local healThreshold = 40
		
		-- Heal itself
		if self.Health < healThreshold then
			self.SkillTargetActor = self
			rpgbrain_skill_selfhealstart(self)
		end

		-- Heal nearby actors
		local nearestTarget = nil
		local dist = self.HealRange

		for actor in MovableMan.Actors do
			if actor.Team == self.Team and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				local d = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX).Magnitude
				if d <= dist then
					if actor.Health < healThreshold then
						a = actor
						dist = d
						healThreshold = actor.Health
					end
				end
			end
		end
				
		if nearestTarget ~= nil then
			self.SkillTargetActor = nearestTarget
			rpgbrain_skill_healstart(self)
		end
	end
end

function Destroy(self)
	swarm_destroy(self)
end

function VoidWanderersRPG_AddPsyEffect(pos)
	local pix = CreateMOPixel("Huge Glow")
	pix.Pos = pos
	MovableMan:AddParticle(pix)
end

function Distance(point1, point2)
	local wrapFact = Vector(SceneMan.SceneWidth, 0) * (SceneMan.SceneWrapsX and 1 or 0)
	return math.min(
		(point1 - point2).Magnitude, 
		(point1 - point2 - wrapFact).Magnitude, 
		(point1 - point2 + wrapFact ).Magnitude)
end

function VoidWanderersRPG_VW_MakeItem(preset, class, module)
	if class == nil then
		class = "HDFirearm"
	end
	if class == "HeldDevice" then
		return module == nil and CreateHeldDevice(preset) or CreateHeldDevice(preset, module)
	elseif class == "HDFirearm" then
		return module == nil and CreateHDFirearm(preset) or CreateHDFirearm(preset, module)
	elseif class == "TDExplosive" then
		return module == nil and CreateTDExplosive(preset) or CreateTDExplosive(preset, module)
	elseif class == "ThrownDevice" then
		return module == nil and CreateThrownDevice(preset) or CreateThrownDevice(preset, module)
	end

	return nil
end

function do_rpgbrain_shield(self)
	if self.Health > 0 and self.Head and self.ShieldEnabled then
		local maximumPressure = (self.ShieldRadius + self.ShieldLevel * self.ShieldRadiusPerPower) * self.ShieldPressureAmp

		if self:IsStatus(Actor.UNSTABLE) then
			self.ShieldPressure = maximumPressure
		end

		local radius = math.max(0, (maximumPressure - self.ShieldPressure) / self.ShieldPressureAmp)
		local massindex = 1 + ((5 - self.ShieldLevel) * 0.20)

		if radius > self.ShieldIneffectiveRadius then
			for i = 1, math.max(1, 2 * math.pi * radius / 100) do
				local angle = math.random() * math.pi * 2
				local pos = self.Head.Pos + Vector(math.cos(angle) * radius, math.sin(angle) * radius)
				if SceneMan:GetTerrMatter(pos.X, pos.Y) == 0 then
					local pix = CreateMOPixel("Purple Glow 1", "VoidWanderers.rte")
					pix.Pos = pos
					MovableMan:AddParticle(pix)
				end
			end

			local pressureTotal = 0
			for projectile in MovableMan:GetMOsInRadius(self.Head.Pos, radius, self.Team, false) do
				if projectile.HitsMOs and projectile.Vel:MagnitudeIsGreaterThan(self.ShieldMinVelocity) then
					local incidentOffset = SceneMan:ShortestDistance(self.Head.Pos, projectile.Pos, SceneMan.SceneWrapsX)
					local incidentAngle = incidentOffset.AbsRadAngle
					local tempVel = (projectile.Vel * 1):GetRadRotatedCopy(-incidentAngle) 

					if tempVel.X < 0 then
						if incidentOffset:MagnitudeIsGreaterThan(self.ShieldIneffectiveRadius) then
							projectile.Vel = tempVel:FlipX(true):GetRadRotatedCopy(incidentAngle + RangeRand(-0.1, 0.1))
						end
					
						local pressureIncrement = (projectile.Mass * massindex * projectile.Vel.Magnitude * projectile.Sharpness) * math.cos(tempVel.AbsRadAngle)
						pressureTotal = pressureTotal + pressureIncrement

						glowIndex = math.min(math.floor(pressureIncrement * 0.1), 15)
						for i = 1, math.sqrt(glowIndex) do
							local glowNumb = math.random(glowIndex)
							local pix = CreateMOPixel("Purple Glow " .. tostring(glowNumb), "VoidWanderers.rte")
							local angle = math.random() * math.pi * 2
							pix.Pos = projectile.Pos + Vector(math.cos(angle), math.sin(angle)) * math.sqrt(1 - glowNumb / glowIndex) * glowIndex
							MovableMan:AddParticle(pix)
						end
					end
				end
			end
			if pressureTotal > 0 then
				self.ShieldPressure = self.ShieldPressure + pressureTotal
				self.DepressureTimer:Reset()
			end
		else
			local angle = math.random() * math.pi * 2
			local radius = math.random(self.ShieldIneffectiveRadius)
			local pos = self.Head.Pos + Vector(math.cos(angle) * radius, math.sin(angle) * radius)
			if SceneMan:GetTerrMatter(pos.X, pos.Y) == 0 then
				local pix = CreateMOPixel("Purple Glow 1", "VoidWanderers.rte")
				pix.Pos = pos
				MovableMan:AddParticle(pix)
			end
		end

		if self.DepressureTimer:IsPastSimMS(self.ShieldDepressureDelay) then
			self.ShieldPressure = math.max(0, math.min(maximumPressure, self.ShieldPressure - 3 * self.ShieldLevel))
		end
	end
end

function do_rpgbrain_pda(self)
	local pos = self.Pos + Vector(0, -200)

	self.SkillTargetActor = nil
	self.SkillTargetActors = {}

	-- Detect nearby target actor
	if #self.ActiveMenu > 0 and self.ActiveMenu[self.SelectedMenuItem]["ActorDetectRange"] ~= nil then
		local detectionRange = self.ActiveMenu[self.SelectedMenuItem]["ActorDetectRange"]
		if not self.ActiveMenu[self.SelectedMenuItem]["DetectAllActors"] then
			for actor in MovableMan.Actors do
				if
					actor.Team == self.Team
					and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
					and (self.ActiveMenu[self.SelectedMenuItem]["AffectsBrains"] == actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua"))
					and detectionRange >= SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX).Magnitude
				then
					self.SkillTargetActor = actor
				end
			end

			if self.SkillTargetActor and self.BlinkTimer:IsPastSimMS(500) then
				self.SkillTargetActor:FlashWhite(25)
				self.BlinkTimer:Reset()
			end
		else
			for actor in MovableMan.Actors do
				if
					actor.Team == self.Team
					and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab")
					and (self.ActiveMenu[self.SelectedMenuItem]["AffectsBrains"] == actor:HasScript("VoidWanderers.rte/Scripts/Brain.lua"))
					and detectionRange >= SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX).Magnitude
				then
					self.SkillTargetActors[#self.SkillTargetActors + 1] = actor
				end
			end

			if #self.SkillTargetActors > 0 and self.BlinkTimer:IsPastSimMS(500) then
				self.BlinkTimer:Reset()
				for _, actor in pairs(self.SkillTargetActors) do
					actor:FlashWhite(25)
				end
			end
		end
	end

	local controller = self:GetController()
	local up = false
	local down = false
	local select = false

	if not (controller:IsState(Controller.PIE_MENU_ACTIVE) or controller:IsState(Controller.PIE_MENU_OPENED)) then
		if controller:IsGamepadControlled() or controller:IsKeyboardOnlyControlled() then
			if controller:IsState(Controller.PRESS_UP) or controller:IsState(Controller.HOLD_UP) then
				up = controller:IsState(Controller.PRESS_UP)

				controller:SetState(Controller.BODY_JUMPSTART, false)
				controller:SetState(Controller.BODY_JUMP, false)
				controller:SetState(Controller.MOVE_UP, false)
				controller.AnalogMove = Vector(controller.AnalogMove.X,0);
			end

			if controller:IsState(Controller.PRESS_DOWN) or controller:IsState(Controller.HOLD_DOWN) then
				down = controller:IsState(Controller.PRESS_DOWN)

				controller:SetState(Controller.BODY_CROUCH, false)
				controller:SetState(Controller.MOVE_DOWN, false)
				controller.AnalogMove = Vector(controller.AnalogMove.X,0);
			end

			if controller:IsState(Controller.PRESS_PRIMARY) or controller:IsState(Controller.WEAPON_FIRE) then
				select = true

				controller:SetState(Controller.PRESS_PRIMARY, false)
				controller:SetState(Controller.WEAPON_FIRE, false)
			end
		else
			if controller:IsState(Controller.SCROLL_UP) then
				up = true
				
				controller:SetState(Controller.SCROLL_UP, false)
				controller:SetState(Controller.WEAPON_CHANGE_PREV, false)
			end

			if controller:IsState(Controller.SCROLL_DOWN) then
				down = true
				
				controller:SetState(Controller.SCROLL_DOWN, false)
				controller:SetState(Controller.WEAPON_CHANGE_NEXT, false)
			end

			if controller:IsState(Controller.PRESS_PRIMARY) or controller:IsState(Controller.WEAPON_FIRE) then
				select = true
				
				controller:SetState(Controller.PRESS_PRIMARY, false)
				controller:SetState(Controller.WEAPON_FIRE, false)
			end
		end
	end

	if up then
		self.SelectedMenuItem = self.SelectedMenuItem - 1
		if self.SelectedMenuItem < 1 then
			self.SelectedMenuItem = #self.ActiveMenu
		end
	end

	if down then
		self.SelectedMenuItem = self.SelectedMenuItem + 1
		if self.SelectedMenuItem > #self.ActiveMenu then
			self.SelectedMenuItem = 1
		end
	end

	self.MenuItemsListStart = self.SelectedMenuItem - (self.SelectedMenuItem - 1) % 6

	-- Show price if item will be nanolyzed
	if self.NanolyzeItem ~= nil then
		self.Skills[self.NanolyzeItem]["Count"] = "EMPTY"

		if self.EquippedItem ~= nil then
			local mass = self.EquippedItem.Mass
			local convert = self.SplitterLevel * CF_Read(self, {"QuantumSplitterEffectiveness"})
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
	local pix = CreateMOPixel("ControlPanel_Skills", "VoidWanderers.rte")
	pix.Pos = pos + Vector(0, 27)
	MovableMan:AddParticle(pix)

	-- Draw skills menu
	if self.ActiveMenu == nil or #self.ActiveMenu == 0 then
		local s = "NO SKILLS"
		local l = CF_Call(self, {"GetStringPixelWidth"}, {s})[1]

		CF_Call(self, {"DrawString"}, {s, pos + Vector(-l / 2, 2), 100, 8})
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
					CF_Call(self, {"DrawString"}, {"> " .. s, pos + Vector(-50, (i - self.MenuItemsListStart) * 10), 150, 8})
				else
					CF_Call(self, {"DrawString"}, {s, pos + Vector(-50, (i - self.MenuItemsListStart) * 10), 150, 8})
				end
			end
		end 
	end

	if select then
		if not self.FirePressed then
			self.FirePressed = true

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
		self.FirePressed = false
	end
end

function rpgbrain_skill_healstart(self)
	if self.HealCount > 0 and self.HealTarget == nil then
		if
			self.SkillTargetActor ~= nil
			and MovableMan:IsActor(self.SkillTargetActor)
		then
			self.HealTarget = self.SkillTargetActor
			self.HealSkillTimer:Reset()
			swarm_create(self, self.HealTarget)
			
			self.HealCount = self.HealCount - 1
			self.ActiveMenu[self.SelectedMenuItem]["Count"] = self.HealCount
			CF_Call(self, {"SaveThisBrainSupplies"}, {CF_Read(self, {"GS"}), PackBrainForConfig(self)})
		end
	end
end

function rpgbrain_skill_selfhealstart(self)
	if self.SelfHealCount > 0 and self.HealTarget == nil then
		if
			self.SkillTargetActor ~= nil
			and MovableMan:IsActor(self.SkillTargetActor)
		then
			self.HealTarget = self.SkillTargetActor
			self.HealSkillTimer:Reset()
			swarm_create(self, self.HealTarget)

			self.SelfHealCount = self.SelfHealCount - 1
			self.ActiveMenu[self.SelectedMenuItem]["Count"] = self.SelfHealCount
			CF_Call(self, {"SaveThisBrainSupplies"}, {CF_Read(self, {"GS"}), PackBrainForConfig(self)})
		end
	end
end

function rpgbrain_skill_healend(self)
	if self.HealTarget ~= nil and MovableMan:IsActor(self.HealTarget) then
		local missingLimbs = {}
		local replacedLimbs = {}

		-- function(item, class, module, xp, identity, player, prestige, name, limbs)
		local referenceActor = CF_Call(self, {"MakeActor"}, {
			self.HealTarget.PresetName,
			self.HealTarget.ClassName,
			self.HealTarget.ModuleName,
			self.HealTarget:GetNumberValue("VW_XP"),
			self.HealTarget:GetNumberValue("Identity"),
			self.HealTarget:GetNumberValue("VW_BrainOfPlayer"),
			self.HealTarget:GetNumberValue("VW_Prestige")
		})[1]

		if referenceActor then
			local possibleLimbs = {}
			if referenceActor.ClassName == "AHuman" then
				self.HealTarget = ToAHuman(self.HealTarget)
				self.HealTarget:UnequipArms()
				possibleLimbs = {"Head", "FGArm", "BGArm", "FGLeg", "BGLeg"}
			elseif referenceActor.ClassName == "ACrab" then
				self.HealTarget = ToACrab(self.HealTarget)
				possibleLimbs = {"Turret", "LFGLeg", "LBGLeg", "RFGLeg", "RBGLeg"}
			end
			for i = 1, #possibleLimbs do
				missingLimbs[i] = false
				replacedLimbs[i] = false
				if self.HealTarget[possibleLimbs[i]] then
					if referenceActor[possibleLimbs[i]] and referenceActor[possibleLimbs[i]].PresetName ~= self.HealTarget[possibleLimbs[i]].PresetName then
						replacedLimbs[i] = true
						self.HealTarget[possibleLimbs[i]] = referenceActor[possibleLimbs[i]]:Clone()
					end
				else
					missingLimbs[i] = true
				end
			end
			if referenceActor.ClassName == "AHuman" then
				self.HealTarget:GetController():SetState(Controller.WEAPON_CHANGE_PREV, true)
			end
			referenceActor.ToDelete = true
		end
		self.HealTarget = nil
	end
	swarm_destroy(self)
end

function rpgbrain_skill_repair(self)
	if self.RepairCount > 0 then
		if self.EquippedItem ~= nil then
			local preset = self.EquippedItem.PresetName
			local class = self.EquippedItem.ClassName
			local module = self.EquippedItem.ModuleName

			local newgun = VoidWanderersRPG_VW_MakeItem(preset, class, module)
			if newgun ~= nil then
				self.EquippedItem.ToDelete = true

				self:AddInventoryItem(newgun)
				self:GetController():SetState(Controller.WEAPON_CHANGE_PREV, true)

				self.RepairCount = self.RepairCount - 1
				self.ActiveMenu[self.SelectedMenuItem]["Count"] = self.RepairCount
				CF_Call(self, {"SaveThisBrainSupplies"}, {CF_Read(self, {"GS"}), PackBrainForConfig(self)})
			end
		end
	end
end

function rpgbrain_skill_split(self)
	if self.EquippedItem ~= nil then
		if self.QuantumStorage < self.QuantumCapacity then
			local mass = self.EquippedItem.Mass
			local convert = self.SplitterLevel * CF_Read(self, {"QuantumSplitterEffectiveness"})
			local matter = math.floor(mass * convert)

			self.QuantumStorage = self.QuantumStorage + matter
			if self.QuantumStorage > self.QuantumCapacity then
				self.QuantumStorage = self.QuantumCapacity
			end

			self.Skills[self.QuantumStorageItem]["Count"] = self.QuantumStorage
			CF_Call(self, {"SaveThisBrainSupplies"}, {CF_Read(self, {"GS"}), PackBrainForConfig(self)})

			self.EquippedItem.ToDelete = true
			self:GetController():SetState(Controller.WEAPON_CHANGE_PREV, true)
		end
	end
end

function rpgbrain_skill_synthesize(self)
	if self.QuantumStorage >= self.ActiveMenu[self.SelectedMenuItem]["Price"] then
		local preset = self.ActiveMenu[self.SelectedMenuItem]["Preset"]
		local class = self.ActiveMenu[self.SelectedMenuItem]["Class"]
		local module = self.ActiveMenu[self.SelectedMenuItem]["Module"]

		local newgun = VoidWanderersRPG_VW_MakeItem(preset, class, module)
		if newgun ~= nil then
			self:AddInventoryItem(newgun)
			self:GetController():SetState(Controller.WEAPON_CHANGE_PREV, true)

			self.QuantumStorage = self.QuantumStorage - self.ActiveMenu[self.SelectedMenuItem]["Price"]
			self.Skills[self.QuantumStorageItem]["Count"] = self.QuantumStorage
			CF_Call(self, {"SaveThisBrainSupplies"}, {CF_Read(self, {"GS"}), PackBrainForConfig(self)})
		end
	end
end

function rpgbrain_skill_scanner(self)
	self.ScannerEnabled = not self.ScannerEnabled

	local enabled = CF_Read(self, {"GS", "Brain" .. self.BrainNumber .. "ScannerEnabled"}) == "true";

	CF_Write({"GS", "Brain" .. self.BrainNumber .. "ScannerEnabled"}, tostring(not enabled))
	self.Skills[self.ScannerSkillIndex]["State"] = enabled and "Off" or "On"
end

function swarm_swarmto(object, target, speed)
	local baseVector = SceneMan:ShortestDistance(object.Pos, target, SceneMan.SceneWrapsX)
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
				local speedMod = SceneMan:ShortestDistance(wasp.Pos, target, SceneMan.SceneWrapsX).Magnitude / 5
				if speedMod < 1 then
					speedMod = 1
				end

				--Counteract gravity.
				wasp.Vel.Y = wasp.Vel.Y - SceneMan.Scene.GlobalAcc.Y * TimerMan.DeltaTimeSecs

				if wasp.Vel.Largest > self.maxSpeed * speedMod * attackMax then
					wasp.Vel = (wasp.Vel / wasp.Vel.Largest) * self.maxSpeed * speedMod * attackMax
				end

				--Keep the wasp within decent bounds of the swarm.
				local distVec = SceneMan:ShortestDistance(target, wasp.Pos, SceneMan.SceneWrapsX)

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