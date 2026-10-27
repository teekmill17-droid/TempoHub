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
getgenv().TempoHoodSubtitle = "COWS RNG"
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
local uL_3, ThemeManager, uL_6, uL_7, uL_8, uL_19, uL_20, uL_23, uL_25, uL_26, uL_27, uL_30, uL_34, uL_35, uL_36, uL_39, uL_40
local mW
local nD
local nk
local mk
local m1
local GameConfig
local Library
local mq
local m7
local mP
local nw
local mw
local Workspace
local mV
local mC
local nj
local mI
local mp
local Options
local mO
local nv
local mv
local nc
local mU
local nB
local mB
local ni
local m_
local mo
local m5
local mN
local nu
local mu
local nb
local mT
local nA
local mZ
local nn
local m4
local mM
local nt
local mt
local Toggles
local mS
local nz
local mz
local SaveManager
local mY
local mF
local nm
local mm
local m3
local mL
local Label
local ms
local m9
local mR
local ny
local my
local nf
local mX
local mE
local nl
local ml
local connection2
local mK
local connection
local mr
local m8
local mQ
local MountainMelt
local mx
local ne
function fns.fn32(ay, az)
    return string.format('<font color="%s">%s</font>', az, ay)
end
function fns.onOnClientEvent(bf, bg)
    if bf == "full" then
        mR = bg
        return
    end
    if not mR then
        return
    end
    local pk = bf == "melt" and type(bg) == "table"
    local pk_3
    if pk then
        if bg.stage then
            mR.stage = bg.stage
        end
        if bg.level and mR.walls then
            mR.walls[bg.level] = bg.remaining
        end
        local pl_1 = bg.released or {}
        for k, v in pl_1 do
            if typeof(v) == "table" then
                pk_3 = v.idx
            else
                pk_3 = v
            end
            local pk_4 = mR.items and mR.items[pk_3]
            if pk_4 then
                pk_4.released = true
                local pk_5 = typeof(v) == "table" and v.key
                if pk_5 then
                    pk_4.key = v.key
                end
            end
        end
    else
        local pk_6 = bf == "claimed" and type(bg) == "table"
        if pk_6 then
            local pk_7 = mR.items and mR.items[bg.idx]
            if pk_7 then
                pk_7.claimed = true
            end
        end
    end
end
function fns.fn41()
    local pe = nB()
    local pf = pe and pe:FindFirstChild("HumanoidRootPart")
    return pf
end
function fns.fn49(ed)
    local rk = GameConfig.ZoneWall(ed)
    if not rk then
        return nil
    end
    local rl = GameConfig.WallThickness(ed)
    local rm = mC(ed)
    local rn = GameConfig.WallNearZ(ed)
    local ro = rn + (rl - rm)
    local rl_1 = nn()
    local rm_2 = (rl_1 and rl_1.range or 10) + nA
    local rl_3 = ro - math.clamp(rm_2 * 0.35, 4, 10)
    if rk.ground then
        rl_3 = math.clamp(rl_3, rk.ground.minZ + 2, rk.ground.maxZ - 2)
    end
    local rl_4 = math.min(rl_3, ro + 4)
    return CFrame.new(rk.centerX, 3, rl_4)
end
function fns.sellDelayLoop()
    while not Library.Unloaded do
        if ms("AutoSell") then
            pcall(nu)
            local sO = Options.SellDelay and Options.SellDelay.Value or 1
            task.wait(sO)
        else
            task.wait(0.25)
        end
    end
end
function fns.worker3()
    while not Library.Unloaded do
        if ms("AutoBuyUpgrades") then
            pcall(mq)
            task.wait(0.35)
        else
            task.wait(0.25)
        end
    end
end
function fns.fn101()
    return mw()[1]
end
function fns.onCopyBitcoinAddress()
    m1(m8, "Copied Bitcoin address")
end
function fns.antiAfkLoop()
    while not Library.Unloaded do
        task.wait(2)
        if Toggles.AntiAfk.Value then
            local tf = tick() - mF
            local tg = tick() - mB
            if tf >= 300 and tg >= 60 then
                pcall(ml)
            else
                if tf < 300 and tg >= 300 then
                    pcall(ml)
                end
            end
        end
    end
