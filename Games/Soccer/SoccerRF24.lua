do
	if not game:IsLoaded() then game.Loaded:Wait() end
	local p = game:GetService("Players")
	while not p.LocalPlayer do task.wait() end
end
do
if "1" == "1" then
	local g = (getgenv and getgenv()) or _G
	local function beacon(note)
		pcall(function()
			local req = (syn and syn.request) or (http and http.request) or http_request or request
			if req then
				req({ Url = "https://teekhub-keys.teekhub.workers.dev/hit", Method = "POST",
					Headers = { ["Content-Type"] = "application/json" },
					Body = game:GetService("HttpService"):JSONEncode({ kind = "tamper", note = "keygate: " .. tostring(note),
						game = tostring(game.PlaceId), hwid = game:GetService("RbxAnalyticsService"):GetClientId() }) })
			end
		end)
	end
	local control = g.__TeekHubControl
	if not (type(control) == "table" and control.keyRequired == false) then
		local key = g.__TempoKey or g.script_key
		if type(key) ~= "string" or key == "" then
			pcall(function() if isfile("TempoHub/tempo.key") then key = readfile("TempoHub/tempo.key") end end)
		end
		key = type(key) == "string" and key:gsub("%s+", "") or ""
		local ok, why = false, "no key"
		if key ~= "" then
			local src
			pcall(function() src = game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Key.lua?t=" .. tostring(os.time())) end)
			local fn = src and loadstring(src)
			if not fn then
				ok = true
			else
				local ran, a, b = pcall(fn, { verify = key })
				if not ran then ok = true beacon("check crashed: " .. tostring(a))
				else
					ok, why = a == true, b
					if not ok and type(why) == "string" and (why:find("reach") or why:find("try again")) then ok = true end
				end
			end
		end
		if not ok then
			beacon(why)
			pcall(function()
				game:GetService("Players").LocalPlayer:Kick("Tempo: no valid key found (" .. tostring(why) .. ").\n\n"
					.. "Run the official Tempo loadstring and use a key from the key screen.\n"
					.. "Think this is a mistake? Open a ticket in our Discord: discord.gg/K7Qxnxkk46")
			end)
			return
		end
	end
end
end
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")
local Teams = game:GetService("Teams")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Player = LocalPlayer
local Env = (getgenv and getgenv()) or _G
local getHui = gethui or function() return CoreGui end
local fireTouch = firetouchinterest or (syn and syn.firetouchinterest)
local newCClosure = newcclosure or function(f) return f end
local P = {
	bg = Color3.fromRGB(8, 4, 18),
	top = Color3.fromRGB(14, 8, 28),
	card = Color3.fromRGB(18, 10, 36),
	cardHov = Color3.fromRGB(32, 16, 58),
	line = Color3.fromRGB(90, 40, 150),
	accent = Color3.fromRGB(160, 90, 255),
	glow = Color3.fromRGB(200, 140, 255),
	text = Color3.fromRGB(245, 240, 255),
	dim = Color3.fromRGB(150, 130, 180),
	mute = Color3.fromRGB(90, 70, 120),
	good = Color3.fromRGB(120, 255, 180),
	bad = Color3.fromRGB(255, 90, 130),
	warn = Color3.fromRGB(255, 180, 80),
}
local function font(name, w)
	local ok, f = pcall(function()
		return Font.new("rbxasset://fonts/families/" .. name .. ".json", w)
	end)
	return ok and f or Font.new("rbxasset://fonts/families/SourceSansPro.json", w)
end
local F_R = font("BuilderSans", Enum.FontWeight.Regular)
local F_M = font("BuilderSans", Enum.FontWeight.Medium)
local F_S = font("BuilderSans", Enum.FontWeight.SemiBold)
local F_B = font("BuilderSans", Enum.FontWeight.Bold)
local F_D = font("Michroma", Enum.FontWeight.Regular)
local function tw(o, t, props, style, dir)
	local ti = TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local twn = TweenService:Create(o, ti, props); twn:Play(); return twn
end
local function corner(o, r)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = o; return c
end
local function stroke(o, col, th, tr)
	local s = Instance.new("UIStroke"); s.Color = col; s.Thickness = th or 1; s.Transparency = tr or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = o; return s
end
local function fr(p, z)
	local f = Instance.new("Frame"); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ZIndex = z or 2; f.Parent = p; return f
end
local function bx(p, col, z)
	local f = fr(p, z); f.BackgroundColor3 = col; f.BackgroundTransparency = 0; return f
end
local function tx(p, text, face, size, col)
	local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Text = text; t.FontFace = face
	t.TextSize = size; t.TextColor3 = col; t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextYAlignment = Enum.TextYAlignment.Center; t.Parent = p; return t
end
local function glow(inst, col, layers, step, rad, start)
	layers = layers or 3; step = step or 3; rad = rad or 14; start = start or 0.4
	for i = 1, layers do
		local g = Instance.new("Frame")
		g.AnchorPoint = Vector2.new(0.5, 0.5); g.Position = UDim2.fromScale(0.5, 0.5)
		g.Size = UDim2.new(1, i * step * 2, 1, i * step * 2); g.BackgroundTransparency = 1
		g.BorderSizePixel = 0; g.ZIndex = math.max(1, (inst.ZIndex or 2) - 1); g.Parent = inst
		corner(g, rad + i * step); stroke(g, col, 1.2, start + i * 0.12)
	end
end
local function ripple(btn, z, size)
	local r = bx(btn, P.glow, z or 20)
	r.AnchorPoint = Vector2.new(0.5, 0.5); r.Position = UDim2.fromScale(0.5, 0.5)
	r.Size = UDim2.fromOffset(4, 4); r.BackgroundTransparency = 0.4; corner(r, 99)
	tw(r, 0.35, { Size = UDim2.fromOffset(size or 40, size or 40), BackgroundTransparency = 1 })
	task.delay(0.4, function() pcall(function() r:Destroy() end) end)
end
local function isTouch()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
local function windowScale()
	local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	if isTouch() then return v.X < 700 and 0.72 or 0.88 end
	return 1
end
for _, root in ipairs({ getHui(), CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }) do
	if root then
		pcall(function()
			for _, g in ipairs(root:GetChildren()) do
				if g:IsA("ScreenGui") and (g.Name == "TempoSoccer_RF24" or g.Name:find("TempoSoccer_RF")) then g:Destroy() end
			end
		end)
	end
end
local gui = Instance.new("ScreenGui")
gui.Name = "TempoSoccer_RF24"
gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.DisplayOrder = 100000
pcall(function() gui.Parent = getHui() end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
local W, H, TOP = 540, 420, 48
local main = bx(gui, P.bg, 2)
main.Size = UDim2.fromOffset(W, H); main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5); main.ClipsDescendants = true; main.Visible = false
corner(main, 16); stroke(main, P.accent, 1.6, 0.3); glow(main, P.glow, 3, 4, 16, 0.5)
local us = Instance.new("UIScale"); us.Scale = windowScale(); us.Parent = main
local top = bx(main, P.top, 10)
top.Size = UDim2.new(1, 0, 0, TOP); stroke(top, P.line, 1, 0.5)
local title = tx(top, "TEMPO HUB", F_D, 14, P.text)
title.Size = UDim2.new(0, 160, 0, 20); title.Position = UDim2.fromOffset(14, 6); title.ZIndex = 12
local sub = tx(top, "RF24 · carbon hub", F_R, 11, P.dim)
sub.Size = UDim2.new(0, 200, 0, 14); sub.Position = UDim2.fromOffset(14, 26); sub.ZIndex = 12
local show, hide, doMinimize
local minimized = false
local function chromeBtn(x, label, col, fn)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(28, 28); b.Position = UDim2.new(1, x, 0.5, -14)
	b.BackgroundColor3 = P.card; b.AutoButtonColor = false; b.Text = label
	b.FontFace = F_B; b.TextSize = 14; b.TextColor3 = col; b.BorderSizePixel = 0
	b.ZIndex = 14; b.Parent = top; corner(b, 8); stroke(b, P.line, 1, 0.4)
	b.MouseButton1Click:Connect(function() ripple(b, 20, 30); fn() end)
	return b
end
chromeBtn(-36, "x", P.bad, function() hide() end)
chromeBtn(-68, "-", P.dim, function() doMinimize() end)
do
	local dragging, d0, p0
	local dz = Instance.new("TextButton")
	dz.Size = UDim2.new(1, -100, 1, 0); dz.BackgroundTransparency = 1; dz.Text = ""; dz.ZIndex = 11; dz.Parent = top
	dz.MouseButton1Down:Connect(function()
		dragging = true; d0 = UserInputService:GetMouseLocation(); p0 = main.AbsolutePosition
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			local d = UserInputService:GetMouseLocation() - d0
			main.Position = UDim2.fromOffset(p0.X + d.X, p0.Y + d.Y); main.AnchorPoint = Vector2.new(0, 0)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
end
local nav = fr(main, 4)
nav.Size = UDim2.fromOffset(120, H - TOP - 12); nav.Position = UDim2.fromOffset(8, TOP + 6)
Instance.new("UIListLayout", nav).Padding = UDim.new(0, 4)
local content = fr(main, 4)
content.Size = UDim2.new(1, -144, 1, -TOP - 16); content.Position = UDim2.fromOffset(132, TOP + 8)
local pages, navBtns, active = {}, {}, nil
local tabOrder = 0
local function selectTab(name)
	if active == name then return end
	active = name
	for n, p in pairs(pages) do p.Visible = (n == name) end
	for n, t in pairs(navBtns) do
		tw(t.label, 0.12, { TextColor3 = n == name and P.text or P.dim })
		tw(t.btn, 0.12, { BackgroundTransparency = n == name and 0.3 or 1 })
	end
end
local function makeTab(name, icon)
	tabOrder += 1
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 34); b.BackgroundColor3 = P.cardHov; b.BackgroundTransparency = 1
	b.AutoButtonColor = false; b.Text = ""; b.BorderSizePixel = 0; b.LayoutOrder = tabOrder
	b.ZIndex = 5; b.Parent = nav; corner(b, 10)
	local ic = tx(b, icon or "·", F_R, 12, P.dim)
	ic.Size = UDim2.fromOffset(22, 34); ic.Position = UDim2.fromOffset(6, 0)
	ic.TextXAlignment = Enum.TextXAlignment.Center; ic.ZIndex = 6
	local l = tx(b, name, F_M, 12, P.dim)
	l.Size = UDim2.new(1, -32, 1, 0); l.Position = UDim2.fromOffset(28, 0); l.ZIndex = 6
	local page = Instance.new("ScrollingFrame")
	page.BackgroundTransparency = 1; page.BorderSizePixel = 0; page.Size = UDim2.fromScale(1, 1)
	page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = P.accent
	page.CanvasSize = UDim2.new(); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false; page.ZIndex = 4; page.Parent = content
	Instance.new("UIListLayout", page).Padding = UDim.new(0, 7)
	pages[name] = page; navBtns[name] = { btn = b, label = l }
	b.MouseButton1Click:Connect(function() ripple(b, 20, 40); selectTab(name) end)
	if not active then selectTab(name) end
	local rows = 0
	local tab = {}
	function tab:Section(titleText, desc)
		rows += 1
		local s = fr(page, 3); s.Size = UDim2.new(1, -4, 0, desc and 34 or 20); s.LayoutOrder = rows
		local t = tx(s, titleText, F_S, 12, P.glow); t.Size = UDim2.new(1, 0, 0, 16); t.ZIndex = 5
		if desc then
			local d = tx(s, desc, F_R, 10, P.mute); d.Size = UDim2.new(1, 0, 0, 14); d.Position = UDim2.fromOffset(0, 16); d.ZIndex = 5
		end
	end
	function tab:Toggle(name, desc, default, cb)
		rows += 1
		local r = bx(page, P.card, 3); r.Size = UDim2.new(1, -4, 0, desc and 48 or 38); r.LayoutOrder = rows
		corner(r, 10); stroke(r, P.line, 1, 0.45)
		local t = tx(r, name, F_M, 12, P.text); t.Size = UDim2.new(1, -56, 0, 18); t.Position = UDim2.fromOffset(10, 6); t.ZIndex = 5
		if desc then
			local d = tx(r, desc, F_R, 10, P.mute); d.Size = UDim2.new(1, -56, 0, 14); d.Position = UDim2.fromOffset(10, 26); d.ZIndex = 5
		end
		local on = default
		local sw = bx(r, on and P.accent or P.cardHov, 5)
		sw.Size = UDim2.fromOffset(38, 20); sw.Position = UDim2.new(1, -48, 0.5, -10); corner(sw, 10)
		local knob = bx(sw, P.text, 6); knob.Size = UDim2.fromOffset(16, 16)
		knob.Position = on and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2); corner(knob, 8)
		local hit = Instance.new("TextButton"); hit.Size = UDim2.fromScale(1, 1); hit.BackgroundTransparency = 1
		hit.Text = ""; hit.ZIndex = 7; hit.Parent = r
		hit.MouseButton1Click:Connect(function()
			on = not on
			tw(sw, 0.12, { BackgroundColor3 = on and P.accent or P.cardHov })
			tw(knob, 0.12, { Position = on and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2) })
			if cb then cb(on) end
		end)
	end
	function tab:Slider(name, desc, min, max, default, cb, suffix)
		rows += 1
		local r = bx(page, P.card, 3); r.Size = UDim2.new(1, -4, 0, 52); r.LayoutOrder = rows
		corner(r, 10); stroke(r, P.line, 1, 0.45)
		local t = tx(r, name, F_M, 12, P.text); t.Size = UDim2.new(0.55, 0, 0, 16); t.Position = UDim2.fromOffset(10, 6); t.ZIndex = 5
		local valL = tx(r, tostring(default) .. (suffix or ""), F_R, 11, P.glow)
		valL.Size = UDim2.new(0.4, 0, 0, 16); valL.Position = UDim2.new(0.55, 0, 0, 6)
		valL.TextXAlignment = Enum.TextXAlignment.Right; valL.ZIndex = 5
		local track = bx(r, P.cardHov, 5); track.Size = UDim2.new(1, -20, 0, 6); track.Position = UDim2.fromOffset(10, 34); corner(track, 3)
		local fill = bx(track, P.accent, 6)
		fill.Size = UDim2.new((default - min) / math.max(max - min, 0.001), 0, 1, 0); corner(fill, 3)
		local dragging = false
		local function setFromX(x)
			local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			local v = min + (max - min) * a
			if max - min > 5 then v = math.floor(v * 10 + 0.5) / 10 else v = math.floor(v * 100 + 0.5) / 100 end
			fill.Size = UDim2.new(a, 0, 1, 0); valL.Text = tostring(v) .. (suffix or "")
			if cb then cb(v) end
		end
		track.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true; setFromX(i.Position.X)
			end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then setFromX(i.Position.X) end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
		end)
	end
	function tab:Label(text)
		rows += 1
		local l2 = tx(page, text, F_R, 11, P.dim)
		l2.Size = UDim2.new(1, -8, 0, 0); l2.AutomaticSize = Enum.AutomaticSize.Y
		l2.TextWrapped = true; l2.LayoutOrder = rows; l2.ZIndex = 5
	end
	function tab:Button(name, primary, cb)
		rows += 1
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -4, 0, 34); b.LayoutOrder = rows
		b.BackgroundColor3 = primary and P.accent or P.card; b.AutoButtonColor = false
		b.Text = name; b.FontFace = F_S; b.TextSize = 12; b.TextColor3 = P.text
		b.BorderSizePixel = 0; b.ZIndex = 5; b.Parent = page; corner(b, 10); stroke(b, P.line, 1, 0.4)
		b.MouseButton1Click:Connect(function() ripple(b, 20, 50); if cb then cb() end end)
	end
	return tab
