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
getgenv().TempoHoodSubtitle = "YOUR LUMBER FARM!"
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
local wp_1, wp_3, wp_4, wp_9, wp_12, wp_15, wp_18, wp_20, wp_22, wp_24, wp_27, wp_30, wp_33, RebirthUpgradesGroup, wp_36, wp_39, wp_41, wp_44, wp_47, wp_49, wp_52
local px
local ox
local Label5
local nS
local pk
local og
local oJ
local o7
local n3
local pw
local ow
local oV
local nR
local pj
local of
local oI
local o6
local n2
local Label
local ov
local oU
local connection2
local pi
local SHARED_LumberjackConfig
local CLIENT_InventoryUIController
local o5
local n1
local pu
local ou
local oT
local nP
local od
local oG
local o4
local n0
local pt
local Toggles
local connection3
local SHARED_EventTokenConfig
local pg
local connection
local oF
local o3
local n_
local ps
local oq
local oR
local nN
local SHARED_RebirthConfig
local ob
local pE
local oE
local o2
local nZ
local pr
local op
local oQ
local nM
local pe
local oa
local pD
local oD
local nY
local pq
local oo
local Label6
local nL
local pd
local n9
local pC
local SHARED_ItemConstants
local Label4
local nX
local pp
local om
local CLIENT_BaseController
local nK
local pc
local n8
local pB
local oB
local Knit
local nW
local po
local ol
local oN
local SHARED_RebirthUtils
local n7
local pA
local oA
local oZ
local nV
local pn
local oj
local Label7
local Label2
local n6
local pz
local oz
local oY
local nU
local pm
local oi
local oL
local o9
local n5
local SHARED_PlacementTransform
local SHARED_TreeConfig
local oX
local nT
local pl
local oh
local oK
local Label3
local SHARED_ToolConfig
function fns.fn3(bc)
    local rh = SHARED_LumberjackConfig.getLumberjack(bc)
    return rh and rh.DisplayName or bc
end
function fns.fn7(b2, b3, b4, b5, b6, b7, b8, b9, ca, cb, cc, cd, ce)
    local rK = pm()
    if not rK then
        return
    end
    local rL = pj(b2, b5)
    local rM = tonumber(nV(cb)) or 0
    local rM_1 = Knit.GetService(b8)
    for i, v in ipairs(b4) do
        if oQ.Unloaded then
            return
        end
        local rO = b5[v]
        local rP = rO
        if rP then
            rP = b3 or rL[rO]
        end
        if rP then
            local rP_1 = b6[rO]
            local rQ_2 = rK[b7]
            local rR = rQ_2 and rQ_2.Stock
            local rQ_3 = rP_1
            if rQ_3 then
                rQ_3 = oL(rR, rO) > 0
            end
            if rQ_3 then
                rQ_3 = (rK[ca] or 0) - rP_1 >= rM
            end
            if rQ_3 then
                local rP_2 = rM_1[b9](rM_1, rO, ce)
                local rO_1 = rP_2 and og(cd)
                if rO_1 then
                    oQ:Notify(("Bought %s"):format(v))
                end
                local wait = task.wait
                local rP_3 = nV(cc) or 0.2
                wait(rP_3)
                rK = pm()
                if not rK then
                    return
                end
            end
        end
    end
end
function fns.fn12(d6, d7, d8, d9)
    local sQ = pm()
    if not sQ then
        return
    end
    for k in pairs(sQ[d6]) do
        if oQ.Unloaded then
            return
        end
        if not n2(d7, k) then
            return
        end
        local sR = Knit.GetService("ToolInteractionService"):RequestInteraction(d8, d7, k)
        if not sR then
            return
        end
        if og("PlaceNotify") then
            oQ:Notify(d9)
        end
        task.wait(nV("PlaceActionDelay", 0.2))
        local sQ_1 = pm()
        if not sQ_1 then
            return
        end
    end
end
function fns.fn42()
    local uD = pm()
    if not uD then
        return
    end
    local uE = nV("RollPack")
    local uF = uE and o7[uE]
    if not uF then
        return
    end
    local uF_1 = oZ[uF] or 0
    local uF_2 = tonumber(nV("TokenReserve")) or 0
    if (uD.EventTokens or 0) - uF_1 < uF_2 then
        return
    end
    local uD_1 = Knit.GetService("UnboxingService"):RequestEventPackSpin(uF)
    local uF_4 = uD_1 and og("RollNotify")
    if uF_4 then
        oQ:Notify(("Opened %s"):format(uE))
    end
end
function fns.onCopyJoinScript_JobID()
    local vt = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, po)
    if setclipboard then
        setclipboard(vt)
    elseif toclipboard then
        toclipboard(vt)
    end
    oQ:Notify("Copied join script to clipboard")
end
function fns.fn65(hx)
    local DiscordGroup = hx:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = pg })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = pg })
end
function fns.fn82(bT, bU)
    local rw = {}
    for k, v in pairs(bT) do
        if v then
            local rx = bU[k]
            if rx then
                rw[rx] = true
            end
        end
    end
    return rw
end
function fns.fn89(eG)
    local tc = nU.getPet(eG)
    local td = tc and tc.ItemRarity
    local tc_1 = td
    if td then
        td = SHARED_ItemConstants.RarityIndex[tc_1]
    end
    return tc_1, td or 0
end
function fns.fn108(bj)
    local rn = SHARED_ToolConfig.getTool(bj)
    return rn and rn.DisplayName or bj
end
function fns.fn124()
    local uj = o4()
    local uk = pm()
    if not (uj and uk) then
        return
    end
    for i, v in ipairs(oF(uj)) do
        if oQ.Unloaded then
            return
        end
        if not v:GetAttribute("EggId") then
            local uj_1 = next(uk.Egg)
            if not uj_1 then
                return
            end
            local ul_1 = Knit.GetService("BaseService"):RequestPlaceEgg(v.Name, uj_1)
            local uj_2 = ul_1 and og("EggNotify")
            if uj_2 then
                oQ:Notify("Started incubating an egg")
            end
            task.wait(nV("EggActionDelay", 0.2))
            uk = pm()
            if not uk then
                return
            end
        end
    end
end
function fns.fn130()
    pe("Pet", "Pet", "PlacePet", "Placed a pet")
end
function fns.fn131()
    local vC = pm()
    if not vC then
        return
    end
    local vD = vC.Cash or 0
    Label2:SetText(oN("Cash", n1(vD), om))
    local vD_1 = vC.Gems or 0
    Label3:SetText(oN("Gems", n1(vD_1), oh))
    local vD_2 = vC.EventTokens or 0
    Label4:SetText(oN("Event Tokens", n1(vD_2), od))
    local vD_3 = vC.Rebirths
    local vL = if vD_3 then 1 else 0
    local vJ = 3384 * vL + 4080 * (1 - vL)
    local vK = 819 * vL + 1898 * (1 - vL)
    if not ((vJ * 2377 + vK * 1172 + vJ * vK) % 16777213 == 11775132) then
        vD_3 = 0
    end
    Label5:SetText(oN("Rebirths", tostring(vD_3), ob))
    local getReqCashForNext = SHARED_RebirthConfig.getReqCashForNext
    local vE = vC.Rebirths or 0
    Label6:SetText(oN("Next rebirth", n1(getReqCashForNext(vE)), od))
    Label7:SetText(oN("Plot level", ("%d / %d"):format(of(vC), pk.getMaxExpandLevel()), oh))
end
function fns.fn166(b_, b0)
    if type(b_) ~= "table" then
        return 0
    end
    return b_[b0] or 0
end
function fns.fn226()
    oz(nZ, og("BuyAllTrees"), o5, oY, oT, "TreeStock", "TreeStockService", "PurchaseTree", "Cash", "TreeReserve", "TreeActionDelay", "TreeNotify")
end
function fns.worker6()
    while not oQ.Unloaded do
        if og("AutoRoll") then
            pcall(pB)
        end
        task.wait(nV("RollLoopDelay", 2))
    end
end
function fns.onPlotUpgradeSelection(iv)
    px = iv
end
function fns.fn249()
    oQ.ScreenGui.Parent = pq:WaitForChild("PlayerGui")
end
function fns.fn302()
    oz(pA, og("BuyAllEggs"), pp, pi, pd, "EggStock", "EggStockService", "PurchaseEgg", "Gems", "EggReserve", "EggActionDelay", "EggNotify", 1)
end
function fns.fn309()
    pe("Lumberjack", "Lumberjack", "PlaceLumberjack", "Placed a lumberjack")
end
function fns.fn314()
    local vj_1
    local vi_1
    if identifyexecutor then
        vj_1, vi_1 = identifyexecutor()
        local vk = vj_1 ~= ""
        local vl = type(vj_1) == "string" and vk
        if vl then
            local vk_1 = type(vi_1) == "string" and vi_1 ~= "" and vj_1 .. " " .. vi_1
            n3 = vk_1 or vj_1
        end
    end
end
function fns.onInputBegan()
    o9 = tick()
end
function fns.onUnload()
    oQ:Unload()
end
function fns.worker7()
    while not oQ.Unloaded do
        if og("AutoPlotUpgrades") then
            pcall(ou)
        end
        if og("AutoExpandPlot") then
            pcall(n5)
        end
        if og("AutoRebirthUpgrades") then
            pcall(nW)
        end
        if og("AutoRebirth") then
            pcall(pn)
        end
        task.wait(nV("UpgradeLoopDelay", 3))
    end
end
function fns.onLumberjackSelection(h8)
    pE = h8
end
function fns.fn360()
    oR(pr, og("AllRebirthUpgrades"), ox, oq, "PetUpgrades", pC.getUpgradeGemCost, pC.getMaxLimitLevel, "Gems", "UpgradeGemReserve", "RequestPetUpgrade")
end
function fns.fn362()
    local uK = pm()
    if not uK then
        return
    end
    local uL = of(uK)
    local uS = if uL >= pk.getMaxExpandLevel() then 1 else 0
    if uS == 1 then
        return
    end
    local uM = pk.getExpandGemCost(uL)
    local uL_1 = tonumber(nV("ExpandGemReserve")) or 0
    local uN = not uM
    if not uN then
        local uL_2 = uK.Gems
        local uV = if uL_2 then 1 else 0
        local uT = 357 * uV + 3045 * (1 - uV)
        local uU = 938 * uV + 1023 * (1 - uV)
        if not ((uT * 152 + uU * 212 + uT * uU) % 16777213 == 587986) then
            uL_2 = 0
        end
        uN = uL_2 - uM < uL_1
    end
    if uN then
        return
    end
    local uK_1 = Knit.GetService("UpgradeService"):RequestFarmExpand()
    local uL_3 = uK_1 and og("UpgradeNotify")
    if uL_3 then
        oQ:Notify("Expanded the plot")
    end
