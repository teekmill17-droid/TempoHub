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
getgenv().TempoHoodSubtitle = "FILL WATER TANKS"
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
local tn_8, tn_10, tn_11, tn_14, tn_20, tn_22, tn_25, tn_30, tn_33, tn_35, tn_37, tn_38, tn_39
local WaterPipeUpgradeConfig
local mJ
local lJ
local mq
local m7
local l7
local lP
local mw
local Options
local md
local mV
local lV
local LocalPlayer
local Toggles
local mj
local HttpService
local l0
local mI
local SaveManager
local mp
local m6
local mO
local lO
local pipes
local nc
local mc
local mU
local lU
local mB
local WaterPipeConfig
local mi
local m_
local l_
local mH
local lH
local CurrentCamera2
local m5
local WaterGainConfig
local mN
local mu
local nb
local PlotController
local mT
local WorkerConfig
local mA
local nh
local mh
local mZ
local SlotUpgradeConfig
local mG
local mn
local m4
local l4
local connection
local lM
local mt
local na
local ma
local mS
local lS
local mz
local ng
local mg
local mY
local lY
local Label
local connection2
local m3
local l3
local mL
local RebirthConfig
local ms
local WaterTankConfig
local mR
local Library
local my
local nf
local Packets
local ButtonConfig
local mE
local ml
local m2
local l2
local mK
local lK
local mr
local m8
local l8
local mQ
local ButtonWorkerConfig
local mx
local me
local mW
local lW
local mD
local nk
local mk
local m1
function fns.onCopyLitecoinAddress()
    na(m3, "Copied Litecoin address")
end
function fns.fn33(cA)
    mZ = cA.ownedButtons or mZ
end
function fns.fn46(dY, dZ, d_)
    local p7 = mD(dY, dZ)
    local p8 = p7 and lO() >= p7
    if p8 then
        l3(d_)
    end
end
function fns.fn68(ak, al)
    return string.format('<font color="%s">%s</font>', al, ak)
end
function fns.fn76()
    local qc = lO()
    for k, v in m8 do
        local qd = ButtonConfig[v]
        if qd and not mZ[v] and (qd.Cost or 0) > 0 and qc >= qd.Cost then
            l3(Packets.RequestBuyButton, { buttonName = v })
            return
        end
    end
end
function fns.fn77(cd)
    local pt = WaterPipeConfig.Pipes[cd]
    return pt and pt.MoneyMultiplier or 0
