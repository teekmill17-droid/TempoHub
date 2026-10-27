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
getgenv().TempoHoodSubtitle = "COIN FLIP"
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
local hT
local hA
local Label2
local hG
local Label5
local hn
local h1
local Label4
local ia
local Options
local Label3
local hV
local hC
local hY
local Label
local h0
local hm
local connection2
local hI
local hL
local h6
local hs
local h9
local hR
local hy
local hU
local hX
local hB
local h_
local connection
local ho
local h5
local hK
local hr
local hN
local h8
local hu
local hx
local function onInputChanged(eu)
    local UserInputType = eu.UserInputType
    local lr = UserInputType == Enum.UserInputType.MouseMovement
    local lv = if lr then 1 else 0
    local lt = 3219 * lv + 3474 * (1 - lv)
    local lu = 2736 * lv + 1627 * (1 - lv)
    if not ((lt * 442 + lu * 2379 + lt * lu) % 16777213 == 16738926) then
        lr = UserInputType == Enum.UserInputType.Gamepad1
    end
    if lr then
        hs = tick()
    end
end
local function antiAfkLoop()
    while not h_.Unloaded do
        task.wait(2)
        if hN.AntiAfk.Value then
            local lw = tick() - hs
            local lx = tick() - hn
            if lw >= 300 and lx >= 60 then
                pcall(hT)
            else
                if lw < 300 and lx >= 300 then
                    pcall(hT)
                end
            end
        end
    end
end
local function fn41()
    local iY_1
    local iX_1
    if identifyexecutor then
        iY_1, iX_1 = identifyexecutor()
        local iZ = iY_1 ~= ""
        local i_ = type(iY_1) == "string" and iZ
        if i_ then
            local iZ_1 = type(iX_1) == "string" and iX_1 ~= "" and iY_1 .. " " .. iX_1
            h0 = iZ_1 or iY_1
        end
    end
end
local function fn44()
    if not workspace.CurrentCamera then
        return
    end
    hX:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    hX:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    hn = tick()
end
local function onRscripts()
    hK(hI)
    h_:Notify("Copied Rscripts profile to clipboard")
end
local function fn140(cU)
    local roll = cU.roll
    if not roll then
        return 0
    end
    local j9 = tonumber(roll.pct) or 0
    local j8_1 = roll.negative and -j9
    local ke = if j8_1 then 1 else 0
    local kc = 2276 * ke + 1554 * (1 - ke)
    local kd = 2391 * ke + 521 * (1 - ke)
    if not ((kc * 1294 + kd * 2543 + kc * kd) % 16777213 == 14467373) then
        j8_1 = j9
    end
    return j8_1
end
local function fn144()
    hK(hL)
    h_:Notify("Copied Discord invite to clipboard")
end
local function fn152(aT)
    local DiscordGroup = aT:AddLeftGroupbox("Discord", nil, nil, nil, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = hC })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = hC })
end
local function autoAscendLoop()
    while not h_.Unloaded do
        task.wait(3)
        if hN.AutoAscend.Value then
            local jZ = hm
            local j_ = jZ and jZ.canAscend
            if j_ then
                local j0 = tonumber(jZ.rebirthCount) or 0
                j_ = j0 >= Options.AscendAtRebirths.Value
            end
            if j_ then
                pcall(function()
                    h5:InvokeServer()
                end)
                ia()
            end
        end
    end
end
local function fn157(U)
    if setclipboard then
        setclipboard(U)
    elseif toclipboard then
        toclipboard(U)
    end
end
local function fn175(ad, ae, af)
    return string.format("<b>%s</b> %s %s", ad, h8("-", "#5a6070"), h8(ae, af))
end
local function worker2()
    while not h_.Unloaded do
        task.wait(2)
        local jz = ia()
        if jz then
            local format = string.format
            local jB = tonumber(jz.balanceCents) or 0
            Label2:SetText(hV("Balance", format("%.2f", jB / 100), hG))
            local jA_1 = jz.totalFlips or 0
            Label3:SetText(hV("Total flips", tostring(jA_1), hA))
            local jA_2 = jz.rebirthCount or 0
            Label4:SetText(hV("Rebirths", tostring(jA_2), hu))
            local jA_3 = jz.level or 0
            Label5:SetText(hV("Level", tostring(jA_3), ho))
        end
    end
end
local function fn215()
    local i9_1
    local i8_1
    i8_1, i9_1 = pcall(function()
        return h1:GetProductInfo(game.PlaceId)
    end)
    local ja = i8_1
    local i8_2 = {}
    if ja then
        ja = type(i9_1) == "table"
    end
    if ja then
        ja = type(i9_1.Description) == "string"
    end
    if ja then
        for k in i9_1.Description:gmatch('"([%w!_%-]+)"') do
            i8_2[#i8_2 + 1] = k
        end
    end
    return i8_2
end
local function autoClaimAchievementsLoop()
    while not h_.Unloaded do
        task.wait(15)
        if hN.AutoClaimAchievements.Value then
            pcall(function()
                hB:InvokeServer()
            end)
        end
    end
end
local function fn278()
    local CycleChoice = require(h6:WaitForChild("CoinFlipConfig")).CycleChoice
    for i, v in ipairs(CycleChoice.Options) do
        local iK_1 = #hY + 1
        local iL = v.name or v.id
        hY[iK_1] = iL
        local iK_2 = v.name
        local iV = if iK_2 then 1 else 0
        local iT = 3304 * iV + 3288 * (1 - iV)
        local iU = 235 * iV + 4054 * (1 - iV)
        if not ((iT * 2767 + iU * 3227 + iT * iU) % 16777213 == 10676953) then
            iK_2 = v.id
        end
        hU[iK_2] = v.id
    end
end
local function onUnload()
    h_:Unload()
end
local function onCopyJoinScript_JobID()
    local az = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, hx)
    hK(az)
    h_:Notify("Copied join script to clipboard")
end
local function autoFlipLoop()
    while not h_.Unloaded do
        if hN.AutoFlip.Value then
            pcall(function()
                hr:FireServer()
            end)
            local jw = hm
            local jx = jw and tonumber(jw.flipCooldown)
            local jw_1 = jx or 1
            task.wait(math.max(0.05, jw_1) + Options.FlipDelay.Value)
        else
            task.wait(0.25)
        end
    end
