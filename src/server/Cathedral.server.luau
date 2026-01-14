--[[
	Cathedral.server.luau

	Generates a medieval cathedral at the specified position.
]]

local Workspace = game:GetService("Workspace")

-- Cathedral configuration
local POSITION: Vector3 = Vector3.new(-83, 0, -84)
local FACING_ANGLE: number = math.rad(45) -- Face toward village center

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(180, 175, 165),
	STONE_DARK = Color3.fromRGB(140, 135, 125),
	STONE_ACCENT = Color3.fromRGB(160, 155, 145),
	ROOF = Color3.fromRGB(70, 65, 60),
	WOOD_DARK = Color3.fromRGB(60, 45, 30),
	WINDOW = Color3.fromRGB(60, 80, 120),
	WINDOW_FRAME = Color3.fromRGB(50, 50, 55),
	GOLD = Color3.fromRGB(200, 170, 80),
	TORCH_HANDLE = Color3.fromRGB(79, 52, 26),
	TORCH_HEAD = Color3.fromRGB(54, 54, 54),
	TORCH_LIGHT = Color3.fromRGB(255, 147, 41),
}

-- Dimensions
local NAVE_LENGTH: number = 80
local NAVE_WIDTH: number = 30
local NAVE_HEIGHT: number = 35
local WALL_THICKNESS: number = 4

local TRANSEPT_LENGTH: number = 50
local TRANSEPT_WIDTH: number = 20

local TOWER_SIZE: number = 18
local TOWER_HEIGHT: number = 60
local SPIRE_HEIGHT: number = 30

local APSE_RADIUS: number = 15
local APSE_SEGMENTS: number = 5

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
	Creates a wall-mounted torch with fire and light
]]
local function createTorch(parent: Instance, cframe: CFrame): Model
	local torchModel: Model = Instance.new("Model")
	torchModel.Name = "Torch"

	-- Wall bracket
	local bracket: Part = Instance.new("Part")
	bracket.Name = "Bracket"
	bracket.Size = Vector3.new(0.5, 0.5, 2)
	bracket.CFrame = cframe * CFrame.new(0, 0, -1)
	bracket.Anchored = true
	bracket.Color = Color3.fromRGB(50, 50, 50)
	bracket.Material = Enum.Material.Metal
	bracket.Parent = torchModel

	-- Torch handle
	local handle: Part = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.6, 3, 0.6)
	handle.CFrame = cframe * CFrame.new(0, 1.5, -2)
	handle.Anchored = true
	handle.Color = COLORS.TORCH_HANDLE
	handle.Material = Enum.Material.Wood
	handle.Parent = torchModel

	-- Torch head
	local head: Part = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(0.8, 0.6, 0.8)
	head.CFrame = cframe * CFrame.new(0, 3.3, -2)
	head.Anchored = true
	head.Color = COLORS.TORCH_HEAD
	head.Material = Enum.Material.Slate
	head.Parent = torchModel

	-- Fire effect
	local fire: Fire = Instance.new("Fire")
	fire.Heat = 9
	fire.Size = 5
	fire.Color = Color3.fromRGB(255, 119, 0)
	fire.SecondaryColor = Color3.fromRGB(255, 200, 50)
	fire.Parent = head

	-- Point light
	local light: PointLight = Instance.new("PointLight")
	light.Color = COLORS.TORCH_LIGHT
	light.Brightness = 2
	light.Range = 25
	light.Shadows = true
	light.Parent = head

	torchModel.Parent = parent
	return torchModel
end

