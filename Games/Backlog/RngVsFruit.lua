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
getgenv().TempoHoodSubtitle = "RNG VS FRUIT"
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
local Network
local connection2
local hE
local hl
local hH
local Toggles
local ho
local hr
local hN
local VirtualUser
local BladesModule
local hb
local EquipmentModule
local hx
local he
local hA
local hh
local hD
local Options
local hk
local LocalPlayer
local UpgradeModule
local BoostsModule
local hq
local ht
local hP
local ha
local Label
local hS
local hd
local hz
local hg
local hC
local hj
local hF
local hm
local connection
local hp
local AreaModule
local DailyRewardModule
local hO
local hv
local Library
local PetsModule
local PlaytimeRewardModule
local hB
local function fn48()
    local jJ = hE()
    if not jJ then
        return
    end
    local jK = {}
    local jL = jJ.Equipment
    local jX = if jL then 1 else 0
    local jV = 2818 * jX + 2530 * (1 - jX)
    local jW = 3844 * jX + 2797 * (1 - jX)
    if not ((jV * 2318 + jW * 2515 + jV * jW) % 16777213 == 10254963) then
        jL = jK
    end
    local jK_1 = jL
    local jM = jJ.EquippedEquipment or {}
    local jJ_1 = 0
    for k, v in pairs(jM) do
        if k ~= "Blade" then
            jJ_1 += #v
        end
    end
    local max = math.max
    local jN = BoostsModule:GetBoost(LocalPlayer, "Max Blade Equip") or 3
    local jO = max(0, jN - jJ_1)
    local jJ_2 = {}
    for k, v in pairs(jK_1) do
        local jM_2 = EquipmentModule.Equipment[v.Name]
        if jM_2 and jM_2.EquipmentType == "Blade" and not v.Locked then
            local jM_3 = v.Count or 1
            local kb = 1
            while kb <= jM_3 do
                table.insert(jJ_2, { GUID = k, Entry = v })
                kb += 1
            end
        end
    end
    table.sort(jJ_2, function(bL, bM)
        return hv(bM.Entry) < hv(bL.Entry)
    end)
    local jM_4 = {}
    local jN_2 = 0
    local jQ = jM.Blade or {}
    for i, v in ipairs(jQ) do
        local jL_3 = jK_1[v]
        if jL_3 and jL_3.Locked then
            jN_2 += 1
        else
            local jL_4 = jM_4[v] or 0
            jM_4[v] = jL_4 + 1
        end
    end
    local jL_5 = {}
    local jK_2 = math.min(math.max(0, jO - jN_2), #jJ_2)
    local kk = 1
    while kk <= jK_2 do
        local GUID = jJ_2[kk].GUID
        local jN_3 = jL_5[GUID] or 0
        jL_5[GUID] = jN_3 + 1
        kk += 1
    end
    for k, v in pairs(jM_4) do
        local jK_4 = v - (jL_5[k] or 0)
        local kt_1 = 1
        while kt_1 <= jK_4 do
            Network:FireServer("UnequipEquipment", k)
            kt_1 += 1
        end
    end
    for k, v in pairs(jL_5) do
        local jK_5 = v - (jM_4[k] or 0)
        local kt_2 = 1
        while kt_2 <= jK_5 do
            Network:FireServer("EquipEquipment", k)
            kt_2 += 1
        end
    end
end
local function autoZoneTravelLoop()
    local mD_1
    local mC_1, mC_4
    while not Library.Unloaded do
        task.wait(0.25)
        local Character = LocalPlayer.Character
        local my_1
        local mz = Character and Character:FindFirstChild("HumanoidRootPart")
        local mA = Character
        if mA then
            mA = Character:FindFirstChildOfClass("Humanoid")
        end
        local mz_1 = mA
        if mz and mz_1 then
            local mA_2 = nil
            if Toggles.AutoZoneTravel.Value then
                mA_2 = hx()
                if mA_2 then
                    mC_1, mD_1 = ho(mz.Position, mA_2)
                    if not mD_1 or mD_1 > 200 then
                        local mC_3 = hB(mA_2)
                        if mC_3 then
                            Character:PivotTo(mC_3.CFrame + Vector3.new(0, 4, 0))
                            task.wait(0.5)
                        end
                    end
                end
            end
            if Toggles.AutoWalkFruits.Value then
                mC_4, my_1 = ho(mz.Position, mA_2)
                if mC_4 then
                    local Value = Options.FruitDistance.Value
                    local mD_2 = mC_4.Position
                    if Value > 0 and my_1 > 0 then
                        mD_2 += (mz.Position - mC_4.Position).Unit * Value
                    end
                    mz_1:MoveTo(mD_2)
                end
            end
        end
    end
end
local function fn73(cO, cP)
    local lH_1
    local lG_1
    lH_1, lG_1 = nil, nil
    for i, child in workspace.Breakables:GetChildren() do
        local PrimaryPart = child.PrimaryPart
        local lJ = PrimaryPart
        if lJ then
            local lK_1 = not cP or child:GetAttribute("Area") == cP
            lJ = lK_1
        end
        if lJ then
            local Magnitude = (PrimaryPart.Position - cO).Magnitude
            if not lG_1 or Magnitude < lG_1 then
                lH_1, lG_1 = PrimaryPart, Magnitude
            end
        end
    end
    return lH_1, lG_1
end
local function autoSpinLoop()
    while not Library.Unloaded do
        task.wait(0.5)
        if Toggles.AutoSpin.Value then
            local mu = hE()
            if mu and (mu.Rolls or 0) > 0 then
                pcall(function()
                    Network:FireServer("OpenEggs", "Basic Egg", 10)
                end)
            end
        end
    end
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local mV = tick() - hz
            local mW = tick() - ht
            if mV >= 300 and mW >= 60 then
                pcall(ha)
            else
                if mV < 300 and mW >= 300 then
                    pcall(ha)
                end
            end
        end
    end
end
local function fn139()
    return Network:Call("GetClientPlayerData")
end
local function fn155(aM)
    local iQ = PetsModule[aM.Name]
    if not iQ or not iQ.Damage then
        return 0
    end
    local MutationsConfig = PetsModule.MutationsConfig
    local iS = aM.Mutation and MutationsConfig and MutationsConfig[aM.Mutation]
    return iQ.Damage * (1 + ((aM.Level or 1) - 1) / 50) * (iS and iS.PowerMult or 1)
end
local function fn181()
    local kO = hE()
    if not kO then
        return
    end
    local kP = {}
    local Upgrades = UpgradeModule.Upgrades
    local kR = {}
    local kS = kO.Upgrades
    local kW = if kS then 1 else 0
    local kU = 3987 * kW + 863 * (1 - kW)
    local kV = 966 * kW + 668 * (1 - kW)
    if not ((kU * 1890 + kV * 3705 + kU * kV) % 16777213 == 14965902) then
        kS = kR
    end
    hl(Upgrades, true, kS, kP)
    table.sort(kP, function(cf, cg)
        return cf.Cost < cg.Cost
    end)
    for i, v in ipairs(kP) do
        if hr(kO, v.Currency) >= v.Cost then
            Network:FireServer("BuyUpgrade", v.Name)
            return
        end
    end
end
local function autoBuyUpgradesLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AutoBuyUpgrades.Value then
            pcall(hD)
        end
        if Toggles.AutoBuyZones.Value then
            pcall(hF)
        end
    end
end
local function onInputChanged(ev)
    local UserInputType = ev.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        hz = tick()
    end
end
local function fn223()
    local iD_1
    local iC_1
    if identifyexecutor then
        iD_1, iC_1 = identifyexecutor()
        local iE = iD_1 ~= ""
        local iF = type(iD_1) == "string" and iE
        if iF then
            local iE_1 = type(iC_1) == "string" and iC_1 ~= "" and iD_1 .. " " .. iC_1
            hb = iE_1 or iD_1
        end
    end
end
local function autoEquipPetsLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AutoEquipPets.Value then
            pcall(he)
        end
        if Toggles.AutoEquipBlades.Value then
            pcall(hm)
        end
    end
end
local function fn269()
    local jc = hE()
    if not jc then
        return
    end
    local jd = {}
    local je = jc.EquippedPets
    local jl = if je then 1 else 0
    local jj = 1995 * jl + 1958 * (1 - jl)
    local jk = 2609 * jl + 133 * (1 - jl)
    if not ((jj * 2118 + jk * 763 + jj * jk) % 16777213 == 11421032) then
        je = jd
    end
    local jd_1 = je
    local je_1 = BoostsModule:GetBoost(LocalPlayer, "Max Pet Equip")
    local jf = {}
    local jh = jc.Pets or {}
    for k, v in pairs(jh) do
        if not v.Locked then
            table.insert(jf, { GUID = k, Entry = v })
        end
    end
    table.sort(jf, function(bh, bi)
        return hg(bi.Entry) < hg(bh.Entry)
    end)
    local jc_1 = {}
    local jg_1 = math.min(je_1, #jf)
    local ju = 1
    while ju <= jg_1 do
        local jv = ju
        jc_1[jf[jv].GUID] = true
        ju += 1
    end
    local je_2 = {}
    for i, v in ipairs(jd_1) do
        je_2[v] = true
    end
    for i, v in ipairs(jd_1) do
        if not jc_1[v] then
            Network:FireServer("UnequipPet", v)
        end
    end
    for k in pairs(jc_1) do
        if not je_2[k] then
            Network:FireServer("EquipPet", k)
        end
    end
end
local function fn290()
    local lt_1
    local ls_1
    local lr = hE()
    if not lr then
        return nil
    end
    lt_1, ls_1 = nil, nil
    local lv = lr.UnlockedAreas or {}
    for i, v in ipairs(lv) do
        local lr_1 = AreaModule.Areas[v]
        local lu_1 = lr_1
        if lu_1 then
            lu_1 = not ls_1 or (lr_1.Order or 0) > ls_1
        end
        if lu_1 then
            lt_1, ls_1 = v, lr_1.Order or 0
        end
    end
    return lt_1
end
local function onRscripts()
    hd(hh)
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function autoRebirthLoop()
    while not Library.Unloaded do
        task.wait(5)
        if Toggles.AutoRebirth.Value then
            pcall(function()
                Network:FireServer("Rebirth")
            end)
        end
        if Toggles.AutoBuySummerShop.Value then
            pcall(hA)
        end
        if Toggles.AutoPlaytimeRewards.Value then
            pcall(hj)
        end
        if Toggles.AutoDailyRewards.Value then
            pcall(hC)
        end
    end
end
local function fn343(cL)
    local lE = workspace.Teleports:FindFirstChild(cL) or workspace.AreaDoors:FindFirstChild(cL)
    return lE
end
local function fn365(aJ, aK)
    return aJ[aK or "Coins"] or 0
end
local function fn368()
    local mk = hE()
    if not mk then
        return
    end
    for k, v in pairs(Options.SummerOffers.Value) do
        local ml = v and hN[k]
        local mm = ml
        if ml then
            ml = hr(mk, mm.Offer.Currency) >= mm.Offer.Cost
        end
        if ml then
            Network:FireServer("PurchaseMerchantOffer", "SummerShop", mm.Index)
        end
    end
end
local function fn380(C)
    if setclipboard then
        setclipboard(C)
    elseif toclipboard then
        toclipboard(C)
    end
end
local function fn383()
    connection:Disconnect()
    connection2:Disconnect()
end
local function onUnload()
    Library:Unload()
end
local function fn443(aV)
    local iZ = EquipmentModule.Equipment[aV.Name]
    if not iZ or iZ.EquipmentType ~= "Blade" or not iZ.Blades then
        return 0
    end
    local i__1 = 0
    for i, v in ipairs(iZ.Blades) do
        local i0_1 = BladesModule[v] and BladesModule[v].Damage or 0
        i__1 += i0_1
    end
    local MutationsConfig = PetsModule.MutationsConfig
    local i0_2 = aV.Mutation and MutationsConfig and MutationsConfig[aV.Mutation]
    local iZ_3 = i0_2
    if i0_2 then
        local i1 = iZ_3.BladePowerMult
        local jb = if i1 then 1 else 0
        local i9 = 789 * jb + 1942 * (1 - jb)
        local ja = 2419 * jb + 3325 * (1 - jb)
        if not ((i9 * 2116 + ja * 1676 + i9 * ja) % 16777213 == 7632359) then
            i1 = iZ_3.PowerMult
        end
        i0_2 = i1 or 1
    end
    return i__1 * (i0_2 or 1)
end
local function worker()
    local iL_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local iK = math.floor(os.clock() - hP)
        if iK < 60 then
            iL_1 = iK .. "s"
        elseif iK < 3600 then
            iL_1 = string.format("%dm %ds", math.floor((iK) / (60)), iK % 60)
        else
            iL_1 = string.format("%dh %dm", math.floor((iK) / (3600)), math.floor((iK % 3600) / (60)))
        end
        Label:SetText(hp("Session time", iL_1, hO))
    end
end
local function fn476()
    hd(hk)
    Library:Notify("Copied Discord invite to clipboard")
end
local function fn479(L, M, N)
    return string.format("<b>%s</b> %s %s", L, hH("-", "#5a6070"), hH(M, N))
end
local function fn493()
    local l7 = hE()
    if not l7 then
        return
    end
    local l8 = l7.DaysPlayed or 0
    for k, v in pairs(DailyRewardModule.Rewards) do
        local l8_1 = v.Days <= l8
        if l8_1 then
            local mc = l7.DailyRewardsClaimed or {}
            l8_1 = not table.find(mc, k)
        end
        if l8_1 then
            Network:FireServer("ClaimDailyReward", k)
        end
    end
end
local function onInputBegan()
    hz = tick()
end
local function fn514(b5, b6, b7, b8)
    for k, v in pairs(b5) do
        local kE = b7[k] and true or false
        if v.Cost then
            if b6 and not kE then
                local insert = table.insert
                local Cost = v.Cost
                local kG = v.Currency or "Coins"
                insert(b8, { Name = k, Cost = Cost, Currency = kG })
            end
            if type(v.Connected) == "table" then
                hl(v.Connected, kE, b7, b8)
            end
        elseif type(v.Connected) == "table" then
            hl(v.Connected, b6, b7, b8)
        end
    end
end
local function fn520(W)
    local DiscordGroup = W:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = hS })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = hS })