end
local function onInputBegan()
    hs = tick()
end
local function autoRebirthLoop()
    while not h_.Unloaded do
        task.wait(3)
        if hN.AutoRebirth.Value then
            local jU = hm
            if jU then
                local jV = tonumber(jU.nextRebirthCost)
                local jW = tonumber(jU.balanceCents) or 0
                if jV and jV >= 0 and jW >= jV then
                    pcall(function()
                        h9:InvokeServer()
                    end)
                    ia()
                end
            end
        end
    end
end
local function worker()
    local i2_1
    while true do
        task.wait(1)
        if h_.Unloaded then
            break
        end
        local i1 = math.floor(os.clock() - hR)
        if i1 < 60 then
            i2_1 = i1 .. "s"
        elseif i1 < 3600 then
            i2_1 = string.format("%dm %ds", math.floor((i1) / (60)), i1 % 60)
        else
            i2_1 = string.format("%dh %dm", math.floor((i1) / (3600)), math.floor((i1 % 3600) / (60)))
        end
        Label:SetText(hV("Session time", i2_1, hu))
    end
end
local function fn574(aa, ab)
    return string.format('<font color="%s">%s</font>', ab, aa)
end
local function fn644()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn650()
    local i5_1
    local i4_1
    i4_1, i5_1 = pcall(function()
        return hy:InvokeServer()
    end)
    local i6 = i4_1 and type(i5_1) == "table"
    if i6 then
        hm = i5_1
    end
    return hm
