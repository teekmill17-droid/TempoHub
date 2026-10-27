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
getgenv().TempoHoodSubtitle = "LOAD THE TRUCK!"
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
local fW
local gh
local fD
local gk
local fZ
local f1
local fG
local fJ
local gn
local client
local f7
local fP
local ga
local fS
local fV
local gg
local f0
local gm
local fF
local fI
local f3
local fL
local f6
local f9
local fO
local fR
local gc
local fX
local fE
local f_
local RebirthsInfo
local connection
local go
local f2
local fK
local f5
local fN
local connection2
local Options
local VirtualUser
local Toggles
local ge
local function fn8(W, X, Y)
    return string.format("<b>%s</b> %s %s", W, ga("-", "#5a6070"), ga(X, Y))
end
local function onUnload()
    f7:Unload()
end
local function fn36(cC)
    local DiscordGroup = cC:AddLeftGroupbox("Discord", "message-circle", true, false, true)
    DiscordGroup:AddButton({ Text = "Join Discord to Make Money", Func = gn })
    DiscordGroup:AddButton({ Text = "Join Discord for Keyless Scripts", Func = gn })
end
local function onCopyJoinScript_JobID()
    local cT = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)', game.PlaceId, fE)
    fN(cT, "Copied join script to clipboard")
end
local function fn39()
    fN(fS, "Copied Discord invite to clipboard")
end
local function fn118(aT, aU)
    local Deposits = aT:FindFirstChild("Deposits")
    local hx = Deposits and Deposits:FindFirstChild("Deposit" .. tostring(aU))
    if not hx then
        return false
    end
    for i, child in ipairs(hx:GetChildren()) do
        local hw_2 = child:IsA("Model") and child:GetAttribute("BoxType") and child:GetAttribute("InDeposit")
        if hw_2 then
            local hw_3 = not child:GetAttribute("CarriedBy") and not child:GetAttribute("ReservedByWorker")
            if hw_3 then
                return true
            end
        end
    end
    return false
end
local function onInputChanged(dr)
    local UserInputType = dr.UserInputType
    if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Gamepad1 then
        fG = tick()
    end
end
local function fn140(aH)
    local ho = client:get({ "BoxTiers" })
    local hp = ho and ho[aH]
    local ho_1 = hp
    if hp then
        hp = ho_1.unlocked
    end
    if hp then
        return true
    end
    local ho_2 = client:get({ "Rebirths" }) or 0
    local ht = 1
    while true do
        if not (ht <= ho_2) then
            return false
        end
        local ho_3 = RebirthsInfo.Unlocks[ht]
        local hp_2 = ho_3 and ho_3.BoxTiers and table.find(ho_3.BoxTiers, aH)
        if hp_2 then
            break
        end
        ht += 1
    end
    return true
end
local function fn208()
    local he = client:get({ "Cash" }) or 0
    return he
end
local function fn250()
    local i3_1
    local i2_1
    if identifyexecutor then
        i3_1, i2_1 = identifyexecutor()
        local i4 = i3_1 ~= ""
        local i5 = type(i3_1) == "string" and i4
        if i5 then
            local i4_1 = type(i2_1) == "string" and i2_1 ~= "" and i3_1 .. " " .. i2_1
            f5 = i4_1 or i3_1
        end
    end
end
local function onInputBegan()
    fG = tick()
end
local function worker4()
    while not f7.Unloaded do
        task.wait(2)
        if gc("AntiAfk") then
            local jp = tick() - fG
            local jq = tick() - gm
            if jp >= 300 and jq >= 60 then
                pcall(f0)
            else
                if jp < 300 and jq >= 300 then
                    pcall(f0)
                end
            end
        end
    end
end
local function fn292()
    local iW = client:get({ "Rebirths" }) or 0
    local iW_1 = RebirthsInfo.Requirements[iW + 1]
    if not iW_1 then
        return
    end
    local iX_1 = fW()
    if iX_1 >= (iW_1.Cash or math.huge) then
        pcall(function()
            fZ:FireServer()
        end)
    end
end
local function worker3()
    while not f7.Unloaded do
        local jt = fR("FarmDelay", 0.2)
        if gc("AutoPickupBoxes") then
            local ju = fI.GetMaxBoxes(f1)
            local jv = f1:GetAttribute("BoxCount") or 0
            if jv < ju then
                pcall(fK)
            elseif gc("AutoLoadBoxes") then
                pcall(go)
            end
        elseif gc("AutoLoadBoxes") then
            pcall(go)
        end
        task.wait(jt)
    end
