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
	local keyless = false
	pcall(function()
		local c = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/control.json?t=" .. tostring(os.time())))
		keyless = c.keyRequired == false
	end)
	if not keyless then
		local key = g.__TempoKey or g.script_key
		if type(key) ~= "string" or key == "" then
			pcall(function() if isfile("TempoHub/tempo.key") then key = readfile("TempoHub/tempo.key") end end)
		end
		key = type(key) == "string" and key:gsub("%s+", "") or ""
		local ok, why = false, "no key"
		for try = 1, (key ~= "" and 2 or 0) do
			local src
			pcall(function() src = game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Key.lua?t=" .. tostring(os.time())) end)
			local fn = src and loadstring(src)
			if not fn then
				why = "couldn't check your key, try again in a minute"
			else
				local ran, a, b = pcall(fn, { verify = key })
				if not ran then why = "key check failed, try again in a minute" beacon("check crashed: " .. tostring(a))
				else ok, why = a == true, b end
			end
			if ok or not (type(why) == "string" and (why:find("reach") or why:find("try again"))) then break end
			task.wait(3)
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
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterPack = game:GetService("StarterPack")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, HRP
local function refreshChar(char)
	Character = char
	Humanoid = char and char:FindFirstChildOfClass("Humanoid")
	HRP = char and char:FindFirstChild("HumanoidRootPart")
end
if LocalPlayer.Character then refreshChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.3) refreshChar(c) end)
local P = {
	bg = Color3.fromRGB(8,6,14), panel = Color3.fromRGB(12,9,20), rail = Color3.fromRGB(10,8,18),
	top = Color3.fromRGB(14,11,24), card = Color3.fromRGB(18,14,30), cardHov = Color3.fromRGB(28,20,44),
	line = Color3.fromRGB(55,40,85), off = Color3.fromRGB(40,30,58), accent = Color3.fromRGB(168,110,255),
	accentD = Color3.fromRGB(110,55,200), accent2 = Color3.fromRGB(255,95,210), glow = Color3.fromRGB(210,175,255),
	hot = Color3.fromRGB(245,235,255), text = Color3.fromRGB(240,235,250), dim = Color3.fromRGB(145,135,165),
	faint = Color3.fromRGB(95,85,120), good = Color3.fromRGB(90,230,160), warn = Color3.fromRGB(255,190,90),
	bad = Color3.fromRGB(255,95,120),
}
local MARK_IMG = "rbxassetid://" .. "1904867353"
local SKY_IMG = "rbxassetid://" .. "111702597357462"
local function font(name, weight)
	local ok, f = pcall(function() return Font.new("rbxasset://fonts/families/"..name..".json", weight) end)
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
local function grad(o, a, b, rot)
	local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(a, b); g.Rotation = rot or 90; g.Parent = o; return g
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
		g.Size = UDim2.new(1, i*step*2, 1, i*step*2); g.BackgroundTransparency = 1; g.BorderSizePixel = 0
		g.ZIndex = (inst.ZIndex or 2) - 1; g.Parent = inst
		corner(g, rad + i*step); out[i] = stroke(g, col, 1.2, start + i*0.14)
	end
	return out
end
local function sheen(parent, z)
	local s = Instance.new("Frame"); s.BackgroundColor3 = Color3.new(1,1,1); s.BackgroundTransparency = 0.94
	s.BorderSizePixel = 0; s.Size = UDim2.fromScale(1,1); s.ZIndex = z or (parent.ZIndex+1); s.Parent = parent
	local g = Instance.new("UIGradient"); g.Rotation = 115
	g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.5), NumberSequenceKeypoint.new(0.4,0.9), NumberSequenceKeypoint.new(1,1)})
	g.Parent = s; return s
end
local function drawMark(parent, size, z)
	local h = fr(parent, z); h.Size = UDim2.fromOffset(size, size)
	local ring = fr(h, z); ring.AnchorPoint = Vector2.new(0.5,0.5); ring.Position = UDim2.fromScale(0.5,0.5)
	ring.Size = UDim2.fromOffset(size, size); corner(ring, size); stroke(ring, P.accent, 1.4, 0.2)
	local img = Instance.new("ImageLabel"); img.BackgroundTransparency = 1; img.Size = UDim2.fromScale(0.86,0.86)
	img.AnchorPoint = Vector2.new(0.5,0.5); img.Position = UDim2.fromScale(0.5,0.5); img.Image = MARK_IMG
	img.ScaleType = Enum.ScaleType.Fit; img.ZIndex = z+1; img.Parent = h
	local core = bx(h, P.accent, z+3); core.AnchorPoint = Vector2.new(0.5,0.5); core.Position = UDim2.fromScale(0.5,0.5)
	core.Size = UDim2.fromOffset(size*0.12, size*0.12); core.BackgroundTransparency = 0.3; corner(core, size)
	local pulse = fr(h, z); pulse.AnchorPoint = Vector2.new(0.5,0.5); pulse.Position = UDim2.fromScale(0.5,0.5)
	local ps = stroke(pulse, P.glow, 1.1, 1); corner(pulse, size)
	local t0 = 0
	local conn = RunService.RenderStepped:Connect(function(dt)
		t0 += dt; local f = (t0*0.55)%1
		pulse.Size = UDim2.fromOffset(size*(0.28+f*0.8), size*(0.28+f*0.8))
		ps.Transparency = 0.3+f*0.7; img.Rotation = math.sin(t0*0.7)*5
		local s = size*0.16 + math.sin(t0*2.2)*size*0.03; core.Size = UDim2.fromOffset(s,s)
	end)
	h.Destroying:Connect(function() pcall(function() conn:Disconnect() end) end)
	return h
end
local function makeRipples(root)
	local pool, idx = {}, 0
	for i = 1, 5 do
		local r = fr(root, 55); r.AnchorPoint = Vector2.new(0.5,0.5); r.Visible = false; corner(r, 200)
		pool[i] = {f=r, s=stroke(r, P.glow, 1.4, 0)}
	end
	return function(parent, x, y, size)
		idx = idx%5+1; local e = pool[idx]
		e.f.Parent = parent; e.f.Position = UDim2.fromOffset(x,y); e.f.Size = UDim2.fromOffset(8,8); e.f.Visible = true
		e.s.Color = P.accent; e.s.Transparency = 0.12
		tw(e.f, 0.5, {Size=UDim2.fromOffset(size or 160, size or 160)}, Enum.EasingStyle.Quint)
		local fade = tw(e.s, 0.5, {Transparency=1})
		fade.Completed:Once(function() e.f.Visible = false end)
	end
end
for _, root in ipairs({rawget(getfenv(),"gethui") and gethui() or nil, game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui")}) do
	if root then pcall(function()
		for _, g in ipairs(root:GetChildren()) do
			if g:IsA("ScreenGui") and (string.match(g.Name,"^TempoSoccer_") or g.Name=="KaivenHub" or g.Name=="RadarGUI") then g:Destroy() end
		end
	end) end
end
local function mount(name)
	local sg = Instance.new("ScreenGui"); sg.Name = name; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.DisplayOrder = 100000
	local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
	if not ok then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
	return sg
end
local function drag(handle, target)
	local dragging = false
	local startMouse, startPos
	handle.Active = true
	handle.Selectable = true
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startMouse = i.Position
			startPos = target.AbsolutePosition
			pcall(function()
				i.Changed:Connect(function()
					if i.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not dragging then return end
		if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = i.Position - startMouse
		local parent = target.Parent
		local parentAbs = parent and parent.AbsolutePosition or Vector2.zero
		local newX = startPos.X + delta.X - parentAbs.X
		local newY = startPos.Y + delta.Y - parentAbs.Y
		target.Position = UDim2.fromOffset(newX, newY)
		target.AnchorPoint = Vector2.new(0, 0)
	end)
end
local W, H, SIDE, TOP = 720, 480, 168, 48
local function isTouch() return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled end
local function windowScale()
	local cam = workspace.CurrentCamera; local vp = cam and cam.ViewportSize
	if not vp or vp.Y <= 0 then return 1 end
	if isTouch() then
		local short = math.min(vp.X, vp.Y)
		if short < 500 then return math.clamp(math.min((vp.Y*0.88)/H, (vp.X*0.96)/W), 0.42, 0.85) end
		return math.clamp(math.min((vp.Y*0.76)/H, (vp.X*0.82)/W), 0.74, 1.15)
	end
	return math.clamp(math.min((vp.Y*0.55)/H, (vp.X*0.42)/W), 0.9, 1.4)
end
local gui = mount("TempoSoccer_"..math.random(1000,9999))
local ripple = makeRipples(gui)
local main = bx(gui, P.panel, 2)
main.BackgroundTransparency = 0.12; main.Name = "Main"; main.Size = UDim2.fromOffset(W,H)
main.AnchorPoint = Vector2.new(0.5,0.5); main.Position = UDim2.fromScale(0.5,0.5)
main.Visible = false; main.ClipsDescendants = true; main.Active = true
corner(main, 20); local mainStroke = stroke(main, P.accent, 1.6, 0.35)
glow(main, P.accent, 3, 4, 20, 0.45); sheen(main, 3)
local field = fr(main, 2); field.Size = UDim2.fromScale(1,1); field.ZIndex = 2; field.ClipsDescendants = true
local function skyLayer(z, scale, trans)
	local photo = Instance.new("ImageLabel"); photo.BackgroundTransparency = 1
	photo.AnchorPoint = Vector2.new(0.5,0.5); photo.Position = UDim2.fromScale(0.5,0.5)
	photo.Size = UDim2.fromScale(scale, scale); photo.Image = SKY_IMG; photo.ImageTransparency = trans
	photo.ScaleType = Enum.ScaleType.Crop; photo.ZIndex = z; photo.Parent = field; corner(photo, 20); return photo
end
local skyBack = skyLayer(2,1.2,0.2); local skyMid = skyLayer(2,1.1,0.08); local skyFront = skyLayer(2,1.04,0)
local grade = Instance.new("Frame"); grade.Size = UDim2.fromScale(1,1); grade.BackgroundColor3 = Color3.fromRGB(30,8,55)
grade.BackgroundTransparency = 0.72; grade.BorderSizePixel = 0; grade.ZIndex = 2; grade.Parent = field; corner(grade,20)
local ggrad = Instance.new("UIGradient"); ggrad.Rotation = 90
ggrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(0.5,0.5),NumberSequenceKeypoint.new(1,0)})
ggrad.Parent = grade
local petals = {}
for i = 1, 12 do
	local petal = Instance.new("ImageLabel"); petal.BackgroundTransparency = 1; petal.Image = MARK_IMG
	petal.ImageColor3 = Color3.fromRGB(165+math.random(0,40),55+math.random(0,40),205+math.random(0,40))
	petal.ImageTransparency = 0.3+math.random()*0.4; local sz = math.random(9,16)
	petal.Size = UDim2.fromOffset(sz,sz); petal.Rotation = math.random(0,360); petal.ZIndex = 5
	petal.ScaleType = Enum.ScaleType.Fit; petal.Parent = field
	petals[i] = {obj=petal, x=math.random(), y=-0.2-math.random(), sp=0.025+math.random()*0.05, sway=0.25+math.random()*0.5, phase=math.random()*6.28, spin=(math.random()-0.5)*24}
end
local skyT = 0
RunService.RenderStepped:Connect(function(dt)
	if not main.Parent then return end
	skyT += dt
	local zx = math.sin(skyT*0.05)*0.015; local zy = math.cos(skyT*0.04)*0.01
	local zoom = 1.04 + math.sin(skyT*0.03)*0.025
	skyFront.Size = UDim2.fromScale(zoom,zoom); skyFront.Position = UDim2.new(0.5+zx,0,0.5+zy,0)
	skyMid.Size = UDim2.fromScale(zoom+0.04,zoom+0.04); skyMid.Position = UDim2.new(0.5+zx*0.5,0,0.5+zy*0.5,0)
	skyBack.Size = UDim2.fromScale(zoom+0.1,zoom+0.1); skyBack.Position = UDim2.new(0.5+zx*0.25,0,0.5+zy*0.25,0)
	for _, pt in ipairs(petals) do
		pt.y += pt.sp*dt*0.45; local sway = math.sin(skyT*pt.sway+pt.phase)*0.04
		if pt.y > 1.15 then pt.y = -0.15-math.random()*0.2; pt.x = math.random() end
		pt.obj.Position = UDim2.new(pt.x+sway,0,pt.y,0); pt.obj.Rotation = pt.obj.Rotation + pt.spin*dt
	end
end)
local us = Instance.new("UIScale"); us.Scale = windowScale(); us.Parent = main
local cam = workspace.CurrentCamera
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	pcall(function() us.Scale = windowScale() end)
end) end
task.spawn(function()
	local t = 0
	while main.Parent do t += RunService.RenderStepped:Wait(); mainStroke.Transparency = 0.3+math.sin(t*1.3)*0.1 end
end)
local top = bx(main, P.top, 4); top.BackgroundTransparency = 0.05; top.Size = UDim2.new(1,0,0,TOP)
top.Active = true; top.Selectable = true
drag(top, main); sheen(top, 5)
local hair = bx(top, P.line, 5); hair.Size = UDim2.new(1,0,0,1); hair.Position = UDim2.new(0,0,1,-1)
grad(hair, P.accent, P.line, 0)
local mark = drawMark(top, 26, 6); mark.Position = UDim2.fromOffset(12,11)
local title = tx(top, "Tempo Hub", F_D, 14, P.text); title.Size = UDim2.fromOffset(200,16); title.Position = UDim2.fromOffset(48,10); title.ZIndex = 6
local sub = tx(top, "UNIVERSAL  ·  VEF", F_MO, 8, P.faint); sub.Size = UDim2.fromOffset(220,11); sub.Position = UDim2.fromOffset(48,27); sub.ZIndex = 6
local function chromeBtn(x, label, col, fn)
	local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(28,28); b.Position = UDim2.new(1,x,0.5,-14)
	b.BackgroundColor3 = P.card; b.BackgroundTransparency = 1; b.AutoButtonColor = false; b.Text = label
	b.FontFace = F_S; b.TextSize = 12; b.TextColor3 = col; b.BorderSizePixel = 0; b.ZIndex = 7; b.Parent = top
	corner(b, 10); local st = stroke(b, col, 1, 0.7)
	b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundTransparency=0}); tw(st,0.12,{Transparency=0.2}) end)
	b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundTransparency=1}); tw(st,0.12,{Transparency=0.7}) end)
	b.MouseButton1Click:Connect(function() ripple(b,14,14,80); fn() end)
	return b
end
local show, hide, doMinimize; local minimized = false
chromeBtn(-34, "x", P.bad, function() hide() end)
chromeBtn(-66, "-", P.dim, function() doMinimize() end)
doMinimize = function(force)
	if force ~= nil then minimized = force else minimized = not minimized end
	local k = us.Scale; local shift = ((H-TOP)/2)*k; local p = main.Position
	if minimized then
		tw(main, 0.28, {Size=UDim2.fromOffset(W,TOP), Position=UDim2.new(p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset-shift)}, Enum.EasingStyle.Quint)
	else
		tw(main, 0.28, {Size=UDim2.fromOffset(W,H), Position=UDim2.new(p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset+shift)}, Enum.EasingStyle.Quint)
	end
end
local side = bx(main, P.rail, 3); side.BackgroundTransparency = 0.05
side.Size = UDim2.new(0,SIDE,1,-TOP); side.Position = UDim2.new(0,0,0,TOP)
side.Active = true
drag(side, main)
local sdiv = bx(side, P.line, 4); sdiv.Size = UDim2.new(0,1,1,0); sdiv.Position = UDim2.new(1,-1,0,0); grad(sdiv, P.accent, P.line, 90)
local nav = Instance.new("ScrollingFrame"); nav.BackgroundTransparency = 1; nav.BorderSizePixel = 0
nav.Size = UDim2.new(1,-12,1,-58); nav.Position = UDim2.fromOffset(6,10); nav.ScrollBarThickness = 0
nav.CanvasSize = UDim2.new(); nav.AutomaticCanvasSize = Enum.AutomaticSize.Y; nav.ZIndex = 4; nav.Parent = side
local nl = Instance.new("UIListLayout"); nl.Padding = UDim.new(0,4); nl.SortOrder = Enum.SortOrder.LayoutOrder; nl.Parent = nav
local uc = bx(side, P.card, 4); uc.Size = UDim2.new(1,-12,0,40); uc.Position = UDim2.new(0,6,1,-48)
corner(uc,14); stroke(uc, P.line,1,0.4); sheen(uc,5)
local av = bx(uc, P.accentD, 5); av.Size = UDim2.fromOffset(26,26); av.Position = UDim2.new(0,7,0.5,-13); corner(av,10)
grad(av, P.accent, P.accent2, 45)
local avt = tx(uc, string.sub(LocalPlayer.DisplayName,1,1):upper(), F_D, 11, P.hot)
avt.Size = UDim2.fromOffset(26,26); avt.Position = UDim2.new(0,7,0.5,-13); avt.TextXAlignment = Enum.TextXAlignment.Center; avt.ZIndex = 6
local un = tx(uc, LocalPlayer.DisplayName, F_S, 10, P.text); un.Size = UDim2.new(1,-42,0,13); un.Position = UDim2.fromOffset(38,6); un.ZIndex = 6
local uh = tx(uc, "@"..LocalPlayer.Name, F_MO, 8, P.faint); uh.Size = UDim2.new(1,-42,0,11); uh.Position = UDim2.fromOffset(38,20); uh.ZIndex = 6
local content = fr(main, 3)
content.Size = UDim2.new(1,-(SIDE+20),1,-(TOP+16)); content.Position = UDim2.fromOffset(SIDE+12, TOP+10); content.ClipsDescendants = true
local ORB = isTouch() and 56 or 48
local orb = Instance.new("TextButton"); orb.Name = "Orb"; orb.Size = UDim2.fromOffset(ORB,ORB)
orb.Position = UDim2.new(0,16,0.55,0); orb.BackgroundColor3 = P.bg; orb.AutoButtonColor = false; orb.Text = ""
orb.BorderSizePixel = 0; orb.Visible = false; orb.ZIndex = 30; orb.Parent = gui
corner(orb, ORB/2); stroke(orb, P.accent, 1.4, 0.2); glow(orb, P.accent, 2, 3, ORB/2, 0.42)
local om = drawMark(orb, ORB*0.58, 31); om.AnchorPoint = Vector2.new(0.5,0.5); om.Position = UDim2.fromScale(0.5,0.5)
local mobileBar = bx(gui, P.top, 28); mobileBar.AnchorPoint = Vector2.new(0.5,0)
mobileBar.Position = UDim2.new(0.5,0,0,12); mobileBar.Size = UDim2.fromOffset(230,42); mobileBar.ZIndex = 28
mobileBar.Visible = isTouch(); corner(mobileBar,21); stroke(mobileBar, P.accent,1.3,0.25); glow(mobileBar, P.accent,2,2,21,0.48); sheen(mobileBar,29)
mobileBar.Active = true
drag(mobileBar, mobileBar)
local function mBtn(label, x, col, fn)
	local b = Instance.new("TextButton"); b.Size = UDim2.fromOffset(66,30); b.Position = UDim2.fromOffset(x,6)
	b.BackgroundColor3 = P.card; b.AutoButtonColor = false; b.Text = label; b.FontFace = F_S; b.TextSize = 11
	b.TextColor3 = col; b.BorderSizePixel = 0; b.ZIndex = 29; b.Parent = mobileBar; corner(b,12)
	local st = stroke(b, col, 1, 0.5)
	b.MouseEnter:Connect(function() tw(b,0.1,{BackgroundColor3=P.cardHov}); tw(st,0.1,{Transparency=0.15}) end)
	b.MouseLeave:Connect(function() tw(b,0.1,{BackgroundColor3=P.card}); tw(st,0.1,{Transparency=0.5}) end)
	b.MouseButton1Click:Connect(function() ripple(b,33,15,100); fn() end)
	return b
end
show = function()
	if minimized then doMinimize(false) end
	orb.Visible = false; main.Visible = true
	local t = windowScale(); us.Scale = t*0.9
	main.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset+12)
	tw(us, 0.35, {Scale=t}, Enum.EasingStyle.Back)
	tw(main, 0.35, {Position=UDim2.new(main.Position.X.Scale,main.Position.X.Offset,main.Position.Y.Scale,main.Position.Y.Offset-12)}, Enum.EasingStyle.Quint)
end
hide = function()
	main.Visible = false; minimized = false; main.Size = UDim2.fromOffset(W,H)
	orb.Visible = true; orb.Size = UDim2.fromOffset(0,0)
	tw(orb, 0.3, {Size=UDim2.fromOffset(ORB,ORB)}, Enum.EasingStyle.Back)
