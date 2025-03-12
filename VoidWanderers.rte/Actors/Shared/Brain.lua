do
	local tempvar = nil;

	function CF_Read(self, keys) 
		tempvar = nil;
		ActivityMan:GetActivity():SendMessage("read_from_CF", {self, keys});
		return tempvar;
	end

	function CF_Write(keys, value) 
		ActivityMan:GetActivity():SendMessage("write_to_CF", {keys, value});
	end

	function GS_Read(self, key) 
		tempvar = nil;
		ActivityMan:GetActivity():SendMessage("read_from_GS", {self, key});
		return tempvar;
	end

	function GS_Write(key, value) 
		ActivityMan:GetActivity():SendMessage("write_to_GS", {key, value});
	end

	function CF_Call(self, keys, arguments) 
		tempvar = nil;
		ActivityMan:GetActivity():SendMessage("call_in_CF", {self, keys, arguments});
		return unpack(tempvar);
	end

	function OnMessage(self, message, context)
		if message == "return_from_activity" then
			tempvar = context;
		end
	end
end

function Create(self)
	-- Set up constants and temps
	local quantumCapacityPerLevel = CF_Read(self, {"QuantumCapacityPerLevel"});
	local reference = _G["To" .. self.ClassName](PresetMan:GetPreset(self.ClassName, self.PresetName, self.ModuleName));
	self.PieMenu:AddPieSlice(CreatePieSlice("RPG Brain PDA", "VoidWanderers.rte"), nil);
	
	self.distPerPower = 100;
	self.telekeneticCoolDown = 3000;
	self.healRange = 100;

	-- Set timers
	self.holdTimer = Timer();
	self.holdTimer:Reset();
	self.energyTickTimer = Timer();
	self.energyTickTimer:Reset();
	self.telekineticCoolDownTimer = Timer();
	self.telekineticCoolDownTimer:Reset();
	self.regenTimer = Timer();
	self.regenTimer:Reset();
	self.blinkTimer = Timer();
	self.blinkTimer:Reset();
	self.healSkillTimer = Timer();
	self.healSkillTimer:Reset();
	
	self.brainNumber = self:GetNumberValue("VW_BrainOfPlayer") - 1;

	self.level = 0;
	self.toughnessLevel = 0;
	self.shieldLevel = 0;
	self.telekinesisLevel = 0;
	self.scannerLevel = 0;
	self.healLevel = 0;
	self.selfHealLevel = 0;
	self.repairLevel = 0;
	self.splitterLevel = 0;
	self.quantumStorageLevel = 0;

	-- Obtain brain capabilities depending on type
	if self.brainNumber ~= Activity.PLAYER_NONE then -- If player controlled
		local player = self.brainNumber;
			
		self.level = tonumber(GS_Read(self, "Brain" .. player .. "Level"));
		self.toughnessLevel = tonumber(GS_Read(self, "Brain" .. player .. "Toughness"));
		self.shieldLevel = tonumber(GS_Read(self, "Brain" .. player .. "Field"));
		self.telekinesisLevel = tonumber(GS_Read(self, "Brain" .. player .. "Telekinesis"));
		self.scannerLevel = tonumber(GS_Read(self, "Brain" .. player .. "Scanner"));
		self.healLevel = tonumber(GS_Read(self, "Brain" .. player .. "Heal"));
		self.selfHealLevel = tonumber(GS_Read(self, "Brain" .. player .. "SelfHeal"));
		self.repairLevel = tonumber(GS_Read(self, "Brain" .. player .. "Fix"));
		self.splitterLevel = tonumber(GS_Read(self, "Brain" .. player .. "Splitter"));
		self.quantumStorageLevel = tonumber(GS_Read(self, "Brain" .. player .. "QuantumCapacity"));
	elseif self:GetNumberValue("VW_PreassignedSkills") ~= 0 then -- If preset with values
		self.level = self:GetNumberValue("VW_BrainLevel");
		self.toughnessLevel = self:GetNumberValue("VW_ToughSkill");
		self.shieldLevel = self:GetNumberValue("VW_ShieldSkill");
		self.telekinesisLevel = self:GetNumberValue("VW_TelekenesisSkill");
		self.scannerLevel = self:GetNumberValue("VW_ScannerSkill");
		self.healLevel = self:GetNumberValue("VW_HealSkill");
		self.selfHealLevel = self:GetNumberValue("VW_SelfHealSkill");
		self.repairLevel = self:GetNumberValue("VW_RepairSkill");
		self.splitterLevel = self:GetNumberValue("VW_SplitterSkill");
		self.quantumStorageLevel = self:GetNumberValue("VW_QuantumSkill");
	end

	-- Defaults are basically nothing but slight regen
	local healthProportion = self.Health / self.MaxHealth;
	self.MaxHealth = reference.MaxHealth * (100 + self.level) / 100;
	self.Health = self.MaxHealth * healthProportion;
	self.regenInterval = 2 - self.level * 0.01;

	self.energy = 100;
	self.maxEnergy = 100;

	self.quantumCapacity = (1 + self.quantumStorageLevel) * quantumCapacityPerLevel;
	self.quantumEfficacy = (self.splitterLevel + 1) * CF_Read(self, {"QuantumSplitterEffectiveness"});
	self.quantumStorage = 0;

	if self.brainNumber ~= Activity.PLAYER_NONE then
		local identityKey = "Brain" .. self.brainNumber .. "Identity";

		if GS_Read(self, identityKey) == nil then
			GS_Write(identityKey, tostring(self:GetNumberValue("Identity")));
		end

		self.quantumStorage = tonumber(GS_Read(self, "Brain" .. self.brainNumber .. "QuantumStorage"));
	end

	self.quantumStorage = math.max(0, self.quantumStorage);

	-- Determine enabled abilities
	self.distortEnabled = self.telekinesisLevel > 0;
	self.distortCost = 35;
	self.pushEnabled = self.telekinesisLevel > 1;
	self.pushCost = 25;
	self.weaponTeleportEnabled = self.telekinesisLevel > 2;
	self.weaponTeleportCost = 20;
	self.weaponStealEnabled = self.telekinesisLevel > 3;
	self.weaponSteal = 45;
	self.damageEnabled = self.telekinesisLevel > 4;
	self.damageCost = 65;

	-- Set up scanner
	self.scannerEnabled = false;
	self.scannerRange = 200 + self.scannerLevel * 160;

	-- Set up shield
	self.shieldEnabled = self.shieldLevel > 0;
	self.shieldRadius = 75;
	self.shieldRadiusPerPower = 25;
	self.shieldIneffectiveRadius = 25;
	self.shieldMinVelocity = 25;
	self.shieldPressure = 0;
	self.shieldPressureAmp = 10;
	self.shieldDepressureDelay = 1000;

	self.depressureTimer = Timer();
	self.depressureTimer:SetSimTimeLimitMS(self.shieldDepressureDelay);
	
	-- Set up healing capabilities
	local healSkillFactor = 1 - self.healLevel / 5;
	self.baseHealDelay = 40 + 200 * healSkillFactor;
	self.healIncrementPerTarget = 30 + 150 * healSkillFactor;
	self.healIncrementPerWound = 10 + 50 * healSkillFactor;
	self.healTimer = Timer();
	self.healTimer:SetSimTimeLimitMS(self.baseHealDelay);

	self.crossTimer = Timer();
	self.crossTimer:SetSimTimeLimitMS(800);

	self.visual = {};
	self.visual.Colors = { 135, 133, 149, 148, 145, 148, 149, 133 };
	self.visual.CurrentColor = 0;
	self.visual.Rotation = 0;
	self.visual.RPM = 60;
	self.visual.ArcCount = 3;

	self.maxHealRange = 50 + self.healLevel * 5;
	self.healTargets = {};

	-- Apply toughness buffs
	local toughnessFactor = (1 + self.toughnessLevel / 5);
	self.AimDistance = reference.AimDistance * toughnessFactor;
	self.ImpulseDamageThreshold = reference.ImpulseDamageThreshold * toughnessFactor;
	self.GibWoundLimit = reference.GibWoundLimit * toughnessFactor;
	self.GibImpulseLimit = reference.GibImpulseLimit * toughnessFactor;

	if self.BGArm and reference.BGArm then
		self.BGArm.GibWoundLimit = reference.BGArm.GibWoundLimit * toughnessFactor;
		self.BGArm.GibImpulseLimit = reference.BGArm.GibImpulseLimit * toughnessFactor;
		self.BGArm.GripStrength = 400000;
	end

	if self.FGArm and reference.FGArm then
		self.FGArm.GibWoundLimit = reference.FGArm.GibWoundLimit * toughnessFactor;
		self.FGArm.GibImpulseLimit = reference.FGArm.GibImpulseLimit * toughnessFactor;
		self.FGArm.GripStrength = 400000;
	end

	if self.BGLeg and reference.BGLeg then
		self.BGLeg.GibWoundLimit = reference.BGLeg.GibWoundLimit * toughnessFactor;
		self.BGLeg.GibImpulseLimit = reference.BGLeg.GibImpulseLimit * toughnessFactor;
	end

	if self.FGLeg and reference.FGLeg then
		self.FGLeg.GibWoundLimit = reference.FGLeg.GibWoundLimit * toughnessFactor;
		self.FGLeg.GibImpulseLimit = reference.FGLeg.GibImpulseLimit * toughnessFactor;
	end

	if self.Head and reference.Head then
		self.Head.GibWoundLimit = reference.Head.GibWoundLimit * toughnessFactor;
		self.Head.GibImpulseLimit = reference.Head.GibImpulseLimit * toughnessFactor;
	end

	if self.Jetpack and reference.Jetpack then
		local softnessFactor = math.sqrt(toughnessFactor);
		self.Jetpack.JetTimeTotal = reference.Jetpack.JetTimeTotal * softnessFactor;
		self.Jetpack.JetTimeLeft = reference.Jetpack.JetTimeLeft * softnessFactor;
		self.Jetpack.JetReplenishRate = reference.Jetpack.JetReplenishRate * softnessFactor;

		for em in self.Jetpack.Emissions do
			em.ParticlesPerMinute = em.ParticlesPerMinute * softnessFactor;
			em.BurstSize = em.BurstSize * softnessFactor;
		end
	end

	self.swarms = {};

	self.activeMenu = nil;
	self.selectedMenuItem = 1;

	self.skillDetectionTypes = {
		NONE = -1,
		SELF = 0,
		NEAREST = 1,
		ALL_ELIGIBLE = 2,
		HELD_DEVICE = 3,
		NEAREST_ITEM = 4,
		DETECTION_TYPE_COUNT = 5
	};
	
	-- Make skill sub-menu
	do
		self.skillMenu = {
			TopLeft = "Brain Skills",
			TopCenter = "",
			TopRight = self.quantumStorage .. " / " .. self.quantumCapacity .. "\242",
			BottomCenter = "L/R - Mode, Scroll - Item, Fire - Select",
			Update = function(self, owner)
				self.TopRight = owner.quantumStorage .. " / " .. owner.quantumCapacity .. "\242";

				if owner.EquippedItem ~= nil then
					local mass = owner.EquippedItem.Mass;
					local convert = owner.quantumEfficacy;
					local matter = math.floor(mass * convert);
					owner.nanolyzeSkillItem.Right = "+" .. tostring(matter) .. "\242";
				else
					owner.nanolyzeSkillItem.Right = "";
				end

				local selectedItem = self[owner.selectedMenuItem];

				-- Detect nearby target actor
				if selectedItem and selectedItem.Detection ~= owner.skillDetectionTypes.NONE then
					local detectionRange = selectedItem.DetectRange;
					local affectedActors = {};

					if selectedItem.Detection == owner.skillDetectionTypes.SELF then
						affectedActors[1] = owner;
					elseif selectedItem.Detection == owner.skillDetectionTypes.NEAREST then
						local affectedActor = nil;
				
						for actor in MovableMan.Actors do
							local dist = SceneMan:ShortestDistance(owner.Pos, actor.Pos, true).Magnitude;
							local withinRange = detectionRange >= dist;
							local onTeam = actor.Team == owner.Team;
							local typicalActor = actor.ClassName == "AHuman" or actor.ClassName == "ACrab";

							if onTeam and typicalActor and not CF_Call(owner, {"IsBrain"}, {actor}) and withinRange then
								affectedActor = actor;
								detectionRange = dist;
							end
						end

						affectedActors[1] = affectedActor;
					elseif selectedItem.Detection == owner.skillDetectionTypes.ALL_ELIGIBLE then
						for actor in MovableMan.Actors do
							local withinRange = detectionRange >= SceneMan:ShortestDistance(owner.Pos, actor.Pos, true).Magnitude;
							local onTeam = actor.Team == owner.Team;
							local typicalActor = actor.ClassName == "AHuman" or actor.ClassName == "ACrab";

							if withinRange and onTeam and typicalActor then
								table.insert(affectedActors, actor);
							end
						end
					elseif selectedItem.Detection == owner.skillDetectionTypes.HELD_DEVICE then
						affectedActors[1] = owner.EquippedItem or owner.EquippedBGItem;
					end

					if #affectedActors > 0 then
						owner.affectedActors = affectedActors;

						if owner.blinkTimer:IsPastSimMS(500) then
							owner.blinkTimer:Reset();

							for _, actor in ipairs(affectedActors) do
								actor:FlashWhite(25);
							end
						end
					end
				end
			end
		};

		if self.scannerLevel > 0 then
			local scannerEnabled = false;
			
			if owner.brainNumber ~= Activity.PLAYER_NONE then
				GS_Read(self, "Brain" .. self.brainNumber .. "ScannerEnabled") == "True";
			end
			
			local scannerOnPress = function(self, parent, owner)
				owner.scannerEnabled = not owner.scannerEnabled;
				
				if owner.brainNumber ~= Activity.PLAYER_NONE then
					GS_Write("Brain" .. owner.brainNumber .. "ScannerEnabled", tostring(owner.scannerEnabled));
				end

				owner.scannerSkillItem.Right = owner.scannerEnabled and "[ ON ]" or "[ OFF ]";
			end

			local skill = {
				Left = "Scanner",
				Center = "",
				Right = scannerEnabled and "[ ON ]" or "[ OFF ]",
				SubMenu = nil,
				DetectRange = nil,
				Detection = self.skillDetectionTypes.NONE,
				Function = scannerOnPress
			};

			table.insert(self.skillMenu, skill);
			self.scannerSkillItem = skill;
			self.scannerEnabled = scannerEnabled;
		end

		if self.repairLevel > 0 then
			local price = 10 - self.repairLevel;
		
			local repairOnPress = function(self, parent, owner)
				if owner.repairLevel > 0 and owner.quantumStorage >= price then
					local gun = owner.EquippedItem;
					if gun ~= nil then
						gun:RemoveWounds(gun:GetWoundCount());
						owner.quantumStorage = owner.quantumStorage - price;

						if owner.brainNumber ~= Activity.PLAYER_NONE then
							GS_Write("Brain" .. owner.brainNumber .. "QuantumStorage", owner.quantumStorage);
						end
					end
				end
			end
		
			local skill = {
				Left = "Repair weapon",
				Center = "",
				Right = "-" .. tostring(price) .. "\242",
				SubMenu = nil,
				DetectRange = nil,
				Detection = self.skillDetectionTypes.HELD_DEVICE,
				Function = repairOnPress
			};

			table.insert(self.skillMenu, skill);
			self.repairSkillItem = skill;
		end
		
		if self.healLevel > 0 then
			local price = 20 - 2 * self.healLevel;
		
			local healUnitOnPress = function(self, parent, owner)
				if owner.healLevel > 0 and owner.quantumStorage >= price and owner.healTarget == nil then
					local target = owner.affectedActors[1];

					if target and IsActor(target) then
						owner.healTarget = target;
						owner.healSkillTimer:Reset();
						owner.healingSwarm = SwarmCreate(owner, target);
						owner.quantumStorage = owner.quantumStorage - price;

						if owner.brainNumber ~= Activity.PLAYER_NONE then
							GS_Write("Brain" .. owner.brainNumber .. "QuantumStorage", owner.quantumStorage);
						end
					end
				end
			end

			local skill = {
				Left = "Heal unit",
				Center = "",
				Right = "-" .. tostring(price) .. "\242",
				SubMenu = nil,
				DetectRange = self.healRange,
				Detection = self.skillDetectionTypes.NEAREST,
				Function = healUnitOnPress
			};

			table.insert(self.skillMenu, skill);
			self.healSkillItem = skill;
		end

		if self.selfHealLevel > 0 then
			local price = 30 - 2 * self.selfHealLevel;
		
			local healSelfOnPress = function(self, parent, owner)
				if owner.selfHealLevel > 0 and owner.quantumStorage >= price and owner.healTarget == nil then
					local target = owner.affectedActors[1];

					if target and IsActor(target) then
						owner.healTarget = target;
						owner.healSkillTimer:Reset();
						owner.healingSwarm = SwarmCreate(owner, target);
						owner.quantumStorage = owner.quantumStorage - price;

						if owner.brainNumber ~= Activity.PLAYER_NONE then
							GS_Write("Brain" .. owner.brainNumber .. "QuantumStorage", owner.quantumStorage);
						end
					end
				end
			end
		
			local skill = {
				Left = "Heal self",
				Center = "",
				Right = "-" .. tostring(price) .. "\242",
				SubMenu = nil,
				DetectRange = 0.1,
				Detection = self.skillDetectionTypes.SELF,
				Function = healSelfOnPress
			};

			table.insert(self.skillMenu, skill);
			self.selfHealSkillItem = skill;
		end
	
		do
			local splitOnPress = function(self, parent, owner)
				if owner.EquippedItem ~= nil then
					if owner.quantumStorage < owner.quantumCapacity then
						local mass = owner.EquippedItem.Mass;
						local convert = owner.quantumEfficacy;
						local matter = math.floor(mass * convert);
						owner.quantumStorage = owner.quantumStorage + matter;

						if owner.quantumStorage > owner.quantumCapacity then
							owner.quantumStorage = owner.quantumCapacity;
						end
			
						if owner.brainNumber ~= Activity.PLAYER_NONE then
							GS_Write("Brain" .. owner.brainNumber .. "QuantumStorage", owner.quantumStorage);
						end
						
						owner.EquippedItem.ToDelete = true;
						owner:GetController():SetState(Controller.WEAPON_CHANGE_NEXT, true);
					end
				end
			end

			local skill = {
				Left = "Nanolyze item",
				Center = "",
				Right = "",
				SubMenu = nil,
				DetectRange = nil,
				Detection = self.skillDetectionTypes.HELD_DEVICE,
				Function = splitOnPress
			};

			table.insert(self.skillMenu, skill);
			self.nanolyzeSkillItem = skill;
		end
	end

	-- Make quantum sub-menu
	do
		local synthesizeOnPress = function(self, parent, owner)
			if owner.quantumStorage >= owner.activeMenu[owner.selectedMenuItem].Price then
				local preset = owner.activeMenu[owner.selectedMenuItem].Preset;
				local class = owner.activeMenu[owner.selectedMenuItem].Class;
				local module = owner.activeMenu[owner.selectedMenuItem].Module;

				local newgun = CF_Call(owner, {"MakeItem"}, {class, preset, module}):Clone();

				if newgun ~= nil then
					owner:AddInventoryItem(newgun);
					owner:GetController():SetState(Controller.WEAPON_CHANGE_PREV, true);

					owner.quantumStorage = owner.quantumStorage - owner.activeMenu[owner.selectedMenuItem].Price;
					owner.quantumMenuItem.Count = owner.quantumStorage;

					if owner.brainNumber ~= Activity.PLAYER_NONE then
						GS_Write("Brain" .. owner.brainNumber .. "QuantumStorage", owner.quantumStorage);
					end
				end
			end
		end
		
		self.quantumMenu = {
			TopLeft = "Item Synthesis",
			TopCenter = "",
			TopRight = self.quantumStorage .. " / " .. self.quantumCapacity .. " \242",
			BottomCenter = "Scroll - Item, Fire - Select",
			NextMenu = nil,
			PrevMenu = nil,
			Update = function(self, owner)
				self.TopRight = owner.quantumStorage .. " / " .. owner.quantumCapacity .. " \242";

				for i = 2, #self do
					self[i] = nil;
				end

				local quantumItems = CF_Read(owner, {"QuantumItems"});
				local quantumItemPresets = CF_Read(owner, {"QuantumItmPresets"});
				local quantumItemClasses = CF_Read(owner, {"QuantumItmClasses"});
				local quantumItemModules = CF_Read(owner, {"QuantumItmModules"});
				local quantumItemPrices = CF_Read(owner, {"QuantumItmPrices"});

				for i = 1, #quantumItems do
					local id = quantumItems[i];
					local class = quantumItemClasses[id];
					local preset = quantumItemPresets[id];
					local module = quantumItemModules[id];
					local price = quantumItemPrices[id];
					local gameStateKey = "UnlockedQuantum_" .. class .. "_" .. preset .. "_" .. module;

					if GS_Read(owner, gameStateKey) then
						local item = {
							Left = preset,
							Center = "",
							Right = "-" .. price .. "\242",
							SubMenu = nil,
							Function = synthesizeOnPress,

							ID = id,
							Class = class,
							Preset = preset,
							Module = module,
							Price = price
						};

						table.insert(self, item);
					end
				end
			end
		};
	end

	-- Make telekenesis sub-menu
	do
		self.telekenesisMenu = {
			TopLeft = "Telekenesis",
			TopCenter = "",
			TopRight = math.floor(self.energy / self.maxEnergy * 100) .. "%",
			BottomCenter = "L/R - Mode, Scroll - Item, Fire - Select",
			Update = function(self, owner)
				self.TopRight = math.floor(owner.energy / owner.maxEnergy * 100) .. "%";

				local selectedItem = self[owner.selectedMenuItem];

				-- Detect nearby target actor
				if selectedItem and selectedItem.Detection ~= owner.skillDetectionTypes.NONE then
					local detectionRange = selectedItem.DetectRange;
					local telekineticTargets = {};

					if selectedItem.Detection == owner.skillDetectionTypes.SELF then
						telekineticTargets[1] = owner;
					elseif selectedItem.Detection == owner.skillDetectionTypes.NEAREST then
						local affectedActor = nil;
				
						for actor in MovableMan.Actors do
							local dist = SceneMan:ShortestDistance(owner.Pos, actor.Pos, true).Magnitude;
							local withinRange = detectionRange >= dist;
							local onTeam = actor.Team ~= owner.Team;
							local typicalActor = actor.ClassName == "AHuman" or actor.ClassName == "ACrab";

							if onTeam and typicalActor and not CF_Call(owner, {"IsBrain"}, {actor}) and withinRange then
								affectedActor = actor;
								detectionRange = dist;
							end
						end

						telekineticTargets[1] = affectedActor;
					elseif selectedItem.Detection == owner.skillDetectionTypes.NEAREST_ITEM then
						local affectedItem = nil;
				
						for item in MovableMan.Items do
							local dist = SceneMan:ShortestDistance(owner.Pos, item.Pos, true).Magnitude;
							local withinRange = detectionRange >= dist;

							if withinRange then
								affectedItem = item;
								detectionRange = dist;
							end
						end

						telekineticTargets[1] = affectedItem;
					elseif selectedItem.Detection == owner.skillDetectionTypes.ALL_ELIGIBLE then
						for actor in MovableMan.Actors do
							local withinRange = detectionRange >= SceneMan:ShortestDistance(owner.Pos, actor.Pos, true).Magnitude;
							local onTeam = actor.Team ~= owner.Team;
							local typicalActor = actor.ClassName == "AHuman" or actor.ClassName == "ACrab";

							if withinRange and onTeam and not CF_Call(owner, {"IsBrain"}, {actor}) and typicalActor then
								table.insert(telekineticTargets, actor);
							end
						end
					elseif selectedItem.Detection == owner.skillDetectionTypes.HELD_DEVICE then
						telekineticTargets[1] = owner.EquippedItem or owner.EquippedBGItem;
					end

					owner.telekineticTargets = telekineticTargets;

					if #telekineticTargets > 0 then
						if owner.blinkTimer:IsPastSimMS(500) then
							owner.blinkTimer:Reset();

							for _, target in ipairs(telekineticTargets) do
								if IsMOSRotating(target) then
									ToMOSRotating(target):FlashWhite(25);
								end
							end
						end
					end
				end
			end
		};

		if self.shieldLevel > 0 then
			local shieldEnabled = false;
			
			if owner.brainNumber ~= Activity.PLAYER_NONE then
				GS_Read(self, "Brain" .. self.brainNumber .. "ShieldEnabled") ~= "False";
			end

			local shieldOnPress = function(self, parent, owner)
				owner.shieldEnabled = not owner.shieldEnabled;
				
				if owner.brainNumber ~= Activity.PLAYER_NONE then
					GS_Write("Brain" .. owner.brainNumber .. "ShieldEnabled", tostring(owner.shieldEnabled));
				end

				owner.shieldSkillItem.Right = owner.shieldEnabled and "[ ON ]" or "[ OFF ]";
			end

			local skill = {
				Left = "Shield",
				Center = "",
				Right = shieldEnabled and "[ ON ]" or "[ OFF ]",
				SubMenu = nil,
				DetectRange = self.distPerPower * self.telekinesisLevel,
				Detection = self.skillDetectionTypes.NONE,
				Function = shieldOnPress
			};

			table.insert(self.telekenesisMenu, skill);
			self.shieldSkillItem = skill;
			self.shieldEnabled = shieldEnabled;
		end

		if self.distortEnabled then
			local distortionOnPress = function(self, parent, owner)
				local threat = owner.telekineticTargets[1];

				if 
					owner.energy >= owner.distortCost
					and owner.distortEnabled
					and owner.telekineticCoolDownTimer:IsPastSimMS(owner.telekeneticCoolDown)
					and MovableMan:IsActor(threat)
				then
					owner.aimDistortSwarm = SwarmCreate(owner, threat);
					owner.aimDistortTarget = threat;

					owner.telekineticCoolDownTimer:Reset();
					owner.energy = owner.energy - owner.distortCost;
				end
			end
			
			local skill = {
				Left = "Distortion",
				Center = "",
				Right = self.distortCost .. "%",
				SubMenu = nil,
				DetectRange = self.distPerPower * self.telekinesisLevel,
				Detection = self.skillDetectionTypes.NEAREST,
				Function = distortionOnPress
			};

			table.insert(self.telekenesisMenu, skill);
			self.telekineticDistortItem = skill;
		end

		if self.pushEnabled then
			local telekineticPushOnPress = function(self, parent, owner)
				if
					owner.energy >= owner.pushCost
					and owner.pushEnabled
					and owner.telekineticCoolDownTimer:IsPastSimMS(owner.telekeneticCoolDown)
					and #owner.telekineticTargets > 0
				then
					for _, threat in ipairs(owner.telekineticTargets) do
						if MovableMan:IsActor(threat) then
							local pow = 600 * owner.telekinesisLevel;
							local angle = SceneMan:ShortestDistance(owner.Pos, threat.Pos, true).AbsRadAngle;
							threat:AddImpulseForce(Vector(math.cos(-angle) * pow, math.sin(-angle) * pow), Vector(0, 0));
							threat.Status = Actor.UNSTABLE;
			
							local pix = CreateMOPixel("Huge Glow");
							pix.Pos = threat.Pos;
							MovableMan:AddParticle(pix);
						end
					end
			
					local pix = CreateMOPixel("Huge Glow");
					pix.Pos = owner.Head.Pos;
					MovableMan:AddParticle(pix);

					owner.telekineticCoolDownTimer:Reset();
					owner.energy = owner.energy - owner.pushCost;
				end
			end

			local skill = {
				Left = "Push foe",
				Center = "",
				Right = self.pushCost .. "%",
				SubMenu = nil,
				DetectRange = self.distPerPower * self.telekinesisLevel,
				Detection = self.skillDetectionTypes.ALL_ELIGIBLE,
				Function = telekineticPushOnPress
			};

			table.insert(self.telekenesisMenu, skill);
			self.telekineticPushItem = skill;
		end

		if self.weaponTeleportEnabled then
			local weaponTeleportOnPress = function(self, parent, owner)
				local threat = owner.telekineticTargets[1];

				if
					owner.energy >= owner.weaponTeleportCost
					and owner.weaponTeleportEnabled
					and owner.telekineticCoolDownTimer:IsPastSimMS(owner.telekeneticCoolDown)
					and MovableMan:IsDevice(threat)
				then
					local pix = CreateMOPixel("Huge Glow");
					pix.Pos = owner.Head.Pos;
					MovableMan:AddParticle(pix);
			
					local pix = CreateMOPixel("Huge Glow");
					pix.Pos = threat.Pos;
					MovableMan:AddParticle(pix);

					owner:AddInventoryItem(MovableMan:RemoveItem(threat));

					owner.energy = owner.energy - owner.weaponTeleportCost;
					owner.telekineticCoolDownTimer:Reset();
				end
			end

			local skill = {
				Left = "Teleport item",
				Center = "",
				Right = self.weaponTeleportCost .. "%",
				SubMenu = nil,
				DetectRange = self.distPerPower * self.telekinesisLevel,
				Detection = self.skillDetectionTypes.NEAREST_ITEM,
				Function = weaponTeleportOnPress
			};

			table.insert(self.telekenesisMenu, skill);
			self.telekineticStealItem = skill;
		end

		if self.weaponStealEnabled then
			local weaponStealOnPress = function(self, parent, owner)
				local threat = owner.telekineticTargets[1];

				if
					owner.energy >= owner.weaponSteal
					and owner.weaponStealEnabled
					and owner.telekineticCoolDownTimer:IsPastSimMS(owner.telekeneticCoolDown)
					and MovableMan:IsActor(threat)
					and IsAHuman(threat)
				then
					local weap = ToAHuman(threat).EquippedItem;

					if weap then
						if weap.ClassName == "TDExplosive" then
							weap:GibThis();
						else
							local angle = SceneMan:ShortestDistance(owner.Pos, weap.Pos, true).AbsRadAngle;
							local newweap = weap:Clone();
							newweap.Pos = weap.Pos;

							newweap.Vel = Vector(
								-math.cos(-angle) * (2 * owner.telekinesisLevel),
								-math.sin(-angle) * (2 * owner.telekinesisLevel)
							);

							MovableMan:AddItem(newweap);
							weap.ToDelete = true;
						end

						local pix = CreateMOPixel("Huge Glow");
						pix.Pos = weap.Pos;
						MovableMan:AddParticle(pix);
			
						local pix = CreateMOPixel("Huge Glow");
						pix.Pos = owner.Pos;
						MovableMan:AddParticle(pix);

						owner.telekineticCoolDownTimer:Reset();
						owner.energy = owner.energy - owner.weaponSteal;
					end
				end
			end

			local skill = {
				Left = "Pull weapon",
				Center = "",
				Right = self.weaponStealCost .. "%",
				SubMenu = nil,
				DetectRange = self.distPerPower * self.telekinesisLevel,
				Detection = self.skillDetectionTypes.NEAREST,
				Function = weaponStealOnPress
			};

			table.insert(self.telekenesisMenu, skill);
			self.telekineticStealItem = skill;
		end

		if self.damageEnabled then
			local damageFoeOnPress = function(self, parent, owner)
				local threat = owner.telekineticTargets[1];

				if
					owner.energy >= owner.damageCost
					and owner.damageEnabled
					and owner.telekineticCoolDownTimer:IsPastSimMS(owner.telekeneticCoolDown)
					and MovableMan:IsActor(threat)
				then
					for i = 1, owner.telekinesisLevel / 4 do
						local pix = CreateMOPixel("Hit particle");
						pix.Pos = threat.Pos + Vector(-2 + math.random(4), -2 + math.random(4));
						pix.Vel = Vector(-2 + math.random(4), -2 + math.random(4));
						MovableMan:AddParticle(pix);
					end
			
					local pix = CreateMOPixel("Huge Glow");
					pix.Pos = threat.Pos;
					MovableMan:AddParticle(pix);
			
					local pix = CreateMOPixel("Huge Glow");
					pix.Pos = owner.Pos;
					MovableMan:AddParticle(pix);

					owner.damageThreat = threat;
					threat:AddAbsImpulseForce(Vector(0, -6), Vector(0, 0));

					owner.telekineticCoolDownTimer:Reset();
					owner.energy = owner.energy - owner.damageCost;
				end
			end

			local skill = {
				Left = "Kill",
				Center = "",
				Right = self.damageCost .. "%",
				SubMenu = nil,
				DetectRange = self.distPerPower * self.telekinesisLevel,
				Detection = self.skillDetectionTypes.NEAREST,
				Function = damageFoeOnPress
			};

			table.insert(self.telekenesisMenu, skill);
			self.telekineticDamageItem = skill;
		end
	end
	
	-- Make return sub-menu
	do
		self.returnMenu = {
			TopLeft = "Orbital Request",
			TopCenter = "",
			TopRight = 0 .. "\243 " .. 0 .. "\210",
			BottomCenter = "L/R - Mode, Scroll - Item, Fire - Select",
			Update = function(self, owner)
			end
		};

		local skill = {
			Left = "Request return beam",
			Center = "",
			Right = "0\210",
			Function = function(self)
				ActivityMan:GetActivity():SendMessage("request_immediate_return", {});
			end
		};

		table.insert(self.returnMenu, skill);
		self.requestReturnItem = skill;
	end

	-- Construct navigation
	local item = {
		Left = "",
		Center = "[ BACK ]",
		Left = "",
		SubMenu = self.skillMenu,
		Function = nil
	};

	table.insert(self.quantumMenu, item)
	self.skillMenuItem = item;

	local skill = {
		Left = "",
		Center = "[ Synthesis ]",
		Right = "",
		SubMenu = self.quantumMenu,
	};

	table.insert(self.skillMenu, skill);
	self.quantumMenuItem = skill;

	self.skillMenu.NextMenu = self.returnMenu;
	self.skillMenu.PrevMenu = self.telekenesisMenu;

	self.telekenesisMenu.NextMenu = self.skillMenu;
	self.telekenesisMenu.PrevMenu = self.returnMenu;
	
	self.returnMenu.NextMenu = self.telekenesisMenu;
	self.returnMenu.PrevMenu = self.skillMenu;

