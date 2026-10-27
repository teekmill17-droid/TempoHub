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
getgenv().TempoHoodSubtitle = "MAKE SOCCER PLAYERS"
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
local xa_12, xa_25
local ot
local pa
local oS
local VirtualUser
local oz
local pg
local Final
local pF
local pm
local oi
local o3
local oL
local SetAutoRoll
local oR
local RequestRoll
local Workspace
local oX
local oE
local oh
local o2
local pK
local oK
local Library
local op
local Options
local oQ
local px
local ox
local pe
local oW
local og
local o1
local pJ
local oJ
local o7
local oP
local pw
local connection2
local Toggles
local oV
local UserInputService
local oC
local SaveManager
local connection3
local o0
local pI
local oI
local pp
local om
local o6
local oO
local pc
local oU
local pB
local oB
local pi
local oe
local o_
local oH
local AutoCollectToggleEvent
local oN
local pu
local ou
local PlotPlayerCollectRequest
local oT
local oA
local oZ
local pG
local Label
local oj
local o4
local oM
local HttpService
function fns.fn3(b3)
    local sb = oR(b3)
    local sc = sb and sb:FindFirstChild("ProxPart")
    local sb_1 = sc
    if sc then
        sc = sb_1:FindFirstChildWhichIsA("ProximityPrompt")
    end
    return sc, sb_1
end
function fns.fn10()
    local sI = oQ()
    if not sI then
        return
    end
    local Upgrades = sI:FindFirstChild("Upgrades")
    if not Upgrades then
        return
    end
    for i, descendant in ipairs(Upgrades:GetDescendants()) do
        local attr = descendant:GetAttribute("UpgradePath")
        if attr then
            local UpgradeName = descendant:FindFirstChild("UpgradeName", true)
            local sK = UpgradeName and UpgradeName.Text
            local sK_1 = sK ~= ""
            local sL = typeof(sK) == "string" and sK_1
            if sL then
                oj({ label = sK, kind = "padLabel", path = attr, name = sK })
            end
        end
    end
    if Options.UpgradeSelect and Options.UpgradeSelect.SetValues then
        pcall(function()
            Options.UpgradeSelect:SetValues(ot)
        end)
    end
end
function fns.fn82()
    return pa.Character
end
function fns.onInputBegan()
    pi = tick()
end
function fns.fn113(am, an)
    if setclipboard then
        setclipboard(am)
    elseif toclipboard then
        toclipboard(am)
    end
    Library:Notify(an)
end
function fns.onCopyJoinScript_JobID()
    local vf = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, oA)
    if setclipboard then
        setclipboard(vf)
    elseif toclipboard then
        toclipboard(vf)
    end
    Library:Notify("Copied join script to clipboard")
end
function fns.fn134()
    pcall(function()
        if pa:GetAttribute("HasAutoRollGamePass") == true then
            SetAutoRoll:InvokeServer(false, oi())
        end
    end)
    pcall(function()
        AutoCollectToggleEvent:FireServer(false)
    end)
    pG(false)
    if connection2 then
        connection2:Disconnect()
    end
    if connection3 then
        connection3:Disconnect()
    end
    select("#", "Unloaded!")
end
function fns.onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local vL_1 = pK()
        if vL_1 then
            vL_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
function fns.fn146()
    pG(Toggles.AntiGameplayPause.Value)
end
function fns.fn151()
    local rN = oM("AutoBuyTiers")
    local rO = {}
    for i, v in ipairs(o_) do
        rO[v] = rN[v] == true
    end
    return rO
end
function fns.fn154()
    if pw("AutoRoll") then
        return
    end
    local sA = oQ()
    local sB = oe(sA)
    local sA_1 = sB and pu(sB)
    if sA_1 then
        oz(sB)
    end
end
function fns.fn159(jz, jA)
    local Type = jA.Type
    if Type == "Toggle" then
        return { idx = jz, type = "Toggle", value = jA.Value == true }
    elseif Type == "Slider" then
        return { idx = jz, type = "Slider", value = tostring(jA.Value) }
    elseif Type == "Dropdown" then
        return { idx = jz, type = "Dropdown", multi = jA.Multi == true, value = jA.Value }
    elseif Type == "Input" then
        local wb = jA.Value or ""
        return { idx = jz, type = "Input", text = tostring(wb) }
    elseif Type == "ColorPicker" then
        return { idx = jz, type = "ColorPicker", value = jA.Value:ToHex(), transparency = jA.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = jz,
            type = "KeyPicker",
            mode = jA.Mode,
            key = jA.Value,
            modifiers = jA.Modifiers,
            toggled = jA.Toggled
        }
    else
        return nil
    end
end
function fns.onCopySolanaAddress()
    o3(oH, "Copied Solana address")
end
function fns.onCopyBitcoinAddress()
    o3(oT, "Copied Bitcoin address")
end
function fns.fn274(cb)
    if Final then
        return Final.Tier or Final.TierName
    end
    local sf_2 = oR(cb)
    local sg = sf_2 and sf_2:FindFirstChild("ActiveCoach")
    if not sg then
        return nil
    end
    local attr2 = sg:GetAttribute("FirstTimeRarityReveal")
    local sh = attr2 ~= ""
    local si = typeof(attr2) == "string" and sh
    if si then
        return attr2
    end
    local attr = sg:GetAttribute("CoachPoolTemplateFolder")
    local sf_4 = attr ~= ""
    local sh_1 = typeof(attr) == "string" and sf_4
    if sh_1 then
        return attr:gsub("Coach$", "")
    end
    return nil
end
function fns.onInputChanged(jj)
    local UserInputType = jj.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        pi = tick()
    end
end
function fns.antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            pG(true)
        end
    end
end
function fns.onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = pa.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local vA_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if vA_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
function fns.fn302(jr, js)
    local v7_1 = (jr == "Toggle" and Toggles or Options)[js]
    local v6_2 = type(v7_1) == "table" and v7_1.Type == jr
    return v6_2 and v7_1 or nil
end
function fns.fn360(b0)
    local r9 = b0 and b0:FindFirstChild("CoachRollSystem")
    return r9
end
function fns.worker4()
    while not Library.Unloaded do
        if pw("AutoSell") then
            pcall(o0)
        end
        if pw("AutoCollect") then
            pcall(pI)
        end
        task.wait(0.9)
    end
end
function fns.onRscripts()
    if setclipboard then
        setclipboard(oZ)
    elseif toclipboard then
        toclipboard(oZ)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
function fns.fn408(aw, ax, ay)
    return string.format("<b>%s</b> %s %s", aw, oB("-", "#5a6070"), oB(ax, ay))
end
function fns.fn413(bV)
    local r3_1
    local r2_1
    if typeof(bV) ~= "string" then
        return nil
    end
    local r1 = bV:gsub("[,$%s]", "")
    r2_1, r3_1 = r1:match("^(%d+%.?%d*)([kKmMbB]?)$")
    local r1_1 = tonumber(r2_1)
    if not r1_1 then
        return nil
    end
    if r3_1 == "k" or r3_1 == "K" then
        r1_1 *= 1000
    else
        local r2_3 = r3_1 == "M"
        local r4_1 = r3_1 == "m"
        local r8 = if r4_1 then 1 else 0
        local r6 = 219 * r8 + 1652 * (1 - r8)
        local r7 = 1585 * r8 + 3913 * (1 - r8)
        if not ((r6 * 3066 + r7 * 530 + r6 * r7) % 16777213 == 1858619) then
            r4_1 = r2_3
        end
        if r4_1 then
            r1_1 *= 1000000
        else
            if r3_1 == "b" or r3_1 == "B" then
                r1_1 *= 1000000000
            end
        end
    end
    return r1_1
