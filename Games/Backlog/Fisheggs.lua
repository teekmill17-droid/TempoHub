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
getgenv().TempoHoodSubtitle = "FISHEGGS"
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
local ym_2_1, ym_2_3
local ym_8_1, ym_8_2, ym_8_3, ym_8_4
local oM
local Options
local pa
local pz
local oz
local pg
local oY
local EquipBestFish
local oF
local CoreGui
local Bases
local oL
local ps
local o9
local ClaimFishIndex
local oX
local pE
local oE
local pl
local LocalPlayer
local oK
local o8
local oQ
local pe
local SellRequest
local oD
local pk
local Biomes
local oJ
local o7
local Toggles
local oV
local pC
local PlaceEgg
local o0
local Library
local oI
local pp
local PlacedEggs
local oO
local pc
local oU
local pB
local oB
local pi
local o_
local pH
local oH
local po
local oN
local SpawnedEggs
local oT
local HatchEgg
local ph
local oZ
local pG
local oG
local pn
local function fn9()
    local Character = LocalPlayer.Character
    local rr = Character and Character:FindFirstChild("HumanoidRootPart")
    return rr
end
local function fn13()
    local Character = LocalPlayer.Character
    if not Character then
        return nil
    end
    for i, child in Character:GetChildren() do
        if oZ(child) then
            return child
        end
    end
    return nil
end
local function fn32(di)
    local sO_1
    local sN_1
    if not next(oD) then
        pG()
    end
    local sK = Options.StealZoneFilter and Options.StealZoneFilter.Value
    local sK_1 = Toggles.AutoStealSelected and Toggles.AutoStealSelected.Value
    local sM = oF
    if sK_1 then
        sK_1 = type(sK) == "table"
    end
    if sK_1 then
        sK_1 = next(sK)
    end
    if sK_1 then
        sO_1, sN_1 = nil, nil
        for k in sK do
            local sK_2 = oD[k]
            if sK_2 then
                local Magnitude = (sK_2 - sM).Magnitude
                local sK_3 = not sN_1
                if not sK_3 then
                    sK_3 = di == "Furthest" and Magnitude > sN_1
                end
                if not sK_3 then
                    sK_3 = di ~= "Furthest" and Magnitude < sN_1
                end
                if sK_3 then
                    sO_1, sN_1 = k, Magnitude
                end
            end
        end
        if sO_1 then
            oX(sO_1)
        end
        return
    end
    local sK_4 = di == "Further"
    local sL_2 = di == "Furthest"
    local s2 = if sL_2 then 1 else 0
    local s0 = 2235 * s2 + 2914 * (1 - s2)
    local s1 = 2853 * s2 + 787 * (1 - s2)
    if not ((s0 * 1183 + s1 * 1540 + s0 * s1) % 16777213 == 13414080) then
        sL_2 = sK_4
    end
    if sL_2 then
        local sK_5 = oB[1]
        if sK_5 then
            oX(sK_5.Name)
        end
    end
end
local function fn108(dJ)
    local s6 = oI[dJ]
    if not s6 then
        return false
    end
    local ta = if os.clock() >= s6 then 1 else 0
    if ta == 1 then
        oI[dJ] = nil
        return false
    end
    return true
end
local function fn118(bv)
    local rz = bv.PrimaryPart or bv:FindFirstChild("PrimaryPart") or bv:FindFirstChildWhichIsA("BasePart")
    return rz
end
local function autoSellLoop()
    while not Library.Unloaded do
        if Toggles.AutoSell and Toggles.AutoSell.Value then
            pcall(pl)
        end
        local wait = task.wait
        local uV = Options.SellDelay and Options.SellDelay.Value or 1
        wait(uV)
    end
end
local function fn157()
    local t0 = false
    for i, child in PlacedEggs:GetChildren() do
        if Library.Unloaded then
            break
        else
            local t1 = child:IsA("Model") and tonumber(child:GetAttribute("OwnerUserId")) == LocalPlayer.UserId and child:GetAttribute("HatchReady") == true
            if t1 then
                HatchEgg:FireServer(child)
                t0 = true
                task.wait(0.2)
            end
        end
    end
    return t0
end
local function fn175()
    local attr = LocalPlayer:GetAttribute("BaseName")
    local qU = attr ~= ""
    local qV = type(attr) == "string" and qU
    if qV then
        return Bases:FindFirstChild(attr)
    end
    for i, child in Bases:GetChildren() do
        if tonumber(child:GetAttribute("OwnerUserId")) == LocalPlayer.UserId then
            return child
        end
    end
    return nil
end
local function fn176()
    po(oT, "Copied Discord invite to clipboard")
end
local function fn204(b6)
    for k, v in { "TreadPoolTrainingPosition", "TreadPoolTrainingOrientation" } do
        local rW = b6:FindFirstChild(v)
        if rW and rW.Enabled then
            rW.Enabled = false
        end
    end
end
local function fn211()
    local q2 = oY()
    local q3 = q2 and q2:FindFirstChild("EggPlacementZone")
    return q3
end
local function fn215()
    local Character = LocalPlayer.Character
    local ru = Character and Character:FindFirstChildOfClass("Humanoid")
    return ru
end
local function fn275()
    local tM = oO()
    local tN = oH()
    local tO = pE()
    local tQ = not tM or not tN
    local tN_1 = not tO
    local tP_1 = tQ
    local tU = if tP_1 then 1 else 0
    local tS = 2104 * tU + 2989 * (1 - tU)
    local tT = 695 * tU + 423 * (1 - tU)
    if not ((tS * 2285 + tT * 654 + tS * tT) % 16777213 == 6724450) then
        tP_1 = tN_1
    end
    if tP_1 then
        return false
    end
    local tN_2 = oV()
    if #tN_2 == 0 then
        return false
    end
    local tP_2 = false
    for k, v in tN_2 do
        if Library.Unloaded then
            break
        end
        if v.Parent == LocalPlayer.Backpack then
            tO:EquipTool(v)
            task.wait(0.12)
        end
        if oz() then
            oU(tM.Position + Vector3.new(0, 5, 0))
            local tN_3 = tM.CFrame:PointToWorldSpace(Vector3.new(0, tM.Size.Y * 0.5, 0))
            PlaceEgg:FireServer(tN_3)
            tP_2 = true
            task.wait(0.35)
        end
    end
    return tP_2
end
local function fn301(db)
    if not next(oD) then
        pG()
    end
    local sF = oD[db]
    if not sF then
        return false
    end
    pi(sF, 2)
    oU(sF + Vector3.new(0, 6, 0))
    task.wait(0.2)
    return true
end
local function fn315(cQ)
    local attr3 = cQ:GetAttribute("Biome")
    local attr2 = cQ:GetAttribute("Rarity")
    local attr = cQ:GetAttribute("DisplayName")
    if not (Toggles.AutoStealSelected and Toggles.AutoStealSelected.Value) then
        return true
    end
    local Value3 = Options.StealZoneFilter.Value
    local Value2 = Options.StealRarityFilter.Value
    local Value = Options.StealSpecificEggs.Value
    local sx = type(Value3) == "table" and next(Value3) and not Value3[attr3]
    if sx then
        return false
    end
    local sr_1 = type(Value2) == "table" and next(Value2) and not Value2[attr2]
    if sr_1 then
        return false
    end
    local sr_2 = type(Value) == "table" and next(Value) and not Value[attr]
    if sr_2 then
        return false
    end
    return true
