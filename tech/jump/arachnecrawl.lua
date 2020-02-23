require "/scripts/util.lua"
require "/scripts/rect.lua"
require "/scripts/poly.lua"
require "/tech/jump/multijump.lua"
require "/scripts/vec2.lua"
require "/scripts/interp.lua"

-- Crawl up on walls and ceilings
-- Requires the bound box to be square with the origin in the center OR DOES IT

-- param direction
-- param run
-- output headingDirection
-- output headingAngle
local wait = 0.5
local pause = 0.15
local lastRotation = 0
local fullRotation = 0

function init()
	self.movementParameters = config.getParameter("hitbox")
end

function update(args, board)
  local bounds = mcontroller.boundBox()
  local size = bounds[3] - bounds[1]
  --local newBounds = [ [-2.0, -2], [-1.6, -2.5], [0.35, -2.5], [0.75, -2.0], [0.75, 0.65], [0.35, 1.22], [-0.35, 1.22], [-0.75, 0.65], [-0.75, -0.35], [-1.6, -0.35], [-2.0, -0.85] ]
  
  local groundDirection = findGroundDirection()
  if not groundDirection then --[[sb.logInfo("Failed to find gD arachne")]] return false end

  local baseParameters = mcontroller.baseParameters()
  local moveSpeed = args.run and baseParameters.runSpeed or baseParameters.walkSpeed
  --sb.logInfo("Arachne MS: "..moveSpeed)
  local headingAngle
  --while true do
    local groundDirection = findGroundDirection()
	local direction = nil
	
	local old = mcontroller.collisionPoly()
      local poly = config.getParameter("hitbox").collisionPoly
	  if old ~= poly then
		sb.logInfo(sb.print(poly))
	  end
	 --mcontroller.controlParameters(self.movementParameters)
	  
	if args.moves["jump"] then
		tech.setParentState("fly")
		pause = 0.15
		detach(args,board)
		return false
		--Try nothing?
	elseif args.moves["left"] and pause <= 0 then
		direction = -1
	elseif args.moves["right"] and pause <= 0 then
		direction = 1
	elseif pause <= 0 then
		tech.setParentState("stand")
		wallSit(args,board)
		return false
	else
		pause = pause - args.dt
	end
	--[[for i,v in pairs(groundDirection) do
		sb.logInfo("Arachne Ground Direction: "..i.." , "..v)
	end]]
    if groundDirection then
      --if not headingAngle then
		--[[if groundDirection[1] - 0.0001 < 0 then
			--sb.logInfo("GD 1 is small!")
			if groundDirection[2] * groundDirection[1] < 0 then
				--sb.logInfo("Negative!")
				headingAngle = (math.atan(-999999999999999999) + math.pi / 2) % (math.pi * 2)
			else
				sb.logInfo("Positive!")
				headingAngle = (math.atan(999999999999999999) + math.pi / 2) % (math.pi * 2)
			end
		else]]
			headingAngle = (math.atan(groundDirection[2] / groundDirection[1]) + math.pi / 2) % (math.pi * 2)
		--end
      --end
	  sb.logInfo("Arachne Heading Angle PRE: "..headingAngle)
      if direction == nil then sb.logInfo("Arachne direction not found!") return false end
	  
	  --sb.logInfo("Arachne Moving Direction:"..direction)

      headingAngle = adjustCornerHeading(headingAngle, direction)
	  --sb.logInfo("Arachne Heading Angle: "..headingAngle)

	  --if args.moves["left"] or args.moves["right"] then
	  
		local rotators = {0, 0.5, 1, 1.5}
		local check = headingAngle / math.pi
		local small = math.huge
		local rotated = headingAngle / math.pi
		if check < 0 then
			check = check * -1
		end
			check = check % 2
		for i,v in pairs(rotators) do
			if small > v - check then
				small = v - check
				rotated = v
			end
		if small < 0 then
			small = small * -1
		end
		end
		rotated = rotated * math.pi
		
		sb.logInfo("Arachne Rotated Angle: "..rotated)
		
		local groundAngle = fullRotation - (math.pi / 2)
		mcontroller.controlApproachVelocity(vec2.withAngle(groundAngle, moveSpeed), 150)
		
		local moveDirection = vec2.rotate({direction, 0}, fullRotation)
		sb.logInfo("Movement Angle: "..math.atan(moveDirection[2], moveDirection[1]))
		mcontroller.controlApproachVelocityAlongAngle(math.atan(moveDirection[2], moveDirection[1]), moveSpeed, 1000)
		tech.setParentState("walk")
	  --else
		--mcontroller.setVelocity(vec2.withAngle(groundAngle, moveSpeed), 50)
	  --end
	  
      mcontroller.controlParameters({
        gravityEnabled = false
      })

	  --sb.logInfo("Arachne Last Rotation Angle: "..lastRotation)
	  --sb.logInfo("Old Bound Box: "..old)
	  
	  if wait <= 0 then
		--[[local moveDirection = vec2.rotate({direction, 0}, rotated)
		mcontroller.controlApproachVelocityAlongAngle(math.atan(moveDirection[2], moveDirection[1]), moveSpeed, 2000)
		tech.setParentState("walk")]]
		--mcontroller.setRotation(rotated)
		--args.angle = rotated
		--args.transformationGroup = "body"
		--rotateBody(args,board)
		if fullRotation / math.pi == 0.5 then
		--tech.setParentDirectives()
		elseif fullRotation / math.pi == 1 then
		tech.setParentDirectives("flipy")
		elseif fullRotation / math.pi == 1.5 then
		--tech.setParentDirectives()
		else
		tech.setParentDirectives("")
		end
		fullRotation = rotated
		--wait = 0
	  end
	  if rotated ~= lastRotation then
		wait = 0.5
	  end
	  lastRotation = rotated
	  wait = wait - args.dt
	  --mcontroller.translate(vec2.withAngle((groundAngle - math.pi),size/2)) --Anti-stuck failed
	  --[[local test = headingAngle / math.pi
	  test = test % 2
	  mcontroller.setRotation(test * math.pi)]]
	  
      --coroutine.yield(nil, {headingDirection = vec2.withAngle(headingAngle), headingAngle = headingAngle})
    else
      return false--break
    end
  --end

  --return false, {headingDirection = {1, 0}, forwardAngle = 0}