end
function fns.fn416(aL, aM)
    local qS = Options[aL]
    if qS == nil then
        return aM
    end
    return qS.Value
end
function fns.worker6()
    while not Library.Unloaded do
        if pw("AutoRoll") then
            if pa:GetAttribute("HasAutoRollGamePass") == true then
                o6()
                if pw("AutoBuy") then
                    pcall(oX)
                end
                task.wait(o4("AutoRollDelay", 2.1))
            else
                pcall(oK)
                task.wait(o4("AutoRollDelay", 2.1))
            end
        else
            if pw("AutoBuy") then
                pcall(oX)
            end
            task.wait(0.6)
        end
    end
end
function fns.worker2()
    while not Library.Unloaded do
        task.wait(2)
        if pw("AntiAfk") then
            local w_ = tick() - pi
            local w0 = tick() - pc
            if w_ >= 300 and w0 >= 60 then
                pcall(oS)
            else
                if w_ < 300 and w0 >= 300 then
                    pcall(oS)
                end
            end
        end
    end
end
function fns.fn501()
    local q2 = oh()
    local q3 = q2 and q2:FindFirstChildOfClass("Humanoid")
    return q3
end
function fns.fn531(at, au)
    return string.format('<font color="%s">%s</font>', au, at)
end
function fns.worker3()
    while not Library.Unloaded do
        if pw("AutoFuse") then
            pcall(pp)
        end
        task.wait(1)
    end
end
local function fn579()
    local wh = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local wi = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if wi then
                local wi_1 = o2(k, v)
                if wi_1 then
                    wh[#wh + 1] = wi_1
                end
            end
        end
    end
    table.sort(wh, function(jN, jO)
        if jN.type ~= jO.type then
            return jN.type < jO.type
        end
        return jN.idx < jO.idx
    end)
    return { objects = wh }
end
local function fn604()
    local tr = oQ()
    if not tr then
        return
    end
    local Upgrades = tr:FindFirstChild("Upgrades")
    if not Upgrades then
        return
    end
    for i, descendant in ipairs(Upgrades:GetDescendants()) do
        local tr_1 = Library.Unloaded or not pw("AutoBuyPads")
        if tr_1 then
            break
        elseif descendant:GetAttribute("UpgradePath") then
            oI(descendant)
        end
    end
end
local function fn629(f4)
    if not f4 then
        return nil
    elseif f4:GetAttribute("IsLeaguePlayer") ~= true then
        return nil
    else
        local ug = (f4:GetAttribute("CardToolId"))
        local uq = if ug then 1 else 0
        local uo = 422 * uq + 3523 * (1 - uq)
        local up = 1624 * uq + 1757 * (1 - uq)
        if not ((uo * 1816 + up * 1723 + uo * up) % 16777213 == 4249832) then
            ug = f4:GetAttribute("InventoryCardId")
        end
        local uh = ug
        local ug_1 = uh == ""
        local ui = typeof(uh) ~= "string" or ug_1
        if ui then
            return nil
        end
        local ug_2 = o4("FuseMinOVR", 0)
        local ui_1 = o4("FuseMaxOVR", 99)
        local uj = o4("FuseMaxValue", 100000)
        local uk = (tonumber(f4:GetAttribute("OVR")))
        local ut = if uk then 1 else 0
        local ur = 1767 * ut + 1744 * (1 - ut)
        local us = 1010 * ut + 179 * (1 - ut)
        if not ((ur * 586 + us * 1413 + ur * us) % 16777213 == 4247262) then
            uk = 0
        end
        local ul = uk
        local uk_1 = tonumber(f4:GetAttribute("Valuation")) or 0
        if ul < ug_2 or ul > ui_1 then
            return nil
        elseif uk_1 > uj then
            return nil
        else
            local ug_3 = {
                ItemId = uh,
                LeagueId = f4:GetAttribute("LeagueId"),
                PlayerName = f4:GetAttribute("PlayerName"),
                OVR = ul
            }
            local ui_2 = (tonumber(f4:GetAttribute("Quantity")))
            local uq_1 = if ui_2 then 1 else 0
            local uo_1 = 3012 * uq_1 + 3955 * (1 - uq_1)
            local up_1 = 3626 * uq_1 + 600 * (1 - uq_1)
            if not ((uo_1 * 600 + up_1 * 1001 + uo_1 * up_1) % 16777213 == 16358338) then
                ui_2 = 1
            end
            return ug_3, ui_2
        end
    end
end
local function fn631(dh, di)
    local sG = typeof(dh) ~= "string" or typeof(di) ~= "string"
    if sG then
        return false
    elseif dh == di then
        return true
    elseif di == "TrainingGroundUpgrades" then
        return dh:find("^TrainingGroundUpgrades") ~= nil
    else
        return false
    end
end
local function fn633(bk)
    local rt = px()
    local ru = not rt or typeof(bk) ~= "Vector3"
    if ru then
        return false
    end
    rt.CFrame = CFrame.new(bk + Vector3.new(0, 3, 0))
    return true
end
local function fn647(aQ)
    local qU = o4(aQ, {})
    if typeof(qU) ~= "table" then
        return {}
    end
    local qV = {}
    for k, v in pairs(qU) do
        if v == true then
            qV[k] = true
        else
            local qU_1 = typeof(k) == "number" and typeof(v) == "string"
            if qU_1 then
                qV[v] = true
            end
        end
    end
    return qV
end
local function fn656()
    local leaderstats = pa:FindFirstChild("leaderstats")
    local rc = leaderstats and leaderstats:FindFirstChild("Cash")
    local rb_1 = rc
    if rc then
        rc = rb_1.Value
    end
    return rc or 0
end
local function fn694(ct)
    local sq_1
    local sp_1
    local so = oQ()
    sq_1, sp_1 = oE(so)
    if not sq_1 or not sp_1 or sq_1.Enabled ~= true then
        return false
    end
    local so_2 = o4("AutoBuyMaxPrice", 100000)
    local sr = pg(sq_1.ObjectText)
    if sr and sr > so_2 then
        return false
    end
    local so_3 = sr and pe() < sr
    if so_3 then
        return false
    end
    local so_4 = ct and not pu(ct)
    if so_4 then
        return false
    end
    op(sp_1.Position)
    task.wait(0.12)
    oU = nil
    pJ(sq_1)
    local so_5 = os.clock()
    while true do
        local sp_2 = not oU and os.clock() - so_5 < 2
        if sp_2 then
            task.wait(0.05)
            continue
        end
        break
    end
    return oU and oU.ok == true
end
local function fn715()
    pcall(function()
        AutoCollectToggleEvent:FireServer(true)
    end)
    pcall(function()
        PlotPlayerCollectRequest:FireServer()
    end)
    local t7 = oQ()
    if not t7 then
        return
    end
    for i, descendant in ipairs(t7:GetDescendants()) do
        local t7_1 = Library.Unloaded or not pw("AutoCollect")
        if t7_1 then
            break
        end
        local t7_2 = (descendant:IsA("ProximityPrompt"))
        if t7_2 then
            t7_2 = descendant.Name == "PlotPlayerPickupPrompt" or descendant.ActionText == "Pick Up"
        end
        if t7_2 then
            local Parent = descendant.Parent
            local t8_2 = Parent and Parent:IsA("BasePart")
            if t8_2 then
                op(Parent.Position)
                task.wait(0.1)
            end
            pJ(descendant)
            task.wait(0.15)
        end
    end
end
local function onExportConfigToClipboard()
    local wF_1
    local wE_1
    wE_1, wF_1 = pcall(HttpService.JSONEncode, HttpService, oO())
    if not wE_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local wE_2 = setclipboard or toclipboard
    local wE_3 = type(wE_2) ~= "function" or not pcall(wE_2, wF_1)
    if wE_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function onCopyLitecoinAddress()
    o3(oW, "Copied Litecoin address")
end
local function fn794()
    local sn = if pa:GetAttribute("HasAutoRollGamePass") ~= true then 1 else 0
    if sn == 1 then
        return
    end
    pcall(function()
        SetAutoRoll:InvokeServer(pw("AutoRoll"), oi())
    end)
end
local function fn836()
    o6()
end
local function fn845()
    local u8_1
    local u7_1
    if identifyexecutor then
        u8_1, u7_1 = identifyexecutor()
        local u9 = u8_1 ~= ""
        local va = type(u8_1) == "string" and u9
        if va then
            local u9_1 = type(u7_1) == "string" and u7_1 ~= "" and u8_1 .. " " .. u7_1
            o7 = u9_1 or u8_1
        end
    end
end
local function fn865(e2)
    if not e2 then
        return nil
    end
    local SigningOffice = e2:FindFirstChild("SigningOffice")
    local tL = SigningOffice and SigningOffice:FindFirstChild("SellPlayerPrompt")
    local tK_1 = tL
    if tL then
        tL = tK_1:FindFirstChildOfClass("ProximityPrompt")
    end
    return tL, tK_1
end
local function onOnClientEvent2(bH, bI)
    oU = { ok = bH == true, reason = bI }
end
local function fn869()
    local sx = oQ()
    local sy = oR(sx)
    local sx_1 = sy and sy:FindFirstChild("RollButton")
    if not sx_1 then
        return
    end
    op(sx_1.Position)
    task.wait(0.12)
    Final = nil
    pcall(function()
        RequestRoll:FireServer()
    end)
    local sx_2 = os.clock()
    while true do
        local sy_2 = not Final and os.clock() - sx_2 < 5
        if sy_2 then
            if Library.Unloaded then
                break
            end
            task.wait(0.05)
            continue
        end
        local sy_3 = Final
        if sy_3 then
            sy_3 = Final.Tier or Final.TierName
        end
        local sx_4 = sy_3
        local sy_4 = pw("AutoBuy") and sx_4 and pu(sx_4)
        if sy_4 then
            task.wait(0.45)
            oz(sx_4)
        end
        return
    end
    return
end
local function fn877(aF)
    if Library.Unloaded then
        return false
    end
    local qP = Toggles[aF]
    return qP ~= nil and qP.Value == true
end
local function fn879(Z)
    local qJ = not Z or typeof(Z.label) ~= "string" or Z.label == ""
    if qJ then
        return
    end
    if om[Z.label] then
        return
    end
    ot[#ot + 1] = Z.label
    om[Z.label] = Z
end
local function onOnClientEvent(bB, bC, bD)
    if bC ~= pa.UserId then
        return
    end
    local rL = typeof(bD) == "table" and typeof(bD.Final) == "table"
    if rL then
        Final = bD.Final
    end
end
local function fn898()
    pcall(function()
        AutoCollectToggleEvent:FireServer(Toggles.AutoCollect.Value == true)
    end)
end
local function worker()
    local vi_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local vh = math.floor(os.clock() - og)
        if vh < 60 then
            vi_1 = vh .. "s"
        elseif vh < 3600 then
            vi_1 = string.format("%dm %ds", math.floor((vh) / (60)), vh % 60)
        else
            vi_1 = string.format("%dh %dm", math.floor((vh) / (3600)), math.floor((vh % 3600) / (60)))
        end
        Label:SetText(ou("Session time", vi_1, pF))
    end
end
local function fn907(g0)
    local DiscordGroup = g0:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = oN })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = oN })
