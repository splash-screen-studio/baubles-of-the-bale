--[[
	GroundGenerator.server.luau

	Generates a natural medieval village ground using noise-based
	terrain generation for organic material clustering.
]]

local Workspace = game:GetService("Workspace")

-- Ground configuration
local GROUND_SIZE: number = 512
local TILE_SIZE: number = 4
local GROUND_THICKNESS: number = 4
local GROUND_Y: number = -GROUND_THICKNESS / 2

-- Noise seeds for different layers
local SEED_GRASS: number = math.random(1, 10000)
local SEED_COBBLE: number = math.random(1, 10000)
local SEED_MUD: number = math.random(1, 10000)
local SEED_STONE: number = math.random(1, 10000)

-- Color palettes for natural variation
local COLORS = {
	DIRT = {
		Color3.fromRGB(115, 85, 55),
		Color3.fromRGB(105, 78, 50),
		Color3.fromRGB(125, 92, 60),
		Color3.fromRGB(98, 72, 45),
	},
	GRASS = {
		Color3.fromRGB(85, 115, 60),
		Color3.fromRGB(75, 105, 55),
		Color3.fromRGB(95, 125, 65),
		Color3.fromRGB(80, 110, 50),
	},
	COBBLE = {
		Color3.fromRGB(130, 125, 120),
		Color3.fromRGB(120, 115, 110),
		Color3.fromRGB(140, 135, 128),
		Color3.fromRGB(110, 108, 105),
	},
	MUD = {
		Color3.fromRGB(75, 55, 35),
		Color3.fromRGB(68, 50, 32),
		Color3.fromRGB(82, 60, 40),
	},
	STONE = {
		Color3.fromRGB(105, 100, 95),
		Color3.fromRGB(95, 92, 88),
		Color3.fromRGB(115, 110, 105),
	},
}

--[[
	Simple 2D noise function using math.noise
]]
local function sampleNoise(x: number, z: number, seed: number, scale: number): number
	return math.noise(x / scale + seed, z / scale + seed)
end

--[[
	Multi-octave noise for more natural variation
]]
local function layeredNoise(x: number, z: number, seed: number): number
	local value: number = 0
	value += sampleNoise(x, z, seed, 60) * 0.5
	value += sampleNoise(x, z, seed + 100, 30) * 0.3
	value += sampleNoise(x, z, seed + 200, 15) * 0.2
	return value
end

--[[
	Calculate distance from center (for path radiance)
]]
local function distanceFromCenter(x: number, z: number): number
	return math.sqrt(x * x + z * z)
end

--[[
	Check if position is on a main path (radial from center)
]]
local function isOnPath(x: number, z: number): boolean
	local dist: number = distanceFromCenter(x, z)
	if dist < 20 then
		-- Village center square
		return true
	end

	-- Main roads radiating outward (4 directions)
	local pathWidth: number = 8
	local onNSPath: boolean = math.abs(x) < pathWidth and dist < 200
	local onEWPath: boolean = math.abs(z) < pathWidth and dist < 200

	-- Diagonal paths (less prominent)
	local diagWidth: number = 5
	local onDiag1: boolean = math.abs(x - z) < diagWidth and dist < 120
	local onDiag2: boolean = math.abs(x + z) < diagWidth and dist < 120

	return onNSPath or onEWPath or onDiag1 or onDiag2
end

