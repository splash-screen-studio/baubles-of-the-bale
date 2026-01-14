--[[
	Stables.server.luau

	Creates medieval horse stables.
]]

local Workspace = game:GetService("Workspace")

-- Stables configuration
local POSITION: Vector3 = Vector3.new(94, 0, 68)
local FACING_ANGLE: number = math.rad(-45) -- Angled toward village center

-- Dimensions
local STABLE_LENGTH: number = 36
local STABLE_WIDTH: number = 20
local WALL_HEIGHT: number = 12
local STALL_COUNT: number = 4
local STALL_WIDTH: number = 8

-- Colors
local COLORS = {
	WOOD = Color3.fromRGB(101, 78, 50),
	WOOD_DARK = Color3.fromRGB(70, 52, 35),
	WOOD_LIGHT = Color3.fromRGB(130, 100, 65),
	HAY = Color3.fromRGB(195, 170, 90),
	ROOF = Color3.fromRGB(80, 65, 50),
	DIRT = Color3.fromRGB(95, 75, 55),
	IRON = Color3.fromRGB(60, 60, 65),
	TORCH_LIGHT = Color3.fromRGB(255, 147, 41),
}

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
	Creates a hay bale
]]
local function createHayBale(parent: Instance, cframe: CFrame, size: Vector3?): Part
	local baleSize: Vector3 = size or Vector3.new(3, 2, 2)
	return createPart(parent, "HayBale", baleSize, cframe, COLORS.HAY, Enum.Material.Grass)
end

--[[
	Creates a single stall with divider, hay, and trough
]]
local function createStall(parent: Instance, baseCFrame: CFrame, stallIndex: number): ()
	local stallOffset: number = (stallIndex - 0.5) * STALL_WIDTH - (STALL_COUNT * STALL_WIDTH / 2)

	-- Stall divider (wooden partition)
	if stallIndex < STALL_COUNT then
		createPart(parent, "StallDivider" .. stallIndex,
			Vector3.new(1, WALL_HEIGHT - 4, STABLE_WIDTH - 4),
			baseCFrame * CFrame.new(stallOffset + STALL_WIDTH / 2, (WALL_HEIGHT - 4) / 2 + 1, 0),
			COLORS.WOOD_DARK)
	end

	-- Stall floor (dirt)
	createPart(parent, "StallFloor" .. stallIndex,
		Vector3.new(STALL_WIDTH - 1, 0.5, STABLE_WIDTH - 4),
		baseCFrame * CFrame.new(stallOffset, 0.25, 0),
		COLORS.DIRT, Enum.Material.Ground)

	-- Hay pile in corner
	createHayBale(parent,
		baseCFrame * CFrame.new(stallOffset - STALL_WIDTH / 4, 1, -STABLE_WIDTH / 2 + 4),
		Vector3.new(3, 2, 3))

	-- Water/feed trough
	createPart(parent, "Trough" .. stallIndex,
		Vector3.new(4, 1.5, 2),
		baseCFrame * CFrame.new(stallOffset, 1.5, -STABLE_WIDTH / 2 + 2.5),
		COLORS.WOOD_DARK)

	-- Trough interior (darker)
	createPart(parent, "TroughInner" .. stallIndex,
		Vector3.new(3.5, 1, 1.5),
		baseCFrame * CFrame.new(stallOffset, 1.6, -STABLE_WIDTH / 2 + 2.5),
		Color3.fromRGB(40, 55, 65), Enum.Material.Metal)

	-- Hitching ring on back wall
	createPart(parent, "HitchRing" .. stallIndex,
		Vector3.new(0.8, 0.8, 0.3),
		baseCFrame * CFrame.new(stallOffset, 5, -STABLE_WIDTH / 2 + 1.2),
		COLORS.IRON, Enum.Material.Metal)
end

