function init()
    self.interval = 4
    self.timer = 4
    self.movementParameters = config.getParameter("movementParameters")
    self.movementParameters2 = config.getParameter("movementParameters2")
    self.movementParameters3 = config.getParameter("wallSlideParameters")
    ballState = false
    status.setStatusProperty("sphereActivated", false)
    status.setStatusProperty("wallSlide", false)
end

function testState()
        ballPoly2 = mcontroller.collisionPoly()
        ballPoly = config.getParameter("testParameters").collisionPoly
        test = sb.print(ballPoly2)
        test2 = sb.print(ballPoly)
        if test == test2 then
            return true
        elseif test ~= test2 then
            return false
        end
end
function update(dt)
        status2 = sb.print(status.statusProperty("sphereActivated"))
        if mcontroller.facingDirection() == 1 and status.statusProperty("sphereActivated") == false then
            mcontroller.controlParameters(self.movementParameters)
        elseif mcontroller.facingDirection() == -1 and status.statusProperty("sphereActivated") == false then
            mcontroller.controlParameters(self.movementParameters2)
        end
end
