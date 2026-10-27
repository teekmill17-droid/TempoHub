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
getgenv().TempoHoodSubtitle = "ANIME ASTRAL SIMULATOR"
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
if not game:IsLoaded() then
	game.Loaded:Wait()
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local SimpleWorld
for _, child in ReplicatedStorage:GetChildren() do
	if child.Name == "SimpleWorld" then
		SimpleWorld = child
		break
	end
end
local Library = require(SimpleWorld.Library)
local ClientFolder = SimpleWorld.Library.Client
local WorldController = require(ClientFolder.WorldController)
local AutoActionController = require(ClientFolder.AutoActionController)
local TeleportController = require(ClientFolder.TeleportController)
local WorldConfig = Library.getConfig("WorldConfig")
local EnemyConfig = Library.getConfig("EnemyConfig")
local SideQuestConfig = Library.getConfig("SideQuestConfig")
local function getBridge(name)
	local bridge
	local pending = true
	task.spawn(function()
		local ok, result = pcall(Library.getBridge, name)
		if ok then
			bridge = result
		end
		pending = false
	end)
	local deadline = os.clock() + 5
	while pending and os.clock() < deadline do
		task.wait(0.1)
	end
	return bridge
end
local Bridges = {
	Click = getBridge("Click"),
	RankUp = getBridge("RankUp"),
	AutoClaimAchievementsSet = getBridge("AutoClaimAchievementsSet"),
	AutoClaimRewardsSet = getBridge("AutoClaimRewardsSet"),
	AutoAvatarBuffSet = getBridge("AutoAvatarBuffSet"),
	BuyWorld = getBridge("BuyWorld"),
	RequestChangeWorld = getBridge("RequestChangeWorld"),
	FuseAllSwords = getBridge("FuseAllSwords"),
	EquipBest = getBridge("EquipBest"),
	EquipBestSword = getBridge("EquipBestSword"),
	EquipBestTitan = getBridge("EquipBestTitan"),
	OpenEgg = getBridge("OpenEgg"),
	QuestCollect = getBridge("QuestCollect"),
	GlobalQuestClaimAll = getBridge("GlobalQuestClaimAll"),
	SideQuestAcceptRequest = getBridge("SideQuestAcceptRequest"),
	EquipBestLoadout = getBridge("EquipBestLoadout"),
	RaidGateTeleport = getBridge("RaidGateTeleport"),
	GachaRoll = getBridge("GachaRoll"),
	SwordRoll = getBridge("SwordRoll"),
	TitanRoll = getBridge("TitanRoll"),
	PlayerPassiveRoll = getBridge("PlayerPassiveRoll"),
}
local GachaConfig = Library.getConfig("GachaConfig")
local SwordConfig = Library.getConfig("SwordConfig")
local TitansConfig = Library.getConfig("TitansConfig")
local RarityRank = {}
for rank, rarity in ipairs(GachaConfig.Rarity_Order) do
	RarityRank[rarity] = rank
end
local GachaNames = {}
local GachaNameToKey = {}
local GachaMaxRarity = {}
for key, gacha in pairs(GachaConfig.Gachas) do
	table.insert(GachaNames, gacha.Name)
	GachaNameToKey[gacha.Name] = key
	local best, bestRank
	for rarity in pairs(gacha.Items or {}) do
		local rank = RarityRank[rarity]
		if rank and (not bestRank or rank > bestRank) then
			best, bestRank = rarity, rank
		end
	end
	GachaMaxRarity[key] = best
end
table.sort(GachaNames)
local function BuildBannerData(entries)
	local names = {}
	local map = {}
	for key, entry in pairs(entries) do
		table.insert(names, entry.Name)
		map[entry.Name] = key
	end
	table.sort(names)
	return names, map
end
local SwordBannerNames, SwordBannerToKey = BuildBannerData(SwordConfig.Swords)
local TitanBannerNames, TitanBannerToKey = BuildBannerData(TitansConfig.Titans)
local ActiveGachas = {}
local GAMEMODES = {
	{
		Id = "Trial",
		Arenas = "TimeTrialArenas",
		Config = "TimeTrialConfig",
		Getter = "GetAllTrials",
		TotalField = "TotalRooms",
		Counter = "Room",
		Join = "TimeTrialJoin",
		Leave = "TimeTrialLeave",
		State = "TimeTrialState",
		Ended = "TimeTrialEnded",
		FarmTitle = "Time Trial Farm",
		LeaveTitle = "Time Trial Leave At Floor",
		SelectText = "Select Trials",
		AutoFarmText = "Auto Farm Trial",
		AutoLeaveText = "Auto leave At Time Trial Floor",
	},
	{
		Id = "Raid",
		Arenas = "RaidArenas",
		Config = "RaidConfig",
		Getter = "GetAllRaids",
		TotalField = "TotalWaves",
		Counter = "Wave",
		Join = "RaidJoin",
		Leave = "RaidLeave",
		State = "RaidState",
		Ended = "RaidEnded",
		Status = "RaidActiveStatus",
		Controller = "RaidController",
		Afford = "HasEnoughForRaid",
		CanJoinActive = "CanAutoJoinActiveRaid",
		FarmTitle = "Raid Farm",
		LeaveTitle = "Raid Leave At Wave",
		SelectText = "Select Raids",
		AutoFarmText = "Auto Farm Raid",
		AutoLeaveText = "Auto leave At Raid Floor",
	},
	{
		Id = "Defense",
		Arenas = "DefenseArenas",
		Config = "DefenseConfig",
		Getter = "GetAllDefenses",
		TotalField = "TotalWaves",
		Counter = "Wave",
		Join = "DefenseJoin",
		Leave = "DefenseLeave",
		State = "DefenseState",
		Ended = "DefenseEnded",
		Status = "DefenseActiveStatus",
		Controller = "DefenseController",
		Afford = "HasEnoughForDefense",
		CanJoinActive = "CanAutoJoinActiveDefense",
		FarmTitle = "Defense Farm",
		LeaveTitle = "Defense Leave At Wave",
		SelectText = "Select Defenses",
		AutoFarmText = "Auto Farm Defense",
		AutoLeaveText = "Auto leave At Defense Floor",
	},
	{
		Id = "Dungeon",
		Arenas = "DungeonArenas",
		Config = "DungeonConfig",
		Getter = "GetAllDungeons",
		TotalField = "TotalRooms",
		Counter = "Room",
		Join = "DungeonJoin",
		Leave = "DungeonLeave",
		State = "DungeonState",
		Ended = "DungeonEnded",
		FarmTitle = "Dungeon Farm",
		LeaveTitle = "Dungeon Leave At Wave",
		SelectText = "Select Dungeons",
		AutoFarmText = "Auto Farm Dungeon",
		AutoLeaveText = "Auto leave At Dungeon Room",
	},
}
for _, gamemode in ipairs(GAMEMODES) do
	local config = Library.getConfig(gamemode.Config)
	local entries = {}
	for key, entry in pairs(config[gamemode.Getter](config)) do
		table.insert(entries, {
			Key = key,
			Name = entry.Name,
			WorldId = tonumber(entry.WorldId),
			Total = tonumber(entry[gamemode.TotalField]) or 100,
			GateRanks = entry.GateRanks,
		})
	end
	table.sort(entries, function(a, b)
		return a.Name < b.Name
	end)
	gamemode.Entries = entries
	gamemode.NameToEntry = {}
	gamemode.Names = {}
	for _, entry in ipairs(entries) do
		table.insert(gamemode.Names, entry.Name)
		gamemode.NameToEntry[entry.Name] = entry
		if entry.GateRanks then
			local ranks = {}
			for _, rank in ipairs(entry.GateRanks) do
				table.insert(ranks, rank.Rank)
			end
			gamemode.GateRankValues = ranks
		end
	end
	Bridges[gamemode.Join] = getBridge(gamemode.Join)
	Bridges[gamemode.Leave] = getBridge(gamemode.Leave)
	Bridges[gamemode.State] = getBridge(gamemode.State)
	if gamemode.Status then
		Bridges[gamemode.Status] = getBridge(gamemode.Status)
	end
