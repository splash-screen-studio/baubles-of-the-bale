--[[
	Castle.server.luau

	Creates a massive medieval castle with towers, walls, keep, and courtyard.
]]

local Workspace = game:GetService("Workspace")

-- Castle configuration
local POSITION: Vector3 = Vector3.new(59, 0, -239)

-- Dimensions
local COURTYARD_SIZE: number = 80
local WALL_HEIGHT: number = 20
local WALL_THICKNESS: number = 5
local TOWER_RADIUS: number = 10
local TOWER_HEIGHT: number = 35
local KEEP_SIZE: number = 30
local KEEP_HEIGHT: number = 45
local GATE_WIDTH: number = 14
local GATE_HEIGHT: number = 16

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(145, 140, 130),
	STONE_DARK = Color3.fromRGB(110, 105, 95),
	STONE_LIGHT = Color3.fromRGB(170, 165, 155),
	ROOF = Color3.fromRGB(55, 50, 45),
	WOOD = Color3.fromRGB(90, 70, 50),
	WOOD_DARK = Color3.fromRGB(60, 45, 30),
	IRON = Color3.fromRGB(55, 55, 60),
	TORCH_LIGHT = Color3.fromRGB(255, 147, 41),
	BANNER_RED = Color3.fromRGB(140, 30, 30),
	GOLD = Color3.fromRGB(180, 150, 50),
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
	light.Range = 20
	light.Shadows = true
	light.Parent = head
end

--[[
	Creates crenellations along a wall segment
]]
local function createCrenellations(parent: Instance, baseCFrame: CFrame, length: number, height: number, prefix: string): ()
	local crenelWidth: number = 3
	local crenelHeight: number = 3
	local crenelCount: number = math.floor(length / (crenelWidth * 2))

	for i = 0, crenelCount - 1 do
		local offset: number = (i - crenelCount / 2 + 0.5) * crenelWidth * 2
		createPart(parent, prefix .. "Crenel" .. i,
			Vector3.new(crenelWidth, crenelHeight, crenelWidth),
			baseCFrame * CFrame.new(offset, height + crenelHeight / 2, 0),
			COLORS.STONE)
	end
end

--[[
	Creates a corner tower
]]
local function createCornerTower(parent: Instance, baseCFrame: CFrame, towerName: string): ()
	-- Main tower cylinder
	createCylinder(parent, towerName .. "Body",
		TOWER_HEIGHT, TOWER_RADIUS,
		baseCFrame * CFrame.new(0, TOWER_HEIGHT / 2, 0),
		COLORS.STONE, Enum.Material.Limestone)

	-- Decorative band
	createCylinder(parent, towerName .. "Band",
		2, TOWER_RADIUS + 1,
		baseCFrame * CFrame.new(0, WALL_HEIGHT, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Top platform
	createCylinder(parent, towerName .. "Platform",
		2, TOWER_RADIUS + 3,
		baseCFrame * CFrame.new(0, TOWER_HEIGHT + 1, 0),
		COLORS.STONE_LIGHT, Enum.Material.Limestone)

	-- Tower crenellations
	local crenelCount: number = 10
	for i = 0, crenelCount - 1 do
		local angle: number = (i / crenelCount) * math.pi * 2
		local x: number = math.cos(angle) * (TOWER_RADIUS + 2)
		local z: number = math.sin(angle) * (TOWER_RADIUS + 2)

		createPart(parent, towerName .. "Crenel" .. i,
			Vector3.new(2.5, 3, 2.5),
			baseCFrame * CFrame.new(x, TOWER_HEIGHT + 3.5, z),
			COLORS.STONE)
	end

	-- Conical roof
	local roofHeight: number = 12
	for i = 0, 7 do
		local angle: number = (i / 8) * math.pi * 2
		local wedgeWidth: number = TOWER_RADIUS * 0.9

		local wedge: WedgePart = Instance.new("WedgePart")
		wedge.Name = towerName .. "RoofWedge" .. i
		wedge.Size = Vector3.new(wedgeWidth, roofHeight, wedgeWidth / 2)
		wedge.CFrame = baseCFrame * CFrame.new(0, TOWER_HEIGHT + 5 + roofHeight / 2, 0) * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, -wedgeWidth / 4)
		wedge.Anchored = true
		wedge.Color = COLORS.ROOF
		wedge.Material = Enum.Material.Slate
		wedge.Parent = parent
	end

	-- Flag pole
	createPart(parent, towerName .. "FlagPole",
		Vector3.new(0.5, 10, 0.5),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT + roofHeight + 10, 0),
		COLORS.IRON, Enum.Material.Metal)

	-- Banner
	createPart(parent, towerName .. "Banner",
		Vector3.new(0.2, 6, 4),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT + roofHeight + 12, 2.5),
		COLORS.BANNER_RED, Enum.Material.Fabric)

	-- Windows
	for level = 1, 3 do
		local windowY: number = level * (TOWER_HEIGHT / 4)
		local windowAngle: number = level * math.rad(45)
		local wx: number = math.cos(windowAngle) * (TOWER_RADIUS - 1)
		local wz: number = math.sin(windowAngle) * (TOWER_RADIUS - 1)

		createPart(parent, towerName .. "Window" .. level,
			Vector3.new(2, 4, 3),
			baseCFrame * CFrame.new(wx, windowY, wz) * CFrame.Angles(0, -windowAngle, 0),
			COLORS.STONE_DARK, Enum.Material.Glass)
	end
