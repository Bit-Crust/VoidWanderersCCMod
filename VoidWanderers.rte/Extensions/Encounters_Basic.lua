-----------------------------------------------------------------------
-----------------------------------------------------------------------
--[[ Test encounter
local id = "TEST"

CF.RandomEncounters[#CF.RandomEncounters + 1] = id
	
CF.RandomEncountersInitialTexts[id] = "TEST ENCOUNTER"
CF.RandomEncountersInitialVariants[id] = {"Variant 1", "Variant 2", "Variant 3"}
CF.RandomEncountersVariantsInterval[id] = 12
CF.RandomEncountersOneTime[id] = false
CF.RandomEncountersFunctions[id] = 

function (self, variant) 
	if variant ~= 0 then
		self.MissionReport = {}
		
		self.MissionReport[#self.MissionReport + 1] = "SELECTED VARIANT "..variant
		
		-- Finish encounter
		self.RandomEncounterID = nil
		CF.SaveMissionReport(self.GS, self.MissionReport)
	end
end
--]]
-----------------------------------------------------------------------
-----------------------------------------------------------------------
--[[ Define pirate identities
CF.RandomEncounterPirates = {}

-- Generic organic mid-heavy pirates
local pid = #CF.RandomEncounterPirates + 1
CF.RandomEncounterPirates[pid] = {}
CF.RandomEncounterPirates[pid]["Captain"] = "Apone"
CF.RandomEncounterPirates[pid]["Ship"] = "Sulako"
CF.RandomEncounterPirates[pid]["Org"] = "The Free Galactic Brotherhood"
CF.RandomEncounterPirates[pid]["FeeInc"] = 500
CF.RandomEncounterPirates[pid]["Act"] = { "Raider", "Soldier Light", "Soldier Heavy", "Browncoat", "Exterminator" }
CF.RandomEncounterPirates[pid]["ActMod"] = { "Ronin.rte", "Coalition.rte", "Coalition.rte", "Browncoats.rte", "Browncoats.rte" }
CF.RandomEncounterPirates[pid]["Itm"] = { "AR-25 Hammerfist", "PY-07 Trailblazer", "M16A2", "Assault Rifle", "Auto Shotgun" }
CF.RandomEncounterPirates[pid]["ItmMod"] = { "Browncoats.rte", "Browncoats.rte", "Ronin.rte", "Coalition.rte", "Coalition.rte" }
CF.RandomEncounterPirates[pid]["Thrown"] = { "Shredder SB-08", "Timed Explosive" }
CF.RandomEncounterPirates[pid]["ThrownMod"] = { "Imperatus.rte", "Coalition.rte" }
CF.RandomEncounterPirates[pid]["Units"] = 12
CF.RandomEncounterPirates[pid]["Burst"] = 3
CF.RandomEncounterPirates[pid]["Interval"] = 14

-- Generic mid-heavy robot pirates
local pid = #CF.RandomEncounterPirates + 1
CF.RandomEncounterPirates[pid] = {}
CF.RandomEncounterPirates[pid]["Captain"] = "SHODAN"
CF.RandomEncounterPirates[pid]["Ship"] = "Von Braun"
CF.RandomEncounterPirates[pid]["Org"] = "The Free Nexus"
CF.RandomEncounterPirates[pid]["FeeInc"] = 500
CF.RandomEncounterPirates[pid]["Act"] = { "Dummy", "All Purpose Robot", "Combat Robot", "Whitebot", "Silver Man" }
CF.RandomEncounterPirates[pid]["ActMod"] = { "Dummy.rte", "Imperatus.rte", "Imperatus.rte", "Techion.rte", "Techion.rte" }
CF.RandomEncounterPirates[pid]["Itm"] = { "Blaster", "Repeater", "Bullpup AR-14", "Mauler SG-23", "Pulse Rifle" }
CF.RandomEncounterPirates[pid]["ItmMod"] = { "Dummy.rte", "Dummy.rte", "Imperatus.rte", "Imperatus.rte", "Techion.rte" }
CF.RandomEncounterPirates[pid]["Thrown"] = { "Scrambler", "Timed Explosive" }
CF.RandomEncounterPirates[pid]["ThrownMod"] = { "Ronin.rte", "Coalition.rte" }
CF.RandomEncounterPirates[pid]["Units"] = 12
CF.RandomEncounterPirates[pid]["Burst"] = 2
CF.RandomEncounterPirates[pid]["Interval"] = 10

-- Pirates
local id = "PIRATE_GENERIC"
CF.RandomEncounters[#CF.RandomEncounters + 1] = id
CF.RandomEncountersInitialTexts[id] = ""
CF.RandomEncountersInitialVariants[id] = {
	"I'm at your mercy, take whatever you want.",
	"Kid, don't threaten me. There are worse things than death and I can do all of them.",
}
CF.RandomEncountersVariantsInterval[id] = 24
CF.RandomEncountersOneTime[id] = false
CF.RandomEncountersFunctions[id] = 
function(self, variant)
	if not self.RandomEncounterIsInitialized then
		-- Select random pirate party
		self.pirateID = math.random(#CF.RandomEncounterPirates)
		self.RandomEncounterPirate = CF.RandomEncounterPirates[self.pirateID]

		local fee =
			self.GS["RandomEncounter" .. self.RandomEncounterID .. self.RandomEncounterPirate["Captain"] .. "Fee"]
		if fee == nil then
			fee = self.RandomEncounterPirate["FeeInc"]
		else
			fee = tonumber(fee)
		end

		-- If we killed selected pirate then show some info and give player some gold
		if fee == -1 then
			local gold = math.random(self.RandomEncounterPirate["FeeInc"])

			self.MissionReport = {}
			self.MissionReport[#self.MissionReport + 1] = "Dead pirate vessel floats nearby. It seems to have been raided countless times, but you managed to scavenge "
				.. gold
				.. "oz of gold from it."
			CF.SaveMissionReport(self.GS, self.MissionReport)

			self.RandomEncounterText = ""

			CF.ChangeGold(self.GS, gold)

			-- Finish encounter
			self.RandomEncounterID = nil
		else
			-- If captain is still alive then initiate negotiations

			--if fee > CF.GetPlayerGold(self.GS) then
			--	fee = CF.GetPlayerGold(self.GS)
			--end

			self.RandomEncounterPirateFee = fee
			self.RandomEncounterPirateUnits = self.RandomEncounterPirate["Units"]

			-- Change initial text
			if self.RandomEncounterPirate["EncounterText"] then
				self.RandomEncounterText = self.RandomEncounterPirate["EncounterText"]
			else
				self.RandomEncounterText = "This is captain "
					.. self.RandomEncounterPirate["Captain"]
					.. " of "
					.. self.RandomEncounterPirate["Ship"]
					.. " speaking. You are in the vicinity of "
					.. self.RandomEncounterPirate["Org"]
					.. " and have to pay a small fee of "
					.. self.RandomEncounterPirateFee
					.. "oz of gold to pass. Comply at once and no one will get hurt."
			end
			self.GS["RandomEncounter" .. self.RandomEncounterID .. self.RandomEncounterPirate["Captain"] .. "Fee"] = fee
				+ self.RandomEncounterPirate["FeeInc"]
		end

		self.RandomEncounterPirateAttackLaunched = false
		self.RandomEncounterIsInitialized = true
	end

	if not self.RandomEncounterPirateAttackLaunched then
		if variant == 1 then
			local gold = CF.GetPlayerGold(self.GS)
			if gold < math.random(self.RandomEncounterPirateFee) then
				if gold >= self.RandomEncounterPirateFee * 0.5 then
					CF.SetPlayerGold(self.GS, 0)
					self.RandomEncounterText = "Thank you for your payment. My troops will come by to collect the rest. "
						.. self.RandomEncounterPirate["Captain"]
						.. " out."
				else
					self.RandomEncounterText = self.RandomEncounterPirate["MsgBroke"]
						or "In that case, we take your ship. " .. self.RandomEncounterPirate["Captain"] .. " out."
				end
				self.RandomEncounterVariants = {}

				-- Indicate thet we fought this pirate and defeated him
				self.GS["RandomEncounter" .. self.RandomEncounterID .. self.RandomEncounterPirate["Captain"] .. "Fee"] =
					-1
				self.RandomEncounterPirateAttackLaunched = true

				--Deploy turrets
				self:DeployTurrets()

				-- Disable consoles
				self:DestroyStorageControlPanelUI()
				--self:DestroyClonesControlPanelUI()
				self:DestroyBeamControlPanelUI()
				self:DestroyTurretsControlPanelUI()

				-- Set up assault
				self.AssaultNextSpawnTime = self.Time + self.RandomEncounterPirate["Interval"]
				self.AssaultNextSpawnPos = self.EnemySpawn[math.random(#self.EnemySpawn)]
				self.AssaultWarningTime = math.random(5, 6)
			else
				self.MissionReport = {}
				local newGold = CF.GetPlayerGold(self.GS) - self.RandomEncounterPirateFee
				if newGold <= 0 then
					self.MissionReport[#self.MissionReport + 1] = self.RandomEncounterPirate["MsgDebt"]
						or "Consider yourself lucky, punk. Next time we take your ship. "
							.. self.RandomEncounterPirate["Captain"]
							.. " out."
				else
					self.MissionReport[#self.MissionReport + 1] = self.RandomEncounterPirate["MsgBribe"]
						or self.RandomEncounterPirate["Org"]
							.. " is always at your service. "
							.. self.RandomEncounterPirate["Captain"]
							.. " out."
				end
				CF.SetPlayerGold(self.GS, math.max(newGold, 0))
				-- Finish encounter
				self.RandomEncounterID = nil
				CF.SaveMissionReport(self.GS, self.MissionReport)
			end
		end

		if variant == 2 then
			self.RandomEncounterText = self.RandomEncounterPirate["MsgHostile"]
				or "Prepare to be punished! " .. self.RandomEncounterPirate["Captain"] .. " out."
			self.RandomEncounterVariants = {}

			-- Indicate thet we fought this pirate and defeated him
			self.GS["RandomEncounter" .. self.RandomEncounterID .. self.RandomEncounterPirate["Captain"] .. "Fee"] = -1
			self.RandomEncounterPirateAttackLaunched = true

			--Deploy turrets
			self:DeployTurrets()

			-- Disable consoles
			self:DestroyStorageControlPanelUI()
			--self:DestroyClonesControlPanelUI()
			self:DestroyBeamControlPanelUI()
			self:DestroyTurretsControlPanelUI()

			-- Set up assault
			self.AssaultNextSpawnTime = self.Time + self.RandomEncounterPirate["Interval"]
			self.AssaultNextSpawnPos = self.EnemySpawn[math.random(#self.EnemySpawn)]
			self.AssaultWarningTime = math.random(5, 6)
		end
	else
		local enemyCount = 0
		local friendCount = 0

		for actor in MovableMan.Actors do
			if actor.Team == CF.CPUTeam then
				enemyCount = enemyCount + 1
				if actor.AIMode ~= Actor.AIMODE_BRAINHUNT then
					actor.AIMode = Actor.AIMODE_BRAINHUNT
				end
				--elseif actor.Team == CF.PlayerTeam and (IsAHuman(actor) or IsACrab(actor)) then
				--	actor = IsAHuman(actor) and ToAHuman(actor) or ToACrab(actor)
				--	if actor.EquippedItem then
				--		friendCount = friendCount + 1
			end
		end

		if self.RandomEncounterPirateUnits == 0 then
			if enemyCount == 0 then
				self.MissionReport = {}
				self.MissionReport[#self.MissionReport + 1] = self.RandomEncounterPirate["MsgDefeat"]
					or "Fine, looks like you're a tough one. You can pass for free. "
						.. self.RandomEncounterPirate["Captain"]
						.. " out."

				self:GiveRandomExperienceReward()

				-- Finish encounter
				self.RandomEncounterID = nil
				CF.SaveMissionReport(self.GS, self.MissionReport)
				-- Rebuild destroyed consoles
				self:InitStorageControlPanelUI()
				--self:InitClonesControlPanelUI()
				self:InitBeamControlPanelUI()
				self:InitTurretsControlPanelUI()
			end
		end

		if self.AssaultNextSpawnTime == self.Time then
			--print ("Spawn")
			self.AssaultNextSpawnTime = self.Time + self.RandomEncounterPirate["Interval"] + math.random(0, 2)

			local cnt = math.random(
				math.ceil(self.RandomEncounterPirate["Burst"] * 0.5),
				self.RandomEncounterPirate["Burst"]
			)

			for j = 1, cnt do
				if MovableMan:GetMOIDCount() < CF.MOIDLimit and self.RandomEncounterPirateUnits > 0 then
					self.RandomEncounterPirateUnits = self.RandomEncounterPirateUnits - 1

					local r1 = math.random(#self.RandomEncounterPirate["Act"])

					local actor = CreateAHuman(
						self.RandomEncounterPirate["Act"][r1],
						self.RandomEncounterPirate["ActMod"][r1]
					)
					if actor then
						local weap
						if self.RandomEncounterPirate["Itm"] then
							local r2 = math.random(#self.RandomEncounterPirate["Itm"])
							weap = CreateHDFirearm(
								self.RandomEncounterPirate["Itm"][r2],
								self.RandomEncounterPirate["ItmMod"][r2]
							)
							if weap then
								actor:AddInventoryItem(weap)
							end
						end
						if self.RandomEncounterPirate["Thrown"] and (not weap or math.random() < 0.5) then
							local r2 = math.random(#self.RandomEncounterPirate["Thrown"])
							local thrown = CreateTDExplosive(
								self.RandomEncounterPirate["Thrown"][r2],
								self.RandomEncounterPirate["ThrownMod"][r2]
							)
							if thrown then
								actor:AddInventoryItem(thrown)
								if math.random() < 0.5 then
									thrown:Activate()
								end
							end
						end
						if self.RandomEncounterPirate["Captain"] == "Apone" then
							if math.random() < 0.3 then
								if math.random() < 0.5 then
									local arm = CreateArm("Prosthetic Arm FG")
									if actor.FGArm then
										arm.ParentOffset = actor.FGArm.ParentOffset
									end
									arm:AddScript("VoidWanderers.rte/Items/Salvage.lua")
									actor.FGArm = arm
								else
									local arm = CreateArm("Prosthetic Arm BG")
									if actor.BGArm then
										arm.ParentOffset = actor.BGArm.ParentOffset
									end
									arm:AddScript("VoidWanderers.rte/Items/Salvage.lua")
									actor.BGArm = arm
								end
							end
							if math.random() < 0.3 then
								if math.random() < 0.5 then
									local leg = CreateLeg("Prosthetic Leg FG")
									if actor.FGLeg then
										leg.ParentOffset = actor.FGLeg.ParentOffset
									end
									leg:AddScript("VoidWanderers.rte/Items/Salvage.lua")
									actor.FGLeg = leg
								else
									local leg = CreateLeg("Prosthetic Leg BG")
									if actor.BGLeg then
										leg.ParentOffset = actor.BGLeg.ParentOffset
									end
									leg:AddScript("VoidWanderers.rte/Items/Salvage.lua")
									actor.BGLeg = leg
								end
							end
						elseif self.RandomEncounterPirate["Captain"] == "SHODAN" then
							if math.random() < 0.3 then
								local head = CreateHeldDevice("Replacement Head")
								if actor.Head then
									head.ParentOffset = actor.Head.ParentOffset
								end
								head:AddScript("VoidWanderers.rte/Items/Salvage.lua")
								actor.Head = head
							end
						end

						actor.HFlipped = cnt == 1 and math.random() < 0.5 or j % 2 == 0
						actor.Pos = self.AssaultNextSpawnPos + Vector(math.random(-4, 4), math.random(-2, 2))
						actor.Team = CF.CPUTeam
						actor.AIMode = Actor.AIMODE_BRAINHUNT
						MovableMan:AddActor(actor)

						actor:FlashWhite(math.random(200, 300))
					end
				end
			end

			local sfx = CreateAEmitter("Teleporter Effect A")
			sfx.Pos = self.AssaultNextSpawnPos
			MovableMan:AddParticle(sfx)

			self.AssaultWarningTime = math.random(5, 6)
			self.AssaultNextSpawnPos = self.EnemySpawn[math.random(#self.EnemySpawn)]
		end

		if self.Time % 10 == 0 and self.RandomEncounterPirateUnits > 0 then
			FrameMan:SetScreenText("Remaining intruders: " .. self.RandomEncounterPirateUnits, 0, 0, 1500, true)
		end

		-- Create teleportation effect
		if self.RandomEncounterPirateUnits > 0 and self.AssaultNextSpawnTime - self.Time < self.AssaultWarningTime then
			self:AddObjectivePoint("INTRUDER\nALERT", self.AssaultNextSpawnPos, CF.PlayerTeam, GameActivity.ARROWDOWN)

			if self.TeleportEffectTimer:IsPastSimMS(50) then
				-- Create particle
				local p = CreateMOSParticle("Tiny Blue Glow", self.ModuleName)
				p.Pos = self.AssaultNextSpawnPos + Vector(math.random(-20, 20), math.random(10, 30))
				MovableMan:AddParticle(p)
				self.TeleportEffectTimer:Reset()
			end
		end
	end
end
--]]
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Abandoned ship exploration
local id = "ABANDONED_VESSEL_GENERIC";
CF.RandomEncounters[#CF.RandomEncounters + 1] = id;

CF.RandomEncounterScripts[id] = "VoidWanderers.rte/Scripts/Encounters/AbandonedVessel.lua";
CF.RandomEncounterEligibilityTests[id] = function(self)
	for i = 1, #CF.Location do
		local id = CF.Location[i];

		if CF.IsLocationHasAttribute(id, CF.LocationAttributeTypes.ABANDONEDVESSEL) then
			return true;
		end
	end
	return false;
end
--]]
-----------------------------------------------------------------------
-----------------------------------------------------------------------
--[[ Hostile drone
local id = "HOSTILE_DRONE";
CF.RandomEncounters[#CF.RandomEncounters + 1] = id
CF.RandomEncountersInitialTexts[id] = "A pre-historic assault drone is floating nearby. We don't know if it is dead or not."
CF.RandomEncountersInitialVariants[id] = {"Initiate evade maneuvers and fire countermeasures!" , "Just ignore the damn thing."}
CF.RandomEncountersVariantsInterval[id] = 24
CF.RandomEncountersOneTime[id] = false
CF.RandomEncountersFunctions[id] = 
function (self, variant)
	if not self.RandomEncounterIsInitialized then
		self.RandomEncounterDroneActivated = false
		self.RandomEncounterDroneCharges = math.max(10 - math.floor(tonumber(self.GS["PlayerVesselSpeed"]) * 0.1 + 0.5), 1)
		self.RandomEncounterShotFired = 0
		self.RandomEncounterDroneInterval = 0
		self.RandomEncounterDroneRechargeInterval = 3
		self.RandomEncounterIsInitialized = true
		
		self.RandomEncounterNeedTarget = true
		self.RandomEncounterSourcePos = Vector(SceneMan.SceneWidth / 2 + math.random(-200, 200), SceneMan.SceneHeight / 2 + 1000 * (1 - 2 * math.random(0, 1)))
		self.RandomEncounterSourceVel = Vector(1 / 3, math.random() * 1 / 2 / 3)
		self.RandomEncounterTargetPos = nil
		self.RandomEncounterTargetAngle = nil
		self.RandomEncounterTargetImpactPos = nil
		
		self.RandomEncounterDroneNextFire = 0
	end

	if variant == 1 then
		if math.random(50) < tonumber(self.GS["PlayerVesselSpeed"]) then
			self.MissionReport = {}
			self.MissionReport[#self.MissionReport + 1] = "Got away safely!"
			CF.SaveMissionReport(self.GS, self.MissionReport)
			-- Finish encounter
			self.RandomEncounterID = nil
		elseif math.random(2) == 1 then
			self.MissionReport = {}
			self.MissionReport[#self.MissionReport + 1] = "Looks like it was dead after all."
			CF.SaveMissionReport(self.GS, self.MissionReport)
			-- Finish encounter
			self.RandomEncounterID = nil
		else
			self.RandomEncounterText = "The drone is charging its' weapons, move units deeper inside the ship!"
			self.RandomEncounterVariants = {}
			self.vesselData["dialogOptionChosen"] = 0
			
			self.RandomEncounterDroneActivated = true
			self.RandomEncounterDroneNextFire = self.Time + 18
		end
	end
	
	if variant == 2 then
		if math.random(2) == 1 then
			self.RandomEncounterText = "Shit, it's readying the Ceasefire! INCOMING!"
			self.RandomEncounterVariants = {}
			self.vesselData["dialogOptionChosen"] = 0
			
			self.RandomEncounterDroneActivated = true
			self.RandomEncounterDroneNextFire = self.Time + 6
			self.RandomEncounterDroneCharges = self.RandomEncounterDroneCharges + 1
		else
			self.MissionReport = {}
			self.MissionReport[#self.MissionReport + 1] = "Looks like it could not detect us. Phew..."
			CF.SaveMissionReport(self.GS, self.MissionReport)
		
			-- Finish encounter
			self.RandomEncounterID = nil
		end
	end
	
	if self.RandomEncounterNeedTarget then
		--print ("Target")
		local actors = {}
		
		for actor in MovableMan.Actors do
			if actor.Team == CF.PlayerTeam and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				actors[#actors + 1] = actor
			end
		end
		
		local t
		if #actors > 0 and math.random() > 0.7 then 
			local r = math.random(#actors)
			t = actors[r].Pos
		else
			t = self.vesselData["ship"]:GetRandomPoint()
		end
		
		--t:FlashWhite(5000)
		
		self.RandomEncounterTargetPos = Vector(t.X, t.Y)
		self.RandomEncounterTargetAngle = (t - self.RandomEncounterSourcePos).AbsRadAngle
		self.RandomEncounterTargetImpactPos = Vector()
		self.RandomEncounterNeedTarget = false
		
		local lastgood = Vector()
		local pos = Vector()
		
		for rds = 1, 5000, 50 do
			pos = self.RandomEncounterTargetPos + Vector(-math.cos(self.RandomEncounterTargetAngle) * rds, -math.sin(self.RandomEncounterTargetAngle) * rds)
			if pos.X < 10 or pos.Y < 10 or pos.X > SceneMan.Scene.Width - 10 or pos.Y > SceneMan.Scene.Height - 10 then
				break
			else
				self.RandomEncounterFirePos = pos
			end
		end
		
		local vectortoactor = Vector(-math.cos(self.RandomEncounterTargetAngle + math.pi) * 5, -math.sin(self.RandomEncounterTargetAngle + math.pi) * 5)
		local outv = Vector()
		
		SceneMan:CastStrengthRay(self.RandomEncounterFirePos , self.RandomEncounterTargetPos - self.RandomEncounterFirePos, 10, outv, 6, -1, true)
		
		self.RandomEncounterTargetImpactPos = outv
	end
	
	if self.RandomEncounterDroneActivated then
		self.RandomEncounterSourcePos = self.RandomEncounterSourcePos + self.RandomEncounterSourceVel	
		self.RandomEncounterTargetAngle = (self.RandomEncounterTargetPos - self.RandomEncounterSourcePos).AbsRadAngle

		if self.Time > self.RandomEncounterDroneNextFire - self.RandomEncounterDroneRechargeInterval then
			for i = self.RandomEncounterShotFired , 2 do
				local a = self.RandomEncounterTargetAngle
				self:AddObjectivePoint("DANGER!!!", self.RandomEncounterTargetImpactPos + Vector(-math.cos(a + math.pi) * (i * 50), -math.sin(a + math.pi) * (i * 50)) , CF.PlayerTeam, GameActivity.ARROWDOWN)
			end
		end
		
		if self.Time >= self.RandomEncounterDroneNextFire then
			local a = self.RandomEncounterTargetAngle
	
			for i = 1, 25 do
				local expl = CreateAEmitter("Destroyer Cannon Shot")
				expl.Pos = self.RandomEncounterFirePos + Vector(-math.cos(a + math.pi) * (i * 10), -math.sin(a + math.pi) * (i * 10))
				
				expl.Vel = Vector(-math.cos(a + math.pi) * 150, -math.sin(a + math.pi) * 150)
				expl.Mass = 1000000
				MovableMan:AddParticle(expl)
			end
			
			self.RandomEncounterShotFired = self.RandomEncounterShotFired + 1
			
			if self.RandomEncounterShotFired == 1 then
				self.RandomEncounterShotFired = 0
				self.RandomEncounterNeedTarget = true
				self.RandomEncounterDroneCharges = self.RandomEncounterDroneCharges - 1
				
				if self.RandomEncounterDroneCharges == 0 then
					self.MissionReport = {}
					self.MissionReport[#self.MissionReport + 1] = "The drone overloaded its' reactors and exploded."
					self:GiveRandomExperienceReward()
					CF.SaveMissionReport(self.GS, self.MissionReport)
				
					-- Finish encounter
					self.RandomEncounterID = nil
				end
				
				self.RandomEncounterDroneNextFire = self.Time + self.RandomEncounterDroneRechargeInterval
			else
				self.RandomEncounterDroneNextFire = self.Time
			end
		end
	end
end
--]]
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Reavers
local id = "REAVERS";
CF.RandomEncounters[#CF.RandomEncounters + 1] = id;

CF.RandomEncounterScripts[id] = "VoidWanderers.rte/Scripts/Encounters/Reavers.lua";
CF.RandomEncounterEligibilityTests[id] = function(self)
	return self.GS["Planet"] == "MapPack-Space"
		or self.GS["Planet"] == "MapPack-City"
		or self.GS["Planet"] == "MapPack-Earth"
		or self.GS["Planet"] == "Miranda"
		or self.GS["Planet"] == "The Breach"
		or self.GS["Planet"] == "CC-11y";
end;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Asteroid field
local id = "ASTEROIDS";
CF.RandomEncounters[#CF.RandomEncounters + 1] = id;

CF.RandomEncounterScripts[id] = "VoidWanderers.rte/Scripts/Encounters/AsteroidField.lua";
CF.RandomEncounterEligibilityTests[id] = function(self)
	return self.GS["Planet"] == "MapPack-Space";
end;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Faction assault
--[[
local id = "AMBUSH";
CF.RandomEncounters[#CF.RandomEncounters + 1] = id;

CF.RandomEncounterScripts[id] = "VoidWanderers.rte/Scripts/Encounters/FactionAmbush.lua";
CF.RandomEncounterEligibilityTests[id] = function(self)
	for i = 1, tonumber(self.GS["ActiveCPUs"]) do
		local rep = tonumber(self.GS["Player" .. i .. "Reputation"]);
		if rep <= CF.ReputationHuntThreshold then
			return true;
		end
	end
	return false;
end;--]]
--]]
-----------------------------------------------------------------------
-----------------------------------------------------------------------