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
repeat task.wait() until game:IsLoaded()
local TeekUI = assert(
	loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))(),
	"TempoUI failed"
)
local UI = TeekUI.new({
	Title = "TEMPO",
	Subtitle = "Underground War",
	Version = "v1",
})
local t0 = os.clock()
cloneref = cloneref or function(x) return x end
local Players = cloneref(game:GetService("Players"))
local RS = cloneref(game:GetService("ReplicatedStorage"))
local RunS = cloneref(game:GetService("RunService"))
local UIS = cloneref(game:GetService("UserInputService"))
local Lighting = cloneref(game:GetService("Lighting"))
local TweenService = cloneref(game:GetService("TweenService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local unpack_ = unpack or table.unpack
local Flags, tabs = {}, {}
local function setFlag(n, v) Flags[n] = v end
local function isOn(n) return Flags[n] == true end
local function notify(title, text)
	pcall(function()
		if UI and UI.Notify then UI:Notify(tostring(title) .. (text and (" | " .. tostring(text)) or ""), "good") end
	end)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = tostring(title or "TEMPO"),
			Text = tostring(text or ""),
			Duration = 3,
		})
	end)
end
local Character, Humanoid, HRP
local function refreshChar()
	Character = LP.Character
	Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	HRP = Character and Character:FindFirstChild("HumanoidRootPart")
end
refreshChar()
LP.CharacterAdded:Connect(function(c)
	Character = c
	Humanoid = c:WaitForChild("Humanoid", 10)
	HRP = c:WaitForChild("HumanoidRootPart", 10)
end)
local Config = {
	Aimbot = false,
	SilentAim = false,
	TeamCheck = true,
	WallCheck = false,
	KillDistance = 5000,
	TargetPart = "HumanoidRootPart",
	FOV = 180,
	ShowFOV = false,
	Hitbox = false,
	HitboxVisible = true,
	HitboxSize = 50,
	SpamSword = false,
	Spin = false,
	SpinSpeed = 2160,
	Prediction = 0,
}
local function getShotRemote()
	local events = RS:FindFirstChild("Events")
	local remote = events and events:FindFirstChild("Remote")
	local shot = remote and remote:FindFirstChild("ShotTarget")
	if shot then return shot end
	for _, d in ipairs(RS:GetDescendants()) do
		if d.Name == "ShotTarget" and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) then
			return d
		end
	end
end
local function isDead(plr)
	local char = plr and plr.Character
	if not char then return true end
	local hum = char:FindFirstChildOfClass("Humanoid")
	return not hum or hum.Health <= 0
end
local function wallBlocked(plr)
	if not Config.WallCheck then return false end
	if not (HRP and plr.Character) then return true end
	local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return true end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { Character, plr.Character }
	local dir = targetHRP.Position - HRP.Position
	local hit = workspace:Raycast(HRP.Position, dir, params)
	return hit ~= nil
end
local function getTargetPart(char)
	local name = Config.TargetPart or "HumanoidRootPart"
	return char:FindFirstChild(name)
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChildWhichIsA("BasePart")
end
local function getClosest(maxDist)
	maxDist = maxDist or Config.KillDistance
	local best, bestDist = nil, maxDist
	if not HRP then return nil end
	local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and not isDead(plr) then
			if not Config.TeamCheck or plr.Team ~= LP.Team then
				local char = plr.Character
				local part = char and getTargetPart(char)
				if part then
					local dist = (part.Position - HRP.Position).Magnitude
					if dist < bestDist and not wallBlocked(plr) then
						local screen, onScreen = Cam:WorldToViewportPoint(part.Position)
						if onScreen then
							local d2 = (Vector2.new(screen.X, screen.Y) - center).Magnitude
							if d2 <= (Config.FOV or 180) or Config.FOV >= 500 then
								bestDist = dist
								best = plr
							end
						elseif Config.FOV >= 500 then
							bestDist = dist
							best = plr
						end
					end
				end
			end
		end
	end
	return best
end
local Locked = nil
local function fireShot(pos, weaponName)
	local rem = getShotRemote()
	if not rem then return false end
	local ok = pcall(function()
		if rem:IsA("RemoteEvent") then
			rem:FireServer(pos, weaponName or "Sniper")
		else
			rem:InvokeServer(pos, weaponName or "Sniper")
		end
	end)
	return ok
end
local function getEquippedWeaponName()
	local tool = Character and Character:FindFirstChildOfClass("Tool")
	return tool and tool.Name or "Sniper"
