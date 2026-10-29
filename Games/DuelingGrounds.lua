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
local TeekUI = assert(
	loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))(),
	"TempoUI failed"
)
local UI = TeekUI.new({
	Title = "TEMPO",
	Subtitle = "Dueling Grounds",
	Version = "v1",
})
local a = os.clock()
cloneref = cloneref or function(b) return b end
local TweenService = cloneref(game:GetService("TweenService"))
local UIS = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Players = cloneref(game:GetService("Players"))
local RS = cloneref(game:GetService("ReplicatedStorage"))
local LP = Players.LocalPlayer
pcall(function()
	for _, child in ipairs(Lighting:GetChildren()) do
		if (child:IsA("BlurEffect") or child:IsA("DepthOfFieldEffect")) and not child.Name:lower():find("aim") then
			child.Enabled = false
		end
	end
end)
local GameManager = nil
pcall(function()
	GameManager = require(RS:WaitForChild("GameManager", 5))
end)
local Remotes = RS:FindFirstChild("Remotes")
local PlayerCharacterRemote = Remotes and Remotes:FindFirstChild("PlayerCharacter")
local WeaponInventoryRemote = Remotes and Remotes:FindFirstChild("WeaponInventory")
local WeaponCosmetics = {
	Katana = { "Default", "Bloodluster", "Champion", "Christmas", "DarkMatter", "DeepBlue", "Flaming", "Oathbreaker" },
	Kusarigama = { "Default", "BronzeViper", "Celestial", "Magma", "Oathbreaker" },
	Daggers = { "Default", "BronzeViper", "Christmas", "CrimsonFangs", "DarkMatter", "Draconic", "Golden", "Oathbreaker" },
	Naginata = { "Default", "Christmas", "DarkMatter", "DeepBlue", "Oathbreaker", "SerpentSlayer" },
	Gauntlets = { "Default", "Bloodluster", "Golden", "Magma", "Oathbreaker" },
	Warhammer = { "Default", "DarkMatter", "Iceborn", "Oathbreaker", "Viper" },
	CurvedBlades = { "Default", "Butterfly", "Draconic", "Oathbreaker", "Scorchflower" },
	BoStaff = { "Default", "Bloodluster", "DeepBlue", "Void" },
}
local WeaponList = { "Katana", "Kusarigama", "Daggers", "Naginata", "Gauntlets", "Warhammer", "CurvedBlades", "BoStaff" }
pcall(function()
	local WeaponModulesShared = RS:FindFirstChild("WeaponModulesShared")
	if not WeaponModulesShared then return end
	for _, child in ipairs(WeaponModulesShared:GetChildren()) do
		if child:IsA("ModuleScript") and child.Name ~= "BaseWeapon" then
			local ok, result = pcall(require, child)
			if ok and result and result.WeaponInfo and result.WeaponInfo.Cosmetics then
				local t = {}
				for k in pairs(result.WeaponInfo.Cosmetics) do
					table.insert(t, k)
				end
				table.sort(t)
				WeaponCosmetics[child.Name] = t
			end
		end
	end
end)
local Config = {
	AutoParry = false,
	AutoDodge = false,
	LegitMode = true,
	AlwaysDefendUltimates = true,
	ParryChance = 100,
	DodgeChance = 100,
	ParryFlash = true,
	AutoUltimate = false,
	UltimateNearTarget = true,
	UltimateDistance = 12,
	UltimateFacingOnly = true,
	UnlockAllCosmetics = true,
	AutoApplyCosmetics = true,
	AutoSaveConfig = true,
	UIScale = 100,
	ToggleKey = Enum.KeyCode.RightControl,
}
local State = {
	handler = nil,
	connections = {},
	equippedCosmetics = {
		Katana = "Oathbreaker",
		Kusarigama = "Celestial",
		Daggers = "CrimsonFangs",
		Naginata = "SerpentSlayer",
		Gauntlets = "Magma",
		Warhammer = "Iceborn",
		CurvedBlades = "Scorchflower",
		BoStaff = "Void",
	},
	isScriptDestroyed = false,
	lastUltimateTrigger = 0,
}
local CONFIG_ROOT = "TEMPO"
local CONFIG_FOLDER = "TEMPO/Configs"
local CONFIG_GAME = "TEMPO"
local CONFIG_GAMEID = 9051406594
local currentConfigName = "default"
local function ensureFolders()
	pcall(function()
		if typeof(makefolder) ~= "function" then return end
		if typeof(isfolder) == "function" then
			if not isfolder(CONFIG_ROOT) then makefolder(CONFIG_ROOT) end
			if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
		else
			makefolder(CONFIG_ROOT)
			makefolder(CONFIG_FOLDER)
		end
	end)