end
local function fn326()
    return fI.GetPlot()
end
local function fn332()
    local CurrentCamera = f6.CurrentCamera
    if not CurrentCamera then
        return
    end
    VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
    task.wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
    gm = tick()
end
local function fn353()
    connection:Disconnect()
    connection2:Disconnect()
end
local function fn362(a2)
    local ActiveVehicles = f6:FindFirstChild("ActiveVehicles")
    local hG = not a2
    local hH = not ActiveVehicles
    local hL = if hH then 1 else 0
    local hJ = 1487 * hL + 4011 * (1 - hL)
    local hK = 318 * hL + 3424 * (1 - hL)
    if not ((hJ * 1606 + hK * 906 + hJ * hK) % 16777213 == 3149096) then
        hH = hG
    end
    if hH then
        return nil
    end
    for i, child in ipairs(ActiveVehicles:GetChildren()) do
        local hF_1 = child:GetAttribute("PlotName") == a2.Name and child:GetAttribute("OwnerUserId") == f1.UserId and child:GetAttribute("Parked") == true
        if hF_1 then
            return child
        end
    end
    return nil
end
local function fn365(A, B)
    return fF[A].Price < fF[B].Price
end
local function fn372(aD)
    local hm = fL()
    if not hm then
        return false
    end
    hm:PivotTo(CFrame.new(aD))
    return true
end
local function onRscripts()
    fN(fP, "Copied Rscripts profile to clipboard")
end
local function fn379(M, N)
    if setclipboard then
        setclipboard(M)
    elseif toclipboard then
        toclipboard(M)
    end
    f7:Notify(N)
end
local function fn403()
    local hS = fO()
    local hT = fL()
    if not hS or not hT then
        return
    end
    local CollectionParts = hS:FindFirstChild("CollectionParts")
    if not CollectionParts then
        return
    end
    local hU_1 = f1:GetAttribute("BoxCount") or 0
    local hU_2 = fI.GetMaxBoxes(f1)
    if hU_1 >= hU_2 then
        return
    end
    local h_ = 1
    while true do
        if h_ <= 5 then
            local h0 = h_
            local hV_2 = f1:GetAttribute("BoxCount") or 0
            if hV_2 >= hU_2 then
                break
            end
            if f3(hS, h0) then
                local hV_3 = CollectionParts:FindFirstChild("Collect" .. tostring(h0))
                local hW = hV_3 and hV_3:IsA("BasePart")
                if hW then
                    gh(hV_3.Position)
                    task.wait(0.25)
                end
            end
            h_ += 1
            continue
        end
        return
    end
    return
end
local function fn409(aq)
    local ha = Options[aq]
    return ha and ha.Value or {}
end
local function fn421()
    local Character = f1.Character
    if not Character then
        return nil
    end
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then
        return nil
    end
    return Character, HumanoidRootPart
end
local function worker2()
    while not f7.Unloaded do
        if gc("AutoBuyUpgrades") then
            pcall(gg)
        end
        if gc("AutoBuyHires") then
            pcall(f2)
        end
        if gc("AutoBuyBoxes") then
            pcall(fX)
        end
        if gc("AutoRebirth") then
            pcall(fD)
        end
        task.wait(fR("ShopDelay", 1))
    end
end
local function fn436(ak, al)
    local g7 = Options[ak]
    local g8 = g7 and tonumber(g7.Value)
    return g8 or al
end
local function fn439()
    local h2 = fO()
    local h3 = fL()
    if not h2 or not h3 then
        return
    end
    local h3_1 = (f1:GetAttribute("BoxCount"))
    local h9 = if h3_1 then 1 else 0
    local h7 = 2233 * h9 + 746 * (1 - h9)
    local h8 = 3466 * h9 + 92 * (1 - h9)
    if not ((h7 * 3093 + h8 * 129 + h7 * h8) % 16777213 == 15093361) then
        h3_1 = 0
    end
    if h3_1 <= 0 then
        return
    end
    local h3_2 = ge(h2)
    if not h3_2 then
        return
    end
    local h4_1 = h3_2:GetAttribute("StopIndex") or 1
    local DropOffParts = h2:FindFirstChild("DropOffParts")
    local h2_1 = DropOffParts and DropOffParts:FindFirstChild("DropOff" .. tostring(h4_1))
    local h2_2 = not h2_1 or not h2_1:IsA("BasePart")
    if h2_2 then
        return
    end
    gh(h2_1.Position)
    task.wait(0.3)