--[[
	Places torches around the cathedral
]]
local function createTorches(parent: Instance, baseCFrame: CFrame): ()
	-- Torches along nave walls (between buttresses)
	local windowCount: number = 6
	local windowSpacing: number = NAVE_LENGTH / (windowCount + 1)

	for i = 1, windowCount do
		local zPos: number = -windowSpacing * i

		-- Left wall torches (facing outward)
		createTorch(parent, baseCFrame * CFrame.new(-NAVE_WIDTH/2 - 3, 8, zPos) * CFrame.Angles(0, math.rad(-90), 0))

		-- Right wall torches (facing outward)
		createTorch(parent, baseCFrame * CFrame.new(NAVE_WIDTH/2 + 3, 8, zPos) * CFrame.Angles(0, math.rad(90), 0))
	end

	-- Entrance torches (flanking the doors)
	createTorch(parent, baseCFrame * CFrame.new(-8, 10, 4) * CFrame.Angles(0, math.rad(180), 0))
	createTorch(parent, baseCFrame * CFrame.new(8, 10, 4) * CFrame.Angles(0, math.rad(180), 0))

	-- Torches at bottom of steps
	createTorch(parent, baseCFrame * CFrame.new(-12, 4, 14) * CFrame.Angles(0, math.rad(180), 0))
	createTorch(parent, baseCFrame * CFrame.new(12, 4, 14) * CFrame.Angles(0, math.rad(180), 0))

	-- Transept end torches
	local transeptZ: number = -NAVE_LENGTH * 0.7

	-- Left transept
	createTorch(parent, baseCFrame * CFrame.new(-NAVE_WIDTH/2 - TRANSEPT_LENGTH/2 + 2, 10, transeptZ - 8) * CFrame.Angles(0, math.rad(-90), 0))
	createTorch(parent, baseCFrame * CFrame.new(-NAVE_WIDTH/2 - TRANSEPT_LENGTH/2 + 2, 10, transeptZ + 8) * CFrame.Angles(0, math.rad(-90), 0))

	-- Right transept
	createTorch(parent, baseCFrame * CFrame.new(NAVE_WIDTH/2 + TRANSEPT_LENGTH/2 - 2, 10, transeptZ - 8) * CFrame.Angles(0, math.rad(90), 0))
	createTorch(parent, baseCFrame * CFrame.new(NAVE_WIDTH/2 + TRANSEPT_LENGTH/2 - 2, 10, transeptZ + 8) * CFrame.Angles(0, math.rad(90), 0))

	-- Apse torches (around the back)
	local apseZ: number = -NAVE_LENGTH - APSE_RADIUS/2
	for i = 1, 4 do
		local angle: number = math.pi * (i / 5) - math.pi/2
		local x: number = math.cos(angle) * (APSE_RADIUS + 3)
		local z: number = math.sin(angle) * (APSE_RADIUS + 3)
		local torchAngle: number = angle + math.pi/2

		createTorch(parent, baseCFrame * CFrame.new(x, 8, apseZ + z) * CFrame.Angles(0, torchAngle, 0))
	end

	-- Tower corner torches
	createTorch(parent, baseCFrame * CFrame.new(-TOWER_SIZE/2 - 2, 12, 2 + TOWER_SIZE/2 + 2) * CFrame.Angles(0, math.rad(180), 0))
	createTorch(parent, baseCFrame * CFrame.new(TOWER_SIZE/2 + 2, 12, 2 + TOWER_SIZE/2 + 2) * CFrame.Angles(0, math.rad(180), 0))
end

