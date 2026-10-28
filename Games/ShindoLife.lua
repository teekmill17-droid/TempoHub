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
_dzEnv.DzShindo_Gen = (_dzEnv.DzShindo_Gen or 0) + 1
local MY_GEN = _dzEnv.DzShindo_Gen
local MyLib
local function alive()
    if _dzEnv.DzShindo_Gen ~= MY_GEN then return false end
    if MyLib and (MyLib.Unloading or MyLib.Unloaded) then return false end
    return true
end
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local HRP       = Character and Character:FindFirstChild("HumanoidRootPart")
local Humanoid  = Character and Character:FindFirstChild("Humanoid")
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HRP       = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid  = char:WaitForChild("Humanoid", 10)
end)
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
local startevent, statz, statMain, spinsValue
do
    local deadline = os.clock() + 10
    repeat
        startevent = startevent or LocalPlayer:FindFirstChild("startevent")
        statz      = statz      or LocalPlayer:FindFirstChild("statz")
        if statz then
            statMain   = statMain   or statz:FindFirstChild("main")
            spinsValue = spinsValue or statz:FindFirstChild("spins")
        end
        if (startevent and statMain and spinsValue)
            or LocalPlayer:FindFirstChild("pressplay") then
            break
        end
        task.wait(0.1)
    until os.clock() > deadline
end
local HAS_STATS = (startevent and statMain and spinsValue) and true or false
local function fire(remote, ...)
    if not remote then return end
    local safe = _dzEnv.DzSafe
    if safe and type(safe.Fire) == "function" then
        return safe.Fire(remote, ...)
    end
    return remote:FireServer(...)
end
local function slotValue(slot)
    local v = statMain and statMain:FindFirstChild(slot)
    return v and v.Value or ""
end
local function collectSpinnables(marker)
    local out = {}
    local RARE = workspace:FindFirstChild("RAREKGS")
    local all = ReplicatedStorage:FindFirstChild("alljutsu")
    if not all then return out end
    for _, child in ipairs(all:GetChildren()) do
        if child:FindFirstChild(marker) then
            local skip = child:FindFirstChild("cantspin") ~= nil
            if not skip and child:FindFirstChild("limited") then
                local entry = RARE and RARE:FindFirstChild(child.Name)
                local release = entry and entry:FindFirstChild("release")
                if not (release and release.Value) then skip = true end
            end
            if not skip then
                local real = child:FindFirstChild("REALNAME")
                out[#out+1] = { name = child.Name, real = real and real.Value or child.Name }
            end
        end
    end
    table.sort(out, function(a, b) return a.real:lower() < b.real:lower() end)
    return out
end
local function waitForCooldown(slot, timeout)
    local v = statMain and statMain:FindFirstChild(slot)
    if not v then return end
    local t0 = os.clock()
    while not v:FindFirstChild("dontspin") and (os.clock() - t0) < 1 do
        task.wait(0.05)
    end
    while v:FindFirstChild("dontspin") and (os.clock() - t0) < (timeout or 12) do
        task.wait(0.1)
    end
end
local function fireSpin(slot)
    fire(startevent, "spin", slot)
end
local function spinCount()
    return (spinsValue and spinsValue.Value) or 0
end
local function corruptSave()
    fire(startevent, "haircolor", "0.5," .. string.char(255) .. ",0.7")
    task.wait(0.1)
    fire(startevent, "custocomplete")
end
local function rejoin()
    if type(_dzEnv.DisableAntiTeleport) == "function" then
        pcall(_dzEnv.DisableAntiTeleport)
    end
    task.wait(0.1)
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end
local getUrl = _dzEnv.DzHub_GetUrl or function(path)
    return "" .. path
end
local DEV_MODE = _dzEnv.DzHub_DevMode
local isMobile = _dzEnv.DzHub_IsMobile
if isMobile == nil then
    local UIS = game:GetService("UserInputService")
    isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
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
    Name = "Tempo", SubName = "Shindo Life",
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
pcall(function()
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
        "chevron-right", "dices", "info", "server", "settings", "swords"
    }) do add(n) end
    if #urls > 0 then pcall(function() game:GetService("ContentProvider"):PreloadAsync(urls) end) end
end)
local FarmTab = Window:AddTab({ Name = "Farm",    Icon = "swords" })
local SpinTab = Window:AddTab({ Name = "Spins",   Icon = "dices" })
local UtilTab = Window:AddTab({ Name = "Utility", Icon = "settings" })
local SrvTab  = Window:AddTab({ Name = "Server",  Icon = "server" })
local Sub = (function()
    local function mk(tab, name)
        if type(tab) == "table" and type(tab.AddSubTab) == "function" then
            local ok, sub = pcall(tab.AddSubTab, tab, { Name = name })
            if ok and type(sub) == "table" then return sub end
        end
        return tab
    end
    return {
        FarmSet     = mk(FarmTab, "Settings"),
        FarmLevel   = mk(FarmTab, "Level"),
        FarmBoss    = mk(FarmTab, "Bosses"),
        FarmScroll  = mk(FarmTab, "Scrolls"),
        FarmReward  = mk(FarmTab, "Rewards"),
        FarmDungeon = mk(FarmTab, "Dungeon"),
        SpinBlood   = mk(SpinTab, "Bloodline"),
        SpinElement = mk(SpinTab, "Element"),
        SpinCodes   = mk(SpinTab, "Codes"),
        SpinBack    = mk(SpinTab, "Rollback"),
        UtilStats   = mk(UtilTab, "Stats"),
        UtilQuest   = mk(UtilTab, "Quest Maker"),
        UtilMove    = mk(UtilTab, "Movement"),
        UtilEsp     = mk(UtilTab, "ESP"),
        UtilTp      = mk(UtilTab, "Teleports"),
        SrvMain     = mk(SrvTab, "Server"),
        SrvPlace    = mk(SrvTab, "Places"),
        SrvPriv     = mk(SrvTab, "Private"),
        SrvJob      = mk(SrvTab, "Job IDs"),
    }
end)()
local function makeSlotIndex(displayPrefix, internalPrefix, count)
    local items, toInternal, toDisplay = {}, {}, {}
    for i = 1, count do
        local d = displayPrefix .. " " .. i
        local n = internalPrefix .. i
        items[i]        = d
        toInternal[d]   = n
        toDisplay[n]    = d
    end
    return items, toInternal, toDisplay