end
local function onCopyJoinScript_JobID()
    local an = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, hq)
    hd(an)
    Library:Notify("Copied join script to clipboard")
end
local function fn546()
    local k5 = hE()
    if not k5 then
        return
    end
    local k6 = {}
    for k, v in pairs(AreaModule.Areas) do
        local k7 = v.Cost
        if k7 then
            local la = k5.UnlockedAreas or {}
            k7 = not table.find(la, k)
        end
        if k7 then
            table.insert(k6, { Name = k, Area = v })
        end
    end
    table.sort(k6, function(ct, cu)
        return (ct.Area.Order or 0) < (cu.Area.Order or 0)
    end)
    for i, v in ipairs(k6) do
        if hr(k5, v.Area.Cost.Currency) >= v.Area.Cost.Amount then
            Network:FireServer("PurchaseArea", v.Name)
            return
        end
    end
end
local function fn564()
    local lS = hE()
    if not lS then
        return
    end
    local lT = lS.PlaytimeRewardsTimePlayed or 0
    for k, v in pairs(PlaytimeRewardModule.Rewards) do
        local lT_1 = lT >= v.Time
        if lT_1 then
            local lX = lS.PlaytimeRewardsClaimed or {}
            lT_1 = not table.find(lX, k)
        end
        if lT_1 then
            Network:FireServer("ClaimPlaytimeReward", k)
        end
    end
