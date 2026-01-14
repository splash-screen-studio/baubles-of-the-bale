--[[
	MoatStairs.server.luau

	Creates stairs for moat access.
]]

local Workspace = game:GetService("Workspace")

-- Stairs configuration
local POSITION: Vector3 = Vector3.new(66, 0, -67)

-- Dimensions
local STAIR_WIDTH: number = 8
local STAIR_DEPTH: number = 3
local STAIR_HEIGHT: number = 1
local STAIR_COUNT: number = 8

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(140, 135, 125),
	STONE_DARK = Color3.fromRGB(110, 105, 95),
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

	-- Build stairs descending into moat (going negative Z)
	for i = 0, STAIR_COUNT - 1 do
		local y: number = POSITION.Y + (STAIR_COUNT - 1 - i) * STAIR_HEIGHT
		local z: number = POSITION.Z - (i * STAIR_DEPTH)

		-- Main step
		createPart(stairs, "Step" .. i,
			Vector3.new(STAIR_WIDTH, STAIR_HEIGHT, STAIR_DEPTH),
			CFrame.new(POSITION.X, y + STAIR_HEIGHT / 2, z - STAIR_DEPTH / 2),
			COLORS.STONE)
	end

	-- Side walls for stairs
	local totalDepth: number = STAIR_COUNT * STAIR_DEPTH
	local totalHeight: number = STAIR_COUNT * STAIR_HEIGHT

	-- Left wall (descending with stairs)
	for i = 0, STAIR_COUNT - 1 do
		local wallHeight: number = (STAIR_COUNT - i) * STAIR_HEIGHT + 2
		local y: number = wallHeight / 2
		local z: number = POSITION.Z - (i * STAIR_DEPTH) - STAIR_DEPTH / 2

		createPart(stairs, "WallLeft" .. i,
			Vector3.new(1, wallHeight, STAIR_DEPTH),
			CFrame.new(POSITION.X - STAIR_WIDTH / 2 - 0.5, y, z),
			COLORS.STONE_DARK)
	end

	-- Right wall (descending with stairs)
	for i = 0, STAIR_COUNT - 1 do
		local wallHeight: number = (STAIR_COUNT - i) * STAIR_HEIGHT + 2
		local y: number = wallHeight / 2
		local z: number = POSITION.Z - (i * STAIR_DEPTH) - STAIR_DEPTH / 2

		createPart(stairs, "WallRight" .. i,
			Vector3.new(1, wallHeight, STAIR_DEPTH),
			CFrame.new(POSITION.X + STAIR_WIDTH / 2 + 0.5, y, z),
			COLORS.STONE_DARK)
	end

	stairs.Parent = Workspace

	print("[MoatStairs] Stairs complete!")
	return stairs
end

-- Build the stairs
buildStairs()