end
local function fn334()
    local TpWalkSpeed = Options.TpWalkSpeed
    local r7 = TpWalkSpeed and tonumber(TpWalkSpeed.Value)
    local r6_1 = r7
    if r7 then
        r7 = math.max(r6_1, 1)
    end
    return r7 or pg
end
local function fn365(by)
    local rB = by:IsA("Tool") and type(by:GetAttribute("EggType")) == "string" and by:GetAttribute("Scale") ~= nil and by:GetAttribute("Kg") ~= nil
    return rB
end
local function fn424()
    local tb = oH()
    if not tb then
        return {}
    end
    local Position = tb.Position
    local tb_1 = {}
    local td = oF
    for i, child in SpawnedEggs:GetChildren() do
        local te = child:IsA("Model") and child:GetAttribute("PromptBusy") ~= true and not oE(child)
        if te then
            local te_1 = pp(child)
            local tf = o8(child)
            local tg = te_1 and te_1.Enabled and tf and oQ(child)
            if tg then
                local tg_1 = #tb_1 + 1
                local Magnitude2 = (tf.Position - Position).Magnitude
                local Magnitude = (tf.Position - td).Magnitude
                local tj = oK[child:GetAttribute("Rarity")] or 0
                tb_1[tg_1] = {
                    Egg = child,
                    Prompt = te_1,
                    Part = tf,
                    Distance = Magnitude2,
                    SafeDistance = Magnitude,
                    RarityRank = tj,
                    Enabled = true,
                    Biome = child:GetAttribute("Biome")
                }
            end
        end
    end
    return tb_1
end
local function onDescendantAdded(f3)
    local uN = f3:IsA("ProximityPrompt") and f3.Name == "EggPrompt"
    if uN then
        pe(f3)
    end
end
local function fn548()
    oU(oF, 20)
    local sn = CFrame.new(oF)
    local so = os.clock() + 6
    while os.clock() < so do
        if not pn() then
            return true
        end
        local sp = Library.Unloaded or not pz(sn)
        if sp then
            return false
        end
        pC.Heartbeat:Wait()
    end
    return not pn()
end
local function fn639(br)
    local EggPrompt = br:FindFirstChild("EggPrompt", true)
    local rx = EggPrompt and EggPrompt:IsA("ProximityPrompt")
    if rx then
        return EggPrompt
    end
    return nil
end
local function fn685()
    return LocalPlayer:GetAttribute("CarryingEgg") == true
end
local function fn689(a2, a3)
    if setclipboard then
        setclipboard(a2)
    elseif toclipboard then
        toclipboard(a2)
    end
    Library:Notify(a3)
end
local function fn708(a9)
    local DiscordGroup = a9:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = o7 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = o7 })
end
local function fn732(bT)
    local rS = not bT or not bT:IsA("ProximityPrompt")
    if rS then
        return
    end
    if bT.HoldDuration < pk then
        bT.HoldDuration = pk
    end
    bT.RequiresLineOfSight = false
end
local function fn767(eh)
    local tD = not eh
    local Prompt
    local tE = not oH() or tD
    local Part
    if tE then
        return false
    elseif pn() then
        return ph()
    else
        Part, Prompt = eh.Part, eh.Prompt
        local tF = not Part
        local tL = if tF then 1 else 0
        local tJ = 3872 * tL + 4069 * (1 - tL)
        local tK = 2543 * tL + 3209 * (1 - tL)
        if not ((tJ * 852 + tK * 2402 + tJ * tK) % 16777213 == 2476513) then
            tF = not Part.Parent
        end
        if not tF then
            tF = not Prompt
        end
        if not tF then
            tF = not Prompt.Parent
        end
        if tF then
            return false
        end
        pi(Part.Position, 1)
        pe(Prompt)
        local tF_1 = Part.CFrame + Vector3.new(0, 4, 0)
        if not oU(tF_1.Position) then
            oI[eh.Egg] = os.clock() + oM
            return false
        end
        o0(Prompt)
        local tG = os.clock() + pk + 3
        while os.clock() < tG do
            if pn() then
                break
            end
            local tH = Library.Unloaded or not Part.Parent or not Prompt.Enabled or not pz(tF_1)
            if tH then
                break
            end
            pC.Heartbeat:Wait()
        end
        if not pn() then
            oI[eh.Egg] = os.clock() + oM
            return false
        end
        return ph()
    end
end
local function autoBuyTrailsLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyTrails and Toggles.AutoBuyTrails.Value then
            pcall(pH)
        end
        local u__1 = task.wait
        local u1 = Options.TrailBuyDelay and Options.TrailBuyDelay.Value or 2
        u__1(u1)
    end
end
local function fn785()
    return CoreGui
end
local function autoEquipBestLoop()
    while not Library.Unloaded do
        local uY = Options.FishActionDelay and Options.FishActionDelay.Value or 1
        if Toggles.AutoEquipBest and Toggles.AutoEquipBest.Value then
            pcall(function()
                EquipBestFish:FireServer()
            end)
        end
        if Toggles.AutoClaimIndex and Toggles.AutoClaimIndex.Value then
            pcall(function()
                ClaimFishIndex:FireServer("ALL")
            end)
        end
        task.wait(uY)
    end
end
local function fn817(cc)
    local r4 = oH()
    if not r4 then
        return false
    end
    oJ(r4)
    r4.CFrame = cc
    r4.AssemblyLinearVelocity = Vector3.zero
    return true
end
local function autoStealAllLoop()
    while not Library.Unloaded do
        if Toggles.AutoStealAll and Toggles.AutoStealAll.Value or Toggles.AutoStealSelected and Toggles.AutoStealSelected.Value then
            if pn() then
                ph()
            else
                local uH_1 = Options.StealPriority and Options.StealPriority.Value or "Nearest"
                local uH_2 = pB()
                if #uH_2 == 0 then
                    oL(uH_1)
                    uH_2 = pB()
                end
                local uI_1 = oN(uH_2)
                if uI_1 then
                    pa(uI_1)
                else
                    local uH_3 = uH_1 == "Further"
                    local uI_2 = uH_1 == "Furthest"
                    local uM = if uI_2 then 1 else 0
                    local uK = 2762 * uM + 157 * (1 - uM)
                    local uL = 1308 * uM + 355 * (1 - uM)
                    if not ((uK * 446 + uL * 1283 + uK * uL) % 16777213 == 6522712) then
                        uI_2 = uH_3
                    end
                    if uI_2 then
                        oL(uH_1)
                    end
                end
            end
        end
        local uH_4 = Options.StealDelay and Options.StealDelay.Value or 0.05
        if uH_4 > 0 then
            task.wait(uH_4)
        else
            task.wait()
        end
    end
end
local function autoPlaceEggsLoop()
    while not Library.Unloaded do
        if Toggles.AutoPlaceEggs and Toggles.AutoPlaceEggs.Value then
            ps()
        end
        if Toggles.AutoHatch and Toggles.AutoHatch.Value then
            oG()
        end
        local wait = task.wait
        local uR = Options.EggActionDelay and Options.EggActionDelay.Value or 0.4
        wait(uR)
    end
