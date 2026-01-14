--[[
	BaubleGameHUD.client.luau

	Client-side HUD for the bauble collection game.
	Compact display: BREAK during break, score during active, always shows leader.
	Handles flash effects on bauble collection.
	Switches music between active and relaxed modes.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

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
local getPlayerState = eventsFolder:WaitForChild("GetPlayerState")

-- Configuration
local RELAXED_MUSIC_ID: string = "rbxassetid://110583378540017"
local ACTIVE_MUSIC_ID: string = "rbxassetid://126431844684249"

-- State
local isActiveMode: boolean = false
local currentScore: number = 0
local currentGoal: number = 1
local timeRemaining: number = 0

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
hudContainer.Size = UDim2.new(0, 180, 0, 58)
hudContainer.Position = UDim2.new(0.5, -90, 0, 0)
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

-- Music player
local musicPlayer: Sound = Instance.new("Sound")
musicPlayer.Name = "BaubleGameMusic"
musicPlayer.Volume = 0.25 -- Start with break volume
musicPlayer.Looped = true
musicPlayer.Parent = SoundService

-- Loud hit sound effect
local hitSound: Sound = Instance.new("Sound")
hitSound.Name = "BaubleHitSound"
hitSound.SoundId = "rbxassetid://9125402735" -- Loud pop/impact sound
hitSound.Volume = 1.0
hitSound.Parent = SoundService

local currentMusicId: string = ""

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
	Switch music based on mode
]]
local function updateMusic(activeMusicId: string?): ()
	local targetId: string = activeMusicId or RELAXED_MUSIC_ID

	if targetId ~= currentMusicId then
		currentMusicId = targetId
		musicPlayer.SoundId = targetId
		-- Break music at 25%, active music at 75%
		musicPlayer.Volume = (targetId == ACTIVE_MUSIC_ID) and 0.75 or 0.25
		musicPlayer:Play()
		print("[BaubleGameHUD] Music changed to", targetId)
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

	print("[BaubleGameHUD] Got state - score:", currentScore, "goal:", currentGoal)

	leaderLabel.Text = string.format("Leader: %s (%d)", state.leaderName, state.leaderScore)
else
	warn("[BaubleGameHUD] Failed to get initial state:", state)
end

updateHUD()
updateMusic(isActiveMode and ACTIVE_MUSIC_ID or nil)

print("[BaubleGameHUD] Bauble game HUD initialized!")
