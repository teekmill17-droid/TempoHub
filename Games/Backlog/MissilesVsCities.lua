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
getgenv().TempoHoodSubtitle = "MISSILES VS CITIES"
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
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = Shared:WaitForChild("Net")
local Config = require(Shared:WaitForChild("Config"))
local PlayerState = require(Shared:WaitForChild("Framework"):WaitForChild("PlayerState"))
local Prompts = require(Net:WaitForChild("Prompts"))
local Targeting = require(Net:WaitForChild("Targeting"))
local Missiles = require(Net:WaitForChild("Missiles"))
local Jets = require(Net:WaitForChild("Jets"))
local Orbital = require(Net:WaitForChild("Orbital"))
local Naval = require(Net:WaitForChild("Naval"))
local Combat = require(Net:WaitForChild("Combat"))
local DISTRICTS = {
	"district_silos",
	"district_military_airport",
	"district_nuclear_reactors",
	"district_datacenters",
	"district_naval_dock",
	"district_space_center",
	"district_oil_refinery",
	"district_seaport",
	"district_warehouses",
	"district_solar_field",
	"district_wind_farm",
	"district_downtown",
	"district_farm",
	"district_houses",
}
local UPGRADE_TYPES = {
	"Houses",
	"Downtown",
	"Farms",
	"Warehouses",
	"Nuclear Reactors",
	"Solar Field",
	"Wind Farm",
	"Datacenters",
	"Oil Refinery",
	"Seaport",
	"Missile Silos",
	"Anti-Air",
	"Hangars",
	"Gold Mines",
	"Barrage Arrays",
	"Space Center",
	"Naval Dock",
	"Navy Ships",
}
local DISTRICT_UPGRADE_TYPES = {
	district_houses = "Houses",
	district_downtown = "Downtown",
	district_farm = "Farms",
	district_warehouses = "Warehouses",
	district_nuclear_reactors = "Nuclear Reactors",
	district_solar_field = "Solar Field",
	district_wind_farm = "Wind Farm",
	district_datacenters = "Datacenters",
	district_oil_refinery = "Oil Refinery",
	district_seaport = "Seaport",
	district_silos = "Missile Silos",
	district_military_airport = "Hangars",
	district_space_center = "Space Center",
	district_naval_dock = "Naval Dock",
}
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Options = Library.Options
local Toggles = Library.Toggles
local DISCORD_INVITE = "https://discord.gg/K7Qxnxkk46"
local function toggle_enabled(name)
	local toggle = Toggles[name]
	return toggle and toggle.Value == true
end
local function upgrade_allowed(category)
	local option = Options.UpgradeSelection
	local selected = option and option.Value
	if typeof(selected) ~= "table" or not next(selected) then
		return true
	end
	return selected[category] == true
end
local function get_plot()
	local plots = workspace:FindFirstChild("map") and workspace.map:FindFirstChild("plots")
	if not plots then
		return nil
	end
	for _, plot in plots:GetChildren() do
		if plot:GetAttribute("owner_name") == LocalPlayer.Name then
			return plot
		end
	end
	return nil
end
local function get_root()
	local character = LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end
local function teleport_to(position)
	local root = get_root()
	if root and typeof(position) == "Vector3" then
		root.CFrame = CFrame.new(position + Vector3.new(0, 6, 0))
	end
end
local function touch(root, part)
	pcall(function()
		firetouchinterest(root, part, 0)
		task.wait()
		firetouchinterest(root, part, 1)
	end)
	pcall(function()
		firesignal(part.Touched, root)
	end)
end
local function collect_money()
	local plot = get_plot()
	local root = get_root()
	if not plot or not root then
		return
	end
	for _, part in plot:GetDescendants() do
		if part.Name == "collector" and part:IsA("BasePart") and part.CanTouch then
			touch(root, part)
		end
	end
end
local function button_upgrade_type(cap, plot)
	local current = cap.Parent
	while current and current ~= plot do
		local category = DISTRICT_UPGRADE_TYPES[current.Name]
		if category then
			return category
		end
		if current.Name == "island_gold" then
			return "Gold Mines"
		end
		if current.Name == "island_barrage" then
			return "Barrage Arrays"
		end
		if current.Name == "expand_wind_farm" then
			return "Wind Farm"
		end
		current = current.Parent
	end
	return nil
end
local function press_buttons()
	local plot = get_plot()
	local root = get_root()
	if not plot or not root then
		return
	end
	for _, cap in plot:GetDescendants() do
		if cap.Name == "cap" and cap:IsA("BasePart") and cap.CanTouch and cap.Transparency == 0 then
			local model = cap.Parent
			local category = button_upgrade_type(cap, plot)
			if model:FindFirstChild("base") and cap.Color == Color3.fromRGB(0, 255, 0) and category and upgrade_allowed(category) then
				touch(root, cap)
			end
		end
	end
