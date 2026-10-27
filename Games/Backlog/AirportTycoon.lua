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
getgenv().TempoHoodSubtitle = "AIRPORT TYCOON"
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
local kv
local lc
local Generation
local kB
local li
local k_
local Toggles
local lo
local connection
local k5
local LocalPlayer
local kT
local kA
local lh
local kZ
local ln
local km
local k4
local Packages
local lt
local ks
local la
local kS
local HttpService
local kY
local client
local UserInputService
local k3
local kL
local ls
local kr
local k9
local kR
local lf
local TempoAirportTycoon
local Options
local ll
local k2
local SaveManager
local lr
local k8
local connection3
local CurrentCamera
local kW
local kD
local VirtualUser
local k1
local kJ
local lq
local kp
local connection5
local kP
local ld
local kV
local connection2
local k0
local kI
local connection4
local ko
local Library
local lv
function fns.antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local qL = tick() - kL
            local qM = tick() - kI
            if qL >= 300 and qM >= 60 then
                pcall(ks)
            else
                if qL < 300 and qM >= 300 then
                    pcall(ks)
                end
            end
        end
    end
end
function fns.fn17()
    local mJ_1
    local mI_1
    mI_1, mJ_1 = pcall(function()
        return client:get({ "tycoon" })
    end)
    local mK = mI_1 and type(mJ_1) == "table"
    if mK then
        return mJ_1
    end
    return {}
end
function fns.fn24()
    local pC = tonumber(client:get({ "tycoon", "accumulatorBalance" })) or 0
    if pC > 0 then
        local pC_1 = lt()
        if pC_1 then
            ld(pC_1)
        end
    end
end
local function fn53()
    k2()
end
local function fn62()
    local Character = LocalPlayer.Character
    local pR = Character and Character:FindFirstChildOfClass("Humanoid")
    return pR
end
local function fn65()
    if not Toggles.WalkSpeedEnabled.Value then
        local qp = k5()
        if qp then
            qp.WalkSpeed = 16
        end
    end
end
local function onExportConfigToClipboard()
    local rq_1
    local rp_1
    rp_1, rq_1 = pcall(HttpService.JSONEncode, HttpService, kY())
    if not rp_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local rp_2 = setclipboard or toclipboard
    local rp_3 = type(rp_2) ~= "function" or not pcall(rp_2, rq_1)
    if rp_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn85(gA, gB)
    local qT_1 = (gA == "Toggle" and Toggles or Options)[gB]
    local qS_2 = type(qT_1) == "table" and qT_1.Type == gA
    return qS_2 and qT_1 or nil
end
local function fn88(bg, bh)
    return string.format('<font color="%s">%s</font>', bh, bg)
end
local function fn100(aQ)
    if not aQ then
        return nil
    end
    local Touch = aQ:FindFirstChild("Touch", true)
    local nh = Touch and Touch:IsA("BasePart")
    if nh then
        return Touch
    end
    return nil
end
local function fn109()
    kD()
end
local function fn142(a_, a0)
    if setclipboard then
        setclipboard(a_)
    elseif toclipboard then
        toclipboard(a_)
    end
    Library:Notify(a0)
end
local function fn143()
    local pK = Toggles.upgradeSecurity.Value or Toggles.upgradeGate.Value or Toggles.upgradeAmenity.Value
    local pO = if pK then 1 else 0
    local pM = 1930 * pO + 4012 * (1 - pO)
    local pN = 845 * pO + 2157 * (1 - pO)
    if not ((pM * 2750 + pN * 3788 + pM * pN) % 16777213 == 10139210) then
        pK = Toggles.upgradeRunway.Value
    end
    return pK
end
local function onCopyJoinScript_JobID()
    local ns = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, la)
    if setclipboard then
        setclipboard(ns)
    elseif toclipboard then
        toclipboard(ns)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn167()
    return Toggles.autoIncome.Value
end
local function onCopyUSDTAddress()
    kB(ll, "Copied USDT address")
end
local function fn173(aL)
    local nd = k1()
    if not nd then
        return nil
    end
    local Models = nd:FindFirstChild("Models")
    if Models then
        return Models:FindFirstChild(aL)
    end
    return nil
end
local function onInputChanged(ge)
    local UserInputType = ge.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        kL = tick()
    end
end
local function fn176()
    return Toggles.autoTrash.Value
end
local function fn186(bj, bk, bl)
    return string.format("<b>%s</b> %s %s", bj, kW("-", "#5a6070"), kW(bk, bl))
end
local function onJumpRequest()
    if Library.Unloaded or not Toggles then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local p4_2 = k5()
        if p4_2 then
            p4_2:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn221()
    lo(Toggles.AntiGameplayPause.Value)
end
local function fn249(aB, aC, aD)
    local m3 = {}
    local m5 = aB.components or {}
    for i, v in ipairs(m5) do
        local behaviors = v.behaviors
        local m5_1 = type(behaviors) == "table" and behaviors[aC] ~= nil
        if m5_1 then
            local m4_2 = not aD
            if not m4_2 then
                m4_2 = (v.upgradeLevel or 0) < aD
            end
            if m4_2 then
                table.insert(m3, v)
            end
        end
    end
    return m3
end
local function onRscripts()
    if setclipboard then
        setclipboard(k0)
    elseif toclipboard then
        toclipboard(k0)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn278()
    return Toggles.autoRebirth.Value