end
function fns.fn90()
    local sA = {}
    for k, v in { Toggles, Options } do
        for k, v in v do
            local sB = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if sB then
                local sB_1 = mU(k, v)
                if sB_1 then
                    sA[#sA + 1] = sB_1
                end
            end
        end
    end
    table.sort(sA, function(hE, hF)
        if hE.type ~= hF.type then
            return hE.type < hF.type
        end
        return hE.idx < hF.idx
    end)
    return { objects = sA }
end
function fns.fn114(hh, hi)
    local sn_1 = (hh == "Toggle" and Toggles or Options)[hi]
    local sm_2 = type(sn_1) == "table" and sn_1.Type == hh
    return sm_2 and sn_1 or nil
end
function fns.onCopyEthereumAddress()
    na(mV, "Copied Ethereum address")
end
function fns.fn140(bS, bT)
    return bS[tostring(bT)]
end
function fns.fn159(O, P)
    local oo = tonumber(O) or 0
    local op = tonumber(P) or 0
    return oo < op
end
function fns.fn163()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local oA = leaderstats and leaderstats:FindFirstChild("Money")
    local oz_1 = oA
    if oA then
        oA = tonumber(oz_1.Value)
    end
    return oA or 0
end
function fns.fn212()
    local oG_1
    local oF_1
    oF_1, oG_1 = pcall(PlotController.GetPlot)
    if oF_1 then
        return oG_1
    end
    return nil
end
function fns.fn221(b0)
    local b2 = math.min(b0, RebirthConfig.LateGrowthRebirth)
    return RebirthConfig.BaseCost * RebirthConfig.CostGrowth ^ b2 * RebirthConfig.LateCostGrowth ^ math.max(b0 - RebirthConfig.LateGrowthRebirth, 0)
end
function fns.fn229(bM)
    local pd = nc()
    local pe = pd and bM and bM:IsA("BasePart")
    if not pe then
        return
    end
    pd.CFrame = bM.CFrame * CFrame.new(0, 1.15, 0)
    pd.AssemblyLinearVelocity = Vector3.zero
    l4(bM)
end
function fns.fn246(eR)
    local qT = eR.Parent
    while true do
        if not qT then
            return nil
        end
        local qU = qT:IsA("Model") and WaterPipeConfig.Pipes[qT.Name]
        if qU then
            break
        end
        qT = qT.Parent
    end
    return qT.Name
end
function fns.fn259(bF)
    local pa = nc()
    if not (pa and bF) then
        return
    end
    if os.clock() - mh < 0.15 then
        return
    end
    mh = os.clock()
    if firetouchinterest then
        pcall(firetouchinterest, pa, bF, 0)
        pcall(firetouchinterest, bF, pa, 0)
        ma = true
        l7 = bF
    end
end
function fns.fn268(bV, bW)
    local pg = tonumber(bW) or 1
    local ph = mY(bV, pg + 1)
    return ph and ph.Cost or nil
end
function fns.fn276(bt)
    local o2 = nc()
    local o3 = o2 and bt and bt:IsA("BasePart")
    if not o3 then
        return
    end
    o2.CFrame = bt.CFrame * CFrame.new(0, bt.Size.Y / 2 + 3, 0)
    o2.AssemblyLinearVelocity = Vector3.zero
end
function fns.fn279(cL)
    mz = true
    pipes = cL.pipes
    local pX = tonumber(cL.rollDuration) or 1
    task.delay(pX + 0.4, function()
        mz = false
    end)
end
function fns.fn294(et, eu, ev, ew)
    local qn = lO()
    for k, v in et do
        if not eu[v] then
            local qo = ev[v]
            if qo and qn >= (qo.Cost or 0) then
                l3(ew)
            end
            return
        end
    end
end
function fns.fn303(ad, ae)
    if setclipboard then
        setclipboard(ad)
    elseif toclipboard then
        toclipboard(ad)
    end
    Library:Notify(ae)
end
function fns.fn336()
    local oL = m2()
    local oM = oL and oL:FindFirstChild("ButtonPart")
    if not oM then
        return nil
    end
    for i, child in oM:GetChildren() do
        if child:IsA("Model") then
            local Button = child:FindFirstChild("Button")
            local oM_1 = Button and Button:IsA("BasePart")
            if oM_1 then
                return Button
            end
        end
    end
    return nil
end
function fns.antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local si = tick() - lY
            local sj = tick() - lU
            if si >= 300 and sj >= 60 then
                pcall(nf)
            else
                if si < 300 and sj >= 300 then
                    pcall(nf)
                end
            end
        end
    end
end
function fns.fn361()
    m5(false)
    ms()
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
    local tg = lP()
    if tg then
        tg.PlatformStand = false
        tg.WalkSpeed = 16
    end
end
function fns.worker()
    local p5_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local p4 = math.floor(os.clock() - me)
        if p4 < 60 then
            p5_1 = p4 .. "s"
        elseif p4 < 3600 then
            p5_1 = string.format("%dm %ds", math.floor((p4) / (60)), p4 % 60)
        else
            p5_1 = string.format("%dh %dm", math.floor((p4) / (3600)), math.floor((p4 % 3600) / (60)))
        end
        Label:SetText(mk("Session time", p5_1, l0))
    end
end
function fns.fn453(cp)
    lV = cp.waterAmount or lV
    lS = cp.maxWater or lS
    local pz_2 = tonumber(cp.waterTankLevel) or lM
    lM = pz_2
end
function fns.onRscripts()
    na(mp, "Copied Rscripts profile to clipboard")
end
function fns.fn475(an, ao, ap)
    return string.format("<b>%s</b> %s %s", an, my("-", "#5a6070"), my(ao, ap))
end
function fns.fn537()
    for k, v in mc do
        if mE[v.Id] ~= true then
            if (not v.ParentId or mE[v.ParentId] == true) and m1 >= (v.Cost or 0) then
                l3(Packets.RequestBuySkillTreeUpgrade, { upgradeId = v.Id })
                return
            end
        end
    end
end
function fns.fn571(cE)
    mN = cE or mN
end
function fns.fn574(cy)
    local pF = (tonumber(cy.level))
    local pJ = if pF then 1 else 0
    local pH = 3127 * pJ + 978 * (1 - pJ)
    local pI = 719 * pJ + 3835 * (1 - pJ)
    if not ((pH * 2838 + pI * 3577 + pH * pI) % 16777213 == 13694602) then
        pF = nb
    end
    nb = pF
end
function fns.onExportConfigToClipboard()
    local sY_1
    local sX_1
    sX_1, sY_1 = pcall(HttpService.JSONEncode, HttpService, mw())
    if not sX_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local sX_2 = setclipboard
    local s2 = if sX_2 then 1 else 0
    local s0 = 1791 * s2 + 792 * (1 - s2)
    local s1 = 454 * s2 + 3726 * (1 - s2)
    if not ((s0 * 1029 + s1 * 3978 + s0 * s1) % 16777213 == 4462065) then
        sX_2 = toclipboard
    end
    local sZ = sX_2
    local sX_3 = type(sZ) ~= "function"
    local s2_1 = if sX_3 then 1 else 0
    local s0_1 = 3998 * s2_1 + 2831 * (1 - s2_1)
    local s1_1 = 666 * s2_1 + 2018 * (1 - s2_1)
    if not ((s0_1 * 3932 + s1_1 * 2913 + s0_1 * s1_1) % 16777213 == 3545649) then
        sX_3 = not pcall(sZ, sY_1)
    end
    if sX_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
function fns.fn646(ct)
    local pB = tonumber(ct.level) or lJ
    lJ = pB
end
function fns.fn662()
    return lV <= 0.05
end
function fns.onImportConfigFromClipboardTex()
    local s5_1
    local s3 = Options.SaveManager_ImportSource.Value
    local s3_1
    local s9 = if s3 then 1 else 0
    local s7 = 3610 * s9 + 2426 * (1 - s9)
    local s8 = 1772 * s9 + 1271 * (1 - s9)
    if not ((s7 * 954 + s8 * 749 + s7 * s8) % 16777213 == 11168088) then
        s3 = ""
    end
    local s4 = tostring(s3):match("^%s*(.-)%s*$")
    if s4 == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    s3_1, s5_1 = pcall(HttpService.JSONDecode, HttpService, s4)
    local s4_1 = not s3_1
    local s9_1 = if s4_1 then 1 else 0
    local s7_1 = 1527 * s9_1 + 2537 * (1 - s9_1)
    local s8_1 = 793 * s9_1 + 1074 * (1 - s9_1)
    if not ((s7_1 * 2359 + s8_1 * 3713 + s7_1 * s8_1) % 16777213 == 7757513) then
        s4_1 = type(s5_1) ~= "table"
    end
    local s9_2 = if s4_1 then 1 else 0
    local s7_2 = 896 * s9_2 + 1943 * (1 - s9_2)
    local s8_2 = 3146 * s9_2 + 1763 * (1 - s9_2)
    if not ((s7_2 * 2223 + s8_2 * 325 + s7_2 * s8_2) % 16777213 == 5833074) then
        s4_1 = type(s5_1.objects) ~= "table"
    end
    if s4_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local s3_2 = 0
    for k, v in s5_1.objects do
        if lK(v) then
            s3_2 += 1
        end
    end
    if s3_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local s5_2 = s3_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(s3_2, s5_2), 6)
end
function fns.fn683()
    if lS <= 0 then
        return false
    end
    return lV >= lS * ((Options.LeaveAtPercent and Options.LeaveAtPercent.Value or 100) / 100)
end
function fns.fn696()
    m5(Toggles.AntiGameplayPause.Value)
end
function fns.onInputChanged(g1)
    local UserInputType = g1.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        lY = tick()
    end
end
function fns.fn711()
    na(mt, "Copied Discord invite to clipboard")
end
function fns.fn712(cv)
    local pD = tonumber(cv.luckLevel) or nk
    nk = pD
    local pD_1 = tonumber(cv.speedLevel) or ng
    ng = pD_1
end
function fns.fn715(cI)
    m1 = cI.crystals or m1
    mE = cI.ownedUpgrades or mE
    mE.Root = true