end
mBtn("Open", 12, P.good, function() show() end)
mBtn("Half", 82, P.glow, function() if not main.Visible then show() end; task.defer(function() doMinimize(true) end) end)
mBtn("Close", 152, P.bad, function() hide() end)
local downAt, moved
orb.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then downAt, moved = i.Position, false end
end)
UserInputService.InputChanged:Connect(function(i)
	if downAt and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		if (i.Position-downAt).Magnitude > 6 then moved = true end
	end
end)
orb.MouseButton1Click:Connect(function() if not moved then show() end end)
drag(orb, orb)
UserInputService.InputBegan:Connect(function(i, gp)
	if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if i.KeyCode == Enum.KeyCode.RightControl then if main.Visible then hide() else show() end end
end)
local pages, navBtns, active = {}, {}, nil
local tabOrder = 0
local function selectTab(name)
	if active == name then return end; active = name
	for n, p in pairs(pages) do
		p.Visible = (n==name)
		if n==name then p.Position = UDim2.fromOffset(8,0); p.CanvasPosition = Vector2.zero; tw(p,0.28,{Position=UDim2.fromOffset(0,0)}, Enum.EasingStyle.Quint) end
	end
	for n, nb in pairs(navBtns) do
		local on = (n==name)
		tw(nb.label,0.16,{TextColor3=on and P.text or P.dim})
		tw(nb.icon,0.16,{TextColor3=on and P.accent or P.dim})
		tw(nb.btn,0.16,{BackgroundTransparency=on and 0 or 1})
	end