end
local function fn285()
    return Options.incomeInterval.Value
end
local function fn293()
    local mD = (tonumber(client:get({ "starTokens" })))
    local mH = if mD then 1 else 0
    local mF = 1601 * mH + 3107 * (1 - mH)
    local mG = 2710 * mH + 2448 * (1 - mH)
    if not ((mF * 3399 + mG * 536 + mF * mG) % 16777213 == 11233069) then
        mD = 0
    end
    return mD
end
local function fn310()
    local mB = tonumber(client:get({ "coins" })) or 0
    return mB
end
local function onRenderStepped(fz)
    if Library.Unloaded or not Toggles or not Options then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local qa_3 = k5()
        if qa_3 then
            qa_3.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local qa_5 = kV()
        local qb_1 = k5()
        if qa_5 and qb_1 then
            qb_1.PlatformStand = true
            local qb_2 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                qb_2 = qb_2 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                qb_2 = qb_2 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                qb_2 = qb_2 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                qb_2 = qb_2 + CurrentCamera.CFrame.RightVector
            end
            local qg = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if qg == 1 then
                qb_2 = qb_2 + Vector3.new(0, 1, 0)
            end
            local qj = if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
            if qj == 1 then
                qb_2 = qb_2 - Vector3.new(0, 1, 0)
            end
            qa_5.Velocity = Vector3.zero
            if qb_2.Magnitude > 0 then
                qa_5.CFrame = qa_5.CFrame + qb_2.Unit * Options.FlySpeed.Value * fz
            end
        end
    end
end
local function fn315()
    kS()
end
local function fn317(cn)
    if not LocalPlayer.Character then
        return false
    end
    local nE_1 = kA(cn, "IncomeAccumulator")
    local nF = false
    for i, v in ipairs(nE_1) do
        local nE_2 = k_(li(v.modelId))
        if nE_2 then
            kR(nE_2.Position, nE_2.Size.Y / 2 + 2)
            nF = true
            task.wait(1.2)
        end
    end
    return nF
end
local function worker()
    local ny_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local nx = math.floor(os.clock() - kT)
        if nx < 60 then
            ny_1 = nx .. "s"
        elseif nx < 3600 then
            ny_1 = string.format("%dm %ds", math.floor((nx) / (60)), nx % 60)
        else
            ny_1 = string.format("%dh %dm", math.floor((nx) / (3600)), math.floor((nx % 3600) / (60)))
        end
        lf:SetText(kP("Session time", ny_1, kv))
    end
end
local function fn345()
    pcall(function()
        Library:Unload()
    end)
end
local function fn347()
    return Toggles.autoRebirthUpg.Value
end
local function fn350()
    return Options.rebirthUpgInterval.Value
end
local function fn375()
    if tick() - kr < 15 then
        return
    end
    kr = tick()
    k3()
end
local function fn398()
    return Options.buyInterval.Value
end
local function onUnload()
    Library:Unload()
end
local function fn431(au, av)
    local Character = LocalPlayer.Character
    local mX = Character and Character:FindFirstChild("HumanoidRootPart")
    local mW_1 = mX
    if mX then
        mX = au
    end
    if mX then
        local new = CFrame.new
        local mZ = av
        local m2 = if mZ then 1 else 0
        local m0 = 3981 * m2 + 1673 * (1 - m2)
        local m1 = 2534 * m2 + 3459 * (1 - m2)
        if not ((m0 * 3102 + m1 * 4019 + m0 * m1) % 16777213 == 15843849) then
            mZ = 3
        end
        mW_1.CFrame = new(au + Vector3.new(0, mZ, 0))
    end
end
local function onImportConfigFromClipboardTex()
    local rv_1
    local rt = Options.SaveManager_ImportSource.Value
    local rt_1
    local rz = if rt then 1 else 0
    local rx = 812 * rz + 3596 * (1 - rz)
    local ry = 2327 * rz + 3900 * (1 - rz)
    if not ((rx * 815 + ry * 214 + rx * ry) % 16777213 == 3049282) then
        rt = ""
    end
    local ru = tostring(rt):match("^%s*(.-)%s*$")
    if ru == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    rt_1, rv_1 = pcall(HttpService.JSONDecode, HttpService, ru)
    local ru_1 = not rt_1 or type(rv_1) ~= "table" or type(rv_1.objects) ~= "table"
    if ru_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local rt_2 = 0
    for i, v in ipairs(rv_1.objects) do
        if lv(v) then
            rt_2 += 1
        end
    end
    if rt_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local rv_2 = rt_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(rt_2, rv_2), 6)
end
local function fn478()
    for i, child in ipairs(lr.Entities.Plots:GetChildren()) do
        if child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
            return child.Name
        end
    end
    return nil
end
local function fn493()
    local nl_1
    local nk_1
    if identifyexecutor then
        nl_1, nk_1 = identifyexecutor()
        local nm = nl_1 ~= ""
        local nn = type(nl_1) == "string" and nm
        if nn then
            local nm_1 = type(nk_1) == "string" and nk_1 ~= "" and nl_1 .. " " .. nk_1
            kp = nm_1 or nl_1
        end
    end
end
local function fn513()
    local Character = LocalPlayer.Character
    local pU = Character and Character:FindFirstChild("HumanoidRootPart")
    return pU
