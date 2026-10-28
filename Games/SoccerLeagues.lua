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
local TeekUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))()
local UI = TeekUI.new({ Title = "TEMPO", Subtitle = "Soccer Leagues", Version = "v1" })
local BASE = "https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/Games/Soccer/"
local LEAGUES = {
	{ "VEF", "VEF" }, { "TSFL / ENI", "VRF" }, { "MPS 4 Side", "MPS4Side" }, { "MPS Futsal", "MPSFutsal" },
	{ "PSL", "PSL" }, { "CBM", "CBM" }, { "TRS", "TRS" }, { "TCS", "TCS" }, { "MMP", "MMP" }, { "OFA", "OFA" }, { "RF24", "RF24" },
}
local tab = UI:Tab("Leagues")
tab:Section("Pick your league")
for _, l in ipairs(LEAGUES) do
	tab:Button(l[1], false, function()
		local ok, src = pcall(game.HttpGet, game, BASE .. "Soccer" .. l[2] .. ".lua?t=" .. os.time())
		local f = ok and loadstring(src)
		if not f then UI:Notify("Couldn't load " .. l[1] .. ", try again", "bad") return end
		UI:Destroy()
		task.spawn(f)
	end)
end
tab:Label("Reach, radar, auto guard and more - each league has its own menu.")
