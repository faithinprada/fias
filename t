local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("prada Loaded")
local player = Players.LocalPlayer

-- =========================
-- THEME (red as default)
-- =========================
local Theme = {
	Primary   = Color3.fromRGB(150, 0, 0), -- Kashi Empire red
	Dark      = Color3.fromRGB(12, 12, 16),
	Text      = Color3.fromRGB(230, 230, 235),
	TextDim   = Color3.fromRGB(140, 140, 150),
}

local uiScale = 0.85
local uiTransparency = 0
local currentTab = "Combat"

-- State
local hitboxEnabled = false
local hitboxSize = 5
local hitboxTransparency = 0.5
local antiWeaveEnabled = false
local headlessEnabled = false
local lowGraphicsEnabled = false

-- Punch Speed
local punchEnabled = false
local PUNCH_MIN, PUNCH_MAX, PUNCH_DEFAULT = 1.0, 10, 1.7
local currentPunchSpeed = PUNCH_DEFAULT

-- Stomp Speed
local stompEnabled = false
local STOMP_MIN, STOMP_MAX, STOMP_DEFAULT = 1.0, 10, 1.25
local currentStompSpeed = STOMP_DEFAULT

-- Glow / Rainbow
local glowEnabled = false
local rainbowEnabled = false
local rainbowConn = nil
local glowThread = nil

-- =========================
-- ROOT
-- =========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RomaniHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Floating prada button (exact size + fixed Kashi color, never changes with theme)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- fixed red
ToggleBtn.Text = "prada"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.Arcade
ToggleBtn.TextSize = 14
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.ZIndex = 50
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", ToggleBtn)
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 3

local glow = Instance.new("UIGradient", ToggleBtn)
glow.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0))
}

-- Main
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 320, 0, 500)
Main.Position = UDim2.new(0.5, -160, 0.5, -250)
Main.BackgroundColor3 = Theme.Dark
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

-- ===== Blood Snowfall Effect =====
local function createSnowflake()
	local snowflake = Instance.new("TextLabel", Main)
	snowflake.Text = "🩸"
	snowflake.Size = UDim2.new(0, 15, 0, 15)
	snowflake.BackgroundTransparency = 1
	snowflake.TextColor3 = Color3.fromRGB(170, 0, 0)
	snowflake.TextScaled = true
	snowflake.TextTransparency = 0
	snowflake.Font = Enum.Font.Arcade
	snowflake.ZIndex = 1

	local randomX = math.random(0, 300)
	snowflake.Position = UDim2.new(0, randomX, 0, -15)

	task.spawn(function()
		while snowflake and snowflake.Parent do
			for _ = 1, 300 do
				if not (snowflake and snowflake.Parent) then break end
				local currentPos = snowflake.Position
				snowflake.Position = UDim2.new(
					currentPos.X.Scale,
					currentPos.X.Offset,
					currentPos.Y.Scale,
					currentPos.Y.Offset + 1
				)
				task.wait(0.02)
			end
			if snowflake and snowflake.Parent then
				snowflake:Destroy()
			end
		end
	end)
end

task.spawn(function()
	while true do
		createSnowflake()
		task.wait(0.8)
	end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 46, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -46, 1, 0)
