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
local f4
local fX
local f7
local f_
local ga
local fV
local f5
local f8
local f0
local gb
local f3
local Omni
local f9
local f1
local gc
local Fluent
local function fn19(S)
    local hk = not S or not S.Parent or not S:IsA("BasePart")
    if hk then
        return false
    elseif S:GetAttribute("Died") == true then
        return false
    else
        local attr = S:GetAttribute("Health")
        local hl = (function(dY, dZ, d_)
            if type(dY) ~= "string" then
                return false
            end
            if #dY ~= dZ then
                return false
            end
            local d0 = 5381
            local d1 = buffer.fromstring(dY)
            local d2 = 0
            while d2 <= dZ - 4 do
                local d3 = buffer.readu32(d1, d2)
                local d0_1 = bit32.bxor(d0, d3)
                d0 = bit32.band(d0_1 * 33, 4294967295)
                d2 = d2 + 4
            end
            while d2 < dZ do
                local d4 = buffer.readu8(d1, d2)
                local d0_2 = bit32.bxor(d0, d4)
                d0 = bit32.band(d0_2 * 33, 4294967295)
                d2 = d2 + 1
            end
            return d0 == d_
        end)(typeof(attr), 6, 472614556) and attr <= 0
        if hl then
            return false
        end
        return S:GetAttribute("ID") ~= nil
    end
end
local function fn78(a4)
    local is = f5()
    local it = is and f0(a4)
    if it then
        local it_1 = CFrame.new(0, 0, fX.FarmDistance)
        is.CFrame = CFrame.new(a4.Position + Vector3.new(0, 2, 0)) * it_1
        is.AssemblyLinearVelocity = Vector3.zero
    end
end
local function fn82()
    return fX.AutoRewards
end
local function fn89()
    local jh = { "EnemiesOnRangeIds" }
    local Cache = Omni.Cache
    local jj = Cache:Get(jh) or {}
    f9(jj)
