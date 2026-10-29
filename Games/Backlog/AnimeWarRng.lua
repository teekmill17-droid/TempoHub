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
local TeekUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/teekmill17-droid/TempoHub/main/dev/TempoUI.lua"))()
getgenv().TempoHoodSubtitle = "ANIME WAR RNG"
do
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local HttpService = game:GetService("HttpService")
	local Toggles, Options = {}, {}
	getgenv().Toggles, getgenv().Options = Toggles, Options
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
	local function loose(t)
		return setmetatable(t, { __index = function(_, k) if type(k) == "string" and string.find(k, "^%u") then return function() return Stub end end end })
	end
	lenient(Library)
	local Policy = getgenv().TempoUIPolicy or {}
	local HIDE, HIDEG = Policy.hide or {}, Policy.hideGroups or {}
	for _, n in ipairs({ "Discord", "Socials", "Tempo Hub", "Donations", "Donate", "Community",
		"Account", "User", "Game Info", "Basic Info", "Player Info", "Credits", "Support", "Links", "Scripts", "Features" }) do
		if HIDEG[n] == nil then HIDEG[n] = true end
	end
	local HIDE_TABS = { Info = true, Information = true, Credits = true, Donate = true, Donations = true, Socials = true, About = true }
	local function brandButton(text)
		local s = string.lower(tostring(text or ""))
		if string.find(s, "webhook", 1, true) then return false end
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
			if w ~= lw then return w end
			if i > 1 and SMALL[lw] then return lw end
			return lw:sub(1, 1):upper() .. lw:sub(2)
		end))
	end
	local function titleOf(idx, text) return RENAME[idx] or tidy(text or idx) end
	local Dummy = setmetatable({}, { __index = function() return function() return nil end end })
	local groups = {}
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
		if isMethod(k) then return function() return Stub end end
	end
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
		local order = {}
		for _, t in ipairs(Library._wtabs or {}) do
			order[#order + 1] = t
			for _, k in ipairs(t.kids) do order[#order + 1] = k end
		end
		for _, t in ipairs(order) do
			for _, g in ipairs(t.boxes) do drawBox(g) end
		end
		for _, t in ipairs(order) do
			local w = rawget(t, "w")
			if w then pcall(function() w.flowed = false w:_flow() end) end
		end
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
	function Groupbox:_rawFor(idx)
		if self.hidden or HIDE[idx] then return Dummy, true end
		self.n += 1
		return self.raw, false
	end
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
		function kp:OnChanged(fn) table.insert(self._changed, fn) end
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
		if type(text) == "table" then idx = wrap text = text.Text end
		if type(wrap) == "string" then idx = wrap end
		local lb = lenient({ Type = "Label", Text = text, _group = self })
		if type(idx) == "string" then Options[idx] = lb end
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
	local Tab = {}
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
		if isMethod(k) then return function() return Stub end end
	end
	function Window:AddTab(name)
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
	local SaveManager = lenient({ folder = "TempoHub/games", ignore = {} })
	SaveManager.Ignore = SaveManager.ignore
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
		if type(tab) == "table" and rawget(tab, "_t") then tab = rawget(tab, "_t") end
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
		return g
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
	local ThemeManager = lenient({ Library = Library })
	function ThemeManager:SetLibrary() end
	function ThemeManager:SetFolder() end
	function Library._mountInterface()
		if Library._interface or not Library.ui then return end
		Library._interface = true
		pcall(function() Library.ui:mountInterface(Library.ui:Tab("Interface", "sliders")) end)
	end
	function ThemeManager:ApplyToTab(tab)
		Library._wantInterface = true
		if flushed then Library._mountInterface() end
	end
	ThemeManager.BuildInterfaceSection = ThemeManager.ApplyToTab
	getgenv().ThemeManager = ThemeManager
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
	RBox.AddToggle, RBox.AddSlider, RBox.AddDropdown, RBox.AddButton = RBox.CreateToggle, RBox.CreateSlider, RBox.CreateDropdown, RBox.CreateButton
	local function rtab(t, flavor)
		local o = { _t = t }
		function o:CreateSection(name)
			if type(name) == "table" then name = pick(name, "Name", "name") end
			rawset(self, "_box", rbox(t:AddLeftGroupbox(tostring(name or t.name)), flavor))
			return Stub
		end
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
local qs_2, qs_4, qs_5, qs_6, qs_7, qs_8, qs_10, qs_11, ItemsSync, qs_13, qs_15, qs_16, qs_19, qs_20, qs_22, qs_23
local ko
local k6
local Options
local kO
local kv
local VirtualUser
local kb
local kU
local kB
local li
local kh
local kH
local lo
local kn
local k5
local RequestRewards
local kN
local kt
local lb
local ka
local kT
local kA
local lh
local kg
local kZ
local kG
local ln
local km
local k4
local j3
local kM
local ks
local la
local j9
local LocalPlayer
local kz
local UserInputService
local kf
local RequestTreeUpgrades
local kF
local lm
local connection2
local j2
local kL
local kr
local k9
local Toggles
local kR
local ky
local Label
local ke
local kX
local kE
local RequestUseItem
local kk
local k2
local kK
local kq
local k8
local j7
local kQ
local kx
local le
local SaveManager
local Workspace
local connection
local lk
local kj
local k1
local RewardDefs
local lq
local Library
local HttpService
local j6
local kP
local kw
local ld
local RequestClaimPlaytime
local kV
local RebirthConfig
local lj
local ki
local RequestBuyTreeNode
local kI
local lp
function fns.onRscripts()
    j3(kB, "Copied Rscripts profile to clipboard")
end
function fns.fn28()
    kf:FireServer()
end
function fns.worker()
    local ob_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local oa = math.floor(os.clock() - kP)
        if oa < 60 then
            ob_1 = oa .. "s"
        elseif oa < 3600 then
            ob_1 = string.format("%dm %ds", math.floor((oa) / (60)), oa % 60)
        else
            ob_1 = string.format("%dh %dm", math.floor((oa) / (3600)), math.floor((oa % 3600) / (60)))
        end
        Label:SetText(kV("Session time", ob_1, k8))
    end
end
function fns.fn98()
    for k in li do
        local nf = tonumber(kZ[k]) or 0
        if nf > 0 then
            RequestUseItem:FireServer(k, nf)
        end
    end
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local ov_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if ov_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.onInputChanged(fd)
    local UserInputType = fd.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        lq = tick()
    end
end
function fns.onCopyVenmoLink()
    j3(ke, "Copied Venmo link")
end
function fns.onRenderStepped(ey)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local oL_1 = km()
        if oL_1 then
            oL_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local oL_3 = kA()
        local oM = km()
        kb = Workspace.CurrentCamera or kb
        if oL_3 and oM and kb then
            oM.PlatformStand = true
            local oM_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                oM_1 = oM_1 + kb.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                oM_1 = oM_1 - kb.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                oM_1 = oM_1 - kb.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                oM_1 = oM_1 + kb.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                oM_1 = oM_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                oM_1 = oM_1 - Vector3.new(0, 1, 0)
            end
            oL_3.Velocity = Vector3.zero
            if oM_1.Magnitude > 0 then
                oL_3.CFrame = oL_3.CFrame + oM_1.Unit * Options.FlySpeed.Value * ey
            end
        end
    end
end
function fns.onCopyBitcoinAddress()
    j3(ks, "Copied Bitcoin address")
end
function fns.onCopyEthereumAddress()
    j3(kq, "Copied Ethereum address")
end
function fns.onCopyUSDTAddress()
    j3(kn, "Copied USDT address")
end
function fns.autoClaimPlaytimeLoop()
    while not Library.Unloaded do
        if Toggles.AutoClaimPlaytime.Value then
            pcall(kw)
        end
        if Toggles.AutoClaimRewards.Value then
            pcall(lk)
        end
        if Toggles.AutoClaimQuests.Value then
            pcall(kX)
        end
        if Toggles.AutoClaimBattlepass.Value then
            pcall(kQ)
        end
        task.wait(2)
    end
end
function fns.onOnClientEvent7(c6)
    if type(c6) ~= "table" then
        return
    end
    local reqId = c6.reqId
    if reqId and kt[reqId] then
        kt[reqId] = nil
        if not c6.error then
            kr:FireServer({ reqId = reqId })
        end
    end
end
function fns.antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            kL(true)
        end
    end
end
function fns.onInputBegan()
    lq = tick()
end
function fns.onCopyLitecoinAddress()
    j3(kv, "Copied Litecoin address")
end
function fns.onImportConfigFromClipboardTex()
    local p2_1
    local p0 = Options.SaveManager_ImportSource.Value or ""
    local p0_1
    local p1 = tostring(p0):match("^%s*(.-)%s*$")
    if p1 == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    p0_1, p2_1 = pcall(HttpService.JSONDecode, HttpService, p1)
    local p1_1 = not p0_1 or type(p2_1) ~= "table" or type(p2_1.objects) ~= "table"
    if p1_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local p0_2 = 0
    for i, v in ipairs(p2_1.objects) do
        if ln(v) then
            p0_2 += 1
        end
    end
    if p0_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local p2_2 = p0_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(p0_2, p2_2), 6)
end
local function fn322()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    lm = tick()
end
local function onExportConfigToClipboard()
    local pV_1
    local pU_1
    pU_1, pV_1 = pcall(HttpService.JSONEncode, HttpService, kF())
    if not pU_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local pU_2 = setclipboard or toclipboard
    local pU_3 = type(pU_2) ~= "function" or not pcall(pU_2, pV_1)
    if pU_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function onOnClientEvent5(c_)
    if type(c_) ~= "table" then
        return
    end
    kO = c_
    if type(c_.Gold) == "number" then
        la = c_.Gold
    end
    if type(c_.Gems) == "number" then
        k5 = c_.Gems
    end
end
local function fn375(fq, fr)
    local ph = fq == "Toggle" and Toggles
    local pm = if ph then 1 else 0
    local pk = 981 * pm + 2035 * (1 - pm)
    local pl = 3837 * pm + 1850 * (1 - pm)
    if not ((pk * 1348 + pl * 2812 + pk * pl) % 16777213 == 15876129) then
        ph = Options
    end
    local ph_1 = ph[fr]
    local pg_2 = type(ph_1) == "table" and ph_1.Type == fq
    return pg_2 and ph_1 or nil
end
local function autoClaimPlaytimeLoop2()
    while not Library.Unloaded do
        task.wait(8)
        if Library.Unloaded then
            break
        end
        if Toggles.AutoClaimPlaytime.Value or Toggles.AutoClaimRewards.Value then
            pcall(function()
                RequestRewards:FireServer()
            end)
        end
        if Toggles.AutoClaimQuests.Value then
            pcall(function()
                lp:FireServer()
            end)
        end
        if Toggles.AutoClaimBattlepass.Value then
            pcall(function()
                k4:FireServer()
            end)
        end
        if Toggles.AutoBuyNodes.Value then
            pcall(function()
                RequestTreeUpgrades:FireServer()
            end)
        end
        if Toggles.AutoUsePackages.Value then
            pcall(function()
                lh:FireServer()
            end)
        end
        if Toggles.AutoRebirth.Value then
            pcall(function()
                kj:FireServer()
            end)
        end
    end
end
local function fn403(a7, a8, a9)
    return string.format("<b>%s</b> %s %s", a7, k6("-", "#5a6070"), k6(a8, a9))
end
local function autoEquipBestLoop()
    while not Library.Unloaded do
        if Toggles.AutoEquipBest.Value then
            pcall(kI)
        end
        task.wait(3)
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local oG_1 = km()
        if oG_1 then
            oG_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onOnClientEvent4(cX)
    if type(cX) ~= "table" then
        return
    end
    kT = cX
    kR = os.clock()
end
local function fn474(a4, a5)
    return string.format('<font color="%s">%s</font>', a5, a4)
end
local function fn496()
    connection:Disconnect()
    connection2:Disconnect()
    kL(false)
    local pe = km()
    if pe then
        pe.PlatformStand = false
        pe.WalkSpeed = 16
    end
end
local function fn508()
    j3(kH, "Copied Discord invite to clipboard")
end
local function fn511()
    if not kT then
        RequestRewards:FireServer()
        return
    end
    local Playtime = kT.Playtime
    if type(Playtime) ~= "table" then
        return
    end
    local Claimed = Playtime.Claimed
    local m0 = Playtime.Seconds
    local m5 = if m0 then 1 else 0
    local m3 = 3810 * m5 + 3110 * (1 - m5)
    local m4 = 3677 * m5 + 1675 * (1 - m5)
    if not ((m3 * 1294 + m4 * 3574 + m3 * m4) % 16777213 == 15303895) then
        m0 = 0
    end
    local mZ_1 = m0 + (os.clock() - kR)
    for i, v in ipairs(RewardDefs.Playtime) do
        if not kh(Claimed, i) then
            if (v.Minutes or 0) * 60 <= mZ_1 then
                RequestClaimPlaytime:FireServer(i)
            end
        end
    end
end
local function onCopyPayPalLink()
    j3(kg, "Copied PayPal link")
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local qm = tick() - lq
            local qn = tick() - lm
            if qm >= 300 and qn >= 60 then
                pcall(k1)
            else
                if qm < 300 and qn >= 300 then
                    pcall(k1)
                end
            end
        end
    end
end
local function fn522()
    j2:FireServer()
end
local function fn527()
    k9:FireServer()
end
local function onUnload()
    Library:Unload()
end
local function fn542(bp)
    if not bp or bp.Hidden or bp.Id == nil then
        return false
    elseif ka(bp.Id) then
        return false
    elseif not kN.IsReachable(bp) then
        return false
    else
        local mw_1 = bp.Parent and not ka(bp.Parent)
        if mw_1 then
            return false
        end
        local mw_2 = kN.Shortfalls(bp, { Gold = la, Gems = k5, TotalRolls = k2 })
        local mx = type(mw_2) ~= "table"
        local mE = if mx then 1 else 0
        local mC = 704 * mE + 1625 * (1 - mE)
        local mD = 4046 * mE + 367 * (1 - mE)
        if not ((mC * 2083 + mD * 2651 + mC * mD) % 16777213 == 15040762) then
            mx = #mw_2 == 0
        end
        return mx
    end
end
local function fn547()
    local Character = LocalPlayer.Character
    local mp = Character and Character:FindFirstChild("HumanoidRootPart")
    return mp
end
local function onPackageTypes(d5)
    local od = {}
    for k, v in d5 do
        if v then
            local oe = ky[k]
            if oe then
                od[oe] = true
            end
        end
    end
    li = od
end
local function onOnClientEvent(cI)
    if type(cI) ~= "table" then
        return
    end
    if type(cI.Owned) == "table" then
        le = cI.Owned
    end
    if type(cI.Gold) == "number" then
        la = cI.Gold
    end
    if type(cI.Gems) == "number" then
        k5 = cI.Gems
    end
    if type(cI.TotalRolls) == "number" then
        k2 = cI.TotalRolls
    end
end
local function onCopyJoinScript_JobID()
    local dx = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, lb)
    j3(dx, "Copied join script to clipboard")