end
local function fn577(I, J)
    return string.format('<font color="%s">%s</font>', J, I)
end
local function fn591()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    ht = tick()
end
ha = nil
hb = nil
PetsModule = nil
hd = nil
he = nil
Network = nil
hg = nil
hh = nil
connection2 = nil
hj = nil
hk = nil
hl = nil
hm = nil
LocalPlayer = nil
ho = nil
hp = nil
hq = nil
hr = nil
DailyRewardModule = nil
ht = nil
VirtualUser = nil
hv = nil
Label = nil
hx = nil
PlaytimeRewardModule = nil
hz = nil
hA = nil
hB = nil
hC = nil
hD = nil
hE = nil
hF = nil
Options = nil
hH = nil
connection = nil
UpgradeModule = nil
Toggles = nil
AreaModule = nil
BoostsModule = nil
hN = nil
hO = nil
hP = nil
BladesModule = nil
Library = nil
hS = nil
EquipmentModule = nil
local hZ_1
Library, Toggles, Options, VirtualUser, LocalPlayer, Network, PetsModule, EquipmentModule, BladesModule, BoostsModule, AreaModule, UpgradeModule, PlaytimeRewardModule, DailyRewardModule, hk, hh, hO, hd, hS, hH, hp, hZ_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local hU = ""
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
local Players = game:GetService("Players")
local GameInfoGroup
VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
LocalPlayer = Players.LocalPlayer
local Services = require(game.ReplicatedStorage.CoreModules.Services)
local hW_1
Network = Services:GetService("Network")
PetsModule = Services:GetService("PetsModule")
EquipmentModule = Services:GetService("EquipmentModule")
BladesModule = Services:GetService("BladesModule")
BoostsModule = Services:GetService("BoostsModule")
AreaModule = Services:GetService("AreaModule")
UpgradeModule = Services:GetService("UpgradeModule")
local MerchantModule = Services:GetService("MerchantModule")
PlaytimeRewardModule = Services:GetService("PlaytimeRewardModule")
DailyRewardModule = Services:GetService("DailyRewardModule")
local h0 = "RNG vs Fruit"
hk = "https://discord.gg/K7Qxnxkk46"
hh = "https://discord.gg/K7Qxnxkk46"
hd = fn380
hS = fn476
hH = fn577
hp = fn479
local h_ = "#7fd47f"
local h2 = "#6ec1ff"
hO = "#e8a34d"
local h1 = "#8b93a3"
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = hk, Copyable = true }, "|", h0 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local h5 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Settings = Window:AddTab("Settings", "settings")
}
if (hH or hU or (Network or Network) or hd and h2 and false or (not hd and h2 or not Network and not Network) and (Network or hH or (Network or not hd))) and (hd and false and (false or not hH) and ((not Network or h2) and (false or hH)) or (Network or not hd) and (hH or false) and (not hH and Network or (Network or h2))) or not ((hH or hU or (Network or Network) or hd and h2 and false or (not hd and h2 or not Network and not Network) and (Network or hH or (Network or not hd))) and (hd and false and (false or not hH) and ((not Network or h2) and (false or hH)) or (Network or not hd) and (hH or false) and (not hH and Network or (Network or h2)))) then
    h5.Farm = h5.Main:AddSubTab("Farm", "swords")
    h5.Progression = h5.Main:AddSubTab("Progression", "trending-up")
    h5.Shop = h5.Main:AddSubTab("Shop", "shopping-cart")
    h5.Rewards = h5.Main:AddSubTab("Rewards", "gift")
    hZ_1 = fn520
