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
getgenv().TempoHoodSubtitle = "COACH A FIGHTER!"
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
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local GAME_NAME = "Coach a Fighter!"
local DISCORD_INVITE = "https://discord.gg/K7Qxnxkk46"
local RSCRIPTS_LINK = "https://discord.gg/K7Qxnxkk46"
local Comms = ReplicatedStorage:WaitForChild("comms")
local RequestReroll = Comms:WaitForChild("RequestReroll")
local PickFighterOffer = Comms:WaitForChild("PickFighterOffer")
local ShowRerollCards = Comms:WaitForChild("ShowRerollCards")
local ClearRerollCards = Comms:WaitForChild("ClearRerollCards")
local ToggleInstantReveal = Comms:WaitForChild("ToggleInstantReveal")
local StartTrainingStation = Comms:WaitForChild("StartTrainingStation")
local OpenTrainingMenu = Comms:WaitForChild("OpenTrainingMenu")
local OpenSparringMenu = Comms:WaitForChild("OpenSparringMenu")
local RequestOfficialNPCMatch = Comms:WaitForChild("RequestOfficialNPCMatch")
local RequestCurrentFighters = Comms:WaitForChild("RequestCurrentFighters")
local RequestPantsShop = Comms:WaitForChild("RequestPantsShop")
local PurchasePantsShopItem = Comms:WaitForChild("PurchasePantsShopItem")
local LeagueConfig = require(ReplicatedStorage.sharedModules.LeagueConfig)
local repo = ""
local Library = getgenv().Library
local ThemeManager = getgenv().ThemeManager
local SaveManager = getgenv().SaveManager
local Toggles = Library.Toggles
local Options = Library.Options
local RARITY_VALUES = { "Random", "Random [Shiny]", "Real", "Real [Shiny]", "Legend", "Legend [Shiny]" }
local STATION_STAT_BY_NAME = {
	["Punching Bag"] = "Power",
	["Bench Press"] = "Power",
	["Pull Ups"] = "Dexterity",
	["Treadmill [AGL]"] = "Agility",
	["Treadmill [STM]"] = "Stamina",
}
local LEAGUE_VALUES = { "Bronze", "Silver", "Gold", "World" }
local NONE_FIGHTER = "None"
local MAX_TRAINING_REPS = 9
local REQUIRED_SPARS = 3
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
local GREEN = "#7fd47f"
local BLUE = "#6ec1ff"
local ORANGE = "#e8a34d"
local GREY = "#8b93a3"
local function isOn(name)
	local toggle = Toggles[name]
	return toggle ~= nil and toggle.Value == true
end
local function optionValue(name, fallback)
	local option = Options[name]
	if option == nil then
		return fallback
	end
	return option.Value
end
local function multiSelected(name)
	local value = optionValue(name, {})
	if typeof(value) ~= "table" then
		return {}
	end
	local selected = {}
	for key, on in pairs(value) do
		if on == true then
			selected[key] = true
		elseif typeof(key) == "number" and typeof(on) == "string" then
			selected[on] = true
		end
	end
	return selected
end
local function multiHasAny(name)
	return next(multiSelected(name)) ~= nil
end
local function getRoot()
	local character = LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end
local function teleportTo(cf)
	local root = getRoot()
	if not root or not cf then
		return false
	end
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	root.CFrame = cf
	return true
end
local function getHud()
	return LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("HUD")
end
local function getPlot()
	local plots = Workspace:FindFirstChild("Plots")
	local used = plots and plots:FindFirstChild("Used")
	return used and used:FindFirstChild(LocalPlayer.Name)
end
local function getStatsFolder()
	return LocalPlayer:FindFirstChild("Stats")
end
local function getMoney()
	local stats = getStatsFolder()
	local money = stats and stats:FindFirstChild("Money")
	return money and money.Value or 0
end
local function getStatValue(name)
	local stats = getStatsFolder()
	local value = stats and stats:FindFirstChild(name)
	return value and value.Value or 0
end
local function fireGuiButton(button)
	if not button then
		return false
	end
	local fired = false
	if firesignal then
		fired = pcall(firesignal, button.MouseButton1Click)
		if not fired then
			fired = pcall(firesignal, button.Activated)
		end
	end
	if fired then
		return true
	end
	for _, signalName in ipairs({ "MouseButton1Click", "Activated" }) do
		local ok, list = pcall(function()
			return getconnections(button[signalName])
		end)
		if ok then
			for _, connection in ipairs(list) do
				local ran = pcall(function()
					if connection.Fire then
						connection:Fire()
					elseif connection.Function then
						connection.Function()
					end
				end)
				fired = fired or ran
			end
		end
	end
	return fired
end
local function parseNumber(text)
	if typeof(text) == "number" then
		return text
	end
	if typeof(text) ~= "string" then
		return nil
	end
	local value = string.match(text, "(%-?%d+%.?%d*)")
	return value and tonumber(value) or nil
end
local function waitFor(predicate, timeout)
	local deadline = os.clock() + (timeout or 5)
	while os.clock() < deadline do
		local ok, result = pcall(predicate)
		if ok and result then
			return result
		end
		task.wait(0.05)
	end
	return nil
