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
getgenv().TempoHoodSubtitle = "MY TOLL FARM!"
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
local s__1, s__3, s__8, s__17, s__19, s__21, s__33, s__34, s__39
local mL
local lL
local ms
local l9
local lR
local my
local VirtualUser
local LaunchUtil
local mE
local lE
local ml
local connection3
local mK
local PlotsUtil
local mr
local l8
local mQ
local SpinsUtil
local mx
local me
local mW
local lW
local Workspace
local connection
local Options
local connection6
local lJ
local mq
local m7
local MutationUtil
local mP
local DataUtil
local mw
local md
local mV
local lV
local mC
local lC
local mj
local l0
local mI
local lI
local connection2
local m6
local l6
local lO
local mv
local mc
local mU
local mB
local SellItemEvent
local mi
local m_
local l_
local connection5
local mo
local m5
local l5
local mN
local lN
local mu
local Label
local HttpService
local lT
local connection4
local lA
local mh
local mZ
local mG
local RarityTiers
local mn
local l4
local mM
local lM
local PlayerGui
local ma
local mS
local RebirthUtil
local mz
local mg
local Gears
local lY
local mF
local lF
local mm
local m3
function fns.fn6()
    gethui = function()
        return PlayerGui
    end
end
function fns.onInputBegan()
    mr = tick()
end
function fns.antiGameplayPauseLoop()
    while not mQ.Unloaded do
        task.wait(1)
        if mq.AntiGameplayPause.Value then
            mx(true)
        end
    end
end
function fns.antiAfkLoop()
    while not mQ.Unloaded do
        task.wait(2)
        if mq.AntiAfk.Value then
            local sS = tick() - mr
            local sT = tick() - ml
            if sS >= 300 and sT >= 60 then
                pcall(l4)
            else
                if sS < 300 and sT >= 300 then
                    pcall(l4)
                end
            end
        end
    end
end
function fns.onJumpRequest()
    if mQ.Unloaded then
        return
    end
    if mq.InfJump and mq.InfJump.Value then
        local rE_1 = l0()
        if rE_1 then
            rE_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.fn38(a8, a9)
    local oy = Options[a8]
    if oy == nil or oy.Value == nil then
        return a9
    end
    return oy.Value
end
function fns.fn87()
    local q4_1
    local q3_1
    local q2 = false
    q3_1, q4_1 = pcall(function()
        return SpinsUtil:CanWheelSpin(my)
    end)
    if q3_1 then
        q2 = q4_1 == true
    end
    if q2 then
        SpinsUtil.RemoteEvent:FireServer("WheelSpin")
    end
end
function fns.fn119(an, ao)
    if setclipboard then
        setclipboard(an)
    elseif toclipboard then
        toclipboard(an)
    end
    mQ:Notify(ao)
end
function fns.fn139()
    local sg = {}
    for i, v in ipairs({ mq, Options }) do
        for k, v in pairs(v) do
            local sh = type(v) == "table" and type(v.Type) == "string" and not mu.Ignore[k]
            if sh then
                local sh_1 = mh(k, v)
                if sh_1 then
                    sg[#sg + 1] = sh_1
                end
            end
        end
    end
    table.sort(sg, function(hL, hM)
        if hL.type ~= hM.type then
            return hL.type < hM.type
        end
        return hL.idx < hM.idx
    end)
    return { objects = sg }
end
function fns.onCopyEthereumAddress()
    mm(mG, "Copied Ethereum address")
end
function fns.fn166()
    if os.clock() - mE < 1.5 then
        return
    end
    mE = os.clock()
    mK = os.clock()
    mz()
    lA("Return")
end
function fns.fn189(a_)
    local og = Options[a_]
    local oh = og and og.Value
    local og_1 = {}
    if type(oh) ~= "table" then
        local oh_1 = oh ~= ""
        local oj = type(oh) == "string" and oh_1
        if oj then
            og_1[oh] = true
        end
        return og_1
    end
    for k, v in oh do
        local oh_2 = v == true
        local oi_1 = type(k) == "string" and oh_2
        if oi_1 then
            og_1[k] = true
        elseif type(v) == "string" then
            og_1[v] = true
        end
    end
    return og_1
end
function fns.fn194()
    if not mq.Fly.Value then
        local rs = l0()
        if rs then
            rs.PlatformStand = false
        end
    end
end
function fns.fn206()
    local oB = md()
    local oC = oB and oB:FindFirstChildOfClass("Humanoid")
    return oC
end
function fns.fn210()
    mx(mq.AntiGameplayPause.Value)
end
function fns.onHeartbeat()
    if mQ.Unloaded then
        return
    end
    local rk = lR("AutoDrive") and lF() and not lT()
    if rk then
        pcall(lE)
    end
end
function fns.fn244(hx, hy)
    local Type = hy.Type
    if Type == "Toggle" then
        return { idx = hx, type = "Toggle", value = hy.Value == true }
    elseif Type == "Slider" then
        return { idx = hx, type = "Slider", value = tostring(hy.Value) }
    elseif Type == "Dropdown" then
        return { idx = hx, type = "Dropdown", multi = hy.Multi == true, value = hy.Value }
    elseif Type == "Input" then
        local sa = hy.Value or ""
        return { idx = hx, type = "Input", text = tostring(sa) }
    elseif Type == "ColorPicker" then
        return { idx = hx, type = "ColorPicker", value = hy.Value:ToHex(), transparency = hy.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = hx,
            type = "KeyPicker",
            mode = hy.Mode,
            key = hy.Value,
            modifiers = hy.Modifiers,
            toggled = hy.Toggled
        }
    else
        return nil
    end
end
function fns.onExportConfigToClipboard()
    local sE_1
    local sD_1
    sD_1, sE_1 = pcall(HttpService.JSONEncode, HttpService, l_())
    if not sD_1 then
        mQ:Notify("Failed to encode the config")
        return
    end
    local sD_2 = setclipboard or toclipboard
    local sD_3 = type(sD_2) ~= "function" or not pcall(sD_2, sE_1)
    if sD_3 then
        mQ:Notify("Your executor does not support copying to the clipboard")
        return
    end
    mQ:Notify("Config copied to clipboard", 6)
end
function fns.onCopySolanaAddress()
    mm(mv, "Copied Solana address")
end
function fns.fn282()
    if not lF() then
        mz()
    else
        mV = nil
        mP = nil
    end
end
function fns.onRenderStepped(gO)
    if mQ.Unloaded then
        return
    end
    if mq.WalkSpeedEnabled and mq.WalkSpeedEnabled.Value then
        local rG_1 = l0()
        if rG_1 then
            rG_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if mq.Fly and mq.Fly.Value then
        local rG_3 = lO()
        local rH = l0()
        lY = Workspace.CurrentCamera or lY
        if rG_3 and rH and lY then
            rH.PlatformStand = true
            local rH_1 = Vector3.zero
            if m_:IsKeyDown(Enum.KeyCode.W) then
                rH_1 = rH_1 + lY.CFrame.LookVector
            end
            local rN = if m_:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if rN == 1 then
                rH_1 = rH_1 - lY.CFrame.LookVector
            end
            if m_:IsKeyDown(Enum.KeyCode.A) then
                rH_1 = rH_1 - lY.CFrame.RightVector
            end
            if m_:IsKeyDown(Enum.KeyCode.D) then
                rH_1 = rH_1 + lY.CFrame.RightVector
            end
            local rN_1 = if m_:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if rN_1 == 1 then
                rH_1 = rH_1 + Vector3.new(0, 1, 0)
            end
            if m_:IsKeyDown(Enum.KeyCode.LeftControl) then
                rH_1 = rH_1 - Vector3.new(0, 1, 0)
            end
            rG_3.Velocity = Vector3.zero
            if rH_1.Magnitude > 0 then
                rG_3.CFrame = rG_3.CFrame + rH_1.Unit * Options.FlySpeed.Value * gO
            end
        end
    end
end
function fns.fn331(eY)
    local DiscordGroup = eY:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = ma })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = ma })
