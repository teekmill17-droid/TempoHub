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
--  Tempo Hub - Bee ReMasters (free)
--  Generated by port_backlog.py from the dev's source. Edit the
--  source + porter, not this file.
-- ============================================================
getgenv().TempoHoodSubtitle = "BEE REMASTERS"
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
local TP_3, TP_5, TP_6, TP_7, TP_9, TP_11, TP_12, ReplicatedStorage, Saving, UserInputService, Window, TP_24, TP_25, TP_26, TP_27, TP_38, TP_49, TP_57, TP_60, TP_63, TP_71, TP_74
TP_3 = nil
TP_5 = nil
TP_6 = nil
TP_9 = nil
TP_11 = nil
TP_12 = nil
ReplicatedStorage = nil
Saving = nil
UserInputService = nil
Window = nil
TP_24 = nil
TP_25 = nil
TP_26 = nil
local CO
local Cv
local AO
local Cc
local CB
local Variables
local connection
local Bi
local onPlayerAdded
local Label
local AH
local Directory
local B5
local CN
local BN
local A5
local Bu
local Cb
local BT
local AT
local onOpenPouchesNow
local BA
local AA
local connection6
local CG
local Worlds
local AZ
local Cn
local AG
local Bn
local CM
local onFly
local connection2
local Bt
local connection4
local Library
local BS
local Lighting
local AS
local Bz
local Cg
local Az
local BY
local CF
local BF
local Cm
local Bm
local connection5
local CL
local A3
local BL
local Toggles
local Bs
local Label2
local BR
local AR
local AbuseManager
local Ay
local Bf
local BX
local AX
local AE
local Bl
local A2
local BK
local connection3
local AK
local B8
local A8
local Network
local onCraftNeonNow
local Cx
local Ce
local Bx
local Be
local VirtualUser
local AW
local Ck
local Options
local BearQuests
local CJ
local BJ
local Cq
local AJ
local A1
local LocalPlayer
local A7
local Bq
local RunService
local CP
local Bw
function fns.fn3()
    local P0 = BX()
    local P1 = P0 and P0:FindFirstChild("Targets")
    local P0_1 = P1
    if P1 then
        P1 = P0_1:FindFirstChild("Positions")
    end
    return P1
end
function fns.fn16(nK)
    if nK then
        if not connection then
            AE()
            connection2 = LocalPlayer.CharacterAdded:Connect(function()
                task.wait(0.2)
                AE()
            end)
            connection = RunService.Stepped:Connect(function()
                for i, v in ipairs(AT) do
                    if v.Parent and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end)
        end
    else
        if connection then
            connection:Disconnect()
            connection = nil
        end
        if connection2 then
            connection2:Disconnect()
            connection2 = nil
        end
    end
end
function fns.fn30(bT)
    local E9_1
    local E7_4
    local E4 = Cc()
    local E5 = bT and Directory.Hives[bT]
    if not (E4 and E5) then
        return 1
    end
    AO()
    local E5_2 = 0
    for k, v in pairs(E4.ActiveBoosts) do
        local E7_1 = (tostring(k):find("ExtraHatch"))
        if E7_1 then
            E7_1 = (v.power or 0) > E5_2
        end
        if E7_1 then
            E5_2 = v.power
        end
    end
    local E7_2 = E4.EventUpgrades and E4.EventUpgrades.Summer2026
    local E8_2 = E7_2
    if E7_2 then
        E7_2 = E8_2["More Hive Slots"]
    end
    if E7_2 then
        E5_2 += E8_2["More Hive Slots"]
    end
    E5_2 += AZ.hatch * 2
    local E8_3 = E4.HiveSlots or 1
    E7_4, E9_1 = pcall(AbuseManager.GetEffectiveStat, E8_3, "HiveSlots")
    local Fa = E7_4 and tonumber(E9_1)
    if Fa then
        E8_3 = tonumber(E9_1)
    end
    local E7_5 = E4[E5.CurrencyType] or 0
    return math.max(math.floor(math.min(E8_3 + E5_2, E7_5 / AK(E4, E5))), 1)
end
function fns.fn31()
    if setclipboard then
        setclipboard(Az)
    elseif toclipboard then
        toclipboard(Az)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
function fns.fn125(lp, lq)
    local MI = lp:lower()
    local MJ = lq or ""
    for k in tostring(MJ):gmatch("[^,%s]+") do
        if k:lower():gsub("^@", "") == MI then
            return true
        end
    end
    return false
end
function fns.fn127()
    if not Variables.Trading or Cq.offerBuilt then
        return
    end
    local NK_1 = BA()
    local NL = Options.TradeItemDelay.Value or 0.2
    local NM = 0
    for i, v in ipairs(NK_1) do
        if Library.Unloaded or not Variables.Trading then
            return
        end
        Network.Send("Bulk Trade Item", v.uid, v.isBee, v.amount, false)
        NM += 1
        task.wait(NL)
    end
    local NK_3 = Options.TradeHoneyAmount.Value or "0"
    local NL_1 = tostring(NK_3)
    local NK_4 = tonumber(NL_1) and tonumber(NL_1) > 0
    if NK_4 then
        Network.Send("Modify Honey", NL_1)
    end
    Cq.offerBuilt = true
    Cq.offerBuiltAt = os.clock()
    Cq.itemsOffered = Cq.itemsOffered + NM
    if Toggles.TradeNotify.Value then
        Library:Notify(("Trade offer ready with %d item stacks"):format(NM))
    end
end
function fns.fn137()
    if not Toggles.TradeRequireOtherOffer.Value then
        return true
    end
    local N5 = #Cq.otherItems
    local N6 = 0
    for i, v in ipairs(Cq.otherItems) do
        local N7_1 = tonumber(v.amount) or 1
        N6 += N7_1
    end
    local N8 = N5 >= (Options.TradeMinimumOtherStacks.Value or 1)
    if N8 then
        N8 = N6 >= (Options.TradeMinimumOtherAmount.Value or 1)
    end
    if N8 then
        local otherHoney = Cq.otherHoney
        local N6_1 = tonumber(Options.TradeMinimumOtherHoney.Value) or 0
        N8 = otherHoney >= N6_1
    end
    return N8
end
function fns.fn139()
    local PE = BX()
    local PF = PE and PE:FindFirstChild("Cannons")
    local PE_1 = {}
    if PF then
        for i, child in ipairs(PF:GetChildren()) do
            local PF_1 = child:IsA("Model") and child:HasTag("CannonSummer2026") and child:FindFirstChild("CameraPos")
            if PF_1 then
                PE_1[#PE_1 + 1] = child
            end
        end
    end
    return PE_1
end
function fns.fn157()
    if TP_12.uid and TP_12.cannon and TP_12.cannon.Parent then
        return true
    end
    local QK_1 = Cb()
    if not QK_1 then
        return false
    end
    local CameraPos = QK_1:FindFirstChild("CameraPos")
    local QM = CM()
    if CameraPos and QM then
        QM.CFrame = CFrame.new(CameraPos.WorldCFrame.Position)
    end
    TP_12.cannon = QK_1
    TP_12.uid = QK_1:GetFullName()
    TP_12.basePivot = QK_1:GetPivot()
    TP_12.enteredAt = os.clock()
    TP_12.lastTargetAt = os.clock()
    Network.Send("Cannon Entered", TP_12.uid)
    local QK_2 = B8()
    if QK_2 then
        pcall(QK_2.gui.Start, A1, TP_12.uid)
        pcall(QK_2.spawner.StartSpawning)
    end
    return true
end
function fns.fn186()
    local Gy_2
    if Variables.LoadingWorld then
        return nil, nil
    end
    local Gu = Worlds.GetCurrentWorld()
    local map = workspace:FindFirstChild("map")
    local Gw = Gu and map
    local Gw_2
    if not Gw then
        return nil, nil
    end
    local FarmingAreas = map:FindFirstChild("FarmingAreas")
    local Teleports = map:FindFirstChild("Teleports")
    local Gx_2
    local Gv_1 = {}
    for i, v in ipairs({ FarmingAreas, Teleports }) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                if child:IsA("BasePart") then
                    local Name = child.Name
                    local Gz_1 = Gv_1[child.Name] or {}
                    Gv_1[Name] = Gz_1
                    if v == FarmingAreas then
                        Gv_1[child.Name].farming = child
                    else
                        Gv_1[child.Name].teleport = child
                    end
                end
            end
        end
    end
    Gx_2, Gy_2, Gw_2 = nil, nil, -math.huge
    for k, v in pairs(Gv_1) do
        local Gv_2 = Directory.Areas[k]
        local Gz_2 = Gv_2 and Gv_2.world == Gu and not Gv_2.isShop and CN(k) and (Gv_2.id or 0) > Gw_2
        if Gz_2 then
            Gx_2 = k
            Gy_2 = v.farming or v.teleport
            Gw_2 = Gv_2.id or 0
        end
    end
    if not (Gx_2 and Gy_2) then
        return nil, nil
    end
    return Gy_2.Position, Gx_2, Gu
end
function fns.fn201()
    local Ou = AS()
    if Ou then
        Ou.WalkSpeed = Options.WalkSpeed.Value
    end
end
function fns.fn276()
    local Hq_1
    if Bz then
        return Bz
    end
    local PlayerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    local Hp = PlayerScripts and PlayerScripts:FindFirstChild("Scripts")
    local Hp_1
    local Ho_1 = Hp
    if Hp then
        Hp = Ho_1:FindFirstChild("Core")
    end
    local Ho_2 = Hp
    if Hp then
        Hp = Ho_2:FindFirstChild("Bees")
    end
    local Ho_3 = Hp
    if Hp then
        Hp = Ho_3:FindFirstChild("BeeController")
    end
    local Ho_4 = Hp
    if Hp then
        Hp = Ho_4:FindFirstChild("BeeManager")
    end
    local Ho_5 = Hp
    if Ho_5 then
        Hp_1, Hq_1 = pcall(require, Ho_5)
        if Hp_1 then
            Bz = Hq_1
        end
    end
    return Bz
end
function fns.fn278()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
function fns.fn289()
    local Character = LocalPlayer.Character
    local Os = Character and Character:FindFirstChild("HumanoidRootPart")
    return Os
end
function fns.fn382()
    local Qm = B8()
    if Qm then
        pcall(Qm.gui.Stop)
        pcall(Qm.spawner.StopSpawning)
    end
    if TP_12.uid then
        Network.Send("Cannon Exited", TP_12.uid)
    end
    TP_12.uid = nil
    TP_12.cannon = nil
    TP_12.basePivot = nil
    table.clear(TP_12.targets)
end
function fns.fn402(aF, aG)
    if aF == "Auto (Best)" then
        return true
    elseif aG == "Auto (Best)" then
        return false
    else
        return aF < aG
    end
end
function fns.fn483()
    local Ea_1
    local D9_1
    D9_1, Ea_1 = pcall(Saving.Get)
    if D9_1 then
        return Ea_1
    end
    return nil
end
function fns.fn497(pC, pD)
    local P6 = Bt(pC):PointToObjectSpace(pD)
    if P6.Magnitude < 0.0001 then
        return nil
    end
    local Unit = P6.Unit
    local P6_1 = math.asin(math.clamp(Unit.Y, -1, 1))
    local P8 = math.atan2(-Unit.X, -Unit.Z)
    local P7_1 = P8 < -1.0471975511965976
    local Qc = if P7_1 then 1 else 0
    local Qa = 153 * Qc + 3786 * (1 - Qc)
    local Qb = 1366 * Qc + 425 * (1 - Qc)
    if not ((Qa * 1078 + Qb * 937 + Qa * Qb) % 16777213 == 1653874) then
        P7_1 = P8 > TP_24
    end
    local Qc_1 = if P7_1 then 1 else 0
    local Qa_1 = 1669 * Qc_1 + 2086 * (1 - Qc_1)
    local Qb_1 = 846 * Qc_1 + 861 * (1 - Qc_1)
    if not ((Qa_1 * 17 + Qb_1 * 3054 + Qa_1 * Qb_1) % 16777213 == 4024031) then
        P7_1 = P6_1 < Cn
    end
    if not P7_1 then
        P7_1 = P6_1 > Ce
    end
    if P7_1 then
        return nil
    end
    return P8, P6_1
end
function fns.fn570(py)
    local Position = py.Position
    local P4 = Vector3.new(py.LookVector.X, 0, py.LookVector.Z)
    if P4.Magnitude < 0.0001 then
        P4 = Vector3.new(py.RightVector.X, 0, py.RightVector.Z)
    end
    return CFrame.lookAt(Position, Position + P4.Unit)
end
function fns.fn575()
    local Character = LocalPlayer.Character
    local Op = Character and Character:FindFirstChildOfClass("Humanoid")
    return Op
end
function fns.fn595()
    local PQ_1
    local PP_1
    local PO = CM()
    PQ_1, PP_1 = nil, nil
    for i, v in ipairs(Bw()) do
        local PR = PO and (v:GetPivot().Position - PO.Position).Magnitude
        local PS = PR or 0
        if not PQ_1 or PS < PP_1 then
            PQ_1, PP_1 = v, PS
        end
    end
    return PQ_1
end
function fns.fn605(rg)
    local DiscordGroup = rg:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = CJ })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = CJ })
end
function fns.fn625()
    local holder = workspace:FindFirstChild("holder")
    local Pz = holder and holder:FindFirstChild("things")
    local Py_1 = Pz
    if Pz then
        Pz = Py_1:FindFirstChild("Summer2026")
    end
    return Pz