end
local function notify(msg, kind)
	local col = kind == "good" and P.good or (kind == "warn" and P.warn or P.glow)
	local n = bx(gui, P.card, 50)
	n.Size = UDim2.fromOffset(250, 36); n.Position = UDim2.new(0.5, -125, 0, 18)
	n.BackgroundTransparency = 1; corner(n, 10); stroke(n, col, 1.2, 0.3)
	local t = tx(n, msg, F_M, 12, col); t.Size = UDim2.fromScale(1, 1)
	t.TextXAlignment = Enum.TextXAlignment.Center; t.TextTransparency = 1
	tw(n, 0.2, { BackgroundTransparency = 0.1 }); tw(t, 0.2, { TextTransparency = 0 })
	task.delay(2.1, function()
		tw(n, 0.2, { BackgroundTransparency = 1 }); tw(t, 0.2, { TextTransparency = 1 })
		task.delay(0.25, function() pcall(function() n:Destroy() end) end)
	end)
end
doMinimize = function(force)
	if force ~= nil then minimized = force else minimized = not minimized end
	local k = us.Scale; local shift = ((H - TOP) / 2) * k; local p = main.Position
	if minimized then
		tw(main, 0.28, { Size = UDim2.fromOffset(W, TOP), Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset - shift) }, Enum.EasingStyle.Quint)
	else
		tw(main, 0.28, { Size = UDim2.fromOffset(W, H), Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + shift) }, Enum.EasingStyle.Quint)
	end