end
function fns.fn339()
    mQ.ScreenGui.Parent = PlayerGui
end
function fns.fn342()
    local oE = md()
    local oF = oE and oE:FindFirstChild("HumanoidRootPart")
    return oF
end
function fns.worker3()
    while not mQ.Unloaded do
        if lC() then
            pcall(mI)
        end
        task.wait(0.4)
    end
end
function fns.fn354(ax, ay, az)
    return string.format("<b>%s</b> %s %s", ax, lV("-", "#5a6070"), lV(ay, az))
end
function fns.fn373()
    if not m3() then
        return
    end
    if os.clock() - mK < 2 then
        return
    end
    mK = os.clock()
    mz()
    lA("Launch")
end
function fns.fn374()
    local pA = if lF() then 1 else 0
    if pA == 1 then
        return false
    end
    local pv = my:GetAttribute("Reviving") or my:GetAttribute("Dying") or my:GetAttribute("Killed")
    if pv then
        return false
    elseif os.clock() - mE < 1.25 then
        return false
    else
        local pv_1 = l0()
        if not (pv_1 and pv_1.Health > 0) then
            return false
        end
        local pv_2 = lW()
        if not (pv_2 and pv_2.PrimaryPart) then
            return false
        end
        return pv_2:FindFirstChildWhichIsA("VehicleSeat", true) ~= nil
    end
end
function fns.onRscripts()
    mm(mg, "Copied Rscripts profile to clipboard")
end
function fns.fn442()
    return my.Character
end
function fns.onStepped()
    if mQ.Unloaded then
        return
    end
    if mq.NoClip and mq.NoClip.Value then
        local Character = my.Character
        if Character then
            for i, descendant in Character:GetDescendants() do
                local rw_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if rw_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.fn495()
    if not lR("AutoSell") then
        return false
    end
    local qp = mW()
    local qq = mw("AutoSellMode", me)
    if qq == l8 then
        local qq_1 = #qp
        local qr = tonumber(mw("AutoSellCount", 10)) or 10
        return qq_1 >= qr
    end
    return #qp > 0
end
function fns.fn508(au, av)
    return string.format('<font color="%s">%s</font>', av, au)
end
function fns.fn510()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    ml = tick()
end
local function fn516(dn)
    if type(dn) ~= "string" then
        return false
    end
    local p3 = m5("KeepRarities")
    return p3[dn] == true
end
local function fn547()
    local qt = mW()
    for k, v in qt do
        local qt_1 = mQ.Unloaded or not lR("AutoSell")
        if qt_1 then
            return
        end
        SellItemEvent:FireServer(v)
        task.wait(0.2)
    end
