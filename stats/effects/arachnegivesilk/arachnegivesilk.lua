function init()
	 script.setUpdateDelta(5400)
end

function update(dt)
	local mypos = mcontroller.position()
	hunger = status.resourcePercentage("food") or 1.0
	amount = math.floor((hunger^2)*15)
	world.spawnItem("arachnesilkresource", mypos, amount)

end

function uninit()

end