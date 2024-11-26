local n = #CF.BombNames + 1
CF.BombNames[n] = "Standard Bomb"
CF.BombPresets[n] = "Standard Bomb"
CF.BombModules[n] = "Base.rte"
CF.BombClasses[n] = "TDExplosive"
CF.BombPrices[n] = 30
CF.BombDescriptions[n] = "Normal craft-bombardment bomb."
--Bomb owner factions determines which faction will sell you those bombs. If your relations are not good enough, then you won't get the bombs.
--If it's empty then bombs can be sold to any faction
CF.BombOwnerFactions[n] = {}
CF.BombUnlockData[n] = 0

local n = #CF.BombNames + 1
CF.BombNames[n] = "Napalm Bomb"
CF.BombPresets[n] = "Napalm Bomb"
CF.BombModules[n] = "Base.rte"
CF.BombClasses[n] = "TDExplosive"
CF.BombPrices[n] = 50
CF.BombDescriptions[n] =
	"Napalm craft-bombardment bomb. Rain flaming death upon troopers by cooking them with hot napalm ordnance!"
CF.BombOwnerFactions[n] = {}
CF.BombUnlockData[n] = 500

local n = #CF.BombNames + 1
CF.BombNames[n] = "Cluster Mine Bomb"
CF.BombPresets[n] = "Cluster Mine Bomb"
CF.BombModules[n] = "Base.rte"
CF.BombClasses[n] = "TDExplosive"
CF.BombPrices[n] = 120
CF.BombDescriptions[n] =
	"Mine field deployment bomb. Scatter mines across the battlefield to stop enemy advances! Explodes several meters above the ground to assure maximum coverage."
CF.BombOwnerFactions[n] = {}
CF.BombUnlockData[n] = 1000