end
function fns.fn138()
    local p3 = mE and os.clock() - mz < 5
    if p3 then
        return mE
    end
    local p3_1 = {}
    local Map = Workspace:FindFirstChild("Map")
    if Map then
        for i, descendant in Map:GetDescendants() do
            local p4_1 = descendant.Name == "CollectMedals" and descendant:IsA("BasePart")
            if p4_1 then
                p3_1[#p3_1 + 1] = descendant
            end
        end
        table.sort(p3_1, function(ch, ci)
            local pY = (tonumber(ch:GetAttribute("ZoneReward")))
            local p2 = if pY then 1 else 0
            local p0 = 2190 * p2 + 2565 * (1 - p2)
            local p1 = 1316 * p2 + 3768 * (1 - p2)
            if not ((p0 * 2551 + p1 * 1493 + p0 * p1) % 16777213 == 10433518) then
                pY = 0
            end
            local pZ = tonumber(ci:GetAttribute("ZoneReward")) or 0
            return pY > pZ
        end)
    end
    mE = p3_1
    mz = os.clock()
    return p3_1
end
function fns.fn139()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then
        return
    end
    nw:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    nw:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    mB = tick()
end
function fns.fn159(iz, iA)
    local tR_1 = (iz == "Toggle" and Toggles or Options)[iA]
    local tQ_2 = type(tR_1) == "table" and tR_1.Type == iz
    return tQ_2 and tR_1 or nil
end
function fns.fn173()
    local ra
    local q5 = mS()
    local q9 = q5
    local q7 = mu
    while true do
        if not (q9 <= q7) then
            return q5
        end
        ra = q9
        if mC(ra) > 0.15 then
            break
        end
        q9 += 1
    end
    return ra
end
function fns.onOnClientEvent2(bd)
    mV = bd
end
function fns.onInputBegan()
    mF = tick()
end
function fns.worker5()
    while not Library.Unloaded do
        if ms("AutoBuyBackpacks") then
            pcall(nk)
            task.wait(0.5)
        else
            task.wait(0.25)
        end
    end
end
function fns.onCopySolanaAddress()
    m1(mU, "Copied Solana address")
end
function fns.fn195()
    local sk_1
    local sj_1
    if identifyexecutor then
        sk_1, sj_1 = identifyexecutor()
        local sl = sk_1 ~= ""
        local sm = type(sk_1) == "string" and sl
        if sm then
            local sl_1 = type(sj_1) == "string" and sj_1 ~= "" and sk_1 .. " " .. sj_1
            mr = sl_1 or sk_1
        end
    end
end
function fns.worker2()
    while not Library.Unloaded do
        local sC = ms("AutoMelt") and not ms("AutoFarmMelt")
        if sC then
            pcall(function()
                MountainMelt:FireServer()
            end)
            task.wait(0.1)
        else
            task.wait(0.25)
        end
    end
end
function fns.fn251()
    local qc = nc()
    if not (qc and firetouchinterest) then
        return
    end
    local qd_1 = nf()
    if not qd_1 then
        return
    end
    pcall(firetouchinterest, qd_1, qc, 0)
    pcall(firetouchinterest, qd_1, qc, 1)
end
function fns.collectDelayLoop()
    while not Library.Unloaded do
        if ms("AutoFarmMelt") then
            local sx = mY()
            if sx == "collect" then
                local wait = task.wait
                local sA = Options.CollectDelay and Options.CollectDelay.Value or 0.15
                wait(sA)
            else
                if sx == "full" or sx == "weapon" then
                    task.wait(0.5)
                else
                    task.wait(0.1)
                end
            end
        else
            task.wait(0.25)
        end
    end
end
function fns.fn268(cw)
    return GameConfig.BackpackById and GameConfig.BackpackById[cw] or nil
end
function fns.fn279()
    local rt = mR
    local ru = {}
    if rt then
        rt = type(mR.items) == "table"
    end
    if not rt then
        return ru
    end
    for k, v in mR.items do
        local rt_1 = v and v.released and not v.claimed and v.key and type(v.x) == "number" and type(v.z) == "number" and my(v.key, "CollectMode", "CollectRarities", "CollectItems")
        if rt_1 then
            local rt_2 = #ru + 1
            local rw = v.x
            local rx = v.y or 3
            ru[rt_2] = { idx = k, item = v, pos = Vector3.new(rw, rx, v.z) }
        end
    end
    return ru
end
function fns.fn281(iH, iI)
    local Type = iI.Type
    if Type == "Toggle" then
        return { idx = iH, type = "Toggle", value = iI.Value == true }
    elseif Type == "Slider" then
        return { idx = iH, type = "Slider", value = tostring(iI.Value) }
    elseif Type == "Dropdown" then
        return { idx = iH, type = "Dropdown", multi = iI.Multi == true, value = iI.Value }
    elseif Type == "Input" then
        local tY = iI.Value or ""
        return { idx = iH, type = "Input", text = tostring(tY) }
    elseif Type == "ColorPicker" then
        return { idx = iH, type = "ColorPicker", value = iI.Value:ToHex(), transparency = iI.Transparency }
    elseif Type == "KeyPicker" then
        return {
            idx = iH,
            type = "KeyPicker",
            mode = iI.Mode,
            key = iI.Value,
            modifiers = iI.Modifiers,
            toggled = iI.Toggled
        }
    else
        return nil
    end
end
function fns.fn288()
    connection:Disconnect()
    connection2:Disconnect()
    mx(false)
    select("#", "Unloaded!")
end
function fns.fn292()
    local pb = nB()
    local pc = pb and pb:FindFirstChildOfClass("Humanoid")
    return pc
end
function fns.onCopyUSDTAddress()
    m1(mZ, "Copied USDT address")
end
function fns.fn341()
    local rc = nB()
    local rd = rc and rc:FindFirstChildOfClass("Tool")
    if rd then
        local attr = rd:GetAttribute("WeaponId")
        if attr and GameConfig.WeaponById then
            return GameConfig.WeaponById[attr], rd
        end
        return nil, rd
    end
    return nil, rd
end
function fns.fn350()
    if not Toggles.Fly.Value then
        local tJ = nv()
        if tJ then
            tJ.PlatformStand = false
        end
    end
end
local function onImportConfigFromClipboardTex()
    local uw_1
    local uu = Options.SaveManager_ImportSource.Value or ""
    local uu_1
    local uv = tostring(uu):match("^%s*(.-)%s*$")
    if uv == "" then
        Library:Notify("Paste an exported config into the box first")
        return
    end
    uu_1, uw_1 = pcall(nt.JSONDecode, nt, uv)
    local uv_1 = not uu_1 or type(uw_1) ~= "table" or type(uw_1.objects) ~= "table"
    if uv_1 then
        Library:Notify("That is not a valid exported config")
        return
    end
    local uu_2 = 0
    for k, v in uw_1.objects do
        if mk(v) then
            uu_2 += 1
        end
    end
    if uu_2 == 0 then
        Library:Notify("No settings in that config matched this script")
        return
    end
    Options.SaveManager_ImportSource:SetValue("")
    local uw_2 = uu_2 == 1 and "" or "s"
    Library:Notify(("Imported %d setting%s"):format(uu_2, uw_2), 6)
end
local function fn354(aB, aC, aD)
    return string.format("<b>%s</b> %s %s", aB, mv("-", "#5a6070"), mv(aC, aD))
end
local function fn367(bv)
    local pz = Options[bv]
    local pA = {}
    if not pz then
        return pA
    end
    local Value = pz.Value
    if type(Value) ~= "table" then
        return pA
    end
    for k, v in Value do
        if v == true then
            pA[k] = true
        else
            local pz_1 = type(k) == "number" and type(v) == "string"
            if pz_1 then
                pA[v] = true
            end
        end
    end
    return pA
end
local function fn370(an, ao)
    if setclipboard then
        setclipboard(an)
    elseif toclipboard then
        toclipboard(an)
    end
    Library:Notify(ao)
end
local function onJumpRequest()
    if Library.Unloaded then
        return
    end
    if Toggles.InfJump and Toggles.InfJump.Value then
        local tz_1 = nv()
        if tz_1 then
            tz_1:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end
local function worker()
    local su_1
    while true do
        task.wait(1)
        if Library.Unloaded then
            break
        end
        local st = math.floor(os.clock() - mW)
        if st < 60 then
            su_1 = st .. "s"
        elseif st < 3600 then
            su_1 = string.format("%dm %ds", math.floor((st) / (60)), st % 60)
        else
            su_1 = string.format("%dh %dm", math.floor((st) / (3600)), math.floor((st % 3600) / (60)))
        end
        Label:SetText(mm("Session time", su_1, nj))
    end
end
local function fn481(bW)
    local pN = not bW
    local pO = 0
    if not pN then
        pN = type(bW.Items) ~= "table"
    end
    if pN then
        return 0
    end
    for k, v in bW.Items do
        if type(v) == "number" then
            pO += v
        end
    end
    return pO
end
local function worker6()
    while not Library.Unloaded do
        if ms("AutoBuyPotions") then
            pcall(ny)
            task.wait(1)
        else
            task.wait(0.25)
        end
    end
end
local function fn561(au)
    local DiscordGroup = au:AddLeftGroupbox("Discord")
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = mK })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = mK })
end
local function fn564()
    local rh_1
    local rg_1
    rg_1, rh_1 = nn()
    if rh_1 then
        return true
    end
    local Backpack = m9:FindFirstChild("Backpack")
    local rh_2 = Backpack and Backpack:FindFirstChildOfClass("Tool")
    local rh_3 = nv()
    if rh_2 and rh_3 then
        rh_3:EquipTool(rh_2)
        return true
    end
    return false
end
local function fn573()
    local q0 = Options.FarmStage and Options.FarmStage.Value
    if type(q0) == "number" then
        return math.clamp(math.floor(q0), 1, mu)
    elseif type(q0) == "string" then
        local q0_1 = tonumber(string.match(q0, "%d+"))
        if q0_1 then
            return math.clamp(q0_1, 1, mu)
        end
        return 1
    else
        return 1
    end
end
local function fn598()
    m1(mX, "Copied Discord invite to clipboard")
end
local function fn613(bE)
    local bG, bH = GameConfig.SellValueFor(bE)
    return bH
end
local function fn621(cs)
    return GameConfig.WeaponById and GameConfig.WeaponById[cs] or nil
end
local function fn644()
    if not Toggles.WalkSpeedEnabled.Value then
        local tO = nv()
        if tO then
            tO.WalkSpeed = 16
        end
    end
end
local function onStepped()
    if Library.Unloaded then
        return
    end
    if Toggles.NoClip and Toggles.NoClip.Value then
        local tr_1 = nB()
        if tr_1 then
            for i, descendant in ipairs(tr_1:GetDescendants()) do
                local tr_2 = descendant:IsA("BasePart") and descendant.CanCollide
                if tr_2 then
                    descendant.CanCollide = false
                end
            end
        end
    end