end
function fns.fn363(eO)
    local tm_1
    local tk_1
    local tj_1
    local tl_1
    tk_1, tj_1 = nil, nil
    for k, v in pairs(eO.Pet) do
        tl_1, tm_1 = n6(v.ItemId)
        if not tj_1 or tm_1 > tj_1 then
            tk_1 = k
            tj_1 = tm_1
        end
    end
    return tk_1, tj_1 or 0
end
function fns.worker()
    local vw_1
    while true do
        task.wait(1)
        if oQ.Unloaded then
            break
        end
        local vv = math.floor(os.clock() - oU)
        if vv < 60 then
            vw_1 = vv .. "s"
        elseif vv < 3600 then
            vw_1 = string.format("%dm %ds", math.floor((vv) / (60)), vv % 60)
        else
            vw_1 = string.format("%dh %dm", math.floor((vv) / (3600)), math.floor((vv % 3600) / (60)))
        end
        Label:SetText(oN("Session time", vw_1, od))
    end
end
function fns.fn369()
    oz(pE, og("BuyAllLumberjacks"), ov, op, oi, "LumberjackStock", "LumberjackStockService", "PurchaseLumberjack", "Cash", "LumberjackReserve", "LumberjackActionDelay", "LumberjackNotify")
end
function fns.worker4()
    while not oQ.Unloaded do
        if og("AutoIncubate") then
            pcall(nY)
        end
        if og("AutoCollectEggs") then
            pcall(oJ)
        end
        task.wait(nV("EggLoopDelay", 3))
    end
