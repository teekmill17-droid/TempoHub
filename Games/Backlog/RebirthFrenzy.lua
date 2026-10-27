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
getgenv().TempoHoodSubtitle = "REBIRTH FRENZY"
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
local kl
local kI
local j_
local ko
local j2
local SaveManager
local Library
local kv
local ky
local kb
local jT
local kB
local kh
local jW
local jZ
local kH
local kk
local Toggles
local HttpService
local VirtualUser
local j4
local kt
local j7
local kx
local ka
local kA
local Label
local connection
local kg
local LocalPlayer
local connection2
local j0
local __tempo_gen
local km
local Options
local kp
local kM
local j6
local UserInputService
local j9
local kw
local jR
local kc
local Eggs
local kf
local ki
local CurrentCamera
local jX
local function fn114(di, dj)
    local mY_1 = (di == "Toggle" and Toggles or Options)[dj]
    local mX_2 = type(mY_1) == "table" and mY_1.Type == di
    return mX_2 and mY_1 or nil
end
local function fn122()
    if Toggles.UseServerAutoTap.Value then
        pcall(function()
            if j0 then
                j0:FireServer()
            end
        end)
        jZ("Server AutoTap", "Toggled server auto via ToggleAutoTap", 2)
    end
end
local function fn127(aw)
    local DiscordGroup = aw:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kk })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kk })
end
local function onCopyUSDTAddress()
    kt(kg, "Copied USDT address")
end
local function onCopyJoinScript_JobID()
    local lU = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, ka)
    if setclipboard then
        setclipboard(lU)
    elseif toclipboard then
        toclipboard(lU)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn153()
    return kM.__tempo_gen == __tempo_gen
end
local function onInputBegan()
    kl = tick()
end
local function fn217()
    local n5_1
    local n2 = not Eggs
    local oa = if n2 then 1 else 0
    local n8 = 1397 * oa + 3708 * (1 - oa)
    local n9 = 2634 * oa + 3483 * (1 - oa)
    if not ((n8 * 3064 + n9 * 633 + n8 * n9) % 16777213 == 9627428) then
        n2 = not LocalPlayer.Character
    end
    if not n2 then
        n2 = not LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    if n2 then
        return nil
    end
    local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
    local n3 = jX()
    local n3_1
    local n4 = {}
    for i, v in ipairs(n3) do
        n4[v] = true
    end
    n5_1, n3_1 = nil, math.huge
    for i, child in ipairs(Eggs:GetChildren()) do
        local n6 = child:IsA("Model") and child.PrimaryPart and n4[child.Name]
        if n6 then
            local Magnitude = (HumanoidRootPart.Position - child.PrimaryPart.Position).Magnitude
            if Magnitude < n3_1 then
                n3_1 = Magnitude
                n5_1 = child
            end
        end
    end
    return n5_1, n3_1
end
local function onCopyLitecoinAddress()
    kt(kp, "Copied Litecoin address")
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local mb_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if mb_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn256(ap, aq)
    if setclipboard then
        setclipboard(ap)
    elseif toclipboard then
        toclipboard(ap)
    end
    Library:Notify(aq)
end
local function onRscripts()
    if setclipboard then
        setclipboard(ky)
    elseif toclipboard then
        toclipboard(ky)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn266()
    if not Toggles.Fly.Value then
        local mv = kw()
        if mv then
            mv.PlatformStand = false
        end
    end
end
local function fn296()
    kM.__tempo_gen = kM.__tempo_gen + 1
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
    jR(false)
    jZ("Tempo", "Unloaded", 2)
end
local function onUnload()
    Library:Unload()
end
local function onImportConfigFromClipboardTex()
    local nG_1
    local nE = Options.SaveManager_ImportSource.Value or ""
    local nE_1
    local nF = tostring(nE):match("^%s*(.-)%s*$")
    if nF == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    nE_1, nG_1 = pcall(HttpService.JSONDecode, HttpService, nF)
    local nF_1 = not nE_1
    local nK = if nF_1 then 1 else 0
    local nI = 967 * nK + 223 * (1 - nK)
    local nJ = 1827 * nK + 780 * (1 - nK)
    if not ((nI * 3245 + nJ * 396 + nI * nJ) % 16777213 == 5628116) then
        nF_1 = type(nG_1) ~= "table"
    end
    if not nF_1 then
        nF_1 = type(nG_1.objects) ~= "table"
    end
    if nF_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local nE_2 = 0
    for i, v in ipairs(nG_1.objects) do
        if kc(v) then
            nE_2 += 1
        end
    end
    if nE_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local nG_2 = nE_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(nE_2, nG_2), 6)
end
local function onCopyPayPalLink()
    kt(kb, "Copied PayPal link")
end
local function fn340()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    kh = tick()
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            jR(true)
        end
    end
end
local function onRenderStepped(cj)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local mo_1 = kw()
        if mo_1 then
            mo_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local mo_3 = ko()
        local mp = kw()
        if mo_3 and mp then
            mp.PlatformStand = true
            local mp_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                mp_1 = mp_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                mp_1 = mp_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                mp_1 = mp_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                mp_1 = mp_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                mp_1 = mp_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                mp_1 = mp_1 - Vector3.new(0, 1, 0)
            end
            mo_3.Velocity = Vector3.zero
            if mp_1.Magnitude > 0 then
                mo_3.CFrame = mo_3.CFrame + mp_1.Unit * Options.FlySpeed.Value * cj
            end
        end
    end
end
local function onCopyVenmoLink()
    kt(j9, "Copied Venmo link")
end
local function onCopySolanaAddress()
    kt(kf, "Copied Solana address")
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local mj_1 = kw()
        if mj_1 then
            mj_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn422()
    SaveManager:LoadAutoloadConfig()
end
local function fn433()
    local Character = LocalPlayer.Character
    local l3 = Character and Character:FindFirstChildOfClass("Humanoid")
    return l3
