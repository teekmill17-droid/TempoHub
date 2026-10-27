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
getgenv().TempoHoodSubtitle = "MINE RNG"
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
local Label
local EquipPickaxeRemote
local h8
local Toggles
local ib
local iA
local ig
local SaveManager
local hW
local CurrentCamera
local ij
local connection
local iJ
local im
local h1
local Options
local UpgradeDataTable
local h4
local iP
local it
local h7
local connection2
local ia
local ie
local iC
local processedPickaxeDT
local ii
local RebirthDataTable
local LocalPlayer
local ZoneDataTable
local BuyZoneRemote
local h0
local Library
local BuyUpgradeRemote
local h3
local iO
local is
local client
local iv
local VirtualUser
local Zones
local UserInputService
local RebirthRemote
local iE
local ih
local hX
local RollPickaxeRemote
local ik
local h_
local iK
local io
local HttpService
local iN
local ir
local function fn3(ap, aq, ar)
    return string.format("<b>%s</b> %s %s", ap, iP("-", "#5a6070"), iP(aq, ar))
end
local function fn17(e0, e1)
    local mu_1 = (e0 == "Toggle" and Toggles or Options)[e1]
    local mt_2 = type(mu_1) == "table" and mu_1.Type == e0
    local mt_3 = mt_2 and mu_1
    local mz = if mt_3 then 1 else 0
    local mx = 1493 * mz + 3467 * (1 - mz)
    local my = 2881 * mz + 3008 * (1 - mz)
    if not ((mx * 3498 + my * 282 + mx * my) % 16777213 == 10336289) then
        mt_3 = nil
    end
    return mt_3
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local Character = LocalPlayer.Character
        if Character then
            for i, descendant in ipairs(Character:GetDescendants()) do
                local lE_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if lE_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onCopyJoinScript_JobID()
    local jX = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, h0)
    if setclipboard then
        setclipboard(jX)
    elseif toclipboard then
        toclipboard(jX)
    end
    Library:Notify("Copied join script to clipboard")
