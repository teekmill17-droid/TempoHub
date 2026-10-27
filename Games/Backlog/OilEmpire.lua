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
getgenv().TempoHoodSubtitle = "OIL EMPIRE"
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
local DrillShop
local ke
local kX
local kE
local kk
local VirtualUser
local j1
local kK
local kq
local k8
local j7
local kQ
local kx
local kd
local kW
local kD
local kj
local k1
local Toggles
local kJ
local DecorationShop
local k7
local j6
local kP
local kw
local kc
local LocalPlayer
local kC
local ki
local k0
local j_
local kI
local ko
local ReplicatedStorage
local j5
local kO
local RefineryShop
local kb
local kU
local kB
local kh
local k_
local jZ
local Knit
local kn
local k5
local Label
local kN
local kt
local ka
local kT
local kA
local kg
local Workspace
local jY
local kG
local km
local k4
local j3
local kM
local TotemShop
local j9
local kS
local kz
local kf
local kY
local Options
local kF
local GameAssets
local k3
local j2
local kL
local kr
local j8
local kR
function fns.fn18()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local mT = leaderstats and leaderstats:FindFirstChild("Cash")
    local mS_1 = mT
    if mT then
        mT = mS_1.Value
    end
    return mT or 0
end
function fns.onUnload()
    j7:Unload()
end
function fns.onInputBegan()
    kJ = tick()
end
function fns.fn57(bD)
    local nl = kj()
    local nm = nl and type(nl.Stock) == "table" and nl.Stock[bD] ~= nil
    if nm then
        return nl.Stock[bD]
    end
    return nil
end
local function onInputChanged(gL)
    local UserInputType = gL.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        kJ = tick()
    end
end
local function fn124(bS)
    local nw_1
    local nu = GameAssets:FindFirstChild(bS, true)
    local nv = nu and nu:IsA("ModuleScript")
    local nv_1
    if nv then
        nv_1, nw_1 = pcall(require, nu)
        local nx = nv_1 and type(nw_1) == "table"
        if nx then
            return nw_1, nu
        end
        return nil, nil
    end
    return nil, nil
end
local function fn154(ax)
    local mw = Toggles[ax]
    return mw ~= nil and mw.Value == true
end
local function fn162()
    kE("Drill", "PlaceDrillItems")
end
local function fn163()
    local m7_1
    local m6_1
    m6_1, m7_1 = pcall(function()
        local m3 = Knit.GetController("DataController")
        local m4 = m3 and m3:GetReplica()
        local m3_1 = m4
        if m4 then
            m4 = m3_1.Data
        end
        return m4
    end)
    if m6_1 then
        return m7_1
    end
    return nil
end
local function fn166(fM)
    local DiscordGroup = fM:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = kW })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = kW })
end
local function fn168()
    local n2 = j_()
    local n3 = n2 and n2:FindFirstChild("PlaceArea")
    return n3
end
local function worker7()
    while not j7.Unloaded do
        if ka("AutoSellDrills") then
            pcall(k1)
        end
        if ka("AutoSellRefineries") then
            pcall(kU)
        end
        task.wait(jY("SellDelay", 0.5))
    end
end
local function fn179(al, am)
    return string.format('<font color="%s">%s</font>', am, al)
end
local function fn198(b_)
    local nz = k3(b_)
    local nA = nz and nz.Model
    if not nA then
        return 6, 6
    end
    local nA_1 = nA.PrimaryPart or nA:FindFirstChild("Primary")
    local nE = if nA_1 then 1 else 0
    local nC = 1143 * nE + 2511 * (1 - nE)
    local nD = 2746 * nE + 2274 * (1 - nE)
    if not ((nC * 1008 + nD * 953 + nC * nD) % 16777213 == 6907760) then
        nA_1 = nA:FindFirstChildWhichIsA("BasePart", true)
    end
    local nz_2 = nA_1
    if not nz_2 then
        return 6, 6
    end
    return nz_2.Size.X, nz_2.Size.Z
end
local function fn208()
    kE("Refinery", "PlaceRefineryItems")
end
local function fn218()
    kI("DecorationShop", DecorationShop, "BuyDecorationItems", false)
end
local function fn222()
    local pj = not kh
    local pk = kT() <= 0 or pj
    if pk then
        return
    end
    local pj_1 = jY("SellGasMinPrice", 1)
    if kx() < pj_1 then
        return
    end
    kG(kh.SellGas)
end
local function fn229(ds)
    if not ds or not kh then
        return false
    end
    local attr3 = ds:GetAttribute("ID")
    local oM_1 = ds:GetAttribute("ToolName") or ds.Name
    local oN = oM_1
    if type(oN) == "string" then
        oN = string.gsub(oN, "%s*%[x%d+%]$", "")
    end
    if not attr3 then
        return false
    end
    local oM_2 = kX(oN)
    if not oM_2 then
        return false
    end
    local Parent = ds.Parent
    local attr2 = ds:GetAttribute("Amount")
    local oP = kG(kh.PlaceBuilding, attr3, oM_2)
    if not oP then
        return false
    end
    task.wait(0.35)
    if not ds.Parent then
        return true
    end
    local attr = ds:GetAttribute("Amount")
    if attr2 ~= nil and attr ~= nil and attr < attr2 then
        return true
    end
    return ds.Parent ~= Parent
