local Oscillation = 1.7

function tick(dt)
	local scale = math.sin(GetTime() * Oscillation) * 0.5 + 0.5
	local shapes = FindShapes('emissive', true)
	-- DebugPrint("Nnum emissive shapes: " .. #shapes)
	for _, shape in ipairs(shapes) do
		SetShapeEmissiveScale(shape, scale)
	end
end