end

function Update(self)
	-- Don't do anything when in edit mode.
	if ActivityMan:GetActivity().ActivityState ~= Activity.RUNNING then
		return;
	end

	-- Brains do nothing while dead.
	if self.Health <= 0 or (not self.Head) or self.Status >= Actor.DYING then
		return;
	end

	-- Do distortion
	if MovableMan:IsActor(self.aimDistortTarget) then
		if not self.telekineticCoolDownTimer:IsPastSimMS(self.telekeneticCoolDown) then
			self.aimDistortTarget:GetController():SetState(Controller.AIM_UP, true);
			SwarmUpdate(self.aimDistortSwarm);

			if self.aimDistortTarget:GetAimAngle(false) < 0.75 then
				self.aimDistortTarget:GetController():SetState(Controller.WEAPON_FIRE, true);
			end
		else
			self.aimDistortTarget = nil;
			SwarmDestroy(self.aimDistortSwarm);
			self.aimDistortSwarm = nil;
		end
	end

	-- Do distortion after damage
	if MovableMan:IsActor(self.damageThreat) and not self.telekineticCoolDownTimer:IsPastSimMS(self.telekeneticCoolDown) then
		if self.damageDistortEnabled then
			self.damageThreat:GetController():SetState(Controller.BODY_CROUCH, true);
			self.damageThreat:GetController():SetState(Controller.AIM_DOWN, true);
		end
	else
		self.damageThreat = nil;
	end

	--CF.DrawString(tostring(self:GetAimAngle(true)), self.Pos + Vector(0,-110), 200, 200)
	--CF.DrawString(tostring(math.cos(self:GetAimAngle(false))), self.Pos + Vector(0,-100), 200, 200)
	--CF.DrawString(tostring(math.floor(self:GetAimAngle(true) * (180 / 3.14))), self.Pos + Vector(0,-90), 200, 200)

	-- Add power and health regen
	self.energy = math.min(self.maxEnergy, self.energy + self.telekinesisLevel * 1/60);
	self.Health = math.min(self.MaxHealth, self.Health + 1/60 / self.regenInterval);

	-- Draw power marker
	if self.telekinesisLevel > 0 and self.Head then
		local glownum = math.min(10, math.ceil(self.telekinesisLevel * 2 * (self.energy / 100)));

		if glownum > 0 then
			local pix = CreateMOPixel("Purple Glow " .. glownum, "VoidWanderers.rte");
			pix.Pos = self.Head.Pos + self.Vel / 3;
			MovableMan:AddParticle(pix);
		end
	end

	-- Process shield
	ProcessShield(self);

	-- Process scanner
	ProcessScanner(self);

	-- Process PDA input
	ProcessPDA(self);

	-- Process passive healing skill
	ProcessPassiveHealing(self);
	
	-- Process active healing ability
	ProcessActiveHealing(self);
		
	-- Process AI skill usage
	if self.Team ~= Activity.TEAM_1 then
		local healThreshold = 40;
		
		-- Heal itself
		if self.Health < healThreshold then
			self.affectedActors[1] = self;
			self.healSkillItem:Function(self.skillMenu, self);
		end

		-- Heal nearby actors
		local nearestTarget = nil;
		local dist = self.healRange;

		for actor in MovableMan.Actors do
			if actor.Team == self.Team and (actor.ClassName == "AHuman" or actor.ClassName == "ACrab") then
				local d = SceneMan:ShortestDistance(self.Pos, actor.Pos, true).Magnitude
				if d <= dist then
					if actor.Health < healThreshold then
						a = actor;
						dist = d;
						healThreshold = actor.Health;
					end
				end
			end
		end
				
		if nearestTarget ~= nil then
			self.affectedActors[1] = nearestTarget;
			self.healSkillItem:Function(self.skillMenu, self);
		end
	end

	if self:IsPlayerControlled() then
		local player = self.brainNumber;
		local camOff = CameraMan:GetOffset(ActivityMan:GetActivity():ScreenOfPlayer(player));
		local pos, text;

		pos = camOff + Vector(16, 11);
		text = "\242";
		CF_Call(self, { "DrawString" }, { text, pos, 135, 11, false, 11, 0, 0, 0, player });
		pos = camOff + Vector(27, 11);
		text = "Matter: " .. self.quantumStorage .. "/" .. self.quantumCapacity .. " q";
		CF_Call(self, { "DrawString" }, { text, pos, 135, 11, false, 11, 0, 0, 0, player });
		pos = camOff + Vector(16, 22);
		text = "\208";
		CF_Call(self, { "DrawString" }, { text, pos, 135, 11, false, 11, 0, 0, 0, player });
		pos = camOff + Vector(27, 22);
		text = "Psychic: " .. math.floor(self.energy / self.maxEnergy * 100) .. "%";
		CF_Call(self, { "DrawString" }, { text, pos, 135, 11, false, 11, 0, 0, 0, player });
	end