end
local function onCopyLitecoinAddress()
    kB(ls, "Copied Litecoin address")
end
local function fn543()
    return Toggles.autoBuy.Value
end
local function onCopyBitcoinAddress()
    kB(lq, "Copied Bitcoin address")
end
local function fn572()
    return Options.trashInterval.Value
end
local function fn576(gI, gJ)
    local Type = gJ.Type
    if Type == "Toggle" then
        return { idx = gI, type = "Toggle", value = gJ.Value == true }
    elseif Type == "Slider" then
        return { idx = gI, type = "Slider", value = tostring(gJ.Value) }
    elseif Type == "Dropdown" then
        return { idx = gI, type = "Dropdown", multi = gJ.Multi == true, value = gJ.Value }
    elseif Type == "Input" then
        local qX = gJ.Value or ""
        return { idx = gI, type = "Input", text = tostring(qX) }
    elseif Type == "ColorPicker" then
        return { idx = gI, type = "ColorPicker", value = gJ.Value:ToHex(), transparency = gJ.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = gI,
            type = "KeyPicker",
            mode = gJ.Mode,
            key = gJ.Value,
            modifiers = gJ.Modifiers,
            toggled = gJ.Toggled
        }
    else
        return nil
    end
end
local function fn592()
    return Options.upgradeInterval.Value
end
local function onCopySolanaAddress()
    kB(lh, "Copied Solana address")
end
local function fn638()
    local q2 = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local q3 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if q3 then
                local q3_1 = k8(k, v)
                if q3_1 then
                    q2[#q2 + 1] = q3_1
                end
            end
        end
    end
    table.sort(q2, function(gV, gW)
        if gV.type ~= gW.type then
            return gV.type < gW.type
        end
        return gV.idx < gW.idx
    end)
    return { objects = q2 }
end
local function fn644(I)
    if km[I] then
        return km[I]
    end
    for i, child in ipairs(Packages._Index:GetChildren()) do
        for i, child in ipairs(child:GetChildren()) do
            if string.find(child.Name, "networker", 1, true) then
                local remotes = child:FindFirstChild("_remotes")
                if remotes then
                    local mg = remotes:FindFirstChild(I)
                    if mg then
                        local mf_1 = { ev = mg:FindFirstChild("RemoteEvent"), fn = mg:FindFirstChild("RemoteFunction") }
                        km[I] = mf_1
                        return mf_1
                    end
                end
            end
        end
    end
    return nil
end
local function onInputBegan()
    kL = tick()
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            lo(true)
        end
    end
end
local function fn694()
    return TempoAirportTycoon.Generation == Generation
end
local function fn703()
    return Options.rebirthInterval.Value
end
local function onCopyEthereumAddress()
    kB(ln, "Copied Ethereum address")
end
local function fn740()
    connection4:Disconnect()
    connection5:Disconnect()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
end
local function fn741()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    kI = tick()
end
local function fn782()
    kB(k4, "Copied Discord invite to clipboard")
end
local function fn795()
    if not Toggles.Fly.Value then
        local qk = k5()
        if qk then
            qk.PlatformStand = false
        end
    end
end
local function onCopyVenmoLink()
    kB(k9, "Copied Venmo link")
end
local function onCopyPayPalLink()
    kB(lc, "Copied PayPal link")
end
local function fn824()
    lo(false)
end
local function fn827()
    kJ()
end
local function fn838(ba)
    local DiscordGroup = ba:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ko })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ko })
end
local function fn858()
    local AirportTycoonClientRuntime = lr:FindFirstChild("AirportTycoonClientRuntime")
    if AirportTycoonClientRuntime then
        return AirportTycoonClientRuntime:FindFirstChild(kZ())
    end
    return nil
end
local function onStepped()
    if Library.Unloaded or not Toggles then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local pW_3 = descendant:IsA("BasePart") and descendant.CanCollide
                if pW_3 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
km = nil
connection = nil
ko = nil
kp = nil
kr = nil
ks = nil
kv = nil
connection3 = nil
kA = nil
kB = nil
kD = nil
Options = nil
client = nil
Toggles = nil
kI = nil
kJ = nil
SaveManager = nil
kL = nil
Packages = nil
Library = nil
kP = nil
kR = nil
kS = nil
kT = nil
Generation = nil
kV = nil
kW = nil
TempoAirportTycoon = nil
kY = nil
kZ = nil
k_ = nil
k0 = nil
k1 = nil
k2 = nil
k3 = nil
k4 = nil
k5 = nil
connection5 = nil
k8 = nil
local kl, TycoonConfig, KitUtils, UpgradeConfig, RebirthUpgradeConfig, kz, RebirthConfig, kG, kN, kQ, k6
k9 = nil
la = nil
LocalPlayer = nil
lc = nil
ld = nil
CurrentCamera = nil
lf = nil
HttpService = nil
lh = nil
li = nil
connection2 = nil
VirtualUser = nil
ll = nil
UserInputService = nil
ln = nil
lo = nil
connection4 = nil
lq = nil
lr = nil
ls = nil
lt = nil
lv = nil
local lu, lz, lB, lD, lH, lI, lJ, lK, lL
local CollectingGroup
lr, lB, UserInputService, VirtualUser, HttpService, LocalPlayer, k4, k0 = nil, nil, nil, nil, nil, nil, nil, nil
local lw = game:GetService("Players")
if (lB or k0 or not lB and k0) and (lB and false or (not lB or not lB)) or not ((lB or k0 or not lB and k0) and (lB and false or (not lB or not lB))) then
    lz = game:GetService("ReplicatedStorage")
    lr = game:GetService("Workspace")
    lB = game:GetService("RunService")