end
local function autoClickIntervalLoop()
    setthreadidentity(8)
    while true do
        local oA = kH() and not Library.Unloaded
        if oA then
            local oB = Options.AutoClickInterval and Options.AutoClickInterval.Value or 0.01
            if Toggles.AutoClick and Toggles.AutoClick.Value then
                pcall(function()
                    if j4 then
                        j4:FireServer()
                    elseif j7 then
                        j7:FindFirstChild("Tap"):FireServer()
                    end
                end)
            end
            task.wait(oB)
            local oA_3 = not kH() or Library.Unloaded
            if oA_3 then
                break
            end
            continue
        end
        break
    end
end
local function fn486()
    local lQ_1
    local lP_1
    if identifyexecutor then
        lQ_1, lP_1 = identifyexecutor()
        local lR = lQ_1 ~= ""
        local lS = type(lQ_1) == "string" and lR
        if lS then
            local lR_1 = type(lP_1) == "string" and lP_1 ~= "" and lQ_1 .. " " .. lP_1
            kv = lR_1 or lQ_1
        end
    end
end
local function fn498(aC, aD)
    return string.format('<font color="%s">%s</font>', aD, aC)
end
local function onCopyBitcoinAddress()
    kt(km, "Copied Bitcoin address")
end
local function fn521(aF, aG, aH)
    return string.format("<b>%s</b> %s %s", aF, j2("-", "#5a6070"), j2(aG, aH))
end
local function onExportConfigToClipboard()
    local nv_1
    local nu_1
    nu_1, nv_1 = pcall(HttpService.JSONEncode, HttpService, kI())
    if not nu_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local nu_2 = setclipboard
    local nA = if nu_2 then 1 else 0
    local ny = 1211 * nA + 2278 * (1 - nA)
    local nz = 3805 * nA + 2093 * (1 - nA)
    if not ((ny * 1030 + nz * 3644 + ny * nz) % 16777213 == 2943392) then
        nu_2 = toclipboard
    end
    local nw = nu_2
    local nu_3 = type(nw) ~= "function" or not pcall(nw, nv_1)
    if nu_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn621()
    local nR = Options.SelectedEggs and Options.SelectedEggs.Value
    if not nR then
        return { kx[1] }
    elseif type(nR) == "string" then
        return { nR }
    elseif type(nR) == "table" then
        local nR_1 = {}
        for k, v in pairs(nR) do
            if v then
                table.insert(nR_1, k)
            end
        end
        if #nR_1 == 0 then
            return { kx[1] }
        end
        return nR_1
    else
        return { kx[1] }
    end
end
local function fn640()
    if not Toggles.WalkSpeedEnabled.Value then
        local mx = kw()
        if mx then
            mx.WalkSpeed = 16
        end
    end
end
local function fn643()
    local m7 = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local m8 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if m8 then
                local m8_1 = jW(k, v)
                if m8_1 then
                    m7[#m7 + 1] = m8_1
                end
            end
        end
    end
    table.sort(m7, function(dG, dH)
        if dG.type ~= dH.type then
            return dG.type < dH.type
        end
        return dG.idx < dH.idx
    end)
    return { objects = m7 }
end
local function onInputChanged(c1)
    local UserInputType = c1.UserInputType
    local mO = UserInputType == Enum.UserInputType.MouseMovement
    local mS = if mO then 1 else 0
    local mQ = 505 * mS + 3121 * (1 - mS)
    local mR = 1401 * mS + 231 * (1 - mS)
    if not ((mQ * 1041 + mR * 3119 + mQ * mR) % 16777213 == 5602929) then
        mO = UserInputType == Enum.UserInputType.Gamepad1
    end
    if mO then
        kl = tick()
    end
end
local function fn676()
    Options.AutoClickInterval:SetValue(0.01)
end
local function fn743()
    jR(Toggles.AntiGameplayPause.Value)
end
local function fn750()
    local Character = LocalPlayer.Character
    local l9 = Character and Character:FindFirstChild("HumanoidRootPart")
    return l9
end
local function onCopyEthereumAddress()
    kt(ki, "Copied Ethereum address")
end
local function fn805()
    kt(kA, "Copied Discord invite to clipboard")
end
local function fn808()
    Library:Unload()
end
local function fn821()
    Options.AutoHatchInterval:SetValue(0.01)
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local mT = tick() - kl
            local mU = tick() - kh
            if mT >= 300 and mU >= 60 then
                pcall(j6)
            else
                if mT < 300 and mU >= 300 then
                    pcall(j6)
                end
            end
        end
    end
end
local function worker()
    local lX_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local lW = math.floor(os.clock() - j_)
        if lW < 60 then
            lX_1 = lW .. "s"
        elseif lW < 3600 then
            lX_1 = string.format("%dm %ds", math.floor((lW) / (60)), lW % 60)
        else
            lX_1 = string.format("%dh %dm", math.floor((lW) / (3600)), math.floor((lW % 3600) / (60)))
        end
        Label:SetText(jT("Session time", lX_1, kB))
    end
end
local function fn895()
    setthreadidentity(8)
end
local function fn900(dr, ds)
    local Type = ds.Type
    if Type == "Toggle" then
        return { idx = dr, type = "Toggle", value = ds.Value == true }
    elseif Type == "Slider" then
        return { idx = dr, type = "Slider", value = tostring(ds.Value) }
    elseif Type == "Dropdown" then
        return { idx = dr, type = "Dropdown", multi = ds.Multi == true, value = ds.Value }
    elseif Type == "Input" then
        local m4 = ds.Value or ""
        return { idx = dr, type = "Input", text = tostring(m4) }
    elseif Type == "ColorPicker" then
        return { idx = dr, type = "ColorPicker", value = ds.Value:ToHex(), transparency = ds.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = dr,
            type = "KeyPicker",
            mode = ds.Mode,
            key = ds.Value,
            modifiers = ds.Modifiers,
            toggled = ds.Toggled
        }
    else
        return nil
    end
end
jR = nil
jT = nil
connection = nil
jW = nil
jX = nil
jZ = nil
j_ = nil
j0 = nil
Toggles = nil
j2 = nil
Options = nil
j4 = nil
SaveManager = nil
j6 = nil
j7 = nil
Library = nil
j9 = nil
ka = nil
kb = nil
kc = nil
Label = nil
kf = nil
kg = nil
kh = nil
ki = nil
LocalPlayer = nil
kk = nil
kl = nil
km = nil
HttpService = nil
ko = nil
kp = nil
VirtualUser = nil
UserInputService = nil
kt = nil
kv = nil
kw = nil
kx = nil
ky = nil
Eggs = nil
kA = nil
kB = nil
local jQ, Upgrade, Rebirth, ke, kC, kD, kE
CurrentCamera = nil
connection2 = nil
kH = nil
kI = nil
__tempo_gen = nil
kM = nil
local kK, kQ, kR, kS, kT, kU, kZ, k4, k6, DonationsGroup
local kP_13
local kO = getgenv().TempoHub
if kO then
    local kP_1 = 7
    repeat
        if (kP_1 * 2 + 6) * 10 % 3 == ((kP_1 * 2 + 6) * 10 + 0) % 3 then
            kO = getgenv().TempoHub.Unload
        else
            kO = getgenv().TempoHub.Unload
        end
        kP_1 = (kP_1 + 4) % 8
    until (kP_1 * 5 + 3) % 8 == 2
end
if kO then
    local kP_2 = 5
    repeat
        local pG = bit32.rrotate(bit32.bxor(bit32.lrotate(kP_2, 23), string.byte(tostring(kP_2))), 6)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(pG, 3447653695), 1595804180), (bit32.bxor(bit32.band(pG, 847313600), 3254933398))), 1595804180), 3254933398) ~= pG then
            pcall(getgenv().TempoHub.Unload)
        else
            pcall(getgenv().TempoHub.Unload)
        end
        kP_2 = (kP_2 + 5) % 8
    until (kP_2 * 1 + 5) % 8 == 7