--[[
	Creates the main nave (central hall)
]]
local function createNave(parent: Instance, baseCFrame: CFrame): ()
	-- Floor
	createPart(parent, "NaveFloor",
		Vector3.new(NAVE_WIDTH, 2, NAVE_LENGTH),
		baseCFrame * CFrame.new(0, 1, -NAVE_LENGTH/2),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Left wall
	createPart(parent, "NaveWallLeft",
		Vector3.new(WALL_THICKNESS, NAVE_HEIGHT, NAVE_LENGTH),
		baseCFrame * CFrame.new(-NAVE_WIDTH/2 + WALL_THICKNESS/2, NAVE_HEIGHT/2, -NAVE_LENGTH/2),
		COLORS.STONE)

	-- Right wall
	createPart(parent, "NaveWallRight",
		Vector3.new(WALL_THICKNESS, NAVE_HEIGHT, NAVE_LENGTH),
		baseCFrame * CFrame.new(NAVE_WIDTH/2 - WALL_THICKNESS/2, NAVE_HEIGHT/2, -NAVE_LENGTH/2),
		COLORS.STONE)

	-- Back wall (behind altar)
	createPart(parent, "NaveWallBack",
		Vector3.new(NAVE_WIDTH, NAVE_HEIGHT, WALL_THICKNESS),
		baseCFrame * CFrame.new(0, NAVE_HEIGHT/2, -NAVE_LENGTH + WALL_THICKNESS/2),
		COLORS.STONE)

	-- Roof (peaked)
	local roofAngle: number = math.rad(25)
	local roofWidth: number = (NAVE_WIDTH / 2) / math.cos(roofAngle)

	createPart(parent, "NaveRoofLeft",
		Vector3.new(roofWidth, 2, NAVE_LENGTH),
		baseCFrame * CFrame.new(-NAVE_WIDTH/4, NAVE_HEIGHT + 4, -NAVE_LENGTH/2) * CFrame.Angles(0, 0, roofAngle),
		COLORS.ROOF, Enum.Material.Slate)

	createPart(parent, "NaveRoofRight",
		Vector3.new(roofWidth, 2, NAVE_LENGTH),
		baseCFrame * CFrame.new(NAVE_WIDTH/4, NAVE_HEIGHT + 4, -NAVE_LENGTH/2) * CFrame.Angles(0, 0, -roofAngle),
		COLORS.ROOF, Enum.Material.Slate)

	-- Windows along nave (both sides)
	local windowCount: number = 6
	local windowSpacing: number = NAVE_LENGTH / (windowCount + 1)

	for i = 1, windowCount do
		local zPos: number = -windowSpacing * i

		-- Left windows (sticking out 1 stud outside wall)
		createPart(parent, "WindowLeft" .. i,
			Vector3.new(3, 12, 4),
			baseCFrame * CFrame.new(-NAVE_WIDTH/2 - 0.5, NAVE_HEIGHT/2 + 5, zPos),
			COLORS.WINDOW, Enum.Material.Neon)

		-- Right windows (sticking out 1 stud outside wall)
		createPart(parent, "WindowRight" .. i,
			Vector3.new(3, 12, 4),
			baseCFrame * CFrame.new(NAVE_WIDTH/2 + 0.5, NAVE_HEIGHT/2 + 5, zPos),
			COLORS.WINDOW, Enum.Material.Neon)
	end

	-- Buttresses along nave
	for i = 1, windowCount + 1 do
		local zPos: number = -windowSpacing * (i - 0.5)

		-- Left buttresses
		createPart(parent, "ButtressLeft" .. i,
			Vector3.new(3, NAVE_HEIGHT * 0.8, 5),
			baseCFrame * CFrame.new(-NAVE_WIDTH/2 - 1, NAVE_HEIGHT * 0.4, zPos),
			COLORS.STONE_ACCENT)

		-- Right buttresses
		createPart(parent, "ButtressRight" .. i,
			Vector3.new(3, NAVE_HEIGHT * 0.8, 5),
			baseCFrame * CFrame.new(NAVE_WIDTH/2 + 1, NAVE_HEIGHT * 0.4, zPos),
			COLORS.STONE_ACCENT)
	end
end

--[[
	Creates the transept (crossing arms)
]]
local function createTransept(parent: Instance, baseCFrame: CFrame): ()
	local transeptZ: number = -NAVE_LENGTH * 0.7

	-- Left arm
	createPart(parent, "TranseptLeft",
		Vector3.new(TRANSEPT_LENGTH/2, NAVE_HEIGHT - 5, TRANSEPT_WIDTH),
		baseCFrame * CFrame.new(-NAVE_WIDTH/2 - TRANSEPT_LENGTH/4, (NAVE_HEIGHT - 5)/2, transeptZ),
		COLORS.STONE)

	-- Right arm
	createPart(parent, "TranseptRight",
		Vector3.new(TRANSEPT_LENGTH/2, NAVE_HEIGHT - 5, TRANSEPT_WIDTH),
		baseCFrame * CFrame.new(NAVE_WIDTH/2 + TRANSEPT_LENGTH/4, (NAVE_HEIGHT - 5)/2, transeptZ),
		COLORS.STONE)

	-- Transept roofs
	createPart(parent, "TranseptRoofLeft",
		Vector3.new(TRANSEPT_LENGTH/2, 2, TRANSEPT_WIDTH + 4),
		baseCFrame * CFrame.new(-NAVE_WIDTH/2 - TRANSEPT_LENGTH/4, NAVE_HEIGHT - 3, transeptZ),
		COLORS.ROOF, Enum.Material.Slate)

	createPart(parent, "TranseptRoofRight",
		Vector3.new(TRANSEPT_LENGTH/2, 2, TRANSEPT_WIDTH + 4),
		baseCFrame * CFrame.new(NAVE_WIDTH/2 + TRANSEPT_LENGTH/4, NAVE_HEIGHT - 3, transeptZ),
		COLORS.ROOF, Enum.Material.Slate)

	-- Rose windows on transept ends
	createPart(parent, "RoseWindowLeft",
		Vector3.new(2, 10, 10),
		baseCFrame * CFrame.new(-NAVE_WIDTH/2 - TRANSEPT_LENGTH/2 + 1, NAVE_HEIGHT/2, transeptZ),
		COLORS.WINDOW, Enum.Material.Neon)

	createPart(parent, "RoseWindowRight",
		Vector3.new(2, 10, 10),
		baseCFrame * CFrame.new(NAVE_WIDTH/2 + TRANSEPT_LENGTH/2 - 1, NAVE_HEIGHT/2, transeptZ),
		COLORS.WINDOW, Enum.Material.Neon)
end

--[[
	Creates the bell tower
]]
local function createTower(parent: Instance, baseCFrame: CFrame): ()
	-- Main tower body
	createPart(parent, "TowerBase",
		Vector3.new(TOWER_SIZE, TOWER_HEIGHT, TOWER_SIZE),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT/2, 2),
		COLORS.STONE)

	-- Tower windows (belfry level)
	local belfryHeight: number = TOWER_HEIGHT - 10
	for i = 0, 3 do
		local angle: number = math.rad(i * 90)
		local offsetX: number = math.sin(angle) * (TOWER_SIZE/2)
		local offsetZ: number = math.cos(angle) * (TOWER_SIZE/2)

		createPart(parent, "BelfryWindow" .. i,
			Vector3.new(4, 8, 2),
			baseCFrame * CFrame.new(offsetX, belfryHeight, 2 + offsetZ) * CFrame.Angles(0, angle, 0),
			COLORS.WINDOW_FRAME, Enum.Material.Metal)
	end

	-- Spire
	local spireBase: Part = createPart(parent, "SpireBase",
		Vector3.new(TOWER_SIZE + 2, 3, TOWER_SIZE + 2),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT + 1.5, 2),
		COLORS.STONE_ACCENT)

	-- Spire pyramid (using wedges approximated with parts)
	for i = 0, 3 do
		local angle: number = math.rad(i * 90 + 45)
		local spireWidth: number = TOWER_SIZE * 0.7

		local wedge: WedgePart = Instance.new("WedgePart")
		wedge.Name = "SpireWedge" .. i
		wedge.Size = Vector3.new(spireWidth, SPIRE_HEIGHT, spireWidth/2)
		wedge.CFrame = baseCFrame * CFrame.new(0, TOWER_HEIGHT + 3 + SPIRE_HEIGHT/2, 2) * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, -spireWidth/4)
		wedge.Anchored = true
		wedge.Color = COLORS.ROOF
		wedge.Material = Enum.Material.Slate
		wedge.Parent = parent
	end

	-- Cross at top
	createPart(parent, "CrossVertical",
		Vector3.new(1, 8, 1),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT + SPIRE_HEIGHT + 7, 2),
		COLORS.GOLD, Enum.Material.Metal)

	createPart(parent, "CrossHorizontal",
		Vector3.new(5, 1, 1),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT + SPIRE_HEIGHT + 9, 2),
		COLORS.GOLD, Enum.Material.Metal)
