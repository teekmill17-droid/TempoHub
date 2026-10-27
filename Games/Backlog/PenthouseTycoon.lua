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
getgenv().TempoHoodSubtitle = "PENTHOUSE TYCOON"
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
local gC
local UserInputService
local gF
local g0
local LocalPlayer
local g3
local gp
local gL
local connection
local gs
local TycoonUtil
local gv
local gR
local gy
local gU
local gB
local gX
local gE
local g_
local gH
local g2
local connection2
local g5
local go
local gr
local g8
local gQ
local VirtualUser
local Toggles
local CollectMoneyTS
local gD
local gZ
local Options
local CurrentCamera
local g4
local Label
local gq
local g7
local gM
local gt
local HttpService
local gw
local gS
local gz
local gV
local function onCopyUSDTAddress()
    gq(gR, "Copied USDT address")
end
local function onCopyBitcoinAddress()
    gq(gZ, "Copied Bitcoin address")
end
local function fn33(c9, da)
    local Type = da.Type
    if Type == "Toggle" then
        return { idx = c9, type = "Toggle", value = da.Value == true }
    elseif Type == "Slider" then
        return { idx = c9, type = "Slider", value = tostring(da.Value) }
    elseif Type == "Dropdown" then
        return { idx = c9, type = "Dropdown", multi = da.Multi == true, value = da.Value }
    elseif Type == "Input" then
        local jI = da.Value or ""
        return { idx = c9, type = "Input", text = tostring(jI) }
    elseif Type == "ColorPicker" then
        return { idx = c9, type = "ColorPicker", value = da.Value:ToHex(), transparency = da.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = c9,
            type = "KeyPicker",
            mode = da.Mode,
            key = da.Value,
            modifiers = da.Modifiers,
            toggled = da.Toggled
        }
    else
        return nil
    end
end
local function onInputChanged(cL)
    local UserInputType = cL.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        g_ = tick()
    end
end
local function fn57()
    gq(gv, "Copied Discord invite to clipboard")
end
local function onStepped()
    if gp.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local iP_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if iP_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function fn97()
    local Character = LocalPlayer.Character
    local iN = Character and Character:FindFirstChild("HumanoidRootPart")
    return iN
end
local function fn99()
    g2(Toggles.AntiGameplayPause.Value)
end
local function fn192(ar)
    local DiscordGroup = ar:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = gX })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = gX })
end
local function fn243()
    local io = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if io and io.Name then
        gM = io.Name
    end
end
local function fn244()
    if not Toggles.Fly.Value then
        local i5 = gt()
        if i5 then
            i5.PlatformStand = false
        end
    end
end
local function antiAfkLoop()
    while not gp.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local jw = tick() - g_
            local jx = tick() - gV
            if jw >= 300 and jx >= 60 then
                pcall(gz)
            else
                if jw < 300 and jx >= 300 then
                    pcall(gz)
                end
            end
        end
    end
end
local function fn290(ak, al)
    if setclipboard then
        setclipboard(ak)
    elseif toclipboard then
        toclipboard(ak)
    end
    gp:Notify(al)
end
local function fn291(ax, ay)
    return string.format('<font color="%s">%s</font>', ay, ax)
end
local function fn365(c1, c2)
    local jB = c1 == "Toggle" and Toggles
    local jG = if jB then 1 else 0
    local jE = 248 * jG + 505 * (1 - jG)
    local jF = 1144 * jG + 1299 * (1 - jG)
    if not ((jE * 3131 + jF * 2687 + jE * jF) % 16777213 == 4134128) then
        jB = Options
    end
    local jB_1 = jB[c2]
    local jA_2 = type(jB_1) == "table" and jB_1.Type == c1
    local jA_3 = jA_2 and jB_1
    local jG_1 = if jA_3 then 1 else 0
    local jE_1 = 2662 * jG_1 + 2285 * (1 - jG_1)
    local jF_1 = 1728 * jG_1 + 1245 * (1 - jG_1)
    if not ((jE_1 * 878 + jF_1 * 1190 + jE_1 * jF_1) % 16777213 == 8993492) then
        jA_3 = nil
    end
    return jA_3