end
local function enemy_plots()
	local plots = workspace:FindFirstChild("map") and workspace.map:FindFirstChild("plots")
	if not plots then
		return {}
	end
	local list = {}
	for _, plot in plots:GetChildren() do
		local owner = plot:GetAttribute("owner_name")
		if typeof(owner) == "string" and owner ~= "" and owner ~= LocalPlayer.Name then
			list[#list + 1] = { plot = plot, owner = owner }
		end
	end
	return list
end
local function district_resources(district)
	local list = {}
	local seen = {}
	for _, child in district:GetDescendants() do
		if child:IsA("Model") and CollectionService:HasTag(child, "building") then
			seen[child] = true
			list[#list + 1] = child
		end
	end
	for _, child in district:GetChildren() do
		if child:IsA("Model") and not seen[child] then
			local name = child.Name
			if
				name:match("^silo_structure_%d+$")
				or name:match("^hangar_structure_%d+$")
				or name == "launch_pad"
				or name == "command_center"
				or name == "heavy_battery"
				or name == "orbital_console"
				or name == "space_shuttle"
			then
				list[#list + 1] = child
			end
		end
	end
	return list
end
local function district_priority(plot)
	local wanted = Options.TargetDistrict.Value
	if wanted and wanted ~= "Most Important" and wanted ~= "Random" then
		local district = plot:FindFirstChild(wanted)
		return district and #district_resources(district) > 0 and 1 or nil
	end
	for index, name in DISTRICTS do
		local district = plot:FindFirstChild(name)
		if district and #district_resources(district) > 0 then
			return index
		end
	end
	return nil
end
local function pick_target()
	local list = enemy_plots()
	if #list == 0 then
		return nil
	end
	local wanted = Options.TargetPlayer.Value
	if wanted and wanted ~= "Auto Priority" and wanted ~= "Random" then
		for _, entry in list do
			if entry.owner == wanted then
				return entry.plot
			end
		end
		if Toggles.StrictTarget.Value then
			return nil
		end
	end
	local best
	local best_priority
	for _, entry in list do
		local priority = district_priority(entry.plot)
		if priority and (not best_priority or priority < best_priority) then
			best = entry.plot
			best_priority = priority
		end
	end
	return best
end
local function selected_target()
	local wanted = Options.TargetPlayer.Value
	if not wanted or wanted == "Auto Priority" or wanted == "Random" then
		return nil
	end
	for _, entry in enemy_plots() do
		if entry.owner == wanted then
			return entry.plot
		end
	end
	return nil
end
local function pick_district(plot)
	local wanted = Options.TargetDistrict.Value
	if wanted and wanted ~= "Most Important" and wanted ~= "Random" then
		return plot:FindFirstChild(wanted)
	end
	for _, name in DISTRICTS do
		local district = plot:FindFirstChild(name)
		if district and #district_resources(district) > 0 then
			return district
		end
	end
	return nil
end
local function aim_position(plot)
	local district = pick_district(plot)
	if not district then
		return plot:GetPivot().Position
	end
	local resources = district_resources(district)
	local best_building
	local best_size = 0
	for _, child in resources do
		local size = child:GetExtentsSize().Magnitude
		if size > best_size then
			best_size = size
			best_building = child
		end
	end
	if best_building then
		return best_building:GetPivot().Position
	end
	return district:GetPivot().Position
end
local function prompt_records()
	local list = {}
	for _, record in PlayerState.Prompts() do
		list[#list + 1] = record
	end
	return list
end
local function silo_anchors()
	local plot = get_plot()
	local list = {}
	if not plot then
		return list
	end
	for _, record in prompt_records() do
		if record.kind == "silo" and record.anchor and record.anchor:IsDescendantOf(plot) then
			list[#list + 1] = record.anchor
		end
	end
	return list
end
local suppressed = {}
local function native_listeners(packet)
	local snapshot = suppressed[packet]
	if not snapshot then
		snapshot = table.clone(packet.getListeners())
		suppressed[packet] = snapshot
	end
	return snapshot
end
local function set_packet_native(packet, enabled)
	local snapshot = native_listeners(packet)
	local live = packet.getListeners()
	for _, listener in snapshot do
		local index = table.find(live, listener)
		if enabled and not index then
			table.insert(live, listener)
		elseif not enabled and index then
			table.remove(live, index)
		end
	end
end
for _, packet in { Targeting.enter, Targeting.enterJet, Orbital.open, Jets.launched, Jets.summary } do
	native_listeners(packet)
end
local function set_native_targeting(enabled)
	set_packet_native(Targeting.enter, enabled)
end
local function set_native_jet_targeting(enabled)
	set_packet_native(Targeting.enterJet, enabled)
end
local function set_native_orbital(enabled)
	set_packet_native(Orbital.open, enabled)
end
local function set_native_jet_flight(enabled)
	set_packet_native(Jets.launched, enabled)
	set_packet_native(Jets.summary, enabled)
end
local TARGETING_TOGGLES = {
	"AutoAttack",
	"AutoBarrage",
	"AutoEMP",
	"AutoRailGun",
	"AutoBlowUpSilo",
	"AutoOrbital",
}
local function sync_native_targeting()
	for _, name in TARGETING_TOGGLES do
		if toggle_enabled(name) then
			set_native_targeting(false)
			return
		end
	end
	set_native_targeting(true)
end
local function sync_native_jet_flight()
	set_native_jet_flight(not toggle_enabled("AutoScramble"))
end
local targeting_open = false
local jet_targeting_open = false
local jet_targeting_data = nil
local targeting_busy = false
Targeting.enter.listen(function()
	targeting_open = true
end)
Targeting.enterJet.listen(function(data)
	jet_targeting_open = true
	jet_targeting_data = data
end)
local function fire_targeted_prompt(anchor, action, plot)
	if targeting_busy then
		return
	end
	targeting_busy = true
	targeting_open = false
	Prompts.action.send({ anchor = anchor, action = action })
	local deadline = os.clock() + 3
	while not targeting_open and os.clock() < deadline do
		task.wait(0.1)
	end
	if targeting_open then
		targeting_open = false
		Missiles.fire.send({ target = aim_position(plot) })
		task.wait(Options.AttackDelay.Value)
	end
	targeting_busy = false
end
local function attack()
	local anchors = silo_anchors()
	if #anchors == 0 then
		return
	end
	for _, anchor in anchors do
		if Library.Unloaded or not Toggles.AutoAttack.Value then
			return
		end
		local plot = pick_target()
		if not plot then
			return
		end
		fire_targeted_prompt(anchor, "shoot", plot)
	end
end
local function barrage_attack()
	local plot = get_plot()
	if not plot then
		return
	end
	for _, record in prompt_records() do
		if Library.Unloaded or not Toggles.AutoBarrage.Value then
			return
		end
		if
			record.kind == "barrage"
			and record.anchor
			and record.anchor:IsDescendantOf(plot)
			and typeof(record.state) == "table"
			and record.state.fire_ready
		then
			local target = pick_target()
			if target then
				fire_targeted_prompt(record.anchor, "fire", target)
			end
		end
	end
end
local function special_weapon_attack(toggle_name, prompt_kind, title_text, explicit_target)
	local plot = get_plot()
	if not plot then
		return
	end
	for _, record in prompt_records() do
		if Library.Unloaded or not toggle_enabled(toggle_name) then
			return
		end
		local info = record.state
		local title = typeof(info) == "table" and tostring(info.title or ""):lower() or ""
		if
			record.kind == prompt_kind
			and record.anchor
			and record.anchor:IsDescendantOf(plot)
			and typeof(info) == "table"
			and info.fire_ready
			and (not title_text or title:find(title_text, 1, true))
		then
			local target = explicit_target and selected_target() or pick_target()
			if target then
				fire_targeted_prompt(record.anchor, "fire", target)
			end
		end
	end
end
local orbital_busy_until = 0
local orbital_open = false
Orbital.open.listen(function()
	orbital_open = true
end)
local function orbital_attack()
	if os.clock() < orbital_busy_until then
		return
	end
	local target = selected_target() or pick_target()
	if not target then
		return
	end
	local plot = get_plot()
	if not plot then
		return
	end
	for _, record in prompt_records() do
		if Library.Unloaded or not Toggles.AutoOrbital.Value then
			return
		end
		local info = record.state
		if
			record.kind == "orbital"
			and record.anchor
			and record.anchor:IsDescendantOf(plot)
			and typeof(info) == "table"
			and info.launched
			and info.fire_ready
		then
			orbital_open = false
			Prompts.action.send({ anchor = record.anchor, action = "fire" })
			local deadline = os.clock() + 3
			while not orbital_open and os.clock() < deadline do
				task.wait(0.1)
			end
			if not orbital_open then
				return
			end
			orbital_open = false
			local duration = math.max(1, tonumber(Config.orbital.window_seconds) or 30)
			local rate = math.max(0.05, tonumber(Config.orbital.aim_rate) or 0.1)
			orbital_busy_until = os.clock() + duration
			Orbital.strike.send({ name = target.Name })
			task.spawn(function()
				while
					not Library.Unloaded
					and Toggles.AutoOrbital.Value
					and os.clock() < orbital_busy_until
				do
					Orbital.aim.send({ pos = aim_position(target) })
					task.wait(rate)
				end
			end)
			return
		end
	end
end
local counter_target = nil
local counter_deadline = 0
local function note_attacker(name)
	if Library.Unloaded or not Toggles.AutoCounter.Value then
		return
	end
	if typeof(name) ~= "string" or name == "" or name == LocalPlayer.Name then
		return
	end
	if not Players:FindFirstChild(name) then
		return
	end
	counter_target = name
	counter_deadline = os.clock() + (tonumber(Options.CounterDuration.Value) or 30)
end
Combat.revengeOffer.listen(function(data)
	note_attacker(typeof(data) == "table" and data.attackerName or nil)
end)
Combat.clip.listen(function(data)
	note_attacker(typeof(data) == "table" and data.name or nil)
end)
Combat.lastAttacker.listen(function(data)
	note_attacker(typeof(data) == "table" and data.owner or nil)
end)
Naval.alertAttack.listen(function(data)
	note_attacker(typeof(data) == "table" and data.attacker or nil)
end)
Naval.alertLost.listen(function(data)
	note_attacker(typeof(data) == "table" and data.attacker or nil)
end)
Missiles.launched.listen(function(data)
	local shooter = typeof(data) == "table" and data.shooter or nil
	if typeof(shooter) == "Instance" and shooter:IsA("Player") then
		note_attacker(shooter.Name)
	end
end)
local function counter_attack()
	if not counter_target or os.clock() > counter_deadline then
		return
	end
	local plot
	for _, entry in enemy_plots() do
		if entry.owner == counter_target then
			plot = entry.plot
			break
		end
	end
	if not plot then
		return
	end
	local anchors = silo_anchors()
	for _, anchor in anchors do
		if Library.Unloaded or not Toggles.AutoCounter.Value then
			return
		end
		if os.clock() > counter_deadline then
			return
		end
		fire_targeted_prompt(anchor, "shoot", plot)
	end
end
local function jet_strike_positions(target, data)
	local positions = {}
	local wanted = target:GetAttribute("owner_name")
	local selected
	if typeof(data) == "table" and typeof(data.plots) == "table" then
		for _, entry in data.plots do
			if typeof(entry) == "table" and entry.city == wanted then
				selected = entry
				break
			end
		end
		if not selected then
			local target_position = target:GetPivot().Position
			local distance
			for _, entry in data.plots do
				if typeof(entry) == "table" and typeof(entry.center) == "Vector3" then
					local current = (entry.center - target_position).Magnitude
					if not distance or current < distance then
						distance = current
						selected = entry
					end
				end
			end
		end
	end
	if selected and typeof(selected.center) == "Vector3" then
		positions[1] = selected.center
	end
	if #positions == 0 then
		positions[1] = aim_position(target)
	end
	return positions
end
local function scramble_jets()
	local plot = get_plot()
	if not plot then
		return
	end
	for _, record in prompt_records() do
		if Library.Unloaded or not Toggles.AutoScramble.Value then
			return
		end
		local info = record.state
		if
			record.kind == "jet"
			and record.anchor
			and record.anchor:IsDescendantOf(plot)
			and typeof(info) == "table"
			and info.scramble_ready
			and not info.scramble_flying
			and not info.scramble_knocked
		then
			local target = selected_target()
			if not target then
				return
			end
			jet_targeting_open = false
			jet_targeting_data = nil
			Prompts.action.send({ anchor = record.anchor, action = "scramble" })
			local deadline = os.clock() + 3
			while not jet_targeting_open and os.clock() < deadline do
				task.wait(0.1)
			end
			if jet_targeting_open then
				jet_targeting_open = false
				Jets.fire.send({ positions = jet_strike_positions(target, jet_targeting_data) })
				task.wait(Options.ScrambleDelay.Value)
			end
		end
	end
end
local function cash()
	local currency = LocalPlayer:FindFirstChild("currency")
	local value = currency and currency:FindFirstChild("Cash")
	return value and value.Value or 0
end
local function reserve()
	return tonumber(Options.CashReserve.Value) or 0
end
local function affordable(cost)
	local limit = tonumber(Options.MaxUpgradeCost.Value) or 0
	if limit > 0 and cost > limit then
		return false
	end
	return cash() - cost >= reserve()
end
local function upgrade_hangars()
	local plot = get_plot()
	if not plot then
		return
	end
	for _, record in prompt_records() do
		if Library.Unloaded or not Toggles.AutoHangars.Value then
			return
		end
		if record.kind == "jet" and record.anchor and record.anchor:IsDescendantOf(plot) then
			local info = record.state
			if typeof(info) == "table" and info.up_affordable and affordable(info.up_cost or 0) then
				Prompts.action.send({ anchor = record.anchor, action = "upgrade" })
				task.wait(0.4)
			end
		end
	end
end
local UPGRADEABLE_PROMPTS = {
	silo = true,
	aa = true,
	jet = true,
	mine = true,
	barrage = true,
}
local PROMPT_UPGRADE_TYPES = {
	silo = "Missile Silos",
	aa = "Anti-Air",
	jet = "Hangars",
	mine = "Gold Mines",
	barrage = "Barrage Arrays",
}
local function upgrade_resources()
	local plot = get_plot()
	if not plot then
		return
	end
	for _, record in prompt_records() do
		if Library.Unloaded or not Toggles.AutoUpgrade.Value then
			return
		end
		local info = record.state
		local category = PROMPT_UPGRADE_TYPES[record.kind]
		if
			UPGRADEABLE_PROMPTS[record.kind]
			and upgrade_allowed(category)
			and record.anchor
			and record.anchor:IsDescendantOf(plot)
			and typeof(info) == "table"
			and info.up_affordable
			and (info.up_cost or -1) >= 0
			and affordable(info.up_cost or 0)
		then
			Prompts.action.send({ anchor = record.anchor, action = "upgrade" })
			task.wait(0.25)
		end
	end
end
local function operate_mines(island_name, toggle)
	local plot = get_plot()
	if not plot then
		return
	end
	for _, record in prompt_records() do
		if Library.Unloaded or not toggle.Value then
			return
		end
		if
			record.kind == "mine"
			and record.anchor
			and record.anchor:IsDescendantOf(plot)
			and record.anchor:GetFullName():find(island_name, 1, true)
			and typeof(record.state) == "table"
			and record.state.mine_state ~= "mining"
		then
			Prompts.action.send({ anchor = record.anchor, action = "operate" })
			task.wait(0.2)
		end
	end
end
local fleet = {}
local islands = {}
local crates = {}
local rarities = {}
local island_names = {}
local naval_sync_serial = 0
local function apply_naval_sync(data)
	fleet = data.fleet
	islands = typeof(data.islands) == "table" and data.islands or {}
	crates = typeof(data.crates) == "table" and data.crates or {}
	naval_sync_serial = naval_sync_serial + 1
	local seen, values = {}, {}
	for _, ship in fleet do
		if ship.rarity and not seen[ship.rarity] then
			seen[ship.rarity] = true
			values[#values + 1] = ship.rarity
		end
	end
	table.sort(values)
	if table.concat(values, ",") ~= table.concat(rarities, ",") then
		rarities = values
		Options.ShipRarities:SetValues(values)
	end
	local names = {}
	for _, island in islands do
		if typeof(island.name) == "string" and island.name ~= "" then
			names[#names + 1] = island.name
		end
	end
	table.sort(names)
	if table.concat(names, ",") ~= table.concat(island_names, ",") then
		island_names = names
		Options.DeployIsland:SetValues(names)
		if not table.find(names, Options.DeployIsland.Value) then
			Options.DeployIsland:SetValue(names[1])
		end
		local assignment_values = { "Auto" }
		for _, name in names do
			assignment_values[#assignment_values + 1] = name
		end
		for index = 1, 4 do
			local option = Options["NavyShip" .. index .. "Island"]
			if option then
				local current = option.Value
				option:SetValues(assignment_values)
				if not table.find(assignment_values, current) then
					option:SetValue("Auto")
				end
			end
		end
	end
end
local pending_naval = nil
Naval.sync.listen(function(data)
	if typeof(data) ~= "table" or typeof(data.fleet) ~= "table" then
		return
	end
	pending_naval = data
end)
task.spawn(function()
	while task.wait(0.1) do
		if Library.Unloaded then
			break
		end
		local data = pending_naval
		if data then
			pending_naval = nil
			pcall(apply_naval_sync, data)
		end
	end
end)
local function sync_naval()
	local serial = naval_sync_serial
	Naval.requestSync.send()
	local deadline = os.clock() + 3
	while naval_sync_serial == serial and os.clock() < deadline do
		task.wait(0.1)
	end
end
local function rarity_allowed(rarity)
	local picked = Options.ShipRarities.Value
	if typeof(picked) ~= "table" or not next(picked) then
		return true
	end
	return picked[rarity] == true
end
local function upgrade_ships()
	sync_naval()
	for _, ship in fleet do
		if Library.Unloaded or not Toggles.AutoShips.Value then
			return
		end
		local cost = ship.upgradeCost or 0
		if
			not ship.maxed
			and ship.upgradeAfford
			and rarity_allowed(ship.rarity)
			and (ship.level or 1) < Options.MaxShipLevel.Value
			and affordable(cost)
		then
			Naval.upgradeShip.send({ shipId = ship.id })
			task.wait(0.4)
		end
	end
end
local function gems()
	local currency = LocalPlayer:FindFirstChild("currency")
	local value = currency and currency:FindFirstChild("Gems")
	return value and value.Value or 0
end
local function buy_crates()
	sync_naval()
	local key = Options.CrateType.Value
	local crate = crates[key]
	if typeof(crate) ~= "table" or not crate.gems then
		return
	end
	local keep = tonumber(Options.GemReserve.Value) or 0
	while gems() - crate.gems >= keep do
		if Library.Unloaded or not Toggles.AutoCrates.Value then
			return
		end
		Naval.roll.send({ crate = key, currency = "gems" })
		task.wait(1)
	end
end
local function pick_island(assignment)
	if assignment and assignment ~= "Auto" then
		for _, island in islands do
			if island.name == assignment then
				return island.mine == true and nil or island
			end
		end
		return nil
	end
	local mode = Options.DeployMode.Value
	local best
	for _, island in islands do
		local owned = island.mine == true
		local enemy = island.controller ~= nil and not owned
		if not (owned and Toggles.SkipOwnedIslands.Value) then
			if mode == "Specific Island" then
				if island.name == Options.DeployIsland.Value then
					return island
				end
			elseif mode == "Empty Islands" then
				if island.controller == nil then
					return island
				end
			elseif mode == "Enemy Islands" then
				if enemy and (not best or (island.rate or 0) > (best.rate or 0)) then
					best = island
				end
			elseif not best or (island.rate or 0) > (best.rate or 0) then
				best = island
			end
		end
	end
	return best
end
local function deploy_ships()
	sync_naval()
	local ordered = {}
	local active = 0
	for _, ship in fleet do
		ordered[#ordered + 1] = ship
		if ship.deployed then
			active = active + 1
		end
	end
	table.sort(ordered, function(left, right)
		return (left.id or 0) < (right.id or 0)
	end)
	for index, ship in ordered do
		if Library.Unloaded or not Toggles.AutoDeploy.Value then
			return
		end
		if index > 4 or active >= 4 then
			return
		end
		if
			not ship.deployed
			and not ship.repairing
			and (ship.readyIn or 0) <= 0
			and rarity_allowed(ship.rarity)
			and (ship.level or 1) >= Options.MinDeployLevel.Value
		then
			local option = Options["NavyShip" .. index .. "Island"]
			local island = pick_island(option and option.Value or "Auto")
			if island then
				Naval.deploy.send({ shipId = ship.id, slot = island.slot })
				ship.deployed = island.slot
				active = active + 1
				task.wait(0.4)
			end
		end
	end
end
local Window = Library:CreateWindow({
	Title = "Tempo Hub",
	Footer = DISCORD_INVITE .. " | Missiles vs Cities",
	Icon = 18657887261,
	NotifySide = "Right",
	ShowCustomCursor = false,
	Size = UDim2.fromOffset(880, 700),
})
local Tabs = {
	Main = Window:AddTab("Main", "rocket"),
	Settings = Window:AddTab("Settings", "settings"),
}
local function AddDiscordButton(Tab)
	local DiscordGroup = Tab:AddLeftGroupbox("Discord", nil, true, false, true)
	DiscordGroup:AddButton({
		Text = "Join Discord to Make Money",
		Func = function()
			setclipboard(DISCORD_INVITE)
			Library:Notify("Copied Discord invite to clipboard")
		end,
	})
	DiscordGroup:AddButton({
		Text = "Join Discord for Keyless Scripts",
		Func = function()
			setclipboard(DISCORD_INVITE)
			Library:Notify("Copied Discord invite to clipboard")
		end,
	})
end
for _, Tab in Tabs do
	AddDiscordButton(Tab)
end
local FarmGroup = Tabs.Main:AddLeftGroupbox("Farm", "banknote")
FarmGroup:AddToggle("AutoCollect", {
	Text = "Auto Collect Money",
	Default = false,
})
FarmGroup:AddToggle("AutoUpgrade", {
	Text = "Auto Upgrade Everything",
	Default = false,
})
FarmGroup:AddDropdown("UpgradeSelection", {
	Values = UPGRADE_TYPES,
	Multi = true,
	AllowNull = true,
	Default = {},
	Text = "Upgrade Types (none = all)",
})
FarmGroup:AddToggle("AutoGoldCarts", {
	Text = "Auto Gold Cart Send / Claim",
	Default = false,
})
FarmGroup:AddToggle("AutoGemCarts", {
	Text = "Auto Gem Cart Send / Claim",
	Default = false,
})
local AttackGroup = Tabs.Main:AddRightGroupbox("Attack", "rocket")
AttackGroup:AddToggle("AutoAttack", {
	Text = "Auto Attack",
	Default = false,
	Callback = sync_native_targeting,
})
AttackGroup:AddDropdown("TargetPlayer", {
	Values = { "Auto Priority" },
	Default = 1,
	Text = "Target",
})
AttackGroup:AddToggle("StrictTarget", {
	Text = "Only Attack Target",
	Default = false,
})
local district_values = { "Most Important" }
for _, name in DISTRICTS do
	district_values[#district_values + 1] = name
end
AttackGroup:AddDropdown("TargetDistrict", {
	Values = district_values,
	Default = 1,
	Text = "District",
})
AttackGroup:AddSlider("AttackDelay", {
	Text = "Delay Between Missiles",
	Default = 1,
	Min = 0.5,
	Max = 10,
	Rounding = 1,
	Suffix = "s",
})
AttackGroup:AddToggle("AutoCounter", {
	Text = "Auto Counter-Attack",
	Default = false,
})
AttackGroup:AddToggle("AutoBarrage", {
	Text = "Auto Barrage Array",
	Default = false,
	Callback = sync_native_targeting,
})
AttackGroup:AddToggle("AutoEMP", {
	Text = "Auto EMP Attack",
	Default = false,
	Callback = sync_native_targeting,
})
AttackGroup:AddToggle("AutoRailGun", {
	Text = "Auto Rail Gun Attack",
	Default = false,
	Callback = sync_native_targeting,
})
AttackGroup:AddToggle("AutoOrbital", {
	Text = "Auto Orbital Cannon",
	Default = false,
	Callback = function()
		set_native_orbital(not toggle_enabled("AutoOrbital"))
		sync_native_targeting()
	end,
})
AttackGroup:AddToggle("AutoBlowUpSilo", {
	Text = "Auto Blow Up Silo",
	Default = false,
	Callback = sync_native_targeting,
})
AttackGroup:AddSlider("CounterDuration", {
	Text = "Counter Duration",
	Default = 30,
	Min = 5,
	Max = 120,
	Rounding = 0,
	Suffix = "s",
})
local last_targets = ""
local function refresh_targets()
	local values = { "Auto Priority" }
	for _, entry in enemy_plots() do
		values[#values + 1] = entry.owner
	end
	local key = table.concat(values, ",")
	if key == last_targets then
		return
	end
	last_targets = key
	local current = Options.TargetPlayer.Value
	Options.TargetPlayer:SetValues(values)
	if not table.find(values, current) then
		Options.TargetPlayer:SetValue("Auto Priority")
	end
end
AttackGroup:AddToggle("AutoScramble", {
	Text = "Auto Scramble Jets",
	Default = false,
	Callback = function()
		set_native_jet_targeting(not toggle_enabled("AutoScramble"))
		sync_native_jet_flight()
	end,
})
AttackGroup:AddSlider("ScrambleDelay", {
	Text = "Delay Between Jets",
	Default = 2,
	Min = 0.5,
	Max = 10,
	Rounding = 1,
	Suffix = "s",
})
AttackGroup:AddButton({
	Text = "Refresh Targets",
	Func = refresh_targets,
})
refresh_targets()
local TeleportGroup = Tabs.Main:AddLeftGroupbox("Teleport", "move")
TeleportGroup:AddButton({
	Text = "Teleport To Target",
	Func = function()
		local wanted = Options.TargetPlayer.Value
		if wanted and wanted ~= "Auto Priority" and wanted ~= "Random" then
			local player = Players:FindFirstChild(wanted)
			local character = player and player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				teleport_to(root.Position)
				return
			end
			for _, entry in enemy_plots() do
				if entry.owner == wanted then
					teleport_to(entry.plot:GetPivot().Position)
					return
				end
			end
		end
		Library:Notify("No target selected")
	end,
})
TeleportGroup:AddButton({
	Text = "Back Home",
	Func = function()
		local plot = get_plot()
		if plot then
			teleport_to(plot:GetPivot().Position)
		end
	end,
})
local UpgradeGroup = Tabs.Main:AddLeftGroupbox("Upgrades", "arrow-up")
UpgradeGroup:AddToggle("AutoHangars", {
	Text = "Auto Upgrade Hangars",
	Default = false,
})
UpgradeGroup:AddToggle("AutoShips", {
	Text = "Auto Upgrade Ships",
	Default = false,
})
UpgradeGroup:AddDropdown("ShipRarities", {
	Values = {},
	Multi = true,
	Text = "Ship Rarities",
})
UpgradeGroup:AddSlider("MaxShipLevel", {
	Text = "Max Ship Level",
	Default = 100,
	Min = 1,
	Max = 100,
	Rounding = 0,
})
UpgradeGroup:AddInput("MaxUpgradeCost", {
	Text = "Max Upgrade Cost",
	Default = "0",
	Numeric = true,
	Finished = true,
})
UpgradeGroup:AddInput("CashReserve", {
	Text = "Keep Cash",
	Default = "0",
	Numeric = true,
	Finished = true,
})
local NavyGroup = Tabs.Main:AddRightGroupbox("Navy", "ship")
NavyGroup:AddToggle("AutoDeploy", {
	Text = "Auto Deploy Ships",
	Default = false,
})
NavyGroup:AddDropdown("DeployMode", {
	Values = { "Highest Gem Rate", "Empty Islands", "Enemy Islands", "Specific Island" },
	Default = 1,
	Text = "Deploy Mode",
})
NavyGroup:AddDropdown("DeployIsland", {
	Values = {},
	AllowNull = true,
	Text = "Island",
})
for index = 1, 4 do
	NavyGroup:AddDropdown("NavyShip" .. index .. "Island", {
		Values = { "Auto" },
		Default = 1,
		Text = "Ship " .. index .. " Fixed Island",
	})
end
NavyGroup:AddButton({
	Text = "Refresh Islands",
	Func = function()
		Naval.requestSync.send()
	end,
})
Naval.requestSync.send()
NavyGroup:AddToggle("SkipOwnedIslands", {
	Text = "Skip Islands I Hold",
	Default = true,
})
NavyGroup:AddSlider("MinDeployLevel", {
	Text = "Min Ship Level",
	Default = 1,
	Min = 1,
	Max = 100,
	Rounding = 0,
})
NavyGroup:AddToggle("AutoCrates", {
	Text = "Auto Buy Naval Crates",
	Default = false,
})
NavyGroup:AddDropdown("CrateType", {
	Values = { "wooden", "iron", "gold" },
	Default = 1,
	Text = "Crate",
})
NavyGroup:AddInput("GemReserve", {
	Text = "Keep Gems",
	Default = "0",
	Numeric = true,
	Finished = true,
})
Tabs.Settings:AddLeftGroupbox("Anti-AFK"):AddToggle("AntiAFK", {
	Text = "Anti-AFK",
	Default = true,
})
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind",
})
MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)
local antiAfkBeganConnection
local antiAfkChangedConnection
Library:OnUnload(function()
	set_native_targeting(true)
	set_native_jet_targeting(true)
	set_native_orbital(true)
	set_native_jet_flight(true)
	antiAfkBeganConnection:Disconnect()
	antiAfkChangedConnection:Disconnect()
end)
Library.ToggleKeybind = Options.MenuKeybind
local antiAfkLastInput = tick()
local antiAfkLastTap = tick()
pcall(function()
	for _, connection in ipairs(getconnections(LocalPlayer.Idled)) do
		pcall(function()
			connection:Disable()
		end)
	end
end)
local function antiAfkTap()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
	task.wait(0.1)
	VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
	antiAfkLastTap = tick()
end
antiAfkBeganConnection = UserInputService.InputBegan:Connect(function()
	antiAfkLastInput = tick()
end)
antiAfkChangedConnection = UserInputService.InputChanged:Connect(function(input)
	local inputType = input.UserInputType
	if inputType == Enum.UserInputType.MouseMovement or inputType == Enum.UserInputType.Gamepad1 then
		antiAfkLastInput = tick()
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		task.wait(2)
		if Library.Unloaded then
			break
		end
		if toggle_enabled("AntiAFK") then
			local idle = tick() - antiAfkLastInput
			local sinceTap = tick() - antiAfkLastTap
			if idle >= 300 and sinceTap >= 60 then
				pcall(antiAfkTap)
			elseif idle < 300 and sinceTap >= 300 then
				pcall(antiAfkTap)
			end
		end
	end
end)
task.spawn(function()
	while task.wait(0.5) do
		if Library.Unloaded then
			break
		end
		if Toggles.AutoCollect.Value then
			pcall(collect_money)
		end
	end
end)
task.spawn(function()
	while task.wait(1) do
		if Library.Unloaded then
			break
		end
		if Toggles.AutoUpgrade.Value then
			pcall(press_buttons)
			pcall(upgrade_resources)
		end
		if Toggles.AutoGoldCarts.Value then
			pcall(operate_mines, "island_gold", Toggles.AutoGoldCarts)
		end
		if Toggles.AutoGemCarts.Value then
			pcall(operate_mines, "island_gem", Toggles.AutoGemCarts)
		end
	end
end)
task.spawn(function()
	while task.wait(0.5) do
		if Library.Unloaded then
			break
		end
		if Toggles.AutoAttack.Value then
			pcall(attack)
		end
		if Toggles.AutoBarrage.Value then
			pcall(barrage_attack)
		end
		if Toggles.AutoEMP.Value then
			pcall(special_weapon_attack, "AutoEMP", "strike", "emp", true)
		end
		if Toggles.AutoRailGun.Value then
			pcall(special_weapon_attack, "AutoRailGun", "strike", "rail", true)
		end
		if Toggles.AutoOrbital.Value then
			pcall(orbital_attack)
		end
		if Toggles.AutoBlowUpSilo.Value then
			pcall(special_weapon_attack, "AutoBlowUpSilo", "nuke")
		end
		if Toggles.AutoScramble.Value then
			pcall(scramble_jets)
		end
		if Toggles.AutoCounter.Value then
			pcall(counter_attack)
		end
	end
end)
task.spawn(function()
	while task.wait(5) do
		if Library.Unloaded then
			break
		end
		refresh_targets()
	end
end)
task.spawn(function()
	while task.wait(2) do
		if Library.Unloaded then
			break
		end
		if Toggles.AutoHangars.Value then
			pcall(upgrade_hangars)
		end
		if Toggles.AutoShips.Value then
			pcall(upgrade_ships)
		end
		if Toggles.AutoUpgrade.Value and upgrade_allowed("Navy Ships") then
			pcall(upgrade_ships)
		end
		if Toggles.AutoDeploy.Value then
			pcall(deploy_ships)
		end
		if Toggles.AutoCrates.Value then
			pcall(buy_crates)
		end
	end
end)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
ThemeManager:ApplyToTab(Tabs.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/missiles-vs-cities")
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
end)(...)