end
local function fn557()
    local p8 = {}
    local p9 = m7()
    local qa = p9 and p9.Gears and type(p9.Gears.Owned) == "table"
    if not qa then
        return p8
    end
    local qa_1 = mc()
    for k, v in p9.Gears.Owned do
        local p9_1 = type(k) == "string" and type(v) == "number" and v > 0 and not qa_1[k]
        if p9_1 then
            local p9_2 = lI(k)
            local qb = p9_2
            if qb then
                local qc = p9_2:GetAttribute("Fuel") or p9_2:GetAttribute("Speed")
                qb = qc
            end
            if qb then
                local qb_1 = tonumber(p9_2:GetAttribute("Price")) or 0
                local qb_2 = qb_1 > 0 and not m6(mM(k))
                if qb_2 then
                    local qm = 1
                    while qm <= v do
                        p8[#p8 + 1] = k
                        qm += 1
                    end
                end
            end
        end
    end
    return p8
end
local function onInputChanged(hh)
    local UserInputType = hh.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        mr = tick()
    end
end
local function fn573()
    local rb_1
    local ra_1
    if identifyexecutor then
        rb_1, ra_1 = identifyexecutor()
        local rc = rb_1 ~= ""
        local rd = type(rb_1) == "string" and rc
        if rd then
            local rc_1 = type(ra_1) == "string" and ra_1 ~= "" and rb_1 .. " " .. ra_1
            mB = rc_1 or rb_1
        end
    end
end
local function worker2()
    while not mQ.Unloaded do
        if lR("AutoDrive") then
            if lF() then
                if lT() then
                    pcall(lL)
                end
            else
                pcall(mj)
            end
        end
        task.wait(0.2)
    end
end
local function onImportConfigFromClipboardTex()
    local sJ_1
    local sH = Options.SaveManager_ImportSource.Value or ""
    local sH_1
    local sI = tostring(sH):match("^%s*(.-)%s*$")
    if sI == "" then
        mQ:Notify("Paste an exported config into the box first")
        return
    end
    sH_1, sJ_1 = pcall(HttpService.JSONDecode, HttpService, sI)
    local sI_1 = not sH_1 or type(sJ_1) ~= "table" or type(sJ_1.objects) ~= "table"
    if sI_1 then
        mQ:Notify("That is not a valid exported config")
        return
    end
    local sH_2 = 0
    for i, v in ipairs(sJ_1.objects) do
        if mN(v) then
            sH_2 += 1
        end
    end
    if sH_2 == 0 then
        mQ:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local sJ_2 = sH_2 == 1 and "" or "s"
    mQ:Notify(("Imported %d setting%s"):format(sH_2, sJ_2), 6)
end
local function worker()
    local rg_1
    while true do
        task.wait(1)
        if mQ.Unloaded then
            break
        end
        local rf = math.floor(os.clock() - lJ)
        if rf < 60 then
            rg_1 = rf .. "s"
        elseif rf < 3600 then
            rg_1 = string.format("%dm %ds", math.floor((rf) / (60)), rf % 60)
        else
            rg_1 = string.format("%dh %dm", math.floor((rf) / (3600)), math.floor((rf % 3600) / (60)))
        end
        Label:SetText(lM("Session time", rg_1, mZ))
    end
end
local function fn612(ai, aj)
    return ai[1] < aj[1]
end
local function fn645()
    if mq.AutoDrive.Value then
        mj()
    else
        mz()
    end
end
local function fn666()
    mm(mi, "Copied Discord invite to clipboard")
end
local function fn668()
    local oI_1
    local oH_1
    oH_1, oI_1 = pcall(function()
        return DataUtil:GetPlayerData(my)
    end)
    if oH_1 then
        return oI_1
    end
    return nil
end
local function fn669()
    local pO = {}
    local pP = m7()
    local pQ = pP and pP.Carts and type(pP.Carts.Equipped) == "table"
    if not pQ then
        return pO
    end
    for k, v in pP.Carts.Equipped do
        local pP_1 = type(v) == "table" and type(v.Gears) == "table"
        if pP_1 then
            for k, v in v.Gears do
                if type(v) == "string" then
                    pO[v] = true
                end
            end
        end
    end
    return pO
end
local function fn726(c4)
    local pI = lI(c4)
    if not pI then
        return nil
    end
    local pJ = pI:GetAttribute("Rarity") or pI:GetAttribute("Tier")
    local pI_1 = tonumber(pJ)
    if not pI_1 then
        return nil
    end
    local pJ_1 = RarityTiers.Tiers[pI_1]
    local pI_2 = type(pJ_1) == "table" and pJ_1.Name
    local pJ_2 = pI_2
    local pN = if pJ_2 then 1 else 0
    local pL = 3788 * pN + 2755 * (1 - pN)
    local pM = 3606 * pN + 3856 * (1 - pN)
    if not ((pL * 2507 + pM * 1654 + pL * pM) % 16777213 == 12343155) then
        pJ_2 = nil
    end
    return pJ_2
end
local function fn733()
    if mP and mV then
        pcall(function()
            if mP.Parent then
                mP:SetAttribute("Speed", mV)
            end
        end)
    end
    mV = nil
    mP = nil
end
local function onCopyBitcoinAddress()
    mm(mL, "Copied Bitcoin address")
end
local function onCopyVenmoLink()
    mm(mn, "Copied Venmo link")
end
local function onCopyLitecoinAddress()
    mm(mS, "Copied Litecoin address")
end
local function fn751(bN, ...)
    local oT = LaunchUtil and LaunchUtil.RemoteEvent
    if not oT then
        return
    end
    oT:FireServer(bN, ...)
end
local function fn767(aU)
    if mQ.Unloaded then
        return false
    end
    local od = mq[aU]
    return od ~= nil and od.Value == true
end
local function onCopyPayPalLink()
    mm(ms, "Copied PayPal link")
end
local function fn795()
    local q8_1
    local q7_1
    local q6 = false
    q7_1, q8_1 = pcall(function()
        return RebirthUtil:CanRebirth(my)
    end)
    if q7_1 then
        q6 = q8_1 == true
    end
    if q6 then
        RebirthUtil.RemoteEvent:FireServer("Rebirth")
    end
end
local function fn811()
    return my:GetAttribute("Launched") == true
end
local function onCopyUSDTAddress()
    mm(mC, "Copied USDT address")
end
local function fn827(cW)
    local pF_1
    if type(cW) ~= "string" then
        return nil
    end
    local pD = MutationUtil
    local pD_1
    local pE = cW
    if pD then
        pD = type(MutationUtil.GetBaseId) == "function"
    end
    if pD then
        pD_1, pF_1 = pcall(MutationUtil.GetBaseId, MutationUtil, cW)
        local pG = pD_1 and type(pF_1) == "string"
        if pG then
            pE = pF_1
        end
    end
    return Gears:FindFirstChild(pE, true)
end
local function fn835()
    mQ.ScreenGui.Parent = PlayerGui
end
local function onCopyJoinScript_JobID()
    local fe = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, l5)
    mm(fe, "Copied join script to clipboard")
end
local function fn858()
    mz()
    lN:Disconnect()
    connection:Disconnect()
    connection2:Disconnect()
    connection3:Disconnect()
    connection4:Disconnect()
    connection5:Disconnect()
    connection6:Disconnect()
    mx(false)
    local sW = l0()
    if sW then
        sW.PlatformStand = false
        sW.WalkSpeed = 16
    end
end
local function fn859(b0)
    if not b0 then
        mz()
        return
    end
    if mP ~= b0 or mV == nil then
        mP = b0
        local oZ_1 = tonumber(b0:GetAttribute("Speed")) or 50
        mV = oZ_1
    end
end
local function fn876()
    local oQ = mo()
    if not oQ then
        return nil
    end
    local AllCartsModel = oQ:FindFirstChild("AllCartsModel")
    if AllCartsModel and AllCartsModel.Name == "OldCart" then
        return nil
    end
    return AllCartsModel
end
local function fn879()
    local oO_1
    local oN_1
    oN_1, oO_1 = pcall(function()
        return PlotsUtil:GetPlayerPlot(my)
    end)
    if oN_1 then
        return oO_1
    end
    return nil
end
local function fn886(hp, hq)
    local r3 = hp == "Toggle" and mq
    local r8 = if r3 then 1 else 0
    local r6 = 1352 * r8 + 258 * (1 - r8)
    local r7 = 3767 * r8 + 2815 * (1 - r8)
    if not ((r6 * 1990 + r7 * 3033 + r6 * r7) % 16777213 == 2431562) then
        r3 = Options
    end
    local r3_1 = r3[hq]
    local r2_2 = type(r3_1) == "table" and r3_1.Type == hp
    return r2_2 and r3_1 or nil