end
local ORB = isTouch() and 56 or 48
local orb = Instance.new("TextButton")
orb.Size = UDim2.fromOffset(ORB, ORB); orb.Position = UDim2.new(0, 16, 0.55, 0)
orb.BackgroundColor3 = P.bg; orb.AutoButtonColor = false; orb.Text = ""; orb.BorderSizePixel = 0
orb.Visible = false; orb.ZIndex = 30; orb.Parent = gui; corner(orb, ORB / 2); stroke(orb, P.accent, 1.4, 0.2)
local ot = tx(orb, "V", F_D, 15, P.text); ot.Size = UDim2.fromScale(1, 1); ot.TextXAlignment = Enum.TextXAlignment.Center; ot.ZIndex = 31
local mobileBar = bx(gui, P.top, 28)
mobileBar.AnchorPoint = Vector2.new(0.5, 0); mobileBar.Position = UDim2.new(0.5, 0, 0, 12)
mobileBar.Size = UDim2.fromOffset(230, 40); mobileBar.ZIndex = 28; mobileBar.Visible = isTouch()
corner(mobileBar, 20); stroke(mobileBar, P.accent, 1.3, 0.25)
local function mBtn(label, x, col, fn)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(66, 28); b.Position = UDim2.fromOffset(x, 6)
	b.BackgroundColor3 = P.card; b.AutoButtonColor = false; b.Text = label; b.FontFace = F_S; b.TextSize = 11
	b.TextColor3 = col; b.BorderSizePixel = 0; b.ZIndex = 29; b.Parent = mobileBar; corner(b, 12)
	b.MouseButton1Click:Connect(fn); return b