end
local function makeTab(name, icon)
	tabOrder += 1
	local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,38); b.BackgroundColor3 = P.cardHov
	b.BackgroundTransparency = 1; b.AutoButtonColor = false; b.Text = ""; b.BorderSizePixel = 0
	b.LayoutOrder = tabOrder; b.ZIndex = 5; b.Parent = nav; corner(b,12)
	local ic = tx(b, icon or "•", F_R, 14, P.dim); ic.Size = UDim2.fromOffset(28,38); ic.Position = UDim2.fromOffset(8,0)
	ic.TextXAlignment = Enum.TextXAlignment.Center; ic.ZIndex = 6
	local l = tx(b, name, F_M, 13, P.dim); l.Size = UDim2.new(1,-44,1,0); l.Position = UDim2.fromOffset(38,0); l.ZIndex = 6
	local page = Instance.new("ScrollingFrame"); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
	page.Size = UDim2.fromScale(1,1); page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = P.accent
	page.ScrollBarImageTransparency = 0.4; page.CanvasSize = UDim2.new(); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false; page.ZIndex = 4; page.Parent = content
	local list = Instance.new("UIListLayout"); list.Padding = UDim.new(0,10); list.SortOrder = Enum.SortOrder.LayoutOrder; list.Parent = page
	local pad = Instance.new("UIPadding"); pad.PaddingTop = UDim.new(0,4); pad.PaddingRight = UDim.new(0,4)
	pad.PaddingBottom = UDim.new(0,8); pad.PaddingLeft = UDim.new(0,2); pad.Parent = page
	pages[name] = page; navBtns[name] = {btn=b, label=l, icon=ic}
	b.MouseEnter:Connect(function() if active~=name then tw(l,0.12,{TextColor3=P.text}); tw(ic,0.12,{TextColor3=P.glow}); tw(b,0.12,{BackgroundTransparency=0.5}) end end)
	b.MouseLeave:Connect(function() if active~=name then tw(l,0.12,{TextColor3=P.dim}); tw(ic,0.12,{TextColor3=P.dim}); tw(b,0.12,{BackgroundTransparency=1}) end end)
	b.MouseButton1Click:Connect(function() ripple(b,20,19,100); selectTab(name) end)
	if not active then selectTab(name) end
	local rows = 0; local tab = {}
	local function rowBase(h)
		rows += 1
		local r = bx(page, P.card, 3); r.Size = UDim2.new(1,-4,0,h); r.LayoutOrder = rows; r.BackgroundTransparency = 1
		corner(r,16); stroke(r, P.line,1,0.4); sheen(r,4)
		local sc = Instance.new("UIScale"); sc.Scale = 0.94; sc.Parent = r
		task.delay(rows*0.03, function()
			if not r.Parent then return end
			tw(r,0.28,{BackgroundTransparency=0}, Enum.EasingStyle.Quint)
			tw(sc,0.3,{Scale=1}, Enum.EasingStyle.Back)
			task.delay(0.4, function() pcall(function() sc:Destroy() end) end)
		end)
		return r
	end
	function tab:Section(titleText, desc)
		rows += 1
		local s = fr(page, 3); s.Size = UDim2.new(1,-4,0,desc and 42 or 26); s.LayoutOrder = rows
		local l2 = tx(s, titleText, F_B, 16, P.text); l2.Size = UDim2.new(1,-8,0,20); l2.Position = UDim2.fromOffset(2,2); l2.ZIndex = 4; l2.TextTransparency = 1
		if desc then
			local d = tx(s, desc, F_R, 11, P.dim); d.Size = UDim2.new(1,-8,0,16); d.Position = UDim2.fromOffset(2,22); d.ZIndex = 4; d.TextTransparency = 1
			task.delay(rows*0.03, function() tw(l2,0.28,{TextTransparency=0}); tw(d,0.28,{TextTransparency=0}) end)
		else task.delay(rows*0.03, function() tw(l2,0.28,{TextTransparency=0}) end) end
	end
	function tab:Label(text)
		rows += 1
		local l2 = tx(page, text, F_R, 11, P.dim); l2.Size = UDim2.new(1,-8,0,0); l2.AutomaticSize = Enum.AutomaticSize.Y
		l2.TextWrapped = true; l2.TextYAlignment = Enum.TextYAlignment.Top; l2.LayoutOrder = rows; l2.ZIndex = 4; l2.TextTransparency = 1
		task.delay(rows*0.03, function() tw(l2,0.28,{TextTransparency=0}) end)
	end
	function tab:Toggle(label, desc, default, cb)
		local on = default and true or false; local h = desc and 56 or 44; local r = rowBase(h)
		local l2 = tx(r, label, F_S, 13, P.text); l2.Size = UDim2.new(1,-70,0,18); l2.Position = UDim2.fromOffset(16, desc and 10 or 13); l2.ZIndex = 5
		if desc then local d = tx(r, desc, F_R, 11, P.dim); d.Size = UDim2.new(1,-70,0,16); d.Position = UDim2.fromOffset(16,30); d.ZIndex = 5 end
		local box = bx(r, on and P.accent or P.off, 5); box.AnchorPoint = Vector2.new(1,0.5); box.Position = UDim2.new(1,-16,0.5,0)
		box.Size = UDim2.fromOffset(22,22); corner(box,8); stroke(box, on and P.accent or P.line, 1, on and 0.2 or 0.45)
		local check = tx(box, "✓", F_B, 14, P.hot); check.Size = UDim2.fromScale(1,1); check.TextXAlignment = Enum.TextXAlignment.Center
		check.TextTransparency = on and 0 or 1; check.ZIndex = 6
		local function apply(v, fire, anim)
			on = v and true or false
			tw(box, anim and 0.18 or 0, {BackgroundColor3=on and P.accent or P.off})
			tw(check, anim and 0.18 or 0, {TextTransparency=on and 0 or 1})
			if fire and cb then pcall(cb, on) end
		end
		local hit = Instance.new("TextButton"); hit.Size = UDim2.fromScale(1,1); hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 8; hit.Parent = r
		hit.MouseEnter:Connect(function() tw(r,0.12,{BackgroundColor3=P.cardHov}) end)
		hit.MouseLeave:Connect(function() tw(r,0.12,{BackgroundColor3=P.card}) end)
		hit.MouseButton1Click:Connect(function() apply(not on, true, true); if on then ripple(r, r.AbsoluteSize.X-28, r.AbsoluteSize.Y/2, 120) end end)
		return {Set=function(_,v) apply(v,true,true) end, Get=function() return on end}
	end
	function tab:Slider(label, desc, min, max, default, cb, suffix)
		local val = math.clamp(default or min, min, max)
		local dec = (max-min)<=3 and 2 or 0
		local function fmt(v) if dec>0 then return string.format("%."..dec.."f",v) end; return tostring(math.floor(v+0.5)) end
		local h = desc and 68 or 54; local r = rowBase(h)
		local l2 = tx(r, label, F_S, 13, P.text); l2.Size = UDim2.new(1,-100,0,16); l2.Position = UDim2.fromOffset(16,10); l2.ZIndex = 5
		if desc then local d = tx(r, desc, F_R, 11, P.dim); d.Size = UDim2.new(1,-100,0,14); d.Position = UDim2.fromOffset(16,28); d.ZIndex = 5 end
		local v = tx(r, fmt(val)..(suffix or ""), F_MB, 12, P.accent); v.AnchorPoint = Vector2.new(1,0)
		v.Position = UDim2.new(1,-16,0,10); v.Size = UDim2.fromOffset(70,16); v.TextXAlignment = Enum.TextXAlignment.Right; v.ZIndex = 5
		local trackY = desc and 50 or 36
		local track = bx(r, P.off, 5); track.Size = UDim2.new(1,-32,0,5); track.Position = UDim2.fromOffset(16,trackY); corner(track,3)
		local fill = bx(track, P.accent, 6); fill.Size = UDim2.fromScale((val-min)/(max-min),1); corner(fill,3); grad(fill, P.accentD, P.glow, 0)
		local knob = bx(track, P.hot, 8); knob.AnchorPoint = Vector2.new(0.5,0.5); knob.Position = UDim2.fromScale((val-min)/(max-min),0.5)
		knob.Size = UDim2.fromOffset(14,14); corner(knob,7); stroke(knob, P.accent,1,0.25)
		local hit = Instance.new("TextButton"); hit.Position = UDim2.fromOffset(0,trackY-10); hit.Size = UDim2.new(1,0,0,28)
		hit.BackgroundTransparency = 1; hit.Text = ""; hit.ZIndex = 9; hit.Parent = r
		local held = false
		local function apply(px, fire)
			local k = math.clamp((px-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
			val = min+(max-min)*k; if dec==0 then val = math.floor(val+0.5) end
			v.Text = fmt(val)..(suffix or ""); fill.Size = UDim2.fromScale(k,1); knob.Position = UDim2.fromScale(k,0.5)
			if fire and cb then pcall(cb, val) end
		end
		hit.InputBegan:Connect(function(i)
			if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
				held=true; apply(i.Position.X,true); tw(knob,0.1,{Size=UDim2.fromOffset(18,18)}, Enum.EasingStyle.Back)
			end
		end)
		UserInputService.InputChanged:Connect(function(i)
			if held and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then apply(i.Position.X,true) end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if held and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
				held=false; tw(knob,0.12,{Size=UDim2.fromOffset(14,14)})
			end
		end)
		return {Set=function(_,nv) val=math.clamp(nv,min,max); local k=(val-min)/(max-min); v.Text=fmt(val)..(suffix or""); fill.Size=UDim2.fromScale(k,1); knob.Position=UDim2.fromScale(k,0.5); if cb then pcall(cb,val) end end, Get=function() return val end}
	end
	function tab:Button(label, primary, cb)
		rows += 1
		local b2 = Instance.new("TextButton"); b2.Size = UDim2.new(1,-4,0,38)
		b2.BackgroundColor3 = primary and P.accent or P.card; b2.BackgroundTransparency = 1; b2.AutoButtonColor = false
		b2.BorderSizePixel = 0; b2.Text = label; b2.FontFace = primary and F_B or F_S; b2.TextSize = 13
		b2.TextColor3 = primary and Color3.new(1,1,1) or P.text; b2.LayoutOrder = rows; b2.ZIndex = 4; b2.Parent = page
		b2.ClipsDescendants = true; corner(b2,14)
		local sc = Instance.new("UIScale"); sc.Scale = 0.94; sc.Parent = b2
		local g; if primary then grad(b2, P.accent, P.accentD, 90); g = glow(b2, P.accent, 2, 2, 12, 0.48) else stroke(b2, P.line,1,0.3) end
		task.delay(rows*0.03, function()
			if not b2.Parent then return end
			tw(b2,0.28,{BackgroundTransparency=0}); tw(sc,0.3,{Scale=1}, Enum.EasingStyle.Back)
			task.delay(0.4, function() pcall(function() sc:Destroy() end) end)
		end)
		b2.MouseEnter:Connect(function()
			if primary and g then for i,s in ipairs(g) do tw(s,0.12,{Transparency=0.25+i*0.1}) end
			else tw(b2,0.12,{BackgroundColor3=P.cardHov}) end
		end)
		b2.MouseLeave:Connect(function()
			if primary and g then for i,s in ipairs(g) do tw(s,0.12,{Transparency=0.48+i*0.12}) end
			else tw(b2,0.12,{BackgroundColor3=P.card}) end
		end)
		b2.MouseButton1Click:Connect(function()
			ripple(b2, b2.AbsoluteSize.X/2, b2.AbsoluteSize.Y/2, 160)
			local sc2 = Instance.new("UIScale"); sc2.Scale = 0.96; sc2.Parent = b2
			tw(sc2,0.18,{Scale=1}, Enum.EasingStyle.Back); task.delay(0.22, function() pcall(function() sc2:Destroy() end) end)
			if cb then pcall(cb) end
		end)
	end
	function tab:TextInput(label, placeholder, default, cb)
		rows += 1
		local r = rowBase(56)
		local l2 = tx(r, label, F_S, 13, P.text); l2.Size = UDim2.new(1,-20,0,16); l2.Position = UDim2.fromOffset(16,6); l2.ZIndex = 5
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1,-32,0,24); box.Position = UDim2.fromOffset(16,28)
		box.BackgroundColor3 = P.off; box.BorderSizePixel = 0; box.Text = default or ""
		box.PlaceholderText = placeholder or ""; box.FontFace = F_R; box.TextSize = 12
		box.TextColor3 = P.text; box.PlaceholderColor3 = P.faint; box.ClearTextOnFocus = false
		box.ZIndex = 6; box.Parent = r; corner(box, 8); stroke(box, P.line, 1, 0.4)
		box.FocusLost:Connect(function(enter)
			if cb then pcall(cb, box.Text) end
		end)
		return {Set=function(_,v) box.Text=tostring(v or"") end, Get=function() return box.Text end}
	end
	function tab:Dropdown(label, options, default, cb)
		rows += 1
		local opts = options or {}
		local cur = default or (opts[1] or "")
		local open = false
		local r = rowBase(52)
		r.ClipsDescendants = false
		local l2 = tx(r, label, F_S, 13, P.text); l2.Size = UDim2.new(0.42,-8,0,18); l2.Position = UDim2.fromOffset(16,16); l2.ZIndex = 5
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.58,-20,0,28); btn.Position = UDim2.new(0.42,0,0.5,-14)
		btn.BackgroundColor3 = P.off; btn.AutoButtonColor = false; btn.BorderSizePixel = 0
		btn.Text = "  "..tostring(cur).."  v"; btn.FontFace = F_S; btn.TextSize = 12
		btn.TextColor3 = P.text; btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.ZIndex = 6; btn.Parent = r; corner(btn, 8); stroke(btn, P.line, 1, 0.35)
		local list = Instance.new("Frame")
		list.Name = "DropList"
		list.BackgroundColor3 = P.panel
		list.BorderSizePixel = 0
		list.Size = UDim2.new(0.58,-20,0,0)
		list.Position = UDim2.new(0.42,0,1,2)
		list.Visible = false
		list.ClipsDescendants = true
		list.ZIndex = 50
		list.Parent = r
		corner(list, 10); stroke(list, P.accent, 1.2, 0.3)
		local scroll = Instance.new("ScrollingFrame")
		scroll.BackgroundTransparency = 1; scroll.Size = UDim2.new(1,-6,1,-6); scroll.Position = UDim2.fromOffset(3,3)
		scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = P.accent; scroll.BorderSizePixel = 0
		scroll.ZIndex = 51; scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.Parent = list
		local lay = Instance.new("UIListLayout"); lay.Padding = UDim.new(0,2); lay.Parent = scroll
		local function close()
			open = false
			tw(list, 0.15, {Size = UDim2.new(0.58,-20,0,0)}, Enum.EasingStyle.Quint)
			task.delay(0.16, function() if list.Parent then list.Visible = false end end)
		end
		local function pick(v)
			cur = v; btn.Text = "  "..tostring(v).."  v"; close()
			if cb then pcall(cb, v) end
		end
		for _, opt in ipairs(opts) do
			local ob = Instance.new("TextButton")
			ob.Size = UDim2.new(1,-4,0,26); ob.BackgroundColor3 = P.card; ob.BackgroundTransparency = 0.25
			ob.AutoButtonColor = false; ob.BorderSizePixel = 0; ob.Text = "  "..tostring(opt)
			ob.FontFace = F_R; ob.TextSize = 12; ob.TextColor3 = P.text; ob.TextXAlignment = Enum.TextXAlignment.Left
			ob.ZIndex = 52; ob.Parent = scroll; corner(ob, 6)
			ob.MouseEnter:Connect(function() tw(ob,0.1,{BackgroundTransparency=0, BackgroundColor3=P.cardHov}) end)
			ob.MouseLeave:Connect(function() tw(ob,0.1,{BackgroundTransparency=0.25, BackgroundColor3=P.card}) end)
			ob.MouseButton1Click:Connect(function() pick(opt) end)
		end
		scroll.CanvasSize = UDim2.new(0,0,0, #opts * 28)
		btn.MouseButton1Click:Connect(function()
			if open then close(); return end
			open = true; list.Visible = true
			local h = math.min(#opts * 28 + 8, 160)
			list.Size = UDim2.new(0.58,-20,0,0)
			tw(list, 0.2, {Size = UDim2.new(0.58,-20,0,h)}, Enum.EasingStyle.Quint)
		end)
		return {Set=function(_,v) cur=v; btn.Text="  "..tostring(v).."  v" end, Get=function() return cur end}
	end
	return tab
end
local function notify(text, kind, seconds)
	local col = kind=="good" and P.good or kind=="warn" and P.warn or kind=="bad" and P.bad or P.accent
	local n = bx(gui, P.top, 40); n.AnchorPoint = Vector2.new(1,1); n.Position = UDim2.new(1,-16,1,50)
	n.Size = UDim2.fromOffset(260,44); n.BackgroundTransparency = 1; corner(n,14); stroke(n,col,1.2,0.3)
	glow(n,col,2,2,11,0.52); sheen(n,41)
	local bar = bx(n,col,41); bar.Size = UDim2.fromOffset(3,22); bar.Position = UDim2.new(0,12,0.5,-11); corner(bar,2)
	local l = tx(n,text,F_M,12,P.text); l.Size = UDim2.new(1,-32,1,0); l.Position = UDim2.fromOffset(22,0); l.ZIndex=42; l.TextWrapped=true; l.TextTransparency=1
	tw(n,0.2,{BackgroundTransparency=0}); tw(n,0.35,{Position=UDim2.new(1,-16,1,-16)}, Enum.EasingStyle.Back); tw(l,0.25,{TextTransparency=0})
	task.delay(seconds or 3, function()
		tw(n,0.3,{Position=UDim2.new(1,-16,1,55),BackgroundTransparency=1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		tw(l,0.2,{TextTransparency=1}); task.delay(0.35, function() pcall(function() n:Destroy() end) end)
	end)
end
local function boot(steps, onDone)
	steps = steps or {"checking","building","ready"}
	local bg = mount("TempoSoccer_Boot"); bg.DisplayOrder = 100001
	local shade = bx(bg, Color3.new(0,0,0), 1); shade.Size = UDim2.fromScale(1,1); shade.BackgroundTransparency = 1
	local stage = fr(bg, 3); stage.AnchorPoint = Vector2.new(0.5,0.5); stage.Position = UDim2.fromScale(0.5,0.5); stage.Size = UDim2.fromOffset(340,290)
	local halo = bx(stage, P.accentD, 2); halo.AnchorPoint = Vector2.new(0.5,0.5); halo.Position = UDim2.new(0.5,0,0,75)
	halo.Size = UDim2.fromOffset(190,190); halo.BackgroundTransparency = 1; corner(halo,190)
	local m = drawMark(stage, 76, 5); m.AnchorPoint = Vector2.new(0.5,0); m.Position = UDim2.new(0.5,0,0,36)
	local msc = Instance.new("UIScale"); msc.Scale = 0; msc.Parent = m
	local tLabel = tx(stage, "VALKYRIE", F_D, 24, P.text); tLabel.AnchorPoint = Vector2.new(0.5,0); tLabel.Position = UDim2.new(0.5,0,0,132)
	tLabel.Size = UDim2.fromOffset(260,28); tLabel.TextXAlignment = Enum.TextXAlignment.Center; tLabel.TextTransparency = 1; tLabel.ZIndex = 6
	local subL = tx(stage, ". U I", F_MO, 12, P.faint); subL.AnchorPoint = Vector2.new(0.5,0); subL.Position = UDim2.new(0.5,0,0,160)
	subL.Size = UDim2.fromOffset(140,14); subL.TextXAlignment = Enum.TextXAlignment.Center; subL.TextTransparency = 1; subL.ZIndex = 6
	local cap = tx(stage, "", F_MO, 12, P.dim); cap.AnchorPoint = Vector2.new(0.5,0); cap.Position = UDim2.new(0.5,0,0,192)
	cap.Size = UDim2.fromOffset(280,16); cap.TextXAlignment = Enum.TextXAlignment.Center; cap.TextTransparency = 1; cap.ZIndex = 6
	local barBg = bx(stage, P.off, 4); barBg.AnchorPoint = Vector2.new(0.5,0); barBg.Position = UDim2.new(0.5,0,0,222)
	barBg.Size = UDim2.fromOffset(200,4); barBg.BackgroundTransparency = 1; corner(barBg,2)
	local bar = bx(barBg, P.accent, 5); bar.Size = UDim2.fromScale(0,1); corner(bar,2); grad(bar, P.accentD, P.glow, 0)
	local dots = {}
	for i = 1,6 do local d = bx(stage, P.accent, 4); d.Size = UDim2.fromOffset(4,4); d.AnchorPoint = Vector2.new(0.5,0.5); d.BackgroundTransparency = 1; corner(d,4); dots[i] = d end
	local t0 = os.clock()
	local orbitConn = RunService.RenderStepped:Connect(function()
		local t = os.clock()-t0
		for i,d in ipairs(dots) do
			local a = t*1.35 + i*(math.pi*2/6); local rad = 52+math.sin(t*2+i)*4
			d.Position = UDim2.new(0.5, math.cos(a)*rad, 0, 75+math.sin(a)*rad)
		end
	end)
	task.spawn(function()
		tw(shade,0.55,{BackgroundTransparency=0.38}); task.wait(0.2)
		for _,d in ipairs(dots) do tw(d,0.4,{BackgroundTransparency=0.18}) end
		tw(msc,0.65,{Scale=1}, Enum.EasingStyle.Back); tw(halo,0.7,{BackgroundTransparency=0.8}); task.wait(0.45)
		tw(tLabel,0.45,{TextTransparency=0}); task.wait(0.2); tw(subL,0.4,{TextTransparency=0}); task.wait(0.28)
		tw(barBg,0.3,{BackgroundTransparency=0}); tw(cap,0.3,{TextTransparency=0})
		for i,step in ipairs(steps) do cap.Text = tostring(step); tw(bar,0.5,{Size=UDim2.fromScale(i/#steps,1)}, Enum.EasingStyle.Quint); task.wait(0.4) end
		task.wait(0.25)
		for _,d in ipairs(dots) do tw(d,0.25,{BackgroundTransparency=1}) end
		tw(tLabel,0.25,{TextTransparency=1}); tw(subL,0.25,{TextTransparency=1}); tw(cap,0.25,{TextTransparency=1})
		tw(barBg,0.25,{BackgroundTransparency=1}); tw(bar,0.25,{BackgroundTransparency=1}); tw(halo,0.3,{BackgroundTransparency=1})
		tw(msc,0.35,{Scale=0.4}); tw(shade,0.45,{BackgroundTransparency=1}); task.wait(0.4)
		pcall(function() orbitConn:Disconnect() end); show(); pcall(function() bg:Destroy() end)
		if onDone then pcall(onDone) end
	end)
end
local ToolManagment = nil
local function LoadToolManagment()
	for _, container in ipairs({LocalPlayer:FindFirstChild("Backpack"), StarterPack, LocalPlayer:FindFirstChild("PlayerGui"), ReplicatedStorage}) do
		if container then for _, child in ipairs(container:GetChildren()) do
			if child:IsA("ModuleScript") and (child.Name=="ToolManagment" or child.Name=="ToolManagement") then
				local ok, mod = pcall(require, child); if ok then return mod end
			end
		end end
	end
	return nil
end
ToolManagment = LoadToolManagment()
task.spawn(function() while true do task.wait(4); if not ToolManagment then ToolManagment = LoadToolManagment() end end end)
local BALL_NAMES = {ballPart=true,ROFI=true,fakeBall=true,MPS=true,TPS=true,CSF=true,SAML=true,VEF=true,VFA=true,VRF=true,CMP=true,IFF=true,RBZ=true,VCL=true,OPSA=true,CBM=true,RSL=true,OFA=true,AIFA=true,RFA=true,VFL=true,PRS=true,LPFI=true,Ball=true,Football=true}
local function GetVEFBalls()
	local balls = {}
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and BALL_NAMES[obj.Name] and obj.Parent then table.insert(balls, obj) end
	end
	return balls
end
local function GetNearestBall(root, maxDist)
	local closest, closestDist = nil, maxDist or math.huge
	for _, ball in pairs(GetVEFBalls()) do
		if ball and ball.Parent then
			local dist = (ball.Position-root.Position).Magnitude
			if dist < closestDist then closest = ball; closestDist = dist end
		end
	end
	return closest, closestDist
end
local InfJump = false
local WalkSpeedValue = 19
local RadarEnabled = false
local RadarFrame = nil
local SpoofTargetLimb = nil
local FE = {}
(function()
local ReachConfig = {Master=false, Visualizer=false, ReachX=6, ReachY=7, ReachZ=6, Shoot=true, Pass=true, Long=true, Tackle=true, Dribble=true, Save=true}
local ReachBox = Instance.new("Part"); ReachBox.Name = tostring(math.random(100000,999999))
ReachBox.Size = Vector3.new(0,0,0); ReachBox.CFrame = CFrame.new(math.huge,math.huge,math.huge)
ReachBox.Anchored = true; ReachBox.CanCollide = false; ReachBox.CanTouch = true; ReachBox.CanQuery = false
ReachBox.Massless = true; ReachBox.Transparency = 1; ReachBox.Material = Enum.Material.SmoothPlastic; ReachBox.CastShadow = false; ReachBox.Parent = Workspace
pcall(function()
	for _, func in pairs(getgc(true)) do
		if typeof(func)=="function" then
			local n = debug.info(func,"n")
			if n=="reachcheck" or n=="touchingcheck" then pcall(hookfunction, func, newcclosure(function() return false end))
			elseif n=="IsBallBoundingHitbox" then pcall(hookfunction, func, newcclosure(function() return true end)) end
		end
	end
end)
SpoofTargetLimb = nil
local TargetLimbNames = {Head=true,HumanoidRootPart=true,LL=true,["Left Arm"]=true,["Left Leg"]=true,Legs=true,RL=true,["Right Arm"]=true,["Right Leg"]=true,Torso=true}
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
	if not checkcaller() and SpoofTargetLimb and (key=="CFrame" or key=="Position") and self:IsA("BasePart") then
		if BALL_NAMES[self.Name] then return SpoofTargetLimb[key] end
	end
	return oldIndex(self, key)
end))
RunService.RenderStepped:Connect(function()
	if not (HRP and Humanoid and Character and Character.Parent) then return end
	local ReachType = nil
	if ReachConfig.Master then
		if (Character:FindFirstChild("Shoot") or Character:FindFirstChild("Kick")) and ReachConfig.Shoot then ReachType = "Shoot"
		elseif Character:FindFirstChild("Pass") and ReachConfig.Pass then ReachType = "Pass"
		elseif Character:FindFirstChild("Long") and ReachConfig.Long then ReachType = "Long"
		elseif Character:FindFirstChild("Tackle") and ReachConfig.Tackle then ReachType = "Tackle"
		elseif Character:FindFirstChild("Dribble") and ReachConfig.Dribble then ReachType = "Dribble"
		elseif (Character:FindFirstChild("Save") or Character:FindFirstChild("Clear") or Character:FindFirstChild("GK") or Character:FindFirstChild("Keeper")) and ReachConfig.Save then ReachType = "Save" end
	end
	if ReachType == nil then
		ReachBox.Size = Vector3.new(0,0,0); ReachBox.CFrame = CFrame.new(math.huge,math.huge,math.huge)
	else
		ReachBox.Size = Vector3.new(ReachConfig.ReachX, ReachConfig.ReachY, ReachConfig.ReachZ); ReachBox.CFrame = HRP.CFrame
	end
	ReachBox.Color = P.accent; ReachBox.Transparency = ReachConfig.Visualizer and 0.8 or 1
	if not ReachType then return end
	task.spawn(function()
		local overlap = OverlapParams.new(); overlap.FilterType = Enum.RaycastFilterType.Include
		local balls = GetVEFBalls(); overlap.FilterDescendantsInstances = balls
		local touching = Workspace:GetPartsInPart(ReachBox, overlap)
		table.sort(touching, function(a,b) return (a.Position-HRP.Position).Magnitude < (b.Position-HRP.Position).Magnitude end)
		if #touching > 0 then
			local Ball = touching[1]
			if ReachType == "Save" then
				local lowest, closestLimb = math.huge, nil
				for _, limb in ipairs(Character:GetChildren()) do
					if limb:IsA("BasePart") and TargetLimbNames[limb.Name] then
						local d = (limb.Position-Ball.Position).Magnitude
						if d < lowest then lowest = d; closestLimb = limb end
					end
				end
				if closestLimb then firetouchinterest(closestLimb,Ball,0); firetouchinterest(closestLimb,Ball,1); SpoofTargetLimb = closestLimb end
			else
				for _, limb in ipairs(Character:GetChildren()) do
					if limb:IsA("BasePart") then firetouchinterest(limb,Ball,0); firetouchinterest(limb,Ball,1) end
				end
				SpoofTargetLimb = nil
			end
		end
	end)
end)
local BallPred = {Enabled=false, Threshold=18, Accuracy=12, TrailSize=0.25, HZ=0.1}
local Dump = {BallPrediction={}}
local function ClearDump()
	for _, inst in ipairs(Dump.BallPrediction) do if inst and inst.Parent then inst:Destroy() end end
	table.clear(Dump.BallPrediction)
end
local function quadraticSolver(a,b,c)
	local disc = math.sqrt((b*b)-4*a*c); local x1=(-b+disc)/(2*a); local x2=(-b-disc)/(2*a); return x2>x1 and x2 or x1
end
local function findTimeAtHeight(a,vel,h,startingH)
	local x=h-startingH; local disc=math.sqrt((vel*vel)+2*a*x); local x1=(disc-vel)/a; local x2=-(disc+vel)/a; return x2>x1 and x2 or x1
end
local function findHeightAtTime(vel,t,acc) return vel.Y*t + 0.5*-acc*(t*t) end
local function findPositionAtTime(vel,t,startingPos,acc)
	local height = findHeightAtTime(vel,t,acc); return startingPos + Vector3.new(vel.X*t, height, vel.Z*t)
end
local function findLandingPosition(Vo, startingPosition, acc, max)
	local seconds = quadraticSolver((0.5*-acc), Vo.Y, startingPosition.Y)
	local lastPosition = startingPosition
	for i=1,max do
		local t = seconds*(1/max*i); local nextPosition = findPositionAtTime(Vo,t,startingPosition,acc)
		local result = Workspace:Raycast(lastPosition, (nextPosition-lastPosition))
		if result then
			local baseHeight = result.Position.Y
			local timeAtHeight = findTimeAtHeight(-acc, Vo.Y, baseHeight, startingPosition.Y)
			return findPositionAtTime(Vo, timeAtHeight, startingPosition, acc)
		end
		lastPosition = nextPosition
	end
	local horizontalVel = Vector3.new(Vo.X,0,Vo.Z)
	return startingPosition + (horizontalVel*seconds) + Vector3.new(0, findHeightAtTime(Vo,seconds,acc), 0)
end
local function PredictBall(Ball)
	local LandingPosition = findLandingPosition(Ball.AssemblyLinearVelocity, Ball.Position, Workspace.Gravity, BallPred.Accuracy)
	local att0 = Instance.new("Attachment"); att0.WorldPosition = Ball.Position; att0.Parent = Workspace.Terrain; table.insert(Dump.BallPrediction, att0)
	local att1 = Instance.new("Attachment"); att1.WorldPosition = LandingPosition; att1.Parent = Workspace.Terrain; table.insert(Dump.BallPrediction, att1)
	local beam = Instance.new("Beam"); beam.Color = ColorSequence.new(P.accent); beam.LightEmission = 0; beam.Brightness = 1
	beam.Transparency = NumberSequence.new(0.3); beam.Attachment0 = att0; beam.Attachment1 = att1; beam.FaceCamera = true
	beam.Width0 = BallPred.TrailSize; beam.Width1 = BallPred.TrailSize; beam.Parent = Ball; table.insert(Dump.BallPrediction, beam)
end
task.spawn(function()
	while true do
		task.wait(BallPred.HZ>0 and BallPred.HZ or 0.1); ClearDump()
		if BallPred.Enabled then for _, Ball in ipairs(GetVEFBalls()) do
			if Ball.AssemblyLinearVelocity.Magnitude > BallPred.Threshold then PredictBall(Ball) end
		end end
	end
end)
RadarEnabled = false; local RadarConfig = {Size=200, MaxRange=150}
local RadarGUI; RadarFrame=nil; local RadarBlips, RadarBallBlips, RadarNameLabels, RadarLastPos = {},{},{},{}
local RadarUpdateConnection
local function CreateRadarGUI()
	if RadarGUI then RadarGUI:Destroy() end
	RadarBlips, RadarBallBlips, RadarNameLabels, RadarLastPos = {},{},{},{}
	RadarGUI = Instance.new("ScreenGui"); RadarGUI.Name = "RadarGUI"; RadarGUI.ResetOnSpawn = false; RadarGUI.Parent = LocalPlayer:WaitForChild("PlayerGui")
	RadarFrame = Instance.new("Frame"); RadarFrame.Size = UDim2.new(0,RadarConfig.Size,0,RadarConfig.Size)
	RadarFrame.Position = UDim2.new(0.88,0,0.12,0); RadarFrame.AnchorPoint = Vector2.new(0.5,0.5)
	RadarFrame.BackgroundColor3 = Color3.new(0,0,0); RadarFrame.BackgroundTransparency = 0.6; RadarFrame.BorderSizePixel = 0
	RadarFrame.ClipsDescendants = true; RadarFrame.ZIndex = 10; RadarFrame.Parent = RadarGUI
	Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(1,0)
	local ring = Instance.new("Frame"); ring.Size = UDim2.new(0.9,0,0.9,0); ring.Position = UDim2.new(0.05,0,0.05,0)
	ring.BackgroundColor3 = Color3.new(0.2,0.2,0.2); ring.BackgroundTransparency = 0.3; ring.BorderSizePixel = 1
	ring.BorderColor3 = Color3.new(0.4,0.4,0.4); ring.ZIndex = 11; ring.Parent = RadarFrame
	Instance.new("UICorner", ring).CornerRadius = UDim.new(1,0)
	local selfBlip = Instance.new("Frame"); selfBlip.Size = UDim2.new(0,10,0,10); selfBlip.AnchorPoint = Vector2.new(0.5,0.5)
	selfBlip.Position = UDim2.new(0.5,0,0.5,0); selfBlip.BackgroundColor3 = Color3.fromRGB(0,255,0)
	selfBlip.BorderSizePixel = 2; selfBlip.BorderColor3 = Color3.fromRGB(255,255,255); selfBlip.ZIndex = 15; selfBlip.Parent = RadarFrame
	Instance.new("UICorner", selfBlip).CornerRadius = UDim.new(1,0)
end
local function CreatePlayerBlip(player)
	local container = Instance.new("Frame"); container.Size = UDim2.new(0,60,0,30); container.AnchorPoint = Vector2.new(0.5,0.5)
	container.BackgroundTransparency = 1; container.ZIndex = 13; container.Parent = RadarFrame
	local b = Instance.new("Frame"); b.Size = UDim2.new(0,8,0,8); b.AnchorPoint = Vector2.new(0.5,0.5); b.Position = UDim2.new(0.5,0,0.5,-8)
	b.BorderSizePixel = 1; b.BorderColor3 = Color3.new(1,1,1); b.ZIndex = 14; b.Parent = container
	Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
	local name = Instance.new("TextLabel"); name.Text = player.Name; name.TextColor3 = Color3.new(1,1,1); name.TextSize = 10
	name.Font = Enum.Font.GothamBold; name.BackgroundTransparency = 1; name.TextStrokeColor3 = Color3.new(0,0,0)
	name.TextStrokeTransparency = 0.3; name.Size = UDim2.new(1,0,0,14); name.Position = UDim2.new(0,0,0,14); name.ZIndex = 14; name.Parent = container
	return container, b, name
end
local function CreateBallBlip()
	local container = Instance.new("Frame"); container.Size = UDim2.new(0,16,0,16); container.AnchorPoint = Vector2.new(0.5,0.5)
	container.BackgroundTransparency = 1; container.ZIndex = 12; container.Parent = RadarFrame
	local b = Instance.new("Frame"); b.Size = UDim2.new(0,4,0,4); b.AnchorPoint = Vector2.new(0.5,0.5); b.Position = UDim2.new(0.5,0,0.5,0)
	b.BackgroundColor3 = Color3.new(1,1,1); b.BackgroundTransparency = 0.2; b.BorderSizePixel = 0; b.ZIndex = 13; b.Parent = container
	Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
	return container
end
local function UpdateRadar()
	if not RadarFrame or not RadarFrame.Parent then return end
	local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); if not root then return end
	local cam = Workspace.CurrentCamera.CFrame; local angle = math.atan2(-cam.LookVector.X, -cam.LookVector.Z)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			if not RadarBlips[p] then local container,dot,name = CreatePlayerBlip(p); RadarBlips[p]=container; RadarNameLabels[p]={dot=dot,name=name} end
			local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if r then RadarLastPos[p]=r.Position end
			local target = RadarLastPos[p] or root.Position; local rel = target - root.Position
			local c,s = math.cos(angle), math.sin(angle); local x = rel.X*c - rel.Z*s; local z = rel.X*s + rel.Z*c
			local dist = Vector2.new(x,z).Magnitude; local scale = (RadarConfig.Size/2)/RadarConfig.MaxRange
			local px,pz; if dist > RadarConfig.MaxRange then local dir = Vector2.new(x,z).Unit; local edge = RadarConfig.Size/2-10; px=dir.X*edge; pz=dir.Y*edge
			else px=x*scale; pz=z*scale end
			local color = p.TeamColor and p.TeamColor.Color or Color3.new(1,1,1)
			if RadarNameLabels[p] and RadarNameLabels[p].dot then RadarNameLabels[p].dot.BackgroundColor3=color; RadarNameLabels[p].name.TextColor3=color end
			RadarBlips[p].Position = UDim2.new(0.5,px,0.5,pz)
		end
	end
	local ballIndex = 0
	for _, ball in pairs(GetVEFBalls()) do
		if ball and ball.Parent then
			ballIndex = ballIndex+1; if not RadarBallBlips[ballIndex] then RadarBallBlips[ballIndex]=CreateBallBlip() end
			local rel = ball.Position-root.Position; local c,s = math.cos(angle),math.sin(angle)
			local x = rel.X*c-rel.Z*s; local z = rel.X*s+rel.Z*c; local dist = Vector2.new(x,z).Magnitude
			local scale = (RadarConfig.Size/2)/RadarConfig.MaxRange
			local px,pz; if dist>RadarConfig.MaxRange then local dir=Vector2.new(x,z).Unit; local edge=RadarConfig.Size/2-10; px=dir.X*edge; pz=dir.Y*edge
			else px=x*scale; pz=z*scale end
			RadarBallBlips[ballIndex].Position = UDim2.new(0.5,px,0.5,pz)
		end
	end
	for i,blip in pairs(RadarBallBlips) do if i>ballIndex then blip:Destroy(); RadarBallBlips[i]=nil end end
end
local function StartRadar()
	if RadarUpdateConnection then return end; CreateRadarGUI(); RadarUpdateConnection = RunService.RenderStepped:Connect(UpdateRadar)
end
local function StopRadar()
	RadarEnabled=false; if RadarUpdateConnection then RadarUpdateConnection:Disconnect(); RadarUpdateConnection=nil end
	if RadarGUI then RadarGUI:Destroy(); RadarGUI=nil end; RadarBlips,RadarBallBlips,RadarNameLabels,RadarLastPos={},{},{},{}
end
local CharSpeed = {Enabled=false, Value=0}; InfJump=false; WalkSpeedValue=19
RunService.Heartbeat:Connect(function(dt)
	if not (HRP and Humanoid and Character and Character.Parent) then return end
	if CharSpeed.Enabled and Character.PrimaryPart then
		Character.PrimaryPart:PivotTo(Character.PrimaryPart.CFrame + Humanoid.MoveDirection*dt*CharSpeed.Value)
	end
end)
UserInputService.JumpRequest:Connect(function() if InfJump and Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
local LIGHTING_PRESETS = {
	Night = {Ambient=Color3.fromRGB(20,20,40), OutdoorAmbient=Color3.fromRGB(15,15,30), Brightness=1, ClockTime=0, FogColor=Color3.fromRGB(10,10,25), FogEnd=800},
	Sunset = {Ambient=Color3.fromRGB(80,40,20), OutdoorAmbient=Color3.fromRGB(100,50,20), Brightness=2, ClockTime=18, FogColor=Color3.fromRGB(120,60,30), FogEnd=600},
	Day = {Ambient=Color3.fromRGB(140,140,140), OutdoorAmbient=Color3.fromRGB(128,128,128), Brightness=2, ClockTime=14, FogColor=Color3.fromRGB(192,192,192), FogEnd=100000},
	Purple = {Ambient=Color3.fromRGB(60,20,90), OutdoorAmbient=Color3.fromRGB(40,10,70), Brightness=1.5, ClockTime=20, FogColor=Color3.fromRGB(50,10,80), FogEnd=700},
}
local function ApplyLighting(name)
	local preset = LIGHTING_PRESETS[name]; if not preset then return end
	pcall(function()
		Lighting.Ambient=preset.Ambient; Lighting.OutdoorAmbient=preset.OutdoorAmbient; Lighting.Brightness=preset.Brightness
		Lighting.ClockTime=preset.ClockTime; Lighting.FogColor=preset.FogColor; Lighting.FogEnd=preset.FogEnd
	end)
end
local function SetPitchColor(color)
	pcall(function()
		local pitch = Workspace:FindFirstChild("Pitch")
		if pitch then local grass = pitch:FindFirstChild("Grass"); if grass and grass:IsA("BasePart") then grass.Color=color end end
		local gameFolder = Workspace:FindFirstChild("Game")
		if gameFolder then
			local pitchM = gameFolder:FindFirstChild("Pitch")
			if pitchM then
				local field = pitchM:FindFirstChild("Field")
				if field then
					local grassContainer = field:FindFirstChild("Grass")
					if grassContainer then
						if grassContainer:IsA("BasePart") then grassContainer.Color=color
						else for _,obj in ipairs(grassContainer:GetDescendants()) do
							if obj:IsA("BasePart") and (obj.Name=="Grass" or obj.Name=="MainGrass") then obj.Color=color end
						end end
					end
				end
			end
		end
	end)
end
local function HasSaveTool()
	if not Character then return false end
	return Character:FindFirstChild("Save") or Character:FindFirstChild("Clear") or Character:FindFirstChild("GK") or Character:FindFirstChild("Keeper")
end
local function IsHoldingBall()
	if not ToolManagment then return false end
	local status = ToolManagment.HoldingBallStatus
	if type(status)=="function" then status=status() end
	return status==true
end
local function IsBallCatchable(ball)
	if not ball or not ball.Parent then return false end
	if ball:FindFirstChildWhichIsA("Motor6D") then return false end
	if ball.Anchored and ball.CanCollide then return false end
	if ToolManagment and ToolManagment.abletoreact then
		local ok, valid = pcall(ToolManagment.abletoreact, ToolManagment, nil, ball)
		if ok and not valid then return false end
	end
	return true
end
local AutoCatch = {Enabled=false, Range=4, Cooldown=1, CatchType="High Catch", LastCatchTime=0, IsCatching=false, ManualEnabled=false}
local function PerformCatch(ball)
	if not HasSaveTool() or not ToolManagment or not ball or not ball.Parent then return false end
	if AutoCatch.IsCatching then return false end
	if tick()-AutoCatch.LastCatchTime < AutoCatch.Cooldown then return false end
	if not IsBallCatchable(ball) then return false end
	if IsHoldingBall() then pcall(function() ToolManagment.dontatac(ToolManagment,false) end); task.wait(0.15) end
	local success = false
	pcall(function() success = ToolManagment.atac(ToolManagment, ball, AutoCatch.CatchType) end)
	if success then AutoCatch.LastCatchTime=tick(); AutoCatch.IsCatching=true; task.delay(0.6,function() AutoCatch.IsCatching=false end); return true end
	return false
end
task.spawn(function()
	while true do
		task.wait(0.15)
		if not AutoCatch.Enabled then continue end
		if not HasSaveTool() or not ToolManagment then continue end
		if IsHoldingBall() then continue end
		if not HRP then continue end
		local ball = GetNearestBall(HRP, AutoCatch.Range)
		if ball and IsBallCatchable(ball) then PerformCatch(ball) end
	end
end)
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode == Enum.KeyCode.Q and AutoCatch.ManualEnabled then
		if not HasSaveTool() or not ToolManagment then return end
		if IsHoldingBall() then pcall(function() ToolManagment.dontatac(ToolManagment,false) end); return end
		if not HRP then return end
		local ball = GetNearestBall(HRP, 40)
		if ball and IsBallCatchable(ball) then PerformCatch(ball) end
	end
end)
local AutoSave = {Enabled=false, Connection=nil, LastSaveTime=0, IsSaving=false}
local AUTOSAVE_CONFIG = {
	GOAL_WIDTH=38, GOAL_HEIGHT=18, PITCH_GROUND_Y=5.5,
	MIN_VELOCITY=3, COOLDOWN=0.34, MAX_PRED_TIME=3.2, GOAL_Z_GATE=60,
	CLOSE_DIST=22, LOW_Y=9.5, CLOSE_TRIGGER=0.38, CLOSE_FIRE_DIST=14,
}
local AutoSaveKeybinds = {Low_Dive=Enum.KeyCode.C, High_Dive=Enum.KeyCode.E, High_Catch=Enum.KeyCode.R, Low_Catch=Enum.KeyCode.F}
local function GetDefendedGoalZ(gkPos) if gkPos.Z>0 then return 376,1 else return -376,-1 end end
local function PredictBallAtGoal(ball, goalZ, travelDirZ)
	local pos=ball.Position; local vel=ball.AssemblyLinearVelocity
	if (travelDirZ>0 and vel.Z<=1) or (travelDirZ<0 and vel.Z>=-1) then return nil,nil end
	local dz=goalZ-pos.Z; if (travelDirZ>0 and dz<=0) or (travelDirZ<0 and dz>=0) then return nil,nil end
	local timeToGoal=dz/vel.Z
	if timeToGoal<=0 or timeToGoal>AUTOSAVE_CONFIG.MAX_PRED_TIME then return nil,nil end
	local predictedX=pos.X+(vel.X*timeToGoal); local speed=vel.Magnitude; local effectiveGravity=196.2
	if speed>50 then effectiveGravity=effectiveGravity*0.40 elseif speed>30 then effectiveGravity=effectiveGravity*0.65 end
	local predictedY=pos.Y+(vel.Y*timeToGoal)-(0.5*effectiveGravity*(timeToGoal^2))
	predictedY=math.max(predictedY, AUTOSAVE_CONFIG.PITCH_GROUND_Y)
	return Vector3.new(predictedX,predictedY,goalZ), timeToGoal
end
local function ExecuteSave(predictedPos)
	if not HRP then return end
	AutoSave.IsSaving=true; AutoSave.LastSaveTime=tick()
	local relativeTarget=HRP.CFrame:PointToObjectSpace(predictedPos); local deltaX=relativeTarget.X
	local worldY=predictedPos.Y; local distFromCenter=math.abs(deltaX)
	local isTopBins=(distFromCenter>=4.5 and worldY>=8.5)
	local isHigh=isTopBins or (worldY>=AUTOSAVE_CONFIG.LOW_Y+1.5)
	local isCenter=distFromCenter<=3.8
	local isLeft=deltaX<-3.8; local isRight=deltaX>3.8
	local dirKey=isRight and Enum.KeyCode.D or isLeft and Enum.KeyCode.A or isCenter and Enum.KeyCode.W or nil
	local saveKey=isHigh and ((isCenter and not isTopBins) and AutoSaveKeybinds.High_Catch or AutoSaveKeybinds.High_Dive) or (isCenter and AutoSaveKeybinds.Low_Catch or AutoSaveKeybinds.Low_Dive)
	task.spawn(function()
		if dirKey then VirtualInputManager:SendKeyEvent(true,dirKey,false,game) end
		VirtualInputManager:SendKeyEvent(true,saveKey,false,game)
		task.delay(0.14, function()
			VirtualInputManager:SendKeyEvent(false,saveKey,false,game)
			if dirKey then VirtualInputManager:SendKeyEvent(false,dirKey,false,game) end
		end)
	end)
	task.delay(AUTOSAVE_CONFIG.COOLDOWN, function() AutoSave.IsSaving=false end)
end
local function StartAutoSave()
	if AutoSave.Enabled then return end; AutoSave.Enabled=true
	AutoSave.Connection = RunService.RenderStepped:Connect(function()
		if not AutoSave.Enabled or AutoSave.IsSaving then return end
		if tick()-AutoSave.LastSaveTime < AUTOSAVE_CONFIG.COOLDOWN then return end
		if not HRP then return end
		local goalZ, travelDirZ = GetDefendedGoalZ(HRP.Position)
		if math.abs(HRP.Position.Z-goalZ)>AUTOSAVE_CONFIG.GOAL_Z_GATE then return end
		for _, ball in ipairs(GetVEFBalls()) do
			local speed = ball.AssemblyLinearVelocity.Magnitude
			if speed < AUTOSAVE_CONFIG.MIN_VELOCITY then continue end
			local ballDist = (ball.Position - HRP.Position).Magnitude
			local isClose = ballDist <= AUTOSAVE_CONFIG.CLOSE_DIST
			local isLowBall = ball.Position.Y <= AUTOSAVE_CONFIG.LOW_Y
			if isClose and isLowBall then
				local toBall = ball.Position - HRP.Position
				local approaching = toBall:Dot(ball.AssemblyLinearVelocity) < -1.5 or math.abs(ball.AssemblyLinearVelocity.Z) > 2.5
				if approaching and ballDist <= AUTOSAVE_CONFIG.CLOSE_FIRE_DIST then
					local side = HRP.CFrame:PointToObjectSpace(ball.Position)
					local fakePred = Vector3.new(HRP.Position.X + side.X, math.max(ball.Position.Y, AUTOSAVE_CONFIG.PITCH_GROUND_Y), HRP.Position.Z)
					ExecuteSave(fakePred)
					break
				end
			end
			local predictedGoalPos = PredictBallAtGoal(ball, goalZ, travelDirZ)
			if predictedGoalPos and math.abs(predictedGoalPos.X)<=(AUTOSAVE_CONFIG.GOAL_WIDTH/2+6) and predictedGoalPos.Y<=AUTOSAVE_CONFIG.GOAL_HEIGHT then
				local predictedGKPos, timeToGK = PredictBallAtGoal(ball, HRP.Position.Z, travelDirZ)
				if predictedGKPos and timeToGK then
					local relGK = HRP.CFrame:PointToObjectSpace(predictedGKPos)
					local reachDist = math.abs(relGK.X)
					local baseTrigger = 0.15 + (math.clamp(reachDist/16, 0, 1) * 0.14)
					if isClose and isLowBall then
						baseTrigger = math.max(baseTrigger, AUTOSAVE_CONFIG.CLOSE_TRIGGER)
					elseif isClose then
						baseTrigger = baseTrigger + 0.08
					elseif isLowBall then
						baseTrigger = baseTrigger + 0.04
					end
					if timeToGK <= baseTrigger and timeToGK >= 0.002 then
						ExecuteSave(predictedGoalPos)
						break
					end
				end
			end
		end
	end)
end
local function StopAutoSave()
	AutoSave.Enabled=false
	if AutoSave.Connection then pcall(function() AutoSave.Connection:Disconnect() end); AutoSave.Connection=nil end
	AutoSave.IsSaving=false
end
local GKHelper = {Enabled=false, Connection=nil, PredCircle=nil, InnerRing=nil, IsMoving=false}
local GK_CONFIG = {GOAL_LINE_Z=364.5, GOAL_POST_LEFT_X=-19.05, GOAL_POST_RIGHT_X=20.14, CROSSBAR_Y=19.3, GROUND_Y=5, BALL_SPEED_THRESHOLD=35, PREDICTION_RANGE_Z=130, MOVE_SPEED=50, ORIGINAL_SPEED=20, GK_BASE_Z=360}
local function CleanupGKHelper()
	if GKHelper.Connection then pcall(function() GKHelper.Connection:Disconnect() end); GKHelper.Connection=nil end
	if GKHelper.PredCircle then pcall(function() GKHelper.PredCircle:Destroy() end); GKHelper.PredCircle=nil end
	if GKHelper.InnerRing then pcall(function() GKHelper.InnerRing:Destroy() end); GKHelper.InnerRing=nil end
	GKHelper.IsMoving=false
	if Humanoid then
		Humanoid.WalkSpeed = GK_CONFIG.ORIGINAL_SPEED
		pcall(function() Humanoid:Move(Vector3.zero) end)
	end
end
local function StartGKHelper()
	if GKHelper.Enabled then return end
	CleanupGKHelper()
	local predictionCircle = Instance.new("Part"); predictionCircle.Name="GK_PredictionCircle"; predictionCircle.Anchored=true
	predictionCircle.CanCollide=false; predictionCircle.Shape=Enum.PartType.Cylinder; predictionCircle.Size=Vector3.new(0.15,5,5)
	predictionCircle.Color=Color3.fromRGB(0,255,80); predictionCircle.Material=Enum.Material.Neon; predictionCircle.Transparency=0.3
	predictionCircle.CFrame=CFrame.new(0,-100,0); predictionCircle.Parent=Workspace.Debris or Workspace; GKHelper.PredCircle=predictionCircle
	local innerRing = Instance.new("Part"); innerRing.Name="GK_InnerRing"; innerRing.Anchored=true; innerRing.CanCollide=false
	innerRing.Shape=Enum.PartType.Cylinder; innerRing.Size=Vector3.new(0.2,2.5,2.5); innerRing.Color=Color3.fromRGB(50,255,50)
	innerRing.Material=Enum.Material.Neon; innerRing.Transparency=0.1; innerRing.CFrame=CFrame.new(0,-100,0)
	innerRing.Parent=Workspace.Debris or Workspace; GKHelper.InnerRing=innerRing
	GKHelper.Enabled=true
	GKHelper.Connection = RunService.Heartbeat:Connect(function()
		if not GKHelper.Enabled then return end
		if not HRP or not Humanoid then return end
		local bestPred, bestTime = nil, math.huge
		local isPositiveGoal = HRP.Position.Z>0
		local goalLineZ = isPositiveGoal and GK_CONFIG.GOAL_LINE_Z or -GK_CONFIG.GOAL_LINE_Z
		local travelDirZ = isPositiveGoal and 1 or -1
		for _, ball in pairs(GetVEFBalls()) do
			local pos,vel = ball.Position, ball.AssemblyLinearVelocity
			if (travelDirZ>0 and vel.Z<=0) or (travelDirZ<0 and vel.Z>=0) then continue end
			if vel.Magnitude < GK_CONFIG.BALL_SPEED_THRESHOLD then continue end
			local t = (goalLineZ-pos.Z)/vel.Z; if t<=0 or t>3 then continue end
			local predX = pos.X+vel.X*t; local predY = pos.Y+vel.Y*t-0.5*Workspace.Gravity*t*t
			if predY < GK_CONFIG.GROUND_Y then predY = GK_CONFIG.GROUND_Y end
			local onTarget = predX>=GK_CONFIG.GOAL_POST_LEFT_X-4 and predX<=GK_CONFIG.GOAL_POST_RIGHT_X+4 and predY<=GK_CONFIG.CROSSBAR_Y+3
			if onTarget and t<bestTime then bestPred=Vector3.new(predX,predY,goalLineZ); bestTime=t end
		end
		if bestPred and GKHelper.PredCircle and GKHelper.InnerRing then
			GKHelper.PredCircle.CFrame = CFrame.new(bestPred)*CFrame.Angles(0,0,math.rad(90))
			GKHelper.InnerRing.CFrame = CFrame.new(bestPred)*CFrame.Angles(0,0,math.rad(90))
			local gkZ = isPositiveGoal and GK_CONFIG.GK_BASE_Z or -GK_CONFIG.GK_BASE_Z
			local gkX = math.clamp(bestPred.X, GK_CONFIG.GOAL_POST_LEFT_X+1, GK_CONFIG.GOAL_POST_RIGHT_X-1)
			Humanoid.WalkSpeed = GK_CONFIG.MOVE_SPEED; Humanoid:MoveTo(Vector3.new(gkX, HRP.Position.Y, gkZ)); GKHelper.IsMoving=true
		else
			if GKHelper.IsMoving then
				Humanoid.WalkSpeed=GK_CONFIG.ORIGINAL_SPEED
				pcall(function() Humanoid:Move(Vector3.zero) end)
				GKHelper.IsMoving=false
			end
			if GKHelper.PredCircle then GKHelper.PredCircle.CFrame=CFrame.new(0,-100,0) end
			if GKHelper.InnerRing then GKHelper.InnerRing.CFrame=CFrame.new(0,-100,0) end
		end
	end)
end
local function StopGKHelper()
	GKHelper.Enabled=false
	CleanupGKHelper()
end
local AutoConfig = {DribbleEnabled=false, DribbleKey=Enum.KeyCode.K, DribbleRadius=1.2, DribblePred=0.14, GuardEnabled=false, GuardKey=Enum.KeyCode.L, GuardStopDist=1.5, GuardPred=0.5, MossEnabled=false, MossKey=Enum.KeyCode.M, MossActivationDist=50}
local AutoCurrentBall = nil
task.spawn(function()
	while true do
		task.wait(0.4); if not HRP then continue end
		local closest, minDist = nil, math.huge
		for _, b in ipairs(GetVEFBalls()) do local d=(b.Position-HRP.Position).Magnitude; if d<minDist then minDist=d; closest=b end end
		AutoCurrentBall = closest
	end
end)
RunService.Heartbeat:Connect(function()
	if not HRP or not Humanoid then return end
	if AutoConfig.DribbleEnabled and AutoCurrentBall and AutoCurrentBall.Parent then
		local ballPos=AutoCurrentBall.Position; local vel=AutoCurrentBall.AssemblyLinearVelocity
		local lead=ballPos+Vector3.new(vel.X,0,vel.Z)*AutoConfig.DribblePred
		local dir=(HRP.Position-lead); dir=Vector3.new(dir.X,0,dir.Z); if dir.Magnitude>0.01 then dir=dir.Unit end
		local target=lead+dir*AutoConfig.DribbleRadius; Humanoid:MoveTo(Vector3.new(target.X,HRP.Position.Y,target.Z))
	end
	if AutoConfig.GuardEnabled and AutoCurrentBall and AutoCurrentBall.Parent then
		local bp=AutoCurrentBall.Position; local bv=AutoCurrentBall.AssemblyLinearVelocity
		local pred=bp+Vector3.new(bv.X,0,bv.Z)*AutoConfig.GuardPred
		local gap=(Vector3.new(pred.X,0,pred.Z)-Vector3.new(HRP.Position.X,0,HRP.Position.Z)).Magnitude
		if gap>AutoConfig.GuardStopDist then Humanoid:MoveTo(Vector3.new(pred.X,HRP.Position.Y,pred.Z)) end
	end
	if AutoConfig.MossEnabled and AutoCurrentBall and AutoCurrentBall.Parent then
		local pos=AutoCurrentBall.Position; local vel=AutoCurrentBall.AssemblyLinearVelocity
		if pos.Y>HRP.Position.Y+3 and math.abs(vel.Y)>2 then
			local t=0.6; local predX=pos.X+vel.X*t; local predZ=pos.Z+vel.Z*t
			local flat=(Vector3.new(predX,0,predZ)-Vector3.new(HRP.Position.X,0,HRP.Position.Z)).Magnitude
			if flat<AutoConfig.MossActivationDist then Humanoid:MoveTo(Vector3.new(predX,HRP.Position.Y,predZ)) end
		end
	end
end)
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode==AutoConfig.DribbleKey then AutoConfig.DribbleEnabled=not AutoConfig.DribbleEnabled; notify("Auto Dribble "..(AutoConfig.DribbleEnabled and "ON" or "OFF"), AutoConfig.DribbleEnabled and "good" or "warn")
	elseif input.KeyCode==AutoConfig.GuardKey then AutoConfig.GuardEnabled=not AutoConfig.GuardEnabled; notify("Auto Guard "..(AutoConfig.GuardEnabled and "ON" or "OFF"), AutoConfig.GuardEnabled and "good" or "warn")
	elseif input.KeyCode==AutoConfig.MossKey then AutoConfig.MossEnabled=not AutoConfig.MossEnabled; notify("Auto Moss "..(AutoConfig.MossEnabled and "ON" or "OFF"), AutoConfig.MossEnabled and "good" or "warn") end
end)
LocalPlayer.Idled:Connect(function() pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end)
local AimbotV1 = {
	Enabled = false, Assist = false, Hud = false, Strength = 0.12, MinSpeed = 25, ReleaseSpeed = 15,
	ToggleKey = Enum.KeyCode.H, AssistKey = Enum.KeyCode.V, SwapKey = Enum.KeyCode.T,
	lockedNet = nil, shotLocked = false, lockedPoint = nil, conn = nil,
	HOME = { FarLeft = Vector3.new(12, 12, -368), FarRight = Vector3.new(-11.5, 12, -368) },
	AWAY = { FarLeft = Vector3.new(-11.5, 12, 368), FarRight = Vector3.new(12, 12, 368) },
}
local function a1GetBall()
	local balls = GetVEFBalls and GetVEFBalls() or {}
	local best, bd = nil, math.huge
	local root = HRP
	for _, b in ipairs(balls) do
		if b and b.Parent then
			local d = root and (b.Position - root.Position).Magnitude or 0
			if d < bd then best, bd = b, d end
		end
	end
	return best
end
local function a1AttackNet()
	if AimbotV1.lockedNet then return AimbotV1.lockedNet end
	local team = LocalPlayer.Team
	if team then
		local n = team.Name:lower()
		if n:find("away") or n:find("blue") or n:find("guest") then AimbotV1.lockedNet = AimbotV1.HOME
		elseif n:find("home") or n:find("red") then AimbotV1.lockedNet = AimbotV1.AWAY end
	end
	if not AimbotV1.lockedNet and HRP then
		local hc = (AimbotV1.HOME.FarLeft + AimbotV1.HOME.FarRight) / 2
		local ac = (AimbotV1.AWAY.FarLeft + AimbotV1.AWAY.FarRight) / 2
		AimbotV1.lockedNet = (HRP.Position.Z < (hc.Z + ac.Z) / 2) and AimbotV1.AWAY or AimbotV1.HOME
	end
	return AimbotV1.lockedNet or AimbotV1.AWAY
end
local function a1GK(net)
	local best, md = nil, 80
	local c = (net.FarLeft + net.FarRight) / 2
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= LocalPlayer and pl.Team ~= LocalPlayer.Team then
			local h = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
			if h then
				local d = (h.Position - c).Magnitude
				if d < md then best, md = pl, d end
			end
		end
	end
	return best
end
local function StartAimbotV1()
	if AimbotV1.conn then return end
	AimbotV1.Enabled = true
	AimbotV1.conn = RunService.Heartbeat:Connect(function()
		if not AimbotV1.Enabled or not AimbotV1.Assist then return end
		local ball = a1GetBall()
		local net = a1AttackNet()
		if not ball or not net or not HRP then return end
		local vel = ball.AssemblyLinearVelocity
		local speed = Vector3.new(vel.X, 0, vel.Z).Magnitude
		local pos = ball.Position
		local nc = (net.FarLeft + net.FarRight) / 2
		local crossed = (net == AimbotV1.AWAY and pos.Z > nc.Z) or (net == AimbotV1.HOME and pos.Z < nc.Z)
		if crossed then AimbotV1.shotLocked = false; AimbotV1.lockedPoint = nil; return end
		local aim = net.FarLeft
		local gk = a1GK(net)
		local gkH = gk and gk.Character and gk.Character:FindFirstChild("HumanoidRootPart")
		if gkH then
			if (net.FarLeft - gkH.Position).Magnitude > (net.FarRight - gkH.Position).Magnitude then aim = net.FarLeft else aim = net.FarRight end
		else
			aim = (HRP.Position.X < nc.X) and net.FarRight or net.FarLeft
		end
		if speed >= AimbotV1.MinSpeed then
			if not AimbotV1.shotLocked then AimbotV1.shotLocked = true; AimbotV1.lockedPoint = aim end
		elseif speed < AimbotV1.ReleaseSpeed then
			AimbotV1.shotLocked = false; AimbotV1.lockedPoint = nil
		end
		local target = AimbotV1.shotLocked and AimbotV1.lockedPoint or aim
		if AimbotV1.shotLocked and target and speed > 0.1 then
			local dir = Vector3.new(target.X - pos.X, 0, target.Z - pos.Z)
			if dir.Magnitude > 0.1 then
				dir = dir.Unit
				local strength = math.clamp((speed / 120) * AimbotV1.Strength, 0.03, AimbotV1.Strength)
				local cur = Vector3.new(vel.X, 0, vel.Z)
				local want = dir * speed
				local blended = cur:Lerp(want, strength)
				if blended.Magnitude > 0.1 then blended = blended.Unit * speed end
				ball.AssemblyLinearVelocity = Vector3.new(blended.X, vel.Y, blended.Z)
			end
		end
	end)
end
local function StopAimbotV1()
	AimbotV1.Enabled = false; AimbotV1.Assist = false; AimbotV1.shotLocked = false
	if AimbotV1.conn then pcall(function() AimbotV1.conn:Disconnect() end); AimbotV1.conn = nil end
end
UserInputService.InputBegan:Connect(function(input, gp)
	if gp or not AimbotV1.Enabled then return end
	if input.KeyCode == AimbotV1.AssistKey then
		AimbotV1.Assist = not AimbotV1.Assist
		notify("Aimbot V1 Assist " .. (AimbotV1.Assist and "ON" or "OFF"), AimbotV1.Assist and "good" or "warn")
	elseif input.KeyCode == AimbotV1.SwapKey then
		AimbotV1.lockedNet = (AimbotV1.lockedNet == AimbotV1.HOME) and AimbotV1.AWAY or AimbotV1.HOME
		notify("Aimbot V1 target swapped", "good")
	end
end)
local AimbotV2 = {
	Enabled = false, Auto = false, Pass = false, Strength = 0.18, MinShot = 18, MaxTime = 4.5,
	conn = nil, passConn = nil, activeUntil = 0,
	HOME = { TL = Vector3.new(-15.51, 16.2, 366.80), TR = Vector3.new(16.59, 16.2, 366.80) },
	AWAY = { TL = Vector3.new(16.59, 16.2, -367.76), TR = Vector3.new(-15.51, 16.2, -367.76) },
}
local function a2Goals()
	local team = LocalPlayer.Team and LocalPlayer.Team.Name or ""
	if team:find("Away") then return AimbotV2.AWAY end
	return AimbotV2.HOME
end
local function a2PickCorner(ball, goal)
	local l, r = goal.TL, goal.TR
	local c = (l + r) / 2
	local vel = ball.AssemblyLinearVelocity
	local hv = Vector3.new(vel.X, 0, vel.Z)
	if hv.Magnitude < 1 then return l end
	local bestGK, md = nil, 90
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= LocalPlayer and pl.Team ~= LocalPlayer.Team then
			local h = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
			if h and (h.Position - c).Magnitude < md then bestGK, md = h, (h.Position - c).Magnitude end
		end
	end
	if bestGK then return ((l - bestGK.Position).Magnitude > (r - bestGK.Position).Magnitude) and l or r end
	return (ball.Position.X < c.X) and r or l
end
local function StartAimbotV2()
	if AimbotV2.conn then return end
	AimbotV2.Enabled = true
	AimbotV2.conn = RunService.Heartbeat:Connect(function()
		if not AimbotV2.Enabled or not AimbotV2.Auto then return end
		if os.clock() < AimbotV2.activeUntil then return end
		local ball = a1GetBall()
		if not ball or not HRP then return end
		local vel = ball.AssemblyLinearVelocity
		local speed = Vector3.new(vel.X, 0, vel.Z).Magnitude
		if speed < AimbotV2.MinShot then return end
		if (ball.Position - HRP.Position).Magnitude > 35 then return end
		local goal = a2Goals()
		local target = a2PickCorner(ball, goal)
		local dir = Vector3.new(target.X - ball.Position.X, 0, target.Z - ball.Position.Z)
		if dir.Magnitude < 1 then return end
		dir = dir.Unit
		local strength = math.clamp(AimbotV2.Strength, 0.05, 0.35)
		local cur = Vector3.new(vel.X, 0, vel.Z)
		local want = dir * speed
		local blend = cur:Lerp(want, strength)
		if blend.Magnitude > 0.1 then blend = blend.Unit * speed end
		ball.AssemblyLinearVelocity = Vector3.new(blend.X, vel.Y, blend.Z)
	end)
	if AimbotV2.passConn then pcall(function() AimbotV2.passConn:Disconnect() end) end
	local prevSpeeds = {}
	AimbotV2.passConn = RunService.Heartbeat:Connect(function()
		if not AimbotV2.Enabled or not AimbotV2.Pass or not HRP then return end
		local balls = GetVEFBalls and GetVEFBalls() or {}
		for _, ball in ipairs(balls) do
			if ball and ball.Parent then
				local sp = ball.AssemblyLinearVelocity.Magnitude
				local before = prevSpeeds[ball] or 0
				prevSpeeds[ball] = sp
				if sp - before > 10 and sp > 22 and (ball.Position - HRP.Position).Magnitude < 18 then
					local flat = Vector3.new(ball.AssemblyLinearVelocity.X, 0, ball.AssemblyLinearVelocity.Z)
					if flat.Magnitude >= 12 then
						local best, bestAng = nil, 28
						for _, pl in ipairs(Players:GetPlayers()) do
							if pl ~= LocalPlayer and pl.Team == LocalPlayer.Team then
								local h = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
								if h then
									local to = Vector3.new(h.Position.X - ball.Position.X, 0, h.Position.Z - ball.Position.Z)
									if to.Magnitude > 12 and to.Magnitude < 120 then
										local ang = math.deg(math.acos(math.clamp(to.Unit:Dot(flat.Unit), -1, 1)))
										if ang < bestAng then best, bestAng = h, ang end
									end
								end
							end
						end
						if best then
							local to = Vector3.new(best.Position.X - ball.Position.X, 0, best.Position.Z - ball.Position.Z)
							if to.Magnitude > 1 then
								local dir = to.Unit
								local v = ball.AssemblyLinearVelocity
								local hs = Vector3.new(v.X, 0, v.Z).Magnitude
								ball.AssemblyLinearVelocity = Vector3.new(dir.X * hs, v.Y, dir.Z * hs)
							end
						end
					end
				end
			end
		end
	end)
end
local function StopAimbotV2()
	AimbotV2.Enabled = false; AimbotV2.Auto = false; AimbotV2.Pass = false
	if AimbotV2.conn then pcall(function() AimbotV2.conn:Disconnect() end); AimbotV2.conn = nil end
	if AimbotV2.passConn then pcall(function() AimbotV2.passConn:Disconnect() end); AimbotV2.passConn = nil end
end
UserInputService.InputBegan:Connect(function(input, gp)
	if gp or not AimbotV2.Enabled then return end
	if input.KeyCode == Enum.KeyCode.J then
		AimbotV2.Auto = not AimbotV2.Auto
		notify("Aimbot V2 Auto " .. (AimbotV2.Auto and "ON" or "OFF"), AimbotV2.Auto and "good" or "warn")
	elseif input.KeyCode == Enum.KeyCode.K then
		AimbotV2.Pass = not AimbotV2.Pass
		notify("Aimbot V2 Pass " .. (AimbotV2.Pass and "ON" or "OFF"), AimbotV2.Pass and "good" or "warn")
	end
end)
local GKV2 = {
	Enabled = false, conn = nil, lastSave = 0, saving = false,
	GOAL_WIDTH = 42, GOAL_HEIGHT = 19, GROUND_Y = 5.5, SPLIT = 5.2, TRIGGER = 0.65,
	COOLDOWN = 0.80, MIN_SPEED = 6, MAX_DIST = 115, JUMP_DELAY = 0.085, HOLD = 0.30, MAGNET_RANGE = 5,
	Keys = { LowDive = Enum.KeyCode.C, HighDive = Enum.KeyCode.E, HighCatch = Enum.KeyCode.R, LowCatch = Enum.KeyCode.F },
}
local function gk2GoalZ(hrpZ)
	local pitch = workspace:FindFirstChild("Pitch")
	if pitch and pitch:FindFirstChild("GLT") then
		local h = pitch.GLT:FindFirstChild("HGLT")
		local a = pitch.GLT:FindFirstChild("AGLT")
		if h and a then
			if hrpZ > 0 then return a.Position.Z, 1 else return h.Position.Z, -1 end
		end
	end
	return (hrpZ > 0) and 376 or -376, (hrpZ > 0) and 1 or -1
end
local function gk2Predict(ball, targetZ, dirZ)
	local pos, vel = ball.Position, ball.AssemblyLinearVelocity
	if (dirZ > 0 and vel.Z <= 1.5) or (dirZ < 0 and vel.Z >= -1.5) then return nil, nil end
	local dz = targetZ - pos.Z
	if (dirZ > 0 and dz <= 0) or (dirZ < 0 and dz >= 0) then return nil, nil end
	local t = dz / vel.Z
	if t <= 0 or t > 2.5 then return nil, nil end
	local g = (vel.Magnitude > 60) and 24 or 38
	local py = pos.Y + vel.Y * t - 0.5 * g * t * t
	py = math.max(py, GKV2.GROUND_Y)
	return Vector3.new(pos.X + vel.X * t, py, targetZ), t
end
local function gk2Magnet(ball, isCatch, ttg, goalZ)
	task.spawn(function()
		task.wait(math.clamp(ttg * 0.25, 0.04, 0.12))
		local t0 = os.clock()
		local fire = firetouchinterest or (syn and syn.firetouchinterest)
		local range = GKV2.MAGNET_RANGE or 5
		while os.clock() - t0 < 0.55 do
			if not ball or not ball.Parent or not Character or not HRP then break end
			local limb = Character:FindFirstChild("RightHand") or Character:FindFirstChild("LeftHand") or Character:FindFirstChild("Right Arm") or Character:FindFirstChild("Torso") or HRP
			if limb then
				local dist = (limb.Position - ball.Position).Magnitude
				if dist <= range then
					if fire then pcall(fire, ball, limb, 0); pcall(fire, ball, limb, 1) end
					local contact = limb.Position + limb.CFrame.LookVector * 0.4
					ball.CFrame = CFrame.new(contact)
					if isCatch then ball.AssemblyLinearVelocity = Vector3.zero
					else ball.AssemblyLinearVelocity = ((contact - HRP.Position).Unit + Vector3.new(0, 0.25, 0)) * 18 end
					break
				end
			end
			RunService.Heartbeat:Wait()
		end
	end)
end
local function gk2Execute(pred, ball, ttg, goalZ, dirZ)
	if not HRP or not Humanoid then return end
	GKV2.saving = true; GKV2.lastSave = os.clock()
	HRP.CFrame = CFrame.lookAt(HRP.Position, HRP.Position + Vector3.new(0, 0, -dirZ))
	local rel = HRP.CFrame:PointToObjectSpace(pred)
	local isHigh = (pred.Y - GKV2.GROUND_Y) >= GKV2.SPLIT
	local isCenter = math.abs(rel.X) <= 2.8
	local dirKey = (rel.X > 2.8) and Enum.KeyCode.D or ((rel.X < -2.8) and Enum.KeyCode.A or Enum.KeyCode.W)
	local saveKey = isHigh and (isCenter and GKV2.Keys.HighCatch or GKV2.Keys.HighDive) or (isCenter and GKV2.Keys.LowCatch or GKV2.Keys.LowDive)
	local isCatch = isCenter and not isHigh
	task.spawn(function()
		if isHigh then
			Humanoid.Jump = true
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			task.wait(GKV2.JUMP_DELAY)
		end
		VirtualInputManager:SendKeyEvent(true, dirKey, false, game)
		VirtualInputManager:SendKeyEvent(true, saveKey, false, game)
		if ball then gk2Magnet(ball, isCatch, ttg, goalZ) end
		task.delay(GKV2.HOLD, function()
			VirtualInputManager:SendKeyEvent(false, saveKey, false, game)
			VirtualInputManager:SendKeyEvent(false, dirKey, false, game)
			if isHigh then VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end
		end)
	end)
	task.delay(GKV2.COOLDOWN, function() GKV2.saving = false end)
end
local function StartGKV2()
	if GKV2.conn then return end
	GKV2.Enabled = true
	local step = RunService.RenderStepped
	GKV2.conn = step:Connect(function()
		if not GKV2.Enabled or GKV2.saving then return end
		if os.clock() - GKV2.lastSave < GKV2.COOLDOWN then return end
		if not HRP then return end
		local goalZ, dirZ = gk2GoalZ(HRP.Position.Z)
		if math.abs(HRP.Position.Z - goalZ) > 30 then return end
		for _, ball in ipairs(GetVEFBalls and GetVEFBalls() or {}) do
			local vel = ball.AssemblyLinearVelocity
			if vel.Magnitude >= GKV2.MIN_SPEED and (HRP.Position - ball.Position).Magnitude <= GKV2.MAX_DIST then
				local pred, t = gk2Predict(ball, goalZ, dirZ)
				if pred and math.abs(pred.X) <= GKV2.GOAL_WIDTH / 2 + 4 and pred.Y <= GKV2.GOAL_HEIGHT then
					if t and t <= GKV2.TRIGGER and t >= 0.005 then
						gk2Execute(pred, ball, t, goalZ, dirZ)
						break
					end
				end
			end
		end
	end)
end
local function StopGKV2()
	GKV2.Enabled = false
	if GKV2.conn then pcall(function() GKV2.conn:Disconnect() end); GKV2.conn = nil end
end
local MossV2 = {
	Enabled = false, Magnet = true, Header = true, AutoShoot = true, BallTP = true,
	magnetRange = 14, airRange = 22, smooth = 0.35, shotCooldown = 0.60, headerDelay = 0.20,
	headerPower = 58, headerUp = 18, tpDist = 50, exemptUntil = 0, loop = nil, auto = nil,
	ToggleKey = Enum.KeyCode.T, TPKey = Enum.KeyCode.V,
}
local function mossBall()
	local best, bd = nil, math.huge
	if not HRP then return nil, math.huge end
	for _, b in ipairs(GetVEFBalls and GetVEFBalls() or {}) do
		if b and b.Parent then
			local d = (b.Position - HRP.Position).Magnitude
			if d < bd then best, bd = b, d end
		end
	end
	return best, bd
end
local function mossOwn(ball) pcall(function() ball:SetNetworkOwner(LocalPlayer) end) end
local function mossMagnetTick()
	if not MossV2.Enabled or not MossV2.Magnet then return end
	if tick() < MossV2.exemptUntil then return end
	local head = Character and Character:FindFirstChild("Head")
	if not HRP then return end
	local ball, dist = mossBall()
	if not ball then return end
	local air = (ball.Position.Y - HRP.Position.Y) > 1.8 or ball.AssemblyLinearVelocity.Y > 4
	if dist > (air and MossV2.airRange or MossV2.magnetRange) then return end
	mossOwn(ball)
	local cam = workspace.CurrentCamera
	local fwd = (cam and cam.CFrame.LookVector) or HRP.CFrame.LookVector
	local target = (air and head) and (head.Position + Vector3.new(0, 1.1, 0)) or (HRP.Position + Vector3.new(0, -0.6, 0) + fwd * 1.8)
	local cur = ball.AssemblyLinearVelocity
	local want = (target - ball.Position) * (air and 28 or 24)
	ball.AssemblyLinearVelocity = cur:Lerp(want, MossV2.smooth)
end
local function mossTP()
	if not MossV2.Enabled or not MossV2.BallTP or not HRP then return end
	if tick() < MossV2.exemptUntil then return end
	local ball, dist = mossBall()
	if not ball or dist > MossV2.tpDist then return end
	mossOwn(ball)
	local cam = workspace.CurrentCamera
	local fwd = (cam and cam.CFrame.LookVector) or HRP.CFrame.LookVector
	local target = HRP.Position + Vector3.new(0, -0.6, 0) + fwd * 1.8
	task.spawn(function()
		for i = 1, 8 do
			if not ball.Parent then break end
			ball.CFrame = ball.CFrame:Lerp(CFrame.new(target), 0.25)
			ball.AssemblyLinearVelocity = (target - ball.Position) * 12
			task.wait(0.015)
		end
	end)
end
local function mossShoot()
	if not MossV2.Enabled then return end
	local tool = Character and Character:FindFirstChildOfClass("Tool")
	if not tool then return end
	if tick() >= MossV2.exemptUntil then mossMagnetTick() end
	pcall(function() tool:Activate() end)
	MossV2.exemptUntil = tick() + MossV2.shotCooldown
	for i = 1, 4 do
		task.delay(i * 0.015, function()
			local t = Character and Character:FindFirstChildOfClass("Tool")
			if t then pcall(function() t:Activate() end) end
		end)
	end
end
local function StartMossV2()
	if MossV2.loop then return end
	MossV2.Enabled = true
	MossV2.loop = task.spawn(function()
		while MossV2.Enabled do pcall(mossMagnetTick); task.wait(0.016) end
		MossV2.loop = nil
	end)
	MossV2.auto = task.spawn(function()
		while MossV2.Enabled do
			task.wait(0.04)
			if MossV2.AutoShoot and tick() >= MossV2.exemptUntil then
				local tool = Character and Character:FindFirstChildOfClass("Tool")
				if tool then
					local ball, dist = mossBall()
					if ball and dist <= 12 then mossShoot() end
				end
			end
		end
		MossV2.auto = nil
	end)
end
local function StopMossV2()
	MossV2.Enabled = false; MossV2.loop = nil; MossV2.auto = nil
end
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if not MossV2.Enabled then return end
	if input.KeyCode == MossV2.TPKey then mossTP(); return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Q then mossShoot() end
end)
UserInputService.JumpRequest:Connect(function()
	if not MossV2.Enabled or not MossV2.Header or not HRP then return end
	local head = Character and Character:FindFirstChild("Head")
	if not head then return end
	local ball, dist = mossBall()
	if not ball or dist > MossV2.airRange then return end
	local t0 = tick()
	task.spawn(function()
		while tick() - t0 < MossV2.headerDelay and MossV2.Enabled do
			mossOwn(ball)
			local target = head.Position + Vector3.new(0, 1.1, 0)
			local cur = ball.AssemblyLinearVelocity
			local want = (target - ball.Position) * 28
			ball.AssemblyLinearVelocity = cur:Lerp(want, 0.45)
			task.wait(0.015)
		end
		if MossV2.Enabled then
			MossV2.exemptUntil = tick() + 0.85
			mossOwn(ball)
			local cam = workspace.CurrentCamera
			local look = (cam and cam.CFrame.LookVector) or HRP.CFrame.LookVector
			local dir = Vector3.new(look.X, 0, look.Z).Unit * MossV2.headerPower + Vector3.new(0, MossV2.headerUp, 0)
			ball.CFrame = CFrame.new(head.Position + Vector3.new(0, 1.1, 0))
			ball.AssemblyLinearVelocity = dir
		end
	end)
end)
local NoCooldown = {Enabled=false, conn=nil}
local function NoCooldownHookTM()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then return end
	local tmModule = backpack:FindFirstChild("ToolManagment")
	if tmModule then
		local ok, tm = pcall(require, tmModule)
		if ok and tm then
			tm.GetUsing = function()
				if tm.GetWindStatus and tm.GetWindStatus() then return true end
				return false
			end
		end
	end
	local rsModule = backpack:FindFirstChild("RagdollSetup")
	if rsModule then
		local ok, rs = pcall(require, rsModule)
		if ok and rs then rs.Ragdoll = function() end end
	end
end
local function StartNoCooldown()
	if NoCooldown.conn then return end
	NoCooldown.Enabled = true
	NoCooldownHookTM()
	NoCooldown.conn = RunService.Heartbeat:Connect(function()
		if not NoCooldown.Enabled then return end
		local character = LocalPlayer.Character
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		local tm = nil
		if backpack and backpack:FindFirstChild("ToolManagment") then
			pcall(function() tm = require(backpack.ToolManagment) end)
		end
		local isWinding = false
		if tm and tm.GetWindStatus then isWinding = tm.GetWindStatus() end
		if not isWinding and character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				if humanoid.PlatformStand then humanoid.PlatformStand = false end
				if humanoid.WalkSpeed == 0 then humanoid.WalkSpeed = 19 end
			end
		end
		if not isWinding then
			for _, container in ipairs({backpack, character}) do
				if container then
					for _, tool in ipairs(container:GetChildren()) do
						if tool:IsA("Tool") then
							for _, scr in ipairs(tool:GetChildren()) do
								if scr:IsA("LocalScript") then
									local ok, env = pcall(getsenv, scr)
									if ok and env and env.Using == true then env.Using = false end
								end
							end
						end
					end
				end
			end
		end
	end)
end
local function StopNoCooldown()
	NoCooldown.Enabled = false
	if NoCooldown.conn then pcall(function() NoCooldown.conn:Disconnect() end); NoCooldown.conn = nil end
end
LocalPlayer.CharacterAdded:Connect(function()
	if NoCooldown.Enabled then task.wait(0.5); NoCooldownHookTM() end
end)
local BallMagnet = {
	Enabled = false, Continuous = false, TackleKey = Enum.KeyCode.C, MagnetKey = Enum.KeyCode.V,
	AutoEquip = true, Distance = 2.0, HeightOffset = 1.0, ZeroVelocity = true, inputConn = nil, loopConn = nil,
}
local function BallMagnetGetBall()
	local pitch = workspace:FindFirstChild("Pitch")
	if pitch then
		local balls = pitch:FindFirstChild("Balls")
		if balls then
			local vef = balls:FindFirstChild("VEF")
			if vef and vef:IsA("BasePart") then return vef end
		end
	end
	for _, v in ipairs(workspace:GetDescendants()) do
		if v.Name == "VEF" and v:IsA("BasePart") then return v end
	end
	return nil
end
local function BallMagnetPull()
	if not HRP or not Character or not Humanoid then return false end
	local rl = Character:FindFirstChild("RL") or Character:FindFirstChild("Right Leg") or Character:FindFirstChild("RightFoot")
	local ball = BallMagnetGetBall()
	if not ball or not rl then return false end
	local mf = ReplicatedStorage:FindFirstChild("Event") and ReplicatedStorage.Event:FindFirstChild("MainFunction")
	if mf then pcall(function() mf:InvokeServer("Ownership", ball, ball.Position, 0, 25) end) end
	local targetPos = HRP.Position + (HRP.CFrame.LookVector * BallMagnet.Distance) - Vector3.new(0, BallMagnet.HeightOffset, 0)
	ball.CFrame = CFrame.new(targetPos)
	if BallMagnet.ZeroVelocity then
		ball.AssemblyLinearVelocity = Vector3.zero
		ball.AssemblyAngularVelocity = Vector3.zero
	end
	local fire = firetouchinterest or (syn and syn.firetouchinterest)
	if fire then pcall(fire, rl, ball, 0); task.wait(); pcall(fire, rl, ball, 1) end
	return true
end
local function BallMagnetOnTackle()
	if not Humanoid then return end
	if BallMagnet.AutoEquip and not Character:FindFirstChild("Tackle") then
		local tackle = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Tackle")
		if tackle then Humanoid:EquipTool(tackle); task.wait(0.02) end
	end
	BallMagnetPull()
end
local function StartBallMagnet()
	if BallMagnet.inputConn then return end
	BallMagnet.Enabled = true
	BallMagnet.inputConn = UserInputService.InputBegan:Connect(function(input, gp)
		if gp or not BallMagnet.Enabled then return end
		if input.KeyCode == BallMagnet.TackleKey then BallMagnetOnTackle()
		elseif input.KeyCode == BallMagnet.MagnetKey then
			BallMagnet.Continuous = not BallMagnet.Continuous
			notify("Ball Magnet " .. (BallMagnet.Continuous and "HOLD ON" or "HOLD OFF"), BallMagnet.Continuous and "good" or "warn")
		end
	end)
	BallMagnet.loopConn = RunService.Heartbeat:Connect(function()
		if BallMagnet.Enabled and BallMagnet.Continuous then BallMagnetPull() end
	end)
end
local function StopBallMagnet()
	BallMagnet.Enabled = false; BallMagnet.Continuous = false
	if BallMagnet.inputConn then pcall(function() BallMagnet.inputConn:Disconnect() end); BallMagnet.inputConn = nil end
	if BallMagnet.loopConn then pcall(function() BallMagnet.loopConn:Disconnect() end); BallMagnet.loopConn = nil end
end
local PowerShot = {
	Enabled=false, Multiplier=1.5, MaxVel=300, SwapDelayMs=500, LastToolEquip=0, LastFire=0,
	Moves={Shoot=true,Kick=true,Volley=false,Header=false},
}
local function TrackPowerShotTool(char)
	if not char then return end
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then PowerShot.LastToolEquip = tick() end
	end)
end
if Character then TrackPowerShotTool(Character) end
LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.2); TrackPowerShotTool(c) end)
local powerShotFallbackConn
local function StartPowerShotWatch()
	if powerShotFallbackConn then return end
	powerShotFallbackConn = RunService.Heartbeat:Connect(function()
		if not PowerShot.Enabled or not HRP then return end
		local tool = Character and Character:FindFirstChildOfClass("Tool")
		if not tool then return end
		local name = tool.Name
		if not (PowerShot.Moves[name] or (name=="Kick" and PowerShot.Moves.Shoot)) then return end
		if (tick()-PowerShot.LastToolEquip)*1000 < PowerShot.SwapDelayMs then return end
		if tick()-PowerShot.LastFire < 0.2 then return end
		for _, ball in ipairs(GetVEFBalls()) do
			if (ball.Position-HRP.Position).Magnitude > 25 then continue end
			local vel = ball.AssemblyLinearVelocity
			local speed = Vector3.new(vel.X,0,vel.Z).Magnitude
			if speed < 25 then continue end
			local mult, maxVel = PowerShot.Multiplier, PowerShot.MaxVel
			local newX, newZ = vel.X*mult, vel.Z*mult
			local horiz = math.sqrt(newX*newX+newZ*newZ)
			if horiz > maxVel then local s=maxVel/horiz; newX,newZ=newX*s,newZ*s end
			ball.AssemblyLinearVelocity = Vector3.new(newX, vel.Y, newZ)
			PowerShot.LastFire = tick()
			break
		end
	end)
