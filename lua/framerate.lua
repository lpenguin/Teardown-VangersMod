local prevFrameTime = 0
local nFrames = 0
local fps = 0

function tick(dt)
	nFrames = nFrames + 1
	local time = GetTime()
	if prevFrameTime == 0 then
		prevFrameTime = time
	end

	if time - prevFrameTime > 1 then
		fps = nFrames / (time - prevFrameTime)
		prevFrameTime = time
		nFrames = 0
	end

	DebugWatch('FPS', fps)
end