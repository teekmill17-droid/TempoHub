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
local function geniter(f, s, c)
	if type(f) ~= "function" then
		local mt = getmetatable(f)
		if type(mt) == "table" and mt.__iter then
			f, s, c = mt.__iter(f)
		elseif type(f) == "table" then
			f, s, c = next, f, nil
		end
	end
	return function()
		local r = table.pack(f(s, c))
		if r[1] == nil then
			return false
		end
		c = r[1]
		return true, table.unpack(r, 1, r.n)
	end
end
local n1 = 677870210
local n2 = 352572318
local n3 = 660935885
local n4 = 666560820
local n5 = 403422737
local n6
local TeekUI = assert(loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))(), "TempoUI failed")
local UI
local SINK
SINK = setmetatable({}, { __index = function() return function() return SINK end end })
local function wrap(t) return setmetatable(t, { __index = function() return function() return SINK end end }) end
local function TempoLib2()
	local lib = wrap({ Scheme = {} })
	function lib:Notify(o)
		o = type(o) == "table" and o or { Description = tostring(o) }
		local text = tostring(o.Title or "Tempo") .. (o.Description and (": " .. tostring(o.Description)) or "")
		pcall(function() UI:Notify(text, "info", tonumber(o.Duration) or 3) end)
	end
	function lib:CreateWindow()
		UI = TeekUI.new({ Title = "TEMPO", Subtitle = "Violence District", Version = "v1" })
		local win = wrap({})
		function win:CreateTab(name)
			if name == "Settings" then return SINK end
			local tab = UI:Tab(name)
			local t = wrap({})
			function t:CreatePage() return t end
			function t:CreateSection(title)
				tab:Section(title)
				local card = tab.cur
				local function run(f, ...)
					local c, l = tab.cur, tab.last
					tab.cur, tab.last = card, nil
					local out = table.pack(pcall(f, tab, ...))
					tab.cur, tab.last = c, l
					if not out[1] then error(out[2], 2) end
					return table.unpack(out, 2, out.n)
				end
				local sec = wrap({})
				function sec:AddToggle(label, default, cb)
					local h = run(tab.Toggle, label, default == true, cb)
					local e = wrap({})
					function e:SetValue(v) h.Set(v == true) end
					e.Set = e.SetValue
					function e:GetValue() return h.Get() end
					function e:AddColorPicker(default2, o)
						o = o or {}
						return run(tab.Color, o.Title or (label .. " Color"), default2, o.Callback)
					end
					return e
				end
				sec.AddCheckbox = sec.AddToggle
				function sec:AddSlider(label, min, max, default, cb)
					return run(tab.Slider, label, min, max, math.clamp(tonumber(default) or min, min, max), cb)
				end
				function sec:AddButton(label, cb) return run(tab.Button, label, false, cb) end
				function sec:AddTextbox(label, _, cb) return run(tab.Input, label, "", cb) end
				function sec:AddKeybind(label, default, cb) return run(tab.Keybind, label, default, cb) end
				function sec:AddDropdown(label, list, default, cb)
					local h = run(tab.Dropdown, label, list or {}, type(default) == "string" and default or nil, cb)
					local e = wrap({})
					local function items(a, b) h.SetItems((a == e) and b or a) end
					e.Refresh, e.SetValues, e.SetOptions, e.Update = items, items, items, items
					function e:SetValue(v) h.Set(v) end
					return e
				end
				return sec
			end
			return t
		end
		return win
	end
	return lib
end
local function v11()
	n6 = 295005065
	local lib2 = TempoLib2()
	lib2.Scheme.AccentColor = Color3.fromRGB(255, 255, 255)
	lib2.Scheme.BackgroundColor = Color3.fromRGB(10, 10, 12)
	lib2.Scheme.MainColor = Color3.fromRGB(16, 16, 18)
	lib2.Scheme.OutlineColor = Color3.fromRGB(255, 255, 255)
	lib2.Scheme.FontColor = Color3.fromRGB(235, 235, 240)
	local n7 = 542746161
	lib2.Scheme.SubTextColor = Color3.fromRGB(140, 140, 150)
	lib2.Scheme.HoverColor = Color3.fromRGB(22, 22, 26)
	local v14 = lib2:CreateWindow({
		Title = "Tempo Hub",
		Subtitle = "Violance District",
		SubtitleColor = Color3.fromRGB(190, 140, 255),
		Logo = "rbxassetid://118755181202304",
		LogoSize = 32,
		SphereText = false,
		SphereWords = "ZX",
		SphereImage = "rbxassetid://118755181202304",
		SphereIconSize = 38,
		Watermark = true,
		WatermarkText = "TEMPO",
		WatermarkIcon = "rbxassetid://118755181202304"
	})
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local v17 = LocalPlayer
	local v18 = LocalPlayer
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local VirtualInputManager = game:GetService("VirtualInputManager")
	local GuiService = game:GetService("GuiService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local CoreGui = game:GetService("CoreGui")
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local CollectionService = game:GetService("CollectionService")
	local HttpService = game:GetService("HttpService")
	game:GetService("TeleportService")
	local TweenService = game:GetService("TweenService")
	_G.Ox = {}
	_G.Ox.AntiBlindEnabled = false
	_G.Ox.GotBlindedRemote = nil
	_G.Ox.NoSlowdownEnabled = false
	_G.Ox.BypassLeapEnabled = false
	_G.Ox.InfAbyssalEnabled = false
	_G.Ox.KILLER_SilentAimFlask = false
	_G.Ox.KILLER_FlaskLaser = false
	_G.Ox.NEX_CureFlaskLaserThread = nil
	_G.Ox.NEX_CureFlaskLaserPart = nil
	_G.Ox.InfiniteLungeEnabled = false
	do
		local t1 = {
			["122812055447896"] = "Veil lunge",
			["133963973694098"] = "Mayers Basic",
			["117042998468241"] = "Mayers lunge",
			["135002183282873"] = "cure lunge",
			["121216847022485"] = "cure Basic",
			["132817836308238"] = "Jeff Basic",
			["129784271201071"] = "Jeff lunge",
			["82666958311998"] = "Jeff Frenzy",
			["78432063483146"] = "Abyssal Basic",
			["118907603246885"] = "Abyssal lunge",
			["139369275981139"] = "Jason Basic",
			["110355011987939"] = "Jason lunge",
			["111920872708571"] = "Masked Basic",
			["105374834496520"] = "Masked lunge",
			["138720291317243"] = "Masked Tony",
			["106871536134254"] = "Masked Alex",
			["130593238885843"] = "Masked Cobra",
			["115244153053858"] = "Masked Cobra lunge",
			["74968262036854"] = "Hidden Basic",
			["113255068724446"] = "Hidden lunge",
			["98163597193511"] = "Hidden S1",
			["80411309607666"] = "Abyssal S1"
		}
		_G.Ox.ParryConfig = {
			AutoParry = false,
			ParrySafety = false,
			ParryAggressive = false,
			ParryCircle = true,
			ParryRadius = 15,
			ParryFace = 0.7,
			AutoCrouch = false,
			Ignored_Skills = {}
		}
		_G.Ox.ParryV2 = {
			Enabled = false,
			SafetyParry = false,
			Mode = "Legit",
			Trigger = "Remote",
			Range = 12,
			KillerFace = 0.6,
			ShowCircle = true,
			IsOnCooldown = false,
			IsResolving = false,
			CooldownToken = 0,
			CooldownThread = nil,
			Attached = {},
			Gradients = {},
			Icon = nil,
			LockConnection = nil,
			ParryTrack = nil,
			RangeAdornment = nil,
			BtnCache = nil
		}
		_G.Ox.ParryV2Anim = {
			Default = "rbxassetid://109133187196613",
			Shield = "rbxassetid://75939529748815",
			Robot = "rbxassetid://126894569253341",
			Katana = "rbxassetid://127096285501517",
			Fish = "rbxassetid://123307242865945",
			Watcher = "rbxassetid://81793464499285",
			Enten = "rbxassetid://127096285501517",
			BloodShield = "rbxassetid://75939529748815",
			Fih = "rbxassetid://123307242865945",
			Feedbacker = "rbxassetid://126894569253341",
			StopWatch = "rbxassetid://81793464499285"
		}
		_G.Ox.ParryV2AttackAnims = {
			["rbxassetid://78432063483146"] = true,
			["rbxassetid://121216847022485"] = true,
			["rbxassetid://74968262036854"] = true,
			["rbxassetid://132817836308238"] = true,
			["rbxassetid://82666958311998"] = true,
			["rbxassetid://111920872708571"] = true,
			["rbxassetid://106871536134254"] = true,
			["rbxassetid://109402730355822"] = true,
			["rbxassetid://130593238885843"] = true,
			["rbxassetid://138720291317243"] = true,
			["rbxassetid://139369275981139"] = true,
			["rbxassetid://133963973694098"] = true,
			["rbxassetid://78935059863801"] = true,
			["rbxassetid://118907603246885"] = true,
			["rbxassetid://135002183282873"] = true,
			["rbxassetid://113255068724446"] = true,
			["rbxassetid://129784271201071"] = true,
			["rbxassetid://105374834496520"] = true,
			["rbxassetid://117070354890871"] = true,
			["rbxassetid://115244153053858"] = true,
			["rbxassetid://110355011987939"] = true,
			["rbxassetid://117042998468241"] = true,
			["rbxassetid://122812055447896"] = true
		}
		_G.Ox._V2RayParams = RaycastParams.new()
		_G.Ox._V2RayParams.FilterType = Enum.RaycastFilterType.Exclude
		_G.Ox._V2ParryRangeRay = RaycastParams.new()
		_G.Ox._V2ParryRangeRay.FilterType = Enum.RaycastFilterType.Exclude
		_G.Ox._V2ParryLastRadius = -1
		_G.Ox._V2ParryLastRoot = nil
		_G.Ox.AttachedParry = {}
		if not _G.Ox.State then
			_G.Ox.State = {}
		end
		_G.Ox.State.ParryCooldown = false
		_G.Ox.State.ParryCooldownTime = 60
		_G.Ox.State.AutoParryAdornment = nil
		_G.Ox.State.ParryCooldownThread = nil
		_G.Ox.AutoParryCustom = {
			Gui = nil,
			IsActive = false,
			GuiVisible = false
		}
		_G.Ox.ParryHUD = _G.Ox.ParryHUD or {
			gradients = {},
			icon = nil,
			rescanConn = nil,
			cachedIconColor = nil
		}
		ParryHUD = _G.Ox.ParryHUD
		IsDowned = function(p1)
			if p1 then
				return p1:GetAttribute("Knocked") == true or p1:GetAttribute("IsHooked") == true
			end
			return false
		end
		IsKiller = function(p2)
			local Team = p2 and p2.Team
			return Team and p2.Team.Name == "Killer"
		end
		TriggerCrouch = function()
			if n1 == n4 then
				n1 = 290781153
				n5 -= 397
				n7 = 796501451
				n4 = 327864712
				n2 -= 1040
				n6 += 1943
				;(nil)()
			else
				pcall(function()
					local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
					for match in string.gmatch("Survivor-mob.Controls.crouch.icon", "[^%.]+") do
						PlayerGui2 = PlayerGui2 and PlayerGui2:FindFirstChild(match)
					end
					if PlayerGui2 and PlayerGui2:IsA("GuiObject") and PlayerGui2.Visible then
						if not PlayerGui2.Parent then
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
							task.wait(1.4)
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
							return
						end
						if not PlayerGui2.Parent:IsA("GuiButton") then
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
							task.wait(1.4)
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
							return
						end
						local Parent = PlayerGui2.Parent
						if UserInputService.TouchEnabled and type(firesignal) == "function" then
							firesignal(Parent.MouseButton1Click)
							task.wait(1.4)
							firesignal(Parent.MouseButton1Click)
						else
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
							task.wait(1.4)
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
						end
					else
						VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
						task.wait(1.4)
						VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
					end
				end)
			end
		end
		IsSafeToParry = function(p3)
			if not _G.Ox.ParryConfig.ParrySafety then
				return true
			end
			if not p3 then
				return false
			end
			local CheckInterractable = p3:FindFirstChild("CheckInterractable")
			if CheckInterractable then
				if CheckInterractable:GetAttribute("isVaulting") == true then
					return false
				end
				if CheckInterractable:GetAttribute("isRepairing") == true then
					return false
				end
				if CheckInterractable:GetAttribute("isUnhooking") == true then
					return false
				end
				if CheckInterractable:GetAttribute("isHealing") == true then
					return false
				end
				if CheckInterractable:GetAttribute("isSliding") == true then
					return false
				end
			end
			if n6 < n7 then
				return true
			end
			n1 = 713763244
			n5 -= 1724
			n3 -= 406
			n2 -= 1965
			n7 -= 581
			n6 = 897230105
		end
		tapMobileParryButton = function()
			local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
			if not PlayerGui2 then
				return
			end
			local SurvivorMob = PlayerGui2:FindFirstChild("Survivor-mob")
			local GuiMob = SurvivorMob and SurvivorMob:FindFirstChild("Controls") and SurvivorMob.Controls:FindFirstChild("Gui-mob")
			if not GuiMob or not GuiMob.Visible then
				pcall(function()
					if mouse2click then
						mouse2click()
						return
					end
					if mouse2press and mouse2release then
						mouse2press()
						task.wait(0.01)
						mouse2release()
						return
					end
					VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
					task.wait(0.01)
					VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
				end)
			elseif firesignal then
				pcall(function()
					firesignal(GuiMob.MouseButton1Down)
					task.wait(0.01)
					firesignal(GuiMob.MouseButton1Up)
				end)
			end
		end
		ExecuteParry = function()
			if _G.Ox.State.ParryCooldown then
				return
			end
			local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
			local Items = Remotes and Remotes:FindFirstChild("Items")
			local ParryingDagger = Items and Items:FindFirstChild("Parrying Dagger")
			local parry = ParryingDagger and ParryingDagger:FindFirstChild("parry")
			if parry then
				for i = 1, 8 do
					parry:FireServer()
				end
			end
			task.spawn(tapMobileParryButton)
		end
		ParryHUD.Scan = function()
			local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
			if not PlayerGui2 then
				return false
			end
			table.clear(ParryHUD.gradients)
			ParryHUD.icon = nil
			for _, v in ipairs({
				"Survivor",
				"Survivor-con"
			}) do
				local v46 = PlayerGui2:FindFirstChild(v)
				if v46 then
					local Gen = v46:FindFirstChild("Gen")
					local ItemFrame = Gen and Gen:FindFirstChild("ItemFrame")
					if ItemFrame then
						local Gui = ItemFrame:FindFirstChild("Gui")
						local Bar = Gui and Gui:FindFirstChild("Bar")
						local UIGradient = Bar and Bar:FindFirstChild("UIGradient")
						if UIGradient then
							table.insert(ParryHUD.gradients, UIGradient)
						end
						local icon = ItemFrame:FindFirstChild("icon")
						if icon then
							ParryHUD.icon = icon
						end
					end
				end
			end
			local SurvivorMob = PlayerGui2:FindFirstChild("Survivor-mob")
			local Controls = SurvivorMob and SurvivorMob:FindFirstChild("Controls")
			if Controls then
				for _, child in ipairs(Controls:GetChildren()) do
					if child:IsA("ImageButton") and child.Name == "Gui-mob" then
						local Bar = child:FindFirstChild("Bar")
						local UIGradient = Bar and Bar:FindFirstChild("UIGradient")
						if UIGradient then
							table.insert(ParryHUD.gradients, UIGradient)
						end
					end
				end
			end
			return #ParryHUD.gradients > 0 or ParryHUD.icon ~= nil
		end
		ParryHUD.SetColor = function(p4)
			if not (#ParryHUD.gradients ~= 0 or ParryHUD.icon) then
				ParryHUD.Scan()
			end
			ParryHUD.cachedIconColor = p4
			for _, gradient in ipairs(ParryHUD.gradients) do
				if gradient and gradient.Parent then
					if gradient.Parent.Parent then
						local icon = gradient.Parent.Parent:FindFirstChild("icon")
						if icon then
							icon.ImageColor3 = p4
						end
						local Gui = gradient.Parent.Parent:FindFirstChild("Gui")
						if Gui then
							Gui.ImageColor3 = p4
						end
					end
				end
			end
			if ParryHUD.icon then
				ParryHUD.icon.ImageColor3 = p4
			end
		end
		ParryHUD.Tween = function(p5)
			if #ParryHUD.gradients == 0 then
				ParryHUD.Scan()
			end
			local n8 = 814517222
			local n9 = 365008311
			for _, gradient in ipairs(ParryHUD.gradients) do
				if gradient and gradient.Parent then
					gradient.Offset = Vector2.new(0, 0.75)
					local tween = TweenService:Create(gradient, TweenInfo.new(p5, Enum.EasingStyle.Linear), {
						Offset = Vector2.new(0, 0.25)
					})
					tween:Play()
					if n2 < n9 then
						tween.Completed:Connect(function()
							if not _G.Ox.State.ParryCooldown then
								ParryHUD.SetColor(Color3.fromRGB(255, 255, 255))
							end
						end)
					else
						n2 += 1301
						n5 = 87732332
						n3 += 121
						n1 = 640406008
						n8 -= 1332
						n6 = 59034877
						n7 = 699941212
						n9 += 660
						bit32.rshift(nil, nil  )
						tween[9] = 1051667195
					end
				end
			end
		end
		ParryHUD.Reset = function()
			ParryHUD.SetColor(Color3.fromRGB(255, 255, 255))
			for _, gradient in ipairs(ParryHUD.gradients) do
				if gradient and gradient.Parent then
					gradient.Offset = Vector2.new(0, 0.25)
				end
			end
		end
		ParryHUD.SetupWatcher = function()
			if ParryHUD.rescanConn then
				ParryHUD.rescanConn:Disconnect()
			end
			local n10 = 823883638
			local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
			if not PlayerGui2 then
				return
			end
			if n10 == 823883638 then
				ParryHUD.rescanConn = PlayerGui2.ChildAdded:Connect(function(child)
					local Name = child.Name
					if Name == "Survivor" or Name == "Survivor-con" or Name == "Survivor-mob" then
						task.wait(0.3)
						ParryHUD.Scan()
						if _G.Ox.State.ParryCooldown and ParryHUD.cachedIconColor then
							ParryHUD.SetColor(ParryHUD.cachedIconColor)
						end
					end
				end)
				task.spawn(function()
					local n11 = 0
					while not ParryHUD.Scan() do
						task.wait(0.5)
						n11 += 0.5
						if not (n11 < 10) then
							break
						end
					end
				end)
				return
			end
			n2 -= 1900
			n3 -= 1974
			n5 -= 974
			n1 += 1572
			n6 = 466638037
			n7 += 39
			return (nil)()
		end
		ParryHUD.SetupWatcher()
		LocalPlayer.CharacterAdded:Connect(function()
			task.wait(1.5)
			ParryHUD.Scan()
			if _G.Ox.State.ParryCooldown and ParryHUD.cachedIconColor then
				ParryHUD.SetColor(ParryHUD.cachedIconColor)
			end
		end)
		ListenToParryResult = function()
			task.spawn(function()
				local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
				local v75 = Remotes
				local parryResult
				if v75 then
					local ParryingDagger = Remotes:WaitForChild("Items", 5):WaitForChild("Parrying Dagger", 5)
					parryResult = ParryingDagger and ParryingDagger:WaitForChild("parryResult", 5)
				else
					parryResult = v75
				end
				local n12 = 381447214
				if parryResult then
					parryResult.OnClientEvent:Connect(function(p6, p7)
						local v79 = tonumber(p7) or p6 == true and 90 or 60
						_G.Ox.State.ParryCooldown = true
						if _G.Ox.State.ParryCooldownThread then
							task.cancel(_G.Ox.State.ParryCooldownThread)
						end
						local n13 = 4509969
						ParryHUD.SetColor(Color3.fromRGB(77, 77, 77))
						local n14 = 996616025
						ParryHUD.Tween(v79)
						if n14 == n13 then
							n7 = 539994509
							n12 -= 1795
							n5 = 343121117
						else
							_G.Ox.State.ParryCooldownThread = task.delay(v79, function()
								_G.Ox.State.ParryCooldown = false
								ParryHUD.SetColor(Color3.fromRGB(255, 255, 255))
							end)
						end
					end)
				end
			end)
		end
		ListenToParryResult()
		IsInKillerPOV = function(p8, p9, p10)
			if not p8 or not p9 then
				return false
			end
			local v82 = p9.Position - p8.Position
			local vector3 = Vector3.new(v82.X, 0, v82.Z)
			if vector3.Magnitude < 0.15 then
				return true
			end
			local vector32 = Vector3.new(p8.CFrame.LookVector.X, 0, p8.CFrame.LookVector.Z)
			if vector32.Magnitude < 0.05 then
				return false
			end
			return vector32.Unit:Dot(vector3.Unit) >= (p10 or 0.35)
		end
		local n15
		AttachParrySensor = function(p11)
			n15 = 1040956873
			local n16 = 134037267
			if not p11 or _G.Ox.AttachedParry[p11] then
				return
			end
			_G.Ox.AttachedParry[p11] = true
			local Humanoid = p11:WaitForChild("Humanoid", 5)
			if not Humanoid then
				return
			end
			local Animator = Humanoid:FindFirstChildOfClass("Animator") or Humanoid:WaitForChild("Animator", 5)
			if not Animator then
				return
			end
			Humanoid.ChildAdded:Connect(function(child)
				local n17 = 653449402
				if child:IsA("Animator") then
					_G.Ox.AttachedParry[p11] = nil
					AttachParrySensor(p11)
					if not (n7 < n17) then
						n5 = 580402950
						n15 += 1766
						n3 = 2054460
						n6 -= 591
						n7 += 1391
						n16 = 966528008
						;(nil)()
						;(nil)(nil)
						return
					end
				elseif not (n7 < n17) then
					n5 = 580402950
					n15 += 1766
					n3 = 2054460
					n6 -= 591
					n7 += 1391
					n16 = 966528008
					;(nil)()
					;(nil)(nil)
				end
			end)
			p11.AncestryChanged:Connect(function(child, parent)
				if not parent then
					_G.Ox.AttachedParry[p11] = nil
				end
				if n7 == n4 then
					n3 -= 1693
					n16 = 878531329
					n4 += 1381
					n5 -= 187
					n7 = 324453711
					n15 += 129
					bit32.band(nil, nil  )
				end
			end)
			Animator.AnimationPlayed:Connect(function(p12)
				local match = (p12.Animation and p12.Animation.AnimationId or ""):match("%d+")
				local v91 = t1[match]
				if not v91 then
					return
				end
				if match == "80411309607666" and _G.Ox.ParryConfig.AutoCrouch then
					local Character = LocalPlayer.Character
					if IsDowned(Character) then
						return
					end
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					local HumanoidRootPart2 = p11:FindFirstChild("HumanoidRootPart")
					if HumanoidRootPart and HumanoidRootPart2 and (HumanoidRootPart.Position - HumanoidRootPart2.Position).Magnitude <= 40 then
						TriggerCrouch()
					end
					return
				end
				local n18 = 29266494
				if not _G.Ox.ParryConfig.AutoParry then
					return
				end
				if _G.Ox.State.ParryCooldown then
					return
				end
				if _G.Ox.ParryConfig.Ignored_Skills and _G.Ox.ParryConfig.Ignored_Skills[v91] then
					return
				end
				local Character = LocalPlayer.Character
				if IsDowned(Character) or not IsSafeToParry(Character) then
					return
				end
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
				local n19 = 828356271
				local HumanoidRootPart2 = p11:FindFirstChild("HumanoidRootPart")
				if not HumanoidRootPart or not HumanoidRootPart2 then
					return
				end
				local Magnitude = (HumanoidRootPart.Position - HumanoidRootPart2.Position).Magnitude
				local ParryFace = _G.Ox.ParryConfig.ParryFace
				if ParryFace < 0.2 then
					ParryFace = 0.35
				end
				if _G.Ox.ParryConfig.ParryAggressive then
					if _G.Ox.ParryConfig.ParryRadius + 5 < Magnitude then
						return
					end
					local function v102()
						if _G.Ox.State.ParryCooldown or IsDowned(Character) then
							return true
						end
						if HumanoidRootPart then
							if HumanoidRootPart2 and HumanoidRootPart.Parent and HumanoidRootPart2.Parent then
								if not ((HumanoidRootPart.Position - HumanoidRootPart2.Position).Magnitude <= 12) or not IsInKillerPOV(HumanoidRootPart2, HumanoidRootPart, ParryFace) then
									return false
								end
								ExecuteParry()
								return true
							end
						end
						return true
					end
					if v102() then
						return
					end
					local connection
					local now = os.clock()
					connection = RunService.Heartbeat:Connect(function()
						if (os.clock() - now >= 0.85 or v102()) and connection then
							connection:Disconnect()
						end
					end)
				else
					local v105 = _G.Ox.ParryConfig.ParryRadius + 6
					local v106 = _G.Ox.ParryConfig.ParryRadius + 2
					if n5 == n4 then
						n7 = 693844197
						n19 -= 426
						n3 = 600519024
						n4 = 213398434
						n16 -= 1955
						n6 -= 1858
						n5 = 535051396
						n18 += 305
					elseif v105 < Magnitude then
						return
					end
					if Magnitude <= v106 and IsInKillerPOV(HumanoidRootPart2, HumanoidRootPart, ParryFace) then
						ExecuteParry()
						return
					end
					local now = os.clock()
					local connection
					connection = RunService.Heartbeat:Connect(function()
						if not (os.clock() - now >= 0.28) then
							if not _G.Ox.State.ParryCooldown and HumanoidRootPart and HumanoidRootPart2 and HumanoidRootPart.Parent and HumanoidRootPart2.Parent and not IsDowned(Character) then
								if (HumanoidRootPart.Position - HumanoidRootPart2.Position).Magnitude <= v106 and IsInKillerPOV(HumanoidRootPart2, HumanoidRootPart, ParryFace) then
									ExecuteParry()
									if connection then
										connection:Disconnect()
									end
								end
								return
							end
						end
						if connection then
							connection:Disconnect()
						end
					end)
				end
			end)
		end
	end
	TryAttachParry = function(p13)
		if p13 ~= LocalPlayer then
			if IsKiller(p13) and p13.Character then
				AttachParrySensor(p13.Character)
			end
		end
	end
	SetupPlayerParry = function(p14)
		if p14 == LocalPlayer then
			return
		end
		p14.CharacterAdded:Connect(function()
			TryAttachParry(p14)
		end)
		p14:GetPropertyChangedSignal("Team"):Connect(function()
			TryAttachParry(p14)
		end)
		if p14.Character then
			TryAttachParry(p14)
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		SetupPlayerParry(player)
	end
	Players.PlayerAdded:Connect(SetupPlayerParry)
	V2_HasParryingDagger = function()
		local Character = LocalPlayer.Character
		if not Character then
			return false
		end
		if Character:FindFirstChild("Parrying Dagger") then
			return true
		end
		for _, child in ipairs(Character:GetChildren()) do
			if child.Name == "Parrying Dagger" and (child:IsA("Tool") or child:IsA("Accessory") or child:IsA("Model")) then
				return true
			end
		end
		return false
	end
	V2_IsBusy = function()
		local Character = LocalPlayer.Character
		if not Character then
			return true
		end
		if LocalPlayer:GetAttribute("IsDead") then
			return true
		end
		if Character:GetAttribute("IsCarried") then
			return true
		end
		if Character:GetAttribute("IsHooked") then
			return true
		end
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		if HumanoidRootPart then
			if CollectionService:HasTag(HumanoidRootPart, "doing action") then
				return true
			end
		end
		if IsDowned(Character) then
			return true
		end
		local CheckInterractable = Character:FindFirstChild("CheckInterractable")
		if CheckInterractable then
			if CheckInterractable:GetAttribute("isVaulting") then
				return true
			end
			if CheckInterractable:GetAttribute("isSliding") then
				return true
			end
			if CheckInterractable:GetAttribute("isDroppingPallet") then
				return true
			end
			if CheckInterractable:GetAttribute("isRepairing") then
				return true
			end
			if CheckInterractable:GetAttribute("isHealing") then
				return true
			end
			if CheckInterractable:GetAttribute("isUnhooking") then
				return true
			end
			if CheckInterractable:GetAttribute("isExiting") then
				return true
			end
		end
		if n6 ~= 295005281 then
			return false
		end
		n2 -= 1970
		n7 += 84
		n5 += 1860
		n4 = 952551215
		n6 = 713266633
		n1 += 820
		return nil
	end
	do
		V2_IsLowHealth = function()
			local Character = LocalPlayer.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				return Humanoid.Health < Humanoid.MaxHealth * 0.5
			end
			return true
		end
	end
	V2_CanParry = function()
		local ParryV2 = _G.Ox.ParryV2
		if not ParryV2.Enabled then
			return false
		end
		if not V2_HasParryingDagger() then
			return false
		end
		if ParryV2.IsOnCooldown then
			return false
		end
		if ParryV2.IsResolving then
			return false
		end
		if ParryV2.SafetyParry and V2_IsBusy() then
			return false
		end
		if V2_IsLowHealth() then
			return false
		end
		return true
	end
	V2_HasLOS = function(p15)
		local Character = LocalPlayer.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		local HumanoidRootPart2 = p15 and p15:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart or not HumanoidRootPart2 then
			return false
		end
		local Position = HumanoidRootPart2.Position
		local v124 = HumanoidRootPart.Position - Position
		local Magnitude = v124.Magnitude
		if Magnitude < 0.1 then
			return true
		end
		_G.Ox._V2RayParams.FilterDescendantsInstances = {
			p15,
			Character
		}
		return not workspace:Raycast(Position, v124.Unit * Magnitude, _G.Ox._V2RayParams)
	end
	V2_IsBtnValid = function(p16)
		if p16 then
			if p16.Parent then
				local ok, result = pcall(function()
					if not p16:IsA("GuiButton") then
						if not (p16:IsA("ImageButton") or p16:IsA("TextButton")) then
							return false
						end
					end
					if p16.Visible == false then
						return false
					end
					if p16.AbsoluteSize.X < 4 or p16.AbsoluteSize.Y < 4 then
						return false
					end
					local Parent = p16.Parent
					local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
					while true do
						if not Parent or Parent == PlayerGui2 then
							return true
						end
						if not Parent:IsA("GuiObject") or Parent.Visible ~= false then
							Parent = Parent.Parent
							continue
						end
						break
					end
					return false
				end)
				local v130 = ok and result == true
				return v130
			end
		end
		return false
	end
	V2_FindParryButton = function()
		local ParryV2 = _G.Ox.ParryV2
		if ParryV2.BtnCache and V2_IsBtnValid(ParryV2.BtnCache) then
			return ParryV2.BtnCache
		end
		local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
		if not PlayerGui2 then
			return nil
		end
		for _, v in ipairs({
			{
				"Survivor-mob",
				"Controls",
				"Gui-mob"
			},
			{
				"SurvivorMob",
				"Controls",
				"GuiMob"
			},
			{
				"Survivor-mob",
				"Controls",
				"GuiMob"
			}
		}) do
			local v135 = PlayerGui2
			for _, v2 in ipairs(v) do
				v135 = v135 and v135:FindFirstChild(v2)
			end
			if not v135 or not V2_IsBtnValid(v135) then
				continue
			end
			ParryV2.BtnCache = v135
			return v135
		end
		return nil
	end
	do
		local n20
		V2_TriggerByButton = function()
			local n21 = 930851140
			n20 = 599753393
			local v140 = V2_FindParryButton()
			local n22 = 658166921
			if v140 then
				pcall(function()
					local spilled = {
						n23 = 545157317,
						n24 = 612300745,
						n25 = 820512774,
						v142 = nil,
						v143 = nil
					}
					if type(firesignal) == "function" then
						if spilled.n24 ~= 612300745 then
							n1 -= 1328
							n5 -= 396
							n2 -= 1358
							n21 = 953802566
							n22 -= 487
							n20 = 536794735
							do
								local v144, v145, v146, v147, v148, v149, v150, v151, v152, v153, v154, v155, v156, v157, v158, v159, v160, v161, v162, v163, v164, v165, v166, v167, v168, v169, v170, v171, v172, v173, v174, v175, v176, v177, v178, v179, v180, v181, v182, v183, v184, v185, v186, v187, v188, v189, v190, v191, v192, v193, v194, v195, v196, v197, v198, v199, v200, v201, v202, v203, v204, v205, v206, v207, v208, v209, v210, v211, v212, v213, v214, v215, v216, v217, v218, v219, v220, v221, v222, v223, v224, v225, v226, v227, v228, v229, v230, v231, v232, v233, v234, v235, v236, v237, v238, v239, v240, v241, v242, v243, v244, v245, v246, v247, v248, v249, v250, v251, v252, v253, v254, v255, v256, v257, v258, v259, v260, v261, v262, v263, v264, v265, v266, v267, v268, v269, v270, v271, v272, v273, v274, v275, v276, v277, v278, v279, v280, v281, v282, v283, v284, v285, v286, v287, v288, v289, v290, v291, v292, v293, v294, v295, v296, v297, v298, v299, v300, v301, v302, v303, v304, v305, v306, v307, v308, v309, v310, v311, v312, v313, v314, v315, v316, v317, v318, v319, v320, v321
								;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 353))
								spilled.v323[nil  ] = nil
								return table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, spilled.v324, spilled.v325, spilled.v326, spilled.v327, spilled.v328, spilled.v329, spilled.v330, spilled.v331, spilled.v332, spilled.v333, spilled.v334, spilled.v335, spilled.v336, spilled.v337, spilled.v338, spilled.v339, spilled.v340, spilled.v341, spilled.v342, spilled.v343, spilled.v344, spilled.v345, spilled.v346, spilled.v347, spilled.v348, spilled.v349, spilled.v350, spilled.v351, spilled.v352, spilled.v353, spilled.v354, spilled.v355, spilled.v356, spilled.v357, spilled.v358, spilled.v359, spilled.v360, spilled.v361, spilled.v362, spilled.v363, spilled.v364, spilled.v365, spilled.v366, spilled.v367, spilled.v368, spilled.v369, spilled.v370, spilled.v371, spilled.v372, spilled.v373, spilled.v374, spilled.v375, spilled.v376, v144, v145, v146, v147, v148, v149, v150, v151, v152, v153, v154, v155, v156, v157, v158, v159, v160, v161, v162, v163, v164, v165, v166, v167, v168, v169, v170, v171, v172, v173, v174, v175, v176, v177, v178, v179, v180, v181, v182, v183, v184, v185, v186, v187, v188, v189, v190, v191, v192, v193, v194, v195, v196, v197, v198, v199, v200, v201, v202, v203, v204, v205, v206, v207, v208, v209, v210, v211, v212, v213, v214, v215, v216, v217, v218, v219, v220, v221, v222, v223, v224, v225, v226, v227, v228, v229, v230, v231, v232, v233, v234, v235, v236, v237, v238, v239, v240, v241, v242, v243, v244, v245, v246, v247, v248, v249, v250, v251, v252, v253, v254, v255, v256, v257, v258, v259, v260, v261, v262, v263, v264, v265, v266, v267, v268, v269, v270, v271, v272, v273, v274, v275, v276, v277, v278, v279, v280, v281, v282, v283, v284, v285, v286, v287, v288, v289, v290, v291, v292, v293, v294, v295, v296, v297, v298, v299, v300, v301, v302, v303, v304, v305, v306, v307, v308, v309, v310, v311, v312, v313, v314, v315, v316, v317, v318, v319, v320, v321, spilled.v377, spilled.v378, spilled.v379, spilled.v380, spilled.v381, spilled.v382, spilled.v383, spilled.v384, spilled.v385, spilled.v386, spilled.v387, spilled.v388, spilled.v389, spilled.v390, spilled.v391, spilled.v392, spilled.v393, nil   * nil, spilled.v394, spilled.v395, spilled.v396, spilled.v397, spilled.v398, spilled.v399, spilled.v400, spilled.v401, spilled.v402, spilled.v403, spilled.v404, spilled.v405, spilled.v406, spilled.v407, spilled.v408, spilled.v409, spilled.v410, spilled.v411, spilled.v412, spilled.v413, spilled.v414, spilled.v415, spilled.v416, spilled.v417, spilled.v418, spilled.v419, spilled.v420, spilled.v421, spilled.v422, spilled.v423, spilled.v424, spilled.v425, spilled.v426, spilled.v427, spilled.v428, spilled.v429, spilled.v430, spilled.v431, spilled.v432, spilled.v433, spilled.v434, spilled.v435, spilled.v436, spilled.v437, spilled.v438, spilled.v439, spilled.v440, spilled.v441, spilled.v442, spilled.v443, spilled.v444, spilled.v445, spilled.v446, spilled.v447, spilled.v448, spilled.v449, spilled.v450, spilled.v451, spilled.v452, spilled.v453, spilled.v454, spilled.v455, spilled.v456, spilled.v457, spilled.v458, spilled.v459, spilled.v460, spilled.v461, spilled.v462, spilled.v463, spilled.v464, spilled.v465, spilled.v466, spilled.v467, spilled.v468, spilled.v469, spilled.v470, spilled.v471, spilled.v472, spilled.v473, spilled.v474, spilled.v475, spilled.v476, spilled.v477, spilled.v478, spilled.v479, spilled.v480, spilled.v323, spilled.v481, spilled.v482, spilled.v483, spilled.v484, spilled.v485, nil }, 1, 408)
							end
						end
						firesignal(v140.MouseButton1Down)
						task.delay(0.06, function()
							spilled.v142 = 438198905
							local n26 = 971758218
							spilled.v143 = 434746925
							if n2 == spilled.n24 then
								repeat
									spilled.n25 += 291
									spilled.n23 = 562075054
									spilled.v143 = 575381489
									n21 = 553456692
									n5 = 890984974
									n26 -= 1660
									spilled.n24 += 726
									n2 -= 621
									spilled.v142 -= 1310
									local v486 = table.pack(P_0())
								until not v486[1]
							else
								pcall(function()
									firesignal(v140.MouseButton1Up)
									if v140.MouseButton1Click then
										firesignal(v140.MouseButton1Click)
									end
									if n5 ~= 403422737 then
										n5 = 722316547
										spilled.n24 = 679985195
										spilled.n25 -= 587
										spilled.v143 = 487085429
										n26 = 515360232
										n2 = 1064434385
									end
								end)
							end
						end)
					else
						local AbsolutePosition = v140.AbsolutePosition
						local AbsoluteSize = v140.AbsoluteSize
						local guiInset = GuiService:GetGuiInset()
						local v487 = AbsolutePosition.X + AbsoluteSize.X / 2 + guiInset.X
						local v488 = AbsolutePosition.Y + AbsoluteSize.Y / 2 + guiInset.Y
						local v489 = 9901 + math.random(1, 400)
						VirtualInputManager:SendTouchEvent(v489, 0, v487, v488)
						task.delay(0.06, function()
							pcall(function()
								VirtualInputManager:SendTouchEvent(v489, 2, v487, v488)
							end)
						end)
					end
				end)
				return true
			end
			pcall(function()
				local n27 = 951846199
				local mouseLocation = UserInputService:GetMouseLocation()
				local n28 = 160397669
				local n29 = 994356521
				if n21 == 930851140 then
					VirtualInputManager:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 1, true, game, 0)
				else
					n5 = 168321882
					n2 += 1589
					n20 -= 917
					n28 -= 1656
					n22 -= 1392
					n3 -= 574
					n27 += 1967
					n21 = 367425448
					n29 += 863
				end
				task.delay(0.06, function()
					local mouseLocation2 = UserInputService:GetMouseLocation()
					VirtualInputManager:SendMouseButtonEvent(mouseLocation2.X, mouseLocation2.Y, 1, false, game, 0)
				end)
			end)
			return false
		end
	end
	V2_SetIconsColor = function(p17)
		local ParryV2 = _G.Ox.ParryV2
		if #ParryV2.Gradients == 0 then
			if ParryHUD and ParryHUD.Scan then
				ParryHUD.Scan()
			end
			ParryV2.Gradients = ParryHUD and ParryHUD.gradients or {}
			ParryV2.Icon = ParryHUD and ParryHUD.icon or nil
		end
		for _, gradient in ipairs(ParryV2.Gradients) do
			if gradient and gradient.Parent and gradient.Parent.Parent then
				local icon = gradient.Parent.Parent:FindFirstChild("icon")
				if icon then
					icon.ImageColor3 = p17
				end
				local Gui = gradient.Parent.Parent:FindFirstChild("Gui")
				if Gui then
					Gui.ImageColor3 = p17
				end
			end
		end
		if ParryV2.Icon then
			ParryV2.Icon.ImageColor3 = p17
		end
	end
	V2_PlayCooldownTween = function(p18)
		local ParryV2 = _G.Ox.ParryV2
		if #ParryV2.Gradients == 0 then
			if ParryHUD and ParryHUD.Scan then
				ParryHUD.Scan()
			end
			ParryV2.Gradients = ParryHUD and ParryHUD.gradients or {}
		end
		for _, gradient in ipairs(ParryV2.Gradients) do
			if gradient and gradient.Parent then
				gradient.Offset = Vector2.new(0, 0.75)
				local tween = TweenService:Create(gradient, TweenInfo.new(p18, Enum.EasingStyle.Linear), {
					Offset = Vector2.new(0, 0.25)
				})
				tween:Play()
				tween.Completed:Connect(function()
					if not ParryV2.IsOnCooldown then
						V2_SetIconsColor(Color3.fromRGB(255, 255, 255))
					end
				end)
			end
		end
	end
	V2_StartCooldown = function(p19)
		local ParryV2 = _G.Ox.ParryV2
		ParryV2.CooldownToken += 1
		local CooldownToken = ParryV2.CooldownToken
		ParryV2.IsResolving = false
		ParryV2.IsOnCooldown = true
		V2_SetIconsColor(Color3.fromRGB(77, 77, 77))
		V2_PlayCooldownTween(p19)
		if ParryV2.CooldownThread then
			task.cancel(ParryV2.CooldownThread)
		end
		ParryV2.CooldownThread = task.delay(p19, function()
			if ParryV2.CooldownToken == CooldownToken then
				ParryV2.IsOnCooldown = false
				V2_SetIconsColor(Color3.fromRGB(255, 255, 255))
				ParryV2.CooldownThread = nil
			end
		end)
	end
	V2_ResetCooldown = function()
		local ParryV2 = _G.Ox.ParryV2
		if ParryV2.CooldownThread then
			task.cancel(ParryV2.CooldownThread)
			ParryV2.CooldownThread = nil
		end
		ParryV2.IsOnCooldown = false
		ParryV2.IsResolving = false
		V2_SetIconsColor(Color3.fromRGB(255, 255, 255))
	end
	V2_FaceLookDirection = function()
		if not workspace.CurrentCamera then
			return
		end
		local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if HumanoidRootPart then
			if HumanoidRootPart.Parent then
				local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				local LookVector = workspace.CurrentCamera.CFrame.LookVector
				local vector3 = Vector3.new(LookVector.X, 0, LookVector.Z)
				if vector3.Magnitude <= 0 then
					return
				end
				local cFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + vector3.Unit)
				TweenService:Create(HumanoidRootPart, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
					CFrame = cFrame
				}):Play()
				if Humanoid then
					Humanoid.AutoRotate = false
				end
				local ParryV2 = _G.Ox.ParryV2
				if ParryV2.LockConnection then
					ParryV2.LockConnection:Disconnect()
				end
				local now = tick()
				ParryV2.LockConnection = RunService.Heartbeat:Connect(function()
					if tick() - now >= 0.8 then
						if ParryV2.LockConnection then
							ParryV2.LockConnection:Disconnect()
							ParryV2.LockConnection = nil
						end
						if Humanoid then
							Humanoid.AutoRotate = true
						end
						return
					end
					if HumanoidRootPart and HumanoidRootPart.Parent then
						HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + vector3.Unit)
					elseif ParryV2.LockConnection then
						ParryV2.LockConnection:Disconnect()
						ParryV2.LockConnection = nil
					end
					if n1 == 677871702 then
						n2 = 307480664
						n6 = 348757978
						n1 += 479
						n5 -= 1836
					end
				end)
				return
			end
		end
	end
	V2_MatchParrySkin = function(p20)
		if type(p20) ~= "string" or p20 == "" then
			return nil
		end
		local ParryV2Anim = _G.Ox.ParryV2Anim
		if not ParryV2Anim then
			return nil
		end
		if ParryV2Anim[p20] then
			return ParryV2Anim[p20]
		end
		local v490 = string.lower(p20):gsub("^equippedskin[_%-]?", ""):gsub("^skin[_%-]?", ""):gsub("[_%-]?parrying[_%-]?dagger", ""):gsub("[_%-]?dagger", ""):gsub("%s+", "")
		for k, v in pairs(ParryV2Anim) do
			local v491 = string.lower(k)
			if v491 == v490 or string.find(v490, v491, 1, true) or string.find(v491, v490, 1, true) then
				return v
			end
		end
		return nil
	end
	V2_ScanSkinFromInstance = function(p21)
		if not p21 then
			return nil
		end
		local n30 = 864594767
		local n31 = 857214961
		local n32 = 309594447
		for _, v in ipairs({
			"EquippedSkin_Parrying_Dagger",
			"EquippedSkin_ParryingDagger",
			"EquippedSkin",
			"ParryingDaggerSkin",
			"ParrySkin",
			"Skin",
			"SkinName",
			"CurrentSkin",
			"EquippedSkinName"
		}) do
			local attribute = p21:GetAttribute(v)
			local v492 = V2_MatchParrySkin(attribute)
			if not v492 then
				continue
			end
			return v492
		end
		local ok, result = pcall(function()
			local v493
			local v494
			local v495
			if n1 ~= 880645667 then
				return p21:GetAttributes()
			end
			n31 -= 104
			n32 += 211
			n30 -= 1664
			n1 = 709473337
			n5 += 1434
			n3 -= 185
			(nil)()
			return v493(table.unpack({ v494, v495, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 448))
		end)
		if ok then
			if type(result) == "table" then
				for k, v in pairs(result) do
					if type(k) ~= "string" then
						continue
					end
					if type(v) ~= "string" then
						continue
					end
					local v496 = string.lower(k)
					if v496:find("skin") or v496:find("parry") then
						local v497 = V2_MatchParrySkin(v)
						if not v497 then
							continue
						end
						return v497
					end
				end
			end
		end
		return nil
	end
	V2_ResolveAnimId = function()
		local Character = LocalPlayer.Character
		if Character then
			local v498 = V2_ScanSkinFromInstance(Character)
			if v498 then
				return v498
			end
			local ParryingDagger = Character:FindFirstChild("Parrying Dagger") or Character:FindFirstChild("ParryingDagger") or Character:FindFirstChild("parrying dagger")
			if ParryingDagger then
				local v499 = V2_ScanSkinFromInstance(ParryingDagger)
				if v499 then
					return v499
				end
				for _, descendant in ipairs(ParryingDagger:GetDescendants()) do
					if descendant:IsA("StringValue") or descendant:IsA("ValueBase") and type(descendant.Value) == "string" then
						local v500 = V2_MatchParrySkin(tostring(descendant.Value))
						if v500 then
							return v500
						end
					end
				end
			end
			local Backpack = LocalPlayer:FindFirstChild("Backpack")
			if Backpack then
				local ParryingDagger2 = Backpack:FindFirstChild("Parrying Dagger")
				ParryingDagger2 = ParryingDagger2 or Backpack:FindFirstChild("ParryingDagger")
				if ParryingDagger2 then
					local v501 = V2_ScanSkinFromInstance(ParryingDagger2)
					if v501 then
						return v501
					end
				end
			end
		end
		local v502 = V2_ScanSkinFromInstance(LocalPlayer)
		if v502 then
			return v502
		end
		return _G.Ox.ParryV2Anim.Default
	end
	do
		V2_PlayParryAnim = function()
			local Character = LocalPlayer.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			local Animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
			if not Animator then
				return
			end
			local ParryV2 = _G.Ox.ParryV2
			if ParryV2.ParryTrack then
				pcall(function()
					ParryV2.ParryTrack:Stop(0.05)
				end)
			end
			pcall(function()
				local Animation = Instance.new("Animation")
				Animation.AnimationId = V2_ResolveAnimId()
				ParryV2.ParryTrack = Animator:LoadAnimation(Animation)
				ParryV2.ParryTrack.Priority = Enum.AnimationPriority.Action4
				ParryV2.ParryTrack:Play()
			end)
		end
	end
	V2_DoParry = function()
		if not V2_CanParry() then
			return
		end
		local n33 = 620852127
		local n34 = 344147015
		local ParryV2 = _G.Ox.ParryV2
		ParryV2.IsResolving = true
		V2_SetIconsColor(Color3.fromRGB(77, 77, 77))
		local n35 = 892900147
		local Trigger = ParryV2.Trigger or "Remote"
		local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
		if Trigger == "Button" then
			V2_TriggerByButton()
		else
			local ParryingDagger = Remotes and Remotes:FindFirstChild("Items") and Remotes.Items:FindFirstChild("Parrying Dagger")
			local parry = ParryingDagger and ParryingDagger:FindFirstChild("parry")
			if parry then
				pcall(function()
					parry:FireServer()
				end)
			end
			V2_FaceLookDirection()
			local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid.AutoRotate = false
			end
			V2_PlayParryAnim()
			local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if HumanoidRootPart then
				pcall(function()
					CollectionService:AddTag(HumanoidRootPart, "doing action")
					local n36 = 381141099
					if not (n34 < n36) then
						n33 += 6
						n5 = 1066130575
						n34 = 736053856
						n3 = 241387436
						n35 += 1360
						n2 = 51231818
						getfenv()[nil  ] = nil
					end
				end)
			end
			local Slow = Remotes and Remotes:FindFirstChild("Mechanics") and Remotes.Mechanics:FindFirstChild("Slow")
			if Slow then
				pcall(function()
					Slow:Fire(0, 1, 0)
				end)
			end
		end
		task.delay(2, function()
			if ParryV2.IsResolving then
				ParryV2.IsResolving = false
				local v503 = ParryV2.Trigger == "Button" and 1.2 or 60
				if not (n5 < n1) then
					n5 = 142317679
					n35 += 1979
					n3 = 696731502
					n34 += 997
					n1 = 322516434
					n33 -= 1675
					return
				end
				V2_StartCooldown(v503)
				local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if HumanoidRootPart then
					pcall(function()
						CollectionService:RemoveTag(HumanoidRootPart, "doing action")
					end)
				end
			end
		end)
	end
	task.spawn(function()
		local Remotes = ReplicatedStorage:WaitForChild("Remotes", 8)
		local Items = Remotes and Remotes:WaitForChild("Items", 5)
		local ParryingDagger = Items and Items:WaitForChild("Parrying Dagger", 5)
		local parryResult = ParryingDagger and ParryingDagger:WaitForChild("parryResult", 5)
		if not parryResult then
			return
		end
		if n7 == 542746161 then
			parryResult.OnClientEvent:Connect(function(p22, p23)
				local ParryV2 = _G.Ox.ParryV2
				if not ParryV2.IsResolving then
					return
				end
				ParryV2.IsResolving = false
				local v504 = tonumber(p23)
				if v504 and v504 > 0 then
					V2_StartCooldown(v504)
				elseif p22 == true then
					V2_StartCooldown(90)
				else
					V2_StartCooldown(60)
				end
				local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if HumanoidRootPart then
					pcall(function()
						CollectionService:RemoveTag(HumanoidRootPart, "doing action")
					end)
				end
			end)
		else
			n2 -= 76
			n6 = 699565421
			n1 = 557630077
			n7 += 1554
			n3 -= 1702
			n5 = 635613072
			;(nil)(nil, nil)
			;(nil)()
		end
	end)
	local CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	CylinderHandleAdornment.Name = "TEMPO_ParryRange_V2"
	CylinderHandleAdornment.Radius = _G.Ox.ParryV2.Range or 12
	CylinderHandleAdornment.InnerRadius = math.max(0.1, (_G.Ox.ParryV2.Range or 12) - 0.15)
	CylinderHandleAdornment.Height = 0.01
	CylinderHandleAdornment.Color3 = Color3.fromRGB(80, 80, 80)
	CylinderHandleAdornment.AlwaysOnTop = false
	CylinderHandleAdornment.Transparency = 1
	CylinderHandleAdornment.Adornee = workspace:FindFirstChildOfClass("Terrain")
	pcall(function()
		CylinderHandleAdornment.Parent = CoreGui
	end)
	if not CylinderHandleAdornment.Parent then
		pcall(function()
			CylinderHandleAdornment.Parent = LocalPlayer:WaitForChild("PlayerGui")
		end)
	end
	_G.Ox.ParryV2.RangeAdornment = CylinderHandleAdornment
	local n37
	V2_UpdateRangeCircle = function()
		n37 = 774176606
		local ParryV2 = _G.Ox.ParryV2
		local RangeAdornment = ParryV2.RangeAdornment
		if not RangeAdornment then
			return
		end
		if not ParryV2.Enabled or not ParryV2.ShowCircle then
			if RangeAdornment.Transparency ~= 1 then
				RangeAdornment.Transparency = 1
			end
			return
		end
		local Character = LocalPlayer.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart then
			if RangeAdornment.Transparency ~= 1 then
				RangeAdornment.Transparency = 1
			end
			return
		end
		local Range = ParryV2.Range or 12
		if HumanoidRootPart == _G.Ox._V2ParryLastRoot and Range == _G.Ox._V2ParryLastRadius then
			return
		end
		_G.Ox._V2ParryLastRoot = HumanoidRootPart
		_G.Ox._V2ParryLastRadius = Range
		RangeAdornment.Transparency = 0.4
		RangeAdornment.Radius = Range
		RangeAdornment.InnerRadius = math.max(0.1, Range - 0.15)
		local _V2ParryRangeRay = _G.Ox._V2ParryRangeRay
		if n2 == 352572639 then
			n1 -= 1027
			n4 = 306140283
			n7 = 187138334
			n5 += 859
			n37 -= 1502
			n2 += 1374
			n6 += 26
			upv240 = nil
		else
			_V2ParryRangeRay.FilterDescendantsInstances = { Character }
		end
		local hit = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -15, 0), _V2ParryRangeRay)
		RangeAdornment.CFrame = CFrame.new((hit and hit.Position or HumanoidRootPart.Position - Vector3.new(0, 3, 0)) + Vector3.new(0, 0.05, 0)) * CFrame.Angles(1.5707963267948966, 0, 0)
	end
	do
		V2_AttachParrySensor = function(p24)
			if not p24 or _G.Ox.ParryV2.Attached[p24] then
				return
			end
			_G.Ox.ParryV2.Attached[p24] = true
			local Humanoid = p24:FindFirstChild("Humanoid")
			if not Humanoid then
				Humanoid = p24:WaitForChild("Humanoid", 5)
				if not Humanoid then
					return
				end
			end
			local Animator = Humanoid:FindFirstChildOfClass("Animator")
			if not Animator then
				Animator = Humanoid:WaitForChild("Animator", 5)
				if not Animator then
					return
				end
			end
			Humanoid.ChildAdded:Connect(function(child)
				if child:IsA("Animator") then
					_G.Ox.ParryV2.Attached[p24] = nil
					V2_AttachParrySensor(p24)
				end
			end)
			p24.AncestryChanged:Connect(function(child, parent)
				if not parent then
					_G.Ox.ParryV2.Attached[p24] = nil
				end
			end)
			Animator.AnimationPlayed:Connect(function(p25)
				if not _G.Ox.ParryV2AttackAnims[p25.Animation and p25.Animation.AnimationId or ""] then
					return
				end
				local ParryV2 = _G.Ox.ParryV2
				if not ParryV2.Enabled then
					return
				end
				if not V2_HasParryingDagger() then
					return
				end
				if ParryV2.IsOnCooldown or ParryV2.IsResolving then
					return
				end
				local Character = LocalPlayer.Character
				if not Character then
					return
				end
				local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
				local HumanoidRootPart2 = p24:FindFirstChild("HumanoidRootPart")
				if not HumanoidRootPart or not HumanoidRootPart2 then
					return
				end
				local Magnitude = (HumanoidRootPart.Position - HumanoidRootPart2.Position).Magnitude
				local Mode = ParryV2.Mode or "Legit"
				local Range = ParryV2.Range or 12
				if Mode == "Aggressive" then
					local v505 = Range
					if v505 + 3 < Magnitude then
						return
					end
					local v506 = math.clamp(tonumber(ParryV2.KillerFace) or 0.6, -1, 1)
					local function v507()
						local v508 = HumanoidRootPart.Position - HumanoidRootPart2.Position
						local vector3 = Vector3.new(v508.X, 0, v508.Z)
						if vector3.Magnitude < 0.05 then
							return true
						end
						local vector32 = Vector3.new(HumanoidRootPart2.CFrame.LookVector.X, 0, HumanoidRootPart2.CFrame.LookVector.Z)
						if vector32.Magnitude < 0.05 then
							return false
						end
						return vector32.Unit:Dot(vector3.Unit) >= v506
					end
					local function v509()
						if ParryV2.IsOnCooldown or ParryV2.IsResolving or not HumanoidRootPart or not HumanoidRootPart2 or not HumanoidRootPart.Parent or not HumanoidRootPart2.Parent then
							return true
						end
						if (HumanoidRootPart.Position - HumanoidRootPart2.Position).Magnitude <= v505 and v507() then
							V2_DoParry()
							return true
						end
						return false
					end
					if v509() then
						return
					end
					local connection
					local now = os.clock()
					connection = RunService.Heartbeat:Connect(function()
						if os.clock() - now >= 1.5 or v509() then
							if connection then
								connection:Disconnect()
							end
						end
					end)
				else
					if Range < Magnitude then
						return
					end
					if not V2_HasLOS(p24) then
						return
					end
					local v510 = Vector3.new(HumanoidRootPart.Position.X, 0, HumanoidRootPart.Position.Z) - Vector3.new(HumanoidRootPart2.Position.X, 0, HumanoidRootPart2.Position.Z)
					if v510.Magnitude > 0 then
						local Unit = v510.Unit
						local vector3 = Vector3.new(HumanoidRootPart2.CFrame.LookVector.X, 0, HumanoidRootPart2.CFrame.LookVector.Z)
						if vector3.Magnitude > 0 then
							local Unit2 = vector3.Unit
							local v511 = math.clamp(tonumber(ParryV2.KillerFace) or 0.6, -1, 1)
							if Unit2:Dot(Unit) < v511 then
								return
							end
						end
						if Mode == "Strict" then
							local CurrentCamera = workspace.CurrentCamera
							local vector32
							if CurrentCamera then
								vector32 = Vector3.new(CurrentCamera.CFrame.LookVector.X, 0, CurrentCamera.CFrame.LookVector.Z)
							end
							if not vector32 or vector32.Magnitude < 0.05 then
								vector32 = Vector3.new(HumanoidRootPart.CFrame.LookVector.X, 0, HumanoidRootPart.CFrame.LookVector.Z)
							end
							if vector32.Magnitude > 0 then
								if vector32.Unit:Dot(-Unit) < 0.5 then
									return
								end
							end
						end
					end
					V2_DoParry()
				end
			end)
		end
	end
	V2_TryAttach = function(p26)
		if p26 ~= LocalPlayer and p26.Team then
			if p26.Team.Name == "Killer" and p26.Character then
				V2_AttachParrySensor(p26.Character)
			end
		end
	end
	do
		V2_SetupPlayer = function(p27)
			if p27 == LocalPlayer then
				return
			end
			p27.CharacterAdded:Connect(function()
				V2_TryAttach(p27)
			end)
			p27:GetPropertyChangedSignal("Team"):Connect(function()
				V2_TryAttach(p27)
			end)
			if p27.Character then
				V2_TryAttach(p27)
			end
		end
	end
	for _, player in pairs(Players:GetPlayers()) do
		V2_SetupPlayer(player)
	end
	Players.PlayerAdded:Connect(V2_SetupPlayer)
	do
		RunService.Heartbeat:Connect(function()
			if _G.Ox.ParryV2 and _G.Ox.ParryV2.Enabled and _G.Ox.ParryV2.ShowCircle then
				_G.Ox._V2ParryLastRoot = nil
				V2_UpdateRangeCircle()
			elseif _G.Ox.ParryV2 and _G.Ox.ParryV2.RangeAdornment and _G.Ox.ParryV2.RangeAdornment.Transparency ~= 1 then
				_G.Ox.ParryV2.RangeAdornment.Transparency = 1
			end
		end)
	end
	UpdateCustomParryGUI = function(p28)
		if not _G.Ox.AutoParryCustom.Gui then
			return
		end
		local Frame = _G.Ox.AutoParryCustom.Gui:FindFirstChild("Frame")
		local n38 = 14877964
		local n39 = 886830910
		if not Frame then
			return
		end
		local ActionButton = Frame:FindFirstChild("ActionButton")
		local UIStroke = Frame:FindFirstChild("UIStroke")
		if p28 then
			if ActionButton then
				ActionButton.Text = "PARRY [ON]"
				ActionButton.TextColor3 = Color3.fromRGB(180, 255, 180)
				ActionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
			end
			if UIStroke then
				UIStroke.Color = Color3.fromRGB(100, 200, 100)
			end
		else
			if ActionButton then
				ActionButton.Text = "PARRY [OFF]"
				if n1 == 677870210 then
					ActionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
					ActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
				else
					n7 -= 193
					n2 = 787668381
					n1 = 742144003
					n3 += 866
					n6 -= 188
					local v512 = n38 + 928
					n5 = 493515133
					local v513 = n39 - 579
					while true do
						ActionButton = ActionButton(UIStroke, "ActionButton")
						UIStroke = Frame:FindFirstChild("UIStroke")
						if not ActionButton then
							break
						end
						ActionButton.Text = "PARRY [OFF]"
						if n1 == 677870210 then
							local color3 = Color3.fromRGB
							local n40 = 200
							ActionButton.TextColor3 = color3(n40, 200, 200)
							ActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
							break
						end
						n7 -= 193
						n2 = 787668381
						n1 = 742144003
						n3 += 866
						n6 -= 188
						v512 += 928
						n5 = 493515133
						v513 -= 579
					end
				end
			end
			if UIStroke then
				UIStroke.Color = Color3.fromRGB(90, 90, 95)
			end
		end
	end
	ToggleParryStatus = function()
		_G.Ox.ParryConfig.AutoParry = not _G.Ox.ParryConfig.AutoParry
		_G.Ox.AutoParryCustom.IsActive = _G.Ox.ParryConfig.AutoParry
		UpdateCustomParryGUI(_G.Ox.ParryConfig.AutoParry)
		lib2:Notify({
			Title = "Auto Parry",
			Description = _G.Ox.ParryConfig.AutoParry and "On" or "Off",
			Duration = 2
		})
	end
	do
		local n41
		CreateCustomParryGUI = function()
			n41 = 172806482
			local n42, ScreenGui, Sibling
			if _G.Ox.AutoParryCustom.Gui then
				_G.Ox.AutoParryCustom.Gui:Destroy()
				n42 = 50494003
				ScreenGui = Instance.new("ScreenGui")
				ScreenGui.Name = "AutoParryCustomGui"
				ScreenGui.ResetOnSpawn = false
				ScreenGui.IgnoreGuiInset = true
				Sibling = Enum.ZIndexBehavior.Sibling
			else
				n42 = 50494003
				ScreenGui = Instance.new("ScreenGui")
				ScreenGui.Name = "AutoParryCustomGui"
				ScreenGui.ResetOnSpawn = false
				ScreenGui.IgnoreGuiInset = true
				Sibling = Enum.ZIndexBehavior.Sibling
			end
			ScreenGui.ZIndexBehavior = Sibling
			ScreenGui.Parent = CoreGui
			ScreenGui.Enabled = false
			_G.Ox.AutoParryCustom.Gui = ScreenGui
			_G.Ox.AutoParryCustom.GuiVisible = false
			local Frame = Instance.new("Frame", ScreenGui)
			Frame.Name = "Frame"
			Frame.Size = UDim2.fromOffset(110, 36)
			Frame.Position = UDim2.fromScale(0.85, 0.35)
			Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			Frame.BackgroundTransparency = 0.1
			Frame.Active = true
			Frame.BorderSizePixel = 0
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
			local UIStroke = Instance.new("UIStroke", Frame)
			UIStroke.Name = "UIStroke"
			UIStroke.Color = Color3.fromRGB(90, 90, 95)
			UIStroke.Thickness = 1.5
			UIStroke.Transparency = 0.2
			local TextButton = Instance.new("TextButton", Frame)
			TextButton.Name = "ActionButton"
			TextButton.Size = UDim2.new(1, 0, 1, 0)
			TextButton.Text = "PARRY [OFF]"
			TextButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
			TextButton.Font = Enum.Font.GothamBold
			TextButton.TextSize = 12
			TextButton.TextColor3 = Color3.fromRGB(200, 200, 200)
			TextButton.BorderSizePixel = 0
			TextButton.AutoButtonColor = false
			Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 8)
			local u514 = false
			local u515 = false
			local u516 = false
			local Position
			local Position2
			local thread
			local n43
			local n44
			update = function(p29)
				n43 = 743976600
				n44 = 685355873
				if n41 == n3 then
					n5 += 405
					n7 += 595
					n41 = 162489435
					n3 += 1751
					n44 += 202
					n6 = 571232937
					n42 += 586
					n43 -= 1322
					upv373[nil] = nil
					local v517 = table.pack(P_0())
					if not v517[1] then
					end
				elseif not u514 or not u516 or not Position or not Position2 then
					return
				end
				local v518 = p29.Position - Position
				if not u515 then
					if math.abs(v518.X) > 18 or math.abs(v518.Y) > 18 then
						u515 = true
					end
				end
				if u515 then
					Frame.Position = UDim2.new(Position2.X.Scale, Position2.X.Offset + v518.X, Position2.Y.Scale, Position2.Y.Offset + v518.Y)
				end
			end
			TextButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					u514 = true
					u515 = false
					u516 = false
					Position = input.Position
					Position2 = Frame.Position
					if thread then
						task.cancel(thread)
					end
					thread = task.delay(0.18, function()
						if u514 then
							u516 = true
						end
					end)
				end
			end)
			TextButton.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if n5 ~= 403422737 then
						n4 -= 261
						n3 -= 235
						n5 -= 1283
						n6 -= 60
						n42 -= 236
						n41 = 62210955
						LPH_CRASH()
					end
					if thread then
						task.cancel(thread)
					end
					if u514 and not u515 then
						ToggleParryStatus()
					end
					u514 = false
					u515 = false
					u516 = false
					Position = nil
					Position2 = nil
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if u514 and u516 then
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						update(input)
						return
					elseif input.UserInputType == Enum.UserInputType.Touch then
						update(input)
					end
				end
			end)
			if _G.Ox.AutoParryCustom._statusConn then
				_G.Ox.AutoParryCustom._statusConn:Disconnect()
			end
			_G.Ox.AutoParryCustom._statusConn = RunService.Heartbeat:Connect(function()
				if not _G.Ox.AutoParryCustom.Gui or not _G.Ox.AutoParryCustom.Gui.Parent then
					if _G.Ox.AutoParryCustom._statusConn then
						_G.Ox.AutoParryCustom._statusConn:Disconnect()
					end
					return
				end
				if _G.Ox.AutoParryCustom.IsActive ~= _G.Ox.ParryConfig.AutoParry then
					_G.Ox.AutoParryCustom.IsActive = _G.Ox.ParryConfig.AutoParry
					UpdateCustomParryGUI(_G.Ox.ParryConfig.AutoParry)
				end
			end)
		end
	end
	LocalPlayer.CharacterAdded:Connect(function()
		task.wait(1)
		if _G.Ox.AutoParryCustom.GuiVisible then
			if _G.Ox.AutoParryCustom.Gui then
				_G.Ox.AutoParryCustom.Gui.Enabled = true
				UpdateCustomParryGUI(_G.Ox.ParryConfig.AutoParry)
			end
		end
	end)
	task.spawn(function()
		task.wait(1.5)
		CreateCustomParryGUI()
	end)
	_G.Ox.InstantTPGate = {
		Enabled = false,
		GateClientModule = nil,
		oldGateNew = nil,
		oldGateCanUse = nil
	}
	_G.Ox.KorlessMorph = {
		Enabled = false,
		Connection = nil
	}
	_G.Ox.SelfHeal = {
		Enabled = false
	}
	_G.Ox.FlowstateNoCD = {
		Enabled = false,
		Connection = nil,
		CharAddedConn = nil
	}
	_G.Ox.NoFall = {
		Enabled = false
	}
	_G.Ox.BulletBlockConfig = {
		Enabled = false
	}
	_G.Ox.BypassGate = {
		Enabled = false
	}
	_G.Ox.NextKiller = {
		Enabled = false,
		IndicatorGui = nil
	}
	_G.Ox.CounterParry = {
		Enabled = false,
		Distance = 15,
		Interval = 0.3,
		AnimId = "rbxassetid://117042998468241",
		Thread = nil,
		Track = nil
	}
	_G.Ox.AutoStalk = {
		Enabled = false,
		Range = 150,
		Conn = nil,
		LastFire = 0
	}
	_G.Ox.Crosshair = {
		Enabled = false,
		Size = 8,
		Thickness = 2,
		Color = Color3.fromRGB(255, 255, 255),
		Style = "Dot",
		OffsetX = 0,
		OffsetY = 0
	}
	_G.Ox.Spectator = {
		Enabled = false,
		Gui = nil,
		Label = nil
	}
	_G.Ox.Moonwalk = {
		Enabled = false,
		GuiVisible = false,
		Gui = nil,
		IsActive = false
	}
	_G.Ox.CrosshairGui = nil
	_G.Ox.CrosshairElements = {}
	_G.Ox.CrosshairCreated = false
	_G.Ox.LastCrosshairStyle = nil
	_G.Ox.Config = _G.Ox.Config or {}
	_G.Ox.Config.Surv_PerfectVault = false
	_G.Ox.autoVaultEnabled = false
	_G.Ox.autoPalletSlideEnabled = false
	_G.Ox.lastActionTime = 0
	_G.Ox.COOLDOWN = 1.5
	_G.Ox.StreamerMode = {
		Enabled = false,
		SpooferConns = {}
	}
	_G.Ox.InfinityZoom = {
		Enabled = false
	}
	_G.Ox.StretchRes = {
		Enabled = false,
		Amount = 0.67,
		Conn = nil
	}
	_G.Ox.CameraFOV = {
		Enabled = false,
		Value = 90,
		Connection = nil
	}
	_G.Ox.Auto = {
		SkillCheck = false,
		SkillCheckMode = "Legit"
	}
	_G.Ox.MapPredict = {
		Enabled = false
	}
	_G.Ox.KillerPerks = {
		Enabled = false,
		Gui = nil,
		Minimized = false
	}
	_G.Ox.Stun = {
		Enabled = false,
		Data = {},
		HitSoundEnabled = false,
		HitSoundVolume = 1,
		HitSoundId = "rbxassetid://106225491596534",
		HitSoundCooldown = 0.3,
		HitSoundLastTime = 0
	}
	_G.Ox.GodMode = false
	_G.Ox.BypassGenEnabled = false
	_G.Ox.BypassGenMode = "Manual Repair"
	_G.Ox.RepairAnimTrack = nil
	_G.Ox.ProcessedGens = {}
	_G.Ox.AutoRepairEnabled = false
	_G.Ox.AutoRepairThread = nil
	_G.Ox.AutoCurrentPoint = nil
	_G.Ox.AutoCurrentGenModel = nil
	_G.Ox.LastFireTime = 0
	_G.Ox.AutoFireInterval = 0.5
	_G.Ox.ScriptAlive = true
	_G.Ox.BypassToggleValue = false
	_G.Ox.UnlimitedVaultEnabled = false
	_G.Ox.State = _G.Ox.State or {}
	_G.Ox.State.busy = false
	_G.Ox.State.RandomMode_IsNormal = false
	_G.Ox.Connections = {
		SkillHeartbeat = nil
	}
	_G.Ox.Speed = {
		Enabled = false,
		Value = 0.1,
		Connection = nil,
		Loop = nil
	}
	_G.Ox.AutoRun = {
		PC = false,
		Mobile = false,
		MobileThread = nil
	}
	_G.Ox.Utility = {
		InvisEnabled = false,
		BandageEnabled = false,
		BandageSpeed = 50
	}
	_G.Ox.AntiHook = {
		Enabled = false,
		OffsetY = -250,
		Hz = 44,
		Interval = 0.022727272727272728,
		Remote = nil,
		Connection = nil,
		Accumulator = 0,
		SendCounter = 0,
		LastCounterTime = os.clock()
	}
	_G.Ox.ConfigData = {
		Surv_SkillFrequency = 10,
		Surv_SkillSpeed = 1
	}
	_G.Ox.Teleport = {
		GenIndex = 1,
		HookIndex = 1,
		GateIndex = 1,
		PalletIndex = 1,
		WindowIndex = 1
	}
	local t2 = {
		Generators = {},
		Hooks = {},
		Gates = {},
		Pallets = {},
		Windows = {}
	}
	local t3 = {
		Enabled = false,
		Conn = nil
	}
	if not _G.Ox.State then
		_G.Ox.State = {}
	end
	_G.Ox.State.ThirdPersonConn = nil
	local t4 = {
		["Left Arm"] = true,
		["Right Arm"] = true,
		LeftHand = true,
		RightHand = true,
		LeftLowerArm = true,
		RightLowerArm = true,
		LeftUpperArm = true,
		RightUpperArm = true
	}
	_G.Ox.FakePerks = {
		QuickRecoveryEnabled = false,
		PerfectLandingEnabled = false,
		FlowstateEnabled = false,
		FakeAdrenalineRush = false,
		PerkCooldown = 10,
		boostActive = false,
		perfectLandingBoostActive = false,
		fsOnCooldown = false,
		lastQRTime = 0,
		lastPLTime = 0,
		lastFSTime = 0,
		qrConnection = nil,
		plConnection = nil,
		fsConnection = nil,
		fsAnimConnection = nil,
		adrenalineOn = false,
		adrenalineConns = {},
		lastARTime = 0
	}
	_G.Ox.AutoPallet = {
		Enabled = false,
		Safety = true,
		Distance = 10,
		Cooldown = 2.5,
		LastDrop = 0,
		UsedPallets = {},
		Connection = nil
	}
	_G.Ox.FullBright = false
	_G.Ox.NoFog = false
	_G.Ox.NoShadow = false
	_G.Ox.TimeOfDayValue = 14
	_G.Ox.LowGFX = {
		Enabled = false,
		Textures = true,
		VisualEffects = true,
		Particles = true,
		Parts = true,
		Sky = false,
		Saved = {}
	}
	_G.Ox.AimConfig = {
		Aim_SilentVeilV2 = false,
		Veil_ShowFOV = true,
		SpearSmart_enable = false,
		Veil_FOV = 150,
		SPEAR_Speed = 165,
		SPEAR_Gravity = 103,
		SPEAR_AuraSpeed = 165,
		SPEAR_AuraGravity = 96.5,
		SPEAR_MaxDist = 500,
		Veil_LeadMultiplier = 1.4,
		AIM_TargetPart = "Torso",
		Pistol_BlockKnocked = false,
		LockAim = false,
		Flash_Silent = false,
		Flash_YOffset = 1.5
	}
	_G.Ox.SurvivorFOVFrame = nil
	_G.Ox.SurvivorFOVGui = nil
	_G.Ox.isAimbotHolding = false
	_G.Ox.lockedAimbotTarget = nil
	_G.Ox.survivorAimbotHighlight = nil
	_G.Ox.isKillerAimbotHolding = false
	_G.Ox.lockedKillerAimbotTarget = nil
	_G.Ox.killerAimbotHighlight = nil
	_G.Ox.Config = {
		SpearSmart_enable = false,
		Surv_Aimbot_Enabled = false,
		Surv_Aimbot_ShowFOV = true,
		Surv_Aimbot_Radius = 150,
		Surv_Aimbot_MaxDist = 300,
		Surv_Aimbot_Smoothness = 0.5,
		Surv_Aimbot_Predict = 0.01,
		Killer_Aimbot_Enabled = false,
		Killer_Aimbot_MaxDist = 12,
		Killer_Aimbot_Smoothness = 0.5
	}
	local u519 = false
	local u520 = false
	local u521 = false
	_G.Ox.ESPConfig = {
		Master = false,
		Player = false,
		Killer = false,
		Outline = false,
		Name = false,
		Distance = false,
		KillerWarn = false,
		ItemIcon = false,
		Generator = false,
		GeneratorName = true,
		Pallet = false,
		Hook = false,
		Gate = false,
		Window = false,
		SCP = false,
		HookCount = false,
		Status = false,
		MaxDistance = 1000
	}
	_G.Ox.ESPColors = {
		Player = Color3.fromRGB(60, 255, 60),
		Killer = Color3.fromRGB(255, 60, 60),
		Generator = Color3.fromRGB(255, 255, 0),
		GeneratorDone = Color3.fromRGB(0, 255, 0),
		Pallet = Color3.fromRGB(60, 255, 255),
		Hook = Color3.fromRGB(255, 105, 180),
		Gate = Color3.fromRGB(255, 255, 255),
		Window = Color3.fromRGB(60, 255, 255),
		SCP = Color3.fromRGB(255, 0, 255),
		Injured = Color3.fromRGB(255, 140, 0),
		Downed = Color3.fromRGB(255, 40, 40),
		Hooked = Color3.fromRGB(240, 240, 255)
	}
	local t5 = {
		Generators = {},
		Windows = {},
		Pallets = {},
		Hooks = {},
		Gates = {},
		SCPs = {}
	}
	local function v522(p30)
		if not p30 or p30 == "" then
			return "***"
		end
		if n7 == 542746161 then
			return string.sub(p30, 1, 3) .. "***"
		end
		n5 -= 359
		n3 += 1905
		n1 -= 599
		n7 -= 1322
		n4 = 1017006405
		n6 -= 1616
		bit32.bxor(nil, nil)
		upv177[nil] = nil - nil
	end
	local function v523()
		local v524 = tonumber(os.date("%H"))
		if v524 < 11 then
			return "Good Morning"
		end
		if v524 < 15 then
			return "Good Afternoon"
		end
		if v524 < 18 then
			return "Good Evening"
		end
		return "Good Night"
	end
	do
		GetRole = function()
			if not v18.Team then
				return "Unknown"
			end
			local Name = v18.Team.Name
			if Name == "Killer" then
				return "Killer"
			end
			if Name == "Survivors" then
				return "Survivor"
			end
			return "Spectator"
		end
	end
	do
		GetDistance = function(p31)
			local HumanoidRootPart = v18.Character and v18.Character:FindFirstChild("HumanoidRootPart")
			if HumanoidRootPart then
				return (p31 - HumanoidRootPart.Position).Magnitude
			end
			return math.huge
		end
	end
	do
		local function v525()
			local Character = LocalPlayer.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			if n6 ~= 295006491 then
				return Humanoid and math.floor(Humanoid.Health) or 0
			end
			n3 -= 882
			n7 -= 1270
			n1 = 187293342
			n5 += 1929
			n2 = 39730144
			n6 = 1026126720
			return (nil)()
		end
	end
	local function v526()
		if n4 ~= 409223859 then
			return #Players:GetPlayers() .. "/" .. Players.MaxPlayers
		end
		n2 -= 1768
		n1 -= 855
		n5 = 512969346
		n4 = 343830653
		n6 = 699672896
		n7 -= 1473
	end
	local function v527()
		return math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"
	end
	do
		local function v528()
			if not identifyexecutor then
				return "Unknown", "-"
			end
			local v529, v530 = identifyexecutor()
			return tostring(v529 or "Unknown"), tostring(v530 or "-")
		end
	end
	local v531
	do
		v531 = function(p32, p33)
			local n45 = 373223793
			if p32 then
				if type(p32.SetValue) == "function" then
					pcall(function()
						p32:SetValue(p33)
						if n7 == 542747400 then
							repeat
								n5 -= 668
								n6 = 271449311
								n7 -= 539
								n45 -= 1557
								n2 += 1216
								upv77[nil  ] = nil
							until true
						end
					end)
				end
			end
		end
	end
	ClearCrosshair = function()
		if _G.Ox.CrosshairGui then
			_G.Ox.CrosshairGui:Destroy()
			_G.Ox.CrosshairGui = nil
		end
		_G.Ox.CrosshairElements = {}
		_G.Ox.CrosshairCreated = false
		_G.Ox.LastCrosshairStyle = nil
		if n7 < n1 then
			return
		end
		n2 = 64406803
		n1 += 570
		n6 -= 1096
		n5 -= 478
		n4 -= 857
		n7 -= 210
		getfenv()[nil  ] = nil
		return nil
	end
	DrawCrosshair = function()
		if not _G.Ox.Crosshair.Enabled then
			if _G.Ox.CrosshairGui then
				_G.Ox.CrosshairGui.Enabled = false
			end
			return
		end
		if _G.Ox.CrosshairGui then
			_G.Ox.CrosshairGui.Enabled = true
		end
		if not (_G.Ox.LastCrosshairStyle == _G.Ox.Crosshair.Style and _G.Ox.CrosshairGui) then
			ClearCrosshair()
			_G.Ox.LastCrosshairStyle = _G.Ox.Crosshair.Style
		end
		if not _G.Ox.CrosshairCreated then
			_G.Ox.CrosshairCreated = true
			_G.Ox.CrosshairGui = Instance.new("ScreenGui")
			_G.Ox.CrosshairGui.Name = "CrosshairUI"
			_G.Ox.CrosshairGui.IgnoreGuiInset = true
			_G.Ox.CrosshairGui.ResetOnSpawn = false
			_G.Ox.CrosshairGui.DisplayOrder = 999
			_G.Ox.CrosshairGui.Parent = CoreGui
			local function createFrame(p34, p35)
				local Frame = Instance.new("Frame")
				Frame.BackgroundColor3 = _G.Ox.Crosshair.Color
				Frame.BorderSizePixel = 0
				Frame.AnchorPoint = Vector2.new(0.5, 0.5)
				Frame.Size = p34
				Frame.Position = p35
				Frame.Parent = _G.Ox.CrosshairGui
				return Frame
			end
			local uDim2 = UDim2.new(0.5, _G.Ox.Crosshair.OffsetX, 0.5, _G.Ox.Crosshair.OffsetY)
			if _G.Ox.Crosshair.Style == "Plus" then
				_G.Ox.CrosshairElements[1] = createFrame(UDim2.new(0, _G.Ox.Crosshair.Size * 2, 0, _G.Ox.Crosshair.Thickness), uDim2)
				_G.Ox.CrosshairElements[2] = createFrame(UDim2.new(0, _G.Ox.Crosshair.Thickness, 0, _G.Ox.Crosshair.Size * 2), uDim2)
			elseif _G.Ox.Crosshair.Style == "Dot" then
				local Frame = Instance.new("Frame")
				Frame.BackgroundColor3 = _G.Ox.Crosshair.Color
				Frame.BorderSizePixel = 0
				Frame.AnchorPoint = Vector2.new(0.5, 0.5)
				Frame.Size = UDim2.new(0, _G.Ox.Crosshair.Size, 0, _G.Ox.Crosshair.Size)
				Frame.Position = uDim2
				Instance.new("UICorner", Frame).CornerRadius = UDim.new(1, 0)
				Frame.Parent = _G.Ox.CrosshairGui
				_G.Ox.CrosshairElements[1] = Frame
			elseif _G.Ox.Crosshair.Style == "Circle" then
				local Frame = Instance.new("Frame")
				Frame.BackgroundTransparency = 1
				Frame.BorderSizePixel = 0
				Frame.AnchorPoint = Vector2.new(0.5, 0.5)
				Frame.Size = UDim2.new(0, _G.Ox.Crosshair.Size * 2, 0, _G.Ox.Crosshair.Size * 2)
				Frame.Position = uDim2
				Frame.Parent = _G.Ox.CrosshairGui
				local UIStroke = Instance.new("UIStroke")
				UIStroke.Color = _G.Ox.Crosshair.Color
				UIStroke.Thickness = _G.Ox.Crosshair.Thickness
				UIStroke.Parent = Frame
				Instance.new("UICorner", Frame).CornerRadius = UDim.new(1, 0)
				_G.Ox.CrosshairElements[1] = Frame
			end
		end
		local uDim2 = UDim2.new(0.5, _G.Ox.Crosshair.OffsetX, 0.5, _G.Ox.Crosshair.OffsetY)
		if _G.Ox.Crosshair.Style == "Plus" then
			if _G.Ox.CrosshairElements[1] then
				_G.Ox.CrosshairElements[1].Size = UDim2.new(0, _G.Ox.Crosshair.Size * 2, 0, _G.Ox.Crosshair.Thickness)
				_G.Ox.CrosshairElements[1].Position = uDim2
				_G.Ox.CrosshairElements[1].BackgroundColor3 = _G.Ox.Crosshair.Color
			end
			if _G.Ox.CrosshairElements[2] then
				_G.Ox.CrosshairElements[2].Size = UDim2.new(0, _G.Ox.Crosshair.Thickness, 0, _G.Ox.Crosshair.Size * 2)
				_G.Ox.CrosshairElements[2].Position = uDim2
				_G.Ox.CrosshairElements[2].BackgroundColor3 = _G.Ox.Crosshair.Color
			end
		elseif _G.Ox.Crosshair.Style ~= "Dot" then
			if _G.Ox.Crosshair.Style == "Circle" and _G.Ox.CrosshairElements[1] then
				_G.Ox.CrosshairElements[1].Size = UDim2.new(0, _G.Ox.Crosshair.Size * 2, 0, _G.Ox.Crosshair.Size * 2)
				_G.Ox.CrosshairElements[1].Position = uDim2
				local UIStroke = _G.Ox.CrosshairElements[1]:FindFirstChildOfClass("UIStroke")
				if UIStroke then
					UIStroke.Color = _G.Ox.Crosshair.Color
					UIStroke.Thickness = _G.Ox.Crosshair.Thickness
				end
			end
		elseif _G.Ox.CrosshairElements[1] then
			_G.Ox.CrosshairElements[1].Size = UDim2.new(0, _G.Ox.Crosshair.Size, 0, _G.Ox.Crosshair.Size)
			_G.Ox.CrosshairElements[1].Position = uDim2
			_G.Ox.CrosshairElements[1].BackgroundColor3 = _G.Ox.Crosshair.Color
		end
	end
	do
		local function v532()
			for _, player in ipairs(Players:GetPlayers()) do
				if player == v18 or player.Team and player.Team.Name == "Survivors" then
					continue
				end
				local Character = player.Character
				if not Character then
					continue
				end
				local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
				if HumanoidRootPart then
					return HumanoidRootPart
				end
			end
			return nil
		end
		local function v533(p36)
			if not _G.Ox.AutoPallet.Safety then
				return true
			end
			if not p36 then
				return false
			end
			if p36:GetAttribute("Knocked") == true then
				return false
			end
			if p36:GetAttribute("IsCarried") == true then
				return false
			end
			if p36:GetAttribute("IsHooked") == true then
				return false
			end
			local CheckInterractable = p36:FindFirstChild("CheckInterractable")
			if CheckInterractable then
				if CheckInterractable:GetAttribute("isVaulting") == true then
					return false
				end
				if CheckInterractable:GetAttribute("isRepairing") == true then
					return false
				end
				if CheckInterractable:GetAttribute("isUnhooking") == true then
					return false
				end
				if CheckInterractable:GetAttribute("isHealing") == true then
					return false
				end
				if CheckInterractable:GetAttribute("isSliding") == true then
					return false
				end
				if CheckInterractable:GetAttribute("isCarrying") == true then
					return false
				end
			end
			local Humanoid = p36:FindFirstChildOfClass("Humanoid")
			if Humanoid and Humanoid.Health <= 0 then
				return false
			end
			return true
		end
		local function v534(p37)
			local v535
			local n46 = 86964449
			local Distance = _G.Ox.AutoPallet.Distance
			local n47 = 24328352
			local n48 = 548493892
			local v536, v537, v538 = ipairs(t5.Pallets or {})
			local v539 = geniter(v536, v537, v538)
			local v540, v541
			while true do
				local v542 = table.pack(v539())
				if not v542[1] then
					return v535
				end
				v540 = v542[3]
				if not v540 or not v540.Parent then
					if n7 == 542746161 then
						continue
					end
					n7 += 533
					v541 = n5
					n5 = v541 - 1462
					n2 = 13303693
					n1 = 167401851
					n47 = 621076324
					n6 = 734899178
					n46 += 287
					n4 = 985741899
					n48 -= 985
					return (nil)()
				end
				if not _G.Ox.AutoPallet.UsedPallets[v540] then
					break
				end
			end
			while true do
				local PrimaryPartPallet = v540:FindFirstChild("PrimaryPartPallet") or v540:FindFirstChild("PalletPoint")
				PrimaryPartPallet = PrimaryPartPallet or v540:FindFirstChild("PalletPointSlide") or v540:FindFirstChildWhichIsA("BasePart")
				if PrimaryPartPallet then
					local ok, result = pcall(function()
						if n6 < n5 then
							return PrimaryPartPallet.Position
						end
						n47 -= 1745
						n5 = 1066558156
						n4 += 1663
						n6 = 869754075
						n48 -= 427
						n46 = 884302477
						return (nil)()
					end)
					if ok and result then
						local Magnitude = (p37.Position - result).Magnitude
						if Magnitude < Distance then
							Distance = Magnitude
							v535 = v540
						end
					end
				end
				while true do
					local v543 = table.pack(v539())
					if not v543[1] then
						return v535
					end
					v540 = v543[3]
					if not v540 or not v540.Parent then
						if n7 == 542746161 then
							continue
						end
						n7 += 533
						v541 = n5
						n5 = v541 - 1462
						n2 = 13303693
						n1 = 167401851
						n47 = 621076324
						n6 = 734899178
						n46 += 287
						n4 = 985741899
						n48 -= 985
						return (nil)()
					end
					if not _G.Ox.AutoPallet.UsedPallets[v540] then
						break
					end
				end
			end
		end
		local function v544(p38)
			if not p38 then
				return false
			end
			local PalletPointSlide = p38:FindFirstChild("PalletPointSlide") or p38:FindFirstChild("PalletPoint") or p38:FindFirstChildWhichIsA("BasePart")
			if not PalletPointSlide then
				return false
			end
			local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
			local PalletDropEvent = Remotes and Remotes:FindFirstChild("Pallet") and Remotes.Pallet:FindFirstChild("PalletDropEvent")
			if not PalletDropEvent then
				return false
			end
			pcall(function()
				PalletDropEvent:FireServer(PalletPointSlide)
			end)
			_G.Ox.AutoPallet.UsedPallets[p38] = true
			_G.Ox.AutoPallet.LastDrop = tick()
			return true
		end
		StartAutoPallet = function()
			if _G.Ox.AutoPallet.Connection then
				return
			end
			local v545
			local n49 = 110795695
			if n7 == n49 then
				n1 -= 668
				n6 = 977001481
				n7 += 177
				n5 -= 391
				n4 = 311272400
				n3 -= 1726
				v545[406] = nil
				v545[407] = nil
				v545[408] = nil
				v545[409] = nil
				v545[410] = nil
				v545[411] = nil
				v545[412] = nil
				v545[413] = nil
				v545[414] = nil
				v545[415] = nil
				v545[416] = nil
				v545[417] = nil
				v545[418] = nil
				v545[419] = nil
				v545[420] = nil
				v545[421] = nil
				v545[422] = nil
				v545[423] = nil
				v545[424] = nil
				v545[425] = nil
				v545[426] = nil
				v545[427] = nil
				v545[428] = nil
				v545[429] = nil
				v545[430] = nil
				v545[431] = nil
				v545[432] = nil
				v545[433] = nil
				v545[434] = nil
				v545[435] = nil
				v545[436] = nil
				v545[437] = nil
				v545[438] = nil
				v545[439] = nil
				v545[440] = nil
				v545[441] = nil
				v545[442] = nil
				v545[443] = nil
				v545[444] = nil
				v545[445] = nil
				v545[446] = nil
				v545[447] = nil
				v545[448] = nil
				v545[449] = nil
				v545[450] = nil
				v545[451] = nil
				v545[452] = nil
				v545[453] = nil
				v545[454] = nil
				v545[455] = nil
				v545[456] = nil
				v545[457] = nil
				v545[458] = nil
				v545[459] = nil
				v545[460] = nil
				v545[461] = nil
				v545[462] = nil
				v545[463] = nil
				v545[464] = nil
				v545[465] = nil
				v545[466] = nil
				v545[467] = nil
				v545[468] = nil
				v545[469] = nil
				v545[470] = nil
				v545[471] = nil
				v545[472] = nil
				v545[473] = nil
				v545[474] = nil
				v545[475] = nil
				v545[476] = nil
				v545[477] = nil
				v545[478] = nil
				v545[479] = nil
				v545[480] = nil
				v545[481] = nil
				v545[482] = nil
				v545[483] = nil
				v545[484] = nil
				v545[485] = nil
				v545[486] = nil
				v545[487] = nil
				v545[488] = nil
				v545[489] = nil
				v545[490] = nil
				v545[491] = nil
				v545[492] = nil
				v545[493] = nil
				v545[494] = nil
				v545[495] = nil
				v545[496] = nil
				v545[497] = nil
				v545[498] = nil
				v545[499] = nil
				v545[500] = nil
				v545[501] = nil
				v545[502] = nil
				v545[503] = nil
				v545[504] = nil
				v545[505] = nil
				v545[506] = nil
				v545[507] = nil
				v545[508] = nil
				v545[509] = nil
				v545[510] = nil
				v545[511] = nil
				v545[512] = nil
				v545[513] = nil
				v545[514] = nil
				v545[515] = nil
				v545[516] = nil
				v545[517] = nil
				v545[518] = nil
				v545[519] = nil
				v545[520] = nil
				v545[521] = nil
				v545[522] = nil
				v545[523] = nil
				v545[524] = nil
				v545[525] = nil
				v545[526] = nil
				v545[527] = nil
				v545[528] = nil
				v545[529] = nil
				v545[530] = nil
				v545[531] = nil
				v545[532] = nil
				v545[533] = nil
				v545[534] = nil
				v545[535] = nil
				v545[536] = nil
				v545[537] = nil
				v545[538] = nil
				v545[539] = nil
				v545[540] = nil
				v545[541] = nil
				v545[542] = nil
				v545[543] = nil
				v545[544] = nil
				v545[545] = nil
				v545[546] = nil
				v545[547] = nil
				v545[548] = nil
				v545[549] = nil
				v545[550] = nil
				v545[551] = nil
				v545[552] = nil
				v545[553] = nil
				v545[554] = nil
				v545[555] = nil
				v545[556] = nil
				v545[557] = nil
				v545[558] = nil
				v545[559] = nil
				v545[560] = nil
				v545[561] = nil
				v545[562] = nil
				v545[563] = nil
				v545[564] = nil
				v545[565] = nil
				v545[566] = nil
				v545[567] = nil
				v545[568] = nil
				v545[569] = nil
				v545[570] = nil
				v545[571] = nil
				v545[572] = nil
				v545[573] = nil
				v545[574] = nil
				v545[575] = nil
				v545[576] = nil
				v545[577] = nil
				v545[578] = nil
				v545[579] = nil
				v545[580] = nil
				v545[581] = nil
				v545[582] = nil
				v545[583] = nil
				v545[584] = nil
				v545[585] = nil
				v545[586] = nil
				v545[587] = nil
				v545[588] = nil
				v545[589] = nil
				v545[590] = nil
				v545[591] = nil
				v545[592] = nil
				v545[593] = nil
				v545[594] = nil
				v545[595] = nil
				v545[596] = nil
				v545[597] = nil
				v545[598] = nil
				v545[599] = nil
				v545[600] = nil
				v545[601] = nil
				v545[602] = nil
				v545[603] = nil
				v545[604] = nil
				v545[605] = nil
				v545[606] = nil
				v545[607] = nil
				v545[608] = nil
				v545[609] = nil
				v545[610] = nil
				v545[611] = nil
				v545[612] = nil
				v545[613] = nil
				v545[614] = nil
				v545[615] = nil
				v545[616] = nil
				v545[617] = nil
				v545[618] = nil
				v545[619] = nil
				v545[620] = nil
				v545[621] = nil
				v545[622] = nil
				v545[623] = nil
				v545[624] = nil
				v545[625] = nil
				v545[626] = nil
				v545[627] = nil
				v545[628] = nil
				v545[629] = nil
				v545[630] = nil
				v545[631] = nil
				v545[632] = nil
				v545[633] = nil
				v545[634] = nil
				v545[635] = nil
				v545[636] = nil
				v545[637] = nil
				v545[638] = nil
				v545[639] = nil
				v545[640] = nil
				v545[641] = nil
				v545[642] = nil
				v545[643] = nil
				v545[644] = nil
				v545[645] = nil
				v545[646] = nil
				v545[647] = nil
				v545[648] = nil
				v545[649] = nil
				v545[650] = nil
				v545[651] = nil
				v545[652] = nil
				v545[653] = nil
				v545[654] = nil
				v545[655] = nil
				v545[656] = nil
				v545[657] = nil
				v545[658] = nil
				v545[659] = nil
				v545[660] = nil
				v545[661] = nil
				v545[662] = nil
				v545[663] = nil
				v545[664] = nil
				v545[665] = nil
				v545[666] = nil
				v545[667] = nil
				v545[668] = nil
				v545[669] = nil
				v545[670] = nil
				v545[671] = nil
				v545[672] = nil
				v545[673] = nil
				v545[674] = nil
				v545[675] = nil
				v545[676] = nil
				v545[677] = nil
				v545[678] = nil
				v545[679] = nil
				v545[680] = nil
				v545[681] = nil
				v545[682] = nil
				v545[683] = nil
				v545[684] = nil
				v545[685] = nil
				v545[686] = nil
				v545[687] = nil
				v545[688] = nil
				v545[689] = nil
				v545[690] = nil
				v545[691] = nil
				v545[692] = nil
				v545[693] = nil
				v545[694] = nil
				v545[695] = nil
				v545[696] = nil
				v545[697] = nil
				v545[698] = nil
				v545[699] = nil
				v545[700] = nil
				v545[701] = nil
				v545[702] = nil
				v545[703] = nil
				v545[704] = nil
				v545[705] = nil
				v545[706] = nil
				v545[707] = nil
				v545[708] = nil
				v545[709] = nil
				v545[710] = nil
				v545[711] = nil
				v545[712] = nil
				v545[713] = nil
				v545[714] = nil
				v545[715] = nil
				v545[716] = nil
				v545[717] = nil
				v545[718] = nil
				v545[719] = nil
				v545[720] = nil
				v545[721] = nil
				v545[722] = nil
				v545[723] = nil
				v545[724] = nil
				v545[725] = nil
				v545[726] = nil
				v545[727] = nil
				v545[728] = nil
				v545[729] = nil
				v545[730] = nil
				v545[731] = nil
				v545[732] = nil
				v545[733] = nil
				v545[734] = nil
				v545[735] = nil
				v545[736] = nil
				v545[737] = nil
				v545[738] = nil
				v545[739] = nil
				v545[740] = nil
				v545[741] = nil
				v545[742] = nil
				v545[743] = nil
				v545[744] = nil
				v545[745] = nil
				v545[746] = nil
				v545[747] = nil
				v545[748] = nil
				v545[749] = nil
				v545[750] = nil
				v545[751] = nil
				v545[752] = nil
				v545[753] = nil
				v545[754] = nil
				v545[755] = nil
				v545[756] = nil
				v545[757] = nil
				v545[758] = nil
				v545[759] = nil
			else
				_G.Ox.AutoPallet.Connection = task.spawn(function()
					local n50 = 861336358
					local n51 = 885180528
					local n52
					local n53
					while _G.Ox.AutoPallet.Enabled do
						task.wait(0.3)
						if GetRole() == "Survivor" and not (tick() - _G.Ox.AutoPallet.LastDrop < _G.Ox.AutoPallet.Cooldown) then
							pcall(function()
								n52 = 257719503
								n53 = 160472786
								local Character = v18.Character
								local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
								local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
								if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then
									return
								end
								if not v533(Character) then
									return
								end
								local v546 = v532()
								if not v546 then
									return
								end
								if _G.Ox.AutoPallet.Distance < (HumanoidRootPart.Position - v546.Position).Magnitude then
									return
								end
								local v547 = v534(HumanoidRootPart)
								if n51 == n5 then
									n6 = 680695375
									n49 -= 982
									n52 -= 110
									n51 = 15866270
									n5 += 1285
									n53 += 1173
									n50 -= 118
									upv452[nil] = nil
								elseif v547 then
									v544(v547)
								end
							end)
						end
					end
				end)
			end
		end
	end
	StopAutoPallet = function()
		if _G.Ox.AutoPallet.Connection then
			task.cancel(_G.Ox.AutoPallet.Connection)
			_G.Ox.AutoPallet.Connection = nil
		end
		_G.Ox.AutoPallet.UsedPallets = {}
	end
	ToggleAutoPallet = function(p39)
		_G.Ox.AutoPallet.Enabled = p39
		if p39 then
			if GetRole() ~= "Survivor" then
				lib2:Notify({
					Title = "Auto Drop Pallet",
					Description = "You have to be a survivor!",
					Duration = 3
				})
				_G.Ox.AutoPallet.Enabled = false
				if AutoPalletToggle then
					v531(AutoPalletToggle, false)
				end
				return
			end
			_G.Ox.AutoPallet.UsedPallets = {}
			StartAutoPallet()
			lib2:Notify({
				Title = "Auto Drop Pallet",
				Description = "ON",
				Duration = 2
			})
		else
			StopAutoPallet()
			lib2:Notify({
				Title = "Auto Drop Pallet",
				Description = "OFF",
				Duration = 2
			})
		end
	end
	v18.CharacterAdded:Connect(function()
		_G.Ox.AutoPallet.UsedPallets = {}
		_G.Ox.AutoPallet.LastDrop = 0
		if n1 == n6 then
			n5 -= 964
			n1 += 1120
			n2 = 585071875
			n3 = 480567492
			n6 = 845712740
			n7 += 1482
		end
	end)
	DropAllPallets = function()
		local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local PalletDropEvent = Remotes and Remotes:FindFirstChild("Pallet") and Remotes.Pallet:FindFirstChild("PalletDropEvent")
		if not PalletDropEvent then
			lib2:Notify({
				Title = "Drop All Pallet",
				Description = "Remote not found!",
				Duration = 2
			})
			return
		end
		local t6 = {}
		local Map = workspace:FindFirstChild("Map")
		if not Map then
			lib2:Notify({
				Title = "Drop All Pallet",
				Description = "Map not found!",
				Duration = 2
			})
			return
		end
		for _, descendant in ipairs(Map:GetDescendants()) do
			if descendant.Name == "PalletPoint" and descendant:IsA("BasePart") then
				local Model = descendant:FindFirstAncestorWhichIsA("Model")
				if Model then
					if not t6[Model] then
						t6[Model] = {}
					end
					table.insert(t6[Model], descendant)
				end
			end
		end
		local n54 = 0
		for _, v in pairs(t6) do
			for _, v2 in ipairs(v) do
				pcall(function()
					PalletDropEvent:FireServer(v2)
					n54 += 1
				end)
			end
		end
		lib2:Notify({
			Title = "Drop All Pallet",
			Description = string.format("Dropped %d pallets!", n54),
			Duration = 3
		})
	end
	local v557
	do
		local n55 = 0
		local n56
		v557 = function(p40)
			n56 = 571113465
			if not p40 and tick() - n55 < 2 then
				return
			end
			n55 = tick()
			table.clear(t2.Generators)
			table.clear(t2.Windows)
			table.clear(t2.Pallets)
			table.clear(t2.Hooks)
			table.clear(t2.Gates)
			table.clear(t5.Generators)
			table.clear(t5.Windows)
			table.clear(t5.Pallets)
			table.clear(t5.Hooks)
			table.clear(t5.Gates)
			table.clear(t5.SCPs)
			local descendants = (workspace:FindFirstChild("Map") or workspace):GetDescendants()
			for i, descendant in ipairs(descendants) do
				if i % 200 == 0 then
					task.wait()
				end
				if descendant:IsA("Model") then
					local v563 = string.lower(descendant.Name)
					if v563 == "generator" then
						local GeneratorBody = descendant:FindFirstChild("GeneratorBody") or descendant:FindFirstChildWhichIsA("BasePart")
						if GeneratorBody then
							local t7 = {
								model = descendant,
								part = GeneratorBody
							}
							table.insert(t2.Generators, t7)
							table.insert(t5.Generators, t7)
						end
					elseif v563 == "hook" and descendant:FindFirstChild("HookPoint") then
						table.insert(t2.Hooks, descendant)
						table.insert(t5.Hooks, descendant)
					elseif v563 == "gate" and descendant:FindFirstChild("ExitLever") then
						table.insert(t2.Gates, descendant)
						table.insert(t5.Gates, descendant)
					elseif v563 == "window" then
						table.insert(t2.Windows, descendant)
						table.insert(t5.Windows, descendant)
					end
				elseif descendant:IsA("BasePart") and descendant.Name == "PrimaryPartPallet" then
					local Parent = descendant.Parent
					if Parent and not table.find(t2.Pallets, Parent) then
						table.insert(t2.Pallets, Parent)
						table.insert(t5.Pallets, Parent)
					end
				end
			end
			local descendants2 = workspace:GetDescendants()
			for i, v in ipairs(descendants2) do
				local v570 = t500_155_1[2]
				local v571 = t500_155_1[3]
				if i % 200 == 0 then
					if n4 == 666560820 then
						task.wait()
					else
						n7 += 1420
						n4 += 391
						n56 += 1188
						n2 = 736600655
						n5 = 828019432
						n6 += 421
						n3 += 936
						;(nil  )[v570] = v571
					end
				end
				if v:IsA("Model") then
					if string.match(string.lower(v.Name), "^scp") and not table.find(t5.SCPs, v) then
						table.insert(t5.SCPs, v)
					end
				end
			end
		end
	end
	local v572
	do
		v572 = function(p41)
			if not p41 then
				return
			end
			local Character = LocalPlayer.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			if HumanoidRootPart then
				local vector3 = Vector3.new(0, 3, 0)
				if p41:IsA("BasePart") then
					HumanoidRootPart.CFrame = p41.CFrame + vector3
				elseif p41:IsA("Model") then
					local BasePart = p41:FindFirstChildWhichIsA("BasePart")
					if BasePart then
						HumanoidRootPart.CFrame = BasePart.CFrame + vector3
					end
				end
				lib2:Notify({
					Title = "Teleport",
					Description = "Done!",
					Duration = 1
				})
			end
		end
	end
	ApplyFullBright = function()
		local Lighting = game:GetService("Lighting")
		if not Lighting then
			return
		end
		if _G.Ox.FullBright then
			Lighting.Brightness = 2.8
			Lighting.ClockTime = _G.Ox.TimeOfDayValue
			Lighting.FogEnd = 100000
			Lighting.Ambient = Color3.fromRGB(200, 200, 200)
			if n1 == n2 then
				n7 = 200621567
				n6 = 40515469
				n4 -= 1251
				n5 = 1054556464
				n2 += 590
				n1 -= 930
				return table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 357)
			end
			Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
		end
	end
	ApplyNoFog = function()
		local Lighting = game:GetService("Lighting")
		if not Lighting then
			return
		end
		if _G.Ox.NoFog then
			Lighting.FogStart = 0
			Lighting.FogEnd = 100000
			Lighting.FogColor = Color3.fromRGB(255, 255, 255)
			local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
			if Atmosphere then
				Atmosphere.Density = 0
				Atmosphere.Offset = 0
				Atmosphere.Glare = 0
				Atmosphere.Haze = 0
			end
		end
		if n3 == 660936134 then
			n2 -= 160
			n1 = 133004435
			n7 += 408
			n3 = 1020744626
			n4 = 829467846
			n5 -= 1636
		end
	end
	ApplyNoShadow = function()
		local Lighting = game:GetService("Lighting")
		if not Lighting then
			return
		end
		Lighting.GlobalShadows = not _G.Ox.NoShadow
	end
	do
		ReapplyPerformance = function()
			ApplyFullBright()
			ApplyNoFog()
			ApplyNoShadow()
		end
	end
	ReapplyPerformanceDelayed = function()
		task.spawn(function()
			ReapplyPerformance()
			task.wait(1.2)
			ReapplyPerformance()
			task.wait(2)
			ReapplyPerformance()
			task.wait(3)
			ReapplyPerformance()
		end)
	end
	do
		local n57
		local n58
		StartLightingGuard = function()
			n57 = 761198243
			n58 = 152099868
			if _G.Ox.LightingGuardConn then
				return
			end
			local n59 = 0
			if n2 == 352572737 then
				n57 += 1826
				n58 += 243
				n6 = 315885856
				n2 -= 1725
				n3 += 988
				n5 += 753
				n7 += 1321
				n4 = 484038437
				;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 253))
				;(nil)[nil] = nil
			else
				_G.Ox.LightingGuardConn = RunService.Heartbeat:Connect(function()
					if not (_G.Ox.FullBright or _G.Ox.NoFog or _G.Ox.NoShadow) then
						return
					end
					local now = tick()
					if now - n59 < 0.4 then
						return
					end
					n59 = now
					ReapplyPerformance()
				end)
			end
		end
	end
	StopLightingGuard = function()
		local v585
		local v586
		if _G.Ox.FullBright or _G.Ox.NoFog or _G.Ox.NoShadow then
			return
		end
		local n60 = 138393743
		local n61
		if not _G.Ox.LightingGuardConn then
			n61 = 590663945
			if 782233718 ~= n3 then
				return
			end
			local v589
			repeat
				n1 -= 285
				n5 += 96
				n2 = 260130921
				n3 = 581183142
				n60 -= 1917
				n7 += 841
				n61 -= 1780
				n4 = 818831523
				v589 = v589(nil)
			until false
			;(nil)[222] = nil
			;(nil)[223] = nil
			;(nil)[224] = nil
			;(nil)[225] = nil
			;(nil)[226] = nil
			;(nil)[227] = nil
			;(nil)[228] = nil
			;(nil)[229] = nil
			;(nil)[230] = nil
			;(nil)[231] = nil
			;(nil)[232] = nil
			;(nil)[233] = nil
			;(nil)[234] = nil
			;(nil)[235] = nil
			;(nil)[236] = nil
			;(nil)[237] = nil
			;(nil)[238] = nil
			;(nil)[239] = nil
			;(nil)[240] = nil
			;(nil)[241] = nil
			;(nil)[242] = nil
			;(nil)[243] = nil
			;(nil)[244] = nil
			;(nil)[245] = nil
			;(nil)[246] = nil
			;(nil)[247] = nil
			;(nil)[248] = nil
			;(nil)[249] = nil
			;(nil)[250] = nil
			;(nil)[251] = nil
			;(nil)[252] = nil
			;(nil)[253] = nil
			;(nil)[254] = nil
			;(nil)[255] = nil
			;(nil)[256] = nil
			;(nil)[257] = nil
			;(nil)[258] = nil
			;(nil)[259] = nil
			;(nil)[260] = nil
			;(nil)[261] = nil
			;(nil)[262] = nil
			;(nil)[263] = nil
			;(nil)[264] = nil
			;(nil)[265] = nil
			;(nil)[266] = nil
			;(nil)[267] = nil
			;(nil)[268] = nil
			;(nil)[269] = nil
			;(nil)[270] = nil
			;(nil)[271] = nil
			;(nil)[272] = nil
			;(nil)[273] = nil
			;(nil)[274] = nil
			;(nil)[275] = nil
			;(nil)[276] = nil
			;(nil)[277] = nil
			;(nil)[278] = nil
			;(nil)[279] = nil
			;(nil)[280] = nil
			;(nil)[281] = nil
			;(nil)[282] = nil
			;(nil)[283] = nil
			;(nil)[284] = nil
			;(nil)[285] = nil
			;(nil)[286] = nil
			;(nil)[287] = nil
			;(nil)[288] = nil
			;(nil)[289] = nil
			;(nil)[290] = nil
			;(nil)[291] = nil
			;(nil)[292] = nil
			;(nil)[293] = nil
			;(nil)[294] = nil
			;(nil)[295] = nil
			;(nil)[296] = nil
			;(nil)[297] = nil
			;(nil)[298] = nil
			;(nil)[299] = nil
			;(nil)[300] = nil
			;(nil)[301] = nil
			;(nil)[302] = nil
			;(nil)[303] = nil
			;(nil)[304] = nil
			;(nil)[305] = nil
			;(nil)[306] = nil
			;(nil)[307] = nil
			;(nil)[308] = nil
			;(nil)[309] = nil
			;(nil)[310] = nil
			;(nil)[311] = nil
			;(nil)[312] = nil
			;(nil)[313] = nil
			;(nil)[314] = nil
			;(nil)[315] = nil
			;(nil)[316] = nil
			;(nil)[317] = nil
			;(nil)[318] = nil
			;(nil)[319] = nil
			;(nil)[320] = nil
			;(nil)[321] = nil
			;(nil)[322] = nil
			;(nil)[323] = nil
			;(nil)[324] = nil
			;(nil)[325] = nil
			;(nil)[326] = nil
			;(nil)[327] = nil
			;(nil)[328] = nil
			;(nil)[329] = nil
			;(nil)[330] = nil
			;(nil)[331] = nil
			;(nil)[332] = nil
			;(nil)[333] = nil
			;(nil)[334] = nil
			;(nil)[335] = nil
			;(nil)[336] = nil
			;(nil)[337] = nil
			;(nil)[338] = nil
			;(nil)[339] = nil
			;(nil)[340] = nil
			;(nil)[341] = nil
			;(nil)[342] = nil
			;(nil)[343] = nil
			;(nil)[344] = nil
			;(nil)[345] = nil
			;(nil)[346] = nil
			;(nil)[347] = nil
			;(nil)[348] = nil
			;(nil)[349] = nil
			;(nil)[350] = nil
			;(nil)[351] = nil
			;(nil)[352] = nil
			;(nil)[353] = nil
			;(nil)[354] = nil
			;(nil)[355] = nil
			;(nil)[356] = nil
			;(nil)[357] = nil
			;(nil)[358] = nil
			;(nil)[359] = nil
			;(nil)[360] = nil
			;(nil)[361] = nil
			;(nil)[362] = nil
			;(nil)[363] = nil
			;(nil)[364] = nil
			;(nil)[365] = nil
			;(nil)[366] = nil
			;(nil)[367] = nil
			;(nil)[368] = nil
			;(nil)[369] = nil
			;(nil)[370] = nil
			;(nil)[371] = nil
			;(nil)[372] = nil
			;(nil)[373] = nil
			;(nil)[374] = nil
			;(nil)[375] = nil
			;(nil)[376] = nil
			;(nil)[377] = nil
			;(nil)[378] = nil
			;(nil)[379] = nil
			;(nil)[380] = nil
			;(nil)[381] = nil
			;(nil)[382] = nil
			;(nil)[383] = nil
			;(nil)[384] = nil
			;(nil)[385] = nil
			;(nil)[386] = nil
			;(nil)[387] = nil
			;(nil)[388] = nil
			;(nil)[389] = nil
			;(nil)[390] = nil
			;(nil)[391] = nil
			;(nil)[392] = nil
			;(nil)[393] = nil
			;(nil)[394] = nil
			;(nil)[395] = nil
			;(nil)[396] = nil
			;(nil)[397] = nil
			;(nil)[398] = nil
			;(nil)[399] = nil
			;(nil)[400] = nil
			;(nil)[401] = nil
			;(nil)[402] = nil
			;(nil)[403] = nil
			;(nil)[404] = nil
			;(nil)[405] = nil
			;(nil)[406] = nil
			;(nil)[407] = nil
			;(nil)[408] = nil
			;(nil)[409] = nil
			;(nil)[410] = nil
			;(nil)[411] = nil
			;(nil)[412] = nil
			;(nil)[413] = nil
			;(nil)[414] = nil
			;(nil)[415] = nil
			;(nil)[416] = nil
			;(nil)[417] = nil
			;(nil)[418] = nil
			;(nil)[419] = nil
			;(nil)[420] = nil
			;(nil)[421] = nil
			;(nil)[422] = nil
			;(nil)[423] = nil
			;(nil)[424] = nil
			;(nil)[425] = nil
			;(nil)[426] = nil
			;(nil)[427] = nil
			;(nil)[428] = nil
			;(nil)[429] = nil
			;(nil)[430] = nil
			;(nil)[431] = v589
			;(nil)[432] = nil
			;(nil)[433] = nil
			;(nil)[434] = nil
			;(nil)[435] = nil
			;(nil)[436] = nil
			;(nil)[437] = nil
			;(nil)[438] = nil
			;(nil)[439] = nil
			;(nil)[440] = nil
			;(nil)[441] = nil
			;(nil)[442] = nil
			;(nil)[443] = nil
			;(nil)[444] = nil
			;(nil)[445] = nil
			;(nil)[446] = nil
			;(nil)[447] = nil
			;(nil)[448] = nil
			;(nil)[449] = nil
			;(nil)[450] = nil
			;(nil)[451] = nil
			;(nil)[452] = nil
			;(nil)[453] = nil
			;(nil)[454] = nil
			;(nil)[455] = nil
			;(nil)[456] = nil
			;(nil)[457] = nil
			;(nil)[458] = nil
			;(nil)[459] = nil
			;(nil)[460] = nil
			;(nil)[461] = nil
			;(nil)[462] = nil
			;(nil)[463] = nil
			;(nil)[464] = nil
			;(nil)[465] = nil
			;(nil)[466] = nil
			;(nil)[467] = nil
			;(nil)[468] = nil
			;(nil)[469] = nil
			;(nil)[470] = nil
			;(nil)[471] = nil
			;(nil)[472] = nil
			;(nil)[473] = nil
			;(nil)[474] = nil
			;(nil)[475] = nil
			;(nil)[476] = nil
			;(nil)[477] = nil
			;(nil)[478] = nil
			;(nil)[479] = nil
			;(nil)[480] = nil
			;(nil)[481] = nil
			;(nil)[482] = nil
			;(nil)[483] = nil
			;(nil)[484] = nil
			;(nil)[485] = nil
			;(nil)[486] = nil
			;(nil)[487] = nil
			;(nil)[488] = nil
			;(nil)[489] = nil
			;(nil)[490] = nil
			;(nil)[491] = nil
			;(nil)[492] = nil
			;(nil)[493] = nil
			;(nil)[494] = nil
			;(nil)[495] = nil
			;(nil)[496] = nil
			;(nil)[497] = nil
			;(nil)[498] = nil
			;(nil)[499] = nil
			;(nil)[500] = nil
			;(nil)[501] = nil
			;(nil)[502] = nil
			;(nil)[503] = nil
			;(nil)[504] = nil
			;(nil)[505] = nil
			;(nil)[506] = nil
			;(nil)[507] = nil
			;(nil)[508] = nil
			;(nil)[509] = nil
			;(nil)[510] = nil
			;(nil)[511] = nil
			;(nil)[512] = nil
			;(nil)[513] = nil
			;(nil)[514] = nil
			;(nil)[515] = nil
			;(nil)[516] = nil
			;(nil)[517] = nil
			;(nil)[518] = nil
			;(nil)[519] = nil
			;(nil)[520] = nil
			;(nil)[521] = nil
			;(nil)[522] = nil
			;(nil)[523] = nil
			;(nil)[524] = nil
			;(nil)[525] = nil
			;(nil)[526] = nil
			;(nil)[527] = nil
			;(nil)[528] = nil
			;(nil)[529] = nil
			;(nil)[530] = nil
			;(nil)[531] = nil
			;(nil)[532] = nil
			;(nil)[533] = nil
			;(nil)[534] = nil
			;(nil)[535] = nil
			;(nil)[536] = nil
			;(nil)[537] = nil
			;(nil)[538] = nil
			;(nil)[539] = nil
			;(nil)[540] = nil
			;(nil)[541] = nil
			;(nil)[542] = nil
			;(nil)[543] = nil
			;(nil)[544] = nil
			;(nil)[545] = nil
			;(nil)[546] = nil
			;(nil)[547] = nil
			;(nil)[548] = nil
			;(nil)[549] = nil
			;(nil)[550] = nil
			;(nil)[551] = nil
			;(nil)[552] = nil
			;(nil)[553] = nil
			;(nil)[554] = nil
			;(nil)[555] = nil
			;(nil)[556] = nil
			;(nil)[557] = nil
			;(nil)[558] = nil
			;(nil)[559] = nil
			;(nil)[560] = nil
			;(nil)[561] = nil
			;(nil)[562] = nil
			;(nil)[563] = nil
			;(nil)[564] = nil
			;(nil)[565] = nil
			;(nil)[566] = nil
			;(nil)[567] = nil
			;(nil)[568] = nil
			;(nil)[569] = nil
			;(nil)[570] = nil
			;(nil)[571] = nil
			;(nil)[572] = nil
			;(nil)[573] = nil
			;(nil)[574] = nil
			;(nil)[575] = nil
			;(nil)[576] = nil
			;(nil)[577] = nil
			;(nil)[578] = nil
			;(nil)[579] = nil
			;(nil)[580] = nil
			;(nil)[581] = nil
			;(nil)[582] = nil
			;(nil)[583] = nil
			;(nil)[584] = nil
			;(nil)[585] = nil
			;(nil)[586] = nil
			;(nil)[587] = nil
			;(nil)[588] = nil
			;(nil)[589] = nil
			;(nil)[590] = nil
			;(nil)[591] = nil
			;(nil)[592] = nil
			;(nil)[593] = nil
			;(nil)[594] = nil
			;(nil)[595] = nil
			;(nil)[596] = nil
			;(nil)[597] = nil
			;(nil)[598] = nil
			;(nil)[599] = nil
			;(nil)[600] = nil
			;(nil)[601] = nil
			;(nil)[602] = nil
			;(nil)[603] = nil
			;(nil)[604] = nil
			;(nil)[605] = nil
			;(nil)[606] = nil
			;(nil)[607] = nil
			;(nil)[608] = nil
			;(nil)[609] = nil
			;(nil)[610] = nil
			;(nil)[611] = nil
			;(nil)[612] = nil
			;(nil)[613] = nil
			;(nil)[614] = nil
			;(nil)[615] = nil
			;(nil)[616] = nil
			;(nil)[617] = nil
			;(nil)[618] = nil
			;(nil)[619] = nil
			;(nil)[620] = nil
			;(nil)[621] = nil
			;(nil)[622] = nil
			;(nil)[623] = nil
			;(nil)[624] = nil
			;(nil)[625] = nil
			;(nil)[626] = nil
			;(nil)[627] = nil
			;(nil)[628] = nil
			;(nil)[629] = nil
			;(nil)[630] = nil
			;(nil)[631] = nil
			;(nil)[632] = nil
			;(nil)[633] = nil
			;(nil)[634] = nil
			;(nil)[635] = nil
			;(nil)[636] = nil
			;(nil)[637] = nil
			;(nil)[638] = nil
			;(nil)[639] = nil
			;(nil)[640] = nil
			;(nil)[641] = nil
			;(nil)[642] = nil
			;(nil)[643] = nil
			;(nil)[644] = nil
			;(nil)[645] = nil
			;(nil)[646] = nil
			;(nil)[647] = nil
			;(nil)[648] = nil
			;(nil)[649] = nil
			;(nil)[650] = nil
			;(nil)[651] = nil
			;(nil)[652] = nil
			;(nil)[653] = nil
			;(nil)[654] = nil
			;(nil)[655] = nil
			;(nil)[656] = nil
			;(nil)[657] = nil
			;(nil)[658] = nil
			;(nil)[659] = nil
			;(nil)[660] = nil
			;(nil)[661] = nil
			;(nil)[662] = nil
			;(nil)[663] = nil
			;(nil)[664] = nil
			;(nil)[665] = nil
			;(nil)[666] = nil
			;(nil)[667] = nil
			;(nil)[668] = nil
			;(nil)[669] = nil
			;(nil)[670] = nil
			;(nil)[671] = nil
			;(nil)[672] = nil
			;(nil)[673] = nil
			;(nil)[674] = nil
			;(nil)[675] = nil
			;(nil)[676] = nil
			;(nil)[677] = nil
			;(nil)[678] = nil
			;(nil)[679] = nil
			;(nil)[680] = nil
			;(nil)[681] = nil
			;(nil)[682] = nil
			;(nil)[683] = nil
			;(nil)[684] = nil
			;(nil)[685] = nil
			;(nil)[686] = nil
			;(nil)[687] = nil
			;(nil)[688] = nil
			;(nil)[689] = nil
			;(nil)[690] = nil
			;(nil)[691] = nil
			;(nil)[692] = nil
			;(nil)[693] = nil
			;(nil)[694] = nil
			;(nil)[695] = nil
			;(nil)[696] = nil
			;(nil)[697] = nil
			;(nil)[698] = nil
			;(nil)[699] = nil
			;(nil)[700] = nil
			;(nil)[701] = nil
			;(nil)[702] = nil
			;(nil)[703] = nil
			;(nil)[704] = nil
			;(nil)[705] = nil
			;(nil)[706] = nil
			;(nil)[707] = nil
			;(nil)[708] = nil
			;(nil)[709] = nil
			;(nil)[710] = nil
			;(nil)[711] = nil
			;(nil)[712] = nil
			;(nil)[713] = nil
			;(nil)[714] = nil
			;(nil)[715] = nil
			;(nil)[716] = nil
			;(nil)[717] = nil
			;(nil)[718] = nil
			;(nil)[719] = nil
			;(nil)[720] = nil
			local v590 = nil + Q_0
			if Q_0 <= 0 then
				if not (v590 >= N_0) then
					return
				end
			elseif not (v590 <= N_0) then
				return
			end
			v585[175] = 115
			v586[117] = 173
			n61.LightingGuardConn = nil
			return
		end
		_G.Ox.LightingGuardConn:Disconnect()
		n61 = _G.Ox
		n61.LightingGuardConn = nil
	end
	if not _G.Ox.LightingChildConn then
		_G.Ox.LightingChildConn = game:GetService("Lighting").ChildAdded:Connect(function(child)
			if not (_G.Ox.FullBright or _G.Ox.NoFog) then
				return
			end
			local n62 = 353335760
			if n4 == n62 then
				n5 += 1601
				n1 = 635029506
				n2 = 319431758
				n4 += 1836
				n3 = 66199575
				n7 = 602818444
			else
				task.defer(function()
					if child:IsA("Atmosphere") and _G.Ox.NoFog then
						child.Density = 0
						child.Offset = 0
						child.Glare = 0
						child.Haze = 0
					end
					ReapplyPerformance()
				end)
			end
		end)
	end
	do
		local n63
		local function v593(p42, p43, p44)
			n63 = 666390576
			table.insert(_G.Ox.LowGFX.Saved, {
				obj = p42,
				kind = p43,
				extra = p44
			})
			if n5 == n2 then
				n5 += 1306
				n4 = 683402394
				n3 += 1505
				n2 = 578756481
				n1 = 740154689
				n63 -= 1598
				n7 = 314035726
				getfenv()[nil  ] = nil
				n7()
			end
		end
		LowGFX_ProcessOne = function(p45)
			if _G.Ox.LowGFX.Enabled then
				if p45 then
					local LowGFX = _G.Ox.LowGFX
					if LowGFX.Parts and (p45:IsA("BasePart") or p45:IsA("UnionOperation") or p45:IsA("MeshPart")) and p45.Material ~= Enum.Material.SmoothPlastic then
						v593(p45, "Part", p45.Material)
						p45.Material = Enum.Material.SmoothPlastic
					end
					if LowGFX.Particles and (p45:IsA("ParticleEmitter") or p45:IsA("Smoke") or p45:IsA("Explosion") or p45:IsA("Sparkles") or p45:IsA("Fire")) and p45.Enabled ~= false then
						v593(p45, "Particle", true)
						p45.Enabled = false
					end
					if LowGFX.VisualEffects then
						if (p45:IsA("BloomEffect") or p45:IsA("BlurEffect") or p45:IsA("DepthOfFieldEffect") or p45:IsA("SunRaysEffect") or p45:IsA("ColorCorrectionEffect")) and p45.Enabled ~= false then
							v593(p45, "VFX", true)
							p45.Enabled = false
						end
					end
					if LowGFX.Textures and (p45:IsA("Decal") or p45:IsA("Texture")) and p45.Texture ~= "" then
						v593(p45, "Texture", p45.Texture)
						p45.Texture = ""
					end
					if LowGFX.Sky and p45:IsA("Sky") then
						v593(p45, "Sky", p45.Parent)
						p45.Parent = nil
					end
					return
				end
			end
		end
	end
	ApplyLowGFX = function()
		if not _G.Ox.LowGFX.Enabled then
			return
		end
		local v595, v596, v597 = ipairs({
			workspace,
			game:GetService("Lighting")
		})
		local v598 = geniter(v595, v596, v597)
		local v599 = table.pack(v598())
		if v599[1] then
			local v600 = v599[3]
			while true do
				local descendants = v600:GetDescendants()
				for i, descendant in ipairs(descendants) do
					if i % 250 == 0 then
						task.wait()
					end
					LowGFX_ProcessOne(descendant)
				end
				local v604 = table.pack(v598())
				if not v604[1] then
					break
				end
				v600 = v604[3]
			end
		end
	end
	RestoreLowGFX = function()
		local v605, v606, v607 = ipairs(_G.Ox.LowGFX.Saved)
		local v608 = geniter(v605, v606, v607)
		while true do
			local v609 = table.pack(v608())
			if not v609[1] then
				table.clear(_G.Ox.LowGFX.Saved)
				return
			end
			local v610 = v609[3]
			local obj = v610.obj
			if n5 == n1 then
				break
			end
			if not obj or not obj.Parent then
				continue
			end
			local exitTo
			repeat
				pcall(function()
					if v610.kind == "Part" then
						obj.Material = v610.extra
					elseif v610.kind == "Particle" or v610.kind == "VFX" then
						obj.Enabled = v610.extra
					elseif v610.kind == "Texture" then
						obj.Texture = v610.extra
					elseif v610.kind == "Sky" and v610.extra then
						obj.Parent = v610.extra
					end
				end)
				exitTo = nil
				while true do
					local v613 = table.pack(v608())
					if not v613[1] then
						break
					end
					v610 = v613[3]
					obj = v610.obj
					if obj and obj.Parent then
						exitTo = 1
						break
					end
				end
			until exitTo ~= 1
			table.clear(_G.Ox.LowGFX.Saved)
			return
		end
		n1 += 281
		n4 += 2020
		n3 -= 1864
		n7 += 697
		n6 += 1438
		n5 = 808137438
		;(nil)()
	end
	ToggleLowGFX = function(p46)
		_G.Ox.LowGFX.Enabled = p46
		if p46 then
			task.spawn(ApplyLowGFX)
			lib2:Notify({
				Title = "Remove Texture",
				Description = "ON - low GFX",
				Duration = 2
			})
		else
			RestoreLowGFX()
			lib2:Notify({
				Title = "Remove Texture",
				Description = "OFF - textures restored",
				Duration = 2
			})
		end
	end
	if not _G.Ox.LowGFX.StreamConn then
		_G.Ox.LowGFX.StreamConn = workspace.DescendantAdded:Connect(function(descendant)
			local n64 = 610106297
			if not _G.Ox.LowGFX.Enabled then
				return
			end
			local n65 = 630136954
			task.defer(function()
				local n66 = 432767161
				LowGFX_ProcessOne(descendant)
				if n2 == n66 then
					n65 -= 261
					n5 = 172037258
					n64 -= 821
					n2 = 361199125
					n4 -= 1392
				end
			end)
		end)
	end
	CreateSpectatorUI = function()
		if _G.Ox.Spectator.Gui then
			_G.Ox.Spectator.Gui:Destroy()
			_G.Ox.Spectator.Gui = nil
		end
		_G.Ox.Spectator.Gui = Instance.new("ScreenGui")
		_G.Ox.Spectator.Gui.Name = "SpectatorCounter"
		_G.Ox.Spectator.Gui.ResetOnSpawn = false
		_G.Ox.Spectator.Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
		local Frame = Instance.new("Frame")
		local n67 = 314254717
		Frame.Name = "MainBox"
		Frame.AnchorPoint = Vector2.new(0.5, 1)
		Frame.Position = UDim2.new(0.5, 0, 0, -10)
		Frame.Size = UDim2.new(0, 68, 0, 22)
		Frame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
		Frame.BackgroundTransparency = 0.25
		Frame.BorderSizePixel = 0
		Frame.Parent = _G.Ox.Spectator.Gui
		Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
		local UIGradient = Instance.new("UIGradient")
		UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		})
		UIGradient.Parent = Frame
		local UIListLayout = Instance.new("UIListLayout", Frame)
		UIListLayout.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		UIListLayout.Padding = UDim.new(0, 6)
		local ImageLabel = Instance.new("ImageLabel", Frame)
		ImageLabel.Size = UDim2.new(0, 15, 0, 15)
		ImageLabel.BackgroundTransparency = 1
		ImageLabel.Image = "rbxassetid://13321848320"
		ImageLabel.ImageColor3 = Color3.fromRGB(225, 225, 225)
		if n67 < n3 then
			_G.Ox.Spectator.Label = Instance.new("TextLabel", Frame)
			_G.Ox.Spectator.Label.BackgroundTransparency = 1
			_G.Ox.Spectator.Label.Font = Enum.Font.GothamMedium
			_G.Ox.Spectator.Label.Text = "0"
			_G.Ox.Spectator.Label.TextColor3 = Color3.fromRGB(240, 240, 240)
			_G.Ox.Spectator.Label.TextSize = 13
			_G.Ox.Spectator.Label.AutomaticSize = Enum.AutomaticSize.X
			return
		end
		n5 = 44879953
		n2 = 562355695
		n7 -= 1157
		n4 = 538886055
		n3 += 957
		n6 += 1848
		return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
	end
	UpdateSpectatorCount = function()
		if _G.Ox.Spectator.Enabled then
			if _G.Ox.Spectator.Label then
				local n68 = 0
				for _, player in ipairs(Players:GetPlayers()) do
					if player.Team and player.Team.Name == "Spectator" then
						n68 += 1
					end
				end
				_G.Ox.Spectator.Label.Text = tostring(n68)
				local MainBox = _G.Ox.Spectator.Gui and _G.Ox.Spectator.Gui:FindFirstChild("MainBox")
				if MainBox then
					MainBox.Size = UDim2.new(0, 55 + (n68 >= 10 and 8 or 0) + (n68 >= 100 and 8 or 0), 0, 22)
				end
				return
			end
		end
	end
	StartSpectatorInfo = function()
		if _G.Ox.Spectator.Enabled then
			return
		end
		_G.Ox.Spectator.Enabled = true
		CreateSpectatorUI()
		UpdateSpectatorCount()
		task.spawn(function()
			while _G.Ox.Spectator.Enabled do
				UpdateSpectatorCount()
				task.wait(1.2)
			end
		end)
		lib2:Notify({
			Title = "Spectator Info",
			Description = "✅ Shown in the top corner",
			Duration = 3
		})
	end
	StopSpectatorInfo = function()
		_G.Ox.Spectator.Enabled = false
		if _G.Ox.Spectator.Gui then
			_G.Ox.Spectator.Gui:Destroy()
			_G.Ox.Spectator.Gui = nil
			_G.Ox.Spectator.Label = nil
		end
		lib2:Notify({
			Title = "Spectator Info",
			Description = "Display dimatikan",
			Duration = 2
		})
	end
	local v626
	do
		local n69
		v626 = function(...)
			local v628 = ...
			n69 = 918998608
			if v628 then
				StartSpectatorInfo()
			else
				StopSpectatorInfo()
			end
			if n5 < n69 then
				return
			end
			n5 = 822482617
			n69 = 552934347
			n4 -= 482
			n3 = 908752843
			n2 -= 1722
			n1 = 274870950
			n7 = 7109734
			return (select(199, ...))
		end
	end
	ScanMapESP = function(p47)
		v557(p47)
	end
	ForceRefreshMap = function()
		v557(true)
		if _G.Ox.ESPConfig.Master then
			ClearAllESP()
			task.wait(0.1)
			UpdatePlayerESP()
			UpdateSCPESP()
			UpdateStaticESP()
		end
	end
	task.spawn(function()
		task.wait(2)
		ScanMapESP()
	end)
	v18.CharacterAdded:Connect(function()
		task.wait(1.5)
		ScanMapESP()
		if _G.Ox.ESPConfig.Master then
			task.spawn(function()
				task.wait(0.5)
				ClearAllESP()
				task.wait(0.2)
				UpdatePlayerESP()
				UpdateSCPESP()
				UpdateStaticESP()
			end)
		end
	end)
	workspace.ChildAdded:Connect(function(child)
		if child.Name == "Map" then
			task.wait(1)
			ScanMapESP(true)
			if _G.Ox.ESPConfig.Master then
				pcall(UpdatePlayerESP)
				pcall(UpdateSCPESP)
				pcall(UpdateStaticESP)
			end
			ReapplyPerformanceDelayed()
			if _G.Ox.LowGFX.Enabled then
				table.clear(_G.Ox.LowGFX.Saved)
				task.wait(1.5)
				ApplyLowGFX()
				task.wait(2.5)
				if _G.Ox.LowGFX.Enabled then
					ApplyLowGFX()
				end
			end
		end
	end)
	do
		local n70
		task.spawn(function()
			n70 = 545467078
			while _G.Ox.ScriptAlive do
				task.wait(40)
				if _G.Ox.ESPConfig.Master then
					ScanMapESP()
					if _G.Ox.ESPConfig.Master then
						pcall(UpdateStaticESP)
						pcall(UpdatePlayerESP)
						pcall(UpdateSCPESP)
					end
				end
			end
			if n2 == n5 then
				n4 += 888
				n7 -= 1261
				n3 = 851289857
				n5 -= 294
				n1 = 836852308
				n70 -= 1356
				n2 = 180761883
				upv473[nil  ] = nil
				upv205[nil  ] = nil
			end
		end)
	end
	local v630, v631
	do
		local function v632()
			local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
			if not PlayerGui2 then
				return nil
			end
			local SurvivorMob = PlayerGui2:FindFirstChild("Survivor-mob")
			if not SurvivorMob then
				return nil
			end
			local Controls = SurvivorMob:FindFirstChild("Controls")
			if not Controls then
				return nil
			end
			local sprint = Controls:FindFirstChild("sprint")
			if not sprint then
				return nil
			end
			if sprint:IsA("GuiButton") then
				return sprint
			end
			local icon = sprint:FindFirstChild("icon")
			if icon and icon:IsA("GuiButton") then
				return icon
			end
			if icon and icon.Parent then
				if icon.Parent:IsA("GuiButton") then
					return icon.Parent
				end
			end
			if sprint.Parent then
				if sprint.Parent:IsA("GuiButton") then
					return sprint.Parent
				end
			end
			return sprint
		end
		local function v638()
			local v639 = v632()
			local n71 = 550659479
			if not v639 then
				return false
			end
			pcall(function()
				if type(firesignal) == "function" then
					firesignal(v639.MouseButton1Click)
					firesignal(v639.MouseButton1Down)
					task.wait(0.04)
					firesignal(v639.MouseButton1Up)
				else
					local AbsolutePosition = v639.AbsolutePosition
					local AbsoluteSize = v639.AbsoluteSize
					local guiInset = GuiService:GetGuiInset()
					local v644 = AbsolutePosition.X + AbsoluteSize.X / 2 + guiInset.X
					local v645 = AbsolutePosition.Y + AbsoluteSize.Y / 2 + guiInset.Y
					VirtualInputManager:SendTouchEvent(9901, 0, v644, v645)
					task.wait(0.04)
					VirtualInputManager:SendTouchEvent(9901, 2, v644, v645)
				end
			end)
			if n2 ~= 352572653 then
				return true
			end
			n7 = 780047924
			n1 -= 121
			n4 += 719
			n2 += 1999
			n5 += 1786
			n71 -= 1436
			n6 -= 165
			upv268[nil  ] = nil
			LPH_CRASH()
		end
		local function v646()
			local Character = LocalPlayer.Character
			if not Character then
				return false
			end
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if not Humanoid then
				return false
			end
			if Humanoid.MoveDirection.Magnitude > 0.12 then
				return true
			end
			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
			if HumanoidRootPart then
				local AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity
				if Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z).Magnitude > 1.5 then
					return true
				end
			end
			return false
		end
		local function v651()
			local Character = LocalPlayer.Character
			if Character then
				return Character:GetAttribute("Crouching") == true or Character:GetAttribute("Crouchingserver") == true
			end
			return false
		end
		local function v653()
			local Character = LocalPlayer.Character
			if Character then
				return Character:GetAttribute("Sprinting") == true or Character:GetAttribute("IsRunning") == true
			end
			return false
		end
		local n72
		v630 = function()
			n72 = 938627678
			local n73 = 210058861
			if _G.Ox.AutoRun.MobileThread then
				if n3 ~= n1 then
					return
				end
				n5 = 218599146
				n7 = 666594959
				n2 -= 1217
				n6 = 377542685
				n73 -= 650
				n1 = 283974692
				n72 -= 675
				n3 -= 24
			end
			_G.Ox.AutoRun.MobileThread = task.spawn(function()
				while true do
					if not _G.Ox.AutoRun.Mobile then
						_G.Ox.AutoRun.MobileThread = nil
						local n74 = 696852038
						if n74 == n2 then
							n72 = 800233840
							n73 -= 1619
							n2 += 518
							n5 -= 1870
							n6 = 463730152
							n1 += 769
							getfenv()[nil  ] = nil
							upv254[nil] = nil
							upv504[nil] = nil
							;(nil)()
							task.wait(0.12)
							continue
						end
						break
					end
					local v658 = v646()
					local v659 = v651()
					local v660 = v653()
					if not v659 then
						if not v658 or v660 then
							if not v658 and v660 then
								v638()
							end
						else
							v638()
						end
					elseif v660 then
						v638()
					end
					task.wait(0.12)
				end
			end)
		end
		v631 = function()
			_G.Ox.AutoRun.Mobile = false
			if _G.Ox.AutoRun.MobileThread then
				task.cancel(_G.Ox.AutoRun.MobileThread)
				_G.Ox.AutoRun.MobileThread = nil
			end
			local n75 = 490691922
			if v653() then
				v638()
			end
			if not (n75 < n3) then
				n1 += 1349
				n3 -= 1954
				n7 += 1883
				n6 -= 1269
				n5 = 451622610
				n2 -= 503
				;(nil)(nil)
			end
		end
	end
	local n76
	task.spawn(function()
		n76 = 97629381
		while _G.Ox.ScriptAlive do
			task.wait(0.1)
			if not _G.Ox.ScriptAlive then
				break
			end
			if not UserInputService.TouchEnabled and not (tick() - _G.Ox.lastActionTime < _G.Ox.COOLDOWN) then
				local autoVaultEnabled = _G.Ox.autoVaultEnabled
				local autoPalletSlideEnabled = _G.Ox.autoPalletSlideEnabled
				if autoVaultEnabled or autoPalletSlideEnabled then
					local pcprompts = PlayerGui:FindFirstChild("pcprompts")
					local Frame = pcprompts and pcprompts:FindFirstChild("Frame")
					if Frame then
						local VaultPromptGui = Frame:FindFirstChild("VaultPromptGui")
						local PalletSlidePromptGui = Frame:FindFirstChild("PalletSlidePromptGui")
						if autoVaultEnabled and VaultPromptGui and VaultPromptGui.Visible or autoPalletSlideEnabled and PalletSlidePromptGui and PalletSlidePromptGui.Visible then
							VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
							task.wait(0.01)
							VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
							_G.Ox.lastActionTime = tick()
						end
					end
				end
			end
		end
		if n2 < n3 then
			return
		end
		n3 -= 987
		n2 += 889
		n76 += 1982
		n5 = 313881970
		n6 += 118
		n4 = 733896269
		n7 -= 610
		LPH_CRASH()
	end)
	do
		local function v669()
			if not UserInputService.TouchEnabled then
				return
			end
			local SurvivorMob = PlayerGui:FindFirstChild("Survivor-mob") or PlayerGui:WaitForChild("Survivor-mob", 8)
			local n77 = 358172312
			if not SurvivorMob then
				return
			end
			local Controls = SurvivorMob:FindFirstChild("Controls") or SurvivorMob:WaitForChild("Controls", 5)
			local action = Controls and (Controls:FindFirstChild("action") or Controls:WaitForChild("action", 5))
			if not action then
				return
			end
			local n78 = 372644746
			local t8 = {
				vault = true,
				palletvault = true,
				palletslide = true,
				slide = true
			}
			local function v676(p48)
				if not p48:IsA("ImageLabel") then
					if not p48:IsA("ImageButton") then
						return
					end
				end
				local v677 = p48.Name:lower()
				if t8[v677] then
					p48:GetPropertyChangedSignal("Visible"):Connect(function()
						if not p48.Visible then
							return
						end
						if tick() - _G.Ox.lastActionTime < _G.Ox.COOLDOWN then
							return
						end
						local v678 = v677:find("vault") and not v677:find("pallet")
						local pos = v677:find("pallet") or v677:find("slide")
						if v678 and _G.Ox.autoVaultEnabled or pos and _G.Ox.autoPalletSlideEnabled then
							pcall(function()
								firesignal(action.MouseButton1Down)
								task.wait(0.01)
								firesignal(action.MouseButton1Up)
							end)
							_G.Ox.lastActionTime = tick()
						end
					end)
					return
				end
			end
			for _, child in pairs(action:GetChildren()) do
				v676(child)
			end
			local n79
			action.ChildAdded:Connect(function(child)
				n79 = 902211361
				task.wait()
				v676(child)
				if n78 < n1 then
					return
				end
				n5 = 494744427
				n79 += 677
				n78 = 85469849
				n2 = 234919157
				n1 = 329375680
				n77 -= 1615
				upv443 = nil
				bit32.rshift(nil, nil  )
				getfenv()[nil  ] = nil
				return (nil)()
			end)
		end
		task.spawn(v669)
		LocalPlayer.CharacterAdded:Connect(function()
			task.wait(2)
			v669()
		end)
		PlayerGui.ChildAdded:Connect(function(child)
			if child.Name == "Survivor-mob" then
				task.wait(1)
				v669()
			end
			if n7 == 542746888 then
				n5 -= 1842
				n4 = 391654970
				n6 = 637427987
				n2 = 1013586858
				n1 = 373593923
				n7 = 253239518
				bit32.bxor(nil, nil)
			end
		end)
	end
	do
		local function v683()
			local Character = LocalPlayer.Character
			if not Character then
				return
			end
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if not Humanoid then
				return
			end
			if _G.Ox.Speed.Enabled then
				local MoveDirection = Humanoid.MoveDirection
				if MoveDirection.Magnitude > 0 then
					local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
					if HumanoidRootPart then
						HumanoidRootPart.CFrame += MoveDirection * _G.Ox.Speed.Value
					end
				end
			end
		end
	end
	local function v688()
		local n80 = 756592569
		if n80 == n2 then
			n2 += 405
			n6 = 372523609
			n3 = 592546389
			n7 -= 1951
			n5 += 962
			n4 = 1003438970
			bit32.rshift(nil, nil  )
			local v690
			;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 370))
			bit32.band(v690, nil  )
		else
			task.spawn(function()
				local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
				local KillerPerks = Remotes and Remotes:WaitForChild("KillerPerks", 5)
				local kingscourge = KillerPerks and KillerPerks:WaitForChild("kingscourge", 5)
				local KingScourgeStart = kingscourge and kingscourge:WaitForChild("KingScourgeStart", 5)
				if KingScourgeStart then
					KingScourgeStart.OnClientEvent:Connect(function()
						if _G.Ox.Auto.SkillCheckMode == "Random" then
							_G.Ox.State.RandomMode_IsNormal = true
						end
					end)
				end
			end)
		end
	end
	v688()
	local v787
	do
		local function v788()
			local v789 = PlayerGui
			if not v789 then
				return nil
			end
			local SurvivorMob = v789:FindFirstChild("Survivor-mob")
			if not SurvivorMob then
				return nil
			end
			local Controls = SurvivorMob:FindFirstChild("Controls")
			if not Controls then
				return nil
			end
			local action = Controls:FindFirstChild("action")
			return action or Controls:FindFirstChild("check")
		end
		local function v793()
			local v794 = v788()
			if v794 and v794:IsA("GuiObject") and v794.Visible then
				if type(firesignal) == "function" then
					pcall(function()
						firesignal(v794.MouseButton1Down)
						task.wait(0.005)
						firesignal(v794.MouseButton1Up)
					end)
					return true
				end
			end
			if not v794 or not v794:IsA("GuiObject") or not v794.Visible then
				pcall(function()
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
					task.wait(0.005)
					VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
				end)
				return true
			end
			pcall(function()
				local AbsolutePosition = v794.AbsolutePosition
				local AbsoluteSize = v794.AbsoluteSize
				local guiInset = GuiService:GetGuiInset()
				local v798 = 8822 + math.random(1, 9999)
				VirtualInputManager:SendTouchEvent(v798, 0, AbsolutePosition.X + AbsoluteSize.X / 2 + guiInset.X, AbsolutePosition.Y + AbsoluteSize.Y / 2 + guiInset.Y)
				task.wait(0.005)
				VirtualInputManager:SendTouchEvent(v798, 2, AbsolutePosition.X + AbsoluteSize.X / 2 + guiInset.X, AbsolutePosition.Y + AbsoluteSize.Y / 2 + guiInset.Y)
			end)
			return true
		end
		v787 = function()
			if _G.Ox.Connections.SkillHeartbeat then
				_G.Ox.Connections.SkillHeartbeat:Disconnect()
				_G.Ox.Connections.SkillHeartbeat = nil
			end
			local n81 = 1023064338
			local n82 = 225216533
			_G.Ox.Connections.SkillHeartbeat = RunService.Heartbeat:Connect(function()
				local Ox = _G.Ox
				local exitTo
				local n83, n84, Line, n85, Goal, u808, u809, v810, v811, v812, v813
				while true do
					if not Ox.Auto.SkillCheck or _G.Ox.State.busy then
						exitTo = 1
						break
					end
					Ox = PlayerGui:FindFirstChild("SkillCheckPromptGui")
					n83 = 202957492
					if not Ox then
						break
					end
					local Check = Ox:FindFirstChild("Check")
					if not Check or not Check.Visible then
						exitTo = 2
						break
					end
					n84 = 566785799
					Line = Check:FindFirstChild("Line")
					n85 = 18931334
					Goal = Check:FindFirstChild("Goal")
					if not Line or not Goal then
						exitTo = 3
						break
					end
					local v815 = _G.Ox.Auto.SkillCheckMode == "Instant" or _G.Ox.Auto.SkillCheckMode == "Random" and not _G.Ox.State.RandomMode_IsNormal
					u808 = nil
					u809 = nil
					if v815 then
						exitTo = 4
						break
					end
					local v816 = _G.Ox.Auto.SkillCheckMode == "Normal"
					v816 = v816 or _G.Ox.Auto.SkillCheckMode == "Random" and _G.Ox.State.RandomMode_IsNormal
					v810 = Line.Rotation % 360
					v811 = Goal.Rotation % 360
					v812 = nil
					if not v816 then
						exitTo = 5
						break
					end
					if n6 < n2 then
						exitTo = 6
						break
					end
					n84 = 42005343
					n2 = 831215366
					n83 += 1224
					n7 += 1718
					n85 = 527250988
					n6 = 100358795
					n5 = 807189315
					n82 += 1419
					n81 -= 1500
					v813 += Q_0
					if Q_0 <= 0 then
						if v813 >= N_0 then
							continue
						end
						exitTo = 7
						break
					end
					if v813 <= N_0 then
						continue
					end
					exitTo = 7
					break
				end
				if exitTo == 1 then
					return
				end
				if exitTo == 2 then
					_G.Ox.State.RandomMode_IsNormal = false
					return
				end
				if exitTo == 3 then
					return
				end
				if exitTo == 4 then
					Line.Rotation = Goal.Rotation + 109
					_G.Ox.State.busy = true
					task.spawn(function()
						u808 = 768819590
						u809 = 929064675
						v793()
						task.wait(0.05)
						_G.Ox.State.busy = false
					end)
				else
					local v817
					if exitTo == 5 then
						v812 = (v811 + 102) % 360
						v817 = (v811 + 116) % 360
					else
						if exitTo == 6 then
							v812 = (v811 + 116) % 360
						else
							if exitTo ~= 7 then
								return
							end
							upv261 = nil
						end
						v817 = (v811 + 140) % 360
					end
					local v818
					if v817 < v812 then
						v818 = v810 >= v812 or v810 <= v817
					else
						v818 = v810 >= v812 and v810 <= v817
					end
					if v818 then
						_G.Ox.State.busy = true
						task.spawn(function()
							v793()
							task.wait(0.05)
							_G.Ox.State.busy = false
						end)
					end
				end
			end)
		end
	end
	do
		local RepairEvent = game:GetService("ReplicatedStorage").Remotes.Generator.RepairEvent
		local t9 = {}
		local n86 = 0
		GetAllGenerators = function()
			local now = tick()
			if now - n86 < 5 then
				return t9
			end
			t9 = {}
			n86 = now
			local Map = workspace:FindFirstChild("Map")
			if Map then
				pcall(function()
					for _, descendant in pairs(Map:GetDescendants()) do
						if descendant:IsA("Model") and descendant.Name == "Generator" then
							if descendant:GetAttribute("RepairProgress") ~= nil or descendant:GetAttribute("kickcount") ~= nil or descendant:GetAttribute("ProgressRepair") ~= nil then
								table.insert(t9, descendant)
							end
						end
					end
				end)
				return t9
			end
			return t9
		end
		_G.Ox.PlayRepairAnim = function()
			local Character = v18.Character
			if not Character then
				return
			end
			local v827 = Character
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			local Animator = Humanoid
			if Animator then
				v827 = Humanoid
				Animator = Humanoid:FindFirstChildOfClass("Animator")
			end
			if not Animator then
				return
			end
			if _G.Ox.RepairAnimTrack and _G.Ox.RepairAnimTrack.IsPlaying then
				return
			end
			if n7 == 542746896 then
				n5 += 868
				n6 = 612744051
				n4 -= 783
				n1 = 387996202
				n3 = 416377257
				n7 = 325195953
				bit32.band(nil, nil  )
				n7[v827][n7[v827]] = nil
			else
				pcall(function()
					local Animation = Instance.new("Animation")
					Animation.AnimationId = "rbxassetid://92960319113695"
					_G.Ox.RepairAnimTrack = Animator:LoadAnimation(Animation)
					_G.Ox.RepairAnimTrack.Priority = Enum.AnimationPriority.Action
					_G.Ox.RepairAnimTrack:Play()
				end)
			end
		end
		_G.Ox.StopRepairAnim = function()
			if _G.Ox.RepairAnimTrack and _G.Ox.RepairAnimTrack.IsPlaying then
				pcall(function()
					_G.Ox.RepairAnimTrack:Stop()
				end)
			end
			_G.Ox.RepairAnimTrack = nil
		end
		GetGeneratorPoints = function(p49)
			local t10 = {}
			pcall(function()
				for _, child in pairs(p49:GetChildren()) do
					if child.Name:find("GeneratorPoint") then
						if child:IsA("BasePart") then
							table.insert(t10, child)
						end
					end
				end
			end)
			return t10
		end
		_G.Ox.StopAutoRepair = function()
			_G.Ox.StopRepairAnim()
			local AutoCurrentPoint = _G.Ox.AutoCurrentPoint
			local n87 = 330565186
			local n88 = 245189601
			_G.Ox.AutoCurrentPoint = nil
			if AutoCurrentPoint then
				pcall(function()
					local FireServer = RepairEvent.FireServer
					local v838 = FireServer
					FireServer(RepairEvent, AutoCurrentPoint, false)
					if n2 == n5 then
						n2 = 985410202
						n88 -= 977
						n5 = 1042453123
						n1 = 498217854
						n4 = 434598598
						n87 = 629686682
						v838[nil] = n87
					end
				end)
			end
		end
		local n89
		_G.Ox.StartAutoRepairLoop = function(p50)
			n89 = 163513710
			_G.Ox.AutoCurrentGenModel = p50
			if _G.Ox.AutoRepairThread then
				task.cancel(_G.Ox.AutoRepairThread)
				_G.Ox.AutoRepairThread = nil
				if n3 ~= 660935885 then
					n1 -= 1632
					n6 = 860890105
					n7 += 500
					n89 += 2019
					n2 += 347
					n3 -= 1833
					n5 -= 563
					return (nil)()
				end
			else
				if n3 ~= 660935885 then
					n1 -= 1632
					n6 = 860890105
					n7 += 500
					local v840 = n89 + 2019
					n89 = v840
					n2 += 347
					n3 -= 1833
					n5 -= 563
					return (nil)()
				end
			end
			_G.Ox.StopAutoRepair()
			_G.Ox.AutoRepairThread = task.spawn(function()
				local n90 = 359469982
				local n91
				local n92
				while _G.Ox.AutoRepairEnabled and _G.Ox.BypassGenEnabled do
					local Character = v18.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					if HumanoidRootPart then
						local v846
						for _, v in pairs(GetAllGenerators()) do
							for _, v2 in pairs(GetGeneratorPoints(v)) do
								if (HumanoidRootPart.Position - v2.Position).Magnitude <= 5 then
									v846 = v2
									break
								end
							end
							if v846 then
								break
							end
						end
						if v846 then
							_G.Ox.AutoCurrentPoint = v846
							local now = tick()
							if _G.Ox.AutoFireInterval <= now - _G.Ox.LastFireTime then
								_G.Ox.PlayRepairAnim()
								pcall(function()
									n91 = 43751088
									n92 = 615127404
									RepairEvent:FireServer(v846, true)
									if not (n2 < n92) then
										n92 = 651225123
										n5 += 1762
										n90 += 1682
										n2 = 448564468
										n91 += 1994
										n1 = 515845747
									end
								end)
								_G.Ox.LastFireTime = now
							end
							task.wait(0.1)
						elseif _G.Ox.AutoCurrentPoint then
							_G.Ox.StopAutoRepair()
							_G.Ox.AutoRepairEnabled = false
							if _G.Ox.AutoCurrentGenModel then
								_G.Ox.ProcessedGens[_G.Ox.AutoCurrentGenModel] = nil
								_G.Ox.AutoCurrentGenModel = nil
							end
							break
						else
							task.wait(0.1)
						end
					else
						task.wait(0.1)
					end
				end
				_G.Ox.StopAutoRepair()
			end)
		end
		waitForRepairing = function(p51, p52)
			local spilled = {
				now = tick(),
				n93 = 87692403
			}
			do
				local v853, v854, v855, v856, v857, v858, v859, v860, v861, v862, v863, v864, v865, v866, v867, v868, v869, v870, v871, v872, v873, v874, v875, v876, v877, v878, v879, v880, v881, v882, v883, v884, v885, v886, v887, v888, v889, v890, v891, v892, v893, v894, v895, v896, v897, v898, v899, v900, v901, v902, v903, v904, v905, v906, v907, v908, v909, v910, v911, v912, v913, v914, v915, v916, v917, v918, v919, v920, v921, v922, v923, v924, v925, v926, v927, v928, v929, v930, v931, v932, v933, v934, v935, v936, v937, v938, v939, v940, v941, v942, v943, v944, v945, v946, v947, v948, v949, v950, v951, v952, v953, v954, v955, v956, v957, v958, v959, v960, v961, v962, v963, v964, v965, v966, v967, v968, v969, v970, v971, v972, v973, v974, v975, v976, v977, v978, v979, v980, v981, v982, v983, v984, v985, v986, v987, v988, v989, v990, v991, v992, v993, v994, v995, v996, v997, v998, v999, v1000, v1001, v1002, v1003, v1004, v1005, v1006, v1007, v1008, v1009, v1010, v1011, v1012
				while true do
					if not (tick() - spilled.now < (p52 or 1)) then
						return false
					end
					if p51:GetAttribute("IsRepairing") == true then
						if n3 ~= n5 then
							break
						end
						n1 = 157714807
						n3 -= 1404
						spilled.n93 += 899
						n5 = 968164907
						n7 -= 1774
						n4 -= 1376
						n6 = 892754733
						do
							local v1013, v1014, v1015, v1016, v1017, v1018, v1019, v1020, v1021, v1022, v1023, v1024, v1025, v1026, v1027, v1028, v1029
						end
						;(379)()
						bit32.rshift(nil, nil  )
					end
					task.wait(0.05)
				end
			end
			return true
		end
		RecreateBypassButton = function()
			local BypassGenUI = CoreGui:FindFirstChild("BypassGenUI")
			if BypassGenUI then
				BypassGenUI:Destroy()
			end
			_G.Ox.BypassUI = Instance.new("ScreenGui")
			_G.Ox.BypassUI.Name = "BypassGenUI"
			_G.Ox.BypassUI.ResetOnSpawn = false
			_G.Ox.BypassUI.IgnoreGuiInset = true
			_G.Ox.BypassUI.Parent = CoreGui
			_G.Ox.BypassButton = Instance.new("ImageButton")
			_G.Ox.BypassButton.Name = "BypassGenButton"
			_G.Ox.BypassButton.Size = UDim2.new(0, 55, 0, 55)
			_G.Ox.BypassButton.Position = UDim2.new(0.88, 0, 0.55, 0)
			_G.Ox.BypassButton.AnchorPoint = Vector2.new(0.5, 0.5)
			_G.Ox.BypassButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			_G.Ox.BypassButton.BackgroundTransparency = 0.15
			_G.Ox.BypassButton.AutoButtonColor = true
			_G.Ox.BypassButton.Visible = false
			_G.Ox.BypassButton.ZIndex = 10
			_G.Ox.BypassButton.Parent = _G.Ox.BypassUI
			local UICorner = Instance.new("UICorner")
			UICorner.CornerRadius = UDim.new(1, 0)
			UICorner.Parent = _G.Ox.BypassButton
			local UIStroke = Instance.new("UIStroke")
			UIStroke.Color = Color3.fromRGB(255, 255, 255)
			UIStroke.Thickness = 1.5
			UIStroke.Transparency = 0.4
			UIStroke.Parent = _G.Ox.BypassButton
			local TextLabel = Instance.new("TextLabel")
			TextLabel.Size = UDim2.new(1, 0, 1, 0)
			TextLabel.BackgroundTransparency = 1
			TextLabel.Text = "GEN"
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.Font = Enum.Font.GothamBold
			TextLabel.ZIndex = 11
			TextLabel.Parent = _G.Ox.BypassButton
			_G.Ox.BypassButton.Visible = _G.Ox.BypassToggleValue and UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		end
		RecreateBypassButton()
		_G.Ox.DoMultiRepairPlain = function(p53)
			local n94 = 318013035
			local Parent = p53.Parent
			local n95 = 4610829
			if _G.Ox.ProcessedGens[Parent] then
				return
			end
			_G.Ox.ProcessedGens[Parent] = true
			local v1156 = GetGeneratorPoints(Parent)
			local Character = v18.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then
				_G.Ox.ProcessedGens[Parent] = nil
				return
			end
			local n96 = 882957654
			local CFrame_ = HumanoidRootPart.CFrame
			pcall(function()
				local n97 = 468549436
				local n98 = 57014850
				local n99 = 65273020
				local v1157
				for _, v in pairs(v1156) do
					if v ~= p53 and v.Parent then
						HumanoidRootPart.Anchored = true
						HumanoidRootPart.CFrame = v.CFrame
						task.wait(0.15)
						pcall(function()
							RepairEvent:FireServer(v, true)
						end)
						if not waitForRepairing(v, 0.8) then
							pcall(function()
								RepairEvent:FireServer(v, false)
							end)
							if n99 == n98 then
								n97 -= 57
								n96 -= 1199
								n99 = 706059101
								n95 -= 555
								n94 -= 1045
								n5 = 655429304
								n4 -= 1772
								n98 = 838038683
								;(nil)[nil] = nil
								v1157 = v1157(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
							else
								task.wait(0.1)
							end
							HumanoidRootPart.CFrame = v.CFrame
							task.wait(0.15)
							pcall(function()
								RepairEvent:FireServer(v, true)
								if n97 ~= 468551420 then
									return
								end
								n5 = 540629206
								n95 = 768535060
								while true do
									n99 += 383
									n98 -= 1109
									n4 = 1068729594
									n97 -= 1900
								end
							end)
							waitForRepairing(v, 0.5)
						end
						HumanoidRootPart.Anchored = false
						task.wait(0.05)
					end
				end
			end)
			pcall(function()
				if HumanoidRootPart and HumanoidRootPart.Parent then
					HumanoidRootPart.Anchored = false
					HumanoidRootPart.CFrame = CFrame_
				end
			end)
			task.wait(0.1)
			if _G.Ox.BypassGenMode == "Manual Repair" then
				pcall(function()
					RepairEvent:FireServer(p53, false)
				end)
			elseif _G.Ox.BypassGenMode == "Auto Repair" then
				_G.Ox.AutoRepairEnabled = true
				_G.Ox.StartAutoRepairLoop(Parent)
			end
		end
	end
	do
		local n100
		_G.Ox.BypassButton.MouseButton1Click:Connect(function()
			n100 = 464188927
			if not _G.Ox.BypassGenEnabled then
				return
			end
			local Character = v18.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then
				return
			end
			local v1158
			local huge = math.huge
			for _, v in pairs(GetAllGenerators()) do
				for _, v2 in pairs(GetGeneratorPoints(v)) do
					local Magnitude = (HumanoidRootPart.Position - v2.Position).Magnitude
					if not (Magnitude < huge) then
						continue
					end
					huge = Magnitude
					if n2 ~= 352573088 then
						v1158 = v2
						continue
					end
					n6 += 1929
					n1 = 591909836
					n100 += 1089
					n3 = 795399638
					n2 += 887
					n5 -= 1332
					n7 += 541
					return (nil)(nil)
				end
			end
			if v1158 and huge <= 8 then
				_G.Ox.DoMultiRepairPlain(v1158)
			else
				lib2:Notify({
					Title = "Gen Boost",
					Description = "Ga deket generator manapun!",
					Duration = 2
				})
			end
		end)
	end
	local n101
	isGeneratorPromptVisible = function()
		n101 = 1039390510
		local n102 = 294344811
		local ok, result = pcall(function()
			if n101 == 1039390510 then
				return v18.PlayerGui.pcprompts.Frame.GeneratorRepair
			end
			n101 += 726
			n7 += 1891
			n3 = 546876569
			n5 = 818234415
			n102 += 1956
			n6 = 1017255413
			;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 260))
			getfenv()[nil  ] = nil
		end)
		local Visible = ok and result and result.Visible
		return Visible
	end
	getNearestGenPoint = function()
		local Character = v18.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart then
			return nil
		end
		local v1159
		local huge = math.huge
		if n5 == 403423611 then
			n5 = 279696351
			n2 = 837580417
			n1 = 516840155
			n4 = 1014130287
			n3 = 219052676
			n7 -= 1339
			upv387[nil] = nil
			upv387[365] = {} == nil
		else
			for _, v in pairs(GetAllGenerators()) do
				for _, v2 in pairs(GetGeneratorPoints(v)) do
					local Magnitude = (HumanoidRootPart.Position - v2.Position).Magnitude
					if Magnitude < huge then
						huge = Magnitude
						v1159 = v2
					end
				end
			end
		end
		return v1159, huge
	end
	do
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			if not _G.Ox.BypassGenEnabled then
				return
			end
			if not isGeneratorPromptVisible() then
				return
			end
			local v1160, v1161 = getNearestGenPoint()
			if not v1160 or v1161 > 8 then
				return
			end
			if _G.Ox.ProcessedGens[v1160.Parent] then
				return
			end
			_G.Ox.DoMultiRepairPlain(v1160)
		end)
	end
	do
		local n103
		startProcessedGensWatcher = function()
			n103 = 192617810
			local n104 = 133713159
			local n105
			task.spawn(function()
				n105 = 423555605
				local n106 = 494751171
				local n107 = 608937756
				local v1162
				while _G.Ox.ScriptAlive do
					task.wait(2)
					if not _G.Ox.ScriptAlive then
						break
					end
					local Character = v18.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					if HumanoidRootPart then
						if n103 < n1 then
							for k in pairs(_G.Ox.ProcessedGens) do
								if k and k.Parent then
									local v1163 = GetGeneratorPoints(k)
									local v1164 = false
									for _, v in pairs(v1163) do
										if v.Parent and (HumanoidRootPart.Position - v.Position).Magnitude <= 10 then
											v1164 = true
											break
										end
									end
									if not v1164 then
										_G.Ox.ProcessedGens[k] = nil
									end
								else
									_G.Ox.ProcessedGens[k] = nil
								end
							end
						else
							n103 = 780134278
							n105 -= 1393
							n107 += 85
							n2 = 985276729
							n1 = 357007313
							n5 -= 245
							n3 += 1113
							n106 += 905
							n104 -= 956
							v1162 = v1162()
						end
					end
				end
			end)
		end
	end
	startProcessedGensWatcher()
	INVIS_URL = ""
	local v1165, u1166, v1167, v1168, v1169
	do
		local u1170
		local u1171 = false
		local v1172 = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		local function v1173()
			if u1171 then
				return true
			end
			local ok, result = pcall(function()
				lib2:Notify({ Title = "Invisibility", Description = "unavailable right now", Duration = 3 }) error("unavailable", 0)
			end)
			if ok then
				if result then
					u1170 = result
					u1171 = true
					return true
				end
			end
			return false
		end
		v1165 = function(p54)
			_G.Ox.Utility.InvisEnabled = p54 == true
			if p54 then
				if not u1171 then
					v1173()
				end
				if u1170 then
					if v1172 then
						u1170.ShowGUI()
					else
						u1170.Enable()
					end
				end
			elseif u1170 then
				if v1172 then
					u1170.HideGUI()
				end
				u1170.Disable()
			end
		end
		u1166 = nil
		local u1174 = false
		local function v1175()
			local n108 = 36170461
			if u1174 then
				return true
			end
			local n109
			local ok, result = pcall(function()
				n109 = 810139493
				if n109 ~= n3 then
					lib2:Notify({ Title = "Fast Bandage", Description = "unavailable right now", Duration = 3 }) error("unavailable", 0)
				end
				n1 += 470
				n109 = 695415224
				n5 -= 1708
				n108 -= 514
				n3 = 1061225420
				n6 -= 630
			end)
			if ok then
				if result then
					u1166 = result
					u1174 = true
					return true
				end
			end
			return false
		end
		v1167 = function(p55)
			if p55 then
				if not u1174 then
					v1175()
				end
				if u1166 then
					if v1172 then
						u1166.ShowGUI()
					else
						local v1176 = u1166.Start()
						if not v1176 then
							_G.Ox.Utility.BandageEnabled = false
						end
					end
				end
			elseif u1166 then
				if v1172 then
					u1166.HideGUI()
				end
				u1166.Stop()
			end
		end
		UNHOOK_URL = ""
		UnhookAPI = nil
		UnhookLoaded = false
		local n110
		v1168 = function()
			n110 = 1036718322
			if UnhookLoaded then
				return true
			end
			local ok, result = pcall(function()
				if n6 > 185755701 then
					lib2:Notify({ Title = "Unhook Self", Description = "unavailable right now", Duration = 3 }) error("unavailable", 0)
				end
				n2 -= 887
				n5 -= 705
				n7 = 686314124
				n110 += 686
				n6 += 1896
				return (nil)(nil)
			end)
			if not ok or not result then
				return false
			end
			UnhookAPI = result
			UnhookLoaded = true
			return true
		end
		local u1178
		local u1179 = false
		local function v1180()
			local n111 = 60187131
			if u1179 then
				return true
			end
			local n112 = 939925556
			local ok, result = pcall(function()
				return loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Games/lib/VD_DashLock.lua"))()
			end)
			if not (n111 < n2) then
				n7 -= 571
				n2 = 867427774
				n111 = 460394299
				n112 += 1935
				n5 += 1729
				n4 -= 1010
				n1 -= 333
				n6 = 891445257
				;(nil)()
			elseif ok and result then
				u1178 = result
				u1179 = true
				return true
			end
			return false
		end
		local n113
		v1169 = function(p56)
			n113 = 242476023
			if p56 then
				if not u1179 then
					if n2 == 352572318 then
						v1180()
					else
						n2 = 211690229
						n6 = 1018464256
						n5 = 282049811
						n113 -= 1857
						n7 = 1073668808
						n3 = 628510614
						n4 = 570020510
						upv267[nil] = nil
						upv267[nil] = nil + nil
					end
				end
				if u1178 then
					if v1172 then
						u1178.ShowGUI()
					else
						u1178.Enable()
					end
					lib2:Notify({
						Title = "Dash Lock",
						Description = "ON - right click to lock",
						Duration = 3
					})
				end
			elseif u1178 then
				if v1172 then
					u1178.HideGUI()
				end
				u1178.Disable()
				lib2:Notify({
					Title = "Dash Lock",
					Description = "OFF",
					Duration = 2
				})
			end
		end
		task.spawn(function()
			local n114 = 810226565
			task.wait(2)
			v1180()
			if n5 ~= n114 then
				return
			end
			n2 = 320496877
			n4 = 981569596
			n3 = 457270747
			n7 = 190062029
			n1 += 1293
			n5 += 248
			local v1181 = nil - nil
			;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, v1181, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 354))
			return table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, v1181, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 300)
		end)
	end
	local v1182
	do
		local u1183
		local u1184 = false
		local function v1185()
			if u1184 then
				return true
			end
			local ok, result = pcall(function()
				return loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Games/lib/VD_MaskedGui.lua"))()
			end)
			if not ok or not result then
				return false
			end
			u1183 = result
			if n3 == 660935885 then
				u1184 = true
			else
				n3 = 1050325494
				n7 = 246886406
				n5 = 630414196
				n2 += 1588
				n6 += 1932
				n4 = 941806262
			end
			return true
		end
		v1182 = function(p57)
			if p57 then
				if not v1185() then
					lib2:Notify({
						Title = "Mask GUI",
						Description = "Couldn't load the script!",
						Duration = 3
					})
					return
				end
				local v1186, v1187 = u1183.Toggle(true)
				if v1186 then
					lib2:Notify({
						Title = "Mask GUI",
						Description = v1187 or "Loaded! (M key)",
						Duration = 3
					})
				else
					lib2:Notify({
						Title = "Mask GUI",
						Description = v1187 or "You're not The Masked!",
						Duration = 3
					})
				end
			elseif u1184 and u1183 then
				u1183.Toggle(false)
				lib2:Notify({
					Title = "Mask GUI",
					Description = "Hidden",
					Duration = 2
				})
			end
		end
		task.spawn(function()
			task.wait(2)
			v1185()
		end)
	end
	getTargetPartObject = function(p58)
		if _G.Ox.AimConfig.AIM_TargetPart == "Head" then
			return p58:FindFirstChild("Head")
		end
		if _G.Ox.AimConfig.AIM_TargetPart == "Root" or _G.Ox.AimConfig.AIM_TargetPart == "HumanoidRootPart" then
			return p58:FindFirstChild("HumanoidRootPart")
		end
		return p58:FindFirstChild("Torso") or p58:FindFirstChild("UpperTorso") or p58:FindFirstChild("HumanoidRootPart")
	end
	getClosestSurvivor = function()
		local Character = v17.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart then
			return nil
		end
		local Veil_FOV = _G.Ox.AimConfig.Veil_FOV
		local v1188
		local vector2 = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= v17 and player.Team and player.Team.Name == "Survivors" and player.Character then
				local Character2 = player.Character
				local Humanoid = Character2:FindFirstChildOfClass("Humanoid")
				local v1189 = getTargetPartObject(Character2)
				if Humanoid and Humanoid.Health > 0 and v1189 and (v1189.Position - HumanoidRootPart.Position).Magnitude <= _G.Ox.AimConfig.SPEAR_MaxDist then
					local v1190, v1191 = workspace.CurrentCamera:WorldToViewportPoint(v1189.Position)
					if v1191 then
						local Magnitude = (Vector2.new(v1190.X, v1190.Y) - vector2).Magnitude
						if Magnitude <= Veil_FOV then
							Veil_FOV = Magnitude
							v1188 = v1189
						end
					end
				end
			end
		end
		return v1188
	end
	getBestAimbotTarget = function()
		local v1192
		local v1193 = GetRole()
		local Surv_Aimbot_Radius = _G.Ox.Config.Surv_Aimbot_Radius
		local huge = math.huge
		local vector2 = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
		local Humanoid
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= v18 and player.Character then
				if not player.Character:FindFirstChild("HumanoidRootPart") then
					continue
				end
				local v1194 = false
				local HumanoidRootPart, v1195, v1196, v1197, Magnitude
				if v1193 == "Survivor" and _G.Ox.Config.Surv_Aimbot_Enabled and IsKiller(player) then
					if false then
						continue
					end
					HumanoidRootPart = player.Character.HumanoidRootPart
					v1195 = GetDistance(HumanoidRootPart.Position)
					if v1193 == "Survivor" then
						if v1195 <= _G.Ox.Config.Surv_Aimbot_MaxDist then
							v1196, v1197 = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
							if not v1197 then
								continue
							end
							Magnitude = (Vector2.new(v1196.X, v1196.Y) - vector2).Magnitude
							if not (Magnitude < Surv_Aimbot_Radius) then
								continue
							end
							Surv_Aimbot_Radius = Magnitude
							v1192 = HumanoidRootPart
							continue
						end
					end
					if v1193 ~= "Killer" or not (v1195 <= _G.Ox.Config.Killer_Aimbot_MaxDist) then
						continue
					end
					if n2 == n6 then
						n6 -= 1082
						n1 += 730
						n7 = 366784847
						n5 += 830
						n2 -= 800
						n4 -= 1757
						upv159[nil  ] = nil
						;(nil)(nil, nil)
					end
				else
					local ok = v1193 ~= "Killer" or not _G.Ox.Config.Killer_Aimbot_Enabled or IsKiller(player)
					if not ok then
						Humanoid = player.Character:FindFirstChild("Humanoid")
						ok = not Humanoid
					end
					if ok then
						if not v1194 then
							continue
						end
						HumanoidRootPart = player.Character.HumanoidRootPart
						v1195 = GetDistance(HumanoidRootPart.Position)
						if v1193 == "Survivor" then
							if v1195 <= _G.Ox.Config.Surv_Aimbot_MaxDist then
								v1196, v1197 = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
								if not v1197 then
									continue
								end
								Magnitude = (Vector2.new(v1196.X, v1196.Y) - vector2).Magnitude
								if not (Magnitude < Surv_Aimbot_Radius) then
									continue
								end
								Surv_Aimbot_Radius = Magnitude
								v1192 = HumanoidRootPart
								continue
							end
						end
						if v1193 ~= "Killer" or not (v1195 <= _G.Ox.Config.Killer_Aimbot_MaxDist) then
							continue
						end
						if n2 == n6 then
							n6 -= 1082
							n1 += 730
							n7 = 366784847
							n5 += 830
							n2 -= 800
							n4 -= 1757
							upv159[nil  ] = nil
							;(nil)(nil, nil)
						end
					else
						if Humanoid.Health > 0 and not IsDowned(player.Character) then
							v1194 = true
						end
						if not v1194 then
							continue
						end
						HumanoidRootPart = player.Character.HumanoidRootPart
						v1195 = GetDistance(HumanoidRootPart.Position)
						if not (v1195 <= _G.Ox.Config.Killer_Aimbot_MaxDist) then
							continue
						end
						if n2 == n6 then
							n6 -= 1082
							n1 += 730
							n7 = 366784847
							n5 += 830
							n2 -= 800
							n4 -= 1757
							upv159[nil  ] = nil
							;(nil)(nil, nil)
						end
					end
				end
				if v1195 < huge then
					huge = v1195
					v1192 = HumanoidRootPart
				end
			end
		end
		return v1192
	end
	getBestKillerAimbotTarget = function()
		local v1198
		local huge = math.huge
		local Character = v18.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart then
			return nil
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= v18 and player.Team and player.Team.Name == "Survivors" and player.Character then
				local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				local HumanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
				if Humanoid and Humanoid.Health > 0 and HumanoidRootPart2 and not IsDowned(player.Character) then
					local Magnitude = (HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude
					if Magnitude < huge then
						if Magnitude <= _G.Ox.Config.Killer_Aimbot_MaxDist then
							huge = Magnitude
							v1198 = HumanoidRootPart2
						end
					end
				end
			end
		end
		return v1198
	end
	getKillerTargetForFlash = function()
		local v1199
		local huge = math.huge
		local Character = v18.Character
		local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart then
			return nil
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= v18 and player.Team and player.Team.Name == "Killer" and player.Character then
				local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				local HumanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
				if Humanoid and Humanoid.Health > 0 and HumanoidRootPart2 and not IsDowned(player.Character) then
					local Magnitude = (HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude
					if Magnitude < huge then
						huge = Magnitude
						v1199 = HumanoidRootPart2
					end
				end
			end
		end
		if n6 ~= n4 then
			return v1199
		end
		n7 += 951
		n4 = 939424024
		n6 += 287
		n3 += 242
		n1 = 610072367
		n5 = 674929746
		upv314 = nil
	end
	NEX_UpdateCureFlaskLaser = function()
		local Character = v18.Character
		if not Character then
			return
		end
		local Position
		local Position2
		local v1200
		local huge = math.huge
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		if HumanoidRootPart then
			local LeftHand = Character:FindFirstChild("LeftHand") or Character:FindFirstChild("Left Arm")
			Position2 = LeftHand and LeftHand.Position or HumanoidRootPart.Position
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= v18 and player.Character then
					if player.Character:FindFirstChild("HumanoidRootPart") and not IsKiller(player) then
						local Magnitude = (player.Character.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
						if Magnitude < huge then
							huge = Magnitude
							v1200 = player
						end
					end
				end
			end
		end
		if v1200 then
			Position = v1200.Character.HumanoidRootPart.Position
		end
		local v1201 = false
		for _, child in pairs(Character:GetChildren()) do
			if child:IsA("LocalScript") and child:GetAttribute("action") == true then
				v1201 = true
				break
			end
		end
		if Position2 and Position and v1201 then
			if not _G.Ox.NEX_CureFlaskLaserPart then
				local Part = Instance.new("Part")
				Part.Name = "FlaskSilentAimLaser"
				Part.Anchored = true
				Part.CanCollide = false
				Part.CanTouch = false
				Part.CastShadow = false
				Part.Material = Enum.Material.Neon
				Part.Color = Color3.fromRGB(255, 50, 50)
				Part.Transparency = 0
				Part.Parent = workspace
				_G.Ox.NEX_CureFlaskLaserPart = Part
			end
			local Magnitude = (Position - Position2).Magnitude
			if Magnitude > 0.1 then
				local NEX_CureFlaskLaserPart = _G.Ox.NEX_CureFlaskLaserPart
				NEX_CureFlaskLaserPart.Size = Vector3.new(0.16, 0.16, Magnitude)
				NEX_CureFlaskLaserPart.CFrame = CFrame.new((Position2 + Position) / 2, Position)
				NEX_CureFlaskLaserPart.Transparency = 0
			end
		elseif _G.Ox.NEX_CureFlaskLaserPart then
			_G.Ox.NEX_CureFlaskLaserPart.Transparency = 1
		end
	end
	do
		NEX_StartCureFlaskLaser = function()
			if _G.Ox.NEX_CureFlaskLaserThread then
				return
			end
			_G.Ox.NEX_CureFlaskLaserThread = RunService.RenderStepped:Connect(function()
				if _G.Ox.KILLER_FlaskLaser then
					pcall(NEX_UpdateCureFlaskLaser)
					return
				end
				if _G.Ox.NEX_CureFlaskLaserPart then
					pcall(function()
						_G.Ox.NEX_CureFlaskLaserPart:Destroy()
					end)
					_G.Ox.NEX_CureFlaskLaserPart = nil
					if _G.Ox.NEX_CureFlaskLaserThread then
						_G.Ox.NEX_CureFlaskLaserThread:Disconnect()
						_G.Ox.NEX_CureFlaskLaserThread = nil
						return
					end
				elseif _G.Ox.NEX_CureFlaskLaserThread then
					_G.Ox.NEX_CureFlaskLaserThread:Disconnect()
					_G.Ox.NEX_CureFlaskLaserThread = nil
				end
			end)
		end
	end
	setupSpearInterceptor = function()
		if u520 then
			return
		end
		if not getrawmetatable or not setreadonly then
			return
		end
		local n115 = 610847563
		local Spearthrow
		pcall(function()
			Spearthrow = ReplicatedStorage.Remotes.Killers.Veil.Spearthrow
		end)
		local Fall = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Mechanics") and ReplicatedStorage.Remotes.Mechanics:FindFirstChild("Fall")
		local function v1202(p59, p60, p61, p62)
			local v1203 = math.max(p61, 0.1)
			local v1204 = p59 * p59
			local v1205 = v1204 * v1204 - p60 * (p60 * v1203 * v1203 + 2 * p62 * v1204)
			if v1205 < 0 then
				v1205 = 0
			end
			local v1206 = math.atan((v1204 - math.sqrt(v1205)) / (p60 * v1203))
			return v1206, v1203 / (p59 * math.cos(v1206))
		end
		local v1207 = getrawmetatable(game)
		setreadonly(v1207, false)
		local __namecall = v1207.__namecall
		v1207.__namecall = newcclosure(function(p63, ...)
			local v1208 = getnamecallmethod()
			local v1209 = v1208 == "FireServer" or v1208 == "fireServer" or v1208 == "InvokeServer"
			if v1209 and not checkcaller() and typeof(p63) == "Instance" then
				if _G.Ox.NoFall.Enabled and Fall and p63 == Fall then
					return __namecall(p63, unpack({
						0,
						...
					}))
				end
				if _G.Ox.AntiBlindEnabled and _G.Ox.GotBlindedRemote and p63 == _G.Ox.GotBlindedRemote and LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
					return nil
				end
				if _G.Ox.BulletBlockConfig.Enabled and p63.Name == "Fire" then
					local Parent = p63.Parent
					if Parent and Parent.Name == "Twist of Fate" then
						return nil
					end
				end
				if _G.Ox.KILLER_SilentAimFlask and p63.Name == "ThrowFlask" then
					local t11 = { ... }
					local v1210
					local huge = math.huge
					local Position = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
					if Position then
						for _, player in pairs(Players:GetPlayers()) do
							if player ~= LocalPlayer and player.Character then
								if player.Character:FindFirstChild("HumanoidRootPart") and not IsKiller(player) then
									local Magnitude = (player.Character.HumanoidRootPart.Position - Position).Magnitude
									if Magnitude < huge then
										huge = Magnitude
										v1210 = player
									end
								end
							end
						end
					end
					if v1210 and t11[2] and typeof(t11[2]) == "Vector3" then
						t11[1] = (v1210.Character.HumanoidRootPart.Position - t11[2]).Unit
						setnamecallmethod(v1208)
						return __namecall(p63, unpack(t11))
					end
				end
				if v1208 == "FireServer" and typeof(p63) == "Instance" and string.lower(tostring(p63.Name)) == "updatecharacterlook" then
					if _G.Ox and _G.Ox.Utility and _G.Ox.Utility.InvisEnabled then
						local t12 = {}
						for i, v in ipairs({ ... }) do
							if typeof(v) == "CFrame" then
								t12[i] = v * CFrame.new(0, 5000, 0)
							else
								t12[i] = v
							end
						end
						return __namecall(p63, unpack(t12))
					end
				end
				if p63.ClassName == "RemoteEvent" and p63.Name == "Spearthrow" and _G.Ox.AimConfig.Aim_SilentVeilV2 and not u519 then
					local v1212 = ...
					local value = select(3, ...)
					local Character = v18.Character
					local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
					local Head = Character and (Character:FindFirstChild("Head") or HumanoidRootPart)
					local SPEAR_AuraSpeed, SPEAR_AuraGravity
					if Character and Character:GetAttribute("special") == true then
						SPEAR_AuraSpeed = _G.Ox.AimConfig.SPEAR_AuraSpeed or 165
						SPEAR_AuraGravity = _G.Ox.AimConfig.SPEAR_AuraGravity or 96.5
					else
						SPEAR_AuraSpeed = _G.Ox.AimConfig.SPEAR_Speed or 165
						SPEAR_AuraGravity = _G.Ox.AimConfig.SPEAR_Gravity or 103
					end
					local v1219 = SPEAR_AuraSpeed
					local Position = value or _G.Ox.Config.SpearSmart_enable and HumanoidRootPart and HumanoidRootPart.Position or Head and Head.Position
					local v1221 = v1212
					local v1222 = getClosestSurvivor()
					if v1222 and Position then
						local HumanoidRootPart2 = v1222:IsA("Model") and v1222:FindFirstChild("HumanoidRootPart") or v1222
						local Position2 = HumanoidRootPart2.Position
						local vector3 = Vector3.new(0, 0, 0)
						local Humanoid = v1222.Parent and v1222.Parent:FindFirstChildOfClass("Humanoid")
						if Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
							vector3 = Humanoid.MoveDirection * Humanoid.WalkSpeed
						elseif HumanoidRootPart2:IsA("BasePart") then
							vector3 = HumanoidRootPart2.AssemblyLinearVelocity
						end
						local vector32 = Vector3.new(vector3.X, 0, vector3.Z)
						local v1228 = Position2 - Position
						local Magnitude = v1228.Magnitude
						local Magnitude2 = Vector3.new(v1228.X, 0, v1228.Z).Magnitude
						local Y = v1228.Y
						if Magnitude > 0.1 then
							if Magnitude <= (_G.Ox.AimConfig.SPEAR_MaxDist or 1000) then
								local Veil_LeadMultiplier = _G.Ox.AimConfig.Veil_LeadMultiplier or 1.4
								local _, v1234 = v1202(SPEAR_AuraSpeed, SPEAR_AuraGravity, Magnitude2, Y)
								if _G.Ox.Config.SpearSmart_enable and vector32.Magnitude > 0.5 then
									local v1235 = vector32 * (v1234 * Veil_LeadMultiplier)
									local v1236 = math.clamp(Magnitude * 0.6, 3, 45)
									if v1236 < v1235.Magnitude then
										v1235 = v1235.Unit * v1236
									end
									local v1237 = Position2 + v1235 - Position
									local Magnitude3 = Vector3.new(v1237.X, 0, v1237.Z).Magnitude
									local value2 = select(1, v1202(SPEAR_AuraSpeed, SPEAR_AuraGravity, math.max(Magnitude3, 0.1), v1237.Y))
									if Magnitude3 > 0.001 then
										v1221 = Vector3.new(v1237.X, 0, v1237.Z).Unit * math.cos(value2) + Vector3.new(0, math.sin(value2), 0)
									else
										v1221 = v1237.Unit
									end
								else
									local value2 = select(1, v1202(SPEAR_AuraSpeed, SPEAR_AuraGravity, math.max(Magnitude2, 0.1), Y))
									if Magnitude2 > 0.001 then
										v1221 = Vector3.new(v1228.X, 0, v1228.Z).Unit * math.cos(value2) + Vector3.new(0, math.sin(value2), 0)
									else
										v1221 = v1228.Unit
									end
								end
							end
						end
					end
					u519 = true
					pcall(function()
						if Spearthrow then
							Spearthrow:FireServer(v1221, v1219, Position)
						else
							p63:FireServer(v1221, v1219, Position)
						end
					end)
					u519 = false
					return
				end
			end
			return __namecall(p63, ...)
		end)
		setreadonly(v1207, true)
		if n4 == 666560820 then
			u520 = true
		else
			n115 += 516
			n7 += 262
			n5 = 158688803
			n6 -= 1006
			n4 -= 1548
			n2 = 32977903
			n1 -= 287
		end
	end
	do
		local function v1241()
			local Items = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Items")
			local Flashlight = Items and Items:FindFirstChild("Flashlight")
			if Flashlight then
				_G.Ox.GotBlindedRemote = Flashlight:FindFirstChild("GotBlinded")
			end
		end
		task.spawn(function()
			task.wait(1)
			v1241()
			setupSpearInterceptor()
		end)
		LocalPlayer.CharacterAdded:Connect(function()
			task.wait(1)
			v1241()
		end)
	end
	local Connections_ = Connections or {}
	local v1245
	do
		v1245 = function()
			if Connections_.LeapBypass then
				task.cancel(Connections_.LeapBypass)
				Connections_.LeapBypass = nil
			end
			Connections_.LeapBypass = task.spawn(function()
				local v1246
				local v1247
				local v1248, v1249, v1250 = pairs(getgc(true))
				local v1251 = geniter(v1248, v1249, v1250)
				while true do
					local v1252 = table.pack(v1251())
					if not v1252[1] then
						break
					end
					local v1253 = v1252[3]
					if type(v1253) == "function" and islclosure(v1253) then
						local v1254 = debug.getinfo(v1253)
						if v1254.name == "tryActivate" then
							v1246 = v1253
						end
						if v1254.name == "playM2Animation" then
							v1247 = v1253
						end
						if v1246 and v1247 then
							break
						end
					end
				end
				if not (v1246 or v1247) then
					warn("[BypassLeap] function not found.")
					return
				end
				while task.wait(0.1) and _G.Ox.BypassLeapEnabled do
					local v1255, v1256, v1257 = pairs({
						v1246,
						v1247
					})
					for _, v in v1255, v1256, v1257 do
						if v then
							for k, v2 in pairs(debug.getupvalues(v)) do
								if type(v2) == "boolean" and v2 == true then
									debug.setupvalue(v, k, false)
								end
							end
						end
					end
				end
			end)
		end
	end
	local v1262
	do
		local u1263 = false
		local function v1264()
			if GetRole() ~= "Killer" then
				return
			end
			local SelectedKiller = LocalPlayer:FindFirstChild("SelectedKiller")
			local Value = SelectedKiller and SelectedKiller.Value or LocalPlayer:GetAttribute("SelectedKiller")
			if Value and string.find(string.lower(tostring(Value)), "abyss") then
				pcall(function()
					local corrupt = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Killers"):FindFirstChild("Abysswalker"):FindFirstChild("corrupt")
					if corrupt then
						corrupt:FireServer()
					end
				end)
			end
		end
		local function v1268()
			if u1263 then
				return
			end
			u1263 = true
			task.spawn(function()
				while u1263 and _G.Ox.InfAbyssalEnabled and GetRole() == "Killer" do
					v1264()
					task.wait(0.5)
				end
			end)
		end
		local n116
		v1262 = function()
			n116 = 632998286
			if n116 ~= n5 then
				u1263 = false
				return
			end
			n1 += 148
			n116 -= 1598
			n3 = 740254612
			n6 += 1659
			n5 = 635282006
			n7 -= 1229
			n2 -= 1307
			return (nil)()
		end
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if _G.Ox.InfAbyssalEnabled and input.KeyCode == Enum.KeyCode.Q then
				v1268()
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Q then
				v1262()
			end
		end)
		task.spawn(function()
			local n117 = 628008384
			while true do
				if not _G.Ox.ScriptAlive then
					return
				end
				task.wait(0.5)
				if _G.Ox.ScriptAlive then
					if not _G.Ox.InfAbyssalEnabled or GetRole() ~= "Killer" then
						v1262()
						continue
					end
					break
				end
				return
			end
			local PlayerGui2
			while true do
				PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
				if PlayerGui2 then
					break
				end
				while true do
					if not _G.Ox.ScriptAlive then
						return
					end
					task.wait(0.5)
					if _G.Ox.ScriptAlive then
						if not _G.Ox.InfAbyssalEnabled or GetRole() ~= "Killer" then
							v1262()
							continue
						end
						break
					end
					return
				end
			end
			local exitTo2, v1273, v1274, v1275
			repeat
				local v1276
				local exitTo
				for _, child in pairs(PlayerGui2:GetChildren()) do
					v1273 = t35_216_1[2]
					v1274 = t35_216_1[1]
					v1275 = t35_216_1[3]
					if string.sub(child.Name, -4) == "-mob" and child.Name ~= "Survivor-mob" then
						v1276 = child
						exitTo = 1
						break
					end
				end
				if exitTo ~= 1 then
					v1273 = t35_216_1[2]
					v1274 = t35_216_1[1]
					v1275 = t35_216_1[3]
				end
				if v1276 then
					v1274 = v1276
					local Controls = v1276:FindFirstChild("Controls")
					if Controls then
						v1274 = Controls
						local move2 = Controls:FindFirstChild("move2")
						if move2 and move2.Visible then
							v1268()
						else
							v1262()
						end
					end
				end
				exitTo2 = nil
				while _G.Ox.ScriptAlive do
					task.wait(0.5)
					if not _G.Ox.ScriptAlive then
						break
					end
					if not _G.Ox.InfAbyssalEnabled or GetRole() ~= "Killer" then
						v1262()
						continue
					end
					local FindFirstChild = LocalPlayer.FindFirstChild
					v1274 = FindFirstChild
					PlayerGui2 = FindFirstChild(LocalPlayer, "PlayerGui")
					if not PlayerGui2 then
						continue
					end
					exitTo2 = 1
					break
				end
			until exitTo2 ~= 1
			if n117 == n1 then
				n3 += 842
				n4 += 1467
				n5 = 982932048
				n1 = 171177690
				n6 = 861194555
				n7 = 304672346
				local v1283 = v1273[v1275]
				v1274[v1283] = n7
				upv410 = nil
				upv410[v1274] = v1283[499]
				bit32.rshift(nil, nil  )
			end
		end)
	end
	EnableInfiniteLunge = function()
		_G.Ox.InfiniteLungeEnabled = true
		local Character = LocalPlayer.Character
		if Character then
			Character:SetAttribute("lungeboost", 999)
			if _G.Ox.InfLungeAttrConn then
				_G.Ox.InfLungeAttrConn:Disconnect()
			end
			_G.Ox.InfLungeAttrConn = Character:GetAttributeChangedSignal("lungeboost"):Connect(function()
				if _G.Ox.InfiniteLungeEnabled and Character:GetAttribute("lungeboost") ~= 999 then
					Character:SetAttribute("lungeboost", 999)
				end
			end)
		end
		lib2:Notify({
			Title = "Infinite Lunge",
			Description = "ON (999x)",
			Duration = 3
		})
	end
	DisableInfiniteLunge = function()
		_G.Ox.InfiniteLungeEnabled = false
		if _G.Ox.InfLungeAttrConn then
			_G.Ox.InfLungeAttrConn:Disconnect()
			_G.Ox.InfLungeAttrConn = nil
		end
		local Character = LocalPlayer.Character
		if Character then
			Character:SetAttribute("lungeboost", 1)
		end
		lib2:Notify({
			Title = "Infinite Lunge",
			Description = "OFF",
			Duration = 2
		})
	end
	LocalPlayer.CharacterAdded:Connect(function(character)
		task.wait(0.8)
		if _G.Ox.InfiniteLungeEnabled and character then
			character:SetAttribute("lungeboost", 999)
		end
	end)
	StopCounterParry = function()
		local n118 = 27882311
		_G.Ox.CounterParry.Enabled = false
		local n119 = 605012740
		if _G.Ox.CounterParry.Thread then
			task.cancel(_G.Ox.CounterParry.Thread)
			_G.Ox.CounterParry.Thread = nil
		end
		if _G.Ox.CounterParry.Track then
			pcall(function()
				_G.Ox.CounterParry.Track:Stop()
				if n1 == n119 then
					n119 = 850391901
					n5 += 929
					n1 -= 1845
					n118 -= 220
					upv262[nil  ] = nil
				end
			end)
			_G.Ox.CounterParry.Track = nil
		end
	end
	StartCounterParry = function()
		if _G.Ox.CounterParry.Thread then
			return
		end
		local n120 = 426516760
		_G.Ox.CounterParry.Thread = task.spawn(function()
			while _G.Ox.CounterParry.Enabled do
				if not _G.Ox.ScriptAlive then
					break
				end
				local Character = LocalPlayer.Character
				if Character and Character.Parent and GetRole() == "Killer" then
					local Humanoid = Character:FindFirstChildOfClass("Humanoid")
					local Animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
					local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
					if Animator and HumanoidRootPart then
						if not _G.Ox.CounterParry.Track or _G.Ox.CounterParry.Track.Parent == nil then
							local Animation = Instance.new("Animation")
							Animation.AnimationId = _G.Ox.CounterParry.AnimId
							local ok, track = pcall(function()
								return Animator:LoadAnimation(Animation)
							end)
							if not ok or not track then
								task.wait(0.5)
								continue
							end
							_G.Ox.CounterParry.Track = track
						end
						local v1296 = false
						local Distance = _G.Ox.CounterParry.Distance
						for _, player in ipairs(Players:GetPlayers()) do
							if n4 == n120 then
								n4 = 835090259
								n5 += 1523
								n120 = 645932042
								upv298[nil  ] = nil
							elseif player ~= LocalPlayer and player.Team and player.Team.Name == "Survivors" then
								local HumanoidRootPart2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
								if HumanoidRootPart2 and (HumanoidRootPart.Position - HumanoidRootPart2.Position).Magnitude <= Distance then
									v1296 = true
									break
								end
							end
						end
						if v1296 and _G.Ox.CounterParry.Track then
							pcall(function()
								_G.Ox.CounterParry.Track:Play()
								_G.Ox.CounterParry.Track:AdjustWeight(0)
							end)
							task.wait(0.05)
							pcall(function()
								_G.Ox.CounterParry.Track:Stop()
							end)
						end
						task.wait(_G.Ox.CounterParry.Interval)
					else
						task.wait(0.3)
					end
				else
					task.wait(0.4)
				end
			end
			_G.Ox.CounterParry.Thread = nil
		end)
	end
	ToggleCounterParry = function(p64)
		if p64 then
			if GetRole() ~= "Killer" then
				lib2:Notify({
					Title = "Counter Auto Parry",
					Description = "Killer only!",
					Duration = 3
				})
				_G.Ox.CounterParry.Enabled = false
				if CounterParryToggle then
					v531(CounterParryToggle, false)
				end
				return
			end
			_G.Ox.CounterParry.Enabled = true
			StartCounterParry()
			lib2:Notify({
				Title = "Counter Auto Parry",
				Description = "ON",
				Duration = 2
			})
		else
			StopCounterParry()
			lib2:Notify({
				Title = "Counter Auto Parry",
				Description = "OFF",
				Duration = 2
			})
		end
	end
	LocalPlayer.CharacterAdded:Connect(function()
		_G.Ox.CounterParry.Track = nil
		task.wait(1)
		if _G.Ox.CounterParry.Enabled then
			StartCounterParry()
		end
	end)
	do
		local function v1301()
			local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
			local Killers = Remotes and Remotes:FindFirstChild("Killers")
			local Stalker = Killers and Killers:FindFirstChild("Stalker")
			return Stalker and Stalker:FindFirstChild("StartStalking")
		end
		local function v1305()
			local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then
				return nil
			end
			local v1307
			local huge = math.huge
			local Range = _G.Ox.AutoStalk.Range
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
					local HumanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
					if Humanoid and HumanoidRootPart2 and Humanoid.Health > 30 then
						local Magnitude = (HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude
						if Magnitude <= Range and Magnitude < huge then
							huge = Magnitude
							v1307 = player
						end
					end
				end
			end
			if n3 ~= 528412385 then
				return v1307
			end
			n2 = 419884531
			n7 = 658547056
			n5 += 585
			n4 = 200889652
			n6 += 1212
			n3 += 448
			bit32.band(nil, nil  )
			return table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, (nil)(), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 275)
		end
		local n121
		StopAutoStalk = function()
			n121 = 1032713002
			local n122 = 974097250
			_G.Ox.AutoStalk.Enabled = false
			if _G.Ox.AutoStalk.Conn then
				if n3 < n122 then
					_G.Ox.AutoStalk.Conn:Disconnect()
				else
					n3 -= 1986
					n5 += 1057
					n4 = 377866668
					n121 -= 1165
					n1 = 858453773
					n7 -= 1632
					n2 -= 323
				end
				_G.Ox.AutoStalk.Conn = nil
			end
		end
		StartAutoStalk = function()
			local n123 = 931983733
			if _G.Ox.AutoStalk.Conn then
				return
			end
			local n124 = 578976394
			local n125
			_G.Ox.AutoStalk.Conn = RunService.Heartbeat:Connect(function()
				n125 = 168604069
				if not _G.Ox.AutoStalk.Enabled or not _G.Ox.ScriptAlive then
					return
				end
				if GetRole() ~= "Killer" then
					return
				end
				local now = tick()
				if now - (_G.Ox.AutoStalk.LastFire or 0) < 0.35 then
					return
				end
				local v1321 = v1305()
				if not v1321 or not v1321.Character then
					return
				end
				local v1322 = v1301()
				if v1322 then
					_G.Ox.AutoStalk.LastFire = now
					pcall(function()
						local v1323
						v1322:FireServer(v1321)
						local n126 = 1051172471
						if n126 ~= n125 then
							return
						end
						n5 = 1049545941
						n125 -= 1024
						n123 -= 804
						n124 -= 1432
						;(nil)[nil] = v1323
						upv30[nil  ] = nil
						return (nil)(nil)
					end)
				end
			end)
		end
	end
	ToggleAutoStalk = function(p65)
		if p65 then
			if GetRole() ~= "Killer" then
				lib2:Notify({
					Title = "Auto Stalk",
					Description = "Killer only!",
					Duration = 3
				})
				_G.Ox.AutoStalk.Enabled = false
				if AutoStalkToggle then
					v531(AutoStalkToggle, false)
				end
				return
			end
			_G.Ox.AutoStalk.Enabled = true
			StartAutoStalk()
			lib2:Notify({
				Title = "Auto Stalk",
				Description = "ON",
				Duration = 2
			})
		else
			StopAutoStalk()
			lib2:Notify({
				Title = "Auto Stalk",
				Description = "OFF",
				Duration = 2
			})
		end
	end
	local v1325
	do
		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Name = "FOVCircleGui_Standalone"
		ScreenGui.ResetOnSpawn = false
		ScreenGui.IgnoreGuiInset = true
		ScreenGui.Parent = CoreGui
		local Frame = Instance.new("Frame")
		Frame.BackgroundTransparency = 1
		Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		Frame.Visible = false
		Frame.Parent = ScreenGui
		Instance.new("UICorner", Frame).CornerRadius = UDim.new(1, 0)
		local UIStroke = Instance.new("UIStroke", Frame)
		UIStroke.Color = Color3.fromRGB(255, 255, 255)
		UIStroke.Thickness = 1.5
		local Highlight = Instance.new("Highlight")
		Highlight.Name = "VD_VeilTarget"
		Highlight.FillColor = Color3.fromRGB(255, 0, 0)
		Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		Highlight.FillTransparency = 0.5
		Highlight.OutlineTransparency = 0
		local u1330
		local function v1331()
			if n7 == n2 then
				n4 -= 1422
				n6 = 450853231
				n5 -= 814
				n1 -= 559
				n7 -= 1391
				n2 = 9031529
				upv489 = nil
			elseif u1330 then
				pcall(function()
					u1330:Destroy()
				end)
				u1330 = nil
			end
		end
		local function v1332(p66, p67)
			if p66 then
				if p67 then
					local Magnitude = (p67 - p66).Magnitude
					if Magnitude < 0.2 then
						if u1330 then
							u1330.Transparency = 1
						end
						return
					end
					if not u1330 then
						local Part = Instance.new("Part")
						Part.Name = "VeilTrackerLine"
						Part.Anchored = true
						Part.CanCollide = false
						Part.CanTouch = false
						Part.CanQuery = false
						Part.CastShadow = false
						Part.Material = Enum.Material.Neon
						Part.Color = Color3.fromRGB(255, 255, 255)
						Part.Parent = workspace
						u1330 = Part
					end
					u1330.Size = Vector3.new(0.08, 0.08, Magnitude)
					u1330.CFrame = CFrame.new((p66 + p67) / 2, p67)
					u1330.Transparency = 0.15
					return
				end
			end
			if u1330 then
				u1330.Transparency = 1
			end
		end
		_G.Ox.SurvivorFOVGui = Instance.new("ScreenGui")
		_G.Ox.SurvivorFOVGui.Name = "SurvivorAimbotFOV"
		_G.Ox.SurvivorFOVGui.ResetOnSpawn = false
		_G.Ox.SurvivorFOVGui.IgnoreGuiInset = true
		_G.Ox.SurvivorFOVGui.Parent = CoreGui
		_G.Ox.SurvivorFOVFrame = Instance.new("Frame")
		_G.Ox.SurvivorFOVFrame.BackgroundTransparency = 1
		_G.Ox.SurvivorFOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		_G.Ox.SurvivorFOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		_G.Ox.SurvivorFOVFrame.Visible = false
		_G.Ox.SurvivorFOVFrame.Parent = _G.Ox.SurvivorFOVGui
		Instance.new("UICorner", _G.Ox.SurvivorFOVFrame).CornerRadius = UDim.new(1, 0)
		local UIStroke2 = Instance.new("UIStroke", _G.Ox.SurvivorFOVFrame)
		UIStroke2.Color = Color3.fromRGB(255, 255, 255)
		UIStroke2.Thickness = 1.5
		UIStroke2.Transparency = 0.5
		_G.Ox.survivorAimbotHighlight = Instance.new("Highlight")
		_G.Ox.survivorAimbotHighlight.Name = "SurvivorAimbotTarget"
		_G.Ox.survivorAimbotHighlight.FillColor = Color3.fromRGB(255, 0, 0)
		_G.Ox.survivorAimbotHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
		_G.Ox.survivorAimbotHighlight.FillTransparency = 0.4
		_G.Ox.survivorAimbotHighlight.OutlineTransparency = 0.2
		_G.Ox.killerAimbotHighlight = Instance.new("Highlight")
		_G.Ox.killerAimbotHighlight.Name = "KillerAimbotTarget"
		_G.Ox.killerAimbotHighlight.FillColor = Color3.fromRGB(255, 0, 0)
		_G.Ox.killerAimbotHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
		_G.Ox.killerAimbotHighlight.FillTransparency = 0.4
		_G.Ox.killerAimbotHighlight.OutlineTransparency = 0.2
		StopMoonwalk = function()
			_G.Ox.Moonwalk.Enabled = false
			local Character = LocalPlayer.Character
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid.AutoRotate = true
			end
		end
		StartMoonwalk = function()
			local Character = LocalPlayer.Character
			local HumanoidRootPart = Character
			local Humanoid
			if HumanoidRootPart then
				HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
				Humanoid = Character
				if Humanoid then
					Humanoid = Character:FindFirstChildOfClass("Humanoid")
					if HumanoidRootPart and Humanoid then
						Humanoid.AutoRotate = false
						_G.Ox.Moonwalk.Enabled = true
						if not (n3 < n1) then
							n5 -= 617
							n3 = 671382733
							n2 = 142810932
							n4 = 832509534
							n1 = 81277292
							n7 = 689682959
							upv280 = nil
							;(nil)[nil] = nil
						end
						return
					end
				elseif HumanoidRootPart and Humanoid then
					Humanoid.AutoRotate = false
					_G.Ox.Moonwalk.Enabled = true
					if not (n3 < n1) then
						n5 -= 617
						n3 = 671382733
						n2 = 142810932
						n4 = 832509534
						n1 = 81277292
						n7 = 689682959
						upv280 = nil
						;(nil)[nil] = nil
					end
					return
				end
			elseif Character then
				Humanoid = Character:FindFirstChildOfClass("Humanoid")
				if HumanoidRootPart and Humanoid then
					Humanoid.AutoRotate = false
					_G.Ox.Moonwalk.Enabled = true
					if not (n3 < n1) then
						n5 -= 617
						n3 = 671382733
						n2 = 142810932
						n4 = 832509534
						n1 = 81277292
						n7 = 689682959
						upv280 = nil
						;(nil)[nil] = nil
					end
					return
				end
			end
		end
		UpdateMoonwalkGUI = function(p68)
			if not _G.Ox.Moonwalk.Gui then
				return
			end
			local Frame2 = _G.Ox.Moonwalk.Gui:FindFirstChild("Frame")
			if not Frame2 then
				return
			end
			local ActionButton = Frame2:FindFirstChild("ActionButton")
			local UIStroke3 = Frame2:FindFirstChild("UIStroke")
			if p68 then
				if ActionButton then
					if n1 == 677870210 then
						ActionButton.Text = "MOON [ON]"
					else
						n1 -= 750
						n4 = 182784497
						n2 = 452540476
						n7 -= 414
						n3 = 917227478
						n5 = 967802825
					end
					ActionButton.TextColor3 = Color3.fromRGB(180, 255, 180)
					ActionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
				end
				if UIStroke3 then
					UIStroke3.Color = Color3.fromRGB(100, 200, 100)
				end
			else
				if ActionButton then
					ActionButton.Text = "MOON [OFF]"
					ActionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
					ActionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
				end
				if UIStroke3 then
					UIStroke3.Color = Color3.fromRGB(90, 90, 95)
				end
			end
		end
		ToggleMoonwalkStatus = function()
			if _G.Ox.Moonwalk.Enabled then
				StopMoonwalk()
			else
				StartMoonwalk()
			end
			_G.Ox.Moonwalk.IsActive = _G.Ox.Moonwalk.Enabled
			UpdateMoonwalkGUI(_G.Ox.Moonwalk.Enabled)
			if MoonwalkPCToggle then
				v531(MoonwalkPCToggle, _G.Ox.Moonwalk.Enabled)
			end
			lib2:Notify({
				Title = "Moonwalk",
				Description = _G.Ox.Moonwalk.Enabled and "ON" or "OFF",
				Duration = 2
			})
		end
		CreateMoonwalkGUI = function()
			if _G.Ox.Moonwalk.Gui then
				_G.Ox.Moonwalk.Gui:Destroy()
			end
			local ScreenGui2 = Instance.new("ScreenGui")
			ScreenGui2.Name = "MoonwalkCustomGui"
			ScreenGui2.ResetOnSpawn = false
			ScreenGui2.IgnoreGuiInset = true
			ScreenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			ScreenGui2.Parent = CoreGui
			ScreenGui2.Enabled = false
			_G.Ox.Moonwalk.Gui = ScreenGui2
			_G.Ox.Moonwalk.GuiVisible = false
			local Frame2 = Instance.new("Frame", ScreenGui2)
			Frame2.Name = "Frame"
			Frame2.Size = UDim2.fromOffset(110, 36)
			Frame2.Position = UDim2.fromScale(0.85, 0.45)
			Frame2.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			Frame2.BackgroundTransparency = 0.1
			Frame2.Active = true
			Frame2.BorderSizePixel = 0
			Instance.new("UICorner", Frame2).CornerRadius = UDim.new(0, 8)
			local UIStroke3 = Instance.new("UIStroke", Frame2)
			UIStroke3.Name = "UIStroke"
			local n127 = 551761792
			UIStroke3.Color = Color3.fromRGB(90, 90, 95)
			UIStroke3.Thickness = 1.5
			UIStroke3.Transparency = 0.2
			local TextButton = Instance.new("TextButton", Frame2)
			TextButton.Name = "ActionButton"
			TextButton.Size = UDim2.new(1, 0, 1, 0)
			TextButton.Text = "MOON [OFF]"
			TextButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
			TextButton.Font = Enum.Font.GothamBold
			TextButton.TextSize = 12
			TextButton.TextColor3 = Color3.fromRGB(200, 200, 200)
			TextButton.BorderSizePixel = 0
			TextButton.AutoButtonColor = false
			Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 8)
			local u1349 = false
			local u1350 = false
			local u1351 = false
			local Position
			local Position2
			local thread
			local function v1355(p69)
				if not u1349 or not u1351 or not Position or not Position2 then
					return
				end
				local v1356 = p69.Position - Position
				if not u1350 and (math.abs(v1356.X) > 18 or math.abs(v1356.Y) > 18) then
					u1350 = true
				end
				if u1350 then
					Frame2.Position = UDim2.new(Position2.X.Scale, Position2.X.Offset + v1356.X, Position2.Y.Scale, Position2.Y.Offset + v1356.Y)
				end
			end
			TextButton.InputBegan:Connect(function(input)
				local n128 = 743492593
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					u1349 = true
					u1350 = false
					u1351 = false
					Position = input.Position
					Position2 = Frame2.Position
					if thread then
						task.cancel(thread)
					end
					thread = task.delay(0.18, function()
						if u1349 then
							u1351 = true
						end
						if n128 == n6 then
							n6 += 2031
							n127 += 1781
							n3 = 376647865
							n128 -= 2037
							n5 = 835878712
							;(nil)(nil)
						end
					end)
				end
			end)
			TextButton.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if thread then
						task.cancel(thread)
					end
					if u1349 and not u1350 then
						ToggleMoonwalkStatus()
					end
					u1349 = false
					u1350 = false
					u1351 = false
					Position = nil
					Position2 = nil
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if u1349 then
					if u1351 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						v1355(input)
					end
				end
			end)
			if _G.Ox.Moonwalk._statusConn then
				_G.Ox.Moonwalk._statusConn:Disconnect()
			end
			_G.Ox.Moonwalk._statusConn = RunService.Heartbeat:Connect(function()
				if not _G.Ox.Moonwalk.Gui or not _G.Ox.Moonwalk.Gui.Parent then
					if _G.Ox.Moonwalk._statusConn then
						_G.Ox.Moonwalk._statusConn:Disconnect()
					end
					return
				end
				if _G.Ox.Moonwalk.IsActive ~= _G.Ox.Moonwalk.Enabled then
					_G.Ox.Moonwalk.IsActive = _G.Ox.Moonwalk.Enabled
					UpdateMoonwalkGUI(_G.Ox.Moonwalk.Enabled)
				end
			end)
		end
		LocalPlayer.CharacterAdded:Connect(function()
			task.wait(1)
			if _G.Ox.Moonwalk.Enabled then
				StartMoonwalk()
			end
			if _G.Ox.Moonwalk.GuiVisible and _G.Ox.Moonwalk.Gui then
				_G.Ox.Moonwalk.Gui.Enabled = true
				UpdateMoonwalkGUI(_G.Ox.Moonwalk.Enabled)
			end
		end)
		task.spawn(function()
			task.wait(1.5)
			CreateMoonwalkGUI()
		end)
		RunService.RenderStepped:Connect(function(dt)
			local state = 1
			local v1359, Character, Humanoid, MoveDirection, HumanoidRootPart, v1364, Character2, HumanoidRootPart2, Humanoid2, CurrentCamera, Character3, vector3, vector32, CurrentCamera2, v1373, Character4, HumanoidRootPart3, v1376, CurrentCamera3, v1378, Character5, v1380, Position, v1382, Character6, HumanoidRootPart4, v1385, v1386, Character7, Parent, Humanoid3, Position2, Character8, HumanoidRootPart5, Parent2, Humanoid4, Character9, Character10, v1397, Aim_SilentVeilV2, Veil_ShowFOV, v1400, v1401, Veil_ShowFOV2, HumanoidRootPart6, Head, Position3
			while true do
				if state <= 3 then
					if state == 1 then
						v1359 = dt
						if _G.Ox.Speed.Enabled or _G.Ox.Moonwalk.Enabled or _G.Ox.Crosshair.Enabled or _G.Ox.StretchRes.Enabled or _G.Ox.Config.Surv_Aimbot_Enabled or _G.Ox.Config.Killer_Aimbot_Enabled and _G.Ox.isKillerAimbotHolding or _G.Ox.AimConfig.Aim_SilentVeilV2 or u521 and _G.Ox.AimConfig.Flash_Silent then
							state = 3
						else
							state = 2
						end
					elseif state == 2 then
						return
					elseif state == 3 then
						if _G.Ox.Crosshair.Enabled then
							state = 4
						else
							state = 5
						end
					end
				elseif state <= 6 then
					if state == 4 then
						DrawCrosshair()
						state = 5
					elseif state == 5 then
						if _G.Ox.Speed.Enabled then
							state = 6
						else
							state = 18
						end
					elseif state == 6 then
						Character = LocalPlayer.Character
						if Character then
							state = 7
						else
							state = 18
						end
					end
				elseif state <= 9 then
					if state == 7 then
						Humanoid = Character:FindFirstChildOfClass("Humanoid")
						if Humanoid then
							state = 8
						else
							state = 18
						end
					elseif state == 8 then
						MoveDirection = Humanoid.MoveDirection
						if MoveDirection.Magnitude > 0 then
							state = 9
						else
							state = 12
						end
					elseif state == 9 then
						HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
						if HumanoidRootPart then
							state = 10
						else
							state = 12
						end
					end
				elseif state <= 12 then
					if state == 10 then
						v1364 = (_G.Ox.Speed.Value - 0.1) * 10
						if v1364 > 0 then
							state = 11
						else
							state = 12
						end
					elseif state == 11 then
						HumanoidRootPart.CFrame += MoveDirection * v1364 * v1359
						state = 12
					elseif state == 12 then
						if _G.Ox.Moonwalk.Enabled then
							state = 13
						else
							state = 31
						end
					end
				elseif state <= 15 then
					if state == 13 then
						Character2 = LocalPlayer.Character
						HumanoidRootPart2 = Character2
						if HumanoidRootPart2 then
							state = 14
						else
							state = 15
						end
					elseif state == 14 then
						HumanoidRootPart2 = Character2:FindFirstChild("HumanoidRootPart")
						state = 15
					elseif state == 15 then
						Humanoid2 = Character2
						if Humanoid2 then
							state = 16
						else
							state = 17
						end
					end
				elseif state <= 18 then
					if state == 16 then
						Humanoid2 = Character2:FindFirstChildOfClass("Humanoid")
						state = 17
					elseif state == 17 then
						CurrentCamera = workspace.CurrentCamera
						if HumanoidRootPart2 and Humanoid2 and CurrentCamera then
							state = 24
						else
							state = 31
						end
					elseif state == 18 then
						if _G.Ox.Moonwalk.Enabled then
							state = 19
						else
							state = 39
						end
					end
				elseif state <= 21 then
					if state == 19 then
						Character3 = LocalPlayer.Character
						HumanoidRootPart2 = Character3
						if HumanoidRootPart2 then
							state = 20
						else
							state = 21
						end
					elseif state == 20 then
						HumanoidRootPart2 = Character3:FindFirstChild("HumanoidRootPart")
						state = 21
					elseif state == 21 then
						Humanoid2 = Character3
						if Humanoid2 then
							state = 22
						else
							state = 23
						end
					end
				elseif state <= 24 then
					if state == 22 then
						Humanoid2 = Character3:FindFirstChildOfClass("Humanoid")
						state = 23
					elseif state == 23 then
						CurrentCamera = workspace.CurrentCamera
						if HumanoidRootPart2 and Humanoid2 and CurrentCamera then
							state = 24
						else
							state = 39
						end
					elseif state == 24 then
						if Humanoid2.AutoRotate == false then
							state = 26
						else
							state = 25
						end
					end
				elseif state <= 27 then
					if state == 25 then
						Humanoid2.AutoRotate = false
						state = 26
					elseif state == 26 then
						vector3 = Vector3.new(CurrentCamera.CFrame.LookVector.X, 0, CurrentCamera.CFrame.LookVector.Z)
						vector32 = Vector3.new(CurrentCamera.CFrame.RightVector.X, 0, CurrentCamera.CFrame.RightVector.Z)
						if vector3.Magnitude > 0.001 then
							state = 27
						else
							state = 28
						end
					elseif state == 27 then
						vector3 = vector3.Unit
						state = 28
					end
				elseif state <= 30 then
					if state == 28 then
						if vector32.Magnitude > 0.001 then
							state = 29
						else
							state = 30
						end
					elseif state == 29 then
						vector32 = vector32.Unit
						state = 30
					elseif state == 30 then
						local v1406 = math.sin(tick() * 35)
						HumanoidRootPart2.CFrame = CFrame.lookAt(HumanoidRootPart2.Position, HumanoidRootPart2.Position + CFrame.Angles(0, math.rad(30 * v1406), 0) * vector3)
						Humanoid2:Move(-vector3 * 1.2 + vector32 * (v1406 * 1.05), false)
						state = 31
					end
				elseif state <= 33 then
					if state == 31 then
						if _G.Ox.StretchRes.Enabled then
							state = 32
						else
							state = 34
						end
					elseif state == 32 then
						CurrentCamera2 = workspace.CurrentCamera
						if CurrentCamera2 then
							state = 33
						else
							state = 34
						end
					elseif state == 33 then
						CurrentCamera2.CFrame *= CFrame.new(0, 0, 0, 1, 0, 0, 0, _G.Ox.StretchRes.Amount, 0, 0, 0, 1)
						state = 34
					end
				elseif state <= 36 then
					if state == 34 then
						if u521 and _G.Ox.AimConfig.Flash_Silent then
							state = 35
						else
							state = 48
						end
					elseif state == 35 then
						v1373 = getKillerTargetForFlash()
						if v1373 then
							state = 36
						else
							state = 48
						end
					elseif state == 36 then
						Character4 = v18.Character
						HumanoidRootPart3 = Character4
						if HumanoidRootPart3 then
							state = 37
						else
							state = 38
						end
					end
				elseif state <= 39 then
					if state == 37 then
						HumanoidRootPart3 = Character4:FindFirstChild("HumanoidRootPart")
						state = 38
					elseif state == 38 then
						v1376 = v1373.Position + Vector3.new(0, _G.Ox.AimConfig.Flash_YOffset, 0)
						local CurrentCamera4 = workspace.CurrentCamera
						CurrentCamera4.CFrame = CurrentCamera4.CFrame:Lerp(CFrame.lookAt(CurrentCamera4.CFrame.Position, v1376), 0.5)
						if HumanoidRootPart3 then
							state = 47
						else
							state = 48
						end
					elseif state == 39 then
						if _G.Ox.StretchRes.Enabled then
							state = 40
						else
							state = 42
						end
					end
				elseif state <= 42 then
					if state == 40 then
						CurrentCamera3 = workspace.CurrentCamera
						if CurrentCamera3 then
							state = 41
						else
							state = 42
						end
					elseif state == 41 then
						CurrentCamera3.CFrame *= CFrame.new(0, 0, 0, 1, 0, 0, 0, _G.Ox.StretchRes.Amount, 0, 0, 0, 1)
						state = 42
					elseif state == 42 then
						if u521 and _G.Ox.AimConfig.Flash_Silent then
							state = 43
						else
							state = 61
						end
					end
				elseif state <= 45 then
					if state == 43 then
						v1378 = getKillerTargetForFlash()
						if v1378 then
							state = 44
						else
							state = 61
						end
					elseif state == 44 then
						Character5 = v18.Character
						HumanoidRootPart3 = Character5
						if HumanoidRootPart3 then
							state = 45
						else
							state = 46
						end
					elseif state == 45 then
						HumanoidRootPart3 = Character5:FindFirstChild("HumanoidRootPart")
						state = 46
					end
				elseif state <= 48 then
					if state == 46 then
						v1376 = v1378.Position + Vector3.new(0, _G.Ox.AimConfig.Flash_YOffset, 0)
						local CurrentCamera4 = workspace.CurrentCamera
						CurrentCamera4.CFrame = CurrentCamera4.CFrame:Lerp(CFrame.lookAt(CurrentCamera4.CFrame.Position, v1376), 0.5)
						if HumanoidRootPart3 then
							state = 47
						else
							state = 61
						end
					elseif state == 47 then
						HumanoidRootPart3.CFrame = HumanoidRootPart3.CFrame:Lerp(CFrame.lookAt(HumanoidRootPart3.Position, Vector3.new(v1376.X, HumanoidRootPart3.Position.Y, v1376.Z)), 0.5)
						state = 48
					elseif state == 48 then
						if _G.Ox.Config.Surv_Aimbot_Enabled then
							state = 49
						else
							state = 60
						end
					end
				elseif state <= 51 then
					if state == 49 then
						if GetRole() == "Survivor" then
							state = 50
						else
							state = 73
						end
					elseif state == 50 then
						if _G.Ox.Config.Surv_Aimbot_ShowFOV then
							state = 51
						else
							state = 52
						end
					elseif state == 51 then
						_G.Ox.SurvivorFOVFrame.Visible = true
						_G.Ox.SurvivorFOVFrame.Size = UDim2.new(0, _G.Ox.Config.Surv_Aimbot_Radius * 2, 0, _G.Ox.Config.Surv_Aimbot_Radius * 2)
						state = 53
					end
				elseif state <= 54 then
					if state == 52 then
						_G.Ox.SurvivorFOVFrame.Visible = false
						state = 53
					elseif state == 53 then
						v1380 = getBestAimbotTarget()
						if v1380 then
							state = 54
						else
							state = 59
						end
					elseif state == 54 then
						_G.Ox.survivorAimbotHighlight.Parent = v1380.Parent
						Position = v1380.Position
						v1382 = GetDistance(Position)
						if v1382 < 100 then
							state = 55
						else
							state = 56
						end
					end
				elseif state <= 57 then
					if state == 55 then
						Position += workspace.CurrentCamera.CFrame.RightVector * ((100 - v1382) * _G.Ox.Config.Surv_Aimbot_Predict)
						state = 56
					elseif state == 56 then
						workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, Position), _G.Ox.Config.Surv_Aimbot_Smoothness)
						Character6 = v18.Character
						HumanoidRootPart4 = Character6
						if HumanoidRootPart4 then
							state = 57
						else
							state = 58
						end
					elseif state == 57 then
						HumanoidRootPart4 = Character6:FindFirstChild("HumanoidRootPart")
						state = 58
					end
				elseif state <= 60 then
					if state == 58 then
						if HumanoidRootPart4 then
							state = 72
						else
							state = 73
						end
					elseif state == 59 then
						_G.Ox.survivorAimbotHighlight.Parent = nil
						state = 73
					elseif state == 60 then
						_G.Ox.SurvivorFOVFrame.Visible = false
						_G.Ox.survivorAimbotHighlight.Parent = nil
						state = 73
					end
				elseif state <= 63 then
					if state == 61 then
						if _G.Ox.Config.Surv_Aimbot_Enabled then
							state = 62
						else
							state = 90
						end
					elseif state == 62 then
						if GetRole() == "Survivor" then
							state = 63
						else
							state = 91
						end
					elseif state == 63 then
						if _G.Ox.Config.Surv_Aimbot_ShowFOV then
							state = 64
						else
							state = 65
						end
					end
				elseif state <= 66 then
					if state == 64 then
						_G.Ox.SurvivorFOVFrame.Visible = true
						_G.Ox.SurvivorFOVFrame.Size = UDim2.new(0, _G.Ox.Config.Surv_Aimbot_Radius * 2, 0, _G.Ox.Config.Surv_Aimbot_Radius * 2)
						state = 66
					elseif state == 65 then
						_G.Ox.SurvivorFOVFrame.Visible = false
						state = 66
					elseif state == 66 then
						v1385 = getBestAimbotTarget()
						if v1385 then
							state = 67
						else
							state = 89
						end
					end
				elseif state <= 69 then
					if state == 67 then
						_G.Ox.survivorAimbotHighlight.Parent = v1385.Parent
						Position = v1385.Position
						v1386 = GetDistance(Position)
						if v1386 < 100 then
							state = 68
						else
							state = 69
						end
					elseif state == 68 then
						Position += workspace.CurrentCamera.CFrame.RightVector * ((100 - v1386) * _G.Ox.Config.Surv_Aimbot_Predict)
						state = 69
					elseif state == 69 then
						workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, Position), _G.Ox.Config.Surv_Aimbot_Smoothness)
						Character7 = v18.Character
						HumanoidRootPart4 = Character7
						if HumanoidRootPart4 then
							state = 70
						else
							state = 71
						end
					end
				elseif state <= 72 then
					if state == 70 then
						HumanoidRootPart4 = Character7:FindFirstChild("HumanoidRootPart")
						state = 71
					elseif state == 71 then
						if HumanoidRootPart4 then
							state = 72
						else
							state = 91
						end
					elseif state == 72 then
						HumanoidRootPart4.CFrame = HumanoidRootPart4.CFrame:Lerp(CFrame.new(HumanoidRootPart4.Position, Vector3.new(Position.X, HumanoidRootPart4.Position.Y, Position.Z)), _G.Ox.Config.Surv_Aimbot_Smoothness)
						state = 73
					end
				elseif state <= 75 then
					if state == 73 then
						if _G.Ox.Config.Killer_Aimbot_Enabled and _G.Ox.isKillerAimbotHolding then
							state = 74
						else
							state = 87
						end
					elseif state == 74 then
						if GetRole() == "Killer" then
							state = 75
						else
							state = 105
						end
					elseif state == 75 then
						if _G.Ox.lockedKillerAimbotTarget then
							state = 76
						else
							state = 86
						end
					end
				elseif state <= 78 then
					if state == 76 then
						Parent = _G.Ox.lockedKillerAimbotTarget.Parent
						Humanoid3 = Parent
						if Humanoid3 then
							state = 77
						else
							state = 78
						end
					elseif state == 77 then
						Humanoid3 = Parent:FindFirstChild("Humanoid")
						state = 78
					elseif state == 78 then
						if not Humanoid3 or Humanoid3.Health <= 0 or IsDowned(Parent) then
							state = 79
						else
							state = 80
						end
					end
				elseif state <= 81 then
					if state == 79 then
						_G.Ox.lockedKillerAimbotTarget = getBestKillerAimbotTarget()
						state = 80
					elseif state == 80 then
						if _G.Ox.lockedKillerAimbotTarget then
							state = 81
						else
							state = 105
						end
					elseif state == 81 then
						Position2 = _G.Ox.lockedKillerAimbotTarget.Position
						if _G.Ox.Config.Killer_Aimbot_MaxDist < GetDistance(Position2) then
							state = 82
						else
							state = 83
						end
					end
				elseif state <= 84 then
					if state == 82 then
						_G.Ox.lockedKillerAimbotTarget = getBestKillerAimbotTarget()
						state = 105
					elseif state == 83 then
						_G.Ox.killerAimbotHighlight.Parent = Parent
						workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, Position2), _G.Ox.Config.Killer_Aimbot_Smoothness)
						Character8 = v18.Character
						HumanoidRootPart5 = Character8
						if HumanoidRootPart5 then
							state = 84
						else
							state = 85
						end
					elseif state == 84 then
						HumanoidRootPart5 = Character8:FindFirstChild("HumanoidRootPart")
						state = 85
					end
				elseif state <= 87 then
					if state == 85 then
						if HumanoidRootPart5 then
							state = 104
						else
							state = 105
						end
					elseif state == 86 then
						_G.Ox.lockedKillerAimbotTarget = getBestKillerAimbotTarget()
						state = 105
					elseif state == 87 then
						if _G.Ox.killerAimbotHighlight then
							state = 88
						else
							state = 105
						end
					end
				elseif state <= 90 then
					if state == 88 then
						_G.Ox.killerAimbotHighlight.Parent = nil
						state = 105
					elseif state == 89 then
						_G.Ox.survivorAimbotHighlight.Parent = nil
						state = 91
					elseif state == 90 then
						_G.Ox.SurvivorFOVFrame.Visible = false
						_G.Ox.survivorAimbotHighlight.Parent = nil
						state = 91
					end
				elseif state <= 93 then
					if state == 91 then
						if _G.Ox.Config.Killer_Aimbot_Enabled and _G.Ox.isKillerAimbotHolding then
							state = 92
						else
							state = 117
						end
					elseif state == 92 then
						if GetRole() == "Killer" then
							state = 93
						else
							state = 119
						end
					elseif state == 93 then
						if _G.Ox.lockedKillerAimbotTarget then
							state = 94
						else
							state = 116
						end
					end
				elseif state <= 96 then
					if state == 94 then
						Parent2 = _G.Ox.lockedKillerAimbotTarget.Parent
						Humanoid4 = Parent2
						if Humanoid4 then
							state = 95
						else
							state = 96
						end
					elseif state == 95 then
						Humanoid4 = Parent2:FindFirstChild("Humanoid")
						state = 96
					elseif state == 96 then
						if not Humanoid4 or Humanoid4.Health <= 0 or IsDowned(Parent2) then
							state = 97
						else
							state = 98
						end
					end
				elseif state <= 99 then
					if state == 97 then
						_G.Ox.lockedKillerAimbotTarget = getBestKillerAimbotTarget()
						state = 98
					elseif state == 98 then
						if _G.Ox.lockedKillerAimbotTarget then
							state = 99
						else
							state = 119
						end
					elseif state == 99 then
						Position2 = _G.Ox.lockedKillerAimbotTarget.Position
						if _G.Ox.Config.Killer_Aimbot_MaxDist < GetDistance(Position2) then
							state = 100
						else
							state = 101
						end
					end
				elseif state <= 102 then
					if state == 100 then
						_G.Ox.lockedKillerAimbotTarget = getBestKillerAimbotTarget()
						state = 119
					elseif state == 101 then
						_G.Ox.killerAimbotHighlight.Parent = Parent2
						workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, Position2), _G.Ox.Config.Killer_Aimbot_Smoothness)
						Character9 = v18.Character
						HumanoidRootPart5 = Character9
						if HumanoidRootPart5 then
							state = 102
						else
							state = 103
						end
					elseif state == 102 then
						HumanoidRootPart5 = Character9:FindFirstChild("HumanoidRootPart")
						state = 103
					end
				elseif state <= 105 then
					if state == 103 then
						if HumanoidRootPart5 then
							state = 104
						else
							state = 119
						end
					elseif state == 104 then
						HumanoidRootPart5.CFrame = HumanoidRootPart5.CFrame:Lerp(CFrame.new(HumanoidRootPart5.Position, Vector3.new(Position2.X, HumanoidRootPart5.Position.Y, Position2.Z)), _G.Ox.Config.Killer_Aimbot_Smoothness)
						state = 105
					elseif state == 105 then
						Character10 = v17.Character
						v1397 = Character10
						if v1397 then
							state = 106
						else
							state = 107
						end
					end
				elseif state <= 108 then
					if state == 106 then
						v1397 = Character10:GetAttribute("spearmode") == true
						state = 107
					elseif state == 107 then
						Aim_SilentVeilV2 = _G.Ox.AimConfig.Aim_SilentVeilV2
						if Aim_SilentVeilV2 then
							state = 108
						else
							state = 109
						end
					elseif state == 108 then
						Aim_SilentVeilV2 = v1397
						state = 109
					end
				elseif state <= 111 then
					if state == 109 then
						Veil_ShowFOV = Aim_SilentVeilV2
						if Veil_ShowFOV then
							state = 110
						else
							state = 111
						end
					elseif state == 110 then
						Veil_ShowFOV = _G.Ox.AimConfig.Veil_ShowFOV
						state = 111
					elseif state == 111 then
						if Veil_ShowFOV then
							state = 112
						else
							state = 113
						end
					end
				elseif state <= 114 then
					if state == 112 then
						Frame.Visible = true
						Frame.Size = UDim2.new(0, _G.Ox.AimConfig.Veil_FOV * 2, 0, _G.Ox.AimConfig.Veil_FOV * 2)
						state = 114
					elseif state == 113 then
						Frame.Visible = false
						state = 114
					elseif state == 114 then
						if Veil_ShowFOV then
							state = 115
						else
							state = 143
						end
					end
				elseif state <= 117 then
					if state == 115 then
						v1400 = getClosestSurvivor()
						if v1400 then
							state = 131
						else
							state = 141
						end
					elseif state == 116 then
						_G.Ox.lockedKillerAimbotTarget = getBestKillerAimbotTarget()
						state = 119
					elseif state == 117 then
						if _G.Ox.killerAimbotHighlight then
							state = 118
						else
							state = 119
						end
					end
				elseif state <= 120 then
					if state == 118 then
						_G.Ox.killerAimbotHighlight.Parent = nil
						state = 119
					elseif state == 119 then
						Character10 = v17.Character
						v1401 = Character10
						if v1401 then
							state = 120
						else
							state = 121
						end
					elseif state == 120 then
						v1401 = Character10:GetAttribute("spearmode") == true
						state = 121
					end
				elseif state <= 123 then
					if state == 121 then
						Aim_SilentVeilV2 = _G.Ox.AimConfig.Aim_SilentVeilV2
						if Aim_SilentVeilV2 then
							state = 122
						else
							state = 123
						end
					elseif state == 122 then
						Aim_SilentVeilV2 = v1401
						state = 123
					elseif state == 123 then
						Veil_ShowFOV2 = Aim_SilentVeilV2
						if Veil_ShowFOV2 then
							state = 124
						else
							state = 125
						end
					end
				elseif state <= 126 then
					if state == 124 then
						Veil_ShowFOV2 = _G.Ox.AimConfig.Veil_ShowFOV
						state = 125
					elseif state == 125 then
						if Veil_ShowFOV2 then
							state = 126
						else
							state = 127
						end
					elseif state == 126 then
						Frame.Visible = true
						Frame.Size = UDim2.new(0, _G.Ox.AimConfig.Veil_FOV * 2, 0, _G.Ox.AimConfig.Veil_FOV * 2)
						state = 128
					end
				elseif state <= 129 then
					if state == 127 then
						Frame.Visible = false
						state = 128
					elseif state == 128 then
						if Veil_ShowFOV2 then
							state = 129
						else
							state = 143
						end
					elseif state == 129 then
						v1400 = getClosestSurvivor()
						if v1400 then
							state = 130
						else
							state = 141
						end
					end
				elseif state <= 132 then
					if state == 130 then
						state = 131
					elseif state == 131 then
						if v1400.Parent then
							state = 132
						else
							state = 141
						end
					elseif state == 132 then
						Highlight.Parent = v1400.Parent
						HumanoidRootPart6 = Character10
						if HumanoidRootPart6 then
							state = 133
						else
							state = 134
						end
					end
				elseif state <= 135 then
					if state == 133 then
						HumanoidRootPart6 = Character10:FindFirstChild("HumanoidRootPart")
						state = 134
					elseif state == 134 then
						Head = Character10
						if Head then
							state = 135
						else
							state = 137
						end
					elseif state == 135 then
						Head = Character10:FindFirstChild("Head")
						if Head then
							state = 137
						else
							state = 136
						end
					end
				elseif state <= 138 then
					if state == 136 then
						Head = HumanoidRootPart6
						state = 137
					elseif state == 137 then
						Position3 = Head
						if Position3 then
							state = 138
						else
							state = 139
						end
					elseif state == 138 then
						Position3 = Head.Position
						state = 139
					end
				elseif state <= 141 then
					if state == 139 then
						v1332(Position3, v1400.Position)
						state = 140
					elseif state == 140 then
						return
					elseif state == 141 then
						Highlight.Parent = nil
						v1332(nil, nil)
						state = 142
					end
				elseif state <= 144 then
					if state == 142 then
						return
					end
					if state == 143 then
						Highlight.Parent = nil
						v1332(nil, nil)
						if Aim_SilentVeilV2 then
							state = 146
						else
							state = 144
						end
					elseif state == 144 then
						v1331()
						state = 145
					end
				elseif state == 145 then
					return
				elseif state == 146 then
					return
				end
			end
		end)
		local n129 = 0
		RunService.Heartbeat:Connect(function()
			local _
			local state = 1
			local Character, v1416, HumanoidRootPart, Character2, Humanoid, forIter, forState, forControl, v1423, Character3, Humanoid2
			while true do
				if state == 1 then
					if _G.Ox.ParryConfig.ParryCircle and _G.Ox.ParryConfig.AutoParry then
						state = 2
					else
						state = 16
					end
				elseif state == 2 then
					Character = LocalPlayer.Character
					if Character then
						state = 3
					else
						state = 14
					end
				elseif state == 3 then
					v1416 = Character
					HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
					if HumanoidRootPart then
						state = 4
					else
						state = 13
					end
				elseif state == 4 then
					if _G.Ox.State.AutoParryAdornment and _G.Ox.State.AutoParryAdornment.Parent == HumanoidRootPart then
						state = 8
					else
						state = 5
					end
				elseif state == 5 then
					if _G.Ox.State.AutoParryAdornment then
						state = 6
					else
						state = 7
					end
				elseif state == 6 then
					local AutoParryAdornment = _G.Ox.State.AutoParryAdornment
					local v1427 = AutoParryAdornment
					local Destroy = AutoParryAdornment.Destroy
					v1416 = Destroy
					Destroy(v1427)
					state = 7
				elseif state == 7 then
					_G.Ox.State.AutoParryAdornment = Instance.new("CylinderHandleAdornment")
					_G.Ox.State.AutoParryAdornment.Name = "AutoParryCircleESP"
					_G.Ox.State.AutoParryAdornment.Height = 0.05
					_G.Ox.State.AutoParryAdornment.Transparency = 0.3
					_G.Ox.State.AutoParryAdornment.Adornee = HumanoidRootPart
					_G.Ox.State.AutoParryAdornment.Parent = HumanoidRootPart
					_G.Ox.State.AutoParryAdornment.ZIndex = 0
					_G.Ox.State.AutoParryAdornment.AlwaysOnTop = false
					state = 8
				elseif state == 8 then
					local ParryRadius = _G.Ox.ParryConfig.ParryRadius
					_G.Ox.State.AutoParryAdornment.Radius = ParryRadius
					_G.Ox.State.AutoParryAdornment.InnerRadius = math.max(0.1, ParryRadius - 0.15)
					_G.Ox.State.AutoParryAdornment.CFrame = CFrame.new(0, -3, 0) * CFrame.Angles(math.rad(90), 0, 0)
					if _G.Ox.State.ParryCooldown then
						state = 9
					else
						state = 10
					end
				elseif state == 9 then
					_G.Ox.State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 128, 0)
					state = 18
				elseif state == 10 then
					if _G.Ox.ParryConfig.ParryAggressive then
						state = 11
					else
						state = 12
					end
				elseif state == 11 then
					_G.Ox.State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 0, 0)
					state = 18
				elseif state == 12 then
					_G.Ox.State.AutoParryAdornment.Color3 = Color3.fromRGB(255, 255, 255)
					state = 18
				elseif state == 13 then
					if _G.Ox.State.AutoParryAdornment then
						state = 15
					else
						state = 18
					end
				elseif state == 14 then
					if _G.Ox.State.AutoParryAdornment then
						state = 15
					else
						state = 20
					end
				elseif state == 15 then
					local AutoParryAdornment = _G.Ox.State.AutoParryAdornment
					local v1431 = AutoParryAdornment
					local Destroy = AutoParryAdornment.Destroy
					v1416 = Destroy
					Destroy(v1431)
					_G.Ox.State.AutoParryAdornment = nil
					state = 18
				elseif state == 16 then
					if _G.Ox.State.AutoParryAdornment then
						state = 17
					else
						state = 20
					end
				elseif state == 17 then
					local AutoParryAdornment = _G.Ox.State.AutoParryAdornment
					local v1434 = AutoParryAdornment
					local Destroy = AutoParryAdornment.Destroy
					v1416 = Destroy
					Destroy(v1434)
					_G.Ox.State.AutoParryAdornment = nil
					state = 18
				elseif state == 18 then
					if _G.Ox.GodMode then
						state = 19
					else
						state = 24
					end
				elseif state == 19 then
					Character2 = LocalPlayer.Character
					if Character2 then
						state = 22
					else
						state = 24
					end
				elseif state == 20 then
					if _G.Ox.GodMode then
						state = 21
					else
						state = 25
					end
				elseif state == 21 then
					Character2 = LocalPlayer.Character
					if Character2 then
						state = 22
					else
						state = 25
					end
				elseif state == 22 then
					v1416 = Character2
					Humanoid = Character2:FindFirstChildOfClass("Humanoid")
					if Humanoid and Humanoid.Health < Humanoid.MaxHealth then
						state = 23
					else
						state = 24
					end
				elseif state == 23 then
					Humanoid.Health = Humanoid.MaxHealth
					state = 24
				elseif state == 24 then
					if _G.Ox.AutoPallet.Enabled then
						state = 26
					else
						state = 30
					end
				elseif state == 25 then
					if _G.Ox.AutoPallet.Enabled then
						state = 26
					else
						state = 36
					end
				elseif state == 26 then
					state = 27
				elseif state == 27 then
					forIter, forState, forControl = pairs(_G.Ox.AutoPallet.UsedPallets)
					if type(forIter) == 'table' then
						local forMeta = getmetatable(forIter)
						if type(forMeta) == 'table' and forMeta['__iter'] then
							forIter, forState, forControl = (forMeta['__iter'](forIter))
						else
							forIter, forState, forControl = next, forIter, nil
						end
					end
					state = 28
				elseif state == 28 then
					local v1437
					v1423, v1437 = (forIter(forState, forControl))
					if v1423 == nil then
						state = 29
					else
						forControl = v1423
						state = 34
					end
				elseif state == 29 then
					v1416 = t291_239_1[1]
					state = 30
				else
					if state == 30 then
						if _G.Ox.CameraFOV.Enabled then
							state = 31
						else
							state = 32
						end
					elseif state == 31 then
						workspace.CurrentCamera.FieldOfView = _G.Ox.CameraFOV.Value
						state = 32
					elseif state == 32 then
						if _G.Ox.NoSlowdownEnabled then
							state = 33
						else
							state = 42
						end
					elseif state == 33 then
						Character3 = LocalPlayer.Character
						if Character3 then
							state = 40
						else
							state = 42
						end
					elseif state == 34 then
						if v1423 and v1423.Parent then
							state = 28
						else
							state = 35
						end
					elseif state == 35 then
						_G.Ox.AutoPallet.UsedPallets[v1423] = nil
						state = 28
					elseif state == 36 then
						if _G.Ox.CameraFOV.Enabled then
							state = 37
						else
							state = 38
						end
					elseif state == 37 then
						workspace.CurrentCamera.FieldOfView = _G.Ox.CameraFOV.Value
						state = 38
					elseif state == 38 then
						if _G.Ox.NoSlowdownEnabled then
							state = 39
						else
							state = 46
						end
					elseif state == 39 then
						Character3 = LocalPlayer.Character
						if Character3 then
							state = 40
						else
							state = 46
						end
					elseif state == 40 then
						v1416 = Character3
						Humanoid2 = Character3:FindFirstChildOfClass("Humanoid")
						if Humanoid2 and GetRole() == "Killer" and Humanoid2.WalkSpeed < 16 then
							state = 41
						else
							state = 42
						end
					elseif state == 41 then
						Humanoid2.WalkSpeed = 16
						state = 42
					elseif state == 42 then
						if _G.Ox.ESPConfig.Master and tick() - n129 >= 2 then
							state = 43
						else
							state = 45
						end
					elseif state == 43 then
						n129 = tick()
						UpdatePlayerESP()
						if n6 == n7 then
							state = 44
						else
							state = 50
						end
					elseif state == 44 then
						n4 -= 1238
						n7 += 553
						n2 += 240
						n6 = 779880449
						n1 += 267
						n5 = 469717484
						upv280[nil  ] = nil
						upv280[v1416] = nil
						state = 49
					else
						if state == 45 then
							return
						end
						if state == 46 then
							if _G.Ox.ESPConfig.Master and tick() - n129 >= 2 then
								state = 47
							else
								state = 53
							end
						elseif state == 47 then
							n129 = tick()
							UpdatePlayerESP()
							if n6 == n7 then
								state = 48
							else
								state = 50
							end
						elseif state == 48 then
							n4 -= 1238
							n7 += 553
							n2 += 240
							n6 = 779880449
							n1 += 267
							n5 = 469717484
							upv280[nil  ] = nil
							upv280[nil] = nil
							state = 49
						elseif state == 49 then
							state = 51
						elseif state == 50 then
							UpdateSCPESP()
							state = 51
						elseif state == 51 then
							UpdateStaticESP()
							state = 52
						elseif state == 52 then
							return
						elseif state == 53 then
							return
						end
					end
				end
			end
		end)
		local Items = ReplicatedStorage:WaitForChild("Items", 5)
		extractAssetId = function(p70)
			return tostring(p70):match("%d+")
		end
		getItemIcon = function(p71)
			if not Items then
				return nil
			end
			local n130 = 212125349
			local v1440 = Items:FindFirstChild(p71)
			local n131 = 604782152
			if not v1440 then
				return nil
			end
			local Texture
			local n132 = 633590872
			local function v1444()
				Texture = v1440.Texture or v1440.Image
			end
			pcall(v1444)
			if Texture and Texture ~= "" then
				local v1445 = extractAssetId(Texture)
				if v1445 then
					return ("rbxthumb://type=Asset&id=%s&w=420&h=420"):format(v1445)
				end
			end
			if n5 == 403422737 then
				return nil
			end
			n130 += 561
			n4 = 594776437
			n7 = 931703073
			n6 -= 1304
			n132 -= 499
			n3 = 40737667
			n131 += 567
			n1 = 966346179
			n5 = 159719626
		end
		CreateModernESP = function(p72, p73, p74)
			if not p72 then
				return
			end
			local name = p74.name or ""
			local v1447 = name ~= ""
			local v1448 = p73 ~= "PE_Text" or not v1447
			local v1449 = v1448 and "single" or "multi"
			local infoRich = p74.infoRich or ""
			local BillboardGui, vector3New, Frame2, UIScale, UIListLayout, uDimNew, n133, n134, Frame3, UIListLayout2, ImageLabel, TextLabel, TextLabel2, UIListLayout3, ImageLabel2, TextLabel3
			if infoRich == "" then
				local t13 = {}
				if not p74.subtext or p74.subtext == "" then
					if p74.distance then
						table.insert(t13, tostring(p74.distance) .. "m")
					end
					infoRich = table.concat(t13, " <font color=\"#888888\">·</font> ")
					BillboardGui = p72:FindFirstChild(p73)
					if BillboardGui and BillboardGui:GetAttribute("Layout") ~= v1449 then
						BillboardGui:Destroy()
						BillboardGui = nil
					end
					if not BillboardGui then
						BillboardGui = Instance.new("BillboardGui")
						BillboardGui.Name = p73
						BillboardGui.AlwaysOnTop = true
						BillboardGui:SetAttribute("Layout", v1449)
						BillboardGui.Size = v1448 and UDim2.new(0, 220, 0, 22) or UDim2.new(0, 220, 0, 34)
						vector3New = Vector3.new
						BillboardGui.StudsOffset = vector3New(0, p74.offsetY or 4, 0)
						BillboardGui.Parent = p72
						Frame2 = Instance.new("Frame")
						Frame2.Name = "Box"
						Frame2.BackgroundTransparency = 1
						Frame2.Size = UDim2.new(1, 0, 1, 0)
						Frame2.AnchorPoint = Vector2.new(0.5, 0.5)
						Frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
						Frame2.Parent = BillboardGui
						if p74.noDistScale then
							BillboardGui:SetAttribute("NoDistScale", true)
						else
							UIScale = Instance.new("UIScale")
							UIScale.Name = "DistScale"
							UIScale.Scale = 1
							UIScale.Parent = Frame2
						end
						if v1448 then
							UIListLayout3 = Instance.new("UIListLayout", Frame2)
							UIListLayout3.FillDirection = Enum.FillDirection.Horizontal
							UIListLayout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
							UIListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
							UIListLayout3.Padding = UDim.new(0, 4)
							ImageLabel2 = Instance.new("ImageLabel")
							ImageLabel2.Name = "Icon"
							ImageLabel2.BackgroundTransparency = 1
							ImageLabel2.Size = UDim2.new(0, 14, 0, 14)
							ImageLabel2.Visible = false
							ImageLabel2.Parent = Frame2
							TextLabel3 = Instance.new("TextLabel")
							TextLabel3.Name = "Text"
							TextLabel3.BackgroundTransparency = 1
							TextLabel3.AutomaticSize = Enum.AutomaticSize.XY
							TextLabel3.Font = Enum.Font.GothamBold
							TextLabel3.TextSize = 12
							TextLabel3.TextWrapped = false
							TextLabel3.TextYAlignment = Enum.TextYAlignment.Center
							TextLabel3.RichText = true
							TextLabel3.TextStrokeTransparency = 0
							TextLabel3.TextStrokeColor3 = Color3.new(0, 0, 0)
							TextLabel3.Parent = Frame2
						else
							UIListLayout = Instance.new("UIListLayout", Frame2)
							UIListLayout.FillDirection = Enum.FillDirection.Vertical
							UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
							UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
							uDimNew = UDim.new
							n133 = 0
							n134 = 0
							UIListLayout.Padding = uDimNew(n133, n134)
							Frame3 = Instance.new("Frame")
							Frame3.Name = "Row1"
							Frame3.BackgroundTransparency = 1
							Frame3.AutomaticSize = Enum.AutomaticSize.XY
							Frame3.Size = UDim2.new(0, 0, 0, 16)
							Frame3.Parent = Frame2
							UIListLayout2 = Instance.new("UIListLayout", Frame3)
							UIListLayout2.FillDirection = Enum.FillDirection.Horizontal
							UIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
							UIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
							UIListLayout2.Padding = UDim.new(0, 4)
							ImageLabel = Instance.new("ImageLabel")
							ImageLabel.Name = "Icon"
							ImageLabel.BackgroundTransparency = 1
							ImageLabel.Size = UDim2.new(0, 14, 0, 14)
							ImageLabel.Visible = false
							ImageLabel.Parent = Frame3
							TextLabel = Instance.new("TextLabel")
							TextLabel.Name = "Name"
							TextLabel.BackgroundTransparency = 1
							TextLabel.AutomaticSize = Enum.AutomaticSize.XY
							TextLabel.Font = Enum.Font.GothamBold
							TextLabel.TextSize = 12
							TextLabel.TextWrapped = false
							TextLabel.TextYAlignment = Enum.TextYAlignment.Center
							TextLabel.TextStrokeTransparency = 0
							TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
							TextLabel.Parent = Frame3
							TextLabel2 = Instance.new("TextLabel")
							TextLabel2.Name = "Info"
							TextLabel2.BackgroundTransparency = 1
							TextLabel2.AutomaticSize = Enum.AutomaticSize.XY
							TextLabel2.Font = Enum.Font.GothamBold
							TextLabel2.TextSize = 11
							TextLabel2.TextWrapped = false
							TextLabel2.TextYAlignment = Enum.TextYAlignment.Center
							TextLabel2.RichText = true
							TextLabel2.TextStrokeTransparency = 0
							TextLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
							TextLabel2.Parent = Frame2
						end
					end
				else
					table.insert(t13, tostring(p74.subtext))
					if p74.distance then
						table.insert(t13, tostring(p74.distance) .. "m")
					end
					infoRich = table.concat(t13, " <font color=\"#888888\">·</font> ")
					BillboardGui = p72:FindFirstChild(p73)
					if BillboardGui and BillboardGui:GetAttribute("Layout") ~= v1449 then
						BillboardGui:Destroy()
						BillboardGui = nil
					end
					if not BillboardGui then
						BillboardGui = Instance.new("BillboardGui")
						BillboardGui.Name = p73
						BillboardGui.AlwaysOnTop = true
						BillboardGui:SetAttribute("Layout", v1449)
						BillboardGui.Size = v1448 and UDim2.new(0, 220, 0, 22) or UDim2.new(0, 220, 0, 34)
						BillboardGui.StudsOffset = Vector3.new(0, p74.offsetY or 4, 0)
						BillboardGui.Parent = p72
						Frame2 = Instance.new("Frame")
						Frame2.Name = "Box"
						Frame2.BackgroundTransparency = 1
						Frame2.Size = UDim2.new(1, 0, 1, 0)
						Frame2.AnchorPoint = Vector2.new(0.5, 0.5)
						Frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
						Frame2.Parent = BillboardGui
						if p74.noDistScale then
							BillboardGui:SetAttribute("NoDistScale", true)
						else
							local UIScale2 = Instance.new("UIScale")
							UIScale2.Name = "DistScale"
							UIScale2.Scale = 1
							UIScale2.Parent = Frame2
						end
						if v1448 then
							UIListLayout3 = Instance.new("UIListLayout", Frame2)
							UIListLayout3.FillDirection = Enum.FillDirection.Horizontal
							UIListLayout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
							UIListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
							UIListLayout3.Padding = UDim.new(0, 4)
							ImageLabel2 = Instance.new("ImageLabel")
							ImageLabel2.Name = "Icon"
							ImageLabel2.BackgroundTransparency = 1
							ImageLabel2.Size = UDim2.new(0, 14, 0, 14)
							ImageLabel2.Visible = false
							ImageLabel2.Parent = Frame2
							TextLabel3 = Instance.new("TextLabel")
							TextLabel3.Name = "Text"
							TextLabel3.BackgroundTransparency = 1
							TextLabel3.AutomaticSize = Enum.AutomaticSize.XY
							TextLabel3.Font = Enum.Font.GothamBold
							TextLabel3.TextSize = 12
							TextLabel3.TextWrapped = false
							TextLabel3.TextYAlignment = Enum.TextYAlignment.Center
							TextLabel3.RichText = true
							TextLabel3.TextStrokeTransparency = 0
							TextLabel3.TextStrokeColor3 = Color3.new(0, 0, 0)
							TextLabel3.Parent = Frame2
						else
							UIListLayout = Instance.new("UIListLayout", Frame2)
							UIListLayout.FillDirection = Enum.FillDirection.Vertical
							UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
							UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
							UIListLayout.Padding = UDim.new(0, 0)
							Frame3 = Instance.new("Frame")
							Frame3.Name = "Row1"
							Frame3.BackgroundTransparency = 1
							Frame3.AutomaticSize = Enum.AutomaticSize.XY
							Frame3.Size = UDim2.new(0, 0, 0, 16)
							Frame3.Parent = Frame2
							UIListLayout2 = Instance.new("UIListLayout", Frame3)
							UIListLayout2.FillDirection = Enum.FillDirection.Horizontal
							UIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
							UIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
							UIListLayout2.Padding = UDim.new(0, 4)
							ImageLabel = Instance.new("ImageLabel")
							ImageLabel.Name = "Icon"
							ImageLabel.BackgroundTransparency = 1
							ImageLabel.Size = UDim2.new(0, 14, 0, 14)
							ImageLabel.Visible = false
							ImageLabel.Parent = Frame3
							TextLabel = Instance.new("TextLabel")
							TextLabel.Name = "Name"
							TextLabel.BackgroundTransparency = 1
							TextLabel.AutomaticSize = Enum.AutomaticSize.XY
							TextLabel.Font = Enum.Font.GothamBold
							TextLabel.TextSize = 12
							TextLabel.TextWrapped = false
							TextLabel.TextYAlignment = Enum.TextYAlignment.Center
							TextLabel.TextStrokeTransparency = 0
							TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
							TextLabel.Parent = Frame3
							TextLabel2 = Instance.new("TextLabel")
							TextLabel2.Name = "Info"
							TextLabel2.BackgroundTransparency = 1
							TextLabel2.AutomaticSize = Enum.AutomaticSize.XY
							TextLabel2.Font = Enum.Font.GothamBold
							TextLabel2.TextSize = 11
							TextLabel2.TextWrapped = false
							TextLabel2.TextYAlignment = Enum.TextYAlignment.Center
							TextLabel2.RichText = true
							TextLabel2.TextStrokeTransparency = 0
							TextLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
							TextLabel2.Parent = Frame2
						end
					end
				end
			else
				BillboardGui = p72:FindFirstChild(p73)
				if BillboardGui and BillboardGui:GetAttribute("Layout") ~= v1449 then
					BillboardGui:Destroy()
					BillboardGui = nil
				end
				if not BillboardGui then
					BillboardGui = Instance.new("BillboardGui")
					BillboardGui.Name = p73
					BillboardGui.AlwaysOnTop = true
					BillboardGui:SetAttribute("Layout", v1449)
					local uDim2 = v1448 and UDim2.new(0, 220, 0, 22) or UDim2.new(0, 220, 0, 34)
					BillboardGui.Size = uDim2
					vector3New = Vector3.new
					local n135 = 0
					local offsetY = p74.offsetY or 4
					BillboardGui.StudsOffset = vector3New(n135, offsetY, 0)
					BillboardGui.Parent = p72
					Frame2 = Instance.new("Frame")
					Frame2.Name = "Box"
					Frame2.BackgroundTransparency = 1
					Frame2.Size = UDim2.new(1, 0, 1, 0)
					Frame2.AnchorPoint = Vector2.new(0.5, 0.5)
					Frame2.Position = UDim2.new(0.5, 0, 0.5, 0)
					Frame2.Parent = BillboardGui
					if p74.noDistScale then
						BillboardGui:SetAttribute("NoDistScale", true)
					else
						UIScale = Instance.new("UIScale")
						UIScale.Name = "DistScale"
						UIScale.Scale = 1
						UIScale.Parent = Frame2
					end
					if v1448 then
						UIListLayout3 = Instance.new("UIListLayout", Frame2)
						UIListLayout3.FillDirection = Enum.FillDirection.Horizontal
						UIListLayout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
						UIListLayout3.VerticalAlignment = Enum.VerticalAlignment.Center
						UIListLayout3.Padding = UDim.new(0, 4)
						ImageLabel2 = Instance.new("ImageLabel")
						ImageLabel2.Name = "Icon"
						ImageLabel2.BackgroundTransparency = 1
						ImageLabel2.Size = UDim2.new(0, 14, 0, 14)
						ImageLabel2.Visible = false
						ImageLabel2.Parent = Frame2
						TextLabel3 = Instance.new("TextLabel")
						TextLabel3.Name = "Text"
						TextLabel3.BackgroundTransparency = 1
						TextLabel3.AutomaticSize = Enum.AutomaticSize.XY
						TextLabel3.Font = Enum.Font.GothamBold
						TextLabel3.TextSize = 12
						TextLabel3.TextWrapped = false
						TextLabel3.TextYAlignment = Enum.TextYAlignment.Center
						TextLabel3.RichText = true
						TextLabel3.TextStrokeTransparency = 0
						TextLabel3.TextStrokeColor3 = Color3.new(0, 0, 0)
						TextLabel3.Parent = Frame2
					else
						UIListLayout = Instance.new("UIListLayout", Frame2)
						UIListLayout.FillDirection = Enum.FillDirection.Vertical
						UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
						UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
						uDimNew = UDim.new
						n133 = 0
						n134 = 0
						UIListLayout.Padding = uDimNew(n133, n134)
						Frame3 = Instance.new("Frame")
						Frame3.Name = "Row1"
						Frame3.BackgroundTransparency = 1
						Frame3.AutomaticSize = Enum.AutomaticSize.XY
						Frame3.Size = UDim2.new(0, 0, 0, 16)
						Frame3.Parent = Frame2
						UIListLayout2 = Instance.new("UIListLayout", Frame3)
						UIListLayout2.FillDirection = Enum.FillDirection.Horizontal
						UIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
						UIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
						UIListLayout2.Padding = UDim.new(0, 4)
						ImageLabel = Instance.new("ImageLabel")
						ImageLabel.Name = "Icon"
						ImageLabel.BackgroundTransparency = 1
						ImageLabel.Size = UDim2.new(0, 14, 0, 14)
						ImageLabel.Visible = false
						ImageLabel.Parent = Frame3
						TextLabel = Instance.new("TextLabel")
						TextLabel.Name = "Name"
						TextLabel.BackgroundTransparency = 1
						TextLabel.AutomaticSize = Enum.AutomaticSize.XY
						TextLabel.Font = Enum.Font.GothamBold
						TextLabel.TextSize = 12
						TextLabel.TextWrapped = false
						TextLabel.TextYAlignment = Enum.TextYAlignment.Center
						TextLabel.TextStrokeTransparency = 0
						TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
						TextLabel.Parent = Frame3
						TextLabel2 = Instance.new("TextLabel")
						TextLabel2.Name = "Info"
						TextLabel2.BackgroundTransparency = 1
						TextLabel2.AutomaticSize = Enum.AutomaticSize.XY
						TextLabel2.Font = Enum.Font.GothamBold
						TextLabel2.TextSize = 11
						TextLabel2.TextWrapped = false
						TextLabel2.TextYAlignment = Enum.TextYAlignment.Center
						TextLabel2.RichText = true
						TextLabel2.TextStrokeTransparency = 0
						TextLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
						TextLabel2.Parent = Frame2
					end
				end
			end
			local Box = BillboardGui:FindFirstChild("Box")
			if v1448 then
				local Text = Box and Box:FindFirstChild("Text")
				local Icon = Box and Box:FindFirstChild("Icon")
				if Text then
					local s1 = "#FFFFFF"
					if p74.color then
						s1 = string.format("#%02X%02X%02X", math.floor(p74.color.R * 255), math.floor(p74.color.G * 255), math.floor(p74.color.B * 255))
					end
					local v1476 = tostring(name):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
					local text = ""
					if v1447 then
						text = string.format("<font color=\"%s\">%s</font>", s1, v1476)
					end
					if infoRich ~= "" then
						if text == "" then
							text = infoRich
						elseif p74.noSeparator then
							text ..= " " .. infoRich
						else
							text ..= " <font color=\"#888888\">·</font> " .. infoRich
						end
					end
					Text.Text = text
				end
				if Icon then
					if not p74.icon or p74.icon == "" then
						Icon.Visible = false
					else
						Icon.Image = p74.icon
						Icon.Visible = true
					end
				end
			else
				local Row1 = Box and Box:FindFirstChild("Row1")
				local Name = Row1 and Row1:FindFirstChild("Name")
				local Icon = Row1 and Row1:FindFirstChild("Icon")
				local Info = Box and Box:FindFirstChild("Info")
				if Name then
					Name.Text = tostring(name):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
					Name.TextColor3 = p74.color or Color3.new(1, 1, 1)
				end
				if Icon then
					if not p74.icon or p74.icon == "" then
						Icon.Visible = false
					else
						Icon.Image = p74.icon
						Icon.Visible = true
					end
				end
				if Info then
					if infoRich == "" then
						Info.Visible = false
					else
						Info.Visible = true
						Info.Text = infoRich
					end
				end
			end
		end
		local function v1482()
			return LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors"
		end
		local function v1483(p75)
			local spilled = {
				Humanoid = p75:FindFirstChildOfClass("Humanoid")
			}
			if not spilled.Humanoid then
				return false
			end
			spilled.n136 = 357168439
			spilled.n137 = 536840544
			spilled.Animator = spilled.Humanoid:FindFirstChildOfClass("Animator")
			if not spilled.Animator then
				return false
			end
			do
				for _, v in ipairs(spilled.Animator:GetPlayingAnimationTracks()) do
					if spilled.n137 ~= n3 then
						if v.Animation and string.find(tostring(v.Animation.AnimationId), "126081405469607") then
							return true
						end
						continue
					end
					n5 += 267
					n7 -= 358
					n3 = 971111875
					n6 += 1091
					n4 = 350973052
					spilled.n137 = 648943816
					spilled.n136 -= 146
					n2 = 613948963
					do
						spilled.v1486, spilled.v1487, spilled.v1488 = nil
						local v1489, v1490, v1491, v1492, v1493, v1494, v1495, v1496, v1497, v1498, v1499, v1500, v1501, v1502, v1503, v1504, v1505, v1506, v1507, v1508, v1509, v1510, v1511, v1512, v1513, v1514, v1515, v1516, v1517, v1518, v1519, v1520, v1521, v1522, v1523, v1524, v1525, v1526, v1527, v1528, v1529, v1530, v1531, v1532, v1533, v1534, v1535, v1536, v1537, v1538, v1539, v1540, v1541, v1542, v1543, v1544, v1545, v1546, v1547, v1548, v1549, v1550, v1551, v1552, v1553, v1554, v1555, v1556, v1557, v1558, v1559, v1560, v1561, v1562, v1563, v1564, v1565, v1566, v1567, v1568, v1569, v1570, v1571, v1572, v1573, v1574, v1575, v1576, v1577, v1578, v1579, v1580, v1581, v1582, v1583, v1584, v1585, v1586, v1587, v1588, v1589, v1590, v1591, v1592, v1593, v1594, v1595, v1596, v1597, v1598, v1599, v1600, v1601, v1602, v1603, v1604, v1605, v1606, v1607, v1608, v1609, v1610, v1611, v1612, v1613, v1614, v1615, v1616, v1617, v1618, v1619, v1620, v1621, v1622, v1623, v1624, v1625, v1626, v1627, v1628, v1629, v1630, v1631, v1632, v1633, v1634, v1635, v1636, v1637, v1638, v1639, v1640, v1641, v1642, v1643, v1644, v1645, v1646, v1647, v1648, v1649, v1650, v1651, v1652, v1653, v1654, v1655, v1656, v1657, v1658, v1659, v1660, v1661, v1662, v1663, v1664
					end
				end
			end
			return false
		end
		local function v1862(p76)
			if not _G.Ox.FakePerks.QuickRecoveryEnabled then
				return
			end
			if not v1482() then
				return
			end
			local n138 = 150723693
			if _G.Ox.FakePerks.boostActive then
				return
			end
			if tick() - _G.Ox.FakePerks.lastQRTime < _G.Ox.FakePerks.PerkCooldown then
				return
			end
			local n139 = 11608267
			if n7 == n138 then
				n2 = 502671634
				n5 = 754302583
				n7 = 320031109
				n1 += 316
				n139 -= 1422
				n6 = 1019845953
				n138 -= 1743
				n3 = 900154991
				getfenv()[nil  ] = nil
			else
				_G.Ox.FakePerks.boostActive = true
			end
			_G.Ox.FakePerks.lastQRTime = tick()
			local now = tick()
			task.spawn(function()
				while _G.Ox.FakePerks.QuickRecoveryEnabled do
					if not (tick() - now < 3) then
						break
					end
					if p76 and p76.Parent then
						p76:SetAttribute("speedboost", 1.4)
					end
					task.wait()
				end
				if p76 and p76.Parent then
					p76:SetAttribute("speedboost", 1)
				end
				_G.Ox.FakePerks.boostActive = false
			end)
		end
		local function v1863(p77)
			if _G.Ox.FakePerks.qrConnection then
				_G.Ox.FakePerks.qrConnection:Disconnect()
				_G.Ox.FakePerks.qrConnection = nil
			end
			if p77 then
				_G.Ox.FakePerks.qrConnection = p77:GetAttributeChangedSignal("isvaulting"):Connect(function()
					if p77:GetAttribute("isvaulting") == true then
						task.spawn(function()
							task.wait(0.05)
							local v1864 = v1483(p77)
							if not v1864 then
								task.wait(0.05)
								v1864 = v1483(p77)
							end
							if not (v1864 or p77:GetAttribute("isvaulting") ~= true) then
								v1862(p77)
							end
						end)
					end
				end)
				return
			end
		end
		ToggleQuickRecovery = function(p78)
			_G.Ox.FakePerks.QuickRecoveryEnabled = p78
			if p78 and LocalPlayer.Character then
				v1863(LocalPlayer.Character)
			elseif not p78 and _G.Ox.FakePerks.qrConnection then
				_G.Ox.FakePerks.qrConnection:Disconnect()
				_G.Ox.FakePerks.qrConnection = nil
			end
			lib2:Notify({
				Title = "Fake Quick Recovery",
				Description = p78 and "ON" or "OFF",
				Duration = 2
			})
		end
		local function v1865(p79)
			if not _G.Ox.FakePerks.PerfectLandingEnabled then
				return
			end
			if not v1482() then
				return
			end
			if _G.Ox.FakePerks.perfectLandingBoostActive then
				return
			end
			if tick() - _G.Ox.FakePerks.lastPLTime < _G.Ox.FakePerks.PerkCooldown then
				return
			end
			_G.Ox.FakePerks.perfectLandingBoostActive = true
			_G.Ox.FakePerks.lastPLTime = tick()
			local now = tick()
			task.spawn(function()
				while _G.Ox.FakePerks.perfectLandingBoostActive and tick() - now < 3 do
					if p79 and p79.Parent then
						p79:SetAttribute("speedboost", 1.4)
					end
					task.wait()
				end
				if p79 and p79.Parent then
					p79:SetAttribute("speedboost", 1)
				end
				_G.Ox.FakePerks.perfectLandingBoostActive = false
			end)
		end
		local function v1866(p80)
			if _G.Ox.FakePerks.plConnection then
				_G.Ox.FakePerks.plConnection:Disconnect()
				_G.Ox.FakePerks.plConnection = nil
			end
			if p80 then
				_G.Ox.FakePerks.plConnection = p80:GetAttributeChangedSignal("speedboost"):Connect(function()
					if not v1482() then
						return
					end
					if p80:GetAttribute("speedboost") == 0.625 then
						v1865(p80)
					end
				end)
				return
			end
		end
		TogglePerfectLanding = function(p81)
			_G.Ox.FakePerks.PerfectLandingEnabled = p81
			if not p81 then
				if _G.Ox.FakePerks.plConnection then
					_G.Ox.FakePerks.plConnection:Disconnect()
					_G.Ox.FakePerks.plConnection = nil
				end
				if _G.Ox.FakePerks.perfectLandingBoostActive and LocalPlayer.Character then
					LocalPlayer.Character:SetAttribute("speedboost", 1)
					_G.Ox.FakePerks.perfectLandingBoostActive = false
				end
			elseif LocalPlayer.Character then
				v1866(LocalPlayer.Character)
			end
			lib2:Notify({
				Title = "Fake Perfect Landing",
				Description = p81 and "ON" or "OFF",
				Duration = 2
			})
		end
		local function v1867(p82)
			if not _G.Ox.FakePerks.FlowstateEnabled then
				return
			end
			if not p82 or not p82.Parent then
				return
			end
			if not v1482() then
				return
			end
			if _G.Ox.FakePerks.fsOnCooldown then
				return
			end
			if tick() - _G.Ox.FakePerks.lastFSTime < _G.Ox.FakePerks.PerkCooldown then
				return
			end
			p82:SetAttribute("Flowstate", true)
		end
		local function v1868(p83)
			if _G.Ox.FakePerks.fsConnection then
				_G.Ox.FakePerks.fsConnection:Disconnect()
				_G.Ox.FakePerks.fsConnection = nil
			end
			if _G.Ox.FakePerks.fsAnimConnection then
				_G.Ox.FakePerks.fsAnimConnection:Disconnect()
				_G.Ox.FakePerks.fsAnimConnection = nil
			end
			if not p83 then
				return
			end
			local Humanoid = p83:WaitForChild("Humanoid", 3)
			if not Humanoid then
				return
			end
			local Animator = Humanoid:WaitForChild("Animator", 3)
			if not Animator then
				return
			end
			_G.Ox.FakePerks.fsAnimConnection = Animator.AnimationPlayed:Connect(function(p84)
				if not p84.Animation then
					return
				end
				if p84.Animation.AnimationId ~= "rbxassetid://136962284480779" then
					return
				end
				local connection
				connection = p84.Stopped:Connect(function()
					if connection then
						connection:Disconnect()
					end
					_G.Ox.FakePerks.lastFSTime = tick()
					_G.Ox.FakePerks.fsOnCooldown = true
					if p83 and p83.Parent then
						p83:SetAttribute("Flowstate", false)
					end
					task.delay(_G.Ox.FakePerks.PerkCooldown, function()
						_G.Ox.FakePerks.fsOnCooldown = false
						if _G.Ox.FakePerks.FlowstateEnabled and p83 and p83.Parent then
							p83:SetAttribute("Flowstate", true)
						end
					end)
				end)
			end)
			_G.Ox.FakePerks.fsConnection = p83:GetAttributeChangedSignal("Flowstate"):Connect(function()
				if not _G.Ox.FakePerks.FlowstateEnabled then
					return
				end
				if not v1482() then
					return
				end
				local attribute = p83:GetAttribute("Flowstate")
				if attribute ~= true then
					if attribute == false and not _G.Ox.FakePerks.fsOnCooldown and _G.Ox.FakePerks.PerkCooldown <= tick() - _G.Ox.FakePerks.lastFSTime then
						p83:SetAttribute("Flowstate", true)
					end
				elseif _G.Ox.FakePerks.fsOnCooldown or tick() - _G.Ox.FakePerks.lastFSTime < _G.Ox.FakePerks.PerkCooldown then
					upv126:SetAttribute("Flowstate", false)
				end
			end)
			task.wait(0.5)
			if _G.Ox.FakePerks.FlowstateEnabled and p83.Parent then
				p83:SetAttribute("Flowstate", true)
			end
		end
		ToggleFlowstate = function(p85)
			_G.Ox.FakePerks.FlowstateEnabled = p85
			if not p85 then
				if _G.Ox.FakePerks.fsConnection then
					_G.Ox.FakePerks.fsConnection:Disconnect()
					_G.Ox.FakePerks.fsConnection = nil
				end
				if _G.Ox.FakePerks.fsAnimConnection then
					_G.Ox.FakePerks.fsAnimConnection:Disconnect()
					_G.Ox.FakePerks.fsAnimConnection = nil
				end
				if LocalPlayer.Character then
					LocalPlayer.Character:SetAttribute("Flowstate", false)
				end
			elseif LocalPlayer.Character then
				v1868(LocalPlayer.Character)
			end
			lib2:Notify({
				Title = "Fake Flowstate",
				Description = p85 and "ON" or "OFF",
				Duration = 2
			})
		end
		local function v1869()
			local adrenalineConns = _G.Ox.FakePerks.adrenalineConns
			if not adrenalineConns then
				return
			end
			for _, adrenalineConn in ipairs(adrenalineConns) do
				pcall(function()
					adrenalineConn:Disconnect()
				end)
			end
			_G.Ox.FakePerks.adrenalineConns = {}
		end
		local function v1870(p86)
			if not _G.Ox.FakePerks.FakeAdrenalineRush then
				return
			end
			if not v1482() then
				return
			end
			if not p86 or not p86.Parent then
				return
			end
			if _G.Ox.FakePerks.boostActive then
				return
			end
			if tick() - (_G.Ox.FakePerks.lastARTime or 0) < _G.Ox.FakePerks.PerkCooldown then
				return
			end
			_G.Ox.FakePerks.boostActive = true
			_G.Ox.FakePerks.lastARTime = tick()
			local now = tick()
			local n140 = 754539722
			if n7 < n140 then
				task.spawn(function()
					while _G.Ox.FakePerks.FakeAdrenalineRush and tick() - now < 5 do
						if p86 and p86.Parent then
							p86:SetAttribute("speedboost", 1.4)
						end
						task.wait()
					end
					if p86 and p86.Parent then
						p86:SetAttribute("speedboost", 1)
					end
					_G.Ox.FakePerks.boostActive = false
				end)
				return
			end
			n2 -= 1653
			n3 += 372
			n5 -= 359
			n1 += 822
			n7 = 847888224
			n6 += 679
			return table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 385)
		end
		local n141
		local function v1871(p87)
			n141 = 1066074474
			local n142 = 387972655
			if not p87 then
				return
			end
			local v1872 = p87
			local Humanoid = p87:FindFirstChildOfClass("Humanoid")
			if not Humanoid then
				v1872 = p87
				Humanoid = p87:WaitForChild("Humanoid", 5)
			end
			if not (n6 < n4) then
				n4 += 1295
				n2 = 900137398
				n142 += 378
				n7 = 892771268
				n3 -= 1366
				n141 = 4292112
				n6 = 400658601
				n5 = 77392027
				v1872[nil] = n5
				upv129[nil  ] = nil
				upv48[nil  ] = nil
			elseif not Humanoid then
				return
			end
			local Health = Humanoid.Health
			local n143
			table.insert(_G.Ox.FakePerks.adrenalineConns, Humanoid.HealthChanged:Connect(function(health)
				n143 = 848783472
				if not _G.Ox.FakePerks.FakeAdrenalineRush then
					return
				end
				if health < Health and health <= 50 and health > 0 then
					v1870(p87)
					Health = health
					if n5 == 403424340 then
						n3 = 316969602
						n141 += 1333
						n2 -= 221
						n5 = 519403386
						n4 = 340476383
						n142 = 508263031
						n143 += 645
						return (nil)()
					end
				else
					Health = health
					if n5 == 403424340 then
						n3 = 316969602
						n141 += 1333
						n2 -= 221
						n5 = 519403386
						n4 = 340476383
						n142 = 508263031
						n143 += 645
						return (nil)()
					end
				end
			end))
		end
		SetupFakeAdrenalineRush = function(p88)
			_G.Ox.FakePerks.FakeAdrenalineRush = p88 == true
			_G.Ox.FakePerks.adrenalineOn = p88 == true
			v1869()
			if not p88 then
				lib2:Notify({
					Title = "Fake Perks",
					Description = "Adrenaline Rush OFF",
					Duration = 2
				})
				return
			end
			v1871(LocalPlayer.Character)
			table.insert(_G.Ox.FakePerks.adrenalineConns, LocalPlayer.CharacterAdded:Connect(function(character)
				task.wait(0.3)
				if _G.Ox.FakePerks.FakeAdrenalineRush then
					v1871(character)
				end
			end))
			lib2:Notify({
				Title = "Fake Perks",
				Description = "Adrenaline Rush ON",
				Duration = 3
			})
		end
		local function v1873(character)
			task.wait(0.5)
			if _G.Ox.FakePerks.QuickRecoveryEnabled then
				v1863(character)
			end
			if _G.Ox.FakePerks.PerfectLandingEnabled then
				v1866(character)
			end
			if _G.Ox.FakePerks.FlowstateEnabled then
				v1868(character)
			end
			if n3 == 660936071 then
				n7 = 599747572
				n3 += 1550
				n5 += 687
				n4 = 687246849
				n6 = 830498384
				n1 += 1659
				;(nil)[nil  ] = nil
				;(nil)(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
			elseif _G.Ox.FakePerks.FakeAdrenalineRush then
				v1871(character)
			end
		end
		if LocalPlayer.Character then
			v1873(LocalPlayer.Character)
		end
		LocalPlayer.CharacterAdded:Connect(v1873)
		local function v1874()
			if not _G.Ox.StreamerMode.Enabled then
				return
			end
			local n144 = 17297626
			local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
			if not PlayerGui2 then
				return
			end
			local function v1875(p89)
				local n145 = 500485560
				local n146 = 532872872
				local n147 = 1037558133
				if p89:IsA("TextLabel") or p89:IsA("TextButton") or p89:IsA("TextBox") then
					local function v1876()
						local n148 = 708905382
						if not _G.Ox.StreamerMode.Enabled then
							return
						end
						local Text = p89.Text
						local v1877 = false
						if not p89:GetAttribute("OriginalText") then
							p89:SetAttribute("OriginalText", Text)
						end
						for _, player in ipairs(Players:GetPlayers()) do
							if string.find(Text, player.Name) or string.find(Text, player.DisplayName) then
								Text = string.gsub(Text, player.Name, "TEMPO")
								if n145 == 500485560 then
									Text = string.gsub(Text, player.DisplayName, "TEMPO")
								else
									n5 = 197025543
									n2 = 486695563
									n145 += 1662
									n146 += 1053
									n148 += 132
									n147 += 811
								end
								v1877 = true
							end
						end
						if v1877 and p89.Text ~= Text then
							p89.Text = Text
						end
					end
					v1876()
					local connection = p89:GetPropertyChangedSignal("Text"):Connect(v1876)
					table.insert(_G.Ox.StreamerMode.SpooferConns, connection)
				elseif p89:IsA("ImageLabel") or p89:IsA("ImageButton") then
					local function v1878()
						if not _G.Ox.StreamerMode.Enabled then
							return
						end
						local Image = p89.Image
						local v1879 = false
						for _, player in ipairs(Players:GetPlayers()) do
							if string.find(Image, tostring(player.UserId)) then
								if not p89:GetAttribute("OriginalImage") then
									p89:SetAttribute("OriginalImage", Image)
								end
								v1879 = true
								break
							end
						end
						if v1879 and p89.Image ~= "rbxassetid://118755181202304" then
							p89.Image = "rbxassetid://118755181202304"
						end
					end
					if n7 == n146 then
						n2 = 296308918
						n7 = 551592777
						n146 -= 117
						n144 += 1498
						n3 = 580729500
						n145 = 562768872
						n5 += 1255
						n147 = 457587360
						getfenv()[nil  ] = nil
						return table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil   ^ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 338)
					end
					v1878()
					local connection = p89:GetPropertyChangedSignal("Image"):Connect(v1878)
					table.insert(_G.Ox.StreamerMode.SpooferConns, connection)
				end
			end
			for _, descendant in ipairs(PlayerGui2:GetDescendants()) do
				v1875(descendant)
			end
			local connection = PlayerGui2.DescendantAdded:Connect(function(descendant)
				task.defer(function()
					v1875(descendant)
				end)
			end)
			table.insert(_G.Ox.StreamerMode.SpooferConns, connection)
		end
		local function v1880()
			for _, spooferConn in ipairs(_G.Ox.StreamerMode.SpooferConns) do
				if spooferConn.Connected then
					spooferConn:Disconnect()
				end
			end
			table.clear(_G.Ox.StreamerMode.SpooferConns)
			local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
			if PlayerGui2 then
				for _, descendant in ipairs(PlayerGui2:GetDescendants()) do
					if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
						local attribute = descendant:GetAttribute("OriginalText")
						if attribute then
							descendant.Text = attribute
							descendant:SetAttribute("OriginalText", nil)
						end
					elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
						local attribute = descendant:GetAttribute("OriginalImage")
						if attribute then
							descendant.Image = attribute
							descendant:SetAttribute("OriginalImage", nil)
						end
					end
				end
			end
		end
		v1325 = function(p90)
			_G.Ox.StreamerMode.Enabled = p90
			if p90 then
				v1874()
				lib2:Notify({
					Title = "Streamer Mode",
					Description = "ON - player names hidden",
					Duration = 3
				})
			else
				v1880()
				lib2:Notify({
					Title = "Streamer Mode",
					Description = "OFF",
					Duration = 2
				})
			end
		end
		local n149
		LocalPlayer.CharacterAdded:Connect(function()
			n149 = 222658387
			task.wait(1)
			if _G.Ox.StreamerMode.Enabled then
				if n5 ~= 403422737 then
					n1 -= 1571
					n7 = 610555913
					n4 = 874748689
					n2 += 665
					n5 = 502614462
					n3 = 230923596
					n149 -= 898
					return (nil)()
				end
				v1880()
				v1331()
				task.wait(0.5)
				v1874()
			end
		end)
		PlayerGui.ChildAdded:Connect(function()
			task.wait(0.5)
			if _G.Ox.StreamerMode.Enabled then
				v1874()
			end
		end)
	end
	local function v1881(p91)
		_G.Ox.StretchRes.Enabled = p91
		lib2:Notify({
			Title = "Stretch Res",
			Description = p91 and "ON" or "OFF",
			Duration = 2
		})
	end
	do
		local t14 = {}
		UpdateHookData = function()
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= v18 and player.Team and player.Team.Name == "Survivors" then
					t14[player.Name] = player:GetAttribute("HookCount") or 0
				end
			end
		end
		CreateHookESP = function(p92, p93)
			if not _G.Ox.ESPConfig.HookCount then
				return
			end
			local name = "HookESP_" .. p92.Name
			local v1882 = p92:FindFirstChild(name)
			if v1882 then
				v1882:Destroy()
			end
			local BillboardGui = Instance.new("BillboardGui")
			BillboardGui.Name = name
			BillboardGui.Parent = p92
			BillboardGui.AlwaysOnTop = true
			BillboardGui.Size = UDim2.new(0, 40, 0, 14)
			BillboardGui.StudsOffset = Vector3.new(0, 5.5, 0)
			local TextLabel = Instance.new("TextLabel")
			TextLabel.Size = UDim2.new(1, 0, 1, 0)
			TextLabel.BackgroundTransparency = 1
			TextLabel.Font = Enum.Font.GothamBold
			TextLabel.TextSize = 11
			TextLabel.TextScaled = true
			TextLabel.Text = string.format("Hooked %d", p93)
			TextLabel.TextXAlignment = Enum.TextXAlignment.Center
			TextLabel.TextYAlignment = Enum.TextYAlignment.Center
			TextLabel.Parent = BillboardGui
			if p93 >= 3 then
				TextLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
			elseif p93 >= 2 then
				TextLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
			else
				TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
			local UIStroke = Instance.new("UIStroke")
			UIStroke.Color = Color3.fromRGB(0, 0, 0)
			UIStroke.Thickness = 2
			UIStroke.Transparency = 0.5
			UIStroke.Parent = TextLabel
		end
		local t15 = {
			"rbxassetid://120434965879067",
			"rbxassetid://81511619438196",
			"rbxassetid://130571419892864"
		}
		CreateHookUICounter = function(p94, p95)
			if not p94 then
				return
			end
			local v1883 = tonumber(p95) or 0
			local OXio_HookCounter = p94:FindFirstChild("OXio_HookCounter")
			if v1883 <= 0 then
				if OXio_HookCounter then
					OXio_HookCounter:Destroy()
				end
				return
			end
			local v1884 = t15[math.clamp(v1883, 1, 3)]
			if not v1884 then
				return
			end
			if not OXio_HookCounter then
				OXio_HookCounter = Instance.new("ImageLabel")
				OXio_HookCounter.Name = "OXio_HookCounter"
				OXio_HookCounter.BackgroundTransparency = 1
				OXio_HookCounter.ZIndex = (p94.ZIndex or 1) + 1
				OXio_HookCounter.Parent = p94
			end
			OXio_HookCounter.Size = UDim2.new(0.509, 0, 0.51, 0)
			OXio_HookCounter.Position = UDim2.new(0.91, 0, 0.18, 0)
			OXio_HookCounter.AnchorPoint = Vector2.new(0.5, 0.5)
			OXio_HookCounter.Image = v1884
			OXio_HookCounter.ScaleType = Enum.ScaleType.Fit
		end
		UpdateHookUICounter = function()
			if GetRole() ~= "Killer" then
				ClearHookUICounter()
				return
			end
			local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
			if not PlayerGui2 then
				return
			end
			local n150 = 944985512
			local function v1885(p96)
				if p96 and type(p96) == "string" then
					return tonumber(p96:match("id=(%d+)"))
				end
				return nil
			end
			local v1886 = table.pack(ipairs(PlayerGui2:GetChildren()))
			local v1887 = geniter(v1886[1], v1886[2], v1886[3])
			local Frame
			while true do
				local v1888 = table.pack(v1887())
				if not v1888[1] then
					return
				end
				local v1889 = v1888[3]
				if typeof(v1889) ~= "Instance" then
					continue
				end
				Frame = v1889:FindFirstChild("Frame")
				if Frame and Frame:IsA("Frame") then
					break
				end
			end
			local v1890, v1891, Frame2
			if n5 == 403424009 then
				n4 += 301
				n6 += 1124
				n7 -= 240
				n3 -= 1166
				n5 += 1707
				n150 += 1761
				n1 = 57346929
				if true then
				end
				v1890 = v1886[3]
			else
				local exitTo2
				local ImageLabel, attribute, v1892
				while true do
					local v1893 = table.pack(ipairs(Frame:GetChildren()))
					local v1894 = geniter(v1893[1], v1893[2], v1893[3])
					local exitTo
					while true do
						local v1895 = table.pack(v1894())
						if not v1895[1] then
							exitTo = 1
							break
						end
						local v1896 = v1895[3]
						ImageLabel = v1896:FindFirstChild("ImageLabel")
						if not ImageLabel then
							continue
						end
						attribute = v1896:GetAttribute("UserId") or v1885(ImageLabel.Image)
						if not attribute then
							local OXio_HookCounter = ImageLabel:FindFirstChild("OXio_HookCounter")
							if OXio_HookCounter then
								OXio_HookCounter:Destroy()
							end
							continue
						end
						break
					end
					if exitTo == 1 then
						local exitTo3
						while true do
							local v1897 = table.pack(v1887())
							if not v1897[1] then
								exitTo3 = 1
								break
							end
							local v1898 = v1897[3]
							if typeof(v1898) ~= "Instance" then
								continue
							end
							Frame = v1898:FindFirstChild("Frame")
							if Frame and Frame:IsA("Frame") then
								break
							end
						end
						if exitTo3 == 1 then
							exitTo2 = 1
							break
						end
						if n5 == 403424009 then
							exitTo2 = 2
							break
						end
						continue
					end
					local exitTo5
					repeat
						local v1899 = Players
						local GetPlayerByUserId = Players.GetPlayerByUserId
						local v1900 = table.pack(tonumber(attribute))
						local v1901 = GetPlayerByUserId(v1899, table.unpack(v1900, 1, v1900.n))
						exitTo5 = nil
						while true do
							v1901 = v1901 or nil
							if v1901 and v1901 ~= v18 and v1901.Team and v1901.Team.Name == "Survivors" then
								CreateHookUICounter(ImageLabel, t14[v1901.Name] or v1901:GetAttribute("HookCount") or 0)
							else
								local OXio_HookCounter = ImageLabel:FindFirstChild("OXio_HookCounter")
								if OXio_HookCounter then
									OXio_HookCounter:Destroy()
								end
							end
							local exitTo4
							while true do
								local v1902 = table.pack(v1894())
								if not v1902[1] then
									break
								end
								v1892 = v1902[3]
								ImageLabel = v1892:FindFirstChild("ImageLabel")
								if ImageLabel then
									exitTo4 = 1
									break
								end
							end
							if exitTo4 ~= 1 then
								break
							end
							attribute = v1892:GetAttribute("UserId") or v1885(ImageLabel.Image)
							v1901 = attribute
							if not v1901 then
								continue
							end
							exitTo5 = 1
							break
						end
					until exitTo5 ~= 1
					local exitTo6
					while true do
						local v1903 = table.pack(v1887())
						if not v1903[1] then
							exitTo6 = 1
							break
						end
						local v1904 = v1903[3]
						if typeof(v1904) ~= "Instance" then
							continue
						end
						Frame = v1904:FindFirstChild("Frame")
						if Frame and Frame:IsA("Frame") then
							break
						end
					end
					if exitTo6 == 1 then
						exitTo2 = 1
						break
					elseif n5 ~= 403424009 then
						continue
					end
					break
				end
				if exitTo2 ~= 1 then
					if exitTo2 == 2 then
						n4 += 301
						n6 += 1124
						n7 -= 240
						n3 -= 1166
						n5 += 1707
						n150 += 1761
						n1 = 57346929
						if true then
						end
						v1890 = t30_127_1[3]
					else
						n4 += 301
						n6 += 1124
						n7 -= 240
						n3 -= 1166
						n5 += 1707
						n150 += 1761
						n1 = 57346929
						if true then
						end
						v1890 = t159_193_1[3]
					end
					while true do
						local v1905 = table.pack(v1887())
						if not v1905[1] then
							break
						end
						v1891 = v1905[3]
						if typeof(v1891) == "Instance" then
							Frame2 = v1891:FindFirstChild("Frame")
							if Frame2 and Frame2:IsA("Frame") then
								n4 += 301
								n6 += 1124
								n7 -= 240
								n3 -= 1166
								n5 += 1707
								n150 += 1761
								n1 = 57346929
								v1890 = v1890[3]
							end
						end
					end
				end
				return
			end
			while true do
				local v1906 = table.pack(v1887())
				if not v1906[1] then
					break
				end
				v1891 = v1906[3]
				if typeof(v1891) == "Instance" then
					Frame2 = v1891:FindFirstChild("Frame")
					if Frame2 and Frame2:IsA("Frame") then
						n4 += 301
						n6 += 1124
						n7 -= 240
						n3 -= 1166
						n5 += 1707
						n150 += 1761
						n1 = 57346929
						v1890 = v1890[3]
					end
				end
			end
		end
		ClearHookUICounter = function()
			local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
			if not PlayerGui2 then
				return
			end
			for _, child in ipairs(PlayerGui2:GetChildren()) do
				if typeof(child) == "Instance" then
					local Frame = child:FindFirstChild("Frame")
					if Frame and Frame:IsA("Frame") then
						for _, child2 in ipairs(Frame:GetChildren()) do
							local ImageLabel = child2:FindFirstChild("ImageLabel")
							local OXio_HookCounter = ImageLabel and ImageLabel:FindFirstChild("OXio_HookCounter")
							if OXio_HookCounter then
								OXio_HookCounter:Destroy()
							end
						end
					end
				end
			end
		end
		UpdateHookESP = function()
			if not _G.Ox.ESPConfig.HookCount then
				ClearHookESP()
			end
		end
		ClearHookESP = function()
			for _, player in pairs(Players:GetPlayers()) do
				if player.Character then
					for _, child in pairs(player.Character:GetChildren()) do
						if string.match(child.Name, "^HookESP_") then
							child:Destroy()
						end
					end
				end
			end
		end
		ClearESP = function(p97)
			if p97 == "Player" then
				for _, player in pairs(Players:GetPlayers()) do
					if player.Character then
						if player.Character:FindFirstChild("PEH") then
							player.Character.PEH:Destroy()
						end
						if player.Character:FindFirstChild("PE_Text") then
							player.Character.PE_Text:Destroy()
						end
					end
				end
			elseif p97 == "Killer" then
				for _, player in pairs(Players:GetPlayers()) do
					if player.Character then
						if player.Character:FindFirstChild("KEH") then
							player.Character.KEH:Destroy()
						end
						if player.Character:FindFirstChild("KE_Text") then
							player.Character.KE_Text:Destroy()
						end
					end
				end
			elseif p97 == "Generator" then
				for _, generator in pairs(t5.Generators) do
					if generator.model and generator.model.Parent then
						if generator.model:FindFirstChild("GEH") then
							generator.model.GEH:Destroy()
						end
					end
					if generator.part and generator.part.Parent then
						if generator.part:FindFirstChild("GE_Text") then
							generator.part.GE_Text:Destroy()
						end
					end
				end
			elseif p97 == "Pallet" then
				for _, pallet in pairs(t5.Pallets) do
					if pallet and pallet.Parent and pallet:FindFirstChild("PalletEH") then
						pallet.PalletEH:Destroy()
					end
				end
			elseif p97 == "Hook" then
				for _, hook in pairs(t5.Hooks) do
					if hook and hook.Parent and hook:FindFirstChild("HookEH") then
						hook.HookEH:Destroy()
					end
				end
			elseif p97 == "Window" then
				for _, window in pairs(t5.Windows) do
					if window and window.Parent and window:FindFirstChild("WindowEH") then
						window.WindowEH:Destroy()
					end
				end
			elseif p97 == "Gate" then
				for _, gate in pairs(t5.Gates) do
					if gate and gate.Parent and gate:FindFirstChild("GateEH") then
						gate.GateEH:Destroy()
					end
				end
			elseif p97 == "SCP" then
				for _, scP in pairs(t5.SCPs) do
					if scP and scP.Parent and scP:FindFirstChild("SCPEH") then
						scP.SCPEH:Destroy()
					end
				end
			end
		end
		ClearAllESP = function()
			ClearESP("Player")
			ClearESP("Killer")
			ClearESP("Generator")
			ClearESP("Pallet")
			ClearESP("Hook")
			ClearESP("Gate")
			ClearESP("SCP")
			ClearESP("Window")
			ClearHookESP()
		end
		GetSurvivorStatus = function(p98)
			if not p98 then
				return nil, nil
			end
			if p98:GetAttribute("IsHooked") == true then
				return "HOOKED", _G.Ox.ESPColors.Hooked
			end
			if p98:GetAttribute("Knocked") == true then
				return "DOWN", _G.Ox.ESPColors.Downed
			end
			local Humanoid = p98:FindFirstChildOfClass("Humanoid")
			if Humanoid and Humanoid.Health > 0 and Humanoid.Health < Humanoid.MaxHealth then
				return "INJURED", _G.Ox.ESPColors.Injured
			end
			return nil, nil
		end
		local n151
		buildInfoRich = function(p99, p100, p101, p102, p103)
			n151 = 477666527
			local t16 = {}
			if p99 and p99 ~= "" then
				local s2 = "#FFFFFF"
				if p99 == "INJURED" then
					s2 = "#FF8C00"
				elseif p99 == "DOWN" then
					s2 = "#FF2828"
				elseif p99 == "HOOKED" then
					s2 = "#F0F0FF"
				end
				table.insert(t16, string.format("<font color=\"%s\">%s</font>", s2, p99))
			end
			if p101 then
				table.insert(t16, string.format("<font color=\"#FFFFFF\">%dm</font>", p101))
			end
			local n152 = 654279542
			if not p103 and p102 and p99 ~= "HOOKED" then
				local s3 = "#C8C8C8"
				if p102 >= 3 then
					s3 = "#FF3232"
				elseif p102 >= 2 then
					if n2 < n152 then
						s3 = "#FFC832"
					else
						n6 -= 314
						n3 = 540504048
						n2 -= 1993
						n7 = 683117175
						n5 = 754323995
						n151 += 301
						n4 = 865996376
					end
				end
				table.insert(t16, string.format("<font color=\"%s\">Hooked %d</font>", s3, p102))
			end
			return table.concat(t16, " <font color=\"#888888\">·</font> ")
		end
		local n153
		UpdatePlayerESP = function()
			n153 = 591600916
			if not _G.Ox.ESPConfig.Master then
				return
			end
			local Character = v18.Character
			local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
			local n154 = 659538441
			if _G.Ox.ESPConfig.KillerWarn and HumanoidRootPart and GetRole() == "Survivor" then
				local KillerWarn = HumanoidRootPart:FindFirstChild("KillerWarn")
				local huge = math.huge
				for _, player in pairs(Players:GetPlayers()) do
					if player ~= v18 and player.Team and player.Team.Name == "Killer" and player.Character then
						local HumanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
						if HumanoidRootPart2 then
							local Magnitude = (HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude
							if Magnitude < huge then
								huge = Magnitude
							end
						end
					end
				end
				if huge <= 80 then
					if not KillerWarn then
						KillerWarn = Instance.new("BillboardGui")
						KillerWarn.Name = "KillerWarn"
						KillerWarn.Size = UDim2.new(0, 30, 0, 30)
						KillerWarn.AlwaysOnTop = true
						KillerWarn.StudsOffset = Vector3.new(0, 4, 0)
						KillerWarn.Parent = HumanoidRootPart
						local TextLabel = Instance.new("TextLabel")
						TextLabel.Name = "WarnText"
						TextLabel.Size = UDim2.new(1, 0, 1, 0)
						TextLabel.BackgroundTransparency = 1
						TextLabel.TextScaled = true
						TextLabel.TextStrokeTransparency = 0
						TextLabel.Font = Enum.Font.GothamBlack
						TextLabel.Parent = KillerWarn
					end
					local WarnText = KillerWarn:FindFirstChild("WarnText")
					if WarnText then
						if huge <= 40 then
							WarnText.Text = "!!"
							WarnText.TextColor3 = Color3.fromRGB(255, 0, 0)
						else
							WarnText.Text = "!"
							WarnText.TextColor3 = Color3.fromRGB(255, 255, 0)
						end
					end
				elseif KillerWarn then
					KillerWarn:Destroy()
				end
			else
				local KillerWarn = HumanoidRootPart and HumanoidRootPart:FindFirstChild("KillerWarn")
				if KillerWarn then
					KillerWarn:Destroy()
				end
			end
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= v18 and player.Character then
					local HumanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")
					if HumanoidRootPart2 and _G.Ox.ESPConfig.MaxDistance < (workspace.CurrentCamera.CFrame.Position - HumanoidRootPart2.Position).Magnitude then
						for _, v in ipairs({
							"PE_Text",
							"KE_Text",
							"PEH",
							"KEH"
						}) do
							local v1907 = player.Character:FindFirstChild(v)
							if v1907 then
								v1907:Destroy()
							end
						end
					else
						local v1908 = player.Team and player.Team.Name == "Killer"
						local Killer
						if v1908 then
							Killer = _G.Ox.ESPConfig.Killer
						else
							Killer = _G.Ox.ESPConfig.Player or _G.Ox.ESPConfig.HookCount
						end
						local v1909 = v1908 and "KE_Text" or "PE_Text"
						local name = v1908 and "KEH" or "PEH"
						local Killer2 = v1908 and _G.Ox.ESPColors.Killer or _G.Ox.ESPColors.Player
						local v1910
						local v1911
						if not v1908 and _G.Ox.ESPConfig.Status then
							local v1912, v1913 = GetSurvivorStatus(player.Character)
							if v1912 then
								v1910 = v1912
								v1911 = v1913
							end
						end
						if Killer then
							for _, v in ipairs({
								"PE_Text",
								"KE_Text"
							}) do
								if v ~= v1909 then
									local v1914 = player.Character:FindFirstChild(v)
									if v1914 then
										v1914:Destroy()
									end
								end
							end
							for _, v in ipairs({
								"PEH",
								"KEH"
							}) do
								if v ~= name then
									local v1915 = player.Character:FindFirstChild(v)
									if v1915 then
										v1915:Destroy()
									end
								end
							end
							if v1908 then
								for _, child in ipairs(player.Character:GetChildren()) do
									if string.match(child.Name, "^HookESP_") then
										child:Destroy()
									end
								end
							end
							local HumanoidRootPart3 = player.Character:FindFirstChild("HumanoidRootPart")
							local v1916 = HumanoidRootPart3 and math.floor(GetDistance(HumanoidRootPart3.Position)) or nil
							local Highlight = player.Character:FindFirstChild(name)
							if not Highlight then
								Highlight = Instance.new("Highlight")
								Highlight.Name = name
								Highlight.Parent = player.Character
							end
							Highlight.FillColor = Killer2
							Highlight.OutlineColor = Killer2
							Highlight.FillTransparency = _G.Ox.ESPConfig.Outline and 1 or 0.5
							Highlight.OutlineTransparency = 0
							local Name
							local v1917
							if _G.Ox.ESPConfig.Name then
								Name = player.Name
								if not (n6 < n154) then
									n3 -= 1866
									n154 = 954314326
									n2 -= 1802
									n1 = 330696049
									n5 += 918
									n6 = 471823059
									n7 = 26886283
									n153 -= 479
									upv450[nil  ] = nil
								elseif v1908 then
									local attribute = player:GetAttribute("SelectedKiller")
									if not attribute then
										local SelectedKiller = player:FindFirstChild("SelectedKiller")
										if SelectedKiller then
											pcall(function()
												if n2 ~= n7 then
													attribute = SelectedKiller.Value
													return
												end
												n153 = 138609163
												n154 -= 2041
												n5 -= 1956
												n2 -= 1251
												n7 = 558554191
												return nil, nil, nil, nil, nil
											end)
										end
									end
									if attribute and tostring(attribute) ~= "" then
										Name = tostring(attribute)
									end
								end
								if _G.Ox.ESPConfig.ItemIcon and not v1908 then
									local attribute = player:GetAttribute("EquippedItem")
									if attribute and attribute ~= "" then
										v1917 = getItemIcon(attribute)
									end
								end
							end
							local attribute
							if not v1908 and _G.Ox.ESPConfig.HookCount then
								attribute = t14[player.Name] or player:GetAttribute("HookCount") or 0
							end
							local v1918 = buildInfoRich(v1910, v1911, _G.Ox.ESPConfig.Distance and v1916 or nil, attribute, v1908)
							if Name or v1918 ~= "" then
								CreateModernESP(player.Character, v1909, {
									name = Name or "",
									infoRich = v1918,
									color = Killer2,
									icon = v1917,
									offsetY = 4
								})
							else
								local v1919 = player.Character:FindFirstChild(v1909)
								if v1919 then
									v1919:Destroy()
								end
							end
						else
							local v1920 = player.Character:FindFirstChild(name)
							if v1920 then
								v1920:Destroy()
							end
							local v1921 = player.Character:FindFirstChild(v1909)
							if v1921 then
								v1921:Destroy()
							end
						end
					end
				end
			end
		end
		UpdateSCPESP = function()
			if not _G.Ox.ESPConfig.Master then
				return
			end
			if _G.Ox.ESPConfig.SCP then
				for _, scP in ipairs(t5.SCPs) do
					if scP and scP.Parent then
						local Humanoid = scP:FindFirstChildOfClass("Humanoid")
						local HumanoidRootPart = scP:FindFirstChild("HumanoidRootPart") or scP:FindFirstChild("Torso") or scP.PrimaryPart
						if HumanoidRootPart and _G.Ox.ESPConfig.MaxDistance < (workspace.CurrentCamera.CFrame.Position - HumanoidRootPart.Position).Magnitude then
							local SCPEH = scP:FindFirstChild("SCPEH")
							if SCPEH then
								SCPEH:Destroy()
							end
						elseif Humanoid and HumanoidRootPart and Humanoid.Health > 0 and math.floor(Humanoid.WalkSpeed) == 9 then
							local SCP = _G.Ox.ESPColors.SCP
							local SCPEH = scP:FindFirstChild("SCPEH")
							if not SCPEH then
								SCPEH = Instance.new("Highlight")
								SCPEH.Name = "SCPEH"
								SCPEH.Parent = scP
							end
							SCPEH.FillColor = SCP
							SCPEH.OutlineColor = SCP
							SCPEH.FillTransparency = _G.Ox.ESPConfig.Outline and 1 or 0.5
							SCPEH.OutlineTransparency = 0
						else
							local SCPEH = scP:FindFirstChild("SCPEH")
							if SCPEH then
								SCPEH:Destroy()
							end
						end
					end
				end
			else
				ClearESP("SCP")
			end
		end
		UpdateStaticESP = function()
			if not _G.Ox.ESPConfig.Master then
				return
			end
			if _G.Ox.ESPConfig.Generator then
				for _, generator in pairs(t5.Generators) do
					local model = generator.model
					if model and model.Parent then
						local part = generator.part or model:FindFirstChildWhichIsA("BasePart")
						if part and _G.Ox.ESPConfig.MaxDistance < (workspace.CurrentCamera.CFrame.Position - part.Position).Magnitude then
							local GEH = model:FindFirstChild("GEH")
							if GEH then
								GEH:Destroy()
							end
							local GE_Text = model:FindFirstChild("GE_Text")
							if GE_Text then
								GE_Text:Destroy()
							end
						else
							local v1922 = math.floor(model:GetAttribute("RepairProgress") or 0)
							local v1923 = math.clamp(v1922 / 100, 0, 1)
							local v1924 = _G.Ox.ESPColors.Generator:Lerp(_G.Ox.ESPColors.GeneratorDone, v1923)
							local GEH = model:FindFirstChild("GEH")
							if not GEH then
								GEH = Instance.new("Highlight")
								GEH.Name = "GEH"
								GEH.Parent = model
							end
							GEH.FillColor = v1924
							GEH.OutlineColor = v1924
							GEH.FillTransparency = _G.Ox.ESPConfig.Outline and 1 or 0.5
							GEH.OutlineTransparency = 0
							if _G.Ox.ESPConfig.GeneratorName then
								local s4
								if v1922 >= 100 then
									s4 = "DONE"
								else
									s4 = string.format("%d%%", v1922)
								end
								local Generator = _G.Ox.ESPColors.Generator
								local part2 = generator.part or model
								local v1925
								if part2:IsA("BasePart") then
									v1925 = part2.Size.Y / 2 + 1
								else
									v1925 = model:GetExtentsSize().Y / 2 + 1
								end
								CreateModernESP(part2, "GE_Text", {
									name = "GEN",
									infoRich = string.format("<font color=\"%s\">%s</font>", "#FF8000", s4),
									color = Generator,
									icon = nil,
									offsetY = v1925,
									noSeparator = true,
									noDistScale = true
								})
							else
								local GE_Text = model:FindFirstChild("GE_Text")
								if GE_Text then
									GE_Text:Destroy()
								end
							end
						end
					end
				end
			end
			if _G.Ox.ESPConfig.Pallet then
				for _, pallet in pairs(t5.Pallets) do
					if pallet and pallet.Parent then
						local BasePart = pallet:FindFirstChildWhichIsA("BasePart")
						if BasePart and _G.Ox.ESPConfig.MaxDistance < (workspace.CurrentCamera.CFrame.Position - BasePart.Position).Magnitude then
							local PalletEH = pallet:FindFirstChild("PalletEH")
							if PalletEH then
								PalletEH:Destroy()
							end
						else
							local PalletEH = pallet:FindFirstChild("PalletEH")
							if not PalletEH then
								PalletEH = Instance.new("Highlight")
								PalletEH.Name = "PalletEH"
								PalletEH.Parent = pallet
							end
							PalletEH.Adornee = pallet
							PalletEH.FillColor = _G.Ox.ESPColors.Pallet
							PalletEH.OutlineColor = _G.Ox.ESPColors.Pallet
							PalletEH.FillTransparency = _G.Ox.ESPConfig.Outline and 1 or 0.5
							PalletEH.OutlineTransparency = 0
						end
					end
				end
			end
			if _G.Ox.ESPConfig.Window then
				for _, window in ipairs(t5.Windows) do
					if window and window.Parent then
						local Bottom = window:FindFirstChild("Bottom") or window:FindFirstChildWhichIsA("BasePart")
						if Bottom and _G.Ox.ESPConfig.MaxDistance < (workspace.CurrentCamera.CFrame.Position - Bottom.Position).Magnitude then
							local WindowEH = window:FindFirstChild("WindowEH")
							if WindowEH then
								WindowEH:Destroy()
							end
						elseif Bottom then
							local WindowEH = window:FindFirstChild("WindowEH")
							if not WindowEH then
								WindowEH = Instance.new("BoxHandleAdornment")
								WindowEH.Name = "WindowEH"
								WindowEH.Parent = window
								WindowEH.AlwaysOnTop = true
								WindowEH.ZIndex = 5
							end
							WindowEH.Adornee = Bottom
							WindowEH.Size = Bottom.Size
							WindowEH.Color3 = _G.Ox.ESPColors.Window
							WindowEH.Transparency = _G.Ox.ESPConfig.Outline and 0.8 or 0.4
						end
					end
				end
			end
			if _G.Ox.ESPConfig.Hook then
				for _, hook in ipairs(t5.Hooks) do
					if hook and hook.Parent then
						local HookPoint = hook:FindFirstChild("HookPoint") or hook:FindFirstChildWhichIsA("BasePart")
						if HookPoint and _G.Ox.ESPConfig.MaxDistance < (workspace.CurrentCamera.CFrame.Position - HookPoint.Position).Magnitude then
							local HookEH = hook:FindFirstChild("HookEH")
							if HookEH then
								HookEH:Destroy()
							end
						else
							local HookEH = hook:FindFirstChild("HookEH")
							if not HookEH then
								HookEH = Instance.new("Highlight")
								HookEH.Name = "HookEH"
								HookEH.Parent = hook
							end
							HookEH.FillColor = _G.Ox.ESPColors.Hook
							HookEH.OutlineColor = _G.Ox.ESPColors.Hook
							HookEH.FillTransparency = _G.Ox.ESPConfig.Outline and 1 or 0.5
							HookEH.OutlineTransparency = 0
						end
					end
				end
			end
			if _G.Ox.ESPConfig.Gate then
				for _, gate in ipairs(t5.Gates) do
					if gate and gate.Parent then
						local BasePart = gate:FindFirstChildWhichIsA("BasePart")
						if BasePart and _G.Ox.ESPConfig.MaxDistance < (workspace.CurrentCamera.CFrame.Position - BasePart.Position).Magnitude then
							local GateEH = gate:FindFirstChild("GateEH")
							if GateEH then
								GateEH:Destroy()
							end
						else
							local GateEH = gate:FindFirstChild("GateEH")
							if not GateEH then
								GateEH = Instance.new("Highlight")
								GateEH.Name = "GateEH"
								GateEH.Parent = gate
							end
							GateEH.Adornee = gate
							GateEH.FillColor = _G.Ox.ESPColors.Gate
							GateEH.OutlineColor = _G.Ox.ESPColors.Gate
							GateEH.FillTransparency = _G.Ox.ESPConfig.Outline and 1 or 0.5
							GateEH.OutlineTransparency = 0
						end
					end
				end
			end
		end
		task.spawn(function()
			while _G.Ox.ScriptAlive do
				task.wait(0.1)
				local CurrentCamera = workspace.CurrentCamera
				if CurrentCamera then
					for _, player in ipairs(Players:GetPlayers()) do
						if player ~= LocalPlayer and player.Character then
							local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
							if HumanoidRootPart then
								local Magnitude = (CurrentCamera.CFrame.Position - HumanoidRootPart.Position).Magnitude
								local scale = math.clamp(40 / math.max(Magnitude, 5), 0.8, 1)
								local v1926 = 4 + math.clamp((Magnitude - 40) * 0.05, 0, 6)
								for _, v in ipairs({
									"PE_Text",
									"KE_Text"
								}) do
									local v1927 = player.Character:FindFirstChild(v)
									if v1927 and not v1927:GetAttribute("NoDistScale") then
										local Box = v1927:FindFirstChild("Box")
										local DistScale = Box and Box:FindFirstChild("DistScale")
										if DistScale then
											DistScale.Scale = scale
										end
										v1927.StudsOffset = Vector3.new(0, v1926, 0)
									end
								end
							end
						end
					end
					for _, generator in pairs(t5.Generators) do
						local model = generator.model
						if model and model.Parent then
							local BasePart = model:FindFirstChildWhichIsA("BasePart")
							if BasePart then
								local Magnitude = (CurrentCamera.CFrame.Position - BasePart.Position).Magnitude
								local scale = math.clamp(40 / math.max(Magnitude, 5), 0.8, 1)
								local v1928 = 4 + math.clamp((Magnitude - 40) * 0.05, 0, 6)
								local GE_Text = model:FindFirstChild("GE_Text")
								if GE_Text and not GE_Text:GetAttribute("NoDistScale") then
									local Box = GE_Text:FindFirstChild("Box")
									local DistScale = Box and Box:FindFirstChild("DistScale")
									if DistScale then
										DistScale.Scale = scale
									end
									GE_Text.StudsOffset = Vector3.new(0, v1928, 0)
								end
							end
						end
					end
				end
			end
			if not (n1 > 213194393) then
				n1 = 955314755
				n3 += 272
				n2 += 1173
				n7 -= 589
				n5 += 1257
				n4 += 2020
			end
		end)
		SetupHookDetection = function()
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= v18 then
					player:GetAttributeChangedSignal("HookCount"):Connect(function()
						t14[player.Name] = player:GetAttribute("HookCount") or 0
						if _G.Ox.ESPConfig.HookCount then
							UpdateHookESP()
							UpdateHookUICounter()
						end
					end)
				end
			end
		end
		Players.PlayerAdded:Connect(function(player)
			player:GetAttributeChangedSignal("HookCount"):Connect(function()
				t14[player.Name] = player:GetAttribute("HookCount") or 0
				if _G.Ox.ESPConfig.HookCount then
					UpdateHookESP()
					UpdateHookUICounter()
				end
			end)
		end)
	end
	do
		task.spawn(function()
			task.wait(2)
			SetupHookDetection()
		end)
	end
	local u1929 = false
	task.spawn(function()
		while _G.Ox.ScriptAlive do
			task.wait(1)
			if _G.Ox.ESPConfig.HookCount then
				u1929 = true
				UpdateHookData()
				UpdatePlayerESP()
				UpdateHookUICounter()
			elseif u1929 then
				ClearHookESP()
				ClearHookUICounter()
				UpdatePlayerESP()
				u1929 = false
			end
		end
	end)
	local function v1930(p104)
		_G.Ox.InfinityZoom.Enabled = p104
		if p104 then
			LocalPlayer.CameraMaxZoomDistance = math.huge
			LocalPlayer.CameraMinZoomDistance = 0
			lib2:Notify({
				Title = "Infinity Zoom",
				Description = "ON - unlimited zoom out",
				Duration = 2
			})
		else
			LocalPlayer.CameraMaxZoomDistance = 12
			LocalPlayer.CameraMinZoomDistance = 0.5
			lib2:Notify({
				Title = "Infinity Zoom",
				Description = "OFF",
				Duration = 2
			})
		end
		if n2 == 352573180 then
			n4 += 1720
			n1 -= 449
			n6 += 1779
			n7 += 907
			n2 -= 1336
			n5 -= 1668
			local v1931 = nil * nil
		end
	end
	local function v1932(p105)
		_G.Ox.CameraFOV.Enabled = p105
		if not p105 then
			workspace.CurrentCamera.FieldOfView = 70
		end
		lib2:Notify({
			Title = "Camera FOV",
			Description = p105 and "ON" or "OFF",
			Duration = 2
		})
	end
	local function v1933(p106)
		_G.Ox.CameraFOV.Value = p106
		if _G.Ox.CameraFOV.Enabled then
			workspace.CurrentCamera.FieldOfView = p106
		end
	end
	do
		LocalPlayer.CharacterAdded:Connect(function()
			task.wait(0.5)
			if _G.Ox.CameraFOV.Enabled then
				workspace.CurrentCamera.FieldOfView = _G.Ox.CameraFOV.Value
			end
		end)
	end
	workspace.ChildAdded:Connect(function(child)
		if child.Name == "Map" then
			task.wait(0.5)
			if _G.Ox.CameraFOV.Enabled then
				workspace.CurrentCamera.FieldOfView = _G.Ox.CameraFOV.Value
			end
		end
		if n4 == 77053445 then
			n4 = 265196129
			n5 += 1557
			n7 += 1505
			n3 = 903212734
			n1 = 792691466
			n6 -= 1500
			upv153[nil  ] = nil
		end
	end)
	pcall(function()
		_G.Ox.InstantTPGate.GateClientModule = require(game:GetService("ReplicatedStorage").Modules.Items.GateClient)
	end)
	local v1934
	do
		local function v1935(p107)
			local v1936, v1937, v1938 = getgc(true)
			local v1939 = geniter(v1936, v1937, v1938)
			local v1940 = table.pack(v1939())
			if v1940[1] then
				local v1941 = v1940[3]
				while true do
					if typeof(v1941) == "table" and rawget(v1941, "gateDuration") and rawget(v1941, "gateRemote") then
						rawset(v1941, "gateDuration", p107)
					end
					local v1942 = table.pack(v1939())
					if not v1942[1] then
						break
					end
					v1941 = v1942[3]
				end
			end
		end
		local function v1943()
			if not _G.Ox.InstantTPGate.GateClientModule then
				return
			end
			if not _G.Ox.InstantTPGate.oldGateNew then
				_G.Ox.InstantTPGate.oldGateNew = _G.Ox.InstantTPGate.GateClientModule.new
				_G.Ox.InstantTPGate.GateClientModule.new = function(...)
					local v1944 = _G.Ox.InstantTPGate.oldGateNew(...)
					if _G.Ox.InstantTPGate.Enabled then
						v1944.gateDuration = 0
					end
					return v1944
				end
			end
			if not _G.Ox.InstantTPGate.oldGateCanUse then
				_G.Ox.InstantTPGate.oldGateCanUse = _G.Ox.InstantTPGate.GateClientModule.CanUse
				_G.Ox.InstantTPGate.GateClientModule.CanUse = function(p108)
					if not _G.Ox.InstantTPGate.Enabled then
						return _G.Ox.InstantTPGate.oldGateCanUse(p108)
					end
					if p108.isSilenced or p108.isBuffering then
						return false
					end
					return os.clock() - p108.lastUse >= p108.currentCooldown
				end
			end
		end
		local function v1945()
			if not _G.Ox.InstantTPGate.GateClientModule then
				return
			end
			if _G.Ox.InstantTPGate.oldGateNew then
				_G.Ox.InstantTPGate.GateClientModule.new = _G.Ox.InstantTPGate.oldGateNew
				_G.Ox.InstantTPGate.oldGateNew = nil
			end
			if _G.Ox.InstantTPGate.oldGateCanUse then
				_G.Ox.InstantTPGate.GateClientModule.CanUse = _G.Ox.InstantTPGate.oldGateCanUse
				_G.Ox.InstantTPGate.oldGateCanUse = nil
			end
		end
		v1934 = function(p109)
			_G.Ox.InstantTPGate.Enabled = p109
			if p109 then
				v1935(0)
				v1943()
				lib2:Notify({
					Title = "Instant TP Gate",
					Description = "ON",
					Duration = 2
				})
			else
				v1935(1.5)
				v1945()
				lib2:Notify({
					Title = "Instant TP Gate",
					Description = "OFF",
					Duration = 2
				})
			end
		end
		LocalPlayer.CharacterAdded:Connect(function()
			task.wait(0.5)
			if _G.Ox.InstantTPGate.Enabled then
				v1935(0)
				v1943()
			end
		end)
		workspace.ChildAdded:Connect(function(child)
			if child.Name == "Map" then
				task.wait(0.5)
				if _G.Ox.InstantTPGate.Enabled then
					v1935(0)
					v1943()
				end
			end
		end)
	end
	local n155
	ResetAllTransparency = function()
		local n156 = 1037236148
		local n157 = 308327690
		n155 = 863310492
		local n158 = 335472987
		for _, child in pairs(workspace.CurrentCamera:GetChildren()) do
			if child ~= v18.Character then
				for _, descendant in pairs(child:GetDescendants()) do
					if n156 == 1037237815 then
						n3 = 6100942
						n4 += 998
						n157 -= 473
						n5 = 492480301
						n7 += 1920
						n158 = 943076482
						n1 = 367872664
						n155 = 253167133
						n156 = 515732295
						n2 = 357567009
						;(nil)[nil] = nil
						getfenv()[nil  ] = nil
					elseif descendant:IsA("BasePart") or descendant:IsA("Decal") then
						pcall(function()
							descendant.LocalTransparencyModifier = 0
							descendant.Transparency = 0
							if n3 ~= 246789217 then
								return
							end
							n158 -= 141
							n157 += 1037
							n5 = 628666097
							n155 += 73
							n3 = 713337765
							n156 -= 1033
							return (nil)(nil)
						end)
					end
				end
			end
		end
	end
	SetWorldTransparency = function(p110)
		for _, child in pairs(workspace.CurrentCamera:GetChildren()) do
			if child ~= v18.Character then
				for _, descendant in pairs(child:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						pcall(function()
							descendant.LocalTransparencyModifier = p110
							descendant.Transparency = p110
						end)
					end
				end
			end
		end
	end
	SetCharacterTransparency = function(p111, p112)
		if not p111 then
			return
		end
		for _, child in pairs(p111:GetChildren()) do
			if child.Name == "Hat" then
				for _, descendant in pairs(child:GetDescendants()) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						pcall(function()
							descendant.LocalTransparencyModifier = p112
							descendant.Transparency = p112
						end)
					end
				end
			end
			if child:IsA("BasePart") and t4[child.Name] then
				pcall(function()
					child.LocalTransparencyModifier = p112
					child.Transparency = p112
				end)
			end
			if child:IsA("Tool") or child:IsA("Model") then
				local descendants = child:IsA("BasePart") and { child } or child:GetDescendants()
				for _, descendant in pairs(descendants) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						pcall(function()
							descendant.LocalTransparencyModifier = p112
							descendant.Transparency = p112
						end)
					end
				end
			end
		end
	end
	ResetCharacterTransparency = function(p113)
		if not v18.Character then
			return
		end
		if p113 then
			for _, child in pairs(v18.Character:GetChildren()) do
				if child.Name == "Hat" then
					for _, descendant in pairs(child:GetDescendants()) do
						if descendant:IsA("BasePart") or descendant:IsA("Decal") then
							pcall(function()
								descendant.LocalTransparencyModifier = 1
								descendant.Transparency = 1
							end)
						end
					end
				end
				if child:IsA("BasePart") and t4[child.Name] then
					pcall(function()
						child.LocalTransparencyModifier = 1
						child.Transparency = 1
					end)
				end
				if not child:IsA("Tool") then
					if not child:IsA("Model") then
						continue
					end
				end
				local descendants = child:IsA("BasePart") and { child } or child:GetDescendants()
				for _, descendant in pairs(descendants) do
					if descendant:IsA("BasePart") or descendant:IsA("Decal") then
						pcall(function()
							descendant.LocalTransparencyModifier = 1
							descendant.Transparency = 1
						end)
					end
				end
			end
		else
			SetCharacterTransparency(v18.Character, 0)
		end
	end
	local v1968
	do
		local function v1969()
			pcall(function()
				v18.CameraMode = Enum.CameraMode.Classic
				if _G.Ox.InfinityZoom and _G.Ox.InfinityZoom.Enabled then
					v18.CameraMinZoomDistance = 0
					v18.CameraMaxZoomDistance = math.huge
				else
					v18.CameraMinZoomDistance = 0.5
					v18.CameraMaxZoomDistance = 128
				end
			end)
			ResetAllTransparency()
			if v18.Character then
				ResetCharacterTransparency(false)
			end
		end
		v1968 = function(p114)
			if p114 and (not v18.Team or v18.Team.Name ~= "Killer") then
				lib2:Notify({
					Title = "Access Denied",
					Description = "This feature is killer only!",
					Duration = 3
				})
				t3.Enabled = false
				v531(ThirdPersonToggle, false)
				return
			end
			t3.Enabled = p114
			if not p114 then
				if _G.Ox.State.ThirdPersonConn then
					_G.Ox.State.ThirdPersonConn:Disconnect()
					_G.Ox.State.ThirdPersonConn = nil
				end
				v1969()
				lib2:Notify({
					Title = "Third Person",
					Description = "OFF",
					Duration = 2
				})
				return
			end
			v18.CameraMode = Enum.CameraMode.Classic
			v18.CameraMinZoomDistance = 7
			v18.CameraMaxZoomDistance = 128
			SetWorldTransparency(1)
			if _G.Ox.State.ThirdPersonConn then
				if n4 == 666560889 then
					n3 -= 1092
					n4 = 754318209
					n6 = 719884867
					n7 = 284315496
					n5 = 791349031
					n2 = 163921065
				else
					_G.Ox.State.ThirdPersonConn:Disconnect()
				end
				_G.Ox.State.ThirdPersonConn = nil
			end
			_G.Ox.State.ThirdPersonConn = RunService.RenderStepped:Connect(function()
				if not t3.Enabled then
					return
				end
				if not v18.Team or v18.Team.Name ~= "Killer" then
					t3.Enabled = false
					if _G.Ox.State.ThirdPersonConn then
						_G.Ox.State.ThirdPersonConn:Disconnect()
						_G.Ox.State.ThirdPersonConn = nil
					end
					v1969()
					v531(ThirdPersonToggle, false)
					return
				end
				v18.CameraMode = Enum.CameraMode.Classic
				v18.CameraMinZoomDistance = 7
				v18.CameraMaxZoomDistance = 128
				if v18.Character then
					SetCharacterTransparency(v18.Character, 0)
				end
			end)
			lib2:Notify({
				Title = "Third Person",
				Description = "ON - killer only",
				Duration = 3
			})
		end
		v18:GetPropertyChangedSignal("Team"):Connect(function()
			if (v18.Team and v18.Team.Name) ~= "Killer" then
				if t3.Enabled then
					v1968(false)
					v531(ThirdPersonToggle, false)
				else
					v1969()
				end
			end
		end)
		v18.CharacterAdded:Connect(function()
			task.wait(0.8)
			if t3.Enabled and v18.Team and v18.Team.Name == "Killer" then
				v18.CameraMode = Enum.CameraMode.Classic
				v18.CameraMinZoomDistance = 7
				v18.CameraMaxZoomDistance = 128
			else
				v1969()
			end
		end)
	end
	EnableUnlimitedVault = function()
		if _G.Ox.UnlimitedVaultEnabled then
			return
		end
		_G.Ox.UnlimitedVaultEnabled = true
		if _G.Ox.UnlimitedVaultConn then
			_G.Ox.UnlimitedVaultConn:Disconnect()
			_G.Ox.UnlimitedVaultConn = nil
		end
		for _, v in ipairs(CollectionService:GetTagged("Blocked")) do
			CollectionService:RemoveTag(v, "Blocked")
		end
		_G.Ox.UnlimitedVaultConn = CollectionService:GetInstanceAddedSignal("Blocked"):Connect(function(p115)
			CollectionService:RemoveTag(p115, "Blocked")
		end)
		lib2:Notify({
			Title = "Unlimited Vault",
			Description = "ON",
			Duration = 3
		})
	end
	do
		DisableUnlimitedVault = function()
			_G.Ox.UnlimitedVaultEnabled = false
			if _G.Ox.UnlimitedVaultConn then
				_G.Ox.UnlimitedVaultConn:Disconnect()
				_G.Ox.UnlimitedVaultConn = nil
			end
			lib2:Notify({
				Title = "Unlimited Vault",
				Description = "OFF",
				Duration = 2
			})
		end
	end
	local function v1972(p116)
		if p116 then
			EnableUnlimitedVault()
		else
			DisableUnlimitedVault()
		end
	end
	v18.CharacterAdded:Connect(function()
		task.wait(1)
		if _G.Ox.UnlimitedVaultEnabled then
			for _, v in ipairs(CollectionService:GetTagged("Blocked")) do
				CollectionService:RemoveTag(v, "Blocked")
			end
		end
	end)
	task.spawn(function()
		if not game:IsLoaded() then
			game.Loaded:Wait()
		end
		local v1975
		local n159 = 0
		while not v1975 and n159 < 10 do
			n159 += 1
			local ok, result = pcall(function()
				local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
				if not Modules then
					return nil
				end
				local Survivors = Modules:WaitForChild("Survivors", 5)
				if not Survivors then
					return nil
				end
				local SurvivorAnimationsController = Survivors:WaitForChild("SurvivorAnimationsController", 5)
				if SurvivorAnimationsController then
					return require(SurvivorAnimationsController)
				end
				return nil
			end)
			if ok and result then
				v1975 = result
			else
				task.wait(1)
			end
		end
		if not v1975 then
			return
		end
		local _isFacingStraightEnough = v1975._isFacingStraightEnough
		v1975._isFacingStraightEnough = function(p117, p118, p119, p120)
			if _G.Ox.Config.Surv_PerfectVault then
				p117.characterspeed = 20
				return true, 0
			end
			return _isFacingStraightEnough(p117, p118, p119, p120)
		end
		local _onVaultAnimation = v1975._onVaultAnimation
		v1975._onVaultAnimation = function(p121, p122, p123)
			if _G.Ox.Config.Surv_PerfectVault then
				return _onVaultAnimation(p121, p122, true)
			end
			return _onVaultAnimation(p121, p122, p123)
		end
	end)
	local v1984
	do
		local function v1985(p124)
			if not p124 then
				return
			end
			p124:SetAttribute("Flowstate", true)
			if _G.Ox.FlowstateNoCD.Connection then
				_G.Ox.FlowstateNoCD.Connection:Disconnect()
				_G.Ox.FlowstateNoCD.Connection = nil
			end
			_G.Ox.FlowstateNoCD.Connection = p124:GetAttributeChangedSignal("Flowstate"):Connect(function()
				if not _G.Ox.FlowstateNoCD.Enabled then
					return
				end
				if p124:GetAttribute("Flowstate") == false then
					task.wait(0.05)
					p124:SetAttribute("Flowstate", true)
				end
				if n1 ~= 677870210 then
					n5 = 150136069
					n1 -= 335
					n4 -= 2037
					n3 = 488978726
				end
			end)
		end
		v1984 = function(p125)
			_G.Ox.FlowstateNoCD.Enabled = p125
			if _G.Ox.FlowstateNoCD.Connection then
				_G.Ox.FlowstateNoCD.Connection:Disconnect()
				_G.Ox.FlowstateNoCD.Connection = nil
			end
			if _G.Ox.FlowstateNoCD.CharAddedConn then
				_G.Ox.FlowstateNoCD.CharAddedConn:Disconnect()
				_G.Ox.FlowstateNoCD.CharAddedConn = nil
			end
			if not p125 then
				local Character = LocalPlayer.Character
				if Character then
					Character:SetAttribute("Flowstate", false)
				end
				lib2:Notify({
					Title = "Flowstate No CD",
					Description = "OFF",
					Duration = 2
				})
				return
			end
			v1985(LocalPlayer.Character)
			_G.Ox.FlowstateNoCD.CharAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
				if not _G.Ox.FlowstateNoCD.Enabled then
					return
				end
				task.wait(1)
				v1985(character)
			end)
			lib2:Notify({
				Title = "Flowstate No CD",
				Description = "ON",
				Duration = 2
			})
		end
	end
	local function v1987(p126)
		_G.Ox.NoFall.Enabled = p126
		local v1988 = lib2
		local Notify = lib2.Notify
		local t17 = {
			Title = "No Fall Damage"
		}
		local description = p126 and "ON"
		t17.Description = description or "OFF"
		t17.Duration = 2
		Notify(v1988, t17)
	end
	local v1992
	do
		local function v1993()
			local t18 = {}
			local Map = workspace:FindFirstChild("Map")
			if not Map then
				return t18
			end
			for _, descendant in pairs(Map:GetDescendants()) do
				if descendant.Name == "Gate" then
					table.insert(t18, descendant)
				end
			end
			if n6 ~= 295005979 then
				return t18
			end
			n7 += 182
			n5 = 476683970
			n3 += 277
			n6 = 105187798
			n4 = 956139353
			n1 = 987253152
			upv159[nil  ] = nil
		end
		local n160
		v1992 = function(p127)
			n160 = 424654591
			_G.Ox.BypassGate.Enabled = p127
			local v1999 = v1993()
			for _, v in pairs(v1999) do
				local LeftGate = v:FindFirstChild("LeftGate")
				local RightGate = v:FindFirstChild("RightGate")
				local LeftGateEnd = v:FindFirstChild("LeftGate-end") or v:FindFirstChild("LeftGate-end2")
				local RightGateEnd = v:FindFirstChild("RightGate-end") or v:FindFirstChild("RightGate-end2")
				local Box = v:FindFirstChild("Box")
				if p127 then
					if LeftGate then
						LeftGate.Transparency = 1
						LeftGate.CanCollide = false
					end
					if RightGate then
						RightGate.Transparency = 1
						RightGate.CanCollide = false
					end
					if LeftGateEnd then
						LeftGateEnd.Transparency = 0
					end
					if RightGateEnd then
						RightGateEnd.Transparency = 0
					end
					if Box then
						Box.CanCollide = false
					end
				else
					if LeftGate then
						LeftGate.Transparency = 0
						LeftGate.CanCollide = true
					end
					if RightGate then
						RightGate.Transparency = 0
						RightGate.CanCollide = true
					end
					if LeftGateEnd then
						LeftGateEnd.Transparency = 1
					end
					if RightGateEnd then
						RightGateEnd.Transparency = 1
					end
					if Box then
						Box.CanCollide = true
					end
				end
			end
			if n4 == 666562490 then
				n3 = 925721627
				n7 += 1718
				n2 = 681488569
				n6 = 848170561
				n5 = 705440345
				n4 = 463615834
				n160 -= 1043
			else
				lib2:Notify({
					Title = "Bypass Gate",
					Description = p127 and "ON" or "OFF",
					Duration = 2
				})
			end
		end
	end
	workspace.ChildAdded:Connect(function(child)
		if child.Name == "Map" then
			task.wait(1)
			if _G.Ox.BypassGate.Enabled then
				v1992(true)
			end
		end
	end)
	local v2007
	do
		local connection
		local function v2009()
			if connection then
				return
			end
			local Character = LocalPlayer.Character
			if not Character then
				return
			end
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if not Humanoid then
				return
			end
			local Animator = Humanoid:FindFirstChildOfClass("Animator")
			if Animator then
				connection = Animator.AnimationPlayed:Connect(function(p128)
					if p128.Animation then
						if p128.Animation.AnimationId:find("95836365038528") then
							p128:Stop(0)
						end
					end
				end)
				return
			end
			if n2 == 352572318 then
				return
			end
			n1 = 772460970
			n5 += 123
			n2 = 549755430
			n3 = 399507170
			n6 = 994961897
			n7 -= 1530
		end
		local function v2013()
			if n7 == n5 then
				n5 -= 1344
				n4 = 434035513
				n2 = 776213281
				n3 -= 1901
				n7 -= 1053
				n6 -= 1765
				;(nil)()
				upv49[nil  ] = nil
			elseif connection then
				pcall(function()
					connection:Disconnect()
				end)
				connection = nil
			end
		end
		task.spawn(function()
			while _G.Ox.ScriptAlive do
				task.wait(3)
				if not _G.Ox.ScriptAlive then
					break
				end
				if _G.Ox.SelfHeal.Enabled and LocalPlayer.Team and LocalPlayer.Team.Name ~= "Killer" then
					local Character = LocalPlayer.Character
					if Character then
						local CheckInterractable = Character:FindFirstChild("CheckInterractable")
						local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
						local Humanoid = Character:FindFirstChildOfClass("Humanoid")
						local v2018 = false
						if CheckInterractable and (CheckInterractable:GetAttribute("isVaulting") or CheckInterractable:GetAttribute("isRepairing") or CheckInterractable:GetAttribute("isUnhooking") or CheckInterractable:GetAttribute("isHealing") or CheckInterractable:GetAttribute("isSliding")) then
							v2018 = true
						end
						if not v2018 and HumanoidRootPart and Humanoid and Humanoid.Health < Humanoid.MaxHealth then
							pcall(function()
								local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
								if Remotes and Remotes:FindFirstChild("Healing") then
									Remotes.Healing.HealEvent:FireServer(HumanoidRootPart, true)
								end
							end)
						end
					end
				end
			end
		end)
		LocalPlayer.CharacterRemoving:Connect(function()
			v2013()
		end)
		LocalPlayer.CharacterAdded:Connect(function()
			task.wait(5)
			if _G.Ox.SelfHeal.Enabled then
				v2009()
			end
		end)
		v2007 = function(p129)
			_G.Ox.SelfHeal.Enabled = p129
			if p129 then
				if LocalPlayer.Team and LocalPlayer.Team.Name == "Killer" then
					lib2:Notify({
						Title = "Self Heal",
						Description = "You have to be a survivor!",
						Duration = 3
					})
					_G.Ox.SelfHeal.Enabled = false
					if SelfHealToggle then
						v531(SelfHealToggle, false)
					end
					return
				end
				v2009()
				lib2:Notify({
					Title = "Self Heal",
					Description = "ON (no animation)",
					Duration = 2
				})
			else
				v2013()
				lib2:Notify({
					Title = "Self Heal",
					Description = "OFF",
					Duration = 2
				})
			end
		end
	end
	local v2020
	do
		local n161
		v2020 = function()
			n161 = 251071434
			local v2022 = LocalPlayer
			local function v2023()
				while true do
					task.wait()
					if not v2022.Character then
						continue
					end
					if not v2022.Character:FindFirstChild("HumanoidRootPart") then
						continue
					end
					if v2022.Character:FindFirstChild("Right Leg") then
						break
					end
				end
				task.wait(0.1)
				local Character = v2022.Character
				pcall(function()
					Character.Head.Transparency = 1
					local face = Character.Head:FindFirstChild("face")
					if face then
						face:Destroy()
					end
					Character["Right Leg"].Transparency = 1
					local MeshPart = Instance.new("MeshPart")
					MeshPart.Name = "KorlessHead"
					MeshPart.Size = Vector3.new(0.85, 0.85, 0.85)
					MeshPart.CanCollide = false
					MeshPart.MeshId = "rbxassetid://902942096"
					MeshPart.TextureID = "rbxassetid://902843398"
					MeshPart.CFrame = Character["Right Leg"].CFrame * CFrame.new(0, 0.7, 0)
					MeshPart.Parent = Character
					local WeldConstraint = Instance.new("WeldConstraint")
					WeldConstraint.Part0 = Character["Right Leg"]
					WeldConstraint.Part1 = MeshPart
					WeldConstraint.Parent = MeshPart
				end)
			end
			v2023()
			if _G.Ox.KorlessMorph.Connection then
				_G.Ox.KorlessMorph.Connection:Disconnect()
			end
			_G.Ox.KorlessMorph.Connection = v2022.CharacterAdded:Connect(function()
				task.wait(1)
				v2023()
				if n5 ~= 403424036 then
					return
				end
				n3 -= 1761
				n7 -= 1630
				n6 = 737848311
				n161 -= 1910
				n5 = 273055850
				return nil
			end)
		end
	end
	local function v2028()
		local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart then
			return
		end
		local v2030
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if string.lower(descendant.Name) == "fininshline" and descendant:IsA("BasePart") then
				v2030 = descendant
				break
			end
		end
		if not v2030 then
			lib2:Notify({
				Title = "Instan Escape",
				Description = "Finish line not found!",
				Duration = 2
			})
			return
		end
		HumanoidRootPart.CFrame = v2030.CFrame + Vector3.new(0, 5, 0)
		lib2:Notify({
			Title = "Instan Escape",
			Description = "Done!",
			Duration = 2
		})
	end
	local n162
	SetupNextKillerIndicator = function()
		n162 = 383295365
		if _G.Ox.NextKiller.IndicatorGui then
			_G.Ox.NextKiller.IndicatorGui:Destroy()
		end
		_G.Ox.NextKiller.IndicatorGui = Instance.new("ScreenGui")
		_G.Ox.NextKiller.IndicatorGui.Name = "NextKillerIndicator"
		_G.Ox.NextKiller.IndicatorGui.ResetOnSpawn = false
		_G.Ox.NextKiller.IndicatorGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	do
		StartNextKiller = function()
			local n163 = 799280311
			if _G.Ox.NextKiller.IndicatorGui then
				return
			end
			local n164 = 19577429
			SetupNextKillerIndicator()
			task.spawn(function()
				local n165 = 402614453
				if _G.Ox.NextKiller.Enabled and _G.Ox.NextKiller.IndicatorGui then
					local IndicatorGui = _G.Ox.NextKiller.IndicatorGui
					local v2038 = IndicatorGui
					local FindFirstChild = IndicatorGui.FindFirstChild
					local v2040 = FindFirstChild
					local nextKillerDisplay = FindFirstChild(v2038, "NextKillerDisplay")
					local UICorner, UIStroke
					if not nextKillerDisplay then
						nextKillerDisplay = Instance.new("TextLabel")
						nextKillerDisplay.Name = "NextKillerDisplay"
						nextKillerDisplay.Size = UDim2.new(0, 150, 0, 22)
						nextKillerDisplay.Position = UDim2.new(0.5, 0, 0, 10)
						nextKillerDisplay.AnchorPoint = Vector2.new(0.5, 0)
						nextKillerDisplay.BackgroundTransparency = 0.15
						nextKillerDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
						if n163 == n7 then
							n164 -= 986
							n5 = 63393746
							n1 = 1046509344
							n7 = 362449082
							n165 += 366
							n3 = 159895905
							n163 -= 2048
							v2040[nil] = n163
							nextKillerDisplay.Font = Enum.Font.GothamMedium
							nextKillerDisplay.TextSize = 11
							nextKillerDisplay.RichText = true
							nextKillerDisplay.Parent = _G.Ox.NextKiller.IndicatorGui
							UICorner = Instance.new("UICorner")
							UICorner.CornerRadius = UDim.new(0, 6)
							UICorner.Parent = nextKillerDisplay
							UIStroke = Instance.new("UIStroke")
							UIStroke.Thickness = 1
							UIStroke.Color = Color3.fromRGB(60, 60, 70)
							UIStroke.Transparency = 0.3
							UIStroke.Parent = nextKillerDisplay
						else
							nextKillerDisplay.TextColor3 = Color3.fromRGB(220, 220, 230)
							nextKillerDisplay.Font = Enum.Font.GothamMedium
							nextKillerDisplay.TextSize = 11
							nextKillerDisplay.RichText = true
							nextKillerDisplay.Parent = _G.Ox.NextKiller.IndicatorGui
							UICorner = Instance.new("UICorner")
							UICorner.CornerRadius = UDim.new(0, 6)
							UICorner.Parent = nextKillerDisplay
							UIStroke = Instance.new("UIStroke")
							UIStroke.Thickness = 1
							UIStroke.Color = Color3.fromRGB(60, 60, 70)
							UIStroke.Transparency = 0.3
							UIStroke.Parent = nextKillerDisplay
						end
					end
					while true do
						local players = Players:GetPlayers()
						table.sort(players, function(p130, p131)
							local attribute = p130:GetAttribute("AllowKiller") or false
							if attribute == (p131:GetAttribute("AllowKiller") or false) then
								return (p130:GetAttribute("KillerChance") or 0) > (p131:GetAttribute("KillerChance") or 0)
							end
							return attribute
						end)
						local v2046 = players[1]
						if not v2046 then
							nextKillerDisplay.Text = "Next Killer: <font color='#888888'>Waiting...</font>"
							task.wait(1.5)
							if not _G.Ox.NextKiller.Enabled or not _G.Ox.NextKiller.IndicatorGui then
								break
							end
							local IndicatorGui2 = _G.Ox.NextKiller.IndicatorGui
							local v2048 = IndicatorGui2
							local FindFirstChild2 = IndicatorGui2.FindFirstChild
							local v2050 = FindFirstChild2
							nextKillerDisplay = FindFirstChild2(v2048, "NextKillerDisplay")
							if not nextKillerDisplay then
								nextKillerDisplay = Instance.new("TextLabel")
								nextKillerDisplay.Name = "NextKillerDisplay"
								nextKillerDisplay.Size = UDim2.new(0, 150, 0, 22)
								nextKillerDisplay.Position = UDim2.new(0.5, 0, 0, 10)
								nextKillerDisplay.AnchorPoint = Vector2.new(0.5, 0)
								nextKillerDisplay.BackgroundTransparency = 0.15
								nextKillerDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
								if n163 == n7 then
									n164 -= 986
									n5 = 63393746
									n1 = 1046509344
									n7 = 362449082
									n165 += 366
									n3 = 159895905
									n163 -= 2048
									v2050[8] = n163
								else
									nextKillerDisplay.TextColor3 = Color3.fromRGB(220, 220, 230)
								end
								nextKillerDisplay.Font = Enum.Font.GothamMedium
								nextKillerDisplay.TextSize = 11
								nextKillerDisplay.RichText = true
								nextKillerDisplay.Parent = _G.Ox.NextKiller.IndicatorGui
								UICorner = Instance.new("UICorner")
								UICorner.CornerRadius = UDim.new(0, 6)
								UICorner.Parent = nextKillerDisplay
								UIStroke = Instance.new("UIStroke")
								UIStroke.Thickness = 1
								UIStroke.Color = Color3.fromRGB(60, 60, 70)
								UIStroke.Transparency = 0.3
								UIStroke.Parent = nextKillerDisplay
							end
							continue
						end
						local v2051 = v2046 == LocalPlayer
						local v2052 = v2046 == v2051
						nextKillerDisplay.Text = "Next Killer: " .. (v2051 and "<font color='#ff5555'>YOU</font>" or v2046.Name)
						task.wait(1.5)
						if not _G.Ox.NextKiller.Enabled or not _G.Ox.NextKiller.IndicatorGui then
							break
						end
						local IndicatorGui2 = _G.Ox.NextKiller.IndicatorGui
						local v2054 = IndicatorGui2
						local FindFirstChild2 = IndicatorGui2.FindFirstChild
						local v2056 = FindFirstChild2
						nextKillerDisplay = FindFirstChild2(v2054, "NextKillerDisplay")
						if nextKillerDisplay then
							continue
						end
						nextKillerDisplay = Instance.new("TextLabel")
						nextKillerDisplay.Name = "NextKillerDisplay"
						nextKillerDisplay.Size = UDim2.new(0, 150, 0, 22)
						nextKillerDisplay.Position = UDim2.new(0.5, 0, 0, 10)
						nextKillerDisplay.AnchorPoint = Vector2.new(0.5, 0)
						nextKillerDisplay.BackgroundTransparency = 0.15
						nextKillerDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
						if n163 ~= n7 then
							nextKillerDisplay.TextColor3 = Color3.fromRGB(220, 220, 230)
							nextKillerDisplay.Font = Enum.Font.GothamMedium
							nextKillerDisplay.TextSize = 11
							nextKillerDisplay.RichText = true
							nextKillerDisplay.Parent = _G.Ox.NextKiller.IndicatorGui
							UICorner = Instance.new("UICorner")
							UICorner.CornerRadius = UDim.new(0, 6)
							UICorner.Parent = nextKillerDisplay
							UIStroke = Instance.new("UIStroke")
							UIStroke.Thickness = 1
							UIStroke.Color = Color3.fromRGB(60, 60, 70)
							UIStroke.Transparency = 0.3
							UIStroke.Parent = nextKillerDisplay
							continue
						end
						n164 -= 986
						n5 = 63393746
						n1 = 1046509344
						n7 = 362449082
						n165 += 366
						n3 = 159895905
						n163 -= 2048
						v2056[v2052] = n163
						nextKillerDisplay.Font = Enum.Font.GothamMedium
						nextKillerDisplay.TextSize = 11
						nextKillerDisplay.RichText = true
						nextKillerDisplay.Parent = _G.Ox.NextKiller.IndicatorGui
						UICorner = Instance.new("UICorner")
						UICorner.CornerRadius = UDim.new(0, 6)
						UICorner.Parent = nextKillerDisplay
						UIStroke = Instance.new("UIStroke")
						UIStroke.Thickness = 1
						UIStroke.Color = Color3.fromRGB(60, 60, 70)
						UIStroke.Transparency = 0.3
						UIStroke.Parent = nextKillerDisplay
					end
				end
			end)
		end
	end
	StopNextKiller = function()
		if _G.Ox.NextKiller.IndicatorGui then
			_G.Ox.NextKiller.IndicatorGui:Destroy()
			_G.Ox.NextKiller.IndicatorGui = nil
		end
	end
	local function v2057(p132)
		_G.Ox.NextKiller.Enabled = p132
		if p132 then
			StartNextKiller()
			lib2:Notify({
				Title = "Next Killer Display",
				Description = "ON - shows the next killer prediction",
				Duration = 3
			})
		else
			StopNextKiller()
			lib2:Notify({
				Title = "Next Killer Display",
				Description = "OFF",
				Duration = 2
			})
		end
	end
	local v2058
	do
		local n166
		local function v2060()
			n166 = 784257363
			local n167 = 459932231
			local MapPredictUI = CoreGui:FindFirstChild("MapPredictUI")
			if MapPredictUI then
				if n167 == n5 then
					n2 = 992008110
					n6 = 858239811
					n4 = 720625863
					n7 += 1771
					n3 -= 254
					n166 -= 784
					n5 -= 415
					;(nil)()
				else
					MapPredictUI:Destroy()
				end
			end
		end
		local function createScreenGui()
			local MapPredictUI = CoreGui:FindFirstChild("MapPredictUI")
			if MapPredictUI then
				return MapPredictUI
			end
			local ScreenGui = Instance.new("ScreenGui")
			ScreenGui.Name = "MapPredictUI"
			ScreenGui.ResetOnSpawn = false
			ScreenGui.IgnoreGuiInset = true
			ScreenGui.Parent = CoreGui
			local TextLabel = Instance.new("TextLabel")
			TextLabel.Name = "NextMapDisplay"
			TextLabel.Size = UDim2.new(0, 220, 0, 22)
			TextLabel.Position = UDim2.new(0.5, 0, 0, 36)
			TextLabel.AnchorPoint = Vector2.new(0.5, 0)
			TextLabel.BackgroundTransparency = 0.15
			TextLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
			TextLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
			TextLabel.Font = Enum.Font.GothamMedium
			TextLabel.TextSize = 11
			TextLabel.RichText = true
			TextLabel.Text = "Next Map: <font color='#888888'>Waiting...</font>"
			TextLabel.Parent = ScreenGui
			local UICorner = Instance.new("UICorner")
			UICorner.CornerRadius = UDim.new(0, 6)
			UICorner.Parent = TextLabel
			local UIStroke = Instance.new("UIStroke")
			UIStroke.Thickness = 1
			UIStroke.Color = Color3.fromRGB(60, 60, 70)
			if n7 > 248694788 then
				UIStroke.Transparency = 0.3
			else
				n2 += 1329
				n5 = 776939920
				n1 = 620891940
				n6 -= 972
				n7 = 2536294
				n3 += 1012
				;(nil)[75] = nil
				;(nil)[76] = nil
				;(nil)[77] = nil
				;(nil)[78] = nil
				;(nil)[79] = nil
				;(nil)[80] = nil
				;(nil)[81] = nil
				;(nil)[82] = nil
				;(nil)[83] = nil
				;(nil)[84] = nil
			end
			UIStroke.Parent = TextLabel
			return ScreenGui
		end
		local function v2069()
			local Map = workspace:FindFirstChild("Map")
			if not Map then
				return nil
			end
			if Map:FindFirstChild("random shakes") or Map:FindFirstChild("SCP-173 Room") or Map:FindFirstChild("SCP-205 Room") then
				return "Site 68"
			end
			if Map:FindFirstChild("HooksMeat") then
				return "BLOODBATH! Club"
			end
			if Map:FindFirstChild("Gate") then
				if Map.Gate:FindFirstChild("vfx") then
					return "Firelink Shrine"
				end
			end
			if Map:FindFirstChild("Bldg_Addon_RooftopUnit_A") or Map:FindFirstChild("Rooftop") then
				return "Mercy Hospital Rooftop"
			end
			if Map:FindFirstChild("White Armored Car") then
				return "Mount Massive Asylum"
			end
			if Map:FindFirstChild("Dumbster") then
				return "The Bay Harbor"
			end
			if Map:FindFirstChild("water pump") then
				return "Valdelobos Village"
			end
			if Map:FindFirstChild("LargeBoulder01") then
				return "Woodview Cabin"
			end
			return nil
		end
		v2058 = function(p133)
			_G.Ox.MapPredict.Enabled = p133
			local n168 = 894600155
			local n169 = 393596400
			local n170
			if p133 then
				task.spawn(function(p134, p135, p136, p137, p138, p139, p140, p141, p142, p143, p144)
					local n171 = 369254227
					n170 = 51671651
					local n172 = 637303899
					local v2076
					local v2077 = false
					local n173
					local n174
					while _G.Ox.MapPredict.Enabled do
						local v2080 = createScreenGui()
						local NextMapDisplay = v2080:FindFirstChild("NextMapDisplay")
						local enabled = false
						pcall(function()
							n173 = 436248879
							n174 = 886267817
							enabled = LocalPlayer.Team and LocalPlayer.Team.Name == "Spectator"
						end)
						v2080.Enabled = enabled
						if enabled and NextMapDisplay then
							local v2083 = workspace:FindFirstChild("Map") ~= nil
							local nextMap = v2069()
							if v2077 and not v2083 then
								NextMapDisplay.Text = "Next Map: " .. (v2076 or "Unknown")
							elseif v2083 and nextMap then
								v2076 = nextMap
								if n5 == n171 then
									n170 -= 493
									n171 += 1630
									n4 = 815359113
									n168 += 64
									n172 = 737804206
									n7 = 716239647
									n169 += 1147
									n5 -= 588
									n171 = p134
									n172 = p135
									v2076 = p136
									n173 = p138
									n174 = p139
									enabled = p142
									v2083 = p144
								else
									NextMapDisplay.Text = "Next Map: " .. nextMap
								end
							elseif not v2083 or nextMap then
								NextMapDisplay.Text = "Next Map: <font color='#888888'>Waiting...</font>"
							else
								NextMapDisplay.Text = "Next Map: Unknown"
							end
							v2077 = v2083
						end
						task.wait(0.5)
					end
					v2060()
				end)
				lib2:Notify({
					Title = "Next Map Prediction",
					Description = "ON - shows the next map prediction",
					Duration = 3
				})
			else
				v2060()
				if n3 == n2 then
					n7 -= 1585
					n1 = 280260501
					n5 -= 1927
					n2 = 575511798
					n3 -= 1046
					n4 += 1081
					;(nil)(nil, nil)
					getfenv()[nil  ] = nil
					return (nil)()
				end
				lib2:Notify({
					Title = "Next Map Prediction",
					Description = "OFF",
					Duration = 2
				})
			end
		end
	end
	local v2085
	do
		local function v2086(p145)
			return (tostring(p145 or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
		end
		local function v2087(p146)
			local match, v2089 = tostring(p146 or ""):match("^(.+)%s+(%d+)$")
			if not match then
				return nil
			end
			local v2090 = match:gsub("^%s+", ""):gsub("%s+$", "")
			if v2090 == "" then
				return nil
			end
			local v2091 = v2090
			if ({
				head = true,
				torso = true,
				humanoid = true,
				humanoidrootpart = true,
				["left arm"] = true,
				["right arm"] = true,
				["left leg"] = true,
				["right leg"] = true
			})[v2090:lower()] then
				return nil
			end
			if n7 ~= n6 then
				return v2090, v2089
			end
			n6 -= 1376
			n3 = 413453057
			n1 = 404422331
			n5 += 1899
			n7 = 588893495
			n2 = 284285149
			v2091[3] = n2
			;(nil)(nil)
			upv439 = nil
		end
		local function v2092()
			for _, player in ipairs(Players:GetPlayers()) do
				local Name = player.Team and player.Team.Name
				if not Name then
					continue
				end
				if Name:lower():find("killer") then
					return player
				end
			end
			return nil
		end
		local function v2096(p147)
			if not p147 then
				return {}
			end
			local Character = p147.Character or workspace:FindFirstChild(p147.Name) or workspace:FindFirstChild(p147.DisplayName)
			if not Character then
				return {}
			end
			local t19 = {}
			local t20 = {}
			for _, child in ipairs(Character:GetChildren()) do
				local v2102, v2103 = v2087(child.Name)
				if v2102 and not t20[v2102] then
					t20[v2102] = true
					table.insert(t19, {
						Name = v2102,
						Level = v2103
					})
				end
			end
			table.sort(t19, function(p148, p149)
				return tostring(p148.Name) < tostring(p149.Name)
			end)
			return t19
		end
		local n175
		local function v2105()
			n175 = 549380919
			local v2106 = v2092()
			local DisplayName = v2106 and (v2106.DisplayName or v2106.Name) or "Unknown"
			local v2108 = v2096(v2106)
			local P_0_, N_0_, Q_0_
			if #v2108 == 0 then
				local v2112, v2113, v2114 = ipairs(Players:GetPlayers())
				for _, v in v2112, v2113, v2114 do
					local v2117 = v2096(v)
					if #v2117 > 0 then
						DisplayName = v.DisplayName or v.Name
						v2108 = v2117
						break
					end
				end
				P_0_ = P_0
				N_0_ = N_0
				Q_0_ = Q_0
			end
			local t21 = { "Killer Perks [<font color=\"rgb(255,80,80)\">" .. v2086(DisplayName) .. "</font>]" }
			if #v2108 == 0 then
				table.insert(t21, "<font color=\"rgb(200,200,200)\">- Waiting for perk data...</font>")
			else
				local n176 = 1
				local v2120 = math.min(#v2108, 4)
				local v2121, v2122, v2123
				if false then
					if n176 >= v2120 then
						local v2124 = n176
						v2121 = v2108[v2124]
						if v2121.Level then
							v2122 = " lvl " .. tostring(v2121.Level) or ""
						else
							v2122 = ""
							if n7 == 542747526 then
								n2 = 227501077
								n175 -= 1708
								n7 -= 1737
								n4 += 1444
								n3 -= 980
								n5 = 315123293
								n6 -= 163
								n6()
							end
						end
						while true do
							table.insert(t21, "<font color=\"rgb(200,200,200)\">- " .. v2086(v2121.Name .. v2122) .. "</font>")
							P_0_ += Q_0_
							if Q_0_ <= 0 then
								if not (P_0_ >= N_0_) then
									break
								end
								v2123 = P_0_
								v2121 = v2108[v2123]
								v2122 = v2121.Level and " lvl " .. tostring(v2121.Level) or ""
								continue
							end
							if not (P_0_ <= N_0_) then
								break
							end
							v2123 = P_0_
							v2121 = v2108[v2123]
							v2122 = v2121.Level and " lvl " .. tostring(v2121.Level) or ""
						end
					end
				elseif n176 <= v2120 then
					v2121 = v2108[n176]
					if v2121.Level then
						v2122 = " lvl " .. tostring(v2121.Level) or ""
					else
						v2122 = ""
						if n7 == 542747526 then
							n2 = 227501077
							n175 -= 1708
							n7 -= 1737
							n4 += 1444
							n3 -= 980
							n5 = 315123293
							n6 -= 163
							n6()
						end
					end
					while true do
						table.insert(t21, "<font color=\"rgb(200,200,200)\">- " .. v2086(v2121.Name .. v2122) .. "</font>")
						P_0_ += Q_0_
						if Q_0_ <= 0 then
							if not (P_0_ >= N_0_) then
								break
							end
							v2123 = P_0_
							v2121 = v2108[v2123]
							v2122 = v2121.Level and " lvl " .. tostring(v2121.Level) or ""
							continue
						end
						if not (P_0_ <= N_0_) then
							break
						end
						v2123 = P_0_
						v2121 = v2108[v2123]
						v2122 = v2121.Level and " lvl " .. tostring(v2121.Level) or ""
					end
				end
			end
			return table.concat(t21, "\n"), #v2108
		end
		local function v2125()
			local n177 = 279802529
			local n178 = 141646247
			local n179 = 874980735
			if _G.Ox.KillerPerks.Gui then
				pcall(function()
					_G.Ox.KillerPerks.Gui:Destroy()
					if n178 ~= 141646247 then
						n2 = 169748147
						n178 += 238
						n1 = 261125655
						n179 = 1019081630
						n177 -= 2009
						n5 = 512194499
						bit32.band(nil, nil  )
					end
				end)
				_G.Ox.KillerPerks.Gui = nil
			end
			if not _G.Ox.KillerPerks.Enabled then
				return
			end
			local ScreenGui = Instance.new("ScreenGui")
			ScreenGui.Name = "NEX_KillerPerksGui"
			ScreenGui.ResetOnSpawn = false
			ScreenGui.IgnoreGuiInset = true
			ScreenGui.Parent = CoreGui
			local Frame = Instance.new("Frame")
			Frame.Name = "Holder"
			Frame.Size = UDim2.new(0, 180, 0, 85)
			Frame.Position = UDim2.new(0.08, 0, 0.22, 0)
			Frame.BackgroundTransparency = 1
			Frame.Active = true
			Frame.Parent = ScreenGui
			local Frame2 = Instance.new("Frame")
			Frame2.Name = "Panel"
			Frame2.Size = UDim2.new(1, 0, 1, 0)
			Frame2.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
			Frame2.BackgroundTransparency = 0.15
			Frame2.BorderSizePixel = 0
			Frame2.Parent = Frame
			Instance.new("UICorner", Frame2).CornerRadius = UDim.new(0, 6)
			local UIStroke = Instance.new("UIStroke")
			UIStroke.Color = Color3.fromRGB(60, 60, 70)
			UIStroke.Thickness = 1
			UIStroke.Transparency = 0.3
			UIStroke.Parent = Frame2
			local Frame3 = Instance.new("Frame")
			Frame3.Size = UDim2.new(1, 0, 0, 24)
			Frame3.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
			Frame3.BorderSizePixel = 0
			Frame3.Parent = Frame2
			Instance.new("UICorner", Frame3).CornerRadius = UDim.new(0, 6)
			local TextLabel = Instance.new("TextLabel")
			TextLabel.Size = UDim2.new(1, -60, 1, 0)
			TextLabel.Position = UDim2.new(0, 8, 0, 0)
			TextLabel.BackgroundTransparency = 1
			TextLabel.Font = Enum.Font.GothamSemibold
			local Minimize, Close, TextLabel2
			if n178 == 141646247 then
				TextLabel.Text = "Killer Perks Info"
				TextLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
				TextLabel.TextSize = 11
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.Parent = Frame3
				local function createTextButton(p150, p151, p152)
					local TextButton = Instance.new("TextButton")
					TextButton.Size = UDim2.new(0, 26, 0, 16)
					TextButton.Position = UDim2.new(1, p151, 0, 4)
					TextButton.BackgroundColor3 = p152 or Color3.fromRGB(25, 25, 30)
					TextButton.BorderSizePixel = 0
					TextButton.Font = Enum.Font.GothamMedium
					TextButton.Text = p150
					TextButton.TextColor3 = Color3.fromRGB(200, 200, 210)
					TextButton.TextSize = 9
					TextButton.Parent = Frame3
					Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 4)
					return TextButton
				end
				Minimize = createTextButton("Minimize", -54, Color3.fromRGB(30, 30, 40))
				Close = createTextButton("Close", -28, Color3.fromRGB(40, 25, 25))
				TextLabel2 = Instance.new("TextLabel")
			else
				n1 = 993869254
				n7 -= 1343
				n6 = 349640357
				n178 = 697917734
				n5 -= 359
				n179 -= 792
				n3 = 737152325
				n177 -= 870
				n2 += 1902
				upv362[nil  ] = nil
				TextLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
				TextLabel.TextSize = 11
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.Parent = Frame3
				local function createTextButton(p153, p154, p155)
					local TextButton = Instance.new("TextButton")
					TextButton.Size = UDim2.new(0, 26, 0, 16)
					TextButton.Position = UDim2.new(1, p154, 0, 4)
					TextButton.BackgroundColor3 = p155 or Color3.fromRGB(25, 25, 30)
					TextButton.BorderSizePixel = 0
					TextButton.Font = Enum.Font.GothamMedium
					TextButton.Text = p153
					TextButton.TextColor3 = Color3.fromRGB(200, 200, 210)
					TextButton.TextSize = 9
					TextButton.Parent = Frame3
					Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 4)
					return TextButton
				end
				Minimize = createTextButton("Minimize", -54, Color3.fromRGB(30, 30, 40))
				Close = createTextButton("Close", -28, Color3.fromRGB(40, 25, 25))
				TextLabel2 = Instance.new("TextLabel")
			end
			TextLabel2.Name = "KillerPerksText"
			TextLabel2.Size = UDim2.new(1, -14, 1, -32)
			TextLabel2.Position = UDim2.new(0, 8, 0, 28)
			TextLabel2.BackgroundTransparency = 1
			TextLabel2.Font = Enum.Font.GothamMedium
			TextLabel2.RichText = true
			TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
			TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
			TextLabel2.TextColor3 = Color3.fromRGB(220, 220, 230)
			TextLabel2.TextSize = 11
			TextLabel2.TextWrapped = false
			TextLabel2.Parent = Frame2
			Minimize.MouseButton1Click:Connect(function()
				_G.Ox.KillerPerks.Minimized = not _G.Ox.KillerPerks.Minimized
				TextLabel2.Visible = not _G.Ox.KillerPerks.Minimized
				Minimize.Text = _G.Ox.KillerPerks.Minimized and "Show" or "Minimize"
				Frame.Size = _G.Ox.KillerPerks.Minimized and UDim2.new(0, 180, 0, 24) or UDim2.new(0, 180, 0, 85)
			end)
			Close.MouseButton1Click:Connect(function()
				_G.Ox.KillerPerks.Enabled = false
				local n180 = 384085692
				if _G.Ox.KillerPerks.Gui then
					pcall(function()
						local n181 = 1055372
						_G.Ox.KillerPerks.Gui:Destroy()
						if n181 == n3 then
							n3 = 269941978
							n177 -= 596
							n179 = 580019119
							n5 = 602896136
							n180 -= 34
							n178 = 284527146
							;(nil)()
						end
					end)
					_G.Ox.KillerPerks.Gui = nil
				end
				if KillerPerksToggle then
					v531(KillerPerksToggle, false)
				end
			end)
			local u2144 = false
			local Position
			local Position2
			Frame.InputBegan:Connect(function(input)
				if not (n6 < n5) then
					n6 = 791326412
					n5 -= 531
					n179 = 1050418300
					n178 += 705
					n177 -= 678
					n2 = 810298517
					;(nil)(nil)
					;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 425))
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					u2144 = true
					Position = input.Position
					Position2 = Frame.Position
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							u2144 = false
						end
					end)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if not u2144 or not Position or not Position2 then
					return
				end
				if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				local v2147 = input.Position - Position
				Frame.Position = UDim2.new(Position2.X.Scale, Position2.X.Offset + v2147.X, Position2.Y.Scale, Position2.Y.Offset + v2147.Y)
			end)
			ScreenGui.Parent = CoreGui
			_G.Ox.KillerPerks.Gui = ScreenGui
			task.spawn(function()
				while _G.Ox.KillerPerks.Enabled and _G.Ox.KillerPerks.Gui do
					if not _G.Ox.KillerPerks.Minimized then
						local v2148, v2149 = v2105()
						TextLabel2.Text = v2148
						Frame.Size = UDim2.new(0, 180, 0, math.max(65, 28 + math.max(2, math.min(v2149 + 1, 5)) * 15))
					end
					task.wait(1)
				end
				if n5 == 403424181 then
					n178 = 945045569
					n179 -= 1050
					n3 = 654056213
					n177 += 285
					n6 -= 1631
					n5 += 906
					upv32[nil  ] = nil
				end
			end)
		end
		v2085 = function(p156)
			_G.Ox.KillerPerks.Enabled = p156
			if p156 then
				v2125()
				lib2:Notify({
					Title = "Killer Perks Display",
					Description = "ON - shows the killer's perks",
					Duration = 3
				})
			else
				if _G.Ox.KillerPerks.Gui then
					pcall(function()
						_G.Ox.KillerPerks.Gui:Destroy()
					end)
					_G.Ox.KillerPerks.Gui = nil
				end
				lib2:Notify({
					Title = "Killer Perks Display",
					Description = "OFF",
					Duration = 2
				})
			end
		end
	end
	PlayHitSound = function()
		local n182 = 977010349
		if not _G.Ox.Stun.HitSoundEnabled then
			return
		end
		local now = tick()
		if not (now - _G.Ox.Stun.HitSoundLastTime < _G.Ox.Stun.HitSoundCooldown) then
			_G.Ox.Stun.HitSoundLastTime = now
			local n183
			pcall(function()
				n183 = 69068694
				local Sound = Instance.new("Sound")
				Sound.SoundId = _G.Ox.Stun.HitSoundId
				Sound.Volume = _G.Ox.Stun.HitSoundVolume
				Sound.PlayOnRemove = true
				Sound.Parent = workspace.CurrentCamera or workspace
				Sound:Play()
				if not (n1 < n182) then
					n2 -= 853
					n4 = 771322491
					n183 -= 838
					n1 = 474261030
					n182 -= 576
					n5 += 569
					bit32.band(nil, nil  )
					while true do
						n183 = 69068694
						Sound = Instance.new("Sound")
						Sound.SoundId = _G.Ox.Stun.HitSoundId
						Sound.Volume = _G.Ox.Stun.HitSoundVolume
						Sound.PlayOnRemove = true
						Sound.Parent = workspace.CurrentCamera or workspace
						Sound:Play()
						if n1 < n182 then
							break
						end
						n2 -= 853
						n4 = 771322491
						n183 -= 838
						n1 = 474261030
						n182 -= 576
						n5 += 569
						bit32.band(nil, nil  )
					end
				end
				task.delay(Sound.TimeLength + 0.1, function()
					if Sound and Sound.Parent then
						Sound:Destroy()
					end
				end)
			end)
			return
		end
	end
	local v2154
	do
		local function v2155(p157)
			local HumanoidRootPart = p157:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then
				return nil
			end
			local StunRingUI = HumanoidRootPart:FindFirstChild("StunRingUI")
			if StunRingUI then
				StunRingUI:Destroy()
			end
			local BillboardGui = Instance.new("BillboardGui")
			BillboardGui.Name = "StunRingUI"
			BillboardGui.Adornee = HumanoidRootPart
			BillboardGui.AlwaysOnTop = true
			BillboardGui.Size = UDim2.new(0, 40, 0, 40)
			BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, 4.5, 0)
			local n184 = 580218793
			BillboardGui.ResetOnSpawn = false
			BillboardGui.LightInfluence = 0
			BillboardGui.Parent = HumanoidRootPart
			local ImageLabel = Instance.new("ImageLabel", BillboardGui)
			ImageLabel.Size = UDim2.new(1, 0, 1, 0)
			ImageLabel.Position = UDim2.new(0, 0, 0, 0)
			ImageLabel.BackgroundTransparency = 1
			ImageLabel.Image = "rbxassetid://129594563448607"
			ImageLabel.ScaleType = Enum.ScaleType.Fit
			BillboardGui.Enabled = false
			return BillboardGui, (task.spawn(function()
				local rotation = 0
				while BillboardGui and BillboardGui.Parent do
					if BillboardGui.Enabled then
						rotation = (rotation + 6) % 360
						ImageLabel.Rotation = rotation
						local v2162 = math.clamp(math.floor(600 / (workspace.CurrentCamera.CFrame.Position - HumanoidRootPart.Position).Magnitude), 22, 44)
						BillboardGui.Size = UDim2.new(0, v2162, 0, v2162)
					end
					task.wait(0.1)
				end
				if n6 == 295005065 then
					return
				end
				n4 += 279
				n5 += 1330
				n6 += 1094
				n3 = 405762336
				n184 -= 650
				return nil
			end))
		end
		local function v2163(p158)
			if not p158 or _G.Ox.Stun.Data[p158] then
				return
			end
			local v2164, v2165 = v2155(p158)
			local n185 = 707355486
			if not v2164 then
				return
			end
			local t22 = {
				stunRing = v2164,
				stunSpinThread = v2165,
				_stunTimer = nil,
				extraConns = {}
			}
			_G.Ox.Stun.Data[p158] = t22
			local n186 = 27649804
			local n187 = 273735675
			local function v2170(p159)
				if not t22.stunRing then
					return
				end
				t22.stunRing.Enabled = true
				if t22._stunTimer then
					task.cancel(t22._stunTimer)
				end
				t22._stunTimer = task.delay(p159, function()
					if t22.stunRing then
						t22.stunRing.Enabled = false
					end
				end)
			end
			local connection = p158:GetAttributeChangedSignal("IsStunned"):Connect(function()
				if p158:GetAttribute("IsStunned") == true then
					v2170(2.2)
				end
			end)
			local connection2 = p158:GetAttributeChangedSignal("Immobile"):Connect(function()
				if p158:GetAttribute("Immobile") == true then
					v2170(2.2)
				end
				if n5 == n186 then
					n186 += 1846
					n1 += 1593
					n187 += 599
					n5 = 618808864
					n185 -= 209
					getfenv()[nil  ] = nil
					local _
					;(nil)(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
				end
			end)
			table.insert(t22.extraConns, connection)
			table.insert(t22.extraConns, connection2)
		end
		local function v2277(p160)
			local v2278 = _G.Ox.Stun.Data[p160]
			if v2278 then
				if v2278._stunTimer then
					task.cancel(v2278._stunTimer)
				end
				if v2278.stunSpinThread then
					task.cancel(v2278.stunSpinThread)
				end
				if v2278.stunRing then
					v2278.stunRing:Destroy()
				end
				if v2278.extraConns then
					for _, extraConn in ipairs(v2278.extraConns) do
						pcall(function()
							extraConn:Disconnect()
						end)
					end
				end
				_G.Ox.Stun.Data[p160] = nil
			end
		end
		local function v2281()
			if not _G.Ox.Stun.Enabled then
				return
			end
			local n188 = 783408661
			for _, player in ipairs(Players:GetPlayers()) do
				if IsKiller(player) and player.Character then
					if n4 == 666562044 then
						n2 = 120584236
						n188 -= 157
						n5 = 135053158
						n6 = 361116951
						n7 = 471215890
						n4 -= 582
						n1 = 734060566
						bit32.bxor(nil, nil  )
					else
						v2163(player.Character)
					end
				end
			end
		end
		Players.PlayerAdded:Connect(function(player)
			if not _G.Ox.Stun.Enabled then
				return
			end
			player.CharacterAdded:Connect(function(character)
				task.wait(0.5)
				if _G.Ox.Stun.Enabled and IsKiller(player) then
					v2163(character)
				end
			end)
			task.wait(0.5)
			if _G.Ox.Stun.Enabled and IsKiller(player) and player.Character then
				v2163(player.Character)
			end
		end)
		Players.PlayerAdded:Connect(function(player)
			local n189
			player:GetPropertyChangedSignal("Team"):Connect(function()
				n189 = 953293138
				if not _G.Ox.Stun.Enabled then
					return
				end
				task.wait(0.5)
				if IsKiller(player) and player.Character then
					v2277(player.Character)
					task.wait(0.1)
					v2163(player.Character)
				end
				if n5 ~= 403424139 then
					return
				end
				n2 = 6814201
				n6 += 824
				n3 = 720930980
				n5 -= 1857
				n189 += 1715
				return (nil)()
			end)
		end)
		Players.PlayerAdded:Connect(function()
			task.wait(0.5)
			if _G.Ox.Stun.Enabled then
				v2281()
			end
		end)
		v18.CharacterAdded:Connect(function()
			task.wait(1.5)
			if _G.Ox.Stun.Enabled then
				v2281()
			end
		end)
		task.spawn(function()
			while _G.Ox.ScriptAlive do
				task.wait(5)
				if not _G.Ox.ScriptAlive then
					break
				end
				if _G.Ox.Stun.Enabled then
					for _, player in ipairs(Players:GetPlayers()) do
						if IsKiller(player) and player.Character then
							local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
							if HumanoidRootPart and not HumanoidRootPart:FindFirstChild("StunRingUI") then
								v2163(player.Character)
							end
						end
					end
				end
			end
		end)
		v2154 = function(p161)
			_G.Ox.Stun.Enabled = p161
			if p161 then
				for k in pairs(_G.Ox.Stun.Data) do
					v2277(k)
				end
				_G.Ox.Stun.Data = {}
				task.wait(0.5)
				v2281()
				lib2:Notify({
					Title = "Stun Indicator",
					Description = "ON - shows stuns on the killer",
					Duration = 3
				})
			else
				for k in pairs(_G.Ox.Stun.Data) do
					v2277(k)
				end
				_G.Ox.Stun.Data = {}
				lib2:Notify({
					Title = "Stun Indicator",
					Description = "OFF",
					Duration = 2
				})
			end
		end
	end
	AntiHook_GetRemote = function()
		if _G.Ox.AntiHook.Remote and _G.Ox.AntiHook.Remote.Parent then
			return _G.Ox.AntiHook.Remote
		end
		local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local Game = Remotes and Remotes:FindFirstChild("Game")
		local UpdateCharacterLook = Game and Game:FindFirstChild("UpdateCharacterLook")
		_G.Ox.AntiHook.Remote = UpdateCharacterLook
		return UpdateCharacterLook
	end
	AntiHook_SendRemoteUpdate = function()
		if not v18.Character then
			return
		end
		local v2294 = AntiHook_GetRemote()
		if not v2294 then
			return
		end
		local cFrame = CFrame.new(0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		local cFrame2 = CFrame.new(0, _G.Ox.AntiHook.OffsetY, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		pcall(function()
			v2294:FireServer(cFrame, cFrame2, cFrame2, cFrame2, cFrame2)
			local AntiHook = _G.Ox.AntiHook
			AntiHook.SendCounter += 1
		end)
	end
	AntiHook_Update = function(p162)
		if not _G.Ox.AntiHook.Enabled then
			return
		end
		local n190 = 33375836
		local Character = v18.Character
		if not Character then
			_G.Ox.AntiHook.Accumulator = 0
			return
		end
		if Character:GetAttribute("IsCarried") ~= true then
			_G.Ox.AntiHook.Accumulator = 0
			return
		end
		local AntiHook = _G.Ox.AntiHook
		local exitTo3, v2302
		repeat
			AntiHook = AntiHook.Accumulator + p162
			local _G_ = _G
			exitTo3 = nil
			while true do
				_G_ = _G_.Ox.AntiHook.Interval
				local n191 = 0
				local exitTo2
				while _G_ <= AntiHook and n191 < 3 do
					AntiHook -= _G_
					n191 += 1
					if n190 < n3 then
						AntiHook_SendRemoteUpdate()
					else
						n1 -= 1315
						n3 = 605910368
						n190 += 1557
						n6 -= 637
						n7 = 103159789
						local exitTo
						while true do
							n5 -= 1503
							n2 -= 428
							;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, v2302, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 316))
							if nil <= nil then
								if nil <= nil then
									exitTo = 1
									break
								end
							else
								break
							end
						end
						if exitTo == 1 then
							v2302 = upv354[nil  ]
							if true then
								exitTo2 = 2
								break
							end
						else
							exitTo2 = 1
							break
						end
					end
				end
				if exitTo2 == 1 then
					exitTo3 = 1
					break
				elseif exitTo2 == 2 then
					continue
				end
				break
			end
		until exitTo3 ~= 1
		_G.Ox.AntiHook.Accumulator = AntiHook
	end
	StartAntiHook = function()
		if _G.Ox.AntiHook.Connection then
			return
		end
		_G.Ox.AntiHook.Accumulator = 0
		_G.Ox.AntiHook.Connection = RunService.Heartbeat:Connect(AntiHook_Update)
	end
	StopAntiHook = function()
		if _G.Ox.AntiHook.Connection then
			_G.Ox.AntiHook.Connection:Disconnect()
			_G.Ox.AntiHook.Connection = nil
		end
		_G.Ox.AntiHook.Accumulator = 0
	end
	task.spawn(function()
		while true do
			task.wait(1)
			local now = os.clock()
			local v2308 = now - _G.Ox.AntiHook.LastCounterTime
			local SendCounter = _G.Ox.AntiHook.SendCounter
			if _G.Ox.AntiHook.Enabled and v2308 > 0 and SendCounter > 0 then
				select("#", string.format("[AntiHook] Actual rate: %.2f Hz (%d sends in %.2fs)", SendCounter / v2308, SendCounter, v2308))
			end
			_G.Ox.AntiHook.SendCounter = 0
			_G.Ox.AntiHook.LastCounterTime = now
		end
	end)
	do
		ToggleAntiHook = function(p163)
			_G.Ox.AntiHook.Enabled = p163
			if p163 then
				StartAntiHook()
				lib2:Notify({
					Title = "Anti Hook",
					Description = "ON",
					Duration = 2
				})
			else
				StopAntiHook()
				lib2:Notify({
					Title = "Anti Hook",
					Description = "OFF",
					Duration = 2
				})
			end
		end
	end
	MainTab = v14:CreateTab("Main", false, false)
	M_Page = MainTab:CreatePage("Main")
	MovementCard = M_Page:CreateSection("Movement", "move")
	AutoVaultToggle = MovementCard:AddToggle("Auto Vault", false, function(p164)
		_G.Ox.autoVaultEnabled = p164
		lib2:Notify({
			Title = "Auto Vault",
			Description = p164 and "ON" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "AutoVault"
	})
	AutoVaultToggle:AddKeyPicker("None")
	AutoSlideToggle = MovementCard:AddToggle("Auto Pallet Slide", false, function(p165)
		_G.Ox.autoPalletSlideEnabled = p165
		lib2:Notify({
			Title = "Auto Pallet Slide",
			Description = p165 and "ON" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "AutoPalletSlide"
	})
	AutoSlideToggle:AddKeyPicker("None")
	AutoRunPCToggle = MovementCard:AddToggle("Auto Run PC", false, function(p166)
		_G.Ox.AutoRun.PC = p166
		if p166 then
			task.spawn(function()
				while _G.Ox.AutoRun.PC do
					VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, LocalPlayer:GetMouse())
					task.wait(0.1)
				end
			end)
		else
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, LocalPlayer:GetMouse())
		end
	end, {
		Flag = "AutoRunPc"
	})
	AutoRunMobileToggle = MovementCard:AddToggle("Auto Run Mobile", false, function(p167)
		_G.Ox.AutoRun.Mobile = p167
		if p167 then
			v630()
		else
			v631()
		end
	end, {
		Flag = "AutoRunMobile"
	})
	SpeedToggle = MovementCard:AddToggle("Enable Speed Boost", false, function(p168)
		_G.Ox.Speed.Enabled = p168
		lib2:Notify({
			Title = "Speed Boost",
			Description = p168 and "ON" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "SpeedBoost"
	})
	SpeedToggle:AddKeyPicker("SpeedBoostKey", {
		Default = "None",
		Text = "Toggle Speed Boost",
		Mode = "Toggle",
		Callback = function(p169)
			_G.Ox.Speed.Enabled = p169
			if SpeedToggle then
				v531(SpeedToggle, p169)
			end
			if n4 == n5 then
				n7 = 405041679
				n2 = 1015051376
				n6 += 1277
				n1 = 514215143
				n5 += 1930
				n4 -= 1249
				bit32.bxor(nil, nil)
				upv512[nil] = nil
			end
		end
	})
	do
		MovementCard:AddSlider("SpeedAmount", 0.1, 3, 0.1, function(p170)
			_G.Ox.Speed.Value = p170
		end, {
			Increment = 0.1,
			Flag = "SpeedAmount"
		})
	end
	_G.Ox.SkipEndscreen = false
	ServerUtilityCard = M_Page:CreateSection("Server Utility", "server-cog")
	SkipEndscreenToggle = ServerUtilityCard:AddToggle("Skip Endscreen", false, function(p171)
		_G.Ox.SkipEndscreen = p171
		lib2:Notify({
			Title = "Skip Endscreen",
			Description = p171 and "ON - endscreen skipped automatically" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "SkipEndscreen"
	})
	do
		SkipEndscreenToggle:AddKeyPicker("SkipEndKey", {
			Default = "None",
			Text = "Toggle Skip Endscreen",
			Mode = "Toggle",
			Callback = function(p172)
				_G.Ox.SkipEndscreen = p172
				if SkipEndscreenToggle then
					if n6 == n3 then
						n4 = 426798477
						n5 = 364090934
						n3 = 680704047
						n7 = 626200910
						n1 = 274808819
						n6 -= 804
						;(nil)(nil)
						bit32.rshift(nil, nil  )
					else
						SkipEndscreenToggle:SetValue(p172)
					end
				end
			end
		})
	end
	task.spawn(function()
		local n192 = 660752451
		local n193 = 186996486
		local n194 = 65253555
		local n195 = 99073512
		if not _G.Ox.ScriptAlive then
			return
		end
		while true do
			if _G.Ox.SkipEndscreen then
				pcall(function()
					local Map = workspace:FindFirstChild("Map")
					if Map then
						local endscreen = Map:FindFirstChild("endscreen", true)
						if endscreen then
							for _, descendant in ipairs(endscreen:GetDescendants()) do
								if descendant:IsA("LocalScript") then
									descendant.Disabled = true
								end
							end
							endscreen:Destroy()
						end
					end
					local Results = PlayerGui:FindFirstChild("Results")
					if Results then
						local Frame = Results:FindFirstChild("Frame")
						if Frame then
							local Close = Frame:FindFirstChild("Close")
							if Close and Frame.Visible and Close.Visible then
								pcall(function()
									firesignal(Close.MouseButton1Click)
								end)
							end
						end
					end
				end)
			end
			task.wait(1)
			if not _G.Ox.ScriptAlive then
				return
			end
			while n192 == 660752929 do
				n6 = 471702844
				n4 += 725
				n194 -= 1177
				n2 += 1411
				n7 += 745
				n192 += 904
				n195 -= 440
				n193 -= 384
				n3 = 217762744
				n5 -= 408
				local v2321 = table.pack(P_0())
				if not v2321[1] then
					return table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 287)
				end
			end
		end
	end)
	FakePerksCard = M_Page:CreateSection("Fake Perks", "sparkles")
	QR_Toggle = FakePerksCard:AddToggle("Quick Recovery", false, function(p173)
		ToggleQuickRecovery(p173)
		if n7 < n4 then
			return
		end
		n7 += 805
		n4 = 214248075
		n2 -= 248
		n5 -= 1707
		n3 = 731444463
		n6 = 1030025527
	end, {
		Flag = "FakeQR"
	})
	QR_Toggle:AddKeyPicker("None")
	PL_Toggle = FakePerksCard:AddToggle("Perfect Landing", false, function(p174)
		TogglePerfectLanding(p174)
	end, {
		Flag = "FakePL"
	})
	PL_Toggle:AddKeyPicker("None")
	do
		FS_Toggle = FakePerksCard:AddToggle("Flowstate", false, function(p175)
			ToggleFlowstate(p175)
		end, {
			Flag = "FakeFS"
		})
	end
	FS_Toggle:AddKeyPicker("None")
	AR_Toggle = FakePerksCard:AddToggle("Adrenaline Rush", false, function(p176)
		SetupFakeAdrenalineRush(p176)
	end, {
		Flag = "FakeAR"
	})
	AR_Toggle:AddKeyPicker("None")
	FakePerksCard:AddSlider("Perk Cooldown", 0, 180, 10, function(p177)
		_G.Ox.FakePerks.PerkCooldown = p177
	end, {
		Increment = 1,
		Flag = "FakePerkColdown"
	})
	CameraCard = M_Page:CreateSection("Camera Settings", "camera")
	do
		StretchToggle = CameraCard:AddToggle("Enable Stretch Res", false, function(p178)
			v1881(p178)
		end, {
			Flag = "SretchRes"
		})
	end
	StretchToggle:AddKeyPicker("None")
	CameraCard:AddSlider("Stretch Amount", 0.4, 1, 0.67, function(p179)
		_G.Ox.StretchRes.Amount = p179
	end, {
		Increment = 0.01,
		Flag = "StretchAmount"
	})
	ThirdPersonToggle = CameraCard:AddToggle("Third Person (Killer)", false, function(p180)
		v1968(p180)
	end, {
		Flag = "ThirdPerson"
	})
	do
		InfinityToggle = CameraCard:AddToggle("Infinity Zoom Out", false, function(p181)
			if n5 == 403423201 then
				n6 = 193896845
				n7 = 1046615234
				n3 += 651
				n1 -= 758
				n5 -= 1179
				n4 = 87719228
				;(nil)(nil)
			else
				v1930(p181)
			end
		end, {
			Flag = "InfinityZoom"
		})
	end
	FOVToggle = CameraCard:AddToggle("Camera FOV", false, function(p182)
		v1932(p182)
		if not (n6 < n5) then
			n3 -= 347
			n4 = 785873177
			n7 += 1250
			n5 -= 1343
			n6 = 717970620
			n2 -= 107
		end
	end, {
		Flag = "CameraFov"
	})
	CameraCard:AddSlider("FOV Value", 60, 120, 90, function(p183)
		v1933(p183)
	end, {
		Increment = 0,
		Flag = "FOVValue"
	})
	DbdCard = M_Page:CreateSection("Camera DBD", "camera")
	_G.Ox.DBD = {
		Enabled = false,
		Distance = 13,
		Height = 4.2,
		RunSmooth = 0.1,
		LookSmooth = 0.28,
		Sens = 0.55,
		PitchMin = -0.55,
		PitchMax = 0.45,
		FOV = 70,
		yaw = 0,
		pitch = 0.12,
		lookInput = nil,
		lastPos = nil,
		conn = nil,
		chg = nil,
		beg = nil,
		endc = nil,
		oldFOV = nil
	}
	DBD_isLookTouch = function(p184)
		if n5 ~= 384832375 then
			return p184.X > workspace.CurrentCamera.ViewportSize.X * 0.22
		end
		n3 += 38
		n6 += 606
		n5 -= 1589
		n2 = 850657649
		n1 = 677470625
		n7 += 651
	end
	DBD_initYaw = function()
		local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not HumanoidRootPart then
			return
		end
		local v2323 = HumanoidRootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
		if v2323.Magnitude > 0.05 then
			_G.Ox.DBD.yaw = math.atan2(-v2323.X, -v2323.Z)
		end
	end
	do
		DBD_Stop = function()
			local DBD = _G.Ox.DBD
			if DBD.conn then
				DBD.conn:Disconnect()
				DBD.conn = nil
			end
			if DBD.chg then
				DBD.chg:Disconnect()
				DBD.chg = nil
			end
			if DBD.beg then
				DBD.beg:Disconnect()
				DBD.beg = nil
			end
			if DBD.endc then
				DBD.endc:Disconnect()
				DBD.endc = nil
			end
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			if DBD.oldFOV then
				workspace.CurrentCamera.FieldOfView = DBD.oldFOV
			end
			DBD.lookInput = nil
			DBD.lastPos = nil
		end
	end
	DBD_Start = function()
		DBD_Stop()
		local DBD = _G.Ox.DBD
		if not DBD.Enabled then
			return
		end
		DBD_initYaw()
		local n196 = 28893595
		DBD.oldFOV = workspace.CurrentCamera.FieldOfView
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera.FieldOfView = DBD.FOV
		local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			Humanoid.AutoRotate = true
		end
		if n6 == 295005065 then
			DBD.chg = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				if input ~= DBD.lookInput then
					return
				end
				local n197 = 866110627
				local Position = input.Position
				if DBD.lastPos then
					DBD.yaw -= (Position.X - DBD.lastPos.X) * 0.011 * DBD.Sens
					DBD.pitch = math.clamp(DBD.pitch - (Position.Y - DBD.lastPos.Y) * 0.011 * DBD.Sens, DBD.PitchMin, DBD.PitchMax)
				end
				if n5 < n197 then
					DBD.lastPos = Position
					return
				end
				n1 -= 199
				n196 -= 953
				n2 = 549988341
				n5 += 1342
				n5()
				;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 255))
				return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
			end)
		else
			n6 -= 966
			n5 += 1934
			n196 += 143
			n2 -= 158
			n7 += 1147
			n1 += 1454
			n3 = 480066578
			;(nil)()
			n3[57] = nil
		end
		local function v2330(input)
			if input.UserInputType == Enum.UserInputType.Touch and DBD_isLookTouch(input.Position) then
				DBD.lookInput = input
				DBD.lastPos = input.Position
			end
		end
		DBD.beg = UserInputService.InputBegan:Connect(v2330)
		DBD.endc = UserInputService.InputEnded:Connect(function(input)
			if input == DBD.lookInput then
				DBD.lookInput = nil
				DBD.lastPos = nil
			end
		end)
		DBD.conn = RunService.RenderStepped:Connect(function(dt)
			if not DBD.Enabled then
				return
			end
			local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then
				return
			end
			local vector3 = Vector3.new(math.sin(DBD.yaw) * math.cos(DBD.pitch), math.sin(DBD.pitch), math.cos(DBD.yaw) * math.cos(DBD.pitch))
			local v2333 = HumanoidRootPart.Position + Vector3.new(0, 1.6, 0)
			workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.lookAt(v2333 - vector3 * DBD.Distance + Vector3.new(0, DBD.Height - 1.6, 0), v2333), 1 - math.pow(1 - (DBD.lookInput and DBD.LookSmooth or DBD.RunSmooth), dt * 60))
		end)
	end
	LocalPlayer.CharacterAdded:Connect(function()
		task.wait(0.6)
		if _G.Ox.DBD.Enabled then
			DBD_Start()
		end
	end)
	DbdCard:AddToggle("DBD Camera", false, function(p185)
		_G.Ox.DBD.Enabled = p185
		if p185 then
			if _G.Ox.CameraFOV then
				_G.Ox.CameraFOV.Enabled = false
			end
			DBD_Start()
		else
			DBD_Stop()
		end
		lib2:Notify({
			Title = "DBD Camera",
			Description = p185 and "ON" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "DBDCamera"
	})
	DbdCard:AddSlider("DBD Distance", 6, 20, 13, function(p186)
		_G.Ox.DBD.Distance = p186
	end, {
		Increment = 0.1,
		Flag = "DBDDistance"
	})
	do
		local n198
		local n199
		DbdCard:AddSlider("DBD Height", 1, 8, 4.2, function(p187)
			n198 = 780055357
			n199 = 612760364
			_G.Ox.DBD.Height = p187
			if n4 < 703254363 then
				return
			end
			n198 -= 469
			n4 -= 877
			n199 += 824
			n2 = 818451209
			n5 -= 1719
			n3 = 540627833
			n6 += 1884
			n7 = 466421988
			return (nil)(nil)
		end, {
			Increment = 0.1,
			Flag = "DBDHeight"
		})
	end
	do
		DbdCard:AddSlider("DBD Run Smooth", 0.03, 0.35, 0.1, function(p188)
			_G.Ox.DBD.RunSmooth = p188
		end, {
			Increment = 0.01,
			Flag = "DBDRunSmooth"
		})
	end
	DbdCard:AddSlider("DBD Look Smooth", 0.08, 0.6, 0.28, function(p189)
		_G.Ox.DBD.LookSmooth = p189
	end, {
		Increment = 0.01,
		Flag = "DBDLookSmooth"
	})
	DbdCard:AddSlider("DBD Sensitivity", 0.15, 1.2, 0.55, function(p190)
		_G.Ox.DBD.Sens = p190
	end, {
		Increment = 0.01,
		Flag = "DBDSens"
	})
	DbdCard:AddSlider("DBD Pitch Min", -1.2, 0, -0.55, function(p191)
		_G.Ox.DBD.PitchMin = p191
	end, {
		Increment = 0.01,
		Flag = "DBDPitchMin"
	})
	local n200
	DbdCard:AddSlider("DBD Pitch Max", 0, 1.2, 0.45, function(p192)
		n200 = 677690025
		_G.Ox.DBD.PitchMax = p192
		if n7 ~= n200 then
			return
		end
		n4 = 751162719
		n7 = 1057503442
		n3 -= 822
		n2 = 1073108942
		n200 = 890713540
		n6 -= 440
		n5 = 850212411
		return (nil)()
	end, {
		Increment = 0.01,
		Flag = "DBDPitchMax"
	})
	do
		DbdCard:AddSlider("DBD FOV", 50, 90, 70, function(p193)
			_G.Ox.DBD.FOV = p193
			if _G.Ox.DBD.Enabled then
				workspace.CurrentCamera.FieldOfView = p193
			end
		end, {
			Increment = 1,
			Flag = "DBDFOV"
		})
	end
	StreamerCard = M_Page:CreateSection("Streamer Mode", "eye-off")
	do
		StreamerToggle = StreamerCard:AddToggle("Streamer Mode", false, function(p194)
			v1325(p194)
		end, {
			Flag = "StreamerMode"
		})
	end
	StreamerToggle:AddKeyPicker("None")
	UtilityCard = M_Page:CreateSection("Players Utility", "user-cog")
	InvisToggle = UtilityCard:AddToggle("Invisibility [OP]", false, function(p195)
		_G.Ox.Utility.InvisEnabled = p195
		if n3 == 660937080 then
			n2 -= 871
			n7 += 482
			n5 += 272
			n1 = 618149067
			n3 += 57
			n6 -= 1272
		else
			v1165(p195)
		end
	end, {
		Flag = "Invis"
	})
	InvisToggle:AddKeyPicker("None")
	BandageToggle = UtilityCard:AddToggle("Fast Bandage", false, function(p196)
		_G.Ox.Utility.BandageEnabled = p196
		v1167(p196)
		local n201 = 914997105
		if n201 == n5 then
			n6 += 1932
			n4 -= 1977
			n1 += 1649
			n7 = 681186553
			n2 -= 812
			n5 -= 592
			;(nil)()
		end
	end, {
		Flag = "FastBandage"
	})
	BandageToggle:AddKeyPicker("None")
	UtilityCard:AddSlider("BandageSpeed", 10, 200, 50, function(p197)
		_G.Ox.Utility.BandageSpeed = p197
		if u1166 and u1166.Config then
			u1166.Config.PreClicksCount = p197
		end
	end, {
		Increment = 1,
		Flag = "BandageSpeed"
	})
	MoonwalkGUIToggle = UtilityCard:AddToggle("Moonwalk GUI", false, function(p198)
		if p198 then
			if not _G.Ox.Moonwalk.Gui then
				CreateMoonwalkGUI()
			end
			_G.Ox.Moonwalk.Gui.Enabled = true
			_G.Ox.Moonwalk.GuiVisible = true
			UpdateMoonwalkGUI(_G.Ox.Moonwalk.Enabled)
			lib2:Notify({
				Title = "Moonwalk GUI",
				Description = "GUI loaded",
				Duration = 2
			})
		else
			if _G.Ox.Moonwalk.Enabled then
				StopMoonwalk()
				if MoonwalkPCToggle then
					v531(MoonwalkPCToggle, false)
				end
			end
			if _G.Ox.Moonwalk.Gui then
				_G.Ox.Moonwalk.Gui.Enabled = false
				_G.Ox.Moonwalk.GuiVisible = false
			end
			lib2:Notify({
				Title = "Moonwalk GUI",
				Description = "GUI hidden",
				Duration = 2
			})
		end
	end, {
		Flag = "MoonwalkGui"
	})
	MoonwalkPCToggle = UtilityCard:AddToggle("Moonwalk PC", false, function(p199)
		if p199 then
			StartMoonwalk()
		else
			StopMoonwalk()
		end
		UpdateMoonwalkGUI(_G.Ox.Moonwalk.Enabled)
		lib2:Notify({
			Title = "Moonwalk PC",
			Description = p199 and "ON" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "MoonwalkPC"
	})
	MoonwalkPCToggle:AddKeyPicker("MoonwalkPCKey", {
		Default = "None",
		Text = "Toggle Moonwalk",
		Mode = "Toggle",
		Callback = function(p200)
			if p200 then
				StartMoonwalk()
			else
				StopMoonwalk()
			end
			UpdateMoonwalkGUI(_G.Ox.Moonwalk.Enabled)
			if MoonwalkPCToggle then
				v531(MoonwalkPCToggle, p200)
			end
			if n4 ~= 666560820 then
				n4 = 3588993
				n6 = 330398678
				n7 = 306516461
				n1 = 989966110
				n5 += 1681
				n2 = 208204632
				;(nil)[nil] = nil
			end
		end
	})
	UtilityCard:AddButton("Fly GUI", function()
		local v2338 = false
		for _, child in pairs(game.CoreGui:GetChildren()) do
			if child.Name:lower():find("fly") then
				v2338 = true
			end
		end
		if v2338 then
			lib2:Notify({
				Title = "Fly GUI",
				Description = "Fly GUI is already open",
				Duration = 2
			})
		else
			loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Games/lib/VD_FlyGui.lua"))()
			lib2:Notify({
				Title = "Fly GUI",
				Description = "Fly GUI loaded",
				Duration = 3
			})
		end
	end)
	CrosshairBox = M_Page:CreateSection("Crosshair", "crosshair")
	CrosshairToggle = CrosshairBox:AddToggle("Enable Crosshair", false, function(p201)
		_G.Ox.Crosshair.Enabled = p201
		if not p201 then
			ClearCrosshair()
		end
		lib2:Notify({
			Title = "Crosshair",
			Description = p201 and "ON" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "Crosshair"
	})
	CrosshairToggle:AddKeyPicker("CrosshairKey", {
		Default = "None",
		Text = "Toggle Crosshair",
		Mode = "Toggle",
		Callback = function(p202)
			_G.Ox.Crosshair.Enabled = p202
			if not p202 then
				ClearCrosshair()
			end
		end
	})
	CrosshairToggle:AddColorPicker(_G.Ox.Crosshair.Color, {
		Flag = "Crosshair_Color",
		Title = "Crosshair Color",
		Callback = function(p203)
			_G.Ox.Crosshair.Color = p203
		end
	})
	CrosshairBox:AddDropdown("Style", {
		"Plus",
		"Dot",
		"Circle"
	}, false, function(p204)
		_G.Ox.Crosshair.Style = p204
		ClearCrosshair()
		_G.Ox.CrosshairCreated = false
	end, {
		Flag = "CrosshairStyle"
	})
	CrosshairBox:AddSlider("Size", 2, 30, 8, function(p205)
		_G.Ox.Crosshair.Size = p205
	end, {
		Increment = 1,
		Flag = "CrosshairSize"
	})
	CrosshairBox:AddSlider("Thickness", 1, 5, 2, function(p206)
		_G.Ox.Crosshair.Thickness = p206
		if n5 == n2 then
			n4 += 1781
			n5 = 522026920
			n1 = 647790506
			n2 = 319511096
			n7 -= 1495
			n3 -= 18
			upv228[nil] = nil
		end
	end, {
		Increment = 1,
		Flag = "CrosshairThickness"
	})
	CrosshairBox:AddSlider("Position X", -100, 100, 0, function(p207)
		_G.Ox.Crosshair.OffsetX = p207
	end, {
		Increment = 1,
		Flag = "CrosshairX"
	})
	CrosshairBox:AddSlider("Position Y", -100, 100, 0, function(p208)
		_G.Ox.Crosshair.OffsetY = p208
	end, {
		Increment = 1,
		Flag = "CrosshairY"
	})
	FakeAvatarSection = M_Page:CreateSection("Copy Avatar", "shirt")
	Pandu_RANDOM_IDS = {
		978663613,
		5261700291,
		1846241644,
		4993456331,
		424866237,
		4312175249
	}
	Pandu_CURRENT_AVATAR = nil
	Pandu_ORIGINAL_ID = LocalPlayer.UserId
	Pandu_FAVORITES = {}
	Pandu_Applying = false
	Pandu_RespawnConnection = nil
	Pandu_SelectedFav = nil
	Pandu_FakeThumbUserId = nil
	Pandu_ThumbConn = nil
	Pandu_ThumbPropConns = {}
	Pandu_ThumbUrl = function(p209, p210, p211)
		local v2341 = p210 or 150
		local v2342 = p211 or 150
		return string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=%d&h=%d", tonumber(p209) or 0, v2341, v2342)
	end
	Pandu_ExtractThumbUserId = function(p212)
		if type(p212) ~= "string" or p212 == "" then
			return nil
		end
		return tonumber(p212:match("rbxthumb://[^%s]*id=(%d+)"))
	end
	Pandu_IsAvatarThumb = function(p213)
		if type(p213) == "string" then
			return p213:find("rbxthumb://", 1, true) ~= nil and (p213:find("AvatarHeadShot", 1, true) or p213:find("AvatarBust", 1, true) or p213:find("type=Avatar", 1, true))
		end
		return false
	end
	Pandu_IsOurCurrentThumb = function(p214)
		if not (p214:IsA("ImageLabel") or p214:IsA("ImageButton")) then
			return false
		end
		if p214:GetAttribute("TempoFakeThumb") == true then
			return true
		end
		local v2343 = Pandu_ExtractThumbUserId(p214.Image)
		if v2343 and Pandu_IsAvatarThumb(p214.Image) then
			return v2343 == Pandu_ORIGINAL_ID
		end
		return false
	end
	Pandu_ForceSetThumb = function(p215, p216)
		local n202 = 598972416
		if not p215 or not p216 then
			return
		end
		if not (p215:IsA("ImageLabel") or p215:IsA("ImageButton")) then
			return
		end
		if not Pandu_IsOurCurrentThumb(p215) then
			return
		end
		if not p215:GetAttribute("TempoOrigThumb") then
			p215:SetAttribute("TempoOrigThumb", p215.Image)
		end
		local match, v2346 = tostring(p215.Image):match("w=(%d+).*h=(%d+)")
		local v2347 = Pandu_ThumbUrl(p216, tonumber(match) or 150, tonumber(v2346) or 150)
		p215:SetAttribute("TempoFakeThumb", true)
		local n203 = 445383800
		p215:SetAttribute("TempoFakeThumbId", tonumber(p216))
		if p215.Image ~= v2347 then
			p215.Image = v2347
		end
		if Pandu_ThumbPropConns[p215] then
			return
		end
		local n204
		if n1 == 677870210 then
			Pandu_ThumbPropConns[p215] = p215:GetPropertyChangedSignal("Image"):Connect(function()
				n204 = 65058499
				if not Pandu_FakeThumbUserId or not p215.Parent then
					if Pandu_ThumbPropConns[p215] then
						Pandu_ThumbPropConns[p215]:Disconnect()
						Pandu_ThumbPropConns[p215] = nil
					end
					return
				end
				local v2350 = Pandu_ExtractThumbUserId(p215.Image)
				if v2350 and v2350 ~= Pandu_ORIGINAL_ID and v2350 ~= Pandu_FakeThumbUserId then
					p215:SetAttribute("TempoFakeThumb", nil)
					p215:SetAttribute("TempoFakeThumbId", nil)
					p215:SetAttribute("TempoOrigThumb", nil)
					if Pandu_ThumbPropConns[p215] then
						Pandu_ThumbPropConns[p215]:Disconnect()
						Pandu_ThumbPropConns[p215] = nil
					end
					return
				end
				local match2, v2352 = tostring(p215.Image):match("w=(%d+).*h=(%d+)")
				local v2353 = Pandu_ThumbUrl(Pandu_FakeThumbUserId, tonumber(match2) or 150, tonumber(v2352) or 150)
				if not (n6 < n203) then
					n202 -= 1534
					n203 += 47
					n204 -= 824
					n2 = 778936049
					n6 -= 218
					n5 = 934534959
					(nil)[nil  ] = nil
				elseif p215.Image ~= v2353 then
					p215.Image = v2353
				end
			end)
		else
			n1 += 1777
			n6 += 1412
			n5 += 346
			n4 += 1408
			n7 -= 1255
			local v2354 = n2
			repeat
				v2354 -= 68
				n2 = v2354
			until true
		end
	end
	Pandu_RestoreThumb = function(p217)
		if not p217 then
			return
		end
		if not (p217:IsA("ImageLabel") or p217:IsA("ImageButton")) then
			return
		end
		if p217:GetAttribute("TempoFakeThumb") ~= true then
			return
		end
		local attribute = p217:GetAttribute("TempoOrigThumb")
		p217.Image = type(attribute) == "string" and attribute ~= "" and attribute or Pandu_ThumbUrl(Pandu_ORIGINAL_ID)
		p217:SetAttribute("TempoFakeThumb", nil)
		p217:SetAttribute("TempoFakeThumbId", nil)
		p217:SetAttribute("TempoOrigThumb", nil)
		if Pandu_ThumbPropConns[p217] then
			Pandu_ThumbPropConns[p217]:Disconnect()
			Pandu_ThumbPropConns[p217] = nil
		end
	end
	Pandu_SweepSetThumb = function(p218)
		for _, v in ipairs({
			CoreGui,
			LocalPlayer:FindFirstChild("PlayerGui")
		}) do
			if v then
				for _, descendant in ipairs(v:GetDescendants()) do
					if Pandu_IsOurCurrentThumb(descendant) then
						pcall(Pandu_ForceSetThumb, descendant, p218)
					end
				end
			end
		end
	end
	do
		Pandu_SweepRestoreThumb = function()
			for _, v in ipairs({
				CoreGui,
				LocalPlayer:FindFirstChild("PlayerGui")
			}) do
				if v then
					for _, descendant in ipairs(v:GetDescendants()) do
						pcall(Pandu_RestoreThumb, descendant)
					end
				end
			end
		end
	end
	do
		Pandu_SetFakeDisplayPicture = function(p219)
			local v2364 = tonumber(p219)
			local n205 = 559151600
			if not v2364 then
				return
			end
			Pandu_FakeThumbUserId = v2364
			Pandu_SweepSetThumb(v2364)
			task.delay(0.4, function()
				if Pandu_FakeThumbUserId == v2364 then
					Pandu_SweepSetThumb(v2364)
				end
			end)
			task.delay(1.2, function()
				if Pandu_FakeThumbUserId == v2364 then
					Pandu_SweepSetThumb(v2364)
				end
			end)
			if Pandu_ThumbConn then
				Pandu_ThumbConn:Disconnect()
				Pandu_ThumbConn = nil
			end
			Pandu_ThumbConn = CoreGui.DescendantAdded:Connect(function(descendant)
				if not Pandu_FakeThumbUserId then
					return
				end
				if n6 ~= 295005238 then
					task.defer(function()
						if Pandu_IsOurCurrentThumb(descendant) then
							pcall(Pandu_ForceSetThumb, descendant, Pandu_FakeThumbUserId)
						end
					end)
					return
				end
				n5 -= 858
				n4 = 585020096
				n205 += 1451
				n7 = 411377813
				n6 -= 1645
			end)
		end
	end
	Pandu_ClearFakeDisplayPicture = function()
		Pandu_SweepRestoreThumb()
		task.delay(0.3, Pandu_SweepRestoreThumb)
		Pandu_FakeThumbUserId = nil
		if Pandu_ThumbConn then
			Pandu_ThumbConn:Disconnect()
			Pandu_ThumbConn = nil
		end
		for k, v in pairs(Pandu_ThumbPropConns) do
			pcall(function()
				v:Disconnect()
			end)
			Pandu_ThumbPropConns[k] = nil
		end
	end
	Pandu_FakeDisplayName = nil
	Pandu_OriginalDisplayName = LocalPlayer.DisplayName
	Pandu_NameCharConn = nil
	Pandu_SetCharacterDisplayName = function(p220)
		local Character = LocalPlayer.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		if Humanoid and p220 then
			Humanoid.DisplayName = p220
		end
	end
	do
		Pandu_LooksLikeOurName = function(p221)
			if type(p221) ~= "string" or p221 == "" then
				return false
			end
			return p221 == LocalPlayer.Name or p221 == LocalPlayer.DisplayName or p221 == Pandu_OriginalDisplayName
		end
	end
	do
		local n206
		Pandu_ApplyNameToLabel = function(p222, p223)
			n206 = 985807451
			if not p222 or not p223 then
				return
			end
			if n3 == 660936749 then
				n7 = 53192765
				n6 += 913
				n5 = 887478785
				n4 += 567
				n3 += 1921
				n2 = 210512107
				n206 += 783
			elseif not (p222:IsA("TextLabel") or p222:IsA("TextButton")) then
				return
			end
			if p222:GetAttribute("TempoFakeName") == true or Pandu_LooksLikeOurName(p222.Text) then
				if not p222:GetAttribute("TempoOrigName") then
					p222:SetAttribute("TempoOrigName", p222.Text)
				end
				p222:SetAttribute("TempoFakeName", true)
				p222.Text = p223
			end
		end
	end
	Pandu_RestoreNameLabel = function(p224)
		if not p224 then
			return
		end
		if not (p224:IsA("TextLabel") or p224:IsA("TextButton")) then
			return
		end
		if p224:GetAttribute("TempoFakeName") ~= true then
			return
		end
		local attribute = p224:GetAttribute("TempoOrigName")
		if type(attribute) ~= "string" or attribute == "" then
			p224.Text = Pandu_OriginalDisplayName
		else
			p224.Text = attribute
		end
		p224:SetAttribute("TempoFakeName", nil)
		p224:SetAttribute("TempoOrigName", nil)
		if not (n4 < 997710298) then
			n5 += 1261
			n6 = 190781903
			n4 = 163848897
			n1 += 1682
			n7 = 498269927
			n2 = 583908225
			upv292[nil  ] = nil
		end
	end
	Pandu_SweepNames = function(p225)
		if not p225 then
			return
		end
		for _, v in ipairs({
			CoreGui,
			LocalPlayer:FindFirstChild("PlayerGui")
		}) do
			if v then
				for _, descendant in ipairs(v:GetDescendants()) do
					pcall(Pandu_ApplyNameToLabel, descendant, p225)
				end
			end
		end
		if not (n5 < n1) then
			n3 -= 1672
			n6 += 377
			n5 += 1655
			n7 -= 496
			n2 = 196846158
			n1 = 118388869
			local v2376 = bit32.bxor(nil, nil  )
			;(nil)(nil)
			;(nil)()
			;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, v2376, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 213))
		end
	end
	Pandu_SweepRestoreNames = function()
		for _, v in ipairs({
			CoreGui,
			LocalPlayer:FindFirstChild("PlayerGui")
		}) do
			if v then
				for _, descendant in ipairs(v:GetDescendants()) do
					pcall(Pandu_RestoreNameLabel, descendant)
				end
			end
		end
	end
	do
		Pandu_SetFakeDisplayName = function(p226)
			if not p226 or p226 == "" then
				return
			end
			Pandu_FakeDisplayName = p226
			Pandu_SetCharacterDisplayName(p226)
			Pandu_SweepNames(p226)
			task.delay(0.3, function()
				if Pandu_FakeDisplayName == p226 then
					Pandu_SetCharacterDisplayName(p226)
					Pandu_SweepNames(p226)
				end
			end)
			task.delay(1, function()
				if Pandu_FakeDisplayName == p226 then
					Pandu_SetCharacterDisplayName(p226)
					Pandu_SweepNames(p226)
				end
			end)
			if Pandu_NameCharConn then
				Pandu_NameCharConn:Disconnect()
				Pandu_NameCharConn = nil
			end
			Pandu_NameCharConn = LocalPlayer.CharacterAdded:Connect(function(character)
				task.wait(0.5)
				if Pandu_FakeDisplayName then
					local Humanoid = character:WaitForChild("Humanoid", 5)
					if Humanoid then
						Humanoid.DisplayName = Pandu_FakeDisplayName
					end
				end
			end)
		end
	end
	Pandu_ClearFakeDisplayName = function()
		Pandu_FakeDisplayName = nil
		Pandu_SetCharacterDisplayName(Pandu_OriginalDisplayName)
		Pandu_SweepRestoreNames()
		task.delay(0.3, Pandu_SweepRestoreNames)
		if Pandu_NameCharConn then
			Pandu_NameCharConn:Disconnect()
			Pandu_NameCharConn = nil
		end
	end
	Pandu_LoadAssetKeKarakter = function(p227, p228, p229)
		local t23 = {}
		local u2383
		local u2384
		local u2385
		local u2386
		local n207 = 39081154
		local t24 = {}
		local n208 = 777255576
		local function v2390(p230)
			for _, child in pairs(p230:GetChildren()) do
				if child:IsA("CharacterMesh") then
					table.insert(t23, child)
				elseif child:IsA("BodyColors") then
					u2383 = child
				elseif child:IsA("Shirt") then
					u2384 = child
				elseif child:IsA("Pants") then
					u2385 = child
				elseif child:IsA("ShirtGraphic") then
					u2386 = child
				elseif child:IsA("Accessory") then
					table.insert(t24, child)
				elseif child:IsA("SpecialMesh") then
					table.insert(t23, child)
				elseif child:IsA("Decal") and child.Name == "face" then
					table.insert(t23, child)
				elseif child:IsA("Folder") or child:IsA("Model") then
					v2390(child)
				end
			end
			if n4 < 1029974632 then
				return
			end
			n7 += 1813
			n2 = 239211432
			n208 = 774825081
			n207 -= 1666
			n4 -= 869
			n5 = 807271807
			LPH_CRASH()
		end
		v2390(p227)
		if u2383 then
			local BodyColors = p228:FindFirstChildOfClass("BodyColors") or p228:FindFirstChild("Body Colors")
			if BodyColors then
				BodyColors:Destroy()
			end
			u2383:Clone().Parent = p228
		end
		if u2384 then
			local Shirt = p228:FindFirstChildOfClass("Shirt")
			if Shirt then
				Shirt:Destroy()
			end
			u2384:Clone().Parent = p228
		end
		if u2385 then
			local Pants = p228:FindFirstChildOfClass("Pants")
			if Pants then
				Pants:Destroy()
			end
			u2385:Clone().Parent = p228
		end
		if u2386 then
			local ShirtGraphic = p228:FindFirstChildOfClass("ShirtGraphic")
			if ShirtGraphic then
				ShirtGraphic:Destroy()
			end
			u2386:Clone().Parent = p228
		end
		for _, v in pairs(t23) do
			if v:IsA("CharacterMesh") then
				pcall(function()
					v:Clone().Parent = p228
				end)
			end
		end
		local n209
		if p229 then
			for _, v in pairs(t23) do
				if v:IsA("SpecialMesh") then
					pcall(function()
						local SpecialMesh = p229:FindFirstChildOfClass("SpecialMesh")
						if SpecialMesh then
							SpecialMesh:Destroy()
						end
						v:Clone().Parent = p229
					end)
				elseif v:IsA("Decal") and v.Name == "face" then
					pcall(function()
						n209 = 820873918
						local FindFirstChild = p229.FindFirstChild
						local v2404 = FindFirstChild
						local v2405 = FindFirstChild(p229, "face")
						if 618353271 == n6 then
							n209 += 859
							n207 -= 1694
							n6 = 986177040
							n2 += 552
							n5 = 329966862
							n208 -= 924
							n7 = 458059468
							;(nil)()
							n7[v2404] = nil == nil
							upv94[nil  ] = nil
						elseif v2405 then
							v2405:Destroy()
						end
						v:Clone().Parent = p229
					end)
				end
			end
		end
		if #t24 > 0 then
			task.spawn(function()
				for _, v in pairs(t24) do
					pcall(function()
						local clone = v:Clone()
						local Handle = clone:FindFirstChild("Handle")
						if Handle then
							Handle.CanCollide = false
							Handle.Massless = true
							local Attachment = Handle:FindFirstChildOfClass("Attachment")
							if Attachment then
								local AttachmentName = p228:FindFirstChild(Attachment.Name, true)
								if AttachmentName and AttachmentName.Parent then
									local Weld = Instance.new("Weld")
									Weld.Part0 = Handle
									Weld.Part1 = AttachmentName.Parent
									Weld.C0 = Attachment.CFrame
									Weld.C1 = AttachmentName.CFrame
									Weld.Parent = Handle
								end
							end
							clone.Parent = p228
						else
							clone.Parent = p228
						end
					end)
				end
			end)
		end
	end
	Pandu_ApplyFakeAvaAppearance = function(p231)
		local Character = LocalPlayer.Character
		if not Character or not p231 then
			return false
		end
		local n210 = 1070382110
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			return false
		end
		local n211
		local n212
		local ok, result = pcall(function()
			n211 = 726388533
			n212 = 111246607
			if n212 < n1 then
				return Players:GetCharacterAppearanceAsync(p231)
			end
			n211 -= 1755
			n210 -= 1927
			n7 = 510428647
			n212 += 1954
			n5 = 333968228
			n1 += 815
			local v2420
			;(nil)()
			v2420[247] = nil
			v2420[248] = nil
			v2420[249] = nil
			v2420[250] = nil
			v2420[251] = nil
			v2420[252] = nil
			v2420[253] = nil
			v2420[254] = nil
			v2420[255] = nil
			v2420[256] = nil
			v2420[257] = nil
			v2420[258] = nil
			v2420[259] = nil
			v2420[260] = nil
			v2420[261] = nil
			v2420[262] = nil
			v2420[263] = nil
			v2420[264] = nil
			v2420[265] = nil
			v2420[266] = nil
			v2420[267] = nil
			v2420[268] = nil
			v2420[269] = nil
			v2420[270] = nil
			v2420[271] = nil
			v2420[272] = nil
			v2420[273] = nil
			v2420[274] = nil
			v2420[275] = nil
			v2420[276] = nil
			v2420[277] = nil
			v2420[278] = nil
			v2420[279] = nil
			v2420[280] = nil
			v2420[281] = nil
			v2420[282] = nil
			v2420[283] = nil
			v2420[284] = nil
			v2420[285] = nil
			v2420[286] = nil
			v2420[287] = nil
			v2420[288] = nil
			v2420[289] = nil
			v2420[290] = nil
			v2420[291] = nil
			v2420[292] = nil
			v2420[293] = nil
			v2420[294] = nil
			v2420[295] = nil
			v2420[296] = nil
			v2420[297] = nil
			v2420[298] = nil
			v2420[299] = nil
			v2420[300] = nil
			v2420[301] = nil
			v2420[302] = nil
			v2420[303] = nil
			v2420[304] = nil
			v2420[305] = nil
			v2420[306] = nil
			v2420[307] = nil
			v2420[308] = nil
			v2420[309] = nil
			v2420[310] = nil
			v2420[311] = nil
			v2420[312] = nil
			v2420[313] = nil
			v2420[314] = nil
			v2420[315] = nil
			v2420[316] = nil
			v2420[317] = nil
			v2420[318] = nil
			v2420[319] = nil
			v2420[320] = nil
			v2420[321] = nil
			v2420[322] = nil
			v2420[323] = nil
			v2420[324] = nil
			v2420[325] = nil
			v2420[326] = nil
			v2420[327] = nil
			v2420[328] = nil
			v2420[329] = nil
			v2420[330] = nil
			v2420[331] = nil
			v2420[332] = nil
			v2420[333] = nil
			v2420[334] = nil
			v2420[335] = nil
			v2420[336] = nil
			v2420[337] = nil
			v2420[338] = nil
			v2420[339] = nil
			v2420[340] = nil
			v2420[341] = nil
			v2420[342] = nil
			v2420[343] = nil
			v2420[344] = nil
			v2420[345] = nil
			v2420[346] = nil
			v2420[347] = nil
			v2420[348] = nil
			v2420[349] = nil
			v2420[350] = nil
			v2420[351] = nil
			v2420[352] = nil
			v2420[353] = nil
			v2420[354] = nil
			v2420[355] = nil
			v2420[356] = nil
			v2420[357] = nil
			v2420[358] = nil
			v2420[359] = nil
			v2420[360] = nil
			v2420[361] = nil
			v2420[362] = nil
			v2420[363] = nil
			v2420[364] = nil
			v2420[365] = nil
			v2420[366] = nil
			v2420[367] = nil
			v2420[368] = nil
			v2420[369] = nil
			v2420[370] = nil
			v2420[371] = nil
			v2420[372] = nil
			v2420[373] = nil
			v2420[374] = nil
			v2420[375] = nil
			v2420[376] = nil
			v2420[377] = nil
			v2420[378] = nil
			v2420[379] = nil
			v2420[380] = nil
			v2420[381] = nil
			v2420[382] = nil
			v2420[383] = nil
			v2420[384] = nil
			v2420[385] = nil
			v2420[386] = nil
			v2420[387] = nil
			v2420[388] = nil
			v2420[389] = nil
			v2420[390] = nil
			v2420[391] = nil
			v2420[392] = nil
			v2420[393] = nil
			v2420[394] = nil
			v2420[395] = nil
			v2420[396] = nil
		end)
		if not ok or not result then
			lib2:Notify({
				Title = "Error",
				Description = "Couldn't load the appearance",
				Duration = 3
			})
			return false
		end
		for _, child in pairs(Character:GetChildren()) do
			if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") or child.Name == "Body Colors" then
				child:Destroy()
			end
		end
		local Head = Character:FindFirstChild("Head")
		if Head then
			local SpecialMesh = Head:FindFirstChildOfClass("SpecialMesh")
			if SpecialMesh then
				SpecialMesh:Destroy()
			end
			local face = Head:FindFirstChild("face")
			if face then
				face:Destroy()
			end
		end
		local v2426
		local ok2, result2 = pcall(function()
			return Players:GetCharacterAppearanceInfoAsync(p231)
		end)
		if ok2 and result2 then
			v2426 = result2
		end
		if v2426 and v2426.scales then
			for k, scale in pairs(v2426.scales) do
				local NumberValue = Humanoid:FindFirstChild(k)
				if not NumberValue then
					NumberValue = Instance.new("NumberValue")
					NumberValue.Name = k
					NumberValue.Parent = Humanoid
				end
				NumberValue.Value = scale
			end
		end
		task.wait(0.2)
		Pandu_LoadAssetKeKarakter(result, Character, Head)
		if v2426 and v2426.assets and Head then
			task.spawn(function()
				for _, asset in pairs(v2426.assets) do
					if asset.assetType then
						if asset.assetType.name == "Face" then
							local face = Head:FindFirstChild("face")
							if face then
								face:Destroy()
							end
							pcall(function()
								local Decal = Instance.new("Decal")
								Decal.Name = "face"
								Decal.Texture = "rbxassetid://" .. asset.id
								Decal.Face = Enum.NormalId.Front
								Decal.Parent = Head
							end)
							break
						end
					end
				end
			end)
		end
		pcall(function()
			result:Destroy()
		end)
		return true
	end
	Pandu_ResolveUser = function(p232)
		local v2436 = tostring(p232):gsub("%s+", ""):gsub("^@", "")
		local v2437 = tonumber(v2436)
		if v2437 then
			local ok, result = pcall(function()
				return Players:GetNameFromUserIdAsync(v2437)
			end)
			if ok and result then
				return v2437, result
			end
		else
			local ok, result = pcall(function()
				return Players:GetUserIdFromNameAsync(v2436)
			end)
			if ok and result then
				local ok2, result2 = pcall(function()
					return Players:GetNameFromUserIdAsync(result)
				end)
				if ok2 and result2 then
					return result, result2
				end
			end
		end
		return nil, nil
	end
	do
		Pandu_ApplyAvatar = function(p233)
			if Pandu_Applying then
				return
			end
			Pandu_Applying = true
			task.spawn(function()
				local v2444, v2445 = Pandu_ResolveUser(p233)
				if not v2444 then
					lib2:Notify({
						Title = "Error",
						Description = "User not found",
						Duration = 3
					})
					Pandu_Applying = false
					return
				end
				Pandu_CURRENT_AVATAR = {
					id = v2444,
					name = v2445
				}
				if Pandu_RespawnConnection then
					Pandu_RespawnConnection:Disconnect()
					Pandu_RespawnConnection = nil
				end
				local v2446 = false
				if LocalPlayer.Character then
					v2446 = Pandu_ApplyFakeAvaAppearance(v2444)
				end
				Pandu_SetFakeDisplayPicture(v2444)
				Pandu_SetFakeDisplayName(v2445)
				Pandu_RespawnConnection = LocalPlayer.CharacterAdded:Connect(function()
					task.wait(1)
					if Pandu_CURRENT_AVATAR then
						Pandu_ApplyFakeAvaAppearance(Pandu_CURRENT_AVATAR.id)
						Pandu_SetFakeDisplayPicture(Pandu_CURRENT_AVATAR.id)
						Pandu_SetFakeDisplayName(Pandu_CURRENT_AVATAR.name)
					end
				end)
				lib2:Notify({
					Title = "Copy Avatar",
					Description = v2446 and "Copied " .. v2445 or "Couldn't apply " .. v2445,
					Duration = 3
				})
				Pandu_Applying = false
			end)
		end
	end
	Pandu_LoadFavorites = function()
		Pandu_FAVORITES = {}
		pcall(function()
			if not isfolder("TempoCopyAvatar") then
				makefolder("TempoCopyAvatar")
			end
			if isfile("TempoCopyAvatar/favorites.json") then
				Pandu_FAVORITES = HttpService:JSONDecode(readfile("TempoCopyAvatar/favorites.json"))
			end
		end)
	end
	Pandu_SaveFavorites = function()
		pcall(function()
			if not isfolder("TempoCopyAvatar") then
				makefolder("TempoCopyAvatar")
			end
			writefile("TempoCopyAvatar/favorites.json", HttpService:JSONEncode(Pandu_FAVORITES))
		end)
	end
	Pandu_LoadFavorites()
	Pandu_ResetAvatar = function()
		Pandu_CURRENT_AVATAR = nil
		if Pandu_RespawnConnection then
			Pandu_RespawnConnection:Disconnect()
			Pandu_RespawnConnection = nil
		end
		Pandu_ClearFakeDisplayPicture()
		Pandu_ClearFakeDisplayName()
		local n213
		task.spawn(function()
			n213 = 373529332
			local v2448 = Pandu_ApplyFakeAvaAppearance(Pandu_ORIGINAL_ID)
			lib2:Notify({
				Title = "Reset Avatar",
				Description = v2448 and "Avatar direset" or "Couldn't reset",
				Duration = 3
			})
			if n3 ~= n1 then
				return
			end
			n213 += 927
			n5 = 819112004
			n3 += 1830
			n7 -= 1775
			n1 += 588
			return (nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil   / nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 405))
		end)
	end
	Pandu_AvatarList = {
		"Self Avatar",
		"Random 1",
		"Random 2",
		"Random 3",
		"Random 4",
		"Random 5",
		"Random 6",
		"Random 7",
		"WoozyNate",
		"Nicholas",
		"yvlyf",
		"traevp",
		"J0LLY",
		"LucashDev",
		"CEOofIsaac",
		"Stealthy",
		"Wildes",
		"Talon",
		"Relukt",
		"Sammy",
		"Diesel",
		"S4ans03",
		"Aura",
		"iJava",
		"White Guy",
		"Purple King",
		"Mpruyyy"
	}
	Pandu_AvatarIDs = {
		["Self Avatar"] = LocalPlayer.UserId,
		["Random 1"] = 2888298851,
		["Random 2"] = 10074747755,
		["Random 3"] = 5209567453,
		["Random 4"] = 8991982843,
		["Random 5"] = 5796319029,
		["Random 6"] = 9744452117,
		["Random 7"] = 8476755006,
		WoozyNate = 146089324,
		Nicholas = 909635,
		yvlyf = 181751703,
		traevp = 471607078,
		J0LLY = 1073847038,
		LucashDev = 2525651744,
		CEOofIsaac = 63238912,
		Stealthy = 56602747,
		Wildes = 40397833,
		Talon = 75974130,
		Relukt = 65042011,
		Sammy = 2678001507,
		Diesel = 9123921576,
		S4ans03 = 35439794,
		Aura = 2275806428,
		iJava = 276557820,
		["White Guy"] = 8843268357,
		["Purple King"] = 9070758608,
		Mpruyyy = 8340163775
	}
	do
		Pandu_GetFavoritesList = function()
			local t25 = {}
			for _, v in ipairs(Pandu_FAVORITES) do
				table.insert(t25, v.name)
			end
			return t25
		end
	end
	Pandu_SelectedAvatarOption = "Self Avatar"
	FakeAvatarSection:AddDropdown("Pick Avatar", Pandu_AvatarList, false, function(p234)
		Pandu_SelectedAvatarOption = p234
	end)
	Pandu_UsernameInput = ""
	do
		FakeAvatarSection:AddTextbox("Username / ID", "Enter a username or ID...", function(p235)
			Pandu_UsernameInput = p235:gsub("^@", "")
		end)
	end
	do
		FakeAvatarSection:AddButton("Apply Avatar", function()
			if Pandu_UsernameInput == "" then
				if not Pandu_SelectedAvatarOption or Pandu_SelectedAvatarOption == "" then
					lib2:Notify({
						Title = "Error",
						Description = "Pick an avatar or enter a username!",
						Duration = 3
					})
				else
					local v2452 = Pandu_AvatarIDs[Pandu_SelectedAvatarOption]
					if v2452 then
						Pandu_ApplyAvatar(v2452)
					else
						lib2:Notify({
							Title = "Error",
							Description = "Pick an avatar or enter a username!",
							Duration = 3
						})
					end
				end
			else
				Pandu_ApplyAvatar(Pandu_UsernameInput)
			end
		end)
	end
	FakeAvatarSection:AddButton("Random Avatar", function()
		Pandu_ApplyAvatar(Pandu_RANDOM_IDS[math.random(1, #Pandu_RANDOM_IDS)])
	end)
	FakeAvatarSection:AddButton("Reset Avatar", function()
		Pandu_ResetAvatar()
	end)
	FakeAvatarSection:AddButton("Add to Favorite", function()
		if not Pandu_CURRENT_AVATAR then
			lib2:Notify({
				Title = "Error",
				Description = "No avatar",
				Duration = 3
			})
			return
		end
		local n214 = 652882442
		for _, v in ipairs(Pandu_FAVORITES) do
			if tonumber(v.id) == tonumber(Pandu_CURRENT_AVATAR.id) then
				lib2:Notify({
					Title = "Info",
					Description = "Already in favorites",
					Duration = 2
				})
				return
			end
		end
		table.insert(Pandu_FAVORITES, {
			id = Pandu_CURRENT_AVATAR.id,
			name = Pandu_CURRENT_AVATAR.name
		})
		Pandu_SaveFavorites()
		Pandu_FavDropdown.SetValues(Pandu_GetFavoritesList())
		if n214 ~= n1 then
			lib2:Notify({
				Title = "Favorite",
				Description = "Added to favorites",
				Duration = 2
			})
			return
		end
		n1 = 763199966
		n5 += 263
		n7 = 13029210
		n6 -= 867
		n3 += 462
		n4 += 1771
		return (nil)()
	end)
	Pandu_FavDropdown = FakeAvatarSection:AddDropdown("Favorites", Pandu_GetFavoritesList(), false, function(p236)
		for _, v in ipairs(Pandu_FAVORITES) do
			if v.name == p236 then
				Pandu_SelectedFav = v.id
				Pandu_ApplyAvatar(v.id)
				break
			end
		end
	end)
	FakeAvatarSection:AddButton("Delete Favorite", function()
		if not Pandu_SelectedFav then
			lib2:Notify({
				Title = "Error",
				Description = "Pick a favorite first",
				Duration = 3
			})
			return
		end
		for i, v in ipairs(Pandu_FAVORITES) do
			if tonumber(v.id) == tonumber(Pandu_SelectedFav) then
				table.remove(Pandu_FAVORITES, i)
				break
			end
		end
		Pandu_SaveFavorites()
		Pandu_FavDropdown.SetValues(Pandu_GetFavoritesList())
		Pandu_SelectedFav = nil
		if n1 == 677870210 then
			lib2:Notify({
				Title = "Favorite",
				Description = "Favorite dihapus",
				Duration = 2
			})
		else
			n2 = 978736690
			n7 = 978962609
			n6 -= 1493
			n5 += 64
			n1 = 286855119
			n3 = 412749044
		end
	end)
	LocalPlayer.CharacterAdded:Connect(function()
		task.wait(1)
		if Pandu_CURRENT_AVATAR then
			Pandu_ApplyFakeAvaAppearance(Pandu_CURRENT_AVATAR.id)
			Pandu_SetFakeDisplayPicture(Pandu_CURRENT_AVATAR.id)
			Pandu_SetFakeDisplayName(Pandu_CURRENT_AVATAR.name)
		end
	end)
	SurvivorTab = v14:CreateTab("Survivor", false, false)
	S_Page = SurvivorTab:CreatePage("Survivor")
	GenCard = S_Page:CreateSection("Generator Settings", "plug-zap")
	SkillCheckToggle = GenCard:AddToggle("Auto Skill Check", false, function(p237)
		_G.Ox.Auto.SkillCheck = p237
		if p237 then
			v787()
		elseif _G.Ox.Connections.SkillHeartbeat then
			_G.Ox.Connections.SkillHeartbeat:Disconnect()
			_G.Ox.Connections.SkillHeartbeat = nil
		end
	end, {
		Flag = "AutoSkillCheck"
	})
	SkillCheckToggle:AddKeyPicker("None")
	GenCard:AddDropdown("Skill Check Mode", {
		"Legit",
		"Instant",
		"Normal",
		"Random"
	}, false, function(p238)
		_G.Ox.Auto.SkillCheckMode = p238
		_G.Ox.State.RandomMode_IsNormal = false
		if n6 == n7 then
			n3 = 785463760
			n6 = 38968733
			n5 = 378047484
			n7 = 926106926
			n1 += 1451
			n2 = 253968344
			;(nil)[nil] = nil
			upv369[nil  ] = nil
		end
	end, {
		Flag = "SkillCheckMode"
	})
	GenCard:AddDropdown("Gen Boost Mode", {
		"Manual Repair",
		"Auto Repair"
	}, false, function(p239)
		_G.Ox.BypassGenMode = p239
	end, {
		Flag = "GenBoostMode"
	})
	GenBoostToggle = GenCard:AddToggle("Gen Boost (Multi-Repair)", false, function(p240)
		_G.Ox.BypassToggleValue = p240
		_G.Ox.BypassGenEnabled = p240
		local n215 = 449506875
		_G.Ox.BypassButton.Visible = p240 and UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		if not p240 then
			_G.Ox.ProcessedGens = {}
			_G.Ox.AutoRepairEnabled = false
			_G.Ox.AutoCurrentGenModel = nil
			if _G.Ox.AutoRepairThread then
				task.cancel(_G.Ox.AutoRepairThread)
				_G.Ox.AutoRepairThread = nil
			end
			_G.Ox.StopAutoRepair()
		end
		local n216 = 930082334
		if not (n6 < n215) then
			n4 = 720723652
			local v2462 = n216 - 1644
			n7 += 1946
			n5 = 982044845
			n1 -= 1740
			local v2463 = n215 + 224
			n3 -= 2036
			n6 += 1363
			while true do
				if v2462.Ox.AutoRepairThread then
					task.cancel(_G.Ox.AutoRepairThread)
					_G.Ox.AutoRepairThread = nil
				end
				_G.Ox.StopAutoRepair()
				local n217 = 930082334
				if n6 < v2463 then
					break
				end
				n4 = 720723652
				v2462 = n217 - 1644
				n7 += 1946
				n5 = 982044845
				n1 -= 1740
				v2463 += 224
				n3 -= 2036
				n6 += 1363
			end
		end
	end, {
		Flag = "GenBoost"
	})
	GenBoostToggle:AddKeyPicker("None")
	do
		local n218
		local Fire = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items")["Twist of Fate"].Fire
		local u2467 = false
		local u2468 = false
		local u2469 = true
		local u2470 = false
		local u2471 = false
		local connection
		local Part
		local s5 = "Killer"
		UDim2.new(0.5, -120, 0, 110)
		local t26 = {}
		local t27 = {
			PredictionEfficiency = 0.85,
			LerpSmoothness = 0.4,
			EnableJitter = false,
			MaxJitterStuds = 0
		}
		getGunObject = function()
			local Character = v18.Character
			if not Character then
				return nil
			end
			local TwistOfFate = Character:FindFirstChild("Twist of Fate", true)
			if not TwistOfFate then
				return nil
			end
			local RightArm = TwistOfFate:FindFirstChild("Right Arm")
			if RightArm then
				local gun = RightArm:FindFirstChild("gun")
				if gun then
					return gun
				end
				local EmperorGun = RightArm:FindFirstChild("EmperorGun")
				if EmperorGun then
					return EmperorGun
				end
			end
			return TwistOfFate
		end
		isTargetVisible = function(p241, p242, p243)
			local v2482 = p242 - p241
			local Magnitude = v2482.Magnitude
			if Magnitude < 0.1 then
				return true
			end
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local filterDescendantsInstances = {}
			local Character = v18.Character
			if Character then
				table.insert(filterDescendantsInstances, Character)
			end
			if p243 and p243 ~= Character then
				table.insert(filterDescendantsInstances, p243)
			end
			if Part then
				table.insert(filterDescendantsInstances, Part)
			end
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			return workspace:Raycast(p241, v2482.Unit * Magnitude, raycastParams) == nil
		end
		local t28 = {}
		local n219 = 0
		GetSCPs = function()
			if tick() - n219 < 0.5 then
				return t28
			end
			local t29 = {}
			local Map = workspace:FindFirstChild("Map")
			if Map then
				for _, descendant in pairs(Map:GetDescendants()) do
					if descendant:IsA("Model") then
						local attributes = descendant:GetAttributes()
						if descendant:GetAttribute("CorpseCreated0492") or next(attributes) ~= nil then
							local HumanoidRootPart = descendant:FindFirstChild("HumanoidRootPart")
							if HumanoidRootPart then
								table.insert(t29, HumanoidRootPart)
							end
						end
					end
				end
			end
			t28 = t29
			n219 = tick()
			return t28
		end
		local function v2495(p244)
			local HumanoidRootPart = p244:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then
				return Vector3.zero
			end
			local Position = HumanoidRootPart.Position
			local v2498 = t26[p244]
			if v2498 then
				local v2499 = tick() - v2498.time
				if v2499 > 0.001 and v2499 < 0.1 then
					local v2500 = v2498.vel:Lerp((Position - v2498.pos) / v2499, t27.LerpSmoothness)
					t26[p244] = {
						pos = Position,
						vel = v2500,
						time = tick()
					}
					return v2500
				end
			end
			t26[p244] = {
				pos = Position,
				vel = HumanoidRootPart.Velocity,
				time = tick()
			}
			return HumanoidRootPart.Velocity
		end
		local function v2501(p245, p246, p247, p248)
			local v2502 = p248 or 500
			local Position = p246.Position
			if (Position - p245).Magnitude < 8 then
				return Position
			end
			local v2504 = v2495(p247)
			local v2505 = Position - p245
			local v2506 = v2504:Dot(v2504) - v2502 * v2502
			local v2507 = 2 * v2505:Dot(v2504)
			local v2508 = v2505:Dot(v2505)
			local v2509
			if not (math.abs(v2506) < 0.01) then
				local v2510 = v2507 * v2507 - 4 * v2506 * v2508
				if v2510 >= 0 then
					local v2511 = math.sqrt(v2510)
					local v2512 = (-v2507 - v2511) / (2 * v2506)
					local v2513 = (-v2507 + v2511) / (2 * v2506)
					if v2512 > 0.001 then
						v2509 = v2512
					elseif v2513 > 0.001 then
						v2509 = v2513
					end
				end
			elseif math.abs(v2507) > 0.01 then
				v2509 = -v2508 / v2507
			end
			local v2514 = Position
			if v2509 then
				v2514 = Position + v2504 * t27.PredictionEfficiency * v2509
				if t27.EnableJitter then
					v2514 += Vector3.new((math.random() - 0.5) * t27.MaxJitterStuds, (math.random() - 0.5) * (t27.MaxJitterStuds / 2), (math.random() - 0.5) * t27.MaxJitterStuds)
				end
			end
			return v2514
		end
		getTargetPosition = function()
			local v2515 = getGunObject()
			local Character = v18.Character
			if not v2515 or not Character then
				return nil, nil, nil, nil
			end
			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
			if not HumanoidRootPart then
				return nil, nil, nil, nil
			end
			local Position = HumanoidRootPart.Position
			local u2519
			if Character:GetAttribute("IsCarried") then
				u2519 = Character.HumanoidRootPart.Position + Character.HumanoidRootPart.CFrame.LookVector * 2
			else
				pcall(function()
					u2519 = v2515:IsA("BasePart") and v2515.Position or v2515:FindFirstChildOfClass("BasePart") and v2515:FindFirstChildOfClass("BasePart").Position
				end)
				u2519 = u2519 or Vector3.new(Position.X, Position.Y + 1.5, Position.Z)
			end
			local function v2520(p249, p250)
				local Position2 = p249.Position
				if u2470 and not isTargetVisible(u2519, Position2, p250) then
					return nil, nil, nil, nil
				end
				local v2522 = getGunObject()
				local Position3 = u2519
				pcall(function()
					if v2522 and v2522:IsA("BasePart") then
						Position3 = v2522.Position
					elseif v2522 then
						local BasePart = v2522:FindFirstChildOfClass("BasePart")
						if BasePart then
							Position3 = BasePart.Position
						end
					end
				end)
				if (Position2 - Position3).Magnitude < 8 then
					return (Position2 - Position3).Unit, v2522, Position3, Position2
				end
				if not u2468 then
					return (Position2 - Position3).Unit, v2522, Position3, Position2
				end
				local v2525 = v2501(Position3, p249, p250, 500)
				return (v2525 - Position3).Unit, v2522, Position3, v2525
			end
			if s5 == "Killer" then
				local v2526
				local Character2
				local huge = math.huge
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= v18 then
						if player.Team and player.Team.Name == "Killer" and player.Character then
							local Torso = player.Character:FindFirstChild("Torso")
							if Torso then
								local Magnitude = (Position - Torso.Position).Magnitude
								if Magnitude < huge then
									huge = Magnitude
									v2526 = Torso
									Character2 = player.Character
								end
							end
						end
					end
				end
				if v2526 then
					return v2520(v2526, Character2)
				end
				return nil, nil, nil, nil
			end
			if s5 == "Survivors" then
				local v2533
				local Character2
				local v2535 = -math.huge
				local CurrentCamera = workspace.CurrentCamera
				local LookVector = CurrentCamera.CFrame.LookVector
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= v18 and player.Team and player.Team.Name == "Survivors" and player.Character then
						local Torso = player.Character:FindFirstChild("Torso")
						if Torso then
							local v2541 = LookVector:Dot((Torso.Position - CurrentCamera.CFrame.Position).Unit)
							if v2541 > 0.5 and v2535 < v2541 then
								v2535 = v2541
								v2533 = Torso
								Character2 = player.Character
							end
						end
					end
				end
				if v2533 then
					return v2520(v2533, Character2)
				end
				return nil, nil, nil, nil
			end
			if s5 ~= "Zombie" then
				return nil, nil, nil, nil
			end
			local v2542 = GetSCPs()
			local v2543
			local v2544 = -math.huge
			local LookVector = workspace.CurrentCamera.CFrame.LookVector
			for _, v in ipairs(v2542) do
				if v and v.Parent then
					local v2548 = LookVector:Dot((v.Position - workspace.CurrentCamera.CFrame.Position).Unit)
					if v2548 > 0.5 and v2544 < v2548 then
						v2544 = v2548
						v2543 = v
					end
				end
			end
			if v2543 then
				return v2520(v2543, v2543.Parent)
			end
			return nil, nil, nil, nil
		end
		updateLaser = function(p251, p252)
			if not Part then
				Part = Instance.new("Part")
				Part.Name = "ToFLaser"
				Part.Anchored = true
				Part.CanCollide = false
				Part.CanTouch = false
				Part.CastShadow = false
				Part.Material = Enum.Material.Neon
				Part.Color = Color3.fromRGB(255, 50, 50)
				Part.Parent = workspace
			end
			Part.Size = Vector3.new(0.05, 0.05, (p252 - p251).Magnitude)
			Part.CFrame = CFrame.new((p251 + p252) / 2, p252)
			Part.Transparency = 0
		end
		clearLaser = function()
			if Part then
				Part:Destroy()
				Part = nil
			end
		end
		local t30 = {}
		local function v2550()
			local attribute = v18:GetAttribute("EquippedSkin_Twist_of_Fate") or ""
			if attribute:find("AWP") or attribute:find("Awp") or attribute:find("awp") then
				return "rbxassetid://119691839016468"
			end
			if attribute:find("SCP") or attribute:find("3108") then
				return "rbxassetid://116394362601423"
			end
			return "rbxassetid://124735239320776"
		end
		local function v2552()
			for _, v in ipairs(t30) do
				v:Disconnect()
			end
			t30 = {}
			local Character = v18.Character
			if not Character then
				return
			end
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			local Animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
			if not Animator then
				return
			end
			local function v2558()
				return Character:GetAttribute("IsCarried") or Character:GetAttribute("Knocked")
			end
			local function v2559()
				return {
					[v2550()] = true,
					["rbxassetid://111824163160605"] = true,
					["rbxassetid://72749744367268"] = true
				}
			end
			table.insert(t30, Animator.AnimationPlayed:Connect(function(p253)
				if not v2558() then
					return
				end
				if not p253.Animation then
					return
				end
				if v2559()[p253.Animation.AnimationId] then
					p253:Stop(0)
				end
			end))
			table.insert(t30, Character:GetAttributeChangedSignal("IsCarried"):Connect(function()
				if not v2558() then
					return
				end
				local v2560 = v2559()
				for _, v in ipairs(Animator:GetPlayingAnimationTracks()) do
					if v.Animation and v2560[v.Animation.AnimationId] then
						v:Stop(0)
					end
				end
			end))
			table.insert(t30, Character:GetAttributeChangedSignal("Knocked"):Connect(function()
				if not v2558() then
					return
				end
				local v2563 = v2559()
				for _, v in ipairs(Animator:GetPlayingAnimationTracks()) do
					if v.Animation then
						if v2563[v.Animation.AnimationId] then
							v:Stop(0)
						end
					end
				end
			end))
		end
		task.defer(v2552)
		v18.CharacterAdded:Connect(function()
			task.defer(function()
				task.wait(0.25)
				v2552()
			end)
		end)
		doShoot = function()
			if not u2467 or not u2471 then
				return
			end
			local Character = v18.Character
			if Character and _G.Ox.AimConfig.Pistol_BlockKnocked and IsDowned(Character) then
				return
			end
			local v2567, v2568, v2569, v2570 = getTargetPosition()
			if not v2567 or not v2568 or not v2570 or not v2569 then
				return
			end
			local Unit = (v2570 - v2569).Unit
			pcall(function()
				Fire:FireServer(v2568, Unit)
			end)
		end
		startConnection = function()
			if connection then
				return
			end
			local n220 = 54751205
			local n221 = 82521192
			local n222
			connection = RunService.Heartbeat:Connect(function()
				n222 = 609372171
				if u2471 and u2467 then
					local v2575, v2576, v2577, v2578 = getTargetPosition()
					if v2575 and v2576 and v2578 then
						pcall(function()
							local Character = v18.Character
							local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
							if HumanoidRootPart then
								if not Character:GetAttribute("IsCarried") then
									HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, Vector3.new(v2578.X, HumanoidRootPart.Position.Y, v2578.Z))
								end
							end
						end)
						if not (n220 < n2) then
							n3 = 557739282
							n2 = 131177462
							n5 = 424388699
							n220 -= 1389
							n221 += 1221
							n222 -= 1588
							;(nil)()
						elseif _G.Ox.AimConfig.LockAim then
							workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, v2578), 0.15)
						end
						if u2469 and v2577 then
							updateLaser(v2577, v2578)
						end
					elseif Part then
						Part.Transparency = 1
					end
				elseif Part then
					Part.Transparency = 1
				end
			end)
		end
		stopConnection = function()
			if connection then
				connection:Disconnect()
				connection = nil
			end
			clearLaser()
			if n2 == 352572318 then
				return
			end
			n7 = 355491744
			local v2581 = n4
			repeat
				n4 = v2581 + 386
				n1 = 846116497
				n2 = 280902072
				n3 -= 955
				v2581 = n5 - 1596
				n5 = v2581
			until nil <= nil
			return (nil)(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
		end
		local uDim2 = UDim2.new(0.5, -82, 0, 30)
		local u2583
		local connection2
		local t31 = {
			{
				internal = "Killer",
				display = "Killer (K)",
				activeColor = Color3.fromRGB(180, 45, 45),
				activeTxt = Color3.fromRGB(255, 180, 180)
			},
			{
				internal = "Survivors",
				display = "Survivors (J)",
				activeColor = Color3.fromRGB(25, 80, 150),
				activeTxt = Color3.fromRGB(160, 210, 255)
			},
			{
				internal = "Zombie",
				display = "Zombie (L)",
				activeColor = Color3.fromRGB(120, 80, 10),
				activeTxt = Color3.fromRGB(255, 210, 100)
			}
		}
		createTargetSelectorUI = function()
			local v2586 = CoreGui
			if not v2586 then
				return
			end
			if u2583 and u2583.Parent then
				return
			end
			local ToFTargetSelector = v2586:FindFirstChild("ToFTargetSelector")
			if ToFTargetSelector then
				ToFTargetSelector:Destroy()
			end
			local ScreenGui = Instance.new("ScreenGui")
			ScreenGui.Name = "ToFTargetSelector"
			ScreenGui.ResetOnSpawn = false
			ScreenGui.IgnoreGuiInset = true
			ScreenGui.Parent = v2586
			local Frame = Instance.new("Frame")
			Frame.Name = "Main"
			Frame.Size = UDim2.new(0, 165, 0, 32)
			Frame.Position = uDim2
			Frame.BackgroundTransparency = 1
			Frame.Active = true
			Frame.Parent = ScreenGui
			local visible = false
			local TextButton = Instance.new("TextButton")
			TextButton.Size = UDim2.new(1, 0, 1, 0)
			TextButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
			TextButton.BackgroundTransparency = 0.25
			TextButton.BorderSizePixel = 0
			TextButton.Font = Enum.Font.GothamBold
			local n223 = 1657648
			TextButton.TextSize = 11
			TextButton.TextColor3 = Color3.fromRGB(240, 240, 240)
			TextButton.Parent = Frame
			Instance.new("UICorner", TextButton).CornerRadius = UDim.new(0, 8)
			local UIStroke = Instance.new("UIStroke", TextButton)
			UIStroke.Color = Color3.fromRGB(100, 100, 110)
			UIStroke.Thickness = 1.2
			UIStroke.Transparency = 0.3
			local Frame2 = Instance.new("Frame")
			Frame2.Size = UDim2.new(1, 0, 0, 0)
			Frame2.Position = UDim2.new(0, 0, 1, 5)
			Frame2.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
			Frame2.BackgroundTransparency = 0.25
			Frame2.BorderSizePixel = 0
			Frame2.ClipsDescendants = true
			local n224 = 994823830
			Frame2.Visible = false
			Frame2.AutomaticSize = Enum.AutomaticSize.Y
			Frame2.Parent = Frame
			Instance.new("UICorner", Frame2).CornerRadius = UDim.new(0, 8)
			local UIStroke2 = Instance.new("UIStroke", Frame2)
			UIStroke2.Color = Color3.fromRGB(80, 80, 90)
			UIStroke2.Thickness = 1.2
			UIStroke2.Transparency = 0.4
			local UIListLayout = Instance.new("UIListLayout", Frame2)
			UIListLayout.FillDirection = Enum.FillDirection.Vertical
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Padding = UDim.new(0, 4)
			local UIPadding = Instance.new("UIPadding", Frame2)
			UIPadding.PaddingTop = UDim.new(0, 4)
			UIPadding.PaddingBottom = UDim.new(0, 4)
			UIPadding.PaddingLeft = UDim.new(0, 4)
			UIPadding.PaddingRight = UDim.new(0, 4)
			local t32 = {}
			local function v2600()
				local s6 = "Unknown"
				local n225 = 384614245
				local v2603, v2604, v2605 = ipairs(t31)
				local v2606 = geniter(v2603, v2604, v2605)
				while true do
					local v2607 = table.pack(v2606())
					if not v2607[1] then
						break
					end
					local v2608 = v2607[3]
					if v2608.internal == s5 then
						s6 = v2608.internal
						break
					end
				end
				local n226 = 925685597
				TextButton.Text = string.format("Target: %s   %s", s6, visible and "v" or ">")
				local n227 = 824040503
				Frame2.Visible = visible
				local v2611, v2612, v2613 = ipairs(t31)
				for _, v in v2611, v2612, v2613 do
					local v2616 = t32[v.internal]
					if v2616 then
						if v.internal == s5 then
							v2616.BackgroundColor3 = v.activeColor
							v2616.TextColor3 = v.activeTxt
						else
							if n4 < n227 then
								v2616.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
							else
								n227 = 875647384
								n225 += 1475
								n223 = 431272044
								n226 += 1789
								n4 -= 518
								n7 += 25
								n2 = 607139347
								n224 = 720064220
								n5 += 1630
							end
							v2616.TextColor3 = Color3.fromRGB(150, 150, 150)
						end
					end
				end
			end
			local v2617
			for i, v in ipairs(t31) do
				local v2620 = t51_285_1[2]
				local v2621 = t51_285_1[1]
				local TextButton2 = Instance.new("TextButton")
				TextButton2.Size = UDim2.new(1, 0, 0, 26)
				TextButton2.BorderSizePixel = 0
				TextButton2.Font = Enum.Font.GothamBold
				TextButton2.TextSize = 10
				TextButton2.Text = v.display
				if n2 == n4 then
					n1 = 448577914
					n7 = 231320829
					n223 -= 468
					n6 = 186469725
					n5 -= 731
					n224 = 424230128
					n2 = 739182346
					n4 += 358
					v2621[v2620] = n4
					v2617 = v2617()
					v2620[38]()
				else
					TextButton2.LayoutOrder = i
				end
				TextButton2.Parent = Frame2
				Instance.new("UICorner", TextButton2).CornerRadius = UDim.new(0, 6)
				local function v2623()
					while true do
						s5 = v.internal
						visible = false
						v2600()
						if n223 < n224 then
							break
						else
							n6 = 168234648
							n2 = 1050747878
							n224 += 426
							n223 = 807254145
							n5 = 369436903
							n1 = 479614054
							if true then
								break
							end
						end
					end
				end
				TextButton2.MouseButton1Click:Connect(v2623)
				TextButton2.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch then
						v2623()
					end
				end)
				t32[v.internal] = TextButton2
			end
			v2600()
			local u2624 = false
			local u2625 = false
			local u2626
			local Position
			local Position2
			TextButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					u2624 = true
					u2625 = false
					u2626 = input
					Position = input.Position
					Position2 = Frame.Position
				end
			end)
			TextButton.InputEnded:Connect(function(input)
				if input == u2626 then
					u2624 = false
					if not u2625 then
						visible = not visible
						v2600()
					end
					u2626 = nil
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if not u2624 then
					return
				end
				local v2629 = false
				if input.UserInputType == Enum.UserInputType.Touch and input == u2626 then
					v2629 = true
				elseif input.UserInputType == Enum.UserInputType.MouseMovement and u2626.UserInputType == Enum.UserInputType.MouseButton1 then
					v2629 = true
				end
				if v2629 then
					local v2630 = input.Position - Position
					if math.abs(v2630.X) > 4 or math.abs(v2630.Y) > 4 then
						u2625 = true
					end
					if u2625 then
						local uDim22 = UDim2.new(Position2.X.Scale, Position2.X.Offset + v2630.X, Position2.Y.Scale, Position2.Y.Offset + v2630.Y)
						Frame.Position = uDim22
						uDim2 = uDim22
					end
				end
			end)
			if connection2 then
				connection2:Disconnect()
				connection2 = nil
			end
			connection2 = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				local n228 = 549724562
				if not u2467 then
					return
				end
				if gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
					return
				end
				local s7
				if input.KeyCode == Enum.KeyCode.K then
					s7 = "Killer"
					lib2:Notify({
						Title = "Target Mode",
						Description = "Killer",
						Time = 1
					})
				elseif input.KeyCode == Enum.KeyCode.J then
					s7 = "Survivors"
					lib2:Notify({
						Title = "Target Mode",
						Description = "Survivors",
						Time = 1
					})
				elseif input.KeyCode == Enum.KeyCode.L then
					s7 = "Zombie"
					lib2:Notify({
						Title = "Target Mode",
						Description = "Zombie",
						Time = 1
					})
				end
				if s7 and s7 ~= s5 then
					s5 = s7
					v2600()
				end
				if n2 < n228 then
					return
				end
				n7 += 624
				n5 += 736
				n223 += 1872
				n2 -= 1807
				n6 += 1508
				n224 = 377912790
				return (nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 374))
			end)
			u2583 = ScreenGui
		end
		destroyTargetSelectorUI = function()
			if connection2 then
				connection2:Disconnect()
				connection2 = nil
			end
			if u2583 then
				u2583:Destroy()
				u2583 = nil
			end
		end
		PistolSection = S_Page:CreateSection("Silent Aim (Pistol)", "crosshair")
		SilentAimToggle = PistolSection:AddToggle("Silent Aim Twist Of Fate", false, function(p254)
			u2467 = p254
			if p254 then
				createTargetSelectorUI()
				startConnection()
			else
				destroyTargetSelectorUI()
				stopConnection()
			end
		end, {
			Flag = "Pistol_SilentAim"
		})
		SilentAimToggle:AddKeyPicker("SilentAimKey")
		PredictToggle = PistolSection:AddToggle("Predict Aim ToF", false, function(p255)
			u2468 = p255
			local spilled = {
				n229 = 843813539,
				n230 = 1050946266
			}
			if n1 == 677872136 then
				n6 = 608549709
				n7 += 169
				n2 = 188512654
				n1 += 823
				n3 -= 885
				n5 += 261
				getfenv()[nil  ] = nil
				local _
				;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 373))
			else
				lib2:Notify({
					Title = "Predict Aim",
					Description = p255 and "Enabled" or "Disabled",
					Duration = 2
				})
			end
		end, {
			Flag = "Pistol_Predict"
		})
		BlockKnockedToggle = PistolSection:AddCheckbox("Block aim Knocked", false, function(p256)
			_G.Ox.AimConfig.Pistol_BlockKnocked = p256
		end, {
			Flag = "Pistol_BlockKnocked"
		})
		BulletBlockToggle = PistolSection:AddToggle("Block Bullets (TOF)", false, function(p257)
			_G.Ox.BulletBlockConfig.Enabled = p257
			lib2:Notify({
				Title = "Block Bullets",
				Description = p257 and "ON - no bullets come out" or "OFF",
				Duration = 3
			})
		end, {
			Flag = "Pistol_BlockPeluru"
		})
		LockAimToggle = PistolSection:AddToggle("Lock Aim (Twist Of Fate)", false, function(p258)
			_G.Ox.AimConfig.LockAim = p258
		end, {
			Flag = "Pistol_LockAim"
		})
		WallCheckToggle = PistolSection:AddToggle("Wallcheck", false, function(p259)
			u2470 = p259
		end, {
			Flag = "Pistol_Wallcheck"
		})
		LaserToggle = PistolSection:AddToggle("Enable Laser Effect", true, function(p260)
			n218 = 779057566
			u2469 = p260
			if n218 ~= n1 then
				if not p260 then
					clearLaser()
				end
				return
			end
			n6 = 872937668
			n2 -= 2031
			n5 = 153777365
			n3 -= 1382
			n1 += 921
			n218 = 585269599
			n7 = 879010035
		end, {
			Flag = "Pistol_Laser"
		})
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				u2471 = true
				if _G.Ox.AimConfig.Flash_Silent then
					u521 = true
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				doShoot()
			end
		end)
		local PistolSection_ = PistolSection
		local v2814 = PistolSection_
		local AddToggle = PistolSection_.AddToggle
		local function v2816(p261)
			_G.Ox.AimConfig.Flash_Silent = p261
			lib2:Notify({
				Title = "Flash Silent Aim",
				Description = p261 and "ON" or "OFF",
				Duration = 2
			})
		end
		AddToggle(v2814, "Silent Aim Flashlight", false, v2816, {
			Flag = "Flash_Silent"
		}):AddKeyPicker("FlashKey")
		PistolSection:AddSlider("FlashHeadOffset", 0, 15, 1.5, function(p262)
			_G.Ox.AimConfig.Flash_YOffset = p262
		end, {
			Increment = 0.1,
			Flag = "Flash_YOffset"
		})
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				u2471 = false
				u521 = false
				if Part then
					Part.Transparency = 1
				end
			end
		end)
		local connection3
		hookMobileButtons = function(p263)
			task.wait(0.5)
			local Controls = p263:WaitForChild("Controls", 10)
			if not Controls then
				return
			end
			local GuiMob = Controls:WaitForChild("Gui-mob", 5)
			if not GuiMob then
				return
			end
			GuiMob.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
					u2471 = true
					if _G.Ox.AimConfig.Flash_Silent then
						u521 = true
					end
				end
			end)
			GuiMob.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
					doShoot()
					u2471 = false
					u521 = false
					if Part then
						Part.Transparency = 1
					end
				end
			end)
		end
		setupMobileButton = function()
			local PlayerGui2 = v18:WaitForChild("PlayerGui", 10)
			if not PlayerGui2 then
				return
			end
			local SurvivorMob = PlayerGui2:FindFirstChild("Survivor-mob")
			if SurvivorMob then
				task.spawn(hookMobileButtons, SurvivorMob)
			end
			if connection3 then
				connection3:Disconnect()
				connection3 = nil
			end
			connection3 = PlayerGui2.ChildAdded:Connect(function(child)
				if child.Name == "Survivor-mob" then
					task.spawn(hookMobileButtons, child)
				end
			end)
		end
		setupMobileButton()
		v18.CharacterAdded:Connect(function(character)
			clearLaser()
			t26 = {}
			t28 = {}
			n219 = 0
			u2471 = false
			character:WaitForChild("HumanoidRootPart", 5)
			setupMobileButton()
			if n6 == 295005065 then
				if u2467 then
					stopConnection()
					task.wait(0.2)
					startConnection()
					createTargetSelectorUI()
				end
				return
			end
			n4 = 711339428
			n3 += 984
			n6 = 208217523
			n7 += 830
			n5 -= 1063
			n1 -= 1861
			return (nil)()
		end)
		PlayerGui.ChildRemoved:Connect(function(child)
			if not u2467 then
				return
			end
			task.wait(0.5)
			if not u2467 then
				return
			end
			if child.Name == "ToFTargetSelector" then
				createTargetSelectorUI()
			end
		end)
	end
	AntiHookCard = S_Page:CreateSection("Anti Hook", "shield")
	UnhookSelfToggle = AntiHookCard:AddToggle("Bypass Unhook Self", false, function(p264)
		if p264 then
			if not UnhookLoaded then
				v1168()
			end
			if not UnhookAPI then
				v531(UnhookSelfToggle, false)
			elseif UnhookAPI.Trigger() then
				lib2:Notify({
					Title = "Unhook Self",
					Description = "On",
					Duration = 2
				})
			else
				v531(UnhookSelfToggle, false)
			end
		else
			if UnhookAPI then
				UnhookAPI.Stop()
			end
			lib2:Notify({
				Title = "Unhook Self",
				Description = "Off",
				Duration = 2
			})
		end
	end, {
		Flag = "UnhookYourself"
	})
	do
		UnhookSelfToggle:AddKeyPicker("UnhookSelfKey", {
			Default = "None",
			Text = "Toggle Unhook Self",
			Mode = "Toggle",
			Callback = function(p265)
				if p265 then
					if not UnhookLoaded then
						v1168()
					end
					if not UnhookAPI then
						v531(UnhookSelfToggle, false)
					elseif UnhookAPI.Trigger() then
						v531(UnhookSelfToggle, true)
						lib2:Notify({
							Title = "Unhook Self",
							Description = "On",
							Duration = 2
						})
					else
						v531(UnhookSelfToggle, false)
					end
				else
					if UnhookAPI then
						UnhookAPI.Stop()
					end
					v531(UnhookSelfToggle, false)
					lib2:Notify({
						Title = "Unhook Self",
						Description = "Off",
						Duration = 2
					})
				end
			end
		})
	end
	local n231
	AntiHookToggle = AntiHookCard:AddToggle("Anti Hook", false, function(...)
		local v2823 = ...
		n231 = 96545554
		ToggleAntiHook(v2823)
		if n231 == 96545554 then
			return
		end
		n2 = 820777787
		n5 += 1275
		n7 -= 546
		n4 = 293385813
		n231 -= 866
		n3 -= 336
		n1 = 61372763
		local value = select(221, ...)
		return (select(220, ...))(value)
	end, {
		Flag = "AntiHook"
	})
	do
		local n232
		AntiHookCard:AddSlider("Offset", 50, 1000, 250, function(p266)
			n232 = 401064343
			if n5 ~= 403424291 then
				_G.Ox.AntiHook.OffsetY = -p266
				return
			end
			n232 -= 1387
			n6 += 1135
			n7 += 533
			n5 = 52952532
			n4 = 960091131
			n3 += 523
			n1 = 750702308
			bit32.bxor(nil, nil  )
			;(nil)(nil, nil)
			;(nil)()
			return table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil / nil  , nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 424)
		end, {
			Increment = 50,
			Flag = "AntiHookOffsetY"
		})
	end
	do
		AntiHookCard:AddSlider("Send HZ", 1, 60, 44, function(p267)
			_G.Ox.AntiHook.Hz = p267
			_G.Ox.AntiHook.Interval = 1 / p267
		end, {
			Increment = 1,
			Flag = "AntiHookHz"
		})
	end
	AbilityCard = S_Page:CreateSection("Survivor Ability", "zap")
	InstantTPToggle = AbilityCard:AddToggle("Instant TP Gate", false, function(p268)
		v1934(p268)
	end, {
		Flag = "InstanTPGate"
	})
	InstantTPToggle:AddKeyPicker("None")
	AbilityCard:AddToggle("Auto Crouch (Dodge S1)", false, function(p269)
		_G.Ox.ParryConfig.AutoCrouch = p269
		if n6 ~= 295006162 then
			return
		end
		n3 = 379808718
		n2 -= 940
		n5 = 768257453
		n6 -= 950
		n1 += 1745
		n7 = 190429945
		return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
	end, {
		Flag = "AutoCrouch"
	})
	UnlimitedVaultToggle = AbilityCard:AddToggle("Unlimited Vault", false, function(p270)
		v1972(p270)
	end, {
		Flag = "UnlimitedVault"
	})
	UnlimitedVaultToggle:AddKeyPicker("None")
	AntiSlowVaultToggle = AbilityCard:AddToggle("Anti Slow Vault", false, function(p271)
		_G.Ox.Config.Surv_PerfectVault = p271
		lib2:Notify({
			Title = "Anti Slow Vault",
			Description = p271 and "ON" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "AntiSlowVault"
	})
	AntiSlowVaultToggle:AddKeyPicker("None")
	FlowstateToggle = AbilityCard:AddToggle("Flowstate No CD", false, function(p272)
		v1984(p272)
	end, {
		Flag = "FlowstateNoCD"
	})
	FlowstateToggle:AddKeyPicker("None")
	NoFallToggle = AbilityCard:AddToggle("No Fall Damage", false, function(p273)
		v1987(p273)
	end, {
		Flag = "NoFallDamage"
	})
	NoFallToggle:AddKeyPicker("None")
	BypassGateToggle = AbilityCard:AddToggle("Bypass Exit Gate", false, function(p274)
		v1992(p274)
	end, {
		Flag = "BypassExiteGate"
	})
	SelfHealToggle = AbilityCard:AddToggle("Self Heal", false, function(p275)
		v2007(p275)
	end, {
		Flag = "SelfHeal"
	})
	SelfHealToggle:AddKeyPicker("None")
	do
		GodModeToggle = AbilityCard:AddToggle("God Mode (Anti Knockdown)", false, function(p276)
			_G.Ox.GodMode = p276
			lib2:Notify({
				Title = "God Mode",
				Description = p276 and "ON - HP won't go down" or "OFF",
				Duration = 3
			})
		end, {
			Flag = "GodMode"
		})
	end
	GodModeToggle:AddKeyPicker("GodModeKey", {
		Default = "None",
		Text = "Toggle God Mode",
		Mode = "Toggle",
		Callback = function(p277)
			if n2 == 352572318 then
				_G.Ox.GodMode = p277
			else
				n6 += 1972
				n4 = 649315070
				n2 = 418404046
				n7 += 544
				n1 = 648708903
				n5 -= 698
			end
		end
	})
	AbilityCard:AddButton("Apply Korless", function()
		v2020()
		lib2:Notify({
			Title = "Korless",
			Description = "Korless Morph Applied!",
			Duration = 3
		})
	end)
	local n233
	AbilityCard:AddButton("Instan Escape", function()
		n233 = 614227165
		v2028()
	end)
	AimbotCard = S_Page:CreateSection("Survivor Aimbot", "crosshair")
	do
		AimbotToggle = AimbotCard:AddToggle("Enable Aimbot", false, function(p278)
			_G.Ox.Config.Surv_Aimbot_Enabled = p278
			if not p278 then
				if _G.Ox.survivorAimbotHighlight then
					_G.Ox.survivorAimbotHighlight.Parent = nil
				end
				if _G.Ox.SurvivorFOVFrame then
					_G.Ox.SurvivorFOVFrame.Visible = false
				end
			end
			lib2:Notify({
				Title = "Survivor Aimbot",
				Description = p278 and "ON" or "OFF",
				Duration = 2
			})
		end, {
			Flag = "SurvAimbot"
		})
	end
	do
		AimbotToggle:AddKeyPicker("SurvivorAimbotKey", {
			Default = "None",
			Text = "Toggle Aimbot",
			Mode = "Toggle",
			Callback = function(p279)
				_G.Ox.Config.Surv_Aimbot_Enabled = p279
				if not p279 then
					if _G.Ox.survivorAimbotHighlight then
						_G.Ox.survivorAimbotHighlight.Parent = nil
					end
					if _G.Ox.SurvivorFOVFrame then
						_G.Ox.SurvivorFOVFrame.Visible = false
					end
				end
			end
		})
	end
	do
		local n234
		AimbotCard:AddToggle("Show FOV Circle", true, function(p280)
			n234 = 587699399
			_G.Ox.Config.Surv_Aimbot_ShowFOV = p280
			if not p280 and _G.Ox.SurvivorFOVFrame then
				_G.Ox.SurvivorFOVFrame.Visible = false
			end
			if n5 == 403422737 then
				return
			end
			n7 = 925738140
			n6 = 418535312
			n5 -= 1303
			n2 = 483731775
			n234 += 214
			n4 = 447961155
			n1 -= 1610
			LPH_CRASH()
		end, {
			Flag = "SurvAimbotFOV"
		})
	end
	do
		AimbotCard:AddSlider("FOV Radius", 30, 500, 150, function(p281)
			_G.Ox.Config.Surv_Aimbot_Radius = p281
		end, {
			Increment = 1,
			Flag = "SurvAimbotRadius"
		})
	end
	AimbotCard:AddSlider("Max Distance", 50, 1000, 300, function(p282)
		_G.Ox.Config.Surv_Aimbot_MaxDist = p282
	end, {
		Increment = 10,
		Flag = "SurvAimbotMaxDist"
	})
	AimbotCard:AddSlider("Smoothness", 0.1, 1, 0.5, function(p283)
		_G.Ox.Config.Surv_Aimbot_Smoothness = p283
		if n4 > 616464775 then
			return
		end
		n2 += 2034
		n6 += 905
		n7 += 275
		n1 = 805634519
		n4 = 470465945
		n5 = 732374411
	end, {
		Increment = 0.05,
		Flag = "SurvAimbotSmoot"
	})
	AimbotCard:AddSlider("Predict Offset", 0, 0.1, 0.01, function(p284)
		_G.Ox.Config.Surv_Aimbot_Predict = p284
	end, {
		Increment = 0.001,
		Flag = "SurvAimbotPredict"
	})
	do
		AimbotCard:AddDropdown("Target Part", {
			"Torso",
			"Head",
			"Root"
		}, false, function(p285)
			_G.Ox.Config.Surv_Aimbot_TargetPart = p285
		end, {
			Flag = "SurvAimbotTarget"
		})
	end
	ParryCardV1 = S_Page:CreateSection("Auto Parry V1", "sword")
	local n235
	AutoParryToggle = ParryCardV1:AddToggle("Auto Parry V1", false, function(p286)
		n235 = 173688992
		_G.Ox.ParryConfig.AutoParry = p286
		if not p286 then
			_G.Ox.State.ParryCooldown = false
			if _G.Ox.State.ParryCooldownThread then
				task.cancel(_G.Ox.State.ParryCooldownThread)
				_G.Ox.State.ParryCooldownThread = nil
			end
			if ParryHUD and ParryHUD.Reset then
				if n5 == n3 then
					n2 -= 595
					n1 += 432
					n235 += 714
					n3 -= 812
					n7 -= 228
					n5 = 35504689
					n4 = 1026938819
				else
					ParryHUD.Reset()
				end
			end
		end
		lib2:Notify({
			Title = "Auto Parry V1",
			Description = p286 and "ON" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "AutoParryV1"
	})
	AutoParryToggle:AddKeyPicker("None")
	local n236
	CustomParryToggle = ParryCardV1:AddToggle("Custom GUI (V1)", false, function(p287)
		n236 = 215962255
		local v2830
		if p287 then
			if not _G.Ox.AutoParryCustom.Gui then
				CreateCustomParryGUI()
			end
			_G.Ox.AutoParryCustom.Gui.Enabled = true
			_G.Ox.AutoParryCustom.GuiVisible = true
			UpdateCustomParryGUI(_G.Ox.ParryConfig.AutoParry)
			local Notify = lib2.Notify
			v2830 = Notify
			Notify(lib2, {
				Title = "Auto Parry GUI",
				Description = "GUI loaded",
				Duration = 2
			})
		else
			if _G.Ox.ParryConfig.AutoParry then
				_G.Ox.ParryConfig.AutoParry = false
				_G.Ox.AutoParryCustom.IsActive = false
				v531(AutoParryToggle, false)
			end
			if _G.Ox.AutoParryCustom.Gui then
				_G.Ox.AutoParryCustom.Gui.Enabled = false
				_G.Ox.AutoParryCustom.GuiVisible = false
			end
			local Notify = lib2.Notify
			v2830 = Notify
			Notify(lib2, {
				Title = "Auto Parry GUI",
				Description = "GUI hidden",
				Duration = 2
			})
		end
		if n7 ~= 542746161 then
			n236 -= 414
			n2 += 1678
			n5 = 835517
			n7 += 286
			n6 += 831
			n3 -= 388
			n4 = 302735549
			v2830[nil] = n4
			v2830[nil] = n4
		end
	end, {
		Flag = "AutoParryGuiV1"
	})
	ParryCardV1:AddCheckbox("Safety Parry", false, function(p288)
		_G.Ox.ParryConfig.ParrySafety = p288
	end, {
		Flag = "ParrySafetyV1"
	})
	ParryCardV1:AddToggle("Aggressive Mode", false, function(p289)
		_G.Ox.ParryConfig.ParryAggressive = p289
	end, {
		Flag = "ParryAggressiveV1"
	})
	ParryCardV1:AddToggle("Show Range Circle", true, function(p290)
		_G.Ox.ParryConfig.ParryCircle = p290
	end, {
		Flag = "ParryCircleV1"
	})
	ParryCardV1:AddSlider("Parry Radius", 5, 25, 15, function(p291)
		_G.Ox.ParryConfig.ParryRadius = p291
	end, {
		Increment = 1,
		Flag = "ParryRadiusV1"
	})
	ParryCardV1:AddSlider("Face Sensitivity", -10, 10, 7, function(p292)
		_G.Ox.ParryConfig.ParryFace = p292 / 10
	end, {
		Increment = 1,
		Flag = "ParryFaceV1"
	})
	ParryCardV2 = S_Page:CreateSection("Auto Parry V2", "sword")
	do
		ParryV2Toggle = ParryCardV2:AddToggle("Auto Parry V2", false, function(p293)
			_G.Ox.ParryV2.Enabled = p293
			if not p293 then
				V2_ResetCooldown()
				_G.Ox._V2ParryLastRoot = nil
				_G.Ox._V2ParryLastRadius = -1
				if _G.Ox.ParryV2.RangeAdornment then
					_G.Ox.ParryV2.RangeAdornment.Transparency = 1
				end
			end
			lib2:Notify({
				Title = "Auto Parry V2",
				Description = p293 and "ON" or "OFF",
				Duration = 2
			})
		end, {
			Flag = "AutoParryV2"
		})
	end
	ParryV2Toggle:AddKeyPicker("None")
	ParryCardV2:AddCheckbox("Safety Parry", false, function(p294)
		_G.Ox.ParryV2.SafetyParry = p294
		if n7 == n1 then
			n7 -= 589
			n6 = 872038284
			n2 += 1018
			n1 = 914950573
			n3 = 889765716
			n5 = 542257439
		end
	end, {
		Flag = "ParrySafetyV2"
	})
	ParryCardV2:AddDropdown("Mode", {
		"Legit",
		"Strict",
		"Aggressive"
	}, false, function(p295)
		_G.Ox.ParryV2.Mode = p295 or "Legit"
	end, {
		Flag = "ParryModeV2"
	})
	ParryCardV2:AddDropdown("Trigger", {
		"Remote",
		"Button"
	}, false, function(p296)
		_G.Ox.ParryV2.Trigger = p296 or "Remote"
	end, {
		Flag = "ParryTriggerV2"
	})
	ParryCardV2:AddSlider("Killer Face", -1, 1, 0.6, function(p297)
		_G.Ox.ParryV2.KillerFace = p297
		if n6 < 339369725 then
			return
		end
		n7 = 610104
		n1 = 1035463004
		n3 = 390116858
		n4 += 136
		n6 = 909238046
		n5 = 1067155118
		;(nil)(nil, nil)
		LPH_CRASH()
	end, {
		Increment = 0.1,
		Flag = "ParryKillerFaceV2"
	})
	ParryCardV2:AddToggle("Show Range Circle", true, function(p298)
		_G.Ox.ParryV2.ShowCircle = p298
		if not p298 and _G.Ox.ParryV2.RangeAdornment then
			_G.Ox.ParryV2.RangeAdornment.Transparency = 1
		end
	end, {
		Flag = "ParryCircleV2"
	})
	ParryCardV2:AddSlider("Parry Radius", 2, 20, 12, function(p299)
		_G.Ox.ParryV2.Range = p299
		_G.Ox._V2ParryLastRadius = -1
		if _G.Ox.ParryV2.RangeAdornment then
			_G.Ox.ParryV2.RangeAdornment.Radius = p299
			_G.Ox.ParryV2.RangeAdornment.InnerRadius = math.max(0.1, p299 - 0.15)
		end
	end, {
		Increment = 0.5,
		Flag = "ParryRadiusV2"
	})
	PalletCard = S_Page:CreateSection("Auto Drop Pallet", "fence")
	AutoPalletToggle = PalletCard:AddToggle("Auto Drop Pallet", false, function(p300)
		ToggleAutoPallet(p300)
	end, {
		Flag = "AutoDropPallet"
	})
	AutoPalletToggle:AddKeyPicker("AutoPalletKey", {
		Default = "None",
		Text = "Toggle Auto Drop Pallet",
		Mode = "Toggle",
		Callback = function(p301)
			ToggleAutoPallet(p301)
		end
	})
	PalletCard:AddCheckbox("Safety", true, function(p302)
		_G.Ox.AutoPallet.Safety = p302
	end, {
		Flag = "PalletSafety"
	})
	do
		PalletCard:AddSlider("Trigger Distance", 5, 30, 10, function(p303)
			_G.Ox.AutoPallet.Distance = p303
		end, {
			Increment = 1,
			Flag = "PalletDistance"
		})
	end
	do
		PalletCard:AddButton("Drop All Pallets", function()
			if n6 == 1024558438 then
				n6 += 319
				n7 = 169286391
				n2 = 728154866
				n5 += 551
				n1 = 253208283
				n3 = 129177815
				upv31[nil  ] = nil
				upv471[nil  ] = nil
				;(nil)(nil)
			else
				DropAllPallets()
			end
		end)
	end
	KillerTab = v14:CreateTab("Killer", false, false)
	K_Page = KillerTab:CreatePage("Killer")
	KillerAimbotCard = K_Page:CreateSection("Killer Aimbot", "swords")
	do
		KillerAimbotToggle = KillerAimbotCard:AddToggle("Enable Aimbot (Melee)", false, function(p304)
			_G.Ox.Config.Killer_Aimbot_Enabled = p304
			if not p304 and _G.Ox.killerAimbotHighlight then
				_G.Ox.killerAimbotHighlight.Parent = nil
			end
			lib2:Notify({
				Title = "Killer Aimbot",
				Description = p304 and "ON" or "OFF",
				Duration = 2
			})
		end, {
			Flag = "AimbotKiller"
		})
	end
	KillerAimbotToggle:AddKeyPicker("KillerAimbotKey", {
		Default = "None",
		Text = "Toggle Killer Aimbot",
		Mode = "Toggle",
		Callback = function(p305)
			_G.Ox.Config.Killer_Aimbot_Enabled = p305
			if not p305 and _G.Ox.killerAimbotHighlight then
				_G.Ox.killerAimbotHighlight.Parent = nil
			end
		end
	})
	local n237
	KillerAimbotCard:AddSlider("Max Distance", 5, 30, 12, function(p306)
		n237 = 399030215
		_G.Ox.Config.Killer_Aimbot_MaxDist = p306
		if n7 == n3 then
			n237 -= 1764
			n6 = 480415509
			n7 -= 750
			n4 += 1966
			n3 -= 432
			n5 = 281501865
			n1 = 393203636
			upv220[nil] = nil
		end
	end, {
		Increment = 1,
		Flag = "AimbotKillerMaxDist"
	})
	KillerAimbotCard:AddSlider("Smoothness", 0.1, 1, 0.5, function(p307)
		_G.Ox.Config.Killer_Aimbot_Smoothness = p307
	end, {
		Increment = 0.05,
		Flag = "AimbotKillerSmoothness"
	})
	VeilCard = K_Page:CreateSection("Silent Veil", "arrow-up-right")
	VeilTog = VeilCard:AddToggle("Silent Veil", false, function(p308)
		_G.Ox.AimConfig.Aim_SilentVeilV2 = p308
		lib2:Notify({
			Title = "Silent Veil",
			Description = p308 and "ON" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "SilentVeilV2"
	})
	VeilTog:AddKeyPicker()
	VeilCard:AddToggle("Auto Predict", false, function(p309)
		_G.Ox.Config.SpearSmart_enable = p309
	end, {
		Flag = "SpearSmartVeil"
	})
	VeilCard:AddToggle("Show FOV", true, function(p310)
		_G.Ox.AimConfig.Veil_ShowFOV = p310
		if n7 ~= 542746298 then
			return
		end
		n5 -= 915
		n3 = 520083032
		n6 += 350
		n7 = 297594873
		n2 += 1956
		n4 += 2007
		;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 290))
		return nil
	end, {
		Flag = "VeilShowFOV"
	})
	VeilCard:AddSlider("Lead", 0.5, 5, 1.4, function(p311)
		_G.Ox.AimConfig.Veil_LeadMultiplier = p311
	end, {
		Increment = 0.1,
		Flag = "VeilLeadMulti"
	})
	do
		VeilCard:AddSlider("Spear Speed", 50, 200, 165, function(p312)
			_G.Ox.AimConfig.SPEAR_Speed = p312
		end, {
			Increment = 1,
			Flag = "VeilSpearSpeed"
		})
	end
	VeilCard:AddSlider("Spear Gravity", 10, 200, 103, function(p313)
		_G.Ox.AimConfig.SPEAR_Gravity = p313
	end, {
		Increment = 1,
		Flag = "VeilSpearGravity"
	})
	VeilCard:AddSlider("Aura Speed", 50, 200, 165, function(p314)
		_G.Ox.AimConfig.SPEAR_AuraSpeed = p314
	end, {
		Increment = 1,
		Flag = "VeilSpearAuraSpeed"
	})
	local n238
	VeilCard:AddSlider("Aura Gravity", 10, 200, 96.5, function(p315)
		n238 = 21562239
		_G.Ox.AimConfig.SPEAR_AuraGravity = p315
		if not (n238 < n7) then
			n1 = 895418454
			n238 = 184114890
			n6 -= 1239
			n7 = 967332060
			n4 = 528312676
			n5 = 386177664
			n2 -= 668
			;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 312))
			upv321[nil] = nil
		end
	end, {
		Increment = 1,
		Flag = "VeilSpearAuraGravity"
	})
	VeilCard:AddSlider("FOV", 50, 500, 150, function(p316)
		_G.Ox.AimConfig.Veil_FOV = p316
	end, {
		Increment = 1,
		Flag = "VeilFOV"
	})
	VeilCard:AddSlider("Max Dist", 50, 1000, 500, function(p317)
		_G.Ox.AimConfig.SPEAR_MaxDist = p317
		if n5 == 403423820 then
			n7 += 1450
			n6 -= 701
			n4 = 943204538
			n5 += 1613
			n3 = 242316428
			n1 += 793
		end
	end, {
		Increment = 10,
		Flag = "SpearMaxDist"
	})
	AntiBlindSection = K_Page:CreateSection("Killer Ability", "zap")
	AntiBlindToggle = AntiBlindSection:AddToggle("Anti Blind (Flashlight)", false, function(p318)
		_G.Ox.AntiBlindEnabled = p318
		lib2:Notify({
			Title = "Anti Blind",
			Description = p318 and "ON - immune to flashlights" or "OFF",
			Duration = 3
		})
	end, {
		Flag = "AntiBlind"
	})
	AntiBlindToggle:AddKeyPicker("AntiBlindKey", {
		Default = "None",
		Text = "Toggle Anti Blind",
		Mode = "Toggle",
		Callback = function(p319)
			_G.Ox.AntiBlindEnabled = p319
		end
	})
	CounterParryToggle = AntiBlindSection:AddToggle("Anti Parry", false, function(p320)
		ToggleCounterParry(p320)
	end, {
		Flag = "CounterAutoParry"
	})
	CounterParryToggle:AddKeyPicker("CounterParryKey", {
		Default = "None",
		Text = "Toggle Counter Parry",
		Mode = "Toggle",
		Callback = function(p321)
			ToggleCounterParry(p321)
		end
	})
	local n239
	if n6 == n5 then
		n1 = 354244368
		n3 += 1954
		n5 = 1034938118
		n4 -= 1155
		n7 -= 386
		n6 = 781739016
		n2 += 1613
		upv355[nil  ] = nil
		n162 = bit32.bxor(n233, nil  )
	else
		InfLungeToggle = AntiBlindSection:AddToggle("Infinite Lunge", false, function(p322)
			n239 = 751782595
			if p322 then
				EnableInfiniteLunge()
			else
				DisableInfiniteLunge()
			end
			if not (n4 < 738693445) then
				n3 = 690875626
				n6 -= 779
				n2 -= 262
				n7 -= 1143
				n5 -= 1845
				n239 += 426
				n4 -= 378
			end
		end, {
			Flag = "InfiniteLunge"
		})
	end
	InfLungeToggle:AddKeyPicker("InfLungeKey", {
		Default = "None",
		Text = "Toggle Infinite Lunge",
		Mode = "Toggle",
		Callback = function(p323)
			if p323 then
				EnableInfiniteLunge()
			else
				DisableInfiniteLunge()
			end
		end
	})
	do
		AutoStalkToggle = AntiBlindSection:AddToggle("Auto Stalk", false, function(p324)
			ToggleAutoStalk(p324)
		end, {
			Flag = "AutoStalk"
		})
	end
	AutoStalkToggle:AddKeyPicker("AutoStalkKey", {
		Default = "None",
		Text = "Toggle Auto Stalk",
		Mode = "Toggle",
		Callback = function(p325)
			ToggleAutoStalk(p325)
		end
	})
	do
		AntiSlowdownToggle = AntiBlindSection:AddToggle("No Slowdown Killer", false, function(p326)
			_G.Ox.NoSlowdownEnabled = p326
			if p326 then
				local Character = LocalPlayer.Character
				if Character then
					local Humanoid = Character:FindFirstChildOfClass("Humanoid")
					if Humanoid then
						Humanoid.WalkSpeed = 16
					end
				end
				lib2:Notify({
					Title = "No Slowdown Killer",
					Description = "ON - WalkSpeed locked to 16",
					Duration = 3
				})
			else
				lib2:Notify({
					Title = "No Slowdown Killer",
					Description = "OFF",
					Duration = 2
				})
			end
		end, {
			Flag = "NoSlowdown"
		})
	end
	AntiSlowdownToggle:AddKeyPicker("NoSlowdownKey", {
		Default = "None",
		Text = "Toggle No Slowdown",
		Mode = "Toggle",
		Callback = function(p327)
			_G.Ox.NoSlowdownEnabled = p327
			if p327 then
				local Character = LocalPlayer.Character
				if Character then
					local Humanoid = Character:FindFirstChildOfClass("Humanoid")
					if Humanoid then
						Humanoid.WalkSpeed = 16
					end
				end
			end
		end
	})
	BypassLeapToggle = AntiBlindSection:AddToggle("Skill Hidden No CD", false, function(p328)
		_G.Ox.BypassLeapEnabled = p328
		if p328 then
			v1245()
			lib2:Notify({
				Title = "Skill Hidden No CD",
				Description = "ON - Hidden skill cooldown removed",
				Duration = 3
			})
		else
			if Connections_.LeapBypass then
				task.cancel(Connections_.LeapBypass)
				Connections_.LeapBypass = nil
			end
			lib2:Notify({
				Title = "Skill Hidden No CD",
				Description = "OFF",
				Duration = 2
			})
		end
		if n5 == 403422737 then
			return
		end
		n6 = 392706182
		n7 = 763379879
		n2 = 512177984
		n4 += 1114
		n3 = 38485478
		n5 = 1048381512
		return (nil)()
	end, {
		Flag = "BypassSkilHidden"
	})
	do
		BypassLeapToggle:AddKeyPicker("BypassLeapKey", {
			Default = "None",
			Text = "Toggle Hidden No CD",
			Mode = "Toggle",
			Callback = function(p329)
				_G.Ox.BypassLeapEnabled = p329
				if p329 then
					v1245()
				elseif Connections_.LeapBypass then
					task.cancel(Connections_.LeapBypass)
					Connections_.LeapBypass = nil
				end
			end
		})
	end
	InfAbyssalToggle = AntiBlindSection:AddToggle("Infinite Corrupt (Abyssal)", false, function(p330)
		_G.Ox.InfAbyssalEnabled = p330
		if not p330 then
			v1262()
		end
		lib2:Notify({
			Title = "Infinite Corrupt",
			Description = p330 and "ON - press Q (PC) or the skill button (mobile)" or "OFF",
			Duration = 3
		})
	end, {
		Flag = "InfinityCorrupt"
	})
	InfAbyssalToggle:AddKeyPicker("InfAbyssalKey", {
		Default = "None",
		Text = "Toggle Infinite Corrupt",
		Mode = "Toggle",
		Callback = function(p331)
			_G.Ox.InfAbyssalEnabled = p331
			if not p331 then
				v1262()
			end
		end
	})
	DashLockToggle = AntiBlindSection:AddToggle("Dash Lock (Hidden)", false, function(p332)
		v1169(p332)
	end, {
		Flag = "DashLockHidden"
	})
	DashLockToggle:AddKeyPicker("DashKey", {
		Default = "V",
		Text = "Toggle Dash Lock",
		Mode = "Toggle",
		Callback = function(p333)
			v1169(p333)
			if n6 == 295005065 then
				return
			end
			n5 -= 75
			n7 -= 1357
			n4 -= 244
			n3 += 904
			n6 += 1329
			n1 += 1777
			return (nil)(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
		end
	})
	MaskToggle = AntiBlindSection:AddToggle("Mask Selection GUI", false, function(p334)
		v1182(p334)
	end, {
		Flag = "MaskSelectGui"
	})
	MaskToggle:AddKeyPicker("None")
	AntiBlindSection:AddButton("Aim Lock Toggle", function()
		local n240 = 964190734
		local n241 = 964396920
		local ok = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Games/lib/VD_AimLock.lua"))()
			if n7 ~= 542746704 then
				return
			end
			n4 = 136815530
			n7 += 865
			n240 += 877
			n241 -= 754
			n5 = 30205895
			return nil
		end)
		if ok then
			lib2:Notify({
				Title = "Aim Lock",
				Description = "Aim Lock loaded!",
				Duration = 3
			})
		else
			lib2:Notify({
				Title = "Error",
				Description = "Couldn't load Aim Lock!",
				Duration = 3
			})
		end
	end)
	FlaskCard = K_Page:CreateSection("Silent Aim Flask (Cure)", "flask-conical")
	FlaskToggle = FlaskCard:AddToggle("Silent Aim Flask", false, function(p335)
		_G.Ox.KILLER_SilentAimFlask = p335
		lib2:Notify({
			Title = "Silent Aim Flask",
			Description = p335 and "ON" or "OFF",
			Duration = 2
		})
	end, {
		Flag = "SilentFlask"
	})
	FlaskToggle:AddKeyPicker("FlaskKey", {
		Default = "None",
		Text = "Toggle Silent Aim Flask",
		Mode = "Toggle",
		Callback = function(p336)
			_G.Ox.KILLER_SilentAimFlask = p336
		end
	})
	FlaskLaserToggle = FlaskCard:AddToggle("Flask Laser", false, function(p337)
		_G.Ox.KILLER_FlaskLaser = p337
		if p337 then
			pcall(NEX_StartCureFlaskLaser)
			lib2:Notify({
				Title = "Flask Laser",
				Description = "ON - red laser shown",
				Duration = 2
			})
		else
			if _G.Ox.NEX_CureFlaskLaserThread then
				_G.Ox.NEX_CureFlaskLaserThread:Disconnect()
				_G.Ox.NEX_CureFlaskLaserThread = nil
			end
			if _G.Ox.NEX_CureFlaskLaserPart then
				pcall(function()
					_G.Ox.NEX_CureFlaskLaserPart:Destroy()
				end)
				_G.Ox.NEX_CureFlaskLaserPart = nil
			end
			lib2:Notify({
				Title = "Flask Laser",
				Description = "OFF",
				Duration = 2
			})
		end
	end, {
		Flag = "LaserFlask"
	})
	local n242
	FlaskLaserToggle:AddKeyPicker("FlaskLaserKey", {
		Default = "None",
		Text = "Toggle Flask Laser",
		Mode = "Toggle",
		Callback = function(p338)
			n242 = 902260622
			_G.Ox.KILLER_FlaskLaser = p338
			if p338 then
				pcall(NEX_StartCureFlaskLaser)
			else
				if _G.Ox.NEX_CureFlaskLaserThread then
					_G.Ox.NEX_CureFlaskLaserThread:Disconnect()
					if n2 == 352572318 then
						_G.Ox.NEX_CureFlaskLaserThread = nil
					else
						n2 += 1248
						n3 -= 1894
						n6 += 1287
						n7 -= 189
						n1 -= 440
						n242 -= 1860
						n5 = 791956493
					end
				end
				if _G.Ox.NEX_CureFlaskLaserPart then
					pcall(function()
						_G.Ox.NEX_CureFlaskLaserPart:Destroy()
					end)
					_G.Ox.NEX_CureFlaskLaserPart = nil
				end
			end
		end
	})
	AntiLoopingSection = K_Page:CreateSection("Anti Looping", "repeat")
	AntiLoopingToggle = AntiLoopingSection:AddToggle("Block Vault & Pallets", false, function(p339)
		_G.Ox.BlockPalletEnabled = p339
		local n243 = 574055950
		local n244 = 121191086
		local n245 = 660526026
		local n246 = 4431394
		if not p339 then
			local VaultCompleteEvent = game:GetService("ReplicatedStorage").Remotes.Window.VaultCompleteEvent
			local PalletSlideCompleteEvent = game:GetService("ReplicatedStorage").Remotes.Pallet.PalletSlideCompleteEvent
			local Map = workspace:FindFirstChild("Map")
			if Map then
				for _, descendant in pairs(Map:GetDescendants()) do
					if descendant.Name == "VaultPointInUse" then
						pcall(function()
							VaultCompleteEvent:FireServer(descendant.Parent, false)
						end)
					elseif descendant.Name == "PalletPointSlideInUse" then
						pcall(function()
							PalletSlideCompleteEvent:FireServer(descendant.Parent, false)
						end)
					end
				end
			end
			return
		end
		local VaultEvent = game:GetService("ReplicatedStorage").Remotes.Window.VaultEvent
		local PalletSlideEvent = game:GetService("ReplicatedStorage").Remotes.Pallet.PalletSlideEvent
		local Map = workspace:FindFirstChild("Map")
		if Map then
			for _, descendant in pairs(Map:GetDescendants()) do
				if descendant.Name == "VaultTrigger" then
					pcall(function()
						VaultEvent:FireServer(descendant, true)
					end)
				end
				if descendant.Name == "PalletPointSlide" and descendant:IsA("BasePart") then
					pcall(function()
						PalletSlideEvent:FireServer(descendant, true)
						if n7 == n243 then
							n7 += 1246
							n245 += 1636
							n5 = 718807807
							n244 += 499
							n243 = 763767228
							n246 -= 271
						end
					end)
				end
			end
		end
		task.spawn(function()
			local Map2 = workspace:FindFirstChild("Map")
			if not Map2 then
				return
			end
			local t33 = {}
			watchPallet = function(p340)
				local n247 = 1038459094
				if p340:IsA("BasePart") and p340.Name == "PalletPoint" then
					local connection = p340:GetPropertyChangedSignal("Name"):Connect(function()
						if not _G.Ox.BlockPalletEnabled then
							return
						end
						if n4 == n247 then
							n247 += 7
							n5 = 399789595
							n4 = 467740588
							bit32.band(nil, nil  )
							upv369[nil  ] = nil
						elseif p340.Name == "PalletPointSlide" then
							task.wait(0.1)
							pcall(function()
								PalletSlideEvent:FireServer(p340, true)
							end)
						end
					end)
					table.insert(t33, connection)
				end
			end
			for _, descendant in pairs(Map2:GetDescendants()) do
				watchPallet(descendant)
			end
			local connection = Map2.DescendantAdded:Connect(function(descendant)
				watchPallet(descendant)
			end)
			table.insert(t33, connection)
			while _G.Ox.BlockPalletEnabled do
				task.wait(0.5)
			end
			for _, v in pairs(t33) do
				v:Disconnect()
			end
			t33 = {}
		end)
		lib2:Notify({
			Title = "Anti Looping",
			Description = "✅ On!",
			Duration = 2
		})
	end, {
		Flag = "AntiLooping"
	})
	AntiLoopingToggle:AddKeyPicker("AntiLoopingKey", {
		Default = "None",
		Text = "Keybind Block Vault & Pallets",
		Mode = "Toggle",
		Callback = function(p341)
			_G.Ox.BlockPalletEnabled = p341
			if AntiLoopingToggle then
				AntiLoopingToggle:SetValue(p341)
			end
		end
	})
	EspTab = v14:CreateTab("Visual", false, false)
	EspPage = EspTab:CreatePage("ESP")
	EspMasterCard = EspPage:CreateSection("ESP Settings", "eye")
	do
		EspMasterToggle = EspMasterCard:AddToggle("Enable ESP", false, function(p342)
			_G.Ox.ESPConfig.Master = p342
			if p342 then
				ForceRefreshMap()
				lib2:Notify({
					Title = "ESP",
					Description = "ON",
					Duration = 2
				})
			else
				ClearAllESP()
				lib2:Notify({
					Title = "ESP",
					Description = "OFF",
					Duration = 2
				})
			end
		end, {
			Flag = "EnableEspMaster"
		})
	end
	EspMasterToggle:AddKeyPicker("EspKey", {
		Default = "None",
		Text = "ESP Key",
		Mode = "Toggle"
	})
	do
		EspMasterCard:AddSlider("ESP Max Distance", 100, 5000, 1000, function(p343)
			_G.Ox.ESPConfig.MaxDistance = p343
		end, {
			Increment = 100,
			Flag = "EspMaxDistance"
		})
	end
	PlayerToggle = EspMasterCard:AddCheckbox("Player ESP", false, function(p344)
		if n2 == 352572318 then
			_G.Ox.ESPConfig.Player = p344
		else
			n7 = 635038564
			n5 = 320823025
			n6 += 1456
			n1 += 1406
			n2 += 2035
			n3 += 284
			;(nil)[nil  ] = nil
		end
		if _G.Ox.ESPConfig.Master then
			if p344 then
				ScanMapESP()
			else
				ClearESP("Player")
			end
		end
	end, {
		Flag = "PlayerEsp"
	})
	PlayerToggle:AddColorPicker(_G.Ox.ESPColors.Player, {
		Flag = "EspPlayer_Color",
		Title = "Player ESP Color",
		Callback = function(p345)
			_G.Ox.ESPColors.Player = p345
			if _G.Ox.ESPConfig.Master then
				UpdatePlayerESP()
			end
			if n3 ~= 660935885 then
				n7 -= 354
				n4 = 923087385
				n5 += 232
				n3 = 349168945
				n1 += 1750
				n6 += 1652
				local v2868
				while true do
					v2868 += Q_0
					if Q_0 <= 0 then
						if not (v2868 >= N_0) then
							break
						end
					elseif not (v2868 <= N_0) then
						break
					end
				end
			end
		end
	})
	KillerToggle = EspMasterCard:AddCheckbox("Killer ESP", false, function(p346)
		_G.Ox.ESPConfig.Killer = p346
		if _G.Ox.ESPConfig.Master then
			if p346 then
				ScanMapESP()
			else
				ClearESP("Killer")
			end
		end
	end, {
		Flag = "KillerEsp"
	})
	do
		KillerToggle:AddColorPicker(_G.Ox.ESPColors.Killer, {
			Flag = "EspKiller_Color",
			Title = "Killer ESP Color",
			Callback = function(p347)
				_G.Ox.ESPColors.Killer = p347
				if _G.Ox.ESPConfig.Master then
					UpdatePlayerESP()
				end
			end
		})
	end
	NameToggle = EspMasterCard:AddCheckbox("ESP Name", false, function(p348)
		_G.Ox.ESPConfig.Name = p348
		if _G.Ox.ESPConfig.Master then
			ScanMapESP()
		else
			ClearAllESP()
		end
	end, {
		Flag = "EspName"
	})
	DistToggle = EspMasterCard:AddCheckbox("ESP Distance", false, function(p349)
		_G.Ox.ESPConfig.Distance = p349
		if _G.Ox.ESPConfig.Master then
			UpdatePlayerESP()
		end
	end, {
		Flag = "EspDistancw"
	})
	StatusToggle = EspMasterCard:AddCheckbox("ESP Status survivors", false, function(p350)
		_G.Ox.ESPConfig.Status = p350
		if _G.Ox.ESPConfig.Master then
			UpdatePlayerESP()
		end
		if n3 == n7 then
			n3 += 899
			n2 = 892346415
			n7 += 1931
			n5 = 570634781
			n1 += 962
			n6 = 646278630
			;(nil)()
		end
	end, {
		Flag = "EspStatus"
	})
	IconToggle = EspMasterCard:AddCheckbox("ESP Item Icon", false, function(p351)
		_G.Ox.ESPConfig.ItemIcon = p351
		if _G.Ox.ESPConfig.Master then
			UpdatePlayerESP()
		end
	end, {
		Flag = "EspItemIcon"
	})
	WarnToggle = EspMasterCard:AddCheckbox("ESP Killer Warn", false, function(p352)
		_G.Ox.ESPConfig.KillerWarn = p352
		if not p352 and v18.Character then
			local HumanoidRootPart = v18.Character:FindFirstChild("HumanoidRootPart")
			if HumanoidRootPart and HumanoidRootPart:FindFirstChild("KillerWarn") then
				HumanoidRootPart.KillerWarn:Destroy()
			end
		end
	end, {
		Flag = "KillerWarn"
	})
	OutlineToggle = EspMasterCard:AddCheckbox("ESP Outline Mode", false, function(p353)
		_G.Ox.ESPConfig.Outline = p353
	end, {
		Flag = "EspOutlineMode"
	})
	HookCountToggle = EspMasterCard:AddCheckbox("ESP Hook Count", false, function(p354)
		_G.Ox.ESPConfig.HookCount = p354
		if p354 then
			if n6 == 295006249 then
				n5 = 327280208
				n7 = 823002794
				n2 += 1659
				n3 = 399887079
				n1 = 799032139
				n6 += 818
				return (nil)()
			end
			UpdateHookData()
			UpdatePlayerESP()
			UpdateHookUICounter()
			lib2:Notify({
				Title = "Hook ESP",
				Description = "ON",
				Duration = 2
			})
		else
			ClearHookESP()
			ClearHookUICounter()
			UpdatePlayerESP()
			lib2:Notify({
				Title = "Hook ESP",
				Description = "OFF",
				Duration = 2
			})
		end
	end, {
		Flag = "EspHookCount"
	})
	PerfCard = EspPage:CreateSection("World Effects", "flashlight")
	FullBrightToggle = PerfCard:AddToggle("Full Bright", false, function(p355)
		_G.Ox.FullBright = p355
		local Lighting = game:GetService("Lighting")
		if not Lighting then
			return
		end
		if p355 then
			StartLightingGuard()
			ReapplyPerformanceDelayed()
			lib2:Notify({
				Title = "Full Bright",
				Description = "ON",
				Duration = 2
			})
		else
			Lighting.Brightness = 1
			Lighting.ClockTime = 14
			Lighting.FogEnd = 1000
			Lighting.Ambient = Color3.fromRGB(128, 128, 128)
			Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
			StopLightingGuard()
			lib2:Notify({
				Title = "Full Bright",
				Description = "OFF",
				Duration = 2
			})
		end
	end, {
		Flag = "FullBright"
	})
	PerfCard:AddSlider("Time Of Day", 0, 24, 14, function(p356)
		_G.Ox.TimeOfDayValue = p356
		if _G.Ox.FullBright then
			local Lighting = game:GetService("Lighting")
			if Lighting then
				Lighting.ClockTime = p356
			end
		end
	end, {
		Increment = 1,
		Flag = "TimeOfDay"
	})
	do
		NoFogToggle = PerfCard:AddToggle("No Fog", false, function(p357)
			_G.Ox.NoFog = p357
			if p357 then
				StartLightingGuard()
				ApplyNoFog()
				lib2:Notify({
					Title = "No Fog",
					Description = "ON - fog removed",
					Duration = 3
				})
			else
				local Lighting = game:GetService("Lighting")
				if Lighting then
					Lighting.FogStart = 0
					Lighting.FogEnd = 1000
					local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
					if not (n6 < n4) then
						n6 += 106
						n3 -= 863
						n4 -= 259
						n2 += 338
						n5 += 1467
						n7 = 168791992
						return (nil)()
					end
					if Atmosphere then
						Atmosphere.Density = 0.35
					end
				end
				StopLightingGuard()
				lib2:Notify({
					Title = "No Fog",
					Description = "OFF",
					Duration = 2
				})
			end
		end, {
			Flag = "NoFog"
		})
	end
	NoShadowToggle = PerfCard:AddToggle("No Shadow", false, function(p358)
		_G.Ox.NoShadow = p358
		if p358 then
			StartLightingGuard()
			ApplyNoShadow()
			lib2:Notify({
				Title = "No Shadow",
				Description = "ON - shadows removed",
				Duration = 2
			})
		else
			ApplyNoShadow()
			StopLightingGuard()
			lib2:Notify({
				Title = "No Shadow",
				Description = "OFF",
				Duration = 2
			})
		end
	end, {
		Flag = "NoShadow"
	})
	LowGFXToggle = PerfCard:AddToggle("Remove Texture (Low GFX)", false, function(p359)
		ToggleLowGFX(p359)
		if n1 ~= 677870210 then
			n6 -= 801
			n3 += 712
			n7 = 874504923
			n1 = 815578611
			n2 = 406816916
			n5 += 989
		end
	end, {
		Flag = "RemoveTexture"
	})
	LowGFXToggle:AddKeyPicker("None")
	MapCard = EspPage:CreateSection("Map ESP", "map")
	GenToggle = MapCard:AddCheckbox("Generator ESP", false, function(p360)
		_G.Ox.ESPConfig.Generator = p360
		if _G.Ox.ESPConfig.Master then
			if p360 then
				ScanMapESP()
			else
				ClearESP("Generator")
			end
		end
	end, {
		Flag = "GeneratorEsp"
	})
	GenToggle:AddColorPicker(_G.Ox.ESPColors.Generator, {
		Flag = "Generator_Color",
		Title = "Generator Color",
		Callback = function(p361)
			_G.Ox.ESPColors.Generator = p361
			if _G.Ox.ESPConfig.Master then
				UpdateStaticESP()
			end
		end
	})
	do
		GenNameToggle = MapCard:AddCheckbox("Generator Name & Progress", true, function(p362)
			_G.Ox.ESPConfig.GeneratorName = p362
			if _G.Ox.ESPConfig.Master then
				ScanMapESP()
			end
		end, {
			Flag = "GeneratorName"
		})
	end
	MapCard:AddColorPicker("Gen Done Color", _G.Ox.ESPColors.GeneratorDone, {
		Flag = "GeneratorDone_Color",
		Title = "Finished Generator Color",
		Callback = function(p363)
			_G.Ox.ESPColors.GeneratorDone = p363
			if _G.Ox.ESPConfig.Master then
				UpdateStaticESP()
			end
		end
	})
	local n248
	PalletToggle = MapCard:AddCheckbox("Pallet ESP", false, function(p364)
		n248 = 529032702
		_G.Ox.ESPConfig.Pallet = p364
		if _G.Ox.ESPConfig.Master then
			if n5 == n248 then
				n248 += 1809
				n7 = 802183263
				n4 = 446570074
				n6 += 1227
				n1 -= 649
				n5 += 495
				n2 -= 438
				;(nil)()
				bit32.bxor(nil, nil)
			elseif p364 then
				ScanMapESP()
			else
				ClearESP("Pallet")
			end
		end
	end, {
		Flag = "EspPallet"
	})
	PalletToggle:AddColorPicker(_G.Ox.ESPColors.Pallet, {
		Flag = "Pallet_Color",
		Title = "Pallet Color",
		Callback = function(p365)
			_G.Ox.ESPColors.Pallet = p365
			if _G.Ox.ESPConfig.Master then
				UpdateStaticESP()
			end
		end
	})
	WindowToggle = MapCard:AddCheckbox("Window ESP", false, function(p366)
		_G.Ox.ESPConfig.Window = p366
		if _G.Ox.ESPConfig.Master then
			if p366 then
				ScanMapESP()
			else
				ClearESP("Window")
			end
		end
	end, {
		Flag = "EspWindow"
	})
	WindowToggle:AddColorPicker(_G.Ox.ESPColors.Window, {
		Flag = "Window_Color",
		Title = "Window Color",
		Callback = function(p367)
			_G.Ox.ESPColors.Window = p367
			if _G.Ox.ESPConfig.Master then
				UpdateStaticESP()
			end
		end
	})
	HookToggle = MapCard:AddCheckbox("Hook ESP", false, function(p368)
		_G.Ox.ESPConfig.Hook = p368
		if _G.Ox.ESPConfig.Master then
			if p368 then
				ScanMapESP()
			else
				ClearESP("Hook")
			end
		end
	end, {
		Flag = "HookEsp"
	})
	HookToggle:AddColorPicker(_G.Ox.ESPColors.Hook, {
		Flag = "Hook_Color",
		Title = "Hook Color",
		Callback = function(p369)
			_G.Ox.ESPColors.Hook = p369
			if _G.Ox.ESPConfig.Master then
				UpdateStaticESP()
			end
		end
	})
	do
		GateToggle = MapCard:AddCheckbox("Gate ESP", false, function(p370)
			_G.Ox.ESPConfig.Gate = p370
			if _G.Ox.ESPConfig.Master then
				if p370 then
					ScanMapESP()
				else
					ClearESP("Gate")
				end
			end
		end, {
			Flag = "GateEsp"
		})
	end
	GateToggle:AddColorPicker(_G.Ox.ESPColors.Gate, {
		Flag = "Gate_Color",
		Title = "Gate Color",
		Callback = function(p371)
			_G.Ox.ESPColors.Gate = p371
			if _G.Ox.ESPConfig.Master then
				UpdateStaticESP()
			end
		end
	})
	SCPToggle = MapCard:AddCheckbox("SCP ESP", false, function(p372)
		_G.Ox.ESPConfig.SCP = p372
		if _G.Ox.ESPConfig.Master then
			if p372 then
				ScanMapESP()
			else
				ClearESP("SCP")
			end
		end
	end, {
		Flag = "EspScp"
	})
	SCPToggle:AddColorPicker(_G.Ox.ESPColors.SCP, {
		Flag = "ScpEsp_Color",
		Title = "SCP Color",
		Callback = function(p373)
			_G.Ox.ESPColors.SCP = p373
			if _G.Ox.ESPConfig.Master then
				UpdateSCPESP()
			end
		end
	})
	MapCard:AddButton("Refresh Map", function()
		ForceRefreshMap()
		lib2:Notify({
			Title = "Map",
			Description = "Refreshed!",
			Duration = 2
		})
		if n2 == n4 then
			n6 = 886683070
			n4 = 56412989
			n2 += 617
			n5 -= 953
			n1 -= 1506
			n7 -= 131
			;(nil)(table.unpack({ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }, 1, 499))
		end
	end)
	NextKillerCard = EspPage:CreateSection("Information", "info")
	NextKillerToggle = NextKillerCard:AddToggle("Next Killer Display", false, function(p374)
		v2057(p374)
		if not (n5 < 506838874) then
			n4 = 489613420
			n2 -= 43
			n5 = 272743488
			n6 -= 1256
			n7 = 965660283
			n1 = 244260761
			;(nil)[nil  ] = nil
		end
	end, {
		Flag = "NextKillerDisplay"
	})
	MapPredictToggle = NextKillerCard:AddToggle("Next Map Prediction", false, function(p375)
		v2058(p375)
		if n5 > 340333522 then
			return
		end
		n7 -= 1431
		n4 = 873737349
		n1 -= 722
		n5 += 1377
		n2 -= 493
		n6 = 458224779
	end, {
		Flag = "NextMapPredict"
	})
	local n249
	KillerPerksToggle = NextKillerCard:AddToggle("Killer Perks Display", false, function(p376)
		n249 = 672899028
		if n5 < 591644510 then
			v2085(p376)
		else
			n6 -= 507
			n7 = 1061697539
			n249 -= 1515
			n5 = 591381614
			n3 = 66082601
			n1 -= 1094
			n2 -= 1988
			upv175 = nil
			;(nil)()
		end
	end, {
		Flag = "KillerPerkDisplay"
	})
	do
		StunToggle = NextKillerCard:AddToggle("Killer Stun Indicator", false, function(p377)
			v2154(p377)
		end, {
			Flag = "KillerStunIndicator"
		})
	end
	SpectatorToggle = NextKillerCard:AddToggle("Spectator info", false, function(p378)
		v626(p378)
		if n7 ~= 542746161 then
			n1 -= 442
			n3 = 505565296
			n2 += 1858
			n7 += 1224
			n5 = 422326163
			n6 = 582632346
		end
	end, {
		Flag = "SpectatorInfo"
	})
	TeleportTab = v14:CreateTab("Teleport", false, false)
	T_Page = TeleportTab:CreatePage("Teleport")
	TeleportMapCard = T_Page:CreateSection("Teleport Map", "map")
	TeleportMapCard:AddButton("Refresh Map Cache", function()
		v557()
		_G.Ox.Teleport.GenIndex = 1
		_G.Ox.Teleport.HookIndex = 1
		_G.Ox.Teleport.GateIndex = 1
		_G.Ox.Teleport.PalletIndex = 1
		_G.Ox.Teleport.WindowIndex = 1
		if n2 == 352573280 then
			n7 = 670793385
			n3 = 920201753
			n2 += 482
			n6 = 997701309
			n1 = 522212134
			n5 = 69376897
		else
			lib2:Notify({
				Title = "Refresh",
				Description = "Map cache refreshed!",
				Duration = 2
			})
		end
	end)
	TeleportMapCard:AddButton("Teleport to Generator", function()
		if #t2.Generators == 0 then
			v557()
		end
		if _G.Ox.Teleport.GenIndex > #t2.Generators then
			_G.Ox.Teleport.GenIndex = 1
		end
		local v2876 = t2.Generators[_G.Ox.Teleport.GenIndex]
		if v2876 and v2876.part then
			v572(v2876.part)
			lib2:Notify({
				Title = "TP Generator",
				Description = "Generator " .. _G.Ox.Teleport.GenIndex,
				Duration = 1.2
			})
		else
			lib2:Notify({
				Title = "TP Generator",
				Description = "Generator not found!",
				Duration = 2
			})
		end
		_G.Ox.Teleport.GenIndex += 1
	end)
	TeleportMapCard:AddButton("Teleport to Hook", function()
		if #t2.Hooks == 0 then
			v557()
		end
		if _G.Ox.Teleport.HookIndex > #t2.Hooks then
			_G.Ox.Teleport.HookIndex = 1
		end
		local v2877 = t2.Hooks[_G.Ox.Teleport.HookIndex]
		local HookPoint = v2877 and (v2877:FindFirstChild("HookPoint") or v2877:FindFirstChildWhichIsA("BasePart"))
		if HookPoint then
			v572(HookPoint)
			lib2:Notify({
				Title = "TP Hook",
				Description = "Hook " .. _G.Ox.Teleport.HookIndex,
				Duration = 1.2
			})
		end
		_G.Ox.Teleport.HookIndex += 1
	end)
	do
		TeleportMapCard:AddButton("Teleport to Gate", function()
			if #t2.Gates == 0 then
				v557()
			end
			if _G.Ox.Teleport.GateIndex > #t2.Gates then
				_G.Ox.Teleport.GateIndex = 1
			end
			local v2879 = t2.Gates[_G.Ox.Teleport.GateIndex]
			local BasePart = v2879 and v2879:FindFirstChildWhichIsA("BasePart")
			if BasePart then
				v572(BasePart)
				lib2:Notify({
					Title = "TP Gate",
					Description = "Gate " .. _G.Ox.Teleport.GateIndex,
					Duration = 1.2
				})
			end
			_G.Ox.Teleport.GateIndex += 1
		end)
	end
	TeleportMapCard:AddButton("Teleport to Pallet", function()
		if #t2.Pallets == 0 then
			v557()
		end
		if _G.Ox.Teleport.PalletIndex > #t2.Pallets then
			_G.Ox.Teleport.PalletIndex = 1
		end
		local v2881 = t2.Pallets[_G.Ox.Teleport.PalletIndex]
		local PrimaryPartPallet = v2881 and (v2881:FindFirstChild("PrimaryPartPallet") or v2881:FindFirstChildWhichIsA("BasePart"))
		if n5 == 808612352 then
			n7 += 369
			n2 = 305510990
			n6 += 1945
			n3 += 1664
			n5 += 1446
			n1 = 108916221
		elseif PrimaryPartPallet then
			v572(PrimaryPartPallet)
			lib2:Notify({
				Title = "TP Pallet",
				Description = "Pallet " .. _G.Ox.Teleport.PalletIndex,
				Duration = 1.2
			})
		end
		_G.Ox.Teleport.PalletIndex += 1
	end)
	TeleportMapCard:AddButton("Teleport to Window", function()
		if #t2.Windows == 0 then
			v557()
		end
		if _G.Ox.Teleport.WindowIndex > #t2.Windows then
			_G.Ox.Teleport.WindowIndex = 1
		end
		local v2883 = t2.Windows[_G.Ox.Teleport.WindowIndex]
		local Bottom = v2883 and (v2883:FindFirstChild("Bottom") or v2883:FindFirstChildWhichIsA("BasePart"))
		if Bottom then
			v572(Bottom)
			lib2:Notify({
				Title = "TP Window",
				Description = "Window " .. _G.Ox.Teleport.WindowIndex,
				Duration = 1.2
			})
		end
		_G.Ox.Teleport.WindowIndex += 1
	end)
	PlayerCard = T_Page:CreateSection("Teleport Player", "users")
	do
		local u2885
		local t34 = {}
		local function v2887()
			t34 = {}
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					table.insert(t34, player.Name)
				end
			end
			table.sort(t34)
		end
		v2887()
		PlayerDropdown = PlayerCard:AddDropdown("Pick Player", t34, false, function(p379)
			u2885 = p379
		end)
		PlayerCard:AddButton("Refresh Player List", function()
			local n250 = 726065652
			v2887()
			local n251 = 90707848
			local n252 = 986099608
			local n253 = 340329494
			pcall(function()
				if PlayerDropdown.Refresh then
					PlayerDropdown:Refresh(t34)
				elseif PlayerDropdown.SetValues then
					PlayerDropdown:SetValues(t34)
				elseif PlayerDropdown.SetOptions then
					PlayerDropdown:SetOptions(t34)
				elseif PlayerDropdown.Update then
					PlayerDropdown:Update(t34)
				end
				if n252 == 986099608 then
					return
				end
				n250 = 508313171
				n252 = 473215367
				n6 = 1053197318
				n251 += 1834
				n253 = 787589221
				n5 -= 1899
			end)
			if n5 == 403422737 then
				lib2:Notify({
					Title = "Refresh",
					Description = "Player list refreshed! (" .. #t34 .. " player)",
					Duration = 2
				})
			else
				n4 = 825568172
				n7 += 1897
				n6 = 279751358
				n1 = 623878357
				n252 = 797667809
				n2 = 397740454
				n250 -= 1632
				n5 -= 1542
				n251 -= 26
				n253 += 61
				upv224[nil] = nil
			end
		end)
		Players.PlayerAdded:Connect(function()
			task.wait(0.3)
			v2887()
			if n6 ~= 295005353 then
				pcall(function()
					if PlayerDropdown.Refresh then
						PlayerDropdown:Refresh(t34)
					end
				end)
				return
			end
			n1 = 844873779
			n5 += 484
			n3 = 224394142
			n6 = 964258900
			n7 += 147
			n2 -= 1047
			LPH_CRASH()
		end)
		Players.PlayerRemoving:Connect(function()
			task.wait(0.1)
			v2887()
			pcall(function()
				if PlayerDropdown.Refresh then
					PlayerDropdown:Refresh(t34)
				end
			end)
		end)
		PlayerCard:AddButton("Teleport to Player", function()
			if not u2885 or u2885 == "" then
				lib2:Notify({
					Title = "Error",
					Description = "Pick a player first!",
					Duration = 3
				})
				return
			end
			local v2894 = Players:FindFirstChild(u2885)
			if v2894 and v2894.Character then
				if not v2894.Character:FindFirstChild("HumanoidRootPart") then
					lib2:Notify({
						Title = "Error",
						Description = "Invalid target!",
						Duration = 2
					})
					return
				end
				local Character = LocalPlayer.Character
				if Character and Character:FindFirstChild("HumanoidRootPart") then
					Character.HumanoidRootPart.CFrame = v2894.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
					lib2:Notify({
						Title = "Teleport",
						Description = "To " .. u2885,
						Duration = 2
					})
				end
			else
				lib2:Notify({
					Title = "Error",
					Description = "Invalid target!",
					Duration = 2
				})
			end
		end)
	end
	SettingsTab = v14:CreateTab("Settings", false, false)
	S_Page1 = SettingsTab:CreatePage("Settings")
	AppearanceCard = S_Page1:CreateSection("UI Config", "sliders-vertical")
	AppearanceCard:AddKeybind("Menu Keybind", "RightShift", function(p380)
		v14:SetMenuKey(p380)
	end, {
		Flag = "MenuKeybing"
	})
	AppearanceCard:AddToggle("Transparency Toggle", false, function(p381)
		v14:SetTransparency(p381 and 0.2 or 0)
	end, {
		Flag = "ToggleTransparancy"
	})
	AppearanceCard:AddToggle("Lock GUI", false, function(p382)
		v14:SetLocked(p382)
	end, {
		Flag = "LockGui"
	})
	AppearanceCard:AddToggle("Watermark", true, function(p383)
		lib2:SetWatermark({
			Enabled = p383
		})
	end, {
		Flag = "Watermark"
	})
	SavesCard = S_Page1:CreateSection("Config", "sliders-vertical")
	SavesCard:AddConfigManager("TempoHub/Configs")
	task.spawn(function()
		task.wait(2)
		v557()
	end)
	LocalPlayer.CharacterAdded:Connect(function()
		_G.Ox.State.busy = false
		_G.Ox.State.RandomMode_IsNormal = false
		if _G.Ox.Auto.SkillCheck then
			task.wait(1)
			v787()
		end
		local v2896 = n7
		if n4 ~= v2896 then
			return
		end
		n7 += 208
		n4 += 2011
		n5 -= 1370
		n3 = 193044847
		n2 += 1071
		n6 = 119319946
		return v2896
	end)
	LocalPlayer.CharacterAdded:Connect(function()
		task.wait(1.5)
		if _G.Ox.NoSlowdownEnabled then
			local Character = LocalPlayer.Character
			if Character then
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				if Humanoid then
					Humanoid.WalkSpeed = 16
				end
			end
		end
		if n2 < n7 then
			return
		end
		n5 -= 357
		n1 = 1073045946
		n4 += 1643
		n2 -= 395
		n6 -= 1466
		n7 = 971544521
	end)
	local n254
	LocalPlayer.CharacterAdded:Connect(function()
		n254 = 368528803
		local n255 = 165561862
		task.wait(1.5)
		if _G.Ox.BypassLeapEnabled then
			if n255 < n5 then
				v1245()
			else
				n7 = 780661225
				n6 -= 1680
				n254 += 192
				n2 -= 331
				n1 = 202439321
				n5 = 533769673
				n3 = 684592113
				upv426[nil  ] = nil
				upv126 = nil
			end
		end
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton2 and _G.Ox.Config.Surv_Aimbot_Enabled and GetRole() == "Survivor" then
			_G.Ox.isAimbotHolding = true
			_G.Ox.lockedAimbotTarget = getBestAimbotTarget()
		end
	end)
	do
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				_G.Ox.isAimbotHolding = false
				_G.Ox.lockedAimbotTarget = nil
				if _G.Ox.survivorAimbotHighlight then
					_G.Ox.survivorAimbotHighlight.Parent = nil
				end
			end
		end)
	end
	local n256
	task.spawn(function()
		n256 = 472275653
		while true do
			if not _G.Ox.ScriptAlive then
				return
			end
			if n3 == n6 then
				break
			end
			task.wait(1)
			if not _G.Ox.ScriptAlive then
				return
			end
			if not _G.Ox.Config.Surv_Aimbot_Enabled or GetRole() ~= "Survivor" or not UserInputService.TouchEnabled then
				if _G.Ox.isAimbotHolding and UserInputService.TouchEnabled then
					_G.Ox.isAimbotHolding = false
					_G.Ox.lockedAimbotTarget = nil
					if _G.Ox.survivorAimbotHighlight then
						_G.Ox.survivorAimbotHighlight.Parent = nil
					end
				end
				continue
			end
			local exitTo
			repeat
				local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
				if PlayerGui2 then
					local SurvivorMob = PlayerGui2:FindFirstChild("Survivor-mob")
					if SurvivorMob then
						local Controls = SurvivorMob:FindFirstChild("Controls")
						if Controls then
							local attack = Controls:FindFirstChild("attack") or Controls:FindFirstChild("Gui-mob")
							if not attack or not attack.Visible then
								if _G.Ox.isAimbotHolding then
									_G.Ox.isAimbotHolding = false
									_G.Ox.lockedAimbotTarget = nil
									if _G.Ox.survivorAimbotHighlight then
										_G.Ox.survivorAimbotHighlight.Parent = nil
									end
								end
							elseif not _G.Ox.isAimbotHolding then
								_G.Ox.isAimbotHolding = true
								_G.Ox.lockedAimbotTarget = getBestAimbotTarget()
							end
						end
					end
				end
				exitTo = nil
				while _G.Ox.ScriptAlive do
					task.wait(1)
					if not _G.Ox.ScriptAlive then
						break
					end
					if not _G.Ox.Config.Surv_Aimbot_Enabled or GetRole() ~= "Survivor" or not UserInputService.TouchEnabled then
						if _G.Ox.isAimbotHolding and UserInputService.TouchEnabled then
							_G.Ox.isAimbotHolding = false
							_G.Ox.lockedAimbotTarget = nil
							if _G.Ox.survivorAimbotHighlight then
								_G.Ox.survivorAimbotHighlight.Parent = nil
							end
						end
						continue
					end
					exitTo = 1
					break
				end
			until exitTo ~= 1
			return
		end
		n4 = 210123877
		n7 += 1598
		n6 += 1934
		n1 = 317071224
		n3 -= 1513
		n256 += 1635
		n5 += 927
		;(nil)(nil)
	end)
	do
		local u2907
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			local v2908 = input.UserInputType == Enum.UserInputType.Touch
			local v2909 = GetRole()
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if gameProcessed then
					return
				end
				if v2909 == "Killer" and _G.Ox.Config.Killer_Aimbot_Enabled then
					_G.Ox.lockedKillerAimbotTarget = getBestKillerAimbotTarget()
					if _G.Ox.lockedKillerAimbotTarget then
						_G.Ox.isKillerAimbotHolding = true
					end
				end
			end
			if v2908 and v2909 == "Killer" and _G.Ox.Config.Killer_Aimbot_Enabled then
				local PlayerGui2 = LocalPlayer:FindFirstChild("PlayerGui")
				local v2911
				if PlayerGui2 then
					for _, child in pairs(PlayerGui2:GetChildren()) do
						if string.sub(child.Name, -4) == "-mob" and child.Name ~= "Survivor-mob" then
							v2911 = child
							break
						end
					end
				end
				local attack = v2911 and v2911:FindFirstChild("Controls") and v2911.Controls:FindFirstChild("attack")
				if attack and attack.Visible then
					local Position = input.Position
					local AbsolutePosition = attack.AbsolutePosition
					local AbsoluteSize = attack.AbsoluteSize
					if AbsolutePosition.X <= Position.X and Position.X <= AbsolutePosition.X + AbsoluteSize.X and AbsolutePosition.Y <= Position.Y and Position.Y <= AbsolutePosition.Y + AbsoluteSize.Y then
						_G.Ox.lockedKillerAimbotTarget = getBestKillerAimbotTarget()
						if _G.Ox.lockedKillerAimbotTarget then
							_G.Ox.isKillerAimbotHolding = true
							u2907 = input
						end
					end
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				_G.Ox.isKillerAimbotHolding = false
				_G.Ox.lockedKillerAimbotTarget = nil
				if _G.Ox.killerAimbotHighlight then
					_G.Ox.killerAimbotHighlight.Parent = nil
				end
			end
			if input.UserInputType == Enum.UserInputType.Touch and input == u2907 then
				_G.Ox.isKillerAimbotHolding = false
				_G.Ox.lockedKillerAimbotTarget = nil
				u2907 = nil
				if _G.Ox.killerAimbotHighlight then
					_G.Ox.killerAimbotHighlight.Parent = nil
				end
			end
		end)
	end
	v18.CharacterAdded:Connect(function()
		task.wait(1.5)
		ReapplyPerformanceDelayed()
		if n6 == 295006299 then
			n1 = 207396565
			n7 -= 1899
			n6 += 824
			n2 = 391783129
			n5 -= 706
			n3 += 1476
		end
	end)
	local n257
	workspace.ChildAdded:Connect(function(child)
		n257 = 907348272
		if n6 < n1 then
			if child.Name == "Map" then
				task.wait(1)
				ReapplyPerformanceDelayed()
			end
			return
		end
		n4 -= 375
		n6 = 824239284
		n257 += 524
		n5 += 1602
		n2 += 340
		n7 = 17251081
		n1 -= 795
		return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
	end)
	task.spawn(function()
		task.wait(2)
		ReapplyPerformanceDelayed()
	end)
	lib2:Notify({
		Title = "Tempo Hub",
		Description = "Loaded",
		Duration = 3
	})
end
v11()
pcall(function() UI:mountInterface(UI:Tab("Interface", "sliders")) end)
