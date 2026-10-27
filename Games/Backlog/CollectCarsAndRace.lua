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
getgenv().TempoHoodSubtitle = "COLLECT CARS AND RACE"
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
local B4_8, B4_14, B4_18, B4_19, B4_20, B4_22, B4_26, B4_33
local PlotClient
local LocalPlayer
local sl
local rl
local r2
local q2
local Toggles
local sr
local qK
local q8
local rQ
local qQ
local se
local rD
local sk
local r1
local q1
local rJ
local qJ
local r7
local q7
local rP
local qP
local rw
local rd
local rC
local sj
local RacewayPath
local q0
local r6
local q6
local rO
local sc
local rc
local rU
local qU
local SpotConfig
local si
local ri
local Library
local so
local r5
local q5
local qN
local CarEconomy
local rb
local PlotConfig
local qT
local rh
local sn
local rn
local r4
local rM
local qM
local ra
local rz
local sg
local rg
local rY
local Options
local sm
local rm
local RollClock
local qL
local rs
local LuckLadderConfig
local q9
local ry
local CarRarities
function fns.fn13()
    return rJ:FindFirstChild("ParkingLot_" .. tostring(LocalPlayer.UserId))
end
function fns.fn31()
    if rw.raceBound then
        pcall(function()
            sk:UnbindFromRenderStep(rD)
        end)
        rw.raceBound = false
    end
    rw.raceEntered = false
end
function fns.fn35()
    if sm("AutoBuyRoll") then
        sj()
    end
end
function fns.fn55()
    local wH = if not sm("AutoCollectMoney") then 1 else 0
    if wH == 1 then
        return
    end
    if os.clock() - rw.lastCollectAt < PlotConfig.CollectCooldown then
        return
    end
    rw.lastCollectAt = os.clock()
    for k, v in rQ() do
        rc(v)
    end
    if LocalPlayer:GetAttribute("Driving") then
        return
    end
    local wB = rs()
    local wC = wB and wB.Parent
    local wD = wC
    if wC then
        wC = tonumber(wD:GetAttribute("StoredCash"))
    end
    if (wC or 0) < 1 then
        return
    end
    local ManualCollect = wB:FindFirstChild("ManualCollect")
    local wB_1 = ManualCollect and ManualCollect:FindFirstChildWhichIsA("BasePart", true)
    local wB_2 = q1()
    local wD_2 = wB_1 and wB_2 and not sm("AutoFarmRace")
    if wD_2 then
        wB_2.CFrame = wB_1.CFrame + Vector3.new(0, 4, 0)
    end
end
function fns.fn108(P)
    if P == nil then
        return nil
    elseif cloneref then
        return cloneref(P)
    else
        return P
    end
end
function fns.fn124()
    local xg = rd()
    for k, v in r7() do
        xg[#xg + 1] = v
    end
    table.sort(xg, function(gu, gv)
        if gu.oneIn ~= gv.oneIn then
            return gu.oneIn < gv.oneIn
        end
        return (gu.level or 0) < (gv.level or 0)
    end)
    return xg
end
function fns.fn146(a0)
    if typeof(a0) ~= "string" then
        return nil
    end
    local ti = CarRarities.tierOf(a0)
    return ti and ti.name or nil
end
function fns.fn149(cT, cU)
    local ux = q1()
    if not (ux and cT) then
        return false
    end
    local pivot = cT:GetPivot()
    if (ux.Position - pivot.Position).Magnitude <= cU then
        return true
    end
    ux.CFrame = pivot * CFrame.new(0, 4, 0)
    ux.AssemblyLinearVelocity = Vector3.zero
    return true
end
function fns.fn162()
    local tw = tonumber(sc:InvokeServer()) or 0
    rw.cash = tw
end
function fns.fn183()
    local uD = sr()
    local uE = uD and uD:FindFirstChild("RollProximity")
    return uE
end
function fns.fn195()
    local xX = q1()
    local Raceway = rJ:FindFirstChild("Raceway")
    if not (xX and Raceway) then
        return false
    end
    local xZ_1 = RaycastParams.new()
    xZ_1.FilterType = Enum.RaycastFilterType.Include
    xZ_1.FilterDescendantsInstances = { Raceway }
    return rJ:Raycast(xX.Position + Vector3.new(0, 2, 0), Vector3.new(0, -30, 0), xZ_1) ~= nil
end
function fns.fn201(dh)
    if not qU() then
        return
    end
    local uL = qN()
    if dh and not uL then
        pcall(function()
            qK:FireServer(true)
        end)
    else
        local uM_1 = not dh
        if uM_1 ~= false then
            uM_1 = uL
        end
        if uM_1 then
            pcall(function()
                qK:FireServer(false)
            end)
        end
    end
end
function fns.fn208(ck, cl)
    local cn = r4(ck)
    return cn[cl] == true
end
function fns.fn210()
    if not Toggles.AutoFarmRace.Value then
        qJ()
        pcall(function()
            qL:FireServer()
        end)
        pcall(function()
            so:FireServer()
        end)
    end
end
function fns.onOnClientEvent3(bx)
    if typeof(bx) == "table" then
        rw.tree = bx
    end
end
function fns.fn245()
    local ty = tonumber(r1:InvokeServer()) or 0
    rw.trophies = ty
end
function fns.worker()
    while not Library.Unloaded do
        if sm("AutoRoll") then
            pcall(q2)
        end
        if sm("AutoBuyRoll") then
            pcall(rm)
        end
        task.wait(0.2)
    end
end
function fns.fn263(cg)
    local t2 = Options[cg]
    if not t2 then
        return {}
    end
    return t2.Value or {}
end
function fns.worker3()
    while not Library.Unloaded do
        pcall(rP)
        task.wait(0.25)
    end
end
function fns.fn272()
    return LocalPlayer:GetAttribute("PassAutoRoll") == true
end
function fns.onOnClientEvent5(bB, bC, bD, bE, bF, bG)
    local tJ = tonumber(bC) or 1
    local offers = rw.offers
    local tL = bE == true
    local tM = bF == true
    local tN = os.clock()
    local tO = os.clock() + rh()
    local tP = bE
    if tP then
        local goldenExtra = RollClock.goldenExtra
        local tR = tonumber(LocalPlayer:GetAttribute("TreeCooldownDelta")) or 0
        local tS = tonumber(LocalPlayer:GetAttribute("PassRollSpeed")) or 1
        tP = goldenExtra(tR, tS)
    end
    local tP_1 = tO + (tP or 0)
    local tO_1 = tonumber(bG) or 0
    offers[tJ] = { name = bB, variant = bD, golden = tL, free = tM, at = tN, readyAt = tP_1 + tO_1 }
    rw.lastRollAt = os.clock()
end
function fns.fn287(fH)
    local wy = q1()
    if not (wy and fH) then
        return
    end
    if firetouchinterest then
        pcall(firetouchinterest, wy, fH, 0)
        pcall(firetouchinterest, wy, fH, 1)
    end
end
local function fn309()
    local vt_1
    local vs_1
    if os.clock() - rw.lastTreePull < 1.5 then
        return
    end
    rw.lastTreePull = os.clock()
    vs_1, vt_1 = pcall(function()
        return rl:InvokeServer()
    end)
    local vu = vs_1 and typeof(vt_1) == "table"
    if vu then
        rw.tree = vt_1
    end
end
local function fn331()
    local gy = ri()
    return gy[#gy]
end
local function onOnClientEvent4(bz)
    if typeof(bz) == "table" then
        rw.indexData = bz
    end
end
local function worker2()
    while not Library.Unloaded do
        if sm("AutoGear") then
            pcall(sl)
        end
        if sm("AutoUpgrade") then
            pcall(ra)
        end
        if sm("AutoUnlockSpots") then
            pcall(sg)
        end
        if sm("AutoClaimIndex") then
            pcall(q6)
        end
        if sm("AutoCollectMoney") then
            pcall(qT)
        end
        if sm("AutoSell") then
            pcall(se)
        end
        task.wait(0.35)
    end
end
local function fn408()
    local wO = qM()
    local wP = {}
    if not wO then
        return wP
    end
    for i, child in wO:GetChildren() do
        local wO_1 = child.Name == "ParkedCar" and child:GetAttribute("OwnerUserId") == LocalPlayer.UserId
        if wO_1 then
            local attr2 = child:GetAttribute("CarName")
            local attr = child:GetAttribute("ItemId")
            local wR = attr ~= nil
            local wS = typeof(attr2) == "string" and wR
            if wS then
                local wR_1 = #wP + 1
                local wS_1 = tonumber(child:GetAttribute("Level")) or 1
                wP[wR_1] = { source = "parked", id = attr, name = attr2, level = wS_1, oneIn = rY(attr2), tier = si(attr2) }
            end
        end
    end
    return wP
end
local function fn416()
    local vK = qM()
    if not vK then
        return nil
    end
    local vL
    for i, child in vK:GetChildren() do
        if child.Name == "UnlockSpotSign" then
            local vK_1 = tonumber(child:GetAttribute("SpotIndex"))
            if vK_1 then
                local vM = tonumber(child:GetAttribute("Price")) or SpotConfig.priceOf(vK_1)
                if not vL or vK_1 < vL.index then
                    vL = { index = vK_1, price = vM, sign = child }
                end
            end
        end
    end
    return vL
end
local function fn417()
    local tp = (tonumber(LocalPlayer:GetAttribute("TreeCooldownDelta")))
    local tv = if tp then 1 else 0
    local tt = 3487 * tv + 3212 * (1 - tv)
    local tu = 2072 * tv + 957 * (1 - tv)
    if not ((tt * 178 + tu * 4013 + tt * tu) % 16777213 == 16160686) then
        tp = 0
    end
    local tq = tp
    local tp_1 = tonumber(LocalPlayer:GetAttribute("PassRollSpeed")) or 1
    return RollClock.cooldown(tq, tp_1)
end
local function fn435()
    return r2
end
local function fn437()
    local tc_1
    local tb = rw.kit and rw.kit.Parent
    local tb_1
    if tb then
        return rw.kit
    end
    tb_1, tc_1 = pcall(function()
        return PlotClient.waitForKit()
    end)
    if tb_1 and tc_1 then
        rw.kit = tc_1
        return tc_1
    end
    return nil
end
local function fn440(b7, b8, b9)
    return string.format("<b>%s</b> %s %s", b7, q9("-", "#5a6070"), q9(b8, b9))
end
local function fn469(h8)
    local DiscordGroup = h8:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = rn })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = rn })
