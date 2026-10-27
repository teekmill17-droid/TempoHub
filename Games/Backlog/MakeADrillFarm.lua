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
getgenv().TempoHoodSubtitle = "MAKE A DRILL FARM"
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
local gr
local gN
local gQ
local Toggles
local Options
local gA
local gk
local gG
local MutationsMetadata
local gM
local EnergySourcesMetadata
local gP
local Library
local gS
local DrillsMetadata
local gC
local gg
local Bases
local gj
local gm
local gI
local gp
local gO
local gs
local VirtualUser
local gv
local gy
local gB
local RequestSpin
local onBuyCurrentResults
local GoldenMetadata
local gH
local go
local connection
local function fn43(cV)
    local jT = DrillsMetadata[cV:GetAttribute("DrillId")]
    if not jT then
        return nil
    end
    local jU = jT.OresPerSecond
    local j_ = if jU then 1 else 0
    local jY = 3318 * j_ + 3635 * (1 - j_)
    local jZ = 2272 * j_ + 4026 * (1 - j_)
    if not ((jY * 303 + jZ * 2973 + jY * jZ) % 16777213 == 15298506) then
        jU = 0
    end
    local computeMultiplier = MutationsMetadata.computeMultiplier
    local parseList = MutationsMetadata.parseList
    local jW = cV:GetAttribute("Mutations") or ""
    local jT_2 = jU * computeMultiplier(parseList(jW))
    if cV:GetAttribute("IsGolden") then
        jT_2 = jT_2 * GoldenMetadata.GOLDEN_MULTIPLIER
    end
    return jT_2
end
local function fn46()
    if setclipboard then
        setclipboard(gS)
    elseif toclipboard then
        toclipboard(gS)
    end
    Library:Notify("Copied Discord invite to clipboard")
end
local function fn50(P)
    local hw = DrillsMetadata[P]
    if hw then
        return hw, "Drills"
    end
    local hw_1 = EnergySourcesMetadata[P]
    if hw_1 then
        return hw_1, "Energy Sources"
    end
    return nil, nil
end
local function autoCollectOresLoop()
    while not Library.Unloaded do
        if Toggles.AutoCollectOres.Value then
            gH()
        end
        if Toggles.AutoDepositOres.Value then
            gB()
        end
        local kZ = Options.OreDelay.Value or 1
        task.wait(kZ)
    end
end
local function fn65()
    go("DepositOresPrompt")
end
local function onAntiAfk(eu)
    if eu then
        if not connection then
            connection = gN.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    elseif connection then
        connection:Disconnect()
        connection = nil
    end
end
local function fn88(b1)
    local jh_1
    local jg_1
    jg_1, jh_1 = tostring(b1):gsub("[^%d%.]", ""), tostring(b1):match("[KkMmBbTt]")
    local ji = (tonumber(jg_1))
    local jo = if ji then 1 else 0
    local jm = 3898 * jo + 258 * (1 - jo)
    local jn = 1306 * jo + 1298 * (1 - jo)
    if not ((jm * 2560 + jn * 3746 + jm * jn) % 16777213 == 3184731) then
        ji = 0
    end
    local jg_2 = { K = 1000, M = 1000000, B = 1000000000, T = 1000000000000 }
    local jj = jh_1
    local jk = ji
    if jj then
        jj = jh_1:upper()
    end
    return jk * (jg_2[jj] or 1)
end
local function onOnClientEvent2(av, aw)
    if not av or av.Name ~= gj then
        return
    end
    gI[aw] = nil
end
local function fn90()
    local kn_1
    local kl = gC()
    local km = kl and kl:FindFirstChild("PlacedItems")
    local km_1
    if not km then
        return nil
    end
    kn_1, km_1 = nil, nil
    for i, child in km:GetChildren() do
        local kl_2 = gy(child)
        if kl_2 and (not kn_1 or kl_2 < km_1) then
            kn_1, km_1 = child, kl_2
        end
    end
    return kn_1, km_1 or 0