else
    lr = game:GetService("ReplicatedStorage")
    lB = game:GetService("Workspace")
    lz = game:GetService("RunService")
end
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = lw.LocalPlayer
local lA = "Airport Tycoon"
k4 = "https://discord.gg/K7Qxnxkk46"
k0 = "https://discord.gg/K7Qxnxkk46"
local ly = getgenv()
lw = {}
local lx = ly.TempoAirportTycoon or lw
TempoAirportTycoon = nil
ly.TempoAirportTycoon = lx
TempoAirportTycoon = ly.TempoAirportTycoon
if type(TempoAirportTycoon.Unload) == "function" then
    pcall(TempoAirportTycoon.Unload)
end
lw = TempoAirportTycoon.Generation or 0
Generation, Packages, client, RebirthConfig, RebirthUpgradeConfig, UpgradeConfig, KitUtils, TycoonConfig, km, Library, SaveManager, Toggles, Options, kQ, lu, kZ, kN, kG, kz, lt, k1, kR, kA, li, k_, kB, ko = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
TempoAirportTycoon.Generation = lw + 1
Generation = TempoAirportTycoon.Generation
kQ = fn694
setthreadidentity(8)
Packages = lz:WaitForChild("Packages")
lx = lz:WaitForChild("Features")
client = require(Packages:WaitForChild("dataservice")).client
RebirthConfig = require(lx.rebirth.RebirthConfig)
RebirthUpgradeConfig = require(lx.rebirth.RebirthUpgradeConfig)
UpgradeConfig = require(lx.upgrades.UpgradeConfig)
KitUtils = require(lx.kits.KitUtils)
TycoonConfig = require(lx.tycoon.TycoonConfig)
km = {}
lu = fn644
kZ = fn478
kN = fn310
kG = fn293
kz = fns.fn17
lt = function()
    local mM
    mM = nil
    local mO_1
    mM = lu("Purchases")
    local mN = mM and mM.fn
    local mN_1
    if not mN then
        return nil
    end
    mN_1, mO_1 = pcall(function()
        return mM.fn:InvokeServer("requestOwnPlotSnapshot")
    end)
    local mP = mN_1 and type(mO_1) == "table"
    if mP then
        return mO_1
    end
    return nil
end
k1 = fn858
kR = fn431
kA = fn249
li = fn173
k_ = fn100
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
kB = fn142
ko = fn782
local lC = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = k4, Copyable = true }, "|", lA },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
TempoAirportTycoon.Unload = fn345
local lG = {
    Info = lC:AddTab("Info", "info"),
    Main = lC:AddTab("Main", "gavel"),
    Player = lC:AddTab("Player", "person-standing"),
    Settings = lC:AddTab("Settings", "settings")
}
lG.Collecting = lG.Main:AddSubTab("Collecting", "coins")
lG.Purchasing = lG.Main:AddSubTab("Purchasing", "shopping-bag")
lG.Upgrading = lG.Main:AddSubTab("Upgrading", "trending-up")
lG.Rebirth = lG.Main:AddSubTab("Rebirth", "refresh-cw")
local lE = fn838
for k, v in lG do
    if v ~= lG.Main then
        lE(v)
    end