end
local function fn47()
    local mH = {}
    for i, v in ipairs({ Toggles, Options }) do
        for k, v in pairs(v) do
            local mI = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if mI then
                local mI_1 = h_(k, v)
                if mI_1 then
                    mH[#mH + 1] = mI_1
                end
            end
        end
    end
    table.sort(mH, function(fn, fo)
        if fn.type ~= fo.type then
            return fn.type < fo.type
        end
        return fn.idx < fo.idx
    end)
    return { objects = mH }
end
local function fn62()
    local Character = LocalPlayer.Character
    local lC = Character and Character:FindFirstChild("HumanoidRootPart")
    return lC
end
local function fn68()
    if not workspace.CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    iJ = tick()
end
local function onExportConfigToClipboard()
    local m1_1
    local m0_1
    m0_1, m1_1 = pcall(HttpService.JSONEncode, HttpService, iE())
    if not m0_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local m0_2 = setclipboard or toclipboard
    local m0_3 = type(m0_2) ~= "function" or not pcall(m0_2, m1_1)
    if m0_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function onInputChanged(eK)
    local UserInputType = eK.UserInputType
    local mk = UserInputType == Enum.UserInputType.MouseMovement
    local mo = if mk then 1 else 0
    local mm = 564 * mo + 3332 * (1 - mo)
    local mn = 656 * mo + 3379 * (1 - mo)
    if not ((mm * 1394 + mn * 1905 + mm * mn) % 16777213 == 2405880) then
        mk = UserInputType == Enum.UserInputType.Gamepad1
    end
    if mk then
        iN = tick()
    end
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause and Toggles.AntiGameplayPause.Value then
            h3(true)
        end
    end
end
local function fn121()
    local Character = LocalPlayer.Character
    local lw = Character and Character:FindFirstChildOfClass("Humanoid")
    return lw
end
local function onCopyLitecoinAddress()
    iK(im, "Copied Litecoin address")
end
local function autoGoBestZoneLoop()
    while not Library.Unloaded do
        if Toggles.AutoGoBestZone.Value then
            pcall(function()
                local Character = LocalPlayer.Character
                local kT = Character and Character:FindFirstChild("HumanoidRootPart")
                local kT_1 = ir()
                local kU = kT_1 and Zones:FindFirstChild(kT_1)
                local kT_2 = kU
                if kU then
                    kU = kT_2:FindFirstChild("SpawnPart")
                end
                local kV = kT
                local kW = kU
                if kV then
                    kV = kW
                end
                if kV then
                    kV = not iv(kT_2, kT.Position)
                end
                if kV then
                    kT.CFrame = CFrame.new(kW.Position + Vector3.new(0, 3, 0))
                    task.wait(0.5)
                end
            end)
        end
        task.wait(0.5)
    end
end
local function worker()
    local j2_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local j1 = math.floor(os.clock() - is)
        if j1 < 60 then
            j2_1 = j1 .. "s"
        elseif j1 < 3600 then
            j2_1 = string.format("%dm %ds", math.floor((j1) / (60)), j1 % 60)
        else
            j2_1 = string.format("%dh %dm", math.floor((j1) / (3600)), math.floor((j1 % 3600) / (60)))
        end
        Label:SetText(iC("Session time", j2_1, h8))
    end
end
local function fn169(e8, e9)
    local Type = e9.Type
    if Type == "Toggle" then
        return { idx = e8, type = "Toggle", value = e9.Value == true }
    elseif Type == "Slider" then
        return { idx = e8, type = "Slider", value = tostring(e9.Value) }
    elseif Type == "Dropdown" then
        return { idx = e8, type = "Dropdown", multi = e9.Multi == true, value = e9.Value }
    elseif Type == "Input" then
        local mB = e9.Value or ""
        return { idx = e8, type = "Input", text = tostring(mB) }
    elseif Type == "ColorPicker" then
        return { idx = e8, type = "ColorPicker", value = e9.Value:ToHex(), transparency = e9.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = e8,
            type = "KeyPicker",
            mode = e9.Mode,
            key = e9.Value,
            modifiers = e9.Modifiers,
            toggled = e9.Toggled
        }
    else
        return nil
    end
end
local function fn177()
    local jC_1
    local jB_1
    jC_1, jB_1 = nil, nil
    for k, v in client.unlockedZones() do
        local jD = ZoneDataTable[v]
        local jD_1 = jD and jD.requiredCurrency or -1
        local jE_1 = not jB_1
        if not jE_1 then
            jE_1 = jD_1 > jB_1
        end
        if jE_1 then
            jB_1 = jD_1
            jC_1 = v
        end
    end
    return jC_1
end
local function fn200()
    local jT_1
    local jS_1
    if identifyexecutor then
        jT_1, jS_1 = identifyexecutor()
        local jU = jT_1 ~= ""
        local jV = type(jT_1) == "string" and jU
        if jV then
            local jU_1 = type(jS_1) == "string" and jS_1 ~= "" and jT_1 .. " " .. jS_1
            iA = jU_1 or jT_1
        end
    end
end
local function autoClaimIndexLoop()
    while not Library.Unloaded do
        if Toggles.AutoClaimIndex.Value then
            pcall(function()
                for k in client.inventory.pickaxes() do
                    local kk = client.index.pickaxes[k]
                    local kl = kk and kk() and not kk.unlocked()
                    if kl then
                        ia:FireServer(k)
                        task.wait(0.1)
                    end
                end
            end)
        end
        task.wait(1)
    end
end
local function onCopyBitcoinAddress()
    iK(ii, "Copied Bitcoin address")
end
local function onImportConfigFromClipboardTex()
    local m6_1
    local m4 = Options.SaveManager_ImportSource.Value or ""
    local m4_1
    local m5 = tostring(m4):match("^%s*(.-)%s*$")
    if m5 == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    m4_1, m6_1 = pcall(HttpService.JSONDecode, HttpService, m5)
    local m5_1 = not m4_1 or type(m6_1) ~= "table" or type(m6_1.objects) ~= "table"
    if m5_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local m4_2 = 0
    for i, v in ipairs(m6_1.objects) do
        if it(v) then
            m4_2 += 1
        end
    end
    if m4_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local m6_2 = m4_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(m4_2, m6_2), 6)
end
local function antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk and Toggles.AntiAfk.Value then
            local mp_1 = tick() - iN
            local mq = tick() - iJ
            if mp_1 >= 300 and mq >= 60 then
                pcall(ij)
            else
                if mp_1 < 300 and mq >= 300 then
                    pcall(ij)
                end
            end
        end
    end
end
local function onInputBegan()
    iN = tick()