end
local function fn590()
    local Character = LocalPlayer.Character
    local ms = Character and Character:FindFirstChildOfClass("Humanoid")
    return ms
end
local function onOnClientEvent3(cR)
    local nJ = type(cR) ~= "table" or type(cR.Items) ~= "table"
    if nJ then
        return
    end
    table.clear(kZ)
    for k, v in cR.Items do
        local nJ_1 = type(k) == "string" and type(v) == "number" and v > 0
        if nJ_1 then
            kZ[k] = v
        end
    end
end
local function fn635()
    local n6_1
    local n5_1
    if identifyexecutor then
        n6_1, n5_1 = identifyexecutor()
        local n7 = n6_1 ~= ""
        local n8 = type(n6_1) == "string" and n7
        if n8 then
            local n7_1 = type(n5_1) == "string" and n5_1 ~= "" and n6_1 .. " " .. n5_1
            j9 = n7_1 or n6_1
        end
    end
end
local function fn637()
    kL(Toggles.AntiGameplayPause.Value)
end
local function fn669()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
local function fn692()
    if not Toggles.WalkSpeedEnabled.Value then
        local ot = km()
        if ot then
            ot.WalkSpeed = 16
        end
    end
end
local function autoRollLoop()
    while not Library.Unloaded do
        if Toggles.AutoRoll.Value then
            pcall(j6)
        end
        task.wait(0.5)
    end