end
local function fn95()
    local hT = {}
    local hV = Omni.Shared.Gacha and Omni.Shared.Gacha.List or {}
    for k in pairs(hV) do
        hT[#hT + 1] = k
    end
    table.sort(hT)
    return hT
end
local function fn108(E)
    local g5 = E
    local g6 = {}
    if not g5 then
        g5 = {}
    end
    for k in pairs(g5) do
        g6[#g6 + 1] = k
    end
    table.sort(g6, function(I, J)
        return tostring(I) < tostring(J)
    end)
    return g6
end
local function fn165()
    f1("General", "Achievements", "ClaimAll")
end
local function fn171()
    Omni.WaitInitialization(Omni)
end
local function fn251(cN)
    fX.StarDelay = cN
end
local function fn288()
    return fX.AutoAwaken
end
local function fn311(aI, aJ)
    local ie = not aI
    local ig = {}
    if not ie then
        ie = not aJ
    end
    if ie then
        return ig
    end
    local ie_1 = gb(aI)
    if not ie_1 then
        return ig
    end
    for i, descendant in ipairs(ie_1:GetDescendants()) do
        local ie_2 = descendant:IsA("BasePart") and descendant.Name == aJ and f0(descendant)
        if ie_2 then
            ig[#ig + 1] = descendant
        end
    end
    table.sort(ig, function(aQ, aR)
        local h9 = aQ:GetAttribute("Health") or math.huge
        local h9_1 = aR:GetAttribute("Health") or math.huge
        if h9 == h9_1 then
            local h9_2 = aQ:GetAttribute("ID") or ""
            local ic = aR:GetAttribute("ID") or ""
            return h9_2 < ic
        end
        return h9 < h9_1
    end)
    return ig
end
local function fn429()
    f1("General", "Attack", "Click", {})
end
local function fn439(cx)
    fX.SelectedEnemy = cx
end
local function fn492()
    if not Omni.DataLoaded then
        Omni.LoadData(Omni)
    end
end
local function fn505(aZ)
    local ip = aZ and next(aZ)
    if ip then
        f1("General", "Attack", "Click", aZ)
    end
end
local function fn532()
    return fX.AttackDelay
end
local function fn535()
    return fX.AutoIndex
end
local function fn591()
    return fX.PunchDelay or fX.AttackDelay
end
local function fn600()
    return fX.AutoAttack and not fX.AutoFarm
end
local function fn602(a2)
    if f0(a2) then
        f9({ [a2:GetAttribute("ID")] = true })
    end
end
local function fn617()
    return fX.AutoFeats
end
local function fn632()
    return fX.AutoStats
end
local function fn709(d6, d7)
    if type(d6) ~= "number" then
        return false
    end
    if d6 % 1 ~= 0 then
        return false
    end
    local d8_1 = bit32.bxor(d6, 1540483477)
    local d8_2 = bit32.band(d8_1 * 403 + bit32.lshift(d8_1, 24), 4294967295)
    local d8_3 = bit32.bxor(d8_2, bit32.rshift(d8_2, 13))
    return d8_3 == d7
end
local function fn721()
    local Data = Omni.Data
    if not Data or not Omni.Shared.IndexRewards then
        return
    end
    local iR_1 = Omni.Shared.IndexRewards.List or {}
    for k, v in pairs(iR_1) do
        local iR_3 = Data.IndexRewards and Data.IndexRewards[k] or {}
        for k2 in pairs(v) do
            if iR_3[k2] ~= true then
                f1("General", "IndexRewards", "Claim", k, k2)
                task.wait(0.15)
                f1("General", "Index", "ClaimReward", k, k2)
                task.wait(0.15)
            end
        end
    end
end
local function fn726(L)
    return L and L[1] or nil
end
local function fn733(bN)
    local jb_1
    local ja_1
    if (function(dY, dZ, d_)
        if type(dY) ~= "string" then
            return false
        end
        if #dY ~= dZ then
            return false
        end
        local d0 = 5381
        local d1 = buffer.fromstring(dY)
        local d2 = 0
        while d2 <= dZ - 4 do
            local d3 = buffer.readu32(d1, d2)
            local d0_7 = bit32.bxor(d0, d3)
            d0 = bit32.band(d0_7 * 33, 4294967295)
            d2 = d2 + 4
        end
        while d2 < dZ do
            local d4 = buffer.readu8(d1, d2)
            local d0_8 = bit32.bxor(d0, d4)
            d0 = bit32.band(d0_8 * 33, 4294967295)
            d2 = d2 + 1
        end
        return d0 == d_
    end)(typeof(bN), 8, 2851454103) then
        ja_1, jb_1 = pcall(bN)
        local jc = ja_1 and (function(dY, dZ, d_)
            if type(dY) ~= "string" then
                return false
            end
            if #dY ~= dZ then
                return false
            end
            local d0 = 5381
            local d1 = buffer.fromstring(dY)
            local d2 = 0
            while d2 <= dZ - 4 do
                local d3 = buffer.readu32(d1, d2)
                local d0_5 = bit32.bxor(d0, d3)
                d0 = bit32.band(d0_5 * 33, 4294967295)
                d2 = d2 + 4
            end
            while d2 < dZ do
                local d4 = buffer.readu8(d1, d2)
                local d0_6 = bit32.bxor(d0, d4)
                d0 = bit32.band(d0_6 * 33, 4294967295)
                d2 = d2 + 1
            end
            return d0 == d_
        end)(typeof(jb_1), 6, 472614556)
        if jc then
            return jb_1
        end
        return 1
    elseif (function(dY, dZ, d_)
        if type(dY) ~= "string" then
            return false
        end
        if #dY ~= dZ then
            return false
        end
        local d0 = 5381
        local d1 = buffer.fromstring(dY)
        local d2 = 0
        while d2 <= dZ - 4 do
            local d3 = buffer.readu32(d1, d2)
            local d0_3 = bit32.bxor(d0, d3)
            d0 = bit32.band(d0_3 * 33, 4294967295)
            d2 = d2 + 4
        end
        while d2 < dZ do
            local d4 = buffer.readu8(d1, d2)
            local d0_4 = bit32.bxor(d0, d4)
            d0 = bit32.band(d0_4 * 33, 4294967295)
            d2 = d2 + 1
        end
        return d0 == d_
    end)(typeof(bN), 6, 472614556) then
        return bN
    else
        return 1
    end
end
local function fn760(cv)
    fX.SelectedWorld = cv
    local jw = f_(cv)
    fX.SelectedEnemy = gc(jw)
    f7.SetValues(f7, jw)
    if fX.SelectedEnemy then
        f7.SetValue(f7, fX.SelectedEnemy)
    end
end
local function fn770(ae)
    local hr = {}
    local hs = Omni.Shared.Enemies and Omni.Shared.Enemies[ae] or {}
    for k, v in pairs(hs) do
        for k in pairs(v) do
            hr[k] = true
        end
    end
    local hs_1 = gb(ae)
    if hs_1 then
        for i, descendant in ipairs(hs_1:GetDescendants()) do
            local hs_2 = descendant:IsA("BasePart") and descendant:GetAttribute("ID")
            if hs_2 then
                hr[descendant.Name] = true
            end
        end
    end
    return f4(hr)
end
local function fn782(b9)
    b9.CreateButton(b9, {
        Title = "Join Discord for Dupe / Keyless Scripts",
        Description = "Copies the invite link to your clipboard.",
        Callback = function()
            if setclipboard then
                setclipboard(f3)
                fV("Discord", "Invite copied to clipboard.", 4)
            else
                fV("Discord", f3, 8)
            end
        end
    })
end
local function fn797(X)
    local Server = ga:FindFirstChild("Server")
    local ho = Server and Server:FindFirstChild("Enemies")
    if not ho then
        return nil
    end
    local World = ho:FindFirstChild("World")
    local hp = World and X and World:FindFirstChild(X)
    if hp then
        return World:FindFirstChild(X)
    end
    local ho_2 = X and ho:FindFirstChild(X)
    if ho_2 then
        return ho:FindFirstChild(X)
    end
    return ho
end
local function fn820()
    local i3_1 = Omni.Shared.Awakenings.List[(Omni.Data.Awakening or 0) + 1]
    if i3_1 and (Omni.Data.Power or 0) >= i3_1.Power then
        f1("General", "Awakening", "Awaken")
    end
end
local function fn829()
    local hJ = {}
    local hL = Omni.Shared.Maps and Omni.Shared.Maps.List or {}
    for k, v in pairs(hL) do
        if not v.FakeMap then
            hJ[#hJ + 1] = k
        end
    end
    table.sort(hJ)
    return hJ
end
local function fn872()
    local h0 = {}
    local h1 = Omni.Shared.Stars or {}
    for k, v in pairs(h1) do
        if (function(dY, dZ, d_)
            if type(dY) ~= "string" then
                return false
            end
            if #dY ~= dZ then
                return false
            end
            local d0 = 5381
            local d1 = buffer.fromstring(dY)
            local d2 = 0
            while d2 <= dZ - 4 do
                local d3 = buffer.readu32(d1, d2)
                local d0_9 = bit32.bxor(d0, d3)
                d0 = bit32.band(d0_9 * 33, 4294967295)
                d2 = d2 + 4
            end
            while d2 < dZ do
                local d4 = buffer.readu8(d1, d2)
                local d0_10 = bit32.bxor(d0, d4)
                d0 = bit32.band(d0_10 * 33, 4294967295)
                d2 = d2 + 1
            end
            return d0 == d_
        end)(typeof(v), 5, 248602996) then
            h0[#h0 + 1] = k
        end
    end
    table.sort(h0)
    return h0
end
local function fn926()
    local Data = Omni.Data
    if not Data then
        return
    end
    local iz = Omni.Shared.TimeRewards or {}
    for k, v in pairs(iz) do
        local iz_1 = Data.TimeRewards and Data.TimeRewards.Claimed and Data.TimeRewards.Claimed[tostring(k)] ~= true and Data.TimeRewards.TimePlayed >= v.Time
        if iz_1 then
            f1("General", "TimeRewards", "Claim", k)
            task.wait(0.1)
        end
    end
    local iz_2 = Data.DailyRewards and (ga:GetServerTimeNow() - Data.DailyRewards.Start) / 86400
    local iA = iz_2 or 0
    local iA_1 = Omni.Shared.DailyRewards or {}
    for k in pairs(iA_1) do
        local iA_2 = Data.DailyRewards and Data.DailyRewards.Claimed and Data.DailyRewards.Claimed[tostring(k)] ~= true and k <= iA
        if iA_2 then
            f1("General", "DailyRewards", "Claim", k)
            task.wait(0.1)
        end
    end
    local iz_4 = Omni.Shared.PlayerLevel.List.Rewards or {}
    for i, v in ipairs(iz_4) do
        local iz_5 = "Level" .. tostring(v.Level)
        if Data.Level and Data.Level.Amount >= v.Level and Data.Level.Rewards[iz_5] ~= true then
            f1("General", "PlayerLevel", "ClaimReward", v.Level)
            task.wait(0.1)
        end
    end
end
local function fn938()
    local Character = f8.Character
    local hi = Character and Character:FindFirstChild("HumanoidRootPart")
    return hi
end
local function fn940()
    return fX.GachaDelay
end
local function fn974()
    fX.Running = false
    fX.AutoAttack = false
    fX.AutoPunch = false
    fX.AutoStats = false
    fX.AutoRewards = false
    fX.AutoIndex = false
    fX.AutoAwaken = false
    fX.AutoFeats = false
    fX.AutoFarm = false
    fX.AutoGacha = false
    fX.AutoStar = false
    pcall(function()
        f1("Player", "AntiAfk", "SetValue", "LastGacha", "None")
        f1("Player", "AntiAfk", "SetValue", "LastStar", "None")
    end)
    pcall(function()
        if Fluent.Destroy then
            Fluent.Destroy(Fluent)
        elseif Fluent.Unload then
            Fluent.Unload(Fluent)
        end
    end)
    if getgenv().BWFAutoFluent == fX then
        getgenv().BWFAutoFluent = nil
    end
end
local function fn1010()
    return fX.AutoGacha and fX.SelectedGacha ~= nil
end
local function fn1022()
    return fX.AutoPunch
end
local function fn1026()
    return f4(Omni.Shared.PlayerLevel.List.Stats)
end
local function fn1067()
    if fX.SelectedGacha then
        f1("General", "Gacha", "Roll", fX.SelectedGacha, {})
    end
end
Fluent = nil
fV = nil
fX = nil
local fY
local fZ
f_ = nil
f0 = nil
f1 = nil
f3 = nil
f4 = nil
f5 = nil
Omni = nil
f7 = nil
f8 = nil
f9 = nil
ga = nil
gb = nil
gc = nil
local ge
local f2, gh, gj, gl, gm, gn, gv, gw, gy, gz, gA, gB, gD, gE, gF, gG
local gC_1
local gH, gI, gJ, gK, gM, gN, gO, gP
local fW = (buffer.fromstring("<  $'n{{3= <!6z7;9{\x157 !58\x195' 1&\x1b;3#5-{\x128!1: y\x061:1#10{&1815'1'{85 1' {0;#:8;50{\x128!1: z8!5!IYkfH]V%&lw,ZUBuKj30*QjHYl[LDALOAH}BDCY^aVHPzOyx+7?R?+Bj59LEMy=l]&U6CdR[RTCRSrYRZNrQ&O5/%OrYle-(!e@Dv:6Ip/_&!QS=vGPTAPaZRRYP7$XC]0wlAUfcS!Cb0_SL9OJEj9zAY)n{jmYXCj@YIBXR}/XqW]f;6PM}Kt#iQ1NN(@P4X{juCJCERCBcHCK_?9R7iRBH@}E#}YD8/6$t_mheV0k/{TSY{TONI~UTQY.=vAU?xs$.x?pyty}NZI1KPIOlvyOKXIBKHFO06{TrIauPb$S,sE^Q[OwDa7D,7f;s,k]KAODCDMRNmaoS-l8&,*eFuJy8FU.)D{TpUPkuljEH@D{L^H[Mz]#im=_RR}cK*{hY:)c&3j!kuh{gzWEBqWU^WYV02(t85YJ@-I*!Qp+dA]NQf40Q_e8gQXQW@QPg@UFK7(#/%#/x3UU4lt@(fu1+]IytNpoH[Dm@Z]HGJLP&*9.C3=[=p9oB*ZfP3kjyFA:si_V_YN_^}[YR[PQM=]LkwJC=RYIW!s!ls%IbY8wLEVA@HC:QOKu#]EuHi{DHTW]&45J_[8-5@I8bVWL\x03pWBQGD?5;iP{DDz%&_x?{o^a3B$=z^T/~[SVCh_M[H^Iv&k/skcU2.}NJ3$*rnAH/;q*Ph]]HJB\tmLEHPT5z^4,,kMIi.m10hz&Jif,nKazGZBKyj1+MDmW{RrK;4l#YZj^/D.LyHJFLSK)>:529=5bGXLT.Ra@z$i=dF,pjeu3h9)Mfu#tV]VAR_4F{;[NdYbWKB%QMb.:GA9wU.o9&GSvZRUK0#:)c,p_@+0;E!!=+Q_E4@0!yiQ.{AgKCD1Pb2DD=Tg)$s^^5GU7du{WG1$b[6#i;q@WSFWf]UU^WGsKF-x)#iWF9N*uP*#6MRV4qLQI@4#hQo)=89G,QPOj_TLkUUbUk_Ro7W;yMLWkLYLKX#3)da92vs2xT(oj)}H9M)MVegN]NG8433?nBu:KAy-qCXy=nba_%Nd$FJ3k_^Ek^^KIAk5Rbe}E75.Z#de!![7EpT5VecBoDMBKIHuM*n%?]7B9D2NE9M,1KFG0Q@zkSJROfdQzQ5o=ocJ8D})2k]jHZR_R-_5-HpFOF@WFGfMFNZ3FAT#;meq.9zRC}iiE@,UnXIITSZN.apZ7_+yCa3:YChA$7XhZgRQG[b@QdQQWLGPQ@MajQL=hbZ{z+(s6YMs*lt`AWGVMTPMKJ@c6R=!WXyo*DiO9XK_%2&[uHUMD6](!Wi3sM}lPP(1BqRdglhgMv;?lfGjAHGNLMFTz.Bz[3b!^soFxiR$S0?OKluWFsFF@[PGFWr5xeDz)sVY4Zq4L3fz4LxYt_VYPRS&M$E+$U3ggJ9SV,O2eT;1cBn_HLYHoXYYBC0$Ro?DvvT?qmTp-4Wb&1{J]YL]zMLLWVH^m[@r;{jnpYKb1BQjoo{_X_[_LS}SO;s@UKh&ylJq1#fb.4eqpHh^W^XO^_hOZOUMQwLvDA%ShsBi6htEATBJWKDbc-8K;drmv)hXq:9:[h/#*fZceTCGRCrIAAJC@O,e$BnHJX{NMf{vJ5qpDE^wTPEB,e^AuF}:xUuizS/(aQ+V?iN[N~HUJ^UMTTmVTWI4(y4::(vTvUg!-<!R.A8bAyZ2znO_Z:[VI(_*yy+l@gFk@IFOML,w5{gCvgh4%hbS$(Ylh&,wXU]Yyo8o?7pmbx-}G5(7wZpkx_mzlZKKVQXLlz?AGJTB?1QV%PEf7PRW,uTWPD]EL=V%5OD9;a@Eng5y[,U[#SmJYF\x0boBX_JEHNP0z+cx}mV8EfqL=gxNGNH_NOx_JY;w=R{l*+x.a3D}++7hDLKsXtZ:?Dw}4K;JT]yi@s(nDd}bNLVMW?flG@Ee!MI1FQ(6:QW6Sxl{ONU{M[Q_T=drZbRO-2;-=2{D%{9bT]TRETUbEPC:MPED6dezs*cZvh%TZ]TA[CPD[Awq-,g1.$$_Rk_.q.gQ@@]ZSGI//jlD4G%@=H1aJsp)v{F[CJ=!e@x,AuTO@ZSdjsMDTqEanHJAHmLEHPaCNZb*8rR{H7=Bgw:lZKnVJ^K-6hUqxU-MO,b3H={^g-lQLT]IBp*%{M1xvh#qGp+OpJ5_|@MUI^`IZI@Gc0H}+9MF4LRLlkq@WSFWa^[VW@^Hi5o4y3+;50V});#>#+0-EN27meHz77#Y={n*^hYNJ_NxGBONYweYGsvooGq0@V~C^FOqE{46c+,fryA-!fn?&rMqPST@YABC+mAAR$uu+onQ6B8dR[RTCRS`XE[SlDXhrkyZao_q^YSq^EDCt_^[SchLjU+JbWNfL@A*v;m/AR}cyh@RR/(ly3t|J[yNCZJ(Uazd943;BQCd:mhNYoROW^0z!E6wkSps;^pFeeDiBKDMONb9QS.X.h*0oD&izGDD[&fOmU+g,8*}J4=z9#%7>5qwn/z#08.c8AaA9CzxHxNGNH_NOnENFRZ,/akLR]2~JKP\x1f~H^TZQ3Ui{[!_@,I3zNOThOZOH5Bt-r(@X[?G,HgUUCKDJ_jOHCGTpCJIEOR_sGF]sFFSQYdy^/+m)d*)Cm|GEFHM#eA.+#OO{sv?%yQe@HMXsDV@SERA0%d^oN[vkL_@iD^YLCNHb(r#2A!G@uBOVFP+X!vY,o%wHIk5apQ|W^QXZ[xxAKpu6utm?vBCX\x17t[V^Z\x17~YSRO1ALKk]YJ[PYZT]wKH4D2e%%0lXYBdCIHUfZeXxd;OyVFyH_[N_~HUJ^UMTtfVQ#o[ZA\x0eoZZOMEihALLrQw{@IZMLN#4DI98:@pVdmk_^E\niFKCG\nxO]KXNYh^HBLG@GNZapFh$a*/kMODMM(49$)*4k,JoOtVGrGGAZQFGVQ{b_JsiHKLXAYsmtk}5)c+x.WNYUSKE@M%DS!]A8NtCVJOEGRCBuRITGACmO^yOX\\CIOLt0uY;7pRCdREAREc^ZRyX@lXYB\rlZLFHC*_w2kZVH*#bU0j/G#v6v,{ONU}[YR[TK%?}3$xGRYvJdi3f(9#S(HwFQU@QgX]PQF=Z{NpFOF@WFGdB@KBZ1bVWL\x03pSJM\x03dB@KByDYAH5[r1+gCU*0gSRI\x06uVOH\x06aGENGwAPrEHQA;fSo[UffDUeDRBDOE@OURbSD@UDuNFFMDI[rCTPETuC^AU^F_t@AZ\x15tAATV^it}eXE]TXxP3hy5:o`QFBWFgQLSGLTM,4-.--#$53/Jl}hy~JKPySJZQK~HAHNYHIjLNEL}KBKMZKJk@KCWwAHAGPA@sKVH@i_V_YNn[X!mcbtLQOGgQLSGLTMGL^eU:5)HlkRze@HMXsDV@SERmH@EP{L^H[MZrCTPETb]XUTCl]JN[J{@HHCJoHBC^tCQGTBU|MZ^KZkPXXSZrCTPETsDEE^_uCJCERCBuRGTbSD@UDrMHEDS{ZLKMPFN(,9FjMGF[qFTBQGPrNNJ}_N{ICTYh]]HJBmLEHP,$15%>3%??2bFAvQ-we3g5-5*$./?:;+<yD@H\x7fHZL_I^nSW_h_M[H^IvJG_CTwZA/%lXYBjLNELXLmWHEJ@\x04wPEVjHCH_LA!:)!xDIQMZdM^MDzLH[JAHKELpFBQ@KBAOFEQLNlEEPFWwCBYwBBWU]dPQJdQQDFNeDiBKDMON]vTEbTCGXRT138-%8, 6.nL]zL[_@JLJIO4).e3brU@SeDM@X>-2.>+6#+mUHQIJ[Y_pDE^wTPEByMLWhMV[P|HIRtSYXEeSB`WZCSEmYXCeBHITj^_DlJHCJk_^Ez_DIBt@AZe@[V]mYXCjIMX_TB_C8/jvjo[ZA}ZOZ]~H^TZQVQXq@WSFWfSP\x00\x00\x00\x00\x00\x00\xe8?yMLWkLYJwUXXVUW_'%9:62,:~]SVvSFShNYoROW^\x00\x00\x00\x00\x00\x00\xe0?xE_DNCDMqS^^PSQYDVYDYDO[\n\xd7\xa3p=\n\xc7?pFWWJMDPQBYTC^XYgQ@bUXAQ62;)#+6mC_eIBC}ALTH_^?.;,2/1eBYY^YPpQRUAX@qPST@YAlA[KGZLERAREDRjKHO[BZz]FFAFOvT_TCP]*.6+=*}ALTH_~EL_HIeSEOAJwBBWU]LDCNL[zM@YI_qJHKE@pKIJDA`WA[HWnSNV_xEX@Ia]PXP~_BGXgZG_VLZRO]rORJCxQBQX|ABB]\x1b41;3wOVNSe]@^VeXE]T(,)-?iTWW`JFGpWD[findaDWN\xa4\xd5\xcdY\x15}\x03\x96 \xabs\"vZCQ\x9f1\x9f=\x1e\x1b\xf6\xf4O\xdd\xa1\x11\xcbGO%bMVA~RZ]hBNO;-%8R%\xd71`LDCQEQE]ZX^mHRUuWTSwRHO|FUJVFE`ZhlHOeAF{AsX_RpTS|PI^:K5M%\x05\x19#wQ@\x1eLXqtI3\x1b\x18$[R\x082"))
local gg = (buffer.fromstring("\x1a-$'),h-&-%!-;h.':h< -h;-$-+<-,h?':$,h.:'%h; ):-,h,)<)h)&,h$!>-h?':#;8)+-f_2!LsDL9S9Zw&03[Ja5R,%xoqT\x1479<=<x/1,0x\x1e4-=6,x\n=6=/=<vJfklrK)-s](fDJF4Z4oU)keSZSUBSReBWD50O:-C+{(tq/9ZSsSu^mGx)uie,}aAFk^^KIAnOFKSO(p2*vFV-ATZDdsNo;@l1qr1hK4Ap#{\x14%26#2\x04;>32%Q!ECCR?-7g6W(7xSj@Uowt?0AK0@.`UU@BJeDM@XeWH,-5)?[^1c#nyOQ%#IAyWcTW2Izm~[N[vU[^_^Y{30x,:vNWJxW;@,y/yjAFjn=ir3hJmsGF]uSQZSMHV%YZD02G9gWx*=HQr2!4Rgs0g4ruaASPEBFVEG^Q%bSC;WsH=BOJX.*zhf}f*6yZDDF(I|JCJL[JKx@]CKEl$vEU-!Kqn8B;H@^(:/.l?#d,UpQ|W^QXZ[w;sC0%EpbGrMsos+IaJIvRq08({4r-pFBQ@KBAOF2F-@wGL2Eye7i0#@lS(Gy}fPAMv;@dB@KBgQLSGLTMSG6VGIJ{m{q[^.9u},n6s?L+VuA@[uCU_QZT/yR@@mg9Rh[x]$LzZl)78=r}^gKcBoDMBKIHS03JB.ffCL,QmcW2XH?RrEb8qtw/`TUN\x01rU@UR/v*4X;_Wj&.##LBcRPUr_0x-F(RlNEDH[H@HCY^w4*fTiTo@q%:D?FSppLu(pfcFvWTSG^Fym^.4k)Z):JweKdo43h)!%&rvII{8Gb@MMC@BJ^]91Q^M(9Qb2wvD!{1ewXaON(MD=!uBOVFP0R1x:Ha[k,LLF]Q?{GM3vOIWGL(mJOv@QsDIP@$r/m.)Te98TU5?/ePt?MJw2:+ArUpQRUAX@44I@hfNTLzz0J}?Iz.l9?vc?h*)O_~C^FOo7o:Fd3Fn/a5[gpbIGENKQKe(RFcVeg[VNRE{RAR[$0EC[xjApu+f)=1qF}i*Pkyndq`gSRI`JSCHR:dPwxnNC4o1r9%/2i;6@:bfIDLHdIIN@YdT6Zp{H$aq$^0U!*3g{y$LJUOIBBEB@GWALtUaV-+xlX__-iqv#_KK*b+t@AZe@[V]CSuL%5%GK(X1RZENfFUMJ&(w;OJC[C#&;S&}4=wDM@e=2m,Cp=/}a%7vzAlpTSTPTGXvXD6suitS&gQYA6YE/IUhBRIoHxEFFY(:NW4h6cJj:&yoXjKOD+VS3c/uz=/fGjAHGNLM)=fB!}}=!6c%6j%!J:}+?h+$JvSHENbCJG_6ert@w=S(Uon(%7#)RA4nSOrTV]TqPYTLN)+OMp#)(7ax!r7ss*@u?:=|[HWuvGK*Ew_BS^Coz965F?zvJGd#}fp.: 78#CMIF(P+$n4-}6iZqB1N9I!cf%}k]:##/4+fv1t:@W]Y_*uMlonA]:VVRg%?[qLQI@=g6Lggfs@#:nnsD(983&DUaCq+P`ABEQHPH?a)g7T]xIu^#EjJII3QnE#A&ED_C^NM&gHF,;r+66bQ!]2[cfKK(OiwH~C^FO1&gkz_XIs$b5g6::Io0H;vUOxkThDEENH_BDEX*Misa#g,?GI&1*F}]Jxfb@QdQQWLGPQ@Kd8W2xb$!FSyg?3OszvF@NDBIjuJrb86@V_]/Bk3OLjll_Unqkh]]HJB\tmLEHPgt[cm:23YfYxD2Q[aGz]H]m[FYMF^GfCvH6Pa*!J{r0sO7D7fGjAHGNLM?}yq6S%D4lNBHYKxZxi9u`TUN`UU@BJo2(x#C*FGg=/_$.ZCt*$wLEVA@v7/X[]LO3FTe$[TWP?0nLWBeTCGRCrIAAJC[E}P}VwKwZu[]nnmTjM^AhE_XMBOI^p9bo^d9vw0.XjZ{0gZG_Vax*}Cbo4f]p=[/Yzav,Ar6b:vBCX\x17t[V^Z\x17~YSROm$Dp,H?.gOPjixE_DNCDM41NMJ$%k6WgX.*6wr6c$tBJWjMJWJBOJYBWJLM^GC_$E0?}peQPKwPEPW)DsJ0XO+V@{,)cKs:0Nc[FXPqS@FfY8XSy%+Q{BPD,=wm6l|^U^IZWe*hZ@Y@W:*Hcf#:eE47,dSFZ_UWBSReBYDWQS7AC60DcnYFq^YSq^EDCt_^[Stmk4-eWDV7y;JbDFMDiC9Y+U90/0XwFC40HTMoo)\x1568=<=y.0-1y\x1f5,<7-y\x0b<7<.<=wPLZ_^U/L=tSXN&#wAQ5#$TqRQ0~F_GZ{]%Og1f)wqaH=Uw#V]ipMRNMCHQEYWt^3{$S)Pv[q1]w%yUiHKLXAY#e@7NDaP]LxHIz&)s0pi|m\x0bj^_Dv\x0bXBLEJG\x0bMJBGNO\x11\x11'.'!6'&\x05#!*#&fK%jp[J+J]WRWKY_lS4Y*U,X&oaPj1W}z3%lXYB~YLY^w[sF]-_NxmTUyFgrSEUD_FB_YXKa(.5b7S?-#?p|AEMzM_IZL[BLb?Zj+Kq:XPYzGZBK+mPsziHWm-h?J*leS9fATGFVWE5(?V5yvv8d8G%URZXEONQA_F_FU-]HW08d+m}Cx_DDCDM2%((*lMTUC@Ej.64~ID]M[a==9Z]EB3(u2.k7,uHUMDr/gf]IgegFM]mr%C*~TXYa{7iJUnVgIvY0zvk#KnSNV_,92A!K@FIU_f,J,gHl]JN[Jk]@_K@XAMtx)V^nHiOMFOjKBOW)Lm^?fcxi)uHgSRI\x06vSHENyONES#*j:;vrDUUHOFR$cpwQ(RKn9Eic.)),,:8+:_h)D[EnRKp(f\x16=6>*s?: 's!65!6 ;67}fW@DQ@qJBBI@QL3C!+{!aCHCTGJn8SHU72G]F8hc~_rYP_VTUoEqSTpjnvt-qED_bUGQBTCdq2PaT2[9tERVCRcXPP[RtU{vhbZeX[[D]el,c[X)+Ce(dGiHKLXAY8/26H7nV4PUenIZE;J6Amalaf@-B1Zi^]I^HS\x1b~U^VB\x1bwRHOdEhCJELNO2M+1iK&q0wAHAGPA@aJAI]0rWkxxEFFY3ll]m{!CUdJNmxEX@I^?9+Uq4UVnUhARH^JWVWo$Rzn2p_pueSBB_XQELESQ.trmJwUDcUBFYSUi;dK1n{ZY^JSKqE_inX,@qrNTCGBU,_d4bI_3[hCH@Ti_B]IBZC*nfbEPCuC^AU^F_]Rqa}[YR[~_V[C3n+KE(vBCX\x17t[V^Z\x17qRVCDrUFYNo={qy7[CXopDE^pFPZT_7zeE)yOFOI^ON}EXFND[gBJOZqFTBQGPVNcu`q\x17vBCXZVC^XYvBCXdCVEU{7C&d_TF32NI$QeF3CRhD]**54iaLYUpUhTYA]Jt]N]TpGguZ]WuZA@Gp[Z_Wc[FXPpF[DP[CZlyho[ZAhB[K@Zp[PXLqGZEQZB[uCJCERCBcHCK_aW^WQFWVe]@^VoIK@IlZGXLG_FbT]TRETUvPRYPfPYPVAPQp[PXLcDWH\x05aLVQDKF@sGF]`WES@VALi_V_YN_^iN[H|^OzOOIRYNO^l]JN[J|CFKJ]h^W^XO^_hOZOn_HLYHzDCIBZ|JN]LGNMCJ^dsBUQDUrEDD_^rW_ZOdSAWDREbT]TRETUbEPEwAHAGPA@wPEVqED_bUGQBTCa@VFWLUQLJKg@UFpQXUM!+ePPEGO`AHE]~BOWK\\}ZOZ]pMIAvASEV@WiOMFO\x0ejKBOW>&91#=IQk*1WJLTXM9srT{>)<gv$#=nbdoZZOMEjKBOWbUXAQGvET.ucD_bTCGXRTdFWpFQUJ@Fh^ZIXSZYW^7>50*'31>&@TZ[V@]RFV{^EHCoNGJRaCRuCTPOECuCGTENGDJC1$%.54;%66qED_y^TUHmYXC|YBODqTAT{D(I@lM`KBMDFG-3.(564'.sGF]\x12tS@_nEL_LNYH_|qY!XyF4MgSRIvSHENnOLK_F^+zgVAEPApEF{ONUjOTYRh^W^XOoZYuTyR[T]_^o[ZAhKOZ]bVWLpWBQ)VUDWNI@VvBCXdCVE9:+8!&/9\x9a\x99\x99\x99\x99\x99\xb9?~HYYDCJ^1,'=,*<*bWTa_RB^v@QQLKBVzGDD[9eMkVLW]PW^rDUUHOFR(>//25<(AO[MGJMObVWLeBQN}A[LHMZjDXbNEDiFKCGON-:):-,:}_T_H[VXQZJ(;piHKLXAYmBOGCKJuTWPD]EbC@GSJRnALD@HIpLVAE@W37)89(TBMMRPaV[BRDswD36,e_QXWZuDW@KQyDGGXsbUXAQGhIRO@_UFWB]S{RAR[pMPHAgKCDrrU@SRiTIQXzGZBKmFMEQoROW^vKHHWyF^L[2=>2:\x01<!90sLTFQwJIIV\x8d\x00\xb3\xa9|PX_cBCH\x1b\x97\x0e\x00eIAFQQ\x00\x03iEMJtQKL[NO!\x19t\x87\x04]I]Ihuge[*2\xa6`EPE`\xce`\xc2s~DE:,$9bEVIkQB]2& 7\xa8\xd3A\x95|VZ[tQB[C[r\x1dtXPW9-:bFAnB[>7<W^Uy]ZKZW\xcc\x01\x08\x02=\x169\x0b_\x15S\x0f48H\x04\t(0P\x07\x14+;J\x0e)j\x17"))
local gf = (buffer.fromstring("*6621xmm%+6*7 l!-/m\x03!67#.\x0f#16'0\r-%5#;m\x04.7',6o\x10','5'&m0'.'#1'1m.#6'16m&-5,.-#&m\x04.7',6l.7#7\x116-21b#..b#76-/#6+-,b.--21ly)V_LV*XF(#+tR6N]T.;Pk@Yq_vGPTAPqGZEQZB[g9$sj,oW?Xbm*F:_oF%/B&TaS^x/xwAHAGPA@wPEVhH2@ux3,qWc={F&=kwmWL@zo.I}xZ?hbCUETOVROIHY7u^Khjmi1iccSQAFu6%INm3&nri?yj[LH]LzE@ML[-M%8a#igyDKQry#xFDWql]#vSFK.5yOFOI^ON}EXFNZ*LmCqix$RHB+91fTb/Q&o4rZy5#~RK`GRA|CV]&].HG4RvQV,enMaY%ya3WOIT;]1_&rDMDBUDEdODLXMUYyDo7]v]/5PEI-6/-d:4$XkS3aFS@\x12vW^SKEi]/ps(^0mGO[7x.TB;}ftvJv7.wh7\x19<:=s\x17: 0<!7s5<!s\x17&#6s|s\x186*?6  s\x000!:#' oL^H}L_Y6j5jk6er]H*G?elj@rGpX,/(z)5a:%GaGENGbCJG_KArMF5ZgcR+.#7dI?0(Egn!Yr^ejdPQJ\x05fIDLH\x05w@RDWAVRSJ3+yF;#zN.H:aBF{P&sGF]uSQZSQ-@YW]IA4Utd[{EFXIbZtQ_lz!#WgJNC[GaXd;$0UJ#LPvDQQ-*1{o(q*;YWeyElBv@HUgNSbIHME&7Q1^f@vwXwv;-SDkN]7w@)aAsRQVB[C}jKsm^:@?}):zNyKti^4uLHMvv])VklM`KBMDFGVn[_tpF5Y_nL3=9&MiHnP8hlv+ZMnObI@OFDEr3h?7h[33ZD[+k^Lp$GM2mi0p4xaVDRAW@b=*uQU?5+-HSTJ(=GZ7=?Lu%(x48PgrcdPQJcIP@KQf[:]J7@}lfIUf4p;cZm{=Bdq^YSq^EDCt_^[SRnNu1d,AqI7s%gV_F8Y,9ACK@CF]Uy-z[]fO)L]umf-#XB!lO3GcZBr8lXYB\r~YLY^wL:n0OCHL&m_Tc71ZQ_I25#BesXS[_SE/-fB{X)jx3{+cFl-]Jd^l(UgskwszQZRVZL;3psH+P}/pOPP9qNT1fT5sh9Lja\x00'? =,i*&9 ,-i=&i*% 9+&(;-g}Wr5:T4|]p[R]TVWTf:3CQ8]B-]./m5(wG-z5!EOX(4403zoo$)3#/2$n''o&s$\n(\x04'9\x1419[#(H:%#7,2BGZRWV]i*-)r4u{vNsU9&9V5M5g&oMFMZIDr2koR?&yI/r}DF;lX6zOUPcFSfTeBQN%ugto8^o]KY3/MgIm;NL}G:/Gu!W[$xZQZM^SvK;/:Y{Ngs8Lp6}NiN-+;#m,;/atebVWLeOVFMWYFo!blUr$W%bdZaUuM0}pFOF@WFGfMFNZ{V!&4F[jKW$y}d9)MUy{oBPWdB@KB#%3^hqYKXrKk0Q7jfF;k}$^iLYL}PGQyfaJ#0{TsDWaEg}@g.=sY;uCk_^ExO]KXNY/-(^uYFx;8I.tMo^K1n}/uCJCERCBuRGT^&tS!WaZ[;Gb8{jT;0.OhARAHqXr{KjPjtl&9}#TX^;eQP?Od^pw3>q{a$Xc*EODgk#DdWAO*G77:59WVPxhKYOzKX^[(o:;d07U)o%(@hm#hlKzdSrCTPETe^VV]TMC&O#Xmiho)m#xm:,/fj[LH]Lm[FYMF^G-gA3VY0iM*8@LYw07tQJGL`AHE]E}2Zqz$LiH$2Ah]:LmeDqTOBIeDM@XsS[fWy&5;uP(h6y/h^%!rSPWCZB-hoHUq^}Dz@G!_P#o-jbUz&`[RAVW_pWN8/?FM5D+B6(7/:HQkzXsQ@n23(@//z1Yrzb_rCt;6SQ!?krkjLNELiHALTCn{L!VT=Pd7Kqd,[AWlkJgLEJCA@gQ2.At%6]BDsw?r[PxL2rDUw@MTDREa#o$e8ptl2oDs_ibWzkzOOZXP\x7f^WZBU#B?7q2#%HqN)%eKlXNCv(@wt/MYH&P_TF2[F&Ax-SkpfgJNC[G+JH$LWj)zLV5_Rw)RB)7K=mBEAI\x0cjEKDXI^_ohZ7N#p}&09Ys&\x08/4+({:77{:./46:/245{744+(ubC@GSJR&}MO=HuwOu@afolkW(9-tS@_kVi8us^giSa6CN#)H[DmSc)eBQNgJPWBM@FqViSyUJ(JpU((:5xWZRV^_HDGWDTToU{Vo)#Yre.r/i_NNST]I9#VRTIvb)Vr/ZWin,)pQRUAX@fw[^SIyWAs]Vy}x2RNPFH[NGYJBXD*P-8jdEvRR9,}8AQQRZPNGaoRxJ$K_UTi}9t@=4rk[|MZ^KZk^]0c&ZMmhIHd@}2CNXmZWN^HV-,wO=k!p2F4k3F(c,;mXXMOGhI@MU[CtZ0Co}+;Np:Wk_^Ek]KAODqwKpUlJ[)jd^^1qSXSDWZlx;V@p8R-o*ksK@MwlQLT]AD84Nf!Qw[xP+)%JzVUxCJYNO;q%GdQa^DFHk9Iiv/iDVQvQDWW/IN;qH2F{[{K2MlMNI]D\\k&immcp@)*.@1[{!rU_^Ci^LZI_H8GzpXSWO3(;v]V^JY&EH-6D{L9TV;ZgV05-(?('9)'4;Qo*)tC2=]$s\x1a>9i6gYOyC)^5b-yT&k/+.lXYB\rkL_@!*;xo(lMOB,?)\x1c158 <Sx=$W%8DP,LNK$[7yXYR_7e@UUkA5FL$S^QJ/f{ONUsT^_B.K:NFLLB5N6WsYUTs]4SyCb{8kmS7R{CTfGjAHGNLM&]%$%rbVxSUik_^ElOK^Y7SMCC.&])m[zgKRu!_P94RlE=YJRQU3rN^C[^MKmV!kwCzLF%iq6EPFYFGEARHBM)k5E?sOakL_@mL)*iY8w0f^K/7pGOA_YCBRN@ORkUfRRTQnv@I@FQ@ArJWIAR.kTDY9:+=$Q.O?;6L$ty],/PrORJC]WXPb[yu_yij!@qWU^WBPfFx7&ZHU]M=dSPDSE^\x16sXS[O\x16z_EBz[v]T[RPQ@%rJQradv}QY^ewfV&or6b.1F07FECXPZE@Ief{d7;TTqPST@YAd3m5=1m7%0pU@UTE1V8tB{^)6g.CCGZQZP_MCF_bKF]4vQDQVoWOh%Tx/EyGbVWLbWWB@HR4cx&$`AlGNAHJKnY]thbIyMLW\x18{TYQU\x18~]YLKo@GMo@[Z]jA@EMQ^~F_GZ(N_5ml.EK{8~JKPy^MRM*:}v:]qLQI@@vR4b+uB_SqITJB@:s%iPtgfb_GNYl7?7=.O4Jg)n_HLYHyBJJAH)f}RU_}RIHOxSRW_{J]YL]|JWH\\WOVmxi\x0fnZ[@BN[F@AvTEuTBRT_UP_EBeIPm$JVo}q)Mm9nSNV_{/1A&;8:zLELJ]LMnHJAHdR[RTCRSrYRZNjKJAa)POjTBS*{F[CJNv//n*[AwAHAGPA@aJAI]nXQX^IXYjROQYxNGNH_NOnENFRsT^_Bh_M[H^IyH_[N_xONNUTuDSWBSbYQQZSiKIBO*DW4fZ8wPC\\uXBEP_RTlN_j__YBI^_NjHYlYY_DOXYHqVEZs^DCVYTR~BBFqSBwEOXUtERVCRd[^SRExI^ZO^lRU_TL|JCJL[JK|[N]fJBEIV62hs+$lYYLNFiHALTbTEgP]DTOR6IHC[PSKAB_^jPOBMG\x03pWBQoNMJ^G_R3D,gSRI\x06gQGMCHn[[NLDkJCNVe@WBQTUcDQD^CDM_AHQ^JSiH^N_D]YDBCi_NNST]IO/YwLEVA@@,}VdCVE\x17sR[VNqVMpFQUJ@FuSQZSvW^SK~JKP~H^TZQz_DIBnOFKSlXYBlZLFHC(>6+s^KB)!z[v]T[RPQ8#;43$Bjp,-4)93+,%lTIPHKZX^mLZ][FP2QlXYBdCIHUuTWPD]EAl@YF[XYCXNcBoDMBKIHn[[NLDhHeeDiBKDMONbCnELCJHIbVWLpWBWPSEMPS8/5m`AlGNAHJKbVWLeFBWPl]JN[J{NMrORJCM^k3lNCCMNLD`TUNg@SLoRHSYTSZbTEEX_VBwAPPMJCWf[F^W%KO333333\xc3?i_NNST]IuA@[rUFYbVWLpWBQzOLyGJZFESBB_XQE&076*>2*cD__X_VoNMJ^G_lN_TADN~Z]`ZIVsRQVB[CkJINZC[3:1Fq75|]^YMTLwXB_wP]6009199uZ@]uR_|X_:yK*> >:*1qFPJYF~RZ]e4dXUMQF<'?07 XBHKCOd_VERSBFFHM_sHJIGBzAC@NKyDGGX]^OY@o@EOGoHBC^c^C[RoPHZM}@]EL`XAYDR^ONJpHQITaFS@FyPCPYrJSKVlQLT]}QY^M\xd1a\x08aMEB\x80Q\x01\x004 &1D\x12A\xa8\x9cXUEETAEqVEZ\x90\x04pciETW\xd6Lr\x1ciKHO\x0e\xb6\x00\xbehIHC\xc4\n=\xd6gZ^VC\xdf\xe62ta\xd1\x0e[DSNnK^Kq\x87c\x1e\x00\xc0\xfb\xfa\xc1xK\x1b\x9c\x86+\x1cd@GyUL_Y^,+8AHC83!mWe\xf8\x02#.&\x96\x03xB/egUi6WyGY\x01]z!\x10D\x13\x1d,"))
local gd = (buffer.fromstring("\x17 )*$!e + (, 6e#*7e1- e6 ) &1 !e2*7)!e#7*(e6-$7 !e!$1$e$+!e),3 e2*7.65$& k\x06*5, 6e1- e,+3,1 e),+.e1*e<*07e&),5'*$7!k=@19;gFzKJM?-WOD369y:oeSZSUBSRqWU^W,&j,a@17bmF?B524t-0mBf:?HTJ0!;fuDSWBSbYQQZSkSm{{7HXRhe}L+0u7-OE#D{0_#pS,8syEHPL[eL_LE})mqt9qk[YQAsbgX9AJ-n-@TD!oY[FYiOMFOjKBOWI2p9w&U]F;NYjRg@XQ.s*!xDQC0p]U%c^ZReR@VESDl6ko,!pT]#sn=;,JP&tP_4jFQHja6ov@I@FQ@ArJWIA0@pR^nQhAI!0_!O4=VL{^@N4njP;CLZVZMUZ]_^k/Ea:3pNhQoWwL8reJ;pH-g,/xwRdyVQU]\x18~Q_PL]JK&E15+2-KKm[/:}x1t2sl;gGRgawAHAGPA@cEGLEX)g;G@)?g]xkmXeMvTa&eX[vgMyMLWyOYS]VEx,zBo6[KGYOf7U]y0wvurC[T^9@(!>%!>77&{V.UZ4O74xz6d/=atGO^ish{v.Hj}3}pQ|W^QXZ[XaQT6jk/M}nB*K62(((EI4wS$ieOf{DXB_BDEz65B-JzTMxbZbL5+l-afhw!x!L}C3FeDG@TMUCg1Cj1?YRx0$]*DS8lF}$aA0e{6TKt~JKPlK^MmqT1l$9N,x^eV9;H6U[]-1znxiYy[}KBKMZKJ}ZOZZ_xl51SiaKs*+,h:V1Ss{fur,o[ZAhKOZ]{xEK5KY6jlhjc{-FiIHJ(aTbr{Xn19=:4':&&.6EfX,6R*Vom25z=ek_QN73K%0fwCBYeBWDDE!8[Vtz^4!K6_Y-J[NxLbJ1YtgbyD@H}ALTHIWzmN,4#KbzrBIP&ZTdl_]Z6+vDrGGRPXwV_RJy%U/4A{%L:V!y/^gHr,+QL9d$3$?'==*0)QSfRB@gCSM4v4qDeUFD7]erX{{~JYU]4xGYzLq#Cx6Q)x$#SVy34HQ=+DbX@~CYBHEBKnJxhl,D^}FowtU7V-gX/7i;7D.kgHROg@Mk;XNwuLqM3FqP5ER&2^8V@qiU-%`LDCKAIr%.@1TDN(tXr.xz9OJofEdU_PQv|JCJL[JKjAJBVauIPIe?3oKO}kHE)e8+cS`[YZTQ1E_tBb/EnE:Yyj6(lz+)M.G-!&.&b_BZSVAcl5/SAgofc+5hu^arg]ili.D=s.nXQX^IXYjROQY0HFuC2*LbX1i)#P}}b$dfzVGU):e5($+]bsTm&1+m5Gh8spKY9)V)MIgCDyCPObr7NF!CK%V&&#0F@PoixU,53&5}KC^lEXiBCFNcP[eZ{jMy=BiM&t#YC0/xbYPCTU%DKzEV)3ichH*)CA.rfEE::Tr-.wAPPMJCW4%TQpmkdiCM?5Cy$fJ9T=jL!oROW^gB_d-%-W]-,GPWDzbEf@caIg?a@XRUx@B,c-oo$Ca@iug=x]FPR{Nbu&.1hjLNELTT16a=5B9a1JHONTZa4+SM3ry&}sQ@u@@F]VA@Qv@;J0$SYL7TFyeaFVmNIiN[H~HUJ^UMT[}pGt3VGK*P+(73709kGXUNDMwT#clvAak6?0P$n]jpg.f$Vl^y^MRgi$_)UWE;#Fg7%L7.TD4]]mTU;i~[@MF\x0ejKBOWLB?Xc8!=vUT,HkQc;^+FbUGQBTC33+}fv(xXVJIwzmX34+AM^pate\x03bVWLNBWJLMNzD9=}KzIJiS&JHTw[Z@QZ@oh%tcVq9c,.gLqn=zp{2Fb-(4403zoo$)3#/2$n''o&s$\n(\x04'9\x141yTN^ROYYLRKw}8s7tg{hbEaqaT^[C|JCJL[JK|[N]l^lE6B+QTF-4VAjaaRF[Y{RRGQ@Z3X!8)cyvwW;.3Q/e#TdGKIDxDIQMZ#4/&IxoV0=7:wR-L]D`V_VPGVW`GRG2ne,92-w*i%Dg9dDnSNV__,,c7.ckNQq%s@kvB@gGl-Q*#(;6{rxO^Zy#TEEpn]xzPf+04hufDODS@McVFl]33ttel9Xo6_}?ycxh^IM^IH]{m0VdwPtQ}cRy%oUih^`K@HL@V%8,&E+W(Y[D_Y:NuSq:Un{j\x0cmYXCAMXECBE4kTd13o?8]E0wVURF_Gnb/j.p)_9bV,+z2uh4dciDVQvQDWQ{k&O%REVCEJGeQ=irpb@K@WDI4pbc?P03e7gJR{SS1pPjQ_PL{WVLJWTRb#BGIdiZA7;9JmJQQVQXwm[Iy;6fjYL0*EMFO0E/eCZRJ#}C#raba})u!wqd?&VlC}@]EL%F+8FLyE,Sr3?$dH!Y=7eXE]T-3f{iww&KA%SZwYSgVSjuDSWBSbWT:^rGI@Dcm;ME?fvkIDDJIKCenL,]TMLkPUe3b@p`K@HL@VjKwDKB@lAVlfn-nEucDNORxO]KXNY9.lBV)HZg.72+=1.?,>(1:6%f/;$TRT7h/%`L]^=F_{$s5}wE{5Jg$d0P(|]^YMTLQ}.!uP*gZ]!c_;MUdYZZE^3(RPxLSG1Ld@.;;Sa81:v-O}mzkUj@IN=bMi1]Q7%614!13<2?fl[@VgUMn#+rUFYp]G@UZWQ6G6x-IWGfvNNWVCELOHNoSsCD+Tvj@NT}R^Vb3^lM2BGK.Olz[%#:^|[N[giI2#x7yA{kn!y]}kBt@AZsTGX#thaV7F!ynP]2J=*?aq:8)9kpP)v(EpH&NIbSD@UDu@C$_p-?t0P7yz}xNGNH_NOnENFR/edB]QN7eSZSUBSReBWBjX9.b(JRoH[D*cidk:M2_y6}=&KNc^D_UX_Vxl3],tvOJnC7|[N]kJCNVeR{0kh5VU(1 ,38 2;5!y&1riebXJ1AFJ]SPsH]G5$M{:uiNDmNB@MqM@XDS!st(yd(dvGPTAPaZRRYP0i#6,fByO^^CDMYE.@pUdK}2W{F[CJG+EAfg2E9O$4)1>=19$egT?xC{UhJDFpFOF@WFGdB@KB,#;FckL_@iD^YLCNHAec,DnObI@OFDE:G7&dmg/qLQI@E,uT;ms://+/sNVZUTR_iTTOkZIOvcr\x14uA@[YU@][ZX*uDSWBSbYQQZSW!aJq@WSFWf]UU^W!$dycJYJC)2hDJziNsk,bC@GSJR[sTNr{E&1cnu7])n+RNtg+NI7pDE^cTFPCUBdL^^lXYBlYYLNFm_m(-x]G@iSc;d(LxFRvjKfMDKB@A79J9vw|GN]JK$_)dAmeFiFKCGbM/kl{I3WyH_[N_~HUJ^UMTxNGNH_NOnENFR!gHOEgHSRUbIHMEiXOK^OnXEZNE]D|JCJL[JKx@]CK`V_VPGVWtRP[RvcruA@[rXAQZ@~TXYa=cZ-MlWgrDMDBUDEf@BI@pFOF@WFGtLQOGaFS@vW^SKnfV9a@mFO@IKJTPO.gQXQW@QPc[FXPuCJCERCBuRGReTCGRCrIAAJCtVGrGGAZQFGVtOANReIHRTIJeQVJWP\x03uFQPF`V_VPGVW`GRGfW@DQ@qJBBI@fPYPVAPQfATAtERVCRcXPP[RsV^[NeR@VESD~JKPvQ[ZGc=GgVAEPApKCCHApEEPRZuT]PHrOKCtCQGTBUgSRItCQGTBUoCBBIOXECB_zNOTi^LZI_HpDE^cTFPCUBgZG_V_xpRT1bM@HLsDV@SEpVT_V\x17sR[VN2$,1a_iKiwRXSA/C.%^sWo[ZAoZZOMEnZ[@nXNDJApRCdREA^TRaFS@vW^SK$jHY~H_[DNHdPQJ\x05uPKFM3<?:8%#!#<wAEVGLEFHAyOKXIBKHFOfGjAHGNLMnZ[@hNLGNyDYAHLPaArCTPETePSzNOT}ZIVqyMLW~]YLKINBOEVYIQ\x11%$?\x03$1$#{ONU}[YR[~_rYP_VTUuA@[rUFYpkJgLEJCA@`GRAwV_RJj^_Dx_J_XjKfMDKB@At@AZrTV]TqED_\x10cDQB~OH[NSUT,/&!8/:8<71)*42<\x0732)\x00'4+fPAcTY@PzNOT}ZIVpMPHAOW^\x00\x00\x00\x00\x00\x00\x0c@\x00\x00\x00\x00\x00\x00\xd0?c^D_UX_VdGUCvGTRwJPKALKBsTOOHOFB_@DYFYpW]S{WFnOLK_F^qM@XDSR]PC@I^3uWFMX]WKHKFBEXgFEBVOWlNENYJG'0#0'&0AVFDXAJuISD@ER':8+?,nUWTZ_HSKDCT{@IZML[_GZL[cXZYWR>=,:#9fZWOSD`WZCSEzAH[LM~RKVQG9,/!(kWZRZ<7=37t[V^Z~WDW^NUEfmkVUUJpVT_VuHUMDEPUNSqLQI@yDYAHtLUMP\xf1I\xffA\x8e;K\xc7\x02\xfbs'uXTU`Y\xd17sortvYU]\xb2.\x9e\xf7\x97\xbc\xf5\xa9sVCV<8-;r^VQaKGF\xb70\xb1\x03jOZObG]Z\x14\xcfr\x0blK^K\x01\x0ch\x05>\x87\xb4\xe4CU]@uYQV\x84J$\x11.80-\xbc \x19\xcdgKR~Z]MKL{WN[RYAVCODVh\x01bo1\x1fZ-V\r?\x00\x1c.\x1aO\x02\x0c7\x06FAE*T\n\x12\x11"))
if getgenv().BWFAutoFluent then
    gh = 0
    repeat
        if bit32.bxor(bit32.lrotate(bit32.bxor(bit32.rrotate(bit32.bxor(bit32.lrotate(gh, 4), string.byte(tostring(gh))), 25), 2516811029), 12), 936466784) ~= bit32.lrotate(bit32.rrotate(bit32.bxor(bit32.lrotate(gh, 4), string.byte(tostring(gh))), 25), 12) then
            getgenv().BWFAutoFluent.Unload()
        else
            getgenv().BWFAutoFluent.Unload()
        end
        gh = (gh + 2) % 4
    until fn709((gh * 3 + 0) % 4, 578005792)
end
Fluent, gl, gj, ga, f8, Omni = nil, nil, nil, nil, nil, nil
local gk = 4
repeat
    gh = (gk * 5 + 3) % 6 + 1
    if gh <= 3 then
        if gh <= 2 then
            if gh <= 1 then
                gm = (vector.create((gk * 7 + 4) % 11 + 1, (gk * 11 + 8) % 13 + 1, (gk * 13 + 13) % 17 + 1))
                gn = (vector.create((gk * 3 + 4) % 11 + 1, (gk * 6 + 5) % 13 + 1, (gk * 7 + 7) % 17 + 1))
                if vector.dot(vector.cross(gm, gn), (vector.cross(gm, gn))) + vector.dot(gm, gn) * vector.dot(gm, gn) == vector.dot(gm, gm) * vector.dot(gn, gn) + 4 then
                    ga = game:GetService("Players")
                else
                    gl = game:GetService("Players")
                end
                gk = (gk + 5) % 24
            else
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gk, 18), string.byte(tostring(Omni))), 26), 1107249649), 295820623), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gk, 18), string.byte(tostring(Omni))), 26), 3187717646), 836183378))), 295820623), 836183378) == bit32.rrotate(bit32.bxor(bit32.lrotate(gk, 18), string.byte(tostring(Omni))), 26) then
                    gj = game:GetService("ReplicatedStorage")
                else
                    f8 = game:GetService(game)
                end
                gk = (gk + 11) % 24
            end
        else
            if (gk * 2 + 9) * 13 % 3 == ((gk * 2 + 9) * 13 + 0) % 3 then
                game.GetService(game, "RunService")
                ga = game:GetService("Workspace")
                f8 = gl.LocalPlayer
            else
                ga = game:GetService("RunService")
                f8 = game:GetService("Workspace")
                gl = game
            end
            gk = (gk + 17) % 24
        end
    elseif gh <= 5 then
        if gh <= 4 then
            if (gk * 2 + 7) * 10 % 3 == ((gk * 2 + 7) * 10 + 6) % 3 then
                Omni = require(gj:WaitForChild("Omni"))
            else
                gj = require(Omni:WaitForChild(Omni))
            end
            gk = (gk + 23) % 24
        else
            gh = (vector.create((gk * 6 + 9) % 11 + 1, (gk * 10 + 12) % 13 + 1, (gk * 5 + 4) % 17 + 1))
            gm = (vector.create((gk * 4 + 5) % 11 + 1, (gk * 1 + 9) % 13 + 1, (gk * 11 + 14) % 17 + 1))
            if vector.dot(vector.cross(gh, gm), (vector.cross(gh, gm))) + vector.dot(gh, gm) * vector.dot(gh, gm) == vector.dot(gh, gh) * vector.dot(gm, gm) then
                pcall(fn492)
                pcall(fn171)
            else
                pcall(fn492)
                pcall(fn171)
            end
            gk = (gk + 17) % 24
        end
    else
        if ((not gl or gl or (Omni or not Omni)) and (Omni or not Omni or (gl or not Omni)) and (not Omni and not Omni and (Omni and gl) and (Omni and not Omni and (not gl or gl))) or (not gl and not Omni and (not Omni and Omni) or (Omni and not Omni or (gl or Omni))) and (not Omni or not Omni or Omni and not Omni or (not Omni or Omni or (not Omni or gl)))) and not ((not gl or gl or (Omni or not Omni)) and (Omni or not Omni or (gl or not Omni)) and (not Omni and not Omni and (Omni and gl) and (Omni and not Omni and (not gl or gl))) or (not gl and not Omni and (not Omni and Omni) or (Omni and not Omni or (gl or Omni))) and (not Omni or not Omni or Omni and not Omni or (not Omni or Omni or (not Omni or gl)))) then
            gl = getgenv().Fluent
        else
            Fluent = getgenv().Fluent
        end
        gk = (gk + 11) % 24
    end
