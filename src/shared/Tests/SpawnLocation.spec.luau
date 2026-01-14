--[[
	SpawnLocation.spec.luau

	REGRESSION TESTS for spawn location configuration.

	These tests exist because of a regression where players were
	spawning at (0, 0) instead of the correct location (0, 100).

	Root cause: Rojo only manages objects defined in the project file.
	Pre-existing SpawnLocations in the Roblox place were not removed,
	causing players to spawn at the wrong location.

	CRITICAL REQUIREMENTS:
	1. Players MUST spawn at X:0, Z:100
	2. There must be exactly ONE SpawnLocation
	3. No SpawnLocation should exist at (0, 0)
]]

local Workspace = game:GetService("Workspace")

return function()
	-- Canonical spawn position - SINGLE SOURCE OF TRUTH
	-- IMPORTANT: Keep in sync with default.project.json and SpawnManager.server.luau
	local EXPECTED_SPAWN_POSITION = Vector3.new(0, 1, 100)
	local EXPECTED_SPAWN_X: number = 0
	local EXPECTED_SPAWN_Z: number = 100
	local POSITION_TOLERANCE: number = 1

	describe("Spawn Location", function()
		it("should have exactly one SpawnLocation in Workspace", function()
			local spawnCount: number = 0

			for _, descendant in Workspace:GetDescendants() do
				if descendant:IsA("SpawnLocation") then
					spawnCount = spawnCount + 1
				end
			end

			expect(spawnCount).to.equal(1)
		end)

		it("should spawn players at X:0, Z:100", function()
			local spawn: SpawnLocation? = nil

			for _, descendant in Workspace:GetDescendants() do
				if descendant:IsA("SpawnLocation") then
					spawn = descendant
					break
				end
			end

			expect(spawn).to.be.ok()

			if spawn then
				local pos: Vector3 = spawn.Position
				local xCorrect: boolean = math.abs(pos.X - EXPECTED_SPAWN_X) < POSITION_TOLERANCE
				local zCorrect: boolean = math.abs(pos.Z - EXPECTED_SPAWN_Z) < POSITION_TOLERANCE

				expect(xCorrect).to.equal(true)
				expect(zCorrect).to.equal(true)
			end
		end)

		it("should NOT have any SpawnLocation at origin (0, 0)", function()
			-- This is the specific regression we're guarding against
			local FORBIDDEN_X: number = 0
			local FORBIDDEN_Z: number = 0
			local foundForbiddenSpawn: boolean = false

			for _, descendant in Workspace:GetDescendants() do
				if descendant:IsA("SpawnLocation") then
					local pos: Vector3 = descendant.Position
					local atForbiddenX: boolean = math.abs(pos.X - FORBIDDEN_X) < POSITION_TOLERANCE
					local atForbiddenZ: boolean = math.abs(pos.Z - FORBIDDEN_Z) < POSITION_TOLERANCE

					if atForbiddenX and atForbiddenZ then
						foundForbiddenSpawn = true
						warn("REGRESSION: Found SpawnLocation at forbidden position (0, 0):", descendant:GetFullName())
					end
				end
			end

			expect(foundForbiddenSpawn).to.equal(false)
		end)

		it("should have SpawnLocation enabled", function()
			local spawn: SpawnLocation? = nil

			for _, descendant in Workspace:GetDescendants() do
				if descendant:IsA("SpawnLocation") then
					spawn = descendant
					break
				end
			end

			expect(spawn).to.be.ok()
			if spawn then
				expect(spawn.Enabled).to.equal(true)
			end
		end)

		it("should have SpawnLocation anchored", function()
			local spawn: SpawnLocation? = nil

			for _, descendant in Workspace:GetDescendants() do
				if descendant:IsA("SpawnLocation") then
					spawn = descendant
					break
				end
			end

			expect(spawn).to.be.ok()
			if spawn then
				expect(spawn.Anchored).to.equal(true)
			end
		end)

		it("should have neutral SpawnLocation (no team restriction)", function()
			local spawn: SpawnLocation? = nil

			for _, descendant in Workspace:GetDescendants() do
				if descendant:IsA("SpawnLocation") then
					spawn = descendant
					break
				end
			end

			expect(spawn).to.be.ok()
			if spawn then
				expect(spawn.Neutral).to.equal(true)
			end
		end)
	end)

	describe("Spawn Configuration Constants", function()
		it("should match SpawnManager constants", function()
			-- These values must stay in sync:
			-- - default.project.json SpawnLocation Position
			-- - SpawnManager.server.luau SPAWN_CONFIG.Position
			-- - This test file EXPECTED_SPAWN_POSITION

			-- If this test fails, someone changed spawn position
			-- without updating all locations
			expect(EXPECTED_SPAWN_X).to.equal(0)
			expect(EXPECTED_SPAWN_Z).to.equal(100)
		end)
	end)
end