end
local function fn904()
    if not mq.WalkSpeedEnabled.Value then
        local ru = l0()
        if ru then
            ru.WalkSpeed = 16
        end
    end
end
local function fn907()
    local oK = m7()
    local oL = oK and type(oK.Currency) == "table"
    if oL then
        local oL_1 = tonumber(oK.Currency.Currency1) or 0
        return oL_1
    end
    return 0
end
local function fn910()
    local o4 = my:GetAttribute("Dying") or my:GetAttribute("Killed") or my:GetAttribute("LaunchEnded")
    if o4 then
        return true
    end
    local o4_1 = lW()
    if not o4_1 then
        return false
    end
    local o5 = tonumber(o4_1:GetAttribute("CurrentFuel")) or 1
    return o5 <= 0
end
local function worker4()
    while not mQ.Unloaded do
        if lR("AutoBuyShop") then
            pcall(l6)
        end
        if lR("AutoBuyUpgrades") then
            pcall(mU)
        end
        if lR("AutoSpin") then
            pcall(mF)
        end
        if lR("AutoRebirth") then
            pcall(l9)
        end
        task.wait(0.6)
    end
end
local function onUnload()
    mQ:Unload()
end
lA = nil
SellItemEvent = nil
lC = nil
connection = nil
lE = nil
lF = nil
RarityTiers = nil
connection5 = nil
lI = nil
lJ = nil
PlotsUtil = nil
lL = nil
lM = nil
lN = nil
lO = nil
DataUtil = nil
SpinsUtil = nil
lR = nil
RebirthUtil = nil
lT = nil
lV = nil
lW = nil
LaunchUtil = nil
lY = nil
l_ = nil
l0 = nil
connection3 = nil
l4 = nil
l5 = nil
l6 = nil
MutationUtil = nil
l8 = nil
l9 = nil
ma = nil
Label = nil
mc = nil
md = nil
me = nil
mg = nil
mh = nil
mi = nil
mj = nil
Options = nil
ml = nil
mm = nil
local lU, lZ, GearUtil, l3, mf
mn = nil
mo = nil
connection2 = nil
mq = nil
mr = nil
ms = nil
PlayerGui = nil
mu = nil
mv = nil
mw = nil
mx = nil
my = nil
mz = nil
connection4 = nil
mB = nil
mC = nil
Workspace = nil
mE = nil
mF = nil
mG = nil
mI = nil
mK = nil
mL = nil
mM = nil
mN = nil
mP = nil
mQ = nil
mS = nil
HttpService = nil
mU = nil
mV = nil
mW = nil
VirtualUser = nil
Gears = nil
mZ = nil
m_ = nil
connection6 = nil
m3 = nil
m5 = nil
m6 = nil
m7 = nil
local mH, CoreGui, GuiService, mR, GetPlayerUpgrades, GetUpgradeStats, BuyUpgrade
mH = nil
CoreGui = nil
GuiService = nil
mR = nil
GetPlayerUpgrades = nil
GetUpgradeStats = nil
BuyUpgrade = nil
m_, VirtualUser, HttpService, GuiService, CoreGui, Workspace, my, PlayerGui = nil, nil, nil, nil, nil, nil, nil, nil
local s__18 = game:GetService("Players")
if (PlayerGui or HttpService or not PlayerGui and HttpService) and (not HttpService or not HttpService or not PlayerGui and not HttpService) and (PlayerGui or not HttpService or (not HttpService or PlayerGui) or (not HttpService and HttpService or (PlayerGui or not HttpService))) or (not HttpService and not PlayerGui or (PlayerGui or PlayerGui) or (PlayerGui or not PlayerGui or (not PlayerGui or not PlayerGui))) and ((HttpService or PlayerGui or PlayerGui and not HttpService) and (PlayerGui or HttpService or (PlayerGui or HttpService))) or not ((PlayerGui or HttpService or not PlayerGui and HttpService) and (not HttpService or not HttpService or not PlayerGui and not HttpService) and (PlayerGui or not HttpService or (not HttpService or PlayerGui) or (not HttpService and HttpService or (PlayerGui or not HttpService))) or (not HttpService and not PlayerGui or (PlayerGui or PlayerGui) or (PlayerGui or not PlayerGui or (not PlayerGui or not PlayerGui))) and ((HttpService or PlayerGui or PlayerGui and not HttpService) and (PlayerGui or HttpService or (PlayerGui or HttpService)))) then
    s__34 = game:GetService("ReplicatedStorage")
    s__21 = game:GetService("RunService")
    m_ = game:GetService("UserInputService")
else
    s__21 = game:GetService("ReplicatedStorage")
    m_ = game:GetService("RunService")
    s__34 = game:GetService("UserInputService")
end
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
my = s__18.LocalPlayer
PlayerGui = my:WaitForChild("PlayerGui")
if getgenv then
    getgenv().gethui = function()
        return PlayerGui
    end
end
MutationUtil, GearUtil, LaunchUtil, RebirthUtil, SpinsUtil, DataUtil, PlotsUtil, RarityTiers, SellItemEvent, BuyUpgrade, GetUpgradeStats, GetPlayerUpgrades, Gears, mQ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fns.fn6)
local s__23 = "Build A Cart"
local s__5 = require(s__34:WaitForChild("Framework"))
MutationUtil = s__5.Modules.MutationUtil
GearUtil = s__5.Modules.GearUtil
LaunchUtil = s__5.Modules.LaunchUtil
RebirthUtil = s__5.Modules.RebirthUtil
SpinsUtil = s__5.Modules.SpinsUtil
DataUtil = s__5.Modules.DataUtil
PlotsUtil = s__5.Modules.PlotsUtil
RarityTiers = s__5.Modules.RarityTiers
s__18 = s__34:WaitForChild("Remotes")
SellItemEvent = s__18:WaitForChild("SellItemEvent")
BuyUpgrade = s__18:WaitForChild("BuyUpgrade")
GetUpgradeStats = s__18:WaitForChild("GetUpgradeStats")
GetPlayerUpgrades = s__18:WaitForChild("GetPlayerUpgrades")
Gears = s__34:WaitForChild("Assets"):WaitForChild("Gears")
local s__37 = ""
mQ = getgenv().Library
pcall(fn835)
if setthreadidentity then
    setthreadidentity(8)