--[[
	Picks a random color from a palette with slight variation
]]
local function pickColor(palette: {Color3}): Color3
	local base: Color3 = palette[math.random(1, #palette)]
	local vary: number = 0.03
	return Color3.new(
		math.clamp(base.R + (math.random() - 0.5) * vary, 0, 1),
		math.clamp(base.G + (math.random() - 0.5) * vary, 0, 1),
		math.clamp(base.B + (math.random() - 0.5) * vary, 0, 1)
	)
end

--[[
	Determines the material and color for a position based on layered rules
]]
local function getMaterialAtPosition(x: number, z: number): (Enum.Material, Color3)
	local dist: number = distanceFromCenter(x, z)
	local edgeFactor: number = dist / (GROUND_SIZE / 2) -- 0 at center, 1 at edge

	-- Sample noise layers
	local grassNoise: number = layeredNoise(x, z, SEED_GRASS)
	local cobbleNoise: number = layeredNoise(x, z, SEED_COBBLE)
	local mudNoise: number = layeredNoise(x, z, SEED_MUD)
	local stoneNoise: number = sampleNoise(x, z, SEED_STONE, 20)

	-- Layer 1: Paths get cobblestone
	if isOnPath(x, z) then
		-- Paths are mostly cobblestone but worn in spots
		if mudNoise > 0.3 then
			return Enum.Material.Mud, pickColor(COLORS.MUD)
		end
		-- Occasional stone slabs in paths
		if stoneNoise > 0.4 and math.random() < 0.3 then
			return Enum.Material.Slate, pickColor(COLORS.STONE)
		end
		return Enum.Material.Cobblestone, pickColor(COLORS.COBBLE)
	end

	-- Layer 2: Grass more likely toward edges, in patches
	local grassThreshold: number = 0.15 - (edgeFactor * 0.3) -- easier to spawn grass at edges
	if grassNoise > grassThreshold and edgeFactor > 0.3 then
		-- Grass patches
		if math.random() < 0.7 then
			return Enum.Material.Grass, pickColor(COLORS.GRASS)
		else
			return Enum.Material.LeafyGrass, pickColor(COLORS.GRASS)
		end
	end

	-- Layer 3: Mud in low areas (negative noise = low spots)
	if mudNoise < -0.25 then
		return Enum.Material.Mud, pickColor(COLORS.MUD)
	end

	-- Layer 4: Scattered cobblestone near paths (spillover)
	local nearPath: boolean = (math.abs(x) < 15 or math.abs(z) < 15) and dist < 180
	if nearPath and cobbleNoise > 0.2 then
		return Enum.Material.Cobblestone, pickColor(COLORS.COBBLE)
	end

	-- Layer 5: Occasional loose stones
	if stoneNoise > 0.45 and math.random() < 0.15 then
		return Enum.Material.Rock, pickColor(COLORS.STONE)
	end

	-- Layer 6: Ground near center is more packed/worn
	if dist < 80 and mudNoise > 0.1 then
		return Enum.Material.Ground, pickColor(COLORS.DIRT)
	end

	-- Default: Dirt/ground
	if math.random() < 0.7 then
		return Enum.Material.Ground, pickColor(COLORS.DIRT)
	else
		return Enum.Material.Mud, pickColor(COLORS.DIRT)
	end
end

--[[
	Creates a single ground tile
]]
local function createTile(parent: Instance, x: number, z: number): Part
	local material: Enum.Material, color: Color3 = getMaterialAtPosition(x, z)

	local tile: Part = Instance.new("Part")
	tile.Name = "GroundTile"
	tile.Size = Vector3.new(TILE_SIZE, GROUND_THICKNESS, TILE_SIZE)
	tile.Position = Vector3.new(x, GROUND_Y, z)
	tile.Anchored = true
	tile.Locked = true
	tile.Material = material
	tile.Color = color
	tile.TopSurface = Enum.SurfaceType.Smooth
	tile.BottomSurface = Enum.SurfaceType.Smooth
	tile.Parent = parent

	return tile
end

--[[
	Generates the entire ground
]]
local function generateGround(): ()
	print("[GroundGenerator] Generating medieval village ground...")

	-- Create folder for organization
	local groundFolder: Folder = Instance.new("Folder")
	groundFolder.Name = "Ground"
	groundFolder.Parent = Workspace

	-- Calculate tile grid
	local halfSize: number = GROUND_SIZE / 2
	local tilesPerSide: number = GROUND_SIZE / TILE_SIZE
	local tilesCreated: number = 0

	-- Generate tiles
	for xIndex = 0, tilesPerSide - 1 do
		for zIndex = 0, tilesPerSide - 1 do
			local x: number = -halfSize + (xIndex * TILE_SIZE) + (TILE_SIZE / 2)
			local z: number = -halfSize + (zIndex * TILE_SIZE) + (TILE_SIZE / 2)

			createTile(groundFolder, x, z)
			tilesCreated += 1
		end

		-- Yield occasionally to prevent timeout
		if xIndex % 16 == 0 then
			task.wait()
		end
	end

	print("[GroundGenerator] Ground complete! Created", tilesCreated, "tiles")
end

-- Generate the ground
generateGround()
