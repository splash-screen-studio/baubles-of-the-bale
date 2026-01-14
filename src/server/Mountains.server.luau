--[[
	Mountains.server.luau

	Creates foothills starting at Z=-315 transitioning to snowy mountains at Z=-411+
	Uses terrain with natural elevations and material blending.
]]

local Workspace = game:GetService("Workspace")

-- Terrain reference
local terrain: Terrain = Workspace.Terrain

-- Zone boundaries
local FOOTHILLS_START_Z: number = -315
local MOUNTAINS_START_Z: number = -411
local MOUNTAINS_END_Z: number = -550

-- X boundaries
local X_MIN: number = -300
local X_MAX: number = 300

-- Elevation settings
local BASE_HEIGHT: number = 0
local FOOTHILL_MAX_HEIGHT: number = 60
local MOUNTAIN_MAX_HEIGHT: number = 250
local TREELINE_HEIGHT: number = 80
local SNOWLINE_HEIGHT: number = 120
local GLACIER_HEIGHT: number = 180

-- Noise settings for natural terrain
local NOISE_SCALE: number = 0.008
local DETAIL_NOISE_SCALE: number = 0.03
local RIDGE_NOISE_SCALE: number = 0.015

-- Resolution (studs per terrain fill)
local RESOLUTION: number = 4

--[[
	Multi-octave noise for more natural terrain
]]
local function fractalNoise(x: number, z: number, octaves: number, persistence: number): number
	local total: number = 0
	local frequency: number = 1
	local amplitude: number = 1
	local maxValue: number = 0

	for i = 1, octaves do
		total = total + math.noise(x * frequency, z * frequency, 0) * amplitude
		maxValue = maxValue + amplitude
		amplitude = amplitude * persistence
		frequency = frequency * 2
	end

	return total / maxValue
end

--[[
	Ridge noise for mountain peaks
]]
local function ridgeNoise(x: number, z: number, scale: number): number
	local n: number = math.noise(x * scale, z * scale, 42)
	return 1 - math.abs(n) * 2 -- Creates ridges
end

--[[
	Calculate terrain height at a given position
]]
local function getTerrainHeight(x: number, z: number): number
	-- Calculate zone blend factor (0 = foothills, 1 = deep mountains)
	local zoneProgress: number = 0

	if z > FOOTHILLS_START_Z then
		return BASE_HEIGHT
	elseif z > MOUNTAINS_START_Z then
		-- Foothills zone - gradual transition
		zoneProgress = (FOOTHILLS_START_Z - z) / (FOOTHILLS_START_Z - MOUNTAINS_START_Z)
	else
		-- Mountain zone
		local mountainProgress: number = (MOUNTAINS_START_Z - z) / (MOUNTAINS_START_Z - MOUNTAINS_END_Z)
		zoneProgress = 1 + mountainProgress * 0.5 -- 1.0 to 1.5
	end

	-- Base terrain noise
	local baseNoise: number = fractalNoise(x * NOISE_SCALE, z * NOISE_SCALE, 4, 0.5)
	baseNoise = (baseNoise + 1) / 2 -- Normalize to 0-1

	-- Detail noise for roughness
	local detailNoise: number = fractalNoise(x * DETAIL_NOISE_SCALE, z * DETAIL_NOISE_SCALE, 2, 0.5)
	detailNoise = (detailNoise + 1) / 2

	-- Ridge noise for mountain peaks
	local ridges: number = ridgeNoise(x, z, RIDGE_NOISE_SCALE)
	ridges = math.max(0, ridges)

	-- Combine noises based on zone
	local height: number = BASE_HEIGHT

	if zoneProgress <= 1 then
		-- Foothills: gentle rolling hills
		local foothillHeight: number = baseNoise * FOOTHILL_MAX_HEIGHT * zoneProgress
		foothillHeight = foothillHeight + detailNoise * 5 * zoneProgress
		height = height + foothillHeight
	else
		-- Mountains: dramatic peaks
		local mountainFactor: number = zoneProgress - 1 -- 0 to 0.5
		local peakHeight: number = FOOTHILL_MAX_HEIGHT + (MOUNTAIN_MAX_HEIGHT - FOOTHILL_MAX_HEIGHT) * mountainFactor * 2

		-- Base mountain shape
		local mountainHeight: number = baseNoise * peakHeight

		-- Add ridges for dramatic peaks
		mountainHeight = mountainHeight + ridges * peakHeight * 0.6

		-- Add detail roughness
		mountainHeight = mountainHeight + detailNoise * 15

		-- Individual peak variation
		local peakNoise: number = math.noise(x * 0.005, z * 0.005, 123)
		if peakNoise > 0.3 then
			mountainHeight = mountainHeight * (1 + (peakNoise - 0.3) * 0.8)
		end

		height = height + mountainHeight
	end

	return math.max(BASE_HEIGHT, height)