end
local ActiveGamemode = nil
local GateAnnouncements = {}
local RaidAnnouncement = getBridge("RaidAnnouncement")
if RaidAnnouncement then
	RaidAnnouncement:Connect(function(payload)
		if type(payload) ~= "table" or type(payload.Key) ~= "string" then
			return
		end
		local rank
		if type(payload.Description) == "string" then
			rank = payload.Description:match("Rank%s+(%a+)%s+Gate")
		end
		GateAnnouncements[payload.Key] = {
			Rank = rank,
			GateTeleport = payload.GateTeleport,
		}
	end)
end
local GamemodeActiveKeys = {}
local GamemodeJoinIndex = {}
local GamemodeLeftKeys = {}
for _, gamemode in ipairs(GAMEMODES) do
	GamemodeActiveKeys[gamemode.Id] = {}
	GamemodeLeftKeys[gamemode.Id] = {}
	local status = gamemode.Status and Bridges[gamemode.Status]
	if status then
		status:Connect(function(payload)
			local keys = {}
			if type(payload) == "table" then
				for key, value in pairs(payload) do
					if type(key) == "string" then
						if value == true then
							keys[key] = true
						elseif type(value) == "table" and value.Active ~= false then
							keys[key] = true
						end
					end
				end
			end
			GamemodeActiveKeys[gamemode.Id] = keys
			for key in pairs(GamemodeLeftKeys[gamemode.Id]) do
				if not keys[key] then
					GamemodeLeftKeys[gamemode.Id][key] = nil
				end
			end
			if gamemode.Id == "Raid" then
				for key in pairs(GateAnnouncements) do
					if keys[key] then
						GateAnnouncements[key] = nil
					end
				end
			end
		end)
	end
end
local LOADOUT_STATS = { "Luck", "Drop", "Power", "XP", "Damage", "Yen", "None" }
local FARM_MODES = { "Selected", "Nearest", "All" }
local TARGET_MODES = { "Nearest", "Highest HP", "Furthest" }
local DIFFICULTIES = { "VeryEasy", "Easy", "Medium", "Hard", "MiniBoss", "Boss", "Secret" }
local DifficultyRank = {}
for rank, difficulty in ipairs(DIFFICULTIES) do
	DifficultyRank[difficulty] = rank
end
local ActiveMode = nil
local function BindMode(name, enterBridges, endBridge)
	for _, bridgeName in enterBridges do
		local bridge = getBridge(bridgeName)
		if bridge then
			bridge:Connect(function()
				ActiveMode = name
			end)
		end
	end
	local ended = getBridge(endBridge)
	if ended then
		ended:Connect(function()
			if ActiveMode == name then
				ActiveMode = nil
			end
		end)
	end
end
BindMode("Dungeon", { "DungeonState", "DungeonMapReady" }, "DungeonEnded")
BindMode("Defense", { "DefenseState", "DefenseMapReady" }, "DefenseEnded")
BindMode("Raid", { "RaidState", "RaidMapReady" }, "RaidEnded")
BindMode("Trial", { "TimeTrialState", "TimeTrialMapReady" }, "TimeTrialEnded")
local WorldChanged = getBridge("WorldChanged")
if WorldChanged then
	WorldChanged:Connect(function()
		ActiveMode = nil
	end)
end
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local ObsidianLibrary = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Options = ObsidianLibrary.Options
local Toggles = ObsidianLibrary.Toggles
local DISCORD_INVITE = "https://discord.gg/K7Qxnxkk46"
local Worlds = {}
for _, world in ipairs(WorldConfig:GetAllWorlds()) do
	local id = tonumber(world.Order)
	if id then
		table.insert(Worlds, { Id = id, Name = world.Name })
	end
end
table.sort(Worlds, function(a, b)
	return a.Id < b.Id
end)
local WorldLabels = {}
local WorldLabelToId = {}
for _, world in ipairs(Worlds) do
	local label = world.Name .. " | " .. world.Id
	table.insert(WorldLabels, label)
	WorldLabelToId[label] = world.Id
end
local MobLabelToName = {}
local function BuildMobData(worldIds)
	local entries = {}
	local map = {}
	for _, worldId in ipairs(worldIds) do
		local list = EnemyConfig:GetEnemiesByWorld(worldId)
		if list then
			for _, enemy in pairs(list) do
				if enemy and enemy.Name then
					local difficulty = tostring(enemy.Type or "Unknown")
					local label = enemy.Name .. " | " .. difficulty
					if not map[label] then
						map[label] = enemy.Name
						table.insert(entries, {
							Label = label,
							Name = enemy.Name,
							Rank = DifficultyRank[difficulty] or #DIFFICULTIES + 1,
							WorldId = worldId,
						})
					end
				end
			end
		end
	end
	table.sort(entries, function(a, b)
		if a.Rank ~= b.Rank then
			return a.Rank < b.Rank
		end
		if a.WorldId ~= b.WorldId then
			return a.WorldId < b.WorldId
		end
		return a.Name < b.Name
	end)
	local labels = {}
	for _, entry in ipairs(entries) do
		table.insert(labels, entry.Label)
	end
	return labels, map
end
local function BuildMobLabels(worldIds)
	local labels, map = BuildMobData(worldIds)
	MobLabelToName = map
	return labels
end
local SideQuestIds = {}
for id in pairs(SideQuestConfig.Quests) do
	table.insert(SideQuestIds, id)
end
table.sort(SideQuestIds)
local function GetSelected(option, values)
	local selected = {}
	local value = option and option.Value
	if type(value) ~= "table" then
		return selected
	end
	for _, entry in ipairs(values) do
		if value[entry] then
			table.insert(selected, entry)
		end
	end
	return selected
end
local function GetFirstSelected(option, values)
	return GetSelected(option, values)[1]
end
local function GetSelectedWorldId()
	local label = Options.FarmWorld and Options.FarmWorld.Value
	return label and WorldLabelToId[label]
end
local function GetSelectedMobNames()
	local names = {}
	local value = Options.FarmMob and Options.FarmMob.Value
	if type(value) ~= "table" then
		return names
	end
	for label, active in pairs(value) do
		if active and MobLabelToName[label] then
			names[MobLabelToName[label]] = true
		end
	end
	return names
end
local function GetRoot()
	local character = LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end
