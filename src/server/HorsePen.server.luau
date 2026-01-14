--[[
	HorsePen.server.luau

	Creates a pen with a horse and bale of hay.
]]

local Workspace = game:GetService("Workspace")

-- Configuration
local POSITION: Vector3 = Vector3.new(53, 0, 33)

-- Pen dimensions
local PEN_WIDTH: number = 18
local PEN_LENGTH: number = 22
local FENCE_HEIGHT: number = 4
local POST_SIZE: number = 1

-- Colors
local COLORS = {
	WOOD = Color3.fromRGB(101, 78, 50),
	WOOD_DARK = Color3.fromRGB(70, 52, 35),
	WOOD_LIGHT = Color3.fromRGB(130, 105, 70),
	HAY = Color3.fromRGB(195, 170, 90),
	DIRT = Color3.fromRGB(95, 75, 55),
	HORSE_BROWN = Color3.fromRGB(101, 67, 33),
	HORSE_DARK = Color3.fromRGB(60, 40, 25),
	HORSE_CREAM = Color3.fromRGB(180, 160, 130),
	MANE_BLACK = Color3.fromRGB(30, 25, 20),
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
	Creates a fence post
]]
local function createFencePost(parent: Instance, position: Vector3, name: string): ()
	createPart(parent, name,
		Vector3.new(POST_SIZE, FENCE_HEIGHT + 1, POST_SIZE),
		CFrame.new(position.X, FENCE_HEIGHT / 2 + 0.5, position.Z),
		COLORS.WOOD_DARK)
end

--[[
	Creates a fence rail between two posts
]]
local function createFenceRail(parent: Instance, pos1: Vector3, pos2: Vector3, height: number, name: string): ()
	local midX: number = (pos1.X + pos2.X) / 2
	local midZ: number = (pos1.Z + pos2.Z) / 2
	local length: number = math.sqrt((pos2.X - pos1.X)^2 + (pos2.Z - pos1.Z)^2)
	local angle: number = math.atan2(pos2.X - pos1.X, pos2.Z - pos1.Z)

	createPart(parent, name,
		Vector3.new(0.5, 0.8, length),
		CFrame.new(midX, height, midZ) * CFrame.Angles(0, angle, 0),
		COLORS.WOOD)
end

--[[
	Creates a hay bale
]]
local function createHayBale(parent: Instance, cframe: CFrame, size: Vector3): Part
	return createPart(parent, "HayBale", size, cframe, COLORS.HAY, Enum.Material.Grass)
end