end
local function fn706()
    if kM >= kE then
        return
    end
    kz += 1
    local mQ = kz
    kt[mQ] = true
    kx:FireServer({ auto = true, reqId = mQ })
end
local function fn722()
    local np = {}
    for i, v in ipairs(kN.Nodes) do
        if lo(v) then
            np[#np + 1] = v
        end
    end
    table.sort(np, function(cy, cz)
        local nm = kG(cy)
        local nn = kG(cz)
        if nm ~= nn then
            return nm < nn
        end
        return tostring(cy.Id) < tostring(cz.Id)
    end)
    local nq = 0
    for i, v in ipairs(np) do
        if nq >= 3 then
            break
        end
        RequestBuyTreeNode:FireServer(v.Id)
        nq += 1
    end
end
local function onOnClientEvent2(cN)
    if type(cN) ~= "table" then
        return
    end
    if type(cN.Gold) == "number" then
        la = cN.Gold
    end
    if type(cN.Gems) == "number" then
        k5 = cN.Gems
    end
    if kO then
        if type(cN.Gold) == "number" then
            kO.Gold = cN.Gold
        end
        if type(cN.Gems) == "number" then
            kO.Gems = cN.Gems
        end
    end
end
local function fn742()
    if not kT then
        RequestRewards:FireServer()
        return
    end
    local Daily = kT.Daily
    local nd = type(Daily) == "table" and Daily.CanClaim
    if nd then
        j7:FireServer()
    end
end
local function autoRebirthLoop()
    while not Library.Unloaded do
        if Toggles.AutoRebirth.Value then
            pcall(ld)
        end
        task.wait(2)
    end
end
local function fn788(bA)
    local mF = 0
    for i, v in ipairs(kN.SpendCosts(bA)) do
        if v.Currency == "Gold" then
            local mG_1 = v.Amount or 0
            mF += mG_1
        elseif v.Currency == "Gems" then
            local mG_2 = v.Amount or 0
            mF += mG_2 * 1000000
        end
    end
    return mF
end
local function fn807()
    local pu = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local pv = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if pv then
                local pv_1 = kU(k, v)
                if pv_1 then
                    pu[#pu + 1] = pv_1
                end
            end
        end
    end
    table.sort(pu, function(fN, fO)
        if fN.type ~= fO.type then
            return fN.type < fO.type
        end
        return fN.idx < fO.idx
    end)
    return { objects = pu }
end
local function onCopySolanaAddress()
    j3(ki, "Copied Solana address")
end
local function fn827(de)
    local DiscordGroup = de:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = lj })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = lj })
end
local function autoUsePackagesLoop()
    while not Library.Unloaded do
        if Toggles.AutoUsePackages.Value then
            pcall(kK)
        end
        task.wait(1)
    end
end
local function fn842(fy, fz)
    local Type = fz.Type
    if Type == "Toggle" then
        return { idx = fy, type = "Toggle", value = fz.Value == true }
    elseif Type == "Slider" then
        return { idx = fy, type = "Slider", value = tostring(fz.Value) }
    elseif Type == "Dropdown" then
        return { idx = fy, type = "Dropdown", multi = fz.Multi == true, value = fz.Value }
    elseif Type == "Input" then
        local po = fz.Value or ""
        return { idx = fy, type = "Input", text = tostring(po) }
    elseif Type == "ColorPicker" then
        return { idx = fy, type = "ColorPicker", value = fz.Value:ToHex(), transparency = fz.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = fy,
            type = "KeyPicker",
            mode = fz.Mode,
            key = fz.Value,
            modifiers = fz.Modifiers,
            toggled = fz.Toggled
        }
    else
        return nil
    end
end
local function fn870(bk)
    local mu = le[bk] == true or kN.IsTabRoot(bk)
    return mu
end
local function fn872(bG, bH)
    if type(bG) ~= "table" then
        return false
    end
    local mO = bG[bH] == true or bG[tostring(bH)] == true
    return mO
end
local function autoBuyNodesLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyNodes.Value then
            pcall(kk)
        end
        task.wait(0.4)
    end
end
local function fn908(aY, aZ)
    if setclipboard then
        setclipboard(aY)
    elseif toclipboard then
        toclipboard(aY)
    end
    Library:Notify(aZ)
