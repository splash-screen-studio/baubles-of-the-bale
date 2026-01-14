--[[
	Schoolhouse.server.luau

	Creates a medieval schoolhouse.
]]

local Workspace = game:GetService("Workspace")

-- Configuration
local POSITION: Vector3 = Vector3.new(192, 0, -28)
local FACING_ANGLE: number = math.rad(180) -- Facing toward village

-- Dimensions
local BUILDING_LENGTH: number = 28
local BUILDING_WIDTH: number = 20
local WALL_HEIGHT: number = 14
local ROOF_HEIGHT: number = 10

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(160, 155, 145),
	STONE_DARK = Color3.fromRGB(120, 115, 105),
	WOOD = Color3.fromRGB(101, 78, 50),
	WOOD_DARK = Color3.fromRGB(70, 52, 35),
	WOOD_LIGHT = Color3.fromRGB(140, 115, 80),
	ROOF = Color3.fromRGB(80, 65, 50),
	FLOOR = Color3.fromRGB(90, 70, 50),
	CHALKBOARD = Color3.fromRGB(30, 45, 35),
	WINDOW = Color3.fromRGB(180, 200, 220),
	BELL = Color3.fromRGB(180, 160, 60),
	TORCH_LIGHT = Color3.fromRGB(255, 147, 41),
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
	part.Material = material or Enum.Material.Wood
	part.Parent = parent
	return part
end

--[[
	Creates a torch
]]
local function createTorch(parent: Instance, cframe: CFrame): ()
	local handle: Part = Instance.new("Part")
	handle.Name = "TorchHandle"
	handle.Size = Vector3.new(0.5, 2.5, 0.5)
	handle.CFrame = cframe * CFrame.new(0, 1.25, 0)
	handle.Anchored = true
	handle.Color = Color3.fromRGB(79, 52, 26)
	handle.Material = Enum.Material.Wood
	handle.Parent = parent

	local head: Part = Instance.new("Part")
	head.Name = "TorchHead"
	head.Size = Vector3.new(0.6, 0.5, 0.6)
	head.CFrame = cframe * CFrame.new(0, 2.75, 0)
	head.Anchored = true
	head.Color = Color3.fromRGB(54, 54, 54)
	head.Material = Enum.Material.Slate
	head.Parent = parent

	local fire: Fire = Instance.new("Fire")
	fire.Heat = 8
	fire.Size = 4
	fire.Color = Color3.fromRGB(255, 119, 0)
	fire.SecondaryColor = Color3.fromRGB(255, 200, 50)
	fire.Parent = head

	local light: PointLight = Instance.new("PointLight")
	light.Color = COLORS.TORCH_LIGHT
	light.Brightness = 1.5
	light.Range = 18
	light.Shadows = true
	light.Parent = head
end

--[[
	Creates a desk with bench
]]
local function createDesk(parent: Instance, cframe: CFrame, index: number): ()
	-- Desk top
	createPart(parent, "DeskTop" .. index,
		Vector3.new(5, 0.5, 2.5),
		cframe * CFrame.new(0, 2.75, 0),
		COLORS.WOOD)

	-- Desk legs
	createPart(parent, "DeskLegLeft" .. index,
		Vector3.new(0.4, 2.5, 0.4),
		cframe * CFrame.new(-2, 1.25, 0),
		COLORS.WOOD_DARK)

	createPart(parent, "DeskLegRight" .. index,
		Vector3.new(0.4, 2.5, 0.4),
		cframe * CFrame.new(2, 1.25, 0),
		COLORS.WOOD_DARK)

	-- Bench
	createPart(parent, "Bench" .. index,
		Vector3.new(5, 0.4, 1),
		cframe * CFrame.new(0, 1.7, 2),
		COLORS.WOOD_LIGHT)

	createPart(parent, "BenchLegLeft" .. index,
		Vector3.new(0.3, 1.5, 0.3),
		cframe * CFrame.new(-2, 0.75, 2),
		COLORS.WOOD_DARK)

	createPart(parent, "BenchLegRight" .. index,
		Vector3.new(0.3, 1.5, 0.3),
		cframe * CFrame.new(2, 0.75, 2),
		COLORS.WOOD_DARK)
end

