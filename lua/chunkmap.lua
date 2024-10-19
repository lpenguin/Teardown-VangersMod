---@type { [string]: Chunk }
local Chunks = {}

local VOXELS_IN_METER = 10.0
local ChunkSizeX = 128 / VOXELS_IN_METER
local ChunkSizeZ = 128 / VOXELS_IN_METER

local MapSizeX = 2048 / VOXELS_IN_METER
local MapSizeZ = 16384 / VOXELS_IN_METER

local MapChunkSizeX = 16
local MapChunkSizeZ = 128

local ChunksVisibleArea = 8
local ChunksUnloadAreaX = 7
local ChunksUnloadAreaZ = 10

local ChunksRemoveAreaZ = 18

local LastLoadTime = 0
local LoadTimeInterval = 50/1000
local ChunkYPos = 128


local ShiftAreaX = 10
local ShiftAreaZ = 10
local WorldOriginX = 0
local WorldOriginZ = 0

local Debug = false

---@type Handle[]
local CycledBodies = {}

ChunksDirectory = "MOD/vmcexport/fostral/"
-- ChunksDirectory = GetStringParam("ChunksDirectory", ChunksDirectory)

ChunkManager = {}

---@param v Vec3
---@return string
function VecString(v)
	return "{"..v[1] .. " " .. v[2] .. " " .. v[3] .. "}"
end

---@param value any
function Print(value)
	if not Debug then
		return
	end
	DebugPrint(value)
end

---@param str string
---@param value any
function Watch(str, value)
	if not Debug then
		return
	end

	DebugWatch(str, value)
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

---@param value1 number
---@param value2 number
---@param size number
---@return number
function CycleDist(value1, value2, size)
	local diff = math.abs(value1 - value2)
	if diff > size / 2 then
		return size - diff
	else
		return diff
	end
end

---@param v Vec3
---@param sizeX number
---@param sizeZ number
---@return Vec3
function VecCycleXZ(v, sizeX, sizeZ)
	return Vec(
		Cycle(v[1], sizeX),
		v[2],
		Cycle(v[3], sizeZ)
	)
end

---@param transform Transform
function TeleportPlayer(transform)
	local velocity = GetPlayerVelocity()
	local cameraTransform = GetPlayerCameraTransform()
	SetPlayerTransform(transform, true)
	SetPlayerVelocity(velocity)
	SetCameraTransform(cameraTransform)
end

--- @enum ChunkStatus
ChunkStatus = {
	queued = 'queued',
	loaded = 'loaded',
	unloaded = 'unloaded',
}

---@class ChunkData
---@field body Handle
---@field shape Handle

---@class Chunk
---@field fileName string
---@field indexX integer
---@field indexZ integer
---@field realIndexX integer
---@field realIndexZ integer
---@field status ChunkStatus
---@field data? ChunkData

Chunk = {}

---@param indexX integer
---@param indexZ integer
---@return string
function GetChunkId(indexX, indexZ)
	return "chunk." .. indexX .. "." .. indexZ
end

---@param chunksDir string
---@param indexX integer
---@param indexZ integer
function GetChunkFilename(chunksDir, indexX, indexZ)
	-- return chunksDir .. 'hm1/' .. 'height_' .. math.abs(indexZ + 1) .. 'x' .. math.abs(indexX + 1) .. '.png'
	return chunksDir .. '/' .. 'chunk.' .. math.abs(indexX) .. '.' .. math.abs(indexZ) .. '.vox'
end


---@param fileName string
---@param realIndexX integer
---@param realIndexZ integer
---@param status ChunkStatus
---@return Chunk
function Chunk.new(fileName, realIndexX, realIndexZ, status)
	local indexX = Cycle(realIndexX, MapChunkSizeX)
	local indexZ = Cycle(realIndexZ, MapChunkSizeZ)
	---@type Chunk
	return {
		fileName=fileName,
		indexX=indexX,
		indexZ=indexZ,
		realIndexX=realIndexX,
		realIndexZ=realIndexZ,
		status=status,
		data=nil,
	}
end