end
local function onOnClientEvent6(c3)
    if type(c3) ~= "table" then
        return
    end
    if type(c3.Entries) == "table" then
        kM = #c3.Entries
    end
    if type(c3.Cap) == "number" then
        kE = c3.Cap
    end
end
local function fn968()
    if not Toggles.Fly.Value then
        local om = km()
        if om then
            om.PlatformStand = false
        end
    end
end
local function fn975()
    if not kO then
        kj:FireServer()
        return
    end
    local mS = tonumber(kO.Rebirths) or 0
    local mS_1 = RebirthConfig.GetRequirement(mS)
    if not mS_1 then
        return
    end
    if kO.MapEligible ~= true then
        return
    end
    local mT_1 = tonumber(kO.Gems) or k5
    local mU = mT_1
    local mY = if mU then 1 else 0
    local mW = 343 * mY + 2736 * (1 - mY)
    local mX = 253 * mY + 522 * (1 - mY)
    if not ((mW * 523 + mX * 275 + mW * mX) % 16777213 == 335743) then
        mU = 0
    end
    if mU < (mS_1.GemCost or 0) then
        return
    end
    ko:FireServer()
end
j2 = nil
j3 = nil
RequestRewards = nil
Options = nil
j6 = nil
j7 = nil
Toggles = nil
j9 = nil
ka = nil
kb = nil
RequestClaimPlaytime = nil
SaveManager = nil
ke = nil
kf = nil
kg = nil
kh = nil
ki = nil
kj = nil
kk = nil
connection2 = nil
km = nil
kn = nil
ko = nil
Library = nil
kq = nil
kr = nil
ks = nil
kt = nil
kv = nil
kw = nil
kx = nil
ky = nil
kz = nil
kA = nil
kB = nil
RebirthConfig = nil
connection = nil
kE = nil
kF = nil
kG = nil
kH = nil
kI = nil
RewardDefs = nil
kK = nil
kL = nil
kM = nil
kN = nil
kO = nil
kP = nil
kQ = nil
kR = nil
LocalPlayer = nil
kT = nil
kU = nil
kV = nil
Workspace = nil
kX = nil
RequestTreeUpgrades = nil
kZ = nil
RequestBuyTreeNode = nil
k1 = nil
k2 = nil
k4 = nil
k5 = nil
k6 = nil
HttpService = nil
k8 = nil
k9 = nil
la = nil
lb = nil
VirtualUser = nil
ld = nil
le = nil
Label = nil
UserInputService = nil
lh = nil
li = nil
lj = nil
lk = nil
RequestUseItem = nil
lm = nil
ln = nil
lo = nil
lp = nil
lq = nil
local CoreGui, GuiService, lr
CoreGui = nil
GuiService = nil
lr = nil
local lL, lM, lN, lO, lP, lQ, lR, lS, lT, lU, lV, lW, lX, lY
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, LocalPlayer = nil, nil, nil, nil, nil, nil, nil
local qs_1 = game:GetService("Players")
local qs_18 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
LocalPlayer = qs_1.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
lO, kH, kB, kv, ks, kq, kn, ki, kg, ke, lM, lL, qs_15, qs_6, qs_22, lT, lS, lR, lQ, k8, lP, qs_20, qs_11, qs_8, qs_5, kN, RewardDefs, RebirthConfig, kx, qs_16, kr, ko, kj, qs_7, kf, RequestClaimPlaytime, j7, RequestRewards, qs_23, j2, lp, RequestUseItem, lh, ItemsSync, k9, k4, RequestBuyTreeNode, RequestTreeUpgrades, qs_4, qs_19, qs_10, qs_2, lN, ky, qs_13 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
qs_1 = 79
repeat
    lU = (qs_1 * 13 + 19) % 24 + 1
    if lU <= 12 then
        if lU <= 6 then
            if lU <= 3 then
                if lU <= 2 then
                    if lU <= 1 then
                        lV = { "cstj", "iuktcvqqo", "yixtwpvq", "nfhbwcgnzxg", "uezcnxyiyh", "jlzcrsde", "qdc", "uwivlogxito" }
                        if lV[(qs_1 * 19 + 101) % 8 + 1] <= lV[(qs_1 * 19 + 101) % 8 + 1] then
                            qs_5 = require(qs_11:WaitForChild("ItemDefs"))
                        else
                            qs_11 = require(qs_5:WaitForChild("ItemDefs"))
                        end
                        qs_1 = (qs_1 + 85) % 192
                    else
                        if (not kx or kB) and (kr or RewardDefs) or (not kB or kv) and (kr and not RebirthConfig) or not ((not kx or kB) and (kr or RewardDefs) or (not kB or kv) and (kr and not RebirthConfig)) then
                            kN = require(qs_11:WaitForChild("UpgradeTreeDefs"))
                            RewardDefs = require(qs_11:WaitForChild("RewardDefs"))
                            RebirthConfig = require(qs_11:WaitForChild("RebirthConfig"))
                            kx = qs_8:WaitForChild("RequestRoll")
                        else
                            kx = require(RewardDefs:WaitForChild("UpgradeTreeDefs"))
                            qs_8 = require(RewardDefs:WaitForChild("RewardDefs"))
                            qs_11 = require(RewardDefs:WaitForChild("RebirthConfig"))
                            kN = RebirthConfig:WaitForChild("RequestRoll")
                        end
                        qs_1 = (qs_1 + 85) % 192
                    end
                else
                    if (qs_1 * 2 + 8) * 16 % 3 == ((qs_1 * 2 + 8) * 16 + 8) % 3 then
                        kr = qs_16:WaitForChild("RollResult")
                        kj = qs_16:WaitForChild("RollRevealed")
                        qs_7 = qs_16:WaitForChild("RequestRebirth")
                        qs_8 = qs_16:WaitForChild("RequestRebirthSync")
                        ko = qs_16:WaitForChild("RebirthSync")
                    else
                        qs_16 = qs_8:WaitForChild("RollResult")
                        kr = qs_8:WaitForChild("RollRevealed")
                        ko = qs_8:WaitForChild("RequestRebirth")
                        kj = qs_8:WaitForChild("RequestRebirthSync")
                        qs_7 = qs_8:WaitForChild("RebirthSync")
                    end
                    qs_1 = (qs_1 + 13) % 192
                end
            elseif lU <= 5 then
                if lU <= 4 then
                    lV = { "rwohs", "dvtpm", "ynovywu", "evcxmtvg", "bwkpxzp", "gtahn", "guwfnm" }
                    local qS = qs_1
                    lW = lV[qS % 7 + 1]
                    if lW:len() <= lW:gsub("(.)", "%1%1", qS % 3 % 2 + 1):len() then
                        kf = qs_8:WaitForChild("RequestEquipBest")
                        RequestClaimPlaytime = qs_8:WaitForChild("RequestClaimPlaytime")
                        j7 = qs_8:WaitForChild("RequestClaimDaily")
                    else
                        j7 = RequestClaimPlaytime:WaitForChild("RequestEquipBest")
                        kf = RequestClaimPlaytime:WaitForChild("RequestClaimPlaytime")
                        qs_8 = RequestClaimPlaytime:WaitForChild("RequestClaimDaily")
                    end
                    qs_1 = (qs_1 + 109) % 192
                else
                    if (not ky or not ky or (not lP or not qs_11) or (lO or not qs_7) and (lO and ky)) and (lP and lT or not lT and not lP or (lT or not qs_11 or lO and qs_11)) and ((not qs_7 or not ky) and (qs_11 and not lO) and (not lO or lO or (not ky or qs_11)) and ((qs_7 or not ky or (qs_11 or lT)) and (not lP and lP or (not lP or qs_7)))) or not ((not ky or not ky or (not lP or not qs_11) or (lO or not qs_7) and (lO and ky)) and (lP and lT or not lT and not lP or (lT or not qs_11 or lO and qs_11)) and ((not qs_7 or not ky) and (qs_11 and not lO) and (not lO or lO or (not ky or qs_11)) and ((qs_7 or not ky or (qs_11 or lT)) and (not lP and lP or (not lP or qs_7))))) then
                        RequestRewards = qs_8:WaitForChild("RequestRewards")
                    else
                        qs_8 = RequestRewards:WaitForChild("RequestRewards")
                    end
                    qs_1 = (qs_1 + 157) % 192
                end
            else
                if kH and kx and (not ki and not lR) and (not kx and not kH or (not kH or kx)) or (kH or lR) and (not kH and not lR) and (not lR and not ki or kH and not kx) or not (kH and kx and (not ki and not lR) and (not kx and not kH or (not kH or kx)) or (kH or lR) and (not kH and not lR) and (not lR and not ki or kH and not kx)) then
                    qs_23 = qs_8:WaitForChild("RewardsSync")
                    j2 = qs_8:WaitForChild("RequestClaimAll")
                    lp = qs_8:WaitForChild("RequestQuests")
                    RequestUseItem = qs_8:WaitForChild("RequestUseItem")
                    lh = qs_8:WaitForChild("RequestItems")
                else
                    j2 = RequestUseItem:WaitForChild("RewardsSync")
                    lh = RequestUseItem:WaitForChild("RequestClaimAll")
                    qs_8 = RequestUseItem:WaitForChild("RequestQuests")
                    lp = RequestUseItem:WaitForChild("RequestUseItem")
                    qs_23 = RequestUseItem:WaitForChild("RequestItems")
                end
                qs_1 = (qs_1 + 181) % 192
            end
        elseif lU <= 9 then
            if lU <= 8 then
                if lU <= 7 then
                    local q7 = bit32.rrotate(bit32.bxor(bit32.lrotate(qs_1, 31), string.byte(tostring(RequestRewards))), 11)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(q7, 1700907638), 28), 1716919463) == bit32.lrotate(q7, 28) then
                        ItemsSync = qs_8:WaitForChild("ItemsSync")
                    else
                        qs_8 = ItemsSync:WaitForChild("ItemsSync")
                    end
                    qs_1 = (qs_1 + 157) % 192
                else
                    lV = (vector.create((qs_1 * 3 + 1) % 11 + 1, (qs_1 * 4 + 13) % 13 + 1, (qs_1 * 3 + 4) % 17 + 1))
                    lW = (vector.create((qs_1 * 7 + 2) % 11 + 1, (qs_1 * 6 + 6) % 13 + 1, (qs_1 * 4 + 1) % 17 + 1))
                    local rj = vector.cross(lV, lW)
                    local rk = vector.dot(lV, lW)
                    if vector.dot(rj, rj) + rk * rk == vector.dot(lV, lV) * vector.dot(lW, lW) then
                        k9 = qs_8:WaitForChild("RequestClaimAllBattlePass")
                        k4 = qs_8:WaitForChild("RequestBattlePass")
                        RequestBuyTreeNode = qs_8:WaitForChild("RequestBuyTreeNode")
                    else
                        qs_8 = RequestBuyTreeNode:WaitForChild("RequestClaimAllBattlePass")
                        k9 = RequestBuyTreeNode:WaitForChild("RequestBattlePass")
                        k4 = RequestBuyTreeNode:WaitForChild("RequestBuyTreeNode")
                    end
                    qs_1 = (qs_1 + 37) % 192
                end
            else
                if (qs_1 and kn or (not lR or not qs_1)) and (not lT and not lp and (not lp and not lR)) or (kn and lp or lR and qs_1) and (not qs_1 and kn and (kB or not lT)) or not ((qs_1 and kn or (not lR or not qs_1)) and (not lT and not lp and (not lp and not lR)) or (kn and lp or lR and qs_1) and (not qs_1 and kn and (kB or not lT))) then
                    RequestTreeUpgrades = qs_8:WaitForChild("RequestTreeUpgrades")
                else
                    qs_8 = RequestTreeUpgrades:WaitForChild("RequestTreeUpgrades")
                end
                qs_1 = (qs_1 + 61) % 192
            end
        elseif lU <= 11 then
            if lU <= 10 then
                if (qs_1 * 2 + 2) * 4 % 3 == ((qs_1 * 2 + 2) * 4 + 0) % 3 then
                    qs_4 = qs_8:WaitForChild("TreeSync")
                    qs_19 = qs_8:WaitForChild("StatsSync")
                    qs_10 = qs_8:WaitForChild("RequestInventory")
                else
                    qs_8 = qs_10:WaitForChild("TreeSync")
                    qs_4 = qs_10:WaitForChild("StatsSync")
                    qs_19 = qs_10:WaitForChild("RequestInventory")
                end
                qs_1 = (qs_1 + 157) % 192
            else
                if qs_1 * 16481707 + 13 + 3 >= qs_1 * 16481707 + 13 + 3 + 1 then
                    qs_8 = qs_2:WaitForChild("InventorySync")
                else
                    qs_2 = qs_8:WaitForChild("InventorySync")
                end
                qs_1 = (qs_1 + 61) % 192
            end
        else
            lV = (vector.create((qs_1 * 6 + 8) % 11 + 1, (qs_1 * 3 + 6) % 13 + 1, (qs_1 * 2 + 14) % 17 + 1))
            local re = vector.floor(lV) + vector.ceil(lV * -1)
            if vector.dot(re, re) == 2 then
                qs_23 = {}
            else
                lN = {}
            end
            qs_1 = (qs_1 + 85) % 192
        end
    elseif lU <= 18 then
        if lU <= 15 then
            if lU <= 14 then
                if lU <= 13 then
                    local rp = bit32.rrotate(bit32.bxor(bit32.lrotate(qs_1, 24), string.byte(tostring(kj))), 30)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(rp, 4166345363), 452863208), (bit32.bxor(bit32.band(rp, 128621932), 1747642138))), 452863208), 1747642138) ~= rp then
                        kn = {}
                    else
                        ky = {}
                    end
                    qs_1 = (qs_1 + 109) % 192
                else
                    lV = {
                        "kut",
                        "gcssw",
                        "ypfhcz",
                        "yirtkylpz",
                        "lirjq",
                        "ydvsdisu",
                        "zzeitb",
                        "twlicdc",
                        "igtdkkvul",
                        "rkprfra",
                        "jwhaezkuacnj",
                        "hgnaalcbapyd",
                        "xqd",
                        "wbyhhmxfh",
                        "fxjs",
                        "vxfp"
                    }
                    if lV[(qs_1 * 29 + 31) % 16 + 1] <= lV[(qs_1 * 29 + 31) % 16 + 1] then
                        qs_13 = {}
                    else
                        qs_11 = {}
                    end
                    qs_1 = (qs_1 + 61) % 192
                end
            else
                lV = {
                    "ytzqbz",
                    "xwplnd",
                    "okwqkip",
                    "zlhag",
                    "uteptphzhu",
                    "mylzedxygo",
                    "hvf",
                    "iqda",
                    "yjxwemjwu",
                    "hzkq",
                    "tuqlqfcs"
                }
                if lV[(qs_1 * 92 + 15) % 11 + 1] < lV[(qs_1 * 92 + 15) % 11 + 1] then
                    kH = "Anime War RNG"
                    lO = "https://discord.gg/K7Qxnxkk46"
                else
                    lO = "Anime War RNG"
                    kH = "https://discord.gg/K7Qxnxkk46"
                end
                qs_1 = (qs_1 + 181) % 192
            end
        elseif lU <= 17 then
            if lU <= 16 then
                if qs_1 * 53658385 + 1 + 3 <= qs_1 * 53658385 + 1 + 3 + 1 then
                    kB = "https://discord.gg/K7Qxnxkk46"
                    kv = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
                else
                    kv = "https://discord.gg/K7Qxnxkk46"
                    kB = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
                end
                qs_1 = (qs_1 + 133) % 192
            else
                local ri = bit32.rrotate(bit32.bxor(bit32.lrotate(qs_1, 17), string.byte(tostring(lh))), 3)
                if bit32.bxor(bit32.lrotate(bit32.bxor(ri, 1759513263), 16), 179267808) ~= bit32.lrotate(ri, 16) then
                    kn = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
                    ks = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                    kq = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                else
                    ks = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
                    kq = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                    kn = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
                end
                qs_1 = (qs_1 + 37) % 192
            end
        else
            if (kg and kg or kg and not qs_7) and (qs_7 or qs_7 or kj and not kg) and not ((kg and kg or kg and not qs_7) and (qs_7 or qs_7 or kj and not kg)) then
                lL = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
                ke = ""
                kg = ""
                ki = "#345d9d"
                lM = "#f7931a"
            else
                ki = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
                kg = ""
                ke = ""
                lM = "#345d9d"
                lL = "#f7931a"
            end
            qs_1 = (qs_1 + 157) % 192
        end
    elseif lU <= 21 then
        if lU <= 20 then
            if lU <= 19 then
                lV = {
                    "ftggqoevt",
                    "hehlidq",
                    "hgbfxohgza",
                    "sklpvxlz",
                    "ijilgceutjf",
                    "ifpplqd",
                    "lqxhdwg",
                    "rdmhtoyn",
                    "fiepzlsaq",
                    "glxk",
                    "vedmy"
                }
                local rl = qs_1
                lW = lV[rl % 11 + 1]
                if lW:len() <= lW:reverse():rep(rl % 3 + 2):len() then
                    qs_15 = "#627eea"
                    qs_6 = "#26a17b"
                else
                    qs_6 = "#627eea"
                    qs_15 = "#26a17b"
                end
                qs_1 = (qs_1 + 13) % 192
            else
                lV = (vector.create((qs_1 * 4 + 5) % 11 + 1, (qs_1 * 9 + 11) % 13 + 1, (qs_1 * 15 + 11) % 17 + 1))
                lW = (vector.create((qs_1 * 1 + 4) % 11 + 1, (qs_1 * 1 + 5) % 13 + 1, (qs_1 * 8 + 13) % 17 + 1))
                lX = (vector.create((qs_1 * 6 + 2) % 11 + 1, (qs_1 * 1 + 1) % 13 + 1, (qs_1 * 10 + 8) % 17 + 1))
                lY = (vector.create((qs_1 * 2 + 2) % 5 + 1, (qs_1 * 1 + 3) % 7 + 1, (qs_1 * 1 + 1) % 9 + 1))
                if vector.dot(vector.cross(lV, (vector.cross(lW, lX))), lY) == vector.dot(lW * vector.dot(lV, lX) - lX * vector.dot(lV, lW), lY) then
                    qs_22 = "#14f195"
                    lT = "#0070ba"
                    lS = "#008cff"
                    lR = "#7fd47f"
                else
                    lR = "#14f195"
                    qs_22 = "#0070ba"
                    lT = "#008cff"
                    lS = "#7fd47f"
                end
                qs_1 = (qs_1 + 85) % 192
            end
        else
            lV = {
                "inkjndgekrjv",
                "rtsloolmh",
                "bzvhskctz",
                "lnofdaai",
                "umjemcp",
                "pckl",
                "qkiozvkctr",
                "hpxo",
                "kfctthbl",
                "ncscik",
                "zgwm",
                "hvoqswkcj"
            }
            if lV[(qs_1 * 70 + 30) % 12 + 1] < lV[(qs_1 * 70 + 30) % 12 + 1] then
                k8 = "#6ec1ff"
                lP = "#e8a34d"
                lQ = "#8b93a3"
            else
                lQ = "#6ec1ff"
                k8 = "#e8a34d"
                lP = "#8b93a3"
            end
            qs_1 = (qs_1 + 157) % 192
        end
    elseif lU <= 23 then
        if lU <= 22 then
            lU = {
                "owkczlzuht",
                "ebcct",
                "rxoppbqti",
                "jlicpvfjge",
                "xqx",
                "exwennvoaz",
                "fxtr",
                "uwvbji",
                "zxbeydfaqux",
                "vue",
                "yhqwqcsg"
            }
            local q6 = qs_1
            lV = lU[q6 % 11 + 1]
            if lV:len() >= lV:reverse():rep(q6 % 3 + 2):len() then
                qs_18 = qs_20:WaitForChild("Modules")
            else
                qs_20 = qs_18:WaitForChild("Modules")
            end
            qs_1 = (qs_1 + 85) % 192
        else
            if (qs_1 * 2 + 9) * 7 % 3 == ((qs_1 * 2 + 9) * 7 + 4) % 3 then
                qs_20 = qs_11:WaitForChild("Shared")
            else
                qs_11 = qs_20:WaitForChild("Shared")
            end
            qs_1 = (qs_1 + 157) % 192
        end
    else
        local ra = bit32.rrotate(bit32.bxor(bit32.lrotate(qs_1, 20), string.byte(tostring(RewardDefs))), 4)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(ra, 1887306475), 4292332767), (bit32.bxor(bit32.band(ra, 2407660820), 3790576478))), 4292332767), 3790576478) == ra then
            qs_8 = qs_18:WaitForChild("Remotes")
        else
            qs_18 = qs_8:WaitForChild("Remotes")
        end
        qs_1 = (qs_1 + 181) % 192
    end
