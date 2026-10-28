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
local TeekUI = assert(
	loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))(),
	"TempoUI failed"
)
local UI = TeekUI.new({
	Title = "TEMPO",
	Subtitle = "Defusal",
	Version = "v1",
})
local a = os.clock()
cloneref = cloneref or function(b) return b end
local RS = cloneref(game:GetService("ReplicatedStorage"))
local CS = cloneref(game:GetService("CollectionService"))
local UIS = cloneref(game:GetService("UserInputService"))
local RF = cloneref(game:GetService("ReplicatedFirst"))
local NC = cloneref(game:GetService("NetworkClient"))
local TS = cloneref(game:GetService("TweenService"))
local RunS = cloneref(game:GetService("RunService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Players = cloneref(game:GetService("Players"))
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Cam = workspace.CurrentCamera
local origAmbient, origOutdoor, origClock = Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.ClockTime
local Flags = {}
local Lists = { Priority = {}, Friend = {} }
local sharedSettings = { prioritiesColor = Color3.fromRGB(245, 239, 120), textFont = 1, textSize = 13, showPriorities = false }
local holdBinds = {}
local tabs = {}
local function hexOf(c)
	local ok, h = pcall(function() return c:ToHex() end)
	if ok and h then return h end
	local r = math.clamp(math.floor(c.R * 255 + 0.5), 0, 255)
	local g = math.clamp(math.floor(c.G * 255 + 0.5), 0, 255)
	local b = math.clamp(math.floor(c.B * 255 + 0.5), 0, 255)
	return string.format("%02X%02X%02X", r, g, b)
end
if not Color3.fromHex then
	function Color3.fromHex(hex)
		hex = tostring(hex or "FFFFFF"):gsub("#", "")
		if #hex < 6 then return Color3.new(1, 1, 1) end
		return Color3.fromRGB(
			tonumber(hex:sub(1, 2), 16) or 255,
			tonumber(hex:sub(3, 4), 16) or 255,
			tonumber(hex:sub(5, 6), 16) or 255
		)
	end
end
local function colorObj(defaultColor, callback)
	local obj = {}
	obj.Color = defaultColor or Color3.new(1, 1, 1)
	obj.HexValue = hexOf(obj.Color)
	obj.Alpha = 1
	function obj:Set(c, alpha)
		if typeof(c) == "Color3" then obj.Color = c end
		if type(alpha) == "number" then obj.Alpha = alpha end
		obj.HexValue = hexOf(obj.Color)
		if callback then pcall(callback, obj, obj.Alpha) end
	end
	return obj
end
local function keybindObj(flagName, mode, defaultKey)
	local kb = {
		Toggled = false,
		Mode = mode or "Hold",
		Key = defaultKey or Enum.KeyCode.E,
		Name = flagName,
	}
	return kb
end
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	for _, kb in pairs(holdBinds) do
		if kb.Key and input.KeyCode == kb.Key then
			if kb.Mode == "Toggle" then
				kb.Toggled = not kb.Toggled
			else
				kb.Toggled = true
			end
		end
	end
end)
UIS.InputEnded:Connect(function(input)
	for _, kb in pairs(holdBinds) do
		if kb.Key and input.KeyCode == kb.Key and kb.Mode ~= "Toggle" then
			kb.Toggled = false
		end
	end
end)
local function ensureTab(name, icon)
	if tabs[name] then return tabs[name] end
	local iconMap = {
		Legit = "crosshair", Rage = "flame", Visuals = "eye",
		Misc = "wrench", Skins = "palette", Players = "users", Settings = "sliders",
	}
	local tab = UI:Tab(name, icon or iconMap[name] or "circle")
	tabs[name] = tab
	return tab
end
local function attachKeybind(tab, holder)
	function holder:Keybind(kopts)
		kopts = kopts or {}
		local kflag = kopts.Flag
		local kb = keybindObj(kflag, kopts.Mode or "Hold", kopts.Default)
		if kflag then Flags[kflag] = kb end
		table.insert(holdBinds, kb)
		pcall(function()
			tab:Label((kopts.Name or kflag or "Keybind") .. " [Key: " .. tostring(kb.Key.Name) .. "]")
		end)
		return kb
	end
	return holder
end
local function attachColorpicker(tab, holder)
	function holder:Colorpicker(copts)
		copts = copts or {}
		local cflag = copts.Flag
		local col = colorObj(copts.Default or Color3.new(1, 1, 1), copts.Callback)
		if typeof(copts.Default) == "Color3" then
			col.Color = copts.Default
			col.HexValue = hexOf(col.Color)
		end
		if cflag then Flags[cflag] = col end
		pcall(function() tab:Label(copts.Name or cflag or "Color") end)
		return col
	end
	return holder
end
local function chainControl(tab)
	local holder = {}
	attachKeybind(tab, holder)
	attachColorpicker(tab, holder)
	return holder
end
local function sectionApi(tab)
	local api = {}
	function api:Toggle(opts)
		opts = opts or {}
		local flag = opts.Flag
		local default = opts.Default
		if default == nil then default = false end
		if flag then Flags[flag] = default and true or false end
		local toggleResult = chainControl(tab)
		pcall(function()
			tab:Toggle(opts.Name or flag or "Toggle", default and true or false, function(v)
				local on = v and true or false
				if flag then Flags[flag] = on end
				if opts.Callback then pcall(opts.Callback, on) end
			end)
		end)
		return toggleResult
	end
	function api:Slider(opts)
		opts = opts or {}
		local flag = opts.Flag
		local min = tonumber(opts.Min) or 0
		local max = tonumber(opts.Max) or 100
		local default = tonumber(opts.Default)
		if default == nil then default = min end
		if flag then Flags[flag] = default end
		pcall(function()
			tab:Slider(opts.Name or flag or "Slider", min, max, default, function(v)
				if flag then Flags[flag] = v end
				if opts.Callback then pcall(opts.Callback, v) end
			end)
		end)
		return chainControl(tab)
	end
	function api:Dropdown(opts)
		opts = opts or {}
		local flag = opts.Flag
		local items = opts.Items or {}
		local default = opts.Default
		if default == nil and type(items) == "table" then default = items[1] end
		if flag then Flags[flag] = default end
		pcall(function()
			if tab.Dropdown then
				tab:Dropdown(opts.Name or flag or "Dropdown", items, default, function(v)
					if flag then Flags[flag] = v end
					if opts.Callback then pcall(opts.Callback, v) end
				end)
			else
				tab:Label((opts.Name or flag or "Dropdown") .. ": " .. tostring(default))
				if type(items) == "table" then
					for _, item in ipairs(items) do
						local capture = item
						tab:Button(tostring(capture), false, function()
							if flag then Flags[flag] = capture end
							if opts.Callback then pcall(opts.Callback, capture) end
						end)
					end
				end
			end
		end)
		return chainControl(tab)
	end
	function api:Label(opts)
		opts = opts or {}
		pcall(function() tab:Label(opts.Text or opts.Name or "") end)
		return chainControl(tab)
	end
	function api:Button(opts)
		opts = opts or {}
		pcall(function()
			tab:Button(opts.Name or "Button", false, function()
				if opts.Callback then pcall(opts.Callback) end
			end)
		end)
		return chainControl(tab)
	end
	function api:Textbox(opts)
		opts = opts or {}
		local flag = opts.Flag
		if flag and Flags[flag] == nil then Flags[flag] = opts.Default or "" end
		pcall(function()
			if tab.Input then
				tab:Input(opts.Name or flag or "Input", 120, function(txt)
					if flag then Flags[flag] = txt end
					if opts.Callback then pcall(opts.Callback, txt) end
				end)
			else
				tab:Label((opts.Name or flag or "Input") .. " = " .. tostring(Flags[flag] or ""))
			end
		end)
		return chainControl(tab)
	end
	function api:Listbox(opts)
		opts = opts or {}
		local items = opts.Items or {}
		local selected = opts.Default
		pcall(function()
			tab:Label(opts.Name or "List")
			for _, item in ipairs(items) do
				local capture = item
				tab:Button(tostring(capture), false, function()
					selected = capture
					if opts.Callback then pcall(opts.Callback, capture) end
				end)
			end
		end)
		return chainControl(tab)
	end
	return api
end
local pageApi = {}
function pageApi:Section(opts)
	opts = opts or {}
	local tab = self._tab
	pcall(function() tab:Section(opts.Name or "Section") end)
	return sectionApi(tab)
end
function pageApi:PlayerList(opts)
	opts = opts or {}
	local tab = self._tab
	pcall(function() tab:Section(opts.Name or "Player List") end)
	local function refresh()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP then
				local name = plr.Name
				pcall(function()
					tab:Button(name .. " [Priority]", false, function()
						local found = false
						for i, p in ipairs(Lists.Priority) do
							if p == plr then table.remove(Lists.Priority, i) found = true break end
						end
						if not found then table.insert(Lists.Priority, plr) end
						UI:Notify(name .. (found and " removed from Priority" or " added to Priority"), "good")
					end)
					tab:Button(name .. " [Friend]", false, function()
						local found = false
						for i, p in ipairs(Lists.Friend) do
							if p == plr then table.remove(Lists.Friend, i) found = true break end
						end
						if not found then table.insert(Lists.Friend, plr) end
						UI:Notify(name .. (found and " removed from Friend" or " added to Friend"), "good")
					end)
				end)
			end
		end
	end
	refresh()
	Players.PlayerAdded:Connect(function() task.wait(0.5) refresh() end)
	return sectionApi(tab)
end
local windowApi = {}
function windowApi:Page(opts)
	opts = opts or {}
	local tab = ensureTab(opts.Name or "Tab")
	return setmetatable({ _tab = tab }, { __index = pageApi })
end
function windowApi:SetVisibility(v) end
local watermarkApi = { SetVisibility = function() end }
local keybindListApi = { SetVisibility = function() end }
local s = {}
s.Flags = Flags
s.Lists = Lists
s.sharedSettings = sharedSettings
s.Theme = {
	Accent = Color3.fromRGB(149, 255, 139),
	Background = Color3.fromRGB(20, 20, 25),
	Text = Color3.fromRGB(255, 255, 255),
}
s.Themes = {
	Default = { Accent = Color3.fromRGB(149, 255, 139), Background = Color3.fromRGB(20, 20, 25), Text = Color3.fromRGB(255, 255, 255) },
	Bitchbot = { Accent = Color3.fromRGB(255, 100, 100), Background = Color3.fromRGB(15, 15, 20), Text = Color3.fromRGB(255, 255, 255) },
	Onetap = { Accent = Color3.fromRGB(255, 170, 0), Background = Color3.fromRGB(25, 25, 30), Text = Color3.fromRGB(255, 255, 255) },
	Aqua = { Accent = Color3.fromRGB(0, 200, 255), Background = Color3.fromRGB(10, 20, 30), Text = Color3.fromRGB(255, 255, 255) },
}
s.ThemeColorpickers = {}
s.Folders = { Themes = "TEMPO/Themes", Configs = "TEMPO/Configs" }
s.Tween = { Style = Enum.EasingStyle.Exponential, Direction = Enum.EasingDirection.Out, Time = 0.12 }
s.MenuKeybind = Enum.KeyCode.RightShift
function s:Window(opts) return windowApi end
function s:Watermark(...) return watermarkApi end
function s:KeybindList(...) return keybindListApi end
function s:Notification(text, duration, color, icon)
	pcall(function() UI:Notify(tostring(text), "good") end)
end
function s:ChangeTheme(name, color) end
function s:GetTheme() return "{}" end
function s:LoadTheme(data) end
function s:RefreshThemeList(listbox) end
function s:GetConfig() return "{}" end
function s:LoadConfig(data) end
function s:SaveConfig(name) end
function s:DeleteConfig(name) end
function s:RefreshConfigsList(listbox) end
function s:Thread(fn) task.spawn(fn) end
function s:Unload() pcall(function() UI:Destroy() end) end
local u = nil
pcall(function()
	u = loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Games/lib/SiriusESP.lua"))()
end)
if type(u) ~= "table" then u = {} end
if u.sharedSettings == nil then u.sharedSettings = sharedSettings end
local function espStub()
	return {
		enabled = false, box = false, box3d = false,
		boxColor = { Color3.new(1, 1, 1) }, box3dColor = { Color3.new(1, 1, 1) },
		name = false, nameColor = { Color3.new(1, 1, 1) },
		weapon = false, weaponColor = { Color3.new(1, 1, 1) },
		distance = false, distanceColor = { Color3.new(1, 1, 1) },
		healthBar = false, healthyColor = Color3.new(0, 1, 0), dyingColor = Color3.new(1, 0, 0),
		healthText = false, healthTextColor = { Color3.new(1, 1, 1) },
		chams = false,
		chamsOutlineColor = { Color3.new(1, 1, 1), 0.5 },
		chamsFillColor = { Color3.new(1, 1, 1), 0.5 },
	}
end
if type(u.teamSettings) ~= "table" then u.teamSettings = { enemy = espStub(), team = espStub() } end
if u.teamSettings.enemy == nil then u.teamSettings.enemy = espStub() end
if u.teamSettings.team == nil then u.teamSettings.team = espStub() end
if type(u.Load) ~= "function" then u.Load = function() end end
if type(u.priorities) ~= "table" then u.priorities = {} end
local t = Flags
local v = windowApi
local w = watermarkApi
local x = keybindListApi
pcall(function()
	if UI.Boot then
		UI:Boot({ "checking executor", "building interface", "loading modules", "ready" }, function()
			UI:Notify("TEMPO | Defusal loaded", "good")
		end)
	else
		UI:Notify("TEMPO | Defusal loaded", "good")
	end
end)
local r = {}
do
	r.WeaponTextures = {
		["Red + White"] = "rbxassetid://73492024663403",
		["Black + Grey"] = "rbxassetid://99819667028441",
		Web = "rbxassetid://81960247728644",
		Pink = "rbxassetid://14003986744",
		Violet = "rbxassetid://18876565862",
		Lego = "rbxassetid://13654261927",
		["Red + Black"] = "rbxassetid://18993843644",
		["Dark Blue + Black"] = "rbxassetid://12703804272",
		Shark = "rbxassetid://12859888187",
		Camo = "rbxassetid://1848173837",
		Lava = "rbxassetid://5013453655",
		["Black + White Leaves"] = "rbxassetid://1982429041",
		Red = "rbxassetid://4786129416",
	}
	r.Sounds = {
		["Default Hit Sound"] = (function()
			local folder = RS:FindFirstChild("Sounds")
			local hit = folder and folder:FindFirstChild("HitSound")
			return hit and tostring(hit.Value) or ""
		end)(),
		["Default Kill Sound"] = (function()
			local folder = RS:FindFirstChild("Sounds")
			local kill = folder and folder:FindFirstChild("KillSound")
			return kill and tostring(kill.Value) or ""
		end)(),
		Bameware = "rbxassetid://3124331820",
		Bell = "rbxassetid://6534947240",
		Bubble = "rbxassetid://6534947588",
		Pick = "rbxassetid://1347140027",
		Pop = "rbxassetid://198598793",
		Rust = "rbxassetid://1255040462",
		Skeet = "rbxassetid://5447626464",
		["Mario Coin"] = "rbxassetid://5709456554",
		["COD Hitmarker"] = "rbxassetid://160432334",
		["Minecraft XP"] = "rbxassetid://1053296915",
		Neverlose = "rbxassetid://6607204501",
		Fatality = "rbxassetid://6534947869",
	}
	r.BulletTracersTextures = {
		Line = "rbxassetid://9150663556",
		Neyrone = "rbxassetid://1825953680",
		Lighting = "rbxassetid://446111271",
		Tracer = "ForceField",
	}
	r.Skyboxes = {
		["--"] = {},
		Galaxy = {
			SkyboxBk = "rbxassetid://159454299", SkyboxDn = "rbxassetid://159454296",
			SkyboxFt = "rbxassetid://159454293", SkyboxLf = "rbxassetid://159454286",
			SkyboxRt = "rbxassetid://159454300", SkyboxUp = "rbxassetid://159454288",
		},
		Purple = {
			SkyboxBk = "rbxassetid://570557514", SkyboxDn = "rbxassetid://570557775",
			SkyboxFt = "rbxassetid://570557559", SkyboxLf = "rbxassetid://570557620",
			SkyboxRt = "rbxassetid://570557672", SkyboxUp = "rbxassetid://570557727",
		},
		["Purple Night"] = {
			SkyboxBk = "rbxassetid://296908715", SkyboxDn = "rbxassetid://296908724",
			SkyboxFt = "rbxassetid://296908740", SkyboxLf = "rbxassetid://296908755",
			SkyboxRt = "rbxassetid://296908764", SkyboxUp = "rbxassetid://296908769",
		},
		["Night Sky"] = {
			SkyboxBk = "rbxassetid://12064107", SkyboxDn = "rbxassetid://12064152",
			SkyboxFt = "rbxassetid://12064121", SkyboxLf = "rbxassetid://12063984",
			SkyboxRt = "rbxassetid://12064115", SkyboxUp = "rbxassetid://12064131",
		},
		["Pink Daylight"] = {
			SkyboxBk = "rbxassetid://271042516", SkyboxDn = "rbxassetid://271077243",
			SkyboxFt = "rbxassetid://271042556", SkyboxLf = "rbxassetid://271042310",
			SkyboxRt = "rbxassetid://271042467", SkyboxUp = "rbxassetid://271077958",
		},
		["Morning Glow"] = {
			SkyboxBk = "rbxassetid://1417494030", SkyboxDn = "rbxassetid://1417494146",
			SkyboxFt = "rbxassetid://1417494253", SkyboxLf = "rbxassetid://1417494402",
			SkyboxRt = "rbxassetid://1417494499", SkyboxUp = "rbxassetid://1417494643",
		},
		["Setting Sun"] = {
			SkyboxBk = "rbxassetid://626460377", SkyboxDn = "rbxassetid://626460216",
			SkyboxFt = "rbxassetid://626460513", SkyboxLf = "rbxassetid://626473032",
			SkyboxRt = "rbxassetid://626458639", SkyboxUp = "rbxassetid://626460625",
		},
		["Fade Blue"] = {
			SkyboxBk = "rbxassetid://153695414", SkyboxDn = "rbxassetid://153695352",
			SkyboxFt = "rbxassetid://153695452", SkyboxLf = "rbxassetid://153695320",
			SkyboxRt = "rbxassetid://153695383", SkyboxUp = "rbxassetid://153695471",
		},
		["Elegant Morning"] = {
			SkyboxBk = "rbxassetid://153767241", SkyboxDn = "rbxassetid://153767216",
			SkyboxFt = "rbxassetid://153767266", SkyboxLf = "rbxassetid://153767200",
			SkyboxRt = "rbxassetid://153767231", SkyboxUp = "rbxassetid://153767288",
		},
		Neptune = {
			SkyboxBk = "rbxassetid://218955819", SkyboxDn = "rbxassetid://218953419",
			SkyboxFt = "rbxassetid://218954524", SkyboxLf = "rbxassetid://218958493",
			SkyboxRt = "rbxassetid://218957134", SkyboxUp = "rbxassetid://218950090",
		},
		Redshift = {
			SkyboxBk = "rbxassetid://401664839", SkyboxDn = "rbxassetid://401664862",
			SkyboxFt = "rbxassetid://401664960", SkyboxLf = "rbxassetid://401664881",
			SkyboxRt = "rbxassetid://401664901", SkyboxUp = "rbxassetid://401664936",
		},
		["Aesthetic Night"] = {
			SkyboxBk = "rbxassetid://1045964490", SkyboxDn = "rbxassetid://1045964368",
			SkyboxFt = "rbxassetid://1045964655", SkyboxLf = "rbxassetid://1045964655",
			SkyboxRt = "rbxassetid://1045964655", SkyboxUp = "rbxassetid://1045962969",
		},
	}
	r.Game = {
		Network = nil, Ambassador = nil, Variables = nil, Shucky = nil, Appearance = nil,
		BaseWeapon = nil, Viewmodel = nil,
		SkinsData = {
			Weapons = { List = {}, Replacements = {}, Settings = {} },
			Knives = { List = {}, Replacements = {}, Settings = {}, CurrentKnifeType = nil },
			Gloves = { List = {}, Settings = {}, CurrentGloves = nil },
		},
		BuyZone = (function()
			local ok, v = pcall(function() return LP.PlayerGui.HUD.Bottom.BuyNow end)
			return ok and v or nil
		end)(),
		EquippedWeapon = nil,
		EquippedWeaponFolder = nil,
		IsAlive = function(s)
			return s.Character
				and s.Character:FindFirstChild("Head")
				and s.Character:FindFirstChild("HumanoidRootPart")
				and s.Character:FindFirstChild("Torso")
				and s.Character:FindFirstChild("Humanoid")
				and s:GetAttribute("Health") > 0
				and s:GetAttribute("Team") ~= "Spectator"
				and s:GetAttribute("Alive")
		end,
		IsC4Planted = function()
			return workspace.Debris:FindFirstChild("PlantedC4")
		end,
		IsDM = function()
			return RS:GetAttribute("NoTKPenalty")
		end,
	}
	r.Client = {
		HasRequire = true, FullRequire = true,
		HasGetsenv = true, FullGetsenv = true,
		HasMousemoverel = true, HasHookmetamethod = true, HasHookfunction = true,
	}
	do
		if require then
			local ok1 = pcall(function() r.Game.Network = require(RF.Network) end)
			local ok2 = pcall(function() r.Game.Ambassador = require(RF.Ambassador) end)
			local ok3 = pcall(function() r.Game.Variables = require(RF.Variables) end)
			pcall(function() r.Game.Shucky = require(RS.Modules.Shucky) end)
			pcall(function() r.Game.Appearance = require(RS.Modules.Appearance) end)
			if not ok1 or not ok2 or not ok3 then r.Client.FullRequire = false end
		else
			r.Client.HasRequire = false
			r.Client.FullRequire = false
		end
		if getsenv then
			local ok = pcall(function()
				r.Game.BaseWeapon = getsenv(LP.PlayerScripts.PlayerBase.BaseWeapon)
			end)
			if not ok or not r.Game.BaseWeapon or not r.Game.BaseWeapon.firebullet then
				r.Client.FullGetsenv = false
			end
		else
			r.Client.HasGetsenv = false
			r.Client.FullGetsenv = false
		end
		if not mousemoverel then r.Client.HasMousemoverel = false end
		if not hookmetamethod then r.Client.HasHookmetamethod = false end
		if not hookfunction then r.Client.HasHookfunction = false end
	end
	for _, t in next, (RS:FindFirstChild("Weapons") and RS.Weapons:GetChildren() or {}) do
		if t:GetAttribute("WeaponType") == "Melee" then
			table.insert(r.Game.SkinsData.Knives.List, t.Name)
		end
	end
	for _, t in next, (RS:FindFirstChild("Gloves") and RS.Gloves:GetChildren() or {}) do
		table.insert(r.Game.SkinsData.Gloves.List, t.Name)
	end
	r.Game.GetFireEvent = function()
		if r.Client.HasRequire and (r.Game.Shucky and r.Game.Shucky.activateresult)
			and debug and debug.getupvalue and setthreadidentity then
			local old = getthreadidentity()
			setthreadidentity(2)
			local fn = debug.getupvalue(r.Game.Shucky.activateresult, 5)
			local rem = fn()
			setthreadidentity(old)
			return rem
		else
			local function weaponFireRemoteNameFromSeed(seed)
				local t, u = math.max(1, math.floor(seed) % 2147483647), {}
				for v = 1, 24 do
					t = t * 48271 % 2147483647
					local w = t % 62 + 1
					u[v] = string.sub("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", w, w)
				end
				return "sus_" .. table.concat(u)
			end
			local function getWeaponFireRemote()
				local seed = RS:GetAttribute("AmongUsSauce")
				while typeof(seed) ~= "number" do
					RS:GetAttributeChangedSignal("AmongUsSauce"):Wait()
					seed = RS:GetAttribute("AmongUsSauce")
				end
				return RS:WaitForChild("Events"):WaitForChild(weaponFireRemoteNameFromSeed(seed))
			end
			return getWeaponFireRemote()
		end
	end
	r.Game.FireEvent = r.Game.GetFireEvent()
	RS:GetAttributeChangedSignal("AmongUsSauce"):Connect(function()
		r.Game.FireEvent = r.Game.GetFireEvent()
	end)
	if r.Game.IsAlive(LP) then
		r.Game.EquippedWeapon = LP.Character:GetAttribute("WhatGun")
		r.Game.EquippedWeaponFolder = RS.Weapons:FindFirstChild(r.Game.EquippedWeapon)
	end
	if LP.Character then
		LP.Character:GetAttributeChangedSignal("WhatGun"):Connect(function()
			if not r.Game.IsAlive(LP) then return end
			r.Game.EquippedWeapon = LP.Character:GetAttribute("WhatGun")
			r.Game.EquippedWeaponFolder = RS.Weapons:FindFirstChild(r.Game.EquippedWeapon)
		end)
	end
	LP.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		char:GetAttributeChangedSignal("WhatGun"):Connect(function()
			if not r.Game.IsAlive(LP) then return end
			r.Game.EquippedWeapon = char:GetAttribute("WhatGun")
			r.Game.EquippedWeaponFolder = RS.Weapons:FindFirstChild(r.Game.EquippedWeapon)
		end)
	end)
