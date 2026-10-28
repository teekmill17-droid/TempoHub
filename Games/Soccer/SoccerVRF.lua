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
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer
local destroyed = false
local cloneRef = cloneref or function(obj) return obj end
local getHui = gethui or function() return CoreGui:FindFirstChild("RobloxGui") or CoreGui end
local fireTouch = firetouchinterest or (syn and syn.firetouchinterest) or (fluxus and fluxus.firetouchinterest) or (Krypton and Krypton.firetouchinterest)
local hookFunc = hookfunction or replaceclosure or hookfunc
local hookMeta = hookmetamethod
local newCClosure = newcclosure or function(f) return f end
local getInfo = (typeof(debug) == "table" and debug.getinfo) or getinfo
local getConns = getconnections or (syn and syn.getconnections)
local P = {
	bg = Color3.fromRGB(8, 6, 14), panel = Color3.fromRGB(12, 9, 20), rail = Color3.fromRGB(10, 8, 18),
	top = Color3.fromRGB(14, 11, 24), card = Color3.fromRGB(18, 14, 30), cardHov = Color3.fromRGB(28, 20, 44),
	line = Color3.fromRGB(55, 40, 85), off = Color3.fromRGB(40, 30, 58), accent = Color3.fromRGB(168, 110, 255),
	accentD = Color3.fromRGB(110, 55, 200), accent2 = Color3.fromRGB(255, 95, 210), glow = Color3.fromRGB(210, 175, 255),
	hot = Color3.fromRGB(245, 235, 255), text = Color3.fromRGB(240, 235, 250), dim = Color3.fromRGB(145, 135, 165),
	faint = Color3.fromRGB(95, 85, 120), good = Color3.fromRGB(90, 230, 160), warn = Color3.fromRGB(255, 190, 90),
	bad = Color3.fromRGB(255, 95, 120),
}
local MARK_IMG = "rbxassetid://1904867353"
local SKY_IMG = "rbxassetid://111702597357462"
local function font(name, weight)
	local ok, f = pcall(function() return Font.new("rbxasset://fonts/families/" .. name .. ".json", weight) end)
	if ok then return f end
	return Font.new("rbxasset://fonts/families/SourceSansPro.json", weight)
end
local F_R = font("BuilderSans", Enum.FontWeight.Regular)
local F_M = font("BuilderSans", Enum.FontWeight.Medium)
local F_S = font("BuilderSans", Enum.FontWeight.SemiBold)
local F_B = font("BuilderSans", Enum.FontWeight.Bold)
local F_D = font("Michroma", Enum.FontWeight.Regular)
local F_MO = font("RobotoMono", Enum.FontWeight.Regular)
local F_MB = font("RobotoMono", Enum.FontWeight.Bold)
local function tw(obj, t, props, style, dir)
	local ti = TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local twn = TweenService:Create(obj, ti, props)
	twn:Play()
	return twn
end
local function corner(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = o; return c end
local function stroke(o, col, th, tr)
	local s = Instance.new("UIStroke"); s.Color = col; s.Thickness = th or 1; s.Transparency = tr or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = o; return s
end
local function fr(parent, z)
	local f = Instance.new("Frame"); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ZIndex = z or 2; f.Parent = parent; return f
end
local function bx(parent, col, z)
	local f = fr(parent, z); f.BackgroundColor3 = col; f.BackgroundTransparency = 0; return f
end
local function tx(parent, text, face, size, col)
	local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Text = text; t.FontFace = face
	t.TextSize = size; t.TextColor3 = col; t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextYAlignment = Enum.TextYAlignment.Center; t.Parent = parent; return t
end
local function glow(inst, col, layers, step, rad, start)
	layers = layers or 2; step = step or 2; rad = rad or 10; start = start or 0.55
	local out = {}
	for i = 1, layers do
		local g = Instance.new("Frame")
		g.AnchorPoint = Vector2.new(0.5, 0.5); g.Position = UDim2.fromScale(0.5, 0.5)
		g.Size = UDim2.new(1, i * step * 2, 1, i * step * 2); g.BackgroundTransparency = 1; g.BorderSizePixel = 0
		g.ZIndex = (inst.ZIndex or 2) - 1; g.Parent = inst
		corner(g, rad + i * step); out[i] = stroke(g, col, 1.2, start + i * 0.14)
	end
	return out
end
local function sheen(parent, z)
	local s = Instance.new("Frame"); s.BackgroundColor3 = Color3.new(1, 1, 1); s.BackgroundTransparency = 0.94
	s.BorderSizePixel = 0; s.Size = UDim2.fromScale(1, 1); s.ZIndex = z or (parent.ZIndex + 1); s.Parent = parent
	local g = Instance.new("UIGradient"); g.Rotation = 115
	g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.4, 0.9), NumberSequenceKeypoint.new(1, 1)})
	g.Parent = s; return s
end
local function drawMark(parent, size, z)
	local h = fr(parent, z); h.Size = UDim2.fromOffset(size, size)
	local ring = fr(h, z); ring.AnchorPoint = Vector2.new(0.5, 0.5); ring.Position = UDim2.fromScale(0.5, 0.5)
	ring.Size = UDim2.fromOffset(size, size); corner(ring, size); stroke(ring, P.accent, 1.4, 0.2)
	local img = Instance.new("ImageLabel"); img.BackgroundTransparency = 1; img.Size = UDim2.fromScale(0.86, 0.86)
	img.AnchorPoint = Vector2.new(0.5, 0.5); img.Position = UDim2.fromScale(0.5, 0.5); img.Image = MARK_IMG
	img.ScaleType = Enum.ScaleType.Fit; img.ZIndex = z + 1; img.Parent = h
	local core = bx(h, P.accent, z + 3); core.AnchorPoint = Vector2.new(0.5, 0.5); core.Position = UDim2.fromScale(0.5, 0.5)
	core.Size = UDim2.fromOffset(size * 0.12, size * 0.12); core.BackgroundTransparency = 0.3; corner(core, size)
	local pulse = fr(h, z); pulse.AnchorPoint = Vector2.new(0.5, 0.5); pulse.Position = UDim2.fromScale(0.5, 0.5)
	local ps = stroke(pulse, P.glow, 1.1, 1); corner(pulse, size)
	local t0 = 0
	local conn = RunService.RenderStepped:Connect(function(dt)
		if not h.Parent then return end
		t0 += dt; local f = (t0 * 0.55) % 1
		pulse.Size = UDim2.fromOffset(size * (0.28 + f * 0.8), size * (0.28 + f * 0.8))
		ps.Transparency = 0.3 + f * 0.7; img.Rotation = math.sin(t0 * 0.7) * 5
		local s = size * 0.16 + math.sin(t0 * 2.2) * size * 0.03; core.Size = UDim2.fromOffset(s, s)
	end)
	h.Destroying:Connect(function() pcall(function() conn:Disconnect() end) end)
	return h
end
local function makeRipples(root)
	local pool, idx = {}, 0
	for i = 1, 5 do
		local r = fr(root, 55); r.AnchorPoint = Vector2.new(0.5, 0.5); r.Visible = false; corner(r, 200)
		pool[i] = { f = r, s = stroke(r, P.glow, 1.4, 0) }
	end
	return function(parent, x, y, size)
		idx = idx % 5 + 1; local e = pool[idx]
		e.f.Parent = parent; e.f.Position = UDim2.fromOffset(x, y); e.f.Size = UDim2.fromOffset(8, 8); e.f.Visible = true
		e.s.Color = P.accent; e.s.Transparency = 0.12
		tw(e.f, 0.5, { Size = UDim2.fromOffset(size or 160, size or 160) }, Enum.EasingStyle.Quint)
		local fade = tw(e.s, 0.5, { Transparency = 1 })
		fade.Completed:Once(function() e.f.Visible = false end)
	end
end
for _, root in ipairs({ (gethui and gethui()) or nil, CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }) do
	if root then
		pcall(function()
			for _, g in ipairs(root:GetChildren()) do
				if g:IsA("ScreenGui") and (string.match(g.Name, "^TempoSoccer_") or string.find(g.Name, "Rayfield") or g.Name == "KaivenHub") then
					g:Destroy()
				end
			end
		end)
	end
end
local function mount(name)
	local sg = Instance.new("ScreenGui")
	sg.Name = name; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.DisplayOrder = 100000
	local ok = pcall(function() sg.Parent = CoreGui end)
	if not ok then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	return sg