end
local function onCopySolanaAddress()
    iK(h7, "Copied Solana address")
end
local function fn359(ai)
    local DiscordGroup = ai:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = io })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = io })
end
local function onRscripts()
    if setclipboard then
        setclipboard(iO)
    elseif toclipboard then
        toclipboard(iO)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function fn384(am, an)
    return string.format('<font color="%s">%s</font>', an, am)
end
local function onCopyEthereumAddress()
    iK(ig, "Copied Ethereum address")
end
local function fn434(ab, ac)
    if setclipboard then
        setclipboard(ab)
    elseif toclipboard then
        toclipboard(ab)
    end
    Library:Notify(ac)
end
local function fn449()
    h3(Toggles.AntiGameplayPause.Value)
end
local function fn451()
    if not Toggles.WalkSpeedEnabled.Value then
        local l_ = ik()
        if l_ then
            l_.WalkSpeed = 16
        end
    end
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local lP_1 = ik()
        if lP_1 then
            lP_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function fn488()
    h3(false)
    connection:Disconnect()
    connection2:Disconnect()
    local ne = ik()
    if ne then
        ne.PlatformStand = false
        ne.WalkSpeed = 16
    end
    select("#", "Unloaded!")
end
local function autoEquipBestLoop()
    while not Library.Unloaded do
        if Toggles.AutoEquipBest.Value then
            pcall(function()
                local kb_1
                local ka_1
                kb_1, ka_1 = nil, -1
                for k in client.inventory.pickaxes() do
                    local kc_1 = processedPickaxeDT[k]
                    if kc_1 and kc_1.miningPower > ka_1 then
                        ka_1 = kc_1.miningPower
                        kb_1 = k
                    end
                end
                local kc_2 = kb_1 and client.equipped.pickaxe() ~= kb_1
                if kc_2 then
                    EquipPickaxeRemote:FireServer(kb_1)
                end
            end)
        end
        task.wait(0.5)
    end
end
local function fn510()
    iK(hX, "Copied Discord invite to clipboard")
end
local function onCopyVenmoLink()
    iK(hW, "Copied Venmo link")
end
local function fn531()
    if not Toggles.Fly.Value then
        local lY = ik()
        if lY then
            lY.PlatformStand = false
        end
    end