end
local function fn241()
    k8(kO, "Copied Discord invite to clipboard")
end
local function fn255(c6)
    local oo, op, oq, ot, ou, ox, oz, oA, oC, oE, oF
    local ow = 0
    while true do
        local ow_1 = 3764 - ow
        do
            if ow_1 < 3754 then
                if ow_1 < 3752 then
                    if ow_1 < 3749 then
                        if ow_1 < 3748 then
                            if ow_1 < 2830 then
                                break
                            elseif ow_1 < 3747 then
                                break
                            else
                                ow = if oE <= oC then 2 else 9
                            end
                        elseif ow_1 == 3748 then
                            oq, op = kz(c6)
                            ot = math.floor(oo.Size.X * 0.5) - 2
                            ou = math.floor(oo.Size.Z * 0.5) - 2
                            oz = -ot
                            ox = ot
                            ow = 1
                        else
                            ow = 12989
                            continue
                        end
                    elseif ow_1 < 3750 then
                        if ow_1 == 3749 then
                            oA = oz
                            ow = 11
                        else
                            ow = 15173
                            continue
                        end
                    elseif ow_1 < 3751 then
                        break
                    else
                        local ot_1 = oo.CFrame:PointToWorldSpace(Vector3.new(oA, 0, oF))
                        local ov_2 = j9(ot_1, oq, op)
                        ot = Vector3.new(ov_2.X, kc, ov_2.Z)
                        ow = if kD(ot, oq, op) then 10 else 12
                    end
                elseif ow_1 < 3753 then
                    if ow_1 == 3752 then
                        ow = 4
                    else
                        ow = 5095
                        continue
                    end
                elseif ow_1 == 3753 then
                    ot = -ou
                    oE = ot
                    oC = ou
                    ow = 17
                else
                    ow = 9581
                    continue
                end
            elseif ow_1 < 3761 then
                if ow_1 < 3757 then
                    if ow_1 < 3755 then
                        return CFrame.new(ot)
                    elseif ow_1 < 3756 then
                        ow = 7
                    else
                        op = oo:FindFirstChild("PlaceArea")
                        ow = 3
                    end
                elseif ow_1 < 3759 then
                    if ow_1 < 3758 then
                        oz += 2
                        ow = 1
                    elseif ow_1 == 3758 then
                        return nil
                    else
                        ow = 3761
                        continue
                    end
                elseif ow_1 < 3760 then
                    if ow_1 == 3759 then
                        return nil
                    end
                    ow = 154
                    continue
                elseif ow_1 == 3760 then
                    oE += 2
                    ow = 17
                else
                    ow = 16170
                    continue
                end
            elseif ow_1 < 3763 then
                if ow_1 < 3762 then
                    oo = op
                    ow = if not oo then 6 else 16
                else
                    oF = oE
                    ow = 13
                end
            elseif ow_1 < 5095 then
                if ow_1 < 3764 then
                    ow = if oz <= ox then 15 else 5
                elseif ow_1 < 4231 then
                    if ow_1 == 3764 then
                        oo = j_()
                        op = oo
                        ow = if op then 8 else 3
                    else
                        break
                    end
                else
                    break
                end
            else
                break
            end
        end
    end
end
local function fn277(aI)
    local mC = Options[aI]
    return mC and mC.Value or {}
end
local function fn280()
    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    for i, child in Plots:GetChildren() do
        local Configuration = child:FindFirstChild("Configuration")
        local na = Configuration and Configuration:FindFirstChild("Player")
        local m9_2 = na
        if na then
            na = m9_2.Value == LocalPlayer
        end
        if na then
            return child
        end
    end
    return nil
end
local function fn306()
    local pw = jZ()
    local px = j_()
    if not px then
        return
    end
    for i, v in ipairs(kq) do
        local py = not j3(v.Name) and pw >= v.Price
        if py then
            local py_1 = px.Zones:FindFirstChild(v.Name)
            local pz = py_1 and py_1:FindFirstChildWhichIsA("ProximityPrompt", true)
            local pz_1 = j8()
            if kh then
                kG(kh.OpenZone, v.Name)
            end
            if pz and pz_1 then
                local CFrame2 = pz_1.CFrame
                local Parent = pz.Parent
                if Parent:IsA("Attachment") then
                    pz_1.CFrame = CFrame.new(Parent.WorldPosition + Vector3.new(0, 3, 0))
                elseif Parent:IsA("BasePart") then
                    pz_1.CFrame = Parent.CFrame + Vector3.new(0, 3, 0)
                end
                task.wait(0.1)
                kY(pz)
                task.wait(0.35)
                pz_1.CFrame = CFrame2
            end
            task.wait(0.2)
            break
        end
    end
