oldUpdate = update
activated = false
oldUninit = uninit
function uninit()
    oldUninit()
    status.setStatusProperty("sphereActivated", false)
    activated = false
end
function update(args)
    oldUpdate(args)
    buttonThis = args.moves["special1"]
    lounging = tech.parentLounging()
    if buttonThis == true and buttonThis ~= buttonLast and lounging == false then
        if activated == false then
            status.setStatusProperty("sphereActivated", true)
            activated = true
        elseif activated == true then
            status.setStatusProperty("sphereActivated", false)

            activated = false
        end
    end
    buttonLast = args.moves["special1"]
end