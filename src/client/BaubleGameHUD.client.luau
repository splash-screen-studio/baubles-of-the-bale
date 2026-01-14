--[[
	BaubleGameHUD.client.luau

	Client-side HUD for the bauble collection game.
	Compact display: BREAK during break, score during active, always shows leader.
	Handles flash effects on bauble collection.
	Switches music between active and relaxed modes.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for events folder
local eventsFolder = ReplicatedStorage:WaitForChild("BaubleGameEvents", 10)
if not eventsFolder then
	warn("[BaubleGameHUD] Events folder not found!")
	return
end

local gameStateEvent = eventsFolder:WaitForChild("GameStateChanged")
local scoreEvent = eventsFolder:WaitForChild("ScoreUpdated")
local baubleTouchedEvent = eventsFolder:WaitForChild("BaubleTouched")
local leaderEvent = eventsFolder:WaitForChild("LeaderUpdated")
local playerDiedEvent = eventsFolder:WaitForChild("PlayerDied")
local zapEvent = eventsFolder:WaitForChild("BaubleZapped")
local zapperRangeEvent = eventsFolder:WaitForChild("ZapperRangeUpdated")
local getPlayerState = eventsFolder:WaitForChild("GetPlayerState")

-- Configuration
local RELAXED_MUSIC_ID: string = "rbxassetid://110583378540017"
local ACTIVE_MUSIC_ID: string = "rbxassetid://126431844684249"

-- State
local isActiveMode: boolean = false
local currentScore: number = 0
local currentGoal: number = 1
local timeRemaining: number = 0
local zapperRange: number = 0

-- Zapper beam parts
local leftBeam: Part? = nil
local rightBeam: Part? = nil
local ZAPPER_ANGLE: number = 60 -- degrees from center

-- Create the main ScreenGui
local screenGui: ScreenGui = Instance.new("ScreenGui")
screenGui.Name = "BaubleGameHUD"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Create flash overlay for bauble collection
local flashOverlay: Frame = Instance.new("Frame")
flashOverlay.Name = "FlashOverlay"
flashOverlay.Size = UDim2.new(1, 0, 1, 0)
flashOverlay.Position = UDim2.new(0, 0, 0, 0)
flashOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 200)
flashOverlay.BackgroundTransparency = 1
flashOverlay.BorderSizePixel = 0
flashOverlay.ZIndex = 100
flashOverlay.Parent = screenGui

-- Main HUD container (top center, compact)
local hudContainer: Frame = Instance.new("Frame")
hudContainer.Name = "HUDContainer"
hudContainer.Size = UDim2.new(0, 240, 0, 58)
hudContainer.Position = UDim2.new(0.5, -120, 0, 0)
hudContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hudContainer.BackgroundTransparency = 0.5
hudContainer.BorderSizePixel = 0
hudContainer.Parent = screenGui

local hudCorner: UICorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 10)
hudCorner.Parent = hudContainer

-- Main display (shows BREAK or score like 0/12)
local mainLabel: TextLabel = Instance.new("TextLabel")
mainLabel.Name = "MainLabel"
mainLabel.Size = UDim2.new(1, 0, 0, 28)
mainLabel.Position = UDim2.new(0, 0, 0, 5)
mainLabel.BackgroundTransparency = 1
mainLabel.Text = "BREAK"
mainLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
mainLabel.TextSize = 24
mainLabel.Font = Enum.Font.GothamBold
mainLabel.Parent = hudContainer

-- Leader display (always visible)
local leaderLabel: TextLabel = Instance.new("TextLabel")
leaderLabel.Name = "LeaderLabel"
leaderLabel.Size = UDim2.new(1, 0, 0, 22)
leaderLabel.Position = UDim2.new(0, 0, 0, 32)
leaderLabel.BackgroundTransparency = 1
leaderLabel.Text = "Leader: None (0)"
leaderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
leaderLabel.TextSize = 18
leaderLabel.Font = Enum.Font.Gotham
leaderLabel.Parent = hudContainer