end
local function worker()
    local jb_1
    while true do
        task.wait(1)
        if f7.Unloaded then
            break
        end
        local ja = math.floor(os.clock() - f_)
        if ja < 60 then
            jb_1 = ja .. "s"
        elseif ja < 3600 then
            jb_1 = string.format("%dm %ds", math.floor((ja) / (60)), ja % 60)
        else
            jb_1 = string.format("%dh %dm", math.floor((ja) / (3600)), math.floor((ja % 3600) / (60)))
        end
        fJ:SetText(fV("Session time", jb_1, gk))
    end
end
local function fn450(af)
    local g4 = Toggles[af]
    return g4 ~= nil and g4.Value == true
end
local function fn483(T, U)
    return string.format('<font color="%s">%s</font>', U, T)
end
local function fn493()
    local ir = client:get({ "Workers" }) or 0
    local ir_1 = client:get({ "MaxWorkers" }) or 0
    if ir_1 <= 0 or ir >= ir_1 then
        return
    end
    local ir_3 = fI.GetHireWorkerPrice(ir)
    if fW() >= ir_3 then
        pcall(function()
            f9:FireServer()
        end)
    end
end
fD = nil
fE = nil
fF = nil
fG = nil
connection = nil
fI = nil
fJ = nil
fK = nil
fL = nil
client = nil
fN = nil
fO = nil
fP = nil
Options = nil
fR = nil
fS = nil
Toggles = nil
fV = nil
fW = nil
fX = nil
fZ = nil
f_ = nil
f0 = nil
f1 = nil
f2 = nil
f3 = nil
f5 = nil
f6 = nil
f7 = nil
connection2 = nil
f9 = nil
ga = nil
VirtualUser = nil
gc = nil
ge = nil
gg = nil
gh = nil
gk = nil
RebirthsInfo = nil
gm = nil
gn = nil
go = nil
local fU, fY, BoxTier, gd, gf, gi, gj
local gp_1, gp_3
local GameInfoGroup
local gv_1
local gu_1
local gt_1
local gs_1, gs_2
local gr_3, gr_4
gp_1, gt_1, gv_1, VirtualUser, f6, f1, gu_1, fS, fP, client, fI, fF, RebirthsInfo, gs_1, gd, f9, BoxTier, fZ, fU = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
local gq = 1
local AccountGroup
repeat
    local gw_1 = (gq * 3 + 1) % 7 + 1
    if gw_1 <= 4 then
        if gw_1 <= 2 then
            if gw_1 <= 1 then
                local gx_1 = {
                    "locuxagwykrl",
                    "rxjocaq",
                    "jvpwifr",
                    "egwmurpqbza",
                    "matieskg",
                    "rttwcidt",
                    "itqmpysxdjv",
                    "ywgmugfxnbs"
                }
                if gx_1[(gq * 86 + 13) % 8 + 1] <= gx_1[(gq * 86 + 13) % 8 + 1] then
                    fS = "https://discord.gg/K7Qxnxkk46"
                    fP = "https://discord.gg/K7Qxnxkk46"
                    local DataService = require(gt_1:WaitForChild("DataService"))
                    client = DataService.client
                    fI = require(gt_1:WaitForChild("Modules"):WaitForChild("Formulas"))
                else
                    fI = "https://discord.gg/K7Qxnxkk46"
                    gt_1 = "https://discord.gg/K7Qxnxkk46"
                    fS = require(client:WaitForChild("DataService"))
                    fP = require(client:WaitForChild("Modules"):WaitForChild("Formulas"))
                end
                gq = (gq + 19) % 28
            else
                local gx_2 = (vector.create((gq * 5 + 9) % 11 + 1, (gq * 9 + 2) % 13 + 1, (gq * 5 + 14) % 17 + 1))
                local gy_1 = (vector.create((gq * 7 + 3) % 11 + 1, (gq * 1 + 10) % 13 + 1, (gq * 12 + 7) % 17 + 1))
                local j3 = vector.dot(gx_2, gy_1)
                if j3 * j3 >= vector.dot(gx_2, gx_2) * vector.dot(gy_1, gy_1) + 1 then
                    gt_1 = require(RebirthsInfo:WaitForChild("Modules"):WaitForChild("BoxTiersInfo"))
                    fF = require(RebirthsInfo:WaitForChild("Modules"):WaitForChild("RebirthsInfo"))
                else
                    fF = require(gt_1:WaitForChild("Modules"):WaitForChild("BoxTiersInfo"))
                    RebirthsInfo = require(gt_1:WaitForChild("Modules"):WaitForChild("RebirthsInfo"))
                end
                gq = (gq + 19) % 28
            end
        elseif gw_1 <= 3 then
            local gx_3 = (vector.create((gq * 2 + 9) % 11 + 1, (gq * 11 + 12) % 13 + 1, (gq * 3 + 2) % 17 + 1))
            local gy_2 = (vector.create((gq * 2 + 5) % 11 + 1, (gq * 8 + 2) % 13 + 1, (gq * 2 + 7) % 17 + 1))
            local gz_1 = (vector.create((gq * 3 + 1) % 11 + 1, (gq * 9 + 5) % 13 + 1, (gq * 15 + 14) % 17 + 1))
            if vector.dot(vector.cross(gx_3, gy_2), gz_1) == vector.dot(vector.cross(gy_2, gz_1), gx_3) + 4 then
                gt_1 = BoxTier:WaitForChild("Events")
                gs_1 = gt_1:WaitForChild("Upgrade")
                fZ = gt_1:WaitForChild("HireWorker")
                f9 = gt_1:WaitForChild("BoxTier")
                gd = gt_1:WaitForChild("Rebirth")
            else
                gs_1 = gt_1:WaitForChild("Events")
                gd = gs_1:WaitForChild("Upgrade")
                f9 = gs_1:WaitForChild("HireWorker")
                BoxTier = gs_1:WaitForChild("BoxTier")
                fZ = gs_1:WaitForChild("Rebirth")
            end
            gq = (gq + 12) % 28
        else
            if (gq * 3 + 1) * 9 % 4 == ((gq * 3 + 1) * 9 + 9) % 4 then
            else
                fU = {}
            end
            gq = (gq + 5) % 28
        end
    elseif gw_1 <= 6 then
        if gw_1 <= 5 then
            local jQ = bit32.rrotate(bit32.bxor(bit32.lrotate(gq, 2), string.byte(tostring(gt_1))), 3)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(jQ, 3891933089), 3697943524), (bit32.bxor(bit32.band(jQ, 403034206), 67695851))), 3697943524), 67695851) ~= jQ then
                fI = game:GetService("Players")
            else
                gp_1 = game:GetService("Players")
            end
            gq = (gq + 12) % 28
        else
            if (gs_1 and fZ and (not fZ and gs_1) or fZ and f1 and (not f1 or fZ)) and (f1 and f1 and (not fU and f1) and (not fU or fU or f1 and f1)) and not ((gs_1 and fZ and (not fZ and gs_1) or fZ and f1 and (not f1 or fZ)) and (f1 and f1 and (not fU and f1) and (not fU or fU or f1 and f1))) then
                fF = game:GetService("ReplicatedStorage")
            else
                gt_1 = game:GetService("ReplicatedStorage")
            end
            gq = (gq + 12) % 28
        end
    else
        if (gq * 3 + 7) * 9 % 4 == ((gq * 3 + 7) * 9 + 12) % 4 then
            gv_1 = game:GetService("UserInputService")
            VirtualUser = game:GetService("VirtualUser")
            f6 = game:GetService("Workspace")
            f1 = gp_1.LocalPlayer
            gu_1 = "Load The Truck"
        else
            gp_1 = game:GetService("UserInputService")
            f6 = game:GetService("VirtualUser")
            f1 = game:GetService("Workspace")
            gu_1 = VirtualUser.LocalPlayer
            gv_1 = "Load The Truck"
        end
        gq = (gq + 19) % 28
    end