end

--[[
	Determine terrain material based on height and position
]]
local function getTerrainMaterial(x: number, z: number, height: number, surfaceHeight: number): Enum.Material
	-- Noise for material variation
	local materialNoise: number = math.noise(x * 0.05, z * 0.05, 789)
	local detailNoise: number = math.noise(x * 0.1, z * 0.1, 456)

	-- Depth below surface affects material
	local depthBelowSurface: number = surfaceHeight - height

	-- Deep underground is always rock
	if depthBelowSurface > 8 then
		if materialNoise > 0.3 then
			return Enum.Material.Rock
		else
			return Enum.Material.Slate
		end
	end

	-- Surface and near-surface materials based on elevation
	if surfaceHeight >= GLACIER_HEIGHT then
		-- Glacier zone - ice and snow
		if materialNoise > 0.4 then
			return Enum.Material.Glacier
		elseif materialNoise > -0.2 then
			return Enum.Material.Ice
		else
			return Enum.Material.Snow
		end

	elseif surfaceHeight >= SNOWLINE_HEIGHT then
		-- Snow zone - mostly snow with exposed rock
		if materialNoise > 0.5 then
			return Enum.Material.Rock
		elseif materialNoise > 0.2 then
			return Enum.Material.Slate
		elseif detailNoise > 0.4 then
			return Enum.Material.Ice
		else
			return Enum.Material.Snow
		end

	elseif surfaceHeight >= TREELINE_HEIGHT then
		-- Above treeline - rock, slate, some snow patches
		if materialNoise > 0.4 then
			return Enum.Material.Rock
		elseif materialNoise > 0 then
			return Enum.Material.Slate
		elseif detailNoise > 0.5 then
			return Enum.Material.Snow
		else
			return Enum.Material.Ground
		end

	elseif surfaceHeight >= FOOTHILL_MAX_HEIGHT * 0.5 then
		-- Upper foothills - grass, rock outcrops, ground
		if materialNoise > 0.5 then
			return Enum.Material.Rock
		elseif materialNoise > 0.2 then
			return Enum.Material.Ground
		elseif detailNoise > 0.3 then
			return Enum.Material.LeafyGrass
		else
			return Enum.Material.Grass
		end

	else
		-- Lower foothills - lush grass, some dirt
		if materialNoise > 0.6 then
			return Enum.Material.Ground
		elseif materialNoise > 0.3 then
			return Enum.Material.Grass
		elseif detailNoise > 0.2 then
			return Enum.Material.LeafyGrass
		else
			return Enum.Material.Grass
		end
	end
end

--[[
	Fill terrain at a specific column
]]
local function fillTerrainColumn(x: number, z: number): ()
	local surfaceHeight: number = getTerrainHeight(x, z)

	if surfaceHeight <= BASE_HEIGHT + 1 then
		return -- Skip flat areas
	end

	-- Fill from base to surface
	local y: number = BASE_HEIGHT
	while y < surfaceHeight do
		local fillHeight: number = math.min(RESOLUTION, surfaceHeight - y)
		local material: Enum.Material = getTerrainMaterial(x, z, y + fillHeight / 2, surfaceHeight)

		terrain:FillBlock(
			CFrame.new(x, y + fillHeight / 2, z),
			Vector3.new(RESOLUTION, fillHeight, RESOLUTION),
			material
		)

		y = y + RESOLUTION
	end
end