end
local latestRerollToken = nil
local latestOffers = {}
local rerollBusy = false
local function offerRarityLabel(data)
	local category = tostring(data.Category or "Custom")
	local label = "Random"
	if category == "Real" then
		label = "Real"
	elseif category == "Legend" then
		label = "Legend"
	end
	if data.IsShiny == true then
		label = label .. " [Shiny]"
	end
	return label
end
local function readOffer(data, index)
	return {
		index = index,
		name = data.RealName or data.PresetName or "",
		rarity = offerRarityLabel(data),
		shiny = data.IsShiny == true,
		overall = tonumber(data.Overall) or 0,
		power = tonumber(data.Power) or 0,
		agility = tonumber(data.Agility) or 0,
		dexterity = tonumber(data.Dexterity) or 0,
		endurance = tonumber(data.Endurance) or 0,
		reach = tonumber(data.Reach) or 0,
		stamina = tonumber(data.Stamina) or 0,
		trainingCap = tonumber(data.TrainingCap) or 0,
	}
end
ShowRerollCards.OnClientEvent:Connect(function(offers, token)
	latestRerollToken = token
	latestOffers = {}
	if typeof(offers) ~= "table" then
		return
	end
	for index = 1, 3 do
		local data = offers[index]
		if typeof(data) == "table" then
			table.insert(latestOffers, readOffer(data, index))
		end
	end
end)
ClearRerollCards.OnClientEvent:Connect(function()
	latestRerollToken = nil
	latestOffers = {}
end)
local function getRerollMenu()
	local hud = getHud()
	return hud and hud:FindFirstChild("RerollMenu")
end
local function getOfferCards()
	local menu = getRerollMenu()
	if not menu or not menu:FindFirstChild("CardSelector") then
		return {}
	end
	return latestOffers
end
local function freeRerollReady()
	local menu = getRerollMenu()
	local button = menu and menu:FindFirstChild("Reroll")
	local label = button and button:FindFirstChild("TextLabel")
	if not button or not label then
		return false
	end
	local text = string.lower(label.Text)
	if string.find(text, "free", 1, true) then
		return button.Active ~= false and button.Visible ~= false
	end
	return false
end
local function setInstantReveal(enabled)
	local current = LocalPlayer:GetAttribute("InstantReveal") == true
	if current == enabled then
		return
	end
	pcall(function()
		ToggleInstantReveal:FireServer(enabled)
	end)
	pcall(function()
		ToggleInstantReveal:FireServer()
	end)
end
local function offerMeetsStop(offer)
	if not offer then
		return false
	end
	local rarities = multiSelected("StopRarities")
	if next(rarities) ~= nil and not rarities[offer.rarity] then
		return false
	end
	if offer.overall < (optionValue("StopMinOverall", 0) or 0) then
		return false
	end
	if offer.trainingCap < (optionValue("StopMinTrainingCap", 0) or 0) then
		return false
	end
	local checks = {
		Power = offer.power,
		Agility = offer.agility,
		Dexterity = offer.dexterity,
		Endurance = offer.endurance,
		Reach = offer.reach,
		Stamina = offer.stamina,
	}
	for stat, value in pairs(checks) do
		local minimum = optionValue("StopMin" .. stat, 0) or 0
		if minimum > 0 and value < minimum then
			return false
		end
	end
	return true
end
local function chooseOffer(offers)
	local matches = {}
	for _, offer in ipairs(offers) do
		if offerMeetsStop(offer) then
			table.insert(matches, offer)
		end
	end
	if #matches == 0 then
		return nil
	end
	local mode = optionValue("StopPickMode", "Lowest Overall")
	if mode == "First Match" then
		return matches[1]
	end
	table.sort(matches, function(a, b)
		if a.overall == b.overall then
			return a.trainingCap > b.trainingCap
		end
		if mode == "Lowest Overall" then
			return a.overall < b.overall
		end
		return a.overall > b.overall
	end)
	return matches[1]
end
local function pickOffer(offer)
	if not offer then
		return false
	end
	if latestRerollToken == nil then
		return false
	end
	PickFighterOffer:FireServer(offer.index, latestRerollToken)
	latestRerollToken = nil
	latestOffers = {}
	return true
end
local function onOfferPicked(offer)
	Library:Notify(string.format("Stopped on %s [%d OVR] %s", offer.rarity, offer.overall, offer.name))
	if isOn("StopUnloadAfterPick") then
		Toggles.AutoFreeReroll:SetValue(false)
		if Toggles.AutoRealReroll then
			Toggles.AutoRealReroll:SetValue(false)
		end
		if Toggles.AutoLegendReroll then
			Toggles.AutoLegendReroll:SetValue(false)
		end
	end
end
local function requestReroll(kind)
	if LocalPlayer:GetAttribute("RerollRequestPending") == true then
		return false
	end
	if kind == "Casual" then
		if not freeRerollReady() then
			return false
		end
	elseif kind == "Real" then
		if getStatValue("RealRerolls") < 1 then
			return false
		end
	elseif kind == "Legend" then
		if getStatValue("LegendRerolls") < 1 then
			return false
		end
	else
		return false
	end
	RequestReroll:FireServer(kind)
	return true
