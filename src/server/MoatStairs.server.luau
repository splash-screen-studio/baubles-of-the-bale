--[[
	MoatStairs.server.luau

	Creates stairs up to exterior wall, bridge over water, stairs down to island.
]]

local Workspace = game:GetService("Workspace")

-- Key positions
local START_Z: number = -67 -- Where ascending stairs begin
local EXTERIOR_WALL_Z: number = -69 -- Top of exterior wall
local INTERIOR_WALL_Z: number = -87 -- Top of interior wall (island side)
local X_POS: number = 66

-- Moat reference values
local WALL_HEIGHT: number = 8

-- Stair dimensions
local STAIR_WIDTH: number = 6
local STAIR_DEPTH: number = 2
local STAIR_HEIGHT: number = 1

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(140, 135, 125),
	STONE_DARK = Color3.fromRGB(110, 105, 95),
	STONE_RIM = Color3.fromRGB(130, 125, 115),
	WOOD = Color3.fromRGB(101, 78, 50),
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
	Builds the stairs and bridge
]]
local function buildStairs(): Model
	print("[MoatStairs] Building stairs and bridge at X =", X_POS)

	local stairs: Model = Instance.new("Model")
	stairs.Name = "MoatStairs"

	-- Calculate stair counts
	local stepsUp: number = math.ceil(WALL_HEIGHT / STAIR_HEIGHT)
	local stepsDown: number = stepsUp

	-- === ASCENDING STAIRS (ground to exterior wall) ===
	-- Start at START_Z, go south toward EXTERIOR_WALL_Z
	for i = 0, stepsUp - 1 do
		local y: number = i * STAIR_HEIGHT
		local z: number = START_Z - (i * STAIR_DEPTH)

		createPart(stairs, "StepUp" .. i,
			Vector3.new(STAIR_WIDTH, STAIR_HEIGHT, STAIR_DEPTH),
			CFrame.new(X_POS, y + STAIR_HEIGHT / 2, z - STAIR_DEPTH / 2),
			COLORS.STONE)
	end

	-- === BRIDGE OVER WATER ===
	-- Spans from exterior wall to interior wall
	local bridgeLength: number = math.abs(INTERIOR_WALL_Z - EXTERIOR_WALL_Z)
	local bridgeCenterZ: number = (EXTERIOR_WALL_Z + INTERIOR_WALL_Z) / 2

	-- Main bridge deck
	createPart(stairs, "BridgeDeck",
		Vector3.new(STAIR_WIDTH + 1, 1.5, bridgeLength + 4),
		CFrame.new(X_POS, WALL_HEIGHT + 0.75, bridgeCenterZ),
		COLORS.WOOD, Enum.Material.Wood)

	-- Bridge railings
	createPart(stairs, "RailingLeft",
		Vector3.new(0.5, 3, bridgeLength + 4),
		CFrame.new(X_POS - STAIR_WIDTH / 2 - 0.5, WALL_HEIGHT + 3, bridgeCenterZ),
		COLORS.WOOD, Enum.Material.Wood)

	createPart(stairs, "RailingRight",
		Vector3.new(0.5, 3, bridgeLength + 4),
		CFrame.new(X_POS + STAIR_WIDTH / 2 + 0.5, WALL_HEIGHT + 3, bridgeCenterZ),
		COLORS.WOOD, Enum.Material.Wood)

	-- === DESCENDING STAIRS (interior wall down to island) ===
	-- Start at interior wall, go further south into island
	local descentStartZ: number = INTERIOR_WALL_Z - 2

	for i = 0, stepsDown - 1 do
		local y: number = WALL_HEIGHT - (i + 1) * STAIR_HEIGHT
		local z: number = descentStartZ - (i * STAIR_DEPTH)

		createPart(stairs, "StepDown" .. i,
			Vector3.new(STAIR_WIDTH, STAIR_HEIGHT, STAIR_DEPTH),
			CFrame.new(X_POS, y + STAIR_HEIGHT / 2, z - STAIR_DEPTH / 2),
			COLORS.STONE)
	end

	-- === SIDE WALLS FOR ASCENDING ===
	for i = 0, stepsUp - 1 do
		local wallHeight: number = (i + 1) * STAIR_HEIGHT + 2
		local y: number = wallHeight / 2
		local z: number = START_Z - (i * STAIR_DEPTH) - STAIR_DEPTH / 2

		createPart(stairs, "WallLeftUp" .. i,
			Vector3.new(0.8, wallHeight, STAIR_DEPTH),
			CFrame.new(X_POS - STAIR_WIDTH / 2 - 0.4, y, z),
			COLORS.STONE_DARK)

		createPart(stairs, "WallRightUp" .. i,
			Vector3.new(0.8, wallHeight, STAIR_DEPTH),
			CFrame.new(X_POS + STAIR_WIDTH / 2 + 0.4, y, z),
			COLORS.STONE_DARK)
	end

	-- === SIDE WALLS FOR DESCENDING ===
	for i = 0, stepsDown - 1 do
		local wallHeight: number = (stepsDown - i) * STAIR_HEIGHT + 2
		local y: number = wallHeight / 2
		local z: number = descentStartZ - (i * STAIR_DEPTH) - STAIR_DEPTH / 2

		createPart(stairs, "WallLeftDown" .. i,
			Vector3.new(0.8, wallHeight, STAIR_DEPTH),
			CFrame.new(X_POS - STAIR_WIDTH / 2 - 0.4, y, z),
			COLORS.STONE_DARK)

		createPart(stairs, "WallRightDown" .. i,
			Vector3.new(0.8, wallHeight, STAIR_DEPTH),
			CFrame.new(X_POS + STAIR_WIDTH / 2 + 0.4, y, z),
			COLORS.STONE_DARK)
	end

	stairs.Parent = Workspace

	print("[MoatStairs] Complete - stairs up, bridge over water, stairs down to island!")
	return stairs
end

-- Build the stairs
buildStairs()