end
local W, H, SIDE, TOP = 720, 480, 168, 48
local function isTouch() return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled end
local function windowScale()
	local cam = workspace.CurrentCamera; local vp = cam and cam.ViewportSize
	if not vp or vp.Y <= 0 then return 1 end
	if isTouch() then
		local short = math.min(vp.X, vp.Y)
		if short < 500 then return math.clamp(math.min((vp.Y * 0.88) / H, (vp.X * 0.96) / W), 0.42, 0.85) end
		return math.clamp(math.min((vp.Y * 0.82) / H, (vp.X * 0.9) / W), 0.55, 0.95)
	end
	return math.clamp(math.min((vp.Y * 0.55) / H, (vp.X * 0.42) / W), 0.9, 1.4)
end
local gui = mount("TempoSoccer_TSFL_" .. math.random(1000, 9999))
local ripple = makeRipples(gui)
local main = bx(gui, P.panel, 2)
main.BackgroundTransparency = 0.12; main.Name = "Main"
main.Size = UDim2.fromOffset(W, H); main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5); main.Visible = false; main.ClipsDescendants = true; main.Active = true
corner(main, 14); stroke(main, P.accent, 1.6, 0.35)
glow(main, P.accent, 3, 4, 14, 0.45); sheen(main, 3)
local field = fr(main, 2); field.Size = UDim2.fromScale(1, 1); field.ZIndex = 2; field.ClipsDescendants = true
local function skyLayer(z, scale, trans)
	local photo = Instance.new("ImageLabel"); photo.BackgroundTransparency = 1
	photo.AnchorPoint = Vector2.new(0.5, 0.5); photo.Position = UDim2.fromScale(0.5, 0.5)
	photo.Size = UDim2.fromScale(scale, scale); photo.Image = SKY_IMG; photo.ImageTransparency = trans
	photo.ScaleType = Enum.ScaleType.Crop; photo.ZIndex = z; photo.Parent = field; corner(photo, 14); return photo
end
skyLayer(2, 1.2, 0.2); skyLayer(2, 1.1, 0.08); skyLayer(2, 1.04, 0)
local grade = Instance.new("Frame"); grade.Size = UDim2.fromScale(1, 1); grade.BackgroundColor3 = Color3.fromRGB(30, 8, 55)
grade.BackgroundTransparency = 0.72; grade.BorderSizePixel = 0; grade.ZIndex = 2; grade.Parent = field; corner(grade, 14)
local top = bx(main, P.top, 10); top.Size = UDim2.new(1, 0, 0, TOP); top.BackgroundTransparency = 0.15
stroke(top, P.line, 1, 0.55)
local brand = drawMark(top, 28, 12); brand.Position = UDim2.fromOffset(14, 10)
local title = tx(top, "Tempo Hub", F_D, 18, P.hot); title.Size = UDim2.new(0, 200, 1, 0); title.Position = UDim2.fromOffset(52, 0); title.ZIndex = 12
local sub = tx(top, "TSFL / ENI", F_R, 11, P.dim); sub.Size = UDim2.new(0, 120, 0, 14); sub.Position = UDim2.fromOffset(52, 28); sub.ZIndex = 12
local function chromeBtn(x, label, col, fn)
	local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(28, 28); b.Position = UDim2.new(1, x, 0.5, -14)
	b.BackgroundColor3 = P.card; b.BackgroundTransparency = 1; b.AutoButtonColor = false; b.Text = label
	b.FontFace = F_S; b.TextSize = 12; b.TextColor3 = col; b.BorderSizePixel = 0; b.ZIndex = 14; b.Parent = top
	corner(b, 8); local st = stroke(b, col, 1, 0.7)
	b.MouseEnter:Connect(function() tw(b, 0.12, { BackgroundTransparency = 0 }); tw(st, 0.12, { Transparency = 0.2 }) end)
	b.MouseLeave:Connect(function() tw(b, 0.12, { BackgroundTransparency = 1 }); tw(st, 0.12, { Transparency = 0.7 }) end)
	b.MouseButton1Click:Connect(function() ripple(b, 14, 14, 80); fn() end)
	return b
end
local show, hide, doMinimize
local minimized = false
chromeBtn(-34, "x", P.bad, function() hide() end)
chromeBtn(-66, "-", P.dim, function() doMinimize() end)
local rail = bx(main, P.rail, 8); rail.Size = UDim2.new(0, SIDE, 1, -TOP); rail.Position = UDim2.fromOffset(0, TOP); rail.BackgroundTransparency = 0.2
local content = fr(main, 4); content.Size = UDim2.new(1, -SIDE - 12, 1, -TOP - 12); content.Position = UDim2.fromOffset(SIDE + 6, TOP + 6)
content.ClipsDescendants = true
local pages, navBtns, active, tabCount = {}, {}, nil, 0
local function selectTab(name)
	if active == name then return end
	for n, pg in pairs(pages) do pg.Visible = (n == name) end
	for n, data in pairs(navBtns) do
		local on = (n == name)
		tw(data.label, 0.15, { TextColor3 = on and P.hot or P.dim })
		tw(data.icon, 0.15, { TextColor3 = on and P.accent or P.dim })
		tw(data.btn, 0.15, { BackgroundTransparency = on and 0.35 or 1 })
	end
	active = name