Content.Position = UDim2.new(0, 46, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundTransparency = 1
Header.Parent = Content

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "COMBAT SETTINGS"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(0, 100, 0, 2)
TitleLine.Position = UDim2.new(0, 12, 1, -5)
TitleLine.BackgroundColor3 = Theme.Primary
TitleLine.BorderSizePixel = 0
TitleLine.Parent = Header

-- Notification
local Notification = Instance.new("TextLabel")
Notification.Size = UDim2.new(1, -16, 0, 16)
Notification.Position = UDim2.new(0, 8, 1, -22)
Notification.BackgroundTransparency = 1
Notification.TextColor3 = Theme.Primary
Notification.Font = Enum.Font.Gotham
Notification.TextSize = 11
Notification.Visible = false
Notification.Parent = Content

-- =========================
-- SIDEBAR
-- =========================
local function createIcon(icon, y, tab)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 32, 0, 32)
	btn.Position = UDim2.new(0.5, -16, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
	btn.Text = icon
	btn.TextColor3 = Theme.TextDim
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.BorderSizePixel = 0
	btn.Parent = Sidebar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	btn.MouseButton1Click:Connect(function()
		switchTab(tab)
	end)
	return btn
end

local CombatBtn   = createIcon("⚔", 18,  "Combat")
local SettingsBtn = createIcon("⚙", 66,  "Settings")
local CustomBtn   = createIcon("🎨", 114, "Customization")
local CreditsBtn  = createIcon("★", 162, "Credits")

-- =========================
-- TABS
-- =========================
local function createTab()
	local f = Instance.new("ScrollingFrame")
	f.Size = UDim2.new(1, -16, 1, -70)
	f.Position = UDim2.new(0, 8, 0, 48)
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.ScrollBarThickness = 3
	f.CanvasSize = UDim2.new(0, 0, 0, 0)
	f.AutomaticCanvasSize = Enum.AutomaticSize.Y
	f.Visible = false
	f.Parent = Content

	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 8)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Parent = f
	return f
end

local CombatTab   = createTab()
local SettingsTab = createTab()
local CustomTab   = createTab()
local CreditsTab  = createTab()
CombatTab.Visible = true

-- =========================
-- THEME SYSTEM
-- =========================
local allAccentLines = {}
local allLabels = {}
local primaryButtons = {}
local allSliderFills = {}
local allSliderStrokes = {}

local function darken(c, amount)
	return Color3.new(
		math.clamp(c.R * amount, 0, 1),
		math.clamp(c.G * amount, 0, 1),
		math.clamp(c.B * amount, 0, 1)
	)
end

local function applyTheme()
	if not glowEnabled then
		Main.BackgroundColor3 = darken(Theme.Primary, 0.11)
		Sidebar.BackgroundColor3 = darken(Theme.Primary, 0.07)
	end

	TitleLine.BackgroundColor3 = Theme.Primary
	Notification.TextColor3 = Theme.Primary

	for _, line in pairs(allAccentLines) do
		if line and line.Parent then line.BackgroundColor3 = Theme.Primary end
	end
	for _, lbl in pairs(allLabels) do
		if lbl and lbl.Parent then lbl.TextColor3 = Theme.Primary end
	end
	for _, btn in pairs(primaryButtons) do
		if btn and btn.Parent then btn.BackgroundColor3 = Theme.Primary end
	end
	for _, fill in pairs(allSliderFills) do
		if fill and fill.Parent then fill.BackgroundColor3 = Theme.Primary end
	end
	for _, stroke in pairs(allSliderStrokes) do
		if stroke and stroke.Parent then stroke.Color = Theme.Primary end
	end
end

local function setPrimary(color)
	Theme.Primary = color
	applyTheme()
	for _, b in pairs({CombatBtn, SettingsBtn, CustomBtn, CreditsBtn}) do
		if b.TextColor3 == Color3.new(1,1,1) then
			b.BackgroundColor3 = color
		end
	end
end

-- =========================
-- GLOW
-- =========================
local function stopGlow()
	if glowThread then
		task.cancel(glowThread)
		glowThread = nil
	end
	Main.BackgroundColor3 = darken(Theme.Primary, 0.11)
	Sidebar.BackgroundColor3 = darken(Theme.Primary, 0.07)
end

local function startGlow()
	stopGlow()
	glowThread = task.spawn(function()
		while glowEnabled do
			local target = Color3.new(
				math.clamp(Theme.Primary.R * 0.55, 0, 1),
				math.clamp(Theme.Primary.G * 0.55, 0, 1),
				math.clamp(Theme.Primary.B * 0.55, 0, 1)
			)
			TweenService:Create(Main, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundColor3 = target
			}):Play()
			TweenService:Create(Sidebar, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundColor3 = darken(target, 0.7)
			}):Play()
			task.wait(2)
			if not glowEnabled then break end
			local dark = darken(Theme.Primary, 0.11)
			TweenService:Create(Main, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundColor3 = dark
			}):Play()
			TweenService:Create(Sidebar, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundColor3 = darken(Theme.Primary, 0.07)
			}):Play()
			task.wait(2)
		end
	end)
