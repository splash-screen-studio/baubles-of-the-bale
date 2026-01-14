--[[
	Music.server.luau

	Plays background music for the village.
]]

local SoundService = game:GetService("SoundService")

-- Music configuration
local MUSIC_ID: number = 110583378540017
local VOLUME: number = 0.5
local LOOPED: boolean = true

--[[
	Creates and plays the background music
]]
local function playMusic(): ()
	print("[Music] Starting background music...")

	local music: Sound = Instance.new("Sound")
	music.Name = "BackgroundMusic"
	music.SoundId = "rbxassetid://" .. MUSIC_ID
	music.Volume = VOLUME
	music.Looped = LOOPED
	music.RollOffMode = Enum.RollOffMode.Linear
	music.Parent = SoundService

	-- Wait for the sound to load
	if not music.IsLoaded then
		music.Loaded:Wait()
	end

	music:Play()
	print("[Music] Now playing: midwest-meridian")
end

-- Start the music
playMusic()