end
local function getOwnedFighters()
	local ok, result = pcall(function()
		return RequestCurrentFighters:InvokeServer()
	end)
	if ok and typeof(result) == "table" then
		return result
	end
	local folder = LocalPlayer:FindFirstChild("Fighters")
	local fighters = {}
	if not folder then
		return fighters
	end
	for _, child in ipairs(folder:GetChildren()) do
		local entry = { FighterId = child.Name }
		for _, value in ipairs(child:GetChildren()) do
			if value:IsA("ValueBase") then
				entry[value.Name] = value.Value
			end
		end
		table.insert(fighters, entry)
	end
	return fighters
end
local function fighterStat(fighter, key)
	local value = fighter and fighter[key]
	return typeof(value) == "number" and value or 0
end
local function fighterRoom(fighter)
	return math.max(0, fighterStat(fighter, "TrainingCap") - fighterStat(fighter, "Overall"))
end
local function sortFighters(fighters, mode)
	local copy = {}
	for i, fighter in ipairs(fighters) do
		copy[i] = fighter
	end
	table.sort(copy, function(a, b)
		if mode == "Highest Overall" then
			return fighterStat(a, "Overall") > fighterStat(b, "Overall")
		elseif mode == "Most Training Room" then
			local roomA = fighterRoom(a)
			local roomB = fighterRoom(b)
			if roomA == roomB then
				return fighterStat(a, "Overall") < fighterStat(b, "Overall")
			end
			return roomA > roomB
		end
		return fighterStat(a, "Overall") < fighterStat(b, "Overall")
	end)
	return copy
end
local function fighterMeetsLeague(fighter, leagueName)
	local ok, result = pcall(function()
		return LeagueConfig.FighterMeetsLeague(fighter, leagueName)
	end)
	if ok then
		return result == true
	end
	local league = LeagueConfig.Leagues and LeagueConfig.Leagues[leagueName]
	if not league then
		return false
	end
	return fighterStat(fighter, "Overall") >= (league.FighterMinOverall or 0)
end
local function getTrainingStations()
	local plot = getPlot()
	local folder = plot and plot:FindFirstChild("TrainingStations")
	if not folder then
		return {}
	end
	local nameCounts = {}
	local stations = {}
	for index, station in ipairs(folder:GetChildren()) do
		local tp = station:FindFirstChild("TP")
		local prompt = tp and tp:FindFirstChildWhichIsA("ProximityPrompt", true)
		if not tp or not prompt then
			continue
		end
		nameCounts[station.Name] = (nameCounts[station.Name] or 0) + 1
		local count = nameCounts[station.Name]
		local label = station.Name
		local totalSame = 0
		for _, other in ipairs(folder:GetChildren()) do
			if other.Name == station.Name then
				totalSame += 1
			end
		end
		if totalSame > 1 then
			label = string.format("%s #%d", station.Name, count)
		end
		table.insert(stations, {
			index = index,
			key = "Station" .. index,
			model = station,
			name = station.Name,
			label = label,
			tp = tp,
			prompt = prompt,
			stat = STATION_STAT_BY_NAME[station.Name] or "Overall",
			fighterOption = "StationFighter_" .. index,
			repsOption = "StationReps_" .. index,
		})
	end
	return stations
end
local function fighterDropdownLabel(fighter)
	local name = fighter.RealName or fighter.PresetName or "Fighter"
	local overall = fighterStat(fighter, "Overall")
	return string.format("%s [%d] %s", name, overall, fighter.FighterId)
end
local function parseFighterIdFromLabel(label)
	if typeof(label) ~= "string" or label == "" or label == NONE_FIGHTER then
		return nil
	end
	local id = string.match(label, "({[%w%-]+})$")
	return id
end
local function getFighterDropdownValues()
	local values = { NONE_FIGHTER }
	for _, fighter in ipairs(getOwnedFighters()) do
		if fighter.FighterId then
			table.insert(values, fighterDropdownLabel(fighter))
		end
	end
	return values
end
local function choosePveFighter()
	local selected = optionValue("PveFighter", NONE_FIGHTER)
	local fighterId = parseFighterIdFromLabel(selected)
	if not fighterId then
		return nil
	end
	for _, fighter in ipairs(getOwnedFighters()) do
		if fighter.FighterId == fighterId then
			return fighter
		end
	end
	return { FighterId = fighterId }
end
local function getFighterSelector()
	local hud = getHud()
	return hud and hud:FindFirstChild("FighterSelector")
end
local function closeFighterSelector()
	local selector = getFighterSelector()
	if not selector then
		return
	end
	local closeButton = selector:FindFirstChild("Close")
	if closeButton then
		fireGuiButton(closeButton)
	end
	selector.Visible = false
end
local function openStationMenu(station)
	closeFighterSelector()
	teleportTo(station.tp.CFrame * CFrame.new(0, 3, 0))
	task.wait(0.15)
	local token
	local connection = OpenTrainingMenu.OnClientEvent:Connect(function(_, sessionToken)
		token = sessionToken
	end)
	pcall(fireproximityprompt, station.prompt)
	local selector = waitFor(function()
		local fs = getFighterSelector()
		if fs and fs.Visible and fs:FindFirstChild("List") and fs.List:FindFirstChild("FighterCard") then
			return fs
		end
	end, 5)
	connection:Disconnect()
	return selector, token
end
local function findSelectorCard(selector, fighterId)
	local list = selector and selector:FindFirstChild("List")
	if not list then
		return nil
	end
	for _, card in ipairs(list:GetChildren()) do
		if card.Name == "FighterCard" and card:GetAttribute("FighterId") == fighterId then
			return card
		end
	end
	return nil
