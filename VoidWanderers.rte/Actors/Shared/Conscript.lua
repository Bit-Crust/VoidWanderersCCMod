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
	if not self:NumberValueExists("VW_ConscriptPrice") then
		self:SetNumberValue("VW_ConscriptPrice", math.ceil(self:GetTotalValue(0, 1, 1) * (1 + math.random())));
	end

	self.cost = self:GetNumberValue("VW_ConscriptPrice");
	self.text = "Conscript for " .. self.cost .. " gold";
	self.interactDist = 30;

	self.pieSliceToAdd = CreatePieSlice("Monetary Access");
	self.pieSliceToAdd.Description = self.text;

	self.registeredActors = {};
	self.registeredFlags = {};
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
				if actor:NumberValueExists("VW_AttemptAccess") then
					if actor.GoldCarried >= self.cost then
						actor.GoldCarried = actor.GoldCarried - self.cost;
					else
						self.cost = self.cost - actor.GoldCarried;
						actor.GoldCarried = 0;
						activity:ChangeTeamFunds(-self.cost, actor.Team);
					end

					actor:RemoveNumberValue("VW_AttemptAccess");

					for i, actor in ipairs(self.registeredActors) do
						if actor and MovableMan:IsActor(actor) then
							actor.PieMenu:RemovePieSlicesByPresetName(self.pieSliceToAdd.PresetName);
						end
					end

					self:ClearAIWaypoints();
					CF_Call(self, {"SetAlly"}, {self, false});
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