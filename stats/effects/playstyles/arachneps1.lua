function init()
    self.prot = 0.2 * (status.stat("protection"))
	effect.addStatModifierGroup({{stat = "maxHealth", effectiveMultiplier = 1.2}})
    effect.addStatModifierGroup({{stat = "protection", amount = self.prot}})
    effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 0.9}})
    self.movementParameters = config.getParameter("movementParameters")
end
function update(dt)
    mcontroller.controlModifiers({
      groundMovementModifier = 0.8,
      speedModifier = 0.8,
    })
end
