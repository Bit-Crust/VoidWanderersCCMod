local n = #CF_BombNames + 1
CF_BombNames[n] = "Standard Bomb"
CF_BombPresets[n] = "Standard Bomb"
CF_BombModules[n] = "Base.rte"
CF_BombClasses[n] = "TDExplosive"
CF_BombPrices[n] = 30
CF_BombDescriptions[n] = "Normal craft-bombardment bomb."
--Bomb owner factions determines which faction will sell you those bombs. If your relations are not good enough, then you won't get the bombs.
--If it's empty then bombs can be sold to any faction
CF_BombOwnerFactions[n] = {}
CF_BombUnlockData[n] = 0

local n = #CF_BombNames + 1
CF_BombNames[n] = "Napalm Bomb"
CF_BombPresets[n] = "Napalm Bomb"
CF_BombModules[n] = "Base.rte"
CF_BombClasses[n] = "TDExplosive"
CF_BombPrices[n] = 50
CF_BombDescriptions[n] =
	"Napalm craft-bombardment bomb. Rain flaming death upon troopers by cooking them with hot napalm ordnance!"
CF_BombOwnerFactions[n] = {}
CF_BombUnlockData[n] = 500

local n = #CF_BombNames + 1
CF_BombNames[n] = "Cluster Mine Bomb"
CF_BombPresets[n] = "Cluster Mine Bomb"
CF_BombModules[n] = "Base.rte"
CF_BombClasses[n] = "TDExplosive"
CF_BombPrices[n] = 120
CF_BombDescriptions[n] =
	"Mine field deployment bomb. Scatter mines across the battlefield to stop enemy advances! Explodes several meters above the ground to assure maximum coverage."
CF_BombOwnerFactions[n] = {}
CF_BombUnlockData[n] = 1000