end
pcall(function() NC:SetOutgoingKBPSLimit(0) end)
pcall(function() LP.PlayerScripts.ImAFKBruh.Disabled = true end)
pcall(function()
	LP.PlayerScripts.ImAFKBruh:GetPropertyChangedSignal("Disabled"):Connect(function()
		pcall(function() LP.PlayerScripts.ImAFKBruh.Disabled = true end)
	end)
end)
local LegitPage = v:Page({ Name = "Legit", Columns = 2 })
local RagePage = v:Page({ Name = "Rage", Columns = 2 })
local VisualsPage = v:Page({ Name = "Visuals", Columns = 2 })
local MiscPage = v:Page({ Name = "Misc", Columns = 2 })
local SkinsPage = v:Page({ Name = "Skins", Columns = 2 })
local PlayersPage = v:Page({ Name = "Players", Columns = 1 })
local SettingsPage = v:Page({ Name = "Settings", Columns = 2 })
do
	local F = LegitPage:Section({ Name = "Silent Aim", Side = 1 })
	if r.Client.HasHookmetamethod then
		F:Toggle({ Name = "Enabled", Flag = "Legit/SilentAim", Default = false })
		F:Slider({ Name = "Hit Chance", Flag = "Legit/SilentAim/HitChance", Min = 0, Default = 100, Max = 100 })
		F:Dropdown({ Name = "Hitscan", Flag = "Legit/Hitscan", Items = { "Head", "Torso", "Body" }, Default = "Head" })
		F:Toggle({ Name = "Wall Check", Flag = "Legit/SilentAim/WallCheck", Default = true })
	else
		F:Label({ Text = "Unsupported (no hookmetamethod)" })
	end
