-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Pirates
local id = "PIRATE_GENERIC";
CF.RandomEncounters[#CF.RandomEncounters + 1] = id;
CF.PirateBands = {};

table.insert(CF.PirateBands, {
	Captain = "Apone",
	Ship = "Sulako",
	Org = "The Free Galactic Brotherhood",
	FeeInc = 400,
	Act = { "Raider", "Soldier Light", "Soldier Heavy", "Browncoat", "Exterminator" },
	ActMod = { "Ronin.rte", "Coalition.rte", "Coalition.rte", "Browncoats.rte", "Browncoats.rte" },
	Itm = { "AR-25 Hammerfist", "PY-07 Trailblazer", "M16A2", "Assault Rifle", "Auto Shotgun" },
	ItmMod = { "Browncoats.rte", "Browncoats.rte", "Ronin.rte", "Coalition.rte", "Coalition.rte" },
	Thrown = { "Shredder SB-08", "Timed Explosive" },
	ThrownMod = { "Imperatus.rte", "Coalition.rte" },
	Units = 12,
	Burst = 3,
	Interval = 14,
}); -- Generic organic mid-heavy pirates

table.insert(CF.PirateBands, {
	Captain = "SHODAN",
	Ship = "Von Braun",
	Org = "The Free Nexus",
	FeeInc = 500,
	Act = { "Dummy", "All Purpose Robot", "Combat Robot", "Whitebot", "Silver Man" },
	ActMod = { "Dummy.rte", "Imperatus.rte", "Imperatus.rte", "Techion.rte", "Techion.rte" },
	Itm = { "Blaster", "Repeater", "Bullpup AR-14", "Mauler SG-23", "Pulse Rifle" },
	ItmMod = { "Dummy.rte", "Dummy.rte", "Imperatus.rte", "Imperatus.rte", "Techion.rte" },
	Thrown = { "Scrambler", "Timed Explosive" },
	ThrownMod = { "Ronin.rte", "Coalition.rte" },
	Units = 12,
	Burst = 2,
	Interval = 10,
}); -- Generic mid-heavy robot pirates

CF.RandomEncounterScripts[id] = "VoidWanderers.rte/Scripts/Encounters/Pirates.lua";
CF.RandomEncounterEligibilityTests[id] = function(self)
	local validPlanet = self.GS["Planet"] ~= "TradeStar";
	return validPlanet and #CF.PirateBands > 0;
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
-- Hostile drone
local id = "HOSTILE_DRONE";
CF.RandomEncounters[#CF.RandomEncounters + 1] = id;
CF.RandomEncounterScripts[id] = "VoidWanderers.rte/Scripts/Encounters/HostileDrone.lua";
CF.RandomEncounterEligibilityTests[id] = function(self)
	return self.GS["Planet"] == "MapPack-Space"
		or self.GS["Planet"] == "MapPack-City"
		or self.GS["Planet"] == "Miranda"
		or self.GS["Planet"] == "CC-11Y";
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
		or self.GS["Planet"] == "MapPack-Snow"
		or self.GS["Planet"] == "Miranda"
		or self.GS["Planet"] == "CC-11Y";
end;
--]]
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Asteroid field
local id = "ASTEROIDS";
CF.RandomEncounters[#CF.RandomEncounters + 1] = id;
CF.RandomEncounterScripts[id] = "VoidWanderers.rte/Scripts/Encounters/AsteroidField.lua";
CF.RandomEncounterEligibilityTests[id] = function(self)
	return self.GS["Planet"] == "MapPack-Space"
		or self.GS["Planet"] == "CC-11Y";
end;
--]]
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Faction assault
local id = "AMBUSH";
CF.RandomEncounters[#CF.RandomEncounters + 1] = id;
CF.RandomEncounterScripts[id] = "VoidWanderers.rte/Scripts/Encounters/FactionAmbush.lua";
CF.RandomEncounterEligibilityTests[id] = function(self)
	for i = 1, tonumber(self.GS["ActiveCPUs"]) do
		local rep = tonumber(self.GS["Participant" .. i .. "Reputation"]);

		if rep <= CF.ReputationHuntThreshold then
			return true;
		end
	end

	return false;
end;
--]]
-----------------------------------------------------------------------
-----------------------------------------------------------------------