end
local function selectFighterCard(card)
	if not card then
		return false
	end
	local fired = false
	for _, descendant in ipairs(card:GetDescendants()) do
		if descendant:IsA("GuiButton") then
			fired = fireGuiButton(descendant) or fired
		end
	end
	return fired
end
local function chooseNamedFighter(optionName)
	local selected = optionValue(optionName, NONE_FIGHTER)
	local fighterId = parseFighterIdFromLabel(selected)
	if not fighterId then
		return nil
	end
	for _, fighter in ipairs(getOwnedFighters()) do
		if fighter.FighterId == fighterId then
			return fighter
		end
	end
	return { FighterId = fighterId }
end
local function fighterCompletedSpars(fighter)
	return fighterStat(fighter, "CompletedSpars")
end
local function getSparringPrompt()
	local plot = getPlot()
	local rings = plot and plot:FindFirstChild("BoxingRings")
	local ring = rings and rings:FindFirstChild("BoxingRing")
	local podium = ring and ring:FindFirstChild("Podium")
	local place = podium and podium:FindFirstChild("PlacePart")
	return place and place:FindFirstChildWhichIsA("ProximityPrompt", true), place
end
local function openSparringMenu()
	closeFighterSelector()
	local prompt, place = getSparringPrompt()
	if not prompt or not place then
		return nil
	end
	teleportTo(place.CFrame * CFrame.new(0, 3, 0))
	task.wait(0.15)
	local token
	local connection = OpenSparringMenu.OnClientEvent:Connect(function(_, sessionToken)
		token = sessionToken
	end)
	pcall(fireproximityprompt, prompt)
	local selector = waitFor(function()
		local fs = getFighterSelector()
		if fs and fs.Visible and fs:FindFirstChild("List") and fs.List:FindFirstChild("FighterCard") then
			return fs
		end
	end, 5)
	connection:Disconnect()
	return selector, token
end
local function clickFighterCard(card)
	if not card then
		return false
	end
	local button = card:FindFirstChild("Button")
	if button and getconnections then
		local ok, list = pcall(getconnections, button.MouseButton1Click)
		if ok then
			for _, connection in ipairs(list) do
				if connection.Function then
					local info = debug.getinfo(connection.Function)
					if info and info.nups and info.nups >= 20 then
						if pcall(connection.Function) then
							return true
						end
					end
				end
			end
			for _, connection in ipairs(list) do
				local ran = pcall(function()
					if connection.Fire then
						connection:Fire()
					elseif connection.Function then
						connection.Function()
					end
				end)
				if ran then
					return true
				end
			end
		end
	end
	return selectFighterCard(card)
end
local function getFighterSpars(fighterId)
	if typeof(fighterId) ~= "string" or fighterId == "" then
		return 0
	end
	local ok, result = pcall(function()
		return RequestCurrentFighters:InvokeServer()
	end)
	if ok and typeof(result) == "table" then
		for _, fighter in ipairs(result) do
			if fighter.FighterId == fighterId then
				return fighterCompletedSpars(fighter)
			end
		end
		return 0
	end
	for _, fighter in ipairs(getOwnedFighters()) do
		if fighter.FighterId == fighterId then
			return fighterCompletedSpars(fighter)
		end
	end
	return 0
end
local function startSparForFighter(fighterId)
	if typeof(fighterId) ~= "string" or fighterId == "" then
		return false
	end
	local before = getFighterSpars(fighterId)
	local selector = openSparringMenu()
	if not selector then
		return false
	end
	local card = findSelectorCard(selector, fighterId)
	if not card then
		closeFighterSelector()
		return false
	end
	if not clickFighterCard(card) then
		closeFighterSelector()
		return false
	end
	local deadline = os.clock() + 60
	while os.clock() < deadline do
		if Library.Unloaded then
			return false
		end
		task.wait(1)
		if getFighterSpars(fighterId) > before then
			return true
		end
	end
	return false
end
local function buyBoxerForFighter(fighterId)
	if typeof(fighterId) ~= "string" or fighterId == "" then
		return false
	end
	local ok, shop = pcall(function()
		return RequestPantsShop:InvokeServer()
	end)
	if not ok or typeof(shop) ~= "table" or typeof(shop.Offers) ~= "table" then
		return false
	end
	local refreshId = shop.RefreshId
	if typeof(refreshId) ~= "string" then
		return false
	end
	local money = getMoney()
	local offers = {}
	for _, offer in pairs(shop.Offers) do
		if typeof(offer) == "table" and typeof(offer.PantsName) == "string" then
			table.insert(offers, offer)
		end
	end
	table.sort(offers, function(a, b)
		return (tonumber(a.Price) or 0) < (tonumber(b.Price) or 0)
	end)
	for _, offer in ipairs(offers) do
		local price = tonumber(offer.Price) or 0
		if money >= price then
			local purchased, result = pcall(function()
				return PurchasePantsShopItem:InvokeServer(fighterId, offer.PantsName, refreshId)
			end)
			if purchased and typeof(result) == "table" and result.Success == true then
				return true
			end
			if purchased and typeof(result) == "table" and typeof(result.Message) == "string" then
				if string.find(string.lower(result.Message), "enough money", 1, true) then
					return false
				end
			end
		end
	end
	return false
