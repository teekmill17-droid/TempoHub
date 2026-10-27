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
getgenv().TempoHoodSubtitle = "HOTEL TYCOON"
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
local gV
local gC
local hj
local gY
local gF
local Options
local g0
local TempoHub
local g3
local hp
local g6
local Label
local g9
local gO
local gR
local Workspace
local gU
local hf
local gB
local Toggles
local HttpService
local gE
local g_
local hl
local CurrentCamera
local ho
local g2
local connection2
local g5
local connection
local gQ
local hb
local gT
local he
local gW
local gA
local hh
local Gen
local hk
local gZ
local SaveManager
local LocalPlayer
local VirtualUser
local gJ
local hq
local g4
local g7
local gM
local gP
local ha
local gS
local hd
local hg
local function fn17(cz, cA)
    local je = cz == "Toggle" and Toggles
    local jj = if je then 1 else 0
    local jh = 3032 * jj + 194 * (1 - jj)
    local ji = 1709 * jj + 533 * (1 - jj)
    if not ((jh * 3569 + ji * 2264 + jh * ji) % 16777213 == 3094859) then
        je = Options
    end
    local je_1 = je[cA]
    local jd_2 = type(je_1) == "table" and je_1.Type == cz
    local jd_3 = jd_2 and je_1
    local jj_1 = if jd_3 then 1 else 0
    local jh_1 = 3723 * jj_1 + 4006 * (1 - jj_1)
    local ji_1 = 594 * jj_1 + 189 * (1 - jj_1)
    if not ((jh_1 * 2823 + ji_1 * 415 + jh_1 * ji_1) % 16777213 == 12968001) then
        jd_3 = nil
    end
    return jd_3
end
local function fn106(E, F)
    if setclipboard then
        setclipboard(E)
    elseif toclipboard then
        toclipboard(E)
    end
    gR:Notify(F)
end
local function onCopyPayPalLink()
    hk(gF, "Copied PayPal link")
end
local function onCopySolanaAddress()
    hk(gM, "Copied Solana address")
end
local function fn123(dZ)
    local Hitbox = dZ:FindFirstChild("Hitbox")
    if not Hitbox then
        return false
    end
    local Character = LocalPlayer.Character
    local kq = Character and Character:FindFirstChild("HumanoidRootPart")
    if not kq then
        return false
    end
    local Position = Hitbox.Position
    kq.CFrame = CFrame.new(Position + Vector3.new(0, 1, 0))
    task.wait(0.5)
    if not hq() then
        return false
    end
    local ky = 1
    while true do
        if not (ky <= 3) then
            return not dZ.Parent
        end
        local kz = ky
        if not dZ.Parent then
            return true
        end
        kq.CFrame = CFrame.new(Position + Vector3.new(kz, 1, 0))
        task.wait(0.3)
        if not hq() then
            break
        end
        ky += 1
    end
    return false
end
local function fn127()
    hk(gB, "Copied Discord invite to clipboard")
end
local function worker()
    local ib_1
    while true do
        task.wait(1)
        if gR.Unloaded then
            break
        end
        local ia = math.floor(os.clock() - ha)
        if ia < 60 then
            ib_1 = ia .. "s"
        elseif ia < 3600 then
            ib_1 = string.format("%dm %ds", math.floor((ia) / (60)), ia % 60)
        else
            ib_1 = string.format("%dh %dm", math.floor((ia) / (3600)), math.floor((ia % 3600) / (60)))
        end
        Label:SetText(g0("Session time", ib_1, hl))
    end
end
local function antiGameplayPauseLoop()
    while not gR.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            g2(true)
        end
    end
end
local function fn160()
    if not Toggles.WalkSpeedEnabled.Value then
        local iO = hg()
        if iO then
            iO.WalkSpeed = 16
        end
    end
end
local function fn171()
    TempoHub.Gen = TempoHub.Gen + 1
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
    g2(false)