end
local function fn308(dm, dn)
    if not kg then
        return false
    end
    return kG(kg.Purchase, dm, dn)
end
local function fn338()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    kC = tick()
end
local function fn341(ej, ek, el, em)
    local pm = jZ()
    for k, v in ek do
        local pn = type(v) == "table" and v.Price and not v.NotSale and ko(el, k)
        if pn then
            local pn_1 = em and kd(k)
            if not pn_1 then
                local pn_2 = kr(k)
                if (pn_2 == nil or pn_2 > 0) and pm >= v.Price then
                    if j1(ej, k) then
                        pm -= v.Price
                        task.wait(0.15)
                    end
                end
            end
        end
    end
end
local function fn350(dG)
    if not dG or not kh then
        return false
    end
    return kG(kh.DeleteBuilding, dG.Name, "Sell")
end
local function worker()
    local l8_1
    repeat
        task.wait()
        pcall(function()
            kh = Knit.GetService("BaseService")
            kg = Knit.GetService("StoresService")
        end)
        l8_1 = kh and kg
    until l8_1
end
local function fn408()
    kI("DrillShop", DrillShop, "BuyDrillItems", false)
end
local function fn418()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local mW = leaderstats and leaderstats:FindFirstChild("Gasoline")
    local mV_1 = mW
    if mW then
        mW = mV_1.Value
    end
    return mW or 0
end
local function fn424(ao, ap, aq)
    return string.format("<b>%s</b> %s %s", ao, kM("-", "#5a6070"), kM(ap, aq))
end
local function fn432(bN)
    if bN == "Zone0" then
        return true
    end
    local nr = kj()
    local ns = nr and type(nr.Zones) == "table" and nr.Zones[bN] == true
    return ns
end
local function fn435()
    local GasPrice = ReplicatedStorage:FindFirstChild("GasPrice")
    local mY_1 = GasPrice and GasPrice.Value
    local m2 = if mY_1 then 1 else 0
    local m0 = 4055 * m2 + 1168 * (1 - m2)
    local m1 = 99 * m2 + 1713 * (1 - m2)
    if not ((m0 * 3487 + m1 * 3736 + m0 * m1) % 16777213 == 14911094) then
        mY_1 = 0
    end
    return mY_1
end
local function fn448(aC, aD)
    local mz = Options[aC]
    local mA = mz and tonumber(mz.Value)
    return mA or aD
end
local function worker4()
    while not j7.Unloaded do
        if ka("AutoCollectGas") then
            pcall(kt)
        end
        if ka("AutoSellGas") then
            pcall(k5)
        end
        if ka("AutoBuyZones") then
            pcall(kn)
        end
        task.wait(jY("FarmDelay", 0.35))
    end
end
local function worker2()
    local qk_1
    while true do
        task.wait(1)
        if j7.Unloaded then
            break
        end
        local qj = math.floor(os.clock() - k_)
        if qj < 60 then
            qk_1 = qj .. "s"
        elseif qj < 3600 then
            qk_1 = string.format("%dm %ds", math.floor((qj) / (60)), qj % 60)
        else
            qk_1 = string.format("%dh %dm", math.floor((qj) / (3600)), math.floor((qj % 3600) / (60)))
        end
        Label:SetText(kA("Session time", qk_1, ke))
    end
end
local function onRscripts()
    k8(kL, "Copied Rscripts profile to clipboard")
end
local function fn472()
    kI("RefineryShop", RefineryShop, "BuyRefineryItems", false)
end
local function fn476()
    select("#", "Unloaded!")
end
local function fn485()
    kF("Drill", "SellDrillItems", "SellDrillKeep")
end
local function fn486(cy, cz, cA)
    local n5 = ki()
    if not n5 then
        return cy
    end
    local CFrame = n5.CFrame
    local n7 = CFrame:PointToObjectSpace(cy) + n5.Size / 2
    local function n8(cG, cH)
        local cI = math.floor(cH / 2 * 100) / 100
        local cJ = math.floor(cG / 30) * 30
        return cJ + math.clamp(math.round((cG - cJ - cI) / 2) * 2 + cI, cI, 30 - cI)
    end
    local n9 = n8(n7.X, cz)
    local oa = n8(n7.Z, cA)
    return CFrame:PointToWorldSpace(Vector3.new(n9, 0.5, oa) - n5.Size / 2)
end
local function fn498()
    local qc_1
    local qb_1
    if identifyexecutor then
        qc_1, qb_1 = identifyexecutor()
        local qd = qc_1 ~= ""
        local qe = type(qc_1) == "string" and qd
        if qe then
            local qd_1 = type(qb_1) == "string" and qb_1 ~= "" and qc_1 .. " " .. qb_1
            kk = qd_1 or qc_1
        end
    end
end
local function fn502(aN)
    for k, v in pairs(aN) do
        if v then
            return true
        end
    end
    return false
end
local function fn503()
    local Character = LocalPlayer.Character
    local mQ = Character and Character:FindFirstChild("HumanoidRootPart")
    return mQ