end

-- =========================
-- RAINBOW
-- =========================
local function startRainbow()
	if rainbowConn then rainbowConn:Disconnect() end
	local hue = 0
	rainbowConn = RunService.RenderStepped:Connect(function(dt)
		if not rainbowEnabled then return end
		hue = (hue + dt * 0.15) % 1
		setPrimary(Color3.fromHSV(hue, 0.85, 1))
	end)
end

local function stopRainbow()
	if rainbowConn then
		rainbowConn:Disconnect()
		rainbowConn = nil
	end
end

-- =========================
-- SCALE
-- =========================
local function applyScale()
	local baseW, baseH = 320, 500
	Main.Size = UDim2.new(0, math.floor(baseW * uiScale), 0, math.floor(baseH * uiScale))
	Main.Position = UDim2.new(0.5, -Main.Size.X.Offset/2, 0.5, -Main.Size.Y.Offset/2)
end

-- =========================
-- TAB SWITCH
-- =========================
function switchTab(name)
	currentTab = name
	CombatTab.Visible   = name == "Combat"
	SettingsTab.Visible = name == "Settings"
	CustomTab.Visible   = name == "Customization"
	CreditsTab.Visible  = name == "Credits"

	Title.Text = (name == "Combat") and "COMBAT SETTINGS" or name:upper()
	TitleLine.Size = UDim2.new(0, math.clamp(#Title.Text * 6.8, 80, 150), 0, 2)

	for _, b in pairs({CombatBtn, SettingsBtn, CustomBtn, CreditsBtn}) do
		b.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
		b.TextColor3 = Theme.TextDim
	end

	local map = {Combat = CombatBtn, Settings = SettingsBtn, Customization = CustomBtn, Credits = CreditsBtn}
	local active = map[name]
	if active then
		active.BackgroundColor3 = Theme.Primary
		active.TextColor3 = Color3.new(1,1,1)
	end
end

-- =========================
-- UI HELPERS
-- =========================
local function section(parent, text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 20)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Theme.Primary
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = parent
	table.insert(allLabels, lbl)

	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 60, 0, 2)
	line.Position = UDim2.new(0, 0, 1, -1)
	line.BackgroundColor3 = Theme.Primary
	line.BorderSizePixel = 0
	line.Parent = lbl
	table.insert(allAccentLines, line)
end

local function toggle(parent, name, default, cb)
	local h = Instance.new("Frame")
	h.Size = UDim2.new(1, 0, 0, 30)
	h.BackgroundTransparency = 1
	h.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.68, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Theme.Primary
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = h
	table.insert(allLabels, lbl)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 42, 0, 22)
	btn.Position = UDim2.new(1, -46, 0.5, -11)
	btn.BackgroundColor3 = default and Theme.Primary or Color3.fromRGB(45, 45, 52)
	btn.Text = ""
	btn.BorderSizePixel = 0
	btn.Parent = h
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 16, 0, 16)
	circle.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	circle.BackgroundColor3 = Color3.new(1,1,1)
	circle.BorderSizePixel = 0
	circle.Parent = btn
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

	local on = default
	btn.MouseButton1Click:Connect(function()
		on = not on
		btn.BackgroundColor3 = on and Theme.Primary or Color3.fromRGB(45, 45, 52)
		circle.Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		cb(on)
		Notification.Text = name .. (on and " Enabled" or " Disabled")
		Notification.Visible = true
		task.delay(1.3, function() Notification.Visible = false end)
	end)
end

