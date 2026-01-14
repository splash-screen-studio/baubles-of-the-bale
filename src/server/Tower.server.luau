--[[
	Tower.server.luau

	Creates a massively tall tower with external spiral staircase.
]]

local Workspace = game:GetService("Workspace")

-- Tower configuration
local POSITION: Vector3 = Vector3.new(131, 0, -97)

-- Dimensions
local TOWER_RADIUS: number = 12
local TOWER_HEIGHT: number = 150
local WALL_THICKNESS: number = 3

-- Staircase
local STAIR_WIDTH: number = 5
local STAIR_DEPTH: number = 4
local STAIR_HEIGHT: number = 2
local STAIRS_PER_ROTATION: number = 16
local STAIR_RADIUS: number = TOWER_RADIUS + STAIR_WIDTH / 2 + 1

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(160, 155, 145),
	STONE_DARK = Color3.fromRGB(120, 115, 105),
	STONE_LIGHT = Color3.fromRGB(180, 175, 165),
	ROOF = Color3.fromRGB(65, 60, 55),
	WOOD = Color3.fromRGB(90, 70, 50),
	IRON = Color3.fromRGB(60, 60, 65),
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
	part.Material = material or Enum.Material.Limestone
	part.Parent = parent
	return part
end

--[[
	Creates a cylinder
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
	Creates a torch
]]
local function createTorch(parent: Instance, cframe: CFrame): ()
	local head: Part = Instance.new("Part")
	head.Name = "TorchHead"
	head.Size = Vector3.new(0.6, 0.5, 0.6)
	head.CFrame = cframe
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
	light.Range = 25
	light.Shadows = true
	light.Parent = head
end

