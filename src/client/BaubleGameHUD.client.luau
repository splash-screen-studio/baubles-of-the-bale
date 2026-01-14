--[[
	BaubleGameHUD.client.luau

	Client-side HUD for the bauble collection game.
	Shows goal, count, leader, mode indicator, and timer.
	Handles flash effects on bauble collection.
	Switches music between active and relaxed modes.
	Includes toggle to disable active mode.
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
local toggleActiveMode = eventsFolder:WaitForChild("ToggleActiveMode")
local getPlayerState = eventsFolder:WaitForChild("GetPlayerState")

-- Configuration
local RELAXED_MUSIC_ID: string = "rbxassetid://110583378540017"
local ACTIVE_MUSIC_ID: string = "rbxassetid://126431844684249"

-- State
local isActiveMode: boolean = false
local activeModeEnabled: boolean = true
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

-- Main HUD container (top center)
local hudContainer: Frame = Instance.new("Frame")
hudContainer.Name = "HUDContainer"
hudContainer.Size = UDim2.new(0, 300, 0, 120)
hudContainer.Position = UDim2.new(0.5, -150, 0, 10)
hudContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hudContainer.BackgroundTransparency = 0.5
hudContainer.BorderSizePixel = 0
hudContainer.Parent = screenGui

local hudCorner: UICorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 12)
hudCorner.Parent = hudContainer

-- Mode indicator (ACTIVE / BREAK)
local modeLabel: TextLabel = Instance.new("TextLabel")
modeLabel.Name = "ModeLabel"
modeLabel.Size = UDim2.new(1, 0, 0, 30)
modeLabel.Position = UDim2.new(0, 0, 0, 5)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "BREAK"
modeLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
modeLabel.TextSize = 24
modeLabel.Font = Enum.Font.GothamBold
modeLabel.Parent = hudContainer

-- Timer label
local timerLabel: TextLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(1, 0, 0, 25)
timerLabel.Position = UDim2.new(0, 0, 0, 32)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "0:30"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.TextSize = 20
timerLabel.Font = Enum.Font.GothamMedium
timerLabel.Parent = hudContainer

-- Score display (count / goal)
local scoreLabel: TextLabel = Instance.new("TextLabel")
scoreLabel.Name = "ScoreLabel"
scoreLabel.Size = UDim2.new(1, 0, 0, 30)
scoreLabel.Position = UDim2.new(0, 0, 0, 55)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "0 / 1"
scoreLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
scoreLabel.TextSize = 28
scoreLabel.Font = Enum.Font.GothamBold
scoreLabel.Parent = hudContainer

-- Leader display
local leaderLabel: TextLabel = Instance.new("TextLabel")
leaderLabel.Name = "LeaderLabel"
leaderLabel.Size = UDim2.new(1, 0, 0, 20)
leaderLabel.Position = UDim2.new(0, 0, 0, 90)
leaderLabel.BackgroundTransparency = 1
leaderLabel.Text = "Leader: None (0)"
leaderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
leaderLabel.TextSize = 14
leaderLabel.Font = Enum.Font.Gotham
leaderLabel.Parent = hudContainer

-- Toggle button (positioned far right for landscape iPhone)
local toggleButton: TextButton = Instance.new("TextButton")
toggleButton.Name = "ToggleActiveMode"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(1, -60, 0.5, -25) -- Far right, vertically centered
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
toggleButton.BackgroundTransparency = 0.3
toggleButton.BorderSizePixel = 0
toggleButton.Text = "ON"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = screenGui

local toggleCorner: UICorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

local toggleLabel: TextLabel = Instance.new("TextLabel")
toggleLabel.Name = "ToggleLabel"
toggleLabel.Size = UDim2.new(0, 50, 0, 15)
toggleLabel.Position = UDim2.new(1, -60, 0.5, 30)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "GAME"
toggleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
toggleLabel.TextSize = 10
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.Parent = screenGui

-- Music player
local musicPlayer: Sound = Instance.new("Sound")
musicPlayer.Name = "BaubleGameMusic"
musicPlayer.Volume = 0.4
musicPlayer.Looped = true
musicPlayer.Parent = SoundService

local currentMusicId: string = ""

--[[
	Update the HUD display
]]
local function updateHUD(): ()
	-- Mode label
	if not activeModeEnabled then
		modeLabel.Text = "GAME OFF"
		modeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	elseif isActiveMode then
		modeLabel.Text = "ACTIVE!"
		modeLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	else
		modeLabel.Text = "BREAK"
		modeLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
	end

	-- Timer
	local minutes: number = math.floor(timeRemaining / 60)
	local seconds: number = timeRemaining % 60
	timerLabel.Text = string.format("%d:%02d", minutes, seconds)

	-- Score
	scoreLabel.Text = string.format("%d / %d", currentScore, currentGoal)

	-- Color score based on progress
	if currentScore >= currentGoal then
		scoreLabel.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green - goal met
	elseif isActiveMode and timeRemaining < 10 and currentScore < currentGoal then
		scoreLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red - running out of time
	else
		scoreLabel.TextColor3 = Color3.fromRGB(255, 220, 100) -- Yellow - normal
	end
end

--[[
	Flash effect when collecting a bauble
]]
local function playFlashEffect(): ()
	flashOverlay.BackgroundTransparency = 0.7

	local tween = TweenService:Create(
		flashOverlay,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 1}
	)
	tween:Play()
end

--[[
	Switch music based on mode
]]
local function updateMusic(activeMusicId: string?): ()
	local targetId: string

	if not activeModeEnabled then
		targetId = RELAXED_MUSIC_ID
	elseif activeMusicId then
		targetId = activeMusicId
	else
		targetId = RELAXED_MUSIC_ID
	end

	if targetId ~= currentMusicId then
		currentMusicId = targetId
		musicPlayer.SoundId = targetId
		musicPlayer:Play()
		print("[BaubleGameHUD] Music changed to", targetId)
	end
end

--[[
	Handle toggle button click
]]
toggleButton.MouseButton1Click:Connect(function()
	activeModeEnabled = not activeModeEnabled

	if activeModeEnabled then
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		toggleButton.Text = "ON"
	else
		toggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
		toggleButton.Text = "OFF"
	end

	-- Notify server
	toggleActiveMode:FireServer(activeModeEnabled)

	-- Update display
	updateHUD()
	updateMusic(nil)
end)

-- Event handlers
gameStateEvent.OnClientEvent:Connect(function(active: boolean, time: number, activeMusicId: string?)
	isActiveMode = active
	timeRemaining = time
	updateHUD()
	updateMusic(activeMusicId)
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
	activeModeEnabled = state.activeModeEnabled

	print("[BaubleGameHUD] Got state - score:", currentScore, "goal:", currentGoal)

	leaderLabel.Text = string.format("Leader: %s (%d)", state.leaderName, state.leaderScore)

	-- Update toggle button to match server state
	if activeModeEnabled then
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		toggleButton.Text = "ON"
	else
		toggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
		toggleButton.Text = "OFF"
	end
else
	warn("[BaubleGameHUD] Failed to get initial state:", state)
end

updateHUD()
updateMusic(isActiveMode and ACTIVE_MUSIC_ID or nil)

print("[BaubleGameHUD] Bauble game HUD initialized!")
