--[[
	Shacks.server.luau

	Creates various medieval shacks around the village.
]]

local Workspace = game:GetService("Workspace")

-- Shack positions and styles
local SHACKS: {{position: Vector3, style: string}} = {
	{ position = Vector3.new(-188, 0, -14), style = "weathered" },
	{ position = Vector3.new(-148, 0, -20), style = "thatched" },
	{ position = Vector3.new(-133, 0, 23), style = "patched" },
}

-- Colors for different styles
local COLORS = {
	-- Weathered style (old, grey wood)
	weathered = {
		WALL = Color3.fromRGB(90, 85, 75),
		WALL_ACCENT = Color3.fromRGB(75, 70, 62),
		ROOF = Color3.fromRGB(60, 58, 52),
		DOOR = Color3.fromRGB(70, 55, 40),
		TRIM = Color3.fromRGB(55, 50, 45),
	},
	-- Thatched style (warm brown, straw roof)
	thatched = {
		WALL = Color3.fromRGB(120, 95, 65),
		WALL_ACCENT = Color3.fromRGB(105, 82, 55),
		ROOF = Color3.fromRGB(180, 155, 90),
		DOOR = Color3.fromRGB(85, 60, 40),
		TRIM = Color3.fromRGB(70, 50, 35),
	},
	-- Patched style (mixed materials, repairs visible)
	patched = {
		WALL = Color3.fromRGB(110, 90, 70),
		WALL_ACCENT = Color3.fromRGB(85, 80, 72),
		ROOF = Color3.fromRGB(75, 65, 55),
		DOOR = Color3.fromRGB(60, 45, 30),
		TRIM = Color3.fromRGB(100, 85, 65),
	},
}

-- Torch colors
local TORCH_LIGHT: Color3 = Color3.fromRGB(255, 147, 41)

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
local function createTorch(parent: Instance, position: Vector3): ()
	local handle: Part = Instance.new("Part")
	handle.Name = "TorchHandle"
	handle.Size = Vector3.new(0.5, 2.5, 0.5)
	handle.Position = position + Vector3.new(0, 1.25, 0)
	handle.Anchored = true
	handle.Color = Color3.fromRGB(79, 52, 26)
	handle.Material = Enum.Material.Wood
	handle.Parent = parent

	local head: Part = Instance.new("Part")
	head.Name = "TorchHead"
	head.Size = Vector3.new(0.6, 0.5, 0.6)
	head.Position = position + Vector3.new(0, 2.75, 0)
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
	light.Color = TORCH_LIGHT
	light.Brightness = 1.5
	light.Range = 20
	light.Shadows = true
	light.Parent = head
end

