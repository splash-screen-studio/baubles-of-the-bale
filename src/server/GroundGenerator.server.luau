--[[
	GroundGenerator.server.luau

	Generates a medieval cobblestone ground with a spotty mix of
	other rock materials, sand patches, and sparse grass.
]]

local Workspace = game:GetService("Workspace")

-- Ground configuration
local GROUND_SIZE: number = 512
local TILE_SIZE: number = 8
local GROUND_THICKNESS: number = 4
local GROUND_Y: number = -GROUND_THICKNESS / 2

-- Material weights (higher = more common)
local MATERIAL_WEIGHTS: {{material: Enum.Material, color: Color3, weight: number}} = {
	-- Primary cobblestone (most common)
	{ material = Enum.Material.Cobblestone, color = Color3.fromRGB(127, 127, 127), weight = 50 },
	{ material = Enum.Material.Cobblestone, color = Color3.fromRGB(115, 115, 115), weight = 30 },
	{ material = Enum.Material.Cobblestone, color = Color3.fromRGB(140, 135, 130), weight = 20 },

	-- Other rocks
	{ material = Enum.Material.Slate, color = Color3.fromRGB(90, 90, 95), weight = 8 },
	{ material = Enum.Material.Basalt, color = Color3.fromRGB(75, 75, 80), weight = 5 },
	{ material = Enum.Material.Rock, color = Color3.fromRGB(110, 105, 100), weight = 6 },
	{ material = Enum.Material.Limestone, color = Color3.fromRGB(160, 155, 145), weight = 4 },

	-- Sand patches
	{ material = Enum.Material.Sand, color = Color3.fromRGB(180, 165, 130), weight = 5 },
	{ material = Enum.Material.Sand, color = Color3.fromRGB(195, 175, 140), weight = 3 },

	-- Sparse grass
	{ material = Enum.Material.Grass, color = Color3.fromRGB(85, 120, 70), weight = 3 },
	{ material = Enum.Material.LeafyGrass, color = Color3.fromRGB(75, 110, 60), weight = 2 },
}

-- Calculate total weight for random selection
local totalWeight: number = 0
for _, entry in MATERIAL_WEIGHTS do
	totalWeight += entry.weight
end

--[[
	Selects a random material based on weights
]]
local function getRandomMaterial(): (Enum.Material, Color3)
	local roll: number = math.random() * totalWeight
	local cumulative: number = 0

	for _, entry in MATERIAL_WEIGHTS do
		cumulative += entry.weight
		if roll <= cumulative then
			return entry.material, entry.color
		end
	end

	-- Fallback to first entry
	return MATERIAL_WEIGHTS[1].material, MATERIAL_WEIGHTS[1].color
end

--[[
	Adds slight color variation for natural look
]]
local function varyColor(baseColor: Color3): Color3
	local variation: number = 0.05
	local r: number = math.clamp(baseColor.R + (math.random() - 0.5) * variation, 0, 1)
	local g: number = math.clamp(baseColor.G + (math.random() - 0.5) * variation, 0, 1)
	local b: number = math.clamp(baseColor.B + (math.random() - 0.5) * variation, 0, 1)
	return Color3.new(r, g, b)
end

--[[
	Creates a single ground tile
]]
local function createTile(parent: Instance, x: number, z: number): Part
	local material: Enum.Material, baseColor: Color3 = getRandomMaterial()

	local tile: Part = Instance.new("Part")
	tile.Name = "GroundTile"
	tile.Size = Vector3.new(TILE_SIZE, GROUND_THICKNESS, TILE_SIZE)
	tile.Position = Vector3.new(x, GROUND_Y, z)
	tile.Anchored = true
	tile.Locked = true
	tile.Material = material
	tile.Color = varyColor(baseColor)
	tile.TopSurface = Enum.SurfaceType.Smooth
	tile.BottomSurface = Enum.SurfaceType.Smooth
	tile.Parent = parent

	return tile
end

--[[
	Generates the entire ground
]]
local function generateGround(): ()
	print("[GroundGenerator] Generating medieval ground...")

	-- Create folder for organization
	local groundFolder: Folder = Instance.new("Folder")
	groundFolder.Name = "Ground"
	groundFolder.Parent = Workspace

	-- Calculate tile grid
	local halfSize: number = GROUND_SIZE / 2
	local tilesPerSide: number = GROUND_SIZE / TILE_SIZE
	local totalTiles: number = tilesPerSide * tilesPerSide
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
		if xIndex % 8 == 0 then
			task.wait()
		end
	end

	print("[GroundGenerator] Ground complete! Created", tilesCreated, "tiles")
end

-- Generate the ground
generateGround()