---@param chunk Chunk
---@return Vec3
function GetChunkWorldPos(chunk)
	return Vec(
		(chunk.realIndexX + WorldOriginX) * ChunkSizeX,
		ChunkYPos,
		(chunk.realIndexZ + WorldOriginZ) * ChunkSizeZ
	)
end

---@param chunk Chunk
local function InstantiateChunk(chunk)
	local worldPos = GetChunkWorldPos(chunk)

	-- Log("Spawning chunk file: ".. chunk.fileName .. ", at: " .. VecString(worldPos))
	-- local ents = Spawn("<body dynamic='false'><vox tags='emissive' file='MOD/assets/monu2.vox'/></body>", Transform(worldPos), true, true)
	local xml = "<body dynamic='false'><vox tags='emissive' file='" .. chunk.fileName .. "'/></body>"
	local ents = Spawn(xml, Transform(worldPos), true, true)
	-- local ents = Spawn([[ 
	-- 	<body dyname="false">
	-- 		<voxscript pos="0.0 3.5 0.0" collide="true" file="MOD/lua/heightmap.lua">
	-- 			<parameters scale="256" hollow="0" tilesize="128" file="]] .. chunk.fileName .. [[ "/>
	-- 		</voxscript>
	-- 	</body>
	-- ]], Transform(worldPos), true)
	
	local body = ents[1]
	local shape = ents[2]
	-- DebugPrint(chunk.fileName .. ' ' .. VecString(GetBodyTransform(body).pos))

	chunk.data = {
		body = body,
		shape = shape,
	}
	chunk.status = ChunkStatus.loaded
end

---@param chunk Chunk
local function UnloadChunk(chunk)
	if chunk.data == nil then
		return
	end
	SetTag(chunk.data.body, "invisible")
	SetTag(chunk.data.shape, "invisible")
end


---@param chunk Chunk
local function LoadChunk(chunk)
	if chunk.data == nil then
		InstantiateChunk(chunk)
	else
		RemoveTag(chunk.data.body, "invisible")
		RemoveTag(chunk.data.shape, "invisible")
	end

end

---@param realIndexX integer
---@param realIndexZ integer
local function PreloadChunkIfNeeded(realIndexX, realIndexZ)
	local indexX = Cycle(realIndexX, MapChunkSizeX)
	local indexZ = Cycle(realIndexZ, MapChunkSizeZ)

	local chunkId = GetChunkId(indexX, indexZ)
	
	-- local worldPos = Vec(realIndexX * ChunkSizeX, ChunkYPos, realIndexZ * ChunkSizeZ)

	local chunk = Chunks[chunkId]
	if chunk == nil then
		local fileName = GetChunkFilename(ChunksDirectory, indexX, MapChunkSizeZ - 1 - indexZ)
		-- local fileName = GetChunkFilename(ChunksDirectory, indexX, indexZ)
		chunk = Chunk.new(fileName, realIndexX, realIndexZ, ChunkStatus.queued)
		-- Log(chunk.fileName .. ' created at ' .. VecString(worldPos))
		Chunks[chunkId] = chunk
	else
		chunk.realIndexX = realIndexX
		chunk.realIndexZ = realIndexZ
		if chunk.status == ChunkStatus.unloaded then
			chunk.status = ChunkStatus.queued
		end
	end
end


---@param playerChunkX integer
---@param playerChunkZ integer
local function PreloadVisibleChunks(playerChunkX, playerChunkZ)
	for indexX = playerChunkX - ChunksVisibleArea, playerChunkX + ChunksVisibleArea do
		for indexZ = playerChunkZ - ChunksVisibleArea, playerChunkZ + ChunksVisibleArea do
			local dx = indexX - playerChunkX
			local dz = indexZ - playerChunkZ
			local dist = math.ceil(math.sqrt(dx * dx + dz * dz))
			if dist < ChunksVisibleArea then
				PreloadChunkIfNeeded(indexX, indexZ)
			end

		end
	end
end


