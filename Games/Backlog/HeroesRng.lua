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
getgenv().TempoHoodSubtitle = "HEROES RNG"
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
local Shared
local kW
local lD
local lk
local k1
local lJ
local Remotes
local lq
local k7
local kP
local Currency
local ld
local CFrame2
local lC
local lj
local k0
local lI
local kI
local lp
local k6
local kO
local lv
local connection
local kU
local lB
local Prestige
local k_
local lH
local kH
local lo
local PrestigeUpgrades
local Library
local lb
local Artifacts
local lA
local connection2
local Inventory
local lG
local Order
local Workspace
local k4
local kM
local lt
local la
local kS
local lg
local kY
local lF
local kF
local lm
local k3
local lL
local kL
local ls
local Heroes
local kR
local ly
local lf
local Zones2
local lE
local kE
local ll
local Upgrades
local lK
local kK
local lr
local k8
local connection3
local lx
local function worker2()
    while not Library.Unloaded do
        if lk then
            pcall(k3)
            task.wait(0.3)
        else
            task.wait(0.4)
        end
    end
end
local function worker9()
    while not Library.Unloaded do
        task.wait(5)
        if lF then
            pcall(ll)
        end
    end
end
local function fn16()
    local pq = kY("GetZoneUnlockState")
    if type(pq) ~= "table" then
        return
    end
    local pr = type(pq.unlocked) == "table" and pq.unlocked
    local pt = pr or {}
    local pt_4
    local ps_1 = type(pq.kills) == "table" and pq.kills
    local pt_1 = ps_1 or {}
    local ps_2 = lx()
    for i, v in ipairs(Order) do
        if not pt[v] then
            local pt_2 = Zones2.Get(v)
            local pu = not pt_2 or not pt_2.PreviousZone
            local pu_1
            if pu or pt[pt_2.PreviousZone] then
                pu_1, pt_4 = Zones2.GetUnlockCost(v)
                local pv_1 = Zones2.EvaluateRequirements(v, pt_1)
                local pw = pt_4 ~= "Gold"
                if not pw then
                    pw = ps_2 >= (pu_1 or 0)
                end
                if pv_1 and pw then
                    lm("RequestZoneUnlock", v)
                end
                return
            end
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        task.wait(1.5)
        if ld then
            pcall(kR)
        end
    end
end
local function fn29()
    local nK_1
    local nJ = Inventory and Inventory.GetBestOwnedDps
    local nJ_1
    if nJ then
        nJ_1, nK_1 = pcall(Inventory.GetBestOwnedDps)
        local nL = nJ_1 and tonumber(nK_1)
        if nL then
            return nK_1
        end
        return 0
    end
    return 0
end
local function fn43()
    local p1 = kY("GetPrestigeUpgrades")
    local p2 = {}
    local p3 = type(p1) == "table" and type(p1.upgrades) == "table"
    if p3 then
        for k, v in pairs(p1.upgrades) do
            p2[k] = v
        end
    end
    local p1_1 = kK()
    for i, v in ipairs(PrestigeUpgrades.Order()) do
        if PrestigeUpgrades.GetState(v, p2, p1_1) == "Affordable" then
            lm("PurchasePrestigeUpgrade", v)
            p2[v] = true
            local p3_1 = PrestigeUpgrades.GetCost(v) or 0
            p1_1 = p1_1 - p3_1
        end
    end
end
local function fn71(bZ)
    local nc = {}
    if type(bZ) == "table" then
        for k, v in pairs(bZ) do
            local nd = type(k) == "number" and type(v) == "string"
            if nd then
                nc[v] = true
            elseif v then
                nc[k] = true
            end
        end
    elseif type(bZ) == "string" then
        nc[bZ] = true
    end
    return nc
end
local function fn86(eh)
    local Zones = Workspace:FindFirstChild("Zones")
    local pI = Zones and Zones:FindFirstChild(eh)
    local pH_1 = pI
    if pI then
        pI = pH_1:FindFirstChild("Spawn")
    end
    local pH_2 = pI
    if pI then
        pI = pH_2:IsA("BasePart")
    end
    if not pI then
        return
    end
    lm("TeleportToZone", eh)
    local Character = lf.Character
    local pJ = Character and Character:FindFirstChild("HumanoidRootPart")
    if pJ then
        pJ.CFrame = pH_2.CFrame * CFrame.new(0, pH_2.Size.Y / 2 + 3, 0)
    end
end
local function onAutoTeleportBest(hq)
    kM = hq
    if hq then
        kH = nil
    end
end
local function onAutoEquipBest(gP)
    kW = gP
end
local function worker4()
    while not Library.Unloaded do
        task.wait(1.5)
        if k8 then
            pcall(lt, nil)
        end
        if k0 then
            pcall(lt, lg)
        end
    end
end
local function fn136(fG)
    local rh_1
    local rg_1
    local EnemyRender = Workspace:FindFirstChild("EnemyRender")
    if not EnemyRender then
        return nil
    end
    rh_1, rg_1 = nil, nil
    for i, child in ipairs(EnemyRender:GetChildren()) do
        local rf_1 = child:IsA("Model") and child.PrimaryPart
        if rf_1 then
            local Magnitude = (child.PrimaryPart.Position - fG.Position).Magnitude
            if not rg_1 or Magnitude < rg_1 then
                rh_1, rg_1 = child, Magnitude
            end
        end
    end
    return rh_1
end
local function fn142(cx, cy, cz, cA)
    local nR_1
    local nQ_1
    nQ_1, nR_1 = pcall(Heroes.GetCombatATK, cx, cy, cz, cA)
    local nS = not nQ_1
    local nW = if nS then 1 else 0
    local nU = 874 * nW + 3976 * (1 - nW)
    local nV = 558 * nW + 3883 * (1 - nW)
    if not ((nU * 1229 + nV * 2999 + nU * nV) % 16777213 == 3235280) then
        nS = not tonumber(nR_1)
    end
    if nS then
        return 0
    end
    local nQ_2 = Heroes.Get(cx)
    local nQ_3 = nQ_2 and nQ_2.AttackSpeed
    local nZ = if nQ_3 then 1 else 0
    local nX = 1869 * nZ + 355 * (1 - nZ)
    local nY = 1488 * nZ + 3985 * (1 - nZ)
    if not ((nX * 2718 + nY * 2380 + nX * nY) % 16777213 == 11402454) then
        nQ_3 = Shared.Config and Shared.Config.HeroDefaultAttackSpeed
    end
    local nS_3 = nQ_3 or 1
    return nR_1 / math.max(nS_3, 1e-06)