end
lD, lC, kv, lz, kp, lH, lf, la, ly, kW, kP = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lw = 56
repeat
    lE = (lw * 4 + 2) % 9 + 1
    if lE <= 5 then
        if lE <= 3 then
            if lE <= 2 then
                if lE <= 1 then
                    local sV = bit32.rrotate(bit32.bxor(bit32.lrotate(lw, 31), string.byte(tostring(kP))), 22)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(sV, 2869129875), 18971534), (bit32.bxor(bit32.band(sV, 1425837420), 1472637717))), 18971534), 1472637717) ~= sV then
                        la = #ly > 18
                    else
                        ly = #la > 18
                    end
                    lw = (lw + 7) % 72
                else
                    local sf = bit32.rrotate(bit32.bxor(bit32.lrotate(lw, 30), string.byte(tostring(lf))), 14)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(sf, 4143573810), 4), 1872671535) == bit32.lrotate(sf, 4) then
                        kW = fn88
                    else
                        kv = fn88
                    end
                    lw = (lw + 70) % 72
                end
            else
                lI = {
                    "ktodtm",
                    "uxws",
                    "olujcf",
                    "lpdecse",
                    "doci",
                    "fiyesl",
                    "pmztxeuzacdj",
                    "yyfmobhes",
                    "vap",
                    "blt"
                }
                if lI[(lw * 91 + 8) % 10 + 1] < lI[(lw * 91 + 8) % 10 + 1] then
                    ly = fn186
                else
                    kP = fn186
                end
                lw = (lw + 61) % 72
            end
        elseif lE <= 4 then
            if lw * 29847215 + 3 + 6 >= lw * 29847215 + 3 + 6 + 5 then
                kW = "#7fd47f"
            else
                lD = "#7fd47f"
            end
            lw = (lw + 7) % 72
        else
            lI = (vector.create((lw * 6 + 7) % 11 + 1, (lw * 7 + 13) % 13 + 1, (lw * 2 + 1) % 17 + 1))
            lJ = (vector.create((lw * 2 + 3) % 11 + 1, (lw * 3 + 9) % 13 + 1, (lw * 7 + 16) % 17 + 1))
            lK = (vector.create((lw * 1 + 6) % 11 + 1, (lw * 2 + 3) % 13 + 1, (lw * 1 + 5) % 17 + 1))
            lL = (vector.create((lw * 3 + 4) % 5 + 1, (lw * 1 + 2) % 7 + 1, (lw * 2 + 3) % 9 + 1))
            if vector.dot(vector.cross(lI, (vector.cross(lJ, lK))), lL) == vector.dot(lJ * vector.dot(lI, lK) - lK * vector.dot(lI, lJ), lL) then
                lC = "#6ec1ff"
            else
                kp = "#6ec1ff"
            end
            lw = (lw + 16) % 72
        end
    elseif lE <= 7 then
        if lE <= 6 then
            lI = (vector.create((lw * 4 + 3) % 11 + 1, (lw * 4 + 3) % 13 + 1, (lw * 13 + 8) % 17 + 1))
            lJ = (vector.create((lw * 3 + 3) % 11 + 1, (lw * 1 + 9) % 13 + 1, (lw * 3 + 13) % 17 + 1))
            local ss = vector.cross(lI, lJ)
            local st = vector.dot(lI, lJ)
            if vector.dot(ss, ss) + st * st == vector.dot(lI, lI) * vector.dot(lJ, lJ) + 4 then
                lf = "#e8a34d"
            else
                kv = "#e8a34d"
            end
            lw = (lw + 70) % 72
        else
            lI = (vector.create((lw * 7 + 6) % 11 + 1, (lw * 5 + 1) % 13 + 1, (lw * 13 + 11) % 17 + 1))
            lJ = (vector.create((lw * 5 + 5) % 11 + 1, (lw * 9 + 9) % 13 + 1, (lw * 3 + 11) % 17 + 1))
            lK = (vector.create((lw * 1 + 2) % 11 + 1, (lw * 7 + 10) % 13 + 1, (lw * 8 + 6) % 17 + 1))
            lL = (vector.create((lw * 1 + 7) % 11 + 1, (lw * 4 + 10) % 13 + 1, (lw * 10 + 16) % 17 + 1))
            if vector.dot(vector.cross(lI, lJ), (vector.cross(lK, lL))) == vector.dot(lI, lK) * vector.dot(lJ, lL) - vector.dot(lI, lL) * vector.dot(lJ, lK) + 5 then
                lH = "#8b93a3"
            else
                lz = "#8b93a3"
            end
            lw = (lw + 52) % 72
        end
    elseif lE <= 8 then
        if (lw * 3 + 2) * 21 % 4 == ((lw * 3 + 2) * 21 + 7) % 4 then
            pcall(fn493)
            lD = lH.Info:AddLeftGroupbox("Account", "circle-user")
            lD:AddLabel(kp("User", lC.Name, LocalPlayer), true)
            lD:AddLabel(kp("Status", "Keyless", LocalPlayer), true)
            lD:AddLabel(kp("Executor", "Unknown", LocalPlayer), true)
            kP = lH.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            kP:AddLabel(kv(lf .. " [" .. tostring(game.PlaceId) .. "]", kW), true)
            kP:AddLabel(kp("Place ID", tostring(game.PlaceId), kW), true)
            lG = kP:AddLabel(kp("Session time", "0s", lA), true)
        else
            kp = "Unknown"
            pcall(fn493)
            lx = lG.Info:AddLeftGroupbox("Account", "circle-user")
            lx:AddLabel(kP("User", LocalPlayer.Name, lD), true)
            lx:AddLabel(kP("Status", "Keyless", lD), true)
            lx:AddLabel(kP("Executor", kp, lD), true)
            lH = lG.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            lH:AddLabel(kW(lA .. " [" .. tostring(game.PlaceId) .. "]", lC), true)
            lH:AddLabel(kP("Place ID", tostring(game.PlaceId), lC), true)
            lf = lH:AddLabel(kP("Session time", "0s", kv), true)
        end
        lw = (lw + 43) % 72
    else
        local sQ = bit32.rrotate(bit32.bxor(bit32.lrotate(lw, 5), string.byte(tostring(kv))), 5)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(sQ, 1048122445), 3059048489), (bit32.bxor(bit32.band(sQ, 3246844850), 2426377707))), 3059048489), 2426377707) ~= sQ then
            kp = tostring(game.JobId)
        else
            la = tostring(game.JobId)
        end
        lw = (lw + 43) % 72
    end
until (lw * 17 + 68) % 72 == 21
if ly then
    lw = 5
    repeat
        lx = {
            "qdxobxo",
            "bmekz",
            "wbmjbev",
            "bxhknlt",
            "uwksmthmqjn",
            "djphmzhbzpp",
            "btoh",
            "qoctheiwje",
            "ofemnhka",
            "qpvo",
            "wqdmp",
            "cbho",
            "ujzwzyymt",
            "ymabxdspl",
            "lyubeakpwwaw",
            "xxy"
        }
        if lx[(lw * 6 + 52) % 16 + 1] <= lx[(lw * 6 + 52) % 16 + 1] then
            ly = string.sub(la, 1, 18) .. "..."
        else
            la = string.sub(ly, 1, 18) .. "..."
        end
        lw = (lw + 5) % 8
    until (lw * 1 + 4) % 8 == 6