end

-- param rotationRate
function wallSit(args, board)
  local bounds = mcontroller.boundBox()
  --while true do
    -- Fail when not adjacent to any blocks
    local groundDirection = findGroundDirection()
    if not groundDirection then return false--[[break]] end

    -- Smoothly rotate to the ground slope
    local headingAngle = (math.atan(groundDirection[2], groundDirection[1]) + math.pi / 2) % (math.pi * 2)
    headingAngle = adjustCornerHeading(headingAngle, mcontroller.facingDirection())
	
	--sb.logInfo("Arachne Sitting Angle:"..headingAngle)
	local rotators = {0, 0.5, 1, 1.5}
		local check = headingAngle / math.pi
		local small = math.huge
		local rotated = headingAngle / math.pi
		if check < 0 then
			check = check * -1
		end
			check = check % 2
		for i,v in pairs(rotators) do
			if small > v - check then
				small = v - check
				rotated = v
			end
		if small < 0 then
			small = small * -1
		end
	end
	rotated = rotated * math.pi
	
	--sb.logInfo("Arachne Sitting Rotated: "..rotated)
	
	local groundAngle = rotated - (math.pi / 2)
	mcontroller.controlApproachVelocity(vec2.withAngle(groundAngle, moveSpeed), 150)
	
	--sb.logInfo("Arachne Last Rotation Sitting:"..lastRotation)
	if wait <= 0 then
		--mcontroller.setRotation(rotated) --No need to rotate when they aren't moving!
		--wait = 0
	end
	if rotated ~= lastRotation then
		wait = 0.5
	end
	lastRotation = rotated
	wait = wait - args.dt
	--[[local test = headingAngle / math.pi
	test = test % 2
	mcontroller.setRotation(test * math.pi)]]
	
    mcontroller.controlParameters({
      gravityEnabled = false
    })
    --coroutine.yield(nil, {groundDirection = groundDirection, forwardAngle = headingAngle})
  --end

  --return false, {groundDirection = {0, -1}, forwardAngle = 0}
