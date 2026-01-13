--[[
	PositionHUD.client.luau

	Displays the player's X,Z position in a medieval-styled HUD element.
	Updates in real-time as the player moves.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player: Player = Players.LocalPlayer

-- Medieval color palette (matching sign style)
local COLORS = {
	BACKGROUND = Color3.fromRGB(62, 39, 18),      -- Dark wood
	FRAME = Color3.fromRGB(139, 90, 43),          -- Oak wood
	BORDER = Color3.fromRGB(45, 28, 12),          -- Dark trim
	TEXT = Color3.fromRGB(235, 220, 180),         -- Parchment text
}

--[[
	Creates the position HUD UI
]]
local function createPositionHUD(): (ScreenGui, TextLabel)
	-- Main ScreenGui
	local screenGui: ScreenGui = Instance.new("ScreenGui")
	screenGui.Name = "PositionHUD"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Outer frame (border)
	local outerFrame: Frame = Instance.new("Frame")
	outerFrame.Name = "OuterFrame"
	outerFrame.Size = UDim2.new(0, 110, 0, 44)
	outerFrame.Position = UDim2.new(0, 16, 1, -60)
	outerFrame.BackgroundColor3 = COLORS.BORDER
	outerFrame.BorderSizePixel = 0
	outerFrame.Parent = screenGui

	-- Add rounded corners
	local outerCorner: UICorner = Instance.new("UICorner")
	outerCorner.CornerRadius = UDim.new(0, 6)
	outerCorner.Parent = outerFrame

	-- Inner frame (main background)
	local innerFrame: Frame = Instance.new("Frame")
	innerFrame.Name = "InnerFrame"
	innerFrame.Size = UDim2.new(1, -6, 1, -6)
	innerFrame.Position = UDim2.new(0, 3, 0, 3)
	innerFrame.BackgroundColor3 = COLORS.FRAME
	innerFrame.BorderSizePixel = 0
	innerFrame.Parent = outerFrame

	-- Add rounded corners to inner frame
	local innerCorner: UICorner = Instance.new("UICorner")
	innerCorner.CornerRadius = UDim.new(0, 4)
	innerCorner.Parent = innerFrame

	-- Position text label
	local positionLabel: TextLabel = Instance.new("TextLabel")
	positionLabel.Name = "PositionText"
	positionLabel.Size = UDim2.new(1, -12, 1, -8)
	positionLabel.Position = UDim2.new(0, 6, 0, 4)
	positionLabel.BackgroundTransparency = 1
	positionLabel.Text = "X: 0\nZ: 0"
	positionLabel.TextColor3 = COLORS.TEXT
	positionLabel.TextSize = 14
	positionLabel.Font = Enum.Font.GothamBold
	positionLabel.TextXAlignment = Enum.TextXAlignment.Left
	positionLabel.TextYAlignment = Enum.TextYAlignment.Center
	positionLabel.Parent = innerFrame

	-- Add text stroke for readability
	local stroke: UIStroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = COLORS.BACKGROUND
	stroke.Transparency = 0.3
	stroke.Parent = positionLabel

	screenGui.Parent = player:WaitForChild("PlayerGui")

	return screenGui, positionLabel
end

--[[
	Gets the player's current position, returns nil if character doesn't exist
]]
local function getPlayerPosition(): Vector3?
	local character: Model? = player.Character
	if not character then
		return nil
	end

	local humanoidRootPart: BasePart? = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not humanoidRootPart then
		return nil
	end

	return humanoidRootPart.Position
end

--[[
	Formats a number to display with no decimal places
]]
local function formatCoordinate(value: number): string
	return tostring(math.floor(value))
end

--[[
	Updates the position label with current coordinates
]]
local function updatePositionDisplay(positionLabel: TextLabel): ()
	local position: Vector3? = getPlayerPosition()

	if position then
		local xText: string = formatCoordinate(position.X)
		local zText: string = formatCoordinate(position.Z)
		positionLabel.Text = "X: " .. xText .. "\nZ: " .. zText
	else
		positionLabel.Text = "X: --\nZ: --"
	end
end

-- Initialize HUD
local screenGui: ScreenGui, positionLabel: TextLabel = createPositionHUD()

-- Update position every frame
RunService.RenderStepped:Connect(function()
	updatePositionDisplay(positionLabel)
end)

print("[PositionHUD] Position HUD initialized!")