-- Music players - two separate tracks for crossfading
local breakMusic: Sound = Instance.new("Sound")
breakMusic.Name = "BreakMusic"
breakMusic.SoundId = RELAXED_MUSIC_ID
breakMusic.Volume = 0.25
breakMusic.Looped = true
breakMusic.Parent = SoundService

local activeMusic: Sound = Instance.new("Sound")
activeMusic.Name = "ActiveMusic"
activeMusic.SoundId = ACTIVE_MUSIC_ID
activeMusic.Volume = 0
activeMusic.Looped = true
activeMusic.Parent = SoundService

-- Loud hit sound effect
local hitSound: Sound = Instance.new("Sound")
hitSound.Name = "BaubleHitSound"
hitSound.SoundId = "rbxassetid://9125402735" -- Loud pop/impact sound
hitSound.Volume = 1.0
hitSound.Parent = SoundService

local currentlyActive: boolean = false
local CROSSFADE_TIME: number = 0.5

--[[
	Create or update the zapper beam effect
]]
local function createZapperBeams(): ()
	-- Remove old beams
	if leftBeam then leftBeam:Destroy() end
	if rightBeam then rightBeam:Destroy() end

	if zapperRange <= 0 then
		leftBeam = nil
		rightBeam = nil
		return
	end

	-- Create left beam
	leftBeam = Instance.new("Part")
	leftBeam.Name = "ZapperBeamLeft"
	leftBeam.Size = Vector3.new(0.3, 0.3, zapperRange)
	leftBeam.Anchored = true
	leftBeam.CanCollide = false
	leftBeam.Material = Enum.Material.Neon
	leftBeam.Color = Color3.fromRGB(100, 180, 255)
	leftBeam.Transparency = 0.4
	leftBeam.CastShadow = false
	leftBeam.Parent = Workspace

	-- Add glow effect
	local leftLight: PointLight = Instance.new("PointLight")
	leftLight.Color = Color3.fromRGB(100, 180, 255)
	leftLight.Brightness = 1
	leftLight.Range = 4
	leftLight.Parent = leftBeam

	-- Create right beam
	rightBeam = Instance.new("Part")
	rightBeam.Name = "ZapperBeamRight"
	rightBeam.Size = Vector3.new(0.3, 0.3, zapperRange)
	rightBeam.Anchored = true
	rightBeam.CanCollide = false
	rightBeam.Material = Enum.Material.Neon
	rightBeam.Color = Color3.fromRGB(100, 180, 255)
	rightBeam.Transparency = 0.4
	rightBeam.CastShadow = false
	rightBeam.Parent = Workspace

	local rightLight: PointLight = Instance.new("PointLight")
	rightLight.Color = Color3.fromRGB(100, 180, 255)
	rightLight.Brightness = 1
	rightLight.Range = 4
	rightLight.Parent = rightBeam
end

--[[
	Update beam positions based on player look direction
]]
local function updateZapperBeams(): ()
	if not leftBeam or not rightBeam then return end
	if zapperRange <= 0 then return end

	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local pos: Vector3 = hrp.Position
	local lookCFrame: CFrame = hrp.CFrame

	-- Calculate left beam direction (60 degrees left)
	local leftAngle: number = math.rad(ZAPPER_ANGLE)
	local leftDir: CFrame = lookCFrame * CFrame.Angles(0, leftAngle, 0)
	local leftEnd: Vector3 = pos + leftDir.LookVector * zapperRange
	local leftMid: Vector3 = (pos + leftEnd) / 2
	leftBeam.Size = Vector3.new(0.3, 0.3, zapperRange)
	leftBeam.CFrame = CFrame.lookAt(leftMid, leftEnd)

	-- Calculate right beam direction (60 degrees right)
	local rightAngle: number = math.rad(-ZAPPER_ANGLE)
	local rightDir: CFrame = lookCFrame * CFrame.Angles(0, rightAngle, 0)
	local rightEnd: Vector3 = pos + rightDir.LookVector * zapperRange
	local rightMid: Vector3 = (pos + rightEnd) / 2
	rightBeam.Size = Vector3.new(0.3, 0.3, zapperRange)
	rightBeam.CFrame = CFrame.lookAt(rightMid, rightEnd)
end