end
local function makeTab(name, icon)
	local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -12, 0, 38); b.Position = UDim2.fromOffset(6, 8 + tabCount * 44); tabCount = tabCount + 1
	b.BackgroundColor3 = P.card; b.BackgroundTransparency = 1; b.Text = ""; b.BorderSizePixel = 0; b.ZIndex = 9; b.Parent = rail; corner(b, 10)
	local ic = tx(b, icon, F_M, 16, P.dim); ic.Size = UDim2.fromOffset(28, 38); ic.Position = UDim2.fromOffset(6, 0)
	ic.TextXAlignment = Enum.TextXAlignment.Center; ic.ZIndex = 10
	local l = tx(b, name, F_M, 13, P.dim); l.Size = UDim2.new(1, -44, 1, 0); l.Position = UDim2.fromOffset(38, 0); l.ZIndex = 10
	local page = Instance.new("ScrollingFrame"); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
	page.Size = UDim2.fromScale(1, 1); page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = P.accent
	page.ScrollBarImageTransparency = 0.4; page.CanvasSize = UDim2.new(); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false; page.ZIndex = 4; page.Parent = content
	local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0, 10); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = page
	local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0, 4); pad.PaddingRight = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 8); pad.PaddingLeft = UDim.new(0, 2); pad.Parent = page
	pages[name] = page; navBtns[name] = { btn = b, label = l, icon = ic }
	b.MouseEnter:Connect(function() if active ~= name then tw(l, 0.12, { TextColor3 = P.text }); tw(ic, 0.12, { TextColor3 = P.glow }); tw(b, 0.12, { BackgroundTransparency = 0.5 }) end end)
	b.MouseLeave:Connect(function() if active ~= name then tw(l, 0.12, { TextColor3 = P.dim }); tw(ic, 0.12, { TextColor3 = P.dim }); tw(b, 0.12, { BackgroundTransparency = 1 }) end end)
	b.MouseButton1Click:Connect(function() ripple(b, 20, 19, 100); selectTab(name) end)
	if not active then selectTab(name) end
	local rows = 0; local tab = {}
	local function rowBase(h)
		rows += 1
		local r = bx(page, P.card, 3); r.Size = UDim2.new(1, -4, 0, h); r.LayoutOrder = rows; r.BackgroundTransparency = 1
		corner(r, 12); stroke(r, P.line, 1, 0.4); sheen(r, 4)
		local sc = Instance.new("UIScale"); sc.Scale = 0.94; sc.Parent = r
		task.delay(rows * 0.03, function()
			if not r.Parent then return end
			tw(r, 0.28, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quint)
			tw(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
			task.delay(0.4, function() pcall(function() sc:Destroy() end) end)
		end)
		return r
	end
	function tab:Section(titleText, desc)
		rows += 1
		local s = fr(page, 3); s.Size = UDim2.new(1, -4, 0, desc and 42 or 26); s.LayoutOrder = rows
		local l2 = tx(s, titleText, F_B, 16, P.text); l2.Size = UDim2.new(1, -8, 0, 20); l2.Position = UDim2.fromOffset(2, 2); l2.ZIndex = 4; l2.TextTransparency = 1
		if desc then
			local d = tx(s, desc, F_R, 11, P.dim); d.Size = UDim2.new(1, -8, 0, 16); d.Position = UDim2.fromOffset(2, 22); d.ZIndex = 4; d.TextTransparency = 1
			task.delay(rows * 0.03, function() tw(l2, 0.28, { TextTransparency = 0 }); tw(d, 0.28, { TextTransparency = 0 }) end)
		else task.delay(rows * 0.03, function() tw(l2, 0.28, { TextTransparency = 0 }) end) end
	end
	function tab:Label(text)
		rows += 1
		local l2 = tx(page, text, F_R, 11, P.dim); l2.Size = UDim2.new(1, -8, 0, 0); l2.AutomaticSize = Enum.AutomaticSize.Y
		l2.TextWrapped = true; l2.TextYAlignment = Enum.TextYAlignment.Top; l2.LayoutOrder = rows; l2.ZIndex = 4; l2.TextTransparency = 1
		task.delay(rows * 0.03, function() tw(l2, 0.28, { TextTransparency = 0 }) end)
	end
	function tab:Toggle(label, desc, default, cb)
		local on = default and true or false; local h = desc and 56 or 44; local r = rowBase(h)
		local l2 = tx(r, label, F_S, 13, P.text); l2.Size = UDim2.new(1, -70, 0, 18); l2.Position = UDim2.fromOffset(16, desc and 10 or 13); l2.ZIndex = 5
		if desc then local d = tx(r, desc, F_R, 11, P.dim); d.Size = UDim2.new(1, -70, 0, 16); d.Position = UDim2.fromOffset(16, 30); d.ZIndex = 5 end
		local box = bx(r, on and P.accent or P.off, 5); box.AnchorPoint = Vector2.new(1, 0.5); box.Position = UDim2.new(1, -16, 0.5, 0)
		box.Size = UDim2.fromOffset(22, 22); corner(box, 6); stroke(box, on and P.accent or P.line, 1, on and 0.2 or 0.45)
		local check = tx(box, "✓", F_B, 14, P.hot); check.Size = UDim2.fromScale(1, 1); check.TextXAlignment = Enum.TextXAlignment.Center
		check.TextTransparency = on and 0 or 1; check.ZIndex = 6
		local function apply(v, fire, anim)
			on = v and true or false
			tw(box, anim and 0.18 or 0, { BackgroundColor3 = on and P.accent or P.off })
			tw(check, anim and 0.18 or 0, { TextTransparency = on and 0 or 1 })
			if fire and cb then pcall(cb, on) end
		end
		local hit = Instance.new("TextButton"); hit.Size = UDim2.fromScale(1, 1); hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 8; hit.Parent = r
		hit.MouseEnter:Connect(function() tw(r, 0.12, { BackgroundColor3 = P.cardHov }) end)
		hit.MouseLeave:Connect(function() tw(r, 0.12, { BackgroundColor3 = P.card }) end)
		hit.MouseButton1Click:Connect(function() apply(not on, true, true); if on then ripple(r, r.AbsoluteSize.X - 28, r.AbsoluteSize.Y / 2, 120) end end)
		return { Set = function(_, v) apply(v, true, true) end, Get = function() return on end }
	end
	function tab:Slider(label, desc, min, max, default, cb, suffix)
		local val = math.clamp(default or min, min, max)
		local h = desc and 72 or 58; local r = rowBase(h)
		local l2 = tx(r, label, F_S, 13, P.text); l2.Size = UDim2.new(1, -90, 0, 18); l2.Position = UDim2.fromOffset(16, desc and 8 or 10); l2.ZIndex = 5
		if desc then local d = tx(r, desc, F_R, 11, P.dim); d.Size = UDim2.new(1, -90, 0, 14); d.Position = UDim2.fromOffset(16, 26); d.ZIndex = 5 end
		local valLbl = tx(r, tostring(val) .. (suffix or ""), F_MO, 12, P.accent); valLbl.Size = UDim2.fromOffset(70, 18)
		valLbl.Position = UDim2.new(1, -86, 0, desc and 8 or 10); valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 5
		local track = bx(r, P.off, 5); track.Size = UDim2.new(1, -32, 0, 6); track.Position = UDim2.fromOffset(16, h - 22); corner(track, 3)
		local fill = bx(track, P.accent, 6); fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0); corner(fill, 3)
		local knob = bx(track, P.hot, 7); knob.Size = UDim2.fromOffset(14, 14); knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.new((val - min) / (max - min), 0, 0.5, 0); corner(knob, 7); stroke(knob, P.accent, 1.5, 0.2)
		local dragging = false
		local function setVal(v, fire)
			val = math.clamp(math.floor(v * 100 + 0.5) / 100, min, max)
			local pct = (val - min) / (max - min)
			fill.Size = UDim2.new(pct, 0, 1, 0); knob.Position = UDim2.new(pct, 0, 0.5, 0)
			valLbl.Text = tostring(val) .. (suffix or "")
			if fire and cb then pcall(cb, val) end
		end
		local hit = Instance.new("TextButton"); hit.Size = UDim2.new(1, 0, 0, 30); hit.Position = UDim2.fromOffset(0, h - 36)
		hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 8; hit.Parent = r
		local function fromX(x)
			local abs = track.AbsolutePosition.X; local w = track.AbsoluteSize.X
			if w <= 0 then return end
			setVal(min + ((x - abs) / w) * (max - min), true)
		end
		hit.MouseButton1Down:Connect(function() dragging = true end)
		hit.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then dragging = true; fromX(inp.Position.X) end end)
		UserInputService.InputChanged:Connect(function(inp)
			if not dragging then return end
			if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then fromX(inp.Position.X) end
		end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
		end)
		hit.MouseEnter:Connect(function() tw(r, 0.12, { BackgroundColor3 = P.cardHov }) end)
		hit.MouseLeave:Connect(function() tw(r, 0.12, { BackgroundColor3 = P.card }) end)
		return { Set = function(_, v) setVal(v, true) end, Get = function() return val end }
	end
	function tab:Button(label, primary, cb)
		local r = rowBase(44)
		local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -24, 0, 32); b.Position = UDim2.fromOffset(12, 6)
		b.BackgroundColor3 = primary and P.accent or P.card; b.Text = label; b.FontFace = F_S; b.TextSize = 13
		b.TextColor3 = primary and P.hot or P.text; b.BorderSizePixel = 0; b.ZIndex = 6; b.Parent = r; corner(b, 8)
		stroke(b, primary and P.accentD or P.line, 1, primary and 0.25 or 0.45)
		b.MouseEnter:Connect(function() tw(b, 0.12, { BackgroundColor3 = primary and P.accent2 or P.cardHov }) end)
		b.MouseLeave:Connect(function() tw(b, 0.12, { BackgroundColor3 = primary and P.accent or P.card }) end)
		b.MouseButton1Click:Connect(function() ripple(r, r.AbsoluteSize.X / 2, 22, 140); if cb then pcall(cb) end end)
	end
	return tab
end
local function notify(msg, kind, dur)
	kind = kind or "good"; dur = dur or 2.5
	local col = kind == "good" and P.good or (kind == "warn" and P.warn or P.bad)
	local n = bx(gui, P.card, 60); n.Size = UDim2.fromOffset(280, 44); n.Position = UDim2.new(1, -300, 0, 20)
	n.AnchorPoint = Vector2.new(0, 0); corner(n, 10); stroke(n, col, 1.5, 0.3); sheen(n, 61)
	local t = tx(n, msg, F_M, 13, P.text); t.Size = UDim2.new(1, -20, 1, 0); t.Position = UDim2.fromOffset(12, 0); t.ZIndex = 62
	tw(n, 0.35, { Position = UDim2.new(1, -300, 0, 20) }, Enum.EasingStyle.Back)
	task.delay(dur, function()
		tw(n, 0.3, { Position = UDim2.new(1, 20, 0, 20) })
		task.delay(0.35, function() pcall(function() n:Destroy() end) end)
	end)
end
hide = function()
	tw(main, 0.25, { BackgroundTransparency = 1 })
	task.delay(0.25, function() main.Visible = false end)
end
show = function()
	main.Visible = true
	main.BackgroundTransparency = 1
	tw(main, 0.3, { BackgroundTransparency = 0.12 }, Enum.EasingStyle.Quint)