end
function fns.fn376(aR, aS, aT)
    local qY = {}
    for k, v in pairs(aR) do
        local qZ_1 = #qY + 1
        local q__1 = v.LayoutOrder or 0
        qY[qZ_1] = { id = k, order = q__1, price = v[aT] }
    end
    table.sort(qY, function(aX, aY)
        return aX.order < aY.order
    end)
    local qZ_2 = {}
    local q__2 = {}
    local q0 = {}
    for i, v in ipairs(qY) do
        local qY_1 = string.format("%s (%s)", aS(v.id), n1(v.price))
        q0[#q0 + 1] = qY_1
        qZ_2[qY_1] = v.id
        q__2[v.id] = v.price
    end
    return q0, qZ_2, q__2
end
function fns.onRebirthUpgradeSelection(iz)
    pr = iz
end
function fns.fn432()
    local vc = pD()
    if not vc then
        return
    end
    if not SHARED_RebirthUtils.canRebirth(vc) then
        return
    end
    local vc_1 = Knit.GetService("RebirthService"):RequestRebirth()
    local vd = vc_1 and og("RebirthNotify")
    if vd then
        oQ:Notify("Rebirthed")
    end
end
function fns.fn433()
    local sG = o4()
    local sH = pm()
    if not (sG and sH) then
        return
    end
    for k, v in pairs(sH.Tree) do
        if oQ.Unloaded then
            return
        end
        if not ow(sG, sH, k, v) then
            return
        end
        sH = pm()
        sG = o4()
        if not (sG and sH) then
            return
        end
    end
end
function fns.fn439()
    local ut = o4()
    if not ut then
        return
    end
    local uu = workspace:GetServerTimeNow()
    for i, v in ipairs(oF(ut)) do
        if oQ.Unloaded then
            return
        end
        local attr = v:GetAttribute("HatchAt")
        local uv = v:GetAttribute("EggId") and attr and attr - uu <= 0
        if uv then
            local ut_2 = Knit.GetService("BaseService"):RequestCollectEgg(v.Name)
            local uv_1 = ut_2 and og("EggNotify")
            if uv_1 then
                oQ:Notify("Collected a hatched pet")
            end
            task.wait(nV("EggActionDelay", 0.2))
        end
    end
end
function fns.onTreePickupRarities(im)
    nN = im
end
function fns.fn493()
    local qS = pD()
    return qS and qS.Data
end
function fns.fn501(bI, bJ)
    return (SHARED_ItemConstants.RarityIndex[bI] or 0) < (SHARED_ItemConstants.RarityIndex[bJ] or 0)
end
function fns.onPetReplaceRarities(iq)
    nK = iq
end
function fns.fn549(a5)
    local re = SHARED_TreeConfig.getTree(a5)
    return re and re.DisplayName or a5
end
function fns.fn584(am, an)
    return string.format('<font color="%s">%s</font>', an, am)
end
function fns.worker8()
    while not oQ.Unloaded do
        pcall(oI)
        task.wait(1)
    end
end
function fns.fn629(ap, aq, ar)
    return string.format("<b>%s</b> %s %s", ap, o3("-", "#5a6070"), o3(aq, ar))
end
function fns.fn640()
    oz(nT, og("BuyAllTools"), nX, nS, nM, "ToolStock", "ToolStockService", "PurchaseTool", "Cash", "ToolReserve", "ToolActionDelay", "ToolNotify")
end
function fns.worker3()
    while not oQ.Unloaded do
        if og("AutoPlaceTrees") then
            pcall(n_)
        end
        if og("AutoPlaceLumberjacks") then
            pcall(oa)
        end
        if og("AutoPlacePets") then
            pcall(n0)
        end
        if og("AutoPickupTrees") then
            pcall(nP)
        end
        local wa = if og("AutoReplacePets") then 1 else 0
        if wa == 1 then
            pcall(oE)
        end
        task.wait(nV("PlaceLoopDelay", 2))
    end
end
function fns.worker5()
    while not oQ.Unloaded do
        if og("AutoCollectTokens") then
            pcall(n8)
        end
        task.wait(nV("TokenLoopDelay", 2))
    end
end
function fns.fn714()
    connection:Disconnect()
    connection2:Disconnect()
    pcall(function()
        connection3:Disconnect()
    end)
    select("#", "Your Lumber Farm unloaded")
end
function fns.fn725(ab, ac)
    local qC = ol[ab]
    if qC == nil or qC.Value == nil then
        return ac
    end
    return qC.Value
end
function fns.worker9()
    while not oQ.Unloaded do
        task.wait(2)
        if og("AntiAfk") then
            local wj = tick() - o9
            local wk = tick() - o2
            if wj >= 300 and wk >= 60 then
                pcall(oD)
            else
                if wj < 300 and wk >= 300 then
                    pcall(oD)
                end
            end
        end
    end
end
function fns.fn756()
    local qV = CLIENT_BaseController.getBaseObjectForPlayer(pq)
    if qV and qV.IsLocalPlayerOwner then
        return qV
    end
end
function fns.onInputChanged(ja)
    local UserInputType = ja.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        o9 = tick()
    end
end
function fns.onRscripts()
    if setclipboard then
        setclipboard(pl)
    elseif toclipboard then
        toclipboard(pl)
    end
    oQ:Notify("Copied Rscripts profile to clipboard")
end
function fns.fn814(W)
    local qz = Toggles[W]
    return qz ~= nil and qz.Value == true
end
function fns.fn818(dC, dD, dE, dF)
    local sy_1
    local PlacementAnchor = dC.PlacementAnchor
    if not PlacementAnchor then
        return false
    end
    local ItemId = dF.ItemId
    local sn = oj.getHitboxSize(ItemId, dF)
    if not sn then
        return false
    end
    local sq = dC.TreeHitboxes and { dC.TreeHitboxes } or {}
    local max = math.max
    local sq_1 = sn.X
    local sr = sn.Z
    local ss = tonumber(nV("PlacementStep", 2)) or 2
    local st = max(sq_1, sr, ss)
    local sp_2 = 0
    for k, v in pairs(dC.PatchParts) do
        if dD.UnlockedPatches[k] then
            local sq_2 = PlacementAnchor.CFrame:ToObjectSpace(v.CFrame)
            local sr_1 = v.Size.X / 2 - sn.X / 2
            local ss_1 = v.Size.Z / 2 - sn.Z / 2
            local su = -sr_1
            while su <= sr_1 do
                local sv = -ss_1
                while sv <= ss_1 do
                    if oQ.Unloaded then
                        return false
                    end
                    local sw = PlacementAnchor.CFrame * CFrame.new(sq_2.Position.X + su, sn.Y / 2, sq_2.Position.Z + sv)
                    local sw_1
                    if ps.canPlaceTree(ItemId, sw, dC.PatchParts, dD.UnlockedPatches, sq, dF) then
                        if not n2("Tree", dE) then
                            return false
                        end
                        local sx = SHARED_PlacementTransform.serializeForStorage(SHARED_PlacementTransform.toRelative(PlacementAnchor, sw))
                        sw_1, sy_1 = Knit.GetService("ToolInteractionService"):RequestInteraction("PlaceTree", "Tree", dE, sx)
                        if sw_1 then
                            o6(dC, dE)
                            if og("PlaceNotify") then
                                oQ:Notify("Placed a tree")
                            end
                            return true
                        end
                        if sy_1 ~= "overlap" and sy_1 ~= "invalid_placement" then
                            return false
                        end
                        sp_2 = sp_2 + 1
                        if sp_2 >= 10 then
                            return false
                        end
                    end
                    sv = sv + st
                end
                su = su + st
            end
        end
    end
    return false
end
function fns.fn825()
    local tx_1
    local tu = pm()
    if not tu then
        return
    end
    local tv = {}
    local tv_4
    for k in pairs(tu.PetEscrow) do
        tv[#tv + 1] = k
    end
    for i, v in ipairs(tv) do
        if oQ.Unloaded then
            return
        end
        local tv_1 = tu.PetEscrow[v]
        local tw = tv_1 and tv_1.ItemData
        local tw_1, tw_2
        if tw then
            tw_1, tx_1 = n6(tw.ItemId)
            if tw_1 and nK[tw_1] then
                tw_2, tv_4 = pu(tu)
                if tw_2 and tv_4 > tx_1 then
                    if Knit.GetService("PetService"):RequestRemovePet(v) then
                        task.wait(nV("ReplaceActionDelay", 0.2))
                        if not n2("Pet", tw_2) then
                            return
                        end
                        local tv_5 = Knit.GetService("ToolInteractionService"):RequestInteraction("PlacePet", "Pet", tw_2)
                        local tw_3 = tv_5 and og("ReplaceNotify")
                        if tw_3 then
                            oQ:Notify("Replaced a pet")
                        end
                        task.wait(nV("ReplaceActionDelay", 0.2))
                        tu = pm()
                        if not tu then
                            return
                        end
                    end
                end
            end
        end
    end
end
local function onTreeSelection(h5)
    nZ = h5
end
local function fn839()
    oR(px, og("AllPlotUpgrades"), oG, oB, "LumberjackUpgrades", n9.getUpgradeCashCost, n9.getMaxLimitLevel, "Cash", "UpgradeCashReserve", "RequestLumberjackUpgrade")
end
local function fn844()
    if not workspace.CurrentCamera then
        return
    end
    pw:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    pw:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    o2 = tick()
end
local function fn869(aA)
    local qM = (tonumber(aA))
    local qR = if qM then 1 else 0
    local qP = 83 * qR + 1055 * (1 - qR)
    local qQ = 2621 * qR + 2918 * (1 - qR)
    if not ((qP * 2357 + qQ * 2891 + qP * qQ) % 16777213 == 7990485) then
        qM = 0
    end
    aA = qM
    if aA < 1000 then
        return tostring(math.floor(aA))
    end
    local qM_1 = 0
    while aA >= 1000 and qM_1 < #n7 do
        aA = aA / 1000
        qM_1 = qM_1 + 1
    end
    return string.format("%.2f%s", aA, n7[qM_1])
end
local function fn928(dv, dw)
    local sj_1
    local TreeHitboxes = dv.TreeHitboxes
    if not TreeHitboxes then
        return
    end
    local si = os.clock() + 2
    repeat
        if TreeHitboxes:FindFirstChild(dw) then
            return
        end
        task.wait(0.05)
        sj_1 = oQ.Unloaded or os.clock() > si
    until sj_1
end
local function fn937(gt)
    return pk.getExpandLevelFromUnlockedPatches(gt.UnlockedPatches)
end
local function fn940()
    if setclipboard then
        setclipboard(pt)
    elseif toclipboard then
        toclipboard(pt)
    end
    oQ:Notify("Copied Discord invite to clipboard")
end
local function worker2()
    while not oQ.Unloaded do
        if og("AutoBuyTrees") then
            pcall(pz)
        end
        if og("AutoBuyLumberjacks") then
            pcall(oX)
        end
        if og("AutoBuyEggs") then
            pcall(oo)
        end
        if og("AutoBuyTools") then
            pcall(nR)
        end
        if og("AutoRestock") then
            pcall(pc)
        end
        task.wait(nV("ShopLoopDelay", 2))
    end
end
local function fn1000(di, dj)
    local sa = oK.getCurTool()
    local sb = sa and sa:GetAttribute("ItemUniqueId") == dj
    local sb_2
    if sb then
        return true
    end
    CLIENT_InventoryUIController.selectItemSlot(di, dj)
    local sa_1 = os.clock() + 1.5
    repeat
        task.wait(0.05)
        local sb_1 = oK.getCurTool()
        local sc = sb_1 and sb_1:GetAttribute("ItemUniqueId") == dj
        if sc then
            return true
        end
        sb_2 = oQ.Unloaded or os.clock() > sa_1
    until sb_2
    return false
end
local function fn1030(bq)
    local rq = nL.getEgg(bq)
    return rq and rq.DisplayName or bq
end
local function fn1032(ff)
    local tN = {}
    for i, descendant in ipairs(ff:GetDescendants()) do
        local tO = descendant:IsA("ProximityPrompt") and descendant.Parent and descendant.Parent:IsA("BasePart")
        if tO then
            tN[#tN + 1] = descendant
        end
    end
    return tN
end
local function fn1047(gL, gM, gN, gO, gP, gQ, gR, gS, gT, gU)
    local uZ = pm()
    if not uZ then
        return
    end
    local u_ = tonumber(nV(gT)) or 0
    local u__1 = Knit.GetService("UpgradeService")
    for i, v in ipairs(gN) do
        if oQ.Unloaded then
            return
        end
        if gM or gL[v] then
            local u1_1 = gO[v]
            local u2_1 = (uZ[gP] or {})[u1_1] or 0
            local u3_1 = true
            if u1_1 == "Limit" then
                u3_1 = u2_1 < gR(of(uZ))
            end
            if u3_1 then
                local u2_2 = gQ(u1_1, u2_1)
                local u3_2 = u2_2
                if u3_2 then
                    u3_2 = (uZ[gS] or 0) - u2_2 >= u_
                end
                if u3_2 then
                    local u2_3 = u__1[gU](u__1, u1_1)
                    local u1_2 = u2_3 and og("UpgradeNotify")
                    if u1_2 then
                        oQ:Notify(("%s upgraded"):format(v))
                    end
                    task.wait(nV("UpgradeActionDelay", 0.2))
                    uZ = pm()
                    if not uZ then
                        return
                    end
                end
            end
        end
    end
end
local function fn1061()
    local sX = pm()
    if not sX then
        return
    end
    local sY = {}
    for k in pairs(sX.PlacedTrees) do
        sY[#sY + 1] = k
    end
    for i, v in ipairs(sY) do
        if oQ.Unloaded then
            return
        end
        local sY_1 = sX.PlacedTrees[v]
        local sZ = sY_1 and sY_1.ItemData
        local sY_2 = sZ
        if sZ then
            sZ = SHARED_TreeConfig.getTree(sY_2.ItemId)
        end
        local s_ = sZ
        if sZ then
            sZ = nN[s_.ItemRarity]
        end
        if sZ then
            local sZ_1 = Knit.GetService("TreeService"):RequestRemoveTree(v)
            local s0 = sZ_1 and og("PickupNotify")
            if s0 then
                local sZ_2 = s_.DisplayName or sY_2.ItemId
                oQ:Notify(("Picked up %s"):format(sZ_2))
            end
            task.wait(nV("PickupActionDelay", 0.2))
            sX = pm()
            if not sX then
                return
            end
        end
    end
end
local function fn1068(fD)
    local PlacementAnchor = fD.PlacementAnchor
    local ub = {}
    if not PlacementAnchor then
        return ub
    end
    for i, child in ipairs(PlacementAnchor:GetChildren()) do
        local ua_1 = child:IsA("Attachment") and string.find(child.Name, "Incubator", 1, true)
        if ua_1 then
            ub[#ub + 1] = child
        end
    end
    table.sort(ub, function(fJ, fK)
        return fJ.Name < fK.Name
    end)
    return ub
end
local function onToolSelection(ib)
    nT = ib
end
local function fn1087()
    if not fireproximityprompt then
        return
    end
    local tW = workspace:FindFirstChild(SHARED_EventTokenConfig.LiveTokensFolderName)
    if not tW then
        return
    end
    local Character = pq.Character
    local tY = Character and Character:FindFirstChild("HumanoidRootPart")
    if not tY then
        return
    end
    local CFrame2 = tY.CFrame
    local tZ = false
    for i, v in ipairs(oA(tW)) do
        if oQ.Unloaded then
            break
        end
        local Parent = v.Parent
        if Parent and Parent.Parent then
            tY.CFrame = Parent.CFrame * CFrame.new(0, 3, 0)
            tZ = true
            task.wait(nV("TokenActionDelay", 0.3))
            pcall(fireproximityprompt, v, v.HoldDuration)
            if og("TokenNotify") then
                oQ:Notify("Collected a Bee Coin")
            end
            task.wait(nV("TokenActionDelay", 0.3))
        end
    end
    local tW_2 = tZ and og("TokenReturn")
    if tW_2 then
        tY.CFrame = CFrame2
    end
end
local function onEggSelection(ig)
    pA = ig
end
local function fn1117()
    return oV.getReplicaByUserId(pq.UserId)
end
nK = nil
nL = nil
nM = nil
nN = nil
SHARED_EventTokenConfig = nil
nP = nil
connection2 = nil
nR = nil
nS = nil
nT = nil
nU = nil
nV = nil
nW = nil
nX = nil
nY = nil
nZ = nil
n_ = nil
n0 = nil
n1 = nil
n2 = nil
n3 = nil
SHARED_ToolConfig = nil
n5 = nil
n6 = nil
n7 = nil
n8 = nil
n9 = nil
oa = nil
ob = nil
connection = nil
od = nil
SHARED_LumberjackConfig = nil
of = nil
og = nil
oh = nil
oi = nil
oj = nil
ol = nil
om = nil
oo = nil
op = nil
oq = nil
Toggles = nil
ou = nil
ov = nil
ow = nil
ox = nil
SHARED_TreeConfig = nil
oz = nil
oA = nil
oB = nil
SHARED_ItemConstants = nil
oD = nil
oE = nil
oF = nil
oG = nil
CLIENT_InventoryUIController = nil
oI = nil
oJ = nil
oK = nil
oL = nil
Label7 = nil
oN = nil
CLIENT_BaseController = nil
Label6 = nil
oQ = nil
oR = nil
connection3 = nil
oT = nil
oU = nil
oV = nil
Label5 = nil
oX = nil
oY = nil
oZ = nil
Knit = nil
Label4 = nil
o2 = nil
o3 = nil
o4 = nil
o5 = nil
o6 = nil
o7 = nil
Label3 = nil
o9 = nil
Label2 = nil
SHARED_RebirthUtils = nil
pc = nil
pd = nil
pe = nil
SHARED_RebirthConfig = nil
pg = nil
pi = nil
pj = nil
pk = nil
pl = nil
pm = nil
pn = nil
local SHARED_LuckySpinUtils, ph
po = nil
pp = nil
pq = nil
pr = nil
ps = nil
pt = nil
pu = nil
Label = nil
pw = nil
px = nil
SHARED_PlacementTransform = nil
pz = nil
pA = nil
pB = nil
pC = nil
pD = nil
pE = nil
wp_44, wp_27, pw, pq = nil, nil, nil, nil
local wp_6 = 3
repeat
    local xo = bit32.rrotate(bit32.bxor(bit32.lrotate(wp_6, 20), string.byte(tostring(pq))), 17)
    if bit32.bxor(bit32.lrotate(bit32.bxor(xo, 3554631191), 28), 2101212641) == bit32.lrotate(xo, 28) then
        wp_24 = game:GetService("Players")
        wp_44 = game:GetService("ReplicatedStorage")
        wp_27 = game:GetService("UserInputService")
        pw = game:GetService("VirtualUser")
        pq = wp_24.LocalPlayer
    else
        wp_44 = game:GetService("Players")
        pq = game:GetService("ReplicatedStorage")
        game:GetService("UserInputService")
        wp_27 = game:GetService("VirtualUser")
        pw = wp_44.LocalPlayer
    end
    wp_6 = (wp_6 + 3) % 4
until (wp_6 * 3 + 2) % 4 == 0
if getgenv then
    getgenv().gethui = function()
        return pq:WaitForChild("PlayerGui")
    end
end
wp_39, wp_33, wp_49, Knit, oV, CLIENT_BaseController, oK, CLIENT_InventoryUIController, SHARED_ItemConstants, SHARED_TreeConfig, wp_47, oj, SHARED_LumberjackConfig, wp_9, n9, SHARED_ToolConfig, wp_24, nU, SHARED_EventTokenConfig, nL, wp_15, pC, SHARED_PlacementTransform, ps, pk, SHARED_RebirthConfig, SHARED_RebirthUtils, wp_52, SHARED_LuckySpinUtils, wp_12, oQ, wp_18, wp_36, Toggles, ol, pt, pl, om, oh, od, ob, n7, o5, oY, oT, ov, op, oi, nX, nS, nM, pp, pi, pd, wp_1, o7, oZ, og, nV, pg, o3, oN, n1, pD, pm, o4, wp_30 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
wp_6 = 111
repeat
    wp_20 = (wp_6 * 29 + 27) % 30 + 1
    if wp_20 <= 15 then
        if wp_20 <= 8 then
            if wp_20 <= 4 then
                if wp_20 <= 2 then
                    if wp_20 <= 1 then
                        wp_3 = {
                            "esaoqm",
                            "bqtkzgmyqr",
                            "fdydyy",
                            "qqafezclhzj",
                            "flhpfhzsaqo",
                            "pmhndp",
                            "nqxsggybjgz",
                            "opsrsmpcxas",
                            "ofqizr",
                            "emnjvdxotg",
                            "ognsdeghqq",
                            "eir"
                        }
                        local w6 = wp_6
                        wp_41 = wp_3[w6 % 12 + 1]
                        if wp_41:len() <= wp_41:reverse():rep(w6 % 3 + 2):len() then
                            pg = fn940
                            o3 = fns.fn584
                            oN = fns.fn629
                        else
                            oN = fn940
                            pg = fns.fn584
                            o3 = fns.fn629
                        end
                        wp_6 = (wp_6 + 179) % 240
                    else
                        wp_3 = (vector.create((wp_6 * 6 + 6) % 11 + 1, (wp_6 * 10 + 10) % 13 + 1, (wp_6 * 8 + 9) % 17 + 1))
                        local xx = vector.floor(wp_3) + vector.ceil(wp_3 * -1)
                        if vector.dot(xx, xx) == 3 then
                            oh = "#7fd47f"
                            om = "#6ec1ff"
                        else
                            om = "#7fd47f"
                            oh = "#6ec1ff"
                        end
                        wp_6 = (wp_6 + 59) % 240
                    end
                elseif wp_20 <= 3 then
                    if wp_6 * 132603557 + 2 + 4 >= wp_6 * 132603557 + 2 + 4 + 6 then
                        n1 = "#e8a34d"
                        n7 = "#8b93a3"
                        od = { "Qi", "M", "K", "B", "Sp", "Qa", "T", "Sx" }
                        ob = fn869
                    else
                        od = "#e8a34d"
                        ob = "#8b93a3"
                        n7 = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp" }
                        n1 = fn869
                    end
                    wp_6 = (wp_6 + 29) % 240
                else
                    wp_3 = {
                        "ugek",
                        "dcnfkvvat",
                        "msuw",
                        "mjlz",
                        "ebxidffsbyi",
                        "npcs",
                        "bxrdpl",
                        "zpc",
                        "urg",
                        "rfphvchr",
                        "dbyihmiwqunl",
                        "xldtfo"
                    }
                    if wp_3[(wp_6 * 19 + 83) % 12 + 1] <= wp_3[(wp_6 * 19 + 83) % 12 + 1] then
                        pD = fn1117
                        pm = fns.fn493
                        o4 = fns.fn756
                    else
                        o4 = fn1117
                        pD = fns.fn493
                        pm = fns.fn756
                    end
                    wp_6 = (wp_6 + 89) % 240
                end
            elseif wp_20 <= 6 then
                if wp_20 <= 5 then
                    local xe = bit32.rrotate(bit32.bxor(bit32.lrotate(wp_6, 13), string.byte(tostring(oi))), 11)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(xe, 3790789935), 109407618), (bit32.bxor(bit32.band(xe, 504177360), 730960948))), 109407618), 730960948) == xe then
                        wp_30 = fns.fn376
                        o5, oY, oT = wp_30(wp_47.Stock, fns.fn549, "CashPrice")
                        ov, op, oi = wp_30(wp_9.Stock, fns.fn3, "CashPrice")
                        nX, nS, nM = wp_30(wp_24.Stock, fns.fn108, "CashPrice")
                        pp, pi, pd = wp_30(wp_15.Stock, fn1030, "GemsPrice")
                    else
                        pd = fns.fn376
                        nM, pi, wp_15 = pd(wp_30.Stock, fns.fn549, "CashPrice")
                        wp_9, oi, oY = pd(pp.Stock, fns.fn3, "CashPrice")
                        nS, nX, ov = pd(oT.Stock, fns.fn108, "CashPrice")
                        wp_24, op, wp_47 = pd(o5.Stock, fn1030, "GemsPrice")
                    end
                    wp_6 = (wp_6 + 149) % 240
                else
                    wp_3 = (vector.create((wp_6 * 4 + 4) % 11 + 1, (wp_6 * 4 + 8) % 13 + 1, (wp_6 * 3 + 13) % 17 + 1))
                    wp_41 = (vector.create((wp_6 * 4 + 6) % 11 + 1, (wp_6 * 5 + 8) % 13 + 1, (wp_6 * 5 + 9) % 17 + 1))
                    local xm = vector.dot(wp_3, wp_41)
                    if xm * xm <= vector.dot(wp_3, wp_3) * vector.dot(wp_41, wp_41) then
                        wp_1 = {}
                        o7 = {}
                        oZ = {}
                    else
                        oZ = {}
                        wp_1 = {}
                        o7 = {}
                    end
                    wp_6 = (wp_6 + 209) % 240
                end
            elseif wp_20 <= 7 then
                wp_3 = (vector.create((wp_6 * 7 + 8) % 11 + 1, (wp_6 * 1 + 4) % 13 + 1, (wp_6 * 15 + 16) % 17 + 1))
                wp_41 = (vector.create((wp_6 * 5 + 6) % 11 + 1, (wp_6 * 2 + 12) % 13 + 1, (wp_6 * 2 + 10) % 17 + 1))
                wp_22 = (vector.create((wp_6 * 1 + 1) % 11 + 1, (wp_6 * 6 + 9) % 13 + 1, (wp_6 * 15 + 17) % 17 + 1))
                if vector.dot(vector.cross(wp_3, wp_41), wp_22) == vector.dot(vector.cross(wp_41, wp_22), wp_3) + 2 then
                    oV = "Your Lumber Farm"
                else
                    wp_39 = "Your Lumber Farm"
                end
                wp_6 = (wp_6 + 239) % 240
            else
                if (not n7 and not SHARED_ItemConstants or (not n7 or not n7) or not oY and pd and (n7 and n7) or SHARED_RebirthConfig and SHARED_RebirthConfig and (not oY and SHARED_ItemConstants) and (not SHARED_RebirthConfig or SHARED_ItemConstants or (pd or SHARED_ItemConstants))) and ((oY and pd or not oY and n7 or oY and not SHARED_RebirthConfig and (not n7 or not pd)) and ((not SHARED_RebirthConfig and not n7 or (not n7 or pd)) and ((nX or oY) and (n7 or nX)))) and not ((not n7 and not SHARED_ItemConstants or (not n7 or not n7) or not oY and pd and (n7 and n7) or SHARED_RebirthConfig and SHARED_RebirthConfig and (not oY and SHARED_ItemConstants) and (not SHARED_RebirthConfig or SHARED_ItemConstants or (pd or SHARED_ItemConstants))) and ((oY and pd or not oY and n7 or oY and not SHARED_RebirthConfig and (not n7 or not pd)) and ((not SHARED_RebirthConfig and not n7 or (not n7 or pd)) and ((nX or oY) and (n7 or nX))))) then
                    wp_44 = wp_33:WaitForChild("SharedSource")
                else
                    wp_33 = wp_44:WaitForChild("SharedSource")
                end
                wp_6 = (wp_6 + 89) % 240
            end
        elseif wp_20 <= 12 then
            if wp_20 <= 10 then
                if wp_20 <= 9 then
                    wp_3 = { "sdlgvoxoe", "tlqrujzn", "lnisvzwsxll", "rys", "biffdiinnh", "uhbofolom", "epowwop", "yciu" }
                    local xn = wp_6
                    wp_41 = wp_3[xn % 8 + 1]
                    if wp_41:len() >= wp_41:gsub("(.)", "%1%1", xn % 3 % 2 + 1):len() then
                        wp_44 = wp_49:WaitForChild("ClientSource")
                    else
                        wp_49 = wp_44:WaitForChild("ClientSource")
                    end
                    wp_6 = (wp_6 + 59) % 240
                else
                    wp_3 = { "qhr", "fast", "bfwon", "pnmp", "toht", "fiwezrcqt", "qayja", "dbk", "bmij", "hajjucuza" }
                    local xg = wp_6
                    wp_41 = wp_3[xg % 10 + 1]
                    if wp_41:len() <= wp_41:gsub("(.)", "%1%1", xg % 3 % 2 + 1):len() then
                        Knit = require(wp_44:WaitForChild("Packages"):WaitForChild("Knit"))
                    else
                        wp_44 = require(Knit:WaitForChild("Packages"):WaitForChild("Knit"))
                    end
                    wp_6 = (wp_6 + 59) % 240
                end
            elseif wp_20 <= 11 then
                if pi and pi and (o5 and wp_24) and (wp_24 or pi or ps and wp_24) or (o7 and not o7 or (not o7 or not wp_24)) and (o5 and ps or (pi or not o7)) or not (pi and pi and (o5 and wp_24) and (wp_24 or pi or ps and wp_24) or (o7 and not o7 or (not o7 or not wp_24)) and (o5 and ps or (pi or not o7))) then
                    oV = require(wp_49.PlayerData.CLIENT_PlayerDataController)
                    CLIENT_BaseController = require(wp_49.Base.CLIENT_BaseController)
                else
                    wp_49 = require(CLIENT_BaseController.PlayerData.CLIENT_PlayerDataController)
                    oV = require(CLIENT_BaseController.Base.CLIENT_BaseController)
                end
                wp_6 = (wp_6 + 119) % 240
            else
                wp_3 = {
                    "ooavt",
                    "jtycsbbfx",
                    "vktex",
                    "avbtutqxibb",
                    "ibss",
                    "rzbgluzvx",
                    "mwrgtz",
                    "nbs",
                    "acpktgnwlpl",
                    "mupfjeln",
                    "zksoex",
                    "eomfhjkys",
                    "djz",
                    "xmsx",
                    "nthzfmocvcu",
                    "aiiazvseq"
                }
                if wp_3[(wp_6 * 25 + 109) % 16 + 1] <= wp_3[(wp_6 * 25 + 109) % 16 + 1] then
                    oK = require(wp_49.Tool.CLIENT_ToolController)
                    CLIENT_InventoryUIController = require(wp_49.Inventory.CLIENT_InventoryUIController)
                else
                    wp_49 = require(CLIENT_InventoryUIController.Tool.CLIENT_ToolController)
                    oK = require(CLIENT_InventoryUIController.Inventory.CLIENT_InventoryUIController)
                end
                wp_6 = (wp_6 + 29) % 240
            end
        elseif wp_20 <= 14 then
            if wp_20 <= 13 then
                wp_3 = (vector.create((wp_6 * 4 + 1) % 11 + 1, (wp_6 * 3 + 6) % 13 + 1, (wp_6 * 11 + 16) % 17 + 1))
                wp_41 = (vector.create((wp_6 * 7 + 2) % 11 + 1, (wp_6 * 8 + 6) % 13 + 1, (wp_6 * 6 + 13) % 17 + 1))
                wp_22 = (vector.create((wp_6 * 7 + 7) % 11 + 1, (wp_6 * 8 + 2) % 13 + 1, (wp_6 * 10 + 2) % 17 + 1))
                wp_4 = (vector.create((wp_6 * 1 + 4) % 5 + 1, (wp_6 * 3 + 3) % 7 + 1, (wp_6 * 4 + 7) % 9 + 1))
                if vector.dot(vector.cross(wp_3, (vector.cross(wp_41, wp_22))), wp_4) == vector.dot(wp_41 * vector.dot(wp_3, wp_22) - wp_22 * vector.dot(wp_3, wp_41), wp_4) then
                    SHARED_ItemConstants = require(wp_33.Item.SHARED_ItemConstants)
                else
                    wp_33 = require(SHARED_ItemConstants.Item.SHARED_ItemConstants)
                end
                wp_6 = (wp_6 + 239) % 240
            else
                if wp_6 * 2678577 + 11 + 6 >= wp_6 * 2678577 + 11 + 6 + 3 then
                    wp_33 = require(SHARED_TreeConfig.Tree.SHARED_TreeConfig)
                else
                    SHARED_TreeConfig = require(wp_33.Tree.SHARED_TreeConfig)
                end
                wp_6 = (wp_6 + 149) % 240
            end
        else
            wp_3 = {
                "aaeqsya",
                "qgbcy",
                "jilw",
                "beapwzbqadj",
                "wtnmrd",
                "hcksdpcjvfg",
                "kvtsqfpi",
                "ebjsmngxo",
                "kfplmne",
                "sacvkfwei",
                "drdkgrlmhbe",
                "vpuphb"
            }
            local w3 = wp_6
            wp_41 = wp_3[w3 % 12 + 1]
            if wp_41:len() <= wp_41:reverse():rep(w3 % 3 + 2):len() then
                wp_47 = require(wp_33.Tree.SHARED_TreeStockConfig)
            else
                wp_33 = require(wp_47.Tree.SHARED_TreeStockConfig)
            end
            wp_6 = (wp_6 + 59) % 240
        end
    elseif wp_20 <= 23 then
        if wp_20 <= 19 then
            if wp_20 <= 17 then
                if wp_20 <= 16 then
                    local wX = bit32.rrotate(bit32.bxor(bit32.lrotate(wp_6, 13), string.byte(tostring(o3))), 9)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(wX, 46765633), 1391250659), (bit32.bxor(bit32.band(wX, 4248201662), 2563061066))), 1391250659), 2563061066) == wX then
                        oj = require(wp_33.Tree.SHARED_TreeModelUtils)
                        SHARED_LumberjackConfig = require(wp_33.Lumberjack.SHARED_LumberjackConfig)
                    else
                        wp_33 = require(SHARED_LumberjackConfig.Tree.SHARED_TreeModelUtils)
                        oj = require(SHARED_LumberjackConfig.Lumberjack.SHARED_LumberjackConfig)
                    end
                    wp_6 = (wp_6 + 179) % 240
                else
                    wp_3 = (vector.create((wp_6 * 6 + 9) % 11 + 1, (wp_6 * 6 + 8) % 13 + 1, (wp_6 * 3 + 13) % 17 + 1))
                    wp_41 = (vector.create((wp_6 * 5 + 1) % 11 + 1, (wp_6 * 10 + 8) % 13 + 1, (wp_6 * 3 + 4) % 17 + 1))
                    wp_22 = (vector.create((wp_6 * 2 + 3) % 11 + 1, (wp_6 * 3 + 7) % 13 + 1, (wp_6 * 2 + 14) % 17 + 1))
                    wp_4 = (vector.create((wp_6 * 3 + 4) % 11 + 1, (wp_6 * 8 + 13) % 13 + 1, (wp_6 * 12 + 5) % 17 + 1))
                    if vector.dot(vector.cross(wp_3, wp_41), (vector.cross(wp_22, wp_4))) == vector.dot(wp_3, wp_22) * vector.dot(wp_41, wp_4) - vector.dot(wp_3, wp_4) * vector.dot(wp_41, wp_22) then
                        wp_9 = require(wp_33.Lumberjack.SHARED_LumberjackStockConfig)
                    else
                        wp_33 = require(wp_9.Lumberjack.SHARED_LumberjackStockConfig)
                    end
                    wp_6 = (wp_6 + 179) % 240
                end
            elseif wp_20 <= 18 then
                wp_3 = (vector.create((wp_6 * 2 + 8) % 11 + 1, (wp_6 * 5 + 11) % 13 + 1, (wp_6 * 8 + 13) % 17 + 1))
                wp_41 = (vector.create((wp_6 * 7 + 5) % 11 + 1, (wp_6 * 10 + 12) % 13 + 1, (wp_6 * 1 + 11) % 17 + 1))
                local wU = vector.cross(wp_3, wp_41)
                local wV = vector.dot(wp_3, wp_41)
                if vector.dot(wU, wU) + wV * wV == vector.dot(wp_3, wp_3) * vector.dot(wp_41, wp_41) + 2 then
                    wp_33 = require(SHARED_ToolConfig.Lumberjack.SHARED_LumberjackUpgradeConstants)
                    n9 = require(SHARED_ToolConfig.Tool.SHARED_ToolConfig)
                else
                    n9 = require(wp_33.Lumberjack.SHARED_LumberjackUpgradeConstants)
                    SHARED_ToolConfig = require(wp_33.Tool.SHARED_ToolConfig)
                end
                wp_6 = (wp_6 + 29) % 240
            else
                if wp_6 * 13080597 + 7 + 4 >= wp_6 * 13080597 + 7 + 4 + 6 then
                    wp_33 = require(wp_24.Tool.SHARED_ToolStockConfig)
                else
                    wp_24 = require(wp_33.Tool.SHARED_ToolStockConfig)
                end
                wp_6 = (wp_6 + 209) % 240
            end
        elseif wp_20 <= 21 then
            if wp_20 <= 20 then
                if wp_6 * 121455979 + 13 + 6 >= wp_6 * 121455979 + 13 + 6 + 6 then
                    wp_33 = require(SHARED_EventTokenConfig.Pet.SHARED_PetConfig)
                    nL = require(SHARED_EventTokenConfig.EventToken.SHARED_EventTokenConfig)
                    nU = require(SHARED_EventTokenConfig.Egg.SHARED_EggConfig)
                else
                    nU = require(wp_33.Pet.SHARED_PetConfig)
                    SHARED_EventTokenConfig = require(wp_33.EventToken.SHARED_EventTokenConfig)
                    nL = require(wp_33.Egg.SHARED_EggConfig)
                end
                wp_6 = (wp_6 + 179) % 240
            else
                wp_3 = (vector.create((wp_6 * 2 + 2) % 11 + 1, (wp_6 * 11 + 3) % 13 + 1, (wp_6 * 15 + 15) % 17 + 1))
                wp_41 = (vector.create((wp_6 * 6 + 2) % 11 + 1, (wp_6 * 5 + 13) % 13 + 1, (wp_6 * 3 + 8) % 17 + 1))
                wp_22 = (vector.create((wp_6 * 6 + 2) % 11 + 1, (wp_6 * 11 + 7) % 13 + 1, (wp_6 * 8 + 10) % 17 + 1))
                wp_4 = (vector.create((wp_6 * 2 + 1) % 11 + 1, (wp_6 * 1 + 3) % 13 + 1, (wp_6 * 6 + 11) % 17 + 1))
                if vector.dot(vector.cross(wp_3, wp_41), (vector.cross(wp_22, wp_4))) == vector.dot(wp_3, wp_22) * vector.dot(wp_41, wp_4) - vector.dot(wp_3, wp_4) * vector.dot(wp_41, wp_22) + 3 then
                    wp_33 = require(wp_15.Egg.SHARED_EggStockConfig)
                else
                    wp_15 = require(wp_33.Egg.SHARED_EggStockConfig)
                end
                wp_6 = (wp_6 + 149) % 240
            end
        elseif wp_20 <= 22 then
            if wp_6 * 94268201 + 7 + 1 <= wp_6 * 94268201 + 7 + 1 + 1 then
                pC = require(wp_33.Pet.SHARED_PetUpgradeConstants)
                SHARED_PlacementTransform = require(wp_33.Placement.SHARED_PlacementTransform)
            else
                wp_33 = require(SHARED_PlacementTransform.Pet.SHARED_PetUpgradeConstants)
                pC = require(SHARED_PlacementTransform.Placement.SHARED_PlacementTransform)
            end
            wp_6 = (wp_6 + 29) % 240
        else
            wp_3 = (vector.create((wp_6 * 5 + 8) % 11 + 1, (wp_6 * 5 + 8) % 13 + 1, (wp_6 * 3 + 15) % 17 + 1))
            wp_41 = (vector.create((wp_6 * 3 + 8) % 11 + 1, (wp_6 * 8 + 5) % 13 + 1, (wp_6 * 9 + 17) % 17 + 1))
            wp_22 = (vector.create((wp_6 * 5 + 4) % 11 + 1, (wp_6 * 8 + 12) % 13 + 1, (wp_6 * 11 + 12) % 17 + 1))
            wp_4 = (vector.create((wp_6 * 1 + 2) % 5 + 1, (wp_6 * 2 + 6) % 7 + 1, (wp_6 * 2 + 3) % 9 + 1))
            if vector.dot(vector.cross(wp_3, (vector.cross(wp_41, wp_22))), wp_4) == vector.dot(wp_41 * vector.dot(wp_3, wp_22) - wp_22 * vector.dot(wp_3, wp_41), wp_4) + 5 then
                pk = require(SHARED_RebirthConfig.Placement.SHARED_PlacementValidation)
                wp_33 = require(SHARED_RebirthConfig.Placement.SHARED_FarmExpandConstants)
                ps = require(SHARED_RebirthConfig.Rebirth.SHARED_RebirthConfig)
            else
                ps = require(wp_33.Placement.SHARED_PlacementValidation)
                pk = require(wp_33.Placement.SHARED_FarmExpandConstants)
                SHARED_RebirthConfig = require(wp_33.Rebirth.SHARED_RebirthConfig)
            end
            wp_6 = (wp_6 + 209) % 240
        end
    elseif wp_20 <= 27 then
        if wp_20 <= 25 then
            if wp_20 <= 24 then
                if wp_6 * 101430905 + 8 + 1 >= wp_6 * 101430905 + 8 + 1 + 2 then
                    wp_33 = require(SHARED_RebirthUtils.Rebirth.SHARED_RebirthUtils)
                else
                    SHARED_RebirthUtils = require(wp_33.Rebirth.SHARED_RebirthUtils)
                end
                wp_6 = (wp_6 + 89) % 240
            else
                if wp_6 * 115602299 + 4 + 2 <= wp_6 * 115602299 + 4 + 2 + 3 then
                    wp_52 = require(wp_33.Event.SHARED_EventPacksGlobalData)
                else
                    wp_33 = require(wp_52.Event.SHARED_EventPacksGlobalData)
                end
                wp_6 = (wp_6 + 89) % 240
            end
        elseif wp_20 <= 26 then
            wp_3 = {
                "fjqg",
                "khmzge",
                "isqnxv",
                "ufllukyhvk",
                "nujfkuby",
                "isplo",
                "vmbgeddljjny",
                "ztgej",
                "beigqxr",
                "jsgjym",
                "cro"
            }
            if wp_3[(wp_6 * 22 + 43) % 11 + 1] < wp_3[(wp_6 * 22 + 43) % 11 + 1] then
                wp_33 = require(SHARED_LuckySpinUtils.LuckySpin.SHARED_LuckySpinUtils)
            else
                SHARED_LuckySpinUtils = require(wp_33.LuckySpin.SHARED_LuckySpinUtils)
            end
            wp_6 = (wp_6 + 209) % 240
        else
            wp_3 = (vector.create((wp_6 * 6 + 7) % 11 + 1, (wp_6 * 2 + 13) % 13 + 1, (wp_6 * 7 + 13) % 17 + 1))
            wp_41 = (vector.create((wp_6 * 6 + 8) % 11 + 1, (wp_6 * 6 + 12) % 13 + 1, (wp_6 * 14 + 13) % 17 + 1))
            local w9 = vector.dot(wp_3, wp_41)
            if w9 * w9 <= vector.dot(wp_3, wp_3) * vector.dot(wp_41, wp_41) then
                wp_12 = ""
            else
                pd = ""
            end
            wp_6 = (wp_6 + 29) % 240
        end
    elseif wp_20 <= 29 then
        if wp_20 <= 28 then
            wp_20 = {
                "vzl",
                "lrkrorqc",
                "eqrs",
                "eplika",
                "qphs",
                "czwktopjlc",
                "xcptcnmhy",
                "bsmenbemsct",
                "ltyeu",
                "guxvczdaoe",
                "imnitnnpjgx"
            }
            local xr = wp_6
            wp_3 = wp_20[xr % 11 + 1]
            if wp_3:len() <= wp_3:gsub("(.)", "%1%1", xr % 3 % 2 + 1):len() then
                oQ = getgenv().Library
                pcall(fns.fn249)
                wp_18 = getgenv().ThemeManager
                wp_36 = getgenv().SaveManager
                Toggles = oQ.Toggles
                ol = oQ.Options
            else
                wp_36 = getgenv().Library
                pcall(fns.fn249)
                oQ = getgenv().ThemeManager
                ol = getgenv().SaveManager
                wp_18 = wp_36.Toggles
                wp_12 = wp_36.Options
            end
            wp_6 = (wp_6 + 89) % 240
        else
            wp_20 = (vector.create((wp_6 * 5 + 7) % 11 + 1, (wp_6 * 8 + 9) % 13 + 1, (wp_6 * 4 + 12) % 17 + 1))
            local wW = vector.floor(wp_20) + vector.ceil(wp_20 * -1)
            if vector.dot(wW, wW) == 0 then
                og = fns.fn814
                nV = fns.fn725
                pt = "https://discord.gg/K7Qxnxkk46"
            else
                pt = fns.fn814
                og = fns.fn725
                nV = "https://discord.gg/K7Qxnxkk46"
            end
            wp_6 = (wp_6 + 119) % 240
        end
    else
        local xh = bit32.rrotate(bit32.bxor(bit32.lrotate(wp_6, 26), string.byte(tostring(wp_33))), 12)
        if bit32.bxor(bit32.lrotate(bit32.bxor(xh, 1193542240), 30), 298385560) ~= bit32.lrotate(xh, 30) then
            om = "https://discord.gg/K7Qxnxkk46"
        else
            pl = "https://discord.gg/K7Qxnxkk46"
        end
        wp_6 = (wp_6 + 59) % 240
    end