end
local function autoUnlockZonesLoop()
    while not Library.Unloaded do
        if Toggles.AutoUnlockZones.Value then
            pcall(function()
                local kI = client.unlockedZones()
                for k, v in ZoneDataTable do
                    local kJ = k ~= "Plains" and not table.find(kI, k) and client.currency() >= v.requiredCurrency
                    if kJ then
                        BuyZoneRemote:FireServer(k)
                        task.wait(0.2)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end
local function autoSellLoop()
    while not Library.Unloaded do
        if Toggles.AutoSell.Value then
            pcall(function()
                local lk = client.lockedOres()
                local ll = 0
                local lm = {}
                for k, v in client.inventory.ores() do
                    if not table.find(lk, k) then
                        lm[k] = v.quantity
                        ll += 1
                    end
                end
                if ll > 0 then
                    ie:FireServer(lm)
                end
            end)
        end
        task.wait(1)
    end
end
local function onCopyUSDTAddress()
    iK(ib, "Copied USDT address")
end
local function autoRebirthLoop()
    while not Library.Unloaded do
        if Toggles.AutoRebirth.Value then
            pcall(function()
                local ks = client.rebirth()
                local kt = RebirthDataTable[ks + 1]
                local ks_1 = kt and client.currency() >= kt.price
                if ks_1 then
                    RebirthRemote:FireServer()
                    task.wait(0.5)
                end
            end)
        end
        task.wait(0.5)
    end
end
local function onCopyPayPalLink()
    iK(h1, "Copied PayPal link")
end
local function onUnload()
    Library:Unload()
end
local function onRenderStepped(d_)
    if Library.Unloaded then
        return
    end
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local lR_1 = ik()
        if lR_1 then
            lR_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local lR_3 = h4()
        local lS = ik()
        if lR_3 and lS then
            lS.PlatformStand = true
            local lS_1 = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                lS_1 = lS_1 + CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                lS_1 = lS_1 - CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                lS_1 = lS_1 - CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                lS_1 = lS_1 + CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                lS_1 = lS_1 + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                lS_1 = lS_1 - Vector3.new(0, 1, 0)
            end
            lR_3.Velocity = Vector3.zero
            if lS_1.Magnitude > 0 then
                lR_3.CFrame = lR_3.CFrame + lS_1.Unit * Options.FlySpeed.Value * d_
            end
        end
    end
end
local function autoUpgradeLoop()
    while not Library.Unloaded do
        if Toggles.AutoUpgrade.Value then
            pcall(function()
                local kx = client.upgradesBought()
                for k, v in UpgradeDataTable do
                    local ky = not table.find(kx, k)
                    if ky ~= false then
                        local kz = v.dependency == "None" or table.find(kx, v.dependency)
                        ky = kz
                    end
                    if ky then
                        ky = client.currency() >= v.price
                    end
                    if ky then
                        BuyUpgradeRemote:FireServer(k, "Upgrades")
                        task.wait(0.1)
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end
local function autoMineLoop()
    while not Library.Unloaded do
        if Toggles.AutoMine.Value then
            pcall(function()
                local k7_1
                local k6_1
                local k5_2
                local Character = LocalPlayer.Character
                local k2 = Character and Character:FindFirstChild("HumanoidRootPart")
                local SpawnedRockModels = workspace:FindFirstChild("SpawnedRockModels")
                local k3
                if Toggles.AutoGoBestZone.Value then
                    local k4_1 = ir()
                    local k5_1 = k4_1 and Zones:FindFirstChild(k4_1)
                    k3 = k5_1
                end
                if k2 and SpawnedRockModels then
                    k7_1, k6_1, k5_2 = nil, nil, nil
                    for i, child in SpawnedRockModels:GetChildren() do
                        if client.spawnedRocks[child.Name]() then
                            local k2_2 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                            local k4_3 = k2_2
                            if k2_2 then
                                local k8_1 = k3 and not iv(k3, k4_3.Position)
                                k2_2 = not k8_1
                            end
                            if k2_2 then
                                local Magnitude = (k2.Position - k4_3.Position).Magnitude
                                if not k5_2 or Magnitude < k5_2 then
                                    k5_2 = Magnitude
                                    k7_1 = child
                                    k6_1 = k4_3
                                end
                            end
                        end
                    end
                    if k7_1 and k6_1 then
                        if k5_2 > 10 then
                            k2.CFrame = CFrame.new(k6_1.Position + Vector3.new(0, 4, 6))
                        end
                        ih:FireServer(k7_1.Name)
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end
local function autoRollLoop()
    while not Library.Unloaded do
        local j8 = Toggles.AutoRoll.Value and not LocalPlayer:GetAttribute("Spinning")
        if j8 then
            LocalPlayer:SetAttribute("Spinning", true)
            pcall(function()
                RollPickaxeRemote:FireServer()
            end)
        end
        task.wait(0.1)
    end
end
local function fn748(R, S)
    local jN = R and R:FindFirstChild("ZoneDetector")
    if not jN then
        return false
    end
    local jN_1 = jN.CFrame:PointToObjectSpace(S)
    local jP = jN.Size / 2
    local jO_1 = math.abs(jN_1.X) <= jP.X and math.abs(jN_1.Z) <= jP.Z and math.abs(jN_1.Y) <= jP.Y + 60
    return jO_1
end
processedPickaxeDT = nil
hW = nil
hX = nil
LocalPlayer = nil
connection = nil
h_ = nil
h0 = nil
h1 = nil
HttpService = nil
h3 = nil
h4 = nil
Label = nil
client = nil
h7 = nil
h8 = nil
VirtualUser = nil
ia = nil
ib = nil
UserInputService = nil
ie = nil
ig = nil
ih = nil
ii = nil
ij = nil
ik = nil
BuyZoneRemote = nil
im = nil
io = nil
BuyUpgradeRemote = nil
Options = nil
ir = nil
is = nil
it = nil
EquipPickaxeRemote = nil
iv = nil
connection2 = nil
Toggles = nil
Zones = nil
iA = nil
RebirthRemote = nil
iC = nil
SaveManager = nil
iE = nil
RebirthDataTable = nil
CurrentCamera = nil
RollPickaxeRemote = nil
ZoneDataTable = nil
iJ = nil
iK = nil
local iz
Library = nil
UpgradeDataTable = nil
iN = nil
iO = nil
iP = nil
local iT_1
Library, SaveManager, Toggles, Options = nil, nil, nil, nil
Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
if getgenv().__TempoMineRNG then
    pcall(function()
        getgenv().__TempoMineRNG:Unload()
    end)
end
UserInputService, VirtualUser, HttpService, LocalPlayer, RollPickaxeRemote, RebirthRemote, EquipPickaxeRemote, BuyUpgradeRemote, BuyZoneRemote, ih, ie, ia, client, iT_1, processedPickaxeDT, UpgradeDataTable, ZoneDataTable, RebirthDataTable, Zones, hX, iO, h8, ir, iv, iK, io, iP, iC = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
getgenv().__TempoMineRNG = Library
local Players = game:GetService("Players")
local iU = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
VirtualUser = game:GetService("VirtualUser")
HttpService = game:GetService("HttpService")
LocalPlayer = Players.LocalPlayer
local i2 = "Mine RNG"
local iW = iU:WaitForChild("Remotes")
RollPickaxeRemote = iW:WaitForChild("RollPickaxeRemote")
RebirthRemote = iW:WaitForChild("RebirthRemote")
EquipPickaxeRemote = iW:WaitForChild("EquipPickaxeRemote")
BuyUpgradeRemote = iW:WaitForChild("BuyUpgradeRemote")
if (not iC and processedPickaxeDT or false and iT_1) and (not processedPickaxeDT or not iT_1 or iT_1 and processedPickaxeDT) and not ((not iC and processedPickaxeDT or false and iT_1) and (not processedPickaxeDT or not iT_1 or iT_1 and processedPickaxeDT)) then
    iW = BuyZoneRemote:WaitForChild("BuyZoneRemote")
    ia = BuyZoneRemote:WaitForChild("HitRockRemote")
    ih = BuyZoneRemote:WaitForChild("SellOresRemote")
    ie = BuyZoneRemote:WaitForChild("UnlockIndexRemote")
else
    BuyZoneRemote = iW:WaitForChild("BuyZoneRemote")
    ih = iW:WaitForChild("HitRockRemote")
    ie = iW:WaitForChild("SellOresRemote")
    ia = iW:WaitForChild("UnlockIndexRemote")
end
if (RebirthDataTable or RebirthDataTable or iW and not RebirthDataTable or not iW and not iW and (RebirthDataTable and RebirthDataTable) or (not iW and iW and (iW and iW) or (not iW or not iW or not RebirthDataTable and RebirthDataTable))) and ((iW or iW or (iW or RebirthDataTable)) and ((not iW or RebirthDataTable) and (RebirthDataTable or RebirthDataTable)) and ((RebirthDataTable or iW) and (not iW and not iW) and (not iW and not iW or (not iW or not RebirthDataTable)))) and not ((RebirthDataTable or RebirthDataTable or iW and not RebirthDataTable or not iW and not iW and (RebirthDataTable and RebirthDataTable) or (not iW and iW and (iW and iW) or (not iW or not iW or not RebirthDataTable and RebirthDataTable))) and ((iW or iW or (iW or RebirthDataTable)) and ((not iW or RebirthDataTable) and (RebirthDataTable or RebirthDataTable)) and ((RebirthDataTable or iW) and (not iW and not iW) and (not iW and not iW or (not iW or not RebirthDataTable))))) then
    iU = require(client:WaitForChild("PlayerData")).client
else
    client = require(iU:WaitForChild("PlayerData")).client
end
local DataTables = iU:WaitForChild("DataTables")
processedPickaxeDT = require(DataTables:WaitForChild("processedPickaxeDT"))
UpgradeDataTable = require(DataTables:WaitForChild("UpgradeDataTable"))
ZoneDataTable = require(DataTables:WaitForChild("ZoneDataTable"))
RebirthDataTable = require(DataTables:WaitForChild("RebirthDataTable"))
Zones = workspace:WaitForChild("Zones")
ir = fn177
iv = fn748
hX = "https://discord.gg/K7Qxnxkk46"
iO = "https://discord.gg/K7Qxnxkk46"
iK = fn434
io = fn510
local DonationsGroup
iP = fn384
iC = fn3
local i_ = "#7fd47f"
local iZ = "#6ec1ff"
h8 = "#e8a34d"
local iY = "#8b93a3"
local Window = Library:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = hX, Copyable = true }, "|", i2 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local i1 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "pickaxe"),
    Player = Window:AddTab("Player", "person-standing"),
    Settings = Window:AddTab("Settings", "settings")
}
for k, v in i1 do
    fn359(v)
