function init()
    self.interval = 4
    self.timer = 0
    self.movementParameters = config.getParameter("movementParameters")
    self.movementParameters2 = config.getParameter("movementParameters2")
    self.movementParameters3 = config.getParameter("wallSlideParameters")
	self.collisionSet = {"Null", "Block", "Dynamic", "Slippery"}
    status.setStatusProperty("sphereActivated", false)
    status.setStatusProperty("wallSlide", false)
end

function testState()
        local poly = mcontroller.collisionPoly()
        local ballPoly = config.getParameter("testParameters").collisionPoly
		local ballPoly2 = config.getParameter("testParameters").collisionPoly2
		local ballPoly3 = config.getParameter("testParameters").collisionPoly3
        local test = sb.print(poly)
        local test2 = sb.print(ballPoly)
		local test3 = sb.print(ballPoly2)
		local test4 = sb.print(ballPoly3)
		
		--sb.logInfo(test)
        if test == test2 then
            return true
        elseif test == test3 then
			return true
		elseif test == test4 then
			return true
		else
			return false
        end
end
function update(dt)
		self.timer = self.timer + 1
		if self.timer < 5 then
			if mcontroller.facingDirection() == 1 then
				if testState() ~= true then
					mcontroller.controlParameters(self.movementParameters)
					if mcontroller.crouching() == true then
						local groundPos = world.resolvePolyCollision(self.movementParameters.crouchingPoly, mcontroller.position(), 2, self.collisionSet)
						if groundPos then
							mcontroller.setPosition(groundPos)
						end
					else
						local groundPos = world.resolvePolyCollision(self.movementParameters.standingPoly, mcontroller.position(), 2, self.collisionSet)
						if groundPos then
							mcontroller.setPosition(groundPos)
						end
					end
				end
			elseif mcontroller.facingDirection() == -1 then
				if testState() ~= true then
					mcontroller.controlParameters(self.movementParameters2)
					if mcontroller.crouching() == true then
						local groundPos = world.resolvePolyCollision(self.movementParameters2.crouchingPoly, mcontroller.position(), 2, self.collisionSet)
						if groundPos then
							mcontroller.setPosition(groundPos)
						end
					else
						local groundPos = world.resolvePolyCollision(self.movementParameters2.standingPoly, mcontroller.position(), 2, self.collisionSet)
						if groundPos then
							mcontroller.setPosition(groundPos)
						end
					end
				end
			end
		else
			self.timer = 0
		end
end