end
Label5 = nil
hm = nil
hn = nil
ho = nil
Label4 = nil
hr = nil
hs = nil
hu = nil
Label3 = nil
hx = nil
hy = nil
hA = nil
hB = nil
hC = nil
Label2 = nil
connection = nil
Label = nil
hG = nil
hI = nil
hK = nil
hL = nil
hN = nil
Options = nil
hR = nil
hT = nil
hU = nil
hV = nil
hX = nil
hY = nil
h_ = nil
h0 = nil
h1 = nil
connection2 = nil
h5 = nil
local hj, hl, RedeemCode, ht, hv, hz, hH, GetChestInventory, hM, hO, hQ, UnequipItem, hW, GetInventory, h2, h4
h6 = nil
h8 = nil
h9 = nil
ia = nil
local h7, ib, im, io, ip, iq, ir
local GameInfoGroup
local iA_1
local ik_1
local Window
local ii_1
local ie_1
local ic_1
local ih_3
ic_1, h6, h1, hX, ip, hQ, im, hL, hI, ie_1, hy, hr, hl, h9, h5, GetInventory, hW, UnequipItem, hO, hM, GetChestInventory, hH, hB, hv, RedeemCode, hj, h7, h2, hY, hU, ib, ii_1, h_, iq, io, Options, hN, hG, hA, hu, ho, Window, ir, h0, GameInfoGroup, Label, hx, ik_1, hK, hC, h8, hV = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local ig = 58
repeat
    local is_1 = (ig * 11 + 18) % 29 + 1
    if is_1 <= 15 then
        if is_1 <= 8 then
            if is_1 <= 4 then
                if is_1 <= 2 then
                    if is_1 <= 1 then
                        local it_1 = (vector.create((ig * 3 + 4) % 11 + 1, (ig * 2 + 4) % 13 + 1, (ig * 9 + 12) % 17 + 1))
                        local iu_1 = (vector.create((ig * 6 + 5) % 11 + 1, (ig * 1 + 2) % 13 + 1, (ig * 9 + 8) % 17 + 1))
                        local iv_1 = (vector.create((ig * 5 + 3) % 11 + 1, (ig * 1 + 7) % 13 + 1, (ig * 10 + 7) % 17 + 1))
                        if vector.dot(vector.cross(it_1, iu_1), iv_1) == vector.dot(vector.cross(iu_1, iv_1), it_1) then
                            hM = ie_1:WaitForChild("UsePotion")
                            GetChestInventory = ie_1:WaitForChild("GetChestInventory")
                        else
                            ie_1 = GetChestInventory:WaitForChild("UsePotion")
                            hM = GetChestInventory:WaitForChild("GetChestInventory")
                        end
                        ig = (ig + 8) % 116
                    else
                        local it_2 = {
                            "qnguhej",
                            "jowihhpyrhm",
                            "haqeeaktubmk",
                            "iyafrb",
                            "bpyanovawujp",
                            "wkldiabajlgn",
                            "pzxmrd",
                            "orlcmcqy",
                            "tifapha",
                            "xhmguoyqu",
                            "jjwb",
                            "fvwtr",
                            "jlxwvmcsb",
                            "snlgps",
                            "fcotk"
                        }
                        if it_2[(ig * 78 + 31) % 15 + 1] <= it_2[(ig * 78 + 31) % 15 + 1] then
                            hH = ie_1:WaitForChild("OpenAllChests")
                            hB = ie_1:WaitForChild("ClaimAllAchievementRewards")
                            hv = ie_1:WaitForChild("ChooseCycleBonus")
                            RedeemCode = ie_1:WaitForChild("RedeemCode")
                        else
                            hB = RedeemCode:WaitForChild("OpenAllChests")
                            hH = RedeemCode:WaitForChild("ClaimAllAchievementRewards")
                            ie_1 = RedeemCode:WaitForChild("ChooseCycleBonus")
                            hv = RedeemCode:WaitForChild("RedeemCode")
                        end
                        ig = (ig + 8) % 116
                    end
                elseif is_1 <= 3 then
                    local it_3 = {
                        "isqldmly",
                        "bbintp",
                        "uxagaiglxot",
                        "uoedi",
                        "viiyludg",
                        "ckbfoww",
                        "wpfkutvovg",
                        "ilk",
                        "koolqos",
                        "rmaz",
                        "sugwamuh"
                    }
                    local mg = ig
                    local iu_2 = it_3[mg % 11 + 1]
                    if iu_2:len() <= iu_2:gsub("(.)", "%1%1", mg % 3 % 2 + 1):len() then
                        hj = {
                            "CoinMultiplier",
                            "HeadsChance",
                            "FlipSpeed",
                            "LuckyFlip",
                            "StreakPower",
                            "CritChance",
                            "CritPower",
                            "FrenzyMastery"
                        }
                        h7 = { "Basic", "Silver", "Legendary", "Matrix", "Exclusive" }
                        h2 = {
                            "coin_1",
                            "coin_2",
                            "coin_3",
                            "coin_4",
                            "coin_5",
                            "coin_6",
                            "coin_7",
                            "luck_1",
                            "luck_2",
                            "luck_3",
                            "luck_4",
                            "luck_5",
                            "luck_6",
                            "luck_7",
                            "xp_1",
                            "xp_2",
                            "xp_3",
                            "xp_4",
                            "xp_5",
                            "xp_6",
                            "xp_7",
                            "flip_speed_1",
                            "flip_speed_2",
                            "flip_speed_3",
                            "flip_speed_4",
                            "flip_speed_5",
                            "flip_speed_6",
                            "flip_speed_7",
                            "shop_coins_1",
                            "shop_luck_1",
                            "shop_xp_1",
                            "shop_flipspeed_1"
                        }
                        hY = {}
                        hU = {}
                    else
                        hY = {
                            "LuckyFlip",
                            "CritPower",
                            "HeadsChance",
                            "StreakPower",
                            "CoinMultiplier",
                            "CritChance",
                            "FrenzyMastery",
                            "FlipSpeed"
                        }
                        hj = { "Legendary", "Basic", "Matrix", "Silver", "Exclusive" }
                        h7 = {
                            "xp_3",
                            "luck_4",
                            "luck_5",
                            "shop_coins_1",
                            "xp_2",
                            "flip_speed_4",
                            "coin_3",
                            "coin_5",
                            "luck_7",
                            "luck_6",
                            "coin_7",
                            "shop_luck_1",
                            "flip_speed_6",
                            "coin_1",
                            "flip_speed_1",
                            "flip_speed_2",
                            "xp_5",
                            "luck_2",
                            "coin_2",
                            "coin_6",
                            "flip_speed_7",
                            "shop_xp_1",
                            "xp_1",
                            "flip_speed_5",
                            "coin_4",
                            "shop_flipspeed_1",
                            "luck_1",
                            "flip_speed_3",
                            "luck_3",
                            "xp_6",
                            "xp_4",
                            "xp_7"
                        }
                        hU = {}
                        h2 = {}
                    end
                    ig = (ig + 8) % 116
                else
                    local it_4 = { "guufe", "rhmaxk", "oprllvd", "wuqoygossan", "weibhuna", "uyspxqbr", "vhdqsfxobgc" }
                    local mG = ig
                    local iu_3 = it_4[mG % 7 + 1]
                    if iu_3:len() <= iu_3:reverse():rep(mG % 3 + 2):len() then
                        pcall(fn278)
                        ib = {
                            Unobtainable = 0,
                            Limitless = 0.5,
                            Secret = 1,
                            Divine = 2,
                            Mythic = 3,
                            Legendary = 4,
                            Epic = 5,
                            Rare = 6,
                            Common = 7
                        }
                    else
                        pcall(fn278)
                        hG = {
                            Legendary = 4,
                            Divine = 2,
                            Limitless = 0.5,
                            Mythic = 3,
                            Epic = 5,
                            Secret = 1,
                            Unobtainable = 0,
                            Rare = 6,
                            Common = 7
                        }
                    end
                    ig = (ig + 37) % 116
                end
            elseif is_1 <= 6 then
                if is_1 <= 5 then
                    local it_5 = (vector.create((ig * 7 + 9) % 11 + 1, (ig * 6 + 7) % 13 + 1, (ig * 5 + 9) % 17 + 1))
                    local iu_4 = (vector.create((ig * 6 + 7) % 11 + 1, (ig * 5 + 3) % 13 + 1, (ig * 9 + 13) % 17 + 1))
                    local mi = vector.dot(it_5, iu_4)
                    if mi * mi >= vector.dot(it_5, it_5) * vector.dot(iu_4, iu_4) + 1 then
                        hx = ""
                    else
                        ii_1 = ""
                    end
                    ig = (ig + 37) % 116
                else
                    local mF = bit32.rrotate(bit32.bxor(bit32.lrotate(ig, 16), string.byte(tostring(ir))), 11)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(mF, 284942897), 1884640727), (bit32.bxor(bit32.band(mF, 4010024398), 3620517681))), 1884640727), 3620517681) ~= mF then
                        ii_1 = getgenv().Library
                    else
                        h_ = getgenv().Library
                    end
                    ig = (ig + 37) % 116
                end
            elseif is_1 <= 7 then
                local it_6 = {
                    "qfawtw",
                    "ntvrencplswk",
                    "myhehd",
                    "ufivhhinc",
                    "tcol",
                    "anelyp",
                    "wba",
                    "kphbpjwfx",
                    "rvhfmfmfoi",
                    "xuu",
                    "hpktscviyep",
                    "pfeijoolizp",
                    "enftihosgblj",
                    "xwjnjuoixp"
                }
                if it_6[(ig * 90 + 13) % 14 + 1] <= it_6[(ig * 90 + 13) % 14 + 1] then
                    iq = getgenv().ThemeManager
                    io = getgenv().SaveManager
                    Options = h_.Options
                    hN = h_.Toggles
                else
                    ii_1 = getgenv().ThemeManager
                    hN = getgenv().SaveManager
                    h_ = io.Options
                    iq = io.Toggles
                end
                ig = (ig + 66) % 116
            else
                local it_7 = {
                    "qarvqia",
                    "ktuuduk",
                    "nwjjfqkw",
                    "gyntt",
                    "bhsqzmalatt",
                    "jdvwfuazfs",
                    "fnzr",
                    "auhmdjuz",
                    "olt",
                    "oofijxjtwgw",
                    "rfusxz",
                    "uwlnqka"
                }
                local mA = ig
                local iu_5 = it_7[mA % 12 + 1]
                if iu_5:len() >= iu_5:gsub("(.)", "%1%1", mA % 3 % 2 + 1):len() then
                    hC = fn157
                    hK = fn144
                else
                    hK = fn157
                    hC = fn144
                end
                ig = (ig + 8) % 116
            end
        elseif is_1 <= 12 then
            if is_1 <= 10 then
                if is_1 <= 9 then
                    local it_8 = {
                        "vom",
                        "kxcmkrv",
                        "tceniy",
                        "stapnvdplo",
                        "bsso",
                        "pbne",
                        "pecybtw",
                        "sfiwtvbpdevc",
                        "kfajwpkelm",
                        "ndd",
                        "cihaekwdia"
                    }
                    if it_8[(ig * 95 + 60) % 11 + 1] < it_8[(ig * 95 + 60) % 11 + 1] then
                        hU = fn574
                    else
                        h8 = fn574
                    end
                    ig = (ig + 37) % 116
                else
                    if (hX and not hY or hx and hY or (hY and hx or hx and not hX) or (hY or hC or (hX or hx) or not hY and hC and (not hY and hC))) and not (hX and not hY or hx and hY or (hY and hx or hx and not hX) or (hY or hC or (hX or hx) or not hY and hC and (not hY and hC))) then
                        iq = fn175
                    else
                        hV = fn175
                    end
                    ig = (ig + 8) % 116
                end
            elseif is_1 <= 11 then
                local it_9 = { "eidbrhps", "xsinc", "uuvpxcmm", "klwooyru", "zmvswhd", "yevo", "eleyg", "vawcqfol", "hqdzmjzp" }
                local mv = ig
                local iu_6 = it_9[mv % 9 + 1]
                if iu_6:len() >= iu_6:gsub("(.)", "%1%1", mv % 3 % 2 + 1):len() then
                    hu = "#7fd47f"
                else
                    hG = "#7fd47f"
                end
                ig = (ig + 66) % 116
            else
                local lU = bit32.rrotate(bit32.bxor(bit32.lrotate(ig, 13), string.byte(tostring(GetInventory))), 15)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(lU, 400227277), 2085158187), (bit32.bxor(bit32.band(lU, 3894740018), 4080403112))), 2085158187), 4080403112) == lU then
                    hA = "#6ec1ff"
                else
                    hu = "#6ec1ff"
                end
                ig = (ig + 8) % 116
            end
        elseif is_1 <= 14 then
            if is_1 <= 13 then
                local it_10 = {
                    "wryopucfb",
                    "rnh",
                    "keby",
                    "lab",
                    "mecica",
                    "lqcnfyjqdz",
                    "tacyydla",
                    "xfzefxhehw",
                    "wzvym",
                    "cbwjqexst",
                    "ffrgdotlk",
                    "vkayrlnu",
                    "girlh",
                    "ekogv",
                    "cxraovew"
                }
                if it_10[(ig * 62 + 4) % 15 + 1] < it_10[(ig * 62 + 4) % 15 + 1] then
                else
                    hu = "#e8a34d"
                end
                ig = (ig + 66) % 116
            else
                local it_11 = (vector.create((ig * 7 + 3) % 11 + 1, (ig * 3 + 10) % 13 + 1, (ig * 7 + 6) % 17 + 1))
                local iu_7 = (vector.create((ig * 1 + 5) % 11 + 1, (ig * 1 + 7) % 13 + 1, (ig * 4 + 5) % 17 + 1))
                local iv_2 = (vector.create((ig * 4 + 5) % 11 + 1, (ig * 2 + 4) % 13 + 1, (ig * 1 + 3) % 17 + 1))
                if vector.dot(vector.cross(it_11, iu_7), iv_2) == vector.dot(vector.cross(iu_7, iv_2), it_11) then
                    ho = "#8b93a3"
                else
                    h8 = "#8b93a3"
                end
                ig = (ig + 37) % 116
            end
        else
            local lT = bit32.rrotate(bit32.bxor(bit32.lrotate(ig, 4), 35), 28)
            if bit32.bxor(bit32.lrotate(bit32.bxor(lT, 2344791778), 10), 180062767) == bit32.lrotate(lT, 10) then
                Window = h_:CreateWindow({
                    Title = "Tempo Hub",
                    Footer = { { Text = hL, Copyable = true }, "|", im },
                    Icon = 12645376577,
                    NotifySide = "Right",
                    ShowCustomCursor = false,
                    CornerRadius = 10
                })
            else
                h_ = Window:CreateWindow({
                    Icon = 12645376577,
                    CornerRadius = 10,
                    ShowCustomCursor = false,
                    Title = "Tempo Hub",
                    Footer = { hL, { Text = im, Copyable = true }, "|" },
                    NotifySide = "Right"
                })
            end
            ig = (ig + 95) % 116
        end
    elseif is_1 <= 22 then
        if is_1 <= 19 then
            if is_1 <= 17 then
                if is_1 <= 16 then
                    local it_12 = (vector.create((ig * 2 + 7) % 11 + 1, (ig * 4 + 8) % 13 + 1, (ig * 5 + 4) % 17 + 1))
                    local iu_8 = (vector.create((ig * 3 + 9) % 11 + 1, (ig * 8 + 13) % 13 + 1, (ig * 1 + 2) % 17 + 1))
                    local iv_3 = (vector.create((ig * 6 + 4) % 11 + 1, (ig * 3 + 3) % 13 + 1, (ig * 6 + 3) % 17 + 1))
                    local iw_1 = (vector.create((ig * 5 + 7) % 11 + 1, (ig * 4 + 3) % 13 + 1, (ig * 1 + 14) % 17 + 1))
                    if vector.dot(vector.cross(it_12, iu_8), (vector.cross(iv_3, iw_1))) == vector.dot(it_12, iv_3) * vector.dot(iu_8, iw_1) - vector.dot(it_12, iw_1) * vector.dot(iu_8, iv_3) then
                        ir = {
                            Info = Window:AddTab("Info", "info"),
                            Main = Window:AddTab("Main", "coins"),
                            Progression = Window:AddTab("Progression", "trending-up"),
                            Items = Window:AddTab("Items", "package-open"),
                            Settings = Window:AddTab("Settings", "settings")
                        }
                        h0 = "Unknown"
                        pcall(fn41)
                        local AccountGroup = ir.Info:AddLeftGroupbox("Account", "circle-user")
                        AccountGroup:AddLabel(hV("User", hQ.Name, hG), true)
                        AccountGroup:AddLabel(hV("Status", "Keyless", hG), true)
                        AccountGroup:AddLabel(hV("Executor", h0, hG), true)
                        GameInfoGroup = ir.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                        GameInfoGroup:AddLabel(h8(im .. " [" .. tostring(game.PlaceId) .. "]", hA), true)
                        GameInfoGroup:AddLabel(hV("Place ID", tostring(game.PlaceId), hA), true)
                        Label = GameInfoGroup:AddLabel(hV("Session time", "0s", hu), true)
                    else
                        local ih_2 = {
                            Settings = hA:AddTab("Settings", "settings"),
                            Items = hA:AddTab("Items", "package-open"),
                            Info = hA:AddTab("Info", "info"),
                            Progression = hA:AddTab("Progression", "trending-up"),
                            Main = hA:AddTab("Main", "coins")
                        }
                        ir = "Unknown"
                        pcall(fn41)
                        hQ = ih_2.Info:AddLeftGroupbox("Account", "circle-user")
                        hQ:AddLabel(Label("User", nil, Window), true)
                        hQ:AddLabel(Label("Status", "Keyless", Window), true)
                        hQ:AddLabel(Label("Executor", "Unknown", Window), true)
                        hV = ih_2.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                        hV:AddLabel(GameInfoGroup(h0 .. " [" .. tostring(game.PlaceId) .. "]", hu), true)
                        hV:AddLabel(Label("Place ID", tostring(game.PlaceId), hu), true)
                        h8 = hV:AddLabel(Label("Session time", "0s", hG), true)
                    end
                    ig = (ig + 95) % 116
                else
                    local it_13 = {
                        "bsogoei",
                        "dgjiq",
                        "uajphxwx",
                        "cmmfbqwjksx",
                        "onmxvjige",
                        "piyljwie",
                        "dqqfueczaqb",
                        "dbdptjicx",
                        "lznwozpfuon",
                        "yujvetyejon",
                        "pgeqpscf",
                        "ngydyjluz"
                    }
                    local ms = ig
                    local iu_9 = it_13[ms % 12 + 1]
                    if iu_9:len() >= iu_9:reverse():rep(ms % 3 + 2):len() then
                        hC = tostring(game.JobId)
                    else
                        hx = tostring(game.JobId)
                    end
                    ig = (ig + 37) % 116
                end
            elseif is_1 <= 18 then
                local mr = bit32.rrotate(bit32.bxor(bit32.lrotate(ig, 7), string.byte(tostring(hQ))), 27)
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(mr, 1960908089), 1347634153), (bit32.bxor(bit32.band(mr, 2334059206), 2167426685))), 1347634153), 2167426685) == mr then
                    ik_1 = #hx > 18
                else
                    hx = #ik_1 > 18
                end
                ig = (ig + 95) % 116
            else
                if (ig * 2 + 3) * 10 % 3 == ((ig * 2 + 3) * 10 + 3) % 3 then
                    ic_1 = game:GetService("Players")
                else
                    hA = game:GetService("Players")
                end
                ig = (ig + 95) % 116
            end
        elseif is_1 <= 21 then
            if is_1 <= 20 then
                if ig * 58695751 + 2 + 3 <= ig * 58695751 + 2 + 3 + 2 then
                    h6 = game:GetService("ReplicatedStorage")
                else
                    h9 = game:GetService("ReplicatedStorage")
                end
                ig = (ig + 95) % 116
            else
                local it_14 = (vector.create((ig * 5 + 4) % 11 + 1, (ig * 7 + 3) % 13 + 1, (ig * 12 + 5) % 17 + 1))
                local iu_10 = (vector.create((ig * 2 + 2) % 11 + 1, (ig * 7 + 8) % 13 + 1, (ig * 3 + 3) % 17 + 1))
                local iv_4 = (vector.create((ig * 4 + 9) % 11 + 1, (ig * 4 + 7) % 13 + 1, (ig * 13 + 9) % 17 + 1))
                if vector.dot(vector.cross(it_14, iu_10), iv_4) == vector.dot(vector.cross(iu_10, iv_4), it_14) then
                    h1 = game:GetService("MarketplaceService")
                    hX = game:GetService("VirtualUser")
                    ip = game:GetService("UserInputService")
                else
                    ip = game:GetService("MarketplaceService")
                    h1 = game:GetService("VirtualUser")
                    hX = game:GetService("UserInputService")
                end
                ig = (ig + 37) % 116
            end
        else
            local it_15 = (vector.create((ig * 6 + 8) % 11 + 1, (ig * 7 + 4) % 13 + 1, (ig * 6 + 9) % 17 + 1))
            local iu_11 = (vector.create((ig * 3 + 6) % 11 + 1, (ig * 3 + 1) % 13 + 1, (ig * 13 + 3) % 17 + 1))
            local iv_5 = (vector.create((ig * 3 + 2) % 11 + 1, (ig * 8 + 8) % 13 + 1, (ig * 15 + 13) % 17 + 1))
            if vector.dot(vector.cross(it_15, iu_11), iv_5) == vector.dot(vector.cross(iu_11, iv_5), it_15) + 3 then
                ic_1 = hQ.LocalPlayer
            else
                hQ = ic_1.LocalPlayer
            end
            ig = (ig + 66) % 116
        end
    elseif is_1 <= 26 then
        if is_1 <= 24 then
            if is_1 <= 23 then
                if ig * 123948461 + 1 + 5 <= ig * 123948461 + 1 + 5 + 2 then
                    im = "Coin Flip"
                else
                    hl = "Coin Flip"
                end
                ig = (ig + 66) % 116
            else
                local it_16 = (vector.create((ig * 2 + 5) % 11 + 1, (ig * 9 + 6) % 13 + 1, (ig * 1 + 8) % 17 + 1))
                local iu_12 = (vector.create((ig * 4 + 1) % 11 + 1, (ig * 6 + 9) % 13 + 1, (ig * 6 + 8) % 17 + 1))
                local me = vector.cross(it_16, iu_12)
                local mf = vector.dot(it_16, iu_12)
                if vector.dot(me, me) + mf * mf == vector.dot(it_16, it_16) * vector.dot(iu_12, iu_12) then
                    hL = "https://discord.gg/K7Qxnxkk46"
                else
                    h_ = "https://discord.gg/K7Qxnxkk46"
                end
                ig = (ig + 66) % 116
            end
        elseif is_1 <= 25 then
            local it_17 = (vector.create((ig * 4 + 9) % 11 + 1, (ig * 7 + 4) % 13 + 1, (ig * 8 + 15) % 17 + 1))
            local iu_13 = (vector.create((ig * 2 + 9) % 11 + 1, (ig * 5 + 2) % 13 + 1, (ig * 3 + 17) % 17 + 1))
            local iv_6 = (vector.create((ig * 1 + 1) % 5 + 1, (ig * 2 + 3) % 7 + 1, (ig * 5 + 4) % 9 + 1))
            if math.abs((vector.angle(it_17, iu_13, iv_6))) - math.abs((vector.angle(iu_13, it_17, iv_6))) == 3 then
                hC = "https://discord.gg/K7Qxnxkk46"
            else
                hI = "https://discord.gg/K7Qxnxkk46"
            end
            ig = (ig + 66) % 116
        else
            local it_18 = { "ixybutxdzry", "cjo", "oogubqh", "tsmgbin", "tfvhf", "jvjddt", "hzaf", "insidhvawg", "hcdvos" }
            local mj = ig
            local iu_14 = it_18[mj % 9 + 1]
            if iu_14:len() >= iu_14:reverse():rep(mj % 3 + 2):len() then
                h6 = ie_1:WaitForChild("RemoteEvents")
            else
                ie_1 = h6:WaitForChild("RemoteEvents")
            end
            ig = (ig + 95) % 116
        end
    elseif is_1 <= 28 then
        if is_1 <= 27 then
            local is_2 = {
                "ouose",
                "mdmrl",
                "sqkz",
                "rxedlmawpf",
                "zokmsayil",
                "pziwkajiwzj",
                "wip",
                "jiqfiwjp",
                "thivugce",
                "lytoogzthd",
                "ioeobhxvp",
                "mjotrkfcdur",
                "oxpl",
                "sprtn"
            }
            if is_2[(ig * 80 + 39) % 14 + 1] <= is_2[(ig * 80 + 39) % 14 + 1] then
                hy = ie_1:WaitForChild("GetPlayerStats")
                hr = ie_1:WaitForChild("CoinFlipResult")
                hl = ie_1:WaitForChild("PurchaseUpgrade")
                h9 = ie_1:WaitForChild("RebirthRequested")
            else
                h9 = hl:WaitForChild("GetPlayerStats")
                ie_1 = hl:WaitForChild("CoinFlipResult")
                hy = hl:WaitForChild("PurchaseUpgrade")
                hr = hl:WaitForChild("RebirthRequested")
            end
            ig = (ig + 8) % 116
        else
            local is_3 = { "lfhvper", "jusc", "skm", "ncb", "fdwvoxa", "ixya", "xslavmbp", "krd", "gwxtnyqlfkiq" }
            if is_3[(ig * 24 + 56) % 9 + 1] <= is_3[(ig * 24 + 56) % 9 + 1] then
                h5 = ie_1:WaitForChild("AscendRequested")
                GetInventory = ie_1:WaitForChild("GetInventory")
            else
                ie_1 = GetInventory:WaitForChild("AscendRequested")
                h5 = GetInventory:WaitForChild("GetInventory")
            end
            ig = (ig + 95) % 116
        end
    else
        if (ig * 3 + 6) * 13 % 4 == ((ig * 3 + 6) * 13 + 5) % 4 then
            hO = UnequipItem:WaitForChild("EquipItem")
            hW = UnequipItem:WaitForChild("UnequipItem")
            ie_1 = UnequipItem:WaitForChild("GetStash")
        else
            hW = ie_1:WaitForChild("EquipItem")
            UnequipItem = ie_1:WaitForChild("UnequipItem")
            hO = ie_1:WaitForChild("GetStash")
        end
        ig = (ig + 95) % 116
    end