end
local function saveConfig(name)
	name = name or currentConfigName or "default"
	pcall(function()
		ensureFolders()
		local path = CONFIG_FOLDER .. "/" .. name .. ".json"
		local payload = {
			Game = CONFIG_GAME,
			GameId = CONFIG_GAMEID,
			PlaceId = game.PlaceId,
			ConfigName = name,
			LastSaved = os.time(),
			Settings = {
				AutoParry = Config.AutoParry,
				AutoDodge = Config.AutoDodge,
				LegitMode = Config.LegitMode,
				AlwaysDefendUltimates = Config.AlwaysDefendUltimates,
				ParryChance = Config.ParryChance,
				DodgeChance = Config.DodgeChance,
				ParryFlash = Config.ParryFlash,
				AutoUltimate = Config.AutoUltimate,
				UltimateNearTarget = Config.UltimateNearTarget,
				UltimateDistance = Config.UltimateDistance,
				UltimateFacingOnly = Config.UltimateFacingOnly,
				UnlockAllCosmetics = Config.UnlockAllCosmetics,
				AutoApplyCosmetics = Config.AutoApplyCosmetics,
				AutoSaveConfig = Config.AutoSaveConfig,
				UIScale = Config.UIScale,
				ToggleKey = Config.ToggleKey.Name,
			},
			Cosmetics = State.equippedCosmetics,
		}
		if typeof(writefile) == "function" then
			writefile(path, HttpService:JSONEncode(payload))
		end
	end)
end
local function listConfigs()
	local out = {}
	pcall(function()
		if typeof(listfiles) ~= "function" then return end
		for _, v in ipairs(listfiles(CONFIG_FOLDER) or {}) do
			if v:sub(-5):lower() == ".json" and (typeof(isfile) ~= "function" or isfile(v)) then
				local ok, raw = pcall(readfile, v)
				if ok and raw then
					local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
					if ok2 and type(data) == "table" and (data.Game == CONFIG_GAME or data.GameId == CONFIG_GAMEID) then
						local match = v:match("([^/\\]+)%.json$") or v
						table.insert(out, match)
					end
				end
			end
		end
	end)
	if #out == 0 then table.insert(out, "default") end
	table.sort(out)
	return out
end
local function loadConfig(name)
	name = name or currentConfigName or "default"
	local ok = false
	pcall(function()
		local path = CONFIG_FOLDER .. "/" .. name .. ".json"
		if typeof(isfile) ~= "function" or not isfile(path) then return end
		if typeof(readfile) ~= "function" then return end
		local data = HttpService:JSONDecode(readfile(path))
		if type(data) ~= "table" then return end
		if data.Game ~= CONFIG_GAME and data.GameId ~= CONFIG_GAMEID then return end
		if type(data.Settings) == "table" then
			for k, setting in pairs(data.Settings) do
				if k == "ToggleKey" and type(setting) == "string" and Enum.KeyCode[setting] then
					Config.ToggleKey = Enum.KeyCode[setting]
				elseif Config[k] ~= nil and type(setting) == type(Config[k]) then
					Config[k] = setting
				end
			end
		end
		if type(data.Cosmetics) == "table" then
			for k, cosmetic in pairs(data.Cosmetics) do
				if State.equippedCosmetics[k] ~= nil and type(cosmetic) == "string" then
					State.equippedCosmetics[k] = cosmetic
				end
			end
		end
		ok = true
	end)
	return ok
end
local function autoSave()
	if Config.AutoSaveConfig then
		saveConfig(currentConfigName)
	end
end
ensureFolders()
loadConfig(currentConfigName)
local function isGrounded(handler)
	if not handler then return true end
	local pc = handler.PhysicsComponent
	if not pc or not pc.IsGrounded then return true end
	local ok, result = pcall(function() return pc:IsGrounded() end)
	return ok and result or true
end
local function clearConnections()
	for _, c in ipairs(State.connections) do
		pcall(function() c:Disconnect() end)
	end
	table.clear(State.connections)
end
local function getHandler()
	if State.handler then return State.handler end
	local char = LP.Character
	if not (char and GameManager) then return nil end
	local ok, controller = pcall(function()
		return GameManager:GetController("CharacterController")
	end)
	if not (ok and controller) then return nil end
	local ok2, handler = pcall(function()
		return controller:GetCharacterHandler(char)
	end)
	if ok2 and handler then
		State.handler = handler
		return State.handler
	end
	return nil
