--[[
	Castle.server.luau

	Generates a massive medieval castle with moat, drawbridge,
	courtyard, and tower staircases.
]]

local Workspace = game:GetService("Workspace")

-- Castle configuration
local POSITION: Vector3 = Vector3.new(-29, 0, -276)
local FACING_ANGLE: number = math.rad(0) -- Face positive Z (toward village)

-- Colors
local COLORS = {
	STONE = Color3.fromRGB(165, 160, 150),
	STONE_DARK = Color3.fromRGB(120, 115, 105),
	STONE_LIGHT = Color3.fromRGB(185, 180, 170),
	WOOD = Color3.fromRGB(101, 67, 33),
	WOOD_DARK = Color3.fromRGB(60, 45, 30),
	WATER = Color3.fromRGB(40, 80, 120),
	ROOF = Color3.fromRGB(70, 65, 60),
	IRON = Color3.fromRGB(55, 55, 60),
	TORCH_LIGHT = Color3.fromRGB(255, 147, 41),
}

-- Dimensions
local CASTLE_SIZE: number = 180 -- Overall footprint
local WALL_HEIGHT: number = 40
local WALL_THICKNESS: number = 8
local TOWER_SIZE: number = 24
local TOWER_HEIGHT: number = 60
local MOAT_WIDTH: number = 20
local MOAT_DEPTH: number = 8
local COURTYARD_SIZE: number = CASTLE_SIZE - (WALL_THICKNESS * 2) - 20
local GATEHOUSE_WIDTH: number = 30
local GATEHOUSE_HEIGHT: number = 50
local DRAWBRIDGE_LENGTH: number = MOAT_WIDTH + 8
local DRAWBRIDGE_WIDTH: number = 20

--[[
	Clears ground tiles in the moat area so terrain water works properly
]]
local function clearGroundForMoat(baseCFrame: CFrame): ()
	print("[Castle] Waiting for ground to generate...")

	-- Wait for Ground folder to exist
	local groundFolder: Folder? = Workspace:FindFirstChild("Ground")
	local waitTime: number = 0
	while not groundFolder and waitTime < 10 do
		task.wait(0.5)
		waitTime += 0.5
		groundFolder = Workspace:FindFirstChild("Ground")
	end

	if not groundFolder then
		warn("[Castle] Ground folder not found, skipping ground clearing")
		return
	end

	print("[Castle] Clearing ground tiles in moat area...")

	-- Calculate moat bounds in world space
	local innerEdge: number = CASTLE_SIZE / 2 + 5
	local outerEdge: number = innerEdge + MOAT_WIDTH + 5 -- Extra buffer

	local tilesRemoved: number = 0

	for _, tile in groundFolder:GetChildren() do
		if tile:IsA("BasePart") then
			-- Convert tile position to castle-local space
			local localPos: Vector3 = baseCFrame:PointToObjectSpace(tile.Position)
			local absX: number = math.abs(localPos.X)
			local absZ: number = math.abs(localPos.Z)

			-- Check if tile is in the moat ring
			-- Moat is between innerEdge and outerEdge on any side
			local inMoatX: boolean = absX >= innerEdge and absX <= outerEdge
			local inMoatZ: boolean = absZ >= innerEdge and absZ <= outerEdge
			local insideOuter: boolean = absX <= outerEdge and absZ <= outerEdge

			-- Tile is in moat if it's within outer bounds AND
			-- (in the X moat channel OR in the Z moat channel)
			if insideOuter and (inMoatX or inMoatZ) then
				tile:Destroy()
				tilesRemoved += 1
			end
		end
	end

	print("[Castle] Removed", tilesRemoved, "ground tiles for moat")