--[[
	Creates a weathered shack (old, tilted, worn)
]]
local function createWeatheredShack(parent: Instance, baseCFrame: CFrame, colors: any): ()
	local width: number = 12
	local depth: number = 10
	local height: number = 8
	local tilt: CFrame = CFrame.Angles(math.rad(2), 0, math.rad(-1.5))

	-- Slightly tilted base frame
	local tiltedCFrame: CFrame = baseCFrame * tilt

	-- Floor
	createPart(parent, "Floor",
		Vector3.new(width, 1, depth),
		baseCFrame * CFrame.new(0, 0.5, 0),
		colors.TRIM, Enum.Material.Wood)

	-- Walls (weathered planks)
	createPart(parent, "WallBack",
		Vector3.new(width, height, 1),
		tiltedCFrame * CFrame.new(0, height/2 + 1, -depth/2 + 0.5),
		colors.WALL, Enum.Material.Wood)

	createPart(parent, "WallLeft",
		Vector3.new(1, height, depth - 1),
		tiltedCFrame * CFrame.new(-width/2 + 0.5, height/2 + 1, 0),
		colors.WALL_ACCENT, Enum.Material.Wood)

	createPart(parent, "WallRight",
		Vector3.new(1, height, depth - 1),
		tiltedCFrame * CFrame.new(width/2 - 0.5, height/2 + 1, 0),
		colors.WALL, Enum.Material.Wood)

	-- Front wall with door gap
	createPart(parent, "WallFrontLeft",
		Vector3.new(4, height, 1),
		tiltedCFrame * CFrame.new(-width/4 - 1, height/2 + 1, depth/2 - 0.5),
		colors.WALL_ACCENT, Enum.Material.Wood)

	createPart(parent, "WallFrontRight",
		Vector3.new(4, height, 1),
		tiltedCFrame * CFrame.new(width/4 + 1, height/2 + 1, depth/2 - 0.5),
		colors.WALL, Enum.Material.Wood)

	createPart(parent, "WallFrontTop",
		Vector3.new(4, 2, 1),
		tiltedCFrame * CFrame.new(0, height, depth/2 - 0.5),
		colors.WALL, Enum.Material.Wood)

	-- Crooked door
	createPart(parent, "Door",
		Vector3.new(3.5, 6, 0.5),
		tiltedCFrame * CFrame.new(0.2, 4, depth/2) * CFrame.Angles(0, math.rad(15), 0),
		colors.DOOR, Enum.Material.Wood)

	-- Slanted roof
	local roofWedge1: WedgePart = Instance.new("WedgePart")
	roofWedge1.Name = "RoofLeft"
	roofWedge1.Size = Vector3.new(depth + 2, 4, width/2 + 2)
	roofWedge1.CFrame = tiltedCFrame * CFrame.new(-width/4, height + 3, 0) * CFrame.Angles(0, math.rad(-90), 0)
	roofWedge1.Anchored = true
	roofWedge1.Color = colors.ROOF
	roofWedge1.Material = Enum.Material.Wood
	roofWedge1.Parent = parent

	local roofWedge2: WedgePart = Instance.new("WedgePart")
	roofWedge2.Name = "RoofRight"
	roofWedge2.Size = Vector3.new(depth + 2, 4, width/2 + 2)
	roofWedge2.CFrame = tiltedCFrame * CFrame.new(width/4, height + 3, 0) * CFrame.Angles(0, math.rad(90), 0)
	roofWedge2.Anchored = true
	roofWedge2.Color = colors.ROOF
	roofWedge2.Material = Enum.Material.Wood
	roofWedge2.Parent = parent

	-- Torch outside
	createTorch(parent, baseCFrame:PointToWorldSpace(Vector3.new(width/2 + 2, 0, depth/2 - 2)))
end