end
local function worker5()
    while not Library.Unloaded do
        if pw("AutoBuyUpgrades") then
            pcall(oV)
        end
        if pw("AutoBuyPads") then
            pcall(pm)
        end
        task.wait(0.8)
    end
end
local function fn953()
    local CreatedPlots = Workspace:FindFirstChild("CreatedPlots")
    if not CreatedPlots then
        return nil
    end
    local ri = CreatedPlots:FindFirstChild("Plot_" .. pa.UserId .. "_" .. pa.Name)
    if ri then
        return ri
    end
    for i, child in ipairs(CreatedPlots:GetChildren()) do
        if child:GetAttribute("PlotOwnerUserId") == pa.UserId then
            return child
        end
    end
    return nil
end
local function fn960(bS)
    local rW = bS == ""
    local rX = typeof(bS) ~= "string" or rW
    if rX then
        return false
    end
    return oM("AutoBuyTiers")[bS] == true
end
local function fn965()
    if not Toggles.Fly.Value then
        local vs = pK()
        if vs then
            vs.PlatformStand = false
        end
    end
end
local function onUnload()
    Library:Unload()
end
local function fn1010()
    local q5 = oh()
    local q6 = q5 and q5:FindFirstChild("HumanoidRootPart")
    return q6
end
local function onCopyEthereumAddress()
    o3(oP, "Copied Ethereum address")
end
local function onCopyUSDTAddress()
    o3(oL, "Copied USDT address")
end
local function fn1028()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    pc = tick()
end
local function onCopyVenmoLink()
    o3(ox, "Copied Venmo link")
end
local function fn1062()
    if pw("AutoRoll") then
        o6()
    end
end
local function onRenderStepped(iR)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local vN_1 = pK()
        if vN_1 then
            vN_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local vN_3 = px()
        local vO = pK()
        oJ = Workspace.CurrentCamera or oJ
        if vN_3 and vO and oJ then
            vO.PlatformStand = true
            local vO_1 = Vector3.zero
            local vU = if UserInputService:IsKeyDown(Enum.KeyCode.W) then 1 else 0
            if vU == 1 then
                vO_1 = vO_1 + oJ.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                vO_1 = vO_1 - oJ.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                vO_1 = vO_1 - oJ.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                vO_1 = vO_1 + oJ.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vO_1 = vO_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vO_1 = vO_1 - Vector3.new(0, 1, 0)
            end
            vN_3.Velocity = Vector3.zero
            if vO_1.Magnitude > 0 then
                vN_3.CFrame = vN_3.CFrame + vO_1.Unit * Options.FlySpeed.Value * iR
            end
        end
    end
end
local function fn1091()
    if not Toggles.WalkSpeedEnabled.Value then
        local vu = pK()
        if vu then
            vu.WalkSpeed = 16
        end
    end
end
local function fn1106(bs)
    local rD = px()
    if not rD or not bs or not firetouchinterest then
        return false
    end
    pcall(firetouchinterest, rD, bs, 0)
    task.wait(0.05)
    pcall(firetouchinterest, rD, bs, 1)
    return true
end
local function onCopyPayPalLink()
    o3(oC, "Copied PayPal link")
