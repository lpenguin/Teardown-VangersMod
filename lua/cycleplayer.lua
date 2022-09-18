---@param v Vec3
---@return string
function VecString(v)
	return "{"..v[1] .. " " .. v[2] .. " " .. v[3] .. "}"
end

---@param q Quat
---@return string
function QuatEulerString(q)
	local x, y, z = GetQuatEuler(q)
	return "{"..x .. " " .. y .. " " .. z .. "}"
end

---@param q Quat
---@return string
function QuatString(q)
	return "{" .. q[1] .. ", " .. q[2] .. ", " .. q[3] .. ", " .. q[4].. "}"
end



---@param transform Transform
function TeleportPlayer(transform)
	local velocity = GetPlayerVelocity()
	local cameraTransform = GetPlayerCameraTransform()
	SetPlayerTransform(transform, true)
	SetPlayerVelocity(velocity)
	SetCameraTransform(cameraTransform)
end


---@param fileName string
---@param worldPos Vec3
local function InstantiateChunk(fileName, worldPos)
	-- DebugPrint("Spawning file: ".. fileName .. ", at: " .. VecString(worldPos))
	local ents = Spawn("<body dynamic='false'><vox file='" .. fileName .. "'/></body>", Transform(worldPos), true)

	for key, v in pairs(ents) do
		DebugPrint(key .. " = " .. v)
	end
	local body = ents[1]
	local shape = ents[2]

	return body, shape
end

---@param value number
---@param size number
---@return number
function Cycle(value, size)
	value = math.fmod(value, size)
	if value < 0 then
		return size + value
	else
		return value
	end
end

local originChunkX = 8
local originChunkY = 120
local nChunks = 3
local VOXEL_SIZE = 10.0

local ChunkSizeX = 128 / VOXEL_SIZE
local ChunkSizeZ = 128 / VOXEL_SIZE
local OriginY = -10

local MapChunkSizeX = 16
local MapChunkSizeZ = 128

local MinX = -ChunkSizeX
local MaxX = ChunkSizeX
local MinZ = -ChunkSizeZ
local MaxZ = ChunkSizeZ

local chunkCenterX = 0
local chunkCenterZ = 0

local ChunkShapes = {}

---@type Handle
local WorldBody = nil

---@type Handle
local root = nil

function init()
	
	
	-- (MapChunkSizeZ - 1 - chunk.indexY)
	
	local chunksDirectory = "MOD/vmcexport/fostral_chunked/"
	for chunkX = -nChunks, nChunks do
		for chunkY = -nChunks, nChunks do
			local realChunkX = Cycle(chunkX + originChunkX, MapChunkSizeX)
			local realChunkY = Cycle(MapChunkSizeZ - 1 - (chunkY + originChunkY), MapChunkSizeZ)
			local filename = chunksDirectory .. "chunk." .. realChunkX .. "." .. realChunkY .. ".vox"
			local worldPos = Vec(chunkX * ChunkSizeX, OriginY, chunkY * ChunkSizeZ)
			local body, shape = InstantiateChunk(filename, worldPos)
			if shape ~= nil then
				ChunkShapes[shape] = {body = body, shape = shape}			
			end
		end
	end

	WorldBody = GetWorldBody()
	root = FindBody('root1', true)
	DebugPrint('World body ' .. WorldBody)
	DebugPrint('root ' .. root)
end


function tick()
	-- local ctr = Transform(Vec(0, 10, 0), QuatEuler(0, 90, 0))
	-- SetCameraTransform(ctr)
	
	local t = GetPlayerTransform(true)
	local p = t.pos
	local r = t.rot
	local velocity = GetPlayerVelocity()

	local playerCameraTransform = GetPlayerCameraTransform()
	local cameraTransform = GetCameraTransform()

	local playerCameraPosition = playerCameraTransform.pos
	local playerCameraRotation = playerCameraTransform.rot

	local cameraPosition = cameraTransform.pos
	local cameraRotation = cameraTransform.rot

	local WorldBodyTransorm = GetBodyTransform(WorldBody)
	local rootTransform = GetBodyTransform(root)

	local dirty = false
	DebugWatch('Player.Position', VecString(p))
	DebugWatch('Player.Rotation', QuatString(r))
	DebugWatch('Velocity', VecString(velocity))
	
	DebugWatch('PlayerCamera.Position', VecString(playerCameraPosition))
	DebugWatch('PlayerCamera.Rotation', QuatString(playerCameraRotation))
	
	DebugWatch('Camera.Position', VecString(cameraPosition))
	DebugWatch('Camera.Rotation', QuatString(cameraRotation))

	DebugWatch('World.Position', WorldBodyTransorm.pos)
	DebugWatch('Root.Transform', rootTransform.pos)

	local x = p[1]
	local y = p[2]
	local z = p[3]

	local shuftX = 0
	local shuftZ = 0

	if x < MinX then
		x = MaxX
		shuftX = 2
		dirty = true
	end

	if x > MaxX	then
		x = MinX
		shuftX = -2
		dirty = true
	end

	if z < MinZ then
		shuftZ = 2
		z = MaxZ
		dirty = true
	end

	if z > MaxZ then
		z = MinZ
		shuftZ = -2
		dirty = true
	end

	if dirty then
		t.pos = Vec(p[1] + shuftX * ChunkSizeX, p[2], p[3] + shuftZ * ChunkSizeZ)
		TeleportPlayer(t)
		
		local ctr = GetBodyTransform(root)
		local cpos = ctr.pos
		local newCpos = Vec(cpos[1] + shuftX * ChunkSizeX, cpos[2], cpos[3] + shuftZ * ChunkSizeZ)
		
		DebugPrint('Moving root ' .. root 
					.. ' from ' .. VecString(cpos) 
					.. ' to ' .. VecString(newCpos))
		ctr.pos = newCpos
		SetBodyTransform(root, ctr)

		-- for id, chunk in pairs(ChunkShapes) do
		-- 	local ctr = GetShapeLocalTransform(chunk.shape)
		-- 	-- local ctr = GetBodyTransform(chunk.body)
		-- 	local cpos = ctr.pos
		-- 	ctr.pos = Vec(cpos[1] + shuftX * ChunkSizeX, cpos[2], cpos[3] + shuftZ * ChunkSizeZ)
		-- 	SetShapeLocalTransform(chunk.shape, ctr)
		-- 	-- SetBodyTransform(chunk.body, ctr)
		-- end
	end

	local r = 1
	local g = 1
	local b = 1
	
	local y = 7.3

	local lb = Vec(-MinX, y, -MinZ)
	local rb = Vec(MinX, y, -MinZ)
	local lt = Vec(-MinX, y, MinZ)
	local rt = Vec(MinX, y, MinZ)

	DebugLine(lb, rb, r, g, b)
	DebugLine(lb, lt, r, g, b)
	DebugLine(rb, rt, r, g, b)
	DebugLine(lt, rt, r, g, b)
end