---@param playerChunkX integer
---@param playerChunkZ integer
function UnloadInvisibleChunks(playerChunkX, playerChunkZ)
	local unloadedChunks = {}
	for chunkId, chunk in pairs(Chunks) do
		if CycleDist(playerChunkX, chunk.realIndexX, MapChunkSizeX) > ChunksUnloadAreaX or
		   CycleDist(playerChunkZ, chunk.realIndexZ, MapChunkSizeZ) > ChunksUnloadAreaZ then
			if chunk.status ~= ChunkStatus.unloaded then
				unloadedChunks[chunkId] = true
				-- DebugPrint('Unloading chunk ' .. chunkId .. ' ' .. chunk.fileName)
				UnloadChunk(chunk)
				chunk.status = ChunkStatus.unloaded
			end
		end
	end
end

---@param pos Vec3
---@return number
---@return number
function ChunkXZFromPos(pos)
	local chunkX = math.floor(pos[1] / ChunkSizeX) - WorldOriginX
	local chunkZ = math.floor(pos[3] / ChunkSizeZ) - WorldOriginZ

	local chunkX = Cycle(chunkX, MapChunkSizeX)
	local chunkZ = Cycle(chunkZ, MapChunkSizeZ)

	return chunkX, chunkZ
end

---@param playerChunkX integer
---@param playerChunkZ integer
local function LoadQueuedChunks(playerChunkX, playerChunkZ)
	local t = GetTime()
	if t - LastLoadTime < LoadTimeInterval then
		return
	end

	LastLoadTime = t


	--- @type {chunk: Chunk?, indexDist: number?}
	local closestChunk = {
		indexDist = nil,
		chunk = nil,
	}

	for id, chunk in pairs(Chunks) do
		if chunk.status == ChunkStatus.queued then
			local dx = CycleDist(playerChunkX, chunk.realIndexX, MapChunkSizeX)
			local dz = CycleDist(playerChunkZ, chunk.realIndexZ, MapChunkSizeZ)
			local indexDist = math.sqrt(dx * dx + dz * dz)

			if closestChunk.indexDist == nil or
			   closestChunk.indexDist > indexDist then
				closestChunk = {
					chunk = chunk,
					indexDist = indexDist,
				}
			   end
		end
	end

	
	
	if closestChunk.chunk ~= nil then
		-- DebugPrint('Dequed ' .. closestChunk.chunk.fileName)
		LoadChunk(closestChunk.chunk)
		closestChunk.chunk.status = ChunkStatus.loaded
	else
		-- DebugPrint('No chunk to load')
	end

end

local shifted = false

