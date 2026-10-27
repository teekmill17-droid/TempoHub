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
getgenv().TempoHoodSubtitle = "STEAL AN EMPLOYEE"
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
local T5_2, T5_5, T5_7, T5_8
T5_2 = nil
T5_5 = nil
T5_7 = nil
T5_8 = nil
local CT
local DA
local connection
local Dh
local BA
local Ch
local CZ
local BZ
local CG
local State
local BG
local Cn
local C4
local CM
local Dt
local Ct
local Da
local CS
local Dz
local Cz
local Bz
local Cg
local BY
local BF
local Dm
local C3
local Cm
local CL
local Ds
local BL
local Cs
local C9
local B9
local B3
local Dy
local BR
local Cy
local Df
local BX
local BE
local Cl
local B2
local CK
local BK
local Dr
local C8
local Cr
local BQ
local Cx
local CW
local CD
local BD
local Ck
local C1
local B1
local LocalPlayer
local Dq
local BJ
local Cq
local B7
local CP
local Dw
local Cw
local Dd
local CV
local BV
local CC
local Dj
local CoreGui
local B0
local CI
local B6
local Dv
local BO
local Cv
local Dc
local Cc
local CU
local CB
local BB
local Ci
local Di
local C_
local B_
local CH
local BH
local Co
local C5
function fns.fn17()
    local GC_1
    local Gw = C5()
    if not Gw then
        return nil
    end
    local TrackBed = Gw:FindFirstChild("TrackBed", true)
    local Gy = TrackBed and TrackBed:IsA("BasePart")
    if Gy then
        local Gy_1 = tonumber(Gw:GetAttribute("TrackW")) or 1.6
        local Gy_2 = tonumber(Gw:GetAttribute("TrackR"))
        local GA = tonumber(Gw:GetAttribute("TrackS")) or 5.5
        if Gy_2 then
            local GA_1 = 2 * (Gy_1 + Gy_2 + GA)
            local GA_2 = GA_1 > 0 and TrackBed.Size.X / GA_1
            local GG = if GA_2 then 1 else 0
            local GE = 2521 * GG + 3106 * (1 - GG)
            local GF = 1472 * GG + 2736 * (1 - GG)
            if not ((GE * 2248 + GF * 836 + GE * GF) % 16777213 == 10608712) then
                GA_2 = 1
            end
            GC_1 = Gy_2 * GA_2
        else
            GC_1 = math.max(1, TrackBed.Size.Z * 0.5 - Gy_1)
        end
        return (TrackBed.CFrame * CFrame.new(0, TrackBed.Size.Y * 0.5 + 3.5, GC_1)).Position
    end
    local StartLine = Gw:FindFirstChild("StartLine", true)
    local Gy_3 = StartLine and StartLine:IsA("BasePart")
    if Gy_3 then
        return StartLine.Position + Vector3.new(0, 4, 0)
    end
    return Gw:GetPivot().Position + Vector3.new(0, 4, 0)
end
function fns.fn20()
    local Pf_1
    local Pc = C3("SafeZone")
    local Pd
    local Pe = Pc and B_(Pc.Part)
    local Pe_1
    if Pe then
        Pe_1, Pf_1 = pcall(Pc.Part)
        local Pc_1 = Pe_1 and typeof(Pf_1) == "Instance" and Pf_1:IsA("BasePart")
        if Pc_1 then
            Pd = Pf_1
        end
    end
    if not Pd then
        local Pc_2 = CS()
        local Pe_2 = Pc_2 and Pc_2:FindFirstChild("SafeZone")
        local Pc_3 = Pe_2
        if Pe_2 then
            Pe_2 = Pc_3:IsA("BasePart")
        end
        if Pe_2 then
            Pd = Pc_3
        end
    end
    if not Pd then
        Dh("Safe zone not found")
        return false
    end
    return BF(Pd.Position + Vector3.new(0, 5, 0))
end
function fns.fn30()
    local N4 = tonumber(LocalPlayer:GetAttribute("SpinNextAt")) or 0
    local N4_1 = Cx()
    if N4 > N4_1 then
        State.RewardStatus = string.format("Spin in %ds", math.ceil(N4 - N4_1))
        return
    end
    local N4_2 = Ci("SpinWheelSpin")
    if type(N4_2) == "table" then
        State.RewardStatus = "Spun the wheel"
        CV()
    else
        State.RewardStatus = "Spin unavailable"
    end
end
function fns.fn85(fd)
    local HumanoidRootPart = fd:FindFirstChild("HumanoidRootPart")
    local IB = HumanoidRootPart and HumanoidRootPart:FindFirstChild("StealPrompt")
    local IC = IB
    if IB then
        IB = IC:IsA("ProximityPrompt")
    end
    if IB then
        return IC, HumanoidRootPart
    end
    return nil, HumanoidRootPart
end
function fns.fn91()
    local TrailShop = Dv:FindFirstChild("TrailShop")
    local LP = TrailShop and TrailShop:FindFirstChild("TrailShopkeeper")
    local LO_1 = LP
    if LP then
        LP = LO_1:FindFirstChild("HumanoidRootPart")
    end
    local LO_2 = LP
    if LP then
        LP = LO_2:IsA("BasePart")
    end
    if LP then
        return LO_2.Position + Vector3.new(0, 0, 5)
    end
    return nil
end
function fns.fn98(n6)
    if n6 then
        C8(B2, B0)
    else
        B9(B2)
        State.ManageStatus = "Idle"
    end
end
function fns.fn101()
    Dy.at = 0
end
function fns.fn102()
    local CarDealership = Dv:FindFirstChild("CarDealership")
    local LV = CarDealership and CarDealership:FindFirstChild("CarDealer")
    local LU_1 = LV
    if LV then
        LV = LU_1:FindFirstChild("HumanoidRootPart")
    end
    local LU_2 = LV
    if LV then
        LV = LU_2:IsA("BasePart")
    end
    if LV then
        return LU_2.Position + Vector3.new(0, 0, 5)
    end
    return nil
end
function fns.fn107()
    local EX = T5_2()
    local EY = EX and EX:FindFirstChildOfClass("Humanoid")
    return EY or nil
end
function fns.fn138(oh)
    local OR = tonumber(oh) or 0
    B2.maxIncome = math.max(0, math.floor(OR))
end
function fns.fn141()
    local LF = C3("OfficeDesks")
    local LG = not LF or type(LF.BY_LEVEL) ~= "table"
    if LG then
        State.ProgressStatus = "Desk catalog missing"
        return
    end
    local LG_1 = Dq()
    if not LG_1 then
        return
    end
    local LH = (tonumber(LG_1.OfficeLevel))
    local LN = if LH then 1 else 0
    local LL = 1031 * LN + 113 * (1 - LN)
    local LM = 621 * LN + 32 * (1 - LN)
    if not ((LL * 781 + LM * 2488 + LL * LM) % 16777213 == 2990510) then
        LH = 1
    end
    local LI = 0
    local LJ = LH
    if type(LG_1.DesksBought) == "table" then
        local LH_1 = tonumber(LG_1.DesksBought[tostring(LJ)]) or tonumber(LG_1.DesksBought[LJ])
        LI = LH_1 or 0
    end
    local LG_3 = LF.BY_LEVEL[LJ]
    local LN_1 = if LG_3 then 1 else 0
    local LL_1 = 1844 * LN_1 + 3318 * (1 - LN_1)
    local LM_1 = 1769 * LN_1 + 3182 * (1 - LN_1)
    if not ((LL_1 * 1724 + LM_1 * 2496 + LL_1 * LM_1) % 16777213 == 10856516) then
        LG_3 = LF.BY_LEVEL[tostring(LJ)]
    end
    local LH_2 = LG_3
    local LG_4 = type(LH_2) == "table" and LI < #LH_2
    if LG_4 then
        local LG_5 = LH_2[LI + 1]
        local LH_3 = LG_5 and tonumber(LG_5.price)
        local LG_6 = LH_3 or 0
        if C4() >= LG_6 then
            CU("RequestDeskPurchase")
            State.ProgressStatus = "Bought desk"
            CV()
            task.wait(1)
            return
        end
        State.ProgressStatus = string.format("Desk needs %d", LG_6)
        return
    end
    local LG_7 = LF.UPGRADE[LJ + 1] or LF.UPGRADE[tostring(LJ + 1)]
    if not LG_7 then
        State.ProgressStatus = "Office maxed"
        return
    end
    local LG_8 = tonumber(LG_7.price) or 0
    if C4() < LG_8 then
        State.ProgressStatus = string.format("Office needs %d", LG_8)
        return
    end
    CU("RequestOfficeUpgrade")
    State.ProgressStatus = "Upgraded office"
    CV()
    task.wait(1)
end
function fns.fn151(oj)
    B2.includeBanked = oj == true
end
function fns.fn170()
    return Dv:FindFirstChild("PlotArea")
end
function fns.fn179(eR)
    local Ic_1, Ic_2
    local Ib_1, Ib_2
    if not eR then
        return nil
    end
    local Ia = Dv:FindFirstChild(eR.id)
    if eR.center then
        Ic_1, Ib_1 = eR.center.X, eR.center.Y
        return BA(Ic_1, Ib_1, 8)
    elseif Ia then
        Ic_2, Ib_2 = Ia:GetPivot().Position.X, Ia:GetPivot().Position.Z
        return BA(Ic_2, Ib_2, 8)
    else
        return nil
    end
end
function fns.fn201(ax)
    local Er = Cc()
    local Es = Er and Er:FindFirstChild(ax)
    local Er_1 = Es
    if Es then
        Es = Er_1:IsA("RemoteEvent")
    end
    if Es then
        return Er_1
    end
    return nil
end
function fns.fn225(oz)
    if oz then
        C8(BQ, Dr)
    else
        B9(BQ)
    end
end
function fns.fn235(eu)
    for i, v in ipairs(BG()) do
        if v.id == eu then
            return v
        end
    end
    return nil
end
function fns.fn238(c1)
    local ProximityPrompt = c1:FindFirstChildWhichIsA("ProximityPrompt")
    if ProximityPrompt and ProximityPrompt.Name == "PlacePrompt" then
        return ProximityPrompt
    end
    for i, child in ipairs(c1:GetChildren()) do
        if child:IsA("ProximityPrompt") then
            return child
        end
    end
    return nil
end
function fns.fn256()
    local Pm = C3("Machines")
    local Pn = Pm and tostring(Pm.MODEL_NAME)
    local Pm_1 = Pn or "RequisitionMachine"
    local Zone10 = Dv:FindFirstChild("Zone10")
    local Po = Zone10 and Zone10:FindFirstChild(Pm_1, true)
    if not Po then
        Dh("Machine not found")
        return false
    end
    local Pn_2 = Po:IsA("BasePart") and Po.Position
    local Po_1 = Pn_2 or Po:GetPivot().Position
    return BF(BA(Po_1.X, Po_1.Z + 8, Po_1.Y))
end
function fns.fn304(oo)
    local OV = tonumber(oo) or 10
    B2.batch = math.clamp(math.floor(OV), 1, 50)