end
local function hasWeaponEquipped()
	local h = getHandler()
	if not h then return false end
	if h.EquippedWeapon ~= nil then return true end
	local char = LP.Character
	if char and char:GetAttribute("EquippedWeapon") ~= nil then return true end
	if not h.WeaponToHandler then return false end
	for _, v in pairs(h.WeaponToHandler) do
		if v and (v.IsHolding or v.IsEquipped) then return true end
	end
	return false
end
local function isUltimateImpact(payload)
	if not payload or typeof(payload) ~= "table" then return false end
	if payload.triggerUltimate or payload.isUltimate or payload.IsUltimate then return true end
	local sourceModule = payload.sourceModule
	if sourceModule then
		local name = typeof(sourceModule) == "Instance" and sourceModule.Name or tostring(sourceModule)
		if name:find("Ultimate") or name:find("Special") or name:find("Critical") then return true end
		local ok, result = pcall(require, sourceModule)
		if ok and type(result) == "table" then
			if result.IsUltimate or result.isUltimate or result.IsSpecial then return true end
			if type(result.impacts) == "table" then
				local idx = payload.sourceImpactN or 1
				local impact = result.impacts[idx]
				if impact and impact.impactInfo then
					local info = impact.impactInfo
					if info.superArmorDamage and info.superArmorDamage >= 100 then return true end
					if info.impactResults and info.impactResults.GetHit and info.impactResults.GetHit.triggerUltimate then
						return true
					end
				end
			end
		end
	end
	if payload.superArmorDamage and payload.superArmorDamage >= 100 then return true end
	return false
end
local function canDodge()
	local h = getHandler()
	if not (h and h.ActionManager) then return false end
	if h.IsDodging then return false end
	local char = LP.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if not isGrounded(h) then return false end
	if h.IsStaggered then return false end
	local am = h.ActionManager
	if am._dodgeStamina and am._dodgeStamina <= 0 then return false end
	if am.CurrentMiniStun then return false end
	local ca = am.CurrentAction
	if ca then
		local at = ca.ActionType
		if at == "BasicAttack" or at == "HeavyAttack" or at == "LightAttack" or at == "CriticalStrike"
			or at == "Ultimate" or at == "UltimateAbility" then return false end
		if ca.Recovering then return false end
		if at == "Stagger" or at == "Jump" or at == "Dodge" or at == "Intro" or at == "Death" then return false end
	end
	return true
end
local function canParry()
	local h = getHandler()
	if not (h and h.ActionManager) then return false end
	if not hasWeaponEquipped() then return false end
	if h.IsParrying or h.IsBlocking or h.ActionManager.BlockAction ~= nil then return false end
	local char = LP.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if not isGrounded(h) then return false end
	local am = h.ActionManager
	if (am._blockCooldown and am._blockCooldown > 0) or am.IsSwappingWeapon then return false end
	if h.IsDodging or h.IsStaggered then return false end
	local ca = am.CurrentAction
	if ca then
		local at = ca.ActionType
		if at == "BasicAttack" or at == "HeavyAttack" or at == "LightAttack" or at == "CriticalStrike"
			or at == "Ultimate" or at == "UltimateAbility" then return false end
		if ca.Recovering then return false end
		if at == "Stagger" or at == "Jump" or at == "Dodge" or at == "Intro" or at == "Death" then return false end
		if ca.ParallelBlockAllowed or ca.CanParry then return true end
		return false
	end
	return true
end
local function doParry()
	local h = getHandler()
	if not (h and h.ActionManager) then return end
	if not hasWeaponEquipped() then return end
	if h.IsParrying or h.IsBlocking then return end
	if Config.LegitMode and not canParry() then return end
	local q = h._blockInputQueue
	if type(q) == "table" then
		table.clear(q)
		table.insert(q, { state = true })
	end
	h.IsParrying = true
	task.delay(0.14, function()
		local h2 = getHandler()
		if h2 and h2.ActionManager then
			local ba = h2.ActionManager.BlockAction
			if ba then
				ba._wantsToRelease = true
			else
				h2.IsParrying = false
			end
		end
	end)
end
local function doDodge()
	local h = getHandler()
	if not (h and h.ActionManager) then return end
	if h.IsDodging then return end
	if Config.LegitMode and not canDodge() then return end
	h.IsDodging = true
	h._desiredDodge = 0.2667
	task.delay(0.35, function()
		local h2 = getHandler()
		if h2 and h2.IsDodging then
			h2.IsDodging = nil
		end
	end)
