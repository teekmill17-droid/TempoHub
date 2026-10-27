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
getgenv().TempoHoodSubtitle = "CUT A GEM"
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
local ActionsGroup, AutoRebirthGroup, MineAccessGroup, CodesGroup, AutoBuyGeodesGroup, AutoPlaceItemsGroup, AC_47
local pY
local pF
local qm
local pm
local p3
local qL
local pL
local qs
local ps
local p9
local o9
local pR
local qy
local PlayerData
local qf
local pf
local pX
local qE
local pE
local ql
local pl
local p2
local qK
local pK
local qr
local pr
local p8
local o8
local pQ
local qx
local px
local qe
local pe
local qD
local pD
local qk
local pk
local p1
local qJ
local pJ
local qq
local pq
local p7
local Options
local pP
local qw
local pw
local qd
local pd
local pV
local codesLoop
local PickaxeConfig
local qj
local pj
local p0
local qI
local MineConfig
local qp
local pp
local GemConfig
local o6
local pO
local qv
local pv
local qc
local Toggles
local pU
local qB
local pB
local qi
local pi
local p_
local qH
local pH
local LocalPlayer
local po
local p5
local qN
local RebirthConfig
local qu
local pu
local qb
local pb
local pT
local VirtualUser
local pA
local qh
local ph
local pZ
local qG
local pG
local connection2
local pn
local p4
local connection
local pM
local qt
local Library
local qa
local pa
local pS
local qz
local pz
local qg
local pg
function fns.autoCollectGemsLoop()
    while not Library.Unloaded do
        if Toggles.AutoCollectGems.Value then
            pcall(pm)
        end
        local z6 = Options.CollectLoopDelay.Value or 0.2
        task.wait(z6)
    end
end
function fns.fn21()
    local yX_1
    local yW_1
    local yT = qa()
    if not yT then
        return
    end
    local yU = pa()
    if not yU then
        return
    end
    local yV = pA()
    if yV then
        qy(yV)
    end
    yX_1, yW_1 = nil, nil
    for i, v in ipairs(pe(yT)) do
        local Magnitude = (v:GetPivot().Position - yU.Position).Magnitude
        if not yX_1 or Magnitude < yW_1 then
            yX_1, yW_1 = v, Magnitude
        end
    end
    if not yX_1 then
        return
    end
    while true do
        if Toggles.AutoMine.Value and not Library.Unloaded and yX_1.Parent then
            local attr = yX_1:GetAttribute("Health")
            if attr and attr <= 0 then
                break
            elseif not p4(yX_1) then
                break
            else
                pU:Fire({ rock = yX_1 })
                local wait = task.wait
                local yU_2 = Options.SwingDelay.Value or 0.35
                wait(yU_2)
                continue
            end
        else
            break
        end
    end
    local attr = yX_1:GetAttribute("Health")
    local yU_3 = Toggles.MineNotify.Value
    if yU_3 then
        local yV_2 = not yX_1.Parent
        if not yV_2 then
            yV_2 = attr and attr <= 0
        end
        yU_3 = yV_2
    end
    if yU_3 then
        Library:Notify(("Mined %s"):format(tostring(yX_1:GetAttribute("NodeName"))))
    end
end
function fns.fn27()
    if setclipboard then
        setclipboard(qK)
    elseif toclipboard then
        toclipboard(qK)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
function fns.fn46(a2)
    local Character = LocalPlayer.Character
    local sc = Character and Character:FindFirstChildOfClass("Humanoid")
    local sd = sc
    if sc then
        sc = a2
    end
    if not sc then
        return false
    elseif a2.Parent == Character then
        return true
    else
        sd:EquipTool(a2)
        task.wait(0.15)
        return a2.Parent == Character
    end
end
function fns.fn68()
    local xu = pw()
    local xv = xu and xu:FindFirstChild("Slots")
    local Data = PlayerData.Data
    if not (xv and Data) then
        return
    end
    local xw_1 = Data.SlotsOwned
    local xA = if xw_1 then 1 else 0
    local xy = 779 * xA + 908 * (1 - xA)
    local xz = 2669 * xA + 1985 * (1 - xA)
    if not ((xy * 3393 + xz * 2628 + xy * xz) % 16777213 == 11736430) then
        xw_1 = 0
    end
    local xv_2 = xw_1
    qw:Fire({ slot = xv_2 + 1 })
    if Toggles.BuySlotUpgrades.Value then
        for i, child in ipairs(xv:GetChildren()) do
            local attr = child:GetAttribute("SlotIndex")
            if attr then
                qq:Fire({ slot = attr })
                local wait = task.wait
                local xv_3 = Options.ActionDelay.Value or 0.2
                wait(xv_3)
            end
        end
    end
end
function fns.onBuyDarkGeodes(jj)
    o9(jj, pj)
