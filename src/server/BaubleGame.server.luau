--[[
	BaubleGame.server.luau

	Timer-based ball collection game.
	- 20 second active period: collect baubles to beat your goal
	- 30 second break period: baubles don't count
	- Must beat previous score or die
	- Goal decreases on death
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

-- Configuration
local ACTIVE_DURATION: number = 20
local BREAK_DURATION: number = 30
local STARTING_GOAL: number = 1
local GOAL_DECREASE_ON_DEATH: number = 1
local ACTIVE_MUSIC_ID: string = "rbxassetid://126431844684249"
local NORMAL_WALK_SPEED: number = 16
local ACTIVE_WALK_SPEED: number = 48 -- 3x faster

-- Create RemoteEvents for client communication
local eventsFolder: Folder = Instance.new("Folder")
eventsFolder.Name = "BaubleGameEvents"
eventsFolder.Parent = ReplicatedStorage

local gameStateEvent: RemoteEvent = Instance.new("RemoteEvent")
gameStateEvent.Name = "GameStateChanged"
gameStateEvent.Parent = eventsFolder

local scoreEvent: RemoteEvent = Instance.new("RemoteEvent")
scoreEvent.Name = "ScoreUpdated"
scoreEvent.Parent = eventsFolder

local baubleTouchedEvent: RemoteEvent = Instance.new("RemoteEvent")
baubleTouchedEvent.Name = "BaubleTouched"
baubleTouchedEvent.Parent = eventsFolder

local leaderEvent: RemoteEvent = Instance.new("RemoteEvent")
leaderEvent.Name = "LeaderUpdated"
leaderEvent.Parent = eventsFolder

local playerDiedEvent: RemoteEvent = Instance.new("RemoteEvent")
playerDiedEvent.Name = "PlayerDied"
playerDiedEvent.Parent = eventsFolder

local toggleActiveMode: RemoteEvent = Instance.new("RemoteEvent")
toggleActiveMode.Name = "ToggleActiveMode"
toggleActiveMode.Parent = eventsFolder

local getPlayerState: RemoteFunction = Instance.new("RemoteFunction")
getPlayerState.Name = "GetPlayerState"
getPlayerState.Parent = eventsFolder

-- Player data
type PlayerData = {
	goal: number,
	currentScore: number,
	bestScore: number,
	activeModeEnabled: boolean,
}

local playerData: {[Player]: PlayerData} = {}

-- Game state
local isActiveMode: boolean = false
local timeRemaining: number = BREAK_DURATION
local currentLeader: Player? = nil
local currentLeaderScore: number = 0

-- Sound effect for collecting baubles
local collectSound: Sound = Instance.new("Sound")
collectSound.Name = "BaubleCollect"
collectSound.SoundId = "rbxassetid://9119713951" -- Short pop/ding sound
collectSound.Volume = 0.5
collectSound.Parent = SoundService

--[[
	Initialize player data
]]
local function initPlayerData(player: Player): ()
	playerData[player] = {
		goal = STARTING_GOAL,
		currentScore = 0,
		bestScore = 0,
		activeModeEnabled = true,
	}
end

--[[
	Clean up player data
]]
local function cleanupPlayerData(player: Player): ()
	playerData[player] = nil

	-- Update leader if this player was leader
	if currentLeader == player then
		currentLeader = nil
		currentLeaderScore = 0
		updateLeader()
	end
end

--[[
	Update the current leader
]]
local function updateLeader(): ()
	local bestPlayer: Player? = nil
	local bestScore: number = 0

	for player, data in pairs(playerData) do
		if data.currentScore > bestScore then
			bestScore = data.currentScore
			bestPlayer = player
		end
	end

	if bestPlayer ~= currentLeader or bestScore ~= currentLeaderScore then
		currentLeader = bestPlayer
		currentLeaderScore = bestScore

		-- Broadcast leader update to all clients
		local leaderName: string = currentLeader and currentLeader.Name or "None"
		print("[BaubleGame] Leader updated:", leaderName, "with score", currentLeaderScore)
		leaderEvent:FireAllClients(leaderName, currentLeaderScore)
	end
end

--[[
	Handle bauble touch during active mode
]]
local function onBaubleTouched(bauble: Part, player: Player): ()
	local data = playerData[player]
	if not data then return end

	-- Only count if active mode is enabled for this player and game is in active mode
	if not isActiveMode or not data.activeModeEnabled then return end

	-- Increment score
	data.currentScore = data.currentScore + 1
	print("[BaubleGame]", player.Name, "collected bauble! Score:", data.currentScore, "/", data.goal)

	-- Update best score
	if data.currentScore > data.bestScore then
		data.bestScore = data.currentScore
	end

	-- Send score update to client
	scoreEvent:FireClient(player, data.currentScore, data.goal)

	-- Send touch event for effects
	baubleTouchedEvent:FireClient(player, bauble.Position)

	-- Play sound (positional from bauble location)
	local sound: Sound = collectSound:Clone()
	sound.Parent = bauble
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	-- Remove the bauble
	bauble:Destroy()

	-- Update leader
	updateLeader()
end

--[[
	Set up bauble touch detection
]]
local function setupBaubleDetection(): ()
	local baublesFolder = Workspace:FindFirstChild("Baubles")
	if not baublesFolder then return end

	baublesFolder.ChildAdded:Connect(function(child)
		if child:IsA("Part") and child.Name == "Bauble" then
			child.Touched:Connect(function(hit)
				local character = hit.Parent
				if not character then return end

				local player = Players:GetPlayerFromCharacter(character)
				if player then
					onBaubleTouched(child, player)
				end
			end)
		end
	end)

	-- Set up existing baubles
	for _, child in ipairs(baublesFolder:GetChildren()) do
		if child:IsA("Part") and child.Name == "Bauble" then
			child.Touched:Connect(function(hit)
				local character = hit.Parent
				if not character then return end

				local player = Players:GetPlayerFromCharacter(character)
				if player then
					onBaubleTouched(child, player)
				end
			end)
		end
	end
end

--[[
	End of active period - check goals
]]
local function endActivePeriod(): ()
	print("[BaubleGame] Active period ended!")

	for player, data in pairs(playerData) do
		if not data.activeModeEnabled then continue end

		if data.currentScore >= data.goal then
			-- Success! Increase goal for next round
			print("[BaubleGame]", player.Name, "succeeded with", data.currentScore, "/", data.goal)
			data.goal = data.currentScore + 1
		else
			-- Failed - player dies
			print("[BaubleGame]", player.Name, "failed with", data.currentScore, "/", data.goal)

			-- Decrease goal (minimum 1)
			data.goal = math.max(STARTING_GOAL, data.goal - GOAL_DECREASE_ON_DEATH)

			-- Kill the player
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.Health = 0
				end
			end

			-- Notify client
			playerDiedEvent:FireClient(player, data.goal)
		end

		-- Reset current score for next round
		data.currentScore = 0
		scoreEvent:FireClient(player, 0, data.goal)
	end

	-- Keep leader visible during break (shows who won the round)
end

--[[
	Start active period
]]
--[[
	Set walk speed for all players
]]
local function setAllPlayersSpeed(speed: number): ()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = speed
			end
		end
	end
end

local function startActivePeriod(): ()
	print("[BaubleGame] Active period started!")
	isActiveMode = true
	timeRemaining = ACTIVE_DURATION

	-- Reset leader for new round
	currentLeader = nil
	currentLeaderScore = 0
	leaderEvent:FireAllClients("None", 0)

	-- Reset scores for all players
	for player, data in pairs(playerData) do
		data.currentScore = 0
		scoreEvent:FireClient(player, 0, data.goal)
	end

	-- Speed boost!
	setAllPlayersSpeed(ACTIVE_WALK_SPEED)

	-- Notify all clients
	gameStateEvent:FireAllClients(true, ACTIVE_DURATION, ACTIVE_MUSIC_ID)
end

--[[
	Start break period
]]
local function startBreakPeriod(): ()
	print("[BaubleGame] Break period started!")
	isActiveMode = false
	timeRemaining = BREAK_DURATION

	-- Reset to normal speed
	setAllPlayersSpeed(NORMAL_WALK_SPEED)

	-- Notify all clients
	gameStateEvent:FireAllClients(false, BREAK_DURATION, nil)
end

--[[
	Main game loop
]]
local function gameLoop(): ()
	-- Start with a break period
	startBreakPeriod()

	while true do
		task.wait(1)
		timeRemaining = timeRemaining - 1

		-- Broadcast time remaining
		gameStateEvent:FireAllClients(isActiveMode, timeRemaining, isActiveMode and ACTIVE_MUSIC_ID or nil)

		if timeRemaining <= 0 then
			if isActiveMode then
				endActivePeriod()
				startBreakPeriod()
			else
				startActivePeriod()
			end
		end
	end
end

--[[
	Handle toggle active mode from client
]]
toggleActiveMode.OnServerEvent:Connect(function(player: Player, enabled: boolean)
	local data = playerData[player]
	if data then
		data.activeModeEnabled = enabled
		print("[BaubleGame]", player.Name, "set active mode to", enabled)
	end
end)

-- Player connections
Players.PlayerAdded:Connect(function(player)
	initPlayerData(player)

	-- Handle character spawn/respawn for speed setting
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = isActiveMode and ACTIVE_WALK_SPEED or NORMAL_WALK_SPEED
		end
	end)

	-- Send initial state
	task.defer(function()
		local data = playerData[player]
		if data then
			gameStateEvent:FireClient(player, isActiveMode, timeRemaining, isActiveMode and ACTIVE_MUSIC_ID or nil)
			scoreEvent:FireClient(player, data.currentScore, data.goal)

			local leaderName: string = currentLeader and currentLeader.Name or "None"
			leaderEvent:FireAllClients(leaderName, currentLeaderScore)
		end
	end)
end)

Players.PlayerRemoving:Connect(cleanupPlayerData)

-- Initialize existing players
for _, player in ipairs(Players:GetPlayers()) do
	initPlayerData(player)
end

--[[
	Handle client request for current state
]]
getPlayerState.OnServerInvoke = function(player: Player)
	local data = playerData[player]
	if not data then
		initPlayerData(player)
		data = playerData[player]
	end

	local leaderName: string = currentLeader and currentLeader.Name or "None"

	print("[BaubleGame] Sending state to", player.Name, "- score:", data.currentScore, "goal:", data.goal)

	return {
		isActiveMode = isActiveMode,
		timeRemaining = timeRemaining,
		currentScore = data.currentScore,
		goal = data.goal,
		leaderName = leaderName,
		leaderScore = currentLeaderScore,
		activeModeEnabled = data.activeModeEnabled,
	}
end

-- Start the game
print("[BaubleGame] Initializing bauble collection game...")
task.defer(setupBaubleDetection)
task.spawn(gameLoop)
