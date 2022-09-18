local ents = {}
function init()
	ents = Spawn([[ 
		<body dyname="false">
			<voxscript pos="0.0 3.5 0.0" texture="1" collide="true" file="MOD/lua/heightmap.lua">
				<parameters scale="64" hollow="0" tilesize="128" file="MOD/vmcexport/fostral1/hm/height_13x7.png"/>
			</voxscript>
		</body>
	]],
	 Transform(Vec(0, 10, 0)), true)
	
	for i, e in pairs(ents) do
		DebugPrint('E #'..i .. ' ' .. e .. ' type=' .. GetEntityType(e) .. ' body=' .. GetShapeBody(e))
	end
end

function update(dt)
	for i, e in pairs(ents) do
		local tr = GetShapeLocalTransform(e)
		tr.pos = VecAdd(tr.pos, Vec(0, 0, 1 * dt))
		-- SetShapeLocalTransform(e, tr)
	end

	local tr = GetBodyTransform(12)
	tr.pos = VecAdd(tr.pos, Vec(0, 0, 1 * dt))
	SetBodyTransform(12, tr)
	
end