end
local function StopPowerShotWatch()
	if powerShotFallbackConn then pcall(function() powerShotFallbackConn:Disconnect() end); powerShotFallbackConn=nil end
end
	FE.ReachConfig = ReachConfig
	FE.ReachBox = ReachBox
	FE.BallPred = BallPred
	FE.ClearDump = ClearDump
	FE.RadarConfig = RadarConfig
	FE.StartRadar = StartRadar
	FE.StopRadar = StopRadar
	FE.CharSpeed = CharSpeed
	FE.AutoCatch = AutoCatch
	FE.StartAutoSave = StartAutoSave
	FE.StopAutoSave = StopAutoSave
	FE.AutoSave = AutoSave
	FE.GKHelper = GKHelper
	FE.StartGKHelper = StartGKHelper
	FE.StopGKHelper = StopGKHelper
	FE.AutoConfig = AutoConfig
	FE.AimbotV1 = AimbotV1
	FE.StartAimbotV1 = StartAimbotV1
	FE.StopAimbotV1 = StopAimbotV1
	FE.AimbotV2 = AimbotV2
	FE.StartAimbotV2 = StartAimbotV2
	FE.StopAimbotV2 = StopAimbotV2
	FE.GKV2 = GKV2
	FE.StartGKV2 = StartGKV2
	FE.StopGKV2 = StopGKV2
	FE.MossV2 = MossV2
	FE.StartMossV2 = StartMossV2
	FE.StopMossV2 = StopMossV2
	FE.PowerShot = PowerShot
	FE.StartPowerShotWatch = StartPowerShotWatch
	FE.StopPowerShotWatch = StopPowerShotWatch