else
    hZ_1.Farm = hZ_1.Main:AddSubTab("Farm", "swords")
    hZ_1.Progression = hZ_1.Main:AddSubTab("Progression", "trending-up")
    hZ_1.Shop = hZ_1.Main:AddSubTab("Shop", "shopping-cart")
    hZ_1.Rewards = hZ_1.Main:AddSubTab("Rewards", "gift")
    h5 = fn520
end
for k, v in h5 do
    if v ~= h5.Main then
        hZ_1(v)
    end
end
hb, GameInfoGroup, Label, hq, hW_1 = nil, nil, nil, nil, nil
local hV = 5
repeat
    local hY_1 = (hV * 2 + 1) % 3 + 1
    if hY_1 <= 2 then
        if hY_1 <= 1 then
            local hY_2 = (vector.create((hV * 4 + 3) % 11 + 1, (hV * 7 + 4) % 13 + 1, (hV * 8 + 12) % 17 + 1))
            local hZ_2 = (vector.create((hV * 2 + 5) % 11 + 1, (hV * 6 + 5) % 13 + 1, (hV * 1 + 7) % 17 + 1))
            local nB = vector.cross(hY_2, hZ_2)
            local nC = vector.dot(hY_2, hZ_2)
            if vector.dot(nB, nB) + nC * nC == vector.dot(hY_2, hY_2) * vector.dot(hZ_2, hZ_2) + 1 then
                hW_1 = tostring(game.JobId)
            else
                hq = tostring(game.JobId)
            end
            hV = (hV + 20) % 24
        else
            local hY_3 = {
                "fsij",
                "jbajtsw",
                "duiemtnjaif",
                "mcdk",
                "uirotjdqvy",
                "vjvvtuvanrwe",
                "obupcwggrrtc",
                "tavkjygkmzes",
                "ffb",
                "gffpdwzahod"
            }
            if hY_3[(hV * 12 + 4) % 10 + 1] <= hY_3[(hV * 12 + 4) % 10 + 1] then
                hW_1 = #hq > 18
            else
                hq = #hW_1 > 18
            end
            hV = (hV + 20) % 24
        end
    else
        local hY_4 = (vector.create((hV * 4 + 4) % 11 + 1, (hV * 2 + 9) % 13 + 1, (hV * 14 + 4) % 17 + 1))
        local hZ_3 = (vector.create((hV * 3 + 2) % 11 + 1, (hV * 6 + 2) % 13 + 1, (hV * 2 + 7) % 17 + 1))
        local nH = vector.dot(hY_4, hZ_3)
        if nH * nH >= vector.dot(hY_4, hY_4) * vector.dot(hZ_3, hZ_3) + 1 then
            pcall(fn223)
            hp = (nil):AddLeftGroupbox("Account", "circle-user")
            hp:AddLabel(hb("User", nil, h2), true)
            hp:AddLabel(hb("Status", "Keyless", h2), true)
            hp:AddLabel(hb("Executor", "Unknown", h2), true)
            hH = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
            hH:AddLabel(h5(Label .. " [" .. tostring(game.PlaceId) .. "]", GameInfoGroup), true)
            hH:AddLabel(hb("Place ID", tostring(game.PlaceId), GameInfoGroup), true)
            hO = hH:AddLabel(hb("Session time", "0s", LocalPlayer), true)
        else
            hb = "Unknown"
            pcall(fn223)
            local AccountGroup = h5.Info:AddLeftGroupbox("Account", "circle-user")
            AccountGroup:AddLabel(hp("User", LocalPlayer.Name, h_), true)
            AccountGroup:AddLabel(hp("Status", "Keyless", h_), true)
            AccountGroup:AddLabel(hp("Executor", hb, h_), true)
            GameInfoGroup = h5.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            GameInfoGroup:AddLabel(hH(h0 .. " [" .. tostring(game.PlaceId) .. "]", h2), true)
            GameInfoGroup:AddLabel(hp("Place ID", tostring(game.PlaceId), h2), true)
            Label = GameInfoGroup:AddLabel(hp("Session time", "0s", hO), true)
        end
        hV = (hV + 14) % 24
    end