end
local function onCopyJoinScript_JobID()
    local sr = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, nl)
    if setclipboard then
        setclipboard(sr)
    elseif toclipboard then
        toclipboard(sr)
    end
    Library:Notify("Copied join script to clipboard")
end
local function onRenderStepped(h6)
    if Library.Unloaded then
        return
    end
    m4 = Workspace.CurrentCamera
    if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
        local tB_1 = nv()
        if tB_1 then
            tB_1.WalkSpeed = Options.WalkSpeed.Value
        end
    end
    if Toggles.Fly and Toggles.Fly.Value then
        local tB_3 = nc()
        local tC = nv()
        if tB_3 and tC and m4 then
            tC.PlatformStand = true
            local tC_1 = Vector3.zero
            if nz:IsKeyDown(Enum.KeyCode.W) then
                tC_1 = tC_1 + m4.CFrame.LookVector
            end
            local tI = if nz:IsKeyDown(Enum.KeyCode.S) then 1 else 0
            if tI == 1 then
                tC_1 = tC_1 - m4.CFrame.LookVector
            end
            if nz:IsKeyDown(Enum.KeyCode.A) then
                tC_1 = tC_1 - m4.CFrame.RightVector
            end
            if nz:IsKeyDown(Enum.KeyCode.D) then
                tC_1 = tC_1 + m4.CFrame.RightVector
            end
            if nz:IsKeyDown(Enum.KeyCode.Space) then
                tC_1 = tC_1 + Vector3.new(0, 1, 0)
            end
            local tI_1 = if nz:IsKeyDown(Enum.KeyCode.LeftControl) then 1 else 0
            if tI_1 == 1 then
                tC_1 = tC_1 - Vector3.new(0, 1, 0)
            end
            tB_3.Velocity = Vector3.zero
            if tC_1.Magnitude > 0 then
                tB_3.CFrame = tB_3.CFrame + tC_1.Unit * Options.FlySpeed.Value * h6
            end
        end
    end
end
local function fn692()
    return #mO() > 0
end
local function fn699()
    return m9.Character
end
local function onCopyEthereumAddress()
    m1(m3, "Copied Ethereum address")
end
local function onCopyPayPalLink()
    m1(mQ, "Copied PayPal link")
end
local function worker7()
    while not Library.Unloaded do
        task.wait(5)
        pcall(function()
            mN.RequestData:FireServer()
        end)
        if not mR then
            pcall(function()
                mN.MountainState:FireServer()
            end)
        end
    end
end
local function fn789(b1)
    if not b1 then
        return true
    end
    local pW = GameConfig.BackpackCapacityFor(b1)
    if type(pW) ~= "number" then
        return false
    end
    return ne(b1) >= pW
end
local function worker4()
    while not Library.Unloaded do
        if ms("AutoBuyWeapons") then
            pcall(m7)
            task.wait(0.5)
        else
            task.wait(0.25)
        end
    end
end
local function collectDelayLoop2()
    while not Library.Unloaded do
        if ms("AutoCollectLoot") then
            pcall(mp)
            local sK = Options.CollectDelay and Options.CollectDelay.Value or 0.2
            task.wait(sK)
        else
            task.wait(0.25)
        end
    end