end

--[[
	Creates the entrance facade
]]
local function createEntrance(parent: Instance, baseCFrame: CFrame): ()
	-- Front wall with entrance
	createPart(parent, "FrontWallLeft",
		Vector3.new(NAVE_WIDTH/2 - 6, NAVE_HEIGHT, WALL_THICKNESS),
		baseCFrame * CFrame.new(-NAVE_WIDTH/4 - 3, NAVE_HEIGHT/2, 0),
		COLORS.STONE)

	createPart(parent, "FrontWallRight",
		Vector3.new(NAVE_WIDTH/2 - 6, NAVE_HEIGHT, WALL_THICKNESS),
		baseCFrame * CFrame.new(NAVE_WIDTH/4 + 3, NAVE_HEIGHT/2, 0),
		COLORS.STONE)

	-- Above door
	createPart(parent, "FrontWallTop",
		Vector3.new(12, NAVE_HEIGHT - 18, WALL_THICKNESS),
		baseCFrame * CFrame.new(0, NAVE_HEIGHT - (NAVE_HEIGHT - 18)/2, 0),
		COLORS.STONE)

	-- Door frame
	createPart(parent, "DoorFrameLeft",
		Vector3.new(2, 18, WALL_THICKNESS + 2),
		baseCFrame * CFrame.new(-5, 9, 0),
		COLORS.STONE_DARK)

	createPart(parent, "DoorFrameRight",
		Vector3.new(2, 18, WALL_THICKNESS + 2),
		baseCFrame * CFrame.new(5, 9, 0),
		COLORS.STONE_DARK)

	-- Doors
	createPart(parent, "DoorLeft",
		Vector3.new(4, 16, 1),
		baseCFrame * CFrame.new(-2.5, 8, WALL_THICKNESS/2 + 0.5),
		COLORS.WOOD_DARK, Enum.Material.Wood)

	createPart(parent, "DoorRight",
		Vector3.new(4, 16, 1),
		baseCFrame * CFrame.new(2.5, 8, WALL_THICKNESS/2 + 0.5),
		COLORS.WOOD_DARK, Enum.Material.Wood)

	-- Arch above door
	createPart(parent, "DoorArch",
		Vector3.new(14, 3, WALL_THICKNESS + 2),
		baseCFrame * CFrame.new(0, 18, 0),
		COLORS.STONE_ACCENT)

	-- Rose window above entrance
	createPart(parent, "MainRoseWindow",
		Vector3.new(2, 12, 12),
		baseCFrame * CFrame.new(0, NAVE_HEIGHT - 8, WALL_THICKNESS/2),
		COLORS.WINDOW, Enum.Material.Neon)

	-- Steps
	for i = 1, 4 do
		createPart(parent, "Step" .. i,
			Vector3.new(16 + i * 2, 1, 3),
			baseCFrame * CFrame.new(0, -i + 0.5, WALL_THICKNESS/2 + 2 + (i - 1) * 3),
			COLORS.STONE_DARK, Enum.Material.Cobblestone)
	end
