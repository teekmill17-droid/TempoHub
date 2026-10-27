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
getgenv().TempoHoodSubtitle = "ANIME ULTRON SIMULATOR"
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
local f_
local f5
local gr
local gb
local fT
local PlayerPower
local gA
local gk
local gn
local gt
local gz
local fV
local SpawnEnemies
local gg
local gj
local fY
local gp
local f3
local gs
local gy
local fU
local gB
local fX
local fn723
local function fn59()
    local Character = gn.Character
    local hY = Character and Character:FindFirstChild("HumanoidRootPart")
    return hY
end
local function fn88(ef, eg)
    if type(ef) ~= "number" then
        return false
    end
    if ef % 1 ~= 0 then
        return false
    end
    local eh_1 = bit32.bxor(ef, 1540483477)
    local eh_2 = bit32.band(eh_1 * 403 + bit32.lshift(eh_1, 24), 4294967295)
    local eh_3 = bit32.bxor(eh_2, bit32.rshift(eh_2, 13))
    return eh_3 == eg
end
local function worker()
    while true do
        if gy then
            pcall(function()
                local EquipBestLoadout = gj.EquipBestLoadout
                EquipBestLoadout.Fire(EquipBestLoadout, { Category = "Avatar", Mode = fY })
            end)
            task.wait(5)
        else
            task.wait(0.5)
        end
    end
end
local function fn148(a8)
    local h8_1
    local h7_1
    local h5 = gb()
    if not h5 then
        return nil
    end
    local Position = h5.Position
    h8_1, h7_1 = nil, nil
    for k, v in pairs(SpawnEnemies.getTrackedReferences()) do
        local h5_1 = (f5(k, v))
        if h5_1 then
            h5_1 = a8 == nil or v.Name == a8
        end
        if h5_1 then
            local Magnitude = (k.Position - Position).Magnitude
            if h7_1 == nil or Magnitude < h7_1 then
                h8_1 = k
                h7_1 = Magnitude
            end
        end
    end
    return h8_1
end
local function fn242(cA)
    gt = cA
end
local function fn374(cj)
    fX = cj
end
local function fn456(b8)
    b8.AddButton(b8, {
        Title = "Join Discord for Dupes/Keyless Scripts",
        Description = "Copies the invite link to your clipboard.",
        Callback = function()
            if setclipboard then
                setclipboard(gg)
            end
        end
    })
end
local function fn550(cb)
    f3 = cb
end
local function fn701(a3, a4)
    if a3.Parent == nil then
        return false
    elseif a3:GetAttribute("IsDead") == true then
        return false
    elseif a4.IsDead == true then
        return false
    else
        local attr = a3:GetAttribute("EntityId")
        local h3 = fn723(typeof(attr), 6, 2175009567) and not fn723(attr, 0, 5381)
        return h3
    end
end
local function worker2()
    while true do
        if gB then
            gs()
            task.wait(30)
        else
            task.wait(0.5)
        end
    end
end
fn723 = function(d6, d7, d8)
    if type(d6) ~= "string" then
        return false
    end
    if #d6 ~= d7 then
        return false
    end
    local d9 = 5381
    local ea = buffer.fromstring(d6)
    local eb = 0
    while eb <= d7 - 4 do
        local ec = buffer.readu32(ea, eb)
        local d9_1 = bit32.bxor(d9, ec)
        d9 = bit32.band(d9_1 * 33, 4294967295)
        eb = eb + 4
    end
    while eb < d7 do
        local ed = buffer.readu8(ea, eb)
        local d9_2 = bit32.bxor(d9, ed)
        d9 = bit32.band(d9_2 * 33, 4294967295)
        eb = eb + 1
    end
    return d9 == d8
end
local function fn934(ck)
    fT = ck
end
local function fn941(bo)
    local im = gb()
    if not im then
        return
    end
    local io = PlayerPower.getAttackRadius(gn) or 16
    local io_1 = math.clamp(io * 0.5, 4, 10)
    local Position = bo.Position
    im.CFrame = CFrame.new(Position + Vector3.new(0, 3, io_1), Position)
end
local function worker3()
    while true do
        if f_ then
            local it = gp and gn:GetAttribute("CurrentIsland") ~= gp
            if it then
                fV(gp)
            end
            local it_1 = f_ and gz(gk)
            local iu = it_1 or nil
            if iu then
                local iu_1 = os.clock() + 10
                while true do
                    local iv = f_
                    if iv then
                        local iw = SpawnEnemies.getTrackedReferences()[iu] or {}
                        iv = f5(iu, iw)
                    end
                    if iv then
                        iv = os.clock() < iu_1
                    end
                    if iv then
                        fU(iu)
                        gr(iu)
                        task.wait(0.08)
                        continue
                    end
                    break
                end
            else
                task.wait(0.3)
            end
        else
            task.wait(0.2)
        end
    end