--[[
	Builds the tower
]]
local function buildTower(): Model
	print("[Tower] Building massive tower at", POSITION)

	local tower: Model = Instance.new("Model")
	tower.Name = "Tower"

	local baseCFrame: CFrame = CFrame.new(POSITION)

	-- === MAIN TOWER BODY ===
	-- Stone cylinder
	createCylinder(tower, "TowerBody",
		TOWER_HEIGHT, TOWER_RADIUS,
		baseCFrame * CFrame.new(0, TOWER_HEIGHT / 2, 0),
		COLORS.STONE, Enum.Material.Limestone)

	-- Decorative bands every 30 studs
	for i = 1, math.floor(TOWER_HEIGHT / 30) do
		local bandY: number = i * 30
		createCylinder(tower, "Band" .. i,
			3, TOWER_RADIUS + 1,
			baseCFrame * CFrame.new(0, bandY, 0),
			COLORS.STONE_DARK, Enum.Material.Cobblestone)
	end

	-- === FOUNDATION ===
	createCylinder(tower, "Foundation",
		4, TOWER_RADIUS + 4,
		baseCFrame * CFrame.new(0, 2, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- === TOP PLATFORM ===
	createCylinder(tower, "TopPlatform",
		3, TOWER_RADIUS + 6,
		baseCFrame * CFrame.new(0, TOWER_HEIGHT + 1.5, 0),
		COLORS.STONE_LIGHT, Enum.Material.Limestone)

	-- Crenellations around top
	local crenelCount: number = 20
	for i = 0, crenelCount - 1 do
		local angle: number = (i / crenelCount) * math.pi * 2
		local x: number = math.cos(angle) * (TOWER_RADIUS + 5)
		local z: number = math.sin(angle) * (TOWER_RADIUS + 5)

		createPart(tower, "Crenel" .. i,
			Vector3.new(3, 4, 3),
			baseCFrame * CFrame.new(x, TOWER_HEIGHT + 5, z),
			COLORS.STONE)
	end

	-- === CONICAL ROOF ===
	local roofHeight: number = 25

	-- Roof cone (approximated with wedges)
	for i = 0, 7 do
		local angle: number = (i / 8) * math.pi * 2
		local wedgeWidth: number = TOWER_RADIUS * 1.2

		local wedge: WedgePart = Instance.new("WedgePart")
		wedge.Name = "RoofWedge" .. i
		wedge.Size = Vector3.new(wedgeWidth, roofHeight, wedgeWidth / 2)
		wedge.CFrame = baseCFrame * CFrame.new(0, TOWER_HEIGHT + 3 + roofHeight / 2, 0) * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, -wedgeWidth / 4)
		wedge.Anchored = true
		wedge.Color = COLORS.ROOF
		wedge.Material = Enum.Material.Slate
		wedge.Parent = tower
	end

	-- Spire at top
	createPart(tower, "Spire",
		Vector3.new(2, 15, 2),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT + roofHeight + 10, 0),
		COLORS.IRON, Enum.Material.Metal)

	-- === EXTERNAL SPIRAL STAIRCASE ===
	local totalStairs: number = math.ceil(TOWER_HEIGHT / STAIR_HEIGHT)
	local totalRotations: number = totalStairs / STAIRS_PER_ROTATION

	print("[Tower] Creating", totalStairs, "spiral stairs...")

	for i = 0, totalStairs - 1 do
		local y: number = i * STAIR_HEIGHT
		local angle: number = (i / STAIRS_PER_ROTATION) * math.pi * 2

		local x: number = math.cos(angle) * STAIR_RADIUS
		local z: number = math.sin(angle) * STAIR_RADIUS

		-- Stair tread
		local stairCFrame: CFrame = baseCFrame * CFrame.new(x, y + STAIR_HEIGHT / 2, z) * CFrame.Angles(0, -angle + math.rad(90), 0)

		createPart(tower, "Stair" .. i,
			Vector3.new(STAIR_WIDTH, STAIR_HEIGHT, STAIR_DEPTH),
			stairCFrame,
			COLORS.STONE_DARK, Enum.Material.Cobblestone)

		-- Railing post every 4 stairs
		if i % 4 == 0 then
			local railX: number = math.cos(angle) * (STAIR_RADIUS + STAIR_WIDTH / 2 + 0.5)
			local railZ: number = math.sin(angle) * (STAIR_RADIUS + STAIR_WIDTH / 2 + 0.5)

			createPart(tower, "RailPost" .. i,
				Vector3.new(0.8, 4, 0.8),
				baseCFrame * CFrame.new(railX, y + 2, railZ),
				COLORS.STONE, Enum.Material.Limestone)
		end

		-- Railing bar
		if i > 0 and i % 2 == 0 then
			local prevAngle: number = ((i - 2) / STAIRS_PER_ROTATION) * math.pi * 2
			local currX: number = math.cos(angle) * (STAIR_RADIUS + STAIR_WIDTH / 2 + 0.5)
			local currZ: number = math.sin(angle) * (STAIR_RADIUS + STAIR_WIDTH / 2 + 0.5)
			local prevX: number = math.cos(prevAngle) * (STAIR_RADIUS + STAIR_WIDTH / 2 + 0.5)
			local prevZ: number = math.sin(prevAngle) * (STAIR_RADIUS + STAIR_WIDTH / 2 + 0.5)

			local midX: number = (currX + prevX) / 2
			local midZ: number = (currZ + prevZ) / 2
			local midY: number = y - STAIR_HEIGHT

			local barLength: number = math.sqrt((currX - prevX)^2 + (currZ - prevZ)^2)
			local barAngle: number = math.atan2(currX - prevX, currZ - prevZ)

			createPart(tower, "Rail" .. i,
				Vector3.new(0.5, 0.5, barLength),
				baseCFrame * CFrame.new(midX, midY + 3.5, midZ) * CFrame.Angles(0, barAngle, 0),
				COLORS.IRON, Enum.Material.Metal)
		end

		-- Torch every 16 stairs (once per rotation)
		if i % 16 == 8 then
			local torchX: number = math.cos(angle) * (TOWER_RADIUS - 1)
			local torchZ: number = math.sin(angle) * (TOWER_RADIUS - 1)
			createTorch(tower, baseCFrame * CFrame.new(torchX, y + 3, torchZ))
		end
	end

	-- Support brackets connecting stairs to tower
	for i = 0, math.floor(totalStairs / 8) - 1 do
		local stairIndex: number = i * 8 + 4
		local y: number = stairIndex * STAIR_HEIGHT
		local angle: number = (stairIndex / STAIRS_PER_ROTATION) * math.pi * 2

		local innerX: number = math.cos(angle) * TOWER_RADIUS
		local innerZ: number = math.sin(angle) * TOWER_RADIUS
		local outerX: number = math.cos(angle) * (STAIR_RADIUS - STAIR_WIDTH / 2)
		local outerZ: number = math.sin(angle) * (STAIR_RADIUS - STAIR_WIDTH / 2)

		local bracketLength: number = STAIR_RADIUS - STAIR_WIDTH / 2 - TOWER_RADIUS

		createPart(tower, "Bracket" .. i,
			Vector3.new(2, 2, bracketLength),
			baseCFrame * CFrame.new((innerX + outerX) / 2, y, (innerZ + outerZ) / 2) * CFrame.Angles(0, -angle, 0),
			COLORS.STONE_DARK, Enum.Material.Cobblestone)
	end

	-- === WINDOWS ===
	local windowCount: number = 8
	local windowLevels: number = 5

	for level = 1, windowLevels do
		local windowY: number = level * (TOWER_HEIGHT / (windowLevels + 1))

		for i = 0, windowCount - 1 do
			local angle: number = (i / windowCount) * math.pi * 2 + (level * 0.3)
			local x: number = math.cos(angle) * (TOWER_RADIUS - WALL_THICKNESS / 2)
			local z: number = math.sin(angle) * (TOWER_RADIUS - WALL_THICKNESS / 2)

			createPart(tower, "Window" .. level .. "_" .. i,
				Vector3.new(3, 6, WALL_THICKNESS + 1),
				baseCFrame * CFrame.new(x, windowY, z) * CFrame.Angles(0, -angle, 0),
				COLORS.STONE_DARK, Enum.Material.Glass)
		end
	end

	-- === ENTRANCE ===
	createPart(tower, "DoorFrame",
		Vector3.new(6, 12, WALL_THICKNESS + 2),
		baseCFrame * CFrame.new(0, 6, TOWER_RADIUS),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	createPart(tower, "Door",
		Vector3.new(4, 10, 1),
		baseCFrame * CFrame.new(0, 5, TOWER_RADIUS + WALL_THICKNESS / 2 + 0.5),
		COLORS.WOOD, Enum.Material.Wood)

	tower.Parent = Workspace

	print("[Tower] Massive tower complete! Height:", TOWER_HEIGHT, "studs")
	return tower
end

-- Build the tower
buildTower()
