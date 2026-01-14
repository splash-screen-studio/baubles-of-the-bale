--[[
	DayNightCycle.server.luau

	Manages the day/night cycle with smooth lighting transitions.
	Starts at dusk and progresses through night and day.
]]

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- Configuration
local MINUTES_PER_DAY: number = 20 -- Real minutes for a full 24-hour cycle
local START_TIME: number = 18.5 -- Start at dusk (6:30 PM)

-- Time progression rate (game hours per real second)
local HOURS_PER_SECOND: number = 24 / (MINUTES_PER_DAY * 60)

-- Lighting presets for different times of day
type LightingPreset = {
	Ambient: Color3,
	OutdoorAmbient: Color3,
	Brightness: number,
	ColorShift_Top: Color3,
	ColorShift_Bottom: Color3,
}

local PRESETS: {[string]: {time: number, settings: LightingPreset}} = {
	DAWN = {
		time = 5.5,
		settings = {
			Ambient = Color3.fromRGB(60, 50, 70),
			OutdoorAmbient = Color3.fromRGB(80, 70, 100),
			Brightness = 0.8,
			ColorShift_Top = Color3.fromRGB(255, 180, 140),
			ColorShift_Bottom = Color3.fromRGB(80, 60, 100),
		}
	},
	SUNRISE = {
		time = 6.5,
		settings = {
			Ambient = Color3.fromRGB(100, 85, 90),
			OutdoorAmbient = Color3.fromRGB(140, 120, 130),
			Brightness = 1.5,
			ColorShift_Top = Color3.fromRGB(255, 200, 150),
			ColorShift_Bottom = Color3.fromRGB(100, 80, 90),
		}
	},
	MORNING = {
		time = 8,
		settings = {
			Ambient = Color3.fromRGB(130, 130, 130),
			OutdoorAmbient = Color3.fromRGB(180, 180, 180),
			Brightness = 2.5,
			ColorShift_Top = Color3.fromRGB(255, 250, 240),
			ColorShift_Bottom = Color3.fromRGB(140, 140, 150),
		}
	},
	MIDDAY = {
		time = 12,
		settings = {
			Ambient = Color3.fromRGB(150, 150, 150),
			OutdoorAmbient = Color3.fromRGB(200, 200, 200),
			Brightness = 3,
			ColorShift_Top = Color3.fromRGB(255, 255, 255),
			ColorShift_Bottom = Color3.fromRGB(150, 150, 160),
		}
	},
	AFTERNOON = {
		time = 16,
		settings = {
			Ambient = Color3.fromRGB(140, 135, 130),
			OutdoorAmbient = Color3.fromRGB(190, 180, 170),
			Brightness = 2.5,
			ColorShift_Top = Color3.fromRGB(255, 240, 220),
			ColorShift_Bottom = Color3.fromRGB(140, 130, 120),
		}
	},
	SUNSET = {
		time = 18,
		settings = {
			Ambient = Color3.fromRGB(100, 70, 80),
			OutdoorAmbient = Color3.fromRGB(150, 100, 120),
			Brightness = 1.8,
			ColorShift_Top = Color3.fromRGB(255, 150, 100),
			ColorShift_Bottom = Color3.fromRGB(100, 60, 80),
		}
	},
	DUSK = {
		time = 19.5,
		settings = {
			Ambient = Color3.fromRGB(60, 50, 80),
			OutdoorAmbient = Color3.fromRGB(80, 60, 110),
			Brightness = 1,
			ColorShift_Top = Color3.fromRGB(180, 120, 150),
			ColorShift_Bottom = Color3.fromRGB(50, 40, 70),
		}
	},
	NIGHT = {
		time = 22,
		settings = {
			Ambient = Color3.fromRGB(30, 30, 50),
			OutdoorAmbient = Color3.fromRGB(40, 40, 70),
			Brightness = 0.3,
			ColorShift_Top = Color3.fromRGB(60, 60, 100),
			ColorShift_Bottom = Color3.fromRGB(20, 20, 40),
		}
	},
	MIDNIGHT = {
		time = 0,
		settings = {
			Ambient = Color3.fromRGB(20, 20, 40),
			OutdoorAmbient = Color3.fromRGB(30, 30, 60),
			Brightness = 0.2,
			ColorShift_Top = Color3.fromRGB(40, 40, 80),
			ColorShift_Bottom = Color3.fromRGB(15, 15, 30),
		}
	},
	LATE_NIGHT = {
		time = 3,
		settings = {
			Ambient = Color3.fromRGB(25, 25, 45),
			OutdoorAmbient = Color3.fromRGB(35, 35, 65),
			Brightness = 0.25,
			ColorShift_Top = Color3.fromRGB(50, 50, 90),
			ColorShift_Bottom = Color3.fromRGB(18, 18, 35),
		}
	},
}