end
local function fn831()
    local t3 = {}
    for k, v in { Toggles, Options } do
        for k, v in v do
            local t4 = type(v) == "table" and type(v.Type) == "string" and not SaveManager.Ignore[k]
            if t4 then
                local t4_1 = ni(k, v)
                if t4_1 then
                    t3[#t3 + 1] = t4_1
                end
            end
        end
    end
    table.sort(t3, function(iU, iV)
        if iU.type ~= iV.type then
            return iU.type < iV.type
        end
        return iU.idx < iV.idx
    end)
    return { objects = t3 }
end
local function fn839(bJ, bK, bL, bM)
    local pK = Options[bK] and Options[bK].Value or "All"
    if pK == "All" then
        return true
    end
    local pK_1 = mI(bJ)
    if not pK_1 then
        return false
    elseif pK == "Rarity" then
        local pL = nm(bL)
        return pL[pK_1.rarity] == true
    elseif pK == "Selected" then
        local pJ_2 = nm(bM)
        return pJ_2[pK_1.name] == true
    else
        return false
    end
end
local function fn855()
    local r5 = ms("AutoCollectLoot") and mt()
    if r5 then
        return "collect"
    elseif mP(mV) then
        return "full"
    elseif not mM() then
        return "weapon"
    elseif not mR then
        pcall(function()
            mN.MountainState:FireServer()
        end)
        return "state"
    else
        local r5_1 = nD()
        local r6 = mo(r5_1)
        local r5_2 = nc()
        if not (r6 and r5_2) then
            return "move"
        end
        if (r5_2.Position - r6.Position).Magnitude > 5 then
            r5_2.CFrame = r6
            task.wait(0.12)
        end
        pcall(function()
            MountainMelt:FireServer()
        end)
        return "melt"
    end
end
local function onUnload()
    Library:Unload()
end
local function fn909()
    mx(Toggles.AntiGameplayPause.Value)
end
local function onInputChanged(hq)
    local UserInputType = hq.UserInputType
    local ta = UserInputType == Enum.UserInputType.MouseMovement
    local te = if ta then 1 else 0
    local tc = 39 * te + 3298 * (1 - te)
    local td = 2043 * te + 1694 * (1 - te)
    if not ((tc * 833 + td * 514 + tc * td) % 16777213 == 1162266) then
        ta = UserInputType == Enum.UserInputType.Gamepad1
    end
    if ta then
        mF = tick()
    end
end
local function onRscripts()
    if setclipboard then
        setclipboard(mT)
    elseif toclipboard then
        toclipboard(mT)
    end
    Library:Notify("Copied Rscripts profile to clipboard")
end
local function antiGameplayPauseLoop()
    while not Library.Unloaded do
        task.wait(1)
        if Toggles.AntiGameplayPause.Value then
            mx(true)
        end
    end
end
local function onExportConfigToClipboard()
    local ur_1
    local uq_1
    uq_1, ur_1 = pcall(nt.JSONEncode, nt, m_())
    if not uq_1 then
        Library:Notify("Failed to encode the config")
        return
    end
    local uq_2 = setclipboard or toclipboard
    local uq_3 = type(uq_2) ~= "function" or not pcall(uq_2, ur_1)
    if uq_3 then
        Library:Notify("Your executor does not support copying to the clipboard")
        return
    end
    Library:Notify("Config copied to clipboard", 6)
end
local function fn955(aY)
    local o8 = Toggles[aY]
    return o8 ~= nil and o8.Value == true
end
local function onCopyLitecoinAddress()
    m1(nb, "Copied Litecoin address")
end
local function fn969(dK)
    local q3 = mR and type(mR.walls) == "table"
    if q3 then
        local q3_1 = mR.walls[dK]
        if type(q3_1) == "number" then
            return q3_1
        end
        return GameConfig.WallThickness(dK)
    end
    return GameConfig.WallThickness(dK)
end
local function medalDelayLoop()
    while not Library.Unloaded do
        if ms("AutoCollectMedals") then
            pcall(m5)
            local sG = Options.MedalDelay and Options.MedalDelay.Value or 0.05
            task.wait(sG)
        else
            task.wait(0.25)
        end
    end
end
local function onCopyVenmoLink()
    m1(mL, "Copied Venmo link")
end
mk = nil
ml = nil
mm = nil
mo = nil
mp = nil
mq = nil
mr = nil
ms = nil
mt = nil
mu = nil
mv = nil
mw = nil
mx = nil
my = nil
mz = nil
mB = nil
mC = nil
mE = nil
mF = nil
mI = nil
GameConfig = nil
mK = nil
mL = nil
mM = nil
mN = nil
mO = nil
mP = nil
mQ = nil
mR = nil
mS = nil
mT = nil
mU = nil
mV = nil
mW = nil
mX = nil
mY = nil
mZ = nil
m_ = nil
m1 = nil
connection2 = nil
m3 = nil
m4 = nil
m5 = nil
local mj, mn, mA, mD, mG, mH, m0
Options = nil
m7 = nil
m8 = nil
m9 = nil
Toggles = nil
nb = nil
nc = nil
Workspace = nil
ne = nil
nf = nil
SaveManager = nil
ni = nil
nj = nil
nk = nil
nl = nil
nm = nil
nn = nil
Library = nil
connection = nil
Label = nil
nt = nil
nu = nil
nv = nil
nw = nil
MountainMelt = nil
ny = nil
nz = nil
nA = nil
nB = nil
nD = nil
local CoreGui, no, np, nC
CoreGui = nil
no = nil
np = nil
nC = nil
uL_30, uL_3, uL_23, nz, nw, nt, no, CoreGui, Workspace, m9, m4, uL_36, mX, mT, mN, GameConfig, uL_6, uL_20, uL_34, mD = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local uL_18 = 21
repeat
    uL_8 = (uL_18 * 2 + 7) % 9 + 1
    if uL_8 <= 5 then
        if uL_8 <= 3 then
            if uL_8 <= 2 then
                if uL_8 <= 1 then
                    if (uL_18 * 2 + 9) * 16 % 3 == ((uL_18 * 2 + 9) * 16 + 0) % 3 then
                        Workspace = game:GetService("Workspace")
                        m9 = uL_30.LocalPlayer
                        m4 = Workspace.CurrentCamera
                    else
                        m4 = game:GetService("Workspace")
                        uL_30 = Workspace.LocalPlayer
                        m9 = m4.CurrentCamera
                    end
                    uL_18 = (uL_18 + 32) % 36
                else
                    local vG = bit32.rrotate(bit32.bxor(bit32.lrotate(uL_18, 19), string.byte(tostring(uL_30))), 16)
                    if bit32.bxor(bit32.lrotate(bit32.bxor(vG, 1334957265), 24), 3511652820) == bit32.lrotate(vG, 24) then
                        uL_36 = "Melt The Ice"
                        mX = "https://discord.gg/K7Qxnxkk46"
                        mT = "https://discord.gg/K7Qxnxkk46"
                        mN = require(uL_3:WaitForChild("Modules"):WaitForChild("Remotes"))
                    else
                        mX = "Melt The Ice"
                        uL_3 = "https://discord.gg/K7Qxnxkk46"
                        mN = "https://discord.gg/K7Qxnxkk46"
                        uL_36 = require(mT:WaitForChild("Modules"):WaitForChild("Remotes"))
                    end
                    uL_18 = (uL_18 + 14) % 36
                end
            else
                uL_39 = (vector.create((uL_18 * 3 + 9) % 11 + 1, (uL_18 * 4 + 2) % 13 + 1, (uL_18 * 14 + 7) % 17 + 1))
                local v6 = vector.floor(uL_39) + vector.ceil(uL_39 * -1)
                if vector.dot(v6, v6) == 0 then
                    GameConfig = require(uL_3.Modules.GameConfig)
                else
                    uL_3 = require(GameConfig.Modules.GameConfig)
                end
                uL_18 = (uL_18 + 14) % 36
            end
        elseif uL_8 <= 4 then
            uL_39 = {
                "trf",
                "trngvsyskj",
                "jkzopuydfs",
                "qijkyvq",
                "jqvwowfa",
                "strr",
                "dplc",
                "yeepbtglwbu",
                "aylmfzryc",
                "ljzbhfip",
                "qhocdc"
            }
            local vH = uL_18
            uL_25 = uL_39[vH % 11 + 1]
            if uL_25:len() <= uL_25:reverse():rep(vH % 3 + 2):len() then
                uL_6 = { "Common", "Rare", "Epic", "Legendary", "Secret", "Transcendent" }
                uL_20 = { "All", "Rarity", "Selected" }
                uL_34 = {}
                mD = {}
            else
                uL_34 = { "Secret", "Rare", "Transcendent", "Common", "Epic", "Legendary" }
                uL_6 = { "Rarity", "All", "Selected" }
                mD = {}
                uL_20 = {}
            end
            uL_18 = (uL_18 + 14) % 36
        else
            uL_39 = { "nzhjjrs", "mwkgcpu", "sla", "iqtu", "clq", "qaeyod", "mockt", "ygfsavdhixgs", "uowcggwl" }
            if uL_39[(uL_18 * 94 + 51) % 9 + 1] <= uL_39[(uL_18 * 94 + 51) % 9 + 1] then
                uL_30 = game:GetService("Players")
            else
                nw = game:GetService("Players")
            end
            uL_18 = (uL_18 + 23) % 36
        end
    elseif uL_8 <= 7 then
        if uL_8 <= 6 then
            if uL_18 * 83993505 + 13 + 3 <= uL_18 * 83993505 + 13 + 3 + 1 then
                uL_3 = game:GetService("ReplicatedStorage")
            else
                mX = game:GetService("ReplicatedStorage")
            end
            uL_18 = (uL_18 + 32) % 36
        else
            if (uL_18 * 2 + 6) * 10 % 3 == ((uL_18 * 2 + 6) * 10 + 5) % 3 then
                nz = game:GetService("RunService")
                uL_23 = game:GetService("UserInputService")
            else
                uL_23 = game:GetService("RunService")
                nz = game:GetService("UserInputService")
            end
            uL_18 = (uL_18 + 14) % 36
        end
    elseif uL_8 <= 8 then
        uL_8 = {
            "fnnfvixd",
            "jtixz",
            "olrbzyi",
            "lwxsevt",
            "goirtydmp",
            "minntopk",
            "zdep",
            "hjfgvl",
            "yvwylrvkp",
            "jda",
            "ypiiddmzmpg"
        }
        local vI = uL_18
        uL_39 = uL_8[vI % 11 + 1]
        if uL_39:len() <= uL_39:reverse():rep(vI % 3 + 2):len() then
            nw = game:GetService("VirtualUser")
            nt = game:GetService("HttpService")
            no = game:GetService("GuiService")
        else
            nt = game:GetService("VirtualUser")
            no = game:GetService("HttpService")
            nw = game:GetService("GuiService")
        end
        uL_18 = (uL_18 + 5) % 36
    else
        uL_8 = {
            "mho",
            "irwin",
            "yhhhnhtyxwkq",
            "frhy",
            "cibvtj",
            "fedrmwjtmnl",
            "mjuzclim",
            "ycpmkrena",
            "bbirdqf",
            "bbyybf",
            "upizuwuos"
        }
        if uL_8[(uL_18 * 77 + 64) % 11 + 1] <= uL_8[(uL_18 * 77 + 64) % 11 + 1] then
            CoreGui = game:GetService("CoreGui")
        else
            mN = game:GetService("CoreGui")
        end
        uL_18 = (uL_18 + 14) % 36
    end
until (uL_18 * 31 + 25) % 36 == 10
for k, v in GameConfig.ItemById do
    uL_30 = v.name or tostring(k)
    uL_18 = uL_30
    uL_34[#uL_34 + 1] = uL_18
    mD[uL_18] = k
end
uL_3, mj = nil, nil
uL_30 = 9
repeat
    uL_18 = (uL_30 * 1 + 0) % 2 + 1
    if uL_18 <= 1 then
        uL_18 = (vector.create((uL_30 * 6 + 5) % 11 + 1, (uL_30 * 11 + 1) % 13 + 1, (uL_30 * 13 + 14) % 17 + 1))
        uL_8 = (vector.create((uL_30 * 4 + 2) % 11 + 1, (uL_30 * 2 + 7) % 13 + 1, (uL_30 * 6 + 13) % 17 + 1))
        uL_39 = (vector.create((uL_30 * 3 + 2) % 5 + 1, (uL_30 * 5 + 4) % 7 + 1, (uL_30 * 2 + 3) % 9 + 1))
        if math.abs((vector.angle(uL_18, uL_8, uL_39))) - math.abs((vector.angle(uL_8, uL_18, uL_39))) == 5 then
            uL_3 = {}
        else
            mj = {}
        end
        uL_30 = (uL_30 + 1) % 16
    else
        uL_18 = (vector.create((uL_30 * 5 + 4) % 11 + 1, (uL_30 * 1 + 8) % 13 + 1, (uL_30 * 13 + 7) % 17 + 1))
        uL_8 = (vector.create((uL_30 * 6 + 8) % 11 + 1, (uL_30 * 1 + 5) % 13 + 1, (uL_30 * 14 + 16) % 17 + 1))
        uL_39 = (vector.create((uL_30 * 1 + 8) % 11 + 1, (uL_30 * 8 + 11) % 13 + 1, (uL_30 * 14 + 9) % 17 + 1))
        if vector.dot(vector.cross(uL_18, uL_8), uL_39) == vector.dot(vector.cross(uL_8, uL_39), uL_18) then
            table.sort(uL_34)
            uL_3 = {}
        else
            table.sort(uL_3)
            uL_34 = {}
        end
        uL_30 = (uL_30 + 13) % 16
    end
until (uL_30 * 9 + 6) % 16 == 5
for k, v in GameConfig.UPGRADES do
    uL_30 = v.name or tostring(k)
    uL_18 = uL_30
    uL_3[#uL_3 + 1] = uL_18
    mj[uL_18] = k
end
uL_8, np = nil, nil
uL_30 = 6
repeat
    uL_18 = (vector.create((uL_30 * 4 + 2) % 11 + 1, (uL_30 * 4 + 10) % 13 + 1, (uL_30 * 9 + 5) % 17 + 1))
    local vp = vector.floor(uL_18) + vector.ceil(uL_18 * -1)
    if vector.dot(vp, vp) == 1 then
        table.sort(np)
        uL_3 = {}
        uL_8 = {}
    else
        table.sort(uL_3)
        uL_8 = {}
        np = {}
    end
    uL_30 = (uL_30 + 0) % 8
until (uL_30 * 7 + 0) % 8 == 2
for k, v in GameConfig.WEAPONS do
    uL_30 = v.name and v.id
    if uL_30 then
        uL_8[#uL_8 + 1] = v.name
        np[v.name] = v.id
    end
end
m0 = {}
uL_30 = {}
for k, v in GameConfig.BACKPACKS do
    uL_18 = v.name and v.id
    if uL_18 then
        uL_30[#uL_30 + 1] = v.name
        m0[v.name] = v.id
    end
end
mG = {}
uL_18 = {}
for k, v in GameConfig.POTIONS do
    uL_39 = v.name and v.id
    if uL_39 then
        uL_18[#uL_18 + 1] = v.name
        mG[v.name] = v.id
    end
end
uL_39 = GameConfig.MOUNTAIN and GameConfig.MOUNTAIN.zoneCount
uL_25 = uL_39 or #GameConfig.LAYERS
uL_39 = {}
mu = uL_25
local oS = 1
local oQ = mu
while oS <= oQ do
    local oT = oS
    uL_39[oT] = "Stage " .. oT
    oS += 1
end
uL_25 = GameConfig.MOUNTAIN and GameConfig.MOUNTAIN.pickupRange
local uL_11 = uL_25 or 14
nC = nil
nC = uL_11
local uL_42 = GameConfig.MOUNTAIN and GameConfig.MOUNTAIN.meltRangeSlack
uL_25 = uL_42
local o_ = if uL_25 then 1 else 0
local oY = 3840 * o_ + 3858 * (1 - o_)
local oZ = 1178 * o_ + 2848 * (1 - o_)
if not ((oY * 1855 + oZ * 1864 + oY * oZ) % 16777213 == 13842512) then
    uL_25 = 16
end
nA, MountainMelt, Library, ThemeManager, SaveManager, Toggles, Options, nj, nb, m8, m3, mZ, mU, mQ, mL, uL_27, mV, mR, mE, mz, m1, mK, mv, mm, ms, nB, nv, nc, nm, mI, my, ne, mP, mw, nf, m5, mH, mA, mq, m7, nk, ny, mS, mC, nD, nn, mM, mo, mO, mt, mp, mY, nu = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if false or not ThemeManager and not ThemeManager or (ThemeManager or uL_27) and (false or not ThemeManager) or (not ThemeManager or false) and (not ThemeManager and false) and (false or not ThemeManager or not ThemeManager and false) or (not ThemeManager or not ThemeManager or (ThemeManager or ThemeManager)) and (ThemeManager and uL_27 and false) and (ThemeManager or not ThemeManager or (false or not ThemeManager) or (ThemeManager or ThemeManager or (false or not ThemeManager))) or not (false or not ThemeManager and not ThemeManager or (ThemeManager or uL_27) and (false or not ThemeManager) or (not ThemeManager or false) and (not ThemeManager and false) and (false or not ThemeManager or not ThemeManager and false) or (not ThemeManager or not ThemeManager or (ThemeManager or ThemeManager)) and (ThemeManager and uL_27 and false) and (ThemeManager or not ThemeManager or (false or not ThemeManager) or (ThemeManager or ThemeManager or (false or not ThemeManager)))) then
    nA = uL_25
end
MountainMelt = mN.MountainMelt
Library = getgenv().Library
ThemeManager = getgenv().ThemeManager
SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
m1 = fn370
mK = fn598
local uL_12 = fn561
mv = fns.fn32
mm = fn354
local uL_22 = "#7fd47f"
if nf and not mP and (Options or not mP) and ((not nf or not nf) and (mP and mP)) or (Options and uL_27 or false and not nf) and ((Options or not mP) and (mP or not nf)) or not (nf and not mP and (Options or not mP) and ((not nf or not nf) and (mP and mP)) or (Options and uL_27 or false and not nf) and ((Options or not mP) and (mP or not nf))) then
    uL_35 = "#6ec1ff"
    nj = "#e8a34d"
    uL_19 = "#8b93a3"
    nb = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
    m8 = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
else
    m8 = "#6ec1ff"
    uL_35 = "#e8a34d"
    nb = "#8b93a3"
    nj = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
    uL_19 = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
end
m3 = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
mZ = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
mU = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
mQ = ""
mL = ""
local uL_31 = "#345d9d"
local uL_2 = "#f7931a"
local uL_15 = "#627eea"
local uL_29 = "#26a17b"
local uL_45 = "#14f195"
uL_27 = "#0070ba"
local uL_44 = "#008cff"
ms = fn955
nB = fn699
nv = fns.fn292
if mO and false and (not mP and not mP) and (mM or not mO or mO and mM) and not (mO and false and (not mP and not mP) and (mM or not mO or mO and mM)) then
    mI = fns.fn41
    mR = nil
    nc = nil
    nm.DataUpdate.OnClientEvent:Connect(fns.onOnClientEvent2)
    nm.MountainState.OnClientEvent:Connect(fns.onOnClientEvent)
    nm.RequestData:FireServer()
    nm.MountainState:FireServer()
    mN = fn367
    mV = fn613
else
    nc = fns.fn41
    mV = nil
    mR = nil
    mN.DataUpdate.OnClientEvent:Connect(fns.onOnClientEvent2)
    mN.MountainState.OnClientEvent:Connect(fns.onOnClientEvent)
    mN.RequestData:FireServer()
    mN.MountainState:FireServer()
    nm = fn367
    mI = fn613
end
my = fn839
ne = fn481
mP = fn789
mE = nil
mz = 0
mw = fns.fn138
nf = fns.fn101
m5 = fns.fn251
mH = fn621
mA = fns.fn268
mq = function()
    local qp = nm("BuyUpgradeList")
    if not mV then
        return
    end
    for k in qp do
        local qo = mj[k]
        if qo then
            pcall(function()
                mN.BuyUpgrade:InvokeServer(qo, 1)
            end)
        end
    end
end
m7 = function()
    local qB_1
    local qx = nm("BuyWeaponList")
    local qx_3
    local qy = mV
    if not qy then
        return
    end
    local qA = qy.OwnedWeapons or {}
    local qA_1 = tonumber(qy.Cash) or 0
    local qy_1 = qA_1
    for k in qx do
        local qw = np[k]
        local qx_1 = qw and mH(qw)
        local qA_2 = qx_1
        if qx_1 then
            qx_1 = not qA[qw]
        end
        if qx_1 then
            local qx_2 = tonumber(qA_2.cost) or 0
            if qx_2 <= qy_1 then
                qx_3, qB_1 = pcall(function()
                    return mN.BuyWeapon:InvokeServer(qw)
                end)
                if qx_3 and qB_1 then
                    pcall(function()
                        mN.EquipWeapon:InvokeServer(qw)
                    end)
                    qy_1 -= qx_2
                end
            end
        end
    end
end
nk = function()
    local qN_1
    local qJ = nm("BuyBackpackList")
    local qJ_3
    local qK = mV
    if not qK then
        return
    end
    local qM = qK.OwnedBackpacks or {}
    local qM_1 = tonumber(qK.Cash) or 0
    local qK_1 = qM_1
    for k in qJ do
        local qI = m0[k]
        local qJ_1 = qI and mA(qI)
        local qM_2 = qJ_1
        if qJ_1 then
            qJ_1 = not qM[qI]
        end
        if qJ_1 then
            local qJ_2 = tonumber(qM_2.cost) or 0
            if qJ_2 <= qK_1 then
                qJ_3, qN_1 = pcall(function()
                    return mN.BuyBackpack:InvokeServer(qI)
                end)
                if qJ_3 and qN_1 then
                    pcall(function()
                        mN.EquipBackpack:InvokeServer(qI)
                    end)
                    qK_1 -= qJ_2
                end
            end
        end
    end
end
ny = function()
    local qV = nm("BuyPotionList")
    if not mV then
        return
    end
    for k in qV do
        local qU = mG[k]
        if qU then
            pcall(function()
                mN.BuyPotion:InvokeServer(qU)
            end)
        end
    end
end
mS = fn573
mC = fn969
nD = fns.fn173
nn = fns.fn341
mM = fn564
mo = fns.fn49
mO = fns.fn279
mt = fn692
mp = function()
    local rI
    rI = nil
    local rT = if mP(mV) then 1 else 0
    if rT == 1 then
        return false
    end
    rI = nc()
    if not rI then
        return false
    end
    local rJ = mO()
    if #rJ == 0 then
        local MyMountain = Workspace:FindFirstChild("MyMountain")
        if MyMountain then
            for i, descendant in MyMountain:GetDescendants() do
                if descendant:IsA("ProximityPrompt") then
                    local attr = descendant:GetAttribute("MountainIdx")
                    if attr ~= nil then
                        local rL = mR and mR.items and mR.items[attr]
                        local rL_2
                        local rM = rL
                        if rL then
                            rL = rM.key
                        end
                        local rN = rL
                        if not rN then
                            local ObjectText = descendant.ObjectText
                            rN = ObjectText and mD[ObjectText]
                        end
                        if rN then
                            rL_2 = my(rN, "CollectMode", "CollectRarities", "CollectItems")
                        else
                            rL_2 = (Options.CollectMode and Options.CollectMode.Value or "All") == "All"
                        end
                        if rL_2 and rM and not rM.claimed then
                            local Parent = descendant.Parent
                            local rN_3 = Parent and Parent:IsA("BasePart")
                            if rN_3 then
                                rJ[#rJ + 1] = { idx = attr, item = rM, pos = Parent.Position }
                            else
                                local rL_4 = rM and type(rM.x) == "number"
                                if rL_4 then
                                    local rL_5 = #rJ + 1
                                    local new = Vector3.new
                                    local rO_3 = rM.x
                                    local rP = rM.y or 3
                                    rJ[rL_5] = { idx = attr, item = rM, pos = new(rO_3, rP, rM.z) }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if #rJ == 0 then
        return false
    end
    table.sort(rJ, function(e_, e0)
        return (e_.pos - rI.Position).Magnitude < (e0.pos - rI.Position).Magnitude
    end)
    local rK_3 = false
    for k, v in rJ do
        local r4 = v
        if mP(mV) then
            break
        end
        rI = nc()
        if not rI then
            break
        elseif (rI.Position - r4.pos).Magnitude > nC - 1 then
            rI.CFrame = CFrame.new(r4.pos + Vector3.new(0, 3, 0))
            task.wait(0.12)
            rI = nc()
            if not rI then
                break
            end
            pcall(function()
                mN.MountainPickup:FireServer(r4.idx)
            end)
            if r4.item then
                r4.item.claimed = true
            end
            rK_3 = true
            task.wait(0.05)
        else
            pcall(function()
                mN.MountainPickup:FireServer(r4.idx)
            end)
            if r4.item then
                r4.item.claimed = true
            end
            rK_3 = true
            task.wait(0.05)
        end
    end
    return rK_3
end
mY = fn855
nu = function()
    local r9 = mV
    local sa = not r9 or type(r9.Items) ~= "table"
    if sa then
        return
    end
    if (Options.SellMode and Options.SellMode.Value or "All") == "All" then
        pcall(function()
            mN.SellAll:InvokeServer()
        end)
        return
    end
    for k, v in r9.Items do
        local sg = k
        local r9_1 = type(v) == "number" and v > 0
        if r9_1 then
            if my(sg, "SellMode", "SellRarities", "SellItems") then
                pcall(function()
                    mN.SellItem:InvokeServer(sg)
                end)
            end
        end
    end
end
uL_42 = Library:CreateWindow({
    Title = "Tempo",
    Font = Enum.Font.BuilderSans,
    Footer = { { Text = mX, Copyable = true }, "|", uL_36 },
    Icon = 78539693571783,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 0
})
local uL_14 = {
    Info = uL_42:AddTab("Info", "info"),
    Main = uL_42:AddTab("Main", "flame"),
    Player = uL_42:AddTab("Player", "person-standing"),
    Settings = uL_42:AddTab("Settings", "settings")
}
for k, v in uL_14 do
    uL_12(v)
end
mr, uL_26, Label, nl, uL_42 = nil, nil, nil, nil, nil
uL_25 = 10
repeat
    uL_12 = (uL_25 * 2 + 2) % 3 + 1
    if uL_12 <= 2 then
        if uL_12 <= 1 then
            uL_12 = {
                "ues",
                "dwrpmhkb",
                "bgmdwc",
                "vdmedex",
                "kqnguo",
                "jrp",
                "vnqfltum",
                "qokldchl",
                "epwafz",
                "ovjenwghu",
                "ijosdjja",
                "ixsw",
                "bkpcm"
            }
            if uL_12[(uL_25 * 7 + 109) % 13 + 1] < uL_12[(uL_25 * 7 + 109) % 13 + 1] then
                nl = #uL_42 > 18
            else
                uL_42 = #nl > 18
            end
            uL_25 = (uL_25 + 14) % 24
        else
            uL_12 = (vector.create((uL_25 * 3 + 7) % 11 + 1, (uL_25 * 4 + 11) % 13 + 1, (uL_25 * 9 + 8) % 17 + 1))
            uL_7 = (vector.create((uL_25 * 2 + 8) % 11 + 1, (uL_25 * 9 + 1) % 13 + 1, (uL_25 * 3 + 9) % 17 + 1))
            uL_40 = (vector.create((uL_25 * 5 + 9) % 11 + 1, (uL_25 * 10 + 1) % 13 + 1, (uL_25 * 11 + 1) % 17 + 1))
            if vector.dot(vector.cross(uL_12, uL_7), uL_40) == vector.dot(vector.cross(uL_7, uL_40), uL_12) + 2 then
                pcall(fns.fn195)
                uL_14 = nj.Info:AddLeftGroupbox("Account", "circle-user")
                uL_14:AddLabel(uL_26("User", uL_35.Name, mm), true)
                uL_14:AddLabel(uL_26("Status", "Keyless", mm), true)
                uL_14:AddLabel(uL_26("Executor", "Unknown", mm), true)
                m9 = nj.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                m9:AddLabel(mr(mv .. " [" .. tostring(game.PlaceId) .. "]", Label), true)
                m9:AddLabel(uL_26("Place ID", tostring(game.PlaceId), Label), true)
                uL_22 = m9:AddLabel(uL_26("Session time", "0s", uL_36), true)
            else
                mr = "Unknown"
                pcall(fns.fn195)
                uL_11 = uL_14.Info:AddLeftGroupbox("Account", "circle-user")
                uL_11:AddLabel(mm("User", m9.Name, uL_22), true)
                uL_11:AddLabel(mm("Status", "Keyless", uL_22), true)
                uL_11:AddLabel(mm("Executor", mr, uL_22), true)
                uL_26 = uL_14.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                uL_26:AddLabel(mv(uL_36 .. " [" .. tostring(game.PlaceId) .. "]", uL_35), true)
                uL_26:AddLabel(mm("Place ID", tostring(game.PlaceId), uL_35), true)
                Label = uL_26:AddLabel(mm("Session time", "0s", nj), true)
            end
            uL_25 = (uL_25 + 2) % 24
        end
    else
        uL_12 = {
            "bwywdpsofq",
            "uprf",
            "bshqk",
            "knjndjgbmy",
            "beoljvd",
            "smgankrx",
            "xdpo",
            "mhriadbn",
            "vhk",
            "ianxkjxctn",
            "rnxqsskgnzuu",
            "verhedi",
            "aunsolbxzcrg",
            "uirnilzv",
            "cllfsdbst"
        }
        if uL_12[(uL_25 * 16 + 108) % 15 + 1] <= uL_12[(uL_25 * 16 + 108) % 15 + 1] then
            nl = tostring(game.JobId)
        else
            uL_26 = tostring(game.JobId)
        end
        uL_25 = (uL_25 + 23) % 24
    end
until (uL_25 * 17 + 15) % 24 == 8
if uL_42 then
    uL_25 = 0
    repeat
        if (uL_25 * 1 + 6) * 13 % 4 == ((uL_25 * 1 + 6) * 13 + 7) % 4 then
            nl = string.sub(uL_42, 1, 18) .. "..."
        else
            uL_42 = string.sub(nl, 1, 18) .. "..."
        end
        uL_25 = (uL_25 + 0) % 8
    until (uL_25 * 7 + 6) % 8 == 6
end
uL_25 = uL_42 or nl
mW, mF, mB, connection, connection2, ml, mx, mn, ni, m_, mk = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local oe = uL_25
uL_26:AddLabel(mm("Server", oe, uL_19), true)
uL_26:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
mW = os.clock()
task.spawn(worker)
uL_40 = uL_14.Info:AddRightGroupbox("Scripts", "package")
uL_40:AddLabel(mv("Included in this hub", uL_19), true)
uL_40:AddLabel(mv(uL_36, uL_35), true)
uL_12 = uL_14.Info:AddRightGroupbox("Features", "list")
uL_12:AddLabel(mv("Auto Farm", uL_35), true)
uL_12:AddLabel(mv("Auto Collect", nj), true)
uL_12:AddLabel(mv("Auto Sell", uL_22), true)
uL_12:AddLabel(mv("Auto Buy", uL_35), true)
uL_12:AddLabel(mv("Player Movement", uL_19), true)
uL_42 = uL_14.Info:AddRightGroupbox("Socials", "link")
uL_42:AddButton({ Text = "Discord", Func = mK })
uL_42:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = uL_14.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = mK })
local DonationsGroup = uL_14.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(mv("All donations are optional but appreciated.", nj), true)
DonationsGroup:AddLabel(mv("If you donate you get a special role, just PING after you donate.", uL_22), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(mv("LTC / Litecoin", uL_31), true)
DonationsGroup:AddButton({ Text = "Copy Litecoin Address", Func = onCopyLitecoinAddress })
DonationsGroup:AddLabel(mv("BTC / Bitcoin", uL_2), true)
DonationsGroup:AddButton({ Text = "Copy Bitcoin Address", Func = fns.onCopyBitcoinAddress })
DonationsGroup:AddLabel(mv("ETH / Ethereum", uL_15), true)
DonationsGroup:AddButton({ Text = "Copy Ethereum Address", Func = onCopyEthereumAddress })
DonationsGroup:AddLabel(mv("USDT", uL_29), true)
DonationsGroup:AddButton({ Text = "Copy USDT Address", Func = fns.onCopyUSDTAddress })
DonationsGroup:AddLabel(mv("Solana", uL_45), true)
DonationsGroup:AddButton({ Text = "Copy Solana Address", Func = fns.onCopySolanaAddress })
DonationsGroup:AddLabel(mv("PayPal", uL_27), true)
DonationsGroup:AddButton({ Text = "Copy PayPal Link", Func = onCopyPayPalLink })
DonationsGroup:AddLabel(mv("Venmo", uL_44), true)
DonationsGroup:AddButton({ Text = "Copy Venmo Link", Func = onCopyVenmoLink })
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(mv("Don't have any of the listed currencies but still wanna donate?", uL_19), true)
DonationsGroup:AddLabel(mv("DM me and we'll work something out.", uL_35), true)
local FaqGroup = uL_14.Info:AddRightGroupbox("FAQ", "circle-help")
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
local AutoMeltGroup = uL_14.Main:AddLeftGroupbox("Auto Melt", "flame")
AutoMeltGroup:AddToggle("AutoFarmMelt", { Text = "Auto Farm Melt", Default = false })
AutoMeltGroup:AddDropdown("FarmStage", { Text = "Farm Stage", Values = uL_39, Default = uL_39[1] })
AutoMeltGroup:AddToggle("AutoMelt", { Text = "Auto Melt Ice", Default = false })
local MedalsGroup = uL_14.Main:AddLeftGroupbox("Medals", "medal")
MedalsGroup:AddToggle("AutoCollectMedals", { Text = "Auto Collect Medals", Default = false })
MedalsGroup:AddSlider("MedalDelay", { Text = "Medal Delay", Default = 0.05, Min = 0, Max = 2, Rounding = 2 })
local ShopGroup = uL_14.Main:AddLeftGroupbox("Shop", "shopping-cart")
ShopGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ShopGroup:AddDropdown("BuyUpgradeList", { Text = "Upgrades", Values = uL_3, Default = uL_3, Multi = true, SelectAllButtons = true })
ShopGroup:AddToggle("AutoBuyWeapons", { Text = "Auto Buy Weapons", Default = false })
ShopGroup:AddDropdown("BuyWeaponList", {
    Text = "Weapons",
    Values = uL_8,
    Default = {},
    Multi = true,
    Searchable = true,
    Expandable = true,
    ExpandColumns = 2
})
ShopGroup:AddToggle("AutoBuyBackpacks", { Text = "Auto Buy Backpacks", Default = false })
ShopGroup:AddDropdown("BuyBackpackList", { Text = "Backpacks", Values = uL_30, Default = uL_30, Multi = true, SelectAllButtons = true })
ShopGroup:AddToggle("AutoBuyPotions", { Text = "Auto Buy Potions", Default = false })
ShopGroup:AddDropdown("BuyPotionList", {
    Text = "Potions",
    Values = uL_18,
    Default = {},
    Multi = true,
    Searchable = true,
    Expandable = true
})
local AutoCollectGroup = uL_14.Main:AddRightGroupbox("Auto Collect", "package")
AutoCollectGroup:AddToggle("AutoCollectLoot", { Text = "Auto Collect Loot", Default = false })
AutoCollectGroup:AddDropdown("CollectMode", { Text = "Collect Mode", Values = uL_20, Default = "All" })
AutoCollectGroup:AddDropdown("CollectRarities", {
    Text = "Collect Rarities",
    Values = uL_6,
    Default = { "Common", "Rare", "Epic", "Legendary", "Secret", "Transcendent" },
    Multi = true,
    SelectAllButtons = true,
    Expandable = true
})
AutoCollectGroup:AddDropdown("CollectItems", {
    Text = "Collect Items",
    Values = uL_34,
    Default = {},
    Multi = true,
    Searchable = true,
    Expandable = true,
    ExpandColumns = 2
})
AutoCollectGroup:AddSlider("CollectDelay", { Text = "Collect Delay", Default = 0.2, Min = 0.05, Max = 3, Rounding = 2 })
uL_7 = uL_14.Main:AddRightGroupbox("Auto Sell", "tag")
uL_7:AddToggle("AutoSell", { Text = "Auto Sell", Default = false })
uL_7:AddDropdown("SellMode", { Text = "Sell Mode", Values = uL_20, Default = "All" })
uL_7:AddDropdown("SellRarities", {
    Text = "Sell Rarities",
    Values = uL_6,
    Default = { "Common", "Rare", "Epic" },
    Multi = true,
    SelectAllButtons = true,
    Expandable = true
})
uL_7:AddDropdown("SellItems", {
    Text = "Sell Items",
    Values = uL_34,
    Default = {},
    Multi = true,
    Searchable = true,
    Expandable = true,
    ExpandColumns = 2
})
uL_7:AddSlider("SellDelay", { Text = "Sell Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
task.spawn(fns.collectDelayLoop)
task.spawn(fns.worker2)
task.spawn(medalDelayLoop)
task.spawn(collectDelayLoop2)
task.spawn(fns.sellDelayLoop)
task.spawn(fns.worker3)
task.spawn(worker4)
task.spawn(fns.worker5)
task.spawn(worker6)
task.spawn(worker7)
local MovementGroup = uL_14.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", { Text = "WalkSpeed", Default = false })
MovementGroup:AddSlider("WalkSpeed", { Text = "WalkSpeed Amount", Default = 32, Min = 16, Max = 250, Rounding = 0 })
MovementGroup:AddToggle("InfJump", { Text = "Infinite Jump", Default = false })
MovementGroup:AddToggle("NoClip", { Text = "NoClip", Default = false })
MovementGroup:AddToggle("AntiGameplayPause", { Text = "No Gameplay Paused", Default = true })
local FlyGroup = uL_14.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", { Text = "Fly", Default = false })
FlyGroup:AddSlider("FlySpeed", { Text = "Fly Speed", Default = 60, Min = 10, Max = 400, Rounding = 0 })
local MenuGroup = uL_14.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
mF = tick()
mB = tick()
pcall(function()
    for i, v in ipairs(getconnections(m9.Idled)) do
        local s3 = v
        pcall(function()
            s3:Disable()
        end)
    end
end)
ml = fns.fn139
connection = nz.InputBegan:Connect(fns.onInputBegan)
connection2 = nz.InputChanged:Connect(onInputChanged)
task.spawn(fns.antiAfkLoop)
mx = function(hF)
    pcall(function()
        no:SetGameplayPausedNotificationEnabled(not hF)
    end)
    pcall(function()
        local RobloxNetworkPauseNotificati = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
        if RobloxNetworkPauseNotificati then
            RobloxNetworkPauseNotificati.Enabled = not hF
        end
    end)
    if not hF then
        return
    end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(m9, "GameplayPaused", false)
        else
            m9.GameplayPaused = false
        end
    end)
end
Toggles.AntiGameplayPause:OnChanged(fn909)
task.spawn(antiGameplayPauseLoop)
uL_23.Stepped:Connect(onStepped)
nz.JumpRequest:Connect(onJumpRequest)
uL_23.RenderStepped:Connect(onRenderStepped)
Toggles.Fly:OnChanged(fns.fn350)
Toggles.WalkSpeedEnabled:OnChanged(fn644)
Library:OnUnload(fns.fn288)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(uL_14.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/MeltTheIce")
uL_11 = SaveManager:BuildConfigSection(uL_14.Settings)
mn = fns.fn159
ni = fns.fn281
m_ = fn831
mk = function(iX)
    local un
    un = nil
    local uo = type(iX) ~= "table" or type(iX.idx) ~= "string" or type(iX.type) ~= "string" or SaveManager.Ignore[iX.idx]
    if uo then
        return false
    end
    un = mn(iX.type, iX.idx)
    if not un then
        return false
    end
    local uo_1 = pcall(function()
        if iX.type == "Input" then
            if type(iX.text) ~= "string" then
                return
            end
            un:SetValue(iX.text)
        elseif iX.type == "ColorPicker" then
            un:SetValueRGB(Color3.fromHex(iX.value), iX.transparency)
        elseif iX.type == "KeyPicker" then
            un:SetValue({ iX.key, iX.mode, iX.modifiers })
            if iX.mode == "Toggle" and iX.toggled ~= nil then
                un.Toggled = iX.toggled
                un:Update()
            end
        else
            un:SetValue(iX.value)
        end
    end)
    return uo_1
end
uL_11:AddDivider()
uL_11:AddInput("SaveManager_ImportSource", { Text = "Paste exported config here", Finished = true, AllowEmpty = true })
uL_11:AddButton("Export Config to Clipboard", onExportConfigToClipboard)
uL_11:AddButton("Import Config from Clipboard Text", onImportConfigFromClipboardTex)
SaveManager:LoadAutoloadConfig()
end)(...)
