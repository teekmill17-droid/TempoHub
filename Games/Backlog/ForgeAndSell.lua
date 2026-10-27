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
getgenv().TempoHoodSubtitle = "FORGE AND SELL"
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
local mN
local mu
local LocalPlayer
local SaveManager
local nA
local Workspace
local mh
local mZ
local UPGRADE_PRICES
local nn
local mn
local Label
local Toggles
local VirtualUser
local Label3
local na
local nz
local mz
local ng
local mg
local nF
local mF
local nm
local m3
local mL
local ns
local ms
local mR
local my
local nf
local mf
local mX
local nE
local mE
local CoreGui
local bodyVelocity
local m2
local mK
local nr
local mr
local m8
local mQ
local nx
local mx
local TeleportService
local me
local mW
local nD
local mD
local nk
local mk
local m1
local mJ
local nq
local mq
local m7
local nw
local mw
local nd
local Players
local nC
local mC
local Label4
local mj
local m0
local Label2
local HttpService
local mp
local m6
local mO
local nv
local Library
local nc
local mU
local nB
local ni
local mi
local m_
local Options
local no
local mo
local m5
local function fn14(iv, iw)
    local Type = iw.Type
    if Type == "Toggle" then
        return { idx = iv, type = "Toggle", value = iw.Value == true }
    elseif Type == "Slider" then
        return { idx = iv, type = "Slider", value = tostring(iw.Value) }
    elseif Type == "Dropdown" then
        return { idx = iv, type = "Dropdown", multi = iw.Multi == true, value = iw.Value }
    elseif Type == "Input" then
        local ud = iw.Value or ""
        return { idx = iv, type = "Input", text = tostring(ud) }
    elseif Type == "ColorPicker" then
        return { idx = iv, type = "ColorPicker", value = iw.Value:ToHex(), transparency = iw.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = iv,
            type = "KeyPicker",
            mode = iw.Mode,
            key = iw.Value,
            modifiers = iw.Modifiers,
            toggled = iw.Toggled
        }
    else
        return nil
    end
end
local function fn29()
    local sd = if mO() < mL then 1 else 0
    if sd == 1 then
        return
    end
    pcall(function()
        mz.StartBlueprintRoll:FireServer()
    end)
    task.wait(0.8)
end
local function fn30()
    local ta = nC()
    local tb = mo()
    if not ta or not tb then
        return
    end
    me()
    mq = true
    tb.PlatformStand = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = ta
end
local function fn49()
    local r7 = mE()
    local r8 = UPGRADE_PRICES[r7 + 1]
    local r7_1 = not r8 or m8() < r8
    if r7_1 then
        return
    end
    pcall(function()
        mz.RequestUpgradeAnvil:FireServer()
    end)
    task.wait(0.35)
end
local function onRejoinServer()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end
local function fn58()
    me()
    nc = nil
    nf = false
    na = 0
    m6 = nil
end
local function onCharacterAdded()
    task.wait(0.5)
    if m_("Fly") then
        nq()
    end
end
local function onImportConfigFromClipboardFie()
    local uU_1
    local uS = Options.SaveManager_ImportSource.Value or ""
    local uS_1
    local uT = tostring(uS):match("^%s*(.-)%s*$")
    if uT == "" then
        Library:Notify("Paste a config first")
        return
    end
    uS_1, uU_1 = pcall(HttpService.JSONDecode, HttpService, uT)
    local uT_1 = not uS_1 or type(uU_1) ~= "table" or type(uU_1.objects) ~= "table"
    if uT_1 then
        Library:Notify("Invalid config payload")
        return
    end
    local uS_2 = 0
    for i, v in ipairs(uU_1.objects) do
        if mJ(v) then
            uS_2 += 1
        end
    end
    Options.SaveManager_ImportSource:SetValue("")
    Library:Notify("Imported " .. tostring(uS_2) .. " settings")
end
local function onRscripts()
    ni(mQ, "Copied Rscripts profile to clipboard")