until (hV * 17 + 12) % 24 == 7
if hW_1 then
    local hU_2 = 1
    repeat
        local hV_1 = (vector.create((hU_2 * 3 + 2) % 11 + 1, (hU_2 * 10 + 2) % 13 + 1, (hU_2 * 7 + 2) % 17 + 1))
        local hY_5 = (vector.create((hU_2 * 6 + 8) % 11 + 1, (hU_2 * 10 + 1) % 13 + 1, (hU_2 * 14 + 11) % 17 + 1))
        local hZ_4 = (vector.create((hU_2 * 3 + 5) % 11 + 1, (hU_2 * 4 + 2) % 13 + 1, (hU_2 * 11 + 17) % 17 + 1))
        local h__1 = (vector.create((hU_2 * 1 + 4) % 5 + 1, (hU_2 * 5 + 4) % 7 + 1, (hU_2 * 5 + 5) % 9 + 1))
        if vector.dot(vector.cross(hV_1, (vector.cross(hY_5, hZ_4))), h__1) == vector.dot(hY_5 * vector.dot(hV_1, hZ_4) - hZ_4 * vector.dot(hV_1, hY_5), h__1) then
            hW_1 = string.sub(hq, 1, 18) .. "..."
        else
            hq = string.sub(hW_1, 1, 18) .. "..."
        end
        hU_2 = (hU_2 + 0) % 4
    until (hU_2 * 3 + 0) % 4 == 3