until fn709((gk * 1 + 5) % 24, 192073492)
gh = "AutoAttack"
local gi = "AutoStats"
local gi_4
gj = "AutoRewards"
gk = "AutoIndex"
gl = "AutoAwaken"
gm = "AutoFeats"
gn = "AutoFarm"
local go = "AutoGacha"
local gp = "AutoStar"
local gq = "SelectedStat"
local gr = "Power"
local gs = "SelectedWorld"
local worker = Omni.Data and Omni.Data.Map
local gu = worker or "Fruits Verse"
fX, gK, gJ, f3, fV, f1, f4, gc, f5, f0, gb, f_, gF, gG, gH, gI, fY, f9, gw, fZ, ge, worker, gy, gC_1, gz, gA, gv, gD, f2, gB, gE = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local gx = 37
repeat
    local gL = (gx * 7 + 2) % 22 + 1
    if gL <= 11 then
        if gL <= 6 then
            if gL <= 3 then
                if gL <= 2 then
                    if gL <= 1 then
                        gM = {
                            "mprauf",
                            "hajouxlnay",
                            "ttpmfmghztqh",
                            "lsuaz",
                            "klnh",
                            "txf",
                            "yjuiylqdl",
                            "jrmew",
                            "xyrjabzpsno",
                            "guzgzglx",
                            "lqwocv",
                            "ozlslmokxbhg",
                            "rpmgfyiwnwn"
                        }
                        if gM[(gx * 27 + 103) % 13 + 1] <= gM[(gx * 27 + 103) % 13 + 1] then
                            f0 = fn19
                            gb = fn797
                            f_ = fn770
                        else
                            f_ = fn19
                            f0 = fn797
                            gb = fn770
                        end
                        gx = (gx + 41) % 88
                    else
                        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 17), string.byte(tostring(fZ))), 1), 1033843103), 2847080589), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 17), string.byte(tostring(fZ))), 1), 3261124192), 509839217))), 2847080589), 509839217) ~= bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 17), string.byte(tostring(fZ))), 1) then
                            f4 = fn829
                        else
                            gF = fn829
                        end
                        gx = (gx + 85) % 88
                    end
                else
                    if gx * 90704897 + 4 + 5 <= gx * 90704897 + 4 + 5 + 5 then
                        gG = fn1026
                        gH = fn95
                        gI = fn872
                    else
                        gI = fn1026
                        gG = fn95
                        gH = fn872
                    end
                    gx = (gx + 19) % 88
                end
            elseif gL <= 5 then
                if gL <= 4 then
                    if (gx * 1 + 9) * 5 % 4 == ((gx * 1 + 9) * 5 + 12) % 4 then
                        fY = fn311
                    else
                        gK = fn311
                    end
                    gx = (gx + 19) % 88
                else
                    gM = (vector.create((gx * 6 + 3) % 11 + 1, (gx * 7 + 4) % 13 + 1, (gx * 4 + 8) % 17 + 1))
                    gN = (vector.create((gx * 4 + 5) % 11 + 1, (gx * 3 + 9) % 13 + 1, (gx * 9 + 9) % 17 + 1))
                    gO = (vector.create((gx * 4 + 2) % 11 + 1, (gx * 3 + 10) % 13 + 1, (gx * 1 + 12) % 17 + 1))
                    gP = (vector.create((gx * 4 + 4) % 11 + 1, (gx * 7 + 9) % 13 + 1, (gx * 1 + 12) % 17 + 1))
                    if vector.dot(vector.cross(gM, gN), (vector.cross(gO, gP))) == vector.dot(gM, gO) * vector.dot(gN, gP) - vector.dot(gM, gP) * vector.dot(gN, gO) then
                        f9 = fn505
                    else
                        worker = fn505
                    end
                    gx = (gx + 19) % 88
                end
            else
                if gx * 50352465 + 3 + 4 >= gx * 50352465 + 3 + 4 + 5 then
                    gv = fn429
                else
                    gw = fn429
                end
                gx = (gx + 41) % 88
            end
        elseif gL <= 9 then
            if gL <= 8 then
                if gL <= 7 then
                    gM = { "kooadv", "djtrhiyekdy", "rdye", "pryldymawo", "hocndwxhp", "wvmql", "ebq", "patp", "voxtrjdal" }
                    if gM[(gx * 83 + 103) % 9 + 1] <= gM[(gx * 83 + 103) % 9 + 1] then
                        fZ = fn602
                        ge = fn78
                    else
                        ge = fn602
                        fZ = fn78
                    end
                    gx = (gx + 41) % 88
                else
                    gM = (vector.create((gx * 5 + 5) % 11 + 1, (gx * 1 + 2) % 13 + 1, (gx * 3 + 1) % 17 + 1))
                    gN = (vector.create((gx * 4 + 5) % 11 + 1, (gx * 9 + 7) % 13 + 1, (gx * 7 + 12) % 17 + 1))
                    gO = (vector.create((gx * 4 + 5) % 11 + 1, (gx * 3 + 4) % 13 + 1, (gx * 6 + 5) % 17 + 1))
                    gP = (vector.create((gx * 3 + 2) % 5 + 1, (gx * 1 + 5) % 7 + 1, (gx * 1 + 4) % 9 + 1))
                    if vector.dot(vector.cross(gM, (vector.cross(gN, gO))), gP) == vector.dot(gN * vector.dot(gM, gO) - gO * vector.dot(gM, gN), gP) then
                        worker = function()
                            local iv
                            iv = 0
                            pcall(function()
                                iv = Omni.Shared.PlayerLevel.GetAvailablePoints(Omni.Data)
                            end)
                            if iv and iv > 0 and fX.SelectedStat then
                                f1("General", "PlayerLevel", "UpgradeStat", fX.SelectedStat, iv)
                            end
                        end
                    else
                        gC_1 = function()
                            local iv
                            iv = 0
                            pcall(function()
                                iv = Omni.Shared.PlayerLevel.GetAvailablePoints(Omni.Data)
                            end)
                            if iv and iv > 0 and fX.SelectedStat then
                                f1("General", "PlayerLevel", "UpgradeStat", fX.SelectedStat, iv)
                            end
                        end
                    end
                    gx = (gx + 41) % 88
                end
            else
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 20), string.byte(tostring(gD))), 22), 457930945), 1163221148), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 20), string.byte(tostring(gD))), 22), 3837036350), 3343596430))), 1163221148), 3343596430) == bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 20), string.byte(tostring(gD))), 22) then
                    gy = fn926
                else
                    f_ = fn926
                end
                gx = (gx + 19) % 88
            end
        elseif gL <= 10 then
            gM = {
                "wjmdvhaxwcz",
                "ndc",
                "rpxspunf",
                "efndzs",
                "wppuucarc",
                "cpatke",
                "kwaden",
                "ucllsq",
                "saydyqjw",
                "admu",
                "jslqrsird",
                "bnqzbpywc"
            }
            if gM[(gx * 47 + 105) % 12 + 1] <= gM[(gx * 47 + 105) % 12 + 1] then
                gC_1 = fn165
            else
                fZ = fn165
            end
            gx = (gx + 63) % 88
        else
            if gx * 75985945 + 1 + 7 <= gx * 75985945 + 1 + 7 + 1 then
                gz = fn721
            else
                gE = fn721
            end
            gx = (gx + 19) % 88
        end
    elseif gL <= 17 then
        if gL <= 14 then
            if gL <= 13 then
                if gL <= 12 then
                    if bit32.bxor(bit32.lrotate(bit32.bxor(bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 1), string.byte(tostring(gv))), 11), 2822836804), 12), 287591044) ~= bit32.lrotate(bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 1), string.byte(tostring(gv))), 11), 12) then
                        gc = fn820
                    else
                        gA = fn820
                    end
                    gx = (gx + 19) % 88
                else
                    gM = (vector.create((gx * 4 + 6) % 11 + 1, (gx * 9 + 12) % 13 + 1, (gx * 10 + 3) % 17 + 1))
                    gN = (vector.create((gx * 5 + 3) % 11 + 1, (gx * 2 + 10) % 13 + 1, (gx * 4 + 7) % 17 + 1))
                    if vector.dot(gM, gN) * vector.dot(gM, gN) >= vector.dot(gM, gM) * vector.dot(gN, gN) + 1 then
                        gK = fn1067
                    else
                        gv = fn1067
                    end
                    gx = (gx + 19) % 88
                end
            else
                gM = {
                    "lxo",
                    "ytgdmz",
                    "gufadqaclbo",
                    "dux",
                    "afk",
                    "rlqwjikxq",
                    "jos",
                    "nmkpxrm",
                    "rplocgyo",
                    "fsrybclraa",
                    "fxfbri",
                    "qpitdnv"
                }
                gN = gM[gx % 12 + 1]
                gM = gx % 3 + 2
                gO = (gN:reverse())
                local lx = gM
                gM = gN:len()
                gP = (gO:rep(lx))
                if gM >= gP:len() then
                    gc = function()
                        local i8
                        if fX.SelectedStar then
                            i8 = 1
                            pcall(function()
                                i8 = Omni.Utils.PlayerStats.MaxStarOpen(Omni.Data, f8)
                            end)
                            f1("General", "Stars", "Open", fX.SelectedStar, i8)
                        end
                    end
                else
                    gD = function()
                        local i8
                        if fX.SelectedStar then
                            i8 = 1
                            pcall(function()
                                i8 = Omni.Utils.PlayerStats.MaxStarOpen(Omni.Data, f8)
                            end)
                            f1("General", "Stars", "Open", fX.SelectedStar, i8)
                        end
                    end
                end
                gx = (gx + 19) % 88
            end
        elseif gL <= 16 then
            if gL <= 15 then
                gM = {
                    "aohatnveqnt",
                    "hoctzy",
                    "ltmnmmcdus",
                    "abd",
                    "oovwbdmnio",
                    "sktzpqadeub",
                    "baboklq",
                    "uoefnb",
                    "aqr",
                    "isdk"
                }
                gN = gM[gx % 10 + 1]
                gM = gN:len()
                gO = (gN:gsub("(.)", "%1%1", gx % 3 % 2 + 1))
                if gM >= gO:len() then
                    gK = fn733
                else
                    f2 = fn733
                end
                gx = (gx + 63) % 88
            else
                gM = (vector.create((gx * 3 + 7) % 11 + 1, (gx * 5 + 6) % 13 + 1, (gx * 9 + 16) % 17 + 1))
                gN = (vector.create((gx * 4 + 8) % 11 + 1, (gx * 4 + 4) % 13 + 1, (gx * 13 + 10) % 17 + 1))
                if vector.dot(vector.cross(gM, gN), (vector.cross(gM, gN))) + vector.dot(gM, gN) * vector.dot(gM, gN) == vector.dot(gM, gM) * vector.dot(gN, gN) + 3 then
                    f_ = function(bS, bT, bU, bV)
                        fX.Threads[bS] = task.spawn(function()
                            while fX.Running do
                                if bU() then
                                    pcall(bV)
                                end
                                task.wait(f2(bT))
                            end
                        end)
                    end
                else
                    gB = function(bS, bT, bU, bV)
                        fX.Threads[bS] = task.spawn(function()
                            while fX.Running do
                                if bU() then
                                    pcall(bV)
                                end
                                task.wait(f2(bT))
                            end
                        end)
                    end
                end
                gx = (gx + 19) % 88
            end
        else
            gM = (vector.create((gx * 7 + 3) % 11 + 1, (gx * 2 + 6) % 13 + 1, (gx * 7 + 14) % 17 + 1))
            gN = (vector.create((gx * 6 + 9) % 11 + 1, (gx * 10 + 2) % 13 + 1, (gx * 4 + 15) % 17 + 1))
            if vector.dot(gM, gN) * vector.dot(gM, gN) >= vector.dot(gM, gM) * vector.dot(gN, gN) + 1 then
                gv(fn532, gv, fn600, "AutoAttack")
                gv(fn89, gv, fn1022, "AutoPunch")
                gv(fn632, "AutoStats", gD, 1)
                gv(3, gv, fn82, gv)
                gv(gv, gC_1, fn617, gz)
                gv("AutoIndex", 5, fn591, gv)
                gv("AutoAwaken", "AutoRewards", "AutoFeats", gv)
                gv(fn535, 1, 10, fn940)
                gv(gK, fn1010, fn288, "AutoStar")
                gw.Threads.AutoFarm = task.spawn(worker)
                gy = fX:CreateWindow(gv)
            else
                gB("AutoAttack", fn532, fn600, fn89)
                gB("AutoPunch", fn591, fn1022, gw)
                gB("AutoStats", 1, fn632, worker)
                gB("AutoRewards", 3, fn82, gy)
                gB("AutoFeats", 5, fn617, gC_1)
                gB("AutoIndex", 10, fn535, gz)
                gB("AutoAwaken", 1, fn288, gA)
                gB("AutoGacha", fn940, fn1010, gv)
                gB("AutoStar", function()
                    return fX.StarDelay
                end, function()
                    return fX.AutoStar and fX.SelectedStar ~= nil
                end, gD)
                fX.Threads.AutoFarm = task.spawn(function()
                    local jt_1
                    while fX.Running do
                        if fX.AutoFarm and fX.SelectedWorld and fX.SelectedEnemy then
                            local jr_1 = fY(fX.SelectedWorld, fX.SelectedEnemy)
                            local js = jr_1[1]
                            if js then
                                local jr_2 = os.clock()
                                repeat
                                    ge(js)
                                    fZ(js)
                                    task.wait(fX.AttackDelay)
                                    jt_1 = not fX.Running or not fX.AutoFarm or not f0(js) or os.clock() - jr_2 > 30
                                until jt_1
                            else
                                task.wait(0.75)
                            end
                        else
                            task.wait(0.25)
                        end
                    end
                end)
                gK = Fluent:CreateWindow({
                    Title = "BWF Automation",
                    SubTitle = "Anime Fighters",
                    TabWidth = 150,
                    Size = UDim2.fromOffset(760, 520),
                    Resize = true,
                    MinSize = Vector2.new(460, 360),
                    Acrylic = true,
                    Theme = "Dark",
                    MinimizeKey = Enum.KeyCode.RightControl
                })
            end
            gx = (gx + 85) % 88
        end
    elseif gL <= 20 then
        if gL <= 19 then
            if gL <= 18 then
                if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 14), string.byte(tostring(f9))), 10), 853991235), 3594324676), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 14), string.byte(tostring(f9))), 10), 3440976060), 4109769502))), 3594324676), 4109769502) ~= bit32.rrotate(bit32.bxor(bit32.lrotate(gx, 14), string.byte(tostring(f9))), 10) then
                    gK = "Settings"
                else
                    gJ = {
                        Main = gK:CreateTab({ Title = "Main", Icon = "swords" }),
                        Farm = gK:CreateTab({ Title = "Farm", Icon = "map" }),
                        Rolls = gK:CreateTab({ Title = "Rolls", Icon = "sparkles" }),
                        Settings = gK:CreateTab({ Title = "Settings", Icon = "settings" })
                    }
                end
                gx = (gx + 63) % 88
            else
                gM = { "ydoudbtb", "jlbhne", "aepf", "wszhbjw", "phav", "awz", "gdmjsdqs", "sfcxe", "yrtloqwy", "jakea" }
                if gM[(gx * 80 + 81) % 10 + 1] < gM[(gx * 80 + 81) % 10 + 1] then
                    gE = "https://discord.gg/K7Qxnxkk46"
                    f3 = fn782
                else
                    f3 = "https://discord.gg/K7Qxnxkk46"
                    gE = fn782
                end
                gx = (gx + 41) % 88
            end
        else
            if (gx * 2 + 6) * 16 % 3 == ((gx * 2 + 6) * 16 + 4) % 3 then
                gu = 0.18
            else
                fX = {
                    [gh] = false,
                    [gi] = false,
                    [gj] = false,
                    [gk] = false,
                    [gl] = false,
                    [gm] = false,
                    [gn] = false,
                    [go] = false,
                    [gp] = false,
                    [gq] = gr,
                    [gs] = gu,
                    SelectedEnemy = nil,
                    SelectedGacha = nil,
                    SelectedStar = nil,
                    FarmDistance = 6,
                    AttackDelay = 0.18,
                    GachaDelay = 1,
                    StarDelay = 3.5,
                    Connections = {},
                    Threads = {},
                    Running = true,
                    AutoPunch = false,
                    PunchDelay = 0.18
                }
            end
            gx = (gx + 85) % 88
        end
    elseif gL <= 21 then
        gh = {
            "oxhjvod",
            "wjuqlsl",
            "csnvs",
            "mcwakfac",
            "btxgvewaxs",
            "ewtafbraczu",
            "ksvavygwyje",
            "rmvrmddu"
        }
        gi = gh[gx % 8 + 1]
        gh = gx % 3 + 2
        gj = (gi:reverse())
        local lr = gh
        gh = gi:len()
        gk = (gj:rep(lr))
        if gh >= gk:len() then
            local lJ = getgenv()
            lJ.BWFAutoFluent = lJ
            fX = function(t, u, v)
                pcall(function()
                    local gY = "Title"
                    local gZ = "Content"
                    local g_ = "Duration"
                    local g0 = v or 4
                    Fluent.Notify(Fluent, { [gY] = t, [gZ] = u, [g_] = g0 })
                end)
            end
            fV = function(y, z, A, ...)
                local g3_2
                local g2_2
                g3_2, g2_2 = pcall(function(...)
                    local Signal = Omni.Signal
                    Signal.Fire(Signal, y, z, A, ...)
                end, ...)
                if not g3_2 then
                    warn("[BWF Auto] signal failed:", y, z, A, g2_2)
                end
                return g3_2
            end
        else
            getgenv().BWFAutoFluent = fX
            fV = function(t, u, v)
                pcall(function()
                    local gY = "Title"
                    local gZ = "Content"
                    local g_ = "Duration"
                    local g0 = v or 4
                    Fluent.Notify(Fluent, { [gY] = t, [gZ] = u, [g_] = g0 })
                end)
            end
            f1 = function(y, z, A, ...)
                local g3_1
                local g2_1
                g3_1, g2_1 = pcall(function(...)
                    local Signal = Omni.Signal
                    Signal.Fire(Signal, y, z, A, ...)
                end, ...)
                if not g3_1 then
                    warn("[BWF Auto] signal failed:", y, z, A, g2_1)
                end
                return g3_1
            end
        end
        gx = (gx + 85) % 88
    else
        gh = 1
        if (gx * 3 + 2) * 17 % 4 == ((gx * 3 + 2) * 17 + 10) % 4 then
            f5 = fn108
            f4 = fn726
            gc = fn938
        else
            f4 = fn108
            gc = fn726
            f5 = fn938
        end
        gx = (gx + 63) % 88
    end