end
local function worker2()
    local s__1
    local sZ_1
    while not Library.Unloaded do
        task.wait(1)
        Label:SetText(nB("Session", ng(), mw))
        Label2:SetText(nB("Players", #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers), mC))
        sZ_1, s__1 = pcall(function()
            return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        local sZ_2 = sZ_1 and s__1 .. " ms"
        local s4 = if sZ_2 then 1 else 0
        local s2 = 2261 * s4 + 1039 * (1 - s4)
        local s3 = 863 * s4 + 175 * (1 - s4)
        if not ((s2 * 3796 + s3 * 3078 + s2 * s3) % 16777213 == 13190313) then
            sZ_2 = "n/a"
        end
        Label3:SetText(nB("Ping", sZ_2, mw))
    end
end
local function fn149()
    return CoreGui
end
local function fn151(bR)
    local pK = mo()
    local pL = not pK or not bR or not bR:IsA("Tool")
    if pL then
        return false
    elseif bR.Parent == my() then
        return true
    else
        pK:EquipTool(bR)
        task.wait(0.12)
        return bR.Parent == my()
    end
end
local function fn155(cp)
    if not cp then
        return false
    end
    local qr = mD("SmeltRarities")
    local qs = mD("SmeltMetals")
    local function qt(cu, cv)
        if not mg(cu) then
            return true
        elseif cu[cv] == true then
            return true
        else
            for k, v in cu do
                if v == cv then
                    return true
                end
            end
            return false
        end
    end
    local qu = qt(qr, cp.Rarity) and qt(qs, cp.DisplayName)
    return qu
end
local function onOnClientEvent(c6, c7, c8, c9)
    nc = { Token = c6, Anvil = c7, MetalId = c8, WeaponType = c9 }
end
local function fn185(b3)
    local pT = my()
    if pT then
        for i, child in ipairs(pT:GetChildren()) do
            local pT_1 = child:IsA("Tool") and child:GetAttribute("InventoryItemId") == b3
            if pT_1 then
                return child
            end
        end
    end
    for i, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
        local pT_2 = child:IsA("Tool") and child:GetAttribute("InventoryItemId") == b3
        if pT_2 then
            return child
        end
    end
    return nil
end
local function fn204(aO)
    local oE = Toggles[aO]
    return oE ~= nil and oE.Value == true
end
local function onWebsite()
    ni(mK, "Copied website link")
end
local function onCopyJobID()
    ni(mF, "Copied Job ID")
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if m_("InfJump") then
        local th = mo()
        if th then
            th:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn299()
    local se = hookfunction ~= nil
    local sf = hookmetamethod ~= nil
    local sg = getrawmetatable ~= nil
    local sh = setrawmetatable ~= nil
    local si = getgc ~= nil
    local sj = getgenv ~= nil
    local sk = getreg ~= nil
    local sl = getconnections ~= nil
    local sm = firesignal ~= nil
    local sn = getcallbackvalue ~= nil
    local so = setclipboard ~= nil
    local sp = getcustomasset ~= nil
    local sq = getnamecallmethod ~= nil
    local sr = isexecutorclosure ~= nil
    local ss = fireproximityprompt ~= nil
    local st = firetouchinterest ~= nil
    local su = WebSocket ~= nil
    local sv = readfile ~= nil
    local sw = writefile ~= nil
    local sy = (request or http_request) ~= nil
    local sA = (debug and debug.getupvalues) ~= nil
    local sC = (debug and debug.setupvalue) ~= nil
    local sD = 0
    local sE = { se, sf, sg, sh, si, sj, sk, sl, sm, sn, so, sp, sq, sr, ss, st, su, sv, sw, sy, sA, sC }
    for i, v in ipairs(sE) do
        if v then
            sD += 1
        end
    end
    local se_1 = sD / #sE
    if se_1 >= 0.9 then
        return mk("Full Support", mC)
    elseif se_1 >= 0.6 then
        return mk("Half Support", mw)
    else
        return mk("Low Support", mn)
    end
end
local function fn319()
    mq = false
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    local s5 = mo()
    if s5 then
        s5.PlatformStand = false
    end
end
local function fn332(dC)
    local Forges = dC:FindFirstChild("Forges")
    if not Forges then
        return false
    end
    for i, child in ipairs(Forges:GetChildren()) do
        local q9_1 = mu(child) and child:GetAttribute("ForgeState") == "Ready"
        if q9_1 then
            local q9_2 = mi(child, "ForgePrompt")
            if q9_2 then
                m0(q9_2)
                task.wait(0.3)
                return true
            end
        end
    end
    return false
end
local function fn343()
    local o7 = my()
    local o8 = o7 and o7:FindFirstChildOfClass("Humanoid")
    return o8
end
local function fn345()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local o1 = leaderstats and leaderstats:FindFirstChild("Coins")
    local o0_1 = o1
    if o1 then
        o1 = tonumber(o0_1.Value)
    end
    return o1 or 0
end
local function fn346(bH)
    if not bH then
        return false
    elseif bH:GetAttribute("ForgeUnlocked") == true then
        return true
    else
        local attr = bH:GetAttribute("ForgeState")
        return attr == "Idle" or attr == "Ready" or attr == "Smelting"
    end
end
local function onCopyUsername()
    ni(LocalPlayer.Name, "Copied username")
end
local function fn380(bX)
    local Inventory = LocalPlayer:FindFirstChild("Inventory")
    local pO = Inventory and Inventory:FindFirstChild(bX)
    local pN_1 = pO
    if pO then
        pO = tonumber(pN_1.Value)
    end
    local pN_2 = pO
    local pS = if pN_2 then 1 else 0
    local pQ = 3014 * pS + 1141 * (1 - pS)
    local pR = 1400 * pS + 2721 * (1 - pS)
    if not ((pQ * 1008 + pR * 1105 + pQ * pR) % 16777213 == 8804712) then
        pN_2 = 0
    end
    return pN_2
end
local function fn394()
    local sU = math.floor(os.clock() - nk)
    if sU < 60 then
        return sU .. "s"
    elseif sU < 3600 then
        return string.format("%dm %ds", math.floor((sU) / (60)), sU % 60)
    else
        return string.format("%dh %dm", math.floor((sU) / (3600)), math.floor((sU % 3600) / (60)))
    end
end
local function fn405()
    local cD = nw("BuyMetal", "Copper")
    return nz[cD]
end
local function onExportConfigToClipboard()
    local uN_1
    local uM_1
    uM_1, uN_1 = pcall(HttpService.JSONEncode, HttpService, nx())
    if not uM_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    if setclipboard then
        setclipboard(uN_1)
    elseif toclipboard then
        toclipboard(uN_1)
    end
    Library:Notify("Exported config to clipboard")
end
local function onCopyProfileLink()
    ni("https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile", "Copied profile link")
end
local function fn418()
    local o3 = tonumber(LocalPlayer:GetAttribute("BlueprintTokens")) or 0
    return o3
end
local function fn431(ce)
    local p6 = my()
    if p6 then
        for i, child in ipairs(p6:GetChildren()) do
            local p6_1 = child:IsA("Tool") and child:GetAttribute("ItemType") == ce
            if p6_1 then
                return child
            end
        end
    end
    for i, child in ipairs(LocalPlayer.Backpack:GetChildren()) do
        local p6_2 = child:IsA("Tool") and child:GetAttribute("ItemType") == ce
        if p6_2 then
            return child
        end
    end
    return nil
end
local function fn456()
    local qD = nf or os.clock() < na
    return qD
end
local function fn479(eB)
    local rO = nr("Weapon")
    local rP = not rO or not nm(rO)
    if rP then
        return false
    end
    local SellStands = eB:FindFirstChild("SellStands")
    local rP_1 = SellStands and SellStands:FindFirstChild("SellStand1")
    local rO_2 = rP_1
    if rP_1 then
        rP_1 = mi(rO_2, "SellStandPrompt")
    end
    local rO_3 = rP_1
    if not rO_3 then
        return false
    end
    m0(rO_3)
    task.wait(0.35)
    return true
end
local function fn490(im, io)
    local t9_1 = (im == "Toggle" and Toggles or Options)[io]
    local t8_2 = type(t9_1) == "table" and t9_1.Type == im
    return t8_2 and t9_1 or nil
end
local function fn562()
    return LocalPlayer.Character
end
local function fn567(aZ)
    for k, v in aZ do
        if v == true then
            return true
        end
        local oL = v ~= ""
        local oM = type(v) == "string" and oL
        if oM then
            return true
        end
        local oL_1 = v ~= nil
        local oM_1 = type(k) == "number" and oL_1
        if oM_1 then
            return true
        end
    end
    return false
end
local function fn611(cT)
    if not m_("AutoSmeltMetal") then
        return false
    end
    local Forges = cT:FindFirstChild("Forges")
    if not Forges then
        return false
    end
    local qG = false
    for i, v in ipairs(nD) do
        local qH_1 = mR(v) and m1(v.Id) > 0
        if qH_1 then
            qG = true
            break
        end
    end
    for i, child in ipairs(Forges:GetChildren()) do
        if mu(child) then
            local attr = child:GetAttribute("ForgeState")
            if attr == "Ready" or attr == "Smelting" then
                return true
            end
            if attr == "Idle" and qG then
                return true
            end
        end
    end
    return false
end
local function fn619(a2, a3)
    local oU = Options[a2]
    local oV = oU and oU.Value
    local oV_1 = oV ~= ""
    local oW = type(oV) == "string" and oV_1
    if oW then
        return oV
    end
    return a3
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if m_("NoClip") then
        local tj_1 = my()
        if tj_1 then
            for i, descendant in ipairs(tj_1:GetDescendants()) do
                local tj_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if tj_2 then
                    mj[descendant] = true
                    descendant.CanCollide = false
                end
            end
        end
    else
        for k in pairs(mj) do
            if k and k.Parent then
                k.CanCollide = true
            end
            mj[k] = nil
        end
    end
end
local function fn648(cK, cL)
    m6 = cL
    local qx = os.clock()
    local qy = cK
    local qC = if qy then 1 else 0
    local qA = 1553 * qC + 2234 * (1 - qC)
    local qB = 1554 * qC + 2184 * (1 - qC)
    if not ((qA * 120 + qB * 2069 + qA * qB) % 16777213 == 5814948) then
        qy = 0.8
    end
    na = math.max(na, qx + qy)
end
local function fn660(az, aA)
    return string.format('<font color="%s">%s</font>', aA, az)
end
local function fn683()
    local o5 = tonumber(LocalPlayer:GetAttribute("AnvilUpgradeLevel")) or 0
    return o5
end
local function fn685(ft)
    local DiscordGroup = ft:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = m7 })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = m7 })