end

function ProcessScanner(self)
	if self.scannerLevel > 0 and self.scannerEnabled then
		for actor in MovableMan.Actors do
			if actor.ClassName ~= "ADoor" and actor.ClassName ~= "Actor" and actor.ID ~= self.ID then
				local shortestDistance = SceneMan:ShortestDistance(self.Head.Pos, actor.Pos, true)
				local a, d = shortestDistance.AbsRadAngle, shortestDistance.Magnitude

				if d < self.scannerRange then
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
		local shortestDistance = SceneMan:ShortestDistance(self.Head.Pos, self.ViewPoint, true)
		local a, d = shortestDistance.AbsRadAngle, shortestDistance.Magnitude
		local relpos = Vector(math.cos(-a) * (20 + (d * 0.1)), math.sin(-a) * (20 + (d * 0.1)))
		local effect = "Green Glow"
			
		local pix = CreateMOPixel(effect, "VoidWanderers.rte")
		pix.Pos = self.Head.Pos + relpos
		MovableMan:AddParticle(pix)
	end
end

function ProcessPassiveHealing(self)
	if self.healLevel > 0 then
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
					local trace = SceneMan:ShortestDistance(self.Pos, healTarget.Pos, true)
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
					local trace = SceneMan:ShortestDistance(self.Pos, actor.Pos, true)
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
end

