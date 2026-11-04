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
--  Tempo Hub - Roll an Anime (free)
--  Generated by port_backlog.py from the dev's source. Edit the
--  source + porter, not this file.
-- ============================================================
getgenv().TempoHoodSubtitle = "ROLL AN ANIME"
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
local eT
local eI
local eL
local eS
local eO
local eV
local eG
local eN
local eU
local CollectionService
local eQ
local eM
local function fn11()
    local Plots = workspace:FindFirstChild("Plots")
    local f2 = Plots and Plots:FindFirstChild(eS.Name .. "'s plot")
    local f1_1 = f2
    if f2 then
        f2 = f1_1:FindFirstChild("Items")
    end
    local f1_2 = f2
    if f2 then
        f2 = f1_2:GetChildren()
    end
    return f2 or {}
end
local function fn14(z)
    local fy = eL.Dice[z]
    if fy and fy.Order then
        return fy.Order
    end
    return 0
end
local function onAutoUpgradeAllUnits(a1)
    eT.autoUpgradeAllUnits = a1
end
local function onAutoCollectIndex(ba)
    eT.autoCollectIndex = ba
end
local function fn112()
    local fB = eV()
    local fC = fB
    local fD = {}
    if fC then
        fC = fB.Dice
    end
    if fC then
        for k, v in fB.Dice do
            local fB_1 = tonumber(v) or 0
            if fB_1 > 0 and eL.Dice[k] then
                fD[#fD + 1] = k
            end
        end
    end
    table.sort(fD, function(M, N)
        return eM(M) > eM(N)
    end)
    return fD
end
local function worker2()
    while task.wait(1) do
        if eQ.Unloaded then
            break
        end
        if eT.autoCollectIndex then
            pcall(function()
                eU:InvokeServer(eO.SPECIAL_UI, "ClaimAllIndexTrinkets")
            end)
        end
    end
end
local function onUpgradeTargets(bn)
    eT.upgradeTargets = bn
end
local function onAutoUpgrade(bl)
    eT.autoUpgrade = bl
end
local function onBuyTarget(bi)
    eT.buyTarget = bi
end
local function onAutoEquipBestDice(aZ)
    eT.autoEquipBestDice = aZ
end
local function fn174(m)
    local fv_1
    local fu_1
    fu_1, fv_1 = pcall(require, m)
    if fu_1 then
        return fv_1
    end
    return nil
end
local function onAutoBuyDice(bg)
    eT.autoBuyDice = bg
end
local function onSelUnits(a5)
    eT.selUnits = a5
end
local function onAutoUpgradeSelUnits(a3)
    eT.autoUpgradeSelUnits = a3
end
local function fn204()
    local fV = eI
    local fW = {}
    if fV then
        fV = eI.Items
    end
    if fV then
        for k in eI.Items do
            fW[#fW + 1] = k
        end
    end
    table.sort(fW)
    return fW
end
local function worker3()
    while task.wait(1) do
        if eQ.Unloaded then
            break
        end
        if eT.autoRebirth then
            pcall(function()
                eU:InvokeServer(eO.REBIRTH)
            end)
        end
    end
end
local function fn225()
    local Plots = workspace:FindFirstChild("Plots")
    local f6 = Plots and Plots:FindFirstChild(eS.Name .. "'s plot")
    local f6_1 = {}
    if f6 then
        for k, v in CollectionService:GetTagged("Podium") do
            local f7 = v.Parent and v.Parent.Parent == f6 and v:FindFirstChild("Collect")
            if f7 then
                f6_1[#f6_1 + 1] = v.Name
            end
        end
    end
    return f6_1
end
local function fn226()
    local fL = {}
    for k, v in eL.Dice do
        local fM = type(v) == "table"
        if fM then
            local fN = tonumber(v.Price) or 0
            fM = fN > 0
        end
        if fM then
            fM = not v.RobuxOnly
        end
        if fM then
            fM = not v.Hided
        end
        if fM then
            fL[#fL + 1] = k
        end
    end
    table.sort(fL, function(W, X)
        return eM(W) > eM(X)
    end)
    return fL
end
local function onAutoEquipBest(aX)
    eT.autoEquipBest = aX
end
local function onUnload()
    eQ:Unload()
end
local function fn238()
    if eG then
        return eG.GetData()
    end
    return nil
end
local function onJoinForAnimeRNGDupe()
    local gf = getgenv and getgenv()
    local gg = gf
    local gl = if gg then 1 else 0
    local gj = 686 * gl + 3965 * (1 - gl)
    local gk = 1717 * gl + 2108 * (1 - gl)
    if not ((gj * 3112 + gk * 2778 + gj * gk) % 16777213 == 8082520) then
        gg = _G
    end
    local gf_1 = rawget(gg, "setclipboard") or setclipboard or toclipboard
    if not gf_1 then
        gf_1 = syn and syn.write_clipboard
    end
    if not gf_1 then
        gf_1 = Clipboard and Clipboard.set
    end
    local gg_3 = false
    local gh = gf_1
    if gh then
        gg_3 = pcall(gh, eN)
    end
    local gg_4 = gg_3 and "Discord link copied to clipboard!" or "Clipboard unavailable: " .. eN
    eQ:Notify({ Title = "Roll Anime", Description = gg_4, Time = 5 })
end
local function onAutoRebirth(bq)
    eT.autoRebirth = bq
end
local function fn266()
    eT.autoSpin = false
    eT.autoEquipBest = false
    eT.autoEquipBestDice = false
    eT.autoUpgradeAllUnits = false
    eT.autoUpgradeSelUnits = false
    eT.autoCollect = false
    eT.autoCollectIndex = false
    eT.autoBuyDice = false
    eT.autoUpgrade = false
    eT.autoRebirth = false
end
local function onAutoSpin(aU)
    eT.autoSpin = aU
end
local function onAutoCollect(a8)
    eT.autoCollect = a8
end
local function worker()
    while task.wait(1) do
        if eQ.Unloaded then
            break
        end
        if eT.autoEquipBest then
            pcall(function()
                eU:InvokeServer(eO.EQUIP_BEST)
            end)
        end
    end
end
CollectionService = nil
eG = nil
eI = nil
eL = nil
eM = nil
eN = nil
eO = nil
eQ = nil
eS = nil
eT = nil
eU = nil
eV = nil
local eH, eJ, eK, eP, eR
local e3_1
local e2_1
local e1_1
local e0_1
local e__1
local eZ_1
local eY_1
eQ, e3_1, e2_1, eZ_1, eY_1, CollectionService, eS, eN, eU, eO, eL, e0_1, eI, eG, eH, e1_1, e__1, eV, eM, eR, eP = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local eX = 10
repeat
    local e4_1 = (eX * 11 + 2) % 14 + 1
    if e4_1 <= 7 then
        if e4_1 <= 4 then
            if e4_1 <= 2 then
                if e4_1 <= 1 then
                    local e5_1 = (vector.create((eX * 6 + 4) % 11 + 1, (eX * 2 + 11) % 13 + 1, (eX * 9 + 7) % 17 + 1))
                    local e6_1 = (vector.create((eX * 4 + 4) % 11 + 1, (eX * 8 + 4) % 13 + 1, (eX * 3 + 11) % 17 + 1))
                    local e7_1 = (vector.create((eX * 7 + 6) % 11 + 1, (eX * 6 + 7) % 13 + 1, (eX * 9 + 8) % 17 + 1))
                    if vector.dot(vector.cross(e5_1, e6_1), e7_1) == vector.dot(vector.cross(e6_1, e7_1), e5_1) then
                        eQ = getgenv().Library
                        e3_1 = getgenv().ThemeManager
                        e2_1 = getgenv().SaveManager
                    else
                        e2_1 = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
                        local _ = getgenv().Library
                        eQ = getgenv().ThemeManager
                        e3_1 = getgenv().SaveManager
                    end
                    eX = (eX + 23) % 112
                else
                    local e5_2 = {
                        "jnrjfwlf",
                        "tvknvw",
                        "sqci",
                        "xkzxpbyfmd",
                        "ctsurrjhpf",
                        "bhpxvef",
                        "ljouoaoqb",
                        "magyevp",
                        "idilnvenam"
                    }
                    if e5_2[(eX * 10 + 56) % 9 + 1] <= e5_2[(eX * 10 + 56) % 9 + 1] then
                        eZ_1 = game:GetService("Players")
                    else
                        eN = game:GetService("Players")
                    end
                    eX = (eX + 51) % 112
                end
            elseif e4_1 <= 3 then
                if (not e0_1 and eR and (eQ and not eZ_1) or e2_1 and e2_1 and (not e2_1 and e2_1)) and ((eR or eZ_1) and (e2_1 and eR) and (not eR or not eQ or (eQ or eQ))) or ((not e2_1 or eQ or not eR and not e0_1) and ((not eQ or not eZ_1) and (eQ or not eZ_1)) or (e2_1 and not e0_1 and (e0_1 or e0_1) or (e0_1 and e0_1 or (not e2_1 or not eR)))) or not ((not e0_1 and eR and (eQ and not eZ_1) or e2_1 and e2_1 and (not e2_1 and e2_1)) and ((eR or eZ_1) and (e2_1 and eR) and (not eR or not eQ or (eQ or eQ))) or ((not e2_1 or eQ or not eR and not e0_1) and ((not eQ or not eZ_1) and (eQ or not eZ_1)) or (e2_1 and not e0_1 and (e0_1 or e0_1) or (e0_1 and e0_1 or (not e2_1 or not eR))))) then
                    eY_1 = game:GetService("ReplicatedStorage")
                else
                    eH = game:GetService("ReplicatedStorage")
                end
                eX = (eX + 23) % 112
            else
                if (eX * 1 + 1) * 9 % 4 == ((eX * 1 + 1) * 9 + 15) % 4 then
                    eH = game:GetService("CollectionService")
                else
                    CollectionService = game:GetService("CollectionService")
                end
                eX = (eX + 93) % 112
            end
        elseif e4_1 <= 6 then
            if e4_1 <= 5 then
                if eX * 40288559 + 13 + 4 >= eX * 40288559 + 13 + 4 + 2 then
                    eZ_1 = eS.LocalPlayer
                else
                    eS = eZ_1.LocalPlayer
                end
                eX = (eX + 65) % 112
            else
                local e5_3 = (vector.create((eX * 3 + 5) % 11 + 1, (eX * 11 + 2) % 13 + 1, (eX * 3 + 6) % 17 + 1))
                local e6_2 = (vector.create((eX * 7 + 8) % 11 + 1, (eX * 4 + 9) % 13 + 1, (eX * 6 + 17) % 17 + 1))
                local e7_2 = (vector.create((eX * 1 + 1) % 5 + 1, (eX * 2 + 7) % 7 + 1, (eX * 5 + 4) % 9 + 1))
                if math.abs((vector.angle(e5_3, e6_2, e7_2))) - math.abs((vector.angle(e6_2, e5_3, e7_2))) == 0 then
                    eN = "https://discord.gg/K7Qxnxkk46"
                else
                    e2_1 = "https://discord.gg/K7Qxnxkk46"
                end
                eX = (eX + 107) % 112
            end
        else
            local e5_4 = (vector.create((eX * 2 + 5) % 11 + 1, (eX * 3 + 11) % 13 + 1, (eX * 13 + 3) % 17 + 1))
            local e6_3 = (vector.create((eX * 3 + 7) % 11 + 1, (eX * 6 + 13) % 13 + 1, (eX * 2 + 12) % 17 + 1))
            local e7_3 = (vector.create((eX * 1 + 7) % 11 + 1, (eX * 2 + 2) % 13 + 1, (eX * 12 + 13) % 17 + 1))
            local e8_1 = (vector.create((eX * 3 + 8) % 11 + 1, (eX * 3 + 12) % 13 + 1, (eX * 2 + 2) % 17 + 1))
            if vector.dot(vector.cross(e5_4, e6_3), (vector.cross(e7_3, e8_1))) == vector.dot(e5_4, e7_3) * vector.dot(e6_3, e8_1) - vector.dot(e5_4, e8_1) * vector.dot(e6_3, e7_3) + 1 then
                e0_1 = fn174
            else
                e__1 = fn174
            end
            eX = (eX + 65) % 112
        end
    elseif e4_1 <= 11 then
        if e4_1 <= 9 then
            if e4_1 <= 8 then
                if eX * 123585215 + 9 + 7 >= eX * 123585215 + 9 + 7 + 6 then
                    eL = eO(e__1.Shared.Utils.Network)
                    eY_1 = eO(e__1.Shared.Constants.Remotes)
                    eU = eO(e__1.Shared.Config.DiceConfig)
                else
                    eU = e__1(eY_1.Shared.Utils.Network)
                    eO = e__1(eY_1.Shared.Constants.Remotes)
                    eL = e__1(eY_1.Shared.Config.DiceConfig)
                end
                eX = (eX + 23) % 112
            else
                if eX * 81336909 + 11 + 7 >= eX * 81336909 + 11 + 7 + 2 then
                    eY_1 = e0_1(e__1.Shared.Config.UpgradesConfig)
                else
                    e0_1 = e__1(eY_1.Shared.Config.UpgradesConfig)
                end
                eX = (eX + 93) % 112
            end
        elseif e4_1 <= 10 then
            local e5_5 = (vector.create((eX * 2 + 1) % 11 + 1, (eX * 1 + 9) % 13 + 1, (eX * 4 + 5) % 17 + 1))
            local e6_4 = (vector.create((eX * 1 + 2) % 11 + 1, (eX * 5 + 8) % 13 + 1, (eX * 10 + 15) % 17 + 1))
            local e7_4 = (vector.create((eX * 5 + 2) % 11 + 1, (eX * 11 + 4) % 13 + 1, (eX * 9 + 12) % 17 + 1))
            if vector.dot(vector.cross(e5_5, e6_4), e7_4) == vector.dot(vector.cross(e6_4, e7_4), e5_5) then
                eI = e__1(eY_1.Shared.Config.ItemsConfig)
                eG = e__1(eS.PlayerScripts.Manager.ClientDataManager)
                eV = fn238
            else
                eG = eI(e__1.Shared.Config.ItemsConfig)
                eY_1 = eI(eV.PlayerScripts.Manager.ClientDataManager)
                eS = fn238
            end
            eX = (eX + 107) % 112
        else
            if eX * 98600689 + 11 + 5 >= eX * 98600689 + 11 + 5 + 1 then
                eO = fn14
            else
                eM = fn14
            end
            eX = (eX + 65) % 112
        end
    elseif e4_1 <= 13 then
        if e4_1 <= 12 then
            local e4_2 = (vector.create((eX * 2 + 7) % 11 + 1, (eX * 8 + 10) % 13 + 1, (eX * 13 + 1) % 17 + 1))
            local e5_6 = (vector.create((eX * 4 + 8) % 11 + 1, (eX * 1 + 5) % 13 + 1, (eX * 6 + 4) % 17 + 1))
            local hF = vector.cross(e4_2, e5_6)
            local hG = vector.dot(e4_2, e5_6)
            if vector.dot(hF, hF) + hG * hG == vector.dot(e4_2, e4_2) * vector.dot(e5_6, e5_6) then
                eR = fn112
            else
                eP = fn112
            end
            eX = (eX + 107) % 112
        else
            if eX * 73853661 + 9 + 7 <= eX * 73853661 + 9 + 7 + 1 then
                eP = fn226
            else
                eQ = fn226
            end
            eX = (eX + 37) % 112
        end
    else
        local hE = bit32.rrotate(bit32.bxor(bit32.lrotate(eX, 6), string.byte(tostring(eZ_1))), 8)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(hE, 4021193545), 3144813537), (bit32.bxor(bit32.band(hE, 273773750), 4086306628))), 3144813537), 4086306628) == hE then
            eH = {}
            e1_1 = {}
        else
            e1_1 = {}
            eH = {}
        end
        eX = (eX + 107) % 112
    end