end
local function fn894()
    table.clear(oD)
    table.clear(oB)
    local q5 = oF
    local q6 = o9:FindFirstChild("Biomes") or Biomes
    if not q6 then
        return
    end
    for i, child in q6:GetChildren() do
        local q6_1 = child:IsA("Folder") and not string.find(child.Name, "IGNORE", 1, true)
        if q6_1 then
            local q7_1 = nil
            local EggSpawns = child:FindFirstChild("EggSpawns")
            if EggSpawns then
                for i, child in EggSpawns:GetChildren() do
                    local q8
                    if child:IsA("BasePart") then
                        q8 = child
                    elseif child:IsA("Model") then
                        local q6_3 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                        q8 = q6_3
                    end
                    if q8 then
                        q7_1 = q8.Position
                        break
                    end
                end
            end
            if not q7_1 then
                local BasePart = child:FindFirstChildWhichIsA("BasePart", true)
                if BasePart then
                    q7_1 = BasePart.Position
                end
            end
            if q7_1 then
                oD[child.Name] = q7_1
                oB[#oB + 1] = { Name = child.Name, Position = q7_1, SafeDistance = (q7_1 - q5).Magnitude }
            end
        end
    end
    table.sort(oB, function(ar, as)
        return ar.SafeDistance > as.SafeDistance
    end)
end
local function fn906()
    local Value2 = Options.SellMode.Value
    if Value2 == "Inventory" then
        return SellRequest:InvokeServer("SellInventory")
    elseif Value2 == "Equipped" then
        return SellRequest:InvokeServer("SellEquipped")
    else
        local Value = Options.SellRarityFilter.Value
        local ua = pE()
        if not ua then
            return nil
        end
        local ub = false
        for k, v in oV() do
            if Library.Unloaded then
                break
            else
                local attr = v:GetAttribute("Rarity")
                local uc_1
                local ud = type(Value) ~= "table" or not next(Value) or Value[attr]
                local ud_1
                if ud then
                    if v.Parent == LocalPlayer.Backpack then
                        ua:EquipTool(v)
                        task.wait(0.12)
                    end
                    uc_1, ud_1 = pcall(function()
                        return SellRequest:InvokeServer("SellEquipped")
                    end)
                    local ue = uc_1 and type(ud_1) == "table" and ud_1.Success
                    if ue then
                        ub = true
                    end
                    task.wait(0.2)
                end
            end
        end
        return ub
    end
end
local function fn911(cp, cq)
    if typeof(cp) ~= "Vector3" then
        return false
    end
    local sc = os.clock()
    local sd = cq
    local sm = if sd then 1 else 0
    local sk = 179 * sm + 3866 * (1 - sm)
    local sl = 434 * sm + 1683 * (1 - sm)
    if not ((sk * 2777 + sl * 2901 + sk * sl) % 16777213 == 1833803) then
        sd = 15
    end
    local se = sc + sd
    while true do
        if not (os.clock() < se) then
            return false
        end
        if Library.Unloaded then
            return false
        end
        local sc_1 = oH()
        if not sc_1 then
            break
        end
        oJ(sc_1)
        local sd_1 = pc()
        local sf = math.max(2, sd_1 * 0.1)
        local sg = cp - sc_1.Position
        local Magnitude = sg.Magnitude
        if Magnitude <= sf then
            sc_1.CFrame = CFrame.new(cp)
            sc_1.AssemblyLinearVelocity = Vector3.zero
            return true
        end
        local si = pC.Heartbeat:Wait()
        sc_1.CFrame = CFrame.new(sc_1.Position + sg.Unit * math.min(sf, sd_1 * si, Magnitude), cp)
        sc_1.AssemblyLinearVelocity = Vector3.zero
    end
    return false
end
oz = nil
HatchEgg = nil
oB = nil
PlaceEgg = nil
oD = nil
oE = nil
oF = nil
oG = nil
oH = nil
oI = nil
oJ = nil
oK = nil
oL = nil
oM = nil
oN = nil
oO = nil
oQ = nil
oT = nil
oU = nil
oV = nil
oX = nil
oY = nil
oZ = nil
o_ = nil
o0 = nil
Biomes = nil
LocalPlayer = nil
Bases = nil
PlacedEggs = nil
o7 = nil
o8 = nil
o9 = nil
pa = nil
SpawnedEggs = nil
pc = nil
pe = nil
pg = nil
ph = nil
pi = nil
pk = nil
local Players, oP, oR, oS, oW, o4, Lighting, TeleportService, TrailConfig, GuiService
pl = nil
CoreGui = nil
pn = nil
po = nil
pp = nil
ps = nil
Options = nil
Toggles = nil
ClaimFishIndex = nil
pz = nil
pB = nil
pC = nil
SellRequest = nil
pE = nil
EquipBestFish = nil
pG = nil
pH = nil
Library = nil
local pq, GetTrailShopState, pu, BuyTrailCash, px, pA
local p0_1
local pV_1
local EggConfig
local pT_1, pT_3
pq = nil
GetTrailShopState = nil
pu = nil
BuyTrailCash = nil
px = nil
pA = nil
Players, ym_8_1, pC, px, pu, pq, CoreGui, GuiService, TeleportService, o9, Lighting, LocalPlayer, o_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
if px and LocalPlayer and (not CoreGui or LocalPlayer) and (not CoreGui and not CoreGui and (pC or not LocalPlayer)) and ((pC or CoreGui or px and not o_) and (px and not LocalPlayer or (px or ym_8_1))) or not (px and LocalPlayer and (not CoreGui or LocalPlayer) and (not CoreGui and not CoreGui and (pC or not LocalPlayer)) and ((pC or CoreGui or px and not o_) and (px and not LocalPlayer or (px or ym_8_1)))) then
    ym_8_2 = game:GetService("ReplicatedStorage")
    pC = game:GetService("RunService")
    px = game:GetService("UserInputService")
    pu = game:GetService("VirtualUser")
    pq = game:GetService("HttpService")
else
    pq = game:GetService("ReplicatedStorage")
    px = game:GetService("RunService")
    ym_8_2 = game:GetService("UserInputService")
    pC = game:GetService("VirtualUser")
    pu = game:GetService("HttpService")
end
CoreGui = game:GetService("CoreGui")
GuiService = game:GetService("GuiService")
TeleportService = game:GetService("TeleportService")
o9 = game:GetService("Workspace")
Lighting = game:GetService("Lighting")
LocalPlayer = Players.LocalPlayer
o_ = fn785
if getgenv then
    getgenv().gethui = o_
end
pcall(function()
    gethui = o_
end)
if setthreadidentity then
    setthreadidentity(8)
end
oW, oT, oS, oP, ym_2_1, PlaceEgg, HatchEgg, EquipBestFish, SellRequest, ClaimFishIndex, BuyTrailCash, GetTrailShopState, EggConfig, TrailConfig, SpawnedEggs, PlacedEggs, Bases, Biomes, oF, oD, oB, oK, oY, oO, pG = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (not SellRequest and not SellRequest and (oK or not GetTrailShopState) or (SellRequest and not SellRequest or (not ym_2_1 or oK))) and not (not SellRequest and not SellRequest and (oK or not GetTrailShopState) or (SellRequest and not SellRequest or (not ym_2_1 or oK))) then
    oT = "Steal Fish Eggs"
    oP = "https://discord.gg/K7Qxnxkk46"
    oW = "https://discord.gg/K7Qxnxkk46"
    oS = "https://tempohub.shop"
else
    oW = "Steal Fish Eggs"
    oT = "https://discord.gg/K7Qxnxkk46"
    oS = "https://discord.gg/K7Qxnxkk46"
    oP = "https://tempohub.shop"
end
local ym_20 = ym_8_2:WaitForChild("EggSystem")
local ym_20_2
local FishSystem = ym_8_2:WaitForChild("FishSystem")
local ym_9_3
local ym_2_2 = ym_8_2:WaitForChild("SellSystem")
local ym_18 = ym_8_2:WaitForChild("FishIndexSystem")
local TrailSystem = ym_8_2:WaitForChild("TrailSystem")
PlaceEgg = ym_20:WaitForChild("PlaceEgg")
HatchEgg = ym_20:WaitForChild("HatchEgg")
EquipBestFish = FishSystem:WaitForChild("EquipBestFish")
SellRequest = ym_2_2:WaitForChild("SellRequest")
ClaimFishIndex = ym_18:WaitForChild("ClaimFishIndex")
BuyTrailCash = TrailSystem:WaitForChild("BuyTrailCash")
GetTrailShopState = TrailSystem:WaitForChild("GetTrailShopState")
if (Biomes or TrailConfig or (oO or not oO) or (not Biomes and not oO or not oF and TrailConfig)) and (not oO and TrailConfig and (ym_18 or oO) or TrailConfig and oO and (not oO or not oO)) and (not oO and oO and (not TrailConfig or not ym_18) and (not oO and oF and (not TrailConfig and oO)) or (not FishSystem or not FishSystem or (oF or not FishSystem) or (TrailConfig or not oF or not TrailConfig and oO))) or not ((Biomes or TrailConfig or (oO or not oO) or (not Biomes and not oO or not oF and TrailConfig)) and (not oO and TrailConfig and (ym_18 or oO) or TrailConfig and oO and (not oO or not oO)) and (not oO and oO and (not TrailConfig or not ym_18) and (not oO and oF and (not TrailConfig and oO)) or (not FishSystem or not FishSystem or (oF or not FishSystem) or (TrailConfig or not oF or not TrailConfig and oO)))) then
    EggConfig = require(ym_20:WaitForChild("EggConfig"))
else
    ym_20 = require(EggConfig:WaitForChild("EggConfig"))
end
local pQ = require(ym_20:WaitForChild("EggRarityConfig"))
TrailConfig = require(TrailSystem:WaitForChild("TrailConfig"))
if (pG and not pG and (TrailSystem and TrailSystem) and (not TrailSystem or pG or (pG or pG)) or (pG and TrailSystem or (TrailSystem or pG) or TrailSystem and pG and (not TrailSystem or pG))) and (not pG or pG or TrailSystem and not pG or (TrailSystem and pG or (pG or not pG)) or (not pG and not TrailSystem or (not pG or pG) or (TrailSystem or pG or TrailSystem and not TrailSystem))) or not ((pG and not pG and (TrailSystem and TrailSystem) and (not TrailSystem or pG or (pG or pG)) or (pG and TrailSystem or (TrailSystem or pG) or TrailSystem and pG and (not TrailSystem or pG))) and (not pG or pG or TrailSystem and not pG or (TrailSystem and pG or (pG or not pG)) or (not pG and not TrailSystem or (not pG or pG) or (TrailSystem or pG or TrailSystem and not TrailSystem)))) then
    SpawnedEggs = o9:WaitForChild("SpawnedEggs")
else
    o9 = SpawnedEggs:WaitForChild("SpawnedEggs")
end
PlacedEggs = o9:WaitForChild("PlacedEggs")
Bases = o9:WaitForChild("Bases")
Biomes = o9:FindFirstChild("Biomes")
oY = fn175
oO = fn211
oF = Vector3.new(32, 119, -47)
oD = {}
oB = {}
pG = fn894
pG()
local RarityOrder = pQ.RarityOrder
oK = {}
for k, v in RarityOrder do
    oK[v] = k
end
ym_18, ym_2_3, ym_8_3 = nil, nil, nil
local ym_23_1 = 13
repeat
    if (ym_23_1 * 1 + 0) % 2 + 1 <= 1 then
        local zU = bit32.rrotate(bit32.bxor(bit32.lrotate(ym_23_1, 28), string.byte(tostring(ym_8_3))), 1)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(zU, 2318922669), 1290121753), (bit32.bxor(bit32.band(zU, 1976044626), 3637795571))), 1290121753), 3637795571) == zU then
            ym_2_3 = {}
            ym_8_3 = {}
        else
            ym_8_3 = {}
            ym_2_3 = {}
        end
        ym_23_1 = (ym_23_1 + 13) % 16
    else
        if ((not ym_2_3 and ym_8_3 or (not ym_2_3 or ym_23_1)) and ((ym_2_3 or not ym_23_1) and (ym_2_3 or ym_18)) and (ym_23_1 and ym_8_3 and (not ym_18 or ym_8_3) or (ym_18 and ym_18 or not ym_8_3 and not ym_2_3)) or (ym_2_3 or ym_8_3 or (ym_2_3 or ym_2_3)) and (ym_8_3 or ym_8_3 or ym_8_3 and ym_8_3) and ((ym_2_3 or ym_23_1 or not ym_23_1 and ym_23_1) and (ym_8_3 and not ym_2_3 or (not ym_8_3 or not ym_8_3)))) and not ((not ym_2_3 and ym_8_3 or (not ym_2_3 or ym_23_1)) and ((ym_2_3 or not ym_23_1) and (ym_2_3 or ym_18)) and (ym_23_1 and ym_8_3 and (not ym_18 or ym_8_3) or (ym_18 and ym_18 or not ym_8_3 and not ym_2_3)) or (ym_2_3 or ym_8_3 or (ym_2_3 or ym_2_3)) and (ym_8_3 or ym_8_3 or ym_8_3 and ym_8_3) and ((ym_2_3 or ym_23_1 or not ym_23_1 and ym_23_1) and (ym_8_3 and not ym_2_3 or (not ym_8_3 or not ym_8_3)))) then
            ym_8_3 = {}
        else
            ym_18 = {}
        end
        ym_23_1 = (ym_23_1 + 1) % 16
    end
