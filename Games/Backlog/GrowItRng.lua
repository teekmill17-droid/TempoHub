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
getgenv().TempoHoodSubtitle = "GROW IT RNG"
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
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = getgenv().Library
if getgenv()._GrowItRNG_Unload then
    pcall(getgenv()._GrowItRNG_Unload)
end
getgenv()._GrowItRNG_Unload = function()
    if Library and not Library.Unloaded then
        Library:Unload()
    end
end
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlantSeed = Remotes:WaitForChild("PlantSeed")
local PlaceBed = Remotes:WaitForChild("PlaceBed")
local PlaceSellTable = Remotes:WaitForChild("PlaceSellTable")
local PlaceCrate = Remotes:WaitForChild("PlaceCrate")
local DepositCrop = Remotes:WaitForChild("DepositCrop")
local CustomerOffer = Remotes:WaitForChild("CustomerOffer")
local CustomerOfferClear = Remotes:WaitForChild("CustomerOfferClear")
local CustomerDecision = Remotes:WaitForChild("CustomerDecision")
local BuySeedRequest = Remotes:WaitForChild("BuySeedRequest")
local BuyStructure = Remotes:WaitForChild("BuyStructure")
local OpenCrateCash = Remotes:WaitForChild("OpenCrateCash")
local BuyUpgrade = Remotes:WaitForChild("BuyUpgrade")
local QuestClaim = Remotes:WaitForChild("QuestClaim")
local PlaytimeClaim = Remotes:WaitForChild("PlaytimeClaim")
local RebirthRequest = Remotes:WaitForChild("RebirthRequest")
local RebirthBuyUpgrade = Remotes:WaitForChild("RebirthBuyUpgrade")
local RebirthBuyItem = Remotes:WaitForChild("RebirthBuyItem")
local RedeemCode = Remotes:WaitForChild("RedeemCode")
local RequestSteal = Remotes:WaitForChild("RequestSteal")
local TrashHeld = Remotes:WaitForChild("TrashHeld")
local PlaceTotem = Remotes:WaitForChild("PlaceTotem")
local PlaceDecoration = Remotes:WaitForChild("PlaceDecoration")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local SeedData = require(Modules:WaitForChild("SeedData"))
local PetData = require(Modules:WaitForChild("PetData"))
local RebirthConfig = require(Modules:WaitForChild("RebirthConfig"))
local BedData = require(Modules:WaitForChild("BedData"))
local SellTableData = require(Modules:WaitForChild("SellTableData"))
local TotemData = require(Modules:WaitForChild("TotemData"))
local DecorationData = require(Modules:WaitForChild("DecorationData"))
local GearData = require(Modules:WaitForChild("GearData"))
local CrateData = require(Modules:WaitForChild("CrateData"))
local seedNames, seedIdByName, seedNameById, seedDisplayNameById, seedTierById = {}, {}, {}, {}, {}
for _, v in ipairs(SeedData.List) do
    local label = string.format("%s (t%s)", v.name, tostring(v.tier))
    table.insert(seedNames, label)
    seedIdByName[label] = v.id
    seedNameById[v.id] = label
    seedDisplayNameById[v.id] = v.name
    seedTierById[v.id] = tonumber(v.tier) or 0
end
local petNames = {}
for _, v in ipairs(PetData.Pets) do
    if v.model then
        table.insert(petNames, v.model)
    end
end
local rebirthUpgradeNames, rebirthUpgradeKey = {}, {}
for _, v in ipairs(RebirthConfig.Upgrades) do
    table.insert(rebirthUpgradeNames, v.name)
    rebirthUpgradeKey[v.name] = v.key
end
local rebirthItemNames, rebirthItemKey = {}, {}
for _, v in ipairs(RebirthConfig.Items) do
    table.insert(rebirthItemNames, v.name)
    rebirthItemKey[v.name] = v.key
end
local function buildShopEntries(list)
    local names, idByName, priceByName = {}, {}, {}
    for _, v in ipairs(list) do
        local price = v.cost or v.cashCost or 0
        local label = string.format("%s ($%s)", v.name, tostring(price))
        table.insert(names, label)
        idByName[label] = v.id
        priceByName[label] = price
    end
    return names, idByName, priceByName
end
local bedNames, bedIdByName, bedPriceByName = buildShopEntries(BedData.List)
local tableNames, tableIdByName, tablePriceByName = buildShopEntries(SellTableData.List)
local totemNames, totemIdByName, totemPriceByName = buildShopEntries(TotemData.List)
local decorNames, decorIdByName, decorPriceByName = buildShopEntries(DecorationData.List)
local gearNames, gearIdByName, gearPriceByName = buildShopEntries(GearData.List)
local crateNames, crateIdByName, cratePriceByName = buildShopEntries(CrateData.List)
local placeShopNames, placeShopLabelByKey = {}, {}
local function addPlaceShopEntries(kind, names, ids)
    for _, name in ipairs(names) do
        local displayKind = kind == "SellTable" and "Sell Table" or kind
        local label = displayKind .. " | " .. name
        local itemId = ids[name]
        table.insert(placeShopNames, label)
        placeShopLabelByKey[kind .. ":" .. tostring(itemId)] = label
    end
end
addPlaceShopEntries("Bed", bedNames, bedIdByName)
addPlaceShopEntries("SellTable", tableNames, tableIdByName)
addPlaceShopEntries("Totem", totemNames, totemIdByName)
addPlaceShopEntries("Decoration", decorNames, decorIdByName)
addPlaceShopEntries("Crate", crateNames, crateIdByName)
local trashShopNames, trashShopLabelByKey = {}, {}
local function addTrashShopEntries(kind, names, ids)
    for _, name in ipairs(names) do
        local displayKind = kind == "SellTable" and "Sell Table" or kind
        local label = displayKind .. " | " .. name
        local itemId = ids[name]
        table.insert(trashShopNames, label)
        trashShopLabelByKey[kind .. ":" .. tostring(itemId)] = label
    end
end
addTrashShopEntries("Bed", bedNames, bedIdByName)
addTrashShopEntries("SellTable", tableNames, tableIdByName)
addTrashShopEntries("Decoration", decorNames, decorIdByName)
addTrashShopEntries("Gear", gearNames, gearIdByName)
addTrashShopEntries("Crate", crateNames, crateIdByName)
local sprinklerList = {}
for _, v in ipairs(DecorationData.List) do
    if string.find(v.name, "Sprinkler") then
        table.insert(sprinklerList, v)
    end
end
local sprinklerNames, sprinklerIdByName, sprinklerPriceByName = buildShopEntries(sprinklerList)
local wateringCanList = {}
for _, v in ipairs(GearData.List) do
    if string.find(v.name, "Watering Can") then
        table.insert(wateringCanList, v)
    end
end
local wateringCanNames, wateringCanIdByName, wateringCanPriceByName = buildShopEntries(wateringCanList)
local playtimeMinutes = {}
local playtimeCfg = ReplicatedStorage:FindFirstChild("PlaytimeRewardsConfig")
if playtimeCfg then
    for _, c in ipairs(playtimeCfg:GetChildren()) do
        local m = c:GetAttribute("Minutes") or c:GetAttribute("minutes") or tonumber(c.Name)
        if m then
            table.insert(playtimeMinutes, m)
        end
    end
    table.sort(playtimeMinutes)
end
local function ownsModel(model)
    return model and model:GetAttribute("OwnerUserId") == LocalPlayer.UserId
end
local function myPlot()
    local plots = workspace:FindFirstChild("Plots")
    local id = LocalPlayer:GetAttribute("PlotId")
    return plots and id and plots:FindFirstChild("Plot" .. tostring(id))
end
local function ownedToolsOfKind(kind)
    local result = {}
    local character = LocalPlayer.Character
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("ToolKind") == kind then
                table.insert(result, child)
            end
        end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("ToolKind") == kind then
                table.insert(result, child)
            end
        end
    end
    return result
end
local function equipTool(tool)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:EquipTool(tool)
    end
