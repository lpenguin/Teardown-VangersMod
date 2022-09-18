---@type Handle[]
local Bodies = {}

local MapSizeX = 0
local MapSizeZ = 0
local MapChunkSizeX = 0
local MapChunkSizeZ = 0
local ChunkSizeX = 0
local ChunkSizeZ = 0
local WorldOriginX = 0
local WorldOriginZ = 0

---@param key string
---@param default number
---@return number
function GetFloatOrDefault(key, default)
	if not HasKey(key) then
		return default
	end

	return GetFloat(key)
end

---@param pos Vec3
---@param size Vec3
---@param color Vec3
---@return Handle[]
function SpawnVoxBox(pos, size, color)
	local colorStr = color[1] .. ' ' .. color[2] .. ' ' .. color[3]
	local sizeStr = size[1] .. ' ' .. size[2] .. ' ' .. size[3]

	 local xml = [[
		<voxbox color="]] .. colorStr .. [[" size="]] .. sizeStr .. [[" />
	]]
	
	return Spawn(xml, Transform(pos), true)
end


function init()
	local vehs = FindVehicles('', true)
	for _, veh in ipairs(vehs) do
		local body = GetVehicleBody(veh)
		table.insert(Bodies, body)
	end

	MapChunkSizeX = GetFloatOrDefault('vangers.map.MapChunkSizeX', 16)
	MapChunkSizeZ = GetFloatOrDefault('vangers.map.MapChunkSizeZ', 128)

	ChunkSizeX = GetFloatOrDefault('vangers.map.ChunkSizeX', 12.8)
	ChunkSizeZ = GetFloatOrDefault('vangers.map.ChunkSizeZ', 12.8)

	MapSizeX = MapChunkSizeX * ChunkSizeX
	MapSizeZ = MapChunkSizeZ * ChunkSizeX


	local numChunksX, numChunksZ = 3, 3
	for indexX = -numChunksX, numChunksX do
		for indexZ=-numChunksZ, numChunksZ  do
			local pos = Vec(indexX * ChunkSizeX, 0, indexZ * ChunkSizeZ)
			local color = Vec(
				(numChunksX + indexX) / (numChunksX * 2 + 1),
				0.7,
				(numChunksZ + indexZ) / (numChunksZ * 2 + 1)
			)
			local size = Vec(ChunkSizeX * 10, 16, ChunkSizeZ * 10)
			local ents = SpawnVoxBox(pos, size, color)
		end
	end
end


function update()
	local tr = GetPlayerTransform()
	DebugWatch('Player.Pos', tr.pos)
	WorldOriginX = GetFloat('vangers.map.WorldOriginX') or 0
	WorldOriginZ = GetFloat('vangers.map.WorldOriginZ') or 0

	for _, body in ipairs(Bodies) do
		UpdateBody(body)
	end
end

---@param v Vec3
---@return string
function VecString(v)
	return "{"..v[1] .. " " .. v[2] .. " " .. v[3] .. "}"
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


---@param indexX integer
---@param indexZ integer
---@return string
function GetChunkId(indexX, indexZ)
	return indexX .. "_" .. indexZ
end

---@param pos Vec3
---@return number
---@return number
function ChunkXZFromPos(pos)
	local chunkX = math.floor(pos[1] / ChunkSizeX) - WorldOriginX
	local chunkZ = math.floor(pos[3] / ChunkSizeZ) - WorldOriginZ

	return chunkX, chunkZ
end


---@param body Handle
function UpdateBody(body)
	local tr = GetBodyTransform(body)

	-- local x = Cycle(tr.pos[1], MapSizeX)
	-- local y = Cycle(tr.pos[3], MapSizeZ)
	
	local chunkX, chunkZ = ChunkXZFromPos(tr.pos)
	local offsetX = Cycle(math.fmod(tr.pos[1], ChunkSizeX), ChunkSizeX)
	local offsetZ = Cycle(math.fmod(tr.pos[3], ChunkSizeZ), ChunkSizeZ)

	DebugWatch('body['..body..'].Pos', VecString(tr.pos))
	DebugWatch('body['..body..'].Chunk', chunkX .. ' ' .. chunkZ)
	DebugWatch('body['..body..'].Offset', offsetX .. ' ' .. offsetZ)
end
