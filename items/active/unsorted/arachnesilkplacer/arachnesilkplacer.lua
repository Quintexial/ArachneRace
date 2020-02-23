require "/scripts/util.lua"

function init()
	self.placing = false;
end


function update(dt, fireMode)
	if mcontroller.crouching() then
		activeItem.setArmAngle(-0.15)
	else
		activeItem.setArmAngle(-0.5)
	end
	if fireMode == "primary" then
		placeMod("foreground")
	elseif fireMode == "alt" then
		placeMod("background")
	end
end

function placeMod(layer)
	position = activeItem.ownerAimPosition()
	if world.mod(position, layer) ~= "arachnesilkmod" then
		if player.consumeCurrency("arachnesilkresource", 1) then
			world.placeMod(position, layer, "arachnesilkmod")
		end
	end
end