end

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
	Creates a torch with fire and light
]]
local function createTorch(parent: Instance, cframe: CFrame): Model
	local torchModel: Model = Instance.new("Model")
	torchModel.Name = "Torch"

	local handle: Part = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.6, 3, 0.6)
	handle.CFrame = cframe * CFrame.new(0, 1.5, 0)
	handle.Anchored = true
	handle.Color = COLORS.WOOD
	handle.Material = Enum.Material.Wood
	handle.Parent = torchModel

	local head: Part = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(0.8, 0.6, 0.8)
	head.CFrame = cframe * CFrame.new(0, 3.3, 0)
	head.Anchored = true
	head.Color = Color3.fromRGB(54, 54, 54)
	head.Material = Enum.Material.Slate
	head.Parent = torchModel

	local fire: Fire = Instance.new("Fire")
	fire.Heat = 9
	fire.Size = 5
	fire.Color = Color3.fromRGB(255, 119, 0)
	fire.SecondaryColor = Color3.fromRGB(255, 200, 50)
	fire.Parent = head

	local light: PointLight = Instance.new("PointLight")
	light.Color = COLORS.TORCH_LIGHT
	light.Brightness = 2
	light.Range = 30
	light.Shadows = true
	light.Parent = head

	torchModel.Parent = parent
	return torchModel
end

--[[
	Creates the moat around the castle using terrain water (for swimming physics)
	with part walls (for clean visual edges)
]]
local function createMoat(parent: Instance, baseCFrame: CFrame): ()
	local terrain: Terrain = Workspace.Terrain
	local moatOuterSize: number = CASTLE_SIZE + (MOAT_WIDTH * 2) + 10

	-- Moat dimensions
	local innerEdge: number = CASTLE_SIZE / 2 + 5
	local outerEdge: number = innerEdge + MOAT_WIDTH
	local waterTop: number = -1 -- Water surface just below ground level
	local waterBottom: number = -MOAT_DEPTH - 2

	-- Helper to fill terrain water at world position
	local function fillWater(center: Vector3, size: Vector3): ()
		local worldPos: Vector3 = baseCFrame:PointToWorldSpace(center)
		terrain:FillBlock(CFrame.new(worldPos), size, Enum.Material.Water)
	end

	-- Fill terrain water in moat channels
	-- North moat
	fillWater(
		Vector3.new(0, (waterTop + waterBottom) / 2, innerEdge + MOAT_WIDTH / 2),
		Vector3.new(moatOuterSize, MOAT_DEPTH, MOAT_WIDTH)
	)

	-- South moat
	fillWater(
		Vector3.new(0, (waterTop + waterBottom) / 2, -innerEdge - MOAT_WIDTH / 2),
		Vector3.new(moatOuterSize, MOAT_DEPTH, MOAT_WIDTH)
	)

	-- East moat
	fillWater(
		Vector3.new(innerEdge + MOAT_WIDTH / 2, (waterTop + waterBottom) / 2, 0),
		Vector3.new(MOAT_WIDTH, MOAT_DEPTH, CASTLE_SIZE + 10)
	)

	-- West moat
	fillWater(
		Vector3.new(-innerEdge - MOAT_WIDTH / 2, (waterTop + waterBottom) / 2, 0),
		Vector3.new(MOAT_WIDTH, MOAT_DEPTH, CASTLE_SIZE + 10)
	)

	-- Stone walls to contain water and give clean edges
	-- Outer walls
	createPart(parent, "MoatOuterWallNorth",
		Vector3.new(moatOuterSize + 4, MOAT_DEPTH + 4, 3),
		baseCFrame * CFrame.new(0, -MOAT_DEPTH / 2, outerEdge + 1.5),
		COLORS.STONE_DARK, Enum.Material.Slate)

	createPart(parent, "MoatOuterWallSouth",
		Vector3.new(moatOuterSize + 4, MOAT_DEPTH + 4, 3),
		baseCFrame * CFrame.new(0, -MOAT_DEPTH / 2, -outerEdge - 1.5),
		COLORS.STONE_DARK, Enum.Material.Slate)

	createPart(parent, "MoatOuterWallEast",
		Vector3.new(3, MOAT_DEPTH + 4, CASTLE_SIZE + MOAT_WIDTH * 2 + 14),
		baseCFrame * CFrame.new(outerEdge + 1.5, -MOAT_DEPTH / 2, 0),
		COLORS.STONE_DARK, Enum.Material.Slate)

	createPart(parent, "MoatOuterWallWest",
		Vector3.new(3, MOAT_DEPTH + 4, CASTLE_SIZE + MOAT_WIDTH * 2 + 14),
		baseCFrame * CFrame.new(-outerEdge - 1.5, -MOAT_DEPTH / 2, 0),
		COLORS.STONE_DARK, Enum.Material.Slate)

	-- Inner walls (against castle)
	createPart(parent, "MoatInnerWallNorth",
		Vector3.new(CASTLE_SIZE + 10, MOAT_DEPTH + 4, 3),
		baseCFrame * CFrame.new(0, -MOAT_DEPTH / 2, innerEdge - 1.5),
		COLORS.STONE_DARK, Enum.Material.Slate)

	createPart(parent, "MoatInnerWallSouth",
		Vector3.new(CASTLE_SIZE + 10, MOAT_DEPTH + 4, 3),
		baseCFrame * CFrame.new(0, -MOAT_DEPTH / 2, -innerEdge + 1.5),
		COLORS.STONE_DARK, Enum.Material.Slate)

	createPart(parent, "MoatInnerWallEast",
		Vector3.new(3, MOAT_DEPTH + 4, CASTLE_SIZE + 10),
		baseCFrame * CFrame.new(innerEdge - 1.5, -MOAT_DEPTH / 2, 0),
		COLORS.STONE_DARK, Enum.Material.Slate)

	createPart(parent, "MoatInnerWallWest",
		Vector3.new(3, MOAT_DEPTH + 4, CASTLE_SIZE + 10),
		baseCFrame * CFrame.new(-innerEdge + 1.5, -MOAT_DEPTH / 2, 0),
		COLORS.STONE_DARK, Enum.Material.Slate)

	-- Moat bed (bottom)
	createPart(parent, "MoatBedNorth",
		Vector3.new(moatOuterSize, 2, MOAT_WIDTH + 4),
		baseCFrame * CFrame.new(0, -MOAT_DEPTH - 2, innerEdge + MOAT_WIDTH / 2),
		COLORS.STONE_DARK, Enum.Material.Slate)

	createPart(parent, "MoatBedSouth",
		Vector3.new(moatOuterSize, 2, MOAT_WIDTH + 4),
		baseCFrame * CFrame.new(0, -MOAT_DEPTH - 2, -innerEdge - MOAT_WIDTH / 2),
		COLORS.STONE_DARK, Enum.Material.Slate)

	createPart(parent, "MoatBedEast",
		Vector3.new(MOAT_WIDTH + 4, 2, CASTLE_SIZE + 10),
		baseCFrame * CFrame.new(innerEdge + MOAT_WIDTH / 2, -MOAT_DEPTH - 2, 0),
		COLORS.STONE_DARK, Enum.Material.Slate)

	createPart(parent, "MoatBedWest",
		Vector3.new(MOAT_WIDTH + 4, 2, CASTLE_SIZE + 10),
		baseCFrame * CFrame.new(-innerEdge - MOAT_WIDTH / 2, -MOAT_DEPTH - 2, 0),
		COLORS.STONE_DARK, Enum.Material.Slate)

	print("[Castle] Moat created with terrain water (swimming enabled)")