end
local ORB = isTouch() and 56 or 48
local orb = Instance.new("TextButton")
orb.Name = "Orb"
orb.Size = UDim2.fromOffset(ORB, ORB)
orb.Position = UDim2.new(0, 16, 0.55, 0)
orb.BackgroundColor3 = P.bg
orb.AutoButtonColor = false
orb.Text = ""
orb.BorderSizePixel = 0
orb.Visible = false
orb.ZIndex = 30
orb.Parent = gui
corner(orb, ORB / 2)
stroke(orb, P.accent, 1.4, 0.2)
glow(orb, P.accent, 2, 3, ORB / 2, 0.42)
local om = drawMark(orb, ORB * 0.58, 31)
om.AnchorPoint = Vector2.new(0.5, 0.5)
om.Position = UDim2.fromScale(0.5, 0.5)
local mobileBar = bx(gui, P.top, 28)
mobileBar.AnchorPoint = Vector2.new(0.5, 0)
mobileBar.Position = UDim2.new(0.5, 0, 0, 12)
mobileBar.Size = UDim2.fromOffset(230, 42)
mobileBar.ZIndex = 28
mobileBar.Visible = isTouch()
corner(mobileBar, 21)
stroke(mobileBar, P.accent, 1.3, 0.25)
glow(mobileBar, P.accent, 2, 2, 21, 0.48)
sheen(mobileBar, 29)
local function mBtn(label, x, col, fn)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(66, 30)
	b.Position = UDim2.fromOffset(x, 6)
	b.BackgroundColor3 = P.card
	b.AutoButtonColor = false
	b.Text = label
	b.FontFace = F_S
	b.TextSize = 11
	b.TextColor3 = col
	b.BorderSizePixel = 0
	b.ZIndex = 29
	b.Parent = mobileBar
	corner(b, 12)
	local st = stroke(b, col, 1, 0.5)
	b.MouseEnter:Connect(function()
		tw(b, 0.1, { BackgroundColor3 = P.cardHov })
		tw(st, 0.1, { Transparency = 0.15 })
	end)
	b.MouseLeave:Connect(function()
		tw(b, 0.1, { BackgroundColor3 = P.card })
		tw(st, 0.1, { Transparency = 0.5 })
	end)
	b.MouseButton1Click:Connect(function()
		ripple(b, 33, 15, 100)
		fn()
	end)
	return b
end
show = function()
	if minimized then doMinimize(false) end
	orb.Visible = false
	main.Visible = true
	main.BackgroundTransparency = 1
	local scaleObj = main:FindFirstChildOfClass("UIScale")
	local t = windowScale()
	if scaleObj then
		scaleObj.Scale = t * 0.9
		tw(scaleObj, 0.35, { Scale = t }, Enum.EasingStyle.Back)
	end
	tw(main, 0.3, { BackgroundTransparency = 0.12 }, Enum.EasingStyle.Quint)
end
hide = function()
	main.Visible = false
	minimized = false
	main.Size = UDim2.fromOffset(W, H)
	orb.Visible = true
	orb.Size = UDim2.fromOffset(0, 0)
	tw(orb, 0.3, { Size = UDim2.fromOffset(ORB, ORB) }, Enum.EasingStyle.Back)
end
mBtn("Open", 12, P.good, function() show() end)
mBtn("Half", 82, P.glow, function()
	if not main.Visible then show() end
	task.defer(function() doMinimize(true) end)
end)
mBtn("Close", 152, P.bad, function() hide() end)
do
	local downAt, moved
	orb.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			downAt, moved = i.Position, false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not downAt then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			if (i.Position - downAt).Magnitude > 6 then moved = true end
			if moved then
				local parentAbs = gui.AbsolutePosition
				orb.Position = UDim2.fromOffset(i.Position.X - parentAbs.X - ORB / 2, i.Position.Y - parentAbs.Y - ORB / 2)
				orb.AnchorPoint = Vector2.new(0, 0)
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			downAt = nil
		end
	end)
	orb.MouseButton1Click:Connect(function()
		if not moved then show() end
	end)
end
local function toggle() if main.Visible then hide() else show() end end
local draggingUI = false
local dragStart, startPos
local DZ = Instance.new("TextButton")
DZ.Size = UDim2.new(1, -50, 1, 0); DZ.Position = UDim2.fromOffset(0, 0)
DZ.BackgroundTransparency = 1; DZ.Text = ""; DZ.ZIndex = 11; DZ.Parent = top; DZ.Active = true
DZ.MouseButton1Down:Connect(function()
	draggingUI = true
	dragStart = UserInputService:GetMouseLocation()
	startPos = main.AbsolutePosition
end)
UserInputService.InputChanged:Connect(function(inp)
	if not draggingUI then return end
	if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
		local delta = UserInputService:GetMouseLocation() - dragStart
		main.Position = UDim2.fromOffset(startPos.X + delta.X, startPos.Y + delta.Y)
		main.AnchorPoint = Vector2.new(0, 0)
	end
end)
UserInputService.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		draggingUI = false
	end
