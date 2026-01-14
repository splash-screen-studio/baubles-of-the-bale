--[[
	Moat.server.luau

	Creates a raised above-ground moat in a quadrilateral shape
	with terrain water for swimming.
]]

local Workspace = game:GetService("Workspace")

-- Moat corner positions (outer boundary)
local OUTER_CORNERS: {Vector3} = {
	Vector3.new(152, 0, -52),
	Vector3.new(212, 0, -57),
	Vector3.new(141, 0, -195),
	Vector3.new(-41, 0, -223),
}

-- Moat dimensions
local MOAT_WIDTH: number = 16
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
	Calculate centroid of corners
]]
local function getCentroid(corners: {Vector3}): Vector3
	local sum: Vector3 = Vector3.new(0, 0, 0)
	for _, corner in corners do
		sum = sum + corner
	end
	return sum / #corners
end

--[[
	Scale corners toward centroid to create inner boundary
]]
local function getInnerCorners(outerCorners: {Vector3}, inset: number): {Vector3}
	local centroid: Vector3 = getCentroid(outerCorners)
	local innerCorners: {Vector3} = {}

	for _, corner in outerCorners do
		local direction: Vector3 = (centroid - corner).Unit
		local innerCorner: Vector3 = corner + direction * inset
		table.insert(innerCorners, innerCorner)
	end

	return innerCorners
end

--[[
	Creates a wall segment between two points
]]
local function createWallSegment(parent: Instance, name: string, p1: Vector3, p2: Vector3, height: number, thickness: number, color: Color3, yOffset: number): Part
	local midpoint: Vector3 = (p1 + p2) / 2
	local direction: Vector3 = p2 - p1
	local length: number = direction.Magnitude
	local angle: number = math.atan2(direction.X, direction.Z)

	local cframe: CFrame = CFrame.new(midpoint.X, yOffset + height / 2, midpoint.Z) * CFrame.Angles(0, angle, 0)

	return createPart(parent, name, Vector3.new(thickness, height, length), cframe, color)
end

--[[
	Creates rim segment between two points
]]
local function createRimSegment(parent: Instance, name: string, p1: Vector3, p2: Vector3, yOffset: number): Part
	local midpoint: Vector3 = (p1 + p2) / 2
	local direction: Vector3 = p2 - p1
	local length: number = direction.Magnitude
	local angle: number = math.atan2(direction.X, direction.Z)

	local cframe: CFrame = CFrame.new(midpoint.X, yOffset, midpoint.Z) * CFrame.Angles(0, angle, 0)

	return createPart(parent, name, Vector3.new(WALL_THICKNESS + 1, 0.5, length + 2), cframe, COLORS.STONE_RIM, Enum.Material.Limestone)
end

--[[
	Creates floor segment between two points (trapezoid approximation)
]]
local function createFloorSegment(parent: Instance, name: string, outer1: Vector3, outer2: Vector3, inner1: Vector3, inner2: Vector3): ()
	-- Create floor as a series of small parts along the channel
	local steps: number = math.ceil((outer1 - outer2).Magnitude / 8)

	for i = 0, steps - 1 do
		local t1: number = i / steps
		local t2: number = (i + 1) / steps

		local o1: Vector3 = outer1:Lerp(outer2, t1)
		local o2: Vector3 = outer1:Lerp(outer2, t2)
		local i1: Vector3 = inner1:Lerp(inner2, t1)
		local i2: Vector3 = inner1:Lerp(inner2, t2)

		local center: Vector3 = (o1 + o2 + i1 + i2) / 4
		local width: number = ((o1 - i1).Magnitude + (o2 - i2).Magnitude) / 2
		local length: number = ((o1 - o2).Magnitude + (i1 - i2).Magnitude) / 2

		local direction: Vector3 = o2 - o1
		local angle: number = math.atan2(direction.X, direction.Z)

		local cframe: CFrame = CFrame.new(center.X, WALL_THICKNESS / 2, center.Z) * CFrame.Angles(0, angle, 0)
		createPart(parent, name .. "_" .. i, Vector3.new(width, WALL_THICKNESS, length + 1), cframe, COLORS.STONE_DARK, Enum.Material.Slate)
	end
