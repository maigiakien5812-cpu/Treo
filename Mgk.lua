loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/MergeaNuke"))()
-- FPS Counter + Lag Reducer v2 - LocalScript
-- Đặt vào: StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then warn("[GUI] Không tìm thấy PlayerGui!") return end

local existing = playerGui:FindFirstChild("FPSLagGui")
if existing then existing:Destroy() end

-- ============================================================
-- BIẾN TRẠNG THÁI
-- ============================================================
local lagEnabled = false
local panelOpen = true  -- trạng thái thu gọn panel fix lag
local hiddenObjects = {} -- lưu các object đã ẩn để restore

-- ============================================================
-- GUI SETUP
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FPSLagGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Main Frame (tự resize theo nội dung)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 190, 0, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = frame

-- ============================================================
-- HELPER: Label & Button
-- ============================================================
local function makeLabel(text, color, order)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 22)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.GothamBold
	l.TextScaled = false
	l.TextSize = 14
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Text = text
	l.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	l.LayoutOrder = order or 0
	l.Parent = frame
	return l
end

local function makeButton(text, color, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 28)
	b.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.LayoutOrder = order or 0
	b.Parent = frame
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

-- Divider
local function makeDivider(order)
	local d = Instance.new("Frame")
	d.Size = UDim2.new(1, 0, 0, 1)
	d.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	d.BorderSizePixel = 0
	d.LayoutOrder = order
	d.Parent = frame
	return d
end

-- ============================================================
-- LABELS & BUTTONS
-- ============================================================
local fpsLabel    = makeLabel("FPS: --",  Color3.fromRGB(0, 255, 0), 1)
local pingLabel   = makeLabel("Ping: --", Color3.fromRGB(100, 200, 255), 2)

makeDivider(3)

-- Header row: "Fix Lag" + nút thu gọn
local headerRow = Instance.new("Frame")
headerRow.Size = UDim2.new(1, 0, 0, 28)
headerRow.BackgroundTransparency = 1
headerRow.LayoutOrder = 4
headerRow.Parent = frame

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -36, 1, 0)
headerTitle.Position = UDim2.new(0, 0, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 13
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Text = "⚙️ Fix Lag"
headerTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
headerTitle.Parent = headerRow

local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 30, 0, 24)
collapseBtn.Position = UDim2.new(1, -30, 0.5, -12)
collapseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
collapseBtn.BorderSizePixel = 0
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.TextSize = 14
collapseBtn.Text = "▲"
collapseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
collapseBtn.Parent = headerRow
Instance.new("UICorner", collapseBtn).CornerRadius = UDim.new(0, 6)

-- Panel chứa các nút fix lag (có thể thu gọn)
local lagPanel = Instance.new("Frame")
lagPanel.Size = UDim2.new(1, 0, 0, 0)
lagPanel.AutomaticSize = Enum.AutomaticSize.Y
lagPanel.BackgroundTransparency = 1
lagPanel.LayoutOrder = 5
lagPanel.Parent = frame

local lagPanelLayout = Instance.new("UIListLayout")
lagPanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
lagPanelLayout.Padding = UDim.new(0, 4)
lagPanelLayout.Parent = lagPanel

local function makeSubButton(text, color, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 28)
	b.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.LayoutOrder = order or 0
	b.Parent = lagPanel
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local lagBtn   = makeSubButton("⚡ Bật Giảm Lag",       Color3.fromRGB(40, 100, 40),  1)
local nukeBtn  = makeSubButton("💣 Xoá Vật Thể (Mạnh)", Color3.fromRGB(120, 40, 40),  2)
local resetBtn = makeSubButton("↺ Reset Tất Cả",        Color3.fromRGB(60, 60, 60),   3)

-- ============================================================
-- THU GỌN / MỞ RỘNG PANEL FIX LAG
-- ============================================================
local function setPanelOpen(open)
	panelOpen = open
	lagPanel.Visible = open
	collapseBtn.Text = open and "▲" or "▼"
end

collapseBtn.MouseButton1Click:Connect(function()
	setPanelOpen(not panelOpen)
end)

-- ============================================================
-- DRAG
-- ============================================================
local dragging, dragStart, startPos = false, nil, nil

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- ============================================================
-- FPS + PING COUNTER
-- ============================================================
local frameCount = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()
	frameCount += 1
	local now = tick()
	local elapsed = now - lastTime

	if elapsed >= 1 then
		local fps = math.round(frameCount / elapsed)

		fpsLabel.Text = "FPS: " .. fps
		if fps >= 60 then
			fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		elseif fps >= 30 then
			fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		else
			fpsLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		end

		local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		pingLabel.Text = "Ping: " .. math.round(ping) .. "ms"
		if ping < 80 then
			pingLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		elseif ping < 150 then
			pingLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		else
			pingLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		end

		frameCount = 0
		lastTime = now
	end
