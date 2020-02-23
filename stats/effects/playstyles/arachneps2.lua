function init()
    self.prot = -0.2 * (status.stat("protection"))
	effect.addStatModifierGroup({{stat = "maxHealth", effectiveMultiplier = 0.8}})
    effect.addStatModifierGroup({{stat = "protection", amount = self.prot}})
    effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 1.1}})
    self.movementParameters = config.getParameter("movementParameters")
end
function update(dt)
    mcontroller.controlModifiers({
      groundMovementModifier = 1.2,
      speedModifier = 1.2,
    })
end