end
do
	local F = LegitPage:Section({ Name = "FOV", Side = 2 })
	F:Toggle({ Name = "Use FOV", Flag = "Legit/Fov", Default = false })
	local G = F:Toggle({ Name = "Visible FOV", Flag = "Legit/Fov/Visible", Default = false })
	G:Colorpicker({ Name = "FOV Circle Color", Flag = "Legit/Fov/Color", Default = Color3.new(1, 1, 1) })
	F:Slider({ Name = "FOV Radius", Flag = "Legit/Fov/Value", Min = 10, Default = 120, Max = 500 })
	F:Slider({ Name = "FOV Num Sides", Flag = "Legit/Fov/NumSides", Min = 3, Default = 64, Max = 100 })
end
do
	local F = LegitPage:Section({ Name = "Aim Assist", Side = 1 })
	F:Toggle({ Name = "Enabled", Flag = "Legit/Aimbot", Default = false })
	F:Slider({ Name = "Speed", Flag = "Legit/Aimbot/Speed", Min = 0, Default = 10, Max = 100 })
	F:Dropdown({ Name = "Aim Type", Flag = "Legit/Aimbot/Type", Items = { "Mouse Movement", "Lerp", "Stick" }, Default = "Mouse Movement" })
	F:Dropdown({ Name = "Speed Type", Flag = "Legit/Aimbot/SpeedType", Items = { "Linear", "Exponential" }, Default = "Linear" })
	F:Dropdown({ Name = "Activation", Flag = "Legit/Aimbot/Activate", Items = { "Mouse 1", "Mouse 2" }, Default = "Mouse 1" })
end
do
	local F = RagePage:Section({ Name = "Rage Bot", Side = 1 })
	F:Toggle({ Name = "Enabled", Flag = "Rage/Ragebot", Default = false })
	F:Toggle({ Name = "Silent Aim", Flag = "Rage/SilentAim", Default = false })
	if r.Client.HasRequire and r.Game.Shucky and r.Game.Shucky.shootsound and r.Game.Ambassador and r.Game.Ambassador.Fire then
		F:Toggle({ Name = "Simulate Shoot", Flag = "Rage/SimulateShoot", Default = false })
	else
		F:Label({ Text = "Unsupported (Simulate Shoot)" })
	end
	F:Toggle({ Name = "Auto Wall", Flag = "Rage/AutoWall", Default = false })
	F:Toggle({ Name = "Force Full Damage", Flag = "Rage/ForceDamage", Default = false })
	F:Slider({ Name = "Minimum Damage", Flag = "Rage/MinDamage", Min = 1, Default = 80, Max = 115 })
	F:Dropdown({ Name = "Hitscan", Flag = "Rage/Hitscan", Items = { "Head", "Torso", "Arms", "Legs" }, Default = "Head" })
end
do
	local F = RagePage:Section({ Name = "Miscellaneous", Side = 2 })
	F:Toggle({ Name = "Debug", Flag = "Rage/Debug", Default = false })
	F:Toggle({ Name = "Use FOV", Flag = "Rage/Fov", Default = false })
	local G = F:Toggle({ Name = "Visible FOV", Flag = "Rage/Fov/Visible", Default = false })
	G:Colorpicker({ Name = "FOV Circle Color", Flag = "Rage/Fov/Color", Default = Color3.new(1, 1, 1) })
	F:Slider({ Name = "FOV", Flag = "Rage/Fov/Value", Min = 0, Default = 25, Max = 80 })
	F:Slider({ Name = "FOV Num Sides", Flag = "Rage/Fov/NumSides", Min = 3, Default = 100, Max = 100 })
	F:Toggle({ Name = "Rapid Fire", Flag = "Rage/RapidFire", Default = false })
	F:Toggle({ Name = "Force Headshot", Flag = "Rage/ForceHead", Default = false })
	F:Toggle({ Name = "Double Tap", Flag = "Rage/DoubleTap", Default = false })
	F:Toggle({ Name = "Allow Throwables", Flag = "Rage/Throwables", Default = false })
	F:Toggle({ Name = "Noscope Icon", Flag = "Rage/Noscope", Default = false })
	F:Toggle({ Name = "Backstab Icon", Flag = "Rage/Backstab", Default = false })
end
do
	local F = RagePage:Section({ Name = "Knife Bot", Side = 1 })
	F:Toggle({ Name = "Enabled", Flag = "Rage/Knifebot", Default = false })
	if r.Client.HasRequire and r.Game.Shucky and r.Game.Shucky.shootsound and r.Game.Ambassador and r.Game.Ambassador.Fire then
		F:Toggle({ Name = "Simulate Stab", Flag = "Rage/Knifebot/SimulateStab", Default = false })
	end
	F:Toggle({ Name = "Wall Check", Flag = "Rage/Knifebot/WallCheck", Default = false })
	F:Slider({ Name = "Radius", Flag = "Rage/Knifebot/Radius", Min = 0, Default = 7, Max = 15 })
end
do
	local F = RagePage:Section({ Name = "Anti Aim", Side = 2 })
	F:Toggle({ Name = "Enabled", Flag = "Rage/AntiAim", Default = false })
	local G = F:Label({ Text = "Disable On" })
	G:Keybind({ Name = "Disable Anti Aim", Flag = "Rage/AntiAim/Disable", Mode = "Toggle" })
	if r.Client.HasRequire and r.Game.Ambassador and r.Game.Ambassador.Fire then
		local H = F:Toggle({ Name = "Fake Duck", Flag = "Rage/AntiAim/FakeDuck", Default = false })
		H:Keybind({ Name = "Fake Duck", Flag = "Rage/AntiAim/FakeDuck/Bind", Mode = "Hold" })
	end
	F:Dropdown({ Name = "Yaw Base", Flag = "Rage/AntiAim/Yaw", Items = { "Camera", "Spin", "Random" }, Default = "Camera" })
	if r.Client.HasRequire and r.Game.Network and r.Game.Network.FireServer then
		F:Dropdown({ Name = "Pitch Base", Flag = "Rage/AntiAim/Pitch", Items = { "Custom", "Random" }, Default = "Custom" })
	end
	F:Slider({ Name = "Spin Speed", Flag = "Rage/AntiAim/SpinSpeed", Min = 0, Default = 3, Max = 48 })
	F:Slider({ Name = "Custom Yaw", Flag = "Rage/AntiAim/CustomYaw", Min = -180, Default = 0, Max = 180 })
	F:Slider({ Name = "Custom Pitch", Flag = "Rage/AntiAim/CustomPitch", Min = -100, Default = 0, Max = 100 })