end
local function onCopyJoinScript_JobID()
    local f2 = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, j2)
    k8(f2, "Copied join script to clipboard")
end
local function worker5()
    while not j7.Unloaded do
        if ka("AutoBuyDrills") then
            pcall(k4)
        end
        if ka("AutoBuyRefineries") then
            pcall(kQ)
        end
        if ka("AutoBuyTotems") then
            pcall(kK)
        end
        if ka("AutoBuyDecorations") then
            pcall(kw)
        end
        task.wait(jY("BuyDelay", 0.5))
    end
end
local function fn532(fn, fo, fp)
    local pU = math.max(0, math.floor(jY(fp, 0)))
    local pV = kP(fn)
    local pW = {}
    for i, v in ipairs(pV) do
        pV = v:GetAttribute("Name")
        local pX = pV and ko(fo, pV)
        if pX then
            local pY = pW[pV] or {}
            pW[pV] = pY
            table.insert(pW[pV], v)
        end
    end
    local p6 = false
    for k, v in pW do
        local p5 = 2
        while true do
            if p5 < 7 then
                if p5 < 3 then
                    if p5 < 1 then
                        pW = kf(pV)
                        p5 = 11
                    elseif p5 < 2 then
                        p5 = 9
                    else
                        p5 = 12
                    end
                elseif p5 < 5 then
                    if p5 < 4 then
                        p6 = true
                        p5 = 8
                    else
                        p5 = 13
                    end
                elseif p5 < 6 then
                    task.wait(0.2)
                    p5 = 1
                else
                    p5 = 13
                end
            elseif p5 < 10 then
                if p5 < 8 then
                    p5 = if #v > pU then 10 else 4
                elseif p5 < 9 then
                    break
                else
                    p5 = 12
                end
            elseif p5 < 12 then
                if p5 < 11 then
                    pV = table.remove(v)
                    pW = pV
                    p5 = if pW then 0 else 11
                else
                    p5 = if pW then 5 else 6
                end
            elseif p5 < 13 then
                p5 = 7
            else
                p5 = 8
            end
        end
        if p6 then
            break
        end
    end
end
local function fn541(aR, aS)
    local mN = kR(aR)
    if not kB(mN) then
        return true
    end
    return mN[aS] == true
end
local function fn584(ae, af)
    if setclipboard then
        setclipboard(ae)
    elseif toclipboard then
        toclipboard(ae)
    end
    j7:Notify(af)
end
local function fn592()
    kF("Refinery", "SellRefineryItems", "SellRefineryKeep")
end
local function fn595(bI)
    local no = kj()
    local np = no and type(no.Totems) == "table" and no.Totems[bI] == true
    return np
end
local function fn606(U, V)
    return U.Price < V.Price
end
local function fn621()
    j6:Disconnect()
    k7:Disconnect()
end
local function fn626(D)
    local md = {}
    for k, v in D do
        local me_1 = type(v) == "table" and v.Price and not v.NotSale
        if me_1 then
            local insert = table.insert
            local Price = v.Price
            local Tier = v.Tier
            local mh = v.LayoutOrder or 0
            insert(md, { Name = k, Price = Price, Tier = Tier, Order = mh })
        end
    end
    table.sort(md, function(I, J)
        return (I.Order or 0) < (J.Order or 0)
    end)
    local me_3 = {}
    for i, v in ipairs(md) do
        table.insert(me_3, v.Name)
    end
    return me_3, md
end
local function fn650()
    local o6 = jY("CollectMinStorage", 1)
    local o7 = ka("CollectOnlyFull")
    for i, v in ipairs(kP("Refinery")) do
        local o8 = v:GetAttribute("Storage") or 0
        local o8_1 = v:GetAttribute("MaxStorage") or 0
        local o8_2 = o8 >= o6
        if o7 then
            o8_2 = o8_1 > 0 and o8 >= o8_1
        end
        if o8_2 then
            local o8_3 = v.PrimaryPart or v:FindFirstChild("Primary") or v:FindFirstChildWhichIsA("BasePart", true)
            if o8_3 then
                j5(o8_3)
                task.wait(0.1)
            end
        end
    end
end
local function fn653(e3, e4)
    local pJ = kb()
    for i, v in ipairs(pJ) do
        local pJ_1 = v:GetAttribute("ToolName") or v.Name
        local pJ_2 = k3(pJ_1)
        local pL = pJ_2 and pJ_2.Type
        local pJ_3 = false
        if e3 == "Drill" then
            pJ_3 = pL == "Drill" or DrillShop[pJ_1] ~= nil
        elseif e3 == "Refinery" then
            pJ_3 = pL == "Refinery" or RefineryShop[pJ_1] ~= nil
        end
        local pL_3 = pJ_3 and ko(e4, pJ_1)
        if pL_3 then
            if k0(v) then
                task.wait(0.25)
                return
            end
        end
    end
end
local function fn668()
    kI("TotemShop", TotemShop, "BuyTotemItems", true)
