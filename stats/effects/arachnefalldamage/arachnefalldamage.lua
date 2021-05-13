function init()
	effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 1.15}})
end
function update(dt)
  mcontroller.controlModifiers({airJumpModifier = 1.25})
end