end
do
	local Fset, G = u.teamSettings.enemy, VisualsPage:Section({ Name = "Enemy Esp", Side = 1 })
	G:Toggle({
		Name = "Enabled", Flag = "Visuals/Esp", Default = false,
		Callback = function(H) Fset.enabled = H end,
	})
	local H = G:Toggle({
		Name = "Bounding Box", Flag = "Visuals/Esp/Box", Default = false,
		Callback = function(val)
			if t["Visuals/Esp/Box/Type"] == "Default" then
				Fset.box = val; Fset.box3d = false
			else
				Fset.box3d = val; Fset.box = false
			end
		end,
	})
	H:Colorpicker({ Name = "Box Color", Flag = "Visuals/Esp/Box/Color", Default = Color3.new(1, 1, 1) })
	G:Dropdown({ Name = "Box Type", Flag = "Visuals/Esp/Box/Type", Items = { "Default", "3D" }, Default = "Default" })
	local I = G:Toggle({ Name = "Name", Flag = "Visuals/Esp/Name", Default = false, Callback = function(v) Fset.name = v end })
	I:Colorpicker({ Name = "Name Color", Flag = "Visuals/Esp/Name/Color", Default = Color3.new(1, 1, 1) })
	local J = G:Toggle({ Name = "Weapon", Flag = "Visuals/Esp/Weapon", Default = false, Callback = function(v) Fset.weapon = v end })
	J:Colorpicker({ Name = "Weapon Color", Flag = "Visuals/Esp/Weapon/Color", Default = Color3.new(1, 1, 1) })
	local K = G:Toggle({ Name = "Distance", Flag = "Visuals/Esp/Distance", Default = false, Callback = function(v) Fset.distance = v end })
	K:Colorpicker({ Name = "Distance Color", Flag = "Visuals/Esp/Distance/Color", Default = Color3.new(1, 1, 1) })
	local L = G:Toggle({ Name = "Health Bar", Flag = "Visuals/Esp/HealthBar", Default = false, Callback = function(v) Fset.healthBar = v end })
	L:Colorpicker({ Name = "Full Health Color", Flag = "Visuals/Esp/HealthBar/FullColor", Default = Color3.new(1, 0, 0) })
	L:Colorpicker({ Name = "Dying Health Color", Flag = "Visuals/Esp/HealthBar/DyingColor", Default = Color3.new(0, 1, 0) })
	local M = G:Toggle({ Name = "Health Number", Flag = "Visuals/Esp/HealthNumber", Default = false, Callback = function(v) Fset.healthText = v end })
	M:Colorpicker({ Name = "Health Number Color", Flag = "Visuals/Esp/HealthNumber/Color", Default = Color3.new(1, 1, 1) })
	local N = G:Toggle({ Name = "Chams", Flag = "Visuals/Esp/Chams", Default = false, Callback = function(v) Fset.chams = v end })
	N:Colorpicker({ Name = "Visible Chams Color", Flag = "Visuals/Esp/Chams/VisibleColor", Default = Color3.new(1, 1, 1) })
	N:Colorpicker({ Name = "Invisible Chams Color", Flag = "Visuals/Esp/Chams/InvisibleColor", Default = Color3.fromRGB(149, 255, 139) })
end
do
	local F = VisualsPage:Section({ Name = "Esp Settings", Side = 2 })
	F:Dropdown({
		Name = "Text Font", Flag = "Visuals/Esp/TextFont",
		Items = { "Plex", "System", "Monospace", "UI" }, Default = "Plex",
		Callback = function(G)
			u.sharedSettings.textFont = (G == "Plex" and 1) or (G == "System" and 2) or (G == "Monospace" and 3) or 4
		end,
	})
	F:Slider({
		Name = "Text Size", Flag = "Visuals/Esp/TextSize", Min = 8, Default = 13, Max = 50,
		Callback = function(G) u.sharedSettings.textSize = G end,
	})
	local G = F:Toggle({
		Name = "Highlight Priorities", Flag = "Visuals/Esp/ShowPriorities", Default = false,
		Callback = function(on)
			u.sharedSettings.showPriorities = on
			if on then
				for _, plr in ipairs(Lists.Priority) do
					if not table.find(u.priorities, plr.UserId) then
						table.insert(u.priorities, plr.UserId)
					end
				end
			else
				table.clear(u.priorities)
			end
		end,
	})
	G:Colorpicker({ Name = "Highlight Color", Flag = "Visuals/Esp/ShowPriorities/Color", Default = Color3.fromRGB(245, 239, 120) })
end
pcall(function() u.Load() end)
do
	local F = VisualsPage:Section({ Name = "Throwable Esp", Side = 2 })
	F:Toggle({ Name = "Enabled", Flag = "Visuals/ThrowableEsp", Default = false })
	local G = F:Toggle({ Name = "Name", Flag = "Visuals/ThrowableEsp/Name", Default = false })
	G:Colorpicker({ Name = "Name Color", Flag = "Visuals/ThrowableEsp/Name/Color", Default = Color3.new(1, 1, 1) })
	local H = F:Toggle({ Name = "Chams", Flag = "Visuals/ThrowableEsp/Chams", Default = false })
	H:Colorpicker({ Name = "Outline Color", Flag = "Visuals/ThrowableEsp/Chams/Outline", Default = Color3.new(1, 1, 1) })
	H:Colorpicker({ Name = "Fill Color", Flag = "Visuals/ThrowableEsp/Chams/Fill", Default = Color3.fromRGB(149, 255, 139) })
end
do
	local F = VisualsPage:Section({ Name = "World", Side = 1 })
	local G = F:Toggle({
		Name = "Ambient", Flag = "Visuals/Ambient", Default = false,
		Callback = function(on)
			if not on then
				Lighting.Ambient = origAmbient
				Lighting.OutdoorAmbient = origOutdoor
			end
		end,
	})
	G:Colorpicker({ Name = "Ambient Color", Flag = "Visuals/Ambient/AmbientColor", Default = Color3.fromRGB(149, 255, 139) })
	G:Colorpicker({ Name = "Outdoor Ambient Color", Flag = "Visuals/Ambient/OutdoorAmbientColor", Default = Color3.fromRGB(129, 255, 129) })
	F:Toggle({
		Name = "No Flash", Flag = "Visuals/NoFlash", Default = false,
		Callback = function(on)
			local I = LP.PlayerScripts:FindFirstChild("PlayerBase") and LP.PlayerScripts.PlayerBase:FindFirstChild("FlashbangEffect")
			if I then I.Disabled = on end
		end,
	})
	F:Toggle({ Name = "No Smoke", Flag = "Visuals/NoSmoke", Default = false })
	local H = F:Toggle({ Name = "Bomb Status", Flag = "Visuals/BombStatus", Default = false })
	H:Colorpicker({ Name = "Bomb Status Bar Color", Flag = "Visuals/BombStatus/Color", Default = Color3.fromRGB(149, 255, 139) })
	local I = F:Toggle({ Name = "Bomb Chams", Flag = "Visuals/BombChams", Default = false })
	I:Colorpicker({ Name = "Outline Color", Flag = "Visuals/BombChams/OutlineColor", Default = Color3.new(1, 1, 1) })
	I:Colorpicker({ Name = "Fill Color", Flag = "Visuals/BombChams/FillColor", Default = Color3.fromRGB(149, 255, 139) })
	if r.Client.HasHookmetamethod then
		local texList = {}
		for k in next, r.BulletTracersTextures do table.insert(texList, k) end
		local K = F:Toggle({ Name = "Bullet Tracers", Flag = "Visuals/BulletTracers", Default = false })
		K:Colorpicker({ Name = "Start Color", Flag = "Visuals/BulletTracers/StartColor", Default = Color3.new(1, 1, 1) })
		K:Colorpicker({ Name = "End Color", Flag = "Visuals/BulletTracers/EndColor", Default = Color3.fromRGB(149, 255, 139) })
		F:Dropdown({ Name = "Texture", Flag = "Visuals/BulletTracers/Texture", Items = texList, Default = texList[1] })
		F:Slider({ Name = "Lifetime", Flag = "Visuals/BulletTracers/Lifetime", Min = 0, Default = 3, Max = 10 })
		local J = F:Toggle({ Name = "Hit Impacts", Flag = "Visuals/HitImpacts", Default = false })
		J:Colorpicker({ Name = "Hit Impacts Color", Flag = "Visuals/HitImpacts/Color", Default = Color3.new(1, 1, 1) })
		F:Slider({ Name = "Lifetime", Flag = "Visuals/HitImpacts/Lifetime", Min = 0, Default = 6, Max = 10 })
	end
	F:Toggle({
		Name = "Time Changer", Flag = "Visuals/TimeChanger", Default = false,
		Callback = function(on) if not on then Lighting.ClockTime = origClock end end,
	})
	F:Slider({ Name = "Time", Flag = "Visuals/TimeChanger/Time", Min = 0, Default = 12, Max = 24 })
	F:Toggle({ Name = "Skybox Changer", Flag = "Visuals/Skybox", Default = false })
	F:Dropdown({
		Name = "Skybox Type", Flag = "Visuals/Skybox/Type",
		Items = { "--", "Galaxy", "Purple", "Purple Night", "Pink Daylight", "Night Sky", "Morning Glow", "Fade Blue", "Elegant Morning", "Aesthetic Night", "Redshift" },
		Default = "--",
	})
end
do
	local F = VisualsPage:Section({ Name = "Viewmodel", Side = 1 })
	F:Toggle({ Name = "Viewmodel Offset", Flag = "Visuals/Viewmodel", Default = false })
	F:Slider({ Name = "Offset X", Flag = "Visuals/Viewmodel/X", Min = -180, Default = 0, Max = 180 })
	F:Slider({ Name = "Offset Y", Flag = "Visuals/Viewmodel/Y", Min = -180, Default = 0, Max = 180 })
	F:Slider({ Name = "Offset Z", Flag = "Visuals/Viewmodel/Z", Min = -180, Default = 0, Max = 180 })
end
do
	local texList = {}
	for k in next, r.WeaponTextures do table.insert(texList, k) end
	local G = VisualsPage:Section({ Name = "Weapon", Side = 2 })
	local H = G:Toggle({ Name = "Chams", Flag = "Visuals/Weapon/Chams", Default = false })
	H:Colorpicker({ Name = "Chams Color", Flag = "Visuals/Weapon/Chams/Color", Default = Color3.fromRGB(149, 255, 139) })
	G:Toggle({ Name = "Texture Changer", Flag = "Visuals/Weapon/TextureChanger", Default = false })
	G:Dropdown({ Name = "Texture", Flag = "Visuals/Weapon/TextureChanger/Texture", Items = texList, Default = texList[1] })
end
do
	local F = VisualsPage:Section({ Name = "Arms", Side = 2 })
	F:Toggle({ Name = "Remove Jump Bob", Flag = "Visuals/Arms/NoJumpBob", Default = false })
	if r.Client.HasHookmetamethod then
		F:Toggle({ Name = "Remove Arms Bob", Flag = "Visuals/Arms/NoBob", Default = false })
		F:Toggle({ Name = "Remove Arms Sway", Flag = "Visuals/Arms/NoSway", Default = false })
	end
end
do
	local sndList = {}
	for k in next, r.Sounds do table.insert(sndList, k) end
	local G = VisualsPage:Section({ Name = "Sound Effects", Side = 2 })
	G:Toggle({ Name = "Custom Hit Sound", Flag = "Visuals/HitSound", Default = false })
	G:Dropdown({ Name = "Hit Sound", Flag = "Visuals/HitSound/Sound", Items = sndList, Default = "Default Hit Sound" })
	G:Slider({ Name = "Hit Sound Volume", Flag = "Visuals/HitSound/Volume", Min = 0, Default = 2, Max = 5 })
	G:Toggle({ Name = "Custom Kill Sound", Flag = "Visuals/KillSound", Default = false })
	G:Dropdown({ Name = "Kill Sound", Flag = "Visuals/KillSound/Sound", Items = sndList, Default = "Default Kill Sound" })
	G:Slider({ Name = "Kill Sound Volume", Flag = "Visuals/KillSound/Volume", Min = 0, Default = 2, Max = 5 })
end
do
	local F = VisualsPage:Section({ Name = "Self", Side = 2 })
	local G = F:Toggle({ Name = "Third Person", Flag = "Visuals/ThirdPerson", Default = false })
	G:Keybind({ Name = "Third Person", Flag = "Visuals/ThirdPerson/Bind", Mode = "Toggle" })
	F:Slider({ Name = "Third Person Distance", Flag = "Visuals/ThirdPerson/Distance", Min = 1, Default = 9, Max = 20 })