until (wp_6 * 119 + 231) % 240 == 0
for k, v in pairs(wp_52.Packs) do
    if v.Active then
        wp_24 = v.DisplayName or k
        wp_6 = wp_24
        wp_1[#wp_1 + 1] = wp_6
        o7[wp_6] = k
        wp_24 = v.SpinCost or 0
        oZ[k] = wp_24
    end
end
oG, oB, ox, oq, wp_44 = nil, nil, nil, nil, nil
wp_6 = 0
while true do
    do
        local xj = bit32.rrotate(bit32.bxor(bit32.lrotate(wp_6, 7), string.byte(tostring(oq))), 17)
        if bit32.bxor(bit32.lrotate(bit32.bxor(xj, 2308898404), 0), 2308898404) ~= bit32.lrotate(xj, 0) then
            table.sort(ox)
            wp_1 = { "Worker Speed", "Worker Limit", "Worker Power" }
            wp_44 = { ["Worker Speed"] = "Speed", ["Worker Power"] = "Power", ["Worker Limit"] = "Limit" }
            oq = { "Pet Power", "Pet Limit", "Pet Speed" }
            oG = { ["Pet Speed"] = "Speed", ["Pet Limit"] = "Limit", ["Pet Power"] = "Power" }
            oB = {}
        else
            table.sort(wp_1)
            oG = { "Worker Limit", "Worker Power", "Worker Speed" }
            oB = { ["Worker Limit"] = "Limit", ["Worker Power"] = "Power", ["Worker Speed"] = "Speed" }
            ox = { "Pet Limit", "Pet Power", "Pet Speed" }
            oq = { ["Pet Limit"] = "Limit", ["Pet Power"] = "Power", ["Pet Speed"] = "Speed" }
            wp_44 = {}
        end
        wp_6 = (wp_6 + 1) % 8
        if (wp_6 * 3 + 0) % 8 == 3 then
            break
        end
        continue
    end
end
for k in pairs(SHARED_ItemConstants.ItemRarities) do
    wp_44[#wp_44 + 1] = k
end
nZ, nT, nN, nK, pE, pA, px, pr, ph, wp_47, pj, oL, oz, pz, oX, oo, nR, pc, n2, o6, ow, n_, pe, oa, n0, nP, n6, pu, oE, oA, n8, oF, nY, oJ, pB, of, n5, oR, ou, nW, pn = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
table.sort(wp_44, fns.fn501)
nZ = {}
nT = {}
nN = {}
nK = {}
pE = {}
pA = {}
px = {}
pr = {}
pj = fns.fn82
oL = fns.fn166
oz = fns.fn7
pz = fns.fn226
oX = fns.fn369
oo = fns.fn302
nR = fns.fn640
ph = {
    { key = "TreeStock", service = "TreeStockService" },
    { key = "LumberjackStock", service = "LumberjackStockService" },
    { key = "EggStock", service = "EggStockService" },
    { key = "ToolStock", service = "ToolStockService" }
}
pc = function()
    local r_ = pm()
    if not r_ then
        return
    end
    local r0 = workspace:GetServerTimeNow()
    for i, v in ipairs(ph) do
        local r9 = v
        if oQ.Unloaded then
            return
        end
        local r1 = r_[r9.key]
        local r2 = r1 and r1.RefreshAtTimestamp
        local r1_1 = r2
        if r2 then
            r2 = r0 >= r1_1
        end
        if r2 then
            pcall(function()
                Knit.GetService(r9.service):RequestRefresh()
            end)
            task.wait(0.2)
        end
    end
end
n2 = fn1000
o6 = fn928
ow = fns.fn818
n_ = fns.fn433
pe = fns.fn12
oa = fns.fn309
n0 = fns.fn130
nP = fn1061
n6 = fns.fn89
pu = fns.fn363
oE = fns.fn825
oA = fn1032
if (not wp_47 and not wp_47 or (o6 or o6) or (not ow and not ow or not ow and wp_47)) and not (not wp_47 and not wp_47 or (o6 or o6) or (not ow and not ow or not ow and wp_47)) then
    oJ = fn1087
    nY = fn1068
    n8 = fns.fn124
    pB = fns.fn439
    oF = fns.fn42
else
    n8 = fn1087
    oF = fn1068
    nY = fns.fn124
    oJ = fns.fn439
    pB = fns.fn42
end
of = fn937
n5 = fns.fn362
oR = fn1047
ou = fn839
nW = fns.fn360
pn = fns.fn432
wp_24 = oQ:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = pt, Copyable = true }, "|", wp_39 },
    Icon = 12645376577,
    NotifySide = "Right",
    Size = UDim2.fromOffset(900, 640),
    ShowCustomCursor = false,
    CornerRadius = 10
})
oQ.ShowCustomCursor = false
wp_47 = {
    Info = wp_24:AddTab("Info", "info"),
    Shop = wp_24:AddTab("Shop", "shopping-cart"),
    Place = wp_24:AddTab("Place", "trees"),
    Eggs = wp_24:AddTab("Eggs", "egg"),
    Event = wp_24:AddTab("Event", "coins"),
    Upgrades = wp_24:AddTab("Upgrades", "trending-up"),
    Settings = wp_24:AddTab("Settings", "settings")
}
wp_9 = fns.fn65
for k, v in wp_47 do
    wp_9(v)