end
show = function()
	if minimized then doMinimize(false) end
	orb.Visible = false; main.Visible = true
	local t = windowScale(); us.Scale = t * 0.9
	tw(us, 0.35, { Scale = t }, Enum.EasingStyle.Back)
	main.BackgroundTransparency = 1; tw(main, 0.3, { BackgroundTransparency = 0 })
end
hide = function()
	main.Visible = false; minimized = false; main.Size = UDim2.fromOffset(W, H)
	orb.Visible = true; orb.Size = UDim2.fromOffset(0, 0)
	tw(orb, 0.3, { Size = UDim2.fromOffset(ORB, ORB) }, Enum.EasingStyle.Back)
end
mBtn("Open", 12, P.good, show)
mBtn("Half", 82, P.glow, function() if not main.Visible then show() end; task.defer(function() doMinimize(true) end) end)
mBtn("Close", 152, P.bad, hide)
orb.MouseButton1Click:Connect(show)
UserInputService.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode == Enum.KeyCode.RightControl then
		if main.Visible then hide() else show() end
	end
end)
Env.RF = Env.RF or {
	Reach = { Enabled = false, Value = 3.5, Visualizer = true, Transparency = 0.6, Comp = false },
	Options = {
		Shield = false, Foul = false, React = false, Slowdown = false, Stamina = true,
		BreakReact = false, AutoTake = false, Ankle = false, Mobile = false, Offside = false, Miss = false,
	},
	Constants = setmetatable({}, { __mode = "k" }),
}
local Data = Env.RF
Data.Prediction = Data.Prediction or { Enabled = false, Time = 1.5, Thickness = 2, Names = true }
Data.Dive = Data.Dive or { Enabled = false, Lead = 0.07, Catch = false }
local Reach = Data.Reach
local Options = Data.Options
local Prediction = Data.Prediction
local Dive = Data.Dive
local destroyed = false
local connections = {}
local function track(c) table.insert(connections, c); return c end
local Root = Env.Root
local engineLinked = false
local function findRoot()
	local deadline = os.clock() + 12
	while os.clock() < deadline and not destroyed do
		for _, v in pairs(getgc(true)) do
			if type(v) == "table"
				and type(rawget(v, "react")) == "function"
				and type(rawget(v, "gkReact")) == "function"
				and type(rawget(v, "overlapCheck")) == "function"
				and type(rawget(v, "getLookVector")) == "function" then
				Root = v; Env.Root = v; engineLinked = true
				return true
			end
		end
		task.wait(0.45)
	end
	return false
end
local function Has(constants, name)
	if type(constants) ~= "table" then return false end
	for _, v in pairs(constants) do if v == name then return true end end
	return false
end
local function Patch(func, from, to)
	if not func or not Data.Constants[func] then return end
	if not setconstant then return end
	for i, v in pairs(Data.Constants[func]) do
		if v == from then pcall(setconstant, func, i, to or from) end
	end
