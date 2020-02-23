function init()
	if status.isResource("stunned") then
		status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
	end
	mcontroller.setVelocity({0, 0})
	droppedItem = false
end

function update(dt)
	mcontroller.controlModifiers({
		facingSuppressed = true,
		movementSuppressed = true
    })
	if not status.resourcePositive("health") and droppedItem == false then
		entType = entity.entityType()
		if entType == "monster" then
			monMaterial = world.callScriptedEntity(entity.id(), "config.getParameter", "statusSettings").statusProperties.targetMaterialKind
			if monMaterial == "organic" then
				level = math.floor(world.callScriptedEntity(entity.id(), "monster.level"))
				if level == 1 then
					world.spawnItem("arachnewebbedcorpset1", entity.position())
				elseif level == 2 then
					world.spawnItem("arachnewebbedcorpset2", entity.position())
				elseif level == 3 then
					world.spawnItem("arachnewebbedcorpset3", entity.position())
				end
			end
		elseif entType == "npc" then
			level = math.floor(world.callScriptedEntity(entity.id(), "npc.level"))
			species = world.entitySpecies(entity.id())
			if species ~= "glitch" and species ~= "shadow" and species ~= "novakid" and species ~= "trink" and species ~= "droden" and species ~= "radien"  then
				if level == 1 then
					world.spawnItem("arachnewebbedcorpset1", entity.position())
				elseif level == 2 then
					world.spawnItem("arachnewebbedcorpset2", entity.position())
				elseif level == 3 then
					world.spawnItem("arachnewebbedcorpset3", entity.position())
				end
			end
		end
		droppedItem = true
		if status.isResource("stunned") then
			status.resetResource("stunned")
		end
		effect.expire()
	end
end

function uninit()
  
end