local function slider(parent, name, default, min, max, cb)
	local h = Instance.new("Frame")
	h.Size = UDim2.new(1, 0, 0, 58)
	h.BackgroundTransparency = 1
	h.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.65, 0, 0, 16)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = Theme.Primary
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = h
	table.insert(allLabels, lbl)

	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0.3, 0, 0, 16)
	val.Position = UDim2.new(0.7, 0, 0, 0)
	val.BackgroundTransparency = 1
	val.Text = tostring(default)
	val.TextColor3 = Theme.TextDim
	val.Font = Enum.Font.Gotham
	val.TextSize = 12
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = h

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 58, 0, 24)
	box.Position = UDim2.new(0, 0, 0, 22)
	box.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	box.Text = tostring(default)
	box.TextColor3 = Theme.Text
	box.Font = Enum.Font.Gotham
	box.TextSize = 12
	box.BorderSizePixel = 0
	box.Parent = h
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Primary
	stroke.Thickness = 1.4
	stroke.Transparency = 0.35
	stroke.Parent = box
	table.insert(allSliderStrokes, stroke)

	local barBg = Instance.new("Frame")
	barBg.Size = UDim2.new(1, -70, 0, 10)
	barBg.Position = UDim2.new(0, 66, 0, 29)
	barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	barBg.BorderSizePixel = 0
	barBg.Active = true
	barBg.Parent = h
	Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Primary
	fill.BorderSizePixel = 0
	fill.Parent = barBg
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
	table.insert(allSliderFills, fill)

	local function setValue(n)
		n = math.clamp(n, min, max)
		if max <= 5 then
			n = math.floor(n * 100 + 0.5) / 100
		else
			n = math.floor(n * 10 + 0.5) / 10
		end
		box.Text = tostring(n)
		val.Text = tostring(n)
		fill.Size = UDim2.new(math.clamp((n - min) / (max - min), 0, 1), 0, 1, 0)
		cb(n)
	end

	box.FocusLost:Connect(function()
		local n = tonumber(box.Text)
		if n then
			setValue(n)
		else
			box.Text = tostring(default)
		end
	end)

	local dragging = false

	local function updateFromInput(input)
		local absPos = barBg.AbsolutePosition
		local absSize = barBg.AbsoluteSize
		local rel = (input.Position.X - absPos.X) / absSize.X
		rel = math.clamp(rel, 0, 1)
		setValue(min + (max - min) * rel)
	end

	barBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromInput(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromInput(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- =========================
-- COMBAT TAB
-- =========================

-- ===== HITBOX =====
section(CombatTab, "Hitbox")
toggle(CombatTab, "Hitbox Toggle", false, function(v) hitboxEnabled = v end)
slider(CombatTab, "Size", 5, 2, 8, function(v) hitboxSize = v end)
slider(CombatTab, "Transparency", 0.5, 0, 1, function(v) hitboxTransparency = v end)

-- ===== PUNCH SPEED =====
section(CombatTab, "Punch Speed")
toggle(CombatTab, "Punch Speed Toggle", false, function(v)
	punchEnabled = v
end)
slider(CombatTab, "Punch Speed", PUNCH_DEFAULT, PUNCH_MIN, PUNCH_MAX, function(v)
	currentPunchSpeed = v
end)

-- ===== STOMP SPEED =====
section(CombatTab, "Stomp Speed")
toggle(CombatTab, "Stomp Speed Toggle", false, function(v)
	stompEnabled = v
end)
slider(CombatTab, "Stomp Speed", STOMP_DEFAULT, STOMP_MIN, STOMP_MAX, function(v)
	currentStompSpeed = v
end)

-- ===== COMBAT =====
section(CombatTab, "Combat")
toggle(CombatTab, "Auto Weave", false, function(v)
	getgenv().AutoWeaveEnabled = v
	if v then StartAutoWeave() else StopAutoWeave() end
end)
slider(CombatTab, "Speed", 0.1, 0.05, 0.5, function(v) getgenv().AutoWeaveSpeed = v end)
toggle(CombatTab, "AntiWeaveStun", false, function(v) antiWeaveEnabled = v end)

-- =========================
-- SETTINGS TAB
-- =========================
section(SettingsTab, "General")
toggle(SettingsTab, "Headless", false, function(v)
	headlessEnabled = v
	setHeadless(v)
end)
toggle(SettingsTab, "Low Graphics", false, function(v)
	lowGraphicsEnabled = v
	if v then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("Texture") or obj:IsA("Decal") then
				obj.Transparency = 1
			end
		end
		Lighting.GlobalShadows = false
	end
end)

section(SettingsTab, "UI")
slider(SettingsTab, "UI Size", 0.86, 0.7, 1.3, function(v)
	uiScale = v
	applyScale()
end)
slider(SettingsTab, "UI Transparency", 0, 0, 0.75, function(v)
	uiTransparency = v
	Main.BackgroundTransparency = v
	Sidebar.BackgroundTransparency = v
end)

section(SettingsTab, "Config")

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, 0, 0, 32)
saveBtn.BackgroundColor3 = Theme.Primary
saveBtn.Text = "Save Config"
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 13
saveBtn.BorderSizePixel = 0
saveBtn.Parent = SettingsTab
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 7)
table.insert(primaryButtons, saveBtn)

local loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.new(1, 0, 0, 32)
loadBtn.BackgroundColor3 = Theme.Primary
loadBtn.Text = "Load Config"
loadBtn.TextColor3 = Color3.new(1,1,1)
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 13
loadBtn.BorderSizePixel = 0
loadBtn.Parent = SettingsTab
Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 7)
table.insert(primaryButtons, loadBtn)

saveBtn.MouseButton1Click:Connect(function()
	getgenv().RomaniConfig = {
		hitboxSize = hitboxSize,
		hitboxTransparency = hitboxTransparency,
		antiWeaveEnabled = antiWeaveEnabled,
		headlessEnabled = headlessEnabled,
	}
	Notification.Text = "Config Saved"
	Notification.Visible = true
	task.delay(1.2, function() Notification.Visible = false end)
end)

loadBtn.MouseButton1Click:Connect(function()
	local c = getgenv().RomaniConfig
	if c then
		hitboxSize = c.hitboxSize or 5
		hitboxTransparency = c.hitboxTransparency or 0.5
		antiWeaveEnabled = c.antiWeaveEnabled or false
		headlessEnabled = c.headlessEnabled or false
		setHeadless(headlessEnabled)
		Notification.Text = "Config Loaded"
		Notification.Visible = true
		task.delay(1.2, function() Notification.Visible = false end)
	end
end)

-- =========================
-- CUSTOMIZATION
-- =========================
section(CustomTab, "UI Color Customization")

local hexHolder = Instance.new("Frame")
hexHolder.Size = UDim2.new(1, 0, 0, 32)
hexHolder.BackgroundTransparency = 1
hexHolder.Parent = CustomTab

local hexLabel = Instance.new("TextLabel")
hexLabel.Size = UDim2.new(0.32, 0, 1, 0)
hexLabel.BackgroundTransparency = 1
hexLabel.Text = "Hex Color"
hexLabel.TextColor3 = Theme.Primary
hexLabel.Font = Enum.Font.Gotham
hexLabel.TextSize = 12
hexLabel.TextXAlignment = Enum.TextXAlignment.Left
hexLabel.Parent = hexHolder
table.insert(allLabels, hexLabel)

local hexBox = Instance.new("TextBox")
hexBox.Size = UDim2.new(0.65, 0, 0, 26)
hexBox.Position = UDim2.new(0.35, 0, 0.5, -13)
hexBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
hexBox.PlaceholderText = "#FF0000 or FF0000"
hexBox.Text = ""
hexBox.TextColor3 = Theme.Text
hexBox.Font = Enum.Font.Gotham
hexBox.TextSize = 12
hexBox.BorderSizePixel = 0
hexBox.Parent = hexHolder
Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 6)

local hexStroke = Instance.new("UIStroke")
hexStroke.Color = Theme.Primary
hexStroke.Thickness = 1.2
hexStroke.Transparency = 0.4
hexStroke.Parent = hexBox
table.insert(allSliderStrokes, hexStroke)

hexBox.FocusLost:Connect(function()
	local text = hexBox.Text:gsub("%s+", ""):upper()
	if text:sub(1,1) == "#" then text = text:sub(2) end
	if #text == 6 and text:match("^[0-9A-F]+$") then
		local r = tonumber(text:sub(1,2), 16)
		local g = tonumber(text:sub(3,4), 16)
		local b = tonumber(text:sub(5,6), 16)
		if r and g and b then
			stopRainbow()
			rainbowEnabled = false
			setPrimary(Color3.fromRGB(r, g, b))
			Notification.Text = "Color set to #" .. text
			Notification.Visible = true
			task.delay(1.4, function() Notification.Visible = false end)
		end
	else
		Notification.Text = "Invalid hex (use #RRGGBB)"
		Notification.Visible = true
		task.delay(1.4, function() Notification.Visible = false end)
	end
end)