end
local function fn148()
    local qP, qQ
    local qM_1
    local qQ_2
    local qJ = kY("GetArtifacts")
    if type(qJ) ~= "table" then
        return
    end
    local qK = Inventory
    local qK_1
    local qL = {}
    if qK then
        qK = Inventory.GetOwnedBuckets
    end
    if qK then
        qK_1, qM_1 = pcall(Inventory.GetOwnedBuckets)
        local qN_1 = qK_1 and type(qM_1) == "table"
        if qN_1 then
            qL = qM_1
        end
    end
    if #qL == 0 then
        return
    end
    table.sort(qL, function(fg, fh)
        local qC = tonumber(fg.Dps) or 0
        local qC_1 = tonumber(fh.Dps) or 0
        if qC == qC_1 then
            return fg.HeroId .. "/" .. (fg.Size or "Normal") < fh.HeroId .. "/" .. (fh.Size or "Normal")
        end
        return qC > qC_1
    end)
    local qK_2 = {}
    local qM_2 = {}
    local qN_2 = {}
    for i, v in ipairs(Artifacts.DisplayOrder) do
        local qO_1 = qJ[v]
        if type(qO_1) == "table" then
            local qP_1 = type(qO_1.EquippedOn) == "table" and qO_1.EquippedOn
            local qR = qP_1 or {}
            local qR_1
            qP = qR
            for i, v in ipairs(qP) do
                qQ_2, qR_1 = string.match(v, "^(.-)/(.-)/")
                if qQ_2 then
                    local qS = qQ_2 .. "/" .. qR_1
                    local qQ_3 = qM_2[qS] or 0
                    qM_2[qS] = qQ_3 + 1
                end
            end
            qQ = tonumber(qO_1.Count) or 0
            local qO_2 = qQ - #qP
            if qO_2 > 0 then
                qN_2[#qN_2 + 1] = v
                qK_2[v] = qO_2
            end
        end
    end
    local qO_3 = 1
    local q6 = false
    for i, v in ipairs(qL) do
        local q5 = 16
        while true do
            if q5 < 14 then
                if q5 < 7 then
                    if q5 < 3 then
                        if q5 < 1 then
                            q5 = 22
                        elseif q5 < 2 then
                            q5 = if qP > 0 then 10 else 17
                        else
                            q5 = 5
                        end
                    elseif q5 < 5 then
                        if q5 < 4 then
                            qJ = 0
                            q5 = 26
                        else
                            q5 = if qJ then 21 else 0
                        end
                    elseif q5 < 6 then
                        q5 = 14
                    else
                        qL = 0
                        q5 = 19
                    end
                elseif q5 < 10 then
                    if q5 < 8 then
                        q6 = true
                        q5 = 23
                    elseif q5 < 9 then
                        q5 = 24
                    else
                        q5 = 23
                    end
                elseif q5 < 12 then
                    if q5 < 11 then
                        q5 = 5
                    else
                        qJ = v.HeroId
                        qL = v.Size
                        q5 = if qL then 15 else 28
                    end
                elseif q5 < 13 then
                    qL = v.HeroId
                    qQ = v.Size
                    q5 = if qQ then 25 else 27
                else
                    q5 = 18
                end
            elseif q5 < 21 then
                if q5 < 17 then
                    if q5 < 15 then
                        qJ = qN_2[qO_3]
                        q5 = if qJ then 20 else 4
                    elseif q5 < 16 then
                        qP = qJ .. "/" .. qL
                        qJ = (tonumber(v.Copies))
                        q5 = if qJ then 26 else 3
                    else
                        q5 = if v.HeroId then 11 else 9
                    end
                elseif q5 < 19 then
                    if q5 < 18 then
                        q5 = 24
                    else
                        q5 = 1
                    end
                elseif q5 < 20 then
                    qP = qJ - qL
                    q5 = 18
                else
                    qJ = qK_2[qN_2[qO_3]] <= 0
                    q5 = 4
                end
            elseif q5 < 25 then
                if q5 < 23 then
                    if q5 < 22 then
                        qO_3 = qO_3 + 1
                        q5 = 2
                    else
                        qJ = qN_2[qO_3]
                        q5 = if not qJ then 8 else 12
                    end
                elseif q5 < 24 then
                    break
                else
                    q5 = 9
                end
            elseif q5 < 27 then
                if q5 < 26 then
                    lm("EquipArtifact", qJ, qL, qQ)
                    qK_2[qJ] = qK_2[qJ] - 1
                    qP = qP - 1
                    q5 = 13
                else
                    qL = qM_2[qP]
                    q5 = if qL then 19 else 6
                end
            elseif q5 < 28 then
                qQ = "Normal"
                q5 = 25
            else
                qL = "Normal"
                q5 = 15
            end
        end
        if q6 then
            break
        end
    end
end
local function fn156()
    local rq = lB
    if not rq then
        return
    end
    local Character2 = lf.Character
    local rs = Character2 and Character2:FindFirstChild("HumanoidRootPart")
    local rt = rs
    if not rt then
        return
    end
    if lf:GetAttribute("CurrentZone") ~= rq then
        local rs_1 = kY("GetZoneUnlockState")
        local ru = type(rs_1) == "table" and type(rs_1.unlocked) == "table" and rs_1.unlocked
        local rs_2 = {}
        local rv = ru
        local rC = if rv then 1 else 0
        local rA = 3362 * rC + 886 * (1 - rC)
        local rB = 1980 * rC + 50 * (1 - rC)
        if not ((rA * 1688 + rB * 2053 + rA * rB) % 16777213 == 16396756) then
            rv = rs_2
        end
        if not rv[rq] then
            return
        end
        kP(rq)
        task.wait(0.35)
        local Character = lf.Character
        local rq_1 = Character and Character:FindFirstChild("HumanoidRootPart")
        rt = rq_1
        if not rt then
            return
        end
    end
    local rq_2 = lC(rt)
    if rq_2 and rq_2.PrimaryPart then
        local Position = rq_2.PrimaryPart.Position
        rt.CFrame = CFrame.new(Position + Vector3.new(0, 3, 6), Position)
    end
end
local function worker10()
    while not Library.Unloaded do
        if lA then
            pcall(lj)
            task.wait(1)
        else
            task.wait(1.5)
        end
    end
end
local function onAutoBuyAffordable(he)
    k8 = he
end
local function onAutoPrestige(gJ)
    kE = gJ
end
local function fn183()
    kF()
    pcall(function()
        Library:Unload()
    end)
end
local function onRemoveNewHeroPopup(gT)
    lo = gT
    if gT then
        pcall(k6)
    end
end
local function worker6()
    while not Library.Unloaded do
        task.wait(4)
        if kS then
            pcall(lI)
        end
    end
end
local function fn208()
    lp = false
    lk = false
    ld = false
    k8 = false
    k0 = false
    kW = false
    kS = false
    kM = false
    kE = false
    lF = false
    lA = false
    lv = false
    lr = false
    lo = false
end
local function fn220(bv, ...)
    local mW = lD(bv)
    if mW then
        pcall(mW.FireServer, mW, ...)
    end
end
local function fn230()
    local n4_2
    local n_ = kY("GetInventory")
    local n0 = type(n_) ~= "table" or type(n_.Heroes) ~= "table"
    if n0 then
        return
    end
    local n0_1 = ly()
    local n1 = tonumber(n_.MaxEquippedHeroes) or 1
    local n1_4
    local n2 = {}
    for k, v in pairs(n_.Heroes) do
        local n1_1 = type(v) == "table" and type(v.Sizes) == "table"
        if n1_1 then
            for k2, v in pairs(v.Sizes) do
                local n1_2 = type(v) == "table" and tonumber(v.Copies)
                local n4_1 = n1_2 or 0
                local n1_3 = n4_1
                if n4_1 then
                    n4_1 = n1_3 > 0
                end
                if n4_1 then
                    n1_4, n4_2 = 1, nil
                    if type(v.Instances) == "table" then
                        for k, v in pairs(v.Instances) do
                            local n5 = type(v) == "table" and tonumber(v.Level)
                            local n6 = n5 or 1
                            if not n4_2 or n6 > n1_4 then
                                n1_4, n4_2 = n6 or 1, k
                            end
                        end
                    end
                    n2[#n2 + 1] = { heroId = k, size = k2, instanceId = n4_2, power = k4(k, n1_4, k2, n0_1) }
                end
            end
        end
    end
    table.sort(n2, function(c8, c9)
        return c8.power > c9.power
    end)
    local n0_2 = {}
    local n1_5 = math.min(n1, #n2)
    local ov = 1
    while ov <= n1_5 do
        local n1_6 = n2[ov]
        n0_2[n1_6.heroId .. "/" .. n1_6.size] = true
        ov += 1
    end
    local n1_7 = {}
    if type(n_.EquippedHeroes) == "table" then
        for i, v in ipairs(n_.EquippedHeroes) do
            local n__1 = type(v) == "table" and v.HeroId
            if n__1 then
                local n__2 = v.HeroId
                local n4_3 = v.Size or "Normal"
                n1_7[n__2 .. "/" .. n4_3] = v
            end
        end
    end
    for k, v in pairs(n1_7) do
        if not n0_2[k] then
            lm("UnequipHero", v.HeroId, v.Size, v.InstanceId)
        end
    end
    local n__3 = math.min(n1, #n2)
    local oI = 1
    while oI <= n__3 do
        local n__4 = n2[oI]
        if not n1_7[n__4.heroId .. "/" .. n__4.size] then
            lm("EquipHero", n__4.heroId, n__4.size, n__4.instanceId)
        end
        oI += 1
    end
end
local function onInputBegan()
    la = tick()
end
local function onAutoBuyStats(hj)
    k0 = hj
end
local function onAutoEquipArtifact(gR)
    lv = gR
end
local function onWalkZone(g7)
    local rQ = kO[g7]
    if rQ then
        lB = rQ
    end
end
local function onAutoBuyPrestigeUpgrades(hl)
    lF = hl
end
local function onInputChanged(hG)
    local UserInputType = hG.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        la = tick()
    end
end
local function fn315()
    local oP = kY("GetEnemiesSnapshot")
    local oQ = type(oP) ~= "table" or type(oP.enemies) ~= "table"
    if oQ then
        return
    end
    local zoneName = oP.zoneName
    if not zoneName then
        return
    end
    local oR = kI()
    if #oR == 0 then
        return
    end
    for k, v in pairs(oP.enemies) do
        local oP_1 = type(v) == "table" and not v.Dead
        if oP_1 then
            local oS_1 = tonumber(v.HP) or 0
            oP_1 = oS_1 > 0
        end
        if oP_1 then
            for i, v2 in ipairs(oR) do
                if v2.HeroId then
                    local HeroId = v2.HeroId
                    local oS_2 = v2.Size or "Normal"
                    lm("ReportHeroAttack", zoneName, k, HeroId, oS_2, v2.InstanceId, 1000000000, v.SpawnPos)
                end
            end
            lm("ReportClickAttack", zoneName, k, v.SpawnPos)
        end
    end
end
local function fn319(gv)
    gv:AddLeftGroupbox("Discord", nil, true, false, true):AddButton({
        Text = "Join Discord For Dupe",
        Func = function()
            setclipboard(lb)
            Library:Notify("Copied Discord invite to clipboard")
        end
    })
end
local function onAutoWorldBoss(gL)
    lA = gL
    if not gL then
        k_ = nil
    end
end
local function onUpgradeCategories(hg)
    lg = kU(hg)
end
local function worker()
    while not Library.Unloaded do
        if lp then
            kY("Roll", 1)
            task.wait(0.05)
        else
            task.wait(0.2)
        end
    end
end
local function fn411()
    Currency = require(lE.client.Currency.Currency)
end
local function fn423(bz, ...)
    local m__1
    local mZ_1
    local mY = lD(bz)
    if mY then
        mZ_1, m__1 = pcall(mY.InvokeServer, mY, ...)
        if mZ_1 then
            return m__1
        end
        return nil
    end
    return nil
end
local function onAutoPurchaseZone(ho)
    kS = ho
end
local function worker13()
    while not Library.Unloaded do
        if lo then
            pcall(k6)
        end
        task.wait(0.4)
    end
end
local function fn516(eu)
    local pO = kY("GetZoneUnlockState")
    local pP = type(pO) == "table" and type(pO.unlocked) == "table" and pO.unlocked
    local pQ = pP or {}
    local pP_1 = nil
    for i, v in ipairs(Order) do
        if pQ[v] then
            pP_1 = v
        end
    end
    if pP_1 and (eu or pP_1 ~= kH) then
        kH = pP_1
        kP(pP_1)
    end
end
local function onWalkToEnemies(hb)
    lr = hb
end
local function fn522(b4)
    local nl = kY("GetUpgrades")
    local nm = {}
    local nn = type(nl) == "table" and type(nl.upgrades) == "table"
    if nn then
        for k, v in pairs(nl.upgrades) do
            nm[k] = v
        end
    end
    local nl_1 = nil
    if b4 then
        nl_1 = {}
        for k in pairs(b4) do
            local nn_1 = k7[k]
            if nn_1 then
                nl_1[nn_1] = true
            end
        end
    end
    local nn_2 = lx()
    for i, v in ipairs(Upgrades.Order()) do
        local no = true
        if nl_1 then
            local np_1 = Upgrades.Data[v]
            local nq = np_1 and np_1.Effect and np_1.Effect.Stat
            no = nq ~= nil and nl_1[nq] == true
        end
        local np_3 = no and Upgrades.GetState(v, nm, nn_2) == "Affordable"
        if np_3 then
            lm("PurchaseUpgrade", v)
            nm[v] = true
            local no_1 = Upgrades.GetCost(v) or 0
            nn_2 = nn_2 - no_1
        end
    end
end
local function worker11()
    while not Library.Unloaded do
        task.wait(5)
        if lv then
            pcall(ls)
        end
    end
end
local function worker7()
    while not Library.Unloaded do
        task.wait(6)
        if kM then
            pcall(lG, false)
        end
    end
end
local function onKillAura(gF)
    lk = gF
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Library.Toggles.AntiAfk.Value then
            local so = tick() - la
            local sp = tick() - k1
            if so >= 300 and sp >= 60 then
                pcall(lH)
            else
                if so < 300 and sp >= 300 then
                    pcall(lH)
                end
            end
        end
    end
end
local function fn593()
    local pZ_1
    local pY = Prestige and Prestige.CanPrestige and Prestige.Request
    local pY_1
    if pY then
        pY_1, pZ_1 = pcall(Prestige.CanPrestige)
        if pY_1 and pZ_1 then
            pcall(Prestige.Request)
        end
    end
end
local function fn604()
    local oM_1, oM_3
    local oL = Inventory and Inventory.GetEquipped
    local oL_1
    if oL then
        oL_1, oM_1 = pcall(Inventory.GetEquipped)
        local oN = oL_1 and type(oM_1) == "table" and #oM_1 > 0
        if oN then
            return oM_1
        end
        local oL_2 = kY("GetInventory")
        if oM_3 then
            return oL_2.EquippedHeroes
        end
        return {}
    end
    local oL_3 = kY("GetInventory")
    oM_3 = type(oL_3) == "table" and type(oL_3.EquippedHeroes) == "table"
    if oM_3 then
        return oL_3.EquippedHeroes
    end
    return {}
end
local function fn610()
    local m6_2
    local m5_2
    local m2_1, m2_4
    local m1 = Currency and Currency.Get
    local m1_1
    if m1 then
        m1_1, m2_1 = pcall(Currency.Get, "Gold")
        local m3 = m1_1 and tonumber(m2_1)
        if m3 then
            return m2_1
        end
        local m1_2 = kY("GetCurrencies")
        if m2_4 then
            local m2_3 = (tonumber(m1_2.balances.Gold))
            if not ((m5_2 * 2281 + m6_2 * 3179 + m5_2 * m6_2) % 16777213 == 658295) then
                m2_3 = 0
            end
            return m2_3
        end
        return 0
    end
    local m1_3 = kY("GetCurrencies")
    m2_4 = type(m1_3) == "table" and type(m1_3.balances) == "table"
    if m2_4 then
        local m2_5 = (tonumber(m1_3.balances.Gold))
        local m7_2 = if m2_5 then 1 else 0
        m5_2 = 3451 * m7_2 + 984 * (1 - m7_2)
        m6_2 = 3973 * m7_2 + 2281 * (1 - m7_2)
        if not ((m5_2 * 2281 + m6_2 * 3179 + m5_2 * m6_2) % 16777213 == 658295) then
            m2_5 = 0
        end
        return m2_5
    end
    return 0
end
local function fn626()
    Inventory = require(lE.client.Inventory.Inventory)
end
local function onAutoCollectLoot(gH)
    ld = gH
end
local function fn638()
    local m9_1, m9_4
    local m8 = Currency and Currency.Get
    local m8_1
    if m8 then
        m8_1, m9_1 = pcall(Currency.Get, "PrestigeTokens")
        local na = m8_1 and tonumber(m9_1)
        if na then
            return m9_1
        end
        local m8_2 = kY("GetCurrencies")
        if m9_4 then
            local m9_3 = tonumber(m8_2.balances.PrestigeTokens) or 0
            return m9_3
        end
        return 0
    end
    local m8_3 = kY("GetCurrencies")
    m9_4 = type(m8_3) == "table" and type(m8_3.balances) == "table"
    if m9_4 then
        local m9_5 = tonumber(m8_3.balances.PrestigeTokens) or 0
        return m9_5
    end
    return 0
end
local function fn658()
    if k_ then
        return
    end
    local Loot = Workspace:FindFirstChild("Loot")
    if not Loot then
        return
    end
    local o9 = {}
    for i, child in ipairs(Loot:GetChildren()) do
        if child:IsA("Model") then
            o9[#o9 + 1] = child
        end
    end
    if #o9 == 0 then
        return
    end
    local Character = lf.Character
    local pa = Character and Character:FindFirstChild("HumanoidRootPart")
    if not pa then
        return
    end
    CFrame2 = pa.CFrame
    local pa_1 = math.min(#o9, 15)
    local pk = 1
    while pk <= pa_1 do
        local pl = pk
        if k_ then
            CFrame2 = nil
            return
        end
        local pa_2 = o9[pl]
        if pa_2.Parent then
            pa.CFrame = CFrame.new(pa_2:GetPivot().Position + Vector3.new(0, 3, 0))
            task.wait(0.25)
        end
        pk += 1
    end
    local o9_1 = lf.Character and lf.Character:FindFirstChild("HumanoidRootPart")
    local o8_3 = o9_1
    if o9_1 then
        o9_1 = CFrame2
    end
    if o9_1 then
        o8_3.CFrame = CFrame2
    end
    CFrame2 = nil
end
local function fn675()
    local qh = kY("GetBossState")
    local Character = lf.Character
    local qj = Character and Character:FindFirstChild("HumanoidRootPart")
    local qj_1 = type(qh) ~= "table" or not qh.bossId
    if qj_1 then
        if k_ and qj then
            qj.CFrame = k_
            k_ = nil
        end
        return
    end
    local Worldboss = Workspace:FindFirstChild("Worldboss")
    local qk = Worldboss and Worldboss:FindFirstChild("BossSpawn")
    local qj_4 = qk
    if qk then
        qk = qj_4:IsA("BasePart")
    end
    if not (qk and qj) then
        return
    end
    if not k_ then
        k_ = CFrame2 or qj.CFrame
    end
    if (qj.Position - qj_4.Position).Magnitude > 12 then
        qj.CFrame = CFrame.new(qj_4.Position + Vector3.new(0, 3, 0))
    end
    if type(qh.runes) == "table" then
        for i, v in ipairs(qh.runes) do
            local qh_1 = type(v) == "table" and v.id
            if qh_1 then
                lm("ClaimBossRune", v.id)
            end
        end
    end
    for i, v in ipairs(kI()) do
        if v.HeroId then
            local HeroId = v.HeroId
            local qi_2 = v.Size or "Normal"
            lm("ReportBossAttack", 0, HeroId, qi_2, v.InstanceId, 1000000000)
        end
    end
end
local function onAutoRoll(gD)
    lp = gD
end
local function fn697()
    Prestige = require(lE.client.Prestige.Prestige)
end
local function worker8()
    while not Library.Unloaded do
        task.wait(5)
        if kE then
            pcall(lJ)
        end
    end
end
local function fn713()
    if not workspace.CurrentCamera then
        return
    end
    lq:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    lq:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    k1 = tick()
end
local function onUnload()
    Library:Unload()
end
local function worker5()
    while not Library.Unloaded do
        task.wait(5)
        if kW then
            pcall(kL)
        end
    end
end
local function worker12()
    while not Library.Unloaded do
        if lr then
            pcall(lL)
            task.wait(0.3)
        else
            task.wait(0.4)
        end
    end
end
local function fn751(br)
    if not lK[br] then
        lK[br] = Remotes:WaitForChild(br, 10)
    end
    return lK[br]
end
local function fn780()
    kF()
    connection2:Disconnect()
    connection3:Disconnect()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end
kE = nil
kF = nil
Order = nil
kH = nil
kI = nil
Remotes = nil
kK = nil
kL = nil
kM = nil
PrestigeUpgrades = nil
kO = nil
kP = nil
connection3 = nil
kR = nil
kS = nil
Artifacts = nil
kU = nil
CFrame2 = nil
kW = nil
Zones2 = nil
kY = nil
Inventory = nil
k_ = nil
k0 = nil
k1 = nil
Upgrades = nil
k3 = nil
k4 = nil
k6 = nil
k7 = nil
k8 = nil
Heroes = nil
la = nil
lb = nil
connection = nil
ld = nil
Shared = nil
lf = nil
lg = nil
connection2 = nil
Prestige = nil
lj = nil
lk = nil
ll = nil
lm = nil
Workspace = nil
lo = nil
lp = nil
local kD, k5
lq = nil
lr = nil
ls = nil
lt = nil
Library = nil
lv = nil
Currency = nil
lx = nil
ly = nil
lA = nil
lB = nil
lC = nil
lD = nil
lE = nil
lF = nil
lG = nil
lH = nil
lI = nil
lJ = nil
lK = nil
lL = nil
local lz, lO, lR, lS, lT, lW, lX
local lP_1
local lN_1
kD, lE, lz, lP_1, lq, Workspace, lf, lb, k5, lO, lN_1 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local lM = 10
repeat
    local lQ_1 = (lM * 5 + 0) % 6 + 1
    if lQ_1 <= 3 then
        if lQ_1 <= 2 then
            if lQ_1 <= 1 then
                local tf = bit32.rrotate(bit32.bxor(bit32.lrotate(lM, 13), string.byte(tostring(lf))), 6)
                if bit32.bxor(bit32.lrotate(bit32.bxor(tf, 11604299), 0), 11604299) == bit32.lrotate(tf, 0) then
                    lO = "RNG Heroes"
                else
                    lq = "RNG Heroes"
                end
                lM = (lM + 23) % 24
            else
                if lM * 38632629 + 11 + 3 >= lM * 38632629 + 11 + 3 + 2 then
                    lE = getgenv().TempoRNGHeroes
                else
                    lN_1 = getgenv().TempoRNGHeroes
                end
                lM = (lM + 23) % 24
            end
        else
            lR = (vector.create((lM * 5 + 4) % 11 + 1, (lM * 2 + 12) % 13 + 1, (lM * 1 + 4) % 17 + 1))
            local tx = vector.floor(lR) + vector.ceil(lR * -1)
            if vector.dot(tx, tx) == 0 then
                kD = game:GetService("Players")
            else
                lP_1 = game:GetService("Players")
            end
            lM = (lM + 17) % 24
        end
    elseif lQ_1 <= 5 then
        if lQ_1 <= 4 then
            local lQ_2 = {
                "thidmpvlszp",
                "djlctijdaqj",
                "qpcjdr",
                "gglya",
                "jtelzmgms",
                "mbteixcigfb",
                "zkpuejknmcvd",
                "wgcjxbwpsf"
            }
            if lQ_2[(lM * 1 + 87) % 8 + 1] < lQ_2[(lM * 1 + 87) % 8 + 1] then
                lz = game:GetService("ReplicatedStorage")
                lE = game:GetService("TweenService")
            else
                lE = game:GetService("ReplicatedStorage")
                lz = game:GetService("TweenService")
            end
            lM = (lM + 5) % 24
        else
            local lQ_3 = {
                "ccrqyjbajreu",
                "zjxdmycd",
                "prathel",
                "szyvjyd",
                "rnaqy",
                "tjn",
                "htw",
                "spejxowudxg",
                "hbzdf",
                "lgxdm",
                "szng",
                "cniqzerufovw"
            }
            if lQ_3[(lM * 52 + 107) % 12 + 1] <= lQ_3[(lM * 52 + 107) % 12 + 1] then
                lP_1 = game:GetService("UserInputService")
                lq = game:GetService("VirtualUser")
                Workspace = game:GetService("Workspace")
                lf = kD.LocalPlayer
            else
                kD = game:GetService("UserInputService")
                lf = game:GetService("VirtualUser")
                lq = game:GetService("Workspace")
                lP_1 = Workspace.LocalPlayer
            end
            lM = (lM + 17) % 24
        end
    else
        local lQ_4 = (vector.create((lM * 2 + 1) % 11 + 1, (lM * 3 + 11) % 13 + 1, (lM * 3 + 13) % 17 + 1))
        lR = (vector.create((lM * 6 + 3) % 11 + 1, (lM * 1 + 13) % 13 + 1, (lM * 6 + 15) % 17 + 1))
        lS = (vector.create((lM * 2 + 4) % 11 + 1, (lM * 6 + 9) % 13 + 1, (lM * 14 + 8) % 17 + 1))
        lT = (vector.create((lM * 4 + 8) % 11 + 1, (lM * 1 + 8) % 13 + 1, (lM * 5 + 16) % 17 + 1))
        if vector.dot(vector.cross(lQ_4, lR), (vector.cross(lS, lT))) == vector.dot(lQ_4, lS) * vector.dot(lR, lT) - vector.dot(lQ_4, lT) * vector.dot(lR, lS) then
            lb = "https://discord.gg/K7Qxnxkk46"
            k5 = ""
        else
            k5 = "https://discord.gg/K7Qxnxkk46"
            lb = ""
        end
        lM = (lM + 5) % 24
    end
until (lM * 17 + 19) % 24 == 15
if lN_1 then
    lM = 2
    repeat
        local te = bit32.rrotate(bit32.bxor(bit32.lrotate(lM, 22), string.byte(tostring(lM))), 2)
        if bit32.bxor(bit32.lrotate(bit32.bxor(te, 888695498), 6), 1041937037) ~= bit32.lrotate(te, 6) then
            lN_1 = getgenv().TempoRNGHeroes.Stop
        else
            lN_1 = getgenv().TempoRNGHeroes.Stop
        end
        lM = (lM + 2) % 8
    until (lM * 5 + 5) % 8 == 1
end
if lN_1 then
    lM = 0
    repeat
        if (lM * 3 + 2) * 9 % 4 == ((lM * 3 + 2) * 9 + 11) % 4 then
            pcall(getgenv().TempoRNGHeroes.Stop)
        else
            pcall(getgenv().TempoRNGHeroes.Stop)
        end
        lM = (lM + 0) % 8
    until (lM * 7 + 1) % 8 == 1
end
Library, Shared, Heroes, Upgrades, Zones2, Artifacts, PrestigeUpgrades, Order = nil, nil, nil, nil, nil, nil, nil, nil
local function lN_2()
    local mF
    local screenGui
    local mv
    local frame4
    local mC
    frame4 = nil
    mv = nil
    screenGui = nil
    mC = nil
    mF = nil
    local ms, frame3, mw, my, mz, frame2, mB, mD, mE, mG
    local mH = 3
    mD = Color3.fromRGB(143, 165, 240)
    local mI = Color3.fromRGB(15, 16, 20)
    mz = Color3.fromRGB(22, 24, 30)
    mF = Color3.fromRGB(230, 235, 245)
    mv = Color3.fromRGB(36, 39, 48)
    local mJ = gethui and gethui()
    local mK = mJ or game:GetService("CoreGui")
    local mJ_1 = mK or kD.LocalPlayer:WaitForChild("PlayerGui")
    local TempoLoadingScreen = mJ_1:FindFirstChild("TempoLoadingScreen")
    if TempoLoadingScreen then
        TempoLoadingScreen:Destroy()
    end
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TempoLoadingScreen"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 99999
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = mJ_1
    local frame5 = Instance.new("Frame")
    frame5.Size = UDim2.fromScale(1, 1)
    frame5.BackgroundColor3 = mI
    frame5.BackgroundTransparency = 1
    frame5.BorderSizePixel = 0
    frame5.Parent = screenGui
    frame4 = Instance.new("Frame")
    frame4.Size = UDim2.fromOffset(380, 250)
    frame4.Position = UDim2.new(0.5, -190, 0.5, -110)
    frame4.BackgroundColor3 = mz
    frame4.BackgroundTransparency = 1
    frame4.BorderColor3 = mv
    frame4.Parent = frame5
    mC = function(D, E, F, G, H, I, J)
        local K = Instance.new(D)
        K.Position = E
        K.Size = F
        K.BackgroundTransparency = 1
        K.Text = G
        K.Font = H
        K.TextSize = I
        K.TextColor3 = J
        K.TextTransparency = 1
        K.Parent = frame4
        return K
    end
    mw = mC("TextLabel", UDim2.new(0, 0, 0, 30), UDim2.new(1, 0, 0, 25), "Tempo Marketplace & MM", Enum.Font.GothamMedium, 17, mF)
    mB = mC("TextLabel", UDim2.new(0, 0, 0, 58), UDim2.new(1, 0, 0, 20), "Tempo Bypassing", Enum.Font.Gotham, 12, mD)
    local function mI_1(P, Q)
        local U = mC("TextButton", UDim2.new(0, 40, 0, P), UDim2.new(1, -80, 0, 36), Q, Enum.Font.Gotham, 12, mF)
        U.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        U.BorderColor3 = mv
        U.AutoButtonColor = false
        U.Active = false
        return U
    end
    my = mI_1(95, "Discord Link Here (Click to Copy)")
    mE = mI_1(138, "Get PC Executor Here (Click to Copy)")
    frame3 = Instance.new("Frame")
    frame3.Position = UDim2.new(0, 40, 0, 195)
    frame3.Size = UDim2.new(1, -80, 0, 2)
    frame3.BackgroundColor3 = Color3.fromRGB(32, 35, 45)
    frame3.BackgroundTransparency = 1
    frame3.BorderSizePixel = 0
    frame3.Parent = frame4
    frame2 = Instance.new("Frame")
    frame2.Size = UDim2.new(0, 0, 1, 0)
    frame2.BackgroundColor3 = mD
    frame2.BackgroundTransparency = 1
    frame2.BorderSizePixel = 0
    frame2.Parent = frame3
    mG = function(ab)
        local frame, textLabel
        local Toast = screenGui:FindFirstChild("Toast")
        if Toast then
            Toast:Destroy()
        end
        frame = Instance.new("Frame")
        frame.Name = "Toast"
        frame.Size = UDim2.fromOffset(220, 45)
        frame.Position = UDim2.new(1, 20, 1, -65)
        frame.BackgroundColor3 = mz
        frame.BorderColor3 = mD
        frame.ZIndex = 100000
        frame.Parent = screenGui
        textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.fromScale(1, 1)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = ab
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextSize = 11
        textLabel.TextColor3 = mF
        textLabel.ZIndex = 100001
        textLabel.Parent = frame
        lz:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(1, -240, 1, -65) }):Play()
        task.delay(2.2, function()
            if not frame.Parent then
                return
            end
            local mf = lz:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, 20, 1, -65) })
            lz:Create(textLabel, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
            mf:Play()
            mf.Completed:Connect(function()
                frame:Destroy()
            end)
        end)
    end
    local function mI_2(ar, as, at)
        ar.MouseEnter:Connect(function()
            if ar.Active then
                lz:Create(ar, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(34, 37, 47), BorderColor3 = mD, TextColor3 = mD }):Play()
            end
        end)
        ar.MouseLeave:Connect(function()
            if ar.Active then
                lz:Create(ar, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(28, 30, 38), BorderColor3 = mv, TextColor3 = mF }):Play()
            end
        end)
        ar.MouseButton1Click:Connect(function()
            if not ar.Active then
                return
            end
            local mq = setclipboard and pcall(setclipboard, as)
            if mq then
                mG(at)
            else
                mG("Clipboard action not supported.")
            end
        end)
    end
    mI_2(my, lb, "Discord invite copied to clipboard!")
    mI_2(mE, k5, "PC Executor link copied to clipboard!")
    ms = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    lz:Create(frame5, TweenInfo.new(0.4), { BackgroundTransparency = 0 }):Play()
    lz:Create(frame4, ms, { Position = UDim2.new(0.5, -190, 0.5, -130), BackgroundTransparency = 0 }):Play()
    task.delay(0.1, function()
        lz:Create(mw, ms, { TextTransparency = 0 }):Play()
        lz:Create(mB, ms, { TextTransparency = 0 }):Play()
        lz:Create(my, ms, { TextTransparency = 0, BackgroundTransparency = 0 }):Play()
        lz:Create(mE, ms, { TextTransparency = 0, BackgroundTransparency = 0 }):Play()
        lz:Create(frame3, ms, { BackgroundTransparency = 0 }):Play()
        lz:Create(frame2, ms, { BackgroundTransparency = 0 }):Play()
    end)
    task.wait(0.6)
    my.Active = true
    mE.Active = true
    lz:Create(frame2, TweenInfo.new(mH, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = UDim2.fromScale(1, 1) }):Play()
    task.wait(3.8)
    local mH_1 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    for i, descendant in ipairs(frame4:GetDescendants()) do
        local mI_3 = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
        if mI_3 then
            lz:Create(descendant, mH_1, { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
        elseif descendant:IsA("Frame") then
            lz:Create(descendant, mH_1, { BackgroundTransparency = 1 }):Play()
        end
    end
    lz:Create(frame4, mH_1, { BackgroundTransparency = 1 }):Play()
    local mI_4 = lz:Create(frame5, mH_1, { BackgroundTransparency = 1 })
    mI_4:Play()
    mI_4.Completed:Connect(function()
        screenGui:Destroy()
    end)
    task.wait(0.5)
end
lN_2()
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
lT = getgenv().SaveManager
Shared = require(lE.shared.Shared)
Heroes = Shared.Heroes
Upgrades = Shared.Upgrades
Zones2 = Shared.Zones
Artifacts = Shared.Artifacts
PrestigeUpgrades = require(lE.shared.Upgrades.PrestigeUpgrades)
Order = require(lE.shared.Zones.ZoneData).Order
lS = lf:GetAttribute("CurrentZone") or Order[1]
lB, Currency, Prestige, Inventory, Remotes, lK, k7, k_, CFrame2, kH, lp, lk, ld, k8, k0, kW, kS, kM, kE, lF, lA, lv, lr, lo, lg, connection, lD, lm, kY, lx, kK, kU, lt, ly, k4, kL, kI, k3, kR, lI, kP, lG, lJ, ll, lj, ls, lC, lL, k6 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
lB = lS
pcall(fn411)
pcall(fn697)
pcall(fn626)
Remotes = lE:WaitForChild("Remotes")
lK = {}
lD = fn751
lm = fn220
kY = fn423
lx = fn610
kK = fn638
k7 = { Luck = "Luck", ["Roll Speed"] = "RollSpeed", Gold = "GoldDropAmount", Damage = "HeroDamage" }
lR = { "Luck", "Roll Speed", "Gold", "Damage" }
kU = fn71
lt = fn522
ly = fn29
k4 = fn142
kL = fn230
kI = fn604
k3 = fn315
kR = fn658
lI = fn16
kP = fn86
lG = fn516
lJ = fn593
ll = fn43
lj = fn675
ls = fn148
lC = fn136
lL = fn156
lp = false
lk = false
ld = false
k8 = false
k0 = false
kW = false
kS = false
kM = false
kE = false
lF = false
lA = false
lv = false
lr = false
lo = false
lg = { Luck = true, ["Roll Speed"] = true, Gold = true, Damage = true }
k6 = function()
    local PlayerGui = lf:FindFirstChildOfClass("PlayerGui")
    if not PlayerGui then
        return
    end
    local HeroDiscovered = PlayerGui:FindFirstChild("HeroDiscovered", true)
    if not HeroDiscovered then
        return
    end
    if not connection then
        connection = HeroDiscovered:GetPropertyChangedSignal("Visible"):Connect(function()
            if lo and HeroDiscovered.Visible then
                HeroDiscovered.Visible = false
            end
        end)
    end
    if lo and HeroDiscovered.Visible then
        HeroDiscovered.Visible = false
    end
end
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = lb .. " | " .. lO,
    Icon = 18657887261,
    NotifySide = "Right",
    ShowCustomCursor = false
})
local lV = {
    Main = Window:AddTab("Main", "play"),
    Upgrades = Window:AddTab("Upgrades", "trending-up"),
    Zones = Window:AddTab("Zones", "map"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in lV do
    fn319(v)
end
lS, kO = nil, nil
lM = 4
repeat
    if (lM * 1 + 1) % 2 + 1 <= 1 then
        local lQ_7 = (vector.create((lM * 6 + 9) % 11 + 1, (lM * 2 + 7) % 13 + 1, (lM * 2 + 1) % 17 + 1))
        lW = (vector.create((lM * 1 + 9) % 11 + 1, (lM * 2 + 2) % 13 + 1, (lM * 9 + 5) % 17 + 1))
        lX = (vector.create((lM * 3 + 7) % 11 + 1, (lM * 6 + 13) % 13 + 1, (lM * 1 + 12) % 17 + 1))
        if vector.dot(vector.cross(lQ_7, lW), lX) == vector.dot(vector.cross(lW, lX), lQ_7) then
            kO = {}
        else
            lS = {}
        end
        lM = (lM + 3) % 8
    else
        local lQ_8 = { "trxdxkyactq", "pupxbsg", "vsxkh", "iiencbkkru", "iuvn", "wtosfm", "ayohyy" }
        local tD = lM
        lW = lQ_8[tD % 7 + 1]
        if lW:len() <= lW:gsub("(.)", "%1%1", tD % 3 % 2 + 1):len() then
            local FarmGroup = lV.Main:AddLeftGroupbox("Farm")
            FarmGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false, Callback = onAutoRoll })
            FarmGroup:AddToggle("KillAura", { Text = "Kill Aura", Default = false, Callback = onKillAura })
            FarmGroup:AddToggle("AutoCollectLoot", { Text = "Auto Collect XP & Gold", Default = false, Callback = onAutoCollectLoot })
            FarmGroup:AddToggle("AutoPrestige", { Text = "Auto Prestige", Default = false, Callback = onAutoPrestige })
            FarmGroup:AddToggle("AutoWorldBoss", { Text = "Auto World Bosses", Default = false, Callback = onAutoWorldBoss })
            lO = lV.Main:AddRightGroupbox("Heroes")
            lO:AddToggle("AutoEquipBest", { Text = "Auto Equip Best Heroes", Default = false, Callback = onAutoEquipBest })
            lO:AddToggle("AutoEquipArtifact", { Text = "Auto Equip Artifact", Default = false, Callback = onAutoEquipArtifact })
            lO:AddToggle("RemoveNewHeroPopup", { Text = "Remove New Hero Popup", Default = false, Callback = onRemoveNewHeroPopup })
            lS = {}
        else
            lV = lS.Main:AddLeftGroupbox("Farm")
            lV:AddToggle("AutoRoll", { Default = false, Text = "Auto Roll", Callback = onAutoRoll })
            lV:AddToggle("KillAura", { Callback = onKillAura, Default = false, Text = "Kill Aura" })
            lV:AddToggle("AutoCollectLoot", { Default = false, Callback = onAutoCollectLoot, Text = "Auto Collect XP & Gold" })
            lV:AddToggle("AutoPrestige", { Text = "Auto Prestige", Callback = onAutoPrestige, Default = false })
            lV:AddToggle("AutoWorldBoss", { Callback = onAutoWorldBoss, Default = false, Text = "Auto World Bosses" })
            local HeroesGroup = lS.Main:AddRightGroupbox("Heroes")
            HeroesGroup:AddToggle("AutoEquipBest", { Callback = onAutoEquipBest, Text = "Auto Equip Best Heroes", Default = false })
            HeroesGroup:AddToggle("AutoEquipArtifact", { Default = false, Text = "Auto Equip Artifact", Callback = onAutoEquipArtifact })
            HeroesGroup:AddToggle("RemoveNewHeroPopup", { Default = false, Text = "Remove New Hero Popup", Callback = onRemoveNewHeroPopup })
        end
        lM = (lM + 5) % 8
    end