end
lw = ly or la
kT, ls, lq, ln, ll, lh, lc, k9, k6, CollectingGroup, kr, connection, connection2, CurrentCamera, connection3, kL, kI, connection4, connection5, lx, ld, kD, kS, k2, k3, kJ, k5, kV, lo, ks, kl, k8, kY, lv = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local lS = lw
lH:AddLabel(kP("Server", lS, lz), true)
lH:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
kT = os.clock()
task.spawn(worker)
lI = lG.Info:AddRightGroupbox("Scripts", "package")
lI:AddLabel(kW("Included in this hub", lz), true)
lI:AddLabel(kW(lA, lC), true)
lE = lG.Info:AddRightGroupbox("Features", "list")
lE:AddLabel(kW("Auto Collect / Clean", lC), true)
lE:AddLabel(kW("Auto Buy Buttons", kv), true)
lE:AddLabel(kW("Auto Upgrade", lD), true)
lE:AddLabel(kW("Auto Rebirth", lz), true)
ly = lG.Info:AddRightGroupbox("Socials", "link")
ly:AddButton({ Text = "Discord", Func = ko })
ly:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = lG.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = ko })
ls = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
lq = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
ln = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
ll = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
lh = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
lc = ""
k9 = ""
local lT = "#345d9d"
local lR = "#f7931a"
local lQ = "#627eea"
local lP = "#26a17b"
local lO = "#14f195"
lK = lG.Info:AddRightGroupbox("Donations", "heart")
lK:AddLabel(kW("All donations are optional but appreciated.", kv), true)
lK:AddLabel(kW("If you donate you get a special role, just PING after you donate.", lD), true)
lK:AddDivider()
lK:AddLabel(kW("LTC / Litecoin", lT), true)
lK:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
lK:AddLabel(kW("BTC / Bitcoin", lR), true)
lK:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
lK:AddLabel(kW("ETH / Ethereum", lQ), true)
lK:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
lK:AddLabel(kW("USDT", lP), true)
lK:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
lK:AddLabel(kW("Solana", lO), true)
lK:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
lK:AddLabel(kW("PayPal", "#0070ba"), true)
lK:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
lK:AddLabel(kW("Venmo", "#008cff"), true)
lK:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
lK:AddDivider()
lK:AddLabel(kW("Don't have any of the listed currencies but still wanna donate?", lz), true)
lK:AddLabel(kW("DM me and we'll work something out.", lC), true)
local FaqGroup = lG.Info:AddRightGroupbox("FAQ", "circle-help")
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
ld = fn317
kD = function()
    local AirportTycoonTrash = lr:FindFirstChild("AirportTycoonTrash")
    if not AirportTycoonTrash then
        return false
    end
    local nP = kZ()
    local nQ = "Trash_" .. nP .. "_"
    local nP_1 = 0
    for i, child in ipairs(AirportTycoonTrash:GetChildren()) do
        local nO_1 = child:IsA("Model") and string.find(child.Name, nQ, 1, true)
        if nO_1 then
            local CleanTrashPrompt = child:FindFirstChild("CleanTrashPrompt", true)
            local nO_2 = CleanTrashPrompt and CleanTrashPrompt:IsA("ProximityPrompt")
            if nO_2 then
                local Sphere = child:FindFirstChild("Sphere")
                local nR = Sphere and Sphere.Position
                local nO_4 = nR or child:GetPivot().Position
                kR(nO_4, 3)
                task.wait(0.8)
                local nO_5 = pcall(function()
                    fireproximityprompt(CleanTrashPrompt)
                end)
                if nO_5 then
                    nP_1 = nP_1 + 1
                end
                task.wait(1)
            end
        end
    end
    return nP_1 > 0
end
kS = function()
    local n0
    n0 = nil
    local nZ = lt()
    if not nZ then
        return
    end
    local n1 = {}
    local n3 = nZ.purchased or {}
    for i, v in ipairs(n3) do
        n1[v] = true
    end
    local n2_1 = tonumber(client:get({ "tycoon", "rebirths" })) or 0
    local getButtonDefinitions = KitUtils.getButtonDefinitions
    local n4 = nZ.kitName or TycoonConfig.DEFAULT_KIT
    local n5 = getButtonDefinitions(n4)
    local n2_3 = {}
    local n4_1 = {}
    local n6 = nZ.visibleButtons
    local ob = if n6 then 1 else 0
    local n9 = 1190 * ob + 2068 * (1 - ob)
    local oa = 2013 * ob + 502 * (1 - ob)
    if not ((n9 * 331 + oa * 2197 + n9 * oa) % 16777213 == 7211921) then
        n6 = n4_1
    end
    for i, v in ipairs(n6) do
        for i, v2 in ipairs(n5) do
            if v2.id == v and v2.terminalId then
                n2_3[v2.terminalId] = true
            end
        end
    end
    local n4_3 = {}
    for i, v in ipairs(n5) do
        if not n1[v.id] then
            local n5_1 = v.cost and v.cost > 0
            if n5_1 then
                n5_1 = (v.gamePassId or 0) == 0
            end
            if n5_1 then
                n5_1 = (v.devProductId or 0) == 0
            end
            if n5_1 then
                n5_1 = (v.starTokenCost or 0) == 0
            end
            if n5_1 then
                n5_1 = (v.rebirthsRequired or 0) <= n2_1
            end
            if n5_1 then
                if #n2_3 == 0 or n2_3[v.terminalId] then
                    local n5_3 = true
                    local n7 = v.requires or {}
                    for i, v in ipairs(n7) do
                        if not n1[v] then
                            n5_3 = false
                            break
                        end
                    end
                    if n5_3 then
                        table.insert(n4_3, { id = v.id, cost = v.cost })
                    end
                end
            end
        end
    end
    table.sort(n4_3, function(dh, di)
        return dh.cost > di.cost
    end)
    local n1_1 = kN()
    n0 = math.clamp(Options.buyBuffer.Value, 0, 100)
    local function n2_4(dn)
        return dn * (1 + n0 / 100)
    end
    local n_ = lu("Purchases")
    if not (n_ and n_.ev) then
        return
    end
    for i, v in ipairs(n4_3) do
        local oI = v
        if n1_1 >= n2_4(oI.cost) then
            pcall(function()
                n_.ev:FireServer("requestPurchase", nZ.plotId, oI.id)
            end)
            task.wait(0.6)
        end
    end