end
local function fn673(ck)
    local nP = j_()
    local nQ = nP and nP:FindFirstChild("Buildings")
    if not nQ then
        return {}
    end
    local nQ_1 = {}
    for i, child in nQ:GetChildren() do
        local attr = child:GetAttribute("Type")
        if not ck or attr == ck then
            table.insert(nQ_1, child)
        end
    end
    return nQ_1
end
local function worker3()
    while not j7.Unloaded do
        task.wait(2)
        if ka("AntiAfk") then
            local qB = tick() - kJ
            local qC = tick() - kC
            if qB >= 300 and qC >= 60 then
                pcall(km)
            else
                if qB < 300 and qC >= 300 then
                    pcall(km)
                end
            end
        end
    end
end
local function fn686(cN, cO, cP)
    local oc = j_()
    local od = oc and oc:FindFirstChild("PlaceArea")
    if not oc or not od then
        return false
    end
    local od_2 = od.CFrame:PointToObjectSpace(cN)
    local of_1 = od.Size / 2
    local oe_1 = math.abs(od_2.X) > of_1.X - 1 or math.abs(od_2.Z) > of_1.Z - 1
    if oe_1 then
        return false
    end
    local od_3 = OverlapParams.new()
    od_3.FilterType = Enum.RaycastFilterType.Exclude
    od_3.FilterDescendantsInstances = { LocalPlayer.Character }
    local oe_2 = Workspace:GetPartBoundsInBox(CFrame.new(cN), Vector3.new(cO, 1, cP) * 0.8, od_3)
    for i, v in ipairs(oe_2) do
        local od_4 = v.Name == "Hitbox" and v.Parent and v.Parent:HasTag("Locked")
        if od_4 then
            return false
        end
        local Buildings = oc:FindFirstChild("Buildings")
        local oe_3 = Buildings and v:IsDescendantOf(Buildings)
        if oe_3 then
            return false
        end
    end
    return true
end
local function worker6()
    while not j7.Unloaded do
        if ka("AutoPlaceDrills") then
            pcall(kS)
        end
        if ka("AutoPlaceRefineries") then
            pcall(kN)
        end
        task.wait(jY("PlaceDelay", 0.35))
    end
end
Options = nil
jY = nil
jZ = nil
j_ = nil
Toggles = nil
j1 = nil
j2 = nil
j3 = nil
Label = nil
j5 = nil
j6 = nil
j7 = nil
j8 = nil
j9 = nil
ka = nil
kb = nil
kc = nil
kd = nil
ke = nil
kf = nil
kg = nil
kh = nil
ki = nil
kj = nil
kk = nil
GameAssets = nil
km = nil
kn = nil
ko = nil
DecorationShop = nil
kq = nil
kr = nil
TotemShop = nil
kt = nil
RefineryShop = nil
kw = nil
kx = nil
DrillShop = nil
kz = nil
kA = nil
kB = nil
kC = nil
kD = nil
kE = nil
kF = nil
kG = nil
Knit = nil
kI = nil
kJ = nil
kK = nil
kL = nil
kM = nil
kN = nil
kO = nil
kP = nil
kQ = nil
kR = nil
kS = nil
kT = nil
kU = nil
LocalPlayer = nil
kW = nil
kX = nil
kY = nil
Workspace = nil
k_ = nil
k0 = nil
k1 = nil
VirtualUser = nil
k3 = nil
k4 = nil
k5 = nil
ReplicatedStorage = nil
k7 = nil
k8 = nil
local lm, ln
ReplicatedStorage, VirtualUser, Workspace, LocalPlayer, kO, kL, Knit, DrillShop, RefineryShop, TotemShop, DecorationShop, GameAssets, kh, kg, kq = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local qP_14 = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
LocalPlayer = qP_14.LocalPlayer
local qP_12 = "Oil Empire"
kO = "https://discord.gg/K7Qxnxkk46"
kL = "https://discord.gg/K7Qxnxkk46"
Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local qP_17 = require(ReplicatedStorage:WaitForChild("GlobalVariables"))
DrillShop = require(ReplicatedStorage:WaitForChild("Shops"):WaitForChild("DrillShop"))
RefineryShop = require(ReplicatedStorage:WaitForChild("Shops"):WaitForChild("RefineryShop"))
TotemShop = require(ReplicatedStorage:WaitForChild("Shops"):WaitForChild("TotemShop"))
DecorationShop = require(ReplicatedStorage:WaitForChild("Shops"):WaitForChild("DecorationShop"))
GameAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("GameAssets")
task.spawn(worker)
local qP_4 = fn626
local qP_7 = qP_4(DrillShop)
local qP_1 = qP_4(RefineryShop)
local qP_11 = qP_4(TotemShop)
local qP_6 = qP_4(DecorationShop)
kq = {}
for k, v in qP_17.ZonePrices do
    table.insert(kq, { Name = k, Price = v })