end
local function fn100()
    local i0 = {}
    local i1 = gC()
    local i2 = i1 and i1:FindFirstChild("PlacedItems")
    if i2 then
        for i, child in i2:GetChildren() do
            i0[child.Name] = true
        end
    end
    return i0
end
local function fn120(c9, da)
    local kc = gC()
    local kd = kc and kc:FindFirstChild("Grid")
    if not kd then
        return nil
    end
    for i, descendant in kd:GetDescendants() do
        if descendant:GetAttribute("Coord") == c9 then
            return descendant:FindFirstChild(da)
        end
    end
    return nil
end
local function fn126()
    local j1_1
    local j0_1
    j1_1, j0_1 = nil, nil
    for k, v in gm() do
        local j2_1 = v:GetAttribute("OresPerSecond") or 0
        local j3 = not j1_1
        if not j3 then
            j3 = j2_1 > j0_1
        end
        if j3 then
            j1_1, j0_1 = v, j2_1
        end
    end
    return j1_1, j0_1 or 0
end
local function fn155()
    pcall(function()
        RequestSpin:InvokeServer()
    end)
end
local function onOnClientEvent(ah, ai, aj)
    if not ah or ah.Name ~= gj then
        return
    end
    local hP_1 = type(ai) ~= "table" or type(aj) ~= "table"
    if hP_1 then
        return
    end
    table.clear(gI)
    for k, v in aj do
        local hP_2 = ai[k]
        local hQ = hP_2 and select(1, gg(hP_2))
        if hQ then
            local Rarity = hQ.Rarity
            local hS = hQ.Price or 0
            local hT = select(2, gg(hP_2))
            local hU = hQ.Name or tostring(hP_2)
            gI[k] = { SpinId = v, ItemId = hP_2, Rarity = Rarity, Price = hS, Type = hT, Name = hU }
        end
    end
end
local function fn168(aB)
    if not gM[aB.Type] then
        return false
    end
    local h3 = tonumber(Options.BuyMaxPrice.Value) or 0
    if h3 > 0 and aB.Price > h3 then
        return false
    end
    local Value = Options.BuyMode.Value
    if Value == "Buy All" then
        return true
    elseif Value == "Minimum Rarity" then
        local h4_1 = gA[aB.Rarity]
        local h5 = gA[Options.BuyMinRarity.Value]
        return h4_1 ~= nil and h5 ~= nil and h4_1 >= h5
    elseif Value == "Specific Rarities" then
        if next(gP) == nil then
            return false
        end
        return gP[aB.Rarity] == true
    else
        return false
    end
end
local function autoReplaceLoop()
    while not Library.Unloaded do
        if Toggles.AutoReplace.Value then
            gv()
        end
        local k7 = Options.ReplaceDelay.Value or 1
        task.wait(k7)
    end
end
local function onPlaceRarities(eo)
    gr = gk(eo)
end
local function fn283()
    local iK_1
    local iJ_1
    local Value = Options.PlaceDrillMode.Value
    iK_1, iJ_1 = nil, nil
    for k, v in gm() do
        local attr = v:GetAttribute("Rarity")
        if Value ~= "Specific Rarities" or gr[attr] then
            local iL_1 = v:GetAttribute("OresPerSecond") or 0
            if not iK_1 then
                iK_1, iJ_1 = v, iL_1
            elseif Value == "Worst (Ores/s)" then
                if iL_1 < iJ_1 then
                    iK_1, iJ_1 = v, iL_1
                end
            elseif iL_1 > iJ_1 then
                iK_1, iJ_1 = v, iL_1
            end
        end
    end
    return iK_1
end
local function fn287(ea)
    ea:AddLeftGroupbox("Discord"):AddButton({ Text = "Join Discord For Dupe", Func = gO })
end
local function fn290(aa)
    local hH = {}
    for k, v in aa do
        if v then
            hH[k] = true
        end
    end
    return hH
end
local function onBuyRarities(eg)
    gP = gk(eg)
