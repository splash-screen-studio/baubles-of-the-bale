--[[
	CoordinateSigns.server.luau

	Creates medieval-style signs with funny gen-z messages.
	Each side of the sign shows a different random message.
]]

local Workspace = game:GetService("Workspace")

-- Sign positions
local SIGN_POSITIONS: {Vector3} = {
	Vector3.new(-60, 0, 0),
	Vector3.new(60, 0, 0),
	Vector3.new(0, 0, -60),
	Vector3.new(0, 0, 60),
}

-- 100 funny gen-z semi-helpful messages
local SIGN_MESSAGES: {string} = {
	"no cap\nthese baubles\ngo hard",
	"touch grass\n(and baubles)",
	"it's giving\nmedieval vibes",
	"slay those\nbaubles bestie",
	"lowkey a\nvibe here",
	"highkey\nneed baubles",
	"this hits\ndifferent fr",
	"main character\nenergy only",
	"understood the\nassignment",
	"catch baubles\nnot feelings",
	"baubles are\nbussin fr fr",
	"stay hydrated\ncatch orbs",
	"no thoughts\njust baubles",
	"living my\nbest life rn",
	"rent free in\nmy head",
	"it's the\nbaubles for me",
	"sending you\ngood vibes",
	"that's sus\nbut okay",
	"periodt.\nget baubles",
	"wig snatched\nby orbs",
	"big yikes\nif you miss",
	"vibe check\npassed",
	"sheesh\nthose baubles",
	"caught in\n4k collecting",
	"W player\nright here",
	"L if you\ndon't collect",
	"based and\nbauble-pilled",
	"sigma grindset\nbauble mode",
	"skill issue\nif you lose",
	"cope and\nseethe (or win)",
	"touch baubles\nnot grass",
	"fr fr\non god",
	"deadass\nneed orbs",
	"bet you\ncan't catch em",
	"say less\njust collect",
	"we move\ndifferent here",
	"built different\nbauble gang",
	"hits harder\nthan expected",
	"valid af\nbauble hunter",
	"ate and left\nno crumbs",
	"mother is\nmothering",
	"giving what\nneeded giving",
	"not the\nflop era",
	"served looks\nand baubles",
	"iconic behavior\nonly",
	"rent is due\n(in baubles)",
	"delulu is\nthe solulu",
	"unhinged but\nmake it work",
	"core memory\nloading...",
	"roman empire\nbut baubles",
	"let him\ncook (baubles)",
	"banger alert\nup ahead",
	"certified\nhood classic",
	"real ones\nknow",
	"iykyk\n(baubles)",
	"understood\nthe vision",
	"galaxy brain\nbauble plays",
	"speedrun this\nno cap",
	"diff is\ncrazy rn",
	"gg ez\nbauble diff",
	"ratio + L +\ncatch orbs",
	"copium levels\nrising",
	"hopium for\nmore baubles",
	"down bad\nfor orbs",
	"astronomically\ndown bad",
	"absolutely\nunhinged",
	"chaotic good\nenergy",
	"menace to\nsociety",
	"threat to\nsociety arc",
	"main quest:\nbaubles",
	"side quest:\nmore baubles",
	"NPC behavior\ndetected",
	"protagonist\nmoment",
	"anime moment\nloading",
	"this goes\nhard actually",
	"screenshot\nworthy tbh",
	"fire emoji\nfire emoji",
	"skull emoji\nvibes",
	"crying emoji\nbut happy",
	"peak fiction\nright here",
	"peak gaming\nmoment",
	"goated with\nthe sauce",
	"drip too\nhard",
	"clean af\nbauble game",
	"immaculate\nvibes only",
	"elite tier\ngameplay",
	"cracked at\nbaubles fr",
	"him/her:\nbauble demon",
	"different breed\nof player",
	"woke up and\nchose baubles",
	"violence\n(the baubles)",
	"war crimes\n(collecting)",
	"menacingly\napproaching",
	"ominously\nlooming",
	"feral mode\nactivated",
	"unalive the\ncompetition",
	"bestie please\ncollect",
	"snatched\nevery orb",
	"era: bauble\ncollector",
	"hot girl\nbauble summer",
}