end
kc, qP_14, j7, Toggles, Options, ke, k8, kW, kM, kA, ka, jY, kR, kB, ko, j8, jZ, kT, kx, kj, j_, kG, kr, kd, j3, k3, kz, kb, kP, ki, j9, kD, kX, j1, k0, kf, j5, kY, kt, k5, kI, k4, kQ, kK, kw, kn, kE, kS, kN, kF, k1, kU = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(kq, fn606)
kc = 9
if (((j_ or not j3) and (not j_ and not j_) or j3 and not kI and (not j3 and j_)) and ((j3 or not j_ or not j3 and not j_) and (kI and not j3 or (not j_ or j_))) or (kI and j_ and (j_ or kI) or not kI and j3 and (j3 or j3)) and ((kI and kI or not j3 and j3) and (kI and j3 and (j_ or not j_)))) and not (((j_ or not j3) and (not j_ and not j_) or j3 and not kI and (not j3 and j_)) and ((j3 or not j_ or not j3 and not j_) and (kI and not j3 or (not j_ or j_))) or (kI and j_ and (j_ or kI) or not kI and j3 and (j3 or j3)) and ((kI and kI or not j3 and j3) and (kI and j3 and (j_ or not j_)))) then
    j_ = ""
else
    qP_14 = ""
end
j7 = getgenv().Library
local qP_16 = getgenv().ThemeManager
local qP_8 = getgenv().SaveManager
Toggles = j7.Toggles
Options = j7.Options
k8 = fn584
kW = fn241
kM = fn179
if (not kD and not qP_14 and (not qP_14 or not kD) or (qP_14 and not kD or (not kD or not qP_14)) or (not qP_14 or not qP_14 or not qP_14 and qP_14 or (not qP_14 and not kD or kD and not kD))) and not (not kD and not qP_14 and (not qP_14 or not kD) or (qP_14 and not kD or (not kD or not qP_14)) or (not qP_14 or not qP_14 or not qP_14 and qP_14 or (not qP_14 and not kD or kD and not kD))) then
    ke = fn424
    kA = "#7fd47f"
    ln = "#6ec1ff"
    lm = "#e8a34d"
else
    kA = fn424
    ln = "#7fd47f"
    lm = "#6ec1ff"
    ke = "#e8a34d"
end
local qP_5 = "#8b93a3"
ka = fn154
jY = fn448
kR = fn277
kB = fn502
ko = fn541
j8 = fn503
jZ = fns.fn18
kT = fn418
kx = fn435
kj = fn163
j_ = fn280
kG = function(bz, ...)
    if not bz then
        return false
    end
    local nj = pcall(function(...)
        if type(bz.Fire) == "function" then
            bz:Fire(...)
        elseif type(bz.FireServer) == "function" then
            bz:FireServer(...)
        end
    end, ...)
    return nj
end
kr = fns.fn57
kd = fn595
j3 = fn432
k3 = fn124
kz = fn198
kb = function(b7)
    local b8
    b8 = {}
    local function b9(ca)
        if not ca then
            return
        end
        for i, child in ca:GetChildren() do
            if child:IsA("Tool") then
                local nF = child:GetAttribute("ToolName") or child.Name
                if not b7 or nF == b7 then
                    table.insert(b8, child)
                end
            end
        end
    end
    b9(LocalPlayer:FindFirstChild("Backpack"))
    b9(LocalPlayer.Character)
    return b8
end
kP = fn673
ki = fn168
j9 = fn486
kD = fn686
kX = fn255
j1 = fn308
k0 = fn229
kf = fn350
j5 = function(dK)
    local oU = j8()
    local oV = not oU or not dK or not dK:IsA("BasePart")
    if oV then
        return false
    end
    local CFrame = oU.CFrame
    oU.CFrame = dK.CFrame + Vector3.new(0, 3, 0)
    if firetouchinterest then
        pcall(function()
            firetouchinterest(oU, dK, 0)
            task.wait(0.05)
            firetouchinterest(oU, dK, 1)
        end)
    end
    task.wait(0.15)
    oU.CFrame = CFrame
    return true
end
kY = function(dS)
    local o_
    o_ = nil
    if not dS then
        return false
    end
    local o1 = dS.HoldDuration > 0 and dS.HoldDuration
    local o5 = if o1 then 1 else 0
    local o3 = 2974 * o5 + 886 * (1 - o5)
    local o4 = 941 * o5 + 3822 * (1 - o5)
    if not ((o3 * 253 + o4 * 2463 + o3 * o4) % 16777213 == 5868639) then
        o1 = 1
    end
    o_ = o1
    if fireproximityprompt then
        return pcall(function()
            fireproximityprompt(dS, o_)
        end)
    end
    return pcall(function()
        dS:InputHoldBegin()
        task.wait(o_ + 0.1)
        dS:InputHoldEnd()
    end)