until (ig * 71 + 41) % 116 == 70
if ik_1 then
    local ic_2 = 1
    repeat
        local ie_2 = {
            "bclmaqkhcy",
            "reoskqhn",
            "fdduh",
            "mrtqftww",
            "qljjq",
            "ymbd",
            "nnjylmh",
            "eiemaka",
            "uydcpds",
            "zlrcqikh",
            "iipmtnhws"
        }
        local mh = ic_2
        ig = ie_2[mh % 11 + 1]
        if ig:len() >= ig:gsub("(.)", "%1%1", mh % 3 % 2 + 1):len() then
            hx = string.sub(ik_1, 1, 18) .. "..."
        else
            ik_1 = string.sub(hx, 1, 18) .. "..."
        end
        ic_2 = (ic_2 + 5) % 8
    until (ic_2 * 1 + 0) % 8 == 6
end
local ic_3 = ik_1 or hx
hR, hm, Label2, Label3, Label4, Label5, hz, iA_1, ih_3, hs, hn, connection, connection2, ia, h4, ht, hT = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
ig = ic_3
GameInfoGroup:AddLabel(hV("Server", ig, ho), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
hR = os.clock()
task.spawn(worker)
local ScriptsGroup = ir.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(h8("Included in this hub", ho), true)
ScriptsGroup:AddLabel(h8(im, hA), true)
local FeaturesGroup = ir.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(h8("Auto Flip", hA), true)
FeaturesGroup:AddLabel(h8("Auto Buy Upgrades", hA), true)
FeaturesGroup:AddLabel(h8("Auto Rebirth", hu), true)
FeaturesGroup:AddLabel(h8("Auto Ascend", hu), true)
FeaturesGroup:AddLabel(h8("Auto Equip Best Items", hu), true)
FeaturesGroup:AddLabel(h8("Auto Use Potions", hG), true)
FeaturesGroup:AddLabel(h8("Auto Open Chests", hG), true)
FeaturesGroup:AddLabel(h8("Auto Claim Achievements", ho), true)
local SocialsGroup = ir.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = hC })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = ir.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = hC })
local FaqGroup = ir.Info:AddRightGroupbox("FAQ", "circle-help")
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
fn152(ir.Main)
fn152(ir.Progression)
fn152(ir.Items)
fn152(ir.Settings)
hm = nil
if ((not SocialsGroup and SocialsGroup or (hs or not SocialsGroup)) and (ih_3 and hT or not hT and not iA_1) and (not h4 or SocialsGroup or not hs and hs or (not hs and h4 or not ih_3 and SocialsGroup)) or (not SocialsGroup or not ih_3 or (not h4 or not h4)) and (not hs and not hs and (hT and hs)) and ((hT or not SocialsGroup or (h4 or not h4)) and ((hT or not SocialsGroup) and (hT and not hT)))) and not ((not SocialsGroup and SocialsGroup or (hs or not SocialsGroup)) and (ih_3 and hT or not hT and not iA_1) and (not h4 or SocialsGroup or not hs and hs or (not hs and h4 or not ih_3 and SocialsGroup)) or (not SocialsGroup or not ih_3 or (not h4 or not h4)) and (not hs and not hs and (hT and hs)) and ((hT or not SocialsGroup or (h4 or not h4)) and ((hT or not SocialsGroup) and (hT and not hT)))) then
    h4 = fn650