until (eX * 37 + 59) % 112 == 107
if e0_1 then
    for k, v in e0_1 do
        local eW_1 = type(v) == "table" and v.DisplayName
        local eX_1 = eW_1 or k
        eH[eX_1] = k
        e1_1[#e1_1 + 1] = eX_1
    end
end
eT, eK, eJ = nil, nil, nil
table.sort(e1_1)
eK = fn11
eJ = fn225
eT = {
    autoSpin = false,
    autoEquipBest = false,
    autoEquipBestDice = false,
    autoUpgradeAllUnits = false,
    autoUpgradeSelUnits = false,
    selUnits = {},
    autoCollect = false,
    autoCollectIndex = false,
    autoBuyDice = false,
    buyTarget = "All",
    autoRebirth = false,
    autoUpgrade = false,
    upgradeTargets = {}
}
local Window = eQ:CreateWindow({ Title = "Tempo Hub", Footer = "Roll Anime", Icon = 18657887261, NotifySide = "Right" })
eQ.ShowCustomCursor = false
local e0_2 = {
    Main = Window:AddTab("Main", "dices"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings")
}
for k, v in e0_2 do
    local CommunityGroup = v:AddLeftGroupbox("Community")
    CommunityGroup:AddButton("Join for Anime RNG Dupe", onJoinForAnimeRNGDupe)
end
local AutoSpinGroup = e0_2.Main:AddLeftGroupbox("Auto Spin")
AutoSpinGroup:AddToggle("AutoSpin", { Text = "Enable Auto Spin", Default = false, Callback = onAutoSpin })
local AutoEquipGroup = e0_2.Main:AddLeftGroupbox("Auto Equip")
AutoEquipGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false, Callback = onAutoEquipBest })
AutoEquipGroup:AddToggle("AutoEquipBestDice", { Text = "Auto Equip Best Owned Dice", Default = false, Callback = onAutoEquipBestDice })
local AutoUpgradeUnitsGroup = e0_2.Main:AddLeftGroupbox("Auto Upgrade Units")
AutoUpgradeUnitsGroup:AddToggle("AutoUpgradeAllUnits", { Text = "Auto Upgrade All Placed Units", Default = false, Callback = onAutoUpgradeAllUnits })
AutoUpgradeUnitsGroup:AddToggle("AutoUpgradeSelUnits", { Text = "Auto Upgrade Selected Units", Default = false, Callback = onAutoUpgradeSelUnits })
AutoUpgradeUnitsGroup:AddDropdown("SelUnits", { Values = fn204(), Default = {}, Multi = true, Text = "Units", Callback = onSelUnits })
local AutoCollectGroup = e0_2.Main:AddLeftGroupbox("Auto Collect")
AutoCollectGroup:AddToggle("AutoCollect", { Text = "Auto Collect Money", Default = false, Callback = onAutoCollect })
AutoCollectGroup:AddToggle("AutoCollectIndex", { Text = "Auto Collect Index", Default = false, Callback = onAutoCollectIndex })
local AutoBuyDiceGroup = e0_2.Main:AddRightGroupbox("Auto Buy Dice")
local e7_5 = { "All" }
for k, v in eP() do
    e7_5[#e7_5 + 1] = v
end
AutoBuyDiceGroup:AddToggle("AutoBuyDice", { Text = "Enable Auto Buy Dice", Default = false, Callback = onAutoBuyDice })
AutoBuyDiceGroup:AddDropdown("BuyTarget", { Values = e7_5, Default = "All", Multi = false, Text = "Dice to Buy", Callback = onBuyTarget })
local AutoUpgradesGroup = e0_2.Main:AddRightGroupbox("Auto Upgrades")
AutoUpgradesGroup:AddToggle("AutoUpgrade", { Text = "Enable Auto Purchase Upgrades", Default = false, Callback = onAutoUpgrade })
AutoUpgradesGroup:AddDropdown("UpgradeTargets", { Values = e1_1, Default = {}, Multi = true, Text = "Upgrades", Callback = onUpgradeTargets })
local AutoRebirthGroup = e0_2.Main:AddRightGroupbox("Auto Rebirth")
AutoRebirthGroup:AddToggle("AutoRebirth", { Text = "Enable Auto Rebirth", Default = false, Callback = onAutoRebirth })
task.spawn(function()
    local gt_1
    local gs_1
    local gr_1
    local go = 0.25
    local gx = false
    repeat
        local gn
        if task.wait(go) then
            if eQ.Unloaded then
                gx = true
            else
                go = 0.25
                if eT.autoSpin then
                    local gp = eV()
                    local gp_2
                    local gq = gp and gp.ActiveDice
                    local gq_1
                    local gm = gq
                    if gm and eL.Dice[gm] then
                        gq_1, gs_1, gr_1, gp_2, gn, gt_1 = pcall(function()
                            return eU:InvokeServer(eO.ROLL, gm)
                        end)
                        if not gq_1 then
                            go = 0.75
                        elseif type(gs_1) == "table" then
                            if gn then
                                task.delay(0.2, function()
                                    pcall(function()
                                        eU:FireServer(eO.ROLL_FINISHED, gn)
                                    end)
                                end)
                            end
                        else
                            if gs_1 == nil and (gr_1 == 1 or gr_1 == 2) then
                                local max = math.max
                                local gq_4 = tonumber(gt_1) or 0.75
                                go = max(gq_4, 0) + 0.05
                            end
                        end
                    end
                end
            end
        else
            gx = true
        end
    until gx
end)
task.spawn(worker)
task.spawn(worker2)
task.spawn(function()
    local gF = false
    repeat
        if task.wait(1) then
            if eQ.Unloaded then
                gF = true
            elseif eT.autoEquipBestDice then
                local gB = eR()
                local gA = gB[1]
                local gB_1 = eV()
                if gA and gB_1 and gB_1.ActiveDice ~= gA then
                    pcall(function()
                        eU:FireServer(eO.SWITCH_DICE, gA)
                    end)
                end
            end
        else
            gF = true
        end
    until gF
end)
task.spawn(function()
    while task.wait(1) do
        if eQ.Unloaded then
            break
        end
        if eT.autoUpgradeAllUnits or eT.autoUpgradeSelUnits then
            for k, v in eK() do
                local gR = v
                if eQ.Unloaded then
                    break
                end
                if not (eT.autoUpgradeAllUnits or eT.autoUpgradeSelUnits) then
                    break
                else
                    local gG_2 = gR:GetAttribute("Level") or 0
                    local attr2 = gR:GetAttribute("MaxLevel")
                    local attr = gR:GetAttribute("ItemName")
                    local gJ = eT.autoUpgradeAllUnits or eT.autoUpgradeSelUnits and attr ~= nil and eT.selUnits[attr]
                    if gJ then
                        gJ = attr2 == nil or gG_2 < attr2
                    end
                    if gJ then
                        pcall(function()
                            eU:InvokeServer(eO.ANIME_UPGRADE, gR.Name, true)
                        end)
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(1) do
        if eQ.Unloaded then
            break
        end
        if eT.autoCollect then
            for k, v in eJ() do
                local gZ = v
                if eQ.Unloaded or not eT.autoCollect then
                    break
                end
                pcall(function()
                    eU:FireServer(eO.COLLECT, gZ)
                end)
            end
        end
    end
end)
task.spawn(function()
    local g__1
    while task.wait(0.5) do
        if eQ.Unloaded then
            break
        end
        if eT.autoBuyDice then
            if eT.buyTarget == "All" or eT.buyTarget == nil then
                g__1 = eP()
            else
                g__1 = { eT.buyTarget }
            end
            for k, v in g__1 do
                local ha = v
                if eQ.Unloaded or not eT.autoBuyDice then
                    break
                end
                pcall(function()
                    eU:InvokeServer(eO.BUY, eL.StockName, ha, true)
                end)
            end
        end
    end
end)
task.spawn(function()
    while task.wait(0.5) do
        if eQ.Unloaded then
            break
        end
        if eT.autoUpgrade then
            for k in eT.upgradeTargets do
                local hb = eH[k]
                if eQ.Unloaded or not eT.autoUpgrade then
                    break
                elseif hb then
                    pcall(function()
                        eU:InvokeServer(eO.UPGRADE, hb)
                    end)
                end
            end
        end
    end
end)
task.spawn(worker3)
local MenuGroup = e0_2["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("UI Toggle"):AddKeyPicker("MenuKeybind", { Default = "RightShift", Text = "UI Toggle", Mode = "Toggle", NoUI = true })
MenuGroup:AddButton("Unload", onUnload)
eQ.ToggleKeybind = eQ.Options.MenuKeybind
e3_1:SetLibrary(eQ)
e2_1:SetLibrary(eQ)
e3_1:SetFolder("TempoHub")
e2_1:SetFolder("TempoHub/roll-anime")
e2_1:IgnoreThemeSettings()
e2_1:SetIgnoreIndexes({ "MenuKeybind" })
e3_1:SaveDefault("Mint")
e3_1:ApplyToTab(e0_2["UI Settings"])
e3_1:LoadDefault()
e2_1:BuildConfigSection(e0_2["UI Settings"])
e2_1:LoadAutoloadConfig()
eQ:OnUnload(fn266)
eQ:Notify({
    Title = "Roll Anime",
    Description = "Loaded. Auto Spin uses your currently equipped dice.",
    Time = 5
})

end)(...)