end
iA, Label, h0 = nil, nil, nil
iA = "Unknown"
pcall(fn200)
local AccountGroup = i1.Info:AddLeftGroupbox("Account", "circle-user")
AccountGroup:AddLabel(iC("User", LocalPlayer.Name, i_), true)
AccountGroup:AddLabel(iC("Status", "Keyless", i_), true)
AccountGroup:AddLabel(iC("Executor", iA, i_), true)
local GameInfoGroup = i1.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameInfoGroup:AddLabel(iP(i2 .. " [" .. tostring(game.PlaceId) .. "]", iZ), true)
GameInfoGroup:AddLabel(iC("Place ID", tostring(game.PlaceId), iZ), true)
Label = GameInfoGroup:AddLabel(iC("Session time", "0s", h8), true)
h0 = tostring(game.JobId)
local iT_3 = #h0 > 18
if iT_3 then
    local iQ_2 = 4
    repeat
        local nO = bit32.rrotate(bit32.bxor(bit32.lrotate(iQ_2, 29), string.byte(tostring(iQ_2))), 30)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(nO, 1624403907), 2153987088), (bit32.bxor(bit32.band(nO, 2670563388), 2805591765))), 2153987088), 2805591765) == nO then
            iT_3 = string.sub(h0, 1, 18) .. "..."
        else
            h0 = string.sub(iT_3, 1, 18) .. "..."
        end
        iQ_2 = (iQ_2 + 4) % 8
    until (iQ_2 * 5 + 2) % 8 == 2
