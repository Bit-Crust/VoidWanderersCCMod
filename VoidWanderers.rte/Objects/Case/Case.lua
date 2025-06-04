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

	function CF_Call(self, keys, arguments) 
		tempvar = nil;
		ActivityMan:GetActivity():SendMessage("call_in_CF", {self, keys, arguments});
		return tempvar;
	end

	function OnMessage(self, message, context)
		if message == "return_from_activity" then
			tempvar = context;
		end
	end
end

function Create(self)
	self.cost = self:GetGoldValue(0, 1, 1);
	self.text = "Open for " .. self.cost .. " gold";
	self.interactDist = 25;

	self.pieSliceToAdd = CreatePieSlice("Monetary Access");
	self.pieSliceToAdd.Description = self.text;

	self.registeredActors = {};
	self.registeredFlags = {};
	
	if not self:StringValueExists("spawnPreset") then
		local isUsingArtifacts = math.random() < 0.2;

		if not isUsingArtifacts then
			local weaponTypes = CF_Read(self, {"WeaponTypes"});
			local factions = CF_Read(self, {"Factions"});
			local factionPlayable = CF_Read(self, {"FactionPlayable"});
			local itmPresets = CF_Read(self, {"ItmPresets"});
			local itmClasses = CF_Read(self, {"ItmClasses"});
			local itmModules = CF_Read(self, {"ItmModules"});
			local factionsPlayable = {};

			for i, faction in ipairs(factions) do
				if factionPlayable[faction] then
					table.insert(factionsPlayable, i);
				end
			end

			local faction = factions[factionsPlayable[math.random(#factionsPlayable)]];
			local weapons = CF_Call(self, {"MakeListOfMostPowerfulWeapons"}, {faction, weaponTypes.ANY, math.huge})[1];
			
			if weapons == nil then
				isUsingArtifacts = true;
			else
				local index = math.random(#weapons);
				local spawnFaction = faction;
				local spawnIndex = weapons[index].Item;

				self:SetStringValue("spawnPreset", itmPresets[spawnFaction][spawnIndex]);
				self:SetStringValue("spawnClass", itmClasses[spawnFaction][spawnIndex] or "HDFirearm");
				self:SetStringValue("spawnModule", itmModules[spawnFaction][spawnIndex]);
			end
		end

		if isUsingArtifacts then
			local artItmPresets = CF_Read(self, {"ArtItmPresets"});
			local artItmClasses = CF_Read(self, {"ArtItmClasses"});
			local artItmModules = CF_Read(self, {"ArtItmModules"});

			local index = math.random(#artItmPresets);

			self:SetStringValue("spawnPreset", artItmPresets[index]);
			self:SetStringValue("spawnClass", artItmClasses[index]);
			self:SetStringValue("spawnModule", artItmModules[index]);
		end
	end
end

function Update(self)
	local activity = ToGameActivity(ActivityMan:GetActivity());

	local removals = {};

	for i, actor in ipairs(self.registeredActors) do
		if actor and MovableMan:IsActor(actor) then
			local distance = SceneMan:ShortestDistance(self.Pos, actor.Pos, true).Magnitude;
			
			if (not actor:IsPlayerControlled()) or distance > self.interactDist + actor.IndividualRadius then
				self.registeredFlags[actor] = nil;
				table.insert(removals, 1, i);
				actor.PieMenu:RemovePieSlicesByPresetName(self.pieSliceToAdd.PresetName);
			end
		else
			self.registeredFlags[actor] = nil;
			table.insert(removals, 1, i);
			actor.PieMenu:RemovePieSlicesByPresetName(self.pieSliceToAdd.PresetName);
		end
	end

	for i, removal in ipairs(removals) do
		table.remove(self.registeredActors, i);
	end

	for player = Activity.PLAYER_NONE + 1, Activity.MAXPLAYERCOUNT - 1 do
		local actor = activity:GetControlledActor(player);

		if actor then
			local distance = SceneMan:ShortestDistance(self.Pos, actor.Pos, true).Magnitude;

			if distance < self.interactDist + actor.IndividualRadius then
				local isNewSlice = actor.PieMenu:AddPieSliceIfPresetNameIsUnique(self.pieSliceToAdd:Clone(), self, true, true);
				
				if isNewSlice and not self.registeredFlags[actor] then
					self.registeredFlags[actor] = true;
					table.insert(self.registeredActors, actor);
				end
			end

			if distance < self.interactDist + actor.IndividualRadius + 3 then
				if actor:NumberValueExists("VW_AttemptAccess") then
					if actor.GoldCarried >= self.cost then
						actor.GoldCarried = actor.GoldCarried - self.cost;
					else
						self.cost = self.cost - actor.GoldCarried;
						actor.GoldCarried = 0;
						activity:ChangeTeamFunds(-self.cost, actor.Team);
					end

					actor:RemoveNumberValue("VW_AttemptAccess");
					self:SetNumberValue("VW_AttemptAccess", 1);
					self:GibThis();
				else
					local existingPieSlice = actor.PieMenu:GetFirstPieSliceByPresetName(self.pieSliceToAdd.PresetName);

					if existingPieSlice then
						existingPieSlice.Enabled = actor.GoldCarried >= self.cost or activity:GetTeamFunds(actor.Team) >= self.cost;
					end
				end
			end
		end
	end
end

function Destroy(self)
	for i, actor in ipairs(self.registeredActors) do
		if actor and MovableMan:IsActor(actor) then
			actor.PieMenu:RemovePieSlicesByPresetName(self.pieSliceToAdd.PresetName);
		end
	end

	if not self:NumberValueExists("VW_AttemptAccess") and math.random(50, 100) < ActivityMan:GetActivity().Difficulty then
		for i = 1, math.random(3) do
			local item = CreateTDExplosive("Frag Grenade", "Base.rte");
			item.Pos = self.Pos;
			item.Vel = Vector(math.random(-2, 2), math.random(-5, -3));
			item:Activate();
			MovableMan:AddItem(item);
		end
	else
		local item = ToHeldDevice(PresetMan:GetPreset(self:GetStringValue("spawnClass"), self:GetStringValue("spawnPreset"), self:GetStringValue("spawnModule"))):Clone();

		if item then
			item.AngularVel = 0;
			item.Vel = Vector(0, -3);
			item.Pos = self.Pos + Vector(0, -5);
		end

		if item then
			MovableMan:AddParticle(item);
		else
			local sizes = { 10, 15, 24 };

			for i = 30, math.random(30, 60) do
				local item = CreateMOSRotating(sizes[math.random(#sizes)] .. "oz Gold Brick", "Base.rte");
				item.Pos = self.Pos;
				item.Vel = Vector(0, -3) + Vector(math.random(6), 0):RadRotate(math.pi * 2 * math.random());
				item.AngularVel = math.random(-4, 4);
				MovableMan:AddParticle(item);
			end
		end
	end
end