end)
UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.RightControl then toggle() end
end)
local uiScale = Instance.new("UIScale"); uiScale.Scale = windowScale(); uiScale.Parent = main
local function boot(steps, onDone)
	main.Visible = true
	main.BackgroundTransparency = 1
	local bootFrame = bx(gui, P.bg, 80); bootFrame.Size = UDim2.fromOffset(320, 140); bootFrame.Position = UDim2.fromScale(0.5, 0.5)
	bootFrame.AnchorPoint = Vector2.new(0.5, 0.5); corner(bootFrame, 14); stroke(bootFrame, P.accent, 1.5, 0.4)
	local mark = drawMark(bootFrame, 36, 82); mark.Position = UDim2.fromOffset(20, 20)
	local bt = tx(bootFrame, "Tempo Hub", F_D, 20, P.hot); bt.Size = UDim2.new(1, -70, 0, 28); bt.Position = UDim2.fromOffset(66, 22); bt.ZIndex = 83
	local st = tx(bootFrame, steps[1] or "loading...", F_R, 13, P.dim); st.Size = UDim2.new(1, -40, 0, 20); st.Position = UDim2.fromOffset(20, 70); st.ZIndex = 83
	local barBg = bx(bootFrame, P.off, 83); barBg.Size = UDim2.new(1, -40, 0, 6); barBg.Position = UDim2.fromOffset(20, 105); corner(barBg, 3)
	local bar = bx(barBg, P.accent, 84); bar.Size = UDim2.new(0, 0, 1, 0); corner(bar, 3)
	task.spawn(function()
		for i, step in ipairs(steps) do
			st.Text = step
			tw(bar, 0.35, { Size = UDim2.new(i / #steps, 0, 1, 0) })
			task.wait(0.28)
		end
		tw(bootFrame, 0.3, { BackgroundTransparency = 1 })
		task.wait(0.3)
		pcall(function() bootFrame:Destroy() end)
		show()
		if onDone then onDone() end
	end)
end
local Config = {
	Enabled = true,
	ReachSize = Vector3.new(14, 14, 14),
	ForwardOffset = 0,
	BehindOffset = 0,
	FrictionPatch = true,
	DefaultFriction = 0.01375,
	ReducedFriction = 0.01,
	Visualizer = true,
	VisualizerColor = Color3.fromRGB(0, 255, 180),
	VisualizerTransparency = 0.7
}
getgenv().settings = {
	maxDist = 2500, stopDist = 1.5, turnSmooth = 0.04, predPower = 0.5,
	flickThreshold = 20, flickMult = 1.0, maxPredTime = 2.5, accelSmooth = 0.3,
	slowdownRange = 4, moveInterval = 0.08, moveEpsilon = 0, useCurves = true, lookAtBall = false,
}
getgenv().guarding = getgenv().guarding or false
local TrajectoryConfig = {
	Enabled = true, AlwaysShow = true, PredictTime = 1.2, SimDT = 1/60, MaxBounces = 4,
	Restitution = 0.55, GroundFriction = 0.78, AirDrag = 0.003, NumMarkers = 22,
	MarkerSize = 0.45, MarkerColor = Color3.fromRGB(255, 220, 0), LandingSize = 3.0,
	LandingColor = Color3.fromRGB(255, 60, 60), TriggerSpeed = 25, TriggerJump = 18, ShowDuration = 2.5
}
local BALL_IDENTIFIERS = {
	["TPS"] = true, ["TCS"] = true, ["TPBall"] = true, ["TPSBall"] = true,
	["WFPN"] = true, ["VEF"] = true, ["ROFI"] = true, ["PRS"] = true,
	["MPS"] = true, ["LPFI"] = true, ["Ball"] = true, ["CBM"] = true,
	["Football"] = true, ["VRF"] = true
}
local visualizerBox, proxyAnchor = nil, nil
local ballConnections, lastTouchTime = {}, {}
local targetBall, smoothAcc, lastVel, lastTime = nil, Vector3.zero, Vector3.zero, os.clock()
local windowFocused, trackedBalls, trackedSet = true, {}, {}
local lastMoveAt, lastMoveTarget, baseGravity = 0, nil, Workspace.Gravity or 196.2
local trajAnchors, trajAdornments, landingAnchor, landingAdornment, showUntil = {}, {}, nil, nil, 0
if getgenv()._cleanup then pcall(getgenv()._cleanup) end
local connections = {}
local function trackConn(c) table.insert(connections, c); return c end
local function initializeHooks()
	if hookMeta then
		pcall(function()
			local oldNamecall
			oldNamecall = hookMeta(game, "__namecall", newCClosure(function(self, ...)
				local method = getnamecallmethod()
				local args = {...}
				if method == "FireServer" or method == "InvokeServer" then
					local remoteName = tostring(self.Name)
					local firstArg = args[1]
					if remoteName == "Speedometer" or remoteName == "MTF" or remoteName == "EnlargedHitbox"
						or remoteName == "AntiCheatReport" or remoteName == "CheckPlayerSettings"
						or firstArg == "MTF" or firstArg == "EnlargedHitbox"
						or firstArg == "Disable Script" or firstArg == "Script Tamper" or firstArg == "Delete Script" then
						return nil
					end
				end
				return oldNamecall(self, ...)
			end))
		end)
	end
	task.spawn(function()
		local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 15)
		if not playerScripts then return end
		local tsflClient = playerScripts:WaitForChild("TSFL Client", 10) or playerScripts:FindFirstChild("TSFLClient", true)
		if not tsflClient then return end
		local modules = tsflClient:WaitForChild("Modules", 10)
		local ballNetworkingScript = modules and modules:WaitForChild("BallNetworking", 10)
		if ballNetworkingScript then
			local ok, BallNetworking = pcall(require, ballNetworkingScript)
			if ok and type(BallNetworking) == "table" then
				if type(BallNetworking.VerifyHit) == "function" and hookFunc then
					hookFunc(BallNetworking.VerifyHit, newCClosure(function(...) return true end))
				end
				if type(BallNetworking.IsBallBoundingHitbox) == "function" and hookFunc then
					local oldBounding = BallNetworking.IsBallBoundingHitbox
					hookFunc(BallNetworking.IsBallBoundingHitbox, newCClosure(function(self, ball, leg, ...)
						if not Config.Enabled then return oldBounding(self, ball, leg, ...) end
						if ball and ball:IsA("BasePart") then
							local char = LocalPlayer.Character
							local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
							if root then
								local zOffset = -Config.ForwardOffset + Config.BehindOffset
								local proxyCF = root.CFrame * CFrame.new(0, 0, zOffset)
								local rel = proxyCF:PointToObjectSpace(ball.Position)
								local hX, hY, hZ = Config.ReachSize.X * 0.5, Config.ReachSize.Y * 0.5, Config.ReachSize.Z * 0.5
								if math.abs(rel.X) <= hX and math.abs(rel.Y) <= hY and math.abs(rel.Z) <= hZ then
									return true
								end
							end
						end
						return oldBounding(self, ball, leg, ...)
					end))
				end
			end
		end
	end)
end
if getConns then
	pcall(function()
		for _, conn in ipairs(getConns(ReplicatedStorage.DescendantRemoving)) do conn:Disconnect() end
	end)
end
if typeof(hookFunc) == "function" then
	local frozenGC = gcinfo()
	if typeof(gcinfo) == "function" then hookFunc(gcinfo, newCClosure(function(...) return frozenGC end)) end
	if typeof(collectgarbage) == "function" then
		local real = collectgarbage
		hookFunc(collectgarbage, newCClosure(function(mode, ...) if mode == "count" then return frozenGC end return real(mode, ...) end))
	end
end
local function SweepCharacterConnections(char)
	if not (char and getConns) then return end
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		for _, prop in ipairs({"JumpHeight", "WalkSpeed", "WalkToPoint", "HipHeight"}) do
			for _, conn in ipairs(getConns(humanoid:GetPropertyChangedSignal(prop))) do conn:Disconnect() end
		end
	end
	for _, name in ipairs({"H", "T", "RA", "LA", "RL", "LL", "Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}) do
		local part = char:FindFirstChild(name)
		if part then for _, conn in ipairs(getConns(part:GetPropertyChangedSignal("Size"))) do conn:Disconnect() end end
	end
	for _, name in ipairs({"Mainframe", "AC_Client", "Handler"}) do
		local s = char:FindFirstChild(name)
		if s then
			for _, conn in ipairs(getConns(s:GetPropertyChangedSignal("Enabled"))) do conn:Disconnect() end
			for _, conn in ipairs(getConns(s.AncestryChanged)) do conn:Disconnect() end
			for _, conn in ipairs(getConns(s.Destroying)) do conn:Disconnect() end
			if s:IsA("Script") or s:IsA("LocalScript") then s.Disabled = true end
		end
	end
end
local function setupCharacterPhysics(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local head = char:WaitForChild("Head", 5)
	local torso = char:WaitForChild("Torso", 5)
	if hrp then hrp.CollisionGroup = 2 end
	if head then head.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 1, 1, 1) end
	if torso then torso.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0, 1, 100) end
	for _, def in ipairs({{"H", Vector3.new(2,1,1)}, {"T", Vector3.new(2,2,1)}, {"RA", Vector3.new(1,2,1)}, {"LA", Vector3.new(1,2,1)}, {"RL", Vector3.new(1,2,1)}, {"LL", Vector3.new(1,2,1)}}) do
		if not char:FindFirstChild(def[1]) then
			local p = Instance.new("Part"); p.Size = def[2]; p.Name = def[1]; p.CanCollide = false; p.Anchored = true; p.Transparency = 1; p.Parent = char
		end
	end
end
local function applyBallFriction(ball)
	if ballConnections[ball] or not Config.FrictionPatch then return end
	local drag = ball:WaitForChild("Drag", 5)
	local fric, activeState, accum = Config.DefaultFriction, false, 0
	ballConnections[ball] = RunService.Heartbeat:Connect(function(dt)
		accum = accum + dt; if accum < 0.05 then return end; accum = 0
		if ball and ball.Parent then
			local vel = ball.AssemblyLinearVelocity
			if (vel * Vector3.new(1, 0, 1)).Magnitude > 0.01 then
				ball.AssemblyLinearVelocity = vel * Vector3.new(1 - fric, 1, 1 - fric)
			elseif drag then drag.Force = Vector3.zero end
		else
			if ballConnections[ball] then ballConnections[ball]:Disconnect(); ballConnections[ball] = nil end
		end
	end)
	ball.ChildAdded:Connect(function(child)
		if child:IsA("BodyVelocity") then
			task.wait()
			local vel = child.Velocity
			if Vector3.new(vel.X, 0, vel.Z).Magnitude > 32.5 and vel.Y > 0.1 then activeState = true; fric = Config.ReducedFriction end
		end
	end)
	ball.Touched:Connect(function(other)
		if other.Name == "Grass" and activeState then activeState = false; fric = Config.DefaultFriction end
	end)
end
local function initializeBallMonitoring()
	local ballsFolder = Workspace:WaitForChild("Balls", 5)
	if not ballsFolder then return end
	for _, child in ipairs(ballsFolder:GetChildren()) do
		if child.Name == "VRF" and child:IsA("BasePart") then task.spawn(applyBallFriction, child) end
	end
	ballsFolder.ChildAdded:Connect(function(child)
		if child.Name == "VRF" and child:IsA("BasePart") then task.spawn(applyBallFriction, child) end
	end)
	ballsFolder.ChildRemoved:Connect(function(child)
		if ballConnections[child] then ballConnections[child]:Disconnect(); ballConnections[child] = nil end
	end)
end
local function setupVisualizer()
	if proxyAnchor and proxyAnchor.Parent then proxyAnchor:Destroy() end
	proxyAnchor = Instance.new("Part")
	proxyAnchor.Name = "VRF_ReachAnchor"; proxyAnchor.Size = Vector3.new(1,1,1); proxyAnchor.Transparency = 1
	proxyAnchor.CanCollide = false; proxyAnchor.CanTouch = false; proxyAnchor.CanQuery = false
	proxyAnchor.Massless = true; proxyAnchor.Anchored = true; proxyAnchor.Parent = Workspace
	if visualizerBox and visualizerBox.Parent then visualizerBox:Destroy() end
	local adorn = Instance.new("BoxHandleAdornment")
	adorn.Name = "VRF_ReachBox"; adorn.Color3 = Config.VisualizerColor; adorn.Transparency = Config.VisualizerTransparency
	adorn.AlwaysOnTop = true; adorn.ZIndex = 10; adorn.Adornee = proxyAnchor; adorn.Size = Config.ReachSize
	adorn.Parent = getHui(); visualizerBox = adorn
end
local function isPointInOBB(cframe, size, point)
	local rel = cframe:PointToObjectSpace(point)
	local hX, hY, hZ = size.X * 0.5, size.Y * 0.5, size.Z * 0.5
	return math.abs(rel.X) <= hX and math.abs(rel.Y) <= hY and math.abs(rel.Z) <= hZ
end
local function getActiveBalls()
	local targets, seen = {}, {}
	for _, ball in ipairs(CollectionService:GetTagged("BallNetworking")) do
		if ball:IsA("BasePart") and not seen[ball] then seen[ball] = true; table.insert(targets, ball) end
	end
	local ballsFolder = Workspace:FindFirstChild("Balls")
	if ballsFolder then
		for _, child in ipairs(ballsFolder:GetChildren()) do
			if child:IsA("BasePart") and not seen[child] then seen[child] = true; table.insert(targets, child)
			elseif child:IsA("Model") then
				for _, part in ipairs(child:GetChildren()) do
					if part:IsA("BasePart") and not seen[part] then seen[part] = true; table.insert(targets, part) end
				end
			end
		end
	end
	return targets
end
local function processReachFrame(char)
	if not Config.Enabled then if visualizerBox then visualizerBox.Visible = false end return end
	local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
	if not root then return end
	local zOffset = -Config.ForwardOffset + Config.BehindOffset
	local targetCF = root.CFrame * CFrame.new(0, 0, zOffset)
	if proxyAnchor and proxyAnchor.Parent then proxyAnchor.CFrame = targetCF else setupVisualizer(); return end
	if visualizerBox then
		visualizerBox.Visible = Config.Enabled and Config.Visualizer
		visualizerBox.Size = Config.ReachSize; visualizerBox.Color3 = Config.VisualizerColor
	end
	local balls = getActiveBalls()
	if #balls == 0 then return end
	local limbs = {}
	for _, name in ipairs({"Right Leg", "Left Leg", "Right Foot", "Left Foot", "RL", "LL", "Torso", "HumanoidRootPart", "RA", "LA", "H", "T"}) do
		local limb = char:FindFirstChild(name)
		if limb and limb:IsA("BasePart") then table.insert(limbs, limb) end
	end
	if #limbs == 0 then return end
	local now = tick()
	for _, ball in ipairs(balls) do
		if isPointInOBB(targetCF, Config.ReachSize, ball.Position) then
			if not lastTouchTime[ball] or (now - lastTouchTime[ball]) > 0.03 then
				lastTouchTime[ball] = now
				for _, limb in ipairs(limbs) do
					if fireTouch then
						fireTouch(limb, ball, 0); fireTouch(ball, limb, 0)
						task.defer(function()
							if limb.Parent and ball.Parent then fireTouch(limb, ball, 1); fireTouch(ball, limb, 1) end
						end)
					end
				end
			end
		end
	end
end
local function hideTrajectory()
	for i = 1, #trajAdornments do if trajAdornments[i] then trajAdornments[i].Transparency = 1 end end
	if landingAdornment then landingAdornment.Transparency = 1 end
	showUntil = 0
end
local function initStealthTrajectoryVisuals()
	if #trajAnchors == 0 then
		for i = 1, TrajectoryConfig.NumMarkers do
			local part = Instance.new("Part"); part.Name = "TrajAnchor_" .. i; part.Size = Vector3.new(1,1,1)
			part.Transparency = 1; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
			part.Massless = true; part.Anchored = true; part.Parent = Workspace
			trajAnchors[i] = part
			local adorn = Instance.new("SphereHandleAdornment")
			adorn.Name = "TrajMarker_" .. i; adorn.Color3 = TrajectoryConfig.MarkerColor; adorn.Transparency = 1
			adorn.AlwaysOnTop = true; adorn.ZIndex = 10; adorn.Adornee = part
			adorn.Radius = TrajectoryConfig.MarkerSize * 0.5; adorn.Parent = getHui()
			trajAdornments[i] = adorn
		end
		landingAnchor = Instance.new("Part"); landingAnchor.Name = "LandingAnchor"; landingAnchor.Size = Vector3.new(1,1,1)
		landingAnchor.Transparency = 1; landingAnchor.CanCollide = false; landingAnchor.CanTouch = false
		landingAnchor.CanQuery = false; landingAnchor.Massless = true; landingAnchor.Anchored = true
		landingAnchor.Parent = Workspace
		landingAdornment = Instance.new("SphereHandleAdornment")
		landingAdornment.Name = "LandingMarker"; landingAdornment.Color3 = TrajectoryConfig.LandingColor
		landingAdornment.Transparency = 1; landingAdornment.AlwaysOnTop = true; landingAdornment.ZIndex = 10
		landingAdornment.Adornee = landingAnchor; landingAdornment.Radius = TrajectoryConfig.LandingSize * 0.5
		landingAdornment.Parent = getHui()
	end
end
local function simulateTrajectory(ballPart)
	local pos, vel = ballPart.Position, ballPart.AssemblyLinearVelocity
	local points, landingPos, bounces = { pos }, nil, 0
	local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { LocalPlayer.Character, ballPart }
	local g, t = Workspace.Gravity or baseGravity, 0
	while t < TrajectoryConfig.PredictTime do
		local stepVel = vel + Vector3.new(0, -g, 0) * TrajectoryConfig.SimDT
		stepVel = stepVel * (1 - TrajectoryConfig.AirDrag)
		local stepPos = pos + stepVel * TrajectoryConfig.SimDT
		local rayDir = stepPos - pos
		local hit = rayDir.Magnitude > 0 and Workspace:Raycast(pos, rayDir, params) or nil
		if hit then
			local hitPos, normal = hit.Position, hit.Normal.Unit
			local vn = stepVel:Dot(normal)
			if normal.Y > 0.7 and not landingPos then landingPos = hitPos end
			if vn < 0 then
				local vNormal = normal * vn
				stepVel = (stepVel - vNormal) * TrajectoryConfig.GroundFriction - vNormal * TrajectoryConfig.Restitution
			end
			stepPos = hitPos + normal * 0.05; bounces = bounces + 1
			table.insert(points, stepPos)
			if stepVel.Magnitude < 2.5 or bounces > TrajectoryConfig.MaxBounces then break end
		else table.insert(points, stepPos) end
		pos, vel, t = stepPos, stepVel, t + TrajectoryConfig.SimDT
	end
	if not landingPos then landingPos = points[#points] end
	return points, landingPos
end
local function drawTrajectoryTrail(ballPart)
	initStealthTrajectoryVisuals()
	local pts, landingPos = simulateTrajectory(ballPart)
	local step = math.max(1, math.floor(#pts / TrajectoryConfig.NumMarkers))
	for i = 1, TrajectoryConfig.NumMarkers do
		local idx = math.min(#pts, (i - 1) * step + 1)
		local anchor, adorn = trajAnchors[i], trajAdornments[i]
		if anchor and adorn and pts[idx] then
			local frac = i / TrajectoryConfig.NumMarkers
			anchor.CFrame = CFrame.new(pts[idx])
			adorn.Transparency = 0.05 + 0.55 * frac
			adorn.Color3 = TrajectoryConfig.MarkerColor
			adorn.Radius = (TrajectoryConfig.MarkerSize * 0.5) * (1 - 0.4 * frac)
		elseif adorn then adorn.Transparency = 1 end
	end
	if landingAnchor and landingAdornment and landingPos then
		landingAnchor.CFrame = CFrame.new(landingPos + Vector3.new(0, 0.05, 0))
		landingAdornment.Radius = TrajectoryConfig.LandingSize * 0.5
		landingAdornment.Color3 = TrajectoryConfig.LandingColor
		landingAdornment.Transparency = 0.15
	end
	showUntil = tick() + TrajectoryConfig.ShowDuration
end
local function checkTrajectoryTrigger(ball)
	if TrajectoryConfig.AlwaysShow then return true end
	local speed = ball.AssemblyLinearVelocity.Magnitude
	local jump = math.abs(ball.AssemblyLinearVelocity.Y)
	return speed > TrajectoryConfig.TriggerSpeed or jump > TrajectoryConfig.TriggerJump or tick() < showUntil
end
local function getTCSCharacter(player)
	player = player or LocalPlayer
	local char = player.Character
	if char and char.Parent then return char end
	local wsChars = Workspace:FindFirstChild("WorkspaceCharacters")
	if wsChars then local found = wsChars:FindFirstChild(player.Name); if found then return found end end
	return nil
end
local function getRoot(p) local c = getTCSCharacter(p); return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c.PrimaryPart) end
local function getHumanoid(p) local c = getTCSCharacter(p); return c and c:FindFirstChildWhichIsA("Humanoid") end
local function isPlayerMoving()
	local h = getHumanoid(LocalPlayer)
	if h and h.MoveDirection.Magnitude > 0.1 then return true end
	return UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A)
		or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
end
local function isBallPart(obj)
	if not (obj and obj:IsA("BasePart")) then return false end
	if BALL_IDENTIFIERS[obj.Name] then return true end
	return CollectionService:HasTag(obj, "TPS") or CollectionService:HasTag(obj, "TCS") or CollectionService:HasTag(obj, "Ball")
end
local function trackBall(obj)
	if not obj or not isBallPart(obj) or trackedSet[obj] then return end
	trackedSet[obj] = true; table.insert(trackedBalls, obj)
end
local function untrackBall(obj)
	if not obj or not trackedSet[obj] then return end
	trackedSet[obj] = nil
	for i = #trackedBalls, 1, -1 do if trackedBalls[i] == obj then table.remove(trackedBalls, i); break end end
end
local function rebuildBallCache()
	trackedBalls, trackedSet = {}, {}
	for _, v in ipairs(Workspace:GetDescendants()) do if isBallPart(v) then trackedSet[v] = true; table.insert(trackedBalls, v) end end
end
local function findClosestBall(pos)
	local closest, minDist = nil, math.huge
	for i = #trackedBalls, 1, -1 do
		local v = trackedBalls[i]
		if not (v and v.Parent) then trackedSet[v] = nil; table.remove(trackedBalls, i)
		else
			local d = (pos - v.Position).Magnitude
			if d < minDist then minDist = d; closest = v end
		end
	end
	return closest
end
local function issueMove(humanoid, pos)
	if not humanoid or not pos then return end
	local s = getgenv().settings
	local now = os.clock()
	if s.moveInterval > 0 and (now - lastMoveAt) < s.moveInterval and lastMoveTarget then
		if (pos - lastMoveTarget).Magnitude <= s.moveEpsilon then return end
	end
	lastMoveAt = now; lastMoveTarget = pos; humanoid:MoveTo(pos)
end
local function calculateLandingSpot(pos, vel, floorY)
	local g = Workspace.Gravity or baseGravity
	local h = pos.Y - floorY
	if h < 0.5 then return Vector3.new(pos.X, floorY, pos.Z), 0 end
	local vy = vel.Y
	local disc = vy * vy + 2 * g * h
	if disc < 0 then return Vector3.new(pos.X, floorY, pos.Z), 0 end
	local t = math.clamp((vy + math.sqrt(disc)) / g, 0, getgenv().settings.maxPredTime)
	local lx, lz
	if getgenv().settings.useCurves then
		lx = pos.X + vel.X * t + 0.5 * smoothAcc.X * t * t
		lz = pos.Z + vel.Z * t + 0.5 * smoothAcc.Z * t * t
	else lx = pos.X + vel.X * t; lz = pos.Z + vel.Z * t end
	return Vector3.new(lx, floorY, lz), t
end
local function calculateGroundPrediction(bpos, bvel, mpos)
	local s = getgenv().settings
	local acc2dMag = math.sqrt(smoothAcc.X * smoothAcc.X + smoothAcc.Z * smoothAcc.Z)
	local isFlick = acc2dMag > s.flickThreshold
	local pt = math.min(isFlick and (s.predPower * s.flickMult) or s.predPower, s.maxPredTime)
	local pv = (isFlick and s.useCurves) and (bvel + smoothAcc * 0.15) or bvel
	local future = s.useCurves and (bpos + pv * pt + 0.5 * smoothAcc * pt * pt) or (bpos + pv * pt)
	return Vector3.new(future.X, mpos.Y, future.Z)
end
local function updateAcceleration(vel)
	local now = os.clock(); local dt = now - lastTime
	if dt < 0.005 then return end
	local rawAcc = (vel - lastVel) / dt
	if rawAcc.Magnitude > 500 then rawAcc = rawAcc.Unit * 500 end
	smoothAcc = smoothAcc:Lerp(rawAcc, math.clamp(getgenv().settings.accelSmooth, 0.05, 0.95))
	lastVel = vel; lastTime = now
end
local scanTask = task.spawn(function()
	while true do
		if getgenv().guarding then
			local r = getRoot(LocalPlayer)
			targetBall = r and findClosestBall(r.Position) or nil
		else targetBall = nil end
		task.wait(0.35)
	end
end)
local function ProcessCharacterBypass(char)
	setupCharacterPhysics(char)
	char:WaitForChild("Humanoid", 10)
	for i = 1, 15 do SweepCharacterConnections(char); task.wait(0.2) end
end
local TeekUI = assert(loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))(), "TempoUI failed")
local TempoWin = TeekUI.new({ Title = "TEMPO", Subtitle = "TSFL / ENI", Version = "v1" })
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
boot = function(steps, onDone) pcall(function() TempoWin:mountInterface(TempoWin:Tab("Interface", "sliders")) end) TempoWin:Boot(steps, onDone) end
local reachTab = makeTab("Reach", "◎")
reachTab:Section("Reach Settings", "Hitbox extension for ball contact")
reachTab:Toggle("Reach", "Enable reach system", true, function(v)
	Config.Enabled = v
	if visualizerBox then visualizerBox.Visible = v and Config.Visualizer end
end)
reachTab:Toggle("Visualizer", "Show reach box", true, function(v)
	Config.Visualizer = v
	if visualizerBox then visualizerBox.Visible = Config.Enabled and v end
end)
reachTab:Slider("Reach Size X", "Width of reach box", 1, 30, 14, function(v)
	Config.ReachSize = Vector3.new(v, Config.ReachSize.Y, Config.ReachSize.Z)
end, " studs")
reachTab:Slider("Reach Size Y", "Height of reach box", 1, 30, 14, function(v)
	Config.ReachSize = Vector3.new(Config.ReachSize.X, v, Config.ReachSize.Z)
end, " studs")
reachTab:Slider("Reach Size Z", "Depth of reach box", 1, 30, 14, function(v)
	Config.ReachSize = Vector3.new(Config.ReachSize.X, Config.ReachSize.Y, v)
end, " studs")
reachTab:Slider("Forward Offset", "Shift box forward", 0, 15, 0, function(v) Config.ForwardOffset = v end, " studs")
reachTab:Slider("Behind Offset", "Shift box backward", 0, 15, 0, function(v) Config.BehindOffset = v end, " studs")
reachTab:Section("Physics", nil)
reachTab:Toggle("Friction Patch", "Reduce ball friction while moving", true, function(v) Config.FrictionPatch = v end)
local guardTab = makeTab("Autoguard", "⚡")
guardTab:Section("Autoguard Settings", "Automatic ball interception")
guardTab:Toggle("Autoguard", "Enable automatic guarding", false, function(v)
	getgenv().guarding = v
	if not v then targetBall = nil; smoothAcc = Vector3.zero end
end)
guardTab:Section("Tuning", nil)
guardTab:Slider("Max Distance", "Maximum distance to chase ball", 100, 5000, 2500, function(v) getgenv().settings.maxDist = v end, " studs")
guardTab:Slider("Stop Distance", "Distance to stop near ball", 0.5, 10, 1.5, function(v) getgenv().settings.stopDist = v end, " studs")
guardTab:Slider("Prediction Power", "How far ahead to predict", 0.1, 2.0, 0.5, function(v) getgenv().settings.predPower = v end, "x")
guardTab:Slider("Turn Smoothness", "How quickly to face the ball", 0.01, 0.2, 0.04, function(v) getgenv().settings.turnSmooth = v end, "")
guardTab:Toggle("Look At Ball", "Rotate character toward ball", true, function(v) getgenv().settings.lookAtBall = v end)
guardTab:Toggle("Use Curves", "Use acceleration curves for prediction", true, function(v) getgenv().settings.useCurves = v end)
local trajTab = makeTab("Trajectory", "↗")
trajTab:Section("Ball Trajectory", "Stealth prediction trail")
trajTab:Toggle("Enable Trajectory", "Show predicted ball path", true, function(v)
	TrajectoryConfig.Enabled = v
	if not v then hideTrajectory() end
end)
trajTab:Toggle("Always Show", "Ignore speed trigger and always draw", true, function(v) TrajectoryConfig.AlwaysShow = v end)
trajTab:Slider("Prediction Time", "How far into the future to simulate", 0.5, 3.0, 1.2, function(v) TrajectoryConfig.PredictTime = v end, " sec")
trajTab:Slider("Marker Count", "Number of dots on the trail", 10, 40, 22, function(v) TrajectoryConfig.NumMarkers = v end, " dots")
local utilTab = makeTab("Utilities", "⚙")
utilTab:Section("Tools", nil)
utilTab:Button("Sweep Character Connections", true, function()
	if LocalPlayer.Character then SweepCharacterConnections(LocalPlayer.Character); notify("Connections swept", "good") end
end)
utilTab:Button("Rebuild Ball Cache", false, function() rebuildBallCache(); notify("Ball cache rebuilt", "good") end)
utilTab:Button("Anti-AFK Click", false, function()
	VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()); notify("Anti-AFK clicked", "good")
end)
utilTab:Section("Hub Control", nil)
utilTab:Button("Unload Hub", false, function()
	if destroyed then return end; destroyed = true; hide(); task.wait(0.2)
	if getgenv()._cleanup then pcall(getgenv()._cleanup) end
	hideTrajectory(); pcall(function() gui:Destroy() end); notify("Unloaded", "warn", 2)
end)
utilTab:Label("RightControl toggles menu. Drag the top bar to move.")
utilTab:Label("Keybinds: V = Reach | L = Autoguard | H = Visualizer")
UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.V then
		Config.Enabled = not Config.Enabled
		if visualizerBox then visualizerBox.Visible = Config.Enabled and Config.Visualizer end
		notify(Config.Enabled and "Reach ON" or "Reach OFF", Config.Enabled and "good" or "warn")
	elseif inp.KeyCode == Enum.KeyCode.L then
		getgenv().guarding = not getgenv().guarding
		if not getgenv().guarding then targetBall = nil; smoothAcc = Vector3.zero end
		notify(getgenv().guarding and "Autoguard ON" or "Autoguard OFF", getgenv().guarding and "good" or "warn")
	elseif inp.KeyCode == Enum.KeyCode.H then
		Config.Visualizer = not Config.Visualizer
		if visualizerBox then visualizerBox.Visible = Config.Enabled and Config.Visualizer end
		notify(Config.Visualizer and "Visualizer ON" or "Visualizer OFF", "good")
	end
end)
initializeHooks(); initializeBallMonitoring(); rebuildBallCache()
trackConn(Workspace.DescendantAdded:Connect(trackBall))
trackConn(Workspace.DescendantRemoving:Connect(untrackBall))
trackConn(RunService.Heartbeat:Connect(function()
	if not getgenv().guarding then return end
	local myRoot, myHum = getRoot(LocalPlayer), getHumanoid(LocalPlayer)
	if not (myRoot and myHum and targetBall and targetBall.Parent) then return end
	if myHum.Health <= 0 or isPlayerMoving() then return end
	local bp, mp, bv = targetBall.Position, myRoot.Position, targetBall.AssemblyLinearVelocity
	updateAcceleration(bv)
	local dist = (Vector3.new(mp.X, 0, mp.Z) - Vector3.new(bp.X, 0, bp.Z)).Magnitude
	if dist > getgenv().settings.maxDist then if not windowFocused then issueMove(myHum, mp) end return end
	local inAir = bp.Y > (mp.Y + 2)
	local targetPos
	if inAir then
		local land, t = calculateLandingSpot(bp, bv, mp.Y)
		targetPos = (t > 0.05 and t < getgenv().settings.maxPredTime) and land or Vector3.new(bp.X, mp.Y, bp.Z)
	else targetPos = calculateGroundPrediction(bp, bv, mp) end
	local gap = (Vector3.new(targetPos.X, 0, targetPos.Z) - Vector3.new(mp.X, 0, mp.Z)).Magnitude
	if gap > getgenv().settings.stopDist then
		if gap < getgenv().settings.slowdownRange then
			issueMove(myHum, mp + (targetPos - mp) * (gap / getgenv().settings.slowdownRange))
		else issueMove(myHum, targetPos) end
	end
			if getgenv().settings.lookAtBall and dist < 10 and not guardWalking() then
		local hum = guardHum(LocalPlayer)
		if hum then hum.AutoRotate = true end
	end
end))
trackConn(RunService.Stepped:Connect(function()
	local char = LocalPlayer.Character
	if char then processReachFrame(char) end
	if TrajectoryConfig.Enabled then
		local activeBall = targetBall or (char and char.PrimaryPart and findClosestBall(char.PrimaryPart.Position))
		if activeBall and checkTrajectoryTrigger(activeBall) then drawTrajectoryTrail(activeBall)
		else hideTrajectory() end
	else hideTrajectory() end
end))
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.3); setupCharacterPhysics(char); setupVisualizer(); task.spawn(ProcessCharacterBypass, char)
end)
if LocalPlayer.Character then
	setupCharacterPhysics(LocalPlayer.Character); setupVisualizer(); task.spawn(ProcessCharacterBypass, LocalPlayer.Character)