local function rgbRow(parent, label, default)
	local h = Instance.new("Frame")
	h.Size = UDim2.new(1, 0, 0, 28)
	h.BackgroundTransparency = 1
	h.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.38, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = label
	lbl.TextColor3 = Theme.Primary
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = h
	table.insert(allLabels, lbl)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.58, 0, 0, 24)
	box.Position = UDim2.new(0.4, 0, 0.5, -12)
	box.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	box.Text = string.format("%d  %d  %d", default.R*255, default.G*255, default.B*255)
	box.TextColor3 = Theme.Text
	box.Font = Enum.Font.Gotham
	box.TextSize = 12
	box.BorderSizePixel = 0
	box.Parent = h
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	return box
end

local mainBox = rgbRow(CustomTab, "RGB Color", Theme.Primary)
mainBox.FocusLost:Connect(function()
	local r,g,b = mainBox.Text:match("(%d+)%s+(%d+)%s+(%d+)")
	if r then
		stopRainbow()
		rainbowEnabled = false
		setPrimary(Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)))
	end
end)

section(CustomTab, "Effects")
toggle(CustomTab, "Rainbow UI", false, function(v)
	rainbowEnabled = v
	if v then
		startRainbow()
	else
		stopRainbow()
	end
end)

toggle(CustomTab, "UI Glow", false, function(v)
	glowEnabled = v
	if v then
		startGlow()
	else
		stopGlow()
	end
end)

section(CustomTab, "Theme Presets")

local presetHolder = Instance.new("Frame")
presetHolder.Size = UDim2.new(1, 0, 0, 0)
presetHolder.BackgroundTransparency = 1
presetHolder.AutomaticSize = Enum.AutomaticSize.Y
presetHolder.Parent = CustomTab

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.48, 0, 0, 30)
grid.CellPadding = UDim2.new(0.04, 0, 0, 6)
grid.FillDirectionMaxCells = 2
grid.Parent = presetHolder

local presets = {
	{"Liquid Black", Color3.fromRGB(25, 25, 30)},
	{"Red",    Color3.fromRGB(150, 0, 0)},
	{"Purple",       Color3.fromRGB(130, 50, 180)},
	{"Ocean",        Color3.fromRGB(35, 120, 190)},
	{"Emerald",      Color3.fromRGB(35, 150, 75)},
	{"Gold",         Color3.fromRGB(190, 150, 40)},
	{"Sunset",       Color3.fromRGB(210, 90, 40)},
	{"Rose",         Color3.fromRGB(190, 60, 120)},
	{"Ice",          Color3.fromRGB(100, 170, 210)},
	{"Mono",         Color3.fromRGB(140, 140, 150)},
}