-- Update beams every frame
RunService.RenderStepped:Connect(updateZapperBeams)

--[[
	Update the HUD display
]]
local function updateHUD(): ()
	if isActiveMode then
		-- During active: show score and timer on same line
		local minutes: number = math.floor(timeRemaining / 60)
		local seconds: number = timeRemaining % 60
		mainLabel.Text = string.format("%d/%d  %d:%02d", currentScore, currentGoal, minutes, seconds)

		-- Color based on progress
		if currentScore >= currentGoal then
			mainLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green - goal met
		elseif timeRemaining < 10 and currentScore < currentGoal then
			mainLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red - running out of time
		else
			mainLabel.TextColor3 = Color3.fromRGB(255, 220, 100) -- Yellow - normal
		end
	else
		-- During break: show BREAK
		mainLabel.Text = "BREAK"
		mainLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
	end
end

--[[
	Flash effect and sound when collecting a bauble
]]
local function playFlashEffect(): ()
	-- Bright white flash
	flashOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	flashOverlay.BackgroundTransparency = 0.3 -- Much brighter (70% visible)

	local tween = TweenService:Create(
		flashOverlay,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 1}
	)
	tween:Play()

	-- Loud sound effect
	hitSound:Play()
end

--[[
	Lightning bolt effect when zapping a bauble
]]
local function playZapEffect(fromPos: Vector3, toPos: Vector3): ()
	-- Create lightning bolt segments - thick and visible
	local segments: number = 6
	local boltParts: {Part} = {}

	local direction: Vector3 = toPos - fromPos
	local distance: number = direction.Magnitude

	-- Create main bolt and a couple branch bolts for effect
	for branch = 1, 3 do
		local branchOffset = (branch == 1) and Vector3.zero or Vector3.new(
			(math.random() - 0.5) * 1,
			(math.random() - 0.5) * 1,
			(math.random() - 0.5) * 1
		)

		for i = 1, segments do
			local startPoint: Vector3 = fromPos + direction * ((i - 1) / segments) + branchOffset
			local endPoint: Vector3 = fromPos + direction * (i / segments) + branchOffset

			-- Add random offset for jagged lightning look
			if i > 1 and i < segments then
				local offset: Vector3 = Vector3.new(
					(math.random() - 0.5) * 1.5,
					(math.random() - 0.5) * 1.5,
					(math.random() - 0.5) * 1.5
				)
				startPoint = startPoint + offset
			end

			local midPoint: Vector3 = (startPoint + endPoint) / 2
			local segDir: Vector3 = endPoint - startPoint

			local bolt: Part = Instance.new("Part")
			bolt.Name = "LightningBolt"
			-- Main bolt is thicker, branches are thinner
			local thickness = (branch == 1) and 0.5 or 0.25
			bolt.Size = Vector3.new(thickness, thickness, segDir.Magnitude)
			bolt.CFrame = CFrame.lookAt(midPoint, endPoint)
			bolt.Anchored = true
			bolt.CanCollide = false
			bolt.Material = Enum.Material.Neon
			bolt.Color = Color3.fromRGB(100, 200, 255)
			bolt.Parent = Workspace

			-- Add point light to main bolt segments
			if branch == 1 then
				local light: PointLight = Instance.new("PointLight")
				light.Color = Color3.fromRGB(150, 220, 255)
				light.Brightness = 3
				light.Range = 8
				light.Parent = bolt
			end

			table.insert(boltParts, bolt)
		end
	end

	-- Play zap sound
	hitSound:Play()

	-- Bright flash effect
	flashOverlay.BackgroundColor3 = Color3.fromRGB(150, 220, 255)
	flashOverlay.BackgroundTransparency = 0.3

	local flashTween = TweenService:Create(
		flashOverlay,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 1}
	)
	flashTween:Play()

	-- Remove lightning after visible moment
	task.delay(0.2, function()
		for _, part in ipairs(boltParts) do
			part:Destroy()
		end
	end)
end