until fn709((gx * 59 + 6) % 88, 1668285584)
for k, v in pairs(gJ) do
    gE(v)
end
gh = gF()
local gi_1 = table.find(gh, fX.SelectedWorld) and fX.SelectedWorld
gj = gi_1 or gc(gh)
gl, gk = nil, nil
local gi_2 = 3
repeat
    gm = (gi_2 * 1 + 0) % 2 + 1
    if gm <= 1 then
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gi_2, 17), string.byte(tostring(gl))), 13), 140628301), 2504119208), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(gi_2, 17), string.byte(tostring(gl))), 13), 4154338994), 625952715))), 2504119208), 625952715) == bit32.rrotate(bit32.bxor(bit32.lrotate(gi_2, 17), string.byte(tostring(gl))), 13) then
            fX.SelectedEnemy = gc(gl)
            gk = gG()
        else
            gG.SelectedEnemy = gk(gc)
            gl = fX()
        end
        gi_2 = (gi_2 + 1) % 16
    else
        gm = {
            "bfcgu",
            "emjger",
            "btsrnzvn",
            "mcpelrais",
            "tepgydz",
            "imsbcr",
            "reanibfn",
            "oxotlvva",
            "sioddcdfaqg",
            "iseqlml",
            "zehsyp",
            "xwtqsnhjhw"
        }
        gn = gm[gi_2 % 12 + 1]
        gm = gn:len()
        go = (gn:gsub("(.)", "%1%1", gi_2 % 3 % 2 + 1))
        if gm <= go:len() then
            fX.SelectedWorld = gj
            gl = f_(fX.SelectedWorld)
        else
            fX.SelectedWorld = f_
            gj = fX(gl.SelectedWorld)
        end
        gi_2 = (gi_2 + 1) % 16
    end