end
s__3, mu, mq, Options, mi, mg, me, l8, l3, lZ, lU = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
s__18 = 31
repeat
    s__34 = (s__18 * 3 + 0) % 4 + 1
    if s__34 <= 2 then
        if s__34 <= 1 then
            s__5 = (vector.create((s__18 * 4 + 6) % 11 + 1, (s__18 * 9 + 5) % 13 + 1, (s__18 * 5 + 17) % 17 + 1))
            s__8 = (vector.create((s__18 * 2 + 6) % 11 + 1, (s__18 * 2 + 2) % 13 + 1, (s__18 * 1 + 7) % 17 + 1))
            local tp = vector.dot(s__5, s__8)
            if tp * tp <= vector.dot(s__5, s__5) * vector.dot(s__8, s__8) then
                lU = {}
            else
                l8 = {}
            end
            s__18 = (s__18 + 15) % 32
        else
            s__5 = (vector.create((s__18 * 7 + 2) % 11 + 1, (s__18 * 5 + 9) % 13 + 1, (s__18 * 9 + 15) % 17 + 1))
            s__8 = (vector.create((s__18 * 3 + 3) % 11 + 1, (s__18 * 1 + 1) % 13 + 1, (s__18 * 8 + 11) % 17 + 1))
            s__39 = (vector.create((s__18 * 3 + 5) % 5 + 1, (s__18 * 1 + 5) % 7 + 1, (s__18 * 5 + 2) % 9 + 1))
            if math.abs((vector.angle(s__5, s__8, s__39))) - math.abs((vector.angle(s__8, s__5, s__39))) == 0 then
                s__3 = getgenv().ThemeManager
                mu = getgenv().SaveManager
                mq = mQ.Toggles
                Options = mQ.Options
                mi = "https://discord.gg/K7Qxnxkk46"
            else
                mu = getgenv().ThemeManager
                mQ = getgenv().SaveManager
                Options = nil
                s__37 = nil
                mq = "https://discord.gg/K7Qxnxkk46"
            end
            s__18 = (s__18 + 19) % 32
        end
    elseif s__34 <= 3 then
        s__34 = (vector.create((s__18 * 3 + 9) % 11 + 1, (s__18 * 9 + 10) % 13 + 1, (s__18 * 10 + 16) % 17 + 1))
        local tu = vector.floor(s__34) + vector.ceil(s__34 * -1)
        if vector.dot(tu, tu) == 0 then
            mg = "https://discord.gg/K7Qxnxkk46"
            me = "Always"
            l8 = "Count"
            l3 = { "Distance Per Currency", "Currency Multiplier", "Currency" }
        else
            l3 = "https://discord.gg/K7Qxnxkk46"
            mg = "Always"
            me = "Count"
            l8 = { "Currency Multiplier", "Currency", "Distance Per Currency" }
        end
        s__18 = (s__18 + 3) % 32
    else
        if (s__18 * 2 + 6) * 10 % 3 == ((s__18 * 2 + 6) * 10 + 6) % 3 then
            lZ = {
                ["Distance Per Currency"] = "DPC",
                ["Currency Multiplier"] = "CurrencyMulti",
                Currency = "CurrencyBuff"
            }
        else
            mu = {
                Currency = "CurrencyBuff",
                ["Distance Per Currency"] = "DPC",
                ["Currency Multiplier"] = "CurrencyMulti"
            }
        end
        s__18 = (s__18 + 31) % 32
    end
until (s__18 * 31 + 31) % 32 == 28
s__34 = {}
for i, child in Gears:GetChildren() do
    for i, child in child:GetChildren() do
        s__18 = not s__34[child.Name]
        if s__18 ~= false then
            s__18 = typeof(child:GetAttribute("Price")) == "number"
        end
        if s__18 then
            s__34[child.Name] = true
            lU[#lU + 1] = child.Name
        end
    end
end
table.sort(lU)
s__18 = {}
s__34 = RarityTiers.Tiers
if type(s__34) == "table" then
    s__5 = {}
    for k, v in s__34 do
        s__34 = tonumber(k)
        s__37 = s__34 and type(v) == "table" and type(v.Name) == "string"
        if s__37 then
            s__5[#s__5 + 1] = { s__34, v.Name }
        end
    end
    s__37 = 7
    repeat
        s__34 = {
            "olordmkf",
            "nyhlzvhnawm",
            "ahvvu",
            "kjgaycx",
            "fyhzsvqsh",
            "zruxhkaea",
            "oislbpstwxw",
            "ozrlgfe",
            "yoekleroo",
            "iyafvuhygi",
            "cndfvre"
        }
        local tK = s__37
        s__8 = s__34[tK % 11 + 1]
        if s__8:len() >= s__8:gsub("(.)", "%1%1", tK % 3 % 2 + 1):len() then
            table.sort(s__5, fn612)
        else
            table.sort(s__5, fn612)
        end
        s__37 = (s__37 + 6) % 8
    until (s__37 * 7 + 1) % 8 == 4
    for k, v in s__5 do
        s__18[#s__18 + 1] = v[2]
    end
end
if #s__18 == 0 then
    s__34 = 2
    repeat
        local tY = bit32.rrotate(bit32.bxor(bit32.lrotate(s__34, 5), string.byte(tostring(s__34))), 31)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(tY, 733748899), 3663746399), (bit32.bxor(bit32.band(tY, 3561218396), 2401411461))), 3663746399), 2401411461) ~= tY then
            s__18 = {
                "Secret",
                "Legendary",
                "Mythic",
                "Eternal",
                "Pinnacle",
                "Common",
                "Heavenly",
                "Divine",
                "Infinite",
                "Transcendent",
                "Epic",
                "Rare"
            }
        else
            s__18 = {
                "Common",
                "Rare",
                "Epic",
                "Legendary",
                "Mythic",
                "Divine",
                "Secret",
                "Heavenly",
                "Pinnacle",
                "Transcendent",
                "Eternal",
                "Infinite"
            }
        end
        s__34 = (s__34 + 2) % 8
    until (s__34 * 7 + 2) % 8 == 6
end
mZ, mS, mL, mG, mC, mv, ms, mn, mV, mP, mK, mE, lN, mm, ma, lV, lM, lR, m5, mw, md, l0, lO, m7, mH, mo, lW, lF, lA, mz, mf, lT, lE, lL, m3, mj, lI, mM, mc, m6, mW, lC, mI, l6, mU, mF, l9, s__8 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
mm = fns.fn119
ma = fn666
lV = fns.fn508
lM = fns.fn354
local s__31 = "#7fd47f"
local s__15 = "#6ec1ff"
mZ = "#e8a34d"
local s__30 = "#8b93a3"
mS = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
mL = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
if (lR or not m3) and "#7fd47f" or not s__8 and not m3 and (s__31 and lR) or not ((lR or not m3) and "#7fd47f" or not s__8 and not m3 and (s__31 and lR)) then
    mG = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
    mC = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
    mv = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
    ms = ""