end
kt = fn650
k5 = fn222
kI = fn341
k4 = fn408
kQ = fn472
kK = fn668
kw = fn218
kn = fn306
kE = fn653
kS = fn162
kN = fn208
kF = fn532
k1 = fn485
kU = fn592
local qP_9 = j7:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = kO, Copyable = true }, "|", qP_12 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local lo = {
    Info = qP_9:AddTab("Info", "info"),
    Main = qP_9:AddTab("Main", "gamepad-2"),
    Settings = qP_9:AddTab("Settings", "settings")
}
lo.Farm = lo.Main:AddSubTab("Farm", "droplets")
lo.Buy = lo.Main:AddSubTab("Buy", "shopping-cart")
lo.Place = lo.Main:AddSubTab("Place", "hammer")
lo.Sell = lo.Main:AddSubTab("Sell", "hand-coins")
qP_17 = fn166
for k, v in lo do
    if v ~= lo.Main then
        qP_17(v)
    end
end
kk, Label, j2 = nil, nil, nil
kk = "Unknown"
pcall(fn498)
qP_14 = lo.Info:AddLeftGroupbox("Account", "circle-user")
qP_14:AddLabel(kA("User", LocalPlayer.Name, ln), true)
qP_14:AddLabel(kA("Status", "Keyless", ln), true)
qP_14:AddLabel(kA("Executor", kk, ln), true)
local GameInfoGroup = lo.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameInfoGroup:AddLabel(kM(qP_12 .. " [" .. tostring(game.PlaceId) .. "]", lm), true)
GameInfoGroup:AddLabel(kA("Place ID", tostring(game.PlaceId), lm), true)
Label = GameInfoGroup:AddLabel(kA("Session time", "0s", ke), true)
j2 = tostring(game.JobId)
qP_9 = #j2 > 18
if qP_9 then
    qP_14 = 2
    repeat
        local rh = bit32.rrotate(bit32.bxor(bit32.lrotate(qP_14, 16), string.byte(tostring(qP_14))), 9)
        if bit32.bxor(bit32.lrotate(bit32.bxor(rh, 4038267126), 16), 284618931) == bit32.lrotate(rh, 16) then
            qP_9 = string.sub(j2, 1, 18) .. "..."
        else
            j2 = string.sub(qP_9, 1, 18) .. "..."
        end
        qP_14 = (qP_14 + 3) % 4
    until (qP_14 * 3 + 1) % 4 == 0
end
qP_14 = qP_9
local l1 = if qP_14 then 1 else 0
local l_ = 444 * l1 + 1453 * (1 - l1)
local l0 = 2547 * l1 + 1311 * (1 - l1)
if not ((l_ * 3348 + l0 * 2857 + l_ * l0) % 16777213 == 9894159) then
    qP_14 = j2
