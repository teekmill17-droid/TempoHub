local TeekUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))()

local TeekGuard = (function()
-- ============================================================
--  TeekGuard - anti-piracy telemetry + honeypot for Tempo hubs
--
--  This only ever watches OUR OWN script and reports to OUR OWN worker. It
--  does not touch the user's machine, read their files, or run anything on
--  them beyond the hub they already loaded. It is leak tracing, not a payload:
--
--    * beacon(kind)   - load / tamper events to teekhub-keys (same worker the
--                       key screen already reports loads to). Adds the buyer's
--                       Luarmor Discord id + the build id, so a key that turns
--                       up on many devices, or a flipped decoy flag, points at
--                       who shared it.
--    * premiumTrap()  - a decoy "unlock" check. It LOOKS like the real premium
--                       gate and reads obvious bypass globals (TempoUnlock, ...)
--                       that a cracker grepping the source would try. Flipping
--                       one reports the device and STILL returns false, so the
--                       crack "works" on screen and unlocks nothing. The real
--                       gate lives elsewhere and never calls this.
--    * watchHook(fn)  - remember our namecall hook; if something replaces it
--                       later (a cracked build swapping the key check out), the
--                       next beacon carries that note.
--
--  BUILD_ID is rewritten per build by obfuscate.ps1. In a dev run it stays the
--  literal placeholder, which just reads as "dev" in telemetry.
-- ============================================================
local TeekGuard = { tampered = false, notes = {} }

local HttpService = game:GetService("HttpService")
local WORKER_URL  = "https://teekhub-keys.teekhub.workers.dev"
local BEACON_URL  = WORKER_URL .. "/hit"
local BUILD_ID    = "backlog-20261104"   -- stamped at build time; "dev" otherwise
-- "1" only in an upload build (obfuscate.ps1 without -KeepDev); raw source and
-- dev builds are not release
TeekGuard.release = ("1") == "1"
-- one generation per load: every loop below ends when the hub is executed again
local GEN = {}
pcall(function() getgenv().TeekGuardGen = GEN end)
local stopped = false
local function current()
	if stopped then return false end
	local ok, g = pcall(function() return getgenv().TeekGuardGen end)
	return not ok or g == GEN
end
-- the hub's unload: every loop below ends at its next check
function TeekGuard.stop()
	stopped = true
	pcall(function() if getgenv().TeekGuardGen == GEN then getgenv().TeekGuardGen = nil end end)
end

-- executors ship the HTTP call under different names; some ship none
local function httpFn()
	return (syn and syn.request) or (fluxus and fluxus.request)
		or (http and http.request) or http_request or request
end
local function httpPost(url, body)
	local fn = httpFn()
	if not fn then return false end
	return pcall(fn, {
		Url = url, Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = body,
	})
end
-- a request that returns the decoded JSON body (nil on any failure). Used for
-- the per-buyer token and server-gated feature data below.
local function httpJSON(url, method, body, headers)
	local fn = httpFn()
	if not fn then return nil end
	local h = { ["Content-Type"] = "application/json" }
	if headers then for k, v in pairs(headers) do h[k] = v end end
	local ok, res = pcall(fn, { Url = url, Method = method or "GET", Headers = h, Body = body })
	if not ok or type(res) ~= "table" then return nil end
	local code = res.StatusCode or res.status_code or 0
	if code ~= 0 and (code < 200 or code >= 300) then return nil end
	local okd, data = pcall(function() return HttpService:JSONDecode(res.Body or "") end)
	return okd and data or nil
end

-- stable per-device id, same order of preference as the key screen
local function deviceId()
	local ok, id = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
	if ok and type(id) == "string" and #id > 0 then return id end
	local ok2, id2 = pcall(function() return gethwid() end)
	if ok2 and type(id2) == "string" and #id2 > 0 then return id2 end
	return "unknown-" .. tostring(game.PlaceId)
end

-- the buyer's linked Discord id, when Luarmor supplied it (nil on dev / free)
local function discId()
	local d = rawget(getfenv and getfenv(0) or _G, "LRM_LinkedDiscordID")
	if d == nil then pcall(function() d = LRM_LinkedDiscordID end) end
	return (type(d) == "string" or type(d) == "number") and tostring(d) or nil
end

-- (10-23) key fingerprint: first 4 + last 4 of the buyer's Luarmor key. An
-- unlinked key reports Discord as "Unknown", so this is what names that buyer
-- (find it in the Luarmor dashboard / shop orders). Useless to reuse.
local function keyFp()
	local k
	pcall(function() k = rawget(getfenv and getfenv(0) or _G, "script_key") end)
	if k == nil then pcall(function() k = getgenv().script_key end) end
	if k == nil then pcall(function() k = script_key end) end
	if type(k) ~= "string" then return nil end
	k = k:gsub("[^%w]", "")
	if #k < 10 then return nil end
	return k:sub(1, 4) .. ".." .. k:sub(-4)
end

local function gameName()
	local n = "place " .. tostring(game.PlaceId)
	pcall(function() n = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or n end)
	return n
end

-- (10-30, teek: "the most info possible") WHO is running it + WHERE. A device hash
-- and a maybe-"unknown" Discord id didn't name the person; the Roblox account does,
-- and the Job ID lets you join the server a leaked copy is in. All plain reads of
-- our own client - no getfenv/debug/metatable fingerprinting (that false-bans legit
-- users on some executors, see the project notes), so this is safe to always send.
local function robloxWho()
	local lp = game:GetService("Players").LocalPlayer
	if not lp then return nil, nil, nil end
	local who = ("%s (%d)"):format(lp.Name, lp.UserId)
	local age = tostring(lp.AccountAge) .. "d"
	return who, age, tostring(lp.DisplayName)
end

local function beaconBody(kind, note, key, ban)
	local who, age = robloxWho()
	return HttpService:JSONEncode({
		kind  = kind or "load",
		user  = who,                                    -- Roblox name (UserId)
		age   = age,                                    -- account age, alt tell
		place = tostring(game.PlaceId),
		job   = tostring(game.JobId),                   -- join the leaker's server
		priv  = game.PrivateServerId ~= "" or nil,
		-- worker drops unknown keys; a Luarmor build has no Tempo key, so it
		-- reports under its own label (the buyer is disc / kf)
		key   = key or (TeekGuard.underLuarmor and TeekGuard.underLuarmor() and "TEMPO-PREMIUM" or "TEMPO-FREE"),
		kf    = keyFp(),
		hwid  = deviceId(),
		disc  = discId(),
		build = BUILD_ID,
		game  = gameName(),
		exec  = tostring(identifyexecutor and identifyexecutor() or "unknown"),
		note  = note and tostring(note):sub(1, 120) or nil,
		tamper = TeekGuard.tampered or nil,
		ban   = ban or nil,
	})
end
-- key is passed in by the hub if it has one (the key screen returns it)
function TeekGuard.beacon(kind, note, key)
	task.spawn(function()
		pcall(function() httpPost(BEACON_URL, beaconBody(kind, note, key)) end)
	end)
end

-- ------------------------------------------------------------
--  Per-buyer token + server-gated features (10-23). The token ties this
--  session to the buyer's Luarmor Discord id and is signed by the worker, so
--  it can't be minted from a dumped copy. A gated feature's decision data is
--  fetched with it and lives on the worker, not in the script: a dumped client
--  with no valid token gets nil back and that feature does nothing.
-- ------------------------------------------------------------
function TeekGuard.token(key)
	if TeekGuard._token ~= nil then return TeekGuard._token or nil end
	local disc = discId()
	if not disc then TeekGuard._token = false return nil end
	local res = httpJSON(WORKER_URL .. "/token", "POST", HttpService:JSONEncode({
		key = key or "TEMPO-PREMIUM", disc = disc, build = BUILD_ID,
	}))
	TeekGuard._token = (res and res.ok and res.token) or false
	return TeekGuard._token or nil
end
-- returns the decoded `data` table for a gated feature, or nil (husk)
function TeekGuard.feature(name, key)
	local tok = TeekGuard.token(key)
	if not tok then return nil end
	local res = httpJSON(WORKER_URL .. "/feature?f=" .. tostring(name), "GET", nil, { ["x-teek-token"] = tok })
	return (res and res.ok and res.data) or nil
end

-- ------------------------------------------------------------
--  Remote boot (10-23). A buyer flagged in the worker (via Teeky /boot) is
--  unloaded + kicked on the next check-in. Only polls when there's a buyer id
--  to match (premium under Luarmor); free / dev builds have none and skip it.
--  Auto-started at load, so every hub that includes TeekGuard gets it.
-- ------------------------------------------------------------
local DEFAULT_BOOT_MSG =
	"You have been banned from Tempo Hub\n\nReach out and make a ticket to get unbanned - this could be a mistake."
-- unload the hub, then kick. (10-23) The kick is a plain call, not :Kick(): a
-- __namecall hook - the usual way a Kick gets swallowed - never sees it. Still
-- in the game 3 s later = the kick was blocked: close the client.
function TeekGuard.hardKick(msg)
	pcall(function() if _G.TeekHubUnload then _G.TeekHubUnload() end end)
	TeekGuard.stop()
	local lp = game:GetService("Players").LocalPlayer
	pcall(function() lp.Kick(lp, msg) end)
	task.wait(3)
	if lp and lp.Parent then pcall(function() game:Shutdown() end) end
end
-- (10-28, teek: "insta boot on any alert, ban them, tell them to open a ticket")
-- a real tamper alert = the worker bans this device + key (the beacon's ban flag)
-- BEFORE the kick, so re-executing is booted by bootWatch at load. Dev / raw
-- source only reports: my own testing must never ban a device.
local BAN_MSG = "You have been banned from Tempo Hub (anti-tamper).\n\nOpen a ticket in our Discord to get unbanned: discord.gg/K7Qxnxkk46"
function TeekGuard.banKick(note)
	TeekGuard.tampered = true
	if not TeekGuard.release then TeekGuard.beacon("tamper", note) return end
	pcall(httpJSON, BEACON_URL, "POST", beaconBody("tamper", note, nil, true))
	TeekGuard.hardKick(BAN_MSG)
end
-- (10-23) every Luarmor run is watched, not only linked ones: a buyer is
-- matched by Discord id, key fingerprint or device. First check right at load
-- (a booted buyer re-executing used to get 25 s free), then every 25 s.
function TeekGuard.bootWatch()
	local disc = discId()
	if not (disc or TeekGuard.underLuarmor()) then return end
	task.spawn(function()
		local first = true
		while current() do
			if not first then task.wait(25) end
			first = false
			if not current() then break end
			local res = httpJSON(BEACON_URL, "POST", HttpService:JSONEncode({
				kind = "ping", key = "TEMPO-PREMIUM", hwid = deviceId(), disc = disc, kf = keyFp(), build = BUILD_ID,
			}))
			local c = res and res.control
			if type(c) == "table" and c.action == "ban" then
				TeekGuard.hardKick((type(c.msg) == "string" and #c.msg > 0) and c.msg or DEFAULT_BOOT_MSG)
				break
			end
		end
	end)
end

-- ------------------------------------------------------------
--  Honeypot: a decoy premium check. Named and shaped like the real thing so
--  it is the first "unlock" a cracker finds. Any of these globals being set
--  reads as a bypass attempt: report it, flag the session, and return false.
--  The genuine gate is the Luarmor LRM_IsUserPremium check in each hub and
--  never routes through here.
-- ------------------------------------------------------------
local DECOYS = { "TempoUnlock", "TempoPremiumBypass", "UnlockPremium", "TempoFreePremium", "TempoDevUnlock" }
local function decoyFlag()
	local env = (getgenv and getgenv()) or _G or {}
	for _, name in ipairs(DECOYS) do
		local ok, v = pcall(function() return env[name] end)
		if ok and v then return name end
	end
	return nil
end

function TeekGuard.premiumTrap()
	local hit = decoyFlag()
	if hit and not TeekGuard.notes[hit] then
		TeekGuard.notes[hit] = true
		task.spawn(TeekGuard.banKick, "decoy:" .. hit)
	end
	return false   -- always: the decoy unlocks nothing
end

-- watch for a flag being set AFTER load, not just at it
task.spawn(function()
	while current() do
		TeekGuard.premiumTrap()
		task.wait(3)
	end
end)

-- ------------------------------------------------------------
--  Hook integrity: remember our namecall hook. If a later build / patch swaps
--  the game's __namecall out from under us (the usual way a key or anti-flag
--  check gets removed), the mismatch rides along on the next beacon. Soft only
--  - it reports, it never bricks anything.
-- ------------------------------------------------------------
-- call once, right after the hub installs its own __namecall hook: snapshots
-- whatever is there now as the baseline, then reports if it changes later
function TeekGuard.watchHook()
	task.spawn(function()
		local function metaNow()
			local ok, mt = pcall(getrawmetatable, game)
			return ok and mt and rawget(mt, "__namecall") or nil
		end
		task.wait(5)
		local baseline = metaNow()
		if baseline == nil then return end   -- can't read it on this executor
		while current() do
			local cur = metaNow()
			if cur ~= nil and cur ~= baseline and not TeekGuard.notes.hookgone then
				TeekGuard.notes.hookgone = true
				TeekGuard.tampered = true
				TeekGuard.beacon("tamper", "namecall-replaced")
			end
			task.wait(15)
			if not current() then break end
		end
	end)
end

-- ------------------------------------------------------------
--  Release builds run through Luarmor only. A dumped copy run raw has no
--  LRM_ variables, and would otherwise count as a dev copy = premium with no
--  checks. (Faking LRM_ variables gets past this - it stops dump-and-run.)
-- ------------------------------------------------------------
function TeekGuard.underLuarmor()
	local yes = false
	pcall(function()
		yes = LRM_IsUserPremium ~= nil or LRM_ScriptName ~= nil or LRM_TotalExecutions ~= nil
			or LRM_LinkedDiscordID ~= nil or LRM_SecondsLeft ~= nil
	end)
	return yes
end
-- ------------------------------------------------------------
--  Env integrity (10-23). A dumped copy can be run inside a hand-written
--  environment that stands in for the engine globals and records everything
--  the script reaches for, so the obfuscation never has to be undone. In a
--  real client those globals are genuine C / executor closures and `game` is
--  a real DataModel userdata; in a stand-in they are plain Lua functions and
--  tables. Check a few that the hub can't run without. Soft by default
--  (reports); release turns a failure into a refusal.
-- ------------------------------------------------------------
local function realClosure(fn)
	-- genuine engine/executor function, not a Lua re-implementation
	if type(fn) ~= "function" then return false end
	local okC, isC = pcall(iscclosure, fn)
	if okC and isC then return true end
	local okX, isX = pcall(isexecutorclosure, fn)
	if okX and isX then return true end
	return false
end
function TeekGuard.envOK()
	-- `game` must be a real DataModel userdata, not a mock table
	local okT, t = pcall(function() return typeof(game) end)
	if not okT or t ~= "Instance" then return false, "game not Instance" end
	local okG, isDM = pcall(function() return game:IsA("DataModel") end)
	if not okG or not isDM then return false, "game not DataModel" end
	-- the engine entry points the hub relies on must be genuine closures.
	-- iscclosure itself being absent is normal on some executors, so only
	-- fail when it IS present and says a core function is a Lua stand-in.
	if type(iscclosure) == "function" then
		local probes = {
			{ "GetService", game.GetService },
			{ "FindFirstChild", game.FindFirstChild },
			{ "IsA", game.IsA },
		}
		for _, p in ipairs(probes) do
			if not realClosure(p[2]) then return false, p[1] .. " not native" end
		end
	end
	return true
end
function TeekGuard.requireLuarmor()
	if not TeekGuard.release then return end
	local envOk, why = TeekGuard.envOK()
	if not envOk then
		TeekGuard.banKick("env: " .. tostring(why))
		error("[Tempo] Run Tempo Hub from the official loader (tempohub.shop).", 0)
	end
	if not TeekGuard.underLuarmor() then
		TeekGuard.banKick("ran outside luarmor")
		error("[Tempo] Run Tempo Hub from the official loader (tempohub.shop).", 0)
	end
end

-- ------------------------------------------------------------
--  Spy watch (moved here from ABA 10-08 so every hub gets it). A spy tool's
--  WINDOW (SimpleSpy, Hydroxide, Cobalt, TurtleSpy, Dex) kicks; a hooked game
--  metatable only REPORTS - other hubs and some executors (Matcha) hook it
--  for honest reasons, and Real-style in-place spies never show there anyway.
-- ------------------------------------------------------------
local SPY_WINDOWS = { "simplespy", "remotespy", "remote spy", "turtlespy", "hydroxide", "cobalt", "octospy", "frostspy", "keyspy", "spyx", "httpspy" }
-- globals the common spies set on load
local SPY_GLOBALS = { "SimpleSpyExecuted", "SimpleSpy", "Hydroxide", "TurtleSpyLoaded", "CobaltLoaded", "RemoteSpy", "RSpyLoaded" }
local function spyGlobal()
	local env = (getgenv and getgenv()) or _G or {}
	for _, n in ipairs(SPY_GLOBALS) do
		local ok, v = pcall(function() return rawget(env, n) end)
		if ok and v then return n end
	end
end
-- Canary: an UNPARENTED remote fired with trap arguments. The engine never
-- reads a table's metamethods or a userdata's __tostring when it packs args,
-- and an unparented remote never reaches the server, so nothing honest touches
-- them. A spy hooking FireServer / __namecall formats its args for its log -
-- that trips the trap. (Spies that only log parented remotes or format lazily
-- skip it; the window / global / hook checks cover those.)
local tripped = nil
local function bait()
	-- (10-24, Discord: Xeno users kicked with "remote log (iter)") executors that run
	-- scripts in their own sandbox COPY a remote's arguments on every call - that
	-- walks the table (__iter / __index / __len) with no spy anywhere. Only turning
	-- the args into TEXT (__tostring / __concat) is a logger; the rest no longer trips,
	-- and Xeno skips the bait altogether
	local exe = ""
	pcall(function() exe = string.lower(tostring((identifyexecutor or getexecutorname)())) end)
	if string.find(exe, "xeno", 1, true) then return nil end
	local function trip(why) return function() tripped = tripped or why return "" end end
	local function quiet() return nil end
	local mt = { __index = quiet, __tostring = trip("tostring"), __len = function() return 0 end, __concat = trip("concat") }
	local t = setmetatable({}, mt)
	local u = newproxy and newproxy(true)
	if u then local m = getmetatable(u) m.__tostring = trip("tostring") m.__index = quiet end
	local r = Instance.new("RemoteEvent")
	r.Name = HttpService:GenerateGUID(false):sub(1, 8)
	pcall(function() r:FireServer(t, u) end)
	r:Destroy()
	task.wait(1)   -- deferred loggers format a beat later
	return tripped
end
-- the engine functions a crack or spy would hook in place
local function hookedEngine()
	if type(isfunctionhooked) ~= "function" then return nil end
	local probes = {}
	pcall(function()
		probes.FireServer = Instance.new("RemoteEvent").FireServer
		probes.InvokeServer = Instance.new("RemoteFunction").InvokeServer
		probes.Kick = game:GetService("Players").LocalPlayer.Kick
	end)
	for n, fn in pairs(probes) do
		local ok, h = pcall(isfunctionhooked, fn)
		if ok and h then return n end
	end
end
local function spyWindow()
	local roots = { game:GetService("CoreGui") }
	pcall(function() if gethui then table.insert(roots, gethui()) end end)
	for _, root in ipairs(roots) do
		local ok, kids = pcall(function() return root:GetChildren() end)
		for _, g in ipairs(ok and kids or {}) do
			local n = string.lower(g.Name)
			for _, sp in ipairs(SPY_WINDOWS) do if string.find(n, sp, 1, true) then return g.Name end end
			if string.sub(n, 1, 3) == "dex" then return g.Name end
		end
	end
end
local function hookedMeta()
	if not (getrawmetatable and isexecutorclosure) then return nil end
	local ok, mt = pcall(getrawmetatable, game)
	if not ok or type(mt) ~= "table" then return nil end
	for _, name in ipairs({ "__namecall", "__index", "__newindex" }) do
		local fn = rawget(mt, name)
		local okc, hooked = pcall(isexecutorclosure, fn)
		if type(fn) == "function" and okc and hooked then return name end
	end
end
-- onKick(): the hub's own unload, run right before the kick. Armed under Luarmor
-- (premium) or when a free hub opts in with TeekGuard.armFree (set by the -KeyGate
-- build, so a spy open on a free hub boots too - teek 11-04).
function TeekGuard.spyWatch(onKick)
	if not (TeekGuard.underLuarmor() or TeekGuard.armFree) then return end
	local function check()
		local w = spyWindow()
		if not w then local g = spyGlobal() w = g and ("global " .. g) end
		if not w then local b = bait() w = b and ("remote log (" .. b .. ")") end
		if w then
			pcall(onKick)
			-- Premium bans the device + key; a free hub only BOOTS (unload + kick) and
			-- reports it - a false positive off a free product must never ban a device.
			if TeekGuard.armFree then
				pcall(TeekGuard.beacon, "spy", w)
				TeekGuard.hardKick("Closing: a spy / remote-logging tool is open. Close it, then re-execute.")
			else
				TeekGuard.banKick("spy window: " .. w)
			end
			return true
		end
		local h = hookedMeta()
		if h and not TeekGuard.notes["meta" .. h] then
			TeekGuard.notes["meta" .. h] = true
			TeekGuard.beacon("tamper", "game." .. h .. " hooked")
		end
		local e = hookedEngine()
		if e and not TeekGuard.notes["fn" .. e] then
			TeekGuard.notes["fn" .. e] = true
			TeekGuard.beacon("tamper", e .. " hooked")
		end
	end
	if check() then return true end
	task.spawn(function()
		while current() do
			task.wait(5)
			if not current() or check() then break end
		end
	end)
end

-- (10-23) started last: bootWatch needs underLuarmor, defined above
task.spawn(function() pcall(TeekGuard.bootWatch) end)

return TeekGuard

end)()
pcall(function()
	if TeekGuard and TeekGuard.spyWatch then
		TeekGuard.armFree = true
		TeekGuard.spyWatch(function()
			local g = (getgenv and getgenv()) or _G
			local u = (g and g.TeekHubUnload) or _G.TeekHubUnload
			if u then pcall(u) end
		end)
	end
end)
-- ============================================================
--  Tempo Hub - Sell Ores (free)
--  Generated by port_backlog.py from the dev's source. Edit the
--  source + porter, not this file.
-- ============================================================
getgenv().TempoHoodSubtitle = "SELL ORES"
-- ============================================================
--  Obsidian -> TempoUI adapter for the game backlog (Tempo Hub, 2026-10-27)
--
--  HoodCompat's copy, made for the ~350 Obsidian game scripts Sky handed
--  over. On top of the Linoria surface it adds what Obsidian scripts call:
--    * Tab:AddSubTab / AddPage  -> a TempoUI group, one tab per subtab
--    * tabs drawn lazily: a tab whose boxes are all hidden never shows
--    * the old hub's Info tab, socials / discord / donation boxes and link
--      buttons are hidden (they were another hub's, not ours)
--    * AddLabel(text, wrap, idx), Notify({ Title, Description, Time })
--    * anything else Obsidian-only (AddPlayerInfo, AddDiscordBox,
--      AddDialog, AddStatusLabel, SetVisible ...) is a quiet no-op
--  HoodCompat stays as it is for Hood / Rivals.
--
--  Linoria -> WindUI adapter (Tempo Hub, 2026-10-04)
--
--  The hood script was written against a Linoria-style library:
--  Window:AddTab, Tab:AddLeftGroupbox, Groupbox:AddToggle(idx, {...}),
--  Toggles[idx] / Options[idx] with .Value, :SetValue, :OnChanged, key and
--  colour pickers chained on toggles and labels, SaveManager, ThemeManager.
--  This file gives it exactly that surface and builds a WindUI window (our
--  WindLib) underneath, so the 8,000 lines of features run untouched.
--
--  Linoria semantics kept on purpose:
--    * building a control never fires its Callback
--    * :SetValue fires Callback and every OnChanged handler
--    * :OnChanged(fn) runs fn once right away
--    * :AddKeyPicker / :AddColorPicker return the parent, for chaining
-- ============================================================
do
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local HttpService = game:GetService("HttpService")

	local Toggles, Options = {}, {}
	getgenv().Toggles, getgenv().Options = Toggles, Options
	-- A control that was cut from this game's build reads as "off" instead of
	-- erroring: the hood features left in the source (force hit and friends)
	-- just never switch on. pairs() still only sees the real controls, so
	-- configs save and load the same.
	local function noop() end
	local stubT = { Value = false, Type = "Toggle", OnChanged = noop, SetValue = noop, SetText = noop }
	stubT.AddKeyPicker = function(self) return self end
	stubT.AddColorPicker = function(self) return self end
	local stubO = { Value = nil, Type = "Stub", OnChanged = noop, OnClick = noop, SetValue = noop,
		SetValues = noop, SetValueRGB = noop, GetState = function() return false end }
	setmetatable(Toggles, { __index = function() return stubT end })
	setmetatable(Options, { __index = function() return stubO end })

	local Library = {
		Toggles = Toggles, Options = Options, Unloaded = false,
		AccentColor = Color3.fromRGB(46, 155, 255), Theme = {}, KeybindFrame = nil,
		unloadFns = {}, ui = nil, Scheme = {}, Labels = {}, Buttons = {},
	}
	-- Obsidian-only calls nobody here draws: a method-looking name we don't
	-- have is a no-op that hands back Stub, so chains keep going. Only names
	-- that read as methods - a missing .Value must stay nil, not a function.
	local METHOD = { "^Set", "^Add", "^Update", "^On", "^Get", "^Refresh", "^Show", "^Hide", "^Load",
		"^Save", "^Apply", "^Create", "^Build", "^Remove", "^Destroy", "^Validate", "^Display", "^Lock", "^Unlock" }
	local function isMethod(k)
		if type(k) ~= "string" then return false end
		for _, p in ipairs(METHOD) do if string.find(k, p) then return true end end
		return false
	end
	local Stub
	Stub = setmetatable({}, { __index = function(_, k) if isMethod(k) then return function() return Stub end end end })
	local function lenient(t)
		return setmetatable(t, { __index = function(_, k) if isMethod(k) then return function() return Stub end end end })
	end
	-- the Fluent / Rayfield wrappers hold no data a script reads: any capitalised
	-- name there is a method we don't draw (SelectTab, Dialog, Minimize ...)
	local function loose(t)
		return setmetatable(t, { __index = function(_, k) if type(k) == "string" and string.find(k, "^%u") then return function() return Stub end end end })
	end
	lenient(Library)

	-- ---------- Tempo look, per build: getgenv().TempoUIPolicy before loading
	--   hide = { [idx] = true }        controls that exist but are not drawn
	--   hideGroups = { [title] = true } whole boxes, same
	--   rename = { [idx] = "Text" }, groupRename = { [title] = "Text" }
	-- Every other title is tidied to Title Case (teek: "uncapital letters").
	local Policy = getgenv().TempoUIPolicy or {}
	local HIDE, HIDEG = Policy.hide or {}, Policy.hideGroups or {}
	-- the old hub's own boxes, tabs and link buttons (every backlog script has them)
	for _, n in ipairs({ "Discord", "Socials", "Tempo Hub", "Donations", "Donate", "Community",
		"Account", "User", "Game Info", "Basic Info", "Player Info", "Credits", "Support", "Links", "Scripts", "Features" }) do
		if HIDEG[n] == nil then HIDEG[n] = true end
	end
	local HIDE_TABS = { Info = true, Information = true, Credits = true, Donate = true, Donations = true, Socials = true, About = true }
	local function brandButton(text)
		local s = string.lower(tostring(text or ""))
		if string.find(s, "webhook", 1, true) then return false end   -- "Test Discord Webhook" is a real feature
		for _, w in ipairs({ "discord", "rscripts", "litecoin", "bitcoin", "ethereum", "usdt", "paypal", "venmo",
			"donat", "website", "youtube", "profile link" }) do
			if string.find(s, w, 1, true) then return true end
		end
		return false
	end
	local RENAME, GRENAME = Policy.rename or {}, Policy.groupRename or {}
	local SMALL = { a = 1, an = 1, ["and"] = 1, at = 1, by = 1, ["for"] = 1, ["in"] = 1, of = 1,
		on = 1, ["or"] = 1, the = 1, to = 1, per = 1, vs = 1 }
	local UPPER = { esp = "ESP", fov = "FOV", hud = "HUD", id = "ID", ui = "UI", ko = "KO", fps = "FPS",
		rgb = "RGB", npc = "NPC", hp = "HP", dps = "DPS" }
	local function tidy(str)
		str = tostring(str or ""):gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")
		local i = 0
		return (str:gsub("[%a][%w']*", function(w)
			i += 1
			local lw = w:lower()
			if UPPER[lw] then return UPPER[lw] end
			if w ~= lw then return w end            -- already capitalised: CFrame, Tracer
			if i > 1 and SMALL[lw] then return lw end
			return lw:sub(1, 1):upper() .. lw:sub(2)
		end))
	end
	local function titleOf(idx, text) return RENAME[idx] or tidy(text or idx) end
	-- hidden controls still exist (the script reads their values), they just draw nothing
	local Dummy = setmetatable({}, { __index = function() return function() return nil end end })
	local groups = {}

	-- Build in slices: ~250 controls in one go froze the game for seconds on
	-- ABA. Give the frame back every ~25 ms while building.
	local breatheAt = os.clock()
	local function breathe()
		if os.clock() - breatheAt > 0.025 then
			if coroutine.isyieldable() then task.wait() end
			breatheAt = os.clock()
		end
	end

	local function fire(fn, ...)
		if type(fn) == "function" then
			local ok, err = pcall(fn, ...)
			if not ok then warn("[Tempo] callback error: " .. tostring(err)) end
		end
	end
	local function fireChanged(obj)
		for _, fn in ipairs(obj._changed) do fire(fn, obj.Value) end
	end
	local function onChanged(obj, fn)
		table.insert(obj._changed, fn)
		fire(fn, obj.Value)
	end

	-- ---------- key names (Linoria style: "B", "End", "MB1", "MB2", "None")
	local function keyMatches(name, input)
		if not name or name == "None" or name == "" then return false end
		if name == "MB1" then return input.UserInputType == Enum.UserInputType.MouseButton1 end
		if name == "MB2" then return input.UserInputType == Enum.UserInputType.MouseButton2 end
		if name == "MB3" then return input.UserInputType == Enum.UserInputType.MouseButton3 end
		return input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name == name
	end
	local function keyName(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 then return "MB1" end
		if t == Enum.UserInputType.MouseButton2 then return "MB2" end
		if t == Enum.UserInputType.MouseButton3 then return "MB3" end
		if t == Enum.UserInputType.Keyboard then return input.KeyCode.Name end
		return nil
	end

	-- ---------- one listener drives every key picker
	local pickers = {}
	local keyConns = {}
	local function typing() return UIS:GetFocusedTextBox() ~= nil end
	keyConns[#keyConns + 1] = UIS.InputBegan:Connect(function(input)
		if Library.Unloaded or typing() then return end
		for _, kp in ipairs(pickers) do
			if not kp._listening and keyMatches(kp.Value, input) then
				if kp.Mode == "Hold" then
					kp.Toggled = true
					fire(kp.Callback, true)
				elseif kp.Mode == "Toggle" then
					kp.Toggled = not kp.Toggled
					fire(kp.Callback, kp.Toggled)
					if kp.SyncToggleState and kp._parent and kp._parent.SetValue then
						kp._parent:SetValue(kp.Toggled)
					end
				else
					fire(kp.Callback, true)
				end
				for _, fn in ipairs(kp._clicked) do fire(fn) end
			end
		end
	end)
	keyConns[#keyConns + 1] = UIS.InputEnded:Connect(function(input)
		if Library.Unloaded then return end
		for _, kp in ipairs(pickers) do
			if kp.Mode == "Hold" and keyMatches(kp.Value, input) then
				kp.Toggled = false
				fire(kp.Callback, false)
			end
		end
	end)

	-- ---------- Groupbox: one WindUI section header + its controls
	-- ---------- TempoUI drawing layer. The groupbox code below speaks WindUI
	-- (raw:Toggle({Title, Value, Callback}) ...); this turns each call into the
	-- native TempoUI control on the tab and hands back a WindUI-shaped element
	-- (:Set / :SetTitle / :Refresh / :Select / :Update). Before 10-10 the calls
	-- went to tab.w.t, which TempoUI tabs don't have: every control failed
	-- inside its pcall and the menu showed empty section headers.
	local TICK = "\u{2713} "
	local function tempoRaw(t)
		local R = {}
		function R:Toggle(c)
			local h = t:Toggle(c.Title, c.Value and true or false, c.Callback)
			return { Set = function(_, v) h.Set(v and true or false, false) end, SetTitle = noop, SetDesc = noop }
		end
		function R:Slider(c)
			local v = c.Value or {}
			local h = t:Slider(c.Title, v.Min or 0, v.Max or 100, v.Default or v.Min or 0, c.Callback)
			return { Set = function(_, x) h.Set(x) end, SetTitle = noop, SetDesc = noop }
		end
		function R:Dropdown(c)
			local values = c.Values or {}
			if c.Multi then
				-- TempoUI picks one value: each pick flips it in the set, ticked ones get a mark
				local set = {}
				for _, x in ipairs(type(c.Value) == "table" and c.Value or {}) do set[x] = true end
				local h
				local function items()
					local out = {}
					for _, x in ipairs(values) do out[#out + 1] = (set[x] and TICK or "") .. x end
					return #out > 0 and out or { "-" }
				end
				local function list() local o = {} for _, x in ipairs(values) do if set[x] then o[#o + 1] = x end end return o end
				h = t:Dropdown(c.Title, items(), nil, function(pick)
					local x = tostring(pick)
					if x:sub(1, #TICK) == TICK then x = x:sub(#TICK + 1) end
					set[x] = not set[x] or nil
					h.SetItems(items(), (set[x] and TICK or "") .. x)
					if c.Callback then c.Callback(list()) end
				end)
				return { Refresh = function(_, nv) values = nv or {} h.SetItems(items()) end, Select = noop, SetDesc = noop }
			end
			local h = t:Dropdown(c.Title, values, c.Value, c.Callback)
			return { Refresh = function(_, nv) h.SetItems(nv or {}, h.Get()) end, Select = function(_, x) h.Set(x) end, SetDesc = noop }
		end
		function R:Input(c)
			local h = t:Input(c.Title, c.Value or "", c.Callback)
			return { Set = function(_, x) h.Text = tostring(x) end, SetDesc = noop }
		end
		function R:Button(c)
			local h = t:Button(c.Title, false, c.Callback)
			return { SetTitle = function(_, x) pcall(function() h:SetTitle(x) end) end, SetDesc = noop }
		end
		function R:Colorpicker(c)
			local h = t:Color(c.Title, c.Default, function(col) if c.Callback then c.Callback(col) end end)
			return { Update = function(_, col) h.Set(col) end, SetDesc = noop }
		end
		function R:Divider() t:Divider() end
		return R
	end

	local Groupbox = {}
	Groupbox.__index = function(_, k)
		local f = rawget(Groupbox, k)
		if f ~= nil then return f end
		if isMethod(k) then return function() return Stub end end   -- AddPlayerInfo, AddDiscordBox, AddStatusLabel ...
	end

	-- A WindUI Section holds its own controls (Toggle, Slider, Dropdown, Input,
	-- Button, Colorpicker...), so each groupbox is a real collapsible box. The
	-- script creates all its groupboxes first and fills them later; plain
	-- headers stacked at the top of the tab with the controls under them.
	-- Clover layout (teek 10-10): one page per window tab, its boxes as
	-- sections on it. Linoria scripts make every box first and fill them
	-- later, out of order, and TempoUI lays rows out in arrival order - so
	-- controls are QUEUED per box while the script builds and drawn box by box
	-- (header, then its rows) once it goes quiet. Each queued call hands back a
	-- stand-in element that keeps the latest Set/Refresh/Select/Update and
	-- passes them on once the real row exists. A box made after that draws
	-- straight away, at the bottom of its page.
	local usedNames = {}
	local flushed = false
	local lastAdd = 0
	local function standIn()
		local e = { _ops = {} }
		for _, m in ipairs({ "Set", "SetTitle", "SetDesc", "Refresh", "Select", "Update" }) do
			e[m] = function(self, ...)
				if self.real and self.real[m] then return self.real[m](self.real, ...) end
				self._ops[m] = table.pack(...)
			end
		end
		return e
	end
	local function drawBox(g)
		if g.drawn or #g.queue == 0 then return end
		g.drawn = true
		pcall(function() g.tab.w:Section(g.shown) end)
		local real = tempoRaw(g.tab.w)
		g.real = real
		for _, q in ipairs(g.queue) do
			local ok, el = pcall(real[q.m], real, q.cfg)
			if ok and type(el) == "table" and q.e then
				q.e.real = el
				for m, args in pairs(q.e._ops) do
					if el[m] then pcall(el[m], el, table.unpack(args, 1, args.n)) end
				end
				q.e._ops = {}
			end
		end
		g.queue = {}
	end
	local function flushAll()
		if flushed then return end
		flushed = true
		-- a tab, then its subtabs, in the order the script made them
		local order = {}
		for _, t in ipairs(Library._wtabs or {}) do
			order[#order + 1] = t
			for _, k in ipairs(t.kids) do order[#order + 1] = k end
		end
		for _, t in ipairs(order) do
			for _, g in ipairs(t.boxes) do drawBox(g) end
		end
		-- TempoUI balances cards into its two columns only when a page is first
		-- built; the page already open got its cards after that and stacked
		-- them all in the left column (teek 10-10: "one long list"). Re-balance.
		-- (rawget: a tab that never drew anything is never made)
		for _, t in ipairs(order) do
			local w = rawget(t, "w")
			if w then pcall(function() w.flowed = false w:_flow() end) end
		end
		-- Interface after the game's tabs, not before them
		if Library._wantInterface then Library._mountInterface() end
	end
	Library._flush = flushAll
	task.spawn(function()
		while not flushed do
			task.wait(0.25)
			if lastAdd > 0 and os.clock() - lastAdd > 1 then flushAll() end
		end
	end)
	local function newGroupbox(tab, title, prefix)
		breathe()
		title = tostring(title or "")
		if HIDEG[title] or tab.hidden then
			return setmetatable({ tab = tab, raw = Dummy, title = title, hidden = true, n = 0 }, Groupbox)
		end
		local shown = GRENAME[title] or tidy(title)
		-- a tabbox's later tabs read "Silent Customization", not a second "Customization"
		if usedNames[shown] or (prefix and string.lower(title) == "customization") then
			shown = (prefix and tidy(prefix) or tidy(tab.name)) .. " " .. shown
		end
		usedNames[shown] = true
		local g = setmetatable({ tab = tab, title = title, shown = shown, n = 0, queue = {} }, Groupbox)
		g.raw = setmetatable({}, { __index = function(_, k)
			return function(_, cfg)
				lastAdd = os.clock()
				if flushed then
					if not g.drawn then
						g.drawn = true
						pcall(function() g.tab.w:Section(g.shown) end)
						g.real = tempoRaw(g.tab.w)
					end
					local f = g.real[k]
					return f and f(g.real, cfg)
				end
				local e = (k ~= "Divider") and standIn() or nil
				g.queue[#g.queue + 1] = { m = k, cfg = cfg, e = e }
				return e
			end
		end })
		table.insert(tab.boxes, g)
		groups[#groups + 1] = g
		return g
	end
	-- where a control draws: its box, or nowhere when hidden (counted for the empty check)
	function Groupbox:_rawFor(idx)
		if self.hidden or HIDE[idx] then return Dummy, true end
		self.n += 1
		return self.raw, false
	end
	-- WindUI marks a box that is still EMPTY a moment after creation as not
	-- expandable and hides its Content frame for good - Open(), Close()+Open()
	-- and Expandable = true all leave it hidden (measured 10-04). The script
	-- creates every groupbox first and fills them later, so every box came up
	-- blank. Unhiding the frame after each add is what works; the box is
	-- already sized for its contents.
	function Groupbox:_reveal()
		if not self.sec or self._rq then return end
		self._rq = true
		task.defer(function()
			self._rq = false
			pcall(function()
				local c = self.sec.ElementFrame:FindFirstChild("Content", true)
				if c then c.Visible = true end
			end)
		end)
	end

	local function desc(e, text)
		if text and e and e.SetDesc then pcall(function() e:SetDesc(text) end) end
	end

	-- pickers chained onto a toggle or a label
	local Chain = {}
	function Chain.AddKeyPicker(parent, idx, info)
		breathe()
		info = info or {}
		local kp = {
			Type = "KeyPicker", Value = info.Default or "None", Mode = info.Mode or "Toggle",
			Text = titleOf(idx, info.Text), Callback = info.Callback, ChangedCallback = info.ChangedCallback,
			SyncToggleState = info.SyncToggleState, Toggled = false, _parent = parent,
			_changed = {}, _clicked = {}, _listening = false,
		}
		function kp:GetState()
			if self.Mode == "Always" then return true end
			if self.Mode == "Hold" then
				if self.Value == "MB1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
				if self.Value == "MB2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
				local ok, kc = pcall(function() return Enum.KeyCode[self.Value] end)
				return ok and kc and UIS:IsKeyDown(kc) or false
			end
			return self.Toggled
		end
		function kp:OnClick(fn) table.insert(self._clicked, fn) end
		function kp:OnChanged(fn) table.insert(self._changed, fn) end   -- key changes only
		local btn
		local function label() return string.format("%s   [ %s ]", tostring(kp.Text), tostring(kp.Value)) end
		function kp:SetValue(v)
			if type(v) == "table" then
				self.Value = v[1] or self.Value
				self.Mode = v[2] or self.Mode
			else
				self.Value = tostring(v)
			end
			if btn then pcall(function() btn.Text = label() end) end
			fire(self.ChangedCallback, self.Value)
			for _, fn in ipairs(self._changed) do fire(fn, self.Value) end
		end
		if not info.NoUI then
			local g = parent._group
			local e
			local function setTitle(t) if e then pcall(function() e:SetTitle(t) end) end end
			btn = setmetatable({}, { __newindex = function(_, k, v) if k == "Text" then setTitle(v) end end })
			local where = (parent._hidden or HIDE[idx]) and Dummy or g.raw
			pcall(function() e = where:Button({ Title = label(), Callback = function()
				if kp._listening then return end
				kp._listening = true
				setTitle(tostring(kp.Text) .. "   [ press a key ]")
				local conn
				conn = UIS.InputBegan:Connect(function(input)
					local n = keyName(input)
					if not n then return end
					conn:Disconnect()
					-- the click that opened the listener is MB1 itself: skip it
					if n == "MB1" and false then return end
					if n == "Escape" or n == "Backspace" then n = "None" end
					task.defer(function() kp._listening = false end)
					kp:SetValue(n)
				end)
			end }) end)
		end
		table.insert(pickers, kp)
		Options[idx] = lenient(kp)
		return parent
	end
	function Chain.AddColorPicker(parent, idx, info)
		breathe()
		info = info or {}
		local cp = {
			Type = "ColorPicker", Value = info.Default or Color3.new(1, 1, 1),
			Transparency = info.Transparency or 0, Callback = info.Callback, _changed = {},
		}
		local g = parent._group
		local e
		local ready = false
		local cpHidden = parent._hidden or HIDE[idx]
		if g and not cpHidden then g.n = (g.n or 0) + 1 end
		if g then
			pcall(function()
				e = (cpHidden and Dummy or g.raw):Colorpicker({
					Title = RENAME[idx] or tidy(info.Title or parent.Text or idx),
					Default = cp.Value,
					Transparency = info.Transparency,
					Callback = function(c, t)
						if not ready then return end
						cp.Value = c
						if t ~= nil then cp.Transparency = t end
						fire(cp.Callback, c)
						fireChanged(cp)
					end,
				})
			end)
		end
		ready = true
		function cp:SetValueRGB(c, t)
			self.Value = c
			if t ~= nil then self.Transparency = t end
			if e then pcall(function() e:Update(c, t) end) end
			fire(self.Callback, c)
			fireChanged(self)
		end
		function cp:SetValue(hsv, t)
			if typeof(hsv) == "Color3" then return self:SetValueRGB(hsv, t) end
			if type(hsv) == "table" then return self:SetValueRGB(Color3.fromHSV(hsv[1], hsv[2], hsv[3]), t) end
		end
		function cp:OnChanged(fn) onChanged(self, fn) end
		Options[idx] = lenient(cp)
		return parent
	end

	function Groupbox:AddToggle(idx, info)
		breathe()
		info = info or {}
		local tg = {
			Type = "Toggle", Value = info.Default and true or false, Text = titleOf(idx, info.Text),
			Callback = info.Callback, _changed = {}, _group = self,
		}
		local raw, hid = self:_rawFor(idx)
		tg._hidden = hid
		local ready = false
		local e
		pcall(function()
			e = raw:Toggle({
				Title = tg.Text,
				Value = tg.Value,
				Callback = function(v)
					v = v and true or false
					if not ready or v == tg.Value then return end
					tg.Value = v
					fire(tg.Callback, v)
					fireChanged(tg)
				end,
			})
		end)
		ready = true
		desc(e, info.Tooltip)
		function tg:SetValue(v)
			v = v and true or false
			self.Value = v
			ready = false
			if e then pcall(function() e:Set(v) end) end
			ready = true
			fire(self.Callback, v)
			fireChanged(self)
		end
		function tg:SetText(t)
			self.Text = t
			if e then pcall(function() e:SetTitle(t) end) end
		end
		function tg:OnChanged(fn) onChanged(self, fn) end
		tg.AddKeyPicker = Chain.AddKeyPicker
		tg.AddColorPicker = Chain.AddColorPicker
		Toggles[idx] = lenient(tg)
		return tg
	end

	function Groupbox:AddSlider(idx, info)
		breathe()
		info = info or {}
		local rounding = info.Rounding or 0
		local function round(v)
			local m = 10 ^ rounding
			return math.floor(v * m + 0.5) / m
		end
		local sl = {
			Type = "Slider", Value = info.Default or info.Min or 0, Min = info.Min or 0, Max = info.Max or 100,
			Rounding = rounding, Callback = info.Callback, _changed = {},
		}
		local title = titleOf(idx, info.Text)
		local raw = self:_rawFor(idx)
		if info.Suffix and info.Suffix ~= "" then title = title .. " (" .. tostring(info.Suffix):gsub("^%s+", "") .. ")" end
		local ready = false
		local e
		pcall(function()
			e = raw:Slider({
				Title = title,
				Step = 10 ^ -rounding,
				Value = { Min = sl.Min, Max = sl.Max, Default = sl.Value },
				Callback = function(v)
					v = round(tonumber(v) or sl.Value)
					if not ready or v == sl.Value then return end
					sl.Value = v
					fire(sl.Callback, v)
					fireChanged(sl)
				end,
			})
		end)
		ready = true
		desc(e, info.Tooltip)
		function sl:SetValue(v)
			v = round(math.clamp(tonumber(v) or self.Value, self.Min, self.Max))
			self.Value = v
			ready = false
			if e then pcall(function() e:Set(v) end) end
			ready = true
			fire(self.Callback, v)
			fireChanged(self)
		end
		function sl:SetMin(v) self.Min = v end
		function sl:SetMax(v) self.Max = v end
		function sl:OnChanged(fn) onChanged(self, fn) end
		Options[idx] = lenient(sl)
		return sl
	end

	local function playerNames()
		local out = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer then out[#out + 1] = p.Name end
		end
		table.sort(out)
		return out
	end
	local function safeValues(values)
		local out, seen = {}, {}
		for _, v in ipairs(values or {}) do
			local s = tostring(v)
			if not seen[s] then seen[s] = true ; out[#out + 1] = s end
		end
		if #out == 0 then out[1] = "-" end
		return out
	end

	function Groupbox:AddDropdown(idx, info)
		breathe()
		info = info or {}
		local isPlayer = info.SpecialType == "Player"
		local values = isPlayer and playerNames() or (info.Values or {})
		local dd = {
			Type = "Dropdown", Values = values, Multi = info.Multi, Callback = info.Callback,
			_changed = {}, AllowNull = info.AllowNull,
		}
		local def = info.Default
		if type(def) == "number" then def = values[def] end
		if dd.Multi then
			dd.Value = {}
			if type(def) == "table" then for _, v in ipairs(def) do dd.Value[v] = true end end
		else
			dd.Value = def or (not isPlayer and not info.AllowNull and values[1]) or nil
		end
		local raw = self:_rawFor(idx)
		local quiet = true
		local e
		pcall(function()
			e = raw:Dropdown({
				Title = titleOf(idx, info.Text),
				Values = safeValues(values),
				Value = dd.Multi and {} or (dd.Value and tostring(dd.Value) or nil),
				Multi = dd.Multi or nil,
				AllowNone = (dd.Multi or isPlayer or info.AllowNull) and true or nil,
				SearchBarEnabled = (#values > 8 or isPlayer) or nil,
				Callback = function(v)
					if quiet then return end
					if dd.Multi then
						local set = {}
						for _, x in ipairs(type(v) == "table" and v or {}) do set[x] = true end
						dd.Value = set
					else
						if v == "-" then v = nil end
						if v == dd.Value then return end
						dd.Value = v
					end
					fire(dd.Callback, dd.Value)
					fireChanged(dd)
				end,
			})
		end)
		quiet = false
		desc(e, info.Tooltip)
		function dd:SetValues(list)
			self.Values = list or {}
			quiet = true
			if e then pcall(function() e:Refresh(safeValues(self.Values)) end) end
			if not self.Multi and self.Value then pcall(function() e:Select(tostring(self.Value)) end) end
			quiet = false
		end
		function dd:SetValue(v)
			self.Value = v
			quiet = true
			if e and v ~= nil and not self.Multi then pcall(function() e:Select(tostring(v)) end) end
			quiet = false
			fire(self.Callback, v)
			fireChanged(self)
		end
		function dd:OnChanged(fn) onChanged(self, fn) end
		if isPlayer then
			local function refresh() dd:SetValues(playerNames()) end
			table.insert(keyConns, Players.PlayerAdded:Connect(refresh))
			table.insert(keyConns, Players.PlayerRemoving:Connect(function() task.defer(refresh) end))
		end
		Options[idx] = lenient(dd)
		return dd
	end

	function Groupbox:AddInput(idx, info)
		breathe()
		info = info or {}
		local ip = { Type = "Input", Value = tostring(info.Default or ""), Callback = info.Callback, _changed = {}, Numeric = info.Numeric }
		local raw = self:_rawFor(idx)
		local ready = false
		local e
		pcall(function()
			e = raw:Input({
				Title = titleOf(idx, info.Text),
				Value = ip.Value,
				Placeholder = info.Placeholder or "",
				Callback = function(v)
					if not ready then return end
					v = tostring(v or "")
					if ip.Numeric and v ~= "" and not tonumber(v) then return end
					if v == ip.Value then return end
					ip.Value = v
					fire(ip.Callback, v)
					fireChanged(ip)
				end,
			})
		end)
		ready = true
		desc(e, info.Tooltip)
		function ip:SetValue(v)
			v = tostring(v or "")
			self.Value = v
			ready = false
			if e then pcall(function() e:Set(v) end) end
			ready = true
			fire(self.Callback, v)
			fireChanged(self)
		end
		function ip:OnChanged(fn) onChanged(self, fn) end
		Options[idx] = lenient(ip)
		return ip
	end

	function Groupbox:AddButton(a, b)
		breathe()
		local text, fn = a, b
		if type(a) == "table" then text, fn = a.Text, a.Func or a.Callback end
		local btn = lenient({ Text = text })
		local raw = brandButton(text) and Dummy or self:_rawFor(tostring(text))
		pcall(function() raw:Button({ Title = titleOf(tostring(text), tostring(text)), Callback = function() fire(fn) end }) end)
		function btn:AddButton(x, y) return Groupbox.AddButton(self._group, x, y) end
		btn._group = self
		return btn
	end

	function Groupbox:AddLabel(text, wrap, idx)
		breathe()
		-- Obsidian: AddLabel({ Text, DoesWrap }, idx) or AddLabel(text, wrap, idx)
		if type(text) == "table" then idx = wrap text = text.Text end
		if type(wrap) == "string" then idx = wrap end
		local lb = lenient({ Type = "Label", Text = text, _group = self })
		if type(idx) == "string" then Options[idx] = lb end
		-- text-only cards are not drawn (teek: "cards that don't have a toggle").
		-- A colour/key picker chained on a label still gets its own row, titled
		-- with the label's text.
		lb._hidden = self.hidden
		local p
		function lb:SetText(t)
			self.Text = t
			if p then pcall(function() p:SetTitle(tostring(t)) end) end
		end
		lb.AddKeyPicker = Chain.AddKeyPicker
		lb.AddColorPicker = Chain.AddColorPicker
		return lb
	end

	function Groupbox:AddDivider()
		if not self.hidden then pcall(function() self.raw:Divider() end) end
	end
	function Groupbox:AddBlank() end
	-- Linoria dependency boxes (controls shown only while a toggle is on): the
	-- controls go straight into the parent box and stay visible (instance
	-- Rivals, 10-10). Returning the box itself keeps its control count right.
	function Groupbox:AddDependencyBox() return self end
	function Groupbox:SetupDependencies() end
	function Groupbox:AddDualSlider(a, b, infoA, infoB)
		self:AddSlider(a, infoA)
		return self:AddSlider(b, infoB)
	end
	function Library:AddToRegistry() end

	for _, name in ipairs({ "AddToggle", "AddSlider", "AddDropdown", "AddInput", "AddButton", "AddLabel", "AddDivider" }) do
		local f = Groupbox[name]
		Groupbox[name] = function(self, ...)
			local r = f(self, ...)
			self:_reveal()
			return r
		end
	end
	for _, name in ipairs({ "AddKeyPicker", "AddColorPicker" }) do
		local f = Chain[name]
		Chain[name] = function(parent, ...)
			local r = f(parent, ...)
			if parent._group then parent._group:_reveal() end
			return r
		end
	end

	-- ---------- Tab / Tabbox / Window
	local Tab = {}
	-- t.w (the TempoUI page) is made the first time a box draws on it, so the
	-- hidden Info tab and any tab left empty never reach the sidebar. A tab with
	-- subtabs becomes a TempoUI group: its own boxes on a page of its name,
	-- each subtab a page beside it.
	local function groupOf(t)
		if not t.group then t.group = t.window.ui:Group(tidy(t.name)) end
		return t.group
	end
	Tab.__index = function(t, k)
		if k == "w" then
			local ui = t.window.ui
			local w
			if t.parent then w = groupOf(t.parent):Tab(tidy(t.name))
			elseif #t.kids > 0 then w = groupOf(t):Tab(tidy(t.name))
			else w = ui:Tab(tidy(t.name)) end
			rawset(t, "w", w)
			return w
		end
		local f = rawget(Tab, k)
		if f ~= nil then return f end
		if isMethod(k) then return function() return Stub end end
	end
	function Tab:AddSubTab(name)
		local s = setmetatable({ name = tostring(name or "Page"), window = self.window, parent = self, boxes = {}, kids = {}, hidden = self.hidden }, Tab)
		table.insert(self.kids, s)
		return s
	end
	Tab.AddPage = Tab.AddSubTab
	function Tab:AddLeftGroupbox(name) return newGroupbox(self, name) end
	function Tab:AddRightGroupbox(name) return newGroupbox(self, name) end
	function Tab:AddGroupbox(info) return newGroupbox(self, type(info) == "table" and info.Name or tostring(info)) end
	local function tabbox(tab)
		local first
		return { AddTab = function(_, name)
			local g = newGroupbox(tab, name, first)
			first = first or name
			return g
		end }
	end
	function Tab:AddLeftTabbox() return tabbox(self) end
	function Tab:AddRightTabbox() return tabbox(self) end

	local Window = {}
	Window.__index = function(_, k)
		local f = rawget(Window, k)
		if f ~= nil then return f end
		if isMethod(k) then return function() return Stub end end   -- AddDialog, SetFooter ...
	end
	function Window:AddTab(name)
		-- one page per window tab ("combat" -> "Combat"); its boxes are sections
		if type(name) == "table" then name = name.Name or name.Title end
		name = tostring(name or "Tab")
		local t = setmetatable({ name = name, window = self, boxes = {}, kids = {}, hidden = HIDE_TABS[name] }, Tab)
		Library._wtabs = Library._wtabs or {}
		table.insert(Library._wtabs, t)
		return t
	end

	function Library:CreateWindow(opts)
		opts = opts or {}
		local ui = TeekUI.new({ Title = "Tempo Hub", Subtitle = getgenv().TempoHoodSubtitle or "GAMES", Version = "v1" })
		self.ui = ui
		task.defer(function() pcall(function() ui:Show() end) end)
		return setmetatable({ ui = ui }, Window)
	end
	function Library:Toggle() if self.ui then pcall(function() self.ui:Toggle() end) end end
	function Library:Notify(text, seconds)
		-- Obsidian: Notify({ Title, Description, Time })
		if type(text) == "table" then
			local d = text.Description or text.Content or text.Text
			seconds = tonumber(text.Time) or seconds
			text = (text.Title and d) and (tostring(text.Title) .. ": " .. tostring(d)) or (d or text.Title or "")
		end
		if type(seconds) ~= "number" then seconds = nil end
		if self.ui then pcall(function() self.ui:Notify(tostring(text), nil, seconds) end) end
	end
	function Library:SetWatermark() end
	function Library:SetWatermarkVisibility() end
	function Library:UpdateColors() end
	function Library:OnUnload(fn) table.insert(self.unloadFns, fn) end
	-- Linoria internals some scripts build their own overlays with (instance
	-- Rivals' hit notifications): a ScreenGui of our own, Create / CreateLabel,
	-- the theme colours and a hidden KeybindFrame they toggle.
	Library.MainColor = Color3.fromRGB(22, 23, 28)
	Library.BackgroundColor = Color3.fromRGB(16, 17, 21)
	Library.OutlineColor = Color3.fromRGB(45, 47, 56)
	Library.FontColor = Color3.fromRGB(235, 236, 240)
	Library.Font = Enum.Font.Gotham
	do
		local sg = Instance.new("ScreenGui")
		sg.Name = "TempoOverlay"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 2147483640
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
		pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
		if not sg.Parent then sg.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
		Library.ScreenGui = sg
		local kf = Instance.new("Frame")
		kf.Name = "KeybindFrame"
		kf.Visible = false
		kf.Parent = sg
		Library.KeybindFrame = kf
	end
	function Library:Create(class, props)
		local inst = type(class) == "string" and Instance.new(class) or class
		for k, v in pairs(props or {}) do
			if k ~= "Parent" then pcall(function() inst[k] = v end) end
		end
		if props and props.Parent then inst.Parent = props.Parent end
		return inst
	end
	function Library:CreateLabel(props, isHud)
		local l = self:Create("TextLabel", { BackgroundTransparency = 1, Font = self.Font, TextColor3 = self.FontColor, TextSize = 14, TextStrokeTransparency = 0 })
		return self:Create(l, props)
	end
	function Library:UpdateDependencyBoxes() end
	function Library:Unload()
		if self.Unloaded then return end
		for _, fn in ipairs(self.unloadFns) do fire(fn) end
		self.Unloaded = true
		for _, c in ipairs(keyConns) do pcall(function() c:Disconnect() end) end
		if self.ui then pcall(function() self.ui:Destroy() end) end
		pcall(function() self.ScreenGui:Destroy() end)
	end
	getgenv().Library = Library

	-- ---------- SaveManager: configs as JSON under TempoHub/<folder>/
	local SaveManager = lenient({ folder = "TempoHub/games", ignore = {} })
	SaveManager.Ignore = SaveManager.ignore   -- Obsidian scripts read SaveManager.Ignore[idx]
	SaveManager.Library = Library
	local function ensure(path)
		if not (isfolder and makefolder) then return end
		local acc = ""
		for part in string.gmatch(path, "[^/]+") do
			acc = acc == "" and part or (acc .. "/" .. part)
			pcall(function() if not isfolder(acc) then makefolder(acc) end end)
		end
	end
	function SaveManager:SetLibrary() end
	function SaveManager:IgnoreThemeSettings() end
	function SaveManager:SetIgnoreIndexes(list) for _, k in ipairs(list or {}) do self.ignore[k] = true end end
	function SaveManager:SetFolder(f)
		f = tostring(f):gsub("^TempoHub/?", "")
		self.folder = "TempoHub/games/" .. (f ~= "" and f or "configs")
		ensure(self.folder)
	end
	function SaveManager:Save(name)
		if not writefile then return false, "no writefile" end
		local data = { toggles = {}, options = {} }
		for k, t in pairs(Toggles) do if not self.ignore[k] then data.toggles[k] = t.Value end end
		for k, o in pairs(Options) do
			if not self.ignore[k] then
				if o.Type == "ColorPicker" then data.options[k] = { "c", o.Value:ToHex(), o.Transparency }
				elseif o.Type == "KeyPicker" then data.options[k] = { "k", o.Value, o.Mode }
				elseif o.Type == "Dropdown" and o.Multi then
					local l = {} for v, on in pairs(o.Value or {}) do if on then l[#l + 1] = v end end
					data.options[k] = { "m", l }
				elseif o.Value ~= nil then data.options[k] = { "v", o.Value } end
			end
		end
		ensure(self.folder)
		local ok = pcall(function() writefile(self.folder .. "/" .. name .. ".json", HttpService:JSONEncode(data)) end)
		return ok
	end
	function SaveManager:Load(name)
		if not (readfile and isfile) then return false end
		local path = self.folder .. "/" .. name .. ".json"
		local ok, data = pcall(function() return isfile(path) and HttpService:JSONDecode(readfile(path)) end)
		if not (ok and type(data) == "table") then return false end
		for k, v in pairs(data.toggles or {}) do
			local t = Toggles[k]
			if t and t.Value ~= v then pcall(function() t:SetValue(v) end) end
		end
		for k, v in pairs(data.options or {}) do
			local o = Options[k]
			if o and type(v) == "table" then
				pcall(function()
					if v[1] == "c" then o:SetValueRGB(Color3.fromHex(v[2]), v[3])
					elseif v[1] == "k" then o:SetValue({ v[2], v[3] })
					elseif v[1] == "m" then
						local set = {} for _, x in ipairs(v[2] or {}) do set[x] = true end
						o:SetValue(set)
					else o:SetValue(v[2]) end
				end)
			end
		end
		return true
	end
	function SaveManager:List()
		local out = {}
		if not listfiles then return out end
		pcall(function()
			for _, f in ipairs(listfiles(self.folder)) do
				local n = string.match(f, "([^/\\]+)%.json$")
				if n then out[#out + 1] = n end
			end
		end)
		table.sort(out)
		return out
	end
	function SaveManager:BuildConfigSection(tab)
		if type(tab) == "table" and rawget(tab, "_t") then tab = rawget(tab, "_t") end   -- a Fluent / Rayfield tab
		local g = tab:AddRightGroupbox("Configuration")
		local nameBox = g:AddInput("TempoCfgName", { Text = "Config name", Default = "", Placeholder = "name" })
		local list = g:AddDropdown("TempoCfgList", { Text = "Saved configs", Values = self:List(), AllowNull = true })
		g:AddButton("Save config", function()
			local n = nameBox.Value ~= "" and nameBox.Value or list.Value
			if not n or n == "" then Library:Notify("type a config name first", 3) return end
			if self:Save(n) then Library:Notify("saved " .. n, 2) list:SetValues(self:List()) end
		end)
		g:AddButton("Load config", function()
			local n = list.Value
			if n and self:Load(n) then Library:Notify("loaded " .. n, 2) end
		end)
		g:AddButton("Load this config on start", function()
			local n = list.Value
			if not (n and writefile) then return end
			pcall(function() writefile(self.folder .. "/autoload.txt", n) end)
			Library:Notify("autoload: " .. n, 2)
		end)
		self.ignore.TempoCfgName, self.ignore.TempoCfgList = true, true
		return g   -- Obsidian scripts add their own import/export rows to it
	end
	function Library:_dropEmpty()
		if self._dropped then return end
		self._dropped = true
		for _, g in ipairs(groups) do
			if (g.n or 0) == 0 and g.sec then pcall(function() g.sec:Destroy() end) end
		end
	end
	function SaveManager:LoadAutoloadConfig()
		Library._flush()
		Library:_dropEmpty()
		if not (readfile and isfile) then return end
		local ok, n = pcall(function()
			local p = self.folder .. "/autoload.txt"
			return isfile(p) and readfile(p)
		end)
		if ok and type(n) == "string" and n ~= "" then
			if self:Load(n) then Library:Notify("loaded config " .. n, 2) end
		end
	end
	getgenv().SaveManager = SaveManager

	-- ---------- ThemeManager: WindUI's own theme / scale / menu key panel
	local ThemeManager = lenient({ Library = Library })
	function ThemeManager:SetLibrary() end
	function ThemeManager:SetFolder() end
	function Library._mountInterface()
		if Library._interface or not Library.ui then return end
		Library._interface = true
		pcall(function() Library.ui:mountInterface(Library.ui:Tab("Interface", "sliders")) end)
	end
	function ThemeManager:ApplyToTab(tab)
		-- our own Interface page, like every other hub (not mixed into Settings),
		-- after the game's tabs: those are only drawn at the flush
		Library._wantInterface = true
		if flushed then Library._mountInterface() end
	end
	ThemeManager.BuildInterfaceSection = ThemeManager.ApplyToTab   -- Fluent's InterfaceManager
	getgenv().ThemeManager = ThemeManager

	-- ---------- Fluent (Fluent-Renewed) and Rayfield / Rayfield Gen2 / OuroFlow
	-- The backlog's other menus, mapped onto the same tabs and boxes. Fluent:
	-- Window:AddTab({ Title }) / tab:AddSection, controls AddToggle(id, { Title,
	-- Default, Callback }) or the same as Create*, Fluent.Options[id] for every
	-- control. Rayfield: Window:CreateTab(name), tab:CreateSection(name), controls
	-- CreateToggle({ Name, CurrentValue, Flag, Callback }) with :Set, Flags[flag];
	-- Gen2 spells the keys in lower case. OuroFlow: Rayfield's controls on
	-- Linoria's tabs (CreateTab({ Name }) -> AddLeftGroupbox({ Name })).
	local FluentOptions = setmetatable({}, { __index = function(_, k) return rawget(Options, k) or rawget(Toggles, k) or Options[k] end })
	local Fluent = loose({ Options = FluentOptions, Unloaded = false })
	Library:OnUnload(function() Fluent.Unloaded = true end)
	local FBox = {}
	local function fbox(gb)
		return setmetatable({ gb = gb }, { __index = function(_, k)
			local f = FBox[k]
			if f then return f end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	function FBox:AddToggle(id, c) c = c or {} return self.gb:AddToggle(id, { Text = c.Title, Default = c.Default, Tooltip = c.Description, Callback = c.Callback }) end
	function FBox:AddSlider(id, c) c = c or {} return self.gb:AddSlider(id, { Text = c.Title, Default = c.Default, Min = c.Min, Max = c.Max, Rounding = c.Rounding, Callback = c.Callback }) end
	function FBox:AddDropdown(id, c) c = c or {} return self.gb:AddDropdown(id, { Text = c.Title, Values = c.Values, Multi = c.Multi, Default = c.Default, AllowNull = c.AllowNull, Callback = c.Callback }) end
	function FBox:AddInput(id, c) c = c or {} return self.gb:AddInput(id, { Text = c.Title, Default = c.Default, Placeholder = c.Placeholder, Numeric = c.Numeric, Callback = c.Callback }) end
	function FBox:AddButton(c) c = c or {} return self.gb:AddButton({ Text = c.Title, Func = c.Callback }) end
	function FBox:AddParagraph(c) c = c or {} return self.gb:AddLabel(tostring(c.Title or "")) end
	function FBox:AddKeybind(id, c) c = c or {} self.gb:AddLabel(c.Title or id):AddKeyPicker(id, { Default = c.Default, Mode = c.Mode, Text = c.Title, Callback = c.Callback, ChangedCallback = c.ChangedCallback }) return Options[id] end
	function FBox:AddColorpicker(id, c) c = c or {} self.gb:AddLabel(c.Title or id):AddColorPicker(id, { Default = c.Default, Title = c.Title, Callback = c.Callback }) return Options[id] end
	FBox.AddColorPicker = FBox.AddColorpicker
	for _, n in ipairs({ "Toggle", "Slider", "Dropdown", "Input", "Button", "Paragraph", "Keybind", "Colorpicker", "ColorPicker" }) do FBox["Create" .. n] = FBox["Add" .. n] end
	-- a tab: its own controls land in a box named after it, AddSection makes more
	local function ftab(t)
		local o = { _t = t }
		function o:AddSection(title) return fbox(t:AddLeftGroupbox(tostring(type(title) == "table" and (title.Title or title.Name) or title or "Section"))) end
		o.CreateSection = o.AddSection
		return setmetatable(o, { __index = function(self, k)
			if FBox[k] then
				return function(me, ...)
					rawset(me, "_box", rawget(me, "_box") or fbox(t:AddLeftGroupbox(t.name)))
					return FBox[k](rawget(me, "_box"), ...)
				end
			end
			if type(k) == "string" and string.find(k, "^%u") then return function() return Stub end end
		end })
	end
	function Fluent:CreateWindow(opts)
		local w = Library:CreateWindow(opts)
		local W = {}
		function W:AddTab(info) return ftab(w:AddTab(type(info) == "table" and (info.Title or info.Name) or tostring(info))) end
		W.CreateTab = W.AddTab
		return loose(W)
	end
	function Fluent:Notify(c)
		c = type(c) == "table" and c or { Content = tostring(c) }
		Library:Notify({ Title = c.Title, Description = c.Content or c.SubContent, Time = c.Duration })
	end
	function Fluent:Destroy() Library:Unload() end
	getgenv().Fluent = Fluent

	-- Rayfield / Gen2 / OuroFlow controls: one config reader for both spellings
	local function pick(c, a, b) if c[a] ~= nil then return c[a] end return c[b] end
	local Flags = {}
	local function relem(o, kind)
		return setmetatable({}, { __index = function(_, k)
			if k == "CurrentValue" or k == "Value" or k == "value" then
				if kind == "dropdown" and type(o.Value) == "table" then local l = {} for v, on in pairs(o.Value) do if on then l[#l + 1] = v end end return l end
				return o.Value
			end
			if k == "CurrentOption" then
				if type(o.Value) == "table" then local l = {} for v, on in pairs(o.Value) do if on then l[#l + 1] = v end end return l end
				return { o.Value }
			end
			if k == "CurrentKeybind" then return o.Value end
			if k == "Set" or k == "SetValue" then
				return function(_, v)
					if kind == "dropdown" then
						if o.Multi then local s = {} for _, x in ipairs(type(v) == "table" and v or { v }) do s[x] = true end o:SetValue(s)
						else o:SetValue(type(v) == "table" and v[1] or v) end
					else o:SetValue(v) end
				end
			end
			if k == "Refresh" or k == "SetOptions" then return function(_, list) o:SetValues(list) end end
			if k == "OnChanged" then return function(_, fn) o:OnChanged(fn) end end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	local function decimals(step) local s = tostring(step or 1) local d = s:match("%.(%d+)$") return d and #d or 0 end
	local RBox = {}
	local function rbox(gb, flavor)
		return setmetatable({ gb = gb, flavor = flavor }, { __index = function(_, k)
			local f = RBox[k]
			if f then return f end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	local function idOf(c) return tostring(pick(c, "Flag", "flag") or pick(c, "Name", "name") or "Control") end
	local function reg(c, e) local f = pick(c, "Flag", "flag") if f then Flags[f] = e end return e end
	function RBox:CreateToggle(c)
		c = c or {}
		local cb = pick(c, "Callback", "callback")
		local o = self.gb:AddToggle(idOf(c), { Text = pick(c, "Name", "name"), Default = pick(c, "CurrentValue", "value"), Callback = cb })
		-- Rayfield fires the callback with the starting value; OuroFlow / Gen2 too
		if cb and o.Value then task.defer(function() pcall(cb, o.Value) end) end
		return reg(c, relem(o, "toggle"))
	end
	function RBox:CreateSlider(c)
		c = c or {}
		local range = pick(c, "Range", "range") or { 0, 100 }
		local o = self.gb:AddSlider(idOf(c), { Text = pick(c, "Name", "name"), Min = range[1], Max = range[2],
			Default = pick(c, "CurrentValue", "value"), Rounding = decimals(pick(c, "Increment", "increment")),
			Suffix = pick(c, "Suffix", "suffix"), Callback = pick(c, "Callback", "callback") })
		return reg(c, relem(o, "slider"))
	end
	function RBox:CreateDropdown(c)
		c = c or {}
		local multi = pick(c, "MultipleOptions", "multiSelect") or c.Multi
		local cur = pick(c, "CurrentOption", "value")
		local def = multi and (type(cur) == "table" and cur or { cur }) or (type(cur) == "table" and cur[1] or cur)
		local cb = pick(c, "Callback", "callback")
		local flavor = self.flavor
		local o = self.gb:AddDropdown(idOf(c), { Text = pick(c, "Name", "name"), Values = pick(c, "Options", "options") or {},
			Multi = multi, Default = def, AllowNull = true,
			Callback = cb and function(v)
				-- Rayfield hands back a list every time; OuroFlow / Gen2 the value itself
				local list = v
				if type(v) == "table" then list = {} for x, on in pairs(v) do if on then list[#list + 1] = x end end end
				if flavor == "rayfield" then cb(type(list) == "table" and list or { list }) else cb(list) end
			end })
		return reg(c, relem(o, "dropdown"))
	end
	function RBox:CreateInput(c)
		c = c or {}
		local o = self.gb:AddInput(idOf(c), { Text = pick(c, "Name", "name"), Default = pick(c, "CurrentValue", "value"),
			Placeholder = pick(c, "PlaceholderText", "placeholder"), Callback = pick(c, "Callback", "callback") })
		return reg(c, relem(o, "input"))
	end
	function RBox:CreateButton(c) c = c or {} self.gb:AddButton({ Text = pick(c, "Name", "name"), Func = pick(c, "Callback", "callback") }) return Stub end
	function RBox:CreateKeybind(c)
		c = c or {}
		local cb = pick(c, "Callback", "callback")
		local hold = pick(c, "HoldToInteract", "hold")
		local id = idOf(c)
		self.gb:AddLabel(pick(c, "Name", "name") or id):AddKeyPicker(id, { Default = pick(c, "CurrentKeybind", "value") or "None",
			Mode = hold and "Hold" or "Toggle", Text = pick(c, "Name", "name"), Callback = cb,
			ChangedCallback = pick(c, "OnChanged", "changed") })
		return reg(c, relem(Options[id], "keybind"))
	end
	function RBox:CreateColorPicker(c)
		c = c or {}
		local id = idOf(c)
		self.gb:AddLabel(pick(c, "Name", "name") or id):AddColorPicker(id, { Default = pick(c, "Color", "value"), Title = pick(c, "Name", "name"), Callback = pick(c, "Callback", "callback") })
		return reg(c, relem(Options[id], "color"))
	end
	function RBox:CreateLabel() return Stub end
	function RBox:CreateParagraph() return Stub end
	-- OuroFlow names its controls the Linoria way too
	RBox.AddToggle, RBox.AddSlider, RBox.AddDropdown, RBox.AddButton = RBox.CreateToggle, RBox.CreateSlider, RBox.CreateDropdown, RBox.CreateButton
	local function rtab(t, flavor)
		local o = { _t = t }
		-- Rayfield: sections split the tab; controls land in the newest one
		function o:CreateSection(name)
			if type(name) == "table" then name = pick(name, "Name", "name") end
			rawset(self, "_box", rbox(t:AddLeftGroupbox(tostring(name or t.name)), flavor))
			return Stub
		end
		-- OuroFlow: Linoria boxes holding Rayfield controls
		function o:AddLeftGroupbox(info) return rbox(t:AddLeftGroupbox(type(info) == "table" and pick(info, "Name", "name") or tostring(info)), flavor) end
		o.AddRightGroupbox = o.AddLeftGroupbox
		function o:CreateConfigManager() SaveManager:BuildConfigSection(t) return Stub end
		function o:CreateThemeManager() ThemeManager:ApplyToTab(t) return Stub end
		return setmetatable(o, { __index = function(self, k)
			if RBox[k] then
				return function(me, ...)
					rawset(me, "_box", rawget(me, "_box") or rbox(t:AddLeftGroupbox(t.name), flavor))
					return RBox[k](rawget(me, "_box"), ...)
				end
			end
			if isMethod(k) then return function() return Stub end end
		end })
	end
	local function rayLib(flavor)
		local R = loose({ Flags = Flags, Unloaded = false })
		Library:OnUnload(function() R.Unloaded = true end)
		function R:CreateWindow(opts)
			local w = Library:CreateWindow(opts)
			local W = loose({})
			function W:CreateTab(name)
				if type(name) == "table" then name = pick(name, "Name", "name") or name.Title end
				return rtab(w:AddTab(tostring(name or "Tab")), flavor)
			end
			W.AddTab = W.CreateTab
			function W:Notify(c) R:Notify(c) end
			function W:LoadAutoload() SaveManager:LoadAutoloadConfig() end
			R.Window = W
			return W
		end
		function R:Notify(c)
			c = type(c) == "table" and c or { Content = tostring(c) }
			Library:Notify({ Title = pick(c, "Title", "title"), Description = pick(c, "Content", "content"), Time = pick(c, "Duration", "duration") })
		end
		function R:LoadConfiguration() SaveManager:LoadAutoloadConfig() end
		R.LoadAutoload = R.LoadConfiguration
		function R:Destroy() Library:Unload() end
		R.Unload = R.Destroy
		return R
	end
	getgenv().Rayfield = rayLib("rayfield")
	getgenv().RayfieldGen2 = rayLib("gen2")
	getgenv().OuroFlow = rayLib("ouroflow")

	-- The script binds Library.ToggleKeybind = Options.MenuKeybind (default End)
	-- after building; follow that picker for the window's open/close key.
	task.spawn(function()
		for _ = 1, 600 do
			local kp = rawget(Options, "MenuKeybind")
			if kp and Library.ui then
				local function apply()
					local n = kp.Value
					if n and n ~= "None" and not string.find(n, "^MB") then pcall(function() Library.ui:SetToggleKey(n) end) end
				end
				apply()
				kp:OnChanged(apply)
				return
			end
			task.wait(0.1)
		end
	end)
end

return (function(...)
local fns = {}
local wF_1, wF_3, wF_4, wF_5, wF_7, wF_9, wF_15, wF_17, UserInputService, wF_19, wF_21, wF_24, wF_27, wF_29, wF_31, wF_32, wF_33, wF_34, wF_36
local oG
local o1
local OreMetadata
local oJ
local o4
local n0
local connection2
local Workspace
local n3
local ot
local pa
local oP
local ow
local pd
local oM
local oV
local oz
local oS
local oC
local pj
local o0
local nX
local oI
local n_
local om
local o6
local n2
local oO
local oq
local o9
local oR
local pc
local n8
local oU
local pf
local n5
local oX
local pi
local nT
local oe
local oE
local nW
local o2
local oK
local oN
local connection3
local pb
local ox
local oT
local pe
local connection
local oD
local oZ
local nV
function fns.worker2()
    while not pc.Unloaded do
        task.wait(2)
        if nW("AntiAfk") then
            local vV = tick() - pf
            local vW = tick() - pe
            if vV >= 300 and vW >= 60 then
                pcall(oS)
            else
                if vV < 300 and vW >= 300 then
                    pcall(oS)
                end
            end
        end
    end
end
function fns.worker6()
    while not pc.Unloaded do
        if nW("AutoUpgradeTunnels") then
            o9(oJ())
            task.wait(oI("UpgradeTunnelDelay", 0.45))
        else
            task.wait(0.25)
        end
    end
end
function fns.fn50(br)
    local q3 = not br or not br:IsA("ProximityPrompt")
    if q3 then
        return false
    elseif br.Enabled ~= true then
        return false
    elseif br:GetAttribute("ClientForceHidden") == true then
        return false
    else
        return true
    end
end
function fns.fn52(hM)
    local DiscordGroup = hM:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = oK })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = oK })
end
local function fn86(bm)
    if not bm then
        return nil
    end
    local Parent = bm.Parent
    local qZ = Parent and Parent:IsA("BasePart")
    if qZ then
        return Parent.Position
    end
    local qZ_1 = Parent and Parent:IsA("Model")
    if qZ_1 then
        return Parent:GetPivot().Position
    end
    return nil
end
local function worker4()
    while not pc.Unloaded do
        if nW("AutoClaimOnlineRewards") then
            oP()
            task.wait(oI("ClaimOnlineDelay", 2))
        else
            task.wait(0.25)
        end
    end
end
local function fn126(ap, aq)
    return string.format('<font color="%s">%s</font>', aq, ap)
end
local function worker7()
    while not pc.Unloaded do
        local wy = nW("AutoUpgradeDrillYield") or nW("AutoUpgradeDrillSpeed") or nW("AutoUpgradeOreRegen") or nW("AutoUpgradePedestal") or nW("AutoUpgradeOreLuck")
        if wy then
            oU(oJ())
            task.wait(oI("UpgradeDelay", 1))
        else
            task.wait(0.25)
        end
    end
end
local function fn153(as, at, au)
    return string.format("<b>%s</b> %s %s", as, oC("-", "#5a6070"), oC(at, au))
end
local function fn157(cM)
    local rV = oX(cM)
    if not rV then
        return 0
    end
    local rW = oN[rV] or OreMetadata.GetRarityRank(rV)
    return rW or 0
end
local function fn166(a0, a1)
    if not n0(a0) then
        return true
    end
    return ow(a0)[tostring(a1)] == true
end
local function onInputChanged(iG)
    local UserInputType = iG.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        pf = tick()
    end
end
local function fn175(f_)
    local um = {}
    if not f_ then
        return um
    end
    for i, descendant in ipairs(f_:GetDescendants()) do
        local un = descendant.Name == "PurchaseModel" and descendant:IsA("Model")
        if un then
            local un_1 = tonumber(descendant:GetAttribute("PurchasePrice"))
            local uo = tonumber(descendant:GetAttribute("FloorNumber"))
            local up = descendant:GetAttribute("TunnelName")
            if uo == nil then
                local uq_1 = descendant.Parent and descendant.Parent.Parent
                local ur_1 = uq_1
                if uq_1 then
                    uq_1 = tonumber(string.match(ur_1.Name, "(%d+)$"))
                end
                uo = uq_1 or nil
            end
            local uq_2 = up == ""
            local ur_3 = type(up) ~= "string" or uq_2
            if ur_3 then
                up = descendant.Parent and descendant.Parent.Name or nil
            end
            local uq_4 = un_1 ~= nil and uo ~= nil and type(up) == "string"
            if uq_4 then
                local uq_5 = string.format("Floor%d_Tunnel%s_Unlocked", uo, up)
                if o4:GetAttribute(uq_5) ~= true then
                    table.insert(um, { price = un_1, floor = uo, tunnel = up })
                end
            end
        end
    end
    table.sort(um, function(ge, gf)
        if ge.price == gf.price then
            if ge.floor == gf.floor then
                return ge.tunnel < gf.tunnel
            end
            return ge.floor < gf.floor
        end
        return ge.price < gf.price
    end)
    return um
end
local function fn180(gn, go)
    local uz = 5 ^ (go - 1)
    if gn == 1 then
        return 10000 * uz
    elseif gn == 2 then
        return 200000 * uz
    else
        return nil
    end
end
local function fn198(cd, ce)
    local rC_1
    local rB_1
    if nT then
        return false
    end
    nT = true
    rB_1, rC_1 = pcall(cd, ce)
    nT = false
    return rB_1 and rC_1 or false
end
local function fn217()
    local Character = o4.Character
    local qW = Character and Character:FindFirstChild("HumanoidRootPart")
    return qW
end
local function fn329()
    local qF = tonumber(o4:GetAttribute("Money")) or 0
    return qF
end
local function worker()
    local vi_1
    while true do
        task.wait(1)
        if pc.Unloaded then
            break
        end
        local vh = math.floor(os.clock() - pa)
        if vh < 60 then
            vi_1 = vh .. "s"
        elseif vh < 3600 then
            vi_1 = string.format("%dm %ds", math.floor((vh) / (60)), vh % 60)
        else
            vi_1 = string.format("%dh %dm", math.floor((vh) / (3600)), math.floor((vh % 3600) / (60)))
        end
        n8:SetText(ot("Session time", vi_1, n_))
    end
end
local function fn403()
    local tm_1
    local tl_1
    local tk = {}
    for k, v in pairs(o4:GetAttributes()) do
        if v == true then
            tm_1, tl_1 = string.match(k, "^Floor(%d+)_Tunnel(Tunnel%d+)_Unlocked$")
            if tm_1 and tl_1 then
                local tn_1 = string.format("Floor%s_Tunnel%s", tm_1, tl_1)
                local attr = o4:GetAttribute(tn_1 .. "_OreType")
                local max = math.max
                local floor = math.floor
                local tr = tonumber(o4:GetAttribute(tn_1 .. "_OreLevel")) or 1
                local tn_2 = max(1, floor(tr))
                local tp_1 = attr ~= ""
                local tq_1 = type(attr) == "string" and tp_1
                if tq_1 then
                    table.insert(tk, { floor = tonumber(tm_1), tunnel = tl_1, ore = attr, level = tn_2 })
                end
            end
        end
    end
    table.sort(tk, function(eF, eG)
        if eF.floor == eG.floor then
            return eF.tunnel < eG.tunnel
        end
        return eF.floor < eG.floor
    end)
    return tk
end
local function fn404()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    pb:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    pb:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    pe = tick()
end
local function fn409()
    local vd_1
    local vc_1
    if identifyexecutor then
        vd_1, vc_1 = identifyexecutor()
        local ve = vd_1 ~= ""
        local vf = type(vd_1) == "string" and ve
        if vf then
            local ve_1 = type(vc_1) == "string" and vc_1 ~= "" and vd_1 .. " " .. vc_1
            ox = ve_1 or vd_1
        end
    end
end
local function fn431()
    local sR_1
    local sQ_1
    sQ_1, sR_1 = pcall(function()
        return n5:InvokeServer()
    end)
    local sS = not sQ_1 or type(sR_1) ~= "table"
    if sS then
        return nil
    elseif type(sR_1.rewards) == "table" then
        return sR_1
    else
        local sQ_2 = type(sR_1.result) == "table" and type(sR_1.result.rewards) == "table"
        if sQ_2 then
            return sR_1.result
        end
        return nil
    end
end
local function fn446(c9)
    if not c9 then
        return nil
    end
    local TrashBin = c9:FindFirstChild("TrashBin", true)
    if not TrashBin then
        return nil
    end
    for i, descendant in ipairs(TrashBin:GetDescendants()) do
        local sc = descendant:IsA("ProximityPrompt") and descendant.ActionText == "Throw Away"
        if sc then
            return descendant
        end
    end
    return TrashBin:FindFirstChildWhichIsA("ProximityPrompt", true)
end
local function onRscripts()
    o0(oO, "Copied Rscripts profile to clipboard")
end
local function fn506(cT)
    local rY = cT == ""
    local rY_7
    local rZ = type(cT) ~= "string" or rY
    if rZ then
        return false
    end
    local rY_1 = oX(cT)
    local rZ_1 = OreMetadata.GetSeedCost(cT) or 0
    local rZ_2 = oI("BuyRollMaxSeedCost", 0)
    if rZ_2 > 0 and rZ_1 > rZ_2 then
        return false
    elseif o2() < rZ_1 then
        return false
    else
        local rZ_3 = n0("BuyRollOres")
        local r__1 = n0("BuyRollRarities")
        if rZ_3 or r__1 then
            local r0_2 = rZ_3 and pj("BuyRollOres", cT)
            local rZ_4 = r0_2 or false
            local r0_3 = r__1
            if r0_3 then
                r0_3 = rY_1 ~= nil
            end
            if r0_3 then
                r0_3 = pj("BuyRollRarities", rY_1)
            end
            if not (rZ_4 or (r0_3 or false)) then
                return false
            end
            o1("BuyRollMinRarity", "Common")
            if oG(cT) < rY_7 then
                return false
            end
            return true
        end
        local rY_6 = o1("BuyRollMinRarity", "Common")
        rY_7 = oN[rY_6] or 0
        if oG(cT) < rY_7 then
            return false
        end
        return true
    end
end
local function fn512(aB)
    if pc.Unloaded then
        return false
    end
    local qo = oZ[aB]
    return qo ~= nil and qo.Value == true
end
local function fn567(fo)
    local max = math.max
    local floor = math.floor
    local t0 = (tonumber(o4:GetAttribute("MaxFloorUnlocked")))
    local t5 = if t0 then 1 else 0
    local t3 = 2014 * t5 + 99 * (1 - t5)
    local t4 = 2863 * t5 + 2351 * (1 - t5)
    if not ((t3 * 3289 + t4 * 2278 + t3 * t4) % 16777213 == 2134829) then
        t0 = 1
    end
    local t1 = max(1, floor(t0))
    local tZ_1 = t1 + 1
    local t__1 = fo and fo:FindFirstChild("Floors")
    local t0_1 = t__1
    if t__1 then
        t__1 = t0_1:FindFirstChild(string.format("Floor%d", tZ_1))
    end
    if t__1 == nil then
        return nil
    end
    return tZ_1
end
local function fn571(gh, gi)
    return math.floor(80 * 5 ^ (gi - 1) * 1.45 ^ (math.max(1, gh) - 1))
end
local function fn576()
    o0(oT, "Copied Discord invite to clipboard")
end
local function fn591()
    local attr = o4:GetAttribute("AssignedBaseName")
    local qI = attr ~= ""
    local qJ = type(attr) == "string" and qI
    if qJ then
        return attr
    end
    return nil
end
local function fn594()
    local qO = oR()
    if not qO then
        return nil
    end
    local Bases = Workspace:FindFirstChild("Bases")
    local qQ = Bases and Bases:FindFirstChild(qO)
    local qP_1 = qQ and qQ:IsA("Model")
    if qP_1 then
        return qQ
    end
    return nil
end
local function worker5()
    while not pc.Unloaded do
        if nW("AutoUnlockFloors") then
            local wt = o6(oJ())
            local wv = wt and oI("UnlockFloorDelay", 0.75)
            local wt_1 = wv or 0.45
            task.wait(wt_1)
        else
            task.wait(0.25)
        end
    end
end
local function fn621(eq)
    if not eq then
        return
    end
    for i, descendant in ipairs(eq:GetDescendants()) do
        local s8 = descendant:IsA("ProximityPrompt") and descendant.ActionText == "Throw Away" and descendant.Enabled == true
        if s8 then
            nX(descendant)
        end
    end
end
local function fn640(gr, gs)
    local attr2 = o4:GetAttribute(string.format("%s_Floor%d", gr, gs))
    local attr = o4:GetAttribute(gr)
    local uF = tonumber(attr2) or tonumber(attr)
    local uB_1 = uF or 1
    return math.max(1, math.floor(uB_1))
end
local function fn653(ai, aj)
    if setclipboard then
        setclipboard(ai)
    elseif toclipboard then
        toclipboard(ai)
    end
    pc:Notify(aj)
end
local function fn665(cs)
    if not cs then
        return false
    end
    local rJ = oz(cs, "SellOresPrompt")
    local rK = oz(cs, "PickUpOresPrompt")
    local rL
    local rP = if pd(rJ) then 1 else 0
    if rP == 1 then
        rL = rJ
    elseif pd(rK) then
        rL = rK
    end
    if not rL then
        return false
    elseif not oE(rL) then
        return false
    else
        task.wait(0.05)
        if not pd(rL) then
            return false
        end
        return nX(rL)
    end
end
local function fn713(eM, eN, eO)
    local tD = 0
    local tE = eO - 1
    local tI = 0
    while tI <= tE do
        local tJ = tI
        tD = tD + om(eM, eN + tJ)
        tI += 1
    end
    return tD
end
local function fn726(bu, bv)
    local q5 = n3(bu)
    if not (bu and q5 and bv) then
        return false
    end
    local max = math.max
    local q7_1 = tonumber(bu.MaxActivationDistance) or 10
    local q8 = max(3, q7_1 * 0.5)
    local q6_2 = Vector3.new(q5.X - bv.Position.X, 0, q5.Z - bv.Position.Z)
    return q6_2.Magnitude <= q8
end
local function onCopyJoinScript_JobID()
    local h2 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, n2)
    o0(h2, "Copied join script to clipboard")
end
local function fn747(eI, eJ)
    local tB = tonumber(OreMetadata.GetUpgradePrice(eI, eJ)) or 0
    return math.max(0, math.floor(tB))
end
local function fn762(aY)
    return next(ow(aY)) ~= nil
end
local function onUnload()
    pc:Unload()
end
local function fn773(b1, b2)
    if not b1 then
        return nil
    end
    local rs = b1:FindFirstChild(b2, true)
    local rt = rs and rs:IsA("ProximityPrompt")
    if rt then
        return rs
    end
    return nil
end
local function fn775(cH)
    local rS = OreMetadata.GetOre(cH)
    return rS and rS.rarity or nil
end
local function worker8()
    while not pc.Unloaded do
        if nW("AutoBuyGears") then
            oD()
            task.wait(oI("BuyGearDelay", 1))
        else
            task.wait(0.25)
        end
    end
end
local function fn786(b6)
    if not b6 then
        return nil
    end
    local Roller = b6:FindFirstChild("Roller")
    local rw = Roller and Roller:FindFirstChild("Lever")
    local rv_1 = rw
    if rw then
        rw = rv_1:FindFirstChildWhichIsA("ProximityPrompt")
    end
    local rv_2 = rw
    local rA = if rv_2 then 1 else 0
    local ry = 3814 * rA + 108 * (1 - rA)
    local rz = 3737 * rA + 979 * (1 - rA)
    if not ((ry * 3463 + rz * 1659 + ry * rz) % 16777213 == 106057) then
        rv_2 = nil
    end
    return rv_2
end
local function fn791(aH, aI)
    local qr = oV[aH]
    if qr == nil then
        return aI
    end
    return qr.Value
end
local function fn794(cA)
    if not cA then
        return false
    end
    local rQ = oe(cA)
    if not pd(rQ) then
        return false
    elseif not oE(rQ) then
        return false
    else
        task.wait(0.05)
        if not pd(rQ) then
            return false
        end
        return nX(rQ)
    end
end
local function fn798(aM, aN)
    local qt = tonumber(o1(aM, aN)) or aN
    return qt
end
local function worker3()
    while not pc.Unloaded do
        local vZ = nW("AutoPickupSell")
        local v_ = nW("AutoTrashOres")
        local v0 = nW("AutoRoll")
        local v1 = not v_
        local v2 = not vZ
        if v2 ~= false then
            v2 = v1
        end
        if v2 and not v0 then
            task.wait(0.2)
        else
            local v1_2 = oJ()
            local v2_1 = false
            if v1_2 then
                if vZ then
                    if pi(oq, v1_2) then
                        v2_1 = true
                        local vZ_1 = oI("PickupSellDelay", 0)
                        if vZ_1 > 0 then
                            task.wait(vZ_1)
                        end
                    end
                end
                local vZ_2 = v_ and not pc.Unloaded and nW("AutoTrashOres")
                if vZ_2 then
                    if pi(oM, v1_2) then
                        v2_1 = true
                        local vZ_3 = oI("TrashDelay", 0.15)
                        if vZ_3 > 0 then
                            task.wait(vZ_3)
                        end
                    end
                end
                local vZ_4 = v0 and not pc.Unloaded and nW("AutoRoll")
                if vZ_4 then
                    if pi(nV, v1_2) then
                        v2_1 = true
                        local vZ_5 = oI("AutoRollDelay", 0.35)
                        if vZ_5 > 0 then
                            task.wait(vZ_5)
                        else
                            task.wait()
                        end
                    end
                end
            end
            if not v2_1 then
                task.wait(0.08)
            end
        end
    end
end
local function fn806()
    connection:Disconnect()
    connection2:Disconnect()
    if connection3 then
        connection3:Disconnect()
    end
end
local function fn809(aQ)
    local qv = o1(aQ, {})
    if typeof(qv) ~= "table" then
        return {}
    end
    local qw = {}
    for k, v in pairs(qv) do
        if v == true then
            qw[k] = true
        else
            local qv_1 = typeof(k) == "number" and typeof(v) == "string"
            if qv_1 then
                qw[v] = true
            end
        end
    end
    return qw
end
local function fn836(gk, gl)
    return math.floor(80 * 5 ^ (gl - 1) * 1.35 ^ (math.max(1, gk) - 1))
end
local function onInputBegan()
    pf = tick()
end
local function fn912(dp)
    local ss = not dp or dp:GetAttribute("ToolType") ~= "Ore"
    if ss then
        return false
    end
    local ss_1 = dp:GetAttribute("OreName") or dp:GetAttribute("OreType") or dp.Name
    local ss_2 = dp:GetAttribute("OreRarity") or oX(ss_1)
    local max = math.max
    local floor = math.floor
    local sw = (dp:GetAttribute("OreLevel"))
    local sB = if sw then 1 else 0
    local sz = 2557 * sB + 3405 * (1 - sB)
    local sA = 3619 * sB + 309 * (1 - sB)
    if not ((sz * 2545 + sA * 1815 + sz * sA) % 16777213 == 5552620) then
        sw = dp:GetAttribute("Level")
    end
    local sx = tonumber(sw) or 1
    local sw_1 = max(1, floor(sx))
    local ss_4 = oI("TrashMaxLevel", 1)
    if sw_1 > ss_4 then
        return false
    end
    local ss_5 = o1("TrashMaxRarity", "Common")
    local sv_1 = oN[ss_5]
    local sE = if sv_1 then 1 else 0
    local sC = 537 * sE + 3893 * (1 - sE)
    local sD = 2945 * sE + 3663 * (1 - sE)
    if not ((sC * 2952 + sD * 3574 + sC * sD) % 16777213 == 13692119) then
        sv_1 = 0
    end
    local ss_6 = ss_2
    local sw_2 = sv_1
    if ss_6 then
        ss_6 = oN[ss_2]
    end
    local sv_2 = ss_6 or oG(ss_1)
    if sv_2 > sw_2 then
        return false
    end
    local ss_8 = n0("TrashOres")
    local sv_3 = n0("TrashRarities")
    if ss_8 or sv_3 then
        local sw_4 = ss_8 and pj("TrashOres", ss_1)
        local ss_9 = sw_4 or false
        local st_1 = sv_3
        if st_1 then
            st_1 = ss_2 ~= nil
        end
        if st_1 then
            st_1 = pj("TrashRarities", ss_2)
        end
        if not (ss_9 or (st_1 or false)) then
            return false
        end
        return true
    end
    return true
end
local function fn923(cj, ck, cl)
    local rF = os.clock()
    local rH = rF + (cl or 2)
    while nT do
        local rF_1 = pc.Unloaded or os.clock() > rH
        if rF_1 then
            return false
        end
        task.wait(0.05)
    end
    return pi(cj, ck)
end
nT = nil
nV = nil
nW = nil
nX = nil
OreMetadata = nil
n_ = nil
n0 = nil
n2 = nil
n3 = nil
n5 = nil
n8 = nil
oe = nil
connection2 = nil
om = nil
oq = nil
ot = nil
ow = nil
ox = nil
oz = nil
connection = nil
oC = nil
oD = nil
oE = nil
oG = nil
local nR, nS, nU, nZ, n1, n4, n6, n7, n9, oa, ob, oc, BaseUpgradeDrillSpeed, of, og, oh, oi, ol, oo, op, ou, ov, BaseBuildPurchaseTunnel, oB, RollerUpgradePedestal, oH
oI = nil
oJ = nil
oK = nil
oM = nil
oN = nil
oO = nil
oP = nil
connection3 = nil
oR = nil
oS = nil
oT = nil
oU = nil
oV = nil
oX = nil
oZ = nil
o0 = nil
o1 = nil
o2 = nil
o4 = nil
o6 = nil
Workspace = nil
o9 = nil
pa = nil
pb = nil
pc = nil
pd = nil
pe = nil
pf = nil
pi = nil
pj = nil
local oL, oW, oY, o_, o3, o5, o8, pg, ph
oL = nil
oW = nil
oY = nil
o_ = nil
o3 = nil
o5 = nil
o8 = nil
pg = nil
ph = nil
local ScriptsGroup
wF_36, wF_15, UserInputService, pb, Workspace, o4, wF_17, oT, oO, wF_1, wF_3, oH, RollerUpgradePedestal, oB, BaseBuildPurchaseTunnel, ov, op, wF_24, ol, BaseUpgradeDrillSpeed, ob, oa, n5, nZ, OreMetadata, nS, ph, wF_27, pc, wF_31, wF_4, oZ, oV, wF_29, oN = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local wF_13 = 67
repeat
    wF_5 = (wF_13 * 5 + 9) % 16 + 1
    if wF_5 <= 8 then
        if wF_5 <= 4 then
            if wF_5 <= 2 then
                if wF_5 <= 1 then
                    wF_32 = { "ebqp", "qebd", "yjawlhlvqk", "atnwkqn", "hzhfxmyksl", "jhbzm", "nkcc", "wzvuvamfx", "ydqiqix" }
                    local x9 = wF_13
                    wF_19 = wF_32[x9 % 9 + 1]
                    if wF_19:len() >= wF_19:reverse():rep(x9 % 3 + 2):len() then
                        op = BaseBuildPurchaseTunnel:WaitForChild("BaseBuildPurchaseTunnel")
                        wF_24 = BaseBuildPurchaseTunnel:WaitForChild("BaseBuildPurchaseFloor")
                        wF_1 = BaseBuildPurchaseTunnel:WaitForChild("BaseBuildTunnelAction")
                        ov = BaseBuildPurchaseTunnel:WaitForChild("BaseCrateAction")
                    else
                        BaseBuildPurchaseTunnel = wF_1:WaitForChild("BaseBuildPurchaseTunnel")
                        ov = wF_1:WaitForChild("BaseBuildPurchaseFloor")
                        op = wF_1:WaitForChild("BaseBuildTunnelAction")
                        wF_24 = wF_1:WaitForChild("BaseCrateAction")
                    end
                    wF_13 = (wF_13 + 29) % 128
                else
                    wF_32 = {
                        "kqilpjelyx",
                        "modixgisoesw",
                        "uxpamyohgl",
                        "pfszffcjlxcc",
                        "odv",
                        "vcxfygdu",
                        "mrdnyacctvez",
                        "wvtkawjz",
                        "kcu",
                        "qpogsjc",
                        "wshvluo",
                        "dolar",
                        "akae",
                        "itvtdk"
                    }
                    if wF_32[(wF_13 * 16 + 86) % 14 + 1] < wF_32[(wF_13 * 16 + 86) % 14 + 1] then
                        oa = BaseUpgradeDrillSpeed:WaitForChild("BaseUpgradeDrillYield")
                        ol = BaseUpgradeDrillSpeed:WaitForChild("BaseUpgradeDrillSpeed")
                        wF_1 = BaseUpgradeDrillSpeed:WaitForChild("BaseUpgradeOreRegenSpeed")
                        ob = BaseUpgradeDrillSpeed:WaitForChild("RequestGearPurchase")
                    else
                        ol = wF_1:WaitForChild("BaseUpgradeDrillYield")
                        BaseUpgradeDrillSpeed = wF_1:WaitForChild("BaseUpgradeDrillSpeed")
                        ob = wF_1:WaitForChild("BaseUpgradeOreRegenSpeed")
                        oa = wF_1:WaitForChild("RequestGearPurchase")
                    end
                    wF_13 = (wF_13 + 125) % 128
                end
            elseif wF_5 <= 3 then
                local x0 = bit32.rrotate(bit32.bxor(bit32.lrotate(wF_13, 7), string.byte(tostring(wF_24))), 1)
                if bit32.bxor(bit32.lrotate(bit32.bxor(x0, 2425702701), 10), 1428469314) == bit32.lrotate(x0, 10) then
                    n5 = wF_1:WaitForChild("PlaytimeRewardsGetState")
                else
                    wF_1 = n5:WaitForChild("PlaytimeRewardsGetState")
                end
                wF_13 = (wF_13 + 61) % 128
            else
                local xU = bit32.rrotate(bit32.bxor(bit32.lrotate(wF_13, 28), string.byte(tostring(oH))), 4)
                if bit32.bxor(bit32.lrotate(bit32.bxor(xU, 1455305807), 6), 2945258453) ~= bit32.lrotate(xU, 6) then
                    wF_1 = wF_15:WaitForChild("PlaytimeRewardsClaim")
                    nZ = require(OreMetadata:WaitForChild("OreMetadata"))
                    ph = require(OreMetadata:WaitForChild("GearMetadata"))
                    nS = require(OreMetadata:WaitForChild("OreLuckConfig"))
                else
                    nZ = wF_1:WaitForChild("PlaytimeRewardsClaim")
                    OreMetadata = require(wF_15:WaitForChild("OreMetadata"))
                    nS = require(wF_15:WaitForChild("GearMetadata"))
                    ph = require(wF_15:WaitForChild("OreLuckConfig"))
                end
                wF_13 = (wF_13 + 125) % 128
            end
        elseif wF_5 <= 6 then
            if wF_5 <= 5 then
                local xs = bit32.rrotate(bit32.bxor(bit32.lrotate(wF_13, 8), string.byte(tostring(wF_24))), 5)
                if bit32.bxor(bit32.lrotate(bit32.bxor(xs, 1737029486), 10), 601733534) == bit32.lrotate(xs, 10) then
                    wF_27 = ""
                else
                    oO = ""
                end
                wF_13 = (wF_13 + 77) % 128
            else
                wF_32 = {
                    "xqaufusy",
                    "pmz",
                    "cblmkkifvoqr",
                    "tnokm",
                    "loyg",
                    "tvlhqim",
                    "twgxfzwsqiw",
                    "svfesesuqyn",
                    "vmkijzg",
                    "jgjrq"
                }
                if wF_32[(wF_13 * 22 + 75) % 10 + 1] <= wF_32[(wF_13 * 22 + 75) % 10 + 1] then
                    pc = getgenv().Library
                    wF_31 = getgenv().ThemeManager
                    wF_4 = getgenv().SaveManager
                    oZ = pc.Toggles
                    oV = pc.Options
                else
                    wF_4 = getgenv().Library
                    pc = getgenv().ThemeManager
                    oV = getgenv().SaveManager
                    wF_27 = wF_4.Toggles
                    oZ = wF_4.Options
                end
                wF_13 = (wF_13 + 125) % 128
            end
        elseif wF_5 <= 7 then
            wF_32 = (vector.create((wF_13 * 4 + 4) % 11 + 1, (wF_13 * 6 + 3) % 13 + 1, (wF_13 * 8 + 15) % 17 + 1))
            wF_19 = (vector.create((wF_13 * 3 + 3) % 11 + 1, (wF_13 * 10 + 5) % 13 + 1, (wF_13 * 1 + 7) % 17 + 1))
            wF_7 = (vector.create((wF_13 * 3 + 5) % 11 + 1, (wF_13 * 2 + 13) % 13 + 1, (wF_13 * 5 + 8) % 17 + 1))
            wF_33 = (vector.create((wF_13 * 2 + 6) % 11 + 1, (wF_13 * 7 + 8) % 13 + 1, (wF_13 * 13 + 12) % 17 + 1))
            if vector.dot(vector.cross(wF_32, wF_19), (vector.cross(wF_7, wF_33))) == vector.dot(wF_32, wF_7) * vector.dot(wF_19, wF_33) - vector.dot(wF_32, wF_33) * vector.dot(wF_19, wF_7) + 1 then
                wF_24 = { "Uncommon", "Epic", "Divine", "Common", "Rare", "Exotic", "Legendary", "Secret" }
            else
                wF_29 = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Secret", "Divine", "Exotic" }
            end
            wF_13 = (wF_13 + 77) % 128
        else
            wF_32 = {
                "toex",
                "oirudlfw",
                "mkpeomnz",
                "krfl",
                "grhdzx",
                "givzqu",
                "xubxphhpmpr",
                "rzfsxqudcwwc",
                "tbke",
                "jbtkphzqrld",
                "nbpl",
                "uwvwpccwo"
            }
            if wF_32[(wF_13 * 16 + 18) % 12 + 1] <= wF_32[(wF_13 * 16 + 18) % 12 + 1] then
                oN = {}
            else
                op = {}
            end
            wF_13 = (wF_13 + 109) % 128
        end
    elseif wF_5 <= 12 then
        if wF_5 <= 10 then
            if wF_5 <= 9 then
                if wF_13 * 75996613 + 5 + 6 >= wF_13 * 75996613 + 5 + 6 + 2 then
                    pb = game:GetService("Players")
                else
                    wF_36 = game:GetService("Players")
                end
                wF_13 = (wF_13 + 45) % 128
            else
                wF_32 = {
                    "ehoh",
                    "lfjvbwwof",
                    "pbfjeu",
                    "kmtspd",
                    "otvgkogyl",
                    "itso",
                    "shmjeski",
                    "knxlayphuenf",
                    "loqxvmecwp",
                    "uchgwmvkld",
                    "qtxsqnp",
                    "gefoz",
                    "ozoeoxvsqc",
                    "bhnwsc",
                    "knbedwckqvbm"
                }
                if wF_32[(wF_13 * 24 + 83) % 15 + 1] <= wF_32[(wF_13 * 24 + 83) % 15 + 1] then
                    wF_15 = game:GetService("ReplicatedStorage")
                else
                    n5 = game:GetService("ReplicatedStorage")
                end
                wF_13 = (wF_13 + 109) % 128
            end
        elseif wF_5 <= 11 then
            local ye = bit32.rrotate(bit32.bxor(bit32.lrotate(wF_13, 20), string.byte(tostring(oH))), 17)
            if bit32.bxor(bit32.lrotate(bit32.bxor(ye, 169689800), 14), 1353843335) ~= bit32.lrotate(ye, 14) then
                pb = game:GetService("UserInputService")
            else
                UserInputService = game:GetService("UserInputService")
            end
            wF_13 = (wF_13 + 77) % 128
        else
            if wF_13 * 4018833 + 5 + 5 <= wF_13 * 4018833 + 5 + 5 + 2 then
                pb = game:GetService("VirtualUser")
                Workspace = game:GetService("Workspace")
                o4 = wF_36.LocalPlayer
                wF_17 = "Sell Ores"
                oT = "https://discord.gg/K7Qxnxkk46"
            else
                wF_36 = game:GetService("VirtualUser")
                oT = game:GetService("Workspace")
                wF_17 = Workspace.LocalPlayer
                o4 = "Sell Ores"
                pb = "https://discord.gg/K7Qxnxkk46"
            end
            wF_13 = (wF_13 + 61) % 128
        end
    elseif wF_5 <= 14 then
        if wF_5 <= 13 then
            if wF_13 * 87788763 + 5 + 2 <= wF_13 * 87788763 + 5 + 2 + 6 then
                oO = "https://discord.gg/K7Qxnxkk46"
            else
                wF_3 = "https://discord.gg/K7Qxnxkk46"
            end
            wF_13 = (wF_13 + 77) % 128
        else
            wF_32 = (vector.create((wF_13 * 1 + 5) % 11 + 1, (wF_13 * 7 + 3) % 13 + 1, (wF_13 * 5 + 12) % 17 + 1))
            wF_19 = (vector.create((wF_13 * 1 + 4) % 11 + 1, (wF_13 * 11 + 4) % 13 + 1, (wF_13 * 5 + 7) % 17 + 1))
            local yc = vector.dot(wF_32, wF_19)
            if yc * yc >= vector.dot(wF_32, wF_32) * vector.dot(wF_19, wF_19) + 1 then
                wF_15 = wF_1:WaitForChild("Remotes")
            else
                wF_1 = wF_15:WaitForChild("Remotes")
            end
            wF_13 = (wF_13 + 93) % 128
        end
    elseif wF_5 <= 15 then
        wF_5 = (vector.create((wF_13 * 6 + 2) % 11 + 1, (wF_13 * 6 + 8) % 13 + 1, (wF_13 * 9 + 5) % 17 + 1))
        wF_32 = (vector.create((wF_13 * 7 + 6) % 11 + 1, (wF_13 * 3 + 6) % 13 + 1, (wF_13 * 8 + 11) % 17 + 1))
        wF_19 = (vector.create((wF_13 * 6 + 9) % 11 + 1, (wF_13 * 1 + 6) % 13 + 1, (wF_13 * 6 + 8) % 17 + 1))
        wF_7 = (vector.create((wF_13 * 2 + 3) % 5 + 1, (wF_13 * 1 + 3) % 7 + 1, (wF_13 * 4 + 4) % 9 + 1))
        if vector.dot(vector.cross(wF_5, (vector.cross(wF_32, wF_19))), wF_7) == vector.dot(wF_32 * vector.dot(wF_5, wF_19) - wF_19 * vector.dot(wF_5, wF_32), wF_7) + 3 then
            wF_15 = wF_3:WaitForChild("RollerRollEvent")
        else
            wF_3 = wF_15:WaitForChild("RollerRollEvent")
        end
        wF_13 = (wF_13 + 29) % 128
    else
        if (wF_13 * 2 + 5) * 10 % 3 == ((wF_13 * 2 + 5) * 10 + 1) % 3 then
            wF_15 = RollerUpgradePedestal:WaitForChild("RollerPurchaseEvent")
            oB = RollerUpgradePedestal:WaitForChild("RollerUpgradePedestal")
            oH = RollerUpgradePedestal:WaitForChild("RollerUpgradeOreLuck")
        else
            oH = wF_15:WaitForChild("RollerPurchaseEvent")
            RollerUpgradePedestal = wF_15:WaitForChild("RollerUpgradePedestal")
            oB = wF_15:WaitForChild("RollerUpgradeOreLuck")
        end
        wF_13 = (wF_13 + 125) % 128
    end
until (wF_13 * 75 + 24) % 128 == 121
for i, v in ipairs(wF_29) do
    wF_36 = OreMetadata.GetRarityRank(v) or 0
    oN[v] = wF_36
end
wF_36 = {}
wF_24 = {}
for i, v in ipairs(wF_29) do
    wF_36[v] = {}
    wF_13 = OreMetadata.GetOresByRarity(v)
    if type(wF_13) == "table" then
        for i, v2 in ipairs(wF_13) do
            wF_13 = type(v2) == "table" and type(v2.name) == "string" and v2.source == "Rolling"
            if wF_13 then
                table.insert(wF_24, v2.name)
                table.insert(wF_36[v], v2.name)
            end
        end
    end
end
table.sort(wF_24)
wF_13, wF_1, n6 = nil, nil, nil
wF_36 = 0
repeat
    local xW = bit32.rrotate(bit32.bxor(bit32.lrotate(wF_36, 4), string.byte(tostring(n6))), 11)
    if bit32.bxor(bit32.lrotate(bit32.bxor(xW, 1489419404), 4), 2355873989) ~= bit32.lrotate(xW, 4) then
        n6 = {}
        wF_13 = {}
        wF_1 = {}
    else
        wF_13 = {}
        wF_1 = {}
        n6 = {}
    end
    wF_36 = (wF_36 + 0) % 4
until (wF_36 * 3 + 2) % 4 == 2
wF_36 = nS.List()
if type(wF_36) == "table" then
    for i, v in ipairs(wF_36) do
        wF_36 = type(v) == "table" and type(v.Id) == "string"
        if wF_36 then
            wF_36 = v.DisplayName or v.Id
            wF_27 = wF_36
            table.insert(wF_13, v.Id)
            table.insert(wF_1, wF_27)
            n6[wF_27] = v.Id
        end
    end
end
o8, o5, n_, nT, og, o0, oK, oC, ot, nW, o1, oI, ow, n0, pj, o2, oR, oJ, oh, n3, pd, o3, oE, nX, oz, oe, pi, oW, oq, nV, oX, oG, of, oo, n1, oY, oM, pg, oP, nU, o_, om, n7, o9, oL, oc, o6, n4, ou, oi, n9, nR, oU, oD = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
o8 = { 2000, 15000, 100000, 1000000, 25000000 }
o5 = 7
o0 = fn653
oK = fn576
oC = fn126
ot = fn153
wF_7 = "#7fd47f"
wF_19 = "#6ec1ff"
n_ = "#e8a34d"
if (not n7 or not n7 or om and om) and (not n7 or not n7 or not n7 and not om) and (not om and not om or (om or n7) or om and not om and (not om and n7)) or (om and not n7 and (not n7 and not om) and (not n7 and n7 and (n7 or not om)) or (om and om and (not n7 and not n7) or om and not n7 and (not n7 or om))) or not ((not n7 or not n7 or om and om) and (not n7 or not n7 or not n7 and not om) and (not om and not om or (om or n7) or om and not om and (not om and n7)) or (om and not n7 and (not n7 and not om) and (not n7 and n7 and (n7 or not om)) or (om and om and (not n7 and not n7) or om and not n7 and (not n7 or om)))) then
    wF_32 = "#8b93a3"
    nW = fn512
else
    nW = "#8b93a3"
    wF_32 = fn512
end
o1 = fn791
oI = fn798
ow = fn809
n0 = fn762
pj = fn166
o2 = fn329
oR = fn591
oJ = fn594
oh = fn217
n3 = fn86
pd = fns.fn50
o3 = fn726
oE = function(bB)
    local ra
    local rb = oh()
    local rc = n3(bB)
    if not (rb and rc) then
        return false
    elseif o3(bB, rb) then
        return true
    else
        local rd_1 = Vector3.new(rc.X, rc.Y + 3, rc.Z)
        local rc_1 = Vector3.new(rd_1.X - rb.Position.X, 0, rd_1.Z - rb.Position.Z)
        ra = nil
        if rc_1.Magnitude > 0.05 then
            ra = CFrame.lookAt(rd_1, rd_1 + rc_1.Unit)
        else
            ra = CFrame.new(rd_1) * (rb.CFrame - rb.Position)
        end
        pcall(function()
            rb.AssemblyLinearVelocity = Vector3.zero
            rb.AssemblyAngularVelocity = Vector3.zero
            rb.CFrame = ra
        end)
        return true
    end
end
nX = function(bN)
    local rk
    if not pd(bN) then
        return false
    elseif not fireproximityprompt then
        return false
    else
        local rm = tonumber(bN.HoldDuration) or 0
        rk = rm
        local rm_1 = pcall(function()
            if rk > 0 then
                fireproximityprompt(bN, rk)
            else
                fireproximityprompt(bN)
            end
        end)
        if not rm_1 then
            pcall(fireproximityprompt, bN)
        end
        if rk > 0 then
            local rj = oh()
            local rn = rj and rj.CFrame
            local rr = if rn then 1 else 0
            local rp = 3824 * rr + 2291 * (1 - rr)
            local rq = 4082 * rr + 3579 * (1 - rr)
            if not ((rp * 449 + rq * 3471 + rp * rq) % 16777213 == 14717953) then
                rn = nil
            end
            local rl = rn
            local rm_3 = os.clock() + rk + 0.05
            while os.clock() < rm_3 do
                if rj and rl and rj.Parent then
                    pcall(function()
                        rj.AssemblyLinearVelocity = Vector3.zero
                        rj.AssemblyAngularVelocity = Vector3.zero
                        rj.CFrame = rl
                    end)
                end
                task.wait()
            end
        end
        return true
    end
end
oz = fn773
oe = fn786
nT = false
pi = fn198
oW = fn923
oq = fn665
nV = fn794
oX = fn775
oG = fn157
of = fn506
oo = fn446
n1 = function()
    local df
    df = {}
    local function dg(dh)
        if not dh then
            return
        end
        for i, child in ipairs(dh:GetChildren()) do
            local sk = child:IsA("Tool") and child:GetAttribute("ToolType") == "Ore"
            if sk then
                table.insert(df, child)
            end
        end
    end
    dg(o4:FindFirstChild("Backpack"))
    dg(o4.Character)
    return df
end
oY = fn912
oM = function(dQ)
    local sG
    local sF
    sF = nil
    sG = nil
    if not dQ then
        return false
    end
    local sH = oo(dQ)
    if not pd(sH) then
        return false
    end
    local sI = o4.Character and o4.Character:FindFirstChildOfClass("Humanoid")
    sF = sI
    if not sF then
        return false
    end
    sG = nil
    for i, v in ipairs(n1()) do
        if oY(v) then
            sG = v
            break
        end
    end
    if not sG then
        return false
    end
    pcall(function()
        sF:EquipTool(sG)
    end)
    task.wait(0.08)
    if not oE(sH) then
        return false
    end
    task.wait(0.05)
    return nX(sH)
end
pg = fn431
oP = function()
    local sY = pg()
    if not sY then
        return false
    end
    local sZ = tonumber(sY.elapsed) or 0
    local s_ = false
    for i, v in ipairs(sY.rewards) do
        local sX
        local sY_1 = pc.Unloaded or not nW("AutoClaimOnlineRewards")
        if sY_1 then
            break
        end
        local sY_2 = type(v) == "table" and v.claimed ~= true
        if sY_2 then
            local sY_3 = tonumber(v.unlockAt) or math.huge
            if sY_3 <= sZ then
                local sY_4 = tonumber(v.index) or i
                sX = sY_4
                pcall(function()
                    nZ:FireServer(sX)
                end)
                s_ = true
                task.wait(0.15)
            end
        end
    end
    return s_
end
nU = fn621
o_ = fn403
om = fn747
n7 = fn713
o9 = function(eT)
    local tP_3
    if not eT then
        return
    end
    local tM = o2()
    local tN = oI("UpgradeTunnelMaxPrice", 0)
    for i, v in ipairs(o_()) do
        local tY = v
        local tO = pc.Unloaded or not nW("AutoUpgradeTunnels")
        local tO_2
        if tO then
            break
        else
            local tL = "IncreaseLevel"
            local tO_1 = om(tY.ore, tY.level)
            if nW("AutoUpgradeTunnelsBulk") then
                local tP_1 = n7(tY.ore, tY.level, 10)
                if tP_1 > 0 and tM >= tP_1 and (tN <= 0 or tP_1 <= tN) then
                    tL = "IncreaseLevel10"
                    tO_1 = tP_1
                end
            end
            local tP_2 = tO_1 > 0 and tM >= tO_1
            if tP_2 then
                tP_2 = tN <= 0 or tO_1 <= tN
            end
            if tP_2 then
                tO_2, tP_3 = pcall(function()
                    return op:InvokeServer(eT.Name, tY.floor, tY.tunnel, tL)
                end)
                local tQ_3 = tO_2 and type(tP_3) == "table" and tP_3.success == true
                if tQ_3 then
                    tM = o2()
                    task.wait(0.05)
                end
            end
        end
    end
end
oL = fn567
og = {}
oc = function(fy)
    local ua_1
    local t9 = og[fy]
    local t9_1
    if t9 ~= nil then
        return t9
    end
    t9_1, ua_1 = pcall(function()
        return ov:InvokeServer("GetFloorPrice", fy)
    end)
    local ub = t9_1 and type(ua_1) == "table" and ua_1.success == true and type(ua_1.price) == "number"
    if ub then
        og[fy] = ua_1.price
        return ua_1.price
    end
    return nil
end
o6 = function(fI)
    local ud
    if not fI then
        return false
    end
    ud = oL(fI)
    if ud == nil then
        return false
    end
    local ue = oc(ud)
    local ue_1
    if type(ue) ~= "number" then
        return false
    end
    local uf = oI("UnlockFloorMaxPrice", 0)
    local uf_1
    if uf > 0 and ue > uf then
        return false
    end
    local uk = if o2() < ue then 1 else 0
    if uk == 1 then
        return false
    end
    ue_1, uf_1 = pcall(function()
        return ov:InvokeServer(fI.Name, ud)
    end)
    local ug_1 = ue_1 and type(uf_1) == "table" and uf_1.success == true
    if ug_1 then
        og[ud] = nil
        return true
    end
    return false
end
n4 = fn175
ou = fn571
oi = fn836
n9 = fn180
nR = fn640
oU = function(gy)
    local uJ_2, uJ_4, uJ_6
    local uI_2, uI_5, uI_7
    if not gy then
        return
    end
    local uH = o2()
    if nW("AutoUpgradeDrillYield") then
        for i = 1, o5 do
            local uQ = i
            local uI_1 = nR("DrillYieldLevel", uQ)
            local uJ_1 = ou(uI_1, uQ)
            if uH >= uJ_1 then
                uI_2, uJ_2 = pcall(function()
                    return ol:InvokeServer(gy.Name, uQ)
                end)
                local uK_1 = uI_2 and type(uJ_2) == "table" and uJ_2.success == true
                if uK_1 then
                    uH = o2()
                end
            end
        end
    end
    if nW("AutoUpgradeDrillSpeed") then
        for i = 1, o5 do
            local uX = i
            local uI_3 = math.clamp(nR("DrillSpeedLevel", uX), 1, 3)
            local uJ_3 = n9(uI_3, uX)
            if uJ_3 and uH >= uJ_3 then
                uI_5, uJ_4 = pcall(function()
                    return BaseUpgradeDrillSpeed:InvokeServer(gy.Name, uX)
                end)
                local uK_2 = uI_5 and type(uJ_4) == "table" and uJ_4.success == true
                if uK_2 then
                    uH = o2()
                end
            end
        end
    end
    if nW("AutoUpgradeOreRegen") then
        for i = 1, o5 do
            local uZ = i
            local uI_6 = nR("OreRegenSpeedLevel", uZ)
            local uJ_5 = oi(uI_6, uZ)
            if uH >= uJ_5 then
                uI_7, uJ_6 = pcall(function()
                    return ob:InvokeServer(gy.Name, uZ)
                end)
                local uK_3 = uI_7 and type(uJ_6) == "table" and uJ_6.success == true
                if uK_3 then
                    uH = o2()
                end
            end
        end
    end
    if nW("AutoUpgradePedestal") then
        local clamp = math.clamp
        local floor = math.floor
        local uK_4 = tonumber(o4:GetAttribute("NumberOfRollingPedestals")) or 1
        local uJ_8 = clamp(floor(uK_4), 1, 6)
        local uI_9 = o8[uJ_8]
        if uI_9 and uH >= uI_9 then
            pcall(function()
                RollerUpgradePedestal:InvokeServer(gy.Name)
            end)
            uH = o2()
        end
    end
    if nW("AutoUpgradeOreLuck") then
        local max = math.max
        local floor = math.floor
        local uK_5 = tonumber(o4:GetAttribute("RollingLuck")) or 1
        local uL = max(1, floor(uK_5))
        local uI_11 = ph.GetUpgradeCost(uL)
        local uJ_11 = type(uI_11) == "number" and uH >= uI_11
        if uJ_11 then
            pcall(function()
                oB:InvokeServer(gy.Name)
            end)
        end
    end
end
oD = function()
    local u0 = ow("AutoBuyGearList")
    local u0_4
    if not next(u0) then
        return
    end
    local u1 = o2()
    for k in pairs(u0) do
        local u_ = n6[k] or k
        local u0_2 = nS.Get(u_)
        local u2 = u0_2 and tonumber(u0_2.Price)
        local u2_2
        local u0_3 = u2 or nil
        local u2_1 = u0_3
        if u0_3 then
            u0_3 = u1 >= u2_1
        end
        if u0_3 then
            u0_4, u2_2 = pcall(function()
                return oa:InvokeServer(u_)
            end)
            local u3 = u0_4 and type(u2_2) == "table" and u2_2.success == true
            if u3 then
                u1 = o2()
            end
        end
    end
end
wF_15 = pc:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = oT, Copyable = true }, "|", wF_17 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
wF_33 = {
    Info = wF_15:AddTab("Info", "info"),
    Main = wF_15:AddTab("Main", "pickaxe"),
    Settings = wF_15:AddTab("Settings", "settings")
}
wF_33.Roll = wF_33.Main:AddSubTab("Roll", "dices")
wF_33.Farm = wF_33.Main:AddSubTab("Farm", "sprout")
wF_33.Shop = wF_33.Main:AddSubTab("Shop", "shopping-cart")
wF_5 = fns.fn52
for k, v in pairs(wF_33) do
    if v ~= wF_33.Main then
        wF_5(v)
    end
end
ox, wF_36, wF_15, n8, n2, wF_27 = nil, nil, nil, nil, nil, nil
wF_13 = 2
repeat
    wF_5 = (wF_13 * 2 + 0) % 3 + 1
    if wF_5 <= 2 then
        if wF_5 <= 1 then
            if wF_13 * 48556689 + 9 + 3 <= wF_13 * 48556689 + 9 + 3 + 3 then
                wF_27 = #n2 > 18
            else
                n2 = #wF_27 > 18
            end
            wF_13 = (wF_13 + 17) % 24
        else
            wF_5 = (vector.create((wF_13 * 2 + 9) % 11 + 1, (wF_13 * 3 + 3) % 13 + 1, (wF_13 * 13 + 4) % 17 + 1))
            wF_21 = (vector.create((wF_13 * 6 + 9) % 11 + 1, (wF_13 * 3 + 8) % 13 + 1, (wF_13 * 6 + 15) % 17 + 1))
            wF_9 = (vector.create((wF_13 * 7 + 9) % 11 + 1, (wF_13 * 11 + 5) % 13 + 1, (wF_13 * 3 + 16) % 17 + 1))
            wF_34 = (vector.create((wF_13 * 3 + 5) % 5 + 1, (wF_13 * 1 + 1) % 7 + 1, (wF_13 * 4 + 6) % 9 + 1))
            if vector.dot(vector.cross(wF_5, (vector.cross(wF_21, wF_9))), wF_34) == vector.dot(wF_21 * vector.dot(wF_5, wF_9) - wF_9 * vector.dot(wF_5, wF_21), wF_34) + 3 then
                n8 = "Unknown"
                pcall(fn409)
                wF_33 = wF_15.Info:AddLeftGroupbox("Account", "circle-user")
                wF_33:AddLabel(wF_7("User", oC.Name, o4), true)
                wF_33:AddLabel(wF_7("Status", "Keyless", o4), true)
                wF_33:AddLabel(wF_7("Executor", n8, o4), true)
                wF_17 = wF_15.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                wF_17:AddLabel(wF_19(wF_36 .. " [" .. tostring(game.PlaceId) .. "]", n_), true)
                wF_17:AddLabel(wF_7("Place ID", tostring(game.PlaceId), n_), true)
                ot = wF_17:AddLabel(wF_7("Session time", "0s", ox), true)
            else
                ox = "Unknown"
                pcall(fn409)
                wF_36 = wF_33.Info:AddLeftGroupbox("Account", "circle-user")
                wF_36:AddLabel(ot("User", o4.Name, wF_7), true)
                wF_36:AddLabel(ot("Status", "Keyless", wF_7), true)
                wF_36:AddLabel(ot("Executor", ox, wF_7), true)
                wF_15 = wF_33.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                wF_15:AddLabel(oC(wF_17 .. " [" .. tostring(game.PlaceId) .. "]", wF_19), true)
                wF_15:AddLabel(ot("Place ID", tostring(game.PlaceId), wF_19), true)
                n8 = wF_15:AddLabel(ot("Session time", "0s", n_), true)
            end
            wF_13 = (wF_13 + 11) % 24
        end
    else
        wF_5 = {
            "rclbyhsvotqh",
            "lzgkfldod",
            "fblgplafl",
            "vqtitvhpkbw",
            "iquvrlo",
            "tyxmwwkiittr",
            "jmbs",
            "mumhhtwwyb",
            "xlqy",
            "khigfvod",
            "gcm",
            "bityg",
            "iyqjpbrmvl"
        }
        if wF_5[(wF_13 * 32 + 1) % 13 + 1] <= wF_5[(wF_13 * 32 + 1) % 13 + 1] then
            n2 = tostring(game.JobId)
        else
            wF_36 = tostring(game.JobId)
        end
        wF_13 = (wF_13 + 8) % 24
    end
until (wF_13 * 11 + 16) % 24 == 2
if wF_27 then
    wF_36 = 3
    repeat
        wF_13 = (vector.create((wF_36 * 1 + 3) % 11 + 1, (wF_36 * 11 + 5) % 13 + 1, (wF_36 * 10 + 1) % 17 + 1))
        wF_5 = (vector.create((wF_36 * 3 + 9) % 11 + 1, (wF_36 * 3 + 12) % 13 + 1, (wF_36 * 11 + 11) % 17 + 1))
        local xz = vector.cross(wF_13, wF_5)
        local xA = vector.dot(wF_13, wF_5)
        if vector.dot(xz, xz) + xA * xA == vector.dot(wF_13, wF_13) * vector.dot(wF_5, wF_5) then
            wF_27 = string.sub(n2, 1, 18) .. "..."
        else
            n2 = string.sub(wF_27, 1, 18) .. "..."
        end
        wF_36 = (wF_36 + 3) % 4
    until (wF_36 * 1 + 0) % 4 == 2
end
wF_36 = wF_27 or n2
pa, ScriptsGroup, pf, pe, connection, connection2, connection3, oS = nil, nil, nil, nil, nil, nil, nil, nil
wF_13 = wF_36
wF_15:AddLabel(ot("Server", wF_13, wF_32), true)
wF_15:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
pa = os.clock()
if pa and connection or (not pf or not pf) or (connection or not pa) and (connection and not connection) or not (pa and connection or (not pf or not pf) or (connection or not pa) and (connection and not connection)) then
    task.spawn(worker)
    ScriptsGroup = wF_33.Info:AddRightGroupbox("Scripts", "package")
else
    task.spawn(worker)
    wF_33 = ScriptsGroup.Info:AddRightGroupbox("Scripts", "package")
end
ScriptsGroup:AddLabel(oC("Included in this hub", wF_32), true)
ScriptsGroup:AddLabel(oC(wF_17, wF_19), true)
local FeaturesGroup = wF_33.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(oC("Auto Roll / Buy Roll", wF_19), true)
FeaturesGroup:AddLabel(oC("Auto Pickup & Sell", n_), true)
FeaturesGroup:AddLabel(oC("Auto Trash Ores", n_), true)
FeaturesGroup:AddLabel(oC("Auto Buy / Upgrade Tunnels", wF_7), true)
FeaturesGroup:AddLabel(oC("Auto Unlock Floors", wF_7), true)
FeaturesGroup:AddLabel(oC("Auto Claim Online Rewards", wF_19), true)
FeaturesGroup:AddLabel(oC("Auto Buy Upgrades / Gears", wF_32), true)
FeaturesGroup:AddLabel(oC("Auto Equip Best", wF_32), true)
local SocialsGroup = wF_33.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = oK })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = wF_33.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = oK })
local FaqGroup = wF_33.Info:AddRightGroupbox("FAQ", "circle-help")
FaqGroup:AddLabel("Where do I get a good config?", true)
FaqGroup:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
FaqGroup:AddLabel("How do I import / export configs?", true)
FaqGroup:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
FaqGroup:AddLabel("How do I report bugs?", true)
FaqGroup:AddLabel("Join the Discord and post it in the bugs channel.", true)
FaqGroup:AddLabel("How do I make suggestions?", true)
FaqGroup:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
FaqGroup:AddLabel("How do I get help or updates?", true)
FaqGroup:AddLabel("Join the Discord, updates and support are posted there first.", true)
local AutoRollGroup = wF_33.Roll:AddLeftGroupbox("Auto Roll", "dices")
AutoRollGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
AutoRollGroup:AddSlider("AutoRollDelay", { Text = "Roll Delay", Default = 0.35, Min = 0, Max = 5, Rounding = 2, Suffix = "s" })
local AutoBuyRollGroup = wF_33.Roll:AddRightGroupbox("Auto Buy Roll", "coins")
AutoBuyRollGroup:AddToggle("AutoBuyRoll", { Text = "Auto Buy Roll", Default = false })
AutoBuyRollGroup:AddToggle("AutoDiscardRoll", { Text = "Auto Discard Others", Default = false })
AutoBuyRollGroup:AddDropdown("BuyRollMinRarity", { Text = "Min Rarity", Values = wF_29, Default = 1 })
AutoBuyRollGroup:AddDropdown("BuyRollRarities", { Text = "Buy Rarities", Values = wF_29, Multi = true, Default = {} })
AutoBuyRollGroup:AddDropdown("BuyRollOres", { Text = "Buy Ores", Values = wF_24, Multi = true, Default = {}, Searchable = true })
AutoBuyRollGroup:AddSlider("BuyRollMaxSeedCost", { Text = "Max Seed Cost", Default = 0, Min = 0, Max = 10000000000, Rounding = 0, Compact = true })
AutoBuyRollGroup:AddSlider("BuyRollDelay", { Text = "Buy Delay", Default = 0.35, Min = 0, Max = 3, Rounding = 2, Suffix = "s" })
local OresGroup = wF_33.Farm:AddLeftGroupbox("Ores", "gem")
OresGroup:AddToggle("AutoPickupSell", { Text = "Auto Pickup Ores & Sell", Default = false })
OresGroup:AddSlider("PickupSellDelay", { Text = "Pickup / Sell Delay", Default = 0, Min = 0, Max = 20, Rounding = 2, Suffix = "s" })
OresGroup:AddToggle("AutoTrashOres", { Text = "Auto Trash Ores", Default = false })
OresGroup:AddDropdown("TrashMaxRarity", { Text = "Trash Max Rarity", Values = wF_29, Default = 1 })
OresGroup:AddDropdown("TrashRarities", { Text = "Trash Rarities", Values = wF_29, Multi = true, Default = {} })
OresGroup:AddDropdown("TrashOres", { Text = "Trash Ores", Values = wF_24, Multi = true, Default = {}, Searchable = true })
OresGroup:AddSlider("TrashMaxLevel", { Text = "Trash Max Level", Default = 1, Min = 1, Max = 100, Rounding = 0 })
OresGroup:AddSlider("TrashDelay", { Text = "Trash Delay", Default = 0.15, Min = 0, Max = 5, Rounding = 2, Suffix = "s" })
OresGroup:AddToggle("AutoClaimOnlineRewards", { Text = "Auto Claim Online Rewards", Default = false })
OresGroup:AddSlider("ClaimOnlineDelay", { Text = "Claim Delay", Default = 2, Min = 0.5, Max = 30, Rounding = 1, Suffix = "s" })
OresGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
OresGroup:AddSlider("EquipBestDelay", { Text = "Equip Best Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 1, Suffix = "s" })
wF_34 = wF_33.Farm:AddRightGroupbox("Tunnels", "hammer")
wF_34:AddToggle("AutoBuyTunnels", { Text = "Auto Buy Tunnels", Default = false })
wF_34:AddToggle("AutoUnlockFloors", { Text = "Auto Unlock Floors", Default = false })
wF_34:AddToggle("AutoUpgradeTunnels", { Text = "Auto Upgrade Tunnels", Default = false })
wF_34:AddToggle("AutoUpgradeTunnelsBulk", { Text = "Prefer +10 Upgrade", Default = false })
wF_34:AddSlider("BuyTunnelDelay", { Text = "Buy Tunnel Delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
wF_34:AddSlider("UnlockFloorDelay", { Text = "Unlock Floor Delay", Default = 0.75, Min = 0.2, Max = 5, Rounding = 2, Suffix = "s" })
wF_34:AddSlider("UpgradeTunnelDelay", { Text = "Upgrade Tunnel Delay", Default = 0.45, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
wF_34:AddSlider("BuyTunnelMaxPrice", { Text = "Max Tunnel Price", Default = 0, Min = 0, Max = 10000000000, Rounding = 0, Compact = true })
wF_34:AddSlider("UnlockFloorMaxPrice", { Text = "Max Floor Price", Default = 0, Min = 0, Max = 10000000000, Rounding = 0, Compact = true })
wF_34:AddSlider("UpgradeTunnelMaxPrice", {
    Text = "Max Upgrade Price",
    Default = 0,
    Min = 0,
    Max = 10000000000,
    Rounding = 0,
    Compact = true
})
wF_9 = wF_33.Shop:AddLeftGroupbox("Upgrades", "trending-up")
wF_9:AddToggle("AutoUpgradeDrillYield", { Text = "Auto Buy Drill Yield", Default = false })
wF_9:AddToggle("AutoUpgradeDrillSpeed", { Text = "Auto Buy Drill Speed", Default = false })
wF_9:AddToggle("AutoUpgradeOreRegen", { Text = "Auto Buy Ore Regen", Default = false })
wF_9:AddToggle("AutoUpgradePedestal", { Text = "Auto Buy Rolling Pedestal", Default = false })
wF_9:AddToggle("AutoUpgradeOreLuck", { Text = "Auto Buy Ore Luck", Default = false })
wF_9:AddSlider("UpgradeDelay", { Text = "Upgrade Delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2, Suffix = "s" })
wF_21 = wF_33.Shop:AddRightGroupbox("Gears", "wrench")
wF_21:AddToggle("AutoBuyGears", { Text = "Auto Buy Gears", Default = false })
wF_21:AddDropdown("AutoBuyGearList", { Text = "Gears", Values = wF_1, Multi = true, Default = {} })
wF_21:AddSlider("BuyGearDelay", { Text = "Buy Gear Delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2, Suffix = "s" })
wF_27 = wF_33.Settings:AddLeftGroupbox("Menu", "menu")
wF_27:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
pc.ToggleKeybind = oV.MenuKeybind
wF_27:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
wF_27:AddButton({ Text = "Unload", Func = onUnload })
wF_31:SetLibrary(pc)
wF_31:SetFolder("TempoHub")
wF_31:SaveDefault("Monochrome")
wF_31:ApplyToTab(wF_33.Settings)
wF_31:LoadDefault()
wF_4:SetLibrary(pc)
wF_4:IgnoreThemeSettings()
wF_4:SetIgnoreIndexes({ "MenuKeybind" })
wF_4:SetFolder("TempoHub/sell-ores")
wF_4:BuildConfigSection(wF_33.Settings)
wF_4:LoadAutoloadConfig()
pf = tick()
pe = tick()
pcall(function()
    for i, v in ipairs(getconnections(o4.Idled)) do
        local vq = v
        pcall(function()
            vq:Disable()
        end)
    end
end)
oS = fn404
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
connection3 = wF_3.OnClientEvent:Connect(function(iL)
    if pc.Unloaded then
        return
    end
    if not nW("AutoBuyRoll") then
        return
    end
    local vC = type(iL) ~= "table" or iL.rollUnlocked == true
    if vC then
        return
    end
    local vC_1 = oR()
    local vD = type(iL.baseName) ~= "string" or iL.baseName ~= vC_1
    if vD then
        return
    end
    local results = iL.results
    if type(results) ~= "table" then
        return
    end
    local vD_1 = oI("BuyRollDelay", 0.35)
    for i, v in ipairs(results) do
        if type(v) == "table" then
            local oreName = v.oreName
            local pedestalName = v.pedestalName
            local vC_3 = type(oreName) == "string" and type(pedestalName) == "string"
            if vC_3 then
                if of(oreName) then
                    task.delay(vD_1, function()
                        local vy = pc.Unloaded or not nW("AutoBuyRoll")
                        if vy then
                            return
                        end
                        if of(oreName) then
                            pcall(function()
                                oH:FireServer(pedestalName, oreName)
                            end)
                        elseif nW("AutoDiscardRoll") then
                            oW(nU, oJ())
                        end
                    end)
                elseif nW("AutoDiscardRoll") then
                    task.delay(math.max(vD_1, 0.2), function()
                        local vw = pc.Unloaded or not nW("AutoBuyRoll")
                        if vw then
                            return
                        end
                        oW(nU, oJ())
                    end)
                end
            end
        end
    end
end)
pc:OnUnload(fn806)
task.spawn(fns.worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(function()
    local wd = false
    repeat
        if not pc.Unloaded then
            if nW("AutoEquipBest") then
                local v9 = oR()
                local wa = v9 and o4:GetAttribute("TutorialComplete") == true
                if wa then
                    pcall(function()
                        op:InvokeServer(v9, 1, "Tunnel1", "EquipBest")
                    end)
                end
                task.wait(oI("EquipBestDelay", 2))
            else
                task.wait(0.25)
            end
        else
            wd = true
        end
    until wd
end)
task.spawn(function()
    local wm = false
    repeat
        if not pc.Unloaded then
            if nW("AutoBuyTunnels") then
                local we = oJ()
                if we then
                    local wf = oI("BuyTunnelMaxPrice", 0)
                    local wg = o2()
                    for i, v in ipairs(n4(we)) do
                        local ws = v
                        local wh = pc.Unloaded or not nW("AutoBuyTunnels")
                        local wh_2
                        if wh then
                            break
                        else
                            local wi = (wf <= 0 or ws.price <= wf) and wg >= ws.price
                            local wi_1
                            if wi then
                                wh_2, wi_1 = pcall(function()
                                    return BaseBuildPurchaseTunnel:InvokeServer(we.Name, ws.floor, ws.tunnel)
                                end)
                                local wj = wh_2 and type(wi_1) == "table" and wi_1.success == true
                                if wj then
                                    wg = o2()
                                    task.wait(oI("BuyTunnelDelay", 0.5))
                                end
                            end
                        end
                    end
                end
                task.wait(oI("BuyTunnelDelay", 0.5))
            else
                task.wait(0.25)
            end
        else
            wm = true
        end
    until wm
end)
task.spawn(worker5)
task.spawn(fns.worker6)
task.spawn(worker7)
task.spawn(worker8)

end)(...)