end
do
	local F = MiscPage:Section({ Name = "Movement", Side = 1 })
	if r.Client.HasRequire and r.Client.FullRequire and r.Game.Variables then
		F:Toggle({ Name = "Bypass Speed Limit", Flag = "Misc/BypassSpeed", Default = false })
	end
	F:Toggle({ Name = "Automatic Jump", Flag = "Misc/AutoJump", Default = false })
	F:Toggle({ Name = "Noclip", Flag = "Misc/Noclip", Default = false })
	F:Toggle({ Name = "Speed Hack", Flag = "Misc/SpeedHack", Default = false })
	F:Slider({ Name = "Speed Hack Speed", Flag = "Misc/SpeedHack/Speed", Min = 16, Default = 40, Max = 250 })
	local G = F:Toggle({ Name = "Airstuck", Flag = "Misc/Airstuck", Default = false })
	G:Keybind({ Name = "Airstuck", Flag = "Misc/Airstuck/Bind", Mode = "Hold" })
	local H = F:Toggle({ Name = "Pixelsurf", Flag = "Misc/Pixelsurf", Default = false })
	H:Keybind({ Name = "Pixelsurf", Flag = "Misc/Pixelsurf/Bind", Mode = "Hold" })
	local I = F:Toggle({ Name = "Edgebug", Flag = "Misc/Edgebug", Default = false })
	I:Keybind({ Name = "Edgebug", Flag = "Misc/Edgebug/Bind", Mode = "Hold" })
	F:Toggle({ Name = "Edgebug Notification", Flag = "Misc/Edgebug/Notification", Default = false })
	F:Slider({ Name = "Edgebug Debounce", Flag = "Misc/Edgebug/Debounce", Min = 0, Default = 0.2, Max = 0.8 })
end
do
	local F = MiscPage:Section({ Name = "Exploits", Side = 1 })
	F:Label({ Text = "EXTREMELY DETECTED - prefer Priority Kill" })
	F:Toggle({ Name = "Kill All", Flag = "Misc/KillAll", Default = false })
	F:Slider({ Name = "Hit Per Second", Flag = "Misc/KillAll/HPS", Min = 1, Default = 1, Max = 10 })
	F:Toggle({ Name = "Anti Spectate", Flag = "Misc/AntiSpectate", Default = false })
	F:Dropdown({ Name = "Type", Flag = "Misc/AntiSpectate/Type", Items = { "Low Fov", "Freeze" }, Default = "Low Fov" })
	F:Button({
		Name = "Flashbang Enemies",
		Callback = function()
			if not r.Game.IsAlive(LP) then return s:Notification("You are dead!") end
			if RS:GetAttribute("Preparation") then return s:Notification("Let the round start!") end
			if r.Game.EquippedWeapon ~= "Flashbang" then return s:Notification("Hold the flashbang!") end
			s:Notification("Flashbanging enemies...")
			local intensity = (t["Misc/Flashbang/Intensity"] or 1)
			for _, H in next, Players:GetPlayers() do
				if H == LP or not r.Game.IsAlive(H) or H.Character:FindFirstChildWhichIsA("ForceField") then continue end
				for _ = 1, intensity do
					r.Game.FireEvent:FireServer({
						Normal = Vector3.zero,
						Position = H.Character.Torso.Position + Vector3.one,
						Hit = H.Character, cCF = Cam.CFrame,
						hS = H.Character.Torso.Size and H.Character.Torso.Size.Magnitude,
						hP = H.Character.Torso.Position, PartName = "Torso", BlindLevel = 1,
					}, r.Game.EquippedWeaponFolder, nil, true, Cam.CFrame, H.Character.Torso.Position, nil, nil)
				end
			end
		end,
	})
	F:Slider({ Name = "Flashbang Intensity", Flag = "Misc/Flashbang/Intensity", Min = 1, Default = 1, Max = 10 })
end
do
	local F = MiscPage:Section({ Name = "Client", Side = 1 })
	F:Toggle({ Name = "Auto Join Team", Flag = "Misc/JoinTeam", Default = false })
	F:Dropdown({ Name = "Team", Flag = "Misc/JoinTeam/Team", Items = { "Operators", "Militia" }, Default = "Operators" })
end
do
	local F = MiscPage:Section({ Name = "Chat", Side = 2 })
	if r.Client.HasRequire and r.Game.Network and r.Game.Network.FireServer then
		F:Toggle({ Name = "Chat Spammer", Flag = "Misc/ChatSpam", Default = false })
		F:Dropdown({ Name = "Message Type", Flag = "Misc/ChatSpam/Type", Items = { "Neyrone", "Advertise", "Japanese", "Custom" }, Default = "Neyrone" })
		F:Textbox({ Name = "Custom Message", Flag = "Misc/ChatSpam/Custom", Default = "Neyrone on top!!" })
	else
		F:Label({ Text = "Unsupported (Chat Spammer)" })
	end
end
do
	local F = MiscPage:Section({ Name = "C4", Side = 2 })
	F:Dropdown({ Name = "Site", Flag = "Misc/PlantC4/Site", Items = { "A", "B" }, Default = "A" })
	F:Button({
		Name = "Plant",
		Callback = function()
			if not r.Game.IsAlive(LP) then return s:Notification("You are dead!") end
			if LP:GetAttribute("Team") ~= "T" then return s:Notification("Not Militia!") end
			if RS:GetAttribute("HasBomb") ~= LP.Name then return s:Notification("No bomb!") end
			if RS:GetAttribute("Preparation") then return s:Notification("Wait for round!") end
			local oldCF = LP.Character.HumanoidRootPart.CFrame
			local site = t["Misc/PlantC4/Site"] == "A" and "BombA" or "BombB"
			local marker = workspace.Map and workspace.Map.Markers and workspace.Map.Markers[site]
			if not marker then return s:Notification("Site marker missing") end
			LP.Character.HumanoidRootPart.CFrame = marker.CFrame - Vector3.new(0, -1, 0)
			task.wait(0.3)
			RS.Events.PlantC4:FireServer()
			LP.Character.HumanoidRootPart.CFrame = oldCF
			s:Notification("Bomb planted on " .. tostring(t["Misc/PlantC4/Site"]))
		end,
	})
	if r.Client.HasRequire and r.Game.Ambassador and r.Game.Ambassador.Fire then
		F:Button({
			Name = "Defuse",
			Callback = function()
				if not r.Game.IsAlive(LP) then return s:Notification("You are dead!") end
				if LP:GetAttribute("Team") ~= "CT" then return s:Notification("Not Operators!") end
				if not r.Game.IsC4Planted() then return s:Notification("No bomb planted!") end
				RS.Events.StartDefuse:FireServer()
				r.Game.Ambassador.Fire("UpdateDefuse")
				RS.Events.StartDefuse:FireServer()
				r.Game.Ambassador.Fire("StopDefuse")
				s:Notification("Defusing, wait ~8s")
			end,
		})
	end
end
do
	local F = MiscPage:Section({ Name = "Gun Mods", Side = 2 })
	F:Toggle({ Name = "No Recoil", Flag = "Misc/GunMods/NoRecoil", Default = false })
	F:Toggle({ Name = "No Spread", Flag = "Misc/GunMods/NoSpread", Default = false })
	F:Toggle({ Name = "Full Auto", Flag = "Misc/GunMods/FullAuto", Default = false })
	F:Toggle({ Name = "Rapid Fire", Flag = "Misc/GunMods/RapidFire", Default = false })
	F:Toggle({ Name = "Stored Ammo -> Ammo", Flag = "Misc/GunMods/ConvertAmmo", Default = false })
	F:Toggle({ Name = "Infinite Ammo", Flag = "Misc/GunMods/InfAmmo", Default = false })
end
do
	local F = MiscPage:Section({ Name = "Throwables", Side = 2 })
	F:Dropdown({ Name = "Activation Type", Flag = "Misc/Throwables/Activate/Type", Items = { "Touch", "Shoot" }, Default = "Touch" })
	F:Toggle({ Name = "Auto Activate Laser Mines", Flag = "Misc/Throwables/Activate", Default = false })
	F:Toggle({ Name = "Allow Yours Laser Mines", Flag = "Misc/Throwables/AllowSelf", Default = false })
	F:Toggle({ Name = "Remove Laser from Mines", Flag = "Misc/Throwables/RemoveLaser", Default = false })
	if r.Client.HasHookmetamethod then
		F:Toggle({ Name = "Teleport", Flag = "Misc/Throwables/Teleport", Default = false })
	end
end
do
	local F = SkinsPage:Section({ Name = "Skin Changer", Side = 1 })
	if r.Client.HasRequire and r.Game.Appearance and r.Game.Appearance.MapGunSkin then
		F:Label({ Text = "Skin changer active (equip weapon to apply)" })
	else
		F:Label({ Text = "Unsupported (require/Appearance)" })
	end
end
do
	local F = SkinsPage:Section({ Name = "Knife Changer", Side = 2 })
	if #r.Game.SkinsData.Knives.List > 0 then
		r.Game.SkinsData.Knives.CurrentKnifeType = r.Game.SkinsData.Knives.List[1]
		F:Toggle({ Name = "Enabled", Flag = "Skins/Knife", Default = false })
		F:Dropdown({ Name = "Knife", Flag = "Skins/Knife/Type", Items = r.Game.SkinsData.Knives.List, Default = r.Game.SkinsData.Knives.List[1] })
	else
		F:Label({ Text = "No knives found" })
	end
end
do
	local F = SkinsPage:Section({ Name = "Gloves Changer", Side = 2 })
	if #r.Game.SkinsData.Gloves.List > 0 then
		r.Game.SkinsData.Gloves.CurrentGlove = r.Game.SkinsData.Gloves.List[1]
		F:Toggle({ Name = "Enabled", Flag = "Skins/Glove", Default = false })
		F:Dropdown({ Name = "Gloves", Flag = "Skins/Glove/Type", Items = r.Game.SkinsData.Gloves.List, Default = r.Game.SkinsData.Gloves.List[1] })
	else
		F:Label({ Text = "No gloves found" })
	end
end
do
	PlayersPage:PlayerList({ Name = "Player List", Flag = "PlayerList" })
end
do
	local F = PlayersPage:Section({ Name = "Priority", Side = 1 })
	F:Toggle({ Name = "Kill", Flag = "Players/Priority/Kill", Default = false })
	F:Slider({ Name = "Hit Per Second", Flag = "Players/Priority/Kill/HPS", Min = 1, Default = 1, Max = 10 })
	F:Button({
		Name = "Flashbang Priority",
		Callback = function()
			if not r.Game.IsAlive(LP) then return s:Notification("You are dead!") end
			if #Lists.Priority < 1 then return s:Notification("No priority players") end
			if RS:GetAttribute("Preparation") then return s:Notification("Wait for round!") end
			if r.Game.EquippedWeapon ~= "Flashbang" then return s:Notification("Hold flashbang!") end
			s:Notification("Flashbanging priority...")
			local intensity = t["Players/Priority/Flashbang/Intensity"] or 1
			for _, H in next, Lists.Priority do
				if H == LP or not r.Game.IsAlive(H) or H.Character:FindFirstChildWhichIsA("ForceField") then continue end
				for _ = 1, intensity do
					r.Game.FireEvent:FireServer({
						Normal = Vector3.zero,
						Position = H.Character.Torso.Position + Vector3.one,
						Hit = H.Character, cCF = Cam.CFrame,
						hS = H.Character.Torso.Size and H.Character.Torso.Size.Magnitude,
						hP = H.Character.Torso.Position, PartName = "Torso", BlindLevel = 1,
					}, r.Game.EquippedWeaponFolder, nil, true, Cam.CFrame, H.Character.Torso.Position, nil, nil)
				end
			end
		end,
	})
	F:Slider({ Name = "Flashbang Intensity", Flag = "Players/Priority/Flashbang/Intensity", Min = 1, Default = 1, Max = 10 })