function ProcessShield(self)
	if self.shieldEnabled and self.shieldLevel > 0 then
		local maximumPressure = (self.shieldRadius + self.shieldLevel * self.shieldRadiusPerPower) * self.shieldPressureAmp

		if self:IsStatus(Actor.UNSTABLE) then
			self.shieldPressure = maximumPressure
		end

		local radius = math.max(0, (maximumPressure - self.shieldPressure) / self.shieldPressureAmp)
		local massindex = 1 + ((5 - self.shieldLevel) * 0.20)

		if radius > self.shieldIneffectiveRadius then
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
				if projectile.HitsMOs and projectile.Vel:MagnitudeIsGreaterThan(self.shieldMinVelocity) then
					local incidentOffset = SceneMan:ShortestDistance(self.Head.Pos, projectile.Pos, true)
					local incidentAngle = incidentOffset.AbsRadAngle
					local tempVel = (projectile.Vel * 1):GetRadRotatedCopy(-incidentAngle) 

					if tempVel.X < 0 then
						if incidentOffset:MagnitudeIsGreaterThan(self.shieldIneffectiveRadius) then
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
				self.shieldPressure = self.shieldPressure + pressureTotal
				self.depressureTimer:Reset()
			end
		else
			local angle = math.random() * math.pi * 2
			local radius = math.random(self.shieldIneffectiveRadius)
			local pos = self.Head.Pos + Vector(math.cos(angle) * radius, math.sin(angle) * radius)
			if SceneMan:GetTerrMatter(pos.X, pos.Y) == 0 then
				local pix = CreateMOPixel("Purple Glow 1", "VoidWanderers.rte")
				pix.Pos = pos
				MovableMan:AddParticle(pix)
			end
		end

		if self.depressureTimer:IsPastSimMS(self.shieldDepressureDelay) then
			self.shieldPressure = math.max(0, math.min(maximumPressure, self.shieldPressure - 3 * self.shieldLevel))
		end
	end
