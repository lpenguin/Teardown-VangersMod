local emitterSpawnInterval = 0.5
local emitterSpawnDistance = 50
local emitterLifeTime = 3
local emitterMaxJump = 3
local emitterMaxInstances = 20

local numParticles = 1
local lastUpdateTime = 0

local spawnRate = 100
local spawnInterval = 1 / spawnRate
local spawnRadius = 0.2

local particleRadius = 0.25
local particleColor = Vec(0.3, .7, 0)

local particleType = 'plain'
local particleLifetime = 1
local movementSpeed = 6

local waveAmplitude = 5
local waveFreq = 10

local nextEmitterId = 0

---@class ParticleEmitter
---@field id integer
---@field pos Vec3
---@field rot Quat
---@field lifeTime number
---@field lastSpawnTime number
---@field lastPos Vec3?

---@type { [integer]: ParticleEmitter }
local emitters = {}

---@param id integer
---@param pos Vec3
---@param rot Quat
---@param lifeTime number
function ParticleEmitter(id, pos, rot, lifeTime)
	return {
		id = id,
		pos = pos,
		rot = rot,
		lifeTime = lifeTime,
		lastSpawnTime = 0,
		lastPos = nil
	}
end


function init()
	-- math.randomseed(os.time())
	-- local loc = FindLocation("", false)
	-- local tr = GetLocationTransform(loc)
	-- local pos = tr.pos
	-- local rot = tr.rot
	-- DebugPrint(loc)
end


---@return Vec3
function VecRandom()
	local v = Vec(
		math.random(), 
		math.random(), 
		math.random()
	)
	return VecNormalize(v)
end

---@param emitter ParticleEmitter
---@param dt number
function UpdateParticleEmitter(emitter, dt)
	emitter.lifeTime = emitter.lifeTime - dt
	local frontDir = QuatRotateVec(emitter.rot, Vec(0, 0, 1))
	local rightDir = QuatRotateVec(emitter.rot, Vec(1, 0, 0))

	local newPos = VecAdd(emitter.pos, 
		VecAdd(
			VecScale(frontDir, movementSpeed * dt),
			VecScale(rightDir, waveAmplitude * math.sin(waveFreq * GetTime()) * dt)
		)
	)

	if emitter.lastPos ~= nil and
		math.abs(newPos[2] - emitter.lastPos[2]) >= emitterMaxJump then
		-- VecLength(VecAdd(newPos, VecScale(emitter.lastPos, -1))) > .3 then
			emitter.lifeTime = 0
			-- DebugPrint('Jump: ' .. emitter.id .. ' ' .. math.abs(newPos[2] - emitter.lastPos[2]))
			return
		end

	emitter.lastPos = emitter.pos
	emitter.pos = newPos

	local rayOrigin = Vec(emitter.pos[1], 100, emitter.pos[3])
	local rayDirection = Vec(0, -1, 0)
	local rayMaxDistance = 200

	QueryRejectVehicle()
	local hit, dist, normal, shape = QueryRaycast(
		rayOrigin,
		rayDirection,
		rayMaxDistance
	)
	-- DebugPrint('Hit? ' .. tostring(hit) .. ' dist ' .. dist)
	
	if not hit then
		emitter.lifeTime = 0
		-- DebugPrint('No hit: ' .. emitter.id)
		return
	end

	if hit then
		-- if hit == true then
			emitter.pos[2] = rayOrigin[2] + rayDirection[2] * dist
		-- end
		

		local time = GetTime()
		if time - emitter.lastSpawnTime > spawnInterval then
			emitter.lastSpawnTime = time
			ParticleReset()
			ParticleType('plain')
			-- ParticleTile(5)
			ParticleColor(
				particleColor[1], 
				particleColor[2] ,
				particleColor[3],
				1, 1, 1
			)
			ParticleRadius(particleRadius, particleRadius / 2)
			ParticleGravity(-1)

			for n=0, numParticles do
				local dir = VecRandom()
				local partilcePos = VecAdd(emitter.pos, VecScale(VecRandom(), spawnRadius))
				SpawnParticle(partilcePos, dir, particleLifetime)
			end
		end
	end

	

end

function DebugCrossMy(pos, size, r, g, b)
	local lb = VecAdd(pos, Vec(-size, 0, -size))
	local rb = VecAdd(pos, Vec(size, 0, -size))
	local lt = VecAdd(pos, Vec(-size, 0, size))
	local rt = VecAdd(pos, Vec(size, 0, size))



	DebugLine(lb, rt, r, g, b)
	DebugLine(lt, rb, r, g, b)
	-- DebugLine(rb, rt, r, g, b)
	-- DebugLine(lt, rt, r, g, b)
end

function update(dt)
	local playerPos = GetPlayerTransform().pos

	-- DebugCrossMy(playerPos, 1, 0, 1, 0)

	for id, emitter in pairs(emitters) do
		-- DebugCrossMy(emitter.pos, 1, 1, 0, 0)

		UpdateParticleEmitter(emitter, dt)
		if emitter.lifeTime <= 0 then
			emitters[id] = nil
		end
	end

	if #emitters > emitterMaxInstances then
		return
	end

	local time = GetTime()
	if lastUpdateTime == 0 or 
	   time - lastUpdateTime > emitterSpawnInterval then
		lastUpdateTime = time
		
		nextEmitterId = nextEmitterId + 1
		local offset = VecRandom()
		offset[2] = 0
		local emitter = ParticleEmitter(
			nextEmitterId,
			VecAdd(
				playerPos,
				VecScale(offset, emitterSpawnDistance)
			),
			QuatEuler(0, 380 * math.random(), 0),
			emitterLifeTime
		)
		emitters[nextEmitterId] = emitter
	end
	

end