end
local function fn698(aC, aD, aE)
    return string.format("<b>%s</b> %s %s", aC, mk("-", "#5a6070"), mk(aD, aE))
end
local function fn714(gL)
    if gL then
        nq()
    else
        me()
    end
end
local function fn734()
    local pa = my()
    local pb = pa and pa:FindFirstChild("HumanoidRootPart")
    return pb
end
local function fn742()
    local Plots = Workspace:FindFirstChild("Plots")
    if not Plots then
        return nil
    end
    local UserId = LocalPlayer.UserId
    for i, child in ipairs(Plots:GetChildren()) do
        local pd_1 = child:GetAttribute("OwnerUserId") == UserId or child:GetAttribute("OwnerUserId") == UserId
        if pd_1 then
            return child
        end
    end
    return nil
end
local function fn744()
    ni(mX, "Copied Discord invite to clipboard")
end
local function fn757()
    local sQ_1
    local sP_1
    if identifyexecutor then
        sQ_1, sP_1 = identifyexecutor()
        local sR = sQ_1 ~= ""
        local sS = type(sQ_1) == "string" and sR
        if sS then
            local sR_1 = type(sP_1) == "string" and sP_1 ~= "" and sQ_1 .. " " .. sP_1
            nE = sR_1 or sQ_1
        end
    end
end
local function worker3()
    while not Library.Unloaded do
        local tM = no()
        local tN = false
        if tM then
            if m_("AutoBuyMetal") then
                nd()
            end
            local tS = if mN() then 1 else 0
            if tS == 1 then
                tN = true
            else
                local tO_1 = m_("AutoSmeltMetal") and mW(tM)
                if tO_1 then
                    m2(0.85, "smelt")
                    tN = true
                else
                    local tO_2 = m_("AutoSmeltMetal") and nF(tM)
                    if tO_2 then
                        m2(1, "smelt")
                        tN = true
                    else
                        local tO_3 = m_("AutoSmithMetal") and mp(tM)
                        if tO_3 then
                            m2(1, "smith")
                            tN = true
                        else
                            local tO_4 = m_("AutoDepositWeapon") and not mx(tM) and nA(tM)
                            if tO_4 then
                                m2(0.9, "deposit")
                                tN = true
                            else
                                local tO_5 = m_("AutoCollectCash") and not mx(tM) and mZ(tM)
                                if tO_5 then
                                    m2(0.75, "money")
                                    tN = true
                                end
                            end
                        end
                    end
                end
            end
            local tO_6 = not tN
            if tO_6 ~= false then
                tO_6 = not mN()
            end
            if tO_6 then
                if m_("AutoUnlockForges") then
                    ms(tM)
                end
                if m_("AutoBuySmithingTime") then
                    mU()
                end
                if m_("AutoBuyBlueprintChest") then
                    mf()
                end
            end
        end
        local wait = task.wait
        local tN_1 = tN and 0.45 or 0.25
        wait(tN_1)
    end