end
local function setTrainingReps(repSelector, desired)
	desired = math.clamp(math.floor(desired), 1, MAX_TRAINING_REPS)
	local amountLabel = repSelector:FindFirstChild("AmountSelected")
	local addButton = repSelector:FindFirstChild("Add")
	local subButton = repSelector:FindFirstChild("Subtract")
	local current = parseNumber(amountLabel and amountLabel.Text) or 1
	local guard = 0
	while current < desired and addButton and guard < MAX_TRAINING_REPS do
		fireGuiButton(addButton)
		task.wait(0.05)
		current = parseNumber(amountLabel.Text) or current
		guard += 1
	end
	guard = 0
	while current > desired and subButton and guard < MAX_TRAINING_REPS do
		fireGuiButton(subButton)
		task.wait(0.05)
		current = parseNumber(amountLabel.Text) or current
		guard += 1
	end
	local startButton = repSelector:FindFirstChild("Start")
	if startButton and getconnections then
		local ok, list = pcall(getconnections, startButton.MouseButton1Click)
		if ok and list[1] and list[1].Function and setupvalue then
			pcall(setupvalue, list[1].Function, 5, desired)
		end
	end
	return current
end
local function startTrainingFromUi(selector, reps)
	local repSelector = waitFor(function()
		local rep = selector:FindFirstChild("RepSelector")
		if rep and rep.Visible then
			return rep
		end
	end, 4)
	if not repSelector then
		return false
	end
	setTrainingReps(repSelector, reps)
	task.wait(0.05)
	local startButton = repSelector:FindFirstChild("Start")
	return fireGuiButton(startButton)
end
local function assignFighterToStation(station, fighterId, reps)
	if typeof(fighterId) ~= "string" or fighterId == "" then
		return false
	end
	local selector = openStationMenu(station)
	if not selector then
		return false
	end
	local card = findSelectorCard(selector, fighterId)
	if not card then
		closeFighterSelector()
		return false
	end
	selectFighterCard(card)
	local started = startTrainingFromUi(selector, reps or 1)
	if not started then
		closeFighterSelector()
		return false
	end
	task.wait(0.35 + ((reps or 1) * 0.35))
	return true
end
local function getMatchSignup()
	local hud = getHud()
	return hud and hud:FindFirstChild("MatchSignup")
end
local function openMatchSignup()
	local existing = getMatchSignup()
	if existing and existing.Visible then
		return existing
	end
	local hud = getHud()
	local fightButton = hud and (hud:FindFirstChild("FightButton", true) or (hud:FindFirstChild("Right") and hud.Right:FindFirstChild("FightButton")))
	if fightButton then
		fireGuiButton(fightButton)
	end
	return waitFor(function()
		local menu = getMatchSignup()
		if menu and menu.Visible then
			return menu
		end
	end, 5)
end
local function startPveFight()
	if not RequestOfficialNPCMatch or not RequestOfficialNPCMatch.Parent then
		return false
	end
	local league = optionValue("PveLeague", "Bronze")
	local leagueData = LeagueConfig.Leagues and LeagueConfig.Leagues[league]
	if leagueData and getMoney() < (leagueData.MatchPrice or 0) then
		return false
	end
	local fighter = choosePveFighter()
	if not fighter or not fighter.FighterId then
		return false
	end
	if getFighterSpars(fighter.FighterId) < REQUIRED_SPARS then
		return false
	end
	local beforeMoney = getMoney()
	local errMessage
	local notifyConn
	local Notify = Comms:FindFirstChild("Notify")
	if Notify then
		notifyConn = Notify.OnClientEvent:Connect(function(message, _, kind)
			if kind == "Error" or (typeof(message) == "string" and string.find(string.lower(message), "available", 1, true)) then
				errMessage = tostring(message)
			end
		end)
	end
	RequestOfficialNPCMatch:FireServer(fighter.FighterId, league)
	task.wait(0.6)
	if notifyConn then
		notifyConn:Disconnect()
	end
	if errMessage then
		closeFighterSelector()
		local menu = openMatchSignup()
		if not menu then
			return false
		end
		local leagueButton = menu:FindFirstChild(league)
		if not leagueButton then
			return false
		end
		local clickTarget = leagueButton:IsA("GuiButton") and leagueButton or leagueButton:FindFirstChildWhichIsA("GuiButton", true) or leagueButton
		fireGuiButton(clickTarget)
		local selector = waitFor(function()
			local fs = getFighterSelector()
			if fs and fs.Visible and fs:FindFirstChild("List") and fs.List:FindFirstChild("FighterCard") then
				return fs
			end
		end, 5)
		if not selector then
			return false
		end
		local card = findSelectorCard(selector, fighter.FighterId)
		if not card then
			closeFighterSelector()
			return false
		end
		if not clickFighterCard(card) then
			closeFighterSelector()
			return false
		end
	end
	local deadline = os.clock() + 20
	while os.clock() < deadline do
		if Library.Unloaded then
			return false
		end
		task.wait(0.5)
		if getMoney() < beforeMoney then
			return true
		end
		local matchViewer = LocalPlayer.PlayerGui:FindFirstChild("MatchViewer")
		if matchViewer then
			local frame = matchViewer:FindFirstChild("Frame")
			local arena = matchViewer:FindFirstChild("ArenaInformation")
			local winner = matchViewer:FindFirstChild("WinnerFrame")
			if (frame and frame.Visible) or (arena and arena.Visible) or (winner and winner.Visible) then
				return true
			end
		end
	end
	return true
