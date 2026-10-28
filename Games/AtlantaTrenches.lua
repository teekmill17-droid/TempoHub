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
if getgenv().SuperNovaUnload then
	pcall(getgenv().SuperNovaUnload)
	getgenv().SuperNovaUnload = nil
end
local TeekUI = assert(
	loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))(),
	"TempoUI failed"
)
local UI = TeekUI.new({
	Title = "TEMPO",
	Subtitle = "Atlanta Trenches",
	Version = "v1",
})
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Games/lib/ExunysESP.lua"))()
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local Workspace = game:GetService("Workspace")
local GameFolder = Workspace:WaitForChild("GameFolder")
local Locations = GameFolder:WaitForChild("Locations")
local LocationsTBL = {
	["Marked"] = Locations:WaitForChild("Google Maps"):WaitForChild("MapLocations"),
}
local DrawingFonts = Drawing.Fonts or {UI = 0, System = 1, Plex = 2, Monospace = 3}
ESPLibrary.Load()
local Flags = {}
local holdBinds = {}
local tabs = {}
local function Env()
	return getgenv().ExunysDeveloperESP
end
local function Resolve(Path)
	local Keys = string.split(Path, ".")
	local Table = Env()
	for Index = 1, #Keys - 1 do
		Table = Table and Table[Keys[Index]]
	end
	return Table, Keys[#Keys]
end
local function Read(Path)
	local Table, Key = Resolve(Path)
	return Table and Table[Key]
end
local function Write(Path, Value)
	local Table, Key = Resolve(Path)
	if Table then Table[Key] = Value end
end
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
	return {
		Toggled = false,
		Mode = mode or "Hold",
		Key = defaultKey or Enum.KeyCode.E,
		Name = flagName,
	}
end
local function ensureTab(name, icon)
	if tabs[name] then return tabs[name] end
	local tab = UI:Tab(name, icon or "circle")
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
			tab:Label((kopts.Name or kflag or "Keybind") .. " [Key]")
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
	return api
end
local pageApi = {}
function pageApi:Section(opts)
	opts = opts or {}
	local tab = self._tab
	pcall(function() tab:Section(opts.Name or "Section") end)
	return sectionApi(tab)
end
local windowApi = {}
function windowApi:Page(opts)
	opts = opts or {}
	local name = opts.Name or "Tab"
	local tab = ensureTab(name)
	return setmetatable({ _tab = tab }, { __index = pageApi })
end
local v = windowApi
local t = Flags
local function Char()
	return Player.Character
end
local settings = {
	CandyFarm = false,
	LoadMap = true,
	AreaTime = 5,
	GunFarm = false,
	Check = false,
}
getgenv().SuperNovaUnload = function()
	settings.CandyFarm, settings.GunFarm, settings.Check = false, false, false
	local Environment = Env()
	if Environment and Environment.Exit then
		pcall(Environment.Exit, Environment)
	end
end
local OverviewPage = v:Page({ Name = "Overview" })
local PlayerPage = v:Page({ Name = "Player" })
local VisualPage = v:Page({ Name = "Visual" })
local WorldPage = v:Page({ Name = "World" })
local VehiclePage = v:Page({ Name = "Vehicle" })
local EconomyPage = v:Page({ Name = "Economy" })
local FarmPage = v:Page({ Name = "Farming" })
local SettingsPage = v:Page({ Name = "Settings" })
do
	local F = OverviewPage:Section({ Name = "Actions" })
	F:Button({
		Name = "Restart ESP",
		Callback = function()
			task.spawn(function()
				local e = Env()
				if e and e.Restart then e:Restart() end
			end)
		end,
	})
	F:Button({
		Name = "Unload",
		Callback = function()
			if getgenv().SuperNovaUnload then getgenv().SuperNovaUnload() end
		end,
	})
end
do
	local F = VisualPage:Section({ Name = "ESP Master" })
	F:Toggle({
		Name = "ESP Enabled",
		Flag = "ESP/Enabled",
		Default = Read("Settings.Enabled") == true,
		Callback = function(on) Write("Settings.Enabled", on) end,
	})
	F:Toggle({
		Name = "Team Check",
		Flag = "ESP/TeamCheck",
		Default = Read("Settings.TeamCheck") == true,
		Callback = function(on) Write("Settings.TeamCheck", on) end,
	})
	F:Toggle({
		Name = "Alive Check",
		Flag = "ESP/AliveCheck",
		Default = Read("Settings.AliveCheck") == true,
		Callback = function(on) Write("Settings.AliveCheck", on) end,
	})
	F:Toggle({
		Name = "NPC ESP",
		Flag = "ESP/EntityESP",
		Default = Read("Settings.EntityESP") == true,
		Callback = function(on) Write("Settings.EntityESP", on) end,
	})
end
do
	local F = VisualPage:Section({ Name = "Overlays" })
	for _, name in ipairs({"ESP", "Tracer", "Box", "HealthBar", "HeadDot", "Skeleton", "Highlight"}) do
		F:Toggle({
			Name = name,
			Flag = "ESP/Prop/" .. name,
			Default = Read("Properties." .. name .. ".Enabled") == true,
			Callback = function(on) Write("Properties." .. name .. ".Enabled", on) end,
		})
	end
end
do
	local F = PlayerPage:Section({ Name = "Silent Aim" })
	F:Toggle({ Name = "Enabled", Flag = "Combat/SilentAim", Default = false })
	F:Slider({ Name = "FOV Radius", Flag = "Combat/SilentAim/FOV", Min = 20, Default = 120, Max = 600 })
	F:Dropdown({ Name = "Aim Part", Flag = "Combat/SilentAim/Part", Items = {"Head", "Torso"}, Default = "Head" })
	F:Toggle({ Name = "Visible Only", Flag = "Combat/SilentAim/Visible", Default = true })
	F:Toggle({ Name = "Team Check", Flag = "Combat/TeamCheck", Default = false })
	F:Toggle({ Name = "Show FOV", Flag = "Combat/SilentAim/ShowFOV", Default = true })
end
do
	local F = PlayerPage:Section({ Name = "Triggerbot" })
	F:Toggle({ Name = "Enabled", Flag = "Combat/Triggerbot", Default = false })
	F:Slider({ Name = "Delay (ms)", Flag = "Combat/Triggerbot/Delay", Min = 0, Default = 50, Max = 500 })
	F:Toggle({ Name = "Fire on Silent", Flag = "Combat/Triggerbot/Silent", Default = false })
	F:Toggle({ Name = "Ignore Cars", Flag = "Combat/Triggerbot/IgnoreCars", Default = false })
end
do
	local F = PlayerPage:Section({ Name = "Character" })
	F:Toggle({ Name = "Walk Speed", Flag = "Character/WalkSpeed", Default = false })
	F:Slider({ Name = "Speed", Flag = "Character/WalkSpeed/Value", Min = 22, Default = 22, Max = 46 })
	F:Toggle({ Name = "Infinite Stamina", Flag = "Client/InfiniteStamina", Default = false })
	F:Toggle({ Name = "No Dehydration Slow", Flag = "Client/NoDehydration", Default = false })
	F:Toggle({ Name = "No Fall Damage", Flag = "Client/NoFallDamage", Default = false })
	F:Toggle({ Name = "Free Movement", Flag = "Client/FreeMovement", Default = false })
	F:Toggle({ Name = "Roll Dash", Flag = "Client/RollDash", Default = false })
	F:Slider({ Name = "Dash Speed", Flag = "Client/DashSpeed", Min = 25, Default = 25, Max = 75 })
end
do
	local F = PlayerPage:Section({ Name = "Fists / Anti-Aim" })
	F:Toggle({ Name = "Fast Fists", Flag = "Client/Fists", Default = false })
	F:Toggle({ Name = "Auto Stomp", Flag = "Client/AutoStomp", Default = false })
	F:Slider({ Name = "Stomp Range", Flag = "Client/StompRange", Min = 3, Default = 8, Max = 15 })
	F:Toggle({ Name = "Anti Aim", Flag = "Client/AntiAim", Default = false })
	F:Dropdown({ Name = "Yaw", Flag = "Client/AntiAim/Yaw", Items = {"Off", "Spin", "Jitter", "Backwards", "Sideways", "Random"}, Default = "Spin" })
	F:Dropdown({ Name = "Pitch", Flag = "Client/AntiAim/Pitch", Items = {"Off", "Down", "Up", "Jitter"}, Default = "Down" })
end
do
	local F = WorldPage:Section({ Name = "Interactions" })
	F:Toggle({ Name = "Hide from CCTV", Flag = "World/HideCCTV", Default = false })
end
do
	local F = VehiclePage:Section({ Name = "Garage" })
	F:Toggle({ Name = "No Fuel Drain", Flag = "Vehicle/NoFuelDrain", Default = false })
	F:Toggle({ Name = "Drive on Empty", Flag = "Vehicle/InfiniteFuel", Default = false })
	F:Toggle({ Name = "Car ESP", Flag = "Vehicle/CarESP", Default = false })
end
do
	local F = EconomyPage:Section({ Name = "Banking / Checks" })
	F:Toggle({ Name = "Auto Sign Checks", Flag = "Economy/Checks/AutoSign", Default = false })
	F:Toggle({ Name = "Auto Cash After Sign", Flag = "Economy/Checks/AutoCash", Default = false })
	F:Toggle({ Name = "Printer Manager", Flag = "Economy/Printers", Default = false })
end
do
	local F = FarmPage:Section({ Name = "Autofarm" })
	F:Toggle({
		Name = "Candy Collection",
		Flag = "Farm/Candy",
		Default = false,
		Callback = function(on) settings.CandyFarm = on end,
	})
	F:Toggle({
		Name = "Load Whole Map",
		Flag = "Farm/Candy/LoadMap",
		Default = true,
		Callback = function(on) settings.LoadMap = on end,
	})
	F:Slider({
		Name = "Seconds Per Area",
		Flag = "Farm/Candy/AreaTime",
		Min = 2,
		Default = 5,
		Max = 15,
		Callback = function(val) settings.AreaTime = val end,
	})
	F:Toggle({
		Name = "Improve Aim State",
		Flag = "Farm/Gun",
		Default = false,
		Callback = function(on) settings.GunFarm = on end,
	})
	F:Toggle({
		Name = "Auto Claim Daily Check",
		Flag = "Farm/DailyCheck",
		Default = false,
		Callback = function(on) settings.Check = on end,
	})
	F:Toggle({ Name = "Auto Math Book", Flag = "Farm/MathBook", Default = false })
end
do
	local F = SettingsPage:Section({ Name = "Safety" })
	F:Toggle({ Name = "Anti-AFK", Flag = "Safety/AntiAfk", Default = true })
	F:Toggle({ Name = "Staff Alert", Flag = "Safety/StaffAlert", Default = true })
	F:Toggle({ Name = "Leave When Staff Joins", Flag = "Safety/StaffLeave", Default = false })
end
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")
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
local Aim = {
	Silent = false,
	FOV = 120,
	ShowFOV = true,
	VisibleOnly = true,
	TeamCheck = false,
	AimPart = "Head",
	Trigger = false,
	TriggerDelay = 0.05,
	TriggerSilent = false,
	TriggerIgnoreCars = false,
}
local AimHook = getgenv().SuperNovaAimHook
if not AimHook then
	AimHook = {}
	getgenv().SuperNovaAimHook = AimHook
	local wrap = newcclosure or function(f) return f end
	local function FromGunClient()
		if not getcallingscript then return true end
		local ok, caller = pcall(getcallingscript)
		return not ok or caller == nil or caller.Name == "GunClient"
	end
	local OldNamecall
	OldNamecall = hookmetamethod(game, "__namecall", wrap(function(...)
		local self = ...
		local method = getnamecallmethod()
		if method == "ScreenPointToRay" and AimHook.Handler and typeof(self) == "Instance" and self.ClassName == "Camera" and FromGunClient() then
			local original = OldNamecall(...)
			local ok, bent = pcall(AimHook.Handler, original, select(2, ...))
			return ok and bent or original
		end
		return OldNamecall(...)
	end))
end
local function PlayersFolder()
	return GameFolder:FindFirstChild("Players")
end
local function OwnCharacters()
	local folder = PlayersFolder()
	return {Player.Character, folder and folder:FindFirstChild(Player.Name), workspace.CurrentCamera}
end
local function HitCharacter(part)
	local folder = PlayersFolder()
	local node = part
	while node and node ~= workspace do
		if node.Parent == folder or (node:IsA("Model") and node:FindFirstChildOfClass("Humanoid")) then
			return node
		end
		node = node.Parent
	end
end
local function IsEnemy(character)
	if not character or character == Player.Character then return false end
	local owner = Players:GetPlayerFromCharacter(character) or Players:FindFirstChild(character.Name)
	if owner == Player then return false end
	if Aim.TeamCheck and owner and owner.Team ~= nil and owner.Team == Player.Team then return false end
	local hum = character:FindFirstChildOfClass("Humanoid")
	return hum == nil or hum.Health > 0
end
local function AimPartOf(character)
	if Aim.AimPart == "Head" then
		return character:FindFirstChild("HeadHitbox", true) or character:FindFirstChild("Head")
	end
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
end
local function NewParams()
	local params = RaycastParams.new()
	local ignore = OwnCharacters()
	if Aim.TriggerIgnoreCars then
		table.insert(ignore, GameFolder:FindFirstChild("Vehicles"))
	end
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore
	return params
end
local function IsVisible(part, character)
	local origin = workspace.CurrentCamera.CFrame.Position
	local result = workspace:Raycast(origin, part.Position - origin, NewParams())
	return result == nil or result.Instance:IsDescendantOf(character)
end
local function SilentTarget(screenPoint)
	local camera = workspace.CurrentCamera
	local folder = PlayersFolder()
	local best, bestDist = nil, Aim.FOV
	for _, other in next, Players:GetPlayers() do
		local character = other ~= Player and (other.Character or (folder and folder:FindFirstChild(other.Name)))
		if character and IsEnemy(character) then
			local part = AimPartOf(character)
			if part then
				local pos, onScreen = camera:WorldToScreenPoint(part.Position)
				local dist = (Vector2.new(pos.X, pos.Y) - screenPoint).Magnitude
				if onScreen and dist <= bestDist and (not Aim.VisibleOnly or IsVisible(part, character)) then
					best, bestDist = part, dist
				end
			end
		end
	end
	return best
end
local function RayTarget(origin, direction)
	local result = workspace:Raycast(origin, direction.Unit * 1000, NewParams())
	local character = result and HitCharacter(result.Instance)
	return IsEnemy(character) and character or nil
end
local function RayAt(original, part)
	local camera = workspace.CurrentCamera.CFrame.Position
	local depth = (original.Origin - camera).Magnitude
	local unit = (part.Position - camera).Unit
	return Ray.new(camera + unit * depth, unit)
end
AimHook.Handler = function(original, x, y)
	Aim.Silent = t["Combat/SilentAim"] == true
	Aim.FOV = t["Combat/SilentAim/FOV"] or 120
	Aim.VisibleOnly = t["Combat/SilentAim/Visible"] ~= false
	Aim.TeamCheck = t["Combat/TeamCheck"] == true
	Aim.AimPart = t["Combat/SilentAim/Part"] or "Head"
	if Aim.Silent and x and y then
		local part = SilentTarget(Vector2.new(x, y))
		if part then return RayAt(original, part) end
	end
	return original
end
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Thickness = 1
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
local function HoldingGun()
	local folder = PlayersFolder()
	for _, character in next, {Player.Character, folder and folder:FindFirstChild(Player.Name)} do
		if character and character:FindFirstChildOfClass("Tool") then
			return true
		end
	end
	return false
end
local firing = false
RunService.RenderStepped:Connect(function()
	Aim.Silent = t["Combat/SilentAim"] == true
	Aim.FOV = t["Combat/SilentAim/FOV"] or 120
	Aim.ShowFOV = t["Combat/SilentAim/ShowFOV"] ~= false
	Aim.Trigger = t["Combat/Triggerbot"] == true
	Aim.TriggerDelay = (t["Combat/Triggerbot/Delay"] or 50) / 1000
	Aim.TriggerSilent = t["Combat/Triggerbot/Silent"] == true
	Aim.TriggerIgnoreCars = t["Combat/Triggerbot/IgnoreCars"] == true
	Aim.AimPart = t["Combat/SilentAim/Part"] or "Head"
	Aim.VisibleOnly = t["Combat/SilentAim/Visible"] ~= false
	Aim.TeamCheck = t["Combat/TeamCheck"] == true
	local mousePos = UIS:GetMouseLocation()
	FOVCircle.Visible = Aim.Silent and Aim.ShowFOV
	FOVCircle.Radius = Aim.FOV
	FOVCircle.Position = mousePos
	if not Aim.Trigger or firing or not (mouse1press and mouse1release) or not HoldingGun() then
		return
	end
	local camera = workspace.CurrentCamera
	local mouseRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
	local onTarget = RayTarget(mouseRay.Origin, mouseRay.Direction) ~= nil
	if not onTarget and Aim.TriggerSilent and Aim.Silent then
		onTarget = SilentTarget(mousePos - GuiService:GetGuiInset()) ~= nil
	end
	if onTarget then
		firing = true
		task.spawn(function()
			task.wait(Aim.TriggerDelay)
			mouse1press()
			task.wait(0.03)
			mouse1release()
			firing = false
		end)
	end
end)
local speedEnabled = false
local speedValue = 22
local originalSpeed = setmetatable({}, {__mode = "k"})
local function restoreSpeed()
	for target, original in next, originalSpeed do
		if target.Parent then target.WalkSpeed = original end
	end
	table.clear(originalSpeed)
end
RunService.Heartbeat:Connect(function()
	speedEnabled = t["Character/WalkSpeed"] == true
	speedValue = t["Character/WalkSpeed/Value"] or 22
	if not speedEnabled then return end
	local character = Player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if originalSpeed[humanoid] == nil then
			originalSpeed[humanoid] = humanoid.WalkSpeed
		end
		if humanoid.WalkSpeed ~= speedValue then
			humanoid.WalkSpeed = speedValue
		end
	end
end)
local antiAfk = true
Player.Idled:Connect(function()
	antiAfk = t["Safety/AntiAfk"] ~= false
	if antiAfk then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.zero)
	end
end)
local CandyFolder = Workspace:WaitForChild("HalloweenCandies", 10)
local TargetsFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("AimTargets")
local AimImprovEvent = Remotes:FindFirstChild("Misc") and Remotes.Misc:FindFirstChild("HitAimTarget")
RunService.RenderStepped:Connect(function()
	if settings.CandyFarm and CandyFolder then
		local candies = CandyFolder:GetChildren()
		local root = Char() and Char():FindFirstChild("HumanoidRootPart")
		if #candies >= 1 and root then
			for _, v in pairs(candies) do
				if v:FindFirstChild("Hitbox") then
					firetouchinterest(root, v.Hitbox, 0)
					firetouchinterest(root, v.Hitbox, 1)
				end
			end
		end
	end
	if settings.GunFarm and TargetsFolder and AimImprovEvent then
		pcall(function()
			for _, v in pairs(TargetsFolder:GetChildren()) do
				local hitPart = v:GetChildren()[2]
				if hitPart then AimImprovEvent:InvokeServer(hitPart) end
			end
		end)
	end
end)
task.spawn(function()
	local function spots()
		local list = {}
		local function add(object)
			local ok, pos = pcall(function()
				return object:IsA("Model") and object:GetPivot().Position or object.Position
			end)
			if ok and typeof(pos) == "Vector3" then
				table.insert(list, {object.Name, pos})
			end
		end
		local transit = Locations:FindFirstChild("PublicTransportation")
		transit = transit and transit:FindFirstChild("Destinations")
		for _, folder in next, {transit, LocationsTBL["Marked"]} do
			for _, child in next, folder and folder:GetChildren() or {} do
				add(child)
			end
		end
		return list
	end
	local function stayInArea()
		local started = os.clock()
		while settings.CandyFarm and settings.LoadMap and os.clock() - started < settings.AreaTime do
			task.wait(0.25)
		end
		if not CandyFolder then return end
		local extra = os.clock()
		while settings.CandyFarm and #CandyFolder:GetChildren() > 0 and os.clock() - extra < settings.AreaTime do
			task.wait(0.25)
		end
	end
	while true do
		local active = settings.CandyFarm and settings.LoadMap
		if not active then
			task.wait(1)
		elseif not Workspace.StreamingEnabled then
			task.wait(2)
		else
			for _, other in next, Players:GetPlayers() do
				if not (settings.CandyFarm and settings.LoadMap) then break end
				local root = other ~= Player and other.Character and other.Character:FindFirstChild("HumanoidRootPart")
				if root then
					pcall(Player.RequestStreamAroundAsync, Player, root.Position, 2)
					stayInArea()
				end
			end
			for _, spot in next, spots() do
				if not (settings.CandyFarm and settings.LoadMap) then break end
				pcall(Player.RequestStreamAroundAsync, Player, spot[2], 2)
				stayInArea()
			end
		end
	end
end)
local checkNotif = Remotes:FindFirstChild("Misc") and Remotes.Misc:FindFirstChild("ShowDailyCheckUI")
if checkNotif then
	checkNotif.OnClientEvent:Connect(function()
		if not settings.Check then return end
		local claim = Remotes.Misc:FindFirstChild("ClaimDailyCheck")
		if claim then claim:FireServer() end
	end)
end
select("#", "[TEMPO Atlanta Trenches] loaded")
pcall(function() UI:mountInterface(UI:Tab("Interface", "sliders")) end)
