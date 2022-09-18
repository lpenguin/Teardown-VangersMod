local map_file = 'MOD/vmcexport/minimap/fostral/map.png'

local playerX = 0
local playerZ = 0


local MAP_SIZE_SMALL = {
	width = 400,
	height = 400,
}

local MAP_SCALE_SMALL = 0.25
local MAP_SCALE_BIG = 0.25


local MAP_SIZE_BIG = {
	width = 1600,
	height = 1000,
}
local minimapWidth = MAP_SIZE_SMALL.width
local minimapHeight = MAP_SIZE_SMALL.height
local bigMap = false
local scale = MAP_SCALE_SMALL


function update()
	local tr = GetPlayerTransform()
	-- DebugWatch('Player', tr.pos)
	-- playerX = tr.pos[1] * 10
	-- playerY = tr.pos[3] * 10

	playerX = HasKey('level.playerX') and GetFloat('level.playerX') or tr.pos[1] * 10
	playerZ = HasKey('level.playerZ') and GetFloat('level.playerZ') or tr.pos[3] * 10

	-- playerX = GetFloat('level.playerX')
	-- playerZ = GetFloat('level.playerZ')
	if InputReleased("m") then
		bigMap = not bigMap

		minimapWidth = bigMap and MAP_SIZE_BIG.width or MAP_SIZE_SMALL.width
		minimapHeight = bigMap and MAP_SIZE_BIG.height or MAP_SIZE_SMALL.height

	end
end

function draw()
	local minimapScaledWidth = minimapWidth / scale
	local minimapScaledHeight = minimapHeight / scale
	local left = playerX - minimapScaledWidth / 2
	local top = playerZ - minimapScaledHeight / 2
	local leftMargin = 0
	local topMargin = 0

	local w, h = UiGetImageSize(map_file)

	if left > w - minimapScaledWidth  then
		left =  left - w
	end

	if top > h - minimapScaledHeight then
		top = top - h
	end

	if left < 0 then
		leftMargin = -left
		left = 0
	end

	if top < 0 then
		topMargin = -top
		top = 0
	end

	-- local w = 0
	-- local h = 0
	

	-- w = w / scale
	-- h = h / scale
	local aligh = "top left"

	local cursorX, cursorY = 25, 25
	UiPush()
		-- UiTranslate(UiCenter(), UiMiddle())

		-- UiTranslate(winWidth - minimapWidth - 10, winHeight - minimapHeight - 10)
		-- UiTranslate(winWidth, winHeight)
		-- UiTranslate(UiWidth() + leftMargin, UiHeight() + topMargin)
		UiTranslate(cursorX + leftMargin * scale, cursorY + topMargin * scale)
		UiAlign(aligh)
		UiScale(scale)
		UiImage(
			map_file, 
			left, 
			top, 
			left + minimapScaledWidth - leftMargin, 
			top + minimapScaledHeight - topMargin
		)
	UiPop()


	if leftMargin ~= 0 then
		UiPush()

		UiTranslate(cursorX, cursorY + topMargin* scale)
		UiAlign(aligh)
		UiScale(scale)
		UiImage(
			map_file, 
			w - leftMargin, 
			top, 
			math.min(w, w - leftMargin + minimapScaledWidth), 
			top + minimapScaledHeight - topMargin
		)	
		UiPop()
	end

	if topMargin ~= 0 then
		UiPush()

		UiTranslate(cursorX + leftMargin* scale, cursorY)
		
		UiAlign(aligh)
		UiScale(scale)
		UiImage(
			map_file, 
			left, 
			h - topMargin, 
			left + minimapScaledWidth - leftMargin, 
			math.min(h, h - topMargin + minimapScaledHeight)
		)
		UiPop()
	end

	if leftMargin ~= 0 and topMargin ~= 0 then
		UiPush()

		UiTranslate(cursorX, cursorY)
		UiAlign(aligh)
		UiScale(scale)
		UiImage(
			map_file, 
			w - leftMargin,
			h - topMargin, 
			math.min(w, w - leftMargin + minimapScaledWidth),
			math.min(h, h - topMargin + minimapScaledHeight)
		)
		UiPop()
	end

	local tr = GetPlayerTransform()
	local xAngle, yAngle, zAngle = GetQuatEuler(tr.rot)
	UiPush()
		UiTranslate(cursorX + minimapWidth / 2, cursorY + minimapHeight / 2)
		UiAlign("center middle")
		UiScale(0.7)
		UiRotate(yAngle)
		UiImage(
			"MOD/images/player_cursor.png"
		)
	UiPop()

end