end
local Window = Library:CreateWindow({
	Title = "Tempo Hub",
	Footer = {
		{ Text = DISCORD_INVITE, Copyable = true },
		"|",
		GAME_NAME,
	},
	Icon = 12645376577,
	NotifySide = "Right",
	ShowCustomCursor = false,
	CornerRadius = 10,
})
local Tabs = {
	Info = Window:AddTab("Info", "info"),
	Main = Window:AddTab("Main", "swords"),
	Settings = Window:AddTab("Settings", "settings"),
}
Tabs.Reroll = Tabs.Main:AddSubTab("Reroll", "dices")
Tabs.Training = Tabs.Main:AddSubTab("Training", "activity")
Tabs.Fights = Tabs.Main:AddSubTab("Fights", "swords")
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
	if Tab ~= Tabs.Main then
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
		if setclipboard then
			setclipboard(joinScript)
		elseif toclipboard then
			toclipboard(joinScript)
		end
		Library:Notify("Copied join script to clipboard")
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
FeaturesGroup:AddLabel(colored("Auto Reroll", BLUE), true)
FeaturesGroup:AddLabel(colored("Auto Stop Roll", ORANGE), true)
FeaturesGroup:AddLabel(colored("Auto Assign / Training", GREEN), true)
FeaturesGroup:AddLabel(colored("Auto Spar / PVE", GREY), true)
FeaturesGroup:AddLabel(colored("Auto Buy Boxers", ORANGE), true)
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
local RerollGroup = Tabs.Reroll:AddLeftGroupbox("Auto Reroll", "refresh-cw")
RerollGroup:AddToggle("AutoFreeReroll", {
	Text = "Auto Free Reroll",
	Default = false,
})
RerollGroup:AddToggle("AutoRealReroll", {
	Text = "Auto Real Reroll",
	Default = false,
})
RerollGroup:AddToggle("AutoLegendReroll", {
	Text = "Auto Legend Reroll",
	Default = false,
})
RerollGroup:AddToggle("UseInstantReveal", {
	Text = "Instant Reveal",
	Default = true,
})
RerollGroup:AddSlider("RerollDelay", {
	Text = "Reroll Delay",
	Default = 0.35,
	Min = 0.1,
	Max = 3,
	Rounding = 2,
})
local StopGroup = Tabs.Reroll:AddRightGroupbox("Auto Stop Roll", "hand")
StopGroup:AddToggle("AutoStopRoll", {
	Text = "Auto Stop Roll",
	Default = false,
})
StopGroup:AddDropdown("StopRarities", {
	Text = "Rarities",
	Values = RARITY_VALUES,
	Default = { "Real [Shiny]", "Legend [Shiny]" },
	Multi = true,
	AllowNull = true,
})
StopGroup:AddDropdown("StopPickMode", {
	Text = "Pick Mode",
	Values = { "Lowest Overall", "Best Overall", "First Match" },
	Default = "Lowest Overall",
})
StopGroup:AddToggle("StopUnloadAfterPick", {
	Text = "Stop Rerolling After Pick",
	Default = true,
})
StopGroup:AddSlider("StopMinOverall", {
	Text = "Min Overall",
	Default = 0,
	Min = 0,
	Max = 99,
	Rounding = 0,
})
StopGroup:AddSlider("StopMinTrainingCap", {
	Text = "Min Training Cap",
	Default = 0,
	Min = 0,
	Max = 99,
	Rounding = 0,
})
for _, stat in ipairs({ "Power", "Agility", "Dexterity", "Endurance", "Reach", "Stamina" }) do
	StopGroup:AddSlider("StopMin" .. stat, {
		Text = "Min " .. stat,
		Default = 0,
		Min = 0,
		Max = 99,
		Rounding = 0,
	})
end
local TrainingGroup = Tabs.Training:AddLeftGroupbox("Auto Assign", "user-plus")
TrainingGroup:AddToggle("AutoAssignFighters", {
	Text = "Auto Assign Fighters",
	Default = false,
})
TrainingGroup:AddSlider("TrainingDelay", {
	Text = "Assign Delay",
	Default = 0.75,
	Min = 0.2,
	Max = 5,
	Rounding = 2,
})
local TrainingStations = getTrainingStations()
if #TrainingStations == 0 then
	local deadline = os.clock() + 8
	while #TrainingStations == 0 and os.clock() < deadline do
		task.wait(0.25)
		TrainingStations = getTrainingStations()
	end
end
local StationDropdowns = {}
local refreshFighterDropdowns
local function fighterValuesWithoutNone()
	local values = getFighterDropdownValues()
	local withoutNone = {}
	for _, value in ipairs(values) do
		if value ~= NONE_FIGHTER then
			table.insert(withoutNone, value)
		end
	end
	if #withoutNone == 0 then
		return { NONE_FIGHTER }
	end
	table.insert(withoutNone, 1, NONE_FIGHTER)
	return withoutNone