for _, p in ipairs(presets) do
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = p[2]
	b.Text = p[1]
	b.TextColor3 = (p[2].R + p[2].G + p[2].B > 1.3) and Color3.new(0,0,0) or Color3.new(1,1,1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.BorderSizePixel = 0
	b.Parent = presetHolder
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

	b.MouseButton1Click:Connect(function()
		stopRainbow()
		rainbowEnabled = false
		setPrimary(p[2])
		Notification.Text = "Theme → " .. p[1]
		Notification.Visible = true
		task.delay(1.2, function() Notification.Visible = false end)
	end)
end

-- =========================
-- CREDITS
-- =========================
local c1 = Instance.new("TextLabel")
c1.Size = UDim2.new(1, 0, 0, 26)
c1.BackgroundTransparency = 1
c1.Text = "credits: war"
c1.TextColor3 = Theme.Text
c1.Font = Enum.Font.GothamBold
c1.TextSize = 14
c1.Parent = CreditsTab

local c2 = Instance.new("TextLabel")
c2.Size = UDim2.new(1, 0, 0, 22)
c2.BackgroundTransparency = 1
c2.Text = "tiktok: faithinpradaa"
c2.TextColor3 = Theme.TextDim
c2.Font = Enum.Font.Gotham
c2.TextSize = 13
c2.Parent = CreditsTab

-- =========================
-- FUNCTIONALITY
-- =========================

-- Punch + Stomp IDs (expanded)
local punchIDs = {
	["rbxassetid://18312333191"] = true,
	["rbxassetid://18312335714"] = true,
	["rbxassetid://18312338197"] = true,
	["rbxassetid://18312340119"] = true,
	["rbxassetid://18312344029"] = true,
	["rbxassetid://18312346524"] = true,
	["rbxassetid://18312348771"] = true,
	["rbxassetid://18312351760"] = true,
	["rbxassetid://1781943850"] = true,
	["rbxassetid://17819441388"] = true,
	["rbxassetid://17819444004"] = true,
	["rbxassetid://17819446225"] = true,
}

local stompIDs = {
	["rbxassetid://18362264385"] = true,
	["rbxassetid://17837722603"] = true,
}

local function isPunch(track)
	return track and track.Animation and punchIDs[tostring(track.Animation.AnimationId)]
end

local function isStomp(track)
	return track and track.Animation and stompIDs[tostring(track.Animation.AnimationId)]
end

-- Clean Character-based animation speed handler
local animationConnections = {}

local function hookAnimations(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end
	local animator = humanoid:WaitForChild("Animator", 5)
	if not animator then return end

	local connection = animator.AnimationPlayed:Connect(function(track)
		if punchEnabled and isPunch(track) then
			pcall(function() track:AdjustSpeed(currentPunchSpeed) end)
		end
		if stompEnabled and isStomp(track) then
			pcall(function() track:AdjustSpeed(currentStompSpeed) end)
		end
	end)

	table.insert(animationConnections, connection)
end

if player.Character then
	task.spawn(hookAnimations, player.Character)
end
player.CharacterAdded:Connect(function(character)
	task.spawn(hookAnimations, character)
end)

-- Hitbox
task.spawn(function()
	while true do
		if hitboxEnabled then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						pcall(function()
							hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
							hrp.Transparency = hitboxTransparency
							hrp.CanCollide = false
						end)
					end
				end
			end
		end
		task.wait(0.08)
	end
end)

-- Auto Weave (kept exactly as before)
getgenv().AutoWeaveEnabled = false
getgenv().AutoWeaveSpeed = 0
local autoThread

function StartAutoWeave()
	if autoThread then
		task.cancel(autoThread)
		autoThread = nil
	end
	autoThread = task.spawn(function()
		local Event = ReplicatedStorage.Remotes.CombatService.RE.Weave
		while getgenv().AutoWeaveEnabled do
			pcall(function()
				Event:FireServer(true)
			end)
			task.wait(getgenv().AutoWeaveSpeed or 0)
		end
	end)
end

function StopAutoWeave()
	if autoThread then
		task.cancel(autoThread)
		autoThread = nil
	end
end

-- Anti Weave Stun
task.spawn(function()
	while true do
		if antiWeaveEnabled then
			local live = workspace:FindFirstChild("Live")
			local pl = live and live:FindFirstChild(player.Name)
			local stun = pl and pl:FindFirstChild("WeaveStun")
			if stun then pcall(function() stun:Destroy() end) end
		end
		task.wait(0.12)
	end
end)

function setHeadless(state)
	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end
	head.Transparency = state and 1 or 0
	for _, v in pairs(head:GetChildren()) do
		if v:IsA("Decal") or v:IsA("Texture") then
			v.Transparency = state and 1 or 0
		end
	end
end
player.CharacterAdded:Connect(function()
	task.wait(0.5)
	if headlessEnabled then setHeadless(true) end
end)

ToggleBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

UserInputService.InputBegan:Connect(function(i, g)
	if i.KeyCode == Enum.KeyCode.M and not g then
		Main.Visible = not Main.Visible
	end
end)

-- init
applyTheme()
applyScale()
switchTab("Combat")