until (qs_1 * 169 + 51) % 192 == 10
for k, v in qs_5.Items do
    qs_1 = v.Use
    qs_8 = v.Usable and type(qs_1) == "table"
    if qs_8 then
        qs_8 = qs_1.Type
        qs_1 = qs_8 == "Bundle" or qs_8 == "Chest" or qs_8 == "MutationChest"
        if not qs_1 then
            qs_18 = qs_8 == "Currency" and v.Category == "Misc"
            qs_1 = qs_18
        end
        qs_8 = qs_1
        if qs_8 then
            qs_1 = v.DisplayName or k
            qs_8 = qs_1
            if not ky[qs_8] then
                lN[#lN + 1] = qs_8
                ky[qs_8] = k
                qs_13[k] = qs_8
            end
        end
    end
end
table.sort(lN)
if #lN == 0 then
    lN[1] = "Starter Package"
end
qs_1 = ky["Starter Package"] and "Starter Package"
qs_8 = qs_1 or lN[1]
li = {}
qs_1 = qs_8
if ky[qs_1] then
    qs_8 = 4
    repeat
        if (qs_8 * 1 + 4) * 17 % 4 == ((qs_8 * 1 + 4) * 17 + 4) % 4 then
            li[ky[qs_1]] = true
        else
            ky[qs_1[li]] = true
        end
        qs_8 = (qs_8 + 5) % 8
    until (qs_8 * 7 + 5) % 8 == 4
end
le, la, k5, k2, kZ, kT, kR, kO, kM, kE, kz, kt, Library, SaveManager, Toggles, Options, j3, lj, k6, kV, kA, km, ka, lo, kG, kh, j6, ld, kI, kw, lk, kX, kQ, kK, kk = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
le = {}
la = 0
k5 = 0
k2 = 0
kZ = {}
kT = nil
kR = 0
kO = nil
kM = 0
kE = math.huge
kz = 0
kt = {}
Library = getgenv().Library
pcall(fn669)
qs_13 = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
j3 = fn908
lj = fn508
k6 = fn474
kV = fn403
kA = fn547
km = fn590
ka = fn870
lo = fn542
kG = fn788
kh = fn872
j6 = fn706
ld = fn975
kI = fns.fn28
kw = fn511
lk = fn742
kX = fn522
kQ = fn527
kK = fns.fn98
kk = fn722
qs_4.OnClientEvent:Connect(onOnClientEvent)
qs_19.OnClientEvent:Connect(onOnClientEvent2)
ItemsSync.OnClientEvent:Connect(onOnClientEvent3)
qs_23.OnClientEvent:Connect(onOnClientEvent4)
qs_7.OnClientEvent:Connect(onOnClientEvent5)
qs_2.OnClientEvent:Connect(onOnClientEvent6)
qs_16.OnClientEvent:Connect(fns.onOnClientEvent7)
RequestTreeUpgrades:FireServer()
lh:FireServer()
RequestRewards:FireServer()
lp:FireServer()
k4:FireServer()
kj:FireServer()
qs_10:FireServer()
qs_11 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = kH, Copyable = true }, "|", lO },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
Library.ShowCustomCursor = false
lU = {
    Info = qs_11:AddTab("Info", "info"),
    Main = qs_11:AddTab("Main", "dices"),
    Player = qs_11:AddTab("Player", "person-standing"),
    Settings = qs_11:AddTab("Settings", "settings")
}
qs_5 = fn827
for k, v in lU do
    qs_5(v)
