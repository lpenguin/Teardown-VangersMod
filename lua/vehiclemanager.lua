local maxEnergy = 1
local energy = maxEnergy
local energyConsumePerSec = 0.5
local energyRestorePerSec = 0.5
local jumpPressed = false
local JumpForce = 200000

---@return string
function VecString(v)
	return "{"..v[1] .. " " .. v[2] .. " " .. v[3] .. "}"
end


function tick(dt)
	-- DebugWatch('Energy', energy)

	if not jumpPressed then
		energy = math.min(maxEnergy, energy + dt * energyRestorePerSec)
	end
	local v = GetPlayerVehicle()
	if v ~= 0 then
		if InputPressed("shift") then
			jumpPressed = true
		end

		local forcedToJump = false
		if jumpPressed then
			energy = energy - dt * energyConsumePerSec
			energy = math.max(0, energy)

			if energy <= 0.001 then
				jumpPressed = false
				forcedToJump = true
			end
		end

		
		if (InputReleased('shift') and jumpPressed) or forcedToJump then
			jumpPressed = false
			local vBody = GetVehicleBody(v)
			local vTr = GetBodyTransform(vBody)

			local r = QuatRotateVec(vTr.rot, Vec(0, 0, -1))
			local dir = VecNormalize(VecAdd(r, Vec(0, 1, 0)))
			local apliedEnergy = maxEnergy - energy
			-- DebugPrint('jump ' .. apliedEnergy .. ' ' .. v .. ' ' .. vBody .. ' ' .. VecString(dir))
			
			ApplyBodyImpulse(vBody, vTr.pos, VecScale(dir,  JumpForce * apliedEnergy))
		end




	end
end
