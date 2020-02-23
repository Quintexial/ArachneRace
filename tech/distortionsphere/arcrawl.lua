require "/tech/distortionsphere/arachnedistortionsphere.lua"
require "/scripts/rect.lua"
require "/scripts/poly.lua"
require "/scripts/status.lua"

function init()
  initCommonParameters()
  self.ignorePlatforms = config.getParameter("ignorePlatforms")
  self.damageDisableTime = config.getParameter("damageDisableTime")
  self.damageDisableTimer = 0

  self.headingAngle = nil

  self.normalCollisionSet = {"Block", "Dynamic"}
  if self.ignorePlatforms then
    self.platformCollisionSet = self.normalCollisionSet
  else
    self.platformCollisionSet = {"Block", "Dynamic", "Platform"}
  end

  self.damageListener = damageListener("damageTaken", function(notifications)
    for _, notification in pairs(notifications) do
      if notification.healthLost > 0 and notification.sourceEntityId ~= entity.id() then
        damaged()
        return
      end
    end
  end)
end

function update(args)
  restoreStoredPosition()

  if not self.specialLast and args.moves["special1"] then
    attemptActivation()
  end
  self.specialLast = args.moves["special1"]

  if not args.moves["special1"] then
    self.forceTimer = nil
  end

  self.damageDisableTimer = math.max(0, self.damageDisableTimer - args.dt)

  self.damageListener:update()

  if self.active then
    local groundDirection
    if self.damageDisableTimer == 0 then
      groundDirection = findGroundDirection()
    end

    if groundDirection then
      if not self.headingAngle then
        self.headingAngle = (math.atan(groundDirection[2], groundDirection[1]) + math.pi / 2) % (math.pi * 2)
      end

      local moveX = 0
      if args.moves["right"] then moveX = moveX + 1 end
      if args.moves["left"] then moveX = moveX - 1 end
      if moveX ~= 0 then
        -- find any collisions in the moving direction, and adjust heading angle *up* until there is no collision
        -- this makes the heading direction follow concave corners
		tech.setParentState("Walk")
        local adjustment = 0
        for a = 0, math.pi, math.pi / 4 do
          local testPos = vec2.add(mcontroller.position(), vec2.rotate({moveX * 0.25, 0}, self.headingAngle + (moveX * a)))
          adjustment = moveX * a
          if not world.polyCollision(poly.translate(poly.scale(mcontroller.collisionPoly(), 1.0), testPos), nil, self.normalCollisionSet) then
            break
          end
        end
        self.headingAngle = self.headingAngle + adjustment

        -- find empty space in the moving direction and adjust heading angle *down* until it collides
        -- adjust to the angle *before* the collision occurs
        -- this makes the heading direction follow convex corners
        adjustment = 0
        for a = 0, -math.pi, -math.pi / 4 do
          local testPos = vec2.add(mcontroller.position(), vec2.rotate({moveX * 0.25, 0}, self.headingAngle + (moveX * a)))
          if world.polyCollision(poly.translate(poly.scale(mcontroller.collisionPoly(), 1.0), testPos), nil, self.normalCollisionSet) then
            break
          end
          adjustment = moveX * a
        end
        self.headingAngle = self.headingAngle + adjustment

        -- apply a gravitation like force in the ground direction, while moving in the controlled direction
        -- Note: this ground force causes weird collision when moving up slopes, result is you move faster up slopes
		mcontroller.setRotation(self.headingAngle)
		
		local playerID = entity.id()
		--local promise = world.sendEntityMessage(playerID,"arachneFindPrimary")
		--local promise2 = world.sendEntityMessage(playerID,"arachneFindAlt")
		local testAngle = math.sin(self.headingAngle)
		local testAngle2 = math.cos(self.headingAngle)
		local const = positionOffset()
		
		--sb.logInfo(sb.print(weaponPrimary))
		--sb.logInfo(sb.print(weaponAlt))
		--[[if weaponPrimary ~= nil then
			--local aimAnglePrimary = weaponPrimary.aimAngleAndDirection((testAngle2*const),tech.aimPosition())[1]
			--weaponPrimary.setArmAngle(aimAnglePrimary - self.headingAngle)
		end
		if weaponAlt ~= nil and weaponAlt ~= weaponPrimary then
			local aimAngleAlt = weaponAlt.aimAngleAndDirection((testAngle2*const),tech.aimPosition())[1]
			weaponAlt.setArmAngle(aimAngleAlt - self.headingAngle)
		end--]]
		--sb.logInfo(sb.print(testAngle))
		--sb.logInfo(sb.print(testAngle2))
		tech.setParentOffset({-(testAngle * const), (testAngle2 * const)})
        local groundAngle = self.headingAngle - (math.pi / 2)
        mcontroller.controlApproachVelocity(vec2.withAngle(groundAngle, self.ballSpeed), 300)

        local moveDirection = vec2.rotate({moveX, 0}, self.headingAngle)
        mcontroller.controlApproachVelocityAlongAngle(math.atan(moveDirection[2], moveDirection[1]), self.ballSpeed, 2000)

        self.angularVelocity = -moveX * self.ballSpeed
      else
		tech.setParentState("Stand")
        mcontroller.controlApproachVelocity({0,0}, 2000)
        self.angularVelocity = 0
      end

      mcontroller.controlDown()
      updateAngularVelocity(args.dt)

      self.transformedMovementParameters.gravityEnabled = false
    else
      updateAngularVelocity(args.dt)
      self.transformedMovementParameters.gravityEnabled = true
    end

    mcontroller.controlParameters(self.transformedMovementParameters)
    --status.setResourcePercentage("energyRegenBlock", 1.0)

    updateRotationFrame(args.dt)

    checkForceDeactivate(args.dt)
  else
    self.headingAngle = nil
  end

  updateTransformFade(args.dt)

  self.lastPosition = mcontroller.position()
end

function damaged()
  if self.active then
    self.damageDisableTimer = self.damageDisableTime
  end
end

function findGroundDirection()
  for i = 0, 3 do
    local angle = (i * math.pi / 2) - math.pi / 2
    local collisionSet = i == 1 and self.platformCollisionSet or self.normalCollisionSet
    local testPos = vec2.add(mcontroller.position(), vec2.withAngle(angle, 0.25))
    if world.polyCollision(poly.translate(mcontroller.collisionPoly(), testPos), nil, collisionSet) then
      return vec2.withAngle(angle, 1.0)
    end
  end
end