end
local function triggerUltimate()
	local h = getHandler()
	if not h then return false end
	if not hasWeaponEquipped() then return false end
	if h.CanPerformUltimate then
		local ok, result = pcall(function() return h:CanPerformUltimate() end)
		if ok and not result then return false end
	else
		local model = h.OriginalModel or LP.Character
		local energy = model and model:GetAttribute("UltimateEnergy") or 0
		if energy < 100 then return false end
	end
	local am = h.ActionManager
	if am and am.CurrentAction then
		local at = am.CurrentAction.ActionType
		if at == "Ultimate" or at == "UltimateAbility" then return false end
	end
	if h.IsStaggered then return false end
	h._desiredQueuedAction = "Ultimate"
	h._desiredQueuedActionDuration = 0.33333333333333
	if am and am.TryQueueBasicAttack then
		pcall(function() am:TryQueueBasicAttack("Ultimate") end)
	end
	pcall(function()
		local VIM = game:GetService("VirtualInputManager")
		local key = Enum.KeyCode.R
		pcall(function()
			local ctrl = require(RS.GameManager):GetController("PlayerKeybindsController")
			if ctrl and ctrl.Keybinds and ctrl.Keybinds.UltimateAbility then
				local kb = ctrl.Keybinds.UltimateAbility.KeyboardBinding
				if kb and Enum.KeyCode[kb] then
					key = Enum.KeyCode[kb]
				end
			end
		end)
		VIM:SendKeyEvent(true, key, false, game)
		task.delay(0.05, function()
			VIM:SendKeyEvent(false, key, false, game)
		end)
	end)
	State.lastUltimateTrigger = tick()
	return true
end
local function setupImpactListener()
	clearConnections()
	local reg = PlayerCharacterRemote
		and PlayerCharacterRemote:FindFirstChild("Update")
		and PlayerCharacterRemote.Update:FindFirstChild("RegisterImpact")
	if not reg then return end
	local conn = reg.OnClientEvent:Connect(function(_, payload)
		if not (Config.AutoParry or Config.AutoDodge or Config.AlwaysDefendUltimates) then return end
		local isUlt = isUltimateImpact(payload)
		local hasWeapon = hasWeaponEquipped()
		if isUlt and Config.AlwaysDefendUltimates then
			if hasWeapon and Config.AutoParry and (not Config.LegitMode or canParry()) then
				doParry()
				if Config.AutoDodge and (not Config.LegitMode or canDodge()) then
					doDodge()
				end
			elseif Config.AutoDodge and (not Config.LegitMode or canDodge()) then
				doDodge()
			elseif not Config.LegitMode then
				if hasWeapon then doParry() else doDodge() end
			end
			return
		end
		local didParry = false
		if hasWeapon and Config.AutoParry and math.random(1, 100) <= Config.ParryChance then
			if not Config.LegitMode or canParry() then
				doParry()
				didParry = true
			end
		end
		if Config.AutoDodge and not didParry and math.random(1, 100) <= Config.DodgeChance then
			if not Config.LegitMode or canDodge() then
				doDodge()
			end
		end
	end)
	table.insert(State.connections, conn)
	local h = getHandler()
	if h and h.Parried then
		local flashConn = h.Parried:Connect(function()
			if not Config.ParryFlash then return end
			local sg = Instance.new("ScreenGui")
			sg.Name = "TEMPOParryFlash"
			sg.IgnoreGuiInset = true
			sg.ResetOnSpawn = false
			pcall(function()
				sg.Parent = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui")
			end)
			local fr = Instance.new("Frame")
			fr.Size = UDim2.fromScale(1, 1)
			fr.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
			fr.BackgroundTransparency = 0.9
			fr.Parent = sg
			local tw = TweenService:Create(fr, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
			})
			tw:Play()
			tw.Completed:Once(function() sg:Destroy() end)
		end)
		table.insert(State.connections, flashConn)
	end