end
local function fn306()
    local replicationFolder = gN:FindFirstChild("_replicationFolder")
    local hC = replicationFolder and replicationFolder:FindFirstChild("Currencies")
    local hB_1 = hC
    if hC then
        hC = hB_1:GetAttribute("Cash")
    end
    return hC or 0
end
local function fn351()
    Library.ScreenGui.Parent = gN:WaitForChild("PlayerGui")
end
local function autoPlaceLoop()
    while not Library.Unloaded do
        if Toggles.AutoPlace.Value then
            gs()
        end
        local k4 = Options.PlaceDelay.Value or 1
        task.wait(k4)
    end
end
local function autoRollLoop()
    while not Library.Unloaded do
        if Toggles.AutoRoll.Value then
            gQ()
        end
        local kT = Options.RollDelay.Value or 5
        task.wait(kT)
    end
end
local function autoBuyLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuy.Value then
            onBuyCurrentResults()
        end
        local kW = Options.BuyDelay.Value or 0.5
        task.wait(kW)
    end
end
local function autoBuyTilesLoop()
    while not Library.Unloaded do
        if Toggles.AutoBuyTiles.Value then
            gp()
        end
        local la = Options.TileDelay.Value or 1
        task.wait(la)
    end
end
local function fn408(bW)
    local Character = gN.Character
    local je = Character and Character:FindFirstChild("HumanoidRootPart")
    if not je then
        return false
    end
    if (je.Position - bW).Magnitude > 10 then
        je.CFrame = CFrame.new(bW + Vector3.new(0, 4, 0))
        task.wait(0.1)
    end
    return true
end
local function fn416()
    go("CollectOresPrompt")
end
local function fn443()
    return Bases:FindFirstChild(gj)
end
local function onBuyTypes(ej)
    gM = gk(ej)
end
local function onUnload()
    Library:Unload()
end
local function fn478()
    local Character = gN.Character
    local iV = Character and Character:FindFirstChildWhichIsA("Humanoid")
    if not iV then
        return false
    end
    local iV_1 = gG()
    if not iV_1 then
        return false
    end
    if iV_1.Parent ~= Character then
        iV:EquipTool(iV_1)
        task.wait(0.1)
    end
    return true