else
    ms = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
    mG = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
    mC = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
    mv = ""
end
mn = ""
local s__44 = "#345d9d"
local s__13 = "#f7931a"
local s__27 = "#627eea"
local s__42 = "#26a17b"
local s__10 = "#14f195"
local s__25 = "#0070ba"
s__39 = "#008cff"
lR = fn767
m5 = fns.fn189
mw = fns.fn38
md = fns.fn442
l0 = fns.fn206
lO = fns.fn342
m7 = fn668
mH = fn907
mo = fn879
lW = fn876
lF = fn811
lA = fn751
mV = nil
mP = nil
mK = 0
mE = 0
mz = fn733
mf = fn859
lT = fn910
lE = function()
    local o8
    o8 = nil
    o8 = lW()
    local o9 = o8 and lF()
    local pa = not o9 or lT()
    local pa_2
    if pa then
        return
    end
    mf(o8)
    local o9_1 = tonumber(mw("DriveSpeed", 4)) or 4
    local max = math.max
    local pb = mV or 50
    local pb_1
    local pc = max(pb * o9_1, 20)
    o8:SetAttribute("Speed", pc)
    local VehicleSeat = o8:FindFirstChildWhichIsA("VehicleSeat", true)
    if VehicleSeat then
        VehicleSeat.Throttle = 1
        pcall(function()
            VehicleSeat.ThrottleFloat = 1
        end)
    end
    local o9_3 = {}
    pa_2, pb_1 = pcall(function()
        return o8:QueryDescendants("LinearVelocity")
    end)
    local pd = pa_2 and type(pb_1) == "table"
    if pd then
        o9_3 = pb_1
    else
        for i, descendant in o8:GetDescendants() do
            if descendant:IsA("LinearVelocity") then
                o9_3[#o9_3 + 1] = descendant
            end
        end
    end
    for k, v in o9_3 do
        v.VectorVelocity = Vector3.new(0, 0, -pc * 1.25)
    end
end
lL = fns.fn166
m3 = fns.fn374
mj = fns.fn373
lN = my:GetAttributeChangedSignal("Launched"):Connect(fns.fn282)
if (m7 and mj or m7 and mL or (m7 or mE) and (not mj and false)) and (mj and false and (not mj or m7) or (not mE and false or m7 and not mE)) or not ((m7 and mj or m7 and mL or (m7 or mE) and (not mj and false)) and (mj and false and (not mj or m7) or (not mE and false or m7 and not mE))) then
    lI = fn827
else
    mm = fn827
end
mM = fn726
mc = fn669
m6 = fn516
mW = fn557
lC = fns.fn495
mI = fn547
if (mf and lE and false or (not mf or lE) and (not mf and not mf)) and (false and not mf and (false or lE) or (lE and mf or (not mf or lE))) and not ((mf and lE and false or (not mf or lE) and (not mf and not mf)) and (false and not mf and (false or lE) or (lE and mf or (not mf or lE)))) then
    lN = function()
        local qE_2
        local qD_2
        local qB = m5("AutoBuyShopItems")
        if next(qB) == nil then
            return
        end
        for k, v in lU do
            local qO = v
            if qB[qO] then
                local qC = false
                qD_2, qE_2 = pcall(function()
                    return GearUtil:CanBuyGear(my, qO)
                end)
                if qD_2 then
                    qC = qE_2 == true
                end
                if qC then
                    GearUtil.RemoteEvent:FireServer("BuyGear", qO)
                    task.wait(0.2)
                end
            end
        end
    end
else
    l6 = function()
        local qE_1
        local qD_1
        local qB = m5("AutoBuyShopItems")
        if next(qB) == nil then
            return
        end
        for k, v in lU do
            local qO = v
            if qB[qO] then
                local qC = false
                qD_1, qE_1 = pcall(function()
                    return GearUtil:CanBuyGear(my, qO)
                end)
                if qD_1 then
                    qC = qE_1 == true
                end
                if qC then
                    GearUtil.RemoteEvent:FireServer("BuyGear", qO)
                    task.wait(0.2)
                end
            end
        end
    end
end
mU = function()
    local qV_1
    local qU_1
    local qT_1, qT_4
    local qR = m5("AutoBuyUpgrade")
    local qS
    qT_1, qU_1 = pcall(function()
        return GetPlayerUpgrades:InvokeServer()
    end)
    if qT_1 then
        qS = qU_1
    end
    if type(qS) ~= "table" then
        return
    end
    for k, v in l3 do
        local qP, qQ
        if qR[v] then
            qP = lZ[v]
            local qT_2 = qS[qP]
            local qU_2 = type(qT_2) == "table" and #qT_2
            qQ = qU_2 or 0
            local qU_3 = nil
            qT_4, qV_1 = pcall(function()
                return GetUpgradeStats:InvokeServer(qP, qQ)
            end)
            if qT_4 then
                qU_3 = qV_1
            end
            local qT_5 = type(qU_3) == "table" and type(qU_3.Cost) == "number" and mH() >= qU_3.Cost
            if qT_5 then
                pcall(function()
                    BuyUpgrade:InvokeServer(qP)
                end)
                task.wait(0.25)
            end
        end
    end
end
mF = fns.fn87
l9 = fn795
s__5 = mQ:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = mi, Copyable = true }, "|", s__23 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
pcall(fns.fn339)
local s__47 = {
    Info = s__5:AddTab("Info", "info"),
    Main = s__5:AddTab("Main", "gauge"),
    Player = s__5:AddTab("Player", "person-standing"),
    Settings = s__5:AddTab("Settings", "settings")
}
s__8 = fns.fn331
for k, v in s__47 do
    s__8(v)