end
function fns.fn109(br)
    local sl = {}
    local Character = LocalPlayer.Character
    for i, v in ipairs({ LocalPlayer:FindFirstChild("Backpack"), Character }) do
        if v then
            for i, child in ipairs(v:GetChildren()) do
                local sm_1 = child:IsA("Tool") and child:GetAttribute(br) ~= nil
                if sm_1 then
                    sl[#sl + 1] = child
                end
            end
        end
    end
    return sl
end
function fns.fn124()
    local uU = Options.GemDestination.Value == "Table" and qz()
    local uV = uU or pG()
    if #uV == 0 then
        return
    end
    local uV_1 = 1
    for i, v in ipairs(qu("GemName")) do
        if p_(v) then
            local uW = uV[uV_1]
            if not uW then
                return
            end
            uV_1 += 1
            local uX = qb(uW, v) and Toggles.PlaceGemNotify.Value
            if uX then
                Library:Notify(("Placed %s"):format(v.Name))
            end
        end
    end
end
function fns.onBuyGeodes(jg)
    o9(jg, pl)
end
function fns.fn171()
    local ty_1
    local tx_1
    local tv = qu("GeodeName")
    local Value = Options.InsertMode.Value
    ty_1, tx_1 = nil, nil
    for i, v in ipairs(tv) do
        local attr = v:GetAttribute("GeodeName")
        local tz = p9[attr] or 0
        if not (Value == "Selected Geodes" and not pd[attr]) then
            if not ty_1 then
                ty_1, tx_1 = v, tz
            elseif Value == "Lowest Tier" then
                if tz < tx_1 then
                    ty_1, tx_1 = v, tz
                end
            elseif tz > tx_1 then
                ty_1, tx_1 = v, tz
            end
        end
    end
    return ty_1
end
function fns.fn184()
    pb:Fire()
    local wi = pX("ItemStock")
    local wj = tonumber(Options.ItemReserve.Value) or 0
    for i, v in ipairs(pV) do
        local wj_1 = pg[v]
        if wj_1 then
            wj_1 = (wi[v] or 0) > 0
        end
        if wj_1 then
            local wj_2 = pP[v] or 0
            if qt() - wj_2 >= wj then
                pf:Fire({ category = pL[v], name = v })
                if Toggles.ItemNotify.Value then
                    Library:Notify(("Bought %s"):format(v))
                end
                local wait = task.wait
                local wl_3 = Options.ActionDelay.Value or 0.2
                wait(wl_3)
            end
        end
    end
end
function fns.fn188(fd)
    local Bases = fd:FindFirstChild("Bases")
    local Data = PlayerData.Data
    local wv = Bases
    local ww = {}
    if wv then
        wv = Data
    end
    if wv then
        wv = Data.Bases
    end
    if not wv then
        return ww
    end
    for k, v in pairs(Data.Bases) do
        local wu_1 = Bases:FindFirstChild(v)
        local wv_1 = wu_1 and wu_1:IsA("BasePart")
        if wv_1 then
            ww[#ww + 1] = wu_1
        end
    end
    return ww
end
function fns.fn192()
    if LocalPlayer:GetAttribute("InMine") then
        return
    end
    local yK = pw()
    local yL = yK and yK:FindFirstChild("Mine")
    if not yL then
        return
    end
    for i, descendant in ipairs(yL:GetDescendants()) do
        local yK_2 = descendant:IsA("ProximityPrompt") and descendant.Name == "MineInteract" and descendant.Enabled
        if yK_2 then
            o8(descendant)
            return
        end
    end
end
function fns.fn215()
    local vh = pw()
    local vi = vh and vh:FindFirstChild("Bin")
    local vh_1 = vi
    if vi then
        vi = vh_1:FindFirstChild("Discard")
    end
    local vh_2 = vi
    if vi then
        vi = vh_2:FindFirstChild("DiscardPrompt")
    end
    local vh_3 = vi
    if not vh_3 then
        return
    end
    local vi_1 = Options.DiscardMaxPurity.Value
    local vn = if vi_1 then 1 else 0
    local vl = 1508 * vn + 1899 * (1 - vn)
    local vm = 1202 * vn + 215 * (1 - vn)
    if not ((vl * 3988 + vm * 3276 + vl * vm) % 16777213 == 11764272) then
        vi_1 = 0
    end
    local vj = vi_1 / 100
    for i, v in ipairs(qu("GemName")) do
        local vi_2 = v:GetAttribute("Purity") or 1
        if vi_2 < vj then
            qb(vh_3, v)
        end
    end
end
function fns.autoBuyPickaxeLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyPickaxe.Value or Toggles.AutoEquipPickaxe.Value then
            pcall(pz)
        end
        local wait = task.wait
        local z3 = Options.PickaxeLoopDelay.Value or 5
        wait(z3)
    end
end
function fns.fn225(hz)
    local yt = {}
    local Value = Options.MineRockType.Value
    for i, descendant in ipairs(hz:GetDescendants()) do
        local yv = descendant:IsA("Model") and descendant:GetAttribute("NodeName")
        if yv then
            local attr = descendant:GetAttribute("Health")
            if not attr or attr > 0 then
                local yv_2 = pH(descendant)
                if Value == "All Rocks" or Value == "Sparkle Only" == yv_2 then
                    yt[#yt + 1] = descendant
                end
            end
        end
    end
    return yt
end
function fns.fn235()
    pF:Fire()
    local zf = tonumber(Options.PickaxeReserve.Value) or 0
    if Toggles.AutoBuyPickaxe.Value then
        for i, v in ipairs(PickaxeConfig.List) do
            local zf_1 = v.price or 0
            local zf_2 = not pq[v.name] and qt() - zf_1 >= zf
            if zf_2 then
                pO:Fire({ name = v.name })
                if Toggles.PickaxeNotify.Value then
                    local zf_3 = v.display or v.name
                    Library:Notify(("Bought %s"):format(zf_3))
                end
                local wait = task.wait
                local zh_2 = Options.ActionDelay.Value or 0.2
                wait(zh_2)
            end
        end
    end
    if Toggles.AutoEquipPickaxe.Value then
        local zf_5 = nil
        for i, v in ipairs(PickaxeConfig.List) do
            local zg_1 = pq[v.name]
            if zg_1 then
                zg_1 = not zf_5 or (v.damage or 0) > (zf_5.damage or 0)
            end
            if zg_1 then
                zf_5 = v
            end
        end
        if zf_5 and pn ~= zf_5.name then
            pK:Fire({ name = zf_5.name })
        end
    end
end
function fns.antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local Ax = tick() - pR
            local Ay = tick() - pM
            if Ax >= 300 and Ay >= 60 then
                pcall(po)
            else
                if Ax < 300 and Ay >= 300 then
                    pcall(po)
                end
            end
        end
    end
end
function fns.onBuyItems(jz)
    o9(jz, pg)
end
function fns.fn293(fo, fp)
    local wE = {}
    for i, v in ipairs(qs) do
        local wF_1 = fo:FindFirstChild(v)
        if wF_1 then
            wE[#wE + 1] = wF_1
        end
    end
    local wF_2 = OverlapParams.new()
    wF_2.FilterType = Enum.RaycastFilterType.Include
    wF_2.FilterDescendantsInstances = wE
    local wE_1 = fp - Vector3.new(0.4, 0.4, 0.4)
    if wE_1.X <= 0 or wE_1.Z <= 0 then
        return nil
    end
    for i, v in ipairs(qG(fo)) do
        local wG_1 = v.Position.Y + v.Size.Y / 2 + fp.Y / 2
        local wH = v.Position.X - v.Size.X / 2 + fp.X / 2
        local wI = v.Position.X + v.Size.X / 2 - fp.X / 2
        local wJ = v.Position.Z - v.Size.Z / 2 + fp.Z / 2
        local wK = v.Position.Z + v.Size.Z / 2 - fp.Z / 2
        if wH <= wI and wJ <= wK then
            local wL_1 = wH
            while wL_1 <= wI do
                local wH_1 = wJ
                while wH_1 <= wK do
                    local wM = CFrame.new(wL_1, wG_1, wH_1)
                    if #workspace:GetPartBoundsInBox(wM, wE_1, wF_2) == 0 then
                        return wM
                    end
                    wH_1 += 2
                end
                wL_1 += 2
            end
        end
    end
    return nil
end
function fns.fn297()
    local tR = pw()
    local tS = tR and tR:FindFirstChild("PlacedGrinders")
    if not tS then
        return
    end
    for i, child in ipairs(tS:GetChildren()) do
        local GemSpawn = child:FindFirstChild("GemSpawn")
        local tS_1 = GemSpawn and GemSpawn:FindFirstChild("PickPrompt")
        if tS_1 then
            local attr = GemSpawn:GetAttribute("RolledGem")
            local tU = GemSpawn:GetAttribute("RolledPurity") or 0
            local tU_1 = qb(tS_1) and Toggles.CollectNotify.Value
            if tU_1 then
                Library:Notify(("Collected %s at %d%% purity"):format(tostring(attr), math.floor(tU * 100)))
            end
        end
    end
end
function fns.fn304()
    local u7 = pS()
    local u8 = 1
    for i, v in ipairs(qu("GemName")) do
        local u9 = u7[u8]
        if not u9 then
            return
        end
        u8 += 1
        qb(u9, v)
    end
end
function fns.autoPlaytimePadLoop()
    while not Library.Unloaded do
        pcall(pv)
        if Toggles.AutoPlaytimePad.Value then
            pcall(p3)
        end
        local Av = Options.RewardLoopDelay.Value or 15
        task.wait(Av)
    end
end
function fns.fn346()
    local x0 = pw()
    local x1 = x0 and x0:FindFirstChild("Playtime")
    if not x1 then
        return
    end
    for i, descendant in ipairs(x1:GetDescendants()) do
        local x0_2 = descendant:IsA("ProximityPrompt") and descendant.Name == "PlaytimeClaimPrompt" and descendant.Enabled
        if x0_2 then
            qb(descendant)
        end
    end
end
function fns.fn349()
    local v5 = pw()
    local v6 = v5 and v5:FindFirstChild("Slots")
    if not v6 then
        return
    end
    local v6_1 = Options.SlotMargin.Value or 10
    for i, child in ipairs(v6:GetChildren()) do
        local attr = child:GetAttribute("SlotIndex")
        if attr then
            if child:GetAttribute("SlotMargin") ~= v6_1 then
                qm:Fire({ slot = attr, margin = v6_1 })
                local wait = task.wait
                local v8 = Options.ActionDelay.Value or 0.2
                wait(v8)
            end
            local Value = Toggles.SlotAutoSell.Value
            if child:GetAttribute("SlotAutoSell") == true ~= Value then
                qj:Fire({ slot = attr })
                local wait = task.wait
                local v6_4 = Options.ActionDelay.Value or 0.2
                wait(v6_4)
            end
        end
    end
end
function fns.fn361()
    for i, v in ipairs(px()) do
        local tI = pi()
        if not tI then
            return
        end
        local tJ = qb(v, tI) and Toggles.InsertNotify.Value
        if tJ then
            Library:Notify(("Grinding %s"):format(tI:GetAttribute("GeodeName")))
        end
    end
end
function fns.fn368(a8, a9)
    if not (a8 and a8.Parent) then
        return false
    end
    local sf_1 = pa()
    if not sf_1 then
        return false
    end
    local CFrame2 = sf_1.CFrame
    local Parent = a8.Parent
    local si = Parent:IsA("BasePart") and Parent.Position
    local sj = si or Parent:GetPivot().Position
    local sh_1 = false
    if (sf_1.Position - sj).Magnitude > a8.MaxActivationDistance - 2 then
        sf_1.CFrame = CFrame.new(sj + Vector3.new(0, 4, 0))
        sh_1 = true
        task.wait(0.2)
    end
    local si_2 = a9 and not qy(a9)
    if si_2 then
        if sh_1 and Toggles.ReturnAfterAction.Value then
            sf_1.CFrame = CFrame2
        end
        return false
    end
    if not (a8.Parent and a8.Enabled) then
        if sh_1 and Toggles.ReturnAfterAction.Value then
            sf_1.CFrame = CFrame2
        end
        return false
    end
    fireproximityprompt(a8)
    local wait = task.wait
    local sj_1 = Options.ActionDelay.Value or 0.2
    wait(sj_1)
    if sh_1 and Toggles.ReturnAfterAction.Value then
        sf_1.CFrame = CFrame2
    end
    return true
end
function fns.fn373()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    pM = tick()
end
function fns.autoPlaceItemsLoop()
    while not Library.Unloaded do
        if Toggles.AutoPlaceItems.Value then
            pcall(p5)
        end
        local Am = Options.PlaceItemLoopDelay.Value or 3
        task.wait(Am)
    end
end
function fns.fn384()
    if Toggles.AutoSpin.Value then
        qc:Fire()
    end
    if Toggles.AutoDaily.Value then
        p8:Fire()
    end
    if Toggles.AutoPlaytime.Value then
        p0:Fire()
    end
    local xP = Toggles.AutoGroupReward.Value and LocalPlayer:GetAttribute("GroupRewardClaimed") ~= true
    if xP then
        pZ:Fire()
    end
end
function fns.fn394()
    local t8 = pw()
    local t9 = t8 and t8:FindFirstChild("Conveyer")
    local t8_1 = t9
    if t9 then
        t9 = t8_1:FindFirstChild("Spawns")
    end
    local t8_2 = {}
    local ua = t9
    if not ua then
        return t8_2
    end
    for i, child in ipairs(ua:GetChildren()) do
        local ProximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt")
        if ProximityPrompt and ProximityPrompt.Enabled then
            t8_2[#t8_2 + 1] = ProximityPrompt
        end
    end
    return t8_2
end
function fns.fn404()
    local y7 = qa()
    if not y7 then
        return
    end
    if #pe(y7) > 0 then
        return
    end
    for i, descendant in ipairs(y7:GetDescendants()) do
        local y7_1 = descendant:IsA("ProximityPrompt") and descendant.Enabled
        if y7_1 then
            o8(descendant)
            return
        end
    end
end
function fns.onInputChanged(jX)
    local UserInputType = jX.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        pR = tick()
    end
end
function fns.fn494(aA, aB)
    table.clear(aB)
    for k, v in aA do
        if v then
            aB[k] = true
        end
    end
end
function fns.autoBuyBasesLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyBases.Value then
            pcall(ql)
        end
        if Toggles.AutoBuySlots.Value then
            pcall(pE)
        end
        local Ap = Options.ExpandLoopDelay.Value or 10
        task.wait(Ap)
    end
end
function fns.fn502()
    return qu("Pickaxe")[1]
end
function fns.fn509()
    Library.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
function fns.onInsertGeodes(jn)
    o9(jn, pd)
end
function fns.fn525()
    local vu = pw()
    local vv = vu and vu:FindFirstChild("Slots")
    local Data = PlayerData.Data
    local vw = Data and Data.ConveyorGems and Data.ConveyorGems.belt
    if not (vv and vw) then
        return
    end
    for i, child in ipairs(vv:GetChildren()) do
        local Spawn = child:FindFirstChild("Spawn")
        local vw_2 = Spawn and not Spawn:FindFirstChild("PlacedGem")
        if vw_2 then
            for k in pairs(vw) do
                local vu_3 = tick()
                if vu_3 - (pJ[k] or 0) > 3 then
                    pJ[k] = tick()
                    qJ:Fire({ plot = LocalPlayer:GetAttribute("PlotName"), slot = child.Name, id = k })
                    break
                end
            end
        end
    end
end
function fns.fn551()
    local w4_1
    local w_ = pw()
    if not w_ then
        return
    end
    for i, v in ipairs(qu("ItemCategory")) do
        local attr = v:GetAttribute("ItemCategory")
        local w1 = v:GetAttribute("StackBase") or v.Name
        local w1_1 = qH:FindFirstChild(attr)
        local w3 = w1_1 and w1_1:FindFirstChild(w1)
        local w3_1
        if w3 then
            w3_1, w4_1 = w3:GetBoundingBox()
            local w1_3 = pY(w_, w4_1)
            if w1_3 then
                o6:Fire({ cframe = w1_3, itemName = w1, folderName = attr })
                if Toggles.PlaceItemNotify.Value then
                    Library:Notify(("Placed %s"):format(w1))
                end
                local wait = task.wait
                local w1_4 = Options.ActionDelay.Value or 0.2
                wait(w1_4)
            end
        end
    end
end
function fns.fn554()
    local xf = pw()
    local xg = xf and xf:FindFirstChild("BaseStands")
    if not xg then
        return
    end
    for i, child in ipairs(xg:GetChildren()) do
        for i, descendant in ipairs(child:GetDescendants()) do
            local xf_2 = descendant:IsA("ProximityPrompt") and descendant.Name == "BuyBasePrompt" and descendant.Enabled
            if xf_2 then
                qb(descendant)
            end
        end
    end
end
local function fn600()
    ph:Fire()
    local th = pX("DarkGeodeStock")
    local ti = tonumber(Options.GeodeReserve.Value) or 0
    for i, v in ipairs(qe) do
        local ti_1 = pj[v]
        if ti_1 then
            ti_1 = (th[v] or 0) > 0
        end
        if ti_1 then
            local ti_2 = p1[v] or 0
            if qt() - ti_2 >= ti then
                pk:Fire({ name = v })
                if Toggles.GeodeNotify.Value then
                    Library:Notify(("Bought %s"):format(v))
                end
                local wait = task.wait
                local tk_3 = Options.ActionDelay.Value or 0.2
                wait(tk_3)
            end
        end
    end
end
local function fn616()
    local vV_1
    local vS = pw()
    if not vS then
        return
    end
    for i, descendant in ipairs(workspace:GetDescendants()) do
        local vT = descendant:IsA("Model") and descendant.Name == "Buyer" and descendant:GetAttribute("OwnerUserId") == LocalPlayer.UserId
        if vT then
            if descendant:GetAttribute("NegotiateActive") then
                local vT_1 = descendant:GetAttribute("Offer") or 0
                local Value = Options.NegotiateMode.Value
                if Value == "Accept All" then
                    vV_1 = true
                elseif Value == "Minimum Amount" then
                    local vT_3 = tonumber(Options.NegotiateMinAmount.Value) or 0
                    vV_1 = vT_1 >= vT_3
                else
                    local vT_4 = qd(vS, descendant:GetAttribute("SlotName"))
                    local vW = vT_4 and pT(vT_4)
                    local vW_1 = vW or 0
                    vV_1 = vW_1 > 0 and vT_1 / vW_1 * 100 >= (Options.NegotiateMinRatio.Value or 100)
                end
                if vV_1 or Toggles.NegotiateReject.Value then
                    qD:Fire({ rig = descendant, accept = vV_1 })
                    if Toggles.NegotiateNotify.Value then
                        local vV_2 = vV_1 and "Accepted" or "Rejected"
                        Library:Notify(("%s offer of $%d"):format(vV_2, vT_1))
                    end
                    local wait = task.wait
                    local vU_1 = Options.ActionDelay.Value or 0.2
                    wait(vU_1)
                end
            end
        end
    end
end
local function fn619(i2)
    local DiscordGroup = i2:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = qE })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = qE })
end
local function fn627()
    local s1, s2, s3, te, tf, tg
    pp:Fire()
    local sX = pX("GeodeStock")
    local sY = tonumber(Options.GeodeReserve.Value) or 0
    local sY_1 = Options.GeodeBuyAmount.Value
    local s7 = if sY_1 then 1 else 0
    local s5 = 1986 * s7 + 519 * (1 - s7)
    local s6 = 373 * s7 + 1658 * (1 - s7)
    if not ((s5 * 2118 + s6 * 2462 + s5 * s6) % 16777213 == 5865452) then
        sY_1 = 1
    end
    local s_ = sY_1
    local sY_2 = Toggles.GeodeOnlyWhenFree.Value and math.min(s_, #px())
    local s0 = sY_2 or s_
    local sY_3 = 0
    local s__1 = s0
    local s9 = false
    for i, v in ipairs(qi) do
        local s8 = 17
        while true do
            if s8 < 13 then
                if s8 < 6 then
                    if s8 < 3 then
                        if s8 < 1 then
                            s0 = 0
                            s8 = 14
                        elseif s8 < 2 then
                            s8 = if (te * 2807 + tf * 240 + te * tf) % 16777213 == 1228620 then 14 else 0
                        else
                            s8 = 25
                        end
                    elseif s8 < 4 then
                        tf = 923 * tg + 1813 * (1 - tg)
                        s8 = 1
                    elseif s8 < 5 then
                        s2 = 0
                        s8 = 7
                    else
                        s2 = sY_3 < s__1
                        s8 = if s2 then 8 else 19
                    end
                elseif s8 < 9 then
                    if s8 < 7 then
                        s8 = 5
                    elseif s8 < 8 then
                        s3 = s2
                        s8 = if qt() - s3 < sY then 20 else 22
                    else
                        s2 = s0 < s1
                        s8 = 19
                    end
                elseif s8 < 11 then
                    if s8 < 10 then
                        s0 = s1 > 0
                        s8 = 23
                    else
                        s9 = true
                        s8 = 24
                    end
                elseif s8 < 12 then
                    s2(s3)
                    s8 = 21
                else
                    s0 = 0
                    s8 = 6
                end
            elseif s8 < 20 then
                if s8 < 16 then
                    if s8 < 14 then
                        s3 = 0.2
                        s8 = 11
                    elseif s8 < 15 then
                        s1 = s0
                        s0 = pl[v]
                        s8 = if s0 then 9 else 23
                    else
                        s2 = task.wait
                        s3 = Options.ActionDelay.Value
                        s8 = if s3 then 11 else 13
                    end
                elseif s8 < 18 then
                    if s8 < 17 then
                        s2 = p1[v]
                        s8 = if s2 then 7 else 4
                    else
                        s0 = sX[v]
                        tg = if s0 then 1 else 0
                        te = 270 * tg + 2075 * (1 - tg)
                        s8 = 3
                    end
                elseif s8 < 19 then
                    s8 = 2
                else
                    s8 = if s2 then 16 else 18
                end
            elseif s8 < 23 then
                if s8 < 21 then
                    s8 = 2
                elseif s8 < 22 then
                    s8 = 6
                else
                    ps:Fire({ name = v })
                    sY_3 += 1
                    s0 += 1
                    s8 = if Toggles.GeodeNotify.Value then 26 else 15
                end
            elseif s8 < 25 then
                if s8 < 24 then
                    s8 = if s0 then 12 else 25
                else
                    break
                end
            elseif s8 < 26 then
                s8 = 24
            else
                Library:Notify(("Bought %s"):format(v))
                s8 = 15
            end
        end
        if s9 then
            break
        end
    end
end
local function onUnload()
    Library:Unload()
end
local function fn668()
    local Data = PlayerData.Data
    local rS_1 = Data and Data.Cash
    local rX = if rS_1 then 1 else 0
    local rV = 38 * rX + 2841 * (1 - rX)
    local rW = 2364 * rX + 3063 * (1 - rX)
    if not ((rV * 1764 + rW * 3492 + rV * rW) % 16777213 == 8411952) then
        rS_1 = 0
    end
    return rS_1
end
local function fn672(g7)
    if type(g7) ~= "table" then
        return
    end
    if type(g7.owned) == "table" then
        pq = g7.owned
    end
    if type(g7.equipped) == "string" then
        pn = g7.equipped
    end
end
local function autoDeliverGemsLoop()
    while not Library.Unloaded do
        if Toggles.AutoDeliverGems.Value then
            pcall(pD)
        end
        task.wait(0.25)
    end
end
local function autoRebirthLoop()
    while not Library.Unloaded do
        if Toggles.AutoRebirth.Value then
            pcall(qk)
        end
        local As = Options.RebirthLoopDelay.Value or 10
        task.wait(As)
    end
end
local function fn748()
    local Character = LocalPlayer.Character
    local r9 = Character and Character:FindFirstChild("HumanoidRootPart")
    return r9
end
local function fn754()
    local zE_1
    local zD_1
    if identifyexecutor then
        zE_1, zD_1 = identifyexecutor()
        local zF = zE_1 ~= ""
        local zG = type(zE_1) == "string" and zF
        if zG then
            local zF_1 = type(zD_1) == "string" and zD_1 ~= "" and zE_1 .. " " .. zD_1
            qL = zF_1 or zE_1
        end
    end
end
local function fn764(hJ)
    local yH_1
    local yG_1
    local yF = pa()
    if not yF then
        return false
    end
    yH_1, yG_1 = hJ:GetBoundingBox()
    local yI = yH_1.Position + Vector3.new(0, yG_1.Y / 2 + 3, 0)
    if (yF.Position - yI).Magnitude > 1 then
        yF.CFrame = CFrame.new(yI)
    end
    return true
end
local function fn769()
    local yi = pw()
    local attr = LocalPlayer:GetAttribute("InMine")
    if not (yi and attr) then
        return nil
    end
    local yk_1 = yi:FindFirstChild(attr)
    local yi_1 = yk_1 and yk_1:IsA("Model")
    return yi_1 and yk_1 or nil
end
local function fn783(bA)
    local attr2 = bA:GetAttribute("Value")
    if attr2 then
        return attr2
    end
    local ComputeValue = GemConfig.ComputeValue
    local attr = bA:GetAttribute("GemName")
    local sC = bA:GetAttribute("Kg") or 0
    local sD = bA:GetAttribute("Purity") or 1
    local sE = bA:GetAttribute("RadMult") or 1
    return ComputeValue(attr, sC, sD, sE)
end
local function fn786()
    local sJ = pw()
    local sK = sJ and sJ:FindFirstChild("PlacedGrinders")
    local sJ_1 = {}
    if not sK then
        return sJ_1
    end
    for i, child in ipairs(sK:GetChildren()) do
        local GemSpawn = child:FindFirstChild("GemSpawn")
        local sL_1 = GemSpawn and GemSpawn:FindFirstChild("ProximityPrompt")
        local sM = sL_1
        if sL_1 then
            sL_1 = not child:GetAttribute("Grinding")
        end
        if sL_1 then
            sL_1 = not GemSpawn:FindFirstChild("PickPrompt")
        end
        if sL_1 then
            sJ_1[#sJ_1 + 1] = sM
        end
    end
    return sJ_1
end
local function fn792()
    local xH = qg()
    if xH >= (Options.RebirthMaxLevel.Value or #RebirthConfig.Rebirths) then
        return
    end
    local xI_1 = RebirthConfig.GetNext(xH)
    if not xI_1 then
        return
    end
    local xJ = qt()
    if xJ < (xI_1.price or math.huge) then
        return
    end
    qh:Fire()
    if Toggles.RebirthNotify.Value then
        Library:Notify(("Rebirthed to %d"):format(xH + 1))
    end
end
local function fn799()
    local Data = PlayerData.Data
    return Data and Data.Rebirths or 0
end
local function autoMineLoop()
    while not Library.Unloaded do
        if Toggles.AutoMine.Value then
            if Toggles.AutoEnterMine.Value then
                pcall(pr)
            end
            pcall(qv)
            if Toggles.AutoLeaveMine.Value then
                pcall(p7)
            end
        end
        local z0 = Options.MineLoopDelay.Value or 0.5
        task.wait(z0)
    end
end
local function autoBuyGeodesLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyGeodes.Value then
            pcall(qp)
        end
        if Toggles.AutoBuyDarkGeodes.Value then
            pcall(qr)
        end
        local zV = Options.GeodeLoopDelay.Value or 3
        task.wait(zV)
    end
end
local function onInputBegan()
    pR = tick()
end
local function onRedeemCodes()
    task.spawn(codesLoop)
end
local function autoInsertGeodesLoop()
    while not Library.Unloaded do
        if Toggles.AutoInsertGeodes.Value then
            pcall(p2)
        end
        local zY = Options.InsertLoopDelay.Value or 1
        task.wait(zY)
    end
end
local function fn902()
    local uE = pw()
    local uF = uE and uE:FindFirstChild("PlacedDisplays")
    local uE_1 = {}
    if not uF then
        return uE_1
    end
    for i, child in ipairs(uF:GetChildren()) do
        for i, descendant in ipairs(child:GetDescendants()) do
            local uF_1 = descendant:IsA("ProximityPrompt") and descendant.Name == "DisplayGemPrompt" and descendant.Enabled
            if uF_1 then
                uE_1[#uE_1 + 1] = descendant
            end
        end
    end
    return uE_1
end
local function fn932(cR)
    local t2 = (Options.SellMinPurity.Value or 0) / 100
    local t1_1 = tonumber(Options.SellMinValue.Value) or 0
    local t1_2 = cR:GetAttribute("Purity") or 0
    if t1_2 < t2 then
        return false
    end
    local t1_3 = cR:GetAttribute("Value") or 0
    if t1_3 < t1_1 then
        return false
    end
    return true
end
local function autoDiscardGemsLoop()
    while not Library.Unloaded do
        if Toggles.AutoDiscardGems.Value then
            pcall(qI)
        end
        if Toggles.AutoDisplayGems.Value then
            pcall(pB)
        end
        if Toggles.AutoPlaceGems.Value then
            pcall(qN)
        end
        local z9 = Options.PlaceGemLoopDelay.Value or 1
        task.wait(z9)
    end
end
local function fn979()
    local ui = pw()
    local uj = ui and ui:FindFirstChild("PlacedTables")
    local ui_1 = {}
    if not uj then
        return ui_1
    end
    for i, child in ipairs(uj:GetChildren()) do
        for i, descendant in ipairs(child:GetDescendants()) do
            local uj_1 = descendant:IsA("ProximityPrompt") and descendant.Name == "PlaceGemPrompt" and descendant.Enabled
            if uj_1 then
                ui_1[#ui_1 + 1] = descendant
            end
        end
    end
    return ui_1
end
local function fn1002()
    local Value = Toggles.GlobalAutoSell.Value
    if LocalPlayer:GetAttribute("AutoSell") == true ~= Value then
        qB:Fire({ enabled = Value })
    end
end
local function fn1008()
    connection:Disconnect()
    connection2:Disconnect()
    select("#", "Cut a Gem unloaded")
end
local function autoNegotiateLoop()
    while not Library.Unloaded do
        if Toggles.AutoNegotiate.Value then
            pcall(pu)
        end
        if Toggles.ApplySlotSettings.Value then
            pcall(pQ)
            pcall(qx)
        end
        local Ad = Options.NegotiateLoopDelay.Value
        local Ah = if Ad then 1 else 0
        local Af = 1889 * Ah + 830 * (1 - Ah)
        local Ag = 801 * Ah + 689 * (1 - Ah)
        if not ((Af * 1058 + Ag * 151 + Af * Ag) % 16777213 == 3632602) then
            Ad = 1
        end
        task.wait(Ad)
    end
end
local function fn1027(hs)
    local Get = MineConfig.Get
    local yq = hs:GetAttribute("MineName") or ""
    local yr = Get(yq)
    local yq_1 = yr and yr.RockHealth
    local yp_2 = yq_1 ~= nil and hs:GetAttribute("MaxHealth") == yq_1.Sparkle
    return yp_2
end
local function fn1034(em, en)
    local vL = em and em:FindFirstChild("Slots")
    local vM = vL
    if vL then
        local vN = en or ""
        vL = vM:FindFirstChild(vN)
    end
    local vM_1 = vL
    if vL then
        vL = vM_1:FindFirstChild("Spawn")
    end
    local vM_2 = vL
    if vL then
        vL = vM_2:FindFirstChild("PlacedGem")
    end
    return vL
end
local function fn1038(hb)
    local ya = pa()
    if not (ya and hb.Parent) then
        return false
    end
    local Parent = hb.Parent
    local yc = Parent:IsA("BasePart") and Parent.Position
    local yd = yc or Parent:GetPivot().Position
    if (ya.Position - yd).Magnitude > hb.MaxActivationDistance - 2 then
        ya.CFrame = CFrame.new(yd + Vector3.new(0, 4, 0))
        task.wait(0.2)
    end
    fireproximityprompt(hb)
    local wait = task.wait
    local yb_3 = Options.ActionDelay.Value or 0.2
    wait(yb_3)
    return true
end
local function fn1086(aN)
    local Data = PlayerData.Data
    return Data and Data[aN] or {}
end
local function autoBuyItemsLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyItems.Value then
            pcall(qf)
        end
        local Aj = Options.ItemLoopDelay.Value or 5
        task.wait(Aj)
    end
end
local function fn1118()
    local Map = workspace:FindFirstChild("Map")
    local r5 = Map and Map:FindFirstChild("Plots")
    local attr = LocalPlayer:GetAttribute("PlotName")
    if not (r5 and attr) then
        return nil
    end
    return r5:FindFirstChild(attr)
end
o6 = nil
Options = nil
o8 = nil
o9 = nil
pa = nil
pb = nil
Toggles = nil
pd = nil
pe = nil
pf = nil
pg = nil
ph = nil
pi = nil
pj = nil
pk = nil
pl = nil
pm = nil
pn = nil
po = nil
pp = nil
pq = nil
pr = nil
ps = nil
Library = nil
pu = nil
pv = nil
pw = nil
px = nil
PlayerData = nil
pz = nil
pA = nil
pB = nil
PickaxeConfig = nil
pD = nil
pE = nil
pF = nil
pG = nil
pH = nil
MineConfig = nil
pJ = nil
pK = nil
pL = nil
pM = nil
RebirthConfig = nil
pO = nil
pP = nil
pQ = nil
pR = nil
pS = nil
pT = nil
pU = nil
pV = nil
pX = nil
pY = nil
pZ = nil
p_ = nil
p0 = nil
p1 = nil
p2 = nil
p3 = nil
p4 = nil
p5 = nil
GemConfig = nil
p7 = nil
p8 = nil
p9 = nil
qa = nil
qb = nil
qc = nil
qd = nil
qe = nil
qf = nil
qg = nil
qh = nil
qi = nil
qj = nil
qk = nil
ql = nil
qm = nil
connection2 = nil
LocalPlayer = nil
qp = nil
qq = nil
qr = nil
qs = nil
qt = nil
qu = nil
qv = nil
qw = nil
qx = nil
qy = nil
qz = nil
VirtualUser = nil
qB = nil
codesLoop = nil
qD = nil
qE = nil
qG = nil
local pW, qF
qH = nil
qI = nil
qJ = nil
qK = nil
qL = nil
connection = nil
qN = nil
qH, VirtualUser, LocalPlayer = nil, nil, nil
local AC_8 = game:GetService("Players")
qH = game:GetService("ReplicatedStorage")
local AC_25 = game:GetService("ReplicatedFirst")
VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
LocalPlayer = AC_8.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end
AC_47, GemConfig, RebirthConfig, MineConfig, PickaxeConfig, PlayerData, ps, pp, pk, ph, pf, pb, o6, qJ, qD, qB, qw, qq, qm, qj, qh, qc, p8, p0, pZ, pW, pU, pO, pK, pF, Library, Toggles, Options, qK, qs, qi, qe, p9, p1, qE = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if ((pf or not pf) and (not pf or pK) or qj and not pK and (qj and pK) or (pK and pf or pK and not qD or (pf or pf or (qj or not pf)))) and ((qD or not pf or (not qj or pK) or (qj and not pf or (qj or not qD))) and (not pf and qj and (not qj and not qj) or (not pK or qD) and (not qD and qj))) and not (((pf or not pf) and (not pf or pK) or qj and not pK and (qj and pK) or (pK and pf or pK and not qD or (pf or pf or (qj or not pf)))) and ((qD or not pf or (not qj or pK) or (qj and not pf or (qj or not qD))) and (not pf and qj and (not qj and not qj) or (not pK or qD) and (not qD and qj)))) then
    qH = require(AC_47:WaitForChild("Packages"):WaitForChild("BridgeNet2"))
else
    AC_47 = require(qH:WaitForChild("Packages"):WaitForChild("BridgeNet2"))
end
local AC_16 = require(qH.Shared.GeodeConfig)
GemConfig = require(qH.Shared.GemConfig)
local AC_14 = require(qH.Shared.GrinderConfig)
local AC_28 = require(qH.Shared.DisplayTableConfig)
local AC_44 = require(qH.Shared.TotemsConfig)
local AC_41 = require(qH.Shared.DisplayConfig)
RebirthConfig = require(qH.Shared.RebirthConfig)
MineConfig = require(qH.Shared.MineConfig)
PickaxeConfig = require(qH.Shared.PickaxeConfig)
PlayerData = require(AC_25.Modules.PlayerData)
ps = AC_47.ReferenceBridge("BuyGeode")
pp = AC_47.ReferenceBridge("RequestStock")
pk = AC_47.ReferenceBridge("BuyDarkGeode")
ph = AC_47.ReferenceBridge("RequestDarkStock")
pf = AC_47.ReferenceBridge("BuyItem")
pb = AC_47.ReferenceBridge("RequestItemStock")
o6 = AC_47.ReferenceBridge("PlaceItem")
qJ = AC_47.ReferenceBridge("ConveyorReached")
qD = AC_47.ReferenceBridge("NegotiateResponse")
if (not AC_44 and AC_44 and (not AC_47 or not AC_44) or (AC_47 or not AC_44) and (AC_44 or not AC_44)) and ((AC_44 or not AC_47 or AC_44 and AC_44) and ((not AC_47 or AC_47) and (not AC_47 or AC_47))) or (not AC_47 and AC_47 and (AC_47 and AC_47) or (AC_44 or AC_44 or (not AC_47 or not AC_47)) or (not AC_47 or not AC_47) and (not AC_44 or AC_47) and (AC_47 and not AC_44 and (AC_47 or not AC_47))) or not ((not AC_44 and AC_44 and (not AC_47 or not AC_44) or (AC_47 or not AC_44) and (AC_44 or not AC_44)) and ((AC_44 or not AC_47 or AC_44 and AC_44) and ((not AC_47 or AC_47) and (not AC_47 or AC_47))) or (not AC_47 and AC_47 and (AC_47 and AC_47) or (AC_44 or AC_44 or (not AC_47 or not AC_47)) or (not AC_47 or not AC_47) and (not AC_44 or AC_47) and (AC_47 and not AC_44 and (AC_47 or not AC_47)))) then
    qB = AC_47.ReferenceBridge("AutoSellToggle")
    qw = AC_47.ReferenceBridge("BuySlot")
    qq = AC_47.ReferenceBridge("BuySlotUpgrade")
    qm = AC_47.ReferenceBridge("SetSlotMargin")
else
    AC_47 = qB.ReferenceBridge("AutoSellToggle")
    qm = qB.ReferenceBridge("BuySlot")
    qw = qB.ReferenceBridge("BuySlotUpgrade")
    qq = qB.ReferenceBridge("SetSlotMargin")
end
qj = AC_47.ReferenceBridge("ToggleSlotAuto")
qh = AC_47.ReferenceBridge("RebirthDo")
qc = AC_47.ReferenceBridge("SpinDo")
p8 = AC_47.ReferenceBridge("DailyClaim")
p0 = AC_47.ReferenceBridge("PlaytimeClaim")
pZ = AC_47.ReferenceBridge("GroupRewardClaim")
pW = AC_47.ReferenceBridge("RedeemCode")
pU = AC_47.ReferenceBridge("MineSwing")
pO = AC_47.ReferenceBridge("PickaxeBuy")
if (Toggles and not pk or Toggles and Library or (not pk or not Toggles or not Toggles and pk)) and ((Toggles and not pk or (not Library or not Library)) and ((Toggles or not Toggles) and (not Toggles and not pk))) and not ((Toggles and not pk or Toggles and Library or (not pk or not Toggles or not Toggles and pk)) and ((Toggles and not pk or (not Library or not Library)) and ((Toggles or not Toggles) and (not Toggles and not pk)))) then
    pF.ReferenceBridge("PickaxeEquip")
    pK = pF.ReferenceBridge("PickaxeSync")
else
    pK = AC_47.ReferenceBridge("PickaxeEquip")
    pF = AC_47.ReferenceBridge("PickaxeSync")
end
Library = getgenv().Library
pcall(fns.fn509)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
qK = "https://discord.gg/K7Qxnxkk46"
qE = fns.fn27
qs = { "PlacedGrinders", "PlacedTables", "PlacedTotems", "PlacedDisplays" }
local AC_49 = { "Grinders", "Tables", "Totems", "Displays" }
local AC_33 = { Grinders = AC_14, Tables = AC_28, Totems = AC_44, Displays = AC_41 }
qi = {}
qe = {}
p9 = {}
p1 = {}
for i, v in ipairs(AC_16.GetAll()) do
    AC_8 = v.name
    AC_41 = v.tier
    local AC_36 = if AC_41 then 1 else 0
    local AC_21 = 2414 * AC_36 + 1253 * (1 - AC_36)
    local AC_3 = 491 * AC_36 + 449 * (1 - AC_36)
    if not ((AC_21 * 2339 + AC_3 * 436 + AC_21 * AC_3) % 16777213 == 7045696) then
        AC_41 = 0
    end
    p9[AC_8] = AC_41
    AC_8 = v.name
    AC_41 = v.price or 0
    p1[AC_8] = AC_41
    if v.Dark then
        qe[#qe + 1] = v.name
    elseif not v.ExcludeShop then
        qi[#qi + 1] = v.name
    end
end
pV, pP, pL = nil, nil, nil
AC_8 = 1
repeat
    if AC_8 * 84554681 + 12 + 4 <= AC_8 * 84554681 + 12 + 4 + 6 then
        pV = {}
        pP = {}
        pL = {}
    else
        pP = {}
        pL = {}
        pV = {}
    end
    AC_8 = (AC_8 + 6) % 8
until (AC_8 * 3 + 1) % 8 == 6
for i, v in ipairs(AC_49) do
    for i, v2 in ipairs(AC_33[v].GetAll()) do
        if not v2.ExcludeShop then
            pV[#pV + 1] = v2.name
            AC_8 = v2.name
            AC_41 = v2.price or 0
            pP[AC_8] = AC_41
            pL[v2.name] = v
        end
    end
end
pl, pj, pg, pd, pJ, qF, pq, pn, o9, qt, qg, pX, pw, pa, qy, qb, qu, pT, px, qp, qr, pi, p2, pm, p_, pG, qz, pS, qN, pB, qI, pD, qd, pu, pQ, qx, qf, qG, pY, p5, ql, pE, qk, pv, codesLoop, p3, o8, qa, pH, pe, p4, pA, pr, qv, p7, pz, AC_25 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if (pz or pi or (pn or qb) or (not pz or not pn) and (pi and pz)) and (pi and pz and (not pn or pi) and ((not pi or pn) and (pn or not pi))) or not ((pz or pi or (pn or qb) or (not pz or not pn) and (pi and pz)) and (pi and pz and (not pn or pi) and ((not pi or pn) and (pn or not pi)))) then
    pl = {}
    pj = {}
    pg = {}
else
    pg = {}
    pl = {}
    pj = {}
end
pd = {}
o9 = fns.fn494
qt = fn668
qg = fn799
pX = fn1086
pw = fn1118
pa = fn748
qy = fns.fn46
qb = fns.fn368
qu = fns.fn109
pT = fn783
px = fn786
qp = fn627
qr = fn600
pi = fns.fn171
p2 = fns.fn361
pm = fns.fn297
p_ = fn932
pG = fns.fn394
qz = fn979
pS = fn902
qN = fns.fn124
pB = fns.fn304
qI = fns.fn215
pJ = {}
pD = fns.fn525
qd = fn1034
pu = fn616
pQ = fns.fn349
qx = fn1002
qf = fns.fn184
qG = fns.fn188
pY = fns.fn293
p5 = fns.fn551
if not pw and qv and (not pj and not pS) and (pj or pS or (AC_25 or not pw)) and ((qv and qv or (pw or not pj)) and (AC_25 and not pw or (pw or not AC_25))) and not (not pw and qv and (not pj and not pS) and (pj or pS or (AC_25 or not pw)) and ((qv and qv or (pw or not pj)) and (AC_25 and not pw or (pw or not AC_25)))) then
    pd = fns.fn554
else
    ql = fns.fn554
end
pE = fns.fn68
qk = fn792
pv = fns.fn384
qF = {}
codesLoop = function()
    local xR = Options.Codes.Value
    local xW = if xR then 1 else 0
    local xU = 769 * xW + 1771 * (1 - xW)
    local xV = 157 * xW + 3103 * (1 - xW)
    if not ((xU * 727 + xV * 908 + xU * xV) % 16777213 == 822352) then
        xR = ""
    end
    local xS = xR
    for k in xS:gmatch("[^,%s]+") do
        local x_ = k
        if not qF[x_] then
            qF[x_] = true
            pcall(function()
                pW:InvokeServerAsync({ code = x_ })
            end)
            task.wait(0.5)
        end
    end
end
p3 = fns.fn346
pq = {}
pn = PickaxeConfig.Default
pF:Connect(fn672)
pF:Fire()
o8 = fn1038
qa = fn769
pH = fn1027
pe = fns.fn225
p4 = fn764
pA = fns.fn502
pr = fns.fn192
qv = fns.fn21
p7 = fns.fn404
pz = fns.fn235
AC_8 = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = "https://discord.gg/K7Qxnxkk46 | Cut a Gem",
    Icon = 18657887261,
    NotifySide = "Right",
    Size = UDim2.fromOffset(900, 640),
    ShowCustomCursor = false
})
Library.ShowCustomCursor = false
AC_44 = {
    Info = AC_8:AddTab("Info", "info"),
    Grinding = AC_8:AddTab("Grinding", "gem"),
    Mining = AC_8:AddTab("Mining", "pickaxe"),
    Selling = AC_8:AddTab("Selling", "banknote"),
    Shop = AC_8:AddTab("Shop", "shopping-cart"),
    Progress = AC_8:AddTab("Progress", "trending-up"),
    Settings = AC_8:AddTab("Settings", "settings")
}
AC_25 = fn619
for k, v in AC_44 do
    AC_25(v)
end
qL, AutoBuyGeodesGroup, MineAccessGroup, AutoPlaceItemsGroup, AutoRebirthGroup, CodesGroup, ActionsGroup, pR, pM, connection, connection2, po = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
AC_8 = AC_44.Info:AddLeftGroupbox("Basic Info", "circle-user")
qL = "Unknown"
pcall(fn754)
AC_8:AddLabel("Executor: " .. qL, true)
AC_8:AddLabel("Game: Cut a Gem", true)
AC_8:AddLabel("Player: " .. LocalPlayer.Name, true)
AC_8:AddLabel("Status: Keyless", true)
local TempoHubGroup = AC_44.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = qE })
local FaqGroup = AC_44.Info:AddRightGroupbox("FAQ", "circle-help")
if (not qL or AutoRebirthGroup or AutoRebirthGroup and not qL) and ((qL or not CodesGroup) and (not qL and MineAccessGroup)) and not ((not qL or AutoRebirthGroup or AutoRebirthGroup and not qL) and ((qL or not CodesGroup) and (not qL and MineAccessGroup))) then
    AC_44:AddLabel("Where do I get a good config?", true)
    AC_44:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
    AC_44:AddLabel("How do I import / export configs?", true)
    AC_44:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
    AC_44:AddLabel("How do I report bugs?", true)
    AC_44:AddLabel("Join the Discord and post it in the bugs channel.", true)
    AC_44:AddLabel("How do I make suggestions?", true)
    AC_44:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
    AC_44:AddLabel("How do I get help or updates?", true)
    AC_44:AddLabel("Join the Discord, updates and support are posted there first.", true)
    AutoBuyGeodesGroup.Grinding:AddLeftGroupbox("Auto Buy Geodes", "package")
else
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
    AutoBuyGeodesGroup = AC_44.Grinding:AddLeftGroupbox("Auto Buy Geodes", "package")
end
AutoBuyGeodesGroup:AddToggle("AutoBuyGeodes", { Text = "Auto Buy Geodes", Default = false })
AutoBuyGeodesGroup:AddDropdown("BuyGeodes", { Text = "Geodes To Buy", Values = qi, Default = {}, Multi = true, Callback = fns.onBuyGeodes })
AutoBuyGeodesGroup:AddToggle("AutoBuyDarkGeodes", { Text = "Auto Buy Dark Geodes", Default = false })
AutoBuyGeodesGroup:AddDropdown("BuyDarkGeodes", {
    Text = "Dark Geodes To Buy",
    Values = qe,
    Default = {},
    Multi = true,
    Callback = fns.onBuyDarkGeodes
})
AutoBuyGeodesGroup:AddToggle("GeodeOnlyWhenFree", { Text = "Only Buy For Free Grinders", Default = true })
AutoBuyGeodesGroup:AddSlider("GeodeBuyAmount", { Text = "Max Buys Per Cycle", Default = 3, Min = 1, Max = 25, Rounding = 0 })
AutoBuyGeodesGroup:AddInput("GeodeReserve", {
    Text = "Keep Cash Reserve",
    Default = "0",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
AutoBuyGeodesGroup:AddToggle("GeodeNotify", { Text = "Notify On Buy", Default = false })
AutoBuyGeodesGroup:AddSlider("GeodeLoopDelay", { Text = "Loop Delay", Default = 3, Min = 0.5, Max = 30, Rounding = 1 })
AC_33 = AC_44.Grinding:AddRightGroupbox("Auto Grind", "cog")
AC_33:AddToggle("AutoInsertGeodes", { Text = "Auto Put Geodes In Grinders", Default = false })
AC_33:AddDropdown("InsertMode", {
    Text = "Geode Priority",
    Values = { "Highest Tier", "Lowest Tier", "Selected Geodes" },
    Default = "Highest Tier",
    Multi = false
})
AC_33:AddDropdown("InsertGeodes", { Text = "Geodes To Grind", Values = qi, Default = {}, Multi = true, Callback = fns.onInsertGeodes })
AC_33:AddToggle("InsertNotify", { Text = "Notify On Grind Start", Default = false })
AC_33:AddSlider("InsertLoopDelay", { Text = "Loop Delay", Default = 1, Min = 0.2, Max = 20, Rounding = 1 })
AC_49 = AC_44.Grinding:AddRightGroupbox("Auto Collect", "hand")
AC_49:AddToggle("AutoCollectGems", { Text = "Auto Collect Gems At Perfect Purity", Default = false })
AC_49:AddToggle("CollectNotify", { Text = "Notify On Collect", Default = false })
AC_49:AddSlider("CollectLoopDelay", { Text = "Loop Delay", Default = 0.2, Min = 0.05, Max = 5, Rounding = 2 })
AC_16 = AC_44.Mining:AddLeftGroupbox("Auto Mine", "mountain")
AC_16:AddToggle("AutoMine", { Text = "Auto Mine Rocks", Default = false })
AC_16:AddDropdown("MineRockType", {
    Text = "Rocks To Mine",
    Values = { "All Rocks", "Sparkle Only", "Normal Only" },
    Default = "All Rocks",
    Multi = false
})
AC_16:AddSlider("SwingDelay", { Text = "Swing Delay", Default = 0.35, Min = 0.05, Max = 2, Rounding = 2 })
AC_16:AddToggle("MineNotify", { Text = "Notify On Rock Break", Default = false })
AC_16:AddSlider("MineLoopDelay", { Text = "Loop Delay", Default = 0.5, Min = 0.1, Max = 10, Rounding = 1 })
MineAccessGroup = AC_44.Mining:AddRightGroupbox("Mine Access", "door-open")
MineAccessGroup:AddToggle("AutoEnterMine", { Text = "Auto Take Elevator Down", Default = false })
MineAccessGroup:AddToggle("AutoLeaveMine", { Text = "Auto Leave When Mine Is Empty", Default = false })
AC_47 = AC_44.Mining:AddRightGroupbox("Pickaxe", "axe")
AC_47:AddToggle("AutoBuyPickaxe", { Text = "Auto Buy Pickaxes", Default = false })
AC_47:AddToggle("AutoEquipPickaxe", { Text = "Auto Equip Best Pickaxe", Default = false })
AC_47:AddInput("PickaxeReserve", {
    Text = "Keep Cash Reserve",
    Default = "0",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
AC_47:AddToggle("PickaxeNotify", { Text = "Notify On Buy", Default = false })
AC_47:AddSlider("PickaxeLoopDelay", { Text = "Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
AC_14 = AC_44.Selling:AddLeftGroupbox("Auto Place Gems", "move-right")
AC_14:AddToggle("AutoPlaceGems", { Text = "Auto Place Gems", Default = false })
AC_14:AddDropdown("GemDestination", { Text = "Destination", Values = { "Conveyor", "Table" }, Default = "Conveyor", Multi = false })
AC_14:AddSlider("SellMinPurity", { Text = "Minimum Purity", Default = 0, Min = 0, Max = 100, Rounding = 0, Suffix = "%" })
AC_14:AddInput("SellMinValue", {
    Text = "Minimum Value",
    Default = "0",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
AC_14:AddToggle("AutoDeliverGems", { Text = "Instant Conveyor Delivery", Default = false })
AC_14:AddToggle("PlaceGemNotify", { Text = "Notify On Place", Default = false })
AC_14:AddSlider("PlaceGemLoopDelay", { Text = "Loop Delay", Default = 1, Min = 0.2, Max = 20, Rounding = 1 })
AC_28 = AC_44.Selling:AddRightGroupbox("Auto Negotiate", "handshake")
AC_28:AddToggle("AutoNegotiate", { Text = "Auto Answer Buyers", Default = false })
AC_28:AddDropdown("NegotiateMode", {
    Text = "Accept When",
    Values = { "Minimum Ratio", "Minimum Amount", "Accept All" },
    Default = "Minimum Ratio",
    Multi = false
})
AC_28:AddSlider("NegotiateMinRatio", { Text = "Minimum Offer Ratio", Default = 100, Min = 10, Max = 300, Rounding = 0, Suffix = "%" })
AC_28:AddInput("NegotiateMinAmount", {
    Text = "Minimum Offer Amount",
    Default = "0",
    Numeric = true,
    Finished = false,
    ClearTextOnFocus = false
})
AC_28:AddToggle("NegotiateReject", { Text = "Reject Bad Offers", Default = true })
AC_28:AddToggle("NegotiateNotify", { Text = "Notify On Answer", Default = false })
AC_28:AddSlider("NegotiateLoopDelay", { Text = "Loop Delay", Default = 1, Min = 0.2, Max = 20, Rounding = 1 })
AC_41 = AC_44.Selling:AddLeftGroupbox("Slots", "layout-grid")
AC_41:AddToggle("ApplySlotSettings", { Text = "Apply Slot Settings", Default = false })
AC_41:AddToggle("SlotAutoSell", { Text = "Slot Auto Sell", Default = false })
AC_41:AddSlider("SlotMargin", { Text = "Slot Margin", Default = 10, Min = 0, Max = 100, Rounding = 0, Suffix = "%" })
AC_41:AddToggle("GlobalAutoSell", { Text = "Game Auto Sell", Default = false })
local AutoDiscardGroup = AC_44.Selling:AddRightGroupbox("Auto Discard", "trash-2")
AutoDiscardGroup:AddToggle("AutoDiscardGems", { Text = "Auto Discard Gems", Default = false })
AutoDiscardGroup:AddSlider("DiscardMaxPurity", { Text = "Discard Below Purity", Default = 20, Min = 0, Max = 100, Rounding = 0, Suffix = "%" })
local AutoBuyItemsGroup = AC_44.Shop:AddLeftGroupbox("Auto Buy Items", "store")
if ((not pR or pR) and (not pR or not AC_49) or (not AC_41 or not AC_49) and (AC_41 or not AC_41)) and ((AC_41 or not AC_41) and (AC_49 and not pR) and ((AC_49 or not AC_41) and (AC_49 or AC_41))) and not (((not pR or pR) and (not pR or not AC_49) or (not AC_41 or not AC_49) and (AC_41 or not AC_41)) and ((AC_41 or not AC_41) and (AC_49 and not pR) and ((AC_49 or not AC_41) and (AC_49 or AC_41)))) then
    AutoPlaceItemsGroup:AddToggle("AutoBuyItems", { Text = "Auto Buy Items", Default = false })
    AutoPlaceItemsGroup:AddDropdown("BuyItems", { Text = "Items To Buy", Multi = true, Values = AC_44, Callback = fns.onBuyItems, Default = {} })
    AutoPlaceItemsGroup:AddInput("ItemReserve", {
        Numeric = true,
        Default = "0",
        Finished = false,
        Text = "Keep Cash Reserve",
        ClearTextOnFocus = false
    })
    AutoPlaceItemsGroup:AddToggle("ItemNotify", { Text = "Notify On Buy", Default = false })
    AutoPlaceItemsGroup:AddSlider("ItemLoopDelay", { Min = 1, Rounding = 1, Max = 60, Text = "Loop Delay", Default = 5 })
    pV.Shop:AddRightGroupbox("Auto Place Items", "hammer")
else
    AutoBuyItemsGroup:AddToggle("AutoBuyItems", { Text = "Auto Buy Items", Default = false })
    AutoBuyItemsGroup:AddDropdown("BuyItems", { Text = "Items To Buy", Values = pV, Default = {}, Multi = true, Callback = fns.onBuyItems })
    AutoBuyItemsGroup:AddInput("ItemReserve", {
        Text = "Keep Cash Reserve",
        Default = "0",
        Numeric = true,
        Finished = false,
        ClearTextOnFocus = false
    })
    AutoBuyItemsGroup:AddToggle("ItemNotify", { Text = "Notify On Buy", Default = false })
    AutoBuyItemsGroup:AddSlider("ItemLoopDelay", { Text = "Loop Delay", Default = 5, Min = 1, Max = 60, Rounding = 1 })
    AutoPlaceItemsGroup = AC_44.Shop:AddRightGroupbox("Auto Place Items", "hammer")
end
AutoPlaceItemsGroup:AddToggle("AutoPlaceItems", { Text = "Auto Place Owned Items", Default = false })
AutoPlaceItemsGroup:AddToggle("PlaceItemNotify", { Text = "Notify On Place", Default = false })
AutoPlaceItemsGroup:AddSlider("PlaceItemLoopDelay", { Text = "Loop Delay", Default = 3, Min = 0.5, Max = 30, Rounding = 1 })
local AutoExpandGroup = AC_44.Shop:AddRightGroupbox("Auto Expand", "maximize")
if not connection2 and ActionsGroup and (not connection2 or ActionsGroup) and ((not connection2 or pM) and (pM or not pM)) and not (not connection2 and ActionsGroup and (not connection2 or ActionsGroup) and ((not connection2 or pM) and (pM or not pM))) then
    AC_44:AddToggle("AutoBuyBases", { Text = "Auto Buy Bases", Default = false })
    AC_44:AddToggle("AutoBuySlots", { Text = "Auto Buy Slots", Default = false })
    AC_44:AddToggle("BuySlotUpgrades", { Text = "Auto Buy Slot Upgrades", Default = false })
    AC_44:AddSlider("ExpandLoopDelay", { Default = 10, Text = "Loop Delay", Min = 1, Max = 60, Rounding = 1 })
    AutoRebirthGroup.Progress:AddLeftGroupbox("Auto Rebirth", "refresh-cw")
else
    AutoExpandGroup:AddToggle("AutoBuyBases", { Text = "Auto Buy Bases", Default = false })
    AutoExpandGroup:AddToggle("AutoBuySlots", { Text = "Auto Buy Slots", Default = false })
    AutoExpandGroup:AddToggle("BuySlotUpgrades", { Text = "Auto Buy Slot Upgrades", Default = false })
    AutoExpandGroup:AddSlider("ExpandLoopDelay", { Text = "Loop Delay", Default = 10, Min = 1, Max = 60, Rounding = 1 })
    AutoRebirthGroup = AC_44.Progress:AddLeftGroupbox("Auto Rebirth", "refresh-cw")
end
AutoRebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
AutoRebirthGroup:AddSlider("RebirthMaxLevel", {
    Text = "Max Rebirth Level",
    Default = #RebirthConfig.Rebirths,
    Min = 1,
    Max = #RebirthConfig.Rebirths,
    Rounding = 0
})
AutoRebirthGroup:AddToggle("RebirthNotify", { Text = "Notify On Rebirth", Default = true })
AutoRebirthGroup:AddSlider("RebirthLoopDelay", { Text = "Loop Delay", Default = 10, Min = 1, Max = 60, Rounding = 1 })
local AutoRewardsGroup = AC_44.Progress:AddRightGroupbox("Auto Rewards", "gift")
AutoRewardsGroup:AddToggle("AutoSpin", { Text = "Auto Free Spin", Default = false })
AutoRewardsGroup:AddToggle("AutoDaily", { Text = "Auto Daily Gift", Default = false })
AutoRewardsGroup:AddToggle("AutoPlaytime", { Text = "Auto Playtime Rewards", Default = false })
AutoRewardsGroup:AddToggle("AutoPlaytimePad", { Text = "Auto Claim Playtime Pad", Default = false })
AutoRewardsGroup:AddToggle("AutoGroupReward", { Text = "Auto Group Reward", Default = false })
AutoRewardsGroup:AddSlider("RewardLoopDelay", { Text = "Loop Delay", Default = 15, Min = 5, Max = 120, Rounding = 0 })
local IndexGroup = AC_44.Progress:AddLeftGroupbox("Index", "book-open")
IndexGroup:AddToggle("AutoDisplayGems", { Text = "Auto Display Gems", Default = false })
CodesGroup = AC_44.Progress:AddRightGroupbox("Codes", "ticket")
CodesGroup:AddInput("Codes", {
    Text = "Codes",
    Default = "PRETTYGAME, 1KLIKES, 100KVISITS",
    Finished = false,
    ClearTextOnFocus = false
})
CodesGroup:AddButton({ Text = "Redeem Codes", Func = onRedeemCodes })
local MenuGroup = AC_44.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
ActionsGroup = AC_44.Settings:AddRightGroupbox("Actions", "move")
ActionsGroup:AddToggle("ReturnAfterAction", { Text = "Return After Teleport", Default = true })
ActionsGroup:AddSlider("ActionDelay", { Text = "Action Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
pR = tick()
pM = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local zO = v
        pcall(function()
            zO:Disable()
        end)
    end
end)
po = fns.fn373
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(fns.onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(fn1008)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/CutAGem")
SaveManager:BuildConfigSection(AC_44.Settings)
ThemeManager:ApplyToTab(AC_44.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
task.spawn(autoBuyGeodesLoop)
task.spawn(autoInsertGeodesLoop)
task.spawn(autoMineLoop)
task.spawn(fns.autoBuyPickaxeLoop)
task.spawn(fns.autoCollectGemsLoop)
task.spawn(autoDiscardGemsLoop)
task.spawn(autoDeliverGemsLoop)
task.spawn(autoNegotiateLoop)
task.spawn(autoBuyItemsLoop)
task.spawn(fns.autoPlaceItemsLoop)
task.spawn(fns.autoBuyBasesLoop)
task.spawn(autoRebirthLoop)
task.spawn(fns.autoPlaytimePadLoop)
task.spawn(fns.antiAfkLoop)
Library:Notify("Cut a Gem loaded")
end)(...)