end
local hU_3 = hW_1 or hq
hP, hN, hE, hr, hg, hv, he, hm, hl, hD, hF, hx, hB, ho, hj, hC = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
GameInfoGroup:AddLabel(hp("Server", hU_3, h1), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
hP = os.clock()
task.spawn(worker)
local ScriptsGroup = h5.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(hH("Included in this hub", h1), true)
ScriptsGroup:AddLabel(hH(h0, h2), true)
local FeaturesGroup = h5.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(hH("Auto Roll", h2), true)
FeaturesGroup:AddLabel(hH("Fruit Farming", h2), true)
FeaturesGroup:AddLabel(hH("Zones and Travel", hO), true)
FeaturesGroup:AddLabel(hH("Upgrades and Rebirth", hO), true)
FeaturesGroup:AddLabel(hH("Equipping", h1), true)
FeaturesGroup:AddLabel(hH("Shop and Rewards", h1), true)
local SocialsGroup = h5.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = hS })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = h5.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = hS })
local FaqGroup = h5.Info:AddRightGroupbox("FAQ", "circle-help")
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
hE = fn139
hr = fn365
hg = fn155
hv = fn443
he = fn269
if (hP and hx or hP and not hP) and (not hE and hP or hx and hE) or hC and hx and (hC or not hP) and (not hx and hE and (not hx and not hx)) or not ((hP and hx or hP and not hP) and (not hE and hP or hx and hE) or hC and hx and (hC or not hP) and (not hx and hE and (not hx and not hx))) then
    hm = fn48
    hl = fn514
    hD = fn181