until (gq * 3 + 8) % 28 == 25
for k, v in pairs(fF) do
    local gp_2 = type(v) == "table" and type(v.Price) == "number"
    if gp_2 and k ~= "Rainbow" then
        table.insert(fU, k)
    end
end
table.sort(fU, fn365)
gj = {}
for k in pairs(fI.UpgradesConfig) do
    table.insert(gj, k)
end
table.sort(gj)
gr_3, f7, Toggles, Options, gk, gp_3, fN, gn, ga, fV, gc, fR, gi, fW, fO, fL, gh, fY, f3, ge, fK, go, gg, f2, gf, fX, fD, gs_2 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
if ((not fD and false or not fN and fN) and (not gp_3 and not fD or (fD or fN)) or gp_3 and 54 and (not fN and fD) and (fD and (gp_3 or not fN))) and not ((not fD and false or not fN and fN) and (not gp_3 and not fD or (fD or fN)) or gp_3 and 54 and (not fN and fD) and (fD and (gp_3 or not fN))) then
else
    gr_3 = ""
end
f7 = getgenv().Library
local gz_2 = getgenv().ThemeManager
local gy_3 = getgenv().SaveManager
Toggles = f7.Toggles
Options = f7.Options
fN = fn379
gn = fn39
ga = fn483
fV = fn8
local gw_2 = "#7fd47f"
local gt_2 = "#6ec1ff"
gk = "#e8a34d"
local gA = "#8b93a3"
gc = fn450
fR = fn436
gi = fn409
fW = fn208
fO = fn326
fL = fn421
gh = fn372
fY = fn140
f3 = fn118
ge = fn362
fK = fn403
go = fn439
gg = function()
    local id = gi("SelectedUpgrades")
    local ie = fW()
    for i, v in ipairs(gj) do
        local iq = v
        if id[iq] then
            local ig = fI.UpgradesConfig[iq]
            if ig then
                local ih = client:get({ "Upgrades", iq }) or 1
                if ih < ig.maxLevel then
                    local ig_1 = fI.GetUpgradeCashPrice(iq, ih)
                    if ie >= ig_1 then
                        pcall(function()
                            gd:FireServer(iq, "Cash")
                        end)
                        task.wait(0.15)
                        ie = fW()
                    end
                end
            end
        end
    end