--[[
	Builds the stables
]]
local function buildStables(): Model
	print("[Stables] Building stables at", POSITION)

	local stables: Model = Instance.new("Model")
	stables.Name = "Stables"

	local baseCFrame: CFrame = CFrame.new(POSITION) * CFrame.Angles(0, FACING_ANGLE, 0)

	-- Main floor
	createPart(stables, "MainFloor",
		Vector3.new(STABLE_LENGTH, 1, STABLE_WIDTH),
		baseCFrame * CFrame.new(0, 0.5, 0),
		COLORS.DIRT, Enum.Material.Ground)

	-- Back wall
	createPart(stables, "WallBack",
		Vector3.new(STABLE_LENGTH, WALL_HEIGHT, 1.5),
		baseCFrame * CFrame.new(0, WALL_HEIGHT / 2, -STABLE_WIDTH / 2 + 0.75),
		COLORS.WOOD)

	-- Side walls (partial height, open top for ventilation)
	createPart(stables, "WallLeft",
		Vector3.new(1.5, WALL_HEIGHT, STABLE_WIDTH - 1.5),
		baseCFrame * CFrame.new(-STABLE_LENGTH / 2 + 0.75, WALL_HEIGHT / 2, 0),
		COLORS.WOOD)

	createPart(stables, "WallRight",
		Vector3.new(1.5, WALL_HEIGHT, STABLE_WIDTH - 1.5),
		baseCFrame * CFrame.new(STABLE_LENGTH / 2 - 0.75, WALL_HEIGHT / 2, 0),
		COLORS.WOOD)

	-- Front half-wall (horses can look out)
	createPart(stables, "WallFrontLower",
		Vector3.new(STABLE_LENGTH, 5, 1.5),
		baseCFrame * CFrame.new(0, 2.5, STABLE_WIDTH / 2 - 0.75),
		COLORS.WOOD)

	-- Front posts (supporting roof)
	for i = 0, STALL_COUNT do
		local postX: number = i * STALL_WIDTH - (STALL_COUNT * STALL_WIDTH / 2)
		createPart(stables, "FrontPost" .. i,
			Vector3.new(1.5, WALL_HEIGHT, 1.5),
			baseCFrame * CFrame.new(postX, WALL_HEIGHT / 2, STABLE_WIDTH / 2 - 0.75),
			COLORS.WOOD_DARK)
	end

	-- Roof beams
	createPart(stables, "RoofBeamFront",
		Vector3.new(STABLE_LENGTH + 2, 1, 2),
		baseCFrame * CFrame.new(0, WALL_HEIGHT + 0.5, STABLE_WIDTH / 2),
		COLORS.WOOD_DARK)

	createPart(stables, "RoofBeamBack",
		Vector3.new(STABLE_LENGTH + 2, 1, 2),
		baseCFrame * CFrame.new(0, WALL_HEIGHT + 2.5, -STABLE_WIDTH / 2),
		COLORS.WOOD_DARK)

	-- Slanted roof
	local roofLength: number = STABLE_LENGTH + 4
	local roofWidth: number = STABLE_WIDTH + 6

	local roofPart: Part = createPart(stables, "Roof",
		Vector3.new(roofLength, 1.5, roofWidth),
		baseCFrame * CFrame.new(0, WALL_HEIGHT + 2, 0) * CFrame.Angles(math.rad(8), 0, 0),
		COLORS.ROOF)
	roofPart.Material = Enum.Material.Wood

	-- Roof overhang supports
	createPart(stables, "RoofSupportLeft",
		Vector3.new(1, 3, 1),
		baseCFrame * CFrame.new(-STABLE_LENGTH / 2, WALL_HEIGHT - 1, STABLE_WIDTH / 2 + 1),
		COLORS.WOOD_DARK)

	createPart(stables, "RoofSupportRight",
		Vector3.new(1, 3, 1),
		baseCFrame * CFrame.new(STABLE_LENGTH / 2, WALL_HEIGHT - 1, STABLE_WIDTH / 2 + 1),
		COLORS.WOOD_DARK)

	-- Create individual stalls
	for i = 1, STALL_COUNT do
		createStall(stables, baseCFrame, i)
	end

	-- Extra hay storage in corner
	createHayBale(stables,
		baseCFrame * CFrame.new(-STABLE_LENGTH / 2 + 3, 1.5, STABLE_WIDTH / 2 - 3),
		Vector3.new(4, 3, 4))

	createHayBale(stables,
		baseCFrame * CFrame.new(-STABLE_LENGTH / 2 + 3, 4, STABLE_WIDTH / 2 - 3),
		Vector3.new(3, 2, 3))

	-- Pitchfork leaning against wall
	createPart(stables, "PitchforkHandle",
		Vector3.new(0.3, 6, 0.3),
		baseCFrame * CFrame.new(STABLE_LENGTH / 2 - 2, 3, STABLE_WIDTH / 2 - 2) * CFrame.Angles(math.rad(15), 0, 0),
		COLORS.WOOD_LIGHT)

	-- Torches
	createTorch(stables, baseCFrame * CFrame.new(-STABLE_LENGTH / 2 + 2, 0, STABLE_WIDTH / 2 + 2))
	createTorch(stables, baseCFrame * CFrame.new(STABLE_LENGTH / 2 - 2, 0, STABLE_WIDTH / 2 + 2))
	createTorch(stables, baseCFrame * CFrame.new(0, 0, -STABLE_WIDTH / 2 - 2))

	stables.Parent = Workspace

	print("[Stables] Stables complete!")
	return stables
end

-- Build the stables
buildStables()