function ShiftWorld(playerPos)
	local playerChunkX = math.floor(playerPos[1] / ChunkSizeX)
	local playerChunkZ = math.floor(playerPos[3] / ChunkSizeZ)

	-- DebugPrint('po ' .. playerChunkX .. ' ' .. playerChunkZ)

	local shiftX = 0
	local shiftZ = 0

	if playerChunkX >= ShiftAreaX then
		-- shiftX = -ShiftAreaX --  - (ShiftAreaX - playerChunkX)
		shiftX = -playerChunkX
		shiftZ = -playerChunkZ
	end

	if playerChunkX <= -ShiftAreaX then
		-- shiftX = ShiftAreaX -- + (ShiftAreaX - playerChunkX)
		shiftX = -playerChunkX
		shiftZ = -playerChunkZ
	end

	if playerChunkZ >= ShiftAreaZ then
		-- shiftZ = -ShiftAreaZ -- - (ShiftAreaZ - playerChunkZ)
		shiftX = -playerChunkX
		shiftZ = -playerChunkZ
	end

	if playerChunkZ <= -ShiftAreaZ then
		-- shiftZ = ShiftAreaZ  -- + (ShiftAreaZ - playerChunkZ)
		shiftX = -playerChunkX
		shiftZ = -playerChunkZ
	end

	if shiftX ~= 0 or shiftZ ~= 0 and not shifted then
		-- shifted = true
		Print('Shifting world ' .. shiftX .. ' ' .. shiftZ)

		WorldOriginX = WorldOriginX + shiftX
		WorldOriginZ = WorldOriginZ + shiftZ

		local playerVehicle = GetPlayerVehicle()

		if playerVehicle == 0 then
			-- DebugPrint('Teleporting player')
			local playerTr = GetPlayerTransform(true)
			local playerPos = playerTr.pos
			playerTr.pos = Vec(
				playerPos[1] + shiftX * ChunkSizeX,
				playerTr.pos[2],
				playerPos[3] + shiftZ * ChunkSizeZ
			)
			
			TeleportPlayer(playerTr)
		end

		local worldBody = GetWorldBody()

		local bodes = FindBodies('', true)
		-- DebugPrint(tostring(bodes))
		for i, body in pairs(bodes) do
			if body ~= worldBody then
				local bodyTransform = GetBodyTransform(body)
				local bodyPos = bodyTransform.pos
	
				-- DebugPrint('s b '.. body .. ' pos=' .. VecString(bodyPos) .. ' desc=' .. GetDescription(body))
				local vehicle = GetBodyVehicle(body)
				local dynamic = IsBodyDynamic(body)
				if vehicle == 0 and dynamic then
					-- DebugPrint('Set body dynamic false: ' .. body)
					SetBodyActive(body, false)
				end
				bodyTransform.pos = Vec(
					bodyPos[1] + shiftX * ChunkSizeX,
					bodyPos[2],
					bodyPos[3] + shiftZ * ChunkSizeZ
				)
				SetBodyTransform(body, bodyTransform)
			end
		end



		-- for id, chunk in pairs(Chunks) do
		-- 	if chunk.status == ChunkStatus.loaded then
		-- 		local chunkBody = chunk.data.body
		-- 		local chunkTransform = GetBodyTransform(chunkBody)
		-- 		chunkTransform.pos = GetChunkWorldPos(chunk)
		-- 		SetBodyTransform(chunkBody, chunkTransform)
		-- 	end
		-- end
	end
end


---@param playerChunkX integer
---@param playerChunkZ integer
function RemoveTooFarChunks(playerChunkX, playerChunkZ)
	for id, chunk in pairs(Chunks) do
		if (chunk.data ~= nil)
		   and (chunk.status == ChunkStatus.unloaded)
 		   and (CycleDist(playerChunkZ, chunk.realIndexZ, MapChunkSizeZ) > ChunksRemoveAreaZ)
		then
			-- DebugPrint('Deleting chunk ' .. chunk.fileName)
			Delete(chunk.data.body)
			chunk.data = nil
		end
	end
end

---@param playerPos Vec3
function ChunkManager.update(playerPos)
	local playerChunkX = math.floor(playerPos[1] / ChunkSizeX) - WorldOriginX
	local playerChunkZ = math.floor(playerPos[3] / ChunkSizeZ) - WorldOriginZ
	local indexX = Cycle(playerChunkX, MapChunkSizeX)
	local indexZ = Cycle(playerChunkZ, MapChunkSizeZ)

	local chunkId = GetChunkId(indexX, indexZ)
	if Chunks[chunkId] ~= nil then
		local chunk = Chunks[chunkId]
		Watch('Player.Chunk.Filename', chunk.fileName)
	end
	ShiftWorld(playerPos)
	PreloadVisibleChunks(playerChunkX, playerChunkZ)
	LoadQueuedChunks(playerChunkX, playerChunkZ)
	UnloadInvisibleChunks(playerChunkX, playerChunkZ)
	RemoveTooFarChunks(playerChunkX, playerChunkZ)
end


function init()
	Print("ChunksDirectory "..ChunksDirectory)
	for i, body in pairs(FindBodies('', true)) do
		Print('Body #' .. i .. 
		' id=' .. body .. 
		' description=' .. GetDescription(body) .. 
	    ' hasPlayerTag? ' .. tostring(HasTag(body, 'player')) ..
		' isWorldBody? ' .. tostring(GetWorldBody() == body)
	)
	end

	for i, vehicle in pairs(FindVehicles('', true)) do
		Print('Vehicle #' .. i .. 
			' id=' .. vehicle .. 
			' description=' .. GetDescription(vehicle)
		)
		local body = GetVehicleBody(vehicle)
		table.insert(CycledBodies, body)
	end