local function GetCurrentWorldId()
	local ok, id = pcall(function()
		return WorldController:GetCurrentWorld()
	end)
	if ok and id then
		return tonumber(id)
	end
	return nil
end
local function GetEnemyList(worldId)
	local worldsFolder = workspace:FindFirstChild("Worlds")
	local world = worldsFolder and worldsFolder:FindFirstChild(tostring(worldId))
	local folder = world and world:FindFirstChild("Enemies")
	if not folder then
		return {}
	end
	local alive = {}
	for _, enemy in folder:GetChildren() do
		local humanoid = enemy:FindFirstChildOfClass("Humanoid")
		local root = enemy:FindFirstChild("HumanoidRootPart")
		if humanoid and root and enemy:GetAttribute("EnemyDead") ~= true then
			table.insert(alive, enemy)
		end
	end
	return alive
end
local function GetNearestEnemy(worldId, root, nameFilter)
	local nearest, nearestDist
	for _, enemy in GetEnemyList(worldId) do
		if not nameFilter or nameFilter[enemy.Name] then
			local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
			local dist = (enemyRoot.Position - root.Position).Magnitude
			if not nearestDist or dist < nearestDist then
				nearest = enemy
				nearestDist = dist
			end
		end
	end
	return nearest
end
local function PickTarget(enemies, root, mode)
	local best, bestScore
	for _, enemy in ipairs(enemies) do
		local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
		local humanoid = enemy:FindFirstChildOfClass("Humanoid")
		if enemyRoot and humanoid then
			local score
			if mode == "Highest HP" then
				score = humanoid.Health
			else
				score = (enemyRoot.Position - root.Position).Magnitude
				if mode ~= "Furthest" then
					score = -score
				end
			end
			if not bestScore or score > bestScore then
				best, bestScore = enemy, score
			end
		end
	end
	return best
end
local Window = ObsidianLibrary:CreateWindow({
	Title = "Tempo Hub",
	Footer = "https://discord.gg/K7Qxnxkk46 | Anime Astral Simulator",
	Icon = 18657887261,
	EnableSidebarResize = true,
	NotifySide = "Right",
	ShowCustomCursor = false,
	ShowMobileButtons = false,
	Size = UDim2.fromOffset(960, 720),
})
local Tabs = {
	Main = Window:AddTab("Main", "swords"),
	Secondary = Window:AddTab("Secondary", "sparkles"),
	Gamemodes = Window:AddTab("Gamemodes", "castle"),
	Gacha = Window:AddTab("Gacha", "dices"),
	Priority = Window:AddTab("Priority", "list-ordered"),
	Webhook = Window:AddTab("Webhook", "webhook"),
	Settings = Window:AddTab("Settings", "settings"),
}
local function AddDiscordButton(Tab)
	Tab:AddLeftGroupbox("Discord", nil, nil, nil, true):AddButton({
		Text = "Join Discord For Dupe",
		Func = function()
			setclipboard(DISCORD_INVITE)
			ObsidianLibrary:Notify("Copied Discord invite to clipboard")
		end,
	})
end
for _, Tab in Tabs do
	AddDiscordButton(Tab)
end
local FarmGroup = Tabs.Main:AddLeftGroupbox("Farm")
FarmGroup:AddDropdown("FarmWorld", {
	Values = WorldLabels,
	Default = WorldLabels[1],
	Searchable = true,
	AllowNull = true,
	Text = "World",
	Callback = function()
		if Options.FarmMob then
			local worldId = GetSelectedWorldId()
			Options.FarmMob:SetValues(BuildMobLabels(worldId and { worldId } or {}))
		end
	end,
})
FarmGroup:AddDropdown("FarmMob", {
	Values = BuildMobLabels({ WorldLabelToId[WorldLabels[1]] }),
	Default = {},
	Multi = true,
	Searchable = true,
	AllowNull = true,
	Text = "Mob",
})
FarmGroup:AddDropdown("FarmMode", {
	Values = FARM_MODES,
	Default = "Nearest",
	Searchable = true,
	AllowNull = true,
	Text = "Farm Mode",
})
FarmGroup:AddToggle("TeleportBeforeFarm", {
	Text = "Teleport To World Before Farm",
	Default = true,
})
FarmGroup:AddToggle("AutoFarm", {
	Text = "Auto Farm",
	Default = false,
})
FarmGroup:AddToggle("FastAutoClick", {
	Text = "Fast Auto Click",
	Default = false,
})
local RoundRobinGroup = Tabs.Main:AddLeftGroupbox("Round Robin Farm")
local RoundRobinMobMap = {}
local RefreshRoundRobinKillSliders
local function RefreshRoundRobinMobs()
	local worldIds = {}
	for _, label in ipairs(GetSelected(Options.RoundRobinWorlds, WorldLabels)) do
		table.insert(worldIds, WorldLabelToId[label])
	end
	local labels, map = BuildMobData(worldIds)
	RoundRobinMobMap = map
	if Options.RoundRobinMobs then
		Options.RoundRobinMobs:SetValues(labels)
	end
	RefreshRoundRobinKillSliders()
end
RoundRobinGroup:AddDropdown("RoundRobinWorlds", {
	Values = WorldLabels,
	Default = {},
	Multi = true,
	Searchable = true,
	AllowNull = true,
	Text = "Worlds",
	Callback = RefreshRoundRobinMobs,
})
RoundRobinGroup:AddDropdown("RoundRobinMobs", {
	Values = {},
	Default = {},
	Multi = true,
	Searchable = true,
	AllowNull = true,
	Text = "Mobs",
	Callback = function()
		RefreshRoundRobinKillSliders()
	end,
})
local AllWorldIds = {}
for _, world in ipairs(Worlds) do
	table.insert(AllWorldIds, world.Id)
end
local AllMobLabels = BuildMobData(AllWorldIds)
for _, label in ipairs(AllMobLabels) do
	RoundRobinGroup:AddSlider("RoundRobinKills_" .. label, {
		Text = "Kills before next - " .. label,
		Default = 3,
		Min = 1,
		Max = 100,
		Rounding = 0,
		Visible = false,
	})
end
RoundRobinGroup:AddSlider("RoundRobinSeconds", {
	Text = "Max Seconds Per Target",
	Default = 60,
	Min = 5,
	Max = 300,
	Rounding = 0,
	Suffix = "s",
})
RoundRobinGroup:AddToggle("RoundRobinFarm", {
	Text = "Round Robin Auto Farm",
	Default = false,
})
function RefreshRoundRobinKillSliders()
	local selected = Options.RoundRobinMobs and Options.RoundRobinMobs.Value
	for _, label in ipairs(AllMobLabels) do
		local slider = Options["RoundRobinKills_" .. label]
		if slider then
			slider:SetVisible(type(selected) == "table" and selected[label] == true)
		end
	end
