-- function DebugCrossMy(pos, size, r, g, b)
-- 	local lb = VecAdd(pos, Vec(-size, 0, -size))
-- 	local rb = VecAdd(pos, Vec(size, 0, -size))
-- 	local lt = VecAdd(pos, Vec(-size, 0, size))
-- 	local rt = VecAdd(pos, Vec(size, 0, size))



-- 	DebugLine(lb, rt, r, g, b)
-- 	DebugLine(lt, rb, r, g, b)
-- 	-- DebugLine(rb, rt, r, g, b)
-- 	-- DebugLine(lt, rt, r, g, b)
-- end

-- function update()
-- 	local vehicles = FindVehicles("", true)
-- 	-- DebugPrint(#vehicles)
-- 	for index, veh in ipairs(vehicles) do
-- 		local tr = GetVehicleTransform(veh)
-- 		-- DebugPrint(tr.pos[1] .. ' ' .. tr.pos[2] .. ' ' .. tr.pos[3])
-- 		local p1 = VecCopy(tr.pos)
-- 		local p2 = VecCopy(tr.pos)

-- 		p1[2] =  100
-- 		p2[2] = -100
-- 		DebugLine(
-- 			p1,
-- 			p2,
-- 			1, 1, 1, 1
-- 		)
-- 		DebugCrossMy(tr.pos, 1, 1, 0, 0)
-- 	end
-- end