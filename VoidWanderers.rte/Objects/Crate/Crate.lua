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

	if not (self:HasStringValue("spawnPreset")) then
		local actorTypes = CF_Read(self, {"ActorTypes"});
		local factions = CF_Read(self, {"Factions"});
		local factionPlayable = CF_Read(self, {"FactionPlayable"});
		local artActPresets = CF_Read(self, {"ArtActPresets"});
		local artActClasses = CF_Read(self, {"ArtActClasses"});
		local artActModules = CF_Read(self, {"ArtActModules"});
		local actPresets = CF_Read(self, {"ActPresets"});
		local actClasses = CF_Read(self, {"ActClasses"});
		local actModules = CF_Read(self, {"ActModules"});

		local artifactActorRate = 0.2;
		local factionsPlayable = {};

		for i, faction in ipairs(factions) do
			if factionPlayable[faction] then
				table.insert(factionsPlayable, i);
			end
		end

		local faction = factions[factionsPlayable[math.random(#factionsPlayable)]];
		local actors = CF_Call(self, {"MakeListOfMostPowerfulActors"}, {faction, actorTypes.ANY, math.huge})[1];
		local isUsingArtifacts = math.random() < artifactActorRate or actors == nil;

		if isUsingArtifacts then
			local index = math.random(#artActPresets);

			self:SetStringValue("spawnPreset", artActPresets[index]);
			self:SetStringValue("spawnClass", artActClasses[index]);
			self:SetStringValue("spawnModule", artActModules[index]);
		else
			local index = math.random(#actors);
			local spawnFaction = faction;
			local spawnIndex = actors[index].Actor;

			self:SetStringValue("spawnPreset", actPresets[spawnFaction][spawnIndex]);
			self:SetStringValue("spawnClass", actClasses[spawnFaction][spawnIndex] or "AHuman");
			self:SetStringValue("spawnModule", actModules[spawnFaction][spawnIndex]);
		end
	end
end

function Update(self)
	local activity = ToGameActivity(ActivityMan:GetActivity());

	local removals = {};

	for i, actor in ipairs(self.registeredActors) do
		if actor and MovableMan:IsActor(actor) then
			local distance = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX).Magnitude;
			
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
			local distance = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX).Magnitude;

			if distance < self.interactDist + actor.IndividualRadius then
				local isNewSlice = actor.PieMenu:AddPieSliceIfPresetNameIsUnique(self.pieSliceToAdd:Clone(), self, true, true);
				
				if isNewSlice and not self.registeredFlags[actor] then
					self.registeredFlags[actor] = true;
					table.insert(self.registeredActors, actor);
				end
			end

			if distance < self.interactDist + actor.IndividualRadius + 3 then
				if actor:HasNumberValue("VW_AttemptAccess") then
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

	if not self:HasNumberValue("VW_AttemptAccess") and math.random(50, 100) < ActivityMan:GetActivity().Difficulty then
		local actor = CreateACrab("Crab", "Base.rte");
		actor.Pos = self.Pos;
		actor.Vel = Vector(0, -5);
		actor.Team = Activity.NOTEAM;
		actor.AIMode = Actor.AIMODE_PATROL;

		if math.random() < 0.9 then
			local item = CreateTDExplosive("Standard Bomb", "Base.rte");
			item:Activate();
			actor:AddInventoryItem(item);
		else
			for i = 1, 3 do
				local item = CreateMOSRotating("Anti Personnel Mine Active");
				item.Pos = self.Pos;
				item.Vel = Vector(math.random(5, 10), 0):RadRotate(RangeRand(-math.pi, math.pi));
				MovableMan:AddParticle(item);
			end
		end

		MovableMan:AddActor(actor);
	else
		local actor = ToActor(PresetMan:GetPreset(self:GetStringValue("spawnClass"), self:GetStringValue("spawnPreset"), self:GetStringValue("spawnModule"))):Clone();

		if actor then
			actor.AngularVel = 0;
			actor.Vel = Vector(0, -3);
			actor.Pos = self.Pos + Vector(0, -10);
			actor.Team = Activity.PLAYER_1;
			actor.AIMode = Actor.AIMODE_SENTRY;
		end

		if not actor then
			local sizes = { 10, 15, 24 };

			for i = 30, math.random(30, 60) do
				local item = CreateMOSRotating(sizes[math.random(#sizes)] .. "oz Gold Brick", "Base.rte");
				item.Pos = self.Pos;
				item.Vel = Vector(0, -3) + Vector(math.random(6), 0):RadRotate(math.pi * 2 * math.random());
				item.AngularVel = math.random(-4, 4);
				MovableMan:AddParticle(item);
			end
		else
			MovableMan:AddActor(actor);
		end
	end
end