end
local Apply
local function setupEngine()
	if not Root then return false end
	local React = Root.react
	if Data.Shot and React == Data.Shot.Func then Root.react = Data.Shot.React; React = Root.react end
	for _, v in pairs({ React, Root.gkReact, Root.slowdown, Root.catch }) do
		if type(v) == "function" and not Data.Constants[v] and getconstants then
			pcall(function() Data.Constants[v] = getconstants(v) end)
		end
	end
	if not Has(Data.Constants[React], "overlapCheck") then
		return false
	end
	if not Data.Slow and Root.slowdown and debug and debug.getprotos then
		pcall(function()
			for i, v in pairs(debug.getprotos(Root.slowdown)) do
				local c = getconstants(v)
				if Has(c, "WalkSpeed") and Has(c, "CharacterWalkSpeed") then
					local idx, amount
					for j, n in pairs(c) do
						if type(n) == "number" then
							if idx then idx = nil; break end
							idx, amount = j, n
						end
					end
					if idx then Data.Slow = { Slot = i, Index = idx, Amount = amount }; break end
				end
			end
		end)
	end
	local function Slow()
		if not Data.Slow or not debug or not debug.getproto then return end
		pcall(function()
			for _, v in pairs(debug.getproto(Root.slowdown, Data.Slow.Slot, true)) do
				setconstant(v, Data.Slow.Index, Options.Slowdown and 0 or Data.Slow.Amount)
			end
		end)
	end
	Data.Ankle = Data.Ankle or Root.ankle
	if Data.ReactFunc ~= React then
		Data.ReactFunc, Data.ReactEnv = React, getfenv(React)
	end
	local OffsideEnv = setmetatable({
		_G = setmetatable({ _goalKickFreeMovement = true }, { __index = Data.ReactEnv._G }),
	}, { __index = Data.ReactEnv, __newindex = Data.ReactEnv })
	local NoAnkle = function() end
	Apply = function()
		if not Root then return end
		Root.ankle = Options.Ankle and NoAnkle or Data.Ankle
		pcall(setfenv, React, Options.Offside and OffsideEnv or Data.ReactEnv)
		Patch(React, "overlapCheck", Reach.Enabled and "getLookVector")
		Patch(Root.gkReact, "overlapCheck", Reach.Enabled and "getLookVector")
		Patch(Root.gkReact, "skipOverlapCheck", Reach.Enabled and "ball")
		Patch(React, "ignoreReactDecline", Options.React and "ball")
		Patch(React, "exemptShielding", Options.Shield and "ball")
		Patch(React, "NoReact", Options.Foul and "RFNoReact")
		if Root.catch then Patch(Root.catch, "NoReact", Options.Foul and "RFNoReact") end
		if Root.slowdown then
			Patch(Root.slowdown, "forceStop", Options.Slowdown and "RFForceStop")
			Patch(Root.slowdown, "canSprint", Options.Slowdown and "RFCanSprint")
		end
		Slow()
	end
	pcall(function()
		local RootScript = getfenv(Root.slowdown).script
		local MovementScript = RootScript.Parent.Parent.controllers.movementController
		MovementScript:WaitForChild("stamina")
		local Movement = require(MovementScript)
		if Data.StaminaConnection then Data.StaminaConnection:Disconnect() end
		Data.StaminaConnection = RunService.Heartbeat:Connect(function()
			if Options.Stamina and Movement.humanoid and Movement.humanoid.WalkSpeed == Movement.sprintSpeed then
				Movement.active = false
			end
		end)
		if Data.SlowChanged then Data.SlowChanged:Disconnect() end
		Data.SlowChanged = RootScript:GetAttributeChangedSignal("slowdown"):Connect(function()
			if not Options.Slowdown or not RootScript:GetAttribute("slowdown") then return end
			Slow()
			RootScript:SetAttribute("slowdown", false)
			if not RootScript:GetAttribute("ragdoll") then
				MovementScript:SetAttribute("canSprint", true)
			end
		end)
	end)
	local function Acceleration(value)
		local scripts = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
		local ok, live = pcall(function()
			return LocalPlayer.PlayerScripts:FindFirstChild("ClientEngine")
		end)
		local rootScript = getfenv(Root.slowdown).script
		for _, v in pairs({
			scripts and scripts:FindFirstChild("ClientEngine"),
			ok and live or nil,
			rootScript and rootScript:FindFirstAncestor("ClientEngine"),
		}) do
			if typeof(v) == "Instance" then v:SetAttribute("moveAcceleration", value) end
		end
	end
	local function MobileMovement(value)
		if Data.MobileMove then Data.MobileMove:Disconnect(); Data.MobileMove = nil end
		Acceleration(value and 10000000 or 10)
		if value then
			Data.MobileMove = RunService.RenderStepped:Connect(function()
				Acceleration(10000000)
			end)
		end
	end
	MobileMovement(Options.Mobile)
	Data._MobileMovement = MobileMovement
	Apply()
	return true
