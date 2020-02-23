require "/scripts/util.lua"

function update(dt)
end

function init()
	self.podUuid = sb.makeUuid()
	--projectileConfig = { ["podUuid"] = self.podUuid] }
	self.param = config.getParameter("params1")
	self.param.currentPets[1].podUuid = self.podUuid
	self.param.podUuid = self.podUuid
end

function shouldDestroy()
  return projectile.timeToLive() <= 0 or projectile.collision()
end

function destroy()
    world.spawnItem("spiderpetegg1a", mcontroller.position(), 1, self.param)
end

