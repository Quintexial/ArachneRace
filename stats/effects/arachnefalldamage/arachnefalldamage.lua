function init()
	effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 0.75}})
end
function update(dt)
  mcontroller.controlModifiers({airJumpModifier = 1.25})
end
