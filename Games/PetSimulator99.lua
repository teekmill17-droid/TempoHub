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
local function DzGuard(fn)
    local ok, err = xpcall(fn, function(e)
        return tostring(e) .. "\n" .. debug.traceback(nil, 2)
    end)
    if ok then return end
    local full = tostring(err or "unknown error")
    warn("[Tempo] " .. full)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Tempo - script error",
            Text = full:match("^[^\n]*") or full,
            Duration = 10,
        })
    end)
end
DzGuard(function()
local _dzEnv = (getgenv and getgenv()) or _G
_dzEnv.DzPS99_Gen = (_dzEnv.DzPS99_Gen or 0) + 1
local MY_GEN = _dzEnv.DzPS99_Gen
local MyLib
local function alive()
    if _dzEnv.DzPS99_Gen ~= MY_GEN then return false end
    if MyLib and (MyLib.Unloading or MyLib.Unloaded) then return false end
    return true
end
local _conns = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    _conns[#_conns + 1] = c
    return c
end
local HttpService       = game:GetService("HttpService")
local Lighting          = game:GetService("Lighting")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TeleportService   = game:GetService("TeleportService")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
bind(LocalPlayer.Idled, function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
local G = {}
local Net
do
    local Lib = ReplicatedStorage:WaitForChild("Library", 20)
    if not Lib then
        error("[Tempo] ReplicatedStorage.Library never appeared - the game did not finish loading.", 0)
    end
    local Client = Lib:WaitForChild("Client", 20)
    local function want(parent, name)
        local inst = parent and parent:FindFirstChild(name)
        if not inst then return nil end
        local ok, mod = pcall(require, inst)
        if ok and type(mod) == "table" then return mod end
        return nil
    end
    G.want = want
    Net = want(Client, "Network")
    G.Client   = Client
    G.Save     = want(Client, "Save")
    G.Money    = want(Client, "CurrencyCmds")
    G.Break    = want(Client, "BreakableFrontend")
    G.Map      = want(Client, "MapCmds")
    G.Zone     = want(Client, "ZoneCmds")
    G.PlayerPet = want(Client, "PlayerPet")
    G.Pets     = want(Client, "PetCmds")
    G.PetNet   = want(Client, "PetNetworking")
    G.Eggs     = want(Client, "EggCmds")
    G.Hatch    = want(Client, "HatchingCmds")
    G.CustomEg = want(Client, "CustomEggsCmds")
    G.Settings = want(Client, "SettingsCmds")
    G.AutoFarm = want(Client, "AutoFarmCmds")
    G.Orbs     = want(Client, "OrbCmds")
    G.Upgrade  = want(Client, "UpgradeCmds")
    G.Rebirth  = want(Client, "RebirthCmds")
    G.Teleport = want(Client, "TeleportMapCmds")
    G.Potion   = want(Client, "PotionCmds")
    G.Fruit    = want(Client, "FruitCmds")
    G.Lootbox  = want(Client, "LootboxCmds")
    G.Hover    = want(Client, "HoverboardCmds")
    G.Ultimate = want(Client, "UltimateCmds")
    G.Inv      = want(Client, "InventoryCmds")
    G.Instance = want(Client, "InstancingCmds")
    G.Chests   = want(Client, "InstanceChestsCmds")
    G.Daycare  = want(Client, "DaycareCmds")
    G.Boost    = want(Client, "BoostCmds")
    G.Consum   = want(Client, "ConsumableCmds")
    G.Mastery  = want(Client, "MasteryCmds")
    G.Wheel    = want(Client, "SpinnyWheelCmds")
    G.Pinata   = want(Client, "PinataChallengeCmds")
    G.ZonesUtil = want(Lib:FindFirstChild("Util"), "ZonesUtil")
    G.Dir       = want(Lib, "Directory")
    G.Functions = want(Lib, "Functions")
    G.RanksUtil = want(Lib:FindFirstChild("Util"), "RanksUtil")
    G.LoginStk  = want(Client, "LoginStreakCmds")
    G.Balancing = want(Lib, "Balancing")
    G.Rank      = want(Client, "RankCmds")
    G.Machines  = want(Client, "MachineCmds")
    G.Orb = G.Orbs and want(Client:FindFirstChild("OrbCmds"), "Orb") or nil
end
local function fire(name, ...)
    if not Net then return false end
    return pcall(Net.Fire, name, ...)
end
local function invoke(name, ...)
    if not Net then return false, nil, "network unavailable" end
    local ok, a, b = pcall(Net.Invoke, name, ...)
    if not ok then return false, nil, tostring(a) end
    return true, a, b
end
local function invokeOk(name, ...)
    local wasCalled, ret = invoke(name, ...)
    return wasCalled and ret ~= false, ret
end
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function uiCall(fn)
    return function(...)
        local args = table.pack(...)
        task.spawn(function()
            local ok, err = pcall(fn, table.unpack(args, 1, args.n))
            if not ok then warn("[Tempo] callback: " .. tostring(err)) end
        end)
    end
end
local function gameCall(fn, ...)
    if type(fn) ~= "function" then return false, nil end
    local args = table.pack(...)
    local done, ok, res = false, false, nil
    task.spawn(function()
        ok, res = pcall(fn, table.unpack(args, 1, args.n))
        done = true
    end)
    local deadline = os.clock() + 5
    while not done and os.clock() < deadline do task.wait() end
    return ok, res
end
local function save()
    if not G.Save then return nil end
    local ok, data = pcall(G.Save.Get)
    if ok and type(data) == "table" then return data end
    return nil
end
local function tpTo(cf)
    local hrp = getHRP()
    if not hrp then return false end
    local aim = (typeof(cf) == "Vector3") and CFrame.new(cf) or cf
    local ok = pcall(function() hrp.CFrame = aim end)
    return ok
end
local function distTo(aim)
    local hrp = getHRP()
    if not hrp then return math.huge end
    local pos
    if typeof(aim) == "Vector3" then pos = aim
    elseif typeof(aim) == "CFrame" then pos = aim.Position
    elseif typeof(aim) == "Instance" then
        if aim:IsA("BasePart") then pos = aim.Position
        elseif aim:IsA("Model") then
            local okp, piv = pcall(aim.GetPivot, aim)
            pos = okp and piv.Position or nil
        end
    end
    if not pos then return math.huge end
    return (hrp.Position - pos).Magnitude
end
local getUrl = _dzEnv.DzHub_GetUrl or function(path)
    return "" .. path
end
local DEV_MODE = _dzEnv.DzHub_DevMode
local isMobile = _dzEnv.DzHub_IsMobile
if isMobile == nil then
    isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
if _dzEnv.Library then pcall(function() _dzEnv.Library:Unload() end) end
local libUrl = DEV_MODE and getUrl("DzLib/DzLibV3.lua")
    or _dzEnv.DzHub_LibUrl
    or getUrl("DzLib/DzLib.lua")
local Library = (function()
	local TeekUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))()
	local TICK = "\u{2713} "
	local L = { Unloading = false, Unloaded = false, _un = {}, _conns = {} }
	local UI
	function L:SetMenuKeybind() end
	function L:GetIconPack() end
	function L:ResolveIcon() return nil end
	function L:LoadAutoloadConfig() end
	function L:OnUnload(fn) table.insert(self._un, fn) end
	function L:Connect(sig, fn) local c = sig:Connect(fn) table.insert(self._conns, c) return c end
	function L:Notification(title, msg, dur)
		pcall(function() UI:Notify(tostring(title) .. (msg and (": " .. tostring(msg)) or ""), "info", dur or 3) end)
	end
	function L:Unload()
		if self.Unloaded then return end
		self.Unloading = true
		for _, fn in ipairs(self._un) do pcall(fn) end
		for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
		pcall(function() UI:Destroy() end)
		self.Unloaded = true
	end
	local function section(t, title)
		t:Section(title)
		local S = {}
		function S:AddToggle(o)
			local h = t:Toggle(o.Name, o.Default and true or false, o.Callback)
			local function set(_, v) h.Set(v and true or false, true) end
			return { Set = set, SetValue = set, Get = function() return h.Get() end }
		end
		function S:AddButton(o) t:Button(o.Name, false, o.Callback) return {} end
		function S:AddSlider(o)
			local h = t:Slider(o.Name, o.Min or 0, o.Max or 100, o.Default or o.Min or 0, o.Callback, o.Suffix)
			local function set(_, v) h.Set(v) end
			return { Set = set, SetValue = set }
		end
		function S:AddLabel(o)
			local h = t:Label(type(o) == "table" and o.Name or o)
			return { SetText = function(_, v) h.Text = tostring(v) end }
		end
		function S:AddTextbox(o) t:Input(o.Placeholder or o.Name, o.Default or "", o.Callback) return {} end
		function S:AddDropdown(o)
			local values = o.Items or {}
			if o.Multi then
				local set, h = {}, nil
				for _, x in ipairs(type(o.Default) == "table" and o.Default or {}) do set[x] = true end
				local function items()
					local out = {}
					for _, x in ipairs(values) do out[#out + 1] = (set[x] and TICK or "") .. x end
					return #out > 0 and out or { "-" }
				end
				local function list() local r = {} for _, x in ipairs(values) do if set[x] then r[#r + 1] = x end end return r end
				h = t:Dropdown(o.Name, items(), nil, function(pick)
					local x = tostring(pick)
					if x:sub(1, #TICK) == TICK then x = x:sub(#TICK + 1) end
					if x == "-" then return end
					set[x] = not set[x] or nil
					h.SetItems(items(), (set[x] and TICK or "") .. x)
					if o.Callback then o.Callback(list()) end
				end)
				return { Refresh = function(_, nv) values = nv or {} h.SetItems(items()) end }
			end
			local h = t:Dropdown(o.Name, values, o.Default, o.Callback)
			return { Refresh = function(_, nv) h.SetItems(nv or {}, h.Get()) end, Set = function(_, v) h.Set(v) end }
		end
		return S
	end
	local function tabObj(t, prefix)
		return {
			AddSection = function(_, o) return section(t, prefix and (prefix .. " - " .. tostring(o.Name)) or tostring(o.Name)) end,
			AddSubTab = function(_, o) return tabObj(t, o.Name) end,
		}
	end
	function L:CreateWindow(o)
		UI = TeekUI.new({ Title = "TEMPO", Subtitle = o.SubName or "", Version = "v1" })
		local W = {}
		function W:AddTab(o2) return tabObj(UI:Tab(o2.Name, o2.Icon)) end
		function W:CreateInfoPage() end
		function W:HideLoading() pcall(function() UI:mountInterface(UI:Tab("Interface", "sliders")) end) end
		return W
	end
	return L
end)()
assert(type(Library) == "table", "[Tempo] DzLib failed to load.")
_dzEnv.Library = Library
MyLib = Library
if type(Library.SetMenuKeybind) == "function" then
    Library:SetMenuKeybind(Enum.KeyCode.LeftControl)
end
local Window = Library:CreateWindow({
    Name = "Tempo", SubName = "Pet Simulator 99",
    ToggleButtonEnabled = isMobile, KeybindListEnabled = true, SettingsTabEnabled = true,
})
_dzEnv.DzWindow = Window
Window:CreateInfoPage({ devMode = DEV_MODE })
local DzLib = setmetatable({
    SaveManager = {
        SetLibrary = function() end, IgnoreThemeSettings = function() end,
        BuildConfigSection = function() end,
        LoadAutoloadConfig = function() return Library:LoadAutoloadConfig(true) end,
        Folder = "",
    },
}, { __index = Library })
_dzEnv.DzLib = DzLib
local function notify(title, msg, dur)
    pcall(function() DzLib:Notification(title, msg, dur or 3) end)
end
if type(Library.OnUnload) == "function" then
    pcall(function()
        Library:OnUnload(function()
            for _, c in ipairs(_conns) do pcall(function() c:Disconnect() end) end
            _conns = {}
        end)
    end)
end
task.spawn(function() pcall(function()
    if type(Library.GetIconPack) == "function" then Library:GetIconPack("lucide") end
    local urls, seen = {}, {}
    local function add(name)
        if type(name) ~= "string" or name == "" then return end
        local r = Library:ResolveIcon(name)
        if type(r) == "string" and r:match("^rbxassetid://") and not seen[r] then
            seen[r] = true; urls[#urls+1] = r
        end
    end
    for _, n in ipairs({
        "chevron-right", "egg", "gift", "globe", "hammer", "info", "party-popper",
        "paw-print", "server", "settings"
    }) do add(n) end
    if #urls > 0 then pcall(function() game:GetService("ContentProvider"):PreloadAsync(urls) end) end
end) end)
local FarmTab    = Window:AddTab({ Name = "Farm",    Icon = "hammer" })
local EggsTab    = Window:AddTab({ Name = "Eggs",    Icon = "egg" })
local PetsTab    = Window:AddTab({ Name = "Pets",    Icon = "paw-print" })
local CollectTab = Window:AddTab({ Name = "Collect", Icon = "gift" })
local WorldTab   = Window:AddTab({ Name = "World",   Icon = "globe" })
local ServerTab  = Window:AddTab({ Name = "Server",  Icon = "server" })
local Sub = (function()
    local function mk(tab, name)
        if type(tab) == "table" and type(tab.AddSubTab) == "function" then
            local ok, sub = pcall(tab.AddSubTab, tab, { Name = name })
            if ok and type(sub) == "table" then return sub end
        end
        return tab
    end
    return {
        FarmBreak   = mk(FarmTab, "Breakables"),
        FarmZones   = mk(FarmTab, "Zones"),
        FarmOrbs    = mk(FarmTab, "Orbs"),
        EggsHatch   = mk(EggsTab, "Hatch"),
        PetsManage  = mk(PetsTab, "Manage"),
        ColClaims   = mk(CollectTab, "Claims"),
        ColBalloon  = mk(CollectTab, "Balloons"),
        ColUpgrade  = mk(CollectTab, "Upgrades"),
        WorldTp     = mk(WorldTab, "Teleport"),
        WorldChar   = mk(WorldTab, "Character"),
        WorldRender = mk(WorldTab, "Render"),
        SrvMain     = mk(ServerTab, "Server"),
        SrvJob      = mk(ServerTab, "Job IDs"),
        SrvPlace    = mk(ServerTab, "Places"),
    }
end)()
local S = {
    autoBreak     = false,
    tapsPerSec    = 8,
    focusNearest  = true,
    prioSpecial   = false,
    prioTipos     = {},
    prioIds       = {},
    fastBreak     = false,
    sendPets      = true,
    spreadPets    = false,
    stayInZone    = false,
    bestBreakZone = false,
    autoBuyZone   = false,
    bestArena     = false,
    petSpeedOn    = false,
    petSpeed      = 1,
    orbMagnet     = false,
    orbRange      = 1500,
    orbInstant    = false,
    autoHatch     = false,
    hatchEggId    = nil,
    hatchAmount   = 1,
    useMaxEggs    = false,
    autoHatchNear = false,
    autoHatchCE   = false,
    ceUid         = nil,
    ceAmount      = 1,
    ceUseMax      = false,
    autoEquipBest = false,
    savedSpeed    = nil,
    noclip        = false,
}
do
    local sec = Sub.FarmBreak:AddSection({ Name = "Auto Break", Side = 1, Icon = "hammer" })
    local function currentZone()
        if not G.Map then return nil end
        local ok, z = pcall(G.Map.GetCurrentZone)
        if ok and type(z) == "string" then return z end
        return nil
    end
    local ownsVIP = false
    do
        local Gp = G.want(G.Client, "Gamepasses")
        local DirGp = G.want(ReplicatedStorage.Library:FindFirstChild("Directory"), "Gamepasses")
        if Gp and DirGp and DirGp.VIP then
            local ok, res = gameCall(Gp.Owns, DirGp.VIP.ProductId)
            ownsVIP = ok and res == true
        end
    end
    local function canHit(b)
        if not b or not b.model or b.health == nil or b.health <= 0 then return false end
        if b.dir and (b.dir.NoTapping or b.disableDamage) then return false end
        if not ownsVIP then
            local ok, vip = pcall(b.model.GetAttribute, b.model, "VIPBreakable")
            if ok and vip then return false end
        end
        return true
    end
    local CLASSES = { "Normal", "Chest" }
    local function typeOf(b)
        return (b and b.dir and b.dir.BreakableType) and tostring(b.dir.BreakableType) or "?"
    end
    local function isSpecial(b)
        return typeOf(b) ~= "Coin"
    end
    local function aims(zoneName)
        if not (G.Break and zoneName) then return {} end
        local hasType = next(S.prioTipos) ~= nil
        local hasId   = next(S.prioIds)   ~= nil
        local out = {}
        for _, cl in ipairs(CLASSES) do
            local ok, listing = pcall(G.Break.AllByZoneAndClass, zoneName, cl)
            if ok and type(listing) == "table" then
                for _, b in pairs(listing) do
                    if canHit(b)
                        and not (hasType and not S.prioTipos[typeOf(b)])
                        and not (hasId   and not S.prioIds[tostring(b.id)]) then
                        out[#out + 1] = b
                    end
                end
            end
        end
        return out
    end
    local function pickAim(listing, i)
        local pool = listing
        if S.prioSpecial then
            local esp = {}
            for _, b in ipairs(listing) do
                if isSpecial(b) then esp[#esp + 1] = b end
            end
            if #esp > 0 then pool = esp end
        end
        if S.focusNearest then
            local aim, bestOne = nil, math.huge
            for _, b in ipairs(pool) do
                local d = distTo(b.position)
                if d < bestOne then bestOne, aim = d, b end
            end
            return aim, i
        end
        if i > #pool then i = 1 end
        return pool[i], i + 1
    end
    local lastSend = 0
    local function playerPets()
        if not G.PlayerPet then return nil end
        local ok, meus = pcall(G.PlayerPet.GetByPlayer, LocalPlayer)
        if not ok or type(meus) ~= "table" then return nil end
        local listing = {}
        for _, pet in pairs(meus) do listing[#listing + 1] = pet end
        return listing
    end
    local function sendPetsToTarget(model)
        if not (S.sendPets and model) then return end
        if os.clock() - lastSend < 0.5 then return end
        local pets = playerPets()
        if not pets then return end
        lastSend = os.clock()
        for _, pet in ipairs(pets) do
            pcall(function() pet:SetTarget(model) end)
        end
    end
    local function spreadPetsAcross(listing)
        if not S.spreadPets then return end
        if os.clock() - lastSend < 0.5 then return end
        local pets = playerPets()
        if not (pets and #pets > 0 and #listing > 0) then return end
        lastSend = os.clock()
        local sortedList = table.clone(listing)
        table.sort(sortedList, function(x, y)
            return distTo(x.position) < distTo(y.position)
        end)
        for idx, pet in ipairs(pets) do
            local aim = sortedList[((idx - 1) % #sortedList) + 1]
            if aim and aim.model then
                pcall(function() pet:SetTarget(aim.model) end)
            end
        end
    end
    local function breakZonePart(zoneName)
        if not (G.ZonesUtil and zoneName) then return nil end
        local ok, folderRef = pcall(G.ZonesUtil.GetBreakableZones, zoneName)
        if not (ok and typeof(folderRef) == "Instance") then return nil end
        for _, p in ipairs(folderRef:GetChildren()) do
            if p:IsA("BasePart") then return p end
        end
        return nil
    end
    local function insideTheBox(part)
        local hrp = getHRP()
        if not (hrp and part) then return false end
        local rel = part.CFrame:PointToObjectSpace(hrp.Position)
        return math.abs(rel.X) <= part.Size.X / 2 + 2
           and math.abs(rel.Z) <= part.Size.Z / 2 + 2
    end
    local function goToBreakArea(zoneName)
        if not G.Map then return false end
        zoneName = zoneName or currentZone()
        if not zoneName then return false end
        local part = breakZonePart(zoneName)
        if not part and G.ZonesUtil then
            local ok, cf = pcall(G.ZonesUtil.GetTeleportPartLocation, zoneName)
            if not (ok and typeof(cf) == "CFrame") then return false end
            tpTo(cf + Vector3.new(0, 6, 0))
            local deadline = os.clock() + 5
            repeat
                task.wait(0.25)
                part = breakZonePart(zoneName)
            until part or os.clock() > deadline
            if not part then return true end
        end
        if not part then return false end
        if insideTheBox(part) then return true end
        return tpTo(CFrame.new(part.Position + Vector3.new(0, 6, 0)))
    end
    sec:AddToggle({ Name = "Auto Break", Default = false, Tooltip = "Damages every breakable in the zone you own, at the same tap rate the game's own client uses. Does not teleport.", Callback = function(state)
        S.autoBreak = state
        if not state then return end
        task.spawn(function()
            local i = 1
            while alive() and S.autoBreak do
                local interval = 1 / math.clamp(S.tapsPerSec, 1, 16)
                local zoneName = currentZone()
                local listing = aims(zoneName)
                if #listing == 0 then
                    task.wait(1)
                else
                    if S.stayInZone then goToBreakArea(zoneName) end
                    local aim
                    aim, i = pickAim(listing, i)
                    if aim then
                        if S.fastBreak then
                            for _, b in ipairs(listing) do
                                pcall(function()
                                    Net.UnreliableFire("Breakables_PlayerDealDamage", b.uid)
                                end)
                            end
                        else
                            pcall(function()
                                Net.UnreliableFire("Breakables_PlayerDealDamage", aim.uid)
                            end)
                        end
                        if S.spreadPets then
                            spreadPetsAcross(listing)
                        else
                            sendPetsToTarget(aim.model)
                        end
                    end
                    task.wait(interval)
                end
            end
        end)
    end })
    sec:AddSlider({ Name = "Taps / Second", Default = 8, Min = 1, Max = 16, Rounding = 0, Suffix = "/s", Tooltip = "The game's own client taps 8x/s, or 16x/s with the Swift Taps enchant. Above that the server throttles you anyway - measured 4x the packets for 20% more damage.", Callback = function(v)
        S.tapsPerSec = v
    end })
    sec:AddToggle({ Name = "Focus Nearest", Default = true, Tooltip = "Always hit the closest breakable. Off = cycle through every breakable in the zone.", Callback = function(v)
        S.focusNearest = v
    end })
    sec:AddToggle({ Name = "Fast Breakables", Default = false, Tooltip = "Hits EVERY breakable in the zone each tick instead of one. Measured with pets off: 32x the packets for about 6x the damage. Loud - around 280 packets/s at 8/s with 35 targets, against 8. Use it knowing that.", Callback = function(v)
        S.fastBreak = v
    end })
    sec:AddToggle({ Name = "Prioritise Special Breakables", Default = false, Tooltip = "Hits chests, safes, vaults, diamonds, crates and presents before plain coin piles. Falls back to coins when there is no special left in the zone.", Callback = function(v)
        S.prioSpecial = v
    end })
    local ddTipos, ddIds
    local function normalizedSelection(v)
        local out = {}
        if type(v) ~= "table" then return out end
        for k, val in pairs(v) do
            if type(val) == "boolean" then
                if val then out[k] = true end
            elseif type(val) == "string" then
                out[val] = true
            end
        end
        return out
    end
    local function sweepZone()
        local ok, res = gameCall(function()
            local zoneName = currentZone()
            local typeSet, ids = {}, {}
            if G.Break and zoneName then
                for _, cl in ipairs(CLASSES) do
                    local okl, listing = pcall(G.Break.AllByZoneAndClass, zoneName, cl)
                    if okl and type(listing) == "table" then
                        for _, b in pairs(listing) do
                            typeSet[typeOf(b)] = true
                            ids[tostring(b.id)] = true
                        end
                    end
                end
            end
            local lt, li = {}, {}
            for k in pairs(typeSet) do lt[#lt + 1] = k end
            for k in pairs(ids)   do li[#li + 1] = k end
            table.sort(lt) ; table.sort(li)
            return { lt, li }
        end)
        if ok and type(res) == "table" then return res[1], res[2] end
        return {}, {}
    end
    local initialTypes, idsIniciais = sweepZone()
    ddTipos = sec:AddDropdown({ Name = "Priority Targets", Items = initialTypes, Multi = true, Default = nil, SearchThreshold = 6, Tooltip = "Only hit these breakable types. Leave empty to hit everything.", Callback = function(v)
        S.prioTipos = normalizedSelection(v)
    end })
    ddIds = sec:AddDropdown({ Name = "Priority Breakables", Items = idsIniciais, Multi = true, Default = nil, SearchThreshold = 6, Tooltip = "Narrower than the type filter: pick exact breakables. Leave empty to ignore.", Callback = function(v)
        S.prioIds = normalizedSelection(v)
    end })
    sec:AddButton({ Name = "Refresh Target Lists", Tooltip = "Re-reads what exists in the zone you are standing in. Run it after moving to a new zone.", Callback = uiCall(function()
        local t, i2 = sweepZone()
        if ddTipos and ddTipos.Refresh then pcall(function() ddTipos:Refresh(t) end) end
        if ddIds and ddIds.Refresh then pcall(function() ddIds:Refresh(i2) end) end
        notify("Farm", ("%d types - %d breakables in this zone"):format(#t, #i2), 4)
    end) })
    sec:AddToggle({ Name = "Send All Pets", Default = true, Tooltip = "Points every pet at whatever you are hitting, the same way clicking does. Only works while you stand inside the zone's break area.", Callback = function(v)
        S.sendPets = v
    end })
    sec:AddToggle({ Name = "Distribute All Pets", Default = false, Tooltip = "Spreads your pets across the nearest breakables instead of stacking them on one. Better on many weak targets, worse on a single fat one.", Callback = function(v)
        S.spreadPets = v
    end })
    sec:AddToggle({ Name = "Stay in Break Zone", Default = false, Tooltip = "Keeps you inside the dotted break area of your current zone, so your pets are allowed to attack. Only moves you when you actually leave the box.", Callback = function(v)
        S.stayInZone = v
        if not v then return end
        task.spawn(function()
            while alive() and S.stayInZone do
                if not S.bestBreakZone then
                    pcall(goToBreakArea, currentZone())
                end
                task.wait(2)
            end
        end)
    end })
    local dottedOriginal = nil
    sec:AddToggle({ Name = "Keep Pets Focused Outside Zone", Default = false, Tooltip = "Makes the client always answer 'you are inside the break area', so pets stop losing their target when you stand outside. Client-side only - if the server re-checks your position, use Stay in Break Zone instead.", Callback = function(v)
        if not G.Map then return end
        if v then
            if not dottedOriginal then
                dottedOriginal = G.Map.IsInDottedBox
                G.Map.IsInDottedBox = function() return true end
            end
        elseif dottedOriginal then
            G.Map.IsInDottedBox = dottedOriginal
            dottedOriginal = nil
        end
    end })
    if type(Library.OnUnload) == "function" then
        pcall(function()
            Library:OnUnload(function()
                if dottedOriginal and G.Map then
                    G.Map.IsInDottedBox = dottedOriginal
                    dottedOriginal = nil
                end
            end)
        end)
    end
    sec:AddToggle({ Name = "Go To Best Break Zone", Default = false, Tooltip = "Moves you to the break area of the highest zone you own - where the breakables are worth the most - and keeps you there. Overrides Stay in Break Zone while on.", Callback = function(v)
        S.bestBreakZone = v
        if not v then return end
        task.spawn(function()
            local warned = nil
            while alive() and S.bestBreakZone do
                local bestOne = nil
                if G.Zone and G.Zone.GetMaxOwnedZone then
                    local ok, label2 = pcall(G.Zone.GetMaxOwnedZone)
                    if ok and type(label2) == "string" then bestOne = label2 end
                end
                if bestOne then
                    if warned ~= bestOne then
                        notify("Farm", "Best break zone: " .. bestOne, 4)
                        warned = bestOne
                    end
                    pcall(goToBreakArea, bestOne)
                elseif not warned then
                    notify("Farm", "Could not read your highest owned zone", 5)
                    warned = "?"
                end
                task.wait(2)
            end
        end)
    end })
    local petSpeedOriginal = nil
    local function applyPetSpeed()
        if not G.PlayerPet then return end
        if S.petSpeedOn then
            petSpeedOriginal = petSpeedOriginal or G.PlayerPet.CalculateSpeedMultiplier
            G.PlayerPet.CalculateSpeedMultiplier = function() return S.petSpeed end
        elseif petSpeedOriginal then
            G.PlayerPet.CalculateSpeedMultiplier = petSpeedOriginal
            petSpeedOriginal = nil
        end
    end
    sec = Sub.FarmBreak:AddSection({ Name = "Pet Movement", Side = 2, Icon = "rabbit" })
    if not G.PlayerPet then
        sec:AddLabel({ Name = "PlayerPet not found in this build - pet speed disabled." })
    else
        sec:AddToggle({ Name = "Override Pet Speed", Default = false, Tooltip = "Replaces the game's own speed calculation for your pets. Turning it off restores the original function exactly.", Callback = function(v)
            S.petSpeedOn = v
            applyPetSpeed()
        end })
        sec:AddSlider({ Name = "Pet Speed", Default = 1, Min = 1, Max = 10, Decimals = 0.1, Suffix = "x", Tooltip = "1x is normal. The game's own buffs reach about 3x-4x, so past that you are outside anything it produces on its own.", Callback = function(v)
            S.petSpeed = v
            applyPetSpeed()
        end })
        if type(Library.OnUnload) == "function" then
            pcall(function()
                Library:OnUnload(function()
                    if petSpeedOriginal then
                        pcall(function() G.PlayerPet.CalculateSpeedMultiplier = petSpeedOriginal end)
                        petSpeedOriginal = nil
                    end
                end)
            end)
        end
    end
end
do
    local sec = Sub.FarmZones:AddSection({ Name = "Zones", Side = 1, Icon = "map" })
    local Balancing = G.want(ReplicatedStorage:FindFirstChild("Library"), "Balancing")
    local DirZones  = G.want(ReplicatedStorage.Library:FindFirstChild("Directory"), "Zones")
    local FFlags    = G.want(G.Client, "FFlags")
    local function nextZonePrice()
        if not (G.Zone and DirZones and Balancing) then return nil end
        local okn, nextName = pcall(G.Zone.GetNextZone)
        if not okn or type(nextName) ~= "string" then return nil end
        local d = DirZones[nextName]
        if not d then return nil end
        local okp, preco = pcall(Balancing.CalcGatePrice, d)
        if not okp then return nextName, nil, d.Currency end
        return nextName, preco, d.Currency
    end
    local function buyNextZone()
        if not G.Zone then return false, "ZoneCmds unavailable" end
        local nextName, preco, currency = nextZonePrice()
        if not nextName then return false, "no next zone" end
        if not preco then return false, "no price for " .. nextName end
        if FFlags then
            local okf, ligado = pcall(function() return FFlags.Get(FFlags.Keys.ZoneUnlocking) end)
            if okf and ligado == false then return false, "zone unlocking is disabled server-side" end
        end
        if G.Money then
            local oka, canDo = pcall(G.Money.CanAfford, currency, preco)
            if oka and canDo ~= true then
                return false, ("%s costs %s %s"):format(nextName, tostring(preco), tostring(currency))
            end
        end
        local ok = invokeOk("Zones_RequestPurchase", nextName)
        return ok, ok and ("bought " .. nextName) or ("purchase failed for " .. nextName)
    end
    local zoneInfo = sec:AddLabel({ Name = "Next: -" })
    sec:AddToggle({ Name = "Auto Buy Zone", Default = false, Tooltip = "Checks once a second and buys the next zone the moment the game says you can afford it.", Callback = function(state)
        S.autoBuyZone = state
        if not state then return end
        task.spawn(function()
            while alive() and S.autoBuyZone do
                local ok, msg = buyNextZone()
                if ok then notify("Zones", tostring(msg), 4) end
                task.wait(1)
            end
        end)
    end })
    sec:AddToggle({ Name = "Always Teleport To Best Arena", Default = false, Tooltip = "Keeps you in the highest zone you own, and moves you the moment a new one unlocks. Only fires when you are actually somewhere else.", Callback = function(state)
        S.bestArena = state
        if not state then return end
        task.spawn(function()
            while alive() and S.bestArena do
                local ok, d = gameCall(function()
                    if not (G.Zone and G.ZonesUtil) then return nil end
                    local okz, bestOne = pcall(G.Zone.GetMaxOwnedZone)
                    if not okz or type(bestOne) ~= "string" then return nil end
                    local atual
                    if G.Map then
                        local okm, z = pcall(G.Map.GetCurrentZone)
                        if okm and type(z) == "string" then atual = z end
                    end
                    local okc, cf = pcall(G.ZonesUtil.GetTeleportPartLocation, bestOne)
                    return { bestOne = bestOne, atual = atual, cf = okc and cf or nil }
                end)
                if ok and type(d) == "table" and d.cf and d.atual ~= d.melhor then
                    tpTo(d.cf + Vector3.new(0, 4, 0))
                    notify("Zones", "Moved to " .. tostring(d.melhor), 3)
                end
                task.wait(3)
            end
        end)
    end })
    task.spawn(function()
        while alive() do
            local ok, d = gameCall(function()
                if not G.Zone then return nil end
                local _, owned = pcall(G.Zone.GetMaxOwnedZone)
                local nextName, preco, currency = nextZonePrice()
                local canDo
                if G.Money and preco then
                    local oka, v = pcall(G.Money.CanAfford, currency, preco)
                    canDo = oka and v == true
                end
                return { nextName = nextName, owned = owned, preco = preco, currency = currency, canDo = canDo }
            end)
            if ok and type(d) == "table" then
                pcall(function()
                    zoneInfo:SetText(("Owned up to: %s\nNext: %s\nPrice: %s %s%s"):format(
                        tostring(d.dono), tostring(d.prox),
                        tostring(d.preco or "?"), tostring(d.moeda or ""),
                        d.pode and "  (affordable)" or ""))
                end)
            end
            task.wait(2)
        end
    end)
end
do
    local sec = Sub.FarmOrbs:AddSection({ Name = "Orb Magnet", Side = 1, Icon = "magnet" })
    if not G.Orb then
        sec:AddLabel({ Name = "OrbCmds.Orb not found in this build - magnet disabled." })
    else
        _dzEnv.DzPS99_OrbBase = _dzEnv.DzPS99_OrbBase or {
            pickup  = G.Orb.DefaultPickupDistance,
            collect = G.Orb.CollectDistance,
        }
        local BASE = _dzEnv.DzPS99_OrbBase
        local function applyIt()
            pcall(function()
                G.Orb.DefaultPickupDistance = S.orbMagnet and S.orbRange or BASE.pickup
                G.Orb.CollectDistance = S.orbInstant and 100000 or BASE.collect
            end)
        end
        sec:AddToggle({ Name = "Orb Magnet", Default = false, Tooltip = "Widens the pickup radius the game already uses, so orbs fly to you from across the zone. Coins from breaking are credited anyway - this is for what drops on the floor.", Callback = function(v)
            S.orbMagnet = v
            applyIt()
        end })
        sec:AddSlider({ Name = "Magnet Range", Default = 1500, Min = 50, Max = 5000, Rounding = 0, Suffix = " studs", Callback = function(v)
            S.orbRange = v
            applyIt()
        end })
        sec:AddToggle({ Name = "Instant Orbs", Default = false, Tooltip = "Collects the orb where it lands instead of making it fly to you. Same path the game uses for the Super Magnet enchant. Each orb still waits out its own spawn delay first - chests use 2.5s.", Callback = function(v)
            S.orbInstant = v
            applyIt()
        end })
        sec:AddLabel({ Name = ("Game defaults: pickup %s - collect %s"):format(
            tostring(BASE.pickup), tostring(BASE.collect)) })
        if type(Library.OnUnload) == "function" then
            pcall(function()
                Library:OnUnload(function()
                    pcall(function()
                        G.Orb.DefaultPickupDistance = BASE.pickup
                        G.Orb.CollectDistance = BASE.collect
                    end)
                end)
            end)
        end
    end
end
do
    local sec = Sub.EggsHatch:AddSection({ Name = "Hatch", Side = 1, Icon = "egg" })
    local DirEggs = G.want(ReplicatedStorage.Library:FindFirstChild("Directory"), "Eggs")
    local eggsPorNome, eggNames = {}, {}
    local function refreshEggs()
        local ok, res = gameCall(function()
            local byName2, nomes = {}, {}
            if not DirEggs then return { byName2, nomes } end
            local d = save()
            local ceilingVal  = (d and tonumber(d.MaximumAvailableEgg)) or 1
            local worldNo = (d and tonumber(d.RecentWorld)) or 1
            for label2, info in pairs(DirEggs) do
                if type(info) == "table" and info._id then
                    local n = tonumber(info.eggNumber)
                    local w = tonumber(info.worldNumber)
                    local unlockedUpTo
                    if n and w then
                        unlockedUpTo = (w == worldNo) and (n <= ceilingVal)
                    elseif G.Eggs and type(G.Eggs.IsUnlocked) == "function" then
                        local oku, v = pcall(G.Eggs.IsUnlocked, info._id)
                        unlockedUpTo = oku and v == true
                    end
                    if unlockedUpTo then
                        byName2[label2] = info._id
                        nomes[#nomes + 1] = label2
                    end
                end
            end
            table.sort(nomes)
            return { byName2, nomes }
        end)
        if ok and type(res) == "table" then
            eggsPorNome, eggNames = res[1], res[2]
        else
            eggsPorNome, eggNames = {}, {}
        end
    end
    refreshEggs()
    local eggDropdown
    eggDropdown = sec:AddDropdown({ Name = "Egg", Items = eggNames, Default = nil, Multi = false, Callback = function(v)
        S.hatchEggId = v and eggsPorNome[v] or nil
    end })
    sec:AddButton({ Name = "Refresh Egg List", Callback = uiCall(function()
        refreshEggs()
        if eggDropdown and eggDropdown.Refresh then eggDropdown:Refresh(eggNames) end
        notify("Eggs", ("%d eggs available"):format(#eggNames), 3)
    end) })
    local SLIDER_CEILING = 60
    local function currentCeiling()
        if not G.Eggs then return 1 end
        local ok, v = pcall(G.Eggs.GetMaxHatch)
        if ok and tonumber(v) then return math.max(1, math.floor(v)) end
        return 1
    end
    sec:AddSlider({ Name = "Egg Amount", Default = 1, Min = 1, Max = SLIDER_CEILING, Suffix = "x", Tooltip = "Clamped to what the game currently allows (bought egg slots + gamepass + mastery perk). The live cap is shown under Info.", Callback = function(v)
        S.hatchAmount = v
    end })
    sec:AddToggle({ Name = "Use Maximum Eggs", Default = false, Tooltip = "Ignores the slider and always hatches at the live cap the game reports. Follows you automatically when you buy more egg slots.", Callback = function(v)
        S.useMaxEggs = v
    end })
    local potatoOriginal, instantOriginal = nil, nil
    local instantStored = false
    local function clearStuckPrompt()
        for _, raiz in ipairs({ game:GetService("CoreGui"), LocalPlayer:FindFirstChild("PlayerGui") }) do
            if raiz then
                for _, g in ipairs(raiz:GetDescendants()) do
                    if g.Name == "TapToOpen" then pcall(function() g:Destroy() end) end
                end
            end
        end
    end
    local animOriginal, animEnv = nil, nil
    local function killPlayEggAnimation(ligar)
        if type(getsenv) ~= "function" then return end
        pcall(function()
            if ligar then
                if animOriginal then return end
                local ps = LocalPlayer:FindFirstChild("PlayerScripts")
                local sc = ps and ps:FindFirstChild("Scripts")
                local gameEnv = sc and sc:FindFirstChild("Game")
                local frontend = gameEnv and gameEnv:FindFirstChild("Egg Opening Frontend")
                if not frontend then return end
                local env = getsenv(frontend)
                if type(env) ~= "table" or type(env.PlayEggAnimation) ~= "function" then return end
                animEnv, animOriginal = env, env.PlayEggAnimation
                env.PlayEggAnimation = function() end
            elseif animOriginal and animEnv then
                animEnv.PlayEggAnimation = animOriginal
                animOriginal, animEnv = nil, nil
            end
        end)
    end
    local function skipEggAnimation(ligar)
        killPlayEggAnimation(ligar)
        if G.Settings then
            if ligar and not potatoOriginal then
                potatoOriginal = G.Settings.Get
                G.Settings.Get = function(label2, ...)
                    if label2 == "EggPotatoMode" then return "On" end
                    return potatoOriginal(label2, ...)
                end
            elseif not ligar and potatoOriginal then
                G.Settings.Get = potatoOriginal
                potatoOriginal = nil
            end
        end
        pcall(function()
            if ligar then
                if not instantStored then
                    instantOriginal = workspace:GetAttribute("GlobalInstantHatch")
                    instantStored = true
                end
                workspace:SetAttribute("GlobalInstantHatch", true)
            elseif instantStored then
                workspace:SetAttribute("GlobalInstantHatch", instantOriginal)
                instantStored = false
            end
        end)
        if ligar then clearStuckPrompt() end
    end
    sec:AddToggle({ Name = "Disable Egg Open Animations", Default = false, Tooltip = "Skips the hatch screen AND the 'Click to open!' prompt that stalls auto hatch. Local only - touches no account setting and sends nothing. Also clears a prompt left stuck on screen.", Callback = function(v)
        skipEggAnimation(v)
    end })
    if type(Library.OnUnload) == "function" then
        pcall(function()
            Library:OnUnload(function()
                if potatoOriginal then
                    pcall(function() G.Settings.Get = potatoOriginal end)
                    potatoOriginal = nil
                end
                if instantStored then
                    pcall(function() workspace:SetAttribute("GlobalInstantHatch", instantOriginal) end)
                    instantStored = false
                end
                killPlayEggAnimation(false)
                clearStuckPrompt()
            end)
        end)
    end
    local function hatchOnce()
        if not (G.Eggs and S.hatchEggId) then return false, "no egg selected" end
        local ceilingVal = currentCeiling()
        local qty = S.useMaxEggs and ceilingVal or math.clamp(math.floor(S.hatchAmount or 1), 1, ceilingVal)
        local ok, r1, r2 = pcall(G.Eggs.RequestPurchase, S.hatchEggId, qty)
        if not ok then return false, tostring(r1) end
        if r1 == false then return false, tostring(r2 or "refused") end
        return true, "ok"
    end
    sec:AddToggle({ Name = "Auto Hatch", Default = false, Tooltip = "Buys the selected egg on a loop. Stops on its own when the game starts refusing (out of coins).", Callback = function(state)
        S.autoHatch = state
        if not state then return end
        task.spawn(function()
            local refusals = 0
            while alive() and S.autoHatch do
                local ok, msg = hatchOnce()
                if ok then
                    refusals = 0
                else
                    refusals = refusals + 1
                    if refusals >= 3 then
                        S.autoHatch = false
                        notify("Eggs", "Auto Hatch stopped: " .. tostring(msg), 6)
                        break
                    end
                end
                task.wait(ok and 0.2 or 1.5)
            end
        end)
    end })
    local function nearestCapsule()
        local hrp = getHRP()
        local coisas = workspace:FindFirstChild("__THINGS")
        local folderRef = coisas and coisas:FindFirstChild("Eggs")
        if not (hrp and folderRef) then return nil, "egg room not loaded" end
        local d = save()
        local worldNo = (d and tonumber(d.RecentWorld)) or 1
        local ceilingVal  = (d and tonumber(d.MaximumAvailableEgg)) or 1
        local byNumber = {}
        for _, e in pairs(DirEggs or {}) do
            if type(e) == "table" and e._id
                and tonumber(e.worldNumber) == worldNo and tonumber(e.eggNumber) then
                byNumber[tonumber(e.eggNumber)] = e
            end
        end
        local bestId, melhorNum, melhorDist, melhorCF
        for _, m in ipairs(folderRef:GetDescendants()) do
            local n = tonumber(tostring(m.Name):match("^(%d+)%s*%-%s*Egg Capsule"))
            local e = n and byNumber[n]
            if e and (tonumber(e.eggNumber) or math.huge) <= ceilingVal then
                local okp, piv = pcall(m.GetPivot, m)
                if okp then
                    local dist = (piv.Position - hrp.Position).Magnitude
                    if not melhorDist or dist < melhorDist then
                        melhorDist, bestId, melhorNum, melhorCF = dist, e._id, n, piv
                    end
                end
            end
        end
        if not bestId then return nil, "no unlocked egg capsule nearby" end
        return bestId, melhorNum, melhorDist, melhorCF
    end
    local DirZonesEgg = G.want(ReplicatedStorage.Library:FindFirstChild("Directory"), "Zones")
    local function currentZoneEgg()
        if not (G.Map and DirEggs and DirZonesEgg) then return nil, "modules unavailable" end
        local okz, zoneName = pcall(G.Map.GetCurrentZone)
        if not okz or type(zoneName) ~= "string" then return nil, "unknown zone" end
        local dz = DirZonesEgg[zoneName]
        local zn = dz and tonumber(dz.ZoneNumber)
        if not zn then return nil, "no zone number for " .. zoneName end
        local d = save()
        local worldNo = (d and tonumber(d.RecentWorld)) or 1
        local ceilingVal  = (d and tonumber(d.MaximumAvailableEgg)) or 1
        for _, e in pairs(DirEggs) do
            if type(e) == "table" and e._id
                and tonumber(e.worldNumber) == worldNo
                and tonumber(e.zoneNumber) == zn then
                if (tonumber(e.eggNumber) or math.huge) > ceilingVal then
                    return nil, e._id .. " is still locked"
                end
                return e._id, zoneName
            end
        end
        return nil, "no egg in " .. zoneName
    end
    local CAPSULE_RADIUS = 40
    local function targetEgg()
        local capsuleId, numCap, distCap = nearestCapsule()
        if capsuleId and distCap and distCap <= CAPSULE_RADIUS then
            return capsuleId, ("capsule #%d, %d studs"):format(numCap, math.floor(distCap))
        end
        local zoneKey, zoneName = currentZoneEgg()
        if zoneKey then return zoneKey, "zone " .. tostring(zoneName) end
        return nil, tostring(zoneName or numCap or "no egg here")
    end
    sec:AddToggle({ Name = "Auto Hatch Nearest", Default = false, Tooltip = "Hatches whatever egg is next to you. Inside the capsule room it follows the row; anywhere else it hatches the egg of the area you are standing in, so you never have to walk back to Spawn.", Callback = function(state)
        S.autoHatchNear = state
        if not state then return end
        task.spawn(function()
            local lastWarning, refusals = nil, 0
            while alive() and S.autoHatchNear do
                local id, originPos = targetEgg()
                if not id then
                    if originPos ~= lastWarning then
                        lastWarning = originPos
                        notify("Eggs", "Nearest: " .. tostring(originPos), 4)
                    end
                    task.wait(2)
                else
                    if id ~= lastWarning then
                        lastWarning = id
                        notify("Eggs", ("Nearest egg: %s (%s)"):format(id, tostring(originPos)), 3)
                    end
                    local ceilingVal = currentCeiling()
                    local qty = S.useMaxEggs and ceilingVal
                        or math.clamp(math.floor(S.hatchAmount or 1), 1, ceilingVal)
                    local ok, r1, r2 = pcall(G.Eggs.RequestPurchase, id, qty)
                    local didAccept = ok and r1 ~= false
                    if didAccept then
                        refusals = 0
                        task.wait(0.2)
                    else
                        local msg = tostring((not ok) and r1 or r2 or "refused")
                        refusals = refusals + 1
                        if refusals >= 3 then
                            S.autoHatchNear = false
                            notify("Eggs", "Auto Hatch Nearest stopped: " .. msg, 6)
                            break
                        end
                        task.wait(1.5)
                    end
                end
            end
        end)
    end })
    sec = Sub.EggsHatch:AddSection({ Name = "Custom Eggs", Side = 2, Icon = "sparkles" })
    if not G.CustomEg then
        sec:AddLabel({ Name = "CustomEggsCmds not found in this build." })
    else
        local ceByName, ceNames = {}, {}
        local function refreshCustom()
            local ok, res = gameCall(function()
                local byName2, nomes = {}, {}
                local oka, everyOne = pcall(G.CustomEg.All)
                if oka and type(everyOne) == "table" then
                    for _, e in pairs(everyOne) do
                        if type(e) == "table" and e._uid then
                            local labelText = ("%s [%s]"):format(
                                tostring(e._id or "?"), tostring(e._uid):sub(1, 6))
                            byName2[labelText] = e._uid
                            nomes[#nomes + 1] = labelText
                        end
                    end
                end
                table.sort(nomes)
                return { byName2, nomes }
            end)
            if ok and type(res) == "table" then
                ceByName, ceNames = res[1], res[2]
            else
                ceByName, ceNames = {}, {}
            end
        end
        refreshCustom()
        local ceDropdown
        ceDropdown = sec:AddDropdown({ Name = "Select Custom Egg", Items = ceNames, Default = nil, Multi = false, Callback = function(v)
            S.ceUid = v and ceByName[v] or nil
        end })
        sec:AddButton({ Name = "Refresh Custom Eggs", Callback = uiCall(function()
            refreshCustom()
            if ceDropdown and ceDropdown.Refresh then ceDropdown:Refresh(ceNames) end
            notify("Eggs", ("%d custom eggs found"):format(#ceNames), 3)
        end) })
        sec:AddSlider({ Name = "Custom Egg Amount", Default = 1, Min = 1, Max = SLIDER_CEILING, Suffix = "x", Callback = function(v)
            S.ceAmount = v
        end })
        sec:AddToggle({ Name = "Use Maximum Eggs (custom)", Default = false, Tooltip = "Same as the one above, applied to the custom egg loop.", Callback = function(v)
            S.ceUseMax = v
        end })
        local function hatchCustom()
            if not S.ceUid then return false, "no custom egg selected" end
            local ceilingVal = currentCeiling()
            local qty = S.ceUseMax and ceilingVal or math.clamp(math.floor(S.ceAmount or 1), 1, ceilingVal)
            local wasCalled, r1, r2 = invoke("CustomEggs_Hatch", S.ceUid, qty)
            if not wasCalled then return false, tostring(r2 or "call failed") end
            if r1 == false then return false, tostring(r2 or "refused") end
            return true, "ok"
        end
        sec:AddToggle({ Name = "Auto Open Custom Eggs", Default = false, Tooltip = "Loops the selected custom egg. Stops on its own after three refusals - usually you are out of currency or too far from the egg.", Callback = function(state)
            S.autoHatchCE = state
            if not state then return end
            task.spawn(function()
                local refusals = 0
                while alive() and S.autoHatchCE do
                    local ok, msg = hatchCustom()
                    if ok then
                        refusals = 0
                    else
                        refusals = refusals + 1
                        if refusals >= 3 then
                            S.autoHatchCE = false
                            notify("Eggs", "Auto Open Custom Eggs stopped: " .. tostring(msg), 6)
                            break
                        end
                    end
                    task.wait(ok and 0.6 or 1.5)
                end
            end)
        end })
    end
    sec = Sub.EggsHatch:AddSection({ Name = "Info", Side = 2, Icon = "info" })
    local eggInfo = sec:AddLabel({ Name = "-" })
    task.spawn(function()
        while alive() do
            local ok, info = gameCall(function()
                local d = save()
                local pets = 0
                if d and d.Inventory and d.Inventory.Pet then
                    for _ in pairs(d.Inventory.Pet) do pets = pets + 1 end
                end
                local ceilingVal = currentCeiling()
                return ("Eggs hatched: %s\nPets owned: %d\nMax egg unlocked: %s\nHatch cap: %dx  (slider is clamped to this)"):format(
                    tostring(d and d.EggsHatched or "-"), pets,
                    tostring(d and d.MaximumAvailableEgg or "-"), ceilingVal)
            end)
            if ok and type(info) == "string" then
                pcall(function()
                    eggInfo:SetText(info)
                end)
            end
            task.wait(2)
        end
    end)
end
do
    local sec = Sub.EggsHatch:AddSection({ Name = "Webhook", Side = 1, Icon = "bell" })
    local HttpService = game:GetService("HttpService")
    local DirRoot = ReplicatedStorage.Library:FindFirstChild("Directory")
    local DirPets = G.want(DirRoot, "Pets")
    local W = {
        url        = "",
        ligado     = false,
        categorias = {},
        fila       = {},
    }
    local function httpPost(url, payload)
        local req = (type(request) == "function" and request)
                 or (type(http_request) == "function" and http_request)
                 or (syn and type(syn.request) == "function" and syn.request)
        if not req then return false, "executor has no HTTP request function" end
        local ok, res = pcall(req, {
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload,
        })
        if not ok then return false, tostring(res) end
        local status = tonumber(res and (res.StatusCode or res.Status)) or 0
        return status >= 200 and status < 300, "HTTP " .. tostring(status)
    end
    local CATEGORY_COLOR = {
        Huge       = 0x3BA3FF,
        Titanic    = 0xB45CFF,
        Gargantuan = 0xFFB020,
    }
    local CATEGORIES = { "Huge", "Titanic", "Gargantuan" }
    local function categoryOf(petId)
        local pd = DirPets and DirPets[petId]
        local label2 = tostring((pd and pd.name) or petId or "")
        for _, cat in ipairs(CATEGORIES) do
            if label2:sub(1, #cat + 1) == cat .. " " then return cat end
        end
        return nil
    end
    local function passesFilter(petId)
        local cat = categoryOf(petId)
        if not cat then return false end
        if not next(W.categorias) then return true end
        return W.categorias[cat] == true
    end
    local SEND_SPACING = 1.1
    local imageCache = {}
    local function imageUrl(petId)
        if imageCache[petId] ~= nil then return imageCache[petId] or nil end
        local pd = DirPets and DirPets[petId]
        local asset = pd and tostring(pd.thumbnail or ""):match("(%d+)")
        if not asset then imageCache[petId] = false return nil end
        local req = (type(request) == "function" and request)
                 or (type(http_request) == "function" and http_request)
                 or (syn and type(syn.request) == "function" and syn.request)
        if not req then imageCache[petId] = false return nil end
        local url = ("https://thumbnails.roblox.com/v1/assets?assetIds=%s&size=420x420&format=Png&isCircular=false"):format(asset)
        local ok, res = pcall(req, { Url = url, Method = "GET" })
        local payload = ok and res and tostring(res.Body or "") or ""
        local img = payload:match('"imageUrl"%s*:%s*"([^"]+)"')
        if img then img = img:gsub("\\/", "/") end
        imageCache[petId] = img or false
        return img
    end
    local function powerOf(pd)
        if not pd then return nil end
        local p = tonumber(pd.power)
        if p then return p end
        if type(pd.cachedPower) == "table" then
            return tonumber(pd.cachedPower[1])
        end
        return nil
    end
    local function shortNumber(n)
        local unitCount = { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }
        for _, u in ipairs(unitCount) do
            if n >= u[1] then
                return ("%.2f%s"):format(n / u[1], u[2])
            end
        end
        return tostring(math.floor(n))
    end
    local function sendPet(pet, categoria, cor, ovo)
        local pd = DirPets and DirPets[pet]
        local campos = {}
        local poder = powerOf(pd)
        if poder then
            campos[#campos + 1] = { name = "Power", value = shortNumber(poder), inline = true }
        end
        local deOvo = ovo or (pd and pd.fromEgg)
        if deOvo then
            campos[#campos + 1] = { name = "Egg", value = tostring(deOvo), inline = true }
        end
        local embed = {
            author = { name = "Pet Simulator 99" },
            title = tostring(pet),
            description = "**" .. tostring(categoria) .. "**",
            color = cor,
            fields = campos,
            footer = { text = "Tempo - " .. os.date("%H:%M:%S") },
        }
        local img = imageUrl(pet)
        if img then embed.thumbnail = { url = img } end
        local payload = HttpService:JSONEncode({
            username = "Tempo",
            embeds = { embed },
        })
        local ok, msg = httpPost(W.url, payload)
        if not ok then
            notify("Webhook", "Failed: " .. tostring(msg), 6)
            W.ligado = false
        end
        return ok
    end
    task.spawn(function()
        while alive() do
            if W.ligado and W.url ~= "" and #W.fila > 0 then
                local p = table.remove(W.fila, 1)
                pcall(sendPet, p.pet, p.categoria, p.cor, p.ovo)
                task.wait(SEND_SPACING)
            else
                task.wait(0.5)
            end
        end
    end)
    sec:AddTextbox({ Name = "Webhook URL", Placeholder = "https://discord.com/api/webhooks/...", Finished = true, Callback = function(v)
        W.url = tostring(v or ""):gsub("%s", "")
    end })
    sec:AddDropdown({ Name = "Notify Categories", Items = CATEGORIES, Multi = true,
        Default = { "Huge", "Titanic", "Gargantuan" },
        Tooltip = "Only these get a message. Rarity is useless for this in PS99 - 1384 of the 1422 big pets are all 'Exclusive', so it separates nothing.",
        Callback = function(v)
            local out = {}
            if type(v) == "table" then
                for k, val in pairs(v) do
                    if type(val) == "boolean" then
                        if val then out[k] = true end
                    elseif type(val) == "string" then
                        out[val] = true
                    end
                end
            elseif type(v) == "string" then
                out[v] = true
            end
            W.categorias = out
        end })
    sec:AddToggle({ Name = "Hatch Notifications", Default = false, Tooltip = "Posts a Discord message when you hatch something worth it. Batches every few seconds - one message per pet would hit Discord's rate limit in seconds of auto hatch.", Callback = function(v)
        if v and W.url == "" then
            notify("Webhook", "Set the webhook URL first", 5)
            W.ligado = false
            return
        end
        W.ligado = v
    end })
    sec:AddButton({ Name = "Send Test Message", Callback = uiCall(function()
        if W.url == "" then notify("Webhook", "Set the webhook URL first", 4) return end
        local payload = HttpService:JSONEncode({
            username = "Tempo",
            content = "Test from Tempo - Pet Simulator 99 - " .. os.date("%H:%M:%S"),
        })
        local ok, msg = httpPost(W.url, payload)
        notify("Webhook", ok and "Test sent" or ("Failed: " .. tostring(msg)), 6)
    end) })
    if Net then
        pcall(function()
            local signalRef = Net.Fired("Eggs_PlayOpenAnimation")
            bind(signalRef, function(eggId, pets)
                if not (W.ligado and W.url ~= "") then return end
                if type(pets) ~= "table" then return end
                for _, dados in pairs(pets) do
                    local id = type(dados) == "table" and dados.id
                    if id and passesFilter(id) then
                        local cat = categoryOf(id)
                        W.fila[#W.fila + 1] = {
                            pet = tostring(id),
                            categoria = cat,
                            cor = CATEGORY_COLOR[cat] or 5814783,
                            ovo = type(eggId) == "string" and eggId or nil,
                        }
                    end
                end
            end)
        end)
    end
end
do
    local sec = Sub.PetsManage:AddSection({ Name = "Equip", Side = 1, Icon = "paw-print" })
    if not G.Pets then
        sec:AddLabel({ Name = "PetCmds not found in this build - pet actions disabled." })
    else
        sec:AddButton({ Name = "Equip Best", Callback = uiCall(function()
            local ok = pcall(G.Pets.EquipBest)
            notify("Pets", ok and "Equipped best pets" or "Failed", 3)
        end) })
        sec:AddButton({ Name = "Unequip All", Callback = uiCall(function()
            pcall(G.Pets.UnequipAll)
        end) })
        sec:AddButton({ Name = "Restore Loadout", Callback = uiCall(function()
            pcall(G.Pets.Restore)
        end) })
        sec:AddButton({ Name = "Respawn Pets", Tooltip = "Unequips and re-equips - fixes pets that stopped attacking.", Callback = uiCall(function()
            pcall(G.Pets.Respawn)
        end) })
        sec:AddToggle({ Name = "Auto Equip Best", Default = false, Tooltip = "Re-runs Equip Best every few seconds, so a pet hatched just now goes in without you opening the inventory.", Callback = function(state)
            S.autoEquipBest = state
            if not state then return end
            task.spawn(function()
                while alive() and S.autoEquipBest do
                    pcall(G.Pets.EquipBest)
                    task.wait(5)
                end
            end)
        end })
        sec = Sub.PetsManage:AddSection({ Name = "Settings", Side = 2, Icon = "settings" })
        sec:AddButton({ Name = "Toggle Auto Equip (game setting)", Tooltip = "Flips the game's own auto-equip option, the same one in the pet inventory.", Callback = uiCall(function()
            pcall(G.Pets.ToggleAutoEquip)
        end) })
        sec:AddButton({ Name = "Toggle Favorite Mode", Callback = uiCall(function()
            pcall(G.Pets.ToggleFavoriteMode)
        end) })
        local petInfo = sec:AddLabel({ Name = "-" })
        task.spawn(function()
            while alive() do
                local ok, texto = gameCall(function()
                    local oke, eq = pcall(G.Pets.GetEquipped)
                    local n = 0
                    if oke and type(eq) == "table" then for _ in pairs(eq) do n = n + 1 end end
                    local _, mx = pcall(G.Pets.GetMaxEquipped)
                    local _, auto = pcall(G.Pets.IsAutoEquipEnabled)
                    return ("Equipped: %d / %s\nAuto equip: %s"):format(
                        n, tostring(mx), auto == true and "on" or "off")
                end)
                if ok and type(texto) == "string" then
                    pcall(function() petInfo:SetText(texto) end)
                end
                task.wait(2)
            end
        end)
    end
end
do
    local sec = Sub.ColClaims:AddSection({ Name = "Claims", Side = 1, Icon = "gift" })
    local Dir = G.Dir
    local Fn  = G.Functions
    local function loopBody(estado, interval, passo)
        task.spawn(function()
            while alive() and estado() do
                pcall(passo)
                for _ = 1, interval do
                    if not (alive() and estado()) then break end
                    task.wait(1)
                end
            end
        end)
    end
    local function freeGiftsList()
        if not (Dir and Dir.FreeGifts) then return {} end
        local listing = {}
        for _, g in pairs(Dir.FreeGifts) do listing[g.Id] = g end
        return listing
    end
    local function freeGiftsPending()
        local d = save()
        if not d then return {} end
        local takenList = d.FreeGiftsRedeemed or {}
        local elapsed = tonumber(d.FreeGiftsTime) or 0
        local out = {}
        for i, g in ipairs(freeGiftsList()) do
            local alreadyTaken = Fn and Fn.SearchArray(takenList, i) or table.find(takenList, i)
            if not alreadyTaken and elapsed >= (g.WaitTime or math.huge) then
                out[#out + 1] = i
            end
        end
        return out
    end
    local function claimFreeGifts()
        local pend = freeGiftsPending()
        local n = 0
        for _, id in ipairs(pend) do
            if invokeOk("Redeem Free Gift", id) then n = n + 1 end
            task.wait(0.35)
        end
        return n, #pend
    end
    local S_gifts = false
    sec:AddToggle({ Name = "Auto Claim Free Gifts", Default = false, Tooltip = "Claims each free gift the moment its timer runs out. Checks once a minute - the game only releases one every 10 minutes at best, so nothing is missed.", Callback = function(v)
        S_gifts = v
        if not v then return end
        loopBody(function() return S_gifts end, 60, function()
            local n = claimFreeGifts()
            if n > 0 then notify("Collect", ("Free gifts: %d claimed"):format(n), 4) end
        end)
    end })
    local function claimLogin()
        if G.LoginStk then
            local ok, canDo = pcall(G.LoginStk.CanClaim)
            if ok and not canDo then return false, "already claimed today" end
        end
        local accepted = invokeOk("Login Streaks: Claim")
        return accepted, accepted and "claimed" or "refused by server"
    end
    local S_login = false
    sec:AddToggle({ Name = "Auto Claim Login Streak", Default = false, Tooltip = "Waits for the daily reset and claims the streak by itself. CanClaim() is a local read, so while the day is already claimed this sends nothing.", Callback = function(v)
        S_login = v
        if not v then return end
        loopBody(function() return S_login end, 60, function()
            local ok = claimLogin()
            if ok then notify("Collect", "Login streak claimed", 4) end
        end)
    end })
    local function ranksPending()
        local d = save()
        if not (d and Dir and G.RanksUtil) then return {}, nil end
        local ok, rid = pcall(G.RanksUtil.RankIDFromNumber, d.Rank)
        if not ok or not rid then return {}, nil end
        local rank = Dir.Ranks and Dir.Ranks[rid]
        if not (rank and rank.Rewards) then return {}, rid end
        local takenList = d.RedeemedRankRewards or {}
        local stars = tonumber(d.RankStars) or 0
        local acum, out = 0, {}
        for idx, rw in ipairs(rank.Rewards) do
            acum = acum + (rw.StarsRequired or 0)
            if acum <= stars and takenList[tostring(idx)] == nil then
                out[#out + 1] = idx
            end
        end
        return out, rid
    end
    local function claimRanks()
        local pend = ranksPending()
        if #pend == 0 then return 0, 0 end
        for _, idx in ipairs(pend) do
            fire("Ranks_ClaimReward", idx)
            task.wait(0.25)
        end
        task.wait(0.8)
        local d = save()
        local takenList = (d and d.RedeemedRankRewards) or {}
        local n = 0
        for _, idx in ipairs(pend) do
            if takenList[tostring(idx)] ~= nil then n = n + 1 end
        end
        return n, #pend
    end
    local S_ranks = false
    sec:AddToggle({ Name = "Auto Claim Rank Rewards", Default = false, Tooltip = "Claims every reward of your current rank that your stars already paid for. Runs every 30s because quest stars can land at any moment.", Callback = function(v)
        S_ranks = v
        if not v then return end
        loopBody(function() return S_ranks end, 30, function()
            local n = claimRanks()
            if n > 0 then notify("Collect", ("Rank rewards: %d claimed"):format(n), 4) end
        end)
    end })
    local TP_WAIT_MACHINE = 2
    local function machineOf(chave)
        local r = Dir and Dir.TimedRewards and Dir.TimedRewards[chave]
        if not (r and G.Machines) then return nil end
        local ok, modelos = pcall(G.Machines.GetModels, r.MachineName)
        if not (ok and modelos) then return nil end
        for _, m in pairs(modelos) do
            if typeof(m) == "Instance" and m.Parent then return m end
        end
        return nil
    end
    local function machinePoint(modelRef)
        local pad = modelRef:FindFirstChild("Pad", true)
        if pad and pad:IsA("BasePart") then return pad.Position end
        local ok, piv = pcall(modelRef.GetPivot, modelRef)
        return ok and piv.Position or nil
    end
    local IGNORED = {
        GroupRewards  = true,
        SocialRewards = true,
        VIPRewards    = true,
    }
    local function timedPending()
        local d = save()
        if not (d and Dir and Dir.TimedRewards) then return {} end
        local stamps = d.TimedRewardTimestamps or {}
        local nowT = workspace:GetServerTimeNow()
        local out = {}
        for chave, r in pairs(Dir.TimedRewards) do
            if not IGNORED[chave] then
                local ts = stamps[chave]
                if not ts or (nowT - ts) > (r.Cooldown or 0) then
                    out[#out + 1] = chave
                end
            end
        end
        table.sort(out)
        return out
    end
    local function claimTimed()
        local pend = timedPending()
        local originPos, n, alcancaveis = nil, 0, 0
        for _, chave in ipairs(pend) do
            if not alive() then break end
            local modelRef = machineOf(chave)
            local spot = modelRef and machinePoint(modelRef)
            if spot then
                alcancaveis = alcancaveis + 1
                if (getHRP() and (getHRP().Position - spot).Magnitude or math.huge) > 20 then
                    local hrp = getHRP()
                    if hrp then
                        originPos = originPos or hrp.CFrame
                        tpTo(CFrame.new(spot + Vector3.new(0, 4, 0)))
                        task.wait(TP_WAIT_MACHINE)
                    end
                end
                if invokeOk("DailyRewards_Redeem", chave) then n = n + 1 end
                task.wait(0.3)
            end
        end
        if originPos then tpTo(originPos) end
        return n, alcancaveis, #pend
    end
    local S_timed = false
    sec:AddToggle({ Name = "Auto Claim Timed Rewards", Default = false, Tooltip = "Diamonds, enchants, items and the social reward. This remote checks distance, so it teleports to each machine and puts you back where you were. Only machines that exist in this world are claimable - the rest live in World 2/3/4, which are separate places.", Callback = function(v)
        S_timed = v
        if not v then return end
        loopBody(function() return S_timed end, 60, function()
            local n, alcancaveis, total = claimTimed()
            if n > 0 then
                notify("Collect", ("Timed rewards: %d claimed"):format(n), 4)
            elseif alcancaveis == 0 and total > 0 then
                notify("Collect", ("%d ready, but their machines are in another world"):format(total), 6)
            end
        end)
    end })
end
do
    local sec = Sub.ColBalloon:AddSection({ Name = "Balloons", Side = 1, Icon = "party-popper" })
    local TYPES = { "Small Balloon", "Medium Balloon", "Huge Balloon" }
    local chosenTypes = { ["Small Balloon"] = true, ["Medium Balloon"] = true, ["Huge Balloon"] = true }
    local autoPop, autoDestruir = false, false
    local function activeOnes()
        local wasCalled, listing = invoke("BalloonGifts_GetActiveBalloons")
        if not (wasCalled and type(listing) == "table") then return {} end
        return listing
    end
    local RATE = 1
    local function estourar(b)
        local hrp = getHRP()
        if not hrp then return false end
        local originPos = hrp.Position
        local d = b.Position - originPos
        local planB = Vector2.new(d.X, d.Z).Magnitude
        local angle = math.atan2(d.Z, d.X)
        local elevation = planB > 0 and math.atan(d.Y / planB) or 0
        invoke("Slingshot_FireProjectile", originPos, angle, elevation, 200)
        return select(1, fire("BalloonGifts_BalloonHit", b.Id))
    end
    sec:AddToggle({ Name = "Auto Popping", Default = false, Tooltip = "Equips the slingshot and pops every balloon of the selected types. Needs 3 rebirths - that's the game's own gate on the slingshot, and the server refuses the hit without it.", Callback = function(v)
        autoPop = v
        if not v then
            invoke("Slingshot_Unequip")
            return
        end
        task.spawn(function()
            local reb = 0
            if G.Rebirth then
                local ok, r = pcall(G.Rebirth.Get)
                if ok then reb = tonumber(r) or 0 end
            end
            if reb < 3 then
                notify("Balloons", ("Needs 3 rebirths for the slingshot (you have %d)"):format(reb), 7)
                autoPop = false
                return
            end
            local wasCalled, accepted, msg = invoke("Slingshot_Equip")
            if not (wasCalled and accepted) then
                notify("Balloons", "Slingshot refused: " .. tostring(msg or "no answer"), 7)
                autoPop = false
                return
            end
            notify("Balloons", "Slingshot equipped", 4)
            while alive() and autoPop do
                local didSend = false
                for _, b in pairs(activeOnes()) do
                    if not (alive() and autoPop) then break end
                    if not b.Popped and chosenTypes[b.BalloonTypeId] then
                        estourar(b)
                        didSend = true
                        task.wait(RATE)
                    end
                end
                if not didSend then task.wait(3) end
            end
            invoke("Slingshot_Unequip")
        end)
    end })
    sec:AddDropdown({ Name = "Select Balloon Types", Items = TYPES, Multi = true,
        Default = { "Small Balloon", "Medium Balloon", "Huge Balloon" },
        Tooltip = "Which balloons Auto Popping is allowed to hit. The three types differ in drop table and chest - Huge is the rare one.",
        Callback = function(v)
            local out = {}
            if type(v) == "table" then
                for k, val in pairs(v) do
                    if type(val) == "boolean" then
                        if val then out[k] = true end
                    elseif type(val) == "string" then
                        out[val] = true
                    end
                end
            elseif type(v) == "string" then
                out[v] = true
            end
            if not next(out) then
                for _, t in ipairs(TYPES) do out[t] = true end
            end
            chosenTypes = out
        end })
    sec:AddToggle({ Name = "Auto Destroy Balloon Gifts", Default = false, Tooltip = "Deletes the balloon models locally. They ride a BulkMoveTo every frame, so on a weak machine this gives frames back. Purely visual - the balloons still exist on the server.", Callback = function(v)
        autoDestruir = v
        if not v then return end
        task.spawn(function()
            while alive() and autoDestruir do
                local folderRef = workspace:FindFirstChild("__THINGS")
                folderRef = folderRef and folderRef:FindFirstChild("BalloonGifts")
                if folderRef then
                    for _, m in ipairs(folderRef:GetChildren()) do
                        pcall(function() m:Destroy() end)
                    end
                end
                task.wait(2)
            end
        end)
    end })
end
do
    local sec = Sub.ColUpgrade:AddSection({ Name = "Upgrades", Side = 1, Icon = "trending-up" })
    local Bal = G.Balancing
    local autoPet, autoEgg = false, false
    local function diamonds()
        if not G.Money then return 0 end
        local ok, v = pcall(G.Money.Get, "Diamonds")
        return ok and tonumber(v) or 0
    end
    local function buyPetSlot()
        local d = save()
        if not (d and G.Rank and Bal) then return false, "modules unavailable" end
        local tem = tonumber(d.PetSlotsPurchased) or 0
        local ok, ceilingVal = pcall(G.Rank.GetMaxPurchasableEquipSlots)
        ceilingVal = ok and tonumber(ceilingVal) or 0
        if tem >= ceilingVal then return false, ("maxed for your rank (%d)"):format(ceilingVal) end
        local aim = tem + 1
        local okP, cost = pcall(Bal.CalcPetSlotPrice, aim)
        cost = okP and tonumber(cost) or nil
        if cost and diamonds() < cost then
            return false, ("needs %d diamonds"):format(cost)
        end
        local accepted = invokeOk("EquipSlotsMachine_RequestPurchase", aim)
        return accepted, accepted and ("slot %d"):format(aim) or "refused by server"
    end
    sec:AddToggle({ Name = "Auto Buy Pet Slots", Default = false, Tooltip = "Buys equip slots one by one, up to the cap your rank allows. Checks the diamond price first, so a broke account sends nothing.", Callback = function(v)
        autoPet = v
        if not v then return end
        task.spawn(function()
            while alive() and autoPet do
                local ok, msg = buyPetSlot()
                if ok then
                    notify("Upgrades", "Pet " .. msg, 4)
                    task.wait(1)
                else
                    task.wait(20)
                end
            end
        end)
    end })
    local function buyEggSlot()
        local d = save()
        if not (d and G.Rank and Bal) then return false, "modules unavailable" end
        local tem = tonumber(d.EggSlotsPurchased) or 0
        local okT, ceilingVal = pcall(G.Rank.GetMaxPurchasableEggSlots)
        ceilingVal = okT and tonumber(ceilingVal) or 0
        if tem >= ceilingVal then return false, ("maxed for your rank (%d)"):format(ceilingVal) end
        local okB, fim, tamanho = pcall(G.Rank.GetEggBundle, tem + 1)
        if not (okB and fim and tamanho) then return false, "bundle unknown" end
        if fim > ceilingVal then return false, ("next bundle needs a higher rank"):format() end
        local cost = 0
        for i = 1, tamanho do
            local okC, p = pcall(Bal.CalcEggSlotPrice, fim - tamanho + i)
            if okC then cost = cost + (tonumber(p) or 0) end
        end
        if cost > 0 and diamonds() < cost then
            return false, ("needs %d diamonds"):format(cost)
        end
        local accepted = invokeOk("EggHatchSlotsMachine_RequestPurchase", fim)
        return accepted, accepted and ("+%d egg"):format(tamanho) or "refused by server"
    end
    sec:AddToggle({ Name = "Auto Buy Egg Slots", Default = false, Tooltip = "Buys hatch slots. The game sells these in bundles (+1/+2/+3), so the price is the whole bundle, not one slot - this adds it up before sending.", Callback = function(v)
        autoEgg = v
        if not v then return end
        task.spawn(function()
            while alive() and autoEgg do
                local ok, msg = buyEggSlot()
                if ok then
                    notify("Upgrades", "Egg slots " .. msg, 4)
                    task.wait(1)
                else
                    task.wait(20)
                end
            end
        end)
    end })
    local TP_WAIT = 0.4
    local NEAR     = 20
    local function buyUpgrades()
        if not (G.Upgrade and G.Dir) then return 0, 0 end
        local okA, listing = pcall(G.Upgrade.All)
        if not (okA and type(listing) == "table") then return 0, 0 end
        local originPos = nil
        local bought, vistos = 0, 0
        for _, u in ipairs(listing) do
            if not alive() then break end
            local okC, canDo = pcall(G.Upgrade.CanInteractWith, u.UpgradeID, u.ZoneID)
            if okC and canDo then
                vistos = vistos + 1
                local dir = G.Dir.Upgrades and G.Dir.Upgrades[u.UpgradeID]
                local cost = dir and dir.TierCosts and dir.TierCosts[u.UpgradeTier]
                local currency = dir and dir.TierCurrencies and dir.TierCurrencies[u.UpgradeTier]
                local balance = 0
                if G.Money and currency then
                    local okS, s = pcall(G.Money.Get, currency)
                    balance = okS and tonumber(s) or 0
                end
                if cost and balance >= cost then
                    if u.Model and u.Model.Parent and distTo(u.Model) > NEAR then
                        local hrp = getHRP()
                        if hrp then
                            originPos = originPos or hrp.CFrame
                            local okPv, piv = pcall(u.Model.GetPivot, u.Model)
                            if okPv then
                                tpTo(CFrame.new(piv.Position + Vector3.new(0, 5, 0)))
                                task.wait(TP_WAIT)
                            end
                        end
                    end
                    local okP, accepted = pcall(G.Upgrade.Purchase, u.UpgradeID, u.ZoneID)
                    if okP and accepted ~= false then bought = bought + 1 end
                    task.wait(0.3)
                end
            end
        end
        if originPos then tpTo(originPos) end
        return bought, vistos
    end
    local autoUp = false
    sec:AddToggle({ Name = "Buy Affordable Player Upgrades", Default = false, Tooltip = "Walks the upgrades of every zone you own and buys whatever you can pay for, then keeps watching. Checking is a local read, so an empty pass sends nothing.", Callback = function(v)
        autoUp = v
        if not v then return end
        task.spawn(function()
            while alive() and autoUp do
                local n = buyUpgrades()
                if n > 0 then notify("Upgrades", ("Bought %d upgrade%s"):format(n, n > 1 and "s" or ""), 5) end
                for _ = 1, 15 do
                    if not (alive() and autoUp) then break end
                    task.wait(1)
                end
            end
        end)
    end })
end
do
    local sec = Sub.WorldTp:AddSection({ Name = "Zones", Side = 1, Icon = "map-pin" })
    local zoneNames, zoneDropdown, zonaEscolhida = {}, nil, nil
    local function refreshZones()
        zoneNames = {}
        if not G.ZonesUtil then return end
        local ok, arr = gameCall(G.ZonesUtil.GetArray)
        if not ok or type(arr) ~= "table" then return end
        local okL, filtradas = gameCall(function()
            local out = {}
            for _, label2 in ipairs(arr) do
                local owned = true
                if G.Zone and type(G.Zone.Owns) == "function" then
                    local oko, v = pcall(G.Zone.Owns, label2)
                    owned = oko and v == true
                end
                if owned then out[#out + 1] = label2 end
            end
            return out
        end)
        if okL and type(filtradas) == "table" then zoneNames = filtradas end
    end
    refreshZones()
    zoneDropdown = sec:AddDropdown({ Name = "Zone", Items = zoneNames, Default = nil, Multi = false, Callback = function(v)
        zonaEscolhida = v
    end })
    sec:AddButton({ Name = "Refresh Zones", Callback = uiCall(function()
        refreshZones()
        if zoneDropdown and zoneDropdown.Refresh then zoneDropdown:Refresh(zoneNames) end
        notify("World", ("%d zones owned"):format(#zoneNames), 3)
    end) })
    sec:AddButton({ Name = "Teleport to Zone", Callback = uiCall(function()
        if not (zonaEscolhida and G.ZonesUtil) then return end
        local ok, cf = pcall(G.ZonesUtil.GetTeleportPartLocation, zonaEscolhida)
        if ok and typeof(cf) == "CFrame" then
            tpTo(cf + Vector3.new(0, 4, 0))
        else
            notify("World", "No teleport point for " .. tostring(zonaEscolhida), 4)
        end
    end) })
    sec:AddButton({ Name = "Game Teleport to Zone", Tooltip = "Uses the game's own teleport request instead of moving your character. Slower, but it is the same call the in-game map makes.", Callback = uiCall(function()
        if not zonaEscolhida then return end
        local ok = invokeOk("Teleports_RequestTeleport", zonaEscolhida)
        notify("World", ok and ("Requested " .. zonaEscolhida) or "Teleport refused", 4)
    end) })
    sec = Sub.WorldChar:AddSection({ Name = "Character", Side = 1, Icon = "person-standing" })
    sec:AddSlider({ Name = "Walk Speed", Default = 0, Min = 0, Max = 200, Rounding = 0, Tooltip = "0 = leave the game's own value alone.", Callback = function(v)
        S.savedSpeed = (v > 0) and v or nil
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and S.savedSpeed then pcall(function() hum.WalkSpeed = S.savedSpeed end) end
    end })
    bind(LocalPlayer.CharacterAdded, function(char)
        task.spawn(function()
            local hum = char:WaitForChild("Humanoid", 10)
            if hum and S.savedSpeed and alive() then
                pcall(function() hum.WalkSpeed = S.savedSpeed end)
            end
        end)
    end)
    sec:AddToggle({ Name = "Infinite Jump", Default = false, Callback = function(state)
        if not state then return end
        task.spawn(function()
            local conn
            conn = UserInputService.JumpRequest:Connect(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
            end)
            while alive() and conn.Connected do
                task.wait(0.5)
                if not Library or Library.Unloading or Library.Unloaded then break end
            end
            pcall(function() conn:Disconnect() end)
        end)
    end })
    sec:AddToggle({ Name = "Noclip", Default = false, Tooltip = "Walk through walls and gates. The gate is still locked server-side - this only moves your body.", Callback = function(state)
        S.noclip = state
        if not state then return end
        task.spawn(function()
            while alive() and S.noclip do
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                    end
                end
                RunService.Stepped:Wait()
            end
        end)
    end })
    sec = Sub.WorldRender:AddSection({ Name = "Render", Side = 1, Icon = "monitor" })
    local luzOriginal = nil
    sec:AddToggle({ Name = "Fullbright", Default = false, Callback = function(state)
        if state then
            luzOriginal = luzOriginal or {
                Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
            }
            pcall(function()
                Lighting.Brightness = 2
                Lighting.ClockTime = 12
                Lighting.FogEnd = 1e6
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            end)
        elseif luzOriginal then
            pcall(function()
                for k, v in pairs(luzOriginal) do Lighting[k] = v end
            end)
        end
    end })
    sec:AddToggle({ Name = "FPS Boost", Default = false, Tooltip = "Kills particles, trails and shadows. This game spawns a particle host per breakable, so it is the single biggest win.", Callback = function(state)
        task.spawn(function()
            pcall(function()
                Lighting.GlobalShadows = not state
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke")
                        or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = not state
                    end
                end
                if state then
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                end
            end)
        end)
    end })
end
do
    local sec = Sub.SrvMain:AddSection({ Name = "Server", Side = 1, Icon = "circle" })
    sec:AddButton({ Name = "Rejoin Server", Callback = function()
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\nRejoining...")
            task.wait()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end })
    local function listServers(sortOrder)
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=" .. sortOrder .. "&limit=100"
        local function get(cursor)
            local raw = game:HttpGet(url .. ((cursor and "&cursor=" .. cursor) or ""))
            return HttpService:JSONDecode(raw)
        end
        local data, cursor
        repeat
            local res = get(cursor)
            data = res.data
            cursor = res.nextPageCursor
        until data
        for i = 1, #data do
            local v = data[i]
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                local ok = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, v.id, LocalPlayer)
                if ok then return end
            end
        end
    end
    sec:AddButton({ Name = "Server Hop", Callback = function() pcall(listServers, "Desc") end })
    sec:AddButton({ Name = "Small Server", Callback = function() pcall(listServers, "Asc") end })
    sec = Sub.SrvJob:AddSection({ Name = "Job ID Manager", Side = 1, Icon = "hash" })
    sec:AddButton({ Name = "Copy Job ID", Callback = function()
        if setclipboard then
            setclipboard(tostring(game.JobId))
            notify("Server", "Job ID copied to clipboard")
        end
    end })
    _dzEnv.DzUniversal_TargetJobId = _dzEnv.DzUniversal_TargetJobId or ""
    sec:AddTextbox({ Name = "Target Job ID", Placeholder = "Paste Job ID here...", Finished = true, Callback = function(val)
        _dzEnv.DzUniversal_TargetJobId = val
    end })
    sec:AddButton({ Name = "Join Job ID", Callback = function()
        if _dzEnv.DzUniversal_TargetJobId ~= "" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, _dzEnv.DzUniversal_TargetJobId, LocalPlayer)
        end
    end })
    sec = Sub.SrvPlace:AddSection({ Name = "Place Teleport", Side = 1, Icon = "plane" })
    local placesByName = {}
    local placeNames = {}
    local placeDropdown
    local selectedPlaceName = nil
    local function fetchPlaces()
        placesByName, placeNames = {}, {}
        local url = "https://develop.roblox.com/v1/universes/" .. game.GameId .. "/places?sortOrder=Asc&limit=100"
        local ok, raw = pcall(game.HttpGet, game, url)
        if not ok or type(raw) ~= "string" then return end
        local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok2 or type(data) ~= "table" or type(data.data) ~= "table" then return end
        for _, p in ipairs(data.data) do
            if p.name and p.id then
                placesByName[p.name] = p.id
                placeNames[#placeNames + 1] = p.name
            end
        end
        table.sort(placeNames)
        if placeDropdown and placeDropdown.Refresh then
            placeDropdown:Refresh(placeNames)
        end
    end
    task.spawn(fetchPlaces)
    placeDropdown = sec:AddDropdown({ Name = "Place", Items = placeNames, Default = nil, Multi = false, Callback = function(v)
        selectedPlaceName = v
    end })
    sec:AddButton({ Name = "Refresh List", Callback = fetchPlaces })
    sec:AddButton({ Name = "Teleport", Callback = function()
        if not selectedPlaceName then return end
        local pid = placesByName[selectedPlaceName]
        if pid then TeleportService:Teleport(pid, LocalPlayer) end
    end })
    sec = Sub.SrvJob:AddSection({ Name = "Saved Servers", Side = 2, Icon = "bookmark" })
    local SAVED_PATH = "DzHub/saved_servers.json"
    local savedServers = {}
    local savedServerNames = {}
    local savedDropdown
    local savedSelectedName = nil
    local function loadSaved()
        savedServers, savedServerNames = {}, {}
        if not (isfile and isfile(SAVED_PATH)) then return end
        local ok, raw = pcall(readfile, SAVED_PATH)
        if not ok or type(raw) ~= "string" then return end
        local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok2 or type(data) ~= "table" then return end
        for name, jobId in pairs(data) do
            savedServers[name] = jobId
            savedServerNames[#savedServerNames + 1] = name
        end
        table.sort(savedServerNames)
    end
    local function persistSaved()
        if not writefile then return end
        if makefolder and not (isfolder and isfolder("DzHub")) then
            pcall(makefolder, "DzHub")
        end
        pcall(writefile, SAVED_PATH, HttpService:JSONEncode(savedServers))
    end
    local function refreshSavedDropdown()
        if savedDropdown and savedDropdown.Refresh then
            savedDropdown:Refresh(savedServerNames)
        end
    end
    loadSaved()
    sec:AddButton({ Name = "Save Current Server", Callback = function()
        local name = os.date("%Y-%m-%d %H:%M:%S")
        if savedServers[name] then
            local i = 2
            while savedServers[name .. " (" .. i .. ")"] do i = i + 1 end
            name = name .. " (" .. i .. ")"
        end
        savedServers[name] = tostring(game.JobId)
        savedServerNames[#savedServerNames + 1] = name
        table.sort(savedServerNames)
        persistSaved()
        refreshSavedDropdown()
        notify("Saved Servers", "Saved '" .. name .. "'")
    end })
    savedDropdown = sec:AddDropdown({ Name = "Saved", Items = savedServerNames, Default = nil, Multi = false, Callback = function(v)
        savedSelectedName = v
    end })
    sec:AddButton({ Name = "Join Saved", Callback = function()
        if not savedSelectedName then return end
        local jobId = savedServers[savedSelectedName]
        if jobId and jobId ~= "" then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
            end)
        end
    end })
    sec:AddButton({ Name = "Delete Selected", Callback = function()
        if not savedSelectedName then return end
        savedServers[savedSelectedName] = nil
        for i, n in ipairs(savedServerNames) do
            if n == savedSelectedName then
                table.remove(savedServerNames, i)
                break
            end
        end
        savedSelectedName = nil
        persistSaved()
        refreshSavedDropdown()
    end })
    sec = Sub.SrvMain:AddSection({ Name = "Misc", Side = 2, Icon = "ellipsis" })
    sec:AddButton({ Name = "Force Reconnect", Callback = function()
        pcall(function() LocalPlayer:Kick("\nReconnecting...") end)
        task.wait(0.2)
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end })
    sec:AddButton({ Name = "Copy Link Server", Callback = function()
        if not setclipboard then return end
        local uri = string.format(
            "roblox://experiences/start?placeId=%d&gameInstanceId=%s",
            game.PlaceId, tostring(game.JobId)
        )
        setclipboard(uri)
        notify("Server", "Server link copied to clipboard")
    end })
    sec:AddButton({ Name = "Check Account Flag", Callback = uiCall(function()
        local ok, res = pcall(function() return Net.Invoke("Is Real Player") end)
        if not ok then
            notify("Account", "Could not read the flag", 5)
        else
            notify("Account", "Is Real Player = " .. tostring(res), 8)
        end
    end) })
end
if type(Window.HideLoading) == "function" then
    pcall(function() Window:HideLoading() end)
end
if type(Library.LoadAutoloadConfig) == "function" then
    pcall(function() Library:LoadAutoloadConfig(true) end)
end
DzLib:Notification("Pet Simulator 99", "Script loaded!", 3)
end)