end
TrainingGroup:AddButton({
	Text = "Refresh Fighters",
	Func = function()
		if refreshFighterDropdowns then
			refreshFighterDropdowns()
		end
		Library:Notify("Fighter lists refreshed")
	end,
})
local initialFighterValues = fighterValuesWithoutNone()
for _, station in ipairs(TrainingStations) do
	local stationGroup = Tabs.Training:AddRightGroupbox(station.label, "map-pin")
	local fighterDropdown = stationGroup:AddDropdown(station.fighterOption, {
		Text = "Fighter",
		Values = initialFighterValues,
		Default = NONE_FIGHTER,
		AllowNull = false,
	})
	stationGroup:AddSlider(station.repsOption, {
		Text = "Reps",
		Default = 1,
		Min = 1,
		Max = MAX_TRAINING_REPS,
		Rounding = 0,
	})
	table.insert(StationDropdowns, fighterDropdown)
end
refreshFighterDropdowns = function()
	local values = fighterValuesWithoutNone()
	for _, dropdown in ipairs(StationDropdowns) do
		local current = dropdown.Value
		dropdown:SetValues(values)
		if current and table.find(values, current) then
			dropdown:SetValue(current)
		else
			dropdown:SetValue(NONE_FIGHTER)
		end
	end
	local pveValues = {}
	for _, value in ipairs(values) do
		if value ~= NONE_FIGHTER then
			table.insert(pveValues, value)
		end
	end
	if #pveValues == 0 then
		pveValues = { NONE_FIGHTER }
	end
	for _, name in ipairs({ "PveFighter", "SparFighter", "BoxerFighter" }) do
		local dropdown = Options[name]
		if dropdown then
			local current = dropdown.Value
			dropdown:SetValues(pveValues)
			if current and table.find(pveValues, current) then
				dropdown:SetValue(current)
			elseif pveValues[1] then
				dropdown:SetValue(pveValues[1])
			end
		end
	end
end
local function formatSparStatusText()
	local fighters = getOwnedFighters()
	if #fighters == 0 then
		return colored("No fighters", GREY)
	end
	local lines = {}
	for _, fighter in ipairs(fighters) do
		local name = fighter.RealName or fighter.PresetName or "Fighter"
		local spars = fighterCompletedSpars(fighter)
		local color = spars >= REQUIRED_SPARS and GREEN or ORANGE
		table.insert(lines, field(name, spars .. " / " .. REQUIRED_SPARS, color))
	end
	return table.concat(lines, "<br/>")
end
local FightGroup = Tabs.Fights:AddLeftGroupbox("Auto Spar", "swords")
FightGroup:AddToggle("AutoSpar", {
	Text = "Auto Spar",
	Default = false,
})
FightGroup:AddToggle("SparStopAtThree", {
	Text = "Stop At 3 Spars",
	Default = true,
})
local fightFighterDefaults = {}
for _, value in ipairs(initialFighterValues) do
	if value ~= NONE_FIGHTER then
		table.insert(fightFighterDefaults, value)
	end
end
if #fightFighterDefaults == 0 then
	fightFighterDefaults = { NONE_FIGHTER }
end
FightGroup:AddDropdown("SparFighter", {
	Text = "Fighter",
	Values = fightFighterDefaults,
	Default = fightFighterDefaults[1],
	AllowNull = false,
})
FightGroup:AddSlider("SparDelay", {
	Text = "Spar Delay",
	Default = 2,
	Min = 0.5,
	Max = 15,
	Rounding = 1,
})
local refreshSparStatus
FightGroup:AddButton({
	Text = "Refresh Fighters",
	Func = function()
		if refreshFighterDropdowns then
			refreshFighterDropdowns()
		end
		if refreshSparStatus then
			refreshSparStatus()
		end
		Library:Notify("Fighter lists refreshed")
	end,
})
local PveGroup = Tabs.Fights:AddLeftGroupbox("Auto PVE", "trophy")
PveGroup:AddToggle("AutoPve", {
	Text = "Auto Start PVE",
	Default = false,
})
PveGroup:AddDropdown("PveLeague", {
	Text = "League",
	Values = LEAGUE_VALUES,
	Default = "Bronze",
})
PveGroup:AddDropdown("PveFighter", {
	Text = "Fighter",
	Values = fightFighterDefaults,
	Default = fightFighterDefaults[1],
	AllowNull = false,
})
PveGroup:AddSlider("PveDelay", {
	Text = "Fight Delay",
	Default = 3,
	Min = 1,
	Max = 20,
	Rounding = 1,
})
PveGroup:AddButton({
	Text = "Refresh Fighters",
	Func = function()
		if refreshFighterDropdowns then
			refreshFighterDropdowns()
		end
		if refreshSparStatus then
			refreshSparStatus()
		end
		Library:Notify("Fighter lists refreshed")
	end,
})
local SparStatusGroup = Tabs.Fights:AddRightGroupbox("Spar Status", "activity")
local SparStatusLabel = SparStatusGroup:AddLabel(formatSparStatusText(), true)
refreshSparStatus = function()
	SparStatusLabel:SetText(formatSparStatusText())
