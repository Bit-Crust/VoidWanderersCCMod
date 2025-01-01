-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Define pirate identities
CF.PirateBands = {};

-- Generic organic mid-heavy pirates
pirateBand = {};
pirateBand.Captain = "Apone";
pirateBand.Ship = "Sulako";
pirateBand.Org = "The Free Galactic Brotherhood";
pirateBand.FeeInc = 400;
pirateBand.Act = { "Raider", "Soldier Light", "Soldier Heavy", "Browncoat", "Exterminator" };
pirateBand.ActMod = { "Ronin.rte", "Coalition.rte", "Coalition.rte", "Browncoats.rte", "Browncoats.rte" };
pirateBand.Itm = { "AR-25 Hammerfist", "PY-07 Trailblazer", "M16A2", "Assault Rifle", "Auto Shotgun" };
pirateBand.ItmMod = { "Browncoats.rte", "Browncoats.rte", "Ronin.rte", "Coalition.rte", "Coalition.rte" };
pirateBand.Thrown = { "Shredder SB-08", "Timed Explosive" };
pirateBand.ThrownMod = { "Imperatus.rte", "Coalition.rte" };
pirateBand.Units = 12;
pirateBand.Burst = 3;
pirateBand.Interval = 14;
table.insert(CF.PirateBands, pirateBand);

-- Generic mid-heavy robot pirates
pirateBand = {};
pirateBand.Captain = "SHODAN";
pirateBand.Ship = "Von Braun";
pirateBand.Org = "The Free Nexus";
pirateBand.FeeInc = 500;
pirateBand.Act = { "Dummy", "All Purpose Robot", "Combat Robot", "Whitebot", "Silver Man" };
pirateBand.ActMod = { "Dummy.rte", "Imperatus.rte", "Imperatus.rte", "Techion.rte", "Techion.rte" };
pirateBand.Itm = { "Blaster", "Repeater", "Bullpup AR-14", "Mauler SG-23", "Pulse Rifle" };
pirateBand.ItmMod = { "Dummy.rte", "Dummy.rte", "Imperatus.rte", "Imperatus.rte", "Techion.rte" };
pirateBand.Thrown = { "Scrambler", "Timed Explosive" };
pirateBand.ThrownMod = { "Ronin.rte", "Coalition.rte" };
pirateBand.Units = 12;
pirateBand.Burst = 2;
pirateBand.Interval = 10;
table.insert(CF.PirateBands, pirateBand);

-- Pirates
local id = "PIRATE_GENERIC";
CF.RandomEncounters[#CF.RandomEncounters + 1] = id;

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
		local rep = tonumber(self.GS["Player" .. i .. "Reputation"]);
		if rep <= CF.ReputationHuntThreshold then
			return true;
		end
	end
	return false;
end;
--]]
-----------------------------------------------------------------------
-----------------------------------------------------------------------