end
local iQ_3 = iT_3
local jr = if iQ_3 then 1 else 0
local jp = 1275 * jr + 3078 * (1 - jr)
local jq = 611 * jr + 2672 * (1 - jr)
if not ((jp * 821 + jq * 894 + jp * jq) % 16777213 == 2372034) then
    iQ_3 = h0
end
is, im, ii, ig, ib, h7, h1, hW, DonationsGroup, CurrentCamera, iN, iJ, connection, connection2, ik, h4, h3, ij, iz, h_, iE, it = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local jg = iQ_3
GameInfoGroup:AddLabel(iC("Server", jg, iY), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
is = os.clock()
task.spawn(worker)
local ScriptsGroup = i1.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(iP("Included in this hub", iY), true)
ScriptsGroup:AddLabel(iP(i2, iZ), true)
local FeaturesGroup = i1.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(iP("Auto Roll & Rebirth", iZ), true)
FeaturesGroup:AddLabel(iP("Auto Mine & Sell", h8), true)
FeaturesGroup:AddLabel(iP("Auto Upgrade & Zones", i_), true)
FeaturesGroup:AddLabel(iP("Auto Equip & Index", iY), true)
local SocialsGroup = i1.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = io })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = i1.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = io })
im = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
ii = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
ig = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
ib = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
h7 = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
h1 = ""
hW = ""
local jh = "#345d9d"
local jd = "#f7931a"
local ja = "#627eea"
local i9 = "#26a17b"
local i7 = "#14f195"
local i4 = "#0070ba"
local i3 = "#008cff"
if (not FeaturesGroup and FeaturesGroup or (not FeaturesGroup or not FeaturesGroup) or (not connection2 or false) and (not FeaturesGroup or not connection2)) and not (not FeaturesGroup and FeaturesGroup or (not FeaturesGroup or not FeaturesGroup) or (not connection2 or false) and (not FeaturesGroup or not connection2)) then
    i1 = DonationsGroup.Info:AddRightGroupbox("Donations", "heart")
else
    DonationsGroup = i1.Info:AddRightGroupbox("Donations", "heart")