end

--[[
	Creates the apse (rounded back end)
]]
local function createApse(parent: Instance, baseCFrame: CFrame): ()
	local apseZ: number = -NAVE_LENGTH - APSE_RADIUS/2

	-- Apse walls (segmented curve)
	for i = 0, APSE_SEGMENTS do
		local angle: number = math.pi * (i / APSE_SEGMENTS) - math.pi/2
		local x: number = math.cos(angle) * APSE_RADIUS
		local z: number = math.sin(angle) * APSE_RADIUS

		local segmentAngle: number = angle + math.pi/2

		createPart(parent, "ApseSegment" .. i,
			Vector3.new(WALL_THICKNESS, NAVE_HEIGHT - 10, APSE_RADIUS * math.pi / APSE_SEGMENTS),
			baseCFrame * CFrame.new(x, (NAVE_HEIGHT - 10)/2, apseZ + z) * CFrame.Angles(0, segmentAngle, 0),
			COLORS.STONE)
	end

	-- Apse roof (conical approximation)
	createPart(parent, "ApseRoof",
		Vector3.new(APSE_RADIUS * 2 + 4, 3, APSE_RADIUS * 2 + 4),
		baseCFrame * CFrame.new(0, NAVE_HEIGHT - 8, apseZ),
		COLORS.ROOF, Enum.Material.Slate)
end

--[[
	Main function to build the cathedral
]]
local function buildCathedral(): Model
	print("[Cathedral] Building cathedral at", POSITION)

	local cathedral: Model = Instance.new("Model")
	cathedral.Name = "Cathedral"

	-- Create base CFrame facing toward center
	local baseCFrame: CFrame = CFrame.new(POSITION) * CFrame.Angles(0, FACING_ANGLE, 0)

	-- Build all components
	createNave(cathedral, baseCFrame)
	createTransept(cathedral, baseCFrame)
	createTower(cathedral, baseCFrame)
	createEntrance(cathedral, baseCFrame)
	createApse(cathedral, baseCFrame)
	createTorches(cathedral, baseCFrame)

	cathedral.Parent = Workspace

	print("[Cathedral] Cathedral complete!")
	return cathedral
end

-- Build the cathedral
buildCathedral()