end
n3, wp_6, wp_12, Label, po, wp_30 = nil, nil, nil, nil, nil, nil
wp_24 = 10
repeat
    wp_9 = (wp_24 * 2 + 0) % 3 + 1
    if wp_9 <= 2 then
        if wp_9 <= 1 then
            wp_9 = {
                "eitcaykypyt",
                "jyqctahoyz",
                "zwxyexyxc",
                "ijrlay",
                "rheb",
                "gsvtshv",
                "lmxgqgcueyy",
                "fjhk",
                "eysbsqiuayc",
                "armu",
                "cbttgghgg",
                "zmjw"
            }
            local xq = wp_24
            wp_49 = wp_9[xq % 12 + 1]
            if wp_49:len() <= wp_49:reverse():rep(xq % 3 + 2):len() then
                po = tostring(game.JobId)
            else
                wp_12 = tostring(game.JobId)
            end
            wp_24 = (wp_24 + 20) % 24
        else
            if wp_24 * 99822221 + 7 + 3 >= wp_24 * 99822221 + 7 + 3 + 1 then
                po = #wp_30 > 18
            else
                wp_30 = #po > 18
            end
            wp_24 = (wp_24 + 20) % 24
        end
    else
        wp_9 = {
            "nkvawxtvcqt",
            "oxtvtel",
            "rvrb",
            "jnutklk",
            "bmabptislwl",
            "wixw",
            "yclmxqsobxzu",
            "wtuxsgp",
            "wmequj",
            "spqssxlej",
            "rzkjvrzvpn",
            "ytofggqb",
            "qjqnoleqiqny",
            "krq",
            "ijh"
        }
        if wp_9[(wp_24 * 81 + 28) % 15 + 1] <= wp_9[(wp_24 * 81 + 28) % 15 + 1] then
            n3 = "Unknown"
            pcall(fns.fn314)
            wp_6 = wp_47.Info:AddLeftGroupbox("Account", "circle-user")
            wp_6:AddLabel(oN("User", pq.Name, om), true)
            wp_6:AddLabel(oN("Status", "Keyless", om), true)
            wp_6:AddLabel(oN("Executor", n3, om), true)
            wp_12 = wp_47.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            wp_12:AddLabel(o3(wp_39 .. " [" .. tostring(game.PlaceId) .. "]", oh), true)
            wp_12:AddLabel(oN("Place ID", tostring(game.PlaceId), oh), true)
            Label = wp_12:AddLabel(oN("Session time", "0s", od), true)
        else
            om = "Unknown"
            pcall(fns.fn314)
            od = wp_6.Info:AddLeftGroupbox("Account", "circle-user")
            od:AddLabel(oh("User", oN.Name, Label), true)
            od:AddLabel(oh("Status", "Keyless", Label), true)
            od:AddLabel(oh("Executor", om, Label), true)
            wp_39 = wp_6.Info:AddLeftGroupbox("Game Info", "gamepad-2")
            wp_39:AddLabel(wp_12(wp_47 .. " [" .. tostring(game.PlaceId) .. "]", o3), true)
            wp_39:AddLabel(oh("Place ID", tostring(game.PlaceId), o3), true)
            pq = wp_39:AddLabel(oh("Session time", "0s", n3), true)
        end
        wp_24 = (wp_24 + 23) % 24
    end
