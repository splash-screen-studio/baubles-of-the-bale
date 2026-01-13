--[[
	CoordinateSigns.server.luau

	Creates medieval-style coordinate signs at key positions around the map.
	Each sign displays its X,Z position and faces toward the origin (0,0).
]]

local Workspace = game:GetService("Workspace")

-- Configuration for sign positions
-- Each entry: { position = Vector3, text = string }
local SIGN_DATA: {{position: Vector3, text: string}} = {
	{ position = Vector3.new(-60, 0, 0), text = "X: -60\nZ: 0" },
	{ position = Vector3.new(60, 0, 0), text = "X: 60\nZ: 0" },
	{ position = Vector3.new(0, 0, -60), text = "X: 0\nZ: -60" },
	{ position = Vector3.new(0, 0, 60), text = "X: 0\nZ: 60" },
}

-- Medieval color palette
local COLORS = {
	POST_WOOD = Color3.fromRGB(101, 67, 33),      -- Dark oak brown
	SIGN_WOOD = Color3.fromRGB(139, 90, 43),      -- Lighter oak
	SIGN_BORDER = Color3.fromRGB(62, 39, 18),     -- Dark trim
	TEXT_COLOR = Color3.fromRGB(45, 30, 15),      -- Dark brown ink
}

-- Sign dimensions
local POST_HEIGHT: number = 8
local POST_WIDTH: number = 1.5
local SIGN_WIDTH: number = 12
local SIGN_HEIGHT: number = 6
local SIGN_THICKNESS: number = 0.8
local BORDER_SIZE: number = 0.4

--[[
	Creates a medieval wooden post
]]
local function createPost(parent: Instance, position: Vector3): Part
	local post: Part = Instance.new("Part")
	post.Name = "WoodenPost"
	post.Size = Vector3.new(POST_WIDTH, POST_HEIGHT, POST_WIDTH)
	post.Position = position + Vector3.new(0, POST_HEIGHT / 2, 0)
	post.Anchored = true
	post.Color = COLORS.POST_WOOD
	post.Material = Enum.Material.Wood
	post.Parent = parent

	return post
end

--[[
	Creates decorative post cap (medieval style finial)
]]
local function createPostCap(parent: Instance, postPosition: Vector3): Part
	local cap: Part = Instance.new("Part")
	cap.Name = "PostCap"
	cap.Size = Vector3.new(POST_WIDTH + 0.5, 1, POST_WIDTH + 0.5)
	cap.Position = postPosition + Vector3.new(0, POST_HEIGHT + 0.5, 0)
	cap.Anchored = true
	cap.Color = COLORS.SIGN_BORDER
	cap.Material = Enum.Material.Wood
	cap.Parent = parent

	return cap
end