end
local AutoGroup = Tabs.Main:AddRightGroupbox("Automation")
AutoGroup:AddToggle("AutoClaimAchievements", {
	Text = "Auto Claim Achievements",
	Default = false,
	Callback = function(value)
		if Bridges.AutoClaimAchievementsSet then
			Bridges.AutoClaimAchievementsSet:Fire(value)
		end
	end,
})
AutoGroup:AddToggle("AutoRankUp", {
	Text = "Auto Rank Up",
	Default = false,
	Callback = function(value)
		if Bridges.RankUp then
			Bridges.RankUp:Fire("SetAutoRankUp", value)
		end
	end,
})
AutoGroup:AddToggle("AutoUnlockWorld", {
	Text = "Auto Unlock Next Affordable World",
	Default = false,
})
AutoGroup:AddToggle("AutoClaimRewards", {
	Text = "Auto Claim Time/Week Reward",
	Default = false,
	Callback = function(value)
		if Bridges.AutoClaimRewardsSet then
			Bridges.AutoClaimRewardsSet:Fire(value)
		end
	end,
})
AutoGroup:AddToggle("AutoFuseSwords", {
	Text = "Auto Fuse All Swords",
	Default = false,
})
local StarGroup = Tabs.Secondary:AddLeftGroupbox("Star Hatch")
StarGroup:AddDropdown("StarWorld", {
	Values = WorldLabels,
	Default = { WorldLabels[1] },
	Multi = true,
	Searchable = true,
	AllowNull = true,
	Text = "Star",
})
StarGroup:AddToggle("AutoHatch", {
	Text = "Auto Hatch",
	Default = false,
})
local QuestGroup = Tabs.Secondary:AddLeftGroupbox("Quests")
QuestGroup:AddToggle("AutoNextWorldQuest", {
	Text = "Auto Next World Quest",
	Default = false,
})
QuestGroup:AddToggle("AutoMainQuest", {
	Text = "Auto Main Quest",
	Default = false,
})
QuestGroup:AddDropdown("SideQuest", {
	Values = SideQuestIds,
	Default = { SideQuestConfig.DefaultQuestId },
	Multi = true,
	Searchable = true,
	AllowNull = true,
	Text = "Side Quest",
})
QuestGroup:AddToggle("AutoSideQuest", {
	Text = "Auto Side Quest",
	Default = false,
})
local EquipGroup = Tabs.Secondary:AddRightGroupbox("Auto Equip")
EquipGroup:AddToggle("AutoEquipPets", {
	Text = "Auto Equip Best Pets",
	Default = false,
})
EquipGroup:AddToggle("AutoEquipSwords", {
	Text = "Auto Equip Best Swords",
	Default = false,
})
EquipGroup:AddToggle("AutoEquipAvatars", {
	Text = "Auto Equip Best Avatars",
	Default = false,
	Callback = function(value)
		if Bridges.AutoAvatarBuffSet then
			Bridges.AutoAvatarBuffSet:Fire(value)
		end
	end,
})
EquipGroup:AddToggle("AutoEquipTitan", {
	Text = "Auto Equip Best Titan",
	Default = false,
})
local function GamemodeSelectedEntries(gamemode)
	local entries = {}
	for _, name in ipairs(GetSelected(Options[gamemode.Id .. "Select"], gamemode.Names)) do
		table.insert(entries, gamemode.NameToEntry[name])
	end
	return entries
end
local function IsArenaRunning(gamemode, key)
	local arenas = workspace:FindFirstChild(gamemode.Arenas)
	return (arenas and arenas:FindFirstChild(key)) ~= nil
end
local function GetArenaEnemies(gamemode, key)
	local arenas = workspace:FindFirstChild(gamemode.Arenas)
	local arena = arenas and arenas:FindFirstChild(key)
	local folder = arena and arena:FindFirstChild("Enemies")
	if not folder then
		return {}
	end
	local alive = {}
	for _, enemy in folder:GetChildren() do
		local humanoid = enemy:FindFirstChildOfClass("Humanoid")
		local root = enemy:FindFirstChild("HumanoidRootPart")
		if humanoid and root and enemy:GetAttribute("EnemyDead") ~= true then
			table.insert(alive, enemy)
		end
	end
	return alive
end
for _, gamemode in ipairs(GAMEMODES) do
	local FarmBox = Tabs.Gamemodes:AddLeftGroupbox(gamemode.FarmTitle)
	FarmBox:AddDropdown(gamemode.Id .. "Select", {
		Values = gamemode.Names,
		Default = {},
		Multi = true,
		Searchable = true,
		AllowNull = true,
		Text = gamemode.SelectText,
	})
	if gamemode.GateRankValues then
		FarmBox:AddDropdown(gamemode.Id .. "GateRank", {
			Values = gamemode.GateRankValues,
			Default = {},
			Multi = true,
			Searchable = true,
			AllowNull = true,
			Text = "Select Gate Rank",
		})
	end
	FarmBox:AddDropdown(gamemode.Id .. "Target", {
		Values = TARGET_MODES,
		Default = TARGET_MODES[1],
		Searchable = true,
		AllowNull = true,
		Text = "Select Mob Priority",
	})
	FarmBox:AddToggle(gamemode.Id .. "AutoFarm", {
		Text = gamemode.AutoFarmText,
		Default = false,
	})
	local LeaveBox = Tabs.Gamemodes:AddRightGroupbox(gamemode.LeaveTitle)
	for _, entry in ipairs(gamemode.Entries) do
		LeaveBox:AddSlider(gamemode.Id .. "Leave" .. entry.Key, {
			Text = entry.Name,
			Default = entry.Total + 1,
			Min = 2,
			Max = entry.Total + 1,
			Rounding = 0,
		})
	end
	LeaveBox:AddToggle(gamemode.Id .. "AutoLeave", {
		Text = gamemode.AutoLeaveText,
		Default = false,
	})
end
local ScheduleGroup = Tabs.Gamemodes:AddLeftGroupbox("Spawn Schedule")
local ScheduleLabels = {}
local STALE_GAMEMODE_SECONDS = 45
local JOIN_CONFIRM_SECONDS = 6
local SPAWN_SCHEDULE = {
	Raid = { [0] = "Random Tier", [10] = "Gate", [20] = "Gate", [30] = "Random Tier", [40] = "Gate", [50] = "Gate" },
	Dungeon = { [0] = "Easy", [15] = "Medium", [30] = "Easy", [45] = "Medium" },
	Trial = { [0] = "Easy", [15] = "Medium", [30] = "Easy", [45] = "Medium" },
}
local function GetSpawnMinutes(id)
	local schedule = SPAWN_SCHEDULE[id]
	if not schedule then
		return nil
	end
	local minutes = {}
	for minute in pairs(schedule) do
		table.insert(minutes, minute)
	end
	table.sort(minutes)
	return minutes
end
local function GetNextSpawn(id)
	local schedule = SPAWN_SCHEDULE[id]
	local minutes = GetSpawnMinutes(id)
	if not minutes then
		return nil
	end
	local now = os.date("*t")
	local remaining, tier
	for _, minute in ipairs(minutes) do
		local seconds = ((minute - now.min) % 60) * 60 - now.sec
		if seconds <= 0 then
			seconds += 3600
		end
		if not remaining or seconds < remaining then
			remaining, tier = seconds, schedule[minute]
		end
	end
	return remaining, tier
end
local function FormatCountdown(seconds)
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end
for _, gamemode in ipairs(GAMEMODES) do
	if SPAWN_SCHEDULE[gamemode.Id] then
		ScheduleLabels[gamemode.Id] = ScheduleGroup:AddLabel(gamemode.Id .. ": --:--", true)
	end