end

--[[
	Builds the castle
]]
local function buildCastle(): Model
	print("[Castle] Building massive castle at", POSITION)

	local castle: Model = Instance.new("Model")
	castle.Name = "Castle"

	local baseCFrame: CFrame = CFrame.new(POSITION)
	local halfCourtyard: number = COURTYARD_SIZE / 2

	-- === COURTYARD FLOOR ===
	createPart(castle, "CourtyardFloor",
		Vector3.new(COURTYARD_SIZE, 1, COURTYARD_SIZE),
		baseCFrame * CFrame.new(0, 0.5, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- === CORNER TOWERS ===
	local towerPositions = {
		{name = "TowerNE", x = halfCourtyard, z = halfCourtyard},
		{name = "TowerNW", x = -halfCourtyard, z = halfCourtyard},
		{name = "TowerSE", x = halfCourtyard, z = -halfCourtyard},
		{name = "TowerSW", x = -halfCourtyard, z = -halfCourtyard},
	}

	for _, tower in ipairs(towerPositions) do
		createCornerTower(castle, baseCFrame * CFrame.new(tower.x, 0, tower.z), tower.name)
	end

	-- === CURTAIN WALLS ===
	-- North wall (with gate)
	local northWallHalfLength: number = (COURTYARD_SIZE - GATE_WIDTH) / 2 - TOWER_RADIUS

	-- North wall left section
	createPart(castle, "WallNorthLeft",
		Vector3.new(northWallHalfLength, WALL_HEIGHT, WALL_THICKNESS),
		baseCFrame * CFrame.new(-halfCourtyard + TOWER_RADIUS + northWallHalfLength / 2, WALL_HEIGHT / 2, halfCourtyard),
		COLORS.STONE)

	-- North wall right section
	createPart(castle, "WallNorthRight",
		Vector3.new(northWallHalfLength, WALL_HEIGHT, WALL_THICKNESS),
		baseCFrame * CFrame.new(halfCourtyard - TOWER_RADIUS - northWallHalfLength / 2, WALL_HEIGHT / 2, halfCourtyard),
		COLORS.STONE)

	-- Gate arch
	createPart(castle, "GateArchLeft",
		Vector3.new(3, WALL_HEIGHT, WALL_THICKNESS + 2),
		baseCFrame * CFrame.new(-GATE_WIDTH / 2 - 1.5, WALL_HEIGHT / 2, halfCourtyard),
		COLORS.STONE_DARK)

	createPart(castle, "GateArchRight",
		Vector3.new(3, WALL_HEIGHT, WALL_THICKNESS + 2),
		baseCFrame * CFrame.new(GATE_WIDTH / 2 + 1.5, WALL_HEIGHT / 2, halfCourtyard),
		COLORS.STONE_DARK)

	createPart(castle, "GateArchTop",
		Vector3.new(GATE_WIDTH + 6, WALL_HEIGHT - GATE_HEIGHT, WALL_THICKNESS + 2),
		baseCFrame * CFrame.new(0, GATE_HEIGHT + (WALL_HEIGHT - GATE_HEIGHT) / 2, halfCourtyard),
		COLORS.STONE_DARK)

	-- Portcullis (gate)
	createPart(castle, "Portcullis",
		Vector3.new(GATE_WIDTH, GATE_HEIGHT, 1),
		baseCFrame * CFrame.new(0, GATE_HEIGHT / 2, halfCourtyard),
		COLORS.IRON, Enum.Material.Metal)

	-- South wall
	createPart(castle, "WallSouth",
		Vector3.new(COURTYARD_SIZE - TOWER_RADIUS * 2, WALL_HEIGHT, WALL_THICKNESS),
		baseCFrame * CFrame.new(0, WALL_HEIGHT / 2, -halfCourtyard),
		COLORS.STONE)

	-- East wall
	createPart(castle, "WallEast",
		Vector3.new(WALL_THICKNESS, WALL_HEIGHT, COURTYARD_SIZE - TOWER_RADIUS * 2),
		baseCFrame * CFrame.new(halfCourtyard, WALL_HEIGHT / 2, 0),
		COLORS.STONE)

	-- West wall
	createPart(castle, "WallWest",
		Vector3.new(WALL_THICKNESS, WALL_HEIGHT, COURTYARD_SIZE - TOWER_RADIUS * 2),
		baseCFrame * CFrame.new(-halfCourtyard, WALL_HEIGHT / 2, 0),
		COLORS.STONE)

	-- === WALL WALKWAYS ===
	local walkwayWidth: number = 4
	local walkwayHeight: number = WALL_HEIGHT - 2

	-- North walkway sections
	createPart(castle, "WalkwayNorthLeft",
		Vector3.new(northWallHalfLength, 1, walkwayWidth),
		baseCFrame * CFrame.new(-halfCourtyard + TOWER_RADIUS + northWallHalfLength / 2, walkwayHeight, halfCourtyard - walkwayWidth / 2),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	createPart(castle, "WalkwayNorthRight",
		Vector3.new(northWallHalfLength, 1, walkwayWidth),
		baseCFrame * CFrame.new(halfCourtyard - TOWER_RADIUS - northWallHalfLength / 2, walkwayHeight, halfCourtyard - walkwayWidth / 2),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- South walkway
	createPart(castle, "WalkwaySouth",
		Vector3.new(COURTYARD_SIZE - TOWER_RADIUS * 2, 1, walkwayWidth),
		baseCFrame * CFrame.new(0, walkwayHeight, -halfCourtyard + walkwayWidth / 2),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- East walkway
	createPart(castle, "WalkwayEast",
		Vector3.new(walkwayWidth, 1, COURTYARD_SIZE - TOWER_RADIUS * 2),
		baseCFrame * CFrame.new(halfCourtyard - walkwayWidth / 2, walkwayHeight, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- West walkway
	createPart(castle, "WalkwayWest",
		Vector3.new(walkwayWidth, 1, COURTYARD_SIZE - TOWER_RADIUS * 2),
		baseCFrame * CFrame.new(-halfCourtyard + walkwayWidth / 2, walkwayHeight, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- === WALL CRENELLATIONS ===
	createCrenellations(castle, baseCFrame * CFrame.new(0, 0, halfCourtyard + WALL_THICKNESS / 2), COURTYARD_SIZE - TOWER_RADIUS * 2, WALL_HEIGHT, "NorthOuter")
	createCrenellations(castle, baseCFrame * CFrame.new(0, 0, -halfCourtyard - WALL_THICKNESS / 2), COURTYARD_SIZE - TOWER_RADIUS * 2, WALL_HEIGHT, "SouthOuter")

	-- === CENTRAL KEEP ===
	local keepCFrame: CFrame = baseCFrame * CFrame.new(0, 0, -halfCourtyard / 2)

	-- Keep base
	createPart(castle, "KeepBase",
		Vector3.new(KEEP_SIZE + 4, 3, KEEP_SIZE + 4),
		keepCFrame * CFrame.new(0, 1.5, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Keep main structure
	createPart(castle, "KeepBody",
		Vector3.new(KEEP_SIZE, KEEP_HEIGHT, KEEP_SIZE),
		keepCFrame * CFrame.new(0, KEEP_HEIGHT / 2 + 3, 0),
		COLORS.STONE, Enum.Material.Limestone)

	-- Keep buttresses
	for i = 0, 3 do
		local angle: number = i * math.rad(90) + math.rad(45)
		local bx: number = math.cos(angle) * (KEEP_SIZE / 2 + 1)
		local bz: number = math.sin(angle) * (KEEP_SIZE / 2 + 1)

		createPart(castle, "KeepButtress" .. i,
			Vector3.new(4, KEEP_HEIGHT - 10, 4),
			keepCFrame * CFrame.new(bx, (KEEP_HEIGHT - 10) / 2 + 3, bz),
			COLORS.STONE_DARK)
	end

	-- Keep top platform
	createPart(castle, "KeepPlatform",
		Vector3.new(KEEP_SIZE + 6, 2, KEEP_SIZE + 6),
		keepCFrame * CFrame.new(0, KEEP_HEIGHT + 4, 0),
		COLORS.STONE_LIGHT, Enum.Material.Limestone)

	-- Keep crenellations
	local keepCrenelCount: number = 6
	for side = 0, 3 do
		local sideAngle: number = side * math.rad(90)
		for i = 0, keepCrenelCount - 1 do
			local offset: number = (i - keepCrenelCount / 2 + 0.5) * 5
			local cx: number
			local cz: number

			if side == 0 then
				cx = offset
				cz = KEEP_SIZE / 2 + 3
			elseif side == 1 then
				cx = KEEP_SIZE / 2 + 3
				cz = -offset
			elseif side == 2 then
				cx = -offset
				cz = -KEEP_SIZE / 2 - 3
			else
				cx = -KEEP_SIZE / 2 - 3
				cz = offset
			end

			createPart(castle, "KeepCrenel" .. side .. "_" .. i,
				Vector3.new(3, 4, 3),
				keepCFrame * CFrame.new(cx, KEEP_HEIGHT + 7, cz),
				COLORS.STONE)
		end
	end

	-- Keep roof (flat with slight peak)
	createPart(castle, "KeepRoof",
		Vector3.new(KEEP_SIZE - 2, 2, KEEP_SIZE - 2),
		keepCFrame * CFrame.new(0, KEEP_HEIGHT + 6, 0),
		COLORS.ROOF, Enum.Material.Slate)

	-- Keep spire
	createPart(castle, "KeepSpire",
		Vector3.new(3, 20, 3),
		keepCFrame * CFrame.new(0, KEEP_HEIGHT + 17, 0),
		COLORS.IRON, Enum.Material.Metal)

	-- Keep entrance
	createPart(castle, "KeepDoorFrame",
		Vector3.new(8, 14, 3),
		keepCFrame * CFrame.new(0, 10, KEEP_SIZE / 2),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	createPart(castle, "KeepDoor",
		Vector3.new(6, 12, 1.5),
		keepCFrame * CFrame.new(0, 9, KEEP_SIZE / 2 + 1),
		COLORS.WOOD_DARK, Enum.Material.Wood)

	-- Keep windows
	for level = 1, 3 do
		local windowY: number = level * 12 + 5
		for side = 0, 3 do
			local wx: number = 0
			local wz: number = 0
			local rotation: number = 0

			if side == 0 and level > 1 then
				wz = KEEP_SIZE / 2
				rotation = 0
			elseif side == 1 then
				wx = KEEP_SIZE / 2
				rotation = math.rad(90)
			elseif side == 2 then
				wz = -KEEP_SIZE / 2
				rotation = math.rad(180)
			elseif side == 3 then
				wx = -KEEP_SIZE / 2
				rotation = math.rad(270)
			end

			if not (side == 0 and level == 1) then
				createPart(castle, "KeepWindow" .. level .. "_" .. side,
					Vector3.new(3, 5, 2),
					keepCFrame * CFrame.new(wx, windowY, wz) * CFrame.Angles(0, rotation, 0),
					COLORS.STONE_DARK, Enum.Material.Glass)
			end
		end
	end

	-- === STAIRS TO WALLS ===
	local stairWidth: number = 4
	local stairCount: number = 12

	-- Stairs to east wall (inside courtyard)
	for i = 0, stairCount - 1 do
		local stairY: number = (i + 1) * (walkwayHeight / stairCount)
		local stairZ: number = halfCourtyard / 2 - i * 1.2

		createPart(castle, "StairsEast" .. i,
			Vector3.new(stairWidth, 1, 2),
			baseCFrame * CFrame.new(halfCourtyard - walkwayWidth - 2, stairY, stairZ),
			COLORS.STONE_DARK, Enum.Material.Cobblestone)
	end

	-- Stairs to west wall
	for i = 0, stairCount - 1 do
		local stairY: number = (i + 1) * (walkwayHeight / stairCount)
		local stairZ: number = halfCourtyard / 2 - i * 1.2

		createPart(castle, "StairsWest" .. i,
			Vector3.new(stairWidth, 1, 2),
			baseCFrame * CFrame.new(-halfCourtyard + walkwayWidth + 2, stairY, stairZ),
			COLORS.STONE_DARK, Enum.Material.Cobblestone)
	end

	-- === TORCHES ===
	-- Gate torches
	createTorch(castle, baseCFrame * CFrame.new(-GATE_WIDTH / 2 - 4, 0, halfCourtyard + 3))
	createTorch(castle, baseCFrame * CFrame.new(GATE_WIDTH / 2 + 4, 0, halfCourtyard + 3))

	-- Courtyard torches
	createTorch(castle, baseCFrame * CFrame.new(-halfCourtyard / 2, 0, halfCourtyard / 3))
	createTorch(castle, baseCFrame * CFrame.new(halfCourtyard / 2, 0, halfCourtyard / 3))
	createTorch(castle, baseCFrame * CFrame.new(-halfCourtyard / 2, 0, -halfCourtyard / 3))
	createTorch(castle, baseCFrame * CFrame.new(halfCourtyard / 2, 0, -halfCourtyard / 3))

	-- Keep entrance torches
	createTorch(castle, keepCFrame * CFrame.new(-5, 0, KEEP_SIZE / 2 + 3))
	createTorch(castle, keepCFrame * CFrame.new(5, 0, KEEP_SIZE / 2 + 3))

	-- Wall walkway torches
	for i = -1, 1, 2 do
		createTorch(castle, baseCFrame * CFrame.new(i * (halfCourtyard - 10), walkwayHeight, halfCourtyard - 2))
		createTorch(castle, baseCFrame * CFrame.new(i * (halfCourtyard - 10), walkwayHeight, -halfCourtyard + 2))
		createTorch(castle, baseCFrame * CFrame.new(halfCourtyard - 2, walkwayHeight, i * (halfCourtyard - 15)))
		createTorch(castle, baseCFrame * CFrame.new(-halfCourtyard + 2, walkwayHeight, i * (halfCourtyard - 15)))
	end

	-- === DECORATIVE ELEMENTS ===
	-- Well in courtyard
	createCylinder(castle, "WellBase", 2, 4,
		baseCFrame * CFrame.new(halfCourtyard / 3, 1, halfCourtyard / 4),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Weapon racks
	createPart(castle, "WeaponRack",
		Vector3.new(6, 6, 1),
		baseCFrame * CFrame.new(-halfCourtyard + 8, 3, -halfCourtyard / 3),
		COLORS.WOOD_DARK, Enum.Material.Wood)

	-- Training dummy
	createPart(castle, "DummyPost",
		Vector3.new(1, 6, 1),
		baseCFrame * CFrame.new(halfCourtyard / 3, 3, -halfCourtyard / 3),
		COLORS.WOOD, Enum.Material.Wood)

	createPart(castle, "DummyArms",
		Vector3.new(4, 1, 1),
		baseCFrame * CFrame.new(halfCourtyard / 3, 5, -halfCourtyard / 3),
		COLORS.WOOD, Enum.Material.Wood)

	castle.Parent = Workspace

	print("[Castle] Massive castle complete!")
	return castle
end

-- Build the castle
buildCastle()