end
k6 = {
    upgradeSecurity = "SecurityLane",
    upgradeGate = "GateDesk",
    upgradeAmenity = "Amenity",
    upgradeRunway = "Runway"
}
k2 = function()
    local oQ_1
    local oP_1
    local oK = lt()
    if not oK then
        return
    end
    local oL = kN()
    local oJ = lu("Upgrades")
    if not (oJ and oJ.ev) then
        return
    end
    for k, v in pairs(k6) do
        if Toggles[k] and Toggles[k].Value then
            local oM_2 = kA(oK, v, 5)
            for i, v in ipairs(oM_2) do
                local o2 = v
                local oN
                local getUpgradeCost = UpgradeConfig.getUpgradeCost
                local oO = o2.upgradeLevel or 1
                oP_1, oQ_1 = pcall(getUpgradeCost, oO, nil, o2.modelId)
                if oP_1 then
                    oN = oQ_1
                end
                if oN and oN <= oL then
                    pcall(function()
                        oJ.ev:FireServer("requestUpgrade", oK.plotId, o2.modelId)
                    end)
                    task.wait(0.5)
                end
            end
        end
    end
end
k3 = function()
    local o4 = RebirthConfig.getRequirementStatus({ coins = kN(), tycoon = kz() })
    if not o4.ready then
        return false
    end
    local o3 = lu("Rebirths")
    if o3 and o3.ev then
        pcall(function()
            o3.ev:FireServer("requestRebirth")
        end)
        return true
    end
    return false
end
kJ = function()
    local pa = client:get({ "tycoon", "rebirth", "upgrades" })
    if type(pa) ~= "table" then
        pa = {}
    end
    local pb = kG()
    if pb <= 0 then
        return
    end
    local o9 = lu("RebirthUpgrades")
    if not (o9 and o9.ev) then
        return
    end
    local pd = RebirthUpgradeConfig.NODES or {}
    local pc_2 = {}
    for i, v in ipairs(pd) do
        if not pa[v.id] then
            local pd_1 = true
            local pf = v.requires or {}
            for i, v in ipairs(pf) do
                if not pa[v] then
                    pd_1 = false
                    break
                end
            end
            if pd_1 and v.cost <= pb then
                table.insert(pc_2, v)
            end
        end
    end
    table.sort(pc_2, function(ep, eq)
        return ep.cost < eq.cost
    end)
    for i, v in ipairs(pc_2) do
        local pz = v
        pcall(function()
            o9.ev:FireServer("requestPurchase", pz.id)
        end)
        task.wait(0.6)
    end
end
lL = function(ew, ex, ey)
    task.spawn(function()
        while true do
            local pA = kQ() and not Library.Unloaded
            if pA then
                if ew() then
                    pcall(ey)
                end
                task.wait(ex())
                continue
            end
            break
        end
    end)
end
if not TempoHubGroup and lx or not TempoHubGroup and not ld or (not ld and not ld or (not lx or connection5)) or not (not TempoHubGroup and lx or not TempoHubGroup and not ld or (not ld and not ld or (not lx or connection5))) then
    CollectingGroup = lG.Collecting:AddRightGroupbox("Collecting", "coins")
else
    lG = CollectingGroup.Collecting:AddRightGroupbox("Collecting", "coins")