--[[
	Switch music with crossfade - tracks continue where they left off
]]
local function updateMusic(activeMusicId: string?): ()
	local shouldBeActive: boolean = (activeMusicId == ACTIVE_MUSIC_ID)

	if shouldBeActive == currentlyActive then return end
	currentlyActive = shouldBeActive

	-- Start both tracks if not playing (they play continuously, just volume changes)
	if not breakMusic.IsPlaying then
		breakMusic:Play()
	end
	if not activeMusic.IsPlaying then
		activeMusic:Play()
	end

	-- Crossfade between tracks
	if shouldBeActive then
		-- Fade to active music (75% volume)
		TweenService:Create(breakMusic, TweenInfo.new(CROSSFADE_TIME), {Volume = 0}):Play()
		TweenService:Create(activeMusic, TweenInfo.new(CROSSFADE_TIME), {Volume = 0.75}):Play()
		print("[BaubleGameHUD] Crossfading to active music")
	else
		-- Fade to break music (25% volume)
		TweenService:Create(activeMusic, TweenInfo.new(CROSSFADE_TIME), {Volume = 0}):Play()
		TweenService:Create(breakMusic, TweenInfo.new(CROSSFADE_TIME), {Volume = 0.25}):Play()
		print("[BaubleGameHUD] Crossfading to break music")
	end
end

-- Event handlers
gameStateEvent.OnClientEvent:Connect(function(active: boolean, time: number, activeMusicId: string?)
	isActiveMode = active
	timeRemaining = time
	updateHUD()

	-- Start active music 1 second early (when break has 1 second left)
	if not active and time <= 1 then
		updateMusic(ACTIVE_MUSIC_ID)
	else
		updateMusic(activeMusicId)
	end
end)

scoreEvent.OnClientEvent:Connect(function(score: number, goal: number)
	currentScore = score
	currentGoal = goal
	updateHUD()
end)

baubleTouchedEvent.OnClientEvent:Connect(function(position: Vector3)
	playFlashEffect()
end)

zapEvent.OnClientEvent:Connect(function(fromPos: Vector3, toPos: Vector3)
	playZapEffect(fromPos, toPos)
end)

zapperRangeEvent.OnClientEvent:Connect(function(newRange: number)
	print("[BaubleGameHUD] Zapper range updated to", newRange)
	zapperRange = newRange
	createZapperBeams()
end)

leaderEvent.OnClientEvent:Connect(function(leaderName: string, leaderScore: number)
	print("[BaubleGameHUD] Leader event received:", leaderName, leaderScore)
	leaderLabel.Text = string.format("Leader: %s (%d)", leaderName, leaderScore)
end)

playerDiedEvent.OnClientEvent:Connect(function(newGoal: number)
	currentGoal = newGoal

	-- Flash red on death
	flashOverlay.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	flashOverlay.BackgroundTransparency = 0.5

	local tween = TweenService:Create(
		flashOverlay,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 1}
	)
	tween:Play()

	-- Reset flash color
	task.delay(1, function()
		flashOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 200)
	end)

	updateHUD()
end)

-- Initialize by requesting current state from server
print("[BaubleGameHUD] Requesting initial state from server...")

local success, state = pcall(function()
	return getPlayerState:InvokeServer()
end)

if success and state then
	isActiveMode = state.isActiveMode
	timeRemaining = state.timeRemaining
	currentScore = state.currentScore
	currentGoal = state.goal
	zapperRange = state.zapperRange or 0

	print("[BaubleGameHUD] Got state - score:", currentScore, "goal:", currentGoal, "zapperRange:", zapperRange)

	leaderLabel.Text = string.format("Leader: %s (%d)", state.leaderName, state.leaderScore)

	-- Create zapper beams if player has zapper
	if zapperRange > 0 then
		createZapperBeams()
	end
else
	warn("[BaubleGameHUD] Failed to get initial state:", state)
end

updateHUD()

-- Start both music tracks (they run continuously, volume controls which is heard)
breakMusic:Play()
activeMusic:Play()

-- Set initial volumes based on current mode
if isActiveMode then
	breakMusic.Volume = 0
	activeMusic.Volume = 0.75
	currentlyActive = true
else
	breakMusic.Volume = 0.25
	activeMusic.Volume = 0
	currentlyActive = false
end

print("[BaubleGameHUD] Bauble game HUD initialized!")