end
do
	local F = SettingsPage:Section({ Name = "Settings", Side = 1 })
	F:Label({ Text = "Menu Keybind" }):Keybind({
		Name = "Menu", Flag = "menu_keybind", Default = Enum.KeyCode.RightShift, Mode = "Toggle",
	})
	F:Toggle({
		Name = "Watermark", Flag = "watermark", Default = false,
		Callback = function(on) w:SetVisibility(on) end,
	})
	F:Toggle({
		Name = "Keybind List", Flag = "keybind_list", Default = false,
		Callback = function(on) x:SetVisibility(on) end,
	})
	F:Button({
		Name = "Rejoin",
		Callback = function()
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
		end,
	})
	F:Button({
		Name = "Unload",
		Callback = function() s:Unload() end,
	})
end
do
	local F = SettingsPage:Section({ Name = "Info", Side = 2 })
	F:Label({ Text = "TEMPO | Defusal Fixed" })
	F:Label({ Text = "Executor checks:" })
	local missing = {}
	if not r.Client.HasHookmetamethod then table.insert(missing, "hookmetamethod") end
	if not r.Client.HasMousemoverel then table.insert(missing, "mousemoverel") end
	if not r.Client.HasRequire then table.insert(missing, "require") end
	if not r.Client.FullRequire then table.insert(missing, "require (partial)") end
	if not r.Client.HasGetsenv then table.insert(missing, "getsenv") end
	if not r.Client.FullGetsenv then table.insert(missing, "getsenv (partial)") end
	if #missing > 0 then
		F:Label({ Text = "Missing: " .. table.concat(missing, ", ") })
	else
		F:Label({ Text = "All required APIs present" })
	end
end
local F_triggerBusy = false
local legitFovCircle = Drawing.new("Circle")
legitFovCircle.ZIndex = 2
legitFovCircle.Visible = false
legitFovCircle.Thickness = 1
legitFovCircle.Color = Color3.new(1, 1, 1)
legitFovCircle.NumSides = 100
legitFovCircle.Filled = false
local rageFovCircle = Drawing.new("Circle")
rageFovCircle.ZIndex = 2
rageFovCircle.Visible = false
rageFovCircle.Thickness = 1
rageFovCircle.Color = Color3.new(1, 1, 1)
rageFovCircle.NumSides = 100
rageFovCircle.Filled = false
local L = {}
L.Hitboxes = { Head = "Head", Torso = "HumanoidRootPart", Body = "HumanoidRootPart" }
local function IsVisible(targetPart, character)
	if not t["Legit/SilentAim/WallCheck"] then return true end
	local origin = Cam.CFrame.Position
	local direction = targetPart.Position - origin
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { LP.Character, character, Cam }
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	local result = workspace:Raycast(origin, direction, params)
	return result == nil or (result.Instance and result.Instance:IsDescendantOf(character))
end
function L.GetTarget(useFov, fovRadius)
	local best, bestPlr = math.huge, nil
	local mousePos = UIS:GetMouseLocation()
	local radius = (useFov and (fovRadius or t["Legit/Fov/Value"] or 120)) or math.huge
	for _, R in next, Players:GetPlayers() do
		if R == LP or not r.Game.IsAlive(R) then continue end
		if not RS:GetAttribute("NoTKPenalty") and R:GetAttribute("Team") == LP:GetAttribute("Team") then continue end
		if R.Character:FindFirstChildWhichIsA("ForceField") then continue end
		local hitName = L.Hitboxes[t["Legit/Hitscan"] or "Head"] or "Head"
		local part = R.Character:FindFirstChild(hitName)
		if not part then continue end
		local screen, onScreen = Cam:WorldToViewportPoint(part.Position)
		if not onScreen then continue end
		if not IsVisible(part, R.Character) then continue end
		local dist = (Vector2.new(screen.X, screen.Y) - mousePos).Magnitude
		if useFov and dist > radius then continue end
		if dist < best then
			best = dist
			bestPlr = R
		end
	end
	return bestPlr
end
local silentTarget, silentPart = nil, nil
local throwTarget, throwPart = nil, nil
local N = { LastShotTick = 0, LastReloadTick = 0 }
N.HitboxMultipliers = {
	Head = 1.75, Torso = 1.25,
	["Left Arm"] = 1, ["Right Arm"] = 1,
	["Left Leg"] = 0.75, ["Right Leg"] = 0.75,
}
N.DefaultValues = { Range = 8192, Penetration = 300, ArmorPenetration = 80, Damage = 50, Bullets = 1 }
N.GetHitboxes = function(plr, hits)
	local Q = {}
	if not r.Game.IsAlive(plr) then return Q end
	if type(hits) == "string" then hits = { hits } end
	for _, S in next, hits do
		if S == "Head" and plr.Character:FindFirstChild("Head") then table.insert(Q, plr.Character.Head) end
		if S == "Torso" and plr.Character:FindFirstChild("Torso") then table.insert(Q, plr.Character.Torso) end
		if S == "Arms" then
			if plr.Character:FindFirstChild("Left Arm") then table.insert(Q, plr.Character["Left Arm"]) end
			if plr.Character:FindFirstChild("Right Arm") then table.insert(Q, plr.Character["Right Arm"]) end
		end
		if S == "Legs" then
			if plr.Character:FindFirstChild("Left Leg") then table.insert(Q, plr.Character["Left Leg"]) end
			if plr.Character:FindFirstChild("Right Leg") then table.insert(Q, plr.Character["Right Leg"]) end
		end
	end
	return Q
end
N.FireEvent = function(weaponFolder, part, ratio, wallbang, bullets, noscope, backstab)
	local taps = t["Rage/DoubleTap"] and 2 or 1
	for _ = 1, taps do
		for _ = 1, (bullets or 1) do
			r.Game.FireEvent:FireServer({
				Normal = Vector3.zero,
				Position = part.Position + Vector3.one,
				Hit = part.Parent,
				cCF = Cam.CFrame,
				hS = part.Size and part.Size.Magnitude,
				hP = part.Position,
				PartName = (t["Rage/ForceHead"] or part.Name:find("Head")) and "Head" or part.Name,
				Wallbang = wallbang,
				Noscope = noscope or false,
				Backstab = backstab or false,
				Ratio = ratio,
			}, weaponFolder, nil, true, Cam.CFrame, part.Position, nil, nil)
		end
	end
end
N.FakeShoot = function(weaponFolder, isKnife)
	if not r.Client.HasRequire or not r.Game.Shucky or not r.Game.Shucky.shootsound then return end
	if not r.Game.Ambassador or not r.Game.Ambassador.Fire then return end
	if not isKnife and not t["Rage/SimulateShoot"] then return end
	if isKnife and not t["Rage/Knifebot/SimulateStab"] then return end
	if weaponFolder:GetAttribute("WeaponType") == "Throwable" or not weaponFolder:FindFirstChild("Model") then return end
	r.Game.Shucky.shootsound(weaponFolder.Model, Cam)
	pcall(function()
		RS.URE_ViewmodelAnimStream:FireServer(true, "fire", "fire", nil, nil, nil)
	end)
	r.Game.Ambassador.Fire("VPlay", "2fire", "fire")
	r.Game.Ambassador.Fire("WPlay", tostring(math.random(1, 2) == 1 and "" or "2"), "Fire")
end
N.ShootTarget = function(weaponFolder, isKnife, origin, targetPlr, part, force, ratio, wallbang)
	local dmg = weaponFolder:GetAttribute("DMG") or N.DefaultValues.Damage
	local bullets = weaponFolder:GetAttribute("Bullets") or 1
	local mult = N.HitboxMultipliers[part.Name] or 1
	local approx = bullets * dmg * (ratio or 1) * mult
	if force or approx >= (t["Rage/MinDamage"] or 80) then
		if not t["Rage/SilentAim"] then
			Cam.CFrame = CFrame.new(Cam.CFrame.Position, part.Position)
		end
		if t["Rage/Debug"] then
			s:Notification(string.format("Shot %s %s ~%.0f dmg", targetPlr.Name, part.Name, approx))
		end
		task.spawn(N.FakeShoot, weaponFolder, isKnife)
		task.spawn(N.FireEvent, weaponFolder, part, ratio or 1, wallbang, bullets, t["Rage/Noscope"], t["Rage/Backstab"])
		return true
	end
	return false
end
N.AutoWall = function(weaponFolder, origin, targetPart, filterList)
	local results = {}
	local dir = (targetPart.Position - origin).Unit
	local range = weaponFolder:GetAttribute("Range") or 8000
	local step = (range / 8) or 1000
	local pen = weaponFolder:GetAttribute("Penetration") or 0
	local penBudget = pen > 0 and pen * 0.02 or 0
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = filterList
	params.IgnoreWater = true
	local filter = params.FilterDescendantsInstances
	local hit = workspace:Raycast(origin, dir * step, params)
	local used = 0
	local hitsOnPlayers = 0
	local wallbanged = false
	local maxIter = 4
	local iter = 0
	repeat
		iter = iter + 1
		if iter >= maxIter then break end
		local inst, pos
		if hit then
			inst = hit.Instance
			pos = hit.Position
		else
			pos = origin + dir * step
			inst = nil
		end
		local entry = { Hit = inst, Position = pos, Normal = hit and hit.Normal or Vector3.new(0, 1, 0) }
		if wallbanged then entry.Wallbang = true end
		if entry.Hit then table.insert(results, entry) end
		if penBudget == 0 then break end
		if inst then
			wallbanged = true
			local hum = inst.Parent and inst.Parent:FindFirstChild("Humanoid")
			local cost = 0
			if hum or (inst.Parent and inst.Parent:GetAttribute("Streak")) then
				hitsOnPlayers = hitsOnPlayers + 1
				table.insert(filter, inst.Parent)
			else
				local pene = inst:GetAttribute("PeneValue") or 1
				local mat = inst.Material
				if mat == Enum.Material.DiamondPlate then pene = 3
				elseif mat == Enum.Material.CorrodedMetal or mat == Enum.Material.Metal then pene = 2
				elseif mat == Enum.Material.Concrete or mat == Enum.Material.Brick then pene = 2
				elseif inst.Name == "Grate" or mat == Enum.Material.Wood or mat == Enum.Material.WoodPlanks then pene = 0.5
				elseif mat == Enum.Material.Fabric or mat == Enum.Material.Sand or mat == Enum.Material.Grass then pene = 0.1
				elseif inst.Transparency == 1 or not inst.CanCollide or inst.Name == "Glass" or inst.Name == "Cardboard" then pene = 0
				end
				if inst.Name == "nowallbang" then used = penBudget end
				cost = 1 * pene
				table.insert(filter, inst)
			end
			params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = filter
			params.IgnoreWater = true
			if used > 0 and hum then
				entry.Ratio = 1 - used / penBudget
			end
			used = used + cost
			hit = workspace:Raycast(origin, dir * step, params)
		end
		if not inst or (penBudget < hitsOnPlayers or penBudget <= used) then break end
	until false
	return results