until (wp_24 * 17 + 18) % 24 == 11
if wp_30 then
    wp_24 = 0
    repeat
        wp_6 = {
            "zffw",
            "nzlxuwuazmox",
            "yyndnsviqi",
            "zqvoz",
            "qsiwkvtx",
            "uasj",
            "ldguhdzmpgm",
            "uursfs",
            "zpuwtaalubmj",
            "kwyfdtj",
            "vezczuiytjv",
            "wxaknz",
            "kqwhri",
            "tzhqsgsk",
            "mpl"
        }
        if wp_6[(wp_24 * 38 + 71) % 15 + 1] < wp_6[(wp_24 * 38 + 71) % 15 + 1] then
            po = string.sub(wp_30, 1, 18) .. "..."
        else
            wp_30 = string.sub(po, 1, 18) .. "..."
        end
        wp_24 = (wp_24 + 0) % 8
    until (wp_24 * 5 + 7) % 8 == 7
end
wp_24 = wp_30 or po
oU, RebirthUpgradesGroup, Label2, Label3, Label4, Label5, Label6, Label7, o9, o2, connection, connection2, connection3, oI, oD = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local wp_28 = wp_24
wp_12:AddLabel(oN("Server", wp_28, ob), true)
wp_12:AddButton({ Text = "Copy join script (Job ID)", Func = fns.onCopyJoinScript_JobID })
oU = os.clock()
task.spawn(fns.worker)
wp_20 = wp_47.Info:AddRightGroupbox("Scripts", "package")
wp_20:AddLabel(o3("Included in this hub", ob), true)
wp_20:AddLabel(o3(wp_39, oh), true)
wp_52 = wp_47.Info:AddRightGroupbox("Features", "list")
wp_52:AddLabel(o3("Auto Buy", oh), true)
wp_52:AddLabel(o3("Auto Place", om), true)
wp_52:AddLabel(o3("Auto Eggs", od), true)
wp_52:AddLabel(o3("Auto Upgrade", oh), true)
wp_52:AddLabel(o3("Auto Rebirth", ob), true)
wp_15 = wp_47.Info:AddRightGroupbox("Socials", "link")
wp_15:AddButton({ Text = "Discord", Func = pg })
wp_15:AddButton({ Text = "Rscripts", Func = fns.onRscripts })
wp_9 = wp_47.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
wp_9:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
wp_9:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
wp_9:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
wp_9:AddButton({ Text = "Copy Discord Invite", Func = pg })
wp_6 = wp_47.Info:AddRightGroupbox("FAQ", "circle-help")
wp_6:AddLabel("Where do I get a good config?", true)
wp_6:AddLabel("Join the Discord, the config channel has configs shared for every script.", true)
wp_6:AddLabel("How do I import / export configs?", true)
wp_6:AddLabel("Join the Discord, the guide is pinned and people share config links daily.", true)
wp_6:AddLabel("How do I report bugs?", true)
wp_6:AddLabel("Join the Discord and post it in the bugs channel.", true)
wp_6:AddLabel("How do I make suggestions?", true)
wp_6:AddLabel("Join the Discord and drop it in suggestions, most of them get added.", true)
wp_6:AddLabel("How do I get help or updates?", true)
wp_6:AddLabel("Join the Discord, updates and support are posted there first.", true)
local TreesGroup = wp_47.Shop:AddLeftGroupbox("Trees", "trees")
TreesGroup:AddToggle("AutoBuyTrees", { Text = "Auto Buy Trees", Default = false })
TreesGroup:AddToggle("BuyAllTrees", { Text = "Buy Every Tree", Default = false })
TreesGroup:AddDropdown("TreeSelection", {
    Text = "Trees",
    Values = o5,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {},
    Callback = onTreeSelection
})
TreesGroup:AddInput("TreeReserve", { Text = "Cash Reserve", Default = "0", Numeric = true, Finished = true })
TreesGroup:AddToggle("TreeNotify", { Text = "Notify On Purchase", Default = false })
local LumberjacksGroup = wp_47.Shop:AddLeftGroupbox("Lumberjacks", "axe")
LumberjacksGroup:AddToggle("AutoBuyLumberjacks", { Text = "Auto Buy Lumberjacks", Default = false })
LumberjacksGroup:AddToggle("BuyAllLumberjacks", { Text = "Buy Every Lumberjack", Default = false })
LumberjacksGroup:AddDropdown("LumberjackSelection", {
    Text = "Lumberjacks",
    Values = ov,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {},
    Callback = fns.onLumberjackSelection
})
LumberjacksGroup:AddInput("LumberjackReserve", { Text = "Cash Reserve", Default = "0", Numeric = true, Finished = true })
LumberjacksGroup:AddToggle("LumberjackNotify", { Text = "Notify On Purchase", Default = false })
local ToolsGroup = wp_47.Shop:AddLeftGroupbox("Tools", "wrench")
ToolsGroup:AddToggle("AutoBuyTools", { Text = "Auto Buy Tools", Default = false })
ToolsGroup:AddToggle("BuyAllTools", { Text = "Buy Every Tool", Default = false })
ToolsGroup:AddDropdown("ToolSelection", {
    Text = "Tools",
    Values = nX,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {},
    Callback = onToolSelection
})
ToolsGroup:AddInput("ToolReserve", { Text = "Cash Reserve", Default = "0", Numeric = true, Finished = true })
ToolsGroup:AddToggle("ToolNotify", { Text = "Notify On Purchase", Default = false })
local EggsGroup = wp_47.Shop:AddRightGroupbox("Eggs", "egg")
EggsGroup:AddToggle("AutoBuyEggs", { Text = "Auto Buy Eggs", Default = false })
EggsGroup:AddToggle("BuyAllEggs", { Text = "Buy Every Egg", Default = false })
EggsGroup:AddDropdown("EggSelection", {
    Text = "Eggs",
    Values = pp,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {},
    Callback = onEggSelection
})
EggsGroup:AddInput("EggReserve", { Text = "Gem Reserve", Default = "0", Numeric = true, Finished = true })
local RollsGroup = wp_47.Shop:AddRightGroupbox("Rolls", "dices")
RollsGroup:AddToggle("AutoRoll", { Text = "Auto Buy Rolls", Default = false })
RollsGroup:AddDropdown("RollPack", { Text = "Pack", Values = wp_1, Searchable = true, AllowNull = true, Default = wp_1[1] })
RollsGroup:AddInput("TokenReserve", { Text = "Token Reserve", Default = "0", Numeric = true, Finished = true })
RollsGroup:AddToggle("RollNotify", { Text = "Notify On Roll", Default = false })
local RestockGroup = wp_47.Shop:AddRightGroupbox("Restock", "refresh-cw")
RestockGroup:AddToggle("AutoRestock", { Text = "Auto Restock Shops", Default = false })
wp_4 = wp_47.Place:AddLeftGroupbox("Placement", "hammer")
wp_4:AddToggle("AutoPlaceTrees", { Text = "Auto Place Trees", Default = false })
wp_4:AddToggle("AutoPlaceLumberjacks", { Text = "Auto Place Lumberjacks", Default = false })
wp_4:AddToggle("AutoPlacePets", { Text = "Auto Place Pets", Default = false })
wp_4:AddSlider("PlacementStep", { Text = "Grid Step", Default = 2, Min = 1, Max = 12, Rounding = 0 })
wp_4:AddToggle("PlaceNotify", { Text = "Notify On Place", Default = false })
wp_22 = wp_47.Place:AddRightGroupbox("Pick Up Trees", "hand")
wp_22:AddToggle("AutoPickupTrees", { Text = "Auto Pick Up Trees", Default = false })
wp_22:AddDropdown("TreePickupRarities", {
    Text = "Rarities",
    Values = wp_44,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {},
    Callback = fns.onTreePickupRarities
})
wp_22:AddToggle("PickupNotify", { Text = "Notify On Pick Up", Default = false })
wp_3 = wp_47.Place:AddRightGroupbox("Replace Pets", "repeat")
wp_3:AddToggle("AutoReplacePets", { Text = "Auto Replace Pets", Default = false })
wp_3:AddDropdown("PetReplaceRarities", {
    Text = "Rarities",
    Values = wp_44,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {},
    Callback = fns.onPetReplaceRarities
})
wp_3:AddToggle("ReplaceNotify", { Text = "Notify On Replace", Default = false })
wp_33 = wp_47.Event:AddLeftGroupbox("Bee Coins", "coins")
wp_33:AddToggle("AutoCollectTokens", { Text = "Auto Collect Bee Coins", Default = false })
wp_33:AddToggle("TokenReturn", { Text = "Return To Start Position", Default = true })
wp_33:AddToggle("TokenNotify", { Text = "Notify On Collect", Default = false })
wp_49 = wp_47.Eggs:AddLeftGroupbox("Incubators", "egg")
wp_49:AddToggle("AutoIncubate", { Text = "Auto Incubate Eggs", Default = false })
wp_49:AddToggle("AutoCollectEggs", { Text = "Auto Pick Up Ready Eggs", Default = false })
wp_49:AddToggle("EggNotify", { Text = "Notify On Hatch", Default = false })
wp_30 = wp_47.Upgrades:AddLeftGroupbox("Plot Upgrades", "axe")
wp_30:AddToggle("AutoPlotUpgrades", { Text = "Auto Buy Plot Upgrades", Default = false })
wp_30:AddToggle("AllPlotUpgrades", { Text = "Buy Every Track", Default = false })
wp_30:AddDropdown("PlotUpgradeSelection", {
    Text = "Tracks",
    Values = oG,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {},
    Callback = fns.onPlotUpgradeSelection
})
wp_30:AddInput("UpgradeCashReserve", { Text = "Cash Reserve", Default = "0", Numeric = true, Finished = true })
local ExpandPlotGroup = wp_47.Upgrades:AddLeftGroupbox("Expand Plot", "land-plot")
if (not connection or oD or not Label6 and Label6 or (not connection and not connection or wp_49 and wp_49)) and not (not connection or oD or not Label6 and Label6 or (not connection and not connection or wp_49 and wp_49)) then
    RebirthUpgradesGroup:AddToggle("AutoExpandPlot", { Text = "Auto Expand Plot", Default = false })
    RebirthUpgradesGroup:AddInput("ExpandGemReserve", { Default = "0", Numeric = true, Finished = true, Text = "Gem Reserve" })
    wp_47 = ExpandPlotGroup.Upgrades:AddRightGroupbox("Rebirth Upgrades", "paw-print")