end
local function fn816()
    local um = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local un = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if un then
                local un_1 = mh(k, v)
                if un_1 then
                    um[#um + 1] = un_1
                end
            end
        end
    end
    table.sort(um, function(iI, iJ)
        if iI.type ~= iJ.type then
            return iI.type < iJ.type
        end
        return iI.idx < iJ.idx
    end)
    return { objects = um }
end
local function fn823(aT)
    local oH = Options[aT]
    local oI = oH and oH.Value
    local oI_1 = type(oI) == "table" and oI
    return oI_1 or {}
end
local function worker()
    while Library and not Library.Unloaded do
        mr()
        task.wait(1)
    end
end
local function fn852(bK, bL)
    if not bK then
        return nil
    elseif bL then
        local py = bK:FindFirstChild(bL, true)
        local pz = py and py:IsA("ProximityPrompt")
        if pz then
            return py
        end
        for i, descendant in ipairs(bK:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                return descendant
            end
        end
        return nil
    else
        for i, descendant in ipairs(bK:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                return descendant
            end
        end
        return nil
    end
end
local function fn853(aH, aI)
    if setclipboard then
        setclipboard(aH)
    elseif toclipboard then
        toclipboard(aH)
    end
    Library:Notify(aI)
end
Players = nil
me = nil
mf = nil
mg = nil
mh = nil
mi = nil
mj = nil
mk = nil
bodyVelocity = nil
mn = nil
mo = nil
mp = nil
mq = nil
mr = nil
ms = nil
Label3 = nil
mu = nil
Library = nil
mw = nil
mx = nil
my = nil
mz = nil
mC = nil
mD = nil
mE = nil
mF = nil
UPGRADE_PRICES = nil
Options = nil
Label2 = nil
mJ = nil
mK = nil
mL = nil
Toggles = nil
mN = nil
mO = nil
mQ = nil
mR = nil
SaveManager = nil
mU = nil
mW = nil
mX = nil
mZ = nil
m_ = nil
local ForgeConfig, mA, UNLOCK_PRICES, mP, mS, mV, mY
m0 = nil
m1 = nil
m2 = nil
m3 = nil
Label = nil
m5 = nil
m6 = nil
m7 = nil
m8 = nil
na = nil
LocalPlayer = nil
nc = nil
nd = nil
TeleportService = nil
nf = nil
ng = nil
Workspace = nil
ni = nil
Label4 = nil
nk = nil
CoreGui = nil
nm = nil
nn = nil
no = nil
HttpService = nil
nq = nil
nr = nil
ns = nil
VirtualUser = nil
nv = nil
nw = nil
nx = nil
nz = nil
nA = nil
nB = nil
nC = nil
nD = nil
nE = nil
nF = nil
local PlayerGui, nu, UserInputService, nJ, nK, nL, nM, nN
PlayerGui = nil
nu = nil
UserInputService = nil
local nO, nP, nR, nS, nT, nU
local nQ_1
Players, UserInputService, VirtualUser, HttpService, CoreGui, Workspace, TeleportService, LocalPlayer, PlayerGui, m5 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
Players = game:GetService("Players")
local u3_7 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
CoreGui = game:GetService("CoreGui")
Workspace = game:GetService("Workspace")
TeleportService = game:GetService("TeleportService")
LocalPlayer = Players.LocalPlayer
PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
m5 = fn149
if getgenv then
    getgenv().gethui = m5
end
pcall(function()
    gethui = m5
end)
if setthreadidentity then
    setthreadidentity(8)
end
nQ_1, mX, mQ, mK, nK, nJ, mz, nL, nP, ForgeConfig, nO, nN, nD, nM, nz, nS, nR = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local u3_11 = 22
repeat
    nT = (u3_11 * 1 + 1) % 11 + 1
    if nT <= 6 then
        if nT <= 3 then
            if nT <= 2 then
                if nT <= 1 then
                    local vJ = bit32.rrotate(bit32.bxor(bit32.lrotate(u3_11, 2), string.byte(tostring(nS))), 6)
                    if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(vJ, 2441083871), 1583009957), (bit32.bxor(bit32.band(vJ, 1853883424), 486563219))), 1583009957), 486563219) == vJ then
                        nR = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Celestial", "Abyssal" }
                    else
                        nQ_1 = { "Mythic", "Rare", "Legendary", "Common", "Abyssal", "Epic", "Celestial", "Divine", "Uncommon" }
                    end
                    u3_11 = (u3_11 + 1) % 44
                else
                    if (u3_11 * 1 + 6) * 21 % 4 == ((u3_11 * 1 + 6) * 21 + 13) % 4 then
                        mQ = "Forge and Sell"
                        mK = "https://discord.gg/K7Qxnxkk46"
                        mX = "https://discord.gg/K7Qxnxkk46"
                        nQ_1 = "https://tempohub.shop"
                    else
                        nQ_1 = "Forge and Sell"
                        mX = "https://discord.gg/K7Qxnxkk46"
                        mQ = "https://discord.gg/K7Qxnxkk46"
                        mK = "https://tempohub.shop"
                    end
                    u3_11 = (u3_11 + 12) % 44
                end
            else
                if (u3_11 * 2 + 6) * 10 % 3 == ((u3_11 * 2 + 6) * 10 + 4) % 3 then
                    u3_7 = nK:WaitForChild("Remotes")
                else
                    nK = u3_7:WaitForChild("Remotes")
                end
                u3_11 = (u3_11 + 23) % 44
            end
        elseif nT <= 5 then
            if nT <= 4 then
                nU = (vector.create((u3_11 * 3 + 1) % 11 + 1, (u3_11 * 6 + 12) % 13 + 1, (u3_11 * 15 + 12) % 17 + 1))
                local vu = vector.floor(nU) + vector.ceil(nU * -1)
                if vector.dot(vu, vu) == 0 then
                    nJ = u3_7:WaitForChild("Shared")
                else
                    u3_7 = nJ:WaitForChild("Shared")
                end
                u3_11 = (u3_11 + 23) % 44
            else
                if ((mX or mX) and (nS and not mX) or (nS or mX or (not nS or mX))) and (not nS and mX or not nS and not mX or not mX and not nS and (not nS or not mX)) and not (((mX or mX) and (nS and not mX) or (nS or mX or (not nS or mX))) and (not nS and mX or not nS and not mX or not mX and not nS and (not nS or not mX))) then
                    nK = {
                        RequestUnlockForge = mz.Forges:WaitForChild("RequestUnlockForge"),
                        StartBlueprintRoll = mz.Blueprints:WaitForChild("StartBlueprintRoll"),
                        PurchaseMetal = mz.Shops:WaitForChild("PurchaseMetal"),
                        RequestUpgradeAnvil = mz.AnvilUpgrades:WaitForChild("RequestUpgradeAnvil"),
                        SubmitTap = mz.Smithing:WaitForChild("SubmitTap"),
                        StartSmithing = mz.Smithing:WaitForChild("StartSmithing")
                    }
                else
                    mz = {
                        PurchaseMetal = nK.Shops:WaitForChild("PurchaseMetal"),
                        StartSmithing = nK.Smithing:WaitForChild("StartSmithing"),
                        SubmitTap = nK.Smithing:WaitForChild("SubmitTap"),
                        RequestUnlockForge = nK.Forges:WaitForChild("RequestUnlockForge"),
                        RequestUpgradeAnvil = nK.AnvilUpgrades:WaitForChild("RequestUpgradeAnvil"),
                        StartBlueprintRoll = nK.Blueprints:WaitForChild("StartBlueprintRoll")
                    }
                end
                u3_11 = (u3_11 + 12) % 44
            end
        else
            if u3_11 * 4504041 + 1 + 3 <= u3_11 * 4504041 + 1 + 3 + 5 then
                nL = require(nJ.Shops.ShopConfig)
            else
                nJ = require(nL.Shops.ShopConfig)
            end
            u3_11 = (u3_11 + 1) % 44
        end
    elseif nT <= 9 then
        if nT <= 8 then
            if nT <= 7 then
                nU = {
                    "qtwloxbdsig",
                    "vtmbvusvjjr",
                    "yzbdp",
                    "wcrydyk",
                    "dnqysbusim",
                    "ynmrd",
                    "aala",
                    "snhjnxewf",
                    "fksr",
                    "fynlzin"
                }
                if nU[(u3_11 * 44 + 12) % 10 + 1] <= nU[(u3_11 * 44 + 12) % 10 + 1] then
                    nP = require(nJ.AnvilUpgrades.AnvilUpgradeConfig)
                    ForgeConfig = require(nJ.Forges.ForgeConfig)
                else
                    nJ = require(ForgeConfig.AnvilUpgrades.AnvilUpgradeConfig)
                    nP = require(ForgeConfig.Forges.ForgeConfig)
                end
                u3_11 = (u3_11 + 23) % 44
            else
                nU = (vector.create((u3_11 * 6 + 9) % 11 + 1, (u3_11 * 5 + 10) % 13 + 1, (u3_11 * 13 + 8) % 17 + 1))
                local nV = (vector.create((u3_11 * 5 + 5) % 11 + 1, (u3_11 * 7 + 11) % 13 + 1, (u3_11 * 4 + 14) % 17 + 1))
                local nW = (vector.create((u3_11 * 4 + 9) % 11 + 1, (u3_11 * 1 + 9) % 13 + 1, (u3_11 * 15 + 11) % 17 + 1))
                local nX = (vector.create((u3_11 * 4 + 2) % 11 + 1, (u3_11 * 1 + 13) % 13 + 1, (u3_11 * 9 + 17) % 17 + 1))
                if vector.dot(vector.cross(nU, nV), (vector.cross(nW, nX))) == vector.dot(nU, nW) * vector.dot(nV, nX) - vector.dot(nU, nX) * vector.dot(nV, nW) + 2 then
                    nJ = require(nO.Blueprints.BlueprintConfig)
                else
                    nO = require(nJ.Blueprints.BlueprintConfig)
                end
                u3_11 = (u3_11 + 23) % 44
            end
        else
            if (u3_11 * 2 + 6) * 4 % 3 == ((u3_11 * 2 + 6) * 4 + 3) % 3 then
                nN = require(nJ.Smithing.SmithingConfig)
            else
                nJ = require(nN.Smithing.SmithingConfig)
            end
            u3_11 = (u3_11 + 12) % 44
        end
    elseif nT <= 10 then
        nT = { "kwaybo", "jiztyc", "iamacyyksc", "scovalysn", "nthfiuci", "pqn", "fymjued", "usbjtwwq", "raifg" }
        local wb = u3_11
        nU = nT[wb % 9 + 1]
        if nU:len() <= nU:reverse():rep(wb % 3 + 2):len() then
            nD = {}
            nM = {}
            nz = {}
        else
            nz = {}
            nD = {}
            nM = {}
        end
        u3_11 = (u3_11 + 12) % 44
    else
        if ((nJ and not nJ or not nQ_1 and not nO) and (nQ_1 or not nO or (nJ or not nO)) or not nO and nQ_1 and (not nJ or nJ) and (nQ_1 and not nQ_1 or (nJ or nQ_1)) or ((nJ or nQ_1) and (not nO or not nJ) and (not nQ_1 or not nJ or nO and nQ_1) or nJ and nO and (not nJ and nO) and (nO and nO and (not nJ or nO)))) and not ((nJ and not nJ or not nQ_1 and not nO) and (nQ_1 or not nO or (nJ or not nO)) or not nO and nQ_1 and (not nJ or nJ) and (nQ_1 and not nQ_1 or (nJ or nQ_1)) or ((nJ or nQ_1) and (not nO or not nJ) and (not nQ_1 or not nJ or nO and nQ_1) or nJ and nO and (not nJ and nO) and (nO and nO and (not nJ or nO)))) then
            nJ = {}
        else
            nS = {}
        end
        u3_11 = (u3_11 + 12) % 44
    end
