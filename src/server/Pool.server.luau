--[[
	Pool.server.luau

	Creates a raised rectangular pool with terrain water.
]]

local Workspace = game:GetService("Workspace")

-- Pool configuration
local POSITION: Vector3 = Vector3.new(0, 0, 213)

-- Dimensions
local POOL_LENGTH: number = 40
local POOL_WIDTH: number = 20
local POOL_DEPTH: number = 6
local WALL_THICKNESS: number = 2
local WALL_HEIGHT: number = POOL_DEPTH + 2 -- Walls extend above water

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(160, 155, 145),
	STONE_DARK = Color3.fromRGB(120, 115, 105),
	STONE_RIM = Color3.fromRGB(140, 135, 125),
}

--[[
	Creates a part with common properties
]]
local function createPart(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material?): Part
	local part: Part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.Color = color
	part.Material = material or Enum.Material.Cobblestone
	part.Parent = parent
	return part
end

--[[
	Builds the pool
]]
local function buildPool(): Model
	print("[Pool] Building raised pool at", POSITION)

	local pool: Model = Instance.new("Model")
	pool.Name = "Pool"

	local terrain: Terrain = Workspace.Terrain

	-- Pool center and bounds
	local centerX: number = POSITION.X
	local centerZ: number = POSITION.Z
	local baseY: number = POSITION.Y

	-- Pool floor (bottom of pool)
	createPart(pool, "PoolFloor",
		Vector3.new(POOL_LENGTH, WALL_THICKNESS, POOL_WIDTH),
		Vector3.new(centerX, baseY + WALL_THICKNESS / 2, centerZ),
		COLORS.STONE_DARK, Enum.Material.Slate)

	-- Pool walls (containing the water)
	-- North wall (positive Z)
	createPart(pool, "WallNorth",
		Vector3.new(POOL_LENGTH + WALL_THICKNESS * 2, WALL_HEIGHT, WALL_THICKNESS),
		Vector3.new(centerX, baseY + WALL_HEIGHT / 2, centerZ + POOL_WIDTH / 2 + WALL_THICKNESS / 2),
		COLORS.STONE, Enum.Material.Cobblestone)

	-- South wall (negative Z)
	createPart(pool, "WallSouth",
		Vector3.new(POOL_LENGTH + WALL_THICKNESS * 2, WALL_HEIGHT, WALL_THICKNESS),
		Vector3.new(centerX, baseY + WALL_HEIGHT / 2, centerZ - POOL_WIDTH / 2 - WALL_THICKNESS / 2),
		COLORS.STONE, Enum.Material.Cobblestone)

	-- East wall (positive X)
	createPart(pool, "WallEast",
		Vector3.new(WALL_THICKNESS, WALL_HEIGHT, POOL_WIDTH),
		Vector3.new(centerX + POOL_LENGTH / 2 + WALL_THICKNESS / 2, baseY + WALL_HEIGHT / 2, centerZ),
		COLORS.STONE, Enum.Material.Cobblestone)

	-- West wall (negative X)
	createPart(pool, "WallWest",
		Vector3.new(WALL_THICKNESS, WALL_HEIGHT, POOL_WIDTH),
		Vector3.new(centerX - POOL_LENGTH / 2 - WALL_THICKNESS / 2, baseY + WALL_HEIGHT / 2, centerZ),
		COLORS.STONE, Enum.Material.Cobblestone)

	-- Decorative rim around top
	local rimHeight: number = 0.5
	local rimWidth: number = 1

	-- North rim
	createPart(pool, "RimNorth",
		Vector3.new(POOL_LENGTH + WALL_THICKNESS * 2 + rimWidth * 2, rimHeight, WALL_THICKNESS + rimWidth),
		Vector3.new(centerX, baseY + WALL_HEIGHT + rimHeight / 2, centerZ + POOL_WIDTH / 2 + WALL_THICKNESS / 2),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	-- South rim
	createPart(pool, "RimSouth",
		Vector3.new(POOL_LENGTH + WALL_THICKNESS * 2 + rimWidth * 2, rimHeight, WALL_THICKNESS + rimWidth),
		Vector3.new(centerX, baseY + WALL_HEIGHT + rimHeight / 2, centerZ - POOL_WIDTH / 2 - WALL_THICKNESS / 2),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	-- East rim
	createPart(pool, "RimEast",
		Vector3.new(WALL_THICKNESS + rimWidth, rimHeight, POOL_WIDTH),
		Vector3.new(centerX + POOL_LENGTH / 2 + WALL_THICKNESS / 2, baseY + WALL_HEIGHT + rimHeight / 2, centerZ),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	-- West rim
	createPart(pool, "RimWest",
		Vector3.new(WALL_THICKNESS + rimWidth, rimHeight, POOL_WIDTH),
		Vector3.new(centerX - POOL_LENGTH / 2 - WALL_THICKNESS / 2, baseY + WALL_HEIGHT + rimHeight / 2, centerZ),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	-- Fill with terrain water
	local waterTop: number = baseY + WALL_HEIGHT - 1
	local waterBottom: number = baseY + WALL_THICKNESS
	local waterHeight: number = waterTop - waterBottom

	terrain:FillBlock(
		CFrame.new(centerX, waterBottom + waterHeight / 2, centerZ),
		Vector3.new(POOL_LENGTH, waterHeight, POOL_WIDTH),
		Enum.Material.Water
	)

	pool.Parent = Workspace

	print("[Pool] Pool complete with terrain water (swimming enabled)")
	return pool
end

-- Build the pool
buildPool()
