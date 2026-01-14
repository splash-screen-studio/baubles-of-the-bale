--[[
	Baubles.server.luau

	Creates big colorful balls falling from the sky.
]]

local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local BASE_SPAWN_INTERVAL: number = 0.5 -- 60% of original rate (was 0.3)
local MIN_SPAWN_INTERVAL: number = 0.15 -- Fastest spawn rate at high scores
local SPAWN_HEIGHT: number = 200 -- How high baubles spawn
local SPAWN_RADIUS: number = 300 -- Horizontal spawn area radius
local SPAWN_CENTER: Vector3 = Vector3.new(50, 0, -100) -- Center of spawn area
local BAUBLE_LIFETIME: number = 30 -- Seconds before bauble despawns
local MIN_SIZE: number = 3
local MAX_SIZE: number = 8

-- Vibrant colors for the baubles
local COLORS = {
	-- Reds and pinks
	Color3.fromRGB(255, 50, 50),
	Color3.fromRGB(255, 100, 150),
	Color3.fromRGB(220, 20, 60),
	Color3.fromRGB(255, 69, 0),

	-- Oranges and yellows
	Color3.fromRGB(255, 165, 0),
	Color3.fromRGB(255, 215, 0),
	Color3.fromRGB(255, 255, 100),
	Color3.fromRGB(255, 200, 50),

	-- Greens
	Color3.fromRGB(50, 255, 50),
	Color3.fromRGB(0, 255, 127),
	Color3.fromRGB(127, 255, 0),
	Color3.fromRGB(0, 200, 100),

	-- Blues and cyans
	Color3.fromRGB(50, 150, 255),
	Color3.fromRGB(0, 255, 255),
	Color3.fromRGB(100, 100, 255),
	Color3.fromRGB(65, 105, 225),

	-- Purples and magentas
	Color3.fromRGB(200, 50, 255),
	Color3.fromRGB(255, 0, 255),
	Color3.fromRGB(148, 0, 211),
	Color3.fromRGB(186, 85, 211),

	-- Special colors
	Color3.fromRGB(255, 255, 255), -- White
	Color3.fromRGB(255, 215, 180), -- Peach
	Color3.fromRGB(64, 224, 208), -- Turquoise
	Color3.fromRGB(255, 182, 193), -- Light pink
}

-- Materials for variety
local MATERIALS = {
	Enum.Material.Neon,
	Enum.Material.Glass,
	Enum.Material.SmoothPlastic,
	Enum.Material.Foil,
}

-- Container for baubles
local baublesFolder: Folder = Instance.new("Folder")
baublesFolder.Name = "Baubles"
baublesFolder.Parent = Workspace

--[[
	Creates a single bauble at a random position
]]
local function spawnBauble(): ()
	local bauble: Part = Instance.new("Part")
	bauble.Name = "Bauble"
	bauble.Shape = Enum.PartType.Ball

	-- Random size
	local size: number = MIN_SIZE + math.random() * (MAX_SIZE - MIN_SIZE)
	bauble.Size = Vector3.new(size, size, size)

	-- Random position within spawn radius
	local angle: number = math.random() * math.pi * 2
	local distance: number = math.random() * SPAWN_RADIUS
	local x: number = SPAWN_CENTER.X + math.cos(angle) * distance
	local z: number = SPAWN_CENTER.Z + math.sin(angle) * distance
	bauble.Position = Vector3.new(x, SPAWN_HEIGHT, z)

	-- Random color
	bauble.Color = COLORS[math.random(1, #COLORS)]

	-- Random material (weighted toward Neon for glow)
	if math.random() < 0.6 then
		bauble.Material = Enum.Material.Neon
	else
		bauble.Material = MATERIALS[math.random(1, #MATERIALS)]
	end

	-- Physics properties
	bauble.Anchored = false
	bauble.CanCollide = true
	bauble.CustomPhysicalProperties = PhysicalProperties.new(
		0.3, -- Density (light)
		0.5, -- Friction
		0.8, -- Elasticity (bouncy!)
		1, -- FrictionWeight
		1 -- ElasticityWeight
	)

	-- Add some initial random spin
	bauble.Parent = baublesFolder

	local angularVelocity: AngularVelocity = Instance.new("AngularVelocity")
	angularVelocity.Attachment0 = Instance.new("Attachment", bauble)
	angularVelocity.AngularVelocity = Vector3.new(
		(math.random() - 0.5) * 5,
		(math.random() - 0.5) * 5,
		(math.random() - 0.5) * 5
	)
	angularVelocity.MaxTorque = 1000
	angularVelocity.Parent = bauble

	-- Add subtle point light for neon baubles
	if bauble.Material == Enum.Material.Neon then
		local light: PointLight = Instance.new("PointLight")
		light.Color = bauble.Color
		light.Brightness = 0.8
		light.Range = size * 2
		light.Parent = bauble
	end

	-- Auto-cleanup
	Debris:AddItem(bauble, BAUBLE_LIFETIME)
end

-- Track highest score for spawn rate boost
local highestPlayerScore: number = 0

--[[
	Get current spawn interval based on highest player score
	Starts at 0.5s (60% rate), speeds up to 0.15s at score 50+
]]
local function getSpawnInterval(): number
	if highestPlayerScore >= 50 then
		return MIN_SPAWN_INTERVAL
	elseif highestPlayerScore >= 5 then
		-- Linear from 0.5 at 5 to 0.15 at 50
		return BASE_SPAWN_INTERVAL - (highestPlayerScore - 5) * (0.35 / 45)
	else
		return BASE_SPAWN_INTERVAL
	end
end

-- BindableEvent for other scripts to trigger extra spawns
local spawnBaublesEvent: BindableEvent = Instance.new("BindableEvent")
spawnBaublesEvent.Name = "SpawnBaubles"
spawnBaublesEvent.Parent = ReplicatedStorage

-- Listen for spawn requests (e.g., 2-for-1 on zap)
spawnBaublesEvent.Event:Connect(function(count: number, newHighScore: number?)
	-- Update highest score if provided
	if newHighScore and newHighScore > highestPlayerScore then
		highestPlayerScore = newHighScore
	end

	-- Spawn requested number of baubles
	for i = 1, count do
		spawnBauble()
	end
end)

--[[
	Main spawning loop
]]
local function startBaubleRain(): ()
	print("[Baubles] Starting colorful bauble rain!")

	while true do
		spawnBauble()
		task.wait(getSpawnInterval())
	end
end

-- Start the bauble rain
task.spawn(startBaubleRain)