end

function tick()

	if InputReleased("R") then
		Debug = not Debug
	end

	local tr = GetPlayerTransform()
	local playerPos = tr.pos

	local playerRealPos = VecScale(
		VecAdd(
			VecAdd(
				playerPos, 
				Vec(-WorldOriginX * ChunkSizeX, 0, -WorldOriginZ * ChunkSizeZ)
			), 
			Vec(ChunkSizeX/2, 0, ChunkSizeZ/2)
		),
		10
	)

	playerRealPos[1] = math.fmod(playerRealPos[1], 2048)
	playerRealPos[3] = math.fmod(playerRealPos[3], 16384)
	SetFloat('level.playerX', playerRealPos[1])
	SetFloat('level.playerZ', playerRealPos[3])

	Watch('Player.Pos', VecString(playerPos))
	Watch('Player.RealPos', VecString(playerRealPos))
	Watch('Player.Vehicle', GetPlayerVehicle())
	




	local chunkX = math.floor(playerPos[1] / ChunkSizeX)
	local chunkY = 0
	local chunkZ = math.floor(playerPos[3] / ChunkSizeZ)
	Watch("Chunk", chunkX .. " " .. chunkZ)

	Watch('WorldOrigin', WorldOriginX .. ' ' .. WorldOriginZ)
	local unloaded = 0
	local loaded = 0
	local queued = 0
	
	for id, chunk in pairs(Chunks) do

		local r = 1
		local g = 1
		local b = 1

		if chunk.status == ChunkStatus.unloaded then
			unloaded = unloaded + 1
			if chunk.data ~= nil then
				r, g, b = 1, 1, 0
			else
				r, g, b = 1, 0, 0
			end
		end

		if chunk.status == ChunkStatus.loaded then
			r, g, b = 0, 1, 0
			loaded = loaded + 1
		end


		if chunk.status == ChunkStatus.queued then
			r = 0
			g = 0
			b = 1

			queued = queued + 1
		end

		if Debug then
			local chunkWorldPos = GetChunkWorldPos(chunk)
			local crossPos = VecAdd(chunkWorldPos, Vec(0, -ChunkYPos * 0.70, 0))
			-- crossPos[2] = playerPos[2]x
			local crossSize = ChunkSizeX / 2 / 10
			DebugLine(
				VecAdd(crossPos, Vec(-crossSize, 0, -crossSize)),
				VecAdd(crossPos, Vec(crossSize, 0, crossSize)),
				r, g, b
			)
	
			DebugLine(
				VecAdd(crossPos, Vec(-crossSize, 0, crossSize)),
				VecAdd(crossPos, Vec(crossSize, 0, -crossSize)),
				r, g, b
			)
	
			DebugCross(crossPos, r, g, b)
		end
	end

	if Debug then
		local y = ChunkYPos/4 -- playerPos[2]
		local lb = Vec(-ShiftAreaX * ChunkSizeX, y, -ShiftAreaZ * ChunkSizeZ)
		local rb = Vec(ShiftAreaX * ChunkSizeX, y, -ShiftAreaZ * ChunkSizeZ)
		local lt = Vec(-ShiftAreaX * ChunkSizeX, y, ShiftAreaZ * ChunkSizeZ)
		local rt = Vec(ShiftAreaX * ChunkSizeX, y, ShiftAreaZ * ChunkSizeZ)
	
	
		local r = 1
		local g = 0.5
		local b = 1
	
		DebugLine(lb, rb, r, g, b)
		DebugLine(lb, lt, r, g, b)
		DebugLine(rb, rt, r, g, b)
		DebugLine(lt, rt, r, g, b)
	
		Watch('unloaded', unloaded)
		Watch('queued', queued)
		Watch('loaded', loaded)
	
		local shapes = GetBodyShapes(GetWorldBody())
		DebugWatch('World body shapes', #shapes)
		for _, shape in ipairs(shapes) do
			DrawShapeOutline(shape, 0.5)
		end
	end

	ChunkManager.update(playerPos)

end