end

--[[
	Fill water in channel segment
]]
local function fillWaterSegment(terrain: Terrain, outer1: Vector3, outer2: Vector3, inner1: Vector3, inner2: Vector3): ()
	local steps: number = math.ceil((outer1 - outer2).Magnitude / 8)
	local waterTop: number = WALL_HEIGHT - 1
	local waterBottom: number = WALL_THICKNESS
	local waterHeight: number = waterTop - waterBottom

	for i = 0, steps - 1 do
		local t1: number = i / steps
		local t2: number = (i + 1) / steps

		local o1: Vector3 = outer1:Lerp(outer2, t1)
		local o2: Vector3 = outer1:Lerp(outer2, t2)
		local i1: Vector3 = inner1:Lerp(inner2, t1)
		local i2: Vector3 = inner1:Lerp(inner2, t2)

		local center: Vector3 = (o1 + o2 + i1 + i2) / 4
		local width: number = ((o1 - i1).Magnitude + (o2 - i2).Magnitude) / 2
		local length: number = ((o1 - o2).Magnitude + (i1 - i2).Magnitude) / 2

		local direction: Vector3 = o2 - o1
		local angle: number = math.atan2(direction.X, direction.Z)

		local cframe: CFrame = CFrame.new(center.X, waterBottom + waterHeight / 2, center.Z) * CFrame.Angles(0, angle, 0)
		terrain:FillBlock(cframe, Vector3.new(width - 2, waterHeight, length + 1), Enum.Material.Water)
	end
end

--[[
	Builds the moat
]]
local function buildMoat(): Model
	print("[Moat] Building raised moat...")

	local moat: Model = Instance.new("Model")
	moat.Name = "Moat"

	local terrain: Terrain = Workspace.Terrain

	-- Calculate inner corners
	local innerCorners: {Vector3} = getInnerCorners(OUTER_CORNERS, MOAT_WIDTH)

	-- Build walls, floor, and water for each side
	for i = 1, #OUTER_CORNERS do
		local nextI: number = (i % #OUTER_CORNERS) + 1

		local outer1: Vector3 = OUTER_CORNERS[i]
		local outer2: Vector3 = OUTER_CORNERS[nextI]
		local inner1: Vector3 = innerCorners[i]
		local inner2: Vector3 = innerCorners[nextI]

		-- Outer wall
		createWallSegment(moat, "OuterWall" .. i, outer1, outer2, WALL_HEIGHT, WALL_THICKNESS, COLORS.STONE, 0)

		-- Inner wall
		createWallSegment(moat, "InnerWall" .. i, inner1, inner2, WALL_HEIGHT, WALL_THICKNESS, COLORS.STONE, 0)

		-- Outer rim
		createRimSegment(moat, "OuterRim" .. i, outer1, outer2, WALL_HEIGHT + 0.25)

		-- Inner rim
		createRimSegment(moat, "InnerRim" .. i, inner1, inner2, WALL_HEIGHT + 0.25)

		-- Floor
		createFloorSegment(moat, "Floor" .. i, outer1, outer2, inner1, inner2)

		-- Water
		fillWaterSegment(terrain, outer1, outer2, inner1, inner2)
	end

	-- Corner posts (decorative)
	for i, corner in OUTER_CORNERS do
		createPart(moat, "CornerPost" .. i,
			Vector3.new(3, WALL_HEIGHT + 2, 3),
			CFrame.new(corner.X, (WALL_HEIGHT + 2) / 2, corner.Z),
			COLORS.STONE_DARK)

		-- Cap on corner post
		createPart(moat, "CornerCap" .. i,
			Vector3.new(4, 1, 4),
			CFrame.new(corner.X, WALL_HEIGHT + 2.5, corner.Z),
			COLORS.STONE_RIM, Enum.Material.Limestone)
	end

	moat.Parent = Workspace

	print("[Moat] Moat complete with terrain water!")
	return moat
end

-- Build the moat
buildMoat()
