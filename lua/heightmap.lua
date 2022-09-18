local file = GetString("file", "testground.png", "script png")
local heightScale = GetInt("scale", 64)
local tileSize = GetInt("tilesize", 128)
local hollow = GetInt("hollow", 1)

function init()
	matRock = CreateMaterial("dirt", 88/256.0, 104/256.0, 68/256.0)
	matDirt = CreateMaterial("dirt", 88/256.0, 104/256.0, 68/256.0, 1, 0, 0.1)
	matGrass1 = CreateMaterial("dirt", 0.17, 0.21, 0.15, 0, 0, 0.2)
	matGrass2 = CreateMaterial("dirt", 0.19, 0.24, 0.2, 0, 0, 0.2)
	matTarmac = CreateMaterial("dirt", 0.35, 0.35, 0.35, 0, 0, 0.4)
	matTarmacTrack = CreateMaterial("dirt", 0.2, 0.2, 0.2, 0, 0, 0.3)
	matTarmacLine = CreateMaterial("dirt", 0.6, 0.6, 0.6, 0, 0, 0.6)
	
	LoadImage(file)
	
	local w, h = GetImageSize()

	local maxSize = tileSize
	
	local y0 = 0
	while y0 < h do
		local y1 = y0 + maxSize
		if y1 > h then y1 = h end

		local x0 = 0
		while x0 < w do
			local x1 = x0 + maxSize
			if x1 > w then x1 = w end

				-- DebugPrint('aaa')
			-- for i=0, 1 do
			    -- local a = debug.getinfo(Heightmap)
				Vox(x0, 0, y0)
				Material(matRock)
				-- Material(matTarmac)
				Heightmap(x0, y0, x1, y1, heightScale, 123)
					
			-- end
			x0 = x1
		end
		y0 = y1
	end
end