end

function detach(args, board)
  local bounds = mcontroller.boundBox()
  --while true do
    -- Fail when not adjacent to any blocks
    local groundDirection = findGroundDirection()
    if not groundDirection then return false--[[break]] end

    -- Smoothly rotate to the ground slope
    local headingAngle = (math.atan(groundDirection[2], groundDirection[1]) + math.pi / 2) % (math.pi * 2)
    headingAngle = adjustCornerHeading(headingAngle, mcontroller.facingDirection())
	
	local groundAngle = headingAngle - (math.pi / 2)
	mcontroller.controlApproachVelocity(vec2.withAngle((-groundAngle), moveSpeed), 150)
	
	--[[local rotators = {0, 0.5, 1, 1.5}
	  local check = headingAngle / math.pi
	  local small = math.huge
	  local rotated = 0
	  if check < 0 then
		check = check * -1
	  end
		check = check % 2
	  for i,v in pairs(rotators) do
		if small > v - check then
		small = v - check
		rotated = v
		end
		if small < 0 then
			small = small * -1
		end
		
	end
	mcontroller.setRotation(math.pi * rotated)]]
	mcontroller.setRotation(0)
	
    mcontroller.controlParameters({
      gravityEnabled = false
    })
    --coroutine.yield(nil, {groundDirection = groundDirection, forwardAngle = headingAngle})
  --end

  --return false, {groundDirection = {0, -1}, forwardAngle = 0}
end


function adjustCornerHeading(headingAngle, direction)
  -- adjust direction for concave corners
  local adjustment = 0
  for a = 0, math.pi, math.pi / 4 do
	sb.logInfo("heading Adjust: "..direction)
    local testPos = vec2.add(mcontroller.position(), vec2.rotate({direction * 0.25, 0}, headingAngle + (direction * a)))
    adjustment = direction * a
	sb.logInfo("Adjustment: "..adjustment)
    if not world.polyCollision(poly.translate(poly.scale(mcontroller.collisionPoly(), 1.0), testPos)) then
	  --sb.logInfo("Broken!")
      break
    end
  end
  if adjustment < 0 then
	adjustment = adjustment * -1 * math.pi
  end
  headingAngle = headingAngle + adjustment

  -- adjust direction for convex corners
  adjustment = 0
  for a = 0, -math.pi, -math.pi / 4 do
    local testPos = vec2.add(mcontroller.position(), vec2.rotate({direction * 0.25, 0}, headingAngle + (direction * a)))
    if world.polyCollision(poly.translate(poly.scale(mcontroller.collisionPoly(), 1.0), testPos)) then
	  --sb.logInfo("Broken!")
      break
    end
    adjustment = direction * a
  end
  if adjustment < 0 then
	adjustment = adjustment * -1 * math.pi
  end
  headingAngle = headingAngle + adjustment
  return headingAngle
end

function findGroundDirection(testDistance)
  testDistance = testDistance or 0.25
  for i = 0, 7 do
    local angle = (i * math.pi / 4) - math.pi / 2
    local collisionSet = i == 1 and self.platformCollisionSet or self.normalCollisionSet
    local testPos = vec2.add(mcontroller.position(), vec2.withAngle(angle, testDistance))
    if world.polyCollision(poly.translate(mcontroller.collisionPoly(), testPos), nil, collisionSet) then
      return vec2.withAngle(angle, 1.0)
    end
  end
end

-- param angle
-- param transformationGroup
-- From monster.lua
function rotateBody(args, board)
  self.rotationGroup = args.transformationGroup
  while true do
    self.rotation = args.angle
    self.rotated = true

    animator.resetTransformationGroup(args.transformationGroup)
    animator.rotateTransformationGroup(args.transformationGroup, self.rotation)
    break
  end
end