end
j9 = nil
j9 = "Unknown"
pcall(fn635)
Label, lb = nil, nil
qs_11 = lU.Info:AddLeftGroupbox("Account", "circle-user")
qs_11:AddLabel(kV("User", LocalPlayer.Name, lR), true)
qs_11:AddLabel(kV("Status", "Keyless", lR), true)
qs_11:AddLabel(kV("Executor", j9, lR), true)
qs_5 = lU.Info:AddLeftGroupbox("Game Info", "gamepad-2")
qs_5:AddLabel(k6(lO .. " [" .. tostring(game.PlaceId) .. "]", lQ), true)
qs_5:AddLabel(kV("Place ID", tostring(game.PlaceId), lQ), true)
Label = qs_5:AddLabel(kV("Session time", "0s", k8), true)
lb = tostring(game.JobId)
qs_20 = #lb > 18
if qs_20 then
    qs_8 = 0
    repeat
        if (qs_8 * 2 + 7) * 7 % 3 == ((qs_8 * 2 + 7) * 7 + 3) % 3 then
            qs_20 = string.sub(lb, 1, 18) .. "..."
        else
            lb = string.sub(qs_20, 1, 18) .. "..."
        end
        qs_8 = (qs_8 + 2) % 8
    until (qs_8 * 1 + 0) % 8 == 2