end
local function IsInGamemode()
	local ok, inside = pcall(function()
		return TeleportController:IsInGamemode()
	end)
	return ok and inside == true
end
local function IsLoading()
	local ok, loading = pcall(function()
		return TeleportController:IsLoading()
	end)
	return ok and loading == true
end
local GamemodeControllers = {}
local function GetGamemodeController(gamemode)
	if not gamemode.Controller then
		return nil
	end
	if GamemodeControllers[gamemode.Id] == nil then
		local ok, controller = pcall(function()
			return require(ClientFolder[gamemode.Controller])
		end)
		GamemodeControllers[gamemode.Id] = ok and controller or false
	end
	return GamemodeControllers[gamemode.Id] or nil
end
local function CanEnterKey(gamemode, key, isActive)
	local controller = GetGamemodeController(gamemode)
	if not controller then
		return true
	end
	local method = isActive and gamemode.CanJoinActive or gamemode.Afford
	if not method then
		return true
	end
	local ok, allowed = pcall(function()
		return controller[method](controller, key)
	end)
	return not ok or allowed == true
end
local function GateRankAllowed(gamemode, entry)
	if not entry.GateRanks then
		return true
	end
	local selected = GetSelected(Options[gamemode.Id .. "GateRank"], gamemode.GateRankValues or {})
	if #selected == 0 then
		return true
	end
	local announced = GateAnnouncements[entry.Key]
	if not (announced and announced.Rank) then
		return false
	end
	for _, rank in ipairs(selected) do
		if rank == announced.Rank then
			return true
		end
	end
	return false
end
local GachaGroup = Tabs.Gacha:AddLeftGroupbox("Gacha")
GachaGroup:AddDropdown("GachaSelect", {
	Values = GachaNames,
	Default = {},
	Multi = true,
	Searchable = true,
	AllowNull = true,
	Text = "Select Gacha",
})
GachaGroup:AddToggle("AutoSpinGacha", {
	Text = "Auto Spin Gacha",
	Default = false,
})
local SwordGroup = Tabs.Gacha:AddRightGroupbox("Sword")
SwordGroup:AddDropdown("SwordBanner", {
	Values = SwordBannerNames,
	Default = {},
	Multi = true,
	Searchable = true,
	AllowNull = true,
	Text = "Select Banner",
})
SwordGroup:AddToggle("AutoRollSword", {
	Text = "Auto Roll Sword Banner",
	Default = false,
})
local TitanGroup = Tabs.Gacha:AddRightGroupbox("Titan")
TitanGroup:AddDropdown("TitanBanner", {
	Values = TitanBannerNames,
	Default = {},
	Multi = true,
	Searchable = true,
	AllowNull = true,
	Text = "Select Banner",
})
TitanGroup:AddToggle("AutoRollTitan", {
	Text = "Auto Roll Titan Banner",
	Default = false,
})
local PassiveGroup = Tabs.Gacha:AddRightGroupbox("Passive")
PassiveGroup:AddToggle("AutoRollPassive", {
	Text = "Auto Roll Passive",
	Default = false,
})
local WEBHOOK_INVITE = "discord.gg/f3dJhDgyTq"
local WebhookGroup = Tabs.Webhook:AddLeftGroupbox("Webhook")
WebhookGroup:AddInput("WebhookUrl", {
	Text = "Webhook URL",
	Default = "",
	Placeholder = "https://discord.com/api/webhooks/...",
	Finished = true,
})
WebhookGroup:AddInput("WebhookPingId", {
	Text = "Ping ID",
	Default = "",
	Placeholder = "Your Discord user ID",
	Numeric = true,
	Finished = true,
})
WebhookGroup:AddToggle("WebhookOnDisconnect", {
	Text = "Send When Disconnected",
	Default = false,
})
WebhookGroup:AddToggle("WebhookOnDivineGacha", {
	Text = "Send When Divine Gacha",
	Default = false,
})
WebhookGroup:AddToggle("WebhookOnSpawn", {
	Text = "Send When Gamemode Spawns",
	Default = false,
})
local httpRequest = http_request or request or (syn and syn.request)
local function SendWebhook(resultLines)
	local url = Options.WebhookUrl.Value
	if not httpRequest or type(url) ~= "string" or url == "" then
		return
	end
	local pingId = Options.WebhookPingId.Value
	local content = ""
	if type(pingId) == "string" and pingId ~= "" then
		content = "<@" .. pingId .. ">"
	end
	local name = LocalPlayer.Name
	local ok, data = pcall(function()
		return Library.Network.Functions.GetPlayerData:InvokeServer()
	end)
	if ok and type(data) == "table" and data.Rank then
		name = "[" .. tostring(data.Rank) .. "] " .. name
	end
	local payload = HttpService:JSONEncode({
		content = content,
		embeds = {
			{
				title = "Anime Astral Simulator",
				color = 5793266,
				fields = {
					{ name = "Name", value = name, inline = false },
					{ name = "Result", value = table.concat(resultLines, "\n"), inline = false },
				},
				footer = { text = WEBHOOK_INVITE },
				timestamp = DateTime.now():ToIsoDate(),
			},
		},
	})
	task.spawn(function()
		pcall(httpRequest, {
			Url = url,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = payload,
		})
	end)
end
task.spawn(function()
	local GachaResult = getBridge("GachaResult")
	if GachaResult then
		GachaResult:Connect(function(success, _, result)
			if not (success and type(result) == "table") then
				return
			end
			if not Toggles.WebhookOnDivineGacha.Value then
				return
			end
			local gacha = GachaConfig:GetGacha(result.GachaKey)
			local gachaName = gacha and gacha.Name or tostring(result.GachaKey)
			local rolls = type(result.Rolls) == "table" and result.Rolls or { result }
			for _, roll in ipairs(rolls) do
				if type(roll) == "table" and roll.RolledRarity == "Divine" then
					local item = roll.RolledItem
					local itemName = item and item.Name or "Divine"
					SendWebhook({
						"Divine Gacha - Obtained",
						"- Gacha: " .. gachaName,
						"- Power: " .. itemName,
						"- Rarity: Divine",
					})
					break
				end
			end
		end)
	end
end)
task.spawn(function()
	local LastSpawnMinute = {}
	while true do
		if ObsidianLibrary.Unloaded then
			break
		end
		local minute = os.date("*t").min
		for _, gamemode in ipairs(GAMEMODES) do
			local schedule = SPAWN_SCHEDULE[gamemode.Id]
			if schedule then
				local label = ScheduleLabels[gamemode.Id]
				if label then
					local remaining, tier = GetNextSpawn(gamemode.Id)
					label:SetText(gamemode.Id .. ": " .. tostring(tier) .. " in " .. FormatCountdown(remaining))
				end
				if schedule[minute] and LastSpawnMinute[gamemode.Id] ~= minute then
					LastSpawnMinute[gamemode.Id] = minute
					if Toggles.WebhookOnSpawn.Value then
						SendWebhook({
							"Spawned - " .. gamemode.Id,
							"- Tier: " .. tostring(schedule[minute]),
							"- Time: " .. os.date("%H:%M"),
						})
					end
				end
			end
		end
		task.wait(1)
	end
end)
local SwapGroup = Tabs.Secondary:AddRightGroupbox("Load Out Swap")
local SwapContexts = {
	{ Index = "SwapDungeon", Text = "Swap At Dungeon", Mode = "Dungeon" },
	{ Index = "SwapDefense", Text = "Swap At Defense", Mode = "Defense" },
	{ Index = "SwapStarSummon", Text = "Swap At Star Summon", Mode = "StarSummon" },
	{ Index = "SwapRaid", Text = "Swap At Raid", Mode = "Raid" },
	{ Index = "SwapTrial", Text = "Swap At Trial", Mode = "Trial" },
	{ Index = "SwapNormalFarm", Text = "Swap At Normal Farm", Mode = "NormalFarm" },
}
for _, context in ipairs(SwapContexts) do
	SwapGroup:AddDropdown(context.Index, {
		Values = LOADOUT_STATS,
		Default = { "None" },
		Multi = true,
		Searchable = true,
		AllowNull = true,
		Text = context.Text,
	})
