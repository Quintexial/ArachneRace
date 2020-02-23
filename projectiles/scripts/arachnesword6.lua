require "/scripts/vec2.lua"

function init()
  message.setHandler("kill", function()
	projectile.die()
  end)
  
  self.hasCollided = false
end

function update(dt)
  
  if mcontroller.isColliding() and self.hasCollided == false then
	projectile.setPower(0.0)
	self.hasCollided = true
  end
  
end