end
local function silentStep()
	if not (Config.SilentAim or Config.Aimbot) then
		Locked = nil
		return
	end
	local target = getClosest()
	Locked = target
	if not target or not target.Character then return end
	local part = getTargetPart(target.Character)
	if not part then return end
	local pos = part.Position
	if Config.Prediction and Config.Prediction > 0 then
		local vel = part.AssemblyLinearVelocity or part.Velocity or Vector3.zero
		pos = pos + vel * (Config.Prediction / 100)
	end
	if Config.Aimbot then
		local tool = Character and Character:FindFirstChildOfClass("Tool")
		if tool and (tool.Name == "Sniper" or tool.Name == "Pistol" or tool:IsA("Tool")) then
			fireShot(pos, tool.Name)
		end
	end
end
local function shootClosest()
	local target = getClosest()
	Locked = target
	if not target or not target.Character then
		notify("Shot", "no target")
		return
	end
	local part = getTargetPart(target.Character)
	if not part then return end
	local pos = part.Position
	local hum = target.Character:FindFirstChildOfClass("Humanoid")
	if hum and hum.MoveDirection.Magnitude > 0 then
		pos = part.Position + hum.MoveDirection * 10
	end
	local tool = Character and Character:FindFirstChildOfClass("Tool")
	if tool then pcall(function() tool:Activate() end) end
	fireShot(pos, getEquippedWeaponName())
	notify("Locked", target.Name)
end
local fovCircle, crossLines, lockLabel
pcall(function()
	if Drawing then
		fovCircle = Drawing.new("Circle")
		fovCircle.Thickness = 1
		fovCircle.NumSides = 64
		fovCircle.Radius = Config.FOV
		fovCircle.Filled = false
		fovCircle.Color = Color3.fromRGB(96, 165, 250)
		fovCircle.Visible = false
		crossLines = {}
		for i = 1, 4 do
			local line = Drawing.new("Line")
			line.Thickness = 2
			line.Color = Color3.fromRGB(255, 60, 60)
			line.Visible = false
			crossLines[i] = line
		end
	end
end)
local function updateDrawings()
	if not fovCircle then return end
	local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
	fovCircle.Position = center
	fovCircle.Radius = Config.FOV
	fovCircle.Visible = Config.ShowFOV == true
	if Locked and Locked.Character then
		local part = getTargetPart(Locked.Character)
		if part then
			local sp, on = Cam:WorldToViewportPoint(part.Position)
			if on and crossLines then
				local p = Vector2.new(sp.X, sp.Y)
				local n = 12
				crossLines[1].From = Vector2.new(p.X - n, p.Y)
				crossLines[1].To = Vector2.new(p.X - n - 5, p.Y)
				crossLines[2].From = Vector2.new(p.X + n, p.Y)
				crossLines[2].To = Vector2.new(p.X + n + 5, p.Y)
				crossLines[3].From = Vector2.new(p.X, p.Y - n)
				crossLines[3].To = Vector2.new(p.X, p.Y - n - 5)
				crossLines[4].From = Vector2.new(p.X, p.Y + n)
				crossLines[4].To = Vector2.new(p.X, p.Y + n + 5)
				for _, l in ipairs(crossLines) do l.Visible = true end
				return
			end
		end
	end
	if crossLines then
		for _, l in ipairs(crossLines) do l.Visible = false end
	end
end
local HitboxPart = Instance.new("Part")
HitboxPart.Name = "TEMPO_HitboxVisual"
HitboxPart.Shape = Enum.PartType.Ball
HitboxPart.Anchored = true
HitboxPart.CanCollide = false
HitboxPart.CastShadow = false
HitboxPart.Transparency = 0.8
HitboxPart.Material = Enum.Material.Neon
HitboxPart.Color = Color3.fromRGB(255, 40, 40)
HitboxPart.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
local function hitboxStep()
	if not Config.Hitbox then
		HitboxPart.Parent = nil
		return
	end
	local tool = Character and Character:FindFirstChildOfClass("Tool")
	local handle = tool and (tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart"))
	if not handle then
		HitboxPart.Parent = nil
		return
	end
	HitboxPart.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
	HitboxPart.CFrame = handle.CFrame
	HitboxPart.Parent = Config.HitboxVisible and workspace or nil
	if not firetouchinterest then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			if root and (root.Position - handle.Position).Magnitude <= Config.HitboxSize / 2 then
				for _, part in ipairs(plr.Character:GetChildren()) do
					if part:IsA("BasePart") then
						pcall(firetouchinterest, part, handle, 0)
						pcall(firetouchinterest, part, handle, 1)
					end
				end
			end
		end
	end
end
local autoRotateState = nil
local function spinStep(dt)
	if not Config.Spin or not Humanoid or not HRP then
		if Humanoid and autoRotateState ~= nil then
			Humanoid.AutoRotate = autoRotateState
			autoRotateState = nil
		end
		return
	end
	if autoRotateState == nil then autoRotateState = Humanoid.AutoRotate end
	Humanoid.AutoRotate = false
	local vel = HRP.AssemblyLinearVelocity or HRP.Velocity
	HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad((Config.SpinSpeed or 2160) * dt), 0)
	pcall(function() HRP.AssemblyLinearVelocity = vel end)