--[[
	Creates the sign board with border frame
]]
local function createSignBoard(parent: Instance, position: Vector3, lookAtOrigin: boolean): Part
	-- Main sign board
	local signBoard: Part = Instance.new("Part")
	signBoard.Name = "SignBoard"
	signBoard.Size = Vector3.new(SIGN_WIDTH, SIGN_HEIGHT, SIGN_THICKNESS)
	signBoard.Position = position + Vector3.new(0, POST_HEIGHT - 1, 0)
	signBoard.Anchored = true
	signBoard.Color = COLORS.SIGN_WOOD
	signBoard.Material = Enum.Material.Wood
	signBoard.Parent = parent

	-- Calculate rotation to face origin (0, 0, 0)
	local signPos: Vector3 = signBoard.Position
	local origin: Vector3 = Vector3.new(0, signPos.Y, 0)
	local direction: Vector3 = (origin - signPos).Unit

	-- Set the CFrame to look at origin
	signBoard.CFrame = CFrame.lookAt(signBoard.Position, origin)

	-- Create border frame pieces
	local borderPositions: {{name: string, size: Vector3, offset: Vector3}} = {
		-- Top border
		{
			name = "TopBorder",
			size = Vector3.new(SIGN_WIDTH + BORDER_SIZE * 2, BORDER_SIZE, SIGN_THICKNESS + 0.1),
			offset = Vector3.new(0, SIGN_HEIGHT / 2 + BORDER_SIZE / 2, 0)
		},
		-- Bottom border
		{
			name = "BottomBorder",
			size = Vector3.new(SIGN_WIDTH + BORDER_SIZE * 2, BORDER_SIZE, SIGN_THICKNESS + 0.1),
			offset = Vector3.new(0, -SIGN_HEIGHT / 2 - BORDER_SIZE / 2, 0)
		},
		-- Left border
		{
			name = "LeftBorder",
			size = Vector3.new(BORDER_SIZE, SIGN_HEIGHT, SIGN_THICKNESS + 0.1),
			offset = Vector3.new(-SIGN_WIDTH / 2 - BORDER_SIZE / 2, 0, 0)
		},
		-- Right border
		{
			name = "RightBorder",
			size = Vector3.new(BORDER_SIZE, SIGN_HEIGHT, SIGN_THICKNESS + 0.1),
			offset = Vector3.new(SIGN_WIDTH / 2 + BORDER_SIZE / 2, 0, 0)
		},
	}

	for _, borderData in borderPositions do
		local border: Part = Instance.new("Part")
		border.Name = borderData.name
		border.Size = borderData.size
		border.CFrame = signBoard.CFrame * CFrame.new(borderData.offset)
		border.Anchored = true
		border.Color = COLORS.SIGN_BORDER
		border.Material = Enum.Material.Wood
		border.Parent = parent
	end

	return signBoard
end

--[[
	Creates a SurfaceGui with text on a given face
]]
local function createSignText(signBoard: Part, text: string, face: Enum.NormalId): SurfaceGui
	local surfaceGui: SurfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Name = "SignText_" .. face.Name
	surfaceGui.Face = face
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 50

	-- Main text label
	local textLabel: TextLabel = Instance.new("TextLabel")
	textLabel.Name = "CoordinateText"
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = COLORS.TEXT_COLOR
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.Antique
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Parent = surfaceGui

	-- Add text stroke for medieval carved look
	local stroke: UIStroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(30, 20, 10)
	stroke.Transparency = 0.5
	stroke.Parent = textLabel

	surfaceGui.Parent = signBoard

	return surfaceGui
end

--[[
	Creates a complete medieval coordinate sign at the specified position
]]
local function createCoordinateSign(signData: {position: Vector3, text: string}): Model
	local signModel: Model = Instance.new("Model")
	signModel.Name = "CoordinateSign_" .. signData.text:gsub("\n", "_"):gsub(" ", ""):gsub(":", "")

	-- Create the wooden post
	local post: Part = createPost(signModel, signData.position)

	-- Create decorative cap
	createPostCap(signModel, signData.position)

	-- Create the sign board (facing origin)
	local signBoard: Part = createSignBoard(signModel, signData.position, true)

	-- Add text to both front and back faces
	createSignText(signBoard, signData.text, Enum.NormalId.Front)
	createSignText(signBoard, signData.text, Enum.NormalId.Back)

	-- Set primary part for the model
	signModel.PrimaryPart = signBoard

	-- Parent to workspace
	signModel.Parent = Workspace

	return signModel
end

--[[
	Initialize all coordinate signs
]]
local function initializeSigns(): ()
	print("[CoordinateSigns] Creating medieval coordinate signs...")

	-- Create a folder to organize signs
	local signsFolder: Folder = Instance.new("Folder")
	signsFolder.Name = "CoordinateSigns"
	signsFolder.Parent = Workspace

	-- Create each sign
	for _, signData in SIGN_DATA do
		local sign: Model = createCoordinateSign(signData)
		sign.Parent = signsFolder
		print("[CoordinateSigns] Created sign at", signData.position)
	end

	print("[CoordinateSigns] All signs created successfully!")
end

-- Run initialization
initializeSigns()