end
local fR
fT = nil
fU = nil
fV = nil
local fW
fX = nil
fY = nil
local fZ
f_ = nil
local f1
local f2
f3 = nil
f5 = nil
local f7
local ga
gb = nil
local gc
PlayerPower = nil
local gf
gg = nil
gj = nil
gk = nil
local imageButton
gn = nil
gp = nil
gr = nil
gs = nil
gt = nil
local gv
local gx
gy = nil
gz = nil
gA = nil
gB = nil
SpawnEnemies = nil
local f0, f6, Dropdown, gl, gu, FarmEnemyDropdown
local gD_1, gD_16
local gF, gG, gH, gI, onCallback, gN, gP, gR, gS
local gO_1
local gE_1, gE_3
local gQ_11
local gL_1
local gM_1, gM_23
local gq = (buffer.fromstring("1--)*cvv>0-1,;w:64v\x18:-,85\x148*-<+\x166>.8 v\x1f5,<7-t\x0b<7<.<=v+<5<8*<*v58-<*-v=6.7568=v\x1f5,<7-w5,8,*=YT+bP.,U@++,FL4BbFy#gOi#1.zs`TUN\x01rTLLNOIFo7TlEzZ3${!+ar%6/?{7M9!m+k1EtwUDcUBFYSUH5/j)McX#k[;SfsNx{LoqZm)JMB&%$bRP]TeHATbx+zpd@bHPNP#moZ?)Y1PArK][J:iQvPRYP\x11f^C]UKyt:sh%K.imx57!f%.Fd5CD8;oKmACLOZe6*?vgnek*-_kJFI}}b0n9X*jF)l=A]eT]TA^CErPEP]^VvMdK?!N[{l7R;AkIus(m,VvFW@@KbPL-eWi[Ojsjq^el8B#ZgBvSfhim@4GDUCZ=8?G:,c=z&+_3=[(VhWXzyv2jQWQGYVwAHAGPpEFn3Aln}e)7^eV{{75?gzg}]yexWPWQJMD/NOqPO[h$I7fD.mYk;JK_d[QF;diKjKHO[BZ*PMPNHl(#)Q)^o+wg*V8ql&cfm4kMUUWV%KSms6,qu#fwY:j1M(:G+wb?9QDc`DPUfgu8YPJwYWmqpIvk]To6.{fFL5Tl6wMJWZWJWK\x18pMZK;U=slZoGU1xms_oLTusM[SNs.3=i-,0*Yl(@tE;8u6%^,gg3i84$$08=-;1S7)HkmqCQSA^q#i2LL67Ta;;vR^XZnE!*}4[_eEb5V6PxAb@YT/=eA]g[VNIMO!45PdWC}AG8vpLEJnkGQB9}RqPST@YACMdKC}@W8FS{,Chb8]*@BD37qQEsEUmzdDfhNdNnM7D]@OYb41bo{B*;8)?&!/Nr5ayG_]Iq4P4gVN63JS2$s~DWHnHsMckUQ,1u[#chY/F]B@nkY[9wRJE=-r]DR6..^p^.n2&MlBbT^Z#lhrORJCu!KdAPPKgp3!HP:rX=J_ZQzfeCUBy^@EDdI@Uj=9&adCp*WR+99WikZGK|PSPM\x0cw[CY#gi[X8%r6=krmG}_Ni_HLSY_Z5nBLFa);+/Yt:vkIZd[G]@][Z4DG.miLf#l$-UJuFJJL+;%,!>-{Tr$zsNS#prG7tx^,sj;ey`QTTY^W=;t/Tb#;suAipFCcAkuETCCHaSO;&Cw$#IV*&zlZky/g8mIECAfQPPKJR-.bMS?gm_OsFJweAFAEARMcMQBL)53lpCU/3E_l?h^VKyPM|WVS[.xdLal:?&/.[WqITJBLZ:Xpy5=J02mv8&WIVL$}@]EL5Rah4^AIvFUFZ;{XYWo0~H@]oF[jA@EM6Nr9ej_*Ikg}o[ZA|O@E{^}c7F.?WUUzcr;rK^]SZaKy*u/iIoDT9tH[yRuo^MZQKj)oZU#BV^(Tw_nc^R!.-!)aE;p6@UDGc+;9c;?=lCD@H\rxAY_BC\r~D@XALYB_~_rYP_VTUmnvV}[gLCs*52}L_HCY&]!II?,Nx(;aGmKOrP[Z=lUGnO2F&:2f{ekx@~C^FOHcX;zfqw-#uC*ZlAq@]QvL_@9bme1U9(_2*2KNRWMOgG{a+l_UK+Gkw[x]]mX[*#Cjp78nH7fO1yDYAH(3LE2K)z.tfX6buY_XE0!u72wff.=lGiMjy^TUHrUXQFY_B^/1dutN|Z^-r*Ki0.qbEuv]vT_^lacgLcKYrP}b;GkIX\x7fI^ZEOI1)w4KRC|OX^CIKFkFCMDGOD^lCFJA[A%4ZqQ4!G/PiHKLXAY2zNzD1=RO83!I=2UBupp1K8*N`TPLUg@VQiJDAJPQ56'1(F,cHaZHuh.pfEGOCVKQJ@gKHKV\x17NFFVrm9xEv,umzs83!Y^E)GH-GH47)pA\\PgKHKV\x17u=zV.tNITYTITHwTZ_^Is`GMLQkLAH_@F[{F[CJ&^z6CeAc_zVT[XM)!rjLX_ppQRUAX@/?SOH:tXZUVC#PT=r:CvPFQjMSVWwZSFvGBBOHAdIRRIKhReD@E]iTxNMTxZ@FPw@AAZ[\x04fPXEw^CrYX]UeRDRCxYdGV@YrDLQcJWfMLIAhJ[n[[]FMZ[Jz_Q^B_XQhn.8sEMPbKVgLMH@lN_j__YBI^_NcTBTE~_bAPF_v[CUONuH^_Hj__JH@x[NNO|FGVH(pv#Q/hYNJ_N#x#{Jg[VNREgX@REdKFMJWuJLKQwCBY\x16wBBWU]lJHCJjHHNXXq@SDOUgstF`Z[;YmdkkOl[VO_I0}-OvBCX\x17pVT_VrTV]TbZGYQkZGK}JKKPQnBCYHUYXLAnKK{@HHCJg[ZPX]V@@~[[kPXXSZu^WDWUBSDdAAqJBBI@kGEXIFAGFmHHxCKK@I\x00\x00\x00\x00\x00\x00\xf8?{\x14\xaeG\xe1z\xb4?soeITHCT`_CYDY_^q@]QvL_@tVCRPXEN333333\xd3?\x9a\x99\x99\x99\x99\x99\xa9?wDSUHB@MyO^|KF_O333333\xeb?qmwPVKOAhDEENH__KVTk~{T@]_`up+!%#%*1fJKK@FQlV]SVQXd^U[^YPxDD@wUD`EEu@CX_YBELvPHHJKfWDSXB}JG^NX{AvWSV}[CCA@eTGP[AvZXWTAuDW@KQx@]CKBWTZS('$( |D]EXVUDRKuQITBSXJkOrORJClTIW_uAR^Vb_BZS{F[CJ/91,gHSD\xdd\xd1\x92\xb5vL_@\xd9b\xd9\x05 +9L\xe9\x85\xc8\x8eg]NQ\xa7\xbb\x0c\xa0OYQL\xa1\x0bx\x02zUYQj\xf9\x9b-KC\x87\x91wM^A\xfcAr\x1e83!s:q92 -&4\xd6\x01\t]\x154G\n\x10xEi\xaa09<Q\x02\x00t-"))
local go = (buffer.fromstring("\x0f*,+e#*7e\x0105 6e$+!e\x0e <) 66e\x16&7,516ke\x0105 6e2,))e$)2$<6e' e$++*0+& !e$+!e+ 3 7e\"$1 . 51e,+e\n07*'*7*6k#,%iy@TNlT@SqzNOT\x1bhNVVTU8YcscVCKj?I_TvsT[wX*@{YsDFaAx6JsEMPbKVgLMH@i]p0iStcF/(RI+kU.p9{njlhU_z,joKYCDMnCXOI^CEDvh-J{265@,t8}[u_gpOz0QMnUQEXZdTV[Rf^Q2s=H5odLAW91De7mKinzqWVc$tb@Qv@WSLF@:(7Jn*U+$ukFHp=YoQDqZX2Zx}frwMJWZWJWK\x18pMZJF^UY4/j-VbW?^oVI:h:ltw[}[HGZYH[LGJP-K4GU^Z%tnOEz#}.nE7hq3dLi^VTO^hNVVTUkp(?xG4+%b%RU3I1*Lh_8CB-jLZMvQOJKkFOZooj[zUiT/mq5?gVlQkY1glEQLNqda$P?,2maLo3.^Q*bWLc^1R*2YZho$rQS[WB_E^TdBQ^C@QBU^SI^aremC+Nli0LtLQOGwq]jSOk23k6vwwZ?Q?g{^J,t*M;2GnIMYXUbMAI*A3Pv}8(no-E2+J=;j&yJ*XkGDGZBpz{Lt:]DSc!YtzY!&]0fULbtEzkM[SNL_Q1@?+nwlP3U4.Vf7mS!=o!lZXzuSKKIHo1vwpD9sN}}y51X4_{7FBCJp9Jl_HNSY[V{VS]TW_TNS19/AFC7V1/mE]ksDIP@Vb20hkX:nY3j_^p4{:V49)-kHjlW^MZ[Swi1CaBc}s+1*u1mBY}u/Q#%2~RT]ZGFWVJ5RDV3gY1Jj%hbguOG{XQ&rORJCd:zj/Z@o5af*2VwLT[GOzFK_9iTIQXg;sSz&+N^])Ilc$PN#z1Y:?G+wF[W`LOLQ\x10C)h06qPqQ[6g1Yeu_?Af83!^{%mXQls2g4e@FvEm:;3oGh7ql?##'$mxx3>$48%3y00x1d3\x1d?\x130.\x03&{TOXNZ,m7ePq;)^:ZRQwY.b:!*tqcXVYEr^_EC^]x0o-9xY.M#70UO^BuBOVFP.Lb?EX::)j].WzLq)mwYm+jIKCOZG]FLkGDGZ\x1b5B#E*L[}Ig*gZG_VNo@wbuNm1l]Hyo,x[PdO8*xTUU^XO+LtJ-m7qrKVu*aYr7^R2/]v_3%XoP;74#6Ib,tK,8)VC6^QEXZepudV5M@3kOz1_S^6]U$/6v_SECUTu^U]IyTv#4+)+V}k@h?#'8df+n;dn$QwbD]hyL)$=Q#vWTSG^F&q.IW98/XBYnB&/COQ~JKPyJLZvQIZQKPMFzQKMVZLpMPHA^}1-5J)D-LMaM^7+4{a`TUN\x01bM@HL\x01`BIHDWDLDOURdBTCx_ADEeHAT%U8W15whgvt[@W6/ynAO^odMh[fK-5[ICn_BNjgGq_w?fMLoo;dxh4J`GGC[XRW}PwDRHyk,c/pP$iKFFHKIAFBxY+ki#K6h9@kt@AZw@AAZ[vZYZGBO$Q?BqS^^PSQYJM+8*#]6=u6[FCDBY^W4.EcX!!7Ff4!nxkJINZC[&7/RITS4D#tf/aCRuCTPOEC0[EJ&,}vcK`BOOAB@HVB:TjW$5PnmeTGP[A]k%OM07;%.*UZ`QL@w[X[F\x07{sK]dD_y|ZQKZMvrWA{T(jZcJfuPP`UVQ.:y4(GMDMq;zJHEL13(,d0bGrzhGvBCXsR[RCR~CRZ~SDfD^XNi^__DE\x1ahGBH@{JOOBEL\x7fD[OUBXdOjy^TUHrUXQFY_BEq[PBJ+eX#uMud89lBh^VKyPM|WVS[lJqwe@@pEFpYDc}D0.;6bVWLfRVJSbUBWBQ\x17652&?'M0KN0[]{&,3)5 .(fzqVI)oxLMV{LMMVWzVUVKh^VKyPM|WVS[2awJWOFO_t2C/;WiRFBGM{-19QO?Z+r]FQUfkxlcsFqqFRVFPWqBMHvStVKCVAWW5+VRHdBTCx_ADEeHATcA[]KcAXKCK@ZgBYT_BrUY/3V^lFJK;s3he!^MnZ[@n[[NLDdgvGBBOHAtOANRuWZZTWU]S1H=.(?4>34=w/*7eS[Ft]@qZ[^VcD_bTCGXRTlRl]FOMGFdGJJQlM`KBMDFG*9gHENITvIOHRvSScXPP[Rp(-xatomr,cC)zWOYCByDRSD)I/EY(fIm[3dF[SFQGG9zS{JW[mZ[[@AkN]DRGN+V/xPKW^R}PS[T@]_}TTAWF{ZY^JSKkcKuDAALKBqJUrU@OE2)K)#fDUrDSWHBDvAUQAWPA@vQIZQKPMFtVKCVAWWAwCBY\x16pWD[rDUw@MTDRnBDMJWVGFg_F^CFulz|^CK^I__}B^DYDBCxZGOZM[[\x00\x00\x00\x00\x00\x00\xe0?\x9a\x99\x99\x99\x99\x99\xb9?z@_R]WzWyFZ@]@FGvNSMEFn0ffffff\xd6??4&+J9Go|^KZXPMFuWJBW@VV|]^YMTLhIJMY@XoIK@IaLrHWZU_HCRPXRTVeIHHCERbLPjFMLvJG_CTUvPFF@VVNIOTSZrPPV@@rEHQAW{LAXH^`]@XQLeLLYO^qTXTRPl@BMN[nHPPRS[NMCJ)*;-4~C^FO<30<4yDYAH<?.8!eXNOX*)8.7lQLT]fAT[QFETB[clampQGOR\x88\x7fr\x1asortta\xd1\x0e~DWH{\xae_\x02G`\xab\x89V_Tn,:2/xDIQzIKM)==6gCWRcYJUq^ERiHr\x1f +9=6$7 5OBB\xcc\x01/X1)\xffZJI\xffP\x0fV7W\x11\x12u2_"))
local gi = (buffer.fromstring("5))-.grr:4)5(?s>20r\x1c>)(<1\x10<.)8/\x122:*<$r\x1b1(83)p\x0f838*89r/818<.8.r1<)8.)r92*312<9r\x1b1(83)s1(<(fWRR_XQd_Q^BVMi[qGCH-VdOx2oK^2{7_*t?;e14#Li{TQQyTOX^ITRS^Q(l^j-G@7Pe:v1&Gm!#}k82cfzZ~PYXERpB^~YDRCHrpG!!6+ynG(.4.it]Luxw9gnNlIIyBJJAH6].WxKic&yc1:,ieBlwR]5^Tbs)bw0vTYYWTV^W9@.:i1?8}f7A:D$;20V4u8ZnS&ku:kMODM~IKE_X^ULiFUbE^JIl+jcuniq[IPLj4B^QNDVB@NC[CPVp70Bwr/4r)n/JI{(yO{O[+#roIZUHKZI^UXBYwGv_6#AM5$t3dXB/c()oQ0FeAYDRxK2b+h=cbq-aoW,r4TkB!7Lq7eBj3#7)3.2210+=6;;.}DPPN3-fl,f/2Iw+}*(*XhlKVM^KJPEHeHMCJIAJP;^HmUT5TG&a.VK+]vTYYWTV^AI5[8+v)F;22XR[?bnaAw@#NOqlJRRPQATo@YcjZRNlKm3y_&l].KlLQE1GM^JWUw^^K]LebHZ36,&!Q_#!4t#oZkPjm{kTHRORTU12/N]cGXoj_:71,vOdV1*/B*AqED_uAEY@qFQDQBX&AAJ$V)0-bNNX+xj`K@HL@VI/q0#T0(F!l-o:1x@]aS&iN-NlCXO7A]xot5?hsYh,}=QBx(]st=$?[0sW[]_Xmf8Rz9NY{M*MCNWi4Sb/+9x%%hYYEPz][FBLdFML8nVli7I?R80a_t{IXSAtj;#.82m?G[[}at,FzmG}TgzlEEYzEYC^CEDR18nir6clG&8x@iwo8_QNF0;)9}BeYsipdI-ao_101XSUN_Au.1(TGOXQRLEi_?6e/@.4EUp]FlGBYXPSXNZGE{KIDM*h*f.fW^tKI%5RN&WPyRwVURF_GPV+3hbMHvu_BiZqC+A9*N:zKKWBhOITP^vT_^#pGFzsB-Z^}h{`EEeSNQENVO*nw}:[&*tUVxSvyU4&6,5''1 =0n{{me`dddlbagldc`pUUe^VV]TRbO_O4,HzDBAWM%gJ6AE]@VAo&e@BIT&tf,IMWEKpv^_@xNF[i@]lGFCKLYA4*vQAo]{bP*(zMZOZI\x1bhOZO$[&L!as,gR+Xn]L^H@]e9F_hs;G)K?npzz,MV}sYP~H@]oF[jA@EMUC++5%jKA)q{btXZGVY^XY@cmTKd)gB(u(I0$quA@[g@[DV^%TUPQ2KJH}f-slvWTSG^F5khkFk]R:Z1p8Q9g:vBCXt[V^ZvT_^RARZRYCD!zPWQJMDhIz(RV4b0HdDM4{BBXMN@IJttZpZ&U1fg)+WE/.j7!)4?cW06mlbbuZGDd[ddcsPRZVC^D_UeCP_BAPCT_RH`|vZG[PGt#.476tW4V7%sT2$,1uj+mrEeqvfT5Y7t/lMhJPV@gPQQJK\x14fILFNsx3f~YGBCuRPVYKCw=!YR;cHguAFZGQQ5}=@UuMy!wS#?sOOK|^Ob=$OShD5ILpn{{AF[V[F[G\x14vMDUGG]ZSbMVAHz7Is%:x0mjt5k7lKVM^KJPEHeHMCJIAJPrU_^C^IH7t,b3=9YEyY]B[_oR^ez%SPYh:Nlh_JVSY[N_^iNUH[]_nVOWJik$[4onEH]h_BI[md0XK2dB3+zfIAeRG[^TVCRSdCXEVPRaB@HDQLVMG`LOLQ\x10mZMXM^aCHICQMd$XmAC^O@GA@?Gz9zN,hRM@OEhEI(fAZiQ]}LQ]}[HGZYH[LGJPeQPKfQPPKJgKHKV{KIDMv/tB%Z.%:v`FPG|[E@AaLEPe&\x7fROYXOnTGXmTEXQoD^XCOYje6Vyaf~TXYhc}ch/a&JVnLAAOLNF[7NqHTU^L[LlrupS-LiFODS!7_$jwnz0[_GZL[9s2T/FSlpjMKVR\\d1F:p}LIIDCJoBYYB@eGZRGPFFV#k({MEXjC^oDE@Hq@SDOU+uPYyndGV@YrYRZ^RD|^OzOOIRYNO^}[HGZYH[LGJPgVAEPAsMJ@KSuW@]BU@QPf}a>5'Otf0:mtKj~ZHRU\\hOBW^[NMCJu}htOMy[JATQ[0uF_d@RHOFrUXMDyXN^OTMITRS{WQVK.k8fOo0;)@a7Qy5^pjMVk]JNQ[]iNJ^_ReJFN}_ECUu^DUBEQLNlEEPFWfHQVaBBAGP|[E@Ap[QPQkZSZOPMKv[d^MRpHauF,lIIoXYYBCk_^E\nlKXGpWD[aYDZRuPP`[SSXQsTL_TNUHCxLMV~XZQXrC^RjGDCJdQRgYTDXkIDDJIKCzL[_@JLZiXEIyU=[qSNFSDRR\x9a\x99\x99\x99\x99\x99\xd9?}HSWUSH_qED_vQB]sQLDQFPPosiNHUQ_rP]]SPRZnOLK_F^~WVLq.h}L_HCYOa@CDPIQgFEBVOWsRQVB[CI]@B}hm62$18'(uY[TWB% 5&32?bNLC@UrWWgRQvL_@XDaV[BRD`QFBWFy]QWUad_VERSyH[LG]KHYOV}@]EL# 1'>LO^HQv@GFPaGENG~JMQLtBEDRxSPOOz^RTV~F_GZBAPF_{90\x04\xc5\xd2\xc4\x04\xe7\x1fP\x05@T@T\xcfQ\x96~~WVL\xbeY\xf11yS_^XNF[:\x03\xb9b\xe8\xe9.\x03`DPUM[SN\xc5\xfcF\x9dTBJW<7%338R__uZGHCQFM_ye\x196,?N=3\xa0+;CTwMl,5"))
local gd = (buffer.fromstring("sPRZVC^D_UeCP_BAPCT_RH(W)=Cwn-4m5[r20I3[;d@Zx;}@G0t96gSRI\x06eJGOK\x06bGOJ_\x06tCQGTBUB0u$^]}W@/?]&5C#+*;#v@HUgNSbIHMEHsW=DHj%M:w4[S?lp5PBO3v@htPvH!\x1b7(1=+x,0=x16.1,=x4163x,7x!7-*x;41(:79*<v\x0b?>%j\x0f;?#:j\x08/9>j\x0b<+>+8:_^:WtggpRn]CHr3ruyj0{eem&),&.e1*e&*5<lJ#bfMi8FmYe,M*ty,d@G@D@SLbLPVtD=mQ$5Rj#p2FS^Uon7}vX8,](xZWWYZXPeq/pl;dfcJjboj**$FB@(7H=sup=UdYAMBCEH~CCX|M^XSU?Vkpn*7Pq6[Ge:f9tksEMPbKVgLMH@5w@FImZe.{*nvx_%[,{W2SxxjHEEKHJBzkB7%9A,6eWk8l)o]^Lz*1F,p[KeC[[YX9qtsVB5uGbDGx(&1Y/fi!*3efDO_3RF^G]]FV*3;{]PO[8/?a*l^EG_QtX;(L79&:1#Z:XF%$_6UOVA)8CvX_+B=Hrb4=s)g9OqSNFSDRRyb.h[Rkd4QFoG%xF]L^HOBV:fhJPV@gPQQJK\x14,YF,VN;:%@UL)rDlTj-*cxZKlZMIV\\ZY9Z:80tU%wI@-**sS+/mfXs_B^UBbQTYEC:)^eDAl{-O%.oxle.3X;38*pX7Bh;?^1:]zV@0gY8PbT,nA2.$/vxN_}JG^NXwUE!,PavOF[9zl%55NF6y/zYUWZfZWOSD:C6$]XnM5WI.Jd3nxD{dyUWX[NFcE*BgnG-N8QiM!(vso[bSnX@kNN~KH?sZMKKv7ai)e:d@pOC^;!To/4WOMSCN!^]ePEr8c$RHr&#2hr,.8^{B/(6613N+7t1L}QU)$Leq6c&$U/xz+Z|ES[7OH]{L,m](yvkf/ncSZ]t1vwDnM__Ti_HLSY_pXP!T-Bk1/$yCJ!pp{CZB_8#[@L6:tKt2Hq]e3]ybt%Ho+83!VheX&LR$IV2Pmz/:5Hx{Up-+RmBNF,Zx[6+_uFv)y-[r%j1N0W2{G'.%w=AYzbzHha(Wq2xy+sp$tiK&%#4?58?6|$!};aAHMnC^TDU8#&kMYDFyliSWxuj2m3lzr?@@](yPJS'7-4&&0!<1ozzldaeeemc`fmebaeS[Ft]@qZ[^V+Q3?/whWbDQQvDkIBCV;jj;_nrc!telE&m6SF{RnADHCYZs:e$?;2m[-M*.9lIe1a}dUPP]ZS*/DH(;tT/UpNJ5zmeQPK\x04gHEMI\x04`EMH]\x04vASEV@Wm~YSROuR_VA^XE&V=8@lFby]oj^MAIY[-nr}!Ao/dN=Xi=-qFRVFPWgBJOZqFTBQGpWBWF{ZY^JSK7cn+Gt_II:HO$SV1wTV^RGZ@[QvZYZG\x06LL0W_883!6x4!y%uxG7IqH8*3E:;gSRI\x06aGENGzfS$!(65i4dD>5'MTph$sY3P7y7=Knk_7W9,/!(%f0#cKiUlV^tJv,Z:$30:(-m.Zcm1BKL$7xUj^_DoNGN_Nb_NFbOXap;XZKvLS^Q[{VLOS^Fq^RZm@XNTUnSEDSgT]wJK7!sojOURjG_ISRrRCEy.EuEGJCr_VCix;9U6dZjs>=,:#%?:zF#e2*!fq:{ZY^JSKxm^]Yt)vS,eNIO:ZtrIkT8GNoy]HVoSRXPU^HHt@)#zMTz5#+6.%gd72Y;w9&ceyDYAHvlVr)&GrNjBrqZ@F]QGmjlEj4zQW`sT^_Bx_R[LSUHXAfZWOSDfYASD*k_WB~Q]U}v%$5B%Mr(UfgEHHFEGO,yYkx7ynSGZXzSSFPAjp2U6jBYEL@`HIDX@2Y$uf<wiia*&9 ,-h`YOGZM_[-j1IT.kSo[ZACOZGM}GTKmv@HUgNSbIHME5odF[SFQGGIc?Bb-dPQJHDQLFvL_@rSPWCZBj){-vBtRDShOQTUuXQD0*61 ET.t]ak-bZGYQT#xHGH?[lXYB\r\x7fLCF\rx]v@HUgNSbIHMEvQOJK|W^QXZ[`QBU^Da%wN+rkHYOV}V]UQ]KqGOR`ITeNOJB}KC^lEXiBCFNo^IMXI{EBHC[}YUSQvA@@[Zj^_D\x0bj__JH@hNVVTUlTIW_lIIi_B]IBZCkZGKhM^OOZ[ZQCCErt:zmxj]JBGJIGN2^wTXZWkWZB^InKK{@HHCJcSGZXzSSFPAkIDDJIKC/^q@SDOUiuOnzXInXOKT^X~JKPlK^MK:uWMK]t]YN]j^_Dx^FFDECWJHvFDI@`TUN\x01gTRDkL_@hCH@T0;)WmqtH^NZGE{KIDMsVVf]UU^WzB_AIxSzLfYE_B_YX\xcd\xcc\xcc\xcc\xcc\xcc\xec?ZYH[BELZbDSeXE]TxR^_-:^:`FQgZG_VzKXOD^}QlG]@]P`MtHE]DGxPjvlKMPTZjV[C&LNOwCBYpCES`LQFdVJxDIQMZ[gKVAcQMnBCCHNYEQLNqdaMYDFyliiL@LJHA{WVV][LO8PO&?_X^EBKxI^ZO^iXOK^OiEGHK^`SQWO{<+,.9'<9#$^=insertrYRZNzE]OXnSNV_oS^V^hDGDYEH^QO1094,iUXPXrJSKVO@COGf@BI@uH^_H1\xb6\xa8w\xb8\x9fTvX\xe1r\x0f\x0b\x96\xd2\x12gZYY>( =V@HUf\xda\x8f\xf8DRZGw^_EGQYD)Ms0gNOU\xf4i-\xed\x1f\x03\xa4\x81ODVp_B&-?5*.#(:/$6OqD\x16%:\r@\x03H#\x14m\x1c$\x05\x08\x1d"))
local f9 = (buffer.fromstring("\x08$! e\n07*'*7*6e\x08$7. 15)$& ecce\x08\x08cne}o#Ofx9FTv4!TQmiRPAaGTV^PQgPSPGP[VPFEe40Y,O,xcOl;f;{a9iZOBz9Lv@GGP[A|FYT[Q=xu3Q.,fO[A3y6Xcoat4nYOvUEDcR_gQVVAJPmWHEJ@}c?D!WDUywUgQv=:jYAOlApRvbA$f@BI@`BUHNO=sJpd^Xc#rCaPejJk1Sz0MEFdA/V$cAPePPVMFQPAn:X;}t^oSd1(emDou)4A7r0BIt\x17243}\x194.>2/9};2/}\x19(-8.r\x168$18..}\x0e>/4-).k_^El_YOt0*c}Ols/2fixGrlNQJFXLoXVysX(n_HLYHse/]5J[$,w2;^55[9^SN:he&:ejri,zKXOD^$Ij+NkZ{5C)46QI)4v)?Y(SO-dB+tbht~ROSXOr&#_tzUf6U#f?u6rrv@7Oc:)y=ffEGOCVKQJ@pVEJWTEVAJG]=eNQz_lr}5P2I|ZQKZM5pWblGa0X/}U5H^8MYTI8cJE8vsSoNX_YDR*fWD$%U%jf/QI[GvgtJhKPcVe(8`OBJNFG]oq!VK?7@M/#EuEGF5MA7K),vC]|[E@Ap[QPQ(LV{=Ui$U+9,]]c#mh$xVm;|ZBB@AnL[F@AZMK)3=rIt^Hr*Nr-+,(]]ITVhXZW^S*LjO$%nKLcF3yB(Lc!Rr+TmKIBKxOMCY^XS*9vISozZY/C4b^QJ4:om$oraRmC9)je+EFrOUi?=6v]]QIRyaioCANMXb!3V}3pMtK(%eqhtxwi_&/O;9qTTtB_@T_G^VG,!P5(.vLg:TKfd%cYQnKKk]@_K@XAW4^nJYxObBT,qzX+HV=VnrxTIU^I-.V7c_u6@]n:oYYqKd=NdH}$O4_rGCPFC9(llDt1Vk%}p+rN%A$]kIXmXX^ENYXIm&h=/SV]8h^w44JRY~E_IBwZ/X]0ZSz_ghOxUO=p=v?mFy~GQYqX#DzJ^W5^QHCIOk}STM1!x7.wXCT{{gFsVdy^-XQ9tOsyjqJ0w5;mK]JqVHMLk]JNQ[]dLASrTbO)1kKT_Mf=hwSFj]-%:P{_LH$qv9d4pK~C^FOj0OEoFjy-hr7to]#$W[)]AvSSsEXGSX@Y%p8wD$Ixe.WtFDRKrVQVRVEZ9oPRV{5G0=V5TQn72sY?4&S*}KhTmOvKU_N[klO_6SrU@}ZIV~U^VB8,H9Jp]c3LS3KIVwkIXmXX^ENYXI*qN,]q4wj6o?Z~[[{MPO[PHQml:jh[:b]!W1lOlNCCMNLDD].}fug$zu0,o1g6bq+`~~v=27=5~*1~=1.'wGB?I]@B}hmf8_AGN0sA6P(uIM0e_LS=p4]&lyve+S,eL9U4E/~XKDYZKXODISbaORHB9S+&*xSXPTXN2]h(J$N@-qDXeX?]VDY)/Gm55FFFniX2nK2?FhYNJ_N2Ws&(?gscNakv9}t{TXP-Q6IM3KHnSGkJR.2teTGP[A%A=%(ICJa.[7q}NlQLT]}fsw5M(1/a4v50Y8cJJ_IX{Ly-V&bgxHgHExACRrTGEMCBtC@CTCHECUrDLQcJWfMLIAI)64+f(~EKDXoCBX^C@*y$6BBch]FB@F]J%d-uI[=Zsnrl[VO_I.fho@=^I!6ZggFEBVOW*A3#2SJs{GidBZZXYvTC^XYJv2$u3gEHHFEGOJ*UWF-xBJqSBeSD@_US;c(VtKsb@UDFNSX7Qpt?aNQqTTtB_@T_G^zh$S6}G@]P]@]Af]UU^WI?4&B)tc.f9&Nt3[gn^OXXSzHT+4Ks+?raFLMPMZ[AYOTb[?rrHOR_RORNiRZZQXa[DIFL[xmeRu:bLiDYONYxBQN{BSNGrVD^YPs^ERTC^XYpFAAV]Gz@_R]W8pXC_VZdRZ^UX[SgEHHFEGOG*M4x0~I]YI_XIHHb/(v@GGP[A|FYT[QbDRE~YGBCcNGRbMHH`MVAGPMKJnKK{@HHCJ.e!uoUg!.R9j^7g%pFWbWWQJAVWFxNF[i@]lGFCK`V^CqXEt_^[ShMM}HK1#Y}YtiD^]ALTb_IH_kZI^UOSmeklAj^_DoJBGRC64qZQYM$*cFnJA`UU@BJrQDDE'19$HtDm0=$wZBTNOtI_^IeJGLKVtKMJPjOOoYD[OD\\EuDAALKBi@CQl@AAJL[cWx*vIQCTG[/E}\x178#4$rA}Vrp]xL:hAZVTvTEbTCGXRTdPQJwDKNpUQEXZxQQDRCdPQJvPHHJKvAVCVEzXSRfZGAzGQPGiUT^VSXNNtQQaZRRYPyXu^WXQSR{^^nU]]V_tSKXSIRODLXEGyIKFO{_X_[_LSfL@A%F)$mOBBLOMEoM@@NMOG\n\xd7\xa3p=\n\xe7?\x9a\x99\x99\x99\x99\x99\xc9?.-</618.wLFMq@]Q}_BJ_H^^lNCCMNLDoPLVKVPQ\x00\x00\x00\x00\x00\x00\xd0?bC@GSJRwVURF_GLXFMDBV)8:28><iEDDOI^uTBEC^HwUDOZ_UrORJCP}nSNV_th_H]H[0;)2R.~[[k^]hYJ]VLjA[F[Vb_BZS^iOWWUTq.fl4Z/:97>jROQYkVKSZqLQI@gS@LD{CZB_cHKTTlXKGO,'5$LbDFMDg_F^Ct^RS6 (5&08%j^YJ\xdb\x96s*I\x9f\x96EeYTL\x1a\xb6s 7<.O\xd25\xa8\x1dgENOiS@_C[r\x1drXTUgVKGoZ[PfWJFrep <4.%7d^l,\x01X\x02[B\x1a^\x01&(u*8U.\x13\x0b\x1e\"\x18"))
local f4 = (buffer.fromstring("sGF]\x12wCG[B\x12pWAF\x12sDSFS@$&V!,U?0bZX3?a3jLEUOk8j:9ayVQU]\x18mTLJWV\x18kQUMTYLWJvOF}xTBqZDn8^EF:XJvqUryijbm[SN|UHyRSV^L4J,!.q/U*z70Hke&I&}fx/yJ2O=$QbVWLb@KJFUFNFMWPHL2lOp?=%&soC1}nwx#{lK)i*iY[V_nCJ_ETVUqearu6mMrgag[!b^U-yvLgl.&DavUW_SF[AZP`FUZGDUFQZWMl$W*DxWmZn%PM{A*bVWLgBJOZso/S]Gk7yZ}k?Ce2Tp=9nvXW:)rOjgSRIgENOCPCKCHRUV7H:UDhN}:s^ok(CG(YPyhDYENYyJOB^XPcxn}-}JO8a:IT(2?x]-iU6bjh_WUN_iOWWUT^ul2{_9ZZ#.GYU!jiFtYplUZwQSXQyT%qt2@-2.KCmN@x3Zrg?d-:Gi!F5]FRTCS(=rDfIekUUim:}mMmAYJ2Of&XMr7da|]^YMTL6x(Vks9q]LFKHJm}c8]Ll%*R{uXsDIP@VrC&5(IY^yK;1xxDk@SXbb/MXVWe=k_^EmKIBK-;/H]u.7Tz7-8HMZQjAbZZs+zKVZbOLKBh#!=j$!J+Ph[,!)*Cx]O@csJcNWbVsWZ[3JzbtEIQ1q]7eX6Nd53vSV-6aWFdS^GW7EB6mJnEaaqM@[Rdfz&cf*58>5'Y!$CGy%zCS#0,gYgg[&G*Cn&,HllTvTEbTCGXRT7Vx}P&)asvG@-iX5RE=)5oD^C^ScNlG}Kr?N1cam*tUpxE=6IDe;aB@HDQLVMGwQBMPSBQFM@Z!2Q$OD5E..;86?vGV.GqcXjH4DbhTBqa$Mv{m_zkx_UTIsTYPGX^CW-55okpk?V1;8@eyuDSWBSQH:k8j)e{:1H-xjcS@!lvt9K-<7:1?4)!?UKTym8#fIziOGC,p}gNcLW@%8YxvI;#x6d_Dw.xQh+2UspJowUDcUBFYSUY(%mb=I@P73Ufd6rB;XgAYY[Z9V^i,Uj#Ay5SPJGg]w*3Jqh^VKyPM|WVS[WZaA5^Mw;c}{xx0TyV[SW~[SVCh_M[H^IGT@6-)3X9^y^FU^D_BIR{HnZg!x{(,G&]w6nhjEBHjE^_XoDE@H:%AT%R{$HsN:#\"2(1##5$94j\x7f\x7fiad```hfech`gdwTV^RGZ@[QaGT[FETGP[VLnw2AqLQI@3psY^]5G-}u?0X_[)MzWqPST@YAF--#+YbJj8%vIaCAEzpVNNLM3,^=caVWpP0C=gVpdZz{ONU\x1ah[TQ\x1aoJzgTX{;!^RgcNpHQITmUJMH{wQ#)9Mf,SYOQh-;3.ue)Las6%rK[x!P#0n36LvPRYP\x11f^C]UGB+8fq{_.Z-wo@[L9:63XN87/MWG&?(1ef[rQS[WB_E^TdBQ^C@QBU^SIgPD@PFAvTATYZRaPYPEZGAyCPOjUqFvYhyVv.;9CcbTUrJSKVpbz8HO^&v]Z%mL*jxEX@IRPGi8BC7XOy]C(gM~H_[DNH^J1nS&uHIlsA+1wUXXVUW_z}op]bdDR8;jC^^EZNF^ME2A!CjyPu-lb_BZSLO##aD+},{/ZE.xTIU^IiZ_RNH-y7ppp]d^YDIDYDX\x0biR[JXXBELEQLNlEEPFW83,h,ApOiQHPMsBRiJ9Ong2iIj9/':}{JVn4AUtH5=zJtRDShOQTUuXQDND3AeBBF^NI,aL(}O,Wq:r[Z@aGy$)iNaiL3_c[FXP2NR4YUB/b3lx^H_dC]XY~H_[DNHlXKGO?9}OPg:TkBql]@LlJYVKHYJ]V[AjMUFMWLQZVnSlT,^yHAH]B_YnLYLABJWUDqDDQS[bQTYECQWP;Zq,{MQsBrD-wCDW0d-VyB8!.z3yUHT_Hh[^SOIVZdFWgFP@FMGBMWPkCXDMAaIHEYATogBBbTIVBIQH;LZSX7sgE1K2?T6zFKSOXyIXCZ^Yb^SKW@aQ@[BFAsUCToHVSRr_VCpUUuC^AU^F_rdC]XYnELCJHI|K]KZa@}^OY@lZRO}TIxSRW_iVJPMPVW!n4bdFWbWWQJAVWFuVDDOrDSWHBDvTEpEECXSDETtBJWeLQ`KJOGaPUUX_V}TWE~I^K^M\x1flK^KdAAaWJUAJRKiOMFOoMMK]]aKGF!,N2;[]y[VVX[YQzdNsWE_XQeBOZSaGENGqITJBoHVSRdCAGHhOK_^SdKGOwLV@K^0%fqK_B@bKK^HYt@AZtAATV^f@BI@hEv.JsQ@gQFB]WQmJRAJPKV]j^_D\x0bm^XNxO[_OY^ONvJWQjWA@WgFk@IFOMLkNN~EMMFO{KIDM|QXMjHEEKHJBb@]U@WAAfDYQDSEE{\x14\xaeG\xe1z\xa4?\xcd\xcc\xcc\xcc\xcc\xcc\xdc?qNRHUHNOfSPe[VFZnLAAOLNF`TUNg@SL\x9a\x99\x99\x99\x99\x99\xe1?hNLGNfKrO[FD{nkPDY[dqtyHMM@GN:9(>'BvoCBBIOXpJAOJMDzTHr^UT 7$7 !7mA@@KMZ}L_HCYq]_PSFgKIFEPjLTTVW|KF_OYgVERYCsDIP@V{JYNE_a]G@QWlJRRPQ30!7.GDUCZ`]@XQ{@ZLGtLQOGc^C[ReXE]T`XAYDeIJITgZG_V\xff\xff\xff\x7fjV[C\x0c\xf0\x15\x83bXKT\x9a\"ED\x16z7q`ZIV\xb4\x1dl\x88-\xcaW\xe2nTGX\xb2\xce\x08\x1b\xa2\xde\xc5\xd8~[HQYOGZa]PHz@SL\x97\x98{\xcbU^LQZHm$o{^F\x05\x15\xa4\x01!FAYRSK\xc8\x0e\x1f\x04\x06\x1b\x07L\x17\x0c"))
gD_1, gL_1, gO_1, gu, gI, gn, gg, onCallback, gH, gj, PlayerPower, gF, f6, f0, gM_1, gE_1, SpawnEnemies, gA, gN, gG = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local gK = 7
repeat
    gP = (gK * 14 + 8) % 15 + 1
    if gP <= 8 then
        if gP <= 4 then
            if gP <= 2 then
                if gP <= 1 then
                    if gK * 39825019 + 6 + 6 >= gK * 39825019 + 6 + 6 + 3 then
                        gE_1 = {}
                    else
                        gN = {}
                    end
                    gK = (gK + 14) % 60
                else
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 19), string.byte(tostring(gE_1))), 24), 2395506153), 2288786868), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 19), string.byte(tostring(gE_1))), 24), 1899461142), 3413874839))), 2288786868), 3413874839) ~= bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 19), string.byte(tostring(gE_1))), 24) then
                        gn = game:GetService("Players")
                    else
                        gD_1 = game:GetService("Players")
                    end
                    gK = (gK + 29) % 60
                end
            elseif gP <= 3 then
                if (gK or gI) and (not gA and not gI) or (PlayerPower or gA) and (not gH and not gK) or not ((gK or gI) and (not gA and not gI) or (PlayerPower or gA) and (not gH and not gK)) then
                    gL_1 = game:GetService("ReplicatedStorage")
                else
                    gM_1 = game:GetService(game)
                end
                gK = (gK + 29) % 60
            else
                local gQ_1 = (vector.create((gK * 5 + 2) % 11 + 1, (gK * 6 + 12) % 13 + 1, (gK * 7 + 8) % 17 + 1))
                gR = (vector.create((gK * 5 + 8) % 11 + 1, (gK * 1 + 10) % 13 + 1, (gK * 8 + 8) % 17 + 1))
                gS = (vector.create((gK * 7 + 7) % 11 + 1, (gK * 10 + 8) % 13 + 1, (gK * 12 + 7) % 17 + 1))
                if vector.dot(vector.cross(gQ_1, gR), gS) == vector.dot(vector.cross(gR, gS), gQ_1) + 1 then
                    gu = game:GetService(game)
                    gI = game:GetService("TweenService")
                    gO_1 = game:GetService("RunService")
                else
                    gO_1 = game:GetService("UserInputService")
                    gu = game:GetService("TweenService")
                    gI = game:GetService("RunService")
                end
                gK = (gK + 14) % 60
            end
        elseif gP <= 6 then
            if gP <= 5 then
                local gQ_2 = (vector.create((gK * 5 + 5) % 11 + 1, (gK * 3 + 11) % 13 + 1, (gK * 11 + 4) % 17 + 1))
                if vector.dot(vector.floor(gQ_2) + vector.ceil(gQ_2 * -1), vector.floor(gQ_2) + vector.ceil(gQ_2 * -1)) == 2 then
                    gD_1 = gn
                else
                    gn = gD_1.LocalPlayer
                end
                gK = (gK + 44) % 60
            else
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 3), string.byte(tostring(f0))), 21), 2309709895), 1145381530), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 3), string.byte(tostring(f0))), 21), 1985257400), 765196650))), 1145381530), 765196650) ~= bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 3), string.byte(tostring(f0))), 21) then
                    gM_1 = "https://discord.gg/K7Qxnxkk46"
                else
                    gg = "https://discord.gg/K7Qxnxkk46"
                end
                gK = (gK + 14) % 60
            end
        elseif gP <= 7 then
            if (gK * 1 + 3) * 17 % 4 == ((gK * 1 + 3) * 17 + 2) % 4 then
                gE_1 = function()
                    local hn, ho, hp, hq, textButton, frame3
                    local screenGui = Instance.new("ScreenGui")
                    screenGui.Name = "TempoLoader"
                    screenGui.ResetOnSpawn = false
                    screenGui.IgnoreGuiInset = true
                    screenGui.DisplayOrder = 2147483647
                    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    local hu = gethui and gethui()
                    local hv = hu or game:GetService("CoreGui")
                    screenGui.Parent = hv
                    local blurEffect = Instance.new("BlurEffect")
                    blurEffect.Size = 0
                    blurEffect.Parent = game:GetService("Lighting")
                    local frame4 = Instance.new("Frame")
                    frame4.Size = UDim2.fromScale(1, 1)
                    frame4.BackgroundTransparency = 1
                    frame4.Parent = screenGui
                    frame3 = Instance.new("Frame")
                    frame3.AnchorPoint = Vector2.new(0.5, 0.5)
                    frame3.Position = UDim2.fromScale(0.5, 0.5)
                    frame3.Size = UDim2.fromOffset(460, 0)
                    frame3.AutomaticSize = Enum.AutomaticSize.Y
                    frame3.BackgroundTransparency = 1
                    frame3.Parent = frame4
                    local uIListLayout = Instance.new("UIListLayout")
                    uIListLayout.FillDirection = Enum.FillDirection.Vertical
                    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    uIListLayout.Padding = UDim.new(0, 8)
                    uIListLayout.Parent = frame3
                    ho = function(x)
                        local uIStroke = Instance.new("UIStroke")
                        uIStroke.Color = Color3.fromRGB(0, 0, 0)
                        uIStroke.Thickness = 2
                        uIStroke.Transparency = 0.1
                        uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
                        uIStroke.Parent = x
                        return uIStroke
                    end
                    local function hv_9(A, B, C, D, E)
                        local textLabel = Instance.new("TextLabel")
                        textLabel.BackgroundTransparency = 1
                        textLabel.Size = UDim2.fromOffset(460, B + 6)
                        textLabel.Font = C
                        textLabel.Text = A
                        textLabel.TextSize = B
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextTransparency = D
                        textLabel.LayoutOrder = E
                        ho(textLabel)
                        textLabel.Parent = frame3
                        return textLabel
                    end
                    hn = gg
                    hv_9("Made Tempo Marketplace && MM", 26, Enum.Font.GothamBold, 0, 1)
                    textButton = Instance.new("TextButton")
                    textButton.BackgroundTransparency = 1
                    textButton.AutoButtonColor = false
                    textButton.Size = UDim2.fromOffset(460, 24)
                    textButton.Font = Enum.Font.GothamSemibold
                    textButton.RichText = true
                    textButton.Text = "<u>" .. hn .. "</u>  (click to copy)"
                    textButton.TextSize = 16
                    textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
                    textButton.LayoutOrder = 2
                    ho(textButton)
                    textButton.Parent = frame3
                    local function hw()
                        textButton.TextColor3 = Color3.fromRGB(170, 200, 255)
                    end
                    local MouseEnter = textButton.MouseEnter
                    MouseEnter.Connect(MouseEnter, hw)
                    local function hw_6()
                        textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
                    end
                    local MouseLeave = textButton.MouseLeave
                    MouseLeave.Connect(MouseLeave, hw_6)
                    local function hw_7()
                        if setclipboard then
                            setclipboard(hn)
                        end
                        textButton.Text = "<u>" .. hn .. "</u>  (copied!)"
                        task.delay(1.5, function()
                            textButton.Text = "<u>" .. hn .. "</u>  (click to copy)"
                        end)
                    end
                    local Activated = textButton.Activated
                    Activated.Connect(Activated, hw_7)
                    local hw_8 = hv_9("Join for Dupes and Keyless Scripts. Dupes will always be announced and never gatekept in Tempo.", 13, Enum.Font.GothamMedium, 0.2, 3)
                    hw_8.TextWrapped = true
                    hw_8.Size = UDim2.fromOffset(420, 34)
                    hp = hv_9("Tempo Bypassing", 14, Enum.Font.GothamMedium, 0.05, 4)
                    hp.Size = UDim2.fromOffset(460, 18)
                    local frame2 = Instance.new("Frame")
                    frame2.LayoutOrder = 5
                    frame2.Size = UDim2.fromOffset(300, 6)
                    frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    frame2.BackgroundTransparency = 0.85
                    frame2.BorderSizePixel = 0
                    frame2.Parent = frame3
                    local uICorner2 = Instance.new("UICorner")
                    uICorner2.CornerRadius = UDim.new(1, 0)
                    uICorner2.Parent = frame2
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.fromScale(0, 1)
                    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    frame.BorderSizePixel = 0
                    frame.Parent = frame2
                    local uICorner = Instance.new("UICorner")
                    uICorner.CornerRadius = UDim.new(1, 0)
                    uICorner.Parent = frame
                    hq = true
                    task.spawn(function()
                        local hl = 0
                        while hq do
                            hl = hl % 3 + 1
                            hp.Text = "Tempo Bypassing" .. string.rep(".", hl)
                            task.wait(0.35)
                        end
                    end)
                    local hx_11 = (gu:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 18 }))
                    hx_11.Play(hx_11)
                    local hx_12 = { 0.35, 0.55, 0.72, 0.9, 1 }
                    for i, v in ipairs(hx_12) do
                        local hx_13 = (gu:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(v, 1) }))
                        hx_13.Play(hx_13)
                        task.wait(0.55)
                    end
                    hq = false
                    task.wait(0.25)
                    local hx_14 = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
                    for i, descendant in ipairs(frame3:GetDescendants()) do
                        local hy_5 = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
                        if hy_5 then
                            local hy_6 = (gu:Create(descendant, hx_14, { TextTransparency = 1 }))
                            hy_6.Play(hy_6)
                        elseif descendant:IsA("UIStroke") then
                            local hy_7 = (gu:Create(descendant, hx_14, { Transparency = 1 }))
                            hy_7.Play(hy_7)
                        end
                    end
                    local hy_8 = (gu:Create(frame2, hx_14, { BackgroundTransparency = 1 }))
                    hy_8.Play(hy_8)
                    local hv_11 = (gu:Create(frame, hx_14, { BackgroundTransparency = 1 }))
                    hv_11.Play(hv_11)
                    local hv_12 = (gu:Create(blurEffect, hx_14, { Size = 0 }))
                    hv_12.Play(hv_12)
                    task.wait(0.45)
                    blurEffect.Destroy(blurEffect)
                    screenGui.Destroy(screenGui)
                end
            else
                gG = function()
                    local hn, ho, hp, hq, textButton, frame3
                    local screenGui = Instance.new("ScreenGui")
                    screenGui.Name = "TempoLoader"
                    screenGui.ResetOnSpawn = false
                    screenGui.IgnoreGuiInset = true
                    screenGui.DisplayOrder = 2147483647
                    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    local hu = gethui and gethui()
                    local hv = hu or game:GetService("CoreGui")
                    screenGui.Parent = hv
                    local blurEffect = Instance.new("BlurEffect")
                    blurEffect.Size = 0
                    blurEffect.Parent = game:GetService("Lighting")
                    local frame4 = Instance.new("Frame")
                    frame4.Size = UDim2.fromScale(1, 1)
                    frame4.BackgroundTransparency = 1
                    frame4.Parent = screenGui
                    frame3 = Instance.new("Frame")
                    frame3.AnchorPoint = Vector2.new(0.5, 0.5)
                    frame3.Position = UDim2.fromScale(0.5, 0.5)
                    frame3.Size = UDim2.fromOffset(460, 0)
                    frame3.AutomaticSize = Enum.AutomaticSize.Y
                    frame3.BackgroundTransparency = 1
                    frame3.Parent = frame4
                    local uIListLayout = Instance.new("UIListLayout")
                    uIListLayout.FillDirection = Enum.FillDirection.Vertical
                    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    uIListLayout.Padding = UDim.new(0, 8)
                    uIListLayout.Parent = frame3
                    ho = function(x)
                        local uIStroke = Instance.new("UIStroke")
                        uIStroke.Color = Color3.fromRGB(0, 0, 0)
                        uIStroke.Thickness = 2
                        uIStroke.Transparency = 0.1
                        uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
                        uIStroke.Parent = x
                        return uIStroke
                    end
                    local function hv_3(A, B, C, D, E)
                        local textLabel = Instance.new("TextLabel")
                        textLabel.BackgroundTransparency = 1
                        textLabel.Size = UDim2.fromOffset(460, B + 6)
                        textLabel.Font = C
                        textLabel.Text = A
                        textLabel.TextSize = B
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextTransparency = D
                        textLabel.LayoutOrder = E
                        ho(textLabel)
                        textLabel.Parent = frame3
                        return textLabel
                    end
                    hn = gg
                    hv_3("Made Tempo Marketplace && MM", 26, Enum.Font.GothamBold, 0, 1)
                    textButton = Instance.new("TextButton")
                    textButton.BackgroundTransparency = 1
                    textButton.AutoButtonColor = false
                    textButton.Size = UDim2.fromOffset(460, 24)
                    textButton.Font = Enum.Font.GothamSemibold
                    textButton.RichText = true
                    textButton.Text = "<u>" .. hn .. "</u>  (click to copy)"
                    textButton.TextSize = 16
                    textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
                    textButton.LayoutOrder = 2
                    ho(textButton)
                    textButton.Parent = frame3
                    local function hw()
                        textButton.TextColor3 = Color3.fromRGB(170, 200, 255)
                    end
                    local MouseEnter = textButton.MouseEnter
                    MouseEnter.Connect(MouseEnter, hw)
                    local function hw_1()
                        textButton.TextColor3 = Color3.fromRGB(120, 160, 255)
                    end
                    local MouseLeave = textButton.MouseLeave
                    MouseLeave.Connect(MouseLeave, hw_1)
                    local function hw_2()
                        if setclipboard then
                            setclipboard(hn)
                        end
                        textButton.Text = "<u>" .. hn .. "</u>  (copied!)"
                        task.delay(1.5, function()
                            textButton.Text = "<u>" .. hn .. "</u>  (click to copy)"
                        end)
                    end
                    local Activated = textButton.Activated
                    Activated.Connect(Activated, hw_2)
                    local hw_3 = hv_3("Join for Dupes and Keyless Scripts. Dupes will always be announced and never gatekept in Tempo.", 13, Enum.Font.GothamMedium, 0.2, 3)
                    hw_3.TextWrapped = true
                    hw_3.Size = UDim2.fromOffset(420, 34)
                    hp = hv_3("Tempo Bypassing", 14, Enum.Font.GothamMedium, 0.05, 4)
                    hp.Size = UDim2.fromOffset(460, 18)
                    local frame2 = Instance.new("Frame")
                    frame2.LayoutOrder = 5
                    frame2.Size = UDim2.fromOffset(300, 6)
                    frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    frame2.BackgroundTransparency = 0.85
                    frame2.BorderSizePixel = 0
                    frame2.Parent = frame3
                    local uICorner2 = Instance.new("UICorner")
                    uICorner2.CornerRadius = UDim.new(1, 0)
                    uICorner2.Parent = frame2
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.fromScale(0, 1)
                    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    frame.BorderSizePixel = 0
                    frame.Parent = frame2
                    local uICorner = Instance.new("UICorner")
                    uICorner.CornerRadius = UDim.new(1, 0)
                    uICorner.Parent = frame
                    hq = true
                    task.spawn(function()
                        local hl = 0
                        while hq do
                            hl = hl % 3 + 1
                            hp.Text = "Tempo Bypassing" .. string.rep(".", hl)
                            task.wait(0.35)
                        end
                    end)
                    local hx_4 = (gu:Create(blurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 18 }))
                    hx_4.Play(hx_4)
                    local hx_5 = { 0.35, 0.55, 0.72, 0.9, 1 }
                    for i, v in ipairs(hx_5) do
                        local hx_6 = (gu:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(v, 1) }))
                        hx_6.Play(hx_6)
                        task.wait(0.55)
                    end
                    hq = false
                    task.wait(0.25)
                    local hx_7 = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
                    for i, descendant in ipairs(frame3:GetDescendants()) do
                        local hy_1 = descendant:IsA("TextLabel") or descendant:IsA("TextButton")
                        if hy_1 then
                            local hy_2 = (gu:Create(descendant, hx_7, { TextTransparency = 1 }))
                            hy_2.Play(hy_2)
                        elseif descendant:IsA("UIStroke") then
                            local hy_3 = (gu:Create(descendant, hx_7, { Transparency = 1 }))
                            hy_3.Play(hy_3)
                        end
                    end
                    local hy_4 = (gu:Create(frame2, hx_7, { BackgroundTransparency = 1 }))
                    hy_4.Play(hy_4)
                    local hv_5 = (gu:Create(frame, hx_7, { BackgroundTransparency = 1 }))
                    hv_5.Play(hv_5)
                    local hv_6 = (gu:Create(blurEffect, hx_7, { Size = 0 }))
                    hv_6.Play(hv_6)
                    task.wait(0.45)
                    blurEffect.Destroy(blurEffect)
                    screenGui.Destroy(screenGui)
                end
            end
            gK = (gK + 59) % 60
        else
            if bit32.bxor(bit32.lrotate(bit32.bxor(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 26), string.byte(tostring(gH))), 6), 53406184), 26), 2685189031) ~= bit32.lrotate(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 26), string.byte(tostring(gH))), 6), 26) then
                onCallback()
                gL_1 = gG:WaitForChild(gG)
            else
                gG()
                onCallback = gL_1:WaitForChild("Shared")
            end
            gK = (gK + 44) % 60
        end
    elseif gP <= 12 then
        if gP <= 10 then
            if gP <= 9 then
                if (gK * 2 + 8) * 10 % 3 == ((gK * 2 + 8) * 10 + 4) % 3 then
                    gL_1 = gH:WaitForChild("Indexers")
                else
                    gH = gL_1:WaitForChild("Indexers")
                end
                gK = (gK + 59) % 60
            else
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 4), string.byte(tostring(gn))), 20), 315790859), 4170177126), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 4), string.byte(tostring(gn))), 20), 3979176436), 3046298077))), 4170177126), 3046298077) == bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 4), string.byte(tostring(gn))), 20) then
                    gj = require(onCallback:WaitForChild("Hooks"))
                    PlayerPower = require(onCallback:WaitForChild("PlayerPower"))
                else
                    onCallback = require(PlayerPower:WaitForChild(PlayerPower))
                    gj = require(PlayerPower:WaitForChild("Hooks"))
                end
                gK = (gK + 59) % 60
            end
        elseif gP <= 11 then
            if (gK * 2 + 3) * 13 % 3 == ((gK * 2 + 3) * 13 + 1) % 3 then
                local World = (gF:WaitForChild("World"))
                gH = require(World:WaitForChild(require))
            else
                gR = (gH:WaitForChild("World"))
                gF = require(gR:WaitForChild("Enemies"))
            end
            gK = (gK + 14) % 60
        else
            local gQ_4 = (vector.create((gK * 3 + 4) % 11 + 1, (gK * 10 + 8) % 13 + 1, (gK * 8 + 10) % 17 + 1))
            gR = (vector.create((gK * 7 + 9) % 11 + 1, (gK * 4 + 2) % 13 + 1, (gK * 11 + 5) % 17 + 1))
            if vector.dot(gQ_4, gR) * vector.dot(gQ_4, gR) <= vector.dot(gQ_4, gQ_4) * vector.dot(gR, gR) then
                gR = (gH:WaitForChild("World"))
                f6 = require(gR:WaitForChild("Islands"))
                gR = (gH:WaitForChild("World"))
                f0 = require(gR:WaitForChild("TeleportCatalog"))
            else
                local gQ_5 = (f6:WaitForChild(require))
                f0 = require(gQ_5:WaitForChild(f6))
                gR = (f6:WaitForChild(require))
                gH = require(gR:WaitForChild("World"))
            end
            gK = (gK + 44) % 60
        end
    elseif gP <= 14 then
        if gP <= 13 then
            if bit32.bxor(bit32.lrotate(bit32.bxor(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 9), string.byte(tostring(gH))), 30), 3636846242), 14), 2007545393) == bit32.lrotate(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 9), string.byte(tostring(gH))), 30), 14) then
                local Gacha = (gH:WaitForChild("Gacha"))
                gM_1 = require(Gacha:WaitForChild("GachaRegistry"))
            else
                local gQ_7 = (gM_1:WaitForChild(require))
                gH = require(gQ_7:WaitForChild("GachaRegistry"))
            end
            gK = (gK + 44) % 60
        else
            if (gK * 2 + 3) * 4 % 3 == ((gK * 2 + 3) * 4 + 3) % 3 then
                gE_1 = require(onCallback:WaitForChild("GachaAccess"))
                local PlayerScripts = (gn:WaitForChild("PlayerScripts"))
                gR = (PlayerScripts:WaitForChild("Client"))
                local Services = (gR:WaitForChild("Services"))
                SpawnEnemies = require(Services:WaitForChild("SpawnEnemies"))
            else
                onCallback = require(SpawnEnemies:WaitForChild(require))
                gP = (gE_1:WaitForChild("GachaAccess"))
                local gQ_10 = gP:WaitForChild(SpawnEnemies)
                gR = gQ_10
                gS = (gR:WaitForChild(gQ_10))
                gn = require(gS:WaitForChild("SpawnEnemies"))
            end
            gK = (gK + 59) % 60
        end
    else
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 18), string.byte(tostring(gA))), 15), 3797404205), 453562034), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 18), string.byte(tostring(gA))), 15), 497563090), 2199253004))), 453562034), 2199253004) ~= bit32.rrotate(bit32.bxor(bit32.lrotate(gK, 18), string.byte(tostring(gA))), 15) then
            gF = gA.all()
        else
            gA = gF.all()
        end
        gK = (gK + 59) % 60
    end