end
local function ownedBedSlots()
    local empty, growing, ripe = {}, {}, {}
    for _, slot in ipairs(CollectionService:GetTagged("GardenBedSlot")) do
        if slot:IsDescendantOf(workspace) and ownsModel(slot.Parent) then
            local seedId = slot:GetAttribute("SeedId") or 0
            if seedId == 0 then
                table.insert(empty, slot)
            elseif slot:GetAttribute("Ripe") == true then
                table.insert(ripe, slot)
            else
                table.insert(growing, slot)
            end
        end
    end
    return empty, growing, ripe
end
local function emptyTableSlots()
    local result = {}
    for _, slot in ipairs(CollectionService:GetTagged("SellTableSlot")) do
        if slot:IsDescendantOf(workspace) and ownsModel(slot.Parent) and (slot:GetAttribute("CropId") or 0) == 0 then
            table.insert(result, slot)
        end
    end
    return result
end
local organizeBase
local organizingBase = false
local farmRevision = 0
local growRevision = 0
local placingOwnedItem = false
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = "https://discord.gg/K7Qxnxkk46 | Grow it RNG",
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false,
    Size = UDim2.fromOffset(940, 720),
})
local Tabs = {
    Main = Window:AddTab("Main Tab", "sprout"),
    Shop = Window:AddTab("Shop", "store"),
    Player = Window:AddTab("Player", "user"),
    Settings = Window:AddTab("Settings", "settings"),
}
local DISCORD_INVITE = "https://discord.gg/K7Qxnxkk46"
local function AddDiscordButton(Tab, addOrganize)
    local DiscordBox = Tab:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordBox:AddButton({
        Text = "Join Discord For Dupe",
        Func = function()
            setclipboard(DISCORD_INVITE)
            Library:Notify("Copied Discord invite to clipboard")
        end,
    })
    if addOrganize then
        DiscordBox:AddButton("Organize Base", function()
            if organizeBase then task.spawn(organizeBase) end
        end)
    end
end
for name, Tab in Tabs do
    AddDiscordButton(Tab, name == "Main")
end
local Toggles = Library.Toggles
local Options = Library.Options
local function selectedList(value, map)
    local out = {}
    for name in pairs(value) do
        local key = map[name]
        if key ~= nil then
            table.insert(out, key)
        end
    end
    return out