end
N.Init = function(weaponFolder, targets, isMelee)
	if not workspace:FindFirstChild("Map") then return end
	if RS:GetAttribute("RoundOver") or RS:GetAttribute("Preparation") or RS:GetAttribute("GameOver") then return end
	local fireRate = weaponFolder:GetAttribute("FireRate") or 0.1
	if LP.Character:GetAttribute("Aiming") then
		fireRate = weaponFolder:GetAttribute("ScopedFireRate") or fireRate
	end
	if t["Rage/RapidFire"] then fireRate = 0.01 end
	local now = tick()
	if now - N.LastShotTick < fireRate then return end
	local origin
	if t["Rage/AntiAim/FakeDuck"] and Flags["Rage/AntiAim/FakeDuck/Bind"] and Flags["Rage/AntiAim/FakeDuck/Bind"].Toggled then
		origin = LP.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)
	else
		origin = LP.Character.Head.Position
	end
	local filterBase = { workspace.Destroyable, workspace.Debris }
	if workspace.Map:FindFirstChild("Clips") then table.insert(filterBase, workspace.Map.Clips) end
	if r.Client.HasRequire and r.Game.Variables and r.Game.Variables.Params then
		filterBase = {}
		for _, v in next, r.Game.Variables.Params.FilterDescendantsInstances do
			table.insert(filterBase, v)
		end
	end
	local shot = false
	for _, target in next, targets do
		if not target or not r.Game.IsAlive(target) then continue end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = filterBase
		params.IgnoreWater = true
		params:AddToFilter(LP.Character)
		params:AddToFilter(Cam)
		if isMelee then
			if not t["Rage/Knifebot"] then return end
			local radius = t["Rage/Knifebot/Radius"] or 7
			local dir = (target.Character.HumanoidRootPart.Position - origin).Unit * radius
			if not t["Rage/Knifebot/WallCheck"] then
				params:AddToFilter(workspace.Map)
			end
			local hit = workspace:Raycast(origin, dir, params)
			if hit and hit.Instance and hit.Instance:IsDescendantOf(target.Character) then
				task.spawn(N.FakeShoot, weaponFolder, true)
				task.spawn(N.FireEvent, weaponFolder, target.Character.HumanoidRootPart, 1, false, 1, t["Rage/Noscope"], t["Rage/Backstab"])
				shot = true
				break
			end
		else
			local hitboxes = N.GetHitboxes(target, t["Rage/Hitscan"] or { "Head" })
			if #hitboxes == 0 then continue end
			for _, part in next, hitboxes do
				if t["Rage/Fov"] then
					local mousePos = UIS:GetMouseLocation()
					local vs = Cam.ViewportSize
					local fovR = (vs.X * ((t["Rage/Fov/Value"] or 25) / 2) / Cam.FieldOfView) / 2
					local sp, onScreen = Cam:WorldToViewportPoint(part.Position)
					local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
					if d > fovR or not onScreen then continue end
				end
				local dir = part.Position - origin
				local hit = workspace:Raycast(origin, dir, params)
				if hit and hit.Instance == part then
					if N.ShootTarget(weaponFolder, false, origin, target, part, true, 1, false) then
						shot = true
						break
					end
				end
				if t["Rage/AutoWall"] then
					local walls = N.AutoWall(weaponFolder, origin, part, filterBase)
					local canHit, ratio, wb = false, 1, false
					for _, entry in ipairs(walls) do
						if entry.Hit and entry.Hit.Parent == target.Character then
							canHit = true
							ratio = t["Rage/ForceDamage"] and 1 or (entry.Ratio or 1)
							wb = entry.Wallbang or false
							break
						end
					end
					if canHit and N.ShootTarget(weaponFolder, false, origin, target, part, false, ratio, wb) then
						shot = true
						break
					end
				end
			end
		end
		if shot then
			N.LastShotTick = now
			break
		end
	end
end
N.Start = function()
	if not t["Rage/Ragebot"] or not r.Game.IsAlive(LP) then return end
	if not r.Game.EquippedWeapon or r.Game.EquippedWeapon == "C4" then return end
	if not r.Game.EquippedWeaponFolder then return end
	if r.Game.EquippedWeaponFolder:GetAttribute("WeaponType") == "Throwable" and not t["Rage/Throwables"] then return end
	local list = {}
	for _, plr in next, Players:GetPlayers() do
		if plr == LP or not r.Game.IsAlive(plr) then continue end
		if not RS:GetAttribute("NoTKPenalty") and plr:GetAttribute("Team") == LP:GetAttribute("Team") then continue end
		if plr.Character:FindFirstChildWhichIsA("ForceField") then continue end
		table.insert(list, plr)
	end
	if #list > 0 then
		N.Init(r.Game.EquippedWeaponFolder, list, r.Game.EquippedWeaponFolder:GetAttribute("WeaponType") == "Melee")
	end
end
RunS.Stepped:Connect(function()
	task.spawn(N.Start)
end)
local function KillAllInit()
	if not t["Misc/KillAll"] or not r.Game.IsAlive(LP) then return end
	if not r.Game.EquippedWeaponFolder then return end
	local hps = t["Misc/KillAll/HPS"] or 1
	for _, al in next, Players:GetPlayers() do
		if al == LP or not r.Game.IsAlive(al) or al.Character:FindFirstChildWhichIsA("ForceField") then continue end
		for _ = 1, hps do
			r.Game.FireEvent:FireServer({
				Normal = Vector3.zero,
				Position = al.Character.Head.Position + Vector3.one,
				Hit = al.Character, cCF = Cam.CFrame,
				hS = al.Character.Head.Size and al.Character.Head.Size.Magnitude,
				hP = al.Character.Head.Position, PartName = "Head", Wallbang = true,
			}, r.Game.EquippedWeaponFolder, nil, true, Cam.CFrame, al.Character.Head.Position, nil, nil)
		end
	end
end
local function KillPriorityInit()
	if not t["Players/Priority/Kill"] or not r.Game.IsAlive(LP) or #Lists.Priority < 1 then return end
	if not r.Game.EquippedWeaponFolder then return end
	local hps = t["Players/Priority/Kill/HPS"] or 1
	for _, al in next, Lists.Priority do
		if al == LP or not r.Game.IsAlive(al) or al.Character:FindFirstChildWhichIsA("ForceField") then continue end
		for _ = 1, hps do
			r.Game.FireEvent:FireServer({
				Normal = Vector3.zero,
				Position = al.Character.Head.Position + Vector3.one,
				Hit = al.Character, cCF = Cam.CFrame,
				hS = al.Character.Head.Size and al.Character.Head.Size.Magnitude,
				hP = al.Character.Head.Position, PartName = "Head", Wallbang = true,
			}, r.Game.EquippedWeaponFolder, nil, true, Cam.CFrame, al.Character.Head.Position, nil, nil)
		end
	end
end
local weaponDefaults = {}
for _, am in next, (RS:FindFirstChild("Weapons") and RS.Weapons:GetChildren() or {}) do
	if am:IsA("Folder") then
		weaponDefaults[am.Name] = {
			RecoilX = am:GetAttribute("RecoilX"),
			RecoilY = am:GetAttribute("RecoilY"),
			Auto = am:GetAttribute("Auto"),
			ScopedFireRate = am:GetAttribute("ScopedFireRate"),
			FireRate = am:GetAttribute("FireRate"),
			Ammo = am:GetAttribute("Ammo"),
			StoredAmmo = am:GetAttribute("StoredAmmo"),
			Spread = am:GetAttribute("Spread"),
			CrouchSpread = am:GetAttribute("CrouchSpread"),
			FireSpread = am:GetAttribute("FireSpread"),
			LadderSpread = am:GetAttribute("LadderSpread"),
			LandSpread = am:GetAttribute("LandSpread"),
			MoveSpread = am:GetAttribute("MoveSpread"),
			StandSpread = am:GetAttribute("StandSpread"),
			JumpSpread = am:GetAttribute("JumpSpread"),
			RunSpread = am:GetAttribute("RunSpread"),
		}
	end
end
local function WeaponModsInit()
	for _, am in next, (RS:FindFirstChild("Weapons") and RS.Weapons:GetChildren() or {}) do
		if not am:IsA("Folder") then continue end
		local def = weaponDefaults[am.Name]
		if not def then continue end
		if t["Misc/GunMods/NoRecoil"] then
			am:SetAttribute("RecoilX", 0)
			am:SetAttribute("RecoilY", 0)
		else
			am:SetAttribute("RecoilX", def.RecoilX)
			am:SetAttribute("RecoilY", def.RecoilY)
		end
		if t["Misc/GunMods/NoSpread"] then
			am:SetAttribute("Spread", 0)
			am:SetAttribute("CrouchSpread", 0)
			am:SetAttribute("FireSpread", 0)
			am:SetAttribute("LadderSpread", 0)
			am:SetAttribute("LandSpread", 0)
			am:SetAttribute("MoveSpread", 0)
			am:SetAttribute("StandSpread", 0)
			am:SetAttribute("JumpSpread", 0)
			am:SetAttribute("RunSpread", 0)
		else
			am:SetAttribute("Spread", def.Spread)
			am:SetAttribute("CrouchSpread", def.CrouchSpread)
			am:SetAttribute("FireSpread", def.FireSpread)
			am:SetAttribute("LadderSpread", def.LadderSpread)
			am:SetAttribute("LandSpread", def.LandSpread)
			am:SetAttribute("MoveSpread", def.MoveSpread)
			am:SetAttribute("StandSpread", def.StandSpread)
			am:SetAttribute("JumpSpread", def.JumpSpread)
			am:SetAttribute("RunSpread", def.RunSpread)
		end
		if t["Misc/GunMods/FullAuto"] then
			am:SetAttribute("Auto", true)
		else
			am:SetAttribute("Auto", def.Auto)
		end
		if t["Misc/GunMods/RapidFire"] then
			am:SetAttribute("FireRate", 0.01)
			am:SetAttribute("ScopedFireRate", 0.01)
		else
			am:SetAttribute("FireRate", def.FireRate)
			am:SetAttribute("ScopedFireRate", def.ScopedFireRate)
		end
		if t["Misc/GunMods/ConvertAmmo"] then
			am:SetAttribute("Ammo", 9e9)
			am:SetAttribute("StoredAmmo", 9e9)
		else
			am:SetAttribute("Ammo", def.Ammo)
			am:SetAttribute("StoredAmmo", def.StoredAmmo)
		end
		if t["Misc/GunMods/InfAmmo"] then
			am:SetAttribute("UseAmmo", 0)
		else
			if am:GetAttribute("UseAmmo") ~= nil then
				am:SetAttribute("UseAmmo", nil)
			end
		end
	end
end
local edgebugLock = false
local lastHumanoidState = Enum.HumanoidStateType.None
local bodyVel = nil
local wallOffsets = { CFrame.new(1, 0, 0), CFrame.new(-1, 0, 0) }
local function IsTouchingWall()
	if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return false end
	for _, off in next, wallOffsets do
		local pos = (LP.Character.HumanoidRootPart.CFrame * off).Position
		local ray = Ray.new(LP.Character.HumanoidRootPart.Position, (pos - LP.Character.HumanoidRootPart.Position).Unit * 2)
		local hit = workspace:FindPartOnRayWithIgnoreList(ray, { Cam, LP.Character, workspace.Destroyable, workspace.Debris })
		if hit then return true end
	end
	return false