--[[
	Builds the schoolhouse
]]
local function buildSchoolhouse(): Model
	print("[Schoolhouse] Building schoolhouse at", POSITION)

	local school: Model = Instance.new("Model")
	school.Name = "Schoolhouse"

	local baseCFrame: CFrame = CFrame.new(POSITION) * CFrame.Angles(0, FACING_ANGLE, 0)
	local halfLength: number = BUILDING_LENGTH / 2
	local halfWidth: number = BUILDING_WIDTH / 2

	-- Foundation
	createPart(school, "Foundation",
		Vector3.new(BUILDING_LENGTH + 4, 1, BUILDING_WIDTH + 4),
		baseCFrame * CFrame.new(0, 0.5, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Floor
	createPart(school, "Floor",
		Vector3.new(BUILDING_LENGTH, 0.5, BUILDING_WIDTH),
		baseCFrame * CFrame.new(0, 1.25, 0),
		COLORS.FLOOR, Enum.Material.Wood)

	-- Walls
	-- Front wall (with door)
	createPart(school, "WallFrontLeft",
		Vector3.new(halfLength - 3, WALL_HEIGHT, 1.5),
		baseCFrame * CFrame.new(-halfLength / 2 - 1.5, WALL_HEIGHT / 2 + 1, halfWidth - 0.75),
		COLORS.STONE, Enum.Material.Limestone)

	createPart(school, "WallFrontRight",
		Vector3.new(halfLength - 3, WALL_HEIGHT, 1.5),
		baseCFrame * CFrame.new(halfLength / 2 + 1.5, WALL_HEIGHT / 2 + 1, halfWidth - 0.75),
		COLORS.STONE, Enum.Material.Limestone)

	createPart(school, "WallFrontTop",
		Vector3.new(6, WALL_HEIGHT - 10, 1.5),
		baseCFrame * CFrame.new(0, WALL_HEIGHT - 4, halfWidth - 0.75),
		COLORS.STONE, Enum.Material.Limestone)

	-- Back wall
	createPart(school, "WallBack",
		Vector3.new(BUILDING_LENGTH, WALL_HEIGHT, 1.5),
		baseCFrame * CFrame.new(0, WALL_HEIGHT / 2 + 1, -halfWidth + 0.75),
		COLORS.STONE, Enum.Material.Limestone)

	-- Side walls
	createPart(school, "WallLeft",
		Vector3.new(1.5, WALL_HEIGHT, BUILDING_WIDTH - 1.5),
		baseCFrame * CFrame.new(-halfLength + 0.75, WALL_HEIGHT / 2 + 1, 0),
		COLORS.STONE, Enum.Material.Limestone)

	createPart(school, "WallRight",
		Vector3.new(1.5, WALL_HEIGHT, BUILDING_WIDTH - 1.5),
		baseCFrame * CFrame.new(halfLength - 0.75, WALL_HEIGHT / 2 + 1, 0),
		COLORS.STONE, Enum.Material.Limestone)

	-- Door frame
	createPart(school, "DoorFrame",
		Vector3.new(6, 10, 2),
		baseCFrame * CFrame.new(0, 6, halfWidth - 0.5),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Door
	createPart(school, "Door",
		Vector3.new(4, 8, 0.8),
		baseCFrame * CFrame.new(0, 5, halfWidth + 0.5),
		COLORS.WOOD_DARK)

	-- Windows (sides)
	for i = -1, 1, 2 do
		for j = 1, 2 do
			local zOffset: number = (j - 1.5) * 6
			createPart(school, "WindowSide" .. i .. "_" .. j,
				Vector3.new(1.5, 5, 3),
				baseCFrame * CFrame.new(i * (halfLength - 0.75), WALL_HEIGHT / 2 + 3, zOffset),
				COLORS.WINDOW, Enum.Material.Glass)
		end
	end

	-- Windows (back)
	for i = -1, 1, 2 do
		createPart(school, "WindowBack" .. i,
			Vector3.new(3, 5, 1.5),
			baseCFrame * CFrame.new(i * 6, WALL_HEIGHT / 2 + 3, -halfWidth + 0.75),
			COLORS.WINDOW, Enum.Material.Glass)
	end

	-- Roof (peaked)
	local roofPart: WedgePart = Instance.new("WedgePart")
	roofPart.Name = "RoofLeft"
	roofPart.Size = Vector3.new(BUILDING_LENGTH + 3, ROOF_HEIGHT, BUILDING_WIDTH / 2 + 2)
	roofPart.CFrame = baseCFrame * CFrame.new(0, WALL_HEIGHT + ROOF_HEIGHT / 2 + 1, -BUILDING_WIDTH / 4 - 0.5) * CFrame.Angles(0, math.rad(180), 0)
	roofPart.Anchored = true
	roofPart.Color = COLORS.ROOF
	roofPart.Material = Enum.Material.Wood
	roofPart.Parent = school

	local roofPart2: WedgePart = Instance.new("WedgePart")
	roofPart2.Name = "RoofRight"
	roofPart2.Size = Vector3.new(BUILDING_LENGTH + 3, ROOF_HEIGHT, BUILDING_WIDTH / 2 + 2)
	roofPart2.CFrame = baseCFrame * CFrame.new(0, WALL_HEIGHT + ROOF_HEIGHT / 2 + 1, BUILDING_WIDTH / 4 + 0.5)
	roofPart2.Anchored = true
	roofPart2.Color = COLORS.ROOF
	roofPart2.Material = Enum.Material.Wood
	roofPart2.Parent = school

	-- Bell tower
	local towerSize: number = 5
	local towerHeight: number = 8

	createPart(school, "BellTowerBase",
		Vector3.new(towerSize, 2, towerSize),
		baseCFrame * CFrame.new(0, WALL_HEIGHT + ROOF_HEIGHT + 2, 0),
		COLORS.WOOD_DARK)

	-- Bell tower posts
	for i = -1, 1, 2 do
		for j = -1, 1, 2 do
			createPart(school, "BellTowerPost" .. i .. j,
				Vector3.new(0.8, towerHeight, 0.8),
				baseCFrame * CFrame.new(i * (towerSize / 2 - 0.5), WALL_HEIGHT + ROOF_HEIGHT + 3 + towerHeight / 2, j * (towerSize / 2 - 0.5)),
				COLORS.WOOD_DARK)
		end
	end

	-- Bell tower roof
	local bellRoof: Part = Instance.new("Part")
	bellRoof.Name = "BellTowerRoof"
	bellRoof.Shape = Enum.PartType.Block
	bellRoof.Size = Vector3.new(towerSize + 1, 1, towerSize + 1)
	bellRoof.CFrame = baseCFrame * CFrame.new(0, WALL_HEIGHT + ROOF_HEIGHT + 3 + towerHeight + 0.5, 0)
	bellRoof.Anchored = true
	bellRoof.Color = COLORS.ROOF
	bellRoof.Material = Enum.Material.Wood
	bellRoof.Parent = school

	-- Pointed cap on bell tower
	local cap: WedgePart = Instance.new("WedgePart")
	cap.Name = "BellTowerCapFront"
	cap.Size = Vector3.new(towerSize + 1, 4, (towerSize + 1) / 2)
	cap.CFrame = baseCFrame * CFrame.new(0, WALL_HEIGHT + ROOF_HEIGHT + towerHeight + 6, -(towerSize + 1) / 4)
	cap.Anchored = true
	cap.Color = COLORS.ROOF
	cap.Material = Enum.Material.Wood
	cap.Parent = school

	local cap2: WedgePart = Instance.new("WedgePart")
	cap2.Name = "BellTowerCapBack"
	cap2.Size = Vector3.new(towerSize + 1, 4, (towerSize + 1) / 2)
	cap2.CFrame = baseCFrame * CFrame.new(0, WALL_HEIGHT + ROOF_HEIGHT + towerHeight + 6, (towerSize + 1) / 4) * CFrame.Angles(0, math.rad(180), 0)
	cap2.Anchored = true
	cap2.Color = COLORS.ROOF
	cap2.Material = Enum.Material.Wood
	cap2.Parent = school

	-- Bell
	createPart(school, "Bell",
		Vector3.new(2, 2.5, 2),
		baseCFrame * CFrame.new(0, WALL_HEIGHT + ROOF_HEIGHT + 3 + towerHeight / 2, 0),
		COLORS.BELL, Enum.Material.Metal)

	-- Chalkboard on back wall
	createPart(school, "ChalkboardFrame",
		Vector3.new(12, 7, 0.5),
		baseCFrame * CFrame.new(0, WALL_HEIGHT / 2 + 3, -halfWidth + 2),
		COLORS.WOOD_DARK)

	createPart(school, "Chalkboard",
		Vector3.new(11, 6, 0.3),
		baseCFrame * CFrame.new(0, WALL_HEIGHT / 2 + 3, -halfWidth + 2.2),
		COLORS.CHALKBOARD, Enum.Material.SmoothPlastic)

	-- Teacher's desk
	createPart(school, "TeacherDesk",
		Vector3.new(6, 3, 3),
		baseCFrame * CFrame.new(0, 2.5, -halfWidth + 6),
		COLORS.WOOD)

	-- Student desks (3 rows of 2)
	local deskIndex: number = 1
	for row = 1, 3 do
		for col = -1, 1, 2 do
			local deskCFrame: CFrame = baseCFrame * CFrame.new(col * 5, 1, -halfWidth + 6 + row * 4)
			createDesk(school, deskCFrame, deskIndex)
			deskIndex = deskIndex + 1
		end
	end

	-- Book shelf
	createPart(school, "BookShelf",
		Vector3.new(1.5, 6, 8),
		baseCFrame * CFrame.new(-halfLength + 2.5, 4, -3),
		COLORS.WOOD_DARK)

	-- Books on shelf
	for i = 1, 4 do
		createPart(school, "Books" .. i,
			Vector3.new(1.2, 1 + math.random() * 0.5, 0.8),
			baseCFrame * CFrame.new(-halfLength + 2.5, 2 + i * 1.3, -5 + i * 1.2),
			Color3.fromRGB(math.random(80, 150), math.random(50, 100), math.random(40, 80)), Enum.Material.SmoothPlastic)
	end

	-- Interior torches
	createTorch(school, baseCFrame * CFrame.new(-halfLength + 2, 1, halfWidth - 3))
	createTorch(school, baseCFrame * CFrame.new(halfLength - 2, 1, halfWidth - 3))
	createTorch(school, baseCFrame * CFrame.new(-halfLength + 2, 1, -halfWidth + 3))
	createTorch(school, baseCFrame * CFrame.new(halfLength - 2, 1, -halfWidth + 3))

	-- Exterior torches
	createTorch(school, baseCFrame * CFrame.new(-4, 1, halfWidth + 2))
	createTorch(school, baseCFrame * CFrame.new(4, 1, halfWidth + 2))

	school.Parent = Workspace

	print("[Schoolhouse] Schoolhouse complete!")
	return school
end

-- Build the schoolhouse
buildSchoolhouse()
