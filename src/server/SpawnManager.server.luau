--[[
	SpawnManager.server.luau

	Enforces spawn location rules to prevent regressions.

	CRITICAL: Players must always spawn at X:0, Z:100

	This script:
	1. Removes any unauthorized SpawnLocations
	2. Ensures the correct spawn exists at (0, 3, 100)
	3. Logs warnings if spawn configuration was incorrect
]]

local Workspace = game:GetService("Workspace")

-- CANONICAL SPAWN CONFIGURATION
-- This is the single source of truth for spawn location
-- IMPORTANT: Keep in sync with default.project.json and Tests/SpawnLocation.spec.luau
local SPAWN_CONFIG = {
	Position = Vector3.new(0, 1, 100),
	Size = Vector3.new(8, 1, 8),
	Name = "SpawnLocation",
}

-- Tolerance for position comparison
local POSITION_TOLERANCE: number = 0.5

--[[
	Check if a position matches the expected spawn position
]]
local function isCorrectPosition(position: Vector3): boolean
	local diff: Vector3 = position - SPAWN_CONFIG.Position
	return diff.Magnitude < POSITION_TOLERANCE
end

--[[
	Validate and fix spawn locations
]]
local function enforceSpawnRules(): ()
	print("[SpawnManager] Validating spawn configuration...")

	local spawnLocations: {SpawnLocation} = {}
	local incorrectSpawns: {SpawnLocation} = {}
	local correctSpawnFound: boolean = false

	-- Find all SpawnLocations in Workspace
	for _, child in Workspace:GetChildren() do
		if child:IsA("SpawnLocation") then
			table.insert(spawnLocations, child)

			if isCorrectPosition(child.Position) then
				correctSpawnFound = true
				print("[SpawnManager] Found correct spawn at", child.Position)
			else
				table.insert(incorrectSpawns, child)
				warn("[SpawnManager] REGRESSION DETECTED: Found unauthorized SpawnLocation at", child.Position)
			end
		end
	end

	-- Also check in any folders
	for _, descendant in Workspace:GetDescendants() do
		if descendant:IsA("SpawnLocation") and not table.find(spawnLocations, descendant) then
			table.insert(spawnLocations, descendant)

			if isCorrectPosition(descendant.Position) then
				correctSpawnFound = true
			else
				table.insert(incorrectSpawns, descendant)
				warn("[SpawnManager] REGRESSION DETECTED: Found unauthorized SpawnLocation at", descendant.Position, "in", descendant.Parent.Name)
			end
		end
	end

	-- Remove incorrect spawn locations
	for _, spawn in incorrectSpawns do
		warn("[SpawnManager] Removing unauthorized SpawnLocation at", spawn.Position)
		spawn:Destroy()
	end

	-- Create correct spawn if missing
	if not correctSpawnFound then
		warn("[SpawnManager] CRITICAL: No spawn at correct position! Creating one...")

		local spawn: SpawnLocation = Instance.new("SpawnLocation")
		spawn.Name = SPAWN_CONFIG.Name
		spawn.Position = SPAWN_CONFIG.Position
		spawn.Size = SPAWN_CONFIG.Size
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.AllowTeamChangeOnTouch = false
		spawn.Enabled = true
		spawn.Material = Enum.Material.Wood
		spawn.Color = Color3.fromRGB(139, 90, 43)
		spawn.Parent = Workspace
	end

	-- Summary
	local totalRemoved: number = #incorrectSpawns
	if totalRemoved > 0 then
		warn("[SpawnManager] Removed", totalRemoved, "unauthorized spawn location(s)")
		warn("[SpawnManager] This indicates a regression - check project configuration!")
	else
		print("[SpawnManager] Spawn configuration valid - players spawn at (0, 3, 100)")
	end
end

-- Run validation on server start
enforceSpawnRules()

-- Also validate periodically in case something adds spawns later
task.spawn(function()
	while true do
		task.wait(30)
		-- Quick check for any new unauthorized spawns
		for _, descendant in Workspace:GetDescendants() do
			if descendant:IsA("SpawnLocation") and not isCorrectPosition(descendant.Position) then
				warn("[SpawnManager] Runtime regression: Unauthorized spawn detected at", descendant.Position)
				descendant:Destroy()
			end
		end
	end
end)