--[[
	Creates a thatched shack (round-ish, warm, straw roof)
]]
local function createThatchedShack(parent: Instance, baseCFrame: CFrame, colors: any): ()
	local width: number = 14
	local depth: number = 12
	local height: number = 7
	local roofHeight: number = 6

	-- Floor
	createPart(parent, "Floor",
		Vector3.new(width, 1, depth),
		baseCFrame * CFrame.new(0, 0.5, 0),
		colors.TRIM, Enum.Material.Wood)

	-- Walls (warmer wood)
	createPart(parent, "WallBack",
		Vector3.new(width, height, 1.5),
		baseCFrame * CFrame.new(0, height/2 + 1, -depth/2 + 0.75),
		colors.WALL, Enum.Material.Wood)

	createPart(parent, "WallLeft",
		Vector3.new(1.5, height, depth - 1.5),
		baseCFrame * CFrame.new(-width/2 + 0.75, height/2 + 1, 0),
		colors.WALL, Enum.Material.Wood)

	createPart(parent, "WallRight",
		Vector3.new(1.5, height, depth - 1.5),
		baseCFrame * CFrame.new(width/2 - 0.75, height/2 + 1, 0),
		colors.WALL_ACCENT, Enum.Material.Wood)

	-- Front wall with door and window
	createPart(parent, "WallFrontLeft",
		Vector3.new(4, height, 1.5),
		baseCFrame * CFrame.new(-width/4 - 1.5, height/2 + 1, depth/2 - 0.75),
		colors.WALL, Enum.Material.Wood)

	createPart(parent, "WallFrontRight",
		Vector3.new(4, height, 1.5),
		baseCFrame * CFrame.new(width/4 + 1.5, height/2 + 1, depth/2 - 0.75),
		colors.WALL, Enum.Material.Wood)

	createPart(parent, "WallFrontTop",
		Vector3.new(5, 2, 1.5),
		baseCFrame * CFrame.new(0, height, depth/2 - 0.75),
		colors.WALL_ACCENT, Enum.Material.Wood)

	-- Door
	createPart(parent, "Door",
		Vector3.new(4, 5.5, 0.8),
		baseCFrame * CFrame.new(0, 3.75, depth/2),
		colors.DOOR, Enum.Material.Wood)

	-- Window on side
	createPart(parent, "WindowFrame",
		Vector3.new(1.6, 3, 3),
		baseCFrame * CFrame.new(width/2 - 0.7, 5, -2),
		colors.TRIM, Enum.Material.Wood)

	createPart(parent, "WindowGlass",
		Vector3.new(0.5, 2, 2),
		baseCFrame * CFrame.new(width/2 - 0.7, 5, -2),
		Color3.fromRGB(150, 170, 180), Enum.Material.Glass)

	-- Thick thatched roof (straw-like)
	local roofWedge1: WedgePart = Instance.new("WedgePart")
	roofWedge1.Name = "RoofLeft"
	roofWedge1.Size = Vector3.new(depth + 4, roofHeight, width/2 + 3)
	roofWedge1.CFrame = baseCFrame * CFrame.new(-width/4 - 0.5, height + roofHeight/2 + 1, 0) * CFrame.Angles(0, math.rad(-90), 0)
	roofWedge1.Anchored = true
	roofWedge1.Color = colors.ROOF
	roofWedge1.Material = Enum.Material.Grass
	roofWedge1.Parent = parent

	local roofWedge2: WedgePart = Instance.new("WedgePart")
	roofWedge2.Name = "RoofRight"
	roofWedge2.Size = Vector3.new(depth + 4, roofHeight, width/2 + 3)
	roofWedge2.CFrame = baseCFrame * CFrame.new(width/4 + 0.5, height + roofHeight/2 + 1, 0) * CFrame.Angles(0, math.rad(90), 0)
	roofWedge2.Anchored = true
	roofWedge2.Color = colors.ROOF
	roofWedge2.Material = Enum.Material.Grass
	roofWedge2.Parent = parent

	-- Chimney
	createPart(parent, "Chimney",
		Vector3.new(2, 5, 2),
		baseCFrame * CFrame.new(-3, height + roofHeight - 1, -2),
		Color3.fromRGB(120, 110, 100), Enum.Material.Cobblestone)

	-- Torch outside
	createTorch(parent, baseCFrame:PointToWorldSpace(Vector3.new(-width/2 - 2, 0, 2)))
end