end
local function onCopyJoinScript_JobID()
    local iD = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, gE)
    if setclipboard then
        setclipboard(iD)
    elseif toclipboard then
        toclipboard(iD)
    end
    gp:Notify("Copied join script to clipboard")
end
local function onExportConfigToClipboard()
    local j8_1
    local j7_1
    j7_1, j8_1 = pcall(HttpService.JSONEncode, HttpService, gS())
    if not j7_1 then
        gp:Notify("Failed to encode the config")
        return
    end
    local j7_2 = setclipboard or toclipboard
    local j7_3 = type(j7_2) ~= "function" or not pcall(j7_2, j8_1)
    if j7_3 then
        gp:Notify("Your executor does not support copying to the clipboard")
        return
    end
    gp:Notify("Config copied to clipboard", 6)
end
local function fn381()
    local hF = TycoonUtil:GetTycoonsFolder()
    for i, child in ipairs(hF:GetChildren()) do
        local hF_1 = TycoonUtil:GetOwner(child)
        if hF_1 and hF_1 == LocalPlayer then
            return child
        end
    end
    return nil
end
local function fn382()
    gD.X = gD.X + 1
    if connection then
        connection:Disconnect()
    end
    if connection2 then
        connection2:Disconnect()
    end
    g2(false)
end
local function fn407(K, L, M)
    M = M or 0
    if M > 8 then
        return nil
    end
    for i, child in ipairs(K:GetChildren()) do
        if child.Name == L then
            return child
        end
        local hP_1 = gQ(child, L, M + 1)
        if hP_1 then
            return hP_1
        end
    end
    return nil
end
local function worker()
    local iG_1
    while true do
        task.wait(1)
        if gp.Unloaded then
            break
        end
        local iF = math.floor(os.clock() - g8)
        if iF < 60 then
            iG_1 = iF .. "s"
        elseif iF < 3600 then
            iG_1 = string.format("%dm %ds", math.floor((iF) / (60)), iF % 60)
        else
            iG_1 = string.format("%dh %dm", math.floor((iF) / (3600)), math.floor((iF % 3600) / (60)))
        end
        Label:SetText(g0("Session time", iG_1, gw))
    end
end
local function onRenderStepped(b2)
    if gp.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local iZ_1 = gt()
        if iZ_1 then
            iZ_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local iZ_3 = g3()
        local i_ = gt()
        if iZ_3 and i_ then
            i_.PlatformStand = true
            local i__1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                i__1 = i__1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                i__1 = i__1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                i__1 = i__1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                i__1 = i__1 + CurrentCamera.CFrame.RightVector
            end
            local i4 = if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 1 else 0
            if i4 == 1 then
                i__1 = i__1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                i__1 = i__1 - Vector3.new(0, 1, 0)
            end
            iZ_3.Velocity = Vector3.zero
            if i__1.Magnitude > 0 then
                iZ_3.CFrame = iZ_3.CFrame + i__1.Unit * Options.FlySpeed.Value * b2
            end
        end
    end
end
local function fn455(aA, aB, aC)
    return string.format("<b>%s</b> %s %s", aA, go("-", "#5a6070"), go(aB, aC))
end
local function fn474()
    gp:Notify({ Title = "Tempo", Description = "Loaded for " .. gM, Time = 4 })
end
local function onCopyVenmoLink()
    gq(gC, "Copied Venmo link")
end
local function onInputBegan()
    g_ = tick()
end
local function fn503()
    if not Toggles.WalkSpeedEnabled.Value then
        local i7 = gt()
        if i7 then
            i7.WalkSpeed = 16
        end
    end
end
local function onCopyEthereumAddress()
    gq(gU, "Copied Ethereum address")