end
mB, s__5, s__17, Label, l5, s__37 = nil, nil, nil, nil, nil, nil
s__34 = 20
repeat
    s__8 = (s__34 * 2 + 2) % 3 + 1
    if s__8 <= 2 then
        if s__8 <= 1 then
            s__8 = {
                "orxglvcmgms",
                "qnn",
                "legj",
                "gko",
                "bkotkjviik",
                "hdsa",
                "fidddelcu",
                "zpmoxpebw",
                "dfsiuvftbnn",
                "fdzsns",
                "dkiz",
                "zlhaikmswno",
                "mtrbthdohml"
            }
            if s__8[(s__34 * 33 + 82) % 13 + 1] < s__8[(s__34 * 33 + 82) % 13 + 1] then
                s__47 = "Unknown"
                pcall(fn573)
                s__31 = s__5.Info:AddLeftGroupbox("Account", "circle-user")
                s__31:AddLabel(s__17("User", nil, mZ), true)
                s__31:AddLabel(s__17("Status", "Keyless", mZ), true)
                s__31:AddLabel(s__17("Executor", "Unknown", mZ), true)
                lM = s__5.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                lM:AddLabel(mB(s__15 .. " [" .. tostring(game.PlaceId) .. "]", lV), true)
                lM:AddLabel(s__17("Place ID", tostring(game.PlaceId), lV), true)
                my = lM:AddLabel(s__17("Session time", "0s", Label), true)
            else
                mB = "Unknown"
                pcall(fn573)
                s__5 = s__47.Info:AddLeftGroupbox("Account", "circle-user")
                s__5:AddLabel(lM("User", my.Name, s__31), true)
                s__5:AddLabel(lM("Status", "Keyless", s__31), true)
                s__5:AddLabel(lM("Executor", mB, s__31), true)
                s__17 = s__47.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                s__17:AddLabel(lV(s__23 .. " [" .. tostring(game.PlaceId) .. "]", s__15), true)
                s__17:AddLabel(lM("Place ID", tostring(game.PlaceId), s__15), true)
                Label = s__17:AddLabel(lM("Session time", "0s", mZ), true)
            end
            s__34 = (s__34 + 23) % 24
        else
            local to = bit32.rrotate(bit32.bxor(bit32.lrotate(s__34, 18), string.byte(tostring(s__37))), 30)
            if bit32.bxor(bit32.lrotate(bit32.bxor(to, 3563279119), 28), 4249236784) ~= bit32.lrotate(to, 28) then
                s__17 = tostring(game.JobId)
            else
                l5 = tostring(game.JobId)
            end
            s__34 = (s__34 + 8) % 24
        end
    else
        s__8 = (vector.create((s__34 * 1 + 3) % 11 + 1, (s__34 * 11 + 7) % 13 + 1, (s__34 * 6 + 4) % 17 + 1))
        s__1 = (vector.create((s__34 * 3 + 4) % 11 + 1, (s__34 * 1 + 12) % 13 + 1, (s__34 * 11 + 5) % 17 + 1))
        s__33 = (vector.create((s__34 * 3 + 2) % 11 + 1, (s__34 * 5 + 13) % 13 + 1, (s__34 * 5 + 13) % 17 + 1))
        s__19 = (vector.create((s__34 * 4 + 1) % 11 + 1, (s__34 * 2 + 4) % 13 + 1, (s__34 * 11 + 10) % 17 + 1))
        if vector.dot(vector.cross(s__8, s__1), (vector.cross(s__33, s__19))) == vector.dot(s__8, s__33) * vector.dot(s__1, s__19) - vector.dot(s__8, s__19) * vector.dot(s__1, s__33) then
            s__37 = #l5 > 18
        else
            l5 = #s__37 > 18
        end
        s__34 = (s__34 + 23) % 24
    end
until (s__34 * 1 + 12) % 24 == 14
if s__37 then
    s__34 = 4
    repeat
        if (not s__34 or s__34 or s__34 and not s__34) and (not s__34 and not s__34 or not s__34 and s__34) and not ((not s__34 or s__34 or s__34 and not s__34) and (not s__34 and not s__34 or not s__34 and s__34)) then
            l5 = string.sub(s__37, 1, 18) .. "..."
        else
            s__37 = string.sub(l5, 1, 18) .. "..."
        end
        s__34 = (s__34 + 0) % 8
    until (s__34 * 7 + 4) % 8 == 0