until fn88((gK * 47 + 4) % 60, 812862761)
gR, gQ_11 = nil, nil
gP = 0
repeat
    if (gP * 1 + 1) % 2 + 1 <= 1 then
        if (not gR or gP or (gP or not gQ_11) or (gP or gR) and (gP and gQ_11)) and not (not gR or gP or (gP or not gQ_11) or (gP or gR) and (gP and gQ_11)) then
            f6 = gQ_11.Order
        else
            gQ_11 = f6.Order
        end
        gP = (gP + 5) % 8
    else
        if gP * 89137127 + 12 + 5 <= gP * 89137127 + 12 + 5 + 4 then
            gR = {}
        else
            gQ_11 = {}
        end
        gP = (gP + 1) % 8
    end
until fn88((gP * 3 + 4) % 8, 510804476)
if fn723(type(gQ_11), 5, 248602996) then
    for i, v in ipairs(gQ_11) do
        local gD_3 = not fn723(v, 12, 2441560907) and gA[v] and not gR[v]
        if gD_3 then
            gN[#gN + 1] = v
            gR[v] = true
        end
    end
end
if fn88(#gN, 544454170) then
    for k in pairs(gA) do
        if f6[k] then
            gN[#gN + 1] = k
        end
    end
    table.sort(gN)
end
gF, f7 = nil, nil
local gD_4 = 0
repeat
    if gD_4 * 80007877 + 4 + 2 <= gD_4 * 80007877 + 4 + 2 + 1 then
        gE_3 = function(aq)
            local hN_5
            local hM_5
            hM_5, hN_5 = pcall(function()
                return f0.getIslandDisplayName(aq)
            end)
            local hO = hM_5 and fn723(type(hN_5), 6, 2175009567) and not fn723(hN_5, 0, 5381)
            if hO then
                return hN_5
            end
            local hM_6 = f6[aq]
            local hN_6 = fn723(type(hM_6), 5, 248602996) and fn723(type(hM_6.BeautyName), 6, 2175009567) and not fn723(hM_6.BeautyName, 0, 5381)
            if hN_6 then
                return hM_6.BeautyName
            end
            return aq
        end
        gF = {}
        f7 = {}
    else
        gF = function(aq)
            local hN_3
            local hM_3
            hM_3, hN_3 = pcall(function()
                return f0.getIslandDisplayName(aq)
            end)
            local hO = hM_3 and fn723(type(hN_3), 6, 2175009567) and not fn723(hN_3, 0, 5381)
            if hO then
                return hN_3
            end
            local hM_4 = f6[aq]
            local hN_4 = fn723(type(hM_4), 5, 248602996) and fn723(type(hM_4.BeautyName), 6, 2175009567) and not fn723(hM_4.BeautyName, 0, 5381)
            if hN_4 then
                return hM_4.BeautyName
            end
            return aq
        end
        f7 = function(aq)
            local hN_1
            local hM_1
            hM_1, hN_1 = pcall(function()
                return f0.getIslandDisplayName(aq)
            end)
            local hO = hM_1 and fn723(type(hN_1), 6, 2175009567) and not fn723(hN_1, 0, 5381)
            if hO then
                return hN_1
            end
            local hM_2 = f6[aq]
            local hN_2 = fn723(type(hM_2), 5, 248602996) and fn723(type(hM_2.BeautyName), 6, 2175009567) and not fn723(hM_2.BeautyName, 0, 5381)
            if hN_2 then
                return hM_2.BeautyName
            end
            return aq
        end
        gE_3 = {}
    end
    gD_4 = (gD_4 + 2) % 8
until fn88((gD_4 * 1 + 7) % 8, 527583337)
for i, v in ipairs(gN) do
    local gD_5 = gE_3(v)
    gF[#gF + 1] = gD_5
    f7[gD_5] = v
end
local function fS(aC)
    local hQ = {}
    local hR = gA[aC]
    if fn723(type(hR), 5, 248602996) then
        for k in pairs(hR) do
            hQ[#hQ + 1] = k
        end
        table.sort(hQ)
    end
    return hQ
end
local gh = {}
for k, v in pairs(gM_1.list()) do
    local gD_6 = fn723(type(v), 5, 248602996) and not fn723(v.Category, 9, 1167499081)
    if gD_6 then
        local Access = v.Access
        gG = fn723(type(Access), 5, 248602996) and Access.IslandId
        gG = gG or nil
        local gD_9 = fn723(type(gG), 6, 2175009567) and not fn723(gG, 0, 5381) and fn723(type(v.Id), 6, 2175009567)
        if gD_9 then
            local gD_10 = gh[gG] or {}
            gh[gG] = gD_10
            table.insert(gh[gG], v.Id)
        end
    end
end
for k, v in pairs(gh) do
    table.sort(v)
end
gl, gH, f3, f_, fX, fT, gB, gy, gv, gt, gp, gk, gf, ga, gG, gb, fV, f5, gz, gr, fU = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local gD_11 = 52
repeat
    gI = (gD_11 * 2 + 2) % 9 + 1
    if gI <= 5 then
        if gI <= 3 then
            if gI <= 2 then
                if gI <= 1 then
                    if (gD_11 * 2 + 1) * 10 % 3 == ((gD_11 * 2 + 1) * 10 + 3) % 3 then
                        fV = function(aY)
                            if gn:GetAttribute("CurrentIsland") == aY then
                                return true
                            end
                            local h_ = pcall(function()
                                local RequestCatalogTeleport = gj.RequestCatalogTeleport
                                local aZ = RequestCatalogTeleport:Fire({ IslandId = aY, TeleportId = "" })
                                return aZ
                            end)
                            if not h_ then
                                return false
                            end
                            local h__2 = os.clock() + 8
                            while true do
                                local h0 = gn:GetAttribute("CurrentIsland") ~= aY and os.clock() < h__2
                                if h0 then
                                    task.wait(0.2)
                                    continue
                                end
                                break
                            end
                            task.wait(0.4)
                            return gn:GetAttribute("CurrentIsland") == aY
                        end
                        f5 = fn701
                        gz = fn148
                    else
                        gz = function(aY)
                            if gn:GetAttribute("CurrentIsland") == aY then
                                return true
                            end
                            local h_ = pcall(function()
                                local RequestCatalogTeleport = gj.RequestCatalogTeleport
                                local aZ = RequestCatalogTeleport:Fire({ IslandId = aY, TeleportId = "" })
                                return aZ
                            end)
                            if not h_ then
                                return false
                            end
                            local h__1 = os.clock() + 8
                            while true do
                                local h0 = gn:GetAttribute("CurrentIsland") ~= aY and os.clock() < h__1
                                if h0 then
                                    task.wait(0.2)
                                    continue
                                end
                                break
                            end
                            task.wait(0.4)
                            return gn:GetAttribute("CurrentIsland") == aY
                        end
                        fV = fn701
                        f5 = fn148
                    end
                    gD_11 = (gD_11 + 59) % 72
                else
                    if (gD_11 * 2 + 5) * 4 % 3 == ((gD_11 * 2 + 5) * 4 + 3) % 3 then
                        gr = function(bk)
                            local attr
                            attr = bk:GetAttribute("EntityId")
                            local ik = not fn723(typeof(attr), 6, 2175009567) or fn723(attr, 0, 5381)
                            if ik then
                                return
                            end
                            gn.SetAttribute(gn, "FocusedEnemyId", attr)
                            pcall(function()
                                local Punch = gj.Punch
                                Punch.Fire(Punch, { Entity = attr, Zone = "" })
                            end)
                        end
                        fU = fn941
                        f3 = false
                        f_ = false
                        fX = false
                    else
                        onCallback = function(bk)
                            local attr
                            attr = bk:GetAttribute("EntityId")
                            local ik = not fn723(typeof(attr), 6, 2175009567) or fn723(attr, 0, 5381)
                            if ik then
                                return
                            end
                            gn.SetAttribute(gn, "FocusedEnemyId", attr)
                            pcall(function()
                                local Punch = gj.Punch
                                Punch.Fire(Punch, { Entity = attr, Zone = "" })
                            end)
                        end
                        f_ = onCallback
                        f3 = fn941
                        fU = fn941
                        fX = false
                        gr = onCallback
                    end
                    gD_11 = (gD_11 + 41) % 72
                end
            else
                if gD_11 * 41421729 + 13 + 6 <= gD_11 * 41421729 + 13 + 6 + 2 then
                    fT = false
                    gB = false
                    gy = false
                else
                    gy = false
                    fT = false
                    gB = false
                end
                gD_11 = (gD_11 + 5) % 72
            end
        elseif gI <= 4 then
            if gD_11 * 98132697 + 11 + 4 <= gD_11 * 98132697 + 11 + 4 + 2 then
                gv = false
                gt = false
                gp = gN[1]
                gk = fS(gp)[1]
            else
                gt = false
                gk = false
                gN = 1
                fS = gp(1)[1]
            end
            gD_11 = (gD_11 + 14) % 72
        else
            onCallback = (vector.create((gD_11 * 3 + 1) % 11 + 1, (gD_11 * 4 + 5) % 13 + 1, (gD_11 * 12 + 2) % 17 + 1))
            gK = (vector.create((gD_11 * 7 + 8) % 11 + 1, (gD_11 * 5 + 2) % 13 + 1, (gD_11 * 5 + 9) % 17 + 1))
            local gL_2 = (vector.create((gD_11 * 5 + 2) % 5 + 1, (gD_11 * 2 + 3) % 7 + 1, (gD_11 * 5 + 6) % 9 + 1))
            if fn88(math.abs((vector.angle(onCallback, gK, gL_2))) - math.abs((vector.angle(gK, onCallback, gL_2))), 544454170) then
                gf = gN[1]
            else
                gN = gf[1]
            end
            gD_11 = (gD_11 + 50) % 72
        end
    elseif gI <= 7 then
        if gI <= 6 then
            if (gD_11 * 2 + 1) * 16 % 3 == ((gD_11 * 2 + 1) * 16 + 8) % 3 then
                gN = ga[1]
            else
                ga = gN[1]
            end
            gD_11 = (gD_11 + 23) % 72
        else
            onCallback = (vector.create((gD_11 * 4 + 9) % 11 + 1, (gD_11 * 10 + 12) % 13 + 1, (gD_11 * 4 + 8) % 17 + 1))
            if fn88(vector.dot(vector.floor(onCallback) + vector.ceil(onCallback * -1), vector.floor(onCallback) + vector.ceil(onCallback * -1)), 544454170) then
                gG = gh[ga]
            else
                ga = gh
            end
            gD_11 = (gD_11 + 5) % 72
        end
    elseif gI <= 8 then
        gI = (vector.create((gD_11 * 2 + 4) % 11 + 1, (gD_11 * 1 + 10) % 13 + 1, (gD_11 * 7 + 1) % 17 + 1))
        onCallback = (vector.create((gD_11 * 1 + 4) % 11 + 1, (gD_11 * 10 + 12) % 13 + 1, (gD_11 * 2 + 13) % 17 + 1))
        gK = (vector.create((gD_11 * 2 + 2) % 5 + 1, (gD_11 * 4 + 6) % 7 + 1, (gD_11 * 2 + 5) % 9 + 1))
        if math.abs((vector.angle(gI, onCallback, gK))) - math.abs((vector.angle(onCallback, gI, gK))) == 1 then
            fX = "Bijuu"
        else
            gl = { "Sword", "Companion", "Aura", "Curse", "Fruit", "Race", "Bijuu", "Grimoire", "Stand" }
        end
        gD_11 = (gD_11 + 41) % 72
    else
        if (gD_11 * 3 + 3) * 21 % 4 == ((gD_11 * 3 + 3) * 21 + 10) % 4 then
            gb = "Damage"
            gH = fn59
        else
            gH = { "Power", "Damage", "AttackSpeed", "Luck", "Coins" }
            gb = fn59
        end
        gD_11 = (gD_11 + 50) % 72
    end
until fn88((gD_11 * 5 + 54) % 72, 443711368)
if not gG then
    gG = {}
end
f1, fY, gI, gx, gK, gs, onCallback = nil, nil, nil, nil, nil, nil, nil
local gD_12 = 34
repeat
    local gL_3 = (gD_12 * 1 + 3) % 5 + 1
    if gL_3 <= 3 then
        if gL_3 <= 2 then
            if gL_3 <= 1 then
                local gM_2 = (vector.create((gD_12 * 6 + 7) % 11 + 1, (gD_12 * 6 + 7) % 13 + 1, (gD_12 * 15 + 13) % 17 + 1))
                gN = (vector.create((gD_12 * 1 + 3) % 11 + 1, (gD_12 * 2 + 4) % 13 + 1, (gD_12 * 3 + 14) % 17 + 1))
                gP = (vector.create((gD_12 * 6 + 2) % 11 + 1, (gD_12 * 6 + 12) % 13 + 1, (gD_12 * 4 + 11) % 17 + 1))
                local gQ_12 = (vector.create((gD_12 * 5 + 9) % 11 + 1, (gD_12 * 9 + 2) % 13 + 1, (gD_12 * 14 + 5) % 17 + 1))
                if vector.dot(vector.cross(gM_2, gN), (vector.cross(gP, gQ_12))) == vector.dot(gM_2, gP) * vector.dot(gN, gQ_12) - vector.dot(gM_2, gQ_12) * vector.dot(gN, gP) + 1 then
                    gx = "Title"
                else
                    gK = {
                        Combat = gx:AddTab({ Title = "Combat", Icon = "swords" }),
                        Progress = gx:AddTab({ Title = "Progress", Icon = "trending-up" }),
                        Summon = gx:AddTab({ Title = "Summon", Icon = "sparkles" }),
                        Inventory = gx:AddTab({ Title = "Inventory", Icon = "package" })
                    }
                end
                gD_12 = (gD_12 + 16) % 40
            else
                gN = ({ "frvsy", "qmiv", "wpv", "oeaganu", "wcch", "bqyngdzs", "vnlrbo", "hlsjn", "xlrypvb" })[gD_12 % 9 + 1]
                local gM_4 = gN:len()
                gP = (gN:gsub("(.)", "%1%1", gD_12 % 3 % 2 + 1))
                if gM_4 >= gP:len() then
                    gs = fn456
                else
                    onCallback = fn456
                end
                gD_12 = (gD_12 + 31) % 40
            end
        else
            local gM_5 = (vector.create((gD_12 * 2 + 1) % 11 + 1, (gD_12 * 6 + 2) % 13 + 1, (gD_12 * 13 + 11) % 17 + 1))
            gN = (vector.create((gD_12 * 3 + 2) % 11 + 1, (gD_12 * 4 + 10) % 13 + 1, (gD_12 * 7 + 9) % 17 + 1))
            gP = (vector.create((gD_12 * 3 + 3) % 5 + 1, (gD_12 * 3 + 7) % 7 + 1, (gD_12 * 4 + 5) % 9 + 1))
            if math.abs((vector.angle(gM_5, gN, gP))) - math.abs((vector.angle(gN, gM_5, gP))) == 1 then
                gG = f1
                local gM_6 = gs[1]
                gH = 1
                task.spawn(task)
                task.spawn(task.spawn)
                task.spawn(gM_6)
                task.spawn(worker3)
                fY = function()
                    local iE_2
                    local iD_3
                    iD_3, iE_2 = pcall(function()
                        local RequestDailyRewardState = gj.RequestDailyRewardState
                        return RequestDailyRewardState:Fire({ Requested = true })
                    end)
                    local iF = iD_3 and fn723(type(iE_2), 5, 248602996) and fn723(type(iE_2.Entries), 5, 248602996)
                    if iF then
                        for i, v in ipairs(iE_2.Entries) do
                            local iM = v
                            if iM.Available == true and iM.Claimed ~= true then
                                pcall(function()
                                    local ClaimDailyRewards = gj.ClaimDailyRewards
                                    ClaimDailyRewards.Fire(ClaimDailyRewards, { Day = iM.Day, Requested = true })
                                end)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            else
                f1 = gG[1]
                fY = gH[1]
                task.spawn(function()
                    while true do
                        if f3 then
                            local ir = gz(nil)
                            if ir then
                                gr(ir)
                            end
                        end
                        task.wait(0.1)
                    end
                end)
                task.spawn(worker3)
                task.spawn(function()
                    local iz_1
                    local iy_1
                    while true do
                        if fX then
                            iy_1, iz_1 = pcall(function()
                                local RequestRankUp = gj.RequestRankUp
                                return RequestRankUp:Fire({ Requested = true })
                            end)
                            local iA = iy_1 and fn723(type(iz_1), 5, 248602996) and iz_1.Success
                            if iA then
                                task.wait(0.2)
                            else
                                task.wait(1)
                            end
                        else
                            task.wait(0.3)
                        end
                    end
                end)
                task.spawn(function()
                    while true do
                        if fT then
                            pcall(function()
                                local AutoClaimAchievements = gj.AutoClaimAchievements
                                AutoClaimAchievements.Fire(AutoClaimAchievements, {})
                            end)
                            task.wait(15)
                        else
                            task.wait(0.5)
                        end
                    end
                end)
                gs = function()
                    local iE_1
                    local iD_1
                    iD_1, iE_1 = pcall(function()
                        local RequestDailyRewardState = gj.RequestDailyRewardState
                        return RequestDailyRewardState:Fire({ Requested = true })
                    end)
                    local iF = iD_1 and fn723(type(iE_1), 5, 248602996) and fn723(type(iE_1.Entries), 5, 248602996)
                    if iF then
                        for i, v in ipairs(iE_1.Entries) do
                            local iM = v
                            if iM.Available == true and iM.Claimed ~= true then
                                pcall(function()
                                    local ClaimDailyRewards = gj.ClaimDailyRewards
                                    ClaimDailyRewards.Fire(ClaimDailyRewards, { Day = iM.Day, Requested = true })
                                end)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end
            gD_12 = (gD_12 + 16) % 40
        end
    elseif gL_3 <= 4 then
        local gL_4 = (vector.create((gD_12 * 4 + 4) % 11 + 1, (gD_12 * 10 + 1) % 13 + 1, (gD_12 * 9 + 15) % 17 + 1))
        local gM_7 = (vector.create((gD_12 * 7 + 9) % 11 + 1, (gD_12 * 2 + 8) % 13 + 1, (gD_12 * 8 + 13) % 17 + 1))
        gN = (vector.create((gD_12 * 3 + 4) % 5 + 1, (gD_12 * 3 + 5) % 7 + 1, (gD_12 * 4 + 6) % 9 + 1))
        if fn88(math.abs((vector.angle(gL_4, gM_7, gN))) - math.abs((vector.angle(gM_7, gL_4, gN))), 544454170) then
            task.spawn(worker2)
            task.spawn(worker)
            task.spawn(function()
                while true do
                    if gv and f1 then
                        local iP_1 = ga and gn:GetAttribute("CurrentIsland") ~= ga
                        if iP_1 then
                            fV(ga)
                        end
                        if gv then
                            pcall(function()
                                local GachaAction = gj.GachaAction
                                GachaAction.Fire(GachaAction, { Mode = "Roll", GachaId = f1, Source = "" })
                            end)
                        end
                        task.wait(0.4)
                    else
                        task.wait(0.3)
                    end
                end
            end)
            task.spawn(function()
                while true do
                    if gt then
                        for i, v in ipairs(gl) do
                            local iX = v
                            if not gt then
                                break
                            end
                            pcall(function()
                                local AutoFuseInventoryEntries = gj.AutoFuseInventoryEntries
                                AutoFuseInventoryEntries.Fire(AutoFuseInventoryEntries, { Category = iX })
                            end)
                            task.wait(0.3)
                        end
                        task.wait(2)
                    else
                        task.wait(0.5)
                    end
                end
            end)
            gI = getgenv().Fluent
        else
            task.spawn(worker2)
            task.spawn(worker)
            task.spawn(task.spawn)
            task.spawn(task)
            gK = loadstring(game:HttpGet(task[nil]))()
        end
        gD_12 = (gD_12 + 31) % 40
    else
        local gL_5 = {
            "cnxwi",
            "ifysauwytltg",
            "wkc",
            "aktnrgio",
            "qqemhxn",
            "jwwlsgowdl",
            "gratux",
            "avqsdz",
            "pjwkkhirdobb",
            "aqofktg",
            "pnyzp"
        }
        if gL_5[(gD_12 * 72 + 33) % 11 + 1] < gL_5[(gD_12 * 72 + 33) % 11 + 1] then
            gI = gx:CreateWindow((UDim2.fromOffset("Title", gx)))
        else
            gx = gI:CreateWindow({
                Title = "Anime Ultron Simulator",
                SubTitle = "Tempo Hub",
                TabWidth = 160,
                Size = UDim2.fromOffset(600, 470),
                Acrylic = false,
                Theme = "Dark",
                MinimizeKey = Enum.KeyCode.RightControl,
                Image = "rbxassetid://91400086538074"
            })
        end
        gD_12 = (gD_12 + 1) % 40
    end
until fn88((gD_12 * 3 + 20) % 40, 494033731)
for k, v in pairs(gK) do
    onCallback(v)
end
FarmEnemyDropdown, gI = nil, nil
gG = 1
repeat
    onCallback = (vector.create((gG * 2 + 9) % 11 + 1, (gG * 8 + 5) % 13 + 1, (gG * 15 + 5) % 17 + 1))
    local gL_6 = (vector.create((gG * 7 + 3) % 11 + 1, (gG * 7 + 8) % 13 + 1, (gG * 10 + 9) % 17 + 1))
    local gM_8 = (vector.create((gG * 2 + 4) % 11 + 1, (gG * 9 + 2) % 13 + 1, (gG * 15 + 5) % 17 + 1))
    if vector.dot(vector.cross(onCallback, gL_6), gM_8) == vector.dot(vector.cross(gL_6, gM_8), onCallback) then
        local gL_7 = { Title = "Auto Attack", Default = false, Callback = fn550 }
        local Combat4 = gK.Combat
        Combat4.AddToggle(Combat4, "AutoAttack", gL_7)
        local gL_8 = { Title = "World", Values = gF, Multi = false, Default = gE_3(gp) }
        local Combat3 = gK.Combat
        local FarmWorldDropdown = Combat3:AddDropdown("FarmWorld", gL_8)
        local gL_9 = {
            Title = "Enemy",
            Values = fS(gp),
            Multi = false,
            Default = gk,
            Callback = function(cd)
                gk = cd
            end
        }
        local Combat2 = gK.Combat
        FarmEnemyDropdown = Combat2:AddDropdown("FarmEnemy", gL_9)
        FarmWorldDropdown.OnChanged(FarmWorldDropdown, function(cf)
            local iZ
            gp = f7[cf] or cf
            iZ = fS(gp)
            gk = iZ[1]
            pcall(function()
                FarmEnemyDropdown.SetValues(FarmEnemyDropdown, iZ)
            end)
            if gk then
                pcall(function()
                    FarmEnemyDropdown.SetValue(FarmEnemyDropdown, gk)
                end)
            end
        end)
        local gL_10 = {
            Title = "Auto Farm",
            Default = false,
            Callback = function(ci)
                f_ = ci
            end
        }
        local Combat = gK.Combat
        Combat.AddToggle(Combat, "AutoFarm", gL_10)
        local gL_11 = { Title = "Auto Rank Up", Default = false, Callback = fn374 }
        local Progress5 = gK.Progress
        Progress5.AddToggle(Progress5, "AutoRankUp", gL_11)
        local gL_12 = { Title = "Auto Claim Achievements", Default = false, Callback = fn934 }
        local Progress4 = gK.Progress
        Progress4.AddToggle(Progress4, "AutoAchievements", gL_12)
        local gL_13 = {
            Title = "Auto Claim Daily Rewards",
            Default = false,
            Callback = function(cl)
                gB = cl
            end
        }
        local Progress3 = gK.Progress
        Progress3.AddToggle(Progress3, "AutoDaily", gL_13)
        local gL_14 = {
            Title = "Avatar Stat",
            Values = gH,
            Multi = false,
            Default = fY,
            Callback = function(cm)
                fY = cm
            end
        }
        local Progress2 = gK.Progress
        Progress2.AddDropdown(Progress2, "AvatarMode", gL_14)
        local gL_15 = {
            Title = "Auto Equip Best Avatar",
            Default = false,
            Callback = function(cn)
                gy = cn
            end
        }
        local Progress = gK.Progress
        Progress.AddToggle(Progress, "AutoEquipAvatar", gL_15)
        local gL_16 = {
            Title = "World",
            Values = gF,
            Multi = false,
            Default = gE_3(gf),
            Callback = function(co)
                gf = f7[co] or co
            end
        }
        local Summon3 = gK.Summon
        Summon3.AddDropdown(Summon3, "SummonWorld", gL_16)
        local gL_17 = {
            Title = "Auto Summon",
            Default = false,
            Callback = function(cq)
                if cq then
                    task.spawn(function()
                        fV(gf)
                        pcall(function()
                            local SummonAction = gj.SummonAction
                            SummonAction.Fire(SummonAction, { Mode = "AutoStart", GachaId = gf, AutoDeleteItemIds = {}, RemoteSummon = false })
                        end)
                    end)
                else
                    pcall(function()
                        local SummonAction = gj.SummonAction
                        SummonAction.Fire(SummonAction, { Mode = "AutoStop", GachaId = gf, AutoDeleteItemIds = {}, RemoteSummon = false })
                    end)
                end
            end
        }
        local Summon2 = gK.Summon
        Summon2.AddToggle(Summon2, "AutoSummon", gL_17)
        local gL_18 = { Title = "Gacha World", Values = gF, Multi = false, Default = gE_3(ga) }
        local Summon = gK.Summon
        gI = Summon:AddDropdown("GachaWorld", gL_18)
    else
        onCallback = fY.Combat
        gP = fn550
        local gQ_13 = { Default = false, Title = "Auto Attack", Callback = gP }
        gR = onCallback
        gR.AddToggle(gR, gQ_13, onCallback)
        local Combat2 = fY.Combat
        gk = Combat2:AddDropdown("Default", gf)
        local gT = fY.Combat
        gK = gT:AddDropdown("Callback", "Values")
        gk.OnChanged(gk, "FarmEnemy")
        local Combat = fY.Combat
        gN = Combat
        gN.AddToggle(gN, gp, false)
        gS = { Title = "Auto Rank Up", Callback = fn374, Default = false }
        gT = fY.Progress
        gT.AddToggle(gT, gS, "Title")
        gS = { Title = "Auto Claim Achievements", Default = false, Callback = fn934 }
        gT = fY.Progress
        gT.AddToggle(gT, "Callback", "Enemy")
        gR = fY.Progress
        gR.AddToggle(gR, Combat, "Auto Claim Daily Rewards")
        local Progress = fY.Progress
        Progress.AddDropdown(Progress, "World", false)
        onCallback = fY.Progress
        local gQ_15 = onCallback
        gQ_15.AddToggle(gQ_15, "Multi", fY)
        gP = fY.Summon
        gP.AddDropdown(gP, onCallback, "Callback")
        gN = fY.Summon
        gN.AddToggle(gN, "Callback", gS)
        local Summon = fY.Summon
        Summon.AddDropdown(Summon, "Gacha World", "AutoSummon")
    end
    gG = (gG + 3) % 8
until fn88((gG * 5 + 4) % 8, 544454170)
local Summon = gK.Summon
local gE_4 = "GachaId"
gF = "Title"
gG = "Gacha"
gH = "Values"
onCallback = gh[ga] or {}
Dropdown, gM_23 = nil, nil
local gL_20 = 4
repeat
    gN = (gL_20 * 2 + 0) % 3 + 1
    if gN <= 2 then
        if gN <= 1 then
            gN = { "hlzofyv", "yyr", "hoqqv", "myaxbbyi", "xgc", "siurc", "vsojp", "tenchfmpxf" }
            gP = gN[gL_20 % 8 + 1]
            gN = gL_20 % 3 + 2
            local gQ_16 = (gP:reverse())
            local ls = gN
            gN = gP:len()
            gR = (gQ_16:rep(ls))
            if gN <= gR:len() then
                gI.OnChanged(gI, function(cv)
                    local i4
                    ga = f7[cv] or cv
                    i4 = gh[ga] or {}
                    f1 = i4[1]
                    pcall(function()
                        Dropdown.SetValues(Dropdown, i4)
                    end)
                    if f1 then
                        pcall(function()
                            Dropdown.SetValue(Dropdown, f1)
                        end)
                    end
                end)
                gP = {
                    Title = "Auto Gacha",
                    Default = false,
                    Callback = function(cz)
                        gv = cz
                    end
                }
                local Summon = gK.Summon
                Summon.AddToggle(Summon, "AutoGacha", gP)
                gP = { Title = "Auto Fuse", Default = false, Callback = fn242 }
                local Inventory = gK.Inventory
                Inventory.AddToggle(Inventory, "AutoFuse", gP)
                pcall(function()
                    gx.SelectTab(gx, 1)
                end)
                gM_23 = Instance.new("ScreenGui")
            else
                gK.OnChanged(gK, function(cv)
                    local i4
                    ga = f7[cv] or cv
                    i4 = gh[ga] or {}
                    f1 = i4[1]
                    pcall(function()
                        Dropdown.SetValues(Dropdown, i4)
                    end)
                    if f1 then
                        pcall(function()
                            Dropdown.SetValue(Dropdown, f1)
                        end)
                    end
                end)
                gN = gM_23.Summon
                local gQ_19 = gN
                gQ_19.AddToggle(gQ_19, gK, "AutoGacha")
                local gQ_20 = { Default = false, Title = "Auto Fuse", Callback = fn242 }
                gR = gM_23.Inventory
                gR.AddToggle(gR, gN, gQ_20)
                pcall("Default")
                gI = Instance.new(false)
            end
            gL_20 = (gL_20 + 14) % 24
        else
            gN = (vector.create((gL_20 * 1 + 1) % 11 + 1, (gL_20 * 4 + 6) % 13 + 1, (gL_20 * 11 + 4) % 17 + 1))
            gP = (vector.create((gL_20 * 1 + 2) % 11 + 1, (gL_20 * 3 + 12) % 13 + 1, (gL_20 * 13 + 14) % 17 + 1))
            if vector.dot(vector.cross(gN, gP), (vector.cross(gN, gP))) + vector.dot(gN, gP) * vector.dot(gN, gP) == vector.dot(gN, gN) * vector.dot(gP, gP) + 3 then
                gM_23.Name = gM_23
                gM_23.ResetOnSpawn = gM_23
                gM_23.ZIndexBehavior = gM_23
            else
                gM_23.Name = "TempoToggle"
                gM_23.ResetOnSpawn = false
                gM_23.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            end
            gL_20 = (gL_20 + 8) % 24
        end
    else
        if gL_20 * 70269307 + 3 + 6 >= gL_20 * 70269307 + 3 + 6 + 1 then
            gP = Summon
            f1 = gP:AddDropdown("Callback", onCallback)
        else
            gN = {
                [gF] = gG,
                [gH] = onCallback,
                Multi = false,
                Default = f1,
                Callback = function(ct)
                    f1 = ct
                end
            }
            gP = Summon
            Dropdown = gP:AddDropdown(gE_4, gN)
        end
        gL_20 = (gL_20 + 2) % 24
    end
until fn88((gL_20 * 13 + 6) % 24, 712218331)
local gD_15 = gethui and gethui()
local gE_5 = gD_15 or game:GetService("CoreGui")
imageButton, gD_16, f2, fZ, fW, fR, gc = nil, nil, nil, nil, nil, nil, nil
gH = 3
repeat
    gI = (gH * 2 + 1) % 3 + 1
    if gI <= 2 then
        if gI <= 1 then
            if (gH * 2 + 2) * 13 % 3 == ((gH * 2 + 2) * 13 + 6) % 3 then
                gI = function()
                    if fR then
                        return
                    end
                    gc = not gc
                    local je = pcall(function()
                        gx.Minimize(gx, gc)
                    end)
                    if not je then
                        pcall(function()
                            gx.Minimize(gx)
                        end)
                    end
                end
                onCallback = imageButton.MouseButton1Click
                onCallback.Connect(onCallback, gI)
            else
                gI = imageButton.MouseButton1Click
                gI.Connect(gI, imageButton)
            end
            gH = (gH + 23) % 24
        else
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gH, 14), string.byte(tostring(gD_16))), 26), 2638675141), 837900734), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gH, 14), string.byte(tostring(gD_16))), 26), 1656292154), 2123780559))), 837900734), 2123780559) == bit32.rrotate(bit32.bxor(bit32.lrotate(gH, 14), string.byte(tostring(gD_16))), 26) then
                gM_23.Parent = gE_5
                imageButton = Instance.new("ImageButton")
            else
                gM_23.Parent = imageButton
                gE_5 = Instance:new()
            end
            gH = (gH + 11) % 24
        end
    else
        if (not fZ and fZ and (not f2 or fZ) and (fZ and fZ and (fZ or not f2)) and (f2 and not f2 and (f2 and not f2) and ((not f2 or fZ) and (not f2 and not f2))) or ((f2 and f2 or f2 and not fZ) and (fZ or not fZ or (fZ or fZ)) or (f2 and fZ or (fZ or fZ) or not fZ and f2 and (not fZ or fZ)))) and not (not fZ and fZ and (not f2 or fZ) and (fZ and fZ and (fZ or not f2)) and (f2 and not f2 and (f2 and not f2) and ((not f2 or fZ) and (not f2 and not f2))) or ((f2 and f2 or f2 and not fZ) and (fZ or not fZ or (fZ or fZ)) or (f2 and fZ or (fZ or fZ) or not fZ and f2 and (not fZ or fZ)))) then
            gI = UDim2.fromOffset
            f2.Size = gI(52, f2)
            onCallback = UDim2.fromScale
            f2.Position = onCallback(UDim2, 0.04)
            f2.AnchorPoint = Vector2.new(0.5, f2)
            f2.BackgroundColor3 = Color3.fromRGB(30, onCallback, 25)
            f2.BackgroundTransparency = Color3
            f2.Image = 52
            gK = Enum.ScaleType
            local Fit = gK.Fit
            f2.ScaleType = Enum
            f2.AutoButtonColor = gK
            f2.Parent = Vector2
            gM_23 = Instance.new(f2)
            gM_23.CornerRadius = UDim.new(0.1, f2)
            gM_23.Parent = f2
            gG = Instance.new(gM_23)
            gG.Color = Color3.fromRGB(12, f2, "rbxassetid://91400086538074")
            gG.Thickness = 0
            gG.Transparency = gI
            gG.Parent = f2
            fZ = Instance.new(Instance.new)
            fZ.PaddingTop = UDim.new(80, fZ)
            onCallback = UDim.new
            fZ.PaddingBottom = onCallback(Color3, f2)
            fZ.PaddingLeft = UDim.new(gG, gG)
            gK = UDim.new
            fZ.PaddingRight = gK(true, onCallback)
            fZ.Parent = "UIPadding"
            gO_1, fR, fW = 6, gK, Fit
            gI = f2.InputBegan
            gI.Connect(gI, 0)
            gI = gc.InputChanged
            gI.Connect(gI, UDim)
            gI = gc.InputEnded
            gI.Connect(gI, UDim)
            gD_16 = gG
        else
            imageButton.Size = UDim2.fromOffset(52, 52)
            imageButton.Position = UDim2.fromScale(0.5, 0.04)
            imageButton.AnchorPoint = Vector2.new(0.5, 0)
            imageButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            imageButton.BackgroundTransparency = 0.1
            imageButton.Image = "rbxassetid://91400086538074"
            imageButton.ScaleType = Enum.ScaleType.Fit
            imageButton.AutoButtonColor = true
            imageButton.Parent = gM_23
            gG = Instance.new("UICorner")
            gG.CornerRadius = UDim.new(0, 12)
            gG.Parent = imageButton
            gF = Instance.new("UIStroke")
            gF.Color = Color3.fromRGB(80, 80, 95)
            gF.Thickness = 1
            gF.Transparency = 0.3
            gF.Parent = imageButton
            gD_16 = Instance.new("UIPadding")
            gD_16.PaddingTop = UDim.new(0, 6)
            gD_16.PaddingBottom = UDim.new(0, 6)
            gD_16.PaddingLeft = UDim.new(0, 6)
            gD_16.PaddingRight = UDim.new(0, 6)
            gD_16.Parent = imageButton
            f2, fZ, fW, fR = false, nil, nil, false
            gI = function(cM)
                if cM.UserInputType == Enum.UserInputType.MouseButton1 or cM.UserInputType == Enum.UserInputType.Touch then
                    f2, fR = true, false
                    fZ = cM.Position
                    fW = imageButton.Position
                end
            end
            onCallback = imageButton.InputBegan
            onCallback.Connect(onCallback, gI)
            gI = function(cO)
                if f2 and (cO.UserInputType == Enum.UserInputType.MouseMovement or cO.UserInputType == Enum.UserInputType.Touch) then
                    local i9_1 = cO.Position - fZ
                    if i9_1.Magnitude > 4 then
                        fR = true
                    end
                    imageButton.Position = UDim2.new(fW.X.Scale, fW.X.Offset + i9_1.X, fW.Y.Scale, fW.Y.Offset + i9_1.Y)
                end
            end
            onCallback = gO_1.InputChanged
            onCallback.Connect(onCallback, gI)
            gI = function(cS)
                if cS.UserInputType == Enum.UserInputType.MouseButton1 or cS.UserInputType == Enum.UserInputType.Touch then
                    f2 = false
                end
            end
            onCallback = gO_1.InputEnded
            onCallback.Connect(onCallback, gI)
            gc = false
        end
        gH = (gH + 20) % 24
    end
until fn88((gH * 7 + 2) % 24, 259187032)
end)(...)