end
task.spawn(function()
	while true do
		if State.isScriptDestroyed then return end
		task.wait(0.08)
		if not Config.AutoUltimate then continue end
		if tick() - State.lastUltimateTrigger <= 1.8 then continue end
		local h = getHandler()
		if not (h and hasWeaponEquipped()) then continue end
		local canUlt = false
		if h.CanPerformUltimate then
			local ok, res = pcall(function() return h:CanPerformUltimate() end)
			canUlt = ok and res
		else
			local model = h.OriginalModel or LP.Character
			canUlt = (model and model:GetAttribute("UltimateEnergy") or 0) >= 100
		end
		if not canUlt then continue end
		local char = LP.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
		if not (hum and hum.Health > 0 and root) then continue end
		local am = h.ActionManager
		if am and am.CurrentAction then
			local at = am.CurrentAction.ActionType
			if at == "Ultimate" or at == "UltimateAbility" then continue end
		end
		if h.IsStaggered then continue end
		local nearOk = true
		if Config.UltimateNearTarget then
			nearOk = false
			local pos = root.Position
			local look = root.CFrame.LookVector
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr == LP then continue end
				local pchar = plr.Character
				local proot = pchar and pchar:FindFirstChild("HumanoidRootPart")
				local phum = pchar and pchar:FindFirstChildOfClass("Humanoid")
				if not (proot and phum and phum.Health > 0) then continue end
				local delta = proot.Position - pos
				if delta.Magnitude <= (Config.UltimateDistance or 12)
					and (not Config.UltimateFacingOnly or look:Dot(delta.Unit) >= 0.17) then
					nearOk = true
					break
				end
			end
		end
		if nearOk then
			triggerUltimate()
		end
	end
end)
local function stripEffects(weaponName)
	local char = LP.Character
	if not char then return end
	local function wipe(container)
		if not container then return end
		local root = container:FindFirstChild(weaponName) or container
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
				or d:IsA("PointLight") or d:IsA("Highlight") then
				pcall(function()
					d.Enabled = false
					d:Destroy()
				end)
			end
		end
	end
	wipe(char:FindFirstChild("MountedWeapons"))
	wipe(char:FindFirstChild("Weapons"))
	local hum = char:FindFirstChildOfClass("Humanoid")
	local anim = hum and hum:FindFirstChildOfClass("Animator")
	if not anim then return end
	for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
		local name = track.Animation and track.Animation.Name:lower() or ""
		if name:find("ult") or name:find("special") or name:find("attack")
			or (weaponName and name:find(weaponName:lower())) then
			pcall(function() track:Stop(0.05) end)
		end
	end
end
local function setCosmetic(weaponName, cosmeticName)
	if not (weaponName and cosmeticName) then return end
	State.equippedCosmetics[weaponName] = cosmeticName
	stripEffects(weaponName)
	pcall(function()
		local ctrl = GameManager and GameManager:GetController("WeaponInventoryController")
		if not ctrl then return end
		ctrl.WeaponToSelectedCosmetic[weaponName] = cosmeticName
		if ctrl.WeaponCosmeticChanged then
			ctrl.WeaponCosmeticChanged:Fire(weaponName, cosmeticName)
		end
	end)
	local char = LP.Character
	if char then
		local mounted = char:FindFirstChild("MountedWeapons")
		local w = mounted and mounted:FindFirstChild(weaponName)
		if w then w:SetAttribute("CurrentCosmetic", cosmeticName) end
	end
	pcall(function()
		local h = getHandler()
		local wh = h and h.WeaponToHandler and h.WeaponToHandler[weaponName]
		if not wh then return end
		if typeof(wh.CurrentCosmeticInstance) == "Instance" then
			pcall(function() wh.CurrentCosmeticInstance:Destroy() end)
		end
		if typeof(wh.CosmeticModel) == "Instance" then
			pcall(function() wh.CosmeticModel:Destroy() end)
		end
		wh:SetCosmetic(cosmeticName)
	end)
	autoSave()
end
local function unlockAllCosmetics()
	local count = 0
	pcall(function()
		if not GameManager then return end
		local ctrl = GameManager:GetController("WeaponInventoryController")
		local mods = RS:FindFirstChild("WeaponModulesShared")
		if not (ctrl and mods) then return end
		for _, child in ipairs(mods:GetChildren()) do
			if child:IsA("ModuleScript") and child.Name ~= "BaseWeapon" then
				local ok, result = pcall(require, child)
				if ok and result and result.WeaponInfo and result.WeaponInfo.Cosmetics then
					if not ctrl.WeaponToUnlockedCosmetics[child.Name] then
						ctrl.WeaponToUnlockedCosmetics[child.Name] = {}
					end
					for k in pairs(result.WeaponInfo.Cosmetics) do
						ctrl.WeaponToUnlockedCosmetics[child.Name][k] = true
						count = count + 1
					end
					ctrl.UnlockedWeapons[child.Name] = true
				end
			end
		end
		ctrl.IsCosmeticUnlocked = function() return true end
		ctrl.IsWeaponUnlocked = function() return true end
	end)
	pcall(function()
		if not GameManager then return end
		local ctrl = GameManager:GetController("IntroInventoryController")
		if ctrl then
			ctrl.IsIntroUnlocked = function() return true end
		end
	end)
	pcall(function()
		if not GameManager then return end
		local ctrl = GameManager:GetController("SequenceInventoryController")
		if ctrl and ctrl.Kinds then
			for _, kind in pairs(ctrl.Kinds) do
				kind.IsUnlocked = function() return true end
			end
		end
	end)
	return count