end
kM = getgenv()
local kO_1 = kM.__tempo_gen or 0
__tempo_gen, kT, UserInputService, VirtualUser, HttpService, LocalPlayer, j7, kU, kH = nil, nil, nil, nil, nil, nil, nil, nil, nil
kM.__tempo_gen = kO_1 + 1
__tempo_gen = kM.__tempo_gen
kH = fn153
local kV = game:GetService("ReplicatedStorage")
if (kU or not LocalPlayer or (LocalPlayer or not kU) or not LocalPlayer and not VirtualUser and (not kU and not UserInputService) or (not UserInputService and not UserInputService and (kU and VirtualUser) or (LocalPlayer or UserInputService) and (kU or kU))) and ((not VirtualUser and not LocalPlayer or kU and UserInputService or (LocalPlayer and not VirtualUser or (not kU or not LocalPlayer))) and (VirtualUser and not LocalPlayer and (not kU or LocalPlayer) and (not VirtualUser or not LocalPlayer or not VirtualUser and not VirtualUser))) or not ((kU or not LocalPlayer or (LocalPlayer or not kU) or not LocalPlayer and not VirtualUser and (not kU and not UserInputService) or (not UserInputService and not UserInputService and (kU and VirtualUser) or (LocalPlayer or UserInputService) and (kU or kU))) and ((not VirtualUser and not LocalPlayer or kU and UserInputService or (LocalPlayer and not VirtualUser or (not kU or not LocalPlayer))) and (VirtualUser and not LocalPlayer and (not kU or LocalPlayer) and (not VirtualUser or not LocalPlayer or not VirtualUser and not VirtualUser)))) then
    kT = game:GetService("Players")
else
    kH = game:GetService("Players")
end
local Workspace = game:GetService("Workspace")
local kW_1
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = kT.LocalPlayer
local kY = "Rebirth Frenzy"
LocalPlayer:WaitForChild("leaderstats", 10)
LocalPlayer:WaitForChild("Upgrades", 10)
LocalPlayer:WaitForChild("Data", 10)
j7 = kV:WaitForChild("TappingRemote", 10)
kU = j7
if kU then
    local kO_2 = 0
    repeat
        local kP_3 = (vector.create((kO_2 * 1 + 3) % 11 + 1, (kO_2 * 1 + 8) % 13 + 1, (kO_2 * 13 + 12) % 17 + 1))
        kQ = (vector.create((kO_2 * 2 + 8) % 11 + 1, (kO_2 * 1 + 13) % 13 + 1, (kO_2 * 3 + 13) % 17 + 1))
        kR = (vector.create((kO_2 * 1 + 3) % 5 + 1, (kO_2 * 2 + 4) % 7 + 1, (kO_2 * 4 + 6) % 9 + 1))
        if math.abs((vector.angle(kP_3, kQ, kR))) - math.abs((vector.angle(kQ, kP_3, kR))) == 3 then
            j7 = kU:WaitForChild("Tap", 5)
        else
            kU = j7:WaitForChild("Tap", 5)
        end
        kO_2 = (kO_2 + 5) % 8
    until (kO_2 * 5 + 5) % 8 == 6
end
local kP_4 = j7
j4 = kU
if kP_4 then
    local kO_3 = 0
    repeat
        kQ = {
            "ktaofboae",
            "ylajtud",
            "ectmkdl",
            "nicwpmdad",
            "ylpgzdkar",
            "hpvhywhtaua",
            "ijxhhfteonx",
            "wzxm",
            "qaylkwslab",
            "lwgouke"
        }
        local qz = kO_3
        kR = kQ[qz % 10 + 1]
        if kR:len() <= kR:gsub("(.)", "%1%1", qz % 3 % 2 + 1):len() then
            kP_4 = j7:WaitForChild("ToggleAutoTap", 5)
        else
            j7 = kP_4:WaitForChild("ToggleAutoTap", 5)
        end
        kO_3 = (kO_3 + 2) % 4
    until (kO_3 * 3 + 0) % 4 == 2
end
j0, Rebirth, Upgrade, jQ, kR = nil, nil, nil, nil, nil
j0 = kP_4
Rebirth = kV:WaitForChild("Rebirth", 5)
Upgrade = kV:WaitForChild("Upgrade", 5)
if (kR or not jQ or false or (Upgrade or false or Upgrade and 3)) and not (kR or not jQ or false or (Upgrade or false or Upgrade and 3)) then
    kV = jQ:WaitForChild("EggHatchingRemote", 10)