end
local function fn504(a5)
    local tl = CarRarities.get(a5)
    return tl and tl.oneIn or 2
end
local function fn510(bY, bZ)
    if setclipboard then
        setclipboard(bY)
    elseif toclipboard then
        toclipboard(bY)
    end
    Library:Notify(bZ)
end
local function fn595(ba, bb, bc)
    if bc then
        return 0
    end
    return CarEconomy.valueOf(ba) * CarEconomy.variantValueMult(bb)
end
local function fn663()
    return LocalPlayer:GetAttribute("AutoRollOff") == nil
end
local function fn678()
    rz(q8, "Copied Discord invite to clipboard")
end
local function fn691()
    if sm("AutoBuyRoll") then
        sj()
    end
end
local function onOnClientEvent2(bu)
    local tF = tonumber(bu) or rw.trophies
    rw.trophies = tF
end
local function fn706()
    local Character = LocalPlayer.Character
    local tg = Character and Character:FindFirstChild("HumanoidRootPart")
    return tg
end
local function fn711()
    if not sm("AutoRoll") then
        return
    end
    q7(true)
    local vj = rh()
    if os.clock() - rw.lastRollAt < vj then
        return
    end
    rO()
end
local function fn731()
    local wi = rs()
    if not wi then
        return {}
    end
    local wj = {}
    for k, v in { "ManualCollect", "Autocollect" } do
        local wk = wi:FindFirstChild(v)
        if wk then
            for i, descendant in wk:GetDescendants() do
                if descendant:IsA("BasePart") then
                    wj[#wj + 1] = descendant
                end
            end
        end
    end
    return wj
end
local function fn732()
    local xO = rw.racePath
    local xT = if xO then 1 else 0
    local xR = 2701 * xT + 1223 * (1 - xT)
    local xS = 1349 * xT + 2771 * (1 - xT)
    if not ((xR * 1377 + xS * 3065 + xR * xS) % 16777213 == 11497611) then
        xO = RacewayPath.build()
    end
    local xP = xO
    rw.racePath = xP
    if xP then
        local xO_1 = xP.startS or 0
        return xP:frame(xO_1, 0, 5)
    end
    local Raceway = rJ:FindFirstChild("Raceway")
    local xP_1 = Raceway and Raceway:FindFirstChild("StartLine")
    if xP_1 then
        return xP_1:GetPivot() + Vector3.new(0, 6, 0)
    end
    return CFrame.new(-217.5, 22, 0)
end
local function fn742()
    local uJ = qU() and qN()
    if uJ then
        return
    end
    if sm("AutoRollTeleportNear") then
        local uJ_1 = sr()
        if uJ_1 then
            q5(uJ_1, 6)
            task.wait(0.12)
        end
    end
    local uJ_2 = r6()
    if not uJ_2 then
        return
    end
    if fireproximityprompt then
        pcall(fireproximityprompt, uJ_2)
    end
end
local function fn757()
    if not sm("AutoGear") then
        return
    end
    if os.clock() - rw.lastGearAt < 0.5 then
        return
    end
    local vl = (LocalPlayer:GetAttribute("LadderReqText"))
    local vr = if vl then 1 else 0
    local vp = 3027 * vr + 3927 * (1 - vr)
    local vq = 3512 * vr + 1795 * (1 - vr)
    if not ((vp * 2062 + vq * 3569 + vp * vq) % 16777213 == 12629613) then
        vl = ""
    end
    if vl ~= "" then
        return
    end
    local Tiers = LuckLadderConfig.Tiers
    local vm = tonumber(LocalPlayer:GetAttribute("LadderTiers")) or 0
    local vn = Tiers[vm + 1]
    if not vn then
        return
    end
    if vn.cost > 0 and rw.cash < vn.cost then
        return
    end
    if (vn.trophies or 0) > 0 and rw.trophies < vn.trophies then
        return
    end
    rw.lastGearAt = os.clock()
    pcall(function()
        sn:FireServer()
    end)
end
local function fn799(cc)
    return Toggles[cc] and Toggles[cc].Value == true
end
local function fn870()
    if not sm("AutoFarmRace") then
        if rw.raceEntered or rw.raceBound then
            qJ()
            pcall(function()
                qL:FireServer()
            end)
            pcall(function()
                so:FireServer()
            end)
        end
        return
    end
    local x9 = if LocalPlayer:GetAttribute("Driving") then 1 else 0
    if x9 == 1 then
        r5()
        rw.raceEntered = true
        return
    end
    qJ()
    if not qQ() then
        return
    end
    if rg() then
        return
    end
    if os.clock() - rw.lastRaceTp < 2.5 then
        return
    end
    local x5_2 = q1()
    if not x5_2 then
        return
    end
    rw.lastRaceTp = os.clock()
    x5_2.CFrame = rU()
    x5_2.AssemblyLinearVelocity = Vector3.zero
end
local function fn900()
    local us_1
    local ur_1
    if os.clock() - rw.lastOfferPull < 1.25 then
        return
    end
    rw.lastOfferPull = os.clock()
    ur_1, us_1 = pcall(function()
        return rb:InvokeServer()
    end)
    if ur_1 then
        qP(us_1)
    end
end
local function fn905()
    if Toggles.AutoBuyRoll.Value then
        sj()
    end
end
local function fn922()
    local uA = rs()
    if not uA then
        return nil
    end
    local Pedestal = uA:FindFirstChild("Pedestal")
    local uA_1 = Pedestal and Pedestal:FindFirstChild("Button")
    return uA_1
end
local function fn957(cp)
    local t6 = typeof(cp) ~= "table" or typeof(cp.name) ~= "string"
    if t6 then
        return false
    end
    local t6_1 = cp.variant == "Chroma" and sm("BuyChroma")
    if t6_1 then
        return true
    end
    local t6_2 = si(cp.name)
    local t7 = t6_2 and rM("BuyRarity", t6_2)
    return t7
end
local function onOnClientEvent(br)
    local tA = (tonumber(br))
    local tE = if tA then 1 else 0
    local tC = 302 * tE + 3657 * (1 - tE)
    local tD = 1605 * tE + 1567 * (1 - tE)
    if not ((tC * 3876 + tD * 3045 + tC * tD) % 16777213 == 6542487) then
        tA = rw.cash
    end
    rw.cash = tA
end
local function fn1050()
    local v__1
    local vZ_1
    if os.clock() - rw.lastIndexPull < 1.5 then
        return
    end
    rw.lastIndexPull = os.clock()
    vZ_1, v__1 = pcall(function()
        return q0:InvokeServer()
    end)
    local v0 = vZ_1 and typeof(v__1) == "table"
    if v0 then
        rw.indexData = v__1
    end
end
local function onOnClientEvent6(bN, bO, bP)
    if bP then
        local offers = rw.offers
        local tV = tonumber(bN) or 1
        offers[tV] = nil
    end
end
local function fn1061(b4, b5)
    return string.format('<font color="%s">%s</font>', b5, b4)
end
local function fn1078(cy)
    if typeof(cy) ~= "table" then
        return
    end
    for k, v in cy do
        local uc = tonumber(k)
        local ud = typeof(v) == "string" and uc
        if ud then
            local ud_1 = rw.offers[uc]
            local ue_1 = not ud_1
            local uq = if ue_1 then 1 else 0
            local uo = 2439 * uq + 560 * (1 - uq)
            local up = 1314 * uq + 1316 * (1 - uq)
            if not ((uo * 4041 + up * 2225 + uo * up) % 16777213 == 15984495) then
                ue_1 = ud_1.name ~= v
            end
            if ue_1 then
                local offers = rw.offers
                local uf = ud_1 and ud_1.variant
                local ud_2 = ud_1 and ud_1.free or false
                offers[uc] = { name = v, variant = uf, free = ud_2, at = os.clock(), readyAt = os.clock() }
            end
        elseif typeof(v) == "table" then
            local ud_3 = v.name or v.car or v.landed
            local ue_3 = uc
            if not ue_3 then
                ue_3 = tonumber(v.unit)
            end
            local ud_4 = ue_3 or 1
            if typeof(ud_3) == "string" then
                rw.offers[ud_4] = { name = ud_3, variant = v.variant, free = v.free == true, at = os.clock(), readyAt = os.clock() }
            end
        end
    end
end
local function fn1099()
    local w1_1
    local w0_1
    local w_ = {}
    w0_1, w1_1 = pcall(function()
        return rC:InvokeServer()
    end)
    local w2 = not w0_1 or typeof(w1_1) ~= "table"
    if w2 then
        return w_
    end
    for k, v in w1_1 do
        local w0_2 = typeof(v) == "table" and typeof(v.name) == "string" and v.id ~= nil
        if w0_2 then
            w_[#w_ + 1] = { source = "reserve", id = v.id, name = v.name, xp = v.xp, oneIn = rY(v.name), tier = si(v.name) }
        end
    end
    return w_
end
local function fn1104()
    if Toggles.AutoRoll.Value then
        q7(true)
    else
        q7(false)
    end
end
qJ = nil
qK = nil
qL = nil
qM = nil
qN = nil
qP = nil
qQ = nil
qT = nil
qU = nil
q0 = nil
q1 = nil
q2 = nil
q5 = nil
q6 = nil
q7 = nil
q8 = nil
q9 = nil
ra = nil
rb = nil
rc = nil
rd = nil
rg = nil
rh = nil
ri = nil
rl = nil
rm = nil
rn = nil
local rq
rs = nil
local qG, qH, qI, qO, qR, qS, qV, qW, qX, qY, qZ, q_, q3, q4, re, rf, rj, rk, ro, rp, rr
rw = nil
ry = nil
rz = nil
SpotConfig = nil
rC = nil
rD = nil
LocalPlayer = nil
Options = nil
rJ = nil
Toggles = nil
rM = nil
rO = nil
rP = nil
rQ = nil
PlotConfig = nil
rU = nil
PlotClient = nil
rY = nil
Library = nil
RacewayPath = nil
r1 = nil
r2 = nil
RollClock = nil
r4 = nil
r5 = nil
r6 = nil
r7 = nil
LuckLadderConfig = nil
CarEconomy = nil
sc = nil
se = nil
CarRarities = nil
local rt, ru, rv, rx, rA, IndexConfig, rH, rI, UpgradeConfig, rN, rR, SaveManager, rV, ThemeManager, rZ, r8, sa, sd
sg = nil
si = nil
sj = nil
sk = nil
sl = nil
sm = nil
sn = nil
so = nil
sr = nil
local sh, sp, sq
sh = nil
sp = nil
sq = nil
qG, B4_20, sk, sd, sa, r8, r2, rZ, rV, rR, rJ, LocalPlayer, ry = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local B4_31 = 1
repeat
    B4_8 = (B4_31 * 1 + 1) % 5 + 1
    if B4_8 <= 3 then
        if B4_8 <= 2 then
            if B4_8 <= 1 then
                if not rJ or not r8 or not r8 and not qG or not r8 and r8 and (rJ or not qG) or (not rJ or r8 or not r8 and r8) and ((not rJ or r8) and (not qG or not qG)) or not (not rJ or not r8 or not r8 and not qG or not r8 and r8 and (rJ or not qG) or (not rJ or r8 or not r8 and r8) and ((not rJ or r8) and (not qG or not qG))) then
                    rR = game:GetService("Lighting")
                    rJ = game:GetService("Workspace")
                else
                    rJ = game:GetService("Lighting")
                    rR = game:GetService("Workspace")
                end
                B4_31 = (B4_31 + 21) % 40
            else
                B4_33 = {
                    "aweiosnjajs",
                    "tdb",
                    "ityfmlx",
                    "qcmtwv",
                    "jiawcptzlj",
                    "erebbmdmzy",
                    "vxgp",
                    "cpuyk",
                    "wiasgqzpj",
                    "vdg",
                    "cdnallqlt"
                }
                if B4_33[(B4_31 * 29 + 78) % 11 + 1] <= B4_33[(B4_31 * 29 + 78) % 11 + 1] then
                    LocalPlayer = qG.LocalPlayer
                    ry = fn435
                else
                    ry = LocalPlayer.LocalPlayer
                    qG = fn435
                end
                B4_31 = (B4_31 + 16) % 40
            end
        else
            B4_33 = (vector.create((B4_31 * 5 + 2) % 11 + 1, (B4_31 * 11 + 9) % 13 + 1, (B4_31 * 7 + 12) % 17 + 1))
            B4_22 = (vector.create((B4_31 * 1 + 4) % 11 + 1, (B4_31 * 5 + 12) % 13 + 1, (B4_31 * 6 + 17) % 17 + 1))
            local Dz = vector.dot(B4_33, B4_22)
            if Dz * Dz >= vector.dot(B4_33, B4_33) * vector.dot(B4_22, B4_22) + 1 then
                ry = game:GetService("Players")
            else
                qG = game:GetService("Players")
            end
            B4_31 = (B4_31 + 26) % 40
        end
    elseif B4_8 <= 4 then
        B4_8 = (vector.create((B4_31 * 2 + 4) % 11 + 1, (B4_31 * 4 + 7) % 13 + 1, (B4_31 * 2 + 12) % 17 + 1))
        B4_33 = (vector.create((B4_31 * 3 + 2) % 11 + 1, (B4_31 * 3 + 13) % 13 + 1, (B4_31 * 12 + 17) % 17 + 1))
        local CJ = vector.dot(B4_8, B4_33)
        if CJ * CJ >= vector.dot(B4_8, B4_8) * vector.dot(B4_33, B4_33) + 1 then
            r8 = game:GetService("ReplicatedStorage")
            sd = game:GetService("RunService")
            B4_20 = game:GetService("UserInputService")
            sk = game:GetService("VirtualUser")
            sa = game:GetService("HttpService")
        else
            B4_20 = game:GetService("ReplicatedStorage")
            sk = game:GetService("RunService")
            sd = game:GetService("UserInputService")
            sa = game:GetService("VirtualUser")
            r8 = game:GetService("HttpService")
        end
        B4_31 = (B4_31 + 11) % 40
    else
        B4_8 = {
            "vimsrsgsm",
            "zoyhl",
            "rjooatcce",
            "xehatxkkrw",
            "mtgb",
            "ajiwrewzt",
            "hxvzgtp",
            "lclmo",
            "klj",
            "hqjvmlstec"
        }
        local DP = B4_31
        B4_33 = B4_8[DP % 10 + 1]
        if B4_33:len() >= B4_33:reverse():rep(DP % 3 + 2):len() then
            rV = game:GetService("CoreGui")
            r2 = game:GetService("GuiService")
            rZ = game:GetService("TeleportService")
        else
            r2 = game:GetService("CoreGui")
            rZ = game:GetService("GuiService")
            rV = game:GetService("TeleportService")
        end
        B4_31 = (B4_31 + 1) % 40
    end
until (B4_31 * 9 + 11) % 40 == 15
if getgenv then
    rq, B4_8 = nil, nil
    B4_31 = 3
    repeat
        B4_33 = (B4_31 * 1 + 0) % 2 + 1
        if B4_33 <= 1 then
            B4_33 = (vector.create((B4_31 * 2 + 3) % 11 + 1, (B4_31 * 5 + 6) % 13 + 1, (B4_31 * 1 + 15) % 17 + 1))
            B4_22 = (vector.create((B4_31 * 3 + 1) % 11 + 1, (B4_31 * 1 + 8) % 13 + 1, (B4_31 * 14 + 8) % 17 + 1))
            local C6 = vector.cross(B4_33, B4_22)
            local C7 = vector.dot(B4_33, B4_22)
            if vector.dot(C6, C6) + C7 * C7 == vector.dot(B4_33, B4_33) * vector.dot(B4_22, B4_22) then
                B4_8 = rq
            else
                rq = B4_8
            end
            B4_31 = (B4_31 + 7) % 8
        else
            local CD = bit32.rrotate(bit32.bxor(bit32.lrotate(B4_31, 21), string.byte(tostring(rq))), 25)
            if bit32.bxor(bit32.lrotate(bit32.bxor(CD, 742502630), 26), 2561738435) ~= bit32.lrotate(CD, 26) then
                getgenv().gethui = rq
                ry = getgenv().__TempoCollectCarsAndRaceLib
            else
                getgenv().gethui = ry
                rq = getgenv().__TempoCollectCarsAndRaceLib
            end
            B4_31 = (B4_31 + 1) % 8
        end
    until (B4_31 * 1 + 1) % 8 == 4
    if B4_8 then
        B4_8 = rq.Unload
    end
    if B4_8 then
        pcall(function()
            rq:Unload()
        end)
    end
end
pcall(function()
    gethui = ry
end)
if setthreadidentity then
    setthreadidentity(8)
end
re, q8, q3, qZ, qV, qR, qO, qI, sq, B4_14, CarRarities, CarEconomy, LuckLadderConfig, RollClock, RacewayPath, PlotClient, PlotConfig, UpgradeConfig, IndexConfig, SpotConfig, rj, B4_18, rb, q4, q_, qX, qS, qK, sn, sc, B4_19, r1, rN, rH, rC, rt, rr, rp, rl, rf, q0, qY, qL, B4_26, so, sh = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
re = "Collect Cars and Race"
q8 = "https://discord.gg/K7Qxnxkk46"
q3 = "https://discord.gg/K7Qxnxkk46"
qZ = "https://tempohub.shop"
qV = "#7fd47f"
qR = "#6ec1ff"
qO = "#e8a34d"
qI = "#8b93a3"
sq = "#e05a5a"
if B4_18 and q3 and (not B4_26 and B4_26) or (false or B4_26) and (false or B4_26) or (not B4_18) and (B4_26 or not B4_26) and (not B4_26 and CarRarities or CarRarities and false) or not (B4_18 and q3 and (not B4_26 and B4_26) or (false or B4_26) and (false or B4_26) or (not B4_18) and (B4_26 or not B4_26) and (not B4_26 and CarRarities or CarRarities and false)) then
    B4_14 = B4_20:WaitForChild("Shared")
else
    B4_20 = B4_14:WaitForChild("Shared")
end
if (LuckLadderConfig and B4_19 or not PlotClient and q0) and (LuckLadderConfig or B4_19 or (q0 or not q0)) and ((not PlotClient or not q0) and (LuckLadderConfig or PlotClient) or LuckLadderConfig and not B4_19 and (LuckLadderConfig or not q0)) or ((q0 or LuckLadderConfig) and (PlotClient or LuckLadderConfig) and (q0 and LuckLadderConfig and (B4_19 or B4_19)) or ((B4_19 or LuckLadderConfig) and (not LuckLadderConfig or not PlotClient) or (not PlotClient or LuckLadderConfig) and (PlotClient and PlotClient))) or not ((LuckLadderConfig and B4_19 or not PlotClient and q0) and (LuckLadderConfig or B4_19 or (q0 or not q0)) and ((not PlotClient or not q0) and (LuckLadderConfig or PlotClient) or LuckLadderConfig and not B4_19 and (LuckLadderConfig or not q0)) or ((q0 or LuckLadderConfig) and (PlotClient or LuckLadderConfig) and (q0 and LuckLadderConfig and (B4_19 or B4_19)) or ((B4_19 or LuckLadderConfig) and (not LuckLadderConfig or not PlotClient) or (not PlotClient or LuckLadderConfig) and (PlotClient and PlotClient)))) then
    CarRarities = require(B4_14:WaitForChild("CarRarities"))
else
    B4_14 = require(CarRarities:WaitForChild("CarRarities"))
end
CarEconomy = require(B4_14:WaitForChild("CarEconomy"))
LuckLadderConfig = require(B4_14:WaitForChild("LuckLadderConfig"))
RollClock = require(B4_14:WaitForChild("RollClock"))
RacewayPath = require(B4_14:WaitForChild("RacewayPath"))
PlotClient = require(B4_14:WaitForChild("PlotClient"))
PlotConfig = require(B4_14:WaitForChild("PlotConfig"))
UpgradeConfig = require(B4_14:WaitForChild("UpgradeConfig"))
IndexConfig = require(B4_14:WaitForChild("IndexConfig"))
SpotConfig = require(B4_14:WaitForChild("SpotConfig"))
local B4_10 = fns.fn108(B4_20:WaitForChild("CarRollRemotes"))
local B4_6 = fns.fn108(B4_10:WaitForChild("RollStarted"))
rj = fns.fn108(B4_10:WaitForChild("BuyOffer"))
B4_18 = fns.fn108(B4_10:WaitForChild("OfferResolved"))
rb = fns.fn108(B4_10:WaitForChild("GetOffers"))
q4 = fns.fn108(B4_10:WaitForChild("SetStopTier"))
q_ = fns.fn108(B4_10:WaitForChild("SetStopChroma"))
qX = fns.fn108(B4_10:WaitForChild("ClearSlots"))
qS = fns.fn108(B4_10:WaitForChild("GetAutoRoll"))
B4_31 = fns.fn108(B4_20:WaitForChild("PassRemotes"))
qK = fns.fn108(B4_31:WaitForChild("SetAutoRoll"))
local B4_3 = fns.fn108(B4_20:WaitForChild("LuckRemotes"))
sn = fns.fn108(B4_3:WaitForChild("BuyTier"))
local B4_25 = fns.fn108(B4_20:WaitForChild("CashRemotes"))
sc = fns.fn108(B4_25:WaitForChild("GetCash"))
B4_19 = fns.fn108(B4_25:WaitForChild("CashChanged"))
local B4_2 = fns.fn108(B4_20:WaitForChild("TrophyRemotes"))
r1 = fns.fn108(B4_2:WaitForChild("GetTrophies"))
local B4_29 = fns.fn108(B4_2:WaitForChild("TrophiesChanged"))
local B4_12 = fns.fn108(B4_20:WaitForChild("CarryRemotes"))
rN = fns.fn108(B4_12:WaitForChild("Pickup"))
rH = fns.fn108(B4_12:WaitForChild("SellCar"))
rC = fns.fn108(B4_12:WaitForChild("GetReserve"))
rt = fns.fn108(B4_12:WaitForChild("CarryReserve"))
rr = fns.fn108(B4_12:WaitForChild("SellReserve"))
rp = fns.fn108(B4_12:WaitForChild("BuySpot"))
B4_22 = fns.fn108(B4_20:WaitForChild("UpgradeRemotes"))
rl = fns.fn108(B4_22:WaitForChild("GetTree"))
rf = fns.fn108(B4_22:WaitForChild("BuyNode"))
local B4_28 = fns.fn108(B4_22:WaitForChild("TreeChanged"))
B4_33 = fns.fn108(B4_20:WaitForChild("IndexRemotes"))
q0 = fns.fn108(B4_33:WaitForChild("GetIndexData"))
qY = fns.fn108(B4_33:WaitForChild("ClaimIndexReward"))
local B4_5 = fns.fn108(B4_33:WaitForChild("IndexDataChanged"))
B4_8 = fns.fn108(B4_20:WaitForChild("DriveRemotes"))
qL = fns.fn108(B4_8:WaitForChild("Stop"))
B4_26 = fns.fn108(B4_20:WaitForChild("PlotRemotes"))
so = fns.fn108(B4_26:WaitForChild("TeleportHome"))
sh = {}
local B4_16 = {}
for k, v in CarRarities.Tiers do
    sh[k] = v.name
    B4_16[v.name] = k
end
B4_31 = {}
for k, v in sh do
    B4_31[v] = true
end
rI, rD, rw, Library, ThemeManager, SaveManager, rs, q1, qM, si, rY, rx, rh, qU, qN = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
B4_33 = { Stock = true, Street = true }
rI = 80
rD = "TempoRaceDrive"
rw = {
    cash = 0,
    trophies = 0,
    kit = nil,
    offers = {},
    lastRollAt = 0,
    lastCollectAt = 0,
    lastGearAt = 0,
    lastSellAt = 0,
    lastBuyAt = {},
    raceBound = false,
    racePath = nil,
    raceS = 0,
    raceEntered = false,
    lastRaceTp = 0,
    lastCarryAttempt = 0,
    lastClearAt = 0,
    lastAutoRollQuery = 0,
    lastOfferPull = 0,
    heldPads = 0,
    tree = {},
    indexData = {},
    lastUpgradeAt = 0,
    lastSpotAt = 0,
    lastIndexAt = 0,
    lastTreePull = 0,
    lastIndexPull = 0
}
rs = fn437
q1 = fn706
qM = fns.fn13
si = fns.fn146
rY = fn504
rx = fn595
rh = fn417
qU = fns.fn272
qN = fn663
pcall(fns.fn162)
pcall(fns.fn245)
B4_19.OnClientEvent:Connect(onOnClientEvent)
B4_29.OnClientEvent:Connect(onOnClientEvent2)
B4_28.OnClientEvent:Connect(fns.onOnClientEvent3)
B4_5.OnClientEvent:Connect(onOnClientEvent4)
B4_6.OnClientEvent:Connect(fns.onOnClientEvent5)
B4_18.OnClientEvent:Connect(onOnClientEvent6)
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
if getgenv then
    getgenv().__TempoCollectCarsAndRaceLib = Library
end
Toggles, Options, sp, rz, rn, q9, qW, sm, r4, rM, ro, qP, rv, q5, sr, r6, rO, q7, sj, rm, q2, sl, rA, ra, rk, sg, ru, q6, rQ, rc, qT, rd, r7, ri, qH, se, qJ, r5, rU, rg, qQ, rP, B4_22 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Toggles = Library.Toggles
Options = Library.Options
rz = fn510
rn = fn678
q9 = fn1061
qW = fn440
sm = fn799
r4 = fns.fn263
rM = fns.fn208
ro = fn957
qP = fn1078
rv = fn900
q5 = fns.fn149
sr = fn922
if (not q2 and q2 or q2 and not q2) and ((not qT or rk) and false) and (rn and false and (not q2 and 60) or q2 and rk and qT) or (not qT or 60 or q2 and q2) and ((not B4_22 or q2) and (B4_22 or not B4_22)) and ((not B4_22 or 60) and (not q2 or qT) and ((B4_22 or not q2) and (not qT or not rk))) or not ((not q2 and q2 or q2 and not q2) and ((not qT or rk) and false) and (rn and false and (not q2 and 60) or q2 and rk and qT) or (not qT or 60 or q2 and q2) and ((not B4_22 or q2) and (B4_22 or not B4_22)) and ((not B4_22 or 60) and (not q2 or qT) and ((B4_22 or not q2) and (not qT or not rk)))) then
    r6 = fns.fn183
    rO = fn742
    q7 = fns.fn201
else
    q7 = fns.fn183
    r6 = fn742
    rO = fns.fn201
end
sj = function()
    if not sm("AutoBuyRoll") then
        return
    end
    local uS = r4("BuyRarity")
    for k, v in sh do
        local uZ = v
        pcall(function()
            q4:FireServer(uZ, uS[uZ] == true)
        end)
    end
    pcall(function()
        q_:FireServer(sm("BuyChroma"))
    end)
end
rm = function()
    local u1_4
    if not sm("AutoBuyRoll") then
        return
    end
    rv()
    local u_ = os.clock()
    local u__1
    local u0 = false
    for k, v in rw.offers do
        local u7 = k
        local u1_1 = (ro(v))
        if u1_1 then
            u1_1 = u_ >= (v.readyAt or 0)
        end
        if u1_1 then
            if u_ - (rw.lastBuyAt[u7] or 0) >= 0.45 then
                local u1_3 = rx(v.name, v.variant, v.free)
                if rw.cash >= u1_3 then
                    rw.lastBuyAt[u7] = u_
                    pcall(function()
                        rj:FireServer(u7)
                    end)
                    u0 = true
                end
            end
        end
    end
    local vi = if qU() then 1 else 0
    if vi == 1 then
        if os.clock() - rw.lastAutoRollQuery >= 1.5 then
            rw.lastAutoRollQuery = os.clock()
            u__1, u1_4 = pcall(function()
                return qS:InvokeServer()
            end)
            local u2_3 = u__1 and typeof(u1_4) == "table"
            if u2_3 then
                local u__2 = tonumber(u1_4.held) or 0
                rw.heldPads = u__2
            end
        end
        local u__3 = false
        for k, v in rw.offers do
            if ro(v) then
                u__3 = true
                break
            end
        end
        local u1_5 = u0
        if not u1_5 then
            u1_5 = rw.heldPads > 0 and not u__3
        end
        if u1_5 then
            if os.clock() - rw.lastClearAt >= 1 then
                rw.lastClearAt = os.clock()
                task.delay(0.35, function()
                    pcall(function()
                        qX:FireServer()
                    end)
                end)
            end
        end
    end
end
if (Options or not ro or (not Options or ru) or not ru and q9 and (rn and not ro)) and ((not q9 or q9 or ro and not ru) and (rn and not q9 or not q9 and ru)) or not ((Options or not ro or (not Options or ru) or not ru and q9 and (rn and not ro)) and ((not q9 or q9 or ro and not ru) and (rn and not q9 or not q9 and ru))) then
    q2 = fn711
    sl = fn757
    rA = fn309
    ra = function()
        local vw
        local vy_6
        local vx_12
        if not sm("AutoUpgrade") then
            return
        end
        if os.clock() - rw.lastUpgradeAt < 0.45 then
            return
        end
        rA()
        vw = nil
        for k, v in UpgradeConfig.Tracks do
            local vx_7 = tonumber(rw.tree[v.id]) or 0
            local vx_8 = vx_7 + 1
            if vx_8 <= #v.nodes then
                local vy_5 = UpgradeConfig.costOf(v, vx_8)
                local vx_9 = UpgradeConfig.currencyOf(v)
                local vx_11 = vy_5 <= (vx_9 == "trophies" and rw.trophies or rw.cash)
                if vx_11 then
                    vx_11 = not vw or vy_5 < vw.cost
                end
                if vx_11 then
                    vw = { id = v.id, cost = vy_5 }
                end
            end
        end
        if not vw then
            return
        end
        rw.lastUpgradeAt = os.clock()
        vx_12, vy_6 = pcall(function()
            return rf:InvokeServer(vw.id)
        end)
        if vx_12 and vy_6 then
            rw.lastTreePull = 0
            rA()
        end
    end
else
    sl = fn711
    q2 = fn757
    ra = fn309
    rA = function()
        local vw
        local vy_3
        local vx_6
        if not sm("AutoUpgrade") then
            return
        end
        if os.clock() - rw.lastUpgradeAt < 0.45 then
            return
        end
        rA()
        vw = nil
        for k, v in UpgradeConfig.Tracks do
            local vx_1 = tonumber(rw.tree[v.id]) or 0
            local vx_2 = vx_1 + 1
            if vx_2 <= #v.nodes then
                local vy_2 = UpgradeConfig.costOf(v, vx_2)
                local vx_3 = UpgradeConfig.currencyOf(v)
                local vx_5 = vy_2 <= (vx_3 == "trophies" and rw.trophies or rw.cash)
                if vx_5 then
                    vx_5 = not vw or vy_2 < vw.cost
                end
                if vx_5 then
                    vw = { id = v.id, cost = vy_2 }
                end
            end
        end
        if not vw then
            return
        end
        rw.lastUpgradeAt = os.clock()
        vx_6, vy_3 = pcall(function()
            return rf:InvokeServer(vw.id)
        end)
        if vx_6 and vy_3 then
            rw.lastTreePull = 0
            rA()
        end
    end
end
rk = fn416
sg = function()
    local vW
    if not sm("AutoUnlockSpots") then
        return
    end
    if os.clock() - rw.lastSpotAt < 0.6 then
        return
    end
    vW = rk()
    if not vW then
        return
    end
    if rw.cash < vW.price then
        return
    end
    local vX = sm("AutoUnlockTeleportNear") and vW.sign
    if vX then
        q5(vW.sign, 5)
        task.wait(0.12)
    end
    rw.lastSpotAt = os.clock()
    pcall(function()
        rp:FireServer(vW.index)
    end)
end
ru = fn1050
q6 = function()
    if not sm("AutoClaimIndex") then
        return
    end
    local wb = if os.clock() - rw.lastIndexAt < 0.4 then 1 else 0
    if wb == 1 then
        return
    end
    ru()
    for k, v in rw.indexData do
        local wf = k
        local v5 = typeof(wf) == "string" and typeof(v) == "table" and v.claimed ~= true
        if v5 then
            local v5_1 = IndexConfig.GetEntry(wf)
            local v5_2 = v5_1 and v5_1.Required or 1
            local v5_3 = tonumber(v.count) or 0
            if v5_3 >= v5_2 then
                rw.lastIndexAt = os.clock()
                pcall(function()
                    qY:FireServer(wf)
                end)
                return
            end
        end
    end
end
rQ = fn731
rc = fns.fn287
qT = fns.fn55
rd = fn408
r7 = fn1099
ri = fns.fn124
qH = fn331
se = function()
    if not sm("AutoSell") then
        return
    end
    if os.clock() - rw.lastSellAt < 0.8 then
        return
    end
    local xp = ri()
    if #xp <= 1 then
        return
    end
    local xq = sm("AutoFarmRace") or LocalPlayer:GetAttribute("Driving")
    local attr = LocalPlayer:GetAttribute("Carrying")
    rw.lastSellAt = os.clock()
    local xs = #xp - 1
    for i = 1, xs do
        local xo = xp[i]
        local xs_1 = xo.tier and rM("SellRarity", xo.tier)
        if xs_1 then
            if xo.source == "reserve" then
                pcall(function()
                    rr:FireServer(xo.id)
                end)
            else
                local xs_2 = attr == nil
                local xt = not xq
                if xt ~= false then
                    xt = xs_2
                end
                if xt then
                    pcall(function()
                        rN:FireServer(xo.id)
                    end)
                    task.wait(0.25)
                    pcall(function()
                        rH:FireServer(xo.id)
                    end)
                    return
                end
            end
        end
    end
end
qJ = fns.fn31
r5 = function()
    if rw.raceBound then
        return
    end
    rw.racePath = RacewayPath.build()
    if rw.racePath then
        local xM = rw.racePath.startS or 0
        rw.raceS = xM
    end
    sk:BindToRenderStep(rD, Enum.RenderPriority.Last.Value, function(g5)
        local xG = Library.Unloaded or not sm("AutoFarmRace")
        if xG then
            return
        end
        local DriveChassis = rJ:FindFirstChild("DriveChassis")
        local racePath = rw.racePath
        local xG_1 = DriveChassis and DriveChassis:IsA("BasePart")
        if not (xG_1 and racePath) then
            return
        end
        local xG_2 = racePath:sample(rw.raceS)
        if xG_2 and xG_2.pos and (DriveChassis.Position - xG_2.pos).Magnitude > 24 then
            rw.raceS = racePath:nearestS(DriveChassis.Position)
        end
        rw.raceS = (rw.raceS + rI * g5) % racePath.length
        local xF = racePath:sample(rw.raceS)
        if xF and xF.pos and xF.tangent then
            pcall(function()
                DriveChassis.CFrame = racePath:frame(rw.raceS, 0, 2.4)
                DriveChassis.AssemblyLinearVelocity = xF.tangent * rI
            end)
        end
    end)
    rw.raceBound = true
end
rU = fn732
rg = fns.fn195
if (not sm and sm or (sl or sl)) and (sl and not sm and (not sm or not sl)) and not ((not sm and sm or (sl or sl)) and (sl and not sm and (not sm or not sl))) then
    rP = function()
        if typeof(LocalPlayer:GetAttribute("Carrying")) == "string" then
            return true
        end
        local x4 = if os.clock() - rw.lastCarryAttempt < 1.2 then 1 else 0
        if x4 == 1 then
            return false
        end
        rw.lastCarryAttempt = os.clock()
        local x0 = qH()
        if not x0 then
            return false
        end
        if x0.source == "parked" then
            pcall(function()
                rN:FireServer(x0.id)
            end)
        else
            pcall(function()
                rt:FireServer(x0.id)
            end)
        end
        return typeof(LocalPlayer:GetAttribute("Carrying")) == "string"
    end
    qQ = fn870
else
    qQ = function()
        if typeof(LocalPlayer:GetAttribute("Carrying")) == "string" then
            return true
        end
        local x4 = if os.clock() - rw.lastCarryAttempt < 1.2 then 1 else 0
        if x4 == 1 then
            return false
        end
        rw.lastCarryAttempt = os.clock()
        local x0 = qH()
        if not x0 then
            return false
        end
        if x0.source == "parked" then
            pcall(function()
                rN:FireServer(x0.id)
            end)
        else
            pcall(function()
                rt:FireServer(x0.id)
            end)
        end
        return typeof(LocalPlayer:GetAttribute("Carrying")) == "string"
    end
    rP = fn870
end
B4_8 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = q8, Copyable = true }, "|", re },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0,
    SidebarCompacted = true,
    TabSwipeFrom = "bottom",
    Animations = { TabSwitch = true }
})
B4_8:SetGlow(true, { Color = Color3.fromRGB(242, 154, 196), Radius = 24, Transparency = 0.3 })
sp = {
    Info = B4_8:AddTab("Info", "info"),
    Main = B4_8:AddTab("Main", "gamepad-2"),
    Player = B4_8:AddTab("Player", "person-standing"),
    Settings = B4_8:AddTab("Settings", "settings")
}
B4_22 = fn469
for k, v in sp do
    if k ~= "Info" then
        B4_22(v)
    end
