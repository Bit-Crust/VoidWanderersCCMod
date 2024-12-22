-----------------------------------------------------------------------
-----------------------------------------------------------------------

-----------------------------------------------------------------------
function VoidWanderers:MissionCreate()
	print("ABANDONED VESSEL ZOMBIES CREATE")

	-- Spawn random wandering enemies
	local set = CF.GetRandomMissionPointsSet(self.Pts, "Deploy")
	local difficulty = self.missionData["difficulty"];

	local enm = CF.GetPointsArray(self.Pts, "Deploy", set, "AmbientEnemy")
	local enmpos = CF.RandomSampleOfList(enm, math.ceil(#enm / (8 - difficulty)))

	self.missionData["landingZones"] = CF.GetPointsArray(self.Pts, "Deploy", set, "EnemyLZ")

	-- Select faction
	self.missionData["selectedFaction"] = CF.GetPlayerFaction(self.GS, math.random(tonumber(self.GS["ActiveCPUs"])));
	local faction = self.missionData["selectedFaction"];

	local diff = CF.GetLocationDifficulty(self.GS, self.GS["Location"])
	difficulty = diff

	self.missionData["zombieRespawnInterval"] = 9 - difficulty
	self.missionData["zombieRespawnTime"] = self.Time
	self.missionData["zombieCount"] = math.random(15, 20) + difficulty
	self.missionData["artifactSpawned"] = false

	local rifles, snipers, pistols, grenades
	if PresetMan:GetModuleID("4Z.rte") ~= -1 then
		if difficulty < CF.MaxDifficulty * 0.5 then
			self.missionData["zombiePresetNames"] = { "4Zombie", "4Zombie", "4Zombie", "4Zombie Spitter", "4Zombie Bloater" }
		else
			self.missionData["zombiePresetNames"] = { "4Zombie", "4Zombie Spitter", "4Zombie Bloater", "4Zombie Mantis" }
		end
	else
		self.missionData["zombiePresetNames"] = { "Culled Clone", "Thin Culled Clone", "Fat Culled Clone" }
		-- Build random weapon lists
		
		local techLevel = CF.GetTechLevelFromDifficulty(faction, difficulty);
		rifles = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.RIFLE, techLevel)
		snipers = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.SNIPER, techLevel)
		pistols = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.PISTOL, techLevel)
		grenades = CF.MakeListOfMostPowerfulWeapons(faction, CF.WeaponTypes.GRENADE, techLevel)
	end

	local weaponPresets = {};

	if rifles ~= nil and #rifles > 0 then
		weaponPresets[#weaponPresets + 1] = rifles;
	end

	if snipers ~= nil and #snipers > 0 then
		weaponPresets[#weaponPresets + 1] = sniper;
	end

	if pistols ~= nil and #pistols > 0 then
		weaponPresets[#weaponPresets + 1] = pistols;
	end

	if grenades ~= nil and #grenades > 0 then
		weaponPresets[#weaponPresets + 1] = grenades;
	end

	self.missionData["weaponPresetNames"] = weaponPresets;

	-- Spawn some random zombies
	for i = 1, #enmpos do
		local zombie = CreateAHuman(self.missionData["zombiePresetNames"][math.random(#self.missionData["zombiePresetNames"])])
		if zombie then
			zombie.Pos = enmpos[i];
			zombie.Team = Activity.NOTEAM;
			zombie.HUDVisible = false;
			zombie.AIMode = Actor.AIMODE_GOTO;
			CF.BuffActor(zombie, math.random(math.min(difficulty, #CF.Ranks)), 0);
			local target = self.vesselData["ship"]:GetRandomPoint();
			zombie:AddAISceneWaypoint(target);

			if #self.missionData["weaponPresetNames"] ~= 0 then
				local r1 = math.random(#self.missionData["weaponPresetNames"])
				local r2 = math.random(#self.missionData["weaponPresetNames"][r1])
				local i = self.missionData["weaponPresetNames"][r1][r2]["Item"]
				local f = self.missionData["weaponPresetNames"][r1][r2]["Faction"]
				local w = CF.MakeItem(CF.ItmClasses[f][i], CF.ItmPresets[f][i], CF.ItmModules[f][i])

				if w ~= nil then
					zombie:AddInventoryItem(w)
				end
			end

			if not self.missionData["artifactSpawned"] and math.random() < difficulty / 200 then
				zombie:AddInventoryItem(CF.CreateBlackPrint())
				self.missionData["artifactSpawned"] = true
				self.missionData["essentialZombie"] = zombie;
			end

			MovableMan:AddActor(zombie)
			CF.HuntForActors(zombie, Activity.TEAM_1)
		end
	end

	for actor in MovableMan.Actors do
		if actor.ClassName == "ADoor" and math.random() < 0.50 then
			actor.GibSound = nil
			actor:GibThis()
		end
	end

	self:InitExplorationPoints()
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:MissionUpdate()
	self:ProcessExplorationPoints()
	local zombiesLeft = self.missionData["zombieCount"];

	if zombiesLeft > 0 and self.Time >= self.missionData["zombieRespawnTime"] then
		self.missionData["zombieRespawnTime"] = self.Time + self.missionData["zombieRespawnInterval"] + math.random(-2, 2);
		local spawnZones = self.missionData["landingZones"];

		if #spawnZones > 0 then
			local zombiePresets = self.missionData["zombiePresetNames"];
			local zombie = CreateAHuman(zombiePresets[math.random(#zombiePresets)]);

			if zombie then
				zombie.Pos = spawnZones[math.random(#spawnZones)];
				zombie.Team = Activity.NOTEAM;
				zombie.HUDVisible = false;
				zombie.AIMode = Actor.AIMODE_GOTO;
				CF.BuffActor(zombie, math.random(math.min(self.missionData["difficulty"], #CF.Ranks)), 0);
				local target = self.vesselData["ship"]:GetRandomPoint();
				zombie:AddAISceneWaypoint(target);

				local weaponPresets = self.missionData["weaponPresetNames"];

				if #weaponPresets > 0 then
					local weaponCategory = weaponPresets[math.random(#weaponPresets)];

					if #weaponCategory > 0 then
						local weaponIndex = math.random(#weaponCategory);
						local index = weaponCategory[weaponIndex]["Item"];
						local faction = weaponCategory[weaponIndex]["Faction"];
						local weapon = CF.MakeItem(CF.ItmClasses[faction][index], CF.ItmPresets[faction][index], CF.ItmModules[faction][index]);

						if weapon then
							zombie:AddInventoryItem(weapon);
						end
					end
				end

				if not self.missionData["artifactSpawned"] and math.random() < self.missionData["difficulty"] / 200 then
					zombie:AddInventoryItem(CF.CreateBlackPrint());
					self.missionData["artifactSpawned"] = true;
					self.missionData["essentialZombie"] = zombie;
				end

				MovableMan:AddActor(zombie);
				CF.HuntForActors(zombie, Activity.TEAM_1);
				self.missionData["zombieCount"] = zombiesLeft - 1;
			end
		end
	end
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