end
local function spamStep()
	if not Config.SpamSword then return end
	local tool = Character and Character:FindFirstChildOfClass("Tool")
	if tool then pcall(function() tool:Activate() end) end
end
local PathfindingService = game:GetService("PathfindingService")
local Debris = game:GetService("Debris")
local TP = {
	Enabled = true,
	MobileMode = false,
	TriggerKey = Enum.KeyCode.R,
	TimePerWaypoint = 0.06,
	Effect = "Lightning",
}
local dirtCache, visCache = {}, {}
local activeTeleportId = 0
local agentParams = {
	AgentRadius = 1.0,
	AgentHeight = 5.0,
	AgentCanJump = true,
	AgentCanClimb = true,
	AgentMaxSlope = 89,
	WaypointSpacing = math.huge,
}
local function disableDirts()
	dirtCache = {}
	local folder = workspace:FindFirstChild("Dirts")
	if not folder then return end
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			dirtCache[part] = part.CanCollide
			part.CanCollide = false
		end
	end
end
local function restoreDirts()
	for part, was in pairs(dirtCache) do
		if part and part.Parent then part.CanCollide = was end
	end
	dirtCache = {}
end
local function restoreVis()
	for inst, t in pairs(visCache) do
		if inst then inst.Transparency = t end
	end
	visCache = {}
