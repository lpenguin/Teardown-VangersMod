currentPos = 1


function VecString(v)
	return "{"..v[1] .. " " .. v[2] .. " " .. v[3] .. "}"
end

first = true
function init()	


	button = FindShape("button", true)
	activateButton = FindShape("activateButton", true)
	dynamicButton = FindShape("dynamicButton", true)

	local loc1 = FindLocation("point1")
	local loc2 = FindLocation("point2")

	shape1 = FindShape("object1")
	body1 = GetShapeBody(shape1)
	

	DebugPrint('body1 ' .. body1)
	DebugPrint('loc1 ' .. loc1)
	DebugPrint('loc2 ' .. loc2)
	DebugPrint('shape1 ' .. shape1)

	pos1 = GetLocationTransform(loc1).pos
	pos2 = GetLocationTransform(loc2).pos

	SetTag(button, "interact", "Move")
	SetTag(activateButton, "interact", "Deactivate")
	SetTag(dynamicButton, "interact", "Static")

end


function tick()


	local playerTr = GetPlayerCameraTransform()
	local playerPos = playerTr.pos
	-- playerTr.pos = VecAdd(playerPos, Vec(0, 10, 0))
	-- SetCameraTransform(playerTr)

	DebugWatch("body1", body1)
	DebugWatch("body1.pos", VecString(GetBodyTransform(body1).pos))
	DebugWatch("body1.active", IsBodyActive(body1))
	DebugWatch("body1.dynamic", IsBodyDynamic(body1))

	DebugWatch("shape1", shape1)
	DebugWatch("shape1.pos", VecString(GetShapeWorldTransform(shape1).pos))
	--Check if player interacts with light switch and presses interact button
	if GetPlayerInteractShape() == activateButton and InputPressed("interact") then
		local active = not IsBodyActive(body1)
		SetBodyActive(body1, active)
		if active then
			SetTag(activateButton, "interact", "Deactivate")
		else
			SetTag(activateButton, "interact", "Activate")
		end


	end

	if GetPlayerInteractShape() == dynamicButton and InputPressed("interact") then
		local dynamic = not IsBodyDynamic(body1)
		SetBodyDynamic(body1, dynamic)
		if active then
			SetTag(dynamicButton, "interact", "Static")
		else
			SetTag(dynamicButton, "interact", "Dynamic")
		end
	end

	if GetPlayerInteractShape() == button and InputPressed("interact") then

	if first then
		first = false
		local fileName = "MOD/vmcexport/glorx/chunk.1.3.vox"
		local ents = Spawn("<body dynamic='false'><vox pos='0 100 10' file='" .. fileName .. "'/></body>", Transform(Vec(0, 100, 0)), true)
		for k, v in ipairs(ents) do
			DebugPrint('ents ' .. k .. "  " .. v .. ' ' .. GetEntityType(v))
		end

		body1 = ents[1]
		shape1 = ents[2]
		-- body1 = GetShapeBody(shape1)

		DebugPrint('spawned ' .. shape1.. ' ' .. fileName .. ' ')
		DebugPrint(VecString(GetBodyTransform(shape1).pos))
		DebugPrint(VecString(GetShapeWorldTransform(body1).pos))



	end

			-- local playerTr = GetPlayerCameraTransform()
			--Find handles to the light switch and and lamp
		local targetPos = nil


		if currentPos == 1 then
			targetPos = pos1
			currentPos = 2
		else
			targetPos = pos2
			currentPos = 1
		end

		DebugPrint(currentPos)
		local tr = GetBodyTransform(object1)
		tr.pos = targetPos
		SetBodyTransform(body1, tr)
		SetBodyActive(body1, false)
	end
end