end
k_, kJ, kC, j6, k7, km = nil, nil, nil, nil, nil, nil
local lH = qP_14
GameInfoGroup:AddLabel(kA("Server", lH, qP_5), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
k_ = os.clock()
task.spawn(worker2)
local ScriptsGroup = lo.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(kM("Included in this hub", qP_5), true)
ScriptsGroup:AddLabel(kM(qP_12, lm), true)
local FeaturesGroup = lo.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(kM("Auto Collect", lm), true)
FeaturesGroup:AddLabel(kM("Auto Buy", ke), true)
FeaturesGroup:AddLabel(kM("Auto Place", ke), true)
FeaturesGroup:AddLabel(kM("Auto Sell", ln), true)
FeaturesGroup:AddLabel(kM("Auto Zones", lm), true)
FeaturesGroup:AddLabel(kM("Misc Utilities", qP_5), true)
local SocialsGroup = lo.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = kW })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = lo.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = kW })
local FaqGroup = lo.Info:AddRightGroupbox("FAQ", "circle-help")
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
local GasGroup = lo.Farm:AddLeftGroupbox("Gas", "droplets")
GasGroup:AddToggle("AutoCollectGas", { Text = "Auto Collect Gas", Default = false })
GasGroup:AddToggle("CollectOnlyFull", { Text = "Collect Only Full", Default = false })
GasGroup:AddSlider("CollectMinStorage", { Text = "Min storage", Default = 1, Min = 1, Max = 100000, Rounding = 0 })
GasGroup:AddToggle("AutoSellGas", { Text = "Auto Sell Gas", Default = false })
GasGroup:AddSlider("SellGasMinPrice", { Text = "Min gas price", Default = 1, Min = 1, Max = 15, Rounding = 1 })
GasGroup:AddSlider("FarmDelay", { Text = "Farm delay", Default = 0.35, Min = 0.1, Max = 3, Rounding = 2, Suffix = "s" })
local ZonesGroup = lo.Farm:AddRightGroupbox("Zones", "map")
ZonesGroup:AddToggle("AutoBuyZones", { Text = "Auto Buy Zones", Default = false })
local DrillsGroup = lo.Buy:AddLeftGroupbox("Drills", "pickaxe")
DrillsGroup:AddToggle("AutoBuyDrills", { Text = "Auto Buy Drills", Default = false })
DrillsGroup:AddDropdown("BuyDrillItems", { Text = "Drills", Values = qP_7, Multi = true, AllowNull = true, Default = {} })
local RefineriesGroup = lo.Buy:AddLeftGroupbox("Refineries", "warehouse")
RefineriesGroup:AddToggle("AutoBuyRefineries", { Text = "Auto Buy Refineries", Default = false })
RefineriesGroup:AddDropdown("BuyRefineryItems", { Text = "Refineries", Values = qP_1, Multi = true, AllowNull = true, Default = {} })
qP_17 = lo.Buy:AddRightGroupbox("Totems", "gem")
qP_17:AddToggle("AutoBuyTotems", { Text = "Auto Buy Totems", Default = false })
qP_17:AddDropdown("BuyTotemItems", { Text = "Totems", Values = qP_11, Multi = true, AllowNull = true, Default = {} })
qP_9 = lo.Buy:AddRightGroupbox("Decorations", "flower-2")
qP_9:AddToggle("AutoBuyDecorations", { Text = "Auto Buy Decorations", Default = false })
qP_9:AddDropdown("BuyDecorationItems", { Text = "Decorations", Values = qP_6, Multi = true, AllowNull = true, Default = {} })
qP_4 = lo.Buy:AddLeftGroupbox("Timing", "timer")
qP_4:AddSlider("BuyDelay", { Text = "Buy delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
local DrillsGroup = lo.Place:AddLeftGroupbox("Drills", "pickaxe")
DrillsGroup:AddToggle("AutoPlaceDrills", { Text = "Auto Place Drills", Default = false })
DrillsGroup:AddDropdown("PlaceDrillItems", { Text = "Drills", Values = qP_7, Multi = true, AllowNull = true, Default = {} })
local RefineriesGroup = lo.Place:AddRightGroupbox("Refineries", "warehouse")
RefineriesGroup:AddToggle("AutoPlaceRefineries", { Text = "Auto Place Refineries", Default = false })
RefineriesGroup:AddDropdown("PlaceRefineryItems", { Text = "Refineries", Values = qP_1, Multi = true, AllowNull = true, Default = {} })
local TimingGroup = lo.Place:AddLeftGroupbox("Timing", "timer")
TimingGroup:AddSlider("PlaceDelay", { Text = "Place delay", Default = 0.35, Min = 0.1, Max = 3, Rounding = 2, Suffix = "s" })
local DrillsGroup = lo.Sell:AddLeftGroupbox("Drills", "pickaxe")
DrillsGroup:AddToggle("AutoSellDrills", { Text = "Auto Sell Drills", Default = false })
DrillsGroup:AddDropdown("SellDrillItems", { Text = "Drills", Values = qP_7, Multi = true, AllowNull = true, Default = {} })
DrillsGroup:AddSlider("SellDrillKeep", { Text = "Keep amount", Default = 0, Min = 0, Max = 100, Rounding = 0 })
local RefineriesGroup = lo.Sell:AddRightGroupbox("Refineries", "warehouse")
RefineriesGroup:AddToggle("AutoSellRefineries", { Text = "Auto Sell Refineries", Default = false })
RefineriesGroup:AddDropdown("SellRefineryItems", { Text = "Refineries", Values = qP_1, Multi = true, AllowNull = true, Default = {} })
RefineriesGroup:AddSlider("SellRefineryKeep", { Text = "Keep amount", Default = 0, Min = 0, Max = 100, Rounding = 0 })
local TimingGroup = lo.Sell:AddLeftGroupbox("Timing", "timer")
TimingGroup:AddSlider("SellDelay", { Text = "Sell delay", Default = 0.5, Min = 0.1, Max = 5, Rounding = 2, Suffix = "s" })
local MenuGroup = lo.Settings:AddLeftGroupbox("Menu", "settings")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
j7.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", fns.onUnload)
j7:OnUnload(fn476)
qP_16:SetLibrary(j7)
qP_16:SetFolder("TempoHub")
qP_16:SaveDefault("Monochrome")
qP_16:ApplyToTab(lo.Settings)
qP_16:LoadDefault()
qP_8:SetLibrary(j7)
qP_8:IgnoreThemeSettings()
qP_8:SetIgnoreIndexes({ "MenuKeybind" })
qP_8:SetFolder("TempoHub/OilEmpire")
qP_8:BuildConfigSection(lo.Settings)
qP_8:LoadAutoloadConfig()
kJ = tick()
kC = tick()
if (not km or not kJ) and (kJ or km) and (kC or qP_9 or (qP_9 or kC)) or not ((not km or not kJ) and (kJ or km) and (kC or qP_9 or (qP_9 or kC))) then
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local qs = v
            pcall(function()
                qs:Disable()
            end)
        end
    end)
    km = fn338
    j6 = UserInputService.InputBegan:Connect(fns.onInputBegan)
    k7 = UserInputService.InputChanged:Connect(onInputChanged)
else
    pcall(function()
        for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
            local qs = v
            pcall(function()
                qs:Disable()
            end)
        end
    end)
    k7 = km.InputBegan:Connect(fns.onInputBegan)
    j6 = km.InputChanged:Connect(onInputChanged)
end
j7:OnUnload(fn621)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
j7:Notify("Oil Empire loaded")
end)(...)