end
local function fn530()
    local Character = LocalPlayer.Character
    local iK = Character and Character:FindFirstChildOfClass("Humanoid")
    return iK
end
local function fn538()
    local iw_1
    local iv_1
    if identifyexecutor then
        iw_1, iv_1 = identifyexecutor()
        local ix = iw_1 ~= ""
        local iy = type(iw_1) == "string" and ix
        if iy then
            local ix_1 = type(iv_1) == "string" and iv_1 ~= "" and iw_1 .. " " .. iv_1
            gr = ix_1 or iw_1
        end
    end
end
local function antiGameplayPauseLoop()
    while not gp.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            g2(true)
        end
    end
end
local function fn570()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    gV = tick()
end
local function fn575()
    g5:LoadAutoloadConfig()
end
local function onCopyPayPalLink()
    gq(gF, "Copied PayPal link")
end
local function onJumpRequest()
    if gp.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local iX_1 = gt()
        if iX_1 then
            iX_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn644()
    return not (getgenv().X ~= gB)
end
local function onRscripts()
    if setclipboard then
        setclipboard(gs)
    elseif toclipboard then
        toclipboard(gs)
    end
    gp:Notify("Copied Rscripts profile to clipboard")
end
local function onImportConfigFromClipboardTex()
    local kd_1
    local kb = Options.SaveManager_ImportSource.Value or ""
    local kb_1
    local kc = tostring(kb):match("^%s*(.-)%s*$")
    if kc == "" then
        gp:Notify("Paste an exported config into the box first")
        return
    end
    kb_1, kd_1 = pcall(HttpService.JSONDecode, HttpService, kc)
    local kc_1 = not kb_1 or type(kd_1) ~= "table" or type(kd_1.objects) ~= "table"
    if kc_1 then
        gp:Notify("That is not a valid exported config")
        return
    end
    local kb_2 = 0
    for i, v in ipairs(kd_1.objects) do
        if gH(v) then
            kb_2 += 1
        end
    end
    if kb_2 == 0 then
        gp:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local kd_2 = kb_2 == 1 and ""
    local kh = if kd_2 then 1 else 0
    local kf = 2869 * kh + 1655 * (1 - kh)
    local kg = 3718 * kh + 2359 * (1 - kh)
    if not ((kf * 4001 + kg * 1028 + kf * kg) % 16777213 == 9190702) then
        kd_2 = "s"
    end
    gp:Notify(("Imported %d setting%s"):format(kb_2, kd_2), 6)
end
local function autoCollectIncomeLoop()
    while true do
        local ko = gy() and not gp.Unloaded
        if ko then
            if Toggles.AutoCollectIncome.Value then
                pcall(function()
                    CollectMoneyTS:Fire()
                end)
            end
            local wait = task.wait
            local kp = Options.CollectInterval.Value or 1
            wait(kp)
            continue
        end
        break
    end
end
local function onUnload()
    gp:Unload()