else
    jQ = kV:WaitForChild("EggHatchingRemote", 10)
end
kR = jQ
if kR then
    local kO_4 = 3
    repeat
        if (kO_4 * 1 + 7) * 13 % 4 == ((kO_4 * 1 + 7) * 13 + 7) % 4 then
            jQ = kR:WaitForChild("HatchServer", 5)
        else
            kR = jQ:WaitForChild("HatchServer", 5)
        end
        kO_4 = (kO_4 + 3) % 8
    until (kO_4 * 5 + 4) % 8 == 2
end
kK, kQ = nil, nil
local kP_5 = 3
repeat
    if (kP_5 * 1 + 1) % 2 + 1 <= 1 then
        local qp = bit32.rrotate(bit32.bxor(bit32.lrotate(kP_5, 7), string.byte(tostring(kQ))), 6)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(qp, 449180629), 2679050336), (bit32.bxor(bit32.band(qp, 3845786666), 1682102195))), 2679050336), 1682102195) == qp then
            kK = kR
        else
            kR = kK
        end
        kP_5 = (kP_5 + 3) % 8
    else
        if (kP_5 * 2 + 5) * 10 % 3 == ((kP_5 * 2 + 5) * 10 + 6) % 3 then
            kQ = (kV:FindFirstChild("TappingGameModule"))
        else
            kV = (kQ:FindFirstChild("TappingGameModule"))
        end
        kP_5 = (kP_5 + 7) % 8
    end
until (kP_5 * 7 + 4) % 8 == 7
if kQ then
    local kO_6 = 1
    repeat
        local kP_6 = {
            "ddbfmhdseuvl",
            "kaxgigshj",
            "rwxjxmml",
            "bmcddpcsrumc",
            "dckxyxdz",
            "kgmgidxpb",
            "ersmfwtpdjns",
            "qvxmik"
        }
        if kP_6[(kO_6 * 52 + 110) % 8 + 1] <= kP_6[(kO_6 * 52 + 110) % 8 + 1] then
            kQ = require(kV:WaitForChild("TappingGameModule"))
        else
            kV = require(kQ:WaitForChild("TappingGameModule"))
        end
        kO_6 = (kO_6 + 3) % 8
    until (kO_6 * 1 + 7) % 8 == 3
end
kE, kR = nil, nil
local kP_7 = 1
repeat
    if (kP_7 * 1 + 1) % 2 + 1 <= 1 then
        local qm = bit32.rrotate(bit32.bxor(bit32.lrotate(kP_7, 15), string.byte(tostring(kR))), 11)
        if bit32.bxor(bit32.lrotate(bit32.bxor(qm, 1816396230), 26), 431034375) == bit32.lrotate(qm, 26) then
            kE = kQ
        else
            kQ = kE
        end
        kP_7 = (kP_7 + 5) % 16
    else
        local kO_8 = (vector.create((kP_7 * 1 + 9) % 11 + 1, (kP_7 * 4 + 4) % 13 + 1, (kP_7 * 6 + 14) % 17 + 1))
        kS = (vector.create((kP_7 * 2 + 9) % 11 + 1, (kP_7 * 9 + 3) % 13 + 1, (kP_7 * 4 + 17) % 17 + 1))
        kT = (vector.create((kP_7 * 6 + 4) % 11 + 1, (kP_7 * 1 + 6) % 13 + 1, (kP_7 * 2 + 6) % 17 + 1))
        kU = (vector.create((kP_7 * 2 + 4) % 11 + 1, (kP_7 * 6 + 12) % 13 + 1, (kP_7 * 3 + 16) % 17 + 1))
        if vector.dot(vector.cross(kO_8, kS), (vector.cross(kT, kU))) == vector.dot(kO_8, kT) * vector.dot(kS, kU) - vector.dot(kO_8, kU) * vector.dot(kS, kT) + 4 then
            kV = (kR:FindFirstChild("Upgrades"))
        else
            kR = (kV:FindFirstChild("Upgrades"))
        end
        kP_7 = (kP_7 + 1) % 16
    end
until (kP_7 * 11 + 11) % 16 == 8
if kR then
    local kO_9 = 3
    repeat
        local kP_8 = {
            "ommblv",
            "juv",
            "yjrzmph",
            "obeilmtqtds",
            "hwekp",
            "dszraehkb",
            "hczurtpthla",
            "iaz",
            "tyedzjjfb",
            "gkb",
            "bvlhfio",
            "tsags"
        }
        local qf = kO_9
        kQ = kP_8[qf % 12 + 1]
        if kQ:len() <= kQ:gsub("(.)", "%1%1", qf % 3 % 2 + 1):len() then
            kR = require(kV:WaitForChild("Upgrades"))
        else
            kV = require(kR:WaitForChild("Upgrades"))
        end
        kO_9 = (kO_9 + 2) % 4
    until (kO_9 * 3 + 0) % 4 == 3
end
kD, Eggs, kx = nil, nil, nil
kD = kR
Eggs = Workspace:FindFirstChild("Eggs")
kx = {}
if Eggs then
    for i, child in ipairs(Eggs:GetChildren()) do
        if child:IsA("Model") then
            table.insert(kx, child.Name)
        end
    end
    table.sort(kx)
end
if #kx == 0 then
    local kO_10 = 3
    repeat
        if (kO_10 * 3 + 1) * 17 % 4 == ((kO_10 * 3 + 1) * 17 + 12) % 4 then
            kx = {
                "Basic Egg",
                "Beach Egg",
                "Candy Egg",
                "Vortex Egg",
                "Heaven Egg",
                "Frozen Egg",
                "Toy Egg",
                "Jungle Egg",
                "Sakura Egg",
                "Magma Egg",
                "Rift Egg",
                "VIP Egg",
                "Magic Egg",
                "Mega Egg"
            }
        else
            kx = {
                "Candy Egg",
                "Magma Egg",
                "Frozen Egg",
                "VIP Egg",
                "Vortex Egg",
                "Basic Egg",
                "Rift Egg",
                "Sakura Egg",
                "Heaven Egg",
                "Mega Egg",
                "Jungle Egg",
                "Beach Egg",
                "Magic Egg",
                "Toy Egg"
            }
        end
        kO_10 = (kO_10 + 2) % 4
    until (kO_10 * 1 + 0) % 4 == 1