end
function fns.fn627(hO)
    local J_ = Cc()
    if not J_ or not J_.Bees then
        return {}
    end
    local Value2 = Options.NeonBeeList.Value
    local Value = Options.NeonRarityList.Value
    local J2 = next(BN(Value2)) == nil
    local J3 = next(BN(Value)) == nil
    local floor = math.floor
    local J5 = tonumber(Options.NeonKeep.Value) or 0
    local J6 = floor(J5)
    local J5_1 = tonumber(Options.NeonMaxPerBee.Value) or 0
    local J7 = floor(J5_1)
    local J4_1 = {}
    for k, v in pairs(J_.Bees) do
        local J__1 = Directory.Items[v.id]
        if J__1 and J__1.Type == "Bees" and J__1.Rarity ~= "Premium" and not v.neon and not v.rainbow then
            local J8 = J2 or Value2[v.id]
            if J8 then
                J8 = J3 or Value[J__1.Rarity]
            end
            if J8 then
                local J5_5 = (v.amount or 1) - J6
                local J__3 = math.floor(J5_5 / hO)
                if J7 > 0 and J__3 > J7 then
                    J__3 = J7
                end
                if J__3 >= 1 then
                    J4_1[#J4_1 + 1] = { uid = k, amount = J__3 }
                end
            end
        end
    end
    return J4_1
end
function fns.fn743(qx, qy)
    local QX_1, QX_2
    local QW_1, QW_2
    local QV_1, QV_2
    local QU_1, QU_2
    local QT_1, QT_2, QT_3
    local QS = qy and qy.Parent
    local QS_1, QS_2, QS_3
    if QS then
        QT_1, QS_1 = A5(qy:GetPivot(), qx)
        if QT_1 then
            return qy, QT_1, QS_1
        end
        QV_1, QX_1, QW_1, QU_1 = nil, nil, nil, nil
        for i, v in ipairs(Bw()) do
            QT_2, QS_2 = A5(v:GetPivot(), qx)
            if QT_2 then
                local QY_1 = math.abs(QT_2) + math.abs(QS_2)
                if not QV_1 or QY_1 < QU_1 then
                    QV_1, QX_1, QW_1, QU_1 = v, QT_2, QS_2, QY_1
                end
            end
        end
        return QV_1, QX_1, QW_1
    end
    QV_2, QX_2, QW_2, QU_2 = nil, nil, nil, nil
    for i, v in ipairs(Bw()) do
        QT_3, QS_3 = A5(v:GetPivot(), qx)
        if QT_3 then
            local QY_2 = math.abs(QT_3) + math.abs(QS_3)
            if not QV_2 or QY_2 < QU_2 then
                QV_2, QX_2, QW_2, QU_2 = v, QT_3, QS_3, QY_2
            end
        end
    end
    return QV_2, QX_2, QW_2
end
function fns.fn758(ly)
    local MT_1
    local MS_1
    local Value = Options.TradeAcceptMode.Value
    if Value == "Everyone" then
        return true
    elseif Value == "Friends Only" then
        MS_1, MT_1 = pcall(LocalPlayer.IsFriendsWith, LocalPlayer, ly.UserId)
        return MS_1 and MT_1
    elseif Value == "Selected Player" then
        return ly == TP_9()
    elseif Value == "User List" then
        return CL(ly.Name, Options.TradeUserList.Value)
    else
        return false
    end
end
function fns.fn795(cc)
    local Value = Options.HiveAmount.Value
    local Fm = type(Value) == "string" and Value:lower():gsub("%s", "") == "max"
    if Fm then
        return Cx(cc)
    end
    local max = math.max
    local Fo = tonumber(Value) or 1
    return max(math.floor(Fo), 1)
end
function fns.fn814(hc)
    local Jr = Cc()
    if not Jr then
        return 0
    end
    local Js = 0
    for k, v in pairs(Jr.ActiveBoosts) do
        if v.sourceName == hc and (v.timeLeft or 0) > Js then
            Js = v.timeLeft
        end
    end
    return Js
end
function fns.fn817()
    local Rf_1
    local Rj = if not Bs() then 1 else 0
    if Rj == 1 then
        return
    end
    local Q9 = BY()
    if not Q9 then
        return
    end
    local cannon = TP_12.cannon
    local Rb = Options.TentacleShootDelay.Value or 0.15
    local Rb_4
    local Rc = {}
    for k, v in pairs(TP_12.targets) do
        Rc[#Rc + 1] = { positionName = k, uid = v }
    end
    for i, v in ipairs(Rc) do
        if Library.Unloaded or not Toggles.AutoShootTentacles.Value then
            return
        end
        if TP_12.targets[v.positionName] == v.uid then
            local Rb_2 = Q9:FindFirstChild(v.positionName)
            if Rb_2 then
                local Rc_1 = Rb_2.Position
                local Rb_3 = Q9.Parent and Q9.Parent:FindFirstChild("Targets")
                local Re = Rb_3
                local Re_2
                if Rb_3 then
                    Rb_3 = Re:FindFirstChild(v.positionName)
                end
                local Re_1 = Rb_3
                if Rb_3 then
                    Rb_3 = Re_1:IsA("Model")
                end
                if Rb_3 then
                    Rc_1 += Vector3.new(0, Re_1:GetExtentsSize().Y * 0.25, 0)
                end
                Rb_4, Rf_1, Re_2 = CG(Rc_1, cannon)
                if Rb_4 then
                    local Rc_2 = Rb_4:GetFullName()
                    Network.Send("Aim Update", Rc_2, Rf_1, Re_2)
                    task.wait()
                    Network.Send("Cannon Shoot Requested", Rc_2)
                    task.wait(Rb)
                end
            end
        end
    end
end
function fns.fn824()
    local G6 = Cc()
    local G6_1
    if not G6 then
        return
    end
    local G7 = G6.Rebirth or 0
    local G7_2
    local G8 = G7 + 1
    local G7_1 = Directory.Rebirths[G8]
    local G9 = not G7_1
    local G9_1
    if not G9 then
        G9 = (G6.Honey or 0) < G7_1.requiredHoney
    end
    if G9 then
        return
    end
    G7_2, G6_1, G9_1 = pcall(function()
        return Network.Query("Rebirth")
    end)
    if G7_2 and G6_1 then
        if Toggles.RebirthNotify.Value then
            Library:Notify(("Rebirthed to %d"):format(G8))
        end
    else
        if G7_2 and Toggles.RebirthNotify.Value and G9_1 then
            Library:Notify(tostring(G9_1))
        end
    end
end
function fns.fn925()
    table.clear(AT)
    local Character = LocalPlayer.Character
    if not Character then
        return
    end
    for i, descendant in ipairs(Character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            AT[#AT + 1] = descendant
        end
    end
end
function fns.fn944(Z, aa)
    return tostring(Z) < tostring(aa)
end
function fns.fn998()
    pcall(function()
        Network.Query("Equip Best Bees")
    end)
end
function fns.fn1002(m0)
    if Variables.Trading then
        Network.Send("Trade Cancel")
    end
    if m0 and Toggles.TradeNotify.Value then
        Library:Notify(m0)
    end
end
function fns.fn1010(eZ)
    local HH_2
    local HG_3
    local HF = {}
    for i, child in ipairs(eZ:GetChildren()) do
        if child:IsA("Folder") then
            local HG_1 = child:GetAttribute("Health") or 0
            if HG_1 > 0 then
                local HG_2 = TP_5(child)
                local HI = HF[HG_2] or 0
                HF[HG_2] = HI + HG_1
            end
        end
    end
    HH_2, HG_3 = nil, -math.huge
    for k, v in pairs(HF) do
        if v > HG_3 then
            HH_2, HG_3 = k, v
        end
    end
    return HH_2
end
function fns.fn1014(eW)
    local Hy = eW:GetAttribute("Area") or "Field"
    return Hy == "Spawn" and "Field" or Hy
end
function fns.fn1018(a6)
    for k, v in pairs(Worlds.GetAllHiveModels()) do
        if v:GetAttribute("ID") == a6 then
            return v
        end
    end
    return nil
end
function fns.fn1093()
    local Nk = Cc()
    if not Nk then
        return {}
    end
    local max2 = math.max
    local floor3 = math.floor
    local Nn = tonumber(Options.TradeKeepAmount.Value) or 0
    local Nm_1 = max2(floor3(Nn), 0)
    local floor2 = math.floor
    local No = tonumber(Options.TradeMaxPerStack.Value) or 0
    local Nn_2 = max2(floor2(No), 0)
    local floor = math.floor
    local Np = tonumber(Options.TradeMaxStacks.Value) or 0
    local No_2 = max2(floor(Np), 0)
    local Nl_1 = {}
    if Toggles.TradeOfferBees.Value then
        local Value3 = Options.TradeBeeList.Value
        local Value2 = Options.TradeBeeRarityList.Value
        local Value = Options.TradeBeeVariants.Value
        local Ns_1 = next(Value) ~= nil
        local Nu_1 = Nk.Bees or {}
        for k, v in pairs(Nu_1) do
            local Nt_2 = Directory.Items[v.id]
            local max = math.max
            local Nv = v.amount or 1
            local Nw = max(Nv - Nm_1, 0)
            local Nu_3 = Nt_2 and Nt_2.tradeable ~= false
            if Nu_3 then
                Nu_3 = Toggles.TradeIncludePaidItems.Value or not Nt_2.IsPaidItem
            end
            if Nu_3 then
                Nu_3 = Cv(v.id, Nt_2.Rarity, Value3, Value2)
            end
            if Nu_3 then
                local Nt_3 = not Ns_1 or Value[CB(v)]
                Nu_3 = Nt_3
            end
            if Nu_3 then
                Nu_3 = Nw > 0
            end
            if Nu_3 then
                if Nn_2 > 0 then
                    Nw = math.min(Nw, Nn_2)
                end
                Nl_1[#Nl_1 + 1] = { uid = k, isBee = true, amount = Nw, name = v.id }
            end
        end
    end
    if Toggles.TradeOfferItems.Value then
        local Value2 = Options.TradeItemList.Value
        local Value = Options.TradeItemRarityList.Value
        local Ns_2 = Nk.Items or {}
        for k, v in pairs(Ns_2) do
            local Nk_1 = Directory.Items[v.id]
            local Nr_3 = Nk_1
            if Nr_3 then
                Nr_3 = Nk_1.rarity or Nk_1.Rarity
            end
            local Ns_4 = Nr_3
            local max = math.max
            local Nt_4 = v.amount or 1
            local Nu_4 = max(Nt_4 - Nm_1, 0)
            local Nr_5 = Nk_1 and Nk_1.tradeable ~= false
            if Nr_5 then
                Nr_5 = Toggles.TradeIncludePaidItems.Value or not Nk_1.IsPaidItem
            end
            if Nr_5 then
                Nr_5 = Cv(v.id, Ns_4, Value2, Value)
            end
            if Nr_5 then
                Nr_5 = Nu_4 > 0
            end
            if Nr_5 then
                if Nn_2 > 0 then
                    Nu_4 = math.min(Nu_4, Nn_2)
                end
                Nl_1[#Nl_1 + 1] = { uid = k, isBee = false, amount = Nu_4, name = v.id }
            end
        end
    end
    table.sort(Nl_1, function(mv, mw)
        if mv.name == mw.name then
            return tostring(mv.uid) < tostring(mw.uid)
        end
        return mv.name < mw.name
    end)
    if No_2 > 0 then
        while #Nl_1 > No_2 do
            table.remove(Nl_1)
        end
    end
    return Nl_1
end
function fns.fn1099(jQ, jR)
    local Lv = BearQuests[jQ]
    local Lw = Lv and Lv.quests and Lv.quests[jR]
    local Lv_1 = Lw
    if Lw then
        Lw = Lv_1.requirementData
    end
    local Lv_2 = Lw
    local LD = if Lv_2 then 1 else 0
    local LB = 770 * LD + 3644 * (1 - LD)
    local LC = 299 * LD + 1583 * (1 - LD)
    if not ((LB * 1591 + LC * 1318 + LB * LC) % 16777213 == 1849382) then
        Lv_2 = nil
    end
    return Lv_2
end
function fns.fn1137(lQ)
    if lQ.rainbow then
        return "Rainbow"
    elseif lQ.neon then
        return "Neon"
    elseif lQ.glossy then
        return "Glossy"
    else
        return "Normal"
    end
end
function fns.fn1204(nv)
    if nv then
        if not connection3 then
            connection3 = RunService.Heartbeat:Connect(BK)
        end
    else
        if connection3 then
            connection3:Disconnect()
            connection3 = nil
        end
        local Ow = AS()
        if Ow then
            Ow.WalkSpeed = 16
        end
    end
end
function fns.fn1251()
    local holder = workspace:FindFirstChild("holder")
    local Hw = holder and holder:FindFirstChild("things")
    local Hv_1 = Hw
    if Hw then
        Hw = Hv_1:FindFirstChild("Flowers")
    end
    return Hw
end
function fns.fn1267()
    local HW = Bq()
    if not HW then
        return {}
    end
    local HX = {}
    for k, v in pairs(HW.GetLoadedBees()) do
        if v.spawned and v.spawned.owner == LocalPlayer then
            HX[#HX + 1] = k
        end
    end
    return HX
end
function fns.fn1271(hk)
    local JB = Cc()
    if not JB then
        return nil
    end
    for k, v in pairs(JB.Items) do
        if v.id == hk and (v.amount or 0) > 0 then
            return k
        end
    end
    return nil
end
function fns.fn1298(nX)
    if nX then
        if not connection4 then
            connection4 = UserInputService.JumpRequest:Connect(function()
                local OP = AS()
                if OP then
                    OP:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    elseif connection4 then
        connection4:Disconnect()
        connection4 = nil
    end
end
function fns.fn1304(iA)
    local Kv = Cc()
    if not Kv or not Kv.Bees then
        return {}
    end
    local Value2 = Options.RainbowBeeList.Value
    local Value = Options.RainbowRarityList.Value
    local Ky = next(BN(Value2)) == nil
    local Kz = next(BN(Value)) == nil
    local floor = math.floor
    local KB = tonumber(Options.RainbowKeep.Value) or 0
    local KC = floor(KB)
    local KB_1 = (tonumber(Options.RainbowMaxPerBee.Value))
    local KL = if KB_1 then 1 else 0
    local KJ = 2167 * KL + 3100 * (1 - KL)
    local KK = 2694 * KL + 3904 * (1 - KL)
    if not ((KJ * 4085 + KK * 2630 + KJ * KK) % 16777213 == 4998100) then
        KB_1 = 0
    end
    local KD = floor(KB_1)
    local KA_1 = {}
    for k, v in pairs(Kv.Bees) do
        local Kv_1 = Directory.Items[v.id]
        if Kv_1 and Kv_1.Type == "Bees" and Kv_1.Rarity ~= "Premium" and v.neon and not v.rainbow then
            local KE = Ky or Value2[v.id]
            if KE then
                KE = Kz or Value[Kv_1.Rarity]
            end
            if KE then
                local KB_5 = (v.amount or 1) - KC
                local Kv_3 = math.floor(KB_5 / iA)
                if KD > 0 and Kv_3 > KD then
                    Kv_3 = KD
                end
                if Kv_3 >= 1 then
                    KA_1[#KA_1 + 1] = { uid = k, amount = Kv_3 }
                end
            end
        end
    end
    return KA_1
end
function fns.fn1306(M, N)
    local D_ = Directory.Areas[M].id
    local D4 = if D_ then 1 else 0
    local D2 = 3070 * D4 + 1476 * (1 - D4)
    local D3 = 3789 * D4 + 798 * (1 - D4)
    if not ((D2 * 800 + D3 * 2141 + D2 * D3) % 16777213 == 5423266) then
        D_ = 0
    end
    return D_ < (Directory.Areas[N].id or 0)
end
function fns.fn1313(lH, lI)
    if not lH or lH == LocalPlayer then
        if lI then
            Library:Notify("Select a player who is in this server")
        end
        return false
    elseif Variables.OpeningHive > 0 then
        if lI then
            Library:Notify("Finish opening the hive before trading")
        end
        return false
    elseif Variables.Trading then
        if lI then
            Library:Notify("A trade is already open")
        end
        return false
    else
        local MZ_1 = os.clock() - Cq.lastRequestAt
        if MZ_1 < 20 then
            if lI then
                Library:Notify(("Wait %d seconds before sending again"):format(math.ceil(20 - MZ_1)))
            end
            return false
        end
        Cq.partner = lH
        Cq.lastRequestAt = os.clock()
        Cq.requestsSent = Cq.requestsSent + 1
        Network.Send("Trade Request", lH)
        return true
    end
end
function fns.fn1314(lS, lT, lU, lV)
    local M8 = next(lU) ~= nil
    local M9 = next(lV) ~= nil
    local Na = not M9
    local Nb = not M8
    if Nb ~= false then
        Nb = Na
    end
    if Nb then
        return false
    end
    if M8 and not lU[lS] then
        return false
    end
    if M9 and not lV[lT] then
        return false
    end
    return true
end
function fns.fn1326(am, an)
    return tostring(am) < tostring(an)
end
function fns.fn1335(aU)
    local Ek = Bn and Bn.Hives_PlayOpenAnimation
    if type(Ek) ~= "table" then
        return
    end
    if aU then
        if not Bi then
            Bi = table.clone(Ek)
            table.clear(Ek)
        end
    elseif Bi then
        for i, v in ipairs(Bi) do
            Ek[#Ek + 1] = v
        end
        Bi = nil
    end
end
function fns.fn1347(bN, bO)
    local E_ = 0
    if AZ.costIII then
        E_ = 0.15
    elseif AZ.costII then
        E_ = 0.1
    elseif AZ.costI then
        E_ = 0.05
    end
    local E2 = bO.Cost or 1
    return math.max(math.floor(E2 * Bx(bN) * (1 - E_)), 1)
end
function fns.fn1382(bE)
    local EO = Directory.Skills and Directory.Skills.Hives and Directory.Skills.Hives.perks
    if not EO then
        return 1
    end
    local floor = math.floor
    local sqrt = math.sqrt
    local ES = bE.Skills and bE.Skills.Hives
    local EZ = if ES then 1 else 0
    local EX = 1553 * EZ + 873 * (1 - EZ)
    local EY = 3447 * EZ + 733 * (1 - EZ)
    if not ((EX * 113 + EY * 1559 + EX * EY) % 16777213 == 10902553) then
        ES = 0
    end
    local EQ_1 = floor(sqrt(ES + 100) * 10 / 100)
    if EO[6] and EO[6].level <= EQ_1 then
        return 0.8
    end
    if EO[2] and EO[2].level <= EQ_1 then
        return 0.9
    end
    return 1
end
function fns.fn1390()
    local Qs = { "Auto (Nearest)" }
    for i, v in ipairs(Bw()) do
        Qs[#Qs + 1] = v.Name
    end
    table.sort(Qs, function(qa, qb)
        if qa == "Auto (Nearest)" then
            return true
        elseif qb == "Auto (Nearest)" then
            return false
        else
            return qa < qb
        end
    end)
    return Qs
end
function fns.fn1406()
    local QA = Options.TentacleCannon and Options.TentacleCannon.Value
    if QA and QA ~= "Auto (Nearest)" then
        for i, v in ipairs(Bw()) do
            if v.Name == QA then
                return v
            end
        end
    end
    return AJ()
end
function fns.fn1422(aN)
    local Ec = {}
    for k, v in aN do
        if v then
            Ec[#Ec + 1] = k
        end
    end
    table.sort(Ec)
    return Ec
end
function fns.fn1429()
    if Variables.OpeningHive <= 0 then
        return
    end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new())
end
function fns.fn1446(jY, jZ, j_)
    local LE = Cc()
    local LF = LE and LE.BearQuests and LE.BearQuests[jY]
    local LE_1 = LF
    if LF then
        LF = LE_1.requirementProgress
    end
    local LE_2 = LF
    if not LE_2 then
        return false
    end
    local LF_1 = LE_2[jZ] or 0
    local LE_3 = tonumber(j_[3]) or 0
    return LF_1 >= LE_3
end
function fns.fn1453(bb)
    local EE = Cm(bb)
    if not EE then
        return false
    end
    local EF = EE:FindFirstChild("Center") or EE.PrimaryPart
    local Character = LocalPlayer.Character
    local EG = Character and Character:FindFirstChild("HumanoidRootPart")
    if not (EF and EG) then
        return false
    end
    if (EG.Position - EF.Position).Magnitude > 12 then
        EG.CFrame = CFrame.new(EF.Position + Vector3.new(0, 4, 6))
    end
    return true
end
function fns.fn1454(oO)
    if oO then
        if not Be then
            Be = {
                QualityLevel = settings().Rendering.QualityLevel,
                GlobalShadows = Lighting.GlobalShadows,
                FogEnd = Lighting.FogEnd
            }
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000000000
        for i, child in ipairs(Lighting:GetChildren()) do
            local Pf_1 = child:IsA("PostEffect") and child.Enabled
            if Pf_1 then
                TP_11[child] = true
                child.Enabled = false
            end
        end
        for i, descendant in ipairs(workspace:GetDescendants()) do
            local Pf_2 = descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Smoke") or descendant:IsA("Fire") or descendant:IsA("Sparkles")
            if Pf_2 then
                if descendant.Enabled then
                    TP_11[descendant] = true
                    descendant.Enabled = false
                end
            end
        end
    elseif Be then
        settings().Rendering.QualityLevel = Be.QualityLevel
        Lighting.GlobalShadows = Be.GlobalShadows
        Lighting.FogEnd = Be.FogEnd
        Be = nil
        for k in pairs(TP_11) do
            if k.Parent then
                k.Enabled = true
            end
        end
        table.clear(TP_11)
    end
end
function fns.fn1463(mP)
    local NV = {}
    for i, v in ipairs(mP) do
        local NW = #NV + 1
        local NX = tostring(v.uid)
        local NY = v.amount or 1
        NV[NW] = NX .. ":" .. tostring(NY)
    end
    table.sort(NV)
    return table.concat(NV, "|")
end
function fns.fn1466(lf)
    if type(lf) ~= "string" then
        return nil
    end
    local My = lf:lower()
    for i, player in ipairs(Ay:GetPlayers()) do
        local Mz = player ~= LocalPlayer
        if Mz then
            local MA = player.Name:lower() == My or player.DisplayName:lower() == My
            Mz = MA
        end
        if Mz then
            return player
        end
    end
    return nil
end
function fns.fn1470()
    local Qh_1
    local Qg_1
    local Qd_5
    if Ck == nil then
        Ck = false
        local LMV = ReplicatedStorage:FindFirstChild("LMV")
        local Qe = LMV and LMV:FindFirstChild("Client")
        local Qe_2
        local Qd_2 = Qe
        if Qe then
            Qe = Qd_2:FindFirstChild("SummerCannons")
        end
        local Qd_3 = Qe
        if Qd_3 then
            local CannonGui = Qd_3:FindFirstChild("CannonGui")
            local TargetSpawnerClient = Qd_3:FindFirstChild("TargetSpawnerClient")
            if CannonGui and TargetSpawnerClient then
                Qd_5, Qg_1 = pcall(require, CannonGui)
                Qe_2, Qh_1 = pcall(require, TargetSpawnerClient)
                if Qd_5 and Qe_2 then
                    Ck = { gui = Qg_1, spawner = Qh_1 }
                end
            end
        end
    end
    return Ck or nil
end
function fns.fn1485()
    Cq.startedAt = 0
    Cq.offerBuilt = false
    Cq.offerBuiltAt = 0
    Cq.readyRequestAt = 0
    Cq.selfReady = false
    Cq.otherReady = false
    Cq.otherItems = {}
    Cq.otherHoney = 0
    Cq.lastOtherOffer = ""
end
local function fn1488()
    if Variables.Trading then
        local Om = Cq.partner and Cq.partner.Name or "another player"
        if Cq.selfReady and Cq.otherReady then
            return "Status: Both players are ready with " .. Om
        elseif Cq.selfReady then
            return "Status: Waiting for " .. Om .. " to be ready"
        elseif not Cq.offerBuilt then
            return "Status: Building your offer for " .. Om
        elseif not AR() then
            return "Status: Waiting for the other offer to meet your rules"
        else
            return "Status: Offer ready for " .. Om
        end
    else
        return "Status: Waiting for a trade"
    end
end
local function fn1498()
    local Mq = {}
    for i, player in ipairs(Ay:GetPlayers()) do
        if player ~= LocalPlayer then
            Mq[#Mq + 1] = player.Name
        end
    end
    table.sort(Mq)
    return Mq
end
local function fn1515()
    local FP_1
    local FO_1
    FP_1, FO_1 = nil, nil
    for k, v in pairs(Worlds.GetAllHiveModels()) do
        local F3 = if v:GetAttribute("Unlocked") then 1 else 0
        if F3 == 1 then
            local attr = v:GetAttribute("ID")
            local FR = attr and Directory.Hives[attr]
            local FS = FR
            if FR then
                FR = FS.Hatchable
            end
            if FR then
                FR = not FO_1 or (FS.Cost or 0) > FO_1
            end
            if FR then
                FP_1 = attr
                FO_1 = FS.Cost or 0
            end
        end
    end
    return FP_1
end
local function fn1527()
    local MP = Options.TradePlayer and Options.TradePlayer.Value
    return Bm(MP)
end
local function fn1540(ao, ap)
    return tostring(ao) < tostring(ap)
end
local function fn1543(ab, ac)
    return tostring(ab) < tostring(ac)
end
local function fn1551()
    if connection5 then
        connection5:Disconnect()
        connection5 = nil
    end
    if connection6 then
        connection6:Disconnect()
        connection6 = nil
    end
    for i, v in ipairs(BT) do
        v:Destroy()
    end
    table.clear(BT)
    local OS = AS()
    if OS then
        OS.PlatformStand = false
    end
end
local function fn1615(a1)
    local Eu_1
    local Et_1
    Et_1, Eu_1 = pcall(Worlds.HasAreaAccess, a1)
    return Et_1 and Eu_1
end
local function fn1620(cg, ch)
    local Fv_1
    local Fu_1
    local Ft_1
    Fu_1, Fv_1, Ft_1 = Network.Query("Buy Hive", cg, ch)
    local Fw = not Fu_1
    if Fw ~= false then
        Fw = type(Ft_1) == "number"
    end
    if Fw then
        Fw = Ft_1 > 0
    end
    if Fw and Ft_1 ~= ch then
        Fu_1, Fv_1 = Network.Query("Buy Hive", cg, Ft_1)
    end
    return Fu_1, Fv_1
end
Ay = nil
Az = nil
AA = nil
Options = nil
AE = nil
AG = nil
AH = nil
Window = nil
AJ = nil
AK = nil
Toggles = nil
connection2 = nil
AO = nil
onCraftNeonNow = nil
AR = nil
AS = nil
AT = nil
AW = nil
AX = nil
AZ = nil
A1 = nil
A2 = nil
A3 = nil
A5 = nil
TP_26 = nil
A7 = nil
A8 = nil
Library = nil
TP_3 = nil
Be = nil
Bf = nil
Bi = nil
TP_11 = nil
BearQuests = nil
local AB, AC, connection7, AN, AP, AU, AV, AY, A_, A0, A4, A9, Bb, Bc, Bh
Bl = nil
Bm = nil
Bn = nil
Directory = nil
TP_25 = nil
Bq = nil
Bs = nil
Bt = nil
Bu = nil
Bw = nil
Bx = nil
AbuseManager = nil
Bz = nil
BA = nil
Variables = nil
TP_6 = nil
BF = nil
Worlds = nil
Saving = nil
BJ = nil
BK = nil
BL = nil
BN = nil
Network = nil
BR = nil
BS = nil
BT = nil
TP_5 = nil
BX = nil
BY = nil
connection6 = nil
TP_12 = nil
connection5 = nil
onFly = nil
B5 = nil
TP_24 = nil
LocalPlayer = nil
local Br, Bv, BD, BE, BH, BM, BO, BP, BU, connection9, connection11, connection10, B2
B8 = nil
Label2 = nil
connection4 = nil
Cb = nil
Cc = nil
Ce = nil
Cg = nil
connection = nil
TP_9 = nil
Ck = nil
Cm = nil
Cn = nil
Label = nil
UserInputService = nil
Cq = nil
connection3 = nil
Cv = nil
RunService = nil
Cx = nil
Lighting = nil
onOpenPouchesNow = nil
CB = nil
VirtualUser = nil
CF = nil
CG = nil
onPlayerAdded = nil
ReplicatedStorage = nil
CJ = nil
CL = nil
CM = nil
CN = nil
CO = nil
CP = nil
local Cd, Ch, Cl, Cs, Ct, Cu, connection8, CC, CE
Cd = nil
local TeleportService
Ch = nil
Cl = nil
Cs = nil
Ct = nil
Cu = nil
connection8 = nil
CC = nil
CE = nil
Ay, ReplicatedStorage, VirtualUser, Lighting, RunService, UserInputService, TeleportService, LocalPlayer = nil, nil, nil, nil, nil, nil, nil, nil
Ay = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
VirtualUser = game:GetService("VirtualUser")
Lighting = game:GetService("Lighting")
RunService = game:GetService("RunService")
if ((UserInputService and not LocalPlayer or not Lighting and false) and (UserInputService or LocalPlayer or UserInputService and TeleportService) and (ReplicatedStorage or 6 or (ReplicatedStorage or not UserInputService) or (not Lighting or not TeleportService) and (not ReplicatedStorage or not TeleportService)) or (LocalPlayer and not UserInputService or (not UserInputService or not TeleportService) or (not UserInputService or not Lighting) and ReplicatedStorage) and ((not TeleportService or Lighting) and (UserInputService or Lighting) or (not TeleportService and not LocalPlayer or (TeleportService or UserInputService)))) and not ((UserInputService and not LocalPlayer or not Lighting and false) and (UserInputService or LocalPlayer or UserInputService and TeleportService) and (ReplicatedStorage or 6 or (ReplicatedStorage or not UserInputService) or (not Lighting or not TeleportService) and (not ReplicatedStorage or not TeleportService)) or (LocalPlayer and not UserInputService or (not UserInputService or not TeleportService) or (not UserInputService or not Lighting) and ReplicatedStorage) and ((not TeleportService or Lighting) and (UserInputService or Lighting) or (not TeleportService and not LocalPlayer or (TeleportService or UserInputService)))) then
    Ay = game:GetService("UserInputService")
else
    UserInputService = game:GetService("UserInputService")
end
TeleportService = game:GetService("TeleportService")
LocalPlayer = Ay.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
Network, Saving, Worlds, Variables, AbuseManager, Directory, BearQuests, Library, Toggles, Options, Az, CJ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local TP_46 = ReplicatedStorage:WaitForChild("LMV")
Network = require(TP_46.Client.Network)
Saving = require(TP_46.Client.Saving)
Worlds = require(TP_46.Client.Worlds)
Variables = require(TP_46.Client.Variables)
AbuseManager = require(TP_46.Client.AbuseManager)
Directory = require(ReplicatedStorage.Directory.Directory)
BearQuests = require(ReplicatedStorage.Directory.Configs.BearQuests)
Library = getgenv().Library
pcall(fns.fn278)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
Az = "https://discord.gg/K7Qxnxkk46"
CJ = fns.fn31
local TP_35 = {}
for k in pairs(Directory.Hives) do
    TP_35[#TP_35 + 1] = k
end
Ch = nil
local TP_68 = 6
repeat
    TP_57 = {
        "wapbrfqgasi",
        "njge",
        "uyvvhotucs",
        "mfoloyd",
        "lrojwyeuf",
        "xqdpajohmj",
        "rxnlroovrnj",
        "dtioy",
        "fhvypgepvl",
        "kmeyseqd",
        "reutfqe"
    }
    local WD = TP_68
    TP_46 = TP_57[WD % 11 + 1]
    if TP_46:len() <= TP_46:gsub("(.)", "%1%1", WD % 3 % 2 + 1):len() then
        table.sort(TP_35)
        Ch = {}
    else
        table.sort(Ch)
        TP_35 = {}
    end
    TP_68 = (TP_68 + 6) % 8
until (TP_68 * 5 + 4) % 8 == 0
for k, v in pairs(Directory.Areas) do
    if not v.unlockedByDefault then
        Ch[#Ch + 1] = k
    end
end
table.sort(Ch, fns.fn1306)
TP_57 = {}
for k, v in pairs(Directory.Items) do
    if v.category == "Fruits" then
        TP_57[#TP_57 + 1] = k
    end
end
TP_71, TP_60, TP_46 = nil, nil, nil
TP_68 = 22
repeat
    TP_49 = (TP_68 * 1 + 2) % 3 + 1
    if TP_49 <= 2 then
        if TP_49 <= 1 then
            if TP_68 * 84733421 + 3 + 2 <= TP_68 * 84733421 + 3 + 2 + 3 then
                table.sort(TP_57)
                TP_71 = {}
            else
                table.sort(TP_71)
                TP_57 = {}
            end
            TP_68 = (TP_68 + 16) % 24
        else
            local VU = bit32.rrotate(bit32.bxor(bit32.lrotate(TP_68, 31), string.byte(tostring(TP_46))), 26)
            if bit32.bxor(bit32.lrotate(bit32.bxor(VU, 646647325), 24), 489065230) ~= bit32.lrotate(VU, 24) then
                TP_46 = {}
            else
                TP_60 = {}
            end
            TP_68 = (TP_68 + 19) % 24
        end
    else
        TP_49 = {
            "twubhuaaqnzl",
            "gjnbsg",
            "bzq",
            "nbddmqgiajuw",
            "owqikbawuja",
            "bpsas",
            "tqw",
            "priymroouo",
            "rbgxk",
            "hqghkaesslxq",
            "zscqa",
            "frae",
            "tulsxrlymmhx"
        }
        if TP_49[(TP_68 * 43 + 17) % 13 + 1] < TP_49[(TP_68 * 43 + 17) % 13 + 1] then
            TP_71 = {}
        else
            TP_46 = {}
        end
        TP_68 = (TP_68 + 19) % 24
    end
until (TP_68 * 5 + 9) % 24 == 5
for k, v in pairs(Directory.Items) do
    TP_68 = v.Type == "Bees" and v.Rarity ~= "Premium"
    if TP_68 then
        TP_71[#TP_71 + 1] = k
        TP_68 = type(v.Rarity) == "string" and not TP_46[v.Rarity]
        if TP_68 then
            TP_46[v.Rarity] = true
            TP_60[#TP_60 + 1] = v.Rarity
        end
    end
end
TP_38, TP_27, TP_49 = nil, nil, nil
TP_68 = 3
repeat
    TP_46 = (TP_68 * 1 + 0) % 3 + 1
    if TP_46 <= 2 then
        if TP_46 <= 1 then
            TP_46 = {
                "izy",
                "gflhugnhu",
                "itkepvbtv",
                "gaak",
                "cuibkodad",
                "xmfoum",
                "fcueczlxsun",
                "lxck",
                "easaeuuahke",
                "tsdhw",
                "pgkzi"
            }
            if TP_46[(TP_68 * 93 + 1) % 11 + 1] <= TP_46[(TP_68 * 93 + 1) % 11 + 1] then
                table.sort(TP_71, fns.fn944)
                table.sort(TP_60, fn1543)
                TP_38 = {}
            else
                table.sort(TP_38, fns.fn944)
                table.sort(TP_71, fn1543)
                TP_60 = {}
            end
            TP_68 = (TP_68 + 1) % 12
        else
            TP_46 = { "hkhyuu", "arsxyrk", "yuerraumj", "hefdeyamjo", "bnu", "tsamqgrr", "mopbmwryl", "qpbobtu" }
            if TP_46[(TP_68 * 37 + 97) % 8 + 1] <= TP_46[(TP_68 * 37 + 97) % 8 + 1] then
                TP_27 = {}
            else
                TP_38 = {}
            end
            TP_68 = (TP_68 + 4) % 12
        end
    else
        TP_46 = (vector.create((TP_68 * 3 + 4) % 11 + 1, (TP_68 * 7 + 7) % 13 + 1, (TP_68 * 4 + 12) % 17 + 1))
        TP_7 = (vector.create((TP_68 * 6 + 7) % 11 + 1, (TP_68 * 7 + 8) % 13 + 1, (TP_68 * 7 + 2) % 17 + 1))
        TP_74 = (vector.create((TP_68 * 1 + 8) % 11 + 1, (TP_68 * 4 + 9) % 13 + 1, (TP_68 * 3 + 1) % 17 + 1))
        TP_63 = (vector.create((TP_68 * 4 + 5) % 11 + 1, (TP_68 * 3 + 12) % 13 + 1, (TP_68 * 12 + 7) % 17 + 1))
        if vector.dot(vector.cross(TP_46, TP_7), (vector.cross(TP_74, TP_63))) == vector.dot(TP_46, TP_74) * vector.dot(TP_7, TP_63) - vector.dot(TP_46, TP_63) * vector.dot(TP_7, TP_74) then
            TP_49 = {}
        else
            TP_27 = {}
        end
        TP_68 = (TP_68 + 7) % 12
    end
until (TP_68 * 11 + 3) % 12 == 0
for k, v in pairs(Directory.Items) do
    TP_68 = v.Type ~= "Bees" and v.tradeable ~= false
    if TP_68 then
        TP_38[#TP_38 + 1] = k
        TP_68 = v.rarity or v.Rarity
        TP_46 = TP_68
        TP_68 = type(TP_46) == "string" and not TP_49[TP_46]
        if TP_68 then
            TP_49[TP_46] = true
            TP_27[#TP_27 + 1] = TP_46
        end
    end
end
table.sort(TP_38, fns.fn1326)
table.sort(TP_27, fn1540)
TP_7 = {}
for k, v in pairs(Directory.Items) do
    if v.category == "Pouches" then
        TP_7[#TP_7 + 1] = k
    end
end
Bh = nil
TP_68 = 1
repeat
    TP_46 = {
        "odsrrmhej",
        "hrvxn",
        "uiycocokt",
        "wxfqc",
        "ezywmbvqtuhh",
        "kibifpjpuv",
        "jsj",
        "qhhtrd",
        "zdgymearowdf",
        "zzchx"
    }
    if TP_46[(TP_68 * 56 + 13) % 10 + 1] < TP_46[(TP_68 * 56 + 13) % 10 + 1] then
        table.sort(Bh)
        TP_7 = {}
    else
        table.sort(TP_7)
        Bh = {}
    end
    TP_68 = (TP_68 + 0) % 8
until (TP_68 * 7 + 6) % 8 == 5
for k in pairs(BearQuests) do
    Bh[#Bh + 1] = k
end
table.sort(Bh)
TP_46 = { "Auto (Best)", "All Fields" }
local onTeleportToSecretArea = {}
TP_74 = workspace:FindFirstChild("holder")
TP_63 = TP_74 and TP_74:FindFirstChild("things")
TP_68 = TP_63
TP_49 = TP_68 and TP_68:FindFirstChild("Flowers")
TP_68 = TP_49
if TP_68 then
    for i, child in ipairs(TP_68:GetChildren()) do
        if child:IsA("Folder") then
            TP_68 = child:GetAttribute("Area") or "Field"
            TP_49 = TP_68
            if TP_49 == "Spawn" then
                TP_49 = "Field"
            end
            if not onTeleportToSecretArea[TP_49] then
                onTeleportToSecretArea[TP_49] = true
                TP_46[#TP_46 + 1] = TP_49
            end
        end
    end
end
table.sort(TP_46, fns.fn402)
Cl, Bn, Bi, AZ, AV, A4, A_, Bz, AN, Cq, Label, Label2, connection10, connection11, connection3, connection, connection4, connection5, connection6, BT, AT, connection2, TP_11, Be, Cn, Ce, TP_24, TP_12, Ck, Window, Cc, BN, Bc, CN, Cm, BP, AO, Bx, AK, Cx, CE, B2, Bl, BM, AG, Bu, TP_3, AP, AW, BJ, Bq, Ct, TP_5, BD, AB, B5, onOpenPouchesNow, CF, Cu, BE, A2, Bv, AU, onCraftNeonNow, A0, AX, AH, BF, CC, BO, AY, Cd, CP, BS, Bm, CL, TP_9, BU, A7, CB, Cv, BA, CO, Bf, AR, Cg, TP_6, TP_25, AS, CM, BK, Br, AE, Cs, Bb, AC, onFly, A9, BX, Bw, AJ, BY, Bt, A5, B8, A1, AA, Cb, Bs, CG, A3, TP_63 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Cl = 12
Cc = fns.fn483
BN = fns.fn1422
Bn = debug.getupvalues(Network.OnPacket)[3]
Bi = nil
Bc = fns.fn1335
CN = fn1615
Cm = fns.fn1018
BP = fns.fn1453
AZ = { costI = false, costII = false, costIII = false, hatch = 0 }
AV = -math.huge
AO = function()
    local EL
    if os.clock() - AV < 3 then
        return
    end
    AV = os.clock()
    EL = { costI = false, costII = false, costIII = false, hatch = 0 }
    local EM = pcall(function()
        Network.InvokeSignal("Has UpgradeTree Upgrade", LocalPlayer, {
            Cost1 = function()
                EL.costI = true
            end,
            Cost2 = function()
                EL.costII = true
            end,
            Cost3 = function()
                EL.costIII = true
            end,
            Cost4 = function() end,
            Hatch = function()
                EL.hatch = EL.hatch + 1
            end,
            Hatch2 = function()
                EL.hatch = EL.hatch + 1
            end,
            Hatch3 = function()
                EL.hatch = EL.hatch + 1
            end,
            Hatch4 = function()
                EL.hatch = EL.hatch + 1
            end
        })
    end)
    if EM then
        AZ = EL
    end
end
Bx = fns.fn1382
AK = fns.fn1347
Cx = fns.fn30
CE = fns.fn795
B2 = fn1620
Bl = function()
    local FF_1
    local FE_1
    local FD = BN(Options.HiveList.Value)
    local FD_3
    if #FD == 0 then
        return
    end
    for i, v in ipairs(FD) do
        local FN = v
        if Library.Unloaded or not Toggles.AutoOpenHives.Value then
            return
        end
        local FD_2 = not Toggles.HiveTeleport.Value or BP(FN)
        if FD_2 then
            FD_3, FE_1, FF_1 = pcall(function()
                return B2(FN, CE(FN))
            end)
            if FD_3 and not FE_1 and Toggles.HiveNotify.Value and FF_1 then
                Library:Notify(("%s: %s"):format(FN, tostring(FF_1)))
            end
        end
        local wait = task.wait
        local FE_2 = Options.HiveDelay.Value or 0.5
        wait(FE_2)
    end
end
BM = fn1515
AG = function()
    local F7_1
    local F6_1
    local F4 = BM()
    if not F4 then
        return
    end
    local F5 = not Toggles.HiveTeleport.Value or BP(F4)
    local F5_1
    if F5 then
        F5_1, F6_1, F7_1 = pcall(function()
            return B2(F4, CE(F4))
        end)
        if F5_1 and not F6_1 and Toggles.HiveNotify.Value and F7_1 then
            Library:Notify(("%s: %s"):format(F4, tostring(F7_1)))
        end
    end
end
Bu = fns.fn1429
TP_3 = function()
    if Variables.LoadingWorld then
        return
    end
    local Ge = Worlds.GetCurrentWorld()
    local map = workspace:FindFirstChild("map")
    local Gf_6
    if not (Ge and map) then
        return
    end
    local FarmingAreas = map:FindFirstChild("FarmingAreas")
    local Teleports = map:FindFirstChild("Teleports")
    for i, v in ipairs(Ch) do
        local Gt = v
        if Library.Unloaded or not Toggles.AutoUnlockZones.Value then
            return
        end
        local Gf_2 = Directory.Areas[Gt]
        local Gi = Gf_2 and Gf_2.world == Ge
        local Gi_2
        local Gf_3 = FarmingAreas
        if Gf_3 then
            Gf_3 = FarmingAreas:FindFirstChild(Gt)
        end
        local Gi_1 = Gf_3
        if not Gi_1 then
            local Gf_4 = Teleports and Teleports:FindFirstChild(Gt)
            Gi_1 = Gf_4
        end
        local Gf_5 = Gi
        local Gj_1 = Gi_1
        if Gf_5 then
            Gf_5 = Gj_1
        end
        if Gf_5 then
            Gf_5 = not CN(Gt)
        end
        if Gf_5 then
            Gf_6, Gi_2 = pcall(function()
                return Network.Query("Buy Area", Gt)
            end)
            if Gf_6 and Gi_2 and Toggles.ZoneNotify.Value then
                Library:Notify(("Unlocked %s"):format(Gt))
            end
            task.wait(0.5)
        end
    end
end
AP = fns.fn186
A4 = nil
A_ = nil
AW = function()
    local G0
    local G2_1
    local G1_1
    G0, G2_1, G1_1 = AP()
    local Character = LocalPlayer.Character
    local G4 = Character and Character:FindFirstChild("HumanoidRootPart")
    if not (G0 and G4) then
        return
    end
    if G1_1 ~= A_ then
        A_ = G1_1
        A4 = nil
    end
    if (G4.Position - G0).Magnitude > 30 then
        pcall(function()
            LocalPlayer:RequestStreamAroundAsync(G0, 8)
        end)
        G4.CFrame = CFrame.new(G0 + Vector3.new(0, 6, 0))
        if Toggles.ZoneNotify.Value and G2_1 ~= A4 then
            A4 = G2_1
            Library:Notify(("Moved to %s"):format(G2_1))
        end
    end
end
BJ = fns.fn824
Bz = nil
Bq = fns.fn276
Ct = fns.fn1251
TP_5 = fns.fn1014
BD = fns.fn1010
AB = fns.fn1267
B5 = function(fi, fj)
    local Ir
    local Iq
    Iq = nil
    Ir = nil
    local Iu = Ct()
    if not Iu then
        return false, "Flowers are not loaded"
    end
    local Iv = AB()
    if #Iv == 0 then
        return false, "No equipped bees are loaded"
    end
    local Iw = fi
    local ID = if Iw then 1 else 0
    local IB = 54 * ID + 1279 * (1 - ID)
    local IC = 3070 * ID + 1363 * (1 - ID)
    if not ((IB * 3827 + IC * 2079 + IB * IC) % 16777213 == 6754968) then
        Iw = Options.PowerFarmArea.Value
    end
    local Ix = Iw
    local Iw_1 = Ix == "All Fields"
    if Ix == "Auto (Best)" then
        Ix = BD(Iu)
    end
    local Iy = not Ix
    local Iz = not Iw_1
    if Iz ~= false then
        Iz = Iy
    end
    if Iz then
        return false, "No live flowers found"
    end
    Iq = {}
    for i, child in ipairs(Iu:GetChildren()) do
        local Iu_1 = (child:IsA("Folder"))
        if Iu_1 then
            local Iy_1 = Iw_1 or TP_5(child) == Ix
            Iu_1 = Iy_1
        end
        if Iu_1 then
            local Iy_2 = child:GetAttribute("Health") or 0
            Iu_1 = Iy_2 > 0
        end
        if Iu_1 then
            Iu_1 = child:GetAttribute("ID")
        end
        if Iu_1 then
            Iq[#Iq + 1] = child
        end
    end
    table.sort(Iq, function(fz, fA)
        local H4 = fz:GetAttribute("Health") or 0
        local H5 = fA:GetAttribute("Health") or 0
        return H4 > H5
    end)
    local floor = math.floor
    local Iw_2 = Options.PowerFarmHits.Value or 3
    local Ip = floor(Iw_2)
    local Iu_3 = Options.PowerFarmSpeed.Value or 0.03
    local Im = 0
    local It = Iu_3
    Ir = 1
    local Iu_4 = math.min(#Iv, #Iq)
    local In = Iu_4
    local function Is()
        local fI = Iq[Ir]
        Ir += 1
        return fI
    end
    for i = 1, Iu_4 do
        local Io
        Io = Iv[i]
        task.spawn(function()
            local Ic_3
            local Ig = false
            repeat
                local H8 = not Library.Unloaded
                if H8 then
                    H8 = fj or Toggles.PowerAutoFarm.Value
                end
                if H8 then
                    local H8_1 = Is()
                    if not H8_1 then
                        Ig = true
                    else
                        local attr = H8_1:GetAttribute("ID")
                        local H9_2 = false
                        local Ia = os.clock() + 15
                        while true do
                            local Ib = H8_1.Parent
                            local Ib_1
                            if Ib then
                                local Ic_1 = H8_1:GetAttribute("Health") or 0
                                Ib = Ic_1 > 0
                            end
                            if Ib then
                                Ib = not Library.Unloaded
                            end
                            if Ib then
                                Ib = os.clock() < Ia
                            end
                            if Ib then
                                Ib = fj or Toggles.PowerAutoFarm.Value
                            end
                            if Ib then
                                if not H9_2 then
                                    Ib_1, Ic_3 = pcall(function()
                                        return Network.Query("Join Flower", attr, { Io })
                                    end)
                                    local Id = Ib_1 and type(Ic_3) == "table" and Ic_3[Io] == true
                                    H9_2 = Id
                                end
                                if H9_2 then
                                    local Ij = 1
                                    while Ij <= Ip do
                                        local Ib_2 = not H8_1.Parent
                                        if not Ib_2 then
                                            local Ic_4 = H8_1:GetAttribute("Health") or 0
                                            Ib_2 = Ic_4 <= 0
                                        end
                                        if Ib_2 then
                                            break
                                        end
                                        Network.Send("Farm Flower", attr, Io)
                                        task.wait(It)
                                        Ij += 1
                                    end
                                else
                                    task.wait(math.max(It, 0.1))
                                end
                                continue
                            end
                            break
                        end
                        local H9_3 = not H8_1.Parent
                        if not H9_3 then
                            local Ia_1 = H8_1:GetAttribute("Health") or 0
                            H9_3 = Ia_1 <= 0
                        end
                        if H9_3 then
                            Im += 1
                        end
                    end
                else
                    Ig = true
                end
            until Ig
            In -= 1
        end)
    end
    while true do
        if In > 0 and not Library.Unloaded then
            task.wait(It)
            continue
        end
        break
    end
    return Im > 0, Ix
end
onTeleportToSecretArea = function()
    local Position
    local map = workspace:FindFirstChild("map")
    local IW = map and map:FindFirstChild("Build")
    local IV_1 = IW
    if IW then
        IW = IV_1:FindFirstChild("AproxCaveSecret")
    end
    local IV_2 = IW
    if IW then
        IW = IV_2:FindFirstChild("GummyBee")
    end
    local IV_3 = IW
    local Character = LocalPlayer.Character
    local IX = Character and Character:FindFirstChild("HumanoidRootPart")
    if not (IV_3 and IX) then
        Library:Notify("Could not find the secret area")
        return
    end
    Position = IV_3:GetPivot().Position
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(Position, 8)
    end)
    IX.CFrame = CFrame.new(Position + Vector3.new(0, 6, 8))
end
local function onTeleportToSummerSecretArea()
    local Position
    local map = workspace:FindFirstChild("map")
    local I3 = map and map:FindFirstChild("Hives")
    local I2_1 = I3
    if I3 then
        I3 = I2_1:FindFirstChild("Bouncy Land")
    end
    local I2_2 = I3
    if I3 then
        I3 = I2_2:FindFirstChild("Bouncy Secret Hive")
    end
    local I2_3 = I3
    local Character = LocalPlayer.Character
    local I4 = Character and Character:FindFirstChild("HumanoidRootPart")
    if not (I2_3 and I4) then
        Library:Notify("Could not find the Summer secret area")
        return
    end
    Position = I2_3:GetPivot().Position
    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(Position, 8)
    end)
    I4.CFrame = CFrame.new(Position + Vector3.new(0, 5, 8))
end
onOpenPouchesNow = function()
    local Jc = Cc()
    local Jc_4
    if not Jc then
        return
    end
    local Value = Options.PouchList.Value
    local Je = next(BN(Value)) == nil
    for k, v in pairs(Jc.Items) do
        local Jo = k
        local Jq = v
        if Library.Unloaded or not Toggles.AutoUsePouches.Value then
            return
        end
        local Jc_2 = Directory.Items[Jq.id]
        local Jf = Jc_2 and Jc_2.category == "Pouches"
        local Jf_1
        if Jf then
            Jf = Je or Value[Jq.id]
        end
        if Jf then
            Jc_4, Jf_1 = pcall(function()
                local Query = Network.Query
                local Ja = Jq.amount or 1
                return Query("Open Pouche", Jo, Ja)
            end)
            if Jc_4 and Jf_1 and Toggles.PouchNotify.Value then
                local id = Jq.id
                local Jf_2 = Jq.amount or 1
                Library:Notify(("Opened %s x%d"):format(id, Jf_2))
            end
            local wait = task.wait
            local Jf_3 = Options.PouchDelay.Value or 0.5
            wait(Jf_3)
        end
    end
end
CF = fns.fn998
Cu = fns.fn814
BE = fns.fn1271
A2 = function()
    local JL = BN(Options.FruitList.Value)
    local JL_3
    local JM = tonumber(Options.FruitRefreshBelow.Value) or 0
    local JM_1
    for i, v in ipairs(JL) do
        if Library.Unloaded or not Toggles.AutoUseFruits.Value then
            return
        end
        local JL_2 = not Toggles.FruitKeepActive.Value or Cu(v) <= JM
        if JL_2 then
            local JK = BE(v)
            if JK then
                JL_3, JM_1 = pcall(function()
                    return Network.Query("Use Fruit", JK, 1)
                end)
                if JL_3 and JM_1 and Toggles.FruitNotify.Value then
                    Library:Notify(("Used %s"):format(v))
                end
                task.wait(0.3)
            end
        end
    end
end
Bv = function(hH)
    local JX_1
    local JW_1
    JW_1, JX_1 = pcall(function()
        return Network.Query("Get Fuse Amount", hH == true)
    end)
    if JW_1 then
        local max = math.max
        local JY = tonumber(JX_1) or 10
        return max(JY, 1)
    end
    return 10
end
AU = fns.fn627
onCraftNeonNow = function()
    local Kj_1, Kj_2
    local Ki_1, Ki_4
    local Kh = Bv(false)
    local Kg = AU(Kh)
    if #Kg == 0 then
        return
    end
    local Kh_1 = 0
    if Toggles.NeonBatch.Value then
        Ki_1, Kj_1 = pcall(function()
            return Network.Query("Make Neon Batch", Kg)
        end)
        local Kk_1 = Ki_1 and type(Kj_1) == "table" and Kj_1.success
        if Kk_1 then
            local Ki_2 = Kj_1.crafted
            local Ko = if Ki_2 then 1 else 0
            local Km = 397 * Ko + 2955 * (1 - Ko)
            local Kn = 53 * Ko + 776 * (1 - Ko)
            if not ((Km * 2460 + Kn * 4044 + Km * Kn) % 16777213 == 1211993) then
                Ki_2 = 0
            end
            Kh_1 = Ki_2
        end
    else
        for i, v in ipairs(Kg) do
            local Ku = v
            if Library.Unloaded or not Toggles.AutoNeonPets.Value then
                break
            end
            Ki_4, Kj_2 = pcall(function()
                return Network.Query("Make Neon", Ku.amount, Ku.uid)
            end)
            if Ki_4 and Kj_2 then
                Kh_1 = Kh_1 + Ku.amount
            end
            local wait = task.wait
            local Kj_3 = Options.NeonDelay.Value or 1
            wait(Kj_3)
        end
    end
    if Kh_1 > 0 and Toggles.NeonNotify.Value then
        Library:Notify(("Crafted %d Neon Bees"):format(Kh_1))
    end
end
A0 = fns.fn1304
AX = function(i_)
    local KV_1, KV_3
    local KU_1, KU_4
    local KT = Bv(true)
    local KS = A0(KT)
    if #KS == 0 then
        if i_ and Toggles.RainbowNotify.Value then
            Library:Notify("No Rainbow crafts available")
        end
        return
    end
    local KT_2 = 0
    if Toggles.RainbowBatch.Value then
        KU_1, KV_1 = pcall(function()
            return Network.Query("Make Rainbow Batch", KS)
        end)
        local KW_1 = KU_1 and type(KV_1) == "table" and KV_1.success
        if KW_1 then
            local KU_2 = KV_1.crafted
            local K_ = if KU_2 then 1 else 0
            local KY = 2702 * K_ + 971 * (1 - K_)
            local KZ = 3712 * K_ + 523 * (1 - K_)
            if not ((KY * 1745 + KZ * 2277 + KY * KZ) % 16777213 == 6419825) then
                KU_2 = 0
            end
            KT_2 = KU_2
        end
    else
        for i, v in ipairs(KS) do
            local K5 = v
            local KU_3 = Library.Unloaded
            if not KU_3 then
                local KV_2 = not i_
                if KV_2 ~= false then
                    KV_2 = not Toggles.AutoRainbowPets.Value
                end
                KU_3 = KV_2
            end
            if KU_3 then
                break
            end
            KU_4, KV_3 = pcall(function()
                return Network.Query("Make Rainbow", K5.amount, K5.uid)
            end)
            if KU_4 and KV_3 then
                KT_2 += K5.amount
            end
            local wait = task.wait
            local KV_4 = Options.RainbowDelay.Value or 1
            wait(KV_4)
        end
    end
    if KT_2 > 0 and Toggles.RainbowNotify.Value then
        Library:Notify(("Crafted %d Rainbow Bees"):format(KT_2))
    end
end
AN = {}
AH = function()
    local K9_1
    local K8_1
    for i = 1, Cl do
        local K7 = Library.Unloaded or not Toggles.AutoClaimGifts.Value
        local K7_1
        if K7 then
            return
        end
        local K6 = "Gift" .. i
        if not AN[K6] then
            K8_1, K7_1, K9_1 = pcall(function()
                return Network.Query("Claim Gift", K6)
            end)
            if K8_1 and K7_1 then
                AN[K6] = true
                if Toggles.GiftNotify.Value then
                    Library:Notify(("Claimed %s"):format(K6))
                end
            else
                if K8_1 and K9_1 == "You already claimed this gift!" then
                    AN[K6] = true
                end
            end
            task.wait(0.2)
        end
    end
end
BF = function()
    local Lj = Cc()
    if not Lj then
        return
    end
    for k, v in pairs(Lj.Items) do
        local Lp = k
        local Lr = v
        if Library.Unloaded or not Toggles.AutoOpenGiftItems.Value then
            return
        end
        local Lj_2 = Directory.Items[Lr.id]
        if Lj_2 and Lj_2.category == "PlaytimeGifts" then
            pcall(function()
                local Query = Network.Query
                local Lh = Lr.amount or 1
                Query("Open Pouche", Lp, Lh)
            end)
            task.wait(0.3)
        end
    end
end
CC = fns.fn1099
BO = fns.fn1446
AY = function()
    local LK = Cc()
    if not LK then
        return
    end
    for k, v in pairs(LK.Items) do
        local LQ = k
        local LK_1 = Directory.Items[v.id]
        local LL = LK_1 and LK_1.category == "Fruits"
        if LL then
            LL = (v.amount or 0) > 0
        end
        if LL then
            pcall(function()
                return Network.Query("Use Fruit", LQ, 1)
            end)
            return
        end
    end
end
Cd = function(kh)
    local LU = kh[1]
    local LT = kh[2]
    if LU == "Hives" then
        local LV_1 = type(LT) == "string" and Directory.Hives[LT]
        if LV_1 then
            local LV_2 = not Toggles.HiveTeleport.Value or BP(LT)
            if LV_2 then
                pcall(function()
                    return B2(LT, CE(LT))
                end)
            end
        else
            AG()
        end
    else
        local LV_3 = LU == "Hatch Bee"
        local LW = LU == "Hatch"
        local L_ = if LW then 1 else 0
        local LY = 431 * L_ + 3773 * (1 - L_)
        local LZ = 3046 * L_ + 2834 * (1 - L_)
        if not ((LY * 2026 + LZ * 1279 + LY * LZ) % 16777213 == 6081866) then
            LW = LV_3
        end
        if LW then
            AG()
        elseif LU == "Break Flowers" then
            local LW_1 = LT == "All" and "All Fields" or LT
            pcall(B5, LW_1, true)
        elseif LU == "Collect" then
            if LT == "Pollen" or LT == "Honey" then
                pcall(B5, "All Fields", true)
            end
        elseif LU == "Craft Neon" then
            onCraftNeonNow()
        elseif LU == "Craft Rainbow" then
            AX(true)
        elseif LU == "Eat Fruit" then
            AY()
        end
    end
end
CP = function()
    local L4_1
    local L3_1
    local L1_1
    local L2_2
    local L0 = BN(Options.QuestBearList.Value)
    local L0_2
    if #L0 == 0 then
        L0 = Bh
    end
    for i, v in ipairs(L0) do
        local Me = v
        if Library.Unloaded or not Toggles.AutoQuests.Value then
            return
        end
        L0_2, L1_1 = nil, nil
        local Mh = 1
        while Mh <= 6 do
            if Library.Unloaded or not Toggles.AutoQuests.Value then
                return
            end
            L2_2, L4_1, L3_1 = pcall(function()
                return Network.Query("Get Bear Quest Info", Me)
            end)
            if not L2_2 then
                break
            end
            L0_2, L1_1 = L4_1, L3_1
            if L4_1 == "finished" and Toggles.QuestNotify.Value then
                Library:Notify(("Claimed %s quest reward"):format(Me))
            end
            if L4_1 ~= "new" and L4_1 ~= "finished" then
                break
            end
            task.wait(0.2)
            Mh += 1
        end
        if L0_2 == "unfinished" and L1_1 then
            local L0_3 = CC(Me, L1_1)
            if L0_3 then
                for i, v in ipairs(L0_3) do
                    if Library.Unloaded or not Toggles.AutoQuests.Value then
                        return
                    end
                    local L0_5 = 0
                    while true do
                        local L1_2 = not BO(Me, i, v) and L0_5 < 25 and not Library.Unloaded and Toggles.AutoQuests.Value
                        if L1_2 then
                            Cd(v)
                            L0_5 += 1
                            task.wait(0.1)
                            continue
                        end
                        break
                    end
                    task.wait(0.2)
                end
            end
        end
        task.wait(0.2)
    end
end
Cq = {
    partner = nil,
    startedAt = 0,
    offerBuilt = false,
    offerBuiltAt = 0,
    readyRequestAt = 0,
    selfReady = false,
    otherReady = false,
    otherItems = {},
    otherHoney = 0,
    lastOtherOffer = "",
    lastRequestAt = -math.huge,
    requestsSent = 0,
    tradesCompleted = 0,
    tradesFailed = 0,
    itemsOffered = 0
}
if (not Cq and not CF and (Cq and BN) or (BX or not AA) and (BN and not CF)) and (BN and AA and (AA or not BN) or (not Cq or BN) and (not Cq and not AA)) or (AA or CF or (CF or CF) or (AA or BN) and (not Cq and AA) or ((not BJ or not BN) and (BJ and Cq) or (BN or Cq or CF and not BJ))) or not ((not Cq and not CF and (Cq and BN) or (BX or not AA) and (BN and not CF)) and (BN and AA and (AA or not BN) or (not Cq or BN) and (not Cq and not AA)) or (AA or CF or (CF or CF) or (AA or BN) and (not Cq and AA) or ((not BJ or not BN) and (BJ and Cq) or (BN or Cq or CF and not BJ)))) then
    BS = fn1498
else
    Cv = fn1498
end
Bm = fns.fn1466
CL = fns.fn125
if (AR and not AR or connection3 and AS or (AO or not connection3) and (Bm and AO)) and (not AA or AS or (AS or not Bm) or (not Bm and not AS or not AA and not connection3)) or not ((AR and not AR or connection3 and AS or (AO or not connection3) and (Bm and AO)) and (not AA or AS or (AS or not Bm) or (not Bm and not AS or not AA and not connection3))) then
    TP_9 = fn1527
    BU = fns.fn758
    A7 = fns.fn1313
    CB = fns.fn1137
    Cv = fns.fn1314
else
    BU = fn1527
    TP_9 = fns.fn758
    Cv = fns.fn1313
    A7 = fns.fn1137
    CB = fns.fn1314
end
BA = fns.fn1093
CO = fns.fn127
Bf = fns.fn1463
AR = fns.fn137
Cg = fns.fn1002
TP_6 = fns.fn1485
TP_25 = fn1488
AS = fns.fn575
CM = fns.fn289
BT = {}
BK = fns.fn201
Br = fns.fn1204
if (not BO or not connection10 or BO and AU or (not Bs or BO) and (Bs and TP_63)) and (not BO or not connection10 or (not AU or not Bs) or Label2 and Label2 and (not BO and not Label2)) or not ((not BO or not connection10 or BO and AU or (not Bs or BO) and (Bs and TP_63)) and (not BO or not connection10 or (not AU or not Bs) or Label2 and Label2 and (not BO and not Label2))) then
    AT = {}
    AE = fns.fn925
else
    AE = {}
    AT = fns.fn925
end
Cs = fns.fn16
Bb = fns.fn1298
AC = fn1551
onFly = function(ob)
    local connection
    local O7
    connection = nil
    O7 = nil
    local bodyGyro, bodyVelocity
    if not ob then
        AC()
        return
    end
    local O8 = CM()
    local O9 = AS()
    if not (O8 and O9) then
        return
    end
    AC()
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1000000000, 1000000000, 1000000000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = O8
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1000000000, 1000000000, 1000000000)
    bodyGyro.P = 9000
    bodyGyro.CFrame = O8.CFrame
    bodyGyro.Parent = O8
    BT[#BT + 1] = bodyVelocity
    BT[#BT + 1] = bodyGyro
    O9.PlatformStand = true
    O7 = {}
    connection6 = UserInputService.InputBegan:Connect(function(oo, op)
        if not op then
            O7[oo.KeyCode] = true
        end
    end)
    connection = UserInputService.InputEnded:Connect(function(ot)
        O7[ot.KeyCode] = nil
    end)
    BT[#BT + 1] = {
        Destroy = function()
            connection:Disconnect()
        end
    }
    connection5 = RunService.Heartbeat:Connect(function()
        local O0 = CM()
        local O1 = AS()
        if not (O0 and O1) or not bodyVelocity.Parent then
            return
        end
        O1.PlatformStand = true
        local CurrentCamera = workspace.CurrentCamera
        local O1_1 = Vector3.zero
        if O7[Enum.KeyCode.W] then
            O1_1 = O1_1 + CurrentCamera.CFrame.LookVector
        end
        if O7[Enum.KeyCode.S] then
            O1_1 = O1_1 - CurrentCamera.CFrame.LookVector
        end
        if O7[Enum.KeyCode.A] then
            O1_1 = O1_1 - CurrentCamera.CFrame.RightVector
        end
        if O7[Enum.KeyCode.D] then
            O1_1 = O1_1 + CurrentCamera.CFrame.RightVector
        end
        if O7[Enum.KeyCode.Space] then
            O1_1 = O1_1 + Vector3.yAxis
        end
        if O7[Enum.KeyCode.LeftControl] then
            O1_1 = O1_1 - Vector3.yAxis
        end
        if O1_1.Magnitude > 0 then
            O1_1 = O1_1.Unit * Options.FlySpeed.Value
        end
        bodyVelocity.Velocity = O1_1
        bodyGyro.CFrame = CurrentCamera.CFrame
    end)
end
TP_11 = {}
Be = nil
A9 = fns.fn1454
Cn = -0.3490658503988659
Ce = 1.3089969389957472
TP_24 = 1.0471975511965976
TP_12 = { uid = nil, cannon = nil, basePivot = nil, targets = {}, lastTargetAt = 0, enteredAt = 0 }
BX = fns.fn625
Bw = fns.fn139
AJ = fns.fn595
BY = fns.fn3
Bt = fns.fn570
A5 = fns.fn497
B8 = fns.fn1470
A1 = fns.fn382
AA = fns.fn1390
Cb = fns.fn1406
Bs = fns.fn157
CG = fns.fn743
A3 = fns.fn817
Window = Library:CreateWindow({
    Title = "Bee ReMasters",
    Footer = "Tempo Hub",
    Size = UDim2.fromOffset(900, 640),
    ShowCustomCursor = false,
    NotifySide = "Right"
})
local TP_30 = {
    Main = Window:AddTab("Main", "bug"),
    Trading = Window:AddTab("Trading", "arrow-right-left"),
    Player = Window:AddTab("Player", "user"),
    Settings = Window:AddTab("Settings", "settings")
}
TP_63 = fns.fn605
for k, v in TP_30 do
    TP_63(v)
end
TP_68 = TP_30.Main:AddLeftGroupbox("Auto Open Hives", "egg")
TP_68:AddDropdown("HiveList", {
    Values = TP_35,
    Default = "Basic Hive",
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Text = "Hives"
})
TP_68:AddLabel('Enter a number, or "max" to open the most your account can', true)
TP_68:AddInput("HiveAmount", { Text = "Hives Per Open", Default = "max", Placeholder = 'number or "max"' })
TP_68:AddSlider("HiveDelay", { Text = "Open Delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
TP_68:AddToggle("HiveTeleport", { Text = "Teleport To Hive", Default = false })
TP_68:AddToggle("HiveNotify", { Text = "Notify On Failure", Default = false })
TP_68:AddToggle("AutoOpenHives", { Text = "Auto Open Hives", Default = false })
TP_68:AddToggle("AutoOpenBestHives", { Text = "Auto Open Best Hives", Default = false })
TP_68:AddToggle("HideHatchAnimation", { Text = "Hide Hatch Animation", Default = false, Callback = Bc })
TP_68 = TP_30.Main:AddLeftGroupbox("Auto Use Fruits", "apple")
TP_68:AddDropdown("FruitList", { Values = TP_57, Multi = true, AllowNull = true, Searchable = true, Text = "Fruits" })
TP_68:AddToggle("FruitKeepActive", { Text = "Only When Expired", Default = true })
TP_68:AddSlider("FruitRefreshBelow", { Text = "Refresh Below", Default = 5, Min = 0, Max = 120, Rounding = 0, Suffix = "s" })
TP_68:AddSlider("FruitDelay", { Text = "Check Delay", Default = 2, Min = 1, Max = 30, Rounding = 0, Suffix = "s" })
TP_68:AddToggle("FruitNotify", { Text = "Notify On Use", Default = false })
TP_68:AddToggle("AutoUseFruits", { Text = "Auto Use Fruits", Default = false })
TP_68 = TP_30.Main:AddLeftGroupbox("Auto Use Pouches", "package-open")
TP_68:AddDropdown("PouchList", { Values = TP_7, Multi = true, AllowNull = true, Searchable = true, Text = "Pouches" })
TP_68:AddSlider("PouchDelay", { Text = "Open Delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
TP_68:AddSlider("PouchCheckDelay", { Text = "Check Delay", Default = 5, Min = 1, Max = 60, Rounding = 0, Suffix = "s" })
TP_68:AddToggle("PouchNotify", { Text = "Notify On Open", Default = true })
TP_68:AddToggle("AutoUsePouches", { Text = "Auto Use Pouches", Default = false })
TP_68:AddButton({ Text = "Open Pouches Now", Func = onOpenPouchesNow })
TP_68 = TP_30.Main:AddLeftGroupbox("Auto Neon Pets", "sparkles")
TP_68:AddDropdown("NeonBeeList", { Values = TP_71, Multi = true, AllowNull = true, Searchable = true, Text = "Bees" })
TP_68:AddDropdown("NeonRarityList", { Values = TP_60, Multi = true, AllowNull = true, Text = "Rarities" })
TP_68:AddSlider("NeonKeep", { Text = "Keep Per Bee", Default = 0, Min = 0, Max = 100, Rounding = 0 })
TP_68:AddSlider("NeonMaxPerBee", { Text = "Max Crafts Per Bee", Default = 0, Min = 0, Max = 100, Rounding = 0 })
TP_68:AddSlider("NeonDelay", { Text = "Craft Delay", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
TP_68:AddSlider("NeonCheckDelay", { Text = "Check Delay", Default = 5, Min = 1, Max = 60, Rounding = 0, Suffix = "s" })
TP_68:AddToggle("NeonBatch", { Text = "Craft All At Once", Default = true })
TP_68:AddToggle("NeonNotify", { Text = "Notify On Craft", Default = true })
TP_68:AddToggle("AutoNeonPets", { Text = "Auto Neon Pets", Default = false })
TP_68:AddButton({ Text = "Craft Neon Now", Func = onCraftNeonNow })
TP_68 = TP_30.Main:AddLeftGroupbox("Auto Rainbow Pets", "rainbow")
TP_68:AddDropdown("RainbowBeeList", { Values = TP_71, Multi = true, AllowNull = true, Searchable = true, Text = "Bees" })
TP_68:AddDropdown("RainbowRarityList", { Values = TP_60, Multi = true, AllowNull = true, Text = "Rarities" })
TP_68:AddSlider("RainbowKeep", { Text = "Keep Neon Per Bee", Default = 0, Min = 0, Max = 100, Rounding = 0 })
TP_68:AddSlider("RainbowMaxPerBee", { Text = "Max Crafts Per Bee", Default = 0, Min = 0, Max = 100, Rounding = 0 })
TP_68:AddSlider("RainbowDelay", { Text = "Craft Delay", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
TP_68:AddSlider("RainbowCheckDelay", { Text = "Check Delay", Default = 5, Min = 1, Max = 60, Rounding = 0, Suffix = "s" })
TP_68:AddToggle("RainbowBatch", { Text = "Craft All At Once", Default = true })
TP_68:AddToggle("RainbowNotify", { Text = "Notify On Craft", Default = true })
TP_68:AddToggle("AutoRainbowPets", { Text = "Auto Rainbow Pets", Default = false })
TP_68:AddButton({
    Text = "Craft Rainbow Now",
    Func = function()
        AX(true)
    end
})
TP_68 = TP_30.Main:AddRightGroupbox("Fast Farm", "wheat")
TP_68:AddDropdown("PowerFarmArea", { Values = TP_46, Default = "Auto (Best)", Multi = false, Searchable = true, Text = "Field" })
TP_68:AddSlider("PowerFarmHits", { Text = "Hits", Default = 3, Min = 1, Max = 10, Rounding = 0 })
TP_68:AddSlider("PowerFarmSpeed", { Text = "Speed", Default = 0.03, Min = 0.01, Max = 0.5, Rounding = 2, Suffix = "s" })
TP_68:AddToggle("PowerAutoFarm", { Text = "Auto Farm", Default = false })
TP_68 = TP_30.Main:AddRightGroupbox("Tentacle Event", "crosshair")
TP_68:AddDropdown("TentacleCannon", { Values = AA(), Default = "Auto (Nearest)", Multi = false, Searchable = true, Text = "Cannon" })
TP_68:AddButton({
    Text = "Refresh Cannons",
    Func = function()
        Options.TentacleCannon:SetValues(AA())
    end
})
TP_68:AddSlider("TentacleShootDelay", { Text = "Shoot Delay", Default = 0.15, Min = 0.05, Max = 2, Rounding = 2, Suffix = "s" })
TP_68:AddToggle("AutoStartTentacle", { Text = "Auto Start Tentacle Fight", Default = false })
TP_68:AddToggle("AutoShootTentacles", { Text = "Auto Shoot Tentacles", Default = false })
TP_68 = TP_30.Main:AddRightGroupbox("Zones", "map-pin")
TP_68:AddSlider("ZoneDelay", { Text = "Check Delay", Default = 3, Min = 1, Max = 30, Rounding = 0, Suffix = "s" })
TP_68:AddToggle("ZoneNotify", { Text = "Notify On Unlock", Default = true })
TP_68:AddToggle("AutoUnlockZones", { Text = "Auto Unlock Zones", Default = false })
TP_68:AddSlider("BestZoneDelay", { Text = "Best Zone Delay", Default = 0.3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
TP_68:AddToggle("AutoGoBestZone", { Text = "Auto Go To Best Owned Zone", Default = false })
TP_68:AddButton({ Text = "Teleport To Secret Area", Func = onTeleportToSecretArea })
TP_68:AddButton({ Text = "Teleport To Summer Secret Area", Func = onTeleportToSummerSecretArea })
TP_68 = TP_30.Main:AddRightGroupbox("Bees", "bug")
TP_68:AddSlider("EquipDelay", { Text = "Equip Delay", Default = 5, Min = 1, Max = 60, Rounding = 0, Suffix = "s" })
TP_68:AddToggle("AutoEquipBest", { Text = "Auto Equip Best Bees", Default = false })
TP_68 = TP_30.Main:AddRightGroupbox("Playtime Gifts", "gift")
TP_68:AddSlider("GiftDelay", { Text = "Check Delay", Default = 30, Min = 5, Max = 120, Rounding = 0, Suffix = "s" })
TP_68:AddToggle("GiftNotify", { Text = "Notify On Claim", Default = true })
TP_68:AddToggle("AutoClaimGifts", { Text = "Auto Claim Playtime Gifts", Default = false })
TP_68:AddToggle("AutoOpenGiftItems", { Text = "Auto Open Gift Items", Default = false })
TP_68 = TP_30.Main:AddRightGroupbox("Auto Complete Quests", "scroll-text")
TP_68:AddDropdown("QuestBearList", { Values = Bh, Multi = true, AllowNull = true, Searchable = true, Text = "Bears" })
TP_68:AddSlider("QuestDelay", { Text = "Check Delay", Default = 5, Min = 1, Max = 60, Rounding = 0, Suffix = "s" })
TP_68:AddToggle("QuestNotify", { Text = "Notify On Turn In", Default = true })
TP_68:AddToggle("AutoQuests", { Text = "Auto Complete Quests", Default = false })
TP_68 = TP_30.Main:AddRightGroupbox("Auto Rebirth", "repeat")
TP_68:AddSlider("RebirthDelay", { Text = "Check Delay", Default = 10, Min = 1, Max = 120, Rounding = 0, Suffix = "s" })
TP_68:AddToggle("RebirthNotify", { Text = "Notify On Rebirth", Default = true })
TP_68:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
TP_68:AddButton({ Text = "Rebirth Now", Func = BJ })
TP_68 = TP_30.Trading:AddLeftGroupbox("Players", "users")
TP_68:AddDropdown("TradePlayer", { Values = BS(), AllowNull = true, Searchable = true, Text = "Player" })
TP_68:AddButton({
    Text = "Refresh Player List",
    Func = function()
        Options.TradePlayer:SetValues(BS())
    end
})
TP_68:AddButton({
    Text = "Send Trade Request",
    Func = function()
        A7(TP_9(), true)
    end
})
TP_68:AddSlider("TradeRequestDelay", { Text = "Request Delay", Default = 20, Min = 20, Max = 120, Rounding = 0, Suffix = "s" })
TP_68:AddToggle("TradeAutoRequest", { Text = "Keep Requesting Selected Player", Default = false })
TP_68 = TP_30.Trading:AddLeftGroupbox("Incoming Requests", "inbox")
TP_68:AddToggle("TradeAutoAccept", { Text = "Auto Accept Trades", Default = false })
TP_68:AddDropdown("TradeAcceptMode", {
    Values = { "Off", "Everyone", "Friends Only", "Selected Player", "User List" },
    Default = "Everyone",
    Text = "Accept From"
})
TP_68:AddInput("TradeUserList", { Text = "Allowed Usernames", Default = "", Placeholder = "name1, name2" })
TP_68:AddSlider("TradeAcceptDelay", { Text = "Response Delay", Default = 1, Min = 0, Max = 10, Rounding = 1, Suffix = "s" })
TP_68:AddToggle("TradeAutoDecline", { Text = "Auto Decline Other Requests", Default = false })
TP_68 = TP_30.Trading:AddLeftGroupbox("Bee Offer", "bug")
TP_68:AddDropdown("TradeBeeList", {
    Values = TP_71,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Text = "Bee Names"
})
TP_68:AddDropdown("TradeBeeRarityList", { Values = TP_60, Default = {}, Multi = true, AllowNull = true, Text = "Bee Rarities" })
TP_68:AddDropdown("TradeBeeVariants", {
    Values = { "Normal", "Glossy", "Neon", "Rainbow" },
    Default = {},
    Multi = true,
    AllowNull = true,
    Text = "Bee Variants"
})
TP_68:AddToggle("TradeOfferBees", { Text = "Add Matching Bees", Default = false })
TP_68 = TP_30.Trading:AddLeftGroupbox("Item Offer", "package")
TP_68:AddDropdown("TradeItemList", {
    Values = TP_38,
    Default = {},
    Multi = true,
    AllowNull = true,
    Searchable = true,
    Text = "Item Names"
})
TP_68:AddDropdown("TradeItemRarityList", { Values = TP_27, Default = {}, Multi = true, AllowNull = true, Text = "Item Rarities" })
TP_68:AddToggle("TradeOfferItems", { Text = "Add Matching Items", Default = false })
TP_68 = TP_30.Trading:AddRightGroupbox("Offer Limits", "shield-check")
TP_68:AddSlider("TradeKeepAmount", { Text = "Keep From Every Stack", Default = 1, Min = 0, Max = 100, Rounding = 0 })
TP_68:AddSlider("TradeMaxPerStack", { Text = "Maximum Per Stack", Default = 1, Min = 0, Max = 1000000, Rounding = 0 })
TP_68:AddSlider("TradeMaxStacks", { Text = "Maximum Item Stacks", Default = 9, Min = 1, Max = 50, Rounding = 0 })
TP_68:AddInput("TradeHoneyAmount", { Text = "Honey To Offer", Default = "0", Numeric = true })
TP_68:AddSlider("TradeOfferDelay", { Text = "Wait Before Building Offer", Default = 1, Min = 0, Max = 10, Rounding = 1, Suffix = "s" })
TP_68:AddSlider("TradeItemDelay", { Text = "Delay Between Items", Default = 0.2, Min = 0.1, Max = 3, Rounding = 1, Suffix = "s" })
TP_68:AddToggle("TradeIncludePaidItems", { Text = "Allow Paid Items", Default = false })
TP_68:AddToggle("TradeAutoBuildOffer", { Text = "Auto Build Offer", Default = false })
TP_68:AddButton({ Text = "Build Offer Now", Func = CO })
TP_68 = TP_30.Trading:AddRightGroupbox("Ready Rules", "lock-keyhole")
TP_68:AddToggle("TradeAutoReady", { Text = "Auto Ready Trades", Default = false })
TP_68:AddToggle("TradeRequireOtherOffer", { Text = "Require Items From Other Player", Default = true })
TP_68:AddSlider("TradeMinimumOtherStacks", { Text = "Minimum Other Item Stacks", Default = 1, Min = 0, Max = 50, Rounding = 0 })
TP_68:AddSlider("TradeMinimumOtherAmount", { Text = "Minimum Other Total Items", Default = 1, Min = 0, Max = 1000, Rounding = 0 })
TP_68:AddInput("TradeMinimumOtherHoney", { Text = "Minimum Other Honey", Default = "0", Numeric = true })
TP_68:AddSlider("TradeReadyDelay", { Text = "Wait Before Ready", Default = 2, Min = 0, Max = 15, Rounding = 1, Suffix = "s" })
TP_68:AddToggle("TradeCancelChangedOffer", { Text = "Cancel If Ready Offer Changes", Default = true })
TP_68 = TP_30.Trading:AddRightGroupbox("Trade Status", "activity")
Label = TP_68:AddLabel("Status: Waiting for a trade", true)
Label2 = TP_68:AddLabel("Requests: 0 | Completed: 0 | Failed: 0", true)
TP_68:AddToggle("TradeNotify", { Text = "Trade Notifications", Default = true })
TP_68:AddButton({
    Text = "Cancel Current Trade",
    Func = function()
        Cg("Trade canceled")
    end
})
TP_68 = TP_30.Player:AddLeftGroupbox("Movement", "footprints")
TP_68:AddSlider("WalkSpeed", { Text = "Walkspeed", Default = 16, Min = 16, Max = 250, Rounding = 0 })
TP_68:AddToggle("WalkSpeedEnabled", { Text = "Walkspeed", Default = false, Callback = Br })
TP_68:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 500, Rounding = 0 })
TP_68:AddToggle("Fly", { Text = "Fly", Default = false, Callback = onFly })
TP_68:AddToggle("Noclip", { Text = "Noclip", Default = false, Callback = Cs })
TP_68:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false, Callback = Bb })
TP_68 = TP_30.Settings:AddLeftGroupbox("Menu", "menu")
TP_68:AddLabel("UI Keybind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "UI Keybind" })
BR = tick()
BL = tick()
BH = {}
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local RC = v
        pcall(function()
            RC:Disable()
            table.insert(BH, RC)
        end)
    end
end)
TP_26 = function()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    BL = tick()
end
connection7 = UserInputService.InputBegan:Connect(function()
    BR = tick()
end)
connection8 = UserInputService.InputChanged:Connect(function(r2)
    local UserInputType = r2.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        BR = tick()
    end
end)
TP_68:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local RI = tick() - BR
            local RJ = tick() - BL
            if RI >= 300 and RJ >= 60 then
                pcall(TP_26)
            else
                if RI < 300 and RJ >= 300 then
                    pcall(TP_26)
                end
            end
        end
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        task.wait(600)
        local RM = AS()
        if RM then
            RM:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
TP_68:AddToggle("AntiRejoin", { Text = "Anti Rejoin", Default = true })
TP_57 = hookmetamethod
local Bg = {
    Teleport = true,
    TeleportAsync = true,
    TeleportPartyAsync = true,
    TeleportToPlaceInstance = true,
    TeleportToPrivateServer = true,
    TeleportToSpawnByName = true
}
if TP_57 then
    TP_57 = getnamecallmethod
end
if TP_57 then
    pcall(function()
        local sl
        sl = hookmetamethod(game, "__namecall", function(sn, ...)
            local RP = getnamecallmethod()
            if not Library.Unloaded and Toggles.AntiRejoin.Value then
                if sn == TeleportService and Bg[RP] then
                    return nil
                end
                local RO = false
                if RP == "FireServer" then
                    pcall(function()
                        RO = sn:IsDescendantOf(ReplicatedStorage)
                    end)
                end
                if RP == "FireServer" and RO then
                    local RP_1 = select(1, ...)
                    if sn.Name == "IdleTeleport" or RP_1 == "IdleTeleport" then
                        return nil
                    end
                    return sl(sn, ...)
                end
                return sl(sn, ...)
            end
            return sl(sn, ...)
        end)
    end)
end
if hookfunction then
    for k in pairs(Bg) do
        local DV = k
        pcall(function()
            local RY
            RY = TeleportService[DV]
            local RZ = newcclosure
            local function R_(...)
                if not Library.Unloaded and Toggles.AntiRejoin.Value then
                    return nil
                end
                return RY(...)
            end
            if RZ then
                RZ = newcclosure(R_)
            end
            local R0 = RZ or R_
            hookfunction(RY, R0)
        end)
    end
end
TP_68:AddToggle("AutoHideUI", {
    Text = "Auto Hide UI",
    Default = false,
    Callback = function(sT)
        if sT then
            Window:Toggle(false)
        end
    end
})
TP_68:AddToggle("FpsBooster", { Text = "FPS Booster", Default = false, Callback = A9 })
TP_68:AddButton("Unload", function()
    Library:Unload()
end)
Library.ToggleKeybind = Options.MenuKeybind
connection9 = LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Library.Unloaded then
        return
    end
    if Toggles.Fly.Value then
        onFly(true)
    end
    if TP_12.uid then
        A1()
    end
end)
Library:OnUnload(function()
    Bc(false)
    A9(false)
    Br(false)
    Cs(false)
    Bb(false)
    AC()
    A1()
    connection9:Disconnect()
    connection7:Disconnect()
    connection8:Disconnect()
    for i, v in ipairs(BH) do
        local Sa = v
        pcall(function()
            Sa:Enable()
        end)
    end
    table.clear(BH)
    if connection10 then
        connection10:Disconnect()
        connection10 = nil
    end
    if connection11 then
        connection11:Disconnect()
        connection11 = nil
    end
    print("Bee ReMasters unloaded")
end)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/BeeReMasters")
SaveManager:BuildConfigSection(TP_30.Settings)
ThemeManager:ApplyToTab(TP_30.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
onPlayerAdded = function()
    if not Library.Unloaded and Options.TradePlayer then
        Options.TradePlayer:SetValues(BS())
    end
end
connection10 = Ay.PlayerAdded:Connect(onPlayerAdded)
connection11 = Ay.PlayerRemoving:Connect(function(tm)
    if Cq.partner == tm then
        Cq.partner = nil
    end
    task.defer(onPlayerAdded)
end)
Network.OnPacket("Trade Request", function(tp)
    if Library.Unloaded or not tp then
        return
    end
    local delay = task.delay
    local Sl_1 = Options.TradeAcceptDelay.Value or 1
    delay(Sl_1, function()
        if Library.Unloaded or not tp.Parent or Variables.Trading or Variables.OpeningHive > 0 then
            return
        end
        local Sh_1 = BU(tp)
        if Sh_1 and Toggles.TradeAutoAccept.Value then
            Cq.partner = tp
            Network.Send("Trade Response", tp, true)
            if Toggles.TradeNotify.Value then
                Library:Notify("Accepted trade from " .. tp.Name)
            end
        else
            local Si_1 = not Sh_1
            if Si_1 ~= false then
                Si_1 = Toggles.TradeAutoDecline.Value
            end
            if Si_1 then
                Network.Send("Trade Response", tp, false)
            end
        end
    end)
end)
Network.OnPacket("Trade Responded", function(tI, tJ)
    if Library.Unloaded then
        return
    end
    if tJ then
        Cq.partner = tI
        TP_6()
        Cq.startedAt = os.clock()
    end
end)
Network.OnPacket("Trade Started", function(tN, tO)
    if Library.Unloaded then
        return
    end
    if tN == LocalPlayer then
        Cq.partner = tO
    elseif tO == LocalPlayer then
        Cq.partner = tN
    end
    TP_6()
    Cq.startedAt = os.clock()
end)
Network.OnPacket("Other Offer Updated", function(tT)
    local Ss = Library.Unloaded or type(tT) ~= "table"
    if Ss then
        return
    end
    local Ss_1 = Bf(tT)
    local St = Cq.selfReady and Cq.lastOtherOffer ~= "" and Ss_1 ~= Cq.lastOtherOffer
    Cq.otherItems = table.clone(tT)
    Cq.lastOtherOffer = Ss_1
    if St and Toggles.TradeCancelChangedOffer.Value then
        Cg("Trade canceled because the other offer changed")
    end
end)
Network.OnPacket("Modify Honey", function(t3, t4)
    if Library.Unloaded or t3 == LocalPlayer.UserId then
        return
    end
    local Sw_1 = tonumber(tostring(t4):gsub(",", "")) or 0
    Cq.otherHoney = Sw_1
end)
Network.OnPacket("Trade Ready Sync", function(t9, ua)
    if Library.Unloaded then
        return
    end
    Cq.selfReady = t9 == true
    Cq.otherReady = ua == true
    if not Cq.selfReady then
        Cq.readyRequestAt = 0
    end
end)
Network.OnPacket("Trade Complete", function()
    if Library.Unloaded then
        return
    end
    Cq.tradesCompleted = Cq.tradesCompleted + 1
    TP_6()
    Cq.partner = nil
end)
Network.OnPacket("Trade Failed", function()
    if Library.Unloaded then
        return
    end
    Cq.tradesFailed = Cq.tradesFailed + 1
    TP_6()
    Cq.partner = nil
end)
Network.OnPacket("Close Trade", function()
    if Library.Unloaded then
        return
    end
    TP_6()
    Cq.partner = nil
end)
A8 = function(un)
    for k, v in pairs(TP_12.targets) do
        if v == un then
            TP_12.targets[k] = nil
            return
        end
    end
end
Network.OnPacket("Target Spawned", function(ur, us)
    local SP = Library.Unloaded or typeof(ur) ~= "string" or typeof(us) ~= "string"
    if SP then
        return
    end
    TP_12.targets[us] = ur
    TP_12.lastTargetAt = os.clock()
end)
Network.OnPacket("Target Despawned", function(uw)
    if typeof(uw) == "string" then
        A8(uw)
    end
end)
Network.OnPacket("Target Hit Confirmed", function(uy)
    if typeof(uy) == "string" then
        A8(uy)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Variables.Trading then
            if Cq.startedAt == 0 then
                Cq.startedAt = os.clock()
            end
            local ST = Toggles.TradeAutoBuildOffer.Value and not Cq.offerBuilt
            if ST then
                local SU_1 = os.clock() - Cq.startedAt
                ST = SU_1 >= (Options.TradeOfferDelay.Value or 1)
            end
            if ST then
                CO()
            end
            local ST_1 = Toggles.TradeAutoReady.Value and Cq.offerBuilt and not Cq.selfReady and Cq.readyRequestAt == 0 and AR()
            if ST_1 then
                local SU_2 = os.clock() - Cq.offerBuiltAt
                ST_1 = SU_2 >= (Options.TradeReadyDelay.Value or 2)
            end
            if ST_1 then
                Cq.readyRequestAt = os.clock()
                Network.Send("Trade Ready")
            end
        elseif Cq.startedAt ~= 0 then
            TP_6()
        end
        if Label then
            Label:SetText(TP_25())
        end
        if Label2 then
            Label2:SetText(("Requests: %d | Completed: %d | Failed: %d | Offered: %d"):format(Cq.requestsSent, Cq.tradesCompleted, Cq.tradesFailed, Cq.itemsOffered))
        end
        task.wait(0.25)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.TradeAutoRequest.Value and not Variables.Trading then
            A7(TP_9(), false)
        end
        local wait = task.wait
        local SY = Options.TradeRequestDelay.Value or 20
        wait(SY)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoOpenHives.Value then
            Bl()
        end
        if Toggles.AutoOpenBestHives.Value then
            AG()
        end
        local S0 = Options.HiveDelay.Value or 0.5
        task.wait(S0)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        Bu()
        task.wait(0.2)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoUnlockZones.Value then
            TP_3()
        end
        local S7 = Options.ZoneDelay.Value or 3
        task.wait(S7)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoGoBestZone.Value then
            AW()
        end
        local Ta = Options.BestZoneDelay.Value or 0.3
        task.wait(Ta)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoUsePouches.Value then
            onOpenPouchesNow()
        end
        local Td = Options.PouchCheckDelay.Value or 5
        task.wait(Td)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoRebirth.Value then
            BJ()
        end
        local Tg = Options.RebirthDelay.Value or 10
        task.wait(Tg)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.PowerAutoFarm.Value then
            B5()
        end
        local Tj = Options.PowerFarmSpeed.Value or 0.03
        task.wait(Tj)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoStartTentacle.Value then
            local Tl_1 = TP_12.uid and os.clock() - TP_12.lastTargetAt > 15 and os.clock() - TP_12.enteredAt > 15
            if Tl_1 then
                pcall(A1)
                task.wait(0.5)
            end
            pcall(Bs)
        else
            if not Toggles.AutoShootTentacles.Value and TP_12.uid then
                pcall(A1)
            end
        end
        task.wait(1)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoShootTentacles.Value then
            pcall(A3)
        end
        local To = Options.TentacleShootDelay.Value or 0.15
        task.wait(To)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoNeonPets.Value then
            onCraftNeonNow()
        end
        local Tr = Options.NeonCheckDelay.Value or 5
        task.wait(Tr)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoRainbowPets.Value then
            AX(false)
        end
        local Tu = Options.RainbowCheckDelay.Value or 5
        task.wait(Tu)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoEquipBest.Value then
            CF()
        end
        local Tx = Options.EquipDelay.Value or 5
        task.wait(Tx)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoUseFruits.Value then
            A2()
        end
        local TA = Options.FruitDelay.Value or 2
        task.wait(TA)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoClaimGifts.Value then
            AH()
        end
        if Toggles.AutoOpenGiftItems.Value then
            BF()
        end
        local TD = Options.GiftDelay.Value or 30
        task.wait(TD)
    end
end)
task.spawn(function()
    while not Library.Unloaded do
        if Toggles.AutoQuests.Value then
            CP()
        end
        local TG = Options.QuestDelay.Value or 5
        task.wait(TG)
    end
end)
Library:Notify("Bee ReMasters loaded")

end)(...)