-- Medieval color palette
local COLORS = {
	POST_WOOD = Color3.fromRGB(101, 67, 33),      -- Dark oak brown
	SIGN_WOOD = Color3.fromRGB(139, 90, 43),      -- Lighter oak
	SIGN_BORDER = Color3.fromRGB(62, 39, 18),     -- Dark trim
	TEXT_COLOR = Color3.fromRGB(45, 30, 15),      -- Dark brown ink
	TORCH_HANDLE = Color3.fromRGB(79, 52, 26),    -- Dark wood for torch
	TORCH_HEAD = Color3.fromRGB(54, 54, 54),      -- Charred top
	TORCH_LIGHT = Color3.fromRGB(255, 147, 41),   -- Warm firelight
}

-- Sign dimensions
local POST_HEIGHT: number = 8
local POST_WIDTH: number = 1.5
local SIGN_WIDTH: number = 12
local SIGN_HEIGHT: number = 6
local SIGN_THICKNESS: number = 3
local BORDER_SIZE: number = 0.4

-- Torch dimensions
local TORCH_HEIGHT: number = 3
local TORCH_WIDTH: number = 0.5
local TORCH_OFFSET_FROM_SIGN: number = 3

--[[
	Creates a medieval wall torch with fire and light
]]
local function createTorch(parent: Instance, position: Vector3, facingDirection: Vector3): Model
	local torchModel: Model = Instance.new("Model")
	torchModel.Name = "Torch"

	-- Torch handle/bracket
	local handle: Part = Instance.new("Part")
	handle.Name = "TorchHandle"
	handle.Size = Vector3.new(TORCH_WIDTH, TORCH_HEIGHT, TORCH_WIDTH)
	handle.Position = position
	handle.Anchored = true
	handle.Color = COLORS.TORCH_HANDLE
	handle.Material = Enum.Material.Wood
	handle.Parent = torchModel

	-- Torch head (where fire sits)
	local head: Part = Instance.new("Part")
	head.Name = "TorchHead"
	head.Size = Vector3.new(TORCH_WIDTH + 0.3, 0.5, TORCH_WIDTH + 0.3)
	head.Position = position + Vector3.new(0, TORCH_HEIGHT / 2 + 0.25, 0)
	head.Anchored = true
	head.Color = COLORS.TORCH_HEAD
	head.Material = Enum.Material.Slate
	head.Parent = torchModel

	-- Fire effect
	local fire: Fire = Instance.new("Fire")
	fire.Heat = 9
	fire.Size = 5
	fire.Color = Color3.fromRGB(255, 119, 0)
	fire.SecondaryColor = Color3.fromRGB(255, 200, 50)
	fire.Parent = head

	-- Point light for illumination
	local light: PointLight = Instance.new("PointLight")
	light.Color = COLORS.TORCH_LIGHT
	light.Brightness = 2
	light.Range = 20
	light.Shadows = true
	light.Parent = head

	-- Wall bracket (decorative iron bracket)
	local bracket: Part = Instance.new("Part")
	bracket.Name = "WallBracket"
	bracket.Size = Vector3.new(0.3, 0.3, 1.5)
	bracket.Anchored = true
	bracket.Color = Color3.fromRGB(50, 50, 50)
	bracket.Material = Enum.Material.Metal

	-- Position bracket to connect torch to sign
	local bracketPos: Vector3 = position - Vector3.new(0, TORCH_HEIGHT / 4, 0)
	bracket.CFrame = CFrame.lookAt(bracketPos, bracketPos + facingDirection) * CFrame.new(0, 0, -0.75)
	bracket.Parent = torchModel

	torchModel.PrimaryPart = handle
	torchModel.Parent = parent

	return torchModel
end