end
local function applyAllEquipped()
	local char = LP.Character
	if not char then return end
	local mounted = char:FindFirstChild("MountedWeapons")
	for weapon, cosmetic in pairs(State.equippedCosmetics) do
		stripEffects(weapon)
		local w = mounted and mounted:FindFirstChild(weapon)
		if w then w:SetAttribute("CurrentCosmetic", cosmetic) end
		pcall(function()
			local h = getHandler()
			local wh = h and h.WeaponToHandler and h.WeaponToHandler[weapon]
			if not wh then return end
			if typeof(wh.CurrentCosmeticInstance) == "Instance" then
				pcall(function() wh.CurrentCosmeticInstance:Destroy() end)
			end
			if typeof(wh.CosmeticModel) == "Instance" then
				pcall(function() wh.CosmeticModel:Destroy() end)
			end
			wh:SetCosmetic(cosmetic)
		end)
	end
end
local function watchCharacter(char)
	if not char then return end
	task.spawn(function()
		local mounted = char:WaitForChild("MountedWeapons", 8)
		if not mounted then return end
		for _, child in ipairs(mounted:GetChildren()) do
			local cos = State.equippedCosmetics[child.Name]
			if cos then
				stripEffects(child.Name)
				child:SetAttribute("CurrentCosmetic", cos)
				pcall(function()
					local h = getHandler()
					local wh = h and h.WeaponToHandler and h.WeaponToHandler[child.Name]
					if not wh then return end
					if typeof(wh.CurrentCosmeticInstance) == "Instance" then
						pcall(function() wh.CurrentCosmeticInstance:Destroy() end)
					end
					if typeof(wh.CosmeticModel) == "Instance" then
						pcall(function() wh.CosmeticModel:Destroy() end)
					end
					wh:SetCosmetic(cos)
				end)
			end
		end
		mounted.ChildAdded:Connect(function(child)
			task.wait(0.15)
			local cos = State.equippedCosmetics[child.Name]
			if cos then
				stripEffects(child.Name)
				child:SetAttribute("CurrentCosmetic", cos)
			end
		end)
	end)
end
local Flags = {}
local tabs = {}
local function ensureTab(name, icon)
	if tabs[name] then return tabs[name] end
	local iconMap = {
		Combat = "sword", Cosmetics = "sparkles", Settings = "settings",
	}
	local tab = UI:Tab(name, icon or iconMap[name] or "circle")
	tabs[name] = tab
	return tab
end
local function sectionApi(tab)
	local api = {}
	function api:Toggle(opts)
		opts = opts or {}
		local flag = opts.Flag
		local default = opts.Default
		if default == nil then default = false end
		if flag then Flags[flag] = default and true or false end
		pcall(function()
			tab:Toggle(opts.Name or flag or "Toggle", default and true or false, function(v)
				local on = v and true or false
				if flag then Flags[flag] = on end
				if opts.Callback then pcall(opts.Callback, on) end
			end)
		end)
		return api
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
		return api
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
				for _, item in ipairs(items) do
					local capture = item
					tab:Button(tostring(capture), false, function()
						if flag then Flags[flag] = capture end
						if opts.Callback then pcall(opts.Callback, capture) end
					end)
				end
			end
		end)
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
	function api:Label(opts)
		opts = opts or {}
		pcall(function() tab:Label(opts.Text or opts.Name or "") end)
		return api
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
		return api
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
	local tab = ensureTab(opts.Name or "Tab")
	return setmetatable({ _tab = tab }, { __index = pageApi })
end
local s = { Flags = Flags }
function s:Notification(text)
	pcall(function() UI:Notify(tostring(text), "good") end)
end
function s:Unload()
	State.isScriptDestroyed = true
	clearConnections()
	pcall(function() UI:Destroy() end)