end
local ShopGroup = Tabs.Fights:AddRightGroupbox("Money Shop", "shopping-bag")
ShopGroup:AddToggle("AutoBuyBoxers", {
	Text = "Auto Buy Boxers",
	Default = false,
})
ShopGroup:AddDropdown("BoxerFighter", {
	Text = "Fighter",
	Values = fightFighterDefaults,
	Default = fightFighterDefaults[1],
	AllowNull = false,
})
ShopGroup:AddSlider("BoxerDelay", {
	Text = "Buy Delay",
	Default = 2,
	Min = 0.5,
	Max = 15,
	Rounding = 1,
})
ShopGroup:AddButton({
	Text = "Refresh Fighters",
	Func = function()
		if refreshFighterDropdowns then
			refreshFighterDropdowns()
		end
		Library:Notify("Fighter lists refreshed")
	end,
})
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu", "menu")
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
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("TempoHub")
ThemeManager:SaveDefault("Monochrome")
ThemeManager:ApplyToTab(Tabs.Settings)
ThemeManager:LoadDefault()
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("TempoHub/coach-a-fighter")
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
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
Library:OnUnload(function()
	antiAfkBeganConnection:Disconnect()
	antiAfkChangedConnection:Disconnect()
end)
task.spawn(function()
	while not Library.Unloaded do
		task.wait(2)
		if isOn("AntiAfk") then
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
task.spawn(function()
	while not Library.Unloaded do
		local delayTime = optionValue("RerollDelay", 0.35) or 0.35
		task.wait(delayTime)
		if not isOn("AutoFreeReroll") and not isOn("AutoRealReroll") and not isOn("AutoLegendReroll") and not isOn("AutoStopRoll") then
			continue
		end
		if rerollBusy then
			continue
		end
		rerollBusy = true
		local ok, err = pcall(function()
			if isOn("UseInstantReveal") then
				setInstantReveal(true)
			end
			if isOn("AutoStopRoll") then
				local choice = chooseOffer(getOfferCards())
				if choice and pickOffer(choice) then
					onOfferPicked(choice)
					task.wait(0.4)
					return
				end
			end
			local rolled = false
			if isOn("AutoFreeReroll") then
				rolled = requestReroll("Casual")
			end
			if not rolled and isOn("AutoRealReroll") then
				rolled = requestReroll("Real")
			end
			if not rolled and isOn("AutoLegendReroll") then
				rolled = requestReroll("Legend")
			end
			if rolled then
				task.wait(0.25)
				if isOn("AutoStopRoll") then
					local choice = chooseOffer(getOfferCards())
					if choice and pickOffer(choice) then
						onOfferPicked(choice)
					end
				end
			end
		end)
		rerollBusy = false
		if not ok then
			warn("[Tempo] Reroll loop:", err)
		end
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		local delayTime = optionValue("TrainingDelay", 0.75) or 0.75
		task.wait(delayTime)
		if not isOn("AutoAssignFighters") then
			continue
		end
		local ok, err = pcall(function()
			for _, station in ipairs(TrainingStations) do
				if Library.Unloaded or not isOn("AutoAssignFighters") then
					break
				end
				if not station.model or not station.model.Parent then
					local refreshed = getTrainingStations()
					for _, fresh in ipairs(refreshed) do
						if fresh.index == station.index then
							station.model = fresh.model
							station.tp = fresh.tp
							station.prompt = fresh.prompt
							break
						end
					end
				end
				local fighterLabel = optionValue(station.fighterOption, NONE_FIGHTER)
				local fighterId = parseFighterIdFromLabel(fighterLabel)
				if fighterId then
					local reps = optionValue(station.repsOption, 1) or 1
					assignFighterToStation(station, fighterId, reps)
					task.wait(delayTime)
				end
			end
		end)
		if not ok then
			warn("[Tempo] Training loop:", err)
		end
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		task.wait(2)
		if refreshSparStatus then
			pcall(refreshSparStatus)
		end
	end
end)
task.spawn(function()
	local pveBusy = false
	while not Library.Unloaded do
		local delayTime = optionValue("PveDelay", 3) or 3
		task.wait(delayTime)
		if not isOn("AutoPve") or pveBusy then
			continue
		end
		pveBusy = true
		local ok, err = pcall(startPveFight)
		pveBusy = false
		if not ok then
			warn("[Tempo] PVE loop:", err)
		end
	end
end)
task.spawn(function()
	local sparBusy = false
	while not Library.Unloaded do
		local delayTime = optionValue("SparDelay", 2) or 2
		task.wait(delayTime)
		if not isOn("AutoSpar") or sparBusy then
			continue
		end
		sparBusy = true
		local ok, err = pcall(function()
			local fighter = chooseNamedFighter("SparFighter")
			if not fighter or not fighter.FighterId then
				return
			end
			local spars = getFighterSpars(fighter.FighterId)
			if isOn("SparStopAtThree") and spars >= REQUIRED_SPARS then
				return
			end
			startSparForFighter(fighter.FighterId)
		end)
		sparBusy = false
		if not ok then
			warn("[Tempo] Spar loop:", err)
		end
	end
end)
task.spawn(function()
	while not Library.Unloaded do
		local delayTime = optionValue("BoxerDelay", 2) or 2
		task.wait(delayTime)
		if not isOn("AutoBuyBoxers") then
			continue
		end
		local ok, err = pcall(function()
			local fighter = chooseNamedFighter("BoxerFighter")
			if not fighter or not fighter.FighterId then
				return
			end
			buyBoxerForFighter(fighter.FighterId)
		end)
		if not ok then
			warn("[Tempo] Boxer loop:", err)
		end
	end
end)
end)(...)