end
f2 = fn493
gf = function()
    local iw = client:get({ "BoxTiers" })
    if not iw then
        return
    end
    local ix = -1
    local iv
    for i, v in ipairs(fU) do
        local iy_1 = iw[v]
        if iy_1 and iy_1.owned then
            local iy_2 = fF[v].Price or 0
            if iy_2 >= ix then
                ix = iy_2
                iv = v
            end
        end
    end
    if iv and iw[iv] and not iw[iv].equipped then
        pcall(function()
            BoxTier:FireServer("Equip", iv)
        end)
    end
end
fX = function()
    local iK = client:get({ "BoxTiers" })
    if not iK then
        return
    end
    local iL = fW()
    for i, v in ipairs(fU) do
        local iV = v
        local iM = iK[iV]
        local iN = fF[iV]
        local iO = iM and iN and not iM.owned and fY(iV)
        if iO then
            local iN_1 = iN.Price or 0
            if iN_1 > 0 and iL >= iN_1 then
                pcall(function()
                    BoxTier:FireServer("Buy", iV)
                end)
                task.wait(0.15)
                iL = fW()
            end
        end
    end
    gf()
end
fD = fn292
local Window = f7:CreateWindow({
    Title = "Tempo Hub",
    Footer = { { Text = fS, Copyable = true }, "|", gu_1 },
    Icon = 12645376577,
    NotifySide = "Right",
    ShowCustomCursor = false,
    CornerRadius = 10
})
local gx_4 = {
    Info = Window:AddTab("Info", "info"),
    Main = Window:AddTab("Main", "gamepad-2"),
    Settings = Window:AddTab("Settings", "settings")
}
if ((gg or gw_2 or gy_3 and false) and ("#7fd47f" or (not gg or gy_3)) or (false or not fW) and (gg and gw_2) and (not f7 or gw_2 or (not f7 or not gy_3))) and not ((gg or gw_2 or gy_3 and false) and ("#7fd47f" or (not gg or gy_3)) or (false or not fW) and (gg and gw_2) and (not f7 or gw_2 or (not f7 or not gy_3))) then
    gg = fn36
else
    gs_2 = fn36
end
for k, v in gx_4 do
    gs_2(v)