end
qs_8 = qs_20 or lb
lV, kP, qs_7, qs_23, qs_20 = nil, nil, nil, nil, nil
if ((not qs_23 or qs_23) and (not qs_20 or qs_7) or (not qs_7 or not qs_23 or (not lV or qs_20))) and ((lV and not qs_20 or (qs_7 or not qs_20)) and (not lV or not qs_23 or not lV and qs_20)) or not (((not qs_23 or qs_23) and (not qs_20 or qs_7) or (not qs_7 or not qs_23 or (not lV or qs_20))) and ((lV and not qs_20 or (qs_7 or not qs_20)) and (not lV or not qs_23 or not lV and qs_20))) then
    lV = qs_8
    qs_5:AddLabel(kV("Server", lV, lP), true)
    qs_5:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    kP = os.clock()
else
    qs_8 = qs_5
    kP:AddLabel(lP("Server", qs_8, kV), true)
    kP:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
    lV = os.clock()
end
task.spawn(fns.worker)
qs_16 = lU.Info:AddRightGroupbox("Scripts", "package")
qs_16:AddLabel(k6("Included in this hub", lP), true)
qs_16:AddLabel(k6(lO, lQ), true)
qs_7 = lU.Info:AddRightGroupbox("Features", "list")
qs_7:AddLabel(k6("Auto Farm", lQ), true)
qs_7:AddLabel(k6("Auto Claim", k8), true)
qs_7:AddLabel(k6("Misc Utilities", lP), true)
qs_23 = lU.Info:AddRightGroupbox("Socials", "link")
qs_23:AddButton({ Text = "Discord", Func = lj })
qs_23:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
qs_20 = lU.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
qs_20:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
qs_20:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
qs_20:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
qs_20:AddButton({ Text = "Copy Discord Invite", Func = lj })
qs_11 = lU.Info:AddRightGroupbox("Donations", "heart")
qs_11:AddLabel(k6("All donations are optional but appreciated.", k8), true)
qs_11:AddLabel(k6("If you donate you get a special role, just PING after you donate.", lR), true)
qs_11:AddDivider()
qs_11:AddLabel(k6("LTC / Litecoin", lM), true)
qs_11:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
qs_11:AddLabel(k6("BTC / Bitcoin", lL), true)
qs_11:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
qs_11:AddLabel(k6("ETH / Ethereum", qs_15), true)
qs_11:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
qs_11:AddLabel(k6("USDT", qs_6), true)
qs_11:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
qs_11:AddLabel(k6("Solana", qs_22), true)
qs_11:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
qs_11:AddLabel(k6("PayPal", lT), true)
qs_11:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
qs_11:AddLabel(k6("Venmo", lS), true)
qs_11:AddButton({ Text = "Copy Venmo Link", Func = fns.onCopyVenmoLink })
qs_11:AddDivider()
qs_11:AddLabel(k6("Don't have any of the listed currencies but still wanna donate?", lP), true)
qs_11:AddLabel(k6("DM me and we'll work something out.", lQ), true)
qs_4 = lU.Info:AddRightGroupbox("FAQ", "circle-help")
qs_4:AddLabel("Where do I get a good config?", true)
qs_4:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
qs_4:AddLabel("How do I import / export configs?", true)
qs_4:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
qs_4:AddLabel("How do I report bugs?", true)
qs_4:AddLabel("Join the Discord and post it in the bugs channel.", true)
qs_4:AddLabel("How do I make suggestions?", true)
qs_4:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
qs_4:AddLabel("How do I get help or updates?", true)
qs_4:AddLabel("Join the Discord, updates and support are posted there first.", true)
qs_19 = lU.Main:AddLeftGroupbox("Auto Farm", "swords")
qs_19:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
qs_19:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
qs_19:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
qs_19:AddToggle("AutoBuyNodes", { Text = "Auto Buy Affordable Upgrades", Default = false })
qs_10 = lU.Main:AddRightGroupbox("Auto Claim", "gift")
qs_10:AddToggle("AutoClaimPlaytime", { Text = "Auto Claim Playtime Rewards", Default = false })
qs_10:AddToggle("AutoClaimRewards", { Text = "Auto Claim Rewards", Default = false })
qs_10:AddToggle("AutoClaimQuests", { Text = "Auto Claim All Quests", Default = false })
qs_10:AddToggle("AutoClaimBattlepass", { Text = "Auto Claim Battlepass", Default = false })
qs_2 = lU.Main:AddLeftGroupbox("Packages", "package")
qs_2:AddToggle("AutoUsePackages", { Text = "Auto Use Packages", Default = false })
qs_2:AddDropdown("PackageTypes", { Text = "Packages", Values = lN, Default = { qs_1 }, Multi = true, Callback = onPackageTypes })
qs_18 = lU.Player:AddLeftGroupbox("Movement", "footprints")
qs_18:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
qs_18:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
qs_18:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
qs_18:AddToggle("NoClip", { Text = "NoClip", Default = false })
qs_18:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
lW = lU.Player:AddRightGroupbox("Fly", "feather")
if (not qs_2 and 48 or (not qs_11 or kP) or (not qs_2) and (qs_11 and not qs_2) and (qs_2 and false or not lV) or ((not qs_11) and lV and (not kP and not qs_11 or (not kP or lV)) or not kP and not kP and (qs_2 or not lV) and ((not qs_2 or kP) and (not lV or qs_11)))) and not (not qs_2 and 48 or (not qs_11 or kP) or (not qs_2) and (qs_11 and not qs_2) and (qs_2 and false or not lV) or ((not qs_11) and lV and (not kP and not qs_11 or (not kP or lV)) or not kP and not kP and (qs_2 or not lV) and ((not qs_2 or kP) and (not lV or qs_11)))) then
    lW:AddToggle("Fly", { Text = "Fly", Default = false })
    lW:AddSlider("FlySpeed", { Max = 400, Min = 10, Rounding = 0, Default = 60, Text = "Fly Speed" })