end
local kP_9 = kE
local kr = {}
if kP_9 then
    kP_9 = kE.Rebirths
end
if kP_9 then
    kP_9 = kE.Rebirths.Buttons
end
if kP_9 then
    for i, v in ipairs(kE.Rebirths.Buttons) do
        table.insert(kr, tostring(v))
    end
end
if #kr == 0 then
    local kO_11 = 0
    repeat
        local kP_10 = {
            "obmrq",
            "bvyvmcax",
            "mpfvjom",
            "sdhadspkbrid",
            "eixtuxr",
            "riy",
            "cbpdgv",
            "xynat",
            "qiyobf",
            "gcqubv"
        }
        if kP_10[(kO_11 * 40 + 37) % 10 + 1] < kP_10[(kO_11 * 40 + 37) % 10 + 1] then
            kr = { "250", "100", "1000", "1", "500", "50", "10" }
        else
            kr = { "1", "10", "50", "100", "250", "500", "1000" }
        end
        kO_11 = (kO_11 + 0) % 4
    until (kO_11 * 3 + 2) % 4 == 2
end
Library, SaveManager, Options, Toggles, kA, ky, kB, kv, Label, ka, jZ, kt, kk, j2, jT = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local k3 = {
    ["Walk Speed"] = "Speed",
    ["Max Pets"] = "MaxPets",
    Inventory = "Inventory",
    Jump = "Jump",
    Luck = "Luck",
    ["Hatch Speed"] = "HatchSpeed",
    ["More Taps"] = "More Taps",
    ["More Gems"] = "More Gems"
}
local k2 = { "Walk Speed", "Max Pets", "Inventory", "Jump", "Luck", "Hatch Speed", "More Taps", "More Gems" }
pcall(fn895)
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Options = Library.Options
Toggles = Library.Toggles
jZ = function(ae, af, ag)
    pcall(function()
        local lJ = ag
        local lN = if lJ then 1 else 0
        local lL = 118 * lN + 71 * (1 - lN)
        local lM = 391 * lN + 870 * (1 - lN)
        if not ((lL * 2457 + lM * 3168 + lL * lM) % 16777213 == 1574752) then
            lJ = 3
        end
        Library:Notify({ Title = ae, Description = af, Time = lJ })
    end)
end
kA = "https://discord.gg/K7Qxnxkk46"
ky = "https://discord.gg/K7Qxnxkk46"
kt = fn256
kk = fn805
local Window = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = kA, Copyable = true }, "|", kY },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local k_ = {
    Info = Window:AddTab("Info", "info"),
    Farming = Window:AddTab("Farming", "mouse-pointer-click"),
    Inventory = Window:AddTab("Inventory", "backpack"),
    Rebirth = Window:AddTab("Rebirth", "rotate-ccw"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
j2 = fn498
jT = fn521
kZ, kW_1, kB, kV = "#7fd47f", "#6ec1ff", "#e8a34d", "#8b93a3"
kv = "Unknown"
pcall(fn486)
kR = k_.Info:AddLeftGroupbox("Account", "circle-user")
kR:AddLabel(jT("User", LocalPlayer.Name, kZ), true)
kR:AddLabel(jT("Status", "Keyless", kZ), true)
kR:AddLabel(jT("Executor", kv, kZ), true)
kU = k_.Info:AddLeftGroupbox("Game Info", "gamepad-2")
kU:AddLabel(j2(kY .. " [" .. tostring(game.PlaceId) .. "]", kW_1), true)
kU:AddLabel(jT("Place ID", tostring(game.PlaceId), kW_1), true)
Label = kU:AddLabel(jT("Session time", "0s", kB), true)
if not kU and not Library or kU and not kU or (not Label and not Library or Library and not Label) or not (not kU and not Library or kU and not kU or (not Label and not Library or Library and not Label)) then
    ka = tostring(game.JobId)
else
    k2 = tostring(game.JobId)
end
kT = #ka > 18
if kT then
    local kO_12 = 7
    repeat
        local kP_12 = {
            "yfruo",
            "csvnb",
            "qqneinj",
            "enbw",
            "xqmjdhy",
            "ehkcl",
            "cnhi",
            "pxsk",
            "wysdpgtwaph",
            "bllrfcszkbur",
            "aaqnojmk",
            "uspezmnkhk"
        }
        if kP_12[(kO_12 * 61 + 42) % 12 + 1] <= kP_12[(kO_12 * 61 + 42) % 12 + 1] then
            kT = string.sub(ka, 1, 18) .. "..."
        else
            ka = string.sub(kT, 1, 18) .. "..."
        end
        kO_12 = (kO_12 + 6) % 8
    until (kO_12 * 7 + 4) % 8 == 7
end
local kO_13 = kT or ka
j_, kp, km, ki, kg, kf, kb, j9, DonationsGroup = nil, nil, nil, nil, nil, nil, nil, nil, nil
kU:AddLabel(jT("Server", kO_13, kV), true)
kU:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
j_ = os.clock()
task.spawn(worker)
local ScriptsGroup = k_.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(j2("Included in this hub", kV), true)
ScriptsGroup:AddLabel(j2(kY, kW_1), true)
local FeaturesGroup = k_.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(j2("Auto Click", kW_1), true)
FeaturesGroup:AddLabel(j2("Auto Upgrades", kB), true)
FeaturesGroup:AddLabel(j2("Auto Hatch", kZ), true)
FeaturesGroup:AddLabel(j2("Auto Rebirth", "#c9a0ff"), true)
FeaturesGroup:AddLabel(j2("Player Movement", kV), true)
local SocialsGroup = k_.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = kk })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = k_.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = kk })
kp = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
km = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
ki = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
kg = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
kf = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
kb = ""
j9 = ""
k6, k4, kT, kS, kR, kQ, kP_13 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
if (FeaturesGroup and not kT and (kT or FeaturesGroup) or (kT and not FeaturesGroup or kb and not kT)) and ((ScriptsGroup or FeaturesGroup) and (j_ or kT) and (kb and not j_ and (FeaturesGroup or kb))) or ((kb or FeaturesGroup) and (not kT and j_) or ("" or (kb or j_))) and ((not kT or ScriptsGroup or not kT and not kT) and (ScriptsGroup or not FeaturesGroup or false and FeaturesGroup)) or not ((FeaturesGroup and not kT and (kT or FeaturesGroup) or (kT and not FeaturesGroup or kb and not kT)) and ((ScriptsGroup or FeaturesGroup) and (j_ or kT) and (kb and not j_ and (FeaturesGroup or kb))) or ((kb or FeaturesGroup) and (not kT and j_) or ("" or (kb or j_))) and ((not kT or ScriptsGroup or not kT and not kT) and (ScriptsGroup or not FeaturesGroup or false and FeaturesGroup))) then
    DonationsGroup = k_.Info:AddRightGroupbox("Donations", "heart")