end
f5, AccountGroup, GameInfoGroup, fJ, fE, gr_4 = nil, nil, nil, nil, nil, nil
local gp_5 = 8
repeat
    local gs_3 = (gp_5 * 2 + 0) % 3 + 1
    if gs_3 <= 2 then
        if gs_3 <= 1 then
            if (fJ or gp_5) and (GameInfoGroup and not fJ) and (not f5 or not gp_5 or (gp_5 or fE)) or not ((fJ or gp_5) and (GameInfoGroup and not fJ) and (not f5 or not gp_5 or (gp_5 or fE))) then
                gr_4 = #fE > 18
            else
                fE = #gr_4 > 18
            end
            gp_5 = (gp_5 + 14) % 24
        else
            local ke = bit32.rrotate(bit32.bxor(bit32.lrotate(gp_5, 3), string.byte(tostring(gr_4))), 8)
            if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(ke, 144582519), 3023800447), (bit32.bxor(bit32.band(ke, 4150384776), 4078422082))), 3023800447), 4078422082) == ke then
                f5 = "Unknown"
                pcall(fn250)
                AccountGroup = gx_4.Info:AddLeftGroupbox("Account", "circle-user")
                AccountGroup:AddLabel(fV("User", f1.Name, gw_2), true)
                AccountGroup:AddLabel(fV("Status", "Keyless", gw_2), true)
                AccountGroup:AddLabel(fV("Executor", f5, gw_2), true)
                GameInfoGroup = gx_4.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                GameInfoGroup:AddLabel(ga(gu_1 .. " [" .. tostring(game.PlaceId) .. "]", gt_2), true)
                GameInfoGroup:AddLabel(fV("Place ID", tostring(game.PlaceId), gt_2), true)
                fJ = GameInfoGroup:AddLabel(fV("Session time", "0s", gk), true)
            else
                gx_4 = "Unknown"
                pcall(fn250)
                ga = fJ.Info:AddLeftGroupbox("Account", "circle-user")
                ga:AddLabel(gk("User", AccountGroup.Name, fV), true)
                ga:AddLabel(gk("Status", "Keyless", fV), true)
                ga:AddLabel(gk("Executor", "Unknown", fV), true)
                gw_2 = fJ.Info:AddLeftGroupbox("Game Info", "gamepad-2")
                gw_2:AddLabel(GameInfoGroup(f1 .. " [" .. tostring(game.PlaceId) .. "]", gu_1), true)
                gw_2:AddLabel(gk("Place ID", tostring(game.PlaceId), gu_1), true)
                f5 = gw_2:AddLabel(gk("Session time", "0s", gt_2), true)
            end
            gp_5 = (gp_5 + 8) % 24
        end
    else
        local gs_4 = (vector.create((gp_5 * 5 + 5) % 11 + 1, (gp_5 * 7 + 6) % 13 + 1, (gp_5 * 3 + 12) % 17 + 1))
        local gC_1 = (vector.create((gp_5 * 6 + 5) % 11 + 1, (gp_5 * 3 + 11) % 13 + 1, (gp_5 * 5 + 14) % 17 + 1))
        local gD_1 = (vector.create((gp_5 * 4 + 9) % 11 + 1, (gp_5 * 11 + 10) % 13 + 1, (gp_5 * 13 + 8) % 17 + 1))
        if vector.dot(vector.cross(gs_4, gC_1), gD_1) == vector.dot(vector.cross(gC_1, gD_1), gs_4) then
            fE = tostring(game.JobId)
        else
            fJ = tostring(game.JobId)
        end
        gp_5 = (gp_5 + 23) % 24
    end
until (gp_5 * 17 + 12) % 24 == 1
if gr_4 then
    local gp_6 = 4
    repeat
        local jR = bit32.rrotate(bit32.bxor(bit32.lrotate(gp_6, 2), string.byte(tostring(gp_6))), 16)
        if bit32.bxor(bit32.bxor(bit32.bxor(bit32.bxor(bit32.band(jR, 1571370347), 3007146300), (bit32.bxor(bit32.band(jR, 2723596948), 3644237278))), 3007146300), 3644237278) == jR then
            gr_4 = string.sub(fE, 1, 18) .. "..."
        else
            fE = string.sub(gr_4, 1, 18) .. "..."
        end
        gp_6 = (gp_6 + 0) % 8
    until (gp_6 * 7 + 0) % 8 == 4