end
local function onRenderStepped(bA)
    if gR.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local iC_1 = hg()
        if iC_1 then
            iC_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local iC_3 = g3()
        local iD = hg()
        if iC_3 and iD then
            iD.PlatformStand = true
            local iD_1 = Vector3.zero
            if g6:IsKeyDown(Enum.KeyCode.W) then
                iD_1 = iD_1 + CurrentCamera.CFrame.LookVector
            end
            local iI = if g6:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if iI == 1 then
                iD_1 = iD_1 - CurrentCamera.CFrame.LookVector
            end
            if g6:IsKeyDown(Enum.KeyCode.A) then
                iD_1 = iD_1 - CurrentCamera.CFrame.RightVector
            end
            if g6:IsKeyDown(Enum.KeyCode.D) then
                iD_1 = iD_1 + CurrentCamera.CFrame.RightVector
            end
            if g6:IsKeyDown(Enum.KeyCode.Space) then
                iD_1 = iD_1 + Vector3.new(0, 1, 0)
            end
            if g6:IsKeyDown(Enum.KeyCode.LeftControl) then
                iD_1 = iD_1 - Vector3.new(0, 1, 0)
            end
            iC_3.Velocity = Vector3.zero
            if iD_1.Magnitude > 0 then
                iC_3.CFrame = iC_3.CFrame + iD_1.Unit * Options.FlySpeed.Value * bA
            end
        end
    end
end
local function onImportConfigFromClipboardTex()
    local jU_1
    local jS = Options.SaveManager_ImportSource.Value or ""
    local jS_1
    local jT = tostring(jS):match("^%s*(.-)%s*$")
    if jT == "" then
        gR:Notify("Paste an exported config into the box first")
        return
    end
    jS_1, jU_1 = pcall(HttpService.JSONDecode, HttpService, jT)
    local jT_1 = not jS_1 or type(jU_1) ~= "table" or type(jU_1.objects) ~= "table"
    if jT_1 then
        gR:Notify("That is not a valid exported config")
        return
    end
    local jS_2 = 0
    for i, v in ipairs(jU_1.objects) do
        if gJ(v) then
            jS_2 += 1
        end
    end
    if jS_2 == 0 then
        gR:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local jU_2 = jS_2 == 1 and "" or "s"
    gR:Notify(("Imported %d setting%s"):format(jS_2, jU_2), 6)
end
local function mailboxIntervalLoop()
    setthreadidentity(8)
    while hq() do
        local Value = Options.MailboxInterval.Value
        if Toggles.MailboxCollect.Value then
            pcall(hd)
        end
        task.wait(Value)
    end
end
local function fn240()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    gW = tick()
end
local function onCopyJoinScript_JobID()
    local h5 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, gE)
    if setclipboard then
        setclipboard(h5)
    elseif toclipboard then
        toclipboard(h5)
    end
    gR:Notify("Copied join script to clipboard")
end
local function fn260()
    local Character = hj.Character
    local iq = Character and Character:FindFirstChild("HumanoidRootPart")
    return iq
end
local function onJumpRequest()
    if gR.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local iA_1 = hg()
        if iA_1 then
            iA_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn265()
    local kB = hf()
    if not kB then
        return
    end
    local Tycoon = kB:FindFirstChild("Tycoon")
    if not Tycoon then
        return
    end
    local attr = Tycoon:GetAttribute("Type")
    local kD = gT()
    local kE = {}
    for i, child in ipairs(Tycoon:GetChildren()) do
        local kC_1 = child:IsA("Folder") and tonumber(child.Name)
        if kC_1 then
            local PurchasingPads = child:FindFirstChild("PurchasingPads")
            if PurchasingPads then
                for i, child2 in ipairs(PurchasingPads:GetChildren()) do
                    local kC_3 = child2:IsA("Model") and child2:FindFirstChild("Hitbox")
                    if kC_3 then
                        local kC_4 = gZ.GetObjectPrice(attr, child.Name, child2:GetAttribute("Structure"))
                        local kF = type(kC_4) == "number" and kC_4 > 0 and kC_4 <= kD
                        if kF then
                            kE[#kE + 1] = { pad = child2, price = kC_4 }
                        end
                    end
                end
            end
        end
    end
    if #kE == 0 then
        return
    end
    table.sort(kE, function(en, eo)
        return en.price < eo.price
    end)
    for i, v in ipairs(kE) do
        if not hq() then
            return
        end
        local pad = v.pad
        if not not pad.Parent then
            if v.price > gT() then
                return
            end
            hh.busy = true
            pcall(gC, pad)
            hh.busy = false
        end
    end
end
local function fn279()
    g2(Toggles.AntiGameplayPause.Value)
end
local function fn280()
    SaveManager:LoadAutoloadConfig()
end
local function onInputBegan()
    g_ = tick()
end
local function fn320()
    return gO.TempoHub == TempoHub and TempoHub.Gen == Gen
end
local function onInputChanged(ci)
    local UserInputType = ci.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        g_ = tick()
    end
end
local function antiAfkLoop()
    while not gR.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local i9 = tick() - g_
            local ja = tick() - gW
            if i9 >= 300 and ja >= 60 then
                pcall(hp)
            else
                if i9 < 300 and ja >= 300 then
                    pcall(hp)
                end
            end
        end
    end
end
local function fn325()
    local h1_1
    local h0_1
    if identifyexecutor then
        h1_1, h0_1 = identifyexecutor()
        local h2 = h1_1 ~= ""
        local h3 = type(h1_1) == "string" and h2
        if h3 then
            local h2_1 = type(h0_1) == "string" and h0_1 ~= "" and h1_1 .. " " .. h0_1
            he = h2_1 or h1_1
        end
    end
end
local function fn331(X, Y, Z)
    return string.format("<b>%s</b> %s %s", X, hb("-", "#5a6070"), hb(Y, Z))
end
local function onUnload()
    gR:Unload()
end
local function fn363()
    local Character = hj.Character
    local ij = Character and Character:FindFirstChildOfClass("Humanoid")
    return ij
end
local function onStepped()
    if gR.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = hj.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local is_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if is_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn408(M)
    local DiscordGroup = M:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = g7 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = g7 })