end
local function fn1155(eP)
    local tA = not eP or not eP:IsA("Tool")
    if tA then
        return false
    elseif eP:GetAttribute("IsLeaguePlayer") == true then
        return false
    else
        local tA_1 = (eP:GetAttribute("CardToolId"))
        local tJ = if tA_1 then 1 else 0
        local tH = 393 * tJ + 3224 * (1 - tJ)
        local tI = 1283 * tJ + 1360 * (1 - tJ)
        if not ((tH * 786 + tI * 2114 + tH * tI) % 16777213 == 3525379) then
            tA_1 = eP:GetAttribute("InventoryCardId")
        end
        local tB = tA_1
        local tA_2 = tonumber(eP:GetAttribute("Valuation"))
        local tC = typeof(tB) ~= "string" or tB == "" or not tA_2
        local tJ_1 = if tC then 1 else 0
        local tH_1 = 1976 * tJ_1 + 2463 * (1 - tJ_1)
        local tI_1 = 2543 * tJ_1 + 4054 * (1 - tJ_1)
        if not ((tH_1 * 1336 + tI_1 * 2922 + tH_1 * tI_1) % 16777213 == 15095550) then
            tC = tA_2 <= 0
        end
        if tC then
            return false
        end
        local tB_1 = o4("SellMaxOVR", 99)
        local tC_1 = o4("SellMaxValue", 100000)
        local tD = pw("SellFusedOnly")
        local tE = tonumber(eP:GetAttribute("OVR")) or 0
        local tE_1 = eP:GetAttribute("IsFused") == true
        if tE > tB_1 then
            return false
        elseif tA_2 > tC_1 then
            return false
        else
            if tD and not tE_1 then
                return false
            end
            return true
        end
    end
end
local function fn1170()
    o3(o1, "Copied Discord invite to clipboard")
end
local function onRollOnce()
    task.spawn(oK)
end
local function onImportConfigFromClipboardTex()
    local wK_1
    local wI = Options.SaveManager_ImportSource.Value
    local wI_1
    local wO = if wI then 1 else 0
    local wM = 698 * wO + 116 * (1 - wO)
    local wN = 457 * wO + 1519 * (1 - wO)
    if not ((wM * 977 + wN * 2812 + wM * wN) % 16777213 == 2286016) then
        wI = ""
    end
    local wJ = tostring(wI):match("^%s*(.-)%s*$")
    if wJ == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    wI_1, wK_1 = pcall(HttpService.JSONDecode, HttpService, wJ)
    local wJ_1 = not wI_1 or type(wK_1) ~= "table" or type(wK_1.objects) ~= "table"
    if wJ_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local wI_2 = 0
    for i, v in ipairs(wK_1.objects) do
        if pB(v) then
            wI_2 += 1
        end
    end
    if wI_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local wK_2 = wI_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(wI_2, wK_2), 6)
end
oe = nil
connection3 = nil
og = nil
oh = nil
oi = nil
oj = nil
om = nil
op = nil
SetAutoRoll = nil
ot = nil
ou = nil
connection2 = nil
ox = nil
RequestRoll = nil
oz = nil
oA = nil
oB = nil
oC = nil
oE = nil
Label = nil
oH = nil
oI = nil
oJ = nil
oK = nil
oL = nil
oM = nil
oN = nil
oO = nil
oP = nil
oQ = nil
oR = nil
oS = nil
oT = nil
oU = nil
oV = nil
oW = nil
oX = nil
Final = nil
oZ = nil
o_ = nil
o0 = nil
o1 = nil
o2 = nil
o3 = nil
o4 = nil
local FuseMultiplierUpgrade, oo, ov, BuyUpgrade, oF
AutoCollectToggleEvent = nil
o6 = nil
o7 = nil
Options = nil
pa = nil
PlotPlayerCollectRequest = nil
pc = nil
Toggles = nil
pe = nil
Workspace = nil
pg = nil
pi = nil
SaveManager = nil
pm = nil
pp = nil
Library = nil
HttpService = nil
pu = nil
pw = nil
px = nil
VirtualUser = nil
pB = nil
UserInputService = nil
pF = nil
pG = nil
pI = nil
pJ = nil
pK = nil
local o9, RequestConfirmation, ConfirmPurchase, pn, CompleteFusionWalkout, ps, MachineInteract, py, RespondSellOffer, RequestSellOffer, pE, Purchase, pL
o9 = nil
RequestConfirmation = nil
local CoreGui
ConfirmPurchase = nil
pn = nil
local GuiService
CompleteFusionWalkout = nil
ps = nil
MachineInteract = nil
py = nil
RespondSellOffer = nil
RequestSellOffer = nil
pE = nil
Purchase = nil
pL = nil
local qg, qj
UserInputService, VirtualUser, HttpService, GuiService, CoreGui, Workspace, pa, o1, oZ, xa_12, BuyUpgrade, RequestRoll, SetAutoRoll, FuseMultiplierUpgrade, Purchase, RequestSellOffer, RespondSellOffer, MachineInteract, CompleteFusionWalkout, ConfirmPurchase, RequestConfirmation, PlotPlayerCollectRequest, AutoCollectToggleEvent, o_ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local xa_29 = game:GetService("Players")
local xa_3 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
if (not xa_3 or xa_3) and (not SetAutoRoll or SetAutoRoll) and (xa_3 and xa_3 or xa_3 and xa_3) and not ((not xa_3 or xa_3) and (not SetAutoRoll or SetAutoRoll) and (xa_3 and xa_3 or xa_3 and xa_3)) then
    pa = game:GetService("Workspace")
else
    Workspace = game:GetService("Workspace")
    pa = xa_29.LocalPlayer
end
local xa_6 = "Make Soccer Players"
o1 = "https://discord.gg/K7Qxnxkk46"
oZ = "https://discord.gg/K7Qxnxkk46"
local xa_14 = xa_3:WaitForChild("Remotes")
local xa_23 = xa_14:WaitForChild("CoachRollRemotes")
local xa_2 = xa_14:WaitForChild("PlayerEconomy")
if (not RequestSellOffer and not RequestSellOffer or not RequestSellOffer and not RequestSellOffer) and (Workspace and not Workspace or (RunService or RequestSellOffer)) and not ((not RequestSellOffer and not RequestSellOffer or not RequestSellOffer and not RequestSellOffer) and (Workspace and not Workspace or (RunService or RequestSellOffer))) then
    xa_3 = xa_12:WaitForChild("PlotUpgradeRemotes")
else
    xa_12 = xa_3:WaitForChild("PlotUpgradeRemotes")
end
BuyUpgrade = xa_23:WaitForChild("BuyUpgrade")
RequestRoll = xa_23:WaitForChild("RequestRoll")
local xa_17 = xa_23:WaitForChild("RollPresentation")
if (Workspace or false or (not Purchase or oZ)) and ("Make Soccer Players" and (oZ or not Purchase)) or not ((Workspace or false or (not Purchase or oZ)) and ("Make Soccer Players" and (oZ or not Purchase))) then
    xa_25 = xa_23:WaitForChild("PurchaseResult")
    SetAutoRoll = xa_23:WaitForChild("SetAutoRoll")
else
    SetAutoRoll:WaitForChild("PurchaseResult")
    xa_25 = SetAutoRoll:WaitForChild("SetAutoRoll")