end
local function setInvisible(char)
	if next(visCache) then restoreVis() end
	visCache = {}
	for _, d in pairs(char:GetDescendants()) do
		if (d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture")) and d.Transparency < 1 then
			visCache[d] = d.Transparency
			d.Transparency = 1
		end
	end
end
local function spawnFadePart(cframe, size, color, material, duration, shape)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CFrame = cframe
	p.Size = size
	p.Color = color
	p.Material = material
	if shape then p.Shape = shape end
	p.Parent = workspace
	TweenService:Create(p, TweenInfo.new(duration), { Transparency = 1, Size = size * 0.1 }):Play()
	Debris:AddItem(p, duration + 0.1)
end
local Effects = {}
Effects.Lightning = {
	Start = function() end,
	Update = function(p1, p2)
		local dist = (p2 - p1).Magnitude
		if dist < 0.1 then return end
		local core = Instance.new("Part")
		core.Anchored = true
		core.CanCollide = false
		core.Material = Enum.Material.Neon
		core.Color = Color3.new(1, 1, 1)
		core.Size = Vector3.new(0.2, 0.2, dist)
		core.CFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -dist / 2)
		core.Parent = workspace
		TweenService:Create(core, TweenInfo.new(0.3), { Transparency = 1, Size = Vector3.new(0, 0, dist) }):Play()
		Debris:AddItem(core, 0.35)
		local glow = core:Clone()
		glow.Color = Color3.fromRGB(40, 200, 255)
		glow.Size = Vector3.new(0.6, 0.6, dist)
		glow.Transparency = 0.4
		glow.Parent = workspace
		TweenService:Create(glow, TweenInfo.new(0.3), { Transparency = 1 }):Play()
		Debris:AddItem(glow, 0.35)
	end,
	Impact = function(pos)
		local f = Instance.new("Part")
		f.Transparency = 1
		f.Anchored = true
		f.CanCollide = false
		f.Position = pos
		f.Parent = workspace
		local light = Instance.new("PointLight")
		light.Range = 20
		light.Brightness = 5
		light.Color = Color3.fromRGB(100, 255, 255)
		light.Parent = f
		Debris:AddItem(f, 0.2)
	end,
}
Effects.Fireball = {
	Start = function(lead)
		local fire = Instance.new("Fire")
		fire.Size = 8
		fire.Heat = 20
		fire.Parent = lead
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 100, 0)
		light.Range = 30
		light.Parent = lead
	end,
	Update = function(p1, p2)
		local dist = (p2 - p1).Magnitude
		if dist < 0.5 then return end
		spawnFadePart(CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -dist / 2), Vector3.new(2, 2, dist), Color3.fromRGB(255, 80, 0), Enum.Material.Neon, 0.5)
	end,
	Impact = function(pos)
		local exp = Instance.new("Explosion")
		exp.Position = pos
		exp.BlastRadius = 0
		exp.BlastPressure = 0
		exp.Parent = workspace
	end,
}
Effects.Sonic = {
	Start = function(lead)
		lead.Color = Color3.new(1, 1, 1)
		lead.Material = Enum.Material.Neon
		lead.Transparency = 0.2
	end,
	Update = function(p1, p2)
		if math.random() > 0.7 then
			local ring = Instance.new("Part")
			ring.Shape = Enum.PartType.Cylinder
			ring.Anchored = true
			ring.CanCollide = false
			ring.Material = Enum.Material.Neon
			ring.Color = Color3.new(1, 1, 1)
			ring.Size = Vector3.new(0.2, 6, 6)
			ring.CFrame = CFrame.lookAt(p1, p2) * CFrame.Angles(0, math.pi / 2, 0)
			ring.Parent = workspace
			TweenService:Create(ring, TweenInfo.new(0.5), { Size = Vector3.new(0, 15, 15), Transparency = 1 }):Play()
			Debris:AddItem(ring, 0.5)
		end
	end,
	Impact = function(pos)
		local ring = Instance.new("Part")
		ring.Shape = Enum.PartType.Ball
		ring.Size = Vector3.new(1, 1, 1)
		ring.Position = pos
		ring.Anchored = true
		ring.CanCollide = false
		ring.Material = Enum.Material.Neon
		ring.Transparency = 0.5
		ring.Parent = workspace
		TweenService:Create(ring, TweenInfo.new(0.4), { Size = Vector3.new(40, 40, 40), Transparency = 1 }):Play()
		Debris:AddItem(ring, 0.4)
	end,
}
Effects.Void = {
	Start = function(lead)
		local p = Instance.new("ParticleEmitter")
		p.Texture = "rbxassetid://243098098"
		p.Color = ColorSequence.new(Color3.new(0, 0, 0))
		p.Size = NumberSequence.new(3)
		p.Rate = 80
		p.Speed = NumberRange.new(0)
		p.Lifetime = NumberRange.new(1)
		p.Parent = lead
	end,
	Update = function(p1, p2)
		local dist = (p2 - p1).Magnitude
		if dist < 0.5 then return end
		spawnFadePart(CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -dist / 2), Vector3.new(3, 3, dist), Color3.new(0, 0, 0), Enum.Material.ForceField, 0.8)
	end,
	Impact = function(pos)
		local orb = Instance.new("Part")
		orb.Shape = Enum.PartType.Ball
		orb.Color = Color3.new(0, 0, 0)
		orb.Material = Enum.Material.Neon
		orb.Size = Vector3.new(20, 20, 20)
		orb.Position = pos
		orb.Anchored = true
		orb.CanCollide = false
		orb.Parent = workspace
		TweenService:Create(orb, TweenInfo.new(0.5), { Size = Vector3.new(0, 0, 0) }):Play()
		Debris:AddItem(orb, 0.6)
	end,
}
Effects.Crazy = {
	Start = function(lead)
		Instance.new("Sparkles", lead).SparkleColor = Color3.fromRGB(255, 0, 255)
	end,
	Update = function(p1, p2)
		local dist = (p2 - p1).Magnitude
		local col = Color3.fromHSV(tick() % 1, 1, 1)
		spawnFadePart(CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -dist / 2), Vector3.new(math.random(1, 3), math.random(1, 3), dist), col, Enum.Material.Neon, 0.6)
	end,
	Impact = function(pos)
		for _ = 1, 12 do
			local p = Instance.new("Part")
			p.Size = Vector3.new(1, 1, 1)
			p.Position = pos
			p.Anchored = false
			p.CanCollide = true
			p.Color = Color3.fromHSV(math.random(), 1, 1)
			p.AssemblyLinearVelocity = Vector3.new(math.random(-50, 50), math.random(50, 100), math.random(-50, 50))
			p.Parent = workspace
			Debris:AddItem(p, 2)
		end
	end,
}
Effects.Quantum = {
	Start = function(lead)
		Instance.new("Sparkles", lead).SparkleColor = Color3.fromRGB(0, 255, 255)
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(170, 0, 255)
		light.Range = 20
		light.Parent = lead
	end,
	Update = function(p1, p2)
		if math.random() > 0.3 then
			local ring = Instance.new("Part")
			ring.Shape = Enum.PartType.Cylinder
			ring.Size = Vector3.new(0.5, 5, 5)
			ring.Color = Color3.fromRGB(85, 0, 255)
			ring.Material = Enum.Material.Neon
			ring.Anchored = true
			ring.CanCollide = false
			ring.CFrame = CFrame.lookAt(p2, p1) * CFrame.Angles(0, math.pi / 2, 0)
			ring.Parent = workspace
			TweenService:Create(ring, TweenInfo.new(0.6), { Size = Vector3.new(0, 15, 15), Transparency = 1 }):Play()
			Debris:AddItem(ring, 0.6)
		end
	end,
	Impact = function(pos)
		local orb = Instance.new("Part")
		orb.Shape = Enum.PartType.Ball
		orb.Color = Color3.fromRGB(0, 0, 0)
		orb.Material = Enum.Material.Neon
		orb.Size = Vector3.new(30, 30, 30)
		orb.Position = pos
		orb.Anchored = true
		orb.CanCollide = false
		orb.Transparency = 0.2
		orb.Parent = workspace
		TweenService:Create(orb, TweenInfo.new(0.3), { Size = Vector3.new(0, 0, 0) }):Play()
		Debris:AddItem(orb, 0.4)
	end,
}
local function moveToPath(destination)
	local char = LP.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not hrp then return end
	activeTeleportId += 1
	local myId = activeTeleportId
	if next(visCache) then restoreVis() end
	local path = PathfindingService:CreatePath(agentParams)
	disableDirts()
	local ok = pcall(function() path:ComputeAsync(hrp.Position, destination) end)
	restoreDirts()
	if not ok or path.Status ~= Enum.PathStatus.Success then
		notify("TP", "path failed")
		return
	end
	local waypoints = path:GetWaypoints()
	local totalDuration = math.max(1, #waypoints - 1) * (TP.TimePerWaypoint or 0.06)
	hrp.Anchored = false
	if humanoid then
		humanoid.PlatformStand = true
		humanoid.AutoRotate = false
	end
	setInvisible(char)
	local startPos = hrp.Position
	local lead = Instance.new("Part")
	lead.Transparency = 1
	lead.Size = Vector3.new(1, 1, 1)
	lead.CanCollide = false
	lead.Anchored = true
	lead.Position = startPos
	lead.Parent = workspace
	lead.CFrame = CFrame.lookAt(startPos, destination) * CFrame.Angles(math.rad(-90), 0, 0)
	local cam = workspace.CurrentCamera
	cam.CameraSubject = lead
	local EffectModule = Effects[TP.Effect] or Effects.Lightning
	if EffectModule.Start then EffectModule.Start(lead) end
	local elapsed, prev, completed = 0, startPos, false
	local startRot = hrp.CFrame.Rotation
	local hip = 3.0
	if humanoid then
		hip = (humanoid.RigType == Enum.HumanoidRigType.R15) and (humanoid.HipHeight + hrp.Size.Y / 2) or 3.0
	end
	local conn
	conn = RunS.Heartbeat:Connect(function(dt)
		if activeTeleportId ~= myId or not char.Parent or not hrp.Parent then
			conn:Disconnect()
			lead:Destroy()
			if humanoid then cam.CameraSubject = humanoid end
			restoreVis()
			return
		end
		elapsed += dt
		local progress = math.clamp(elapsed / totalDuration, 0, 1)
		local leadPos = startPos:Lerp(destination, progress)
		lead.Position = leadPos
		EffectModule.Update(prev, leadPos)
		prev = leadPos
		local segFloat = elapsed / (TP.TimePerWaypoint or 0.06)
		local segIdx = math.floor(segFloat) + 1
		local nextPos
		if segIdx >= #waypoints then
			nextPos = waypoints[#waypoints].Position
			completed = true
		else
			local alpha = segFloat - math.floor(segFloat)
			nextPos = waypoints[segIdx].Position:Lerp(waypoints[segIdx + 1].Position, alpha)
		end
		hrp.CFrame = CFrame.new(nextPos + Vector3.new(0, hip, 0)) * startRot
		hrp.AssemblyLinearVelocity = Vector3.zero
		if completed then
			conn:Disconnect()
			EffectModule.Impact(destination)
			if humanoid then
				humanoid.PlatformStand = false
				humanoid.AutoRotate = true
				cam.CameraSubject = humanoid
			end
			restoreVis()
			lead:Destroy()
		end
	end)
end
UIS.InputBegan:Connect(function(input, gp)
	if gp or not TP.Enabled then return end
	local isClick = input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
	if not isClick then return end
	local go = TP.MobileMode or UIS:IsKeyDown(TP.TriggerKey)
	if not go then return end
	local mouse = UIS:GetMouseLocation()
	local ray = Cam:ViewportPointToRay(mouse.X, mouse.Y)
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 5000, RaycastParams.new())
	if hit then moveToPath(hit.Position) end
end)
local ESP = {
	Enabled = false,
	Boxes = true,
	Names = true,
	TeamCheck = true,
	Color = Color3.fromRGB(96, 165, 250),
	EnemyColor = Color3.fromRGB(255, 70, 70),
}
local espFolder = Instance.new("Folder")
espFolder.Name = "TEMPO_ESP"
pcall(function() espFolder.Parent = game:GetService("CoreGui") end)
local espObjects = {}
local function clearPlayerESP(plr)
	local t = espObjects[plr]
	if not t then return end
	for _, o in pairs(t) do
		pcall(function() o:Destroy() end)
	end
	espObjects[plr] = nil
end
local function clearAllESP()
	for plr in pairs(espObjects) do
		clearPlayerESP(plr)
	end
end
local function makeBillboard(adornee, text, color)
	local bb = Instance.new("BillboardGui")
	bb.Name = "TEMPO_Name"
	bb.AlwaysOnTop = true
	bb.Size = UDim2.fromOffset(120, 20)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.Adornee = adornee
	bb.Parent = espFolder
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextColor3 = color
	lbl.TextStrokeTransparency = 0.4
	lbl.Text = text
	lbl.Parent = bb
	return bb
end
local function makeBox(char, color)
	local box = Instance.new("SelectionBox")
	box.Name = "TEMPO_Box"
	box.LineThickness = 0.03
	box.Color3 = color
	box.SurfaceTransparency = 0.85
	box.SurfaceColor3 = color
	box.Adornee = char
	box.Parent = espFolder
	return box
end
local function shouldESP(plr)
	if plr == LP then return false end
	if not plr.Character then return false end
	local hum = plr.Character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if ESP.TeamCheck and plr.Team and LP.Team and plr.Team == LP.Team then
		return false
	end
	return true
end
local function refreshESP()
	if not ESP.Enabled then
		clearAllESP()
		return
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if shouldESP(plr) then
			local char = plr.Character
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")
			local color = (LP.Team and plr.Team and plr.Team == LP.Team) and ESP.Color or ESP.EnemyColor
			if not LP.Team or not plr.Team then
				color = ESP.EnemyColor
			end
			local pack = espObjects[plr]
			if not pack then
				pack = {}
				espObjects[plr] = pack
			end
			if ESP.Boxes then
				if not pack.box or not pack.box.Parent then
					pack.box = makeBox(char, color)
				else
					pack.box.Adornee = char
					pack.box.Color3 = color
					pack.box.SurfaceColor3 = color
				end
			elseif pack.box then
				pack.box:Destroy()
				pack.box = nil
			end
			if ESP.Names and hrp then
				local label = plr.Name
				if hum then label = string.format("%s [%.0f]", plr.Name, hum.Health) end
				if not pack.name or not pack.name.Parent then
					pack.name = makeBillboard(hrp, label, color)
				else
					pack.name.Adornee = hrp
					local lbl = pack.name:FindFirstChildOfClass("TextLabel")
					if lbl then
						lbl.Text = label
						lbl.TextColor3 = color
					end
				end
			elseif pack.name then
				pack.name:Destroy()
				pack.name = nil
			end
		else
			clearPlayerESP(plr)
		end
	end
end
Players.PlayerRemoving:Connect(clearPlayerESP)
local function ensureTab(name, icon)
	if tabs[name] then return tabs[name] end
	local icons = { Main = "home", Combat = "crosshair", Visuals = "eye", Player = "user", Settings = "sliders" }
	local ok, tab = pcall(function() return UI:Tab(name, icon or icons[name] or "circle") end)
	if ok and tab then tabs[name] = tab return tab end
end
local function sectionApi(tab)
	local api = {}
	function api:Toggle(opts)
		opts = opts or {}
		local flag, default = opts.Flag, opts.Default
		if default == nil then default = false end
		if flag then setFlag(flag, default and true or false) end
		pcall(function()
			tab:Toggle(opts.Name or flag or "Toggle", default and true or false, function(v)
				if flag then setFlag(flag, v and true or false) end
				if opts.Callback then pcall(opts.Callback, v and true or false) end
			end)
		end)
		return api
	end
	function api:Slider(opts)
		opts = opts or {}
		local flag = opts.Flag
		local min, max = tonumber(opts.Min) or 0, tonumber(opts.Max) or 100
		local default = tonumber(opts.Default) or min
		if flag then Flags[flag] = default end
		pcall(function()
			tab:Slider(opts.Name or flag or "Slider", min, max, default, function(v)
				if flag then Flags[flag] = v end
				if opts.Callback then pcall(opts.Callback, v) end
			end)
		end)
		return api
	end
	function api:Dropdown(opts)
		opts = opts or {}
		local flag, items = opts.Flag, opts.Items or {}
		local default = opts.Default or items[1]
		if flag then Flags[flag] = default end
		pcall(function()
			if tab.Dropdown then
				tab:Dropdown(opts.Name or flag or "Dropdown", items, default, function(v)
					if flag then Flags[flag] = v end
					if opts.Callback then pcall(opts.Callback, v) end
				end)
			else
				for _, item in ipairs(items) do
					local cap = item
					tab:Button(tostring(cap), false, function()
						if flag then Flags[flag] = cap end
						if opts.Callback then pcall(opts.Callback, cap) end
					end)
				end
			end
		end)
		return api
	end
	function api:Label(opts)
		pcall(function() tab:Label((opts and (opts.Text or opts.Name)) or "") end)
		return api
	end
	function api:Button(opts)
		opts = opts or {}
		pcall(function()
			tab:Button(opts.Name or "Button", false, function()
				if opts.Callback then pcall(opts.Callback) end
			end)
		end)
		return api
	end
	return api
end
local pageApi = {}
function pageApi:Section(opts)
	local tab = self._tab
	pcall(function() tab:Section((opts and opts.Name) or "Section") end)
	return sectionApi(tab)
end
local windowApi = {}
function windowApi:Page(opts)
	return setmetatable({ _tab = ensureTab((opts and opts.Name) or "Tab") }, { __index = pageApi })
end
pcall(function()
	if UI.Boot then
		UI:Boot({ "executor", "interface", "combat", "ready" }, function()
			UI:Notify("TEMPO | Underground War", "good")
		end)
	else
		UI:Notify("TEMPO | Underground War", "good")
	end
end)
local MainPage = windowApi:Page({ Name = "Main" })
local CombatPage = windowApi:Page({ Name = "Combat" })
local VisualsPage = windowApi:Page({ Name = "Visuals" })
local PlayerPage = windowApi:Page({ Name = "Player" })
local SettingsPage = windowApi:Page({ Name = "Settings" })
do
	local F = MainPage:Section({ Name = "Quick" })
	F:Toggle({ Name = "Silent Aim", Flag = "Silent Aim", Default = false, Callback = function(v) Config.SilentAim = v end })
	F:Toggle({ Name = "Aimbot (auto shot)", Flag = "Aimbot", Default = false, Callback = function(v) Config.Aimbot = v end })
	F:Toggle({ Name = "Team Check", Flag = "Team Check", Default = true, Callback = function(v) Config.TeamCheck = v end })
	F:Button({ Name = "Shoot Closest", Callback = shootClosest })
end
do
	local F = CombatPage:Section({ Name = "Aim" })
	F:Toggle({ Name = "Silent Aim", Flag = "Silent Aim", Default = false, Callback = function(v) Config.SilentAim = v end })
	F:Toggle({ Name = "Aimbot (auto shot)", Flag = "Aimbot", Default = false, Callback = function(v) Config.Aimbot = v end })
	F:Toggle({ Name = "Team Check", Flag = "Team Check", Default = true, Callback = function(v) Config.TeamCheck = v end })
	F:Toggle({ Name = "Wall Check", Flag = "Wall Check", Default = false, Callback = function(v) Config.WallCheck = v end })
	F:Slider({ Name = "Kill Distance", Flag = "Kill Distance", Min = 50, Max = 5000, Default = 5000,
		Callback = function(v) Config.KillDistance = v end })
	F:Slider({ Name = "FOV", Flag = "FOV", Min = 20, Max = 600, Default = 180,
		Callback = function(v) Config.FOV = v end })
	F:Slider({ Name = "Prediction", Flag = "Prediction", Min = 0, Max = 50, Default = 0,
		Callback = function(v) Config.Prediction = v end })
	F:Dropdown({ Name = "Target Part", Flag = "Target Part",
		Items = { "HumanoidRootPart", "Head", "Torso", "UpperTorso" },
		Default = "HumanoidRootPart",
		Callback = function(v) Config.TargetPart = tostring(v) end })
	F:Button({ Name = "Shoot Closest", Callback = shootClosest })
end
do
	local F = CombatPage:Section({ Name = "Sword / Melee" })
	F:Toggle({ Name = "Hitbox Expander", Flag = "Hitbox", Default = false, Callback = function(v) Config.Hitbox = v end })
	F:Toggle({ Name = "Hitbox Visible", Flag = "Hitbox Visible", Default = true, Callback = function(v) Config.HitboxVisible = v end })
	F:Slider({ Name = "Hitbox Size", Flag = "Hitbox Size", Min = 5, Max = 120, Default = 50,
		Callback = function(v) Config.HitboxSize = v end })
	F:Toggle({ Name = "Spam Sword", Flag = "Spam Sword", Default = false, Callback = function(v) Config.SpamSword = v end })
	F:Toggle({ Name = "Spin", Flag = "Spin", Default = false, Callback = function(v) Config.Spin = v end })
	F:Slider({ Name = "Spin Speed", Flag = "Spin Speed", Min = 360, Max = 4320, Default = 2160,
		Callback = function(v) Config.SpinSpeed = v end })
end
do
	local F = VisualsPage:Section({ Name = "ESP" })
	F:Toggle({ Name = "ESP Enabled", Flag = "ESP Enabled", Default = false, Callback = function(v)
		ESP.Enabled = v
		if not v then clearAllESP() end
	end })
	F:Toggle({ Name = "Boxes", Flag = "ESP Boxes", Default = true, Callback = function(v) ESP.Boxes = v end })
	F:Toggle({ Name = "Nametags", Flag = "ESP Names", Default = true, Callback = function(v) ESP.Names = v end })
	F:Toggle({ Name = "Team Check", Flag = "ESP Team Check", Default = true, Callback = function(v) ESP.TeamCheck = v end })
end
do
	local F = VisualsPage:Section({ Name = "FOV" })
	F:Toggle({ Name = "Show FOV Circle", Flag = "Show FOV", Default = false, Callback = function(v) Config.ShowFOV = v end })
	F:Label({ Text = "Red crosshair locks on current target" })
end
do
	local F = PlayerPage:Section({ Name = "Path Teleport" })
	F:Toggle({ Name = "Enable Path TP", Flag = "Path TP", Default = true, Callback = function(v) TP.Enabled = v end })
	F:Toggle({ Name = "Mobile Mode (tap)", Flag = "Mobile TP", Default = false, Callback = function(v) TP.MobileMode = v end })
	F:Slider({ Name = "Travel Speed (sec/node)", Flag = "TP Speed", Min = 0.04, Max = 0.2, Default = 0.06,
		Callback = function(v) TP.TimePerWaypoint = v end })
	F:Dropdown({ Name = "TP Effect", Flag = "TP Effect",
		Items = { "Lightning", "Fireball", "Sonic", "Void", "Crazy", "Quantum" },
		Default = "Lightning",
		Callback = function(v) TP.Effect = tostring(v) end })
	F:Label({ Text = "PC: hold R + left click | Mobile: enable Mobile Mode + tap" })
end
do
	local F = PlayerPage:Section({ Name = "Character" })
	F:Label({ Text = "Spin lives under Combat" })
end
do
	local F = SettingsPage:Section({ Name = "Config" })
	F:Button({ Name = "Unload", Callback = function()
		Config.Aimbot = false
		Config.SilentAim = false
		Config.Hitbox = false
		Config.Spin = false
		Config.SpamSword = false
		HitboxPart.Parent = nil
		if fovCircle then fovCircle.Visible = false end
		if crossLines then for _, l in ipairs(crossLines) do l.Visible = false end end
		clearAllESP()
		pcall(function() espFolder:Destroy() end)
		pcall(function() if UI.Destroy then UI:Destroy() end end)
	end })
	F:Label({ Text = "Tempo Hub UI · ShotTarget silent · no webhooks" })
end
do
	local sg = Instance.new("ScreenGui")
	sg.Name = "TEMPO_MobileShoot"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	pcall(function() sg.Parent = LP:WaitForChild("PlayerGui") end)
	local btn = Instance.new("TextButton")
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.Position = UDim2.new(0.92, 0, 0.65, 0)
	btn.Size = UDim2.fromOffset(72, 72)
	btn.BackgroundColor3 = Color3.fromRGB(22, 27, 38)
	btn.Text = "SHOOT"
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(96, 165, 250)
	btn.TextSize = 14
	btn.Parent = sg
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
	local stroke = Instance.new("UIStroke", btn)
	stroke.Color = Color3.fromRGB(96, 165, 250)
	stroke.Thickness = 2
	btn.MouseButton1Click:Connect(shootClosest)
end
RunS.Heartbeat:Connect(function(dt)
	pcall(silentStep)
	pcall(hitboxStep)
	pcall(spinStep, dt)
	pcall(updateDrawings)
	pcall(refreshESP)
end)
task.spawn(function()
	while true do
		pcall(spamStep)
		task.wait(0.08)
	end
end)
pcall(function()
	local function hookTool(tool)
		if not tool:IsA("Tool") then return end
		tool.Activated:Connect(function()
			if not Config.SilentAim then return end
			local target = getClosest()
			if not target or not target.Character then return end
			local part = getTargetPart(target.Character)
			if part then
				local pos = part.Position
				if Config.Prediction > 0 then
					local vel = part.AssemblyLinearVelocity or Vector3.zero
					pos = pos + vel * (Config.Prediction / 100)
				end
				fireShot(pos, tool.Name)
			end
		end)
	end
	if Character then
		for _, t in ipairs(Character:GetChildren()) do hookTool(t) end
	end
	LP.CharacterAdded:Connect(function(c)
		c.ChildAdded:Connect(hookTool)
		task.wait(0.5)
		for _, t in ipairs(c:GetChildren()) do hookTool(t) end
	end)
	if Character then Character.ChildAdded:Connect(hookTool) end
end)
notify("TEMPO", string.format("Underground War ready (%.2fs)", os.clock() - t0))
select("#", "[TEMPO] Underground War loaded", string.format("%.2fs", os.clock() - t0))
pcall(function() UI:mountInterface(UI:Tab("Interface", "sliders")) end)