until (u3_11 * 3 + 11) % 44 == 11
for i, v in ipairs(nL.MetalShop.Metals) do
    u3_11 = {
        Id = v.Id,
        DisplayName = v.DisplayName,
        Rarity = v.Rarity,
        CoinPrice = v.CoinPrice,
        MoltenItemId = v.MoltenItemId
    }
    nD[#nD + 1] = u3_11
    nM[u3_11.Id] = u3_11
    nz[u3_11.DisplayName] = u3_11
    nS[#nS + 1] = u3_11.DisplayName
end
u3_11 = {}
for i, v in ipairs(nR) do
    u3_11[v] = true
end
u3_7 = {}
for i, v in ipairs(nS) do
    u3_7[v] = true
end
u3_11 = nN.MAX_STARS or 10
u3_7 = nN.CLICKS_PER_STAR or 3
mY = u3_11 * u3_7
u3_11 = math.max
u3_7 = nN.MIN_TAP_INTERVAL_SECONDS or 0.08
mS = u3_11(0.09, u3_7 + 0.01)
u3_11 = nO.TIER_1_COST or 100
mL, UPGRADE_PRICES, UNLOCK_PRICES, Library, SaveManager, Toggles, Options, mC, mw, mn, nf, nc, na, m6, nK, nT, mr, mk, nB, ni, m7, m_, mD, mg, nw, m8, mO, mE, my, mo, nC, no, m0, mu, mi, nm, m1, mA, nr, mR, nu, m2, mN, mx, mV, nd, mW, nF, mp, nA, mZ, ms, mU, mf = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
mL = u3_11
UPGRADE_PRICES = nP.UPGRADE_PRICES
UNLOCK_PRICES = ForgeConfig.UNLOCK_PRICES
Library = getgenv().Library
mr = function()
    local function op(Z)
        local on = not Z or not Z:IsA("ScreenGui")
        if on then
            return
        end
        Z.ResetOnSpawn = false
        Z.IgnoreGuiInset = true
        Z.DisplayOrder = math.max(Z.DisplayOrder, 1000)
        pcall(function()
            Z.ClipToDeviceSafeArea = false
        end)
        pcall(function()
            Z.ScreenInsets = Enum.ScreenInsets.None
        end)
        if Z.Parent ~= CoreGui then
            Z.Parent = CoreGui
        end
    end
    op(Library.ScreenGui)
    if Library.ActiveLoading and Library.ActiveLoading.ScreenGui then
        op(Library.ActiveLoading.ScreenGui)
    end
    for i, v in ipairs({ "Obsidian", "ObsidianLoading" }) do
        local oq_1 = CoreGui:FindFirstChild(v) or PlayerGui:FindFirstChild(v)
        if oq_1 then
            op(oq_1)
        end
    end
end
mr()
task.spawn(worker)
nO = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
mC = "#7fd47f"
nM = "#6ec1ff"
mw = "#e8a34d"
nN = "#8b93a3"
mn = "#e05a5a"
mk = fn660
nB = fn698
ni = fn853
m7 = fn744
m_ = fn204
mD = fn823
mg = fn567
nw = fn619
m8 = fn345
mO = fn418
mE = fn683
my = fn562
mo = fn343
nC = fn734
no = fn742
m0 = function(bz)
    local pp = not bz or not bz:IsA("ProximityPrompt")
    if pp then
        return false
    end
    local pp_1 = nC()
    local Parent = bz.Parent
    local pr = pp_1 and Parent and Parent:IsA("BasePart")
    if pr then
        pp_1.CFrame = Parent.CFrame * CFrame.new(0, 3, -4)
        task.wait(0.12)
    end
    pcall(function()
        bz.Enabled = true
        bz.HoldDuration = 0
        bz.MaxActivationDistance = math.max(bz.MaxActivationDistance, 20)
    end)
    if fireproximityprompt then
        fireproximityprompt(bz)
        return true
    end
    return false
end
mu = fn346
if not mN and nK and (mN or nK) or (not nK or mN) and (not mN and not nK) or not mN and not mN and (mN and nK) and ((mN or not nK) and (nK and not mN)) or not (not mN and nK and (mN or nK) or (not nK or mN) and (not mN and not nK) or not mN and not mN and (mN and nK) and ((mN or not nK) and (nK and not mN))) then
    mi = fn852
    nm = fn151
else
    nm = fn852
    mi = fn151
end
m1 = fn380
mA = fn185
nr = fn431
mR = fn155
nu = fn405
nf = false
nc = nil
na = 0
m6 = nil
m2 = fn648
mN = fn456
mx = fn611
mz.StartSmithing.OnClientEvent:Connect(onOnClientEvent)
mV = function(dc)
    local Token
    if nf or not dc or not dc.Token then
        return false
    end
    nf = true
    Token = dc.Token
    pcall(function()
        mz.SubmitTap:InvokeServer(Token, "Start")
        local q_ = 1
        while q_ <= mY do
            local qW = Library.Unloaded or not m_("AutoSmithMetal")
            if qW then
                break
            end
            mz.SubmitTap:InvokeServer(Token, "Tap")
            task.wait(mS)
            q_ += 1
        end
        mz.SubmitTap:InvokeServer(Token, "Finish")
    end)
    task.wait(0.35)
    nf = false
    return true
end
nd = function()
    local q5
    q5 = nu()
    if not q5 then
        return false
    end
    local q6 = m8()
    if q6 < (q5.CoinPrice or 0) then
        return false
    end
    pcall(function()
        mz.PurchaseMetal:FireServer(q5.Id)
    end)
    task.wait(0.25)
    return true
end
mW = fn332
nF = function(dM)
    local Forges = dM:FindFirstChild("Forges")
    if not Forges then
        return false
    end
    local rj
    for i, v in ipairs(nD) do
        local rk_1 = mR(v) and m1(v.Id) > 0
        if rk_1 then
            rj = v
            break
        end
    end
    if not rj then
        return false
    end
    local rk_2 = mA(rj.Id)
    local rj_1 = not rk_2 or not nm(rk_2)
    if rj_1 then
        return false
    end
    for i, child in ipairs(Forges:GetChildren()) do
        local ri_1 = mu(child) and child:GetAttribute("ForgeState") == "Idle"
        if ri_1 then
            local rh = mi(child, "ForgePrompt")
            if rh then
                pcall(function()
                    rh.Enabled = true
                end)
                m0(rh)
                task.wait(0.35)
                return true
            end
        end
    end
    return false
end
mp = function(d7)
    local rB
    if nf then
        return true
    elseif nc then
        local rC_1 = nc
        nc = nil
        mV(rC_1)
        return true
    else
        local rC_2 = nil
        for i, v in ipairs(nD) do
            if mR(v) then
                local rD_1 = mA(v.MoltenItemId)
                if rD_1 then
                    rC_2 = rD_1
                    break
                end
            end
        end
        if not rC_2 then
            rC_2 = nr("MoltenMetal")
        end
        local rD_2 = not rC_2
        local rH = if rD_2 then 1 else 0
        local rF = 804 * rH + 1821 * (1 - rH)
        local rG = 2310 * rH + 1775 * (1 - rH)
        if not ((rF * 1886 + rG * 659 + rF * rG) % 16777213 == 4895874) then
            rD_2 = not nm(rC_2)
        end
        if rD_2 then
            return false
        end
        local Anvils = d7:FindFirstChild("Anvils")
        local rD_3 = Anvils and Anvils:FindFirstChild("Anvil1")
        local rC_4 = rD_3
        if rD_3 then
            rD_3 = mi(rC_4, "AnvilPrompt")
        end
        rB = rD_3
        if not rB then
            return false
        end
        nc = nil
        pcall(function()
            rB.Enabled = true
        end)
        m0(rB)
        local rC_5 = os.clock()
        while true do
            local rD_4 = not nc and os.clock() - rC_5 < 3
            if not rD_4 then
                if nc then
                    local rC_6 = nc
                    nc = nil
                    mV(rC_6)
                end
                return true
            end
            local rD_5 = Library.Unloaded or not m_("AutoSmithMetal")
            if rD_5 then
                break
            end
            task.wait(0.05)
        end
        return true
    end
end
if ((not mi or not nw) and (mi or not mi) and ((nw or not mi) and (not mi or nw)) or (not nw and not nw and (not mi and not mi) or mi and not nw and (not mi and not nw))) and (not mi and nw or (not nw or not nw) or (not mi or nw or (nw or not nw)) or ((mi or mi) and (not nw or not mi) or (not mi and not mi or (mi or nw)))) and not (((not mi or not nw) and (mi or not mi) and ((nw or not mi) and (not mi or nw)) or (not nw and not nw and (not mi and not mi) or mi and not nw and (not mi and not nw))) and (not mi and nw or (not nw or not nw) or (not mi or nw or (nw or not nw)) or ((mi or mi) and (not nw or not mi) or (not mi and not mi or (mi or nw))))) then
    mZ = fn479
    nA = function(eO)
        local rR
        rR = nil
        local MoneyArea = eO:FindFirstChild("MoneyArea")
        local rT = MoneyArea or eO
        rR = mi(rT, "CollectCash")
        if not rR then
            return false
        end
        pcall(function()
            rR.Enabled = true
        end)
        m0(rR)
        task.wait(0.25)
        return true
    end
else
    nA = fn479
    mZ = function(eO)
        local rR
        rR = nil
        local MoneyArea = eO:FindFirstChild("MoneyArea")
        local rT = MoneyArea or eO
        rR = mi(rT, "CollectCash")
        if not rR then
            return false
        end
        pcall(function()
            rR.Enabled = true
        end)
        m0(rR)
        task.wait(0.25)
        return true
    end
end
ms = function(eV)
    local rZ = eV or no()
    eV = rZ
    if not eV then
        return
    end
    local Forges = eV:FindFirstChild("Forges")
    if not Forges then
        return
    end
    local r_ = m8()
    local r0 = ForgeConfig.MAX_FORGES or 6
    for i = 2, r0 do
        local rY = Forges:FindFirstChild("Forge" .. tostring(i))
        local r0_1 = rY and not mu(rY)
        if r0_1 then
            local r0_2 = UNLOCK_PRICES[i] or tonumber(rY:GetAttribute("UnlockPrice"))
            local r1 = r0_2
            if r0_2 then
                r0_2 = r_ >= r1
            end
            if r0_2 then
                pcall(function()
                    mz.RequestUnlockForge:FireServer(rY)
                end)
                task.wait(0.35)
            end
            return
        end
    end
end
mU = fn49
mf = fn29
nK = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = mX, Copyable = true }, "|", nQ_1 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
if (false and (not mE and not mE) or (mC or not mf or mE and mC)) and (not mE and mC and (mE or mC) or not mf and mE and (mf and not mE)) and ((mE or mf) and (not mE or false) and ((mE or mC) and (false and mE)) or (not mf or mC or mE and mE) and (mf or mf or mE and mf)) or not ((false and (not mE and not mE) or (mC or not mf or mE and mC)) and (not mE and mC and (mE or mC) or not mf and mE and (mf and not mE)) and ((mE or mf) and (not mE or false) and ((mE or mC) and (false and mE)) or (not mf or mC or mE and mE) and (mf or mf or mE and mf))) then
    nT = {
        Info = nK:AddTab("Info", "info"),
        Main = nK:AddTab("Main", "hammer"),
        Player = nK:AddTab("Player", "person-standing"),
        Settings = nK:AddTab("Settings", "settings")
    }
else
    nK = {
        Settings = nT:AddTab("Settings", "settings"),
        Info = nT:AddTab("Info", "info"),
        Player = nT:AddTab("Player", "person-standing"),
        Main = nT:AddTab("Main", "hammer")
    }
end
nL = fn685
for k, v in pairs(nT) do
    if k ~= "Info" then
        nL(v)
    end
end
nE, nk, ng = nil, nil, nil
u3_7 = fn299
nE = "Unknown"
pcall(fn757)
nJ = u3_7()
nk = os.clock()
ng = fn394
Label, Label2, mF = nil, nil, nil
nK = nT.Info:AddLeftGroupbox("User", "circle-user")
nK:AddLabel(nB("User", LocalPlayer.DisplayName .. " @" .. LocalPlayer.Name, mC), true)
nK:AddLabel(nB("UserId", tostring(LocalPlayer.UserId), nM), true)
nK:AddLabel(nB("Executor", nE .. "  " .. nJ, mC), true)
nK:AddDivider()
Label = nK:AddLabel(nB("Session", ng(), mw), true)
nK:AddDivider()
nK:AddButton({ Text = "Copy Username", Func = onCopyUsername })
nK:AddButton({ Text = "Copy Profile Link", Func = onCopyProfileLink })
nU = nT.Info:AddRightGroupbox("Session", "signal")
nU:AddDivider("Server")
nU:AddLabel(nB("Game", nQ_1, nM), true)
Label2 = nU:AddLabel(nB("Players", "0/0", mC), true)
mF = tostring(game.JobId)
nP = #mF > 18
if nP then
    u3_11 = 3
    repeat
        u3_7 = (vector.create((u3_11 * 1 + 1) % 11 + 1, (u3_11 * 6 + 8) % 13 + 1, (u3_11 * 10 + 11) % 17 + 1))
        nJ = (vector.create((u3_11 * 7 + 6) % 11 + 1, (u3_11 * 7 + 4) % 13 + 1, (u3_11 * 11 + 4) % 17 + 1))
        nK = (vector.create((u3_11 * 2 + 3) % 5 + 1, (u3_11 * 2 + 1) % 7 + 1, (u3_11 * 2 + 2) % 9 + 1))
        if math.abs((vector.angle(u3_7, nJ, nK))) - math.abs((vector.angle(nJ, u3_7, nK))) == 0 then
            nP = string.sub(mF, 1, 18) .. "..."
        else
            mF = string.sub(nP, 1, 18) .. "..."
        end
        u3_11 = (u3_11 + 0) % 4
    until (u3_11 * 1 + 0) % 4 == 3
end
u3_11 = nP or mF
Label3 = nil
u3_7 = u3_11
nU:AddLabel(nB("Job", u3_7, nN), true)
Label3 = nU:AddLabel(nB("Ping", "0 ms", mw), true)
nU:AddDivider()
nU:AddButton({ Text = "Rejoin Server", Func = onRejoinServer })
nU:AddButton({ Text = "Copy Job ID", Func = onCopyJobID })
task.spawn(worker2)
nJ = nT.Info:AddRightGroupbox("Socials", "link")
nJ:AddButton({ Text = "Discord", Func = m7 })
nJ:AddButton({ Text = "Rscripts", Func = onRscripts })
nJ:AddButton({ Text = "Website", Func = onWebsite })
nM = nT.Main:AddLeftGroupbox("Automation", "bot")
nM:AddToggle("AutoBuyMetal", { Text = "Auto Buy Metal", Default = false })
nM:AddDropdown("BuyMetal", { Text = "Metal", Values = nS, Default = "Copper" })
nM:AddDivider("Smelt")
nM:AddToggle("AutoSmeltMetal", { Text = "Auto Smelt Metal", Default = false })
nM:AddDropdown("SmeltRarities", { Text = "Rarity", Values = nR, Default = nR, Multi = true })
nM:AddDropdown("SmeltMetals", { Text = "Metal Type", Values = nS, Default = nS, Multi = true })
nM:AddToggle("AutoSmithMetal", { Text = "Auto Smith Metal", Default = false })
nM:AddToggle("AutoDepositWeapon", { Text = "Auto Deposit Weapon", Default = false })
nM:AddToggle("AutoCollectCash", { Text = "Auto Collect Money", Default = false })
nL = nT.Main:AddRightGroupbox("Upgrades", "arrow-up")
nL:AddToggle("AutoUnlockForges", { Text = "Auto Unlock Forges", Default = false })
nL:AddToggle("AutoBuySmithingTime", { Text = "Auto Buy Smithing Time Upgrade", Default = false })
nL:AddToggle("AutoBuyBlueprintChest", { Text = "Auto Buy Blueprint Chest", Default = false })
u3_7 = nil
nJ = nT.Player:AddLeftGroupbox("Movement", "footprints")
if (not nJ) and (u3_7 or nJ) and (nJ and false) and (nJ or 3 or nJ and false or (not nJ or not nJ) and (not nJ or false)) and ((not nJ or false) and u3_7 or (nJ or nil) or (true or not nJ or true) and (nil or nJ)) and not ((not nJ) and (u3_7 or nJ) and (nJ and false) and (nJ or 3 or nJ and false or (not nJ or not nJ) and (not nJ or false)) and ((not nJ or false) and u3_7 or (nJ or nil) or (true or not nJ or true) and (nil or nJ))) then
    u3_7:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    u3_7:AddSlider("WalkSpeed", { Default = 32, Rounding = 0, Text = "WalkSpeed Amount", Min = 16, Max = 250 })
    u3_7:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    u3_7:AddToggle("NoClip", { Text = "NoClip", Default = false })
    u3_7:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    u3_7:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = true })
    nT = nJ.Player:AddRightGroupbox("Fly", "feather")