end)()
local ReachConfig = FE.ReachConfig
local ReachBox = FE.ReachBox
local BallPred = FE.BallPred
local ClearDump = FE.ClearDump
local RadarConfig = FE.RadarConfig
local StartRadar = FE.StartRadar
local StopRadar = FE.StopRadar
local CharSpeed = FE.CharSpeed
local AutoCatch = FE.AutoCatch
local StartAutoSave = FE.StartAutoSave
local StopAutoSave = FE.StopAutoSave
local AutoSave = FE.AutoSave
local GKHelper = FE.GKHelper
local StartGKHelper = FE.StartGKHelper
local StopGKHelper = FE.StopGKHelper
local AutoConfig = FE.AutoConfig
local AimbotV1 = FE.AimbotV1
local StartAimbotV1 = FE.StartAimbotV1
local StopAimbotV1 = FE.StopAimbotV1
local AimbotV2 = FE.AimbotV2
local StartAimbotV2 = FE.StartAimbotV2
local StopAimbotV2 = FE.StopAimbotV2
local GKV2 = FE.GKV2
local StartGKV2 = FE.StartGKV2
local StopGKV2 = FE.StopGKV2
local MossV2 = FE.MossV2
local StartMossV2 = FE.StartMossV2
local StopMossV2 = FE.StopMossV2
local PowerShot = FE.PowerShot
local StartPowerShotWatch = FE.StartPowerShotWatch
local StopPowerShotWatch = FE.StopPowerShotWatch
local SkyboxCfg = { Enabled = false, Current = "Default", OriginalSky = nil, OriginalSkyParent = nil }
pcall(function()
	local sky = Lighting:FindFirstChildOfClass("Sky")
	if sky then SkyboxCfg.OriginalSky = sky; SkyboxCfg.OriginalSkyParent = sky.Parent end
end)
local SKYBOX_PRESETS = {
	["Default"] = nil,
	["Space"] = { SkyboxBk="rbxassetid://159454299", SkyboxDn="rbxassetid://159454296", SkyboxFt="rbxassetid://159454293", SkyboxLf="rbxassetid://159454286", SkyboxRt="rbxassetid://159454300", SkyboxUp="rbxassetid://159454288", StarCount=5000 },
	["Nebula"] = { SkyboxBk="rbxassetid://159454299", SkyboxDn="rbxassetid://159454296", SkyboxFt="rbxassetid://159454293", SkyboxLf="rbxassetid://159454286", SkyboxRt="rbxassetid://159454300", SkyboxUp="rbxassetid://159454288", StarCount=8000 },
	["Galaxy"] = { SkyboxBk="rbxassetid://159454299", SkyboxDn="rbxassetid://159454296", SkyboxFt="rbxassetid://159454293", SkyboxLf="rbxassetid://159454286", SkyboxRt="rbxassetid://159454300", SkyboxUp="rbxassetid://159454288", StarCount=12000 },
	["Deep Space"] = { SkyboxBk="rbxassetid://159454299", SkyboxDn="rbxassetid://159454296", SkyboxFt="rbxassetid://159454293", SkyboxLf="rbxassetid://159454286", SkyboxRt="rbxassetid://159454300", SkyboxUp="rbxassetid://159454288", StarCount=20000 },
	["Night Sky"] = { SkyboxBk="rbxassetid://159454299", SkyboxDn="rbxassetid://159454296", SkyboxFt="rbxassetid://159454293", SkyboxLf="rbxassetid://159454286", SkyboxRt="rbxassetid://159454300", SkyboxUp="rbxassetid://159454288", StarCount=3000 },
	["Sunset"] = { SkyboxBk="rbxassetid://4581982114", SkyboxDn="rbxassetid://4581982271", SkyboxFt="rbxassetid://4581982425", SkyboxLf="rbxassetid://4581982560", SkyboxRt="rbxassetid://4581982687", SkyboxUp="rbxassetid://4581982817", StarCount=0 },
	["Cloudy"] = { SkyboxBk="rbxassetid://5705570148", SkyboxDn="rbxassetid://5705570242", SkyboxFt="rbxassetid://5705570342", SkyboxLf="rbxassetid://5705570451", SkyboxRt="rbxassetid://5705570548", SkyboxUp="rbxassetid://5705570630", StarCount=0 },
}
local SKY_NAMES = {"Default","Space","Nebula","Galaxy","Deep Space","Night Sky","Sunset","Cloudy"}
local function RemoveCustomSky()
	pcall(function()
		local existing = Lighting:FindFirstChild("TempoSoccer_Sky")
		if existing then existing:Destroy() end
	end)