end
local function onCopyBitcoinAddress()
    na(m_, "Copied Bitcoin address")
end
local function fn723()
    local qa = l2("BuyUpgradeList")
    if qa["Water Gain"] then
        mn(WaterGainConfig, lJ, Packets.RequestBuyWaterGain)
    end
    if qa["Roll Luck"] then
        mn(WaterPipeUpgradeConfig.Luck, nk, Packets.RequestBuyRollLuck)
    end
    if qa["Roll Speed"] then
        mn(WaterPipeUpgradeConfig.Speed, ng, Packets.RequestBuyRollSpeed)
    end
    if qa.Slot then
        mn(SlotUpgradeConfig, nb, Packets.RequestBuySlot)
    end
end
local function fn725()
    pipes = nil
end
local function fn726()
    local o5 = nc()
    local o6 = ma
    local o7 = l7
    if o6 then
        o6 = firetouchinterest
    end
    if o6 and o5 and o7 then
        pcall(firetouchinterest, o5, o7, 1)
        pcall(firetouchinterest, o7, o5, 1)
    end
    ma = false
    l7 = nil
end
local function fn741(hp, hq)
    local Type = hq.Type
    if Type == "Toggle" then
        return { idx = hp, type = "Toggle", value = hq.Value == true }
    elseif Type == "Slider" then
        return { idx = hp, type = "Slider", value = tostring(hq.Value) }
    elseif Type == "Dropdown" then
        return { idx = hp, type = "Dropdown", multi = hq.Multi == true, value = hq.Value }
    elseif Type == "Input" then
        local su = hq.Value or ""
        return { idx = hp, type = "Input", text = tostring(su) }
    elseif Type == "ColorPicker" then
        return { idx = hp, type = "ColorPicker", value = hq.Value:ToHex(), transparency = hq.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = hp,
            type = "KeyPicker",
            mode = hq.Mode,
            key = hq.Value,
            modifiers = hq.Modifiers,
            toggled = hq.Toggled
        }
    else
        return nil
    end
end
local function autoUpgradeWaterTankLoop()
    while not Library.Unloaded do
        task.wait(0.2)
        if Toggles.AutoUpgradeWaterTank.Value then
            local ru_1 = mD(WaterTankConfig, lM)
            local rv_1 = ru_1 and lO() >= ru_1
            if rv_1 then
                l3(Packets.RequestUpgradeWaterTank)
            end
        end
        if Toggles.AutoBuyUpgrades.Value then
            lW()
        end
        if Toggles.AutoBuyButtons.Value then
            mJ()
        end
        if Toggles.AutoBuyWorkers.Value then
            l_(mK, mT, WorkerConfig, Packets.RequestBuyWorker)
        end
        if Toggles.AutoBuyButtonWorkers.Value then
            l_(mq, mN, ButtonWorkerConfig, Packets.RequestBuyButtonWorker)
        end
        if Toggles.AutoRebirth.Value then
            if lO() >= mg(m6) then
                l3(Packets.RequestRebirth)
            end
        end
        if Toggles.AutoBuyTreeNodes.Value then
            mQ()
        end
        local ru_2 = Toggles.AutoRoll.Value and not mz and not mS() and os.clock() - mj > 0.8
        if ru_2 then
            mj = os.clock()
            l3(Packets.RequestRollWaterPipe)
        end
        if Toggles.AutoPickupPipe.Value and not mz then
            mu()
        end
    end
end
local function onCopyUSDTAddress()
    na(mO, "Copied USDT address")
end
local function fn776()
    local CurrentCamera = mI.CurrentCamera
    if not CurrentCamera then
        return
    end
    m4:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    m4:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    lU = tick()
end
local function onCopyVenmoLink()
    na(mx, "Copied Venmo link")
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local rF_1 = lP()
        if rF_1 then
            rF_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function onInputBegan()
    lY = tick()
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            m5(true)
        end
    end
end
local function fn843()
    if not Toggles.WalkSpeedEnabled.Value then
        local rX = lP()
        if rX then
            rX.WalkSpeed = 16
        end
    end
end
local function fn844(U, V)
    return (U.Cost or 0) < (V.Cost or 0)
end
local function onCopyPayPalLink()
    na(mB, "Copied PayPal link")
end
local function fn856()
    local Character = LocalPlayer.Character
    local o0 = Character and Character:FindFirstChild("HumanoidRootPart")
    return o0
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in Character:GetDescendants() do
                local rx_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if rx_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onCopySolanaAddress()
    na(mH, "Copied Solana address")
end
local function onCopyJoinScript_JobID()
    local c8 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, mA)
    na(c8, "Copied join script to clipboard")
end
local function fn899(cS)
    local DiscordGroup = cS:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mR })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mR })
end
local function fn910()
    local oU = m2()
    local oV = oU and oU:FindFirstChild("Spawn")
    local oU_1 = oV
    if oV then
        oV = oU_1:IsA("BasePart")
    end
    if oV then
        return oU_1
    end
    return nil
end
local function fn916(G, H)
    return (ButtonConfig[G].Cost or 0) < (ButtonConfig[H].Cost or 0)
end
local function fn949()
    local Character = LocalPlayer.Character
    local oY = Character and Character:FindFirstChildOfClass("Humanoid")
    return oY
end
local function fn965()
    local p0_1
    local p__1
    if identifyexecutor then
        p0_1, p__1 = identifyexecutor()
        local p1 = p0_1 ~= ""
        local p2 = type(p0_1) == "string" and p1
        if p2 then
            local p1_1 = type(p__1) == "string" and p__1 ~= "" and p0_1 .. " " .. p__1
            nh = p1_1 or p0_1
        end
    end
end
local function fn967(cG)
    local pQ = cG.rebirths
    local pU = if pQ then 1 else 0
    local pS = 1664 * pU + 1567 * (1 - pU)
    local pT = 725 * pU + 1665 * (1 - pU)
    if not ((pS * 2350 + pT * 3288 + pS * pT) % 16777213 == 7500600) then
        pQ = m6
    end
    m6 = pQ
end
local function fn985(cC)
    mT = cC or mT
