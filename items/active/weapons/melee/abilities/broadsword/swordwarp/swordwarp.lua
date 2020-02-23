require "/scripts/util.lua"
require "/scripts/status.lua"
require "/scripts/vec2.lua"
require "/items/active/weapons/weapon.lua"

SwordWarp = WeaponAbility:new()

function SwordWarp:init()
  self.cooldownTimer = self.cooldownTime
  self.windupTimer = self.windupTime
  self.warpTimer = self.warpTime
  fireOffset = copy(self.fireOffset)
end

function SwordWarp:update(dt, fireMode, shiftHeld)
	WeaponAbility.update(self, dt, fireMode, shiftHeld)
	
	self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
	
	if not self.weapon.currentAbility
		 and self.cooldownTimer == 0
		 and self.windupTimer > 0
		 and self.fireMode == (self.activatingFireMode or self.abilitySlot)
		 and mcontroller.onGround()
		 and not status.statPositive("activeMovementAbilities")
		 and status.consumeResource("energy", self.energyUsage) then
		self:setState(self.windup)
	end
end

function SwordWarp:windup()
	self.weapon:updateAim()
	
	while self.windupTimer > 0 and self.fireMode == (self.activatingFireMode or self.abilitySlot) do
		self.windupTimer = math.max(0, self.windupTimer - self.dt)
		if self.walkWhileFiring then mcontroller.controlModifiers({runningSuppressed = true}) end
		
		self.weapon.aimAngle = 0
		self.weapon:setStance(self.stances.windup)
		coroutine.yield()
	end
	self:setState(self.aiming) 
end

function SwordWarp:aiming()
	if self.windupTimer == 0 then
		self.weapon:setStance(self.stances.aiming)
	end
	
	while self.fireMode == (self.activatingFireMode or self.abilitySlot) do
		if self.walkWhileFiring then mcontroller.controlModifiers({runningSuppressed = true}) end
		
		coroutine.yield()
	end
	
	if self.windupTimer == 0 then
		self:setState(self.fire)
		else
		self:reset()
	end
		
end

function SwordWarp:fire()
	self.weapon:setStance(self.stances.fire)
	
	if not world.pointTileCollision(self.firePosition()) and status.overConsumeResource("energy", self.energyUsage) then
		local projectileParameters = copy(self.projectileParameters)
		projectileParameters.power = projectileParameters.power * self.weapon.damageLevelMultiplier
		self.thrownSword = world.spawnProjectile(
			self.projectileType,
			self:firePosition(),
			activeItem.ownerEntityId(),
			self:aimVector(),
			false,
			projectileParameters
			)
		animator.playSound("throw")
		animator.setAnimationState("blade", "hidden")
		self.windupTimer = 0
	end
	self.cooldownTimer = self.cooldownTime
	if self.thrownSword then
		self:setState(self.cooldown)
	end
end

function SwordWarp:cooldown()
	self.weapon:updateAim()
	self.weapon.aimAngle = 0
	self.weapon:setStance(self.stances.cooldown)
	while self.warpTimer > 0 do
		self.warpTimer = math.max(0, self.warpTimer - self.dt)
		coroutine.yield()
	end
	self.teleportTarget = world.entityPosition(self.thrownSword)
	self.weapon.aimAngle = 0
	self.weapon:setStance(self.stances.idle)
	if self.warpTimer == 0 then
		self:setState(self.attemptTeleport)
	end
	animator.setAnimationState("blade", "return")
end

function SwordWarp:attemptTeleport()
	if world.entityExists(self.thrownSword) then
		local playerPos = mcontroller.position()
		local newTarget = world.resolvePolyCollision(mcontroller.collisionPoly(), vec2.add(self.teleportTarget, self.teleportOffset), self.teleportTolerance)
		if newTarget and self.teleportTarget ~= nil then
			world.spawnProjectile("arachnesword6teleportout", playerPos)
			status.addEphemeralEffect("arachnesword6teleport")
			mcontroller.setYVelocity(0, 0)
			mcontroller.setPosition(newTarget)
		else
		end
	end
	animator.setAnimationState("blade", "return")
end

function SwordWarp:reset()
	self.windupTimer = self.windupTime
	self.cooldownTimer = self.cooldownTime
	self.warpTimer = self.warpTime
	self.teleportTarget = nil
	if animator.animationState("blade") == "hidden" then
		animator.setAnimationState("blade", "return")
	end
end
function SwordWarp:aimVector()
  local aimVector = vec2.rotate({1, 0}, self.weapon.aimAngle + sb.nrand(self.inaccuracy or 0, 0))
  aimVector[1] = aimVector[1] * self.weapon.aimDirection
  return aimVector
end

function SwordWarp:firePosition()
  return vec2.add(mcontroller.position(), activeItem.handPosition(fireOffset))
end

function SwordWarp:uninit()
	if self.thrownSword then
		world.sendEntityMessage(self.thrownSword, "kill")
	end
	self:reset()
end