end
local function ApplySkybox(name)
	pcall(function()
		local preset = SKYBOX_PRESETS[name]
		RemoveCustomSky()
		if preset == nil then
			if SkyboxCfg.OriginalSky then SkyboxCfg.OriginalSky.Parent = SkyboxCfg.OriginalSkyParent or Lighting end
			return
		end
		if SkyboxCfg.OriginalSky then SkyboxCfg.OriginalSky.Parent = nil end
		local sky = Instance.new("Sky")
		sky.Name = "TempoSoccer_Sky"
		for k,v in pairs(preset) do pcall(function() sky[k]=v end) end
		sky.Parent = Lighting
	end)
end
local TimeOfDayCfg = { Enabled=false, Value=14 }
local VisualFX = { Current = "Default", Saved = nil }
local function CaptureLighting()
	local s = {}
	pcall(function()
		s.Ambient = Lighting.Ambient; s.OutdoorAmbient = Lighting.OutdoorAmbient
		s.Brightness = Lighting.Brightness; s.ClockTime = Lighting.ClockTime
		s.FogColor = Lighting.FogColor; s.FogEnd = Lighting.FogEnd; s.FogStart = Lighting.FogStart
		s.ExposureCompensation = Lighting.ExposureCompensation; s.GlobalShadows = Lighting.GlobalShadows
	end)
	return s
end
if not VisualFX.Saved then VisualFX.Saved = CaptureLighting() end
local function ClearFX()
	for _, n in ipairs({"TempoSoccer_CC","TempoSoccer_Bloom","TempoSoccer_Rays","TempoSoccer_Blur","TempoSoccer_Atmo"}) do
		pcall(function() local o=Lighting:FindFirstChild(n); if o then o:Destroy() end end)
	end
end
local function Ensure(class, name)
	local o = Lighting:FindFirstChild(name)
	if o and o.ClassName == class then return o end
	if o then o:Destroy() end
	o = Instance.new(class); o.Name = name; o.Parent = Lighting
	return o
end
local VISUAL_PRESETS = {
	["Default"] = function()
		ClearFX()
		local s = VisualFX.Saved
		if s then
			pcall(function()
				Lighting.Ambient=s.Ambient; Lighting.OutdoorAmbient=s.OutdoorAmbient
				Lighting.Brightness=s.Brightness; Lighting.FogColor=s.FogColor
				Lighting.FogEnd=s.FogEnd; Lighting.FogStart=s.FogStart
				Lighting.ExposureCompensation=s.ExposureCompensation; Lighting.GlobalShadows=s.GlobalShadows
			end)
		end
	end,
	["Dark"] = function()
		ClearFX()
		Lighting.Ambient = Color3.fromRGB(15,15,22); Lighting.OutdoorAmbient = Color3.fromRGB(25,25,35)
		Lighting.Brightness = 0.6; Lighting.ExposureCompensation = -0.4
		Lighting.FogColor = Color3.fromRGB(10,10,18); Lighting.FogStart = 40; Lighting.FogEnd = 400
		local cc = Ensure("ColorCorrectionEffect","TempoSoccer_CC")
		cc.Brightness = -0.05; cc.Contrast = 0.25; cc.Saturation = -0.15; cc.TintColor = Color3.fromRGB(180,190,220)
	end,
	["Light"] = function()
		ClearFX()
		Lighting.Ambient = Color3.fromRGB(180,180,190); Lighting.OutdoorAmbient = Color3.fromRGB(200,200,210)
		Lighting.Brightness = 3; Lighting.ExposureCompensation = 0.35; Lighting.FogStart = 0; Lighting.FogEnd = 100000
		local cc = Ensure("ColorCorrectionEffect","TempoSoccer_CC")
		cc.Brightness = 0.08; cc.Contrast = 0.1; cc.Saturation = 0.05; cc.TintColor = Color3.fromRGB(255,255,255)
		local bl = Ensure("BloomEffect","TempoSoccer_Bloom"); bl.Intensity = 0.4; bl.Size = 24; bl.Threshold = 1.2
	end,
	["Abundance"] = function()
		ClearFX()
		Lighting.Ambient = Color3.fromRGB(90,70,120); Lighting.OutdoorAmbient = Color3.fromRGB(110,90,140)
		Lighting.Brightness = 2.2; Lighting.ExposureCompensation = 0.2
		Lighting.FogColor = Color3.fromRGB(80,50,120); Lighting.FogStart = 60; Lighting.FogEnd = 600
		local cc = Ensure("ColorCorrectionEffect","TempoSoccer_CC")
		cc.Brightness = 0.05; cc.Contrast = 0.2; cc.Saturation = 0.35; cc.TintColor = Color3.fromRGB(230,200,255)
		local bl = Ensure("BloomEffect","TempoSoccer_Bloom"); bl.Intensity = 1.1; bl.Size = 40; bl.Threshold = 0.85
		local rays = Ensure("SunRaysEffect","TempoSoccer_Rays"); rays.Intensity = 0.15; rays.Spread = 0.6
	end,
	["Night"] = function()
		ClearFX()
		Lighting.Ambient = Color3.fromRGB(20,24,40); Lighting.OutdoorAmbient = Color3.fromRGB(30,35,55)
		Lighting.Brightness = 0.8; Lighting.ClockTime = 0; Lighting.ExposureCompensation = -0.2
		Lighting.FogColor = Color3.fromRGB(15,18,35); Lighting.FogStart = 30; Lighting.FogEnd = 350
		local cc = Ensure("ColorCorrectionEffect","TempoSoccer_CC")
		cc.Brightness = -0.02; cc.Contrast = 0.2; cc.Saturation = -0.05; cc.TintColor = Color3.fromRGB(160,175,255)
	end,
}
local VISUAL_NAMES = {"Default","Dark","Light","Abundance","Night"}
local function ApplyVisual(name)
	VisualFX.Current = name
	local fn = VISUAL_PRESETS[name]
	if fn then pcall(fn) end