else
    lW:AddToggle("Fly", { Text = "Fly", Default = false })
    lW:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
end
kb, lq, lm, connection, connection2, kL, k1, lr, kU, kF, ln = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles.Fly:OnChanged(fn968)
Toggles.WalkSpeedEnabled:OnChanged(fn692)
RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
kb = Workspace.CurrentCamera
RunService.RenderStepped:Connect(fns.onRenderStepped)
kL = function(eO)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not eO)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not eO
        end
    end)
    if not eO then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(LocalPlayer, "GameplayPaused", false)
        else
            LocalPlayer.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn637)
lX = lU.Settings:AddLeftGroupbox("Menu", "wrench")
lX:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
lq = tick()
lm = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local o8 = v
        pcall(function()
            o8:Disable()
        end)
    end
end)
k1 = fn322
connection = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
lX:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
lX:AddButton("Unload", onUnload)
Library:OnUnload(fn496)
qs_13:SetLibrary(Library)
qs_13:SetFolder("TempoHub")
qs_13:SaveDefault("Monochrome")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/AnimeWarRNG")
lY = SaveManager:BuildConfigSection(lU.Settings)
lr = fn375
kU = fn842
kF = fn807
ln = function(fQ)
    local pO
    pO = nil
    local pP = type(fQ) ~= "table"
    local pT = if pP then 1 else 0
    local pR = 970 * pT + 1070 * (1 - pT)
    local pS = 1568 * pT + 1610 * (1 - pT)
    if not ((pR * 94 + pS * 455 + pR * pS) % 16777213 == 2325580) then
        pP = type(fQ.idx) ~= "string"
    end
    if not pP then
        pP = type(fQ.type) ~= "string"
    end
    if not pP then
        pP = SaveManager.Ignore[fQ.idx]
    end
    if pP then
        return false
    end
    pO = lr(fQ.type, fQ.idx)
    if not pO then
        return false
    end
    local pP_1 = pcall(function()
        if fQ.type == "Input" then
            if type(fQ.text) ~= "string" then
                return
            end
            pO:SetValue(fQ.text)
        elseif fQ.type == "ColorPicker" then
            pO:SetValueRGB(Color3.fromHex(fQ.value), fQ.transparency)
        elseif fQ.type == "KeyPicker" then
            pO:SetValue({ fQ.key, fQ.mode, fQ.modifiers })
            if fQ.mode == "Toggle" and fQ.toggled ~= nil then
                pO.Toggled = fQ.toggled
                pO:Update()
            end
        else
            pO:SetValue(fQ.value)
        end
    end)
    return pP_1
end
lY:AddDivider()
lY:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
lY:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
lY:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
qs_13:ApplyToTab(lU.Settings)
qs_13:LoadDefault()
SaveManager:LoadAutoloadConfig()
task.spawn(autoRollLoop)
task.spawn(autoRebirthLoop)
task.spawn(autoEquipBestLoop)
task.spawn(autoBuyNodesLoop)
task.spawn(fns.autoClaimPlaytimeLoop)
task.spawn(autoUsePackagesLoop)
task.spawn(autoClaimPlaytimeLoop2)
task.spawn(fns.antiGameplayPauseLoop)
task.spawn(antiAfkLoop)
Library:Notify("Anime War RNG loaded")
end)(...)