--[[
	Creates the horse model
]]
local function createHorse(parent: Instance, baseCFrame: CFrame): Model
	local horse: Model = Instance.new("Model")
	horse.Name = "Horse"

	-- Body
	createPart(horse, "Body",
		Vector3.new(3.5, 3, 7),
		baseCFrame * CFrame.new(0, 4, 0),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	-- Chest (front body, slightly larger)
	createPart(horse, "Chest",
		Vector3.new(3.2, 3.2, 2),
		baseCFrame * CFrame.new(0, 4.1, 2.5),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	-- Hindquarters
	createPart(horse, "Hindquarters",
		Vector3.new(3.3, 3, 2),
		baseCFrame * CFrame.new(0, 4, -2.5),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	-- Neck
	createPart(horse, "Neck",
		Vector3.new(2, 4, 2),
		baseCFrame * CFrame.new(0, 5.5, 4) * CFrame.Angles(math.rad(-30), 0, 0),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	-- Head
	createPart(horse, "Head",
		Vector3.new(1.8, 2, 3.5),
		baseCFrame * CFrame.new(0, 7.5, 5.5) * CFrame.Angles(math.rad(-10), 0, 0),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	-- Snout
	createPart(horse, "Snout",
		Vector3.new(1.4, 1.2, 1.8),
		baseCFrame * CFrame.new(0, 6.8, 7),
		COLORS.HORSE_CREAM, Enum.Material.SmoothPlastic)

	-- Ears
	createPart(horse, "EarLeft",
		Vector3.new(0.4, 1, 0.3),
		baseCFrame * CFrame.new(-0.5, 8.8, 5) * CFrame.Angles(math.rad(-20), 0, math.rad(-15)),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	createPart(horse, "EarRight",
		Vector3.new(0.4, 1, 0.3),
		baseCFrame * CFrame.new(0.5, 8.8, 5) * CFrame.Angles(math.rad(-20), 0, math.rad(15)),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	-- Eyes
	createPart(horse, "EyeLeft",
		Vector3.new(0.4, 0.5, 0.4),
		baseCFrame * CFrame.new(-0.8, 7.8, 5.8),
		COLORS.MANE_BLACK, Enum.Material.SmoothPlastic)

	createPart(horse, "EyeRight",
		Vector3.new(0.4, 0.5, 0.4),
		baseCFrame * CFrame.new(0.8, 7.8, 5.8),
		COLORS.MANE_BLACK, Enum.Material.SmoothPlastic)

	-- Mane
	for i = 0, 5 do
		createPart(horse, "Mane" .. i,
			Vector3.new(0.6, 1.5, 1),
			baseCFrame * CFrame.new(0, 7 - i * 0.5, 4.5 - i * 0.6) * CFrame.Angles(math.rad(-30 + i * 5), 0, 0),
			COLORS.MANE_BLACK, Enum.Material.SmoothPlastic)
	end

	-- Front legs
	createPart(horse, "FrontLegLeft",
		Vector3.new(0.8, 4, 0.8),
		baseCFrame * CFrame.new(-1, 2, 2.5),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	createPart(horse, "FrontLegRight",
		Vector3.new(0.8, 4, 0.8),
		baseCFrame * CFrame.new(1, 2, 2.5),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	-- Back legs
	createPart(horse, "BackLegLeft",
		Vector3.new(0.9, 4, 0.9),
		baseCFrame * CFrame.new(-1, 2, -2.5),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	createPart(horse, "BackLegRight",
		Vector3.new(0.9, 4, 0.9),
		baseCFrame * CFrame.new(1, 2, -2.5),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	-- Hooves
	createPart(horse, "HoofFL",
		Vector3.new(0.9, 0.6, 0.9),
		baseCFrame * CFrame.new(-1, 0.3, 2.5),
		COLORS.HORSE_DARK, Enum.Material.SmoothPlastic)

	createPart(horse, "HoofFR",
		Vector3.new(0.9, 0.6, 0.9),
		baseCFrame * CFrame.new(1, 0.3, 2.5),
		COLORS.HORSE_DARK, Enum.Material.SmoothPlastic)

	createPart(horse, "HoofBL",
		Vector3.new(1, 0.6, 1),
		baseCFrame * CFrame.new(-1, 0.3, -2.5),
		COLORS.HORSE_DARK, Enum.Material.SmoothPlastic)

	createPart(horse, "HoofBR",
		Vector3.new(1, 0.6, 1),
		baseCFrame * CFrame.new(1, 0.3, -2.5),
		COLORS.HORSE_DARK, Enum.Material.SmoothPlastic)

	-- Tail
	createPart(horse, "TailBase",
		Vector3.new(0.6, 0.6, 1.5),
		baseCFrame * CFrame.new(0, 4.5, -4) * CFrame.Angles(math.rad(30), 0, 0),
		COLORS.HORSE_BROWN, Enum.Material.SmoothPlastic)

	createPart(horse, "Tail",
		Vector3.new(0.8, 3, 0.8),
		baseCFrame * CFrame.new(0, 3, -5) * CFrame.Angles(math.rad(15), 0, 0),
		COLORS.MANE_BLACK, Enum.Material.SmoothPlastic)

	horse.Parent = parent
	return horse
end

--[[
	Builds the pen
]]
local function buildPen(): Model
	print("[HorsePen] Building horse pen at", POSITION)

	local pen: Model = Instance.new("Model")
	pen.Name = "HorsePen"

	local baseCFrame: CFrame = CFrame.new(POSITION)
	local halfWidth: number = PEN_WIDTH / 2
	local halfLength: number = PEN_LENGTH / 2

	-- Dirt floor
	createPart(pen, "Floor",
		Vector3.new(PEN_WIDTH, 0.5, PEN_LENGTH),
		baseCFrame * CFrame.new(0, 0.25, 0),
		COLORS.DIRT, Enum.Material.Ground)

	-- Fence posts at corners and intervals
	local postPositions = {
		-- Corners
		Vector3.new(POSITION.X - halfWidth, 0, POSITION.Z - halfLength),
		Vector3.new(POSITION.X + halfWidth, 0, POSITION.Z - halfLength),
		Vector3.new(POSITION.X - halfWidth, 0, POSITION.Z + halfLength),
		Vector3.new(POSITION.X + halfWidth, 0, POSITION.Z + halfLength),
		-- Middle posts
		Vector3.new(POSITION.X, 0, POSITION.Z - halfLength),
		Vector3.new(POSITION.X, 0, POSITION.Z + halfLength),
		Vector3.new(POSITION.X - halfWidth, 0, POSITION.Z),
		Vector3.new(POSITION.X + halfWidth, 0, POSITION.Z),
	}

	for i, pos in ipairs(postPositions) do
		createFencePost(pen, pos, "Post" .. i)
	end

	-- Fence rails (two horizontal rails per section)
	local railHeights = {1.5, 3}

	for _, railHeight in ipairs(railHeights) do
		-- North fence
		createFenceRail(pen, postPositions[1], postPositions[5], railHeight, "RailN1_" .. railHeight)
		createFenceRail(pen, postPositions[5], postPositions[2], railHeight, "RailN2_" .. railHeight)

		-- South fence
		createFenceRail(pen, postPositions[3], postPositions[6], railHeight, "RailS1_" .. railHeight)
		createFenceRail(pen, postPositions[6], postPositions[4], railHeight, "RailS2_" .. railHeight)

		-- West fence
		createFenceRail(pen, postPositions[1], postPositions[7], railHeight, "RailW1_" .. railHeight)
		createFenceRail(pen, postPositions[7], postPositions[3], railHeight, "RailW2_" .. railHeight)

		-- East fence
		createFenceRail(pen, postPositions[2], postPositions[8], railHeight, "RailE1_" .. railHeight)
		createFenceRail(pen, postPositions[8], postPositions[4], railHeight, "RailE2_" .. railHeight)
	end

	-- Create the horse (facing slightly toward center)
	local horseCFrame: CFrame = baseCFrame * CFrame.new(3, 0, -3) * CFrame.Angles(0, math.rad(-30), 0)
	createHorse(pen, horseCFrame)

	-- Hay bale
	createHayBale(pen,
		baseCFrame * CFrame.new(-5, 1.5, 4),
		Vector3.new(4, 3, 3))

	-- Scattered hay on ground
	createHayBale(pen,
		baseCFrame * CFrame.new(-4, 0.4, 5) * CFrame.Angles(0, math.rad(25), 0),
		Vector3.new(2, 0.8, 1.5))

	createHayBale(pen,
		baseCFrame * CFrame.new(-6, 0.35, 3) * CFrame.Angles(0, math.rad(-15), 0),
		Vector3.new(1.5, 0.7, 1))

	-- Water trough
	createPart(pen, "Trough",
		Vector3.new(4, 1.5, 2),
		baseCFrame * CFrame.new(5, 0.75, -5),
		COLORS.WOOD_DARK)

	createPart(pen, "TroughWater",
		Vector3.new(3.5, 1, 1.5),
		baseCFrame * CFrame.new(5, 0.9, -5),
		Color3.fromRGB(60, 80, 100), Enum.Material.Glass)

	pen.Parent = Workspace

	print("[HorsePen] Horse pen complete!")
	return pen
end

-- Build the pen
buildPen()