else
    hD = fn48
    hm = fn514
    hl = fn181
end
hF = fn546
hx = fn290
hB = fn343
ho = fn73
hj = fn564
hC = fn493
hN = {}
local ia = {}
for i, v in ipairs(MerchantModule.Merchants.SummerShop.Offers) do
    hN[v.Name] = { Index = i, Offer = v }
    table.insert(ia, v.Name)
end
hz, ht, connection, connection2, hA, ha = nil, nil, nil, nil, nil, nil
hA = fn368
local RollingGroup = h5.Farm:AddLeftGroupbox("Rolling", "dices")
RollingGroup:AddToggle("AutoSpin", { Text = "Auto Spin", Default = false })
local MovementGroup = h5.Farm:AddRightGroupbox("Movement", "footprints")
MovementGroup:AddToggle("AutoWalkFruits", { Text = "Auto Walk Towards Fruits", Default = false })
MovementGroup:AddSlider("FruitDistance", { Text = "Fruit Distance", Default = 5, Min = 0, Max = 40, Rounding = 0, Suffix = " studs" })
MovementGroup:AddToggle("AutoZoneTravel", { Text = "Auto Go To Best Owned Zone", Default = false })
local UpgradesGroup = h5.Progression:AddRightGroupbox("Upgrades", "trending-up")
UpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Affordable Upgrades", Default = false })
UpgradesGroup:AddToggle("AutoBuyZones", { Text = "Auto Buy Zones", Default = false })
UpgradesGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local EquippingGroup = h5.Progression:AddLeftGroupbox("Equipping", "swords")
EquippingGroup:AddToggle("AutoEquipPets", { Text = "Auto Equip Best Pets", Default = false })
EquippingGroup:AddToggle("AutoEquipBlades", { Text = "Auto Equip Best Blades", Default = false })
local SummerShopGroup = h5.Shop:AddRightGroupbox("Summer Shop", "sun")
SummerShopGroup:AddDropdown("SummerOffers", { Values = ia, Default = {}, Multi = true, Text = "Summer Shop Offers" })
SummerShopGroup:AddToggle("AutoBuySummerShop", { Text = "Auto Buy Summer Shop", Default = false })
local RewardsGroup = h5.Rewards:AddRightGroupbox("Rewards", "gift")
RewardsGroup:AddToggle("AutoPlaytimeRewards", { Text = "Auto Claim Playtime Rewards", Default = false })
RewardsGroup:AddToggle("AutoDailyRewards", { Text = "Auto Claim Daily Rewards", Default = false })
task.spawn(autoSpinLoop)
task.spawn(autoZoneTravelLoop)
task.spawn(autoBuyUpgradesLoop)
task.spawn(autoEquipPetsLoop)
task.spawn(autoRebirthLoop)
local h__2 = h5.Settings:AddLeftGroupbox("Menu", "settings")
h__2:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
hz = tick()
ht = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local mP = v
        pcall(function()
            mP:Disable()
        end)
    end
end)
ha = fn591
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
h__2:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
h__2:AddButton("Unload", onUnload)
Library:OnUnload(fn383)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(h5.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/rng-vs-fruit")
SaveManager:BuildConfigSection(h5.Settings)
SaveManager:LoadAutoloadConfig()
end)(...)