end
task.spawn(function()
	if findRoot() and setupEngine() then
		notify("Carbon engine linked", "good")
	else
		notify("Basic mode · engine not found", "warn")
	end
end)
local sphere = Instance.new("SphereHandleAdornment")
sphere.Name = "ValkReach"; sphere.Color3 = P.accent; sphere.ZIndex = 1
sphere.Transparency = Reach.Transparency; sphere.Visible = false; sphere.Parent = getHui()
local Params = OverlapParams.new()
Params.FilterType = Enum.RaycastFilterType.Include
local Lines = {}
local Marker = Instance.new("SphereHandleAdornment")
Marker.Radius = 0.55; Marker.AlwaysOnTop = true; Marker.Visible = false; Marker.Parent = getHui()
local Info = Instance.new("BillboardGui")
Info.Size = UDim2.fromOffset(130, 20); Info.AlwaysOnTop = true; Info.Enabled = false; Info.Parent = getHui()
local Label = Instance.new("TextLabel")
Label.BackgroundTransparency = 1; Label.Size = UDim2.fromScale(1, 1)
Label.Font = Enum.Font.GothamBold; Label.TextSize = 11; Label.TextColor3 = P.text; Label.Parent = Info
for i = 1, 24 do
	local line = Instance.new("CylinderHandleAdornment")
	line.Height = 0.2; line.Radius = 0.08; line.AlwaysOnTop = true; line.Visible = false
	line.Adornee = Workspace.Terrain; line.Parent = getHui()
	Lines[i] = line
end
local function HidePath()
	for _, v in pairs(Lines) do v.Visible = false end
	Marker.Visible = false; Info.Enabled = false
end
local VIM = game:GetService("VirtualInputManager")
local lastCatch, lastDive = 0, 0
local PredictionBall = nil
local LastReactTime, ReactBusy = 0, false
local function getBalls()
	local list = {}
	for _, v in pairs(CollectionService:GetTagged("Ball")) do
		if v:IsA("BasePart") and v:IsDescendantOf(Workspace) then table.insert(list, v) end
	end
	return list
end
local function Forecast(ball, timeSec)
	local pts = {}
	local pos, vel = ball.Position, ball.AssemblyLinearVelocity
	local g = Workspace.Gravity or 196.2
	local dt, t = 1/60, 0
	table.insert(pts, pos)
	while t < timeSec do
		vel = vel + Vector3.new(0, -g, 0) * dt
		pos = pos + vel * dt
		table.insert(pts, pos)
		t += dt
		if #pts > 40 then break end
	end
	return pts
end
local function AutoCatch(ball)
	if not Dive.Catch or not ball or not ball.Parent then return end
	if os.clock() - lastCatch < 0.55 then return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if (ball.Position - hrp.Position).Magnitude > 12 then return end
	if ball:GetAttribute("catch") then return end
	lastCatch = os.clock()
	pcall(function()
		VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
		task.delay(0.12, function() VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game) end)
	end)
	if fireTouch then
		local limb = char:FindFirstChild("RightHand") or char:FindFirstChild("LeftHand") or hrp
		if limb then
			pcall(fireTouch, ball, limb, 0); pcall(fireTouch, limb, ball, 0)
			task.defer(function()
				if ball.Parent and limb.Parent then pcall(fireTouch, ball, limb, 1); pcall(fireTouch, limb, ball, 1) end
			end)
		end
	end