end

function ProcessPDA(self)
	if self:IsPlayerControlled() then
		if self:NumberValueExists("VW_TogglePDA") then
			if self.PDAEnabled then
				self.PDAEnabled = false;
			else
				if self.Vel:MagnitudeIsLessThan(15) then
					self.PDAEnabled = true;
				end

				self.selectedMenuItem = 1;
				self.activeMenu = self.skillMenu;
			end

			self:RemoveNumberValue("VW_TogglePDA");
		end
	else
		self.PDAEnabled = false;
	end

	if self.PDAEnabled then
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(self.brainNumber);
		local pos = CameraMan:GetOffset(screen) + Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight);
		pos = pos - Vector(20, 20) - Vector(70, 53);

		local controller = self:GetController();
		local up = false;
		local down = false;
		local left = false;
		local right = false;
		local select = false;

		if not (controller:IsState(Controller.PIE_MENU_ACTIVE) or controller:IsState(Controller.PIE_MENU_OPENED)) then
			if controller:IsGamepadControlled() or controller:IsKeyboardOnlyControlled() then
				if controller:IsState(Controller.PRESS_UP) or controller:IsState(Controller.HOLD_UP) then
					up = controller:IsState(Controller.PRESS_UP);
					controller:SetState(Controller.BODY_JUMPSTART, false);
					controller:SetState(Controller.BODY_JUMP, false);
					controller:SetState(Controller.MOVE_UP, false);
					controller.AnalogMove = Vector(controller.AnalogMove.X,0);
				end

				if controller:IsState(Controller.PRESS_DOWN) or controller:IsState(Controller.HOLD_DOWN) then
					down = controller:IsState(Controller.PRESS_DOWN);
					controller:SetState(Controller.BODY_CROUCH, false);
					controller:SetState(Controller.MOVE_DOWN, false);
					controller.AnalogMove = Vector(controller.AnalogMove.X,0);
				end

				if controller:IsState(Controller.PRESS_PRIMARY) or controller:IsState(Controller.WEAPON_FIRE) then
					select = controller:IsState(Controller.PRESS_PRIMARY);
					controller:SetState(Controller.PRESS_PRIMARY, false);
					controller:SetState(Controller.WEAPON_FIRE, false);
				end
			else
				if controller:IsState(Controller.SCROLL_UP) then
					up = true;
					controller:SetState(Controller.SCROLL_UP, false);
					controller:SetState(Controller.WEAPON_CHANGE_PREV, false);
				end

				if controller:IsState(Controller.SCROLL_DOWN) then
					down = true;
					controller:SetState(Controller.SCROLL_DOWN, false);
					controller:SetState(Controller.WEAPON_CHANGE_NEXT, false);
				end

				if controller:IsState(Controller.WEAPON_CHANGE_PREV) then
					left = true;
					controller:SetState(Controller.WEAPON_CHANGE_PREV, false);
				end

				if controller:IsState(Controller.WEAPON_CHANGE_NEXT) then
					right = true;
					controller:SetState(Controller.WEAPON_CHANGE_NEXT, false);
				end

				if controller:IsState(Controller.PRESS_PRIMARY) or controller:IsState(Controller.WEAPON_FIRE) then
					select = controller:IsState(Controller.PRESS_PRIMARY);
					controller:SetState(Controller.PRESS_PRIMARY, false);
					controller:SetState(Controller.WEAPON_FIRE, false);
				end
			end
		end

		if left and self.activeMenu.PrevMenu then
			self.activeMenu = self.activeMenu.PrevMenu;
		end

		if right and self.activeMenu.NextMenu then
			self.activeMenu = self.activeMenu.NextMenu;
		end

		if up then
			self.selectedMenuItem = self.selectedMenuItem - 1;
		end

		if down then
			self.selectedMenuItem = self.selectedMenuItem + 1;
		end

		if self.selectedMenuItem < 1 then
			self.selectedMenuItem = #self.activeMenu;
		end

		if self.selectedMenuItem > #self.activeMenu then
			self.selectedMenuItem = 1;
		end

		if select and self.activeMenu[self.selectedMenuItem] and self.activeMenu[self.selectedMenuItem].SubMenu then
			self.activeMenu = self.activeMenu[self.selectedMenuItem].SubMenu;
			self.selectedMenuItem = 1;
			select = false;
		end

		local listStart = self.selectedMenuItem - (self.selectedMenuItem - 1) % 6;

		-- Draw background
		CF_Call(self, {"DrawMenuBox"}, {self.brainNumber, pos.X - 70, pos.Y - 39, pos.X + 70, pos.Y + 39});
		CF_Call(self, {"DrawMenuBox"}, {self.brainNumber, pos.X - 70, pos.Y - 53, pos.X + 70, pos.Y - 40});
		CF_Call(self, {"DrawMenuBox"}, {self.brainNumber, pos.X - 70, pos.Y + 40, pos.X + 70, pos.Y + 53});
		local lineOffset = -36;

		-- Draw skills menu
		local menu = self.activeMenu;
		local selectedItem = menu[self.selectedMenuItem];
		
		if menu then
			if menu.Update ~= nil then
				menu:Update(self);
			end

			local text = menu.TopLeft or "";
			CF_Call(self, {"DrawString"}, {text, pos + Vector(-67, -46), 135, 11, false, 11, 0, 1});
			local text = menu.TopCenter or "";
			CF_Call(self, {"DrawString"}, {text, pos + Vector(0, -46), 135, 11, false, 11, 1, 1});
			local text = menu.TopRight or "";
			CF_Call(self, {"DrawString"}, {text, pos + Vector(68, -46), 135, 11, false, 11, 2, 1});

			local text = menu.BottomCenter or "";
			CF_Call(self, {"DrawString"}, {text, pos + Vector(0, 46), 135, 11, true, 11, 1, 1});

			for i = listStart, listStart + 6 - 1 do
				local menuItem = menu[i];

				if menuItem then
					local prefix = i == self.selectedMenuItem and "> " or "";
					local text = (prefix .. menuItem.Left) or "";
					CF_Call(self, {"DrawString"}, {text, pos + Vector(-67, lineOffset), 135, 11, false, 11, 0});
					local text = menuItem.Center or "";
					CF_Call(self, {"DrawString"}, {text, pos + Vector(0, lineOffset), 135, 11, false, 11, 1});
					local text = menuItem.Right or "";
					CF_Call(self, {"DrawString"}, {text, pos + Vector(68, lineOffset), 135, 11, false, 11, 2});
					lineOffset = lineOffset + 11;
				end
			end 
		end

		if select then
			if not self.firePressed then
				self.firePressed = true;

				-- Execute skill function
				if selectedItem and selectedItem.Function ~= nil then
					selectedItem:Function(menu, self);
				end
			end
		else
			self.firePressed = false;
		end
	end