else
    nJ:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
    nJ:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
    nJ:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
    nJ:AddToggle("NoClip", { Text = "NoClip", Default = false })
    nJ:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
    nJ:AddToggle("InstantProximityPrompt", { Text = "Instant ProximityPrompt", Default = true })
    u3_7 = nT.Player:AddRightGroupbox("Fly", "feather")
end
u3_7:AddToggle("Fly", { Text = "Fly", Default = false })
u3_7:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
mq, bodyVelocity, mj, me, nq = nil, nil, nil, nil, nil
mq = false
bodyVelocity = nil
mj = {}
me = fn319
nq = fn30
Toggles.Fly:OnChanged(fn714)
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
UserInputService.JumpRequest:Connect(onJumpRequest)
RunService.Stepped:Connect(onStepped)
RunService.RenderStepped:Connect(function()
    if Library.Unloaded then
        return
    end
    if m_("WalkSpeedEnabled") then
        local tw_1 = mo()
        if tw_1 then
            tw_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    local tw_2 = m_("Fly") and mq
    if tw_2 and bodyVelocity then
        local tw_3 = nC()
        local CurrentCamera = Workspace.CurrentCamera
        if tw_3 and CurrentCamera then
            local tw_4 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                tw_4 += CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                tw_4 -= CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                tw_4 -= CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                tw_4 += CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                tw_4 += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                tw_4 -= Vector3.new(0, 1, 0)
            end
            if tw_4.Magnitude > 0 then
                bodyVelocity.Velocity = tw_4.Unit * Options.FlySpeed.Value
            else
                bodyVelocity.Velocity = Vector3.zero
            end
        end
    end
    if m_("AntiGameplayPause") then
        pcall(function()
            LocalPlayer:SetAttribute("GameplayPaused", false)
        end)
        local tv = my()
        if tv then
            pcall(function()
                tv:SetAttribute("GameplayPaused", false)
            end)
        end
    end
    if m_("InstantProximityPrompt") then
        local tw_5 = no()
        if tw_5 then
            for i, descendant in ipairs(tw_5:GetDescendants()) do
                local tw_6 = descendant:IsA("ProximityPrompt") and descendant.HoldDuration ~= 0
                if tw_6 then
                    descendant.HoldDuration = 0
                end
            end
        end
    end
end)
task.spawn(worker3)
u3_11 = nT.Settings:AddLeftGroupbox("Menu")
u3_11:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
nv = tick()
ns = tick()
nn = 0
Label4 = nil
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local tZ = v
        pcall(function()
            tZ:Disable()
        end)
    end