--[[
	Creates torches on both sides of a sign
]]
local function createSignTorches(parent: Instance, signBoard: Part): ()
	local signCFrame: CFrame = signBoard.CFrame
	local signRight: Vector3 = signCFrame.RightVector
	local signForward: Vector3 = signCFrame.LookVector

	-- Position torches on left and right sides of sign, offset in front and back
	local torchHeight: number = signBoard.Position.Y - 1
	local horizontalOffset: number = SIGN_WIDTH / 2 + 1.5

	-- Front-left torch
	local frontLeftPos: Vector3 = signBoard.Position
		- signRight * horizontalOffset
		- signForward * TORCH_OFFSET_FROM_SIGN
	frontLeftPos = Vector3.new(frontLeftPos.X, torchHeight, frontLeftPos.Z)
	createTorch(parent, frontLeftPos, signForward)

	-- Front-right torch
	local frontRightPos: Vector3 = signBoard.Position
		+ signRight * horizontalOffset
		- signForward * TORCH_OFFSET_FROM_SIGN
	frontRightPos = Vector3.new(frontRightPos.X, torchHeight, frontRightPos.Z)
	createTorch(parent, frontRightPos, signForward)

	-- Back-left torch
	local backLeftPos: Vector3 = signBoard.Position
		- signRight * horizontalOffset
		+ signForward * TORCH_OFFSET_FROM_SIGN
	backLeftPos = Vector3.new(backLeftPos.X, torchHeight, backLeftPos.Z)
	createTorch(parent, backLeftPos, -signForward)

	-- Back-right torch
	local backRightPos: Vector3 = signBoard.Position
		+ signRight * horizontalOffset
		+ signForward * TORCH_OFFSET_FROM_SIGN
	backRightPos = Vector3.new(backRightPos.X, torchHeight, backRightPos.Z)
	createTorch(parent, backRightPos, -signForward)
end

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

-- Track all sign text labels for updating
local allSignLabels: {TextLabel} = {}

--[[
	Gets N unique random messages from the list
]]
local function getUniqueMessages(count: number): {string}
	local available = table.clone(SIGN_MESSAGES)
	local selected: {string} = {}

	for i = 1, count do
		if #available == 0 then
			available = table.clone(SIGN_MESSAGES) -- Reset if we run out
		end
		local index = math.random(1, #available)
		table.insert(selected, available[index])
		table.remove(available, index)
	end

	return selected
end

--[[
	Updates all sign texts with unique messages
]]
local function updateAllSigns(): ()
	local messages = getUniqueMessages(#allSignLabels)
	for i, label in ipairs(allSignLabels) do
		label.Text = messages[i]
	end
	print("[Signs] Updated all signs with new messages")
end

--[[
	Creates a complete medieval sign at the specified position
]]
local function createSign(position: Vector3, index: number): Model
	local signModel: Model = Instance.new("Model")
	signModel.Name = "FunnySign_" .. index

	-- Create the wooden post
	local post: Part = createPost(signModel, position)

	-- Create decorative cap
	createPostCap(signModel, position)

	-- Create the sign board (facing origin)
	local signBoard: Part = createSignBoard(signModel, position, true)

	-- Add text to front and back faces (will be updated with unique messages)
	local frontGui = createSignText(signBoard, "", Enum.NormalId.Front)
	local backGui = createSignText(signBoard, "", Enum.NormalId.Back)

	-- Track the text labels
	table.insert(allSignLabels, frontGui:FindFirstChild("CoordinateText"))
	table.insert(allSignLabels, backGui:FindFirstChild("CoordinateText"))

	-- Add torches to illuminate both sides
	createSignTorches(signModel, signBoard)

	-- Set primary part for the model
	signModel.PrimaryPart = signBoard

	-- Parent to workspace
	signModel.Parent = Workspace

	return signModel
end

-- Create BindableEvent for other scripts to trigger sign updates
local updateSignsEvent: BindableEvent = Instance.new("BindableEvent")
updateSignsEvent.Name = "UpdateSigns"
updateSignsEvent.Parent = game:GetService("ReplicatedStorage")
updateSignsEvent.Event:Connect(updateAllSigns)

--[[
	Initialize all signs
]]
local function initializeSigns(): ()
	print("[Signs] Creating funny medieval signs...")

	-- Create a folder to organize signs
	local signsFolder: Folder = Instance.new("Folder")
	signsFolder.Name = "FunnySigns"
	signsFolder.Parent = Workspace

	-- Create each sign
	for index, position in ipairs(SIGN_POSITIONS) do
		local sign: Model = createSign(position, index)
		sign.Parent = signsFolder
		print("[Signs] Created sign", index)
	end

	-- Set initial unique messages
	updateAllSigns()

	print("[Signs] All signs created successfully!")
end

-- Run initialization
initializeSigns()