end)

-- ============================================================
-- LAG REDUCER NHẸ (như cũ)
-- ============================================================
local function applyLagReduction()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9

	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("BloomEffect") or effect:IsA("BlurEffect")
			or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect")
			or effect:IsA("DepthOfFieldEffect") then
			effect.Enabled = false
		end
	end

	workspace.StreamingEnabled = true

	local count = 0
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and count < 500 then
			obj.CastShadow = false
			count += 1
		end
	end
end

local function resetQuality()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
	Lighting.GlobalShadows = true

	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("BloomEffect") or effect:IsA("BlurEffect")
			or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect")
			or effect:IsA("DepthOfFieldEffect") then
			effect.Enabled = true
		end
	end
end

-- ============================================================
-- NHE ÁP DỤNG: Xoá vật thể (ẩn hết Decal, Texture, MeshPart nhỏ...)
-- Giữ lại character của player & baseplate
-- ============================================================
local nukeEnabled = false

local KEEP_TAGS = {
	"HumanoidRootPart", "Torso", "Head",
	"UpperTorso", "LowerTorso",
	"LeftUpperArm", "LeftLowerArm", "LeftHand",
	"RightUpperArm", "RightLowerArm", "RightHand",
	"LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
	"RightUpperLeg", "RightLowerLeg", "RightFoot",
}

local function isCharacterPart(obj)
	for _, p in ipairs(Players:GetPlayers()) do
		local char = p.Character
		if char and obj:IsDescendantOf(char) then
			return true
		end
	end
	return false
end

local function applyNuke()
	hiddenObjects = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		-- Bỏ qua character của tất cả player
		if isCharacterPart(obj) then continue end

		-- Ẩn Decal, Texture, ParticleEmitter, Trail, Beam (nặng GPU)
		if obj:IsA("Decal") or obj:IsA("Texture")
			or obj:IsA("ParticleEmitter") or obj:IsA("Trail")
			or obj:IsA("Beam") or obj:IsA("SelectionBox")
			or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
			if obj.Enabled ~= nil and obj.Enabled then
				obj.Enabled = false
				table.insert(hiddenObjects, {obj = obj, prop = "Enabled"})
			elseif obj:IsA("Decal") or obj:IsA("Texture") then
				obj.Transparency = 1
				table.insert(hiddenObjects, {obj = obj, prop = "Transparency", val = 0})
			end

		-- Ẩn BasePart không phải baseplate (ẩn thay vì xoá để restore được)
		elseif obj:IsA("BasePart") then
			local name = obj.Name:lower()
			-- Giữ lại baseplate và SpawnLocation
			if name == "baseplate" or name == "spawnlocation" then continue end
			if not obj.Locked and obj.Transparency < 1 then
				obj.Transparency = 1
				obj.CastShadow = false
				table.insert(hiddenObjects, {obj = obj, prop = "Transparency", val = obj.Transparency})
			end

		-- Xoá Sound để giảm tải audio
		elseif obj:IsA("Sound") and obj.Playing then
			obj:Stop()
			table.insert(hiddenObjects, {obj = obj, prop = "Sound"})
		end
	end
end

local function restoreNuke()
	for _, entry in ipairs(hiddenObjects) do
		local obj = entry.obj
		if not obj or not obj.Parent then continue end

		if entry.prop == "Enabled" then
			obj.Enabled = true
		elseif entry.prop == "Transparency" then
			obj.Transparency = entry.val or 0
		end
		-- Sound không auto resume, để tự nhiên
	end
	hiddenObjects = {}
end

-- ============================================================
-- BUTTON EVENTS
-- ============================================================
lagBtn.MouseButton1Click:Connect(function()
	lagEnabled = not lagEnabled
	if lagEnabled then
		applyLagReduction()
		lagBtn.Text = "✅ Đang Giảm Lag"
		lagBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 30)
	else
		resetQuality()
		lagBtn.Text = "⚡ Bật Giảm Lag"
		lagBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
	end
end)

nukeBtn.MouseButton1Click:Connect(function()
	nukeEnabled = not nukeEnabled
	if nukeEnabled then
		applyNuke()
		nukeBtn.Text = "✅ Đã Xoá Vật Thể"
		nukeBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
	else
		restoreNuke()
		nukeBtn.Text = "💣 Xoá Vật Thể (Mạnh)"
		nukeBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
	end
end)

resetBtn.MouseButton1Click:Connect(function()
	-- Reset tất cả
	lagEnabled = false
	nukeEnabled = false
	resetQuality()
	restoreNuke()
	lagBtn.Text = "⚡ Bật Giảm Lag"
	lagBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
	nukeBtn.Text = "💣 Xoá Vật Thể (Mạnh)"
	nukeBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
end)