--[[
	Creates a patched shack (mixed materials, makeshift repairs)
]]
local function createPatchedShack(parent: Instance, baseCFrame: CFrame, colors: any): ()
	local width: number = 10
	local depth: number = 11
	local height: number = 7

	-- Floor (uneven)
	createPart(parent, "Floor",
		Vector3.new(width, 1, depth),
		baseCFrame * CFrame.new(0, 0.5, 0),
		colors.TRIM, Enum.Material.Wood)

	-- Main walls with patches
	createPart(parent, "WallBack",
		Vector3.new(width, height, 1),
		baseCFrame * CFrame.new(0, height/2 + 1, -depth/2 + 0.5),
		colors.WALL, Enum.Material.Wood)

	-- Patch on back wall
	createPart(parent, "PatchBack",
		Vector3.new(3, 3, 1.1),
		baseCFrame * CFrame.new(2, 5, -depth/2 + 0.5),
		colors.WALL_ACCENT, Enum.Material.WoodPlanks)

	createPart(parent, "WallLeft",
		Vector3.new(1, height, depth - 1),
		baseCFrame * CFrame.new(-width/2 + 0.5, height/2 + 1, 0),
		colors.WALL, Enum.Material.Wood)

	createPart(parent, "WallRight",
		Vector3.new(1, height - 2, depth - 1),
		baseCFrame * CFrame.new(width/2 - 0.5, (height-2)/2 + 1, 0),
		colors.WALL_ACCENT, Enum.Material.Wood)

	-- Patched upper right wall (different material)
	createPart(parent, "WallRightPatch",
		Vector3.new(1.2, 2.5, depth - 1),
		baseCFrame * CFrame.new(width/2 - 0.5, height - 0.25, 0),
		colors.TRIM, Enum.Material.WoodPlanks)

	-- Front wall
	createPart(parent, "WallFrontLeft",
		Vector3.new(3, height, 1),
		baseCFrame * CFrame.new(-width/4 - 1, height/2 + 1, depth/2 - 0.5),
		colors.WALL, Enum.Material.Wood)

	createPart(parent, "WallFrontRight",
		Vector3.new(3, height, 1),
		baseCFrame * CFrame.new(width/4 + 1, height/2 + 1, depth/2 - 0.5),
		colors.WALL_ACCENT, Enum.Material.Wood)

	createPart(parent, "WallFrontTop",
		Vector3.new(4, 2, 1),
		baseCFrame * CFrame.new(0, height, depth/2 - 0.5),
		colors.WALL, Enum.Material.Wood)

	-- Makeshift door (planks)
	createPart(parent, "DoorMain",
		Vector3.new(3, 5, 0.5),
		baseCFrame * CFrame.new(0, 3.5, depth/2),
		colors.DOOR, Enum.Material.Wood)

	createPart(parent, "DoorBrace",
		Vector3.new(3.5, 0.8, 0.6),
		baseCFrame * CFrame.new(0, 4, depth/2 + 0.1),
		colors.TRIM, Enum.Material.Wood)

	-- Uneven roof (one side higher)
	local roofWedge1: WedgePart = Instance.new("WedgePart")
	roofWedge1.Name = "RoofMain"
	roofWedge1.Size = Vector3.new(depth + 2, 5, width + 3)
	roofWedge1.CFrame = baseCFrame * CFrame.new(0.5, height + 3.5, 0) * CFrame.Angles(0, math.rad(-90), 0)
	roofWedge1.Anchored = true
	roofWedge1.Color = colors.ROOF
	roofWedge1.Material = Enum.Material.Wood
	roofWedge1.Parent = parent

	-- Tarp/patch on roof
	createPart(parent, "RoofPatch",
		Vector3.new(4, 0.3, 5),
		baseCFrame * CFrame.new(2, height + 2, 2) * CFrame.Angles(math.rad(-25), 0, 0),
		Color3.fromRGB(100, 90, 70), Enum.Material.Fabric)

	-- Barrel outside
	local barrel: Part = Instance.new("Part")
	barrel.Name = "Barrel"
	barrel.Shape = Enum.PartType.Cylinder
	barrel.Size = Vector3.new(4, 3, 3)
	barrel.CFrame = baseCFrame * CFrame.new(width/2 + 2.5, 2, -2) * CFrame.Angles(0, 0, math.rad(90))
	barrel.Anchored = true
	barrel.Color = Color3.fromRGB(100, 70, 45)
	barrel.Material = Enum.Material.Wood
	barrel.Parent = parent

	-- Torch
	createTorch(parent, baseCFrame:PointToWorldSpace(Vector3.new(-width/2 - 2, 0, depth/2 - 2)))
end

--[[
	Builds all shacks
]]
local function buildShacks(): ()
	print("[Shacks] Building village shacks...")

	local shacksFolder: Folder = Instance.new("Folder")
	shacksFolder.Name = "Shacks"
	shacksFolder.Parent = Workspace

	for i, shackData in SHACKS do
		local shack: Model = Instance.new("Model")
		shack.Name = "Shack_" .. shackData.style

		local baseCFrame: CFrame = CFrame.new(shackData.position)
		local colors = COLORS[shackData.style]

		if shackData.style == "weathered" then
			createWeatheredShack(shack, baseCFrame, colors)
		elseif shackData.style == "thatched" then
			createThatchedShack(shack, baseCFrame, colors)
		elseif shackData.style == "patched" then
			createPatchedShack(shack, baseCFrame, colors)
		end

		shack.Parent = shacksFolder
		print("[Shacks] Built", shackData.style, "shack at", shackData.position)
	end

	print("[Shacks] All shacks complete!")
end

-- Build the shacks
buildShacks()