else
    ia = fn650
end
local FlipGroup = ir.Main:AddLeftGroupbox("Flip", "circle-dollar-sign")
FlipGroup:AddToggle("AutoFlip", { Text = "Auto Flip", Default = false })
FlipGroup:AddSlider("FlipDelay", { Text = "Extra Delay", Default = 0, Min = 0, Max = 2, Rounding = 2, Suffix = "s" })
local StatsGroup = ir.Main:AddRightGroupbox("Stats", "chart-line")
Label2 = StatsGroup:AddLabel(hV("Balance", "0", hG), true)
Label3 = StatsGroup:AddLabel(hV("Total flips", "0", hA), true)
Label4 = StatsGroup:AddLabel(hV("Rebirths", "0", hu), true)
Label5 = StatsGroup:AddLabel(hV("Level", "0", ho), true)
local CodesGroup = ir.Main:AddRightGroupbox("Codes", "ticket")
h4 = fn215
hz = false
CodesGroup:AddButton({
    Text = "Redeem All Codes",
    Func = function()
        if hz then
            return
        end
        hz = true
        task.spawn(function()
            local jj_1
            local ji_1
            local jg = h4()
            if #jg == 0 then
                h_:Notify("No codes found")
                hz = false
                return
            end
            local jh = 0
            for i, v in ipairs(jg) do
                local jr = v
                ji_1, jj_1 = pcall(function()
                    return RedeemCode:InvokeServer(jr)
                end)
                local jk = ji_1 and type(jj_1) == "table" and jj_1.success
                if jk then
                    jh = jh + 1
                end
                task.wait(0.5)
            end
            h_:Notify(string.format("Redeemed %d of %d codes", jh, #jg))
            hz = false
        end)
    end
})
local UpgradesGroup = ir.Progression:AddLeftGroupbox("Upgrades", "arrow-big-up-dash")
UpgradesGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
UpgradesGroup:AddDropdown("UpgradeList", { Values = hj, Multi = true, Searchable = true, Text = "Upgrades" })
UpgradesGroup:AddToggle("BuyMax", { Text = "Buy Max", Default = false })
local RebirthGroup = ir.Progression:AddRightGroupbox("Rebirth", "rotate-ccw")
do
    RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
    RebirthGroup:AddToggle("AutoAscend", { Text = "Auto Ascend", Default = false })
    RebirthGroup:AddSlider("AscendAtRebirths", { Text = "Ascend At Rebirths", Default = 25, Min = 25, Max = 30, Rounding = 0 })
    RebirthGroup:AddToggle("AutoCycleBonus", { Text = "Auto Choose Rebirth Bonus", Default = false })
    RebirthGroup:AddDropdown("CycleBonus", { Values = hY, Default = hY[1], Searchable = true, Text = "Cycle Bonus" })
    local AchievementsGroup = ir.Progression:AddRightGroupbox("Achievements", "trophy")
    AchievementsGroup:AddToggle("AutoClaimAchievements", { Text = "Auto Claim Achievements", Default = false })
    local EquipmentGroup = ir.Items:AddLeftGroupbox("Equipment", "shirt")
    EquipmentGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best Items", Default = false })
    local PotionsGroup = ir.Items:AddRightGroupbox("Potions", "flask-round")
    PotionsGroup:AddToggle("AutoUsePotions", { Text = "Auto Use Potions", Default = false })
    PotionsGroup:AddDropdown("PotionList", { Values = h2, Multi = true, Searchable = true, Text = "Potions" })
    local ChestsGroup = ir.Items:AddRightGroupbox("Chests", "box")
    ChestsGroup:AddToggle("AutoOpenChests", { Text = "Auto Open Chests", Default = false })
    ChestsGroup:AddDropdown("ChestList", { Values = h7, Multi = true, Searchable = true, Text = "Chests" })
    task.spawn(autoFlipLoop)
    task.spawn(worker2)
    task.spawn(function()
        local jN = false
        repeat
            if not h_.Unloaded then
                task.wait(1)
                if hN.AutoBuyUpgrades.Value then
                    local jE = hm
                    if jE and jE.upgrades and jE.upgradeCosts then
                        local jF_1 = tonumber(jE.balanceCents) or 0
                        local jG = jF_1
                        local jD = hN.BuyMax.Value and "max" or 1
                        for i, v in ipairs(hj) do
                            local jT = v
                            if Options.UpgradeList.Value[jT] then
                                local jF_3 = tonumber(jE.upgradeCosts[jT])
                                local jH_1 = jE.upgradeMaxLevels and tonumber(jE.upgradeMaxLevels[jT])
                                local jH_2 = tonumber(jE.upgrades[jT]) or 0
                                local jJ = jH_1
                                if jJ then
                                    jJ = jH_2 >= jH_1
                                end
                                local jH_3 = jF_3
                                local jI_1 = jJ
                                if jH_3 then
                                    jH_3 = jF_3 >= 0
                                end
                                if jH_3 then
                                    jH_3 = jF_3 <= jG
                                end
                                if jH_3 and not jI_1 then
                                    pcall(function()
                                        hl:InvokeServer(jT, jD)
                                    end)
                                    ia()
                                    jE = hm
                                    local jF_5 = jE and tonumber(jE.balanceCents)
                                    jG = jF_5 or 0
                                end
                            end
                        end
                    end
                end
            else
                jN = true
            end
        until jN
    end)
    task.spawn(autoRebirthLoop)
    task.spawn(autoAscendLoop)
    task.spawn(function()
        local j7 = false
        repeat
            if not h_.Unloaded then
                task.wait(0.5)
                if hN.AutoCycleBonus.Value then
                    local CycleChoiceGui = hQ.PlayerGui:FindFirstChild("CycleChoiceGui")
                    local j4 = CycleChoiceGui and CycleChoiceGui:FindFirstChild("CycleChoiceDim")
                    if j4 then
                        local j2 = hU[Options.CycleBonus.Value] or hU[hY[1]]
                        if j2 then
                            pcall(function()
                                hv:InvokeServer(j2)
                            end)
                            j4:Destroy()
                        end
                    end
                end
            else
                j7 = true
            end
        until j7
    end)
    ht = fn140
end
task.spawn(function()
    local kl_1
    local kk_1
    while not h_.Unloaded do
        task.wait(5)
        if hN.AutoEquipBest.Value then
            local kj = hm
            kk_1, kl_1 = pcall(function()
                return GetInventory:InvokeServer()
            end)
            local km = kk_1 and type(kl_1) == "table"
            if km and kj then
                local kk_3 = tonumber(kj.extraBackpackSlots) or 0
                local kj_1 = 1 + kk_3
                local kk_4 = {}
                for i, v in ipairs(kl_1) do
                    local kn_1 = v.equipped and 1
                    if not kn_1 then
                        local max = math.max
                        local ko = tonumber(v.count) or 1
                        kn_1 = max(1, ko)
                    end
                    local km_3 = kn_1
                    local kz = 1
                    while kz <= km_3 do
                        kk_4[#kk_4 + 1] = v
                        kz += 1
                    end
                end
                table.sort(kk_4, function(dd, de)
                    local kf = ib[dd.rarity] or 99
                    local kf_1 = ib[de.rarity] or 99
                    if kf ~= kf_1 then
                        return kf < kf_1
                    end
                    local kf_2 = ht(dd)
                    local kg_1 = ht(de)
                    if kf_2 ~= kg_1 then
                        return kg_1 < kf_2
                    end
                    return (dd.name or dd.id) < (de.name or de.id)
                end)
                local km_4 = {}
                local kn_2 = math.min(kj_1, #kk_4)
                local kE = 1
                while kE <= kn_2 do
                    local key = kk_4[kE].key
                    local kn_3 = km_4[key] or 0
                    km_4[key] = kn_3 + 1
                    kE += 1
                end
                for i, v in ipairs(kl_1) do
                    local kM = v
                    if kM.equipped and not km_4[kM.key] then
                        pcall(function()
                            UnequipItem:InvokeServer(kM.key)
                        end)
                    end
                end
                for i, v in ipairs(kl_1) do
                    local kQ = v
                    local kj_4 = km_4[kQ.key]
                    if kj_4 and not kQ.equipped then
                        local kT = 1
                        while kT <= kj_4 do
                            pcall(function()
                                hW:InvokeServer(kQ.key)
                            end)
                            kT += 1
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    local kY_1
    local kX_1
    while not h_.Unloaded do
        task.wait(0.5)
        if hN.AutoUsePotions.Value then
            kX_1, kY_1 = pcall(function()
                return hO:InvokeServer()
            end)
            local kZ = kX_1 and type(kY_1) == "table"
            if kZ then
                for i, v in ipairs(h2) do
                    local k5 = v
                    local kX_2 = kY_1[k5]
                    local kZ_1 = Options.PotionList.Value[k5] and type(kX_2) == "table"
                    if kZ_1 then
                        local kZ_2 = tonumber(kX_2.count) or 0
                        local kW = kZ_2
                        if kW > 0 then
                            pcall(function()
                                hM:InvokeServer(k5, kW)
                            end)
                        end
                    end
                end
            end
        end
    end
end)
task.spawn(function()
    local k7_1
    local k6_1
    while not h_.Unloaded do
        task.wait(5)
        if hN.AutoOpenChests.Value then
            k6_1, k7_1 = pcall(function()
                return GetChestInventory:InvokeServer()
            end)
            local k8 = k6_1 and type(k7_1) == "table"
            if k8 then
                for i, v in ipairs(h7) do
                    local lf = v
                    local k6_2 = Options.ChestList.Value[lf]
                    if k6_2 then
                        local k8_1 = tonumber(k7_1[lf]) or 0
                        k6_2 = k8_1 > 0
                    end
                    if k6_2 then
                        pcall(function()
                            hH:InvokeServer(lf)
                        end)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)
task.spawn(autoClaimAchievementsLoop)
local MenuGroup = ir.Settings:AddLeftGroupbox("Menu", "menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
h_.ToggleKeybind = Options.MenuKeybind
hs = tick()
hn = tick()
pcall(function()
    for i, v in ipairs(getconnections(hQ.Idled)) do
        local ln = v
        pcall(function()
            ln:Disable()
        end)
    end
end)
hT = fn44
connection = ip.InputBegan:Connect(onInputBegan)
connection2 = ip.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddButton("Unload", onUnload)
h_:OnUnload(fn644)
iq:SetLibrary(h_)
iq:SetFolder("TempoHub")
iq:SaveDefault("Monochrome")
iq:ApplyToTab(ir.Settings)
iq:LoadDefault()
io:SetLibrary(h_)
io:IgnoreThemeSettings()
io:SetIgnoreIndexes({ "MenuKeybind" })
io:SetFolder("TempoHub/coin-flip")
io:BuildConfigSection(ir.Settings)
io:LoadAutoloadConfig()
ia()
end)(...)