-- Convert presets to sorted array for interpolation
local sortedPresets: {{time: number, settings: LightingPreset}} = {}
for _, preset in PRESETS do
	table.insert(sortedPresets, preset)
end
table.sort(sortedPresets, function(a, b)
	return a.time < b.time
end)

--[[
	Lerp between two Color3 values
]]
local function lerpColor(a: Color3, b: Color3, t: number): Color3
	return Color3.new(
		a.R + (b.R - a.R) * t,
		a.G + (b.G - a.G) * t,
		a.B + (b.B - a.B) * t
	)
end

--[[
	Lerp between two numbers
]]
local function lerpNumber(a: number, b: number, t: number): number
	return a + (b - a) * t
end

--[[
	Get the two presets surrounding the current time and interpolation factor
]]
local function getInterpolatedSettings(clockTime: number): LightingPreset
	local presetCount: number = #sortedPresets

	-- Handle wrap-around (midnight crossing)
	local prevPreset: {time: number, settings: LightingPreset} = sortedPresets[presetCount]
	local nextPreset: {time: number, settings: LightingPreset} = sortedPresets[1]

	for i = 1, presetCount do
		if sortedPresets[i].time > clockTime then
			nextPreset = sortedPresets[i]
			prevPreset = sortedPresets[i > 1 and i - 1 or presetCount]
			break
		end
		if i == presetCount then
			-- Time is after last preset, wrap to first
			prevPreset = sortedPresets[presetCount]
			nextPreset = sortedPresets[1]
		end
	end

	-- Calculate interpolation factor
	local prevTime: number = prevPreset.time
	local nextTime: number = nextPreset.time

	-- Handle midnight wrap
	if nextTime < prevTime then
		if clockTime < nextTime then
			clockTime = clockTime + 24
		end
		nextTime = nextTime + 24
	end

	local range: number = nextTime - prevTime
	local t: number = range > 0 and (clockTime - prevTime) / range or 0
	t = math.clamp(t, 0, 1)

	-- Smooth interpolation
	t = t * t * (3 - 2 * t) -- Smoothstep

	-- Interpolate all settings
	local prev: LightingPreset = prevPreset.settings
	local next: LightingPreset = nextPreset.settings

	return {
		Ambient = lerpColor(prev.Ambient, next.Ambient, t),
		OutdoorAmbient = lerpColor(prev.OutdoorAmbient, next.OutdoorAmbient, t),
		Brightness = lerpNumber(prev.Brightness, next.Brightness, t),
		ColorShift_Top = lerpColor(prev.ColorShift_Top, next.ColorShift_Top, t),
		ColorShift_Bottom = lerpColor(prev.ColorShift_Bottom, next.ColorShift_Bottom, t),
	}
end

--[[
	Apply lighting settings
]]
local function applyLighting(settings: LightingPreset): ()
	Lighting.Ambient = settings.Ambient
	Lighting.OutdoorAmbient = settings.OutdoorAmbient
	Lighting.Brightness = settings.Brightness
	Lighting.ColorShift_Top = settings.ColorShift_Top
	Lighting.ColorShift_Bottom = settings.ColorShift_Bottom
end

--[[
	Initialize the day/night cycle
]]
local function initialize(): ()
	print("[DayNightCycle] Starting day/night cycle")
	print("[DayNightCycle] Cycle length:", MINUTES_PER_DAY, "real minutes")
	print("[DayNightCycle] Starting at:", START_TIME, "(dusk)")

	-- Set initial time
	Lighting.ClockTime = START_TIME

	-- Apply initial lighting
	local initialSettings: LightingPreset = getInterpolatedSettings(START_TIME)
	applyLighting(initialSettings)
end

-- Initialize
initialize()

-- Main update loop
local lastUpdate: number = 0
local UPDATE_INTERVAL: number = 0.1 -- Update every 0.1 seconds for smooth transitions

RunService.Heartbeat:Connect(function(deltaTime: number)
	lastUpdate = lastUpdate + deltaTime

	if lastUpdate >= UPDATE_INTERVAL then
		lastUpdate = 0

		-- Advance time
		local currentTime: number = Lighting.ClockTime
		local newTime: number = currentTime + (HOURS_PER_SECOND * UPDATE_INTERVAL)

		-- Wrap around at 24
		if newTime >= 24 then
			newTime = newTime - 24
		end

		Lighting.ClockTime = newTime

		-- Update lighting
		local settings: LightingPreset = getInterpolatedSettings(newTime)
		applyLighting(settings)
	end
end)
