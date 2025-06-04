function VoidWanderers:AmbientCreate()
	self.AmbientSmokesNextHealthDamage = tonumber(self.GS["Time"])
	self.vesselData["ship"] = SceneMan.Scene:GetArea("Vessel")
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
function VoidWanderers:AmbientUpdate()

	--[[ Generate artificial gravity inside the ship

	local grav = 0.5 / (1 + SceneMan.Scene.GlobalAcc.Magnitude * 2)

	local coll = {MovableMan.Actors, MovableMan.Items}
	for i = 1, #coll do
		for mo in coll[i] do
			if mo.PinStrength == 0 then
				if self.vesselData["ship"]:IsInside(mo.Pos) then

					mo.Vel = mo.Vel + Vector(0, grav)
				else
					if tonumber(self.GS["Time"]) >= self.AmbientSmokesNextHealthDamage then
						self.AmbientSmokesNextHealthDamage = tonumber(self.GS["Time"]) + 1

						if IsActor(mo) and not actor:IsInGroup("Brains") then
							local actor = ToActor(mo)
							actor.Health = actor.Health - math.ceil(50 / math.sqrt(1 + math.abs(actor.Mass + actor.Material.StructuralIntegrity)))
							-- Push actor outwards from the ship
							actor.Vel = actor.Vel + SceneMan:ShortestDistance(Vector(SceneMan.SceneWidth / 2, SceneMan.SceneHeight / 2), actor.Pos, true) * 0.001
						end
					end
					-- God forbid you exit the ship when the engines are on
					if self.vesselData["engines"] ~= nil then
						for i = 1, #self.vesselData["engines"] do
							local em = self.vesselData["engines"][i]
							if em and IsAEmitter(em) and ToAEmitter(em):IsEmitting() then
								mo.Vel = mo.Vel + Vector(0.2, 0)
							end
						end
					end
					if IsAHuman(mo) then
					
						local actor = ToAHuman(mo)
						if actor.Status < 2 then
						
							local moveSpeed = 0.001

							actor.Status = 1	-- flaily
							local negNum = 1
							if actor.HFlipped == true then
								negNum = -1
							end

							actor.AngularVel = actor.AngularVel * 0.99 / math.sqrt(math.abs(actor.AngularVel * 0.05) + 1)

							actor.RotAngle = actor:GetAimAngle(true) - 1.57

							-- if actor.Jetpack then
							if actor:GetController():IsState(Controller.BODY_JUMP)	-- ability to still move altough zero g
							or actor:GetController():IsState(Controller.MOVE_RIGHT)
							or actor:GetController():IsState(Controller.MOVE_LEFT) then
								actor.Vel = actor.Vel + Vector(moveSpeed * math.sqrt(math.abs(actor.Health))/(actor.Vel.Magnitude + 1), 0):RadRotate(actor:GetAimAngle(true))
							end
							if actor:GetController():IsState(Controller.MOVE_RIGHT) then
								actor.Vel = actor.Vel + Vector(moveSpeed * math.sqrt(math.abs(actor.Health))/(actor.Vel.Magnitude + 1), 0)
							end
							if actor:GetController():IsState(Controller.MOVE_LEFT) then
								actor.Vel = actor.Vel + Vector(-moveSpeed * math.sqrt(math.abs(actor.Health))/(actor.Vel.Magnitude + 1), 0)
							end
							if actor:GetController():IsState(Controller.BODY_CROUCH) then
								actor:GetController():SetState(Controller.BODY_CROUCH, false)	-- avoid flinging yourself forwards
								actor.Vel = actor.Vel + Vector(0, moveSpeed * math.sqrt(math.abs(actor.Health))/(actor.Vel.Magnitude + 1))
							end
						end
					end
				end
			end
		end
	end]]
	--
end
-----------------------------------------------------------------------
--
-----------------------------------------------------------------------