end
local RollGroup = sp.Main:AddLeftGroupbox("Roll", "dices")
RollGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false, Tooltip = "You have to be near" })
RollGroup:AddToggle("AutoRollTeleportNear", { Text = "Teleport Near", Default = false })
RollGroup:AddDivider("Buy")
RollGroup:AddToggle("AutoBuyRoll", { Text = "Auto Buy Roll", Default = false })
RollGroup:AddDropdown("BuyRarity", {
    Text = "Rarity",
    Values = sh,
    Default = B4_31,
    Multi = true,
    AllowEmpty = true,
    Searchable = true,
    SelectAllButtons = true,
    Expandable = true,
    ExpandColumns = 2
})
RollGroup:AddToggle("BuyChroma", { Text = "Buy Chroma", Default = true })
B4_10 = sp.Main:AddLeftGroupbox("Sell", "banknote")
B4_10:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
B4_10:AddDropdown("SellRarity", {
    Text = "Rarity",
    Values = sh,
    Default = B4_33,
    Multi = true,
    AllowEmpty = true,
    Searchable = true,
    SelectAllButtons = true,
    Expandable = true,
    ExpandColumns = 2
})
B4_8 = sp.Main:AddRightGroupbox("Farm", "gauge")
B4_8:AddToggle("AutoGear", { Text = "Auto Gear", Default = false })
B4_8:AddToggle("AutoUpgrade", { Text = "Auto Upgrade", Default = false })
B4_8:AddToggle("AutoUnlockSpots", { Text = "Auto Unlock Spots", Default = false, Tooltip = "You have to be near" })
B4_8:AddToggle("AutoUnlockTeleportNear", { Text = "Teleport Near", Default = false })
B4_8:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
B4_8:AddDivider("Track")
B4_8:AddToggle("AutoFarmRace", { Text = "Auto Farm Race Track", Default = false })
B4_8:AddToggle("AutoCollectMoney", { Text = "Auto Collect Money", Default = false, Tooltip = "will teleport you" })
Toggles.AutoRoll:OnChanged(fn1104)
Toggles.AutoBuyRoll:OnChanged(fn905)
Options.BuyRarity:OnChanged(fn691)
Toggles.BuyChroma:OnChanged(fns.fn35)
Toggles.AutoFarmRace:OnChanged(fns.fn210)
B4_2 = function()
    local y8
    local y9
    y8 = nil
    y9 = nil
    local y6, y7, Label, Label2, Label3
    local function zd()
        local yi = hookfunction ~= nil
        local yj = hookmetamethod ~= nil
        local yk = getrawmetatable ~= nil
        local yl = setrawmetatable ~= nil
        local ym = getgc ~= nil
        local yn = getgenv ~= nil
        local yo = getreg ~= nil
        local yp = getconnections ~= nil
        local yq = firesignal ~= nil
        local yr = getcallbackvalue ~= nil
        local ys = setclipboard ~= nil
        local yt = getcustomasset ~= nil
        local yu = getnamecallmethod ~= nil
        local yv = isexecutorclosure ~= nil
        local yw = fireproximityprompt ~= nil
        local yx = firetouchinterest ~= nil
        local yy = WebSocket ~= nil
        local yz = readfile ~= nil
        local yA = writefile ~= nil
        local yC = (request or http_request) ~= nil
        local yE = (debug and debug.getupvalues) ~= nil
        local yG = (debug and debug.setupvalue) ~= nil
        local yH = 0
        local yI = { yi, yj, yk, yl, ym, yn, yo, yp, yq, yr, ys, yt, yu, yv, yw, yx, yy, yz, yA, yC, yE, yG }
        for i, v in ipairs(yI) do
            if v then
                yH += 1
            end
        end
        local yi_1 = yH / #yI
        if yi_1 >= 0.9 then
            return q9("Full Support", qV)
        elseif yi_1 >= 0.6 then
            return q9("Half Support", qO)
        else
            return q9("Low Support", sq)
        end
    end
    y8 = "Unknown"
    pcall(function()
        local yR_1
        local yQ_1
        if identifyexecutor then
            yR_1, yQ_1 = identifyexecutor()
            local yS = yR_1 ~= ""
            local yT = type(yR_1) == "string" and yS
            if yT then
                local yS_1 = type(yQ_1) == "string" and yQ_1 ~= "" and yR_1 .. " " .. yQ_1
                local yQ_2 = yS_1
                local yX = if yQ_2 then 1 else 0
                local yV = 605 * yX + 1674 * (1 - yX)
                local yW = 1048 * yX + 3946 * (1 - yX)
                if not ((yV * 3634 + yW * 1567 + yV * yW) % 16777213 == 4474826) then
                    yQ_2 = yR_1
                end
                y8 = yQ_2
            end
        end
    end)
    local ze = zd()
    y9 = os.clock()
    y6 = function()
        local y0 = math.floor(os.clock() - y9)
        if y0 < 60 then
            return y0 .. "s"
        elseif y0 < 3600 then
            return string.format("%dm %ds", math.floor((y0) / (60)), y0 % 60)
        else
            return string.format("%dh %dm", math.floor((y0) / (3600)), math.floor((y0 % 3600) / (60)))
        end
    end
    local UserGroup = sp.Info:AddLeftGroupbox("User", "circle-user")
    UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
    UserGroup:AddLabel(qW("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, qV), true)
    UserGroup:AddLabel(qW("UserId", tostring(LocalPlayer.UserId), qR), true)
    UserGroup:AddLabel(qW("Executor", y8 .. "  " .. ze, qV), true)
    UserGroup:AddDivider()
    Label3 = UserGroup:AddLabel(qW("Session", y6(), qO), true)
    UserGroup:AddDivider()
    UserGroup:AddButton({
        Text = "Copy Username",
        Func = function()
            rz(LocalPlayer.Name, "Copied username")
        end
    })
    UserGroup:AddButton({
        Text = "Copy Profile Link",
        Func = function()
            rz("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
        end
    })
    local SessionGroup = sp.Info:AddRightGroupbox("Session", "signal")
    SessionGroup:AddDivider("Server")
    SessionGroup:AddLabel(qW("Game", re, qR), true)
    Label2 = SessionGroup:AddLabel(qW("Players", "0/0", qV), true)
    y7 = tostring(game.JobId)
    local ze_1 = #y7 > 18 and string.sub(y7, 1, 18) .. "..."
    local ze_2 = ze_1 or y7
    SessionGroup:AddLabel(qW("Job", ze_2, qI), true)
    Label = SessionGroup:AddLabel(qW("Ping", "0 ms", qO), true)
    SessionGroup:AddDivider()
    SessionGroup:AddButton({
        Text = "Rejoin Server",
        Func = function()
            rV:Teleport(game.PlaceId, LocalPlayer)
        end
    })
    SessionGroup:AddButton({
        Text = "Copy Job ID",
        Func = function()
            rz(y7, "Copied Job ID")
        end
    })
    task.spawn(function()
        local y3_1
        local y2_1
        while true do
            task.wait(1)
            if Library.Unloaded then
                break
            end
            Label3:SetText(qW("Session", y6(), qO))
            Label2:SetText(qW("Players", #qG:GetPlayers() .. "/" .. tostring(qG.MaxPlayers), qV))
            y2_1, y3_1 = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local y2_2 = y2_1 and y3_1 .. " ms" or "n/a"
            Label:SetText(qW("Ping", y2_2, qO))
        end
    end)
    local SocialsGroup = sp.Info:AddRightGroupbox("Socials", "link")
    SocialsGroup:AddButton({ Text = "Discord", Func = rn })
    SocialsGroup:AddButton({
        Text = "Rscripts",
        Func = function()
            rz(q3, "Copied Rscripts profile to clipboard")
        end
    })
    SocialsGroup:AddButton({
        Text = "Website",
        Func = function()
            rz(qZ, "Copied website link")
        end
    })
end
B4_20 = function()
    local connection
    local MovementGroup = sp.Player:AddLeftGroupbox("Movement", "footprints")
    MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
    MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
    local FlyGroup = sp.Player:AddRightGroupbox("Fly", "feather")
    FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
    FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    local function jM()
        local Character = LocalPlayer.Character
        local zi = Character and Character:FindFirstChildOfClass("Humanoid")
        return zi
    end
    local function jR()
        local Character = LocalPlayer.Character
        local zl = Character and Character:FindFirstChild("HumanoidRootPart")
        return zl
    end
    sk.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.NoClip and Toggles.NoClip.Value then
            local Character = LocalPlayer.Character
            if Character then
                for i, descendant in Character:GetDescendants() do
                    local zn_2 = descendant:IsA("BasePart") and descendant.CanCollide
                    if zn_2 then
                        descendant.CanCollide = false
                    end
                end
            end
        end
    end)
    sd.JumpRequest:Connect(function()
        if Library.Unloaded then
            return
        end
        if Toggles.InfJump and Toggles.InfJump.Value then
            local zB_1 = jM()
            if zB_1 then
                zB_1:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    local CurrentCamera = rJ.CurrentCamera
    sk.RenderStepped:Connect(function(kd)
        if Library.Unloaded then
            return
        end
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local zG_1 = jM()
            if zG_1 then
                zG_1.WalkSpeed = Options.WalkSpeed.Value
            end
        end
        if Toggles.Fly and Toggles.Fly.Value then
            local zG_3 = jR()
            local zH = jM()
            if zG_3 and zH then
                zH.PlatformStand = true
                local zH_1 = Vector3.zero
                if sd:IsKeyDown(Enum.KeyCode.W) then
                    zH_1 += CurrentCamera.CFrame.LookVector
                end
                if sd:IsKeyDown(Enum.KeyCode.S) then
                    zH_1 -= CurrentCamera.CFrame.LookVector
                end
                if sd:IsKeyDown(Enum.KeyCode.A) then
                    zH_1 -= CurrentCamera.CFrame.RightVector
                end
                if sd:IsKeyDown(Enum.KeyCode.D) then
                    zH_1 += CurrentCamera.CFrame.RightVector
                end
                if sd:IsKeyDown(Enum.KeyCode.Space) then
                    zH_1 += Vector3.new(0, 1, 0)
                end
                if sd:IsKeyDown(Enum.KeyCode.LeftControl) then
                    zH_1 -= Vector3.new(0, 1, 0)
                end
                zG_3.AssemblyLinearVelocity = Vector3.zero
                if zH_1.Magnitude > 0 then
                    zG_3.CFrame = zG_3.CFrame + zH_1.Unit * Options.FlySpeed.Value * kd
                end
            end
        end
    end)
    Toggles.Fly:OnChanged(function()
        if not Toggles.Fly.Value then
            local zQ = jM()
            if zQ then
                zQ.PlatformStand = false
            end
        end
    end)
    Toggles.WalkSpeedEnabled:OnChanged(function()
        if not Toggles.WalkSpeedEnabled.Value then
            local zV = jM()
            if zV then
                zV.WalkSpeed = 16
            end
        end
    end)
    local function kz(kA)
        if not kA:IsA("ProximityPrompt") then
            return
        end
        kA.HoldDuration = 0
        kA.MaxActivationDistance = 50
        kA.RequiresLineOfSight = false
    end
    connection = nil
    Toggles.InstantProximityPrompt:OnChanged(function()
        if Toggles.InstantProximityPrompt.Value then
            for i, descendant in rJ:GetDescendants() do
                pcall(kz, descendant)
            end
            connection = rJ.DescendantAdded:Connect(function(kI)
                if Toggles.InstantProximityPrompt.Value then
                    pcall(kz, kI)
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
B4_2()
B4_20()
task.spawn(fns.worker)
task.spawn(worker2)
task.spawn(fns.worker3)
B4_12 = function()
    local BM, BN, BO, BP, BQ, BR, BS, BT, BU, connection2, connection, BX, Label, BZ, B_
    local MenuGroup = sp.Settings:AddLeftGroupbox("Menu", "logs")
    BM = 0
    BS = tick()
    MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
    Label = MenuGroup:AddLabel("AFK triggers: 0")
    BO = function()
        local CurrentCamera = rJ.CurrentCamera
        if not CurrentCamera then
            return
        end
        sa:CaptureController()
        sa:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
        BM += 1
        BS = tick()
        pcall(function()
            Label:SetText("AFK triggers: " .. BM)
        end)
    end
    connection2 = LocalPlayer.Idled:Connect(function()
        if Toggles.AntiAfk.Value then
            pcall(BO)
        end
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(2)
            local Ai = Toggles.AntiAfk.Value and tick() - BS >= 60
            if Ai then
                pcall(BO)
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
    BU = function(lr)
        pcall(function()
            rZ:SetGameplayPausedNotificationEnabled(not lr)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = r2:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not lr
            end
        end)
        if not lr then
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
        BU(Toggles.AntiGameplayPause.Value)
    end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            if Toggles.AntiGameplayPause.Value then
                BU(true)
            end
        end
    end)
    BN = false
    BT = function()
        local PlaceId, JobId
        if BN then
            return
        end
        BN = true
        PlaceId, JobId = game.PlaceId, game.JobId
        local Ax = pcall(function()
            rV:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
        end)
        if not Ax then
            pcall(function()
                rV:Teleport(PlaceId, LocalPlayer)
            end)
        end
    end
    task.spawn(function()
        local RobloxPromptGui = r2:WaitForChild("RobloxPromptGui", 30)
        local AC = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
        if not AC then
            return
        end
        AC.ChildAdded:Connect(function(l0)
            if Library.Unloaded then
                return
            end
            if Toggles.AutoReconnect.Value and l0.Name == "ErrorPrompt" then
                BT()
            end
        end)
    end)
    rV.TeleportInitFailed:Connect(function()
        if Toggles.AutoReconnect.Value then
            BN = false
            BT()
        end
    end)
    Toggles.Disable3D:OnChanged(function()
        pcall(function()
            sk:Set3dRenderingEnabled(not Toggles.Disable3D.Value)
        end)
    end)
    B_ = {
        ParticleEmitter = true,
        Trail = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        Explosion = true,
        Beam = true
    }
    BP = function(mi)
        if B_[mi.ClassName] then
            pcall(function()
                mi.Enabled = false
            end)
        end
    end
    connection = nil
    Toggles.FpsBoost:OnChanged(function()
        if Toggles.FpsBoost.Value then
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            pcall(function()
                rR.GlobalShadows = false
            end)
            pcall(function()
                rR.FogEnd = 9000000000
            end)
            for i, descendant in rJ:GetDescendants() do
                pcall(BP, descendant)
            end
            connection = rJ.DescendantAdded:Connect(function(mx)
                if Toggles.FpsBoost.Value then
                    pcall(BP, mx)
                end
            end)
        else
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end)
            pcall(function()
                rR.GlobalShadows = true
            end)
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    local ScriptGroup = sp.Settings:AddLeftGroupbox("Script", "terminal")
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
        if connection then
            connection:Disconnect()
        end
        qJ()
        pcall(function()
            qL:FireServer()
        end)
        q7(false)
        BU(false)
        pcall(function()
            sk:Set3dRenderingEnabled(true)
        end)
        if getgenv then
            getgenv().__TempoCollectCarsAndRaceLib = nil
        end
    end)
    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("TempoHub")
    ThemeManager:SaveDefault("Evil Hello Kitty")
    ThemeManager:ApplyToTab(sp.Settings)
    ThemeManager:LoadDefault()
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
    SaveManager:SetFolder("TempoHub/CollectCarsAndRace")
    local B0_2 = SaveManager:BuildConfigSection(sp.Settings)
    BR = function(mS, mT)
        local AW_1 = (mS == "Toggle" and Toggles or Options)[mT]
        local AV_2 = type(AW_1) == "table" and AW_1.Type == mS
        return AV_2 and AW_1 or nil
    end
    BQ = function(m_, m0)
        local Type = m0.Type
        if Type == "Toggle" then
            return { idx = m_, type = "Toggle", value = m0.Value == true }
        elseif Type == "Slider" then
            return { idx = m_, type = "Slider", value = tostring(m0.Value) }
        elseif Type == "Dropdown" then
            return { idx = m_, type = "Dropdown", multi = m0.Multi == true, value = m0.Value }
        elseif Type == "Input" then
            local A2 = m0.Value or ""
            return { idx = m_, type = "Input", text = tostring(A2) }
        elseif Type == "ColorPicker" then
            return { idx = m_, type = "ColorPicker", value = m0.Value:ToHex(), transparency = m0.Transparency }
        elseif Type == "KeyPicker" then
            return {
                idx = m_,
                type = "KeyPicker",
                mode = m0.Mode,
                key = m0.Value,
                modifiers = m0.Modifiers,
                toggled = m0.Toggled
            }
        else
            return nil
        end
    end
    BX = function()
        local A5 = {}
        for i, v in ipairs({ Toggles, Options }) do
            for k, v in pairs(v) do
                local A6 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                if A6 then
                    local A6_1 = BQ(k, v)
                    if A6_1 then
                        A5[#A5 + 1] = A6_1
                    end
                end
            end
        end
        table.sort(A5, function(na, nb)
            if na.type ~= nb.type then
                return na.type < nb.type
            end
            return na.idx < nb.idx
        end)
        return { objects = A5 }
    end
    BZ = function(nd)
        local Bp
        Bp = nil
        local Bq = type(nd) ~= "table" or type(nd.idx) ~= "string" or type(nd.type) ~= "string" or SaveManager.Ignore[nd.idx]
        if Bq then
            return false
        end
        Bp = BR(nd.type, nd.idx)
        if not Bp then
            return false
        end
        local Bq_1 = pcall(function()
            if nd.type == "Input" then
                if type(nd.text) ~= "string" then
                    return
                end
                Bp:SetValue(nd.text)
            elseif nd.type == "ColorPicker" then
                Bp:SetValueRGB(Color3.fromHex(nd.value), nd.transparency)
            elseif nd.type == "KeyPicker" then
                Bp:SetValue({ nd.key, nd.mode, nd.modifiers })
                if nd.mode == "Toggle" and nd.toggled ~= nil then
                    Bp.Toggled = nd.toggled
                    Bp:Update()
                end
            else
                Bp:SetValue(nd.value)
            end
        end)
        return Bq_1
    end
    B0_2:AddDivider()
    B0_2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    B0_2:AddButton({
        Text = "Export Config to Clipboard",
        Func = function()
            local Bt_1
            local Bs_1
            Bs_1, Bt_1 = pcall(r8.JSONEncode, r8, BX())
            if not Bs_1 then
                Library:Notify("Failed to encode the config")
                return
            end
            local Bs_2 = setclipboard or toclipboard
            local Bs_3 = type(Bs_2) ~= "function" or not pcall(Bs_2, Bt_1)
            if Bs_3 then
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Config copied to clipboard", 6)
        end
    })
    B0_2:AddButton({
        Text = "Import Config from Clipboard Text",
        Func = function()
            local By_1
            local Bw = Options.SaveManager_ImportSource.Value
            local Bw_1
            local BC = if Bw then 1 else 0
            local BA = 3240 * BC + 3446 * (1 - BC)
            local BB = 2388 * BC + 900 * (1 - BC)
            if not ((BA * 1725 + BB * 347 + BA * BB) % 16777213 == 14154756) then
                Bw = ""
            end
            local Bx = tostring(Bw):match("^%s*(.-)%s*$")
            if Bx == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            Bw_1, By_1 = pcall(r8.JSONDecode, r8, Bx)
            local Bx_1 = not Bw_1 or type(By_1) ~= "table" or type(By_1.objects) ~= "table"
            if Bx_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            local Bw_2 = 0
            for i, v in ipairs(By_1.objects) do
                if BZ(v) then
                    Bw_2 += 1
                end
            end
            if Bw_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local By_2 = Bw_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(Bw_2, By_2), 6)
        end
    })
    SaveManager:LoadAutoloadConfig()
    if Toggles.HideUiOnStart.Value then
        Library:Toggle(false)
    end
end
B4_12()
end)(...)