end
local function fn418()
    gR:Notify({ Title = "Tempo", Description = "Loaded for " .. gU, Time = 4 })
end
local function fn449(U, V)
    return string.format('<font color="%s">%s</font>', V, U)
end
local function onExportConfigToClipboard()
    local jP_1
    local jO_1
    jO_1, jP_1 = pcall(HttpService.JSONEncode, HttpService, gP())
    if not jO_1 then
        gR:Notify("Failed to encode the config")
        return
    end
    local jO_2 = setclipboard or toclipboard
    local jO_3 = type(jO_2) ~= "function" or not pcall(jO_2, jP_1)
    if jO_3 then
        gR:Notify("Your executor does not support copying to the clipboard")
        return
    end
    gR:Notify("Config copied to clipboard", 6)
end
local function onCopyVenmoLink()
    hk(gA, "Copied Venmo link")
end
local function onCopyBitcoinAddress()
    hk(gY, "Copied Bitcoin address")
end
local function onCopyLitecoinAddress()
    hk(g4, "Copied Litecoin address")
end
local function onCopyUSDTAddress()
    hk(gQ, "Copied USDT address")
end
local function onCopyEthereumAddress()
    hk(gV, "Copied Ethereum address")
end
local function fn534()
    if not Toggles.Fly.Value then
        local iJ = hg()
        if iJ then
            iJ.PlatformStand = false
        end
    end
end
local function autoBuyPadsLoop()
    setthreadidentity(8)
    while hq() do
        local Value = Options.BuyInterval.Value
        if Toggles.AutoBuyPads.Value then
            pcall(gS)
        end
        task.wait(Value)
    end
end
local function fn539()
    if hh.busy then
        return
    end
    local kf = hf()
    if not kf then
        return
    end
    local Tycoon = kf:FindFirstChild("Tycoon")
    local kf_1 = Tycoon and Tycoon:FindFirstChild("Mailbox") and Tycoon.Mailbox:FindFirstChild("ProximityPromptPart")
    local kg_1 = kf_1
    if kf_1 then
        kf_1 = kg_1:FindFirstChildOfClass("ProximityPrompt")
    end
    local kh = kf_1
    if not kh then
        return
    end
    local kf_2 = 0
    local Data = g5.Data
    local kj = type(Data) == "table" and Data.CurrentTycoon
    if kj then
        local kj_1 = Data.TycoonSpecificData and Data.TycoonSpecificData[Data.CurrentTycoon]
        local ki_1 = kj_1
        if kj_1 then
            kj_1 = ki_1.CashToCollect
        end
        local ki_2 = kj_1
        local kn = if ki_2 then 1 else 0
        local kl = 875 * kn + 2494 * (1 - kn)
        local km = 979 * kn + 1448 * (1 - kn)
        if not ((kl * 2763 + km * 3047 + kl * km) % 16777213 == 6257263) then
            ki_2 = 0
        end
        kf_2 = ki_2
    end
    if not (kf_2 > 0) then
        return
    end
    local Character = LocalPlayer.Character
    local ki_3 = Character and Character:FindFirstChild("HumanoidRootPart")
    if not ki_3 then
        return
    end
    ki_3.CFrame = CFrame.new(kg_1.Position + Vector3.new(0, 1.5, 0))
    task.wait(0.4)
    if not hq() then
        return
    end
    fireproximityprompt(kh)