end
DonationsGroup:AddLabel(iP("All donations are optional but appreciated.", h8), true)
DonationsGroup:AddLabel(iP("If you donate you get a special role, just PING after you donate.", i_), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(iP("LTC / Litecoin", jh), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(iP("BTC / Bitcoin", jd), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = onCopyBitcoinAddress })
DonationsGroup:AddLabel(iP("ETH / Ethereum", ja), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(iP("USDT", i9), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = onCopyUSDTAddress })
DonationsGroup:AddLabel(iP("Solana", i7), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = onCopySolanaAddress })
DonationsGroup:AddLabel(iP("PayPal", i4), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(iP("Venmo", i3), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(iP("Don't have any of the listed currencies but still wanna donate?", iY), true)
DonationsGroup:AddLabel(iP("DM me and we'll work something out.", iZ), true)
local FaqGroup = i1.Info:AddRightGroupbox("FAQ", "circle-help")
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
local Rolling_PickaxeGroup = i1.Main:AddLeftGroupbox("Rolling & Pickaxe", "dices")
Rolling_PickaxeGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
Rolling_PickaxeGroup:AddToggle("AutoEquipBest", { Text = "Auto Equip Best Pickaxe", Default = false })
Rolling_PickaxeGroup:AddToggle("AutoClaimIndex", { Text = "Auto Claim Index", Default = false })
local ProgressionGroup = i1.Main:AddRightGroupbox("Progression", "trending-up")
ProgressionGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
ProgressionGroup:AddToggle("AutoUpgrade", { Text = "Auto Upgrade", Default = false })
ProgressionGroup:AddToggle("AutoUnlockZones", { Text = "Auto Unlock Zones", Default = false })
local Mining_SellingGroup = i1.Main:AddLeftGroupbox("Mining & Selling", "gem")
Mining_SellingGroup:AddToggle("AutoGoBestZone", { Text = "Auto Go to Best Owned Zone", Default = false })
Mining_SellingGroup:AddToggle("AutoMine", { Text = "Auto Mine Ores", Default = false })
Mining_SellingGroup:AddToggle("AutoSell", { Text = "Auto Sell Ores", Default = false })
task.spawn(autoRollLoop)
task.spawn(autoEquipBestLoop)
task.spawn(autoClaimIndexLoop)
task.spawn(autoRebirthLoop)
task.spawn(autoUpgradeLoop)
task.spawn(autoUnlockZonesLoop)
task.spawn(autoGoBestZoneLoop)
task.spawn(autoMineLoop)
task.spawn(autoSellLoop)
local MovementGroup = i1.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = i1.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
ik = fn121
h4 = fn62
RunService.Stepped:Connect(onStepped)
UserInputService.JumpRequest:Connect(onJumpRequest)
CurrentCamera = workspace.CurrentCamera
RunService.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fn531)
Toggles.WalkSpeedEnabled:OnChanged(fn451)
h3 = function(ek)
    pcall(function()
        game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(not ek)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = game:GetService("CoreGui"):FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not ek
        end
    end)
    if not ek then
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
Toggles.AntiGameplayPause:OnChanged(fn449)
task.spawn(antiGameplayPauseLoop)
local MenuGroup = i1.Settings:AddLeftGroupbox("Menu", "menu")
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", onUnload)
iN = tick()
iJ = tick()
pcall(function()
    for i, v in ipairs(getconnections(LocalPlayer.Idled)) do
        local mg = v
        pcall(function()
            mg:Disable()
        end)
    end
end)
ij = fn68
connection = UserInputService.InputBegan:Connect(onInputBegan)
connection2 = UserInputService.InputChanged:Connect(onInputChanged)
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
task.spawn(antiAfkLoop)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(i1.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/MineRNG")
local jb = SaveManager:BuildConfigSection(i1.Settings)
iz = fn17
h_ = fn169
iE = fn47
it = function(fq)
    local mY
    mY = nil
    local mZ = type(fq) ~= "table" or type(fq.idx) ~= "string" or type(fq.type) ~= "string" or SaveManager.Ignore[fq.idx]
    if mZ then
        return false
    end
    mY = iz(fq.type, fq.idx)
    if not mY then
        return false
    end
    local mZ_1 = pcall(function()
        if fq.type == "Input" then
            if type(fq.text) ~= "string" then
                return
            end
            mY:SetValue(fq.text)
        elseif fq.type == "ColorPicker" then
            mY:SetValueRGB(Color3.fromHex(fq.value), fq.transparency)
        elseif fq.type == "KeyPicker" then
            mY:SetValue({ fq.key, fq.mode, fq.modifiers })
            if fq.mode == "Toggle" and fq.toggled ~= nil then
                mY.Toggled = fq.toggled
                mY:Update()
            end
        else
            mY:SetValue(fq.value)
        end
    end)
    return mZ_1
end
jb:AddDivider()
jb:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
jb:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
jb:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
Library:OnUnload(fn488)
end)(...)
