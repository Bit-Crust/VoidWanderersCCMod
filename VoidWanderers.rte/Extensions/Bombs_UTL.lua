if PresetMan:GetModuleID("UTL.rte") ~= -1 then
	local n = #CF_BombNames + 1
	CF_BombNames[n] = "ADW 10kg CONCUS"
	CF_BombPresets[n] = "ADW 10kg CONCUS"
	CF_BombModules[n] = "UTL.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 60
	CF_BombDescriptions[n] =
		"A tiny concussion bomb that detonates at head height, good for taking out infantry without leaving craters everywhere."
	CF_BombOwnerFactions[n] = {}
	CF_BombUnlockData[n] = 0

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "ADW 10kg HE"
	CF_BombPresets[n] = "ADW 10kg HE"
	CF_BombModules[n] = "UTL.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 40
	CF_BombDescriptions[n] =
		"The most basic air deployed weapon availible from Ul-Tex, Cheap but effective. The concussive force of the explosion is likely to kill infantry outright."
	CF_BombOwnerFactions[n] = {}
	CF_BombUnlockData[n] = 0

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "ADW 10kg INCIN"
	CF_BombPresets[n] = "ADW 10kg INCIN"
	CF_BombModules[n] = "UTL.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 50
	CF_BombDescriptions[n] =
		"Need an instant barbeque? Ul-Tex is happy to oblige, the INCIN bomb detonates a small charge of Firex 5 to spread some warmth."
	CF_BombOwnerFactions[n] = {}
	CF_BombUnlockData[n] = 0

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "ADW 25kg AP"
	CF_BombPresets[n] = "ADW 25kg AP"
	CF_BombModules[n] = "UTL.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 160
	CF_BombDescriptions[n] =
		"Part of Ul-Tex's popular 25kg bomb range, the AP bomb detonates on impact, driving a dense core into the ground. The core will detonate when it detects a void infront of it or after three seconds. The AP bomb will reliably penetrate nine meters of concrete."
	CF_BombOwnerFactions[n] = {}
	CF_BombUnlockData[n] = 0

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "ADW 25kg CONCUS"
	CF_BombPresets[n] = "ADW 25kg CONCUS"
	CF_BombModules[n] = "UTL.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 140
	CF_BombDescriptions[n] =
		"A less common variant of Ul-Tex's popular 25kg bomb range, the CONCUS creates a deadly concussion wave that crushes skulls and shatters armour."
	CF_BombOwnerFactions[n] = {}
	CF_BombUnlockData[n] = 0

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "ADW 25kg FRAG"
	CF_BombPresets[n] = "ADW 25kg FRAG"
	CF_BombModules[n] = "UTL.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 120
	CF_BombDescriptions[n] =
		"Part of Ul-Tex's popular 25kg bomb range, the FRAG variant detonates above the target and showers the area in a withering hail of dense metal balls."
	CF_BombOwnerFactions[n] = {}
	CF_BombUnlockData[n] = 0

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "ADW 25kg HE"
	CF_BombPresets[n] = "ADW 25kg HE"
	CF_BombModules[n] = "UTL.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 100
	CF_BombDescriptions[n] = "The star of Ul-Tex's popular 25kg bomb range, good old Hi-Ex and lots of it."
	CF_BombOwnerFactions[n] = {}
	CF_BombUnlockData[n] = 0

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "ADW 25kg INCIN"
	CF_BombPresets[n] = "ADW 25kg INCIN"
	CF_BombModules[n] = "UTL.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 120
	CF_BombDescriptions[n] =
		"Pesky biologicals giving you trouble? What you need is a big 25kg pot of Firex goodness. Part of Ul-Tex's popular 25kg bomb line, the incendiary bomb is perfect for rooting organic enemies out of their holes."
	CF_BombOwnerFactions[n] = {}
	CF_BombUnlockData[n] = 0

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "ADW 50kg CLUST"
	CF_BombPresets[n] = "ADW 50kg CLUST"
	CF_BombModules[n] = "UTL.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 270
	CF_BombDescriptions[n] =
		"The most destructive of the 50kg bomb range. This sucker fires out sixty HE bomblets that spread out to cause maximum carnage."
	CF_BombOwnerFactions[n] = {}
	CF_BombUnlockData[n] = 0

	local n = #CF_BombNames + 1
	CF_BombNames[n] = "ADW 50kg FRAG"
	CF_BombPresets[n] = "ADW 50kg FRAG"
	CF_BombModules[n] = "UTL.rte"
	CF_BombClasses[n] = "TDExplosive"
	CF_BombPrices[n] = 250
	CF_BombDescriptions[n] =
		"Ul-Tex's 50kg bomb range, for when you absolutey definately NEED that squad of Browncoats dead. The FRAG variant sprays the target area with dense metal balls at high velocity."
	CF_BombOwnerFactions[n] = {}
	CF_BombUnlockData[n] = 0
end