end
SwapGroup:AddToggle("AutoSwapLoadout", {
	Text = "Auto Swap LoadOut",
	Default = false,
})
ObsidianLibrary.ToggleKeybind = Options.MenuKeybind
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind",
})
MenuGroup:AddToggle("AntiAFK", {
	Text = "Anti-AFK",
	Default = true,
})
local HasAutoHidden = false
local function AutoHideOnce()
	if HasAutoHidden or not Toggles.AutoHideUI.Value then
		return
	end
	HasAutoHidden = true
	Window:Toggle(false)
end
MenuGroup:AddToggle("AutoHideUI", {
	Text = "Auto Hide UI",
	Default = false,
	Callback = AutoHideOnce,
})
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "TempoToggle"
ToggleGui.ResetOnSpawn = false
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.DisplayOrder = 999
if syn and syn.protect_gui then
	syn.protect_gui(ToggleGui)
end
ToggleGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "Toggle"
ToggleButton.Size = UDim2.fromOffset(56, 56)
ToggleButton.Position = UDim2.fromOffset(20, 20)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.BorderSizePixel = 0
ToggleButton.AutoButtonColor = false
ToggleButton.Image = "rbxassetid://18657887261"
ToggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.Parent = ToggleGui
local TogglePadding = Instance.new("UIPadding")
TogglePadding.PaddingTop = UDim.new(0, 10)
TogglePadding.PaddingBottom = UDim.new(0, 10)
TogglePadding.PaddingLeft = UDim.new(0, 10)
TogglePadding.PaddingRight = UDim.new(0, 10)
TogglePadding.Parent = ToggleButton
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(60, 60, 60)
ToggleStroke.Thickness = 1
ToggleStroke.Parent = ToggleButton
local UserInputService = game:GetService("UserInputService")
local dragInput
local dragMoved = false
local dragStart
local startPosition
local function SyncToggleVisual()
	ToggleButton.ImageTransparency = ObsidianLibrary.Toggled and 0 or 0.45
end
ToggleButton.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	dragInput = input
	dragMoved = false
	dragStart = input.Position
	startPosition = ToggleButton.Position
end)
UserInputService.InputChanged:Connect(function(input)
	if not dragInput then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local delta = input.Position - dragStart
	if delta.Magnitude > 4 then
		dragMoved = true
	end
	if dragMoved then
		ToggleButton.Position = UDim2.fromOffset(
			startPosition.X.Offset + delta.X,
			startPosition.Y.Offset + delta.Y
		)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if not dragInput or input.UserInputType ~= dragInput.UserInputType then
		return
	end
	dragInput = nil
	if not dragMoved then
		ObsidianLibrary:Toggle()
		SyncToggleVisual()
	end
end)
ObsidianLibrary:OnUnload(function()
	ToggleGui:Destroy()
end)
MenuGroup:AddButton("Unload", function()
	ObsidianLibrary:Unload()
end)
ObsidianLibrary:OnUnload(function()
	select("#", "Unloaded!")
end)
local PRIORITY_FEATURES = {
	{ Id = "Trial", Text = "Time Trial" },
	{ Id = "Defense", Text = "Defense" },
	{ Id = "Raid", Text = "Raid" },
	{ Id = "Dungeon", Text = "Dungeon" },
	{ Id = "Quest", Text = "Auto Quest" },
	{ Id = "Star", Text = "Auto Open Star" },
	{ Id = "Farm", Text = "Auto Farm" },
}
local PriorityGroup = Tabs.Priority:AddLeftGroupbox("Feature Priority")
PriorityGroup:AddToggle("PriorityEnabled", {
	Text = "Enable Priority System",
	Default = true,
})
PriorityGroup:AddLabel("1 = Highest Priority, 7 = Lowest Priority", true)
PriorityGroup:AddLabel("1 = Ưu tiên cao nhất, 7 = Ưu tiên thấp nhất", true)
PriorityGroup:AddLabel("1 = ลำดับความสำคัญสูงสุด, 7 = ลำดับความสำคัญต่ำสุด", true)
PriorityGroup:AddLabel("1 = Pinakamataas na Prayoridad, 7 = Pinakamababang Prayoridad", true)
for rank, feature in ipairs(PRIORITY_FEATURES) do
	PriorityGroup:AddSlider("Priority" .. feature.Id, {
		Text = feature.Text,
		Default = rank,
		Min = 1,
		Max = #PRIORITY_FEATURES,
		Rounding = 0,
	})
end
local function IsFeatureEligible(id)
	if id == "Quest" then
		return Toggles.AutoMainQuest.Value or Toggles.AutoNextWorldQuest.Value or Toggles.AutoSideQuest.Value
	elseif id == "Star" then
		return Toggles.AutoHatch.Value
	elseif id == "Farm" then
		return Toggles.AutoFarm.Value or Toggles.RoundRobinFarm.Value
	end
	local toggle = Toggles[id .. "AutoFarm"]
	if not (toggle and toggle.Value) then
		return false
	end
	for _, gamemode in ipairs(GAMEMODES) do
		if gamemode.Id == id then
			return #GamemodeSelectedEntries(gamemode) > 0
		end
	end
	return false
end
local function GetActiveFeature()
	if ActiveGamemode then
		return ActiveGamemode.Id
	end
	local best, bestRank
	for _, feature in ipairs(PRIORITY_FEATURES) do
		if IsFeatureEligible(feature.Id) then
			local rank = Options["Priority" .. feature.Id].Value
			if not bestRank or rank < bestRank then
				best, bestRank = feature.Id, rank
			end
		end
	end
	return best
end
local function IsAllowed(id)
	if not Toggles.PriorityEnabled.Value then
		return true
	end
	return GetActiveFeature() == id