end
local function onRenderStepped(f2)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local rK_1 = lP()
        if rK_1 then
            rK_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local rK_3 = nc()
        local rL_1 = lP()
        if rK_3 and rL_1 then
            rL_1.PlatformStand = true
            local rL_2 = Vector3.zero
            if m7:IsKeyDown(Enum.KeyCode.W) then
                rL_2 += CurrentCamera2.CFrame.LookVector
            end
            local rR_1 = if m7:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if rR_1 == 1 then
                rL_2 -= CurrentCamera2.CFrame.LookVector
            end
            if m7:IsKeyDown(Enum.KeyCode.A) then
                rL_2 -= CurrentCamera2.CFrame.RightVector
            end
            if m7:IsKeyDown(Enum.KeyCode.D) then
                rL_2 += CurrentCamera2.CFrame.RightVector
            end
            if m7:IsKeyDown(Enum.KeyCode.Space) then
                rL_2 += Vector3.new(0, 1, 0)
            end
            if m7:IsKeyDown(Enum.KeyCode.LeftControl) then
                rL_2 -= Vector3.new(0, 1, 0)
            end
            rK_3.AssemblyLinearVelocity = Vector3.zero
            if rL_2.Magnitude > 0 then
                rK_3.CFrame = rK_3.CFrame + rL_2.Unit * Options.FlySpeed.Value * f2
            end
        end
    end
    if os.clock() < mr then
        return
    end
    local rK_4 = Toggles.AutoFillTank and Toggles.AutoFillTank.Value
    local rK_5 = Toggles.AutoSellTank and Toggles.AutoSellTank.Value
    if rK_4 or rK_5 then
        if rK_5 then
            if mL() then
                ml = true
            else
                local rR_2 = if mi() then 1 else 0
                if rR_2 == 1 then
                    ml = false
                end
            end
        else
            ml = false
        end
        if rK_5 and ml then
            ms()
            mW(l8())
        elseif rK_4 then
            local rK_8 = mG()
            if rK_8 then
                local rL_4 = LocalPlayer:GetAttribute("OnFillButton") == true
                local rM_3 = nc()
                local rM_4 = rM_3 and (rM_3.Position - rK_8.Position).Magnitude > 6
                if rL_4 then
                    if rM_4 then
                        lH(rK_8)
                    end
                else
                    local rR_3 = if os.clock() - md > 0.4 then 1 else 0
                    if rR_3 == 1 then
                        md = os.clock()
                        lH(rK_8)
                    else
                        l4(rK_8)
                    end
                end
            end
        else
            ms()
        end
    end
end
local function fn1001(eJ)
    local qH = m2()
    local qI = qH and qH:FindFirstChild("WaterPipe")
    if not qI then
        return
    end
    for i, descendant in qI:GetDescendants() do
        local qH_2 = descendant:IsA("ProximityPrompt") and descendant.Enabled and descendant.ActionText == "Pick Up"
        if qH_2 then
            eJ(descendant)
        end
    end
end
local function fn1003(b4)
    local pj = Options[b4]
    local pk = {}
    if not pj then
        return pk
    end
    local Value = pj.Value
    if type(Value) ~= "table" then
        return pk
    end
    for k, v in Value do
        if v == true then
            pk[k] = true
        else
            local pj_1 = type(k) == "number" and type(v) == "string"
            if pj_1 then
                pk[v] = true
            end
        end
    end
    return pk
end
local function fn1008()
    if not Toggles.Fly.Value then
        local rV = lP()
        if rV then
            rV.PlatformStand = false
        end
    end
end
local function fn1018(K, L)
    local ol = tonumber(K) or 0
    local om = tonumber(L) or 0
    return ol < om
end
lH = nil
SaveManager = nil
lJ = nil
lK = nil
RebirthConfig = nil
lM = nil
lO = nil
lP = nil
ButtonWorkerConfig = nil
Library = nil
lS = nil
WorkerConfig = nil
lU = nil
lV = nil
lW = nil
ButtonConfig = nil
lY = nil
SlotUpgradeConfig = nil
l_ = nil
l0 = nil
WaterPipeUpgradeConfig = nil
l2 = nil
l3 = nil
l4 = nil
WaterGainConfig = nil
l7 = nil
l8 = nil
WaterTankConfig = nil
ma = nil
PlotController = nil
mc = nil
md = nil
me = nil
Packets = nil
mg = nil
mh = nil
mi = nil
mj = nil
mk = nil
ml = nil
connection2 = nil
mn = nil
CurrentCamera2 = nil
mp = nil
mq = nil
mr = nil
ms = nil
mt = nil
local lN, l6
mu = nil
pipes = nil
mw = nil
mx = nil
my = nil
mz = nil
mA = nil
mB = nil
LocalPlayer = nil
mD = nil
mE = nil
Label = nil
mG = nil
mH = nil
mI = nil
mJ = nil
mK = nil
mL = nil
connection = nil
mN = nil
mO = nil
mQ = nil
mR = nil
mS = nil
mT = nil
mU = nil
mV = nil
mW = nil
mY = nil
mZ = nil
m_ = nil
HttpService = nil
m1 = nil
m2 = nil
m3 = nil
m4 = nil
m5 = nil
m6 = nil
m7 = nil
m8 = nil
na = nil
nb = nil
nc = nil
Options = nil
nf = nil
ng = nil
local CoreGui, GuiService, m9, ne
nh = nil
WaterPipeConfig = nil
Toggles = nil
nk = nil
m7, m4, HttpService, GuiService, CoreGui, mI, LocalPlayer, mt, mp, Packets, PlotController, WaterTankConfig, WaterGainConfig, WaterPipeUpgradeConfig, SlotUpgradeConfig, ButtonConfig, WorkerConfig, ButtonWorkerConfig, RebirthConfig, WaterPipeConfig, m8 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local tn_26 = game:GetService("Players")
local tn_15 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
if (false and not HttpService and (HttpService or WaterPipeUpgradeConfig) and (not PlotController and RunService and (false or HttpService)) or RunService and WaterPipeUpgradeConfig and (not PlotController or PlotController) and (PlotController or PlotController or "https://discord.gg/K7Qxnxkk46")) and (HttpService and not WaterPipeUpgradeConfig and (HttpService and not WaterPipeUpgradeConfig) and (PlotController and WaterPipeUpgradeConfig and (not PlotController or PlotController)) or (PlotController and not WaterPipeUpgradeConfig and (false and not HttpService) or (not RunService or false) and (PlotController and PlotController))) or not ((false and not HttpService and (HttpService or WaterPipeUpgradeConfig) and (not PlotController and RunService and (false or HttpService)) or RunService and WaterPipeUpgradeConfig and (not PlotController or PlotController) and (PlotController or PlotController or "https://discord.gg/K7Qxnxkk46")) and (HttpService and not WaterPipeUpgradeConfig and (HttpService and not WaterPipeUpgradeConfig) and (PlotController and WaterPipeUpgradeConfig and (not PlotController or PlotController)) or (PlotController and not WaterPipeUpgradeConfig and (false and not HttpService) or (not RunService or false) and (PlotController and PlotController)))) then
    m7 = game:GetService("UserInputService")
    m4 = game:GetService("VirtualUser")