end
pcall(function()
	if UI.Boot then
		UI:Boot({ "checking executor", "building interface", "loading modules", "ready" }, function()
			UI:Notify("TEMPO Hub loaded", "good")
		end)
	else
		UI:Notify("TEMPO Hub loaded", "good")
	end
end)
local CombatPage = windowApi:Page({ Name = "Combat" })
local CosmeticsPage = windowApi:Page({ Name = "Cosmetics" })
local SettingsPage = windowApi:Page({ Name = "Settings" })
do
	local F = CombatPage:Section({ Name = "Auto Defense" })
	F:Toggle({
		Name = "Auto Parry", Flag = "Combat/AutoParry", Default = Config.AutoParry,
		Callback = function(v)
			Config.AutoParry = v
			autoSave()
			if Config.AutoParry or Config.AutoDodge or Config.AlwaysDefendUltimates then
				setupImpactListener()
			else
				clearConnections()
			end
		end,
	})
	F:Toggle({
		Name = "Legit Mode (Strict Checks)", Flag = "Combat/LegitMode", Default = Config.LegitMode,
		Callback = function(v)
			Config.LegitMode = v
			autoSave()
		end,
	})
	F:Toggle({
		Name = "Auto Dodge", Flag = "Combat/AutoDodge", Default = Config.AutoDodge,
		Callback = function(v)
			Config.AutoDodge = v
			autoSave()
			if Config.AutoParry or Config.AutoDodge or Config.AlwaysDefendUltimates then
				setupImpactListener()
			else
				clearConnections()
			end
		end,
	})
	F:Toggle({
		Name = "100% Defense on Ultimates", Flag = "Combat/AlwaysDefendUltimates", Default = Config.AlwaysDefendUltimates,
		Callback = function(v)
			Config.AlwaysDefendUltimates = v
			autoSave()
			if Config.AutoParry or Config.AutoDodge or Config.AlwaysDefendUltimates then
				setupImpactListener()
			else
				clearConnections()
			end
		end,
	})
end
do
	local F = CombatPage:Section({ Name = "Defense Parameters" })
	F:Slider({
		Name = "Parry Chance (%)", Flag = "Combat/ParryChance", Min = 0, Max = 100, Default = Config.ParryChance,
		Callback = function(v) Config.ParryChance = v; autoSave() end,
	})
	F:Slider({
		Name = "Dodge Chance (%)", Flag = "Combat/DodgeChance", Min = 0, Max = 100, Default = Config.DodgeChance,
		Callback = function(v) Config.DodgeChance = v; autoSave() end,
	})
	F:Toggle({
		Name = "Parry Flash Effect", Flag = "Combat/ParryFlash", Default = Config.ParryFlash,
		Callback = function(v) Config.ParryFlash = v; autoSave() end,
	})
end
do
	local F = CombatPage:Section({ Name = "Ultimate Ability" })
	F:Toggle({
		Name = "Auto Ultimate Ability", Flag = "Combat/AutoUltimate", Default = Config.AutoUltimate,
		Callback = function(v) Config.AutoUltimate = v; autoSave() end,
	})
	F:Toggle({
		Name = "Only Near Opponent", Flag = "Combat/UltimateNearTarget", Default = Config.UltimateNearTarget,
		Callback = function(v) Config.UltimateNearTarget = v; autoSave() end,
	})
	F:Toggle({
		Name = "Must Face Opponent", Flag = "Combat/UltimateFacingOnly", Default = Config.UltimateFacingOnly,
		Callback = function(v) Config.UltimateFacingOnly = v; autoSave() end,
	})
	F:Slider({
		Name = "Strike Range (Studs)", Flag = "Combat/UltimateDistance", Min = 6, Max = 25, Default = Config.UltimateDistance,
		Callback = function(v) Config.UltimateDistance = v; autoSave() end,
	})
	F:Button({
		Name = "Force Trigger Ultimate",
		Callback = function() triggerUltimate() end,
	})
end
do
	local selectedWeapon = "Katana"
	local selectedSkin = State.equippedCosmetics.Katana or "Default"
	local F = CosmeticsPage:Section({ Name = "Weapon Skin Changer" })
	F:Dropdown({
		Name = "Weapon", Flag = "Cosmetics/Weapon", Items = WeaponList, Default = selectedWeapon,
		Callback = function(v)
			selectedWeapon = v
			local list = WeaponCosmetics[v] or { "Default" }
			selectedSkin = State.equippedCosmetics[v] or list[1] or "Default"
			Flags["Cosmetics/Skin"] = selectedSkin
		end,
	})
	F:Dropdown({
		Name = "Skin", Flag = "Cosmetics/Skin", Items = WeaponCosmetics[selectedWeapon] or { "Default" }, Default = selectedSkin,
		Callback = function(v) selectedSkin = v end,
	})
	F:Button({
		Name = "Equip Skin",
		Callback = function()
			setCosmetic(selectedWeapon, selectedSkin)
			s:Notification("Equipped " .. selectedSkin .. " on " .. selectedWeapon)
		end,
	})