end
local chatLast = 0
RunS.PreRender:Connect(function()
	if r.Game.IsAlive(LP) then
		local vs = Cam.ViewportSize
		local legitFovR = t["Legit/Fov/Value"] or 120
		if t["Legit/SilentAim"] then
			silentTarget = L.GetTarget(t["Legit/Fov"], legitFovR)
			if silentTarget then
				local hn = L.Hitboxes[t["Legit/Hitscan"] or "Head"] or "Head"
				silentPart = silentTarget.Character:FindFirstChild(hn)
			else
				silentPart = nil
			end
		else
			silentTarget = nil
			silentPart = nil
		end
		if t["Legit/Aimbot"] then
			local act = t["Legit/Aimbot/Activate"] or "Mouse 1"
			local pressed = (act == "Mouse 1" and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1))
				or (act == "Mouse 2" and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
			if pressed then
				local tgt = L.GetTarget(t["Legit/Fov"], legitFovR)
				if tgt then
					local hn = L.Hitboxes[t["Legit/Hitscan"] or "Head"] or "Head"
					local part = tgt.Character:FindFirstChild(hn)
					if part then
						local speed = t["Legit/Aimbot/Speed"] or 10
						local aimType = t["Legit/Aimbot/Type"] or "Mouse Movement"
						if aimType == "Mouse Movement" and r.Client.HasMousemoverel then
							speed = speed / 9
							local sp = Cam:WorldToViewportPoint(part.Position)
							local dx = (sp.X - vs.X / 2) * speed / 20.5
							local dy = (sp.Y - vs.Y / 2) * speed / 20.5
							mousemoverel(dx, dy)
						elseif aimType == "Lerp" then
							local goal = CFrame.new(Cam.CFrame.Position, part.Position)
							local ang = math.abs(math.deg(math.acos(Cam.CFrame.LookVector:Dot(goal.LookVector)))) * 2
							local alpha
							if t["Legit/Aimbot/SpeedType"] == "Exponential" then
								alpha = speed / 500
							else
								alpha = (speed / math.max(ang, 0.01)) / 100
							end
							Cam.CFrame = Cam.CFrame:Lerp(goal, alpha)
						else
							Cam.CFrame = CFrame.new(Cam.CFrame.Position, part.Position)
						end
					end
				end
			end
		end
		if t["Misc/Throwables/Teleport"] then
			throwTarget = L.GetTarget(false, math.huge)
			if throwTarget then throwPart = throwTarget.Character:FindFirstChild("Head") end
		end
	end
	if t["Visuals/Ambient"] then
		local ac = Flags["Visuals/Ambient/AmbientColor"]
		local oc = Flags["Visuals/Ambient/OutdoorAmbientColor"]
		if ac and ac.Color then Lighting.Ambient = ac.Color end
		if oc and oc.Color then Lighting.OutdoorAmbient = oc.Color end
	end
	if t["Visuals/NoSmoke"] then
		for _, smoke in next, CS:GetTagged("Smoke") do
			smoke:Destroy()
		end
	end
	if t["Visuals/TimeChanger"] then
		local tm = t["Visuals/TimeChanger/Time"] or 12
		if Lighting.ClockTime ~= tm then Lighting.ClockTime = tm end
	end
	task.spawn(WeaponModsInit)
	if t["Misc/JoinTeam"] then
		local isCT = (t["Misc/JoinTeam/Team"] == "Operators")
		pcall(function() RS.RE_Deploy:FireServer(isCT) end)
	end
	if t["Misc/ChatSpam"] and r.Client.HasRequire and r.Game.Network and tick() - chatLast > 3 then
		local msgType = t["Misc/ChatSpam/Type"] or "Neyrone"
		local msg
		if msgType == "Neyrone" then
			msg = string.rep("\n", 15) .. "neyrone on top " .. tostring(math.random(1, 5))
		elseif msgType == "Advertise" then
			msg = string.rep("\n", 15) .. "tg - neyrone_tech " .. tostring(math.random(1, 5))
		elseif msgType == "Japanese" then
			msg = string.rep("的是不\n", 16) .. tostring(math.random(1, 5))
		else
			msg = t["Misc/ChatSpam/Custom"] or "Neyrone on top!!"
		end
		pcall(function() r.Game.Network.FireServer("Chat", msg, false) end)
		chatLast = tick()
	end
end)
RunS.Heartbeat:Connect(function()
	if r.Game.IsAlive(LP) then
		if t["Rage/AntiAim"] and not (Flags["Rage/AntiAim/Disable"] and Flags["Rage/AntiAim/Disable"].Toggled) then
			LP.Character.Humanoid.AutoRotate = false
			local yaw = -math.atan2(Cam.CFrame.LookVector.Z, Cam.CFrame.LookVector.X) + math.rad(-90)
			local customYaw = math.rad(t["Rage/AntiAim/CustomYaw"] or 0)
			if t["Rage/AntiAim/Yaw"] == "Spin" then
				N._spin = (N._spin or 0) + (t["Rage/AntiAim/SpinSpeed"] or 3)
				if N._spin >= 360 then N._spin = 0 end
				yaw = yaw + math.rad(N._spin)
			elseif t["Rage/AntiAim/Yaw"] == "Random" then
				yaw = yaw + math.rad(math.random(0, 360))
			end
			local cf = CFrame.new(LP.Character.HumanoidRootPart.Position) * CFrame.Angles(0, yaw + customYaw, 0)
			local _, y = cf:ToOrientation()
			LP.Character.HumanoidRootPart.CFrame = CFrame.new(cf.Position) * CFrame.Angles(0, y, 0)
			if r.Client.HasRequire and r.Game.Network and r.Game.Network.FireServer then
				local pitch
				if t["Rage/AntiAim/Pitch"] == "Custom" then
					pitch = (t["Rage/AntiAim/CustomPitch"] or 0) / 100
				else
					pitch = math.random(-1, 1)
				end
				r.Game.Network.FireServer("0R5lsPxqfSH3", pitch, true)
			end
		else
			LP.Character.Humanoid.AutoRotate = true
		end
		if t["Rage/AntiAim/FakeDuck"] and Flags["Rage/AntiAim/FakeDuck/Bind"] and Flags["Rage/AntiAim/FakeDuck/Bind"].Toggled then
			if r.Client.HasRequire and r.Game.Ambassador and r.Game.Ambassador.Fire then
				r.Game.Ambassador.Fire("WPlay", "CrouchIdle", nil, 0)
			end
		end
		local hum = LP.Character.Humanoid
		local state = hum:GetState()
		if t["Misc/BypassSpeed"] and r.Game.Variables then
			if r.Game.Variables.crouch or r.Game.Variables.fullycrouched then
				r.Game.Variables.jumping = true
			else
				r.Game.Variables.jumping = false
			end
		end
		if t["Misc/AutoJump"] and UIS:IsKeyDown(Enum.KeyCode.Space)
			and hum.FloorMaterial ~= Enum.Material.Air
			and state ~= Enum.HumanoidStateType.Jumping
			and not edgebugLock then
			hum.Jump = true
		end
		if t["Misc/Noclip"] then
			for _, part in next, LP.Character:GetChildren() do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		else
			if LP.Character:FindFirstChild("HumanoidRootPart") then
				LP.Character.HumanoidRootPart.CanCollide = true
			end
		end
		if t["Misc/SpeedHack"] then
			local dir = Vector3.zero
			local spd = (t["Misc/SpeedHack/Speed"] or 40) / 10
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Cam.CFrame.RightVector end
			if dir.Magnitude > 0 then
				dir = dir.Unit * spd * 1.5
				dir = Vector3.new(dir.X, 0, dir.Z)
				LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame + (dir / 100 * 2)
			end
		end
		if t["Misc/Airstuck"] and Flags["Misc/Airstuck/Bind"] and Flags["Misc/Airstuck/Bind"].Toggled then
			LP.Character.HumanoidRootPart.Anchored = true
		else
			LP.Character.HumanoidRootPart.Anchored = false
		end
		if t["Misc/Pixelsurf"] and Flags["Misc/Pixelsurf/Bind"] and Flags["Misc/Pixelsurf/Bind"].Toggled then
			if not bodyVel then bodyVel = Instance.new("BodyVelocity") end
			if IsTouchingWall() then
				bodyVel.MaxForce = Vector3.new(1500, 1500, 1500)
				bodyVel.Velocity = Vector3.zero
				bodyVel.Parent = LP.Character.HumanoidRootPart
			else
				bodyVel.MaxForce = Vector3.zero
				bodyVel.Parent = nil
			end
		elseif bodyVel then
			bodyVel.MaxForce = Vector3.zero
			bodyVel.Parent = nil
		end
		if t["Misc/Edgebug"] and Flags["Misc/Edgebug/Bind"] and Flags["Misc/Edgebug/Bind"].Toggled and not edgebugLock then
			if lastHumanoidState == Enum.HumanoidStateType.Freefall and state == Enum.HumanoidStateType.Landed then
				edgebugLock = true
				local vel = LP.Character.HumanoidRootPart.Velocity
				for _ = 1, 5 do
					task.wait()
					LP.Character.HumanoidRootPart.Velocity = (Vector3.new(1.2, 0, 1.2) * vel) - Vector3.new(0, 15, 0)
				end
				task.wait()
				LP.Character.HumanoidRootPart.Velocity *= Vector3.new(1.8, 1, 1.8)
				if t["Misc/Edgebug/Notification"] then s:Notification("Edgebugged") end
				task.spawn(function()
					task.wait(t["Misc/Edgebug/Debounce"] or 0.2)
					edgebugLock = false
				end)
			end
		end
		lastHumanoidState = state
	end
	local vs = Cam.ViewportSize
	legitFovCircle.Radius = t["Legit/Fov/Value"] or 120
	legitFovCircle.Visible = t["Legit/Fov/Visible"] == true
	if Flags["Legit/Fov/Color"] and Flags["Legit/Fov/Color"].Color then
		legitFovCircle.Color = Flags["Legit/Fov/Color"].Color
	end
	legitFovCircle.NumSides = t["Legit/Fov/NumSides"] or 100
	legitFovCircle.Position = Vector2.new(math.floor(vs.X / 2), math.floor(vs.Y / 2))
	rageFovCircle.Radius = (vs.X * (((t["Rage/Fov/Value"] or 25) / 2) / Cam.FieldOfView)) / 2
	rageFovCircle.Visible = t["Rage/Fov/Visible"] == true
	if Flags["Rage/Fov/Color"] and Flags["Rage/Fov/Color"].Color then
		rageFovCircle.Color = Flags["Rage/Fov/Color"].Color
	end
	rageFovCircle.NumSides = t["Rage/Fov/NumSides"] or 100
	rageFovCircle.Position = Vector2.new(math.floor(vs.X / 2), math.floor(vs.Y / 2))
	task.spawn(KillAllInit)
	task.spawn(KillPriorityInit)
end)
if r.Client.HasHookmetamethod and r.Client.HasHookfunction then
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local method = getnamecallmethod()
		local args = { ... }
		if method == "Raycast" and self == workspace then
			if t["Legit/SilentAim"] and silentPart and (t["Legit/SilentAim/HitChance"] or 100) >= math.random(1, 100) then
				args[2] = (silentPart.Position - args[1]).Unit * args[2].Magnitude
				return oldNamecall(self, unpack(args))
			end
		elseif method == "FireServer" then
			if self == r.Game.FireEvent and args[1] and args[1].Position then
			elseif self.Name == "Throwable" and t["Misc/Throwables/Teleport"] and throwPart then
				args[2] = throwPart.CFrame
				args[3] = -100
				return oldNamecall(self, unpack(args))
			end
		end
		return oldNamecall(self, ...)
	end))
end
s:Notification(string.format("Loaded in %.4f seconds", os.clock() - a))
do
	local missing = {}
	if not r.Client.HasHookmetamethod then table.insert(missing, "hookmetamethod") end
	if not r.Client.HasMousemoverel then table.insert(missing, "mousemoverel") end
	if not r.Client.HasRequire then table.insert(missing, "require") end
	if not r.Client.FullRequire then table.insert(missing, "require (partial)") end
	if not r.Client.HasGetsenv then table.insert(missing, "getsenv") end
	if not r.Client.FullGetsenv then table.insert(missing, "getsenv (partial)") end
	if #missing > 0 then
		s:Notification("Missing: " .. table.concat(missing, ", "))
	end
end
pcall(function() UI:mountInterface(UI:Tab("Interface", "sliders")) end)