end
local PlantBox = Tabs.Main:AddLeftGroupbox("Auto Plant", "shovel")
PlantBox:AddToggle("AutoPlant", { Text = "Auto Plant Seeds", Default = false })
PlantBox:AddSlider("PlantInterval", { Text = "Plant interval", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
PlantBox:AddDropdown("PlantSeedLogic", {
    Values = { "Highest Weight", "Highest Tier", "Closest to Target Weight", "Lowest Weight", "Lowest Tier", "Random", "Inventory Order" },
    Default = 1,
    Text = "Auto Plant Seed Logic",
})
PlantBox:AddDropdown("PlantSeeds", {
    Values = seedNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Seeds allowed (none = all)",
})
PlantBox:AddInput("PlantMinWeight", { Text = "Minimum seed weight (g, 0 = off)", Default = "0", Numeric = true, Finished = true })
PlantBox:AddInput("PlantMaxWeight", { Text = "Maximum seed weight (g, 0 = off)", Default = "0", Numeric = true, Finished = true })
PlantBox:AddInput("PlantTargetWeight", { Text = "Target seed weight (g)", Default = "5", Numeric = true, Finished = true })
PlantBox:AddDivider()
PlantBox:AddToggle("AutoPlaceShopItems", { Text = "Auto Place Shop Items", Default = false })
PlantBox:AddDropdown("PlaceShopItems", {
    Values = placeShopNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Shop items to place",
})
PlantBox:AddSlider("PlaceShopInterval", { Text = "Shop item place interval", Default = 1, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
local BuyBox = Tabs.Main:AddLeftGroupbox("Auto Buy Seeds", "shopping-cart")
BuyBox:AddToggle("AutoBuySeeds", { Text = "Auto Buy Seeds", Default = false })
BuyBox:AddDropdown("BuySeeds", {
    Values = seedNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Seeds to buy",
})
BuyBox:AddSlider("BuyAmount", { Text = "Buys per cycle", Default = 6, Min = 1, Max = 50, Rounding = 0 })
BuyBox:AddSlider("BuyInterval", { Text = "Buy interval", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
local GrowBox = Tabs.Main:AddLeftGroupbox("Grow & Harvest", "sun")
GrowBox:AddToggle("AutoGrow", { Text = "Auto Grow Rush", Default = false })
GrowBox:AddSlider("GrowClicks", { Text = "Rush taps per crop", Default = 10, Min = 1, Max = 40, Rounding = 0 })
GrowBox:AddSlider("GrowTapDelay", { Text = "Rush tap delay", Default = 0.05, Min = 0.03, Max = 0.2, Rounding = 2, Suffix = "s" })
GrowBox:AddSlider("GrowInterval", { Text = "Grow rush interval", Default = 0.3, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
GrowBox:AddDivider()
GrowBox:AddToggle("AutoHarvest", { Text = "Auto Harvest", Default = false })
GrowBox:AddSlider("HarvestInterval", { Text = "Harvest interval", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
local UpgradeBox = Tabs.Main:AddLeftGroupbox("Expansion & Upgrades", "trending-up")
UpgradeBox:AddToggle("AutoExpand", { Text = "Auto Expansion", Default = false })
UpgradeBox:AddSlider("ExpandInterval", { Text = "Expansion interval", Default = 1, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
UpgradeBox:AddDivider()
UpgradeBox:AddToggle("AutoUpgrade", { Text = "Auto Farm Upgrades", Default = false })
UpgradeBox:AddDropdown("FarmUpgrades", {
    Values = { "Grow", "Eat" }, Default = {}, Multi = true, AllowNull = true,
    Text = "Farm upgrades to buy",
})
UpgradeBox:AddSlider("UpgradeInterval", { Text = "Upgrade interval", Default = 1, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
local SellBox = Tabs.Main:AddRightGroupbox("Selling", "coins")
SellBox:AddToggle("AutoDeposit", { Text = "Auto Place Seeds on Table", Default = false })
SellBox:AddSlider("DepositInterval", { Text = "Place interval", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
SellBox:AddDivider()
SellBox:AddToggle("AutoAccept", { Text = "Auto Accept Customer Offer", Default = false })
SellBox:AddInput("MinPrice", { Text = "Minimum offer price", Default = "0", Numeric = true, Finished = true })
SellBox:AddToggle("DeclineBelow", { Text = "Decline Offers Below Minimum", Default = false })
SellBox:AddDivider()
SellBox:AddToggle("AutoRush", { Text = "Auto Rush Customer", Default = false })
SellBox:AddSlider("RushInterval", { Text = "Rush interval", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
local PetBox = Tabs.Main:AddRightGroupbox("Wild Pets", "paw-print")
PetBox:AddToggle("AutoCatch", { Text = "Auto Catch Wild Pets", Default = false })
PetBox:AddDropdown("CatchPets", {
    Values = petNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Pets to catch (none = all)",
})
PetBox:AddInput("MaxCatchPrice", { Text = "Max catch price (0 = any)", Default = "0", Numeric = true, Finished = true })
PetBox:AddSlider("CatchInterval", { Text = "Catch interval", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
local StealBox = Tabs.Main:AddRightGroupbox("Auto Steal", "hand")
StealBox:AddToggle("AutoSteal", { Text = "Auto Steal Crops", Default = false })
StealBox:AddToggle("StealTables", { Text = "Steal From Sell Tables", Default = true })
StealBox:AddToggle("StealBeds", { Text = "Steal Ripe Beds", Default = true })
StealBox:AddSlider("StealInterval", { Text = "Steal interval", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
local RewardBox = Tabs.Main:AddRightGroupbox("Rewards", "gift")
RewardBox:AddToggle("AutoQuests", { Text = "Auto Claim Quests", Default = false })
RewardBox:AddSlider("QuestInterval", { Text = "Quest claim interval", Default = 2, Min = 0.5, Max = 15, Rounding = 1, Suffix = "s" })
RewardBox:AddDivider()
RewardBox:AddToggle("AutoPlaytime", { Text = "Auto Claim Playtime Rewards", Default = false })
RewardBox:AddSlider("PlaytimeInterval", { Text = "Playtime claim interval", Default = 5, Min = 1, Max = 30, Rounding = 0, Suffix = "s" })
local RebirthBox = Tabs.Main:AddRightGroupbox("Rebirth", "repeat")
RebirthBox:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
RebirthBox:AddToggle("AutoRebirthUpgrades", { Text = "Auto Buy Rebirth Upgrades", Default = false })
RebirthBox:AddDropdown("RebirthUpgrades", {
    Values = rebirthUpgradeNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Rebirth upgrades to buy",
})
RebirthBox:AddToggle("AutoRebirthItems", { Text = "Auto Buy Rebirth Items", Default = false })
RebirthBox:AddDropdown("RebirthItems", {
    Values = rebirthItemNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Rebirth items to buy",
})
RebirthBox:AddSlider("RebirthInterval", { Text = "Rebirth interval", Default = 1, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
local ShopBox = Tabs.Shop:AddLeftGroupbox("Auto Buy Shop", "shopping-bag")
ShopBox:AddToggle("AutoBuyShop", { Text = "Auto Buy Shop", Default = false })
ShopBox:AddSlider("ShopBuyAmount", { Text = "Buys per cycle", Default = 5, Min = 1, Max = 50, Rounding = 0 })
ShopBox:AddSlider("ShopInterval", { Text = "Shop interval", Default = 1, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
ShopBox:AddInput("ShopKeepCash", { Text = "Keep cash reserve", Default = "0", Numeric = true, Finished = true })
local StructureBox = Tabs.Shop:AddLeftGroupbox("Structures", "layout-grid")
StructureBox:AddDropdown("BuyBeds", {
    Values = bedNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Beds to buy",
})
StructureBox:AddDropdown("BuySellTables", {
    Values = tableNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Sell tables to buy",
})
StructureBox:AddDropdown("BuyTotems", {
    Values = totemNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Totems to buy",
})
local CosmeticBox = Tabs.Shop:AddRightGroupbox("Gear & Decorations", "swords")
CosmeticBox:AddDropdown("BuyGear", {
    Values = gearNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Gear to buy",
})
CosmeticBox:AddDropdown("BuyDecorations", {
    Values = decorNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Decorations to buy",
})
local SprinklerBox = Tabs.Shop:AddLeftGroupbox("Sprinklers", "droplets")
SprinklerBox:AddToggle("AutoBuySprinklers", { Text = "Auto Buy Sprinklers", Default = false })
SprinklerBox:AddDropdown("BuySprinklers", {
    Values = sprinklerNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Sprinklers to buy",
})
SprinklerBox:AddSlider("SprinklerAmount", { Text = "Buys per cycle", Default = 1, Min = 1, Max = 20, Rounding = 0 })
SprinklerBox:AddSlider("SprinklerInterval", { Text = "Sprinkler interval", Default = 1, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
local WateringCanBox = Tabs.Shop:AddLeftGroupbox("Watering Cans", "droplet")
WateringCanBox:AddToggle("AutoBuyWateringCans", { Text = "Auto Buy Watering Cans", Default = false })
WateringCanBox:AddDropdown("BuyWateringCans", {
    Values = wateringCanNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Watering cans to buy",
})
WateringCanBox:AddSlider("WateringCanAmount", { Text = "Buys per cycle", Default = 1, Min = 1, Max = 20, Rounding = 0 })
WateringCanBox:AddSlider("WateringCanInterval", { Text = "Watering can interval", Default = 1, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
local CrateBox = Tabs.Shop:AddRightGroupbox("Crates", "package")
CrateBox:AddToggle("AutoBuyCrates", { Text = "Auto Buy Crates", Default = false })
CrateBox:AddDropdown("BuyCrates", {
    Values = crateNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Crates to open",
})
CrateBox:AddSlider("CrateInterval", { Text = "Crate interval", Default = 2, Min = 0.5, Max = 15, Rounding = 1, Suffix = "s" })
local TrashBox = Tabs.Main:AddRightGroupbox("Auto Trash", "trash-2")
TrashBox:AddToggle("AutoTrash", { Text = "Auto Trash Items", Default = false })
TrashBox:AddDropdown("TrashSeeds", {
    Values = seedNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Seeds to trash",
})
TrashBox:AddDropdown("TrashTotems", {
    Values = totemNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Totems to trash",
})
TrashBox:AddDropdown("TrashShopItems", {
    Values = trashShopNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Shop items to trash",
})
TrashBox:AddInput("KeepWeight", { Text = "Keep at or above weight (g, 0 = off)", Default = "0", Numeric = true, Finished = true })
TrashBox:AddSlider("TrashInterval", { Text = "Trash interval", Default = 0.5, Min = 0.1, Max = 5, Rounding = 1, Suffix = "s" })
local UseBox = Tabs.Shop:AddRightGroupbox("Use Items", "package-open")
UseBox:AddToggle("AutoPlaceTotems", { Text = "Auto Place Totems", Default = false })
UseBox:AddDropdown("PlaceTotems", {
    Values = totemNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Totems to place (none = all)",
})
for _, totem in ipairs(TotemData.List) do
    UseBox:AddInput("TotemPlaceLimit" .. tostring(totem.id), {
        Text = totem.name .. " place limit (0 = unlimited)", Default = "1", Numeric = true, Finished = true,
    })
end
UseBox:AddSlider("TotemPlaceInterval", { Text = "Totem place interval", Default = 1, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
UseBox:AddDivider()
UseBox:AddToggle("AutoUseSprinklers", { Text = "Auto Use Sprinklers", Default = false })
UseBox:AddDropdown("UseSprinklers", {
    Values = sprinklerNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Sprinklers to use (none = all)",
})
UseBox:AddSlider("UseSprinklerInterval", { Text = "Sprinkler use interval", Default = 1, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
UseBox:AddDivider()
UseBox:AddToggle("AutoUseWateringCans", { Text = "Auto Use Watering Cans", Default = false })
UseBox:AddDropdown("UseWateringCans", {
    Values = wateringCanNames, Default = {}, Multi = true, Searchable = true, AllowNull = true,
    Text = "Watering cans to use (none = all)",
})
UseBox:AddSlider("UseWateringCanInterval", { Text = "Watering can use interval", Default = 0.5, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
local MovementBox = Tabs.Player:AddLeftGroupbox("Movement")
MovementBox:AddToggle("WalkSpeedEnabled", { Text = "Walk Speed", Default = false })
MovementBox:AddSlider("WalkSpeed", { Text = "Walk speed", Default = 16, Min = 16, Max = 300, Rounding = 0 })
MovementBox:AddToggle("Fly", { Text = "Fly", Default = false })
MovementBox:AddSlider("FlySpeed", { Text = "Fly speed", Default = 60, Min = 10, Max = 300, Rounding = 0 })
MovementBox:AddToggle("Noclip", { Text = "Noclip", Default = false })
MovementBox:AddToggle("InfiniteJump", { Text = "Infinite Jump", Default = false })
local ESPBox = Tabs.Player:AddRightGroupbox("ESP")
ESPBox:AddToggle("SeedSizeESP", { Text = "Seed Size ESP", Default = false })
ESPBox:AddToggle("PetESP", { Text = "Pet ESP", Default = false })
local CodesBox = Tabs.Player:AddRightGroupbox("Codes", "ticket")
CodesBox:AddInput("CodeInput", { Text = "Code", Default = "", Placeholder = "ENTER CODE", Finished = false })
CodesBox:AddButton("Redeem Code", function()
    local code = Options.CodeInput.Value
    if type(code) ~= "string" or #code:gsub("%s+", "") == 0 then
        Library:Notify("Enter a code first")
        return
    end
    local ok, result = pcall(function() return RedeemCode:InvokeServer(code) end)
    if ok and type(result) == "table" and result.ok then
        Library:Notify("Redeemed: " .. code)
    else
        Library:Notify("Invalid code: " .. code)
    end
end)
local shopCategories = {
    { kind = "Bed", option = "BuyBeds", ids = bedIdByName, prices = bedPriceByName },
    { kind = "SellTable", option = "BuySellTables", ids = tableIdByName, prices = tablePriceByName },
    { kind = "Totem", option = "BuyTotems", ids = totemIdByName, prices = totemPriceByName },
    { kind = "Gear", option = "BuyGear", ids = gearIdByName, prices = gearPriceByName },
    { kind = "Decoration", option = "BuyDecorations", ids = decorIdByName, prices = decorPriceByName },
}
local function rootPart()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end
local flyVelocity
local flyUp = false
local flyDown = false
local collisionStates = {}
local walkSpeedOriginals = {}
local seedEspObjects = {}
local petEspObjects = {}
local playerConnections = {}
local function humanoid()
    local character = LocalPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end
local function restoreWalkSpeed()
    for hum, speed in pairs(walkSpeedOriginals) do
        if hum.Parent then
            hum.WalkSpeed = speed
        end
        walkSpeedOriginals[hum] = nil
    end
end
local function restoreNoclip()
    for part, canCollide in pairs(collisionStates) do
        if part.Parent then
            part.CanCollide = canCollide
        end
        collisionStates[part] = nil
    end
end
local function stopFlying()
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    flyUp = false
    flyDown = false
end
local function makeEspLabel(adornee, text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "_TempoESP"
    billboard.Adornee = adornee
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    billboard.Size = UDim2.fromOffset(220, 32)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = adornee
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 14
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Parent = billboard
    return billboard, label
end
local function clearSeedEsp()
    for slot, entry in pairs(seedEspObjects) do
        if entry.gui then entry.gui:Destroy() end
        seedEspObjects[slot] = nil
    end
end
local function clearPetEsp()
    for pet, entry in pairs(petEspObjects) do
        if entry.gui then entry.gui:Destroy() end
        if entry.highlight then entry.highlight:Destroy() end
        petEspObjects[pet] = nil
    end
end
local function updateSeedEsp()
    local seen = {}
    for _, slot in ipairs(CollectionService:GetTagged("GardenBedSlot")) do
        local seedId = slot:GetAttribute("SeedId") or 0
        if slot:IsDescendantOf(workspace) and seedId ~= 0 and slot:IsA("BasePart") then
            seen[slot] = true
            local entry = seedEspObjects[slot]
            if not entry or not entry.gui.Parent then
                if entry and entry.gui then entry.gui:Destroy() end
                local gui, label = makeEspLabel(slot, "", Color3.fromRGB(95, 255, 150))
                entry = { gui = gui, label = label }
                seedEspObjects[slot] = entry
            end
            local weight = tonumber(slot:GetAttribute("SeedWeight")) or 0
            entry.label.Text = string.format("%s | %.1fg", seedDisplayNameById[seedId] or "Seed", weight)
        end
    end
    for slot, entry in pairs(seedEspObjects) do
        if not seen[slot] then
            if entry.gui then entry.gui:Destroy() end
            seedEspObjects[slot] = nil
        end
    end
end
local function updatePetEsp()
    local runtime = workspace:FindFirstChild("PetsRuntime")
    local seen = {}
    if runtime then
        for _, pet in ipairs(runtime:GetChildren()) do
            local part = pet:IsA("Model") and (pet.PrimaryPart or pet:FindFirstChildWhichIsA("BasePart", true))
            if part then
                seen[pet] = true
                local entry = petEspObjects[pet]
                if not entry or not entry.gui.Parent then
                    if entry then
                        if entry.gui then entry.gui:Destroy() end
                        if entry.highlight then entry.highlight:Destroy() end
                    end
                    local gui, label = makeEspLabel(part, pet.Name, Color3.fromRGB(255, 190, 80))
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "_TempoPetESP"
                    highlight.Adornee = pet
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Color3.fromRGB(255, 190, 80)
                    highlight.FillTransparency = 0.8
                    highlight.OutlineColor = Color3.fromRGB(255, 235, 170)
                    highlight.OutlineTransparency = 0
                    highlight.Parent = pet
                    entry = { gui = gui, label = label, highlight = highlight }
                    petEspObjects[pet] = entry
                end
                entry.label.Text = pet.Name
            end
        end
    end
    for pet, entry in pairs(petEspObjects) do
        if not seen[pet] then
            if entry.gui then entry.gui:Destroy() end
            if entry.highlight then entry.highlight:Destroy() end
            petEspObjects[pet] = nil
        end
    end
end
table.insert(playerConnections, UserInputService.InputBegan:Connect(function(input, processed)
    if processed or Library.Unloaded or not Toggles.Fly.Value then return end
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        flyDown = true
    end
end))
table.insert(playerConnections, UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        flyDown = false
    end
end))
table.insert(playerConnections, UserInputService.JumpRequest:Connect(function()
    if Library.Unloaded or not Toggles.InfiniteJump.Value then return end
    local hum = humanoid()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end))
table.insert(playerConnections, RunService.Heartbeat:Connect(function()
    if Library.Unloaded then return end
    local character = LocalPlayer.Character
    local hum = humanoid()
    local root = rootPart()
    if Toggles.WalkSpeedEnabled.Value and hum then
        if walkSpeedOriginals[hum] == nil then walkSpeedOriginals[hum] = hum.WalkSpeed end
        hum.WalkSpeed = Options.WalkSpeed.Value
    end
    if Toggles.Noclip.Value and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if collisionStates[part] == nil then collisionStates[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end
    if Toggles.Fly.Value and root and hum then
        if not flyVelocity or not flyVelocity.Parent then
            if flyVelocity then flyVelocity:Destroy() end
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.Name = "_TempoFly"
            flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyVelocity.P = 1250
            flyVelocity.Parent = root
        end
        local vertical = (flyUp and 1 or 0) - (flyDown and 1 or 0)
        flyVelocity.Velocity = hum.MoveDirection * Options.FlySpeed.Value + Vector3.new(0, vertical * Options.FlySpeed.Value, 0)
    elseif flyVelocity then
        stopFlying()
    end
end))
Toggles.WalkSpeedEnabled:OnChanged(function()
    if not Toggles.WalkSpeedEnabled.Value then restoreWalkSpeed() end
end)
Toggles.Noclip:OnChanged(function()
    if not Toggles.Noclip.Value then restoreNoclip() end
end)
Toggles.Fly:OnChanged(function()
    if not Toggles.Fly.Value then stopFlying() end
end)
Toggles.SeedSizeESP:OnChanged(function()
    if not Toggles.SeedSizeESP.Value then clearSeedEsp() end
end)
Toggles.PetESP:OnChanged(function()
    if not Toggles.PetESP.Value then clearPetEsp() end
end)
task.spawn(function()
    while task.wait(0.25) do
        if Library.Unloaded then break end
        if Toggles.SeedSizeESP.Value then updateSeedEsp() end
        if Toggles.PetESP.Value then updatePetEsp() end
    end
end)
local function selectionContainsItem(selection, itemId, labelsById)
    if next(selection) == nil then return true end
    local label = labelsById[itemId]
    return label ~= nil and selection[label] == true
end
local function labelsById(ids)
    local result = {}
    for label, id in pairs(ids) do
        result[id] = label
    end
    return result
end
local totemLabelById = labelsById(totemIdByName)
local sprinklerLabelById = labelsById(sprinklerIdByName)
local wateringCanLabelById = labelsById(wateringCanIdByName)
local activeWateringCan
Toggles.AutoUseWateringCans:OnChanged(function()
    if not Toggles.AutoUseWateringCans.Value and activeWateringCan then
        pcall(function() activeWateringCan:Deactivate() end)
        activeWateringCan = nil
    end
end)
local function itemModel(tool)
    local itemId = tool:GetAttribute("ItemId")
    local kind = tool:GetAttribute("ToolKind")
    if kind == "Bed" then
        local data = BedData.getById(itemId)
        local folder = ReplicatedStorage.Models:FindFirstChild("Beds")
        return data and folder and folder:FindFirstChild(data.modelName or "")
    end
    if kind == "SellTable" then
        local data = SellTableData.getById(itemId)
        local folder = ReplicatedStorage.Models:FindFirstChild("SellTables")
        return data and folder and folder:FindFirstChild(data.modelName or "")
    end
    if kind == "Totem" then
        local data = TotemData.getById(itemId)
        local folder = ReplicatedStorage.Models:FindFirstChild("Totems")
        return data and folder and folder:FindFirstChild(data.modelName or "")
    end
    if kind == "Crate" then
        local data = CrateData.getById(itemId)
        local folder = ReplicatedStorage.Models:FindFirstChild("Crates")
        return data and folder and folder:FindFirstChild(data.modelName or "")
    end
    local data = DecorationData.getById(itemId)
    local folder = ReplicatedStorage.Models:FindFirstChild("Decorations")
    return data and folder and folder:FindFirstChild(data.modelName or "")
end
local function placementCandidates(tool)
    local plot = myPlot()
    local floor = plot and plot:FindFirstChild("InteriorFloor")
    local model = itemModel(tool)
    if not floor or not model then return {} end
    local boxCFrame, boxSize = model:GetBoundingBox()
    local pivotOffset = model:GetPivot().Position.Y - (boxCFrame.Position.Y - boxSize.Y / 2)
    local y = floor.Position.Y + floor.Size.Y / 2 + pivotOffset
    local candidates = {}
    local seen = {}
    local nature = plot:FindFirstChild("Nature")
    local halfX = boxSize.X / 2 + 0.5
    local halfZ = boxSize.Z / 2 + 0.5
    local function locked(x, z)
        if not nature then return false end
        for _, region in ipairs(nature:GetChildren()) do
            if region:GetAttribute("Price") ~= nil and not region:GetAttribute("Unlocked") then
                local centerX = region:GetAttribute("CenterX")
                local centerZ = region:GetAttribute("CenterZ")
                local regionHalfX = region:GetAttribute("HalfX") or 15
                local regionHalfZ = region:GetAttribute("HalfZ") or 15
                if centerX and centerZ and math.abs(x - centerX) < halfX + regionHalfX and math.abs(z - centerZ) < halfZ + regionHalfZ then
                    return true
                end
            end
        end
        return false
    end
    local function occupied(x, z)
        for _, tag in ipairs({ "GardenBed", "SellTable", "Totem", "PlacedCrate" }) do
            for _, placed in ipairs(CollectionService:GetTagged(tag)) do
                if placed:IsA("Model") and placed:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                    local placedCFrame, placedSize = placed:GetBoundingBox()
                    if math.abs(x - placedCFrame.X) < halfX + placedSize.X / 2 - 0.3 and math.abs(z - placedCFrame.Z) < halfZ + placedSize.Z / 2 - 0.3 then
                        return true
                    end
                end
            end
        end
        return false
    end
    local function add(x, z)
        local key = string.format("%.1f:%.1f", x, z)
        if not seen[key] and not locked(x, z) and not occupied(x, z) and math.abs(x - floor.Position.X) <= floor.Size.X / 2 - halfX and math.abs(z - floor.Position.Z) <= floor.Size.Z / 2 - halfZ then
            seen[key] = true
            table.insert(candidates, CFrame.new(x, y, z))
        end
    end
    local kind = tool:GetAttribute("ToolKind")
    if kind == "Totem" or kind == "Decoration" then
        local _, growing, ripe = ownedBedSlots()
        for _, slot in ipairs(growing) do
            for _, offset in ipairs({ Vector3.new(5, 0, 0), Vector3.new(-5, 0, 0), Vector3.new(0, 0, 5), Vector3.new(0, 0, -5) }) do
                add(slot.Position.X + offset.X, slot.Position.Z + offset.Z)
            end
        end
        for _, slot in ipairs(ripe) do
            for _, offset in ipairs({ Vector3.new(5, 0, 0), Vector3.new(-5, 0, 0), Vector3.new(0, 0, 5), Vector3.new(0, 0, -5) }) do
                add(slot.Position.X + offset.X, slot.Position.Z + offset.Z)
            end
        end
    end
    local footprint = math.max(boxSize.X, boxSize.Z)
    local margin = math.ceil(footprint / 2) + 1
    local step = math.max(5, math.ceil(footprint + 1))
    for x = -math.floor(floor.Size.X / 2) + margin, math.floor(floor.Size.X / 2) - margin, step do
        for z = -math.floor(floor.Size.Z / 2) + margin, math.floor(floor.Size.Z / 2) - margin, step do
            add(floor.Position.X + x, floor.Position.Z + z)
        end
    end
    local root = rootPart()
    if root then
        table.sort(candidates, function(a, b)
            return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
        end)
    end
    return candidates
end
local function placeOwnedTool(tool, remote, shouldContinue)
    if placingOwnedItem then return false end
    placingOwnedItem = true
    equipTool(tool)
    task.wait(0.1)
    for _, cframe in ipairs(placementCandidates(tool)) do
        if Library.Unloaded or not shouldContinue() or not tool.Parent then break end
        remote:FireServer(tool, cframe)
        task.wait(0.3)
        if not tool.Parent then
            placingOwnedItem = false
            return true
        end
    end
    placingOwnedItem = false
    return false
end
local placeRemoteByKind = {
    Bed = PlaceBed,
    SellTable = PlaceSellTable,
    Totem = PlaceTotem,
    Decoration = PlaceDecoration,
    Crate = PlaceCrate,
}
local function shouldTrash(tool)
    local kind = tool:GetAttribute("ToolKind")
    local itemId = tool:GetAttribute("ItemId")
    if kind == "Seed" then
        local seedLabel = seedNameById[itemId]
        if not seedLabel or not Options.TrashSeeds.Value[seedLabel] then return false end
        local keepWeight = tonumber(Options.KeepWeight.Value) or 0
        if keepWeight > 0 and (tonumber(tool:GetAttribute("SeedWeight")) or 0) >= keepWeight then return false end
        return true
    end
    if kind == "Totem" then
        local totemLabel = totemLabelById[itemId]
        return totemLabel ~= nil and Options.TrashTotems.Value[totemLabel] == true
    end
    local shopLabel = trashShopLabelByKey[kind .. ":" .. tostring(itemId)]
    return shopLabel ~= nil and Options.TrashShopItems.Value[shopLabel] == true
end
local function canPlaceTotem(itemId)
    local option = Options["TotemPlaceLimit" .. tostring(itemId)]
    local limit = option and tonumber(option.Value) or 0
    if limit <= 0 then return true end
    local placed = 0
    for _, totem in ipairs(CollectionService:GetTagged("Totem")) do
        if totem:GetAttribute("OwnerUserId") == LocalPlayer.UserId and totem:GetAttribute("ItemId") == itemId then
            placed = placed + 1
        end
    end
    return placed < limit
end
local function ownTrashPrompt()
    local plot = myPlot()
    local trashCan = plot and plot:FindFirstChild("TrashCan")
    return trashCan and trashCan:FindFirstChild("TrashPrompt", true)
end
local function safeFarmLoop(slots, maxDist, shouldContinueFunc, getInteractableFunc, actionFunc)
    local root = rootPart()
    if not root then return end
    local originalCFrame = root.CFrame
    local moved = false
    for _, slot in ipairs(slots) do
        if Library.Unloaded or not shouldContinueFunc() then break end
        local target = getInteractableFunc(slot)
        if target then
            if (root.Position - slot.Position).Magnitude > maxDist then
                root.CFrame = slot.CFrame + Vector3.new(0, 3, 0)
                moved = true
                task.wait(0.15)
            end
            if Library.Unloaded or not shouldContinueFunc() then break end
            actionFunc(slot, target)
        end
    end
    if moved then
        root.CFrame = originalCFrame
    end
end
local function structureModel(tool)
    local kind = tool:GetAttribute("ToolKind")
    local itemId = tool:GetAttribute("ItemId")
    if kind == "Bed" then
        local data = BedData.getById(itemId)
        return data and ReplicatedStorage.Models.Beds:FindFirstChild(data.modelName or "")
    end
    if kind == "SellTable" then
        local data = SellTableData.getById(itemId)
        return data and ReplicatedStorage.Models.SellTables:FindFirstChild(data.modelName or "")
    end
end
local function structureCFrame(tool, x, z, floor)
    local model = structureModel(tool)
    if not model then return nil end
    local boxCFrame, boxSize = model:GetBoundingBox()
    local pivotOffset = model:GetPivot().Position.Y - (boxCFrame.Position.Y - boxSize.Y / 2)
    return CFrame.new(x, floor.Position.Y + floor.Size.Y / 2 + pivotOffset, z), boxSize
end
local function touchesLockedExpansion(plot, cframe, size)
    local nature = plot:FindFirstChild("Nature")
    if not nature then return false end
    local halfX = size.X / 2 + 0.5
    local halfZ = size.Z / 2 + 0.5
    for _, region in ipairs(nature:GetChildren()) do
        if region:GetAttribute("Price") ~= nil and not region:GetAttribute("Unlocked") then
            local centerX = region:GetAttribute("CenterX")
            local centerZ = region:GetAttribute("CenterZ")
            local regionHalfX = region:GetAttribute("HalfX") or 15
            local regionHalfZ = region:GetAttribute("HalfZ") or 15
            if centerX and centerZ and math.abs(cframe.X - centerX) < halfX + regionHalfX and math.abs(cframe.Z - centerZ) < halfZ + regionHalfZ then
                return true
            end
        end
    end
    return false
end
local function structureCandidates(tool, plot, floor)
    local candidates = {}
    local minX = floor.Position.X - floor.Size.X / 2 + 7
    local maxX = floor.Position.X + floor.Size.X / 2 - 7
    local minZ = floor.Position.Z - floor.Size.Z / 2 + 7
    local maxZ = floor.Position.Z + floor.Size.Z / 2 - 7
    for z = minZ, maxZ, 12 do
        for x = minX, maxX, 12 do
            local cframe, size = structureCFrame(tool, x, z, floor)
            if cframe and not touchesLockedExpansion(plot, cframe, size) then
                table.insert(candidates, cframe)
            end
        end
    end
    return candidates
end
organizeBase = function()
    if organizingBase or Library.Unloaded then return end
    organizingBase = true
    farmRevision = farmRevision + 1
    local plot = myPlot()
    local floor = plot and plot:FindFirstChild("InteriorFloor")
    local root = rootPart()
    if not plot or not floor or not root then
        organizingBase = false
        Library:Notify("Unable to find your plot")
        return
    end
    local originalCFrame = root.CFrame
    local inventoryBefore = {}
    for _, kind in ipairs({ "Bed", "SellTable" }) do
        for _, tool in ipairs(ownedToolsOfKind(kind)) do
            local key = kind .. ":" .. tostring(tool:GetAttribute("ItemId"))
            inventoryBefore[key] = (inventoryBefore[key] or 0) + 1
        end
    end
    local structures = {}
    for _, tag in ipairs({ "GardenBed", "SellTable" }) do
        for _, model in ipairs(CollectionService:GetTagged(tag)) do
            if model:IsA("Model") and model:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                table.insert(structures, model)
            end
        end
    end
    table.sort(structures, function(a, b)
        local aBed = CollectionService:HasTag(a, "GardenBed")
        local bBed = CollectionService:HasTag(b, "GardenBed")
        if aBed ~= bBed then return aBed end
        return (a:GetAttribute("ItemId") or 0) < (b:GetAttribute("ItemId") or 0)
    end)
    for _, model in ipairs(structures) do
        if Library.Unloaded then break end
        local prompt = model:FindFirstChild("PickupPrompt", true)
        local target = prompt and prompt.Parent
        if prompt and target and target:IsA("BasePart") then
            root = rootPart()
            if not root then break end
            root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.1)
            fireproximityprompt(prompt)
            local deadline = os.clock() + 2
            repeat task.wait(0.05) until not model.Parent or os.clock() >= deadline or Library.Unloaded
        end
    end
    task.wait(0.5)
    local tools = {}
    local inventoryAfter = {}
    for _, kind in ipairs({ "Bed", "SellTable" }) do
        for _, tool in ipairs(ownedToolsOfKind(kind)) do
            local key = kind .. ":" .. tostring(tool:GetAttribute("ItemId"))
            inventoryAfter[key] = (inventoryAfter[key] or 0) + 1
            if inventoryAfter[key] > (inventoryBefore[key] or 0) then
                table.insert(tools, tool)
            end
        end
    end
    table.sort(tools, function(a, b)
        local aBed = a:GetAttribute("ToolKind") == "Bed"
        local bBed = b:GetAttribute("ToolKind") == "Bed"
        if aBed ~= bBed then return aBed end
        return (a:GetAttribute("ItemId") or 0) < (b:GetAttribute("ItemId") or 0)
    end)
    local occupied = {}
    local placed = 0
    for _, tool in ipairs(tools) do
        if Library.Unloaded then break end
        local remote = tool:GetAttribute("ToolKind") == "Bed" and PlaceBed or PlaceSellTable
        equipTool(tool)
        for _, cframe in ipairs(structureCandidates(tool, plot, floor)) do
            if Library.Unloaded or not tool.Parent then break end
            local key = string.format("%.1f:%.1f", cframe.X, cframe.Z)
            if not occupied[key] then
                remote:FireServer(tool, cframe)
                task.wait(0.2)
                if not tool.Parent then
                    occupied[key] = true
                    placed = placed + 1
                    break
                end
            end
        end
    end
    root = rootPart()
    if root then root.CFrame = originalCFrame end
    organizingBase = false
    farmRevision = farmRevision + 1
    Library:Notify(string.format("Organized %d beds and tables", placed))
end
Toggles.AutoPlant:OnChanged(function()
    farmRevision = farmRevision + 1
end)
Toggles.AutoHarvest:OnChanged(function()
    farmRevision = farmRevision + 1
end)
Toggles.AutoGrow:OnChanged(function()
    growRevision = growRevision + 1
end)
local function plantSlot(slot, revision)
    if organizingBase or revision ~= farmRevision or not Toggles.AutoPlant.Value then return end
    local candidates = {}
    local selectedSeeds = Options.PlantSeeds.Value
    local minWeight = tonumber(Options.PlantMinWeight.Value) or 0
    local maxWeight = tonumber(Options.PlantMaxWeight.Value) or 0
    for _, tool in ipairs(ownedToolsOfKind("Seed")) do
        local itemId = tool:GetAttribute("ItemId")
        local weight = tonumber(tool:GetAttribute("SeedWeight")) or 0
        local allowed = next(selectedSeeds) == nil or selectedSeeds[seedNameById[itemId]] == true
        if allowed and (minWeight <= 0 or weight >= minWeight) and (maxWeight <= 0 or weight <= maxWeight) then
            table.insert(candidates, tool)
        end
    end
    if #candidates == 0 then return end
    local logic = Options.PlantSeedLogic.Value
    if logic == "Random" then
        local randomIndex = math.random(1, #candidates)
        candidates[1], candidates[randomIndex] = candidates[randomIndex], candidates[1]
    elseif logic ~= "Inventory Order" then
        local targetWeight = tonumber(Options.PlantTargetWeight.Value) or 0
        table.sort(candidates, function(a, b)
            local aWeight = tonumber(a:GetAttribute("SeedWeight")) or 0
            local bWeight = tonumber(b:GetAttribute("SeedWeight")) or 0
            local aTier = seedTierById[a:GetAttribute("ItemId")] or 0
            local bTier = seedTierById[b:GetAttribute("ItemId")] or 0
            if logic == "Highest Tier" then
                return aTier == bTier and aWeight > bWeight or aTier > bTier
            elseif logic == "Lowest Tier" then
                return aTier == bTier and aWeight > bWeight or aTier < bTier
            elseif logic == "Lowest Weight" then
                return aWeight < bWeight
            elseif logic == "Closest to Target Weight" then
                return math.abs(aWeight - targetWeight) < math.abs(bWeight - targetWeight)
            end
            return aWeight > bWeight
        end)
    end
    local seed = candidates[1]
    if not seed then return end
    equipTool(seed)
    if organizingBase or revision ~= farmRevision or not Toggles.AutoPlant.Value then return end
    pcall(function() PlantSeed:InvokeServer(slot, seed) end)
end
task.spawn(function()
    local nextPlant = 0
    local nextHarvest = 0
    while task.wait(0.05) do
        if Library.Unloaded then break end
        if not organizingBase then
            local now = os.clock()
            local revision = farmRevision
            if Toggles.AutoHarvest.Value and now >= nextHarvest then
                nextHarvest = now + Options.HarvestInterval.Value
                local _, _, ripe = ownedBedSlots()
                safeFarmLoop(ripe, 6, function()
                    return not organizingBase and revision == farmRevision and Toggles.AutoHarvest.Value
                end, function(slot)
                    return slot:FindFirstChild("HarvestPrompt", true)
                end, function(slot, target)
                    if revision ~= farmRevision or not Toggles.AutoHarvest.Value then return end
                    pcall(function() fireproximityprompt(target) end)
                    task.wait(0.05)
                end)
            end
            if Toggles.AutoPlant.Value and now >= nextPlant then
                nextPlant = now + Options.PlantInterval.Value
                local empty, _, ripe = ownedBedSlots()
                if not Toggles.AutoHarvest.Value or #ripe == 0 then
                    for _, slot in ipairs(empty) do
                        if Library.Unloaded or organizingBase or revision ~= farmRevision or not Toggles.AutoPlant.Value then break end
                        plantSlot(slot, revision)
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.BuyInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoBuySeeds.Value then
            local ids = selectedList(Options.BuySeeds.Value, seedIdByName)
            if #ids > 0 then
                for i = 1, Options.BuyAmount.Value do
                    if Library.Unloaded or not Toggles.AutoBuySeeds.Value then break end
                    local id = ids[(i - 1) % #ids + 1]
                    pcall(function() BuySeedRequest:InvokeServer(id) end)
                end
            end
        end
    end
end)
task.spawn(function()
    local nextRush = 0
    while task.wait(0.05) do
        if Library.Unloaded then break end
        local now = os.clock()
        if not organizingBase and Toggles.AutoGrow.Value and now >= nextRush then
            nextRush = now + Options.GrowInterval.Value
            local revision = growRevision
            local _, growing = ownedBedSlots()
            safeFarmLoop(growing, 14, function()
                return not organizingBase and revision == growRevision and Toggles.AutoGrow.Value
            end, function(slot)
                return slot:FindFirstChild("SpeedupClick", true) or slot:FindFirstChildOfClass("ClickDetector", true)
            end, function(slot, target)
                for _ = 1, Options.GrowClicks.Value do
                    if Library.Unloaded or organizingBase or revision ~= growRevision or not Toggles.AutoGrow.Value then break end
                    if slot:GetAttribute("Ripe") == true or (slot:GetAttribute("SeedId") or 0) == 0 or not target.Parent then break end
                    pcall(function() fireclickdetector(target) end)
                    task.wait(Options.GrowTapDelay.Value)
                end
            end)
        end
    end
end)
task.spawn(function()
    while task.wait(Options.DepositInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoDeposit.Value then
            if #ownedToolsOfKind("Crop") > 0 then
                for _, slot in ipairs(emptyTableSlots()) do
                    if Library.Unloaded or not Toggles.AutoDeposit.Value then break end
                    local crop = ownedToolsOfKind("Crop")[1]
                    if not crop then break end
                    equipTool(crop)
                    DepositCrop:FireServer(slot, crop)
                    task.wait(0.1)
                end
            end
        end
    end
end)
local pendingOffers = {}
local function resolveOffer(customer, price)
    if not customer or not customer.Parent then return end
    local minPrice = tonumber(Options.MinPrice.Value) or 0
    if (price or 0) >= minPrice then
        pendingOffers[customer] = nil
        pcall(function() CustomerDecision:FireServer(customer, true) end)
    elseif Toggles.DeclineBelow.Value then
        pendingOffers[customer] = nil
        pcall(function() CustomerDecision:FireServer(customer, false) end)
    end
end
CustomerOffer.OnClientEvent:Connect(function(customer, _, price)
    if not customer then return end
    pendingOffers[customer] = price or 0
    if Toggles.AutoAccept.Value then
        resolveOffer(customer, price or 0)
    end
end)
CustomerOfferClear.OnClientEvent:Connect(function(customer)
    if customer then
        pendingOffers[customer] = nil
    else
        table.clear(pendingOffers)
    end
end)
task.spawn(function()
    while task.wait(0.1) do
        if Library.Unloaded then break end
        if Toggles.AutoAccept.Value then
            for customer, price in pairs(pendingOffers) do
                if customer.Parent then
                    resolveOffer(customer, price)
                else
                    pendingOffers[customer] = nil
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.RushInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoRush.Value then
            for _, prompt in ipairs(workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Name == "RushPrompt" then
                    pcall(function() fireproximityprompt(prompt) end)
                end
            end
        end
    end
end)
local function foreignStealSlots()
    local result = {}
    if Toggles.StealTables.Value then
        for _, slot in ipairs(CollectionService:GetTagged("SellTableSlot")) do
            if slot:IsDescendantOf(workspace) and (slot:GetAttribute("CropId") or 0) ~= 0 and not ownsModel(slot.Parent) then
                table.insert(result, slot)
            end
        end
    end
    if Toggles.StealBeds.Value then
        for _, slot in ipairs(CollectionService:GetTagged("GardenBedSlot")) do
            if slot:IsDescendantOf(workspace) and slot:GetAttribute("Ripe") == true and not ownsModel(slot.Parent) then
                table.insert(result, slot)
            end
        end
    end
    return result
end
task.spawn(function()
    while task.wait(0.05) do
        if Library.Unloaded then break end
        if not organizingBase and Toggles.AutoSteal.Value then
            safeFarmLoop(foreignStealSlots(), 8, function()
                return not organizingBase and Toggles.AutoSteal.Value
            end, function(slot)
                return slot
            end, function(slot)
                pcall(function() RequestSteal:FireServer(slot) end)
                task.wait(0.1)
            end)
        end
        task.wait(math.max(0, Options.StealInterval.Value - 0.05))
    end
end)
task.spawn(function()
    while task.wait(Options.ExpandInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoExpand.Value then
            local plot = myPlot()
            if plot then
                for _, prompt in ipairs(plot:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Name == "UnlockPrompt" then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.UpgradeInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoUpgrade.Value then
            for key in pairs(Options.FarmUpgrades.Value) do
                pcall(function() BuyUpgrade:FireServer(key) end)
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.CatchInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoCatch.Value then
            local runtime = workspace:FindFirstChild("PetsRuntime")
            local root = rootPart()
            if runtime and root then
                local wanted = Options.CatchPets.Value
                local hasFilter = next(wanted) ~= nil
                local maxPrice = tonumber(Options.MaxCatchPrice.Value) or 0
                local origin = root.CFrame
                local moved = false
                for _, pet in ipairs(runtime:GetChildren()) do
                    if Library.Unloaded or not Toggles.AutoCatch.Value then break end
                    if (not hasFilter or wanted[pet.Name]) and pet:IsDescendantOf(workspace) then
                        local prompt = pet:FindFirstChildWhichIsA("ProximityPrompt", true)
                        local target = prompt and prompt.Parent
                        if prompt and target and target:IsA("BasePart") then
                            local ok = true
                            if maxPrice > 0 then
                                local priceStr = tostring(prompt.ActionText):match("%$([%d,]+)")
                                local price = priceStr and tonumber((priceStr:gsub(",", ""))) or 0
                                ok = price <= maxPrice
                            end
                            if ok then
                                root = rootPart()
                                if not root then break end
                                root.CFrame = target.CFrame + Vector3.new(0, 4, 0)
                                moved = true
                                task.wait(0.15)
                                if prompt.Parent and prompt.Enabled then
                                    pcall(function() fireproximityprompt(prompt) end)
                                    task.wait(math.max(prompt.HoldDuration + 0.05, 0.1))
                                end
                            end
                        end
                    end
                end
                if moved then
                    root = rootPart()
                    if root then
                        root.CFrame = origin
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.QuestInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoQuests.Value then
            pcall(function() QuestClaim:FireServer() end)
        end
    end
end)
task.spawn(function()
    while task.wait(Options.PlaytimeInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoPlaytime.Value then
            for _, minutes in ipairs(playtimeMinutes) do
                pcall(function() PlaytimeClaim:InvokeServer(minutes) end)
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.RebirthInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoRebirthUpgrades.Value then
            for _, key in ipairs(selectedList(Options.RebirthUpgrades.Value, rebirthUpgradeKey)) do
                pcall(function() RebirthBuyUpgrade:InvokeServer(key) end)
            end
        end
        if Toggles.AutoRebirthItems.Value then
            for _, key in ipairs(selectedList(Options.RebirthItems.Value, rebirthItemKey)) do
                pcall(function() RebirthBuyItem:InvokeServer(key) end)
            end
        end
        if Toggles.AutoRebirth.Value then
            local cash = LocalPlayer:GetAttribute("Cash") or 0
            if RebirthConfig.canRebirth(cash) then
                pcall(function() RebirthRequest:FireServer() end)
            end
        end
    end
end)
local function affordable(price)
    local cash = LocalPlayer:GetAttribute("Cash") or 0
    local reserve = tonumber(Options.ShopKeepCash.Value) or 0
    return cash - price >= reserve
end
task.spawn(function()
    while task.wait(Options.ShopInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoBuyShop.Value then
            local bought = 0
            for _, category in ipairs(shopCategories) do
                if Library.Unloaded or not Toggles.AutoBuyShop.Value then break end
                for label in pairs(Options[category.option].Value) do
                    if bought >= Options.ShopBuyAmount.Value then break end
                    local id = category.ids[label]
                    if id and affordable(category.prices[label] or 0) then
                        pcall(function() BuyStructure:InvokeServer(category.kind, id) end)
                        bought = bought + 1
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.SprinklerInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoBuySprinklers.Value then
            local bought = 0
            for label in pairs(Options.BuySprinklers.Value) do
                if Library.Unloaded or not Toggles.AutoBuySprinklers.Value then break end
                if bought >= Options.SprinklerAmount.Value then break end
                local id = sprinklerIdByName[label]
                if id and affordable(sprinklerPriceByName[label] or 0) then
                    pcall(function() BuyStructure:InvokeServer("Decoration", id) end)
                    bought = bought + 1
                    task.wait(0.1)
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.WateringCanInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoBuyWateringCans.Value then
            local bought = 0
            for label in pairs(Options.BuyWateringCans.Value) do
                if Library.Unloaded or not Toggles.AutoBuyWateringCans.Value then break end
                if bought >= Options.WateringCanAmount.Value then break end
                local id = wateringCanIdByName[label]
                if id and affordable(wateringCanPriceByName[label] or 0) then
                    pcall(function() BuyStructure:InvokeServer("Gear", id) end)
                    bought = bought + 1
                    task.wait(0.1)
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.CrateInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoBuyCrates.Value then
            for label in pairs(Options.BuyCrates.Value) do
                if Library.Unloaded or not Toggles.AutoBuyCrates.Value then break end
                local id = crateIdByName[label]
                if id and affordable(cratePriceByName[label] or 0) then
                    pcall(function() OpenCrateCash:InvokeServer(id) end)
                    task.wait(0.2)
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.TrashInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoTrash.Value then
            local toolsToTrash = {}
            for _, kind in ipairs({ "Seed", "Bed", "SellTable", "Totem", "Decoration", "Gear", "Crate" }) do
                for _, tool in ipairs(ownedToolsOfKind(kind)) do
                    if shouldTrash(tool) then
                        table.insert(toolsToTrash, tool)
                    end
                end
            end
            local root = rootPart()
            local prompt = ownTrashPrompt()
            local target = prompt and prompt.Parent
            if #toolsToTrash > 0 and root and target and target:IsA("BasePart") then
                local originalCFrame = root.CFrame
                root.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.1)
                for _, tool in ipairs(toolsToTrash) do
                    if Library.Unloaded or not Toggles.AutoTrash.Value then break end
                    if tool.Parent then
                        equipTool(tool)
                        task.wait(0.1)
                        if tool.Parent == LocalPlayer.Character then
                            TrashHeld:FireServer(tool)
                        end
                        task.wait(0.1)
                    end
                end
                root = rootPart()
                if root then root.CFrame = originalCFrame end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.TotemPlaceInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoPlaceTotems.Value then
            for _, tool in ipairs(ownedToolsOfKind("Totem")) do
                if selectionContainsItem(Options.PlaceTotems.Value, tool:GetAttribute("ItemId"), totemLabelById) and canPlaceTotem(tool:GetAttribute("ItemId")) then
                    placeOwnedTool(tool, PlaceTotem, function() return Toggles.AutoPlaceTotems.Value end)
                    break
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.PlaceShopInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoPlaceShopItems.Value and next(Options.PlaceShopItems.Value) ~= nil then
            local placed = false
            for _, kind in ipairs({ "Bed", "SellTable", "Totem", "Decoration", "Crate" }) do
                for _, tool in ipairs(ownedToolsOfKind(kind)) do
                    if Library.Unloaded or not Toggles.AutoPlaceShopItems.Value then break end
                    local label = placeShopLabelByKey[kind .. ":" .. tostring(tool:GetAttribute("ItemId"))]
                    if label and Options.PlaceShopItems.Value[label] and (kind ~= "Totem" or canPlaceTotem(tool:GetAttribute("ItemId"))) then
                        placeOwnedTool(tool, placeRemoteByKind[kind], function() return Toggles.AutoPlaceShopItems.Value end)
                        placed = true
                        break
                    end
                end
                if placed or Library.Unloaded or not Toggles.AutoPlaceShopItems.Value then break end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.UseSprinklerInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoUseSprinklers.Value then
            for _, tool in ipairs(ownedToolsOfKind("Decoration")) do
                local itemId = tool:GetAttribute("ItemId")
                if sprinklerLabelById[itemId] and selectionContainsItem(Options.UseSprinklers.Value, itemId, sprinklerLabelById) then
                    placeOwnedTool(tool, PlaceDecoration, function() return Toggles.AutoUseSprinklers.Value end)
                    break
                end
            end
        end
    end
end)
task.spawn(function()
    while task.wait(Options.UseWateringCanInterval.Value) do
        if Library.Unloaded then break end
        if Toggles.AutoUseWateringCans.Value then
            for _, tool in ipairs(ownedToolsOfKind("Gear")) do
                local itemId = tool:GetAttribute("ItemId")
                local waterLeft = tonumber(tool:GetAttribute("WaterLeft")) or 0
                if wateringCanLabelById[itemId] and waterLeft > 0 and selectionContainsItem(Options.UseWateringCans.Value, itemId, wateringCanLabelById) then
                    activeWateringCan = tool
                    equipTool(tool)
                    task.wait(0.1)
                    if Library.Unloaded or not Toggles.AutoUseWateringCans.Value or not tool.Parent then break end
                    pcall(function() tool:Activate() end)
                    task.wait(math.min(0.4, Options.UseWateringCanInterval.Value))
                    pcall(function() tool:Deactivate() end)
                    activeWateringCan = nil
                    break
                end
            end
        end
    end
end)
Tabs.Settings:AddLeftGroupbox("Anti-AFK"):AddToggle("AntiAFK", { Text = "Anti-AFK", Default = true })
LocalPlayer.Idled:Connect(function()
    if Library.Unloaded then return end
    if not Toggles.AntiAFK.Value then return end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
Library:OnUnload(function()
    if activeWateringCan then
        pcall(function() activeWateringCan:Deactivate() end)
        activeWateringCan = nil
    end
    restoreWalkSpeed()
    restoreNoclip()
    stopFlying()
    clearSeedEsp()
    clearPetEsp()
    for _, connection in ipairs(playerConnections) do
        connection:Disconnect()
    end
    select("#", "[Grow It RNG] Unloaded")
end)
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("TempoHub")
SaveManager:SetFolder("TempoHub/GrowItRNG")
ThemeManager:SaveDefault("Mint")
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
end)(...)