end

function ProcessActiveHealing(self)
	if self.healTarget ~= nil then
		SwarmUpdate(self.healingSwarm);

		if self.healSkillTimer:IsPastSimMS(6000) then
			if self.healTarget and IsActor(self.healTarget) then
				local missingLimbs = {};
				local replacedLimbs = {};

				-- function(item, class, module, xp, identity, player, prestige, name, limbs)
				local referenceActor = CF_Call(self, {"MakeActor"}, {
					self.healTarget.ClassName,
					self.healTarget.PresetName,
					self.healTarget.ModuleName,
					self.healTarget:GetNumberValue("VW_XP"),
					self.healTarget:GetNumberValue("Identity"),
					self.healTarget:GetNumberValue("VW_BrainOfPlayer"),
					self.healTarget:GetNumberValue("VW_Prestige")
				});

				if referenceActor then
					local possibleLimbs = {};

					if referenceActor.ClassName == "AHuman" then
						self.healTarget = ToAHuman(self.healTarget);
						self.healTarget:UnequipArms();
						possibleLimbs = {"Head", "FGArm", "BGArm", "FGLeg", "BGLeg"};
					elseif referenceActor.ClassName == "ACrab" then
						self.healTarget = ToACrab(self.healTarget);
						possibleLimbs = {"Turret", "LFGLeg", "LBGLeg", "RFGLeg", "RBGLeg"};
					end

					for i = 1, #possibleLimbs do
						missingLimbs[i] = false;
						replacedLimbs[i] = false;

						if self.healTarget[possibleLimbs[i]] then
							if referenceActor[possibleLimbs[i]] and referenceActor[possibleLimbs[i]].PresetName ~= self.healTarget[possibleLimbs[i]].PresetName then
								replacedLimbs[i] = true;
								self.healTarget[possibleLimbs[i]] = referenceActor[possibleLimbs[i]]:Clone();
							end
						else
							missingLimbs[i] = true;
						end
					end

					if referenceActor.ClassName == "AHuman" then
						self.healTarget:GetController():SetState(Controller.WEAPON_CHANGE_PREV, true);
					end

					referenceActor.ToDelete = true;
				end

				self.healTarget = nil;
			end

			SwarmDestroy(self.healingSwarm);
			self.healingSwarm = nil;
		end
	end