end
FuseMultiplierUpgrade = xa_14:WaitForChild("FuseMultiplierUpgrade")
FuseMultiplierUpgrade:WaitForChild("Purchase")
FuseMultiplierUpgrade:WaitForChild("PurchaseDoubleRollLuck")
FuseMultiplierUpgrade:WaitForChild("PurchaseDoubleRollUnlock")
local xa_24 = xa_14:WaitForChild("WalkspeedUpgrade")
Purchase = xa_24:WaitForChild("Purchase")
RequestSellOffer = xa_2:WaitForChild("RequestSellOffer")
RespondSellOffer = xa_2:WaitForChild("RespondSellOffer")
MachineInteract = xa_2:WaitForChild("MachineInteract")
CompleteFusionWalkout = xa_2:WaitForChild("CompleteFusionWalkout")
ConfirmPurchase = xa_12:WaitForChild("ConfirmPurchase")
RequestConfirmation = xa_12:WaitForChild("RequestConfirmation")
PlotPlayerCollectRequest = xa_3:WaitForChild("PlotPlayerCollectRequest")
AutoCollectToggleEvent = xa_3:WaitForChild("AutoCollectToggleEvent")
local xa_15 = require(xa_3:WaitForChild("Modules"):WaitForChild("PlotUpgradeConfig"))
o_ = {
    "Amateur",
    "Grumpy",
    "SemiPro",
    "Veteran",
    "Pro",
    "Iconic",
    "WorldClass",
    "HallOfFame",
    "Generational",
    "Elite",
    "Cyborg"
}
local xa_5 = {
    { label = "Faster Time", kind = "coach", id = "FasterTime" },
    { label = "Better Chances", kind = "coach", id = "BetterChances" },
    { label = "Fuse Multiplier", kind = "fuse", remote = "Purchase" },
    { label = "Double Roll Luck", kind = "fuse", remote = "PurchaseDoubleRollLuck" },
    { label = "Double Roll Unlock", kind = "fuse", remote = "PurchaseDoubleRollUnlock" },
    { label = "Walkspeed Upgrade", kind = "walkspeed" },
    { label = "Plot Upgrades", kind = "pad", path = "PlotUpgrades" },
    { label = "Treadmill Unlock", kind = "pad", path = "WalkspeedArea" },
    { label = "Trash Upgrades", kind = "pad", path = "TrashUpgrades" },
    { label = "Fuse Area Upgrades", kind = "pad", path = "FuseUpgrades" },
    { label = "Training Grounds", kind = "pad", path = "TrainingAreas" },
    { label = "Training Equipment", kind = "pad", path = "TrainingGroundUpgrades" },
    { label = "Office Upgrades", kind = "pad", path = "OfficeUpgrades" },
    { label = "Squad Builder", kind = "pad", path = "SquadBuilderUpgrade" },
    { label = "Podium", kind = "pad", path = "PodiumUpgrade" }
}
xa_29 = {}
local xa_20 = xa_15.PathOrder or xa_29
xa_29 = xa_20
for i, v in ipairs(xa_29) do
    xa_29 = xa_15.Paths and xa_15.Paths[v]
    xa_20 = xa_29
    if xa_29 then
        xa_29 = xa_20.DisplayName
    end
    xa_20 = xa_29 or v
    xa_29 = xa_20
    xa_5[#xa_5 + 1] = { label = xa_29, kind = "tile", path = v }
end
ot, om, oj = nil, nil, nil
ot = {}
om = {}
oj = fn879
for i, v in ipairs(xa_5) do
    oj(v)
end
Library, SaveManager, Toggles, Options, pF, Final, oU, xa_2, o3, oN, oB, ou, pw, o4, oM, oh, pK, px, pe, oQ, op, pJ, py, o9, oi, pu, pg, oR, oE, oe, o6, oz, oK, oX, oo, pL, oI, oV, pm, oF, ps, o0, pI, ov, pn, pp = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
o3 = fns.fn113
oN = fn1170
oB = fns.fn531
ou = fns.fn408
xa_14 = "#7fd47f"
xa_23 = "#6ec1ff"
pF = "#e8a34d"
xa_12 = "#8b93a3"
pw = fn877
if not SaveManager or not oE or (not SaveManager or pp) or (pn or not oB) and (not oE or not SaveManager) or not (not SaveManager or not oE or (not SaveManager or pp) or (pn or not oB) and (not oE or not SaveManager)) then
    o4 = fns.fn416
    oM = fn647
    oh = fns.fn82
else
    oh = fns.fn416
    o4 = fn647
    oM = fns.fn82
end
pK = fns.fn501
px = fn1010
pe = fn656
oQ = fn953
op = fn633
pJ = function(bp)
    if not bp then
        return
    end
    if fireproximityprompt then
        pcall(fireproximityprompt, bp)
        return
    end
    pcall(function()
        bp:InputHoldBegin()
        local rA = bp.HoldDuration or 0
        task.wait(rA)
        bp:InputHoldEnd()
    end)
end
py = fn1106
o9 = function(bx)
    if not bx then
        return
    end
    pcall(function()
        if firesignal then
            firesignal(bx.Activated)
            firesignal(bx.MouseButton1Click)
        else
            bx.Activated:Fire()
        end
    end)
end
Final = nil
oU = nil
xa_17.OnClientEvent:Connect(onOnClientEvent)
xa_25.OnClientEvent:Connect(onOnClientEvent2)
oi = fns.fn151
pu = fn960
pg = fns.fn413
oR = fns.fn360
oE = fns.fn3
oe = fns.fn274
o6 = fn794
oz = fn694
oK = fn869
oX = fns.fn154
oo = fn631
pL = fns.fn10
oI = function(dD)
    local sW
    local attr2 = dD:GetAttribute("UpgradeAvailable")
    local attr = dD:GetAttribute("UpgradeEnabled")
    local sZ = tonumber(dD:GetAttribute("UpgradePrice")) or math.huge
    local sZ_1 = attr2 == false or attr == false or pe() < sZ
    if sZ_1 then
        return false
    end
    local sX_1 = dD:FindFirstChild("Pad") or dD:FindFirstChildWhichIsA("BasePart", true)
    if not sX_1 then
        return false
    end
    sW = nil
    local connection = RequestConfirmation.OnClientEvent:Connect(function(dO, dP)
        sW = true
        ConfirmPurchase:FireServer(dO, dP)
    end)
    op(sX_1.Position)
    task.wait(0.12)
    py(sX_1)
    local sY_2 = os.clock()
    while true do
        local sZ_2 = not sW and os.clock() - sY_2 < 0.8
        if sZ_2 then
            task.wait(0.05)
            continue
        end
        break
    end
    connection:Disconnect()
    task.wait(0.2)
    return sW == true
end
oV = function()
    local s8 = oM("UpgradeSelect")
    if not next(s8) then
        return
    end
    pL()
    local s9 = oQ()
    for k in pairs(s8) do
        local s6
        local s8_1 = Library.Unloaded or not pw("AutoBuyUpgrades")
        if s8_1 then
            break
        else
            local s5 = om[k]
            if s5 then
                if s5.kind == "coach" then
                    pcall(function()
                        BuyUpgrade:InvokeServer(s5.id)
                    end)
                elseif s5.kind == "fuse" then
                    local s7 = FuseMultiplierUpgrade:FindFirstChild(s5.remote)
                    if s7 then
                        pcall(function()
                            s7:InvokeServer()
                        end)
                    end
                elseif s5.kind == "walkspeed" then
                    pcall(function()
                        Purchase:InvokeServer()
                    end)
                else
                    if s5.kind == "tile" and s5.path then
                        s6 = nil
                        local connection = RequestConfirmation.OnClientEvent:Connect(function(en, eo)
                            if en == s5.path then
                                s6 = true
                                ConfirmPurchase:FireServer(en, eo)
                            end
                        end)
                        pcall(function()
                            ConfirmPurchase:FireServer(s5.path, 1)
                        end)
                        task.wait(0.25)
                        connection:Disconnect()
                    else
                        local ta = (s5.kind == "pad" or s5.kind == "padLabel") and s9
                        local ta_2
                        if ta then
                            local Upgrades = s9:FindFirstChild("Upgrades")
                            if Upgrades then
                                for i, descendant in ipairs(Upgrades:GetDescendants()) do
                                    local s8_6 = Library.Unloaded or not pw("AutoBuyUpgrades")
                                    if s8_6 then
                                        break
                                    end
                                    local attr = descendant:GetAttribute("UpgradePath")
                                    if attr then
                                        local UpgradeName = descendant:FindFirstChild("UpgradeName", true)
                                        local tb = UpgradeName and UpgradeName.Text
                                        if s5.kind == "pad" then
                                            ta_2 = oo(attr, s5.path)
                                        else
                                            ta_2 = tb == s5.name or tb == k
                                        end
                                        if ta_2 then
                                            oI(descendant)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
pm = fn604
oF = fn1155
ps = fn865
o0 = function()
    local tR_1
    local tQ_1
    local tV_1
    local tP = oQ()
    tQ_1, tR_1 = ps(tP)
    local tS = not tQ_1 or not tR_1
    local tS_5
    if tS then
        return
    end
    local tP_2 = pK()
    local tS_1 = oh()
    if not tP_2 or not tS_1 then
        return
    end
    local tS_2 = pa:FindFirstChild("PlayerGui") and pa.PlayerGui:FindFirstChild("Frames")
    local tT_1 = tS_2
    if tS_2 then
        tS_2 = tT_1:FindFirstChild("ConfirmationSellPlayer")
    end
    local tT_2 = tS_2
    if tS_2 then
        tS_2 = tT_2:FindFirstChild("SellButton")
    end
    local tU_1 = tS_2
    for i, child in ipairs(pa.Backpack:GetChildren()) do
        local tN, tO
        local tS_3 = Library.Unloaded or not pw("AutoSell")
        if tS_3 then
            break
        elseif oF(child) then
            tP_2:EquipTool(child)
            task.wait(0.15)
            op(tR_1.Position)
            task.wait(0.2)
            local tS_4 = child:GetAttribute("CardToolId") or child:GetAttribute("InventoryCardId")
            tN = tS_4
            tS_5, tV_1, tO = pcall(function()
                return RequestSellOffer:InvokeServer(tN)
            end)
            local tW = tS_5 and tV_1 and typeof(tO) == "table" and tO.OfferId
            if tW then
                pcall(function()
                    RespondSellOffer:InvokeServer(tO.OfferId, true)
                end)
            else
                pJ(tQ_1)
                task.wait(0.35)
                if tT_2 and tT_2.Visible and tU_1 then
                    o9(tU_1)
                end
            end
            task.wait(o4("SellDelay", 0.75))
        end
    end
end
if (false or (not xa_2 or false)) and (xa_2 and false or false) or not ((false or (not xa_2 or false)) and (xa_2 and false or false)) then
    pI = fn715
    ov = fn629
else
    ov = fn715
    pI = fn629
end
pn = function(gf)
    local uD
    uD = {}
    local function uE(gi)
        local uv_1
        local uu_1
        uv_1, uu_1 = ov(gi)
        if not uv_1 then
            return
        end
        local uw = math.max(1, uu_1)
        local uA = 1
        while uA <= uw do
            uD[#uD + 1] = { ItemId = uv_1.ItemId, LeagueId = uv_1.LeagueId, PlayerName = uv_1.PlayerName, OVR = uv_1.OVR }
            if #uD >= gf then
                return true
            end
            uA += 1
        end
        return false
    end
    for i, child in ipairs(pa.Backpack:GetChildren()) do
        local uF_1 = child:IsA("Tool") and uE(child)
        if uF_1 then
            return uD
        end
    end
    local uF_2 = oh()
    if uF_2 then
        for i, child in ipairs(uF_2:GetChildren()) do
            local uF_3 = child:IsA("Tool") and uE(child)
            if uF_3 then
                return uD
            end
        end
    end
    local PlotInventory = pa:FindFirstChild("PlotInventory")
    if PlotInventory then
        for i, child in ipairs(PlotInventory:GetChildren()) do
            local uF_5 = child:IsA("StringValue") and uE(child)
            if uF_5 then
                return uD
            end
        end
    end
    return uD
end
pp = function()
    local uX, StartFuse, PlayerToAdd
    local u_ = oQ()
    local u__3
    if not u_ then
        return
    end
    local FuseMachine = u_:FindFirstChild("FuseMachine")
    local u0_2
    if not FuseMachine then
        return
    end
    PlayerToAdd = FuseMachine:FindFirstChild("PlayerToAdd", true)
    StartFuse = FuseMachine:FindFirstChild("StartFuse", true)
    if not PlayerToAdd or not StartFuse then
        return
    end
    local u__2 = o4("FuseMinInputs", 2)
    uX = pn(math.max(u__2, 2))
    if #uX < u__2 then
        return
    end
    op(PlayerToAdd.Position)
    task.wait(0.2)
    u__3, u0_2 = pcall(function()
        return MachineInteract:InvokeServer("AddPlayers", PlayerToAdd, uX)
    end)
    if not u__3 or u0_2 ~= true then
        return
    end
    task.wait(0.2)
    op(StartFuse.Position)
    task.wait(0.12)
    pcall(function()
        MachineInteract:InvokeServer("RunFuse", StartFuse)
    end)
    task.wait(0.35)
    pcall(function()
        CompleteFusionWalkout:InvokeServer()
    end)
    task.wait(o4("FuseDelay", 1.25))
end
local xa_10 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = o1, Copyable = true }, "|", xa_6 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
xa_2 = {
    Info = xa_10:AddTab("Info", "info"),
    Main = xa_10:AddTab("Main", "gamepad-2"),
    Player = xa_10:AddTab("Player", "person-standing"),
    Settings = xa_10:AddTab("Settings", "settings")
}
xa_2.Roll = xa_2.Main:AddSubTab("Roll", "dices")
xa_2.Buy = xa_2.Main:AddSubTab("Buy", "shopping-cart")
xa_2.Sell = xa_2.Main:AddSubTab("Sell", "banknote")
xa_2.Fuse = xa_2.Main:AddSubTab("Fuse", "combine")
local xa_31 = fn907
for k, v in xa_2 do
    if v ~= xa_2.Main then
        xa_31(v)
    end
end
o7, Label, oA = nil, nil, nil
o7 = "Unknown"
pcall(fn845)
xa_29 = xa_2.Info:AddLeftGroupbox("Account", "circle-user")
xa_29:AddLabel(ou("User", pa.Name, xa_14), true)
xa_29:AddLabel(ou("Status", "Keyless", xa_14), true)
xa_29:AddLabel(ou("Executor", o7, xa_14), true)
xa_3 = xa_2.Info:AddLeftGroupbox("Game Info", "gamepad-2")
xa_3:AddLabel(oB(xa_6 .. " [" .. tostring(game.PlaceId) .. "]", xa_23), true)
xa_3:AddLabel(ou("Place ID", tostring(game.PlaceId), xa_23), true)
Label = xa_3:AddLabel(ou("Session time", "0s", pF), true)
oA = tostring(game.JobId)
xa_10 = #oA > 18
if xa_10 then
    xa_29 = 3
    repeat
        if xa_29 * 34639471 + 12 + 1 <= xa_29 * 34639471 + 12 + 1 + 2 then
            xa_10 = string.sub(oA, 1, 18) .. "..."
        else
            oA = string.sub(xa_10, 1, 18) .. "..."
        end
        xa_29 = (xa_29 + 2) % 4
    until (xa_29 * 3 + 3) % 4 == 2
end
xa_29 = xa_10 or oA
og, oW, oT, oP, oL, oH, oC, ox, xa_25, xa_15, xa_31, oJ, pi, pc, connection2, connection3, pG, oS, pE, o2, oO, pB = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local xa_28 = xa_29
xa_3:AddLabel(ou("Server", xa_28, xa_12), true)
xa_3:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
og = os.clock()
task.spawn(worker)
local ScriptsGroup = xa_2.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(oB("Included in this hub", xa_12), true)
ScriptsGroup:AddLabel(oB(xa_6, xa_23), true)
local FeaturesGroup = xa_2.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(oB("Auto Roll", xa_23), true)
FeaturesGroup:AddLabel(oB("Auto Buy", pF), true)
FeaturesGroup:AddLabel(oB("Auto Sell / Collect", xa_14), true)
FeaturesGroup:AddLabel(oB("Auto Fuse", xa_12), true)
local SocialsGroup = xa_2.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = oN })
SocialsGroup:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
local TempoHubGroup = xa_2.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = oN })
oW = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
oT = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
oP = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
oL = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
oH = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
oC = ""
ox = ""
local xa_19 = "#345d9d"
local xa_18 = "#f7931a"
if ((not xa_31 or xa_31) and (not xa_15 or not xa_15) or (not xa_31 or not xa_31) and (xa_15 and xa_15) or (not xa_31 and not xa_15 or (xa_31 or xa_15)) and (not xa_31 and xa_31 and (not xa_15 or not xa_15))) and ((xa_15 or not xa_31) and (not xa_15 and xa_31) and (xa_15 or xa_31 or not xa_15 and not xa_15) or ((not xa_15 or xa_31) and (xa_15 or not xa_31) or (not xa_31 and not xa_31 or not xa_31 and not xa_15))) or not (((not xa_31 or xa_31) and (not xa_15 or not xa_15) or (not xa_31 or not xa_31) and (xa_15 and xa_15) or (not xa_31 and not xa_15 or (xa_31 or xa_15)) and (not xa_31 and xa_31 and (not xa_15 or not xa_15))) and ((xa_15 or not xa_31) and (not xa_15 and xa_31) and (xa_15 or xa_31 or not xa_15 and not xa_15) or ((not xa_15 or xa_31) and (xa_15 or not xa_31) or (not xa_31 and not xa_31 or not xa_31 and not xa_15)))) then
    xa_25 = "#627eea"