else
    k_ = DonationsGroup.Info:AddRightGroupbox("Donations", "heart")
end
DonationsGroup:AddLabel(j2("All donations are optional but appreciated.", kB), true)
DonationsGroup:AddLabel(j2("If you donate you get a special role, just PING after you donate.", kZ), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(j2("LTC / Litecoin", k6), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(j2("BTC / Bitcoin", k4), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(j2("ETH / Ethereum", kT), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(j2("USDT", kS), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(j2("Solana", kR), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(j2("PayPal", kQ), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(j2("Venmo", kP_13), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(j2("Don't have any of the listed currencies but still wanna donate?", kV), true)
DonationsGroup:AddLabel(j2("DM me and we'll work something out.", kW_1), true)
local FaqGroup = k_.Info:AddRightGroupbox("FAQ", "circle-help")
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
local ClickingGroup = k_.Farming:AddLeftGroupbox("Clicking", "mouse-pointer-click")
ClickingGroup:AddToggle("AutoClick", { Text = "Auto Click", Default = false })
ClickingGroup:AddSlider("AutoClickInterval", { Text = "Interval", Default = 0.01, Min = 0.01, Max = 10, Rounding = 2, Suffix = "s" })
ClickingGroup:AddToggle("UseServerAutoTap", { Text = "Use Server ToggleAutoTap", Default = false })
k_.Inventory:SetSubTabAlignment("Center")
kQ = k_.Inventory:AddSubTab("Upgrades", "trending-up")
local kP_14 = k_.Inventory:AddSubTab("Hatching", "egg")
kT = kQ:AddLeftGroupbox("Stat Upgrades", "trending-up")
kV = kQ:AddRightGroupbox("Resource Upgrades", "gem")
kS = { "Walk Speed", "Max Pets", "Inventory", "Jump" }
kU = { "Luck", "Hatch Speed", "More Taps", "More Gems" }
for i, v in ipairs(kS) do
    local kO_14 = k3[v]
    kT:AddToggle("AutoUpgrade_" .. kO_14, { Text = "Auto " .. v, Default = false })
    kT:AddSlider("Interval_" .. kO_14, { Text = v .. " Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
end
for i, v in ipairs(kU) do
    local kO_15 = k3[v]
    kV:AddToggle("AutoUpgrade_" .. kO_15, { Text = "Auto " .. v, Default = false })
    kV:AddSlider("Interval_" .. kO_15, { Text = v .. " Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
end
kS = kP_14:AddLeftGroupbox("Auto Hatch", "egg")
kS:AddToggle("AutoHatch", { Text = "Auto Hatch Eggs", Default = false })
kS:AddSlider("AutoHatchInterval", { Text = "Interval", Default = 0.01, Min = 0.01, Max = 10, Rounding = 2, Suffix = "s" })
kS:AddDropdown("SelectedEggs", {
    Values = kx,
    Default = 1,
    Multi = true,
    Text = "Eggs",
    Searchable = true,
    Expandable = true,
    ExpandColumns = 2
})
kS:AddToggle("HatchUseTriple", { Text = "Prefer Triple Hatch", Default = false })
kT = k_.Rebirth:AddRightGroupbox("Rebirth", "rotate-ccw")
kT:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
kT:AddSlider("AutoRebirthInterval", { Text = "Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
kT:AddDropdown("RebirthAmount", { Values = kr, Default = 1, Multi = false, Text = "Amount", Searchable = true })
kT:AddToggle("RebirthSmart", { Text = "Smart (highest affordable)", Default = false })
CurrentCamera, kl, kh, connection, connection2, kw, ko, jR, j6, ke, jW, kI, kc, jX, kC = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
fn127(k_.Farming)
fn127(kQ)
fn127(kP_14)
fn127(k_.Rebirth)
fn127(k_.Player)
local MovementGroup = k_.Player:AddRightGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
kV = k_.Player:AddLeftGroupbox("Fly", "feather")
kV:AddToggle("Fly", { Text = "Fly", Default = false })
kV:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
kw = fn433
ko = fn750
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn266)
Toggles.WalkSpeedEnabled:OnChanged(fn640)
jR = function(cE)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not cE)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not cE
        end
    end)
    if not cE then
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
Toggles.AntiGameplayPause:OnChanged(fn743)
task.spawn(antiGameplayPauseLoop)
kU = k_.Settings:AddLeftGroupbox("Menu", "wrench")
kl = tick()
kh = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local mK = v
        pcall(function()
            mK:Disable()
        end)
    end
end)
j6 = fn340
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
kU:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
kU:AddButton("Unload", onUnload)
kU:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
ThemeManager:SetFolder("TempoHub")
SaveManager:SetFolder("TempoHub/RebirthFrenzy")
kS = SaveManager:BuildConfigSection(k_.Settings)
ThemeManager:ApplyToTab(k_.Settings)
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:LoadDefault()
ke = fn114
jW = fn900
kI = fn643
kc = function(dJ)
    local nr
    nr = nil
    local ns = type(dJ) ~= "table" or type(dJ.idx) ~= "string" or type(dJ.type) ~= "string" or SaveManager.Ignore[dJ.idx]
    if ns then
        return false
    end
    nr = ke(dJ.type, dJ.idx)
    if not nr then
        return false
    end
    local ns_1 = pcall(function()
        if dJ.type == "Input" then
            if type(dJ.text) ~= "string" then
                return
            end
            nr:SetValue(dJ.text)
        elseif dJ.type == "ColorPicker" then
            nr:SetValueRGB(Color3.fromHex(dJ.value), dJ.transparency)
        elseif dJ.type == "KeyPicker" then
            nr:SetValue({ dJ.key, dJ.mode, dJ.modifiers })
            if dJ.mode == "Toggle" and dJ.toggled ~= nil then
                nr.Toggled = dJ.toggled
                nr:Update()
            end
        else
            nr:SetValue(dJ.value)
        end
    end)
    return ns_1
end
kS:AddDivider()
kS:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
kS:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
kS:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
pcall(fn422)
pcall(fn676)
pcall(fn821)
jX = fn621
kC = fn217
task.spawn(function()
    setthreadidentity(8)
    task.wait(1)
    local op = jQ and jQ:FindFirstChild("ToggleAutoDelete")
    local oo = op
    if oo then
        for i, v in ipairs({ "Common", "Uncommon", "Rare", "Epic", "Legendary" }) do
            local oy = v
            pcall(function()
                oo:FireServer(oy, false)
            end)
            task.wait(0.15)
        end
        pcall(function()
            oo:FireServer("Legendary", true)
        end)
        task.wait(0.15)
        pcall(function()
            oo:FireServer("Legendary", false)
        end)
    end
end)
task.spawn(autoClickIntervalLoop)
Toggles.UseServerAutoTap:OnChanged(fn122)
for i, v in ipairs(k2) do
    local jS, kN, kL
    jS = k3[v]
    kN = "AutoUpgrade_" .. jS
    kL = "Interval_" .. jS
    task.spawn(function()
        setthreadidentity(8)
        local oS = false
        repeat
            local oL = kH() and not Library.Unloaded
            if oL then
                local oL_1 = Toggles[kN]
                local oM = Options[kL]
                local oM_1 = oM and oM.Value or 1
                local oN_1 = oL_1
                if oN_1 then
                    oN_1 = oL_1.Value
                end
                if oN_1 then
                    local oL_2 = LocalPlayer:FindFirstChild("Upgrades") and LocalPlayer.Upgrades:FindFirstChild(jS)
                    local oJ = oL_2
                    local oL_3 = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Gems")
                    local oK
                    if kD then
                        pcall(function()
                            local getPrice = kD.getPrice
                            local oH = oJ and oJ.Value or 0
                            oK = getPrice(jS, oH)
                        end)
                    end
                    local oL_4 = true
                    if oK and oL_3 then
                        oL_4 = oL_3.Value >= oK
                        if oK == math.huge or oK == math.huge then
                            oL_4 = false
                        end
                    end
                    local oM_4 = kD
                    local oN_3 = false
                    if oM_4 then
                        oM_4 = kD.Upgrades
                    end
                    if oM_4 then
                        oM_4 = kD.Upgrades[jS]
                    end
                    if oM_4 then
                        local Max = kD.Upgrades[jS].Max
                        if oJ and Max and oJ.Value >= Max then
                            oN_3 = true
                        end
                    end
                    local oM_6 = not oN_3
                    if oM_6 ~= false then
                        oM_6 = oL_4
                    end
                    if oM_6 then
                        pcall(function()
                            return Upgrade:InvokeServer(jS)
                        end)
                    end
                end
                task.wait(oM_1)
                local oL_5 = not kH() or Library.Unloaded
                if oL_5 then
                    oS = true
                end
            else
                oS = true
            end
        until oS
    end)
end
local kO_16 = 3
repeat
    local kP_15 = {
        "jnzqfhsyso",
        "okeannmh",
        "ojjw",
        "wefr",
        "grpmomvbmdo",
        "xwnnuewdp",
        "pcobwvomems",
        "dccjle",
        "vzafiptymti",
        "hcobynoqb",
        "vaibkmy"
    }
    local pH = kO_16
    kQ = kP_15[pH % 11 + 1]
    if kQ:len() <= kQ:gsub("(.)", "%1%1", pH % 3 % 2 + 1):len() then
        task.spawn(function()
            setthreadidentity(8)
            local o1 = false
            repeat
                local oV = kH() and not Library.Unloaded
                if oV then
                    local oW = Options.AutoHatchInterval and Options.AutoHatchInterval.Value or 0.01
                    if Toggles.AutoHatch and Toggles.AutoHatch.Value then
                        local oU = kC()
                        if not oU then
                            local oW_8 = jX()
                            if oW_8 and oW_8[1] then
                                local oX_10 = Eggs and Eggs:FindFirstChild(oW_8[1])
                                oU = oX_10
                            end
                        end
                        if oU then
                            local oW_9 = oU:FindFirstChild("Price") and oU.Price.Value
                            local oX_11 = oW_9 or 0
                            local oX_12 = oU:FindFirstChild("Currency") and oU.Currency.Value
                            local oY = oX_12 or "Taps"
                            local oY_5 = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild(oY)
                            local oX_14 = oY_5
                            if oY_5 then
                                oY_5 = oX_14.Value >= oX_11
                            end
                            local oW_11 = oY_5
                            local oX_15 = LocalPlayer:FindFirstChild("Pets") and #LocalPlayer.Pets:GetChildren()
                            local oY_6 = oX_15 or 0
                            local oY_7 = LocalPlayer:FindFirstChild("Upgrades") and LocalPlayer.Upgrades:FindFirstChild("Inventory") and LocalPlayer.Upgrades.Inventory.Value
                            if not (oY_6 >= (oY_7 or 100)) then
                                if not not oW_11 then
                                    local oW_12 = pcall(function()
                                        if kK then
                                            return kK:InvokeServer(oU, "auto")
                                        end
                                    end)
                                    if not oW_12 then
                                        pcall(function()
                                            return kK:InvokeServer(oU.Name, "auto")
                                        end)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(oW)
                    local oV_6 = not kH() or Library.Unloaded
                    if oV_6 then
                        o1 = true
                    end
                else
                    o1 = true
                end
            until o1
        end)
        task.spawn(function()
            setthreadidentity(8)
            local pb = false
            repeat
                local o3 = kH() and not Library.Unloaded
                if o3 then
                    local o4 = Options.AutoRebirthInterval and Options.AutoRebirthInterval.Value or 1
                    if Toggles.AutoRebirth and Toggles.AutoRebirth.Value then
                        local o5 = Options.RebirthAmount and Options.RebirthAmount.Value or "1"
                        local o5_6 = Toggles.RebirthSmart and Toggles.RebirthSmart.Value
                        local o5_7 = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Taps")
                        local o5_8 = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Rebirths") and LocalPlayer.leaderstats.Rebirths.Value
                        local o5_9 = o5_8 or 0
                        local o8_3 = tonumber(o5) or 1
                        local o2 = o8_3
                        if o5_6 and kE then
                            local pe = #kr
                            local pd = -1
                            while false and pe <= 1 or true and pe >= 1 do
                                local pf = pe
                                local o4_14 = tonumber(kr[pf])
                                local o6_3 = kE.Rebirths.GetPrice(o4_14, o5_9)
                                if o5_7 and o5_7.Value >= o6_3 then
                                    o2 = o4_14
                                    break
                                end
                                pe += pd
                            end
                        end
                        local o4_15 = kE and kE.Rebirths.GetPrice(o2, o5_9)
                        local o5_10 = o4_15 or 0
                        local o4_16 = o5_7
                        if o4_16 then
                            o4_16 = o5_7.Value >= o5_10
                        end
                        if o4_16 then
                            pcall(function()
                                Rebirth:FireServer(o2)
                            end)
                        end
                    end
                    task.wait(o4)
                    local o3_6 = not kH() or Library.Unloaded
                    if o3_6 then
                        pb = true
                    end
                else
                    pb = true
                end
            until pb
        end)
        Library:OnUnload(fn296)
        getgenv().TempoHub = { Unload = fn808 }
        jZ("Tempo", "Loaded for Rebirth Frenzy", 3)
    else
        task.spawn(function()
            setthreadidentity(8)
            local o1 = false
            repeat
                local oV = kH() and not Library.Unloaded
                if oV then
                    local oW = Options.AutoHatchInterval and Options.AutoHatchInterval.Value or 0.01
                    if Toggles.AutoHatch and Toggles.AutoHatch.Value then
                        local oU = kC()
                        if not oU then
                            local oW_2 = jX()
                            if oW_2 and oW_2[1] then
                                local oX_2 = Eggs and Eggs:FindFirstChild(oW_2[1])
                                oU = oX_2
                            end
                        end
                        if oU then
                            local oW_3 = oU:FindFirstChild("Price") and oU.Price.Value
                            local oX_3 = oW_3 or 0
                            local oX_4 = oU:FindFirstChild("Currency") and oU.Currency.Value
                            local oY = oX_4 or "Taps"
                            local oY_1 = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild(oY)
                            local oX_6 = oY_1
                            if oY_1 then
                                oY_1 = oX_6.Value >= oX_3
                            end
                            local oW_5 = oY_1
                            local oX_7 = LocalPlayer:FindFirstChild("Pets") and #LocalPlayer.Pets:GetChildren()
                            local oY_2 = oX_7 or 0
                            local oY_3 = LocalPlayer:FindFirstChild("Upgrades") and LocalPlayer.Upgrades:FindFirstChild("Inventory") and LocalPlayer.Upgrades.Inventory.Value
                            if not (oY_2 >= (oY_3 or 100)) then
                                if not not oW_5 then
                                    local oW_6 = pcall(function()
                                        if kK then
                                            return kK:InvokeServer(oU, "auto")
                                        end
                                    end)
                                    if not oW_6 then
                                        pcall(function()
                                            return kK:InvokeServer(oU.Name, "auto")
                                        end)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(oW)
                    local oV_3 = not kH() or Library.Unloaded
                    if oV_3 then
                        o1 = true
                    end
                else
                    o1 = true
                end
            until o1
        end)
        task.spawn(function()
            setthreadidentity(8)
            local pb = false
            repeat
                local o3 = kH() and not Library.Unloaded
                if o3 then
                    local o4 = Options.AutoRebirthInterval and Options.AutoRebirthInterval.Value or 1
                    if Toggles.AutoRebirth and Toggles.AutoRebirth.Value then
                        local o5 = Options.RebirthAmount and Options.RebirthAmount.Value or "1"
                        local o5_1 = Toggles.RebirthSmart and Toggles.RebirthSmart.Value
                        local o5_2 = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Taps")
                        local o5_3 = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Rebirths") and LocalPlayer.leaderstats.Rebirths.Value
                        local o5_4 = o5_3 or 0
                        local o8_1 = tonumber(o5) or 1
                        local o2 = o8_1
                        if o5_1 and kE then
                            local pe = #kr
                            local pd = -1
                            while false and pe <= 1 or true and pe >= 1 do
                                local pf = pe
                                local o4_6 = tonumber(kr[pf])
                                local o6_1 = kE.Rebirths.GetPrice(o4_6, o5_4)
                                if o5_2 and o5_2.Value >= o6_1 then
                                    o2 = o4_6
                                    break
                                end
                                pe += pd
                            end
                        end
                        local o4_7 = kE and kE.Rebirths.GetPrice(o2, o5_4)
                        local o5_5 = o4_7 or 0
                        local o4_8 = o5_2
                        if o4_8 then
                            o4_8 = o5_2.Value >= o5_5
                        end
                        if o4_8 then
                            pcall(function()
                                Rebirth:FireServer(o2)
                            end)
                        end
                    end
                    task.wait(o4)
                    local o3_3 = not kH() or Library.Unloaded
                    if o3_3 then
                        pb = true
                    end
                else
                    pb = true
                end
            until pb
        end)
        kY:OnUnload(fn296)
        getgenv().TempoHub = { Unload = fn808 }
        Library("Tempo", "Loaded for " .. jZ, 3)
    end
    kO_16 = (kO_16 + 1) % 4
until (kO_16 * 3 + 0) % 4 == 0
end)(...)