end

function SwarmCreate(self, target)
	local swarm = {};

	swarm.InitialWasps = 25;
	swarm.WaspFlickerProbability = 0.2;
	swarm.WaspRoster = {};
	swarm.WaspOffsets = {};
	swarm.CloudPos = self.Pos;
	swarm.CloudRadius = 15;
	swarm.CloudMaxSpeed = 5;
	swarm.CloudTarget = target;
	swarm.CloudOutterBound = 75;

	for i = 1, swarm.InitialWasps do
		local wasp = CreateMOPixel("Purple Glow 1", "VoidWanderers.rte");

		if wasp then
			wasp:SetEffectStrength(0.25);
			wasp.Vel = Vector(math.random(-10, 10), math.random(-10, 10));
			swarm.WaspOffsets[i] = Vector(math.random(-swarm.CloudRadius, swarm.CloudRadius), math.random(-swarm.CloudRadius, swarm.CloudRadius));
			wasp.Pos = swarm.CloudPos + swarm.WaspOffsets[i];
			MovableMan:AddParticle(wasp);
			swarm.WaspRoster[i] = wasp;
		end
	end
	
	return swarm;
end

function SwarmUpdate(self)
	--Make all the wasps in this swarm's WaspRoster follow it.
	if MovableMan:IsActor(self.CloudTarget) then
		for i = 1, #self.WaspRoster do
			if MovableMan:IsParticle(self.WaspRoster[i]) then
				local wasp = self.WaspRoster[i];

				--Keep the wasp alive.
				wasp.ToDelete = false;
				wasp.ToSettle = false;
				wasp:NotResting();
				wasp.Age = 0;

				--Make the wasp follow the swarm.
				local target = self.CloudTarget.Pos + self.WaspOffsets[i];
				local baseVector = SceneMan:ShortestDistance(wasp.Pos, target, true);
				local dirVector = baseVector / baseVector.Largest;
				local dist = baseVector.Magnitude;
				local modifier = math.max(dist / 5);

				wasp.Vel = wasp.Vel + dirVector * math.random() * modifier;

				--Keep the wasp from going too fast.
				local speedMod = math.max(1, SceneMan:ShortestDistance(wasp.Pos, target, true).Magnitude / 5);

				--Counteract gravity.
				wasp.Vel.Y = wasp.Vel.Y - SceneMan.Scene.GlobalAcc.Y * TimerMan.DeltaTimeSecs;

				if wasp.Vel.Largest > self.CloudMaxSpeed * speedMod then
					wasp.Vel = (wasp.Vel / wasp.Vel.Largest) * self.CloudMaxSpeed * speedMod;
				end

				--Keep the wasp within decent bounds of the swarm.
				local distVec = SceneMan:ShortestDistance(target, wasp.Pos, true);

				if math.abs(distVec.Largest) > self.CloudOutterBound then
					wasp.Pos = distVec:SetMagnitude(self.CloudOutterBound) + target;
				end

				--Flicker.
				if math.random() <= self.WaspFlickerProbability then
					local flicker = CreateMOPixel("Purple Glow 5", "VoidWanderers.rte");
					flicker:SetEffectStrength(0.5);
					flicker.Pos = wasp.Pos;
					MovableMan:AddParticle(flicker);
				end
			else
				if #self.WaspRoster < self.InitialWasps then
					local wasp = CreateMOPixel("Purple Glow 1", "VoidWanderers.rte");
					wasp.Pos = self.Pos + self.WaspOffsets[i];
					wasp.Vel = Vector(math.random(-10, 10), math.random(-10, 10));
					MovableMan:AddParticle(wasp);
					self.WaspRoster[i] = wasp;
				else
					table.remove(self.WaspRoster, i);
				end
			end
		end
	else
		SwarmDestroy(self);
	end
end

function SwarmDestroy(self)
	if self.WaspRoster ~= nil then
		for i = 1, #self.WaspRoster do
			if MovableMan:IsParticle(self.WaspRoster[i]) then
				self.WaspRoster[i].ToDelete = true;
			end
		end
	end
end