end
local KG_SLOT_ITEMS,      KG_SLOT_INTERNAL,      KG_SLOT_DISPLAY      = makeSlotIndex("Bloodline", "kg",      4)
local ELEMENT_SLOT_ITEMS, ELEMENT_SLOT_INTERNAL, ELEMENT_SLOT_DISPLAY = makeSlotIndex("Elements",  "element", 4)
local KG_LIST      = collectSpinnables("KG")
local ELEMENT_LIST = collectSpinnables("ELEMENT")
local function buildDisplayIndex(list)
    local items, realToName = {}, {}
    for _, e in ipairs(list) do
        items[#items+1] = e.real
        realToName[e.real] = e.name
    end
    return items, realToName
end
local KG_ITEMS,      KG_MAP      = buildDisplayIndex(KG_LIST)
local ELEMENT_ITEMS, ELEMENT_MAP = buildDisplayIndex(ELEMENT_LIST)
local state = {
    kg      = { running = false, slots = { "kg1" },      whitelist = {} },
    element = { running = false, slots = { "element1" }, whitelist = {} },
}
local autoRollback = false
local function buildSpinSection(name, kind, slotItems, slotToInternal, slotToDisplay, defaultDisplay, items, realToName)
    local defaultInternal = slotToInternal[defaultDisplay]
    local host = Sub[kind == "kg" and "SpinBlood" or "SpinElement"]
    local section = host:AddSection({ Name = name, Icon = "dices", Side = 1 })
    if not HAS_STATS then
        section:AddLabel("Unavailable here - this place has no spin data.")
        section:AddLabel("Go back to a village to use it.")
    end
    local slotLabels = {}
    for _, display in ipairs(slotItems) do
        local internal = slotToInternal[display]
        slotLabels[display] = section:AddLabel(display .. ": " .. slotValue(internal))
    end
    local countLabel = section:AddLabel("Spins available: " .. tostring(spinCount()))
    section:AddDropdown({
        Name = "Slots (multi)",
        Flag = "shindo_" .. kind .. "_slot",
        Multi = true,
        Items = slotItems,
        Default = { defaultDisplay },
        Callback = function(selected)
            local list = {}
            if type(selected) == "table" then
                for k, v in pairs(selected) do
                    local display = (type(k) == "string") and k or v
                    local internal = slotToInternal[display]
                    if internal then list[#list+1] = internal end
                end
            end
            if #list == 0 then list = { defaultInternal } end
            state[kind].slots = list
        end,
    })
    section:AddDropdown({
        Name = "Whitelist (empty = spin forever)",
        Flag = "shindo_" .. kind .. "_whitelist",
        Multi = true,
        SearchThreshold = 6,
        Items = items,
        Default = {},
        Callback = function(selected)
            local set = {}
            if type(selected) == "table" then
                for k, v in pairs(selected) do
                    local real = (type(k) == "string") and k or v
                    local internal = realToName[real]
                    if internal then set[internal] = true end
                end
            end
            state[kind].whitelist = set
        end,
    })
    section:AddButton({
        Name = "Spin Once (all selected slots)",
        Callback = function()
            for _, slot in ipairs(state[kind].slots) do fireSpin(slot) end
        end,
    })
    local runGen = 0
    local announced = {}
    local function picked(slot)
        for _, s in ipairs(state[kind].slots) do
            if s == slot then return true end
        end
        return false
    end
    local function runSlot(slot, myGen)
        task.wait(1)
        while state[kind].running and alive() and runGen == myGen do
            if not picked(slot) then
                task.wait(0.5)
                continue
            end
            if next(state[kind].whitelist) and state[kind].whitelist[slotValue(slot)] then
                if not announced[slot] then
                    announced[slot] = true
                    Library:Notification("Auto Spin",
                        (slotToDisplay[slot] or slot) .. " already matches - leaving it alone", 6)
                end
                task.wait(1)
                continue
            end
            announced[slot] = nil
            if spinCount() <= 0 then
                state[kind].running = false
                if autoRollback then
                    Library:Notification("Auto Rollback", "Out of spins - rolling back", 5)
                    task.wait(0.3)
                    corruptSave()
                    task.wait(0.3)
                    rejoin()
                end
                return
            end
            fireSpin(slot)
            waitForCooldown(slot, 12)
            if not state[kind].running or runGen ~= myGen then return end
            local whitelist = state[kind].whitelist
            local result = slotValue(slot)
            if next(whitelist) and whitelist[result] then
                state[kind].running = false
                if autoRollback then
                    Library:Notification("Auto Rollback", "Matched " .. result .. " - rejoining to save", 6)
                    task.wait(0.3)
                    rejoin()
                else
                    Library:Notification("Auto Spin", "Matched " .. result .. " on " .. (slotToDisplay[slot] or slot), 6)
                end
                return
            end
        end
    end
    section:AddToggle({
        Name = "Auto Spin (stops on whitelist match)",
        Flag = "shindo_" .. kind .. "_auto",
        Default = false,
        Callback = function(on)
            state[kind].running = on
            runGen = runGen + 1
            if not on then return end
            local myGen = runGen
            for _, display in ipairs(slotItems) do
                task.spawn(runSlot, slotToInternal[display], myGen)
            end
        end,
    })
    if not HAS_STATS then return end
    task.spawn(function()
        while alive() do
            countLabel:SetText("Spins available: " .. tostring(spinCount()))
            for _, display in ipairs(slotItems) do
                local internal = slotToInternal[display]
                slotLabels[display]:SetText(display .. ": " .. slotValue(internal))
            end
            task.wait(1)
        end
    end)
end
buildSpinSection("Auto Bloodline", "kg",      KG_SLOT_ITEMS,      KG_SLOT_INTERNAL,      KG_SLOT_DISPLAY,      "Bloodline 1", KG_ITEMS,      KG_MAP)
buildSpinSection("Auto Element",   "element", ELEMENT_SLOT_ITEMS, ELEMENT_SLOT_INTERNAL, ELEMENT_SLOT_DISPLAY, "Elements 1",  ELEMENT_ITEMS, ELEMENT_MAP)
local CODE_SOURCES = {
    { Name = "Eurogamer",     Url = "https://www.eurogamer.pt/roblox-codigos-shindo-life" },
    { Name = "Pocket Tactics", Url = "https://www.pockettactics.com/shindo-life/codes"    },
}
local function httpRequest()
    return (syn and syn.request)
        or http_request
        or request
        or (fluxus and fluxus.request)
end
local function parseReward(text)
    local lower = text:lower()
    local reward = { kind = "Unknown", spins = 0, rellcoins = 0 }
    local s = text:match("(%d+)%s*[Ss]pins?")
    if s then reward.spins = tonumber(s) end
    local rc = text:match("(%d+)%s*[Kk]?%s*RELL")
    if rc then
        rc = tonumber(rc)
        if lower:find("k") then rc = rc * 1000 end
        reward.rellcoins = rc
    end
    if lower:find("bloodline") then
        reward.kind = "Bloodline Bag"
    elseif lower:find("server") then
        reward.kind = "Private Server"
    elseif reward.spins > 0 and reward.rellcoins > 0 then
        reward.kind = "Spin + Rellcoins"
    elseif reward.spins > 0 then
        reward.kind = "Spin"
    elseif reward.rellcoins > 0 then
        reward.kind = "Rellcoins"
    elseif lower:find("spin") and lower:find("rell") then
        reward.kind = "Spin + Rellcoins"
    elseif lower:find("spin") then
        reward.kind = "Spin"
    elseif lower:find("rell") then
        reward.kind = "Rellcoins"
    end
    return reward
end
local function formatReward(r)
    if r.spins > 0 and r.rellcoins > 0 then
        return r.spins .. " Spins + " .. r.rellcoins .. " RC"
    elseif r.spins > 0 then
        return r.spins .. " Spins"
    elseif r.rellcoins > 0 then
        return r.rellcoins .. " RC"
    end
    return r.kind
end
local function fetchCodes()
    local req = httpRequest()
    local list, seen = {}, {}
    if not req then return list, "executor has no HTTP request function" end
    for _, site in ipairs(CODE_SOURCES) do
        local ok, r = pcall(req, { Url = site.Url, Method = "GET" })
        if ok and r and r.StatusCode == 200 and type(r.Body) == "string" then
            for item in r.Body:gmatch("<li.->(.-)</li>") do
                local raw = item:match("<strong>(.-)</strong>")
                if raw then
                    local code = raw:gsub("<.->", ""):match("^%s*(.-)%s*$") or ""
                    if code ~= "" and code:find("!") and not seen[code] then
                        local rewardText = item
                            :gsub("<strong>.-</strong>", "")
                            :gsub("<.->", "")
                            :gsub("&nbsp;", " ")
                            :gsub("^%s*[-:]?%s*", "")
                            :match("^%s*(.-)%s*$") or ""
                        local reward = parseReward(rewardText)
                        seen[code] = true
                        list[#list+1] = { code = code, reward = reward, display = code .. " - " .. formatReward(reward) }
                    end
                end
            end
        end
    end
    table.sort(list, function(a, b) return a.code:lower() < b.code:lower() end)
    return list
end
local CodesSection = Sub.SpinCodes:AddSection({ Name = "Codes", Icon = "key", Side = 1 })
if not HAS_STATS then
    CodesSection:AddLabel("Redeeming needs a village - this place has no")
    CodesSection:AddLabel("player data. The list still loads.")
end
local codesStatus  = CodesSection:AddLabel("Status: auto-fetching...")
local codesCache      = {}
local displayToCode   = {}
local codesSelected   = {}
local codesDropdown = CodesSection:AddDropdown({
    Name = "Codes",
    Flag = "shindo_codes_pick",
    Multi = true,
    SearchThreshold = 6,
    Items = {},
    Default = {},
    Callback = function(sel)
        local set = {}
        if type(sel) == "table" then
            for k, v in pairs(sel) do
                local display = (type(k) == "string") and k or v
                if type(display) == "string" then
                    local code = displayToCode[display] or display
                    set[code] = true
                end
            end
        end
        codesSelected = set
    end,
})
local function redeemList(list)
    if not HAS_STATS then
        codesStatus:SetText("Status: can't redeem here - go to a village.")
        return
    end
    task.spawn(function()
        for i, code in ipairs(list) do
            fire(startevent, "addtwitter", code)
            codesStatus:SetText("Status: redeem " .. i .. "/" .. #list .. " (" .. code .. ")")
            task.wait(1)
        end
        codesStatus:SetText("Status: done - " .. #list .. " codes fired")
    end)
end
CodesSection:AddButton({
    Name = "Redeem All (1s each)",
    Callback = function()
        if #codesCache == 0 then codesStatus:SetText("Status: no codes cached yet"); return end
        local pure = {}
        for _, entry in ipairs(codesCache) do pure[#pure+1] = entry.code end
        redeemList(pure)
    end,
})
CodesSection:AddButton({
    Name = "Redeem Code",
    Callback = function()
        local pick = {}
        for code in pairs(codesSelected) do pick[#pick+1] = code end
        if #pick == 0 then codesStatus:SetText("Status: pick at least one code in the dropdown"); return end
        table.sort(pick)
        redeemList(pick)
    end,
})
do
    local sec = Sub.SpinCodes:AddSection({ Name = "Featured", Icon = "star", Side = 2 })
    sec:AddLabel("Item codes - one click each.")
    for _, e in ipairs({
        { name = "Get Private Server Generator", code = "RELLGIFTsc!"    },
        { name = "Get Bloodline Bag",            code = "RELLGIFTbag!"   },
        { name = "Get Ability Bag",              code = "DragonScammer!" },
    }) do
        sec:AddButton({
            Name = e.name,
            Callback = function() redeemList({ e.code }) end,
        })
    end
end
task.spawn(function()
    local list, err = fetchCodes()
    codesCache = list
    displayToCode = {}
    local items = {}
    for _, entry in ipairs(list) do
        items[#items+1] = entry.display
        displayToCode[entry.display] = entry.code
    end
    codesDropdown:Refresh(items)
    codesStatus:SetText("Status: " .. (err and ("fetch failed - " .. err) or ("cached " .. #list .. " codes")))
end)
local RollbackSection = Sub.SpinBack:AddSection({ Name = "Rollback", Icon = "rotate-ccw", Side = 1 })
if not HAS_STATS then
    RollbackSection:AddLabel("Unavailable here - this place has no player data.")
    RollbackSection:AddLabel("Go back to a village to use it.")
end
local rollbackStatus  = RollbackSection:AddLabel("Status: idle")
RollbackSection:AddLabel("Reverts your session to the last saved snapshot.")
RollbackSection:AddLabel("Auto Rollback works alongside Auto Spin - it")
RollbackSection:AddLabel("automatically rolls back when your spin attempts run")
RollbackSection:AddLabel("out, and rejoins to save the roll when a match is found.")
RollbackSection:AddButton({
    Name = "Rollback",
    Callback = function()
        if not HAS_STATS then
            rollbackStatus:SetText("Status: unavailable here - go to a village.")
            return
        end
        rollbackStatus:SetText("Status: corrupting save...")
        corruptSave()
        rollbackStatus:SetText("Status: rejoining...")
        task.wait(0.3)
        rejoin()
    end,
})
RollbackSection:AddToggle({
    Name = "Auto Rollback (with Auto Spin)",
    Flag = "shindo_auto_rollback",
    Default = false,
    Callback = function(on)
        autoRollback = on
        rollbackStatus:SetText(on and "Status: armed - will trigger on Auto Spin exit" or "Status: idle")
    end,
})
local Hook = {
    url = "", on = false,
    events = {},
    botName = "Tempo", avatar = "",
    colorMode = "Per event",
    withStats = true,
    mention = "", rareOnly = true,
    ryoStep = 250000,
    report = false, reportEvery = 30,
    queue = {}, lastSend = 0, GAP = 2, MAXQ = 20,
    sent = 0, failed = 0,
    armedAt = math.huge,
    last = {}, acc = {}, base = {},
    lbl = nil, tab = nil,
    PALETTE = {
        { name = "Blurple", v = 0x5865F2 },
        { name = "Green",   v = 0x57F287 },
        { name = "Gold",    v = 0xFEE75C },
        { name = "Red",     v = 0xED4245 },
        { name = "Purple",  v = 0x9B59B6 },
        { name = "Orange",  v = 0xE67E22 },
        { name = "Teal",    v = 0x1ABC9C },
        { name = "Pink",    v = 0xEB459E },
    },
    TINT = {
        unlock = 0x9B59B6, level = 0x57F287, prestige = 0xFEE75C,
        roll   = 0x1ABC9C, spins = 0xE67E22, cash  = 0x2ECC71,
        rell   = 0xEB459E, bounty = 0xED4245, report = 0x5865F2,
    },
    RARE = { unlock = true, prestige = true, roll = true },
}
function Hook.req()
    return (syn and syn.request) or (http and http.request) or http_request or request
end
function Hook.ok(u)
    return type(u) == "string"
        and u:match("^https://[%w%.]*discord[%w%.]*%.com/api/webhooks/%d+/[%w%-_]+") ~= nil
end
function Hook.setStatus(txt)
    if Hook.lbl then pcall(function() Hook.lbl:SetText("Status: " .. txt) end) end
end
function Hook.arm()
    Hook.armedAt = tick() + 5
    Hook.base = Hook.snap()
    Hook.baseAt = tick()
    table.clear(Hook.acc)
end
function Hook.live()
    return Hook.on and Hook.ok(Hook.url) and tick() > Hook.armedAt and alive()
end
function Hook.num(folder, child)
    local ok, v = pcall(function()
        local st = LocalPlayer.statz
        local n = folder and st[folder][child] or st[child]
        return tonumber(n.Value) or 0
    end)
    return ok and v or 0
end
function Hook.snap()
    return {
        lvl   = Hook.num("lvl", "lvl"),
        spins = Hook.num(nil, "spins"),
        cash  = Hook.num(nil, "cash"),
        rell  = Hook.num(nil, "rellcoin"),
        unlocks = (function()
            local ok, n = pcall(function() return #LocalPlayer.statz.unlocked:GetChildren() end)
            return ok and n or 0
        end)(),
    }
end
function Hook.comma(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (out:gsub("^,", ""))
end
function Hook.push(payload)
    if #Hook.queue >= Hook.MAXQ then table.remove(Hook.queue, 1) end
    Hook.queue[#Hook.queue + 1] = payload
end
function Hook.send(payload)
    local req = Hook.req()
    if not req then
        Hook.failed = Hook.failed + 1
        Hook.setStatus("this executor has no HTTP request function.")
        return
    end
    local ok, res = pcall(req, {
        Url = Hook.url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = game:GetService("HttpService"):JSONEncode(payload),
    })
    local code = ok and res and (res.StatusCode or res.status_code)
    if ok and code and code >= 200 and code < 300 then
        Hook.sent = Hook.sent + 1
        Hook.setStatus(("%d sent, %d failed"):format(Hook.sent, Hook.failed))
    else
        Hook.failed = Hook.failed + 1
        Hook.setStatus(("HTTP %s - %d sent, %d failed")
            :format(tostring(code or "no reply"), Hook.sent, Hook.failed))
    end
end
function Hook.embed(kind, title, desc, fields)
    local color = Hook.TINT[kind] or 0x5865F2
    if Hook.colorMode ~= "Per event" then
        for _, c in ipairs(Hook.PALETTE) do
            if c.name == Hook.colorMode then color = c.v break end
        end
    end
    local e = {
        title = title,
        description = desc,
        color = color,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        author = {
            name = ("%s (@%s)"):format(LocalPlayer.DisplayName, LocalPlayer.Name),
            icon_url = ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png")
                :format(LocalPlayer.UserId),
        },
        footer = { text = "Tempo - Shindo Life" },
    }
    if fields and #fields > 0 then e.fields = fields end
    if Hook.withStats then
        e.fields = e.fields or {}
        local s = Hook.snap()
        local pres = ""
        pcall(function()
            pres = ("%s%s"):format(tostring(LocalPlayer.statz.prestige.rank.Value),
                tostring(LocalPlayer.statz.prestige.number.Value))
        end)
        e.fields[#e.fields + 1] = { name = "Level",  value = tostring(s.lvl),        inline = true }
        e.fields[#e.fields + 1] = { name = "Rank",   value = pres ~= "" and pres or " - ", inline = true }
        e.fields[#e.fields + 1] = { name = "Spins",  value = tostring(s.spins),      inline = true }
        e.fields[#e.fields + 1] = { name = "Ryo",    value = Hook.comma(s.cash),     inline = true }
    end
    return e
end
function Hook.fire(kind, title, desc, fields)
    if not Hook.live() then return end
    if not Hook.events[kind] then return end
    local body = { embeds = { Hook.embed(kind, title, desc, fields) } }
    if Hook.botName ~= "" then body.username = Hook.botName end
    if Hook.avatar ~= "" then body.avatar_url = Hook.avatar end
    if Hook.mention ~= "" and (not Hook.rareOnly or Hook.RARE[kind]) then
        local m = Hook.mention
        if not (m:sub(1, 1) == "<" or m:sub(1, 1) == "@") then m = "<@" .. m .. ">" end
        body.content = m
    end
    Hook.push(body)
end
function Hook.watchNum(inst, kind, label, step, fmt)
    if not inst then return end
    Hook.last[kind] = tonumber(inst.Value) or 0
    Library:Connect(inst:GetPropertyChangedSignal("Value"), function()
        local now = tonumber(inst.Value) or 0
        local delta = now - (Hook.last[kind] or now)
        Hook.last[kind] = now
        if delta <= 0 then return end
        Hook.acc[kind] = (Hook.acc[kind] or 0) + delta
        if Hook.acc[kind] < (step or 1) then return end
        local total = Hook.acc[kind]
        Hook.acc[kind] = 0
        Hook.fire(kind, label, (fmt or "+%s (now %s)")
            :format(Hook.comma(total), Hook.comma(now)))
    end)
end
function Hook.watch()
    local st = LocalPlayer:FindFirstChild("statz")
    if not st then return end
    local lvl = st:FindFirstChild("lvl")
    lvl = lvl and lvl:FindFirstChild("lvl")
    if lvl then
        Hook.last.level = tonumber(lvl.Value) or 0
        Library:Connect(lvl:GetPropertyChangedSignal("Value"), function()
            local now = tonumber(lvl.Value) or 0
            local was = Hook.last.level or now
            Hook.last.level = now
            if now <= was then return end
            Hook.fire("level", "Level up", ("**%d** - **%d**"):format(was, now))
        end)
    end
    local pres = st:FindFirstChild("prestige")
    if pres then
        for _, key in ipairs({ "rank", "number" }) do
            local v = pres:FindFirstChild(key)
            if v then
                Hook.last["pres_" .. key] = tostring(v.Value)
                Library:Connect(v:GetPropertyChangedSignal("Value"), function()
                    local now = tostring(v.Value)
                    local was = Hook.last["pres_" .. key]
                    Hook.last["pres_" .. key] = now
                    if now == was then return end
                    Hook.fire("prestige", "Prestige",
                        ("%s: **%s** - **%s**"):format(key, tostring(was), now))
                end)
            end
        end
    end
    local unl = st:FindFirstChild("unlocked")
    if unl then
        Library:Connect(unl.ChildAdded, function(c)
            local nm = tostring(c.Name)
            local pretty = nm:gsub("^BOSSDROP", ""):gsub("scroll$", "")
            Hook.fire("unlock", "New unlock",
                ("**%s**"):format(pretty ~= "" and pretty or nm))
        end)
    end
    local main = st:FindFirstChild("main")
    if main then
        for i = 1, 4 do
            for _, pair in ipairs({ { "kg", "Bloodline" }, { "element", "Element" } }) do
                local v = main:FindFirstChild(pair[1] .. i)
                if v then
                    local key = pair[1] .. i
                    Hook.last[key] = tostring(v.Value)
                    Library:Connect(v:GetPropertyChangedSignal("Value"), function()
                        local now = tostring(v.Value)
                        local was = Hook.last[key]
                        Hook.last[key] = now
                        if now == was or now == "" then return end
                        Hook.fire("roll", "Rolled " .. pair[2] .. " " .. i,
                            ("**%s**%s"):format(now,
                                (was and was ~= "") and (" (was " .. was .. ")") or ""))
                    end)
                end
            end
        end
    end
    Hook.watchNum(st:FindFirstChild("spins"),    "spins",  "Spins",     1, "+%s (now %s)")
    Hook.watchNum(st:FindFirstChild("cash"),     "cash",   "Ryo",       Hook.ryoStep, "+%s (now %s)")
    Hook.watchNum(st:FindFirstChild("rellcoin"), "rell",   "RellCoins", 1, "+%s (now %s)")
    Hook.watchNum(st:FindFirstChild("bounty"),   "bounty", "Bounty",    1, "+%s (now %s)")
end
task.spawn(function()
    while alive() do
        if #Hook.queue > 0 and tick() - Hook.lastSend >= Hook.GAP then
            Hook.lastSend = tick()
            Hook.send(table.remove(Hook.queue, 1))
        end
        task.wait(0.25)
    end
end)
task.spawn(function()
    while alive() do
        task.wait(30)
        if Hook.report and Hook.live() and Hook.base then
            local mins = (tick() - (Hook.baseAt or tick())) / 60
            if mins >= Hook.reportEvery then
                local now, b = Hook.snap(), Hook.base
                Hook.baseAt, Hook.base = tick(), now
                Hook.events.report = true
                Hook.fire("report", ("Session report - %dm"):format(math.floor(mins)), nil, {
                    { name = "Levels",   value = "+" .. (now.lvl - b.lvl),                 inline = true },
                    { name = "Spins",    value = "+" .. (now.spins - b.spins),             inline = true },
                    { name = "Unlocks",  value = "+" .. (now.unlocks - b.unlocks),         inline = true },
                    { name = "Ryo",      value = "+" .. Hook.comma(now.cash - b.cash),     inline = true },
                    { name = "RellCoin", value = "+" .. Hook.comma(now.rell - b.rell),     inline = true },
                })
            end
        end
    end
end)
Hook.tab = Window:AddTab({ Name = "Webhook", Icon = "webhook" })
do
    local sec = Hook.tab:AddSection({ Name = "Discord Webhook", Icon = "link", Side = 1 })
    if not HAS_STATS then
        sec:AddLabel("Unavailable here - this place has no player data.")
        sec:AddLabel("Go back to a village to use it.")
    end
    sec:AddLabel("Server Settings > Integrations > Webhooks > Copy URL")
    Hook.lbl = sec:AddLabel("Status: idle")
    sec:AddTextbox({
        Name = "Webhook URL",
        Flag = "shindo_hook_url",
        Placeholder = "https://discord.com/api/webhooks/...",
        Finished = true,
        Default = "",
        Callback = function(v)
            Hook.url = tostring(v or "")
            if Hook.url == "" then
                Hook.setStatus("idle")
            elseif Hook.ok(Hook.url) then
                Hook.setStatus("URL looks good - turn it on.")
            else
                Hook.setStatus("that is not a webhook URL.")
            end
        end,
    })
    sec:AddLabel("Saved in your config - don't share that file.")
    sec:AddToggle({
        Name = "Enabled",
        Flag = "shindo_hook_on",
        Default = false,
        Callback = function(on)
            Hook.on = on
            if not on then
                Hook.setStatus("off")
                return
            end
            if not Hook.ok(Hook.url) then
                Hook.setStatus("paste a valid webhook URL first.")
                return
            end
            Hook.arm()
            Hook.setStatus("on - arming for 5s")
        end,
    })
    sec:AddButton({
        Name = "Send Test",
        Callback = function()
            if not Hook.ok(Hook.url) then
                Hook.setStatus("paste a valid webhook URL first.")
                return
            end
            local body = { embeds = { Hook.embed("report", "Test message",
                "If you can read this, the webhook works.") } }
            if Hook.botName ~= "" then body.username = Hook.botName end
            if Hook.avatar ~= "" then body.avatar_url = Hook.avatar end
            Hook.setStatus("sending...")
            Hook.push(body)
        end,
    })
    sec = Hook.tab:AddSection({ Name = "Events", Icon = "bell", Side = 2 })
    sec:AddLabel("Read straight from your save - works with no farm on.")
    for _, e in ipairs({
        { key = "unlock",   name = "New Scroll / Unlock",     def = true  },
        { key = "prestige", name = "Prestige / Rank",         def = true  },
        { key = "level",    name = "Level Up",                def = true  },
        { key = "roll",     name = "Bloodline & Element Roll", def = true },
        { key = "spins",    name = "Spins Gained",            def = false },
        { key = "cash",     name = "Ryo Gained",              def = false },
        { key = "rell",     name = "RellCoins Gained",        def = false },
        { key = "bounty",   name = "Bounty Gained",           def = false },
    }) do
        sec:AddToggle({
            Name = e.name,
            Flag = "shindo_hook_ev_" .. e.key,
            Default = e.def,
            Callback = function(on) Hook.events[e.key] = on end,
        })
    end
    sec:AddSlider({
        Name = "Ryo Step (only report gains of at least this)",
        Flag = "shindo_hook_ryostep",
        Min = 10000, Max = 5000000, Default = 250000, Decimals = 10000,
        Callback = function(v) Hook.ryoStep = v end,
    })
    sec = Hook.tab:AddSection({ Name = "Session Report", Icon = "clock", Side = 2 })
    sec:AddLabel("A recap on a timer, so you know it's still alive.")
    sec:AddToggle({
        Name = "Send Session Report",
        Flag = "shindo_hook_report",
        Default = false,
        Callback = function(on)
            Hook.report = on
            if on then Hook.base, Hook.baseAt = Hook.snap(), tick() end
        end,
    })
    sec:AddSlider({
        Name = "Every (minutes)",
        Flag = "shindo_hook_reportevery",
        Min = 5, Max = 240, Default = 30, Decimals = 5,
        Callback = function(v) Hook.reportEvery = v end,
    })
    sec = Hook.tab:AddSection({ Name = "Appearance", Icon = "palette", Side = 1 })
    sec:AddTextbox({
        Name = "Bot Name",
        Flag = "shindo_hook_botname",
        Placeholder = "Tempo",
        Finished = true,
        Default = "Tempo",
        Callback = function(v) Hook.botName = tostring(v or "") end,
    })
    sec:AddTextbox({
        Name = "Avatar URL",
        Flag = "shindo_hook_avatar",
        Placeholder = "https://... (optional)",
        Finished = true,
        Default = "",
        Callback = function(v) Hook.avatar = tostring(v or "") end,
    })
    do
        local colors = { "Per event" }
        for _, c in ipairs(Hook.PALETTE) do colors[#colors + 1] = c.name end
        sec:AddDropdown({
            Name = "Embed Color",
            Flag = "shindo_hook_color",
            Multi = false,
            Items = colors,
            Default = "Per event",
            Callback = function(v)
                if type(v) == "string" then Hook.colorMode = v end
            end,
        })
    end
    sec:AddToggle({
        Name = "Include Stats Block",
        Flag = "shindo_hook_stats",
        Default = true,
        Callback = function(on) Hook.withStats = on end,
    })
    sec:AddTextbox({
        Name = "Mention (your Discord ID)",
        Flag = "shindo_hook_mention",
        Placeholder = "123456789 or @everyone",
        Finished = true,
        Default = "",
        Callback = function(v) Hook.mention = tostring(v or "") end,
    })
    sec:AddToggle({
        Name = "Mention Only On Rare (unlock, prestige, roll)",
        Flag = "shindo_hook_rareonly",
        Default = true,
        Callback = function(on) Hook.rareOnly = on end,
    })
end
Hook.watch()
do
    local Workspace           = game:GetService("Workspace")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local function notify(title, desc)
        Library:Notification(title, desc, 6)
    end
    local function combatFire(a1, a2, a3)
        local ch = LocalPlayer.Character
        local update = ch and ch:FindFirstChild("combat") and ch.combat:FindFirstChild("update")
        if update then fire(update, a1, a2, a3) end
    end
    local conns = {}
    local function track(conn)
        conns[#conns + 1] = conn
        return conn
    end
    local function spawnLoop(fn)
        task.spawn(function()
            xpcall(fn, function(e)
                return tostring(e) .. "\n" .. debug.traceback()
            end)
        end)
    end
    local state = {
        flags = {
            autoLevel     = false,
            autoQuest     = false,
            autoBoss      = false,
            useSkills     = false,
            autoAttack    = false,
            autoChi       = false,
            autoTail      = false,
            autoEventBoss = false,
            autoJin       = false,
            semiKill      = false,
            spiritNoCd    = false,
            mdReset       = false,
            camLook       = false,
            throwSword    = false,
            autoRank      = false,
            autoHealth    = false,
            autoNinjutsu  = false,
            autoTaijutsu  = false,
            autoChakra    = false,
            scrollFarm    = false,
            scrollSmartHop= false,
            scrollSkipOwned = false,
            autoDungeon   = false,
            voidFarm      = false,
            voidAuto      = false,
            autoDungeonStart = false,
            dungeonAutoDiff = false,
            autoClaim     = false,
            noclip        = false,
            speed         = false,
            infJump       = false,
            antiGrip      = false,
            antiRagdoll   = false,
            infStamina    = false,
            questRush     = false,
            questJump     = false,
            questPunch    = false,
            questChi      = false,
            playerLock    = false,
            fly           = false,
            invisicam     = false,
            fullbright    = false,
            noFog         = false,
            fpsBoost      = false,
        },
        cfg = {
            farmWait = 0.08,
            hitDelay = 0.08,
            range = 6.5,
            farmMode = "Under",
            chiMin = 40,
            selectedMob = nil,
            stuckSeconds = 12,
            skillsNeedTarget = true,
            swordDelay   = 0.1,
            safeHeight   = 300,
            walkSpeed     = 50,
            jumpPower     = 50,
            lockDistance  = 4,
            flySpeed      = 80,
            fov           = 0,
            scrollWait    = 12,
            voidWaitDepth = 300,
            voidClear     = 25,
            voidRadius    = 800,
            voidRise      = 0.45,
            voidPullHold  = 6,
            voidWave      = 3,
            voidMdMin     = 60,
            voidDodge     = 60,
            hopMinPlayers = 4,
            hopMaxPlayers = 18,
        },
        lastHit = 0,
        lockTarget = nil,
        lockLog = nil,
        lockPlayer = nil,
        safeAnchor = nil,
        voidAnchor = nil,
        arenaFloorY = nil,
        arenaUnderY = nil,
        arenaSpotX = nil, arenaSpotZ = nil,
        farmMoving = false,
        spiritBusy = false,
        noclipOn   = false,
        freeUntil  = 0,
        tpWarn = 0,
        rotLocked = false,
        chargingChi = false,
        lastHop = 0,
        lastScrollSeen = tick(),
        flyBV = nil,
        flyBG = nil,
        flyKeys = { w = false, a = false, s = false, d = false, up = false, down = false },
        savedWaypoint = nil,
        lightingSnapshot = nil,
        session = { start = tick(), startCash = 0, startSpins = 0, startLvl = 0, claims = 0 },
    }
    local function root()
        local ch = LocalPlayer.Character
        return ch and ch:FindFirstChild("HumanoidRootPart")
    end
    local function hum()
        local ch = LocalPlayer.Character
        return ch and ch:FindFirstChildWhichIsA("Humanoid")
    end
    local Phys = {}
    function Phys.held()
        return tick() < (state.freeUntil or 0)
    end
    function Phys.freeze(h)
        if Phys.held() then return end
        h = h or hum()
        if not h then return end
        pcall(function() h:ChangeState(11) end)
    end
    function Phys.unstick(secs)
        state.freeUntil = tick() + (secs or 1.5)
        local h = hum()
        if not h then return end
        pcall(function()
            h.PlatformStand = false
            h:ChangeState(Enum.HumanoidStateType.GettingUp)
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end
    local function tpTo(cf)
        if state.spiritBusy then
            local now = tick()
            if now - (state.tpWarn or 0) > 5 then
                state.tpWarn = now
                notify("Spirit Room", "Teleport held - the spirit room is setting up.")
            end
            return false
        end
        local hrp = root()
        if hrp then
            pcall(function() hrp.CFrame = cf end)
        end
        return true
    end
    local function hitOnce()
        local now = tick()
        if now - state.lastHit < state.cfg.hitDelay then return end
        state.lastHit = now
        local ch = LocalPlayer.Character
        local fn = ch and ch:FindFirstChild("combat") and ch.combat:FindFirstChild("functions")
        local m1 = fn and fn:FindFirstChild("mouse1")
        combatFire("mouse1", true)
        if m1 then pcall(function() m1.Value = true end) end
        combatFire("mouse1", false)
        if m1 then pcall(function() m1.Value = false end) end
    end
    local function missionGui()
        local main = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local ingame = main and main:FindFirstChild("ingame")
        return ingame and ingame:FindFirstChild("Missionstory")
    end
    local function missionVisible()
        local m = missionGui()
        return m and m.Visible
    end
    local function missionText()
        local m = missionGui()
        local bg = m and m:FindFirstChild("bg")
        local name = bg and bg:FindFirstChild("name")
        return name and name.Text or ""
    end
    local GREEN = "http://www.roblox.com/asset/?id=5459241648"
    local RED   = "http://www.roblox.com/asset/?id=5459241799"
    local SIM_R = 1e9
    local lastSimBoost = 0
    pcall(function() settings().Physics.AllowSleep = false end)
    local function boostSim()
        local now = tick()
        if now - lastSimBoost < 0.35 then return end
        lastSimBoost = now
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(LocalPlayer, "SimulationRadius", SIM_R)
                sethiddenproperty(LocalPlayer, "MaxSimulationRadius", SIM_R)
            end
            if setsimulationradius then
                setsimulationradius(SIM_R, SIM_R)
            end
            pcall(function() LocalPlayer.SimulationRadius = SIM_R end)
        end)
        local ch = LocalPlayer.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.RootPriority = 127
                if sethiddenproperty then
                    sethiddenproperty(hrp, "NetworkIsSleeping", false)
                end
            end)
        end
    end
    boostSim()
    track(RunService.Heartbeat:Connect(function()
        if not alive() then return end
        boostSim()
    end))
    local Arena = { at = 0, on = false, said = false }
    function Arena.staging()
        local now = tick()
        if now - Arena.at < 0.5 then return Arena.on end
        Arena.at = now
        Arena.on = false
        local map = Workspace:FindFirstChild("map")
        local plat = map and map:FindFirstChild("Model")
        local hrp = plat and plat:IsA("Model") and root()
        if hrp then
            local ok, cf, size = pcall(plat.GetBoundingBox, plat)
            if ok and cf and size then
                local p = cf:PointToObjectSpace(hrp.Position)
                Arena.on = math.abs(p.X) <= size.X / 2 + 20
                    and math.abs(p.Z) <= size.Z / 2 + 20
            end
        end
        if Arena.on then
            local folder = Workspace:FindFirstChild("npc")
            for _, v in ipairs(folder and folder:GetChildren() or {}) do
                local h = v:FindFirstChild("npctype")
                    and v:FindFirstChildWhichIsA("Humanoid")
                if h and h.Health > 0 then
                    Arena.on = false
                    break
                end
            end
        end
        if Arena.on then
            state.arenaFloorY = nil
            state.arenaUnderY = nil
            state.arenaSpotX, state.arenaSpotZ = nil, nil
            state.voidAnchor = nil
        end
        return Arena.on
    end
    local function wantNoclip()
        local f = state.flags
        local dungeon = f.autoDungeon and not Arena.staging()
        return f.autoLevel or f.autoQuest or f.autoBoss or f.autoTail
            or f.autoEventBoss or f.autoJin
            or f.noclip or f.scrollFarm or dungeon
            or f.playerLock
            or (f.voidFarm and dungeon)
    end
    local function wantSafeHold()
        local f = state.flags
        if f.voidFarm and f.autoDungeon then return false end
        return f.autoLevel or f.autoQuest or f.autoBoss or f.autoTail
            or f.autoEventBoss or f.autoJin or f.autoDungeon
    end
    local charParts = {}
    _dzEnv.DzShindo_NoClipped = _dzEnv.DzShindo_NoClipped or {}
    local charOff = _dzEnv.DzShindo_NoClipped
    local lastNoclip = 0
    local function noclipPart(p)
        if not p:IsA("BasePart") then return end
        charParts[#charParts + 1] = p
        if wantNoclip() and p.CanCollide then
            charOff[p] = true
            pcall(function() p.CanCollide = false end)
        end
    end
    local function refreshCharParts(ch)
        table.clear(charParts)
        ch = ch or LocalPlayer.Character
        if not ch then return end
        for _, p in ipairs(ch:GetDescendants()) do noclipPart(p) end
    end
    local function forceCharNoCollide()
        if not (state.lockTarget or state.lockLog or state.lockPlayer) then
            local now = tick()
            if now - lastNoclip < 0.12 then return end
            lastNoclip = now
        end
        if #charParts == 0 then refreshCharParts() end
        for i = 1, #charParts do
            local p = charParts[i]
            if p and p.Parent and p.CanCollide then
                charOff[p] = true
                p.CanCollide = false
            end
        end
    end
    local function npcFalling(model)
        local hrp = model and model:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local slab = state.arenaUnderY
        if slab and hrp.Position.Y < slab - 10 then return true end
        local ok, vel = pcall(function() return hrp.AssemblyLinearVelocity end)
        return ok and vel.Y < -200
    end
    local function npcGone(model)
        if not model or not model.Parent then return true end
        if not model:FindFirstChild("HumanoidRootPart") then return true end
        local head = model:FindFirstChild("Head")
        if head and head.Position.Y <= -1000 then return true end
        if npcFalling(model) then return true end
        return false
    end
    local function isCompanion(v)
        if not v then return false end
        return v:FindFirstChild("companion") ~= nil
            or v:FindFirstChild("owner") ~= nil
    end
    local Zombie = {
        since = setmetatable({}, { __mode = "k" }),
        AFTER = 1.5,
    }
    function Zombie.track(v)
        local h = v and v:FindFirstChildWhichIsA("Humanoid")
        if not h then return end
        if h.Health <= 0 then
            if not Zombie.since[v] then Zombie.since[v] = tick() end
        else
            Zombie.since[v] = nil
        end
    end
    function Zombie.is(v)
        if not v or not v.Parent then return false end
        local h = v:FindFirstChildWhichIsA("Humanoid")
        if not h or h.Health > 0 then return false end
        local t = Zombie.since[v]
        return t ~= nil and (tick() - t) >= Zombie.AFTER
    end
    function Zombie.targetable(v)
        local h = v and v:FindFirstChildWhichIsA("Humanoid")
        if not h then return false end
        if h.Health > 0 then return true end
        return Zombie.is(v)
    end
    local function charReady()
        local ch = LocalPlayer.Character
        if not ch then return false end
        local h = ch:FindFirstChildWhichIsA("Humanoid")
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        return (h and hrp and h.Health > 0) and true or false
    end
    local function faceLock(h, on)
        if not h then return end
        if on then
            state.rotLocked = true
            if h.AutoRotate then
                pcall(function() h.AutoRotate = false end)
            end
        elseif state.rotLocked then
            state.rotLocked = false
            if not h.AutoRotate then
                pcall(function() h.AutoRotate = true end)
            end
        end
    end
    local function releaseFacing()
        local h = hum()
        if h and state.rotLocked then
            state.rotLocked = false
            pcall(function() h.AutoRotate = true end)
        end
    end
    local guard = { fail = {}, cool = {}, said = {} }
    local function cooling(name) return (guard.cool[name] or 0) > tick() end
    local function coolFor(name, secs) guard.cool[name] = tick() + secs end
    local function okStep(name)
        guard.fail[name] = 0
        guard.said[name] = nil
    end
    local function failStep(name, limit, secs, msg)
        local n = (guard.fail[name] or 0) + 1
        guard.fail[name] = n
        if n >= limit then
            guard.fail[name] = 0
            coolFor(name, secs)
            if msg and not guard.said[name] then
                guard.said[name] = true
                notify("Failsafe", msg)
            end
            return true
        end
        return false
    end
    local Turn = {
        owner = nil, deadline = 0, sliceEnd = 0, last = nil,
        SLICE = 20,
        ORDER = { "scrollFarm", "autoLevel", "autoQuest", "autoBoss", "autoTail",
                  "autoEventBoss", "autoJin", "autoDungeon" },
        RANK = {},
        idleUntil = {},
        IDLE = 15,
    }
    Turn.PICKS = {
        { label = "Event Boss Sweep", flag = "autoEventBoss" },
        { label = "Boss Farm",        flag = "autoBoss"      },
        { label = "Tail Beast",       flag = "autoTail"      },
        { label = "Jin Farm",         flag = "autoJin"       },
        { label = "Scroll Farm",      flag = "scrollFarm"    },
        { label = "Quests",           flag = "autoQuest"     },
        { label = "Level (Logs)",     flag = "autoLevel"     },
    }
    function Turn.setOrder(picked)
        local byLabel = {}
        for _, e in ipairs(Turn.PICKS) do byLabel[e.label] = e.flag end
        local rank, n = {}, 0
        local function put(flag)
            if flag and not rank[flag] then
                n = n + 1
                rank[flag] = n
            end
        end
        if type(picked) == "table" then
            for _, label in ipairs(picked) do put(byLabel[label]) end
            for _, e in ipairs(Turn.PICKS) do
                if picked[e.label] then put(e.flag) end
            end
        end
        Turn.RANK = rank
        table.clear(Turn.idleUntil)
    end
    function Turn.blocked(name)
        local mine = Turn.RANK[name]
        if not mine then return false end
        for other, rank in pairs(Turn.RANK) do
            if rank < mine and state.flags[other]
                and tick() >= (Turn.idleUntil[other] or 0) then
                return true
            end
        end
        return false
    end
    function Turn.step(name, status)
        if status == "busy" then
            Turn.idleUntil[name] = nil
        else
            Turn.idleUntil[name] = tick() + Turn.IDLE
            Turn.release(name)
        end
    end
    function Turn.wanted(name)
        for _, other in ipairs(Turn.ORDER) do
            if other ~= name and state.flags[other] and not Turn.blocked(other) then
                return true
            end
        end
        return false
    end
    function Turn.free()
        if not Turn.owner then return true end
        if not state.flags[Turn.owner] or tick() > Turn.deadline then
            Turn.owner = nil
            return true
        end
        return false
    end
    function Turn.sliceOver(name)
        if Turn.owner ~= name then return false end
        return tick() > Turn.sliceEnd and Turn.wanted(name)
    end
    function Turn.claim(name)
        if Turn.owner == name then
            Turn.deadline = tick() + 600
            return true
        end
        if not Turn.free() then return false end
        if Turn.blocked(name) then return false end
        if missionVisible() and Turn.last and Turn.last ~= name
            and state.flags[Turn.last] then
            return false
        end
        if Turn.last == name and not missionVisible() and Turn.wanted(name) then
            return false
        end
        Turn.owner = name
        Turn.deadline = tick() + 600
        Turn.sliceEnd = tick() + Turn.SLICE
        return true
    end
    function Turn.release(name)
        if Turn.owner ~= name then return end
        Turn.owner = nil
        Turn.last = name
        state.lockTarget = nil
        state.lockLog = nil
    end
    function Turn.run(name, fn)
        if not Turn.claim(name) then
            task.wait(0.2)
            return
        end
        pcall(fn)
        if Turn.sliceOver(name) then Turn.release(name) end
    end
    local function ownsPart(part)
        if not part or not part.Parent then return false end
        if isnetworkowner then
            local ok, res = pcall(isnetworkowner, part)
            if ok and res == true then return true end
        end
        local ok2, age = pcall(function() return part.ReceiveAge end)
        if ok2 and age == 0 then return true end
        local ok3, owner = pcall(function()
            return part.GetNetworkOwner and part:GetNetworkOwner()
        end)
        return ok3 and owner == LocalPlayer
    end
    local function ownsNpc(model)
        local hrp = model and model:FindFirstChild("HumanoidRootPart")
        return ownsPart(hrp)
    end
    local function prepTarget(model)
        if not model or not model.Parent then return false end
        boostSim()
        local thrp = model:FindFirstChild("HumanoidRootPart")
        if not thrp then return false end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(thrp, "NetworkIsSleeping", false)
            end
            thrp.AssemblyLinearVelocity = thrp.AssemblyLinearVelocity
        end)
        for _, name in ipairs({ "Torso", "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" }) do
            local p = model:FindFirstChild(name)
            if p and p:IsA("BasePart") then
                pcall(function()
                    if sethiddenproperty then
                        sethiddenproperty(p, "NetworkIsSleeping", false)
                    end
                end)
            end
        end
        return ownsNpc(model)
    end
    local Skills = {
        SLOTS = { "r", "t", "y", "f", "g", "h", "v", "b", "n" },
        picks = {}, names = {}, dd = nil,
        cache = {}, at = 0,
    }
    function Skills.wanted(slot)
        if next(Skills.picks) == nil then return true end
        return Skills.picks[slot] == true
    end
    function Skills.real(npcName)
        local aj = ReplicatedStorage:FindFirstChild("alljutsu")
        if not aj or npcName == "" then return nil end
        local directCall = aj:FindFirstChild(npcName)
            or (aj:FindFirstChild("modes") and aj.modes:FindFirstChild(npcName))
        local r = directCall and directCall:FindFirstChild("REALNAME")
        if r then return tostring(r.Value) end
        for _, pasta in ipairs(aj:GetChildren()) do
            local j = pasta:FindFirstChild(npcName)
            local rn = j and j:FindFirstChild("REALNAME")
            if rn then return tostring(rn.Value) end
        end
        return nil
    end
    function Skills.items()
        local items = {}
        Skills.names = {}
        local sz = LocalPlayer:FindFirstChild("statz")
        local keys = sz and sz:FindFirstChild("keys")
        for _, slot in ipairs(Skills.SLOTS) do
            local v = keys and keys:FindFirstChild(slot)
            local npcName = v and tostring(v.Value) or ""
            if npcName ~= "" then
                local label = slot:upper() .. " - " .. (Skills.real(npcName) or npcName)
                items[#items + 1] = label
                Skills.names[label] = slot
            end
        end
        return items
    end
    function Skills.active()
        local now = tick()
        if now - Skills.at < 2 then return Skills.cache end
        Skills.at = now
        local out = {}
        local sz = LocalPlayer:FindFirstChild("statz")
        local keys = sz and sz:FindFirstChild("keys")
        for _, slot in ipairs(Skills.SLOTS) do
            local v = keys and keys:FindFirstChild(slot)
            if v and tostring(v.Value) ~= "" and Skills.wanted(slot) then
                out[#out + 1] = slot
            end
        end
        Skills.cache = out
        return out
    end
    local function getChiPercent()
        local pct
        pcall(function()
            local ch = LocalPlayer.Character
            local combat = ch and ch:FindFirstChild("combat")
            local st = combat and combat:FindFirstChild("stamina")
            if st and st.MaxValue and st.MaxValue > 0 then
                pct = (st.Value / st.MaxValue) * 100
            end
        end)
        if pct then return pct end
        pcall(function()
            local main = LocalPlayer.PlayerGui:FindFirstChild("Main")
            local label = main
                and (
                    (main:FindFirstChild("ingame") and main.ingame:FindFirstChild("Bar") and main.ingame.Bar:FindFirstChild("cha"))
                    or (main:FindFirstChild("ingamearena") and main.ingamearena:FindFirstChild("Bar") and main.ingamearena.Bar:FindFirstChild("cha"))
                )
            if label and label.Text then
                local a, b = label.Text:match("CHI:%s*(%d+)%s*/%s*(%d+)")
                if a and b and tonumber(b) and tonumber(b) > 0 then
                    pct = (tonumber(a) / tonumber(b)) * 100
                end
            end
        end)
        return pct or 100
    end
    local function pressSkill(combat, key)
        pcall(function() fire(combat, "key", key) end)
        pcall(function()
            local fn = combat.Parent and combat.Parent:FindFirstChild("functions")
            if fn and fn:FindFirstChild("key") then
                fn.key.Value = key
            end
        end)
        pcall(function()
            local code = Enum.KeyCode[string.upper(key)]
            if code then
                VirtualInputManager:SendKeyEvent(true, code, false, game)
                VirtualInputManager:SendKeyEvent(false, code, false, game)
            end
        end)
        pcall(function() fire(combat, "key", key .. "end") end)
    end
    local function punchOnce(combat)
        local fn = combat.Parent and combat.Parent:FindFirstChild("functions")
        local m1 = fn and fn:FindFirstChild("mouse1")
        pcall(function() fire(combat, "mouse1", true) end)
        if m1 then pcall(function() m1.Value = true end) end
        task.wait(0.1)
        pcall(function() fire(combat, "mouse1", false) end)
        if m1 then pcall(function() m1.Value = false end) end
    end
    local function manageChi(combat)
        if not state.flags.autoChi then
            if state.chargingChi then
                state.chargingChi = false
                pcall(function() fire(combat, "key", "cend") end)
            end
            return false
        end
        local chi = getChiPercent()
        local minPct = state.cfg.chiMin or 40
        local stopPct = math.min(minPct + 20, 95)
        if state.chargingChi then
            if chi < stopPct then
                pcall(function() fire(combat, "key", "c") end)
                return true
            end
            state.chargingChi = false
            pcall(function() fire(combat, "key", "cend") end)
            return false
        end
        if chi < minPct then
            state.chargingChi = true
            pcall(function() fire(combat, "key", "c") end)
            return true
        end
        return false
    end
    local function releaseChi()
        if not state.chargingChi then return end
        state.chargingChi = false
        combatFire("key", "cend")
    end
    local function finishArmed()
        return state.flags.semiKill
    end
    local function tryFinishNpc(model)
        if not model or not finishArmed() then return false end
        prepTarget(model)
        local h = model:FindFirstChildWhichIsA("Humanoid")
        if h and h.Health > 0 and h.Health < h.MaxHealth then
            h.Health = 0
            if h.Health <= 0 then return true end
        elseif h and Zombie.is(model) then
            pcall(function() h.Health = 0 end)
        end
        return false
    end
    local function onLiveTarget()
        local t = state.lockTarget
        if t and t.Parent then return true end
        local l = state.lockLog
        return (l and l.Parent) and true or false
    end
    local function skillsOk()
        if not state.flags.useSkills then return false end
        if state.cfg.skillsNeedTarget and not onLiveTarget() then return false end
        return true
    end
    local function inputBlocked(combat)
        local c = combat and combat.Parent
        if not c then return false end
        local dk = c:FindFirstChild("disablekeys")
        return (dk and dk.Value) and true or false
    end
    local function logFarmCFrame(logNpc)
        local hrp = logNpc and logNpc:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        return hrp.CFrame * CFrame.new(0, -(state.cfg.range or 6.5), 0)
    end
    local function calcFarmCF(targetHRP)
        if not targetHRP then return nil end
        local mp = targetHRP.Position
        local mode = state.cfg.farmMode or "Under"
        local r = state.cfg.range or 6.5
        local pos
        if mode == "Above" then
            pos = Vector3.new(mp.X, mp.Y + r, mp.Z)
        elseif mode == "Under" or mode == "Below" then
            pos = Vector3.new(mp.X, mp.Y - r, mp.Z)
        elseif mode == "Front" or mode == "In Front" then
            pos = mp + targetHRP.CFrame.LookVector * r
        else
            pos = mp - targetHRP.CFrame.LookVector * r
        end
        return CFrame.lookAt(pos, targetHRP.Position)
    end
    local function movementHeld() return false end
    local function setMoving(on, secs)
        state.farmMoving = on and true or false
        state.farmMoveUntil = on and (tick() + (secs or 8)) or 0
    end
    local function movingNow()
        if not state.farmMoving then return false end
        if tick() > (state.farmMoveUntil or 0) then
            state.farmMoving = false
            return false
        end
        return true
    end
    local holdBP, holdBG
    local function clearHoldBodies()
        if holdBP then
            pcall(function() holdBP:Destroy() end)
            holdBP = nil
        end
        if holdBG then
            pcall(function() holdBG:Destroy() end)
            holdBG = nil
        end
    end
    local function safeHold()
        if movingNow() then
            clearHoldBodies()
            return
        end
        local anchor = state.safeAnchor
        local hrp = anchor and root()
        if not hrp then
            clearHoldBodies()
            return
        end
        local targetCF = anchor + Vector3.new(0, state.cfg.safeHeight or 300, 0)
        pcall(function()
            hrp.CFrame = targetCF
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            if not holdBP or holdBP.Parent ~= hrp then
                holdBP = Instance.new("BodyPosition")
                holdBP.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                holdBP.P = 1e6
                holdBP.D = 1e4
                holdBP.Parent = hrp
            end
            holdBP.Position = targetCF.Position
            if not holdBG or holdBG.Parent ~= hrp then
                holdBG = Instance.new("BodyGyro")
                holdBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                holdBG.P = 1e6
                holdBG.D = 1e4
                holdBG.CFrame = targetCF
                holdBG.Parent = hrp
            else
                holdBG.CFrame = targetCF
            end
        end)
    end
    track(RunService.Stepped:Connect(function()
        if not alive() then clearHoldBodies(); return end
        if not charReady() then
            clearHoldBodies()
            releaseFacing()
            return
        end
        local h = hum()
        if state.spiritBusy then
            clearHoldBodies()
            releaseFacing()
            if wantNoclip() then
                forceCharNoCollide()
                safeHold()
            end
            return
        end
        if state.flags.voidFarm and state.flags.autoDungeon
            and not Arena.staging() then
            clearHoldBodies()
            releaseFacing()
            forceCharNoCollide()
            local anchor = state.voidAnchor
            local hrp = anchor and root()
            if hrp then
                pcall(function()
                    hrp.CFrame = anchor
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            Phys.freeze(h)
            return
        end
        if state.flags.autoLevel and state.lockLog and state.lockLog.Parent then
            clearHoldBodies()
            forceCharNoCollide()
            local cf = logFarmCFrame(state.lockLog)
            local hrp = root()
            if cf and hrp then
                state.safeAnchor = cf
                faceLock(h, true)
                hrp.CFrame = cf
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            Phys.freeze(h)
            return
        end
        if state.lockTarget and state.lockTarget.Parent then
            clearHoldBodies()
            if state.flags.semiKill then
                prepTarget(state.lockTarget)
            end
            forceCharNoCollide()
            local thrp = state.lockTarget:FindFirstChild("HumanoidRootPart")
            local hrp = root()
            if thrp and hrp then
                pcall(function()
                    local cf = calcFarmCF(thrp)
                    state.safeAnchor = cf
                    faceLock(h, true)
                    hrp.CFrame = cf
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            Phys.freeze(h)
            return
        end
        if state.flags.playerLock and state.lockPlayer and state.lockPlayer.Parent then
            clearHoldBodies()
            forceCharNoCollide()
            local thrp = state.lockPlayer:FindFirstChild("HumanoidRootPart")
            local hrp = root()
            if thrp and hrp then
                local dist = state.cfg.lockDistance or 4
                local pos = thrp.Position - thrp.CFrame.LookVector * dist
                pcall(function()
                    faceLock(h, true)
                    hrp.CFrame = CFrame.lookAt(pos, thrp.Position + Vector3.new(0, 1.5, 0))
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            return
        end
        releaseFacing()
        if wantNoclip() then
            forceCharNoCollide()
            Phys.freeze(h)
            if wantSafeHold() then
                if not state.safeAnchor then
                    local hrp = root()
                    if hrp then state.safeAnchor = hrp.CFrame end
                end
                safeHold()
            else
                clearHoldBodies()
            end
        else
            clearHoldBodies()
        end
    end))
    track(RunService.Heartbeat:Connect(function()
        if not alive() then return end
        local wants = wantNoclip()
        if wants then
            state.noclipOn = true
        elseif state.noclipOn then
            state.noclipOn = false
            pcall(function()
                for p in pairs(charOff) do
                    if p.Parent then p.CanCollide = true end
                end
                table.clear(charOff)
            end)
            Phys.unstick(1)
        end
        if state.flags.autoLevel or wants then
            Phys.freeze()
        end
        if state.flags.speed then
            local h = hum()
            if h then
                pcall(function()
                    h.WalkSpeed = state.cfg.walkSpeed
                    h.JumpPower = state.cfg.jumpPower
                end)
            end
        end
        if state.flags.antiGrip then
            local ch = LocalPlayer.Character
            local fh = ch and ch:FindFirstChild("fakehealth")
            if fh then pcall(function() fh:Destroy() end) end
        end
        if state.flags.antiRagdoll then
            local ch = LocalPlayer.Character
            local combat = ch and ch:FindFirstChild("combat")
            local rag = combat and combat:FindFirstChild("ragdoll")
            if rag and rag.Value then pcall(function() rag.Value = false end) end
            local h = hum()
            if h then
                pcall(function()
                    h.PlatformStand = false
                    h:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end
        end
        if state.flags.infStamina then
            local ch = LocalPlayer.Character
            local combat = ch and ch:FindFirstChild("combat")
            if combat then
                for _, n in ipairs({ "stamina", "stamina2" }) do
                    local s = combat:FindFirstChild(n)
                    if s then pcall(function() s.Value = s.MaxValue end) end
                end
            end
        end
    end))
    local function talkAccept(model)
        local talk = model and model:FindFirstChild("CLIENTTALK")
        if not talk then return false end
        pcall(function() fire(talk) end)
        task.wait(0.35)
        pcall(function() fire(talk, "accept") end)
        task.wait(0.35)
        return missionVisible()
    end
    local function talkAcceptNear(model)
        if talkAccept(model) then return true end
        local hrp = model and model:FindFirstChild("HumanoidRootPart")
        if hrp then
            setMoving(true, 5)
            tpTo(hrp.CFrame * CFrame.new(0, -6, 0))
            task.wait(0.25)
            local ok = talkAccept(model)
            setMoving(false)
            return ok
        end
        return false
    end
    local function prepareLog(logNpc)
        if not logNpc then return end
        forceCharNoCollide()
    end
    local function findLog()
        local folder = Workspace:FindFirstChild("npc")
        if not folder then return nil end
        local best, bestDist
        local hrp = root()
        local origin = hrp and hrp.Position
        for _, v in ipairs(folder:GetChildren()) do
            if v.Name == "logtraining" and v:FindFirstChild("HumanoidRootPart") then
                if not origin then return v end
                local d = (v.HumanoidRootPart.Position - origin).Magnitude
                if not bestDist or d < bestDist then
                    best, bestDist = v, d
                end
            end
        end
        return best
    end
    local function acceptDefeatMission()
        local folder = Workspace:FindFirstChild("missiongivers")
        if not folder then return false end
        local lvl = LocalPlayer.statz and LocalPlayer.statz.lvl and LocalPlayer.statz.lvl.lvl and LocalPlayer.statz.lvl.lvl.Value or 1
        for _, v in ipairs(folder:GetChildren()) do
            local talk = v:FindFirstChild("Talk")
            local typ = talk and talk:FindFirstChild("typ")
            local head = v:FindFirstChild("Head")
            local give = head and head:FindFirstChild("givemission")
            local color = give and give:FindFirstChild("color")
            if typ and typ.Value == "defeat" and give and give.Enabled and color and color.Visible then
                local img = color.Image
                local okImg = img == GREEN or (lvl >= 700 and img == RED)
                if okImg and v:FindFirstChild("CLIENTTALK") then
                    if talkAcceptNear(v) then return true end
                end
            end
        end
        return false
    end
    local ScrollBoss = { picks = {}, names = {}, dd = nil }
    function ScrollBoss.all() return true end
    ScrollBoss.scanAt = 0
    ScrollBoss.tailFold = nil
    ScrollBoss.bossFold = nil
    function ScrollBoss.isHollow(packName)
        return type(packName) == "string" and packName:match("^Hollow%d+$") ~= nil
    end
    function ScrollBoss.isMissionGiver(giver)
        local talk = giver and giver:FindFirstChild("Talk")
        local typ = talk and talk:FindFirstChild("typ")
        if not typ then return true end
        return tostring(typ.Value) == "storymission"
    end
    function ScrollBoss.giver(pack)
        local namedOne = pack:FindFirstChild("missiongiver")
        if namedOne and ScrollBoss.isMissionGiver(namedOne) then return namedOne end
        for _, v in ipairs(pack:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("CLIENTTALK") and not v:FindFirstChild("rpaw")
                and ScrollBoss.isMissionGiver(v) then
                return v
            end
        end
        return nil
    end
    function ScrollBoss.rescan()
        local now = tick()
        if ScrollBoss.tailFold and now - ScrollBoss.scanAt < 8 then return end
        local tail, boss = { "tailbeastbossmission" }, { "bossdropmission" }
        local seen = {
            tailbeastbossmission = true,
            bossdropmission      = true,
            eventbossmission     = true,
        }
        for _, f in ipairs(Workspace:GetChildren()) do
            local m = not seen[f.Name] and f:FindFirstChild("missions")
            if m then
                local isTail, hasGiver = false, false
                for _, p in ipairs(m:GetChildren()) do
                    if ScrollBoss.isHollow(p.Name) then
                        isTail = true
                        break
                    end
                    hasGiver = hasGiver or (ScrollBoss.giver(p) ~= nil)
                end
                if isTail then
                    seen[f.Name] = true
                    tail[#tail + 1] = f.Name
                elseif hasGiver then
                    seen[f.Name] = true
                    boss[#boss + 1] = f.Name
                end
            end
        end
        ScrollBoss.scanAt = now
        ScrollBoss.tailFold, ScrollBoss.bossFold = tail, boss
    end
    function ScrollBoss.tailFolders()
        ScrollBoss.rescan()
        return ScrollBoss.tailFold
    end
    function ScrollBoss.bossFolders()
        ScrollBoss.rescan()
        return ScrollBoss.bossFold
    end
    function ScrollBoss.list()
        local out = {}
        local folders = { "eventbossmission" }
        for _, n in ipairs(ScrollBoss.bossFolders()) do
            folders[#folders + 1] = n
        end
        for _, n in ipairs(ScrollBoss.tailFolders()) do
            folders[#folders + 1] = n
        end
        for _, folderName in ipairs(folders) do
            local f = Workspace:FindFirstChild(folderName)
            f = f and f:FindFirstChild("missions")
            if f then
                for _, pack in ipairs(f:GetChildren()) do
                    local giver = ScrollBoss.giver(pack)
                    local hrp = giver and giver:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Position.Y > -1000 then
                        local t1 = giver:FindFirstChild("Talk")
                        t1 = t1 and t1:FindFirstChild("talk1")
                        local pretty = t1 and tostring(t1.Value):match('"(.-)"')
                        if pretty == "" then pretty = nil end
                        out[#out + 1] = {
                            pack = pack.Name,
                            folder = folderName,
                            pretty = pretty,
                        }
                    end
                end
            end
        end
        table.sort(out, function(a, b) return a.pack:lower() < b.pack:lower() end)
        return out
    end
    function ScrollBoss.nomeDoFolder(folderName)
        local base = folderName:gsub("mission$", "")
        if base == "" then return nil end
        if base == base:upper() then
            return base:sub(1, 1):upper() .. base:sub(2):lower()
        end
        return base:sub(1, 1):upper() .. base:sub(2)
    end
    function ScrollBoss.items()
        local items = {}
        ScrollBoss.names = {}
        for _, e in ipairs(ScrollBoss.list()) do
            local label
            if ScrollBoss.isHollow(e.pack) then
                local doFolder = not e.pretty and ScrollBoss.nomeDoFolder(e.folder)
                label = e.pretty or (doFolder and (doFolder .. " Gen 3")) or e.pack
            else
                label = (e.pretty and e.pretty ~= e.pack)
                    and (e.pack .. " - " .. e.pretty) or e.pack
            end
            items[#items + 1] = label
            ScrollBoss.names[label] = e.pack
        end
        table.sort(items, function(a, b) return a:lower() < b:lower() end)
        return items
    end
    function ScrollBoss.wanted(name)
        local picks = ScrollBoss.picks
        if type(picks) ~= "table" or next(picks) == nil then return true end
        if picks.All then return true end
        return picks[name] == true
    end
    function ScrollBoss.tailTypes()
        local set = {}
        local bosses = ReplicatedStorage:FindFirstChild("bosses")
        for _, folderName in ipairs(ScrollBoss.tailFolders()) do
            local f = Workspace:FindFirstChild(folderName)
            f = f and f:FindFirstChild("missions")
            if f then
                local hollowOnly = folderName ~= "tailbeastbossmission"
                for _, pack in ipairs(f:GetChildren()) do
                    if not hollowOnly or ScrollBoss.isHollow(pack.Name) then
                        local model = bosses and bosses:FindFirstChild(pack.Name)
                        local t = model and model:FindFirstChild("npctype")
                        set[t and tostring(t.Value) or pack.Name] = true
                    end
                end
            end
        end
        return set
    end
    function ScrollBoss.owned(scrollName)
        if typeof(scrollName) ~= "string" or scrollName == "" then
            return false
        end
        local function normalize(s)
            s = s:lower()
            s = s:gsub("scroll", "")
            s = s:gsub("boss", "")
            s = s:gsub("drop", "")
            s = s:gsub("[%s%-_]", "")
            return s
        end
        local sz = LocalPlayer:FindFirstChild("statz")
        local u = sz and sz:FindFirstChild("unlocked")
        if u then
            if u:FindFirstChild(scrollName .. "scroll") then
                return true
            end
            if u:FindFirstChild(scrollName) then
                return true
            end
            local normScroll = normalize(scrollName)
            for _, c in ipairs(u:GetChildren()) do
                if normalize(c.Name) == normScroll then
                    return true
                end
            end
        end
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local main = pg and pg:FindFirstChild("Main")
        local ingame = main and main:FindFirstChild("ingame")
        local menu = ingame and ingame:FindFirstChild("Menu")
        if not menu then
            return false
        end
        local tabNames = {
            "JutsuTab",
            "WeaponsTab",
            "CompanionTab",
            "BossTab",
            "MovesetsTab",
            "CustomTab",
            "KenjutsuTab",
            "KekkeiGenkaiTab",
        }
        local variants = { scrollName }
        local base = scrollName:lower()
        if base:sub(-6) == "scroll" then
            table.insert(variants, scrollName:sub(1, #scrollName - 6))
        end
        for _, tabName in ipairs(tabNames) do
            local tab = menu:FindFirstChild(tabName)
            if tab then
                for _, name in ipairs(variants) do
                    if tab:FindFirstChild(name) then
                        return true
                    end
                end
                local normScroll = normalize(scrollName)
                if #normScroll >= 7 then
                    for _, child in ipairs(tab:GetChildren()) do
                        local normChild = normalize(child.Name)
                        if normChild ~= "" and (normChild:find(normScroll, 1, true) or normScroll:find(normChild, 1, true)) then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end
    local function bossWait(giver)
        local talk = giver and giver:FindFirstChild("Talk")
        if not talk then return 0 end
        local acc = talk:FindFirstChild("accepted")
        if not (acc and acc.Value) then return 0 end
        local cd = talk:FindFirstChild("cooldown")
        local v = cd and tonumber(cd.Value) or 0
        return (v > 0) and v or 15
    end
    local function acceptBossFolder(rootFolder, wantFn)
        if not rootFolder then return false end
        local missions = rootFolder:FindFirstChild("missions")
        if not missions then return false end
        wantFn = wantFn or ScrollBoss.wanted
        local soonest
        for _, pack in ipairs(missions:GetChildren()) do
            if wantFn(pack.Name) then
                local giver = ScrollBoss.giver(pack)
                if giver and giver:FindFirstChild("CLIENTTALK") then
                    local hrp = giver:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Position.Y > -1000 then
                        local wait = bossWait(giver)
                        if wait > 0 then
                            if not soonest or wait < soonest then soonest = wait end
                        elseif talkAcceptNear(giver) then
                            return true
                        end
                    end
                end
            end
        end
        return false, soonest
    end
    local function getNpcDisplayName(v)
        if not v then return nil end
        local npt = v:FindFirstChild("npctype")
        if npt and tostring(npt.Value) ~= "" then
            return tostring(npt.Value)
        end
        local info
        pcall(function()
            info = v.Head.mob.fram.name.info.Text
        end)
        if type(info) == "string" and info ~= "" then
            local last = info:match("%[([^%]]+)%]%s*$")
            if last and not last:find("Lv", 1, true) then
                return last
            end
            return info
        end
        return nil
    end
    local function npcMatchesMission(v)
        if not v or v.Name == "logtraining" then return false end
        local txt = missionText()
        local name = getNpcDisplayName(v)
        if not name then return false end
        if string.find(name, "Spirit", 1, true) then return false end
        if txt == "" then
            return v:FindFirstChild("npctype") ~= nil
        end
        if string.find(txt, name, 1, true) then return true end
        local clean = txt:gsub("^Defeat%s+", ""):gsub("%(s%)", ""):gsub("%s+$", "")
        if clean ~= "" and (name == clean or string.find(name, clean, 1, true) or string.find(clean, name, 1, true)) then
            return true
        end
        local want = state.cfg.selectedMob
        if want and name == want then return true end
        return false
    end
    local function pickFilteredNpc(filterFn)
        local folder = Workspace:FindFirstChild("npc")
        if not folder then return nil end
        local origin = root() and root().Position
        local best, bestD
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
                local head = v:FindFirstChild("Head")
                local humObj = v:FindFirstChildWhichIsA("Humanoid")
                Zombie.track(v)
                if head
                    and head.Position.Y > -1000
                    and humObj
                    and not npcGone(v)
                    and not isCompanion(v)
                    and (humObj.Health > 0 or Zombie.is(v))
                    and (not filterFn or filterFn(v))
                then
                    local thrp = v.HumanoidRootPart
                    local d = origin and (thrp.Position - origin).Magnitude or 0
                    if not bestD or d < bestD then
                        best, bestD = v, d
                    end
                end
            end
        end
        return best
    end
    local function killFiltered(filterFn, opts)
        opts = opts or {}
        local flagName = opts.flagName or "autoDungeon"
        local target = pickFilteredNpc(filterFn)
        if not target then
            state.lockTarget = nil
            return false
        end
        state.lockTarget = target
        prepTarget(target)
        local skillTick = 0
        local skillIdx = 0
        local lastHp = math.huge
        local lastProgress = tick()
        local stuckAfter = state.cfg.stuckSeconds or 12
        while alive() and state.flags[flagName] do
            if Turn.sliceOver(flagName) then break end
            if opts.stop and opts.stop() then break end
            if movementHeld() then
                state.lockTarget = nil
                releaseFacing()
                return true
            elseif not charReady() then
                task.wait(1.5)
            else
                if npcGone(target) then
                    local nextT = pickFilteredNpc(filterFn)
                    if nextT then
                        target = nextT
                        state.lockTarget = target
                        lastHp = math.huge
                        lastProgress = tick()
                    else
                        state.lockTarget = nil
                        task.wait(0.35)
                    end
                elseif target and target.Parent then
                    local th = target:FindFirstChildWhichIsA("Humanoid")
                    local thrp = target:FindFirstChild("HumanoidRootPart")
                    local hp = (th and th.Health) or 0
                    Zombie.track(target)
                    if hp <= 0 and not Zombie.is(target) and ownsNpc(target) then
                        task.wait(0.1)
                    else
                        if hp > 0 and hp < lastHp - 0.5 then
                            lastHp = hp
                            lastProgress = tick()
                        end
                        if tick() - lastProgress > stuckAfter then
                            local nextT = pickFilteredNpc(filterFn)
                            if nextT then
                                target = nextT
                                state.lockTarget = target
                                lastHp = math.huge
                                lastProgress = tick()
                            else
                                lastProgress = tick()
                            end
                        end
                        local ch = LocalPlayer.Character
                        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                        local humObj = ch and ch:FindFirstChildWhichIsA("Humanoid")
                        local combat = ch and ch:FindFirstChild("combat") and ch.combat:FindFirstChild("update")
                        if not thrp or not hrp or not combat then
                            task.wait(0.1)
                        elseif state.spiritBusy then
                            task.wait(0.2)
                        else
                            state.lockTarget = target
                            faceLock(humObj, true)
                            hrp.CFrame = calcFarmCF(thrp)
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                            Phys.freeze(humObj)
                            prepTarget(target)
                            local charging = manageChi(combat)
                            if not charging then
                                if state.flags.autoAttack then punchOnce(combat) end
                                skillTick = skillTick + 1
                                if skillsOk() and not inputBlocked(combat) and skillTick % 3 == 0 then
                                    local ks = Skills.active()
                                    if #ks > 0 then
                                        skillIdx = (skillIdx % #ks) + 1
                                        pressSkill(combat, ks[skillIdx])
                                    end
                                end
                            else
                                task.wait(0.08)
                            end
                            if finishArmed() then
                                tryFinishNpc(target)
                            end
                            task.wait(state.cfg.farmWait)
                        end
                    end
                else
                    local nextT = pickFilteredNpc(filterFn)
                    if nextT then
                        target = nextT
                        state.lockTarget = target
                        lastHp = math.huge
                        lastProgress = tick()
                    else
                        task.wait(0.35)
                    end
                end
            end
        end
        state.lockTarget = nil
        releaseFacing()
        return true
    end
    local function missionNameClean(txt)
        if not txt or txt == "" then return "" end
        return (txt:gsub("^Defeat%s+", ""):gsub("%(s%)", ""):gsub("%s+$", ""))
    end
    local function killMissionTarget(opts)
        opts = opts or {}
        local folder = Workspace:FindFirstChild("npc")
        if not folder then return false end
        local txt = missionText()
        if txt == "" then return false end
        local clean = missionNameClean(txt)
        local flagName = opts.flagName or "autoBoss"
        local myRoot = root()
        local origin = myRoot and myRoot.Position
        local tailTypes = ScrollBoss.tailTypes()
        local function isBeast(v)
            local t = v:FindFirstChild("npctype")
            if t and tailTypes[tostring(t.Value)] then return true end
            return v:FindFirstChild("rpaw") ~= nil
                or v:FindFirstChild("lbpaw") ~= nil
                or v:FindFirstChild("tails") ~= nil
        end
        local function rankTarget(v)
            if not v or v.Name == "logtraining" then return nil end
            if isCompanion(v) then return nil end
            local beast = isBeast(v)
            if opts.beastOnly then
                if not beast then return nil end
            elseif beast then
                return nil
            end
            if npcGone(v) then return nil end
            Zombie.track(v)
            if not Zombie.targetable(v) then return nil end
            if opts.beastOnly then return 1 end
            local marked = opts.bossMarker
                and (v:FindFirstChild("megaboss") or v:FindFirstChild("bossdrop")) ~= nil
            local name = getNpcDisplayName(v)
            if name and not (opts.skipSpirit and string.find(name, "Spirit", 1, true)) then
                if string.find(txt, name, 1, true) then return 1 end
                if clean ~= "" and (name == clean or string.find(name, clean, 1, true) or string.find(clean, name, 1, true)) then
                    return 1
                end
                if opts.anyNpc and v:FindFirstChild("npctype") then return 1 end
            end
            if marked then return 2 end
            return nil
        end
        local function pickClosest()
            local best, bestD, bestRank
            origin = root() and root().Position
            for _, v in ipairs(folder:GetChildren()) do
                local rank = rankTarget(v)
                if rank then
                    local thrp = v:FindFirstChild("HumanoidRootPart")
                    local d = origin and thrp and (thrp.Position - origin).Magnitude or 0
                    if not bestRank or rank < bestRank
                        or (rank == bestRank and d < bestD) then
                        best, bestD, bestRank = v, d, rank
                    end
                end
            end
            return best
        end
        local target = pickClosest()
        if not target then
            state.lockTarget = nil
            return false
        end
        state.lockTarget = target
        local skillTick = 0
        local skillIdx = 0
        local lastHp = math.huge
        local lastProgress = tick()
        local startedAt = tick()
        local stuckAfter = state.cfg.stuckSeconds or 12
        while alive() and state.flags[flagName] and missionVisible() do
            if not charReady() then
                state.lockTarget = nil
                releaseFacing()
                task.wait(1.5)
                return false
            end
            local th = target:FindFirstChildWhichIsA("Humanoid")
            local thrp = target:FindFirstChild("HumanoidRootPart")
            local hp = (th and th.Health) or 0
            Zombie.track(target)
            if npcGone(target) or (hp <= 0 and not Zombie.is(target)) then
                local nextT = pickClosest()
                if nextT then
                    target = nextT
                    state.lockTarget = target
                    lastHp = math.huge
                    lastProgress = tick()
                    startedAt = tick()
                    task.wait(0.05)
                else
                    break
                end
            end
            th = target:FindFirstChildWhichIsA("Humanoid")
            thrp = target:FindFirstChild("HumanoidRootPart")
            hp = (th and th.Health) or 0
            if hp > 0 and hp < lastHp - 0.5 then
                lastHp = hp
                lastProgress = tick()
            end
            if tick() - lastProgress > stuckAfter then
                state.lockTarget = nil
                releaseFacing()
                coolFor(flagName, 4)
                notify("Failsafe", "Target took no damage - moving to the next one.")
                return false
            end
            if tick() - startedAt > 420 then
                state.lockTarget = nil
                releaseFacing()
                coolFor(flagName, 4)
                notify("Failsafe", "Target held too long - released.")
                return false
            end
            local ch = LocalPlayer.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            local humObj = ch and ch:FindFirstChildWhichIsA("Humanoid")
            local combat = ch and ch:FindFirstChild("combat") and ch.combat:FindFirstChild("update")
            if not thrp or not hrp or not combat then
                task.wait(0.1)
            elseif state.spiritBusy then
                task.wait(0.2)
            else
                forceCharNoCollide()
                pcall(function()
                    faceLock(humObj, true)
                    hrp.CFrame = calcFarmCF(thrp)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
                Phys.freeze(humObj)
                prepTarget(target)
                local charging = manageChi(combat)
                if not charging then
                    if state.flags.autoAttack then punchOnce(combat) end
                    skillTick = skillTick + 1
                    if skillsOk() and not inputBlocked(combat) and skillTick % 3 == 0 then
                        local ks = Skills.active()
                        if #ks > 0 then
                            skillIdx = (skillIdx % #ks) + 1
                            pressSkill(combat, ks[skillIdx])
                        end
                    end
                else
                    task.wait(0.08)
                end
                if finishArmed() then
                    tryFinishNpc(target)
                end
                task.wait(state.cfg.farmWait)
            end
        end
        state.lockTarget = nil
        releaseFacing()
        okStep(flagName)
        return true
    end
    local function missionFarmStep(flagName, folderName, opts)
        if cooling(flagName) then
            task.wait(0.5)
            return "empty"
        end
        if not charReady() then
            state.lockTarget = nil
            task.wait(1)
            return "busy"
        end
        if missionVisible() then
            killMissionTarget(opts)
            releaseChi()
            return "busy"
        end
        local accepted, waitFor
        if folderName then
            local achou = false
            for _, npcName in ipairs(type(folderName) == "table" and folderName or { folderName }) do
                local folder = Workspace:FindFirstChild(npcName)
                if folder then
                    achou = true
                    local ok, waitY = acceptBossFolder(folder, opts and opts.wantFn)
                    if ok then
                        accepted = true
                        break
                    end
                    if waitY and (not waitFor or waitY < waitFor) then
                        waitFor = waitY
                    end
                end
            end
            if not achou then
                failStep(flagName, 3, 10, "Mission givers aren't in this area.")
                task.wait(0.5)
                return "empty"
            end
        else
            accepted = acceptDefeatMission()
        end
        if not accepted and waitFor then
            okStep(flagName)
            if not cooling(flagName .. "_cd") then
                coolFor(flagName .. "_cd", 30)
                notify("Boss", string.format(
                    "Your picks are taken or on cooldown - retrying in %ds.", math.ceil(waitFor)))
            end
            task.wait(math.min(waitFor, 5))
            return "waiting"
        end
        if accepted then
            okStep(flagName)
            return "busy"
        elseif not failStep(flagName, 4, 8, "No mission ready - pausing before retry.") then
            task.wait(0.6)
        end
        return "empty"
    end
    local function sweepStep(flagName, filterFn, stopFn)
        if cooling(flagName) then
            task.wait(0.5)
            return "empty"
        end
        if not charReady() then
            task.wait(1)
            return "busy"
        end
        local swept = killFiltered(filterFn, { flagName = flagName, stop = stopFn })
        releaseChi()
        if swept then
            okStep(flagName)
            return "busy"
        elseif not failStep(flagName, 25, 6, "Nothing to farm in this area.") then
            task.wait(0.3)
        end
        return "empty"
    end
    track(LocalPlayer.CharacterAdded:Connect(function(ch)
        clearHoldBodies()
        state.lockTarget = nil
        state.lockLog = nil
        state.lockPlayer = nil
        state.safeAnchor = nil
        state.voidAnchor = nil
        state.arenaFloorY = nil
        state.arenaUnderY = nil
        state.arenaSpotX, state.arenaSpotZ = nil, nil
        setMoving(false)
        state.rotLocked = false
        state.chargingChi = false
        table.clear(charParts)
        task.defer(refreshCharParts, ch)
        track(ch.DescendantAdded:Connect(function(d) noclipPart(d) end))
        local h = ch:WaitForChild("Humanoid", 5)
        if h then
            pcall(function() h.AutoRotate = true end)
            track(h.Died:Connect(function()
                state.lockTarget = nil
                state.lockLog = nil
                state.lockPlayer = nil
            end))
        end
    end))
    if LocalPlayer.Character then
        refreshCharParts(LocalPlayer.Character)
        track(LocalPlayer.Character.DescendantAdded:Connect(function(d) noclipPart(d) end))
    end
    spawnLoop(function()
        while alive() do
            if state.flags.autoLevel then
                Turn.run("autoLevel", function()
                    if not charReady() then
                        state.lockLog = nil
                        Turn.step("autoLevel", "busy")
                        task.wait(1)
                        return
                    end
                    local logNpc = findLog()
                    state.lockLog = logNpc
                    if logNpc and logNpc:FindFirstChild("HumanoidRootPart") then
                        okStep("autoLevel")
                        Turn.step("autoLevel", "busy")
                        prepareLog(logNpc)
                        if state.flags.autoAttack then hitOnce() end
                    else
                        state.lockLog = nil
                        if not failStep("autoLevel", 20, 6, "No training log in this area.") then
                            task.wait(0.4)
                        end
                        Turn.step("autoLevel", "empty")
                    end
                end)
            else
                state.lockLog = nil
            end
            task.wait(state.cfg.farmWait)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.autoQuest then
                Turn.run("autoQuest", function()
                    local status = missionFarmStep("autoQuest", nil, { skipSpirit = true, flagName = "autoQuest" })
                    Turn.step("autoQuest", status)
                end)
            end
            task.wait(state.cfg.farmWait)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.autoBoss then
                Turn.run("autoBoss", function()
                    local status = missionFarmStep("autoBoss",
                        ScrollBoss.bossFolders(),
                        { skipSpirit = true, flagName = "autoBoss", bossMarker = true })
                    Turn.step("autoBoss", status)
                end)
            end
            task.wait(state.cfg.farmWait)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.autoTail then
                Turn.run("autoTail", function()
                    local status = missionFarmStep(
                        "autoTail",
                        ScrollBoss.tailFolders(),
                        { flagName = "autoTail", beastOnly = true }
                    )
                    Turn.step("autoTail", status)
                end)
            end
            task.wait(state.cfg.farmWait)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.autoEventBoss then
                local ebm = Workspace:FindFirstChild("eventbossmission")
                local packs = ebm and ebm:FindFirstChild("missions")
                Turn.run("autoEventBoss", function()
                    local status
                    if packs and #packs:GetChildren() > 0 then
                        status = missionFarmStep("autoEventBoss", "eventbossmission",
                            { skipSpirit = true, flagName = "autoEventBoss" })
                    else
                        status = sweepStep("autoEventBoss", function(v)
                            return v.Name ~= "logtraining"
                                and v:FindFirstChild("npctype") ~= nil
                                and not (getNpcDisplayName(v) or ""):find("Spirit", 1, true)
                        end)
                    end
                    Turn.step("autoEventBoss", status)
                end)
            end
            task.wait(state.cfg.farmWait)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.autoJin then
                Turn.run("autoJin", function()
                    local status = sweepStep("autoJin", function(v)
                        return v.Name == "npc1"
                    end)
                    Turn.step("autoJin", status)
                end)
            end
            task.wait(state.cfg.farmWait)
        end
    end)
    spawnLoop(function()
        while alive() do
            if finishArmed() then
                pcall(function()
                    local folder = Workspace:FindFirstChild("npc")
                    local hrp = root()
                    if folder and hrp then
                        for _, v in ipairs(folder:GetChildren()) do
                            if not npcGone(v) and not isCompanion(v) then
                                local thrp = v:FindFirstChild("HumanoidRootPart")
                                if thrp and (thrp.Position - hrp.Position).Magnitude < 80 then
                                    Zombie.track(v)
                                    tryFinishNpc(v)
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(0.25)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.autoRank and not cooling("autoRank") then
                pcall(function()
                    if LocalPlayer.statz.lvl.lvl.Value >= 1000 then
                        if LocalPlayer.statz.prestige.maxlvlpres.Value >= 1 then
                            fire(startevent, "maxlvlpres")
                        else
                            fire(startevent, "rankup")
                        end
                        coolFor("autoRank", 4)
                    end
                end)
            end
            task.wait(0.4)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.autoHealth then
                fire(startevent, "addstat", "health", 5)
            end
            if state.flags.autoNinjutsu then
                fire(startevent, "addstat", "ninjutsu", 5)
            end
            if state.flags.autoTaijutsu then
                fire(startevent, "addstat", "taijutsu", 5)
            end
            if state.flags.autoChakra then
                fire(startevent, "addstat", "chakra", 5)
            end
            task.wait(0.25)
        end
    end)
    local sec
    sec = Sub.FarmLevel:AddSection({ Name = "Leveling", Icon = "swords", Side = 1 })
    sec:AddToggle({
        Name = "Auto Level (Logs)",
        Flag = "shindo_farm_autolevel",
        Default = false,
        Callback = function(on) state.flags.autoLevel = on end,
    })
    sec:AddButton({
        Name = "TP To Logs",
        Callback = function()
            local logNpc = findLog()
            if logNpc then
                prepareLog(logNpc)
                local cf = logFarmCFrame(logNpc)
                if cf then tpTo(cf) end
            else
                notify("Logs", "No training log found here.")
            end
        end,
    })
    sec:AddToggle({
        Name = "Auto Quests",
        Flag = "shindo_farm_autoquest",
        Default = false,
        Callback = function(on) state.flags.autoQuest = on end,
    })
    sec:AddToggle({
        Name = "Auto Rank Up At Lvl 1000",
        Flag = "shindo_farm_autorank",
        Default = false,
        Callback = function(on)
            state.flags.autoRank = on
            if on then
                local lvl = 0
                pcall(function() lvl = LocalPlayer.statz.lvl.lvl.Value end)
                if lvl >= 1000 then
                    notify("Auto Rank", "You're at the cap - ranking up now.")
                else
                    notify("Auto Rank", string.format("Armed. Waiting for Lvl 1000 (you're %d).", lvl))
                end
            end
        end,
    })
    sec = Sub.FarmSet:AddSection({ Name = "Farm Config", Icon = "sliders-horizontal", Side = 2 })
    sec:AddSlider({
        Name = "Farm Delay",
        Flag = "shindo_farm_delay",
        Min = 0, Max = 0.5, Default = 0.08, Decimals = 0.01,
        Callback = function(v) state.cfg.farmWait = v end,
    })
    sec:AddSlider({
        Name = "Give Up After (s)",
        Flag = "shindo_farm_stuck",
        Min = 5, Max = 60, Default = 12, Decimals = 1,
        Callback = function(v) state.cfg.stuckSeconds = v end,
    })
    sec:AddSlider({
        Name = "Range",
        Flag = "shindo_farm_range",
        Min = 1, Max = 1000, Default = 6.5, Decimals = 0.1,
        Callback = function(v) state.cfg.range = v end,
    })
    sec:AddDropdown({
        Name = "Stand On Side",
        Flag = "shindo_farm_posmode",
        Multi = false,
        Items = { "Under", "Behind", "Above", "Front" },
        Default = "Under",
        Callback = function(v)
            if type(v) == "string" then state.cfg.farmMode = v end
        end,
    })
    sec = Sub.FarmBoss:AddSection({ Name = "Boss Farms", Icon = "skull", Side = 1 })
    sec:AddLabel("Empty = all. Bosses on cooldown are skipped.")
    sec:AddLabel("Farms take turns - only one moves you at a time.")
    ScrollBoss.dd = sec:AddDropdown({
        Name = "Boss & Spirit Givers",
        Flag = "shindo_farm_bosses",
        Multi = true,
        SearchThreshold = 6,
        Items = ScrollBoss.items(),
        Default = {},
        Callback = function(v)
            local set = {}
            if type(v) == "table" then
                for k, val in pairs(v) do
                    local label = (type(k) == "string") and k or val
                    if type(label) == "string" then
                        set[ScrollBoss.names[label] or label] = true
                    end
                end
            elseif type(v) == "string" then
                set[ScrollBoss.names[v] or v] = true
            end
            ScrollBoss.picks = set
        end,
    })
    sec:AddButton({
        Name = "Refresh Boss List",
        Callback = function()
            local items = ScrollBoss.items()
            pcall(function() ScrollBoss.dd:Refresh(items) end)
            notify("Bosses", #items > 0 and (#items .. " giver(s) up right now.") or "No givers spawned here.")
        end,
    })
    sec:AddButton({
        Name = "TP To Boss Giver",
        Callback = function()
            local achou = false
            local ready, waiting, waitFor
            local folderList = { "bossdropmission", "eventbossmission" }
            for _, n in ipairs(ScrollBoss.tailFolders()) do
                folderList[#folderList + 1] = n
            end
            for _, npcName in ipairs(folderList) do
                local bd = Workspace:FindFirstChild(npcName)
                local missions = bd and bd:FindFirstChild("missions")
                if missions then
                    achou = true
                    for _, pack in ipairs(missions:GetChildren()) do
                        if ScrollBoss.wanted(pack.Name) then
                            local mg = pack:FindFirstChild("missiongiver") or pack:FindFirstChildWhichIsA("Model")
                            local hrp = mg and mg:FindFirstChild("HumanoidRootPart")
                            if hrp and hrp.Position.Y > -1000 then
                                local wait = bossWait(mg)
                                if wait <= 0 then
                                    ready = hrp
                                    break
                                elseif not waitFor or wait < waitFor then
                                    waiting, waitFor = hrp, wait
                                end
                            end
                        end
                    end
                    if ready then break end
                end
            end
            if not achou then
                notify("Boss", "Not in a village with boss givers.")
                return
            end
            if ready then
                tpTo(ready.CFrame * CFrame.new(0, -6, 0))
            elseif waiting then
                tpTo(waiting.CFrame * CFrame.new(0, -6, 0))
                notify("Boss", string.format(
                    "All your picks are taken or on cooldown (~%ds).", math.ceil(waitFor)))
            else
                notify("Boss", "None of your picks are spawned right now.")
            end
        end,
    })
    sec:AddToggle({
        Name = "Auto Boss Farm",
        Flag = "shindo_farm_autoboss",
        Default = false,
        Callback = function(on) state.flags.autoBoss = on end,
    })
    sec:AddToggle({
        Name = "Auto Tail Beast",
        Flag = "shindo_farm_autotail",
        Default = false,
        Callback = function(on) state.flags.autoTail = on end,
    })
    sec:AddToggle({
        Name = "Event Boss Sweep",
        Flag = "shindo_farm_eventboss",
        Default = false,
        Callback = function(on) state.flags.autoEventBoss = on end,
    })
    sec:AddToggle({
        Name = "Jin Farm",
        Flag = "shindo_farm_jin",
        Default = false,
        Callback = function(on) state.flags.autoJin = on end,
    })
    sec = Sub.FarmSet:AddSection({ Name = "Farm Priority", Icon = "list-ordered", Side = 1 })
    do
        local labels = {}
        for _, e in ipairs(Turn.PICKS) do labels[#labels + 1] = e.label end
        sec:AddLabel("Empty = no priority, every farm takes turns.")
        sec:AddDropdown({
            Name = "Priority Queue (pick in order)",
            Flag = "shindo_farm_priorder",
            Multi = true,
            Ranked = true,
            SearchThreshold = 6,
            Items = labels,
            Default = {},
            Callback = function(v) Turn.setOrder(v) end,
        })
        sec:AddLabel("1 runs first. The next only runs while the")
        sec:AddLabel("ones above it find nothing to do.")
        sec:AddLabel("Left out of the list = ignores priority entirely.")
    end
    sec = Sub.FarmSet:AddSection({ Name = "Fight Settings", Icon = "swords", Side = 1 })
    sec:AddToggle({
        Name = "Auto Attack (M1)",
        Flag = "shindo_farm_autoattack",
        Default = false,
        Callback = function(on) state.flags.autoAttack = on end,
    })
    sec:AddToggle({
        Name = "Spam Skills",
        Flag = "shindo_farm_skills",
        Default = false,
        Callback = function(on) state.flags.useSkills = on end,
    })
    sec:AddLabel("Empty = every jutsu you have equipped.")
    Skills.dd = sec:AddDropdown({
        Name = "Skills To Use",
        Flag = "shindo_farm_skillpick",
        Multi = true,
        SearchThreshold = 6,
        Items = Skills.items(),
        Default = {},
        Callback = function(v)
            local set = {}
            if type(v) == "table" then
                for k, val in pairs(v) do
                    local label = (type(k) == "string") and k or val
                    if type(label) == "string" then
                        set[Skills.names[label] or label] = true
                    end
                end
            end
            Skills.picks = set
            Skills.at = 0
        end,
    })
    sec:AddButton({
        Name = "Refresh Skill List",
        Callback = function()
            local items = Skills.items()
            pcall(function() Skills.dd:Refresh(items) end)
            Skills.at = 0
            notify("Skills", #items > 0
                and (#items .. " jutsu equipped.")
                or "No jutsu equipped in the R/T/Y/F/G/H/V/B/N slots.")
        end,
    })
    sec:AddToggle({
        Name = "Auto Charge Chi",
        Flag = "shindo_farm_autochi",
        Default = false,
        Callback = function(on)
            state.flags.autoChi = on
            if not on then releaseChi() end
        end,
    })
    sec:AddSlider({
        Name = "Chi Recharge Under (%)",
        Flag = "shindo_farm_chimin",
        Min = 5, Max = 95, Default = 40, Decimals = 1, Suffix = "%",
        Callback = function(v) state.cfg.chiMin = v end,
    })
    sec:AddToggle({
        Name = "Semi Insta Kill",
        Flag = "shindo_farm_semikill",
        Default = false,
        Callback = function(on) state.flags.semiKill = on end,
    })
    local function currentFarmTarget()
        local t = state.lockTarget
        if t and t.Parent then return t end
        local l = state.lockLog
        if l and l.Parent then return l end
        local p = state.lockPlayer
        if p and p.Parent then return p end
        return nil
    end
    pcall(function() RunService:UnbindFromRenderStep("DzShindoCamLook") end)
    RunService:BindToRenderStep("DzShindoCamLook" .. MY_GEN, Enum.RenderPriority.Camera.Value + 1, function()
        if not alive() then return end
        if not state.flags.camLook then return end
        local target = currentFarmTarget()
        if not target then return end
        local part = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
        local cam = Workspace.CurrentCamera
        if not part or not cam then return end
        pcall(function()
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, part.Position)
        end)
    end)
    sec:AddToggle({
        Name = "Look Camera At Mob",
        Flag = "shindo_farm_camlook",
        Default = false,
        Callback = function(on) state.flags.camLook = on end,
    })
    spawnLoop(function()
        while alive() do
            if state.flags.throwSword and currentFarmTarget() then
                pcall(function()
                    local ch = LocalPlayer.Character
                    local combat = ch and ch:FindFirstChild("combat") and ch.combat:FindFirstChild("update")
                    if combat and not inputBlocked(combat) then
                        pressSkill(combat, "e")
                    end
                end)
                task.wait(state.cfg.swordDelay or 0.2)
            else
                task.wait(0.3)
            end
        end
    end)
    sec:AddToggle({
        Name = "Throwable Sword",
        Flag = "shindo_farm_throwsword",
        Default = false,
        Callback = function(on) state.flags.throwSword = on end,
    })
    local Spirit = {
        HIDDEN   = "dz_beserk",
        chatPos  = nil,
        warned   = false,
        toggle   = nil,
    }
    function Spirit.gen(name)
        if type(name) ~= "string" or not name:find("tail") then return nil end
        if name:match("x2$") then return 3 end
        if name:match("x$")  then return 2 end
        return 1
    end
    function Spirit.usableOwned()
        local out = {}
        local gl = LocalPlayer.statz and LocalPlayer.statz:FindFirstChild("genkailevel")
        if not gl then return out end
        for _, k in ipairs(gl:GetChildren()) do
            local g = Spirit.gen(k.Name)
            local lvl = tonumber(k.Value) or 0
            if g and g < 3 and lvl > 0 then
                out[#out + 1] = { name = k.Name, gen = g, level = lvl }
            end
        end
        table.sort(out, function(a, b) return a.level > b.level end)
        return out
    end
    function Spirit.equipped()
        local keys = LocalPlayer.statz and LocalPlayer.statz:FindFirstChild("keys")
        if not keys then return nil end
        for _, k in ipairs(keys:GetChildren()) do
            local v = tostring(k.Value)
            if v ~= "" and (v:find("tail") or v == "rabbit") then
                return v, k.Name, Spirit.gen(v)
            end
        end
        return nil
    end
    function Spirit.equip(name)
        local modes = ReplicatedStorage:FindFirstChild("alljutsu")
        modes = modes and modes:FindFirstChild("modes")
        local folder = modes and modes:FindFirstChild(name)
        if not folder or not startevent then return false end
        fire(startevent, "equipmode", folder, name)
        return true
    end
    function Spirit.inRoom()
        local ch = LocalPlayer.Character
        local bes = ch and (ch:FindFirstChild("beserk") or ch:FindFirstChild(Spirit.HIDDEN))
        local jr = bes and bes:FindFirstChild("jinroom")
        return jr ~= nil and jr.Value == true
    end
    function Spirit.modeOn()
        local ch = LocalPlayer.Character
        local cb = ch and ch:FindFirstChild("combat")
        local m = cb and cb:FindFirstChild("KG") and cb.KG:FindFirstChild("currentmode")
        return m ~= nil and tostring(m.Value):sub(1, 4) == "tail"
    end
    function Spirit.activateMode()
        local ch = LocalPlayer.Character
        local cb = ch and ch:FindFirstChild("combat")
        local upd = cb and cb:FindFirstChild("update")
        if not upd then return end
        local _, key = Spirit.equipped()
        key = key or "z"
        fire(upd, "key", key)
        task.wait(2.2)
        fire(upd, "key", key .. "end")
    end
    function Spirit.enter()
        local vc = Workspace:FindFirstChild("VC")
        local r = vc and vc:FindFirstChild("RemoteEvent")
        if r then fire(r, "!spirit") end
    end
    function Spirit.spiritOff()
        local ch = LocalPlayer.Character
        local hidden = ch and ch:FindFirstChild(Spirit.HIDDEN)
        if hidden then hidden.Name = "beserk" end
        local vc = Workspace:FindFirstChild("VC")
        local r = vc and vc:FindFirstChild("RemoteEvent")
        if r then fire(r, "!spirit off") end
    end
    function Spirit.leave()
        state.spiritBusy = false
        Spirit.clearOverlay()
        Spirit.closeBeastCustom()
        Spirit.spiritOff()
    end
    function Spirit.closeChat()
        local main = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local ingame = main and main:FindFirstChild("ingame")
        local cf = ingame and ingame:FindFirstChild("chat")
        if not cf then return end
        if Spirit.chatPos == nil then Spirit.chatPos = cf.Position end
        cf.Visible = false
        cf.Position = Spirit.chatPos
    end
    function Spirit.closeBeastCustom()
        local main = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local tc = main and main:FindFirstChild("TailedCustom")
        if not tc or not tc.Visible then return end
        local btn = tc:FindFirstChild("complete")
        if btn and getconnections then
            local ok, conns = pcall(getconnections, btn.MouseButton1Down)
            if ok and #conns > 0 then
                pcall(function() conns[1]:Fire(0, 0) end)
                if not tc.Visible then return end
            end
        end
        pcall(function()
            tc.Visible = false
            local ingame = main:FindFirstChild("ingame")
            if ingame then ingame.Visible = true end
        end)
    end
    function Spirit.clearOverlay()
        local main = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not main then return end
        local f = main:FindFirstChild("Frame")
        if f and (f:IsA("Frame") or f:IsA("ImageLabel") or f:IsA("CanvasGroup")) then
            pcall(function() f:Destroy() end)
        end
    end
    function Spirit.cameraHijacked()
        local subj = Workspace.Camera.CameraSubject
        local parent = subj and subj.Parent
        if not parent then return false end
        return parent ~= LocalPlayer.Character
    end
    function Spirit.waitForHijack(timeout)
        local t0 = tick()
        while tick() - t0 < (timeout or 8) do
            if Spirit.cameraHijacked() then return true end
            task.wait(0.1)
        end
        return false
    end
    function Spirit.reclaim()
        local ch = LocalPlayer.Character
        if not ch then return end
        local bes = ch:FindFirstChild("beserk")
        if bes then bes.Name = Spirit.HIDDEN end
        Spirit.closeChat()
        Spirit.closeBeastCustom()
        local hum = ch:FindFirstChildWhichIsA("Humanoid")
        if hum then
            pcall(function() Workspace.Camera.CameraSubject = hum end)
            if hum.WalkSpeed <= 0 then
                local cb = ch:FindFirstChild("combat")
                local run = cb and cb:FindFirstChild("run")
                hum.WalkSpeed = (run and run.Value) and 30 or 16
            end
        end
        local wi = LocalPlayer:FindFirstChild("wasdinvert")
        if wi then pcall(function() wi.Value = 1 end) end
        Spirit.clearOverlay()
    end
    function Spirit.clearCombatTag()
        local ic = LocalPlayer:FindFirstChild("incombat")
        if not ic then return end
        pcall(function()
            ic.Value = false
            local tim = ic:FindFirstChild("tim")
            if tim then tim.Value = 0 end
        end)
    end
    function Spirit.refillMd()
        local ch = LocalPlayer.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local cb = ch and ch:FindFirstChild("combat")
        local m = cb and cb:FindFirstChild("mode")
        if not hrp or not m then return end
        local maxMd = m.MaxValue or 10000
        if m.Value >= maxMd then return end
        setMoving(true, 130)
        local back = hrp.CFrame
        Spirit.spiritOff()
        task.wait(2)
        if state.flags.mdReset then
            local h = ch:FindFirstChildWhichIsA("Humanoid")
            if not h then
                setMoving(false)
                return
            end
            Spirit.clearCombatTag()
            Phys.unstick(4)
            task.wait(0.35)
            pcall(function() h.Health = 0 end)
            local t0 = tick()
            local freshChar = LocalPlayer.Character
            local lastOne = tick()
            while (freshChar == ch or not freshChar) and tick() - t0 < 25 do
                task.wait(0.2)
                freshChar = LocalPlayer.Character
                if freshChar == ch and tick() - lastOne > 2.5 then
                    lastOne = tick()
                    Spirit.clearCombatTag()
                    Phys.unstick(4)
                    pcall(function() h.Health = 0 end)
                end
            end
            if freshChar == ch then
                setMoving(false)
                return
            end
            ch  = freshChar
            cb  = ch:WaitForChild("combat", 10)
            hrp = ch:WaitForChild("HumanoidRootPart", 5)
            task.wait(0.6)
        else
            local up = back + Vector3.new(0, 1200, 0)
            local t0 = tick()
            while m and m.Parent and m.Value < maxMd and tick() - t0 < 90 do
                if hrp and hrp.Parent then
                    pcall(function() hrp.CFrame = up end)
                end
                task.wait(0.4)
            end
        end
        if hrp and hrp.Parent then
            pcall(function() hrp.CFrame = back end)
        end
        setMoving(false)
        if wantNoclip() then state.safeAnchor = back end
    end
    function Spirit.ensureBeast()
        local equipped, _, gen = Spirit.equipped()
        if equipped and gen and gen < 3 then return true end
        local owned = Spirit.usableOwned()
        if #owned == 0 then
            if not Spirit.warned then
                Spirit.warned = true
                notify("Spirit Room",
                    "You need a gen 1 or gen 2 tailed spirit. Gen 3 can't enter the spirit room.")
            end
            return false
        end
        local pick = owned[1]
        notify("Spirit Room", string.format("Equipping %s (gen %d, lvl %d).",
            pick.name, pick.gen, pick.level))
        Spirit.equip(pick.name)
        task.wait(1.5)
        local nowEquipped, _, nowGen = Spirit.equipped()
        return nowEquipped ~= nil and nowGen ~= nil and nowGen < 3
    end
    local spiritToggle
    spiritToggle = sec:AddToggle({
        Name = "No Cooldown",
        Flag = "shindo_farm_spiritnocd",
        Default = false,
        Callback = function(on)
            state.flags.spiritNoCd = on
            Spirit.warned = false
            if on then
                notify("Spirit Room", "Entering the spirit room - skills lose cooldown there.")
            else
                Spirit.leave()
            end
        end,
    })
    Spirit.toggle = spiritToggle
    sec:AddToggle({
        Name = "Reset Character To Refill (MD)",
        Flag = "shindo_farm_mdreset",
        Default = false,
        Callback = function(on) state.flags.mdReset = on end,
    })
    spawnLoop(function()
        while alive() do
            if state.flags.spiritNoCd then
                pcall(function()
                    if not charReady() then return end
                    if not Spirit.ensureBeast() then
                        state.flags.spiritNoCd = false
                        if Spirit.toggle and type(Spirit.toggle.Set) == "function" then
                            task.defer(function() pcall(Spirit.toggle.Set, Spirit.toggle, false) end)
                        end
                        return
                    end
                    if Spirit.inRoom() and Spirit.modeOn() then
                        if Spirit.cameraHijacked() then
                            state.spiritBusy = true
                            Spirit.reclaim()
                        end
                        return
                    end
                    state.spiritBusy = true
                    if wantNoclip() and not state.safeAnchor then
                        local hrp = root()
                        if hrp then state.safeAnchor = hrp.CFrame end
                    end
                    if not Spirit.modeOn() then
                        Spirit.refillMd()
                        Spirit.activateMode()
                        task.wait(0.8)
                        if not Spirit.modeOn() then return end
                    end
                    Spirit.enter()
                    Spirit.waitForHijack(8)
                    task.wait(0.3)
                    if Spirit.inRoom() then
                        Spirit.reclaim()
                    end
                end)
                state.spiritBusy = false
                setMoving(false)
            end
            task.wait(1)
        end
    end)
    sec = Sub.UtilStats:AddSection({ Name = "Stats", Icon = "award", Side = 1 })
    do
        local lbl1 = sec:AddLabel("Points - ")
        local lbl2 = sec:AddLabel("")
        local MAP = {
            { key = "chakra",   short = "Chi", frame = "Chakra"   },
            { key = "ninjutsu", short = "Nin", frame = "Jutsu"    },
            { key = "taijutsu", short = "Tai", frame = "Strength" },
            { key = "health",   short = "HP",  frame = "Health"   },
        }
        local function statsLines()
            local m = LocalPlayer:FindFirstChild("statz")
            m = m and m:FindFirstChild("mastery")
            if not m then return "Stats unavailable in this place.", "" end
            local st = LocalPlayer.PlayerGui:FindFirstChild("Main")
            st = st and st:FindFirstChild("ingame")
            st = st and st:FindFirstChild("Menu")
            st = st and st:FindFirstChild("StatsTab")
            local parts = {}
            for _, e in ipairs(MAP) do
                local v = m:FindFirstChild(e.key)
                local f = st and st:FindFirstChild(e.frame)
                local t = f and f:FindFirstChild("title")
                local cap = t and tostring(t.Text):match("%[(%d+)%]%s*$")
                parts[#parts + 1] = e.short .. " " .. tostring(v and v.Value or 0)
                    .. (cap and ("/" .. cap) or "")
            end
            local pts = m:FindFirstChild("points")
            local lvl = LocalPlayer.statz:FindFirstChild("lvl")
            lvl = lvl and lvl:FindFirstChild("lvl")
            return ("Points %s - Level %s"):format(
                       tostring(pts and pts.Value or 0),
                       tostring(lvl and lvl.Value or " - ")),
                   table.concat(parts, " - ")
        end
        spawnLoop(function()
            while alive() do
                pcall(function()
                    local a, b = statsLines()
                    lbl1:SetText(a)
                    lbl2:SetText(b)
                end)
                task.wait(1)
            end
        end)
    end
    sec = Sub.UtilStats:AddSection({ Name = "Auto Stats", Icon = "trending-up", Side = 1 })
    sec:AddToggle({
        Name = "Auto Health",
        Flag = "shindo_farm_stat_health",
        Default = false,
        Callback = function(on) state.flags.autoHealth = on end,
    })
    sec:AddToggle({
        Name = "Auto Ninjutsu",
        Flag = "shindo_farm_stat_ninjutsu",
        Default = false,
        Callback = function(on) state.flags.autoNinjutsu = on end,
    })
    sec:AddToggle({
        Name = "Auto Taijutsu",
        Flag = "shindo_farm_stat_taijutsu",
        Default = false,
        Callback = function(on) state.flags.autoTaijutsu = on end,
    })
    sec:AddToggle({
        Name = "Auto Chakra",
        Flag = "shindo_farm_stat_chakra",
        Default = false,
        Callback = function(on) state.flags.autoChakra = on end,
    })
    local TeleportService = game:GetService("TeleportService")
    local HttpService     = game:GetService("HttpService")
    local Lighting        = game:GetService("Lighting")
    do
        local s = state.session
        s.start = tick()
        pcall(function()
            s.startCash  = LocalPlayer.statz.cash.Value
            s.startSpins = LocalPlayer.statz.spins.Value
            s.startLvl   = LocalPlayer.statz.lvl.lvl.Value
        end)
    end
    local MENU = 4616652839
    local PLACES = {
        Menu                = 4616652839,
        Ember               = 4601350214,
        Obelisk             = 4601350809,
        Nimbus              = 4601350656,
        Haze                = 4601350760,
        Dunes               = 4601350394,
        Storm               = 5084678830,
        Training            = 5431071837,
        ["Forest of Embers"]= 5447073001,
        ["Dawn Hideout"]    = 5431069982,
        ArenaX              = 5743370338,
        ["Shindo World"]    = 5943872934,
        ["Dungeon Lobby"]   = 7524809704,
        Maru                = 5451401540,
    }
    local PLACE_NAMES = {}
    for name in pairs(PLACES) do PLACE_NAMES[#PLACE_NAMES + 1] = name end
    table.sort(PLACE_NAMES)
    local function hopServer(mode)
        local moved = false
        pcall(function()
            local url = "https://games.roblox.com/v1/games/"
                .. tostring(game.PlaceId)
                .. "/servers/Public?sortOrder=Asc&limit=100"
            local data = HttpService:JSONDecode(game:HttpGet(url))
            local best, bestScore
            for _, s in ipairs(data.data or {}) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    local playing = s.playing or 0
                    local score = playing
                    if mode == "range" then
                        if playing < (state.cfg.hopMinPlayers or 4) then
                            score = score - 100
                        elseif playing > (state.cfg.hopMaxPlayers or 18) then
                            score = score - 50
                        else
                            score = score + 20
                        end
                    elseif mode == "small" then
                        score = -playing
                    end
                    if not bestScore or score > bestScore then
                        best, bestScore = s, score
                    end
                end
            end
            if best then
                if type(_dzEnv.DisableAntiTeleport) == "function" then
                    pcall(_dzEnv.DisableAntiTeleport)
                end
                TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
                moved = true
            end
        end)
        return moved
    end
    local Scroll = {
        dud     = setmetatable({}, { __mode = "k" }),
        MAX_TRY = 3,
        FORGET  = 60,
    }
    function Scroll.giveUp(model)
        local e = Scroll.dud[model]
        if not e then return false end
        if tick() - e.at > Scroll.FORGET then
            Scroll.dud[model] = nil
            return false
        end
        return e.n >= Scroll.MAX_TRY
    end
    function Scroll.tried(model, gone)
        if gone then
            Scroll.dud[model] = nil
            return
        end
        local e = Scroll.dud[model]
        if not e or tick() - e.at > Scroll.FORGET then
            e = { n = 0, at = 0 }
            Scroll.dud[model] = e
        end
        e.n, e.at = e.n + 1, tick()
    end
    local function grabScrolls()
        local found = false
        local function scan(container)
            if not container then return end
            for _, v in ipairs(container:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("sh") then
                    local sh = v.sh
                    local skip = (state.flags.scrollSkipOwned and ScrollBoss.owned(v.Name))
                        or Scroll.giveUp(v)
                    if sh:IsA("BasePart") and not skip
                        and sh.Position.Y > -1000 and sh.Position.Y < 2000 then
                        found = true
                        state.lastScrollSeen = tick()
                        clearHoldBodies()
                        setMoving(true, 3)
                        tpTo(sh.CFrame)
                        local inv = sh:FindFirstChild("invoke")
                        if inv then
                            pcall(function() fire(inv, LocalPlayer) end)
                        end
                        local cd = sh:FindFirstChildWhichIsA("ClickDetector")
                        if cd and fireclickdetector then
                            pcall(fireclickdetector, cd)
                        end
                        task.wait(0.15)
                        setMoving(false)
                        Scroll.tried(v, v.Parent == nil or sh.Parent == nil)
                    end
                end
            end
        end
        scan(Workspace:FindFirstChild("GLOBALTIME"))
        scan(Workspace)
        return found
    end
    local function listMobTypes()
        local map, out = {}, {}
        local folder = Workspace:FindFirstChild("npc")
        if folder then
            for _, v in ipairs(folder:GetChildren()) do
                if v.Name ~= "logtraining" and v:FindFirstChild("npctype") then
                    local t = tostring(v.npctype.Value)
                    if t ~= "" and not map[t] then
                        map[t] = true
                        out[#out + 1] = t
                    end
                end
            end
        end
        table.sort(out)
        return out
    end
    local function nearestPlayerChar()
        local hrp = root()
        if not hrp then return nil end
        local best, bestDist
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local ch = plr.Character
                local thrp = ch and ch:FindFirstChild("HumanoidRootPart")
                local th = ch and ch:FindFirstChildWhichIsA("Humanoid")
                if thrp and th and th.Health > 0 then
                    local d = (thrp.Position - hrp.Position).Magnitude
                    if not bestDist or d < bestDist then
                        best, bestDist = ch, d
                    end
                end
            end
        end
        return best
    end
    local Esp = {
        gen = MY_GEN,
        players = false, npcs = false,
        npcMode = "All",
        scrolls = false, givers = false,
        dist = 400,
        highlight = false, box = false,
        health = false, name = false, level = false,
        showDist = false,
        cache = {},
    }
    function Esp.parent()
        if type(gethui) == "function" then
            local ok, hui = pcall(gethui)
            if ok and hui then return hui end
        end
        local okCore, cg = pcall(game.GetService, game, "CoreGui")
        if okCore and cg then return cg end
        return LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end
    function Esp.remove(model)
        local c = model and Esp.cache[model]
        if not c then return end
        if c.text then pcall(function() c.text:Destroy() end) end
        if c.box then pcall(function() c.box:Destroy() end) end
        if c.hl then pcall(function() c.hl:Destroy() end) end
        Esp.cache[model] = nil
    end
    function Esp.clear()
        for m in pairs(Esp.cache) do Esp.remove(m) end
    end
    function Esp.ensureText(c, adornee)
        if c.text and c.text.Parent then
            c.text.Adornee = adornee
            return
        end
        local bb = Instance.new("BillboardGui")
        bb.Name = "DzTextESP" .. MY_GEN
        bb.Adornee = adornee
        bb.Size = UDim2.new(0, 200, 0, 100)
        bb.StudsOffset = Vector3.new(0, 2, 0)
        bb.AlwaysOnTop = true
        bb.Parent = Esp.parent()
        local box = Instance.new("Frame", bb)
        box.Name = "Container"
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundTransparency = 1
        box.ClipsDescendants = false
        local list = Instance.new("UIListLayout", box)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.VerticalAlignment = Enum.VerticalAlignment.Bottom
        for i, n in ipairs({ "Name", "Level", "Health", "Dist" }) do
            local l = Instance.new("TextLabel", box)
            l.Name = n
            l.LayoutOrder = i
            l.Size = UDim2.new(1, 0, 0, 13)
            l.BackgroundTransparency = 1
            l.Font = Enum.Font.GothamBold
            l.TextSize = 13
            l.TextColor3 = Color3.new(1, 1, 1)
            l.TextStrokeTransparency = 0
            l.TextStrokeColor3 = Color3.new(0, 0, 0)
            l.Visible = false
        end
        c.text = bb
    end
    function Esp.isBoss(v)
        return v:FindFirstChild("megaboss") ~= nil
            or v:FindFirstChild("rpaw") ~= nil
            or v:FindFirstChild("tails") ~= nil
    end
    function Esp.npcAllowed(v)
        local mode = Esp.npcMode
        if mode == "Bosses" then return Esp.isBoss(v) end
        if mode == "Mission Target" then
            local txt = missionText()
            if txt == "" then return false end
            local n = getNpcDisplayName(v)
            return n ~= nil and (txt:find(n, 1, true) ~= nil or n:find(txt, 1, true) ~= nil)
        end
        return true
    end
    function Esp.tag(key, adornee, title, sub, tint)
        local myHrp = root()
        local d = myHrp and (myHrp.Position - adornee.Position).Magnitude or math.huge
        if d > Esp.dist then
            Esp.remove(key)
            return false
        end
        local c = Esp.cache[key]
        if not c then c = {}; Esp.cache[key] = c end
        Esp.ensureText(c, adornee)
        local box = c.text and c.text:FindFirstChild("Container")
        if not box then return true end
        local lName = box:FindFirstChild("Name")
        if lName then
            lName.Visible = true
            lName.Text = title
            lName.TextColor3 = tint
        end
        local lSub = box:FindFirstChild("Level")
        if lSub then
            lSub.Visible = sub ~= nil
            if sub then lSub.Text = sub end
        end
        local lHp = box:FindFirstChild("Health")
        if lHp then lHp.Visible = false end
        local lDist = box:FindFirstChild("Dist")
        if lDist then
            lDist.Visible = Esp.showDist
            if Esp.showDist then lDist.Text = math.floor(d) .. "m" end
        end
        return true
    end
    function Esp.levelOf(entity, isPlayer)
        local v
        if isPlayer then
            local plr = Players:GetPlayerFromCharacter(entity)
            pcall(function() v = plr.statz.lvl.lvl.Value end)
        else
            local l = entity:FindFirstChild("lvl")
            v = l and tonumber(l.Value)
        end
        return v
    end
    function Esp.update(entity, isPlayer)
        local hrp = entity and entity.Parent and entity:FindFirstChild("HumanoidRootPart")
        local h = hrp and entity:FindFirstChildWhichIsA("Humanoid")
        if not h or h.Health <= 0 then
            Esp.remove(entity)
            return
        end
        local myHrp = root()
        local d = myHrp and (myHrp.Position - hrp.Position).Magnitude or math.huge
        if d > Esp.dist then
            Esp.remove(entity)
            return
        end
        local c = Esp.cache[entity]
        if not c then c = {}; Esp.cache[entity] = c end
        local tint = isPlayer and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 60, 60)
        if Esp.highlight then
            if not c.hl or c.hl.Parent ~= entity then
                if c.hl then pcall(function() c.hl:Destroy() end) end
                local hl = Instance.new("Highlight")
                hl.Adornee = entity
                hl.FillColor = tint
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Parent = entity
                c.hl = hl
            end
        elseif c.hl then
            pcall(function() c.hl:Destroy() end)
            c.hl = nil
        end
        if Esp.box then
            if not c.box or not c.box.Parent then
                local bb = Instance.new("BillboardGui")
                bb.Name = "DzBoxESP" .. MY_GEN
                bb.Adornee = hrp
                bb.Size = UDim2.new(4.5, 0, 6, 0)
                bb.AlwaysOnTop = true
                bb.Parent = Esp.parent()
                local f = Instance.new("Frame", bb)
                f.Size = UDim2.new(1, 0, 1, 0)
                f.BackgroundTransparency = 1
                local s = Instance.new("UIStroke", f)
                s.Thickness = 1.5
                s.Color = tint
                c.box = bb
            end
        elseif c.box then
            pcall(function() c.box:Destroy() end)
            c.box = nil
        end
        Esp.ensureText(c, entity:FindFirstChild("Head") or hrp)
        local box = c.text and c.text:FindFirstChild("Container")
        if not box then return end
        local lName = box:FindFirstChild("Name")
        if lName then
            lName.Visible = Esp.name
            if Esp.name then
                lName.Text = isPlayer and entity.Name or (getNpcDisplayName(entity) or entity.Name)
                lName.TextColor3 = tint
            end
        end
        local lLvl = box:FindFirstChild("Level")
        if lLvl then
            local lvl = Esp.level and Esp.levelOf(entity, isPlayer) or nil
            lLvl.Visible = lvl ~= nil
            if lvl then lLvl.Text = "Lv " .. tostring(lvl) end
        end
        local lHp = box:FindFirstChild("Health")
        if lHp then
            lHp.Visible = Esp.health
            if Esp.health then
                local hp = math.floor(h.Health)
                local max = math.max(math.floor(h.MaxHealth), 1)
                lHp.Text = string.format("%d/%d [%d%%]", hp, max, math.floor(hp / max * 100))
                lHp.TextColor3 = Color3.fromHSV(math.clamp(hp / max * 0.33, 0, 0.33), 1, 1)
            end
        end
        local lDist = box:FindFirstChild("Dist")
        if lDist then
            lDist.Visible = Esp.showDist
            if Esp.showDist then lDist.Text = math.floor(d) .. "m" end
        end
    end
    local function destroyFlyBody()
        if state.flyBV then
            pcall(function() state.flyBV:Destroy() end)
            state.flyBV = nil
        end
        if state.flyBG then
            pcall(function() state.flyBG:Destroy() end)
            state.flyBG = nil
        end
        local h = hum()
        if h then pcall(function() h.PlatformStand = false end) end
    end
    local function stopFly()
        state.flags.fly = false
        destroyFlyBody()
    end
    local function startFly()
        destroyFlyBody()
        state.flags.fly = true
        local hrp = root()
        if not hrp then
            state.flags.fly = false
            return
        end
        pcall(function()
            local bg = Instance.new("BodyGyro")
            bg.P = 9e4
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            state.flyBG = bg
            state.flyBV = bv
        end)
    end
    track(UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe or not alive() then return end
        local k = inp.KeyCode
        if k == Enum.KeyCode.W then state.flyKeys.w = true
        elseif k == Enum.KeyCode.A then state.flyKeys.a = true
        elseif k == Enum.KeyCode.S then state.flyKeys.s = true
        elseif k == Enum.KeyCode.D then state.flyKeys.d = true
        elseif k == Enum.KeyCode.Space then state.flyKeys.up = true
        elseif k == Enum.KeyCode.LeftControl then state.flyKeys.down = true
        end
    end))
    track(UserInputService.InputEnded:Connect(function(inp)
        local k = inp.KeyCode
        if k == Enum.KeyCode.W then state.flyKeys.w = false
        elseif k == Enum.KeyCode.A then state.flyKeys.a = false
        elseif k == Enum.KeyCode.S then state.flyKeys.s = false
        elseif k == Enum.KeyCode.D then state.flyKeys.d = false
        elseif k == Enum.KeyCode.Space then state.flyKeys.up = false
        elseif k == Enum.KeyCode.LeftControl then state.flyKeys.down = false
        end
    end))
    track(RunService.RenderStepped:Connect(function()
        if not alive() or not state.flags.fly then return end
        local hrp = root()
        local cam = Workspace.CurrentCamera
        if not hrp or not cam or not state.flyBV or not state.flyBG then return end
        local spd = state.cfg.flySpeed or 80
        local move = Vector3.zero
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local keys = state.flyKeys
        if keys.w then move = move + look end
        if keys.s then move = move - look end
        if keys.a then move = move - right end
        if keys.d then move = move + right end
        if keys.up then move = move + Vector3.yAxis end
        if keys.down then move = move - Vector3.yAxis end
        if move.Magnitude > 0 then
            state.flyBV.Velocity = move.Unit * spd
        else
            state.flyBV.Velocity = Vector3.zero
        end
        state.flyBG.CFrame = cam.CFrame
    end))
    track(UserInputService.JumpRequest:Connect(function()
        if state.flags.infJump then
            local h = hum()
            if h then
                pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
            end
        end
    end))
    local function ensureLightSnapshot()
        if state.lightingSnapshot then return end
        pcall(function()
            state.lightingSnapshot = {
                Brightness      = Lighting.Brightness,
                ClockTime       = Lighting.ClockTime,
                FogEnd          = Lighting.FogEnd,
                FogStart        = Lighting.FogStart,
                GlobalShadows   = Lighting.GlobalShadows,
                Ambient         = Lighting.Ambient,
                OutdoorAmbient  = Lighting.OutdoorAmbient,
            }
        end)
    end
    local function restoreLighting()
        local snap = state.lightingSnapshot
        if not snap then return end
        pcall(function()
            Lighting.Brightness     = snap.Brightness
            Lighting.ClockTime      = snap.ClockTime
            Lighting.FogEnd         = snap.FogEnd
            Lighting.FogStart       = snap.FogStart
            Lighting.GlobalShadows  = snap.GlobalShadows
            Lighting.Ambient        = snap.Ambient
            Lighting.OutdoorAmbient = snap.OutdoorAmbient
        end)
        state.lightingSnapshot = nil
    end
    local function applyVisuals()
        local f = state.flags
        if f.fullbright or f.noFog then ensureLightSnapshot() end
        if f.fullbright then
            pcall(function()
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(178, 178, 178)
                Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            end)
        end
        if f.noFog then
            pcall(function()
                Lighting.FogEnd = 1e9
                Lighting.FogStart = 1e9
            end)
        end
        if not f.fullbright and not f.noFog and state.lightingSnapshot then
            restoreLighting()
        end
    end
    local lastFpsSweep = 0
    local function applyFpsBoost()
        if not state.flags.fpsBoost then return end
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        local now = tick()
        if now - lastFpsSweep < 3 then return end
        lastFpsSweep = now
        local ce = Workspace:FindFirstChild("ClientEffects")
        if ce then
            for _, v in ipairs(ce:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam")
                    or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    pcall(function() v.Enabled = false end)
                end
            end
        end
    end
    track(RunService.RenderStepped:Connect(function()
        if not alive() then return end
        local fov = state.cfg.fov or 0
        if fov > 0 then
            local cam = Workspace.CurrentCamera
            if cam then
                pcall(function() cam.FieldOfView = fov end)
            end
        end
    end))
    spawnLoop(function()
        while alive() do
            if state.flags.fullbright or state.flags.noFog or state.lightingSnapshot then
                pcall(applyVisuals)
            end
            if state.flags.fpsBoost then
                pcall(applyFpsBoost)
            end
            task.wait(0.5)
        end
    end)
    local CLAIM_GAP = 1.2
    local function entryReady(entry)
        if not entry then return false end
        local amount = entry:FindFirstChild("amount")
        local maxamount = entry:FindFirstChild("maxamount")
        local claim = entry:FindFirstChild("claim")
        if not amount or not maxamount or not claim then return false end
        return amount.Value >= maxamount.Value and not claim.Value
    end
    local function pendingRewards()
        local count, cash, spins = 0, 0, 0
        pcall(function()
            for _, q in ipairs(LocalPlayer.statz.mission:GetChildren()) do
                if entryReady(q) then
                    count = count + 1
                    cash = cash + ((q:FindFirstChild("cash") and q.cash.Value) or 0)
                    spins = spins + ((q:FindFirstChild("spins") and q.spins.Value) or 0)
                end
            end
            for _, m in ipairs(LocalPlayer.statz.mainmission:GetChildren()) do
                if entryReady(m) then
                    count = count + 1
                    cash = cash + ((m:FindFirstChild("cash") and m.cash.Value) or 0)
                    spins = spins + ((m:FindFirstChild("spins") and m.spins.Value) or 0)
                end
            end
        end)
        return count, cash, spins
    end
    local function claimEntry(entry, cmd)
        if not entryReady(entry) then return false end
        local c = entry:FindFirstChild("claim")
        for _ = 1, 3 do
            fire(startevent, cmd, entry)
            local t = tick()
            while tick() - t < 1.5 do
                if c and c.Value then
                    return true,
                        (entry:FindFirstChild("cash") and entry.cash.Value) or 0,
                        (entry:FindFirstChild("spins") and entry.spins.Value) or 0
                end
                task.wait(0.1)
            end
        end
        return false
    end
    local function claimReady()
        local got, ryo, spins = 0, 0, 0
        local sz = LocalPlayer:FindFirstChild("statz")
        for _, par in ipairs({ { "mission", "claim" }, { "mainmission", "claim2" } }) do
            local folder = sz and sz:FindFirstChild(par[1])
            if folder then
                for _, entry in ipairs(folder:GetChildren()) do
                    if not alive() then break end
                    local ok, c, s = claimEntry(entry, par[2])
                    if ok then
                        got, ryo, spins = got + 1, ryo + c, spins + s
                        task.wait(CLAIM_GAP)
                    end
                end
            end
        end
        if got > 0 then
            state.session.claims = state.session.claims + got
        end
        return got, ryo, spins
    end
    local function statNow(name)
        local v
        pcall(function()
            v = LocalPlayer.statz:FindFirstChild(name) and LocalPlayer.statz[name].Value
        end)
        return v or 0
    end
    local function levelNow()
        local v
        pcall(function() v = LocalPlayer.statz.lvl.lvl.Value end)
        return v or 0
    end
    local function sessionReport()
        local s = state.session
        local mins = math.floor((tick() - s.start) / 60)
        return string.format(
            "%dm - Ryo +%d - Spins +%d - Lvl +%d - Claims %d",
            mins,
            statNow("cash") - s.startCash,
            statNow("spins") - s.startSpins,
            levelNow() - s.startLvl,
            s.claims
        )
    end
    spawnLoop(function()
        while alive() do
            if state.flags.autoClaim and select(1, pendingRewards()) > 0 then
                pcall(claimReady)
            end
            task.wait(15)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.playerLock then
                state.lockPlayer = nearestPlayerChar()
            else
                state.lockPlayer = nil
            end
            task.wait(0.2)
        end
    end)
    spawnLoop(function()
        while alive() do
            if not (Esp.players or Esp.npcs or Esp.scrolls or Esp.givers) then
                if next(Esp.cache) then Esp.clear() end
                task.wait(0.3)
            else
                pcall(function()
                    local live = {}
                    if Esp.players then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                live[plr.Character] = true
                                Esp.update(plr.Character, true)
                            end
                        end
                    end
                    if Esp.npcs then
                        local folder = Workspace:FindFirstChild("npc")
                        if folder then
                            for _, v in ipairs(folder:GetChildren()) do
                                if v:IsA("Model") and v.Name ~= "logtraining"
                                    and not isCompanion(v) and Esp.npcAllowed(v) then
                                    live[v] = true
                                    Esp.update(v, false)
                                end
                            end
                        end
                    end
                    if Esp.scrolls then
                        local function scan(c)
                            if not c then return end
                            for _, v in ipairs(c:GetChildren()) do
                                local sh = v:IsA("Model") and v:FindFirstChild("sh")
                                if sh and sh:IsA("BasePart")
                                    and sh.Position.Y > -1000 and sh.Position.Y < 2000 then
                                    if Esp.tag(v, sh, "Scroll", nil, Color3.fromRGB(255, 210, 70)) then
                                        live[v] = true
                                    end
                                end
                            end
                        end
                        scan(Workspace:FindFirstChild("GLOBALTIME"))
                        scan(Workspace)
                    end
                    if Esp.givers then
                        local bd = Workspace:FindFirstChild("bossdropmission")
                        local missions = bd and bd:FindFirstChild("missions")
                        if missions then
                            for _, pack in ipairs(missions:GetChildren()) do
                                local mg = pack:FindFirstChild("missiongiver")
                                local hrp = mg and mg:FindFirstChild("HumanoidRootPart")
                                if hrp and hrp.Position.Y > -1000 then
                                    local w = bossWait(mg)
                                    local sub, tint
                                    if w <= 0 then
                                        sub, tint = "READY", Color3.fromRGB(90, 235, 120)
                                    else
                                        sub = string.format("%d:%02d", math.floor(w / 60), math.floor(w % 60))
                                        tint = Color3.fromRGB(235, 170, 70)
                                    end
                                    if Esp.tag(mg, hrp, pack.Name, sub, tint) then
                                        live[mg] = true
                                    end
                                end
                            end
                        end
                    end
                    for m in pairs(Esp.cache) do
                        if not live[m] then Esp.remove(m) end
                    end
                end)
                task.wait(0.1)
            end
        end
    end)
    task.spawn(function()
        while alive() do task.wait(0.5) end
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        table.clear(conns)
        clearHoldBodies()
        pcall(function() RunService:UnbindFromRenderStep("DzShindoCamLook" .. MY_GEN) end)
        pcall(Esp.clear)
        pcall(function()
            local parent = Esp.parent()
            if not parent then return end
            local mine = tostring(MY_GEN)
            for _, d in ipairs(parent:GetDescendants()) do
                if d:IsA("BillboardGui") then
                    local n = d.Name
                    if n == "DzTextESP" .. mine or n == "DzBoxESP" .. mine then
                        pcall(function() d:Destroy() end)
                    end
                end
            end
        end)
        state.spiritBusy = false
        setMoving(false)
        pcall(releaseFacing)
        pcall(function()
            for p in pairs(charOff) do
                if p.Parent then p.CanCollide = true end
            end
            table.clear(charOff)
        end)
        for k in pairs(state.flags) do state.flags[k] = false end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.scrollFarm then
                Turn.run("scrollFarm", function()
                    if not charReady() then
                        Turn.step("scrollFarm", "busy")
                        task.wait(1)
                        return
                    end
                    local found = grabScrolls()
                    if found then
                        okStep("scrollFarm")
                        Turn.step("scrollFarm", "busy")
                    else
                        Turn.step("scrollFarm", "empty")
                    end
                    if state.flags.scrollSmartHop then
                        local players = #Players:GetPlayers()
                        local tooSmall = players < (state.cfg.hopMinPlayers or 4)
                        local stale = (tick() - state.lastScrollSeen) >= (state.cfg.scrollWait or 12)
                        local hopReady = (tick() - state.lastHop) >= 30
                        if (tooSmall or (stale and not found)) and hopReady then
                            state.lastHop = tick()
                            state.lastScrollSeen = tick()
                            notify("Scrolls", "Hopping for a better server...")
                            hopServer("range")
                            task.wait(5)
                        end
                    end
                end)
            end
            task.wait(0.2)
        end
    end)
    local Dungeon = {
        MAPS = {
            "Training Grounds", "Des Exams", "Samurai Bridge", "Sen Exams",
            "Narumaki Bridge", "Ember Hideout", "Sovereign Summit", "Dawn Hideout",
            "Shindai Valley", "Korashi Manor", "Mount Maki", "Tyn Stone",
        },
        DIFFS = { "Easy", "Medium", "Hard" },
        slot = 1,
        diff = "easy",
        dd = nil,
        names = {},
        sentDiff = false,
        lbl = {},
    }
    function Dungeon.list()
        local out = {}
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        gui = gui and gui:FindFirstChild("teleport")
        gui = gui and gui:FindFirstChild("serverframe")
        gui = gui and gui:FindFirstChild("top")
        gui = gui and gui:FindFirstChild("BossTab")
        if gui then
            for _, f in ipairs(gui:GetChildren()) do
                local n = tonumber(f.Name)
                local icon = f:FindFirstChild("icon")
                local lbl = icon and icon:FindFirstChild("lvl")
                if n and lbl then
                    local nm = tostring(lbl.Text):gsub("^%s*%[", ""):gsub("%]%s*$", ""):gsub("%s+", " ")
                    out[#out + 1] = { slot = n, name = nm }
                end
            end
        end
        local live = #out > 0
        if not live then
            for i, nm in ipairs(Dungeon.MAPS) do out[i] = { slot = i, name = nm } end
        end
        table.sort(out, function(a, b) return a.slot < b.slot end)
        return out, live
    end
    function Dungeon.items()
        local items = {}
        Dungeon.names = {}
        local list, live = Dungeon.list()
        for _, e in ipairs(list) do
            local label = e.slot .. " - " .. e.name
            items[#items + 1] = label
            Dungeon.names[label] = e.slot
        end
        return items, live
    end
    function Dungeon.comma(n)
        local s, k = tostring(math.floor(tonumber(n) or 0)), nil
        repeat s, k = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2") until k == 0
        return s
    end
    function Dungeon.rewards(slot)
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        gui = gui and gui:FindFirstChild("teleport")
        gui = gui and gui:FindFirstChild("serverframe")
        gui = gui and gui:FindFirstChild("top")
        gui = gui and gui:FindFirstChild("BossTab")
        local f = gui and gui:FindFirstChild(tostring(slot))
        local d = f and f:FindFirstChild("dungeon")
        if not d then return nil end
        local function num(name)
            local v = d:FindFirstChild(name)
            return v and tonumber(v.Value) or 0
        end
        local out = { ryo = num("ryo"), ryo2 = num("ryo2"), spin = num("spin"), exp = num("exp") }
        local drop = d:FindFirstChild("bloodline") or d:FindFirstChild("mode")
        if drop then
            local aj = ReplicatedStorage:FindFirstChild("alljutsu")
            local obj = aj and (aj:FindFirstChild(drop.Value)
                or (aj:FindFirstChild("modes") and aj.modes:FindFirstChild(drop.Value)))
            local real = obj and obj:FindFirstChild("REALNAME")
            out.drop = real and real.Value or tostring(drop.Value)
            local mx = drop:FindFirstChild("max")
            out.dropOdds = mx and tonumber(mx.Value) or nil
        end
        local gp = d:FindFirstChild("gamepass")
        if gp then
            out.pass = tostring(gp.Value)
            local mx = gp:FindFirstChild("max")
            out.passOdds = mx and tonumber(mx.Value) or nil
        end
        return out
    end
    function Dungeon.showRewards()
        local L = Dungeon.lbl
        if not L.money then return end
        local r = Dungeon.rewards(Dungeon.slot)
        if not r then
            L.money:SetText("Rewards: only readable in the dungeon lobby.")
            L.exp:SetText("")
            L.drop:SetText("")
            L.pass:SetText("")
            return
        end
        L.money:SetText(("Ryo %s - Ryo2 %s - Spins %d")
            :format(Dungeon.comma(r.ryo), Dungeon.comma(r.ryo2), r.spin))
        L.exp:SetText("EXP " .. Dungeon.comma(r.exp))
        L.drop:SetText(r.drop
            and ("Drop [1/" .. tostring(r.dropOdds or "?") .. "] " .. r.drop)
            or "Drop: - ")
        L.pass:SetText(r.pass
            and ("Gamepass [1/" .. tostring(r.passOdds or "?") .. "] " .. r.pass)
            or "Gamepass: - ")
    end
    function Dungeon.remote()
        local z = Workspace:FindFirstChild("zetsugamemode")
        if not z then return nil end
        return z:FindFirstChild("get") or z:FindFirstChildWhichIsA("RemoteEvent")
    end
    function Dungeon.isLeader()
        local cp = LocalPlayer:FindFirstChild("currentparty")
        local party = cp and cp.Value
        local p1 = party and party:FindFirstChild("p1")
        return p1 ~= nil and p1.Value == LocalPlayer
    end
    function Dungeon.start()
        local queue = LocalPlayer:FindFirstChild("pressplay")
        if not queue then return false, "Not in the dungeon lobby." end
        if not Dungeon.isLeader() then
            return false, "Only the party leader can start a dungeon."
        end
        if not pcall(fire, queue, "dungeon" .. tostring(Dungeon.slot)) then
            return false, "The queue remote didn't take the request."
        end
        return true
    end
    function Dungeon.setDiff()
        local ev = Dungeon.remote()
        if not ev then return false end
        return pcall(fire, ev, Dungeon.diff)
    end
    spawnLoop(function()
        while alive() do
            if state.flags.autoDungeonStart and not cooling("autoDungeonStart") then
                local ok, why = Dungeon.start()
                if ok then
                    okStep("autoDungeonStart")
                    coolFor("autoDungeonStart", 5)
                else
                    failStep("autoDungeonStart", 6, 10, why)
                end
            end
            task.wait(0.5)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.dungeonAutoDiff then
                local ev = Dungeon.remote()
                if not ev then
                    Dungeon.sentDiff = false
                elseif not Dungeon.sentDiff then
                    Dungeon.sentDiff = true
                    pcall(fire, ev, Dungeon.diff)
                    notify("Dungeon", "Difficulty set to " .. Dungeon.diff .. ".")
                end
            end
            task.wait(1)
        end
    end)
    local VoidFarm = {
        voided = 0, last = "", covers = 0, total = 0,
        ceilY = nil, underY = nil, phase = "off",
        MODE = "BOSSDROPwormsage",
        warned = false,
        lastCast = 0,
        dry = 0,
        toldThick = false,
        dodgeAt = 0, dodgeA = 0,
        blocked = nil,
        tune = {}, tuned = {},
        CD_PAD = 5,
    }
    function VoidFarm.hasMode()
        local sz = LocalPlayer:FindFirstChild("statz")
        local u = sz and sz:FindFirstChild("unlocked")
        if not u then return false end
        return u:FindFirstChild(VoidFarm.MODE .. "scroll") ~= nil
            or u:FindFirstChild(VoidFarm.MODE) ~= nil
    end
    function VoidFarm.modeKey()
        local sz = LocalPlayer:FindFirstChild("statz")
        local keys = sz and sz:FindFirstChild("keys")
        if not keys then return nil end
        for _, k in ipairs(keys:GetChildren()) do
            local v = tostring(k.Value)
            if v:find("wormsage") then return k.Name end
        end
        return nil
    end
    function VoidFarm.modeOn()
        local ch = LocalPlayer.Character
        local cb = ch and ch:FindFirstChild("combat")
        local kg = cb and cb:FindFirstChild("KG")
        local cm = kg and kg:FindFirstChild("currentmode")
        return cm ~= nil and tostring(cm.Value) == VoidFarm.MODE
    end
    function VoidFarm.transform()
        if VoidFarm.modeOn() then return true end
        local ch = LocalPlayer.Character
        local cb = ch and ch:FindFirstChild("combat")
        local upd = cb and cb:FindFirstChild("update")
        local key = VoidFarm.modeKey()
        if not upd or not key then return false end
        fire(upd, "key", key)
        task.wait(2.2)
        fire(upd, "key", key .. "end")
        local t = tick()
        local on = false
        while tick() - t < 2 do
            if VoidFarm.modeOn() then on = true break end
            task.wait(0.1)
        end
        if not on then return false end
        task.wait(3)
        return VoidFarm.modeOn()
    end
    function VoidFarm.casting()
        local ch = LocalPlayer.Character
        return ch ~= nil and ch:FindFirstChild("invisibleshark") ~= nil
    end
    function VoidFarm.cooldown()
        local aj = ReplicatedStorage:FindFirstChild("alljutsu")
        local modes = aj and aj:FindFirstChild("modes")
        local mode = modes and modes:FindFirstChild(VoidFarm.MODE)
        local cd = mode and mode:FindFirstChild("cooldown")
        return tonumber(cd and cd.Value) or 20
    end
    function VoidFarm.cdLeft()
        local since = tick() - (VoidFarm.lastCast or 0)
        return math.max(0, VoidFarm.cooldown() + VoidFarm.CD_PAD - since)
    end
    function VoidFarm.mobs()
        local out = {}
        local folder = Workspace:FindFirstChild("npc")
        if not folder then return out end
        for _, v in ipairs(folder:GetChildren()) do
            local thrp = v:IsA("Model") and v:FindFirstChild("HumanoidRootPart")
            local h = thrp and v:FindFirstChildWhichIsA("Humanoid")
            if h and h.Health > 0 and thrp.Position.Y > -1000
                and v.Name ~= "logtraining"
                and v:FindFirstChild("npctype")
                and not isCompanion(v)
                and not npcFalling(v)
                and not (v:FindFirstChild("rpaw") or v:FindFirstChild("lbpaw")
                         or v:FindFirstChild("tails"))
            then
                out[#out + 1] = v
            end
        end
        return out
    end
    function VoidFarm.near(spot, radius)
        local list = {}
        for _, v in ipairs(VoidFarm.mobs()) do
            local p = v.HumanoidRootPart.Position
            local flat = (Vector3.new(p.X, spot.Y, p.Z) - spot).Magnitude
            if flat <= radius then list[#list + 1] = v end
        end
        return list
    end
    function VoidFarm.ceiling(from)
        local cached = state.arenaFloorY
        if cached and from.Y < cached then return cached end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local skip = { LocalPlayer.Character }
        local npcs = Workspace:FindFirstChild("npc")
        if npcs then skip[#skip + 1] = npcs end
        params.FilterDescendantsInstances = skip
        local hit = Workspace:Raycast(from, Vector3.new(0, -400, 0), params)
            or Workspace:Raycast(from, Vector3.new(0, 4000, 0), params)
        if not hit then return cached end
        state.arenaFloorY = hit.Position.Y
        return state.arenaFloorY
    end
    function VoidFarm.underside(origin, limite)
        if state.arenaUnderY then return state.arenaUnderY end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local skip = { LocalPlayer.Character }
        local npcs = Workspace:FindFirstChild("npc")
        if npcs then skip[#skip + 1] = npcs end
        params.FilterDescendantsInstances = skip
        local up = Workspace:Raycast(origin, Vector3.new(0, 4000, 0), params)
        if not up then return nil end
        local y = up.Position.Y
        if limite and y > limite + 1 then return nil end
        state.arenaUnderY = y
        return y
    end
    function VoidFarm.mobFloor()
        local list = VoidFarm.mobs()
        if #list == 0 then return nil end
        local ys = {}
        for _, v in ipairs(list) do
            ys[#ys + 1] = v.HumanoidRootPart.Position.Y
        end
        table.sort(ys)
        return ys[math.ceil(#ys / 2)]
    end
    function VoidFarm.findSpot(x0, z0)
        local mobGround = VoidFarm.mobFloor()
        if not mobGround then return nil end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local skip = { LocalPlayer.Character }
        local npcs = Workspace:FindFirstChild("npc")
        if npcs then skip[#skip + 1] = npcs end
        params.FilterDescendantsInstances = skip
        local topFace = mobGround + 50
        local function ground(x, z)
            local d = Workspace:Raycast(Vector3.new(x, topFace, z), Vector3.new(0, -2000, 0), params)
            if not d then return nil end
            local y = d.Position.Y
            if math.abs(y - mobGround) > 300 then return nil end
            return y
        end
        local bestX, bestZ, topScore
        for dx = -500, 500, 250 do
            for dz = -500, 500, 250 do
                local x, z = x0 + dx, z0 + dz
                local y = ground(x, z)
                if y then
                    local eyePos = Vector3.new(x, y + 3, z)
                    local sum, smallest, degrau = 0, 500, 0
                    for i = 0, 7 do
                        local a = i * math.pi / 4
                        local dir = Vector3.new(math.cos(a), 0, math.sin(a))
                        local h = Workspace:Raycast(eyePos, dir * 500, params)
                        local d = h and (h.Position - eyePos).Magnitude or 500
                        sum = sum + d
                        if d < smallest then smallest = d end
                        local yy = ground(x + dir.X * 120, z + dir.Z * 120)
                        if yy then degrau = math.max(degrau, math.abs(yy - y)) end
                    end
                    local cellScore = smallest * 2 + sum / 8 - degrau * 5
                    if not topScore or cellScore > topScore then
                        topScore, bestX, bestZ = cellScore, x, z
                    end
                end
            end
        end
        return bestX, bestZ
    end
    function VoidFarm.autoTune(topY, base)
        local esp = math.max(0, topY - base)
        local want = {
            shindo_void_waitdepth = math.max(300, esp + 50),
            shindo_void_clear = math.clamp(28 - esp, 5, 25),
            shindo_void_rise = 0.45,
            shindo_void_pullhold = 6,
            shindo_void_wave = 3,
            shindo_void_mdmin = 60,
        }
        local farAway, me = 0, root()
        if me then
            for _, v in ipairs(VoidFarm.mobs()) do
                local p = v.HumanoidRootPart.Position
                local flat = (Vector3.new(p.X, me.Position.Y, p.Z) - me.Position).Magnitude
                if flat > farAway then farAway = flat end
            end
        end
        if farAway > 0 then
            want.shindo_void_radius = math.clamp(farAway + 150, 400, 2000)
        end
        for flag, val in pairs(want) do
            local s = VoidFarm.tune[flag]
            if s and VoidFarm.tuned[flag] ~= val then
                VoidFarm.tuned[flag] = val
                pcall(s.Set, s, val)
            end
        end
    end
    function VoidFarm.mdPercent()
        local ch = LocalPlayer.Character
        local cb = ch and ch:FindFirstChild("combat")
        local m = cb and cb:FindFirstChild("mode")
        if not m then return 0 end
        local max = m.MaxValue or 10000
        if max <= 0 then return 0 end
        return (m.Value / max) * 100
    end
    function VoidFarm.sit(cf)
        state.voidAnchor = cf
        local hrp = root()
        if not hrp then return end
        pcall(function()
            hrp.CFrame = cf
            hrp.AssemblyLinearVelocity = Vector3.zero
        end)
        Phys.freeze()
    end
    function VoidFarm.dodge(cf)
        local r = state.cfg.voidDodge or 0
        if r <= 0 then return cf end
        local now = tick()
        if now - VoidFarm.dodgeAt >= 0.35 then
            VoidFarm.dodgeAt = now
            VoidFarm.dodgeA = VoidFarm.dodgeA + 1.7 + math.random() * 2.6
        end
        local p = cf.Position
        return CFrame.new(
            p.X + math.cos(VoidFarm.dodgeA) * r,
            p.Y,
            p.Z + math.sin(VoidFarm.dodgeA) * r)
    end
    function VoidFarm.arm()
        if not (state.flags.voidFarm and state.flags.autoDungeon) then return end
        if state.voidAnchor then return end
        local hrp = root()
        if hrp then state.voidAnchor = hrp.CFrame end
    end
    function VoidFarm.pull()
        local ch = LocalPlayer.Character
        local cb = ch and ch:FindFirstChild("combat")
        local upd = cb and cb:FindFirstChild("update")
        local key = VoidFarm.modeKey()
        if not upd or not key then return false end
        fire(upd, "key", key)
        task.wait(0.05)
        fire(upd, "key", key .. "end")
        local t = tick()
        while tick() - t < 1.2 do
            if VoidFarm.casting() then
                VoidFarm.lastCast = tick()
                return true
            end
            task.wait(0.05)
        end
        return false
    end
    function VoidFarm.cycle()
        local function armed()
            return alive() and state.flags.voidFarm and state.flags.autoDungeon
        end
        if Arena.staging() then
            VoidFarm.phase = "waiting for the run to start"
            if not Arena.said then
                Arena.said = true
                notify("Dungeon", "Holding off while you pick the difficulty - the farm starts when the arena loads.")
            end
            task.wait(1)
            return
        end
        Arena.said = false
        if not VoidFarm.hasMode() then
            VoidFarm.phase = "no Worm Spirit Awaken (Sand Crawler drop)"
            if not VoidFarm.warned then
                VoidFarm.warned = true
                notify("Void Farm",
                    "Needs Worm Spirit Awaken - the Sand Crawler drop (1 in 16). Without it there's no pull to cast.")
            end
            task.wait(3)
            return
        end
        if not VoidFarm.modeKey() then
            VoidFarm.phase = "Worm Spirit Awaken not on a key"
            task.wait(3)
            return
        end
        local me = root()
        if not me then return end
        local ceilingY = VoidFarm.ceiling(me.Position)
        if not ceilingY then
            VoidFarm.phase = "no floor overhead"
            task.wait(1)
            return
        end
        VoidFarm.ceilY = ceilingY
        if state.flags.voidAuto and not state.arenaSpotX then
            local sx, sz = VoidFarm.findSpot(me.Position.X, me.Position.Z)
            if sx then
                state.arenaSpotX, state.arenaSpotZ = sx, sz
                state.arenaUnderY = nil
            end
        end
        local axisX = state.arenaSpotX or me.Position.X
        local axisZ = state.arenaSpotZ or me.Position.Z
        local axis = Vector3.new(axisX, ceilingY, axisZ)
        local depthBelow = math.max(state.cfg.voidWaitDepth or 300, 600)
        local base = VoidFarm.underside(
            Vector3.new(axis.X, ceilingY - depthBelow, axis.Z), ceilingY) or ceilingY
        VoidFarm.underY = base
        local topY = VoidFarm.mobFloor() or math.max(ceilingY, base)
        if state.flags.voidAuto then VoidFarm.autoTune(topY, base) end
        local bottomY  = CFrame.new(axis.X, topY - (state.cfg.voidWaitDepth or 300), axis.Z)
        local strike  = CFrame.new(axis.X, base - (state.cfg.voidClear or 25), axis.Z)
        local radiusVal   = state.cfg.voidRadius or 800
        if not VoidFarm.modeOn() then
            VoidFarm.sit(bottomY)
            local md = VoidFarm.mdPercent()
            local minMd = state.cfg.voidMdMin or 60
            if md < minMd then
                VoidFarm.phase = ("recharging MD %d%%/%d%%"):format(math.floor(md), minMd)
                local t = tick()
                while armed() and tick() - t < 1 do
                    VoidFarm.sit(VoidFarm.dodge(bottomY))
                    task.wait(0.1)
                end
                return
            end
            VoidFarm.phase = "transforming"
            if not VoidFarm.transform() then
                VoidFarm.phase = "transform failed - retrying"
                task.wait(2)
                return
            end
        end
        local t0 = tick()
        local peakGap, parado = 0, tick()
        while armed() and tick() - t0 < 60 do
            VoidFarm.sit(VoidFarm.dodge(bottomY))
            local nearCount = VoidFarm.near(axis, radiusVal)
            VoidFarm.covers, VoidFarm.total = #nearCount, #VoidFarm.mobs()
            local cd = VoidFarm.cdLeft()
            VoidFarm.phase = cd > 0
                and ("waiting - Z in %ds - wave %d"):format(math.ceil(cd), #nearCount)
                or ("waiting - MD %d%% - wave %d"):format(math.floor(VoidFarm.mdPercent()), #nearCount)
            if #nearCount > peakGap then peakGap, parado = #nearCount, tick() end
            if #nearCount > 0
                and tick() - parado > (state.cfg.voidWave or 3)
                and cd <= 0 then
                break
            end
            task.wait(0.1)
        end
        if not armed() then return end
        if not VoidFarm.modeOn() then
            VoidFarm.phase = "mode dropped - recharging"
            return
        end
        local stack = VoidFarm.near(axis, radiusVal)
        if #stack == 0 then
            VoidFarm.last = "nobody came"
            return
        end
        VoidFarm.phase = ("closing in on %d"):format(#stack)
        local aliveBefore = 0
        local heightBefore = {}
        for i, v in ipairs(stack) do
            local h = v:FindFirstChildWhichIsA("Humanoid")
            if h and h.Health > 0 then aliveBefore = aliveBefore + 1 end
            local t = v:FindFirstChild("HumanoidRootPart")
            heightBefore[i] = t and t.Position.Y or nil
        end
        local t1 = tick()
        while armed() and tick() - t1 < (state.cfg.voidRise or 0.45) do
            VoidFarm.sit(strike)
            task.wait()
        end
        if not VoidFarm.pull() then
            local cdNow = VoidFarm.cdLeft()
            VoidFarm.last = "Z refused"
            VoidFarm.phase = cdNow > 0
                and ("Z on cooldown - %ds"):format(math.ceil(cdNow))
                or "Z refused - retrying"
            local tf = tick()
            while armed() and tick() - tf < 0.5 do
                VoidFarm.sit(VoidFarm.dodge(bottomY))
                task.wait()
            end
            return
        end
        VoidFarm.phase = ("pulling %d"):format(#stack)
        local t2 = tick()
        while armed() and tick() - t2 < (state.cfg.voidPullHold or 6) do
            VoidFarm.sit(strike)
            task.wait()
        end
        local deadCount, mexeu = 0, false
        for i, v in ipairs(stack) do
            local h = v.Parent and v:FindFirstChildWhichIsA("Humanoid")
            if not v.Parent or (h and h.Health <= 0) then deadCount = deadCount + 1 end
            local t = v.Parent and v:FindFirstChild("HumanoidRootPart")
            if t and heightBefore[i] and (heightBefore[i] - t.Position.Y) > 5 then
                mexeu = true
            end
        end
        VoidFarm.voided = VoidFarm.voided + deadCount
        VoidFarm.last = ("%d/%d"):format(deadCount, aliveBefore)
        if deadCount == 0 and not mexeu then
            VoidFarm.dry = VoidFarm.dry + 1
        else
            VoidFarm.dry = 0
            VoidFarm.toldThick = false
            VoidFarm.blocked = nil
        end
        if VoidFarm.dry >= 2 then
            local esp = math.floor(topY - base)
            local gap = math.floor((heightBefore[1] or topY) - strike.Position.Y)
            VoidFarm.blocked = ("floor too thick (%d studs) - pull can't reach"):format(esp)
            if not VoidFarm.toldThick then
                VoidFarm.toldThick = true
                notify("Void Farm", string.format(
                    "This arena's floor is %d studs thick, so the cast sits %d studs under the mobs "
                    .. "and the pull can't reach. Use Farm Dungeon NPCs here instead.", esp, gap))
            end
        end
        VoidFarm.phase = "back down"
        local t3 = tick()
        while armed() and tick() - t3 < 0.5 do
            VoidFarm.sit(VoidFarm.dodge(bottomY))
            task.wait()
        end
    end
    spawnLoop(function()
        while alive() do
            if state.flags.autoDungeon and not state.flags.voidFarm
                and not Arena.staging() then
                Turn.run("autoDungeon", function()
                    local status = sweepStep("autoDungeon", function(v)
                        return v:FindFirstChild("npctype") ~= nil
                    end, function()
                        return state.flags.voidFarm or Arena.staging()
                    end)
                    if status == "empty" then Turn.release("autoDungeon") end
                end)
            end
            task.wait(state.cfg.farmWait)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.voidFarm and state.flags.autoDungeon then
                Turn.run("autoDungeon", function()
                    if not charReady() then task.wait(1) return end
                    VoidFarm.cycle()
                end)
            end
            task.wait(0.2)
        end
    end)
    spawnLoop(function()
        while alive() do
            if state.flags.questRush then
                combatFire("rushw")
                task.wait(0.25)
            elseif state.flags.questJump then
                combatFire("takemovement2")
                task.wait(0.25)
            elseif state.flags.questPunch then
                combatFire("mouse1", true)
                task.wait(0.28)
            elseif state.flags.questChi then
                combatFire("key", "c")
                task.wait(0.1)
                combatFire("key", "cend")
                task.wait(0.45)
            else
                task.wait(0.3)
            end
        end
    end)
    sec = Sub.FarmScroll:AddSection({ Name = "Scroll Farm", Icon = "scroll", Side = 1 })
    sec:AddToggle({
        Name = "Scroll Farm",
        Flag = "shindo_scroll_farm",
        Default = false,
        Callback = function(on)
            state.flags.scrollFarm = on
            if on then state.lastScrollSeen = tick() end
        end,
    })
    sec:AddToggle({
        Name = "Skip Drops Already Owned",
        Flag = "shindo_scroll_skipowned",
        Default = false,
        Callback = function(on) state.flags.scrollSkipOwned = on end,
    })
    sec:AddToggle({
        Name = "Smart Hop",
        Flag = "shindo_scroll_smarthop",
        Default = false,
        Callback = function(on) state.flags.scrollSmartHop = on end,
    })
    sec:AddSlider({
        Name = "No-Scroll Wait (s)",
        Flag = "shindo_scroll_wait",
        Min = 5, Max = 60, Default = 12, Decimals = 1,
        Callback = function(v) state.cfg.scrollWait = v end,
    })
    sec:AddSlider({
        Name = "Min Players",
        Flag = "shindo_scroll_hopmin",
        Min = 1, Max = 20, Default = 4, Decimals = 1,
        Callback = function(v) state.cfg.hopMinPlayers = v end,
    })
    sec:AddSlider({
        Name = "Max Players",
        Flag = "shindo_scroll_hopmax",
        Min = 5, Max = 40, Default = 18, Decimals = 1,
        Callback = function(v) state.cfg.hopMaxPlayers = v end,
    })
    sec = Sub.FarmReward:AddSection({ Name = "Daily & Main Missions", Icon = "gift", Side = 1 })
    sec:AddButton({
        Name = "Check Pending",
        Callback = function()
            local n, cash, spins = pendingRewards()
            if n == 0 then
                notify("Rewards", "Nothing ready to claim.")
            else
                notify("Rewards", string.format("%d ready - %d Ryo - %d Spins", n, cash, spins))
            end
        end,
    })
    sec:AddButton({
        Name = "Claim All Ready",
        Callback = function()
            task.spawn(function()
                local n = pendingRewards()
                if n == 0 then
                    notify("Rewards", "Nothing ready to claim.")
                    return
                end
                local got, ryo, spins = claimReady()
                if got == 0 then
                    notify("Rewards", "Nothing landed - try again in a moment.")
                else
                    notify("Rewards", string.format("Claimed %d - +%d Ryo - +%d Spins", got, ryo, spins))
                end
            end)
        end,
    })
    sec:AddToggle({
        Name = "Auto Claim Rewards",
        Flag = "shindo_rewards_autoclaim",
        Default = false,
        Callback = function(on) state.flags.autoClaim = on end,
    })
    sec = Sub.FarmDungeon:AddSection({ Name = "Dungeon Lobby", Icon = "door-open", Side = 1 })
    do
        local items = Dungeon.items()
        Dungeon.dd = sec:AddDropdown({
            Name = "Dungeon Map",
            Flag = "shindo_dungeon_map",
            Multi = false,
            SearchThreshold = 6,
            Items = items,
            Default = items[1],
            Callback = function(v)
                local s = (type(v) == "string") and Dungeon.names[v]
                if s then
                    Dungeon.slot = s
                    Dungeon.showRewards()
                end
            end,
        })
    end
    Dungeon.lbl.money = sec:AddLabel("Ryo - ")
    Dungeon.lbl.exp   = sec:AddLabel("EXP - ")
    Dungeon.lbl.drop  = sec:AddLabel("Drop - ")
    Dungeon.lbl.pass  = sec:AddLabel("Gamepass - ")
    Dungeon.showRewards()
    sec:AddButton({
        Name = "Refresh Map List",
        Callback = function()
            local items = Dungeon.items()
            pcall(function() Dungeon.dd:Refresh(items) end)
            Dungeon.showRewards()
            notify("Dungeon", #items .. " map(s) in the list.")
        end,
    })
    sec:AddButton({
        Name = "Start Selected Now",
        Callback = function()
            local ok, why = Dungeon.start()
            if not ok then notify("Dungeon", why) end
        end,
    })
    task.spawn(function()
        local deadline = tick() + 90
        local mapOk, charOk = false, false
        while alive() and tick() < deadline and not (mapOk and charOk) do
            task.wait(1)
            if not mapOk then
                local items, live = Dungeon.items()
                if live then
                    mapOk = true
                    pcall(function() Dungeon.dd:Refresh(items) end)
                    Dungeon.showRewards()
                end
            end
            if not charOk and charReady() then
                charOk = true
                pcall(function() Skills.dd:Refresh(Skills.items()) end)
                pcall(function() ScrollBoss.dd:Refresh(ScrollBoss.items()) end)
                Skills.at = 0
            end
        end
    end)
    sec:AddToggle({
        Name = "Auto Start Dungeon",
        Flag = "shindo_dungeon_start",
        Default = false,
        Callback = function(on) state.flags.autoDungeonStart = on end,
    })
    sec = Sub.FarmDungeon:AddSection({ Name = "Inside The Dungeon", Icon = "swords", Side = 2 })
    sec:AddDropdown({
        Name = "Difficulty",
        Flag = "shindo_dungeon_diff",
        Multi = false,
        Items = Dungeon.DIFFS,
        Default = "Easy",
        Callback = function(v)
            if type(v) == "string" then
                Dungeon.diff = v:lower()
                Dungeon.sentDiff = false
            end
        end,
    })
    sec:AddButton({
        Name = "Set Difficulty Now",
        Callback = function()
            if Dungeon.setDiff() then
                notify("Dungeon", "Difficulty set to " .. Dungeon.diff .. ".")
            else
                notify("Dungeon", "You're not inside a dungeon yet.")
            end
        end,
    })
    sec:AddToggle({
        Name = "Auto Set Difficulty",
        Flag = "shindo_dungeon_autodiff",
        Default = false,
        Callback = function(on)
            state.flags.dungeonAutoDiff = on
            if on then Dungeon.sentDiff = false end
        end,
    })
    sec:AddToggle({
        Name = "Farm Dungeon NPCs",
        Flag = "shindo_dungeon_farm",
        Default = false,
        Callback = function(on)
            state.flags.autoDungeon = on
            if on then VoidFarm.arm() end
        end,
    })
    do
        local vsec = Sub.FarmDungeon:AddSection({ Name = "Void Farm", Icon = "arrow-down-to-line", Side = 2 })
        vsec:AddToggle({
            Name = "Void Farm",
            Flag = "shindo_void_farm",
            Default = false,
            Callback = function(on)
                state.flags.voidFarm = on
                state.voidAnchor = nil
                state.arenaFloorY = nil
                state.arenaUnderY = nil
                state.arenaSpotX, state.arenaSpotZ = nil, nil
                if on then
                    state.lockTarget = nil
                    state.lockLog = nil
                    VoidFarm.arm()
                end
            end,
        })
        vsec:AddToggle({
            Name = "Auto Config (tunes itself per arena)",
            Flag = "shindo_void_auto",
            Default = false,
            Callback = function(on)
                state.flags.voidAuto = on
                state.arenaSpotX, state.arenaSpotZ = nil, nil
                table.clear(VoidFarm.tuned)
            end,
        })
        local vstate = vsec:AddLabel("Void Farm: off")
        local vnums  = vsec:AddLabel("voided 0 - wave 0/0")
        vsec:AddLabel("Turn on Farm Dungeon NPCs too - this replaces it.")
        vsec:AddLabel("Transforms alone and pulls each wave from under")
        vsec:AddLabel("the floor. Nothing else to set up.")
        local vtune = Sub.FarmDungeon:AddSection({
            Name = "Void Farm - Tuning", Icon = "sliders-horizontal", Side = 2 })
        vtune:AddLabel("With Auto Config on, these move by themselves - ")
        vtune:AddLabel("what you see here is what it picked for this arena.")
        local function tuneSlider(opts)
            VoidFarm.tune[opts.Flag] = vtune:AddSlider(opts)
        end
        tuneSlider({
            Name = "Wait Depth Below Mobs (studs)",
            Flag = "shindo_void_waitdepth",
            Min = 50, Max = 1000, Default = 300, Decimals = 10,
            Callback = function(v) state.cfg.voidWaitDepth = v end,
        })
        tuneSlider({
            Name = "Cast Depth Below Floor (studs)",
            Flag = "shindo_void_clear",
            Min = 1, Max = 100, Default = 25, Decimals = 1,
            Callback = function(v) state.cfg.voidClear = v end,
        })
        tuneSlider({
            Name = "Dodge While Waiting (studs, 0 = off)",
            Flag = "shindo_void_dodge",
            Min = 0, Max = 200, Default = 60, Decimals = 10,
            Callback = function(v) state.cfg.voidDodge = v end,
        })
        tuneSlider({
            Name = "Pull Radius (studs)",
            Flag = "shindo_void_radius",
            Min = 100, Max = 2000, Default = 800, Decimals = 10,
            Callback = function(v) state.cfg.voidRadius = v end,
        })
        tuneSlider({
            Name = "Rise Before Cast (s)",
            Flag = "shindo_void_rise",
            Min = 0.1, Max = 3, Default = 0.45, Decimals = 0.05,
            Callback = function(v) state.cfg.voidRise = v end,
        })
        tuneSlider({
            Name = "Pull Hold (s)",
            Flag = "shindo_void_pullhold",
            Min = 1, Max = 15, Default = 6, Decimals = 1,
            Callback = function(v) state.cfg.voidPullHold = v end,
        })
        tuneSlider({
            Name = "Wave Settle (s without growing)",
            Flag = "shindo_void_wave",
            Min = 0.5, Max = 15, Default = 3, Decimals = 0.5,
            Callback = function(v) state.cfg.voidWave = v end,
        })
        tuneSlider({
            Name = "Min MD To Transform (%)",
            Flag = "shindo_void_mdmin",
            Min = 0, Max = 100, Default = 60, Decimals = 1, Suffix = "%",
            Callback = function(v) state.cfg.voidMdMin = v end,
        })
        spawnLoop(function()
            while alive() do
                pcall(function()
                    local says
                    if not state.flags.voidFarm then
                        says = "off"
                    elseif not state.flags.autoDungeon then
                        says = "turn on Farm Dungeon NPCs"
                    elseif not LocalPlayer:FindFirstChild("statz") then
                        says = "can't tell here - no player data"
                    elseif not VoidFarm.hasMode() then
                        says = "LOCKED - Worm Spirit Awaken drops from Sand Crawler"
                    elseif not VoidFarm.modeKey() then
                        says = "Worm Spirit Awaken isn't on a key"
                    else
                        says = VoidFarm.blocked or VoidFarm.phase
                    end
                    vstate:SetText("Void Farm: " .. says)
                    local cd = VoidFarm.cdLeft()
                    local esp = (VoidFarm.ceilY and VoidFarm.underY)
                        and math.floor(VoidFarm.ceilY - VoidFarm.underY) or nil
                    vnums:SetText(("voided %d%s - MD %d%% - wave %d/%d%s"):format(
                        VoidFarm.voided,
                        VoidFarm.last ~= "" and (" (" .. VoidFarm.last .. ")") or "",
                        math.floor(VoidFarm.mdPercent()),
                        cd > 0 and (math.ceil(cd) .. "s") or "ready",
                        VoidFarm.covers, VoidFarm.total,
                        esp and (" - floor " .. esp .. " studs") or ""))
                end)
                task.wait(0.5)
            end
        end)
    end
    sec = Sub.UtilMove:AddSection({ Name = "Local", Icon = "person-standing", Side = 1 })
    sec:AddToggle({
        Name = "Noclip",
        Flag = "shindo_mv_noclip",
        Default = false,
        Callback = function(on) state.flags.noclip = on end,
    })
    sec:AddToggle({
        Name = "Speed / Jump",
        Flag = "shindo_mv_speed",
        Default = false,
        Callback = function(on)
            state.flags.speed = on
            if not on then
                local h = hum()
                if h then
                    pcall(function()
                        h.WalkSpeed = 16
                        h.JumpPower = 50
                    end)
                end
            end
        end,
    })
    sec:AddSlider({
        Name = "WalkSpeed",
        Flag = "shindo_mv_walkspeed",
        Min = 16, Max = 200, Default = 50, Decimals = 1,
        Callback = function(v) state.cfg.walkSpeed = v end,
    })
    sec:AddSlider({
        Name = "JumpPower",
        Flag = "shindo_mv_jumppower",
        Min = 50, Max = 200, Default = 50, Decimals = 1,
        Callback = function(v) state.cfg.jumpPower = v end,
    })
    sec:AddButton({
        Name = "Unstuck (force jump)",
        Callback = function()
            clearHoldBodies()
            pcall(function()
                for p in pairs(charOff) do
                    if p.Parent then p.CanCollide = true end
                end
                table.clear(charOff)
            end)
            releaseFacing()
            Phys.unstick(2)
            notify("Movement", "Physics unstuck - try jumping now.")
        end,
    })
    sec:AddToggle({
        Name = "Infinite Jump",
        Flag = "shindo_mv_infjump",
        Default = false,
        Callback = function(on) state.flags.infJump = on end,
    })
    sec:AddToggle({
        Name = "Anti Grip",
        Flag = "shindo_mv_antigrip",
        Default = false,
        Callback = function(on) state.flags.antiGrip = on end,
    })
    sec:AddLabel("Fly: WASD + Space (up) / LeftCtrl (down)")
    sec:AddToggle({
        Name = "Fly",
        Flag = "shindo_mv_fly",
        Default = false,
        Callback = function(on)
            if on then startFly() else stopFly() end
        end,
    })
    sec:AddSlider({
        Name = "Fly Speed",
        Flag = "shindo_mv_flyspeed",
        Min = 20, Max = 250, Default = 80, Decimals = 1,
        Callback = function(v) state.cfg.flySpeed = v end,
    })
    sec = Sub.UtilMove:AddSection({ Name = "Combat Assist", Icon = "shield", Side = 2 })
    sec:AddToggle({
        Name = "Anti Ragdoll",
        Flag = "shindo_mv_antiragdoll",
        Default = false,
        Callback = function(on) state.flags.antiRagdoll = on end,
    })
    sec:AddToggle({
        Name = "Infinite Stamina",
        Flag = "shindo_mv_infstamina",
        Default = false,
        Callback = function(on) state.flags.infStamina = on end,
    })
    sec = Sub.UtilMove:AddSection({ Name = "Visual", Icon = "eye", Side = 2 })
    sec:AddToggle({
        Name = "Fullbright",
        Flag = "shindo_vis_fullbright",
        Default = false,
        Callback = function(on)
            state.flags.fullbright = on
            pcall(applyVisuals)
        end,
    })
    sec:AddToggle({
        Name = "No Fog",
        Flag = "shindo_vis_nofog",
        Default = false,
        Callback = function(on)
            state.flags.noFog = on
            pcall(applyVisuals)
        end,
    })
    sec:AddToggle({
        Name = "FPS Boost",
        Flag = "shindo_vis_fpsboost",
        Default = false,
        Callback = function(on) state.flags.fpsBoost = on end,
    })
    sec:AddSlider({
        Name = "FOV (0 = off)",
        Flag = "shindo_vis_fov",
        Min = 0, Max = 120, Default = 0, Decimals = 1,
        Callback = function(v) state.cfg.fov = v end,
    })
    sec:AddToggle({
        Name = "Invisicam",
        Flag = "shindo_vis_invisicam",
        Default = false,
        Callback = function(on)
            state.flags.invisicam = on
            pcall(function()
                LocalPlayer.DevCameraOcclusionMode = on
                    and Enum.DevCameraOcclusionMode.Invisicam
                    or Enum.DevCameraOcclusionMode.Zoom
            end)
        end,
    })
    sec = Sub.UtilMove:AddSection({ Name = "PvP", Icon = "users", Side = 1 })
    sec:AddToggle({
        Name = "Lock Nearest Player",
        Flag = "shindo_pvp_lock",
        Default = false,
        Callback = function(on)
            state.flags.playerLock = on
            if not on then
                state.lockPlayer = nil
                releaseFacing()
            end
        end,
    })
    sec:AddSlider({
        Name = "Lock Distance",
        Flag = "shindo_pvp_lockdist",
        Min = 1, Max = 15, Default = 4, Decimals = 0.1,
        Callback = function(v) state.cfg.lockDistance = v end,
    })
    sec:AddButton({
        Name = "TP Nearest Player",
        Callback = function()
            local ch = nearestPlayerChar()
            local thrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if thrp then
                tpTo(thrp.CFrame * CFrame.new(0, 0, 3))
            else
                notify("Teleport", "No other player alive nearby.")
            end
        end,
    })
    sec = Sub.UtilEsp:AddSection({ Name = "Targets", Icon = "eye", Side = 1 })
    sec:AddToggle({
        Name = "ESP Players",
        Flag = "shindo_esp_players",
        Default = false,
        Callback = function(on) Esp.players = on end,
    })
    sec:AddToggle({
        Name = "ESP NPCs",
        Flag = "shindo_esp_npcs",
        Default = false,
        Callback = function(on) Esp.npcs = on end,
    })
    sec:AddDropdown({
        Name = "NPC Filter",
        Flag = "shindo_esp_npcmode",
        Multi = false,
        Items = { "All", "Bosses", "Mission Target" },
        Default = "All",
        Callback = function(v)
            if type(v) == "string" and v ~= Esp.npcMode then
                Esp.npcMode = v
                Esp.clear()
            end
        end,
    })
    sec:AddToggle({
        Name = "ESP Scrolls",
        Flag = "shindo_esp_scrolls",
        Default = false,
        Callback = function(on) Esp.scrolls = on end,
    })
    sec:AddToggle({
        Name = "ESP Boss Givers",
        Flag = "shindo_esp_givers",
        Default = false,
        Callback = function(on) Esp.givers = on end,
    })
    sec:AddSlider({
        Name = "ESP Distance",
        Flag = "shindo_esp_dist",
        Min = 50, Max = 5000, Default = 400, Decimals = 10,
        Callback = function(v) Esp.dist = v end,
    })
    sec:AddToggle({
        Name = "Highlight",
        Flag = "shindo_esp_highlight",
        Default = false,
        Callback = function(on) Esp.highlight = on end,
    })
    sec:AddToggle({
        Name = "Box",
        Flag = "shindo_esp_box",
        Default = false,
        Callback = function(on) Esp.box = on end,
    })
    sec = Sub.UtilEsp:AddSection({ Name = "Info", Icon = "list", Side = 2 })
    sec:AddLabel("Pick at least one line, or the ESP panel")
    sec:AddLabel("shows up empty over the target.")
    sec:AddToggle({
        Name = "Name",
        Flag = "shindo_esp_name",
        Default = false,
        Callback = function(on) Esp.name = on end,
    })
    sec:AddToggle({
        Name = "Level",
        Flag = "shindo_esp_level",
        Default = false,
        Callback = function(on) Esp.level = on end,
    })
    sec:AddToggle({
        Name = "Health",
        Flag = "shindo_esp_health",
        Default = false,
        Callback = function(on) Esp.health = on end,
    })
    sec:AddToggle({
        Name = "Distance",
        Flag = "shindo_esp_showdist",
        Default = false,
        Callback = function(on) Esp.showDist = on end,
    })
    sec = Sub.UtilTp:AddSection({ Name = "Waypoint", Icon = "flag", Side = 1 })
    sec:AddButton({
        Name = "Save Current Spot",
        Callback = function()
            local hrp = root()
            if hrp then
                state.savedWaypoint = hrp.CFrame
                notify("Waypoint", "Saved current position.")
            else
                notify("Waypoint", "No character.")
            end
        end,
    })
    sec:AddButton({
        Name = "Teleport To Saved",
        Callback = function()
            if state.savedWaypoint then
                tpTo(state.savedWaypoint)
            else
                notify("Waypoint", "Nothing saved yet.")
            end
        end,
    })
    sec = Sub.UtilTp:AddSection({ Name = "Mobs", Icon = "crosshair", Side = 2 })
    local mobList = listMobTypes()
    if #mobList == 0 then mobList = { "(none yet)" } end
    local mobDropdown = sec:AddDropdown({
        Name = "Mob Type",
        Flag = "shindo_tp_mob",
        Multi = false,
        SearchThreshold = 6,
        Items = mobList,
        Default = mobList[1],
        Callback = function(v)
            if type(v) == "string" and v ~= "(none yet)" then
                state.cfg.selectedMob = v
            end
        end,
    })
    sec:AddButton({
        Name = "Refresh Mob List",
        Callback = function()
            local found = listMobTypes()
            local values = #found > 0 and found or { "(none yet)" }
            pcall(function() mobDropdown:Refresh(values) end)
            notify("Mobs", #found > 0 and (#found .. " mob type(s) here.") or "No mobs spawned here.")
        end,
    })
    sec:AddButton({
        Name = "TP To Selected Mob",
        Callback = function()
            local want = state.cfg.selectedMob
            local folder = Workspace:FindFirstChild("npc")
            if not folder or not want then
                notify("TP", "Pick a mob type first.")
                return
            end
            for _, v in ipairs(folder:GetChildren()) do
                if v:FindFirstChild("npctype")
                    and tostring(v.npctype.Value) == want
                    and v:FindFirstChild("HumanoidRootPart") then
                    tpTo(v.HumanoidRootPart.CFrame * CFrame.new(0, -7, 0))
                    return
                end
            end
            notify("TP", "Mob not found right now.")
        end,
    })
    sec:AddButton({
        Name = "TP Nearest Enemy",
        Callback = function()
            local folder = Workspace:FindFirstChild("npc")
            local hrp = root()
            if not folder or not hrp then
                notify("TP", "No NPCs in this area.")
                return
            end
            local best, bestD
            for _, v in ipairs(folder:GetChildren()) do
                if v.Name ~= "logtraining"
                    and not isCompanion(v)
                    and v:FindFirstChild("HumanoidRootPart")
                    and v:FindFirstChild("Humanoid") then
                    local d = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if not bestD or d < bestD then best, bestD = v, d end
                end
            end
            if best then
                tpTo(best.HumanoidRootPart.CFrame * CFrame.new(0, -7, 0))
            else
                notify("TP", "No enemy found right now.")
            end
        end,
    })
    sec:AddButton({
        Name = "TP To Logs",
        Callback = function()
            local logNpc = findLog()
            if logNpc then
                prepareLog(logNpc)
                local cf = logFarmCFrame(logNpc)
                if cf then tpTo(cf) end
            else
                notify("Logs", "No training log found here.")
            end
        end,
    })
    sec = Sub.SrvMain:AddSection({ Name = "Server", Icon = "server", Side = 1 })
    sec:AddButton({
        Name = "Rejoin Server",
        Callback = function()
            if #Players:GetPlayers() <= 1 then
                pcall(function() LocalPlayer:Kick("\nRejoining...") end)
                task.wait()
                pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
            else
                if type(_dzEnv.DisableAntiTeleport) == "function" then
                    pcall(_dzEnv.DisableAntiTeleport)
                end
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end)
            end
        end,
    })
    sec:AddButton({
        Name = "Server Hop",
        Callback = function()
            task.spawn(function()
                if not hopServer() then notify("Server", "No other server available right now.") end
            end)
        end,
    })
    sec:AddButton({
        Name = "Small Server",
        Callback = function()
            task.spawn(function()
                if not hopServer("small") then notify("Server", "No other server available right now.") end
            end)
        end,
    })
    sec:AddButton({
        Name = "Force Reconnect",
        Callback = function()
            pcall(function() LocalPlayer:Kick("\nReconnecting...") end)
            task.wait(0.2)
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end,
    })
    sec = Sub.SrvPlace:AddSection({ Name = "Places", Icon = "map-pin", Side = 1 })
    local selectedPlace = "Ember"
    local placeDropdown
    placeDropdown = sec:AddDropdown({
        Name = "Destination",
        Flag = "shindo_tp_dest",
        Multi = false,
        SearchThreshold = 6,
        Items = PLACE_NAMES,
        Default = "Ember",
        Callback = function(v)
            if type(v) == "string" and PLACES[v] then selectedPlace = v end
        end,
    })
    sec:AddButton({
        Name = "Teleport",
        Callback = function()
            local id = PLACES[selectedPlace]
            if not id then
                notify("Teleport", "Pick a destination first.")
                return
            end
            if type(_dzEnv.DisableAntiTeleport) == "function" then
                pcall(_dzEnv.DisableAntiTeleport)
            end
            pcall(function() TeleportService:Teleport(id, LocalPlayer) end)
        end,
    })
    sec:AddButton({
        Name = "Go Menu",
        Callback = function()
            if type(_dzEnv.DisableAntiTeleport) == "function" then
                pcall(_dzEnv.DisableAntiTeleport)
            end
            pcall(function() TeleportService:Teleport(MENU, LocalPlayer) end)
        end,
    })
    sec:AddButton({
        Name = "Load All Places",
        Callback = function()
            task.spawn(function()
                local url = "https://develop.roblox.com/v1/universes/"
                    .. tostring(game.GameId) .. "/places?sortOrder=Asc&limit=100"
                local ok, raw = pcall(game.HttpGet, game, url)
                if not ok or type(raw) ~= "string" then
                    notify("Places", "Couldn't reach the Roblox API.")
                    return
                end
                local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
                if not ok2 or type(data) ~= "table" or type(data.data) ~= "table" then
                    notify("Places", "The API answered something unexpected.")
                    return
                end
                local added = 0
                for _, p in ipairs(data.data) do
                    if p.name and p.id and not PLACES[p.name] then
                        PLACES[p.name] = p.id
                        PLACE_NAMES[#PLACE_NAMES + 1] = p.name
                        added = added + 1
                    end
                end
                table.sort(PLACE_NAMES)
                pcall(function() placeDropdown:Refresh(PLACE_NAMES) end)
                notify("Places", added .. " new place(s) in the list.")
            end)
        end,
    })
    sec = Sub.SrvPriv:AddSection({ Name = "Private Servers", Icon = "door-open", Side = 1 })
    do
        local Priv = {
            byMap = {},
            maps = {},
            map = nil, code = nil,
            status = nil, mapDd = nil, codeDd = nil,
        }
        Priv.status = sec:AddLabel("Status: not loaded yet")
        function Priv.join(code)
            if type(code) ~= "string" or code == "" then
                notify("Private Server", "Pick or paste a code first.")
                return
            end
            if type(_dzEnv.DisableAntiTeleport) == "function" then
                pcall(_dzEnv.DisableAntiTeleport)
            end
            fire(startevent, "teleporttoprivate", code, nil)
            Priv.status:SetText("Status: joining " .. code .. "...")
        end
        function Priv.fetch()
            local req = httpRequest()
            if not req then
                Priv.status:SetText("Status: executor has no HTTP request")
                return
            end
            Priv.status:SetText("Status: fetching...")
            local ok, r = pcall(req, {
                Url = "https://gamerempire.net/shindo-life-roblox-private-server-codes-list-all-locations/",
                Method = "GET",
            })
            if not ok or not r or r.StatusCode ~= 200 or type(r.Body) ~= "string" then
                Priv.status:SetText("Status: source is down or blocked")
                return
            end
            local byMap, maps, total = {}, {}, 0
            for row in r.Body:gmatch("<tr.-</tr>") do
                local cells = {}
                for c in row:gmatch("<td.->(.-)</td>") do
                    cells[#cells + 1] = (c:gsub("<.->", ""):gsub("^%s+", ""):gsub("%s+$", ""))
                end
                local code, map = cells[2], cells[3]
                if code and map and code ~= "" and map ~= "" and #code <= 12 then
                    if not byMap[map] then
                        byMap[map] = {}
                        maps[#maps + 1] = map
                    end
                    local list = byMap[map]
                    list[#list + 1] = code
                    total = total + 1
                end
            end
            if total == 0 then
                Priv.status:SetText("Status: page changed shape - nothing parsed")
                return
            end
            table.sort(maps)
            Priv.byMap, Priv.maps = byMap, maps
            pcall(function() Priv.mapDd:Refresh(maps) end)
            Priv.status:SetText(("Status: %d codes across %d maps"):format(total, #maps))
        end
        Priv.mapDd = sec:AddDropdown({
            Name = "Map",
            Flag = "shindo_priv_map",
            Multi = false,
            SearchThreshold = 6,
            Items = {},
            Default = nil,
            Callback = function(v)
                if type(v) ~= "string" then return end
                Priv.map, Priv.code = v, nil
                local list = Priv.byMap[v] or {}
                pcall(function() Priv.codeDd:Refresh(list) end)
                Priv.status:SetText(("Status: %s - %d codes"):format(v, #list))
            end,
        })
        Priv.codeDd = sec:AddDropdown({
            Name = "Code",
            Flag = "shindo_priv_code",
            Multi = false,
            SearchThreshold = 8,
            Items = {},
            Default = nil,
            Callback = function(v)
                if type(v) == "string" then Priv.code = v end
            end,
        })
        sec:AddButton({
            Name = "Join Selected",
            Callback = function() Priv.join(Priv.code) end,
        })
        sec:AddButton({
            Name = "Refresh List",
            Callback = function() task.spawn(Priv.fetch) end,
        })
        sec:AddTextbox({
            Name = "Custom Code",
            Placeholder = "Paste a private code...",
            Finished = true,
            Callback = function(v)
                local s = tostring(v or ""):gsub("^%s+", ""):gsub("%s+$", "")
                if s ~= "" then Priv.join(s) end
            end,
        })
        task.spawn(Priv.fetch)
    end
    sec = Sub.SrvJob:AddSection({ Name = "Job ID", Icon = "hash", Side = 1 })
    sec:AddButton({
        Name = "Copy Job ID",
        Callback = function()
            if not setclipboard then
                notify("Server", "Your executor has no setclipboard.")
                return
            end
            setclipboard(tostring(game.JobId))
            notify("Server", "Job ID copied.")
        end,
    })
    sec:AddButton({
        Name = "Copy Server Link",
        Callback = function()
            if not setclipboard then
                notify("Server", "Your executor has no setclipboard.")
                return
            end
            setclipboard(string.format(
                "roblox://experiences/start?placeId=%d&gameInstanceId=%s",
                game.PlaceId, tostring(game.JobId)))
            notify("Server", "Server link copied - paste it to open this exact server.")
        end,
    })
    _dzEnv.DzShindo_TargetJobId = _dzEnv.DzShindo_TargetJobId or ""
    sec:AddTextbox({
        Name = "Target Job ID",
        Placeholder = "Paste a Job ID here...",
        Finished = true,
        Callback = function(v) _dzEnv.DzShindo_TargetJobId = tostring(v or "") end,
    })
    sec:AddButton({
        Name = "Join Job ID",
        Callback = function()
            local id = _dzEnv.DzShindo_TargetJobId
            if type(id) ~= "string" or id == "" then
                notify("Server", "Paste a Job ID in the box first.")
                return
            end
            if type(_dzEnv.DisableAntiTeleport) == "function" then
                pcall(_dzEnv.DisableAntiTeleport)
            end
            local ok = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer)
            end)
            if not ok then notify("Server", "That Job ID didn't take - it may be closed.") end
        end,
    })
    sec = Sub.SrvJob:AddSection({ Name = "Saved Servers", Icon = "bookmark", Side = 2 })
    do
        local PATH = "DzHub/saved_servers.json"
        local saved, names, dropdown, picked = {}, {}, nil, nil
        local function persist()
            if not writefile then return end
            if makefolder and not (isfolder and isfolder("DzHub")) then
                pcall(makefolder, "DzHub")
            end
            pcall(writefile, PATH, HttpService:JSONEncode(saved))
        end
        local function reload()
            saved, names = {}, {}
            if isfile and isfile(PATH) and readfile then
                local ok, raw = pcall(readfile, PATH)
                local ok2, data = ok and pcall(HttpService.JSONDecode, HttpService, raw)
                if ok2 and type(data) == "table" then
                    for n, id in pairs(data) do
                        saved[n] = id
                        names[#names + 1] = n
                    end
                end
            end
            table.sort(names)
            pcall(function() dropdown:Refresh(names) end)
        end
        reload()
        sec:AddButton({
            Name = "Save Current Server",
            Callback = function()
                local n = os.date("%d/%m %H:%M")
                if saved[n] then
                    local i = 2
                    while saved[n .. " (" .. i .. ")"] do i = i + 1 end
                    n = n .. " (" .. i .. ")"
                end
                saved[n] = tostring(game.JobId)
                names[#names + 1] = n
                table.sort(names)
                persist()
                pcall(function() dropdown:Refresh(names) end)
                notify("Saved Servers", "Saved as '" .. n .. "'.")
            end,
        })
        dropdown = sec:AddDropdown({
            Name = "Saved",
            Flag = "shindo_srv_saved",
            Multi = false,
            Items = names,
            Default = names[1],
            Callback = function(v) if type(v) == "string" then picked = v end end,
        })
        sec:AddButton({
            Name = "Join Saved",
            Callback = function()
                local id = picked and saved[picked]
                if not id or id == "" then
                    notify("Saved Servers", "Pick one in the dropdown first.")
                    return
                end
                if type(_dzEnv.DisableAntiTeleport) == "function" then
                    pcall(_dzEnv.DisableAntiTeleport)
                end
                local ok = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer)
                end)
                if not ok then
                    notify("Saved Servers", "That server is gone (closed or another place).")
                end
            end,
        })
        sec:AddButton({
            Name = "Delete Selected",
            Callback = function()
                if not picked then return end
                saved[picked] = nil
                for i, n in ipairs(names) do
                    if n == picked then table.remove(names, i) break end
                end
                picked = nil
                persist()
                pcall(function() dropdown:Refresh(names) end)
            end,
        })
    end
    sec = Sub.UtilQuest:AddSection({ Name = "Counters", Icon = "list-checks", Side = 1 })
    sec:AddLabel("Counters for daily quests - one runs at a time.")
    sec:AddToggle({
        Name = "Auto Rush",
        Flag = "shindo_qm_rush",
        Default = false,
        Callback = function(on) state.flags.questRush = on end,
    })
    sec:AddToggle({
        Name = "Auto Jumps",
        Flag = "shindo_qm_jump",
        Default = false,
        Callback = function(on) state.flags.questJump = on end,
    })
    sec:AddToggle({
        Name = "Auto Punches",
        Flag = "shindo_qm_punch",
        Default = false,
        Callback = function(on) state.flags.questPunch = on end,
    })
    sec:AddToggle({
        Name = "Auto Chi Charge",
        Flag = "shindo_qm_chi",
        Default = false,
        Callback = function(on) state.flags.questChi = on end,
    })
end
if type(Window.HideLoading) == "function" then
    pcall(function() Window:HideLoading() end)
end
Library:Notification("Tempo - Shindo Life", HAS_STATS
    and "Farm, Spins and Utility loaded."
    or "Loaded without Spins - this place has no spin data.", 6)
end)