--[[
	Add glacier features - ice flows and crevasses
]]
local function addGlacierFeatures(): ()
	print("[Mountains] Adding glacier features...")

	-- Large glacier flows in valleys
	for i = 1, 5 do
		local glacierX: number = X_MIN + math.random() * (X_MAX - X_MIN)
		local glacierZ: number = MOUNTAINS_START_Z - 50 - math.random() * 80
		local glacierLength: number = 40 + math.random() * 60
		local glacierWidth: number = 15 + math.random() * 20

		-- Create glacier flow
		for offset = 0, glacierLength, 8 do
			local flowX: number = glacierX + math.sin(offset * 0.05) * 10
			local flowZ: number = glacierZ - offset
			local baseHeight: number = getTerrainHeight(flowX, flowZ)

			terrain:FillBlock(
				CFrame.new(flowX, baseHeight + 3, flowZ),
				Vector3.new(glacierWidth - offset * 0.2, 8, 12),
				Enum.Material.Glacier
			)
		end
	end
end

--[[
	Add snow accumulation on peaks
]]
local function addSnowCaps(): ()
	print("[Mountains] Adding snow caps...")

	-- Find high points and add extra snow
	for x = X_MIN, X_MAX, 20 do
		for z = MOUNTAINS_START_Z - 30, MOUNTAINS_END_Z, 20 do
			local height: number = getTerrainHeight(x, z)

			if height > SNOWLINE_HEIGHT + 20 then
				-- Add snow cap
				local snowDepth: number = 3 + math.random() * 4
				terrain:FillBall(
					Vector3.new(x, height + snowDepth / 2, z),
					8 + math.random() * 6,
					Enum.Material.Snow
				)
			end
		end
	end
end

--[[
	Add rocky outcrops and boulders
]]
local function addRockyOutcrops(): ()
	print("[Mountains] Adding rocky outcrops...")

	-- Scatter boulders in foothills
	for i = 1, 40 do
		local x: number = X_MIN + math.random() * (X_MAX - X_MIN)
		local z: number = FOOTHILLS_START_Z - math.random() * (FOOTHILLS_START_Z - MOUNTAINS_START_Z)
		local height: number = getTerrainHeight(x, z)

		if height > 10 then
			local boulderSize: number = 4 + math.random() * 8
			terrain:FillBall(
				Vector3.new(x, height + boulderSize / 3, z),
				boulderSize,
				Enum.Material.Rock
			)
		end
	end

	-- Add cliff faces in mountains
	for i = 1, 25 do
		local x: number = X_MIN + math.random() * (X_MAX - X_MIN)
		local z: number = MOUNTAINS_START_Z - 20 - math.random() * 100
		local height: number = getTerrainHeight(x, z)

		if height > TREELINE_HEIGHT then
			-- Vertical rock face
			terrain:FillBlock(
				CFrame.new(x, height - 10, z) * CFrame.Angles(math.rad(math.random(-20, 20)), 0, 0),
				Vector3.new(8 + math.random() * 12, 25 + math.random() * 20, 6),
				Enum.Material.Rock
			)
		end
	end
end

--[[
	Main terrain generation
]]
local function generateMountains(): ()
	print("[Mountains] Generating foothills and mountains...")
	print("[Mountains] Foothills: Z =", FOOTHILLS_START_Z, "to", MOUNTAINS_START_Z)
	print("[Mountains] Mountains: Z =", MOUNTAINS_START_Z, "to", MOUNTAINS_END_Z)

	local totalColumns: number = 0
	local startTime: number = os.clock()

	-- Generate base terrain grid
	for x = X_MIN, X_MAX, RESOLUTION do
		for z = FOOTHILLS_START_Z, MOUNTAINS_END_Z, -RESOLUTION do
			fillTerrainColumn(x, z)
			totalColumns = totalColumns + 1
		end

		-- Yield periodically to prevent timeout
		if x % 50 == 0 then
			task.wait()
			print("[Mountains] Progress: X =", x)
		end
	end

	-- Add special features
	addRockyOutcrops()
	addSnowCaps()
	addGlacierFeatures()

	local elapsed: number = os.clock() - startTime
	print("[Mountains] Terrain complete!")
	print("[Mountains] Generated", totalColumns, "columns in", string.format("%.2f", elapsed), "seconds")
end

-- Generate the mountains
generateMountains()