end
task.spawn(function()
	for _, gamemode in ipairs(GAMEMODES) do
		local ended = getBridge(gamemode.Ended)
		if ended then
			ended:Connect(function()
				if not gamemode.Status then
					GamemodeLeftKeys[gamemode.Id] = {}
				end
				if ActiveGamemode and ActiveGamemode.Id == gamemode.Id then
					ActiveGamemode = nil
				end
			end)
		end
		local state = Bridges[gamemode.State]
		if state then
			state:Connect(function(payload)
				if type(payload) ~= "table" then
					return
				end
				if not (ActiveGamemode and ActiveGamemode.Id == gamemode.Id) then
					return
				end
				ActiveGamemode.LastState = os.clock()
				if not Toggles[gamemode.Id .. "AutoLeave"].Value then
					return
				end
				local counter = tonumber(payload[gamemode.Counter])
				local limit = Options[gamemode.Id .. "Leave" .. ActiveGamemode.Key]
				if not (counter and limit) then
					return
				end
				if counter >= limit.Value and Bridges[gamemode.Leave] then
					Bridges[gamemode.Leave]:Fire()
					GamemodeLeftKeys[gamemode.Id][ActiveGamemode.Key] = true
					ActiveGamemode = nil
				end
			end)
		end
	end
end)
task.spawn(function()
	while true do
		if ObsidianLibrary.Unloaded then
			break
		end
		if Toggles.AutoSpinGacha.Value and Bridges.GachaRoll then
			local ok, data = pcall(function()
				return Library.Network.Functions.GetPlayerData:InvokeServer()
			end)
			if ok and type(data) == "table" and type(data.ActiveGachas) == "table" then
				ActiveGachas = data.ActiveGachas
			end
			for _, name in ipairs(GetSelected(Options.GachaSelect, GachaNames)) do
				local key = GachaNameToKey[name]
				if key and ActiveGachas[key] ~= GachaMaxRarity[key] then
					Bridges.GachaRoll:Fire(key)
				end
			end
		end
		if Toggles.AutoRollSword.Value and Bridges.SwordRoll then
			for _, name in ipairs(GetSelected(Options.SwordBanner, SwordBannerNames)) do
				Bridges.SwordRoll:Fire(SwordBannerToKey[name])
			end
		end
		if Toggles.AutoRollTitan.Value and Bridges.TitanRoll then
			for _, name in ipairs(GetSelected(Options.TitanBanner, TitanBannerNames)) do
				Bridges.TitanRoll:Fire(TitanBannerToKey[name])
			end
		end
		if Toggles.AutoRollPassive.Value and Bridges.PlayerPassiveRoll then
			Bridges.PlayerPassiveRoll:Fire()
		end
		task.wait(1)
	end
end)
task.spawn(function()
	local CoreGui = game:GetService("CoreGui")
	local ok, overlay = pcall(function()
		return CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
	end)
	if not ok or not overlay then
		return
	end
	overlay.ChildAdded:Connect(function(child)
		if ObsidianLibrary.Unloaded then
			return
		end
		if not Toggles.WebhookOnDisconnect.Value then
			return
		end
		if not child.Name:find("ErrorPrompt") then
			return
		end
		local reason = "Connection lost"
		local label = child:FindFirstChild("ErrorMessage", true)
		if label and label:IsA("TextLabel") and label.Text ~= "" then
			reason = label.Text
		end
		SendWebhook({
			"Disconnected",
			"- Reason: " .. reason,
		})
	end)
end)
task.spawn(function()
	while true do
		if ObsidianLibrary.Unloaded then
			break
		end
		for _, gamemode in ipairs(GAMEMODES) do
			if Toggles[gamemode.Id .. "AutoFarm"].Value and IsAllowed(gamemode.Id) then
				local entries = GamemodeSelectedEntries(gamemode)
				if ActiveGamemode and ActiveGamemode.Id == gamemode.Id then
					local root = GetRoot()
					local enemies = GetArenaEnemies(gamemode, ActiveGamemode.Key)
					if os.clock() - ActiveGamemode.LastState > STALE_GAMEMODE_SECONDS and not IsInGamemode() then
						ActiveGamemode = nil
					elseif root and #enemies > 0 then
						local target = PickTarget(enemies, root, Options[gamemode.Id .. "Target"].Value)
						if target then
							local targetRoot = target:FindFirstChild("HumanoidRootPart")
							if targetRoot then
								root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
							end
							if Bridges.Click then
								Bridges.Click:Fire()
							end
						end
					end
				elseif not ActiveGamemode and #entries > 0 and not IsInGamemode() and not IsLoading() then
					local index = GamemodeJoinIndex[gamemode.Id] or 1
					if index > #entries then
						index = 1
					end
					for offset = 0, #entries - 1 do
						local slot = ((index - 1 + offset) % #entries) + 1
						local entry = entries[slot]
						local isActive = gamemode.Status and GamemodeActiveKeys[gamemode.Id][entry.Key] == true
						local leftBehind = GamemodeLeftKeys[gamemode.Id][entry.Key] == true
						if leftBehind and not gamemode.Status and not IsArenaRunning(gamemode, entry.Key) then
							GamemodeLeftKeys[gamemode.Id][entry.Key] = nil
							leftBehind = false
						end
						local canEnter
						if gamemode.Status then
							canEnter = CanEnterKey(gamemode, entry.Key, isActive)
						else
							canEnter = IsArenaRunning(gamemode, entry.Key)
						end
						if GateRankAllowed(gamemode, entry) and Bridges[gamemode.Join] and not leftBehind and canEnter then
							local action = "Join"
							if gamemode.Status and not isActive then
								action = "Create"
							end
							Bridges[gamemode.Join]:Fire(action, entry.Key)
							local deadline = os.clock() + JOIN_CONFIRM_SECONDS
							while os.clock() < deadline do
								if IsInGamemode() or IsArenaRunning(gamemode, entry.Key) then
									ActiveGamemode = { Id = gamemode.Id, Key = entry.Key, LastState = os.clock() }
									GamemodeJoinIndex[gamemode.Id] = slot + 1
									break
								end
								task.wait(0.25)
							end
							break
						end
					end
				end
			end
		end
		task.wait(0.1)
	end
end)
task.spawn(function()
	local lastStat
	while true do
		if ObsidianLibrary.Unloaded then
			break
		end
		if Toggles.AutoSwapLoadout.Value and Bridges.EquipBestLoadout then
			local mode = ActiveMode
			if not mode and Toggles.AutoHatch.Value then
				mode = "StarSummon"
			end
			if not mode then
				mode = "NormalFarm"
			end
			local stat
			for _, context in ipairs(SwapContexts) do
				if context.Mode == mode then
					stat = GetFirstSelected(Options[context.Index], LOADOUT_STATS)
					break
				end
			end
			if stat and stat ~= "None" and stat ~= lastStat then
				Bridges.EquipBestLoadout:Fire(stat)
				lastStat = stat
			end
		else
			lastStat = nil
		end
		task.wait(1)
	end
end)
task.spawn(function()
	while true do
		if ObsidianLibrary.Unloaded then
			break
		end
		local doFarm = Toggles.AutoFarm.Value and not Toggles.RoundRobinFarm.Value and IsAllowed("Farm")
		local fastClick = Toggles.FastAutoClick.Value
		if (doFarm or fastClick) and Bridges.Click then
			local root = GetRoot()
			if root then
				if doFarm then
					local selectedWorldId = GetSelectedWorldId()
					local currentWorldId = GetCurrentWorldId()
					if Toggles.TeleportBeforeFarm.Value and Bridges.RequestChangeWorld and selectedWorldId then
						if currentWorldId ~= selectedWorldId then
							Bridges.RequestChangeWorld:Fire(selectedWorldId)
							task.wait(2)
							currentWorldId = GetCurrentWorldId()
						end
					end
					currentWorldId = currentWorldId or selectedWorldId
					if currentWorldId then
						local mode = Options.FarmMode.Value or "Nearest"
						local target
						if mode == "Selected" then
							local names = GetSelectedMobNames()
							if next(names) then
								target = GetNearestEnemy(currentWorldId, root, names)
							end
						elseif mode == "All" then
							local list = GetEnemyList(currentWorldId)
							if #list > 0 then
								target = list[math.random(1, #list)]
							end
						else
							target = GetNearestEnemy(currentWorldId, root)
						end
						if target then
							local targetRoot = target:FindFirstChild("HumanoidRootPart")
							if targetRoot then
								root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
							end
						end
					end
				end
				Bridges.Click:Fire()
			end
		end
		task.wait(Toggles.FastAutoClick.Value and 0.05 or 0.15)
	end
end)
local function BuildRotation()
	local rotation = {}
	for _, label in ipairs(GetSelected(Options.RoundRobinWorlds, WorldLabels)) do
		local worldId = WorldLabelToId[label]
		local names = {}
		for mobLabel, active in pairs(Options.RoundRobinMobs.Value) do
			if active and RoundRobinMobMap[mobLabel] then
				names[RoundRobinMobMap[mobLabel]] = true
			end
		end
		local list = EnemyConfig:GetEnemiesByWorld(worldId)
		if list then
			local worldMobs = {}
			for _, enemy in pairs(list) do
				if enemy and enemy.Name and names[enemy.Name] then
					local difficulty = tostring(enemy.Type or "Unknown")
					table.insert(worldMobs, {
						WorldId = worldId,
						Name = enemy.Name,
						Label = enemy.Name .. " | " .. difficulty,
						Rank = DifficultyRank[difficulty] or #DIFFICULTIES + 1,
					})
				end
			end
			table.sort(worldMobs, function(a, b)
				if a.Rank ~= b.Rank then
					return a.Rank < b.Rank
				end
				return a.Name < b.Name
			end)
			for _, entry in ipairs(worldMobs) do
				table.insert(rotation, entry)
			end
		end
	end
	return rotation
end
local function IsEnemyDead(enemy)
	if not enemy.Parent then
		return true
	end
	if enemy:GetAttribute("EnemyDead") == true then
		return true
	end
	local humanoid = enemy:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health <= 0
end
task.spawn(function()
	local index = 1
	local dwellStart = 0
	local currentKey
	local kills = 0
	local engaged
	while true do
		if ObsidianLibrary.Unloaded then
			break
		end
		if Toggles.RoundRobinFarm.Value and IsAllowed("Farm") and Bridges.Click then
			local rotation = BuildRotation()
			if #rotation > 0 then
				if index > #rotation then
					index = 1
				end
				local target = rotation[index]
				local key = target.WorldId .. "|" .. target.Name
				if key ~= currentKey then
					currentKey = key
					dwellStart = os.clock()
					kills = 0
					engaged = nil
				end
				local root = GetRoot()
				local currentWorldId = GetCurrentWorldId()
				if root and currentWorldId ~= target.WorldId and Bridges.RequestChangeWorld then
					Bridges.RequestChangeWorld:Fire(target.WorldId)
					task.wait(2)
					currentWorldId = GetCurrentWorldId()
				end
				if engaged and IsEnemyDead(engaged) then
					kills += 1
					engaged = nil
				end
				local enemy = root and GetNearestEnemy(target.WorldId, root, { [target.Name] = true })
				if enemy then
					engaged = enemy
					local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
					if enemyRoot then
						root.CFrame = enemyRoot.CFrame * CFrame.new(0, 0, 5)
					end
					Bridges.Click:Fire()
				end
				local killSlider = Options["RoundRobinKills_" .. target.Label]
				local killTarget = killSlider and killSlider.Value or 3
				local timedOut = os.clock() - dwellStart >= Options.RoundRobinSeconds.Value
				if kills >= killTarget or timedOut then
					index += 1
					currentKey = nil
				end
			end
		end
		task.wait(Toggles.FastAutoClick.Value and 0.05 or 0.15)
	end
end)
task.spawn(function()
	while true do
		if ObsidianLibrary.Unloaded then
			break
		end
		if Toggles.AutoFuseSwords.Value and Bridges.FuseAllSwords then
			Bridges.FuseAllSwords:Fire()
		end
		if Toggles.AutoUnlockWorld.Value and Bridges.BuyWorld then
			for _, world in ipairs(Worlds) do
				local unlocked = false
				pcall(function()
					unlocked = TeleportController:IsWorldUnlocked(world.Id)
				end)
				if not unlocked then
					Bridges.BuyWorld:Fire(world.Id)
					break
				end
			end
		end
		if Toggles.AutoEquipPets.Value and Bridges.EquipBest then
			Bridges.EquipBest:Fire()
		end
		if Toggles.AutoEquipSwords.Value and Bridges.EquipBestSword then
			Bridges.EquipBestSword:Fire()
		end
		if Toggles.AutoEquipTitan.Value and Bridges.EquipBestTitan then
			Bridges.EquipBestTitan:Fire()
		end
		if Toggles.AutoHatch.Value and IsAllowed("Star") and Bridges.OpenEgg then
			for _, label in ipairs(GetSelected(Options.StarWorld, WorldLabels)) do
				local eggKey = "World" .. tostring(WorldLabelToId[label])
				local actions
				pcall(function()
					actions = AutoActionController:GetActionsForEgg(eggKey)
				end)
				Bridges.OpenEgg:Fire(eggKey, actions)
			end
		end
		local questAllowed = IsAllowed("Quest")
		if Toggles.AutoMainQuest.Value and questAllowed and Bridges.QuestCollect then
			Bridges.QuestCollect:Fire()
		end
		if Toggles.AutoNextWorldQuest.Value and questAllowed and Bridges.GlobalQuestClaimAll then
			Bridges.GlobalQuestClaimAll:Fire()
		end
		if Toggles.AutoSideQuest.Value and questAllowed and Bridges.SideQuestAcceptRequest then
			for _, questId in ipairs(GetSelected(Options.SideQuest, SideQuestIds)) do
				Bridges.SideQuestAcceptRequest:Fire(questId)
			end
		end
		task.wait(1)
	end
end)
LocalPlayer.Idled:Connect(function()
	if ObsidianLibrary.Unloaded then
		return
	end
	if not Options.AntiAFK.Value then
		return
	end
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)
task.spawn(function()
	while true do
		task.wait(600)
		if ObsidianLibrary.Unloaded then
			break
		end
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)
ThemeManager:SetLibrary(ObsidianLibrary)
SaveManager:SetLibrary(ObsidianLibrary)
ThemeManager:SetFolder("TempoHub")
SaveManager:SetFolder("TempoHub/astral-simulator")
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SaveDefault("Mint")
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
AutoHideOnce()
SyncToggleVisual()
end)(...)