else
    m4 = game:GetService("UserInputService")
    m7 = game:GetService("VirtualUser")
end
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
mI = game:GetService("Workspace")
LocalPlayer = tn_26.LocalPlayer
local tn_31 = "Fill Water Tanks"
mt = "https://discord.gg/K7Qxnxkk46"
mp = "https://discord.gg/K7Qxnxkk46"
local tn_40 = tn_15:WaitForChild("Modules")
local tn_12 = tn_40:WaitForChild("Configs")
Packets = require(tn_40:WaitForChild("Packets"))
PlotController = require(tn_40:WaitForChild("PlotController"))
WaterTankConfig = require(tn_12:WaitForChild("WaterTankConfig"))
WaterGainConfig = require(tn_12:WaitForChild("WaterGainConfig"))
WaterPipeUpgradeConfig = require(tn_12:WaitForChild("WaterPipeUpgradeConfig"))
SlotUpgradeConfig = require(tn_12:WaitForChild("SlotUpgradeConfig"))
ButtonConfig = require(tn_12:WaitForChild("ButtonConfig"))
WorkerConfig = require(tn_12:WaitForChild("WorkerConfig"))
ButtonWorkerConfig = require(tn_12:WaitForChild("ButtonWorkerConfig"))
RebirthConfig = require(tn_12:WaitForChild("RebirthConfig"))
local tn_2 = require(tn_12:WaitForChild("SkillTreeConfig"))
WaterPipeConfig = require(tn_12:WaitForChild("WaterPipeConfig"))
local tn_5 = { "Water Gain", "Roll Luck", "Roll Speed", "Slot" }
m8 = {}
for k in ButtonConfig do
    m8[#m8 + 1] = k
end
mK = nil
tn_26 = 2
repeat
    tn_12 = { "knvsu", "lxoeqnf", "jmtoitjicwo", "tgxckj", "bmu", "osnrhhv", "hpwkjsvobt", "zypdmit" }
    local uf = tn_26
    tn_40 = tn_12[uf % 8 + 1]
    if tn_40:len() >= tn_40:gsub("(.)", "%1%1", uf % 3 % 2 + 1):len() then
        table.sort(mK, fn916)
        m8 = {}
    else
        table.sort(m8, fn916)
        mK = {}
    end
    tn_26 = (tn_26 + 2) % 4
until (tn_26 * 3 + 1) % 4 == 1
for k in WorkerConfig do
    mK[#mK + 1] = tostring(k)
end
mq = nil
tn_26 = 2
repeat
    local t1 = bit32.rrotate(bit32.bxor(bit32.lrotate(tn_26, 18), string.byte(tostring(mq))), 10)
    if bit32.bxor(bit32.lrotate(bit32.bxor(t1, 3704971204), 10), 1434391411) == bit32.lrotate(t1, 10) then
        table.sort(mK, fn1018)
        mq = {}
    else
        table.sort(mq, fn1018)
        mK = {}
    end
    tn_26 = (tn_26 + 0) % 8
until (tn_26 * 5 + 6) % 8 == 0
for k in ButtonWorkerConfig do
    mq[#mq + 1] = tostring(k)
end
mc = nil
tn_26 = 1
repeat
    local t3 = bit32.rrotate(bit32.bxor(bit32.lrotate(tn_26, 27), string.byte(tostring(mc))), 8)
    if bit32.bxor(bit32.lrotate(bit32.bxor(t3, 4195098610), 10), 813681640) ~= bit32.lrotate(t3, 10) then
        table.sort(mc, fns.fn159)
        mq = {}
    else
        table.sort(mq, fns.fn159)
        mc = {}
    end
    tn_26 = (tn_26 + 2) % 4
until (tn_26 * 1 + 0) % 4 == 3
for k, v in tn_2.Nodes do
    tn_26 = v.Id and v.Id ~= "Root"
    if tn_26 then
        mc[#mc + 1] = v
    end
end
Library, SaveManager, Toggles, Options, l0, lV, lS, na, mR, my, mk = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(mc, fn844)
Library = getgenv().Library
tn_40 = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
na = fns.fn303
mR = fns.fn711
my = fns.fn68
mk = fns.fn475
tn_2 = "#7fd47f"
tn_15 = "#6ec1ff"
l0 = "#e8a34d"
local tn_28 = "#8b93a3"
lV = 0
lS = 0
tn_26 = (tonumber(LocalPlayer:GetAttribute("WaterTankLevel")))
local oc = if tn_26 then 1 else 0
local oa = 1986 * oc + 2041 * (1 - oc)
local ob = 4088 * oc + 2182 * (1 - oc)
if not ((oa * 3804 + ob * 759 + oa * ob) % 16777213 == 1999091) then
    tn_26 = 1
end
lM, lJ, nk, ng, nb, m6, m1, mZ, mT, mN, mE, mz, pipes, mr, ml, mj, mh, md, ma, l7, l3, lO, m2, mG, l8, lP, nc, mW, ms, l4, lH, mY, mD, mg, l2, m9, mL, mi, tn_20 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if not l7 and mL and (not mZ and mr) and (mr or l7 or mr and not mL) or not (not l7 and mL and (not mZ and mr) and (mr or l7 or mr and not mL)) then
    lM = tn_26
end
lJ = 1
nk = 1
ng = 1
nb = 1
m6 = 0
m1 = 0
if ((mz or tn_20 or (mZ or not tn_20)) and (not mZ or tn_20 or (not tn_20 or tn_20)) or (not mz and mz and (mz or not mZ) or (not ng or mZ) and (not mz or not tn_20))) and ((not tn_20 or tn_20 or (not ng or not tn_20)) and ((tn_20 or not mZ) and (ng and not mz)) or (ng and ng and (not mz and mZ) or (not mZ or not mz) and (not mZ and ng))) or not (((mz or tn_20 or (mZ or not tn_20)) and (not mZ or tn_20 or (not tn_20 or tn_20)) or (not mz and mz and (mz or not mZ) or (not ng or mZ) and (not mz or not tn_20))) and ((not tn_20 or tn_20 or (not ng or not tn_20)) and ((tn_20 or not mZ) and (ng and not mz)) or (ng and ng and (not mz and mZ) or (not mZ or not mz) and (not mZ and ng)))) then
    mZ = {}
    mT = {}
    mN = {}
    mE = { Root = true }
    mz = false
else
    mT = {}
    mE = {}
    mz = {}
    mN = { Root = true }
    mZ = false
end
pipes = nil
mr = 0
ml = false
mj = 0
mh = 0
md = 0
ma = false
l7 = nil
l3 = function(aS, aT)
    if not aS then
        return
    end
    pcall(function()
        if aT == nil then
            aS.send()
        else
            aS.send(aT)
        end
    end)
end
lO = fns.fn163
m2 = fns.fn212
mG = fns.fn336
l8 = fn910
lP = fn949
nc = fn856
mW = fns.fn276
ms = fn726
l4 = fns.fn259
lH = fns.fn229
mY = fns.fn140
mD = fns.fn268
mg = fns.fn221
l2 = fn1003
m9 = fns.fn77
mL = fns.fn683
mi = fns.fn662
Packets.UpdateWater.listen(fns.fn453)
Packets.SyncWaterGain.listen(fns.fn646)
Packets.SyncRollUpgrades.listen(fns.fn712)
Packets.SyncSlot.listen(fns.fn574)
Packets.SyncButtons.listen(fns.fn33)
Packets.SyncWorkers.listen(fn985)
Packets.SyncButtonWorkers.listen(fns.fn571)
Packets.SyncRebirth.listen(fn967)
Packets.SyncSkillTree.listen(fns.fn715)
Packets.WaterPipeRollStarted.listen(fns.fn279)
Packets.WaterPipePickedUp.listen(fn725)
l3(Packets.RequestSyncWaterGain)
l3(Packets.RequestSyncRollUpgrades)
l3(Packets.RequestSyncSlot)
l3(Packets.RequestSyncButtons)
l3(Packets.RequestSyncWorkers)
l3(Packets.RequestSyncButtonWorkers)
l3(Packets.RequestSyncRebirth)
l3(Packets.RequestSyncSkillTree)
l3(Packets.RequestSyncWaterTank)
tn_12 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = mt, Copyable = true }, "|", tn_31 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local tn_7 = {
    Info = tn_12:AddTab("Info", "info"),
    Main = tn_12:AddTab("Main", "droplets"),
    Player = tn_12:AddTab("Player", "person-standing"),
    Settings = tn_12:AddTab("Settings", "settings")
}
if (l8 and not lO or not l8 and mG or (not mZ or mG) and (l2 and mZ)) and (not mG or mG or (not l8 or not l2) or (mG and not l2 or (not lO or not l2))) and not ((l8 and not lO or not l8 and mG or (not mZ or mG) and (l2 and mZ)) and (not mG or mG or (not l8 or not l2) or (mG and not l2 or (not lO or not l2)))) then
    ng = fn899
else
    tn_20 = fn899
end
for k, v in tn_7 do
    tn_20(v)
end
nh, tn_12, tn_35, Label, mA, tn_33 = nil, nil, nil, nil, nil, nil
tn_26 = 10
repeat
    tn_20 = (tn_26 * 2 + 0) % 3 + 1
    if tn_20 <= 2 then
        if tn_20 <= 1 then
            tn_20 = {
                "mnmyakjai",
                "lndprktqprrm",
                "cusggdffh",
                "okuasnim",
                "yjiu",
                "qewk",
                "owkweojmyxvs",
                "oiitqipj",
                "tsccbytae",
                "tdpt",
                "oznxqdcogkne",
                "oum"
            }
            if tn_20[(tn_26 * 85 + 70) % 12 + 1] <= tn_20[(tn_26 * 85 + 70) % 12 + 1] then
                mA = tostring(game.JobId)
            else
                tn_35 = tostring(game.JobId)
            end
            tn_26 = (tn_26 + 11) % 12
        else
            tn_20 = {
                "nmbr",
                "exkz",
                "ftsgihpqvhg",
                "ccfgm",
                "kiufuszar",
                "bjwxvsyylzg",
                "kodbmvinhsla",
                "jremybjtmf",
                "rte",
                "dth",
                "pcrdwlhhmi",
                "oceidw",
                "uwuiyupwp",
                "vlfcwhgvgrw",
                "vnrkvrvmlb"
            }
            if tn_20[(tn_26 * 50 + 61) % 15 + 1] < tn_20[(tn_26 * 50 + 61) % 15 + 1] then
                mA = #tn_33 > 18
            else
                tn_33 = #mA > 18
            end
            tn_26 = (tn_26 + 8) % 12
        end
    else
        tn_20 = (vector.create((tn_26 * 5 + 8) % 11 + 1, (tn_26 * 11 + 4) % 13 + 1, (tn_26 * 14 + 14) % 17 + 1))
        tn_22 = (vector.create((tn_26 * 6 + 1) % 11 + 1, (tn_26 * 9 + 12) % 13 + 1, (tn_26 * 15 + 14) % 17 + 1))
        tn_8 = (vector.create((tn_26 * 3 + 3) % 11 + 1, (tn_26 * 1 + 6) % 13 + 1, (tn_26 * 8 + 12) % 17 + 1))
        tn_37 = (vector.create((tn_26 * 5 + 3) % 5 + 1, (tn_26 * 2 + 2) % 7 + 1, (tn_26 * 3 + 7) % 9 + 1))
        if vector.dot(vector.cross(tn_20, (vector.cross(tn_22, tn_8))), tn_37) == vector.dot(tn_22 * vector.dot(tn_20, tn_8) - tn_8 * vector.dot(tn_20, tn_22), tn_37) + 4 then
            l0 = "Unknown"
            pcall(fn965)
            nh = Label.Info:AddLeftGroupbox("Account", "circle-user")
            nh:AddLabel(tn_12("User", mk.Name, LocalPlayer), true)
            nh:AddLabel(tn_12("Status", "Keyless", LocalPlayer), true)
            nh:AddLabel(tn_12("Executor", l0, LocalPlayer), true)
            tn_31 = Label.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            tn_31:AddLabel(tn_2(tn_15 .. " [" .. tostring(game.PlaceId) .. "]", tn_7), true)
            tn_31:AddLabel(tn_12("Place ID", tostring(game.PlaceId), tn_7), true)
            my = tn_31:AddLabel(tn_12("Session time", "0s", tn_35), true)
        else
            nh = "Unknown"
            pcall(fn965)
            tn_12 = tn_7.Info:AddLeftGroupbox("Account", "circle-user")
            tn_12:AddLabel(mk("User", LocalPlayer.Name, tn_2), true)
            tn_12:AddLabel(mk("Status", "Keyless", tn_2), true)
            tn_12:AddLabel(mk("Executor", nh, tn_2), true)
            tn_35 = tn_7.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            tn_35:AddLabel(my(tn_31 .. " [" .. tostring(game.PlaceId) .. "]", tn_15), true)
            tn_35:AddLabel(mk("Place ID", tostring(game.PlaceId), tn_15), true)
            Label = tn_35:AddLabel(mk("Session time", "0s", l0), true)
        end
        tn_26 = (tn_26 + 5) % 12
    end
until (tn_26 * 5 + 5) % 12 == 7
if tn_33 then
    tn_26 = 6
    repeat
        tn_12 = {
            "hgaq",
            "nwbzshga",
            "ocq",
            "ndbfbhb",
            "qsc",
            "ojilwdbuw",
            "eqedzuvxki",
            "qanaakcrb",
            "qxhsvafwrar",
            "wvb",
            "cvd"
        }
        local tO = tn_26
        tn_20 = tn_12[tO % 11 + 1]
        if tn_20:len() <= tn_20:reverse():rep(tO % 3 + 2):len() then
            tn_33 = string.sub(mA, 1, 18) .. "..."
        else
            mA = string.sub(tn_33, 1, 18) .. "..."
        end
        tn_26 = (tn_26 + 3) % 8
    until (tn_26 * 5 + 1) % 8 == 6
end
tn_26 = tn_33 or mA
me, m3, m_, mV, mO, mH, mB, mx, CurrentCamera2, lY, lU, connection, connection2, mn, lW, mJ, l_, mQ, l6, ne, mS, mu, m5, nf, lN, mU, mw, lK = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local tn_1 = tn_26
tn_35:AddLabel(mk("Server", tn_1, tn_28), true)
tn_35:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
me = os.clock()
task.spawn(fns.worker)
tn_33 = tn_7.Info:AddRightGroupbox("Scripts", "package")
tn_33:AddLabel(my("Included in this hub", tn_28), true)
tn_33:AddLabel(my(tn_31, tn_15), true)
tn_12 = tn_7.Info:AddRightGroupbox("Features", "list")
tn_12:AddLabel(my("Automation", tn_15), true)
tn_12:AddLabel(my("Shop", l0), true)
tn_12:AddLabel(my("Player", tn_28), true)
local SocialsGroup = tn_7.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = mR })
SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
local TempoHubGroup = tn_7.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = mR })
m3 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
m_ = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
mV = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
mO = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
mH = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
mB = ""
mx = ""
tn_30, tn_14, tn_39, tn_11, tn_25, tn_38, tn_10 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
local DonationsGroup = tn_7.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(my("All donations are optional but appreciated.", l0), true)
DonationsGroup:AddLabel(my("If you donate you get a special role, just PING after you donate.", tn_2), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(my("LTC / Litecoin", tn_30), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = fns.onCopyLitecoinAddress })
DonationsGroup:AddLabel(my("BTC / Bitcoin", tn_14), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(my("ETH / Ethereum", tn_39), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
DonationsGroup:AddLabel(my("USDT", tn_11), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(my("Solana", tn_25), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(my("PayPal", tn_38), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(my("Venmo", tn_10), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(my("Don't have any of the listed currencies but still wanna donate?", tn_28), true)
DonationsGroup:AddLabel(my("DM me and we'll work something out.", tn_15), true)
local FaqGroup = tn_7.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FarmGroup = tn_7.Main:AddLeftGroupbox("Farm", "droplets")
FarmGroup:AddToggle("AutoFillTank", { Text = "Auto Fill Tank", Default = false })
FarmGroup:AddToggle("AutoSellTank", { Text = "Auto Step Off Tank to Sell", Default = false })
FarmGroup:AddSlider("LeaveAtPercent", { Text = "Leave At", Default = 100, Min = 1, Max = 100, Rounding = 0, Suffix = "%" })
FarmGroup:AddToggle("AutoUpgradeWaterTank", { Text = "Auto Upgrade Water Tank", Default = false })
FarmGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local PipeGroup = tn_7.Main:AddLeftGroupbox("Pipe", "dices")
PipeGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
PipeGroup:AddToggle("AutoPickupPipe", { Text = "Auto Pick Up Pipe", Default = false })
local ShopGroup = tn_7.Main:AddRightGroupbox("Shop", "shopping-cart")
ShopGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ShopGroup:AddDropdown("BuyUpgradeList", { Text = "Upgrades", Values = tn_5, Default = tn_5, Multi = true, SelectAllButtons = true })
ShopGroup:AddToggle("AutoBuyButtons", { Text = "Auto Buy Buttons", Default = false })
ShopGroup:AddToggle("AutoBuyWorkers", { Text = "Auto Buy Workers", Default = false })
ShopGroup:AddToggle("AutoBuyButtonWorkers", { Text = "Auto Buy Button Workers", Default = false })
ShopGroup:AddToggle("AutoBuyTreeNodes", { Text = "Auto Buy Tree Node Upgrades", Default = false })
mn = fns.fn46
lW = fn723
mJ = fns.fn76
l_ = fns.fn294
mQ = fns.fn537
l6 = fn1001
ne = fns.fn246
mS = function()
    local eW
    eW = false
    l6(function()
        eW = true
    end)
    return eW
end
mu = function()
    local ra, rb, rc, slot2
    rb = nil
    slot2 = nil
    rc = -1
    ra = nil
    l6(function(e4)
        local qW = ne(e4)
        local qX = qW and m9(qW)
        local qY = qX or 0
        if qY > rc then
            rc = qY
            ra = e4
            slot2 = nil
            local Parent = e4.Parent
            local qY_1 = Parent
            if qY_1 then
                local qZ = Parent:IsA("BasePart") and Parent
                local q_ = qZ or Parent:FindFirstChildWhichIsA("BasePart", true)
                qY_1 = q_
            end
            rb = qY_1
            if pipes then
                for k, v in pipes do
                    if v.pipeType == qW then
                        slot2 = v.slot
                        break
                    end
                end
            end
        end
    end)
    if not ra then
        if not pipes then
            return
        end
        local re = -1
        local slot
        for k, v in pipes do
            local rg = m9(v.pipeType)
            if rg > re then
                re = rg
                slot = v.slot
            end
        end
        if slot then
            l3(Packets.RequestPickupWaterPipe, { slot = slot })
        end
        return
    end
    if rb then
        mW(rb)
        mr = os.clock() + 0.6
    end
    if slot2 then
        l3(Packets.RequestPickupWaterPipe, { slot = slot2 })
    end
    if fireproximityprompt then
        pcall(fireproximityprompt, ra)
    end
end
if ((not TempoHubGroup or not mU) and (ShopGroup and not lW) and (not ShopGroup and TempoHubGroup and (lW and TempoHubGroup)) or (false or not ShopGroup or (lW or TempoHubGroup) or (not lW and m_ or not lW and false))) and (((not ShopGroup or lW) and (lW and mU) or (m_ or ShopGroup) and (lW or not TempoHubGroup)) and (false or not mU or (mU or not TempoHubGroup) or (lW or not TempoHubGroup or mU and lW))) and not (((not TempoHubGroup or not mU) and (ShopGroup and not lW) and (not ShopGroup and TempoHubGroup and (lW and TempoHubGroup)) or (false or not ShopGroup or (lW or TempoHubGroup) or (not lW and m_ or not lW and false))) and (((not ShopGroup or lW) and (lW and mU) or (m_ or ShopGroup) and (lW or not TempoHubGroup)) and (false or not mU or (mU or not TempoHubGroup) or (lW or not TempoHubGroup or mU and lW)))) then
    task.spawn(autoUpgradeWaterTankLoop)
    tn_20 = CurrentCamera2.Player:AddLeftGroupbox("Movement", "footprints")
    tn_20:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    tn_20:AddSlider("WalkSpeed", { Min = 16, Text = "WalkSpeed Amount", Rounding = 0, Max = 250, Default = 32 })
    tn_20:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    tn_20:AddToggle("NoClip", { Text = "NoClip", Default = false })
    tn_20:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    tn_8 = CurrentCamera2.Player:AddRightGroupbox("Fly", "feather")
    tn_8:AddToggle("Fly", { Text = "Fly", Default = false })
    tn_8:AddSlider("FlySpeed", { Default = 60, Min = 10, Rounding = 0, Text = "Fly Speed", Max = 400 })
    m7.Stepped:Connect(onStepped)
    RunService.JumpRequest:Connect(onJumpRequest)
    mI = tn_7.CurrentCamera
else
    task.spawn(autoUpgradeWaterTankLoop)
    tn_8 = tn_7.Player:AddLeftGroupbox("Movement", "footprints")
    tn_8:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    tn_8:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    tn_8:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    tn_8:AddToggle("NoClip", { Text = "NoClip", Default = false })
    tn_8:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    tn_20 = tn_7.Player:AddRightGroupbox("Fly", "feather")
    tn_20:AddToggle("Fly", { Text = "Fly", Default = false })
    tn_20:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    RunService.Stepped:Connect(onStepped)
    m7.JumpRequest:Connect(onJumpRequest)
    CurrentCamera2 = mI.CurrentCamera
end
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn1008)
Toggles.WalkSpeedEnabled:OnChanged(fn843)
m5 = function(gz)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not gz)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not gz
        end
    end)
    if not gz then
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
Toggles.AntiGameplayPause:OnChanged(fns.fn696)
task.spawn(antiGameplayPauseLoop)
tn_37 = tn_7.Settings:AddLeftGroupbox("Menu")
tn_37:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
lY = tick()
lU = tick()
pcall(function()
    for k, v in getconnections(LocalPlayer.Idled) do
        local sc = v
        pcall(function()
            sc:Disable()
        end)
    end
end)
nf = fn776
connection = m7.InputBegan:Connect(onInputBegan)
connection2 = m7.InputChanged:Connect(fns.onInputChanged)
tn_37:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(fns.antiAfkLoop)
tn_40:SetLibrary(Library)
tn_40:SetFolder("TempoHub")
tn_40:SaveDefault("Evil Hello Kitty")
tn_40:ApplyToTab(tn_7.Settings)
tn_40:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/FillWaterTanks")
tn_22 = SaveManager:BuildConfigSection(tn_7.Settings)
SaveManager:LoadAutoloadConfig()
lN = fns.fn114
mU = fn741
mw = fns.fn90
lK = function(hH)
    local sU
    sU = nil
    local sV = type(hH) ~= "table" or type(hH.idx) ~= "string" or type(hH.type) ~= "string" or SaveManager.Ignore[hH.idx]
    if sV then
        return false
    end
    sU = lN(hH.type, hH.idx)
    if not sU then
        return false
    end
    local sV_1 = pcall(function()
        if hH.type == "Input" then
            if type(hH.text) ~= "string" then
                return
            end
            sU:SetValue(hH.text)
        elseif hH.type == "ColorPicker" then
            sU:SetValueRGB(Color3.fromHex(hH.value), hH.transparency)
        elseif hH.type == "KeyPicker" then
            sU:SetValue({ hH.key, hH.mode, hH.modifiers })
            if hH.mode == "Toggle" and hH.toggled ~= nil then
                sU.Toggled = hH.toggled
                sU:Update()
            end
        else
            sU:SetValue(hH.value)
        end
    end)
    return sV_1
end
tn_22:AddDivider()
tn_22:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
tn_22:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
tn_22:AddButton("Import Config from Clipboard Text", fns.onImportConfigFromClipboardTex)
Library:OnUnload(fns.fn361)
end)(...)
