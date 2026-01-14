--[[
	Well.server.luau

	Creates a medieval stone well at the village center.
]]

local Workspace = game:GetService("Workspace")

-- Well configuration
local POSITION: Vector3 = Vector3.new(0, 0, 0)

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(140, 135, 125),
	STONE_DARK = Color3.fromRGB(100, 95, 85),
	WOOD = Color3.fromRGB(101, 67, 33),
	WOOD_DARK = Color3.fromRGB(70, 50, 30),
	ROPE = Color3.fromRGB(139, 119, 80),
	WATER = Color3.fromRGB(40, 70, 100),
	IRON = Color3.fromRGB(55, 55, 60),
}

-- Dimensions
local WELL_RADIUS: number = 5
local WELL_HEIGHT: number = 4
local WELL_DEPTH: number = 8
local ROOF_HEIGHT: number = 8

--[[
	Creates a part with common properties
]]
local function createPart(parent: Instance, name: string, size: Vector3, cframe: CFrame, color: Color3, material: Enum.Material?): Part
	local part: Part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.Color = color
	part.Material = material or Enum.Material.Limestone
	part.Parent = parent
	return part
end

--[[
	Creates a cylinder part
]]
local function createCylinder(parent: Instance, name: string, height: number, radius: number, cframe: CFrame, color: Color3, material: Enum.Material?): Part
	local part: Part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(height, radius * 2, radius * 2)
	part.CFrame = cframe * CFrame.Angles(0, 0, math.rad(90))
	part.Anchored = true
	part.Color = color
	part.Material = material or Enum.Material.Limestone
	part.Parent = parent
	return part
end

--[[
	Builds the well
]]
local function buildWell(): Model
	print("[Well] Building well at", POSITION)

	local well: Model = Instance.new("Model")
	well.Name = "Well"

	local baseCFrame: CFrame = CFrame.new(POSITION)

	-- Stone well base (cylindrical wall)
	createCylinder(well, "WellWall",
		WELL_HEIGHT, WELL_RADIUS,
		baseCFrame * CFrame.new(0, WELL_HEIGHT / 2, 0),
		COLORS.STONE, Enum.Material.Cobblestone)

	-- Inner well shaft (hollow, going down)
	createCylinder(well, "WellShaft",
		WELL_DEPTH, WELL_RADIUS - 1,
		baseCFrame * CFrame.new(0, -WELL_DEPTH / 2 + 1, 0),
		COLORS.STONE_DARK, Enum.Material.Slate)

	-- Water at bottom
	createCylinder(well, "WellWater",
		2, WELL_RADIUS - 1.5,
		baseCFrame * CFrame.new(0, -WELL_DEPTH + 2, 0),
		COLORS.WATER, Enum.Material.Water)

	-- Stone rim at top
	createCylinder(well, "WellRim",
		1, WELL_RADIUS + 0.5,
		baseCFrame * CFrame.new(0, WELL_HEIGHT + 0.5, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Wooden support posts
	local postHeight: number = ROOF_HEIGHT
	local postOffset: number = WELL_RADIUS + 1

	createPart(well, "PostLeft",
		Vector3.new(1.5, postHeight, 1.5),
		baseCFrame * CFrame.new(-postOffset, WELL_HEIGHT + postHeight / 2, 0),
		COLORS.WOOD, Enum.Material.Wood)

	createPart(well, "PostRight",
		Vector3.new(1.5, postHeight, 1.5),
		baseCFrame * CFrame.new(postOffset, WELL_HEIGHT + postHeight / 2, 0),
		COLORS.WOOD, Enum.Material.Wood)

	-- Crossbeam
	createPart(well, "Crossbeam",
		Vector3.new(postOffset * 2 + 2, 1.5, 1.5),
		baseCFrame * CFrame.new(0, WELL_HEIGHT + postHeight, 0),
		COLORS.WOOD, Enum.Material.Wood)

	-- Roof (peaked)
	local roofWidth: number = postOffset * 2 + 4
	local roofDepth: number = WELL_RADIUS * 2 + 4
	local roofAngle: number = math.rad(30)

	local roofPart1: WedgePart = Instance.new("WedgePart")
	roofPart1.Name = "RoofLeft"
	roofPart1.Size = Vector3.new(roofDepth, 3, roofWidth / 2 + 1)
	roofPart1.CFrame = baseCFrame * CFrame.new(-roofWidth / 4, WELL_HEIGHT + postHeight + 2, 0) * CFrame.Angles(0, math.rad(-90), 0)
	roofPart1.Anchored = true
	roofPart1.Color = COLORS.WOOD_DARK
	roofPart1.Material = Enum.Material.Wood
	roofPart1.Parent = well

	local roofPart2: WedgePart = Instance.new("WedgePart")
	roofPart2.Name = "RoofRight"
	roofPart2.Size = Vector3.new(roofDepth, 3, roofWidth / 2 + 1)
	roofPart2.CFrame = baseCFrame * CFrame.new(roofWidth / 4, WELL_HEIGHT + postHeight + 2, 0) * CFrame.Angles(0, math.rad(90), 0)
	roofPart2.Anchored = true
	roofPart2.Color = COLORS.WOOD_DARK
	roofPart2.Material = Enum.Material.Wood
	roofPart2.Parent = well

	-- Winch/crank mechanism
	createCylinder(well, "Winch",
		postOffset * 2 - 2, 0.8,
		baseCFrame * CFrame.new(0, WELL_HEIGHT + postHeight - 2, 0),
		COLORS.WOOD, Enum.Material.Wood)

	-- Crank handle
	createPart(well, "CrankArm",
		Vector3.new(0.4, 2, 0.4),
		baseCFrame * CFrame.new(postOffset - 0.5, WELL_HEIGHT + postHeight - 2, 0),
		COLORS.IRON, Enum.Material.Metal)

	createPart(well, "CrankHandle",
		Vector3.new(1.5, 0.4, 0.4),
		baseCFrame * CFrame.new(postOffset - 0.5, WELL_HEIGHT + postHeight - 0.5, 0),
		COLORS.IRON, Enum.Material.Metal)

	-- Rope hanging down
	createPart(well, "Rope",
		Vector3.new(0.3, WELL_HEIGHT + 4, 0.3),
		baseCFrame * CFrame.new(0, WELL_HEIGHT / 2 + 2, 0),
		COLORS.ROPE, Enum.Material.Fabric)

	-- Bucket
	createPart(well, "Bucket",
		Vector3.new(1.5, 2, 1.5),
		baseCFrame * CFrame.new(0, 1, 0),
		COLORS.WOOD, Enum.Material.Wood)

	well.Parent = Workspace

	print("[Well] Well complete!")
	return well
end

-- Build the well
buildWell()