until (ym_23_1 * 13 + 9) % 16 == 8
local ym_9_2 = {}
for k, v in EggConfig.Biomes do
    ym_18[#ym_18 + 1] = k
    if type(v.Eggs) == "table" then
        for k2, v in v.Eggs do
            if type(v) == "table" then
                local ym_23_2 = v.DisplayName or v.ModelName
                local ym_23_3 = type(ym_23_2) == "string" and ym_23_2 ~= "" and not ym_9_2[ym_23_2]
                if ym_23_3 then
                    ym_9_2[ym_23_2] = true
                    ym_2_3[#ym_2_3 + 1] = ym_23_2
                    ym_8_3[ym_23_2] = { ModelName = v.ModelName, Rarity = v.Rarity, Biome = k, ToolName = v.ToolName, SaveId = v.SaveId }
                end
            end
        end
    end
end
table.sort(ym_18)
table.sort(ym_2_3)
o4 = {}
for k, v in TrailConfig.RarityOrder do
    o4[#o4 + 1] = v
end
ym_20_2, ym_9_3, ym_8_4 = nil, nil, nil
local ym_23_4 = 4
repeat
    if ((not ym_20_2 or not ym_8_4 or not ym_20_2 and not ym_23_4) and (ym_9_3 and not ym_23_4 and (ym_20_2 and not ym_9_3)) and (not ym_9_3 and ym_23_4 and (not ym_8_4 and ym_23_4) and ((ym_8_4 or ym_9_3) and (ym_23_4 or not ym_9_3))) or (not ym_20_2 and not ym_20_2 and (ym_20_2 or ym_23_4) and (not ym_9_3 and ym_8_4 and (not ym_9_3 or not ym_20_2)) or ((ym_20_2 or ym_9_3) and (not ym_23_4 or ym_23_4) or (ym_23_4 or not ym_8_4 or not ym_9_3 and ym_20_2)))) and not ((not ym_20_2 or not ym_8_4 or not ym_20_2 and not ym_23_4) and (ym_9_3 and not ym_23_4 and (ym_20_2 and not ym_9_3)) and (not ym_9_3 and ym_23_4 and (not ym_8_4 and ym_23_4) and ((ym_8_4 or ym_9_3) and (ym_23_4 or not ym_9_3))) or (not ym_20_2 and not ym_20_2 and (ym_20_2 or ym_23_4) and (not ym_9_3 and ym_8_4 and (not ym_9_3 or not ym_20_2)) or ((ym_20_2 or ym_9_3) and (not ym_23_4 or ym_23_4) or (ym_23_4 or not ym_8_4 or not ym_9_3 and ym_20_2)))) then
        ym_8_4 = { "Nearest", "Random", "Furthest", "Rarest" }
        ym_20_2 = { "Equipped", "Inventory", "Filtered Eggs" }
        ym_9_3 = {}
    else
        ym_20_2 = { "Nearest", "Rarest", "Random", "Furthest" }
        ym_9_3 = { "Inventory", "Equipped", "Filtered Eggs" }
        ym_8_4 = {}
    end
    ym_23_4 = (ym_23_4 + 0) % 8
until (ym_23_4 * 7 + 1) % 8 == 5
for k, v in RarityOrder do
    ym_8_4[v] = true
end
local ym_23_5 = {}
for k, v in ym_18 do
    ym_23_5[v] = true
end
local ym_4 = {}
for k, v in o4 do
    ym_4[v] = true
end
Library, pA, Toggles, Options, pT_1, oR, po, o7, oH, pE, pp, o8, oZ, oV, oz = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pQ = ""
if (not Toggles and Toggles or (po or false) or (not Toggles and pT_1 or (po or Toggles))) and (Toggles and false or Toggles and pE or (Toggles and not oR or 102)) and ((oR or pE) and (not pT_1 or false) and ((not pE or po) and (not po and false)) or (not oR and oR or not pT_1 and false or (not po or po or (not po or 102)))) or not ((not Toggles and Toggles or (po or false) or (not Toggles and pT_1 or (po or Toggles))) and (Toggles and false or Toggles and pE or (Toggles and not oR or 102)) and ((oR or pE) and (not pT_1 or false) and ((not pE or po) and (not po and false)) or (not oR and oR or not pT_1 and false or (not po or po or (not po or 102))))) then
    Library = getgenv().Library
else
    pQ = getgenv().Library
end
local p_ = getgenv().ThemeManager
pA = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
po = fn689
o7 = fn176
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = oT, Copyable = true }, "|", oW },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
oR = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "egg"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
local pZ = oR.Main:AddSubTab("Steal", "swords")
local pY = oR.Main:AddSubTab("Eggs", "egg")
local pX = oR.Main:AddSubTab("Fish", "fish")
local pW = oR.Main:AddSubTab("Shop", "shopping-bag")
fn708(pZ)
fn708(pY)
fn708(pX)
fn708(pW)
fn708(oR.Player)
fn708(oR.Settings)
oH = fn9
pE = fn215
pp = fn639
o8 = fn118
oZ = fn365
oV = function()
    local bB = {}
    local function bC(bD)
        if not bD then
            return
        end
        for i, child in bD:GetChildren() do
            if oZ(child) then
                bB[#bB + 1] = child
            end
        end
    end
    bC(LocalPlayer:FindFirstChild("Backpack"))
    bC(LocalPlayer.Character)
    return bB
end
oz = fn13
pQ = EggConfig.Settings and EggConfig.Settings.PromptHoldDuration
local pR_2 = tonumber(pQ) or 1
pk, pg, oM, oI, p0_1, pV_1, pT_3, pe, o0, oJ, pz, pc, oU, pn, ph, oQ, pi, oX, oL, oE, pB, oN, pa, ps, oG, pl, pH = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pk = pR_2
pe = fn732
o0 = function(bX)
    task.spawn(function()
        task.wait(0.25)
        if Library.Unloaded or not bX.Parent then
            return
        end
        pcall(function()
            bX:InputHoldBegin()
            task.wait(math.max(bX.HoldDuration, pk) + 0.35)
            bX:InputHoldEnd()
        end)
    end)
end
if (not oU and pT_3 or oM and oM or not oU and oU and (oM or p0_1)) and not (not oU and pT_3 or oM and oM or not oU and oU and (oM or p0_1)) then
    pz = fn204
    oJ = fn817
else
    oJ = fn204
    pz = fn817
end
pg = 150
pc = fn334
oU = fn911
pn = fn685
ph = fn548
oQ = fn315
pi = function(c4, c5)
    if typeof(c4) ~= "Vector3" then
        return
    end
    pcall(function()
        local sC = c5 or 2
        LocalPlayer:RequestStreamAroundAsync(c4, sC)
    end)
end
if (pV_1 or pn or not pV_1 and not pc) and (pn and not ps and (not pc and not pV_1)) or (p0_1 or pc) and (p0_1 and not pn) and (p0_1 and not pV_1 and (pc or not p0_1)) or not ((pV_1 or pn or not pV_1 and not pc) and (pn and not ps and (not pc and not pV_1)) or (p0_1 or pc) and (p0_1 and not pn) and (p0_1 and not pV_1 and (pc or not p0_1))) then
    oX = fn301
    oL = fn32
    oM = 6
    oI = {}
else
    oL = fn301
    oM = fn32
    oI = 6
    oX = {}
end
oE = fn108
pB = fn424
oN = function(d4)
    local Value
    Value = nil
    if #d4 == 0 then
        return nil
    end
    Value = Options.StealPriority.Value
    if Value == "Random" then
        return d4[math.random(1, #d4)]
    end
    if Value == "Furthest" or Value == "Further" then
        local tt_1 = d4[1]
        local tu_1 = #d4
        local tA = 2
        while tA <= tu_1 do
            local tu_2 = d4[tA]
            if tu_2.SafeDistance > tt_1.SafeDistance or tu_2.SafeDistance == tt_1.SafeDistance and tu_2.RarityRank > tt_1.RarityRank then
                tt_1 = tu_2
            end
            tA += 1
        end
        return tt_1
    end
    table.sort(d4, function(ed, ee)
        if Value == "Rarest" then
            if ed.RarityRank ~= ee.RarityRank then
                return ed.RarityRank > ee.RarityRank
            elseif ed.Enabled ~= ee.Enabled then
                return ed.Enabled
            else
                return ed.Distance < ee.Distance
            end
        elseif ed.Distance ~= ee.Distance then
            return ed.Distance < ee.Distance
        else
            return ed.RarityRank > ee.RarityRank
        end
    end)
    return d4[1]
end
pa = fn767
ps = fn275
oG = fn157
pl = fn906
pH = function()
    local uq_1
    local ur_1
    local Value = Options.TrailBuyFilter.Value
    uq_1, ur_1 = pcall(function()
        return GetTrailShopState:InvokeServer()
    end)
    local us = uq_1 and type(ur_1) == "table" and ur_1.Owned
    local ur_2 = us or {}
    local uq_3 = 0
    local Stats = LocalPlayer:FindFirstChild("Stats")
    local ut = Stats and Stats:FindFirstChild("Cash")
    local ut_5
    if ut then
        local ut_1 = tonumber(ut.Value) or 0
        uq_3 = ut_1
    end
    for k, v in o4 do
        local uF = v
        if Library.Unloaded then
            break
        else
            local ut_2 = type(Value) ~= "table" or not next(Value) or Value[uF]
            local uu = ut_2 and not ur_2[uF]
            local uu_3
            if uu then
                local ut_3 = TrailConfig.GetShopData(uF)
                local uu_1 = ut_3 and tonumber(ut_3.CashPrice)
                if uq_3 >= (uu_1 or math.huge) then
                    ut_5, uu_3 = pcall(function()
                        return BuyTrailCash:InvokeServer(uF)
                    end)
                    local uv = ut_5 and type(uu_3) == "table"
                    if uv then
                        if ut then
                            local ut_6 = tonumber(ut.Value) or uq_3
                            uq_3 = ut_6
                        end
                    end
                    task.wait(0.25)
                end
            end
        end
    end
end
local AutoStealGroup = pZ:AddLeftGroupbox("Auto Steal", "swords")
local p3 = AutoStealGroup:AddTabbox()
local Tab = p3:AddTab("", "globe")
Tab:AddToggle("AutoStealAll", { Text = "Auto Steal All", Default = false })
Tab:AddDropdown("StealPriority", { Text = "Priority", Values = ym_20_2, Default = 1 })
local Tab = p3:AddTab("", "list-filter")
Tab:AddToggle("AutoStealSelected", { Text = "Auto Steal Selected", Default = false })
Tab:AddDropdown("StealZoneFilter", { Text = "Zone Filter", Values = ym_18, Multi = true, Default = ym_23_5 })
Tab:AddDropdown("StealRarityFilter", { Text = "Rarity Filter", Values = RarityOrder, Multi = true, Default = ym_8_4 })
Tab:AddDropdown("StealSpecificEggs", { Text = "Specific Eggs", Values = ym_2_3, Multi = true, Default = {}, Searchable = true })
AutoStealGroup:AddSlider("TpWalkSpeed", { Text = "TP Walk Speed", Default = 150, Min = 16, Max = 500, Rounding = 0 })
AutoStealGroup:AddSlider("StealDelay", { Text = "Steal Delay", Default = 0.05, Min = 0, Max = 3, Rounding = 2 })
local EggsGroup = pY:AddLeftGroupbox("Eggs", "egg")
EggsGroup:AddToggle("AutoPlaceEggs", { Text = "Auto Place Eggs", Default = false })
EggsGroup:AddToggle("AutoHatch", { Text = "Auto Hatch", Default = false })
EggsGroup:AddSlider("EggActionDelay", { Text = "Action Delay", Default = 0.4, Min = 0.1, Max = 3, Rounding = 2 })
local SellGroup = pY:AddRightGroupbox("Sell", "badge-dollar-sign")
SellGroup:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
SellGroup:AddDropdown("SellMode", { Text = "Sell Mode", Values = ym_9_3, Default = 1 })
SellGroup:AddDropdown("SellRarityFilter", { Text = "Sell Rarities", Values = RarityOrder, Multi = true, Default = ym_8_4 })
SellGroup:AddSlider("SellDelay", { Text = "Sell Delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2 })
local FishGroup = pX:AddLeftGroupbox("Fish", "fish")
FishGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best", Default = false })
FishGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
FishGroup:AddSlider("FishActionDelay", { Text = "Action Delay", Default = 1, Min = 0.25, Max = 10, Rounding = 2 })
local TrailsGroup = pW:AddLeftGroupbox("Trails", "footprints")
if not oL and not oL and (pc or AutoStealGroup) and (oL or ps or (not oL or pc)) and ((pc and not oL or (not AutoStealGroup or not pc)) and (not pc and not pc or (not AutoStealGroup or oL))) and not (not oL and not oL and (pc or AutoStealGroup) and (oL or ps or (not oL or pc)) and ((pc and not oL or (not AutoStealGroup or not pc)) and (not pc and not pc or (not AutoStealGroup or oL)))) then
    ym_4:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
    ym_4:AddDropdown("TrailBuyFilter", { Text = "Trail Rarities", Multi = true, Default = o4, Values = TrailsGroup })
    ym_4:AddSlider("TrailBuyDelay", { Text = "Buy Delay", Max = 15, Rounding = 2, Default = 2, Min = 0.5 })
    task.spawn(autoStealAllLoop)
else
    TrailsGroup:AddToggle("AutoBuyTrails", { Text = "Auto Buy Trails", Default = false })
    TrailsGroup:AddDropdown("TrailBuyFilter", { Text = "Trail Rarities", Values = o4, Multi = true, Default = ym_4 })
    TrailsGroup:AddSlider("TrailBuyDelay", { Text = "Buy Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 2 })
    task.spawn(autoStealAllLoop)
end
for i, descendant in SpawnedEggs:GetDescendants() do
    local ym_23_6 = descendant:IsA("ProximityPrompt") and descendant.Name == "EggPrompt"
    if ym_23_6 then
        pe(descendant)
    end
end
SpawnedEggs.DescendantAdded:Connect(onDescendantAdded)
task.spawn(autoPlaceEggsLoop)
task.spawn(autoSellLoop)
task.spawn(autoEquipBestLoop)
task.spawn(autoBuyTrailsLoop)
ym_18 = function()
    local vV
    local vT
    local vP
    local vW
    local vU
    local vQ
    vP = nil
    vQ = nil
    vT = nil
    vU = nil
    vV = nil
    vW = nil
    local vR, Label, vX, vY, Label2, Label3
    vW = function(gD, gE)
        return string.format('<font color="%s">%s</font>', gE, gD)
    end
    vY = function(gG, gH, gI)
        return string.format("<b>%s</b> %s %s", gG, vW("-", "#5a6070"), vW(gH, gI))
    end
    vV = "#7fd47f"
    local v1 = "#8b93a3"
    vP = "#e05a5a"
    vT = "#e8a34d"
    local function v2()
        local u3 = hookfunction ~= nil
        local u4 = hookmetamethod ~= nil
        local u5 = getrawmetatable ~= nil
        local u6 = setrawmetatable ~= nil
        local u7 = getgc ~= nil
        local u8 = getgenv ~= nil
        local u9 = getreg ~= nil
        local va = getconnections ~= nil
        local vb = firesignal ~= nil
        local vc = getcallbackvalue ~= nil
        local vd = setclipboard ~= nil
        local ve = getcustomasset ~= nil
        local vf = getnamecallmethod ~= nil
        local vg = isexecutorclosure ~= nil
        local vh = fireproximityprompt ~= nil
        local vi = firetouchinterest ~= nil
        local vj = WebSocket ~= nil
        local vk = readfile ~= nil
        local vl = writefile ~= nil
        local vn = (request or http_request) ~= nil
        local vp = (debug and debug.getupvalues) ~= nil
        local vr = (debug and debug.setupvalue) ~= nil
        local vs = 0
        local vt = { u3, u4, u5, u6, u7, u8, u9, va, vb, vc, vd, ve, vf, vg, vh, vi, vj, vk, vl, vn, vp, vr }
        for i, v in ipairs(vt) do
            if v then
                vs += 1
            end
        end
        local u3_1 = vs / #vt
        if u3_1 >= 0.9 then
            return vW("Full Support", vV)
        elseif u3_1 >= 0.6 then
            return vW("Half Support", vT)
        else
            return vW("Low Support", vP)
        end
    end
    vQ = "Unknown"
    pcall(function()
        local vC_1
        local vB_1
        if identifyexecutor then
            vC_1, vB_1 = identifyexecutor()
            local vD = vC_1 ~= ""
            local vE = type(vC_1) == "string" and vD
            if vE then
                local vD_1 = type(vB_1) == "string" and vB_1 ~= "" and vC_1 .. " " .. vB_1
                vQ = vD_1 or vC_1
            end
        end
    end)
    local v3 = v2()
    vU = os.clock()
    vX = function()
        local vJ = math.floor(os.clock() - vU)
        if vJ < 60 then
            return vJ .. "s"
        elseif vJ < 3600 then
            return string.format("%dm %ds", math.floor((vJ) / (60)), vJ % 60)
        else
            return string.format("%dh %dm", math.floor((vJ) / (3600)), math.floor((vJ % 3600) / (60)))
        end
    end
    local UserGroup = oR.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(vY("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, vV), true)
    UserGroup:AddLabel(vY("UserId", tostring(LocalPlayer.UserId), "#6ec1ff"), true)
    UserGroup:AddLabel(vY("Executor", vQ .. "  " .. v3, vV), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(vY("Session", vX(), vT), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            po(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            po("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = oR.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(vY("Game", oW, "#6ec1ff"), true)
    Label2 = SessionGroup:AddLabel(vY("Players", "0/0", vV), true)
    vR = tostring(game.JobId)
    local v0 = #vR > 18 and string.sub(vR, 1, 18) .. "..."
    local v3_1 = v0 or vR
    SessionGroup:AddLabel(vY("Job", v3_1, v1), true)
    Label = SessionGroup:AddLabel(vY("Ping", "0 ms", vT), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            po(vR, "Copied Job ID")
        end
    })
    task.spawn(function()
        local vM_1
        local vL_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(vY("Session", vX(), vT))
            Label2:SetText(vY("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), vV))
            vL_1, vM_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local vL_2 = vL_1 and vM_1 .. " ms" or "n/a"
            Label:SetText(vY("Ping", vL_2, vT))
        end
    end)
    local SocialsGroup = oR.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = o7 })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            po(oS, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            po(oP, "Copied website link")
        end
    })
end
local function ym_23_7()
    local connection
    local MovementGroup = oR.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = oR.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    pC.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    local v5_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if v5_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    px.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local wg_1 = pE()
            if wg_1 then
                wg_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = o9.CurrentCamera
    pC.RenderStepped:Connect(function(ih)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local wi_1 = pE()
            if wi_1 then
                wi_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local wi_3 = oH()
            local wj = pE()
            if wi_3 and wj then
                wj.PlatformStand = true
                local wj_1 = Vector3.zero
                if px:IsKeyDown(Enum.KeyCode.W) then
                    wj_1 += CurrentCamera.CFrame.LookVector
                end
                if px:IsKeyDown(Enum.KeyCode.S) then
                    wj_1 -= CurrentCamera.CFrame.LookVector
                end
                if px:IsKeyDown(Enum.KeyCode.A) then
                    wj_1 -= CurrentCamera.CFrame.RightVector
                end
                if px:IsKeyDown(Enum.KeyCode.D) then
                    wj_1 += CurrentCamera.CFrame.RightVector
                end
                if px:IsKeyDown(Enum.KeyCode.Space) then
                    wj_1 += Vector3.new(0, 1, 0)
                end
                if px:IsKeyDown(Enum.KeyCode.LeftControl) then
                    wj_1 -= Vector3.new(0, 1, 0)
                end
                wi_3.AssemblyLinearVelocity = Vector3.zero
                if wj_1.Magnitude > 0 then
                    wi_3.CFrame = wi_3.CFrame + wj_1.Unit * Options.FlySpeed.Value * ih
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local wp = pE()
            if wp then
                wp.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local wr = pE()
            if wr then
                wr.WalkSpeed = 16
            end
        end
    end)
    local function iE(iF)
        local ww = if not iF:IsA("ProximityPrompt") then 1 else 0
        if ww == 1 then
            return
        end
        if iF.Name == "EggPrompt" then
            return
        end
        iF.HoldDuration = 0
        iF.MaxActivationDistance = 50
        iF.RequiresLineOfSight = false
    end
    connection = nil
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in ipairs(o9:GetDescendants()) do
                pcall(iE, descendant)
            end
            connection = o9.DescendantAdded:Connect(function(iN)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(iE, iN)
                end
            end)
        elseif connection then
            connection:Disconnect()
            connection = nil
        end
    end)
    Library:OnUnload(function()
        if connection then
            connection:Disconnect()
        end
    end)
end
local function ym_20_3()
    local MenuGroup = oR.Settings:AddLeftGroupbox("Menu", "logs")
    local iU = 0
    local iV = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    local Label = MenuGroup:AddLabel("AFK triggers: 0")
    local function iX()
        local CurrentCamera = o9.CurrentCamera
        if not CurrentCamera then
            return
        end
        pu:CaptureController()
        pu:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        iU += 1
        iV = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. iU)
        end)
    end
    local connection2 = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(iX)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local wV = Toggles.AntiAfk.Value and tick() - iV >= 60
            if wV then
                pcall(iX)
            end
        end
    end)
    MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
    MenuGroup:AddToggle("Disable3D", { Text = "Disable 3D Rendering", Default = false })
    MenuGroup:AddToggle("FpsBoost", { Text = "FPS Boost", Default = false })
    MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
    Library.ToggleKeybind = Options.MenuKeybind
    local function jj(jk)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not jk)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not jk
            end
        end)
        if not jk then
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
    Toggles.AntiGameplayPause:OnChanged(function()
        jj(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                jj(true)
            end
        end
    end)
    local jB = false
    local function jC()
        local PlaceId, JobId
        if jB then
            return
        end
        jB = true
        PlaceId, JobId = game.PlaceId, game.JobId
        local w6 = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
        end)
        if not w6 then
            pcall(function()
                TeleportService:Teleport(PlaceId, LocalPlayer)
            end)
        end
    end
    task.spawn(function()
        local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
        local xb = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        if not xb then
            return
        end
        xb.ChildAdded:Connect(function(jU)
            if Library.Unloaded then
                return
            end
            if Toggles.AutoReconnect.Value and jU.Name == "ErrorPrompt" then
                jC()
            end
        end)
    end)
    TeleportService.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            jB = false
            jC()
        end
    end)
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            pC:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    local j9 = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        Explosion = true,
        Beam = true
    }
    local function ka(kb)
        if j9[kb.ClassName] then
            pcall(function()
                kb.Enabled = false
            end)
        end
    end
    local connection
    Toggles.FpsBoost:OnChanged(function()
        if Toggles.FpsBoost.Value then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            pcall(function()
                Lighting.GlobalShadows = false
            end)
            pcall(function()
                Lighting.FogEnd = 9000000000
            end)
            for i, descendant in ipairs(o9:GetDescendants()) do
                pcall(ka, descendant)
            end
            connection = o9.DescendantAdded:Connect(function(kq)
                if Toggles.FpsBoost.Value then
                    pcall(ka, kq)
                end
            end)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end)
            pcall(function()
                Lighting.GlobalShadows = true
            end)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    local ScriptGroup = oR.Settings:AddLeftGroupbox("Script", "terminal")
    ScriptGroup:AddButton({
        Text = "Unload Script",
        Func = function()
            Library:Unload()
        end
    })
    Library:OnUnload(function()
        if connection2 then
            connection2:Disconnect()
        end
        jj(false)
        pcall(function()
            pC:Set3dRenderingEnabled(true)
        end)
        if connection then
            connection:Disconnect()
        end
        local xq = oH()
        if xq then
            xq.Anchored = false
        end
        local xq_1 = pE()
        if xq_1 then
            xq_1.PlatformStand = false
            xq_1.WalkSpeed = 16
        end
    end)
end
local function ym_8_5(kI)
    local function kJ(kK, kL)
        local xt_1 = (kK == "Toggle" and Toggles or Options)[kL]
        local xs_2 = type(xt_1) == "table" and xt_1.Type == kK
        return xs_2 and xt_1 or nil
    end
    local function kT(kU, kV)
        local Type = kV.Type
        if Type == "Toggle" then
            return { idx = kU, type = "Toggle", value = kV.Value == true }
        elseif Type == "Slider" then
            return { idx = kU, type = "Slider", value = tostring(kV.Value) }
        elseif Type == "Dropdown" then
            return { idx = kU, type = "Dropdown", multi = kV.Multi == true, value = kV.Value }
        elseif Type == "Input" then
            local xA = kV.Value or ""
            return { idx = kU, type = "Input", text = tostring(xA) }
        elseif Type == "ColorPicker" then
            return { idx = kU, type = "ColorPicker", value = kV.Value:ToHex(), transparency = kV.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = kU,
                type = "KeyPicker",
                mode = kV.Mode,
                key = kV.Value,
                modifiers = kV.Modifiers,
                toggled = kV.Toggled
            }
        else
            return nil
        end
    end
    local function kX()
        local xD = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local xE = type(v) == "table" and type(v.Type) == "string" and not pA.Ignore[k]
                if xE then
                    local xE_1 = kT(k, v)
                    if xE_1 then
                        xD[#xD + 1] = xE_1
                    end
                end
            end
        end
        table.sort(xD, function(k6, k7)
            if k6.type ~= k7.type then
                return k6.type < k7.type
            end
            return k6.idx < k7.idx
        end)
        return { objects = xD }
    end
    local function k8(k9)
        local xX
        xX = nil
        local xY = type(k9) ~= "table" or type(k9.idx) ~= "string" or type(k9.type) ~= "string"
        local x1 = if xY then 1 else 0
        local x_ = 3237 * x1 + 1539 * (1 - x1)
        local x0 = 3517 * x1 + 3967 * (1 - x1)
        if not ((x_ * 1040 + x0 * 3234 + x_ * x0) % 16777213 == 9347774) then
            xY = pA.Ignore[k9.idx]
        end
        if xY then
            return false
        end
        xX = kJ(k9.type, k9.idx)
        if not xX then
            return false
        end
        local xY_1 = pcall(function()
            if k9.type == "Input" then
                if type(k9.text) ~= "string" then
                    return
                end
                xX:SetValue(k9.text)
            elseif k9.type == "ColorPicker" then
                xX:SetValueRGB(Color3.fromHex(k9.value), k9.transparency)
            elseif k9.type == "KeyPicker" then
                xX:SetValue({ k9.key, k9.mode, k9.modifiers })
                if k9.mode == "Toggle" and k9.toggled ~= nil then
                    xX.Toggled = k9.toggled
                    xX:Update()
                end
            else
                xX:SetValue(k9.value)
            end
        end)
        return xY_1
    end
    kI:AddDivider()
    kI:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    kI:AddButton("Export Config to Clipboard", function()
        local x3_1
        local x2_1
        x2_1, x3_1 = pcall(pq.JSONEncode, pq, kX())
        if not x2_1 then
            Library:Notify("Failed to encode the config")
            return
        end
        local x2_2 = setclipboard or toclipboard
        local x2_3 = type(x2_2) ~= "function" or not pcall(x2_2, x3_1)
        if x2_3 then
            Library:Notify("Your executor does not support copying to the clipboard")
            return
        end
        Library:Notify("Config copied to clipboard", 6)
    end)
    kI:AddButton("Import Config from Clipboard Text", function()
        local x8_1
        local x6 = Options.SaveManager_ImportSource.Value or ""
        local x6_1
        local x7 = tostring(x6):match("^%s*(.-)%s*$")
        if x7 == "" then
            Library:Notify("Paste an exported config into the box first")
            return
        end
        x6_1, x8_1 = pcall(pq.JSONDecode, pq, x7)
        local x7_1 = not x6_1 or type(x8_1) ~= "table" or type(x8_1.objects) ~= "table"
        if x7_1 then
            Library:Notify("That is not a valid exported config")
            return
        end
        local x6_2 = 0
        for i, v in ipairs(x8_1.objects) do
            if k8(v) then
                x6_2 += 1
            end
        end
        if x6_2 == 0 then
            Library:Notify("No settings in that config matched this script")
            return
        end
        Options.SaveManager_ImportSource:SetValue("")
        local x8_2 = x6_2 == 1 and "" or "s"
        Library:Notify(("Imported %d setting%s"):format(x6_2, x8_2), 6)
    end)
end
ym_18()
ym_23_7()
ym_20_3()
p_:SetLibrary(Library)
p_:SetFolder("TempoHub")
p_:SaveDefault("Evil Hello Kitty")
p_:ApplyToTab(oR.Settings)
p_:LoadDefault()
pA:SetLibrary(Library)
pA:IgnoreThemeSettings()
pA:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
pA:SetFolder("TempoHub/StealFishEggs")
local ym_9_4 = pA:BuildConfigSection(oR.Settings)
ym_8_5(ym_9_4)
pA:LoadAutoloadConfig()
if Toggles.HideUiOnStart.Value then
    Library:Toggle(false)
end
end)(...)
