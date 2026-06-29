loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/MergeaNuke"))()
-- FPS Counter + Lag Reducer LocalScript
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
-- GUI SETUP
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "FPSLagGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 130)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingBottom = UDim.new(0, 6)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = frame

-- Label helper
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

-- Button helper
local function makeButton(text, color, order)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 26)
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

local fpsLabel  = makeLabel("FPS: --",  Color3.fromRGB(0, 255, 0), 1)
local pingLabel = makeLabel("Ping: --", Color3.fromRGB(100, 200, 255), 2)
local lagBtn    = makeButton("⚡ Bật Giảm Lag", Color3.fromRGB(40, 100, 40), 3)
local resetBtn  = makeButton("↺ Reset Chất Lượng", Color3.fromRGB(60, 60, 60), 4)

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
-- LAG REDUCER
-- ============================================================
local lagEnabled = false

local function applyLagReduction()
	-- Giảm chất lượng đồ họa
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

	-- Tắt hiệu ứng Lighting nặng
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9

	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("BloomEffect")
			or effect:IsA("BlurEffect")
			or effect:IsA("SunRaysEffect")
			or effect:IsA("ColorCorrectionEffect")
			or effect:IsA("DepthOfFieldEffect") then
			effect.Enabled = false
		end
	end

	-- Giảm render distance của các part xa
	workspace.StreamingEnabled = true

	-- Tắt shadow trên các BasePart (giới hạn số lượng để tránh lag)
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
		if effect:IsA("BloomEffect")
			or effect:IsA("BlurEffect")
			or effect:IsA("SunRaysEffect")
			or effect:IsA("ColorCorrectionEffect")
			or effect:IsA("DepthOfFieldEffect") then
			effect.Enabled = true
		end
	end
end

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

resetBtn.MouseButton1Click:Connect(function()
	lagEnabled = false
	resetQuality()
	lagBtn.Text = "⚡ Bật Giảm Lag"
	lagBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
end)