end
local function fn556()
    local jr = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local js = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if js then
                local js_1 = g9(k, v)
                if js_1 then
                    jr[#jr + 1] = js_1
                end
            end
        end
    end
    table.sort(jr, function(cV, cW)
        if cV.type ~= cW.type then
            return cV.type < cW.type
        end
        return cV.idx < cW.idx
    end)
    return { objects = jr }
end
local function fn601()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local kd = leaderstats and leaderstats:FindFirstChild("Cash")
    local kc_1 = kd
    if kd then
        kd = kc_1.Value
    end
    return kd or 0
end
local function fn621(cH, cI)
    local Type = cI.Type
    if Type == "Toggle" then
        return { idx = cH, type = "Toggle", value = cI.Value == true }
    elseif Type == "Slider" then
        return { idx = cH, type = "Slider", value = tostring(cI.Value) }
    elseif Type == "Dropdown" then
        return { idx = cH, type = "Dropdown", multi = cI.Multi == true, value = cI.Value }
    elseif Type == "Input" then
        local jl = cI.Value or ""
        return { idx = cH, type = "Input", text = tostring(jl) }
    elseif Type == "ColorPicker" then
        return { idx = cH, type = "ColorPicker", value = cI.Value:ToHex(), transparency = cI.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = cH,
            type = "KeyPicker",
            mode = cI.Mode,
            key = cI.Value,
            modifiers = cI.Modifiers,
            toggled = cI.Toggled
        }
    else
        return nil
    end
end
local function fn623()
    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in ipairs(Plots:GetChildren()) do
        if child:GetAttribute("OwnerId") == LocalPlayer.UserId then
            return child
        end
    end
    return nil
end
local function onRscripts()
    if setclipboard then
        setclipboard(ho)
    elseif toclipboard then
        toclipboard(ho)
    end
    gR:Notify("Copied Rscripts profile to clipboard")
end
gA = nil
gB = nil
gC = nil
Gen = nil
gE = nil
gF = nil
SaveManager = nil
CurrentCamera = nil
TempoHub = nil
gJ = nil
connection2 = nil
Label = nil
gM = nil
gO = nil
gP = nil
gQ = nil
gR = nil
gS = nil
gT = nil
gU = nil
gV = nil
gW = nil
HttpService = nil
gY = nil
gZ = nil
g_ = nil
g0 = nil
VirtualUser = nil
g2 = nil
g3 = nil
g4 = nil
g5 = nil
g6 = nil
g7 = nil
connection = nil
g9 = nil
ha = nil
hb = nil
Workspace = nil
hd = nil
he = nil
hf = nil
hg = nil
hh = nil
Toggles = nil
hj = nil
hk = nil
hl = nil
Options = nil
local gN
LocalPlayer = nil
ho = nil
hp = nil
hq = nil
local hN_1
local hJ_1
local hH_1
local hD_1
local hC_1
local hB_1
local hA_1
local hw_1
local hz_1, hz_3
local hy_1, hy_3
local hv_2, hv_3
LocalPlayer, hj, Workspace, g6, VirtualUser, HttpService, gU, gO = nil, nil, nil, nil, nil, nil, nil, nil
local Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
hj = LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
g6 = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
gU = "Hotel Tycoon"
if Players and HttpService and (Players or not HttpService) and (HttpService and HttpService or Players and Players) and (Players and HttpService and (not HttpService or Players) or (not HttpService or Players) and (not Players or not HttpService)) and (not HttpService and HttpService and (not HttpService or HttpService) or not Players and not Players and (Players or Players) or (Players and HttpService and (Players and Players) or (Players or Players) and (HttpService or HttpService))) and not (Players and HttpService and (Players or not HttpService) and (HttpService and HttpService or Players and Players) and (Players and HttpService and (not HttpService or Players) or (not HttpService or Players) and (not Players or not HttpService)) and (not HttpService and HttpService and (not HttpService or HttpService) or not Players and not Players and (Players or Players) or (Players and HttpService and (Players and Players) or (Players or Players) and (HttpService or HttpService)))) then
    gU = getgenv()
else
    gO = getgenv()
end
local hs = gO.TempoHub or {}
TempoHub = nil
gO.TempoHub = hs
TempoHub = gO.TempoHub
local hr_2 = TempoHub.Gen or 0
Gen, g5, gZ, gR, SaveManager, gB, ho, hy_1, Options, Toggles, hA_1, hl, he, Label, gE, hz_1, hq, hk, g7, hb, g0 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
TempoHub.Gen = hr_2 + 1
Gen = TempoHub.Gen
hq = fn320
local ModuleLoader = require(ReplicatedStorage:FindFirstChild("ModuleLoader"))
g5 = ModuleLoader.Import("DataHandler")
gZ = ModuleLoader.Import("TycoonConfig")
setthreadidentity(8)
gR = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if (hy_1 or not hy_1 or not hy_1 and hz_1) and (not hz_1 or not hy_1 or "https://discord.gg/K7Qxnxkk46") and ((ho or not hy_1) and (hy_1 or false) or (false and hz_1 or hz_1 and ho)) or not ((hy_1 or not hy_1 or not hy_1 and hz_1) and (not hz_1 or not hy_1 or "https://discord.gg/K7Qxnxkk46") and ((ho or not hy_1) and (hy_1 or false) or (false and hz_1 or hz_1 and ho))) then
    gB = "https://discord.gg/K7Qxnxkk46"
else
    gR = "https://discord.gg/K7Qxnxkk46"
end
ho = "https://discord.gg/K7Qxnxkk46"
hk = fn106
g7 = fn127
local Window = gR:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = gB, Copyable = true }, "|", gU },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
Options = gR.Options
Toggles = gR.Toggles
local hG = {
    Info = Window:AddTab("Info", "info"),
    Farming = Window:AddTab("Farming", "coins"),
    Inventory = Window:AddTab("Inventory", "package"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
hb = fn449
g0 = fn331
if ((Toggles or Toggles) and (not Toggles or not gE) or (not Toggles and not Toggles or not Toggles and not gE)) and ((gE or not gE) and (not Toggles or gE) and (gE or not Toggles or Toggles and Toggles)) or not (((Toggles or Toggles) and (not Toggles or not gE) or (not Toggles and not Toggles or not Toggles and not gE)) and ((gE or not gE) and (not Toggles or gE) and (gE or not Toggles or Toggles and Toggles))) then
    hA_1, hD_1, hl, hC_1 = "#7fd47f", "#6ec1ff", "#e8a34d", "#8b93a3"
    he = "Unknown"
    pcall(fn325)
    local AccountGroup = hG.Info:AddLeftGroupbox("Account", "circle-user")
    AccountGroup:AddLabel(g0("User", hj.Name, hA_1), true)
    AccountGroup:AddLabel(g0("Status", "Keyless", hA_1), true)
    AccountGroup:AddLabel(g0("Executor", he, hA_1), true)
    hB_1 = hG.Info:AddLeftGroupbox("Game Info", "gamepad-2")
    hB_1:AddLabel(hb(gU .. " [" .. tostring(game.PlaceId) .. "]", hD_1), true)
    hB_1:AddLabel(g0("Place ID", tostring(game.PlaceId), hD_1), true)
    Label = hB_1:AddLabel(g0("Session time", "0s", hl), true)
else
    hD_1, g0, hB_1, hv_2 = "#e8a34d", "#8b93a3", "#7fd47f", "#6ec1ff"
    hb = "Unknown"
    pcall(fn325)
    hj = (nil):AddLeftGroupbox("Account", "circle-user")
    hj:AddLabel(he("User", Label.Name, hB_1), true)
    hj:AddLabel(he("Status", "Keyless", hB_1), true)
    hj:AddLabel(he("Executor", hb, hB_1), true)
    gU = (nil):AddLeftGroupbox("Game Info", "gamepad-2")
    gU:AddLabel(hA_1(hG .. " [" .. tostring(game.PlaceId) .. "]", hv_2), true)
    gU:AddLabel(he("Place ID", tostring(game.PlaceId), hv_2), true)
    hC_1 = gU:AddLabel(he("Session time", "0s", hD_1), true)
end
if ((not hC_1 or not Toggles) and (Window or Toggles) or (not hC_1 and not Window or Toggles and not hC_1)) and not ((not hC_1 or not Toggles) and (Window or Toggles) or (not hC_1 and not Window or Toggles and not hC_1)) then
    he = tostring(game.JobId)
else
    gE = tostring(game.JobId)
end
local hz_2 = #gE > 18
if hz_2 then
    local hr_3 = 0
    repeat
        if hr_3 * 120588071 + 5 + 4 <= hr_3 * 120588071 + 5 + 4 + 1 then
            hz_2 = string.sub(gE, 1, 18) .. "..."
        else
            gE = string.sub(hz_2, 1, 18) .. "..."
        end
        hr_3 = (hr_3 + 3) % 4
    until (hr_3 * 3 + 2) % 4 == 3
end
local hr_4 = hz_2 or gE
ha, g4, gY, gV, gQ, gM, gF, gA = nil, nil, nil, nil, nil, nil, nil, nil
hB_1:AddLabel(g0("Server", hr_4, hC_1), true)
hB_1:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
ha = os.clock()
task.spawn(worker)
local ScriptsGroup = hG.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(hb("Included in this hub", hC_1), true)
ScriptsGroup:AddLabel(hb(gU, hD_1), true)
local FeaturesGroup = hG.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(hb("Auto Collect Income", hD_1), true)
FeaturesGroup:AddLabel(hb("Auto Buy Buttons", hl), true)
FeaturesGroup:AddLabel(hb("Player Movement", hC_1), true)
local SocialsGroup = hG.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = g7 })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = hG.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = g7 })
g4 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
gY = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
gV = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
gQ = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
gM = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
gF = ""
gA = ""
hN_1, hJ_1, hH_1, hz_3, hy_3, hw_1, hv_3 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
local DonationsGroup = hG.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(hb("All donations are optional but appreciated.", hl), true)
DonationsGroup:AddLabel(hb("If you donate you get a special role, just PING after you donate.", hA_1), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(hb("LTC / Litecoin", hN_1), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(hb("BTC / Bitcoin", hJ_1), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(hb("ETH / Ethereum", hH_1), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(hb("USDT", hz_3), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(hb("Solana", hy_3), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(hb("PayPal", hw_1), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(hb("Venmo", hv_3), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(hb("Don't have any of the listed currencies but still wanna donate?", hC_1), true)
DonationsGroup:AddLabel(hb("DM me and we'll work something out.", hD_1), true)
local FaqGroup = hG.Info:AddRightGroupbox("FAQ", "circle-help")
if (not hr_4 and FaqGroup and (FaqGroup and false) or not hr_4 and not FaqGroup and (hr_4 and not FaqGroup) or (FaqGroup and not hr_4 or FaqGroup and FaqGroup) and (hJ_1 and FaqGroup and (not FaqGroup and FaqGroup))) and ("#f7931a" and (hJ_1 and FaqGroup) or (not FaqGroup or not hr_4) and (not FaqGroup or FaqGroup) or (FaqGroup and false or hr_4 and false or not FaqGroup and FaqGroup and (hr_4 or hJ_1))) and not ((not hr_4 and FaqGroup and (FaqGroup and false) or not hr_4 and not FaqGroup and (hr_4 and not FaqGroup) or (FaqGroup and not hr_4 or FaqGroup and FaqGroup) and (hJ_1 and FaqGroup and (not FaqGroup and FaqGroup))) and ("#f7931a" and (hJ_1 and FaqGroup) or (not FaqGroup or not hr_4) and (not FaqGroup or FaqGroup) or (FaqGroup and false or hr_4 and false or not FaqGroup and FaqGroup and (hr_4 or hJ_1)))) then
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
end
local IncomeGroup = hG.Farming:AddRightGroupbox("Income", "coins")
IncomeGroup:AddToggle("MailboxCollect", { Text = "Auto Collect Income (Mailbox)", Default = false })
IncomeGroup:AddSlider("MailboxInterval", { Text = "Collect Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local PurchasingGroup = hG.Inventory:AddRightGroupbox("Purchasing", "shopping-cart")
PurchasingGroup:AddToggle("AutoBuyPads", { Text = "Auto Buy All Buttons", Default = false })
PurchasingGroup:AddSlider("BuyInterval", { Text = "Buy Check Interval", Default = 1.5, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
CurrentCamera, g_, gW, connection, connection2, hh, hg, g3, g2, hp, gN, g9, gP, gJ, hf, gT, hd, gC, gS = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
fn408(hG.Farming)
fn408(hG.Inventory)
fn408(hG.Player)
local MovementGroup = hG.Player:AddRightGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = hG.Player:AddLeftGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
hg = fn363
g3 = fn260
RunService.Stepped:Connect(onStepped)
g6.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn534)
Toggles.WalkSpeedEnabled:OnChanged(fn160)
g2 = function(bV)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not bV)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not bV
        end
    end)
    if not bV then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(hj, "GameplayPaused", false)
        else
            hj.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn279)
task.spawn(antiGameplayPauseLoop)
local MenuGroup = hG.Settings:AddLeftGroupbox("Menu", "wrench")
if (connection or connection) and (not connection or gW) and (connection or gS or connection and not gW) or not ((connection or connection) and (not connection or gW) and (connection or gS or connection and not gW)) then
    g_ = tick()
    gW = tick()
    pcall(function()
        for i, v in ipairs(getconnections(hj.Idled)) do
            local i0 = v
            pcall(function()
                i0:Disable()
            end)
        end
    end)
    hp = fn240
    connection = g6.InputBegan:Connect(onInputBegan)
else
    hp = tick()
    g6 = tick()
    pcall(function()
        for i, v in ipairs(getconnections(hj.Idled)) do
            local i0 = v
            pcall(function()
                i0:Disable()
            end)
        end
    end)
    g_ = fn240
    gW = connection.InputBegan:Connect(onInputBegan)
end
connection2 = g6.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddButton("Unload", onUnload)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
gR.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(gR)
SaveManager:SetLibrary(gR)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
ThemeManager:SetFolder("TempoHub")
SaveManager:SetFolder("TempoHub/HotelTycoon")
SaveManager:SetSubFolder(tostring(game.PlaceId))
local ht_2 = SaveManager:BuildConfigSection(hG.Settings)
ThemeManager:ApplyToTab(hG.Settings)
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:LoadDefault()
gN = fn17
g9 = fn621
gP = fn556
gJ = function(cY)
    local jI
    jI = nil
    local jJ = type(cY) ~= "table" or type(cY.idx) ~= "string"
    local jN = if jJ then 1 else 0
    local jL = 803 * jN + 2867 * (1 - jN)
    local jM = 977 * jN + 609 * (1 - jN)
    if not ((jL * 647 + jM * 610 + jL * jM) % 16777213 == 1900042) then
        jJ = type(cY.type) ~= "string"
    end
    if not jJ then
        jJ = SaveManager.Ignore[cY.idx]
    end
    if jJ then
        return false
    end
    jI = gN(cY.type, cY.idx)
    if not jI then
        return false
    end
    local jJ_1 = pcall(function()
        if cY.type == "Input" then
            if type(cY.text) ~= "string" then
                return
            end
            jI:SetValue(cY.text)
        elseif cY.type == "ColorPicker" then
            jI:SetValueRGB(Color3.fromHex(cY.value), cY.transparency)
        elseif cY.type == "KeyPicker" then
            jI:SetValue({ cY.key, cY.mode, cY.modifiers })
            if cY.mode == "Toggle" and cY.toggled ~= nil then
                jI.Toggled = cY.toggled
                jI:Update()
            end
        else
            jI:SetValue(cY.value)
        end
    end)
    return jJ_1
end
ht_2:AddDivider()
ht_2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
ht_2:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
ht_2:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
pcall(fn280)
hf = fn623
gT = fn601
if (not hd and gS or (false or g2)) and (false and (not hd and gS)) and not ((not hd and gS or (false or g2)) and (false and (not hd and gS))) then
    hd = { busy = false }
    hh = fn539
else
    hh = { busy = false }
    hd = fn539
end
gC = fn123
gS = fn265
do
    task.spawn(mailboxIntervalLoop)
    task.spawn(autoBuyPadsLoop)
    gR:OnUnload(fn171)
    pcall(fn418)
end
end)(...)
