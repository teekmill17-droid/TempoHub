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
getgenv().TempoHoodSubtitle = "+1 SKINNY PER STEP"
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
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local GAME_NAME = "+1 Skinny Per Step"
local DISCORD_INVITE = "https://discord.gg/K7Qxnxkk46"
local RSCRIPTS_LINK = "https://discord.gg/K7Qxnxkk46"
local LTC_ADDRESS = "LSZPqKSsD1x6QXea2H8JS17nXMLnmtew3w"
local BTC_ADDRESS = "bc1qwc9exvcn3ykjqnsa0t9gakuccr494ljjuuqj99"
local ETH_ADDRESS = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
local USDT_ADDRESS = "0xaE95A405D007a6F858E5d35714111B075fEFb40a"
local SOL_ADDRESS = "Hq5jPHKDKjyHhccc6UULcbYTK6aKBBbTDmHNRXGKBKGp"
local PAYPAL_LINK = ""
local VENMO_LINK = ""
local LTC = "#345d9d"
local BTC = "#f7931a"
local ETH = "#627eea"
local USDT = "#26a17b"
local SOL = "#14f195"
local PAYPAL = "#0070ba"
local VENMO = "#008cff"
local GREEN = "#7fd47f"
local BLUE = "#6ec1ff"
local ORANGE = "#e8a34d"
local GREY = "#8b93a3"
local AutoWinsRoute = ReplicatedStorage:WaitForChild("AutoWinsRoute")
local Resources = ReplicatedStorage:WaitForChild("Resources")
local EggsFolder = Resources:WaitForChild("Eggs")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyEgg = Remotes:WaitForChild("Eggs"):WaitForChild("BuyEgg")
local EquipBestPets = Remotes:WaitForChild("Pets"):WaitForChild("EquipBest")
local RebirthRequest = ReplicatedStorage:WaitForChild("RebirthRequest")
local TrailEquipRequest = ReplicatedStorage:WaitForChild("TrailEquipRequest")
local TeleportRequest = ReplicatedStorage:WaitForChild("TeleportRequest")
local WORLD_REBIRTHS = {
	[1] = 0,
	[2] = 16,
	[3] = 33,
}
local TRAIL_ORDER = {
	{ Name = "WhiteTrail", Cost = 5, Speed = 17 },
	{ Name = "RedTrail", Cost = 100, Speed = 22 },
	{ Name = "BlueTrail", Cost = 1000, Speed = 25 },
	{ Name = "YellowTrail", Cost = 50000, Speed = 28 },
	{ Name = "GreenTrail", Cost = 500000, Speed = 31 },
	{ Name = "PurpleTrail", Cost = 1000000, Speed = 35 },
	{ Name = "RainbowTrail", Cost = 10000000, Speed = 40 },
	{ Name = "AuroraTrail", Cost = 50000000, Speed = 45 },
	{ Name = "LavaTrail", Cost = 100000000, Speed = 50 },
	{ Name = "BeachTrail", Cost = 1000000000, Speed = 54 },
	{ Name = "ObsidianTrail", Cost = 1e12, Speed = 59 },
	{ Name = "DiamondTrail", Cost = 1e15, Speed = 65 },
}
local repo = ""
local Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Toggles = Library.Toggles
local Options = Library.Options
local function copyText(text, message)
	if setclipboard then
		setclipboard(text)
	elseif toclipboard then
		toclipboard(text)
	end
	Library:Notify(message)
end
local function copyDiscord()
	copyText(DISCORD_INVITE, "Copied Discord invite to clipboard")
end
local function colored(text, color)
	return string.format('<font color="%s">%s</font>', color, text)
end
local function field(key, value, color)
	return string.format("<b>%s</b> %s %s", key, colored("-", "#5a6070"), colored(value, color))
end
local function isOn(name)
	local toggle = Toggles[name]
	return toggle ~= nil and toggle.Value == true
end
local function getCharacter()
	return LocalPlayer.Character
end
local function getHumanoid()
	local character = getCharacter()
	return character and character:FindFirstChildOfClass("Humanoid")
end
local function getRoot()
	local character = getCharacter()
	return character and character:FindFirstChild("HumanoidRootPart")
end
local function attr(name, default)
	local value = LocalPlayer:GetAttribute(name)
	if value == nil then
		return default
	end
	return value
end
local function getLevel()
	return tonumber(attr("Level", 1)) or 1
end
local function getWins()
	return tonumber(attr("Wins", 0)) or 0
end
local function getRebirths()
	return tonumber(attr("Rebirths", 0)) or 0
end
local function getCurrentWorld()
	return tonumber(attr("CurrentWorld", 1)) or 1
end
local function requiredRebirthLevel(rebirths)
	return (rebirths + 1) * 25
end
local function csvOwns(csv, name)
	return ("," .. tostring(csv or "") .. ","):find("," .. name .. ",", 1, true) ~= nil
end
local function ownsFruit(name)
	return csvOwns(attr("OwnedFruits", ""), name)
end
local function ownsTrail(name)
	return csvOwns(attr("OwnedTrails", ""), name)
end
local function worldFolder(world)
	return AutoWinsRoute:FindFirstChild("W" .. tostring(world)) or AutoWinsRoute:FindFirstChild("W1")