end
local gp_7 = gr_4 or fE
f_, fG, gm, connection, connection2, f0 = nil, nil, nil, nil, nil, nil
GameInfoGroup:AddLabel(fV("Server", gp_7, gA), true)
GameInfoGroup:AddButton({ Text = "Copy join script (Job ID)", Func = onCopyJoinScript_JobID })
f_ = os.clock()
task.spawn(worker)
local ScriptsGroup = gx_4.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(ga("Included in this hub", gA), true)
ScriptsGroup:AddLabel(ga(gu_1, gt_2), true)
local FeaturesGroup = gx_4.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(ga("Auto Farm", gt_2), true)
FeaturesGroup:AddLabel(ga("Auto Buy", gk), true)
FeaturesGroup:AddLabel(ga("Auto Rebirth", gw_2), true)
FeaturesGroup:AddLabel(ga("Misc Utilities", gA), true)
local SocialsGroup = gx_4.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({ Text = "Discord", Func = gn })
SocialsGroup:AddButton({ Text = "Rscripts", Func = onRscripts })
local TempoHubGroup = gx_4.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
TempoHubGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
TempoHubGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
TempoHubGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
TempoHubGroup:AddButton({ Text = "Copy Discord Invite", Func = gn })
local FaqGroup = gx_4.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FarmGroup = gx_4.Main:AddLeftGroupbox("Farm", "package")
FarmGroup:AddToggle("AutoPickupBoxes", { Text = "Auto Pickup Boxes", Default = false })
FarmGroup:AddToggle("AutoLoadBoxes", { Text = "Auto Load Boxes", Default = false })
FarmGroup:AddSlider("FarmDelay", { Text = "Farm delay", Default = 0.2, Min = 0.05, Max = 2, Rounding = 2, Suffix = "s" })
local ShopGroup = gx_4.Main:AddRightGroupbox("Shop", "shopping-cart")
ShopGroup:AddToggle("AutoBuyUpgrades", { Text = "Auto Buy Upgrades", Default = false })
ShopGroup:AddDropdown("SelectedUpgrades", { Text = "Upgrades", Values = gj, Multi = true, AllowNull = true, Default = gj })
ShopGroup:AddToggle("AutoBuyHires", { Text = "Auto Buy Hires", Default = false })
ShopGroup:AddToggle("AutoBuyBoxes", { Text = "Auto Buy Boxes", Default = false })
ShopGroup:AddToggle("AutoRebirth", { Text = "Auto Rebirth", Default = false })
ShopGroup:AddSlider("ShopDelay", { Text = "Shop delay", Default = 1, Min = 0.2, Max = 10, Rounding = 1, Suffix = "s" })
local MenuGroup = gx_4.Settings:AddLeftGroupbox("Menu", "menu")
f7.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddToggle("AntiAfk", { Text = "Anti-AFK", Default = true })
MenuGroup:AddButton({ Text = "Unload", Func = onUnload })
gz_2:SetLibrary(f7)
gz_2:SetFolder("TempoHub")
gz_2:SaveDefault("Monochrome")
gz_2:ApplyToTab(gx_4.Settings)
gz_2:LoadDefault()
gy_3:SetLibrary(f7)
gy_3:IgnoreThemeSettings()
gy_3:SetIgnoreIndexes({ "MenuKeybind" })
gy_3:SetFolder("TempoHub/load-the-truck")
gy_3:BuildConfigSection(gx_4.Settings)
gy_3:LoadAutoloadConfig()
fG = tick()
gm = tick()
pcall(function()
    for i, v in ipairs(getconnections(f1.Idled)) do
        local jj = v
        pcall(function()
            jj:Disable()
        end)
    end
end)
f0 = fn332
connection = gv_1.InputBegan:Connect(onInputBegan)
connection2 = gv_1.InputChanged:Connect(onInputChanged)
if (not gm or ShopGroup) and (ShopGroup and ShopGroup) or (gm and not ShopGroup or gm and not ShopGroup) or not ((not gm or ShopGroup) and (ShopGroup and ShopGroup) or (gm and not ShopGroup or gm and not ShopGroup)) then
    f7:OnUnload(fn353)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    f7:Notify("Load The Truck loaded")
else
    f7:OnUnload(fn353)
    task.spawn(worker4)
    task.spawn(worker3)
    task.spawn(worker2)
    f7:Notify("Load The Truck loaded")
end
end)(...)