end
local function fn697()
    local jL = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local jM = type(v) == "table" and type(v.Type) == "string" and not g5.Ignore[k]
            if jM then
                local jM_1 = g7(k, v)
                if jM_1 then
                    jL[#jL + 1] = jM_1
                end
            end
        end
    end
    table.sort(jL, function(dn, dp)
        if dn.type ~= dp.type then
            return dn.type < dp.type
        end
        return dn.idx < dp.idx
    end)
    return { objects = jL }
end
local function onCopySolanaAddress()
    gq(gL, "Copied Solana address")
end
local function onCopyLitecoinAddress()
    gq(g4, "Copied Litecoin address")
end
go = nil
gp = nil
gq = nil
gr = nil
gs = nil
gt = nil
gv = nil
gw = nil
gy = nil
gz = nil
CollectMoneyTS = nil
gB = nil
gC = nil
gD = nil
gE = nil
gF = nil
CurrentCamera = nil
gH = nil
LocalPlayer = nil
Label = nil
connection2 = nil
gL = nil
gM = nil
TycoonUtil = nil
HttpService = nil
gQ = nil
gR = nil
gS = nil
VirtualUser = nil
gU = nil
gV = nil
Toggles = nil
gX = nil
UserInputService = nil
gZ = nil
g_ = nil
g0 = nil
Options = nil
g2 = nil
g3 = nil
g4 = nil
g5 = nil
connection = nil
g7 = nil
g8 = nil
local gu, gx, gN, g9
local Players
local hx_1
local hv_1
local ht_1
local hn_1
local hm_1
local hl_1
local hb_1, hb_3
local hh_1
Players, UserInputService, VirtualUser, HttpService, LocalPlayer, gD = nil, nil, nil, nil, nil, nil
if (not LocalPlayer or Players) and (gD and gD) and (not gD and gD or (not gD or not HttpService)) or not ((not LocalPlayer or Players) and (gD and gD) and (not gD and gD or (not gD or not HttpService))) then
    Players = game:GetService("Players")
else
    gD = game:GetService("Players")
end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hc_1
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = Players.LocalPlayer
gD = getgenv()
local ha_2 = gD.X or 0
gB, hb_1, gp, g5, Options, Toggles, hh_1, TycoonUtil, CollectMoneyTS, gx, gM, gv, gs, gw, gr, Label, gE, gy, gu, gQ, g9, gq, gX, go, g0 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
gD.X = ha_2 + 1
gB = gD.X
gy = fn644
if (gq and false or not gr and gr or (gr or not hh_1) and (gq or false)) and ((gq or false) and (not gq) and (not gr or hh_1 or (gq or false))) and not ((gq and false or not gr and gr or (gr or not hh_1) and (gq or false)) and ((gq or false) and (not gq) and (not gr or hh_1 or (gq or false)))) then
    g9 = ""
else
    hb_1 = ""
end
gp = getgenv().Library
local hr = getgenv().ThemeManager
g5 = getgenv().SaveManager
Options = gp.Options
Toggles = gp.Toggles
TycoonUtil = require(ReplicatedStorage.Shared.Utilities.TycoonUtil)
local Remotes = require(ReplicatedStorage.Shared.Modules.Pronghorn.Remotes)
local NetworkedVariable = require(ReplicatedStorage.Shared.Modules.NetworkedVariable)
local hf_1
CollectMoneyTS = Remotes.Client.TycoonService.CollectMoneyTS
gx = NetworkedVariable.new("MoneyNetworked")
gu = fn381
gQ = fn407
g9 = function()
    local h8 = gu()
    if not h8 then
        return {}
    end
    local h9 = gQ(h8, "Buttons")
    if not h9 then
        return {}
    end
    local h8_1 = gx:GetValue()
    local ia = {}
    for i, child in ipairs(h9:GetChildren()) do
        local h7
        local im = child
        local attr = im:GetAttribute("Price")
        if attr and h8_1 >= attr then
            h7 = nil
            pcall(function()
                h7 = im.PrimaryPart
                if not h7 then
                    for i, descendant in ipairs(im:GetDescendants()) do
                        local hX = descendant:IsA("BasePart") and descendant:FindFirstChildOfClass("TouchTransmitter")
                        if hX then
                            h7 = descendant
                            break
                        end
                    end
                end
            end)
            if h7 then
                table.insert(ia, { model = im, part = h7, price = attr })
            end
        end
    end
    return ia
end
if ((CollectMoneyTS and CollectMoneyTS or (not CollectMoneyTS or false)) and (CollectMoneyTS or gM or CollectMoneyTS and gM) or (false and gM or false or (not CollectMoneyTS or gM) and "#6ec1ff")) and ((false or gM or false) and (not CollectMoneyTS and CollectMoneyTS or (CollectMoneyTS or gM)) and ((CollectMoneyTS and false or false and not CollectMoneyTS) and (CollectMoneyTS and CollectMoneyTS and (not CollectMoneyTS or not gM)))) and not (((CollectMoneyTS and CollectMoneyTS or (not CollectMoneyTS or false)) and (CollectMoneyTS or gM or CollectMoneyTS and gM) or (false and gM or false or (not CollectMoneyTS or gM) and "#6ec1ff")) and ((false or gM or false) and (not CollectMoneyTS and CollectMoneyTS or (CollectMoneyTS or gM)) and ((CollectMoneyTS and false or false and not CollectMoneyTS) and (CollectMoneyTS and CollectMoneyTS and (not CollectMoneyTS or not gM))))) then
else
    gM = "Penthouse Tycoon"
end
pcall(fn243)
setthreadidentity(8)
gv = "https://discord.gg/K7Qxnxkk46"
gs = "https://discord.gg/K7Qxnxkk46"
gq = fn290
gX = fn57
local Window = gp:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = gv, Copyable = true }, "|", gM },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local hp = {
    Info = Window:AddTab("Info", "info"),
    Farming = Window:AddTab("Farming", "warehouse"),
    Inventory = Window:AddTab("Inventory", "package"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
go = fn291
g0 = fn455
hn_1, hm_1, gw, hl_1 = "#7fd47f", "#6ec1ff", "#e8a34d", "#8b93a3"
gr = "Unknown"
pcall(fn538)
local AccountGroup = hp.Info:AddLeftGroupbox("Account", "circle-user")
local hi_1
AccountGroup:AddLabel(g0("User", LocalPlayer.Name, hn_1), true)
AccountGroup:AddLabel(g0("Status", "Keyless", hn_1), true)
AccountGroup:AddLabel(g0("Executor", gr, hn_1), true)
local GameInfoGroup = hp.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameInfoGroup:AddLabel(go(gM .. " [" .. tostring(game.PlaceId) .. "]", hm_1), true)
GameInfoGroup:AddLabel(g0("Place ID", tostring(game.PlaceId), hm_1), true)
Label = GameInfoGroup:AddLabel(g0("Session time", "0s", gw), true)
gE = tostring(game.JobId)
local hk = #gE > 18
if hk then
    local ha_3 = 2
    repeat
        local hb_2 = {
            "imlbedti",
            "nwxomumidsf",
            "izwica",
            "beloffgxwkz",
            "qmkrtum",
            "pfuxvrumkpc",
            "iejuldrqsgub",
            "vynpuntup",
            "gyu",
            "wcm",
            "ayltdjvjhdx",
            "hxxdslvj",
            "bpszkn"
        }
        if hb_2[(ha_3 * 1 + 7) % 13 + 1] <= hb_2[(ha_3 * 1 + 7) % 13 + 1] then
            hk = string.sub(gE, 1, 18) .. "..."
        else
            gE = string.sub(hk, 1, 18) .. "..."
        end
        ha_3 = (ha_3 + 2) % 8
    until (ha_3 * 1 + 2) % 8 == 6
end
local ha_4 = hk or gE
g8, g4, gZ, gU, gR, gL, gF, gC = nil, nil, nil, nil, nil, nil, nil, nil
GameInfoGroup:AddLabel(g0("Server", ha_4, hl_1), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
g8 = os.clock()
task.spawn(worker)
local ScriptsGroup = hp.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(go("Included in this hub", hl_1), true)
ScriptsGroup:AddLabel(go(gM, hm_1), true)
local FeaturesGroup = hp.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(go("Auto Collect Income", hm_1), true)
FeaturesGroup:AddLabel(go("Auto Buy Buttons", gw), true)
FeaturesGroup:AddLabel(go("Player Movement", hl_1), true)
local SocialsGroup = hp.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = gX })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = hp.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = gX })
g4 = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
gZ = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
gU = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
gR = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
gL = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
gF = ""
gC = ""
hi_1, hf_1, hc_1, hb_3, hx_1, hv_1, ht_1 = "#345d9d", "#f7931a", "#627eea", "#26a17b", "#14f195", "#0070ba", "#008cff"
local DonationsGroup = hp.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(go("All donations are optional but appreciated.", gw), true)
DonationsGroup:AddLabel(go("If you donate you get a special role, just PING after you donate.", hn_1), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(go("LTC / Litecoin", hi_1), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(go("BTC / Bitcoin", hf_1), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(go("ETH / Ethereum", hc_1), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(go("USDT", hb_3), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(go("Solana", hx_1), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(go("PayPal", hv_1), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(go("Venmo", ht_1), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(go("Don't have any of the listed currencies but still wanna donate?", hl_1), true)
DonationsGroup:AddLabel(go("DM me and we'll work something out.", hm_1), true)
local FaqGroup = hp.Info:AddRightGroupbox("FAQ", "circle-help")
if not ScriptsGroup and not ScriptsGroup and (ScriptsGroup and not hc_1) and (SocialsGroup and SocialsGroup and (hc_1 and hc_1)) and ((ScriptsGroup or not hc_1) and (SocialsGroup or not hc_1) or (not ScriptsGroup and ScriptsGroup or not hc_1 and ScriptsGroup)) or (ScriptsGroup or SocialsGroup or hc_1 and ScriptsGroup) and ((SocialsGroup or hc_1) and (not SocialsGroup and hc_1)) and (not hc_1 or hc_1 or not ScriptsGroup and not SocialsGroup or (hc_1 or ScriptsGroup or (not SocialsGroup or hc_1))) or not (not ScriptsGroup and not ScriptsGroup and (ScriptsGroup and not hc_1) and (SocialsGroup and SocialsGroup and (hc_1 and hc_1)) and ((ScriptsGroup or not hc_1) and (SocialsGroup or not hc_1) or (not ScriptsGroup and ScriptsGroup or not hc_1 and ScriptsGroup)) or (ScriptsGroup or SocialsGroup or hc_1 and ScriptsGroup) and ((SocialsGroup or hc_1) and (not SocialsGroup and hc_1)) and (not hc_1 or hc_1 or not ScriptsGroup and not SocialsGroup or (hc_1 or ScriptsGroup or (not SocialsGroup or hc_1)))) then
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
else
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
end
local IncomeCollectionGroup = hp.Farming:AddRightGroupbox("Income Collection", "coins")
IncomeCollectionGroup:AddToggle("AutoCollectIncome", { Text = "Auto Collect Income", Default = false })
IncomeCollectionGroup:AddSlider("CollectInterval", { Text = "Collect Interval", Default = 1, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
local ButtonPurchasingGroup = hp.Inventory:AddRightGroupbox("Button Purchasing", "shopping-cart")
ButtonPurchasingGroup:AddToggle("AutoBuyButtons", { Text = "Auto Buy All Buttons", Default = false })
ButtonPurchasingGroup:AddSlider("BuyInterval", { Text = "Buy Interval", Default = 0.3, Min = 0.1, Max = 10, Rounding = 1, Suffix = "s" })
ButtonPurchasingGroup:AddToggle("OnlyAffordable", { Text = "Only Buy If Affordable", Default = true })
ButtonPurchasingGroup:AddToggle("TeleportToButtons", { Text = "Teleport to Buttons", Default = false })
CurrentCamera, g_, gV, connection, connection2, gt, g3, g2, gz, gN, g7, gS, gH = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
fn192(hp.Farming)
fn192(hp.Inventory)
fn192(hp.Player)
local MovementGroup = hp.Player:AddRightGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = hp.Player:AddLeftGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
gt = fn530
g3 = fn97
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn244)
Toggles.WalkSpeedEnabled:OnChanged(fn503)
g2 = function(cn)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not cn)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not cn
        end
    end)
    if not cn then
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
Toggles.AntiGameplayPause:OnChanged(fn99)
task.spawn(antiGameplayPauseLoop)
local MenuGroup = hp.Settings:AddLeftGroupbox("Menu", "wrench")
g_ = tick()
gV = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local jn = v
        pcall(function()
            jn:Disable()
        end)
    end
end)
gz = fn570
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
MenuGroup:AddButton("Unload", onUnload)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
gp.ToggleKeybind = Options.MenuKeybind
hr:SetLibrary(gp)
g5:SetLibrary(gp)
g5:IgnoreThemeSettings()
g5:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
hr:SetFolder("TempoHub")
g5:SetFolder("TempoHub/PenthouseTycoon")
g5:SetSubFolder(tostring(game.PlaceId))
local hg_2 = g5:BuildConfigSection(hp.Settings)
hr:ApplyToTab(hp.Settings)
hr:SaveDefault("Evil Hello Kitty")
hr:LoadDefault()
gN = fn365
g7 = fn33
gS = fn697
gH = function(dr)
    local j4
    j4 = nil
    local j5 = type(dr) ~= "table" or type(dr.idx) ~= "string" or type(dr.type) ~= "string" or g5.Ignore[dr.idx]
    if j5 then
        return false
    end
    j4 = gN(dr.type, dr.idx)
    if not j4 then
        return false
    end
    local j5_1 = pcall(function()
        if dr.type == "Input" then
            if type(dr.text) ~= "string" then
                return
            end
            j4:SetValue(dr.text)
        elseif dr.type == "ColorPicker" then
            j4:SetValueRGB(Color3.fromHex(dr.value), dr.transparency)
        elseif dr.type == "KeyPicker" then
            j4:SetValue({ dr.key, dr.mode, dr.modifiers })
            if dr.mode == "Toggle" and dr.toggled ~= nil then
                j4.Toggled = dr.toggled
                j4:Update()
            end
        else
            j4:SetValue(dr.value)
        end
    end)
    return j5_1
end
hg_2:AddDivider()
hg_2:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
hg_2:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
hg_2:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
pcall(fn575)
task.spawn(autoCollectIncomeLoop)
task.spawn(function()
    local kB = false
    repeat
        local kx = gy() and not gp.Unloaded
        if kx then
            if Toggles.AutoBuyButtons.Value then
                local Character = LocalPlayer.Character
                local ky_1 = Character and Character:FindFirstChild("HumanoidRootPart")
                local kw = ky_1
                if kw then
                    local kx_2 = g9()
                    for i, v in ipairs(kx_2) do
                        local kH = v
                        local kx_3 = not gy() or gp.Unloaded
                        if kx_3 then
                            break
                        elseif not Toggles.AutoBuyButtons.Value then
                            break
                        else
                            local kx_4 = not Toggles.OnlyAffordable.Value
                            if not kx_4 then
                                local ky_2 = kH.price and gx:GetValue() >= kH.price
                                kx_4 = ky_2
                            end
                            if kx_4 then
                                pcall(function()
                                    if Toggles.TeleportToButtons.Value then
                                        kw.CFrame = kH.part.CFrame + Vector3.new(0, 3, 0)
                                        task.wait(0.1)
                                    end
                                    firetouchinterest(kw, kH.part, 0)
                                    task.wait(0.05)
                                    firetouchinterest(kw, kH.part, 1)
                                end)
                            end
                            task.wait(0.05)
                        end
                    end
                end
            end
            local wait = task.wait
            local ky_3 = Options.BuyInterval.Value
            local kK = if ky_3 then 1 else 0
            local kI = 1445 * kK + 1267 * (1 - kK)
            local kJ = 1439 * kK + 1110 * (1 - kK)
            if not ((kI * 2178 + kJ * 64 + kI * kJ) % 16777213 == 5318661) then
                ky_3 = 0.3
            end
            wait(ky_3)
        else
            kB = true
        end
    until kB
end)
gp:OnUnload(fn382)
pcall(fn474)
end)(...)