end
CollectingGroup:AddToggle("autoIncome", { Text = "Auto Collect Income", Default = false })
CollectingGroup:AddSlider("incomeInterval", { Text = "Interval", Min = 0.1, Max = 10, Default = 2, Rounding = 1, Suffix = "s" })
local CleaningGroup = lG.Collecting:AddLeftGroupbox("Cleaning", "trash-2")
CleaningGroup:AddToggle("autoTrash", { Text = "Auto Clean Trash", Default = false })
CleaningGroup:AddSlider("trashInterval", { Text = "Interval", Min = 0.1, Max = 10, Default = 1.5, Rounding = 1, Suffix = "s" })
local BuyingGroup = lG.Purchasing:AddRightGroupbox("Buying", "shopping-bag")
BuyingGroup:AddToggle("autoBuy", { Text = "Auto Buy All Buttons", Default = false })
BuyingGroup:AddSlider("buyBuffer", { Text = "Money Buffer", Min = 0, Max = 20, Default = 10, Rounding = 1, Suffix = "%" })
BuyingGroup:AddSlider("buyInterval", { Text = "Interval", Min = 0.1, Max = 10, Default = 2, Rounding = 1, Suffix = "s" })
local AutoUpgradeGroup = lG.Upgrading:AddRightGroupbox("Auto Upgrade", "trending-up")
AutoUpgradeGroup:AddToggle("upgradeSecurity", { Text = "Upgrade Security Lanes", Default = false })
AutoUpgradeGroup:AddToggle("upgradeGate", { Text = "Upgrade Gate Desk", Default = false })
AutoUpgradeGroup:AddToggle("upgradeAmenity", { Text = "Upgrade Amenities", Default = false })
AutoUpgradeGroup:AddToggle("upgradeRunway", { Text = "Upgrade Runway", Default = false })
AutoUpgradeGroup:AddSlider("upgradeInterval", { Text = "Interval", Min = 0.1, Max = 10, Default = 3, Rounding = 1, Suffix = "s" })
local RebirthGroup = lG.Rebirth:AddRightGroupbox("Rebirth", "refresh-cw")
RebirthGroup:AddToggle("autoRebirth", { Text = "Auto Rebirth", Default = false })
RebirthGroup:AddSlider("rebirthInterval", { Text = "Interval", Min = 0.1, Max = 10, Default = 5, Rounding = 1, Suffix = "s" })
RebirthGroup:AddToggle("autoRebirthUpg", { Text = "Auto Buy Rebirth Upgrades", Default = false })
RebirthGroup:AddSlider("rebirthUpgInterval", { Text = "Upgrade Interval", Min = 0.1, Max = 10, Default = 4, Rounding = 1, Suffix = "s" })
lL(fn167, fn285, fns.fn24)
lL(fn176, fn572, fn109)
lL(fn543, fn398, fn315)
lL(fn143, fn592, fn53)
kr = 0
lL(fn278, fn703, fn375)
lL(fn347, fn350, fn827)
local MovementGroup = lG.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = lG.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
k5 = fn62
if false and (lI or not lI) or (false or lx or (lx or lE)) or not (false and (lI or not lI) or (false or lx or (lx or lE))) then
    kV = fn513
    connection = lB.Stepped:Connect(onStepped)
else
    lB = fn513
    kV = connection.Stepped:Connect(onStepped)
end
connection2 = UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
connection3 = lB.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn795)
Toggles.WalkSpeedEnabled:OnChanged(fn65)
lo = function(fQ)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not fQ)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not fQ
        end
    end)
    if not fQ then
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
Toggles.AntiGameplayPause:OnChanged(fn221)
task.spawn(antiGameplayPauseLoop)
Library:OnUnload(fn824)
lJ = lG.Settings:AddLeftGroupbox("Menu")
lJ:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
kL = tick()
kI = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local qC = v
        pcall(function()
            qC:Disable()
        end)
    end
end)
ks = fn741
connection4 = UserInputService.InputBegan:Connect(onInputBegan)
connection5 = UserInputService.InputChanged:Connect(onInputChanged)
lJ:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(fns.antiAfkLoop)
lJ:AddButton("Unload", onUnload)
Library:OnUnload(fn740)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(lG.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/AirportTycoon")
lx = SaveManager:BuildConfigSection(lG.Settings)
SaveManager:LoadAutoloadConfig()
kl = fn85
k8 = fn576
kY = fn638
lv = function(gY)
    local rj
    rj = nil
    local rk = type(gY) ~= "table" or type(gY.idx) ~= "string" or type(gY.type) ~= "string"
    local ro = if rk then 1 else 0
    local rm = 3900 * ro + 1979 * (1 - ro)
    local rn = 3357 * ro + 171 * (1 - ro)
    if not ((rm * 2609 + rn * 140 + rm * rn) % 16777213 == 6960167) then
        rk = SaveManager.Ignore[gY.idx]
    end
    if rk then
        return false
    end
    rj = kl(gY.type, gY.idx)
    if not rj then
        return false
    end
    local rk_1 = pcall(function()
        if gY.type == "Input" then
            if type(gY.text) ~= "string" then
                return
            end
            rj:SetValue(gY.text)
        elseif gY.type == "ColorPicker" then
            rj:SetValueRGB(Color3.fromHex(gY.value), gY.transparency)
        elseif gY.type == "KeyPicker" then
            rj:SetValue({ gY.key, gY.mode, gY.modifiers })
            if gY.mode == "Toggle" and gY.toggled ~= nil then
                rj.Toggled = gY.toggled
                rj:Update()
            end
        else
            rj:SetValue(gY.value)
        end
    end)
    return rk_1
end
if (false and not CollectingGroup or (false or not CollectingGroup)) and ("Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp" and (not ld and CollectingGroup)) or not ((false and not CollectingGroup or (false or not CollectingGroup)) and ("Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp" and (not ld and CollectingGroup))) then
    lx:AddDivider()
    lx:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    lx:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    lx:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
else
    lx:AddDivider()
    lx:AddInput("SaveManager_ImportSource", { AllowEmpty = true, Text = "Paste exported config here", Finished = true })
    lx:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    lx:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
end
end)(...)
