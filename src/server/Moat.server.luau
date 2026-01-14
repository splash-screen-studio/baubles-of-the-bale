--[[
	Moat.server.luau

	Creates a raised rectangular moat with terrain water.
	Grid-aligned rectangle fitting within the original polygon.
]]

local Workspace = game:GetService("Workspace")

-- Rectangle bounds (fits within original polygon)
local X_MIN: number = 40
local X_MAX: number = 160
local Z_MIN: number = -180
local Z_MAX: number = -70

-- Moat dimensions
local MOAT_WIDTH: number = 14
local MOAT_DEPTH: number = 6
local WALL_HEIGHT: number = MOAT_DEPTH + 2
local WALL_THICKNESS: number = 2

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(150, 145, 135),
	STONE_DARK = Color3.fromRGB(110, 105, 95),
	STONE_RIM = Color3.fromRGB(130, 125, 115),
}

--[[
	Creates a part
]]
local function createPart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?): Part
	local part: Part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.Color = color
	part.Material = material or Enum.Material.Cobblestone
	part.Parent = parent
	return part
end

--[[
	Builds the moat
]]
local function buildMoat(): Model
	print("[Moat] Building raised rectangular moat...")

	local moat: Model = Instance.new("Model")
	moat.Name = "Moat"

	local terrain: Terrain = Workspace.Terrain

	-- Outer rectangle dimensions
	local outerWidth: number = X_MAX - X_MIN
	local outerLength: number = Z_MAX - Z_MIN
	local centerX: number = (X_MIN + X_MAX) / 2
	local centerZ: number = (Z_MIN + Z_MAX) / 2

	-- Inner rectangle (the "hole" in the doughnut)
	local innerWidth: number = outerWidth - (MOAT_WIDTH * 2)
	local innerLength: number = outerLength - (MOAT_WIDTH * 2)

	-- === OUTER WALLS ===
	-- North outer wall
	createPart(moat, "OuterWallNorth",
		Vector3.new(outerWidth + WALL_THICKNESS * 2, WALL_HEIGHT, WALL_THICKNESS),
		CFrame.new(centerX, WALL_HEIGHT / 2, Z_MAX + WALL_THICKNESS / 2),
		COLORS.STONE)

	-- South outer wall
	createPart(moat, "OuterWallSouth",
		Vector3.new(outerWidth + WALL_THICKNESS * 2, WALL_HEIGHT, WALL_THICKNESS),
		CFrame.new(centerX, WALL_HEIGHT / 2, Z_MIN - WALL_THICKNESS / 2),
		COLORS.STONE)

	-- East outer wall
	createPart(moat, "OuterWallEast",
		Vector3.new(WALL_THICKNESS, WALL_HEIGHT, outerLength),
		CFrame.new(X_MAX + WALL_THICKNESS / 2, WALL_HEIGHT / 2, centerZ),
		COLORS.STONE)

	-- West outer wall
	createPart(moat, "OuterWallWest",
		Vector3.new(WALL_THICKNESS, WALL_HEIGHT, outerLength),
		CFrame.new(X_MIN - WALL_THICKNESS / 2, WALL_HEIGHT / 2, centerZ),
		COLORS.STONE)

	-- === INNER WALLS ===
	-- North inner wall
	createPart(moat, "InnerWallNorth",
		Vector3.new(innerWidth + WALL_THICKNESS * 2, WALL_HEIGHT, WALL_THICKNESS),
		CFrame.new(centerX, WALL_HEIGHT / 2, Z_MAX - MOAT_WIDTH - WALL_THICKNESS / 2),
		COLORS.STONE)

	-- South inner wall
	createPart(moat, "InnerWallSouth",
		Vector3.new(innerWidth + WALL_THICKNESS * 2, WALL_HEIGHT, WALL_THICKNESS),
		CFrame.new(centerX, WALL_HEIGHT / 2, Z_MIN + MOAT_WIDTH + WALL_THICKNESS / 2),
		COLORS.STONE)

	-- East inner wall
	createPart(moat, "InnerWallEast",
		Vector3.new(WALL_THICKNESS, WALL_HEIGHT, innerLength),
		CFrame.new(X_MAX - MOAT_WIDTH - WALL_THICKNESS / 2, WALL_HEIGHT / 2, centerZ),
		COLORS.STONE)

	-- West inner wall
	createPart(moat, "InnerWallWest",
		Vector3.new(WALL_THICKNESS, WALL_HEIGHT, innerLength),
		CFrame.new(X_MIN + MOAT_WIDTH + WALL_THICKNESS / 2, WALL_HEIGHT / 2, centerZ),
		COLORS.STONE)

	-- === FLOOR ===
	-- North channel floor
	createPart(moat, "FloorNorth",
		Vector3.new(outerWidth, WALL_THICKNESS, MOAT_WIDTH),
		CFrame.new(centerX, WALL_THICKNESS / 2, Z_MAX - MOAT_WIDTH / 2),
		COLORS.STONE_DARK, Enum.Material.Slate)

	-- South channel floor
	createPart(moat, "FloorSouth",
		Vector3.new(outerWidth, WALL_THICKNESS, MOAT_WIDTH),
		CFrame.new(centerX, WALL_THICKNESS / 2, Z_MIN + MOAT_WIDTH / 2),
		COLORS.STONE_DARK, Enum.Material.Slate)

	-- East channel floor
	createPart(moat, "FloorEast",
		Vector3.new(MOAT_WIDTH, WALL_THICKNESS, innerLength),
		CFrame.new(X_MAX - MOAT_WIDTH / 2, WALL_THICKNESS / 2, centerZ),
		COLORS.STONE_DARK, Enum.Material.Slate)

	-- West channel floor
	createPart(moat, "FloorWest",
		Vector3.new(MOAT_WIDTH, WALL_THICKNESS, innerLength),
		CFrame.new(X_MIN + MOAT_WIDTH / 2, WALL_THICKNESS / 2, centerZ),
		COLORS.STONE_DARK, Enum.Material.Slate)

	-- === RIM ===
	local rimY: number = WALL_HEIGHT + 0.25

	-- Outer rim
	createPart(moat, "OuterRimNorth",
		Vector3.new(outerWidth + WALL_THICKNESS * 2 + 2, 0.5, WALL_THICKNESS + 1),
		CFrame.new(centerX, rimY, Z_MAX + WALL_THICKNESS / 2),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	createPart(moat, "OuterRimSouth",
		Vector3.new(outerWidth + WALL_THICKNESS * 2 + 2, 0.5, WALL_THICKNESS + 1),
		CFrame.new(centerX, rimY, Z_MIN - WALL_THICKNESS / 2),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	createPart(moat, "OuterRimEast",
		Vector3.new(WALL_THICKNESS + 1, 0.5, outerLength),
		CFrame.new(X_MAX + WALL_THICKNESS / 2, rimY, centerZ),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	createPart(moat, "OuterRimWest",
		Vector3.new(WALL_THICKNESS + 1, 0.5, outerLength),
		CFrame.new(X_MIN - WALL_THICKNESS / 2, rimY, centerZ),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	-- Inner rim
	createPart(moat, "InnerRimNorth",
		Vector3.new(innerWidth + WALL_THICKNESS * 2 + 2, 0.5, WALL_THICKNESS + 1),
		CFrame.new(centerX, rimY, Z_MAX - MOAT_WIDTH - WALL_THICKNESS / 2),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	createPart(moat, "InnerRimSouth",
		Vector3.new(innerWidth + WALL_THICKNESS * 2 + 2, 0.5, WALL_THICKNESS + 1),
		CFrame.new(centerX, rimY, Z_MIN + MOAT_WIDTH + WALL_THICKNESS / 2),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	createPart(moat, "InnerRimEast",
		Vector3.new(WALL_THICKNESS + 1, 0.5, innerLength),
		CFrame.new(X_MAX - MOAT_WIDTH - WALL_THICKNESS / 2, rimY, centerZ),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	createPart(moat, "InnerRimWest",
		Vector3.new(WALL_THICKNESS + 1, 0.5, innerLength),
		CFrame.new(X_MIN + MOAT_WIDTH + WALL_THICKNESS / 2, rimY, centerZ),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	-- === TERRAIN WATER ===
	local waterTop: number = WALL_HEIGHT - 1
	local waterBottom: number = WALL_THICKNESS
	local waterHeight: number = waterTop - waterBottom

	-- North channel water
	terrain:FillBlock(
		CFrame.new(centerX, waterBottom + waterHeight / 2, Z_MAX - MOAT_WIDTH / 2),
		Vector3.new(outerWidth - 2, waterHeight, MOAT_WIDTH - 2),
		Enum.Material.Water)

	-- South channel water
	terrain:FillBlock(
		CFrame.new(centerX, waterBottom + waterHeight / 2, Z_MIN + MOAT_WIDTH / 2),
		Vector3.new(outerWidth - 2, waterHeight, MOAT_WIDTH - 2),
		Enum.Material.Water)

	-- East channel water
	terrain:FillBlock(
		CFrame.new(X_MAX - MOAT_WIDTH / 2, waterBottom + waterHeight / 2, centerZ),
		Vector3.new(MOAT_WIDTH - 2, waterHeight, innerLength - 2),
		Enum.Material.Water)

	-- West channel water
	terrain:FillBlock(
		CFrame.new(X_MIN + MOAT_WIDTH / 2, waterBottom + waterHeight / 2, centerZ),
		Vector3.new(MOAT_WIDTH - 2, waterHeight, innerLength - 2),
		Enum.Material.Water)

	moat.Parent = Workspace

	print("[Moat] Rectangular moat complete!")
	print("[Moat] Bounds: X[", X_MIN, ",", X_MAX, "] Z[", Z_MIN, ",", Z_MAX, "]")
	return moat
end

-- Build the moat
buildMoat()