end
local TeekUI = assert(loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))(), "TempoUI failed")
local TempoWin = TeekUI.new({ Title = "TEMPO", Subtitle = "VEF", Version = "v1" })
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
local playerTab = makeTab("Player", "👤")
playerTab:Section("Reach", "Extends hitbox to touch ball")
playerTab:Toggle("Reach", "Master switch", false, function(v)
	ReachConfig.Master=v
	if not v then ReachBox.Size=Vector3.new(0,0,0); ReachBox.CFrame=CFrame.new(math.huge,math.huge,math.huge) end
end)
playerTab:Toggle("Visualizer", "Show reach hitbox visualization", false, function(v) ReachConfig.Visualizer=v end)
playerTab:Slider("Reach X (Width)", "Hitbox width (0-30)", 0, 30, 6, function(v) ReachConfig.ReachX=v end, " studs")
playerTab:Slider("Reach Y (Height)", "Hitbox height (0-30)", 0, 30, 7, function(v) ReachConfig.ReachY=v end, " studs")
playerTab:Slider("Reach Z (Length)", "Hitbox length / depth (0-30)", 0, 30, 6, function(v) ReachConfig.ReachZ=v end, " studs")
playerTab:Section("Move Filters", "Which tools use reach")
playerTab:Toggle("Shoot", nil, true, function(v) ReachConfig.Shoot=v end)
playerTab:Toggle("Pass", nil, true, function(v) ReachConfig.Pass=v end)
playerTab:Toggle("Long", nil, true, function(v) ReachConfig.Long=v end)
playerTab:Toggle("Tackle", nil, true, function(v) ReachConfig.Tackle=v end)
playerTab:Toggle("Dribble", nil, true, function(v) ReachConfig.Dribble=v end)
playerTab:Toggle("Save", nil, true, function(v) ReachConfig.Save=v end)
playerTab:Section("Movement", nil)
playerTab:Slider("Walk Speed", "19 default - 400 max speed", 19, 400, 19, function(v)
	WalkSpeedValue=v; if Humanoid then Humanoid.WalkSpeed=v end
end, " studs/s")
playerTab:Toggle("Speed", "Extra movement speed", false, function(v) CharSpeed.Enabled=v end)
playerTab:Slider("Speed Value", nil, 0, 10, 0, function(v) CharSpeed.Value=v end, "")
playerTab:Toggle("Infinite Jump", nil, false, function(v) InfJump=v end)
playerTab:Section("No Cooldown", "Remove tool / skill cooldowns")
playerTab:Toggle("No Cooldown", "Clear Using flags + block ragdoll lock", false, function(v)
	if v then StartNoCooldown(); notify("No Cooldown ON", "good")
	else StopNoCooldown(); notify("No Cooldown OFF", "warn") end
end)
playerTab:Section("PowerShot / Shoot Speed", "Velocity multiplier on shots")
playerTab:Toggle("PowerShot Master", "Enable shoot speed multiplier", false, function(v)
	PowerShot.Enabled=v
	if v then StartPowerShotWatch(); notify("PowerShot ON","good") else StopPowerShotWatch(); notify("PowerShot OFF","warn") end
end)
playerTab:Slider("Multiplier", "Shot velocity scale", 0.5, 5, 1.5, function(v) PowerShot.Multiplier=v end, "x")
playerTab:Slider("Max Velocity Cap", "Horizontal speed hard cap", 100, 1000, 300, function(v) PowerShot.MaxVel=v end, "")
playerTab:Slider("Tool Swap Delay", "ms after equip before boost", 0, 2000, 500, function(v) PowerShot.SwapDelayMs=v end, " ms")
playerTab:Toggle("Boost Shoot", nil, true, function(v) PowerShot.Moves.Shoot=v; PowerShot.Moves.Kick=v end)
playerTab:Toggle("Boost Volley", nil, false, function(v) PowerShot.Moves.Volley=v end)
playerTab:Toggle("Boost Header", nil, false, function(v) PowerShot.Moves.Header=v end)
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.3); local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed=WalkSpeedValue end
end)
local visualsTab = makeTab("Visuals", "👁")
visualsTab:Section("Radar", "Shows players and balls on a circular radar")
visualsTab:Toggle("Radar", nil, false, function(v) if v then RadarEnabled=true; StartRadar() else StopRadar() end end)
visualsTab:Slider("Max Range", "Maximum detection range for radar", 50, 500, 150, function(v) RadarConfig.MaxRange=v end, " studs")
visualsTab:Slider("Size", "Radar display size", 100, 400, 200, function(v)
	RadarConfig.Size=v; if RadarFrame then RadarFrame.Size=UDim2.new(0,v,0,v) end
end, " px")
visualsTab:Section("Trajectory", "Shows ball trajectory prediction")
visualsTab:Toggle("Trajectory", nil, false, function(v) BallPred.Enabled=v; if not v then ClearDump() end end)
visualsTab:Slider("Trigger Speed", nil, 5, 60, 18, function(v) BallPred.Threshold=v end, "")
visualsTab:Slider("Accuracy", nil, 4, 30, 12, function(v) BallPred.Accuracy=v end, "")
visualsTab:Section("Skybox", "Pick sky from dropdown below")
visualsTab:Toggle("Enable Skybox", "Apply custom sky locally", false, function(v)
	SkyboxCfg.Enabled = v
	if v then ApplySkybox(SkyboxCfg.Current) else RemoveCustomSky()
		if SkyboxCfg.OriginalSky then SkyboxCfg.OriginalSky.Parent = SkyboxCfg.OriginalSkyParent or Lighting end
	end
end)
visualsTab:Dropdown("Select Skybox", SKY_NAMES, SkyboxCfg.Current or "Default", function(v)
	SkyboxCfg.Current = v
	if SkyboxCfg.Enabled then ApplySkybox(v) end
	notify("Sky: "..v, "good", 1.5)
end)
visualsTab:Section("Visual Lighting", "Dark · Light · Abundance · more")
visualsTab:Dropdown("Visual Preset", VISUAL_NAMES, VisualFX.Current or "Default", function(v)
	ApplyVisual(v); notify("Visual: "..v, "good", 1.5)
end)
visualsTab:Toggle("Custom Time of Day", "Lock clock time", false, function(v)
	TimeOfDayCfg.Enabled = v
	if v then Lighting.ClockTime = TimeOfDayCfg.Value end
end)
visualsTab:Slider("Time (Hours)", "0-24 clock", 0, 24, 14, function(v)
	TimeOfDayCfg.Value = v
	if TimeOfDayCfg.Enabled then Lighting.ClockTime = v end
end, " h")
visualsTab:Section("Sky / Lighting", "World atmosphere")
visualsTab:Button("Sky: Night", false, function() ApplyLighting("Night"); notify("Night sky","good") end)
visualsTab:Button("Sky: Sunset", false, function() ApplyLighting("Sunset"); notify("Sunset sky","good") end)
visualsTab:Button("Sky: Day", false, function() ApplyLighting("Day"); notify("Day sky","good") end)
visualsTab:Button("Sky: Purple", false, function() ApplyLighting("Purple"); notify("Purple sky","good") end)
visualsTab:Button("Pitch: Green", false, function() SetPitchColor(Color3.fromRGB(40,120,40)); notify("Pitch green","good") end)
visualsTab:Button("Pitch: Dark", false, function() SetPitchColor(Color3.fromRGB(20,40,20)); notify("Pitch dark","good") end)
visualsTab:Button("Pitch: Purple", false, function() SetPitchColor(Color3.fromRGB(60,20,80)); notify("Pitch purple","good") end)
local gkTab = makeTab("GK", "🧤")
gkTab:Section("Auto Catch", "Automatically catches balls in range")
gkTab:Toggle("Auto Catch", nil, false, function(v) AutoCatch.Enabled=v end)
gkTab:Slider("Catch Range", "Max distance to auto-catch", 1, 5, 4, function(v) AutoCatch.Range=v end, " studs")
gkTab:Slider("Catch Cooldown", "Time between catch attempts", 0.5, 5, 1, function(v) AutoCatch.Cooldown=v end, " s")
gkTab:Toggle("High Catch", "ON: High Catch | OFF: Low Catch", true, function(v) AutoCatch.CatchType=v and "High Catch" or "Low Catch" end)
gkTab:Section("Manual Catch", nil)
gkTab:Toggle("Enable Q Key", "use Q key for manual catch", false, function(v) AutoCatch.ManualEnabled=v end)
gkTab:Section("Auto Save", nil)
gkTab:Toggle("Auto Dive", "Dives for you", false, function(v) if v then StartAutoSave() else StopAutoSave() end end)
gkTab:Section("GK Helper", nil)
gkTab:Toggle("GK Helper", "auto position to save shots", false, function(v) if v then StartGKHelper() else StopGKHelper() end end)
gkTab:Section("Auto GK V2", "VRF AI style low/high dive + magnet")
gkTab:Toggle("Auto GK V2", "Penalty/shot auto dive with magnet net", false, function(v)
	if v then StartGKV2(); notify("Auto GK V2 ON", "good")
	else StopGKV2(); notify("Auto GK V2 OFF", "warn") end
end)
gkTab:Slider("V2 Trigger Time", "Seconds before goal line to dive", 0.2, 1.2, 0.65, function(v) GKV2.TRIGGER = v end, " s")
gkTab:Slider("V2 Cooldown", "Delay between saves", 0.3, 1.5, 0.80, function(v) GKV2.COOLDOWN = v end, " s")
gkTab:Slider("V2 Magnet Range", "Post-dive ball pull distance", 2, 12, 5, function(v) GKV2.MAGNET_RANGE = v end, " studs")
local autoTab = makeTab("Auto", "⚡")
autoTab:Section("Auto Dribble", "Hotkey: K")
autoTab:Toggle("Auto Dribble", "Enable/Disable Auto Dribble", false, function(v) AutoConfig.DribbleEnabled=v end)
autoTab:Slider("Dribble Radius", nil, 0.5, 4, 1.2, function(v) AutoConfig.DribbleRadius=v end, "")
autoTab:Slider("Dribble Prediction", nil, 0, 0.5, 0.14, function(v) AutoConfig.DribblePred=v end, "")
autoTab:Section("Auto Guard", "Hotkey: L")
autoTab:Toggle("Auto Guard", "Enable/Disable Auto Guard", false, function(v) AutoConfig.GuardEnabled=v end)
autoTab:Slider("Stop Distance", nil, 0.5, 5, 1.5, function(v) AutoConfig.GuardStopDist=v end, "")
autoTab:Slider("Prediction", nil, 0, 2, 0.5, function(v) AutoConfig.GuardPred=v end, "")
autoTab:Section("Auto Moss", "Hotkey: M")
autoTab:Toggle("Auto Moss", "Enable/Disable Auto Moss", false, function(v) AutoConfig.MossEnabled=v end)
autoTab:Slider("Activation Dist", nil, 10, 100, 50, function(v) AutoConfig.MossActivationDist=v end, " studs")
autoTab:Section("Moss V2", "Magnet + header + ball TP + shoot")
autoTab:Toggle("Moss V2 Master", "Full moss engine", false, function(v)
	if v then StartMossV2(); notify("Moss V2 ON", "good")
	else StopMossV2(); notify("Moss V2 OFF", "warn") end
end)
autoTab:Toggle("Moss Magnet", "Pull ball toward you", true, function(v) MossV2.Magnet = v end)
autoTab:Toggle("Moss Header Boost", "Jump = header lock", true, function(v) MossV2.Header = v end)
autoTab:Toggle("Moss Auto Shoot", "Auto activate shoot tool near ball", true, function(v) MossV2.AutoShoot = v end)
autoTab:Toggle("Moss Ball TP [V]", "V key teleports ball in front", true, function(v) MossV2.BallTP = v end)
autoTab:Slider("Moss Magnet Range", "Ground magnet distance", 6, 30, 14, function(v) MossV2.magnetRange = v end, " studs")
autoTab:Slider("Moss Air Range", "Air ball magnet distance", 10, 40, 22, function(v) MossV2.airRange = v end, " studs")
autoTab:Section("Ball Magnet Tackle", "TP ball to feet on tackle")
autoTab:Toggle("Ball Magnet Master", "Enable ball magnet / reverse TP tackle", false, function(v)
	if v then StartBallMagnet(); notify("Ball Magnet ON", "good")
	else StopBallMagnet(); notify("Ball Magnet OFF", "warn") end
end)
autoTab:Toggle("Auto Equip Tackle", "Equip Tackle tool on C press", true, function(v) BallMagnet.AutoEquip = v end)
autoTab:Toggle("Zero Velocity", "Kill ball momentum on pull", true, function(v) BallMagnet.ZeroVelocity = v end)
autoTab:Slider("Pull Distance", "Studs in front of feet", 0.5, 5, 2, function(v) BallMagnet.Distance = v end, " studs")
autoTab:Slider("Height Offset", "Vertical offset from HRP", 0, 2, 1, function(v) BallMagnet.HeightOffset = v end, "")
local aimTab = makeTab("Aimbot", "🎯")
aimTab:Section("Aimbot Goal V1", "Corner velocity assist")
aimTab:Toggle("Enable V1", "Master switch for aimbot goal v1", false, function(v)
	if v then StartAimbotV1(); notify("Aimbot Goal V1 ON", "good")
	else StopAimbotV1(); notify("Aimbot Goal V1 OFF", "warn") end
end)
aimTab:Toggle("V1 Assist [V]", "Curve shots to far corners", false, function(v)
	AimbotV1.Assist = v
	if v and not AimbotV1.Enabled then StartAimbotV1() end
	notify("V1 Assist " .. (v and "ON" or "OFF"), v and "good" or "warn")
end)
aimTab:Slider("V1 Strength", "Curve strength", 0.03, 0.30, 0.12, function(v) AimbotV1.Strength = v end, "")
aimTab:Slider("V1 Min Speed", "Min ball speed to lock", 10, 60, 25, function(v) AimbotV1.MinSpeed = v end, "")
aimTab:Section("Aimbot Goal V2", "TB-style auto bins + pass assist")
aimTab:Toggle("Enable V2", "Master switch for aimbot goal v2", false, function(v)
	if v then StartAimbotV2(); notify("Aimbot Goal V2 ON", "good")
	else StopAimbotV2(); notify("Aimbot Goal V2 OFF", "warn") end
end)
aimTab:Toggle("V2 Auto Shot [J]", "Auto curve toward open corner", false, function(v)
	AimbotV2.Auto = v
	if v and not AimbotV2.Enabled then StartAimbotV2() end
	notify("V2 Auto " .. (v and "ON" or "OFF"), v and "good" or "warn")
end)
aimTab:Toggle("V2 Pass Assist [K]", "Redirect passes to teammates", false, function(v)
	AimbotV2.Pass = v
	if v and not AimbotV2.Enabled then StartAimbotV2() end
	notify("V2 Pass " .. (v and "ON" or "OFF"), v and "good" or "warn")
end)
aimTab:Slider("V2 Strength", "Auto curve strength", 0.05, 0.40, 0.18, function(v) AimbotV2.Strength = v end, "")
local S = {
	Keybinds={}, Listen=nil, Features={}, MobileOn={}, MPos={}, MSize=48, MTrans=0.15, MLock=false, MShow=true, MBtns={}, MLayer=nil,
	ShowCatchBtns=true, AutoLoadConfig=true, ConfigName="default",
}
S.ShowGKHelperBtn = true
S.MLayer = fr(gui, 50); S.MLayer.Size=UDim2.fromScale(1,1); S.MLayer.ZIndex=50
local function S_reg(id, label, getf, setf)
	table.insert(S.Features, {id=id, label=label, get=getf, set=setf})
end
local function S_style(b)
	b.BackgroundColor3=Color3.fromRGB(12,8,20); b.BackgroundTransparency=S.MTrans
	b.TextColor3=P.hot; b.FontFace=F_S; b.TextSize=math.clamp(math.floor(S.MSize*0.28),9,14)
	b.AutoButtonColor=false; b.BorderSizePixel=0
	corner(b, math.floor(S.MSize*0.28))
	local st=b:FindFirstChildOfClass("UIStroke") or stroke(b, P.accent, 1.3, 0.25)
	st.Color=P.accent; st.Transparency=0.25+S.MTrans*0.5
end
local function S_lookAll()
	for _,e in pairs(S.MBtns) do
		if e.btn and e.btn.Parent then
			local s = S.MSize
			e.btn.Size = UDim2.fromOffset(s, s)
			S_style(e.btn)
			if e.wrap then
				local pad = 10
				e.wrap.Size = UDim2.fromOffset(s + pad*2, s + pad*2)
			end
		end
	end
end
local function S_kill(id)
	local e=S.MBtns[id]; if not e then return end
	pcall(function() if e.wrap then e.wrap:Destroy() elseif e.btn then e.btn:Destroy() end end); S.MBtns[id]=nil
end
local function S_makeBtn(id, label, onPress)
	S_kill(id); if not S.MShow then return end
	local s = math.max(S.MSize or 48, 36)
	local pad = 10
	local wrap = Instance.new("Frame")
	wrap.Name = "MBW_"..id
	wrap.BackgroundTransparency = 1
	wrap.BorderSizePixel = 0
	wrap.Size = UDim2.fromOffset(s + pad*2, s + pad*2)
	wrap.ZIndex = 54
	wrap.Active = true
	wrap.Parent = S.MLayer
	local h = 0
	for i = 1, #id do h = h + string.byte(id, i) end
	if S.MPos and S.MPos[id] then
		wrap.Position = UDim2.fromOffset(S.MPos[id][1] - pad, S.MPos[id][2] - pad)
	else
		wrap.Position = UDim2.new(1, -(s+pad*2) - 8 - (h%3)*8, 0.18 + (h%10)*0.055, 0)
	end
	local b = Instance.new("TextButton")
	b.Name = "MB_"..id
	b.Size = UDim2.fromOffset(s, s)
	b.Position = UDim2.fromOffset(pad, pad)
	b.Text = string.sub(label, 1, 6)
	b.ZIndex = 55
	b.Parent = wrap
	b.Active = true
	b.Selectable = true
	b.AutoButtonColor = false
	b.Modal = false
	S_style(b)
	local hit = Instance.new("TextButton")
	hit.Name = "Hit"
	hit.Size = UDim2.fromScale(1, 1)
	hit.Position = UDim2.fromOffset(0, 0)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.ZIndex = 56
	hit.Active = true
	hit.AutoButtonColor = false
	hit.Parent = wrap
	local down = false
	local dragging = false
	local didMove = false
	local startM, startP, downPos = nil, nil, nil
	local DRAG_THRESHOLD = 18
	local changedConn, endedConn = nil, nil
	local function cleanupConns()
		if changedConn then pcall(function() changedConn:Disconnect() end); changedConn = nil end
		if endedConn then pcall(function() endedConn:Disconnect() end); endedConn = nil end
	end
	local function onDown(i)
		if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
		down = true
		didMove = false
		dragging = false
		downPos = i.Position
		startM = i.Position
		startP = wrap.AbsolutePosition
		cleanupConns()
		changedConn = UserInputService.InputChanged:Connect(function(ci)
			if not down then return end
			if ci.UserInputType ~= Enum.UserInputType.MouseMovement and ci.UserInputType ~= Enum.UserInputType.Touch then return end
			local mag = (ci.Position - downPos).Magnitude
			if mag > DRAG_THRESHOLD then
				didMove = true
				if not S.MLock then
					dragging = true
					local d = ci.Position - startM
					local pa = S.MLayer.AbsolutePosition
					wrap.Position = UDim2.fromOffset(startP.X + d.X - pa.X, startP.Y + d.Y - pa.Y)
					wrap.AnchorPoint = Vector2.new(0, 0)
				end
			end
		end)
		endedConn = UserInputService.InputEnded:Connect(function(ei)
			if ei.UserInputType ~= Enum.UserInputType.MouseButton1 and ei.UserInputType ~= Enum.UserInputType.Touch then return end
			if not down then return end
			down = false
			cleanupConns()
			if dragging then
				S.MPos = S.MPos or {}
				S.MPos[id] = {wrap.Position.X.Offset + pad, wrap.Position.Y.Offset + pad}
			elseif not didMove then
				ripple(b, s/2, s/2, s*2)
				if onPress then task.defer(function() pcall(onPress) end) end
			end
			dragging = false
			didMove = false
			downPos = nil
			startM = nil
			startP = nil
		end)
	end
	hit.InputBegan:Connect(onDown)
	S.MBtns[id] = {btn = b, wrap = wrap, label = label}
end
local function S_toggle(id)
	for _,f in ipairs(S.Features) do
		if f.id==id then
			local cur=f.get(); f.set(not cur)
			notify(f.label.." "..(not cur and "ON" or "OFF"), not cur and "good" or "warn")
			return
		end
	end
end
UserInputService.InputBegan:Connect(function(input, gp)
	if gp or UserInputService:GetFocusedTextBox() then return end
	if input.UserInputType~=Enum.UserInputType.Keyboard then return end
	if S.Listen then
		local id=S.Listen; S.Listen=nil
		if input.KeyCode==Enum.KeyCode.Escape then S.Keybinds[id]=nil; notify("Unbound "..id,"warn")
		else S.Keybinds[id]=input.KeyCode; notify("Bound "..id.." → "..input.KeyCode.Name,"good") end
		return
	end
	for id,kc in pairs(S.Keybinds) do
		if kc==input.KeyCode then S_toggle(id) end
	end
end)
local function S_keyName(id)
	local k=S.Keybinds[id]; return k and k.Name or "None"
end
local function S_rebuildMobile()
	for id in pairs(S.MBtns) do S_kill(id) end
	if not S.MShow then return end
	for _,f in ipairs(S.Features) do
		if f.id~="menu" and S.MobileOn[f.id] then
			S_makeBtn(f.id, f.label, function() S_toggle(f.id) end)
		end
	end
	if S.ShowGKHelperBtn ~= false then
		S_makeBtn("_gkhelper", "GKHelp", function()
			if GKHelper.Enabled then
				StopGKHelper()
				notify("GK Helper OFF", "warn")
			else
				StartGKHelper()
				notify("GK Helper ON", "good")
			end
		end)
	end
	if S.ShowCatchBtns then
		S_makeBtn("_highcatch", "HiCatch", function()
			if not HRP then return end
			local ball = GetNearestBall and GetNearestBall(HRP, AutoCatch.Range or 25)
			if ball and ToolManagment then
				pcall(function() ToolManagment.atac(ToolManagment, ball, "High Catch") end)
			else
				pcall(function()
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
					task.wait(0.05)
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
				end)
			end
			notify("High Catch", "good", 1)
		end)
		S_makeBtn("_lowcatch", "LoCatch", function()
			if not HRP then return end
			local ball = GetNearestBall and GetNearestBall(HRP, AutoCatch.Range or 25)
			if ball and ToolManagment then
				pcall(function() ToolManagment.atac(ToolManagment, ball, "Low Catch") end)
			else
				pcall(function()
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
					task.wait(0.05)
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
				end)
			end
			notify("Low Catch", "good", 1)
		end)
	end
end
local CFG_FOLDER = "TempoConfigs"
local function cfgPath(name)
	return CFG_FOLDER .. "/" .. tostring(name or S.ConfigName or "default") .. ".json"
end
local function S_ensureFolder()
	pcall(function()
		if isfolder and not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end
	end)
