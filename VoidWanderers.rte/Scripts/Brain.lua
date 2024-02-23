dofile("VoidWanderers.rte/Scripts/Brain_Create.lua")
dofile("VoidWanderers.rte/Scripts/Brain_Update.lua")
dofile("VoidWanderers.rte/Scripts/Brain_Destroy.lua")

function Create(self)
	do_rpgbrain_create(self)
end

function Update(self)
	do_rpgbrain_update(self)
end

function Destroy(self)
	do_rpgbrain_destroy(self)
end