end)
m3 = function()
    if not Workspace.CurrentCamera then
        return
    end
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    ns = tick()
    nn += 1
    if Label4 then
        pcall(function()
            Label4:SetText("AFK triggers: " .. nn)
        end)
    end
end
UserInputService.InputBegan:Connect(function()
    nv = tick()
end)
UserInputService.InputChanged:Connect(function(h0)
    local UserInputType = h0.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        nv = tick()
    end
end)
u3_11:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
Label4 = u3_11:AddLabel("AFK triggers: 0")
u3_11:AddButton({
    Text = "Unload UI",
    Func = function()
        Library:Unload()
    end
})
task.spawn(function()
    while not Library.Unloaded do
        task.wait(2)
        if m_("AntiAfk") then
            local t4 = tick() - nv
            local t5 = tick() - ns
            if t4 >= 300 and t5 >= 60 then
                pcall(m3)
            else
                if t4 < 300 and t5 >= 300 then
                    pcall(m3)
                end
            end
        end
    end
end)
mP, mh, nx, mJ = nil, nil, nil, nil
Library:OnUnload(fn58)
nO:SetLibrary(Library)
nO:SetFolder("TempoHub")
nO:SaveDefault("Evil Hello Kitty")
nO:ApplyToTab(nT.Settings)
nO:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/ForgeAndSell")
u3_11 = SaveManager:BuildConfigSection(nT.Settings)
mP = fn490
mh = fn14
nx = fn816
mJ = function(iL)
    local uG
    uG = nil
    local uH = type(iL) ~= "table" or type(iL.idx) ~= "string" or type(iL.type) ~= "string" or SaveManager.Ignore[iL.idx]
    if uH then
        return false
    end
    uG = mP(iL.type, iL.idx)
    if not uG then
        return false
    end
    local uH_1 = pcall(function()
        if iL.type == "Input" then
            if type(iL.text) ~= "string" then
                return
            end
            uG:SetValue(iL.text)
        elseif iL.type == "ColorPicker" then
            uG:SetValueRGB(Color3.fromHex(iL.value), iL.transparency)
        elseif iL.type == "KeyPicker" then
            uG:SetValue({ iL.key, iL.mode, iL.modifiers })
            if iL.mode == "Toggle" and iL.toggled ~= nil then
                uG.Toggled = iL.toggled
                uG:Update()
            end
        else
            uG:SetValue(iL.value)
        end
    end)
    return uH_1
end
u3_11:AddDivider()
u3_11:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
u3_11:AddButton({ Text = "Export Config to Clipboard", Func = onExportConfigToClipboard })
u3_11:AddButton({ Text = "Import Config from Clipboard Field", Func = onImportConfigFromClipboardFie })
SaveManager:LoadAutoloadConfig()
end)(...)
