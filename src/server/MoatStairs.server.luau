--[[
	MoatStairs.server.luau

	Creates stairs that go up and over the moat wall to access the island.
]]

local Workspace = game:GetService("Workspace")

-- Stairs configuration
local POSITION: Vector3 = Vector3.new(66, 0, -67)

-- Moat reference values
local WALL_HEIGHT: number = 8
local MOAT_WIDTH: number = 14

-- Stair dimensions
local STAIR_WIDTH: number = 6
local STAIR_DEPTH: number = 2
local STAIR_HEIGHT: number = 1

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(140, 135, 125),
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
	Builds the stairs
]]
local function buildStairs(): Model
	print("[MoatStairs] Building stairs at", POSITION)

	local stairs: Model = Instance.new("Model")
	stairs.Name = "MoatStairs"

	-- Calculate stair counts
	local stepsUp: number = math.ceil(WALL_HEIGHT / STAIR_HEIGHT)
	local stepsDown: number = stepsUp

	-- === ASCENDING STAIRS (outside to rim) ===
	-- Going from north (outside) toward south (onto rim)
	for i = 0, stepsUp - 1 do
		local y: number = i * STAIR_HEIGHT
		local z: number = POSITION.Z - (i * STAIR_DEPTH)

		createPart(stairs, "StepUp" .. i,
			Vector3.new(STAIR_WIDTH, STAIR_HEIGHT, STAIR_DEPTH),
			CFrame.new(POSITION.X, y + STAIR_HEIGHT / 2, z - STAIR_DEPTH / 2),
			COLORS.STONE)
	end

	-- Landing at top of outer wall
	local landingZ: number = POSITION.Z - (stepsUp * STAIR_DEPTH)
	local landingLength: number = 4

	createPart(stairs, "Landing",
		Vector3.new(STAIR_WIDTH + 2, 1, landingLength),
		CFrame.new(POSITION.X, WALL_HEIGHT + 0.5, landingZ - landingLength / 2),
		COLORS.STONE_RIM, Enum.Material.Limestone)

	-- === DESCENDING STAIRS (rim down to island) ===
	-- Continue south, going down into the island
	local descentStartZ: number = landingZ - landingLength

	for i = 0, stepsDown - 1 do
		local y: number = WALL_HEIGHT - (i + 1) * STAIR_HEIGHT
		local z: number = descentStartZ - (i * STAIR_DEPTH)

		createPart(stairs, "StepDown" .. i,
			Vector3.new(STAIR_WIDTH, STAIR_HEIGHT, STAIR_DEPTH),
			CFrame.new(POSITION.X, y + STAIR_HEIGHT / 2, z - STAIR_DEPTH / 2),
			COLORS.STONE)
	end

	-- === SIDE WALLS ===
	-- Left wall ascending
	for i = 0, stepsUp - 1 do
		local wallHeight: number = (i + 1) * STAIR_HEIGHT + 2
		local y: number = wallHeight / 2
		local z: number = POSITION.Z - (i * STAIR_DEPTH) - STAIR_DEPTH / 2

		createPart(stairs, "WallLeftUp" .. i,
			Vector3.new(0.8, wallHeight, STAIR_DEPTH),
			CFrame.new(POSITION.X - STAIR_WIDTH / 2 - 0.4, y, z),
			COLORS.STONE_DARK)
	end

	-- Right wall ascending
	for i = 0, stepsUp - 1 do
		local wallHeight: number = (i + 1) * STAIR_HEIGHT + 2
		local y: number = wallHeight / 2
		local z: number = POSITION.Z - (i * STAIR_DEPTH) - STAIR_DEPTH / 2

		createPart(stairs, "WallRightUp" .. i,
			Vector3.new(0.8, wallHeight, STAIR_DEPTH),
			CFrame.new(POSITION.X + STAIR_WIDTH / 2 + 0.4, y, z),
			COLORS.STONE_DARK)
	end

	-- Left wall descending
	for i = 0, stepsDown - 1 do
		local wallHeight: number = (stepsDown - i) * STAIR_HEIGHT + 2
		local y: number = wallHeight / 2
		local z: number = descentStartZ - (i * STAIR_DEPTH) - STAIR_DEPTH / 2

		createPart(stairs, "WallLeftDown" .. i,
			Vector3.new(0.8, wallHeight, STAIR_DEPTH),
			CFrame.new(POSITION.X - STAIR_WIDTH / 2 - 0.4, y, z),
			COLORS.STONE_DARK)
	end

	-- Right wall descending
	for i = 0, stepsDown - 1 do
		local wallHeight: number = (stepsDown - i) * STAIR_HEIGHT + 2
		local y: number = wallHeight / 2
		local z: number = descentStartZ - (i * STAIR_DEPTH) - STAIR_DEPTH / 2

		createPart(stairs, "WallRightDown" .. i,
			Vector3.new(0.8, wallHeight, STAIR_DEPTH),
			CFrame.new(POSITION.X + STAIR_WIDTH / 2 + 0.4, y, z),
			COLORS.STONE_DARK)
	end

	stairs.Parent = Workspace

	print("[MoatStairs] Stairs complete - ascends to rim, descends to island!")
	return stairs
end

-- Build the stairs
buildStairs()