end
trackConn(LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
end))
trackConn(UserInputService.WindowFocused:Connect(function() windowFocused = true end))
trackConn(UserInputService.WindowFocusReleased:Connect(function() windowFocused = false end))
getgenv()._cleanup = function()
	for _, c in ipairs(connections) do if c.Connected then c:Disconnect() end end
	table.clear(connections)
	if scanTask then pcall(task.cancel, scanTask) end
	for _, conn in pairs(ballConnections) do if conn then conn:Disconnect() end end
	table.clear(ballConnections); hideTrajectory()
	if proxyAnchor then pcall(function() proxyAnchor:Destroy() end) end
	if visualizerBox then pcall(function() visualizerBox:Destroy() end) end
end
doMinimize = function(force)
	if force ~= nil then minimized = force else minimized = not minimized end
	local k = (main:FindFirstChildOfClass("UIScale") and main:FindFirstChildOfClass("UIScale").Scale) or 1
	local shift = ((H - TOP) / 2) * k
	local p = main.Position
	if minimized then
		tw(main, 0.28, { Size = UDim2.fromOffset(W, TOP), Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset - shift) }, Enum.EasingStyle.Quint)
	else
		tw(main, 0.28, { Size = UDim2.fromOffset(W, H), Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + shift) }, Enum.EasingStyle.Quint)
	end
end
task.spawn(function()
	while not destroyed do
		task.wait(1.2)
		local plr = Players.LocalPlayer
		local cam = workspace.CurrentCamera
		local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
		if cam and hum then
			pcall(function()
				if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
				if cam.CameraSubject ~= hum then cam.CameraSubject = hum end
				if hum.AutoRotate == false then hum.AutoRotate = true end
			end)
		end
	end
end)
boot({ "checking executor", "loading reach", "wiring systems", "ready" }, function()
	notify("Tempo TSFL loaded", "good")
end)