else
    oS = "#627eea"
end
xa_15 = "#26a17b"
xa_31 = "#14f195"
xa_20 = "#0070ba"
local qi = "#008cff"
local DonationsGroup = xa_2.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(oB("All donations are optional but appreciated.", pF), true)
DonationsGroup:AddLabel(oB("If you donate you get a special role, just PING after you donate.", xa_14), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(oB("LTC / Litecoin", xa_19), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(oB("BTC / Bitcoin", xa_18), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
DonationsGroup:AddLabel(oB("ETH / Ethereum", xa_25), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(oB("USDT", xa_15), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(oB("Solana", xa_31), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
DonationsGroup:AddLabel(oB("PayPal", xa_20), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(oB("Venmo", qi), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(oB("Don't have any of the listed currencies but still wanna donate?", xa_12), true)
DonationsGroup:AddLabel(oB("DM me and we'll work something out.", xa_23), true)
local FaqGroup = xa_2.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoRollGroup = xa_2.Roll:AddLeftGroupbox("Auto Roll", "dices")
AutoRollGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
AutoRollGroup:AddSlider("AutoRollDelay", { Text = "Roll Delay", Default = 2.1, Min = 1, Max = 6, Rounding = 2 })
AutoRollGroup:AddButton({ Text = "Roll Once", Func = onRollOnce })
local AutoBuyGroup = xa_2.Roll:AddRightGroupbox("Auto Buy", "shopping-cart")
AutoBuyGroup:AddToggle("AutoBuy", { Text = "Auto Buy", Default = false })
AutoBuyGroup:AddDropdown("AutoBuyTiers", {
    Text = "Buy Tiers",
    Values = o_,
    Default = {
        Grumpy = true,
        SemiPro = true,
        Veteran = true,
        Pro = true,
        Iconic = true,
        WorldClass = true,
        HallOfFame = true,
        Generational = true,
        Elite = true,
        Cyborg = true
    },
    Multi = true,
    Searchable = true,
    AllowNull = true
})
AutoBuyGroup:AddSlider("AutoBuyMaxPrice", { Text = "Max Buy Price", Default = 100000, Min = 20, Max = 10000000, Rounding = 0 })
local AutoBuyUpgradesGroup = xa_2.Buy:AddLeftGroupbox("Auto Buy Upgrades", "arrow-big-up")
AutoBuyUpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
AutoBuyUpgradesGroup:AddDropdown("UpgradeSelect", { Text = "Upgrades", Values = ot, Default = {}, Multi = true, Searchable = true, AllowNull = true })
task.defer(pL)
xa_17 = xa_2.Buy:AddRightGroupbox("Pads", "layout-grid")
xa_17:AddToggle("AutoBuyPads", { Text = "Auto Buy Affordable Pads", Default = false })
xa_5 = xa_2.Sell:AddLeftGroupbox("Auto Sell", "banknote")
if ((not FeaturesGroup and FeaturesGroup or "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w") and (false and (false and not FeaturesGroup)) or ((not FeaturesGroup or not FeaturesGroup) and (false or FeaturesGroup) or (FeaturesGroup or not SocialsGroup) and (FeaturesGroup and false))) and not ((not FeaturesGroup and FeaturesGroup or "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w") and (false and (false and not FeaturesGroup)) or ((not FeaturesGroup or not FeaturesGroup) and (false or FeaturesGroup) or (FeaturesGroup or not SocialsGroup) and (FeaturesGroup and false))) then
    xa_2:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    xa_2:AddToggle("SellFusedOnly", { Text = "Fused Only", Default = false })
    xa_2:AddSlider("SellMaxOVR", { Rounding = 0, Text = "Max OVR", Default = 70, Min = 1, Max = 99 })
    xa_2:AddSlider("SellMaxValue", { Max = 10000000, Default = 20000, Min = 100, Rounding = 0, Text = "Max Value" })
    xa_2:AddSlider("SellDelay", { Default = 0.75, Min = 0.2, Rounding = 2, Text = "Sell Delay", Max = 5 })
    xa_5 = pG.Sell:AddRightGroupbox("Auto Collect", "package-open")
    xa_5:AddToggle("AutoCollect", { Text = "Auto Collect", Default = false })
    qg = pG.Fuse:AddLeftGroupbox("Auto Fuse", "combine")
    qg:AddToggle("AutoFuse", { Text = "Auto Fuse", Default = false })
    qg:AddSlider("FuseMinOVR", { Min = 0, Default = 0, Rounding = 0, Text = "Min OVR", Max = 99 })
    qg:AddSlider("FuseMaxOVR", { Rounding = 0, Default = 99, Min = 1, Text = "Max OVR", Max = 99 })
    qg:AddSlider("FuseMaxValue", { Min = 100, Rounding = 0, Max = 10000000, Default = 50000, Text = "Max Value" })
    qg:AddSlider("FuseMinInputs", { Text = "Min Inputs", Max = 8, Rounding = 0, Min = 2, Default = 2 })
    qg:AddSlider("FuseDelay", { Default = 1.25, Rounding = 2, Text = "Fuse Delay", Min = 0.4, Max = 5 })
    xa_10 = pG.Player:AddLeftGroupbox("Movement", "footprints")
    xa_10:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    xa_10:AddSlider("WalkSpeed", { Max = 250, Default = 32, Rounding = 0, Text = "WalkSpeed Amount", Min = 16 })
    xa_10:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    xa_10:AddToggle("NoClip", { Text = "NoClip", Default = false })
    xa_10:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    qj = pG.Player:AddRightGroupbox("Fly", "feather")
    qj:AddToggle("Fly", { Text = "Fly", Default = false })
    qj:AddSlider("FlySpeed", { Min = 10, Text = "Fly Speed", Default = 60, Rounding = 0, Max = 400 })
else
    xa_5:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
    xa_5:AddToggle("SellFusedOnly", { Text = "Fused Only", Default = false })
    xa_5:AddSlider("SellMaxOVR", { Text = "Max OVR", Default = 70, Min = 1, Max = 99, Rounding = 0 })
    xa_5:AddSlider("SellMaxValue", { Text = "Max Value", Default = 20000, Min = 100, Max = 10000000, Rounding = 0 })
    xa_5:AddSlider("SellDelay", { Text = "Sell Delay", Default = 0.75, Min = 0.2, Max = 5, Rounding = 2 })
    xa_24 = xa_2.Sell:AddRightGroupbox("Auto Collect", "package-open")
    xa_24:AddToggle("AutoCollect", { Text = "Auto Collect", Default = false })
    xa_10 = xa_2.Fuse:AddLeftGroupbox("Auto Fuse", "combine")
    xa_10:AddToggle("AutoFuse", { Text = "Auto Fuse", Default = false })
    xa_10:AddSlider("FuseMinOVR", { Text = "Min OVR", Default = 0, Min = 0, Max = 99, Rounding = 0 })
    xa_10:AddSlider("FuseMaxOVR", { Text = "Max OVR", Default = 99, Min = 1, Max = 99, Rounding = 0 })
    xa_10:AddSlider("FuseMaxValue", { Text = "Max Value", Default = 50000, Min = 100, Max = 10000000, Rounding = 0 })
    xa_10:AddSlider("FuseMinInputs", { Text = "Min Inputs", Default = 2, Min = 2, Max = 8, Rounding = 0 })
    xa_10:AddSlider("FuseDelay", { Text = "Fuse Delay", Default = 1.25, Min = 0.4, Max = 5, Rounding = 2 })
    qj = xa_2.Player:AddLeftGroupbox("Movement", "footprints")
    qj:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    qj:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    qj:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    qj:AddToggle("NoClip", { Text = "NoClip", Default = false })
    qj:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    qg = xa_2.Player:AddRightGroupbox("Fly", "feather")
    qg:AddToggle("Fly", { Text = "Fly", Default = false })
    qg:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
    pG = function(ib)
        pcall(function()
            GuiService:SetGameplayPausedNotificationEnabled(not ib)
        end)
        pcall(function()
            local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
            if RobloxNetworkPauseNotificati then
                RobloxNetworkPauseNotificati.Enabled = not ib
            end
        end)
        if not ib then
            return
        end
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(pa, "GameplayPaused", false)
            else
                pa.GameplayPaused = false
            end
        end)
    end
end
Toggles.AntiGameplayPause:OnChanged(fns.fn146)
Toggles.Fly:OnChanged(fn965)
Toggles.WalkSpeedEnabled:OnChanged(fn1091)
Toggles.AutoRoll:OnChanged(fn836)
Options.AutoBuyTiers:OnChanged(fn1062)
Toggles.AutoCollect:OnChanged(fn898)
RunService.Stepped:Connect(fns.onStepped)
UserInputService.JumpRequest:Connect(fns.onJumpRequest)
oJ = Workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
local MenuGroup = xa_2.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
pi = tick()
pc = tick()
pcall(function()
    for i, v in ipairs(getconnections(pa.Idled)) do
        local v0 = v
        pcall(function()
            v0:Disable()
        end)
    end
end)
oS = fn1028
connection2 = UserInputService.InputBegan:Connect(fns.onInputBegan)
connection3 = UserInputService.InputChanged:Connect(fns.onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/make-soccer-players")
local qe = SaveManager:BuildConfigSection(xa_2.Settings)
pE = fns.fn302
o2 = fns.fn159
oO = fn579
pB = function(jQ)
    local wy
    wy = nil
    local wz = type(jQ) ~= "table" or type(jQ.idx) ~= "string" or type(jQ.type) ~= "string" or SaveManager.Ignore[jQ.idx]
    if wz then
        return false
    end
    wy = pE(jQ.type, jQ.idx)
    if not wy then
        return false
    end
    local wz_1 = pcall(function()
        if jQ.type == "Input" then
            if type(jQ.text) ~= "string" then
                return
            end
            wy:SetValue(jQ.text)
        elseif jQ.type == "ColorPicker" then
            wy:SetValueRGB(Color3.fromHex(jQ.value), jQ.transparency)
        elseif jQ.type == "KeyPicker" then
            wy:SetValue({ jQ.key, jQ.mode, jQ.modifiers })
            if jQ.mode == "Toggle" and jQ.toggled ~= nil then
                wy.Toggled = jQ.toggled
                wy:Update()
            end
        else
            wy:SetValue(jQ.value)
        end
    end)
    return wz_1
end
if ("LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" and (MenuGroup and false) or connection3 and not connection3 and (not connection3 or MenuGroup)) and not ("LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w" and (MenuGroup and false) or connection3 and not connection3 and (not connection3 or MenuGroup)) then
    ThemeManager:AddDivider()
    ThemeManager:AddInput("SaveManager_ImportSource", { AllowEmpty = true, Text = "Paste exported config here", Finished = true })
    ThemeManager:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    ThemeManager:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    qe:ApplyToTab(SaveManager.Settings)
    qe:LoadDefault()
    Library:LoadAutoloadConfig()
    task.spawn(fns.worker6)
    task.spawn(worker5)
    task.spawn(fns.worker4)
    task.spawn(fns.worker3)
    task.spawn(fns.antiGameplayPauseLoop)
    task.spawn(fns.worker2)
    xa_2:OnUnload(fns.fn134)
else
    qe:AddDivider()
    qe:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
    qe:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
    qe:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
    ThemeManager:ApplyToTab(xa_2.Settings)
    ThemeManager:LoadDefault()
    SaveManager:LoadAutoloadConfig()
    task.spawn(fns.worker6)
    task.spawn(worker5)
    task.spawn(fns.worker4)
    task.spawn(fns.worker3)
    task.spawn(fns.antiGameplayPauseLoop)
    task.spawn(fns.worker2)
    Library:OnUnload(fns.fn134)
end
end)(...)