end
function fns.fn309()
    local F6 = Dw()
    if #F6 > 0 then
        CB = math.max(CB, #F6)
        local F7 = 0
        for i, v in ipairs(F6) do
            if v.Occupant == nil then
                F7 += 1
            end
        end
        return F7
    elseif CB <= 0 then
        return nil
    else
        return math.max(0, CB - T5_7())
    end
end
function fns.fn311()
    local NM = Dj(CM())
    if #NM == 0 then
        State.ManageStatus = "Nothing matches sell filters"
        return
    end
    table.sort(NM, function(mi, mj)
        local NJ = tonumber(mi.Income) or 0
        local NK = tonumber(mj.Income) or 0
        return NJ > NK
    end)
    local max2 = math.max
    local floor2 = math.floor
    local NP = B2.keepCount
    local NW = if NP then 1 else 0
    local NU = 1810 * NW + 404 * (1 - NW)
    local NV = 2721 * NW + 1897 * (1 - NW)
    if not ((NU * 3428 + NV * 3260 + NU * NV) % 16777213 == 3222937) then
        NP = 0
    end
    local NQ = max2(0, floor2(NP))
    if #NM <= NQ then
        State.ManageStatus = string.format("Keeping top %d", NQ)
        return
    end
    if not Dm() then
        return
    end
    local NN_1 = Cw()
    if NN_1 then
        Da(NN_1)
    end
    local NN_2 = Cv()
    if NN_2 then
        BF(NN_2, B1)
    end
    local NN_3 = 0
    local max = math.max
    local floor = math.floor
    local NR = B2.batch or 10
    local NS = max(1, floor(NR))
    local NO_2 = NQ + 1
    local NP_2 = #NM
    local NZ = NO_2
    while NZ <= NP_2 do
        local N_ = NZ
        local NO_3 = not BL() or B2.stopped or NN_3 >= NS
        if NO_3 then
            break
        end
        CU("RequestEmployeeSell", NM[N_].Uid)
        NN_3 += 1
        task.wait(0.25)
        NZ += 1
    end
    Df()
    State.Sold = State.Sold + NN_3
    State.ManageStatus = string.format("Sold %d of %d", NN_3, #NM - NQ)
    CV()
end
function fns.fn313()
    CU("RequestEquipBest")
    State.ManageStatus = "Equipped best employees"
end
function fns.fn350()
    local SellShop = Dv:FindFirstChild("SellShop")
    local Ni = SellShop and SellShop:FindFirstChild("EmployeeBroker")
    local Nh_1 = Ni
    if Ni then
        Ni = Nh_1:FindFirstChild("HumanoidRootPart")
    end
    local Nh_2 = Ni
    if Ni then
        Ni = Nh_2:IsA("BasePart")
    end
    if Ni then
        return Nh_2.Position + Vector3.new(0, 0, 5)
    end
    return nil
end
function fns.fn358(m5)
    CI.priority = m5 == true
end
function fns.fn369()
    if LocalPlayer:GetAttribute("DailyPending") ~= true then
        local Oa_1 = tonumber(LocalPlayer:GetAttribute("DailyNextAt")) or 0
        local Oa_2 = Cx()
        if Oa_1 > Oa_2 then
            State.RewardStatus = string.format("Daily in %dm", math.ceil((Oa_1 - Oa_2) / 60))
            return
        end
    end
    local Oa_3 = Ci("DailyRewardClaim")
    if type(Oa_3) == "table" then
        State.RewardStatus = "Claimed daily reward"
        CV()
    else
        State.RewardStatus = "Daily unavailable"
    end
end
function fns.fn370(cd, ce, cf)
    local Fx = RaycastParams.new()
    Fx.FilterType = Enum.RaycastFilterType.Exclude
    local Fy = T5_2()
    local Fz_1 = Fy and { Fy } or {}
    Fx.FilterDescendantsInstances = Fz_1
    local Fy_2 = Dv:Raycast(Vector3.new(cd, 600, ce), Vector3.new(0, -1200, 0), Fx)
    if Fy_2 then
        return Vector3.new(cd, Fy_2.Position.Y + 5, ce)
    end
    local new = Vector3.new
    local Fy_3 = cf or 8
    return new(cd, Fy_3, ce)
end
function fns.fn378()
    for i, v in ipairs(Bz) do
        B9(v)
    end
    local Px = Cw()
    if Px then
        pcall(Da, Px)
    end
end
function fns.fn413()
    return CoreGui
end
function fns.fn436(d5)
    local Hl = C_
    local Hq = if Hl then 1 else 0
    local Ho = 3706 * Hq + 1992 * (1 - Hq)
    local Hp = 651 * Hq + 2358 * (1 - Hq)
    if not ((Ho * 3770 + Hp * 1462 + Ho * Hp) % 16777213 == 558775) then
        Hl = CW()
    end
    local Hm = Hl
    if not Hm then
        return false
    end
    return DA(d5, Hm)
end
function fns.fn438(W)
    local El = typeof(cloneref) == "function" and typeof(W) == "Instance"
    if El then
        return cloneref(W)
    end
    return W
end
function fns.fn439()
    local HN = {}
    for i, v in ipairs(BG()) do
        HN[#HN + 1] = string.format("%d. %s", v.level, v.name)
    end
    return HN
end
function fns.fn440()
    local O6 = Dd()
    if not O6 then
        Dh("Plot not found")
        return false
    end
    return BF(O6)
end
function fns.fn444()
    return LocalPlayer.Character
end
function fns.fn448(gX)
    gX.stopped = true
    local JK = gX.generation
    local JO = if JK then 1 else 0
    local JM = 2291 * JO + 696 * (1 - JO)
    local JN = 682 * JO + 315 * (1 - JO)
    if not ((JM * 1368 + JN * 2335 + JM * JN) % 16777213 == 6289020) then
        JK = 0
    end
    gX.generation = JK + 1
end
function fns.fn509()
    local Nn = {}
    for i, v in ipairs(BR) do
        Nn[i] = v
    end
    return Nn
end
function fns.fn538()
    return BB:FindFirstChild("Remotes")
end
function fns.fn544(Z)
    return type(Z) == "function"
end
function fns.fn552()
    local attr = LocalPlayer:GetAttribute("PlotName")
    local FD = CS()
    local FE = attr == ""
    local FF = type(attr) ~= "string" or FE
    if FF or not FD then
        return nil
    end
    local FE_2 = FD:FindFirstChild(attr)
    local FC_1 = FE_2 and FE_2:IsA("Model")
    if FC_1 then
        return FE_2
    end
    return nil
end
function fns.fn645()
    gethui = Cz
end
function fns.fn647(nK)
    if nK then
        C8(Cg, Dt)
    else
        B9(Cg)
    end
end
function fns.fn674(oe)
    B2.ranks = BX(oe)
end
function fns.fn708(eK)
    for i, v in ipairs(BG()) do
        if v.min and v.max then
            if eK.X >= v.min.X and eK.X <= v.max.X and eK.Z >= v.min.Y and eK.Z <= v.max.Y then
                return v
            end
        end
    end
    return nil
end
function fns.fn710()
    if Ds then
        return false
    end
    Ds = true
    return true
end
function fns.fn733(m1)
    CI.zones = BX(m1, T5_5)
end
function fns.fn735(ag)
    State.Status = tostring(ag)
end
function fns.fn760()
    local Go = CS()
    local Gp = Go and Go:FindFirstChild("PlotTracks")
    local Gp_1 = T5_8()
    local Gq = not Gp_1
    local Gr = not Gp
    local Gv = if Gr then 1 else 0
    local Gt = 2618 * Gv + 3548 * (1 - Gv)
    local Gu = 3466 * Gv + 1869 * (1 - Gv)
    if not ((Gt * 3233 + Gu * 3158 + Gt * Gu) % 16777213 == 11706397) then
        Gr = Gq
    end
    if Gr then
        return nil
    end
    local Gq_1 = Gp:FindFirstChild("Track" .. tostring(Gp_1))
    local Go_2 = Gq_1 and Gq_1:IsA("Model")
    if Go_2 then
        return Gq_1
    end
    return nil
end
function fns.fn770(n1)
    if n1 then
        C8(B6, CL)
    else
        B9(B6)
    end
end
function fns.fn774(eE)
    local HV = tonumber(tostring(eE):match("^(%d+)%."))
    if not HV then
        return tostring(eE)
    end
    for i, v in ipairs(BG()) do
        if v.level == HV then
            return v.id
        end
    end
    return tostring(eE)
end
function fns.fn793()
    local attr = LocalPlayer:GetAttribute("Cash")
    if type(attr) == "number" then
        return attr
    end
    local Ls_1 = Dq()
    local Lt = Ls_1 and tonumber(Ls_1.Cash)
    return Lt or 0
end
function fns.fn798()
    local Jo = Dd()
    if not Jo then
        return false
    end
    return BF(Jo, B1)
end
function fns.fn803()
    return LocalPlayer:GetAttribute("Carrying") == true
end
function fns.fn804()
    for i, v in ipairs(BD()) do
        if v:GetAttribute("Drawn") == true then
            return v
        end
    end
    local I4 = T5_2()
    if I4 then
        for i, child in ipairs(I4:GetChildren()) do
            local I4_1 = child:IsA("Tool") and child:GetAttribute("CarrySlot") == true
            if I4_1 then
                return child
            end
        end
    end
    return nil
end
function fns.fn813(om)
    B2.includeUntrained = om == true
end
function fns.fn827(oJ)
    if oJ then
        C8(BH, B7)
    else
        B9(BH)
    end
end
function fns.fn849(nc)
    if nc then
        C8(CD, Cs)
    else
        B9(CD)
        State.PlaceStatus = "Idle"
        task.spawn(function()
            local Os = Cw()
            if Os then
                Dz()
                Da(Os)
            end
        end)
    end
end
function fns.fn852(nA)
    if nA then
        C8(Co, Di)
    else
        B9(Co)
    end
end
function fns.fn868(ak)
    local Ep_1
    if C9[ak] ~= nil then
        return C9[ak] or nil
    end
    local Shared = BB:FindFirstChild("Shared")
    local Eo = Shared and Shared:FindFirstChild(ak)
    local Eo_2
    local Eo_1 = not Eo or not Eo:IsA("ModuleScript")
    if Eo_1 then
        C9[ak] = false
        return nil
    end
    Eo_2, Ep_1 = pcall(require, Eo)
    local En_4 = not Eo_2 or type(Ep_1) ~= "table"
    if En_4 then
        C9[ak] = false
        return nil
    end
    C9[ak] = Ep_1
    return Ep_1
end
function fns.fn882()
    connection:Disconnect()
end
function fns.fn912()
    if LocalPlayer:GetAttribute("GroupGiftTaken") == true then
        State.RewardStatus = "Group gift already taken"
        return
    end
    local Od = Ci("GroupGiftClaim")
    if type(Od) == "string" then
        State.RewardStatus = "Group gift: " .. Od
    elseif type(Od) == "table" then
        State.RewardStatus = "Claimed group gift"
        CV()
    else
        State.RewardStatus = "Group gift unavailable"
    end
end
function fns.fn941(lX)
    local NA_1
    local ranks = B2.ranks
    local Nw = Dc(ranks) > 0
    local Nx = tonumber(B2.maxIncome) or 0
    local Ny = {}
    for i, v in ipairs(lX) do
        local Nx_1 = type(v) == "table" and type(v.Uid) == "string"
        if Nx_1 then
            if v.Carried == true then
                NA_1 = B2.includeBanked
            else
                local Nx_3 = v.Hired == true
                if not Nx_3 then
                    Nx_3 = B2.includeUntrained and v.Trained ~= true
                end
                NA_1 = Nx_3
            end
            local Nx_4 = NA_1 and Nw and ranks[tostring(v.Rank)] ~= true
            if Nx_4 then
                NA_1 = false
            end
            local Nx_5 = NA_1 and Nx > 0
            if Nx_5 then
                local NB_2 = tonumber(v.Income) or 0
                Nx_5 = NB_2 > Nx
            end
            if Nx_5 then
                NA_1 = false
            end
            if NA_1 then
                Ny[#Ny + 1] = v
            end
        end
    end
    return Ny
end
function fns.fn971(dQ, dR)
    local G1 = dR or {}
    for i, v in ipairs(G1) do
        local G0_1 = dQ - v.center
        local G1_1 = math.abs(G0_1.X) <= v.size.X * 0.5 and math.abs(G0_1.Y) <= v.size.Y * 0.5 and math.abs(G0_1.Z) <= v.size.Z * 0.5
        if G1_1 then
            return true
        end
    end
    return false
end
function fns.fn994(m9)
    CI.otherPlots = m9 == true
    if m9 then
        CG()
    end
end
function fns.fn1007(a2)
    local EG = os.clock()
    if Dy.value and EG - Dy.at < (a2 or 2) then
        return Dy.value
    end
    local EH_1 = Ci("GetProfile")
    if type(EH_1) == "table" then
        Dy.value = EH_1
        Dy.at = EG
    end
    return Dy.value
end
function fns.fn1011(fO)
    local Jl = tostring(fO.Name):gsub("[^%w%s%p]", "")
    local Jm = Jl:match("^%s*(.-)%s*$") or Jl
    if Jm == "" then
        return "employee"
    end
    return Jm
end
function fns.fn1017()
    local Ih = {}
    for i, v in ipairs(BZ()) do
        for i, child in ipairs(v:GetChildren()) do
            local Ii_1 = child:IsA("Model") and child:GetAttribute("EmployeeId")
            if Ii_1 then
                Ih[#Ih + 1] = child
            end
        end
    end
    for i, child in ipairs(Dv:GetChildren()) do
        local Ii_2 = child:IsA("Model") and child:GetAttribute("EmployeeId")
        if Ii_2 then
            Ih[#Ih + 1] = child
        end
    end
    return Ih
end
function fns.fn1044(np)
    if np then
        C8(Cy, Cq)
    else
        B9(Cy)
        State.HireStatus = "Idle"
    end
end
function fns.fn1056()
    local L4_1
    local L3_2
    local L_ = C3("Trails")
    local L0 = not L_ or type(L_.LIST) ~= "table"
    if L0 then
        State.ProgressStatus = "Trail catalog missing"
        return
    end
    local L0_1 = Dq()
    if not L0_1 then
        return
    end
    local L1 = {}
    if type(L0_1.TrailsOwned) == "table" then
        for k, v in pairs(L0_1.TrailsOwned) do
            if v == true or v == 1 then
                L1[tostring(k)] = true
            elseif type(v) == "string" then
                L1[v] = true
            end
        end
    end
    local L2_2 = C4()
    L4_1, L3_2 = nil, nil
    for i, v in ipairs(L_.LIST) do
        local L__1 = tostring(v.id)
        local L5_1 = tonumber(v.mult) or 0
        local L5_2 = tonumber(v.price) or math.huge
        if L1[L__1] then
            local L__2 = not L4_1
            if not L__2 then
                local L5_3 = (tonumber(L4_1.mult))
                local Mh_1 = if L5_3 then 1 else 0
                local Mf_1 = 2148 * Mh_1 + 3494 * (1 - Mh_1)
                local Mg_1 = 2944 * Mh_1 + 1677 * (1 - Mh_1)
                if not ((Mf_1 * 1580 + Mg_1 * 617 + Mf_1 * Mg_1) % 16777213 == 11534000) then
                    L5_3 = 0
                end
                L__2 = L5_1 > L5_3
            end
            if L__2 then
                L4_1 = v
            end
        elseif L5_2 <= L2_2 then
            local L__3 = not L3_2
            if not L__3 then
                local L5_4 = tonumber(L3_2.mult) or 0
                L__3 = L5_1 > L5_4
            end
            if L__3 then
                L3_2 = v
            end
        end
    end
    local L__4 = L3_2
    if L__4 then
        local L1_1 = not L4_1
        if not L1_1 then
            local L2_3 = tonumber(L3_2.mult) or 0
            local L5_5 = tonumber(L4_1.mult) or 0
            L1_1 = L2_3 > L5_5
        end
        L__4 = L1_1
    end
    if L__4 then
        local Mh_2 = if not Dm() then 1 else 0
        if Mh_2 == 1 then
            return
        end
        local L__5 = BE()
        if L__5 then
            BF(L__5, B1)
        end
        CU("RequestTrailBuy", L3_2.id)
        task.wait(0.8)
        CU("RequestTrailEquip", L3_2.id)
        Df()
        local L__6 = L3_2.name
        local Mh_3 = if L__6 then 1 else 0
        local Mf_2 = 261 * Mh_3 + 1201 * (1 - Mh_3)
        local Mg_2 = 2865 * Mh_3 + 3375 * (1 - Mh_3)
        if not ((Mf_2 * 3971 + Mg_2 * 297 + Mf_2 * Mg_2) % 16777213 == 2635101) then
            L__6 = L3_2.id
        end
        State.ProgressStatus = "Bought trail " .. tostring(L__6)
        CV()
        return
    end
    local L__7 = L4_1
    if L__7 then
        local L1_2 = L0_1.EquippedTrail or ""
        L__7 = tostring(L1_2) ~= tostring(L4_1.id)
    end
    if L__7 then
        CU("RequestTrailEquip", L4_1.id)
        local L__8 = L4_1.name or L4_1.id
        State.ProgressStatus = "Equipped trail " .. tostring(L__8)
        CV()
        return
    end
    State.ProgressStatus = "Trail up to date"
end
function fns.fn1061()
    local MB_1
    local Mw_1
    local Mr = C3("Cars")
    local Ms = not Mr or type(Mr.LIST) ~= "table"
    if Ms then
        State.ProgressStatus = "Car catalog missing"
        return
    end
    local Ms_1 = Dq()
    if not Ms_1 then
        return
    end
    local Mt = tonumber(Ms_1.OfficeLevel) or 1
    local Mt_1 = tonumber(Mr.UNLOCK_LEVEL) or 2
    local Mv_1
    if Mt < Mt_1 then
        State.ProgressStatus = string.format("Cars need office %d", Mt_1)
        return
    end
    local Mt_2 = 1
    if B_(Mr.DrivewaysForLevel) then
        Mv_1, Mw_1 = pcall(Mr.DrivewaysForLevel, Mt)
        local Mu_1 = Mv_1 and tonumber(Mw_1)
        if Mu_1 then
            Mt_2 = math.max(1, math.floor(tonumber(Mw_1)))
        end
    end
    local Mu_2 = {}
    if type(Ms_1.CarsOwned) == "table" then
        for k, v in pairs(Ms_1.CarsOwned) do
            if v == true or v == 1 then
                Mu_2[tostring(k)] = true
            elseif type(v) == "string" then
                Mu_2[v] = true
            end
        end
    end
    local Mv_3 = {}
    for i, v in ipairs(Mr.LIST) do
        Mv_3[#Mv_3 + 1] = v
    end
    table.sort(Mv_3, function(lg, lh)
        local Mo = tonumber(lg.boost) or 0
        local Mp = tonumber(lh.boost) or 0
        return Mo > Mp
    end)
    local Mw_3 = C4()
    for i, v in ipairs(Mv_3) do
        local Mx_1 = tostring(v.id)
        local My = tonumber(v.price) or math.huge
        local My_1
        local Mz = true
        if B_(Mr.IsAvailable) then
            My_1, MB_1 = pcall(Mr.IsAvailable, Mx_1)
            if My_1 and MB_1 == false then
                Mz = false
            end
        end
        if Mz and not Mu_2[Mx_1] and My <= Mw_3 then
            if not Dm() then
                return
            end
            local My_3 = C1()
            if My_3 then
                BF(My_3, B1)
            end
            CU("RequestCarBuy", Mx_1)
            Df()
            local My_4 = v.name or Mx_1
            State.ProgressStatus = "Bought car " .. tostring(My_4)
            CV()
            task.wait(1)
            return
        end
    end
    local Mx_2 = {}
    if type(Ms_1.DrivewayCars) == "table" then
        for k, v in pairs(Ms_1.DrivewayCars) do
            Mx_2[tostring(v)] = true
            local Mr_1 = tonumber(k) or 0
            Mx_2[Mr_1] = tostring(v)
        end
    end
    local Mr_2 = {}
    for i, v in ipairs(Mv_3) do
        if Mu_2[tostring(v.id)] then
            Mr_2[#Mr_2 + 1] = v
        end
    end
    local Ms_2 = false
    local Na = 1
    local M8 = Mt_2
    while Na <= M8 do
        local Nb = Na
        local Mt_3 = Mr_2[Nb]
        if Mt_3 then
            local Mu_3 = Mx_2[Nb]
            if Mu_3 ~= tostring(Mt_3.id) then
                CU("RequestCarPark", Mt_3.id, Nb)
                Ms_2 = true
                task.wait(0.5)
            end
        end
        Na += 1
    end
    if Ms_2 then
        State.ProgressStatus = "Parked best cars"
        CV()
    else
        State.ProgressStatus = "Cars up to date"
    end
end
function fns.fn1070()
    if BJ then
        return BJ
    end
    local Hr = C3("Zones")
    local Max
    local Hs = Hr
    local Min
    local Ht = {}
    if Hs then
        Hs = type(Hr.List) == "table"
    end
    if Hs then
        for i, v in ipairs(Hr.List) do
            local Hr_1 = type(v) == "table" and type(v.Id) == "string"
            if Hr_1 then
                Min, Max = v.Min, v.Max
                local Hu
                local Hv = typeof(Min) == "Vector2" and typeof(Max) == "Vector2"
                if Hv then
                    Hu = Vector2.new((Min.X + Max.X) * 0.5, (Min.Y + Max.Y) * 0.5)
                end
                local Hv_1 = #Ht + 1
                local Id = v.Id
                local Hx = tonumber(v.Level) or #Ht + 1
                local Hy = v.DisplayName or v.Id
                Ht[Hv_1] = { id = Id, level = Hx, name = tostring(Hy), min = Min, max = Max, center = Hu }
            end
        end
    end
    table.sort(Ht, function(er, es)
        return er.level < es.level
    end)
    BJ = Ht
    return Ht
end
function fns.fn1076(gZ, g_)
    local JP = {}
    if type(gZ) == "table" then
        for k, v in pairs(gZ) do
            local JQ
            local JR = v == true and type(k) == "string"
            if JR then
                JQ = k
            elseif type(v) == "string" then
                JQ = v
            end
            if JQ then
                local JR_1 = g_ and g_(JQ)
                local JS = JR_1
                local J1 = if JS then 1 else 0
                local J_ = 3669 * J1 + 1193 * (1 - J1)
                local J0 = 1275 * J1 + 3859 * (1 - J1)
                if not ((J_ * 1062 + J0 * 2739 + J_ * J0) % 16777213 == 12066678) then
                    JS = JQ
                end
                JP[JS] = true
            end
        end
    end
    return JP
end
function fns.fn1093()
    CZ(false)
end
function fns.fn1094()
    local FW = {}
    for i, v in ipairs(Dw()) do
        if v.Occupant == nil then
            FW[#FW + 1] = v
        end
    end
    return FW
end
function fns.fn1095(fj)
    if not B_(fireproximityprompt) then
        return false
    end
    local HoldDuration = fj.HoldDuration
    local IH_1 = HoldDuration > 0 and HoldDuration or nil
    local II_1 = pcall(fireproximityprompt, fj, IH_1) or pcall(fireproximityprompt, fj)
    return II_1
end
local function fn1120()
    local EU = T5_2()
    local EV = EU and EU:FindFirstChild("HumanoidRootPart")
    local EU_1 = EV
    if EV then
        EV = EU_1:IsA("BasePart")
    end
    if EV then
        return EU_1
    end
    return nil
end
local function fn1132()
    local O8 = Dw()
    if #O8 == 0 then
        Dh("Office not found")
        return false
    end
    return BF(O8[1].Position + Vector3.new(0, 4, 3))
end
local function fn1163(m_)
    local Op = tonumber(m_) or 0
    CI.interval = math.max(Op, 0)
end
local function fn1165()
    local EO = Ci("GetSellList")
    if type(EO) == "table" then
        return EO
    end
    return {}
end
local function onOnClientEvent(hc)
    if type(hc) == "string" then
        CT.message = hc
        CT.at = os.clock()
    end
end
local function fn1180(oE)
    if oE then
        C8(BK, CP)
    else
        B9(BK)
    end
end
local function fn1249()
    local N1 = tonumber(LocalPlayer:GetAttribute("IndexPending")) or 0
    if N1 <= 0 then
        State.RewardStatus = "No index rewards"
        return
    end
    CU("RequestIndexClaimAll")
    State.RewardStatus = string.format("Claimed %d index rewards", N1)
    CV()
end
local function fn1267()
    if LocalPlayer:GetAttribute("OnSprintTrack") == true then
        local format = string.format
        local Nf = tonumber(LocalPlayer:GetAttribute("Speed")) or 0
        State.SprintStatus = format("Running - speed %d", math.floor(Nf))
        return
    end
    local Nd_2 = Cm()
    if not Nd_2 then
        State.SprintStatus = "Track not found"
        return
    end
    if not Dm() then
        return
    end
    State.SprintStatus = "Moving to track"
    BF(Nd_2, B1)
    Df()
    if LocalPlayer:GetAttribute("OnSprintTrack") == true then
        State.SprintStatus = "Running"
    else
        State.SprintStatus = "Waiting for track"
    end
end
local function fn1269()
    local Lv = C3("SprintTrackCatalog")
    local Lw = Lv and Lv.LEVELS
    if type(Lw) ~= "table" then
        State.ProgressStatus = "Track catalog missing"
        return
    end
    local Lw_1 = Dq()
    local Lx = Lw_1 and tonumber(Lw_1.TrackLevel)
    local Lw_3 = Lw[(Lx or 1) + 1]
    if not Lw_3 then
        State.ProgressStatus = "Track maxed"
        return
    end
    local Lv_2 = tonumber(Lw_3.cost) or 0
    if C4() < Lv_2 then
        State.ProgressStatus = string.format("Track %s needs %d", tostring(Lw_3.name), Lv_2)
        return
    end
    CU("RequestTrackUpgrade")
    State.ProgressStatus = "Upgraded track"
    CV()
    task.wait(1)
end
local function fn1289(ou)
    if ou then
        C8(BV, B3)
    else
        B9(BV)
    end
end
local function fn1322(b7, b8)
    local Fu = os.clock() + b8
    while true do
        local Fv = BL() and os.clock() < Fu
        if Fv then
            if b7() then
                return true
            end
            task.wait(0.05)
            continue
        end
        break
    end
    return false
end
local function fn1349()
    local Ie = {}
    local Employees = Dv:FindFirstChild("Employees")
    if Employees then
        Ie[1] = Employees
    end
    return Ie
end
local function fn1358()
    Ds = false
end
local function fn1371()
    local GH = CK()
    local GI = GH and GH:FindFirstChild("PlotSpawn", true)
    local GJ = GI
    if GI then
        GI = GJ:IsA("BasePart")
    end
    if GI then
        return GJ.Position + Vector3.new(0, 4, 0)
    elseif GH then
        return GH:GetPivot().Position + Vector3.new(0, 6, 0)
    else
        return nil
    end
end
local function fn1375()
    local FN = BY()
    local FO = {}
    if not FN then
        return FO
    end
    for i, child in ipairs(FN:GetChildren()) do
        local Seat = child:FindFirstChildWhichIsA("Seat", true)
        if Seat then
            FO[#FO + 1] = Seat
        end
    end
    return FO
end
local function fn1379()
    local IN = {}
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if Backpack then
        for i, child in ipairs(Backpack:GetChildren()) do
            local IO_1 = child:IsA("Tool") and child:GetAttribute("CarrySlot") == true
            if IO_1 then
                IN[#IN + 1] = child
            end
        end
    end
    local IO_2 = T5_2()
    if IO_2 then
        for i, child in ipairs(IO_2:GetChildren()) do
            local IO_3 = child:IsA("Tool") and child:GetAttribute("CarrySlot") == true
            if IO_3 then
                IN[#IN + 1] = child
            end
        end
    end
    return IN
end
local function fn1391()
    local Of = Cw()
    if not Of then
        Dh("Nothing in hand")
        return false
    end
    local Og = BO(Of)
    Dh("Carrying " .. Og .. " to base")
    Dz()
    if Da(Of) then
        Dh("Banked " .. Og)
        return true
    end
    Dh("Could not stow " .. Og)
    return false
end
local function fn1405(mL)
    if mL then
        table.clear(CI.failures)
        table.clear(CI.cooldowns)
        CG()
        CW()
        C8(CI, CH)
    else
        B9(CI)
        Dh("Idle")
        task.spawn(function()
            local Ol = Cw()
            if Ol then
                Dz()
                Da(Ol)
            end
        end)
    end
end
local function fn1428()
    local Lg = CM()
    local Lh = 0
    local Li = 0
    for i, v in ipairs(Lg) do
        local Lg_1 = type(v) == "table" and v.Hired ~= true and v.Carried ~= true and type(v.Uid) == "string"
        if Lg_1 then
            local Lg_2 = tonumber(v.TrainingEndsAt)
            local Lj = v.Trained == true
            if not Lj then
                local Lk = Lg_2 ~= nil and Lg_2 <= Cx()
                Lj = Lk
            end
            if Lj then
                CU("RequestEmployeeHire", v.Uid)
                Lh += 1
                task.wait(0.2)
            else
                Li += 1
            end
        end
    end
    if Lh > 0 then
        State.Hired = State.Hired + Lh
        State.HireStatus = string.format("Hired %d", Lh)
        CV()
    elseif Li > 0 then
        State.HireStatus = string.format("%d still training", Li)
    else
        State.HireStatus = "Nothing to hire"
    end
end
local function fn1435(oc)
    local ON = tonumber(oc) or 0
    B2.keepCount = math.max(0, math.floor(ON))
end
local function fn1449(nv)
    if nv then
        C8(Cr, CC)
    else
        B9(Cr)
    end
end
local function fn1454()
    return not Ch.Unloaded
end
local function fn1457()
    local Pa = Cm()
    if not Pa then
        Dh("Track not found")
        return false
    end
    return BF(Pa)
end
local function fn1469()
    return #BD()
end
local function fn1480(m7)
    CI.respectDesks = m7 == true
end
local function fn1485(pw)
    local Pq = Cl(T5_5(pw))
    local Pr = Ct(Pq)
    if not Pr then
        Dh("Zone not found")
        return false
    end
    local Ps = BF(Pr)
    if not Ps then
        local Pq_1 = Pq and Pq.name
        local Pw = if Pq_1 then 1 else 0
        local Pu = 879 * Pw + 3686 * (1 - Pw)
        local Pv = 755 * Pw + 2661 * (1 - Pw)
        if not ((Pu * 192 + Pv * 1916 + Pu * Pv) % 16777213 == 2278993) then
            Pq_1 = pw
        end
        Dh("Blocked before " .. tostring(Pq_1))
    end
    return Ps
end
local function fn1486(aE)
    local Eu = Cc()
    local Ev = Eu and Eu:FindFirstChild(aE)
    local Eu_1 = Ev
    if Ev then
        Ev = Eu_1:IsA("RemoteFunction")
    end
    if Ev then
        return Eu_1
    end
    return nil
end
local function fn1506()
    local FK = CK()
    local FL = FK and FK:FindFirstChild("Office")
    if FL then
        return FL
    end
    return nil
end
local function fn1513(g7)
    local J2 = 0
    for k in pairs(g7) do
        J2 += 1
    end
    return J2
end
local function fn1516(nF)
    if nF then
        C8(Ck, Cn)
    else
        B9(Ck)
    end
end
local function fn1532()
    local attr = LocalPlayer:GetAttribute("PlotName")
    if type(attr) == "string" then
        return tonumber(attr:match("%d+"))
    end
    return nil
end
local function fn1534()
    local F3 = Dq()
    local F4 = F3 and type(F3.Employees) == "table"
    if F4 then
        return #F3.Employees
    end
    return 0
end
local function fn1542(oq)
    local OY = tonumber(oq) or 10
    B2.interval = math.clamp(OY, 1, 120)
end
local function fn1546()
    local Ph = Cv()
    if not Ph then
        Dh("Broker not found")
        return false
    end
    return BF(Ph)
end
local function fn1556()
    local ER_1
    local EQ_1
    EQ_1, ER_1 = pcall(function()
        return Dv:GetServerTimeNow()
    end)
    local ES = EQ_1 and type(ER_1) == "number"
    if ES then
        return ER_1
    end
    return os.time()
end
Bz = nil
BA = nil
BB = nil
BD = nil
BE = nil
BF = nil
BG = nil
BH = nil
BJ = nil
BK = nil
BL = nil
BO = nil
BQ = nil
BR = nil
BV = nil
BX = nil
BY = nil
BZ = nil
B_ = nil
B0 = nil
B1 = nil
B2 = nil
B3 = nil
T5_2 = nil
B6 = nil
B7 = nil
B9 = nil
T5_8 = nil
Cc = nil
Cg = nil
Ch = nil
Ci = nil
Ck = nil
local Players, BC, BI, BM, BN, BP, BS, BT, BU, BW, B4, B8, Ca, Cd, Ce, Cf, Cj
Cl = nil
Cm = nil
Cn = nil
Co = nil
Cq = nil
Cr = nil
Cs = nil
Ct = nil
T5_7 = nil
Cv = nil
Cw = nil
Cx = nil
Cy = nil
Cz = nil
connection = nil
CB = nil
CC = nil
CD = nil
CG = nil
CH = nil
CI = nil
LocalPlayer = nil
CK = nil
CL = nil
CM = nil
CP = nil
CS = nil
CT = nil
CU = nil
CV = nil
CW = nil
CZ = nil
C_ = nil
CoreGui = nil
C1 = nil
C3 = nil
C4 = nil
C5 = nil
local Cp, CE, CF, CN, Workspace, CQ, Lighting, TeleportService, CY, C2, C6, GuiService
C8 = nil
C9 = nil
Da = nil
Dc = nil
Dd = nil
Df = nil
Dh = nil
Di = nil
Dj = nil
Dm = nil
State = nil
Dq = nil
Dr = nil
Ds = nil
Dt = nil
T5_5 = nil
Dv = nil
Dw = nil
Dy = nil
Dz = nil
DA = nil
local HttpService, VirtualUser, UserInputService, Dk, RunService, Do, Dp, Dx
HttpService = nil
VirtualUser = nil
UserInputService = nil
Dk = nil
RunService = nil
Do = nil
Dp = nil
Dx = nil
if not game:IsLoaded() then
    game.Loaded:Wait()
end
Players, RunService, UserInputService, VirtualUser, HttpService, GuiService, CoreGui, TeleportService, Lighting, Workspace, LocalPlayer, Cz = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
GuiService = game:GetService("GuiService")
CoreGui = game:GetService("CoreGui")
TeleportService = game:GetService("TeleportService")
Lighting = game:GetService("Lighting")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
local T5_1 = "TempoStealAnEmployee"
Cz = fns.fn413
if getgenv then
    getgenv().gethui = Cz
end
Ch, BB, Dv, State, C9, Dy, C6, B1, BU, BP, BI, CB, CN, C_, BJ, CI, CD, Cy, Cr, Co, Ck, Cg, Ca, B6, B2, BV, BQ, BK, BH, Bz, Ds, CT, CQ, B_, BL, Dh, C3, Cc, B4, Do, CU, Ci, Dq, CV, CM, Cx, T5_2, BS, Dk, CZ, BF, B8, BA, CS, CK, T5_8, BY, Dw, CY, T5_7, Ce, Dx, C5, Cm, Dd, CG, DA, CW, Cj, BG, Cl, BW, T5_5, C2, Ct, BZ, BC, CE, Cd, BM, BD, CF, Cw, BO, Dz, Da, BT, Dm, Df, C8, B9, BX, Dc = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
pcall(fns.fn645)
local function T5_16(t)
    local D8
    local D6
    local D7
    D6 = nil
    D7 = nil
    D8 = nil
    local D9 = t ~= ""
    local Ea = type(t) == "string" and D9
    assert(Ea, "A namespace is required")
    assert(type(getgenv) == "function", "getgenv is unavailable")
    D6 = getgenv()
    assert(type(D6) == "table", "getgenv did not return a table")
    local D9_1 = D6[t]
    if D9_1 ~= nil then
        local Ea_1 = type(D9_1) == "table" and type(D9_1.Unload) == "function"
        assert(Ea_1, "Namespace is occupied")
        D9_1.Unload()
        assert(D6[t] == nil, "Previous instance did not release its namespace")
    end
    D7 = {}
    D8 = { State = {}, Unloaded = false }
    D8.Track = function(B)
        assert(type(B) == "function", "Cleanup must be callable")
        if D8.Unloaded then
            B()
        else
            table.insert(D7, B)
        end
        return B
    end
    D8.Unload = function()
        local DX_1
        local DW_1
        if D8.Unloaded then
            return
        end
        D8.Unloaded = true
        local DU = {}
        local D0 = #D7
        local D_ = -1
        while false and D0 <= 1 or true and D0 >= 1 do
            local D1 = D0
            local DV_1 = table.remove(D7, D1)
            DW_1, DX_1 = pcall(DV_1)
            if not DW_1 then
                table.insert(DU, tostring(DX_1))
            end
            D0 += D_
        end
        table.clear(D8.State)
        if #DU > 0 then
            error("Cleanup incomplete: " .. table.concat(DU, "; "), 0)
        end
        if D6[t] == D8 then
            D6[t] = nil
        end
    end
    D6[t] = D8
    return D8
end
CQ = function(O, P)
    local Ed = type(O) == "table" and type(O.Track) == "function"
    assert(Ed, "FeatureAPI required")
    local Ed_1 = type(P) == "table" and type(P.OnUnload) == "function"
    assert(Ed_1, "UI library required")
    assert(type(P.Unload) == "function", "UI unload required")
    O.Track(function()
        if not P.Unloaded then
            P:Unload()
        end
    end)
    P:OnUnload(function()
        O.Unload()
    end)
end
Ch = T5_16(T5_1)
local T5_14 = fns.fn438
B_ = fns.fn544
BL = fn1454
BB = T5_14(ReplicatedStorage)
Dv = T5_14(Workspace)
State = Ch.State
State.Status = "Idle"
State.PlaceStatus = "Idle"
State.HireStatus = "Idle"
State.ProgressStatus = "Idle"
State.SprintStatus = "Idle"
State.ManageStatus = "Idle"
State.RewardStatus = "Idle"
State.Stolen = 0
State.Placed = 0
State.Hired = 0
State.Sold = 0
Dh = fns.fn735
C9 = {}
C3 = fns.fn868
Cc = fns.fn538
B4 = fns.fn201
Do = fn1486
CU = function(aL, ...)
    local Ey
    local Ex
    Ex = nil
    Ey = nil
    Ey = B4(aL)
    if not Ey then
        return false
    end
    Ex = table.pack(...)
    local Ez = pcall(function()
        Ey:FireServer(table.unpack(Ex, 1, Ex.n))
    end)
    return Ez
end
Ci = function(aT, ...)
    local EB
    local EC
    EB = nil
    EC = nil
    local EE_1
    local ED_1
    EB = Do(aT)
    if not EB then
        return nil
    end
    EC = table.pack(...)
    ED_1, EE_1 = pcall(function()
        return EB:InvokeServer(table.unpack(EC, 1, EC.n))
    end)
    if ED_1 then
        return EE_1
    end
    return nil
end
if Cj and not Cj and (not B8 or B8) or not B8 and not Cj and (not Cj and not Cj) or not (Cj and not Cj and (not B8 or B8) or not B8 and not Cj and (not Cj and not Cj)) then
    Dy = { value = nil, at = 0 }
    Dq = fns.fn1007
    CV = fns.fn101
    CM = fn1165
else
    CV = { value = nil, at = 0 }
    Dy = fns.fn1007
    CM = fns.fn101
    Dq = fn1165
end
Cx = fn1556
T5_2 = fns.fn444
if (Dm or not Dm) and (not Dm or T5_2) or not Dm and Dm and (T5_2 and not Dm) or not ((Dm or not Dm) and (not Dm or T5_2) or not Dm and Dm and (T5_2 and not Dm)) then
    BS = fn1120
else
    Cw = fn1120
end
Dk = fns.fn107
C6 = {}
CZ = function(bx)
    local E2 = T5_2()
    if not E2 then
        return
    end
    if bx then
        for i, descendant in ipairs(E2:GetDescendants()) do
            local E2_1 = descendant:IsA("BasePart") and descendant.CanCollide
            if E2_1 then
                if C6[descendant] == nil then
                    C6[descendant] = true
                end
                descendant.CanCollide = false
            end
        end
        return
    end
    for k, v in pairs(C6) do
        local Fg = k
        local Fi = v
        if Fg.Parent then
            pcall(function()
                Fg.CanCollide = Fi
            end)
        end
        C6[Fg] = nil
    end
end
if (CI or not T5_8) and (not Dv or false) and ((Dv or BI) and (T5_8 and not Cd)) and not ((CI or not T5_8) and (not Dv or false) and ((Dv or BI) and (T5_8 and not Cd))) then
    B1.Track(fns.fn1093)
    BU = 0.5
    Ch = 14
else
    Ch.Track(fns.fn1093)
    B1 = 0.5
    BU = 14
end
BP = 0.12
BI = 4.5
BF = function(bO, bP)
    if typeof(bO) ~= "Vector3" then
        return false
    end
    local Fk = CFrame.new(bO)
    local Fl = 0
    local Fm = math.huge
    for i = 1, BU do
        local Fj
        if not BL() then
            break
        else
            local Fn = BS()
            if not Fn then
                task.wait(0.25)
            else
                local Magnitude = (bO - Fn.Position).Magnitude
                if Magnitude < BI then
                    break
                elseif Magnitude < Fm - 3 then
                    Fm = Magnitude
                    Fl = 0
                    CZ(true)
                    Fj = Dk()
                    if Fj then
                        pcall(function()
                            Fj:ChangeState(Enum.HumanoidStateType.Freefall)
                        end)
                    end
                    Fn.CFrame = Fk
                    Fn.AssemblyLinearVelocity = Vector3.zero
                    task.wait(BP)
                else
                    Fl += 1
                    if Fl >= 3 then
                        break
                    end
                    CZ(true)
                    Fj = Dk()
                    if Fj then
                        pcall(function()
                            Fj:ChangeState(Enum.HumanoidStateType.Freefall)
                        end)
                    end
                    Fn.CFrame = Fk
                    Fn.AssemblyLinearVelocity = Vector3.zero
                    task.wait(BP)
                end
            end
        end
    end
    CZ(false)
    if bP then
        task.wait(bP)
    end
    local Fk_1 = BS()
    return Fk_1 ~= nil and (Fk_1.Position - bO).Magnitude < 12
end
if ((CG or false) and (not Co and Ci) and (false or Ci or CS and Ci) and (Cd or CS or Co and Cd or Cd and false and (false and Do)) or (false and not Cd and false or Ci and Ci and (false and not CS)) and ((not Co or false or Do and Cd) and ((CG or Do) and (not Co or Cd)))) and not ((CG or false) and (not Co and Ci) and (false or Ci or CS and Ci) and (Cd or CS or Co and Cd or Cd and false and (false and Do)) or (false and not Cd and false or Ci and Ci and (false and not CS)) and ((not Co or false or Do and Cd) and ((CG or Do) and (not Co or Cd)))) then
    BA = fn1322
    B8 = fns.fn370
else
    B8 = fn1322
    BA = fns.fn370
end
CS = fns.fn170
CK = fns.fn552
T5_8 = fn1532
BY = fn1506
Dw = fn1375
CY = fns.fn1094
CB = 0
T5_7 = fn1534
Ce = fns.fn309
Dx = fns.fn238
C5 = fns.fn760
Cm = fns.fn17
Dd = fn1371
CN = nil
CG = function()
    local GS_1
    local GR_1
    local GO = CS()
    local GO_2
    local GP = CK()
    local GQ = {}
    if GO then
        for i, child in ipairs(GO:GetChildren()) do
            local G_ = child
            local GO_1 = G_ ~= GP and G_:IsA("Model") and G_.Name:match("^Plot%d+$")
            if GO_1 then
                GO_2, GS_1, GR_1 = pcall(function()
                    return G_:GetBoundingBox()
                end)
                if GO_2 and GS_1 then
                    GQ[#GQ + 1] = { center = GS_1.Position, size = GR_1 }
                end
            end
        end
    end
    CN = GQ
    return GQ
end
if (CM or false) and (CM and Da) and (not CM and not C9 or (not CM or C9)) and (Da and Da or (CM or not CM) or (Da and C9 or (false or C9))) or not ((CM or false) and (CM and Da) and (not CM and not C9 or (not CM or C9)) and (Da and Da or (CM or not CM) or (Da and C9 or (false or C9)))) then
    DA = fns.fn971
    C_ = nil
    CW = function()
        local G9
        G9 = nil
        local Hc_2
        local Hb_2
        local Ha_2
        G9 = CK()
        if not G9 then
            C_ = nil
            return nil
        end
        Ha_2, Hb_2, Hc_2 = pcall(function()
            return G9:GetBoundingBox()
        end)
        if Ha_2 and Hb_2 then
            C_ = { { center = Hb_2.Position, size = Hc_2 } }
        else
            C_ = nil
        end
        return C_
    end
    Cj = fns.fn436
    BJ = nil
else
    BJ = fns.fn971
    CW = nil
    C_ = function()
        local G9
        G9 = nil
        local Hc_1
        local Hb_1
        local Ha_1
        G9 = CK()
        if not G9 then
            C_ = nil
            return nil
        end
        Ha_1, Hb_1, Hc_1 = pcall(function()
            return G9:GetBoundingBox()
        end)
        if Ha_1 and Hb_1 then
            C_ = { { center = Hb_1.Position, size = Hc_1 } }
        else
            C_ = nil
        end
        return C_
    end
    DA = fns.fn436
    Cj = nil
end
BG = fns.fn1070
Cl = fns.fn235
BW = fns.fn439
T5_5 = fns.fn774
C2 = fns.fn708
Ct = fns.fn179
BZ = fn1349
BC = fns.fn1017
CE = fns.fn85
Cd = fns.fn1095
BM = fns.fn803
BD = fn1379
CF = fn1469
Cw = fns.fn804
BO = fns.fn1011
Dz = fns.fn798
Da = function(fW)
    local Jt = fW or Cw()
    fW = Jt
    if not fW or not fW.Parent then
        return true
    end
    local attr = fW:GetAttribute("CarryUid")
    if type(attr) == "string" then
        CU("RequestCarryHolster", true, attr)
    end
    local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local Jt_3 = Backpack and fW.Parent == T5_2()
    if Jt_3 then
        pcall(function()
            fW.Parent = Backpack
        end)
    end
    return B8(function()
        local Jq = fW.Parent == nil or fW:GetAttribute("Drawn") ~= true
        return Jq
    end, 2)
end
BT = function(gb)
    if not gb or not gb.Parent then
        return false
    end
    local attr = gb:GetAttribute("CarryUid")
    if type(attr) == "string" then
        CU("RequestCarryHolster", false, attr)
    end
    local JA = Dk()
    local JB_2 = JA and gb.Parent ~= T5_2()
    if JB_2 then
        pcall(function()
            JA:EquipTool(gb)
        end)
    end
    return B8(function()
        local Jy = gb:GetAttribute("Drawn") == true and gb.Parent == T5_2()
        return Jy
    end, 2)
end
CI = {
    interval = 0.35,
    zones = {},
    priority = true,
    respectDesks = true,
    otherPlots = false,
    cooldowns = {},
    failures = {}
}
CD = { interval = 0.6 }
Cy = { interval = 5 }
Cr = { interval = 12 }
Co = { interval = 12 }
Ck = { interval = 20 }
if ((C_ and not Cj or (not Dm or not CK)) and (CK and Dm and (C_ and CK)) and (Cj and Dm or (not Dm or not Dm) or (not C_ and not CK or (not Cj or Dm))) or (not Dm or CK) and (Cj and not C_) and (not CK or not Dm or not Cj and not Cj) and ((not C_ or not Cj) and (Dm and not CK) or (C_ and not Cj or (Dm or not Dm)))) and not ((C_ and not Cj or (not Dm or not CK)) and (CK and Dm and (C_ and CK)) and (Cj and Dm or (not Dm or not Dm) or (not C_ and not CK or (not Cj or Dm))) or (not Dm or CK) and (Cj and not C_) and (not CK or not Dm or not Cj and not Cj) and ((not C_ or not Cj) and (Dm and not CK) or (C_ and not Cj or (Dm or not Dm)))) then
    CY = { interval = 25 }
else
    Cg = { interval = 25 }
end
Ca = { interval = 3 }
B6 = { interval = 15 }
B2 = {
    interval = 10,
    keepCount = 0,
    ranks = {},
    maxIncome = 0,
    includeBanked = false,
    includeUntrained = false,
    batch = 10
}
BV = { interval = 12 }
BQ = { interval = 15 }
BK = { interval = 30 }
BH = { interval = 60 }
Bz = { CI, CD, Cy, Cr, Co, Ck, Cg, Ca, B6, B2, BV, BQ, BK, BH }
Ds = false
Dm = fns.fn710
Df = fn1358
C8 = function(gK, gL)
    local generation
    local JI = gK.generation or 0
    gK.generation = JI + 1
    gK.stopped = false
    generation = gK.generation
    task.spawn(function()
        local JF_1
        while true do
            local JE = BL() and not gK.stopped and gK.generation == generation
            local JE_1
            if JE then
                JE_1, JF_1 = pcall(gL)
                if not JE_1 then
                    warn("[Tempo] loop error: " .. tostring(JF_1))
                end
                local JE_2 = not BL() or gK.stopped or gK.generation ~= generation
                if JE_2 then
                    break
                end
                task.wait(gK.interval)
                continue
            end
            break
        end
    end)
end
B9 = fns.fn448
BX = fns.fn1076
Dc = fn1513
CT = { message = "", at = 0 }
local T5_12 = B4("StealRefused")
if T5_12 then
    connection = nil
    T5_14 = 6
    repeat
        T5_1 = (T5_14 * 1 + 1) % 2 + 1
        if T5_1 <= 1 then
            local We = bit32.rrotate(bit32.bxor(bit32.lrotate(T5_14, 3), string.byte(tostring(connection))), 4)
            if bit32.bxor(bit32.lrotate(bit32.bxor(We, 1059090946), 2), 4236363784) ~= bit32.lrotate(We, 2) then
                Ch.Track(fns.fn882)
            else
                Ch.Track(fns.fn882)
            end
            T5_14 = (T5_14 + 5) % 8
        else
            T5_1 = {
                "bncdmm",
                "zjlnbchxuqw",
                "ufyhvttpsm",
                "rovagycp",
                "rsww",
                "pqvaycy",
                "jos",
                "wepqsyppjx",
                "laktdqauw"
            }
            if T5_1[(T5_14 * 87 + 23) % 9 + 1] <= T5_1[(T5_14 * 87 + 23) % 9 + 1] then
                connection = T5_12.OnClientEvent:Connect(onOnClientEvent)
            else
                T5_12 = connection.OnClientEvent:Connect(onOnClientEvent)
            end
            T5_14 = (T5_14 + 5) % 8
        end
    until (T5_14 * 7 + 4) % 8 == 4
end
BR, Cp, Cf, CH, Cs, Cq, C4, CC, Di, BE, C1, Cn, Dt, Dp, CL, Cv, BN, Dj, B0, B3, Dr, CP, B7 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Cp = function(hh)
    local Kb
    local Kc = CY()
    if #Kc == 0 then
        State.PlaceStatus = "No free desk"
        return false
    elseif not BT(hh) then
        State.PlaceStatus = "Could not hold employee"
        return false
    else
        local Kd = BS()
        Kb = Kd and Kd.Position or Vector3.zero
        table.sort(Kc, function(hr, hs)
            return (hr.Position - Kb).Magnitude < (hs.Position - Kb).Magnitude
        end)
        for i, v in ipairs(Kc) do
            local Ko = v
            local Kc_1 = Dx(Ko)
            if Kc_1 then
                State.PlaceStatus = "Placing employee"
                BF(Ko.Position + Vector3.new(0, 3, 3), B1)
                local Kd_2 = Ko.Occupant == nil and BM()
                if Kd_2 then
                    Cd(Kc_1)
                    if B8(function()
                        return Ko.Occupant ~= nil or hh.Parent == nil
                    end, 2.5) then
                        State.Placed = State.Placed + 1
                        State.PlaceStatus = "Placed employee"
                        CV()
                        return true
                    end
                end
            end
        end
        State.PlaceStatus = "Place failed"
        return false
    end
end
Cf = function()
    local Kr
    local Ky_1
    local KD_1
    local Kx_1
    CW()
    local Ks = CI.otherPlots
    if Ks then
        local Kt_1 = CN or CG()
        Ks = Kt_1
    end
    local Kt_2 = Ks or nil
    local zones = CI.zones
    local Ku = Dc(zones) > 0
    local Kv = os.clock()
    local Kw = {}
    for i, v in ipairs(BC()) do
        Kx_1, Ky_1 = CE(v)
        if Kx_1 and Ky_1 and Kx_1.Enabled and Kx_1.ActionText == "Steal" then
            local Position = Ky_1.Position
            local KA = CI.cooldowns[v]
            local KB = not KA or KA < Kv
            local KA_1 = KB and not Cj(Position)
            if KA_1 then
                local KA_2 = C2(Position)
                local KB_1 = Kt_2 and DA(Position, Kt_2)
                local KC = KB_1 or false
                if KC then
                    KD_1 = CI.otherPlots
                elseif KA_2 then
                    KD_1 = not Ku or zones[KA_2.id] == true
                else
                    KD_1 = false
                end
                if KD_1 then
                    local KC_2 = #Kw + 1
                    local KA_3 = KA_2 and KA_2.level or 0
                    Kw[KC_2] = { model = v, prompt = Kx_1, root = Ky_1, position = Position, level = KA_3, plot = KC }
                end
            end
        end
    end
    local Kx_2 = BS()
    Kr = Kx_2 and Kx_2.Position or Vector3.zero
    table.sort(Kw, function(ii, ij)
        if CI.priority and ii.level ~= ij.level then
            return ii.level > ij.level
        end
        return (ii.position - Kr).Magnitude < (ij.position - Kr).Magnitude
    end)
    return Kw
end
CH = function()
    local K2_1
    local K1_1
    if not Dm() then
        return
    end
    K1_1, K2_1 = pcall(function()
        local KN
        local KO = Cw()
        if KO then
            Dh("Banking " .. BO(KO))
            Dz()
            Da(KO)
        end
        KN = CF()
        if CI.respectDesks then
            local KO_1 = Ce()
            if KO_1 and KO_1 - KN <= 0 then
                Dh("Desks full")
                return
            end
        end
        local KO_2 = Cf()
        if #KO_2 == 0 then
            Dh("No employees available")
            return
        end
        local KP_2 = KO_2[1]
        Dh(string.format("Stealing %s", KP_2.model.Name))
        BF(KP_2.position + Vector3.new(0, 0, 3), B1)
        if not KP_2.prompt.Parent or not KP_2.prompt.Enabled then
            CI.cooldowns[KP_2.model] = os.clock() + 15
            return
        end
        CT.message = ""
        Cd(KP_2.prompt)
        if B8(function()
            local KL = CF() > KN or Cw() ~= nil
            return KL
        end, 2.5) then
            CI.failures[KP_2.model] = nil
            State.Stolen = State.Stolen + 1
            CV()
            local KO_4 = Cw()
            if KO_4 then
                local KQ_1 = BO(KO_4)
                Dh("Carrying " .. KQ_1 .. " to base")
                if not Dz() then
                    Dh("Could not reach base with " .. KQ_1)
                end
                if Da(KO_4) then
                    Dh("Banked " .. KQ_1)
                else
                    Dh("Could not stow " .. KQ_1)
                end
            else
                Dh("Stole " .. KP_2.model.Name)
            end
        else
            local KO_5 = CI.failures[KP_2.model]
            local K0 = if KO_5 then 1 else 0
            local KZ = 1495 * K0 + 3840 * (1 - K0)
            local K_ = 1413 * K0 + 1100 * (1 - K0)
            if not ((KZ * 3506 + K_ * 2805 + KZ * K_) % 16777213 == 11317370) then
                KO_5 = 0
            end
            local KQ_2 = KO_5 + 1
            CI.failures[KP_2.model] = KQ_2
            local cooldowns = CI.cooldowns
            local model = KP_2.model
            local KS = os.clock()
            local KU = KQ_2 >= 3 and 300 or KQ_2 * 15
            cooldowns[model] = KS + KU
            local KO_7 = CT.message ~= "" and os.clock() - CT.at < 3
            if KO_7 then
                Dh(CT.message)
            else
                Dh("Could not take " .. KP_2.model.Name)
            end
        end
    end)
    Df()
    if not K1_1 then
        error(K2_1, 0)
    end
end
Cs = function()
    local Lc
    local Le_1
    local Ld_2
    Lc = BD()
    if #Lc == 0 then
        State.PlaceStatus = "Nothing carried"
        return
    end
    if not Dm() then
        return
    end
    if #Dw() == 0 then
        local Ld_1 = Dd()
        if Ld_1 then
            State.PlaceStatus = "Returning to office"
            BF(Ld_1, B1)
        end
    end
    Ld_2, Le_1 = pcall(function()
        for i, v in ipairs(Lc) do
            local K4 = not BL() or CD.stopped
            if K4 then
                break
            end
            local K4_1 = v.Parent == nil or #CY() == 0
            if K4_1 then
                break
            end
            Cp(v)
        end
    end)
    Df()
    if not Ld_2 then
        error(Le_1, 0)
    end
end
Cq = fn1428
C4 = fns.fn793
CC = fn1269
Di = fns.fn141
BE = fns.fn91
C1 = fns.fn102
Cn = fns.fn1056
Dt = fns.fn1061
Dp = fn1267
if ((CP or B0) and (CP and not Cn) or (not CC or CP or (BN or BR))) and not ((CP or B0) and (CP and not Cn) or (not CC or CP or (BN or BR))) then
    B7 = fns.fn313
else
    CL = fns.fn313
end
Cv = fns.fn350
BR = { "Rookie", "Skilled", "Pro", "Expert", "Elite", "Superstar" }
BN = fns.fn509
Dj = fns.fn941
B0 = fns.fn311
B3 = fn1249
Dr = fns.fn30
CP = fns.fn369
B7 = fns.fn912
Ch.BankHeldEmployee = fn1391
Ch.SetAutoSteal = fn1405
Ch.SetStealDelay = fn1163
Ch.SetStealZones = fns.fn733
Ch.SetStealPriority = fns.fn358
Ch.SetStealRespectDesks = fn1480
Ch.SetStealOtherPlots = fns.fn994
Ch.SetAutoPlace = fns.fn849
Ch.SetAutoHire = fns.fn1044
Ch.SetAutoTrack = fn1449
Ch.SetAutoOffice = fns.fn852
Ch.SetAutoTrail = fn1516
Ch.SetAutoCars = fns.fn647
Ch.SetAutoSprint = function(nP)
    if nP then
        C8(Ca, Dp)
    else
        B9(Ca)
        State.SprintStatus = "Idle"
        local OD = Dd()
        local OE = OD and LocalPlayer:GetAttribute("OnSprintTrack") == true
        if OE then
            task.spawn(function()
                BF(OD)
            end)
        end
    end
end
Ch.SetAutoEquipBest = fns.fn770
Ch.SetAutoSell = fns.fn98
Ch.SetSellKeep = fn1435
Ch.SetSellRanks = fns.fn674
Ch.SetSellMaxIncome = fns.fn138
Ch.SetSellIncludeBanked = fns.fn151
Ch.SetSellIncludeUntrained = fns.fn813
Ch.SetSellBatch = fns.fn304
Ch.SetSellDelay = fn1542
Ch.SetAutoIndex = fn1289
Ch.SetAutoSpin = fns.fn225
Ch.SetAutoDaily = fn1180
Ch.SetAutoGift = fns.fn827
Ch.TeleportToPlot = fns.fn440
Ch.TeleportToDesks = fn1132
Ch.TeleportToTrack = fn1457
Ch.TeleportToSafeZone = fns.fn20
Ch.TeleportToBroker = fn1546
Ch.TeleportToMachine = fns.fn256
Ch.TeleportToZone = fn1485
Ch.Track(fns.fn378)
T5_1 = function()
    local pP = "https://tempohub.shop"
    local pM = "v0.6"
    local pL = "Steal an Employee"
    local pN = "https://discord.gg/K7Qxnxkk46"
    local pO = "https://discord.gg/K7Qxnxkk46"
    local Library = getgenv().Library
    local ThemeManager = getgenv().ThemeManager
    local SaveManager = getgenv().SaveManager
    local Toggles = Library.Toggles
    local Options = Library.Options
    CQ(Ch, Library)
    local function pY(pZ, p_)
        local PF = B_(setclipboard) and setclipboard
        local PG = PF
        if not PG then
            local PF_1 = B_(toclipboard) and toclipboard
            local PH = PF_1
            local PL = if PH then 1 else 0
            local PJ = 3582 * PL + 1401 * (1 - PL)
            local PK = 3344 * PL + 2471 * (1 - PL)
            if not ((PJ * 3523 + PK * 1215 + PJ * PK) % 16777213 == 11883341) then
                PH = nil
            end
            PG = PH
        end
        local PF_2 = PG
        if not PF_2 then
            Library:Notify("Clipboard is unavailable")
            return
        end
        local PG_1 = pcall(PF_2, pZ)
        if PG_1 then
            Library:Notify(p_)
        else
            Library:Notify("Failed to copy")
        end
    end
    local function onDiscord()
        pY(pN, "Copied Discord invite to clipboard")
    end
    local Window = Library:CreateWindow({
        Title = "Tempo",
        Font = Enum.Font.BuilderSans,
        Footer = { { Text = pN, Copyable = true }, "|", pL, "|", pM },
        Icon = 78539693571783,
        NotifySide = "Right",
        ShowCustomCursor = false,
        CornerRadius = 0,
        SidebarCompacted = true,
        TabSwipeFrom = "bottom",
        Animations = { TabSwitch = true }
    })
    Window:SetGlow(false)
    local qc = {
        [1] = Window:AddTab("Info", "info"),
        [2] = Window:AddTab("Main", "gamepad-2"),
        [3] = Window:AddTab("Player", "person-standing"),
        [4] = Window:AddTab("Settings", "settings")
    }
    local qd = {
        [1] = qc[2]:AddSubTab("Employees", "users"),
        [2] = qc[2]:AddSubTab("Progression", "trending-up"),
        [3] = qc[2]:AddSubTab("Rewards", "gift"),
        [4] = qc[2]:AddSubTab("Teleports", "map-pin")
    }
    local function qe(qf)
        local DiscordGroup = qf:AddLeftGroupbox("Discord")
        DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = onDiscord })
        DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = onDiscord })
    end
    qe(qd[1])
    qe(qd[2])
    qe(qd[3])
    qe(qd[4])
    qe(qc[3])
    qe(qc[4])
    local qj = BW()
    local qk = {}
    local function ql()
        local PN
        PN = nil
        local EmployeeFarmingGroup = qd[1]:AddRightGroupbox("Employee Farming", "briefcase")
        qk[1] = EmployeeFarmingGroup:AddLabel(State.Status, true)
        EmployeeFarmingGroup:AddToggle("AutoSteal", {
            Text = "Auto Steal / Collect Employees",
            Default = false,
            Callback = function(qr)
                Ch.SetAutoSteal(qr)
            end
        })
        EmployeeFarmingGroup:AddDropdown("StealZones", {
            Text = "Zone Filter",
            Values = qj,
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = function(qv)
                Ch.SetStealZones(qv)
            end
        })
        EmployeeFarmingGroup:AddToggle("StealPriority", {
            Text = "Zone Priority Targeting (Zone 19 to 1)",
            Default = true,
            Callback = function(qx)
                Ch.SetStealPriority(qx)
            end
        })
        EmployeeFarmingGroup:AddToggle("StealRespectDesks", {
            Text = "Stop Stealing When Desks Full",
            Default = true,
            Callback = function(qz)
                Ch.SetStealRespectDesks(qz)
            end
        })
        EmployeeFarmingGroup:AddToggle("StealOtherPlots", {
            Text = "Steal From Other Players' Plots",
            Default = false,
            Callback = function(qB)
                Ch.SetStealOtherPlots(qB)
            end
        })
        EmployeeFarmingGroup:AddSlider("StealDelay", {
            Text = "Steal Delay",
            Default = 0.35,
            Min = 0,
            Max = 5,
            Rounding = 2,
            Suffix = "s",
            Callback = function(qD)
                Ch.SetStealDelay(qD)
            end
        })
        EmployeeFarmingGroup:AddButton({
            Text = "Bank Held Employee",
            Func = function()
                Ch.BankHeldEmployee()
            end
        })
        local OfficeGroup = qd[1]:AddRightGroupbox("Office", "layout-grid")
        qk[2] = OfficeGroup:AddLabel(State.PlaceStatus, true)
        OfficeGroup:AddToggle("AutoPlace", {
            Text = "Auto Place Carried Employees on Desks",
            Default = false,
            Callback = function(qH)
                Ch.SetAutoPlace(qH)
            end
        })
        qk[3] = OfficeGroup:AddLabel(State.HireStatus, true)
        OfficeGroup:AddToggle("AutoHire", {
            Text = "Auto Hire / Finish Training",
            Default = false,
            Callback = function(qJ)
                Ch.SetAutoHire(qJ)
            end
        })
        local EmployeeManagementGroup = qd[1]:AddLeftGroupbox("Employee Management", "users-round")
        qk[4] = EmployeeManagementGroup:AddLabel(State.ManageStatus, true)
        EmployeeManagementGroup:AddToggle("AutoEquipBest", {
            Text = "Auto Equip Best Employees",
            Default = false,
            Callback = function(qM)
                Ch.SetAutoEquipBest(qM)
            end
        })
        EmployeeManagementGroup:AddToggle("AutoSell", {
            Text = "Auto Sell Hired Employees",
            Default = false,
            Callback = function(qO)
                Ch.SetAutoSell(qO)
            end
        })
        EmployeeManagementGroup:AddDropdown("SellRanks", {
            Text = "Sell These Ranks",
            Values = BN(),
            Default = {},
            Multi = true,
            AllowNull = true,
            Callback = function(qS)
                Ch.SetSellRanks(qS)
            end
        })
        EmployeeManagementGroup:AddSlider("SellKeep", {
            Text = "Keep Top Earners",
            Default = 0,
            Min = 0,
            Max = 40,
            Rounding = 0,
            Callback = function(qU)
                Ch.SetSellKeep(qU)
            end
        })
        EmployeeManagementGroup:AddSlider("SellMaxIncome", {
            Text = "Only Sell Income At Or Below",
            Default = 0,
            Min = 0,
            Max = 100000,
            Rounding = 0,
            Suffix = " (0 = any)",
            Callback = function(qW)
                Ch.SetSellMaxIncome(qW)
            end
        })
        EmployeeManagementGroup:AddToggle("SellIncludeBanked", {
            Text = "Also Sell Banked (Unplaced) Employees",
            Default = false,
            Callback = function(qY)
                Ch.SetSellIncludeBanked(qY)
            end
        })
        EmployeeManagementGroup:AddToggle("SellIncludeUntrained", {
            Text = "Also Sell Employees Still Training",
            Default = false,
            Callback = function(q_)
                Ch.SetSellIncludeUntrained(q_)
            end
        })
        EmployeeManagementGroup:AddSlider("SellBatch", {
            Text = "Sell Per Trip",
            Default = 10,
            Min = 1,
            Max = 50,
            Rounding = 0,
            Callback = function(q1)
                Ch.SetSellBatch(q1)
            end
        })
        EmployeeManagementGroup:AddSlider("SellDelay", {
            Text = "Sell Delay",
            Default = 10,
            Min = 1,
            Max = 120,
            Rounding = 0,
            Suffix = "s",
            Callback = function(q3)
                Ch.SetSellDelay(q3)
            end
        })
        local Progression_UpgradesGroup = qd[2]:AddRightGroupbox("Progression & Upgrades", "arrow-big-up")
        qk[5] = Progression_UpgradesGroup:AddLabel(State.ProgressStatus, true)
        Progression_UpgradesGroup:AddToggle("AutoTrack", {
            Text = "Auto Upgrade Sprint Track",
            Default = false,
            Callback = function(q6)
                Ch.SetAutoTrack(q6)
            end
        })
        Progression_UpgradesGroup:AddToggle("AutoOffice", {
            Text = "Auto Purchase Desks & Upgrade Office",
            Default = false,
            Callback = function(q8)
                Ch.SetAutoOffice(q8)
            end
        })
        Progression_UpgradesGroup:AddToggle("AutoTrail", {
            Text = "Auto Buy & Equip Best Trail",
            Default = false,
            Callback = function(ra)
                Ch.SetAutoTrail(ra)
            end
        })
        Progression_UpgradesGroup:AddToggle("AutoCars", {
            Text = "Auto Buy & Park Best Cars (Driveway)",
            Default = false,
            Callback = function(rc)
                Ch.SetAutoCars(rc)
            end
        })
        local SprintTrainingGroup = qd[2]:AddLeftGroupbox("Sprint Training", "footprints")
        qk[6] = SprintTrainingGroup:AddLabel(State.SprintStatus, true)
        SprintTrainingGroup:AddToggle("AutoSprint", {
            Text = "Auto Run Sprint Track (Speed Farm)",
            Default = false,
            Callback = function(rf)
                Ch.SetAutoSprint(rf)
            end
        })
        local RewardsGroup = qd[3]:AddRightGroupbox("Rewards", "gift")
        qk[7] = RewardsGroup:AddLabel(State.RewardStatus, true)
        RewardsGroup:AddToggle("AutoIndex", {
            Text = "Auto Claim Employee Index Rewards",
            Default = false,
            Callback = function(ri)
                Ch.SetAutoIndex(ri)
            end
        })
        RewardsGroup:AddToggle("AutoSpin", {
            Text = "Auto Spin Reward Wheel",
            Default = false,
            Callback = function(rk)
                Ch.SetAutoSpin(rk)
            end
        })
        RewardsGroup:AddToggle("AutoDaily", {
            Text = "Auto Claim Daily Reward",
            Default = false,
            Callback = function(rm)
                Ch.SetAutoDaily(rm)
            end
        })
        RewardsGroup:AddToggle("AutoGift", {
            Text = "Auto Claim Group Gift",
            Default = false,
            Callback = function(ro)
                Ch.SetAutoGift(ro)
            end
        })
        local TeleportsGroup = qd[4]:AddRightGroupbox("Teleports", "map-pin")
        TeleportsGroup:AddButton({
            Text = "Teleport to My Plot Spawn",
            Func = function()
                Ch.TeleportToPlot()
            end
        })
        TeleportsGroup:AddButton({
            Text = "Teleport to Office Desks",
            Func = function()
                Ch.TeleportToDesks()
            end
        })
        TeleportsGroup:AddButton({
            Text = "Teleport to Sprint Track",
            Func = function()
                Ch.TeleportToTrack()
            end
        })
        TeleportsGroup:AddButton({
            Text = "Teleport to SafeZone Line",
            Func = function()
                Ch.TeleportToSafeZone()
            end
        })
        TeleportsGroup:AddButton({
            Text = "Teleport to Sell Broker NPC",
            Func = function()
                Ch.TeleportToBroker()
            end
        })
        TeleportsGroup:AddButton({
            Text = "Teleport to Zone 10 Requisition Machine",
            Func = function()
                Ch.TeleportToMachine()
            end
        })
        local ZonesGroup = qd[4]:AddLeftGroupbox("Zones", "map")
        local PP = qj[1] or ""
        ZonesGroup:AddDropdown("TeleportZone", { Text = "Zone", Values = qj, Default = PP, Multi = false, AllowNull = true })
        ZonesGroup:AddButton({
            Text = "Teleport to Zone",
            Func = function()
                Ch.TeleportToZone(Options.TeleportZone.Value)
            end
        })
        PN = task.spawn(function()
            while not Library.Unloaded do
                task.wait(0.5)
                pcall(function()
                    qk[1]:SetText(State.Status)
                    qk[2]:SetText(State.PlaceStatus)
                    qk[3]:SetText(State.HireStatus)
                    qk[4]:SetText(State.ManageStatus)
                    qk[5]:SetText(State.ProgressStatus)
                    qk[6]:SetText(State.SprintStatus)
                    qk[7]:SetText(State.RewardStatus)
                end)
            end
        end)
        Ch.Track(function()
            pcall(task.cancel, PN)
        end)
    end
    ql()
    local function rJ()
        local P3
        local PY
        PY = nil
        P3 = nil
        local Label3, P_, P0, P1, Label, P4, P5, Label2
        local Qc_2
        local Qb_1, Qb_2
        local Qa_1
        P1 = Color3.fromRGB(120, 230, 150)
        local P7 = Color3.fromRGB(120, 180, 255)
        P_ = Color3.fromRGB(255, 190, 120)
        local P8 = Color3.fromRGB(180, 180, 180)
        P5 = function(rP, rQ, rR)
            return string.format('%s: <font color="#%s">%s</font>', rP, rR:ToHex(), tostring(rQ))
        end
        local P9 = "Unknown"
        if B_(identifyexecutor) then
            Qa_1, Qb_1 = pcall(identifyexecutor)
            local Qc_1 = Qa_1 and type(Qb_1) == "string"
            if Qc_1 then
                P9 = Qb_1
            end
        end
        local Qa_2 = 0
        for i, v in ipairs({ "hookfunction", "getconnections", "fireproximityprompt", "setclipboard", "getgenv", "cloneref" }) do
            local Qk = v
            Qb_2, Qc_2 = pcall(function()
                return getgenv()[Qk]
            end)
            local Qd = Qb_2 and B_(Qc_2)
            if Qd then
                Qa_2 += 1
            end
        end
        local Qb_3 = "(" .. Qa_2 .. "/6 globals)"
        PY = os.clock()
        P4 = function()
            local PR = math.floor(os.clock() - PY)
            if PR < 60 then
                return PR .. "s"
            elseif PR < 3600 then
                return string.format("%dm %ds", math.floor((PR) / (60)), PR % 60)
            else
                return string.format("%dh %dm", math.floor((PR) / (3600)), math.floor((PR % 3600) / (60)))
            end
        end
        local UserGroup = qc[1]:AddLeftGroupbox("User", "circle-user")
        UserGroup:AddPlayerInfo("InfoUserCard", { Player = LocalPlayer, Title = "User", HeaderIcon = "user", Collapsible = false })
        UserGroup:AddLabel(P5("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, P1), true)
        UserGroup:AddLabel(P5("UserId", tostring(LocalPlayer.UserId), P7), true)
        UserGroup:AddLabel(P5("Executor", P9 .. "  " .. Qb_3, P1), true)
        UserGroup:AddDivider()
        Label3 = UserGroup:AddLabel(P5("Session", P4(), P_), true)
        UserGroup:AddDivider()
        UserGroup:AddButton({
            Text = "Copy Username",
            Func = function()
                pY(LocalPlayer.Name, "Copied username")
            end
        })
        UserGroup:AddButton({
            Text = "Copy Profile Link",
            Func = function()
                pY("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
            end
        })
        local SessionGroup = qc[1]:AddRightGroupbox("Session", "signal")
        SessionGroup:AddLabel(P5("Game", pL, P7), true)
        Label2 = SessionGroup:AddLabel(P5("Players", "0/0", P1), true)
        P0 = tostring(game.JobId)
        local P7_1 = #P0 > 18 and string.sub(P0, 1, 18) .. "..."
        local Qa_4 = P7_1 or P0
        SessionGroup:AddLabel(P5("Job", Qa_4, P8), true)
        Label = SessionGroup:AddLabel(P5("Ping", "0 ms", P_), true)
        SessionGroup:AddDivider()
        SessionGroup:AddButton({
            Text = "Rejoin Place",
            Func = function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        })
        SessionGroup:AddButton({
            Text = "Copy Job ID",
            Func = function()
                pY(P0, "Copied Job ID")
            end
        })
        P3 = task.spawn(function()
            local PU_1
            local PT_1
            while true do
                task.wait(1)
                if Library.Unloaded then
                    break
                end
                Label3:SetText(P5("Session", P4(), P_))
                Label2:SetText(P5("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), P1))
                PT_1, PU_1 = pcall(function()
                    return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local PT_2 = PT_1 and PU_1 .. " ms" or "n/a"
                Label:SetText(P5("Ping", PT_2, P_))
            end
        end)
        Ch.Track(function()
            if coroutine.status(P3) ~= "dead" then
                pcall(task.cancel, P3)
            end
        end)
        local SocialsGroup = qc[1]:AddRightGroupbox("Socials", "link")
        SocialsGroup:AddButton({ Text = "Discord", Func = onDiscord })
        SocialsGroup:AddButton({
            Text = "Rscripts",
            Func = function()
                pY(pO, "Copied Rscripts profile")
            end
        })
        SocialsGroup:AddButton({
            Text = "Website",
            Func = function()
                pY(pP, "Copied website link")
            end
        })
    end
    rJ()
    local function sV()
        local s2
        local s0
        local s1
        local s_
        local MovementGroup = qc[3]:AddLeftGroupbox("Movement", "footprints")
        MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
        MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
        MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
        MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
        MovementGroup:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = false })
        local FlyGroup = qc[3]:AddRightGroupbox("Fly", "feather")
        FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
        FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
        s_ = {}
        s1 = {}
        local sZ = {}
        s2 = {}
        s0 = {}
        local function s3()
            for k, v in s_ do
                if k.Parent then
                    k.CanCollide = v
                end
            end
            table.clear(s_)
        end
        local function s7()
            for k, v in s0 do
                if k.Parent then
                    k.WalkSpeed = v
                end
            end
            table.clear(s0)
        end
        local function tb()
            for k, v in s1 do
                if k.Parent then
                    k.PlatformStand = v
                end
            end
            table.clear(s1)
        end
        local function tf(tg)
            local QJ = if not tg:IsA("ProximityPrompt") then 1 else 0
            if QJ == 1 then
                return
            end
            if s2[tg] == nil then
                s2[tg] = {
                    HoldDuration = tg.HoldDuration,
                    MaxActivationDistance = tg.MaxActivationDistance,
                    RequiresLineOfSight = tg.RequiresLineOfSight
                }
            end
            tg.HoldDuration = 0
            tg.MaxActivationDistance = 50
            tg.RequiresLineOfSight = false
        end
        local function ti()
            for k, v in s2 do
                if k.Parent then
                    k.HoldDuration = v.HoldDuration
                    k.MaxActivationDistance = v.MaxActivationDistance
                    k.RequiresLineOfSight = v.RequiresLineOfSight
                end
            end
            table.clear(s2)
        end
        Toggles.Fly:OnChanged(function()
            if not Toggles.Fly.Value then
                tb()
            end
        end)
        Toggles.WalkSpeedEnabled:OnChanged(function()
            if not Toggles.WalkSpeedEnabled.Value then
                s7()
            end
        end)
        Toggles.NoClip:OnChanged(function()
            if not Toggles.NoClip.Value then
                s3()
            end
        end)
        Toggles.InstantProximityPrompt:OnChanged(function()
            if Toggles.InstantProximityPrompt.Value then
                for i, descendant in ipairs(Workspace:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        pcall(tf, descendant)
                    end
                end
            else
                ti()
            end
        end)
        table.insert(sZ, Workspace.DescendantAdded:Connect(function(tB)
            local Q0 = Toggles.InstantProximityPrompt.Value and tB:IsA("ProximityPrompt")
            if Q0 then
                tf(tB)
            end
        end))
        table.insert(sZ, RunService.Stepped:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            if Toggles.NoClip.Value and Character then
                for i, descendant in ipairs(Character:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        if s_[descendant] == nil then
                            s_[descendant] = descendant.CanCollide
                        end
                        descendant.CanCollide = false
                    end
                end
            end
        end))
        table.insert(sZ, UserInputService.JumpRequest:Connect(function()
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Rc = Character and Character:FindFirstChildOfClass("Humanoid")
            if Toggles.InfJump.Value and Rc then
                Rc:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end))
        table.insert(sZ, RunService.RenderStepped:Connect(function(tY)
            if Library.Unloaded then
                return
            end
            local Character = LocalPlayer.Character
            local Ri = Character and Character:FindFirstChildOfClass("Humanoid")
            local Rj = Character
            if Rj then
                Rj = Character:FindFirstChild("HumanoidRootPart")
            end
            local Rh_1 = Rj
            local CurrentCamera = Workspace.CurrentCamera
            if Toggles.WalkSpeedEnabled.Value and Ri then
                if s0[Ri] == nil then
                    s0[Ri] = Ri.WalkSpeed
                end
                Ri.WalkSpeed = Options.WalkSpeed.Value
            end
            if Toggles.Fly.Value and Rh_1 and Ri and CurrentCamera then
                if s1[Ri] == nil then
                    s1[Ri] = Ri.PlatformStand
                end
                Ri.PlatformStand = true
                local Rj_4 = Vector3.zero
                local Rs = if not UserInputService:GetFocusedTextBox() then 1 else 0
                if Rs == 1 then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        Rj_4 += CurrentCamera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        Rj_4 -= CurrentCamera.CFrame.LookVector
                    end
                    local Rp = if UserInputService:IsKeyDown(Enum.KeyCode.A) then 1 else 0
                    if Rp == 1 then
                        Rj_4 -= CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        Rj_4 += CurrentCamera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        Rj_4 += Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        Rj_4 -= Vector3.new(0, 1, 0)
                    end
                end
                Rh_1.AssemblyLinearVelocity = Vector3.zero
                if Rj_4.Magnitude > 0 then
                    Rh_1.CFrame = Rh_1.CFrame + Rj_4.Unit * Options.FlySpeed.Value * tY
                end
            end
        end))
        Ch.Track(function()
            for k, v in sZ do
                v:Disconnect()
            end
            s3()
            s7()
            tb()
            ti()
        end)
    end
    sV()
    local function ud()
        local SA, SB, Label, SD, SE, SF, SG, SH, SI, SJ, SK, SL, SM, SN
        SD = {}
        SL = {}
        SI = nil
        SJ = 0
        SF = 0
        SN = false
        SA = os.clock()
        local MenuGroup = qc[4]:AddLeftGroupbox("Menu", "logs")
        MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
        Label = MenuGroup:AddLabel("AFK triggers: 0")
        SG = function()
            local CurrentCamera
            CurrentCamera = Workspace.CurrentCamera
            local RB = not CurrentCamera or not B_(VirtualUser.CaptureController) or not B_(VirtualUser.ClickButton2)
            if RB then
                return false
            end
            local RB_1 = pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            end)
            if not RB_1 then
                return false
            end
            SJ += 1
            SA = os.clock()
            pcall(function()
                Label:SetText("AFK triggers: " .. SJ)
            end)
            return true
        end
        SB = function(uH)
            pcall(function()
                GuiService:SetGameplayPausedNotificationEnabled(not uH)
            end)
            pcall(function()
                local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
                if RobloxNetworkPauseNotificati then
                    RobloxNetworkPauseNotificati.Enabled = not uH
                end
            end)
            if not uH then
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
        SM = function(uX)
            local RK = uX.ClassName == "ParticleEmitter" or uX.ClassName == "Trail" or uX.ClassName == "Smoke" or uX.ClassName == "Fire" or uX.ClassName == "Sparkles"
            local RO = if RK then 1 else 0
            local RM = 3599 * RO + 2985 * (1 - RO)
            local RN = 1219 * RO + 3761 * (1 - RO)
            if not ((RM * 3816 + RN * 963 + RM * RN) % 16777213 == 2517649) then
                RK = uX.ClassName == "Explosion"
            end
            if not RK then
                RK = uX.ClassName == "Beam"
            end
            if RK then
                if SD[uX] == nil then
                    SD[uX] = uX.Enabled
                end
                pcall(function()
                    uX.Enabled = false
                end)
            end
        end
        SK = function()
            for k, v in SD do
                local RU = k
                local RW = v
                if RU.Parent then
                    pcall(function()
                        RU.Enabled = RW
                    end)
                end
            end
            table.clear(SD)
            if SI then
                pcall(function()
                    settings().Rendering.QualityLevel = SI.Quality
                end)
                Lighting.GlobalShadows = SI.Shadows
                Lighting.FogEnd = SI.Fog
                SI = nil
            end
        end
        MenuGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
        MenuGroup:AddToggle("AutoReconnect", { Text = "Auto Reconnect on Kick", Default = false })
        MenuGroup:AddToggle("Disable3D", {
            Text = "Disable 3D Rendering",
            Default = false,
            Callback = function(vb)
                pcall(function()
                    RunService:Set3dRenderingEnabled(not vb)
                end)
            end
        })
        MenuGroup:AddToggle("FpsBoost", {
            Text = "FPS Boost",
            Default = false,
            Callback = function(vg)
                if vg then
                    if not SI then
                        SI = {
                            Quality = settings().Rendering.QualityLevel,
                            Shadows = Lighting.GlobalShadows,
                            Fog = Lighting.FogEnd
                        }
                    end
                    pcall(function()
                        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                    end)
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9000000000
                    for i, descendant in ipairs(Workspace:GetDescendants()) do
                        pcall(SM, descendant)
                    end
                else
                    SK()
                end
            end
        })
        MenuGroup:AddToggle("HideUiOnStart", { Text = "Hide UI On Start", Default = false })
        MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
        Library.ToggleKeybind = Options.MenuKeybind
        SB(true)
        local ScriptGroup = qc[4]:AddLeftGroupbox("Script", "terminal")
        ScriptGroup:AddButton({
            Text = "Unload Script",
            Func = function()
                Library:Unload()
            end
        })
        Toggles.AntiGameplayPause:OnChanged(function()
            SB(Toggles.AntiGameplayPause.Value)
        end)
        if Toggles.AntiGameplayPause.Value then
            SB(true)
        end
        table.insert(SL, LocalPlayer.Idled:Connect(function()
            if Toggles.AntiAfk.Value and not Library.Unloaded then
                SG()
            end
        end))
        table.insert(SL, Workspace.DescendantAdded:Connect(function(vz)
            if Toggles.FpsBoost.Value then
                SM(vz)
            end
        end))
        SH = function(vD)
            if SN or Library.Unloaded or not Toggles.AutoReconnect.Value then
                return
            end
            SN = true
            local Sb = SF
            local Sc_1 = pcall(function()
                if vD then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end)
            if not Sc_1 then
                SN = false
                if not vD and Sb == SF then
                    task.delay(1.5, function()
                        if Sb == SF then
                            SH(true)
                        end
                    end)
                end
            end
        end
        table.insert(SL, TeleportService.TeleportInitFailed:Connect(function(vV)
            local Sg
            if vV == LocalPlayer and SN then
                SN = false
                Sg = SF
                task.delay(3, function()
                    if Sg == SF then
                        SH(true)
                    end
                end)
            end
        end))
        task.spawn(function()
            local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 30)
            local Sl = RobloxPromptGui and RobloxPromptGui:WaitForChild("promptOverlay", 30)
            if Library.Unloaded or not Sl then
                return
            end
            table.insert(SL, Sl.ChildAdded:Connect(function(v9)
                if v9.Name == "ErrorPrompt" then
                    SH(false)
                end
            end))
        end)
        SE = task.spawn(function()
            while not Library.Unloaded do
                if Toggles.AntiGameplayPause.Value then
                    SB(true)
                end
                local Sr = Toggles.AntiAfk.Value and os.clock() - SA >= 60
                if Sr then
                    SG()
                end
                task.wait(1)
            end
        end)
        Ch.Track(function()
            SF += 1
            for k, v in SL do
                v:Disconnect()
            end
            pcall(task.cancel, SE)
            SB(false)
            SK()
            pcall(function()
                RunService:Set3dRenderingEnabled(true)
            end)
        end)
    end
    ud()
    local function wt()
        local TN, TO, TP, TQ
        ThemeManager:SetLibrary(Library)
        ThemeManager:SetFolder("MyScriptHub")
        ThemeManager:SaveDefault("Evil Hello Kitty")
        ThemeManager:ApplyToTab(qc[4])
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
        SaveManager:SetFolder("TempoHub/StealAnEmployee")
        local TR = SaveManager:BuildConfigSection(qc[4])
        TQ = function(wA, wB)
            local SR = wA == "Toggle" and Toggles
            local SW = if SR then 1 else 0
            local SU = 1898 * SW + 2591 * (1 - SW)
            local SV = 3229 * SW + 3097 * (1 - SW)
            if not ((SU * 3507 + SV * 1507 + SU * SV) % 16777213 == 873818) then
                SR = Options
            end
            local SR_1 = SR[wB]
            local SQ_2 = type(SR_1) == "table" and SR_1.Type == wA
            return SQ_2 and SR_1 or nil
        end
        TO = function(wK, wL)
            local Type = wL.Type
            if Type == "Toggle" then
                return { idx = wK, type = "Toggle", value = wL.Value == true }
            elseif Type == "Slider" then
                return { idx = wK, type = "Slider", value = tostring(wL.Value) }
            elseif Type == "Dropdown" then
                return { idx = wK, type = "Dropdown", multi = wL.Multi == true, value = wL.Value }
            elseif Type == "Input" then
                local SY = wL.Value or ""
                return { idx = wK, type = "Input", text = tostring(SY) }
            elseif Type == "ColorPicker" then
                return { idx = wK, type = "ColorPicker", value = wL.Value:ToHex(), transparency = wL.Transparency }
            elseif Type == "KeyPicker" then
                return {
                    idx = wK,
                    type = "KeyPicker",
                    mode = wL.Mode,
                    key = wL.Value,
                    modifiers = wL.Modifiers,
                    toggled = wL.Toggled
                }
            else
                return nil
            end
        end
        TN = function()
            local S0 = {}
            for i, v in ipairs({ Toggles, Options }) do
                for k, v in pairs(v) do
                    local S1 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
                    if S1 then
                        local S1_1 = TO(k, v)
                        if S1_1 then
                            S0[#S0 + 1] = S1_1
                        end
                    end
                end
            end
            table.sort(S0, function(wV, wW)
                if wV.type ~= wW.type then
                    return wV.type < wW.type
                end
                return wV.idx < wW.idx
            end)
            return { objects = S0 }
        end
        TP = function(wY)
            local Th
            Th = nil
            local Ti = type(wY) ~= "table" or type(wY.idx) ~= "string" or type(wY.type) ~= "string"
            local Tm = if Ti then 1 else 0
            local Tk = 1192 * Tm + 1049 * (1 - Tm)
            local Tl = 374 * Tm + 1530 * (1 - Tm)
            if not ((Tk * 2282 + Tl * 2991 + Tk * Tl) % 16777213 == 4284586) then
                Ti = SaveManager.Ignore[wY.idx]
            end
            if Ti then
                return false
            end
            Th = TQ(wY.type, wY.idx)
            if not Th then
                return false
            end
            local Ti_1 = pcall(function()
                if wY.type == "Input" then
                    if type(wY.text) ~= "string" then
                        return
                    end
                    Th:SetValue(wY.text)
                elseif wY.type == "ColorPicker" then
                    Th:SetValueRGB(Color3.fromHex(wY.value), wY.transparency)
                elseif wY.type == "KeyPicker" then
                    Th:SetValue({ wY.key, wY.mode, wY.modifiers })
                    if wY.mode == "Toggle" and wY.toggled ~= nil then
                        Th.Toggled = wY.toggled
                        Th:Update()
                    end
                else
                    Th:SetValue(wY.value)
                end
            end)
            return Ti_1
        end
        TR:AddDivider()
        TR:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
        TR:AddButton("Export Config to Clipboard", function()
            local To_1
            local Tn_1
            Tn_1, To_1 = pcall(HttpService.JSONEncode, HttpService, TN())
            if Tn_1 then
                local Tn_2 = B_(setclipboard) and setclipboard
                local Tp = Tn_2
                if not Tp then
                    local Tn_3 = B_(toclipboard) and toclipboard
                    Tp = Tn_3 or nil
                end
                local Tn_4 = Tp
                local Tp_1 = type(Tn_4) == "function" and pcall(Tn_4, To_1)
                if Tp_1 then
                    Library:Notify("Config copied to clipboard", 6)
                    return
                end
                Library:Notify("Your executor does not support copying to the clipboard")
                return
            end
            Library:Notify("Failed to encode the config")
        end)
        TR:AddButton("Import Config from Clipboard Text", function()
            local Tx_1
            local Tv = Options.SaveManager_ImportSource.Value or ""
            local Tv_1
            local Tw = tostring(Tv):match("^%s*(.-)%s*$")
            if Tw == "" then
                Library:Notify("Paste an exported config into the box first")
                return
            end
            if #Tw > 262144 then
                Library:Notify("That config is too large")
                return
            end
            Tv_1, Tx_1 = pcall(HttpService.JSONDecode, HttpService, Tw)
            local Tw_1 = not Tv_1
            local TB = if Tw_1 then 1 else 0
            local Tz = 3690 * TB + 2260 * (1 - TB)
            local TA = 3250 * TB + 1679 * (1 - TB)
            if not ((Tz * 1149 + TA * 2447 + Tz * TA) % 16777213 == 7407847) then
                Tw_1 = type(Tx_1) ~= "table"
            end
            if not Tw_1 then
                Tw_1 = type(Tx_1.objects) ~= "table"
            end
            if Tw_1 then
                Library:Notify("That is not a valid exported config")
                return
            end
            if #Tx_1.objects > 2048 then
                Library:Notify("That config has too many records")
                return
            end
            local Tv_2 = 0
            for i, v in ipairs(Tx_1.objects) do
                if TP(v) then
                    Tv_2 += 1
                end
            end
            if Tv_2 == 0 then
                Library:Notify("No settings in that config matched this script")
                return
            end
            Options.SaveManager_ImportSource:SetValue("")
            local Tx_2 = Tv_2 == 1 and "" or "s"
            Library:Notify(("Imported %d setting%s"):format(Tv_2, Tx_2), 6)
        end)
        ThemeManager:LoadDefault()
        SaveManager:LoadAutoloadConfig()
        local function TR_1(xw, xx)
            if Options[xw] then
                xx(Options[xw].Value)
            end
        end
        local function TS(xA, xB)
            if Toggles[xA] then
                xB(Toggles[xA].Value)
            end
        end
        TR_1("StealDelay", Ch.SetStealDelay)
        TR_1("StealZones", Ch.SetStealZones)
        TS("StealPriority", Ch.SetStealPriority)
        TS("StealRespectDesks", Ch.SetStealRespectDesks)
        TS("StealOtherPlots", Ch.SetStealOtherPlots)
        TR_1("SellKeep", Ch.SetSellKeep)
        TR_1("SellRanks", Ch.SetSellRanks)
        TR_1("SellMaxIncome", Ch.SetSellMaxIncome)
        TR_1("SellBatch", Ch.SetSellBatch)
        TR_1("SellDelay", Ch.SetSellDelay)
        TS("SellIncludeBanked", Ch.SetSellIncludeBanked)
        TS("SellIncludeUntrained", Ch.SetSellIncludeUntrained)
        TS("AutoSteal", Ch.SetAutoSteal)
        TS("AutoPlace", Ch.SetAutoPlace)
        TS("AutoHire", Ch.SetAutoHire)
        TS("AutoEquipBest", Ch.SetAutoEquipBest)
        TS("AutoSell", Ch.SetAutoSell)
        TS("AutoTrack", Ch.SetAutoTrack)
        TS("AutoOffice", Ch.SetAutoOffice)
        TS("AutoTrail", Ch.SetAutoTrail)
        TS("AutoCars", Ch.SetAutoCars)
        TS("AutoSprint", Ch.SetAutoSprint)
        TS("AutoIndex", Ch.SetAutoIndex)
        TS("AutoSpin", Ch.SetAutoSpin)
        TS("AutoDaily", Ch.SetAutoDaily)
        TS("AutoGift", Ch.SetAutoGift)
        if Toggles.HideUiOnStart and Toggles.HideUiOnStart.Value then
            Library:Toggle(false)
        end
    end
    wt()
end
T5_1()
end)(...)