until (lM * 3 + 4) % 8 == 0
for i, v in ipairs(Order) do
    lM = Zones2.Get(v)
    lM = lM and lM.DisplayName or v
    local lN_7 = lM
    lS[#lS + 1] = lN_7
    kO[lN_7] = v
end
lO = Zones2.Get(lB)
lM = lO and lO.DisplayName or lS[1]
la, k1, connection2, connection3, lH, kF = nil, nil, nil, nil, nil, nil
local lQ_10 = lM
lO = lV.Main:AddRightGroupbox("Movement")
lO:AddDropdown("WalkZone", { Text = "Walk Zone", Values = lS, Multi = false, Default = lQ_10, Callback = onWalkZone })
lO:AddToggle("WalkToEnemies", { Text = "Walk To Enemies", Default = false, Callback = onWalkToEnemies })
lX = lV.Upgrades:AddLeftGroupbox("Upgrades")
lX:AddToggle("AutoBuyAffordable", { Text = "Auto Purchase Affordable Upgrades", Default = false, Callback = onAutoBuyAffordable })
lX:AddDropdown("UpgradeCategories", { Text = "Upgrade Stats", Values = lR, Multi = true, Default = lR, Callback = onUpgradeCategories })
lX:AddToggle("AutoBuyStats", { Text = "Auto Upgrades", Default = false, Callback = onAutoBuyStats })
lX:AddToggle("AutoBuyPrestigeUpgrades", {
    Text = "Auto Purchase Affordable Prestige Upgrades",
    Default = false,
    Callback = onAutoBuyPrestigeUpgrades
})
local ZonesGroup = lV.Zones:AddLeftGroupbox("Zones")
ZonesGroup:AddToggle("AutoPurchaseZone", { Text = "Auto Purchase Next Zone", Default = false, Callback = onAutoPurchaseZone })
ZonesGroup:AddToggle("AutoTeleportBest", { Text = "Auto Teleport To Best Owned Zone", Default = false, Callback = onAutoTeleportBest })
lW = lV.Settings:AddLeftGroupbox("Menu")
la = tick()
k1 = tick()
pcall(function()
    for i, v in ipairs(getconnections(lf.Idled)) do
        local rZ = v
        pcall(function()
            rZ:Disable()
        end)
    end
end)
lH = fn713
connection2 = lP_1.InputBegan:Connect(onInputBegan)
connection3 = lP_1.InputChanged:Connect(onInputChanged)
lW:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
lW:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Library.Options.MenuKeybind
lW:AddButton("Unload", onUnload)
kF = fn208
Library:OnUnload(fn780)
getgenv().TempoRNGHeroes = { Stop = fn183 }
task.spawn(worker)
task.spawn(worker2)
task.spawn(worker3)
task.spawn(worker4)
task.spawn(worker5)
task.spawn(worker6)
task.spawn(worker7)
task.spawn(worker8)
task.spawn(worker9)
task.spawn(worker10)
task.spawn(worker11)
task.spawn(worker12)
task.spawn(worker13)
task.spawn(antiAfkLoop)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
lT:SetLibrary(Library)
lT:IgnoreThemeSettings()
lT:SetIgnoreIndexes({ "MenuKeybind" })
lT:SetFolder("TempoHub/RNGHeroes")
lT:BuildConfigSection(lV.Settings)
ThemeManager:ApplyToTab(lV.Settings)
ThemeManager:LoadDefault()
lT:LoadAutoloadConfig()
end)(...)