end
local function fn501()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    select("#", "Make a Drill Farm unloaded")
end
local function fn510()
    local it = {}
    for k, v in { gN.Character, gN:FindFirstChild("Backpack") } do
        if v then
            for i, child in v:GetChildren() do
                local iu = child:IsA("Tool") and child:GetAttribute("Kind") == "Drill"
                if iu then
                    it[#it + 1] = child
                end
            end
        end
    end
    return it
end
Toggles = nil
gg = nil
onBuyCurrentResults = nil
gj = nil
gk = nil
GoldenMetadata = nil
gm = nil
go = nil
gp = nil
MutationsMetadata = nil
gr = nil
gs = nil
EnergySourcesMetadata = nil
gv = nil
Library = nil
gy = nil
DrillsMetadata = nil
gA = nil
gB = nil
gC = nil
Bases = nil
gG = nil
gH = nil
gI = nil
connection = nil
gM = nil
gN = nil
gO = nil
gP = nil
gQ = nil
VirtualUser = nil
gS = nil
Options = nil
RequestSpin = nil
local gd, gf, gh, gn, gu, gx, gD, RemoveDrill, gJ, gL, gT, BuyResult, gV
local Services, gZ_3
local g0_1
VirtualUser, gN = nil, nil
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
VirtualUser = game:GetService("VirtualUser")
gN = Players.LocalPlayer
if getgenv then
    getgenv().gethui = function()
        return gN:WaitForChild("PlayerGui")
    end
end
DrillsMetadata, EnergySourcesMetadata, MutationsMetadata, GoldenMetadata, Services, RequestSpin, BuyResult, RemoveDrill, g0_1, Library, Toggles, Options, gS, gA, gO = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local Source = ReplicatedStorage:WaitForChild("Source")
local Metadatas = Source:WaitForChild("Metadatas")
DrillsMetadata = require(Metadatas:WaitForChild("DrillsMetadata"))
EnergySourcesMetadata = require(Metadatas:WaitForChild("EnergySourcesMetadata"))
MutationsMetadata = require(Metadatas:WaitForChild("MutationsMetadata"))
GoldenMetadata = require(Metadatas:WaitForChild("GoldenMetadata"))
if (not Services or Toggles) and (not g0_1 and Options) and (g0_1 and RequestSpin or (Services or Options)) and (not Services or not Options or (not Services or not Toggles) or Toggles and Options and (not Toggles and Options)) or not ((not Services or Toggles) and (not g0_1 and Options) and (g0_1 and RequestSpin or (Services or Options)) and (not Services or not Options or (not Services or not Toggles) or Toggles and Options and (not Toggles and Options))) then
    Services = Source:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.5.1"):WaitForChild("knit"):WaitForChild("Services")
else
    Services:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.5.1"):WaitForChild("knit"):WaitForChild("Services")
end
local SpinDrillService = Services:WaitForChild("SpinDrillService")
RequestSpin = SpinDrillService:WaitForChild("RF"):WaitForChild("RequestSpin")
BuyResult = SpinDrillService:WaitForChild("RF"):WaitForChild("BuyResult")
local OnSpinStartedSignal = SpinDrillService:WaitForChild("RE"):WaitForChild("OnSpinStartedSignal")
local OnResultClearedSignal = SpinDrillService:WaitForChild("RE"):WaitForChild("OnResultClearedSignal")
local AutoReplaceGroup
if ((not DrillsMetadata or gO) and (not Metadatas and MutationsMetadata) and (gO and DrillsMetadata or (not DrillsMetadata or not SpinDrillService)) or (DrillsMetadata or DrillsMetadata or not MutationsMetadata and not DrillsMetadata or (DrillsMetadata and not MutationsMetadata or (not Metadatas or gO)))) and ((gO or gO or DrillsMetadata and not SpinDrillService) and (not DrillsMetadata and not MutationsMetadata and (DrillsMetadata or not MutationsMetadata)) or (gO or MutationsMetadata) and (gO and not BuyResult) and (not MutationsMetadata and DrillsMetadata or (not DrillsMetadata or SpinDrillService))) or not (((not DrillsMetadata or gO) and (not Metadatas and MutationsMetadata) and (gO and DrillsMetadata or (not DrillsMetadata or not SpinDrillService)) or (DrillsMetadata or DrillsMetadata or not MutationsMetadata and not DrillsMetadata or (DrillsMetadata and not MutationsMetadata or (not Metadatas or gO)))) and ((gO or gO or DrillsMetadata and not SpinDrillService) and (not DrillsMetadata and not MutationsMetadata and (DrillsMetadata or not MutationsMetadata)) or (gO or MutationsMetadata) and (gO and not BuyResult) and (not MutationsMetadata and DrillsMetadata or (not DrillsMetadata or SpinDrillService)))) then
    local PlacementService = Services:WaitForChild("PlacementService")
    RemoveDrill = PlacementService:WaitForChild("RF"):WaitForChild("RemoveDrill")
else
    local PlacementService = RemoveDrill:WaitForChild("PlacementService")
    PlacementService:WaitForChild("RF"):WaitForChild("RemoveDrill")
end
Library = getgenv().Library
pcall(fn351)
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
Toggles = Library.Toggles
Options = Library.Options
gS = "https://discord.gg/K7Qxnxkk46"
gO = fn46
local g9 = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Limited" }
gA = {}
for i, v in ipairs(g9) do
    gA[v] = i
end
gj, gP, gM, gI, Bases, gr, gh, gZ_3, gg, gL, gk, gf, onBuyCurrentResults, gQ, gC, go, gH, gB, gm, gG, gJ, gd, gu, gV, gs, gp, gy, gT, gn, gD, gx, gv = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local g0_2 = { "Drills", "Energy Sources" }
if ((gj and gI or (gI or gI)) and (not gC and not gC or gj and gC) and (gj and gI and (not gI or not gj) and (gj or gC or (not gI or not gI))) or (not gC and gI and (not gI or not gC) or not gI and not gj and (gC or not gj) or (not gI and not gj or not gI and not gI or not gC and gj and (not gC and gC)))) and not ((gj and gI or (gI or gI)) and (not gC and not gC or gj and gC) and (gj and gI and (not gI or not gj) and (gj or gC or (not gI or not gI))) or (not gC and gI and (not gI or not gC) or not gI and not gj and (gC or not gj) or (not gI and not gj or not gI and not gI or not gC and gj and (not gC and gC)))) then
    gL = "Player_" .. gj.UserId
    gk = fn50
    gg = fn306
    gP = fn290
    gN = {}
else
    gj = "Player_" .. gN.UserId
    gg = fn50
    gL = fn306
    gk = fn290
    gP = {}
end
gM = { Drills = true, ["Energy Sources"] = true }
gI = {}
OnSpinStartedSignal.OnClientEvent:Connect(onOnClientEvent)
OnResultClearedSignal.OnClientEvent:Connect(onOnClientEvent2)
gf = fn168
onBuyCurrentResults = function()
    local ia_1
    local h8 = tonumber(Options.BuyReserve.Value) or 0
    local h8_2
    for k, v in gI do
        local ij = v
        if Library.Unloaded or not Toggles.AutoBuy.Value then
            return
        end
        if gf(ij) then
            if not (gL() - ij.Price < h8) then
                h8_2, ia_1 = pcall(function()
                    return BuyResult:InvokeServer(ij.SpinId)
                end)
                if h8_2 and ia_1 then
                    gI[k] = nil
                    if Toggles.BuyNotify.Value then
                        Library:Notify(("Bought %s (%s)"):format(ij.Name, tostring(ij.Rarity)))
                    end
                    task.wait(0.15)
                end
            end
        end
    end
end
gQ = fn155
Bases = workspace:WaitForChild("Map"):WaitForChild("Bases")
gC = fn443
go = function(a9)
    local ik = gC()
    if not ik then
        return
    end
    for i, descendant in ik:GetDescendants() do
        local is = descendant
        local ik_1 = is.Name == a9 and is:IsA("ProximityPrompt")
        if ik_1 then
            is.Enabled = true
            pcall(function()
                fireproximityprompt(is)
            end)
            return
        end
    end
end
if gg and not gV and (not gD and not gg) or (gZ_3 or gg) and (gg or not gg) or not (gg and not gV and (not gD and not gg) or (gZ_3 or gg) and (gg or not gg)) then
    gH = fn416
    gB = fn65
    gr = {}
else
    gr = fn416
    gH = fn65
    gB = {}
end
gm = fn510
gG = fn283
gJ = fn478
gh = { "Cell1", "Cell2", "Cell3", "Cell4" }
gd = fn100
gu = fn408
gV = fn88
gs = function()
    local jq = gC()
    local jr = jq and jq:FindFirstChild("Grid")
    if not jr then
        return
    end
    if not gJ() then
        return
    end
    local jr_1 = gd()
    for i, descendant in jr:GetDescendants() do
        if Library.Unloaded or not Toggles.AutoPlace.Value then
            return
        end
        local attr = descendant:GetAttribute("Coord")
        local js = attr and descendant:GetAttribute("Locked") ~= true
        if js then
            for k, v in gh do
                local js_1 = descendant:FindFirstChild(v)
                local jt = js_1 and js_1:FindFirstChild("PlacePromptAttach")
                local ju = jt
                if jt then
                    jt = ju:FindFirstChild("PlacePrompt")
                end
                local jp = jt
                local jt_1 = jp and jp:IsA("ProximityPrompt") and jp.Enabled and not jr_1[attr .. "_" .. v]
                if jt_1 then
                    if gu(js_1.Position) then
                        pcall(function()
                            fireproximityprompt(jp)
                        end)
                        task.wait(0.15)
                        jr_1 = gd()
                    end
                end
            end
        end
    end
end
gp = function()
    local jJ = gC()
    local jK = jJ and jJ:FindFirstChild("Grid")
    if not jK then
        return
    end
    local jK_1 = tonumber(Options.TileReserve.Value) or 0
    for i, descendant in jK:GetDescendants() do
        if Library.Unloaded or not Toggles.AutoBuyTiles.Value then
            return
        end
        local jJ_3 = descendant:GetAttribute("Coord") and descendant:GetAttribute("Locked") == true and descendant:GetAttribute("OwnerUserId") == gN.UserId
        if jJ_3 then
            local UnlockPromptAttach = descendant:FindFirstChild("UnlockPromptAttach")
            local jK_2 = UnlockPromptAttach and UnlockPromptAttach:FindFirstChild("UnlockPrompt")
            local jI = jK_2
            local jJ_5 = jI and jI:IsA("ProximityPrompt")
            if jJ_5 then
                local jJ_6 = gV(jI.ObjectText)
                if gL() - jJ_6 >= jK_1 then
                    if gu(descendant:GetPivot().Position) then
                        jI.Enabled = true
                        pcall(function()
                            fireproximityprompt(jI)
                        end)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end
gy = fn43
gT = fn126
gn = fn120
gD = fn90
gx = function(dx, dy)
    local Character = gN.Character
    local kD = Character and Character:FindFirstChildWhichIsA("Humanoid")
    local PlacePromptAttach = dy:FindFirstChild("PlacePromptAttach")
    local kF = PlacePromptAttach and PlacePromptAttach:FindFirstChild("PlacePrompt")
    local kD_2 = not kD
    local kB = kF
    if not kD_2 then
        kD_2 = not kB
    end
    if not kD_2 then
        kD_2 = not kB:IsA("ProximityPrompt")
    end
    if kD_2 then
        return false
    elseif not gu(dy.Position) then
        return false
    else
        if dx.Parent ~= Character then
            kD:EquipTool(dx)
            task.wait(0.1)
        end
        kB.Enabled = true
        pcall(function()
            fireproximityprompt(kB)
        end)
        return true
    end
end
gv = function()
    local kK_1
    local kL_1, kL_2
    local kI = tonumber(Options.ReplaceMinGain.Value) or 0
    local kI_2, kI_3
    local kP = false
    repeat
        local kH
        if not Library.Unloaded and Toggles.AutoReplace.Value then
            kK_1, kI_2 = gT()
            if not kK_1 then
                return
            end
            kH, kL_1 = gD()
            if not kH or kI_2 - kL_1 < kI or kI_2 <= kL_1 then
                return
            end
            kL_2, kI_3 = kH.Name:match("^(.+)_(Cell%d+)$")
            local kM_1 = kL_2 and gn(kL_2, kI_3)
            if not kM_1 then
                return
            end
            local Name = DrillsMetadata[kH:GetAttribute("DrillId")].Name
            local kM_2 = pcall(function()
                return RemoveDrill:InvokeServer(kH)
            end)
            if not kM_2 then
                return
            end
            task.wait(0.2)
            gx(kK_1, kM_1)
            if Toggles.ReplaceNotify.Value then
                Library:Notify(("Replaced %s with %s"):format(Name, kK_1.Name))
            end
            task.wait(0.3)
        else
            kP = true
        end
    until kP
end
local Window = Library:CreateWindow({
    Title = "Make a Drill Farm",
    Footer = "Tempo Hub",
    Size = UDim2.fromOffset(900, 640),
    ShowCustomCursor = false
})
Library.ShowCustomCursor = false
local g1_1 = { Main = Window:AddTab("Main", "drill"), Settings = Window:AddTab("Settings", "settings") }
for k, v in g1_1 do
    fn287(v)
end
AutoReplaceGroup, connection = nil, nil
local AutoRollGroup = g1_1.Main:AddLeftGroupbox("Auto Roll", "dices")
AutoRollGroup:AddToggle("AutoRoll", { Text = "Auto Roll", Default = false })
AutoRollGroup:AddSlider("RollDelay", { Text = "Roll Delay", Default = 5, Min = 3.5, Max = 20, Rounding = 1 })
local AutoBuyGroup = g1_1.Main:AddRightGroupbox("Auto Buy", "shopping-cart")
AutoBuyGroup:AddToggle("AutoBuy", { Text = "Auto Buy", Default = false })
AutoBuyGroup:AddDropdown("BuyMode", {
    Text = "Buy Mode",
    Values = { "Buy All", "Minimum Rarity", "Specific Rarities" },
    Default = "Minimum Rarity",
    Multi = false
})
AutoBuyGroup:AddDropdown("BuyMinRarity", { Text = "Minimum Rarity", Values = g9, Default = "Rare", Multi = false })
AutoBuyGroup:AddDropdown("BuyRarities", { Text = "Specific Rarities", Values = g9, Default = {}, Multi = true, Callback = onBuyRarities })
AutoBuyGroup:AddDropdown("BuyTypes", {
    Text = "Item Types",
    Values = g0_2,
    Default = { "Drills", "Energy Sources" },
    Multi = true,
    Callback = onBuyTypes
})
AutoBuyGroup:AddInput("BuyMaxPrice", { Text = "Max Price (0 = off)", Default = "0", Numeric = true, Finished = true })
AutoBuyGroup:AddInput("BuyReserve", { Text = "Keep Cash Reserve", Default = "0", Numeric = true, Finished = true })
AutoBuyGroup:AddSlider("BuyDelay", { Text = "Buy Loop Delay", Default = 0.5, Min = 0.2, Max = 5, Rounding = 1 })
AutoBuyGroup:AddToggle("BuyNotify", { Text = "Notify On Buy", Default = true })
AutoBuyGroup:AddButton({ Text = "Buy Current Results", Func = onBuyCurrentResults })
local AutoOresGroup = g1_1.Main:AddLeftGroupbox("Auto Ores", "pickaxe")
AutoOresGroup:AddToggle("AutoCollectOres", { Text = "Auto Collect Ores", Default = false })
AutoOresGroup:AddToggle("AutoDepositOres", { Text = "Auto Deposit Ores", Default = false })
AutoOresGroup:AddSlider("OreDelay", { Text = "Ore Loop Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
local AutoPlaceGroup = g1_1.Main:AddRightGroupbox("Auto Place", "layout-grid")
if ((AutoBuyGroup or not AutoBuyGroup or (AutoPlaceGroup or not AutoRollGroup)) and (not AutoPlaceGroup or not connection or (AutoRollGroup or AutoRollGroup)) or (AutoPlaceGroup or not AutoPlaceGroup) and (AutoRollGroup and not AutoRollGroup) and ((not connection or AutoPlaceGroup) and (AutoPlaceGroup or not AutoRollGroup))) and ((not AutoPlaceGroup or connection) and (not AutoRollGroup or not AutoBuyGroup) or not AutoRollGroup and connection and (AutoRollGroup and AutoRollGroup) or (connection and not AutoPlaceGroup or not AutoPlaceGroup and AutoBuyGroup) and (AutoPlaceGroup or AutoPlaceGroup or (AutoRollGroup or not connection))) and not (((AutoBuyGroup or not AutoBuyGroup or (AutoPlaceGroup or not AutoRollGroup)) and (not AutoPlaceGroup or not connection or (AutoRollGroup or AutoRollGroup)) or (AutoPlaceGroup or not AutoPlaceGroup) and (AutoRollGroup and not AutoRollGroup) and ((not connection or AutoPlaceGroup) and (AutoPlaceGroup or not AutoRollGroup))) and ((not AutoPlaceGroup or connection) and (not AutoRollGroup or not AutoBuyGroup) or not AutoRollGroup and connection and (AutoRollGroup and AutoRollGroup) or (connection and not AutoPlaceGroup or not AutoPlaceGroup and AutoBuyGroup) and (AutoPlaceGroup or AutoPlaceGroup or (AutoRollGroup or not connection)))) then
    AutoReplaceGroup:AddToggle("AutoPlace", { Text = "Auto Place Drills", Default = false })
    AutoReplaceGroup:AddDropdown("PlaceDrillMode", {
        Default = "Best (Ores/s)",
        Values = { "Worst (Ores/s)", "Specific Rarities", "Best (Ores/s)" },
        Multi = false,
        Text = "Drill To Place"
    })
    AutoReplaceGroup:AddDropdown("PlaceRarities", {
        Callback = onPlaceRarities,
        Default = {},
        Text = "Place Rarities",
        Multi = true,
        Values = AutoPlaceGroup
    })
    AutoReplaceGroup:AddSlider("PlaceDelay", { Text = "Place Loop Delay", Min = 0.2, Max = 10, Default = 1, Rounding = 1 })
    AutoReplaceGroup:AddToggle("AutoBuyTiles", { Text = "Auto Buy Tiles", Default = false })
    AutoReplaceGroup:AddInput("TileReserve", { Numeric = true, Finished = true, Default = "0", Text = "Keep Cash Reserve" })
    AutoReplaceGroup:AddSlider("TileDelay", { Default = 1, Max = 10, Rounding = 1, Min = 0.2, Text = "Tile Loop Delay" })
    g1_1 = g9.Main:AddRightGroupbox("Auto Replace", "replace")
else
    AutoPlaceGroup:AddToggle("AutoPlace", { Text = "Auto Place Drills", Default = false })
    AutoPlaceGroup:AddDropdown("PlaceDrillMode", {
        Text = "Drill To Place",
        Values = { "Best (Ores/s)", "Worst (Ores/s)", "Specific Rarities" },
        Default = "Best (Ores/s)",
        Multi = false
    })
    AutoPlaceGroup:AddDropdown("PlaceRarities", { Text = "Place Rarities", Values = g9, Default = {}, Multi = true, Callback = onPlaceRarities })
    AutoPlaceGroup:AddSlider("PlaceDelay", { Text = "Place Loop Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
    AutoPlaceGroup:AddToggle("AutoBuyTiles", { Text = "Auto Buy Tiles", Default = false })
    AutoPlaceGroup:AddInput("TileReserve", { Text = "Keep Cash Reserve", Default = "0", Numeric = true, Finished = true })
    AutoPlaceGroup:AddSlider("TileDelay", { Text = "Tile Loop Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
    AutoReplaceGroup = g1_1.Main:AddRightGroupbox("Auto Replace", "replace")
end
AutoReplaceGroup:AddToggle("AutoReplace", { Text = "Auto Replace With Better Drill", Default = false })
AutoReplaceGroup:AddInput("ReplaceMinGain", { Text = "Min Ores/s Gain", Default = "0", Numeric = true, Finished = true })
AutoReplaceGroup:AddSlider("ReplaceDelay", { Text = "Replace Loop Delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1 })
AutoReplaceGroup:AddToggle("ReplaceNotify", { Text = "Notify On Replace", Default = true })
local MenuGroup = g1_1.Settings:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddLabel("UI Keybind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "UI Keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true, Callback = onAntiAfk })
MenuGroup:AddButton("Unload", onUnload)
Library.ToggleKeybind = Options.MenuKeybind
Library:OnUnload(fn501)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Mint")
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/MakeADrillFarm")
SaveManager:BuildConfigSection(g1_1.Settings)
ThemeManager:ApplyToTab(g1_1.Settings)
ThemeManager:LoadDefault()
SaveManager:LoadAutoloadConfig()
task.spawn(autoRollLoop)
task.spawn(autoBuyLoop)
task.spawn(autoCollectOresLoop)
task.spawn(autoPlaceLoop)
task.spawn(autoReplaceLoop)
task.spawn(autoBuyTilesLoop)
Library:Notify("Make a Drill Farm loaded")
end)(...)