end
local function buildWinPlateValues()
	local values = { "Best" }
	for world = 1, 3 do
		local folder = worldFolder(world)
		if folder then
			local levels = {}
			for _, child in folder:GetChildren() do
				local level = tonumber(child.Name)
				if level and child:IsA("Vector3Value") then
					levels[#levels + 1] = level
				end
			end
			table.sort(levels)
			for _, level in levels do
				values[#values + 1] = string.format("W%d | Lv %d", world, level)
			end
		end
	end
	return values
end
local function parseWinPlate(label)
	if not label or label == "Best" then
		return nil
	end
	local world, level = string.match(label, "^W(%d+) | Lv (%d+)$")
	if not world then
		return nil
	end
	return tonumber(world), tonumber(level)
end
local function bestUnlockedPad(world)
	local folder = worldFolder(world)
	if not folder then
		return nil
	end
	local level = getLevel()
	local bestLevel = -1
	local bestPos = nil
	for _, child in folder:GetChildren() do
		local padLevel = tonumber(child.Name)
		if padLevel and child:IsA("Vector3Value") and padLevel <= level and padLevel > bestLevel then
			bestLevel = padLevel
			bestPos = child.Value
		end
	end
	if not bestPos then
		return nil
	end
	return bestLevel, bestPos
end
local function resolveWinTarget()
	local selected = Options.WinPlate and Options.WinPlate.Value or "Best"
	local world, level = parseWinPlate(selected)
	if not world then
		world = getCurrentWorld()
		local bestLevel, bestPos = bestUnlockedPad(world)
		if not bestLevel then
			return nil
		end
		return world, bestLevel, bestPos
	end
	local playerLevel = getLevel()
	if level > playerLevel then
		local bestLevel, bestPos = bestUnlockedPad(world)
		if not bestLevel then
			return nil
		end
		return world, bestLevel, bestPos
	end
	local folder = worldFolder(world)
	local pad = folder and folder:FindFirstChild(tostring(level))
	if pad and pad:IsA("Vector3Value") then
		return world, level, pad.Value
	end
	return nil
end
local worldTeleportAt = 0
local function ensureWorld(world)
	if getCurrentWorld() == world then
		return true
	end
	local need = WORLD_REBIRTHS[world] or 0
	if getRebirths() < need then
		return false
	end
	if os.clock() - worldTeleportAt < 2 then
		return false
	end
	worldTeleportAt = os.clock()
	pcall(function()
		TeleportRequest:FireServer(world)
	end)
	return false
end
local function findWinTouch(world, level)
	local name
	if world == 1 then
		name = "WinZoneLevel" .. level .. "Model"
	else
		name = "WinZoneLevel" .. level .. "ModelW" .. world
	end
	local zone = Workspace:FindFirstChild(name)
	if not zone then
		return nil
	end
	return zone:FindFirstChild("TouchWin", true)
end
local playerControls = nil
pcall(function()
	playerControls = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
end)
local controlsEnabled = true
local function setAutoWinControls(enabled)
	if not playerControls or controlsEnabled == enabled then
		return
	end
	controlsEnabled = enabled
	pcall(function()
		if enabled then
			playerControls:Enable()
		else
			playerControls:Disable()
		end
	end)
end
local function laneZ(world)
	local folder = worldFolder(world)
	return tonumber(folder and folder:GetAttribute("LaneZ")) or 0
end
local function spawnPos(world)
	local folder = worldFolder(world)
	local pos = folder and folder:GetAttribute("SpawnPos")
	if typeof(pos) == "Vector3" then
		return pos
	end
	return Vector3.new(-33.763, 0.923, laneZ(world))
end
local function resetToLaneSpawn(world)
	local root = getRoot()
	if not root then
		return
	end
	local spawn = spawnPos(world)
	root.CFrame = CFrame.new(spawn + Vector3.new(0, 3, 0))
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end
local lastPadTouchAt = 0
local function retriggerWinTouch(touch)
	local root = getRoot()
	if not root or not touch or not touch:IsA("BasePart") then
		return
	end
	if not firetouchinterest then
		return
	end
	if os.clock() - lastPadTouchAt < 0.2 then
		return
	end
	lastPadTouchAt = os.clock()
	pcall(firetouchinterest, root, touch, 0)
	pcall(firetouchinterest, root, touch, 1)
end
local function walkToward(position, speed, world)
	local root = getRoot()
	local humanoid = getHumanoid()
	if not root or not humanoid or humanoid.Health <= 0 then
		return false
	end
	humanoid.Sit = false
	humanoid.PlatformStand = false
	local lane = laneZ(world)
	local positionXZ = root.Position
	if math.abs(positionXZ.Z - lane) >= 24 then
		resetToLaneSpawn(world)
		return false
	end
	local deltaX = position.X - positionXZ.X
	local deltaLane = lane - positionXZ.Z
	local goal
	if math.abs(deltaX) <= 15 then
		goal = Vector3.new(position.X, positionXZ.Y, position.Z)
	elseif math.abs(deltaLane) > 2.5 then
		goal = Vector3.new(positionXZ.X, positionXZ.Y, lane)
	else
		goal = Vector3.new(position.X, positionXZ.Y, lane)
	end
	local flat = (goal - positionXZ) * Vector3.new(1, 0, 1)
	if flat.Magnitude < 0.5 then
		humanoid.WalkSpeed = math.min(speed, 16)
		humanoid:Move(Vector3.zero, false)
		return math.abs(deltaX) <= 5
	end
	if math.abs(deltaX) < 24 then
		humanoid.WalkSpeed = math.min(speed, 16)
	else
		humanoid.WalkSpeed = speed
	end
	humanoid:Move(flat.Unit, false)
	return false
end
local function autoWinStep()
	local world, level, position = resolveWinTarget()
	if not world or not position then
		return
	end
	if getCurrentWorld() ~= world then
		ensureWorld(world)
		return
	end
	setAutoWinControls(false)
	local speed = Options.AutoWinWalkSpeed and Options.AutoWinWalkSpeed.Value or 60
	local touch = findWinTouch(world, level)
	local target = touch and touch.Position or position
	local arrived = walkToward(target, speed, world)
	local root = getRoot()
	if touch and root then
		local near = (Vector3.new(touch.Position.X - root.Position.X, 0, touch.Position.Z - root.Position.Z)).Magnitude
		if arrived or near <= 12 then
			retriggerWinTouch(touch)
		end
	end
end
local function isTreadmillModel(inst)
	return inst:IsA("Model") and inst.Name:find("Treadmill") and inst.Name ~= "TreadmillsGUI"
end
local function treadmillLabel(model)
	local name = model.Name
	if string.sub(name, -9) == "Treadmill" then
		name = string.sub(name, 1, -10)
	end
	return (string.gsub(name, "GoldenCrown", " Golden Crown"))
end
local function isRobuxTreadmill(model)
	if model.Name == "WoodenTreadmill" then
		return false
	end
	if (tonumber(model:GetAttribute("RequiredRebirths")) or 0) == 0 then
		return true
	end
	if string.find(model.Name, "GoldenCrown", 1, true) then
		return true
	end
	return model:FindFirstChild("RobuxAmountNeedToUnlockGUI", true) ~= nil
end
local function treadmillStand(model)
	local conveyor = model:FindFirstChild("Conveyor", true)
	if conveyor and conveyor:IsA("BasePart") then
		return conveyor
	end
	if model.PrimaryPart then
		return model.PrimaryPart
	end
	return model:FindFirstChildWhichIsA("BasePart", true)
end
local function eachTreadmill()
	local list = {}
	for _, child in Workspace:GetChildren() do
		if isTreadmillModel(child) then
			list[#list + 1] = child
		end
	end
	table.sort(list, function(a, b)
		local ma = tonumber(a:GetAttribute("Multiplier")) or 0
		local mb = tonumber(b:GetAttribute("Multiplier")) or 0
		if ma ~= mb then
			return ma > mb
		end
		return a.Name < b.Name
	end)
	return list
end
local function getTreadmills()
	local list = {}
	for _, model in eachTreadmill() do
		local conveyor = model:FindFirstChild("Conveyor", true)
		if conveyor and conveyor:IsA("BasePart") then
			list[#list + 1] = {
				Model = model,
				Required = tonumber(model:GetAttribute("RequiredRebirths")) or 0,
				Multiplier = tonumber(model:GetAttribute("Multiplier")) or 0,
				Conveyor = conveyor,
			}
		end
	end
	return list
end
local function treadmillUnlocked(entry)
	local name = entry.Model.Name
	if name == "HackerTreadmill" then
		return attr("HasHacker", false) == true
	end
	if name == "GalaxyTreadmill" then
		return attr("HasGalaxy", false) == true
	end
	if name == "LavaTreadmill" then
		return attr("HasLava", false) == true
	end
	if string.find(name, "GoldenCrown", 1, true) then
		return attr("HasVIP", false) == true
	end
	return getRebirths() >= entry.Required
end
local function bestTreadmill()
	for _, entry in getTreadmills() do
		if not isRobuxTreadmill(entry.Model) and treadmillUnlocked(entry) then
			return entry
		end
	end
	return nil
end
local function entryFromModel(model)
	local stand = treadmillStand(model)
	if not stand then
		return nil
	end
	return {
		Model = model,
		Required = tonumber(model:GetAttribute("RequiredRebirths")) or 0,
		Multiplier = tonumber(model:GetAttribute("Multiplier")) or 0,
		Conveyor = stand,
	}
end
local function resolveTreadmill()
	local selected = Options.Treadmill and Options.Treadmill.Value or "Best"
	if selected == "Best" then
		return bestTreadmill()
	end
	for _, model in eachTreadmill() do
		if treadmillLabel(model) == selected then
			return entryFromModel(model)
		end
	end
	return nil
end
local function buildTreadmillValues()
	local values = { "Best" }
	for _, model in eachTreadmill() do
		values[#values + 1] = treadmillLabel(model)
	end
	return values
end
local function teleportToPart(part)
	local root = getRoot()
	if not root or not part then
		return
	end
	root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
end
local function getBuyPrompt(model)
	local prompt = model:FindFirstChild("BuyPrompt", true)
	if prompt and prompt:IsA("ProximityPrompt") then
		return prompt
	end
	return nil
end
local function fireBuyPrompt(model)
	local prompt = getBuyPrompt(model)
	if not prompt then
		return false
	end
	local part = prompt.Parent
	if part and part:IsA("BasePart") then
		teleportToPart(part)
		task.wait(0.1)
	end
	if fireproximityprompt then
		pcall(fireproximityprompt, prompt)
		return true
	end
	pcall(function()
		prompt:InputHoldBegin()
		task.wait(0.05)
		prompt:InputHoldEnd()
	end)
	return true
end
local function getFoods()
	local list = {}
	for _, child in Workspace:GetChildren() do
		if child:IsA("Model") and child:GetAttribute("RequiredWins") ~= nil then
			local req = tonumber(child:GetAttribute("RequiredWins"))
			local boost = tonumber(child:GetAttribute("ThinBoost")) or 0
			if req and req == req and req ~= math.huge then
				list[#list + 1] = {
					Model = child,
					Name = child.Name,
					Required = req,
					Boost = boost,
				}
			end
		end
	end
	table.sort(list, function(a, b)
		return a.Boost > b.Boost
	end)
	return list
end
local function foodAction(model)
	local prompt = getBuyPrompt(model)
	return prompt and prompt.ActionText or nil
end
local function foodUnlocked(food, wins)
	return ownsFruit(food.Name) or wins >= food.Required
end
local lastFoodActionAt = 0
local function autoBuyFoodsOnce()
	local wins = getWins()
	local equipped = tostring(attr("EquippedItem", "") or "")
	local bestBuy = nil
	local bestOwned = nil
	for _, food in getFoods() do
		local action = foodAction(food.Model)
		if action == "Buy" and wins >= food.Required then
			if not bestBuy then
				bestBuy = food
			end
		elseif foodUnlocked(food, wins) then
			if not bestOwned then
				bestOwned = food
			end
		end
	end
	if os.clock() - lastFoodActionAt < 1.5 then
		return
	end
	if bestBuy then
		lastFoodActionAt = os.clock()
		fireBuyPrompt(bestBuy.Model)
		return
	end
	if bestOwned and equipped ~= bestOwned.Name then
		lastFoodActionAt = os.clock()
		fireBuyPrompt(bestOwned.Model)
	end
end
local function buildEggValues()
	local values = {}
	local entries = {}
	for _, egg in EggsFolder:GetChildren() do
		local cost = egg:FindFirstChild("Cost")
		local amount = cost and tonumber(cost.Value) or 0
		if amount > 0 then
			entries[#entries + 1] = { Name = egg.Name, Cost = amount }
		end
	end
	table.sort(entries, function(a, b)
		return a.Cost < b.Cost
	end)
	for _, entry in entries do
		values[#values + 1] = entry.Name
	end
	return values
end
local function eggCost(name)
	local egg = EggsFolder:FindFirstChild(name)
	local cost = egg and egg:FindFirstChild("Cost")
	return cost and tonumber(cost.Value) or 0
end
local function autoTrainOnce()
	local entry = resolveTreadmill()
	if not entry then
		return
	end
	if attr("OnTreadmill", false) == true then
		local root = getRoot()
		if root and (root.Position - entry.Conveyor.Position).Magnitude > 14 then
			teleportToPart(entry.Conveyor)
		end
		return
	end
	teleportToPart(entry.Conveyor)
end
local function autoRebirthOnce()
	local rebirths = getRebirths()
	local need = requiredRebirthLevel(rebirths)
	if getLevel() < need then
		return
	end
	pcall(function()
		RebirthRequest:FireServer()
	end)
end
local function autoBuyTrailsOnce()
	local wins = getWins()
	local bestOwned = nil
	local bestSpeed = -1
	for _, trail in TRAIL_ORDER do
		if ownsTrail(trail.Name) then
			if trail.Speed > bestSpeed then
				bestSpeed = trail.Speed
				bestOwned = trail.Name
			end
		elseif wins >= trail.Cost then
			pcall(function()
				TrailEquipRequest:FireServer(trail.Name)
			end)
			task.wait(0.15)
			if ownsTrail(trail.Name) and trail.Speed > bestSpeed then
				bestSpeed = trail.Speed
				bestOwned = trail.Name
			end
		end
	end
	local equipped = tostring(attr("EquippedTrail", "") or "")
	if bestOwned and equipped ~= bestOwned then
		pcall(function()
			TrailEquipRequest:FireServer(bestOwned)
		end)
	end
end
local function autoHatchOnce()
	local eggName = Options.HatchEgg and Options.HatchEgg.Value
	if type(eggName) ~= "string" or eggName == "" then
		return
	end
	local egg = EggsFolder:FindFirstChild(eggName)
	if not egg then
		return
	end
	local cost = eggCost(eggName)
	if getWins() < cost then
		return
	end
	local ok, result = pcall(function()
		return BuyEgg:InvokeServer(egg)
	end)
	if ok and result then
		if isOn("AutoEquipBestPets") then
			pcall(function()
				EquipBestPets:FireServer()
			end)
		end
	end
end
local WIN_PLATE_VALUES = buildWinPlateValues()
local TREADMILL_VALUES = buildTreadmillValues()
local EGG_VALUES = buildEggValues()
if #EGG_VALUES == 0 then
	EGG_VALUES = { "Common" }
end
local Window = Library:CreateWindow({
	Title = "Tempo",
	Font = Enum.Font.BuilderSans,
	Footer = {
		{ Text = DISCORD_INVITE, Copyable = true },
		"|",
		GAME_NAME,
	},
	Icon = 78539693571783,
	NotifySide = "Right",
	ShowCustomCursor = false,
	CornerRadius = 0,
})
local Tabs = {
	Info = Window:AddTab("Info", "info"),
	Main = Window:AddTab("Main", "gauge"),
	Player = Window:AddTab("Player", "person-standing"),
	Settings = Window:AddTab("Settings", "settings"),
}
local function AddDiscordButton(Tab)
	local DiscordGroup = Tab:AddLeftGroupbox("Discord")
	DiscordGroup:AddButton({
		Text = "Join Discord to Make Money",
		Func = copyDiscord,
	})
	DiscordGroup:AddButton({
		Text = "Join Discord for Keyless Scripts",
		Func = copyDiscord,
	})
end
for _, Tab in Tabs do
	if Tab ~= Tabs.Info then
		AddDiscordButton(Tab)
	end
end
local executorName = "Unknown"
pcall(function()
	if identifyexecutor then
		local name, version = identifyexecutor()
		if type(name) == "string" and name ~= "" then
			executorName = type(version) == "string" and version ~= "" and (name .. " " .. version) or name
		end
	end
end)
local AccountGroup = Tabs.Info:AddLeftGroupbox("Account", "circle-user")
AccountGroup:AddLabel(field("User", LocalPlayer.Name, GREEN), true)
AccountGroup:AddLabel(field("Status", "Keyless", GREEN), true)
AccountGroup:AddLabel(field("Executor", executorName, GREEN), true)
local GameGroup = Tabs.Info:AddLeftGroupbox("Game Info", "gamepad-2")
GameGroup:AddLabel(colored(GAME_NAME .. " [" .. tostring(game.PlaceId) .. "]", BLUE), true)
GameGroup:AddLabel(field("Place ID", tostring(game.PlaceId), BLUE), true)
local SessionLabel = GameGroup:AddLabel(field("Session time", "0s", ORANGE), true)
local jobId = tostring(game.JobId)
local shortJobId = #jobId > 18 and (string.sub(jobId, 1, 18) .. "...") or jobId
GameGroup:AddLabel(field("Server", shortJobId, GREY), true)
GameGroup:AddButton({
	Text = "Copy join script (Job ID)",
	Func = function()
		local joinScript = string.format(
			'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)',
			game.PlaceId,
			jobId
		)
		copyText(joinScript, "Copied join script to clipboard")
	end,
})
local sessionStart = os.clock()
task.spawn(function()
	while true do
		task.wait(1)
		if Library.Unloaded then
			break
		end
		local elapsed = math.floor(os.clock() - sessionStart)
		local text
		if elapsed < 60 then
			text = elapsed .. "s"
		elseif elapsed < 3600 then
			text = string.format("%dm %ds", math.floor((elapsed) / (60)), elapsed % 60)
		else
			text = string.format("%dh %dm", math.floor((elapsed) / (3600)), math.floor(((elapsed % 3600)) / (60)))
		end
		SessionLabel:SetText(field("Session time", text, ORANGE))
	end
end)
local ScriptsGroup = Tabs.Info:AddRightGroupbox("Scripts", "package")
ScriptsGroup:AddLabel(colored("Included in this hub", GREY), true)
ScriptsGroup:AddLabel(colored(GAME_NAME, BLUE), true)
local FeaturesGroup = Tabs.Info:AddRightGroupbox("Features", "list")
FeaturesGroup:AddLabel(colored("Auto Win", ORANGE), true)
FeaturesGroup:AddLabel(colored("Auto Train", BLUE), true)
FeaturesGroup:AddLabel(colored("Auto Shop", GREEN), true)
FeaturesGroup:AddLabel(colored("Auto Hatch", BLUE), true)
FeaturesGroup:AddLabel(colored("Player Utilities", GREY), true)
local SocialsGroup = Tabs.Info:AddRightGroupbox("Socials", "link")
SocialsGroup:AddButton({
	Text = "Discord",
	Func = copyDiscord,
})
SocialsGroup:AddButton({
	Text = "Rscripts",
	Func = function()
		copyText(RSCRIPTS_LINK, "Copied Rscripts profile to clipboard")
	end,
})
local AdGroup = Tabs.Info:AddLeftGroupbox("Tempo Hub", "sparkles")
AdGroup:AddLabel("Every script in the hub is keyless. No key systems, no checkpoints, no linkvertise.", true)
AdGroup:AddLabel("The Discord has ready made configs, dupe methods, giveaways, and early access to new scripts.", true)
AdGroup:AddLabel("Requests get taken seriously. A lot of what is in this script started as a Discord message.", true)
AdGroup:AddButton({
	Text = "Copy Discord Invite",
	Func = copyDiscord,
})
local DonationsGroup = Tabs.Info:AddRightGroupbox("Donations", "heart")
DonationsGroup:AddLabel(colored("All donations are optional but appreciated.", ORANGE), true)
DonationsGroup:AddLabel(colored("If you donate you get a special role, just PING after you donate.", GREEN), true)
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(colored("LTC / Litecoin", LTC), true)
DonationsGroup:AddButton({
	Text = "Copy Litecoin Address",
	Func = function()
		copyText(LTC_ADDRESS, "Copied Litecoin address")
	end,
})
DonationsGroup:AddLabel(colored("BTC / Bitcoin", BTC), true)
DonationsGroup:AddButton({
	Text = "Copy Bitcoin Address",
	Func = function()
		copyText(BTC_ADDRESS, "Copied Bitcoin address")
	end,
})
DonationsGroup:AddLabel(colored("ETH / Ethereum", ETH), true)
DonationsGroup:AddButton({
	Text = "Copy Ethereum Address",
	Func = function()
		copyText(ETH_ADDRESS, "Copied Ethereum address")
	end,
})
DonationsGroup:AddLabel(colored("USDT", USDT), true)
DonationsGroup:AddButton({
	Text = "Copy USDT Address",
	Func = function()
		copyText(USDT_ADDRESS, "Copied USDT address")
	end,
})
DonationsGroup:AddLabel(colored("Solana", SOL), true)
DonationsGroup:AddButton({
	Text = "Copy Solana Address",
	Func = function()
		copyText(SOL_ADDRESS, "Copied Solana address")
	end,
})
DonationsGroup:AddLabel(colored("PayPal", PAYPAL), true)
DonationsGroup:AddButton({
	Text = "Copy PayPal Link",
	Func = function()
		copyText(PAYPAL_LINK, "Copied PayPal link")
	end,
})
DonationsGroup:AddLabel(colored("Venmo", VENMO), true)
DonationsGroup:AddButton({
	Text = "Copy Venmo Link",
	Func = function()
		copyText(VENMO_LINK, "Copied Venmo link")
	end,
})
DonationsGroup:AddDivider()
DonationsGroup:AddLabel(colored("Don't have any of the listed currencies but still wanna donate?", GREY), true)
DonationsGroup:AddLabel(colored("DM me and we'll work something out.", BLUE), true)
local FaqGroup = Tabs.Info:AddRightGroupbox("FAQ", "circle-help")
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
local FarmGroup = Tabs.Main:AddLeftGroupbox("Farm", "bot")
FarmGroup:AddToggle("AutoWin", {
	Text = "Auto Win",
	Default = false,
})
FarmGroup:AddDropdown("WinPlate", {
	Text = "Win Plate",
	Values = WIN_PLATE_VALUES,
	Default = "Best",
	Expandable = true,
	ExpandColumns = 2,
})
FarmGroup:AddSlider("AutoWinWalkSpeed", {
	Text = "Auto Win WalkSpeed",
	Default = 60,
	Min = 16,
	Max = 250,
	Rounding = 0,
})
FarmGroup:AddToggle("AutoTrain", {
	Text = "Auto Train",
	Default = false,
})
FarmGroup:AddDropdown("Treadmill", {
	Text = "Treadmill",
	Values = TREADMILL_VALUES,
	Default = "Best",
	Expandable = true,
	ExpandColumns = 2,
})
FarmGroup:AddToggle("AutoRebirth", {
	Text = "Auto Rebirth",
	Default = false,
})
local ShopGroup = Tabs.Main:AddRightGroupbox("Shop", "shopping-bag")
ShopGroup:AddToggle("AutoBuyTrail", {
	Text = "Auto Buy Trail",
	Default = false,
})
ShopGroup:AddToggle("AutoBuyFoods", {
	Text = "Auto Buy Foods",
	Default = false,
})
local HatchGroup = Tabs.Main:AddRightGroupbox("Pets", "paw-print")
HatchGroup:AddToggle("AutoHatch", {
	Text = "Auto Hatch Pets",
	Default = false,
})
HatchGroup:AddDropdown("HatchEgg", {
	Text = "Egg",
	Values = EGG_VALUES,
	Default = EGG_VALUES[1],
})
HatchGroup:AddSlider("HatchDelay", {
	Text = "Hatch Delay",
	Default = 0.35,
	Min = 0.1,
	Max = 3,
	Rounding = 2,
})
HatchGroup:AddToggle("AutoEquipBestPets", {
	Text = "Auto Equip Best Pets",
	Default = true,
})
local MovementGroup = Tabs.Player:AddLeftGroupbox("Movement", "footprints")
MovementGroup:AddToggle("WalkSpeedEnabled", {
	Text = "WalkSpeed",
	Default = false,
})
MovementGroup:AddSlider("WalkSpeed", {
	Text = "WalkSpeed Amount",
	Default = 32,
	Min = 16,
	Max = 250,
	Rounding = 0,
})
MovementGroup:AddToggle("InfJump", {
	Text = "Infinite Jump",
	Default = false,
})
MovementGroup:AddToggle("NoClip", {
	Text = "NoClip",
	Default = false,
})
MovementGroup:AddToggle("AntiGameplayPause", {
	Text = "No Gameplay Paused",
	Default = true,
})
local FlyGroup = Tabs.Player:AddRightGroupbox("Fly", "feather")
FlyGroup:AddToggle("Fly", {
	Text = "Fly",
	Default = false,
})
FlyGroup:AddSlider("FlySpeed", {
	Text = "Fly Speed",
	Default = 60,
	Min = 10,
	Max = 400,
	Rounding = 0,
})
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind",
})
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("AntiAfk", {
	Text = "Anti-AFK",
	Default = true,
})
MenuGroup:AddButton({
	Text = "Unload",
	Func = function()
		Library:Unload()
	end,
})
local antiAfkLastInput = tick()
local antiAfkLastTap = tick()
pcall(function()
	for _, connection in ipairs(getconnections(LocalPlayer.Idled)) do
		pcall(function()
			connection:Disable()
		end)
	end
end)
local function antiAfkTap()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
	task.wait(0.1)
	VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
	antiAfkLastTap = tick()
end
local antiAfkBeganConnection = UserInputService.InputBegan:Connect(function()
	antiAfkLastInput = tick()
end)
local antiAfkChangedConnection = UserInputService.InputChanged:Connect(function(input)
	local inputType = input.UserInputType
	if inputType == Enum.UserInputType.MouseMovement or inputType == Enum.UserInputType.Gamepad1 then
		antiAfkLastInput = tick()
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		task.wait(2)
		if Toggles.AntiAfk.Value then
			local idle = tick() - antiAfkLastInput
			local sinceTap = tick() - antiAfkLastTap
			if idle >= 300 and sinceTap >= 60 then
				pcall(antiAfkTap)
			elseif idle < 300 and sinceTap >= 300 then
				pcall(antiAfkTap)
			end
		end
	end
end)
local function applyAntiGameplayPause(enabled)
	pcall(function()
		GuiService:SetGameplayPausedNotificationEnabled(not enabled)
	end)
	pcall(function()
		local notification = CoreGui:FindFirstChild("RobloxNetworkPauseNotification")
		if notification then
			notification.Enabled = not enabled
		end
	end)
	if not enabled then
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
Toggles.AntiGameplayPause:OnChanged(function()
	applyAntiGameplayPause(Toggles.AntiGameplayPause.Value)
end)
task.spawn(function()
	while not Library.Unloaded do
		task.wait(1)
		if Toggles.AntiGameplayPause.Value then
			applyAntiGameplayPause(true)
		end
	end
end)
RunService.Stepped:Connect(function()
	if Library.Unloaded then
		return
	end
	if Toggles.NoClip and Toggles.NoClip.Value then
		local character = LocalPlayer.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end
end)
UserInputService.JumpRequest:Connect(function()
	if Library.Unloaded then
		return
	end
	if Toggles.InfJump and Toggles.InfJump.Value then
		local humanoid = getHumanoid()
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)
local Camera = Workspace.CurrentCamera
RunService.RenderStepped:Connect(function(dt)
	if Library.Unloaded then
		return
	end
	if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value and not isOn("AutoWin") then
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.WalkSpeed = Options.WalkSpeed.Value
		end
	end
	if Toggles.Fly and Toggles.Fly.Value then
		local root = getRoot()
		local humanoid = getHumanoid()
		if root and humanoid then
			humanoid.PlatformStand = true
			local direction = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				direction = direction + Camera.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				direction = direction - Camera.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				direction = direction - Camera.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				direction = direction + Camera.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				direction = direction + Vector3.new(0, 1, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				direction = direction - Vector3.new(0, 1, 0)
			end
			root.AssemblyLinearVelocity = Vector3.zero
			if direction.Magnitude > 0 then
				root.CFrame = root.CFrame + direction.Unit * Options.FlySpeed.Value * dt
			end
		end
	end
end)
Toggles.Fly:OnChanged(function()
	if not Toggles.Fly.Value then
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.PlatformStand = false
		end
	end
end)
Toggles.WalkSpeedEnabled:OnChanged(function()
	if not Toggles.WalkSpeedEnabled.Value and not isOn("AutoWin") then
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.WalkSpeed = 16
		end
	end
end)
Toggles.AutoWin:OnChanged(function()
	if not Toggles.AutoWin.Value then
		setAutoWinControls(true)
		local humanoid = getHumanoid()
		if humanoid then
			humanoid:Move(Vector3.zero, false)
			if not (Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value) then
				humanoid.WalkSpeed = 16
			end
		end
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		RunService.Heartbeat:Wait()
		if isOn("AutoWin") then
			pcall(autoWinStep)
		end
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		task.wait(0.35)
		if isOn("AutoTrain") then
			pcall(autoTrainOnce)
		end
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		task.wait(1)
		if isOn("AutoRebirth") then
			pcall(autoRebirthOnce)
		end
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		task.wait(1)
		if isOn("AutoBuyTrail") then
			pcall(autoBuyTrailsOnce)
		end
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		task.wait(1.25)
		if isOn("AutoBuyFoods") then
			pcall(autoBuyFoodsOnce)
		end
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		local delayTime = Options.HatchDelay and Options.HatchDelay.Value or 0.35
		task.wait(delayTime)
		if isOn("AutoHatch") then
			pcall(autoHatchOnce)
		end
	end
end)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Evil Hello Kitty")
ThemeManager:ApplyToTab(Tabs.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind", "SaveManager_ImportSource" })
SaveManager:SetFolder("TempoHub/SkinnyPerStep")
local ConfigurationBox = SaveManager:BuildConfigSection(Tabs.Settings)
local function configElement(objectType, index)
	local holder = objectType == "Toggle" and Toggles or Options
	local element = holder[index]
	return type(element) == "table" and element.Type == objectType and element or nil
end
local function encodeConfigObject(index, element)
	local elementType = element.Type
	if elementType == "Toggle" then
		return { idx = index, type = "Toggle", value = element.Value == true }
	elseif elementType == "Slider" then
		return { idx = index, type = "Slider", value = tostring(element.Value) }
	elseif elementType == "Dropdown" then
		return { idx = index, type = "Dropdown", multi = element.Multi == true, value = element.Value }
	elseif elementType == "Input" then
		return { idx = index, type = "Input", text = tostring(element.Value or "") }
	elseif elementType == "ColorPicker" then
		return {
			idx = index,
			type = "ColorPicker",
			value = element.Value:ToHex(),
			transparency = element.Transparency,
		}
	elseif elementType == "KeyPicker" then
		return {
			idx = index,
			type = "KeyPicker",
			mode = element.Mode,
			key = element.Value,
			modifiers = element.Modifiers,
			toggled = element.Toggled,
		}
	end
	return nil
end
local function buildConfigPayload()
	local objects = {}
	for _, holder in ipairs({ Toggles, Options }) do
		for index, element in pairs(holder) do
			if type(element) == "table"
				and type(element.Type) == "string"
				and not SaveManager.Ignore[index]
			then
				local encoded = encodeConfigObject(index, element)
				if encoded then
					objects[#objects + 1] = encoded
				end
			end
		end
	end
	table.sort(objects, function(a, b)
		if a.type ~= b.type then
			return a.type < b.type
		end
		return a.idx < b.idx
	end)
	return { objects = objects }
end
local function applyConfigObject(object)
	if type(object) ~= "table"
		or type(object.idx) ~= "string"
		or type(object.type) ~= "string"
		or SaveManager.Ignore[object.idx]
	then
		return false
	end
	local element = configElement(object.type, object.idx)
	if not element then
		return false
	end
	local applied = pcall(function()
		if object.type == "Input" then
			if type(object.text) ~= "string" then
				return
			end
			element:SetValue(object.text)
		elseif object.type == "ColorPicker" then
			element:SetValueRGB(Color3.fromHex(object.value), object.transparency)
		elseif object.type == "KeyPicker" then
			element:SetValue({ object.key, object.mode, object.modifiers })
			if object.mode == "Toggle" and object.toggled ~= nil then
				element.Toggled = object.toggled
				element:Update()
			end
		else
			element:SetValue(object.value)
		end
	end)
	return applied
end
ConfigurationBox:AddDivider()
ConfigurationBox:AddInput("SaveManager_ImportSource", {
	Text = "Paste exported config here",
	Finished = true,
	AllowEmpty = true,
})
ConfigurationBox:AddButton("Export Config to Clipboard", function()
	local encodeSuccess, encoded = pcall(HttpService.JSONEncode, HttpService, buildConfigPayload())
	if not encodeSuccess then
		Library:Notify("Failed to encode the config")
		return
	end
	local writeClipboard = setclipboard or toclipboard
	if type(writeClipboard) ~= "function" or not pcall(writeClipboard, encoded) then
		Library:Notify("Your executor does not support copying to the clipboard")
		return
	end
	Library:Notify("Config copied to clipboard", 6)
end)
ConfigurationBox:AddButton("Import Config from Clipboard Text", function()
	local source = tostring(Options.SaveManager_ImportSource.Value or ""):match("^%s*(.-)%s*$")
	if source == "" then
		Library:Notify("Paste an exported config into the box first")
		return
	end
	local decodeSuccess, decoded = pcall(HttpService.JSONDecode, HttpService, source)
	if not decodeSuccess or type(decoded) ~= "table" or type(decoded.objects) ~= "table" then
		Library:Notify("That is not a valid exported config")
		return
	end
	local applied = 0
	for _, object in ipairs(decoded.objects) do
		if applyConfigObject(object) then
			applied += 1
		end
	end
	if applied == 0 then
		Library:Notify("No settings in that config matched this script")
		return
	end
	Options.SaveManager_ImportSource:SetValue("")
	Library:Notify(("Imported %d setting%s"):format(applied, applied == 1 and "" or "s"), 6)
end)
SaveManager:LoadAutoloadConfig()
Library:OnUnload(function()
	antiAfkBeganConnection:Disconnect()
	antiAfkChangedConnection:Disconnect()
	applyAntiGameplayPause(false)
	setAutoWinControls(true)
	local humanoid = getHumanoid()
	if humanoid then
		humanoid:Move(Vector3.zero, false)
		humanoid.PlatformStand = false
		humanoid.WalkSpeed = 16
	end
	select("#", "Unloaded!")
end)
end)(...)