end

--[[
	Creates crenellations (battlements) along a wall
]]
local function createCrenellations(parent: Instance, baseCFrame: CFrame, length: number, wallThickness: number): ()
	local crenelWidth: number = 4
	local crenelHeight: number = 5
	local crenelSpacing: number = 6
	local numCrenels: number = math.floor(length / (crenelWidth + crenelSpacing))

	for i = 0, numCrenels - 1 do
		local offset: number = -length/2 + (i + 0.5) * (length / numCrenels)
		createPart(parent, "Crenel" .. i,
			Vector3.new(crenelWidth, crenelHeight, wallThickness + 1),
			baseCFrame * CFrame.new(offset, crenelHeight/2, 0),
			COLORS.STONE)
	end
end

--[[
	Creates the main castle walls
]]
local function createWalls(parent: Instance, baseCFrame: CFrame): ()
	local halfSize: number = CASTLE_SIZE / 2

	-- North wall (with gap for gatehouse)
	local northWallSideLength: number = (CASTLE_SIZE - GATEHOUSE_WIDTH) / 2

	createPart(parent, "WallNorthLeft",
		Vector3.new(northWallSideLength, WALL_HEIGHT, WALL_THICKNESS),
		baseCFrame * CFrame.new(-halfSize + northWallSideLength/2, WALL_HEIGHT/2, halfSize),
		COLORS.STONE)

	createPart(parent, "WallNorthRight",
		Vector3.new(northWallSideLength, WALL_HEIGHT, WALL_THICKNESS),
		baseCFrame * CFrame.new(halfSize - northWallSideLength/2, WALL_HEIGHT/2, halfSize),
		COLORS.STONE)

	-- South wall
	createPart(parent, "WallSouth",
		Vector3.new(CASTLE_SIZE, WALL_HEIGHT, WALL_THICKNESS),
		baseCFrame * CFrame.new(0, WALL_HEIGHT/2, -halfSize),
		COLORS.STONE)

	-- East wall
	createPart(parent, "WallEast",
		Vector3.new(WALL_THICKNESS, WALL_HEIGHT, CASTLE_SIZE),
		baseCFrame * CFrame.new(halfSize, WALL_HEIGHT/2, 0),
		COLORS.STONE)

	-- West wall
	createPart(parent, "WallWest",
		Vector3.new(WALL_THICKNESS, WALL_HEIGHT, CASTLE_SIZE),
		baseCFrame * CFrame.new(-halfSize, WALL_HEIGHT/2, 0),
		COLORS.STONE)

	-- Wall walks (top of walls for soldiers)
	createPart(parent, "WalkSouth",
		Vector3.new(CASTLE_SIZE, 2, WALL_THICKNESS + 4),
		baseCFrame * CFrame.new(0, WALL_HEIGHT + 1, -halfSize),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	createPart(parent, "WalkEast",
		Vector3.new(WALL_THICKNESS + 4, 2, CASTLE_SIZE),
		baseCFrame * CFrame.new(halfSize, WALL_HEIGHT + 1, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	createPart(parent, "WalkWest",
		Vector3.new(WALL_THICKNESS + 4, 2, CASTLE_SIZE),
		baseCFrame * CFrame.new(-halfSize, WALL_HEIGHT + 1, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Crenellations
	createCrenellations(parent, baseCFrame * CFrame.new(0, WALL_HEIGHT + 2, -halfSize), CASTLE_SIZE, WALL_THICKNESS)
	createCrenellations(parent, baseCFrame * CFrame.new(halfSize, WALL_HEIGHT + 2, 0) * CFrame.Angles(0, math.rad(90), 0), CASTLE_SIZE, WALL_THICKNESS)
	createCrenellations(parent, baseCFrame * CFrame.new(-halfSize, WALL_HEIGHT + 2, 0) * CFrame.Angles(0, math.rad(90), 0), CASTLE_SIZE, WALL_THICKNESS)
end

--[[
	Creates a corner tower with internal spiral staircase
]]
local function createTower(parent: Instance, baseCFrame: CFrame, name: string): ()
	-- Main tower body
	createPart(parent, name .. "Base",
		Vector3.new(TOWER_SIZE, TOWER_HEIGHT, TOWER_SIZE),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT/2, 0),
		COLORS.STONE)

	-- Tower top platform
	createPart(parent, name .. "Platform",
		Vector3.new(TOWER_SIZE + 4, 2, TOWER_SIZE + 4),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT + 1, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Tower crenellations
	local crenelSize: number = 3
	local crenelHeight: number = 4
	for i = 0, 3 do
		for j = -1, 1, 2 do
			local angle: number = math.rad(i * 90)
			local perpAngle: number = math.rad(i * 90 + 90)
			local baseOffset: number = (TOWER_SIZE + 4) / 2 - crenelSize/2
			local sideOffset: number = j * (TOWER_SIZE / 4)

			local xOff: number = math.sin(angle) * baseOffset + math.sin(perpAngle) * sideOffset
			local zOff: number = math.cos(angle) * baseOffset + math.cos(perpAngle) * sideOffset

			createPart(parent, name .. "Crenel" .. i .. "_" .. j,
				Vector3.new(crenelSize, crenelHeight, crenelSize),
				baseCFrame * CFrame.new(xOff, TOWER_HEIGHT + 2 + crenelHeight/2, zOff),
				COLORS.STONE)
		end
	end

	-- Conical roof
	local roofHeight: number = 15
	local roofBase: Part = createPart(parent, name .. "RoofBase",
		Vector3.new(TOWER_SIZE + 6, 2, TOWER_SIZE + 6),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT + crenelHeight + 4, 0),
		COLORS.STONE_LIGHT)

	-- Roof cone (approximated with wedges)
	for i = 0, 3 do
		local angle: number = math.rad(i * 90 + 45)
		local roofWidth: number = TOWER_SIZE * 0.8

		local wedge: WedgePart = Instance.new("WedgePart")
		wedge.Name = name .. "RoofWedge" .. i
		wedge.Size = Vector3.new(roofWidth, roofHeight, roofWidth/2)
		wedge.CFrame = baseCFrame * CFrame.new(0, TOWER_HEIGHT + crenelHeight + 5 + roofHeight/2, 0) * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, -roofWidth/4)
		wedge.Anchored = true
		wedge.Color = COLORS.ROOF
		wedge.Material = Enum.Material.Slate
		wedge.Parent = parent
	end

	-- Spiral staircase inside tower
	local stairCount: number = 20
	local stairHeight: number = TOWER_HEIGHT / stairCount
	local stairRadius: number = TOWER_SIZE / 2 - 3

	for i = 0, stairCount - 1 do
		local angle: number = math.rad(i * 360 / 8) -- 8 stairs per full rotation
		local height: number = i * stairHeight + 2

		local stairX: number = math.sin(angle) * stairRadius * 0.6
		local stairZ: number = math.cos(angle) * stairRadius * 0.6

		createPart(parent, name .. "Stair" .. i,
			Vector3.new(6, 1.5, 4),
			baseCFrame * CFrame.new(stairX, height, stairZ) * CFrame.Angles(0, -angle, 0),
			COLORS.STONE_DARK, Enum.Material.Cobblestone)
	end

	-- Central pillar for stairs
	createPart(parent, name .. "StairPillar",
		Vector3.new(3, TOWER_HEIGHT - 5, 3),
		baseCFrame * CFrame.new(0, TOWER_HEIGHT/2, 0),
		COLORS.STONE_DARK)

	-- Tower door at ground level
	createPart(parent, name .. "Door",
		Vector3.new(5, 10, 2),
		baseCFrame * CFrame.new(0, 5, TOWER_SIZE/2),
		COLORS.WOOD_DARK, Enum.Material.Wood)
end

--[[
	Creates the main gatehouse with drawbridge
]]
local function createGatehouse(parent: Instance, baseCFrame: CFrame): ()
	local halfSize: number = CASTLE_SIZE / 2

	-- Gatehouse towers (flanking the entrance)
	local towerOffset: number = GATEHOUSE_WIDTH/2 + 8

	-- Left gatehouse tower
	createPart(parent, "GatehouseTowerLeft",
		Vector3.new(16, GATEHOUSE_HEIGHT, 16),
		baseCFrame * CFrame.new(-towerOffset, GATEHOUSE_HEIGHT/2, halfSize),
		COLORS.STONE)

	-- Right gatehouse tower
	createPart(parent, "GatehouseTowerRight",
		Vector3.new(16, GATEHOUSE_HEIGHT, 16),
		baseCFrame * CFrame.new(towerOffset, GATEHOUSE_HEIGHT/2, halfSize),
		COLORS.STONE)

	-- Gatehouse arch above entrance
	createPart(parent, "GatehouseArch",
		Vector3.new(GATEHOUSE_WIDTH, 15, 12),
		baseCFrame * CFrame.new(0, GATEHOUSE_HEIGHT - 7, halfSize),
		COLORS.STONE)

	-- Gatehouse platform
	createPart(parent, "GatehousePlatform",
		Vector3.new(GATEHOUSE_WIDTH + 32, 2, 20),
		baseCFrame * CFrame.new(0, GATEHOUSE_HEIGHT + 1, halfSize),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Crenellations on gatehouse
	for i = -3, 3 do
		if math.abs(i) > 0 then
			createPart(parent, "GatehouseCrenel" .. i,
				Vector3.new(4, 5, 4),
				baseCFrame * CFrame.new(i * 7, GATEHOUSE_HEIGHT + 4.5, halfSize + 8),
				COLORS.STONE)
		end
	end

	-- Portcullis (raised)
	createPart(parent, "Portcullis",
		Vector3.new(GATEHOUSE_WIDTH - 4, 20, 1),
		baseCFrame * CFrame.new(0, GATEHOUSE_HEIGHT - 5, halfSize - 2),
		COLORS.IRON, Enum.Material.Metal)

	-- Drawbridge (down position)
	createPart(parent, "Drawbridge",
		Vector3.new(DRAWBRIDGE_WIDTH, 2, DRAWBRIDGE_LENGTH),
		baseCFrame * CFrame.new(0, 1, halfSize + MOAT_WIDTH/2 + 8),
		COLORS.WOOD, Enum.Material.Wood)

	-- Drawbridge chains
	createPart(parent, "ChainLeft",
		Vector3.new(0.5, 15, 0.5),
		baseCFrame * CFrame.new(-DRAWBRIDGE_WIDTH/2 + 1, 10, halfSize + 3) * CFrame.Angles(math.rad(-30), 0, 0),
		COLORS.IRON, Enum.Material.Metal)

	createPart(parent, "ChainRight",
		Vector3.new(0.5, 15, 0.5),
		baseCFrame * CFrame.new(DRAWBRIDGE_WIDTH/2 - 1, 10, halfSize + 3) * CFrame.Angles(math.rad(-30), 0, 0),
		COLORS.IRON, Enum.Material.Metal)

	-- Torches at gatehouse
	createTorch(parent, baseCFrame * CFrame.new(-towerOffset + 8, 12, halfSize + 9))
	createTorch(parent, baseCFrame * CFrame.new(towerOffset - 8, 12, halfSize + 9))
end

--[[
	Creates the courtyard
]]
local function createCourtyard(parent: Instance, baseCFrame: CFrame): ()
	-- Main courtyard floor
	createPart(parent, "CourtyardFloor",
		Vector3.new(COURTYARD_SIZE, 2, COURTYARD_SIZE),
		baseCFrame * CFrame.new(0, 1, 0),
		COLORS.STONE_DARK, Enum.Material.Cobblestone)

	-- Well in center
	local wellRadius: number = 6
	createPart(parent, "WellBase",
		Vector3.new(wellRadius * 2, 4, wellRadius * 2),
		baseCFrame * CFrame.new(0, 4, 0),
		COLORS.STONE)

	createPart(parent, "WellInner",
		Vector3.new(wellRadius, 6, wellRadius),
		baseCFrame * CFrame.new(0, 3, 0),
		COLORS.WATER, Enum.Material.Water)

	-- Well roof supports
	createPart(parent, "WellPostLeft",
		Vector3.new(1, 10, 1),
		baseCFrame * CFrame.new(-wellRadius + 1, 9, 0),
		COLORS.WOOD, Enum.Material.Wood)

	createPart(parent, "WellPostRight",
		Vector3.new(1, 10, 1),
		baseCFrame * CFrame.new(wellRadius - 1, 9, 0),
		COLORS.WOOD, Enum.Material.Wood)

	createPart(parent, "WellRoof",
		Vector3.new(wellRadius * 2 + 4, 1, wellRadius + 2),
		baseCFrame * CFrame.new(0, 14, 0),
		COLORS.ROOF, Enum.Material.Wood)

	-- Courtyard torches (along walls)
	local torchSpacing: number = 40
	local torchDist: number = COURTYARD_SIZE / 2 - 5

	for i = -1, 1, 2 do
		for j = -1, 1 do
			createTorch(parent, baseCFrame * CFrame.new(i * torchDist, 3, j * torchSpacing))
			createTorch(parent, baseCFrame * CFrame.new(j * torchSpacing, 3, i * torchDist))
		end
	end
end

--[[
	Creates the keep (main castle building)
]]
local function createKeep(parent: Instance, baseCFrame: CFrame): ()
	local keepSize: number = 50
	local keepHeight: number = 45
	local keepZ: number = -30 -- Toward back of courtyard

	-- Main keep structure
	createPart(parent, "KeepBase",
		Vector3.new(keepSize, keepHeight, keepSize),
		baseCFrame * CFrame.new(0, keepHeight/2, keepZ),
		COLORS.STONE)

	-- Keep entrance
	createPart(parent, "KeepDoor",
		Vector3.new(12, 18, 2),
		baseCFrame * CFrame.new(0, 9, keepZ + keepSize/2),
		COLORS.WOOD_DARK, Enum.Material.Wood)

	-- Keep windows
	for floor = 1, 2 do
		local windowY: number = floor * 15 + 5
		for side = -1, 1, 2 do
			createPart(parent, "KeepWindowFront" .. floor .. "_" .. side,
				Vector3.new(4, 8, 2),
				baseCFrame * CFrame.new(side * 15, windowY, keepZ + keepSize/2),
				COLORS.STONE_DARK, Enum.Material.Glass)

			createPart(parent, "KeepWindowSide" .. floor .. "_" .. side,
				Vector3.new(2, 8, 4),
				baseCFrame * CFrame.new(side * keepSize/2, windowY, keepZ),
				COLORS.STONE_DARK, Enum.Material.Glass)
		end
	end

	-- Keep battlements
	createPart(parent, "KeepTop",
		Vector3.new(keepSize + 4, 3, keepSize + 4),
		baseCFrame * CFrame.new(0, keepHeight + 1.5, keepZ),
		COLORS.STONE_LIGHT)

	for i = 0, 3 do
		local angle: number = math.rad(i * 90)
		for j = -2, 2 do
			local dist: number = keepSize / 2 + 2
			local sideOffset: number = j * 10

			local xOff: number = math.sin(angle) * dist + math.sin(angle + math.rad(90)) * sideOffset
			local zOff: number = math.cos(angle) * dist + math.cos(angle + math.rad(90)) * sideOffset

			createPart(parent, "KeepCrenel" .. i .. "_" .. j,
				Vector3.new(4, 5, 4),
				baseCFrame * CFrame.new(xOff, keepHeight + 5.5, keepZ + zOff),
				COLORS.STONE)
		end
	end

	-- Keep torches
	createTorch(parent, baseCFrame * CFrame.new(-8, 12, keepZ + keepSize/2 + 2))
	createTorch(parent, baseCFrame * CFrame.new(8, 12, keepZ + keepSize/2 + 2))
end

--[[
	Main function to build the castle
]]
local function buildCastle(): Model
	print("[Castle] Building massive castle at", POSITION)

	local castle: Model = Instance.new("Model")
	castle.Name = "Castle"

	-- Create base CFrame
	local baseCFrame: CFrame = CFrame.new(POSITION) * CFrame.Angles(0, FACING_ANGLE, 0)

	-- Clear ground tiles where moat will be (must happen before moat creation)
	clearGroundForMoat(baseCFrame)

	-- Build all components
	createMoat(castle, baseCFrame)
	createWalls(castle, baseCFrame)

	-- Corner towers with staircases
	local halfSize: number = CASTLE_SIZE / 2
	createTower(castle, baseCFrame * CFrame.new(-halfSize, 0, -halfSize), "TowerSW")
	createTower(castle, baseCFrame * CFrame.new(halfSize, 0, -halfSize), "TowerSE")
	createTower(castle, baseCFrame * CFrame.new(-halfSize, 0, halfSize), "TowerNW")
	createTower(castle, baseCFrame * CFrame.new(halfSize, 0, halfSize), "TowerNE")

	createGatehouse(castle, baseCFrame)
	createCourtyard(castle, baseCFrame)
	createKeep(castle, baseCFrame)

	castle.Parent = Workspace

	print("[Castle] Castle complete!")
	return castle
end

-- Build the castle
buildCastle()