end
s__34 = s__37 or l5
lJ, connection, connection2, connection3, lY, connection4, mr, ml, connection5, connection6, mx, l4, mR, mh, l_, mN = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
s__5 = s__34
s__17:AddLabel(lM("Server", s__5, s__30), true)
s__17:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
lJ = os.clock()
task.spawn(worker)
local s__38 = s__47.Info:AddRightGroupbox("Scripts", "package")
s__38:AddLabel(lV("Included in this hub", s__30), true)
s__38:AddLabel(lV(s__23, s__15), true)
local s__22 = s__47.Info:AddRightGroupbox("Features", "list")
s__22:AddLabel(lV("Auto Farm", s__15), true)
s__22:AddLabel(lV("Auto Sell", mZ), true)
s__22:AddLabel(lV("Auto Buy", s__30), true)
local s__4 = s__47.Info:AddRightGroupbox("Socials", "link")
s__4:AddButton({ Text = "Discord", Func = ma })
s__4:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
s__1 = s__47.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
s__1:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
s__1:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
s__1:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
s__1:AddButton({ Text = "Copy Discord Invite", Func = ma })
s__8 = s__47.Info:AddRightGroupbox("Donations", "heart")
s__8:AddLabel(lV("All donations are optional but appreciated.", mZ), true)
s__8:AddLabel(lV("If you donate you get a special role, just PING after you donate.", s__31), true)
s__8:AddDivider()
s__8:AddLabel(lV("LTC / Litecoin", s__44), true)
s__8:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
s__8:AddLabel(lV("BTC / Bitcoin", s__13), true)
s__8:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
s__8:AddLabel(lV("ETH / Ethereum", s__27), true)
s__8:AddButton({ Text = "Copy Ethereum Address", Func = fns.onCopyEthereumAddress })
s__8:AddLabel(lV("USDT", s__42), true)
s__8:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
s__8:AddLabel(lV("Solana", s__10), true)
s__8:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
s__8:AddLabel(lV("PayPal", s__25), true)
s__8:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
s__8:AddLabel(lV("Venmo", s__39), true)
s__8:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
s__8:AddDivider()
s__8:AddLabel(lV("Don't have any of the listed currencies but still wanna donate?", s__30), true)
s__8:AddLabel(lV("DM me and we'll work something out.", s__15), true)
local s__43 = s__47.Info:AddRightGroupbox("FAQ", "circle-help")
s__43:AddLabel("Where do I get a good config?", true)
s__43:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
s__43:AddLabel("How do I import / export configs?", true)
s__43:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
s__43:AddLabel("How do I report bugs?", true)
s__43:AddLabel("Join the Discord and post it in the bugs channel.", true)
s__43:AddLabel("How do I make suggestions?", true)
s__43:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
s__43:AddLabel("How do I get help or updates?", true)
s__43:AddLabel("Join the Discord, updates and support are posted there first.", true)
local s__12 = s__47.Main:AddLeftGroupbox("Drive", "gauge")
s__12:AddToggle("AutoDrive", { Text = "Auto Drive", Default = false })
s__12:AddSlider("DriveSpeed", { Text = "Drive Speed", Default = 4, Min = 1, Max = 100, Rounding = 1 })
local s__26 = s__47.Main:AddLeftGroupbox("Sell", "circle-dollar-sign")
s__26:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
s__26:AddDropdown("AutoSellMode", { Text = "When", Values = { me, l8 }, Default = me })
s__26:AddSlider("AutoSellCount", { Text = "Item Count", Default = 10, Min = 1, Max = 200, Rounding = 0 })
s__26:AddDropdown("KeepRarities", {
    Text = "Keep Rarities",
    Values = s__18,
    Default = {},
    Multi = true,
    Expandable = true,
    ExpandColumns = 2
})
local s__41 = s__47.Main:AddRightGroupbox("Shop", "shopping-bag")
s__41:AddToggle("AutoBuyShop", { Text = "Auto Buy Shop", Default = false })
s__41:AddDropdown("AutoBuyShopItems", { Text = "Items", Values = lU, Default = {}, Multi = true, Expandable = true, ExpandColumns = 2 })
local s__24 = s__47.Main:AddRightGroupbox("Upgrades", "trending-up")
s__24:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Cart Upgrades", Default = false })
s__24:AddDropdown("AutoBuyUpgrade", {
    Text = "Upgrade",
    Values = l3,
    Default = { "Distance Per Currency", "Currency Multiplier", "Currency" },
    Multi = true,
    Expandable = true,
    ExpandColumns = 1
})
local s__7 = s__47.Main:AddRightGroupbox("Misc", "sparkles")
s__7:AddToggle("AutoSpin", { Text = "Auto Spin Wheel", Default = false })
s__7:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
local s__36 = s__47.Player:AddLeftGroupbox("Movement", "footprints")
s__36:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
s__36:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
s__36:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
s__36:AddToggle("NoClip", { Text = "NoClip", Default = false })
s__36:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
s__19 = s__47.Player:AddRightGroupbox("Fly", "feather")
s__19:AddToggle("Fly", { Text = "Fly", Default = false })
s__19:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
mq.AutoDrive:OnChanged(fn645)
task.spawn(worker2)
connection = s__21.Heartbeat:Connect(fns.onHeartbeat)
task.spawn(fns.worker3)
task.spawn(worker4)
mx = function(gg)
    pcall(function()
        GuiService:SetGameplayPausedNotificationEnabled(not gg)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not gg
        end
    end)
    if not gg then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(my, "GameplayPaused", false)
        else
            my.GameplayPaused = false
        end
    end)
end
mq.AntiGameplayPause:OnChanged(fns.fn210)
mq.Fly:OnChanged(fns.fn194)
mq.WalkSpeedEnabled:OnChanged(fn904)
connection2 = s__21.Stepped:Connect(fns.onStepped)
connection3 = m_.JumpRequest:Connect(fns.onJumpRequest)
lY = Workspace.CurrentCamera
connection4 = s__21.RenderStepped:Connect(fns.onRenderStepped)
s__33 = s__47.Settings:AddLeftGroupbox("Menu", "menu")
s__33:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
mQ.ToggleKeybind = Options.MenuKeybind
mr = tick()
ml = tick()
pcall(function()
    for k, v in getconnections(my.Idled) do
        local rX = v
        pcall(function()
            rX:Disable()
        end)
    end
end)
l4 = fns.fn510
connection5 = m_.InputBegan:Connect(fns.onInputBegan)
connection6 = m_.InputChanged:Connect(onInputChanged)
s__33:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
s__33:AddButton("Unload", onUnload)
s__3:SetLibrary(mQ)
s__3:SetFolder("TempoHub")
s__3:SaveDefault("Evil Hello Kitty")
s__3:ApplyToTab(s__47.Settings)
s__3:LoadDefault()
mu:SetLibrary(mQ)
mu:IgnoreThemeSettings()
mu:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
mu:SetFolder("TempoHub/BuildACart")
local s__9 = mu:BuildConfigSection(s__47.Settings)
mR = fn886
mh = fns.fn244
l_ = fns.fn139
mN = function(hO)
    local sx
    sx = nil
    local sy = type(hO) ~= "table"
    local sC = if sy then 1 else 0
    local sA = 3212 * sC + 3315 * (1 - sC)
    local sB = 3889 * sC + 3911 * (1 - sC)
    if not ((sA * 1402 + sB * 3650 + sA * sB) % 16777213 == 14412329) then
        sy = type(hO.idx) ~= "string"
    end
    local sC_1 = if sy then 1 else 0
    local sA_1 = 2214 * sC_1 + 3146 * (1 - sC_1)
    local sB_1 = 3619 * sC_1 + 3127 * (1 - sC_1)
    if not ((sA_1 * 3201 + sB_1 * 1429 + sA_1 * sB_1) % 16777213 == 3493818) then
        sy = type(hO.type) ~= "string"
    end
    if not sy then
        sy = mu.Ignore[hO.idx]
    end
    if sy then
        return false
    end
    sx = mR(hO.type, hO.idx)
    if not sx then
        return false
    end
    local sy_1 = pcall(function()
        if hO.type == "Input" then
            if type(hO.text) ~= "string" then
                return
            end
            sx:SetValue(hO.text)
        elseif hO.type == "ColorPicker" then
            sx:SetValueRGB(Color3.fromHex(hO.value), hO.transparency)
        elseif hO.type == "KeyPicker" then
            sx:SetValue({ hO.key, hO.mode, hO.modifiers })
            if hO.mode == "Toggle" and hO.toggled ~= nil then
                sx.Toggled = hO.toggled
                sx:Update()
            end
        else
            sx:SetValue(hO.value)
        end
    end)
    return sy_1
end
s__9:AddDivider()
s__9:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
s__9:AddButton("Export Config to Clipboard", fns.onExportConfigToClipboard)
s__9:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
mu:LoadAutoloadConfig()
task.spawn(fns.antiGameplayPauseLoop)
task.spawn(fns.antiAfkLoop)
mQ:OnUnload(fn858)
mQ:Notify("Build A Cart loaded")
end)(...)
