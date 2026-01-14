--[[
	Tests/init.luau

	Test runner for regression tests.
	Uses TestEZ to run all .spec files in this directory.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import TestEZ from packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local TestEZ = require(Packages:WaitForChild("TestEZ"))

local Tests = {}

--[[
	Run all tests and return results
]]
function Tests.runAll(): ()
	print("===========================================")
	print("Running Regression Tests")
	print("===========================================")

	local testModules = {}

	-- Collect all .spec files
	for _, child in script:GetChildren() do
		if child:IsA("ModuleScript") and child.Name:match("%.spec$") then
			table.insert(testModules, child)
		end
	end

	-- Run tests
	local results = TestEZ.TestBootstrap:run(testModules)

	-- Summary
	print("===========================================")
	if results.failureCount > 0 then
		warn("REGRESSION TESTS FAILED:", results.failureCount, "failure(s)")
		warn("Please fix regressions before deploying!")
	else
		print("All regression tests passed!")
	end
	print("===========================================")

	return results
end

return Tests