until fn709((gi_2 * 15 + 14) % 16, 661912322)
local gi_3 = table.find(gk, fX.SelectedStat) and fX.SelectedStat
gj = gi_3 or gc(gk)
gm, gi_4, f7, gn = nil, nil, nil, nil
go = 9
repeat
    gp = (go * 3 + 4) % 5 + 1
    if gp <= 3 then
        if gp <= 2 then
            if gp <= 1 then
                if (go * 2 + 7) * 16 % 3 == ((go * 2 + 7) * 16 + 2) % 3 then
                    fX.OnChanged(fX, fn760)
                    gi_4.OnChanged(gi_4, fn439)
                    worker = gn.Farm
                    gu = worker:CreateToggle("Auto Farm", false)
                    local gr_1 = gu
                    gr_1.OnChanged(gr_1, "Default")
                    local Farm = gn.Farm
                    gw = Farm
                    gw.CreateButton(gw, "AutoFarm")
                    gA = gm.SelectedGacha
                    gB = gn.Rolls
                    local gq_1 = (gB:CreateDropdown(gn, "GachaDropdown"))
                    gq_1.OnChanged(gq_1, "Reload enemies for the selected world from shared data and live workspace.")
                    local Rolls2 = gn.Rolls
                    gs = (Rolls2:CreateToggle("Title", "Default"))
                    gs.OnChanged(gs, "Multi")
                    local Rolls = gn.Rolls
                    gs = { Values = gJ, Title = "Island Star", Multi = false, Searchable = true, Default = gm.SelectedStar }
                    gv = Rolls
                    gx = (gv:CreateDropdown(gA, "Searchable"))
                    gx.OnChanged(gx, gJ)
                    gx = gn.Rolls
                    gs = (gx:CreateToggle(gn, gs))
                    gs.OnChanged(gs, gu)
                    gs = gn.Settings
                    worker = (gs:CreateSlider("Values", gm))
                    worker.OnChanged(worker, Farm)
                    gs = gn.Settings
                    local gr_3 = (gs:CreateSlider("Auto Star", "Default"))
                    gr_3.OnChanged(gr_3, Rolls)
                else
                    gn.OnChanged(gn, fn760)
                    f7.OnChanged(f7, fn439)
                    local gr_4 = { Title = "Auto Farm", Default = false }
                    gs = gJ.Farm
                    worker = function(cy)
                        fX.AutoFarm = cy
                    end
                    local gq_4 = (gs:CreateToggle("AutoFarm", gr_4))
                    gq_4.OnChanged(gq_4, worker)
                    local gq_5 = {
                        Title = "Refresh Enemy List",
                        Description = "Reload enemies for the selected world from shared data and live workspace.",
                        Callback = function()
                            local jy = f_(fX.SelectedWorld)
                            f7.SetValues(f7, jy)
                            if not table.find(jy, fX.SelectedEnemy) then
                                fX.SelectedEnemy = gc(jy)
                                if fX.SelectedEnemy then
                                    f7.SetValue(f7, fX.SelectedEnemy)
                                end
                            end
                            fV("BWF Automation", "Enemy list refreshed.")
                        end
                    }
                    local Farm = gJ.Farm
                    Farm.CreateButton(Farm, gq_5)
                    local gr_6 = { Title = "Gacha", Values = gm, Multi = false, Searchable = true, Default = fX.SelectedGacha }
                    gs = gJ.Rolls
                    worker = function(cA)
                        fX.SelectedGacha = cA
                    end
                    local gq_6 = (gs:CreateDropdown("GachaDropdown", gr_6))
                    gq_6.OnChanged(gq_6, worker)
                    local gr_7 = { Title = "Auto Spin Gacha", Default = false }
                    gs = gJ.Rolls
                    worker = function(cB)
                        fX.AutoGacha = cB
                        local jA = "Player"
                        local jB = "AntiAfk"
                        local jC = "SetValue"
                        local jD = "LastGacha"
                        local jF = cB and fX.SelectedGacha or "None"
                        f1(jA, jB, jC, jD, jF)
                    end
                    local gq_7 = (gs:CreateToggle("AutoGacha", gr_7))
                    gq_7.OnChanged(gq_7, worker)
                    local gr_8 = {
                        Title = "Island Star",
                        Values = gi_4,
                        Multi = false,
                        Searchable = true,
                        Default = fX.SelectedStar
                    }
                    gs = gJ.Rolls
                    worker = function(cE)
                        fX.SelectedStar = cE
                    end
                    local gq_8 = (gs:CreateDropdown("StarDropdown", gr_8))
                    gq_8.OnChanged(gq_8, worker)
                    local gr_9 = { Title = "Auto Star", Default = false }
                    gs = gJ.Rolls
                    worker = function(cF)
                        fX.AutoStar = cF
                        local jH = "Player"
                        local jI = "AntiAfk"
                        local jJ = "SetValue"
                        local jK = "LastStar"
                        local jM = cF and fX.SelectedStar or "None"
                        f1(jH, jI, jJ, jK, jM)
                    end
                    local gq_9 = (gs:CreateToggle("AutoStar", gr_9))
                    gq_9.OnChanged(gq_9, worker)
                    local gr_10 = { Title = "Farm Distance", Default = fX.FarmDistance, Min = 2, Max = 15, Rounding = 1 }
                    gs = gJ.Settings
                    worker = function(cI)
                        fX.FarmDistance = cI
                    end
                    local gq_10 = (gs:CreateSlider("FarmDistance", gr_10))
                    gq_10.OnChanged(gq_10, worker)
                    local gr_11 = { Title = "Attack Delay", Default = fX.AttackDelay, Min = 0.1, Max = 1, Rounding = 2 }
                    gs = gJ.Settings
                    worker = function(cJ)
                        fX.AttackDelay = cJ
                    end
                    local gq_11 = (gs:CreateSlider("AttackDelay", gr_11))
                    gq_11.OnChanged(gq_11, worker)
                end
                go = (go + 2) % 20
            else
                local gq_12 = (vector.create((go * 4 + 3) % 11 + 1, (go * 9 + 1) % 13 + 1, (go * 13 + 12) % 17 + 1))
                local gr_12 = (vector.create((go * 1 + 7) % 11 + 1, (go * 8 + 8) % 13 + 1, (go * 11 + 4) % 17 + 1))
                if vector.dot(vector.cross(gq_12, gr_12), (vector.cross(gq_12, gr_12))) + vector.dot(gq_12, gr_12) * vector.dot(gq_12, gr_12) == vector.dot(gq_12, gq_12) * vector.dot(gr_12, gr_12) then
                    fX.SelectedStat = gj
                    gm = gH()
                else
                    fX.SelectedStat = gm
                    gH = gj()
                end
                go = (go + 2) % 20
            end
        else
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(go, 1), string.byte(tostring(gn))), 20), 2788305499), 4210802688), (bit32.bxor(bit32.band(bit32.rrotate(bit32.bxor(bit32.lrotate(go, 1), string.byte(tostring(gn))), 20), 1506661796), 1162116723))), 4210802688), 1162116723) ~= bit32.rrotate(bit32.bxor(bit32.lrotate(go, 1), string.byte(tostring(gn))), 20) then
                gc.SelectedGacha = gm(gm)
                fX = gi_4()
            else
                fX.SelectedGacha = gc(gm)
                gi_4 = gI()
            end
            go = (go + 17) % 20
        end
    elseif gp <= 4 then
        if go * 61943991 + 9 + 7 <= go * 61943991 + 9 + 7 + 6 then
            fX.SelectedStar = gc(gi_4)
            local gq_13 = { Title = "Auto Attack", Default = false }
            local Main8 = gJ.Main
            gs = function(cl)
                fX.AutoAttack = cl
            end
            gp = (Main8:CreateToggle("AutoAttack", gq_13))
            gp.OnChanged(gp, gs)
            local gq_14 = { Title = "Auto Punch", Default = false }
            local Main7 = gJ.Main
            gs = function(cm)
                fX.AutoPunch = cm
            end
            gp = (Main7:CreateToggle("AutoPunch", gq_14))
            gp.OnChanged(gp, gs)
            local gq_15 = { Title = "Stat", Values = gk, Multi = false, Searchable = true, Default = fX.SelectedStat }
            local Main6 = gJ.Main
            gs = function(cn)
                fX.SelectedStat = cn
            end
            gp = (Main6:CreateDropdown("StatDropdown", gq_15))
            gp.OnChanged(gp, gs)
            local gq_16 = { Title = "Auto Stats", Default = false }
            local Main5 = gJ.Main
            gs = function(co)
                fX.AutoStats = co
            end
            gp = (Main5:CreateToggle("AutoStats", gq_16))
            gp.OnChanged(gp, gs)
            local gq_17 = { Title = "Auto Claim Rewards", Default = false }
            local Main4 = gJ.Main
            gs = function(cp)
                fX.AutoRewards = cp
            end
            gp = (Main4:CreateToggle("AutoRewards", gq_17))
            gp.OnChanged(gp, gs)
            local gq_18 = { Title = "Auto Claim Index", Default = false }
            local Main3 = gJ.Main
            gs = function(cq)
                fX.AutoIndex = cq
            end
            gp = (Main3:CreateToggle("AutoIndex", gq_18))
            gp.OnChanged(gp, gs)
            local gq_19 = { Title = "Auto Awaken", Default = false }
            local Main2 = gJ.Main
            gs = function(cr)
                fX.AutoAwaken = cr
                f1("General", "Settings", "Set", "Auto Awaken", cr)
            end
            gp = (Main2:CreateToggle("AutoAwaken", gq_19))
            gp.OnChanged(gp, gs)
            local gq_20 = { Title = "Auto Claim Feats", Default = false }
            local Main = gJ.Main
            gs = function(cs)
                fX.AutoFeats = cs
            end
            gp = (Main:CreateToggle("AutoFeats", gq_20))
            gp.OnChanged(gp, gs)
            local gq_21 = { Title = "World", Values = gh, Multi = false, Searchable = true, Default = fX.SelectedWorld }
            local Farm = gJ.Farm
            gn = Farm:CreateDropdown("WorldDropdown", gq_21)
        else
            gn.SelectedStar = gi_4(gk)
            gp = gc.Main
            gu = gp
            gv = gu:CreateToggle("Auto Attack", false)
            gs = gv
            gs.OnChanged(gs, "Title")
            gs = gc.Main
            gw = (gs:CreateToggle(gi_4, gn))
            gw.OnChanged(gw, "AutoAttack")
            local Main = gc.Main
            gy = gn.SelectedStat
            gz = { Multi = false, Title = "Stat", Default = gy, Searchable = true, Values = gJ }
            gA = Main
            gv = (gA:CreateDropdown(gv, gn))
            gv.OnChanged(gv, gp)
            gu = gc.Main
            gs = (gu:CreateToggle("Title", "Stat"))
            gs.OnChanged(gs, "Default")
            worker = gc.Main
            gu = (worker:CreateToggle(false, true))
            gu.OnChanged(gu, "AutoPunch")
            worker = gc.Main
            gp = (worker:CreateToggle(gy, "Auto Stats"))
            gp.OnChanged(gp, gc)
            worker = gc.Main
            local gq_23 = (worker:CreateToggle(Main, "Title"))
            gq_23.OnChanged(gq_23, "AutoAwaken")
            gp = gc.Main
            local gq_24 = (gp:CreateToggle(false, "AutoRewards"))
            gq_24.OnChanged(gq_24, "Default")
            gp = gc.Farm
            gh = gp:CreateDropdown(false, gz)
        end
        go = (go + 2) % 20
    else
        gp = {
            "cvw",
            "yefhcz",
            "axxtop",
            "fnjmcpmqqy",
            "aggnfnn",
            "qekjgqlcwg",
            "wxnbnyanikj",
            "qylhxcnxbbo",
            "ybr"
        }
        local gq_25 = gp[go % 9 + 1]
        gp = go % 3 + 2
        local gr_22 = (gq_25:reverse())
        local ly = gp
        gp = gq_25:len()
        gs = (gr_22:rep(ly))
        if gp <= gs:len() then
            local gq_26 = { Title = "Enemy", Values = gl, Multi = false, Searchable = true, Default = fX.SelectedEnemy }
            local Farm = gJ.Farm
            f7 = Farm:CreateDropdown("EnemyDropdown", gq_26)
        else
            gp = fX.Farm
            local SelectedEnemy = gJ.SelectedEnemy
            local gr_24 = gp
            gl = gr_24:CreateDropdown(SelectedEnemy, gp)
        end
        go = (go + 17) % 20
    end