end
local function S_serializeKeybinds()
	local out = {}
	for id, kc in pairs(S.Keybinds) do
		if typeof(kc) == "EnumItem" then out[id] = kc.Name end
	end
	return out
end
local function S_deserializeKeybinds(t)
	S.Keybinds = {}
	if type(t) ~= "table" then return end
	for id, name in pairs(t) do
		local ok, kc = pcall(function() return Enum.KeyCode[name] end)
		if ok and kc then S.Keybinds[id] = kc end
	end
end
local function S_collectConfig()
	S.MPos = S.MPos or {}
	for id, e in pairs(S.MBtns) do
		if e.wrap and e.wrap.Parent then
			local pad = 10
			S.MPos[id] = {e.wrap.Position.X.Offset + pad, e.wrap.Position.Y.Offset + pad}
		elseif e.btn and e.btn.Parent then
			S.MPos[id] = {e.btn.Position.X.Offset, e.btn.Position.Y.Offset}
		end
	end
	local features = {}
	for _, f in ipairs(S.Features) do
		local ok, val = pcall(f.get)
		if ok then features[f.id] = val end
	end
	return {
		version = 3,
		MSize = S.MSize, MTrans = S.MTrans, MLock = S.MLock, MShow = S.MShow,
		ShowCatchBtns = S.ShowCatchBtns,
		ShowGKHelperBtn = S.ShowGKHelperBtn, AutoLoadConfig = S.AutoLoadConfig,
		MobileOn = S.MobileOn, MPos = S.MPos, Keybinds = S_serializeKeybinds(),
		Features = features,
		Reach = ReachConfig and {
			Master=ReachConfig.Master, Visualizer=ReachConfig.Visualizer,
			ReachX=ReachConfig.ReachX, ReachY=ReachConfig.ReachY, ReachZ=ReachConfig.ReachZ,
			Shoot=ReachConfig.Shoot, Pass=ReachConfig.Pass, Long=ReachConfig.Long,
			Tackle=ReachConfig.Tackle, Dribble=ReachConfig.Dribble, Save=ReachConfig.Save,
		} or nil,
		BallPred = BallPred and {Enabled=BallPred.Enabled, Threshold=BallPred.Threshold, Accuracy=BallPred.Accuracy} or nil,
		CharSpeed = CharSpeed and {Enabled=CharSpeed.Enabled, Value=CharSpeed.Value} or nil,
		WalkSpeedValue = WalkSpeedValue,
		InfJump = InfJump,
		AutoCatch = AutoCatch and {Enabled=AutoCatch.Enabled, Range=AutoCatch.Range, Cooldown=AutoCatch.Cooldown, CatchType=AutoCatch.CatchType, ManualEnabled=AutoCatch.ManualEnabled} or nil,
		AutoSave = AutoSave and {Enabled=AutoSave.Enabled} or nil,
		GKHelper = GKHelper and {Enabled=GKHelper.Enabled} or nil,
		GKV2 = GKV2 and {Enabled=GKV2.Enabled, TRIGGER=GKV2.TRIGGER, COOLDOWN=GKV2.COOLDOWN, MAGNET_RANGE=GKV2.MAGNET_RANGE} or nil,
		NoCooldown = NoCooldown and {Enabled=NoCooldown.Enabled} or nil,
		BallMagnet = BallMagnet and {
			Enabled=BallMagnet.Enabled, AutoEquip=BallMagnet.AutoEquip, ZeroVelocity=BallMagnet.ZeroVelocity,
			Distance=BallMagnet.Distance, HeightOffset=BallMagnet.HeightOffset,
		} or nil,
		AutoConfig = AutoConfig and {
			DribbleEnabled=AutoConfig.DribbleEnabled, DribbleRadius=AutoConfig.DribbleRadius, DribblePred=AutoConfig.DribblePred,
			GuardEnabled=AutoConfig.GuardEnabled, GuardStopDist=AutoConfig.GuardStopDist, GuardPred=AutoConfig.GuardPred,
			MossEnabled=AutoConfig.MossEnabled, MossActivationDist=AutoConfig.MossActivationDist,
		} or nil,
		MossV2 = MossV2 and {
			Enabled=MossV2.Enabled, Magnet=MossV2.Magnet, Header=MossV2.Header, AutoShoot=MossV2.AutoShoot, BallTP=MossV2.BallTP,
			magnetRange=MossV2.magnetRange, airRange=MossV2.airRange,
		} or nil,
		AimbotV1 = AimbotV1 and {Enabled=AimbotV1.Enabled, Assist=AimbotV1.Assist, Strength=AimbotV1.Strength, MinSpeed=AimbotV1.MinSpeed} or nil,
		AimbotV2 = AimbotV2 and {Enabled=AimbotV2.Enabled, Auto=AimbotV2.Auto, Pass=AimbotV2.Pass, Strength=AimbotV2.Strength} or nil,
		PowerShot = PowerShot and {
			Enabled=PowerShot.Enabled, Multiplier=PowerShot.Multiplier, MaxVel=PowerShot.MaxVel, SwapDelayMs=PowerShot.SwapDelayMs,
			Moves=PowerShot.Moves,
		} or nil,
		Radar = {Enabled=RadarEnabled, Size=RadarConfig and RadarConfig.Size, MaxRange=RadarConfig and RadarConfig.MaxRange},
		Sky = {
			Enabled = SkyboxCfg and SkyboxCfg.Enabled or false,
			Current = SkyboxCfg and SkyboxCfg.Current or "Default",
			TimeEnabled = TimeOfDayCfg and TimeOfDayCfg.Enabled or false,
			TimeValue = TimeOfDayCfg and TimeOfDayCfg.Value or 14,
		},
		Visual = VisualFX and VisualFX.Current or "Default",
	}
end
local function S_applyConfig(data)
	if type(data) ~= "table" then return false end
	if data.MSize then S.MSize = data.MSize end
	if data.MTrans then S.MTrans = data.MTrans end
	if data.MLock ~= nil then S.MLock = data.MLock end
	if data.MShow ~= nil then S.MShow = data.MShow end
	if data.ShowCatchBtns ~= nil then S.ShowCatchBtns = data.ShowCatchBtns end
	if data.ShowGKHelperBtn ~= nil then S.ShowGKHelperBtn = data.ShowGKHelperBtn end
	if data.AutoLoadConfig ~= nil then S.AutoLoadConfig = data.AutoLoadConfig end
	if type(data.MobileOn) == "table" then S.MobileOn = data.MobileOn end
	if type(data.MPos) == "table" then S.MPos = data.MPos end
	if data.Keybinds then S_deserializeKeybinds(data.Keybinds) end
	local function merge(dst, src)
		if type(dst)~="table" or type(src)~="table" then return end
		for k,v in pairs(src) do
			if type(v)=="table" and type(dst[k])=="table" then merge(dst[k], v) else dst[k]=v end
		end
	end
	if data.Reach and ReachConfig then merge(ReachConfig, data.Reach) end
	if data.BallPred and BallPred then merge(BallPred, data.BallPred) end
	if data.CharSpeed and CharSpeed then merge(CharSpeed, data.CharSpeed) end
	if data.WalkSpeedValue then WalkSpeedValue = data.WalkSpeedValue; if Humanoid then Humanoid.WalkSpeed = WalkSpeedValue end end
	if data.InfJump ~= nil then InfJump = data.InfJump end
	if data.AutoCatch and AutoCatch then merge(AutoCatch, data.AutoCatch) end
	if data.AutoSave and AutoSave then
		if data.AutoSave.Enabled then StartAutoSave() else StopAutoSave() end
	end
	if data.GKHelper and GKHelper then
		if data.GKHelper.Enabled then StartGKHelper() else StopGKHelper() end
	end
	if data.GKV2 and GKV2 then
		merge(GKV2, data.GKV2)
		if data.GKV2.Enabled then StartGKV2() else StopGKV2() end
	end
	if data.NoCooldown and NoCooldown then
		if data.NoCooldown.Enabled then StartNoCooldown() else StopNoCooldown() end
	end
	if data.BallMagnet and BallMagnet then
		merge(BallMagnet, data.BallMagnet)
		if data.BallMagnet.Enabled then StartBallMagnet() else StopBallMagnet() end
	end
	if data.AutoConfig and AutoConfig then merge(AutoConfig, data.AutoConfig) end
	if data.MossV2 and MossV2 then
		merge(MossV2, data.MossV2)
		if data.MossV2.Enabled then StartMossV2() else StopMossV2() end
	end
	if data.AimbotV1 and AimbotV1 then
		merge(AimbotV1, data.AimbotV1)
		if data.AimbotV1.Enabled then StartAimbotV1() else StopAimbotV1() end
	end
	if data.AimbotV2 and AimbotV2 then
		merge(AimbotV2, data.AimbotV2)
		if data.AimbotV2.Enabled then StartAimbotV2() else StopAimbotV2() end
	end
	if data.PowerShot and PowerShot then
		merge(PowerShot, data.PowerShot)
		if data.PowerShot.Enabled then StartPowerShotWatch() else StopPowerShotWatch() end
	end
	if data.Radar then
		if data.Radar.Size and RadarConfig then RadarConfig.Size = data.Radar.Size end
		if data.Radar.MaxRange and RadarConfig then RadarConfig.MaxRange = data.Radar.MaxRange end
		if data.Radar.Enabled then RadarEnabled=true; pcall(StartRadar) else pcall(StopRadar) end
	end
	if type(data.Features) == "table" then
		for _, f in ipairs(S.Features) do
			if data.Features[f.id] ~= nil then
				pcall(f.set, data.Features[f.id])
			end
		end
	end
	if type(data.Sky) == "table" and SkyboxCfg then
		SkyboxCfg.Current = data.Sky.Current or SkyboxCfg.Current
		SkyboxCfg.Enabled = data.Sky.Enabled and true or false
		if SkyboxCfg.Enabled then ApplySkybox(SkyboxCfg.Current) else RemoveCustomSky() end
		if TimeOfDayCfg then
			TimeOfDayCfg.Value = data.Sky.TimeValue or TimeOfDayCfg.Value
			TimeOfDayCfg.Enabled = data.Sky.TimeEnabled and true or false
			if TimeOfDayCfg.Enabled then Lighting.ClockTime = TimeOfDayCfg.Value end
		end
	end
	if data.Visual and ApplyVisual then pcall(ApplyVisual, data.Visual) end
	S_rebuildMobile()
	return true
end
local function S_saveConfig(name)
	name = name or S.ConfigName or "default"
	S.ConfigName = name
	S_ensureFolder()
	local data = S_collectConfig()
	local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
	if not ok then notify("Config encode failed", "bad"); return false end
	local path = cfgPath(name)
	local wok = pcall(function()
		if writefile then writefile(path, encoded) else error("writefile missing") end
	end)
	if wok then notify("Saved config: "..name, "good") else notify("Save failed (no writefile)", "bad") end
	return wok
end
local function S_loadConfig(name)
	name = name or S.ConfigName or "default"
	S.ConfigName = name
	local path = cfgPath(name)
	local ok, raw = pcall(function()
		if isfile and not isfile(path) then error("missing") end
		return readfile(path)
	end)
	if not ok or type(raw) ~= "string" then notify("Config not found: "..name, "warn"); return false end
	local dok, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if not dok or type(data) ~= "table" then notify("Config corrupt", "bad"); return false end
	S_applyConfig(data)
	notify("Loaded config: "..name, "good")
	return true
end
S_reg("reach","Reach",function() return ReachConfig.Master end,function(v)
	ReachConfig.Master=v
	if not v then ReachBox.Size=Vector3.new(0,0,0); ReachBox.CFrame=CFrame.new(math.huge,math.huge,math.huge) end
end)
S_reg("speed","Speed",function() return CharSpeed.Enabled end,function(v) CharSpeed.Enabled=v end)
S_reg("infjump","Infinite Jump",function() return InfJump end,function(v) InfJump=v end)
S_reg("powershot","PowerShot",function() return PowerShot.Enabled end,function(v)
	PowerShot.Enabled=v; if v then StartPowerShotWatch() else StopPowerShotWatch() end
end)
S_reg("nocooldown","No Cooldown",function() return NoCooldown.Enabled end,function(v)
	if v then StartNoCooldown() else StopNoCooldown() end
end)
S_reg("ballmagnet","Ball Magnet",function() return BallMagnet.Enabled end,function(v)
	if v then StartBallMagnet() else StopBallMagnet() end
end)
S_reg("radar","Radar",function() return RadarEnabled end,function(v)
	if v then RadarEnabled=true; StartRadar() else StopRadar() end
end)
S_reg("trajectory","Trajectory",function() return BallPred.Enabled end,function(v)
	BallPred.Enabled=v; if not v then ClearDump() end
end)
S_reg("autocatch","Auto Catch",function() return AutoCatch.Enabled end,function(v) AutoCatch.Enabled=v end)
S_reg("autodive","Auto Dive",function() return AutoSave.Enabled end,function(v)
	if v then StartAutoSave() else StopAutoSave() end
end)
S_reg("gkhelper","GK Helper",function() return GKHelper.Enabled end,function(v)
	if v then StartGKHelper() else StopGKHelper() end
end)
S_reg("gkv2","Auto GK V2",function() return GKV2.Enabled end,function(v)
	if v then StartGKV2() else StopGKV2() end
end)
S_reg("autodribble","Auto Dribble",function() return AutoConfig.DribbleEnabled end,function(v) AutoConfig.DribbleEnabled=v end)
S_reg("autoguard","Auto Guard",function() return AutoConfig.GuardEnabled end,function(v) AutoConfig.GuardEnabled=v end)
S_reg("automoss","Auto Moss",function() return AutoConfig.MossEnabled end,function(v) AutoConfig.MossEnabled=v end)
S_reg("mossv2","Moss V2",function() return MossV2.Enabled end,function(v)
	if v then StartMossV2() else StopMossV2() end
end)
S_reg("aimv1","Aimbot V1",function() return AimbotV1.Enabled end,function(v)
	if v then StartAimbotV1() else StopAimbotV1() end
end)
S_reg("aimv1assist","V1 Assist",function() return AimbotV1.Assist end,function(v)
	AimbotV1.Assist=v; if v and not AimbotV1.Enabled then StartAimbotV1() end
end)
S_reg("aimv2","Aimbot V2",function() return AimbotV2.Enabled end,function(v)
	if v then StartAimbotV2() else StopAimbotV2() end
end)
S_reg("aimv2auto","V2 Auto Shot",function() return AimbotV2.Auto end,function(v)
	AimbotV2.Auto=v; if v and not AimbotV2.Enabled then StartAimbotV2() end
end)
S_reg("aimv2pass","V2 Pass Assist",function() return AimbotV2.Pass end,function(v)
	AimbotV2.Pass=v; if v and not AimbotV2.Enabled then StartAimbotV2() end
end)
S_reg("menu","Toggle Menu",function() return main.Visible end,function(v)
	if v then show() else hide() end
end)
local mobileSetTab = makeTab("Mobile", "📱")
mobileSetTab:Section("Mobile Buttons", "Size · lock · transparency · master")
mobileSetTab:Toggle("Show Mobile Buttons", "Master switch for floating buttons", true, function(v)
	S.MShow=v; S_rebuildMobile()
end)
mobileSetTab:Toggle("High / Low Catch Buttons", "On-screen HiCatch + LoCatch", true, function(v)
	S.ShowCatchBtns=v; S_rebuildMobile()
end)
mobileSetTab:Toggle("GK Helper Button", "Always-on floating GK Helper toggle", true, function(v)
	S.ShowGKHelperBtn=v; S_rebuildMobile()
end)
mobileSetTab:Toggle("Lock Buttons", "Freeze position (no drag)", false, function(v) S.MLock=v end)
mobileSetTab:Slider("Button Size", "Mobile button pixel size", 32, 80, 48, function(v) S.MSize=v; S_lookAll() end, " px")
mobileSetTab:Slider("Button Transparency", "0 solid · 1 invisible", 0, 0.85, 0.15, function(v) S.MTrans=v; S_lookAll() end, "")
mobileSetTab:Button("Rebuild Mobile Buttons", false, function() S_rebuildMobile(); notify("Mobile buttons rebuilt","good") end)
mobileSetTab:Section("Which Features Get a Button", "Toggle on only what you want on screen")
for _,f in ipairs(S.Features) do
	if f.id ~= "menu" then
		local fid, flabel = f.id, f.label
		mobileSetTab:Toggle("Btn · "..flabel, "Show a mobile button for "..flabel, false, function(v)
			S.MobileOn[fid] = v
			S_rebuildMobile()
		end)
	end
end
mobileSetTab:Button("Enable All Feature Buttons", false, function()
	for _,f in ipairs(S.Features) do
		if f.id ~= "menu" then S.MobileOn[f.id] = true end
	end
	S_rebuildMobile()
	notify("All feature buttons on", "good")
end)
mobileSetTab:Button("Clear All Feature Buttons", false, function()
	table.clear(S.MobileOn)
	S_rebuildMobile()
	notify("All feature buttons off", "warn")
end)
local pcSetTab = makeTab("PC", "🖥")
pcSetTab:Section("Keybinds", "Click Bind, press a key. Esc clears.")
pcSetTab:Label("Every feature can be hotkeyed on keyboard.")
for _,f in ipairs(S.Features) do
	local fid,flabel=f.id,f.label
	pcSetTab:Button("Bind: "..flabel.."  ["..S_keyName(fid).."]", false, function()
		S.Listen=fid; notify("Press a key for "..flabel.." (Esc=clear)","warn",4)
	end)
end
pcSetTab:Section("Keybind Utils", nil)
pcSetTab:Button("Clear All Keybinds", false, function() table.clear(S.Keybinds); notify("All keybinds cleared","warn") end)
pcSetTab:Label("RightControl still toggles the main menu window.")
local configTab = makeTab("Config", "💾")
configTab:Section("Named Configs", "Save toggles · sliders · keybinds · mobile layout")
configTab:TextInput("Config Name", "e.g. mobile_gk", S.ConfigName or "default", function(t)
	if t and t ~= "" then S.ConfigName = t end
end)
configTab:Toggle("Auto Load On Inject", "Load this name when script starts", true, function(v)
	S.AutoLoadConfig = v
end)
configTab:Button("Save / Overwrite Config", true, function()
	S_saveConfig(S.ConfigName or "default")
end)
configTab:Button("Load Config", false, function()
	S_loadConfig(S.ConfigName or "default")
end)
configTab:Button("Overwrite Current", true, function()
	S_saveConfig(S.ConfigName or "default")
end)
configTab:Section("Quick Slots", "One-tap save/load")
configTab:Button("Save → slot1", false, function() S_saveConfig("slot1") end)
configTab:Button("Load ← slot1", false, function() S_loadConfig("slot1") end)
configTab:Button("Save → slot2", false, function() S_saveConfig("slot2") end)
configTab:Button("Load ← slot2", false, function() S_loadConfig("slot2") end)
configTab:Button("Save → mobile", false, function() S_saveConfig("mobile") end)
configTab:Button("Load ← mobile", false, function() S_loadConfig("mobile") end)
configTab:Label("Saves to executor workspace: TempoConfigs/<name>.json")
configTab:Label("Includes: all toggles, reach X/Y/Z, sliders, PowerShot, aim, GK, moss, radar, sky, keybinds, mobile layout.")
task.defer(function()
	task.wait(0.8)
	if S.AutoLoadConfig then
		pcall(function() S_loadConfig(S.ConfigName or "default") end)
	end
	S_rebuildMobile()
end)
local miscTab = makeTab("Misc", "M")
miscTab:Section("Utility", nil)
miscTab:Button("Notify Test", true, function() notify("Tempo Hub online","good") end)
miscTab:Section("Unload", nil)
miscTab:Button("Unload", false, function()
	task.spawn(function()
		pcall(function() ReachConfig.Master = false end)
		pcall(StopRadar); pcall(StopAutoSave); pcall(StopGKHelper); pcall(ClearDump)
		pcall(StopAimbotV1); pcall(StopAimbotV2); pcall(StopGKV2); pcall(StopMossV2); pcall(StopPowerShotWatch)
		pcall(StopNoCooldown); pcall(StopBallMagnet)
		pcall(function() if BallPred then BallPred.Enabled = false end end)
		pcall(function() CharSpeed.Enabled = false end)
		pcall(function() AutoCatch.Enabled = false end)
		pcall(function()
			AutoConfig.DribbleEnabled = false
			AutoConfig.GuardEnabled = false
			AutoConfig.MossEnabled = false
		end)
		hide()
		task.wait(0.15)
		pcall(function() if ReachBox then ReachBox:Destroy() end end)
		pcall(function() if orb then orb:Destroy() end end)
		pcall(function() if mobileBar then mobileBar:Destroy() end end)
		pcall(function() if S and S.MBtns then for id in pairs(S.MBtns) do S_kill(id) end end end)
		pcall(function() gui:Destroy() end)
		notify("Unloaded", "warn", 2)
	end)
end)
miscTab:Label("RightControl toggles menu. Mobile uses top bar + orb.")
miscTab:Label("Paste this whole script into any executor while in game.")
boot({"checking executor","loading reach","wiring gk systems","syncing theme","ready"}, function()
	notify("Tempo Hub loaded","good")
end)