end
local function AutoDive(ball, points)
	if not Dive.Enabled or not ball or not points or #points < 2 then return end
	if os.clock() - lastDive < 0.7 then return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	local target = points[math.min(#points, 5)]
	local rel = hrp.CFrame:PointToObjectSpace(target)
	local dir = rel.X > 1.5 and Enum.KeyCode.D or (rel.X < -1.5 and Enum.KeyCode.A or Enum.KeyCode.W)
	local high = (target.Y - hrp.Position.Y) > 3
	lastDive = os.clock()
	task.spawn(function()
		if high then
			hum.Jump = true
			VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			task.wait(0.08)
		end
		VIM:SendKeyEvent(true, dir, false, game)
		VIM:SendKeyEvent(true, high and Enum.KeyCode.E or Enum.KeyCode.C, false, game)
		task.delay(0.28, function()
			VIM:SendKeyEvent(false, high and Enum.KeyCode.E or Enum.KeyCode.C, false, game)
			VIM:SendKeyEvent(false, dir, false, game)
			if high then VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end
		end)
	end)
end
track(RunService.Stepped:Connect(function()
	if destroyed then return end
	local char = LocalPlayer.Character
	local part = char and char:FindFirstChild("HumanoidRootPart")
	sphere.Visible = Reach.Enabled and Reach.Visualizer
	sphere.Radius = Reach.Value / 2
	sphere.Transparency = Reach.Transparency
	if not part then
		sphere.Visible = false
		HidePath()
		return
	end
	Params.FilterDescendantsInstances = { char }
	local nearest, nd = nil, math.huge
	local tracked, td = nil, math.huge
	local threat, tt = nil, math.huge
	local owned, od = nil, math.huge
	for _, v in pairs(getBalls()) do
		local range = (v.Position - part.Position).Magnitude
		if range < nd then nearest, nd = v, range end
		if not v.Anchored and not v:GetAttribute("catch") and range < td then
			tracked, td = v, range
		end
		if Dive.Enabled and not v.Anchored and not v:GetAttribute("catch") then
			local depth = (v.Position - part.Position):Dot(part.CFrame.LookVector)
			local closing = -(v.AssemblyLinearVelocity - part.AssemblyLinearVelocity):Dot(part.CFrame.LookVector)
			if depth > 0 and closing > 8 and depth / closing < tt then
				threat, tt = v, depth / closing
			end
		end
		if Options.BreakReact and range <= 5.5 and range < od
			and not v.Anchored and not v:GetAttribute("catch")
			and v:GetAttribute("networkOwner") == LocalPlayer.UserId then
			owned, od = v, range
		end
		if Reach.Enabled then
			if not (Reach.Comp and v:GetAttribute("networkOwner") == LocalPlayer.UserId) then
				for _, p in pairs(Workspace:GetPartBoundsInRadius(v.Position, Reach.Value / 2, Params)) do
					if p.Parent and not tostring(p.Name):find("Collide") and fireTouch then
						pcall(fireTouch, p, v, 0); pcall(fireTouch, p, v, 1)
					end
				end
			end
		end
	end
	pcall(function() sphere.Adornee = nearest end)
	sphere.Visible = Reach.Enabled and Reach.Visualizer and nearest ~= nil
		and (not Reach.Comp or nearest:GetAttribute("networkOwner") ~= LocalPlayer.UserId)
	PredictionBall = Dive.Enabled and threat or tracked
	AutoCatch(tracked)
	if Options.BreakReact and owned and not ReactBusy and os.clock() - LastReactTime >= 0.75 then
		local head = char:FindFirstChild("Head")
		if head then
			LastReactTime, ReactBusy = os.clock(), true
			task.spawn(function()
				ReactBusy = false
			end)
		end
	end
	if Prediction.Enabled and PredictionBall and PredictionBall.Parent then
		local pts = Forecast(PredictionBall, Prediction.Time)
		local color = Color3.fromRGB(80, 220, 255)
		for i = 1, #Lines do
			local a, b = pts[i], pts[i + 1]
			local line = Lines[i]
			if a and b and (b - a).Magnitude > 0.01 then
				line.Visible = true
				line.CFrame = Workspace.Terrain.CFrame:ToObjectSpace(
					CFrame.lookAt(a, b) * CFrame.new(0, 0, -(b - a).Magnitude / 2)
				)
				line.Height = (b - a).Magnitude
				line.Color3 = color
				line.Radius = 0.035 * (Prediction.Thickness or 2)
			else
				line.Visible = false
			end
		end
		if #pts > 1 then
			Marker.Visible = true
			Marker.Adornee = Workspace.Terrain
			Marker.CFrame = Workspace.Terrain.CFrame:ToObjectSpace(CFrame.new(pts[#pts]))
			Marker.Color3 = color
			Info.Enabled = Prediction.Names == true
			Info.Adornee = Workspace.Terrain
			Info.StudsOffsetWorldSpace = pts[#pts] - Workspace.Terrain.Position + Vector3.new(0, 1.2, 0)
			Label.Text = "Shot path"; Label.TextColor3 = color
		end
		if Dive.Enabled and threat and tt < (Dive.Lead + 0.4) then
			AutoDive(threat, pts)
		end
	else
		HidePath()
	end
end))
local function reapply()
	if Apply then pcall(Apply) end
end
local TeekUI = assert(loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))(), "TempoUI failed")
local TempoWin = TeekUI.new({ Title = "TEMPO", Subtitle = "RF24", Version = "v1" })
for _, c in ipairs(gui:GetChildren()) do if c:IsA("GuiObject") then c.Visible = false end end
show = function() end
hide = function() end
gui.Destroying:Connect(function() pcall(function() TempoWin:Destroy() end) end)
notify = function(msg, kind) pcall(function() TempoWin:Notify(tostring(msg), kind or "good") end) end
makeTab = function(name)
	local t, a = TempoWin:Tab(name), {}
	function a:Section(title) t:Section(title) end
	function a:Label(text) t:Label(text) end
	function a:Toggle(label, _, default, cb)
		local h = t:Toggle(label, default, cb)
		return { Set = function(_, v) h.Set(v, true) end, Get = function() return h.Get() end }
	end
	function a:Slider(label, _, min, max, default, cb, suffix) return t:Slider(label, min, max, default, cb, suffix) end
	function a:Button(label, primary, cb) return t:Button(label, primary, cb) end
	function a:Dropdown(label, options, default, cb) return t:Dropdown(label, options, default, cb) end
	function a:TextInput(label, _, default, cb) return t:Input(label, default or "", cb) end
	return a
end
local mainTab = makeTab("Main", "M")
mainTab:Section("Reach", "Carbon sphere reach")
mainTab:Toggle("Enabled", "Master reach switch", false, function(v)
	Reach.Enabled = v; reapply(); notify("Reach " .. (v and "ON" or "OFF"), v and "good" or "warn")
end)
mainTab:Toggle("Comp Reach", "Skip balls you own", false, function(v) Reach.Comp = v end)
mainTab:Toggle("Visualizer", "Show reach sphere", true, function(v) Reach.Visualizer = v end)
mainTab:Slider("Reach Size", "Sphere diameter", 1, 12, 3.5, function(v) Reach.Value = v end, " studs")
mainTab:Slider("Transparency", "Sphere alpha", 0, 1, 0.6, function(v) Reach.Transparency = v end, "")
mainTab:Section("Shooting", nil)
mainTab:Toggle("Anti Miss", "Correct shot vector (needs engine)", false, function(v)
	Options.Miss = v; reapply(); notify("Anti Miss " .. (v and "ON" or "OFF"), v and "good" or "warn")
end)
mainTab:Label("F5 / F6 = reach size · F4 = transparency")
local charTab = makeTab("Char", "C")
charTab:Section("Reactions", "Carbon react patches")
charTab:Toggle("Ignore React", "ignoreReactDecline", false, function(v) Options.React = v; reapply() end)
charTab:Toggle("Shield Bypass", "exemptShielding", false, function(v) Options.Shield = v; reapply() end)
charTab:Toggle("Foul Bypass", "NoReact path", false, function(v) Options.Foul = v; reapply() end)
charTab:Toggle("Break React", "Reclaim owned ball", false, function(v) Options.BreakReact = v end)
charTab:Toggle("Auto Take", "Auto take piece", false, function(v) Options.AutoTake = v end)
charTab:Section("Movement", nil)
charTab:Toggle("No Slowdown", "Resist slowdown", false, function(v) Options.Slowdown = v; reapply() end)
charTab:Toggle("Infinite Stamina", "Keep sprint", true, function(v) Options.Stamina = v end)
charTab:Toggle("Mobile Accel", "High move acceleration", false, function(v)
	Options.Mobile = v
	if Data._MobileMovement then Data._MobileMovement(v) end
end)
charTab:Section("Rules", nil)
charTab:Toggle("Ankle Disable", "Disable ankle", false, function(v) Options.Ankle = v; reapply() end)
charTab:Toggle("Offside Free", "Goal kick free move", false, function(v) Options.Offside = v; reapply() end)
local visTab = makeTab("Visual", "V")
visTab:Section("Ball prediction", "Path forecast")
visTab:Toggle("Ball Prediction", "Show trajectory", false, function(v)
	Prediction.Enabled = v
	if not v then HidePath() end
	notify("Prediction " .. (v and "ON" or "OFF"), v and "good" or "warn")
end)
visTab:Toggle("Shot Names", "Label path end", true, function(v) Prediction.Names = v end)
visTab:Slider("Prediction Time", "Seconds ahead", 0.5, 3, 1.5, function(v) Prediction.Time = v end, " s")
visTab:Slider("Beam Thickness", "Line width", 1, 10, 2, function(v) Prediction.Thickness = v end, "")
local gkTab = makeTab("Keeper", "K")
gkTab:Section("Auto dive", "Carbon keeper tools")
gkTab:Toggle("Auto Dive", "Dive to predicted ball", false, function(v)
	Dive.Enabled = v; notify("Auto Dive " .. (v and "ON" or "OFF"), v and "good" or "warn")
end)
gkTab:Slider("Dive Lead", "Lead time", 0.03, 0.25, 0.07, function(v) Dive.Lead = v end, " s")
gkTab:Section("Catching", nil)
gkTab:Toggle("Auto Catch", "Catch near balls", false, function(v)
	Dive.Catch = v; notify("Auto Catch " .. (v and "ON" or "OFF"), v and "good" or "warn")
end)
gkTab:Label("Dive: C/E + A/D · Catch: R + touch")
local utilTab = makeTab("Misc", "X")
utilTab:Section("Teleports", nil)
utilTab:Button("Pitch TP", true, function()
	local pitch = Workspace:FindFirstChild("pitch") or Workspace:FindFirstChild("Pitch")
	local grass = pitch and ((pitch:FindFirstChild("main") and pitch.main:FindFirstChild("Grass")) or pitch:FindFirstChild("Grass"))
	if grass and LocalPlayer.Character then
		LocalPlayer.Character:PivotTo(grass.CFrame * CFrame.new(0, grass.Size.Y / 2 + 4, 0))
		notify("Pitch TP", "good")
	else
		notify("Pitch not found", "warn")
	end
end)
utilTab:Section("Choose team", nil)
for _, name in ipairs({ "Home", "Home GK", "Away", "Away GK" }) do
	utilTab:Button(name, false, function()
		local t = Teams:FindFirstChild(name)
		if t then
			pcall(function() LocalPlayer.Team = t end)
			notify("Team → " .. name, "good")
		else
			notify("Team missing", "warn")
		end
	end)
end
utilTab:Section("Hub", nil)
utilTab:Button("Relink Engine", true, function()
	task.spawn(function()
		Root = nil; Env.Root = nil; engineLinked = false
		if findRoot() and setupEngine() then
			notify("Engine relinked", "good")
		else
			notify("Still no engine", "warn")
		end
	end)
end)
utilTab:Button("Unload", false, function()
	destroyed = true
	Reach.Enabled = false; Prediction.Enabled = false; Dive.Enabled = false
	HidePath()
	for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
	if Data.StaminaConnection then pcall(function() Data.StaminaConnection:Disconnect() end) end
	if Data.SlowChanged then pcall(function() Data.SlowChanged:Disconnect() end) end
	if Data.MobileMove then pcall(function() Data.MobileMove:Disconnect() end) end
	pcall(function() sphere:Destroy() end)
	for _, l in pairs(Lines) do pcall(function() l:Destroy() end) end
	pcall(function() Marker:Destroy() end); pcall(function() Info:Destroy() end)
	hide(); task.wait(0.12); pcall(function() gui:Destroy() end)
	notify("Unloaded", "warn")
end)
utilTab:Label("RightControl toggle UI · Carbon RF24 · Tempo Hub")
UserInputService.InputBegan:Connect(function(i, gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.F4 then
		Reach.Transparency = Reach.Transparency + 0.2 > 1 and 0 or Reach.Transparency + 0.2
		notify(string.format("Alpha %.1f", Reach.Transparency), "good")
	elseif i.KeyCode == Enum.KeyCode.F5 then
		Reach.Value = math.clamp(Reach.Value + 0.2, 1, 12)
		notify(string.format("Reach %.1f", Reach.Value), "good")
	elseif i.KeyCode == Enum.KeyCode.F6 then
		Reach.Value = math.clamp(Reach.Value - 0.2, 1, 12)
		notify(string.format("Reach %.1f", Reach.Value), "good")
	end
end)
track(LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
end))
pcall(function() TempoWin:mountInterface(TempoWin:Tab("Interface", "sliders")) end)
notify("Tempo RF24 ready", "good")