until fn709((go * 7 + 4) % 20, 494033731)
gh = gJ.Settings
local gi_5 = "PunchDelay"
gj = "Title"
gk = "Punch Delay"
gl = "Default"
gm = fX.PunchDelay or fX.AttackDelay
gn = 0
repeat
    if gn * 956187 + 1 + 5 <= gn * 956187 + 1 + 5 + 4 then
        go = { [gj] = gk, [gl] = gm, Min = 0.1, Max = 1, Rounding = 2 }
        gp = gh
        local function gq_28(cL)
            fX.PunchDelay = cL
        end
        local gi_6 = (gp:CreateSlider(gi_5, go))
        gi_6.OnChanged(gi_6, gq_28)
        go = { Title = "Gacha Delay", Default = fX.GachaDelay, Min = 0.5, Max = 5, Rounding = 1 }
        gp = gJ.Settings
        local function gq_29(cM)
            fX.GachaDelay = cM
        end
        local gi_7 = (gp:CreateSlider("GachaDelay", go))
        gi_7.OnChanged(gi_7, gq_29)
        go = { Title = "Star Delay", Default = fX.StarDelay, Min = 1, Max = 8, Rounding = 1 }
        gp = gJ.Settings
        local gi_8 = (gp:CreateSlider("StarDelay", go))
        gi_8.OnChanged(gi_8, fn251)
        gi_5 = {
            Title = "Unload",
            Description = "Stops all automation loops.",
            Callback = function()
                fX.Unload()
            end
        }
        go = gJ.Settings
        go.CreateButton(go, gi_5)
        fX.Unload = fn974
        gK.SelectTab(gK, 1)
        fV("BWF Automation", "Loaded with Fluent Renewed.", 5)
    else
        gp = gh
        gh = (gp:CreateSlider("Rounding", "Max"))
        gh.OnChanged(gh, 2)
        local gi_9 = { Min = 0.5, Max = 5, Default = fV.GachaDelay, Rounding = 1, Title = "Gacha Delay" }
        gj = fX.Settings
        gh = (gj:CreateSlider(gi_9, "Gacha Delay"))
        gh.OnChanged(gh, 0.5)
        gh = fX.Settings
        local StarDelay = fV.StarDelay
        gj = "Rounding"
        gk = gh
        gl = fn251
        local gi_11 = (gk:CreateSlider(0.1, StarDelay))
        gi_11.OnChanged(gi_11, gl)
        gi_5 = "Title"
        gk = "Callback"
        gl = fX.Settings
        gl.CreateButton(gl, "Callback")
        fV.Unload = fn974
        gm.SelectTab(gm, "Rounding")
        gK("Title", gh, "Loaded with Fluent Renewed.")
    end
    gn = (gn + 6) % 8
until fn709((gn * 1 + 6) % 8, 477252822)
end)(...)