else
    ExpandPlotGroup:AddToggle("AutoExpandPlot", { Text = "Auto Expand Plot", Default = false })
    ExpandPlotGroup:AddInput("ExpandGemReserve", { Text = "Gem Reserve", Default = "0", Numeric = true, Finished = true })
    RebirthUpgradesGroup = wp_47.Upgrades:AddRightGroupbox("Rebirth Upgrades", "paw-print")
end
RebirthUpgradesGroup:AddToggle("AutoRebirthUpgrades", { Text = "Auto Buy Rebirth Upgrades", Default = false })
RebirthUpgradesGroup:AddToggle("AllRebirthUpgrades", { Text = "Buy Every Track", Default = false })
RebirthUpgradesGroup:AddDropdown("RebirthUpgradeSelection", {
    Text = "Tracks",
    Values = ox,
    Multi = true,
    Searchable = true,
    AllowNull = true,
    Default = {},
    Callback = fns.onRebirthUpgradeSelection
})
RebirthUpgradesGroup:AddInput("UpgradeGemReserve", { Text = "Gem Reserve", Default = "0", Numeric = true, Finished = true })
RebirthUpgradesGroup:AddToggle("UpgradeNotify", { Text = "Notify On Upgrade", Default = false })
local RebirthGroup = wp_47.Upgrades:AddRightGroupbox("Rebirth", "rotate-ccw")
RebirthGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
RebirthGroup:AddToggle("RebirthNotify", { Text = "Notify On Rebirth", Default = false })
local StatusGroup = wp_47.Upgrades:AddRightGroupbox("Status", "activity")
Label2 = StatusGroup:AddLabel(oN("Cash", "?", om), true)
Label3 = StatusGroup:AddLabel(oN("Gems", "?", oh), true)
Label4 = StatusGroup:AddLabel(oN("Event Tokens", "?", od), true)
Label5 = StatusGroup:AddLabel(oN("Rebirths", "?", ob), true)
Label6 = StatusGroup:AddLabel(oN("Next rebirth", "?", od), true)
Label7 = StatusGroup:AddLabel(oN("Plot level", "?", oh), true)
oI = fns.fn131
local DelaysGroup = wp_47.Settings:AddRightGroupbox("Delays", "timer")
DelaysGroup:AddSlider("TreeActionDelay", { Text = "Tree Buy Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
DelaysGroup:AddSlider("LumberjackActionDelay", { Text = "Lumberjack Buy Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
DelaysGroup:AddSlider("ToolActionDelay", { Text = "Tool Buy Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
DelaysGroup:AddSlider("PickupActionDelay", { Text = "Tree Pick Up Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
DelaysGroup:AddSlider("ReplaceActionDelay", { Text = "Pet Replace Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
DelaysGroup:AddSlider("TokenActionDelay", { Text = "Bee Coin Delay", Default = 0.3, Min = 0.05, Max = 2, Rounding = 2 })
DelaysGroup:AddSlider("TokenLoopDelay", { Text = "Bee Coin Loop Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 1 })
DelaysGroup:AddSlider("EggActionDelay", { Text = "Egg Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
DelaysGroup:AddSlider("PlaceActionDelay", { Text = "Place Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
DelaysGroup:AddSlider("UpgradeActionDelay", { Text = "Upgrade Delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2 })
DelaysGroup:AddSlider("ShopLoopDelay", { Text = "Shop Loop Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 1 })
DelaysGroup:AddSlider("PlaceLoopDelay", { Text = "Place Loop Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 1 })
DelaysGroup:AddSlider("EggLoopDelay", { Text = "Egg Loop Delay", Default = 3, Min = 0.5, Max = 30, Rounding = 1 })
DelaysGroup:AddSlider("UpgradeLoopDelay", { Text = "Upgrade Loop Delay", Default = 3, Min = 0.5, Max = 30, Rounding = 1 })
DelaysGroup:AddSlider("RollLoopDelay", { Text = "Roll Loop Delay", Default = 2, Min = 0.5, Max = 15, Rounding = 1 })
local MenuGroup = wp_47.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
o9 = tick()
o2 = tick()
pcall(function()
    for i, v in ipairs(getconnections(pq.Idled)) do
        local vS = v
        pcall(function()
            vS:Disable()
        end)
    end
end)
oD = fn844
connection = wp_27.InputBegan:Connect(fns.onInputBegan)
connection2 = wp_27.InputChanged:Connect(fns.onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton("Unload", fns.onUnload)
oQ.ToggleKeybind = ol.MenuKeybind
connection3 = Knit.GetService("UnboxingService").UnboxingResult:Connect(function(jg, jh)
    local vZ = type(jh) ~= "table" or type(jh.UnboxedItems) ~= "table"
    if vZ then
        return
    end
    local vY = Knit.GetService("UnboxingService")
    for i, v in ipairs(SHARED_LuckySpinUtils.flattenUnboxingItems(jh.UnboxedItems)) do
        local v5 = v
        if v5.ItemUniqueId then
            pcall(function()
                vY:RequestClaimUnboxingEscrow(v5.ItemUniqueId)
            end)
        end
    end
end)
oQ:OnUnload(fns.fn714)
wp_18:SetLibrary(oQ)
wp_18:SetFolder("TempoHub")
wp_18:SaveDefault("Monochrome")
wp_36:SetLibrary(oQ)
wp_36:IgnoreThemeSettings()
wp_36:SetIgnoreIndexes({ "MenuKeybind" })
wp_36:SetFolder("TempoHub/YourLumberFarm")
wp_36:BuildConfigSection(wp_47.Settings)
wp_18:ApplyToTab(wp_47.Settings)
wp_18:LoadDefault()
wp_36:LoadAutoloadConfig()
task.spawn(worker2)
task.spawn(fns.worker3)
task.spawn(fns.worker4)
task.spawn(fns.worker5)
task.spawn(fns.worker6)
task.spawn(fns.worker7)
task.spawn(fns.worker8)
task.spawn(fns.worker9)
oQ:Notify("Your Lumber Farm loaded")
end)(...)