end
do
	local F = CosmeticsPage:Section({ Name = "Inventory Unlocker" })
	F:Toggle({
		Name = "Auto Unlock on Menu", Flag = "Cosmetics/UnlockAll", Default = Config.UnlockAllCosmetics,
		Callback = function(v)
			Config.UnlockAllCosmetics = v
			autoSave()
			if v then unlockAllCosmetics() end
		end,
	})
	F:Button({
		Name = "Force Unlock All",
		Callback = function()
			local n = unlockAllCosmetics()
			s:Notification("Unlocked " .. tostring(n) .. " cosmetics")
		end,
	})
	F:Button({
		Name = "Equip All Top Tier Skins",
		Callback = function()
			local top = {
				Katana = "DarkMatter",
				Kusarigama = "Celestial",
				Daggers = "CrimsonFangs",
				Naginata = "SerpentSlayer",
				Gauntlets = "Magma",
				Warhammer = "Iceborn",
				CurvedBlades = "Scorchflower",
				BoStaff = "Void",
			}
			for k, v in pairs(top) do
				setCosmetic(k, v)
			end
			s:Notification("Top tier skins equipped")
		end,
	})
	F:Toggle({
		Name = "Auto Re-apply on Spawn", Flag = "Cosmetics/AutoApply", Default = Config.AutoApplyCosmetics,
		Callback = function(v) Config.AutoApplyCosmetics = v; autoSave() end,
	})
end
do
	local F = SettingsPage:Section({ Name = "Configuration" })
	local configNameBox = currentConfigName
	F:Textbox({
		Name = "Config Name", Flag = "Settings/ConfigName", Default = currentConfigName,
		Callback = function(txt)
			local cleaned = tostring(txt):gsub("[%c%p%s]", "_")
			if cleaned ~= "" then configNameBox = cleaned end
		end,
	})
	F:Dropdown({
		Name = "Select Config", Flag = "Settings/SelectConfig", Items = listConfigs(), Default = currentConfigName,
		Callback = function(v)
			currentConfigName = v
			configNameBox = v
		end,
	})
	F:Button({
		Name = "Save Config",
		Callback = function()
			local name = (configNameBox and configNameBox ~= "") and configNameBox or currentConfigName or "default"
			name = name:gsub("[%c%p%s]", "_")
			if name == "" then name = "default" end
			currentConfigName = name
			saveConfig(name)
			s:Notification("Saved config: " .. name)
		end,
	})
	F:Button({
		Name = "Load Config",
		Callback = function()
			if not loadConfig(currentConfigName) then
				s:Notification("Failed to load config")
				return
			end
			s:Notification("Loaded config: " .. currentConfigName)
			applyAllEquipped()
			if Config.AutoParry or Config.AutoDodge or Config.AlwaysDefendUltimates then
				clearConnections()
				setupImpactListener()
			else
				clearConnections()
			end
		end,
	})
	F:Button({
		Name = "Refresh Configs",
		Callback = function()
			s:Notification("Configs: " .. table.concat(listConfigs(), ", "))
		end,
	})
	F:Toggle({
		Name = "Auto Save Config", Flag = "Settings/AutoSave", Default = Config.AutoSaveConfig,
		Callback = function(v)
			Config.AutoSaveConfig = v
			if v then saveConfig(currentConfigName) end
		end,
	})
end
do
	local F = SettingsPage:Section({ Name = "Unload" })
	F:Button({
		Name = "Unload Script",
		Callback = function() s:Unload() end,
	})
	F:Label({ Text = "TEMPO Hub" })
end
LP.CharacterAdded:Connect(function(char)
	State.handler = nil
	task.wait(0.8)
	if Config.AutoParry or Config.AutoDodge or Config.AlwaysDefendUltimates then
		clearConnections()
		setupImpactListener()
	end
	if Config.AutoApplyCosmetics then
		applyAllEquipped()
	end
	watchCharacter(char)
end)
if LP.Character then
	watchCharacter(LP.Character)
	if Config.AutoParry or Config.AutoDodge or Config.AlwaysDefendUltimates then
		setupImpactListener()
	end
end
if Config.UnlockAllCosmetics then
	unlockAllCosmetics()
end
if Config.AutoApplyCosmetics then
	applyAllEquipped()
end
s:Notification(string.format("Loaded in %.4f seconds", os.clock() - a))
pcall(function() UI:mountInterface(UI:Tab("Interface", "sliders")) end)
