if _G["VW_TeleporterList"] == nil then
	_G["VW_TeleporterList"] = {}
end
function Create(self)
	if _G["VW_TeleporterList"][self.PresetName] == nil then
		_G["VW_TeleporterList"][self.PresetName] = {}
	end
	--The number ID of this teleporter, used for communicating with other teleporters
	self.listID = #_G["VW_TeleporterList"][self.PresetName] + 1
	_G["VW_TeleporterList"][self.PresetName][self.listID] = self

	self.portTime = 2000
	self.portTimer = Timer()
	self.cooldown = Timer()
	self.coolTime = self.portTime

	self.flashTimer = Timer()
	self.flashTime = self.portTime * 0.25

	self.particleTimer = Timer()
	self.particleTimer:SetSimTimeLimitMS(50)

	self.radius = Vector(self:GetSpriteWidth() * 0.4, self:GetSpriteHeight() * 0.4)

	self.activity = ActivityMan:GetActivity()
end

function Update(self)
	if self.Sharpness ~= 0 then --Communicate cooldown reset
		self.cooldown:Reset()
		self.Sharpness = 0
	end
	local progress = math.min(self.portTimer.ElapsedSimTimeMS / self.portTime, 1)
	local inverseProgress = 1 - progress
	if self.Age > self.portTime and self.activity.ActivityState ~= Activity.EDITING then
		self:EnableEmission(true)
		self.Throttle = math.min(math.max(progress, 1 - self.cooldown.ElapsedSimTimeMS / self.coolTime), 1)
		self.EmitOffset = Vector(self.radius.X * RangeRand(-1, 1), 1 + self.radius.Y * RangeRand(-1, 1))
		if self.partner then
			self.SpriteAnimDuration = self.portTime * inverseProgress
			if self.cooldown:IsPastSimMS(self.portTime) then
				local targets = {}
				local toFlash = self.flashTimer:IsPastSimMS(self.flashTime * inverseProgress)
				for actor in MovableMan.Actors do
					if
						math.abs(self.Pos.X - actor.Pos.X) < self.radius.X
						and math.abs(self.Pos.Y - actor.Pos.Y) < self.radius.Y
						and actor.PinStrength == 0
					then
						table.insert(targets, actor)
						if toFlash then
							actor:FlashWhite(10)
						end
						if progress >= 1 then
							local pos = { self.Pos, self.partner.Pos }
							for i = 1, #pos do
								local fx = CreateAEmitter("Teleporter Effect A")
								fx.Pos = pos[i]
								MovableMan:AddParticle(fx)
								local glow = CreateMOPixel("Teleporter Glow", "VoidWanderers.rte")
								glow.Pos = pos[i]
								MovableMan:AddParticle(glow)
							end
							self.cooldown:Reset()
						end
					end
				end
				if toFlash then
					local glow = CreateMOPixel("Teleporter Glow Short", "VoidWanderers.rte")
					glow.Pos = self.Pos
					MovableMan:AddParticle(glow)

					self.flashTimer:Reset()
				end
				if #targets > 0 then
					if not self.cooldown:IsPastSimMS(self.portTime) then --Cooldown indicates that a teleportation happened
						--[[Telefrag??
						for actor in MovableMan.Actors do
							for _, target in pairs(targets) do
								if SceneMan:ShortestDistance(actor.Pos, pos, SceneMan.SceneWrapsX):MagnitudeIsLessThan(5) then
									actor:GibThis()
									break
								end
							end
						end]]
						--
						for _, actor in pairs(targets) do
							actor.Pos = self.partner.Pos
								+ SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX)
							actor:FlashWhite(250)
						end
						self.partner.Sharpness = 1
					end
				else
					self.portTimer:Reset()
				end
			else
				self.portTimer:Reset()
			end
		else
			self:EnableEmission(false)
			for i = 0, #_G["VW_TeleporterList"][self.PresetName] - 1 do
				local id = ((self.listID + i) % #_G["VW_TeleporterList"][self.PresetName]) + 1
				if
					id ~= self.listID
					and _G["VW_TeleporterList"][self.PresetName][id]
					and MovableMan:IsParticle(_G["VW_TeleporterList"][self.PresetName][id])
				then
					self.partner = _G["VW_TeleporterList"][self.PresetName][id]
					break
				end
			end
		end
	end
end

function Destroy(self)
	_G["VW_TeleporterList"][self.PresetName][self.listID] = nil
end
